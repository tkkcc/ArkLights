-- print('util')
oppid = "com.hypergryph.arknights"
if use_zhuzhu_game then oppid = "com.hypergryph.arknightss" end
bppid = "com.hypergryph.arknights.bilibili"
-- apk502 = getApkVerInt() >= 502 or getApkVerInt() == 1
apk502 = getApkVerInt() >= 502
is_apk_old = function() return getApkVerInt() < 0 end
apk_old_warning = "怎么还有人用" .. getApkVerInt()

disable_game_up_check_wrapper = function(func)
  return function(...)
    local state = disable_game_up_check
    disable_game_up_check = true
    local ret = func(...)
    disable_game_up_check = state
    return ret
  end
end
never_end_wrapper = function(func)
  return function(...) while true do func(...) end end
end
still_wrapper = function(func)
  return function(...)
    -- nodeLib.keepNode()
    keepCapture()
    local ret = func(...)
    releaseCapture()
    -- nodeLib.releaseNode()
    return ret
  end
end
disable_log_wrapper = function(func, enable)
  return function(...)
    local state = disable_log
    disable_log = not enable and true or false
    local ret = func(...)
    disable_log = state
    return ret
  end
end
enable_log_wrapper = function(func) return disable_log_wrapper(func, true) end

-- _restartScript = restartScript

-- 无障碍函数替换
if not openPermissionSetting then
  openPermissionSetting =
    function() stop("没root请换用无障碍版速通") end
  isSnapshotServiceRun = function() return true end
  isAccessibilityServiceRun = function() return true end
  Path = {}
  function Path:new(o)
    o = o or {startTime = 0, durTime = 0, point = {}}
    setmetatable(o, self)
    self.__index = self
    return o
  end
  function Path:setStartTime(t) self.startTime = t end
  function Path:setDurTime(t) self.durTime = t end
  function Path:addPoint(x, y)
    table.insert(self.point, x)
    table.insert(self.point, y)
  end
  Gesture = {}
  function Gesture:new(o)
    o = o or {path = {}}
    setmetatable(o, self)
    self.__index = self
    return o
  end
  function Gesture:addPath(path) table.insert(self.path, path) end
  gestureDispatchOnePath = function(path, id)
    local point = path.point
    if #point < 2 then return end
    local start_time = time()
    local timeline = {}
    local length = 0
    local x, y, px, py
    px = point[1]
    py = point[2]
    sleep(path.startTime)
    for i = 2, #point / 2 do
      x = point[i * 2]
      y = point[i * 2 + 1]
      length = length + math.sqrt((x - px) ^ 2 + (y - py) ^ 2)
      table.insert(timeline, length)
      px, py = x, y
    end
    touchUp(id)
    touchMove(id, point[1], point[2])
    touchDown(id)
    print(59, id, point)
    for i = 2, #point / 2 do
      x = point[i * 2]
      y = point[i * 2 + 1]
      timeline[i] = timeline[i] / length * path.durTime
      touchMoveEx(id, x, y, timeline[i])
      if time() - start_time > path.durTime then break end
    end
    sleep(max(0, time() - start_time - path.durTime))
    print(60, id, point, start_time + path.durTime - time())
    touchUp(id)
  end
  function Gesture:dispatch()

    for id, path in pairs(self.path) do
      log(71, id, path)
      beginThread(gestureDispatchOnePath, path, id)
    end
  end
end

package = getPackageName()
-- transfer 节点精灵 to 懒人精灵
getColor = function(x, y)
  local bgr = getPixelColor(x, y):upper()
  return bgr:sub(7, 8) .. bgr:sub(5, 6) .. bgr:sub(3, 4)
end
time = systemTime
exit = exitScript
JsonDecode = jsonLib.decode
JsonEncode = jsonLib.encode
findNode = function(selector) return nodeLib.findOne(selector, true) end
findNodes = function(selector) return nodeLib.findAll(selector, true) end
clickNode = function(x) nodeLib.click(x, true) end
clickNodeFalse = function(x) nodeLib.click(x, false) end
clickPoint = function(x, y)
  local gesture = Gesture:new()
  local path = Path:new()
  path:setStartTime(0)
  path:setDurTime(1)
  path:addPoint(x, y)
  gesture:addPath(path)
  gesture:dispatch()
end
_tap = tap
if not zero_wait_click then clickPoint = tap end

getDir = getWorkPath
base64 = getFileBase64
putClipboard = writePasteboard
getClipboard = readPasteboard
_toast = toast
toast = function(x)
  _toast(x)
  log(x)
end

deviceClickEventMaxX = nil
deviceClickEventMaxY = nil
catchClick = function()
  if not root_mode then stop("未实现免root获取用户点击") end
  local result = exec("su root sh -c 'getevent -l -c 4 -q'")
  local x, y
  x = result:match('POSITION_X%s+([^%s]+)')
  y = result:match('POSITION_Y%s+([^%s]+)')
  -- log(33, x, y)
  if x and y then
    if not deviceClickEventX then
      local event = result:match('(/dev/[^:]+):.+POSITION_X')
      result = exec("su root sh -c 'getevent -il " .. event .. "'")
      deviceClickEventMaxX = result:match("POSITION_X[^\n]+max%s*(%d+)")
      deviceClickEventMaxY = result:match("POSITION_Y[^\n]+max%s*(%d+)")
    end
    local screen = getScreen()
    return {
      x = math.round(tonumber(x, 16) * screen.width / deviceClickEventMaxX),
      y = math.round(tonumber(y, 16) * screen.height / deviceClickEventMaxY),
    }
  end
end
home = function()
  -- open(package)
  keyPress(3)
end
back = function() keyPress(4) end
power = function() keyPress(26) end
_getDisplaySize = getDisplaySize
getDisplaySize = function()
  -- override height and width
  if type(force_height) == 'number' and type(force_width) == 'number' and
    force_width > 0 and force_height > 0 then return force_width, force_height end

  -- -- try to get from wm command, seems not work on real devices
  -- local wmsize = exec("wm size")
  -- local x, y = wmsize:match("(%d+)%s*x%s*(%d+)%s*$")
  -- x = str2int(x, -1)
  -- y = str2int(y, -1)
  -- if x > 0 and y > 0 then return x, y end

  -- use internal api
  return _getDisplaySize()
end
getScreen = function()
  local width, height = getDisplaySize()
  if getDisplayRotate() % 2 == 1 then width, height = height, width end
  return {width = width, height = height}
end
saveConfig = setStringConfig
loadConfig = function(k, v)
  v = v or ''
  local y = getStringConfig(k)
  if not y or #y == 0 then y = v end
  return y
end

peaceExit = function()
  -- need_show_console = false
  exit()
end

max = math.max
min = math.min
math.round = function(x) return math.floor(x + 0.5) end
round = math.round
clip = function(x, minimum, maximum) return min(max(x, minimum), maximum) end

-- https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
string.quote = function(str)
  local quotepattern = '([' .. ("%^$().[]*+-?"):gsub("(.)", "%%%1") .. '])'
  return str:gsub(quotepattern, "%%%1")
end

-- https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
string.trim = function(s)

  s = s or ''
  return s:match '^()%s*$' and '' or s:match '^%s*(.*%S)'
end

string.count = function(str, pattern)
  local ans = 0
  for _ in str.gfind(pattern) do ans = ans + 1 end
  return ans
end

string.map = function(str, map)
  local ans = ''
  for character in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
    -- print(217, character)
    if map[character] == nil then
      ans = ans .. character
    else
      ans = ans .. map[character]
    end
  end
  return ans
end

string.split = function(str, sep)
  if sep == nil then sep = "%s" end
  local t = {}
  for str in string.gmatch(str, "([^" .. sep .. "]+)") do table.insert(t, str) end
  return t
end

-- 全角转半角
string.commonmap = function(str, extra_map)
  return string.map(str, update({
    ["　"] = " ",
    ["１"] = "1",
    ["２"] = "2",
    ["３"] = "3",
    ["４"] = "4",
    ["５"] = "5",
    ["６"] = "6",
    ["７"] = '7',
    ["８"] = '8',
    ["９"] = '9',
    ["０"] = '0',

    ["Ａ"] = 'a',
    ["Ｂ"] = 'b',
    ["Ｃ"] = 'c',
    ["Ｄ"] = 'd',
    ["Ｅ"] = 'e',
    ["Ｆ"] = 'f',
    ["Ｇ"] = 'g',
    ["Ｈ"] = 'h',
    ["Ｉ"] = 'i',
    ["Ｊ"] = 'j',
    ["Ｋ"] = 'k',
    ["Ｌ"] = 'l',
    ["Ｍ"] = 'm',
    ["Ｎ"] = 'n',
    ["Ｏ"] = 'o',
    ["Ｐ"] = 'p',
    ["Ｑ"] = 'q',
    ["Ｒ"] = 'r',
    ["Ｓ"] = 's',
    ["Ｔ"] = 't',
    ["Ｕ"] = 'u',
    ["Ｖ"] = 'v',
    ["Ｗ"] = 'w',
    ["Ｘ"] = 'x',
    ["Ｙ"] = 'y',
    ["Ｚ"] = 'z',

    ["ａ"] = 'a',
    ["ｂ"] = 'b',
    ["ｃ"] = 'c',
    ["ｄ"] = 'd',
    ["ｅ"] = 'e',
    ["ｆ"] = 'f',
    ["ｇ"] = 'g',
    ["ｈ"] = 'h',
    ["ｉ"] = 'i',
    ["ｊ"] = 'j',
    ["ｋ"] = 'k',
    ["ｌ"] = 'l',
    ["ｍ"] = 'm',
    ["ｎ"] = 'n',
    ["ｏ"] = 'o',
    ["ｐ"] = 'p',
    ["ｑ"] = 'q',
    ["ｒ"] = 'r',
    ["ｓ"] = 's',
    ["ｔ"] = 't',
    ["ｕ"] = 'u',
    ["ｖ"] = 'v',
    ["ｗ"] = 'w',
    ["ｘ"] = 'x',
    ["ｙ"] = 'y',
    ["ｚ"] = 'z',

    [";"] = " ",
    ['"'] = " ",
    ["'"] = " ",
    ["；"] = " ",
    ["："] = ":",
    [":"] = ":",
    [","] = " ",
    ["_"] = "-",
    ["－"] = "-",
    ["＿"] = "-",
    ["、"] = " ",
    ["，"] = " ",
    ["|"] = " ",
    ["@"] = "@",
    ["#"] = "#",
    ["\n"] = " ",
    ["\t"] = " ",

    ["！"] = "!",
    ["＠"] = "@",
    ["＃"] = "#",
    ["＄"] = " ",
    ["％"] = " ",
    ["＾"] = " ",
    ["＆"] = " ",
    ["＊"] = "*",
    ["（"] = " ",
    ["）"] = " ",
    ["￥"] = " ",
    ["…"] = " ",
    ["×"] = "x",
    ["—"] = "-",
    ["＋"] = "+",
  }, extra_map or {}))

end

string.filterSplit = function(str, extra_map)
  return string.split(string.commonmap(str, extra_map))
end

