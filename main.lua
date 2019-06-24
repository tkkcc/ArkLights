init("0", 1)
setScreenScale(1080, 1920)
require("path")
require("util")
local Url = require("socket.url")
local Json = require("JSON")
local Socket = require("socket.socket")
local html = require("html")
local server = assert(Socket.bind("127.0.0.1", 0))
local ip, port = server:getsockname()
-- runtime.openURL('http://127.0.0.1:'..port)
-- v1.9
runApp("com.android.browser")
sleep(2)
touchDown(0, 600, 150)
sleep(0.2)
touchUp(0, 600, 150)
sleep(.5)
inputText('http://127.0.0.1:' .. port .. "#ENTER#")

while 1 do
  local client = server:accept()
  client:settimeout(10)
  local request, err = client:receive()
  if request:startsWith('POST') then
    config = Json:decode(Url.unescape(request:sub(7)))
    break
  else
    client:send(html)
    client:close()
  end
end
-- fetch(window.location.href+JSON.stringify({基建:["收取信用","线索布置"]}),{method:'post'})
log(config.基建)
lua_exit()

cron = require("crontab")
基建 = {"换人", "戳人", "制造站补充", "订单交付", "订单加速",
          "线索接收", "线索布置", "信用奖励"}
作战 = {"邮件", "轮次作战"}
任务 = {"访问好友基建", "信用收取", "信用购买", "干员强化",
          "任务"}
show("开始")
fight_type = {"3-2", "2-10", "PR-A-1", "PR-A-2", "PR-B-1", "PR-B-2", "PR-C-1",
              "PR-C-2", "PR-D-1", "PR-D-2"}
table.insert(fight_type, "CE-5")
repeat_last(fight_type, 10)
table.insert(fight_type, "SK-5")
repeat_last(fight_type, 10)
fight_type = {'龙门外环', '切尔诺伯格'}
fight_type = fight_type_all

-- now(作战,基建, 任务, background)
cron.cron(map(hc, {{作战, "2,8,14,20"}, {基建, "2,14"}, {任务, 3},
                   {background}, {showBL}}), true)
