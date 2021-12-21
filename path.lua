path = {}

-- base 只在跳转时使用，如果在任务中间需要登录失效，则当前任务超时后，下一任务的跳转会重新登录。
-- base 应覆盖尽可能多的corner case。
-- wait_game_up 每5秒执行一次，保证游戏在前台，别点到其他应用。
-- wait_game_up 有必要在游戏中自动亮屏吗：有
-- wait_game_up 有必要在切出游戏后回到游戏吗：有
-- wait_game_up 有必要做B服界面跳转吗：没有。做了之后，退出账号难实现

path.base = {
  面板 = true,
  下载资源确认 = "下载资源确认",
  start黄框 = function() wait(function() tap("start黄框") end) end,
  start黄框暗 = function() wait(function() tap("start黄框") end) end,
  账号登录 = "账号登录",
  开始唤醒 = "开始唤醒",
  手机验证码登录 = function()
    if appid ~= oppid then return end
    if #username > 0 then
      if not wait(function()
        tap("账号左侧")
        tap("账号")
        if appear('okbutton', .5) then return true end
      end, 5) then return end
      input("inputbox", username)
      tap("okbutton")
      disappear("okbutton")
    end
    if #password > 0 then
      if not wait(function()
        tap("账号左侧")
        tap("密码")
        if appear('okbutton', .5) then return true end
      end, 5) then return end
      input("inputbox", password)
      tap('okbutton')
      disappear("okbutton")
    end

    wait(function()
      if findAny({"用户名或密码错误", "密码不能为空"}) then
        login_error_times = (login_error_times or 0) + 1
        if login_error_times > 3 then stop("登录失败34") end
        return true
      end
      tap("登录")
    end, 5)
  end,
  正在释放神经递质 = function()
    if not disappear("正在释放神经递质", 60 * 60, 1) then
      stop("正在释放神经递质")
    end
  end,
  接管作战 = function()
    if not disappear("接管作战", 24 * 60 * 60, 1) then
      stop("接管作战")
    end

    -- this calllback only works for 主线、资源、剿灭
    local unfinished
    if not wait(function()
      if findOne("开始行动") and findOne("代理指挥开") then
        log(59)
        return true
      end
      if findOne("接管作战") then
        unfinished = true
        return true
      end
      tap("开始行动")
      appear({"开始行动", "接管作战"}, 1)
    end, 30) then return end

    if unfinished then return path.base.接管作战() end

    log(89, repeat_fight_mode)
    if repeat_fight_mode then return path.开始游戏('') end

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
      -- 物资芯片的appear是完备的

      local x = get_fight_type(cur_fight)
      -- if x == "物资芯片" then
      --   appear("作战列表" .. cur_fight, .5)
      if x == "主线" then
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
  bilibili_framelayout_only = function() auto(path.bilibili_login) end,
}

path.bilibili_login = {
  bgame = true,
  bilibili_account_login = function()
    tap("bilibili_account_login")
    appear("bilibili_login")
  end,
  bilibili_login = function()
    if username and #username > 0 and password and #password > 0 then
      input("bilibili_username_inputbox", username)
      input("bilibili_password_inputbox", password)
    end
    tap("bilibili_login")
    if not disappear("bilibili_login", 30) then stop("登录失败138") end
  end,
  bilibili_oneclicklogin = function()
    tap("bilibili_oneclicklogin")
    appear("bilibili_ok", 5)
  end,
  bilibili_ok = function()
    tap("bilibili_ok")
    appear("bgame", 5)
  end,
  bilibili_other = function()
    tap("bilibili_other")
    appear("bilibili_account_login")
  end,
}

path.bilibili_login_change = update(path.bilibili_login, {
  bilibili_oneclicklogin = false,
  bilibili_login = true,
  bilibili_change2 = function()
    wait(function()
      tap("bilibili_change2")
      if appear({"bilibili_change", "bilibili_account_login"}, .5) then
        return true
      end
    end, 5)
  end,
  bilibili_change = function()
    tap("bilibili_change")
    appear("bilibili_account_login")
  end,
}, nil, true)

