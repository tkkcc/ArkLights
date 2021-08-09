network_timeout = 200 -- seconds
-- set bl true
bl = {}
-- for k, v in pairs(fight_type_all) do bl[v] = true end
cl = {}
-- for k, v in pairs(fight_type_all) do cl[v] = 0 end
unfound_fight = {}
failed_fight = {}

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
      log(37)
      if not appear(inputbox) or not appear(ok) then stop("登录失败") end
      log(38)
      input(inputbox, username)
      log(39)
      click(ok)
      log(40)
      -- tap("右下角确认", 0, true)
      -- if not disappear(inputbox) then stop("登录失败") end
      log(41)
      if not appear("手机验证码登录") then stop("登录失败") end
      log(42)
    end
    log(52)
    if #password > 0 then
      if not wait(function()
        if not findOne("手机验证码登录") then return true end
        tap("账号左侧")
        tap("密码")
        disappear("手机验证码登录", .5)
      end, 5) then return end
      -- log(44)
      -- tap("账号左侧")
      -- log(45)
      -- tap()
      log(46)
      if not appear(inputbox) or not appear(ok) then stop("登录失败") end
      log(47)
      -- exit()
      input(inputbox, password)
      click(ok)
      -- tap("右下角确认", 0, true)
      -- if not disappear(inputbox) then stop("登录失败") end
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
    if not disappear("接管作战", 60 * 60, 5) then stop("接管作战") end

    -- this calllback is only for 主线、资源、剿灭
    if not wait(function()
      if findOne("开始行动") then return true end
      if findOne("接管作战") then return true end
      tap("开始行动")
    end, 20) then return end

    if findOne("接管作战") then return path.base.接管作战() end

    if repeat_fight_mode then return path.开始游戏() end

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
      log(108)
      if not wait(function()
        if not findOne("开始行动") then return true end
        tap("主页右侧")
      end, 20) then return end
      log(109)
      ssleep(1)
    end
  end,

  -- need test
  -- 客户端过时 = function() stop("客户端过时") end,
  -- 正在加载网络配置 = function()
  --   if not disappear("正在加载网络配置", 30) then
  --     stop("正在加载网络配置")
  --   end
  -- end,
  -- 登入错误 = restart,
  -- 我知道了 = restart,
  -- 网络异常稍后重试 = restart,
  -- 获取网络配置失败 = function()
  --   tap("获取网络配置失败")
  --   return true
  -- end,
  -- 理智兑换取消 = function()
  --   running = "理智不足"
  --   tap("理智兑换取消")
  --   return true
  -- end,
  -- 源石理智兑换次数上限 = function()
  --   running = "理智不足"
  --   tap("理智兑换取消")
  --   return true
  -- end,
  -- 源石不足 = function()
  --   running = "理智不足"
  --   tap('返回')
  --   return true
  -- end,
  -- 代理失误放弃行动 = "代理失误放弃行动",
  -- 战斗记录未能同步返回 = function()
  --   local i = 0
  --   while i < 5 do
  --     log("战斗记录同步重试")
  --     tap("右确认")
  --     if disappear("战斗记录未能同步返回", 5, 1) then
  --       stop("战斗记录未能同步")
  --     end
  --   end
  -- end,
  -- 未能同步到相关战斗记录 = function()
  --   stop("未能同步到相关战斗记录")
  -- end,
}

path.邮件收取 = function()
  path.跳转("邮件")

  if not wait(function()
    if findAny({"邮件提示", "邮件提示2"}) then return true end
    log(123)
    tap("收取所有邮件")
  end, 5) then return end
  log(128)
end

path.基建收获 = function()
  path.跳转("基建")
  -- TODO 灯泡可能在线索搜集提示前出现
  if not appear({"基建灯泡蓝", "基建灯泡蓝2", "线索搜集提示"}) then
    leaving_jump = true
    return
  end
  log(139)
  if not disappear("线索搜集提示", 10) then return end
  log(140)
  local x = appear({"基建灯泡蓝2", "基建灯泡蓝"}, 1)
  log(141)
  if not x then return end
  if not wait(function()
    if not findOne(x) and findOne("待办事项") then return true end
    tap(x)
    appear("待办事项", .5)
  end, 10) then return end

  wait(function()
    if not wait(function()
      if findAny({"点击全部收取", "正在提交反馈至神经"}) then
        return true
      end
    end, 1) then return true end
    findTap("点击全部收取")
  end, 20)
  tap("基建右上角")
  if appear("进驻总览") then leaving_jump = true end
