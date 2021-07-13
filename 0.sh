#!/usr/bin/env bash
{
  stop() {
    local dst=${1:-192.168.0.30}
    echo ==\> stop
    curl http://$dst:9090/script/stop \
      --data-raw 'name=stop'
  }
  run() {
    stop
    local dst=${1:-192.168.0.30}
    for x in *.lua; do
      echo ==\> upload "$x"
      curl http://$dst:9090/api/file/save \
        --data-urlencode code="$(cat "$x")" \
        --data-urlencode path=/storage/emulated/0/freespace/scripts/test/"$x"
    done
    wait

    echo ==\> run
    curl http://$dst:9090/script/run \
      --data-urlencode code="$(cat main.lua)" \
      --data-urlencode name=test \
      --data-urlencode path=/storage/emulated/0/freespace/scripts/test/main.lua
  }
  listen() {
    local dst=${1:-192.168.0.30}
    websocat ws://$dst:9095
  }
  "$@"
}
