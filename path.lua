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
  start黄框 = function()
    for _ = 1, 5 do
      tap("start黄框")
      ssleep(.5)
    end
  end,
  start黄框暗 = function()
    for _ = 1, 5 do
      tap("start黄框")
      ssleep(.5)
    end
  end,
  账号登录 = "账号登录",
  开始唤醒 = "开始唤醒",
  登录 = function()
    local inputbox = R():type("EditText"):name(appid):path(
                       "/FrameLayout/EditText")
    if #username > 0 then
      tap("账号左侧")
      tap("账号")
      if not appear(inputbox) then stop("登录失败") end
      input(inputbox, username)
      tap("右下角确认", 0, true)
      if not disappear(inputbox) then stop("登录失败") end
      if not appear("登录") then stop("登录失败") end
    end
    if #password > 0 then
      tap("账号左侧")
      tap("密码")
      if not appear(inputbox) then stop("登录失败") end
      input(inputbox, password)
      tap("右下角确认", 0, true)
      if not disappear(inputbox) then stop("登录失败") end
      if not appear("登录") then stop("登录失败") end
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
  end,
  其它 = "返回",
  -- need test
  -- 客户端过时 = function() stop("客户端过时") end,
  -- 限时活动返回 = function()
  --   local t = "限时活动列表"
  --   for i = 1, #point[t] do
  --     log(t .. i)
  --     tap(t .. i)
  --   end
  --   tap('限时活动返回')
  -- end,
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
  -- 触发数据更新
  path.跳转("首页")
  tap("面板邮件")

  path.跳转("邮件")
  if not wait(function()
    if findAny({"邮件提示", "邮件提示2"}) then return true end
    tap("收取所有邮件")
  end, 5) then return end
end

path.基建收获 = function()
  path.跳转("基建")
  log(132)
  local x = findAny({"基建灯泡蓝", "基建灯泡蓝2"})
  log(133, x)
  if not x then return end
  log(134)

  if not wait(function()
    if not findOne(x) then return true end
    tap(x)
    disappear(x, 1)
  end, 8) then return end

  if not wait(function()
    if not appearTap("点击全部收取") then return true end
  end, 15) then return end
end

