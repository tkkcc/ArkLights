max = math.max
min = math.min
math.round = function(x) return math.floor(x + 0.5) end
clip = function(x, minimum, maximum) return min(max(x, minimum), maximum) end
insert = table.insert
-- https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
function trim(s) return s:match '^()%s*$' and '' or s:match '^%s*(.*%S)' end
string.count = function(str, pattern)
  local ans = 0
  for _ in str.gfind(pattern) do ans = ans + 1 end
  return ans
end
string.map = function(str, map)
  local ans = ''
  for character in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
    -- print(character)
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

string.startsWith = function(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

string.endsWith = function(str, suffix)
  return string.sub(str, #str - string.len(suffix) + 1) == suffix
end

startsWithX = function(x) return
  function(prefix) return x:startsWith(prefix) end end

string.lpad = function(str, len, char)
  if char == nil then char = " " end
  return str .. string.rep(char, len - #str)
end
table.select = function(mask, reference)
  local ans = {}
  for i = 1, #reference do if mask[i] then insert(ans, reference[i]) end end
  return ans
end
-- return true if there is an x s.t. f(x) is true
table.any = function(t, f)
  for k, v in pairs(t) do if f(v) then return true end end
end
-- return true if f(x) is all true
table.all = function(t, f)
  for k, v in pairs(t) do if not f(v) then return false end end
  return true
end
table.findv = function(t, f)
  for k, v in pairs(t) do if f(v) then return v end end
end

table.filter = function(t, f)
  local a = {}
  for k, v in pairs(t) do if f(v) then insert(a, v) end end
  return a
end
table.keys = function(t)
  local a = {}
  for k, v in pairs(t) do table.insert(a, k) end
  return a
end
-- a,a+1,...b
range = function(a, b)
  local t = {}
  for i = a, b do insert(t, i) end
  return t
end

table.includes = function(t, e)
  return table.any(t, function(x) return x == e end)
end

table.extend = function(t, e) for k, v in pairs(e) do insert(t, v) end end
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
      if table.includes(v2, k) then insert(r[k], k2) end
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
equalX = function(x) return function(y) return x == y end end

shallowCopy = function(x)
  local y = {}
  if x == nil then return y end
  for k, v in pairs(x) do y[k] = v end
  return y
end

update = function(b, x, inplace)
  local y = inplace and b or shallowCopy(b)
  if x == nil then return y end
  for k, v in pairs(x) do y[k] = v end
  return y
end

-- n: num, a: alternative element
repeat_last = function(x, n, a)
  if a == nil then a = x[#x] end
  for i = 1, n do insert(x, a) end
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

nop = function() end

-- content height
-- show = function(x, h)
--  print(x)
--  h = not h and 36 or h
--  --showHUD(hudid, x, 24, "0xff444444", "0xffffffff", 2, 0, 1080 - 36, 500, h)
-- end

table.join = function(t, d)
  d = not d and ',' or d
  local a = ''
  for i = 1, #t do
    a = a .. t[i]
    if i ~= #t then a = a .. d end
  end
  return a
end

history = {}
table.clear = function(x) for k, v in pairs(x) do x[k] = nil end end

removeFuncHash =
  function(x) return x:startsWith('function') and 'function' or x end

table2string = function(t)
  if type(t) == 'table' then
    if #t == 0 then
      return JsonEncode(t)
    else
      return table.join(map(tostring, t))
    end
  end
  return t
end

log = function(...)
  local l = {
    map(tostring, running, " ", table.unpack(map(table2string, {...}))),
  }
  l = map(removeFuncHash, l)
  l = map(table2string, l)
  local a = time()
  for _, v in pairs(l) do a = a .. ' ' .. v end
  if #history > 2000 then table.clear(history) end
  history[#history + 1] = a
  l = loop_times(history)
  if l > 1 then a = a .. " x" .. l end
  if l > 100 then stop("246") end
  print(a)
end

set = function(k, v)
  k, v = map(tostring, k, v)
  save(k, v)
end

-- get = function(k, v)
-- k, v = map(tostring, k, v)
-- return getStringConfig(k, v)
-- end

open = function()
  local appid = "com.hypergryph.arknights"
  runApp(appid)
end
start = open
stop = function(msg)
  log("stop " .. msg)
  toast("stop " .. msg)
  -- TODO showHUD
  -- logConfig({
  --  x = math.floor(screen.width / 4),
  --  y = math.floor(screen.height / 4),
  --  width = math.floor(screen.width / 2),
  --  height = math.floor(screen.height / 2),
  --  color = "#37474F",
  --  bgcolor = "#FFFFFF",
  --  mode = 2,
  --  size = 11,
  --  debug = false,
  --  shadow = false,
  -- });
  -- ssleep(3600 * 72)
  exit()
end

pause = function(t)
  background()
  ssleep(t or (3600 * 72))
end

background = home

conf2task = function(c, m)
  local p, q = 0, 0
  local r = {}
  if c == nil or #c == 0 then return end
  while true do
    q = c:find("@", p + 1)
    if q == nil then break end
    insert(r, c:sub(p + 1, q - 1))
    p = q
  end
  insert(r, c:sub(p + 1))
  r = map(function(x) return x + 1 end, map(tonumber, r))
  if m == nil then return r end
  return map(m, r)
end

findColorAbsolute = function(color)
  -- keepScreen(true)
  for x, y, c in color:gmatch("(%d+),(%d+),(#[^|]+)") do
    -- log(x, y, c)
    -- if not compareColor(tonumber(x), tonumber(y), c, 100) then
    if getColor(tonumber(x), tonumber(y)).hex ~= c then
      if verbose_fca then log(x, y, c) end
      -- keepScreen(false)
      return
    end
  end
  local x, y = color:match("(%d+),(%d+)")
  -- log(310)
  -- keepScreen(false)
  return {x = x, y = y}
end
findOne = function(x)
  local x0 = x
  local confidence = 100 -- workaround, should be 100
  if not x:find(coord_delimeter) then x = point[x] end
  if type(x) == "table" then return x end
  if type(x) == "string" then
    local pos
    if rfl[x0] then
      pos = findColorAbsolute(x)
    else
      local color = shallowCopy(rfl[x0] or {0, 0, screen.width, screen.height})
      table.extend(color, {x, confidence})
      -- log(x0, color)
      -- workaround
      if not x:find(point_delimeter) then
        if compareColor(color[1], color[2], x:sub(-7), confidence) then
          pos = {x = color[1], y = color[2]}
        end
      else
        -- log(314, color)
        pos = findColor(color)
      end
    end
    -- log(294)
    -- if pos then log(pos.x, pos.y) end
    if pos then return {pos.x, pos.y} end
  end
end

findAll = function(x)
  local x0 = x
  local y
  if not x:find(coord_delimeter) then x = point[x] end
  if type(x) == "table" then return x end
  if type(x) == "string" then
    points = findColors(rfl[x0] or {0, 0, 1919, 1079}, x, 100)
    if #points > 0 then return points end
  end
end

-- x={2,3} "信用" func nil
tap = function(x, retry, allow_outside_game)
  if not allow_outside_game then wait_game_up() end
  local x0 = x
  if x == true then return true end
  if x == "返回" then back() end
  if type(x) == "function" then return x() end
  if type(x) == "string" and not x:find(coord_delimeter) then
    x = point[x]
    if type(x) == "string" then
      local p = x:find(coord_delimeter)
      local q = x:find(",", p + 1)
      x = map(tonumber, {x:sub(1, p - 1), x:sub(p + 1, q - 1)})
    end
  end
  -- log(x0, x)
  if type(x) ~= "table" then return end
  -- log('tap', x[1], x[2])
  click(x[1], x[2])
  if retry then return end

  -- 返回"面板"后易触发数据更新,导致操作失效
  if type(x0) == 'string' and x0:startsWith('面板') then
    wait(function()
      if not findOne('面板') then return true end
      log("retap", x0)
      tap(x0, true, allow_outside_game)
    end, 2)
  end
  ssleep(tap_extra_delay[x0] or 0)
end

-- input = function(x, s)
--  tap(x)
--  inputText("#CLEAR#")
--  ssleep(.5)
--  inputText(s)
--  -- inputText('#ENTER#')
--  ssleep(.5)
--  tap('返回')
--  ssleep(.5)
-- end

-- swip = function(x, y, dx, dy, t, interval)
--  if not (x and y and dx and dy) then return end
--  interval = interval or .2
--  slid(x,y,x+dx,y+dy,t)
--  local times = 20
--  local e = 1e-6
--  if t then times = math.floor((t + e) / interval) end
--  local sx = dx / times
--  local sy = dy / times
--  for j = 1, times do
--    x = x + sx
--    y = y + sy
--    ssleep(interval)
--    touchMove(i, x, y)
--  end
--  ssleep(interval)
--  touchUp(i, x, y)
--  ssleep(interval)
-- end

-- quick multiple swip for 作战
-- input distance => {x,y,x',y',time} / list of them
swipq = function(dis)
  wait_game_up()
  if type(dis) == "string" then dis = distance[dis] end
  -- no need to swip
  if not dis then return end
  -- multiple swip
  log(401, dis)
  if type(dis) ~= "table" then dis = {dis} end
  log(403, dis)
  for _, x in pairs(dis) do
    if type(x) == 'number' then
      if x == 0 then -- special wait
        ssleep(.4)
      elseif x > 0 then -- magick distance map from xxzhushou to nspirit
        log(200, 400, min(1720, 200 + x * 2), 400, 400)
        slid(math.round(200 * wscale), math.round(400 * hscale),
             math.round(min(1720, 200 + x * 2) * wscale),
             math.round(400 * hscale), 400)
      elseif x < 0 then
        log(1720, 400, max(200, 1720 + x * 2), 400, 400)
        slid(math.round(1720 * wscale), math.round(400 * hscale),
             math.round(max(200, 1720 + x * 2) * wscale),
             math.round(400 * hscale), 400)
      end
    elseif type(x) == 'table' then
      log(table.unpack(x))
      local a, b, c, d, e = table.unpack(x)
      slid(math.round(a * wscale), math.round(b * hscale),
           math.round(c * wscale), math.round(d * hscale), e)
    else
      stop(413)
    end
    log("after slid", x)
    ssleep(.4)
  end
  log(422)
end

auto = function(p, timeout, interval)
  if type(p) == "function" then return p() end
  if type(p) ~= "table" then return true end
  while true do
    local f = false
    local check = function()
      for k, v in pairs(p) do
        if findOne(k) then
          log(k, "=>", v)
          if tap(v) then f = true end
          -- hook
          -- TODO
          return true
        end
      end
    end
    local e = wait(check, timeout or 1, interval or 0)

    -- tap true
    if f then return true end

    -- tap false or timeout
    if not e then
      local k = "其它"
      local v = p[k]
      log(k, "=>", v)
      tap(v)
    end
  end
end

-- run function / job / table of function and job
run = function(...)
  local arg = {...}
  if #arg == 1 then
    if type(arg[1]) == "function" then return arg[1]() end
    if type(arg[1]) == "table" then arg = arg[1] end
  end
  path.移动停止按钮()
  -- check_stop_button_position(true)
  for _, v in ipairs(arg) do
    if type(v) == 'function' then
      v()
    else
      running = v
      -- log(path[v])
      auto(path[v])
    end
  end
  set("retry", 0)
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

-- if find then tap with fallback
findTap = function(target)
  if type(target) == 'string' or #target == 0 then target = {target} end
  for _, v in pairs(target) do
    local x = findOne(v)
    if x then
      tap(x)
      return true
    end
  end
end

-- wait some
appearTap = function(target, timeout, interval)
  if type(target) == 'string' or #target == 0 then target = {target} end
  target = appear(target, timeout, interval)
  if target then
    findTap(target)
    return true
  end
end
-- {x:2,y:3} => {2,3}
xy2arr = function(t) return {t.x, t.y} end

deploy = function(x1, x2, y2, d)
  -- TODO
  local y1 = 1000
  local t = .3
  d = d or 2
  d = ({{0, -1}, {1, 0}, {0, 1}, {-1, 0}})[d]
  d = {d[1] * 500, d[2] * 500}
  swip(x1, y1, x2 - x1, y2 - y1, t, t)
  swip(x2, y2, x2 + d[1], y2 + d[2], .2)
end

-- todo: make a map ?
retreat = function(x1, y1, x2, y2)
  local t = .2
  touchDown(0, x1, y1)
  ssleep(t)
  touchUp(0, x1, y1)
  ssleep(t)
  touchDown(0, x2, y2)
  ssleep(t)
  touchUp(0, x2, y2)
end

-- wait until func success
wait = function(func, timeout, interval)
  timeout = timeout or 2
  interval = interval or 0
  -- log(timeout,interval)
  local start_time = time()
  while true do
    local ans = func()
    -- log(584,ans)
    if ans then return ans end
    if (time() - start_time) > timeout * 1000 then break end
    ssleep(interval)
  end
end

-- wait until see node / point / list of node and point
appear = function(target, timeout, interval, disappear)
  if type(target) == 'string' or #target == 0 then target = {target} end
  return wait(function()
    for _, v in pairs(target) do
      if disappear then
        if #v == 0 and not find(v) then
          return v
        elseif #v > 0 and not findOne(v) then
          return v
        end
      else
        if #v == 0 and find(v) then
          return v
        elseif #v > 0 and findOne(v) then
          return v
        end
      end
    end
  end, timeout, interval)
end
disappear = function(target, timeout, interval)
  return appear(target, timeout, interval, true)
end
wait_game_up = function()
  local game = R():name("com.hypergryph.arknights"):path("/FrameLayout/View")
  if not find(game) then
    open()
    if not appear(game, 10, 1) then stop("游戏不在前台") end
  end
end
