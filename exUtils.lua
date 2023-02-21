-- ===========================================
--          额外工具类函数
-- 请所有贡献者在此处添加额外需要的函数
-- 
-- 函数命名规范推荐
--  1. 工具 --> 小驼峰
--  2. 类path函数 --> 下划线
--  3. 禁止重载utils.lua中已有的函数，避免污染
-- 
-- 函数注解
--  请在函数上方添加注解，尽可能的说明函数用途
-- ===========================================


-- 以字符串格式找色
findOneStr = function(x, confidence)
    -- 每5秒确认游戏在前台
    -- if (time() - findOne_game_up_check_last_time > 5000) then
    --     findOne_game_up_check_last_time = time()
    --     wait_game_up()
    -- end

    confidence = confidence or default_findcolor_confidence

    if type(x) == "string" then

        -- 控制截图频率
        local current = time()
        if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
            findOne_last_time = time()
            keepCapture()
        end

        local pos

        if cmpColorEx(x, confidence) == 1 then
            pos = { str2int(x:match("^(%d+)|"), 0), str2int(x:match("^%d+|(%d+)|"), 0) }
        end

        return pos
    end
end

-- 单点找色
checkPointColor = function(pInfo, confidence)

    -- 每5秒确认游戏在前台
    -- if (time() - findOne_game_up_check_last_time > 5000) then
    --     findOne_game_up_check_last_time = time()
    --     wait_game_up()
    -- end

    confidence = confidence or default_findcolor_confidence

    -- 控制截图频率
    local current = time()
    if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
        findOne_last_time = time()
        keepCapture()
    end

    local colorStr = pInfo[1] .. "|" .. pInfo[2] .. "|" .. pInfo[3]

    -- 比色
    if cmpColorEx(colorStr, confidence) == 1 then
        return true
    else
        return false
    end
end

-- 等待单点颜色出现
waitUntilFindColor = function(pInfo, time)
    local time = time or 5
    return wait(function()
        if checkPointColor(pInfo) then
            return true
        end
    end, time)
end

-- 持续点击直到找到指定颜色
tapUntilCheckedPointColor = function(pTap, pInfo, msg, sleep, time)
    log(msg)
    local sleep = sleep or 0
    local time = time or 5
    if wait(function()
        if checkPointColor(pInfo) then
            log(msg, "成功")
            return true
        end
        tap({ pTap[1], pTap[2] })
        ssleep(sleep)
    end, time) then
        return true
    else
        log("持续点击直到找到指定颜色失败")
        return false
    end
end

doIfCheckedColor = function(pInfo, func, time)
    time = time or 15
    if checkPointColor(pInfo) then
        wait(function()
            return func()
        end, time)
    end
end

tapIfCheckedColor = function(pTap, pInfo)
    doIfCheckedColor(pInfo,
        function()
            tap({ pTap[1], pTap[2] })
            return true
        end)
end

-- 新deploy3 原deploy3有计算bug
-- src: 从右数第几个干员
-- dst: 目标位置，格式{x,y,direction} direction: 上1 右2 下3 左4
-- total: 当前有几个干员，不同干员数影响干员位置
nDeploy3 = function(src, dst, total)
    total = total or 1
    local max_op_width = scale(178) --  in loose mode, each operator's width
    local x1
    if total * max_op_width > screen.width then
        -- tight
        max_op_width = screen.width // total
        x1 = src * max_op_width - max_op_width // 2
    else
        -- loose
        -- x1 = screen.width - (total - src) * max_op_width - max_op_width // 2
        x1 = screen.width - src * max_op_width + max_op_width // 2
    end
    deploy(x1, dst[1], dst[2], dst[3])
end

-- 合并至主分支后已弃用
-- show_extra_ui = function()
--     local layout = "extra"
--     saveConfig('last_layout', layout)

--     ui.newLayout(layout, ui_page_width, -2)

--     make_ui_title(layout, "其他功能")

--     newRow(layout)