prev_jump = nil
path.跳转 = function(x, disable_quick_jump)
  local sign = {
    好友 = "个人名片",
    基建 = "进驻总览",
    公开招募 = "公开招募",
    首页 = "面板",
    采购中心 = "可露希尔推荐",
    任务 = "任务第一个",
    终端 = "主页",
    邮件 = "邮件信封",
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
  local target = sign[x]
  local home_target = x == "邮件" and "首页" or x
  if findOne(target) then return true end
  local p
  p = update(path.base, {
    面板 = function()
      p["主页"] = nil
      tap(plain[x])
      appear({target, "活动公告返回"}, 5)
    end,
    主页 = function()
      p["主页"] = nil
      tap("主页")
      if not appear("主页列表任务") then return end
      tap("主页列表" .. home_target)
    end,
  })
  if x == prev_jump or disable_quick_jump then p.主页 = nil end

  p[target] = true
  p[target] = function()
    if not disappear(target, .5) then
      log("see", target, "after one second")
      return true
    end
  end

  local fallback = {返回确认 = "右确认"}
  if x == "基建" then
    fallback.返回确认 = function()
      back()
      appear("进驻总览")
    end
  end

  auto(p, fallback)
  if x == "基建" then
    log("before zoom")
    --    local state = sample("缩放")
    if not wait(function()
      if findOne("缩放结束") then return true end
      zoom()
    end, 10) then return true end
    log("after zoom")
  end
  prev_jump = x
end

start_time = parse_time("202101010400")
update_state_last_day = 0
update_state_last_week = 0
communication_enough = false
jmfight_enough = false
zero_san = false
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

-- path.限时活动 = update(path.base, {
--   -- TODO
--   面板 = function()
--     if not findTap('面板限时活动') then return true end
--     local t = "限时活动列表"
--     for i = 1, #point[t] do
--       log(t .. i)
--       tap(t .. i)
--     end
--     tap('限时活动返回')
--     auto(path.base)
--   end,
-- })

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
      if findOne("确认蓝") then return true end
      if findOne("基建副手简报") then
        tap("基建副手列表" .. i)
        disappear("基建副手简报", 1)
      end
    end, 5) then return end

    if appear("干员选中", 1) then tap("干员选择列表1") end
    if not disappear("干员选中") then return end

    local state = sample("信赖")
    tap("信赖")
    log("state", state)
    disappear(state)

    state = sample("信赖")
    tap("信赖")
    disappear(state)

    tap("干员选择列表" .. i)
    tap("确认蓝")
    if not appear("基建副手简报") then return end
  end
  --  path.跳转("基建", true)
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
  log(312)
  -- 宿舍换人
  local f
  f = function(i)
    log(315)
    path.跳转("基建")
    log(316)
    if not appearTap("宿舍列表" .. i) then
      log("未找到宿舍列表" .. i)
      return
    end
    log(317)

    if not wait(function()
      if findAny({"进驻信息", "进驻信息选中"}) then return true end
      if findOne("进驻总览") and findTap("宿舍列表" .. i) then
        disappear("进驻总览", 1)
      end
    end, 10) then return end

    log(318)
    if not wait(function()
      if findOne("进驻信息选中") and findOne("当前房间入住信息") then
        return true
      end
      if findTap("进驻信息") then disappear("进驻信息", 1) end
    end, 10) then return end
    log(319)

    if not wait(function()
      if not findOne("当前房间入住信息") then return true end
      tap("进驻第一人")
    end, 5) then return end
    if not appear("确认蓝", 5) then return end
    log(325)

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
    tap("确认蓝")

    if appear({"排班调整提示", "进驻信息", "进驻信息选中"}, 5) ==
      "排班调整提示" then
      if not wait(function()
        if not findOne("排班调整提示") then return true end
        tap("排班调整确认")
      end, 5) then return end
    end
  end
  for i = 1, 4 do f(i) end

  path.跳转("基建")
  if not wait(function()
    if findOne("撤下干员") then return true end
    if findTap("进驻总览") then disappear("进驻总览", 1) end
  end, 10) then return end

  local swip = function(up, starty, endy)
    if up then
      starty = starty or screen.height // 4 * 3
      endy = endy or 0
    else
      starty = starty or screen.height // 4
      endy = endy or screen.height
    end
    slid((1867 - 1919) * minscale + screen.width, starty,
         (1867 - 1919) * minscale + screen.width, endy, 333)
    --    ssleep(.33)

    tap("入驻干员右侧")
    ssleep(.33)
  end

  -- 其他换人
  f = function()
    if not findTap("入驻干员") then return end
    if not appear("确认蓝", 5) then return end
    if not wait(function()
      if findOne("筛选取消") then return true end
      if findOne("确认蓝") then tap("筛选") end
    end, 5) then return end
    findTap("筛选未进驻")
    findTap("筛选技能")
    tap("筛选确认")
    local limit = 1
    if not appear("确认蓝", 5) then return end
    if appearTap("清空选择", 1) then limit = 5 end
    if not wait(function()
      if findOne("干员未选中") then return true end
      tap("清空选择")
    end, 5) then return end
    for j = 1, limit do tap("干员选择列表" .. j) end
    tap("确认蓝")
    if appear({"排班调整提示", "撤下干员"}, 5) == "排班调整提示" then
      if not wait(function()
        if not findOne("排班调整提示") then return true end
        tap("排班调整确认")
      end, 5) then return end
    end
    if not appear("撤下干员") then return end
    return true
  end

  for i = 1, 15 do
    if i ~= 1 then swip(true) end
    while f() do end
    if findOne("入驻干员底部") then break end
  end
end

path.制造加速 = function()
  path.跳转("基建")
  --  swipq("right")
  --  sleep(.4)

  local station
  for i = 1, #point.基建左侧列表 do
    local x, y = table.unpack(point["基建左侧列表" .. i])
    --    log(x, y, i)
    if compareColor(x, y, "#FFCC00", 99) then
      --      log(380, i)
      station = {x, y}
      break
    end
  end

  if not station then
    log("未找到制造站")
    return
  end
  tap(station)
  disappear("进驻总览")
  if not wait(function()
    if findAny({"进驻信息", "进驻信息选中"}) then return true end
    if findOne("进驻总览") then tap(station) end
  end, 5) then return end
  tap("制造站进度")
  if not wait(function()
    if findOne("无人机加速") then return true end
    findTap("制造站加速")
  end, 5) then return end
  tap("无人机加速最大")
  if not wait(function()
    if findOne("制造站加速") then return true end
    tap("无人机加速确定")
  end, 5) then return end
  tap("制造站收取")
  --  path.跳转("基建", true)
