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
    local start=$(date -u +"%s.%N")
    local cur
    while :; do
      cur=$(date -u +"%s.%N")
      printf "\r$(date -u -d "0 $cur seconds - $start seconds" +"%H:%M:%S")"
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

  "$@"
  wait
}
