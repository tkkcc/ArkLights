-- predebug = true
-- enable_drug_24hour = true
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
zl_enable_tap_before_drag = true
zero_wait_click = true
check_after_tap = true
crontab_enable = true
-- enable_simultaneous_tap = true
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
release_date = "2022.04.12 20:13"
ui_submit_color = "#ff0d47a1"
ui_cancel_color = "#ff1976d2"
ui_page_width = -2
ui_submit_width = -2
ui_small_submit_width = -2
network_timeout = 300

require('util')
require("point")
require("path")
require("tag")
require('skill')
require("fight")

load(after_require_hook or '')()
point.面板活动 = point.面板活动2
rfl.面板活动 = rfl.面板活动2

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

findOne_interval = str2int(findOne_interval, -1)
tap_interval = str2int(tap_interval, -1)
zl_restart_interval = str2int(zl_restart_interval, math.huge)
if zl_restart_interval_3600 then zl_restart_interval = 3600 end
zl_skill_times = str2int(zl_skill_times, 0)
zl_skill_idx = str2int(zl_skill_idx, 1)
tapall_duration = str2int(tapall_duration, -1)
max_login_times = str2int(max_login_times, math.huge)
if not always_enable_log and debug_disable_log then disable_log = true end
if not enable_shift_log then chooseOperator =
  disable_log_wrapper(chooseOperator) end
QQ = (QQ or ''):commonmap():trim()
if QQ:find('#') then
  devicenote = QQ:sub(QQ:find('#') + 1, #QQ):trim()
  QQ = QQ:sub(1, QQ:find('#') - 1):trim()
end
if #((qqimagedeliver or ''):trim()) == 0 then
  qqimagedeliver = "http://82.156.198.12:49875"
end
if zl_enable_log then zl_disable_log = false end

for i = 1, 7 do
  local k = 'max_drug_times_' .. i .. 'day'
  _G[k] = str2int(_G[k], 0)
end
if disable_drug_24hour then max_drug_times_1day = 0 end

load(before_account_hook or '')()

no_extra_job = {}
transfer_global_variable("multi_account_user1", "multi_account_user0")
-- 多帐号模式
if not crontab_enable_only and (not extra_mode and true or extra_mode_multi) and
  multi_account_enable then

  -- 分隔临时设置
  multi_account_choice = multi_account_choice:commonmap()
  local p = multi_account_choice:find('#')
  if p then
    multi_account_config_remove_once_choice()
    multi_account_choice =
      multi_account_choice:sub(p + 1, #multi_account_choice)
  end
  log(123, multi_account_choice)

  saveConfig("continue_account", '')
  multi_account_choice = expand_number_config(multi_account_choice)
  for idx, i in pairs(multi_account_choice) do
    multi_account_choice_idx = idx
    account_idx = i
    username = (_G["username" .. i] or ''):map({["＃"] = "#"}):trim()
    password = (_G["password" .. i] or ''):trim()
    server = _G["server" .. i] or 0
    usernote = ''
    apply_multi_account_setting(i)
    update_state_from_ui()
    if multi_account_end_closeotherapp then
      closeapp(appid == oppid and bppid or oppid)
    end
    if multi_account_end_closeapp then closeapp(appid) end

    log(account_idx, username, '*****' .. password:sub(#password, #password))
    if username:find("#") then
      usernote = username:sub(username:find('#') + 1, #username):trim()
      username = username:sub(1, username:find('#') - 1):trim()
    end
    log({username, usernote})
    if extra_mode then
      no_extra_job = job
      job = {extra_mode}

    end
    if #username > 0 and #password > 0 then
      table.insert(job, 1, "退出账号")
    end
    saveConfig("continue_account",
               table.join(table.slice(multi_account_choice, idx), ' '))
    run(job)
  end
  saveConfig("continue_account", '')
elseif not crontab_enable_only then
  -- 单帐号模式
  transfer_global_variable("multi_account_user0")
  update_state_from_ui()
  test_fight_hook()
  if extra_mode then
    no_extra_job = job
    job = {extra_mode}
  end
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

load(after_all_hook or '')()

ssleep(.5)
console.dismiss()
peaceExit()
