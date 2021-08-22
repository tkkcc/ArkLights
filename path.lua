path = {}
path.base = {
  面板 = true,
  下载资源确认 = "下载资源确认",
  start黄框 = function() wait(function() tap("start黄框") end) end,
  start黄框暗 = function() wait(function() tap("start黄框") end) end,
  账号登录 = "账号登录",
  开始唤醒 = "开始唤醒",
  手机验证码登录 = function()
    local inputbox = R():type("EditText"):name(appid):path(
                       "/FrameLayout/EditText")
    local ok = R():type("Button"):name("com.hypergryph.arknights"):path(
                 "/FrameLayout/Button")
    if #username > 0 then
      if not wait(function()
        if not findOne("手机验证码登录") then return true end
        tap("账号左侧")
        tap("账号")
        disappear("手机验证码登录", .5)
      end, 5) then return end
      if not appear(inputbox) or not appear(ok) then stop("登录失败") end
      input(inputbox, username)
      click(ok)
      if not appear("手机验证码登录") then stop("登录失败") end
    end
    if #password > 0 then
      if not wait(function()
        if not findOne("手机验证码登录") then return true end
        tap("账号左侧")
        tap("密码")
        disappear("手机验证码登录", .5)
      end, 5) then return end
      if not appear(inputbox) or not appear(ok) then stop("登录失败") end
      input(inputbox, password)
      click(ok)
      if not appear("手机验证码登录") then stop("登录失败") end
    end
    if not wait(function()
      if findAny({"用户名或密码错误", "密码不能为空"}) then
        stop("登录失败")
      end
      tap("登录")
    end, 5) then return end
  end,
  正在释放神经递质 = function()
    if not disappear("正在释放神经递质", 60 * 60, 1) then
      stop("正在释放神经递质")
    end
  end,
  接管作战 = function()
    if not disappear("接管作战", 60 * 60, 1) then stop("接管作战") end

    -- this calllback only works for 主线、资源、剿灭
    if not wait(function()
      if findOne("开始行动") then return true end
      if findOne("接管作战") then return true end
      tap("开始行动")
      appear({"开始行动", "接管作战"}, 1)
    end, 30) then return end

    if findOne("接管作战") then return path.base.接管作战() end
    log(89, repeat_fight_mode)
    if repeat_fight_mode then return path.开始游戏('', true) end

    -- current fight success
    pre_fight = cur_fight

    -- if same fight or same page fight
    local next_fight_tick = fight_tick % #fight + 1
    local next_fight = fight[next_fight_tick]
    log(cur_fight, next_fight)

    if next_fight == cur_fight then
      fight_tick = next_fight_tick
      pre_fight = nil
      return path.开始游戏(next_fight)
    elseif same_page_fight(cur_fight, next_fight) then
      if not wait(function()
        if not findOne("开始行动") then return true end
        tap("主页右侧")
      end, 20) then return end
      -- TODO how to ignore this sleep
      -- ssleep(.5)
      -- 只有主线与物资芯片会存在same_page_fight，
      -- 物资芯片的appear是完备的，
      local x = get_fight_type(cur_fight)
      if x == "物资芯片" then
        appear("作战列表" .. cur_fight, .5)
      elseif x == "主线" then
        local x0 = cur_fight
        local chapter = x0:find("-")
        chapter = x0:sub(1, chapter - 1)
        chapter = chapter:sub(chapter:find("%d"))
        local chapter_index = tonumber(chapter) + 1
        appear("当前进度列表" .. chapter_index, .5)
      else
        log("unexpected same page fight wait")
        ssleep(.5)
      end
    end
  end,
}

path.邮件收取 = function()
  path.跳转("邮件")
  local state = sample("邮件提示")
  log(state)
  if not wait(function()
    if not findOne(state) then return true end
    tap("收取所有邮件")
  end, 5) then return end
end

path.基建收获 = function()
  -- jump without zoom
  path.跳转("基建", nil, true)

  local x

  -- 认为线索搜集提示弹出前一定能看到灯泡，但进入基建后灯泡需要一会儿才会出现
  -- 1s不够
  x = appear({"基建灯泡蓝", "基建灯泡蓝2"}, 2)
  log(103)
  -- 没看到灯泡或线索提示
  if not x then
    leaving_jump = true
    log(106)
    return
  end

  -- 唤出待办事项
  wait(function()
    if findOne("待办事项") then
      if not disappear("待办事项", .2) then return true end
    end
    if findOne("进驻总览") then
      tap(x)
      disappear("进驻总览", .2)
    end
  end, 5)

  wait(function()
    local y = appear({
      "点击全部收取", "小蓝圈", "正在提交反馈至神经",
      "进驻总览",
    }, 2)
    log(147, y)
    if not y or y == "小蓝圈" or y == "进驻总览" then return true end
    tap("点击全部收取")
  end, 10)

  -- 回到进驻总览
  if not wait(function()
    if findOne("进驻总览") then return true end
    tap("基建右上角")
  end, 5) then return end
  leaving_jump = true
end

