-- debug option, should be all false / zero / empty in release
print(time())
print(findColor({223,310,238,319,"229,313,#EEEEEE",10})==nil)
exit()
--print(time())
--for i = 1,100 do
--print(findShape({'#FFFFFF-95','[{"a":-0.085,"d":1.33,"id":"1","r":1159.0}]',0.85}) ==nil)
--end
--print(findColor({0, 0, 1920, 1080, "1596,511,#FFFFFC", 99}) == nil)
--print(findColor({1595, 510, 1599, 516, "1596,511,#FFFFFF", 100}) == nil)
 --print(findColor({0,0,122,95,"0,0,#182931|57,58,#FFFFFF",100})==nil)
 --print(findColor({1757,179,1854,245,"1801,195,#FFFFFF",100})==nil)
 --print(findColor({892,428,923,429,"892,428,#CCFF66",100})==nil)
-- print(findColors({0, 0, 1920, 1080, "1596,511,#FFFFFC", 99})==nil)
-- print(findColors({1596, 511, 1606, 546, "1596,511,#FFFFFA", 99})==nil)
-- print(findColors({0,0,122,95,"0,0,#182931|57,58,#FFFFFF",100})==nil)
--exit()
local test_some = true
-- warkaround for nspirit
test_fight = false
no_config_cache = true
ok_time = 1
screen = getScreen()
print("分辨率：" .. screen.width .. "x" .. screen.height)
require("util")
require("path")
require("point")
cron = require("crontab")
exit()
-- swipq("S5-2")
-- swipq("5-3")
-- keepScreen(true)
-- target="当前进度列表6"
-- target="作战列表5-1"
-- start=time()
-- log(findColorAbsolute(point[target])==nil)
-- print(time()-start)
-- start=time()
-- log(findOne(target)==nil)
-- print(time()-start)
-- exit()
-- log(findOne("作战列表5-3"))
-- for i = 1, 100000 do log(i, findOne("当前进度列表6") == nil) end
-- log(findOne("当前进度列表6") == nil)
-- exit()
-- ssleep(4)

-- slid(1000,500,10000,500,250)
-- ssleep()
-- slid(math.floor(screen.width * 0.5), 100,
--     math.floor(screen.width * 0.4), 100, 400)
-- slid(math.floor(screen.width * 0.5), 100,
--     math.floor(screen.width * 0.05), 100, 400)
-- ssleep(3)
-- slid(math.floor(screen.width * 0.5), 100,
--     math.floor(screen.width * 0.95), 100, 400)
-- ssleep(3)
-- exit()

local outside = runThread("outside")
local all_job = {
  "每日更新", "作战1-11", "邮件", "轮次作战", "基建点击全部",
  "换人", "基建副手换人", "制造站加速", "线索接收",
  "信用奖励", "访问好友基建", "信用收取", "信用购买",
  "公开招募聘用", "公开招募刷新", "任务", "后台",
  "显示全部",
}
local now_job = {
  -- "每日更新", "作战1-11",
  "邮件", "轮次作战", "基建点击全部", "换人", -- "基建副手换人",
  "制造站加速", "线索接收", "信用奖励", "访问好友基建",
  "信用收取", "信用购买", "公开招募聘用", "公开招募刷新",
  "任务", "后台", "显示全部",
}

local cron1_job = now_job
local cron2_job = {
  "每日更新", "作战1-11", "邮件", "基建副手换人", "任务",
  "后台", "显示全部",
}

