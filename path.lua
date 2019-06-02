require('util')
require('point')
running = nil
path = {}
path.base = {
  面板 = true,
  start黄框 = '删除缓存返回',
  进入游戏 = '进入游戏',
  账号登陆 = '账号登陆',
  登陆 = function()
    local u = '...'
    local p = '...'
    input('账号', u)
    input('密码', p)
    tap('登陆')
  end,
  登入错误 = restart,
  我知道了 = restart,
  密码错误 = function()
    tap('密码错误')
    stop()
  end,
  删除缓存返回 = '删除缓存返回',
  登陆认证失效 = '登陆认证失效',
  今日配给 = '今日配给',
  签到返回 = '签到返回',
  活动公告返回 = '活动公告返回',
  系统公告返回 = '系统公告返回',
  撤下干员确认 = '撤下干员确认',
  其它 = '返回',
  离开基建确认 = '离开基建确认',
  理智兑换 = function()
    running = '理智不足'
    tap('理智兑换')
    return true
  end,
  新手任务 = '右返回',
  代理失误放弃行动 = '代理失误放弃行动',
  提示关闭 = 提示关闭,
  战斗记录未能同步返回 = '战斗记录未能同步返回',
  正在释放神经递质 = function()
    sleep(5)
  end,
  传递线索返回 = '传递线索返回'
}
path.移动停止按钮 = function()
  sleep()
  local p = find('停止按钮')
  if p then
    swip(p[1], p[2], 1920 - p[1], 1080 / 2 - p[2])
  end
  return true
end

path.换人 = function()
  auto(path.base)
  local a, b, p
  for index, i in ipairs(la) do
    p =
      update(
      path.base,
      {
        干员选择确认 = true,
        面板 = '面板基建',
        进驻总览 = i,
        进驻信息 = '进驻信息',
        宿舍进驻信息 = '宿舍进驻信息',
        会客厅进驻信息 = '会客厅进驻信息',
        控制中枢进驻信息 = '控制中枢进驻信息',
        清空 = '清空',
        清空确认 = '清空确认',
        清空完毕进驻 = '清空完毕进驻'
        --						清空完毕进驻2="清空完毕进驻2",
      }
    )
    auto(p)
    if index == 4 then
      auto(
        update(
          p,
          {
            干员选择确认 = '排序筛选按钮',
            排序筛选确认 = true
          }
        )
      )
      auto(
        update(
          p,
          {
            排序筛选未进驻选中 = '排序筛选确认',
            排序筛选未进驻未选中 = '排序筛选未进驻未选中'
          }
        )
      )
    end
    if index <= 4 then
      swip(630, 500, 10000, 0)
    end
    if index == 2 then
      swip(1000, 500, -470, 0)
    elseif index == 3 then
      swip(1000, 500, -1200, 0)
    end
    a = index == 2 and 2 or 1
    b = find('进驻多干员') and 5 or 1
    for i = a, a + b - 1 do
      tap(point.干员选择[i])
    end
    auto(
      update(
        path.base,
        {
          面板 = '面板基建',
          进驻总览 = true,
          干员选择确认 = '干员选择确认'
        }
      )
    )
  end
  return true
end

path.订单 =
  update(
  path.base,
  {
    订单无 = true,
    进驻总览 = '贸易站',
    订单 = '订单',
    订单蓝 = '订单蓝',
    面板 = '面板基建',
    进驻信息选中 = '进驻信息选中'
  }
)

path.制造站补充 =
  update(
  path.base,
  {
    制造站进驻信息 = '制造站进驻信息',
    制造站设施列表 = function()
      for _, i in pairs(point.制造站列表) do
        tap(i)
        tap('制造站最多')
        if find('执行更改') then
          tap('执行更改')
        end
      end
      return true
    end,
    进驻总览 = point.制造站[1],
    面板 = '面板基建',
    进驻信息选中 = '进驻信息选中'
  }
)

local num = #(point.物资筹备) + #(point.芯片搜索) * 2 + 2
local tick = math.random(1, num)
local bl = repeat_last({false}, num - 1)
set_fight_type = function(...)
  bl = repeat_last({false}, num - 1)
  local x = {...}
  for _, i in pairs(x) do
    bl[i] = true
  end
end

