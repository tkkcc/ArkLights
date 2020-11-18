init("0", 1)
setScreenScale(1080, 1920)
require("path")
require("util")
cron = require("crontab")
ret, opt = showUI('ui.json')
if ret == 0 then lua_exit() end
job = getUIContent("ui.json")
job = string.match(job, '"now".*"list": "([^"]+)",')
job = string.split(job, ',')
parse_job = function(cron)
  cron = string.split(cron, '@')
  for i = 1, #cron do cron[i] = job[cron[i] + 1] end
  return cron
end
opt.now = parse_job(opt.now)
opt.cron = {}
if opt.cron1_enable then
  insert(opt.cron, hc({parse_job(opt.cron1), opt.cron1_time}))
end
if opt.cron2_enable then
  insert(opt.cron, hc({parse_job(opt.cron2), opt.cron2_time}))
end
log(opt.drug_enable)
if opt.drug_enable:find("0") then
  path.base.药剂恢复理智取消 = "药剂恢复理智确认"
end
if opt.drug_enable:find("1") then
  path.base.源石恢复理智取消 = "药剂恢复理智确认"
end
opt.fight = string.split(opt.fight, ',')
parse_time = function(a)
  return os.time({
    year = tonumber(a:sub(1, 4)),
    month = tonumber(a:sub(5, 6)),
    day = tonumber(a:sub(7, 8)),
    hour = tonumber(a:sub(9, 10)),
    min = tonumber(a:sub(11, 12)),
  })
end
a = opt.all_open_time:split(',')
opt.all_open_time_start = parse_time(a[1])
opt.all_open_time_end = parse_time(a[2])
update_open_time()
if opt.now_enable then now(opt.now) end
cron(opt.cron)