end

prev_jump = "基建"
path.跳转 = function(x, disable_quick_jump)
  local sign = {
    好友 = "个人名片",
    基建 = "进驻总览",
    公开招募 = "公开招募",
    首页 = "面板",
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
    基建 = "面板基建",
    公开招募 = "面板公开招募",
    首页 = nil,
    采购中心 = "面板采购中心",
    任务 = "面板任务",
    终端 = "面板作战",
  }
  -- TODO: is all largest ok?
  local timeout = (x == "基建" or prev_jump == "基建") and 20 or 20

  -- still in 基建
  if prev_jump == "采购中心" then timeout = 20 end

  local target = sign[x]
  local home_target = x == "邮件" and "首页" or x

  -- direct quit
  if findOne(target) then
    prev_jump = x
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
      if not wait(function()
        if not findOne("主页") then return true end
        if findAny({"返回确认", "返回确认2"}) then
          tap("右确认")
        end
        tap("主页")
        disappear("主页", 1)
      end, 10) then return end
      if not appear({"主页列表任务", "返回确认"}) then
        log(252)
        return
      end
      log(findAny({"主页列表任务", "返回确认"}))
      if findOne("返回确认") then
        tap("右确认")
        return
      end
      if not appear("主页列表任务") then return end
      tap("主页列表" .. home_target)
      if not bypass(sign[home_target]) then return end
      log('wait appear', sign[home_target], timeout)
      appear(sign[home_target], timeout)
    end,
  })
  if x == prev_jump or disable_quick_jump then p.主页 = nil end
  p[target] = function()
    log("leaving_jump", leaving_jump)
    if not disappear(target,
                     (target == "进驻总览" and not leaving_jump) and 1 or 0) then
      leaving_jump = false
      log("found", target)
      return true
    end
  end

  local fallback = {返回确认 = "右确认"}
  if x == "基建" then fallback.返回确认 = function() back() end end
  auto(p, fallback)

  -- post processing especially for 基建
  if x == "基建" then zoom() end

  prev_jump = x
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
    if findAny({"进驻信息", "进驻信息选中"}) then return true end
    tap("控制中枢")
  end, 5) then return end

  if not wait(function()
    if findOne("基建副手简报") then return true end
    tap("基建副手")
  end, 5) then return end

  for i = 1, 5 do
    if not wait(function()
      if findOne("副手确认蓝") then return true end
      if findOne("基建副手简报") then
        tap("基建副手列表" .. i)
        disappear("基建副手简报", 1)
      end
    end, 10) then return end

    if not findOne("干员未选中") then
      tap("干员选择列表1")
      if not appear("干员未选中", 1) then return end
    end

    local state = sample("信赖")
    tap("信赖")
    log("state", state)
    disappear(state)

    state = sample("信赖")
    tap("信赖")
    disappear(state)

    tap("干员选择列表" .. i)
    if not wait(function()
      if findOne("基建副手简报") then return true end
      findTap("副手确认蓝")
    end, 5) then return end
  end
end

