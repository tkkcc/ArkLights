#!/usr/bin/env bash
{
  init() {
    declare -A serial
    # serial=([k40]=df7592c8 [l]=localhost:5555 [z9]=z9:5555 [z9v]=z9:5667 )
    # export ANDROID_SERIAL=${serial[${1:-l}]}
    export ANDROID_SERIAL=$1
    adb forward --remove tcp:9095
    adb forward --remove tcp:9090
    adb forward tcp:9095 tcp:9095
    adb forward tcp:9090 tcp:9090
  }
  restartcolor() { # 重启节点精灵，以适应分辨率变更
    adb shell am force-stop com.aojoy.aplug
    sleep 1

    # === no need to start from launcher
    adb shell monkey -p com.aojoy.aplug -c android.intent.category.LAUNCHER 1
    sleep 1

    # === to find the service name
    # adb shell dumpsys activity services aojoy
    # com.aojoy.aplug/com.aojoy.server.CmdAccessibilityService
    # adb shell settings put secure enabled_accessibility_services com.aojoy.aplug/com.aojoy.server.floatwin.FloatService
    # adb shell settings put secure enabled_accessibility_services com.aojoy.aplug/com.aojoy.server.CmdAccessibilityService
    # adb shell settings put secure enabled_accessibility_services com.aojoy.aplug/com.aojoy.server.CmdService
    # sleep 2

    # adb shell am start com.hypergryph.arknights
    # adb shell input keyevent KEYCODE_APP_SWITCH
    # adb shell input keyevent KEYCODE_APP_SWITCH

    #adb shell monkey -p com.hypergryph.arknights -c android.intent.category.LAUNCHER 1
    # sleep 2
  }
  remove() {
    curl 'http://localhost:9090/script/del?name=test' -X 'POST'
  }
  beta() {
    release 'script.lr.beta'
  }
  release() {
    local lr=${1:-script.lr}
    git add -u
    cd release
    cp /F:/software/懒人精灵3.6.0/out/main.lr $lr
    cp ../README.md README.md
    numfmt --to=iec $(stat -c %s $lr)

    local md5=$(md5sum $lr | cut -d' ' -f1)
    echo $md5 >$lr.md5
    git add -A
    git commit --amend --date=now -m "$md5"
    git push --force
  }
  stop() {
    i3-msg 'focus left'
    xte 'keydown F6'
    xte 'keyup F6'
    i3-msg 'focus left'
  }
  findr() {
    # 测试不同分辨率下脚本结果
    local option=(
      1080x2400
      720x1280
      1080x1920
      1080x2340
    )
    if [[ -n $1 ]]; then
      option=(${option[$1]})
      shift
    fi
    for ((i = 0; i < ${#option[@]}; ++i)); do
      adb shell wm size ${option[$i]}
      # restartcolor "$@"
      # if [[ $i -eq 0 ]]; then
      #   save "$@"
      # fi
      # run "$@"
    done
  }
  run() {
    i3-msg 'focus left'
    xte 'keydown F6'
    xte 'keyup F6'
    sleep .1
    xte 'keydown F5'
    xte 'keyup F5'
    i3-msg 'focus left'
  }

  save() {
    sed -i -r 's/^(release_date =).+$/\1 "'"$(date +'%Y.%m.%d %k:%M')"'"/' main.lua
    local dst_dir=/F:/software/懒人精灵3.6.0/script/main
    dst="$dst_dir"/脚本
    mkdir -p $dst
    while IFS= read -r -d '' f; do
      iconv -f UTF-8 -t GB18030 "$f" -o "$dst/$f"
    done < <(find . -type f -name '*.lua' -printf '%P\0')
    dst="$dst_dir"/界面
    mkdir -p $dst
    while IFS= read -r -d '' f; do
      iconv -f UTF-8 -t GB18030 "$f" -o "$dst/$f"
    done < <(find . -type f -name '*.ui' -printf '%P\0')
  }
  saverun() {
    save
    run
  }

  timer() {
    local start=$(date +"%s.%N" -d "${1:-now}")
    local cur
    while :; do
      cur=$(date +"%s.%N")
      printf "\r$(date -d "0 $cur seconds - $start seconds" +"%H:%M:%S")"
      sleep 1
    done
  }

  scrcpy() {
    scrcpy "$@"
  }
  png2rgb() {
    convert "$1" txt:- | tail -n +2 | sed -nr 's/.*(#.{6}).*/\1/p'
  }
  png2alpha() {
    convert "$1" txt:- | tail -n +2 | sed -nr 's/.*,([^,]+)\)$/\1/p'
  }
  dim() {
    # make dim version of skill icon
    local src=${1:-png}
    local dst=${2:-png_noalpha_dim}
    mkdir -p "$dst"
    mogrify -path "$dst" -alpha set -channel A -evaluate multiply 0.4 +channel -alpha remove -alpha off -background '#202020' "$src"/'*.png'
  }
  noalpha() {
    # make noalpha version of skill icon
    local src=${1:-png}
    local dst=${2:-png_noalpha}
    mkdir -p "$dst"
    mogrify -path "$dst" -alpha remove -alpha off -background '#3D3D3D' "$src"/'*.png'
  }
  fetchicon() {
    local a="prts.wiki/images/5/5f/Bskill_ctrl_p_spd.png
prts.wiki/images/2/2e/Bskill_ctrl_token_p_spd.png
prts.wiki/images/8/85/Bskill_ctrl_p_bot.png
prts.wiki/images/5/58/Bskill_ctrl_t_spd.png
prts.wiki/images/5/58/Bskill_ctrl_t_spd.png
prts.wiki/images/3/3c/Bskill_ctrl_c_spd.png
prts.wiki/images/0/01/Bskill_ctrl_h_spd.png
prts.wiki/images/2/21/Bskill_ctrl_cost_aegir.png
prts.wiki/images/5/54/Bskill_ctrl_aegir.png
prts.wiki/images/9/97/Bskill_ctrl_aegir2.png
prts.wiki/images/c/cc/Bskill_ctrl_psk.png
prts.wiki/images/9/9f/Bskill_ctrl_t_limit%26spd.png
prts.wiki/images/f/f7/Bskill_ctrl_lda.png
prts.wiki/images/d/d0/Bskill_ctrl_lda_add.png
prts.wiki/images/9/96/Bskill_ctrl_karlan.png
prts.wiki/images/b/be/Bskill_ctrl_lungmen.png
prts.wiki/images/6/69/Bskill_ctrl_ussg.png
prts.wiki/images/a/a0/Bskill_ctrl_sp.png
prts.wiki/images/e/e9/Bskill_ctrl_cost.png
prts.wiki/images/e/e9/Bskill_ctrl_cost.png
prts.wiki/images/e/e9/Bskill_ctrl_cost.png
prts.wiki/images/e/e9/Bskill_ctrl_cost.png
prts.wiki/images/e/e9/Bskill_ctrl_cost.png
prts.wiki/images/e/e9/Bskill_ctrl_cost.png
prts.wiki/images/e/e9/Bskill_ctrl_cost.png
prts.wiki/images/e/e9/Bskill_ctrl_cost.png
prts.wiki/images/5/52/Bskill_ctrl_clear_sui.png
prts.wiki/images/d/d0/Bskill_ctrl_cost_bd1%26bd2.png
prts.wiki/images/9/9d/Bskill_ctrl_cost_bd1.png
prts.wiki/images/7/73/Bskill_ctrl_cost_bd2.png
prts.wiki/images/c/cb/Bskill_ctrl_ash.png
prts.wiki/images/6/60/Bskill_ctrl_r6.png
prts.wiki/images/c/c4/Bskill_ctrl_tachanka.png
prts.wiki/images/c/c0/Bskill_ctrl_c_wt.png
prts.wiki/images/e/ea/Bskill_ctrl_c_wt2.png
prts.wiki/images/b/b8/Bskill_ctrl_c_wt1.png
prts.wiki/images/9/93/Bskill_pow_spd3.png
prts.wiki/images/9/93/Bskill_pow_spd3.png
prts.wiki/images/9/93/Bskill_pow_spd3.png
prts.wiki/images/9/93/Bskill_pow_spd3.png
prts.wiki/images/a/a0/Bskill_pow_spd2.png
prts.wiki/images/a/a0/Bskill_pow_spd2.png
prts.wiki/images/a/a0/Bskill_pow_spd2.png
prts.wiki/images/a/a0/Bskill_pow_spd2.png
prts.wiki/images/a/a0/Bskill_pow_spd2.png
prts.wiki/images/a/a0/Bskill_pow_spd2.png
prts.wiki/images/a/a0/Bskill_pow_spd2.png
prts.wiki/images/8/8f/Bskill_pow_spd1.png
prts.wiki/images/8/8f/Bskill_pow_spd1.png
prts.wiki/images/8/8f/Bskill_pow_spd1.png
prts.wiki/images/2/21/Bskill_pow_spd%26cost.png
prts.wiki/images/8/8f/Bskill_pow_spd1.png
prts.wiki/images/9/9c/Bskill_pow_jnight.png
prts.wiki/images/c/c6/Bskill_man_exp3.png
prts.wiki/images/5/5c/Bskill_man_exp2.png
prts.wiki/images/4/44/Bskill_man_exp1.png
prts.wiki/images/5/55/Bskill_man_gold2.png
prts.wiki/images/c/cb/Bskill_man_gold1.png
prts.wiki/images/b/b6/Bskill_man_spd%26trade.png
prts.wiki/images/6/6d/Bskill_man_spd_bd_n1.png
prts.wiki/images/4/47/Bskill_man_spd_bd1.png
prts.wiki/images/6/6c/Bskill_man_spd_bd2.png
prts.wiki/images/2/25/Bskill_man_spd_variable21.png
prts.wiki/images/3/37/Bskill_man_spd3.png
prts.wiki/images/1/15/Bskill_man_spd2.png
prts.wiki/images/1/15/Bskill_man_spd2.png
prts.wiki/images/1/15/Bskill_man_spd2.png
prts.wiki/images/f/fd/Bskill_man_limit%26cost3.png
prts.wiki/images/0/03/Bskill_man_spd%26limit%26cost3.png
prts.wiki/images/0/03/Bskill_man_spd%26limit%26cost3.png
prts.wiki/images/0/05/Bskill_man_spd_add1.png
prts.wiki/images/f/f1/Bskill_man_spd_add2.png
prts.wiki/images/f/f1/Bskill_man_spd_add2.png
prts.wiki/images/b/b3/Bskill_man_spd1.png
prts.wiki/images/b/b3/Bskill_man_spd1.png
prts.wiki/images/b/b3/Bskill_man_spd1.png
prts.wiki/images/b/b3/Bskill_man_spd1.png
prts.wiki/images/f/fb/Bskill_man_spd%26power3.png
prts.wiki/images/2/2f/Bskill_man_spd%26power2.png
prts.wiki/images/7/71/Bskill_man_spd%26power1.png
prts.wiki/images/4/48/Bskill_man_skill_spd.png
prts.wiki/images/c/c1/Bskill_man_spd%26limit3.png
prts.wiki/images/9/9b/Bskill_man_spd%26limit1.png
prts.wiki/images/4/4e/Bskill_man_spd%26limit%26cost2.png
prts.wiki/images/7/76/Bskill_man_spd%26limit%26cost1.png
prts.wiki/images/7/7d/Bskill_man_spd%26limit%26cost4.png
prts.wiki/images/9/9e/Bskill_man_exp%26limit2.png
prts.wiki/images/4/40/Bskill_man_exp%26limit1.png
prts.wiki/images/b/ba/Bskill_man_limit%26cost2.png
prts.wiki/images/8/82/Bskill_man_spd_variable31.png
prts.wiki/images/4/47/Bskill_man_limit%26cost1.png
prts.wiki/images/0/05/Bskill_man_spd_add1.png
prts.wiki/images/4/47/Bskill_man_limit%26cost1.png
prts.wiki/images/4/47/Bskill_man_limit%26cost1.png
prts.wiki/images/d/d2/Bskill_man_spd_variable11.png
prts.wiki/images/4/47/Bskill_man_limit%26cost1.png
prts.wiki/images/f/f8/Bskill_man_exp%26cost.png
prts.wiki/images/2/20/Bskill_man_originium2.png
prts.wiki/images/2/20/Bskill_man_originium2.png
prts.wiki/images/2/20/Bskill_man_originium2.png
prts.wiki/images/2/20/Bskill_man_originium2.png
prts.wiki/images/5/58/Bskill_man_originium1.png
prts.wiki/images/5/58/Bskill_man_originium1.png
prts.wiki/images/4/40/Bskill_man_cost_all.png
prts.wiki/images/6/64/Bskill_tra_Lappland1.png
prts.wiki/images/7/7d/Bskill_tra_Lappland2.png
prts.wiki/images/1/1c/Bskill_tra_texas1.png
prts.wiki/images/5/51/Bskill_tra_texas2.png
prts.wiki/images/2/2d/Bskill_tra_vodfox.png
prts.wiki/images/5/52/Bskill_tra_spd3.png
prts.wiki/images/2/21/Bskill_tra_spd_variable22.png
prts.wiki/images/a/a6/Bskill_tra_spd%26cost.png
prts.wiki/images/e/e0/Bskill_tra_spd%26limit7.png
prts.wiki/images/e/e0/Bskill_tra_spd%26limit7.png
prts.wiki/images/9/99/Bskill_tra_spd2.png
prts.wiki/images/9/99/Bskill_tra_spd2.png
prts.wiki/images/a/a1/Bskill_tra_spd%26limit6.png
prts.wiki/images/9/9d/Bskill_tra_spd_variable21.png
prts.wiki/images/b/b1/Bskill_tra_spd%26limit5.png
prts.wiki/images/c/cc/Bskill_tra_spd1.png
prts.wiki/images/c/cc/Bskill_tra_spd1.png
prts.wiki/images/c/cc/Bskill_tra_spd1.png
prts.wiki/images/2/2a/Bskill_tra_spd%26limit4.png
prts.wiki/images/2/24/Bskill_tra_spd%26limit3.png
prts.wiki/images/8/80/Bskill_tra_spd%26limit2.png
prts.wiki/images/7/7d/Bskill_tra_spd%26limit1.png
prts.wiki/images/3/34/Bskill_tra_flow_gs2.png
prts.wiki/images/f/fb/Bskill_tra_flow_gs1.png
prts.wiki/images/b/b6/Bskill_tra_flow_gc2.png
prts.wiki/images/0/0b/Bskill_tra_flow_gc1.png
prts.wiki/images/4/41/Bskill_tra_limit_diff.png
prts.wiki/images/c/c0/Bskill_tra_limit_count.png
prts.wiki/images/9/94/Bskill_tra_spd%26dorm2.png
prts.wiki/images/1/1f/Bskill_tra_spd%26dorm1.png
prts.wiki/images/2/21/Bskill_tra_wt%26cost2.png
prts.wiki/images/2/21/Bskill_tra_wt%26cost2.png
prts.wiki/images/9/92/Bskill_tra_wt%26cost1.png
prts.wiki/images/9/92/Bskill_tra_wt%26cost1.png
prts.wiki/images/f/fa/Bskill_tra_bd_n2.png
prts.wiki/images/9/90/Bskill_tra_long2.png
prts.wiki/images/9/94/Bskill_tra_long1.png
prts.wiki/images/4/49/Bskill_tra_limit%26cost.png
prts.wiki/images/f/f4/Bskill_dorm_all%26one2.png
prts.wiki/images/7/72/Bskill_dorm_all%26one1.png
prts.wiki/images/7/7b/Bskill_dorm_all3.png
prts.wiki/images/7/7b/Bskill_dorm_all3.png
prts.wiki/images/7/7b/Bskill_dorm_all3.png
prts.wiki/images/0/0f/Bskill_dorm_all2.png
prts.wiki/images/0/0f/Bskill_dorm_all2.png
prts.wiki/images/0/0f/Bskill_dorm_all2.png
prts.wiki/images/0/0f/Bskill_dorm_all2.png
prts.wiki/images/3/3d/Bskill_dorm_all%26one3.png
prts.wiki/images/3/3d/Bskill_dorm_all%26one3.png
prts.wiki/images/3/3d/Bskill_dorm_all%26one3.png
prts.wiki/images/2/2e/Bskill_dorm_all1.png
prts.wiki/images/1/18/Bskill_dorm_all%26bd_n1_n2.png
prts.wiki/images/9/92/Bskill_dorm_all%26bd_n1.png
prts.wiki/images/2/2e/Bskill_dorm_all1.png
prts.wiki/images/1/12/Bskill_dorm_single4.png
prts.wiki/images/d/dd/Bskill_dorm_single3.png
prts.wiki/images/d/dd/Bskill_dorm_single3.png
prts.wiki/images/d/dd/Bskill_dorm_single3.png
prts.wiki/images/1/13/Bskill_dorm_single2.png
prts.wiki/images/1/13/Bskill_dorm_single2.png
prts.wiki/images/7/7e/Bskill_dorm_single_schwarz.png
prts.wiki/images/2/24/Bskill_dorm_single_tomimi.png
prts.wiki/images/3/35/Bskill_dorm_single_indigo.png
prts.wiki/images/b/b7/Bskill_dorm_single1.png
prts.wiki/images/6/6d/Bskill_dorm_single%26one22.png
prts.wiki/images/6/6d/Bskill_dorm_single%26one22.png
prts.wiki/images/8/88/Bskill_dorm_single%26one21.png
prts.wiki/images/3/38/Bskill_dorm_single%26one12.png
prts.wiki/images/3/38/Bskill_dorm_single%26one12.png
prts.wiki/images/f/f0/Bskill_dorm_single%26one11.png
prts.wiki/images/8/85/Bskill_dorm_single%26one02.png
prts.wiki/images/c/cf/Bskill_dorm_single%26one01.png
prts.wiki/images/3/3a/Bskill_dorm_one5.png
prts.wiki/images/6/66/Bskill_dorm_one4.png
prts.wiki/images/6/66/Bskill_dorm_one4.png
prts.wiki/images/a/af/Bskill_dorm_one3.png
prts.wiki/images/5/55/Bskill_dorm_one.png
prts.wiki/images/a/a2/Bskill_dorm_one2.png
prts.wiki/images/9/90/Bskill_dorm_one1.png
prts.wiki/images/2/24/Bskill_ws_nian.png
prts.wiki/images/f/f5/Bskill_ws_evolve4.png
prts.wiki/images/7/78/Bskill_ws_evolve_dorm2.png
prts.wiki/images/1/18/Bskill_ws_evolve_dorm1.png
prts.wiki/images/2/28/Bskill_ws_bonus1.png
prts.wiki/images/0/01/Bskill_ws_bonus2.png
prts.wiki/images/9/9f/Bskill_ws_constant.png
prts.wiki/images/9/94/Bskill_ws_orirock.png
prts.wiki/images/e/ec/Bskill_ws_polyester.png
prts.wiki/images/f/f5/Bskill_ws_oriron.png
prts.wiki/images/4/40/Bskill_ws_device.png
prts.wiki/images/d/d4/Bskill_ws_evolve3.png
prts.wiki/images/d/d4/Bskill_ws_evolve3.png
prts.wiki/images/d/d4/Bskill_ws_evolve3.png
prts.wiki/images/b/b9/Bskill_ws_drop_oriron.png
prts.wiki/images/d/d4/Bskill_ws_evolve3.png
prts.wiki/images/d/d4/Bskill_ws_evolve3.png
prts.wiki/images/d/d4/Bskill_ws_evolve3.png
prts.wiki/images/5/55/Bskill_ws_evolve2.png
prts.wiki/images/5/55/Bskill_ws_evolve2.png
prts.wiki/images/5/55/Bskill_ws_evolve2.png
prts.wiki/images/5/55/Bskill_ws_evolve2.png
prts.wiki/images/1/1d/Bskill_ws_evolve_cost.png
prts.wiki/images/5/55/Bskill_ws_evolve2.png
prts.wiki/images/5/55/Bskill_ws_evolve2.png
prts.wiki/images/1/12/Bskill_ws_evolve1.png
prts.wiki/images/d/dc/Bskill_ws_cost_blemishine.png
prts.wiki/images/b/b1/Bskill_ws_free.png
prts.wiki/images/b/b8/Bskill_ws_build3.png
prts.wiki/images/2/20/Bskill_ws_build_cost2.png
prts.wiki/images/1/16/Bskill_ws_build2.png
prts.wiki/images/7/77/Bskill_ws_build_cost.png
prts.wiki/images/e/e3/Bskill_ws_build1.png
prts.wiki/images/f/f1/Bskill_ws_skill3.png
prts.wiki/images/f/f1/Bskill_ws_skill3.png
prts.wiki/images/c/c5/Bskill_ws_skill_cost1.png
prts.wiki/images/0/03/Bskill_ws_skill2.png
prts.wiki/images/3/33/Bskill_ws_skill1.png
prts.wiki/images/1/19/Bskill_ws_asc2.png
prts.wiki/images/9/91/Bskill_ws_asc_cost1.png
prts.wiki/images/d/dd/Bskill_ws_asc1.png
prts.wiki/images/2/28/Bskill_ws_p5.png
prts.wiki/images/8/8c/Bskill_ws_p4.png
prts.wiki/images/e/ec/Bskill_ws_p3.png
prts.wiki/images/e/ec/Bskill_ws_p3.png
prts.wiki/images/c/ca/Bskill_ws_p2.png
prts.wiki/images/0/0b/Bskill_ws_recovery.png
prts.wiki/images/c/ca/Bskill_ws_p2.png
prts.wiki/images/4/4a/Bskill_ws_cost_magallan.png
prts.wiki/images/c/ca/Bskill_ws_p2.png
prts.wiki/images/0/02/Bskill_ws_frost.png
prts.wiki/images/3/3f/Bskill_ws_p1.png
prts.wiki/images/7/74/Bskill_ws_evolve_cost2.png
prts.wiki/images/9/90/Bskill_ws_evolve_cost1.png
prts.wiki/images/9/90/Bskill_ws_evolve_cost1.png
prts.wiki/images/2/25/Bskill_hire_skgoat.png
prts.wiki/images/2/2d/Bskill_hire_spd5.png
prts.wiki/images/0/01/Bskill_hire_spd4.png
prts.wiki/images/0/01/Bskill_hire_spd4.png
prts.wiki/images/0/01/Bskill_hire_spd4.png
prts.wiki/images/a/ad/Bskill_hire_spd%26clue.png
prts.wiki/images/a/ad/Bskill_hire_spd%26clue.png
prts.wiki/images/8/82/Bskill_hire_spd2.png
prts.wiki/images/4/44/Bskill_hire_spd%26ursus2.png
prts.wiki/images/c/ce/Bskill_hire_spd%26blacksteel2.png
prts.wiki/images/a/a5/Bskill_hire_spd_bd_n1_n1.png
prts.wiki/images/8/80/Bskill_hire_spd_memento.png
prts.wiki/images/c/ca/Bskill_hire_spd%26cost2.png
prts.wiki/images/d/da/Bskill_hire_spd_bd_n2.png
prts.wiki/images/b/bc/Bskill_hire_blitz.png
prts.wiki/images/2/23/Bskill_hire_spd1.png
prts.wiki/images/b/b6/Bskill_hire_spd%26cost1.png
prts.wiki/images/c/c5/Bskill_train1_vanguard1.png
prts.wiki/images/1/1a/Bskill_train_vanguard3.png
prts.wiki/images/2/28/Bskill_train_vanguard2.png
prts.wiki/images/2/2f/Bskill_train_vanguard1.png
prts.wiki/images/d/df/Bskill_train3_guard1.png
prts.wiki/images/e/e4/Bskill_train2_guard1.png
prts.wiki/images/a/a2/Bskill_train1_guard1.png
prts.wiki/images/8/8c/Bskill_train_guard3.png
prts.wiki/images/b/b7/Bskill_train_guard2.png
prts.wiki/images/9/96/Bskill_train_guard1.png
prts.wiki/images/6/6c/Bskill_train_artsprotector.png
prts.wiki/images/9/90/Bskill_train2_defender1.png
prts.wiki/images/1/19/Bskill_train1_defender1.png
prts.wiki/images/8/87/Bskill_train_defender3.png
prts.wiki/images/0/0e/Bskill_train_defender2.png
prts.wiki/images/9/9e/Bskill_train_defender1.png
prts.wiki/images/c/ce/Bskill_train_fastshot.png
prts.wiki/images/9/95/Bskill_train3_sniper2.png
prts.wiki/images/c/cb/Bskill_train_w.png
prts.wiki/images/3/3e/Bskill_train1_sniper2.png
prts.wiki/images/6/62/Bskill_train_sniper3.png
prts.wiki/images/9/96/Bskill_train_sniper2.png
prts.wiki/images/1/14/Bskill_train_sniper1.png
prts.wiki/images/f/f2/Bskill_train2_caster1.png
prts.wiki/images/7/79/Bskill_train_caster3.png
prts.wiki/images/a/ad/Bskill_train1_caster1.png
prts.wiki/images/3/38/Bskill_train_caster2.png
prts.wiki/images/c/c2/Bskill_train_caster1.png
prts.wiki/images/e/e8/Bskill_train3_supporter2.png
prts.wiki/images/a/a6/Bskill_train_chen.png
prts.wiki/images/7/72/Bskill_train_skadi.png
prts.wiki/images/5/58/Bskill_train_supporter3.png
prts.wiki/images/b/b6/Bskill_train_supporter2.png
prts.wiki/images/1/1c/Bskill_train_supporter1.png
prts.wiki/images/0/02/Bskill_train_medic3.png
prts.wiki/images/1/18/Bskill_train_medic2.png
prts.wiki/images/d/d8/Bskill_train_medic1.png
prts.wiki/images/3/38/Bskill_train1_specialist1.png
prts.wiki/images/9/9b/Bskill_train_specialist3.png
prts.wiki/images/8/86/Bskill_train_specialist2.png
prts.wiki/images/9/9b/Bskill_train_specialist1.png
prts.wiki/images/1/16/Bskill_train_all.png
prts.wiki/images/d/d8/Bskill_train_knight_bd1.png
prts.wiki/images/7/73/Bskill_train_knight_bd2.png
prts.wiki/images/2/21/Bskill_meet_rhodes2.png
prts.wiki/images/4/4e/Bskill_meet_rhodes1.png
prts.wiki/images/c/ce/Bskill_meet_flag_rhodes.png
prts.wiki/images/0/0c/Bskill_meet_kjerag2.png
prts.wiki/images/0/0c/Bskill_meet_kjerag2.png
prts.wiki/images/a/a2/Bskill_meet_flag_kjerag.png
prts.wiki/images/b/b8/Bskill_meet_glasgow2.png
prts.wiki/images/b/b8/Bskill_meet_glasgow2.png
prts.wiki/images/d/db/Bskill_meet_glasgow1.png
prts.wiki/images/9/90/Bskill_meet_flag_glasgow.png
prts.wiki/images/5/5c/Bskill_meet_ursus2.png
prts.wiki/images/2/26/Bskill_meet_ursus1.png
prts.wiki/images/1/1a/Bskill_meet_flag_ursus.png
prts.wiki/images/e/e6/Bskill_meet_blacksteel2.png
prts.wiki/images/e/e6/Bskill_meet_blacksteel2.png
prts.wiki/images/2/2f/Bskill_meet_penguin2.png
prts.wiki/images/d/d4/Bskill_meet_penguin1.png
prts.wiki/images/5/5c/Bskill_meet_rhine2.png
prts.wiki/images/a/a3/Bskill_meet_flag_rhine.png
prts.wiki/images/e/e8/Bskill_meet_spd3.png
prts.wiki/images/e/e8/Bskill_meet_spd3.png
prts.wiki/images/e/e8/Bskill_meet_spd3.png
prts.wiki/images/e/e8/Bskill_meet_spd3.png
prts.wiki/images/d/d9/Bskill_meet_spd2.png
prts.wiki/images/a/a0/Bskill_meet_spd1.png
"
    rm -rf png
    rm -rf png_noalpha
    rm -rf release/skill.zip
    mkdir -p png
    cd png
    xargs -I % -P 100 curl -sSLO % <<<"$a"
    cd ..
    noalpha png png_noalpha
    touch png_noalpha/.nomedia
    zip release/skill.zip -q -r -j png_noalpha
    local md5=$(md5sum release/skill.zip | cut -d' ' -f1)
    echo $md5 >release/skill.zip.md5
  }
  "$@"
  wait
}
