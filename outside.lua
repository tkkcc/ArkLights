require('util')
log("outside")
function goto_qqgroup()
  local qq = "1009619697"
  local key = "KlYYiyXj2VRJg1qNqRo3tExo959SrKhT"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3D" ..
      key,
  }
  runIntent(intent)
  -- intent.setData(Uri.parse("mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3D" + key));

  putClipboard(qq)
  toast("群号已复制：" .. qq)
  -- runWeb("https://qm.qq.com/cgi-bin/qm/qr?k=esG3bPL_Du3klWdo-JJpqQ8ra2uY3Olp&jump_from=webapi")
  safeexit()
end
function goto_qq()
  local qq = "605597237"
  local intent = {
    action = "android.intent.action.VIEW",
    uri = "mqqwpa://im/chat?chat_type=wpa&uin=" .. qq,
  }
  runIntent(intent)
  putClipboard(qq)
  toast("QQ号已复制：" .. qq)
  safeexit()
end

function goto_bilibili()
  local bv = "BV1DL411t7n2"
  runWeb("https://bilibili.com/video/" .. bv)
  safeexit()
end

function goto_github()
  local github = "tkkcc/arknights"
  runWeb("https://github.com/" .. github)
  safeexit()
end

function preload()
  -- ocr initialization needs 5 seconds
  -- ocr font need downlaod
  pcall(ocr, 0, 0, 1, 1)
  print("preload finish")
end

-- require('util')
-- function capture_screen_on_gesture() capture_screen_on_password(true) end
-- function capture_screen_on_password(swip_mode)

-- local finger = {}
-- local idle_start_time = time()
-- -- TODO 怎么实现一个
-- wait(function()
--   local p = catchClick()
--   table.insert(finger, {p.x, p.y})
-- end)
-- save("screen_on_swip_mode", "true")
-- print(get("screen_on_swip_mode"))
-- safeexit()
-- end
function show_gesture_capture_ui()
  home()
  local ui = {
    name = 'main',
    title = "停止录制",
    views = {
      {
        type = 'div',
        views = {
          {
            type = 'text',
            value = [[有锁屏手势或密码的手机，在熄屏状态下运行脚本时，]] ..
              [[脚本首先需要亮屏解锁（需root授权），关键点与解锁方式在本界面设置。另外xposed edge pro也可实现亮屏解锁。]],
          },
        },
      }, {
        type = 'div',
        views = {
          {type = "text", value = "1. 先阅读以下说明，再点击"}, {
            type = 'button',
            value = '开始录制',
            click = {thread = 0, name = "capture_gesture"},
          },
        },
      }, {
        type = 'div',
        views = {
          {
            type = "text",
            value = "2. 点击 手势路径关键点 或 密码数字及确认键",
          },
        },
      }, {
        type = 'div',
        views = {{type = "text", value = "3. 点击标题“停止录制”"}},
      }, {
        type = 'div',
        views = {
          {type = "text", value = "4. 选择解锁方式"},
          {
            type = 'radio',
            value = '*手势|密码',
            id = 'unlock_mode',
            ore = 1,
          },
        },
      }, {
        type = 'div',
        views = {
          {
            type = "text",
            value = [[5. 点击“保存”回到脚本主界面，然后测试。

快速测试：脚本主界面按“启动”，然后手动熄屏，5秒内应观察到亮屏解锁现象。

完整测试：设置定时1分钟后运行脚本，然后手动熄屏，1分钟后可能观察到亮屏不解锁现象，再等1分钟后应观察到亮屏解锁现象。
]],
          },
        },
      },
    },
    submit = {type = "text", value = "保存"},
    cancle = {type = "text", value = "退出"},
  }
  updateUI(ui)
end

function capture_gesture()
  local title = R():text("停止录制")
  if not appear(title) then stop("85") end
  local bottom = find(title).rect.bottom

  local finger = {}
  for _ = 1, 20 do
    local p = catchClick()
    if not p then break end
    if p.y < bottom then break end
    table.insert(finger, {p.x, p.y})
  end
  save('unlock_gesture', JsonEncode(finger))
end

function show_multi_account_ui()
  home()
  updateUI(make_multi_account_setting_ui())
end

for i = 1, 20 do
  _G["multi_account_new_setting" .. i] = function()
    local newstate = 1 - get("multi_account_new_setting" .. i, 0)
    if newstate == 0 then log(i, 194) end
    save("multi_account_new_setting" .. i, newstate)
    return show_multi_account_ui()
  end
end