--     addButton(layout, nil, "返回", make_jump_ui_command(layout, "main"), nil,
--         nil)
--     -- ui.addButton(layout, layout .. "_stop", "返回")
--     -- ui.setBackground(layout .. "_stop", ui_cancel_color)
--     -- ui.setOnClick(layout .. "_stop", make_jump_ui_command(layout, "main"))

--     -- make_continue_extra_ui(layout)

--     -- {nil, "退出", make_jump_ui_command(layout, nil, "peaceExit()")}, {
--     --   readme_btn, "必读", make_jump_ui_command(layout, nil,
--     --                                              "saveConfig('readme_already_read','1');jump_readme()"),
--     -- }, {nil, "高级设置", make_jump_ui_command(layout, "debug")},

--     newRow(layout)
--     addTextView(layout, [[以下功能将沿用脚本主页设置]])

--     newRow(layout)
--     addButton(layout, nil, "傀影与猩红孤钻",
--         make_jump_ui_command(layout, nil,
--             "extra_mode='傀影与猩红孤钻自动上号';lock:remove(main_ui_lock)"))
--     addButton(layout, nil, "水月与深蓝之树",
--         make_jump_ui_command(layout, nil,
--             "extra_mode='水月与深蓝之树自动上号';lock:remove(main_ui_lock)"))
--     addButton(layout, nil, "生息演算",
--         make_jump_ui_command(layout, nil,
--             "extra_mode='生息演算沙中之火自动上号';lock:remove(main_ui_lock)"))

--     newRow(layout)
--     addTextView(layout, [[账号]])
--     ui.addEditText(layout, "rogue_account", [[]])
--     addTextView(layout, [[ 密码]])
--     ui.addEditText(layout, "rogue_password", [[]])
--     ui.addCheckBox(layout, "rogue_server", "是B服", false)
--     newRow(layout)
--     addTextView(layout, [[选第]])
--     ui.addEditText(layout, "zl_best_operator", [[-1]])
--     addTextView(layout, [[个近卫 开]])
--     ui.addEditText(layout, "zl_skill_times", [[0]])
--     addTextView(layout, [[次]])
--     ui.addEditText(layout, "zl_skill_idx", [[1]])
--     addTextView(layout, [[技能]])

--     newRow(layout)
--     ui.addCheckBox(layout, "zl_more_repertoire", "多点剧目", false)
--     ui.addCheckBox(layout, "zl_more_experience", "升级等级", true)
--     ui.addCheckBox(layout, "zl_skip_coin", "跳过投币", false)

--     newRow(layout)
--     ui.addCheckBox(layout, "zl_accept_mg", "可打敏感", false)
--     ui.addCheckBox(layout, "zl_accept_yx", "可打臆想", false)
--     ui.addCheckBox(layout, "zl_accept_sc", "可打生存", false)

--     newRow(layout)
--     ui.addCheckBox(layout, "zl_skip_hard", "不打驯兽", false)
--     ui.addCheckBox(layout, "zl_no_waste", "每8小时做日常", true)

--     -- ui.addSpinner(layout, "zl_hard_level", {"观光", "正式"}, 0)

--     newRow(layout)
--     addTextView(layout, [[需求商品]])
--     ui.addEditText(layout, "zl_need_goods", [[]])
--     addTextView(layout, [[等级]])
--     ui.addEditText(layout, "zl_max_level", [[]])
--     addTextView(layout, [[源石锭]])
--     ui.addEditText(layout, "zl_max_coin", [[]])

--     -- ui.addCheckBox(layout, "zl_disable_game_up_check", "禁用前台检查", false)
--     -- newRow(layout)
--     -- addTextView(layout, [[重启间隔(秒)]])
--     -- ui.addEditText(layout, "zl_restart_interval", [[]])

