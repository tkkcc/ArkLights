init("0", 1)
setScreenScale(1080, 1920)
require("path")
require("util")
cron = require("crontab")

每八小时 = {"邮件", "轮次作战", "基建点击全部", "换人",
                "制造站加速", "制造站补充", "订单交付",
                "线索接收", "信用奖励", "访问好友基建",
                "信用收取", "信用购买", "公开招募聘用",
                "公开招募刷新", "任务", "后台", "显示全部"}
每日开始 = {"关闭", "限时活动", "每日更新", "作战1-11",
                "基建点击全部", "基建副手换人", "任务", "后台",
                "显示全部"}

fight_type_ext = {"PR-A-2", "PR-B-2", "PR-C-2", "PR-D-2"}
table.extend(fight_type_ext,
             {"4-8", "LS-5", "CA-5", "AP-5", "CE-5", "龙门市区"})
table.extend(fight_type_ext, {"4-2", "4-10", "4-8"})
insert(fight_type_ext, "CE-5")
repeat_last(fight_type_ext, 500)
insert(fight_type_ext, "龙门市区")
repeat_last(fight_type_ext, 10)
fight_type = fight_type_ext
table.shuffle(fight_type)
-- fight_type={"4-10"}
-- insert(fight_type, "CE-5")
-- repeat_last(fight_type, 500)
now(unpack(每八小时))
-- path.作战("1-11")
-- now(unpack(每日开始))
cron(map(hc, {{每日开始, 4}, {每八小时, "2,10,18"}}))
