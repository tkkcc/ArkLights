-- debug option, should be commented in release
-- disable_communication_check=true
-- speedrun=true
-- debug = true
-- disable_log = true
-- unsafe_tap = true
zero_wait_click = true
check_after_tap = true
-- predebug = true
-- verbose_fca = true
-- no_dorm = true
-- test_some = true
-- ok_time = 1
-- ignore_jmfight_enough_check=true
-- test_fight = true
-- fake_fight = true
-- no_config_cache = true
-- prefer_bapp = true
-- prefer_bapp_on_android7 = true
-- debug0721 = true
-- no_background_after_run = true
-- longest_tag = true
-- very_slow_state_check = true
-- exec(
--   "adb shell settings put secure enabled_accessibility_services com.aojoy.aplug/com.aojoy.server.CmdAccessibilityService")
-- exec(
--   "adb shell settings put secure enabled_accessibility_services com.bilabila.arknightsspeedrun/com.aojoy.server.CmdAccessibilityService")
screen = getScreen()
if screen.width < screen.height then
  screen.width, screen.height = screen.height, screen.width
end
default_findcolor_confidence = 95

require("util")
require("point")
require("path")
require("tag")
log(time() .. " 分辨率：" .. screen.width .. "x" .. screen.height)

-- auto switch 官服 and B服
appid_need_user_select = false
appid = "com.hypergryph.arknights"
bppid = "com.hypergryph.arknights.bilibili"
if prefer_bapp then appid = bppid end
if prefer_bapp_on_android7 and android_verison_code < 30 then appid = bppid end
local app_info = getAppinfo(appid)
local bpp_info = getAppinfo(bppid)
if not app_info and not bpp_info then stop("未安装明日方舟官服或B服") end
if bpp_info and not app_info then appid = bppid end
if bpp_info and app_info then appid_need_user_select = true end

if predebug then
  log(findOne("筛选"))

  local region = {
    {590, 487, 1919, 523}, {1033, 487, 1491, 523}, {1464, 487, 1919, 523},
    {590, 907, 1059, 943}, {1033, 907, 1491, 943}, {1464, 907, 1919, 943},
  }

  -- {0,0,0,0,"1059,457,#D2D1D1|1033,455,#FFFFFF|1464,443,#D1CACE|1491,446,#D6D5D5",95}

  local r = region[1]
  text, info = ocr_fast(math.round(minscale * r[1]),
                        math.round(minscale * r[2]),
                        math.round(minscale * r[3]), math.round(minscale * r[4]))
  log(text, info)
  -- p={}
  -- ocr_text, _ = ocr_fast(table.unpack(p))
  exit()

  zoom()
  log(findOne("缩放结束"))
  exit()
  -- while true do 
  --   if findOne("资源收集", 90) then log(1) end
  --   if findOne("主题曲", 90) then log(2) end
  --   if findOne("每周部署", 90) then log(3) end
  -- end

  log(findOne("主页按过"))
  -- tapAll({
  --   "干员选择列表6", "干员选择列表7", "干员选择列表8",
  --   "干员选择列表9", "干员选择列表10", "干员选择列表11",
  --   "干员选择列表12",
  -- })
  -- tap("访问下位橘")
  -- tap("访问下位橘")
  -- tap("访问下位橘")
  -- tap("访问下位橘")
  exit()
end

local outside = runThread("outside")