string.startsWith = function(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

string.endsWith = function(str, suffix)
  return string.sub(str, #str - string.len(suffix) + 1) == suffix
end

startsWithX = function(x) return
  function(prefix) return x:startsWith(prefix) end end

string.padStart = function(str, len, char)
  if char == nil then char = " " end
  return string.rep(char, len - #str) .. str
end
string.padEnd = function(str, len, char)
  if char == nil then char = " " end
  return str .. string.rep(char, len - #str)
end
table.diff = function(a, b)
  local ans = {}
  for k, v in pairs(a) do if v ~= b[k] then ans[k] = v end end
  return ans
end
table.index = function(t, idx)
  local ans = {}
  for _, i in pairs(idx) do table.insert(ans, t[i]) end
  return ans
end
table.reduce = function(t, f, a)
  a = a or 0
  for _, c in pairs(t) do a = f(a, c) end
  return a
end
table.sum = function(t)
  local a = 0
  for _, c in pairs(t) do a = a + c end
  return a
end
-- 从t中选出长度为n的所有组合，结果在ans，
table.combination = function(t, n)
  local ans = {}
  local cur = {}
  local k = 1
  combination(t, n, ans, cur, k)
  return ans
end
combination = function(t, n, ans, cur, k)
  -- cur = cur or {}
  -- k = k or 1
  if n == 0 then
    table.insert(ans, shallowCopy(cur))
  elseif k <= #t then
    table.insert(cur, t[k])
    combination(t, n - 1, ans, cur, k + 1)
    cur[#cur] = nil
    combination(t, n, ans, cur, k + 1)
  end
end

table.flatten = function(t)
  local ans = {}
  for _, v in pairs(t) do
    if type(v) == 'table' then
      table.extend(ans, table.flatten(v))
    else
      table.insert(ans, v)
    end
  end
  return ans
end

table.remove_duplicate = function(t)
  local ans = {}
  local visited = {}
  for _, v in pairs(t) do
    if not visited[v] then
      table.insert(ans, v)
      visited[v] = 1
    end
  end
  return ans
end

-- 出现n次的元素
table.appear_times = function(t, times)
  local ans = {}
  local visited = {}
  for _, v in pairs(t) do visited[v] = (visited[v] or 0) + 1 end
  -- log(visited)
  -- exit()
  for k, _ in pairs(visited) do
    if visited[k] == times then table.insert(ans, k) end
  end
  return ans
end

-- table.rotate = function(t, idx)
--   return table.extend(table.slice(t, idx), table.slice(t, 1, idx - 1))
-- end

-- 交
table.intersect = function(a, b)
  local ans = {}
  if #b < #a then a, b = b, a end
  b = table.value2key(b)
  a = table.value2key(a)
  for k, _ in pairs(a) do if b[k] then table.insert(ans, k) end end
  return ans
end

-- 差
table.subtract = function(a, b)
  local ans = {}
  b = table.value2key(b or {})
  a = table.value2key(a or {})
  for k, _ in pairs(a) do if not b[k] then table.insert(ans, k) end end
  return ans
end

table.slice = function(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do sliced[#sliced + 1] = tbl[i] end
  return sliced
end
-- shallow table
table.contains = function(a, b)
  for k, v in pairs(b) do if a[k] ~= v then return false end end
  return true
end

table.value2key = function(x)
  local ans = {}
  for k, v in pairs(x) do ans[v] = k end
  return ans
end
table.select = function(mask, reference)
  local ans = {}
  for i = 1, #reference do if mask[i] then table.insert(ans, reference[i]) end end
  return ans
end

-- return true if there is an x s.t. f(x) is true
table.any = function(t, f)
  for k, v in pairs(t) do if f(v) then return true end end
end

-- return true if f(x) is all true
table.all = function(t, f)
  for _, v in pairs(t) do if not f(v) then return false end end
  return true
end

table.findv = function(t, f)
  for k, v in pairs(t) do if f(v) then return v end end
end

table.filter = function(t, f)
  local a = {}
  for _, v in pairs(t) do if f(v) then table.insert(a, v) end end
  return a
end
table.filterKV = function(t, f)
  local a = {}
  for k, v in pairs(t) do if f(k, v) then a[k] = v end end
  return a
end

table.keys = function(t)
  local a = {}
  t = t or a
  for k, _ in pairs(t) do table.insert(a, k) end
  return a
end

table.values = function(t)
  local a = {}
  t = t or a
  for _, v in pairs(t) do table.insert(a, v) end
  return a
end

-- a,a+1,...b
range = function(a, b, s)
  local t = {}
  if not b and not s then a, b = 1, a end
  s = s or 1
  for i = a, b, s do table.insert(t, i) end
  return t
end

table.includes = function(t, e)
  return table.any(t, function(x) return x == e end)
end

string.includes = function(s, t)
  for _, v in pairs(t) do if s:find(v) then return true end end
end

table.extend = function(t, e)
  for k, v in pairs(e) do table.insert(t, v) end
  return t
end

table.cat = function(t)
  local ans = {}
  for _, v in pairs(t) do for _, n in pairs(v) do table.insert(ans, n) end end
  return ans
end

--  in = {
--    "A" = {1,4,5,7},
--    "B" = {1,2,5,6},
--    "C" = {3,4,6,7},
--    "D" = {2,3,6,7},
--  }
-- out = { {"A","B"},...}
-- n:key, m:value O(mmn)
table.reverseIndex = function(t)
  local r = {}
  local s = {}
  for k, v in pairs(t) do for k2, v2 in pairs(v) do s[v2] = true end end
  for k, v in pairs(s) do
    r[k] = {}
    for k2, v2 in pairs(t) do
      if table.includes(v2, k) then table.insert(r[k], k2) end
    end
  end
  for k, v in pairs(r) do table.sort(v) end
  return r
end

table.find =
  function(t, f) for k, v in pairs(t) do if f(v) then return k end end end

table.shuffle = function(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

-- one depth compare, and key-value pairs all same
table.equal = function(a, b)
  if type(a) ~= 'table' or type(b) ~= 'table' then return end

  if #a ~= #b then return end
  if #a == 0 and #table.keys(a) ~= #table.keys(b) then return end

  for k, v in pairs(a) do if v ~= b[k] then return end end
  return true
end

-- one depth compare, and key all same
table.equalKey = function(a, b)
  if type(a) ~= 'table' or type(b) ~= 'table' then return end

  if #a ~= #b then return end
  if #a == 0 and #table.keys(a) ~= #table.keys(b) then return end

  for k, _ in pairs(a) do if b[k] == nil then return end end
  return true
end

equalX = function(x) return function(y) return x == y end end

shallowCopy = function(x)
  local y = {}
  if x == nil then return y end
  for k, v in pairs(x) do y[k] = v end
  return y
end

update = function(b, x, inplace, false_as_nil)
  local y = inplace and b or shallowCopy(b)
  if x == nil then return y end
  for k, v in pairs(x) do
    if false_as_nil and v == false then v = nil end
    y[k] = v
  end
  return y
end

-- n: num, a: alternative element
repeat_last = function(x, n, a)
  if a == nil then a = x[#x] end
  for i = 1, n do table.insert(x, a) end
  return x
end

-- TODO: better algorithms
loop_times = function(x)
  local times, f, n
  local maxlen = 40 -- of one piece
  local maxtimes = 1 -- of same pieces
  if x == nil or #x == 0 then return 0 end
  for i = 1, maxlen do
    f = true
    n = math.floor(#x / i)
    if n <= maxtimes then break end
    for j = 1, n - 1 do
      for k = 1, i do
        if x[#x - j * i - k + 1] ~= x[#x - k + 1] then
          f = false
          break
        end
      end
      if not f then
        maxtimes = math.max(maxtimes, j)
        break
      else
        maxtimes = math.max(maxtimes, j + 1)
      end
    end
  end
  return maxtimes
end

map = function(...)
  local a = {...}
  local n = select("#", ...)
  local r = {}
  local f, x = a[1], a[2]
  local p, ur
  if n < 2 then return r end
  if n == 2 then
    n = #x
  elseif n > 2 then
    ur = true
    x = {table.unpack(a, 2, n)}
    n = n - 1
  end
  for i = 1, n do
    p = x[i]
    if type(f) == "function" then
      p = f(p)
    elseif type(f) == "table" then
      p = f[p]
    end
    r[i] = p
  end
  if ur then return table.unpack(r, 1, n) end
  return r
end

ssleep = function(x)
  if x == nil then x = 1 end
  sleep(x * 1000)
end

table.join = function(t, d)
  t = t or {}
  d = not d and ',' or d
  local a = ''
  for i = 1, #t do
    a = a .. t[i]
    if i ~= #t then a = a .. d end
  end
  return a
end

table.clear = function(x) for k, v in pairs(x) do x[k] = nil end end

removeFuncHash =
  function(x) return x:startsWith('function') and 'function' or x end

table2string = function(t)
  if type(t) == 'table' then
    t = shallowCopy(t)
    for k, v in pairs(t) do if type(v) == "function" then t[k] = 'func' end end
    t = JsonEncode(t)
  end
  return t
end

-- log_history = {}
log = function(...)
  if disable_log then return end
  local arg = {...}

  local l = table.join({
    map(tostring, running, ' ', table.unpack(map(table2string, arg))),
  }, ' ')
  -- l = map(removeFuncHash, l)
  -- l = map(table2string, l)

  local a = os.date('%Y.%m.%d %H:%M:%S')
  -- local a = time()
  -- for _, v in pairs(l) do a = a .. ' ' .. v end
  -- TODO: 有可能是日志太多导致速通停止运行
  print(l)
  console.println(1, a .. ' ' .. l)
  -- writeLog(l)
end

open = function(id)
  id = id or appid
  runApp(id)
end

stop = function(msg, mode, nohome, complete)
  msg = msg or ''
  msg = "stop " .. msg
  disable_log = false -- 强制开启日志
  local info = table.join(qqmessage, ' ') .. ' ' .. msg
  captureqqimagedeliver("INFO", "任务结束", info, true)
  toast(msg)
  if complete then
    cloud.completeTask(last_upload_img)
  else
    local type = ''
    if msg:find("登录次数达到") then
      type = cloud.FAILTASK_LINEBUSY
    elseif msg:find("密码") then
      type = cloud.FAILTASK_ACCOUNTERROR
    end
    cloud.failTask(last_upload_img, type)
  end
  cloud.fetchSolveTask()
  if not nohome then
    closeapp(appid)
    home()
  end
  ssleep(2)
  if mode == 'next' then restart_account(true) end
  if mode == 'cur' then restart_account(false) end
  exit()
end

findColorAbsolute = function(color, confidence)
  -- print(286, confidence)
  confidence = confidence or 100
  -- keepScreen(true)
  for x, y, c in color:gmatch("(%d+),(%d+),(#[^|]+)") do
    -- log(x, y, c)
    if not compareColor(tonumber(x), tonumber(y), c, confidence) then
      -- if getColor(tonumber(x), tonumber(y)).hex ~= c then
      if verbose_fca then log(x, y, c) end
      -- keepScreen(false)
      return
    end
  end
  local x, y = color:match("(%d+),(%d+)")
  return {x = tonumber(x), y = tonumber(y)}
end

findOne_game_up_check_last_time = 0
findOne_keepalive_check_last_time = time()
findOne_last_time = time()
findOne_locked = false
findOne = function(x, confidence)
  if type(x) == "function" then return x() end

  -- 每5秒确认游戏在前台
  if (time() - findOne_game_up_check_last_time > 5000) then
    findOne_game_up_check_last_time = time()
    wait_game_up()
  end

  local x0 = x
  confidence = confidence or default_findcolor_confidence

  if type(x) == 'string' and not x:find(coord_delimeter) then x = point[x] end
  if type(x) == "function" then return x() end
  if type(x) == "table" and #x == 0 then return findNode(x) end
  if type(x) == "table" and #x > 0 then return x end
  if type(x) == "string" then

    -- 控制截图频率
    local current = time()
    if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
      findOne_last_time = time()
      -- log(500)
      -- releaseCapture()
      keepCapture()
    end

    -- sleep(max(0, findOne_interval - (time() - findOne_last_time)))
    -- findOne_last_time = time()
    local pos
    -- log(x0, rfl[x0], x, confidence)
    if rfl[x0] then
      if cmpColorEx(x, confidence) == 1 then pos = first_point[x0] end
    else
      local px, py
      -- log(x0, rfg[x0], first_color[x0], x)
      px, py = findMultiColor(rfg[x0][1], rfg[x0][2], rfg[x0][3], rfg[x0][4],
                              first_color[x0], x, 0, confidence)
      if px ~= -1 then pos = {px, py} end
    end
    return pos
  end
end

findAny = function(x) return appear(x, 0, 0) end

findOnes = function(x, confidence)
  confidence = confidence or default_findcolor_confidence
  log(rfg[x], first_color[x], point[x])
  return findMultiColorAll(rfg[x][1], rfg[x][2], rfg[x][3], rfg[x][4],
                           first_color[x], point[x], 0, confidence) or {}
end

-- x={2,3} "信用" func nil
tap_last_time = time()
tap = function(x, noretry, allow_outside_game)
  if not unsafe_tap and not allow_outside_game and not check_after_tap then
    wait_game_up()
  end

  local x0 = x
  if x == nil then return end
  if x == true then return true end
  if type(x) == "function" then return x() end
  if type(x) == "string" and not x:find(coord_delimeter) then
    x = point[x]
    if type(x) == "string" then
      local p = x:find(coord_delimeter)
      local q = x:find(coord_delimeter, p + 1)
      x = map(tonumber, {x:sub(1, p - 1), x:sub(p + 1, q - 1)})
    end
  end
  log("tap", x0, x)
  if type(x) ~= "table" then return end

  -- log(843, tap_interval)
  if tap_interval > 0 and tap_interval - (time() - tap_last_time) > 0 then
    return
    -- sleep(max(0, tap_interval - (time() - tap_last_time)))
  end

  tap_last_time = time()
  -- log(838,x)
  if #x > 0 then
    clickPoint(x[1], x[2])
  else
    clickNode(x)
  end
  collectgarbage("collect")

  -- collectgarbage('collect')
  local start_time = time()

  -- 后置检查
  if not unsafe_tap and not allow_outside_game and check_after_tap then
    wait_game_up()
  end

  -- 这个sleep的作用是两次gesture间隔太短被判定为长按/点击，游戏界面会无反应，
  -- 所以click后需要等一会儿
  -- 懒人无现象闪退，可能和点太快有关
  sleep(max(milesecond_after_click + start_time - time(), 0))

  -- 返回"面板"后易触发数据更新，导致操作失效
  if noretry then return end
  if type(x0) == 'string' and x0:startsWith('面板') then
    wait(function()
      if not findOne("面板") then return true end
      if findOne("阿米娅") then
        path.fallback.阿米娅()
        return true
      end
      log("retap", x0)
      tap(x0, true, allow_outside_game)
    end, 10)
  end
end

-- simple swip for 资源收集
swipq = function(direction)
  local finger = {
    point = {
      {screen.width // 2, screen.height // 2},
      {direction == 'right' and (screen.width - 1) or 0, screen.height // 2},
    },
    duration = 500,
  }
  gesture(finger)
  sleep(finger.duration + 50)
end

-- quick swip for fight
swipu = function(dis)
  log('swipu', dis)
  -- preprocess distance
  if type(dis) == "string" then dis = distance[dis] end
  if type(dis) ~= "table" then dis = {dis} end
  if not dis then return end

  -- flatten to one depth
  -- local max_once_dis = 1080
  -- local freey = scale(150)
  local freey = scale(150)
  local freex = scale(300)
  local max_once_dis = screen.width - scale(300) - freex

  for _, d in pairs(dis) do
    local sign = d > 0 and 1 or -1
    if math.abs(d) == swip_right_max then
      swipe(sign > 0 and "right" or "left")
    else
      -- 只实现了右移
      if sign > 0 then stop("swipu左移未实现") end

      local finger = {
        {
          point = {{freex, freey}, {freex, screen.height - 1}},
          start = 0,
          duration = 0,
        },
      }
      local start = 0
      local duration = 150
      local interval = 50
      local end_delay = 50
      local flipy = swipu_flipy or 0
      local flipx = swipu_flipx or 0
      d = math.abs(d)
      while d > 0 do
        if d > max_once_dis then
          table.insert(finger, {
            point = {
              {freex + max_once_dis, freey + flipx},
              {freex + max_once_dis, freey + flipy},
            },
            start = start,
            duration = duration,
          })
        else
          table.insert(finger, {
            point = {{freex + d, freey}, {freex + d + flipx, freey + flipy}},
            start = start,
            duration = duration,
          })
        end
        d = d - max_once_dis
        start = start + duration + interval
        -- log(finger[#finger])
      end
      local last_finger = finger[#finger]
      finger[1].duration = last_finger.start + last_finger.duration + end_delay
      log("finger", finger)
      gesture(finger)
      sleep(finger[1].duration + 50)
    end
  end
end

-- swip to end for fight
swipe = function(x)
  -- 作战中第一次右滑容易错位，先做一次
  if first_time_swipe then
    first_time_swipe = false
    -- swip("9-2")
  end

  -- tap({scale(300), scale(150)})
  log("swipe", x)
  if x == 'right' then
    gesture({
      {
        point = {{scale(300), scale(150)}, {1000000, scale(150)}},
        start = 0,
        duration = 250,
      },
    })
    sleep(150 + 50)
  elseif x == 'left' then
    gesture({
      {
        point = {{scale(300), scale(150)}, {scale(300), screen.height - 1}},
        start = 0,
        duration = 100,
      },
      {point = {{screen.width - scale(300), 150}}, start = 60, duration = 50},
    })
    sleep(100 + 50)
  end
end

-- 安卓8以下的滑动用双指
android_verison_code = tonumber(getSdkVersion())
if android_verison_code < 24 then
  toast("安卓版本7以下不可用")
  ssleep(3)
end
-- if android_verison_code < 26 then
--   is_device_swipe_too_fast = true
-- else
--   is_device_swipe_too_fast = false
-- end

-- 华为手机需要慢速滑动
-- is_device_need_slow_swipe = true

-- simple swip for chapter navigation
swipc = function()
  local x1, y1, x2, y2
  x1, y1 = math.round((500 - 1920 / 2) * minscale + screen.width / 2),
           screen.height // 2
  x2, y2 = math.round((1500 - 1920 / 2) * minscale + screen.width / 2),
           scale(100)
  local finger = {point = {{x1, y1}, {x2, y1}, {x2, y2}}, duration = 500}
  gesture(finger)
  sleep(finger.duration + 50)
end

-- swip for operator
swipo = function(left, nodelay)
  local duration
  local finger
  local delay
  if left then
    local x1 = scale(600)
    local x2 = scale(10000 / 720 * 1080)
    local y1 = scale(533)
    duration = 400
    finger = {{point = {{x1, y1}, {x2, y1}}, duration = duration}}
    delay = 750
  else
    local x = scale(600)
    local y = scale(533)
    -- local y2 = scale(900)
    local y2 = scale(900)
    local x2 = scale(1681)
    local y3 = scale(900)
    local slids = 50
    local slidd = 200
    local taps = slids + slidd + 150
    local tapd = 200
    local downd = taps + 100
    duration = downd
    finger = {
      {point = {{x, y}, {x, y2}}, start = 0, duration = downd},
      {point = {{x2, y}, {x2, y3}}, start = slids, duration = slidd},
      {point = {{x2, y}, {x2, y}}, start = taps, duration = tapd},
    }
    delay = 250
  end
  log(JsonEncode(finger))
  gesture(finger)
  sleep(duration + (nodelay and 0 or delay))
  return nodelay and delay or 0
end

-- swip for fight
swip = function(dis)
  if type(dis) == "string" then dis = distance[dis] end
  if type(dis) ~= "table" then dis = {dis} end
  if not dis then return end
  for i, d in pairs(dis) do
    if i ~= 1 then ssleep(0.1) end
    if math.abs(d) == swip_right_max then
      swipe(d == swip_right_max and "right" or "left")
    else
      swipu(d)
    end
  end
end

-- pass loading, give a standard view of 基建
zoom = function(retry)
  log("zoom", retry)
  retry = retry or 0
  if retry > 20 then -- 20*200 = 4000（毫秒）
    -- TODO: 提示到底影响了什么，是不能缩放，还是缩放结束找不到
    log("缩放结束未找到")
    return true
  end
  log(696, findOne("进驻总览"))
  if not findOne("进驻总览") then return path.跳转("基建") end
  if findOne("缩放结束") then
    log("缩放结束")
    return true
  end

  -- 网络加载时重置retry
  if findOne("正在提交反馈至神经") then retry = 0 end

  -- 2x2 pixel zoom
  local duration = 50
  local delay = 500
  local finger

  -- if debug then
  --   -- duration = 1000
  --   -- delay = 1000
  --   finger = {
  --     {point = {{5, 5}}, duration = duration},
  --     {point = {{0, 0}, {5, 5}}, duration = duration},
  --   }
  -- end

  -- 特殊兼容 华为云 miui13
  if retry % 2 == 0 then
    finger = {
      {point = {{5, 0}}, duration = duration},
      {point = {{0, 0}, {5, 0}}, duration = duration},
    }
  else
    finger = {
      {point = {{0, 0}}, duration = duration},
      {point = {{0, 5}, {0, 0}}, duration = duration},
    }
  end
  -- local w =screen.width//2
  --   local h=screen.height//2
  --     finger = {
  --       {point = {{w-5,h-5}}, duration = duration},
  --       {point = {{w+5,h+5}, {w-5,h-5}}, duration = duration},
  --     }
  gesture(finger)
  sleep(duration + 50)
  appear("缩放结束", 0.5)

  -- local start_time = time()
  -- if appear("缩放结束", (duration + 50) / 1000) then
  --   sleep(max(0, start_time + duration + 50 - time()))
  --   return true
  -- end
  return zoom(retry + 1)
end

auto_total_timeout_hook = function()

  -- 应对进关卡黑屏、启动游戏黑屏、卡死

  -- 新增界面卡住、回归任务

  local known = {"面板", "主页"}
  wait(function()
    if findAny(known) then return true end
    tap("主题曲已开放")
    ssleep(.5)
  end, 5)

  wait(function()
    back()
    ssleep(.5)
  end, 2)

  if findAny(known) then return true end

  -- 全屏点一遍
  for w = 150, screen.width - 50, 50 do
    if findAny(known) then return true end
    for h = 50, screen.height - 50, 50 do tap({w, h}) end
  end
end
-- 为什么auto要有两组状态： 第二组状态点唯一性不足，比如返回与邮件同时出现时，需要的是邮件。没有优先级。
auto = function(p, fallback, timeout, total_timeout, total_timeout_restart)
  if type(p) == "function" then return p() end
  if type(p) ~= "table" then return true end
  local start_time = time()
  while true do
    if total_timeout and time() - start_time > total_timeout * 1000 then
      if total_timeout_restart then
        -- should be a hook, by defualt restartapp

        auto_total_timeout_hook()
        stop("auto超时" .. total_timeout .. 's', 'cur')

      else
        return true
      end
    end
    -- local found = false
    local finish = false
    local check = function()
      for k, v in pairs(p) do
        -- log(663, k, v)
        -- print(type(k))
        if findOne(k) then

          -- log(664, k)
          log(k, "=>", v)
          -- effective_state = k
          -- found = true
          if tap(v) then finish = true end
          return true
        end
      end
    end
    timeout = timeout or 0
    local e = wait(check, timeout)
    if finish then return true end

    -- fallback自动机只做一次
    if not e and fallback then auto(path.fallback, nil, nil, 0) end
  end
end

parse_time = function(x)
  if not x then return os.time() end
  return os.time({
    year = tonumber(x:sub(1, 4)),
    month = tonumber(x:sub(5, 6)),
    day = tonumber(x:sub(7, 8)),
    hour = tonumber(x:sub(9, 10)),
    min = tonumber(x:sub(11, 12)),
  })
end

qqnotify_before_run = function()
  qqmessage = {}
  if qqnotify_quiet then
    table.extend(qqmessage, {devicenote, usernote})
  elseif account_idx ~= nil then
    table.extend(qqmessage, {
      devicenote and devicenote or getDevice(), "号" .. account_idx,
      server == 0 and "官服" or "B服", username, usernote,
    })
  else
    table.extend(qqmessage, {
      devicenote and devicenote or getDevice(),
      server == 0 and "官服" or "B服",
    })
  end
end

qqnotify_after_run = function(run_start_time)
  local qqmessage_bak = shallowCopy(qqmessage)
  if not qqnotify_noruntime and run_start_time then
    table.insert(qqmessage,
                 math.floor((time() - run_start_time) / 1000 / 60) .. "分钟")
  end
  if not qqnotify_nofight then
    table.insert(qqmessage, shrink_fight_config(fight_history))
  end
  path.跳转("首页")
  captureqqimagedeliver("INFO", "通知", table.join(qqmessage, ' '))
  qqmessage = qqmessage_bak
end

qqnotify_before_restart_package = function()
  table.insert(qqmessage, "即将重启脚本")
  if not qqnotify_nofight then
    table.insert(qqmessage, shrink_fight_config(fight_history))
  end
  captureqqimagedeliver("INFO", "战术重启", table.join(qqmessage, ' '))
end

-- run function / job / table of function and job
run = function(...)
  local arg = {...}
  if #arg == 1 then
    if type(arg[1]) == "function" then return arg[1]() end
    if type(arg[1]) == "table" then arg = arg[1] end
  end
  local run_start_time = time()
  qqnotify_before_run()
  update_state()
  save_run_state()
  wait_game_up()
  for _, v in ipairs(arg) do
    running = v
    if type(v) == 'function' then
      v()
    else
      auto(path[v], path.fallback)
    end
  end
  qqnotify_after_run(run_start_time)
end

half_hour_cron = function(x, h)
  local m = 30
  if type(x) == "table" then
    if #x == 3 then
      x, h, m = x[1], x[2], x[3]
    else
      x, h = x[1], x[2]
    end
  end
  return {callback = function() run(x) end, hour = h, minute = m}
end

findTap = function(target)
  if type(target) == 'string' or #target == 0 then target = {target} end
  for _, v in pairs(target) do
    -- log(574, v, type(v))
    local p = findOne(v)
    if p then
      --      log("findTap:", v, p)
      tap(p)
      return v
    end
  end
end

appearTap = function(target, timeout, interval)
  if type(target) == 'string' or #target == 0 then target = {target} end
  target = appear(target, timeout, interval)
  if target then
    -- log("apperTap: ", target)
    findTap(target)
    return true
  end
end
-- {x:2,y:3} => {2,3}
xy2arr = function(t) return {t.x, t.y} end

clamp = function(x, minimum, maximum)
  minimum = minimum or 0
  maximum = maximum or (screen.width - 1)
  return min(max(x, minimum), maximum)
end
clampw = clamp
clamph = function(x, minimum, maximum)
  return clampw(x, minimum or 0, maximum or (screen.height - 1))
end

-- resoluton invariant deploy
-- idx=1 => the left most operator
-- idx=total => the right most operator
-- x2,y2 => destination
-- d => direction
deploy2 = function(idx, total, x2, y2, d)
  local max_op_width = scale(178) --  in loose mode, each operator's width
  local x1
  if total * max_op_width > screen.width then
    -- tight
    max_op_width = screen.width // total
    x1 = idx * max_op_width - max_op_width // 2
  else
    -- loose
    x1 = screen.width - (total - idx) * max_op_width - max_op_width // 2
  end
  x2 = math.round((x2 - (1920 / 2)) * minscale) + (screen.width // 2)
  y2 = math.round((y2 - (1080 / 2)) * minscale) + (screen.height // 2)
  deploy(x1, x2, y2, d)
end

deploy = function(x1, x2, y2, d)
  local y1 = screen.height - scale(109)
  d = d or 2
  d = ({{0, -1}, {1, 0}, {0, 1}, {-1, 0}})[d]
  d = {d[1] * 500, d[2] * 500}
  local dragd = 500
  local dird = 200
  local delay = 150 -- 有人卡这儿？
  local x3 = x2 - scale(5)
  local x4 = x2 + scale(5)
  local y3 = y2 - scale(5)
  local y4 = y2 + scale(5)
  local finger = {
    {
      point = {
        {x1, y1}, {x2, y2}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2},
        {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2},
        {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4},
        {x3, y2}, {x4, y2}, {x2, y3}, {x2, y4}, {x3, y2}, {x4, y2}, {x2, y3},
        {x2, y4}, {x2, y2},
      },
      duration = dragd,
    }, {
      point = {{x2, y2}, {clamp(x2 + d[1]), clamp(y2 + d[2])}},
      duration = dird,
      start = dragd + delay,
    },
  }
  -- if 1 or zl_enable_tap_before_drag then
  --   tap({x1, y1})
  --   ssleep(.5)
  -- end
  gesture(finger)
  sleep(dragd + delay + dird + delay)
  log("deploy", finger)
end

-- todo: make a map ?
retreat = function(x1, y1, x2, y2)
  local t = .5
  x1 = math.round((x1 - (1920 / 2)) * minscale) + (screen.width // 2)
  y1 = math.round((y1 - (1080 / 2)) * minscale) + (screen.height // 2)
  x2 = math.round((x2 - (1920 / 2)) * minscale) + (screen.width // 2)
  y2 = math.round((y2 - (1080 / 2)) * minscale) + (screen.height // 2)
  tap({x1, y1})
  ssleep(t)
  tap({x2, y2})
  ssleep(t)

  -- touchDown(0, x1, y1)
  -- ssleep(t)
  -- touchUp(0, x1, y1)
  -- ssleep(t)
  -- touchDown(0, x2, y2)
  -- ssleep(t)
  -- touchUp(0, x2, y2)
end

-- wait until func success
wait = function(func, timeout, interval)
  timeout = timeout or 2
  interval = interval or 0
  -- log(timeout,interval)
  local start_time = time()
  local reset_wait_start_time = function()
    if not disappear("正在提交反馈至神经", network_timeout) then
      stop("网络连接超时" .. network_timeout .. "秒", 'cur')
    end
    start_time = time()
  end
  while true do
    local ans = func(reset_wait_start_time)
    -- log(584,ans)
    if ans then return ans end
    if (time() - start_time) > timeout * 1000 then break end
    ssleep(interval)
  end
end

-- wait until see node / point / list of node and point
appear = function(target, timeout, interval, disappear)
  log((disappear and "dis" or '') .. "appear", target)
  if not (type(target) == 'table' and #target > 0) then target = {target} end
  return wait(function()
    for _, v in pairs(target) do
      -- log(1291, type(v), #v, v, findNode(v))
      if disappear then
        if type(v) == "function" and not v() then
          return v
        elseif type(v) == "table" and #v == 0 and not findNode(v) then
          return v
        elseif type(v) == "string" and #v > 0 and not findOne(v) then
          return v
        end
      else
        if type(v) == "function" and v() then
          return v
        elseif type(v) == "table" and #v == 0 and findNode(v) then
          return v
        elseif type(v) == "string" and #v > 0 and findOne(v) then
          return v
        end
      end
    end
  end, timeout, interval)
end

disappear = function(target, timeout, interval)
  return appear(target, timeout, interval, true)
end

trySolveCapture = function()
  if not findOne("captcha") then return end
  solveCapture()
  -- 第二次重试
  if not disappear("captcha", 5) then solveCapture() end
  -- 手工给2分钟
  if not appear("realgame", 5) then
    local msg =
      "请在2分钟内手动滑动验证码，超时将暂时跳过该账号"
    toast(msg)
    captureqqimagedeliver("WARN", "触发图灵测试",
                          table.join(qqmessage, ' ') .. ' ' .. msg)
    if not appear("realgame", 120) then
      back()
      if not appear("realgame", 5) then closeapp(appid) end
      stop("验证码", 'next')
    end
  end
end

wait_game_up = function(retry)
  retry = retry or 0
  if disable_game_up_check then return end
  local prev = disable_game_up_check
  disable_game_up_check = true

  if findOne("game") then
    disable_game_up_check = prev
    -- 前台切到游戏后，需要延时再设悬浮按钮与oom_score_adj
    if retry > 0 then
      setTimer(setControlBar, 2000)
      setTimer(setControlBar, 5000)
      setTimer(oom_score_adj, 2000)
      setTimer(oom_score_adj, 5000)
    end
    return
  end

  if retry == 2 then
    login_times = (login_times or 0) - 1
    table.remove(login_time_history or {})
    closeapp(appid)
  end
  if retry >= 4 then stop("无法启动游戏", 'cur') end

  open(appid)
  screenon()
  request_game_permission()
  local p = appear({
    "game", "keyguard_indication", "keyguard_input", "captcha",
    "同意并继续",
  }, 5)
  if p == "同意并继续" then path.bilibili_login[p]() end
  trySolveCapture()
  checkScreenLock()
  log("wait_game_up next", retry)
  disable_game_up_check = prev
  return wait_game_up(retry + 1)
end

screenLockSwipUp = function()
  if not wait(function()
    local node = findOne("keyguard_indication")
    if not node then return true end
    local center = (node.bounds.t + node.bounds.b) // 2
    local width = getScreen().width
    gesture({point = {{width // 2, center}, {width // 2, 1}}, duration = 1000})
    sleep(1000 + 50)
  end, 5) then stop("解锁失败1004") end
end
screenLockGesture = function()
  local point = JsonDecode(unlock_gesture or "[]") or {}
  log("point", point)
  if findOne("keyguard_input") then
    if unlock_mode == 0 then
      gesture({point = point, duration = 3000})
      sleep(3000 + 50)
    else
      for _, p in pairs(point) do
        tap(p)
        ssleep(.5)
      end
    end
    if not disappear("keyguard_input") then stop("解锁失败1005") end
  end
end

-- 检查解锁界面
checkScreenLock = function()
  screenLockSwipUp()
  screenLockGesture()
end
checkScreenLock = disable_game_up_check_wrapper(checkScreenLock)

coming_hour = function(a, b, starttime)
  if a == nil then return b end
  if b == nil then return a end
  start = os.date("*t", starttime)

  atime = os.time({
    year = start.year,
    month = start.month,
    day = start.day,
    hour = tonumber(a),
  })
  if atime < starttime then atime = atime + 24 * 3600 end

  btime = os.time({
    year = start.year,
    month = start.month,
    day = start.day,
    hour = tonumber(b),
  })
  if btime < starttime then btime = btime + 24 * 3600 end

  if atime - starttime < btime - starttime then return a end
  return b
end

findtap_operator = function(operator)
  operator_notfound = table.value2key(operator)
  found = #operator
  swipo(true)
  tap("清空选择")
  -- swip 3 times only
  for i = 1, 3 do
    if found <= 0 then return end
    if i ~= 1 then swipo() end
    ssleep(1)
    -- 616,107
    local res = ocrp({
      rect = {scale(616), scale(107), screen.width - 1, screen.height - 1},
    })
    res = res or {}

    for _, node in pairs(res) do
      log(node.text)
      for pattern, _ in pairs(operator_notfound) do
        if string.find(node.text, pattern) then
          log('found', pattern)
          tap(node.text_box_position[1])
          operator_notfound[pattern] = nil
          found = found - 1
          if found == 0 then return end
          break
        end
      end
    end
  end
end

ocr_fast = function(x1, y1, x2, y2, timeout)
  timeout = timeout or 10
  local status, text, info
  wait(function()
    if status then return true end
    status, text, info = pcall(ocr, x1, y1, x2, y2)
  end, timeout)
  if not status then
    text = nil
    info = {}
  end
  return text, info
end

findtap_operator_fast = function(operator)
  operator_notfound = table.value2key(operator)
  found = #operator
  -- swip 3 times only
  for i = 1, 3 do
    if found <= 0 then return end
    if i ~= 1 then swipo() end

    -- TODO: wait for 节点精灵 fix bug
    -- we must ocr on small region if we want to use position
    local region = {
      {590, 487, 1059, 523}, {1033, 487, 1491, 523}, {1464, 487, 1919, 523},
      {590, 907, 1059, 943}, {1033, 907, 1491, 943}, {1464, 907, 1919, 943},
    }

    -- {0,0,0,0,"1059,457,#D2D1D1|1033,455,#FFFFFF|1464,443,#D1CACE|1491,446,#D6D5D5",95}

    -- local r = region[1]
    -- ocr_fast(scale(r[1]), scale(r[2]),
    --          scale(r[3]), scale(r[4]))
    for _, r in pairs(region) do
      local text, info
      text, info = ocr_fast(scale(r[1]), scale(r[2]), scale(r[3]), scale(r[4]))
      if text then
        log(text, info, r)
        for _, w in pairs(info.words) do
          if operator_notfound[w.word] then
            log('found', w.word)
            tap({scale(r[1]) + w.rect.left, scale(r[2]) + w.rect.top})
            operator_notfound[w.word] = nil
            found = found - 1
            if found == 0 then return end
          end
        end
        -- 补救节点精灵bug
        for w in string.gmatch(text, "([%z\1-\127\194-\244][\128-\191]*)") do
          if operator_notfound[w] then
            log('found in text but not in words', w)
            tap({
              math.round((r[3] - 100) * minscale),
              math.round((r[4] - 100) * minscale),
            })
            operator_notfound[w] = nil
            found = found - 1
            if found == 0 then return end
          end
        end
      end
    end
  end
end

-- findtap_operator_type = function(type)
--   swipo(true)
--   tap("清空选择")
--   ssleep(2)
--   log('type', type)
--   local 经验加速 = {
--     '#261500-50',
--     '[{"a":0.129,"d":1.622,"id":"1","r":529.0,"s":"34|5<fOm>&5~9zPN&5~amm]&5>Yg}@&5]8m]^&5X[L$H&5X[L$H&5X[L$X&5>xRmv&5<quBx&5>GERF&5>GERE&5X[L$Y&5X[Npu&5X[Npu&5Y6o!c&5>YhCE&5~a15*&5~9z^6&5~9z^6&2~zjVe"}]',
--     0.85,
--   }
--   local 赤金加速 = {
--     '#202020-50',
--     '[{"a":-0.044,"d":1.807,"id":"1","r":358.0,"s":"22|py&PS&PS&PS&H6!&18dN&18dN&18dM&18dM&2OY&2OY&2LC&2LC&2gre&4wSA&8{v2&8{v2&4wSs&aL6&ax~&ax~&lgc&k]*&k]*&lGs&H6!&H6!&H6!&18dM&H6Y"}]',
--     0.85,
--   }
--   if type == '经验站' then
--     type = 经验加速
--   elseif type == "赤金站" then
--     type = 赤金加速
--   end
--   -- swip 3 times only
--   for i = 1, 3 do
--     if i ~= 1 then swipo() end
--
--     local candidate = findShape(type)
--     if candidate then
--       log(11777, #candidate)
--       local p = {}
--       for j, c in pairs(candidate) do
--         -- 宽度不超过
--         if c['x'] < 1920 * minscale then
--           table.insert(p, 'candidates' .. j)
--           point['candidates' .. j] = {c['x'], c['y']}
--         end
--       end
--       if #p > 0 then
--         tapAll(p)
--         ssleep(.1)
--       end
--     end
--   end
--   swipo(true)
-- end

timeit = function(f)
  local start = time()
  f()
  log(time() - start)
end

tapAll = function(ks)
  log("tapAll", ks)
  if #ks == 0 then return end
  -- 0 还是漏第一个
  -- 试试100 还是会漏第一个，即使界面看上去已经是完全可用状态了
  local duration = 1
  if tapall_duration > 0 then duration = tapall_duration end

  local finger = {}
  for i, k in pairs(ks) do
    if type(k) == 'string' then k = point[k] end
    table.insert(finger, {point = {{k[1], k[2]}}, duration = duration})
  end
  log('tapall', finger)
  if enable_simultaneous_tap then
    gesture(finger)
    sleep(duration + 50)
  else
    for _, v in pairs(finger) do tap(v.point[1]) end
  end
end

-- event queue
Lock = {}
function Lock:new(o)
  o = o or {queue = {}, length = 0, id = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end
function Lock:remove(id)
  self.queue[id] = nil
  self.length = self.length - 1
end
function Lock:exist(id) return self.queue[id] end
function Lock:add()
  self.id = self.id + 1
  self.queue[self.id] = 1
  self.length = self.length + 1
  return self.id
end
lock = Lock:new()

captureqqimagedeliver = function(log_level, log_title, log_detail, important)
  local f = io.open(getWorkPath() .. '/.nomedia', 'w')
  f:close()
  local img = getWorkPath() .. "/tmp.jpg"
  local img_src = img

  if not qqnotify_bar then
    hideControlBar()
    ssleep(.5)
    snapShot(img)
    setControlBar()
  else
    snapShot(img)
  end

  info = log_title .. ' ' .. log_detail

  log_title = os.date('[%m-%d][%H:%M]') .. ' ' .. log_title

  if not qqnotify_notime then info = os.date('%m.%d %H:%M:%S') .. ' ' .. info end

  img = base64(img)
  info = tostring(info):trim():gsub("%s+", ' ')

  -- qq
  notifyqq(img, info, QQ)
  if important then notifyqq(img, info, QQ2) end

  local img_url
  if cloud.enabled() or type(pushplus_token) == 'string' and #pushplus_token > 5 then
    img_url = uploadImg(img_src)
  end

  -- pushplus
  notifypp(img_url, info, pushplus_token, pushplus_channel)

  -- cloud
  cloud.addLog(log_level, log_title, log_detail, img_url)

  -- local
  if qqnotify_save then
    local img_dst = '/sdcard/' .. package .. '/' .. path_name_escape(info) ..
                      '.jpg'
    exec("cp '" .. img_src .. "' '" .. img_dst .. "'")
  end
end

poweroff =
  function() if root_mode then exec("su root sh -c 'reboot -p'") end end

kill_game_last_time = {[oppid] = time(), [bppid] = time()}
closeapp = function(package)
  if not package then return end
  -- log("package",package)
  -- 记录app被杀时间
  kill_game_last_time[package] = time()
  -- log("closeapp", package)
  if not isAppInstalled(package) then return end
  if root_mode then
    exec("su root sh -c 'am force-stop " .. package .. "'")
  elseif false then
    local intent = {
      action = "android.settings.APPLICATION_DETAILS_SETTINGS",
      uri = "package:" .. package,
    }
    runIntent(intent)
    log(intent)
    local stop_node
    stop_node = appear({
      {text = "*停止*"}, {text = "*结束*"}, {text = "*STOP*"},
    }, 10)
    if not stop_node then return end
    stop_node = findNode(stop_node)
    if not stop_node or not stop_node.enabled then return back() end
    tap(stop_node)

    ok_node = nil
    ok_node = appear({{text = "*确*"}, {text = "*OK*"}}, 5)
    if not ok_node then return end
    ok_node = findNode(ok_node)
    if not ok_node or not ok_node.enabled then return back() end
    tap(ok_node)
    disappear(ok_node)
    back()
    disappear(stop_node)
  end
end
closeapp = disable_game_up_check_wrapper(closeapp)
restartapp = function(package)
  login_times = (login_times or 0) - 1
  table.remove(login_time_history or {})
  closeapp(package)
  wait_game_up()
end
screenoff = function()
  if root_mode then exec([[su root sh -c 'input keyevent 223']]) end
end
screenon = function()
  if root_mode then
    exec([[su root sh -c 'input keyevent 224']])
  else
    -- stop("无障碍亮屏未实现")
  end
end

multiply = function(prefix, times)
  times = times or 1
  local ans = {}
  for i = 1, times do table.insert(ans, prefix .. i) end
  return ans
end

parse_id_to_ui = function(prefix, length)
  local ans = ''
  for i = 1, length do ans = ans .. prefix .. i .. '|' end
  return ans:sub(1, #ans - 1)
end

parse_value_to_ui = function(all, select)
  local ans = ''
  for _, v in pairs(all) do
    if table.includes(select, v) then ans = ans .. '*' end
    ans = ans .. v .. '|'
  end
  return ans:sub(1, #ans - 1)
end

parse_from_ui = function(prefix, reference)
  local ans = {}
  for i = 1, #reference do
    -- log("prefix..i", prefix .. i, _G[prefix .. i])
    if _G[prefix .. i] then table.insert(ans, reference[i]) end
  end
  return ans
end

all_job = {
  "邮件收取", "轮次作战", "访问好友", "基建收获",
  "基建换班", "制造加速", "线索交流", "副手换人",
  "信用购买", "公开招募", "任务收集", "限时活动",
}

-- now_job = table.filter(all_job, function(x) return x ~= "副手换人" end)
now_job = table.filter(all_job, function(x) return true end)

make_account_ui = function(layout, prefix)
  layout = layout or "main"
  prefix = prefix or ''
  newRow(layout)
  addTextView(layout, "作战关卡")
  ui.addEditText(layout, prefix .. "fight_ui", [[jm hd ce ls pr ap]])

  newRow(layout)
  addTextView(layout, "作战吃药")
  ui.addEditText(layout, prefix .. 'max_drug_times', "0")
  addTextView(layout, "次，吃石头")
  ui.addEditText(layout, prefix .. 'max_stone_times', "0")
  addTextView(layout, "次")

  -- newRow(layout)
  -- addTextView(layout, "换班模式")
  -- ui.addRadioGroup(layout, prefix .. "prefer_speed", {"极速", "高产"}, 0,
  --                  -2, -2, true)

  -- ui.addRadioGroup(layout, prefix .. "shift_prefer_speed", {"极速", "高产"},
  --                  1, -2, -2, true)
  -- addTextView(layout, "心情阈值")
  -- ui.addEditText(layout, prefix .. 'shift_min_mood', "12")

  -- ui.setEnable(prefix .. "shift_prefer_speed", false)
  -- ui.setEnable(prefix .. "shift_min_mood", false)

  -- ui.addRadioGroup(layout, prefix .. "prefer_speed", {"极速", "高产"}, 0,
  --                  -2, -2, true)

  -- ui.addCheckBox(layout, prefix .. "dorm_shift", "宿", true)
  -- ui.addCheckBox(layout, prefix .. "manu_shift", "制", false)
  -- ui.addCheckBox(layout, prefix .. "trading_shift", "贸", false)
  -- ui.addCheckBox(layout, prefix .. "meet_shift", "会", false)
  -- ui.addCheckBox(layout, prefix .. "overview_shift", "总", true)

  -- ui.setEnable(prefix .. "meet_shift", false)

  newRow(layout)
  addTextView(layout, "信用多买")
  ui.addEditText(layout, prefix .. "high_priority_goods", "")
  addTextView(layout, "信用少买")
  ui.addEditText(layout, prefix .. "low_priority_goods", "")

  newRow(layout)
  addTextView(layout, "自动招募")
  ui.addCheckBox(layout, prefix .. "auto_recruit0", "其他", true)
  ui.addCheckBox(layout, prefix .. "auto_recruit1", "车", true)
  ui.addCheckBox(layout, prefix .. "auto_recruit4", "4", true)
  ui.addCheckBox(layout, prefix .. "auto_recruit5", "5", true)
  ui.addCheckBox(layout, prefix .. "auto_recruit6", "6", true)

  -- local max_checkbox_one_row = getScreen().width //200
  local max_checkbox_one_row = 3
  for k, v in pairs(all_job) do
    if k % max_checkbox_one_row == 1 then
      newRow(layout, prefix .. "now_job_row" .. k)

    end
    ui.addCheckBox(layout, prefix .. "now_job_ui" .. k, v,
                   table.includes(now_job, v))
  end
end

multi_account_num = 30
show_multi_account_ui = function()
  local num = multi_account_num
  toast("正在加载多账号设置...")
  local layout = "multi_account"
  saveConfig('last_layout', layout)

  ui.newLayout(layout, ui_page_width, -2)

  make_ui_title(layout, "多账号")

  newRow(layout)
  -- ui.addButton(layout, layout .. "_start", "返回", ui_submit_width)
  -- ui.setBackground(layout .. "_start", ui_submit_color)
  -- ui.setOnClick(layout .. "_start", make_jump_ui_command(layout, "main"))

  addButton(layout, nil, "返回", make_jump_ui_command(layout, "main"), nil,
            nil)

  -- addButton(layout, nil, "启动", make_jump_ui_command(layout, nil,
  --                                                       "crontab_enable=false;lock:remove(main_ui_lock)"),
  -- ui_small_submit_width)
  addButton(layout, nil, "定时", make_jump_ui_command(layout, nil,
                                                        "crontab_enable_only=true;lock:remove(main_ui_lock)"),
            ui_small_submit_width)

  addButton(layout, nil, "启动并定时",
            make_jump_ui_command(layout, nil, "lock:remove(main_ui_lock)"),
            ui_small_submit_width, ui_small_submit_height, ui_submit_color)

  -- newRow(layout)
  -- addButton(layout, nil, "退出",
  --           make_jump_ui_command(layout, nil, "peaceExit()"))
  -- addButton(layout, nil, "必读", make_jump_ui_command(layout, nil,
  --                                                       "saveConfig('readme_already_read','1');jump_readme()"))
  -- addButton(layout, nil, "高级设置", make_jump_ui_command(layout, "debug"))
  -- make_continue_account_ui(layout)

  newRow(layout)
  addButton(layout, randomString(32), "导出帐密", make_jump_ui_command(
              layout, layout, "multi_account_config_export(1)"))
  addButton(layout, randomString(32), "导出全部", make_jump_ui_command(
              layout, layout, "multi_account_config_export()"))
  addButton(layout, randomString(32), "导入",
            make_jump_ui_command(layout, nil,
                                 "multi_account_config_import();show_multi_account_ui()"))

  newRow(layout)
  ui.addCheckBox(layout, layout .. '_enable', "启用账号", false)
  ui.addEditText(layout, layout .. "_choice", "1-" .. multi_account_num, -1)

  continue_account = loadConfig("continue_account", '')
  if #continue_account > 0 then
    continue_account = shrink_number_config(continue_account)
    continue_account_btn = randomString(32)
    addButton(layout, continue_account_btn, "继续账号" .. continue_account,
              "ui.setVisiblity(continue_account_btn,3);ui.setText('multi_account_choice', ui.getText('multi_account_choice') .. ' # '.. continue_account);saveConfig('continue_account','');")
  end

  newRow(layout)
  addTextView(layout, "切号前关闭")
  ui.addCheckBox(layout, "multi_account_end_closeotherapp", "其他服", true)
  ui.addCheckBox(layout, "multi_account_end_closeapp", "当前服", true)

  -- newRow(layout)
  -- addTextView(layout, "单号最大登录次数")
  -- ui.addEditText(layout, "max_login_times", "")

  -- newRow(layout)
  -- addTextView(layout,[[启用账号]])
  -- newRow(layout)
  -- addTextView(layout,
  --             [[“启用账号”填“1-10”表示跑前10个号，填“7 10-8 7 1-3”等价于“7 10 9 8 7 1 2 3”。临时账号写在#号后，填“1-10 # 5-10”表示跑前10个号，但本次启动只跑第5到第10个。账密为空跳过，高级设置中可调。抢登处理看必读。]])
  --
  newRow(layout)

  multi_account_all_inherit_choice = map(function(x)
    return "账号" .. tostring(x):padStart(2, '0')
  end, range(1, multi_account_num))

  for i = 1, num do
    local padi = tostring(i):padStart(2, '0')
    newRow(layout)
    addTextView(layout, "账号" .. padi)
    ui.addEditText(layout, "username" .. i, "", -1)
    addTextView(layout, "密码")
    ui.addEditText(layout, "password" .. i, "", -1)

    addButton(layout, nil, "#" .. i, make_jump_ui_command(layout, nil,
                                                          "multi_account_config_remove_once_choice('" ..
                                                            i ..
                                                            "');saveConfig('continue_account','');lock:remove(main_ui_lock)"),
              -2, nil, ui_submit_color)

    -- ui.addCheckBox(layout, "multi_account" .. i, "启用", true)
    newRow(layout)
    addTextView(layout, "账号" .. padi .. "在")
    -- addTextView(layout, "在")

    -- ui.addRadioGroup(layout, "server" .. i, {"官服", "B服"}, 0, -2, -2, true)

    ui.addSpinner(layout, "server" .. i, {"官服", "B服"}, 0)
    -- newRow(layout)
    -- addTextView(layout, "账号" .. padi .. "用")

    addTextView(layout, "用")
    addButton(layout, "multi_account_inherit_toggle" .. i,
              i == 1 and '单号设置' or "继承设置",
              "multi_account_inherit_toggle(" .. i .. ")")

    --
    -- addButton(layout, "multi_account_inherit_toggle" .. i, "单号设置",
    --           "multi_account_inherit_toggle(" .. i .. ")")

    -- addTextView(layout, "账号" .. padi .. "使用",multi_account_inherit)
    -- newRow(layout)
    ui.addSpinner(layout, "multi_account_inherit_spinner" .. i,
                  multi_account_all_inherit_choice, 0)

    -- addTextView(layout, "设置")
    -- addButton(layout, "multi_account_inherit_toggle" .. i,
    --           "切换为独立设置",
    --           "multi_account_inherit_toggle(" .. i .. ")")
    setNewRowGid("multi_account_user_row" .. i)
    make_account_ui(layout, "multi_account_user" .. i)
    setNewRowGid()
  end

  -- local all_inherit_choice = map(function(j)
  --   return "账号" .. tostring(j):padStart(2, '0')
  -- end, table.filter(range(1, num), function(k) return k ~= i end))
  -- all_inherit_choice = table.extend({"默认"}, all_inherit_choice)
  -- ui函数必须global
  multi_account_inherit_toggle = function(i)
    local btn = "multi_account_inherit_toggle" .. i

    local txt = ui.getText(btn)
    if txt == "单号设置" then
      ui.setText(btn, "继承设置")
    elseif txt == "继承设置" then
      ui.setText(btn, "独立设置")
    else
      ui.setText(btn, "单号设置")
    end
    multi_account_inherit_render(i)
  end

  -- ui函数必须global
  multi_account_inherit_render = function(start, stop)
    local layout = "multi_account"
    start = start or 1
    stop = stop or start
    for i = start, stop do
      local btn = "multi_account_inherit_toggle" .. i
      local gid = "multi_account_user_row" .. i
      local spinner = "multi_account_inherit_spinner" .. i

      local txt = ui.getText(btn)
      -- local txt = ui.getText(btn)
      -- if txt == "默认设置" then
      --   ui.setText(btn, "使用" .. txt)
      -- elseif txt == "独立设置" then
      --   ui.setText(btn, "使用" .. txt)
      -- end

      -- fallback
      if txt == "默认设置" then
        txt = "单号设置"
        ui.setText(btn, txt)
      end

      -- ui.setText(btn,"账号30设置")
      if txt == "单号设置" then
        ui.setVisiblity(spinner, 3)
        ui.setRowVisibleByGid(layout, gid, 8)
      elseif txt == "独立设置" then
        ui.setVisiblity(spinner, 3)
        ui.setRowVisibleByGid(layout, gid, 0)
      elseif txt == "继承设置" then
        ui.setRowVisibleByGid(layout, gid, 8)
        ui.setVisiblity(spinner, 1)
      end
    end
  end

  ui.saveProfile(getUIConfigPath(layout .. '_default'))
  ui.loadProfile(getUIConfigPath(layout))
  multi_account_inherit_render(1, num)

  -- if #continue_account > 0 then
  --   if equal_number_config(ui.getText('multi_account_choice') or '',
  --                          continue_account) then
  --     ui.setVisiblity(continue_account_btn, 3)
  --   end
  -- end

  ui.show(layout, false)
end

multi_account_config_export = function(simple)
  local layout = "multi_account"
  local content = loadOneUIConfig(layout)

  content = table.filterKV(content, function(k, v)
    if #k == 32 and not k:find('_') then return false end
    return true
  end)

  if simple then
    -- 提取账密
    local account = ''
    for i = 1, multi_account_num do
      local username = content['username' .. i]:trim():map({[' '] = ''})
      local password = content['password' .. i]:trim()
      local server = content['server' .. i]
      if type(username) == 'string' and #username > 0 and type(password) ==
        'string' and #password > 0 then
        account = account .. username .. ' ' .. password .. ' ' ..
                    (server == 1 and 'B服' or '官服') .. '\n'
      end
    end
    log(account)
    content = account
  else
    local default = loadOneUIConfig(layout .. "_default")
    content = JsonEncode(table.diff(content, default))
  end

  putClipboard(content)
  toast("多账号设置已复制" .. #content)

end

parse_simple_config = function(data)
  data = data or ''
  local layout = 'multi_account'
  local cur = loadOneUIConfig(layout)
  local i = multi_account_num
  while i > 0 do
    if type(cur["username" .. i]) == 'string' and #cur["username" .. i] > 0 or
      type(cur["password" .. i]) == 'string' and #cur["password" .. i] > 0 then
      break
    end
    i = i - 1
  end
  i = i + 1
  if i > multi_account_num then i = 1 end
  log('good index', i)
  local startidx = i

  -- log(2041, data)
  for _, v in pairs(data:split('\n')) do
    v = v:trim():split(' ')
    if #v >= 2 and not v[1]:startsWith('#') then
      local username = v[1]
      local password = v[2]
      local server = 0
      if type(v[3]) == 'string' and string.upper(v[3]:sub(1, 1)) == 'B' then
        server = 1
      end
      log(i, v)
      update(cur, {
        ['username' .. i] = username,
        ['password' .. i] = password,
        ['server' .. i] = server,
      }, true)
      i = i + 1
    end
  end
  local endidx = i - 1
  return JsonEncode(cur), startidx, endidx
end

multi_account_config_import = function()
  local data = getClipboard():trim()
  if not data or #data == 0 then stop('剪贴板无数据') end
  log("剪贴板数据：" .. data)
  local status, result
  status, result = pcall(JsonDecode, data)
  if not status and data:sub(1, 1) == '{' then
    stop("json格式错误(剪贴板数据不完整)")
  end
  if not status then data = parse_simple_config(data) end
  if not data or #data == 0 then stop("从剪贴板导入失败：" .. result) end
  local layout = "multi_account"
  saveOneUIConfig(layout, data)
end

multi_account_config_remove_once_choice = function(append)
  local layout = "multi_account"
  local cur = loadOneUIConfig(layout)
  local choice = cur[layout .. "_choice"] or ''
  choice = choice:commonmap()
  if choice:find('#') then choice = choice:sub(1, choice:find('#') - 1):trim() end
  if type(append) == "string" and #append > 0 then
    choice = choice .. '#' .. append
  end
  cur[layout .. "_choice"] = choice
  cur = JsonEncode(cur)
  saveOneUIConfig(layout, cur)
  -- log("choice", choice)
  return choice
end

transfer_global_variable = function(prefix, save_prefix)
  local stem
  -- 存在了几个月的BUG：遍历key的过程中修改key
  local G = {}
  for k, v in pairs(_G) do
    if k:startsWith(prefix) then
      stem = string.sub(k, #prefix + 1)
      if save_prefix and #save_prefix > 0 then
        G[save_prefix .. stem] = _G[stem] or false
      end
      G[stem] = v
    end
  end
  update(_G, G, true)
end

notifyqq = function(image, info, to, sync)
  image = image or ''
  info = info or ''
  to = to or ''

  if #to < 5 then return end

  local param = "image=" .. encodeUrl(image) .. "&info=" .. encodeUrl(info) ..
                  "&to=" .. encodeUrl(to)
  log('notify qq', info, to)

  local id = lock:add()
  asynHttpPost(function(res, code)
    -- log("notifyqq response", res, code)
    lock:remove(id)
  end, qqimagedeliver, param)
  if sync then wait(function() return not lock:exist(id) end, 30) end
end

notifypp = function(img, info, to, channel, sync)
  img = img or ''
  info = info or ''
  to = to or ''

  if #to < 5 then return end

  -- log("#image", #image)
  -- local ret, code
  -- ret, code = httpGet('https://api.uomg.com/api/image.baidu', "imgurl=" ..
  --                       'http://imgsrc.baidu.com/forum/pic/item/09f790529822720edafc8a9d76cb0a46f21faba3.jpg')
  -- log("notifypp response", ret, code)
  -- exit()
  -- end, 'http://www.pushplus.plus/send', param)
  --

  -- TODO 没图床
  -- log("#image", #image)
  -- local content = encodeUrl(
  --                   "![](data:image/jpeg;base64," .. image:sub(1, 17000) .. ")")
  -- log("#content", #content)
  -- if #content > 19900 then content = encodeUrl(to) end

  -- 不发图更好
  local param = "content=" .. encodeUrl("![](" .. img .. ")") .. "&title=" ..
                  encodeUrl(info) .. "&token=" .. encodeUrl(to) ..
                  "&template=markdown"
  if #strOr(channel) > 0 then param = param .. "&channel=" .. channel end
  log('notify pp', info, to)
  -- log("param", param)

  local id = lock:add()

  asynHttpPost(function(res, code)
    log("notifypp response", res, code)
    lock:remove(id)
  end, 'http://www.pushplus.plus/send', param)

  if sync then wait(function() return not lock:exist(id) end, 30) end
end

-- remove unneed elements while preserving cursor
clean_table = function(t, idx, bad)
  local ans = {}
  for k, v in pairs(t) do
    if not bad(v) then table.insert(ans, v) end
    if idx == k then idx = #ans end
  end
  return ans, idx
end

hotUpdate = function()
  toast("正在检查更新...")
  if disable_hotupdate then return end
  -- https://gitee.com/bilabila/arknights/raw/master
  -- local url = 'https://gitee.com/bilabila/arknights/raw/master/script.lr'
  local url = update_source .. '/script.lr'
  if beta_mode then url = url .. '.beta' end
  local md5url = url .. '.md5'
  local path = getWorkPath() .. '/newscript.lr'
  local md5path = path .. '.md5'
  if downloadFile(md5url, md5path) == -1 then
    toast("下载校验数据失败")
    ssleep(3)
    return
  end
  local f = io.open(md5path, 'r')
  local expectmd5 = f:read() or '1'
  f:close()
  if #expectmd5 ~= #'b966ddd58fd64b2f963a0c6b61b463ce' and update_source ~=
    update_source_fallback then
    log(2405)
    update_source = update_source_fallback
    return hotUpdate()
  end
  if expectmd5 == loadConfig("lr_md5", "2") then
    toast("已经是最新版")
    return
  end
  -- log(3, expectmd5, loadConfig("lr_md5", "2"))
  if downloadFile(url, path) == -1 then
    toast("下载最新脚本失败")
    ssleep(3)
    return
  end
  if fileMD5(path) ~= expectmd5 then
    toast("脚本校验失败")
    ssleep(3)
    return
  end
  installLrPkg(path)
  saveConfig("lr_md5", expectmd5)
  sleep(1000)
  -- log(5, expectmd5, loadConfig("lr_md5", "2"))
  log("已更新至最新")
  return restartScript()
end

styleButton = function(layout)
  ui.setBackground(layout, "#fff1f3f4")
  ui.setTextColor(layout, "#ff000000")
end

addButton = function(layout, id, text, func, w, h, bg)
  id = id or randomString(32)
  ui.addButton(layout, id, text, w or -2, h or -2)
  ui.setOnClick(id, func)
  if bg then ui.setBackground(id, bg) end
  -- styleButton(id)
end

setNewRowGid = function(gid) default_row_gid = gid end
newRow = function(layout, id, align, w, h)
  -- log(173,default_row_gid)
  id = id or randomString(32)
  ui.newRow(layout, id, w or -2, h or -2, default_row_gid)
  align = align or 'left'
  if align == 'center' then ui.setGravity(id, 17) end
end
addTextView = function(layout, text, id)
  ui.addTextView(layout, id or randomString(32), text)
end

make_jump_ui_command = function(cur, next, extra)
  -- log(getUIConfigPath(cur))
  local cmd = {
    -- 'log(ui.getData())',
    "ui.saveProfile('" .. getUIConfigPath(cur) .. "')",
    "ui.dismiss('" .. cur .. "');", next and "show_" .. next .. "_ui()" or '',
    extra or '',
  }
  return table.join(cmd, ';')
end

-- 快速启动
make_continue_account_ui = function(layout)
  continue_account = loadConfig("continue_account", '')
  continue_all_account = loadConfig("continue_all_account", '')
  if #continue_account > 0 and #continue_all_account > 0 then
    newRow(layout, nil, nil, -1)
    continue_account = shrink_number_config(continue_account)
    addButton(layout, nil, "启动并定时，本次只跑剩余账号 #" ..
                continue_account, make_jump_ui_command(layout, nil,
                                                       "multi_account_config_remove_once_choice(continue_account);saveConfig('continue_account','');lock:remove(main_ui_lock)"),
              -1, nil, ui_submit_color)
    newRow(layout, nil, nil, -1)
    continue_all_account = shrink_number_config(continue_all_account)
    addButton(layout, nil, "启动并定时，本次先跑剩余账号 #" ..
                continue_all_account, make_jump_ui_command(layout, nil,
                                                           "multi_account_config_remove_once_choice(continue_all_account);saveConfig('continue_account','');lock:remove(main_ui_lock)"),
              -1, nil, ui_submit_color)
  end
end

make_continue_extra_ui = function(layout)

  continue_extra_mode = loadConfig("continue_extra_mode", '')
  if #continue_extra_mode > 0 then
    newRow(layout, nil, nil, -1)
    addButton(layout, nil, "继续" .. continue_extra_mode,
              make_jump_ui_command(layout, nil,
                                   "extra_mode=continue_extra_mode;saveConfig('continue_extra_mode','');lock:remove(main_ui_lock)"),
              -1, nil, ui_submit_color)
  end
end

make_afterjob_ui = function(layout)
  newRow(layout)
  addTextView(layout, "完成之后")
  ui.addCheckBox(layout, "end_home", "返回桌面", true)
  ui.addCheckBox(layout, "end_closeapp", "关闭游戏", false)
  ui.addCheckBox(layout, "end_screenoff", "熄屏")

  newRow(layout)
  addTextView(layout, "定时启动")
  ui.addEditText(layout, "crontab_text", "4:00 12:00 20:00")
end
make_jump_ui = function(layout)

  local max_checkbox_one_row = 3
  local readme_btn = randomString(32)
  -- local jump_btn
  -- if layout == 'multi_account' then
  --   jump_btn = {nil, "单号", make_jump_ui_command(layout, 'main')}
  -- else
  -- jump_btn = {nil, "多号", make_jump_ui_command(layout, 'multi_account')}
  -- end

  local buttons = {
    {nil, "多号", make_jump_ui_command(layout, 'multi_account')},
    -- jump_btn, --
    {nil, "解锁", make_jump_ui_command(layout, 'gesture_capture')}, -- {
    --   layout .. "crontab", "定时执行",
    --   make_jump_ui_command(layout, 'crontab'),
    -- },
    -- {
    --   layout .. "github", "源码",
    --   make_jump_ui_command(layout, nil, "jump_github()"),
    -- },
    -- {
    --   layout .. "qqgroup", "反馈群",
    --   make_jump_ui_command(layout, nil, "jump_qqgroup()"),
    -- },
    {nil, "肉鸽/公招", make_jump_ui_command(layout, "extra")},
    -- {nil, "必读", make_jump_ui_command(layout, "help")},
    {nil, "退出", make_jump_ui_command(layout, nil, "peaceExit()")}, {
      readme_btn, "必读", make_jump_ui_command(layout, nil,
                                                 "saveConfig('readme_already_read','1');jump_readme()"),
    }, {nil, "高级设置", make_jump_ui_command(layout, "debug")},
    -- {
    --   layout .. "demo", "视频演示",
    --   make_jump_ui_command(layout, nil, "jump_bilibili()"),
    -- },
  }

  for k, v in pairs(buttons) do
    if k % max_checkbox_one_row == 1 then newRow(layout) end
    addButton(layout, v[1], v[2], v[3])
  end

  if #loadConfig("readme_already_read", '') == 0 then
    ui.setBackground(readme_btn, ui_submit_color)
  end

  newRow(layout)
  -- addButton(layout, layout .. "_stop", "退出",
  --           make_jump_ui_command(layout, nil, "peaceExit()"))
  -- ui.setBackground(layout .. "_stop", ui_cancel_color)

  addButton(layout, nil, "启动", make_jump_ui_command(layout, nil,
                                                        "crontab_enable=false;lock:remove(main_ui_lock)"),
            ui_small_submit_width)
  addButton(layout, nil, "定时", make_jump_ui_command(layout, nil,
                                                        "crontab_enable_only=true;lock:remove(main_ui_lock)"),
            ui_small_submit_width)
  addButton(layout, nil, "启动并定时",
            make_jump_ui_command(layout, nil, "lock:remove(main_ui_lock)"),
            ui_small_submit_width, ui_small_submit_height, ui_submit_color)
end

make_ui_title = function(layout, name)
  local screen = getScreen()
  local resolution = screen.width .. 'x' .. screen.height
  name = name or ''
  local title = name .. " " .. getApkVerInt() .. "-" ..
                  release_date:gsub(' ', '-') .. ' ' .. resolution
  ui.setTitleText(layout, is_apk_old() and apk_old_warning or title)
end

show_main_ui = function()
  local layout = "main"

  saveConfig('last_layout', layout)
  ui.newLayout(layout, ui_page_width, -2)

  make_ui_title(layout, "明日方舟速通")

  -- make_continue_account_ui(layout)
  -- make_continue_extra_ui(layout)

  if appid_need_user_select then
    newRow(layout)
    addTextView(layout, "服务器选")
    -- ui.addRadioGroup(layout, "server", {"官服", "B服"}, 0, -2, -2, true)

    ui.addSpinner(layout, "server", {"官服", "B服"}, 0)
  end

  make_account_ui(layout)

  make_afterjob_ui(layout)

  -- newRow(layout)
  -- addTextView(layout, "完成后通知QQ")
  -- ui.addEditText(layout, "QQ", "")

  -- addButton(layout, layout .. "jump_qq_btn", "加机器人好友",
  --           make_jump_ui_command(layout, nil, 'jump_qq()'))

  -- ui.addCheckBox(layout, "crontab_enable", "启用", true)
  -- newRow(layout)
  -- addTextView(layout, "点击间隔(毫秒)")
  -- ui.addEditText(layout, "click_interval", "")

  -- ui.addEditText(layout, "enable_log", "")

  -- 无法实现
  -- ui.addCheckBox(layout, "end_poweroff", "关机")

  -- newRow(layout)
  -- addTextView(layout,
  --             [[开基建退出提示，异形屏适配设为0。关游戏模式、全局侧边栏、深色夜间护眼模式、隐藏刘海。关懒人输入法，音量加停止脚本。有问题看必读。]])

  -- local max_checkbox_one_row = getScreen().width // 200
  make_jump_ui(layout)

  ui.loadProfile(getUIConfigPath(layout))
  -- log(getUIConfigPath(layout))
  -- 后处理
  if not root_mode then
    ui.setEnable("end_screenoff", false)
    ui.setEnable("end_poweroff", false)
    ui.setEnable("end_closeapp", false)
  end
  ui.show(layout, false)
end

show_help_ui = function()
  local layout = "help"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, "必读")
  newRow(layout)
  addTextView(layout, [[
源码与其他脚本：github.com/tkkcc/arknights
好用的话在上面github链接里登录后点下star
不star属于白嫖行为，开发者也没动力更新下去了
有问题加群反馈1009619697
国内主页：gitee.com/bilabila/arknights
商用要求：可卖脚本与服务，修改代码再卖需开源

最近更新：
1. 刷肉鸽等级(蜡烛)已加。
1. 第10章已加。
1. 新增root保活，雷电2核2G内存可无限挂肉鸽。需手动关闭root授权提示（设置-超级用户-右上角三个点-通知-无）。

]])

  newRow(layout)
  ui.addButton(layout, layout .. "_stop", "返回")
  ui.setBackground(layout .. "_stop", ui_cancel_color)
  ui.setOnClick(layout .. "_stop", make_jump_ui_command(layout, "main"))

  newRow(layout)
  addTextView(layout, [[
]])

  --   newRow(layout)
  --   addTextView(layout, [[
  -- ]])

  ui.show(layout, false)
end

show_help_ui = function()
  local layout = "help"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, "必读")
  newRow(layout)

  newRow(layout)
  ui.addButton(layout, layout .. "_stop", "返回")
  ui.setBackground(layout .. "_stop", ui_cancel_color)
  ui.setOnClick(layout .. "_stop", make_jump_ui_command(layout, "main"))
  newRow(layout)
  ui.addWebView(layout, randomString(32), 'https://arklights.pages.dev/guide',
                -2, 1000)
  ui.show(layout, false)
end

show_debug_ui = function()
  local layout = "debug"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, "高级设置")

  newRow(layout)

  addButton(layout, nil, "返回",
            make_jump_ui_command(layout, loadConfig("last_layout", "main")),
            nil, nil)
  -- ui.addButton(layout, layout .. "_stop", "返回")
  -- ui.setBackground(layout .. "_stop", ui_cancel_color)
  -- ui.setOnClick(layout .. "_stop",
  --               make_jump_ui_command(layout, ))

  newRow(layout)
  addTextView(layout, "图鉴用户名")
  ui.addEditText(layout, "captcha_username", "")

  newRow(layout)
  addTextView(layout, "图鉴密码")
  ui.addEditText(layout, "captcha_password", "")

  newRow(layout)
  addTextView(layout, "审判庭服务地址")
  ui.addEditText(layout, "cloud_server", "")

  newRow(layout)
  addTextView(layout, "审判庭设备标识")
  ui.addEditText(layout, "cloud_device_token", "")

  newRow(layout)
  ui.addCheckBox(layout, "cloud_get_task", "审判庭接受任务", false)

  newRow(layout)
  addTextView(layout, "单号最大登录次数")
  ui.addEditText(layout, "max_login_times", "")

  newRow(layout)
  addTextView(layout, "单号15分钟内最大登录次数")
  ui.addEditText(layout, "max_login_times_5min", "3")

  newRow(layout)
  addTextView(layout, "单关卡最大连续代理/导航失败次数")
  ui.addEditText(layout, "max_fight_failed_times", "2")

  newRow(layout)
  addTextView(layout, "单号最大成功剿灭次数")
  ui.addEditText(layout, "max_jmfight_times", "1")

  -- newRow(layout)
  -- addTextView(layout, "最大连续作战次数(达到重启游戏)")
  -- ui.addEditText(layout, "max_fight_times", "")

  -- newRow(layout)
  -- ui.addCheckBox(layout, "zl_enable_slow_drag", "前瞻投资长部署时间",
  --                false)
  -- newRow(layout)
  -- ui.addCheckBox(layout, "zl_enable_tap_before_drag",
  --                "前瞻投资部署前点一下", false)

  -- newRow(layout)
  -- ui.addCheckBox(layout, "zl_enable_log", "前瞻投资开启日志", false)

  -- newRow(layout)
  -- addTextView(layout, "多点点击时长(宿舍换班选不上人)")
  -- ui.addEditText(layout, "tapall_duration", "")
  -- ui.addCheckBox(layout, "tapall_usetap", "多点点击模式", false)

  --
  -- newRow(layout)
  -- ui.addCheckBox(layout, "disable_drug_24hour",
  --                "禁用自动吃24时到期理智药", false)
  --
  -- newRow(layout)
  -- ui.addCheckBox(layout, "disable_drug_48hour",
  --                "禁用自动吃48时到期理智药", false)

  for i = 1, 7 do
    newRow(layout)
    local timenote = i == 1 and "“X小时”" or "“" .. (i - 1) .. "天”"
    local default = i < 3 and '99' or '1'
    addTextView(layout, timenote .. "理智药最多吃")
    ui.addEditText(layout, "max_drug_times_" .. i .. "day", default)
    addTextView(layout, "次")
  end

  newRow(layout)
  ui.addCheckBox(layout, "zero_san_after_fight", "使用1-7清空剩余理智",
                 true)
  newRow(layout)
  ui.addCheckBox(layout, "restart_on_crontab_timeout",
                 "跨定时点结束后重启", true)

  newRow(layout)
  addTextView(layout, "QQ通知账号")
  ui.addEditText(layout, "QQ", "")

  newRow(layout)
  addTextView(layout, "QQ通知自建服务地址")
  ui.addEditText(layout, "qqimagedeliver", "")

  newRow(layout)
  addTextView(layout, "pushplus通知账号(token)")
  ui.addEditText(layout, "pushplus_token", "")

  newRow(layout)
  addTextView(layout, "pushplus通知渠道(channel)")
  ui.addEditText(layout, "pushplus_channel", "")

  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_save",
                 "QQ通知保存到/sdcard/包名/ (保留一周)", true)

  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_quiet",
                 "QQ通知设备名与账号名只显示备注", false)

  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_notime", "QQ通知不显示发送时间",
                 false)

  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_nofailedfight",
                 "QQ通知不显示代理失败信息", false)

  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_nofight", "QQ通知不显示作战信息",
                 false)
  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_noruntime", "QQ通知不显示耗时信息",
                 false)

  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_bar", "QQ通知显示悬浮按钮", false)

  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_beforemail",
                 "QQ通知显示邮件收取前情况", true)

  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_afterenter",
                 "QQ通知显示基建进入后情况", true)

  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_beforeleaving",
                 "QQ通知显示基建退出前情况", true)
  newRow(layout)
  ui.addCheckBox(layout, "qqnotify_beforemission",
                 "QQ通知显示任务收集前情况", true)

  newRow(layout)
  ui.addCheckBox(layout, "collect_beforeleaving",
                 "基建离开前加一次基建收获", true)

  newRow(layout)
  addTextView(layout, "基建换班心情阈值")
  ui.addEditText(layout, "shift_min_mood", '12')

  newRow(layout)
  ui.addCheckBox(layout, "shift_prefer_speed", "基建换班禁用高产换班",
                 false)

  newRow(layout)
  ui.addCheckBox(layout, "disable_dorm_shift", "基建换班禁用宿舍换班",
                 false)
  newRow(layout)
  ui.addCheckBox(layout, "disable_control_shift",
                 "基建换班禁用控制中枢换班", false)
  newRow(layout)
  ui.addCheckBox(layout, "disable_meeting_shift",
                 "基建换班禁用会客厅换班", false)
  newRow(layout)
  ui.addCheckBox(layout, "disable_office_shift",
                 "基建换班禁用办公室换班", false)
  newRow(layout)
  ui.addCheckBox(layout, "disable_manu_shift",
                 "基建换班禁用制造站换班", false)
  newRow(layout)
  ui.addCheckBox(layout, "disable_trading_shift",
                 "基建换班禁用贸易站换班", false)
  newRow(layout)
  ui.addCheckBox(layout, "disable_overview_shift",
                 "基建换班禁用总览换班", false)

  newRow(layout)
  ui.addCheckBox(layout, "disable_free_draw",
                 "限时活动禁用赠送寻访(每日单抽)", false)

  newRow(layout)
  ui.addCheckBox(layout, "zl_disable_lighter",
                 "前瞻投资禁用升级幕后筹备", false)
  newRow(layout)
  ui.addCheckBox(layout, "disable_strick_account_check",
                 "多账号允许不填帐密(双号双服玩家)", false)

  newRow(layout)
  addTextView(layout, "多账号双休日跳过账号")
  ui.addEditText(layout, "multi_account_choice_weekday_only", '')
  newRow(layout)
  addTextView(layout, "多账号仅传递线索账号(线索小号)")
  ui.addEditText(layout, "multi_account_disable_clue_unlock", '')

  -- newRow(layout)
  -- ui.addCheckBox(layout, "enable_keepalive",
  --                "保活模式(需关root通知与“X正在运行”通知)",
  --                false)

  -- newRow(layout)
  -- ui.addCheckBox(layout, "disable_shift_mood", "高产换班忽略心情", false)

  newRow(layout)
  addTextView(layout, [[


以下设置仅用于调试，如有修改后果自负！！！


]])

  -- newRow(layout)
  -- addTextView(layout, "前瞻投资重启游戏间隔(游戏有内存泄漏)")
  -- ui.addEditText(layout, "zl_restart_interval1", "3600")

  newRow(layout)
  addTextView(layout, "游戏重启间隔(s)")
  ui.addEditText(layout, "restart_game_interval", "900")

  newRow(layout)
  addTextView(layout, "完全重启间隔(s)")
  ui.addEditText(layout, "restart_package_interval", "3600")

  -- newRow(layout)
  -- ui.addCheckBox(layout, "enable_disable_lmk",
  --                "禁用LMK(测试中,专用挂机设备建议勾)", false)

  newRow(layout)
  ui.addCheckBox(layout, "disable_restart_package", "禁用完全重启", false)

  -- newRow(layout)
  -- ui.addCheckBox(layout, "disable_killacc1", "禁用重启acc进程", false)

  -- addTextView(layout, "禁用重启acc")
  -- ui.addEditText(layout, "disable_killacc", "")
  -- ui.addCheckBox(layout, "enable_killacc", "启用重启acc进程", false)

  newRow(layout)
  ui.addCheckBox(layout, "enable_log", "启用日志(会导致闪退)", false)

  -- newRow(layout)
  -- ui.addCheckBox(layout, "zl_enable_log", "前瞻投资开启日志", false)

  -- newRow(layout)
  -- ui.addCheckBox(layout, "enable_shift_log", "高产换班开启日志", false)

  -- newRow(layout)
  -- ui.addCheckBox(layout, "debug_disable_log", "禁用全部日志", false)

  newRow(layout)
  ui.addCheckBox(layout, "disable_oom_score_adj", "禁用oom_score_adj", false)

  newRow(layout)
  ui.addCheckBox(layout, "disable_hotupdate", "禁用自动更新", false)

  newRow(layout)
  ui.addCheckBox(layout, "beta_mode", "启用调试更新源", false)

  newRow(layout)
  ui.addCheckBox(layout, "debug_mode", "启用测试模式", false)

  newRow(layout)
  ui.addCheckBox(layout, "enable_native_tap", "启用原生点击方式", false)

  newRow(layout)
  ui.addCheckBox(layout, "enable_simultaneous_tap", "启用多点同步点击",
                 false)

  newRow(layout)
  addTextView(layout, "强制分辨率")
  ui.addEditText(layout, "force_width", [[]])
  addTextView(layout, "x")
  ui.addEditText(layout, "force_height", [[]])

  newRow(layout)
  addTextView(layout, "点击后等待(ms)")
  ui.addEditText(layout, "tap_wait", "")

  newRow(layout)
  addTextView(layout, "最小点击间隔(丢包模式)(ms)")
  ui.addEditText(layout, "tap_interval", "")

  newRow(layout)
  addTextView(layout, "最小截屏间隔(ms)")
  ui.addEditText(layout, "findOne_interval", "")

  newRow(layout)
  ui.addEditText(layout, "after_require_hook", "-- after_require_hook")
  newRow(layout)
  ui.addEditText(layout, "before_account_hook", "-- before_account_hook")
  newRow(layout)
  ui.addEditText(layout, "after_all_hook", "-- after_all_hook")

  ui.loadProfile(getUIConfigPath(layout))
  ui.show(layout, false)
end

show_extra_ui = function()
  local layout = "extra"
  saveConfig('last_layout', layout)

  ui.newLayout(layout, ui_page_width, -2)

  make_ui_title(layout, "其他功能")

  newRow(layout)

  addButton(layout, nil, "返回", make_jump_ui_command(layout, "main"), nil,
            nil)
  -- ui.addButton(layout, layout .. "_stop", "返回")
  -- ui.setBackground(layout .. "_stop", ui_cancel_color)
  -- ui.setOnClick(layout .. "_stop", make_jump_ui_command(layout, "main"))

  -- make_continue_extra_ui(layout)

  -- {nil, "退出", make_jump_ui_command(layout, nil, "peaceExit()")}, {
  --   readme_btn, "必读", make_jump_ui_command(layout, nil,
  --                                              "saveConfig('readme_already_read','1');jump_readme()"),
  -- }, {nil, "高级设置", make_jump_ui_command(layout, "debug")},

  newRow(layout)
  addTextView(layout, [[以下功能将沿用脚本主页设置]])

  newRow(layout)
  addButton(layout, nil, "战略前瞻投资", make_jump_ui_command(layout, nil,
                                                                    "extra_mode='战略前瞻投资';lock:remove(main_ui_lock)"))

  newRow(layout)
  addTextView(layout, [[选第]])
  ui.addEditText(layout, "zl_best_operator", [[-1]])
  addTextView(layout, [[个近卫 开]])
  ui.addEditText(layout, "zl_skill_times", [[0]])
  addTextView(layout, [[次]])
  ui.addEditText(layout, "zl_skill_idx", [[1]])
  addTextView(layout, [[技能]])

  newRow(layout)
  ui.addCheckBox(layout, "zl_more_repertoire", "多点剧目", false)
  ui.addCheckBox(layout, "zl_more_experience", "多点蜡烛", false)
  ui.addCheckBox(layout, "zl_skip_coin", "跳过投币", false)

  newRow(layout)
  ui.addCheckBox(layout, "zl_accept_mg", "可打敏感", false)
  ui.addCheckBox(layout, "zl_accept_yx", "可打臆想", false)
  ui.addCheckBox(layout, "zl_accept_sc", "可打生存", false)

  newRow(layout)
  ui.addCheckBox(layout, "zl_skip_hard", "不打驯兽", false)
  ui.addCheckBox(layout, "zl_no_waste", "每8小时做日常", false)

  -- ui.addSpinner(layout, "zl_hard_level", {"观光", "正式"}, 0)

  newRow(layout)
  addTextView(layout, [[需求商品]])
  ui.addEditText(layout, "zl_need_goods", [[]])
  addTextView(layout, [[等级]])
  ui.addEditText(layout, "zl_max_level", [[]])
  addTextView(layout, [[源石锭]])
  ui.addEditText(layout, "zl_max_coin", [[]])

  -- ui.addCheckBox(layout, "zl_disable_game_up_check", "禁用前台检查", false)
  -- newRow(layout)
  -- addTextView(layout, [[重启间隔(秒)]])
  -- ui.addEditText(layout, "zl_restart_interval", [[]])

  -- newRow(layout)
  -- addTextView(layout,
  --             [[用于刷源石锭投资、等级(蜡烛)、藏品、剧目等。应选择常见5、6星近卫，临光1、煌2、山2、羽毛笔1、帕拉斯1、赫拉格2、史尔特尔2、银灰1、幽灵鲨1、拉狗2，更多干员测试见群精华消息。]] ..
  --   [[刷源石锭应选“观光难度”，不勾“多点蜡烛”、“跳过投币”]]
  --               [[支持凌晨4点数据更新、支持掉线抢登情况、支持每8小时做日常。支持16:9及以上分辨率，但建议16:9，否则可能选不到后勤队。]] ..
  --               [[游戏本体存在内存泄漏，因此会抽空重启。如果1小时内就出现脚本停止运行、随机界面卡住、悬浮按钮消失，应把“高级设置”中两个3600重启间隔调小(如900)。]] ..
  --               [[999源石锭刷取耗时与难度、幕后筹备无关，与是否通关三结局、网络延迟有关，双结局耗时10时14分(97个/时)，三结局耗时8时10分(122个/时)，低网络延迟+三结局耗时7时21分(135个/时)。]] ..
  --               [[如需刷等级(蜡烛)，应选普通难度，勾“多点蜡烛”与“跳过投币”。]] ..
  --               [[商品需求可填商品名称关键字，用空格隔开(如填“玩 金 骑士”)，则刷到其中任一商品就会停止并通知QQ]])
  --
  -- ui.(layout, layout .. "_invest", "集成战略前瞻性投资")
  -- ui.setOnClick(layout .. "_invest", make_jump_ui_command(layout, nil,
  --                                                         "extra_mode='前瞻投资';lock:remove(main_ui_lock)"))

  newRow(layout)
  addButton(layout, layout .. "_recruit", "公开招募加急",
            make_jump_ui_command(layout, nil,
                                 "extra_mode='公开招募加急';lock:remove(main_ui_lock)"))
  addTextView(layout, [[保留标签]])
  ui.addEditText(layout, layout .. "_recruit_important_tag", [[]])
  -- newRow(layout)
  -- addTextView(layout,
  --             [[用于刷黄绿票，或刷出指定标签。使用加急券在第一个公招位反复执行“公开招募”任务，沿用脚本主页的“自动招募”设置。“自动招募”只勾“其他”时，刷出保底标签就停；只勾“其他”、“4”时，刷出保底小车、保底5星、资深就停；其余同理。如果想刷到指定标签就停，则“保留标签”填期望标签（例如填“削弱 快速复活”）。]])

  -- newRow(layout)
  -- addButton(layout, layout .. "_hd2_shop", "遗尘漫步任务与商店",
  --           make_jump_ui_command(layout, nil,
  --                                "extra_mode='活动任务与商店';lock:remove(main_ui_lock)"))
  --
  -- addButton(layout, layout .. "_hd2_shop_multi",
  --           "遗尘漫步任务与商店多号",
  --           make_jump_ui_command(layout, nil,
  --                                "extra_mode='活动任务与商店';extra_mode_multi=true;lock:remove(main_ui_lock)"))

  -- newRow(layout)
  -- addButton(layout, layout .. "_hd3_shop", "吾导先路任务与商店",
  --           make_jump_ui_command(layout, nil,
  --                                "extra_mode='活动2任务与商店';lock:remove(main_ui_lock)"))
  --
  -- addButton(layout, layout .. "_hd3_shop_multi",
  --           "吾导先路任务与商店多号",
  --           make_jump_ui_command(layout, nil,
  --                                "extra_mode='活动2任务与商店';extra_mode_multi=true;lock:remove(main_ui_lock)"))

  -- newRow(layout)
  -- addButton(layout, layout .. "_speedrun", "每日任务速通（待修）",
  --           make_jump_ui_command(layout, nil,
  --                                "extra_mode='每日任务速通';lock:remove(main_ui_lock)"))

  -- ui.setOnClick(layout .. "_speedrun", )
  -- addButton(layout, layout .. "jump_qq_btn", "需加机器人好友",
  --           make_jump_ui_command(layout, nil, 'jump_qq()'))
  -- newRow(layout)
  -- ui.addButton(layout, layout .. "_speedrun", "每日任务速通（别用）")
  -- ui.setOnClick(layout .. "_speedrun", make_jump_ui_command(layout, nil,
  --                                                           "extra_mode='每日任务速通';lock:remove(main_ui_lock)"))
  --

  -- newRow(layout)
  -- ui.addButton(layout, layout .. "_1-12", "克洛丝单人1-12（没写）")
  -- ui.setOnClick(layout .. "_1-12", make_jump_ui_command(layout, nil,
  --                                                       "extra_mode='克洛丝单人1-12';lock:remove(main_ui_lock)"))

  ui.loadProfile(getUIConfigPath(layout))
  ui.show(layout, false)
end

jump_qqgroup = function()
  local qq = "1009619697"
  local key = "KlYYiyXj2VRJg1qNqRo3tExo959SrKhT"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3D" ..
      key,
  }
  runIntent(intent)
  putClipboard(qq)
  toast("群号已复制：" .. qq)
  peaceExit()
end
jump_qq = function()
  local qq = "605597237"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "mqqwpa://im/chat?chat_type=wpa&uin=" .. qq,
  }
  runIntent(intent)
  putClipboard(qq)
  toast("QQ号已复制：" .. qq)
  peaceExit()
end
jump_bilibili = function()
  local bv = "BV1DL411t7n2"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "https://bilibili.com/video/" .. bv,
  }
  runIntent(intent)
  peaceExit()
end
jump_github = function()
  local github = "tkkcc/arknights"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "https://github.com/" .. github,
  }
  runIntent(intent)
  peaceExit()
end
jump_readme = function()
  local prefix = "arklights"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "https://" .. prefix .. '.pages.dev/guide.html',
  }
  runIntent(intent)
  while true do ssleep(1) end
  peaceExit()
end

jump_multi_account_json = function()
  log(getUIConfigPath("multi_account"))
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "file://" .. getUIConfigPath("multi_account"),
  }
  runIntent(intent)
  peaceExit()
end
openLog = function()
  local log_file = "file://" .. getSdPath() .. '/' .. package .. '/log/log.txt'
  log_file = '/sdcard/Download/icon.png'
  log(log_file)
  if fileExist(log_file) then log(1) end
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "content://" .. log_file,
    -- type= 'image/*'
  }
  log(intent)
  runIntent(intent)
  log(1849)
  ssleep(3)
  peaceExit()
end
show_gesture_capture_ui = function()
  local layout = "gesture_capture"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, (root_mode and '亮屏解锁' or
                    " 当前无root权限，请借助其他亮屏解锁软件"))

  newRow(layout)

  addButton(layout, nil, "返回", make_jump_ui_command(layout, "main"))

  newRow(layout)
  addTextView(layout,
              [[录入解锁手势或密码，以便熄屏下自动解锁]])

  newRow(layout)
  addTextView(layout, "1. 点击")

  addButton(layout, nil, "开始录制", "gesture_capture()", nil, nil,
            ui_submit_color)
  -- ui.addButton(layout, layout .. "_start", "开始录制", ui_small_submit_width)
  -- ui.setBackground(layout .. "_start", ui_submit_color)
  -- ui.setOnClick(layout .. "_start", "")

  newRow(layout)
  addTextView(layout, "2. 观察到 熄屏+亮屏+上滑 后，手动解锁")
  newRow(layout)
  addTextView(layout, "3. 点击本界面任意文字区域")
  newRow(layout)
  addTextView(layout, "4. 选择锁屏类型")

  ui.addSpinner(layout, "unlock_mode", {"手势", "密码"}, 0)
  -- ui.addRadioGroup(layout, "unlock_mode", {"手势", "密码"}, 0, -2, -2, true)

  newRow(layout)
  addTextView(layout,
              [[5. 快速测试：启动脚本后，手动熄屏，5秒内应观察到亮屏解锁现象。]])
  newRow(layout)
  addTextView(layout, "当前手势：")
  ui.addTextView(layout, "unlock_gesture", JsonEncode({}))

  ui.loadProfile(getUIConfigPath(layout))
  ui.show(layout, false)
end

gesture_capture = function()
  tap_interval = -1
  findOne_interval = -1
  -- update_state_from_debugui()
  local finger = {}
  screenoff()
  ssleep(3)
  -- wait(function()
  --   log(findOne("gesture_capture_ui"))
  --   nodeLib.updateNode()
  --   if not findOne("gesture_capture_ui") then return true end
  -- end,5)

  -- disappear("gesture_capture_ui", 5)
  screenon()
  disappear("gesture_capture_ui", 1)

  local state
  if not wait(function()
    state = appear({
      "gesture_capture_ui", "keyguard_indication", "keyguard_input",
    }, 5)
    if not state then
      stop("未找到解锁界面")
    elseif state == "gesture_capture_ui" then
      ui.setText("unlock_gesture", JsonEncode({}))
      return true
    elseif state == "keyguard_indication" then
      screenLockSwipUp()
    elseif state == "keyguard_input" then
      return true
    end
  end, 30) then stop("手势录制2010") end

  if state == title then return end
  log(200)

  if not wait(function()
    local p = catchClick()
    if findOne("gesture_capture_ui") then return true end
    if p then
      table.insert(finger, {p.x, p.y})
      ui.setText("unlock_gesture", JsonEncode(finger))
    end
  end, 30) then stop("手势录制超时") end
end
gesture_capture = disable_game_up_check_wrapper(gesture_capture)

show_crontab_ui = function()
  local layout = "crontab"
  ui.newLayout(layout, ui_page_width, -2)
  ui.setTitleText(layout, "定时执行")
  newRow(layout)
  ui.addCheckBox(layout, layout .. "_option", "定时执行总开关", true)
  local max_checkbox_one_row = 4
  local default_hour = {8, 16, 24}
  for i = 1, 24 do
    if i % max_checkbox_one_row == 1 then
      newRow(layout, layout .. "_row" .. i)
    end
    ui.addCheckBox(layout, layout .. i, tostring(i):padStart(2, '0') .. "点",
                   table.includes(default_hour, i))
  end
  newRow(layout, layout .. "_stop_row")
  ui.addButton(layout, layout .. "_stop", "返回", ui_submit_width)
  ui.setBackground(layout .. "_stop", ui_submit_color)
  ui.setOnClick(layout .. "_stop", make_jump_ui_command(layout, "main"))

  ui.loadProfile(getUIConfigPath(layout))
  ui.show(layout, false)
end

assignGlobalVariable = function(t)
  for k, v in pairs(t) do
    -- if string.find(k, "dual") then log(k, v, type(v)) end
    -- if _G[k] then log("_G[k] exist", k, v) end
    _G[k] = v
  end
end

getUIConfigPath = function(layout)
  return getWorkPath() .. '/config_' .. layout .. '.json'
end

loadOneUIConfig = function(layout)
  local config = getUIConfigPath(layout)
  if not fileExist(config) then return {} end
  -- log("load", config)
  local f = io.open(config, 'r')
  local content = f:read() or '{}'
  f:close()
  local status
  status, content = pcall(JsonDecode, content)
  if status then return content or {} end
  return {}
end

saveOneUIConfig = function(layout, content)
  if type(content) == 'table' then content = JsonEncode(content) end

  local config = getUIConfigPath(layout)
  local f = io.open(config, 'w')
  f:write(content or '{}')
  f:close()
end

loadUIConfig = function(layouts)
  if not layouts then
    layouts = {"multi_account", "gesture_capture", "extra", "debug", "main"}
  end
  for _, layout in pairs(layouts) do
    assignGlobalVariable(loadOneUIConfig(layout))
  end
end

all_apps = getInstalledApk()
isAppInstalled = function(package) return table.includes(all_apps, package) end

randomString = function(length)
  length = length or 8
  local res = ""
  for i = 1, length do res = res .. string.char(math.random(97, 122)) end
  return res
end
gesture = function(fingers)
  if #fingers == 0 then fingers = {fingers} end
  local gesture = Gesture:new() -- 创建一个手势滑动对象
  for _, finger in pairs(fingers) do
    local path = Path:new()
    for _, point in pairs(finger.point) do path:addPoint(point[1], point[2]) end
    path:setDurTime(finger.duration or 1000)
    path:setStartTime(finger.start or 0)
    gesture:addPath(path)
  end
  gesture:dispatch()
end
compareColor = function(x, y, color, sim)
  -- color = color:sub(6,7)..color:sub(4,5)..color:sub(2,3)
  -- log(x,y,color,sim)
  -- exit()
  return cmpColor(x, y, color:sub(2), sim) == 1
end

scale = function(x, mode)
  if not mode or mode == 'min' then
    return math.round(x * minscale)
  elseif mode == 'max' then
    return math.round(x * maxscale)
  elseif type(mode) == 'number' then
    return math.round(x * mode)
  end
end

input = function(selector, text)
  if type(text) ~= 'string' then return end
  local node = findNodes(point[selector])
  if not node then return end
  for _, n in pairs(node) do nodeLib.setText(n, text) end
end
-- input = disable_game_up_check_wrapper(input)

enable_accessibility_service = function(after_killacc)

  if isAccessibilityServiceRun() then return end
  if root_mode then
    local service = package .. "/com.nx.assist.AssistService"
    local services = exec(
                       "su root sh -c 'settings get secure enabled_accessibility_services'")
    log("3363", services)
    services = table.filter(services:trim():split(':'),
                            function(x) return x ~= 'null' end)

    log("3365", services)
    local other_services = table.join(table.filter(services, function(x)
      return x ~= service
    end), ':')
    log("3366", other_services)
    local cmd = [[su root sh -c '
settings put secure enabled_accessibility_services ]] .. other_services ..
                  (#other_services > 0 and ':' or '') .. service .. [[;
settings put secure enabled_accessibility_services ]] ..
                  (#other_services > 0 and other_services or [['\'\'']]) .. [[;

settings put secure enabled_accessibility_services ]] .. other_services ..
                  (#other_services > 0 and ':' or '') .. service .. [[;

' 2>&1 ]]
    local out = exec(cmd)
    log(3386, cmd)
    log(3387, out)
    if not wait(function() return isAccessibilityServiceRun() end, 2) then
      stop("无障碍服务启动失败", 'cur')
    else
      return
    end
  end
  openPermissionSetting()
  toast("请开启无障碍权限")
  if not wait(function() return isAccessibilityServiceRun() end, 60) then
    toast("开启无障碍权限超时")
    restartPackage()
  end
  toast("已开启无障碍权限")
end

enable_snapshot_service = disable_game_up_check_wrapper(function()
  if isSnapshotServiceRun() then return end
  if skip_snapshot_service_check then return end

  if root_mode then
    log("enable snapshot permission by root")
    exec([[su root sh -c '
appops set ]] .. package .. [[ PROJECT_MEDIA allow
appops set ]] .. package .. [[ SYSTEM_ALERT_WINDOW allow
']])
  end

  -- log("3444", 3444)
  -- if apk502 then
  --   import('java.lang.*')
  --   import('android.content.Context')
  --   import('com.nx.assist.lua.LuaEngine')
  --   import('com.nx.assist.lua.IReqSnapshotServiceResult')
  --   local cbReqSnapshot = IReqSnapshotServiceResult {
  --     onResult = function(ret)
  --       print(ret) -- ret是true或者false true表示成功，false失败
  --     end,
  --   }
  --   LuaEngine.requestSnapshotService(cbReqSnapshot)
  -- end

  -- log(isSnapshotServiceRun())
  -- exit()

  -- if loadConfig("hideUIOnce", "false") ~= "false" then
  --   log(2237)
  --   log("定时模式启动，不敢弹录屏")
  --   return
  -- end

  -- if wait(function() return isSnapshotServiceRun() end) then return end

  -- _toast("请开启录屏权限")
  openPermissionSetting()
  if not wait(function()
    if isSnapshotServiceRun() then return true end
    local p
    p = findOne("snap")
    if p then clickNodeFalse(p) end
    p = findOne({text = '立即开始'})
    if p then clickNodeFalse(p) end
    ssleep(1)
  end, 60) then
    toast("开启录屏权限超时")
    restartPackage()
  end
end)

test_fight_hook = function()
  if not test_fight then return end
  -- log(2392)
  fight = {
    -- "11-1",
    -- "11-2",
    -- "11-3",
    -- "11-4",
    -- "11-5",
    -- "11-6",
    -- "11-7",
    -- "11-8",
    -- "11-9",
    -- "11-10",
    -- "11-11",
    -- "11-12",
    -- "11-13",
    -- "11-14",
    -- "11-15",
    -- "11-16",
    -- "11-17",
    -- "11-18",
    -- "11-19",
    -- "11-20",
    "HD-8", "HD-7", "HD-6", "HD-5", "HD-4", "HD-3", "HD-2", "HD-1",

    -- "10-9",
    -- "9-9",
    -- "10-3",
    -- "10-4",
    -- "10-5",
    -- "10-6",
    -- "10-7",
    -- "10-8",
    -- "10-9",
    -- "10-10",
    -- "10-11",
    -- "10-12",
    -- "10-14",
    -- "10-15",
    -- "10-16",
    -- "10-17",
    -- "9-2",

    -- "HD-1", "HD-2", "HD-3", "HD-4", "HD-5", "HD-6", "HD-7", "HD-8", "HD-9",
    -- "break",
    -- "1-7", "1-7", "CE-5", "LS-5",

    -- "9-2", "9-3", "9-4", "9-5", "9-6", "9-7", "9-9", "9-10", "9-11", "9-12",
    -- "9-13", "S9-1", "9-14", "9-15", "9-16", "9-17", "9-18", "9-19",

    -- "0-8", "1-7", "S2-7", "3-7", "S4-10", "S5-3", "6-9", "7-15", "R8-2",
    --
    -- "JT8-2", "R8-2", "M8-8",
    -- "CA-5", "CE-5", 'AP-5', 'SK-5', 'LS-5', "PR-D-2", "PR-C-2", "PR-B-2",
    -- "PR-A-2", "龙门外环", "龙门市区", -- "1-7", "1-12", "2-3", "2-4",
    -- "2-9", "S2-7", "3-7", "S4-10", "S5-3", "6-9", "7-6", "7-15", "S7-2",
    -- "JT8-2", "R8-2", "M8-8",
    -- "PR-A-2", "PR-B-1", "PR-B-2", "PR-C-1", "PR-C-2", "PR-D-1", "PR-D-2",
    -- "CE-1", "CE-2", "CE-3", "CE-4", "CE-5", "CA-1", "CA-2", "CA-3", "CA-4",
    -- "CA-5", "AP-1", "AP-2", "AP-3", "AP-4", "AP-5", "LS-1", "LS-2", "LS-3",
    -- "LS-4", "LS-5", "SK-1", "SK-2", "SK-3", "SK-4", "SK-5", "0-1", "0-2", "0-3",
    -- "0-8", "1-9", "2-9", "S3-7", "4-10", "5-9", "6-10", "7-14", "R8-2",
    -- "积水潮窟", "切尔诺伯格", "龙门外环", "龙门市区",
    -- "废弃矿区", "大骑士领郊外", "北原冰封废城", "PR-A-1", "0-4",
    -- "0-5", "0-6", "0-7", "0-8", "0-9", "0-10", "0-11", "1-1", "1-3", "1-4",
    -- "1-5", "1-6", "1-7", "
    -- 1-8", "1-9", "1-10", "1-11", "1-12", "2-1", "2-2",
    -- "2-3", "2-4", "2-5", "2-6", "2-7", "2-8", "2-9", "2-10", "S2-1", "S2-2",
    -- "S2-3", "S2-4", "S2-5", "S2-6", "S2-7", "S2-8", "S2-9", "S2-10", "S2-12",
    -- "3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "3-8", "S3-1", "S3-2",
    -- "S3-3", "S3-4", "S3-5", "S3-6", "S3-7", "4-1", "4-2", "4-3", "4-4", "4-5",
    -- "4-6", "4-7", "4-8", "4-9", "4-10", "S4-1", "S4-2", "S4-3", "S4-4", "S4-5",
    -- "S4-6", "S4-7", "S4-8", "S4-9", "S4-10", "5-1", "5-2", "S5-1", "S5-2",
    -- "5-3", "5-4", "5-5", "5-6", "S5-3", "S5-4", "5-7", "5-8", "5-9", "S5-5",
    -- "S5-6", "S5-7", "S5-8", "S5-9", "5-10", "6-1", "6-2", "6-3", "6-4", "6-5",
    -- "6-7", "6-8", "6-9", "6-10", "S6-1", "S6-2", "6-11", "6-12", "6-14", "6-15",
    -- "S6-3", "S6-4", "6-16", "7-2", "7-3", "7-4", "7-5", "7-6", "7-8", "7-9",
    -- "7-10", "7-11", "7-12", "7-13", "7-14", "7-15", "7-16", "S7-1", "S7-2",
    -- "7-17", "7-18", "R8-1", "R8-2", "R8-3", "R8-4", "R8-5", "R8-6", "R8-7",
    -- "R8-8", "R8-9", "R8-10", "R8-11", "JT8-2", "JT8-3", "M8-6", "M8-7", "M8-8",
  }
  fight = table.filter(fight, function(v) return point['作战列表' .. v] end)
  log("fight", fight)
  repeat_fight_mode = false
  run("轮次作战")
  exit()
end

predebug_hook = function()
  if not predebug then return end
  tap_interval = -1
  findOne_interval = -1
  zl_skill_times = 100
  -- log(shift_prefer_speed)
  -- exit()

  disable_game_up_check = 1
  max_login_times = 10000

  swipu_flipy = 0
  swipu_flipx = 0
  -- log(findOne("活动导航0"))
  -- log(ocr("fullscreen"))
  -- log(findOne("常规行动2"))
  swip("HD-1")
  -- tap({361, 14})
  exit()
  -- log(point["HD-8"])
  --

  local paths = {
    {
      point = {{screen.width // 2, scale(600)}, {screen.width // 2, scale(0)}},
      duration = 500,
    },
  }
  gesture(paths)
  ssleep(1.5)
  -- log(findOne("当前进度列表9"))
  -- log(findOne("当前进度列表10"))
  -- log(findOne("当前进度列表11"))
  -- log(point["当前进度列表12"])
  -- log(findOne("当前进度列表12"))
  -- log(findOne("活动导航2"))
  -- log(findOne("B服安全验证框"))
  exit()

  -- local col=1
  -- log(findOne("第一层不期而遇" .. col .. "入口列表1"))
  -- log(findOne("第一层不期而遇" .. col .. "入口列表2"))
  -- log(findOne("第一层不期而遇" .. col .. "入口列表3"))
  -- log(findOne("第一层不期而遇" .. col .. "入口列表4"))
  -- log(findOne("第一层不期而遇" .. col .. "入口列表5"))
  -- log("===")
  -- col=2
  -- log(findOne("第一层不期而遇" .. col .. "入口列表1"))
  -- log(findOne("第一层不期而遇" .. col .. "入口列表2"))
  -- log(findOne("第一层不期而遇" .. col .. "入口列表3"))
  -- log(findOne("第一层不期而遇" .. col .. "入口列表4"))
  -- log(findOne("第一层不期而遇" .. col .. "入口列表5"))
  -- log(findOne("不要了"))
  -- tap({495, 516})
  local buy = function()
    local p = appear(point["战略商品列表"], 1)
    p = findAny(point["战略商品列表"])
    if not p then return end
    if not wait(function()
      local x, y = point[p]:match("(%d+)" .. coord_delimeter .. "(%d+)")
      tap({tonumber(x) - scale(111), tonumber(y) - scale(100)})
      if disappear(p, 1) then return true end
    end) then return end

    disappear("诡意行商离开", 1)
    if not wait(function(reset_wait_start_time)
      tap("诡意行商确认投资")
      if findOne("诡意行商离开") then return true end
      if findOne("确认招募") then
        local start_time = time()
        if not wait(function(reset_wait_start_time2)
          if findOne("编队") then return true end
          if findOne("返回确认界面") then
            if time() - start_time < 2000 then
              tap("左取消")
            else
              tap("右确认")
            end
            disappear("返回确认界面")
            ssleep(.5)
          end
          if findOne("正在提交反馈至神经") then
            reset_wait_start_time()
            reset_wait_start_time2()
          end
          tap("近卫招募列表" .. 1)
          findTap("确认招募")
          tap("开包skip")
        end, 10) then return end
      end
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
    end, 10) then return end
    return true
  end
  ssleep(1)
  buy()
  ssleep(1)
  exit()

  -- yg3 = "ff303030"
  -- log(colorDiff(yg3, "ff003030"))
  -- local r = {399, 351, 501, 383}
  -- point.r = {892, 171, 924, 203}
  -- point.r = {468,358,492,378}
  -- point.r = {861,175,1003,204}
  --
  point.r = {891, 139, 989, 211}
  -- point.r = {389,320,507,495}

  -- local handle = createOcr("chi-sim")
  -- local text = ocrText(handle,468,358,492,378,"ffffff-0f0f0f")
  -- local text = ocrText(handle,468,358,492,378,"000000-0f0f0f")

  ocr("r")
  ocr("r")
  ocr("r")
  ocr("r")
  ocr("r")
  ocr("r")
  log("text", text)
  -- ocrText("r")

  -- path.跳过剧情()
  exit()
  -- while true do
  --   log(findOne("活动导航1"))
  -- end
  -- swip("HD-2")
  -- ssleep(1)
  -- exit()
  log(ocr("fullscreen"))
  -- log(findOne("资源下载确定"))
  -- log(findOne("下载资源确认"))
  exit()
  ssleep(2)
  -- log(appearTap("snap"))
  -- log(point["剿灭记录确认"])
  -- log(findOne("剿灭记录确认"))
  -- log(point.当前委托侧边栏)
  -- log(findOne("当前委托侧边栏"))
  -- log(time())
  -- log(type(time()))
  -- log(type(time()-time()))
  -- log(os.time())
  -- log(string.format('%q',true))
  -- log(string.format('%q',nil))
  -- while true do
  --   log(ocr("第一层作战"))
  -- ssleep(1)
  -- end
  -- log(string.format('%q',time()))
  -- log(string.format('%q',os.time()))
  -- log(findOne("主题曲已开放"))
  -- save_extra_mode(extra_mode,extra_mode_multi)
  -- log(findOne("game"))
  -- cloud_task = {}
  -- log(uploadImg(getWorkPath() .. '/tmp.jpg'))
  -- m.addLog()
  -- log(is_network_unstable() == true)
  -- restartScript()
  -- log(findOne("返回"))
  ssleep(1)

  exit()
  -- tap({1281,721})
  -- appid = bppid
  -- log(findOne("同意并继续"))
  -- log(findOne("bilibili_framelayout_only"))
  -- log(findOne("game"))
  -- p = findOne("同意并继续")
  -- clickNode(p)
  -- log(ocr("第一层作战"))
  -- deploy3(1, "死斗", 1)
  ssleep(1)

  -- killacc2()

  ssleep(10)
  exit()

  local zl_level_check = function()
    -- if not (str2int(zl_max_level, 0) > 0) then return end

    -- if not findOne("常规行动") then return end
    -- if not wait(function()
    --   if not findOne("常规行动") then return true end
    --   tap("战略等级入口")
    -- end) then return end
    -- ssleep(.5)

    local prex = -1
    local ans = wait(function()
      -- if not findOne("常规行动") then return 0 end
      -- local x = ocr("战略等级") or {}
      local r = point["战略等级"]
      r[3] = 1580
      log("r", r)
      -- r[3]=1084
      -- r[4]=85

      -- r = {983, 30, 1053, 58}
      -- r = {991, 28, 1087, 82}
      -- local x = ocrBinaryEx(r[1], r[2], 1280, r[4], "000000-feb525") or {}
      local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-feb525") or {}
      -- local x = ocrEx(r[1], r[2], r[3], r[4]) or {}
      log("4126", x)
      x = (x[1] or {}).text or ""
      x = number_ocr_correct(x)
      x = str2int(x:match("^(%d+).*"), -1)
      log("4127", x)
      -- if x >= 0 and x <= 140 and x == prex then return x end
      if x >= 0 and x <= 200 then return x end
      -- if x >= 0 then return x end
      prex = x
    end, 5)
    -- wait(function()
    --   tap("返回")
    --   if appear("常规行动") then return true end
    -- end, 5)
    return ans
  end
  while true do if zl_level_check() ~= 88 then break end end
  exit()

  log(findOne("面板"))
  exit()
  -- disable_log = 1
  -- home()
  while true do
    -- keepalive()
    -- open(appid)
    -- screenon()
    -- request_game_permission()
    -- local p = appear({
    --   "game", "keyguard_indication", "keyguard_input", "captcha",
    -- }, 10)
    -- break
  end
  exit()

  collectgarbage("collect")
  disable_log = true
  log(1)

  while true do
    -- local gesture = Gesture:new()
    clickPoint(0, 0)
    -- print(1)
    -- tap({0, 0})
    -- tap("战略等级")
    collectgarbage("collect")

    -- ocr("战略等级")
  end
  log(2)
  exit()

  -- log(getApkVerInt())
  -- log(1)
  -- log(exec("su root sh -c 'dumpsys package "..package .."|grep versionName'"))
  -- log(2)
  -- exit()
  -- log(shrink_fight_config({"1-7"}))
  -- log(shrink_fight_config({"1-7", "1-7"}))
  -- log(shrink_fight_config({"1-7", "1-7", "1-7"}))
  -- log(shrink_fight_config({"1-7", "1-7", "1-7", 'CE-6'}))
  -- log(shrink_fight_config({"1-7", "1-7", "1-7", 'CE-6', 'CE-6'}))
  -- log(shrink_fight_config({"1-7", "1-7", "1-7", 'CE-6', 'CE-6', '1-8'}))
  -- log(shrink_fight_config({"1-7", "1-7", "1-7", 'CE-6', '1-8', 'CE-6'}))
  -- log(shrink_fight_config({"1-7", "1-7", "1-7", '1-8', 'CE-6', 'CE-6'}))
  -- log(shrink_fight_config({"1-6", "1-7", "1-7", '1-8', 'CE-6', 'CE-6'}))
  -- ssleep(1)
  -- swip("HD-1")
  -- ssleep(1)
  -- exit()
  local operator = {}
  initPngdata()
  discover(operator, controlPngdata, 1)
  -- discover(operator, manufacturingPngdata, 1)

  log(operator)
  exit()
  local zl_coin_check = function()
    -- if not (str2int(zl_max_coin, 0) > 0) then return 0 end
    local prex = -1
    return wait(function()
      -- if not findOne("常规行动") then return 0 end
      -- local r = point["战略等级"]
      -- "148|516|282320,284|570|1C1C1C"
      -- "1171|9|121A1A,1237|63|181818"
      -- r = {1034, 39, 1130, 72}
      -- log(r)
      -- local id = createHUD()
      -- showHUD(id, "等", 20, "0xffffb525", "0xff000000", 0, r[3], r[2], 0, 0) -- 显示HUD内容
      -- ssleep(1)
      -- local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-feb525") or {}

      -- local r = point["战略等级"]
      -- r =  {1034, 39, 1153, 64}
      -- local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-feb525") or {}

      -- local x = ocrEx(r[1], r[2], 1111, 95) or {}
      --
      -- 右上角源石锭 可
      -- local x = ocrEx(1078,9,1234,57) or {}
      --
      -- 360
      -- local x = ocrEx(1093, 15, 1247, 63) or {}
      -- local x = ocrEx(1134,25,1238,51) or {}
      local x = ocrEx(477, 592, 571, 627, "0-01d3ae") or {}
      -- local x = ocrBinaryEx(1093, 15, 1247, 63,"000000-555555") or {}

      --  右上角等级 可
      -- local x = ocrEx(1104,17,1204,45) or {}
      -- local x = ocrEx(1101, 17, 1204, 47) or {}
      --
      -- local x = ocrEx( 975,30,1050,61) or {}
      -- local x = ocrEx( 157,128,454,235) or {}

      -- local id = createHUD()
      -- showHUD(id,"的",11,"0xffffffff","0x00000000",0,240,540,40,32)--显示HUD内容
      -- ssleep(1)

      --  主页
      -- local x = ocrEx(169,543,283,591) or {}
      -- local x = ocrEx(1018,9,1228,69) or {}

      -- local x = ocr("战略源石锭") or {}
      log(4195, x)
      x = (x[1] or {}).text or ""
      x = number_ocr_correct(x)
      x = str2int(x:match("^(%d+).*"), -1)
      log("4128", x)
      if x >= 0 and x == prex then return x end
      prex = x
    end, 5) or 0
  end

  local zl_level_check = function()
    local prex = -1
    return wait(function()
      -- if not findOne("常规行动") then return 0 end
      local r = point["战略等级"]
      -- local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-bc8522") or {}
      -- local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-fab025") or {}
      -- log(r)
      -- local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-fab020") or {}
      -- local x = ocrBinaryEx(r[1], r[2], 140, r[4], "000000-fab020") or {}
      -- local x = ocrBinaryEx(1040, 39, 1153, 65, "000000-fab020") or {}
      -- local x = ocrBinaryEx(1033, 39, 1153, 64, "000000-fab020") or {}
      --
      -- local x = ocrBinaryEx(1035, 39, 1105, 64, "000000-fab525") or {}
      -- local x = ocrBinaryEx(1035, 39, 1105, 64, "000000-feb525") or {}
      --
      -- good
      -- local x = ocrBinaryEx(1017, 39, 1280, 64, "000000-feb525") or {}
      -- good
      -- local x = ocrBinaryEx(1034, 39, 1131, 64, "000000-feb525") or {}
      -- local x = ocrBinaryEx(1034, 39, 1142, 64, "000000-feb525") or {}
      --
      -- local x = ocrBinaryEx(1034, 39, 1153, 64, "000000-feb525") or {}

      -- local x = ocrBinaryEx(1034, 39, 1175, 64, "000000-feb525") or {}
      -- local x = ocrBinaryEx(1034, 39, 1197, 64, "000000-feb525") or {}

      -- "1017|13|121212,1109|85|18130E"
      -- local x = ocrBinaryEx(1017, 39, 1109, 72, "000000-feb525",200) or {}
      -- local x = ocrBinaryEx( 915,3,1275,136, "000000-feb525") or {}
      -- x = map(function(x) return x.text end,x)
      -- local x = ocrEx(1035, 39, 1105, 64) or {}
      -- x = (x[1] or {}).text or ""
      -- x = number_ocr_correct(x)
      -- x = str2int(x:match("^(%d+).*"), -1)

      -- log("4127", x)
      -- if x ~= 121 then log(x) end
      -- if x >= 0 and x <= 140 and x == prex then return x end
      -- x = (x[1] or {}).text or ""
      -- x = number_ocr_correct(x)
      -- local x = ocr("公开招募标签框范围")
      local x = ocrEx(0, 0, 0, 0)
      log(x)
      prex = x
    end, 50) or 0
  end

  -- log(zl_level_check())
  log(zl_coin_check())
  -- tap("战略难度列表2")
  --
  -- tap("战略难度列表3")
  -- tap("战略难度列表2")
  ssleep(1)
  exit()

  -- log(findOne("开始行动"))

  -- while true do if not isAccessibilityServiceRun() then log(1) end end

  -- log(colorDiff('ffcfcfcf','fffcfcfc'))
  -- exit()
  -- ssleep(1)
  -- log(1, findOne("小蓝圈"))
  -- ssleep(1)

  -- exit()
  -- if findOne("训练室") then
  --   if not wait(function()
  --     tap("训练室")
  --     if disappear("") then return true end
  --   end, 5) then return end
  --
  --   tap("电流")
  -- end
  --
  --
  -- ssleep(1)
  -- tap("面板活动2")
  -- ssleep(1)
  -- exit()
  --
  -- x = "9O古像绪记"
  -- log(x:match("^(%d+).*"))
  -- exit()
  -- zl_max_level = '10000'
  -- local zl_level_check = function()
  --   if not (str2int(zl_max_level, 0) > 0) then return 0 end
  --   local prex = -1
  --   return wait(function()
  --     if not findOne("常规行动") then return 0 end
  --
  --     local r = point["战略等级"]
  --     -- local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-bc8522") or {}
  --     local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-bc8522") or {}
  --     log(x)
  --     x = (x[1] or {}).text or ""
  --     x = x:map({O = '0'})
  --     x = str2int(x:match("^(%d+).*"), -1)
  --     log("4127", x)
  --     -- 等级10以下的多等等
  --     if x >= 10 and x <= 140 and x == prex then return x end
  --     prex = x
  --   end, 5) or 0
  -- end
  -- zl_level_check()
  -- exit()

  point.r = {1028, 13, 1100, 73}
  point.r = {1049, 38, 1088, 62}
  point.r = {1034, 14, 1244, 116}
  while true do
    -- ssleep(1)
    -- local p = ocrBinaryEx(1010, 13, 1106, 73, "FFB525-755316",100)
    -- local p = ocrEx(1056, 575, 1251, 659)
    -- local p = ocrEx( 160,542,311,596)
    -- r = point.战略源石锭
    -- local p = ocrBinaryEx(161, 542, 270, 589, "000000-3a3a3a")
    local p = ocrBinaryEx(177, 548, 227, 569, "000000-3a3a3a")
    -- local p = ocrBinaryEx(1056, 575, 1251, 659,"FFFFFF-303030")
    -- local p = ocrBinaryEx(0,0,1280,720,"FFB525-755316")
    -- local p = ocrBinaryEx( 1014-200,0,1254,132,"FFB525-755316")
    -- local p = ocrBinaryEx( 1014-200,0,1254,132,"FFB525-755316")
    -- local p = ocrBinaryEx( 1014-200,39,1254,78,"000000-64461C")
    -- local p = ocrBinaryEx(1020, 39, 1254, 70, "000000-64461C")
    -- local p = ocrBinaryEx(1020, 39, 1254, 70, "000000-755120")

    -- local p = ocrBinaryEx(1020, 39, 1280 - 1, 70, "000000-755120")

    -- local p = ocrBinaryEx( 1014-200,0,1254,78,"FFFFFF-755316")
    log(type(p), p)
    -- log(map(function(x) return x.text end,p))
  end
  exit()
  path.前瞻投资(true)
  -- tap("幕后筹备升级右列表5")
  -- tap("幕后筹备升级列表9")
  -- path.
  ssleep(1)
  exit(0)

  -- unZip("/sdcard/skill.zip", "/sdcard/skill")
  -- unZip(getWorkPath() .. "/skill.zip", getWorkPath() .. "/skill")
  -- ssleep(1)
  exit()

  swip("HD-1")
  ssleep(1)
  -- log(findOne("开始行动"))
  -- log(findOne("代理指挥开"))
  log(findOne("全权委托确认"))
  log(findOne("源石恢复理智取消"))

  exit()

  log(2253)
  disable_game_up_check = false
  ssleep(1)
  -- tap({1258,22})
  -- log(findOne(""))
  -- log(point.开始行动1)
  -- tap("开始行动1")

  state = findAny({
    "开始行动红", "源石恢复理智取消", "药剂恢复理智取消",
    "单选确认框", "源石恢复理智不足", "当期委托侧边栏",
  })
  log(state)
  exit()

  log(findOne("开始行动活动"))
  ssleep(1)
  exit()
  swipu_flipy = 100
  log(findOne("开始行动活动"))
  exit()
  swip("HD-1")
  -- swip("10-17")
  --
  -- swipe("right")

  exit()
  log(expand_number_config(shrink_number_config("")))
  log(expand_number_config(shrink_number_config("1")))
  log(expand_number_config(shrink_number_config("9 8")))
  log(expand_number_config(shrink_number_config("9 7")))
  log(expand_number_config(shrink_number_config("1 2 4 5 9 8 7 6")))

  exit()

  nodeLib.setOnNodeEvent(function(e) print("event:" .. e) end)

  -- ssleep(1)
  -- log(findOne("活动公告返回"))
  -- log(findOne("线索传递界面"))
  ssleep(1000)
  -- path.跳转("")
  -- log(findOne("活动公告返回"))
  exit()
  while true do
    local p = findOne("技能ready")
    if p then log(p) end
  end
  exit()

  local f = function()
    local p = findOne("技能亮")
    log("p", p)
    exit()
    if p then
      tap({p[1], p[2] + scale(200)})
      -- appear("技能ready", 5)
      appear("生命值蓝", 3)
      ssleep(0.5)
      wait(function()
        tap("开技能")
        if not findOne("生命值蓝") then return true end
      end)
    end
  end
  f()

  exit()

  p = findAny(point.任务有列表)
  p = table.subtract(point.任务有列表, p)
  log(p)
  exit()

  tap({5, 0})
  tap({6, 6})
  ssleep(1)
  exit()

  path.跳转("好友")
  log(2254)
  if not wait(function()
    tap('好友列表')
    if findOne("好友列表") then return true end
  end, 10) then return end
  log(2255)
  if not wait(function()
    tap('访问基建')
    if findAny({"访问下位灰", "访问下位橘"}) then return true end
    -- if not findOne("好友列表") then return true end
  end, 10) then return end -- 无好友或网络超时10秒
  log(2256)
  if speedrun then
    disappear("正在提交反馈至神经", network_timeout)
    appear("主页", 5)
    return
  end
  disable_communication_check = 1
  if not wait(function()
    if not disable_communication_check and
      findOne("今日参与交流已达上限") then
      log("今日参与交流已达上限")
      disappear("正在提交反馈至神经", network_timeout)
      appear("主页", 5)
      communication_enough = true
      return true
    end
    if findOne("访问下位灰") then
      log("访问下位灰")
      return true
    end
    tap("访问下位橘")
  end, 60) then return end
  log(2257)
  exit()
  -- log(findOne("行动结束"))
  -- exit()
  log(findAny(point.战略商品列表))
  for i = 1, 16 do log(i, findOne("战略商品列表" .. i)) end
  -- for i = 9,16 do
  --   log(i,findOne("战略商品列表"..i))
  -- end
  exit()
  -- log(findOne("战略返回"))
  --
  -- tap("诡意行商确认投资")
  -- exit()

  local buy = function()
    for i = 1, 9 do
      local p = appear(point["战略商品列表"])
      if not p then return end
      if not wait(function()
        if not findOne(p) then return true end
        local x, y = point[p]:match("(%d+)" .. coord_delimeter .. "(%d+)")
        tap({tonumber(x), tonumber(y) - scale(100)})
      end, 2) then return end

      if not wait(function()
        tap("诡意行商确认投资")
        if findOne("诡意行商离开") then return true end

        if findOne("确认招募") then
          if not wait(function()
            if findOne("编队") then return true end
            if findOne("返回确认界面") then
              tap("左取消")
              disappear("返回确认界面")
              ssleep(.5)
            end
            tap("近卫招募列表" .. 1)
            findTap("确认招募")
            tap("开包skip")
          end, 10) then return restartapp(apppid) end

        end
      end, 10) then return end

    end
  end
  buy()

  -- ssleep(1)
  -- tap("主页列表首页")
  --
  --
  ssleep(1)
  log(point.开始行动)
  exit()
  hideControlBar()
  log(2)
  ssleep(10)
  exit()
  swipe('right')
  -- swipu('10-17')
  -- log(findOne("作战列表AP-0"))
  -- log(findOne("开始行动"))
  -- log(findOne("代理指挥开"))
  -- log(findOne("行动结束"))
  -- log(findOne("零星代理"))
  -- log(point.代理指挥开)
  -- log(findOne("代理指挥开"))
  -- log(findOne("代理指挥开"))
  -- for i = 1, 11 do if findOne("当前进度列表" .. i) then log(i) end end
  -- log("---")
  -- for i = 1, 11 do if findOne("按下当前进度列表" .. i) then log(i) end end
  -- chooseOperatorBeforeFight()
  -- log(findOne("作战列表SK-5"))
  -- tap("作战列表AP-5")
  -- log(findOne("代理指挥开"))

  sleep(1)
  exit()
  ssleep(1)
  -- killacc()
  -- log(2)
  exit()

  cur = {{text = '迷茫的盲目的木木的'}}
  for _, v in pairs(cur) do
    local txt = v.text
    log(txt)
    while #txt > 9 do
      table.insert(cur, {text = txt:sub(#txt - 8, #txt)})
      txt = txt:sub(1, #txt - 9)
    end
    v.text = txt
  end
  log(cur)
  exit()

  -- log(time())
  -- keepalive()
  -- log(time())
  -- log(findOne("凋零残响"))
  exit()

  local restart = function()
    log(in_fight_return)
    exit()
  end

  if findOne("偏执的") then
    local all = {
      "迷茫的", "盲目的", "暴怒的", "孤独的", "偏执的",
      "敏感的", "臆想的", "生存的", "谨慎的",
    }
    -- local accept = {"孤独的", "偏执的", "谨慎的"}
    local accept = {"孤独的", "偏执的", "谨慎的"}

    -- local danger_accept = {
    --   "敏感的", "臆想的", "生存的",
    -- }

    if zl_accept_mg then table.insert(accept, "敏感的") end
    if zl_accept_yx then table.insert(accept, "臆想的") end
    if zl_accept_sc then table.insert(accept, "生存的") end

    local cur = {}
    if not wait(function()
      cur = ocr("幻觉范围")
      for _, v in pairs(cur) do
        local txt = v.text
        while #txt > 9 do
          table.insert(cur, {text = txt:sub(#txt - 8, #txt)})
          txt = txt:sub(1, #txt - 9)
        end
        v.text = txt
      end
      if table.all(cur, function(x) return table.includes(all, x.text) end) then
        return true
      end
    end, 5) then
      in_fight_return = "幻觉重试：" ..
                          table.join(map(function(x) return x.text end, cur))
      return restart()
    end
    for _, c in pairs(cur) do
      if not table.includes(accept, c.text) then
        in_fight_return = "幻觉重试：" ..
                            table.join(map(function(x) return x.text end, cur))
        return restart()
      end

    end

  end
  exit()
  -- point.r= {615,18,706,44}

  for i = 1, 10 do if findOne("当前进度列表" .. i) then log(i) end end
  log("---")
  for i = 1, 10 do if findOne("按下当前进度列表" .. i) then log(i) end end
  -- chooseOperatorBeforeFight()

  exit()
  -- point.r = {1, 1, screen.width, screen.height}
  -- scale(504)
  -- -- log(ocr('r'))
  -- pngdata = {}
  -- operators = {}
  -- discoverInFight(operators, pngdata, 1)

  exit()

  -- local x = scale(1000)
  -- local y = scale(533)
  -- tap({x, y})
  -- ssleep(1)
  -- exit()
  -- swipo()
  -- -- multi_account_config_export()
  -- exit()
  swipo(true)
  for i = 1, 10 do swipo() end
  ssleep(1)
  exit()

  local first_time_see_zero_star
  local zero_star
  while true do
    -- tap("开始行动")
    if findOne("行动结束") and findOne("零星代理") then
      first_time_see_zero_star = first_time_see_zero_star or time()
      log(time() - first_time_see_zero_star)
    end
  end
  exit()

  -- multi_account_config_import()
  exit()
  swipu('HD-8')
  exit()
  -- ssleep(1)
  while true do
    log(3007)
    -- if findOne("captcha") then
    if findOne("信用不足") then
      -- if findOne("bilibili_framelayout_only") then
      -- if findOne("game") then
      log(3008)
      exit()
    end
  end
  -- ssleep(1)
  -- exit()

  -- disable_log = 1
  disable_game_up_check = 1
  tapall_duration = 0
  enable_simultaneous_tap = 1
  while true do
    point.r = {scale(1), 306, screen.width + 100, 335}
    log(#ocr('r'))
  end
  exit()

  log(findOne("活动商店支付"))
  exit()
  -- tap("收取信用有")
  tap("开包skip")
  ssleep(1)
  exit()
  local p, f, g

  exit()
  -- log(
  -- for i = 1, 1 do tapAll({{574, 130},{574, 131},{574, 132}}) end
  -- ssleep(1)
  -- point.r = {759, 124, 888, 214}
  -- point.r = {665,340,1241,370}
  -- point.r = {633,350,925,368}
  -- point.r = {593,350,1280,368}
  -- point.r = {661,349,954+1,419}
  -- point.r = {704,334,778,381}
  point.r = {704, 334, 1241, 381}
  -- point.r = {676, 333, 1241, 397}
  -- point.r = {659, 333, 1243, 381}
  -- point.r = {659, 233, 1243, 442}
  while true do
    log(ocr('r'))
    ssleep(1)
    -- log(ocr('理智药到期时间范围'))

  end
  -- log(ocr('理智药到期时间范围'))
  exit()

  log(expand_number_config("10-1,1-3, 5-10"))
  exit()
  appear("bilibili_change2")
  log(findOne('bilibili_framelayout_only'))
  exit()
  while true do
    if not findOne("bilibili_account_switch") then
      toast(2972)
      exit()
    end
  end
  exit()

  extra_map = {["："] = ":"}
  x = update({
    [";"] = " ",
    ['"'] = " ",
    ["'"] = " ",
    ["；"] = " ",
    [","] = " ",
    ["_"] = "-",
    ["－"] = "-",
    ["、"] = " ",
    ["，"] = " ",
    ["|"] = " ",
    ["@"] = " ",
    ["#"] = " ",
    ["\n"] = " ",
    ["\t"] = " ",
    ["！"] = " ",
    ["＠"] = " ",
    ["＃"] = " ",
    ["＄"] = " ",
    ["％"] = " ",
    ["＾"] = " ",
    ["＆"] = " ",
    ["＊"] = " ",
    ["（"] = " ",
    ["）"] = " ",
    ["￥"] = " ",
    ["…"] = " ",
    ["×"] = " ",
    ["—"] = " ",
    ["＋"] = " ",

    ["ｘ"] = " ",
  }, extra_map or {})
  log(x)
  log(x['：'])
  -- tap({1178,654})
  -- tap("确认蓝")
  ssleep(1)

  exit()

  tap("开始行动")
  log(point["返回确认界面"])
  log(findOne("返回确认界面"))
  exit()

  while true do
    if findOne("行动结束") and findOne("零星代理") then log(2) end
  end
  tap("账号登录返回")
  ssleep(1)
  exit()

  zl_need_goods = "1"
  local check_goods = function()
    if type(zl_need_goods) ~= 'string' or #zl_need_goods:trim() == 0 then
      return
    end
    local need_goods = zl_need_goods:filterSplit()
    local goods1 = table.join(map(function(x) return x.text end,
                                  ocr("战略第一行商品范围")))
    local goods2 = table.join(map(function(x) return x.text end,
                                  ocr("战略第二行商品范围")))
    local goods = table.join({goods1, goods2})
    if goods:includes(need_goods) then
      stop("肉鸽已遇到所需商品", '', true, true)
    end
    log("未找到商品", goods, need_goods)
  end
  check_goods()
  exit()
  -- log(findOne("确认蓝"))
  -- log(findOne("第一干员未选中"))
  log(findOne("干员未选中"))
  -- log(point.指挥分队)
  -- log(findOne("指挥分队"))
  exit()
  -- solveCapture()

  -- log(point["captcha"])
  -- log(findOne("captcha"))
  exit()

  local p = appear({"game", "keyguard_indication", "keyguard_input", "captcha"},
                   5)
  log(p)
  -- log(findOne("captcha2"))
  exit()
  path.基建信息获取()

  log(1217, tradingStationLevel, manufacturingStationLevel, powerStationLevel,
      dormitoryLevel)
  exit()
  log(point["制造站补货通知"])
  log(findOne("制造站补货通知"))
  -- log(findOne("赤金站"))
  -- log(findOnes("第一干员卡片"))
  -- tap("制造站进度")
  ssleep(1)
  exit()

  swipo(true)
  for i = 1, 10 do swipo() end
  ssleep(1)

  exit()
end

_exec = exec
check_root_mode = function()
  -- log(4040)
  if hy_exec("echo aaa"):trim() == 'aaa' then
    exec = hy_exec
    log('华云')
  end

  if not disable_root_mode and #exec("su root sh -c 'echo aaa'") > 1 then
    root_mode = true
    disableRootToast()
  end
  -- log(exec("sh -c 'echo aaa'"))
  -- log(exec("sh -c 'echo aaa'"))
  -- log(exec("su root sh -c 'echo aaa'"))
  -- log(exec("su -c 'echo aaa'"))
  -- log(exec("su -h"))
  -- log(exec("which su"))
  -- log(exec("echo $PATH"))
  -- log(exec("ls /system/xbin/su"))
  -- log(exec("/system/xbin/su -h"))
  -- log(exec("/system/xbin/su -h 2>&1"))
  -- log(exec("id"))
  log("root_mode", root_mode and 'true' or 'false')
end

parse_fight_config = function(fight_ui)
  local fight = string.filterSplit(fight_ui)
  fight = map(string.upper, fight)

  -- expand LS-5x999
  local expanded_fight = {}
  for _, v in pairs(fight) do
    local cur_fight, times = v:match('(.+)[xX*](%d+)')
    if not cur_fight then
      table.insert(expanded_fight, v)
    else
      for _ = 1, times do table.insert(expanded_fight, cur_fight) end
    end
  end
  fight = expanded_fight
  -- log("expanded_fight", expanded_fight)

  -- LMSQ => 龙门市区
  expand_fight = {}
  for k, v in pairs(fight) do
    if table.includes(table.keys(jianpin2name), v) then
      v = jianpin2name[v]
    elseif table.includes(table.keys(extrajianpin2name), v) then
      v = extrajianpin2name[v]
    end
    if table.find({'活动'}, startsWithX(v)) then
      local idx = v:gsub(".-(%d+)$", '%1')
      v = "HD-" .. (idx or '')
      -- log(2731, v, idx)
    end

    -- special fight expand
    if table.includes({'CE', 'LS', 'AP', 'SK', 'CA'}, v) then
      for i = 6, 1, -1 do
        for _ = 1, 99 do table.insert(expand_fight, v .. '-' .. i) end
      end
    elseif table.includes({'PR'}, v) then
      for _ = 1, 99 do
        table.extend(expand_fight, {"PR-B-2", "PR-A-2", "PR-C-2", "PR-D-2"})
      end
      for _ = 1, 99 do
        table.extend(expand_fight, {"PR-B-1", "PR-A-1", "PR-C-1", "PR-D-1"})
      end
    elseif table.includes({'PR1'}, v) then
      for _ = 1, 99 do
        table.extend(expand_fight, {"PR-B-1", "PR-A-1", "PR-C-1", "PR-D-1"})
      end
    elseif table.includes({'WT', 'JM'}, v) then
      for _ = 1, 99 do table.insert(expand_fight, '当期委托') end
      for _ = 1, 99 do table.insert(expand_fight, '长期委托1') end
      for _ = 1, 99 do table.insert(expand_fight, '长期委托2') end
      for _ = 1, 99 do table.insert(expand_fight, '长期委托3') end
    elseif table.includes({'HD'}, v) then
      for _, i in pairs({7, 6, 5}) do
        for _ = 1, 99 do table.insert(expand_fight, v .. '-' .. i) end
      end
    elseif table.includes({'HD1'}, v) then
      for i = 10, 1, -1 do table.insert(expand_fight, 'HD' .. '-' .. i) end
      table.insert(expand_fight, "BREAK")
    else
      table.insert(expand_fight, v)
    end
  end
  fight = expand_fight
  fight = table.filter(fight, function(v) return point['作战列表' .. v] end)
  return fight
end

update_state_from_ui = function()
  bilibili_captcha_times = 0

  disable_clue_unlock = account_idx and
                          table.includes(multi_account_disable_clue_unlock,
                                         account_idx)

  -- 总览换班就按工作状态了，保证高心情
  -- prefer_skill = true
  drug_times = 0
  max_drug_times = str2int(max_drug_times, 0)
  stone_times = 0
  max_stone_times = str2int(max_stone_times, 0)
  for i = 1, 7 do
    local k = 'drug_times_' .. i .. 'day'
    _G[k] = 0
  end

  appid = server == 0 and oppid or bppid
  job = parse_from_ui("now_job_ui", all_job)

  fight = parse_fight_config(fight_ui)
  -- log("fight", fight)

  -- 活动开放时间段
  hd_open_time_end = parse_time("202212290400")

  -- 资源关全天开放时间段
  all_open_time_start = parse_time("202211151600")
  all_open_time_end = parse_time("202211290400")
  update_open_time()

  -- 危机合约时间段，只为加速平时的信用交易所
  during_crisis_contract = false
  local crisis_contract_start = parse_time("202211151600")
  local crisis_contract_end = parse_time("202211290400")
  local current = parse_time()
  if crisis_contract_start < current and current < crisis_contract_end then
    during_crisis_contract = true
  end

  -- 用于自定义换班，已弃用
  startup_time = parse_time()
  facility2operator = {}
  facility2nexthour = {}

  for _, v in pairs(string.split(dorm, '\n')) do
    v = string.split(v)
    if #v > 3 then
      local facility = v[1]
      if #facility == 3 then facility = facility .. 1 end
      local hour = tonumber(v[2])
      local operator = table.slice(v, 3)
      local cur_hour = facility2nexthour[facility]
      if coming_hour(cur_hour, hour, startup_time) == hour then
        facility2operator[facility] = operator
        facility2nexthour[facility] = hour
      end
    end
  end
  -- log(facility2nexthour)
  -- log(facility2operator)
end

apply_multi_account_setting = function(i, visited)
  visited = visited or {}
  table.insert(visited, i)
  local txt = _G["multi_account_inherit_toggle" .. i]
  if txt == "继承设置" then
    local inherit = _G["multi_account_inherit_spinner" .. i]
    local j = math.floor(inherit) + 1
    if table.includes(visited, j) then
      transfer_global_variable("multi_account_user0")
    else
      apply_multi_account_setting(j, visited)
    end
  elseif txt == "单号设置" or txt == "默认设置" then
    transfer_global_variable("multi_account_user0")
  else
    transfer_global_variable("multi_account_user" .. i)
  end
end

crontab_next_time = function(text)
  local config = string.filterSplit(text)
  local candidate = {}
  if #config == 0 then return 0 end
  local current = os.time()
  for _, v in pairs(config) do
    local hour_second = v:split(':')
    local hour = math.round(tonumber(hour_second[1] or 0) or 0)
    local min = math.round(tonumber(hour_second[2] or 0) or 0)
    table.insert(candidate, os.time(
                   update(os.date("*t"), {hour = hour, min = min, sec = 0})))
    table.insert(candidate, os.time(
                   update(os.date("*t"), {hour = hour + 24, min = min, sec = 0})))
  end
  table.sort(candidate)
  -- log("candidate", candidate)
  -- log("#candidate", #candidate)
  local next_time = table.findv(candidate, function(x) return x > current end)
  return next_time or 0
end

check_crontab_on_start = function()
  if not crontab_enable then return end
  if #loadConfig("crontab_next_time_on_start", "") > 0 then return end
  local next_time = crontab_next_time(crontab_text)
  -- log(4748, "next_time", next_time)
  saveConfig("crontab_next_time_on_start", str(next_time))
end

-- 定时执行逻辑：如果到点但脚本还在run则跳过
check_crontab = function()
  if not crontab_enable then return end
  saveConfig("hideUIOnce", "true")
  saveConfig("restart_mode_hook", '')
  local next_time_on_start = loadConfig("crontab_next_time_on_start", "")
  saveConfig("crontab_next_time_on_start", '')
  local next_time = crontab_next_time(crontab_text)
  log(4749, "next_time", next_time, next_time_on_start)
  multi_account_choice_idx = nil

  local restart = function()
    wait_game_up()
    restartPackage()
  end
  -- 有+号直接重启
  if crontab_text:find("+") then
    toast("无等待重启")
    restart()
  end
  -- 跨定时点重启
  -- log("next_time_on_start", next_time_on_start)
  -- log("next_time", next_time)
  -- exit()
  if next_time == 0 then return end
  if restart_on_crontab_timeout and str2int(next_time_on_start, next_time) ~=
    next_time then
    toast("跨定时点重启")
    restart()
  end

  toast("下次执行时间：" .. os.date("%H:%M", next_time))
  while true do
    if os.time() >= next_time then break end
    ssleep(1)
    -- ssleep(clamp(next_time - os.time(), 0, 1000))
  end
  restart()
end

setEventCallback = function()

  setStopCallBack(function()
    disable_log = false
    log("结束")
    saveConfig("hideUIOnce", "false")
    saveConfig("restart_mode_hook", '')
    saveConfig("crontab_next_time_on_start", '')
    disableRootToast(true)
    console.show()
  end)

  setUserEventCallBack(function(type)
    disable_log = false
    log("重启", type)
    saveConfig("hideUIOnce", "false")
    saveConfig("restart_mode_hook", '')
    disableRootToast(true)
    restartScript()
  end)

end

consoleInit = function()
  console.clearLog()
  console.setPos(round(screen.height * 0.05), round(screen.height * 0.05),
                 round(screen.height * 0.9), round(screen.height * 0.9))
  local screen = getScreen()
  local resolution = screen.width .. 'x' .. screen.height
  local title = getApkVerInt() .. ' ' .. release_date .. '  ' .. resolution
  console.setTitle(is_apk_old() and apk_old_warning or title)
  console.show()
  console.dismiss()
end

detectServer = function()
  appid = oppid
  if prefer_bapp then appid = bppid end
  if prefer_bapp_on_android7 and android_verison_code < 30 then appid = bppid end
  local app_info = isAppInstalled(appid)
  local bpp_info = isAppInstalled(bppid)
  if not app_info and not bpp_info then
    toast("未安装明日方舟官服或B服")
    ssleep(3)
  end
  if bpp_info and not app_info then appid = bppid end
  if bpp_info and app_info then appid_need_user_select = true end
  server = appid == oppid and 0 or 1
end

showUI = function()
  if loadConfig("hideUIOnce", "false") ~= "false" then
    saveConfig("hideUIOnce", "false")
  else
    main_ui_lock = lock:add()
    local last_layout = loadConfig("last_layout", "main")
    _G["show_" .. last_layout .. "_ui"]()
    if not wait(function() return not lock:exist(main_ui_lock) end, math.huge) then
      peaceExit()
    end

  end
end

setControlBar = function()
  -- TODO: 用0,1时，会缩进去半个图标，圆角手机不好点
  -- local screen = getScreen()
  -- setControlBarPosNew(0, 1)
  setControlBarPosNew(0, 1)
end

hideControlBar = function() showControlBar(false) end

-- extra_mode_hook = function()
--
--   if extra_mode then
--     run(extra_mode)
--     exit()
--   end
-- end

ocr = function(r, max_height)
  -- releaseCapture()
  r = point[r]
  log("ocrinput", r, max_height)
  local d1 = scale(math.random(-1, 1))
  local d2 = scale(math.random(-1, 1))
  local d3 = scale(math.random(-1, 1))
  local d4 = scale(math.random(-1, 1))
  r = ocrEx(r[1] + d1, r[2] + d2, r[3] + d3, r[4] + d4) or {}
  if max_height then
    r = table.filter(r, function(x) return (x.b - x.t) <= max_height end)
  end
  log("ocroutput", r)
  return r
end

-- 集成战略
swipzl = function(mode)
  -- 两个200的时候逍遥有概率出先没点下一关情况，不知道是不是这个引起的。
  -- 加了一次滑动冗余，应该不会了，改回200
  local duration = 200
  local delay = 200 -- 后面直接ocr或点击了，给点时间吧
  local x1 = scale(300)
  local x2 = screen.width - scale(300)
  local y = scale(1080 // 2)
  local finger
  if mode == "card" then
    duration = 300
    x2 = scale(1516)
  end

  if mode == 'right' then
    finger = {
      {point = {{x1, y}, {screen.width - 1, y}}, start = 0, duration = duration},
      {
        point = {{x1, y}, {screen.width - 1, y}},
        start = duration + delay,
        duration = duration,
      },
    }
    duration = duration + delay + duration
    delay = 500
  else
    finger = {
      {point = {{x2, y}, {0, y}}, start = 0, duration = duration},
      {point = {{x2, y}, {0, y}}, start = duration + delay, duration = duration},
    }
    duration = duration + delay + duration
    delay = 500
  end
  log(28491, finger)
  gesture(finger)
  log(28501)
  sleep(duration + delay)
end

-- src: 从右数第几个干员
-- dst: 目标位置，格式{A-G}{1-10} 参考https://map.ark-nights.com/map/ro1_n_1_4
-- total: 当前有几个干员，不同干员数影响干员位置
deploy3 = function(src, dst, direction, total)
  total = total or 1
  local max_op_width = scale(178) --  in loose mode, each operator's width
  local x1
  if total * max_op_width > screen.width then
    -- tight
    max_op_width = screen.width // total
    x1 = src * max_op_width - max_op_width // 2
  else
    -- loose
    x1 = screen.width - (total - src) * max_op_width - max_op_width // 2
  end

  dst = point["部署位" .. dst]
  deploy(x1, dst[1], dst[2], direction)
end

always_request_appid = {}
request_game_permission = function()
  log(2943)
  if not root_mode then return end
  if always_request_appid[appid] then return end
  always_request_appid[appid] = 1
  local aapt = [[android.permission.ACCESS_WIFI_STATE
android.permission.READ_PHONE_STATE
android.permission.ACCESS_NETWORK_STATE
android.permission.INTERNET
android.permission.WRITE_EXTERNAL_STORAGE]]
  local cmd = ''
  for s in aapt:gmatch("[^\r\n]+") do
    cmd = cmd .. 'pm grant ' .. appid .. ' ' .. s .. ';'
  end
  log(cmd)
  exec("su root sh -c '" .. cmd .. "'")
  log(2944)
end

str2int = function(number, fallback)
  if type(number) == 'number' then return math.floor(number) end
  return math.floor(tonumber(string.trim(number)) or fallback)
end

-- string annotation to list
expand_number_config = function(x)
  local y = {}
  x = string.filterSplit(x)
  for _, v in pairs(x) do
    if v:find('-') then
      local s = str2int(v:sub(1, v:find('-') - 1), -1)
      local e = str2int(v:sub(v:find('-') + 1), -1)
      local d = e < s and -1 or 1
      if s > 0 and e > 0 then for i = s, e, d do table.insert(y, i) end end
    else
      table.insert(y, str2int(v, 0))
    end
  end
  return y
end

equal_number_config = function(a, b)
  a = expand_number_config(a)
  b = expand_number_config(b)
  return table.equal(a, b)
end

-- {1,2,3,6,9,8} => '1-3 6 9-8'
shrink_number_config = function(x)
  local ans = ''
  x = x:split(' ')
  for i, _ in pairs(x) do x[i] = str2int(x[i], -1) end
  local i = 1
  while i <= #x do
    local j = i + 1
    while j <= #x and x[j] - x[j - 1] == 1 do j = j + 1 end
    if j == i + 1 then
      while j <= #x and x[j] - x[j - 1] == -1 do j = j + 1 end
    end
    if j == i + 1 then
      ans = ans .. x[i] .. ' '
    else
      ans = ans .. x[i] .. '-' .. x[j - 1] .. ' '
    end
    i = j
  end
  return ans
end

-- {1-7 1-7 1-7 CE-6} => '1-7x3 CE-6'
shrink_fight_config = function(x)
  local ans = ''
  local i = 1

  while i <= #x do
    local j = i + 1
    while j <= #x and x[j] == x[j - 1] do j = j + 1 end
    if j == i + 1 then
      ans = ans .. x[i] .. ' '
    else
      ans = ans .. x[i] .. 'x' .. (j - i) .. ' '
    end
    i = j
  end

  return ans
end

restart_game_check_last_time = nil
restart_game_check = function(timeout)
  timeout = timeout or 3600
  log(3145, timeout)
  restart_game_check_last_time = restart_game_check_last_time or time()
  if (time() - restart_game_check_last_time) > timeout * 1000 then
    restart_game_check_last_time = time()
    restartapp(appid)
    return true
  end
end

captcha_solver = function() end

forever = function(f, ...) while true do f(...) end end

make_extra_mode_hook = function(mode, multi)
  if not mode then return '' end
  local hook = [[;
extra_mode=]] .. string.format('%q', str(mode)) .. [[;
extra_mode_multi=]] .. str(multi and true or false) .. [[;
zl_no_waste_last_time=]] .. str(zl_no_waste_last_time)
  return hook
end

make_drug_stone_times_hook = function()
  if not max_stone_times or not stone_times then return '' end
  local stone_remain_times = max_stone_times - stone_times
  local drug_remain_times = max_drug_times - drug_times
  local idx = account_idx
  local hook = ''
  if not idx then
    hook = [[;
max_stone_times=]] .. stone_remain_times .. [[;
max_drug_times=]] .. drug_remain_times .. [[;
]]
  else
    hook = [[;
multi_account_user]] .. idx .. [[max_stone_times=]] .. stone_remain_times .. [[;
multi_account_user]] .. idx .. [[max_drug_times=]] .. drug_remain_times .. [[;
]]
  end
  return hook
end

make_multi_account_choice_hook = function(skip_current)
  if not multi_account_choice_idx or not account_idx then return '' end
  local choice_idx = multi_account_choice_idx
  local choice = multi_account_choice
  -- 跳过当前账号
  if skip_current then
    while choice[choice_idx] == account_idx do choice_idx = choice_idx + 1 end
  end
  -- 截取后续账号
  choice = table.slice(choice, choice_idx)
  return ";multi_account_choice=" ..
           string.format('%q', table.join(choice, ' '))
end

-- restart_mode = function(mode, multi)
--   if not mode then return end
--   saveConfig("restart_mode_hook",
--              "extra_mode=[[" .. mode .. "]];extra_mode_multi=" ..
--                (multi and 'true' or 'false'))
--   saveConfig("hideUIOnce", "true")
--   -- TODO：这里把速通放到前台会不会有助于防止被杀（genymotion 安卓10）
--   -- 结果：没用
--   -- open(getPackageName())
--   -- toast("5秒前台，防止别杀")
--   -- ssleep(5)
--   restartScript()
-- end

save_run_state = function(skip_current)
  local hook_prefix = ";-- save_run_state_begin;"
  local hook_suffix = ";-- save_run_state_end;"
  local hook = ''

  hook = hook .. make_extra_mode_hook(extra_mode, extra_mode_multi)
  hook = hook .. make_drug_stone_times_hook()
  hook = hook .. make_multi_account_choice_hook(skip_current)

  hook = hook_prefix .. hook .. hook_suffix

  local pre_hook = loadConfig('restart_mode_hook', '')
  pre_hook = pre_hook:gsub(hook_prefix:quote() .. ".*" .. hook_suffix:quote(),
                           '')
  hook = pre_hook .. hook
  saveConfig("restart_mode_hook", hook)
  saveConfig("hideUIOnce", "true")
end

restart_account = function(skip_current)
  -- 单帐号等待
  if not account_idx and skip_current then
    toast("等待1小时")
    wait(function() ssleep(1) end, 3600)
  end
  save_run_state(skip_current)
  restartPackage()
end

restart_mode_hook = function()
  -- load(loadConfig("restart_mode_hook", ''))()
  -- saveConfig("restart_mode_hook", '')
  local f = loadConfig("restart_mode_hook", '')
  -- log("restart_mode_hook",f)
  saveConfig("restart_mode_hook", '')
  load(f)()
end

check_login_frequency = function()

  login_times = (login_times or 0) + 1

  if login_times > 1 then
    -- captureqqimagedeliver(table.join(qqmessage, ' ') .. ' ' .. "登录次数" ..
    --                         login_times ..
    --                         (is_network_unstable() and
    --                           ",闪断时间段等15分钟" or ''))
    if is_network_unstable() then
      toast("闪断时间段等15分钟")
      wait(function() ssleep(1) end, 900)
      login_times = login_times - 1
      return
    end
  end

  if login_times >= max_login_times then
    stop("登录次数达到" .. login_times, 'next')
  end

  table.insert(login_time_history, time())
  log("login_time_history", login_time_history)
  if max_login_times_5min > 0 and #login_time_history >= max_login_times_5min and
    login_time_history[#login_time_history] -
    login_time_history[#login_time_history - max_login_times_5min + 1] < 15 * 60 *
    1000 then
    stop("15分钟内登录次数达到" .. max_login_times_5min, 'next')
  end

end

keepalive = function()
  -- enable_log_wrapper(function() log("keepalive") end)()
  -- trim_game_memory()
  -- killacc()
  -- oom_score_adj()
  -- collectgarbage('collect')
  -- disable_lmk()
end

killacc = function()
  exit()
  -- collectgarbage("collect")
  if not root_mode then return end
  if disable_killacc1 then return end
  if apk502 then return end
  -- if enable_killacc2 then return killacc2() end
  --   if 1 then return 1 end
  --
  --   local service = package .. "/com.nx.assist.AssistService"
  --   local services = exec(
  --                      "su root sh -c 'settings get secure enabled_accessibility_services'")
  --   log("3363", services)
  --   services = table.filter(services:trim():split(':'),
  --                           function(x) return x ~= 'null' end)
  --
  --   log("3365", services)
  --   local other_services = table.join(table.filter(services, function(x)
  --     return x ~= service
  --   end), ':')
  --   log("3366", other_services)
  --   local cmd = [[su root sh -c '
  -- pid=$(pidof ]] .. package .. [[:acc)
  -- settings put global heads_up_notifications_enabled 0
  -- # 开
  -- settings put secure enabled_accessibility_services ]] .. other_services ..
  --                 (#other_services > 0 and ':' or '') .. service .. [[;
  -- # 关
  -- settings put secure enabled_accessibility_services ]] ..
  --                 (#other_services > 0 and other_services or [['\'\'']]) .. [[;
  -- kill $pid
  -- sleep 1
  -- # 开
  -- settings put secure enabled_accessibility_services ]] .. other_services ..
  --                 (#other_services > 0 and ':' or '') .. service .. [[;
  -- # 关
  -- settings put secure enabled_accessibility_services ]] ..
  --                 (#other_services > 0 and other_services or [['\'\'']]) .. [[;
  -- # 开
  -- settings put secure enabled_accessibility_services ]] .. other_services ..
  --                 (#other_services > 0 and ':' or '') .. service .. [[;
  -- ' 2>&1 ]]
  open(package)
  appear({package = package}, 5)
  ssleep(1)

  local cmd = [[nohup su root sh -c ' \
# settings put global heads_up_notifications_enabled 0
kill $(pidof ]] .. package .. [[:acc)
secs=2
endTime=$(( $(date +%s) + secs ))
while [ $(date +%s) -lt $endTime ]; do
  pidof ]] .. package .. [[:acc && continue
  break
done
secs=2
endTime=$(( $(date +%s) + secs ))
while [ $(date +%s) -lt $endTime ]; do
  pidof ]] .. package .. [[:acc && break
done
echo -1000 > /proc/$(pidof ]] .. package .. [[:acc)/oom_score_adj

' > /dev/null & ]]

  log(5031)
  exec(cmd)
  -- log(4661, isAccessibilityServiceRun())
  -- log(4662, exec(cmd), isAccessibilityServiceRun())
  wait(function() return not isAccessibilityServiceRun() end, 2)
  if not wait(function() return isAccessibilityServiceRun() end, 2) then
    enable_accessibility_service(true)
    -- stop("无障碍服务启动失败，可以勾选禁用重启acc", false)
  end
  log(5038)
  -- log(5038)
  -- ssleep(100)
  -- exit()
  -- enable_accessibility_service()
  -- log("cmd", cmd)
  -- if #exec(cmd):trim() == 0 then
  -- stop(
  --   "acc进程重启失败，华云必须按必读操作，其他请反馈。可在高级设置中暂时关闭，但会引入内存泄漏无法长时间运行。",
  --   false)
  -- end
  -- log(1)
  -- exit()

  -- home()
  -- tap({screen.width + 1, screen.width + 1}, true, true)
  ssleep(1)
  home()
  wait_game_up()

  -- exit()

  --   cmd = [[nohup su root sh -c ' \
  -- sleep 10
  -- settings put global heads_up_notifications_enabled 1
  -- ' > /dev/null & ]]
  --   exec(cmd)
end

restartPackage = function()
  -- log("restart_mode_hook", loadConfig("restart_mode_hook", ''))
  -- log("hideUIOnce", loadConfig("hideUIOnce", ''))
  if getApkVerInt() == 1 then
    disable_restart_package = true
    log("debug")
  end
  if not root_mode or disable_restart_package then return restartScript() end
  local cmd = [[nohup su root sh -c ' \
while :; do
am force-stop ]] .. oppid .. [[;
am force-stop ]] .. bppid .. [[;
am force-stop ]] .. package .. [=[;
sleep 1
input keyevent KEYCODE_HOME
sleep 1
secs=300
endTime=$(( $(date +%s) + secs ))
while [[ $(date +%s) -lt $endTime ]]; do
  monkey -p ]=] .. package .. [=[ -c android.intent.category.LAUNCHER 1
  foreground=$(dumpsys activity recents|sed -rn '\''s/.*Recent #0.*(com[^ ]+).*/\1/p'\'')
  if [[ $foreground == *com.bilabila* ]];then
     break
  fi
  sleep 5
done
secs=300
endTime=$(( $(date +%s) + secs ))
ok_found=0
while [[ $(date +%s) -lt $endTime ]]; do
  sleep 5
  foreground=$(dumpsys activity recents|sed -rn '\''s/.*Recent #0.*(com[^ ]+).*/\1/p'\'')

  if [[ ! $foreground == *com.bilabila* ]] && [[ $ok_found == 1 ]] ;then
     exit
  fi

  if [[ ! $foreground == *com.bilabila* ]];then
     continue
  fi

  uiautomator dump /sdcard/window_dump.xml

  cancel=$(sed -rn '\''s|.*text=.取消.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  ok=$(sed -rn '\''s|.*text=.确定.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  close=$(sed -rn '\''s|.*text=.关闭.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  if [[ -n $close ]]; then
    eval $close
  fi

  if [[ -n $cancel ]]; then
    eval $cancel
    continue
  elif [[ -n $ok ]]; then
    sleep 1
    eval $ok
    ok_found=1
    continue
  fi

  #start=$(sed -rn '\''s|.*text=.立即开始.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  #if [[ -n $start ]]; then
  #  eval $start
  #  continue
  #fi

  # snap=$(sed -rn '\''s|.*com.bilabila.arknightsspeedrun2:id/switch_snap.[^>]*bilabila[^>]*bounds=.\[([0-9]*),([0-9]*)\]\[([0-9]*),([0-9]*)\]..*|input tap $(((\1+\3)/2)) $(((\2+\4)/2))|p'\'' /sdcard/window_dump.xml)
  # if [[ -n $snap ]]; then
  #   eval $snap
  #   continue
  # fi
done
done
' > /dev/null & ]=]

  exec(cmd)
  ssleep(60)
  restartScript()
end

trim_game_memory = function()
  if not root_mode then return end
  local cmd = [[nohup su root sh -c ' \
am send-trim-memory ]] .. appid .. [[ RUNNING_CRITICAL
' > /dev/null & ]]

  exec(cmd)

end

oom_score_adj = function()
  if not root_mode then return end
  if disable_oom_score_adj then return end
  -- if disable_oom_score_adj then return end
  -- if not enable_oom_score_adj then return end
  -- log("4032")

  -- local f = function(package)
  --     local cmd = [[nohup su root sh -c ' \
  -- while :; do
  --   package=]] .. package .. [[
  --   pid=$(pidof $package)
  --   [ -z $pid ] && exit
  --   echo -1000 > /proc/$pid/oom_score_adj
  --   strace -e trace=none -e signal=none -p $pid
  --   sleep 0.1
  -- done
  local cmd = [[nohup su root sh -c ' \
echo -1000 > /proc/$(pidof ]] .. package .. [[:remote)/oom_score_adj
echo -1000 > /proc/$(pidof ]] .. package .. [[)/oom_score_adj
echo -1000 > /proc/$(pidof ]] .. package .. [[:acc)/oom_score_adj
echo -1000 > /proc/$(pidof ]] .. [[nc)/oom_score_adj
' > /dev/null & ]]

  exec(cmd)

  -- cmd = 'nohup sleep 50 > /dev/null &'
  -- log(exec(cmd))
  -- while true do log(exec(cmd)) end
  -- end
  -- f(package .. ':acc')
  -- f(package .. ':remote')
  -- f(package .. '')
  -- keepalive_thread[1] = beginThread(f, package .. ':acc')
  -- keepalive_thread[2] = beginThread(f, package .. ':remote')
  -- keepalive_thread[3] = beginThread(f, package .. '')
  -- log("keepalive", keepalive_thread)

  -- local getCmd = function(package, score)
  --
  --   score = score or "-1000"
  --   return "echo " .. score .. " > /proc/$(pidof " .. package ..
  --            ")/oom_score_adj"
  -- end
  -- local get = function(package)
  --   return (exec("su root sh -c 'cat /proc/$(pidof " .. package ..
  --                  ")/oom_score_adj'") or ''):trim()
  -- end
  -- local package = getPackageName()
  -- local cmd = table.join({
  --   getCmd(package), getCmd(package .. ":acc"), getCmd(package .. ":remote"),
  -- }, ';')
  -- log(cmd)
  -- exec("su root sh -c '" .. cmd .. "'")
  -- exec("su root sh -c '" .. "sleep 1000" .. "'")
  -- log(4040)
  -- exit()
  -- log("oom_score_adj:" .. get(package) .. get(package .. ":acc") ..
  --       get(package .. ":remote"))
end

disable_lmk = function()
  if not root_mode then return end
  if not enable_disable_lmk then return end
  local cmd = [[nohup su root sh -c ' \
echo 1,2,3,4,5,6 > /sys/module/lowmemorykiller/parameters/minfree
' > /dev/null & ]]
  exec(cmd)
end

solveCapture = function()
  log("solve")

  ssleep(1)
  keepCapture()
  local node = findOne("captcha")
  if not node then
    log('3576 not found captcha')
    return
  end
  local left, top = node.bounds.l, node.bounds.t
  point.captcha_area = {
    left + scale(240), top + scale(40), left + scale(789), top + scale(481),
  }
  point.captcha_left_area = {
    left + scale(105), top + scale(40), left + scale(196), top + scale(481),
  }
  point.captcha_area_btn = {left + scale(114), top + scale(609)}

  local w, h, color
  local i, j, b, g, r
  local best, best_score, best_left, best_right
  local data
  local maxgrad
  local diff1, diff2, y1, y2, y3
  w, h, color = getScreenPixel(table.unpack(point.captcha_area))
  data = {}
  for i = 1, #color do
    b, g, r = colorToRGB(color[i])
    table.extend(data, {r, g, b})
  end

  maxgrad = {}
  for i = w + 1, #color do
    y1 = (0.299 * data[i * 3 - 2] + 0.587 * data[i * 3 - 1] + 0.114 *
           data[i * 3])
    y2 =
      (0.299 * data[(i - 2) * 3 - 2] + 0.587 * data[(i - 2) * 3 - 1] + 0.114 *
        data[(i - 2) * 3])
    y3 =
      (0.299 * data[(i - w) * 3 - 2] + 0.587 * data[(i - w) * 3 - 1] + 0.114 *
        data[(i - w) * 3])
    diff1 = y1 - y2
    diff2 = y1 - y3
    maxgrad[i % w] = (maxgrad[i % w] or 0) + max(0, diff1) /
                       (1 + math.abs(diff2))
  end

  -- local best = {}
  -- for i = 4, #maxgrad do
  --   table.insert(best, {maxgrad[i], i + point.captcha_area[1]})
  -- end
  -- table.sort(best, function(a, b) return a[1] > b[1] end)
  -- log(table.slice(best, 1, 10))
  -- log(point.captcha_area)
  -- exit()

  best = 1
  best_score = 0
  for i = 4, #maxgrad do
    if best_score < maxgrad[i] then
      best_score = maxgrad[i]
      best = i
    end
  end

  best_right = best + point.captcha_area[1]

  w, h, color = getScreenPixel(table.unpack(point.captcha_left_area))
  data = {}
  for i = 1, #color do
    b, g, r = colorToRGB(color[i])
    table.extend(data, {r, g, b})
  end
  maxgrad = {}
  for i = w + 1, #color do
    y1 = (0.299 * data[i * 3 - 2] + 0.587 * data[i * 3 - 1] + 0.114 *
           data[i * 3])
    y2 =
      (0.299 * data[(i - 2) * 3 - 2] + 0.587 * data[(i - 2) * 3 - 1] + 0.114 *
        data[(i - 2) * 3])
    y3 =
      (0.299 * data[(i - w) * 3 - 2] + 0.587 * data[(i - w) * 3 - 1] + 0.114 *
        data[(i - w) * 3])
    diff1 = y1 - y2
    diff2 = y1 - y3
    maxgrad[i % w] = (maxgrad[i % w] or 0) + max(0, -diff1) /
                       (1 + math.abs(diff2))
  end

  -- local best = {}
  -- for i = 4, #maxgrad do
  --   table.insert(best, {maxgrad[i], i + point.captcha_area[1]})
  -- end
  -- table.sort(best, function(a, b) return a[1] > b[1] end)
  -- log(table.slice(best,1,10))
  -- exit()

  best = 1
  best_score = 0
  for i = 4, #maxgrad do
    if best_score < maxgrad[i] then
      best_score = maxgrad[i]
      best = i
    end
  end

  best_left = best + point.captcha_left_area[1]
  log(3399, best_left, best_right)
  -- exit()

  -- log(table.slice(best, 1, 10))
  -- exit()
  -- log(w, h, best, best_score, best + point.captcha_area[1])

  -- for i = 1, #maxgrad do log(i, maxgrad[i]) end
  -- log(point.captcha_area)
  --
  local distance = best_right - best_left
  local sx, sy
  sx = point.captcha_area_btn[1]
  sy = point.captcha_area_btn[2]
  local duration = 500
  local finger = {
    point = {
      {sx, sy}, {sx + distance, sy},
      {sx + distance + scale(10), sy - scale(100)},
      {sx + distance + scale(10), sy},
      {sx + distance + scale(10), sy - scale(100)},
      {sx + distance + scale(10), sy},
      {sx + distance - scale(10), sy - scale(100)},
      {sx + distance - scale(10), sy},
      {sx + distance - scale(10), sy - scale(100)},
      {sx + distance - scale(10), sy}, {sx + distance, sy - scale(100)},
      {sx + distance, sy}, {sx + distance, sy - scale(100)},
      {sx + distance, sy}, {sx + distance, sy - scale(100)},
      {sx + distance, sy},
    },
    duration = duration,
  }
  log(finger.point[1], finger.point[#finger.point])
  gesture(finger)
  sleep(duration + 50)

  releaseCapture()
end

chineseUnicodeStringMatch = function(a, b)
  local len = min(#a, #b) // 3
  local score = 0
  for i = 1, len do
    if a:sub(i * 3 - 2, i * 3) == b:sub(i * 3 - 2, i * 3) then
      score = score + 1
    end
  end
  return score
end

disableRootToast = function(reenable)
  -- toast会影响识别
  local cmd = [[nohup su root sh -c ' \
root_manager=$(pm list packages|grep -e .superuser -e .supersu -e .magisk | head -n1|cut -d: -f2)
root_manager=${root_manager:-com.android.settings}
appops set $root_manager TOAST_WINDOW ]] .. (reenable and "allow" or "deny") ..
                [[;
settings put global heads_up_notifications_enabled ]] .. (reenable and 1 or 0) ..
                [[;
' > /dev/null & ]]
  -- log(5208,cmd)
  exec(cmd)
  -- ssleep(1000)
end

hd_wrapper = function(func)
  local f = function(...)
    swipu_flipy = scale(100)
    local keys = {}
    local point_store = {}
    local rfl_store = {}
    local first_point_store = {}

    for _, k in pairs(keys) do
      point_store[k] = point[k]
      rfl_store[k] = rfl[k]
      first_point_store[k] = first_point[k]
      point[k] = point[k .. "活动"]
      rfl[k] = rfl[k .. "活动"]
      first_point[k] = first_point[k .. "活动"]

    end

    local ret = func(...)

    for _, k in pairs(keys) do
      point[k] = point_store[k]
      rfl[k] = rfl_store[k]
      first_point[k] = first_point_store[k]
    end
    swipu_flipy = 0

    return ret
  end
  return f
end

update_state_from_debugui = function()
  multi_account_choice_weekday_only = expand_number_config(
                                        multi_account_choice_weekday_only or '')
  multi_account_disable_clue_unlock = expand_number_config(
                                        multi_account_disable_clue_unlock or '')

  max_jmfight_times = str2int(max_jmfight_times, 1)
  findOne_interval = str2int(findOne_interval, -1)
  max_fight_times = str2int(max_fight_times, math.huge)
  tap_interval = str2int(tap_interval, -1)
  zl_skill_times = str2int(zl_skill_times, 0)
  zl_skill_idx = str2int(zl_skill_idx, 1)
  tapall_duration = str2int(tapall_duration, -1)
  max_login_times = str2int(max_login_times, math.huge)
  max_login_times_5min = str2int(max_login_times_5min, 3)
  milesecond_after_click = str2int(tap_wait, milesecond_after_click)
  if not (always_enable_log or enable_log) then run = disable_log_wrapper(run) end
  -- if not enable_shift_log then
  --   chooseOperator = disable_log_wrapper(chooseOperator)
  -- end
  QQ = (QQ or ''):commonmap():trim()
  if QQ:find('#') then
    devicenote = QQ:sub(QQ:find('#') + 1, #QQ):trim()
    QQ = QQ:sub(1, QQ:find('#') - 1):trim()
    if QQ:find(' ') then
      QQ = QQ:split(' ')
      QQ, QQ2 = QQ[1], QQ[2]
    end
  end
  qqimagedeliver = (qqimagedeliver or ''):trim()
  if #qqimagedeliver == 0 then qqimagedeliver = "82.156.198.12:49875" end
  pushplus_token = (pushplus_token or ''):trim()
  for i = 1, 7 do
    local k = 'max_drug_times_' .. i .. 'day'
    _G[k] = str2int(_G[k], 0)
  end
  shift_min_mood = str2int(shift_min_mood, 12)
  if shift_min_mood <= 0 or shift_min_mood >= 24 then shift_min_mood = 12 end
  if enable_native_tap then clickPoint = _tap end
  max_fight_failed_times = str2int(max_fight_failed_times, 2)
  cloud.setDeviceToken(cloud_device_token)
  cloud.setServer(cloud_server)
  cloud.setStatus(extra_mode == "战略前瞻投资" and 1002 or 1001)
  -- if apk502 then enable_restart_package = true end
  -- enable_restart_package = not disable_restart_package

  restart_game_interval = str2int(restart_game_interval, 900)
  restart_package_interval = str2int(restart_package_interval, 3600)

  if restart_on_crontab_timeout == nil then restart_on_crontab_timeout = true end
end

-- 基建心情阈值与QQ号
main_ui_config_transfer = function()
  local main_config = loadOneUIConfig("main")
  local debug_config = loadOneUIConfig("debug")
  if main_config["QQ"] and #main_config["QQ"] > 0 then
    debug_config["QQ"] = main_config["QQ"]
  end
  if main_config["shift_min_mood"] and #main_config["shift_min_mood"] > 0 then
    debug_config["shift_min_mood"] = main_config["shift_min_mood"]
  end
  saveOneUIConfig("debug", debug_config)
end

qqhide = function(x)
  x = tostring(x)
  -- if #x<=7 then return x end
  -- return x:sub(1,3) + '***' + x:sub(#x-4,#x)
  return x:sub(#x - 3, #x)
end

hy_exec = function(x)
  return _exec('echo "' .. x:gsub('%$', '\\$') .. '"|nc localhost 49876')
end

path_name_escape = function(x)
  return x:map({
    ['/'] = '_',
    ["'"] = '_',
    ['"'] = '_',
    ['$'] = '_',
    ['\\'] = '_',
  })
end

number_ocr_correct = function(x)
  return x:map({
    ['〇'] = '0',
    ['C'] = '0',
    [','] = '',
    ['.'] = '',
    [' '] = '',
    ["O"] = '0',
    ["Q"] = '0',
    ["o"] = '0',
    ["|"] = '1',
    ["z"] = '2',
    ["Z"] = '2',
    ['s'] = '5',
    ['S'] = '5',
    -- ['e'] = '8',
    -- ['B'] = '8',
  }):trim()
end

isweekday = function()
  local cur_time = tonumber(os.date("%w", os.time()))
  if cur_time == 0 then cur_time = 7 end
  if cur_time < 6 then return true end
end

is_network_unstable = function()
  local cur_time = parse_time()
  local s, e
  s = os.time(update(os.date("*t"), {hour = 4, min = 0}))
  e = os.time(update(os.date("*t"), {hour = 4, min = 15}))
  if s < cur_time and cur_time < e then return true end
  s = os.time(update(os.date("*t"), {hour = 16, min = 0}))
  e = os.time(update(os.date("*t"), {hour = 16, min = 15}))
  if s < cur_time and cur_time < e then return true end
end

restart_package_last_time = time()
request_memory_clean = function()
  if (time() - restart_package_last_time > restart_package_interval * 1000) then
    qqnotify_before_restart_package()
    restart_account(false)
    return true
  end

  if (time() - kill_game_last_time[appid] > restart_game_interval * 1000) then
    restartapp(appid)
    return true
  end
end

remove_old_log = function()
  -- 一周前的文件
  exec("find /sdcard/" .. package .. '/ -ctime +7 -type f -delete')
end

clear_hook = function()
  local config = loadOneUIConfig("debug")
  config["before_account_hook"] = '-- before_account_hook'
  config["after_require_hook"] = '-- after_require_hook'
  config["after_all_hook"] = '-- after_all_hook'
  saveOneUIConfig("debug", config)
end

update_game = function()
  if not enable_update_game then return end
  -- curl 'https://line1-h5-pc-api.biligame.com/game/detail/gameinfo?game_base_id=101772'
  -- "android_download_link":"https://pkg.biligame.com/games/mrfz_1.8.21_20220606_101833_1d3de.apk"
  --
  -- https://ak.hypergryph.com/downloads/android_lastest
end

strOr = function(x, y)
  if type(x) == 'string' and #x:trim() > 0 then return x end
  return y or ''
end
str = tostring

get = function(Obj, Field, ...)
  if Obj == nil or Field == nil or type(Obj) ~= 'table' then
    return Obj
  else
    return get(Obj[Field], ...)
  end
end

istable = function(x) return type(x) == 'table' end

last_upload_img = ''
uploadImg = function(img)
  local ret = uploadFile(
                "https://tucang.cc/api/v1/upload?token=16557347027164af30c5ce7a14e7e9338f34cdfd953cf",
                img, 30)
  -- log('uploadImg', ret)
  local status
  status, ret = pcall(JsonDecode, ret)
  log("ret", ret)
  ret = get(ret, 'data', 'url')
  ret = strOr(ret)
  last_upload_img = ret
  return ret
end

-- eager post_util_hook
loadUIConfig({"debug"})
force_width = str2int(force_width, 0)
force_height = str2int(force_height, 0)

-- b服选点验证码打码
-- 接打码平台 http://www.ttshitu.com/

trySolvePointSelectionCapture = function(username, password, rect)

  -- 截图验证码 794,348,1138,745
  -- local p = point["选点验证码识别区域"]
  local img = getWorkPath() .. "/capture.jpg"
  snapShot(img, rect.l, rect.t, rect.r, rect.b)
  local img_base64 = base64(img)

  local data = {
    username = username,
    password = password,
    typeid = "19",
    image = img_base64,
  }

  local res, code = httpPost("http://api.ttshitu.com/predict", JsonEncode(data),
                             30, "Content-Type: application/json;charset=UTF-8")
  if code == 200 then
    local status, data = pcall(JsonDecode, res)
    data = data or {}
    ttshitu_last_id = get(data, "data", "id") or ""
    local success = get(data, "success") or false
    if not success then return end

    local ans = get(data, "data", "result") or ""
    local x, y = string.match(ans, "(%d+),(%d+)")
    x = x or 0
    y = y or 0
    local ans_p = {rect.l + x, rect.t + y}
    tap(ans_p)
    return true
  end

end

ttshitu_report = function()
  if not ttshitu_last_id then return end
  local data = {id = ttshitu_last_id}
  local ret, code = httpPost("http://api.ttshitu.com/reporterror.json",
                             JsonEncode(data), 30,
                             "Content-Type: application/json;charset=UTF-8")
  log(ret, code)
end
