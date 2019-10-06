init("0", 1)
setScreenScale(1080, 1920)
-- auto_delay=.5
tap_delay = .6
default_delay = 1
require("path")
require("util")
cron = require("crontab")
基建 = {"基建点击全部", "换人", "制造站补充", "订单交付",
          "贸易站加速", "线索接收", "线索布置", "信用奖励"}

作战 = {"邮件", "轮次作战"}
任务 = {"访问好友基建", "信用收取", "信用购买", "干员强化",
          "公开招募聘用", "任务"}

show("开始")
tick = 0
fight_type_ext = {"CA-5", "PR-A-2", "PR-B-2", "PR-C-2", "PR-D-2"}
insert(fight_type_ext, "CE-5")
repeat_last(fight_type_ext, 500)
-- insert(fight_type_ext,"龙门外环")
-- repeat_last(fight_type_ext, 10)

fight_type = fight_type_ext
-- fight_type = {"CE-5"}
table.shuffle(fight_type)
-- now("贸易站加速")
-- now(作战, 基建, 任务)
-- fight_type={'OF-8'}
-- fight_type={"OF-7"}
-- repeat_last(fight_type, 28)
-- table.insert(fight_type,"OF-6")
-- table.insert(fight_type,"OF-8")
-- repeat_last(fight_type, 230)
-- fight_type={'龙门外环'}
-- now("贸易站加速")
-- now("任务")
cron(map(hc,
         {{作战, "0,6,8,16"}, {基建, "0,6,8,16"}, {任务, "0,6,8,16"},
          {close}, {background}, {showALL}}), true)
-- cron(map(hc, {{作战, "2,8,14,20"}, {基建, "2,14"}, {任务, 3}, {close, 4},
--               {background}, {showALL}}), true)
