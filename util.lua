appid = "com.hypergryph.arknights"
hudid = createHUD()

insert = table.insert
-- https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
function trim(s) return s:match '^()%s*$' and '' or s:match '^%s*(.*%S)' end

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
-- return true if there is an x s.t. f(x) is true
table.any = function(t, f)
  for k, v in pairs(t) do if f(v) then return true end end
end
table.findv = function(t, f)
  for k, v in pairs(t) do if f(v) then return v end end
end

table.filter = function(t, f)
  local a = {}
  for k, v in pairs(t) do if f(v) then insert(a, v) end end
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
--	in = {
--		"A" = {1,4,5,7},
--		"B" = {1,2,5,6},
--		"C" = {3,4,6,7},
--		"D" = {2,3,6,7},
--	}
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
    x = {unpack(a, 2, n)}
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
  if ur then return unpack(r, 1, n) end
  return r
end

sleep = function(x)
  if x == nil then x = 1 end
  mSleep(x * 1000)
end

nop = function() end

-- content height
show = function(x, h)
  print(x)
  h = not h and 36 or h
  showHUD(hudid, x, 24, "0xff444444", "0xffffffff", 2, 0, 1080 - 36, 500, h)
end

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
    local a = table.join(map(tostring, t))
    return a
  end
  return t
end

