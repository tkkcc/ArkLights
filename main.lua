init("0", 1)
setScreenScale(1080,1920)
require("path")
require("util")
cron =  require("crontab")

基建 = {'换人','戳人', '制造站补充','订单','信用奖励'}
作战 = {'作战'}
repeat_last(作战,20)
任务 = {'邮件','信用购买','干员强化','任务'}

start()
--map(run,作战,基建,任务)
cron.cron(map(hc,{{作战,"0,6,12,18"},{基建,2},{任务,3},{restart,4}}),true)