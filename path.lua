path = {}

-- base 只在跳转时使用，如果在任务中间需要登录失效，则当前任务超时后，下一任务的跳转会重新登录。
-- base 应覆盖尽可能多的corner case。
-- wait_game_up 每5秒执行一次，保证游戏在前台，别点到其他应用。
-- wait_game_up 有必要在游戏中自动亮屏吗：有
-- wait_game_up 有必要在切出游戏后回到游戏吗：有
-- wait_game_up 有必要做B服界面跳转吗：没有。做了之后，退出账号难实现

path.base = {
  面板 = function()
    login_error_times = 0
    return true
  end,
  下载资源确认 = "下载资源确认",
  资源下载确定 = "资源下载确定",
  start黄框 = function()
    wait(function()
      tap("适龄提示")
      tap("保持配音")
      tap("保持配音确定")
      tap("start黄框")
    end)
  end,
  start黄框暗 = function() return path.base["start黄框"]() end,
  账号登录 = function() tap("账号登录") end,
  开始唤醒 = function()
    check_login_frequency()
    wait(function()
      tap("开始唤醒")
      disappear("开始唤醒")
    end, 5)
  end,
  手机验证码登录 = disable_game_up_check_wrapper(function()
    if appid ~= oppid then return end
    if not username or #username == 0 or not password or #password == 0 then
      -- 单账号直接停，多账号跳过
      stop("账号或密码为空", account_idx and 'next' or '')
    end
    if #username > 0 then
      log(44)
      if not wait(function()
        tap("账号左侧")
        tap("账号")
        -- if disappear("手机验证码登录", 1) then return true end
        if appear('inputbox', 1) then return true end
      end, 10) then return end
      log(45)
      -- if not appear('inputbox') then return end
      -- ssleep(1) -- 等待输入法弹出
      -- if debug_mode then toast(username) end
      -- ssleep(.5) -- 等待输入法弹出
      if not wait(function()
        wait(function() input("inputbox", username) end, 1)
        log(45.1)
        tap("okbutton")
        -- appear("手机验证码登录")
        if appear("手机验证码登录", 1) and not findOne("okbutton") then
          return true
        end
        log(45.2)
      end, 3) then return end
      log(46)
    end
    if not appear("手机验证码登录", 1) then return end

    if #password > 0 then
      log(44)
      -- if debug_mode then toast(password) end
      if not wait(function()
        tap("账号左侧")
        tap("密码")
        -- if disappear("手机验证码登录", 1) then return true end
        if appear('inputbox', 1) then return true end
      end, 10) then return end
      log(45)
      -- if not appear('inputbox') then return end
      -- ssleep(1) -- 等待输入法弹出
      -- if debug_mode then toast(password) end
      -- ssleep(.5) -- 等待输入法弹出
      if not wait(function()
        wait(function() input("inputbox", password) end, 1)
        log(45.1)
        tap("okbutton")
        -- appear("手机验证码登录")
        if appear("手机验证码登录", 1) and not findOne("okbutton") then
          return true
        end
        log(45.2)
      end, 3) then return end
      log(46)
      -- appear("手机验证码登录")
    end

    log(47)
    if not appear("手机验证码登录", 1) then return end
    log(48)

    -- local login_error_times = 0
    wait(function(reset_wait_start_time)
      tap("登录")
      local p = appear({
        "captcha", "密码不能为空", "单选确认框", "注册协议",
      }, 2)
      log(p)
      if p == "注册协议" then return true end
      if p == 'captcha' then
        trySolveCapture()
        appear("单选确认框")
      end
      if p == "密码不能为空" or p == "单选确认框" then
        return true
      end
    end, 4)
    if findTap("单选确认框") then
      log("login_error_times", login_error_times)
      login_error_times = (login_error_times or 0) + 1
    end
    -- 两次，第一次可能是数据更新
    if login_error_times > 1 then
      stop("单选确认框，密码错误？", account_idx and 'next' or '')
    end
  end),
  正在释放神经递质 = function()
    if not disappear("正在释放神经递质", 1800, 1) then
      stop("正在释放神经递质超半小时", 'cur')
    end
  end,
  接管作战 = function()
    -- 超时5分钟后重启游戏
    if not wait(function()
      if not findOne("接管作战") then return true end
      -- log(126)
      if findOne("暂停中") then
        tap("开包skip")
        disappear("暂停中")
      end
    end, 5 * 60) then return restartapp(appid) end
    -- log(127)

    -- if not disappear("接管作战", 8 * 60 * 60, 1) then
    --       stop("接管作战超8小时")
    --     end

    -- this calllback only works for 主线、资源、剿灭
    local unfinished

    local first_time_see_zero_star
    local zero_star
    local see_end
    local unexpect_return
    local home
    local normal

    if not wait(disable_log_wrapper(function()
      if findOne("行动结束") then see_end = true end
      if findOne("行动结束") and findOne("零星代理") then
        first_time_see_zero_star = first_time_see_zero_star or time()
        -- 实测560秒，给两倍
        if time() - first_time_see_zero_star > 1200 then zero_star = true end
      end

      if findOne("开始行动") and findOne("代理指挥开") and
        findOne("主页") then
        log(59)
        normal = true
        return true
      end

      if findOne("接管作战") then
        unfinished = true
        return true
      end

      if findOne("剿灭接管作战") and
        not disappear("剿灭接管作战", 5) then
        captureqqimagedeliver(table.join(qqmessage, ' ') .. " " .. cur_fight ..
                                "剿灭接管作战", true)
        tap("剿灭接管作战")
        ssleep(2)
        tap("面板设置", true)
        ssleep(2)
        tap("放弃行动")
        ssleep(2)
        tap("右确认")
      end

      if findOne("剿灭记录确认") and
        not disappear("剿灭记录确认", 5) then
        captureqqimagedeliver(table.join(qqmessage, ' ') .. " " .. cur_fight ..
                                "剿灭记录确认", true)
        tap("剿灭记录确认")
      end

      -- 战斗记录未同步
      if findOne("返回确认界面") then
        tap("左取消")
        unexpect_return = true
      end

      -- 掉线
      if findAny({
        "开始唤醒", "bilibili_framelayout_only", "手机验证码登录",
      }) then
        home = true
        log(60)
        return true
      end

      tap("开始行动1")

      appear({"开始行动", "接管作战"}, 1)
    end), 60) then return end

    if unfinished then return path.base.接管作战() end

    log("回到首页")
    log("代理结束", cur_fight, "失败次数", fight_failed_times[cur_fight])
    log(139, first_time_see_zero_star, zero_star)
    log("zero_star", zero_star)
    log("see_end", see_end)
    log("home", home)
    log("normal", normal)
    if zero_star or not see_end or home then
      log("代理失败返回首页")

      if not qqnotify_nofailedfight then
        local info = table.join(qqmessage, ' ') .. " " .. cur_fight ..
                       "代理失败" .. (home and "(掉线或抢登)" or '')
        -- (zero_star and 'zero_star' or '') ..
        -- (see_end and 'see_end' or '') ..
        -- (normal and 'normal' or '')
        captureqqimagedeliver(info, true)
      end
      -- 一次代理失败直接认为无效：不行，因为可能是掉线造成的失败
      fight_failed_times[cur_fight] = max(0, fight_failed_times[cur_fight] or 0)
      log(161)
      return path.跳转("首页")
    end

    table.insert(fight_history, cur_fight)

    fight_times = (fight_times or 0) + 1
    if fight_times >= max_fight_times then
      fight_times = 0
      restartapp(appid)
      return path.跳转("首页")
    end

    log(89, repeat_fight_mode)
    if repeat_fight_mode then return path.开始游戏('') end

    -- current fight success
    pre_fight = cur_fight
    fight_failed_times[cur_fight] = -3

    -- if same fight or same page fight
    local next_fight_tick = fight_tick % #fight + 1
    local next_fight = fight[next_fight_tick]
    log(cur_fight, next_fight)

    if table.includes({"剿灭"}, get_fight_type(cur_fight)) then
      jmfight_times = (jmfight_times or 0) + 1
      if jmfight_times >= max_jmfight_times then clean_jmfight() end
      -- if appear("全权委托", 1) then
      --   wait(function()
      --     tap("全权委托")
      --     if disappear("全权委托", 1) and not disappear("开始行动", 1) then
      --       return true
      --     end
      --   end, 30)
      -- end
      -- 剿灭必须回主页
      -- if not appear("主页") then back() end
      return path.跳转("首页")
    elseif next_fight == cur_fight then
      fight_tick = next_fight_tick
      pre_fight = nil
      if not request_memory_clean() then
        return path.开始游戏(next_fight)
      else
        return path.跳转("首页")
      end
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

  bilibili_framelayout_only = function()
    auto(path.bilibili_login, nil, 0, 300, true)
  end,

  -- bilibili_account_switch = function() auto(path.bilibili_login) end,
}

path.bilibili_login = {
  同意并继续 = function()
    local p = findNode(point["同意并继续"])
    if p then
      clickNodeFalse(p)
      disappear("同意并继续")
    end
  end,
  captcha = function() trySolveCapture() end,
  bgame = true,
  bilibili_license_ok = function() tap("bilibili_license_ok") end,
  bilibili_phone_inputbox = function()
    -- 把输入法关了
    wait(function()
      if findOne("bilibili_account_login") then return true end
      tap("返回")
    end, 5)
    tap("bilibili_account_login")
    appear("bilibili_username_inputbox")
  end,
  -- bilibili_username_inputbox = function()
  --   if not findOne()
  --   tap("返回")
  -- end,
  bilibili_username_inputbox = function()
    log(149)
    -- 把输入法关了
    wait(function()
      if findOne("bilibili_login") then return true end
      tap("返回")
    end, 5)
    if username and #username > 0 and password and #password > 0 then
      wait(function() input("bilibili_username_inputbox", username) end, 1)
      wait(function() input("bilibili_password_inputbox", password) end, 1)
      -- input("bilibili_username_inputbox", username)
      -- input("bilibili_password_inputbox", password)
    else
      stop("账号或密码为空", account_idx and 'next' or '')
    end
    tap("bilibili_login")
    disappear("bilibili_login", 15)
    tap("bilibili_login")
    if not appear({"bilibili_change2", "captcha", {text = "存储"}}, 15) then
      stop("B服登录失败", account_idx and 'next' or '')
    end
    -- 小米
    appearTap({text = "存储"}, 1)
    appear({"bilibili_change2", "captcha"})
  end,
  bilibili_oneclicklogin = function()
    tap("bilibili_oneclicklogin")
    appear({"bilibili_ok", "bilibili_change2"}, 5)
  end,
  bilibili_ok = function()
    tap("bilibili_ok")
    appear("bgame", 5)
  end,
  bilibili_other = function()
    tap("bilibili_other")
    appear("bilibili_phone_inputbox")
  end,
  bilibili_change2 = function()
    if debug_mode then
      if appear("bilibili_account_switch") then
        toast(259)
      else
        toast(258)
      end
      exit()
    end
    check_login_frequency()
    disappear("bilibili_change2", 10)
    log(271)
  end,
}

path.bilibili_login_change = update(path.bilibili_login, {
  bilibili_oneclicklogin = false,
  bilibili_username_inputbox = true,
  bilibili_change2 = function()
    wait(function()
      tap("bilibili_change2")
      -- if appear({"bilibili_change", "bilibili_account_login"}, .5) then
      if appear({"bilibili_change", "bilibili_phone_inputbox"}, .5) then
        return true
      end
    end, 5)
  end,
  bilibili_change = function()
    tap("bilibili_change")
    -- appear("bilibili_account_login")
    appear("bilibili_phone_inputbox")
  end,
}, nil, true)