path.作战 = function()
  auto(path.base)
  tap('面板作战')
  local true_num = 0
  local p
  for _, i in pairs(bl) do
    true_num = true_num + (i and 1 or 0)
  end
  if true_num == 0 then
    running = '全部作战代理失误'
    return true
  end
  repeat
    tick = (tick % num) + 1
  until bl[tick]
  --123
  if tick <= #(point.物资筹备) then
    --4567
    tap('作战物资筹备')
    tap(point.物资筹备[tick])
  elseif tick <= #(point.物资筹备) + #(point.芯片搜索) * 2 then
    --89
    tap('作战芯片搜索')
    local t = tick - #(point.物资筹备)
    if t > #(point.芯片搜索) then
      t = t - #(point.芯片搜索)
      p = '作战第一'
    end
    tap(point.芯片搜索[t])
  else
    tap('作战骑兵与猎人')
    tap('骑兵与猎人行动地图')
    p = tick - (#(point.物资筹备) + #(point.芯片搜索) * 2)
    p = point.骑兵与猎人[p]
  end
  p = p or find('作战5') or find('作战PR2') or find('作战最后')
  if not p then
    return
  end
  tap(p)
  return auto(
    update(
      path.base,
      {
        代理指挥关 = '代理指挥关',
        代理指挥开 = '开始行动蓝',
        开始行动红 = '开始行动红',
        未能同步到相关战斗记录 = function()
          bl[tick] = false
          return true
        end,
        接管作战 = function()
          while true do
            sleep(5)
            if not find('接管作战') then
              if find('代理失误放弃行动') then
                log('代理失误 ', tick)
                bl[tick] = false
              elseif find('战斗记录未能同步返回') then
                tap('战斗记录未能同步返回')
              end
              return true
            end
          end
        end
      }
    )
  )
end
path.任务 = function()
  for _, i in pairs({'日常任务', '周常任务'}) do
    local p =
      update(
      path.base,
      {
        面板 = '面板任务',
        见习任务 = i,
        日常任务 = i,
        周常任务 = i
      }
    )
    p[i] = true
    auto(p)
    p[i] = nil
    auto(
      update(
        p,
        {
          任务蓝 = '任务蓝',
          任务黑 = true,
          任务灰 = true
        }
      )
    )
  end
end

path.取消进驻信息选中 =
  update(
  path.base,
  {
    面板 = '面板基建',
    进驻总览 = 会客厅,
    进驻信息 = true,
    进驻信息选中 = '进驻信息选中',
    宿舍进驻信息 = true,
    宿舍进驻信息选中 = '宿舍进驻信息选中',
    会客厅进驻信息 = true,
    会客厅进驻信息选中 = '会客厅进驻信息选中',
    控制中枢进驻信息 = true,
    控制中枢进驻信息选中 = '控制中枢进驻信息选中'
  }
)
path.戳人 = function()
  local o
  for _, i in pairs(la) do
    auto(
      update(
        path.取消进驻信息选中,
        {
          进驻总览 = i
        }
      )
    )
    o = i == '控制中枢' and true or false
    scale(o)
    auto(
      update(
        path.base,
        {
          面板 = '面板基建',
          信赖圈蓝 = '信赖圈蓝',
          信赖圈红 = '信赖圈红',
          进驻总览 = true
        }
      )
    )
  end
end

path.信用奖励 =
  update(
  path.base,
  {
    已达线索上限 = function()
      --		保证有好友
      auto(
        update(
          path.base,
          {
            面板 = '面板基建',
            进驻总览 = '会客厅',
            会客厅进驻信息 = '线索',
            会客厅传递线索 = '会客厅传递线索',
            传递线索返回 = function()
              sleep()
              tap(point.线索列表[1])
              sleep()
              tap(point.传递列表[2])
              sleep()
              tap('传递线索返回')
              return true
            end
          }
        )
      )
    end,
    信用奖励有 = '信用奖励有',
    会客厅信用奖励 = '会客厅信用奖励',
    会客厅进驻信息 = '线索',
    进驻总览 = '会客厅',
    信用奖励无 = true,
    面板 = '面板基建',
    会客厅进驻信息选中 = '会客厅进驻信息选中'
  }
)
path.线索布置 = function()
  for k, v in pairs(point.线索布置) do
    k = '线索布置' .. k
    auto(
      update(
        path.base,
        {
          会客厅进驻信息 = '线索',
          会客厅信用奖励 = function()
            if find(k) then
              tap(k)
              tap('线索库列表1')
              sleep()
              tap('解锁线索右')
            end
            return true
          end,
          进驻总览 = '会客厅',
          面板 = '面板基建',
          会客厅进驻信息选中 = '会客厅进驻信息选中'
        }
      )
    )
  end
  if find('解锁线索') then
    tap('解锁线索')
  end
end
path.线索接收 =
  update(
  path.base,
  {
    会客厅进驻信息 = '线索',
    线索全部收取有 = '线索全部收取有',
    线索全部收取无 = true,
    会客厅信用奖励 = '会客厅线索接收',
    进驻总览 = '会客厅',
    面板 = '面板基建',
    会客厅进驻信息选中 = '会客厅进驻信息选中'
  }
)
path.信用购买 =
  update(
  path.base,
  {
    面板 = '面板采购中心',
    可露希尔推荐 = '信用交易所',
    收取信用 = '收取信用',
    收取信用无 = function()
      for _, i in pairs(point.信用交易所列表) do
        tap(i)
        if find('购买物品') then
          tap('购买物品')
        end
        auto(
          update(
            path.base,
            {
              面板 = '面板采购中心',
              可露希尔推荐 = '信用交易所',
              信用交易所 = true,
              信用不足 = true
            }
          )
        )
      end
      return true
    end
  }
)
--path.公开招募=function()
--		auto(path.base)
--		tap('面板公开招募')
--		auto(update(path.base,{
--				聘用候选人='聘用候选人',
--				开包skip='开包skip',
--				面板=true
--		}))
--	end
path.邮件 = function()
  auto(path.base)
  tap('面板邮件')
  sleep()
  tap('收取全部邮件有')
  return true
end
path.干员强化 =
  update(
  path.base,
  {
    面板 = '面板干员',
    等级递减 = '等级递增',
    等级递增 = point.干员列表[1],
    EXP = 'EXP',
    提升等级确认 = function()
      tap(point.经验书列表[1])
      tap('提升等级确认')
      return true
    end
  }
)
path.活动任务 = function()
  auto(path.base)
  tap('面板作战')
  tap('作战骑兵与猎人')
  tap('骑兵与猎人集市')
  sleep()
  tap('骑兵与猎人支线任务')
  sleep()
  while find('活动任务领取') do
    tap('活动任务领取')
    sleep()
    tap('返回')
  end
end
