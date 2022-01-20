-- predebug = true
-- always_enable_log = true
-- disable_dorm_shift=true
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
release_date = "2022.01.20 16:37"
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
-- setControlBar()
setEventCallback()
hotUpdate()
consoleInit()
check_root_mode()
enable_accessibility_service()
enable_snapshot_service()
detectServer()
predebug_hook()
showUI()
loadUIConfig()
restart_mode_hook()

-- log(findOne_interval,tap_interval)
findOne_interval = str2int(findOne_interval, -1)
tap_interval = str2int(tap_interval, -1)
zl_restart_interval = str2int(zl_restart_interval, math.huge)
-- log(findOne_interval,tap_interval)
-- stop()
-- fallback
if type(username1) == 'string' and #username1 > 0 and type(dual_server) ==
  "boolean" then
  stop("多账号已改版，注意重新设置")
elseif type(dual_server) == "boolean" then
  toast("多账号已改版，注意重新设置")
end

if not always_enable_log and not ui_enable_log then disable_log = true end
-- milesecond_after_click = tonumber(click_interval) or milesecond_after_click

transfer_global_variable("multi_account_user1", "multi_account_user0")

-- 多帐号模式
if not crontab_enable_only and not extra_mode and multi_account_enable then
  multi_account_choice = expand_number_config(multi_account_choice)
  for _, i in pairs(multi_account_choice) do
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
  update_state_from_ui()
  test_fight_hook()
  extra_mode_hook()
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
