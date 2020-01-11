require("util")
require("point")

-- set bl true
bl = {}
for k, v in pairs(fight_type_all) do bl[v] = true end
cl = {}
for k, v in pairs(fight_type_all) do cl[v] = 0 end

path = {}

path.base = {
  客户端过时 = function() stop() end,
  限时活动返回 = function()
    local t = "限时活动列表"
    for i = 1, #point[t] do
      log(t .. i)
      tap(t .. i)
    end
    tap('限时活动返回')
  end,
  面板 = true,
  start黄框 = "删除缓存返回",
  进入游戏 = "进入游戏",
  账号登陆 = "账号登陆",
  登陆 = function()
    local u = "..."
    local p = "..."
    if u then input("账号", u) end
    input("密码", p)
    tap("登陆")
    -- reset state
    already_update_station_list = false
    no_friend = false
  end,
  -- 维护
  登入错误 = restart,
  我知道了 = function()
    background()
    return true
  end,
  -- restart,
  密码错误 = stop,
  网络异常稍后重试 = function()
    -- tap("确认")
    close()
    -- sleep(600)
  end,
  -- 断网
  获取网络配置失败 = function()
    tap("获取网络配置失败")
    return true
  end,
  删除缓存返回 = "删除缓存返回",
  登陆认证失效 = "登陆认证失效",
  今日配给 = "今日配给",
  签到返回 = "签到返回",
  活动公告返回 = "活动公告返回",
  系统公告返回 = "系统公告返回",
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
  新手任务 = "右返回",
  代理失误放弃行动 = "代理失误放弃行动",
  提示关闭 = 提示关闭,
  战斗记录未能同步重试 = "左返回",
  正在释放神经递质 = "正在释放神经递质",
  线索传递返回 = "线索传递返回",
  无人机加速确定 = "无人机加速确定",
  无人机加速获取订单确定 = "无人机加速获取订单确定",
}

path.移动停止按钮 = function()
  if getScreenDirection() == 0 then
    background()
    sleep(5)
  end
  local t = "停止按钮"
  if not appear(t, 10) then log(t .. "未找到,忽略") end
  t = find(t)
  swip(t[1], t[2], 1920 - t[1], 1080 / 2 - t[2], .2)
  return true
end
comm_enough = false
update_comm = function() comm_enough = false end
update_station_list = function()
  if already_update_station_list then return end
  -- auto(update(path.base, {面板 = "面板基建", 进驻总览 = true}))
  local a = point.基建标识
  local b = a.base
  local l = {"宿舍", "制造站", "贸易站", "发电站"}
  local r = {"会客厅", "控制中枢", "加工站", "办公室", "训练室"}
  -- unstable: adaptive
  -- keepScreen(true)
  -- for k, v in pairs(l) do
  --   local t = table.filter((v == "宿舍" and a.中间设施 or a.左侧设施),
  --                          function(x)
  --     return find(x[1] .. '|' .. x[2] .. '|' .. a[v] .. ',' .. b)
  --   end)
  --   if #t > 0 then point[v .. '列表'] = t end
  -- end
  -- for k, v in pairs(r) do
  --   local t = find(a[v] .. ',' .. b)
  --   if t then point[v] = t end
  -- end
  -- keepScreen(false)

  -- all department
  la = {}
  -- flatten
  for k, v in pairs(l) do
    v = v .. '列表'
    for i = 1, #point[v] do
      -- point[v .. i] = point[v][i]
      insert(la, v .. i)
    end
  end
  table.extend(la, r)
  already_update_station_list = true
end
path.更新设备列表 = update_station_list
path.更新参与交流次数 = update_comm
path.每日更新 = function()
  update_station_list()
  update_comm()
end
path.限时活动 = update(path.base, {
  面板 = function()
    if not findTap('面板限时活动') then return true end
    auto(path.base)
  end,
})

path.基建点击全部 = function()
  auto(update(path.base, {面板 = '面板基建', 进驻总览 = true}))
  if not appear('基建灯泡蓝', 10, 1) then return end
  tap("基建灯泡蓝")
  if findTap('点击全部收获') then sleep(6) end
  if findTap('点击全部收取') then log('基建信赖') end
  auto(path.base)
end
-- 换信赖最低的5人
path.基建副手换人 = function()
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
    if not find("干员选择无选中") then tap("干员选择列表1") end
    tap("排序信赖")
    tap("排序信赖")
    tap("干员选择列表1")
    tap("干员选择确认")
    tap("返回")
    sleep(.5)
  end