sample = function(v)
  local ans = ''
  for _, p in pairs(point[v .. "采样列表"]) do
    log(297, p)
    p = point[p]
    log(298, p)
    ans = ans .. p[1] .. ',' .. p[2] .. ',' .. getColor(table.unpack(p)).hex ..
            '|'
  end
  log("采样", point.sample)
  point.sample = ans:sub(1, #ans - 1)
  rfl.sample = point2region(point.sample)
  return "sample"
end

path.基建换班 = function()
  -- 宿舍换人
  local f
  f = function(i)
    log(358)
    path.跳转("基建")
    log(359)
    if not appearTap("宿舍列表" .. i) then
      log("未找到宿舍列表" .. i)
      return
    end

    if not wait(function()
      if findAny({"进驻信息", "进驻信息选中"}) then return true end
      if findOne("进驻总览") and findTap("宿舍列表" .. i) then
        disappear("进驻总览", 1)
      end
    end, 10) then return end

    if not wait(function()
      if findOne("进驻信息选中") and findOne("当前房间入住信息") then
        return true
      end
      if findTap("进驻信息") then disappear("进驻信息", 1) end
    end, 10) then return end

    if not wait(function()
      if not findOne("当前房间入住信息") then return true end
      tap("进驻第一人")
    end, 5) then return end
    if not appear("确认蓝", 5) then return end

    if not wait(function()
      if findOne("干员未选中") then return true end
      tap("清空选择")
    end, 5) then return end

    local state = sample("心情")
    tap("心情")
    disappear(state)
    state = sample("心情")
    tap("心情")
    disappear(state)
    for j = 1, 5 do tap("干员选择列表" .. j) end
    if not wait(function()
      if not findOne("确认蓝") then return true end
      tap("确认蓝")
      disappear("确认蓝", 1)
    end, 5) then return end
    if appear({"排班调整提示", "进驻信息", "进驻信息选中"}, 5) ==
      "排班调整提示" then
      if not wait(function()
        if not findOne("排班调整提示") then return true end
        tap("排班调整确认")
      end, 5) then return end
    end
  end
  if not no_dorm then for i = 1, 4 do f(i) end end

  path.跳转("基建")
  if not wait(function()
    if findOne("撤下干员") then return true end
    if findTap("进驻总览") then disappear("进驻总览", 1) end
  end, 10) then return end

  local swipd = function()
    local duration = 333
    local delay = 100
    local y1 = screen.height * 3 // 4
    local x1 = math.round((1880 - 1920) * minscale) + screen.width
    local x2 = math.round((680 - 1920) * minscale) + screen.width
    local y2 = math.round(10 * minscale)
    log(x1, y1, x2, y2)
    local paths = {{{x = x1, y = y1}, {x = x1, y = y2}}}
    log(paths)
    gesture(paths, duration)
    sleep(duration + delay)
    tap("入驻干员右侧")
    sleep(33)
  end
  -- local swip = function(up, starty, endy)
  --     if up then
  --         starty = starty or screen.height // 4 * 3
  --         endy = endy or 0
  --     else
  --         starty = starty or screen.height // 4
  --         endy = endy or screen.height
  --     end
  --     -- TODO 
  --     slid((1867 - 1919) * minscale + screen.width, starty,
  --          (1867 - 1919) * minscale + screen.width, endy, 333)
  --     tap("入驻干员右侧")
  --     sleep(333)
  -- end

  local first_look = true
  -- 其他换人
  f = function()
    local timeout = first_look and 1 or 0
    first_look = false
    if not appearTap("入驻干员", timeout) then return end
    if not wait(function()
      if not findOne("入驻干员") then return true end
      findTap("入驻干员")
      disappear("入驻干员")
    end, 10) then return end
    if not appear("确认蓝", 10) then return end

    local limit = findOne("清空选择") and 5 or 1

    -- local state = sample("筛选")

    if not wait(function()
      if findOne("筛选取消") then return true end
      tap("筛选")
    end, 5) then return end
    if not wait(function()
      if not findOne("筛选未进驻") then return true end
      tap("筛选未进驻")
      disappear("筛选未进驻", .5)
    end, 5) then return end
    if not wait(function()
      if not findOne("筛选技能") then return true end
      tap("筛选技能")
      disappear("筛选技能", .5)
    end, 5) then return end
    if not wait(function()
      if not findOne("筛选取消") then return true end
      tap("筛选确认")
      disappear("筛选取消", .5)
    end, 5) then return end

    if not appear("确认蓝", 5) then return end

    if not wait(function()
      if findOne("干员未选中") then return true end
      tap("清空选择")
    end, 5) then return end

    -- appear(state, .5)
    for j = 1, limit do tap("干员选择列表" .. j) end
    if not wait(function()
      if findAny({"排班调整提示", "撤下干员"}) then return true end
      if findTap("确认蓝") then disappear("确认蓝", 1) end
    end, 5) then return end

    if findAny({"排班调整提示", "撤下干员"}) == "排班调整提示" then
      if not wait(function()
        if not findOne("排班调整提示") then return true end
        tap("排班调整确认")
      end, 5) then return end
    end
    if not appear("撤下干员") then return end
    return true
  end

  for i = 1, 6 do
    -- TODO 应对换人网络延迟
    -- if findOne("入驻干员底部") then
    --   log("滑到底部")
    --   break
    -- end
    if i ~= 1 then
      local state = sample("进驻")
      while findOne(state) do
        log(470)
        swipd()
      end
    end
    while f(i) do log(475) end
  end
end

path.制造加速 = function()
  path.跳转("基建")
  log(488)
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
  if not station then return end
  log(498, station)
  if not wait(function()
    if not findOne("进驻总览") then return true end
    if findTap("station") then disappear("station", 1) end
  end, 5) then return end
  log(513)
  if not appear({"进驻信息", "进驻信息选中"}, 5) then return end
  tap("制造站进度")
  log(514)
  if not wait(function()
    if findOne("无人机加速") then return true end
    findTap("制造站加速")
  end, 5) then return end
  log(515)
  tap("无人机加速最大")
  if not wait(function()
    if findOne("制造站加速") then return true end
    tap("无人机加速确定")
  end, 5) then return end
  tap("制造站收取")
end

path.线索搜集 = function()
  path.跳转("基建")

  -- assume
  -- local station = findOne("会客厅")
  -- if not station then return end
  if not wait(function()
    if not findOne("进驻总览") then return true end
    tap("会客厅")
    disappear("进驻总览", 1)
  end, 5) then return end
  if not appear({"进驻信息", "进驻信息选中"}, 5) then return end

  if not wait(function()
    if findOne("线索传递") then return true end
    if findAny({"进驻信息", "进驻信息选中"}) then
      tap("制造站进度")
      appear("线索传递")
    end
  end, 10) then return end

  log(460)
  if appear({"正在提交反馈至神经", "本次线索交流活动"}, .5) then
    if disappear("正在提交反馈至神经", 20) and
      disappear("线索传递") then
      log(462)
      if not wait(function()
        if findOne("线索传递") then return true end
        if findOne("本次线索交流活动") then
          tap("返回")
          disappear("本次线索交流活动", .5)
        end
        log(5)
      end, 10) then return end
    end
  end
  log(559)

  -- single tap enough?
  if findTap("接收线索有") then
    appearTap("全部收取", 5)
    log(499)
    if not wait(function()
      if findOne("线索传递") then return true end
      tap("解锁线索左")
      appear("线索传递", 1)
    end, 5) then return end
    log(500)
  end
  log(433)
  if not appear("线索传递", 5) then return end
  log(434)

  local f
  f = function()
    if not wait(function()
      if findOne("信用奖励返回") then return true end
      if findOne("线索传递") then
        tap("信用奖励有")
        disappear("线索传递", 1)
      end
    end, 5) then return end
    -- appear("信用奖励返回")
    -- log(444)
    if not appear("未达线索上限", .5) then
      log(445)
      tap("返回")
      appear("线索传递")
      clue_unlocked = false
      path.线索布置()
      if not clue_unlocked then path.线索传递() end
      return f()
    end

    -- TODO: need recheck after 领取？
    if findTap("信用奖励领取") then
      log(531)
      -- TODO
      if appear("未达线索上限") then
        log(532)
        return f()
      end
    end
    if findOne("信用奖励返回") then tap("返回") end
    if not appear("线索传递") then return end
    return true
  end
  if not f() then return end
  if not appear("线索传递") then return end
  path.线索布置()

  -- 访问好友
  if not appear("线索传递") then return end
  if not wait(function()
    if findAny({"进驻信息", "进驻信息选中"}) then return true end
    if findOne("线索传递") then
      tap("返回")
      disappear("线索传递", 1)
    end
  end, 5) then return end
  if not wait(function()
    if findOne("个人名片") then return true end
    local x = findAny({"进驻信息", "进驻信息选中"})
    if x then
      tap("好友")
      disappear(x, 1)
    end
  end, 5) then return end
  path.访问好友()
end

path.线索布置 = function()
  log(650)
  -- internal
  if not findOne("线索传递") then
    log("线索布置未找到线索传递")
    return
  end
  log(656)
  local p = appear(point.线索布置列表, .5)
  log(6566)

  -- tap with offset -50,50
  local tapCard = function(k)
    local x, y = point[k]:match("(%d+),(%d+)")
    tap({tonumber(x) - 50, tonumber(y) + 50})
  end

  if p then
    log(645)
    if not wait(function()
      if not findOne(p) then return true end
      tapCard(p)
      disappear(p)
    end, 5) then return end
    log(646)
    if not appear("线索布置左列表" .. p:sub(#p), 5) then return end
    log(647)

    for i = 1, 7 do
      if findOne("线索布置左列表" .. i) then
        p = "线索布置左列表" .. i
        if not wait(function()
          if findOne("线索传递数字右列表" .. i) then
            return true
          end
          tapCard(p)
        end, 5) then return end

        if not wait(function()
          if not findOne(p) then return true end
          tap("线索库列表1")
          disappear(p)
        end, 50) then return end
      end
    end
    log(648)
    tap("解锁线索左")
    appear("线索传递")
  end
  if not appear("线索传递") then return end

  if findTap("解锁线索") then
    clue_unlocked = true
    if not appear("进驻信息", 5) then return path.线索搜集() end
    if not wait(function()
      if findOne("线索传递") then return true end
      if findAny({"进驻信息", "进驻信息选中"}) then
        tap("制造站进度")
        appear("线索传递")
      end
    end, 10) then return path.线索搜集() end
    return path.线索布置()
  end
end

path.线索传递 = function()
  -- internal
  if not appearTap("线索传递") then return end
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
    elseif findOne("线索传递橙框") then
      local points = findAll("线索传递橙框")
      if points then
        for _, p in pairs(points) do
          local i = 1
          for j = 1, 4 do
            if p.y < point["传递列表" .. j][2] then
              i = j
              break
            end
          end
          if findOne("今日登录列表" .. i) then
            -- log(539, i, p.y, point["传递列表" .. i])
            -- log(findOne("今日登录列表" .. i))
            idx = i
            break
          end
        end
        -- if idx then break end
      end
    end
    if idx then
      -- log("线索传递", idx, point.传递列表[idx])
      tap(point.传递列表[idx])
      wait(function()
        if findOne("线索传递") then return true end
        tap("线索传递返回")
      end, 5)
      return true
    end
  end
  for _ = 1, 50 / 4 + 5 do
    if f() then break end

    if not appear({"线索传递右白", "线索传递右白2"}, .5) then
      f(true)
      break
    end

    tap("线索传递右白")
    appear("线索传递橙框", .5)
  end
end

path.任务收集 = function()
  path.跳转("任务")
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
  log(803)
  if not wait(function()
    if findOne("信用交易所") then return true end
    -- if not findOne("可露希尔推荐") then return true end
    tap("信用交易所")
  end, 10) then return end
  log(804)

  log(820)
  if findOne("收取信用有") then
    log(821)
    local f = function()
      if not wait(function()
        if not findOne("信用交易所") then return true end
        -- if not findOne("干员解锁进度") then return true end
        tap("收取信用有")
      end, 5) then return end
      if not wait(function()
        if findOne("信用交易所") then return true end
        -- if findOne("干员解锁进度") then return true end
        tap("收取信用有")
      end, 5) then return end
    end
    f()
  end

  log(822)
  if not appear(point["信用交易所列表"]) then return end
  log(823)

  local f
  f = function(i)
    local enough
    if not findOne("信用交易所") then return end
    -- if not findOne("干员解锁进度") then return end
    local x = "信用交易所列表" .. i
    if not findOne(x) then return end

    if not wait(function()
      if not findOne(x) then return true end
      tap(x)
    end, 5) then return end
    if not appear("购买物品") then return end

    log(813)
    if not findOne("购买物品面板") then return end
    log(814)
    if not wait(function()
      if not findOne("购买物品面板") then return true end
      if findOne("信用不足") then
        enough = true
        return true
      end
      tap("购买物品")
    end, 10) then return end
    log(815)
    if enough then return true end

    -- wait for popup
    appear("信用交易所", 5)
    -- appear("干员解锁进度", 5)
    disappear("信用交易所", 5)
    -- disappear("干员解锁进度", 5)
    -- log(816)

    if not wait(function()
      if findOne("信用交易所") then return true end
      -- if findOne("干员解锁进度") then return true end
      tap("信用交易所")
      -- tap("干员解锁进度")
    end, 5) then return end

  end
  for i = 1, 10 do if f(i) then break end end
  -- log(findOne('主页'))
  -- exit()
end

-- get_fight_type =function(x)
--  local f = startsWithX(x)
--   if table.any({"PR", "CE", "CA", "AP", "LS", "SK"}, f) then
--     return "物资芯片"
--   elseif table.any(table.keys(jmfight2area), f) then
--     return "剿灭"
--   else
--     return "主线"
--   end
-- end

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
path.轮次作战 = function()
  if #fight == 0 then return true end
  path.跳转("首页")
  pre_fight = nil
  while not zero_san do
    fight_tick = fight_tick % #fight + 1
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

path.开始游戏 = function(x)
  log("开始游戏", fight_tick, x)
  if x == "1-11" then return auto(path["1-11"]) end
  if not findOne("开始行动") then return end
  if is_jmfight_enough() then return end
  if not wait(function()
    if appear("代理指挥开", .1) then return true end
    tap("代理指挥开")
    appear("代理指挥开", .4)
  end, 5) then return end
  if not findOne("代理指挥开") then
    log("未检测到代理指挥开")
    return
  end
  log("代理指挥开", findOne("代理指挥开"))
  if not wait(function()
    if not findOne("开始行动") then return true end
    tap("开始行动蓝")
  end, 5) then return end
  local state = appear({
    "开始行动红", "源石恢复理智取消", "药剂恢复理智取消",
  }, 5)

  if state == "开始行动红" then
    if fake_fight then
      log("debug0415", x)
      if not wait(function()
        if not findOne(state) then return true end
        tap("返回")
        disappear(state,1)
      end,5) then return end
      return path.base.接管作战()
    end
    if not wait(function()
      if not findOne(state) then return true end
      tap(state)
    end, 10) then return end
    if not appear("接管作战", 20) then return end
    path.base.接管作战()
  elseif state == "源石恢复理智取消" then
    if stone_enable then
      tap("药剂恢复理智确认")
    else
      zero_san = true
      tap("源石恢复理智取消")
      return
    end
  elseif state == "药剂恢复理智取消" then
    if drug_enable then
      tap("药剂恢复理智确认")
    else
      zero_san = true
      tap("药剂恢复理智取消")
      return
    end
  end
end

path.主线 = function(x)
  -- split s2-9 to 2 and 9
  local x0 = x
  local chapter = x0:find("-")
  chapter = x0:sub(1, chapter - 1)
  chapter = chapter:sub(chapter:find("%d"))
  local chapter_index = tonumber(chapter) + 1
  local p
  p = {
    ["当前进度列表" .. chapter_index] = function()
      ssleep(.5)
      log(928, x0)
      swip(x0)
      tap("作战列表" .. x0)
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
    tap("主题曲")
    if not appear("怒号光明") then return end
    if chapter_index <= 4 then
      tap("觉醒")
    elseif chapter_index <= 9 then
      tap("幻灭")
    end
    if disappear("二次呼吸", .5) then appear("二次呼吸") end
    if not findOne("二次呼吸") then return end
    swipq(chapter, true)
    if not wait(function()
      if not findOne("怒号光明") then return true end
      tap("作战主线章节列表" .. chapter)
    end) then tap("作战主线章节列表8") end
    if not appear(table.keys(p)) then return end
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
  local x2
  if not x1 then return end
  x1, x2 = x0:sub(1, x1 - 1), x0:sub(x1 + 1)
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
    tap("资源收集")
    -- TODO: no wait here seems ok
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

jmfight2area = {
  龙门外环 = "炎国龙门",
  龙门市区 = "炎国龙门",
  废弃矿区 = "乌萨斯",
  切尔诺伯格 = "乌萨斯",
  北原冰封废城 = "乌萨斯",
  大骑士领郊外 = "卡西米尔",
  潮没海滨 = "汐斯塔",
}

jmfight_current = "积水潮窟"
is_jmfight_enough = function()
  if jmfight_enough then return true end
  if findOne("报酬合成玉满") then
    jmfight_enough = true
    return true
  end
  return false
end
path.剿灭 = function(x)
  if jmfight_enough then return end
  path.跳转("首页")
  tap("面板作战")
  if not appear("主页") then return end
  tap("每周部署")
  if not findOne("主页") then return end
  if not wait(function()
    if not findOne("主页") then return true end
    tap("当期委托")
  end, 5) then return end
  if not appear("开始行动") then return end
  if is_jmfight_enough() then return end
  if x ~= jmfight_current then
    -- 非当期委托需要切换
    if not wait(function()
      if findOne("切换") then return true end
      tap("主页右侧")
    end, 5) then return end
    if not wait(function()
      if findOne("当前委托侧边栏") then return true end
      if findTap("切换") then disappear("切换", .5) end
    end, 5) then return end
    if not wait(function()
      if not findOne("当前委托侧边栏") then return true end
      tap("作战列表" .. x)
      disappear("当前委托侧边栏", .5)
    end, 5) then return end
  end
  appear("开始行动")
  path.开始游戏(x)
end

path.访问好友 = function()
  if communication_enough then return end
  -- 鹰角跳转优化不够
  -- path.跳转("好友")
  -- internal
  log(1019)
  if not appear("个人名片") then return end
  if not wait(function()
    if findOne("好友列表") then return true end
    tap('好友列表')
  end, 5) then return end

  if not appearTap('访问基建', 5) then return end
  while appear({"访问下位橘", "访问下位灰"}, 10) do
    if findOne("今日参与交流已达上限") then
      appear("主页")
      communication_enough = true
      break
    end
    if findOne("访问下位灰") then break end
    tap("访问下位橘")
  end
end

path["1-11"] = function()
  local x = "1-11"
  tap("开始行动蓝")
  -- wait 安德切尔
  if not findTap("开始行动红") then return end
  -- appearTap()
  -- ssleep(13)
  -- tap("跳过剧情")
  if not appearTap("跳过剧情", 20, 1) then
    log("没找到跳过剧情")
    log('代理失误', x)
    bl[x] = false
    failed_fight[x] = (failed_fight[x] or 0) + 1
    return false
  end
  ssleep(1)
  tap("跳过剧情确认")
  -- start
  ssleep(23)
  tap("两倍速")
  -- 芬
  deploy(591, 807, 522)
  -- 翎羽
  deploy(447, 948, 516)
  -- 杰西卡
  ssleep(2)
  deploy(585, 939, 373)
  -- 安塞尔
  ssleep(6)
  deploy(1299, 801, 384)
  -- 玫兰莎
  ssleep(8)
  deploy(945, 1227, 368)
  -- 黑角
  deploy(1122, 1216, 269)
  -- 米格鲁
  ssleep(11)
  -- 黑角
  -- retreat(1110, 263, 894, 323)
  deploy(1482, 813, 314)
  -- 史都华德
  deploy(1656, 669, 407)
  ssleep(6)
  -- 玫兰莎
  retreat(1110, 368, 894, 323)
  if appear("行动结束", 60, 1) then
    log('代理成功', x)
    cl[x] = (cl[x] or 0) + 1
    ssleep(3)
    tap("返回")
    ssleep(4)
  else
    log('代理失误', x)
    bl[x] = false
    failed_fight[x] = (failed_fight[x] or 0) + 1
  end
end

path.公招刷新 = function()
  log(1355)
  path.跳转("公开招募")
  log(1356)
  local f, g

  f = function(i)
    log(1044, i)
    if findOne("公开招募确认蓝") then tap("返回") end
    log(1286)
    if not appear("公开招募箭头", .5) then return end
    log(1287)
    local see = findAny({
      "聘用候选人列表" .. i, "公开招募列表" .. i,
    })
    log(1288)
    if see == "聘用候选人列表" .. i then
      log(i, 1001)
      if not wait(function()
        if not findOne("公开招募") then return true end
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
      -- 刷新
      log(1308)
      if not wait(function()
        -- log(1309)
        if findOne("公开招募取消") then return true end
        -- log(1310)
        findTap("公开招募列表" .. i)
      end, 5) then return end
      log(1311)
      local prev_tags = nil
      g = function(disable_refresh_check)
        log("1243", prev_tags)

        local empty_tags = true
        local tags = {}
        local ocr_text
        local max_star = 4

        -- retry ocr if contains invalid tags
        for j = 1, 6 do
          for _ = 1, 5 do
            local p = point["公开招募标签框列表" .. j]
            ocr_text, _ = ocr(table.unpack(p))
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
            log(1411)
            if not wait(function()
              if findOne("公开招募时间减") then return true end
              tap("公开招募右确认")
            end, 5) then return end
            if not appear("公开招募时间减") then return end
            log(1412)
            ssleep(2)
            return g()
          else
            tap("返回")
            if not appear("公开招募箭头") or
              not appear("公开招募列表" .. i) then return end
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
  for i = 1, 4 do f(i) end
end

path["作战1-11"] = function() for _ = 1, 14 do path.作战("1-11") end end