end

path.线索搜集 = function()
  path.跳转("基建")

  local station = findOne("会客厅")
  if not station then return end

  -- this check if not enough
  --  if not debug0721 and not appear("会客厅有", 1) then return end

  if not wait(function()
    if findAny({"进驻信息", "进驻信息选中"}) then return true end
    if findOne("进驻总览") then tap(station) end
  end, 5) then return end
  tap("制造站进度")
  if appear("本次线索交流活动") then
    if not wait(function()
      if findOne("线索传递") then return end
      tap("返回")
      appear("线索传递", 1)
    end, 5) then return end
  end
  if findTap("接收线索有") then
    appearTap("全部收取", 5)
    if not wait(function()
      if findOne("线索传递") then return true end
      tap("解锁线索左")
      appear("线索传递", 1)
    end, 5) then return end
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
    while appear("信用奖励返回") do
      if findOne("未达线索上限") then
        break
      else
        tap("返回")
        path.线索布置()
        path.线索传递()
        return f()
      end
    end
    tap("信用奖励领取")
    -- TODO
    if appear("未达线索上限") then return f() end
    if not appear("线索传递") then tap("返回") end
    return true
  end
  if not f() then return end
  appear("线索传递")
  path.线索布置()
end

path.线索布置 = function()
  -- internal
  if not appear("线索传递") then return end
  local p = findAny(point.线索布置列表)

  -- tap with offset -50,50
  local f = function(k)
    local x, y = point[k]:match("(%d+),(%d+)")
    tap({tonumber(x) - 50, tonumber(y) + 50})
  end

  if p then
    f(p)
    if not appear("全部") then return end

    for i = 1, 7 do
      if findOne("线索布置左列表" .. i) then
        p = "线索布置左列表" .. i
        f(p)
        appear("线索传递数字右列表" .. i)
        tap("线索库列表1")
        if not disappear(p, 3) then return end
      end
    end
    tap("解锁线索左")
  end
  if not appear("线索传递") then return end

  if findTap("解锁线索") then
    if not appear("进驻信息", 5) then return path.线索搜集() end
    if not wait(function()
      if findOne("线索传递") then return true end
      if findAny({"进驻信息", "进驻信息选中"}) then
        tap("制造站进度")
      end
    end, 5) then return path.线索搜集() end
    path.线索布置()
  end
end

path.线索传递 = function()
  -- internal
  if not appearTap("线索传递") then return end
  if not appear("线索传递数字列表8", 5) then return end

  for i = 1, 8 do
    tap("线索传递数字列表" .. i)
    if not appear("线索传递数字列表" .. i) then return end
    if findOne("线索传递数字重复") then break end
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
      if not wait(function()
        if findOne("收集全部") then return true end
        tap("任务有列表" .. i)
      end, 5) then return end
      tap("收集全部")
      if not disappear("收集全部", 5) then return end
      if disappear("主页") then
        if not wait(function()
          if findOne("主页") then return true end
          tap("收集全部")
        end, 5) then return end
      end
    end
  end
end

path.信用购买 = function()
  path.跳转("采购中心")
  if not wait(function()
    if findOne("信用交易所") then return true end
    tap("信用交易所")
  end, 5) then return end
  if not appear("信用交易所") then return end
  if findOne("收取信用有") then
    local f = function()
      if not wait(function()
        if not findOne("信用交易所") then return true end
        if not findTap("收取信用有") then return true end
      end, 5) then return end
      if not wait(function()
        if findOne("信用交易所") then return true end
        tap("收取信用有")
      end, 5) then return end
    end
    f()
  end
  local enough = true
  for _ = 1, 20 do
    if not wait(function()
      if findOne("信用不足") then
        enough = false
        log("信用不足")
        return true
      end
      if findTap("购买物品") then return true end
      if findAny(point["信用交易所列表"]) and findOne("信用交易所") then
        findTap(point["信用交易所列表"])
        appear("购买物品")
      end
    end, 10) then return end
    if not enough then return end
  end
end

same_page_fight = function(pre, cur)
  if type(pre) ~= 'string' or type(cur) ~= 'string' then return end
  -- pattern before last - should be same
  if pre:gsub("(.*)-.*$", "%1") == cur:gsub("(.*)-.*$", "%1") then
    log("same page fight", pre, cur)
    return true
  end
  log("not same page fight", pre, cur)
end