end
path.换人 = function()
  update_station_list()
  auto(update(path.base, {面板 = '面板基建', 进驻总览 = true}))
  local a, b, p
  already_after_dormitory = false
  for index, v in pairs(la) do
    -- ignore the last one(训练室)
    if v == "训练室" then break end
    p = update(path.base, {
      干员选择确认 = true,
      面板 = "面板基建",
      进驻总览 = v,
      进驻信息2 = "进驻信息2",
      进驻信息3 = "进驻信息3",
      进驻信息4 = "进驻信息4",
      有人清空 = function()
        -- 人满不清
        if index > #point.宿舍列表 and
          table.any(point.进驻人数满, find) then return true end
        tap("有人清空")
      end,
      清空完毕进驻 = function()
        -- check 进驻人数
        b = table.find(point.进驻人数, find)
        tap("清空完毕进驻")
        -- toggle tag after 宿舍
        if index > #point.宿舍列表 and not already_after_dormitory then
          auto(update(p, {
            干员选择确认 = "排序筛选按钮",
            排序筛选确认 = true,
          }))
          auto(update(p, {
            排序筛选未进驻选中 = "排序筛选确认",
            排序筛选未进驻未选中 = "排序筛选未进驻未选中",
          }))
          already_after_dormitory = true
        end
        local dorm_index = #point.宿舍列表 - index + 1
        swipq('dorm' .. dorm_index)
        a = 1
        if dorm_index > 0 and dorm_index % 2 == 0 then a = 2 end
        for i = a, a + b - 1 do tap("干员选择列表" .. i) end
      end,
    })
    auto(p)
    auto(update(path.base, {
      面板 = "面板基建",
      进驻总览 = true,
      干员选择确认 = "干员选择确认",
    }))
  end
end

path.戳人 = function()
  update_station_list()
  local o
  for k, v in pairs(la) do
    auto(update(path.取消进驻信息选中, {进驻总览 = v}))
    o = v == "控制中枢" and true or false
    scale(o)
    auto(update(path.base, {
      面板 = "面板基建",
      信赖圈蓝 = "信赖圈蓝",
      信赖圈红 = "信赖圈红",
      进驻总览 = true,
    }))
  end
end

path.订单 = function()
  update_station_list()
  if #point.贸易站列表 == 0 then return end
  auto(update(path.base, {
    订单无 = true,
    进驻总览 = "贸易站列表1",
    贸易站进度 = "贸易站进度",
    订单蓝 = "订单蓝",
    面板 = "面板基建",
    进驻信息2选中 = "进驻信息2选中",
  }))
end

path.订单交付 = function()
  update_station_list()
  local l = #point.贸易站列表
  if l == 0 then return end
  local p = update(path.base, {
    订单无 = true,
    贸易站进度 = "贸易站进度",
    订单蓝 = "订单蓝",
    面板 = "面板基建",
    进驻信息2选中 = "进驻信息2选中",
  })
  for i = 1, l do
    p.进驻总览 = "贸易站列表" .. i
    auto(p)
    auto(update(path.base, {进驻总览 = true, 面板 = "面板基建"}))
  end
end

path.贸易站加速 = function()
  update_station_list()
  local l = #point.贸易站列表
  if l == 0 then return end
  auto(update(path.base, {
    面板 = "面板基建",
    进驻总览 = "贸易站列表1",
    进驻信息2选中 = "进驻信息2选中",
    贸易站进度 = "贸易站进度",
    订单蓝 = "订单蓝",
    订单无 = "无人机协助",
    无人机加速获取订单确定 = function()
      if find("无人机加速获取订单剩余时间零") then
        tap("无人机加速获取订单取消")
        return
      end
      tap("无人机加速最大")
      if not find("多余加速浪费") then
        tap("无人机加速获取订单确定")
        return true
      end
      tap("无人机加速减一")
      tap("无人机加速获取订单确定")
      sleep(20)
    end,
  }))
end

path.制造站补充 = function()
  update_station_list()
  if #point.制造站列表 == 0 then return end
  auto(update(path.base, {
    制造站进度 = "制造站进度",
    制造站设施 = function()
      for i = 1, #point.制造站列表 do
        tap("设施列表" .. i)
        tap("制造站最多")
        findTap("执行更改")
      end
      return true
    end,
    进驻总览 = "制造站列表1",
    面板 = "面板基建",
    进驻信息2选中 = "进驻信息2选中",
  }))
