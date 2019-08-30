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

作战 = {"邮件", "轮次作战", "火蓝之心任务里程碑",
          "火蓝之心嘉年华轮次作战"}
任务 = {"植物种植", "免费强化包", "访问好友基建",
          "信用收取", "信用购买", "干员强化", "公开招募聘用",
          "任务"}

show("开始")
tick = 0
fight_type_ext = {"OF-6", "OF-6", "OF-6", "OF-6", "OF-6", "OF-8"}
-- fight_type_ext = {"OF-6", "OF-6", "OF-8"}
repeat_last(fight_type_ext, 100)
fight_type = fight_type_ext
-- fight_type = {"CE-5"}
-- table.shuffle(fight_type)
-- now("轮次作战")
cron(map(hc, {{作战, "2,8,14,20"}, {基建, "2,14"}, {任务, 3}, {close, 4},
              {background}, {showALL}}), true)
