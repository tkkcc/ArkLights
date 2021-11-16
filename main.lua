-- predebug = true
-- fake_recruit = true
-- during_crisis_contract =true
-- disable_communication_check=true
-- speedrun=true
-- debug = true
-- disable_log = true
-- unsafe_tap = true
zero_wait_click = true
check_after_tap = true
-- auto_clean_fight=true
-- enable_dorm_check = true
-- fake_transfer= true
-- verbose_fca = true
-- no_dorm = true
-- test_some = true
-- ok_time = 1000
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
default_findcolor_confidence = 95
-- default_max_drug_times = 9999
-- default_max_stone_times = 0
disable_hotupdate = true
disable_root_mode = true
disable_game_up_check = true
need_show_console = true

require('util')
require("point")
require("path")
require("tag")

setStopCallBack(function()
  if need_show_console then
    local screen = getScreen()
    console.setPos(round(screen.width * 0.05), round(screen.height * 0.05),
                   round(screen.width, 0.9), round(screen.height, 0.9))
    console.show()
  end
end)

hotUpdate()
showControlBar(true)
setControlBarPosNew(0, 1)
clearLog()
console.clearLog()
console.setPos(round(screen.width * 0.05), round(screen.height * 0.05),
               round(screen.width, 0.9), round(screen.height, 0.9))
console.setTitle("如有问题，滚动到问题点，截屏反馈开发者")
console.dismiss()

-- 有root自动开无障碍
if not disable_root_mode and pcall(exec, "su") then root_mode = true end
if root_mode then
  local package = getPackageName()
  log("package", package)
  -- TODO 以下三行在重启软件后是否有效
  exec(
    "su -c 'settings put secure enabled_accessibility_services " .. package ..
      "/com.nx.assist.AssistService:com.nx.nxproj.assist/com.nx.assist.AssistService'")

  exec("su -c 'appops set " .. package .. " PROJECT_MEDIA allow'")
  exec("su -c 'appops set " .. package .. " SYSTEM_ALERT_WINDOW allow'")
end

if not isAccessibilityServiceRun() then
  log("未开启无障碍")
  toast("请开启无障碍权限")
  openPermissionSetting()
end
if not isSnapshotServiceRun() then
  log("录屏权限未开启")
  toast("请开启无障碍权限")
  openPermissionSetting()
end

-- auto switch 官服 and B服
local appid_need_user_select = false
oppid = "com.hypergryph.arknights"
bppid = "com.hypergryph.arknights.bilibili"
appid = oppid

if prefer_bapp then appid = bppid end
if prefer_bapp_on_android7 and android_verison_code < 30 then appid = bppid end
local all_apps = getInstalledApps()
local app_info = table.findv(all_apps, function(x) return x.pkg == appid end)
local bpp_info = table.findv(all_apps, function(x) return x.pkg == bppid end)
if not app_info and not bpp_info then stop("未安装明日方舟官服或B服") end
if bpp_info and not app_info then appid = bppid end
if bpp_info and app_info then appid_need_user_select = true end
server = appid == oppid and "官服" or "B服"