end

path.制造站加速 = function()
  update_station_list()
  if #point.制造站列表 == 0 then return end
  auto(update(path.base, {
    进驻总览 = "制造站列表1",
    面板 = "面板基建",
    制造站进度 = "制造站进度",
    制造站设施 = "制造站加速",
    进驻信息2选中 = "进驻信息2选中",
    无人机加速制造确定 = function()
      tap("无人机加速最大")
      if find("多余加速浪费") then tap("无人机加速减一") end
      tap("无人机加速制造确定")
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
  update_station_list()
  if not point.会客厅 then return end
  auto(update(path.base, {
    进驻信息3 = "线索",
    会客厅信用奖励 = function()
      keepScreen(true)
      local v = table.findv(point.线索布置列表, find)
      keepScreen(false)
      if not v then return true end
      -- offset -50,50
      v = point[v]
      local x = v:find('|')
      local y = v:sub(x + 1, v:find('|', x + 1) - 1)
      x = tonumber(v:sub(1, x - 1))
      y = tonumber(y)
      tap({x - 50, y + 50})
      tap("线索库列表1")
      tap("解锁线索右")
    end,
    进驻总览 = "会客厅",
    面板 = "面板基建",
    进驻信息3选中 = "进驻信息3选中",
  }))
  if findTap("解锁线索") then auto(path.线索布置) end
end

path.线索传递 = update(path.base, {
  面板 = "面板基建",
  进驻总览 = "会客厅",
  进驻信息3 = "线索",
  会客厅信用奖励 = "会客厅线索传递",
  线索传递返回 = function()
    local a = point.线索传递数字列表
    for k, v in pairs(a) do
      tap(v)
      if find("线索传递数字重复") or k == #a then
        tap("线索列表1")
        break
      end
    end
    a = point.传递列表
    local count = 0
    local f = function(random)
      local p = find("线索传递橙框")
      local t
      if p then
        p = p[2]
        if 100 < p and p < 300 then
          t = a[1]
          log('给1')
        elseif p < 500 then
          t = a[2]
          log('给2')
        elseif p < 700 then
          t = a[3]
          log('给3')
        else
          t = a[4]
          log('给4')
        end
      elseif random then
        for i = 1, math.random(0, count) do findTap("线索传递左白") end
        t = a[math.random(#a)]
        log('给随机')
      end
      if t then
        tap(t)
        tap("线索传递返回")
        return true
      end
    end
    while 1 do
      -- 当前页看看有没有缺的
      if f() then return true end
      -- 翻到末尾就随机给
      if not findTap("线索传递右白") and
        not findTap("线索传递右白2") then
        f(true)
        return true
      end
      count = count + 1
    end
  end,
})

path.信用奖励 = function()
  update_station_list()
  if not point.会客厅 then return end
  no_friend = false
  auto(update(path.base, {
    信用奖励有 = function()
      if find("已达线索上限") then
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
      if not find("已达线索上限") then return true end
      if no_friend then return true end
      auto(path.线索传递)
    end,
    面板 = "面板基建",
    进驻信息3选中 = "进驻信息3选中",
  }))
  auto(path.线索布置)
end

path.任务 = function()
  local l = {"活动任务", "周常任务"}
  local b = os.time({
    year = 2019,
    month = 12,
    day = 24,
    hour = 4,
    min = 0,
    sec = 0,
  })
  local t = os.time()
  if t > b then l = {"日常任务", "周常任务"} end
  for _, i in pairs(l) do
    local p = update(path.base, {
      面板 = "面板任务",
      见习任务 = i,
      日常任务 = i,
      活动任务 = i,
      周常任务 = i,
    })
    p[i] = function()
      findTap('任务蓝')
      if table.any({'任务黑', "任务灰"}, find) then return true end
    end
    auto(p)
  end
end

path.信用购买 = function()
  auto(update(path.base, {
    面板 = "面板采购中心",
    可露希尔推荐 = "信用交易所",
    信用交易所 = function()
      if not findTap(unpack(point.信用交易所列表)) then return true end
      findTap("购买物品")
      if find("信用不足") then return true end
    end,
  }))
  return true
end

path.信用收取 = update(path.base, {
  面板 = "面板采购中心",
  可露希尔推荐 = "信用交易所",
  收取信用 = "收取信用",
  收取信用无 = true,
})

path.公开招募聘用 = update(path.base, {
  面板 = function()
    if not findTap("面板公开招募有") then return true end
    for i = 1, 4 do
      if findTap(unpack(point["聘用候选人列表"])) then
        findTap("开包skip")
        tap("返回")
      end
    end
  end,
})

path.邮件 = update(path.base, {
  面板 = "面板邮件",
  收取所有邮件 = function()
    tap("收取所有邮件")
    return true
  end,
})

path.干员强化 = update(path.base, {
  面板 = "面板干员",
  等级递减 = "等级递增",
  等级递增 = "干员列表1",
  EXP = "EXP",
  提升等级确认 = function()
    tap("作战记录列表2")
    tap("提升等级确认")
    return true
  end,
})

path.免费强化包 = update(path.base, {
  面板 = "面板采购中心",
  可露希尔推荐 = "组合包",
  组合包 = function()
    swipq(-10000)
    findTap("免费强化包")
    findTap("购买强化包")
    return true
  end,
})

tick = 0
path.轮次作战 = function()
  while running ~= "理智不足" do
    tick = tick % #fight_type + 1
    -- log(tick,' ',fight_type[tick])
    path.作战(fight_type[tick])
  end
end

-- S2-10 PR-A-2 LS-5 AP-5
path.作战 = function(x)
  -- 代理失误或未同步战斗记录
  local f = startsWithX(x)
  if table.any({"PR", "CE", "CA", "AP", "LS", "SK"}, f) then
    path.物资芯片(x)
  elseif table.any({'龙门外环', '切尔诺伯格', '龙门市区'}, f) then
    path.剿灭(x)
  else
    path.主线(x)
  end
end

path.开始游戏 = function(x)
  if x == "1-11" then return auto(path["1-11"]) end
  return auto(update(path.base, {
    面板 = true,
    代理指挥关 = "代理指挥关",
    代理指挥开 = "开始行动蓝",
    开始行动红 = function()
      -- log(x)
      -- if true then return true end
      tap("开始行动红")
    end,
    未能同步到相关战斗记录 = function()
      bl[x] = false
      return true
    end,
    接管作战 = function()
      -- todo: 记录不能同步到服务器
      if disappear("接管作战", 60 * 60, 5) and
        not find("代理失误放弃行动") then
        log('代理成功', x)
        cl[x] = (cl[x] or 0) + 1
      else
        log('代理失误', x)
        bl[x] = false
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
  local t = "当前进度列表"
  if not x1 then return end
  x1, x2 = x0:sub(1, x1 - 1), x0:sub(x1 + 1)
  x1 = (x1:startsWith("S")) and x1:sub(2) or x1
  local x3 = tonumber(x1) + 1
  -- 面板=>开始游戏
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      swipq(x1)
      tap(x1)
    end,
    [t .. x3] = function()
      swipq(x0)
      if not find(x) then
        -- distance or point error
        log(x .. "未找到")
        bl[x] = false
      else
        tap(x)
      end
      return true
    end,
  })
  -- switch chapter
  for i = 1, #point[t] do
    if x3 ~= i then p[t .. i] = t .. (i > x3 and "左" or "右") end
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
  -- move CE to last
  local lotr = ls_open_time_r
  for k, v in pairs(lotr) do
    table.remove(lotr[k], table.find(lotr[k], equalX("LS")))
    insert(lotr[k], 1, "LS")
    local p = table.find(lotr[k], equalX("CE"))
    if p then
      table.remove(lotr[k], p)
      insert(lotr[k], "CE")
    end
  end
  local a = os.time({
    year = 2019,
    month = 11,
    day = 19,
    hour = 16,
    min = 0,
    sec = 0,
  })
  local b = os.time({
    year = 2019,
    month = 12,
    day = 3,
    hour = 4,
    min = 0,
    sec = 0,
  })
  local t = os.time()
  if a <= t and t < b then
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
    ls_open_time_r[1] = {"LS", "AP", "SK", "CA", "CE"}
    ls_open_time_r[2] = {"LS", "CA", "CE", "AP", "SK"}
    ls_open_time_r[3] = {"LS", "CA", "SK", "AP", "CE"}
    ls_open_time_r[4] = {"LS", "AP", "CE", "CA", "SK"}
    ls_open_time_r[5] = {"LS", "CA", "SK", "AP", "CE"}
    ls_open_time_r[6] = {"LS", "AP", "SK", "CE", "CA"}
    ls_open_time_r[7] = {"LS", "AP", "CA", "CE", "SK"}
  end
end
update_open_time()
path.更新开启时间 = update_open_time

path.物资芯片 = function(x)
  -- split PR-A-1 to A and 1, split LS-1 to LS and 1
  local type = x:startsWith("PR") and "pr" or "ls"
  local x0 = type == "pr" and x:sub(4) or x
  local prls_open_time = _G[type .. "_open_time"]
  local prls_open_time_r = _G[type .. "_open_time_r"]
  local name = type == "pr" and "芯片搜索" or "物资筹备"
  local x1 = x0:find("-")
  local x2
  if not x1 then return end
  x1, x2 = x0:sub(1, x1 - 1), x0:sub(x1 + 1)
  -- check if open now
  local open_time = prls_open_time[x1]
  local cur_time = tonumber(os.date("%w", os.time() - 4 * 3600))
  if cur_time == 0 then cur_time = 7 end

  if not table.includes(open_time, cur_time) then return end
  -- get the index in 芯片搜索
  local cur_open = prls_open_time_r[cur_time]
  local index = table.find(cur_open, equalX(x1))
  -- 面板=>开始游戏
  local p = update(path.base, {
    面板 = function()
      tap("面板作战")
      tap("作战" .. name)
      tap(name .. "列表" .. index)
    end,
    [x] = function()
      tap(x)
      return true
    end,
  })
  auto(p)
  path.开始游戏(x)
end

jwf = {full = false, week = nil}
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
      tap("作战剿灭")
    end,
    [x] = function()
      tap(x)

      return true
    end,
  })
  auto(p)
  if not find("报酬合成玉未满") then
    jwf.full = true
    return
  end
  path.开始游戏(x)
end

path.访问好友基建 = function()
  if comm_enough then return end
  local loop_end = false
  auto(update(path.base, {
    面板 = '面板好友',
    个人名片 = '好友列表',
    好友列表 = function()
      if not findTap('访问基建') then return true end
      tap("访问下位")
      while 1 do
        if not wait(nil, function()
          if find("今日参与交流已达上限") then
            comm_enough = true
            return false
          end
          if find("访问下位无") then
            loop_end = true
            return false
          end
          return not findTap("访问下位橘") and not findTap("访问下位")
        end, 10, 1) or comm_enough or loop_end then return true end
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
  for k, v in pairs(bl) do if not v then b = b .. k .. " " end end
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
  show(showBL(true))
end

path["1-11"] = function()
  sleep(.5)
  local x = "1-11"
  tap("开始行动蓝")
  -- wait 安德切尔
  if not findTap("开始行动红") then return end
  sleep(10)
  if not appear("跳过剧情") then
    log("没找到跳过剧情")
    log('代理失误', x)
    bl[x] = false
    return false
  end
  tap("跳过剧情")
  findTap("跳过剧情确认")
  -- start
  sleep(22)
  tap("速度2")
  -- 芬
  deploy(591, 807, 522)
  -- 翎羽
  deploy(447, 948, 516)
  -- 杰西卡
  sleep(2)
  deploy(585, 939, 373)
  -- 安塞尔
  sleep(6)
  deploy(1299, 801, 384)
  -- 玫兰莎
  sleep(8)
  deploy(945, 1227, 368)
  -- 黑角
  deploy(1122, 1216, 269)
  -- 米格鲁
  sleep(11)
  -- 黑角
  retreat(1110, 263, 894, 323)
  deploy(1482, 813, 314)
  -- 史都华德
  deploy(1656, 669, 407)
  sleep(5)
  -- 玫兰莎
  retreat(1110, 368, 894, 323)
  if appear("行动结束", 60, 5) then
    log('代理成功', x)
    cl[x] = (cl[x] or 0) + 1
  else
    log('代理失误', x)
    bl[x] = false
  end
end

path.base.药剂恢复理智取消 =
  function() tap('药剂恢复理智确认') end
-- path.base.源石恢复理智取消 =
--   function() tap('药剂恢复理智确认') end

path["作战1-11"] = function() for i = 1, 4 do path.作战("1-11") end end

path.关闭 = close
path.显示全部 = showALL
path.后台 = background