--     -- newRow(layout)
--     -- addTextView(layout,
--     --             [[用于刷源石锭投资、等级(蜡烛)、藏品、剧目等。应选择常见5、6星近卫，临光1、煌2、山2、羽毛笔1、帕拉斯1、赫拉格2、史尔特尔2、银灰1、幽灵鲨1、拉狗2，更多干员测试见群精华消息。]] ..
--     --   [[刷源石锭应选“观光难度”，不勾“多点蜡烛”、“跳过投币”]]
--     --               [[支持凌晨4点数据更新、支持掉线抢登情况、支持每8小时做日常。支持16:9及以上分辨率，但建议16:9，否则可能选不到后勤队。]] ..
--     --               [[游戏本体存在内存泄漏，因此会抽空重启。如果1小时内就出现脚本停止运行、随机界面卡住、悬浮按钮消失，应把“高级设置”中两个3600重启间隔调小(如900)。]] ..
--     --               [[999源石锭刷取耗时与难度、幕后筹备无关，与是否通关三结局、网络延迟有关，双结局耗时10时14分(97个/时)，三结局耗时8时10分(122个/时)，低网络延迟+三结局耗时7时21分(135个/时)。]] ..
--     --               [[如需刷等级(蜡烛)，应选普通难度，勾“多点蜡烛”与“跳过投币”。]] ..
--     --               [[商品需求可填商品名称关键字，用空格隔开(如填“玩 金 骑士”)，则刷到其中任一商品就会停止并通知QQ]])
--     --
--     -- ui.(layout, layout .. "_invest", "集成战略前瞻性投资")
--     -- ui.setOnClick(layout .. "_invest", make_jump_ui_command(layout, nil,
--     --                                                         "extra_mode='前瞻投资';lock:remove(main_ui_lock)"))

--     newRow(layout)
--     addButton(layout, layout .. "_recruit", "公开招募加急",
--         make_jump_ui_command(layout, nil,
--             "extra_mode='公开招募加急';lock:remove(main_ui_lock)"))
--     addTextView(layout, [[保留标签]])
--     ui.addEditText(layout, layout .. "_recruit_important_tag", [[]])
--     -- newRow(layout)
--     -- addTextView(layout,
--     --             [[用于刷黄绿票，或刷出指定标签。使用加急券在第一个公招位反复执行“公开招募”任务，沿用脚本主页的“自动招募”设置。“自动招募”只勾“其他”时，刷出保底标签就停；只勾“其他”、“4”时，刷出保底小车、保底5星、资深就停；其余同理。如果想刷到指定标签就停，则“保留标签”填期望标签（例如填“削弱 快速复活”）。]])

--     -- newRow(layout)
--     -- addButton(layout, layout .. "_hd2_shop", "遗尘漫步任务与商店",
--     --           make_jump_ui_command(layout, nil,
--     --                                "extra_mode='活动任务与商店';lock:remove(main_ui_lock)"))
--     --
--     -- addButton(layout, layout .. "_hd2_shop_multi",
--     --           "遗尘漫步任务与商店多号",
--     --           make_jump_ui_command(layout, nil,
--     --                                "extra_mode='活动任务与商店';extra_mode_multi=true;lock:remove(main_ui_lock)"))

--     -- newRow(layout)
--     -- addButton(layout, layout .. "_hd3_shop", "吾导先路任务与商店",
--     --           make_jump_ui_command(layout, nil,
--     --                                "extra_mode='活动2任务与商店';lock:remove(main_ui_lock)"))
--     --
--     -- addButton(layout, layout .. "_hd3_shop_multi",
--     --           "吾导先路任务与商店多号",
--     --           make_jump_ui_command(layout, nil,
--     --                                "extra_mode='活动2任务与商店';extra_mode_multi=true;lock:remove(main_ui_lock)"))

--     -- newRow(layout)
--     -- addButton(layout, layout .. "_speedrun", "每日任务速通（待修）",
--     --           make_jump_ui_command(layout, nil,
--     --                                "extra_mode='每日任务速通';lock:remove(main_ui_lock)"))

