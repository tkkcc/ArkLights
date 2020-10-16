init("0", 1)
setScreenScale(1080, 1920)

require("path")
require("util")
cron = require("crontab")

每八小时 = {"邮件", "轮次作战", "基建点击全部", "换人",
                "制造站加速", "线索接收", "信用奖励",
                "访问好友基建", "信用收取", "信用购买",
                "公开招募聘用", "公开招募刷新", "任务", "后台",
                "显示全部"}
每日开始 = {"关闭", "每日更新", "作战1-11", "基建点击全部",
                "基建副手换人", "任务", "后台", "显示全部"}

path.base.药剂恢复理智取消 = "药剂恢复理智确认"
-- path.base.源石恢复理智取消 = "药剂恢复理智确认"

-- 从左往右从上往下，未建造位置用其他字
基建左侧 = "贸贸发制发发制制制"

用户名 = "..."
密码 = "..."

fight_type = {"7-15"}
repeat_last(fight_type, 500, "CE-5")
repeat_last(fight_type, 10, "龙门市区")
table.shuffle(fight_type)
fight_type = {}
repeat_last(fight_type, 100, "MN-8")
-- now(unpack(每日开始))
now(unpack(每八小时))
-- now("公开招募聘用","公开招募刷新")

cron(map(hc, {{每日开始, 4}, {每八小时, "1,9,17"},
              {{"后台", "显示全部"}, "0-23"}}))
