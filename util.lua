appid = 'com.hypergryph.arknights'
hudid = createHUD()

insert = table.insert

shallowcopy = function(x)
  local y = {}
  if x == nil then return y end
  for k, v in pairs(x) do y[k] = v end
  return y
end

update = function(b, x)
  local y = shallowcopy(b)
  if x == nil then return y end
  for k, v in pairs(x) do y[k] = v end
  return y
end

repeat_last = function(x, n)
  for i = 1, n do insert(x, x[#x]) end
  return x
end

loop_times = function(x)
  local times, f, n
  local maxlen = 50
  local maxtimes = 1
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
  local n = select('#', ...)
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
    if type(f) == 'function' then
      p = f(p)
    elseif type(f) == 'table' then
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

stop = function() lua_exit() end

show = function(x)
  print(x)
  showHUD(hudid, x, 24, "0xff444444", "0xffffffff", 2, 0, 1080 - 36, 500, 36)
end

history = {}
table.clear = function(x) for k, v in pairs(x) do x[k] = nil end end
log = function(...)
  local l = {map(tostring, running, ' ', ...)}
  local a = ''
  for _, v in pairs(l) do a = a .. v end
  if #history > 6000 then table.clear(history) end
  history[#history + 1] = a
  l = loop_times(history)
  if l > 100 then stop() end
  if l > 1 then a = a .. ' x' .. l end
  show(a)
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

restart = function()
  close()
  sleep(1)
  set('restart', true)
  lua_restart()
end

now = function(...)
  if get('restart') == 'true' then
    set('restart', 'false')
  else
    map(run, {...})
  end
end

conf2task = function(c, m)
  local p, q = 0, 0
  local r = {}
  if c == nil or #c == 0 then return end
  while true do
    q = c:find('@', p + 1)
    if q == nil then break end
    table.insert(r, c:sub(p + 1, q - 1))
    p = q
  end
  table.insert(r, c:sub(p + 1))
  r = map(function(x) return x + 1 end, map(tonumber, r))
  if m == nil then return r end
  return map(m, r)
end

find = function(x)
  local y = {0, 0, 0}
  if not x:find('|') then x = point[x] end
  if type(x) == 'table' then x, y = x[1], x[2] end
  if type(x) == 'string' then
    x, y = findColor({0, 0, 1919, 1079}, x, 100, y[1], y[2], y[3])
  end
  if type(x) == 'number' and x > -1 then return {x, y} end
end

-- x={2,3} '信用' func nil
tap = function(x)
  keepScreen(false)
  if isFrontApp(appid) == 0 then
    show('应用不在前台')
    restart()
  end
  y = x
  if x == true then return true end
  if type(x) == 'function' then return x() end
  if type(x) == 'string' then
    y = find(x)
    if not y then
      x = point[x]
      if type(x) == 'table' and type(x[1]) == 'string' then x = x[1] end
      local p = x:find('|')
      local q = x:find('|', p + 1)
      x, y = x:sub(1, p - 1), x:sub(p + 1, q - 1)
      y = map(tonumber, {x, y})
    end
  end
  if type(y) ~= 'table' then return end
  x, y = y[1], y[2]
  touchDown(0, x, y)
  sleep(0.2)
  touchUp(0, x, y)
  sleep()
end

input = function(x, s)
  tap(x)
  inputText("#CLEAR#")
  sleep(.5)
  inputText(s)
  sleep(.5)
  tap(x)
end

swip = function(x, y, dx, dy)
  local i = 0
  touchDown(i, x, y)
  local times = 20
  local sx = dx / times
  local sy = dy / times
  for j = 1, times do
    x = x + sx
    y = y + sy
    touchMove(i, x, y)
    sleep(.2)
  end
  touchUp(i, x, y)
  sleep()
end

scale = function(o)
  a = {413, 295}
  b = {1537, 872}
  touchDown(1, a[1], a[2])
  touchDown(2, b[1], b[2])
  t = 20
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

auto = function(p)
  if type(p) == 'function' then return p() end
  if type(p) ~= 'table' then return true end
  while true do
    keepScreen(true)
    f = false
    for k, v in pairs(p) do
      if find(k) then
        f = true
        log(k, '=>', v)
        if tap(v) then return true end
        break
      end
    end
    if f == false then
      local k = '其它'
      local v = p[k]
      log(k, '=>', v)
      tap(v)
    end
    sleep(.5)
  end
end

run = function(...)
  if running ~= nil then return end
  if #arg == 1 then
    if type(arg[1]) == 'function' then return arg[1]() end
    if type(arg[1]) == 'table' then arg = arg[1] end
  end
  open()
  running = '移动停止按钮'
  auto(path[running])
  for _, i in pairs(arg) do
    running = i
    auto(path[i])
    if running ~= i then break end
  end
  running = nil
end

-- hour crontab
hc = function(x, h)
  if type(x) == 'table' then x, h = x[1], x[2] end
  return {callback = function() run(x) end, hour = h, minute = 30}
end