--     -- ui.setOnClick(layout .. "_speedrun", )
--     -- addButton(layout, layout .. "jump_qq_btn", "需加机器人好友",
--     --           make_jump_ui_command(layout, nil, 'jump_qq()'))
--     -- newRow(layout)
--     -- ui.addButton(layout, layout .. "_speedrun", "每日任务速通（别用）")
--     -- ui.setOnClick(layout .. "_speedrun", make_jump_ui_command(layout, nil,
--     --                                                           "extra_mode='每日任务速通';lock:remove(main_ui_lock)"))
--     --

--     -- newRow(layout)
--     -- ui.addButton(layout, layout .. "_1-12", "克洛丝单人1-12（没写）")
--     -- ui.setOnClick(layout .. "_1-12", make_jump_ui_command(layout, nil,
--     --                                                       "extra_mode='克洛丝单人1-12';lock:remove(main_ui_lock)"))

--     ui.loadProfile(getUIConfigPath(layout))
--     ui.show(layout, false)
-- end

-- 沙中之火 导航
sandfire_navigation = function()
    log("沙中之火 导航")
    -- if not checkPointColor(sandfire_point.奖励) and not checkPointColor(sandfire_point.进入演算开启状态) then

    -- end
    path.跳转("首页")

    tap(global_point.活动1)
    if not appear("主页") then return false end

    if not tapUntilCheckedPointColor(global_point.面板主活动, sandfire_point.奖励) then return false end

    if not checkPointColor(sandfire_point.进入演算开启状态) then return false end

    return true
end

-- 沙中之火 检查放弃
sandfire_check_giveup = function()
    waitUntilFindColor(sandfire_point.进入演算开启状态)
    ssleep(0.5)
    log("沙中之火 检查放弃")
    if checkPointColor(sandfire_point.放弃区域) then
        log("需要放弃")
        wait(function()
            if not checkPointColor(sandfire_point.放弃快进) then
                tap({ sandfire_point.放弃区域[1], sandfire_point.放弃区域[2] })
                tap(sandfire_point.放弃确认)
            else
                log("沙中之火 放弃完成")
                tap({ sandfire_point.放弃快进[1], sandfire_point.放弃快进[2] })
                if checkPointColor(sandfire_point.进入演算开启状态) then
                    return true
                end
            end
        end, 5)
    else
        log("沙中之火 检查放弃完成")
        if checkPointColor(sandfire_point.进入演算开启状态) then
            return true
        end
    end
end

-- 沙中之火 编队初始化
sandfire_init_fight_group = function()
    log("等待初始化干员")
    tapUntilCheckedPointColor(sandfire_point.进入演算, sandfire_point.初始化选择干员, "等待初始化干员"
        , 0.1)
    tapUntilCheckedPointColor(sandfire_point.初始化选择干员, sandfire_point.干员卡空白区域4)
    log("选择第一个干员")
    tapUntilCheckedPointColor(sandfire_point.干员卡空白区域1, sandfire_point.干员卡技能白条, "选择干员"
        , 0.1)
    log("选择确认")
    tapUntilCheckedPointColor(sandfire_point.干员选择确认, sandfire_point.干员卡外部区域1)
    log("全队补充")
    tapUntilCheckedPointColor(sandfire_point.全队补充, sandfire_point.退出, "全队补充", 0.1, 30)
    waitUntilFindColor(sandfire_point.退出)
    log("初始化完成")
end

-- 沙中之火 缩放地图
sandfir_zoom_map = function()
    showControlBar(false)
    tapUntilCheckedPointColor(sandfire_point.缩放地图, sandfire_point.缩放地图进度, "缩放地图", 0.2, 10)
    showControlBar(true)
end

-- 沙中之火 进入作战
sandfir_enter_fight = function()
    sandfir_zoom_map()
    if not wait(function()
        return tapUntilCheckedPointColor(sandfire_point.作战关卡, sandfire_point.作战信息, "选择作战", 0.3)
    end, 5) then
        -- exit()
        return false
    end
    return true
end