path.fallback = {
  签到返回 = function()
    local x
    if not wait(function()
      -- 曾出现 返回确认 误判为 活动公告返回
      x = findAny({"返回确认", "返回确认3"})
      if x then return true end
      back()
    end, 10) then stop("返回键10秒超时") end
    if x then return tap(path.fallback[x]) end
  end,
  活动公告返回 = function() return path.fallback.签到返回() end,
  抽签返回 = function()
    for u = scale(300), screen.width - scale(300), 200 do
      tap({u, screen.height // 2})
    end
    tap("确定抽取")
    return path.fallback.签到返回()
  end,
  活动签到返回 = function()
    for u = scale(300), screen.width - scale(300), 200 do
      tap({u, screen.height // 2})
    end
    for v = scale(300), screen.height - scale(300), 200 do
      tap({screen.width // 2, v})
    end
    return path.fallback.签到返回()
  end,
  返回确认 = function()
    log(191)
    leaving_jump = false
    if not wait(function()
      if not findOne("返回确认") then return true end
      if stay_in_dorm_once then
        back()
        -- 必须等待
        if disappear("返回确认", .5) and not appear("进驻总览", 1) then
          -- 解决灯泡激活状态的死循环
          tap("基建右上角")
        end
      else
        tap("右确认")
      end
    end, 10) then stop("基建返回提示不消失") end
    stay_in_dorm_once = false

    if appear("进驻总览", 1) then leaving_jump = true end
  end,
  返回确认2 = "右确认",
  返回确认3 = function()
    if not wait(function()
      if findOne("面板") then return true end
      tap("左取消")
    end, 5) then stop(213) end
  end,
  单选确认框 = "右确认",
  剿灭说明 = function()
    if not wait(function()
      if findOne("主页") then return true end
      tap("基建右上角")
    end, 5) then stop(208) end
  end,
  行动结束 = function()
    if not wait(function()
      if findOne("开始行动") and findOne("代理指挥开") then
        return true
      end
      findTap("行动结束")
    end, 10) then stop(217) end
  end,
  限时开放许可 = function()
    wait(function() tap("开始作业") end, 1)
    wait(function()
      if findOne("面板") then return true end
      tap("基建右上角")
    end, 10)
    disappear("面板", 1)
  end,
  感谢庆典返回 = function()
    wait(function() tap("感谢典点击领取") end, 1)
    wait(function()
      if findOne("面板") then return true end
      tap("基建右上角")
    end, 4)
    disappear("面板", 1)

  end,
  返回 = function()
    local x = findAny({"返回确认", "返回确认2"})
    log(251, x)
    if x then return tap(path.fallback[x]) end
    -- back()
    tap("返回")
    -- 基建内返回太快会卡
    -- ssleep(.1)
    -- TODO: 基建内用back怎么样？
  end,
  返回3 = function()
    -- 只有邮件与设置界面有白色返回
    tap("返回3")
    disappear("返回3", .5)
  end,
}

path.邮件收取 = function()
  path.跳转("邮件")
  local state = sample("邮件提示")
  if not wait(function()
    if not findOne(state) then return true end
    tap("收取所有邮件")
  end, 5) then return end
end

path.基建收获 = function()
  -- jump with zoom too
  path.跳转("基建")
  local x
  local max_retry = 5
  for i = 1, max_retry do
    x = appear({
      "基建灯泡蓝", "基建灯泡蓝2", "基建收获线索提示",
    }, 3)
    -- 没看到灯泡或线索提示
    if not x then
      leaving_jump = true
      return
    end
    if x == "基建收获线索提示" then
      disappear(x, 5)
      if i >= max_retry then
        log('unknown 140')
        return
      end
    else
      break
    end
  end

  log(130)
  wait(function()
    if not findOne("进驻总览") then return true end
    tap("点击全部收取2")
    ssleep(.1)
    tap(x)
    ssleep(.1)
  end, 10)
  log(131)

  wait(function()
    log(132)
    if findAny({"小蓝圈", "进驻总览"}) then return true end
    log(133)
    tap("点击全部收取2")
  end, 10)
  log(findAny({"小蓝圈", "进驻总览"}))
  log(134)

  -- 回到进驻总览
  if not wait(function()
    if findOne("进驻总览") then return true end
    tap("基建右上角")
  end, 5) then return end

  leaving_jump = true
end

-- 跳转至由面板可到达的界面
-- 注意 从好友 以及 到采购中心的跳转
-- TODO 从好友跳转失败时有5秒等待
path.跳转 = function(x, disable_quick_jump, disable_postprocess)
  local sign = {
    好友 = "个人名片",
    基建 = "进驻总览",
    公开招募 = function()
      return findOne("公开招募") and findOne("公开招募箭头")
    end,
    首页 = "面板",
    干员 = "干员界面",
    采购中心 = "可露希尔推荐",
    任务 = "任务第一个",
    终端 = "主页",
    邮件 = function() return findOne("邮件信封") and findOne("返回3") end,
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
  local timeout = 20

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

  log(218)

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
        "抽签返回", "单选确认框", "返回3",
      }, timeout)
      log(209)
    end,
    主页 = function()
      if not wait(function()
        local y = findAny({"主页"})
        tap(y)
        -- TODO we can make this faster, gain .5s mostly
        -- jump from 宿舍 to others
        -- TODO .5 => .1 failed
        if not y or disappear(y, .5) then
          -- not y 表示 当前主页列表正在展开、收缩或停止，这时
          if home_target == "任务" or home_target == "好友" then
            ssleep(.2)
          end

          -- 一直按直到出现新状态
          tap("主页列表" .. home_target)
          tap("主页列表" .. home_target)

          wait(function()
            if not findAny({"返回", "返回2"}) or
              findAny({"主页", "返回确认", "返回确认2"}) then
              return true
            end
            tap("主页列表" .. home_target)
          end, .5)

          return true
        end
      end, 5) then return end

      if not bypass(sign[home_target]) then return end
      log('wait appear', sign[home_target], timeout)
      local first_time_see_home
      if not wait(function()
        if findOne(sign[home_target]) then
          p["主页"] = nil
          return true
        end

        if findAny({"返回", "返回2"}) then
          if not first_time_see_home then
            first_time_see_home = time()
          elseif (time() - first_time_see_home) > 1000 then
            p["主页"] = nil
            return true -- we see 返回 for some time, but target still not appear
          end
        else
          first_time_see_home = nil
        end
      end, timeout) then
        p["主页"] = nil
        return
      end
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

  stay_in_dorm_once = x == "基建"
  auto(p, path.fallback)

  -- post processing especially for 基建
  if x == "基建" and not disable_postprocess then zoom() end

  prev_jump = x

  -- disable repeat fight after any jump complete
  repeat_fight_mode = false
end

start_time = parse_time("202101010400")

-- 对于不同用户的首次任务
init_state = function()
  -- 启用重复刷模式
  repeat_fight_mode = true

  fight_tick = 0
  no_success_one_loop = 0
  prev_jump = "基建"

  update_state_last_day = 0
  update_state_last_week = 0
  communication_enough = false
  jmfight_enough = false
  zero_san = false

  first_time_swipe = true
end

-- 对于单个用户的不同任务
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
  -- toast("副手换人还没修，等5秒提示消失")
  -- ssleep(5)
  if 1 then return end
  path.跳转("基建")

  if not wait(function()
    if not findOne("进驻总览") or not findOne("缩放结束") then
      return true
    end
    tap("控制中枢")
  end, 5) then return end
  if not appear({"进驻信息", "进驻信息选中"}) then return end
  if not wait(function()
    if not findAny({"进驻信息", "进驻信息选中"}) then return true end
    tap("基建副手")
  end, 5) then return end

  for i = 1, 5 do
    if not wait(function()
      if findOne("副手确认蓝") then return true end
      tap("基建副手列表" .. i)
    end, 5) then return end

    if not findOne("干员未选中") then
      tap("干员选择列表1")
      if not appear("干员未选中") then return end
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
      if not findOne("副手确认蓝") and findOne("基建副手简报") then
        return true
      end
      tap("副手确认蓝")
    end, 5) then return end

  end
end

sample = function(v)
  local ans = ''
  for _, p in pairs(point[v .. "采样列表"]) do
    p = point[p]
    ans = ans .. p[1] .. coord_delimeter .. p[2] .. coord_delimeter ..
            getColor(p[1], p[2]) .. point_delimeter
  end
  point.sample = ans:sub(1, #ans - #point_delimeter)
  rfl.sample = point2region(point.sample)
  first_point.sample = {rfl.sample[1], rfl.sample[2]}
  return "sample"
end

path.宿舍换班 = function()
  local f
  f = function(i)
    path.跳转("基建")
    if not wait(function()
      if not findOne("进驻总览") or not findOne("缩放结束") then
        return true
      end
      tap("宿舍列表" .. i)
    end) then return end
    if not appear({"进驻信息", "进驻信息选中"}, 5) then return end
    if not wait(function()
      if findOne("筛选") then return true end
      if findOne("进驻信息选中") then
        wait(function()
          if findOne("筛选") then return true end
          tap("进驻第一人")
        end, 1)
      elseif findOne("进驻信息") then
        tap("进驻信息")
        ssleep(.2)
        wait(function()
          if findOne("筛选") then return true end
          tap("进驻第一人")
        end, 1)
      end
    end, 5) then return end

    tap("清空选择")
    if not wait(function()
      if findOne("干员未选中") and findOne("第一干员未选中") then
        return true
      end
      tap("清空选择")
    end, 5) then return end
    if not wait(function()
      if not findOne("干员未选中") then return true end
      tapAll(map(function(i) return "干员选择列表" .. i end, range(6, 10)))
      disappear("干员未选中", 0.5)
    end, 5) then return end
    if not wait(function()
      if findAny({
        "隐藏", "进驻信息", "进驻信息选中",
        -- "正在提交反馈至神经",
      }) then return true end
      tap("确认蓝")
    end, 10) then return end
  end
  if not no_dorm then for i = 1, 4 do f(i) end end
end

path.制造换班 = function()
  -- if not debug then return end

  local f
  f = function(i)

    path.跳转("基建")
    local x, y = table.unpack(point["基建列表" .. i])
    -- 检测kernel，因为可能被条纹挡住
    if not (compareColor(x, y, "#FFCC00", default_findcolor_confidence) or
      compareColor(x - 5, y - 10, "#FFCC00", default_findcolor_confidence) or
      compareColor(x - 5, y + 10, "#FFCC00", default_findcolor_confidence) or
      compareColor(x + 5, y + 10, "#FFCC00", default_findcolor_confidence) or
      compareColor(x - 5, y - 10, "#FFCC00", default_findcolor_confidence)) then
      log("skip", i)
      return
    end
    -- 进入制造站
    if not wait(function()
      if not findOne("进驻总览") or not findOne("缩放结束") then
        return true
      end
      tap({x, y})
    end, 10) then return end

    -- 收起进驻信息
    if not appear({"进驻信息", "进驻信息选中"}, 5) then return end
    if not wait(function()
      if findOne("进驻信息") then return true end
      if findOne("进驻信息选中") then
        tap("进驻信息选中")
        disappear("进驻信息选中")
      end
    end, 5) then return end

    -- 确认类型
    local type = appear({"经验站", "赤金站"}, 5)
    if not type then
      log("not support", i)
      return
    end
    log(524, type)

    -- 进入干员列表
    if not wait(function()
      if findOne("确认蓝") then return true end
      if findOne("进驻信息选中") and
        not disappear("进驻信息选中", .5) then
        tap("进驻第一人左")
      elseif findOne("进驻信息") then
        tap("进驻信息")
        disappear("进驻信息", .5)
      end
    end, 5) then return end

    -- 筛选出无进驻技能排序
    if not wait(function()
      if findOne("筛选取消") then return true end
      tap("筛选")
    end, 5) then return end

    if not appear({"筛选未进驻选中", "筛选未进驻"}) then return end
    if not appear({"筛选技能降序", "筛选技能", "筛选技能升序"}) then
      return
    end

    if not findOne("筛选未进驻选中") then
      if not wait(function()
        if findOne("筛选未进驻选中") then return true end
        tap("筛选未进驻选中")
        appear("筛选未进驻选中", .5)
      end, 5) then return end
    end

    if prefer_skill and not findOne("筛选技能降序") then
      if not wait(function()
        if findOne("筛选技能降序") then return true end
        tap("筛选技能降序")
        appear("筛选技能降序", .5)
      end, 5) then return end
    end

    if not wait(function()
      if not findOne("筛选取消") then return true end
      tap("筛选确认")
    end, 5) then return end

    if not wait(function()
      if findOne("干员未选中") and findOne("筛选横线") and
        findOne("筛选") then return true end
      tap("清空选择")
    end, 5) then return end

    findtap_operator_type(type)

    if not wait(function()
      if findAny({
        "隐藏", "进驻信息", "进驻信息选中",
        "正在提交反馈至神经",
      }) then return true end
      tap("确认蓝")
    end, 5) then return end
  end
  -- 找到所有制造站
  for i = 1, 9 do f(i) end
end

path.总览换班 = function()
  local f
  path.跳转("基建", nil, true)
  if not wait(function()
    if findOne("撤下干员") then return true end
    tap("进驻总览")
  end, 10) then return end

  local swipd = function()
    local flipd = 150
    local flips = 50
    local duration = flipd + flips + 50
    local x1 = screen.width - scale(1280 - 500)
    local x2 = x1 + scale(100)
    local x3 = screen.width - 1
    local y1 = scale(150)
    local y2 = screen.height - scale(150)
    local paths = {
      {point = {{x1, y1}, {x3, y1}}, duration = duration},
      {point = {{x1, y2}, {x2, y2}}, duration = flipd, start = flips},
    }
    gesture(paths)
    sleep(duration + 50)
    -- 可能还是需要按下
    tap("入驻干员右侧")
    sleep(200)
  end

  local first_look = true
  local visitedy = {}
  f = function()
    -- 0.1 是 从干员列表退出后 取消连续点击 保证滑动手势有效
    -- 0.5 是 首次进入界面时 需要多点时间
    local timeout = first_look and .5 or .1
    -- local timeout = .1
    local p
    first_look = false
    if not appear("入驻干员", timeout) then return end

    local last_time_see_plus = time()
    if not wait(function()
      if findOne("确认蓝") then return true end
      if findOne("撤下干员") then
        p = findOne("入驻干员")
        if p then
          tap(p)
          last_time_see_plus = time()
        elseif time() - last_time_see_plus > 1000 then
          return true
        end
      end
    end, 10) then return end

    if not findOne("确认蓝") then return true end

    local limit = findOne("清空选择") and 5 or 1

    if p then
      -- 处理异格干员:出现同高度第二次缺人，不清空从后往前选人。还是要等鹰角更新。
      log('visitedy', visitedy)
      local height = tostring(p[2])

      -- 多次进入同一高度，直接翻页
      if (visitedy[height] or 0) > 2 then
        if not wait(function()
          if findOne("撤下干员") then return true end
          tap("确认蓝")
        end, 5) then return end
        return
      end

      -- 两次进入同一高度，从后往前选
      -- visitedy[height] = 1
      if (visitedy[height] or 0) > 0 then
        visitedy[height] = visitedy[height] + 1
        log(676, limit, height)
        if not wait(function()
          if findOne("筛选取消") then return true end
          tap("筛选")
        end, 5) then return end
        if not wait(function()
          if not findOne("筛选取消") then return true end
          tap("筛选确认")
        end, 5) then return end

        if not wait(function()
          if findOne("筛选横线") and findOne("筛选") then
            return true
          end
        end, 5) then return end
        ssleep(0.5)
        tapAll(map(function(j) return "干员选择列表" .. j end,
                   range(2 * limit, limit + 1, -1)))
        if not wait(function()
          if findOne("撤下干员") then return true end
          tap("确认蓝")
        end, 5) then return end
        return true
      end

      visitedy[height] = (visitedy[height] or 0) + 1
    end

    if not wait(function()
      if findOne("筛选取消") then return true end
      tap("筛选")
    end, 5) then return end

    if not appear({"筛选未进驻选中", "筛选未进驻"}) then return end
    if not appear({"筛选技能降序", "筛选技能", "筛选技能升序"}) then
      return
    end

    if not findOne("筛选未进驻选中") then
      if not wait(function()
        if findOne("筛选未进驻选中") then return true end
        tap("筛选未进驻选中")
        appear("筛选未进驻选中", .5)
      end, 5) then return end
    end

    if prefer_skill and not findOne("筛选技能降序") then
      if not wait(function()
        if findOne("筛选技能降序") then return true end
        tap("筛选技能降序")
        appear("筛选技能降序", .5)
      end, 5) then return end
    end

    if not wait(function()
      if not findOne("筛选取消") then return true end
      tap("筛选确认")
    end, 5) then return end

    if not wait(function()
      -- and findOne("筛选横线") and
      -- findOne("筛选")
      if findOne("干员未选中") and findOne("第一干员未选中") then
        return true
      end
      tap("清空选择")
    end, 5) then return end

    log("limit", limit)

    if not wait(function()
      if not findOne("干员未选中") then return true end
      tapAll(map(function(j) return "干员选择列表" .. j end,
                 range(1, limit)))
      disappear("干员未选中", 0.5)
    end, 5) then return end

    if not wait(function()
      if findOne("撤下干员") then return true end
      tap("确认蓝")
    end, 5) then return end

    return true
  end

  local bottom
  local reach_bottom = false
  for i = 1, 15 do
    if i ~= 1 then
      swipd()
      -- TODO wait bottom for stable
      if not appear(bottom, .2) then reach_bottom = true end
    end
    visitedy = {}
    while f() do log(475) end
    if reach_bottom then break end
    -- sample bottom after first detect
    if not bottom then bottom = sample("进驻总览底部") end
  end
  if not findOne("撤下干员") then return end
  tap("返回")
  if appear("进驻总览") then leaving_jump = true end
end

path.基建换班 = function()
  if not disable_dorm_shift then path.宿舍换班() end
  if prefer_speed == 1 then
    path.制造换班()
    path.贸易换班()
  end
  path.总览换班()
end

path.制造加速 = function()
  path.跳转("基建")
  local station
  for i = 1, #point.基建左侧列表 do
    local x, y = table.unpack(point["基建左侧列表" .. i])
    log(x, y, default_findcolor_confidence)
    log(type(default_findcolor_confidence))
    if compareColor(x, y, "#FFCC00", default_findcolor_confidence) then
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

  local f

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

  -- 进入可控状态
  if not wait(function()
    if not findOne("线索传递") then return true end
    tapCard("线索布置列表1")
  end, 5) then return end

  -- 回到线索主界面，处理交流结束情况
  if not wait(function()
    if findOne("线索传递") then return true end
    tap("解锁线索上")
    if findOne("本次线索交流活动") then
      log("find本次线索交流活动")
      tap("返回")
      -- 只能用返回必须等待
      disappear("本次线索交流活动", .5)
    end
  end, 5) then return end

  -- 等待前一任务的通知消失
  appear("接收线索白", 5)

  -- 接收线索
  wait(function()
    if not findOne("线索传递") then return true end
    if not findOne("接收线索有") then return true end
    if not wait(function()
      if not findOne("线索传递") then return true end
      tap("接收线索有")
    end, 5) then return true end

    if not appear("接收线索", 5) then return true end
    wait(function() tap("全部收取") end, 1)

    if not wait(function()
      if findOne("线索传递") then return true end
      tap("解锁线索上")
    end, 5) then return true end
  end, 10)
  if not findOne("线索传递") then return end

  -- 信用奖励，已满则传递线索
  f = function(retry)
    if retry > 10 or no_friend then return true end

    -- 进入信用奖励界面
    if not wait(function()
      if findOne("信用奖励返回") then return true end
      tap("信用奖励有")
    end, 5) then return end

    -- 已满则传递，并循环
    if not appear("未达线索上限", .2) then
      tap("返回")
      appear("线索传递")
      clue_unlocked = false
      path.线索布置()
      if not clue_unlocked then path.线索传递() end
      return f(retry + 1)
    end

    -- 未满则收取奖励
    if findOne("信用奖励领取") then
      if not wait(function()
        if findOne("线索传递") then return true end
        tap("信用奖励领取")
      end, 5) then return end
    else
      tap("返回")
    end

    -- 确保回到线索界面，退出
    if not appear("线索传递") then return end
    return true
  end
  if not f(0) then return end
  if not appear("线索传递") then return end
  path.线索布置()
end

-- tap with offset -50,50
tapCard = function(k)
  local x, y = point[k]:match("(%d+)" .. coord_delimeter .. "(%d+)")
  tap({tonumber(x) - 50, tonumber(y) + 50})
end

path.线索布置 = function()
  -- internal
  if not findOne("线索传递") then
    log("线索布置未找到线索传递")
    return
  end
  log(643)

  -- 在左侧判断，不会右侧提示挡住
  wait(function()
    if findOne("线索布置展开") and disappear("线索布置白列表5", 1) then
      return true
    end
    tap("线索布置5")
  end, 5)

  log(644)
  if true then
    for i = 1, 7 do
      if findOne("线索布置左列表" .. i) then
        p = "线索布置左列表" .. i

        wait(function()
          if findOne("线索布置白列表" .. i) then return true end
          tapCard(p)
        end, 2)
        if not wait(function()
          if not findOne(p) then return true end
          tap("线索库列表1")
          tap("线索库列表1")
          disappear(p, 5)
        end, 20) then return end
      end
    end
    log(648)
    if not wait(function()
      if findOne("线索传递") then return true end
      tap("解锁线索上")
    end, 10) then return end
  end

  if findOne("解锁线索") then
    clue_unlocked = true

    wait(function() tap("解锁线索") end, .5)

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
  -- log(827)
  if not findTap("线索传递") then return end
  -- log(828)
  if not appear("线索传递数字列表8", 10) then return end
  if not appear("线索传递有好友", .5) then
    no_friend = true
    wait(function()
      if findOne("线索传递") then return true end
      tap("线索传递返回")
    end, 10)
    return
  end

  for i = 1, 8 do
    if not wait(function()
      if findOne("线索传递数字列表" .. i) then return true end
      tap("线索传递数字列表" .. i)
    end, 5) then return end
    log(653)
    if findOne("线索传递数字重复") and findOne("线索列表1") then
      break
    end
    log(654)
  end

  if not wait(function()
    if not findOne("线索列表1") or findOne("线索按下列表1") then
      return true
    end
    tap("线索列表1")
  end, 5) then stop(1098) end

  local f = function(random)
    local idx
    if random then
      idx = 1 -- 有人只有一个好友
    else
      for _, p in pairs(findOnes("线索传递橙框")) do
        log(857, p)
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

    if idx then
      log("线索传递", idx, point.传递列表[idx])
      if fake_transfer then exit() end
      tap(point.传递列表[idx])
      wait(function()
        if findOne("线索传递") then return true end
        tap("线索传递返回")
      end, 10)
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
    log(state, point['sample'])
    tap("线索传递右白")
    disappear(state, .5)
  end, 30) then stop(1146) end
end

path.任务收集 = function()
  path.跳转("任务")

  if speedrun then
    -- 只保留日常任务
    point.任务有列表2 = nil
    point.任务有列表4 = nil
  end

  for i = 1, #point.任务有列表 do

    log(794, i)
    if findOne("任务有列表" .. i) then
      log(795, i)

      -- nagivate to tab
      if not wait(function()
        if findOne("收集全部") then return true end
        tap("任务有列表" .. i)
      end, 10) then return end

      -- 判定是否有剩余红点
      local remain = findAny(table.slice(point.任务有列表, i + 1))

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

        -- 等待剩余红点出现
        if remain then appear(remain) end
      end
    end
  end
end

path.信用购买 = function()
  path.跳转("采购中心")
  if not wait(function()
    if findAny({"信用交易所列表1", "信用交易所已购列表1"}) then
      return true
    end
    tap("信用交易所2")
  end, 10) then return end

  if findOne("收取信用有") then
    local f = function()

      if not wait(function()
        if not findOne("信用交易所横线") then return true end
        tap("收取信用有")
      end, 5) then return end

      if not wait(function()
        if findOne("信用交易所横线") then return true end
        tap("收取信用有")
      end, 5) then return end

      -- 危机合约期间启用
      if during_crisis_contract and disappear("信用交易所横线", 1) then
        if not wait(function()
          if findOne("信用交易所横线") then return true end
          tap("收取信用有")
        end, 5) then return end
      end
    end
    f()
  end

  -- 等待前一个任务的提示消失
  disappear("信用不足", 5)

  local f
  f = function(i)
    if not findOne("信用交易所横线") then

      if not wait(function()
        if findOne("信用交易所横线") then return true end
        tap("收取信用有")
      end, 5) then return end

    end

    log(832)
    if not appear({
      "信用交易所列表" .. i, "信用交易所已购列表" .. i,
    }) then return end
    log(833)

    if not findOne("信用交易所列表" .. i) then
      log(845, i)
      return
    end

    -- 获取遗漏物品
    for j = 1, i do
      if findOne("信用交易所列表" .. j) then
        i = j
        break
      end
    end

    if not wait(function()
      if not findOne("信用交易所横线") then return true end
      tap("信用交易所列表" .. i)
      -- 快速点击物品导致二次弹出 或 弹不出
      -- disappear("信用交易所横线", .1)
    end, 5) then return end

    if not wait(function()
      if findAny({"信用交易所横线", "信用不足"}) then
        return true
      end
      tap("购买物品")
    end, 5) then return end

    if findOne("信用不足") then
      log("信用不足")
      return true
    end

    log(830)
    disappear("信用交易所横线", 5)
    log(831)

    if not wait(function()
      if findOne("信用交易所横线") then return true end
      tap("信用交易所2")
    end, 5) then
      log(832)
      return
    end
  end
  if speedrun then return f(2) end
  for i = 1, 10 do if f(i) then return end end
end

get_fight_type = function(x)
  local f = startsWithX(x)
  if table.any({"PR", "CE", "CA", "AP", "LS", "SK"}, f) then
    return "物资芯片"
  elseif table.any(table.values(jianpin2name), f) then
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

path.轮次作战 = function()
  -- path.跳转("首页")
  pre_fight = nil
  no_success_one_loop = 0
  while not zero_san do
    if #fight == 0 then return true end
    fight_tick = fight_tick % #fight + 1
    if fight_tick == #fight then
      no_success_one_loop = no_success_one_loop + 1
      if no_success_one_loop > 5 then break end
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
  DQWT = "当期委托",
  -- JSCK = "积水潮窟",
  -- CMHB = "潮没海滨",
  LMSQ = "龙门市区",
  LMWH = "龙门外环",
  QENBG = "切尔诺伯格",
  -- BYBFFC = "北原冰封废城",
  -- DQSLJW = "大骑士领郊外",
  -- FQKQ = "废弃矿区",
}
extrajianpin2name = {SYC = "上一次"}

path.作战 = function(x)
  log(table.values(jmfight2name), x)
  local f = startsWithX(x)
  if table.any({"上一次"}, f) then
    path.上一次(x)
  elseif table.any({"PR", "CE", "CA", "AP", "LS", "SK"}, f) then
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
  if x == "1-11" then return path["1-11"] end

  -- TODO 活动时需要注意这个地方，活动关的代理指挥不长这样
  -- 目的是剿灭
  -- if not appear("代理指挥开", 1) then return end
  -- log(findOne("开始行动"))
  -- log(findOne("返还规则"))
  -- log(findOne("报酬合成玉已满"))
  -- log(findOne("开始行动"))
  -- safeexit()

  if not appear("代理指挥开", .5) then
    tap("代理指挥开")
    if not appear("代理指挥开", .5) then return end
    -- if not wait(function()
    --   if findOne("代理指挥开") and not disappear("代理指挥开", .5) then
    --     return true
    --   end
    --   tap("代理指挥开")
    --   appear("代理指挥开", .5)
    -- end, 5) then return end
  end

  if is_jmfight_enough(x) then return end

  -- quick tap .5s
  wait(function()
    if not findOne("代理指挥开") then return true end
    tap("开始行动蓝")
  end, .5)

  local state = nil
  local start_time = time()
  if not wait(function()
    state = findAny({
      "开始行动红", "源石恢复理智取消", "药剂恢复理智取消",
      "单选确认框", "源石恢复理智不足",
    })
    if state == "单选确认框" then return true end
    if state == "开始行动红" then return true end
    if state and not disappear(state, .5) then return true end

    if findOne("开始行动") then
      tap("开始行动蓝")
      -- TODO 2秒太慢 => 一开始就用0秒, 2秒内增加至2秒
      disappear("开始行动", min(2, (time() - start_time) / 1000 * 2 / 2))
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
    if not appear({"接管作战", "单选确认框"}, 20) then
      log(1430)
      return
    end
    if findOne("单选确认框") then return end
    return path.base.接管作战()
  elseif stone_times < max_stone_times and state == "源石恢复理智取消" or
    drug_times < max_drug_times and state == "药剂恢复理智取消" then
    if state == "源石恢复理智取消" then
      stone_times = stone_times + 1
    else
      drug_times = drug_times + 1
    end

    if not wait(function()
      if findOne("开始行动") then return true end
      if findOne(state) then
        tap("药剂恢复理智确认")
        disappear(state, 10)
      end
    end, 10) then return end
    return path.开始游戏(x)
  elseif state == "源石恢复理智取消" or state ==
    "药剂恢复理智取消" or state == '源石恢复理智不足' then
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
  local state_with_home = function(y)
    local f = function() return findOne("主页") and findOne(y) end
    return f
  end
  local go = function()
    -- TODO 怎么省掉
    ssleep(.5)
    log(928, x)
    swip(x)
    tap("作战列表" .. x)
    appear("开始行动")
  end
  local p
  p = {
    [state_with_home("当前进度列表" .. chapter_index)] = function()
      go()
      return true
    end,
    [state_with_home("按下当前进度列表" .. chapter_index)] = function()
      go()
      return true
    end,
  }
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
      p[state_with_home("当前进度列表" .. i)] =
        "当前进度列表" .. (i > chapter_index and "左" or "右")
      p[state_with_home("按下当前进度列表" .. i)] =
        p["当前进度列表" .. i]
    end
  end

  log(1040)
  if not findAny(table.keys(p)) then
    log(1041)
    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end
    if not wait(function()
      if findOne("主题曲界面") then return true end
      tap("主题曲")
    end) then return end

    if chapter_index <= 4 then
      -- 从上到下，命中第一篇, 专为还没过3-8的玩家
      ssleep(.5)
      tap("觉醒")
      tap("幻灭")
      ssleep(.5)
    elseif chapter_index <= 9 then
      -- 只打到3-8，第9章也会解锁，无需特殊处理
      ssleep(.5)
      tap("幻灭")
      ssleep(.5)
    end

    if not appear("怒号光明") then return end

    log("1046", chapter)
    if distance['' .. chapter] then swipc() end

    if not wait(function()
      if not findOne("怒号光明") then return true end
      tap("作战主线章节列表" .. chapter)
    end, 3) and not wait(function()
      if not findOne("怒号光明") then return true end
      tap("作战主线章节列表" .. 8)
    end, 3) then return end
    if not appear(table.keys(p), 5) then return end
  end
  -- 10秒内需要完成章节切换
  auto(p, nil, 10, 10)
  path.开始游戏(x)
end

path.上一次 = function(x)
  log("1265")
  if findOne("开始行动") then return path.开始行动(x) end
  log("1266")
  path.跳转("首页")
  tap("面板作战")
  if not appear("主页") then return end
  wait(function()
    if not findOne("主页") then return true end
    tap("上一次")
  end, 5)
  if not appear("开始行动", 5) then return end
  -- 专为剿灭设计
  -- 但活动时可能有点问题会，因为
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
    -- if auto_clean_fight then
    log("before fight clean", fight, fight_tick)
    local unavailable_fight = type == "pr" and x:sub(1, 4) or x:sub(1, 2)
    log("unavailable_fight", unavailable_fight)
    fight, fight_tick = clean_table(fight, fight_tick, function(v)
      return v:startsWith(unavailable_fight)
    end)
    log("after fight clean", fight, fight_tick)
    -- end
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

  local fight_notation = "作战列表" .. x:sub(1, #x - 1) .. "0"
  if not findOne(fight_notation) then
    path.跳转("首页")
    tap("面板作战")
    if not appear("主页") then return end

    if not wait(function()
      if findOne("主题曲界面") then return true end
      tap("主题曲")
    end) then return end

    -- if not wait(function()
    --   if findOne("资源收集", 90) and not findOne("主题曲", 90) and
    --     not findOne("每周部署", 90) then return true end
    wait(function()
      if not findOne("主题曲界面") then return true end
      tap("资源收集")
    end)
    -- end) then return end
    -- if not wait(function()
    --   if findOne("资源收集", 90) then return true end
    --   tap("资源收集")
    -- end) then return end
    -- ssleep(.5)
    -- tap("资源收集")
    ssleep(.2)
    log("资源收集", index, point["资源收集列表" .. index])
    local p = point["资源收集列表" .. index][1]
    if p < 0 then
      swipq(distance["资源收集列表1"])
      tap("资源收集最左列表" .. index)
    elseif p > screen.width - 1 then
      swipq(distance["资源收集列表9"])
      tap("资源收集最右列表" .. index)
    else
      tap("资源收集列表" .. index)
    end
    appear(fight_notation)
  end
  if findOne(fight_notation) then
    tap("作战列表" .. x)
    appear("开始行动")
    path.开始游戏(x)
  end
end

clean_jmfight = function()
  -- if auto_clean_fight then
  log("before fight clean", fight, fight_tick)
  -- local unavailable_fight = type == "pr" and x:sub(1, 4) or x:sub(1, 2)
  -- log("unavailable_fight", unavailable_fight)
  fight, fight_tick = clean_table(fight, fight_tick, function(v)
    return get_fight_type(v) == '剿灭'
  end)
  log("after fight clean", fight, fight_tick)
  -- end
end

is_jmfight_enough = function(x, outside)
  log("is_jmfight_enough", x)
  if ignore_jmfight_enough_check then return false end

  -- all fights should check first, because x may not be in jmfight
  if findOne("报酬合成玉已满") and findOne("返还规则") then
    log("find报酬合成玉已满")
    jmfight_enough = true
    clean_jmfight()
    return true
  end

  -- use state, jmfight only
  if not table.includes(table.values(jianpin2name), x) then
    log(1738)
    return false
  end
  if jmfight_enough then return true end

  if not outside and findOne("报酬合成玉已满") or outside and
    findOne("报酬合成玉已满2") then
    log("find报酬合成玉已满")
    jmfight_enough = true
    clean_jmfight()
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

  if not wait(function()
    if findOne("主题曲界面") then return true end
    tap("主题曲")
  end) then return end

  wait(function()
    if not findOne("主题曲界面") then return true end
    tap("每周部署")
  end)

  -- if not wait(function()
  --   if findOne("每周部署", 90) and not findOne("主题曲", 90) and
  --     not findOne("资源收集", 90) then return true end
  -- tap("每周部署")
  -- end) then return end
  -- if not wait(function()
  --   if findOne("每周部署", 90) then return true end
  --   tap("每周部署")
  -- end) then return end

  if not findOne("主页") then return end
  if not wait(function()
    -- if is_jmfight_enough(x, true) then return true end
    if not findOne("主页") then return true end
    tap("当期委托")
  end, 5) then return end
  if is_jmfight_enough(x) then return end
  if not appear("开始行动", 5) then return end
  if is_jmfight_enough(x) then return end
  -- if x ~= "当期委托" then
  -- -- 非当期委托需要切换
  if x ~= "unknown" then
    -- 都需要切换
    if not wait(function()
      if findOne("切换") then return true end
      tap("主页右侧")
    end, 5) then return end
    if is_jmfight_enough(x) then return end
    if not wait(function()
      if findOne("当前委托侧边栏") then return true end
      tap("切换")
      appear("当前委托侧边栏")
    end, 5) then return end
    if not wait(function()
      if not findOne("当前委托侧边栏") then return true end
      tap("作战列表" .. x)
    end, 5) then return end

    log(1287)
  end
  if is_jmfight_enough(x) then return end
  log(1289)
  -- ssleep(1)
  -- log(1290)
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
  no_success_one_loop = 0
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
  end, 5) then return end
  if speedrun then
    disappear("正在提交反馈至神经", 20)
    appear("主页", 5)
    return
  end

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
    tap("访问下位橘")
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
    local see
    if speedrun then
      see = "公开招募列表" .. i
    else
      -- 有灰，等待检测所有状态
      see = appear({
        "聘用候选人列表" .. i, "公开招募列表" .. i,
        "立即招募列表" .. i,
      })
    end
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
      end, 10) then return end
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
          if not findOne("公开招募箭头") then return true end
          tap("公开招募点击列表" .. i)
        end, 10) then return end
        if not appear("公开招募时间减") then return true end
        if not wait(function()
          if not findOne("公开招募时间减") then return true end
          tap("公开招募确认蓝")
        end, 10) then return end
        if not appear("公开招募箭头") then return end
        success = success + 1
        return
      end

      if not wait(function()
        if not findOne("公开招募箭头") then return true end
        tap("公开招募点击列表" .. i)
      end, 5) then return end

      g = function(pre_tags)
        local tags, r
        wait(function()
          r = point["公开招募标签框范围"]
          r = ocrEx(r[1], r[2], r[3], r[4]) or {}
          tags = {}
          for _, p in pairs(r) do
            p.text = tagFix(p.text) -- 替换常见错别字
            if table.includes(tag, p.text) then -- 处理已知tag
              tags[p.text] = {(p.l + p.r) // 2, (p.t + p.b) // 2}
            else -- 出现未知文字，重试
              tags = {}
              return
            end
          end
          if #table.keys(tags) >= 5 and not table.equalKey(tags, pre_tags) then
            return true
          end
          log(1091, tags)
        end, 2)

        local skip = false
        if #table.keys(tags) < 5 then skip = true end

        log(1092, tags, skip)
        -- exit()
        local tag4 = table.filter(tag5, function(rule)
          return table.all(rule[1], function(m) return tags[m] end)
        end)
        log(1093, tag4)
        -- toast(JsonEncode(tags))

        if #tag4 == 0 or skip then
          if not skip and findTap("公开招募标签刷新蓝") then
            if not disappear("公开招募时间减") then return end
            if not wait(function()
              if findOne("公开招募时间减") then return true end
              tap("公开招募右确认")
            end, 5) then return end
            if not appear("公开招募时间减") then return end
            return g(tags)
          else
            if not wait(function()
              if findOne("公开招募箭头") and
                findOne("公开招募列表" .. i) then return true end
              if findOne("公开招募时间减") then
                tap("返回")
                disappear("公开招募时间减", 1)
              end
            end, 5) then return end
          end
        else
          -- 最大星数
          local max_star = 0
          local list
          for _, v in pairs(tag4) do
            if max_star < v[2] then
              max_star = v[2]
              list = v[1]
            end
          end

          if max_star > 0 and not _G['auto_recruit' .. max_star] then
            log("notify 存在", max_star, list)
            table.insert(qqmessage, "可招募：" .. table.join(list))
          end

          if max_star > 0 and _G['auto_recruit' .. max_star] then
            for _, v in pairs(list) do tap(tags[v]) end
            if max_star == 1 then
              -- 3.5小时
              tap("公开招募时间加")
              tap("公开招募时间加")
              tap("公开招募时间加")
              tap("公开招募时间减2")
            else
              -- 9小时
              tap("公开招募时间减")
            end
            if fake_recruit then
              log("fake_recruit", list)
              tap("返回")
            else
              tap("公开招募确认蓝")
            end
            if not appear("公开招募箭头") then return end
          end
        end
      end
      g()
    end
  end
  for i = 1, 4 do
    f(i)
    if speedrun and i >= 3 then break end
  end
  appear("主页", .5)
end

path.干员升级 = function()
  if no_update_operator then return end
  path.跳转("首页")

  -- this will enforce we not see 面板
  tap("面板干员")

  if not wait(function()
    if findOne("副手确认蓝") then return true end
    tap("升级")
  end, 5) then return end

  appear(point.录像列表)

  tap("清空选择")

  findTap(point.录像列表)
  tap("副手确认蓝")
  -- TODO 0.1等待仍然可能直接跳转走，
  ssleep(.2)
end

path.每日任务速通 = function()
  -- inspired by 1m57s https://www.bilibili.com/video/BV1P341167fe
  -- and 56s https://www.bilibili.com/video/BV1aM4y1L72i
  speedrun = true

  path.干员升级()
  path.基建收获()

  -- 宿舍换班 2次， may be this should be removed
  path.跳转("基建")
  f = function(i, last)
    if not wait(function()
      if not findOne("进驻总览") or not findOne("缩放结束") then
        return true
      end
      tap("宿舍列表" .. i)
    end) then return end
    if not appear({"进驻信息", "进驻信息选中"}, 5) then return end
    if not wait(function()
      if findOne("筛选") then return true end
      if findOne("进驻信息选中") then
        wait(function()
          if findOne("筛选") then return true end
          tap("进驻第一人")
        end, 1)
      elseif findOne("进驻信息") then
        tap("进驻信息")
        ssleep(.2)
        wait(function()
          if findOne("筛选") then return true end
          tap("进驻第一人")
        end, 1)
      end
    end, 5) then return end

    if not wait(function()
      -- and findOne("筛选横线")
      if findOne("干员未选中") and findOne("第一干员未选中") then
        return true
      end
      tap("清空选择")
    end, 5) then return end
    -- local state = sample("心情")
    -- tap("心情")
    -- disappear(state, 1)
    -- state = sample("心情")
    -- tap("心情")
    -- disappear(state, 1)
    -- for j = 6, 6 + 6 do tap("干员选择列表" .. j) end
    tapAll(map(function(j) return "干员选择列表" .. j end, range(6, 10)))
    -- tapAll({
    --   "干员选择列表6", "干员选择列表7", "干员选择列表8",
    --   "干员选择列表9", "干员选择列表10",
    --   -- "干员选择列表11",
    --   -- "干员选择列表12",
    -- })

    local exit_state = {"进驻信息", "进驻信息选中"}
    if last then table.insert(exit_state, "正在提交反馈至神经") end
    if not wait(function()
      if findAny(exit_state) then return true end
      tap("确认蓝")
    end, 5) then return end
  end

  f(1)
  f(1, true)
  path.信用购买()
  path.公招刷新()

  path.任务收集()
end

path.满练每日任务速通 = function()
  no_update_operator = true
  return path.每日任务速通()
end

path.指定换班 = function()
  if true then return end
  -- if not debug then return end
  -- 按设置跳转到依次制造、贸易、控制中枢、办公室
  -- path.跳转("基建")
  local f
  local count = {}
  f = function(i)
    -- judge the type of facility i, and check if we need to do
    local type, facility, operator
    local x, y = table.unpack(point["基建列表" .. i])
    if i <= 9 then
      path.跳转("基建")
      if not wait(function()
        if type then return true end
        if compareColor(x, y, "#FFCC00", default_findcolor_confidence) then
          type = "制"
        elseif compareColor(x, y, "#33CCFF", default_findcolor_confidence) then
          type = "贸"
        elseif compareColor(x, y, "#CCFF66", default_findcolor_confidence) then
          type = "发"
        end
      end, 2) then return end

    elseif i == 10 then
      type = "控"
    elseif i <= 14 then
      type = "宿"
    elseif i == 15 then
      type = "会"
    elseif i == 16 then
      type = "加"
    elseif i == 17 then
      type = "办"
    end
    if not type then return end
    -- log(count, type)
    count[type] = (count[type] or 0) + 1
    facility = type .. count[type]
    operator = facility2operator[facility]
    if not operator or #operator == 0 then return end
    log(facility, operator)

    path.跳转("基建")
    if not wait(function()
      if not findOne("进驻总览") or not findOne("缩放结束") then
        return true
      end
      tap({x, y})
    end, 10) then return end

    if not appear({"进驻信息", "进驻信息选中"}, 5) then return end
    if not wait(function()
      if findOne("确认蓝") then return true end
      if findOne("进驻信息选中") and
        not disappear("进驻信息选中", .5) then
        tap("进驻第一人左")
      elseif findOne("进驻信息") then
        tap("进驻信息")
        disappear("进驻信息", .5)
      end
    end, 5) then return end

    -- tap("清空选择")
    if not wait(function()
      if findOne("确认蓝") and findOne("干员未选中") then
        return true
      end

      tap("清空选择")

    end, 5) then return end

    if not wait(function()
      if findOne("筛选取消") then return true end
      tap("筛选")
    end, 5) then return end

    if not appear({"筛选未进驻选中", "筛选未进驻"}) then return end
    if not appear({"筛选技能降序", "筛选技能", "筛选技能升序"}) then
      return
    end

    if not findOne("筛选未进驻") then
      if not wait(function()
        if findOne("筛选未进驻") then return true end
        tap("筛选未进驻")
        appear("筛选未进驻", .5)
      end, 5) then return end
    end

    if not findOne("筛选技能降序") then
      if not wait(function()
        if findOne("筛选技能降序") then return true end
        tap("筛选技能降序")
        appear("筛选技能降序", .5)
      end, 5) then return end
    end

    -- if not findOne("筛选未进驻") then tap("筛选未进驻") end
    -- if not findOne("筛选技能降序") then tap("筛选技能降序") end
    if not wait(function()
      if not findOne("筛选取消") then return true end
      tap("筛选确认")
    end, 5) then return end
    appear("筛选横线", 1)
    ssleep(1)
    swipo(true)
    ssleep(2)
    findtap_operator_fast(operator)
    swipo(true)

    if not wait(function()
      if findAny({
        "隐藏", "进驻信息", "进驻信息选中",
        "正在提交反馈至神经",
      }) then return true end
      tap("确认蓝")
    end, 5) then return end
  end
  for i = 1, #point.基建列表 do f(i) end
end

path["克洛丝单人1-12"] = function()
  -- TODO
end

path.退出账号 = function()
  auto(update(path.base, {
    bilibili_framelayout_only = false,
    [function()
      return findOne("bilibili_framelayout_only") and
               not findOne("bilibili_login")
    end] = function() auto(path.bilibili_login_change) end,
    面板 = function()
      tap("面板设置")
      if not appear("返回3") then return end
      wait(function()
        tap("退出登录" .. (appid == oppid and '' or '2'))
        tap("右确认")
      end, 1)
    end,
    开始唤醒 = "账号管理",
    bilibili_login = true,
    手机验证码登录 = true,
  }, nil, true), path.fallback)
end
