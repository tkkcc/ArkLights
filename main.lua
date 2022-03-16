-- predebug = true
-- prefer_speed = true
-- always_enable_log = true
-- enable_shift_log = true
-- disable_dorm_shift=true
-- disable_overview_shift=true
-- prefer_bapp = true
-- disable_hotupdate = true
-- disable_root_mode = true
-- no_background_after_run = true
-- fake_recruit = true
-- debug_tag = true
-- during_crisis_contract =true
-- disable_communication_check=true
-- speedrun=true
-- debug = true
-- disable_log = true
-- unsafe_tap = true
-- zl_disable_fight_drop = true
zl_disable_log = true
zero_wait_click = true
check_after_tap = true
crontab_enable = true
-- auto_clean_fight=true
-- enable_dorm_check = true
-- fake_transfer= true
-- verbose_fca = true
-- no_dorm = true
-- test_some = true
-- ok_time = 1000
-- ignore_jmfight_enough_check=true
-- use_zhuzhu_game = true
-- test_fight = true
-- fake_fight = true
-- no_config_cache = true
-- prefer_bapp_on_android7 = true
-- debug0721 = true
-- longest_tag = true
-- very_slow_state_check = true
default_findcolor_confidence = 95 / 100
-- default_max_drug_times = 9999
-- default_max_stone_times = 0
-- disable_game_up_check = true
-- skip_snapshot_service_check = true
-- need_show_console = true
-- 设成10以下时，单核机作战导航失败率高，真机基建缩放也会有问题
-- 设成1000//30时，真机同时开着B服与官服时会出现点着点着脚本就停（从基建开始做邮件）
frame_milesecond = 1000 // 30
milesecond_after_click = frame_milesecond
release_date = "2022.03.16 22:17"
ui_submit_color = "#ff0d47a1"
ui_cancel_color = "#ff1976d2"
ui_page_width = -2
ui_submit_width = -2
ui_small_submit_width = -2

require('util')
require("point")
require("path")
require("tag")
require('skill')

showControlBar(true)
setEventCallback()
hotUpdate()
fetchSkillIcon()
consoleInit()
check_root_mode()
enable_accessibility_service()
enable_snapshot_service()
detectServer()
predebug_hook()
showUI()
loadUIConfig()
restart_mode_hook()

if not enable_shift_log then chooseOperator =
  disable_log_wrapper(chooseOperator) end

-- log(findOne_interval,tap_interval)
findOne_interval = str2int(findOne_interval, -1)
tap_interval = str2int(tap_interval, -1)
zl_restart_interval = str2int(zl_restart_interval, math.huge)
zl_skill_times = str2int(zl_skill_times, 0)
zl_skill_idx = str2int(zl_skill_idx, 1)
tapall_duration = str2int(tapall_duration, -1)
max_login_times = str2int(max_login_times, math.huge)
log("debug_mode", debug_mode)
-- if best_operator then
--   zl_best_operator = best_operator
--   zl_skip_hard = skip_hard
-- end
-- zl_best_operator = string.trim(zl_best_operator)

-- log(findOne_interval,tap_interval)
-- stop()
-- fallback
-- if type(username1) == 'string' and #username1 > 0 and type(dual_server) ==
--   "boolean" then
--   stop("多账号已改版，注意重新设置")
-- elseif type(dual_server) == "boolean" then
--   toast("多账号已改版，注意重新设置")
-- end

if not always_enable_log and debug_disable_log then disable_log = true end
-- milesecond_after_click = tonumber(click_interval) or milesecond_after_click
-- log(100)
-- for i = 1, 12 do
--   log("now_job_ui" .. i, _G["now_job_ui" .. i])
--   log("multi_account_user1now_job_ui" .. i,
--       _G["multi_account_user1now_job_ui" .. i])
--   log("multi_account_user0now_job_ui" .. i,
--       _G["multi_account_user0now_job_ui" .. i])
-- end
load(before_account_hook or '')()
transfer_global_variable("multi_account_user1", "multi_account_user0")
-- log(101)
-- for i = 1, 12 do
--   log("now_job_ui" .. i, _G["now_job_ui" .. i])
--   log("multi_account_user1now_job_ui" .. i,
--       _G["multi_account_user1now_job_ui" .. i])
--   log("multi_account_user0now_job_ui" .. i,
--       _G["multi_account_user0now_job_ui" .. i])
-- end