path.fallback = {
  主题曲已开放 = function()
    tap("主题曲已开放")
    ssleep(1)
    tap("主题曲已开放")
    ssleep(1)
    tap("主题曲已开放")
    ssleep(1)
    back()
  end,
  注册协议 = function()
    tap("注册协议1")
    ssleep(.5)
    tap("注册协议2")
  end,
  阿米娅 = function()
    for k, v in pairs(point.阿米娅右列表) do tap(v) end
    for k, v in pairs(point.阿米娅左列表) do tap(v) end
    tap("返回")
    if appear("阿米娅", 5) then
      ssleep(1)
      return path.fallback.阿米娅()
    end
  end,
  阿米娅2 = function() return path.fallback.阿米娅() end,
  覆巢之下主页 = function() tap("返回") end,
  全权委托 = function()
    wait(function()

      tap("全权委托")
      if not findOne("主页") then tap("开始行动蓝") end
      ssleep(1)

      if not findOne("全权委托") and findOne("代理指挥开") and
        findOne("主页") then return true end

    end, 30)
  end,
  开始行动活动 = function()
    tap("返回")
    appear("主页")
  end,
  线索传递界面 = function() tap("线索传递返回") end,
  查看谢幕表 = function() tap("战略确认") end,
  我知道了 = function() tap("我知道了") end,
  剿灭提示 = function() tap("左上角返回") end,
  获得物资 = function() tap("返回") end,
  战略返回 = function()
    tap("战略返回")
    appear("常规行动", 2)
  end,
  断罪返回 = function()
    tap("断罪返回")
    disappear("断罪返回")
  end,
  -- 断罪 = function()
  --   if appear("跳过剧情") then
  --     tap("跳过剧情")
  --     ssleep(1)
  --     tap("跳过剧情确认")
  --   end
  -- end,
  签到返回黄 = function() return path.fallback.签到返回() end,
  回坑返回 = function() return path.fallback.签到返回() end,
  签到返回 = function()
    local x
    local last_time_tap_return = time()
    local start_time = time()
    if not wait(function()
      -- 曾出现 返回确认 误判为 活动公告返回
      -- 返回确认3按back太快弹不出来
      local timeout = min(2, (time() - start_time + 1000) / 1000 * 2 / 10)
      log(237, timeout)
      -- timeout = 0
      x = appear({
        "返回确认", "返回确认3", "主题曲已开放", "回归返回",
        'start黄框', 'start黄框暗',
      }, timeout)
      -- disappear("开始行动", min(2, (time() - start_time) / 1000 * 2 / 2))
      if x then return true end
      back()

      -- 每两秒按下返回，处理限时活动中领到干员/皮肤
      if time() - last_time_tap_return > 5000 then
        -- TODO:按返回在获得物资界面没用
        tap("返回")
        last_time_tap_return = time()
      end
      -- 干员/皮肤界面用返回键没用，这时按基建右上角
    end, 30) then stop("返回键30秒超时", 'cur') end
    if x then return tap(path.fallback[x]) end
  end,
  回归返回 = function()
    tap("回归返回")
    ssleep(1)
    return path.fallback.签到返回()
  end,
  活动公告返回 = function()
    if not wait(function()
      if disappear("活动公告返回", 1) then return true end
      back()
    end, 5) then return restartapp(appid) end
    return path.fallback.签到返回()
  end,
  抽签返回 = function()
    for u = scale(300), screen.width - scale(300), 200 do
      tap({u, screen.height // 2})
    end
    tap("确定抽取")
    return path.fallback.签到返回()
  end,
  活动签到返回 = function()
    for u = screen.width // 2 + scale(825 - 1920 // 2), screen.width // 2 +
      scale(1730 - 1920 // 2), scale(100) do tap({u, scale(500)}) end
    for v = screen.height // 2 + scale(180 - 1080 // 2), screen.height // 2 +
      scale(950 - 1080 // 2), scale(100) do tap({screen.width // 2, v}) end
    return path.fallback.签到返回()
  end,
  返回确认 = function()
    log(191)
    leaving_jump = false
    if not wait(function()
      if findOne("进驻总览") then zoom() end
      if not findOne("返回确认") then return true end

      -- 宽屏上有误判
      if findOne("活动公告返回") then
        path.fallback.活动公告返回()
        return true
      end

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
    end, 60) then return restartapp(appid) end
    stay_in_dorm_once = false

    if appear("进驻总览", 1) then leaving_jump = true end
  end,
  返回确认2 = "右确认",
  返回确认3 = function()
    wait(function()
      if findAny({
        "面板", "开始唤醒", "bilibili_framelayout_only",
        "活动公告返回",
      }) then return true end
      tap("左取消")
    end, 5)
  end,
  单选确认框 = "右确认",
  剿灭说明 = function()
    tap("基建右上角")
    ssleep(1)
    -- if not wait(function()
    --   if findOne("主页") then return true end
    --   tap("基建右上角")
    -- end, 5) then stop(208) end
  end,
  行动结束 = function()
    tap("行动结束")
    -- if not wait(function()
    --   if findOne("开始行动") and findOne("代理指挥开") then
    --     return true
    --   end
    --   findTap("行动结束")
    -- end, 10) then stop(217) end
  end,
  限时幸运签 = function()
    tapAll(point.限时幸运签列表)
    ssleep(.25)
    tap("限时幸运签抽取")
    disappear("限时幸运签", 10)
    return path.fallback.签到返回()
  end,
  限时开放许可 = function()
    wait(function() tap("开始作业") end, 1)
    wait(function()
      if findOne("面板") then return true end
      tap("开包skip")
    end, 10)
    -- disappear("面板", 1)
  end,
  感谢庆典返回 = function()
    wait(function() tap("感谢典点击领取") end, 1)
    wait(function()
      if findOne("面板") then return true end
      tap("开包skip")
    end, 10)
    -- disappear("面板", 1)
  end,
  返回 = function()
    -- 基建内返回太快会卡
    local x = appear({
      "返回确认", "返回确认2", "返回确认3", "活动公告返回",
      "签到返回", "签到返回黄", "活动签到返回", "抽签返回",
      "战略返回", '感谢庆典返回', '限时开放许可',
      "限时幸运签", "线索传递界面", "阿米娅",
    }, .1)
    log(251, x)
    if x then return tap(path.fallback[x]) end
    -- back()
    tap("返回")
  end,
  返回3 = function()
    -- 只有邮件与设置界面有白色返回
    tap("返回3")
    -- disappear("返回3", .5)
  end,
}

path.限时活动 = function(retry)
  -- 只包含主页红点
  retry = retry or 0
  if retry > 5 then return end
  path.跳转("首页")
  local p = findAny({
    "面板限时活动", "面板限时活动2", "面板限时活动3",
  })
  if p then
    tap(p)
    appear({
      '活动签到返回', '抽签返回', '感谢庆典返回',
      '限时开放许可', "限时幸运签",
    })
  elseif findOne("面板赠送一次") and not disable_free_draw then
    tap("面板干员寻访")
    if not appear("赠送一次") then return end
    ssleep(.5)
    if not wait(function()
      if not findOne("赠送一次") then return true end
      tap("寻访一次")
      disappear("赠送一次", 1)
    end, 10) then return end
    if not appear("返回确认界面") then return end
    if not wait(function()
      if not findOne("返回确认界面") then return true end
      tap("右右确认")
    end, 2) then return end

    local last_time_see_home = time()
    if not wait(function()
      if findOne("主页") then last_time_see_home = time() end
      if time() - last_time_see_home > 1000 then return true end
      tap("开包skip")
    end, 15) then return end

    -- appear("主页", 2)
    -- disappear("主页", 10)
    if not wait(function()
      if findOne("主页") then return true end
      tap("开包skip")
    end, 15) then return end
  end

  path.跳转("首页")

  -- 需要点时间才能找到 面板限时活动2 与 单抽
  if not wait(function()
    if not findOne("面板") then return true end
    if findAny({
      "面板限时活动", "面板限时活动2", "面板限时活动3",
      "面板赠送一次",
    }) then return true end
  end, 1) then return end
  return path.限时活动(retry + 1)
end

path.邮件收取 = function()
  if qqnotify_beforemail then
    path.跳转("首页")

    -- if disappear("面板", 1) then return path.邮件收取() end
    -- if findOne("正在提交反馈至神经") then return path.邮件收取() end
    captureqqimagedeliver(table.join(qqmessage, ' ') .. " 邮件收取前")
  end

  path.跳转("邮件")
  local state = sample("邮件提示")
  if not wait(function()
    tap("收取所有邮件")
    if not findOne(state) then return true end
  end, 10) then return end

  -- 卡在邮件的获取
  local start_time = time()
  local last_time_tap_return = time()

  wait(function()
    local timeout = min(2, (time() - start_time) / 1000 * 2 / 10)
    -- local timeout = 0
    if appear({
      "开始唤醒", "账号登录", "返回确认3",
      "bilibili_framelayout_only",
    }, timeout) then return true end
    back()

    -- 每5秒按下返回，处理限时活动中领到干员/皮肤
    if time() - last_time_tap_return > 5000 then
      -- TODO:按返回在获得物资界面没用
      tap("返回", true)
      last_time_tap_return = time()
    end

  end, 30)

end

path.基建收获 = function()
  -- jump with zoom too
  path.跳转("基建")
  local x
  local max_retry = 5
  for i = 1, max_retry do
    x = appear({
      "正在提交反馈至神经", "基建灯泡蓝", "基建灯泡蓝2",
      "基建收获线索提示",
    }, 3)
    -- 没看到灯泡或线索提示
    if not x then
      log(448)
      leaving_jump = true
      return
    end
    if table.includes({
      "基建收获线索提示", "正在提交反馈至神经",
    }, x) then
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

  if false and findOne("小蓝圈") and findOne("训练室") then
    tap("点击全部收取2")
    zoom()
    if not wait(function()
      tap("训练室")
      log(678)
      disappear("训练室", 1)
      if not findAny({"进驻信息", "进驻信息选中"}) then
        return true
      end
    end, 5) then return end

    -- if not appear({"进驻信息", "进驻信息选中"}) then return end

    if not wait(function(reset_wait_start_time)
      tap("贸易站进度")
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
      if not findOne("主页") then return true end
    end, 5) then return end

    if not wait(function()
      tap("训练室")
      if findOne("隐藏") and findOne("返回") and
        findAny({"进驻信息", "进驻信息选中"}) then return true end
    end, 5) then return end
    return

  end

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

  -- 存在嵌套跳转，加载开头应该可以？
  if prev_jump == "基建" and x ~= "基建" and collect_beforeleaving and
    not_first_time_jump then path.基建收获() end

  -- 退出基建前截图
  if prev_jump == "基建" and x ~= "基建" and qqnotify_beforeleaving and
    not_first_time_jump then
    path.跳转("基建")
    captureqqimagedeliver(table.join(qqmessage, ' ') .. " " .. "基建离开前")
  end

  not_first_time_jump = true

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
        target, "活动公告返回", "签到返回", "签到返回黄",
        "活动签到返回", "抽签返回", "单选确认框", "返回3",
        "阿米娅",
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
          if table.includes({"任务", "好友", "首页"}, home_target) then
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

        if findOne("返回") then
          -- log(458)
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
      if not disappear(target, 1) then
        log("found804", target)
        return true
      end
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

  -- 1分钟跳转失败
  auto(p, path.fallback, 0, 300, true)

  -- post processing especially for 基建
  if x == "基建" and not disable_postprocess then zoom() end

  -- 进入基建后截图
  if prev_jump ~= "基建" and x == "基建" and qqnotify_afterenter and
    not_first_time_jump then
    captureqqimagedeliver(table.join(qqmessage, ' ') .. " " .. "基建进入后")
  end

  prev_jump = x

  -- disable repeat fight after any jump complete
  repeat_fight_mode = false
end

start_time = parse_time("202101010400")

-- 对于不同用户的首次任务
init_state = function() end

-- 对于单个用户的不同任务
update_state = function()

  -- 禁用重复刷模式
  repeat_fight_mode = false
  pre_fight = nil

  -- 作战统计
  fight_history = {}

  fight_tick = 0
  no_success_one_loop = 0
  prev_jump = "基建"
  not_first_time_jump = false

  update_state_last_day = 0
  update_state_last_week = 0
  communication_enough = false
  jmfight_enough = false
  zero_san = false
  zero_san_hit = 0
  username_typed = false

  first_time_swipe = true
  jmfight_times = 0
  no_friend = false
  cur_fight = ''
  fight_failed_times = {}
  zero_san = false
  login_error_times = 0
  login_times = 0
  login_time_history = {}

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
  -- if 1 then return end
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
      tap("基建副手列表" .. i)
      if findOne("副手确认蓝") then return true end
    end, 5) then return end

    if not wait(function()
      tap("干员选择列表7")
      if appear("副手第七干员选中", 1) then return true end
    end, 5) then return end

    if not wait(function()
      if not findOne("副手确认蓝") and findOne("基建副手简报") then
        return true
      end
      tap("副手确认蓝")
    end, 5) then return end

    if not wait(function()
      tap("基建副手列表" .. i)
      if findOne("副手确认蓝") then return true end
    end, 5) then return end

    if not wait(function()
      tap("干员选择列表7")
      if appear("副手第七干员选中", 1) then return true end
    end, 5) then return end

    if not wait(function()
      tap("干员选择列表" .. (i + 1))
      if disappear("副手第七干员选中", 1) then return true end
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

path.宿舍清空 = function()
  local f
  f = function(i)
    path.跳转("基建")

    if not wait(function()
      if not findOne("进驻总览") or not findOne("缩放结束") then
        return true
      end
      tap("宿舍列表" .. i)
    end) then return end

    if not appear({"进驻信息", "进驻信息选中"}, 5) then
      log("621")
      return
    end
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

    if not wait(function(reset_wait_start_time)
      if findAny({"隐藏", "进驻信息", "进驻信息选中"}) then
        return true
      end
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
      tap("确认蓝")
    end, 5) then return end

  end
  for i = 1, 4 do f(i) end
end

path.宿舍换班 = function()
  if disable_dorm_shift then return end
  local f
  f = function(i)
    path.跳转("基建")

    if not wait(function()
      if not findOne("进驻总览") or not findOne("缩放结束") then
        return true
      end
      tap("宿舍列表" .. i)
    end) then return end

    if not appear({"进驻信息", "进驻信息选中"}, 5) then
      log("621")
      return
    end
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

    local operator
    if shift_prefer_speed then
      -- 选后5个
      operator = map(function(x) return "干员选择列表" .. x end,
                     range(6, 10))
    else
      -- 根据心情阈值选择
      operator = {}
      discover(operator, {}, 1, true)
      log(818, operator, shift_min_mood)
      operator = table.filter(operator, function(x)
        return math.abs(x[3]) < shift_min_mood + 1
      end)
      -- log(819,operator)
      operator = map(function(x) return x[4] end, operator)
      operator = table.slice(operator, 1, 5)

      -- operator = table.slice(table.extend(operator, map(
      --                                       function(x)
      --     return "干员选择列表" .. x
      --   end, range(1, 5))), 1, 5)

      log(820, operator)
    end

    if #operator > 0 and not wait(function()
      if not findOne("干员未选中") then return true end
      -- 慢机仍会漏换， miui13也是
      -- 加了心情检测这儿还要等？
      ssleep(0.25)
      tapAll(operator)
      disappear("干员未选中", 2)
    end, 5) then return end

    log(842, #operator)
    -- 把未进驻的非满心情干员放进去
    if nil and #operator < 5 then

      -- 进入筛选界面
      if not wait(function()
        if findOne("筛选取消") then return true end
        tap("筛选")
      end, 5) then return end

      if not appear({"筛选未进驻选中", "筛选未进驻"}, 5) then
        return
      end

      if not findOne("筛选未进驻选中") then
        if not wait(function()
          if findOne("筛选未进驻选中") then return true end
          tap("筛选未进驻选中")
          appear("筛选未进驻选中", .5)
        end, 5) then return end
      end

      if not wait(function()
        if not findOne("筛选取消") then return true end
        tap("筛选确认")
      end, 5) then return end

      if not wait(function()
        if findOne("干员未选中") and findOne("第一干员未选中") then
          return true
        end
        tap("清空选择")
      end, 5) then return end

      -- 选择后续干员
      operator = map(function(x) return "干员选择列表" .. x end,
                     range(1, 5))
      ssleep(0.25)
      tapAll(operator)

      -- 进入筛选界面
      if not wait(function()
        if findOne("筛选取消") then return true end
        tap("筛选")
      end, 5) then return end

      if not appear({"筛选未进驻选中", "筛选未进驻"}, 5) then
        return
      end
      if not findOne("筛选未进驻") then
        if not wait(function()
          if findOne("筛选未进驻") then return true end
          tap("筛选未进驻")
          appear("筛选未进驻", 1)
        end, 5) then return end
      end
      if not wait(function()
        if not findOne("筛选取消") then return true end
        tap("筛选确认")
      end, 5) then return end
    end

    if not wait(function(reset_wait_start_time)
      if findAny({"隐藏", "进驻信息", "进驻信息选中"}) then
        return true
      end
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
      tap("确认蓝")
    end, 5) then return end

  end
  for i = 1, 4 do f(i) end
end

-- 各站数量与等级，直接全局变量
path.基建信息获取 = function()
  dormitoryCapacity = 0
  dormitoryLevelSum = 0
  dormitoryNum = 0
  goldStationNum = 0
  tradingStationNum = 0
  powerStationNum = 0

  dormitoryStation = {}
  dormitoryLevel = {}
  powerStation = {}
  powerStationLevel = {}
  tradingStation = {}
  tradingStationLevel = {}
  manufacturingStation = {}
  manufacturingStationLevel = {}

  path.跳转("基建")

  local type2color = {
    制造站 = "#FFCC00",
    贸易站 = "#33CCFF",
    发电站 = "#CCFF66",
  }
  local f
  keepCapture()
  f = function(i)
    local x, y = table.unpack(point["基建列表" .. i])
    local station, stationLevel
    for type, color in pairs(type2color) do
      if type == "制造站" then
        station = manufacturingStation
        stationLevel = manufacturingStationLevel
      elseif type == "贸易站" then
        station = tradingStation
        stationLevel = tradingStationLevel
      elseif type == "发电站" then
        station = powerStation
        stationLevel = powerStationLevel
      end

      -- 检测kernel，因为可能被条纹挡住
      if (compareColor(x, y, color, default_findcolor_confidence) or
        compareColor(x - scale(5), y - scale(10), color,
                     default_findcolor_confidence) or
        compareColor(x - scale(5), y + scale(10), color,
                     default_findcolor_confidence) or
        compareColor(x + scale(5), y + scale(10), color,
                     default_findcolor_confidence) or
        compareColor(x - scale(5), y - scale(10), color,
                     default_findcolor_confidence)) then
        table.insert(station, {x, y})
        table.insert(stationLevel, 3)

        for j = 0, 2 do
          local x, y = table.unpack(point["基建等级列表" .. i * 3 - j])
          -- log(973,x,y)
          if (compareColor(x, y, color, default_findcolor_confidence) or
            compareColor(x - scale(1), y - scale(3), color,
                         default_findcolor_confidence) or
            compareColor(x - scale(1), y + scale(3), color,
                         default_findcolor_confidence) or
            compareColor(x + scale(1), y + scale(3), color,
                         default_findcolor_confidence) or
            compareColor(x - scale(1), y - scale(3), color,
                         default_findcolor_confidence)) then
            stationLevel[#stationLevel] = 3 - j
            break
          end
        end

        break
      end
    end
  end

  for i = 1, 9 do f(i) end

  f = function(i)
    local color = '#FFFFFF'
    local stationLevel
    stationLevel = dormitoryLevel
    for j = 0, 4 do
      local x, y = table.unpack(point["宿舍等级列表" .. i * 5 - j])
      if (compareColor(x, y, color, default_findcolor_confidence) or
        compareColor(x - scale(1), y - scale(3), color,
                     default_findcolor_confidence) or
        compareColor(x - scale(1), y + scale(3), color,
                     default_findcolor_confidence) or
        compareColor(x + scale(1), y + scale(3), color,
                     default_findcolor_confidence) or
        compareColor(x - scale(1), y - scale(3), color,
                     default_findcolor_confidence)) then
        table.insert(stationLevel, 5 - j)
        break
      end
    end
  end

  for i = 1, 4 do f(i) end

  dormitoryNum = #dormitoryLevel
  dormitoryCapacity = dormitoryNum * 5
  dormitoryLevelSum = table.sum(dormitoryLevel)

  -- powerStationLevel = map(function() return 3 end, powerStation)
  powerStationNum = #powerStation

  -- tradingStationLevel = map(function() return 3 end, tradingStation)
  tradingStationNum = #tradingStation

  -- manufacturingStationLevel = map(function() return 3 end, manufacturingStation)
  manufacturingStationNum = #manufacturingStation

  releaseCapture()

  log(1216, tradingStationLevel, manufacturingStationLevel, powerStationLevel,
      dormitoryLevel)
end

-- trading 是否是贸易站
path.制造换班 = function(trading)
  if disable_manu_shift and not trading then return end

  -- if not debug then return end
  local station_color = trading and "#33CCFF" or "#FFCC00"
  local type
  local good
  local good2type = {
    经验站 = "作战记录",
    赤金站 = "贵金属",
    源石站 = "源石",
    芯片站 = "芯片",
    开采协力 = "源石",
    龙门商法 = "贵金属",
  }

  local f
  f = function(i, station, stationLevel)
    path.跳转("基建")
    -- local x, y = table.unpack(point["基建列表" .. i])
    -- -- 检测kernel，因为可能被条纹挡住
    -- if not (compareColor(x, y, station_color, default_findcolor_confidence) or
    --   compareColor(x - scale(5), y - scale(10), station_color,
    --                default_findcolor_confidence) or
    --   compareColor(x - scale(5), y + scale(10), station_color,
    --                default_findcolor_confidence) or
    --   compareColor(x + scale(5), y + scale(10), station_color,
    --                default_findcolor_confidence) or
    --   compareColor(x - scale(5), y - scale(10), station_color,
    --                default_findcolor_confidence)) then
    --   log("skip", i)
    --   return
    -- end

    -- 进入制造站
    if not wait(function()
      if not findOne("进驻总览") or not findOne("缩放结束") then
        return true
      end
      tap(station)
    end) then return end

    if not appear({"进驻信息", "进驻信息选中"}, 5) then return end

    local chip2book_needed = false
    -- 制造站需要确认产品类型
    if not trading then

      wait(function()
        if findAny({"制造站设施列表1", "未进驻设施列表1"}) then
          return true
        end
        tap("贸易站进度")
      end, 5)

      good = findAny({"赤金站", "源石站", "芯片站", "经验站"})
      if good == '芯片站' and findOne("芯片站已完成") then
        good = "赤金站"
        chip2book_needed = true
      end

      -- -- 收起进驻信息
      -- if not wait(function()
      --   if findOne("进驻信息") and not disappear("进驻信息", 1) then
      --     return true
      --   end
      --   if findOne("进驻信息选中") then
      --     tap("进驻信息选中")
      --     disappear("进驻信息选中")
      --   end
      -- end, 10) then return end

      -- 确认类型
      -- 计算赤金站数量，用于贸易站技能计算
      if good == "赤金站" then goldStationNum = goldStationNum + 1 end
      log(854, good)
      if not good then
        log("not support", i)
        return
      end
      type = good2type[good]
      log(524, type)
      if not disappear("制造站补货通知", 10) then return end

      -- 制造站进入干员列表
      if not wait(function()
        if findOne("确认蓝") then return true end
        tap("设施列表第二个干员")
      end, 5) then return end

      -- -- 制造站进入干员列表
      -- if not wait(function()
      --   if findOne("确认蓝") then return true end
      --   if findOne("进驻信息选中") and
      --     not disappear("进驻信息选中", .5) then
      --     tap("进驻第一人左")
      --   elseif findOne("进驻信息") then
      --     tap("进驻信息")
      --     disappear("进驻信息", .5)
      --   end
      -- end, 5) then return end

    end

    -- 贸易站需要确认产品类型
    if trading then

      wait(function()
        if findAny({"贸易站设施列表1", "未进驻设施列表1"}) then
          return true
        end
        tap("贸易站进度")
      end, 5)

      good = findAny({"龙门商法", "开采协力"}) or "龙门商法"

      -- 确认类型
      log(855, good)
      if not good then
        log("not support", i)
        return
      end
      type = good2type[good]
      log(525, type)
      if not disappear("制造站补货通知", 10) then return end

      -- 贸易站进入干员列表
      if not wait(function()
        if findOne("确认蓝") then return true end
        tap("设施列表第一个干员")
      end, 5) then return end

    end

    -- TODO 下面这段稳定吗
    -- if not wait(function()
    --   if findOne("筛选") then return true end
    --   if findOne("进驻信息选中") then
    --     wait(function()
    --       if findOne("筛选") then return true end
    --       tap("进驻第一人")
    --     end, 1)
    --   elseif findOne("进驻信息") then
    --     tap("进驻信息")
    --     ssleep(.2)
    --     wait(function()
    --       if findOne("筛选") then return true end
    --       tap("进驻第一人")
    --     end, 1)
    --   end
    -- end, 5) then return end

    log("使用默认筛选")

    -- -- 筛选出无进驻技能排序
    -- if not wait(function()
    --   if findOne("筛选取消") then return true end
    --   tap("筛选")
    -- end, 5) then return end
    --
    -- if not appear({"筛选未进驻选中", "筛选未进驻"}) then return end
    -- if not appear({"筛选技能降序", "筛选技能", "筛选技能升序"}) then
    --   return
    -- end
    --
    -- if not findOne("筛选未进驻选中") then
    --   if not wait(function()
    --     if findOne("筛选未进驻选中") then return true end
    --     tap("筛选未进驻选中")
    --     appear("筛选未进驻选中", 1)
    --   end, 5) then return end
    -- end
    --
    -- if prefer_skill and not findOne("筛选技能降序") then
    --   if not wait(function()
    --     if findOne("筛选技能降序") then return true end
    --     tap("筛选技能降序")
    --     appear("筛选技能降序", 1)
    --   end, 5) then return end
    -- end
    --
    -- if not wait(function()
    --   if not findOne("筛选取消") then return true end
    --   tap("筛选确认")
    -- end, 5) then return end

    local start_time = time()
    if not wait(function()
      if findOne("干员未选中") and findOne("第一干员未选中") then
        return true
      end
      if time() - start_time > 1000 then
        tap("干员选择列表1")
        start_time = time()
      end
      tap("清空选择")
    end, 5) then
      log(1037)
      return
    end

    log(1217, tradingStationLevel, manufacturingStationLevel, powerStationLevel,
        dormitoryLevel)

    local stationType = trading and "贸易站" or "制造站"
    chooseOperator(stationType, type, stationLevel, tradingStationNum,
                   powerStationNum, dormitoryCapacity, dormitoryLevelSum,
                   goldStationNum)

    wait(function(reset_wait_start_time)
      tap("确认蓝")
      if findAny({"制造站设施列表1", "贸易站设施列表1"}) then
        return true
      end
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
    end, 5)

    -- 源石站补货
    if good == "源石站" then
      wait(function()
        tap("制造站最多")
        if findOne("制造站执行更改") then return true end
      end, 2)
      tap("制造站执行更改")
    end

    -- 芯片换经验
    if chip2book_needed then
      local chip2book = function()
        if not wait(function()
          tap("芯片站")
          if not findOne("制造站设施列表1") then return true end
        end, 5) then return end

        if not wait(function()
          tap("芯片站选赤金类")
          if findOne("芯片站选赤金") then return true end
        end, 5) then return end

        if not wait(function()
          tap("芯片站选赤金")
          if findOne("制造站执行更改") then return true end
        end, 5) then return end

        if not wait(function()
          tap("制造站最多")
          tap("制造站执行更改")
          if not findOne("制造站设施列表1") then return true end
        end, 5) then return end

        if not wait(function(reset_wait_start_time)
          tap("右确认")
          if appear("制造站设施列表1", 1) then return true end
          if findOne("正在提交反馈至神经") then
            reset_wait_start_time()
          end
        end, 5) then return end

        return true
      end
      chip2book()
    end
  end

  -- 找到所有制造站
  local station = trading and tradingStation or manufacturingStation
  local stationLevel = trading and tradingStationLevel or
                         manufacturingStationLevel
  for i = 1, #station do f(i, station[i], stationLevel[i]) end
end

path.贸易换班 = function()
  if disable_trading_shift then return end
  return path.制造换班(true)
end

path.总览换班 = function()
  if disable_overview_shift then return end
  local f
  path.跳转("基建")
  if not wait(function()
    if findOne("撤下干员") then return true end
    tap("进驻总览")
  end, 10) then return end

  path.控制中枢换班()
  path.会客厅换班()

  local swipd = function()
    local flipd = 150
    local flips = 50
    local duration = flipd + flips + 50
    local x1 = screen.width - scale(1280 - 500)
    local x2 = x1 + scale(100)
    local x3 = screen.width - 1
    local y1 = scale(150)
    local y2 = screen.height - scale(300)
    local paths = {
      {point = {{x1, y1}, {x3, y1}}, duration = duration},
      {point = {{x1, y2}, {x2, y2}}, duration = flipd, start = flips},
    }
    -- sleep(100)
    gesture(paths)
    sleep(duration + 50)
    -- 可能还是需要按下
    tap("入驻干员右侧")
    -- 不用的话，大分辨率还是有可能出现错过加号
    sleep(100)
  end

  local first_look = false
  if disable_control_shift and disable_meeting_shift then first_look = true end
  local visitedy = {}
  f = function()
    -- 0.1 是 从干员列表退出后 取消连续点击 保证滑动手势有效
    -- 0.5 是 首次进入界面时 需要多点时间
    -- local timeout = first_look and .5 or .1
    local timeout = (first_look and .5 or .25)
    -- local timeout = .1
    local p
    log(800, p)
    first_look = false
    -- 至少做两次"入驻干员"检测，慢机只靠timeout不够可能，强制加一次
    if not appear("入驻干员", timeout) and findOne("撤下干员") and
      not findOne("入驻干员") then
      log("无入驻干员")
      return
    end

    local last_time_see_plus = time()
    if not wait(function()
      if findOne("确认蓝") then return true end
      if findOne("撤下干员") then
        p = findOne("入驻干员")
        if p then
          tap(p)
          last_time_see_plus = time()
        elseif time() - last_time_see_plus > 5000 then
          return true
        end
      end
    end, 10) then return end

    if not findOne("确认蓝") then return true end

    local limit = findOne("清空选择") and 5 or 1

    if p then
      -- 处理异格干员:出现同高度第二次缺人，不清空从后往前选人。
      log('visitedy', visitedy, height, p)
      local height = tostring(p[2])

      -- 多次进入同一高度，直接翻页
      if (visitedy[height] or 0) >= 4 then
        if not wait(function(reset_wait_start_time)
          if findOne("撤下干员") then return true end
          if findOne("正在提交反馈至神经") then
            reset_wait_start_time()
          end
          tap("确认蓝")
        end, 5) then return end
        return
      end

      -- 超过两次进入同一高度，从后往前选
      -- visitedy[height] = 1
      if (visitedy[height] or 0) >= 3 then
        visitedy[height] = (visitedy[height] or 0) + 1
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
        ssleep(0.25)
        tapAll(map(function(j) return "干员选择列表" .. j end,
                   range(2 * limit, limit + 1, -1)))
        if not wait(function(reset_wait_start_time)
          if findOne("撤下干员") then return true end
          if findOne("正在提交反馈至神经") then
            reset_wait_start_time()
          end
          tap("确认蓝")
        end, 5) then return end
        return true
      end

      visitedy[height] = (visitedy[height] or 0) + 1
      log(865, height, p, visitedy)
    end

    if not wait(function()
      if findOne("筛选取消") then return true end
      tap("筛选")
    end, 5) then return end

    if not appear({"筛选未进驻选中", "筛选未进驻"}, 5) then
      return
    end
    if not appear({"筛选技能降序", "筛选技能", "筛选技能升序"},
                  5) then return end

    if not findOne("筛选未进驻选中") then
      if not wait(function()
        if findOne("筛选未进驻选中") then return true end
        tap("筛选未进驻选中")
        appear("筛选未进驻选中", .5)
      end, 5) then return end
    end

    -- if prefer_skill and not findOne("筛选技能降序") then
    --   if not wait(function()
    --     if findOne("筛选技能降序") then return true end
    --     tap("筛选技能降序")
    --     appear("筛选技能降序", 1)
    --   end, 5) then return end
    -- end

    if not wait(function()
      if not findOne("筛选取消") then return true end
      tap("筛选确认")
    end, 5) then return end

    local start_time = time()
    if not wait(function()
      if findOne("干员未选中") and findOne("第一干员未选中") then
        return true
      end
      if time() - start_time > 1000 then
        tap("干员选择列表1")
        start_time = time()
      end
      tap("清空选择")
    end, 5) then
      log(1037)
      return
    end

    log("limit", limit)

    -- 排除异格干员
    local operator = {}
    discover(operator, {}, 1, true)
    -- log("1905", operator)
    operator = table.filter(operator, function(x) return x[3] >= 0 end)
    operator = map(function(x) return x[4] end, operator)
    operator = table.slice(operator, 1, limit)

    if not wait(function()
      if not findOne("干员未选中") then return true end

      -- 不得不等，不然不按序
      -- 不用等，因为加了异格检测需要时间？
      ssleep(0.25)
      tapAll(operator)
      disappear("干员未选中", 2)
    end, 5) then return end

    if not wait(function(reset_wait_start_time)
      if findOne("撤下干员") then return true end
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
      tap("确认蓝")
    end, 3) then return end

    return true
  end

  local bottom
  local reach_bottom = false
  for i = 1, 60 do
    if i ~= 1 then
      swipd()
      -- TODO wait bottom for stable
      if not appear(bottom, .2) then reach_bottom = true end
    end
    if i == 60 then stop('总览换班滑动', 'cur') end
    visitedy = {}
    while f() do log(475) end
    if reach_bottom then break end
    -- sample bottom after first detect
    if not bottom then bottom = sample("进驻总览底部") end
  end
  if not findOne("撤下干员") then return end

end

path.基建换班 = function()
  -- 极速模式
  if shift_prefer_speed then
    path.宿舍换班()
    path.总览换班()
    return
  end

  path.宿舍换班()
  path.基建信息获取()
  -- path.控制中枢换班()
  -- path.会客厅换班()
  path.办公室换班()
  path.制造换班()
  path.贸易换班()
  path.总览换班()
end

path.控制中枢换班 = function()
  if disable_control_shift then return end
  return path.会客厅换班("控制中枢")
end

path.办公室换班 = function(stationType)
  if disable_office_shift then return end
  -- TODO: 感觉没必要对办公室做处理，又没做体系
  if 1 then return end
  stationType = stationType or "办公室"

  path.跳转("基建")

  -- 进办公室
  if not wait(function()
    if not findOne("进驻总览") or not findOne("缩放结束") then
      return true
    end
    tap(stationType)
  end) then return end

  if not appear({"进驻信息", "进驻信息选中"}, 5) then return end

  if not wait(function()
    if findOne("确认蓝") then return true end
    tap("制造站进度")
  end, 10) then return end

  -- 清空选择
  local start_time = time()
  tap("干员选择列表1")
  if not wait(function()
    if findOne("干员未选中") and findOne("第一干员未选中") then
      return true
    end
    if time() - start_time > 1000 then
      tap("干员选择列表1")
      start_time = time()
    end
    -- tap("清空选择")
  end, 5) then
    log(1037)
    return
  end

  chooseOperator(stationType, type, stationLevel, tradingStationNum,
                 powerStationNum, dormitoryCapacity, dormitoryLevelSum,
                 goldStationNum)

  if not wait(function(reset_wait_start_time)
    tap("确认蓝")
    if findAny({"隐藏", "进驻信息", "进驻信息选中"}) then
      return true
    end
    if findOne("正在提交反馈至神经") then reset_wait_start_time() end
  end, 3) then return end
end

path.会客厅换班 = function(stationType)
  if disable_meeting_shift and not stationType then return end

  stationType = stationType or "会客厅"
  -- 进总览
  -- path.跳转("基建")
  -- if not wait(function()
  --   if findOne("撤下干员") then return true end
  --   tap("进驻总览")
  -- end, 10) then return end

  -- 检查是否缺人，不缺不换
  if not appear("入驻干员" .. stationType, .5) and findOne("撤下干员") and
    not findOne("入驻干员" .. stationType) then
    log("无入驻干员")
    return
  end

  -- 进干员列表
  if not wait(function()
    if findOne("确认蓝") then return true end
    tap("进驻总览" .. stationType)
  end, 10) then return end

  -- 清空选择
  local start_time = time()
  if not wait(function()
    if findOne("干员未选中") and findOne("第一干员未选中") then
      return true
    end
    if time() - start_time > 1000 then
      tap("干员选择列表1")
      start_time = time()
    end
    tap("清空选择")
  end, 5) then
    log(1037)
    return
  end

  chooseOperator(stationType, type, stationLevel, tradingStationNum,
                 powerStationNum, dormitoryCapacity, dormitoryLevelSum,
                 goldStationNum)

  if not wait(function(reset_wait_start_time)
    tap("确认蓝")
    if findOne("撤下干员") then return true end
    if findOne("正在提交反馈至神经") then reset_wait_start_time() end
  end, 3) then return end
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
  end, 10) then return end
  -- if not appear("制造站加速") then return end

  if not wait(function()
    if findOne("无人机加速") then return true end
    tap("制造站加速")
  end, 10) then return end

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

path.线索交流 = function()
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
    if findAny({"线索传递", "本次线索交流活动"}) then return true end
    tap("制造站进度")
  end, 10) then return end

  log(1028)

  -- 进入可控状态
  if not wait(function()
    -- if not findOne("线索传递") then return true end
    if findAny({"线索布置展开", "本次线索交流活动"}) then
      return true
    end
    -- tapCard("线索布置列表1")
    tap("线索布置5")
  end, 10) then return end

  log(1029)

  -- 回到线索主界面，处理交流结束情况
  if not wait(function()
    if findOne("线索传递") then return true end
    tap("解锁线索上")
    if findOne("本次线索交流活动") then
      -- log("find本次线索交流活动")
      tap("返回")
      -- 只能用返回必须等待
      disappear("本次线索交流活动", .5)
    end
  end, 10) then return end

  log(1030)

  -- 等待前一任务的通知消失
  appear("接收线索白", 5)
  appear("线索传递", 5)
  log(1031)

  -- 接收线索
  wait(function()
    if not findOne("线索传递") then return true end
    -- TODO 暂时妥协这0.5秒，丢失率太高
    if not appear("接收线索有", .5) then return true end
    if not wait(function()
      tap("接收线索有")
      if disappear("线索传递", 1) then return true end
    end, 5) then return true end

    if not appear("接收线索", 5) then return true end
    wait(function() tap("全部收取") end, 1)

    if not wait(function()
      if findOne("线索传递") then return true end
      tap("解锁线索上")
    end, 5) then return true end
  end, 10)
  if not appear("线索传递") then return end

  log(1032)

  -- 信用奖励，已满则传递线索
  f = function(retry)
    log(1033)
    if retry > 10 or no_friend then return true end

    -- 进入信用奖励界面
    if not wait(function()
      if findOne("信用奖励返回") then return true end
      tap("信用奖励有")
    end, 10) then return end

    log(1034)

    -- 已满则传递，并循环
    if not appear("未达线索上限", .5) then
      tap("返回")
      appear("线索传递")
      clue_unlocked = false
      path.线索布置()
      if not clue_unlocked then path.线索传递() end
      return f(retry + 1)
    end

    log(1035)

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
  tap({tonumber(x) - scale(50), tonumber(y) + scale(50)})
end

path.线索布置 = function()
  -- internal
  if not findOne("线索传递") then
    log("线索布置未找到线索传递")
    return
  end
  log(643)

  if disable_clue_unlock then
    path.线索传递()
    ssleep(5)
    path.线索传递()
    return
  end

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

  -- 只送线索
  log("disable_clue_unlock", disable_clue_unlock)
  -- exit()

  if findOne("解锁线索") and not disable_clue_unlock then
    clue_unlocked = true

    wait(function() tap("解锁线索") end, .5)

    if not appear({"进驻信息", "进驻信息选中"}, 5) then
      return path.线索交流()
    end

    if not wait(function()
      if findOne("线索传递") then return true end
      tap("制造站进度")
    end, 10) then return path.线索交流() end

    return path.线索布置()
  end
end

path.线索传递 = function()
  -- internal
  disappear("正在提交反馈至神经", network_timeout)
  if not findTap("线索传递") then return end

  appear({"线索传递数字列表8", "正在提交反馈至神经"})
  disappear("正在提交反馈至神经", network_timeout)
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
  appear({"任务未选中列表2", "任务有列表2", "任务无列表2"})
  if qqnotify_beforemission then
    captureqqimagedeliver(table.join(qqmessage, ' ') .. " 任务收集前")
  end

  if speedrun then
    -- 只保留日常任务
    point.任务有列表2 = nil
    point.任务有列表4 = nil
  end

  for _ = 1, #point.任务有列表 do
    local p = appear(point.任务有列表, 0.5)
    if not p then break end

    log(795, p)

    -- nagivate to tab
    if not wait(function()
      if findOne("收集全部") then return true end
      tap(p)
    end, 10) then return end

    -- 判定是否有剩余红点
    local remain = findAny(table.subtract(point.任务有列表, {p}))

    -- tap collect
    if not wait(function()
      if not findTap("收集全部") then return true end
    end, 5) then return end

    -- wait for popup
    disappear(p, network_timeout)
    if disappear("主页") then
      if not wait(function()
        tap(p)
        if findOne("主页") and findOne("返回") then return true end
      end, 10) then return end

      -- 等待剩余红点出现
      if remain then appear(point.任务有列表) end
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

  -- 等待前一个任务的提示完全消失
  if findOne("信用不足") then
    -- 1秒内不出现才ok，应对多个通知消失情况
    if not wait(function()
      if not appear("信用不足", 1) then return true end
    end, 10) then return end
  end

  local f
  local order = {}
  f = function()
    local i = 0

    tap("收取信用有")
    if not wait(function()
      if findOne("信用交易所横线") then return true end
      tap("收取信用有")
    end, 5) then return end

    log(832)
    if not appear({
      "信用交易所列表" .. 5, "信用交易所已购列表" .. 5,
    }) then return end
    -- if not appear({
    --   "信用交易所列表" .. i, "信用交易所已购列表" .. i,
    -- }) then return end
    log(833)

    -- if not findOne("信用交易所列表" .. i) then
    --   log(845, i)
    --   return
    -- end

    -- 获取遗漏物品
    for _, j in pairs(order) do
      if findOne("信用交易所列表" .. j) then
        i = j
        break
      end
    end

    -- 全买完了或者有问题
    if i == 0 then return end

    if not wait(function()
      if not findOne("信用交易所横线") then return true end
      tap("信用交易所列表" .. i)
      -- 快速点击物品将导致购买界面消失
      disappear("信用交易所横线", 1)
    end, 5) then return end

    if not wait(function()
      if findAny({"信用交易所横线", "信用不足"}) then
        return true
      end
      findTap("购买物品")
    end, 5) then return end

    -- 有可能进皮肤界面
    if findOne("信用不足") and findOne("主页") then
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

  -- if speedrun then return f(2) end

  -- 按优先级排
  if type(low_priority_goods) == 'string' and type(high_priority_goods) ==
    'string' and (#low_priority_goods > 0 or #high_priority_goods > 0) then
    keepCapture()
    local first_want = {}
    local last_want = {}
    local low_goods = low_priority_goods:filterSplit()
    local high_goods = high_priority_goods:filterSplit()
    log("low_goods", low_goods)
    log("high_goods", high_goods)
    for i, v in pairs(point.信用交易所列表) do
      local x, y = point[v]:match("(%d+)|(%d+)")
      x = str2int(x, 0)
      y = str2int(y, 0)
      point.t = {x - scale(105), y, x + scale(105), y + scale(46)}
      local r = ocr("t")
      if #r > 0 and r[1].text:includes(high_goods) then
        table.insert(first_want, i)
      elseif #r > 0 and r[1].text:includes(low_goods) then
        table.insert(last_want, i)
      else
        table.insert(order, i)
      end
    end
    order = table.extend(first_want, order)
    table.extend(order, last_want)
    releaseCapture()
  else
    order = range(1, 10)
  end

  log(1635, "信用物品排序", order)
  -- exit()
  for _, i in pairs(order) do if f() then break end end
  -- for _, i in pairs(range(20)) do if f() then break end end
end

get_fight_type = function(x)
  local f = startsWithX(x)
  if table.any({"上一次"}, f) then
    return "上一次"
  elseif table.any({"PR", "CE", "CA", "AP", "LS", "SK"}, f) then
    return "物资芯片"
  elseif table.any(table.values(jianpin2name), f) then
    return "剿灭"
  elseif f('HD') then
    return "活动"
  elseif f('BREAK') then
    return "BREAK"
  else
    return "主线"
  end
end

same_page_fight = function(pre, cur)
  if type(pre) ~= 'string' or type(cur) ~= 'string' then return end

  -- 禁用同页跳转
  if get_fight_type(cur) == '活动' then return end

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
  while not zero_san do

    if #fight == 0 then return true end
    fight_tick = fight_tick % #fight + 1
    if fight_tick == #fight then
      no_success_one_loop = no_success_one_loop + 1
      if no_success_one_loop > 5 then break end
    end
    if request_memory_clean() then path.跳转("首页") end

    cur_fight = fight[fight_tick]
    log(971, cur_fight)
    if cur_fight == 'BREAK' then break end
    if not same_page_fight(pre_fight, cur_fight) then path.跳转("首页") end
    log(820, fight, fight_tick_ui)
    pre_fight = nil

    path[get_fight_type(cur_fight)](cur_fight)

    -- 导航/代理失败3次就删除
    fight_failed_times[cur_fight] = (fight_failed_times[cur_fight] or 0) + 1

    if fight_failed_times[cur_fight] >= max_fight_failed_times then
      clean_fight(cur_fight)
    end

    -- 清光理智: 第一次理智不足时，转为1-7
    if zero_san_after_fight and zero_san then
      if zero_san_hit > 0 then break end
      zero_san_hit = zero_san_hit + 1
      zero_san = false
      fight_tick = 0
      fight = {"1-7"}
    end
  end

end

jianpin2name = {
  -- JM = '剿灭',
  DQWT = "当期委托",
  -- JSCK = "积水潮窟",
  -- CMHB = "潮没海滨",
  LMSQ = "龙门市区",
  LMWH = "龙门外环",
  QENBG = "切尔诺伯格",
  CQWT1 = "长期委托1",
  CQWT2 = "长期委托2",
  CQWT3 = "长期委托3",
  CQWT4 = "长期委托4",
  -- BYBFFC = "北原冰封废城",
  -- DQSLJW = "大骑士领郊外",
  -- FQKQ = "废弃矿区",
}
extrajianpin2name = {
  SYC = "上一次",
  长期委托 = "长期委托1",
  CQWT = "长期委托1",
  当前委托 = "当期委托",
}

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
    tap("代理指挥开1")
    if not appear("代理指挥开", .5) then
      clean_fight(x)
      -- fight_failed_times[cur_fight] = (fight_failed_times[cur_fight] or 0) + 1
      if not appear("主页") then back() end
      return path.跳转("首页")
    end
    -- if not wait(function()
    --   if findOne("代理指挥开") and not disappear("代理指挥开", .5) then
    --     return true
    --   end
    --   tap("代理指挥开")
    --   appear("代理指挥开", .5)
    -- end, 5) then return end
  end

  if is_jmfight_enough(x) then return end

  if findOne("全权委托") then path.fallback.全权委托() end

  -- quick tap .5s
  wait(function()
    if not findOne("代理指挥开") then return true end
    tap("开始行动蓝")
  end, 1)

  local state = nil
  local start_time = time()
  if not wait(function(reset_wait_start_time)
    state = findAny({
      "开始行动红", "源石恢复理智取消", "药剂恢复理智取消",
      "单选确认框", "源石恢复理智不足", "当期委托侧边栏",
      "行动结束",
    })
    -- 剿灭后一直按开始行动导致开始行动界面消失，可能出现下面的界面
    if state == "当前委托侧边栏" then
      path.跳转("首页")
      return true
    end

    if state == "单选确认框" then return true end
    if state == "开始行动红" then return true end
    if state == "行动结束" then return true end
    if state and not disappear(state, .5) then return true end
    if findOne("正在提交反馈至神经") then reset_wait_start_time() end

    local p = findAny({"开始行动", "全权委托确认使用"})
    if p then

      tap("开始行动蓝")
      -- TODO 2秒太慢 => 一开始就用0秒, 2秒内增加至2秒
      disappear(p, min(5, (time() - start_time) / 1000 * 5 / 5))

    end
  end, 10) then
    back()
    appear("主页")
    path.跳转("首页")
    return
  end

  if state == "行动结束" then
    no_success_one_loop = 0
    return path.base.接管作战()
  elseif state == "开始行动红" then
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
    if not appear({"接管作战", "单选确认框"}, 60) then
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
        tap("恢复理智确认")
        disappear(state, 10)
      end
    end, 10) then return end
    return path.开始游戏(x)
  elseif stone_times < max_stone_times and state == "药剂恢复理智取消" then
    tap("源石恢复理智")
    state = "源石恢复理智取消"
    if not appear({state, '源石恢复理智不足'}) then
      log(2143)
      tap("开始行动蓝")
      return
    end
    if findOne('源石恢复理智不足') then
      log(2144)
      tap("开始行动蓝")
      return
    end

    stone_times = stone_times + 1
    if not wait(function()
      if findOne("开始行动") then return true end
      if findOne(state) then
        tap("恢复理智确认")
        disappear(state, 10)
      end
    end, 10) then return end
    return path.开始游戏(x)
  elseif state == "药剂恢复理智取消" then

    -- if (disable_drug_48hour and disable_drug_24hour) or
    --   not findTap("理智药清空选择") then
    --   log("2226", disable_drug_24hour, disable_drug_48hour)
    --   zero_san = true
    --   tap("药剂恢复理智取消")
    --   return
    -- end
    tap("理智药清空选择")

    local deadline = {}
    wait(function()
      deadline = ocr("理智药到期时间范围")
      if #deadline == 1 and deadline[1].text:includes({"天", "时"}) then
        return true
      end
    end, 5)
    deadline = deadline[1] or {text = ''}
    log(2317, deadline)
    local idx = table.findv(range(2, 7), function(i)
      return deadline.text == (i - 1) .. '天'
    end)
    if deadline.text:endsWith("时") then idx = 1 end
    idx = idx or 0
    log(2318, idx)
    local max_times = _G['max_drug_times_' .. idx .. 'day']
    local times = _G['drug_times_' .. idx .. 'day']
    if not max_times or times >= max_times or max_drug_times == -1 then
      log(2326, idx, times, max_times)
      zero_san = true
      tap("开始行动蓝")
      return
    end

    -- 理智小样为10, 最大理智关卡为35，5次应该足够
    -- deadline = map(function(x) return {x.r, scale(409)} end, deadline)
    -- for _, v in pairs(deadline) do for i = 1, 1 do tap(v) end end
    -- log(2240, deadline)
    tap({deadline.l, scale(409)})

    _G['drug_times_' .. idx .. 'day'] = times + 1
    log(drug_times_3day, max_drug_times_3day)
    if not wait(function()
      if findOne("开始行动") then return true end
      if findOne(state) then
        tap("恢复理智确认")
        disappear(state, 10)
      end
    end, 10) then return end

    -- -- 可能出现吃多次才能满足当前关卡，失败次数要减
    -- fight_failed_times[cur_fight] = (fight_failed_times[cur_fight] or 0) - 1

    return path.开始游戏(x)
  elseif state == "源石恢复理智取消" or state ==
    "药剂恢复理智取消" or state == '源石恢复理智不足' then
    zero_san = true
    tap("开始行动蓝")
  end
end

path.主线 = function(x)
  -- split s2-9 to 2 and 9
  local chapter = x:find("-")
  chapter = x:sub(1, chapter - 1)
  chapter = chapter:sub(chapter:find("%d+"))
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
    -- [state_with_home("按下当前进度列表" .. chapter_index)] = function()
    --   go()
    --   return true
    -- end,
  }
  if chapter_index <= 4 then -- chapter 0 to 3
    switch_start = 1
    switch_end = 4
  elseif chapter_index <= 9 then -- chapter 4 to 8
    switch_start = 5
    switch_end = 9
  elseif chapter_index <= 14 then -- chapter 9 to ?
    switch_start = 10
    switch_end = 14
  end
  for i = switch_start, switch_end do
    if chapter_index ~= i then
      p[state_with_home("当前进度列表" .. i)] =
        "当前进度列表" .. (i > chapter_index and "左" or "右")
      -- p[state_with_home("按下当前进度列表" .. i)] =
      --   "当前进度列表" .. (i > chapter_index and "左" or "右")
    end
  end
  -- log("chapter",chapter)
  -- exit()

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
    if not appear(table.keys(p), 5) then
      log("无法确认是第几章")
      return
    end
  end
  -- 10秒内需要完成章节切换
  auto(p, nil, 5, 5)
  path.开始游戏(x)
end

path.上一次 = function(x)
  log("1265")
  if findOne("开始行动") then return path.开始游戏(x) end
  log("1266")
  path.跳转("首页")
  tap("面板作战")
  if not appear("主页") then return end
  wait(function()
    tap("上一次")
    if not findOne("主页") then return true end
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
    ssleep(.5)
    tap("作战列表" .. x)
    appear("开始行动")
    path.开始游戏(x)
  end
end

clean_jmfight = function()
  -- if auto_clean_fight then
  log("before jmfight clean", fight, fight_tick)
  -- local unavailable_fight = type == "pr" and x:sub(1, 4) or x:sub(1, 2)
  -- log("unavailable_fight", unavailable_fight)
  fight, fight_tick = clean_table(fight, fight_tick, function(v)
    return get_fight_type(v) == '剿灭'
  end)
  log("after jmfight clean", fight, fight_tick)

end

clean_fight = function(x)
  log("before fight clean", fight, fight_tick)
  fight, fight_tick = clean_table(fight, fight_tick,
                                  function(v) return v == x end)
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

  if findOne("报酬合成玉已满") then
    log("find报酬合成玉已满")
    jmfight_enough = true
    clean_jmfight()
    return true
  end
  log("not find报酬合成玉已满")
  return false
end

path.剿灭 = function(x)
  -- 白色皮肤首页误判为已满
  -- if is_jmfight_enough(x) then return end

  path.跳转("首页")
  tap("面板作战")
  if not appear("主页") then return end

  -- 噪声是一方面，未解锁提示也会挡着，邮件提示也会挡着
  -- if not appear("每周报酬合成玉", 3) then
  --   jmfight_enough = true
  --   return
  -- end
  -- if not wait(function()
  --   tap("每周报酬合成玉")
  --   if not findOne("每周报酬合成玉") then return true end
  -- end) then return end

  if not wait(function()
    tap("主题曲")
    if findOne("主题曲界面") then return true end
  end) then return end

  wait(function()
    tap("每周部署")
    if not findOne("主题曲界面") then return true end
  end)

  -- 注意有噪点
  if not appear("主页") then return end
  if not wait(function()
    tap("当期委托")
    if not findOne("主页") then return true end
  end, 5) then return end

  if is_jmfight_enough(x) then return end
  if not appear("开始行动", 5) then return end
  if is_jmfight_enough(x) then return end

  -- if x ~= "当期委托" then
  -- 当期委托也需要切换
  -- if x ~= "剿灭" then
  -- 都需要切换
  wait(function()
    if findOne("切换") then return true end
    tap("主页右侧")
    appear("切换", 1)
  end, 5)

  if is_jmfight_enough(x) then return end

  if not wait(function()
    if findOne("当前委托侧边栏") then return true end
    tap("切换")
    appear("当前委托侧边栏")
  end, 5) then return end

  if not wait(function()
    if not findOne("当前委托侧边栏") then return true end
    tap("作战列表" .. x)
    disappear("当前委托侧边栏", 1)
  end, 5) then return end

  log(1287)
  -- end
  if is_jmfight_enough(x) then return end
  log(1289)
  -- ssleep(1)
  -- log(1290)
  appear("开始行动", 5)
  path.开始游戏(x)
end

clean_hdfight = function()
  -- TODO
  -- if auto_clean_fight then
  log("before hdfight clean", fight, fight_tick)
  -- local unavailable_fight = type == "pr" and x:sub(1, 4) or x:sub(1, 2)
  -- log("unavailable_fight", unavailable_fight)
  fight, fight_tick = clean_table(fight, fight_tick, function(v)
    return get_fight_type(v) == '活动'
  end)
  log("after hdfight clean", fight, fight_tick)
  -- end

end

path.活动 = function(x)
  log(3223, x)
  local t = parse_time()
  if t >= hd_open_time_end then
    clean_hdfight()
    return
  end
  path.跳转("首页")
  tap("面板活动2")
  if not wait(function()
    if findOne("活动导航1") then return true end
    if findOne("跳过剧情") then
      tap("跳过剧情")
      ssleep(.5)
      tap("跳过剧情确认")
    end
  end, 10) then return end

  if not wait(function()
    tap("活动导航2")
    if not appear("活动导航1") then return true end
  end, 5) then return end

  swip(x)
  ssleep(.5)
  tap("作战列表" .. x)
  if not appear("开始行动") then

    wait(function()
      if appear("主页") then return true end
      back()
    end, 30)

  end
  path.开始游戏(x)
end

-- path.活动 = hd_wrapper(path.活动)

path.活动2任务与商店 = function()

  for k, _ in pairs(point) do
    if k:startsWith("活动2") then
      local rk = k:sub(1, 6) .. k:sub(8)
      point[rk] = point[k]
      rfl[rk] = rfl[k]
    end
  end

  point.面板活动 = point.面板活动2
  rfl.面板活动 = rfl.面板活动2

  return path.活动任务与商店()
end

path.活动任务与商店 = function()
  path.跳转("邮件")
  path.跳转("首页")
  tap("面板作战")

  if not wait(function()
    tap("作战主页列表1")
    if findOne("活动导航1") then return true end
    if findOne("跳过剧情") then
      tap("跳过剧情")
      ssleep(.5)
      tap("跳过剧情确认")
    end
  end, 10) then return end

  -- if not wait(function()
  --   tap("活动任务")
  --   if not findOne("活动导航1") then return true end
  -- end, 5) then return end

  local g
  local success_once

  if not wait(function()
    tap("活动任务")
    if disappear("活动导航1", 1) then return true end
  end, 5) then return end

  local got = false
  wait(function()
    -- if findOne("活动任务一键领取") then return true end
    tap("活动任务一键领取")
    if not appear("主页", 1) or findOne("正在提交反馈至神经") then
      got = true
      return true
    end
  end)

  if got then
    disappear("正在提交反馈至神经", network_timeout)
    disappear("主页", 5)
    if not wait(function()
      tap("开包skip")
      tap("活动任务一键领取")
      local p = findAny({
        "主页", "单选确认框", "开始唤醒",
        "bilibili_framelayout_only", "面板",
      })
      log(2779, p)
      if p then return true end
    end, 15) then return end
  end

  if not appear("主页", 1) then return path.活动任务与商店() end
  captureqqimagedeliver(table.join(qqmessage, ' ') .. " " ..
                          "活动任务领取")
  tap("返回")
  if not appear("活动导航1") then return end

  g = function()
    if not wait(function()
      if findOne("活动商店横线") then return true end
      tap("开包skip")
      tap("收取信用有")
    end) then return end

    log(832)

    -- “剩余” 左上角优先
    local left = table.cat(map(function(x)
      point.r = {scale(1), scale(x), screen.width - scale(1), scale(x + 50)}
      return ocr('r')
    end, {459, 699, 939}))

    table.sort(left, function(a, b)
      if math.abs(a.l - b.l) < scale(10) then
        return a.t < b.t
      else
        return a.l < b.l
      end
    end)
    log(left)
    -- TODO 实际这个剩余范围只需要三行
    local p1 = table.findv(left,
                           function(x) return x.text:startsWith("剩余") end)
    if p1 then p1 = {p1.l, p1.t} end
    local p2 = findAny(point.活动商店列表)
    if not p1 and not p2 then return end

    tap("活动商店列表" .. 1)
    tap(p1)
    tap(p2)

    if not disappear("活动商店横线") then return end
    if not appear("活动商店支付") then return end

    if not wait(function()
      tap("活动商店最多")
      tap("活动商店支付")
      if not appear("活动商店支付", 1) or
        findOne("正在提交反馈至神经") then return true end
    end, 5) then
      success_once = false
      return
    end

    disappear("正在提交反馈至神经", network_timeout)
    disappear("主页", 5)
    if not wait(function()
      tap("开包skip")
      tap("收取信用有")
      if findAny({
        "活动商店横线", "开始唤醒", "单选确认框",
        "bilibili_framelayout_only", "面板",
      }) then return true end
    end, 10) then return end
    if findOne("活动商店横线") then success_once = true end
    return true
  end

  for i = 1, 4 do
    if not wait(function()
      if not findOne("活动导航1") then return true end
      tap("活动商店")
    end) then return end
    if not appear("活动商店横线", 5) then break end

    success_once = false
    while true do if not g() then break end end

    -- 一个商品都没买到
    if success_once == false then
      captureqqimagedeliver(table.join(qqmessage, ' ') .. " " ..
                              "活动奖励领取")
      break
    end

    -- 掉线
    if findAny({
      "开始唤醒", "bilibili_framelayout_only", "面板", "单选确认框",
    }) then return path.活动与商店() end

    if not wait(function()
      tap("收取信用有")
      tap("开包skip")
      if findOne("活动商店横线") then tap("返回") end
      if findOne("活动导航1") then return true end
    end, 5) then return end
  end
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

  if findOne("跳过剧情") then
    tap("跳过剧情")
    ssleep(.5)
    tap("跳过剧情确认")
  end

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
    tap("开始行动1")
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
  log(2253)
  path.跳转("好友")
  log(2254)
  if not wait(function()
    tap('好友列表')
    if findOne("好友列表") then return true end
  end, 10) then return end
  log(2255)
  if not wait(function()
    tap('访问基建')
    if findAny({"访问下位灰", "访问下位橘"}) and
      not findOne("好友列表") then return true end
    -- if not findOne("好友列表") then return true end
  end, 10) then return end -- 无好友或网络超时10秒
  log(2256)
  if speedrun then
    disappear("正在提交反馈至神经", network_timeout)
    appear("主页", 5)
    return
  end

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
    disappear("正在提交反馈至神经", network_timeout)
  end, 60) then return end
  log(2257)
end

path.公开招募 = function()
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
    if see == "立即招募列表" .. i and recruit_accelerate_mode then
      log(2236)
      if not appear("公开招募箭头") then return end
      wait(function()
        if not findOne("公开招募箭头") then return true end
        tapCard("立即招募列表" .. i)
      end, 5)
      log(2237)
      wait(function()
        if findOne("公开招募箭头") then return true end
        tap("中右确认")
      end, 5)
      log(2238)
      appear("聘用候选人列表" .. i)
      return
    end

    if see == "聘用候选人列表" .. i then
      log(i, 1001)
      -- 这个界面有噪点
      local last_time_see_home = time()
      if not wait(function()
        if findOne("主页") then last_time_see_home = time() end
        if time() - last_time_see_home > 1000 then return true end
        -- if not findOne("公开招募") and not findOne("主页") then
        --   return true
        -- end
        if findTap("聘用候选人列表" .. i) then
          log(1052)
          -- disappear("公开招募", 1)
        end
        tap("开包skip")
      end, 15) then return end

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
        if findOne("立即招募列表" .. i) then return true end
        tap("公开招募点击列表" .. i)
      end, 5) then return end
      if findOne("立即招募列表" .. i) then return f(i) end

      g = function(pre_tags)
        local tags, r
        wait(function()
          r = ocr("公开招募标签框范围")
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
          tags = {}
          log(1091, tags)
        end, 5)

        local skip = false
        if #table.keys(tags) < 5 then skip = true end
        -- 保留标签处理
        -- log(2316, extra_recruit_importance_tag, recruit_accelerate_mode)
        if recruit_accelerate_mode and extra_recruit_importance_tag and
          table.any(table.keys(tags),
                    function(x)
            return extra_recruit_importance_tag:find(x)
          end) then
          stop("已找到保留标签：" .. extra_recruit_importance_tag, '',
               true, true)
        end

        if debug_tag then
          tmp = {}
          -- tmp1 = {"医疗干员", "治疗", "新手", "防护", "削弱"}
          tmp1 = {"支援机械", "治疗", "新手", "防护", "近战位"}
          tmp2 = table.keys(tags)
          for j = 1, 5 do tmp[tmp1[j]] = tags[tmp2[j]] end
          tags = tmp
        end

        log(1092, tags, skip)
        -- exit()
        local tag4 = table.filter(tag5, function(rule)
          return table.all(rule[1], function(m) return tags[m] end)
        end)
        -- 有噪点，得等
        local can_refresh = appear({
          "公开招募标签刷新蓝", "公开招募标签刷新灰",
        }) == "公开招募标签刷新蓝"

        -- 如果勾选非保底，且不能刷新时，也招
        if auto_recruit0 and not can_refresh then
          table.extend(tag4, tag0)
        end

        log(1093, tag4)
        -- toast(JsonEncode(tags))

        if #tag4 == 0 or skip then
          if not skip and can_refresh then
            tap("公开招募标签刷新蓝")
            if not disappear("公开招募时间减", 10) then return end
            if not wait(function()
              if findOne("公开招募时间减") then return true end
              tap("公开招募右确认")
            end, 10) then return end
            -- if not appear("公开招募时间减") then return end
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
            if recruit_accelerate_mode then
              stop("已遇到需保留情况", '', true, true)
            end
          end
        else
          -- 最大星数
          local max_star = -1
          local list = {}

          for _, v in pairs(tag4) do
            -- 同星级需要优选“资深”优选，不选会出弹窗。
            local better = max_star < v[2] or max_star == v[2] and
                             (v[1][1] and v[1][1]:find("资深"))

            if better then
              max_star = v[2]
              list = v[1]
            end
          end

          if max_star >= 0 and not _G['auto_recruit' .. max_star] then
            log("notify 存在", max_star, list)
            -- table.insert(qqmessage, "可招募：" .. table.join(list))
            table.insert(qqmessage, table.join(list))
            if recruit_accelerate_mode then
              stop(table.join(list), '', true, true)
            end
          end

          if max_star >= 0 and _G['auto_recruit' .. max_star] then
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
              -- 点太快会无效
              ssleep(.25)
              wait(function()
                tap("公开招募确认蓝")
                if appear({"公开招募箭头", "返回确认界面"}, 3) then
                  return true
                end
              end, 10)
            end
            if not appear({"公开招募箭头", "返回确认界面"}) then
              return
            end

            -- 漏判高星弹出提示
            -- 这种情况出现并非ocr出错，而是选了另一个5星组合，而没选资深)
            -- 已经添加优选资深，这块逻辑不会走到，另外刷新时也需要添加判断，单加这里也不够
            -- if findOne('返回确认界面') then
            --   -- 关闭提示
            --   wait(function()
            --     if not findOne('返回确认界面') then
            --       return true
            --     end
            --     tap("左取消")
            --   end, 5)
            --   -- 标签界面 => 公招界面
            --   if not wait(function()
            --     if findOne("公开招募箭头") and
            --       findOne("公开招募列表" .. i) then
            --       return true
            --     end
            --     if findOne("公开招募时间减") then
            --       tap("返回")
            --       disappear("公开招募时间减", 1)
            --     end
            --   end, 5) then return end
            -- end
          end
        end
      end
      g()
    end
  end

  -- 第二个容易被刷新通知卡着，最后再做
  -- for i = 1, #point.公开招募列表 do
  for _, i in pairs(table.slice({1, 3, 4, 2}, 1, #point.公开招募列表)) do
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
    if not wait(function(reset_wait_start_time)
      if findAny(exit_state) then return true end
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
      tap("确认蓝")
    end, 5) then return end
  end

  f(1)
  f(1, true)
  path.信用购买()
  path.公开招募()

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
      end) then return end
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

    if not appear({"筛选未进驻选中", "筛选未进驻"}, 5) then
      return
    end
    if not appear({"筛选技能降序", "筛选技能", "筛选技能升序"},
                  5) then return end

    if not findOne("筛选未进驻") then
      if not wait(function()
        if findOne("筛选未进驻") then return true end
        tap("筛选未进驻")
        appear("筛选未进驻", 1)
      end, 5) then return end
    end

    if not findOne("筛选技能降序") then
      if not wait(function()
        if findOne("筛选技能降序") then return true end
        tap("筛选技能降序")
        appear("筛选技能降序", 1)
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

    if not wait(function(reset_wait_start_time)
      if findAny({"隐藏", "进驻信息", "进驻信息选中"}) then
        return true
      end
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
      tap("确认蓝")
    end, 5) then return end
  end
  for i = 1, #point.基建列表 do f(i) end
end

path.退出账号 = function()
  auto(update(path.base, {
    bilibili_framelayout_only = false,
    [function()
      return findOne("bilibili_framelayout_only") and
               not findOne("bilibili_username_inputbox")
    end] = function() auto(path.bilibili_login_change, nil, 0, 300, true) end,
    面板 = function()
      tap("面板设置", true)
      if not appear("返回3") then return end
      wait(function()
        tap("退出登录" .. (appid == oppid and '' or '2'))
        ssleep(.1)
        tap("右右确认")
      end, 1)
    end,
    --  开始唤醒 = "账号管理",
    开始唤醒 = function()
      check_login_frequency()
      tap("账号管理")
      disappear("开始唤醒")
    end,
    bilibili_username_inputbox = true,
    手机验证码登录 = true,
  }, nil, true), path.fallback, 0, 300)
end

path.前瞻投资 = function(lighter)
  -- 防止日志占用资源过多把脚本挤掉
  -- if zl_disable_log then disable_log = true end
  -- 防止无障碍节点获取失效，而反复重启游戏（在7时42分记录中浪费了2分多钟）
  -- if zl_disable_game_up_check then disable_game_up_check = true end
  -- 3.6.0发现当节点获取失效时，点击、找色其实都出问题了
  --
  -- path.base.账号登录 = function()
  --   if not wait(function()
  --     tap("账号登录返回")
  --     if disappear("账号登录") then return true end
  --   end, 10) then stop("登录需要密码", false) end
  -- end
  -- path.base.手机验证码登录 = function()
  --   if not wait(function()
  --     tap("账号登录返回")
  --     if disappear("手机验证码登录") then return true end
  --   end, 10) then stop("登录需要密码", false) end
  -- end

  if findOne("凋零残响") then
    -- local last_time_see = time()
    wait(function()
      if findAny({"常规行动", "面板"}) then return true end
      -- if findOne("凋零残响") then
      --   last_time_see = time()
      -- elseif time() - last_time_see > 5000 then
      --   return true
      -- end
      tap("战略确认")
    end, 15)
    return
  end

  -- 每8小时做日常
  if not zl_no_waste_last_time or time() - zl_no_waste_last_time > 8 * 3600 *
    1000 then

    -- 并非首次
    if zl_no_waste_last_time then
      zl_no_waste_last_time = nil
      restart_account()
      -- saveConfig("hideUIOnce", "true")
      -- save_extra_mode(extra_mode, extra_mode_multi)
      -- restartPackage()
    end

    -- 首次
    if zl_no_waste then
      transfer_global_variable("multi_account_user0")
      update_state_from_ui()
      run(no_extra_job)
    end

    zl_no_waste_last_time = time()
  end

  local in_fight_return = ''
  local restart = function()
    toast(in_fight_return or '重开')

    ssleep(3)
    -- if not restart_game_check(zl_restart_interval) then
    if not request_memory_clean() then
      path.前瞻投资(true)
    else
      path.跳转("首页")
    end

    -- 脚本内存泄漏45M/h => 每小时重启acc进程
    -- 游戏内存泄漏66M/h => 每小时重启游戏

    -- -- 关闭游戏然后重启脚本
    -- if restart_game_check(zl_restart_interval) then
    --   saveConfig("hideUIOnce", "true")
    --   save_extra_mode(extra_mode, extra_mode_multi)
    --   log(3326, loadConfig("restart_mode_hook", ''))
    --   restartScript()
    -- end

    -- 抽空点亮幕后筹备
  end

  local jumpout
  if findOne("战略返回") then path.fallback.战略返回() end

  if findOne("暂停中") and findOne("生命值") then restartapp(appid) end

  -- 先导航到常规行动
  if not findOne("常规行动") then
    path.跳转("首页")

    tap("面板作战")
    if not appear("主页") then return end

    if not wait(function()
      if findOne("主题曲界面") then return true end
      tap("主题曲")
    end, 5) then return end

    if not wait(function()
      if findOne("傀影") then return true end
      tap("集成战略")
    end, 5) then return end

    if not wait(function()
      if findOne("常规行动") then return true end
      tap("进入主题")
    end, 5) then return end
  end

  if zl_level_enough then

    if zl_no_waste then

      -- todo
      transfer_global_variable("multi_account_user0")
      update_state_from_ui()
      run(no_extra_job)
    end
    stop("肉鸽结束", '', false, true)
  end

  if zl_coin_enough then
    if zl_no_waste then

      -- todo
      transfer_global_variable("multi_account_user0")
      update_state_from_ui()
      run(no_extra_job)
    end
    stop("肉鸽结束", '', false, true)
  end

  -- 检测等级
  local zl_level_check = function()
    if not (str2int(zl_max_level, 0) > 0) then return end
    if not findOne("常规行动") then return end
    -- if not wait(function()
    --   if not findOne("常规行动") then return true end
    --   tap("战略等级入口")
    -- end) then return end

    local prex = -1
    local ans = wait(function()
      ssleep(.5)
      -- if not findOne("常规行动") then return 0 end
      -- local x = ocr("战略等级") or {}
      local r = point["战略等级"]
      local x = ocrBinaryEx(r[1], r[2], r[3], r[4], "000000-feb525") or {}
      -- local x = ocrEx(r[1], r[2], r[3], r[4]) or {}
      log("4126", x)
      x = (x[1] or {}).text or ""
      x = number_ocr_correct(x)
      x = str2int(x:match("^(%d+).*"), -1)
      log("4127", x)
      if x == 125 and not findOne("战略等级" .. x) then return end
      if x >= 0 and x <= 140 and x == prex then return x end
      -- if x >= 0 and x <= 140 then return x end
      -- if x >= 0 then return x end
      prex = x
    end, 5)
    -- wait(function()
    --   tap("返回")
    --   if appear("常规行动") then return true end
    -- end, 5)
    return ans
  end

  local zl_level = zl_level_check() or -1
  if not zl_level_enough and zl_level == str2int(zl_max_level, 10000) then
    zl_level_enough = true
    captureqqimagedeliver(
      table.join(qqmessage, ' ') .. " " .. (zl_level or '') .. "等级已满")
  end

  -- 检测源石锭
  local zl_coin_check = function()
    if not (str2int(zl_max_coin, 0) > 0) then return end
    if str2int(zl_max_coin, 0) >= 999 then return end

    if not findOne("常规行动") then return end
    if not wait(function()
      if not findOne("常规行动") then return true end
      tap("战略源石锭入口")
    end) then return end

    local prex = -1
    local ans = wait(function()
      ssleep(.5)
      -- if not findOne("常规行动") then return 0 end
      local x = ocr("战略源石锭") or {}
      log(4195, x)
      x = (x[1] or {}).text or ""
      x = number_ocr_correct(x)
      x = str2int(x:match("[^%d](%d+)$"), -1)
      log("4128", x)
      if x >= 0 and x == prex then return x end
      -- if x >= 0 then return x end
      prex = x
    end, 5)
    wait(function()
      tap("返回")
      if appear("常规行动") then return true end
    end, 5)

    return ans
  end

  local zl_coin = zl_coin_check() or -1
  if not zl_coin_enough and zl_coin >= str2int(zl_max_coin, 10000) then
    zl_coin_enough = true
    captureqqimagedeliver(
      table.join(qqmessage, ' ') .. " " .. (zl_coin or '') .. "源石锭已满")
  end

  -- 等级/源石锭 阶段性通知
  if not zl_captcha_time or time() - zl_captcha_time > 3600 * 1000 then
    zl_captcha_time = time()
    local info = ''
    if str2int(zl_max_level, 0) > 0 then
      info = info .. zl_level .. '/' .. zl_max_level .. ' '
    end
    if str2int(zl_max_coin, 0) > 0 then
      info = info .. zl_coin .. '/' .. zl_max_coin
    end
    captureqqimagedeliver(table.join(qqmessage, ' ') .. " " .. info)
  end

  -- if not findOne("常规行动") then return end

  -- log(zl_coin, zl_level)
  -- exit()
  -- 放弃探索
  if findOne("放弃探索") then
    if not wait(function()
      if findOne("返回确认界面") then return true end
      tap("放弃本次探索")
    end, 5) then
      log(2608)
      -- 无法直接放弃的情况 不处理
      if not wait(function()
        if not findOne("常规行动") then return true end
        tap("继续探索")
        ssleep(.5)
        log(2613)
      end, 5) then return end

      if not wait(function()
        if findOne("常规行动") then return true end
        -- 第一次数据更新处理
        if findAny({
          "面板", "活动公告返回", "签到返回", "签到返回黄",
          "开始唤醒", "bilibili_framelayout_only",
        }) then
          jumpout = true
          return true
        end
        tap("战略确认")
      end, 5) then return end
      if jumpout then return end

    end
    if not wait(function(reset_wait_start_time)
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
      if findOne("返回确认界面") then
        tap("右右确认")
        return
      end
      tap("战略确认")
      if findOne("常规行动") and not findOne("放弃探索") then
        return true
      end
      -- 第一次数据更新处理
      if findAny({
        "面板", "活动公告返回", "签到返回", "签到返回黄",
        "开始唤醒", "bilibili_framelayout_only",
      }) then
        jumpout = true
        return true
      end
    end, 30) then return end
  end
  if jumpout then return end

  -- 等级满了，放弃行动后回到首页再截个图
  if zl_level_enough or zl_coin_enough then

    -- wait(function(reset_wait_start_time)
    --   if not findOne("常规行动") then return true end
    --   tap("战略确认")
    -- end,5)

    captureqqimagedeliver(table.join(qqmessage, ' ') .. " 放弃行动后")

    wait(function(reset_wait_start_time)
      if not disappear("常规行动") then return true end
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
      tap("战略确认")
    end, 5)
    return
    -- return path.fallback.签到返回()
  end

  -- 回到常规行动？

  -- 点幕后筹备后继续
  if lighter and not lighter_enough and not zl_disable_lighter then
    local f = function()
      -- 进入幕后
      if not wait(function()
        tap("战略确认")
        tap("幕后筹备")
        if findOne("幕后筹备界面") then return true end
      end, 5) then return end

      -- 确认是否已满
      ssleep(.1)
      tap("幕后筹备升级右列表1")
      appear({"幕后筹备升级有", "幕后筹备升级无"}, .5)
      if findOne("幕后筹备升级无") then
        lighter_enough = true
        return
      end

      -- 确认类型
      local lists = {
        "幕后筹备升级左列表", "幕后筹备升级中3列表",
        "幕后筹备升级中2列表", "幕后筹备升级中1列表",
      }
      local list = point["幕后筹备升级右列表"]
      if not findOne("幕后筹备升级") then
        local found
        for _, p in pairs(lists) do
          tap(p .. 1)
          if appear("幕后筹备升级", .5) then
            list = point[p]
            found = true
            break
          end
        end
        if not found then return end
      end

      -- 从左向右点
      list = map(function(p) return point[p] end, list)
      table.sort(list, function(a, b) return a[1] < b[1] end)

      tap(list[2])
      for _, p in pairs(list) do
        tap(p)
        -- local jumpout
        if not wait(function(reset_wait_start_time)
          appearTap("幕后筹备升级有", .25)
          if findAny({"幕后筹备升级无", "幕后筹备升级不"}) then
            return true
          end
          -- if not appear({"幕后筹备升级", "正在提交反馈至神经"}) then
          --   jumpout = true
          --   return true
          -- end
          if findOne("正在提交反馈至神经") then
            reset_wait_start_time()
          end
        end, 2) then break end
      end
    end
    f()
    return
  end

  -- 开始探索
  if not wait(function(reset_wait_start_time)
    if findOne("战略返回") then return true end
    -- 第二次数据更新处理
    if findAny({
      "面板", "活动公告返回", "签到返回", "签到返回黄",
      "开始唤醒", "bilibili_framelayout_only",
    }) then
      jumpout = true
      return true
    end
    if findOne("正在提交反馈至神经") then reset_wait_start_time() end
    tap("战略确认")
    tap("继续探索")
  end, 5) then
    -- 初始选难度
    tap("战略难度列表" .. (zl_more_experience and "2" or "1"))
    return
  end
  if jumpout then return end

  -- 开始探索 一路按到 招募干员
  local first_time_see_first_card = 0
  if not wait(function(reset_wait_start_time)
    if findOne("初始招募") then return true end
    if findOne("正在提交反馈至神经") then reset_wait_start_time() end
    tap("战略确认")
    tap("战略确认")
    tap("战略确认")
    if findOne("指挥分队") then
      if first_time_see_first_card == 0 then
        first_time_see_first_card = time()
      end
      if time() - first_time_see_first_card > 2000 then
        tap("指挥分队1")
        appear("指挥分队确认", 1)
        ssleep(.5)
        tap("指挥分队确认")
        disappear("指挥分队确认")
        first_time_see_first_card = 0
      end
    else
      first_time_see_first_card = 0
    end

    -- 因为小号只有指挥分队，但每一秒只做一次
    -- if findAny({"指挥分队", "指挥分队确认"}) and time() -
    --   last_time_see_first_card > first_card_interval then
    --   first_card_interval = 5000 -- 1秒
    --   findTap("指挥分队")
    --   wait(function() tap("战略确认") end, 0.5)
    --   if findTap("指挥分队确认") then disappear("指挥分队确认") end
    --   last_time_see_first_card = time()
    -- end

  end, 10) then return end

  if not wait(function(reset_wait_start_time)
    if findOne("初始招募") then return true end
    tap("近卫招募券")
  end, 10) then return end

  -- 第二人，这里三步带了 剿灭说明 处理
  if not wait(function()
    if findOne("确认招募") then return true end
    if findOne("剿灭说明") then tap("剿灭说明") end
    tap("辅助招募券")
    tap("招募说明关闭")
  end, 10) then return end

  if not wait(function()
    tap("放弃招募")
    if findOne("剿灭说明") then tap("剿灭说明") end
    if not findOne("确认招募") then return true end
  end, 10) then return end

  if not wait(function()
    tap("右右确认")
    if findOne("剿灭说明") then tap("剿灭说明") end
    if findOne("初始招募") then return true end
  end, 10) then return end

  -- 第三人
  if not wait(function()
    tap("医疗招募券")
    tap("招募说明关闭")
    if findOne("确认招募") then return true end
  end, 10) then return end

  if not wait(function()
    tap("放弃招募")
    if not findOne("确认招募") then return true end
  end, 10) then return end

  if not wait(function()
    tap("右右确认")
    if findOne("初始招募") then return true end
  end, 10) then return end

  -- 第一人
  if not wait(function()
    tap("近卫招募券")
    tap("招募说明关闭")
    if not findOne("初始招募") and findOne("确认招募") then
      return true
    end
  end, 10) then return end

  local help_fight = function()
    -- if not findOne("确认招募") then return end
    if not wait(function()
      if findOne("战略助战界面") then return true end
      tap("战略助战")
    end, 5) then return end

    local operator
    if not wait(function()
      operator = ocr("战略助战干员范围")
      if #operator > 3 then return true end
    end, 5) then stop("找不到助战干员", 'cur') end

    local name2point = table.reduce(operator, function(a, c)
      a[c.text] = c
      return a
    end, {})

    -- 山2、羽毛笔1、耀光1、史尔特尔2、煌2、帕拉斯1、赫拉格2、艾丽妮1、银灰1、幽灵鲨1、拉狗2
    local order = {
      {"山", 1, 2}, {"羽毛笔", 0, 1}, {"耀骑士临光", 0, 1},
      {"史尔特尔", 99, 2}, {"帕拉斯", 0, 1}, {"赫拉格", 99, 2},
      {"艾丽妮", 0, 1}, {"斯卡蒂", 99, 1}, {"银灰", 0, 1},
      {"幽灵鲨", 99, 1}, {"拉普兰德", 0, 1},
    }
    local best = table.findv(order, function(x) return name2point[x[1]] end)
    if not best then return end
    zl_skill_times = best[2]
    zl_skill_idx = best[3]
    -- log("best", best)
    -- if not best then return point.战略助战干员列表1, 0, 1 end
    local p = name2point[best[1]]
    p = {p.l, p.t}
    tap(p)
    disappear("战略助战界面", 5)
    wait(function()
      if findOne("初始招募") then return true end
      tap("开包skip")
      tap("战略助战确认")
    end, 5)
  end

  if not wait(function()
    if findAny({"初始招募", "战略返回"}) then
      log(26)
      return true
    end
    if findOne("返回确认界面") then
      log(27)
      -- 虽然不知道会不会走这儿
      tap("左取消")
      disappear("返回确认界面")
      -- 不等会怎么样呢，有时会闪
      ssleep(.5)
    end
    log(28, zl_best_operator)
    local idx = str2int(zl_best_operator, -1)

    if idx >= 1 and idx <= 12 then
      -- 指定
      tap("近卫招募列表" .. (zl_best_operator or 1))
      findTap("确认招募")
      tap("开包skip")

    elseif idx == -1 then
      -- 助战自动
      help_fight()
    else
      stop("请设置近卫干员序号(1~12)", '', true, false)
    end
  end, 10) then return end

  if not appear("初始招募") then return end

  log(2698)
  -- 进入古堡 必须分为两段，否则产生位移
  if not wait(function()
    if not findOne("初始招募") then return true end
    tap("进入古堡")
  end, 5) then return end

  -- if not wait(function()
  --   if findOne("编队") then return true end
  --   tap("进入古堡")
  -- end, 10) then return end

  log(2700)
  if not appear("战略帮助", 10) then return end

  -- 先看作战
  local fight1ocr = {}
  if not wait(function()
    fight1ocr = ocr("第一层作战")

    if #fight1ocr > 0 then
      local fight1 = fight1ocr[1]
      -- 只支持三种作战
      if fight1.text:includes({"意", "外"}) then
        fight1.text = "意外"
      elseif fight1.text:includes({"礼", "炮", "队"}) then
        fight1.text = "礼炮小队"
      elseif fight1.text:includes({"与", "虫", "伴"}) then
        fight1.text = "与虫为伴"
      elseif fight1.text:includes({"驯", "兽", "屋"}) then
        fight1.text = "驯兽小屋"
      elseif fight1.text:includes({"死", "斗"}) then
        fight1.text = "死斗"
      else
        log("不知道什么作战：" .. fight1.text)
        return
      end
      return true
    end
  end, 5) then
    stop("不知道第一个作战是什么", 'cur')
    return
  end
  log(fight1ocr)

  local fight1 = fight1ocr[1]

  -- -- 只支持三种作战
  -- if fight1.text:includes({"意", "外"}) then
  --   fight1.text = "意外"
  -- elseif fight1.text:includes({"礼", "炮", "队"}) then
  --   fight1.text = "礼炮小队"
  -- elseif fight1.text:includes({"与", "虫", "伴"}) then
  --   fight1.text = "与虫为伴"
  -- elseif fight1.text:includes({"驯", "兽", "屋"}) then
  --   fight1.text = "驯兽小屋"
  -- else
  --   toast("不知道什么作战：" .. fight1.text)
  --   return
  -- end
  -- if fight1.text == '死斗' then ssleep(1000) end

  if zl_skip_hard and fight1.text == "驯兽小屋" then
    in_fight_return = "驯兽小屋重试"
    return restart()
  end

  -- 幻觉选择性放弃
  if findOne("偏执的") then
    local all = {
      "迷茫的", "盲目的", "暴怒的", "孤独的", "偏执的",
      "敏感的", "臆想的", "生存的", "谨慎的",
    }
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

      -- 分割
      for _, v in pairs(cur) do
        local txt = v.text
        while #txt > 9 do
          table.insert(cur, {text = txt:sub(#txt - 8, #txt)})
          txt = txt:sub(1, #txt - 9)
        end
        v.text = txt
      end

      log("cur", cur)
      -- 模糊匹配
      for _, v in pairs(cur) do
        local txt = v.text
        if #txt ~= 9 or not txt:endsWith("的") then return end
        local scores = map(function(x)
          return {x, chineseUnicodeStringMatch(x, txt)}
        end, all)
        table.sort(scores, function(a, b) return a[2] < b[2] end)
        log("scores", scores)
        if scores[#scores][2] == 2 and scores[#scores - 1][2] < 2 then
          log("模糊匹配before", txt)
          txt = scores[#scores][1]
          log("模糊匹配after", txt)
        end
        v.text = txt
      end

      if table.all(cur, function(x) return table.includes(all, x.text) end) then
        return true
      end
    end, 5) then
      in_fight_return = "未知幻觉重试：" ..
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

  -- 再看不期而遇
  for col = 1, 2 do
    local unexpect
    if findOne("第一层不期而遇" .. col .. "入口列表1") then
      unexpect = {
        "第一层不期而遇" .. col .. "列表1",
        "第一层不期而遇" .. col .. "列表3",
        "第一层不期而遇" .. col .. "列表5",
      }
    elseif findOne("第一层不期而遇" .. col .. "入口列表2") then
      unexpect = {
        "第一层不期而遇" .. col .. "列表2",
        "第一层不期而遇" .. col .. "列表4",
      }
    else
      unexpect = {"第一层不期而遇" .. col .. "列表3"}
    end
    for k, v in pairs(unexpect) do
      unexpect[k] = {
        text = findOne(v) and "不期而遇" or '作战',
        l = str2int(point[v]:match("^(%d+)|"), 0),
        t = str2int(point[v]:match("^%d+|(%d+)|"), 0),
      }
    end
    _G["unexpect" .. col .. "ocr"] = unexpect
  end

  -- 设置商店
  fight2 = point.第一层作战2
  fight2 = {l = fight2[1], t = fight2[2]}

  if not table.find(unexpect2ocr,
                    function(x) return x.text == "不期而遇" end) then
    in_fight_return = "第三列没找到不期而遇"
    return restart()
  end

  local from_bottom_node = findOne("第一层从下方来")

  if not table.find(unexpect1ocr,
                    function(x) return x.text == "不期而遇" end) then
    in_fight_return = "第二列没找到不期而遇"
    return restart()
  end
  log(unexpect1ocr, unexpect2ocr)

  log(2723)
  -- 根据不期而遇来选择路径，只有边上两个均为不期而遇才行
  local unexpect1, unexpect2
  if unexpect1ocr[1].text == "不期而遇" and unexpect2ocr[1].text ==
    "不期而遇" then
    unexpect1 = unexpect1ocr[1]
    unexpect2 = unexpect2ocr[1]
  elseif unexpect1ocr[#unexpect1ocr].text == "不期而遇" and
    unexpect2ocr[#unexpect2ocr].text == "不期而遇" then
    unexpect1 = unexpect1ocr[#unexpect1ocr]
    unexpect2 = unexpect2ocr[#unexpect2ocr]
  elseif #unexpect1ocr == 1 then
    unexpect1 = unexpect1ocr[1]
    unexpect2 = table.findv(unexpect2ocr,
                            function(x) return x.text == "不期而遇" end)
  elseif #unexpect2ocr == 1 then
    unexpect2 = unexpect2ocr[1]
    unexpect1 = table.findv(unexpect1ocr,
                            function(x) return x.text == "不期而遇" end)

    -- 2 走 3 且 3只有中间为不期而遇时，确认2的上还是下来的
  elseif #unexpect2ocr == 3 and unexpect2ocr[2].text == '不期而遇' and
    #unexpect1ocr == 2 and unexpect1ocr[1].text == '不期而遇' and
    not from_bottom_node then
    unexpect2 = unexpect2ocr[2]
    unexpect1 = unexpect1ocr[1]
  elseif #unexpect2ocr == 3 and unexpect2ocr[2].text == '不期而遇' and
    #unexpect1ocr == 2 and unexpect1ocr[2].text == '不期而遇' and
    from_bottom_node then
    unexpect2 = unexpect2ocr[2]
    unexpect1 = unexpect1ocr[2]
  else
    in_fight_return = "难以找到一条全是不期而遇的路"
    return restart()
  end

  if not wait(function()
    tap({fight1.l, fight1.t})
    if appear("进入界面", 1) then return true end
  end) then
    in_fight_return = "无法进入作战"
    return restart()
  end
  -- tap({fight1.l, fight1.t})
  -- if not appear("进入界面") then
  --   return
  -- end
  if not wait(function()
    if findOne("快捷编队") then return true end
    tap("进入")
  end, 10) then return end

  if not wait(function()
    if findOne("确认招募") then return true end
    tap("快捷编队")
  end, 10) then return end

  if not wait(function()
    if findOne("攻击范围") and
      (zl_skill_idx ~= 2 or zl_skill_idx == 2 and findOne("战略二技能")) then
      return true
    end

    tap("近卫招募列表1")
    if not appear("攻击范围", 1) then return end
    if zl_skill_idx == 2 then
      tap("战略二技能")
      if not appear("战略二技能", 1) then return end
    end
  end, 10) then return end

  if not wait(function()
    if not findOne("确认招募") then return true end
    tap("确认招募")
  end, 10) then return end

  if not appear("快捷编队") then return end

  -- -- 回到上一级（这里好bug，选完人，开始行动就没了，只能回退）
  -- if not wait(function()
  --   if not findOne("快捷编队") then return true end
  --   tap("返回")
  --   disappear("快捷编队", 1)
  -- end, 10) then return end
  --
  -- if not wait(function()
  --   if findOne("快捷编队") then return true end
  --   tap("继续探索")
  -- end, 10) then return end

  -- 开始游戏
  if not wait(function()
    tap("确认招募")
    if not findOne("快捷编队") then return true end
    -- 出现过在这儿卡死的
    if not disappear("正在提交反馈至神经", network_timeout) then
      restartapp(appid)
      return true
    end
  end, 10) then return end

  -- 游戏界面
  if not wait(function()
    if findOne("单选确认框") then return true end
    if findOne("生命值") then return true end
  end, 30) then return end

  if not findOne("生命值") then return end

  -- 需要等等才能点
  appearTap("两倍速", 3)

  if #in_fight_return > 0 then
    toast(in_fight_return .. "，10秒后重开")
    ssleep(10)
    tap("面板设置", true)
    ssleep(2)
    tap("放弃行动")
    ssleep(2)
    tap("右确认")

    wait(function()
      if findAny({
        "战略返回", "面板", "活动公告返回", "签到返回",
        "签到返回黄", "开始唤醒", "常规行动",
        "bilibili_framelayout_only",
      }) then return true end
      tap("战略确认")
    end, 60)

    return
  end

  if not wait(function()
    if findOne("干员费用够列表1") then return true end
    if not findOne("生命值") then
      log(2827)
      -- return true
    end
  end, 30) then return end

  -- 重复拖拽
  wait(function()
    log(4105)
    tap("干员费用够列表1")
    disappear("干员费用够列表1", 0.5)
    -- 部署 拖拽当前第一个干员至部署位dst，方向朝左或右
    local direction = 4
    if table.includes({"礼炮小队", "驯兽小屋"}, fight1.text) then
      direction = 2
    end
    if fight1.text == '死斗' then direction = 1 end
    deploy3(1, fight1.text, direction)
    log(4106)
    wait(function()
      if findOne("生命值") then return true end
      tap("开始行动1")
    end)

    log(4107)
    if not appear("干员费用够列表1", 5) then return true end
    log(4108)
  end, 20)
  log(4109)

  appear("生命值")

  log(4110)
  -- 超时作战不对劲 超5分钟
  local last_time_see_life = time()
  local skill_times = 0
  if not wait(function()
    if findOne("返回确认界面") then tap("左取消") end
    if findOne("暂停中") then
      tap("开包skip")
      disappear("暂停中")
    end
    if findOne("生命值") then last_time_see_life = time() end
    -- 超过3秒没看到生命值
    if time() - last_time_see_life > 5000 then
      tap("战略确认")
      return true
    end
    tap("开始行动1")
    local p = findOne("技能亮")
    if p and skill_times < zl_skill_times then
      skill_times = skill_times + 1
      tap({p[1], p[2] + scale(200)})
      -- appear("技能ready", 5)
      appear("生命值蓝", 5)
      ssleep(0.5)
      wait(function()
        tap("开技能")
        if disappear("生命值蓝", 1) then return true end
      end)
    end
  end, 300) then return restartapp(appid) end

  appear({"战略返回", "凋零残响"}, 30)
  if findOne("凋零残响") then return end
  if not findOne("战略返回") then return end

  local drop_page = false
  if not wait(function()
    if not drop_page then tap("战略确认") end
    if zl_more_repertoire then findTap("剧目") end
    if zl_more_experience then findTap("招募券") end
    findTap("收藏品")
    if findTap("源石锭") then drop_page = true end
    local p = findOne("不要了")
    log(4233)
    if p and findOne("战略返回") then
      tap({p[1] + scale(765 - 668), scale(789)})
      tap({p[1] + scale(765 - 668), scale(789)})
      tap({p[1] + scale(765 - 668), scale(789)})
      tap({p[1] + scale(765 - 668), scale(789)})
    end

    -- 误触到招募券处理
    if findOne("确认招募") then
      -- 放弃招募
      if not zl_more_experience then

        if not wait(function()
          if not findOne("确认招募") then return true end
          tap("放弃招募")
        end, 5) then return end

        if not wait(function()
          if findOne("编队") then return true end
          tap("右右确认")
        end, 5) then return end

      else

        -- 招募
        if findOne("确认招募") then
          local start_time = time()
          if not wait(function()
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
            tap("近卫招募列表" .. 1)
            findTap("确认招募")
            tap("开包skip")
          end, 10) then return end
        end
      end
    end

    if not findOne("战略返回") then
      if not appear({"战略返回", "战略帮助"}) then
        tap("战略确认")
      end
    end
    -- if disappear("战略返回",0.5) then return true end
    if findAny({"常规行动", "战略帮助"}) and not findOne("确认招募") then
      return true
    end
  end, 30) then return end

  -- if not appear("战略返回", 5) then return end

  if not findOne("战略帮助") then
    log(2873)
    return
  end

  local last_time_see_help

  -- 不期而遇1 两次尝试
  tap({point.第一层下一个[1], unexpect1.t})
  -- ssleep(.2)
  if not appear("进入界面") then return end
  last_time_see_help = time()
  if not wait(function()
    if findOne("战略帮助") then last_time_see_help = time() end
    if time() - last_time_see_help > 250 then return true end
    tap("不期而遇第三选项")
  end, 3) then
    swipzl("right")
    tap({unexpect1.l, unexpect1.t})
    last_time_see_help = time()
    if not wait(function()
      if findOne("战略帮助") then last_time_see_help = time() end
      if time() - last_time_see_help > 250 then return true end
      tap("不期而遇第三选项")
    end, 3) then return end
  end

  wait(function()
    if findOne("确认招募") then
      if not wait(function()
        if not findOne("确认招募") then return true end
        tap("放弃招募")
      end, 5) then return end

      if not wait(function()
        if findOne("编队") then return true end
        tap("右右确认")
      end, 5) then return end
    end
    if findOne("战略帮助") then return true end
    -- 需要提前退出
    if not findOne("战略返回") and appear("战略帮助") then
      return true
    end
    tap("不期而遇第三选项")
    tap("不期而遇第三选项")
    tap("不期而遇第三选项")
    tap("不期而遇第三选项")
    tap("不期而遇第二选项")
    log(2960, findOne("确认招募"))
  end, 10)

  if not appear("战略帮助", 5) then return end

  -- 不期而遇2 两次尝试
  tap({point.第一层下一个[1], unexpect2.t})
  -- ssleep(.2)
  -- ssleep(.2)
  if not appear("进入界面") then return end
  last_time_see_help = time()
  if not wait(function()
    if findOne("战略帮助") then last_time_see_help = time() end
    if time() - last_time_see_help > 250 then return true end
    tap("不期而遇第三选项")
  end, 3) then
    swipzl("left")
    tap({unexpect2.l, unexpect2.t})
    last_time_see_help = time()
    if not wait(function()
      if findOne("战略帮助") then last_time_see_help = time() end
      if time() - last_time_see_help > 250 then return true end
      tap("不期而遇第三选项")
    end, 3) then return end
  end

  wait(function()
    if findOne("确认招募") then
      if not wait(function()
        if not findOne("确认招募") then return true end
        tap("放弃招募")
      end, 5) then return end

      if not wait(function()
        if findOne("编队") then return true end
        tap("右右确认")
      end, 5) then return end
    end
    if findOne("战略帮助") then return true end
    if not findOne("战略返回") and appear("战略帮助") then
      return true
    end
    tap("不期而遇第三选项")
    tap("不期而遇第三选项")
    tap("不期而遇第三选项")
    tap("不期而遇第三选项")
    tap("不期而遇第二选项")
    log(2961, findOne("确认招募"))
  end, 10)

  if not appear("战略帮助", 5) then return end
  -- 商店
  -- swipzl("left")
  -- tap({fight2.l, fight2.t})
  fight2.l = max(point.第一层下一个[1], fight2.l)
  tap({fight2.l, fight2.t})
  if not appear("进入界面") then return end

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
      stop("已遇到所需商品" .. goods, '', true, true)
    end
    log("未找到商品", goods, need_goods)
  end

  local goto_next_level = function()
    if not zl_more_experience then return end
    -- 去第二层
    wait(function()
      if not findOne("战略返回") then return true end
      tap("诡意行商离开")
    end, 10)
    wait(function()
      if findOne("战略返回") then return true end
      tap("诡意行商离开")
    end, 10)
  end

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

  local coin = function()

    -- if not appear("诡意行商投资", 1) then return goto_next_level() end
    if not appear("诡意行商投资", 1) then return true end
    if not wait(function()
      if findOne("诡意行商投币") then return true end
      tap("诡意行商投资")
    end) then return end
    if not wait(function()
      if findOne("诡意行商投资入口") then return true end
      tap("诡意行商投币")
    end) then return end

    local coin_no_notification = sample("投币提示")

    -- 超时改为60秒，有时会出现上限极高情况
    wait(function(reset_wait_start_time)
      -- 不能投情况
      if not findOne("诡意行商投资入口") then return true end
      if findOne("正在提交反馈至神经") then
        reset_wait_start_time()
      end
      if not findOne(coin_no_notification) then reset_wait_start_time() end

      -- 6秒后，如果底部投币提示没有，那就说明投币结束
      -- 能投但币不够或者已投满
      -- if time() - coin_start_time > 6000 and findOne(coin_no_notification) then
      --   return true
      -- end
      tap("诡意行商确认投资")
    end, 6)
  end

  if not wait(function()
    -- if not findOne("战略帮助") then return true end
    if findAny({"诡意行商投资", "诡意行商离开"}) then return true end
    tap("进入")
  end, 3) then
    -- check_goods()
    -- goto_next_level()
    return
  end

  check_goods()

  if not zl_skip_coin then coin() end

  if zl_more_experience then
    if not wait(function()
      if findOne("诡意行商离开") then return true end
      tap("开包skip")
    end, 5) then return end
    for i = 1, 10 do if not buy() then break end end
  end

  return goto_next_level()
end

path.战略前瞻投资 = never_end_wrapper(path.前瞻投资)

path["克洛丝单人1-12"] = function()
  -- TODO
end

path.公开招募加急 = function()
  -- 只处理第一个列表
  recruit_accelerate_mode = true
  point.公开招募列表 = table.slice(point.公开招募列表, 1, 1)
  forever(path.公开招募)
end