-- 沙中之火 关卡内作战（退出）
sandfir_fight = function()
    if not sandfir_enter_fight() then
        return false
    end

    tapUntilCheckedPointColor(sandfire_point.作战开始, sandfire_point.开始行动)
    tapUntilCheckedPointColor(sandfire_point.开始行动, sandfire_point.作战暂停, "等待作战暂停出现", 0.3,
        30)
    tapUntilCheckedPointColor(sandfire_point.作战暂停, sandfire_point.作战已暂停, "按出暂停", 0.3, 10)
    tapUntilCheckedPointColor(sandfire_point.离开作战, sandfire_point.确认离开, "按出离开", 0.3, 10)
    -- if not wait(function()
    --     tap(sandfire_point.离开作战)
    --     ssleep(0.3)
    --     if checkPointColor(sandfire_point.确认离开) and checkPointColor(sandfire_point.取消确认离开)
    --         and checkPointColor(sandfire_point.离开当前区域) then
    --         return true
    --     end
    -- end, 10) then
    --     -- exit()
    --     return false
    -- end
    tapUntilCheckedPointColor(sandfire_point.确认离开, sandfire_point.行动结束)
    tapUntilCheckedPointColor(sandfire_point.结算空白区域, sandfire_point.驻扎地)
    return sandfir_next()
end

-- 沙中之火 下一天
sandfir_next = function()
    if not wait(function()
        if checkPointColor(sandfire_point.跳过) then
            tap({ sandfire_point.跳过[1], sandfire_point.跳过[2] })
        end
        if checkPointColor(sandfire_point.取消进入下一关) then
            tap({ sandfire_point.取消进入下一关[1], sandfire_point.取消进入下一关[2] })
        end
        if checkPointColor(sandfire_point.驻扎地) then
            return true
        end
    end, 10) then return false end
    if checkPointColor(sandfire_point.下一天紧急) then
        return true
    end
    if checkPointColor(sandfire_point.下一天激活) then
        tapUntilCheckedPointColor(sandfire_point.下一天, sandfire_point.下一天未激活, "进入下一天", 0.1, 30)
        local jumpout = false
        wait(function()
            tap(sandfire_point.下一天)
            if checkPointColor(sandfire_point.下一天紧急) then
                jumpout = true
                return true
            end
            if checkPointColor(sandfire_point.取消进入下一关) then
                return true
            end
        end, 30)
        if jumpout then
            return true
        end
        -- tapUntilCheckedPointColor(sandfire_point.下一天, sandfire_point.取消进入下一关, "点出下一天取消确认"
        --     , 0.3, 30)
        tapUntilCheckedPointColor(sandfire_point.取消进入下一关, sandfire_point.退出, "取消下一天", 0.3, 5)
        return sandfir_fight()
    end
    return sandfir_fight()
end

-- 沙中之火 点击奖励
sandfir_get_reward = function()
    log("检查每15分钟领奖励")
    if not sandfir_timer or time() - sandfir_timer > 900 * 1000 then

        -- 进入奖励页面
        tapUntilCheckedPointColor(sandfire_point.奖励, sandfire_point.奖励页面)

        -- 检查领完没
        if checkPointColor(sandfire_point.奖励已领完) then
            stop("等级已满，演算生息结束", '', true, true)
        end

        -- 领取奖励
        if not tapUntilCheckedPointColor(sandfire_point.一键领取变灰, sandfire_point.一键领取变灰, "领取奖励"
            , 0, 3) then
            tapUntilCheckedPointColor(sandfire_point.跳过皮肤, sandfire_point.一键领取变灰)
        end

        -- 检查领完没
        if checkPointColor(sandfire_point.奖励已领完) then
            stop("等级已满，演算生息结束", '', true, true)
        end

        sandfir_timer = time()
        return true
        -- -- 并非首次
        -- if zl_no_waste_last_time then
        --     zl_no_waste_last_time = nil
        -- end

        -- -- 首次
        -- if zl_no_waste then
        --     zl_no_waste_last_time = time()
        --     return false
        -- end

        -- zl_no_waste_last_time = time()
    else
        return false
    end
end
