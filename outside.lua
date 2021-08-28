function goto_qq()
  local qq = "1009619697"
  putClipboard(qq)
  toast("群号已复制：" .. qq)
  runWeb(
    "https://qm.qq.com/cgi-bin/qm/qr?k=esG3bPL_Du3klWdo-JJpqQ8ra2uY3Olp&jump_from=webapi")
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

-- function miui_hook()
--   local miui = R():text("立即开始")
--   wait(function()
--     if getColor(0, 0) then return true end
--     wait(function() click(miui) end, 10)
--   end, 30)
-- end
