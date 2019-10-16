init("0", 1)
setScreenScale(1080, 1920)
-- auto_delay=.5
tap_delay = .6
default_delay = 1
require("path")
require("util")
cron = require("crontab")
-- todo:线索收取
每八小时 = {"邮件", "轮次作战", "制造站补充", "订单交付",
                "贸易站加速", "线索布置", "信用奖励",
                "访问好友基建", "信用收取", "信用购买",
                "干员强化", "公开招募聘用", "任务"}
每日开始 = {"作战1-11", "任务"}
每日结束 = {"基建点击全部收取", "换人", "任务"}

show("开始")
tick = 0
fight_type_ext = {"PR-A-2", "PR-B-2", "PR-C-2", "PR-D-2"}
insert(fight_type_ext, "CE-5")
repeat_last(fight_type_ext, 500)
insert(fight_type_ext, "CA-5")
repeat_last(fight_type_ext, 10)
insert(fight_type_ext, "龙门市区")
repeat_last(fight_type_ext, 10)
fight_type = fight_type_ext
table.shuffle(fight_type)

cron(map(hc,
         {{每日开始, 4}, {每八小时, "2,10,18"}, {每日结束, 3},
          {close}, {background}, {showALL}}), true)