tick = 0
path.轮次作战 = function()
  if #fight == 0 then return true end
  pre_fight = nil
  cur_fight = nil
  while not zero_san do
    tick = tick % #fight + 1
    cur_fight = fight[tick]
    if not same_page_fight(pre_fight, cur_fight) then path.跳转("首页") end
    path.作战(fight[tick])
  end
end

jianpin2name = {
  CMHB = "潮没海滨",
  LMSQ = "龙门市区",
  LMWH = "龙门外环",
  QENBG = "切尔诺伯格",
  BYBFFC = "北原冰封废城",
  DQSLJW = "大骑士领郊外",
  FQKQ = "废弃矿区",
}

path.作战 = function(x)
  local f = startsWithX(x)
  if table.any({"PR", "CE", "CA", "AP", "LS", "SK"}, f) then
    path.物资芯片(x)
  elseif f("OF-") then
    path.火蓝之心(x)
  elseif f("GT-") then
    path.骑兵与猎人(x)
  elseif f("DM-") then
    path.生于黑夜(x)
  elseif table.any(table.keys(jmfight2area), f) then
    path.剿灭(x)
  elseif f("WR-") then
    path.画中世界(x)
  elseif f("MN-") then
    path.临光(x)
  elseif f("TW-") then
    path.沃伦姆德的薄暮(x)
  elseif f("RI-") then
    path.密林(x)
  elseif f("MB-") then
    path.越狱(x)
  elseif f("OD-") then
    path.源石尘行动(x)
  elseif f("WD-") then
    path.遗尘漫步(x)
  elseif f("SV-") then
    path.覆潮之下(x)
  elseif f("PL-") then
    path.灯火序曲(x)
  elseif table.any({"TB-DB", "LK-DP", "FIN-TS"}, f) then
    path.联锁竞赛(x)
  else
    path.主线(x)
  end
end

path.开始游戏 = function(x)
  log("开始游戏", tick, x)
  pre_fight = x
  if x == "1-11" then return auto(path["1-11"]) end
  if not appear("演习券") then return end
  if not findOne("代理指挥开") then tap("代理指挥开") end
  if not appear("代理指挥开") then
    log("未检测到代理指挥开")
    return
  end
  tap("开始行动蓝")

  local state = appear({
    "开始行动红", "源石恢复理智取消", "药剂恢复理智取消",
  }, 5)
  if not x then return end

  if state == "开始行动红" then
    if debug0415 then
      log(x)
      return
    end
    tap("开始行动红")
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
  if not chapter then return end
  chapter = x0:sub(1, chapter - 1)
  chapter = chapter:sub(chapter:find("%d"))
  local chapter_index = tonumber(chapter) + 1

  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      appear("主页")
      tap("主题曲")
      appear("怒号光明")
      if chapter_index <= 4 then
        tap("觉醒")
      elseif chapter_index <= 9 then
        tap("幻灭")
      end
      swipq(chapter)
      tap("作战主线章节列表" .. chapter)
      tap("作战主线章节列表8")
    end,
    ["当前进度列表" .. chapter_index] = function()
      swipq(x0)
      local v = distance[x0]
      if type(v) == "table" then
        v = v[#v]
        -- ssleep(min(math.abs(v) / 500, 1))
      end
      if not appearTap("作战列表" .. x) then
        -- distance or point error
        log(x .. "未找到")
        bl[x] = false
        unfound_fight[x] = (unfound_fight[x] or 0) + 1
      end
      return true
    end,
  })
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
  auto(p)
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
    -- log(x, "未开启")
    return
  end
  -- get the index in 芯片搜索
  local cur_open = prls_open_time_r[cur_time]
  local index = table.find(cur_open, equalX(x1))
  if type == "pr" then
    index = index + 5
  else
    index = index + 5 - #cur_open
  end
  -- 面板=>开始游戏
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      appear("主页")
      tap("资源收集")
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
    end,
    ["作战列表" .. x] = function()
      tap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
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
path.剿灭 = function(x)
  if jwfight_enough then return end
  path.跳转("首页")
  -- TODO jwf
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      tap("每周部署")
      tap("进入地图")
      swipq(jmfight2area[x])
      findTap(jmfight2area[x])
      ssleep(2)
    end,
    ["作战列表" .. x] = function()
      if not debug0415 and
        not table.any(point["报酬合成玉未满列表"], find) then
        jwf.full = true
        log("本周合成玉已满")
      end
      findTap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  if jwf.full then return end

  path.开始游戏(x)
