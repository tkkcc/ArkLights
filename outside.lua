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
  exit()
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
  exit()
end

function goto_bilibili()
  local bv = "BV1DL411t7n2"
  runWeb("https://bilibili.com/video/" .. bv)
  exit()
end

function goto_github()
  local github = "tkkcc/arknights"
  runWeb("https://github.com/" .. github)
  exit()
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
-- exit()
-- end
require('util')
function show_gesture_capture_ui()
  home()
  local ui = {
    name = 'main',
    title = "停止录制",
    views = {
      {
        type = 'text',
        value = [[有锁屏手势或密码的手机，在熄屏状态下运行脚本时，]] ..
          [[脚本首先需要亮屏解锁（需root授权），解锁方式与关键点需设置：
1. 点击 手势路径关键点 或 密码数字及确认键
2. 点击标题停止录制
3. 选择解锁方式
4. 点击“保存”
]],
      }, {
        type = 'div',
        views = {
          {type = "text", value = "解锁方式"},
          {
            type = 'radio',
            value = '*手势|密码',
            id = 'unlock_mode',
            ore = 1,
          },
        },
      },
    },
    submit = {type = "text", value = "保存"},
    cancle = {type = "text", value = "退出"},
  }
  updateUI(ui)
  local title = R():text(ui.title)
  if not appear(title) then stop("85") end
  local bottom = find(title).rect.bottom

  local finger = {}
  for i = 1, 20 do
    local p = catchClick()
    if not p then break end
    if p.y < bottom then break end
    table.insert(finger, {p.x, p.y})
  end
  save('unlock_gesture', JsonEncode(finger))
end

function show_multi_account_ui()
  home()
  local ui = {
    name = 'main',
    title = "多账号",
    submit = {type = "text", value = "保存"},
    cancle = {type = "text", value = "退出"},
    views = {},
  }
  for i = 1, 20 do
    table.insert(ui.views,
                 {type = 'edit', title = '账号' .. i, id = 'username' .. i})
    table.insert(ui.views,
                 {type = 'edit', title = '密码' .. i, id = 'password' .. i})
    table.insert(ui.views, {
      type = 'div',
      views = {
        {type = 'text', value = '服务器'..i},
        {type = 'radio', value = '官服|B服|*不启用', id = 'server' .. i,ore=1},

      },
    })
  end
  updateUI(ui)
end
