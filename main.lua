-- predebug = true
-- disable_hotupdate = true
-- disable_root_mode = true
-- no_background_after_run = true
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
-- longest_tag = true
-- very_slow_state_check = true
default_findcolor_confidence = 95 / 100
-- default_max_drug_times = 9999
-- default_max_stone_times = 0
-- disable_game_up_check = true
need_show_console = true
milesecond_after_click = 2
release_date = "2021.11.30  0:24"

require('util')
require("point")
require("path")
require("tag")

ui_submit_color = "#ff0d47a1"
ui_cancel_color = "#ff1976d2"
-- ui_page_width = math.round(screen.height*0.89)
-- ui_submit_width = math.round(ui_page_width * 0.8)
-- ui_small_submit_width = math.round(ui_page_width * 0.51)
ui_page_width = -2
ui_submit_width = -2
ui_small_submit_width = -2

setStopCallBack(function()
  -- local screen = getScreen()
  -- console.setPos(round(screen.width * 0.05), round(screen.height * 0.05),
  --                round(screen.width * 0.9), round(screen.height * 0.9))
  console.setPos(round(screen.height * 0.05), round(screen.height * 0.05),
                 round(screen.height * 0.9), round(screen.height * 0.9))

  -- console.setPos(round(screen.width * 0.05), round(screen.height * 0.05),
  --                round(screen.width * 0.09), round(screen.height * 0.09))
  if need_show_console then
    console.show()
  else
    console.dismiss()
  end
end)
setUserEventCallBack(function(type) log(67, type) end)

hotUpdate(true)
showControlBar(true)
setControlBarPosNew(0, 1)
console.clearLog()
-- console.setPos(round(screen.width * 0.05), round(screen.height * 0.05),
--              round(screen.width * 0.9), round(screen.height * 0.9))
console.setPos(round(screen.height * 0.05), round(screen.height * 0.05),
               round(screen.height * 0.9), round(screen.height * 0.9))
console.setTitle("如有问题，滚动到问题点，截屏反馈开发者")
console.show()
console.dismiss()

-- 有root自动开无障碍
if not disable_root_mode and pcall(exec, "su") then root_mode = true end
log("root_mode", root_mode)
if root_mode then
  local package = getPackageName()
  log("package", package)
  print(86)
  -- TODO 以下三行在重启软件后是否有效
  -- exec(
  --   "su -c 'settings put secure enabled_accessibility_services " .. package ..
  --     "/com.nx.assist.AssistService:com.nx.nxproj.assist/com.nx.assist.AssistService'")
  -- exec("su -c 'appops set " .. package .. " PROJECT_MEDIA allow'")
  -- exec("su -c 'appops set " .. package .. " SYSTEM_ALERT_WINDOW allow'")
end

enabled_accessibility_services()
if not isSnapshotServiceRun() then
  log("请开启录屏权限")
  toast("请开启录屏权限")
  openPermissionSetting()
  if not wait(function() return isSnapshotServiceRun() end, 600) then
    stop("开启录屏权限超时")
  end
  home()
end

-- auto switch 官服 and B服
appid_need_user_select = false
appid = oppid

if prefer_bapp then appid = bppid end
if prefer_bapp_on_android7 and android_verison_code < 30 then appid = bppid end
local app_info = isAppInstalled(appid)
local bpp_info = isAppInstalled(bppid)
if not app_info and not bpp_info then stop("未安装明日方舟官服或B服") end
if bpp_info and not app_info then appid = bppid end
if bpp_info and app_info then appid_need_user_select = true end
server = appid == oppid and 0 or 1

if predebug then
  wait(function()
    if findOne("开始行动") and not findOne("代理指挥开") then
      return true
    end
    log(135)
  end, 500)
  log(137, findOne("开始行动"), 138,findOne("代理指挥开"))
  -- log(findAny({"返回", "返回2", "返回3", "返回4"}))
  -- log(findOne("bilibili_framelayout_only"))

  -- log(findOne("bilibili_framelayout"))
  -- log(findOne("game"))
  -- log(findOne("bgame"))
  -- log(findOne("ogame"))
  -- log(1,findOne("game"))
  -- for i = 1, 1000 do findOne("game") end
  -- log(2,findOne("主页"))
  -- for i = 1, 1000 do findOne("主页") end
  -- log(3)
  -- ssleep(1)
  -- sleep(2000 * 1000)
  -- log(JsonEncode(ocrEx(0,0,0,0)))
  -- log(findOnes("线索传递橙框")[1])
  -- log(point["入驻干员"])
  -- log(findOne("入驻干员"))
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