local all_job = {
  "邮件收取", "轮次作战", "访问好友", "基建收获",
  "指定换班", "基建换班", "线索搜集", "制造加速",
  "副手换人", "信用购买", "公招刷新", "任务收集",
  "每日任务速通", "满练每日任务速通",
}
local now_job = {
  "邮件收取", "轮次作战", "访问好友", "基建收获",
  "线索搜集", "基建换班", "制造加速", "副手换人",
  "信用购买", "公招刷新", "任务收集",
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
    if _G[prefix .. i] then table.insert(ans, reference[i]) end
  end
  return ans
end

local ui = {
  title = "明日方舟速通（2021.09.08 21:25）",
  cache = not no_config_cache,
  width = -1,
  height = -1,
  time = ok_time or 60,
  views = {
    {title = "账号", type = "edit", id = "username"},
    {title = "密码", type = "edit", id = "password", mode = "password"}, {
      title = "作战",
      type = "edit",
      value = [[当期委托,dqwt,龙门市区，LMSQ,
4-4,4-9,1-7,JT8-3,PR-D-2,PR-D-1,CE-5,LS-5]],
      id = "fight",
    }, {
      title = "换班",
      type = "edit",
      value = [[贸1 10 空 灰 刀
贸1 18 空 灰 刀
贸1 2 天 拉 萨]],
      id = "dorm",
    }, {
      type = "check",
      value = "*吃药|吃石头|*保底最高4星时自动招募|*换班技能优先|" ..
        (is_device_swipe_too_fast and "*" or '') .. "双指滑动",
      ore = 1,
      id = "drug_enable|stone_enable|star4_auto|prefer_skill|is_device_swipe_too_fast",
    }, {
      type = "check",
      ore = 1,
      value = parse_value_to_ui(all_job, now_job),
      id = parse_id_to_ui("now_job_ui", #all_job),
    }, {
      type = "text",
      value = [[
须知：
1. 在接管作战界面启动本辅助将重复刷当前关卡，活动关卡或跳转失败关卡应采用该方式刷。
1. 游戏必须全屏显示，两侧无刘海黑边，无虚拟键。
1. 游戏内尽量采用默认设置。基建退出提示必须开启，异形屏UI适配必须为0。
1. 如果作战滑动距离错误，请尝试切换双指滑动选项，并反馈给我。

待解决问题：
1. 赤金经验加速不分
1. 换班时进入进驻总览后有长时间等待。
1. 主页展开有至多0.5s延时，影响速通时从宿舍跳转采购中心。
1. 指定换班OCR错误率极高。干员只能单字。
1. 危机合约被使用次数弹窗导致速通慢0.7s。

指定换班策略：
每行表示由设施、时间与干员组组成。换该设施时，将使用时间上大于脚本启动时间的最近设置干员。干员组可以不满或留空，但每个干员只能是单字。一个针对贸易站的设置为
贸1 10 空 灰 刀
贸2 10 天 拉 萨
贸1 18 空 灰 刀
贸2 18 巫 雪 芬
贸1 2 天 拉 萨
贸2 2 巫 雪 芬
制1 2
控1
发1
办1
会1
宿1
尽量使用常见字，比如用“子”而非“孑”

每日任务速通准备：
1. 用B服新号，比用官服老号快得多。
1. 使用最快网络与设备。
1. 调整干员列表排序使右上角干员可升级。
1. 确保有20个订单。
1. 撤下全部干员。
1. 进入一次信用交易所。
1. 公开招募全部留空。
1. 展示日常任务界面。
]],
    }, {
      type = 'div',
      title = '',
      views = {
        {
          type = "button",
          value = "视频演示",
          title = '',
          click = {thread = outside, name = "goto_bilibili"},
        }, {
          type = "button",
          value = "QQ群",
          title = '',
          click = {thread = outside, name = "goto_qq"},
        }, {
          type = "button",
          value = "源码(欢迎star!)",
          title = '',
          click = {thread = outside, name = "goto_github"},
        },
      },
    },
  },
  submit = {type = "text", value = "启动"},
  cancle = {type = "text", value = "退出"},
};
-- add server selection to ui
if appid_need_user_select then
  table.insert(ui.views, 1, {
    title = "",
    type = "radio",
    value = "*官服|B服",
    ore = 2,
    id = "server",
  })
end

-- trigger screen recording permission request using one second
findColor({0, 0, 1, 1, "0,0,#000000"})
local miui = R():text("立即开始|start now"):type("Button")
click(miui)

-- trigger color system rebuild
-- home()

ret = show(ui)
if not ret then exit() end
callThreadFun(outside, "preload")
-- findColor({0, 0, 1, 1, "0,0,#000000"})

-- default_findcolor_confidence =
--   math.round(tonumber(default_findcolor_confidence))

if server == "B服" then appid = bppid end
log(appid)

now_job = parse_from_ui("now_job_ui", all_job)

fight = string.map(fight, {
  [","] = " ",
  ["_"] = "-",
  ["、"] = " ",
  ["，"] = " ",
  ["|"] = " ",
  ["\n"] = " ",
  ["\t"] = " ",
})
fight = string.split(fight, ' ')
fight = map(string.upper, fight)
for k, v in pairs(fight) do
  if table.includes(table.keys(jianpin2name), v) then
    fight[k] = jianpin2name[v]
  end
end
fight = table.filter(fight, function(v) return point['作战列表' .. v] end)

all_open_time_start = parse_time("202108261600")
all_open_time_end = parse_time("202109090400")
update_open_time()

startup_time = parse_time()
facility2operator = {}
facility2nexthour = {}
for _, v in pairs(string.split(dorm, '\n')) do
  v = string.split(v)
  if #v > 3 then
    local facility = v[1]
    if #facility == 3 then facility = facility .. 1 end
    local hour = tonumber(v[2])
    local operator = table.slice(v, 3)
    local cur_hour = facility2nexthour[facility]
    if coming_hour(cur_hour, hour, startup_time) == hour then
      facility2operator[facility] = operator
      facility2nexthour[facility] = hour
    end
  end
end
log(facility2nexthour)
log(facility2operator)

if test_fight then
  fight = {
    "CA-5", "CE-5", 'AP-5', 'SK-5', 'LS-5', "PR-D-2", "PR-C-2", "PR-B-2",
    "PR-A-2",

    -- "PR-A-2", "PR-B-1", "PR-B-2", "PR-C-1", "PR-C-2", "PR-D-1", "PR-D-2",
    -- "CE-1", "CE-2", "CE-3", "CE-4", "CE-5", "CA-1", "CA-2", "CA-3", "CA-4",
    -- "CA-5", "AP-1", "AP-2", "AP-3", "AP-4", "AP-5", "LS-1", "LS-2", "LS-3",
    -- "LS-4", "LS-5", "SK-1", "SK-2", "SK-3", "SK-4", "SK-5", "0-1", "0-2", "0-3",
    -- "0-8", "1-9", "2-9", "S3-7", "4-10", "5-9", "6-10", "7-14", "R8-2",
    --
    -- "积水潮窟", "切尔诺伯格", "龙门外环", "龙门市区",
    -- "废弃矿区", "大骑士领郊外", "北原冰封废城", "PR-A-1",
    -- "0-4", "0-5", "0-6", "0-7", "0-8", "0-9", "0-10", "0-11", "1-1", "1-3",
    -- "1-4", "1-5", "1-6", "1-7", "1-8", "1-9", "1-10", "1-11", "1-12", "2-1",
    -- "2-2", "2-3", "2-4", "2-5", "2-6", "2-7", "2-8", "2-9", "2-10", "S2-1",
    -- "S2-2", "S2-3", "S2-4", "S2-5", "S2-6", "S2-7", "S2-8", "S2-9", "S2-10",
    -- "S2-12", "3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "3-8", "S3-1",
    -- "S3-2", "S3-3", "S3-4", "S3-5", "S3-6", "S3-7", "4-1", "4-2", "4-3", "4-4",
    -- "4-5", "4-6", "4-7", "4-8", "4-9", "4-10", "S4-1", "S4-2", "S4-3", "S4-4",
    -- "S4-5", "S4-6", "S4-7", "S4-8", "S4-9", "S4-10", "5-1", "5-2", "S5-1",
    -- "S5-2", "5-3", "5-4", "5-5", "5-6", "S5-3", "S5-4", "5-7", "5-8", "5-9",
    -- "S5-5", "S5-6", "S5-7", "S5-8", "S5-9", "5-10", "6-1", "6-2", "6-3", "6-4",
    -- "6-5", "6-7", "6-8", "6-9", "6-10", "S6-1", "S6-2", "6-11", "6-12", "6-14",
    -- "6-15", "S6-3", "S6-4", "6-16", "7-2", "7-3", "7-4", "7-5", "7-6", "7-8",
    -- "7-9", "7-10", "7-11", "7-12", "7-13", "7-14", "7-15", "7-16", "S7-1",
    -- "S7-2", "7-17", "7-18", "R8-1", "R8-2", "R8-3", "R8-4", "R8-5", "R8-6",
    -- "R8-7", "R8-8", "R8-9", "R8-10", "R8-11", "JT8-2", "JT8-3", "M8-6", "M8-7",
    -- "M8-8",
  }

  fight = table.filter(fight, function(v) return point['作战列表' .. v] end)
  log(fight)
  repeat_fight_mode = false
  run("轮次作战")
  exit()
end
if test_some then end

local start_time = time()
log("start")
run(now_job)
log("end", time() - start_time)

playAudio('/system/media/audio/ui/Effect_Tick.ogg')
ssleep(1)