local parse_id_to_ui = function(prefix, length)
  local ans = ''
  for i = 1, length do ans = ans .. prefix .. i .. '|' end
  return ans:sub(1, #ans - 1)
end

local parse_value_to_ui = function(all, select)
  local ans = ''
  for _, v in pairs(all) do
    if table.includes(select, v) then ans = ans .. '*' end
    ans = ans .. v .. '|'
  end
  return ans:sub(1, #ans - 1)
end

local parse_from_ui = function(prefix, reference)
  local ans = {}
  for i = 1, #reference do
    if _G[prefix .. i] then insert(ans, reference[i]) end
  end
  return ans
end

local ui = {
  title = "明日方舟全日常代理",
  cache = not no_config_cache,
  width = -1,
  height = -1,
  time = ok_time,
  views = {
    {title = "账号", type = "edit", id = "username"},
    {title = "密码", type = "edit", id = "password", mode = "password"}, {
      title = "轮次作战地图",
      type = "edit",
      value = "R8-2,龙门市区,LMSQ,PR-D-2,CE-5,LS-5",
      id = "fight",
    }, {
      type = "check",
      value = "*吃药|*吃石头|*保底最高4星时自动招募",
      ore = 1,
      id = "drug_enable|stone_enable|start4_auto",
    }, {type = "text", value = ""},
    {type = "check", value = "*立即执行：", id = "now_enable"}, {
      type = "check",
      ore = 1,
      value = parse_value_to_ui(all_job, now_job),
      id = parse_id_to_ui("now_job_ui", #all_job),
    }, {type = "text", value = ""},
    {type = "check", value = "*半点执行1：", id = "cron1_enable"}, {
      type = "check",
      ore = 1,
      value = parse_value_to_ui(all_job, cron1_job),
      id = parse_id_to_ui("cron1_job_ui", #all_job),
    }, {
      title = "半点执行1时间",
      type = "edit",
      value = "1,9,17",
      id = "cron1_time",
    }, {type = "text", value = ""},
    {type = "check", value = "*半点执行2：", id = "cron2_enable"}, {
      type = "check",
      ore = 1,
      value = parse_value_to_ui(all_job, cron2_job),
      id = parse_id_to_ui("cron2_job_ui", #all_job),
    },
    {
      title = "半点执行2时间",
      type = "edit",
      value = "4",
      id = "cron2_time",
    }, {
      type = 'div',
      title = '',
      views = {
        {
          type = "button",
          value = "QQ群：1009619697",
          title = '',
          click = {thread = outside, name = "goto_qq"},
        }, {
          type = "button",
          value = "视频演示",
          title = '',
          click = {thread = outside, name = "goto_bilibili"},
        }, {
          type = "button",
          value = "开发",
          title = '',
          click = {thread = outside, name = "goto_github"},
        },
      },
    },
  },
  submit = {type = "text", value = "启动"},
  cancle = {type = "text", value = "退出"},
};

ret = show(ui)
if not ret then exit() end

now_job = parse_from_ui("now_job_ui", all_job)
cron1_job = parse_from_ui("cron1_job_ui", all_job)
cron2_job = parse_from_ui("cron2_job_ui", all_job)
local cron_job = {}
if cron1_enable then insert(cron_job, half_hour_cron({cron1_job, cron1_time})) end
if cron2_enable then insert(cron_job, half_hour_cron({cron2_job, cron2_time})) end

-- if drug_enable then
--  path.base.药剂恢复理智取消 = "药剂恢复理智确认"
-- end
-- if stone_enable then
--  path.base.源石恢复理智取消 = "药剂恢复理智确认"
-- end

fight = string.map(fight, {
  [","] = " ",
  ["、"] = " ",
  ["，"] = " ",
  ["|"] = " ",
  ["\n"] = " ",
})
fight = string.split(fight, ' ')
fight = map(string.upper, fight)
-- for k, v in pairs(fight) do
--  if table.includes(table.keys(jianpin2name), v) then
--    fight[k] = jianpin2name[v]
--  end
-- end

local parse_time = function(a)
  return os.time({
    year = tonumber(a:sub(1, 4)),
    month = tonumber(a:sub(5, 6)),
    day = tonumber(a:sub(7, 8)),
    hour = tonumber(a:sub(9, 10)),
    min = tonumber(a:sub(11, 12)),
  })
end
all_open_time_start = parse_time("202001011600")
all_open_time_end = parse_time("202001010400")
-- update_open_time()

if test_fight then
  fight = {
    -- ??
    -- "TB-DB-1", "TB-DB-2", "TB-DB-3", "TB-DB-4", "FIN-TS",
    -- "TW-6",
    -- "TW-7",
    -- "TW-8",
    -- ============= debug
    -- "潮没海滨",
    -- "切尔诺伯格",
    -- "龙门外环",
    -- "龙门市区",
    -- "废弃矿区",
    -- "大骑士领郊外",
    -- "北原冰封废城",

    -- "PL-1", "PL-2", "PL-3", "PL-4", "PL-5",

    -- -- 生于黑夜
    -- "DM-1", "DM-2", "DM-3", "DM-4", "DM-5", "DM-6", "DM-7", "DM-8",
    -- -- 遗尘漫步
    -- "WD-6", "WD-7", "WD-8",
    -- -- 覆潮之下
    -- "SV-7", "SV-8", "SV-9",

    -- "PR-A-1", "PR-A-2", "PR-B-1", "PR-B-2", "PR-C-1", "PR-C-2", "PR-D-1", "PR-D-2",
    -- "CE-1", "CE-2", "CE-3", "CE-4", "CE-5", "CA-1", "CA-2", "CA-3","CA-4", "CA-5",
    -- "AP-1", "AP-2", "AP-3", "AP-4", "AP-5",
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
    -- "M8-6", "M8-7", "M8-8",
    -- -- 火蓝之心
    -- "OF-F1", "OF-F2", "OF-F3", "OF-F4",
    -- -- 骑猎
    -- "GT-1", "GT-2", "GT-3", "GT-4", "GT-5", "GT-6",
  }
end
if test_fight then
  run("轮次作战")
  pause()
  exit()
end
if test_some then
  -- debug
  logConfig({mode = 3})
  menuConfig({x = 0, y = screen.height / 2 - 50, alpha = 1})
  open()
  fight = {"5-1"}
  -- , "1-2", "S3-3", "S4-5", "R8-2"}
  username = ""
  password = ""
  run("轮次作战")
  log(241)
  exit()
end

if now_enable then run(now_job) end
if #cron_job > 0 then cron(cron_job) end