end

path.访问好友 = function()
  if communication_enough then return end
  path.跳转("好友")
  log(1019)
  if not wait(function()
    if findOne("好友列表") then return true end
    tap('好友列表')
  end, 5) then return end

  if not appearTap('访问基建', 5) then return end
  while appear("访问下位橘", 10) do
    if findOne("今日参与交流已达上限") then
      communication_enough = true
      break
    end
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
  path.跳转("公开招募")
  local f, g

  f = function(i)
    log(1044, i)
    if findOne("公开招募确认蓝") then tap("返回") end
    local see =
      appear({"聘用候选人列表" .. i, "公开招募列表" .. i})
    if see == "聘用候选人列表" .. i then
      log(i, 1001)
      if not wait(function()
        if not findOne("公开招募") then return true end
        if findTap("聘用候选人列表" .. i) then
          log(1052)
          disappear("公开招募", 1)
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
      if not wait(function()
        if findOne("公开招募确认蓝") then return true end
        if findTap("公开招募列表" .. i) then
          log(1068)
          appear("公开招募确认蓝", 1)
        end
      end, 5) then return end
      g = function(disable_refresh_check)
        local empty_tags = true
        local tags = {}
        local ocr_text
        local max_star = 4
        local prev_tags = nil

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
        --        if next(tags) == nil then return end
        if empty_tags then return end

        log(1092, tags)
        -- TODO check 刷新后
        if not disable_refresh_check and prev_tags and
          table.contains(table.keys(tags), table.keys(prev_tags)) then
          log("==> enable refresh check")
          log(table.keys(tags), table.keys(prev_tags))
          return g(true)
        end

        local tag4 = table.filter(tag5, function(rule)
          return table.all(rule[1], function(r) return tags[r] end)
        end)
        log(1093, tag4)

        if #tag4 == 0 then
          if findTap("公开招募标签刷新蓝") then
            if not disappear("公开招募") then return end
            if not wait(function()
              if findOne("公开招募") then return true end
              tap("消耗一次联络机会确认")
              appear("公开招募", 1)
            end, 5) then return end
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
            if not debug0416 then
              log(1131)
              tap("公开招募确认蓝")
            else
              tap("返回")
            end
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

path.密林 = function(x)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      ssleep(1)
      tap("作战密林悍将归来")
      ssleep(3)
      tap("密林大酋长之路")
    end,
    大酋长之路 = function()
      swipq(x)
      ssleep(1)
      if not findTap("作战列表" .. x) then
        log(x .. "未找到")
        bl[x] = false
        unfound_fight[x] = (unfound_fight[x] or 0) + 1
      end
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

path.临光 = function(x)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战活动上")
      tap("大竞技场")
      ssleep(1)
    end,
    梅什科竞技证券 = function() swipq(x) end,
    ["作战列表" .. x] = function()
      findTap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

path.画中世界 = function(x)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战活动上")
      ssleep(1)
      tap("入画")
      ssleep(1)
      swipq(x)
      if not findTap("作战列表" .. x) then
        log(x .. "未找到")
        unfound_fight[x] = (unfound_fight[x] or 0) + 1
      end
      return true
    end,
    ["作战列表" .. x] = function()
      findTap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

path.源石尘行动 = function(x)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战活动下")
      ssleep(2)
      tap("行动记录")
      ssleep(1)
      swipq(x)
      ssleep(1)
      if not findTap("作战列表" .. x) then
        log(x .. "未找到")
        unfound_fight[x] = (unfound_fight[x] or 0) + 1
      end
      return true
    end,
    ["作战列表" .. x] = function()
      findTap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

path.灯火序曲 = function(x)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战活动")
      ssleep(2)
      tap("路线安排")
      ssleep(1)
      swipq(x)
      ssleep(1)
      if not findTap("作战列表" .. x) then
        log(x .. "未找到")
        unfound_fight[x] = (unfound_fight[x] or 0) + 1
      end
      return true
    end,
    ["作战列表" .. x] = function()
      findTap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

path.联锁竞赛 = function(x)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战活动")
      tap("始发营地")
      ssleep(1)
    end,
    ["作战列表" .. "TB-DB-3"] = function()
      tap("作战列表" .. x)
      -- if findOne("联锁竞赛代理指挥关") then
      --   tap("联锁竞赛代理指挥")
      -- end
      tap("开始行动蓝")
      ssleep(1)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end