-- TODO 无障碍图色权限获取？
getPixelColor(0, 0)
-- local miui = R():text("立即开始|start now"):type("Button")
-- findColor({0, 0, 1, 1, "0,0,#000000"})
-- if nodeLib.findOne({text = "start now"}, false) then
-- click(miui)

if loadConfig("hideUIOnce", "false") ~= "false" then
  saveConfig("hideUIOnce", "false")
else
  main_ui_lock = lock:add()
  print(218)
  show_main_ui()
  if not wait(function() return not lock:exist(main_ui_lock) end, 600) then
    peaceExit()
  end
end

-- start
loadUIConfig()

update_state_from_ui = function()
  prefer_skill = true
  drug_times = 0
  max_drug_times = tonumber(max_drug_times)
  stone_times = 0
  max_stone_times = tonumber(max_stone_times)
  appid = server == 0 and oppid or bppid
  job = parse_from_ui("now_job_ui", all_job)

  fight = string.filterSplit(fight_ui)
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
  -- log("expanded_fight", expanded_fight)

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

local no_valid_account = true
transfer_global_variable("multi_account_user1", "multi_account_user0")

local apply_multi_account_setting
apply_multi_account_setting = function(i, visited)
  visited = visited or {}
  table.insert(visited, i)
  -- if loadConfig("multi_account_new_setting" .. i, "0") == "0" then
  if _G["multi_account_inherit_toggle" .. i] == "切换为独立设置" then
    local inherit = _G["multi_account_inherit_spinner" .. i]
    local j = math.floor(inherit)
    if inherit == 0 or table.includes(visited, j) then
      transfer_global_variable("multi_account_user0")
    else
      apply_multi_account_setting(j, visited)
    end
  else
    transfer_global_variable("multi_account_user" .. i)
  end
end
for i = 1, dual_server and 2 or 20 do
  log("dual_server", dual_server)
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
    run(job)
  end
end

-- 单帐号模式
if no_valid_account then
  transfer_global_variable("multi_account_user0")
  update_state_from_ui()
  test_fight_hook()
  run(job)
end

-- 全部结束后
log("end_closeapp", end_closeapp)
if end_closeapp then
  closeapp(oppid)
  closeapp(bppid)
end
if not no_background_after_run and end_home then home() end
if end_screenoff then screenoff() end
if end_poweroff then poweroff() end

-- 等待所有QQ通知结束
wait(function() return lock.length == 0 end, 30)

-- local notification
vibrate(100)
playAudio('/system/media/audio/ui/Effect_Tick.ogg')

-- 定时执行逻辑：如果到点但脚本还在run则跳过，因为run中重启可能出现异常
if crontab_enable then
  local config = string.filterSplit(crontab_text, {"：", ":"})
  local candidate = {}
  log("config", config)
  for _, v in pairs(config) do
    local hour_second = v:split(':')
    local hour = math.round(tonumber(hour_second[1] or 0) or 0)
    local min = math.round(tonumber(hour_second[2] or 0) or 0)
    table.insert(candidate,
                 os.time(update(os.date("*t"), {hour = hour, min = min})))
    table.insert(candidate,
                 os.time(update(os.date("*t"), {hour = hour + 24, min = min})))
  end
  table.sort(candidate)
  local next_time = table.findv(candidate, function(x) return x > os.time() end)
  toast("下次执行时间：" .. os.date("%H:%M", next_time))
  log("下次执行时间：" .. os.date("%H:%M", next_time))
  while true do
    if os.time() >= next_time then break end
    ssleep(clamp(next_time - os.time(), 0, 1000))
  end
  saveConfig("hideUIOnce", "true")
  restartScript()
else
  ssleep(.5)
  peaceExit()
end
