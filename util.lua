print('util')
max = math.max
min = math.min
math.round = function(x) return math.floor(x + 0.5) end
clip = function(x, minimum, maximum) return min(max(x, minimum), maximum) end

-- https://stackoverflow.com/questions/10460126/how-to-remove-spaces-from-a-string-in-lua
string.trim = function(s) return
  s:match '^()%s*$' and '' or s:match '^%s*(.*%S)' end

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
range = function(a, b)
  local t = {}
  for i = a, b do table.insert(t, i) end
  return t
end

table.includes = function(t, e)
  return table.any(t, function(x) return x == e end)
end

table.extend = function(t, e) for k, v in pairs(e) do table.insert(t, v) end end

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
    return JsonEncode(t)
    --    if #t == 0 then
    --    else
    --      return table.join(map(tostring, t))
    --    end
  end
  return t
end

log_history = {}
log = function(...)
  if disable_log then return end
  local arg = {...}
  local l = {map(tostring, running, ' ', table.unpack(map(table2string, arg)))}
  l = map(removeFuncHash, l)
  l = map(table2string, l)
  local a = time()
  for _, v in pairs(l) do a = a .. ' ' .. v end
  -- if #log_history > 2000 then table.clear(log_history) end
  -- log_history[#log_history + 1] = a
  -- l = loop_times(log_history)
  -- l = 0
  -- if l > 1 then a = a .. " x" .. l end
  -- if l > 100 then stop("246") end
  print(a)
end

open = function(retry) runApp(appid) end

stop = function(msg)
  msg = msg or ''
  log("stop " .. msg)
  toast("stop " .. msg)
  logConfig({
    width = math.round(screen.height * .8),
    height = math.round(screen.height * .8),
    mode = 2,
  })
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

findOne_last_time = 0
findOne = function(x, confidence)
  if type(x) == "function" then return x() end

  -- check foreground
  if (time() - findOne_last_time > 5000) then
    wait_game_up()
    findOne_last_time = time()
  end

  local x0 = x
  confidence = confidence or default_findcolor_confidence
  -- print(confidence)
  if type(x) == 'string' and not x:find(coord_delimeter) then x = point[x] end
  if type(x) == "table" then return x end
  if type(x) == "function" then return x() end
  if type(x) == "string" then
    local pos
    if rfl[x0] then
      pos = findColorAbsolute(x, confidence)
    else
      local color = shallowCopy(rfg[x0])
      table.extend(color, {x, confidence})
      log(color)
      pos = findColor(color, confidence)
    end
    if pos then return {pos.x, pos.y} end
  end
end

findAny = function(x) return appear(x, 0, 0) end

findAll = function(x, confidence)
  confidence = confidence or default_findcolor_confidence
  local color = shallowCopy(rfl[x] or {0, 0, screen.width, screen.height})
  table.extend(color, {point[x], confidence})
  return findColors(color)
end

first_time_tap_nil = time()
-- x={2,3} "信用" func nil
tap = function(x, retry, allow_outside_game)
  if not unsafe_tap and not allow_outside_game and not check_after_tap then
    wait_game_up()
  end

  local x0 = x
  if x == true then return true end
  if x == nil then
    first_time_tap_nil = time()
    if time() - first_time_tap_nil > 5000 then -- 5 seconds
      tap("返回")
      first_time_tap_nil = time()
    end
    return
  end
  if type(x) == "function" then return x() end
  if type(x) == "string" and not x:find(coord_delimeter) then
    x = point[x]
    if type(x) == "string" then
      local p = x:find(coord_delimeter)
      local q = x:find(coord_delimeter, p + 1)
      -- log(p, q)
      x = map(tonumber, {x:sub(1, p - 1), x:sub(p + 1, q - 1)})
    end
  end
  log("tap", x0, x)
  if type(x) ~= "table" then return end
  -- log(373)
  if zero_wait_click then
    gesture({{{x = x[1], y = x[2]}}}, 1)
    sleep(2)
    -- log(374)
  else
    click(x[1], x[2])
  end

  if not unsafe_tap and not allow_outside_game and check_after_tap then
    wait_game_up()
  end

  -- log(399)
  if retry then return end

  -- 返回"面板"后易触发数据更新,导致操作失效
  if type(x0) == 'string' and x0:startsWith('面板') then
    wait(function()
      if not findOne("面板") then return true end
      log("retap", x0)
      tap(x0, true, allow_outside_game)
      log(352)
    end, 10)
  end
  -- log(375)
end

-- quick multiple swip, for fights
-- input distance => {x,y,x',y',time} / list of them
swipq = function(dis, disable_end_sleep, duration)
  log("swipq", dis)
  wait_game_up()
  duration = duration or 400
  if type(dis) == "string" then dis = distance[dis] end
  if not dis then return end
  if type(dis) ~= "table" then dis = {dis} end
  log("367", dis)
  for idx, x in ipairs(dis) do
    if type(x) == 'number' then
      local left_boundary = math.round(100 * minscale)
      local right_boundary = math.round((1620 - 1920) * minscale + screen.width)
      local height = screen.height // 2
      if x == 0 then -- special wait sign
        ssleep(.4)
      elseif x == 1 then -- special quit sign
        return
      elseif x > 0 then -- magick distance map from xxzhushou to nspirit
        log(left_boundary, height, min(right_boundary, left_boundary + x * 2),
            right_boundary, duration)
        slid(left_boundary, height, min(right_boundary, left_boundary + x * 2),
             right_boundary, duration)
      elseif x < 0 then
        log(right_boundary, height, max(left_boundary, right_boundary + x * 2),
            height, duration)
        slid(right_boundary, height, max(left_boundary, right_boundary + x * 2),
             height, duration)
      end
    elseif type(x) == 'table' then
      log(x)
      slid(table.unpack(x))
    else
      stop(413)
    end
    if not (disable_end_sleep and idx == #dis) then ssleep(.4) end
  end
end

-- swip to end
swipe = function(x)
  log("swipe", x)
  -- wait_game_up()
  local duration = 150
  -- if is_device_need_slow_swipe then duration = duration * 2 end

  local x1 = screen.width - math.round(300 * minscale) * 2
  local d = x == "right" and x1 or -x1
  if d == x1 then x1 = math.round(300 * minscale) end
  local y1 = math.round(128 * minscale)
  local x2 = math.round(x1 + d)
  slid(x1, y1, x2, y1, duration)
  sleep(50)
  slid(x1, y1, x2, y1, duration)
  sleep(50)
  slid(x1, y1, x2, y1, duration)
  sleep(50)
  slid(x1, y1, x2, y1, duration)
  sleep(50)
end

-- 安卓8以下的滑动用双指
android_verison_code = getAppinfo("android").versionCode
if android_verison_code < 26 then
  is_device_swipe_too_fast = true
else
  is_device_swipe_too_fast = false
end

-- 华为手机需要慢速滑动
is_device_need_slow_swipe = true

-- universal multiple swip, for fights
-- input distance => {x,y,x',y',time} / list of them
swipu = function(dis)
  log('swipu', dis)
  -- wait_game_up()
  -- preprocess distance
  if type(dis) == "string" then dis = distance[dis] end
  if type(dis) ~= "table" then dis = {dis} end
  if not dis then return end

  -- flatten to one depth
  -- local max_once_dis = 1080
  local max_once_dis = screen.width - math.round(300 * minscale)
  local disf = {}
  for _, d in pairs(dis) do
    local sign = d > 0 and 1 or -1
    d = math.abs(d)
    while d > 0 do
      if d > max_once_dis then
        table.insert(disf, sign * max_once_dis)
        d = d - max_once_dis
      else
        table.insert(disf, sign * d)
        d = 0
      end
    end
  end

  -- do swip
  for _, d in pairs(disf) do
    local duration = 200
    local delay = 50
    if is_device_need_slow_swipe then
      duration = duration * 2
      delay = delay * 2
    end
    local x1 = screen.width - math.round(300 * minscale)
    if d > 0 then x1 = math.round(300 * minscale) end
    local y1 = math.round(128 * minscale)
    local x2 = math.round(x1 + d)
    local y2 = screen.height - math.round(150 * minscale)
    local finger = {
      {
        {x = x1, y = y1}, {x = x2, y = y1}, {x = x2, y = y2}, {x = x2, y = y1},
        {x = x2, y = y2}, {x = x2, y = y1}, {x = x2, y = y2}, {x = x2, y = y1},
        {x = x2, y = y2}, {x = x2, y = y1}, {x = x2, y = y2}, {x = x2, y = y1},
      },
    }

    -- TODO:什么情况下用双指滑
    if is_device_swipe_too_fast then table.insert(finger, 1, finger[1]) end
    log(482, finger)

    gesture(finger, duration)
    sleep(duration + delay)
  end
end

-- single swip for chapter navigation
swipc = function(dis)
  if not dis then return end
  local x1, y1, x2, y2
  x1, y1 = math.round((500 - 1920 / 2) * minscale + screen.width / 2),
           screen.height // 2
  x2, y2 = math.round((1500 - 1920 / 2) * minscale + screen.width / 2),
           math.round(100 * minscale)
  local finger = {{{x = x1, y = y1}, {x = x2, y = y1}, {x = x2, y = y2}}}
  duration = 500
  gesture(finger, duration)
  sleep(duration)
end

-- pagedown for operator
swipo = function(left)
  local x1, y1, x2, y2, duration
  x1, y1 = screen.width - math.round(300 * minscale), screen.height // 2
  x2, y2 = max(x1 - math.round(1565 * minscale), 0), screen.height - 1
  duration = 1000
  if left then
    x2 = 10000
    duration = 500
  end
  local finger = {
    {{x = x1, y = y1}, {x = x2, y = y1}, {x = x2, y = y2}, {x = x2, y = y1}},
  }
  table.insert(finger, 1, finger[1])
  log(finger)
  gesture(finger, duration)
  sleep(duration)
end

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
  if retry > 10 then
    -- TODO: 提示到底影响了什么，是不能缩放，还是缩放结束找不到
    log("缩放结束未找到")
    return true
  end
  if not findOne("进驻总览") then return path.跳转("基建") end
  if findOne("缩放结束") then
    log("缩放结束")
    return true
  end
  local finger = {
    {
      {
        x = math.round((1720 - 1920) * minscale + screen.width),
        y = math.round(56 * minscale),
      }, {x = screen.width // 2 - 100, y = math.round(56 * minscale)},
    }, {
      {x = 600, y = math.round(56 * minscale)},
      {x = screen.width // 2 + 100, y = math.round(56 * minscale)},
    },
  }
  local duration = 150
  gesture(finger, duration)

  -- otherwise next zoom will be recognized as tapping, cause flicking
  appear("缩放结束", 0.4)

  return zoom(retry + 1)
end

auto = function(p, fallback, timeout, total_timeout)
  if type(p) == "function" then return p() end
  if type(p) ~= "table" then return true end
  local start_time = time()
  while true do
    if total_timeout and time() - start_time > total_timeout * 1000 then
      return true
    end
    local finish = false
    local check = function()
      for k, v in pairs(p) do
        -- log(k)
        if findOne(k) then
          log(k, "=>", v)
          effective_state = k
          if tap(v) then finish = true end
          return true
        end
      end
    end
    timeout = timeout or 0
    -- timeout = 100
    -- if findAny({"进驻信息", "进驻信息选中"}) then timeout = 3 end
    local e = wait(check, timeout)
    -- stop()
    -- tap true
    if finish then return true end

    -- fallback: tap false or timeout
    if not e and fallback ~= false then
      -- log("auto -> fallback")
      local x = table.findv({
        "返回确认", "返回确认2", "活动公告返回", "签到返回",
        "返回", "返回2", "返回3", "返回4", "活动签到返回",
        "抽签返回", "单选确认框",
      }, findOne)
      if x then
        log(x)
        if table.includes({
          "活动公告返回", "签到返回", "活动签到返回",
          "抽签返回",
        }, x) then
          -- solve 活动签到
          if x == "活动签到返回" and not speedrun then
            for u = math.round(300 * minscale), screen.width -
              math.round(300 * minscale), 200 do
              tap({u, screen.height // 2})
            end
            for v = math.round(300 * minscale), screen.height -
              math.round(300 * minscale), 200 do
              tap({screen.width // 2, v})
            end
          end
          -- solve 抽签
          if x == "抽签返回" and not speedrun then
            for u = math.round(300 * minscale), screen.width -
              math.round(300 * minscale), 200 do
              tap({u, screen.height // 2})
            end
            tap("确定抽取")
          end

          -- deal with everyday popup
          if not wait(function()
            if findOne("面板") then return true end
            tap(x)
            appear("面板", .5)
          end, 10) then return end
        elseif x == "返回确认" then
          leaving_jump = false
          if not wait(function()
            if not findOne("返回确认") then return true end
            if fallback then
              log("tap fallback[x]")
              tap(fallback[x])
              disappear("返回确认", .5)
            else
              tap("右确认")
            end
          end, 10) then return end
          if appear("进驻总览", 1) then leaving_jump = true end

          -- wait(function()
          --   if not findOne(x) then return true end
          --   tap(fallback and fallback[x] or "右确认")
          --   disappear(x, 1)
          --   appear("进驻总览", 2)
          -- end, 10)
        elseif x == "返回确认2" then
          tap("右确认")
        elseif x == "单选确认框" then
          tap("右确认")
        else
          tap(x)
          -- TODO
          log(687, 'tryto fix 基建返回 stuck', x)
          ssleep(.1)
        end
      else
        -- log("no fallback sign found")
        tap()

        --        tap(p.other)
        --        tap("返回")
        --        ssleep(.5)
        --        tap(p["其它"])
      end
      -- wait for fallback
      --      ssleep(.5)
    end
    -- log(495, "end of while")
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

-- run function / job / table of function and job
run = function(...)
  local arg = {...}
  if #arg == 1 then
    if type(arg[1]) == "function" then return arg[1]() end
    if type(arg[1]) == "table" then arg = arg[1] end
  end
  menuConfig({x = 0, y = screen.height})
  logConfig({
    width = math.round(screen.height * .8),
    height = math.round(screen.height * .8),
    mode = 3,
  })
  qqmessage = {' '}
  update_state()
  wait_game_up()
  for _, v in ipairs(arg) do
    menuConfig({x = 0, y = screen.height})
    running = v
    if type(v) == 'function' then
      v()
    else
      auto(path[v])
    end
  end
  if QQ then
    path.跳转("首页")
    captureqqimagedeliver(os.date('%Y.%m.%d %H:%M:%S') .. table.join(qqmessage),
                          QQ)
  end
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
  local max_op_width = math.round(178 * minscale) --  in loose mode, each operator's width
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
  local y1 = screen.height - math.round(90 * maxscale)
  local duration = 300
  local delay = 100
  d = d or 2
  d = ({{0, -1}, {1, 0}, {0, 1}, {-1, 0}})[d]
  d = {d[1] * 500, d[2] * 500}
  local finger = {
    {
      {x = x1, y = y1}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2}, {x = x2, y = y2}, {x = x2 - 10, y = y2},
      {x = x2, y = y2}, {x = x2 - 10, y = y2}, {x = x2, y = y2},
      {x = x2 - 10, y = y2},
    },
  }
  gesture(finger, duration)
  log("deploy", finger)
  sleep(duration + delay)
  finger = {{{x = x2, y = y2}, {x = clamp(x2 + d[1]), y = clamp(y2 + d[2])}}}
  log("deploy", finger)
  gesture(finger, 200)
  sleep(1000)
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
  log((disappear and "dis" or '') .. "appear", target)
  if not (type(target) == 'table' and #target > 0) then target = {target} end
  return wait(function()
    for _, v in pairs(target) do
      if disappear then
        if type(v) == "function" and not v() then
          return v
        elseif type(v) == "table" and #v == 0 and not find(v) then
          return v
        elseif type(v) == "string" and #v > 0 and not findOne(v) then
          return v
        end
      else
        if type(v) == "function" and v() then
          return v
        elseif type(v) == "table" and #v == 0 and find(v) then
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

wait_game_up = function(retry)
  retry = retry or 0
  if retry > 10 then stop("不能启动游戏") end
  local game = R():name(appid):path("/FrameLayout/View")
  local bilibili_wrapper = R():name("com.hypergryph.arknights.bilibili"):path(
                             "/FrameLayout/TextView")
  local bilibili_login = R():id(
                           "com.hypergryph.arknights.bilibili:id/tv_gsc_account_login");
  local bilibili_oneclicklogin = R():id(
                                   "com.hypergryph.arknights.bilibili:id/tv_gsc_record_login")
  local bilibili_ok = R():id("tv.danmaku.bili:id/ok")

  local bilibili_account_login = R():id(
                                   "com.hypergryph.arknights.bilibili:id/iv_gsc_account_login")
  local bilibili_change = R():id(
                            "com.hypergryph.arknights.bilibili:id/tv_gsc_record_login_change")
  local bilibili_change2 = R():id(
                             "com.hypergryph.arknights.bilibili:id/tv_gsc_wel_change")
  local keyguard_indication = R():id(
                                'com.android.systemui:id/keyguard_indication_area')
  local keyguard_input = R():id('com.android.systemui:id/keyguard_host_view')

  local screen = getScreen()
  if screen.width > screen.height and find(game) then return end

  if appid ~= bppid then
    open()
    screenon()
    appear({game, keyguard_indication, keyguard_input}, 5)

  else
    log(961)
    if not appear({
      game, bilibili_wrapper, bilibili_oneclicklogin, bilibili_ok,
      bilibili_account_login, bilibili_change, bilibili_change2,
    }, 1) then
      log(965)
      open()
      screenon()
      appear({game, keyguard_indication, keyguard_input}, 5)
    elseif change_account_mode then
      if find(bilibili_login) then
        return
      elseif find(bilibili_change2) then
        click(bilibili_change2)
        disappear(bilibili_change2)
      elseif find(bilibili_change) then
        click(bilibili_change)
        appear(bilibili_account_login)
      elseif find(bilibili_account_login) then
        click(bilibili_account_login)
        appear(bilibili_login)
      end
    elseif find(bilibili_account_login) then
      click(bilibili_account_login)
      appear(bilibili_login)
    elseif find(bilibili_login) then
      local username_inputbox = R():id(
                                  "com.hypergryph.arknights.bilibili:id/et_gsc_account");
      local password_inputbox = R():id(
                                  "com.hypergryph.arknights.bilibili:id/et_gsc_account_pwd");
      input(username_inputbox, username)
      input(password_inputbox, password)
      click(bilibili_login)
      appear(game, 5)
    elseif find(bilibili_oneclicklogin) then
      click(bilibili_oneclicklogin)
      appear(bilibili_ok, 5)
    elseif find(bilibili_ok) then
      click(bilibili_ok)
      appear(game, 5)
    elseif find(bilibili_wrapper) then
      retry = retry - 1
    end
  end
  if find(keyguard_indication) then
    if not wait(function()
      if not find(keyguard_indication) then return true end
      local height = max(screen.width, screen.height)
      local width = min(screen.width, screen.height)
      gesture({
        {
          {x = width // 2, y = math.round(height * .75)},
          {x = width // 2, y = 1},
        },
      }, 1000)
      sleep(1500)
    end, 5) then stop("解锁失败1004") end
  elseif find(keyguard_input) then
    local unlock_gesture = JsonDecode(get('unlock_gesture', '{}'))
    local unlock_mode = JsonDecode(get('unlock_mode', '"手势"'))
    unlock(unlock_gesture, unlock_mode == '手势')
    if not disappear(keyguard_input) then stop("解锁失败1005") end
  end

  log("wait_game_up next", retry)
  return wait_game_up(retry + 1)
end

bilibili_login_hook = function()
  if appid ~= bppid then return end
  local login = R():id(
                  "com.hypergryph.arknights.bilibili:id/bsgamesdk_buttonLogin");
  if not appear(login, 1) then return end
  local username_inputbox = R():id(
                              "com.hypergryph.arknights.bilibili:id/bsgamesdk_edit_username_login");
  local password_inputbox = R():id(
                              "com.hypergryph.arknights.bilibili:id/bsgamesdk_edit_password_login");
  input(username_inputbox, username)
  input(password_inputbox, password)
  click(login)
end

miui_hook = function()
  local miui = R():text("立即开始"):type("Button")
  if not wait(function()
    if not find(miui) then return true end
    click(miui)
  end, 10) then stop("不能消去立即开始") end
end

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
      rect = {
        math.round(616 * minscale), math.round(107 * minscale),
        screen.width - 1, screen.height - 1,
      },
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
    -- ocr_fast(math.round(minscale * r[1]), math.round(minscale * r[2]),
    --          math.round(minscale * r[3]), math.round(minscale * r[4]))
    for _, r in pairs(region) do
      local text, info
      text, info = ocr_fast(math.round(minscale * r[1]),
                            math.round(minscale * r[2]),
                            math.round(minscale * r[3]),
                            math.round(minscale * r[4]))
      if text then
        log(text, info, r)
        for _, w in pairs(info.words) do
          if operator_notfound[w.word] then
            log('found', w.word)
            tap({
              math.round(r[1] * minscale) + w.rect.left,
              math.round(r[2] * minscale) + w.rect.top,
            })
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

findtap_operator_type = function(type)
  swipo(true)
  tap("清空选择")
  ssleep(2)
  log('type', type)
  local 经验加速 = {
    '#261500-50',
    '[{"a":0.129,"d":1.622,"id":"1","r":529.0,"s":"34|5<fOm>&5~9zPN&5~amm]&5>Yg}@&5]8m]^&5X[L$H&5X[L$H&5X[L$X&5>xRmv&5<quBx&5>GERF&5>GERE&5X[L$Y&5X[Npu&5X[Npu&5Y6o!c&5>YhCE&5~a15*&5~9z^6&5~9z^6&2~zjVe"}]',
    0.85,
  }
  local 赤金加速 = {
    '#202020-50',
    '[{"a":-0.044,"d":1.807,"id":"1","r":358.0,"s":"22|py&PS&PS&PS&H6!&18dN&18dN&18dM&18dM&2OY&2OY&2LC&2LC&2gre&4wSA&8{v2&8{v2&4wSs&aL6&ax~&ax~&lgc&k]*&k]*&lGs&H6!&H6!&H6!&18dM&H6Y"}]',
    0.85,
  }
  if type == '经验站' then
    type = 经验加速
  elseif type == "赤金站" then
    type = 赤金加速
  end
  -- swip 3 times only
  for i = 1, 3 do
    if i ~= 1 then swipo() end

    local candidate = findShape(type)
    if candidate then
      log(11777, #candidate)
      local p = {}
      for j, c in pairs(candidate) do
        -- 宽度不超过
        if c['x'] < 1920 * minscale then
          table.insert(p, 'candidates' .. j)
          point['candidates' .. j] = {c['x'], c['y']}
        end
      end
      if #p > 0 then
        tapAll(p)
        ssleep(.1)
      end
    end
  end
  swipo(true)
end

timeit = function(f)
  local start = time()
  f()
  log(time() - start)
end

tapAll = function(ks)
  log("tapAll", ks)

  -- 100时仍然可能不按序，试试200
  local duration = 200 -- 1 漏 20漏 50 漏 1000可以，问题还是在前一步
  if speedrun then duration = 100 end
  local finger = {}
  for _, k in pairs(ks) do
    table.insert(finger, {{x = point[k][1], y = point[k][2]}})
  end
  -- log(finger)
  gesture(finger, duration)
  sleep(duration)
end

captureqqimagedeliver = function(info, to)
  toast("正在通知QQ：" .. info)
  io.open(getDir() .. '/.nomedia', 'w')
  local img = getDir() .. "/tmp.jpg"
  capture(img, 30)
  local req = {
    url = "http://a1.bilabila.tk:49875",
    param = {image = base64(img), info = tostring(info), to = tostring(to)},
    timeout = 20,
  }
  httpPost(req)
end

poweroff = function() exec('reboot -p') end
closeapp = function() exec("am force-stop " .. appid) end
screenoff = function() exec('input keyevent 223') end
screenon = function() exec('input keyevent 224') end

unlock = function(route, swip_mode)
  log('unlock', route, swip_mode)
  -- 手势或密码，通过catchClick录入
  if swip_mode then
    local finger = {}
    for _, p in pairs(route) do table.insert(finger, {x = p[1], y = p[2]}) end
    log(finger)
    gesture({finger}, 3000)
    ssleep(3)
  else
    for _, p in pairs(route) do
      tap(p, true, true)
      ssleep(.5)
    end
  end
  ssleep(1)
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
    if _G[prefix .. i] then table.insert(ans, reference[i]) end
  end
  return ans
end

all_job = {
  "邮件收取", "轮次作战", "访问好友", "基建收获",
  "指定换班", "基建换班", "线索搜集", "制造加速",
  "副手换人", "信用购买", "公招刷新", "任务收集",
}

now_job = {
  "邮件收取", "轮次作战", "访问好友", "基建收获",
  "指定换班", "基建换班", "线索搜集", "制造加速",
  "副手换人", "信用购买", "公招刷新", "任务收集",
}

make_account_setting_ui = function(prefix)
  print(1327)
  prefix = prefix or ''
  local ui = {
    {
      type = 'div',
      ore = 1,
      views = {
        {type = 'text', value = '作战：'}, {
          type = 'edit',
          value = [[当期委托 dwqt 龙门市区 LMSQ
9-19 4-4 4-9 JT8-3 PR-D-2 CE-5 LS-5
 上一次 syc]],
          id = prefix .. 'fight',
        },
      },
    }, {
      type = 'div',
      ore = 1,
      views = {
        {type = 'text', value = '最多吃'},
        {type = 'edit', value = '9999', id = prefix .. 'max_drug_times'},
        {type = 'text', value = '次药和'},
        {type = 'edit', value = '0', id = prefix .. 'max_stone_times'},
        {type = 'text', value = '次石头'},
      },
    }, {
      type = 'div',
      ore = 1,
      views = {
        {type = 'text', value = '指定换班(待设计)：'},
        {type = 'edit', value = [[]], id = prefix .. 'dorm'},
      },
    }, {
      type = 'div',
      ore = 1,
      views = {
        {type = 'text', value = '换班优先'}, {
          type = 'radio',
          value = '工作状态|*技能',
          id = prefix .. 'prefer_skill',
          ore = 1,
        },
      },
    }, {
      type = 'div',
      ore = 1,
      views = {
        {type = 'text', value = '自动招募'}, {
          type = 'check',
          value = '*小车|*4星|5星|6星',
          id = table.join(map(function(i)
            return prefix .. 'auto_recruit' .. i
          end, {1, 4, 5, 6}), '|'),
          ore = 1,
        },
      },
    }, {
      type = "check",
      ore = 1,
      value = parse_value_to_ui(all_job, now_job),
      id = parse_id_to_ui(prefix .. "now_job_ui", #all_job),
    },
  }
  -- log(1388)
  -- log(ui)
  return ui
end

make_multi_account_setting_ui = function()
  -- local inherit_setting_selection = 
  local ui = {
    name = 'main',
    title = "多账号",
    submit = {type = "text", value = "保存"},
    cancle = {type = "text", value = "退出"},
    views = {
      {
        type = 'div',
        views = {
          {
            type = 'check',
            value = '*多账号模式总开关',
            id = 'multi_account',
          },
        },
      }, {
        type = 'div',
        views = {
          {
            ore = 1,
            type = 'check',
            value = table.join(map(function(i) return '*账号' .. i end,
                                   range(1, 20)), '|'),
            id = table.join(map(function(i)
              return 'multi_account' .. i
            end, range(1, 20)), '|'),
          },
        },
      },
    },
  }

  for i = 1, 20 do
    -- 基本设置
    table.insert(ui.views, {
      type = 'edit',
      title = '账号' .. i,
      id = 'username' .. i,
      value = '',
    })
    table.insert(ui.views, {
      type = 'edit',
      title = '密码' .. i,
      id = 'password' .. i,
      value = '',
    })
    table.insert(ui.views, {
      type = 'div',
      views = {
        {type = 'text', value = '服务器' .. i},
        {type = 'radio', value = '*官服|B服', id = 'server' .. i, ore = 1},
      },
    })

    -- 详细设置
    if get("multi_account_new_setting" .. i, 0) == 0 then
      table.insert(ui.views, {
        type = 'div',
        ore = 1,
        views = {
          {type = "text", value = "账号" .. i .. "使用"}, {
            type = "spinner",
            value = "默认" .. (i > 1 and "|" or '') ..
              table.join(
                map(function(j) return "账号" .. j end, range(1, i - 1)), '|'),
            id = "multi_account_inherit_setting" .. i,
          }, {type = "text", value = "设置"}, {
            type = "button",
            value = "切换为独立设置",
            title = '',
            click = {thread = 0, name = "multi_account_new_setting" .. i},
          },
        },
      })
    else
      table.insert(ui.views, {
        type = 'div',
        ore = 1,
        views = {
          {type = "text", value = "账号" .. i .. "使用独立"},
          {type = "text", value = "设置"}, {
            type = "button",
            value = "切换为默认设置",
            title = '',
            click = {thread = 0, name = "multi_account_new_setting" .. i},
          },
        },
      })

      for _, x in pairs(make_account_setting_ui("multi_account_user" .. i)) do
        -- log(x)
        table.insert(ui.views, x)
      end

    end
  end
  return ui
end

transfer_global_variable = function(prefix)
  local t
  for k, v in pairs(_G) do
    if k:startsWith(prefix) then
      _G[k.substr(#prefix)], _G[k] = v, _G[k.substr(#prefix)]
    end
  end
end
