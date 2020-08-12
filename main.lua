init("0", 1)
setScreenScale(1080, 1920)
require("path")
require("util")
cron = require("crontab")

每八小时 = {"邮件", "轮次作战", "基建点击全部", "换人",
                "制造站加速", "线索接收", "信用奖励",
                "访问好友基建", "信用收取", "信用购买",
                "公开招募聘用", "公开招募刷新", "任务",
                "显示全部", "后台"}
每日开始 = {"关闭", "每日更新", "作战1-11", "基建点击全部",
                "基建副手换人", "任务", "显示全部", "后台"}

path.base.药剂恢复理智取消 = "药剂恢复理智确认"
-- path.base.源石恢复理智取消 = "药剂恢复理智确认"

-- 从左往右从上往下，未建造位置用其他字
基建左侧 = "贸贸发制发发制制制"

用户名 = "..."
密码 = "..."

fight_type = {"7-15"}
-- fight_type = {"1-7"}
repeat_last(fight_type, 500, "CE-5")
repeat_last(fight_type, 10, "龙门市区")
table.shuffle(fight_type)
fight_type={}
repeat_last(fight_type, 3, "OF-6")
repeat_last(fight_type, 14, "OF-7")
repeat_last(fight_type, 37, "OF-8")
repeat_last(fight_type, 1000, "OF-F4")
-- fight_type={"OF-F4"}
-- 立即执行
-- fight_type = {"4-8"}
-- findTap("作战列表".."LS-5")
-- findTap("作战列表" .. "OF-7")
-- lua_exit()
-- now("轮次作战")
-- now(unpack(每日开始))
now(unpack(每八小时))

-- now("基建副手换人", "显示全部", "后台")
-- now("基建点击全部")
-- 半点执行
cron(map(hc, {{每日开始, 4}, {每八小时, "1,9,17"}, {"后台", "0-23"}}))