if predebug then

  jump_github()
  peaceExit()

  vibrate(100)
  playAudio('/system/media/audio/ui/Effect_Tick.ogg')
  ssleep(1)
  peaceExit()
  log(type(getStringConfig("ddddd")))
  log(#getStringConfig("ddddd"))
  exit()
  require("skill")
  log(time())
  log(#skill)
  local border_height = math.round(
                          (379 - 1080 // 2) * minscale + screen.height / 2)
  local skill_height1 = math.round(
                          (397 - 1080 // 2) * minscale + screen.height / 2)
  local skill_height2 = math.round(
                          (817 - 1080 // 2) * minscale + screen.height / 2)
  local color = {
    math.round(600 * minscale), border_height, screen.width, border_height + 5,
    "663,253,#88888A|663,255,#88888A|665,255,#88888A|661,253,#FFFFFF|661,255,#FFFFFF|659,255,#FFFFFF",
    95,
  }
  log(color)
  local borders = findColors(color)
  if not borders then return end
  -- keepScreen(false)
  -- keepScreen(true)
  for _, border in pairs(borders) do
    log('border', border)
    local skill_top_left = {
      {border.x + math.round(5 * minscale), skill_height1},
      {border.y + math.round(47 * minscale), skill_height1},
    }
    local best_score = 0
    local best_skill = 1
    local valid_score_threshold = 0
    for k, v in pairs(skill) do
      log(81, k)
      local rgb = v[4]
      local alpha = v[5]
      local score = 0
      local predict_score = 0
      for i = 1, 36 * 36 do
        -- log(82, i)
        -- log(83, rgb[i])
        -- log(84, alpha[i])
        score = score +
                  (compareColor(skill_top_left[1][1] + i // 36 + 1,
                                skill_top_left[1][2] + i % 36, rgb[i],
                                95 * alpha[i] // 255) and 1 or 0)
        predict_score = score + 36 * 36 - i
        if predict_score < best_score or predict_score < valid_score_threshold then
          break
        end
      end
      if score > best_score and score > valid_score_threshold then
        best_score = score
        brest_skill = k
      end
      log(v[3], score, skill[best_skill][3])
    end
    log(skill[best_skill][3], best_score)
    exit()
  end
  exit()
end

-- 无障碍图色权限获取？
getPixelColor(0, 0)
-- local miui = R():text("立即开始|start now"):type("Button")
-- findColor({0, 0, 1, 1, "0,0,#000000"})
-- if nodeLib.findOne({text = "start now"}, false) then
-- click(miui)

ui.show(make_main_ui(),false)
ssleep(100000)
peaceExit()

for i, x in pairs(make_account_setting_ui()) do table.insert(ui.views, i, x) end

-- add server selection to ui
if appid_need_user_select then
  table.insert(ui.views, 1, {
    type = 'div',
    views = {
      {type = 'text', value = '服务器'},
      {type = "radio", value = "*官服|B服", ore = 1, id = "server"},
    },
  })
end

-- ui loop
while true do
  home()
  local ret = show(ui)
  if not ret then exit() end
  if not unlock_mode and not server1 then break end
  if unlock_mode then
    saveConfig('unlock_mode', JsonEncode(unlock_mode))
    unlock_mode = nil
  end
  if server1 then server1 = nil end
  log(168, ret)
end

update_state_from_ui = function()
  prefer_skill = prefer_skill == "技能"
  drug_times = 0
  max_drug_times = tonumber(max_drug_times)
  stone_times = 0
  max_stone_times = tonumber(max_stone_times)
  appid = server == "官服" and oppid or bppid
  job = parse_from_ui("now_job_ui", all_job)

  fight = string.map(fight_ui, {
    [";"] = " ",
    ['"'] = " ",
    ["'"] = " ",
    ["；"] = " ",
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

  -- expand LS-5x999
  local expanded_fight = {}
  for _, v in pairs(fight) do
    local cur_fight, times = v:match('(.+)[xX*](%d+)')
    if not cur_fight then
      table.insert(expanded_fight, v)
    else
      for _ = 1, times do table.insert(expanded_fight, cur_fight) end
    end
  end
  fight = expanded_fight
  log("expanded_fight", expanded_fight)

  -- LMSQ => 龙门市区
  for k, v in pairs(fight) do
    if table.includes(table.keys(jianpin2name), v) then
      fight[k] = jianpin2name[v]
    end
    if table.includes(table.keys(extrajianpin2name), v) then
      fight[k] = extrajianpin2name[v]
    end
  end
  fight = table.filter(fight, function(v) return point['作战列表' .. v] end)

  all_open_time_start = parse_time("202111221600")
  all_open_time_end = parse_time("202112060400")
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
end

if test_fight then
  fight = {
    "1-7", "1-7", "CE-5", "LS-5",

    -- "9-2", "9-3", "9-4", "9-5", "9-6", "9-7", "9-9", "9-10", "9-11", "9-12",
    -- "9-13", "S9-1", "9-14", "9-15", "9-16", "9-17", "9-18", "9-19",

    -- "0-8", "1-7", "S2-7", "3-7", "S4-10", "S5-3", "6-9", "7-15", "R8-2",
    --
    -- "JT8-2", "R8-2", "M8-8",
    -- "CA-5", "CE-5", 'AP-5', 'SK-5', 'LS-5', "PR-D-2", "PR-C-2", "PR-B-2",
    -- "PR-A-2", "龙门外环", "龙门市区", 
    -- "1-7", "1-12", "2-3", "2-4",
    -- "2-9", "S2-7", "3-7", "S4-10", "S5-3", "6-9", "7-6", "7-15", "S7-2",
    -- "JT8-2", "R8-2", "M8-8",

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

if test_some then exit() end

-- 多账号模式 load by builtin ui, tricky
ui = make_multi_account_setting_ui()
ui.cache = true
ui.time = 1
ui.width = 1
ui.height = 1
show(ui)

local no_valid_account = true

transfer_global_variable("multi_account_user1", "multi_account_user0")

local apply_multi_account_setting
apply_multi_account_setting = function(i, visited)
  visited = visited or {}
  table.insert(visited, i)
  if loadConfig("multi_account_new_setting" .. i, "0") == "0" then
    local inherit = _G["multi_account_inherit_setting" .. i]
    local j = tonumber(string.sub(inherit, #"账号" + 1))
    if inherit == "默认" or table.includes(visited, j) then
      transfer_global_variable("multi_account_user0")
    else
      apply_multi_account_setting(j, visited)
    end
  else
    transfer_global_variable("multi_account_user" .. i)
  end
end
for i = 1, dual_server and 2 or 20 do
  username = _G["username" .. i]
  password = _G["password" .. i]
  if (multi_account and _G["multi_account" .. i]) and
    (#username > 0 and #password > 0 or dual_server) then
    server = _G["server" .. i]
    no_valid_account = false
    apply_multi_account_setting(i)
    update_state_from_ui()
    if multi_account_end_closeapp then
      closeapp(appid == oppid and bppid or oppid)
    end
    if not dual_server then table.insert(job, 1, "退出账号") end
    log(job)
    run(job)
  end
end

-- 单帐号模式
if no_valid_account then
  transfer_global_variable("multi_account_user0")
  update_state_from_ui()
  run(job)
end

-- 全部结束后
if not no_background_after_run then home() end
if end_closeapp then
  closeapp(oppid)
  closeapp(bppid)
end
if end_screenoff then screenoff() end
if end_poweroff then poweroff() end

-- 等待所有QQ通知结束
wait(function() return lock.length == 0 end, 30)

-- local notification
vibrate(100)
playAudio('/system/media/audio/ui/Effect_Tick.ogg')
ssleep(1)
peaceExit()
