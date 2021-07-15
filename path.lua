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
  start黄框 = function()
    tap("start黄框")
    ssleep()
    tap("start黄框")
  end,
  start黄框暗 = function()
    tap("start黄框暗")
    ssleep()
    tap("start黄框暗")
  end,
  客户端过时 = function() stop("客户端过时") end,
  限时活动返回 = function()
    local t = "限时活动列表"
    for i = 1, #point[t] do
      log(t .. i)
      tap(t .. i)
    end
    tap('限时活动返回')
  end,
  账号登录 = "账号登录",
  开始唤醒 = "开始唤醒",
  正在加载网络配置 = function()
    if not disappear("正在加载网络配置", 30) then
      stop("正在加载网络配置")
    end
  end,
  登录 = function()
    local inputbox = R():type("EditText"):name("com.hypergryph.arknights"):path(
                       "/FrameLayout/EditText")
    if #username then
      tap("账号左侧")
      tap("账号")
      appear(inputbox)
      input(inputbox, username)
      tap("右下角确认", 0, true)
      disappear(inputbox)
      appear("登录")
    end
    if #password then
      tap("账号左侧")
      tap("密码")
      appear(inputbox)
      input(inputbox, password)
      tap("右下角确认", 0, true)
      disappear(inputbox)
      appear("登录")
    end
    tap("登录")
    if appear({"用户名或密码错误", "密码不能为空"}) then
      stop("登录失败")
    end
    appear("面板")
    -- reset state
    already_update_station_list = false
    no_friend = false
  end,
  -- 维护
  登入错误 = restart,
  我知道了 = restart,
  网络异常稍后重试 = restart,
  -- 断网
  获取网络配置失败 = function()
    tap("获取网络配置失败")
    return true
  end,
  撤下干员确认 = "撤下干员确认",
  其它 = "返回",
  离开基建确认 = "离开基建确认",
  返回自己基建确认 = "返回自己基建确认",
  返回好友列表确认 = "返回好友列表确认",
  理智兑换取消 = function()
    running = "理智不足"
    tap("理智兑换取消")
    return true
  end,
  源石理智兑换次数上限 = function()
    running = "理智不足"
    tap("理智兑换取消")
    return true
  end,
  源石不足 = function()
    running = "理智不足"
    tap('返回')
    return true
  end,
  药剂恢复理智取消 = function()
    running = "理智不足"
    tap("药剂恢复理智取消")
    return true
  end,
  源石恢复理智取消 = function()
    running = "理智不足"
    tap("药剂恢复理智取消")
    return true
  end,
  代理失误放弃行动 = "代理失误放弃行动",
  战斗记录未能同步返回 = function()
    local i = 0
    while i < 5 do
      log("战斗记录同步重试")
      tap("右确认")
      if disappear("战斗记录未能同步返回", 5, 1) then
        stop("战斗记录未能同步")
      end
    end
  end,
  正在释放神经递质 = function()
    disappear("正在释放神经递质", 60 * 60, 1)
  end,
  接管作战 = function()
    if not disappear("接管作战", 60 * 60, 1) then stop("接管作战") end
  end,
  未能同步到相关战斗记录 = function()
    stop("未能同步到相关战斗记录")
  end,
}

path.移动停止按钮 = function()
  menuConfig({
    x = 0, -- x坐标
    y = screen.height / 2 - 50, -- y坐标
  })
  -- config = {
  --  x = width/2-1000/2, -- 位置x
  --  y = -36, -- 位置y
  --  width = 1000, -- 宽度
  --  height = 36, -- 高度
  --  color = "#37474F",
  --  bgcolor = "#FFFFFF",
  --  mode = 2, -- 模式 :1= 显示可点击,2=显示不可点击，3=隐藏
  --  size = 11, -- 字体大小
  --  debug = true, -- 是否输出系统日志 false =不输出，true = 输出
  --  shadow = false, -- 是否显示阴影，false：不显示 true 显示；
  -- };
  -- logConfig(config);
