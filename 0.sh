#!/usr/bin/env bash
{

  declare -A default
  default[dst]=q1
  restartcolor() {
    # 重启节点精灵，以适应分辨率变更
    adb shell am force-stop com.aojoy.aplug
    #adb shell monkey -p com.aojoy.aplug -c android.intent.category.LAUNCHER 1
    sleep 1
    adb shell settings put secure enabled_accessibility_services com.aojoy.aplug/com.aojoy.server.CmdAccessibilityService
    sleep 2
    #adb shell am start com.hypergryph.arknights
    adb shell input keyevent KEYCODE_APP_SWITCH
    adb shell input keyevent KEYCODE_APP_SWITCH
    #adb shell monkey -p com.hypergryph.arknights -c android.intent.category.LAUNCHER 1
    sleep 2
  }
  stop() {
    local dst=${1:-${default[dst]}}
    echo ==\> stop
    curl http://$dst:9090/script/stop \
      --data-raw 'name=stop'
  }
  save() {
    local dst=${1:-${default[dst]}}
    for x in *.lua; do
      echo ==\> upload "$x"
      curl -sS http://$dst:9090/api/file/save \
        --data-urlencode code="$(cat "$x")" \
        --data-urlencode path=/storage/emulated/0/freespace/scripts/test/"$x" >/dev/null
    done
  }
  find() {
    # 测试不同分辨率下脚本结果
    local option=(
      2400x1080
      1280x720
      #1024x720
      #2400x720
      1920x1080
    )
    if [[ -n $1 ]]; then
      option=(${option[$1]})
      shift
    fi
    for ((i = 0; i < ${#option[@]}; ++i)); do
      adb shell wm size ${option[$i]}
      restartcolor
      if [[ $i -eq 0 ]]; then
        save "$@"
      fi
      run "$@"
    done
  }
  run() {
    local dst=${1:-${default[dst]}}
    listen &
    echo ==\> run
    curl -sS http://$dst:9090/script/run \
      --data-urlencode name=test \
      --data-urlencode code= \
      --data-urlencode path=/storage/emulated/0/freespace/scripts/test/placeholder.lua >/dev/null
  }
  saverun() {
    stop "$@"
    save "$@"
    run "$@"
  }
  listen() {
    local dst=${1:-${default[dst]}}
    websocat -n ws://$dst:9095
  }
  "$@"
  wait
}
