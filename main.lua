init("0", 1)
setScreenScale(1080, 1920)
require("path")
require("util")
cron = require("crontab")

每八小时 = {"邮件", "轮次作战", "基建点击全部", "换人",
                "制造站加速", "制造站补充", "线索接收",
                "信用奖励", "访问好友基建", "信用收取",
                "信用购买", "公开招募聘用", "公开招募刷新",
                "任务", "后台", "显示全部"}
每日开始 = {"关闭", "限时活动", "每日更新", "轮次作战",
                "作战1-11", "基建点击全部", "基建副手换人",
                "任务", "后台", "显示全部"}

fight_type = {"S4-1", "3-4", "4-4", "4-8", "4-9"}
table.extend(fight_type, {"1-7"})
repeat_last(fight_type, 500, "CE-5")
repeat_last(fight_type, 10, "龙门市区")
table.shuffle(fight_type)
-- fight_type = {"DM-1", "DM-2", "DM-3", "DM-4", "DM-5", "DM-6", "DM-7", "DM-8"}
fight_type = {"DM-7", "DM-8"}
-- now("轮次作战","后台")
-- now("基建点击全部","后台")
-- now(unpack(每八小时))
-- now(unpack(每日开始))
-- now("公开招募刷新")
cron(map(hc, {{每日开始, 4}, {每八小时, "1,9,17"}}))