end
comm_enough = false
update_comm = function() comm_enough = false end
update_station_list = function()
  if already_update_station_list then return end
  local a = point.基建标识
  local b = a.base
  local l = {"宿舍", "制造站", "贸易站", "发电站"}
  local r = {"会客厅", "控制中枢", "加工站", "办公室", "训练室"}
  -- ax[1]ll department
  la = {}
  -- flatten
  for k, v in pairs(l) do
    v = v .. '列表'
    if point[v] == nil then
      local a = opt.building
      local tx = {"贸易站", "发电站", "制造站"}
      local ix = {1, 1, 1}
      for i = 1, #tx do point[tx[i] .. "列表"] = {} end
      for i = 1, math.ceil(#a / 3) do
        local b = a:sub(3 * i - 2, 3 * i)
        local j = table.find(tx, function(x) return x:startsWith(b) end)
        if j then
          local k1 = tx[j] .. "列表"
          local k2 = k1 .. ix[j]
          insert(point[k1], k2)
          point[k2] = point.基建左侧[i]
          tap_extra_delay[k2] = tap_extra_delay[k1]
          ix[j] = ix[j] + 1
        end
      end
    end
    for i = 1, #point[v] do insert(la, v .. i) end
  end
  table.extend(la, r)
  already_update_station_list = true
end

path.跳转 = function(x)
  local sign = {
    好友 = "个人名片",
    基建 = "进驻总览",
    公开招募 = "公开招募",
    首页 = "面板",
    采购中心 = "可露希尔推荐",
    任务 = "日常任务",
    终端 = "主页",
  }
  local plain = {
    好友 = "面板好友",
    基建 = "面板基建",
    公开招募 = "面板基建",
    首页 = nil,
    采购中心 = "面板采购中心 ",
    任务 = "面板任务",
    终端 = "面板作战",
  }
  local target = sign[x]
  local f = true
  local p = update(path.base, {
    面板 = function()
      tap(plain[x])
      if not appear(target, 5) then f = false end
      return true
    end,
    主页 = function()
      tap("主页")
      if not appear("主页列表任务") then
        f = false
        return true
      end
      tap("主页列表" .. x)
      if not appear(target, 5) then f = false end
      return true
    end,
    target = true,
  })
  auto(p)
  return f
end

path.更新设备列表 = update_station_list
path.更新参与交流次数 = update_comm
path.每日更新 = function()
  update_station_list()
  update_comm()
  update_open_time()
end
path.限时活动 = update(path.base, {
  -- TODO
  面板 = function()
    if not findTap('面板限时活动') then return true end
    local t = "限时活动列表"
    for i = 1, #point[t] do
      log(t .. i)
      tap(t .. i)
    end
    tap('限时活动返回')
    auto(path.base)
  end,
})

path.基建点击全部 = function()
  if not path.跳转("面板基建") then return end
  -- TODO

  ssleep(3)
  if not appearTap('基建灯泡蓝', 5, 1) then
    log("未找到灯泡")
    return
  end
  i = 1
  while i <= 10 and appearTap("点击全部收取", 3, 1) do
    ssleep(2)
    i = i + 1
  end
  tap("宿舍列表1")
  tap("宿舍列表1")
  -- auto(path.base)
end

-- 换信赖最低的5人
path.基建副手换人 = function()
  -- TODO
  update_station_list()
  local p = update(path.base, {
    面板 = '面板基建',
    进驻总览 = "控制中枢",
    进驻信息3选中 = "进驻信息3选中",
    控制中枢界面 = "控制中枢基建副手",
    基建副手简报 = true,
  })
  for k, v in pairs(point.基建副手列表) do
    auto(p)
    tap(v)
    if not findOne("干员选择无选中") then tap("干员选择列表1") end
    tap("排序信赖")
    tap("排序信赖")
    tap("干员选择列表" .. k)
    tap("干员选择确认")
    ssleep(1)
  end
end
count_people = function()
  local capacity = 5
  local current = 5
  local max_retry = 3
  local retry = 0
  while retry < max_retry do
    retry = retry + 1
    for i = 1, 5 do
      if not findOne("进驻人数列表" .. i) then
        capacity = i - 1
        break
      end
      -- if not findOne("进驻人数满列表" .. i) then current = i - 1 end
    end
    for i = 1, 5 do
      -- if not findOne("进驻人数列表" .. i) then capacity = i - 1 end
      if not findOne("进驻人数满列表" .. i) then
        current = i - 1
        break
      end
    end
    -- log(current, '/', capacity)
    if current <= capacity then return {current, capacity} end
    ssleep(2)
  end
  return {0, 5}
end
path.换人 = function()
  -- TODO
  update_station_list()
  auto(update(path.base, {面板 = '面板基建', 进驻总览 = true}))
  already_after_dormitory = false
  local p, f, a, b, current, capacity
  for index, v in pairs(la) do
    -- ignore the last one(训练室)
    if v == "训练室" then break end
    p = update(path.base, {
      面板 = "面板基建",
      进驻总览 = v,
      进驻信息2 = "进驻信息2",
      进驻信息3 = "进驻信息3",
      进驻信息4 = "进驻信息4",
      有人清空 = function()
        -- 人满不清
        if index > #point.宿舍列表 then
          current = count_people()
          current, capacity = current[1], current[2]
          if current == capacity then return true end
        end
        tap("有人清空")
      end,
      清空完毕进驻 = function()
        b = count_people()[2]
        tap("清空完毕进驻")
        if not appear("干员选择确认", 3, 1) then return end
        -- toggle tag after 宿舍
        if index > #point.宿舍列表 and not already_after_dormitory then
          tap("排序筛选按钮")
          ssleep(1)
          findTap("排序筛选未进驻未选中")
          ssleep(1)
          tap("排序筛选确认")
          ssleep(1)
          already_after_dormitory = true
        end
        local dorm_index = #point.宿舍列表 - index + 1
        swipq('dorm' .. dorm_index)
        a = 1
        if dorm_index > 0 and dorm_index % 2 == 0 then a = 2 end
        for i = a, a + b - 1 do tap("干员选择列表" .. i) end
        tap("干员选择确认")
        appearTap("排班调整确认", 1, 0.5)
        return true
      end,
    })
    auto(p)
    auto(update(path.base, {面板 = "面板基建", 进驻总览 = true}))
  end
end

path.制造站加速 = function()
  -- TODO
  update_station_list()
  if #point.制造站列表 == 0 then return end
  auto(update(path.base, {
    进驻总览 = "制造站列表1",
    面板 = "面板基建",
    制造站进度 = "制造站进度",
    -- 制造站设施 = ,
    进驻信息2选中 = "进驻信息2选中",
    -- 无人机加速制造
    制造站设施 = function()
      tap("制造站加速")
      ssleep(1)
      tap("无人机加速最大")
      tap("无人机加速制造确定")
      ssleep(2)
      tap("制造站收取")
      return true
    end,
  }))
end

path.取消进驻信息选中 = update(path.base, {
  面板 = "面板基建",
  进驻总览 = 会客厅,
  进驻信息2 = true,
  进驻信息2选中 = "进驻信息2选中",
  进驻信息3 = true,
  进驻信息3选中 = "进驻信息3选中",
  进驻信息4 = true,
  进驻信息4选中 = "进驻信息4选中",
})

path.线索接收 = function()
  -- TODO
  update_station_list()
  if not point.会客厅 then return end
  local new = false
  auto(update(path.base, {
    会客厅线索搜集中 = "会客厅线索搜集中",
    线索全部收取有 = function()
      tap("线索全部收取有")
      new = true
    end,
    线索全部收取无 = function()
      tap("解锁线索右")
      return true
    end,
    会客厅信用奖励 = "会客厅线索接收",
    进驻总览 = "会客厅",
    面板 = "面板基建",
    进驻信息3选中 = "进驻信息3选中",
  }))
  if new then auto(path.线索布置) end
end

path.线索布置 = function()
  -- TODO
  update_station_list()
  if not point.会客厅 then return end
  auto(update(path.base, {
    进驻信息3 = "线索",
    会客厅信用奖励 = function()
      local v = table.findv(point.线索布置列表, find)
      if not v then return true end
      -- offset -50,50
      v = point[v]
      local x = v:find(coord_delimeter)
      local y = v:sub(x + 1, v:find(coord_delimeter, x + 1) - 1)
      x = tonumber(v:sub(1, x - 1))
      y = tonumber(y)
      tap({x - 50, y + 50})
      ssleep(.5)
      tap("线索库列表1")
      tap("解锁线索右")
      ssleep(.5)
    end,
    进驻总览 = "会客厅",
    面板 = "面板基建",
    进驻信息3选中 = "进驻信息3选中",
  }))
  if findTap("解锁线索") then
    ssleep(2)
    auto(path.线索布置)
  end
end

path.线索传递 = update(path.base, {
  -- TODO
  面板 = "面板基建",
  进驻总览 = "会客厅",
  进驻信息3 = "线索",
  会客厅信用奖励 = "会客厅线索传递",
  线索传递返回 = function()
    local a = point.线索传递数字列表
    for k, v in pairs(a) do
      tap(v)
      ssleep(.5)
      if findOne("线索传递数字重复") or k == #a then
        tap("线索列表1")
        break
      end
    end
    a = point.传递列表
    local count = 0
    local ranges = {100, 300, 500, 700, 900}
    local f = function(random)
      local points = findAll("线索传递橙框")
      local t
      if points then
        for p in pairs(points) do
          p = points[p].y
          for i = 1, 4 do
            if ranges[i] < p and p < ranges[i + 1] and
              findOne("今日登录列表" .. i) then
              t = a[i]
              log('给' .. i)
              break
            end
          end
          if t then break end
        end
      elseif random then
        for i = 1, math.random(0, count) do findTap("线索传递左白") end
        t = a[math.random(#a)]
        log('给随机')
      end
      if t then
        tap(t)
        return true
      end
    end
    while count < 50 / 4 do
      -- 翻到末尾就随机给
      if not appear("线索传递右白", 2, 1) and
        not findOne("线索传递右白2") then
        f(true)
        return true
      end
      -- 当前页看看有没有缺的
      if f() then return true end
      tap("线索传递右白")
      count = count + 1
    end
  end,
})

path.信用奖励 = function()
  -- TODO
  update_station_list()
  if not point.会客厅 then return end
  no_friend = false
  auto(update(path.base, {
    信用奖励有 = function()
      if findOne("已达线索上限") then
        if no_friend then return true end
        auto(path.线索传递)
      end
      tap("信用奖励有")
      auto(path.线索布置)
    end,
    会客厅信用奖励 = "会客厅信用奖励",
    进驻信息3 = "线索",
    进驻总览 = "会客厅",
    信用奖励无 = function()
      if not findOne("已达线索上限") then return true end
      if no_friend then return true end
      auto(path.线索传递)
    end,
    面板 = "面板基建",
    进驻信息3选中 = "进驻信息3选中",
  }))
  auto(path.线索布置)
end

path.任务 = function()
  -- if not path.跳转("任务") then return end
  -- TODO
  local l = {"日常任务", "周常任务"}
  for _, i in pairs(l) do
    local p = update(path.base, {
      面板 = "面板任务",
      见习任务 = i,
      日常任务 = i,
      活动任务 = i,
      周常任务 = i,
    })
    p[i] = function()
      tap('任务蓝')
      -- if table.any({'报酬已领取','任务黑', "任务灰", "任务灰2"}, find) then
      return true
      -- end
    end
    p['活动任务'] = p["日常任务"]
    auto(p)
  end
end

path.信用购买 = function()
  -- if not path.跳转("采购中心") then return end
  -- TODO
  auto(update(path.base, {
    面板 = "面板采购中心",
    可露希尔推荐 = "信用交易所",
    信用交易所 = function()
      if not findTap(table.unpack(point.信用交易所列表)) then
        return true
      end
      if not findTap("购买物品") then return end
      if findOne("信用不足") then
        log("信用不足")
        return true
      else
        tap("返回")
        -- ssleep(1)
      end
    end,
  }))
  return true
end

path.信用收取 = function()
  local p = update(path.base, {
    面板 = "面板采购中心",
    可露希尔推荐 = "信用交易所",
    收取信用 = "收取信用",
    收取信用无 = true,
    其他 = function()
      path.跳转("采购中心")
      p.其他 = path.base.其他
    end,
  })
  auto(p)
end

path.邮件 = function()
  local p = update(path.base, {
    面板 = function()
      if not findOne("面板邮件有") then return true end
      tap("面板邮件")
      appear("邮件")
    end,
    邮件 = function()
      tap("收取所有邮件")
      return true
    end,
    其他 = function()
      path.跳转("首页")
      p.其他 = path.base.其他
    end,
  })
  auto(p)
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
  while running ~= "理智不足" do
    set("tick", tick)
    tick = tick % #fight + 1
    cur_fight = fight[tick]
    if not same_page_fight(pre_fight, cur_fight) then path.跳转("首页") end
    path.作战(fight[tick])
    pre_fight = fight[tick]
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
  log(tick, ' ', x)
  if x == "1-11" then return auto(path["1-11"]) end
  return auto(update(path.base, {
    面板 = true,
    演习券 = function()
      if not findOne("代理指挥开") then tap("代理指挥开") end
      if not appear("代理指挥开") then
        log("未检测到代理指挥开")
        return true
      end
      tap("开始行动蓝")
      appear({
        "开始行动红", "源石恢复理智取消",
        "药剂恢复理智取消",
      }, 5)
    end,
    开始行动红 = function()
      if debug0415 then
        log(x)
        if true then return true end
      end
      tap("开始行动红")
    end,
    接管作战 = function()
      if disappear("接管作战", 60 * 60, 1) and
        not findOne("代理失误放弃行动") and
        not appear("战斗记录未能同步返回", 2, 1) then
        log('代理成功', x)
        cl[x] = (cl[x] or 0) + 1
      else
        log('代理失误', x)
        bl[x] = false
        failed_fight[x] = (failed_fight[x] or 0) + 1
      end
      return true
    end,
  }))
end

path.主线 = function(x)
  -- split s2-9 to 2 and 9
  local x0 = x
  local x1 = x0:find("-")
  local x2
  if not x1 then return end
  x1, x2 = x0:sub(1, x1 - 1), x0:sub(x1 + 1)
  x1 = x1:sub(x1:find("%d"))
  local x3 = tonumber(x1) + 1
  local p = update(path.base, {
    终端 = function()
      tap("主题曲")
      appear("怒号光明")
      if x3 <= 4 then
        tap("觉醒")
      elseif x3 <= 9 then
        tap("幻灭")
      end
      swipq(x1)
      tap("作战主线章节列表" .. x1)
      tap("作战主线章节列表8")
    end,
    面板 = function()
      tap("面板作战")
      appear("主页")
      tap("主题曲")
      appear("怒号光明")
      if x3 <= 4 then
        tap("觉醒")
      elseif x3 <= 9 then
        tap("幻灭")
      end
      swipq(x1)
      tap("作战主线章节列表" .. x1)
      tap("作战主线章节列表8")
    end,
    ["当前进度列表" .. x3] = function()
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
  p["按下当前进度列表" .. x3] = p["当前进度列表" .. x3]
  if x3 <= 4 then -- chapter 0 to 3
    switch_start = 1
    switch_end = 4
  elseif x3 <= 9 then -- chapter 4 to 8
    switch_start = 5
    switch_end = 9
  else
    switch_start = 10
    switch_end = 10 - 1
  end
  for i = switch_start, switch_end do
    if x3 ~= i then
      p["当前进度列表" .. i] = "当前进度列表" ..
                                       (i > x3 and "左" or "右")
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
      insert(lotr[k], "CE")
    end
    table.remove(lotr[k], table.find(lotr[k], equalX("LS")))
    insert(lotr[k], "LS")
  end
  local t = os.time()
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
path.更新开启时间 = update_open_time

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
      log(index, point["资源收集列表" .. index])
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
    end,
    ["作战列表" .. x] = function()
      tap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

jwf = {full = false, week = nil}
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
  -- 周一4点
  local start_week_time = os.time({
    year = 2019,
    month = 6,
    day = 17,
    hour = 4,
    min = 0,
    sec = 0,
  })
  local cur_week = math.ceil((os.time() - start_week_time) / (7 * 24 * 3600))
  if jwf.week ~= cur_week then jwf = {full = false, week = cur_week} end
  if jwf.full then return end
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

path.访问好友基建 = function()
  if comm_enough then return end
  local loop_end = false
  auto(update(path.base, {
    面板 = '面板好友',
    个人名片 = '好友列表',
    好友列表 = function()
      if not appearTap('访问基建', 3, 1) then return true end
      while 1 do
        if not wait(function()
          if find("今日参与交流已达上限") then
            comm_enough = true
            return true
          end
          if find("访问下位无") then
            loop_end = true
            return true
          end
          return findTap("访问下位橘", "访问下位")
        end, 10, 2) or comm_enough or loop_end then return true end
      end
    end,
  }))
end

-- show station list
showSL = function(not_show)
  local a = ''
  local l = {"宿舍", "制造站", "贸易站", "发电站"}
  local r = {"会客厅", "控制中枢", "加工站", "办公室", "训练室"}
  for k, v in pairs(l) do
    if point[v .. '列表'] then
      a = a .. v .. 'x' .. #point[v .. '列表'] .. ' '
    end
  end
  for k, v in pairs(r) do if point[v] then a = a .. v .. 'x1 ' end end
  if not_show then return a end
  show(a, 500)
end

-- show failed fight
showBL = function(not_show)
  local a = ''
  local b = ''
  for k, v in pairs(failed_fight) do
    if not v then b = b .. k .. "x" .. v .. " " end
  end
  if #b > 0 then a = a .. '失败：' .. b end
  if not_show then return a end
  show(a, 500)
end

-- show success fight
showCL = function(not_show)
  local a = ''
  for k, v in pairs(cl) do if v > 0 then a = a .. k .. "x" .. v .. ' ' end end
  if #a > 0 then a = '已完成：' .. a end
  if not_show then return a end
  show(a, 500)
end

-- show all info
showALL = function()
  -- show(showSL(true) .. '\n' .. showBL(true) .. '\n' .. showCL(true), 500)
  show(taglog .. showBL(true), 36)

end
path.关闭 = close
path.显示全部 = showALL
-- path.后台 = background
path.后台 = function()
  -- auto(update(path.base, {
  --   面板 = function() pressKey('BACK', false) end,

  --   退出游戏 = function()
  --     -- tap("右确认")
  --     -- wait(nil, function() return isFrontApp(appid) == 0 end)
  --     -- log("已退出")
  --     return true
  --   end,
  -- }))
  -- lua_exit()
  -- auto(path.base)
  -- if true then return true end

  -- close()
  -- set("restart", "true")

  -- lua_restart()
  -- if true then return true end

  -- TODO
  -- ssleep(60)
  -- log("debug-2")
  -- auto(update(path.base, {
  --   面板 = function()
  --     tap("面板公告")
  --     return true
  --   end,
  -- }))
  -- tap("返回")
  -- set("restart", "true")
  -- close()
  -- lua_restart()
  -- close()
  -- ssleep(10)
  background()

  -- log('gc count ', collectgarbage("count"))
  -- print(collectgarbage("count") * 1024)
  -- collectgarbage()

  -- ssleep(1800)
  -- log("debug-1")
  -- if true then return true end

  -- ssleep(60)
  -- close()
  -- set("restart", true)
  -- lua_restart()
  -- log("debug0")

  -- runApp("com.xxscript.idehelper")
  -- log("debug1")

  -- ssleep(60)
  -- log("debug2")

  -- -- background()
  -- log("debug3")
  -- runApp("com.android.settings")

  -- if isFrontApp(appid) == 0 then return end
  -- auto(update(path.base, {
  --   面板 = function() pressKey('BACK', false) end,
  --   退出游戏 = function()
  --     tap("右确认")
  --     wait(nil, function() return isFrontApp(appid) == 0 end)
  --     log("已退出")
  --     return true
  --   end,
  -- }))
end
-- path.后台 = path.后台

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

path.公开招募聘用 = update(path.base, {
  面板 = function()
    if not findTap("面板公开招募有") then return true end
  end,
  公开招募 = function()
    if findTap(table.unpack(point["聘用候选人列表"])) then
      findTap("开包skip")
    end
    tap("返回")
  end,
})

taglog = ''
path.公开招募刷新 = function()
  taglog = ''
  auto(update(path.base, {面板 = "面板公开招募", 公开招募 = true}))
  -- if find("公开招募联络次数0") then return end
  local a, tt, t, flag
  local total_max_star = 4
  for i = 1, #point.公开招募列表 do
    auto(update(path.base, {面板 = "面板公开招募", 公开招募 = true}))
    auto(update(path.base, {
      面板 = "面板公开招募",
      公开招募 = function()
        -- if find("公开招募联络次数0") then return true end
        if not appearTap('公开招募列表' .. i, 2, 1) then
          return true
        end
      end,
      公开招募确认 = function()
        local flag
        local a = {}
        local b = {}
        local mr = 10 -- max retries for one tag
        for k, v in pairs(point.公开招募标签框列表) do
          v = point[v]
          t = ""
          r = 0
          while not table.includes(tag, t) and r < mr do
            ssleep(0.1 * r)
            r = r + 1
            t = binarizeImage({
              rect = v,
              diff = {"0xffffff-0x989898"}, -- background<=0x66
            })
            t = ocr(t)
          end
          if not table.includes(tag, t) then
            tt = 'invalid tag: ' .. table.concat(a, ',') .. ',' .. tostring(t)
            log(tt)
            taglog = taglog .. tt .. '\n'
            return true
          end
          insert(a, t)
        end
        tt = table.concat(a, ',')
        log(tt)
        -- discover at least 4 stars tags
        t = {}
        for k, v in pairs(tagk) do
          flag = true
          for k1, v1 in pairs(v) do
            if not table.includes(a, v1) then
              flag = false
              break
            end
          end
          if flag then insert(t, k) end
        end

        if #t ~= 0 then
          -- 判断保底是否只有4星
          local max_star = 4
          for k, v in pairs(t) do
            -- tt = table.concat(tagk[v], ',') .. ' ' .. tagl[v] .. '★'
            if tagl[v] > 4 then
              max_star = max(max_star, tagl[v])
              total_max_star = max(total_max_star, tagl[v])
              taglog = total_max_star .. '★'
              -- taglog = taglog .. tt .. '\n'
            end
          end
          -- 9小时招募
          if max_star == 4 and star4_auto then
            tt = tagk[t[1]]
            for k, v in pairs(tt) do
              p = table.find(a, function(x) return x == v end)
              tap("公开招募标签列表" .. p)
            end
            -- for i = 1, 8 do tap("公开招募时间加") end
            tap("公开招募时间减")
            if not debug0416 then tap("公开招募确认") end
          end
        else
          if findTap("公开招募标签刷新蓝") then
            tap("消耗一次联络机会确认")
            return false
          end
        end
        return true
      end,
    }))
  end
end

path["作战1-11"] = function() for i = 1, 14 do path.作战("1-11") end end

path.越狱 = function(x)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战活动")
      ssleep(2)
      tap("越狱计划")
      ssleep(3)
    end,
    ["作战列表" .. x] = function()
      findTap("作战列表" .. x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

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

path.生于黑夜 = function(x, hook)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      tap("插曲")
      if hook ~= nil then
        hook()
      else
        tap("生于黑夜")
      end
      tap("进入活动")
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

path.骑兵与猎人 = function(x, hook)
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      tap("别传")
      if hook ~= nil then
        hook()
      else
        tap("骑兵与猎人")
        tap("进入活动")
      end
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

path.火蓝之心 = function(x)
  path.骑兵与猎人(x, function()
    tap("别传")
    tap("火蓝之心")
    tap("进入活动")
    tap("火蓝之心地区2")
  end)
end

path.沃伦姆德的薄暮 = function(x)
  path.骑兵与猎人(x, function()
    tap("别传")
    tap("沃伦姆德的薄暮")
    tap("进入活动")
    ssleep(1)
    swipq(x)
  end)
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

path.遗尘漫步 = function(x)
  path.生于黑夜(x, function() tap("遗尘漫步") end)
end

path.覆潮之下 = function(x)
  path.生于黑夜(x, function() tap("覆潮之下") end)
end

-- error = function()
--  if findOne("返回x") then
--    log("限时活动")
--    local retry = 0, t
--    local retry_m = 3
--    while findOne("返回x") and retry < retry_m do
--      dis = "限时活动列表"
--      for i = 1, #point[dis] do tap(dis .. i) end
--      dis = "限时活动横列表"
--      for i = 1, #point[dis] do tap(dis .. i) end
--      if findTap('返回x') then break end
--      retry = retry + 1
--    end
--    if retry_m == retry then stop("限时活动执行失败") end
--  else
--    stop("未知状态")
--  end
-- end

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