prev_jump = "基建"
path.跳转 = function(x, disable_quick_jump, disable_postprocess)
  local sign = {
    好友 = "个人名片",
    基建 = function()
      return findOne("进驻总览") and not findOne("任务第一个")
    end,
    公开招募 = function()
      return findOne("公开招募") and findOne("公开招募箭头")
    end,
    首页 = "面板",
    干员 = "干员界面",
    采购中心 = "可露希尔推荐",
    任务 = "任务第一个",
    终端 = "主页",
    邮件 = function()
      return (findOne("邮件信封") and findAny({"返回3", "返回4"}))
    end,
  }
  local plain = {
    邮件 = "面板邮件",
    好友 = "面板好友",
    干员 = "面板干员",
    基建 = "面板基建",
    公开招募 = "面板公开招募",
    首页 = nil,
    采购中心 = "面板采购中心",
    任务 = "面板任务",
    终端 = "面板作战",
  }
  local timeout = (x == "基建" or prev_jump == "基建") and 20 or 20
  if prev_jump == "采购中心" then timeout = 20 end

  local target = sign[x]
  local home_target = x == "邮件" and "首页" or x

  -- direct quit
  if findOne(target) then
    log("before zoom", x)
    if x == "基建" and not disable_postprocess then zoom() end
    prev_jump = x
    repeat_fight_mode = false
    leaving_jump = false
    return true
  end

  local bypass = function(t)
    log("bypass 基建返回确认", prev_jump)
    if prev_jump == "基建" and appear({"返回确认", t}) == "返回确认" then
      if not wait(function()
        if not findOne("返回确认") then return true end
        tap("右确认")
      end, 5) then return end
    end
    log("bypass 基建返回确认", "end")
    return true
  end
  local p
  p = update(path.base, {
    面板 = function()
      p["主页"] = nil
      tap(plain[x])
      log(208)
      appear({
        target, "活动公告返回", "签到返回", "活动签到返回",
        "抽签返回",
      }, timeout)
      log(209)
    end,
    主页 = function()
      p["主页"] = nil
      local expand = false
      if not wait(function()
        -- if expand and findAny({"主页", "主页按过"}) then return true end
        -- if not findOne("主页") and not findOne("主页按过") then expand = true end
        local y = findAny({"主页", "主页按过"})
        tap(y)
        if not y or disappear(y, .5) then
          if home_target == "任务" or home_target == "好友" then
            ssleep(.1)
          end
          wait(function() tap("主页列表" .. home_target) end, .1)
          return true
        end
      end, 5) then return end

      -- if not wait(function()
      --   if findOne("主页列表展开") and
      --     not disappear("主页列表展开", .05) then
      --     tap("主页列表" .. home_target)
      --     if disappear("主页列表展开") then return true end
      --   end
      --   if findTap({"主页", "主页按过"}) then
      --     appear("主页按下", .5)
      --   end
      -- end, 10) then return end
      if not bypass(sign[home_target]) then return end
      log('wait appear', sign[home_target], timeout)
      -- appear(sign[home_target], timeout)
      -- TODO appear all?
      appear(table.values(sign), timeout)
    end,
  })
  if x == prev_jump and x ~= "首页" or disable_quick_jump then p.主页 = nil end
  p[target] = function()
    if prev_jump == "基建" and x == "基建" and not leaving_jump then
      tap('返回')
      disappear(target)
      return
    end

    -- leaving_jump is true means we don't need to wait 1 seconds to ensure current state is 进驻总览
    -- leaving_jump will be true if the previous state is 返回确认, and we slow tap 返回 (0.5s interval)
    -- leaving_jump will be also true if previous job confirm it
    log("leaving_jump", leaving_jump)
    local t = very_slow_state_check and 10 or 1
    if not disappear(target, (prev_jump == "基建" and x == "基建" and
                       not leaving_jump) and t or 0) then
      leaving_jump = false
      log("found", target)
      return true
    end
  end

  local fallback = {返回确认 = "右确认"}
  if x == "基建" then fallback.返回确认 = function() back() end end
  auto(p, fallback)

  -- post processing especially for 基建
  if x == "基建" and not disable_postprocess then zoom() end

  prev_jump = x

  -- disable repeat fight after any jump complete
  repeat_fight_mode = false
end

start_time = parse_time("202101010400")
update_state_last_day = 0
update_state_last_week = 0
communication_enough = false
jmfight_enough = false
zero_san = false
repeat_fight_mode = true

update_state = function()
  zero_san = false

  local day = (parse_time() - start_time) // (24 * 3600)
  if day == update_state_last_day then return end
  communication_enough = false
  update_open_time()

  local week = (parse_time() - start_time) // (7 * 24 * 3600)
  if week == update_state_last_week then return end
  jmfight_enough = false
end

path.副手换人 = function()
  path.跳转("基建")

  if not wait(function()
    if not findOne("进驻总览") then return true end
    tap("控制中枢")
  end, 5) then return end
  if not appear({"进驻信息", "进驻信息选中"}) then return end
  if not wait(function()
    if not findAny({"进驻信息", "进驻信息选中"}) then return true end
    tap("基建副手")
  end, 5) then return end

  for i = 1, 5 do
    if not wait(function()
      -- if findOne("副手确认蓝") then return true end
      if not findOne("基建副手简报") then return true end
      tap("基建副手列表" .. i)
    end, 5) then return end



    if not findOne("干员未选中") then
      tap("干员选择列表1")
      if not appear("干员未选中", .5) then return end
    end
    local state = sample("信赖")
    tap("信赖")
    log("state", state)
    disappear(state)
    state = sample("信赖")
    tap("信赖")
    disappear(state)
    if not wait(function()
      if not findOne("干员未选中") then return true end
      tap("干员选择列表" .. i)
      disappear("干员未选中", .5)
    end, 5) then return end
    if not wait(function()
      if findOne("基建副手简报") then return true end
      tap("副手确认蓝")
    end, 5) then return end
  end
end

