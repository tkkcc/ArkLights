init("0", 1)
setScreenScale(1080, 1920)
require("path")
require("util")
cron = require("crontab")

-- sleep(1)
-- swipq({10000},{1600,500})
-- swipq({10000,-1000},{1600,500})
-- swipq({10000,-2000},{1600,500})
-- swipq({10000,-4000},{1600,500})
-- sys.exit()

version = "20210205"
if get("version", "0") ~= version then
  toast("版本" .. version .. "，设置已重置")
  resetUIConfig("save.dat")
  set("version", version)
else
  toast("版本" .. version)
end
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
if opt.cron1_enable:find("0") then
  insert(opt.cron, hc({parse_job(opt.cron1), opt.cron1_time}))
end
if opt.cron2_enable:find("0") then
  insert(opt.cron, hc({parse_job(opt.cron2), opt.cron2_time}))
end
if opt.drug_enable:find("0") then
  path.base.药剂恢复理智取消 = "药剂恢复理智确认"
end
if opt.drug_enable:find("1") then
  path.base.源石恢复理智取消 = "药剂恢复理智确认"
end
opt.fight = string.split(opt.fight, ',')
for k, v in pairs(opt.fight) do
  if table.includes(table.keys(jianpin2name), v) then
    opt.fight[k] = jianpin2name[v]
  end
end
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
-- now("公开招募聘用","公开招募刷新")

-- lua_exit()
-- opt.fight[1]="龙门市区"
-- opt.fight[1]="龙门外环"
-- opt.fight[1]="切尔诺伯格"
-- opt.fight[1]="北原冰封废城"
-- opt.fight[1]="大骑士领郊外"

debug0415 = false
if debug0415 then
  opt.fight = {
    -- "1-12","S5-7","LS-1","LS-2","LS-3","LS-4","LS-5","SK-1","SK-2","SK-3","SK-4","SK-5",
    "CA-1","CA-2","CA-3","CA-4","CA-5",
    -- 生于黑夜
    -- "DM-1", "DM-2", "DM-3", "DM-4", "DM-5", "DM-6", "DM-7", "DM-8", "TW-8",
    -- "WR-8", "WR-9", "WR-10",
    -- "切尔诺伯格",
    -- "北原冰封废城",
    -- "废弃矿区",
    -- "龙门外环",
    -- "龙门市区",
    -- "大骑士领郊外",
    -- "PR-A-1", "PR-A-2", "PR-B-1", "PR-B-2", "PR-C-1", "PR-C-2", "PR-D-1", "PR-D-2",
    -- "CE-1", "CE-2", "CE-3", "CE-4", "CE-5", "CA-1", "CA-2", "CA-3",
    -- "CA-4", "CA-5", "CA-5", "AP-1", "AP-2", "AP-3", "AP-4", "AP-5",
    -- "LS-1", "LS-2", "LS-3", "LS-4", "LS-5", "SK-1", "SK-2", "SK-3",
    -- "SK-4", "SK-5", "0-1", "0-2", "0-3", "0-4", "0-5", "0-6", "0-7", "0-8", "0-9",
    -- "0-10", "0-11", "1-1", "1-3", "1-4", "1-5", "1-6", "1-7", "1-8", "1-9",
    -- "1-10", "1-11", "1-12", "2-1", "2-2", "2-3", "2-4", "2-5", "2-6", "2-7",
    -- "2-8", "2-9", "2-10", "S2-1", "S2-2", "S2-3", "S2-4", "S2-5", "S2-6", "S2-7", "S2-8", "S2-9", "S2-10", "S2-12",
    -- "3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "3-8", "S3-1", "S3-2", "S3-3", "S3-4", "S3-5", "S3-6", "S3-7",
    -- "4-1", "4-2", "4-3", "4-4", "4-5", "4-6", "4-7", "4-8", "4-9", "4-10", "S4-1",
    -- "S4-2", "S4-3", "S4-4", "S4-5", "S4-6", "S4-7", "S4-8", "S4-9", "S4-10",
    -- "5-1", "5-2", "S5-1", "S5-2", "5-3", "5-4", "5-5", "5-6", "S5-3", "S5-4",
    -- "5-7", "5-8", "5-9", "S5-5", "S5-6", "S5-7", "S5-8", "S5-9", "5-10", "6-1",
    -- "6-2", "6-3", "6-4", "6-5", "6-7", "6-8", "6-9", "6-10", "S6-1",
    -- "S6-2", "6-11", "6-12", "6-14", "6-15", "S6-3", "S6-4", "6-16", "7-2", "7-3",
    -- "7-4", "7-5", "7-6", "7-8", "7-9", "7-10", "7-11", "7-12", "7-13", "7-14",
    -- "7-15", "7-16", "S7-1", "S7-2", "7-17", "7-18",
    -- "R8-1", "R8-2", "R8-3", "R8-4", "R8-5", "R8-6", "R8-7", "R8-8", "R8-9", "R8-10", "R8-11", "JT8-2", "JT8-3", 
    -- "M8-6", "M8-7", "M8-8", "MB-6", "MB-7", "MB-8", 
    -- 火蓝之心
    -- "OF-F1", "OF-F2", "OF-F3", "OF-F4",
    -- 密林
    -- "RI-8",
    -- 骑猎
    -- "GT-1", "GT-2", "GT-3", "GT-4", "GT-5", "GT-6", 
    -- 临光
    -- "MN-8", "MN-7", 
    -- 彩6
    -- "OD-7", "OD-8", 
    -- 漫漫独行
    -- "WD-6", "WD-7", "WD-8",
  }
end

if opt.now_enable:find("0") then now(opt.now) end
if #opt.cron > 0 then cron(opt.cron) end