log = function(...)
  local l = {map(tostring, running, " ", unpack(map(table2string, {...})))}
  l = map(removeFuncHash, l)
  l = map(table2string, l)
  local a = ""
  for _, v in pairs(l) do a = a .. v end
  if #history > 2000 then table.clear(history) end
  history[#history + 1] = a
  l = loop_times(history)
  if l > 1 then a = a .. " x" .. l end
  show(a)
  if l > 500 then error() end
end

set = function(k, v)
  k, v = map(tostring, k, v)
  setStringConfig(k, v)
end

get = function(k, v)
  k, v = map(tostring, k, v)
  return getStringConfig(k, v)
end

open = function() runApp(appid) end

close = function() closeApp(appid) end

start = function() open() end

stop = function()
  log("stop")
  -- DEBUG
  sleep(3600*72)
  pause()
  lua_exit()
end
pause = function(t)
  background()
  sleep(t or 3600*72)
end
restart = function()
  log("restart")
  pause()
  close()
  set("restart", true)
  lua_restart()
end

background = function() pressHomeKey() end

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

find = function(x)
  local x0 = x
  local y
  if not x:find("|") then x = point[x] end
  if type(x) == "table" then return x end
  if type(x) == "string" then
    -- if rfl[x0] == nil then log("findColor globally ", x0) end
    x, y = findColor(rfl[x0] or {0, 0, 1919, 1079}, x, 100)
    if x ~= -1 then return {x, y} end
  end
end

out_of_app = false
-- x={2,3} "信用" func nil
tap = function(x)
  keepScreen(false)
  if not out_of_app and isFrontApp(appid) == 0 then
    show("应用不在前台")
    open()
    sleep(5)
    return
  end
  local x0 = x
  if x == true then return true end
  if type(x) == "function" then return x() end
  if type(x) == "string" and not x:find("|") then
    x = point[x]
    if type(x) == "string" then
      local p = x:find("|")
      local q = x:find("|", p + 1)
      x = map(tonumber, {x:sub(1, p - 1), x:sub(p + 1, q - 1)})
    end
  end
  if type(x) ~= "table" then return end
  touchDown(0, x[1], x[2])
  sleep(0.2)
  touchUp(0, x[1], x[2])
  sleep(tap_extra_delay[x0] or 0)
end

input = function(x, s)
  tap(x)
  inputText("#CLEAR#")
  sleep(.5)
  inputText(s)
  sleep(.5)
  tap(x)
end

swip = function(x, y, dx, dy, t, interval)
  if not (x and y and dx and dy) then return end
  local i = 0
  touchDown(i, x, y)
  local times = 20
  local e = 1e-6
  interval = interval or .2
  if t then times = math.floor((t + e) / interval) end
  local sx = dx / times
  local sy = dy / times
  for j = 1, times do
    x = x + sx
    y = y + sy
    sleep(interval)
    touchMove(i, x, y)
  end
  sleep(interval)
  touchUp(i, x, y)
  sleep(interval)
end
-- quick multiple horizontal swip 
swipq = function(t)
  if type(t) == "string" then t = point.滑动距离[t] end
  -- no need to swip
  if not t then return end
  -- multiple swip
  if type(t) ~= "table" then t = {t} end
  for k, v in pairs(t) do swip(1000, 500, v, 0, .4) end
  -- wait for inertia
  if #t > 1 then sleep() end
end

-- put (a,b) to (x,y)
scale = function(o)
  a = {413, 295}
  b = {1537, 872}
  touchDown(1, a[1], a[2])
  touchDown(2, b[1], b[2])
  t = 2
  l = 150
  s = l / t
  if o then s = s * -1 end
  for i = 1, t do
    a[1] = a[1] + s
    a[2] = a[2] + s
    b[1] = b[1] - s
    b[2] = b[2] - s
    touchMove(1, a[1], a[2])
    touchMove(2, b[1], b[2])
    sleep(.2)
  end
  touchUp(1, a[1], a[2])
  touchUp(2, b[1], b[2])
end

auto = function(p, timeout, interval)
  if type(p) == "function" then return p() end
  if type(p) ~= "table" then return true end
  while true do
    local f = false
    local check = function()
      keepScreen(true)
      for k, v in pairs(p) do
        if find(k) then
          log(k, "=>", v)
          if tap(v) then f = true end
          return true
        end
      end
      keepScreen(false)
    end
    local e = wait(nil, check, timeout or 0, interval or 1)
    -- tap true
    if f then return true end
    -- tap false or timout
    if not e then
      local k = "其它"
      local v = p[k]
      log(k, "=>", v)
      tap(v)
    end
  end
end
-- find tap for auto
ft = function(x) return findTap(x) end

now = function(...)
  if get("restart") == "true" then
    set("restart", "false")
  else
    map(run, arg)
  end
end

run = function(...)
  if #arg == 1 then
    if type(arg[1]) == "function" then return arg[1]() end
    if type(arg[1]) == "table" then arg = arg[1] end
  end
  running = "移动停止按钮"
  auto(path[running])
  for k, v in ipairs(arg) do
    if type(v) == 'function' then
      v()
    else
      running = v
      -- log(path[v])
      auto(path[v])
    end
  end
end
-- hour crontab
hc = function(x, h)
  if type(x) == "table" then x, h = x[1], x[2] end
  return {callback = function() run(x) end, hour = h, minute = 30}
end
-- if find then tap with fallback
findTap = function(...)
  for k, v in ipairs(arg) do
    local x = find(v)
    if x then
      tap(x)
      sleep(tap_extra_delay[v] or 0)
      return true
    end
  end
end

appearTap = function(x, timeout, interval)
  if appear(x, timeout, interval) then
    findTap(x)
    return true
  end
end
-- {x:2,y:3} => {2,3}
xy2arr = function(t) return {t.x, t.y} end

deploy = function(x1, x2, y2, d)
  local y1 = 1000
  local t = .3
  d = d or 2
  d = ({{0, -1}, {1, 0}, {0, 1}, {-1, 0}})[d]
  d = {d[1] * 500, d[2] * 500}
  swip(x1, y1, x2 - x1, y2 - y1, t, t)
  swip(x2, y2, x2 + d[1], y2 + d[2], .2)
end

-- todo: make a map
retreat = function(x1, y1, x2, y2)
  local t = .2
  touchDown(0, x1, y1)
  sleep(t)
  touchUp(0, x1, y1)
  sleep(t)
  touchDown(0, x2, y2)
  sleep(t)
  touchUp(0, x2, y2)
end
-- until f true
wait = function(t, func, timeout, interval)
  timeout = timeout or 60
  interval = interval or 1
  local count = 0
  local max_count = math.floor(timeout / interval)
  while not func(t) do
    count = count + 1
    if count > max_count then break end
    sleep(interval)
  end
  if count <= max_count then return true end
end

appear = function(t, timeout, interval)
  local f = function(x) return find(x) end
  return wait(t, f, timeout, interval)
end
disappear = function(t, timeout, interval)
  local f = function(x) return not find(x) end
  return wait(t, f, timeout, interval)
end

-- faster than table.sort when #a>=25
median = function(a)
  local l = 1
  local r = #a
  local lo, am
  while l < r do
    lo = l - 1
    am = a[r]
    for i = l, r - 1 do
      if a[i] < am then
        lo = lo + 1
        a[lo], a[i] = a[i], a[lo]
      end
    end
    lo = lo + 1
    a[lo], a[r] = a[r], a[lo]
    if math.floor(#a / 2) + 1 <= lo then
      r = lo - 1
    else
      l = lo + 1
    end
  end
  if #a % 2 == 0 then
    return (a[math.floor(#a / 2) + 1] + a[math.floor(#a / 2)]) / 2
  else
    return a[math.floor(#a / 2) + 1]
  end
end

max = math.max
min = math.min
