init("0", 1)
setScreenScale(1080,1920)
require("path")
require("util")
cron =  require("crontab")

基建 = {'换人','戳人', '制造站补充','订单','线索接收','线索布置','信用奖励'}
作战 = {'邮件','作战'}
repeat_last(作战,100)
任务 = {'信用购买','干员强化','任务','活动任务'}
--now('换人')
-- todo check 67
set_fight_type(1,2,3,4,5)
set_fight_type(8,9)
now(作战)
--now('线索布置','信用奖励')
--now('信用奖励')
show('开始')
--now(作战,基建,任务,close)
--now('信用奖励')
cron.cron(map(hc,{{作战,"1,7,13,19"},{基建,"2,14"},{任务,3},{close}}),true)