-- 多帐号模式
if not crontab_enable_only and not extra_mode and multi_account_enable then
  multi_account_choice = expand_number_config(multi_account_choice)
  for idx, i in pairs(multi_account_choice) do
    multi_account_choice_idx = idx
    account_idx = i
    username = _G["username" .. i]
    password = _G["password" .. i]
    server = _G["server" .. i]
    if username ~= nil then
      apply_multi_account_setting(i)
      update_state_from_ui()
      if multi_account_end_closeotherapp then
        closeapp(appid == oppid and bppid or oppid)
      end
      if multi_account_end_closeapp then closeapp(appid) end
      log(account_idx, username, password)
      if #username > 0 and #password > 0 then
        table.insert(job, 1, "退出账号")
      end
      run(job)
    end
  end
elseif not crontab_enable_only then
  -- 单帐号模式
  transfer_global_variable("multi_account_user0")
  -- log(102)
  -- for i = 1, 12 do
  --   log("now_job_ui" .. i, _G["now_job_ui" .. i])
  --   log("multi_account_user1now_job_ui" .. i,
  --       _G["multi_account_user1now_job_ui" .. i])
  --   log("multi_account_user0now_job_ui" .. i,
  --       _G["multi_account_user0now_job_ui" .. i])
  -- end
  update_state_from_ui()
  test_fight_hook()
  extra_mode_hook()
  disable_log = false
  if debug_mode then
    log(point["源石锭"])
    log(findOne("源石锭"))
    exit()
    toast(fight[1])
    ssleep(3)
    exit()
    toast(getWorkPath())
    ssleep(3)
    local img = getWorkPath() .. "/tmp.jpg"
    snapShot(img)
    log(base64(img))
    log(tostring(111))
    log(1, exec("ls " .. getWorkPath()))
    img = "/sdcard/com.bilabila.arknightsspeedrun2/tmp.jpg"
    log(2, exec("ls /sdcard/com.bilabila.arknightsspeedrun2"))
    snapShot(img)
    log(3, exec("ls /sdcard/com.bilabila.arknightsspeedrun2"))
    exec("echo 1111111 > /sdcard/com.bilabila.arknightsspeedrun2/11.jpg")
    log(4, exec("ls /sdcard/com.bilabila.arknightsspeedrun2"))
    log(tostring(222))
    -- captureqqimagedeliver(os.date('%Y.%m.%d %H:%M:%S') .. "调试模式", QQ)
    exit()
    -- clickPoint = function(x, y)
    --   log(159,x,y)
    --   local gesture = Gesture:new()
    --   local path = Path:new()
    --   path:setStartTime(0)
    --   path:setDurTime(200)
    --   path:addPoint(x, y)
    --   gesture:addPath(path)
    --   gesture:dispatch()
    -- end
    -- clickPoint(733,509)
    log(168)
    _tap(733, 509)
    log(169)
    log("你勾选了调试模式")
    -- if not zero_wait_click then clickPoint = tap end
    exit()
  end

  -- if debug_mode then
  --   log(128, debug)
  --   log(getUIConfigPath("main"))
  --   log(fight)
  --   log(job)
  --   stop(130)
  -- end
  run(job)
end

-- 完成后
if end_closeapp then
  closeapp(oppid)
  closeapp(bppid)
end
if not no_background_after_run and end_home then home() end
if end_screenoff then screenoff() end
if end_poweroff then poweroff() end

-- 等待所有QQ通知结束
wait(function() return lock.length == 0 end, 30)

-- 本地通知
vibrate(100)
playAudio('/system/media/audio/ui/Effect_Tick.ogg')

-- 定时任务
check_crontab()

ssleep(.5)
console.dismiss()
peaceExit()
load(after_all_hook or '')()