sample = function(v)
  local ans = ''
  for _, p in pairs(point[v .. "采样列表"]) do
    -- log(297, p)
    p = point[p]
    -- log(298, p)
    ans = ans .. p[1] .. ',' .. p[2] .. ',' .. getColor(table.unpack(p)).hex ..
            '|'
  end
  point.sample = ans:sub(1, #ans - 1)
  rfl.sample = point2region(point.sample)
  -- log("采样", point.sample)
  return "sample"
end

path.基建换班 = function()
  -- 宿舍换班 4间
  local f
  f = function(i)
    path.跳转("基建")
    if not wait(function()
      if not findOne("进驻总览") or not findOne("缩放结束") then
        return true
      end
      tap("宿舍列表" .. i)
    end, 10) then return end
    if not appear({"进驻信息", "进驻信息选中"}, 5) then return end
    if not wait(function()
      if findOne("确认蓝") then return true end
      if findOne("进驻信息选中") then
        wait(function()
          if findOne("确认蓝") then return true end
          tap("进驻第一人")
        end, 1)
      elseif findOne("进驻信息") then
        tap("进驻信息")
        ssleep(.2)
        wait(function()
          if findOne("确认蓝") then return true end
          tap("进驻第一人")
        end, 1)
      end
    end, 5) then return end
    if not wait(function()
      if findOne("干员未选中") then return true end
      tap("清空选择")
    end, 5) then return end
    local state = sample("心情")
    tap("心情")
    disappear(state, 1)
    state = sample("心情")
    tap("心情")
    disappear(state, 1)
    for j = 1, 6 do tap("干员选择列表" .. j) end

    if not wait(function()
      if findAny({"隐藏", "进驻信息", "进驻信息选中"}) then
        return true
      end
      tap("确认蓝")
    end, 5) then return end
  end
  if not no_dorm then for i = 1, 4 do f(i) end end

  -- no doing this any more
  -- if 1 then return end

  -- 进驻总览 查漏补缺
  path.跳转("基建", nil, true)
  if not wait(function()
    if findOne("撤下干员") then return true end
    tap("进驻总览")
  end, 10) then return end

  local swipd = function()
    local duration = 500
    local delay = 0
    local y1 = screen.height - math.round(200 * minscale)
    local x1 = math.round((1680 - 1920) * minscale) + screen.width
    local x2 = math.round((680 - 1920) * minscale) + screen.width
    local y2 = math.round(150 * minscale)
    log(x1, y1, x2, y2)
    local paths = {{{x = x1, y = y1}, {x = x1, y = y2}}}
    log(paths)
    gesture(paths, duration)
    sleep(duration + delay)
    tap("入驻干员右侧")
    sleep(200)
  end

  local first_look = true
  f = function()
    local timeout = first_look and .5 or 0
    first_look = false
    if not appear("入驻干员", timeout) then return end
    if not wait(function()
      if findOne("确认蓝") then return true end
      if findTap("入驻干员") then appear("确认蓝") end
    end, 10) then return end

    local limit = findOne("清空选择") and 6 or 1

    if not wait(function()
      if findOne("筛选取消") then return true end
      tap("筛选")
    end, 5) then return end
    if not wait(function()
      if not findOne("筛选未进驻") then return true end
      tap("筛选未进驻")
      disappear("筛选未进驻", .5)
    end, 5) then return end

    if prefer_skill then
      if not wait(function()
        if not findOne("筛选技能") then return true end
        tap("筛选技能")
        disappear("筛选技能", .5)
      end, 5) then return end
    end

    if not wait(function()
      if findOne("确认蓝") then return true end
      tap("筛选确认")
      appear("确认蓝")
    end, 5) then return end

    if not wait(function()
      if findOne("干员未选中") then return true end
      tap("清空选择")
    end, 5) then return end
    for j = 1, limit do tap("干员选择列表" .. j) end
    if not wait(function()
      if findOne("撤下干员") then return true end
      tap("确认蓝")
    end, 5) then return end
    return true
  end

  local bottom = sample("进驻总览底部")
  local reach_bottom = false
  for i = 1, 15 do
    if i ~= 1 then
      swipd()
      if not findOne(bottom) then reach_bottom = true end
    end
    while f(i) do log(475) end
    if reach_bottom then break end
  end
  if not findOne("撤下干员") then return end
  tap("返回")
  if appear("进驻总览") then leaving_jump = true end
end

path.制造加速 = function()
  path.跳转("基建")
  local station
  for i = 1, #point.基建左侧列表 do
    local x, y = table.unpack(point["基建左侧列表" .. i])
    if compareColor(x, y, "#FFCC00", 99) then
      station = x .. coord_delimeter .. y .. coord_delimeter .. "#FFCC00"
      point.station = station
      rfl.station = true
      break
    end
  end
  log(526)
  if not station then return end
  log(station)
  if not wait(function()
    if not findOne("进驻总览") or not findOne("缩放结束") then
      return true
    end
    tap("station")
  end, 5) then return end
  -- if not appear({"进驻信息", "进驻信息选中"}) then return end
  if not wait(function()
    if findOne("制造站加速") then return true end
    tap("制造站进度")
  end, 5) then return end
  -- if not appear("制造站加速") then return end

  if not wait(function()
    if findOne("无人机加速") then return true end
    tap("制造站加速")
  end, 5) then return end

  -- appear("无人机加速加", .5)
  wait(function()
    if not findOne("无人机加速加") then return true end
    tap("无人机加速最大")
  end)

  if not wait(function()
    if findOne("制造站加速") then return true end
    tap("无人机加速确定")
  end, 5) then return end

  tap("制造站收取")
end

path.线索搜集 = function()
  path.跳转("基建")

  if not wait(function()
    if not findOne("进驻总览") or not findOne("缩放结束") then
      return true
    end
    tap("会客厅")
    disappear("进驻总览", 2)
  end, 5) then return end
  if not appear({"进驻信息", "进驻信息选中"}) then return end
  if not wait(function()
    if findOne("线索传递") then return true end
    tap("制造站进度")
  end, 10) then return end

  -- goto a controllable state
  if not wait(function()
    if not findOne("线索传递") then return true end
    tapCard("线索布置列表1")
  end, 5) then return end

  if not wait(function()
    if findOne("线索传递") then return true end
    tap("解锁线索上")
    if findOne("本次线索交流活动") then
      tap("返回")
      -- 只能用返回必须等待
      disappear("本次线索交流活动", .5)
    end
  end, 5) then return end

  log(588)
  --  TODO may be overlaped by notification
  if findOne("接收线索有") then
    if not wait(function()
      if not findOne("线索传递") then return true end
      tap("接收线索有")
    end, 5) then return end
    appearTap("全部收取")
    if not wait(function()
      if findOne("线索传递") then return true end
      tap("解锁线索上")
    end, 5) then return end
  end

  log(501)
  local f
  f = function()
    if not wait(function()
      if findOne("信用奖励返回") then return true end
      tap("信用奖励有")
    end, 5) then return end

    if not appear("未达线索上限", .05) then
      tap("返回")
      appear("线索传递")
      clue_unlocked = false
      path.线索布置()
      if not clue_unlocked then path.线索传递() end
      return f()
    end

    if findOne("信用奖励领取") then
      if not wait(function()
        if findOne("线索传递") then return true end
        tap("信用奖励领取")
      end, 5) then return end
    else
      tap("返回")
    end
    if not appear("线索传递") then return end
    return true
  end
  if not f() then return end
  if not appear("线索传递") then return end
  path.线索布置()
  -- if not appear("线索传递") then return end
  -- path.访问好友()
end

-- tap with offset -50,50
tapCard = function(k)
  local x, y = point[k]:match("(%d+),(%d+)")
  tap({tonumber(x) - 50, tonumber(y) + 50})
end

path.线索布置 = function()
  -- internal
  if not findOne("线索传递") then
    log("线索布置未找到线索传递")
    return
  end
  log(643)
  -- TODO need wait: yes!
  -- that is find"线索传递"
  local p = appear(point.线索布置列表, .5)
  -- local p = findAny(point.线索布置列表)

  log(644)
  if p then
    log(645)
    if not wait(function()
      if not findOne(p) then return true end
      tapCard(p)
      disappear(p)
    end, 5) then return end
    log(646)
    if not appear("线索布置左列表" .. p:sub(#p)) then return end
    log(647)

    for i = 1, 7 do
      if findOne("线索布置左列表" .. i) then
        p = "线索布置左列表" .. i
        -- TODO: half seconds should be enough?
        if not wait(function()
          if findOne("线索布置按下列表" .. i) then return true end
          tapCard(p)
        end, 1) then return end

        if not wait(function()
          if not findOne(p) then return true end
          tap("线索库列表1")
          -- we must wait network
          disappear(p, 5)
        end, 50) then return end
      end
    end
    log(648)
    if not wait(function()
      if findOne("线索传递") then return true end
      tap("解锁线索上")
    end, 5) then return end
  end

  if findTap("解锁线索") then
    clue_unlocked = true
    if not appear({"进驻信息", "进驻信息选中"}, 5) then
      return path.线索搜集()
    end

    if not wait(function()
      if findOne("线索传递") then return true end
      tap("制造站进度")
    end, 10) then return path.线索搜集() end
    return path.线索布置()
  end
end

path.线索传递 = function()
  -- internal
  if not findTap("线索传递") then return end
  if not appear("线索传递数字列表8", 5) then return end

  for i = 1, 8 do
    if not wait(function()
      if findOne("线索传递数字列表" .. i) then return true end
      tap("线索传递数字列表" .. i)
    end, 5) then return end
    log(653)
    if findOne("线索传递数字重复") then break end
    log(654)
  end
  tap("线索列表1")

  local f = function(random)
    local idx
    if random then
      tap("线索传递左白")
      idx = math.random(4)
    else
      local ps = findAll("线索传递橙框")
      if ps then
        for _, p in pairs(ps) do
          local i = 1
          for j = 1, 4 do
            if p.y < point["传递列表" .. j][2] then
              i = j
              break
            end
          end
          if findOne("今日登录列表" .. i) then
            idx = i
            break
          end
        end
      end
    end

    if idx then
      log("线索传递", idx, point.传递列表[idx])
      tap(point.传递列表[idx])
      wait(function()
        if findOne("线索传递") then return true end
        tap("线索传递返回")
      end, 5)
      return true
    end
  end
  if not wait(function()
    if f() then return true end
    if not appear({"线索传递右白", "线索传递右白2"}, .5) then
      f(true)
      return true
    end
    local state = sample("好友")
    tap("线索传递右白")
    disappear(state, .5)
  end, 5) then return end
end

path.任务收集 = function()
  path.跳转("任务")

  if speedrun then
    -- 只保留日常任务
    point.任务有列表 = {point.任务有列表[3]}
    point.任务有列表1 = point.任务有列表3
  end

  for i = 1, #point.任务有列表 do
    if findOne("任务有列表" .. i) then

      -- nagivate to tab
      if not wait(function()
        if findOne("收集全部") then return true end
        tap("任务有列表" .. i)
      end, 10) then return end

      -- tap collect
      if not wait(function()
        if not findTap("收集全部") then return true end
      end, 5) then return end

      -- wait for popup
      disappear("任务有列表" .. i, 10)
      if disappear("主页", 1) then
        if not wait(function()
          if findOne("主页") then return true end
          tap("任务有列表" .. i)
        end, 5) then return end
        -- wait 0.5 for next
        appear(point["任务有列表"], .5)
      end
    end
  end
end

path.信用购买 = function()
  path.跳转("采购中心")
  if not wait(function()
    if findOne("信用交易所") then return true end
    tap("信用交易所2")
  end, 10) then return end
  if findOne("收取信用有") then
    local f = function()
      if not wait(function()
        if not findOne("信用交易所") then return true end
        tap("收取信用有")
      end, 5) then return end
      if not wait(function()
        if findOne("信用交易所") then return true end
        tap("收取信用有")
      end, 5) then return end
    end
    f()
  end
  local f
  f = function(i)
    local enough
    if not findOne("信用交易所") then

      log(831)
      return
    end
    local x = "信用交易所列表" .. i
    if not findOne(x) then return end

    if not wait(function()
      if not findOne(x) then return true end
      tap(x)
      -- TODO check if this is slow
      disappear(x)
    end, 5) then return end

    if not appear("购买物品", 5) then return end
    if not appear("购买物品面板") then return end
    if not wait(function()
      if not findOne("购买物品面板") then return true end
      if findOne("信用不足") then
        log("信用不足")
        enough = true
        return true
      end
      tap("购买物品")
    end, 10) then return end
    if enough then return true end

    -- wait for popup
    appear("信用交易所", 5)
    disappear("信用交易所", 5)
    if not wait(function()
      if findOne("信用交易所") then return true end
      tap("信用交易所2")
    end, 5) then
      log(832)
      return
    end
  end
  if speedrun then return f(2) end
  for i = 1, 10 do if f(i) then break end end
end

get_fight_type = function(x)
  local f = startsWithX(x)
  if table.any({"PR", "CE", "CA", "AP", "LS", "SK"}, f) then
    return "物资芯片"
  elseif table.any(table.keys(jmfight2area), f) then
    return "剿灭"
  else
    return "主线"
  end
end

same_page_fight = function(pre, cur)
  if type(pre) ~= 'string' or type(cur) ~= 'string' then return end
  -- pattern before last - should be same
  -- PR-A-1 == PR-A-2, PR-A-1 != PR-A-2
  if pre:gsub("(.*)-.*$", "%1") == cur:gsub("(.*)-.*$", "%1") then
    log("same page fight", pre, cur)
    return true
  end

  -- number before last - should be same
  if pre:gsub(".*(%d+)-.*$", "%1") == cur:gsub(".*(%d+)-.*$", "%1") then
    log("same page fight", pre, cur)
    return true
  end

  log("not same page fight", pre, cur)
end

fight_tick = 0
no_success_one_loop = 0
path.轮次作战 = function()
  if #fight == 0 then return true end
  path.跳转("首页")
  pre_fight = nil
  no_success_one_loop = 0
  while not zero_san do
    fight_tick = fight_tick % #fight + 1
    if fight_tick == 1 then
      no_success_one_loop = no_success_one_loop + 1
      if no_success_one_loop > 10 then break end
    end
    cur_fight = fight[fight_tick]
    log(971)
    if not same_page_fight(pre_fight, cur_fight) then path.跳转("首页") end
    log(820, fight, fight_tick)
    pre_fight = nil
    path.作战(fight[fight_tick])
  end
end

jianpin2name = {
  JSCK = "积水潮窟",
  CMHB = "潮没海滨",
  LMSQ = "龙门市区",
  LMWH = "龙门外环",
  QENBG = "切尔诺伯格",
  BYBFFC = "北原冰封废城",
  DQSLJW = "大骑士领郊外",
  FQKQ = "废弃矿区",
}

path.作战 = function(x)
  log(table.values(jmfight2name), x)
  local f = startsWithX(x)
  if table.any({"PR", "CE", "CA", "AP", "LS", "SK"}, f) then
    path.物资芯片(x)
  elseif table.any(table.values(jianpin2name), f) then
    path.剿灭(x)
  else
    path.主线(x)
  end
end

path.开始游戏 = function(x, disable_ptrs_check)
  log("开始游戏", fight_tick, x)
  if not findOne("开始行动") then return end
  if x == "1-11" then return auto(path["1-11"]) end
  if is_jmfight_enough(x) then return end
  if not disable_ptrs_check and not appear("代理指挥开", .2) then
    if not wait(function()
      if findOne("代理指挥开") and not disappear("代理指挥开", .2) then
        return true
      end
      tap("代理指挥开")
      appear("代理指挥开", .5)
    end, 5) then return end
  end

  -- quick tap .5s
  wait(function()
    if not findOne("代理指挥开") then return true end
    tap("开始行动蓝")
  end, .5)

  local state = nil
  if not wait(function()
    state = findAny({
      "开始行动红", "源石恢复理智取消", "药剂恢复理智取消",
    })
    if state == "开始行动红" then return true end
    if state and not disappear(state, .2) then return true end

    if findOne("开始行动") then
      tap("开始行动蓝")
      appear({
        "开始行动红", "源石恢复理智取消",
        "药剂恢复理智取消",
      }, .5)
    end
  end, 30) then return end

  if state == "开始行动红" then
    no_success_one_loop = 0
    if fake_fight then
      log("debug0415", x)
      if not wait(function()
        if not findOne(state) and not appear(state, 1) then return true end
        tap("返回")
        disappear(state, 1)
      end, 5) then return end
      return path.base.接管作战()
    end
    if not wait(function()
      if not findOne(state) then return true end
      tap("开始行动红按钮")
    end, 10) then return end
    if not appear("接管作战", 60) then return end
    return path.base.接管作战()
  elseif stone_enable and state == "源石恢复理智取消" or drug_enable and
    state == "药剂恢复理智取消" then
    if not wait(function()
      if findOne("开始行动") then return true end
      if findOne(state) then
        tap("药剂恢复理智确认")
        disappear(state, 10)
      end
    end, 10) then return end
    return path.开始游戏(x)
  elseif state == "源石恢复理智取消" or state ==
    "药剂恢复理智取消" then
    zero_san = true
    tap("药剂恢复理智取消")
  end
end

path.主线 = function(x)
  -- split s2-9 to 2 and 9
  local chapter = x:find("-")
  chapter = x:sub(1, chapter - 1)
  chapter = chapter:sub(chapter:find("%d"))
  local chapter_index = tonumber(chapter) + 1
  local p
  p = {
    ["当前进度列表" .. chapter_index] = function()
      ssleep(.5)
      log(928, x)
      swip(x)
      tap("作战列表" .. x)
      appear("开始行动")
      return true
    end,
  }
  p["按下当前进度列表" .. chapter_index] =
    p["当前进度列表" .. chapter_index]
  if chapter_index <= 4 then -- chapter 0 to 3
    switch_start = 1
    switch_end = 4
  elseif chapter_index <= 9 then -- chapter 4 to 8
    switch_start = 5
    switch_end = 9
  else
    switch_start = 10
    switch_end = 10 - 1
  end
  for i = switch_start, switch_end do
    if chapter_index ~= i then
      p["当前进度列表" .. i] = "当前进度列表" ..
                                       (i > chapter_index and "左" or "右")
      p["按下当前进度列表" .. i] = p["当前进度列表" .. i]
    end
  end

  log(1040)
  if not findAny(table.keys(p)) then
    log(1041)
    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end
    -- this wait is needed for K40
    ssleep(.2)
    tap("主题曲")
    if not appear("怒号光明") then return end

    if chapter_index <= 4 then
      tap("觉醒")
      ssleep(.5)
    end

    log("1046", chapter)
    swipc(distance['' .. chapter])

    if not wait(function()
      if not findOne("怒号光明") then return true end
      tap("作战主线章节列表" .. chapter)
    end, 1) then tap("作战主线章节列表8") end

    if not appear(table.keys(p), 5) then return end
  end
  auto(p, false, 10)
  path.开始游戏(x)
end

update_open_time = function()
  -- 芯片搜索
  pr_open_time = {
    A = {1, 4, 5, 7},
    B = {1, 2, 5, 6},
    C = {3, 4, 6, 7},
    D = {2, 3, 6, 7},
  }
  pr_open_time_r = table.reverseIndex(pr_open_time)
  -- pr_open_time_r[1]={"A","B"}
  -- pr_open_time_r[2]={"B","D"}
  -- pr_open_time_r[3]={"C","D"}
  -- pr_open_time_r[4]={"A","C"}
  -- pr_open_time_r[5]={"A","B"}
  -- pr_open_time_r[6]={"B","C","D"}
  -- pr_open_time_r[7]={"A","C","D}
  -- 物资筹备
  ls_open_time = {
    LS = {1, 2, 3, 4, 5, 6, 7},
    AP = {1, 4, 6, 7},
    CA = {2, 3, 5, 7},
    CE = {2, 4, 6, 7},
    SK = {1, 3, 5, 6},
  }
  ls_open_time_r = table.reverseIndex(ls_open_time)
  -- ls_open_time_r[1]={"LS","AP","SK"}
  -- ls_open_time_r[2]={"LS","CA","CE"}
  -- ls_open_time_r[3]={"LS","CA","SK"}
  -- ls_open_time_r[4]={"LS","AP","CE"}
  -- ls_open_time_r[5]={"LS","CA","SK"}
  -- ls_open_time_r[6]={"LS","AP","SK","CE"}
  -- ls_open_time_r[7]={"LS","AP","CA","CE"}
  -- move CE and LS to last
  local lotr = ls_open_time_r
  for k, v in pairs(lotr) do
    local p = table.find(lotr[k], equalX("CE"))
    if p then
      table.remove(lotr[k], p)
      table.insert(lotr[k], "CE")
    end
    table.remove(lotr[k], table.find(lotr[k], equalX("LS")))
    table.insert(lotr[k], "LS")
  end
  local t = parse_time()
  if all_open_time_start <= t and t < all_open_time_end then
    log("全天开启时间表")
    pr_open_time = {
      A = {1, 2, 3, 4, 5, 6, 7},
      B = {1, 2, 3, 4, 5, 6, 7},
      C = {1, 2, 3, 4, 5, 6, 7},
      D = {1, 2, 3, 4, 5, 6, 7},
    }
    pr_open_time_r[1] = {"A", "B", "C", "D"}
    pr_open_time_r[2] = {"B", "D", "A", "C"}
    pr_open_time_r[3] = {"C", "D", "A", "B"}
    pr_open_time_r[4] = {"A", "C", "B", "D"}
    pr_open_time_r[5] = {"A", "B", "C", "D"}
    pr_open_time_r[6] = {"B", "C", "D", "A"}
    pr_open_time_r[7] = {"A", "C", "D", "B"}

    ls_open_time = {
      LS = {1, 2, 3, 4, 5, 6, 7},
      CA = {1, 2, 3, 4, 5, 6, 7},
      CE = {1, 2, 3, 4, 5, 6, 7},
      SK = {1, 2, 3, 4, 5, 6, 7},
      AP = {1, 2, 3, 4, 5, 6, 7},
    }
    -- for i = 1, 7 do log(ls_open_time_r[i], i) end
    ls_open_time_r[1] = {"CA", "CE", "AP", "SK", "LS"}
    ls_open_time_r[2] = {"AP", "SK", "CA", "CE", "LS"}
    ls_open_time_r[3] = {"AP", "CE", "CA", "SK", "LS"}
    ls_open_time_r[4] = {"CA", "SK", "AP", "CE", "LS"}
    ls_open_time_r[5] = {"AP", "CE", "CA", "SK", "LS"}
    ls_open_time_r[6] = {"CA", "AP", "SK", "CE", "LS"}
    ls_open_time_r[7] = {"SK", "AP", "CA", "CE", "LS"}
  end
end

path.物资芯片 = function(x)
  -- split PR-A-1 to A and 1, split LS-1 to LS and 1
  local type = x:startsWith("PR") and "pr" or "ls"
  local x0 = type == "pr" and x:sub(4) or x
  local prls_open_time = _G[type .. "_open_time"]
  local prls_open_time_r = _G[type .. "_open_time_r"]
  local x1 = x0:find("-")
  if not x1 then return end
  x1 = x0:sub(1, x1 - 1)
  -- check if open now
  local open_time = prls_open_time[x1]
  local cur_time = tonumber(os.date("%w", os.time() - 4 * 3600))
  if cur_time == 0 then cur_time = 7 end
  if not table.includes(open_time, cur_time) then
    -- log(open_time, cur_time)
    log(x, "未开启")
    return
  end
  -- get index in 芯片搜索
  local cur_open = prls_open_time_r[cur_time]
  local index = table.find(cur_open, equalX(x1))
  if type == "pr" then
    index = index + 5
  else
    index = index + 5 - #cur_open
  end
  if not findOne("作战列表" .. x) then
    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end
    ssleep(.2)
    tap("资源收集")
    ssleep(.2)
    log("资源收集", index, point["资源收集列表" .. index])
    local p = point["资源收集列表" .. index][1]
    if p < 0 then
      swipq("资源收集列表1")
      tap("资源收集最左列表" .. index)
    elseif p > screen.width - 1 then
      swipq("资源收集列表9")
      tap("资源收集最右列表" .. index)
    else
      tap("资源收集列表" .. index)
    end
    appear("作战列表" .. x)
  end
  if findTap("作战列表" .. x) then
    appear("开始行动")
    path.开始游戏(x)
  end
end

jmfight_current = "积水潮窟"
is_jmfight_enough = function(x, outside)
  log("is_jmfight_enough", x)
  if ignore_jmfight_enough_check then return false end
  if not table.includes(table.values(jianpin2name), x) then return false end
  if jmfight_enough then return true end

  if not outside and findOne("报酬合成玉已满") or outside and
    findOne("报酬合成玉已满2") then

    log("find报酬合成玉已满")
    jmfight_enough = true
    return true
  end
  log("not find报酬合成玉已满")
  return false
end

path.剿灭 = function(x)
  if is_jmfight_enough(x) then return end
  path.跳转("首页")
  tap("面板作战")
  if not appear("主页") then return end
  ssleep(.2)
  tap("每周部署")

  if not findOne("主页") then return end
  if not wait(function()
    if is_jmfight_enough(x, true) then return true end
    if not findOne("主页") then return true end
    tap("当期委托")
  end, 5) then return end
  if is_jmfight_enough(x) then return end
  if not appear("开始行动") then return end
  if is_jmfight_enough(x) then return end
  if x ~= jmfight_current then
    -- 非当期委托需要切换
    if not wait(function()
      if findOne("切换") then return true end
      tap("主页右侧")
    end, 5) then return end
    if not wait(function()
      if findOne("当前委托侧边栏") then return true end
      tap("切换")
      disappear("切换")
    end, 5) then return end
    if not wait(function()
      if not findOne("当前委托侧边栏") then return true end
      tap("作战列表" .. x)
      disappear("当前委托侧边栏")
    end, 5) then return end
  end
  appear("开始行动")
  path.开始游戏(x)
end

path["1-11"] = function()
  local x = "1-11"
  if not findOne("开始行动") then return end
  if not wait(function()
    if not findOne("开始行动") then return true end
    log(123)
    tap("开始行动蓝")
  end, 5) then return end
  if not appear("开始行动红", 5) then return end
  if not wait(function()
    if not findOne("开始行动红") and not appear("开始行动红", 1) then
      return true
    end
    tap("开始行动红按钮")
  end, 5) then return end
  if not appear("跳过剧情", 20) then return end
  ssleep(.5)
  tap("跳过剧情")
  ssleep(.5)
  tap("跳过剧情确认")

  -- start
  ssleep(23)
  tap("两倍速")
  -- 芬
  -- deploy(591, 807, 522)
  deploy2(4, 12, 807, 522)
  -- 翎羽
  -- deploy(600, 948, 516)
  deploy2(3, 11, 948, 516)
  -- 杰西卡
  ssleep(2)
  -- deploy(585, 939, 373)
  deploy2(3, 10, 939, 373)
  -- 安塞尔
  ssleep(6)
  -- deploy(1299, 801, 384)
  deploy2(6, 9, 801, 384)
  -- 玫兰莎
  ssleep(8)
  -- deploy(945, 1227, 368)
  deploy2(3, 8, 1227, 368)
  -- 黑角
  -- deploy(1122, 1216, 269)
  deploy2(3, 7, 1216, 269)
  -- 黑角
  -- retreat(1110, 263, 894, 323)
  -- 米格鲁
  ssleep(11)
  -- deploy(1482, 813, 314)
  deploy2(5, 7, 813, 314)
  -- 史都华德
  -- deploy(1656, 669, 407)
  deploy2(5, 6, 669, 407)
  ssleep(4)
  -- 玫兰莎
  retreat(1110, 368, 894, 323)

  if not wait(function()
    if findOne("当前进度列表2") then return true end
    tap("开始行动")
  end, 60 * 2, 1) then return end
  pre_fight = "1-11"
end

path.会客厅跳转好友 = function()
  -- deprecated, we now first do 访问好友, then do 基建
  if not findOne("线索传递") then return end

  if not wait(function()
    if findAny({"进驻信息", "进驻信息选中"}) then return true end
    if findOne("线索传递") then
      tap("返回")
      -- can't ignore sleep
      disappear("线索传递", .5)
    end
  end, 5) then return end

  if not wait(function()
    if not findAny({"进驻信息", "进驻信息选中"}) then return true end
    tap("好友")
  end, 5) then return end

  if not wait(function()
    if findOne("好友列表") then return true end
    tap('好友列表')
  end, 5) then return end

  if not wait(function()
    if not findOne("主页") then return true end
    tap('访问基建')
  end, 10) then return end

  -- if speedrun then return appear("主页", 10) end
end

path.访问好友 = function()
  if communication_enough then return end
  path.跳转("好友")
  if not wait(function()
    if findOne("好友列表") then return true end
    tap('好友列表')
  end, 5) then return end
  if not wait(function()
    if not findOne("主页") then return true end
    tap('访问基建')
  end, 10) then return end

  if not wait(function()
    if not disable_communication_check and
      findOne("今日参与交流已达上限") then
      log("今日参与交流已达上限")
      disappear("正在提交反馈至神经", 20)
      appear("主页", 5)
      communication_enough = true
      return true
    end
    if findOne("访问下位灰") then
      log("访问下位灰")
      return true
    end
    tap("访问下位")
  end, 60) then return end
end

path.公招刷新 = function()
  log(1355)
  path.跳转("公开招募")
  log(1356)
  local f, g
  local success = 0

  f = function(i)
    log(1044, i)
    if findOne("公开招募确认蓝") then tap("返回") end
    log(1286)
    if not appear("公开招募箭头", 1) then return end
    log(1287)
    -- 有灰，等待检测所有状态
    local see = appear({
      "聘用候选人列表" .. i, "公开招募列表" .. i,
      "立即招募列表" .. i,
    })
    log(1288)

    if see == "聘用候选人列表" .. i then
      log(i, 1001)
      if not wait(function()
        if not findOne("公开招募") and not findOne("主页") then
          return true
        end
        if findTap("聘用候选人列表" .. i) then
          log(1052)
          -- disappear("公开招募", 1)
        end
      end, 5) then return end
      -- 聘用
      if not wait(function()
        if findOne("公开招募") and findOne("主页") then return true end
        tap("开包skip")
      end, 15) then return end
      return f(i)
    end

    if see == "公开招募列表" .. i then
      if speedrun then
        if not wait(function()
          if findOne("公开招募取消") then return true end
          -- TODO no tap->findtap
          tap("公开招募列表" .. i)
        end, 10) then return end

        if not wait(function()
          if not findOne("公开招募取消") then return true end
          tap("公开招募确认蓝")
        end, 10) then return end
        if not appear("公开招募箭头") then return end
        success = success + 1
        return
      end

      -- 刷新
      log(1308)
      if not wait(function()
        if findOne("公开招募取消") then return true end
        if findOne("公开招募箭头") then
          tap("公开招募列表" .. i)
        end
      end, 5) then return end
      log(1311)
      g = function()
        log("1243")

        local empty_tags = true
        local tags = {}
        local ocr_text
        local max_star = 4

        -- retry ocr if contains invalid tags
        for j = 1, 6 do
          for _ = 1, 5 do
            local p = point["公开招募标签框列表" .. j]
            log(1461, p)

            -- TODO dont's know if this function other function raise exception
            -- java.lang.StringIndexOutOfBoundsException: length=4; index=4
            local status
            while not status do
              log(1469, status)
              status, ocr_text = pcall(ocr, table.unpack(p))
            end

            log(1463, ocr_text)
            if not ocr_text then break end
            ocr_text = string.map(ocr_text, {
              ["'"] = "",
              [" "] = "",
              ["."] = "",
              ["。"] = "",
              ["`"] = "",
              ["-"] = "",
              ["_"] = "",
              ["′"] = "",
              [","] = "",
              ["，"] = "",
              ["("] = "",
              [")"] = "",
              ["{"] = "",
              ["}"] = "",
              ["v"] = "",
              ["^"] = "",
              ["4"] = "",
            })

            -- should be at least dual chinese characters
            if #ocr_text < 6 then break end

            if table.includes(tag, ocr_text) then
              tags[ocr_text] = {p[1], p[2]}
              empty_tags = false
              break
            end
            log("invalid tag", ocr_text)
          end
        end
        if empty_tags then return end
        log(1092, tags)
        local tag4 = table.filter(tag5, function(rule)
          return table.all(rule[1], function(r) return tags[r] end)
        end)
        log(1093, tag4)
        -- toast(JsonEncode(tags))

        if #tag4 == 0 then
          if findTap("公开招募标签刷新蓝") then
            if not disappear("公开招募时间减") then return end
            if not wait(function()
              if findOne("公开招募时间减") then return true end
              tap("公开招募右确认")
            end, 5) then return end
            if not appear("公开招募时间减") then return end

            -- 画面中有飞屑，sample不可用，先用sleep了
            -- 2 seconds for stabilization
            ssleep(2)
            return g()
          else
            if not wait(function()
              if findOne("公开招募箭头") and
                findOne("公开招募列表" .. i) then return true end
              if findOne("公开招募时间减") then
                tap("返回")
                disappear("公开招募箭头", .5)
              end
            end, 5) then return end
          end
        else
          for _, v in pairs(tag4) do max_star = max(max_star, v[2]) end
          log(max_star)
          if max_star == 4 and star4_auto then
            log(1144)

            local list = tag4[1][1]
            if longest_tag then
              list = {{}}
              for _, v in pairs(tag4) do
                if #list[1] < #v[1] then list = v end
              end
              list = list[1]
            end
            log(1145)

            for _, v in pairs(list) do
              log("tap", v)
              tap(tags[v])
            end
            tap("公开招募时间减")
            tap("公开招募确认蓝")
            if not appear("公开招募箭头") then return end
          end
        end
      end
      g()
    end
  end
  for i = 1, 4 do
    f(i)
    if speedrun and success >= 3 then break end
  end
end
path.干员升级 = function()
  if no_update_operator then return end
  -- 干员升级 1次
  -- 最低等级干员必须小于30级
  path.跳转("干员")
  if not findOne("等级升") then
    if not wait(function()
      if findOne("等级升") then return true end
      tap("等级")
      appear("等级升", .5)
    end) then return end
  end
  if not wait(function()
    if findOne("升级") then return true end
    tap("干员1")
  end, 5) then return end
  if not wait(function()
    if findOne("副手确认蓝") then return true end
    tap("升级")
  end, 5) then return end
  appear(point.录像列表)
  tap("清空选择")
  findTap(point.录像列表)
  tap("副手确认蓝")
end

path.每日任务速通 = function()
  -- inspired by 1m57s https://www.bilibili.com/video/BV1P341167fe
  -- and 56s https://www.bilibili.com/video/BV1aM4y1L72i
  speedrun = true

  path.干员升级()
  path.基建收获()

  -- 宿舍换班 2次， may be this should be removed
  path.跳转("基建")
  f = function(i)
    if not wait(function()
      if not findOne("进驻总览") or not findOne("缩放结束") then
        return true
      end
      tap("宿舍列表" .. i)
    end, 10) then return end
    if not appear({"进驻信息", "进驻信息选中"}, 5) then return end
    if not wait(function()
      if findOne("确认蓝") then return true end
      if findOne("进驻信息选中") then
        wait(function()
          if findOne("确认蓝") then return true end
          tap("进驻第一人")
        end, 1)
      elseif findOne("进驻信息") then
        tap("进驻信息")
        ssleep(.2)
        wait(function()
          if findOne("确认蓝") then return true end
          tap("进驻第一人")
        end, 1)
      end
    end, 5) then return end
    if not wait(function()
      if findOne("干员未选中") then return true end
      tap("清空选择")
    end, 5) then return end
    local state = sample("心情")
    tap("心情")
    disappear(state, 1)
    state = sample("心情")
    tap("心情")
    disappear(state, 1)
    for j = 1, 6 do tap("干员选择列表" .. j) end

    if not wait(function()
      if findAny({"隐藏", "进驻信息", "进驻信息选中"}) then
        return true
      end
      tap("确认蓝")
    end, 5) then return end
  end

  f(1)
  f(1)

  path.信用购买()
  path.公招刷新()
  path.任务收集()
end

path.满练每日任务速通 = function()
  no_update_operator = true
  return path.每日任务速通()
end
