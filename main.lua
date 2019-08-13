init("0", 1)
setScreenScale(1080, 1920)
-- auto_delay=.5
tap_delay = .5
require("path")
require("util")
cron = require("crontab")
基建 = {"基建点击全部", "换人", "制造站补充", "订单交付",
          "贸易站加速", "线索接收", "线索布置", "信用奖励"}

作战 = {"邮件", "轮次作战"}
任务 = {"植物种植", "免费强化包", "访问好友基建",
          "信用收取", "信用购买", "干员强化", "公开招募聘用",
          "任务"}

show("开始")
fight_type_ext = {"PR-A-1", "PR-A-2", "PR-B-1", "PR-B-2", "PR-C-1", "PR-C-2",
                  "PR-D-1", "PR-D-2"}
insert(fight_type_ext, "CE-5")
repeat_last(fight_type_ext, 200)
insert(fight_type_ext, "CA-5")
repeat_last(fight_type_ext, 200)
insert(fight_type_ext, "PR-D-2")
repeat_last(fight_type_ext, 200)
insert(fight_type_ext, "4-4")
repeat_last(fight_type_ext, 200)
insert(fight_type_ext, "4-8")
repeat_last(fight_type_ext, 200)
insert(fight_type_ext, "4-9")
repeat_last(fight_type_ext, 200)
insert(fight_type_ext, "4-7")
repeat_last(fight_type_ext, 200)
-- insert(fight_type_ext,'龙门外环')
-- repeat_last(fight_type_ext, 2)
-- fight_type = shallowCopy(fight_type_all)
-- table.extend(fight_type,fight_type_ext)
insert(fight_type_ext, "S3-3")
repeat_last(fight_type_ext, 3)
insert(fight_type_ext, "5-7")
repeat_last(fight_type_ext, 11)
insert(fight_type_ext, "4-4")
repeat_last(fight_type_ext, 1)
insert(fight_type_ext, "4-9")
repeat_last(fight_type_ext, 27)
insert(fight_type_ext, "4-7")
repeat_last(fight_type_ext, 22)
insert(fight_type_ext, "4-4")
repeat_last(fight_type_ext, 21)
insert(fight_type_ext, "3-4")
repeat_last(fight_type_ext, 6)
insert(fight_type_ext, "3-1")
repeat_last(fight_type_ext, 2)
fight_type = fight_type_ext
table.shuffle(fight_type)
-- fight_type={'4-4'}
now(作战, 基建, 任务, background)
cron(map(hc, {{作战, "2,8,14,20"}, {基建, "2,14"}, {任务, 3}, {close, 4},
              {background}, {showALL}}), true)
