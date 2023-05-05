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

-- 水月肉鸽导航
mizuki_navigation = function()
    -- 先导航到水月_常规行动
    if not findOne("水月_常规行动") then
        path.跳转("首页")

        tap("面板作战")
        if not appear("主页") then return false end

        -- if not wait(function()
        --   if findOne("主题曲界面") then return true end
        --   tap("主题曲")
        -- end, 5) then return false end

        if not wait(function()
                if findOne("傀影") then return true end
                tap("集成战略")
            end, 5) then
            return false
        end


        if not wait(function()
                if checkPointColor(mizuki_point.等待开始页面标题) then
                    return true
                end
                tap("进入主题")
            end, 5) then
            return false
        end
    end
    log("常规行动选中")
    return true
end

-- 水月肉鸽助战
mizuki_help_fight = function(reflashNum)
    reflashNum = reflashNum or 0
    single_man_operation = false
    if reflashNum > 3 then
        log("助战刷新次数超过3次")
        return false
    end
    -- if not findOne("确认招募") then return end
    if not wait(function()
            if findOne("战略助战界面") then return true end
            tap("战略助战")
        end, 5) then
        return
    end

    local operator
    if not wait(function()
            operator = ocr("战略助战干员范围")
            if #operator > 3 then return true end
        end, 5) then
        stop("找不到助战干员", 'cur')
    end

    local name2point = table.reduce(operator, function(a, c)
        a[c.text] = c
        return a
    end, {})

    local order = {
        { "羽毛笔",       0,  1 },
        { "海沫",          0,  1 },
        { "煌",             0,  2 },
        { "百炼嘉维尔", 99, 2 }
    }
    local best = table.findv(order, function(x) return name2point[x[1]] end)
    if not best then
        log("助战也找不到所需干员")
        tapUntilCheckedPointColor(mizuki_point.刷新助战, mizuki_point.刷新助战中, 5)
        reflashNum = reflashNum + 1
        ssleep(3)
        return mizuki_help_fight(reflashNum)
    end
    reflashNum = 0
    if best[1] == "羽毛笔" or best[1] == "海沫" then
        single_man_operation = true
    end
    zl_skill_times = best[2]
    zl_skill_idx = best[3]
    -- log("best", best)
    -- if not best then return point.战略助战干员列表1, 0, 1 end
    local p = name2point[best[1]]
    p = { p.l, p.t }
    tap(p)
    disappear("战略助战界面", 5)
    return wait(function()
        if checkPointColor(mizuki_point.初始招募进度条) then
            log("助战选择完成")
            return true
        end
        tap("开包skip")
        tap("战略助战确认")
        -- 需要等待ui加载
        ssleep(0.5)
    end, 5)
end

-- 水月肉鸽重启
mizuki_restart = function(msg)
    toast(msg)
    mizuki_fight_time = mizuki_fight_time + 1
    -- if not restart_game_check(zl_restart_interval) then
    if not request_memory_clean() then
        path.水月与深蓝之树前瞻投资()
    else
        path.跳转("首页")
    end
end

-- 水月肉鸽认知塑造
mizuki_cognition = function()
    mizuki_fight_time = 0
    local f = function()
        local pos_cognition = mizuki_point.认知塑造界面[1] .. "|" ..
            mizuki_point.认知塑造界面[2] .. "|" ..
            mizuki_point.认知塑造界面[3]
        -- 进入认知塑造
        log("进入认知塑造")
        if not wait(function()
                tap({ mizuki_point.认知塑造[1], mizuki_point.认知塑造[2] })
                sleep(100)
                if findOneStr(pos_cognition) then return true end
            end, 5) then
            return
        end

        sleep(100)

        -- 缩放
        log("缩放")
        local finger = {
            {
                point = { { 0, 0 }, { screen.width // 2, screen.height // 2 } },
                duration = duration,
            }, {
            point = {
                { screen.width,      screen.height },
                { screen.width // 2, screen.height // 2 },
            },
            duration = duration,
        },
        }
        gesture(finger)
        sleep(300)

        -- 创建坐标
        local pos_up = mizuki_point.认知塑造节点升级[1] .. "|" ..
            mizuki_point.认知塑造节点升级[2] .. "|" ..
            mizuki_point.认知塑造节点升级[3]
        local pos_uped = mizuki_point.认知塑造节点已升级[1] .. "|" ..
            mizuki_point.认知塑造节点已升级[2] .. "|" ..
            mizuki_point.认知塑造节点已升级[3]
        local pos_lock = mizuki_point.认知塑造节点未解锁[1] .. "|" ..
            mizuki_point.认知塑造节点未解锁[2] .. "|" ..
            mizuki_point.认知塑造节点未解锁[3]

        -- 确认是否已满
        log("确认是否已满")
        tap(mizuki_point.认知塑造节点列表[#mizuki_point.认知塑造节点列表])
        ssleep(1)
        if findOneStr(pos_uped) then
            log("认知塑造已满")
            lighter_enough = true
            return true
        end

        -- 升级
        log("升级")
        for i = 1, #mizuki_point.认知塑造节点列表 do
            local flag = false
            if not wait(function()
                    tap(mizuki_point.认知塑造节点列表[i])
                    sleep(100)

                    if findOneStr(pos_lock) then
                        flag = true
                        return true
                    end

                    if findOneStr(pos_up) then
                        tap({
                            mizuki_point.认知塑造节点升级[1],
                            mizuki_point.认知塑造节点升级[2],
                        })
                    end

                    if findOneStr(pos_uped) then return true end
                end, 3) then
                break
            end
            if flag then break end
        end
    end
    f()
    return true
end



-- 水月肉鸽作战选择器
mizuki_fight_select = function()
    local select_fight = nil
    if not wait(function()
            setDict(0, "水月.txt") -- 字库需要放到资源文件中
            useDict(0)
            if not wait(function()
                    -- 战斗
                    select_fight = matrixOcr(mizuki_point.水月关卡标题坐标1[1],
                        mizuki_point.水月关卡标题坐标1[2],
                        mizuki_point.水月关卡标题坐标1[3],
                        mizuki_point.水月关卡标题坐标1[4],
                        "FFFFFF", 0.90)
                    if select_fight ~= nil then
                        log(select_fight)
                        return true
                    end
                    -- 不期而遇/地区委托/诡异行商
                    select_fight = matrixOcr(mizuki_point.水月关卡标题坐标2[1],
                        mizuki_point.水月关卡标题坐标2[2],
                        mizuki_point.水月关卡标题坐标2[3],
                        mizuki_point.水月关卡标题坐标2[4],
                        "FFFFFF", 0.90)
                    if select_fight ~= nil then
                        log(select_fight)
                        return true
                    end
                    -- 紧急战斗识别区域
                    select_fight = matrixOcr(mizuki_point.水月关卡标题坐标3[1],
                        mizuki_point.水月关卡标题坐标3[2],
                        mizuki_point.水月关卡标题坐标3[3],
                        mizuki_point.水月关卡标题坐标3[4],
                        "FFFFFF", 0.90)
                    if select_fight ~= nil then
                        log(select_fight)
                        return true
                    end
                end, 5) then
                log("关卡识别错误")
                return mizuki_restart("关卡识别错误")
            end

            if #select_fight > 1 then
                if select_fight:includes({ "排", "反", "应" }) then
                    select_fight = "排异反应"
                elseif select_fight:includes({ "启", "示" }) then
                    select_fight = "启示"
                elseif select_fight:includes({ "大", "的", "呼", "唤" }) then
                    select_fight = "大群的呼唤"
                elseif select_fight:includes({ "掷", "出", "骰", "子" }) then
                    select_fight = "掷出骰子"
                elseif select_fight:includes({ "虫", "群", "横" }) then
                    select_fight = "虫群横行"
                    -- 蓄水池
                elseif select_fight:includes({ "蓄", "水", "池" }) then
                    select_fight = "蓄水池"
                    -- 共生
                elseif select_fight:includes({ "共", "生" }) then
                    select_fight = "共生"
                elseif select_fight:includes({ "互", "助" }) then
                    select_fight = "互助"
                elseif select_fight:includes({ "射", "手", "部", "队" }) then
                    select_fight = "射手部队"
                    -- 不期而遇
                elseif select_fight:includes({ "不", "期", "而", "遇" }) then
                    select_fight = "不期而遇"
                    -- 地区委托
                elseif select_fight:includes({ "地", "区", "委", "托" }) then
                    select_fight = "地区委托"
                    -- 诡异行商
                elseif select_fight:includes({ "诡", "异", "行", "商" }) then
                    select_fight = "诡异行商"
                    -- 得偿所愿
                elseif select_fight:includes({ "得", "偿", "所", "愿" }) then
                    select_fight = "得偿所愿"
                    -- 兴致盎然
                elseif select_fight:includes({ "兴", "致", "盎", "然" }) then
                    select_fight = "兴致盎然"
                else
                    log("不知道什么作战：" .. select_fight)
                    return
                end
                log("作战: " .. select_fight)
                return true
            end
        end, 5) then
        stop("不知道第一个作战是什么", 'cur')
        return
    end

    return select_fight
end

-- 水月肉鸽干员放置
mizuki_deploy = function(deploy_table)
    for i = 1, #deploy_table, 1 do
        if not wait(function()
                if findOne("干员费用够列表1") then return true end
                if not findOne("生命值") then
                    log("没找到生命值，继续等待")
                end
            end, 30) then
            return false
        end

        wait(function()
            tap("水月_干员费用够列表1")
            disappear("水月_干员费用够列表1", 0.5)
            nDeploy3(1, deploy_table[i], 4 - i)

            wait(function()
                if findOne("生命值") then return true end
                tap("开始行动1")
            end)

            if not appear("水月_干员费用够列表" .. 4 - i, 5) then return true end
        end, 20)
        if single_man_operation then break end
    end
end

-- 水月肉鸽重新校准路径
mizuki_repos_path = function()
    findTap("战略返回")
    local tgha_pos = mizuki_point.天光海岸[1] .. "|" ..
        mizuki_point.天光海岸[2] .. "|" ..
        mizuki_point.天光海岸[3]
    log("tgha_pos: ", tgha_pos)
    if not wait(function()
            if checkPointColor(mizuki_point.等待开始页面标题) then
                log("找到等待开始页面标题")
                return true
            end
        end, 5) then
        mizuki_restart("超时未找到等待开始页面标题")
    end
    wait(function()
        tap(mizuki_point.继续探索)
        if findOneStr(tgha_pos) then
            log("重置成功")
            return true
        end
    end, 5)
end

-- 水月肉鸽路径选择器
mizuki_path_selecter = function()
    local path_count = 0
    wait(function()
        local current = time()
        if findOne_interval > 0 and current - findOne_last_time > findOne_interval then
            findOne_last_time = time()
            -- log(500)
            -- releaseCapture()
            keepCapture()
        end
        -- 检查此次分支关卡数量
        for i = 1, 5 do
            local path_pos = mizuki_point.水月关卡坐标[i][1] .. "|" ..
                mizuki_point.水月关卡坐标[i][2]
            -- log("正在检测第" .. i .. "个路径")
            -- log("path_pos: ", path_pos)
            -- 关卡等级判断
            for k, t in ipairs({ "846BDE", "AC4F79", "131314", "17C7C8", "199B81" }) do
                local path_pos_color = path_pos .. "|" .. t
                local res = cmpColorEx(path_pos_color, 0.95)
                if res == 1 then
                    -- log("path_pos_color: ", path_pos_color)
                    if i < 4 then
                        path_count = 4 - i
                        return true
                    elseif i == 4 then
                        path_count = 2
                        return true
                    elseif i == 5 then
                        path_count = 1
                        return true
                    end
                end
            end
        end
    end, 5)
    log("当前分支数量 ", path_count)
    if path_count == 0 then
        log("没有找到路径")
        mizuki_repos_path()
        return mizuki_path_selecter()
    end
    return path_count
end

-- 水月肉鸽关卡类型判断器
mizuki_level_type = function(count)
    local res = {}
    local level = {}
    local currentDetectionTypeColor = nil

    -- 关卡坐标
    if count == 3 then
        level = {
            mizuki_point.水月关卡坐标[1], mizuki_point.水月关卡坐标[3],
            mizuki_point.水月关卡坐标[5],
        }
    elseif count == 2 then
        level = {
            mizuki_point.水月关卡坐标[2], mizuki_point.水月关卡坐标[4],
        }
    elseif count == 1 then
        level = { mizuki_point.水月关卡坐标[3] }
    end

    -- 关卡类型
    count = math.tointeger(count)
    for i = 1, count do
        -- log("第".. i .."个关卡类型判断")
        wait(function()
            for t, v in ipairs({
                "关卡等级_不期而遇", "关卡等级_普通",
                "关卡等级_行商", "关卡等级_紧急", "关卡等级_未选择",
            }) do
                currentDetectionTypeColor = mizuki_point[v]
                local pos = level[i][1] .. "|" .. level[i][2] .. "|" ..
                    currentDetectionTypeColor
                local ans = cmpColorEx(pos, 0.95)
                if ans == 1 then
                    res[i] = { level = t, pos = level[i] }
                    --  x偏移77 y偏移-114
                    local pos_key = level[i][1] + mizuki_point.偏移[1] .. "|" ..
                        level[i][2] - mizuki_point.偏移[2] .. "|FFFFFFF"
                    local ans_key = cmpColorEx(pos_key, 0.8)
                    if ans_key == 1 then
                        res[i]["key"] = true
                        log("第" .. i .. "个 " .. v .. " 有钥匙")
                    else
                        res[i]["key"] = false
                        log("第" .. i .. "个 " .. v)
                    end
                    return true
                end
            end
        end, 3)
    end

    -- log(res)
    return res
end

-- 水月肉鸽关卡判决器
mizuki_level_selecter = function(input_info)
    local info = input_info
    -- log("关卡判决器",info)

    if info == nil then
        log("关卡判决器未传入参数")
        return false
    end

    -- 选择排序 info
    for i = 1, #info do
        local min = i
        for j = i + 1, #info do
            if info[j].level < info[min].level then min = j end
        end
        info[i], info[min] = info[min], info[i]
    end

    for i = 1, #info do
        if info[i].key then info[i], info[#info] = info[#info], info[i] end
    end

    -- 非单人作战的情况下尝试打紧急
    if not single_man_operation then
        -- 排序后检查是否只有紧急
        if info[1] ~= nil then
            if info[1].level == 4 then
                log("只有紧急, 重试")
                mizuki_restart("只有紧急, 重试")
                return false
            end
        end
    end

    -- 检查全是钥匙
    local key_count = 0
    local flag = false

    for k, v in pairs(info) do
        if not info[k].key then
            if wait(function()
                    tap(info[k].pos)
                    if waitUntilFindColor(mizuki_point.选中关卡, 1) then return true end
                end, 3) then
                log("进入关卡准备界面")
                flag = true
                break
            end
        else
            key_count = key_count + 1
        end
    end

    if flag then return true end

    if key_count == #info then
        log("全有钥匙, 重试")
        mizuki_restart("全有钥匙, 重试")
        return false
    end

    mizuki_repos_path()
    return mizuki_level_selecter(input_info)
end

-- 水月肉鸽骰子处理器(只处理必定出现的情况)
mizuki_dice_solve = function()
    ssleep(1)
    local pos = mizuki_point.投骰子确认[1] .. "|" ..
        mizuki_point.投骰子确认[2] .. "|" ..
        mizuki_point.投骰子确认[3]

    if not wait(function()
            if findOneStr(pos) then
                log("点击骰子确认")
                tap({ mizuki_point.投骰子确认[1], mizuki_point.投骰子确认[2] })
                return true
            end
        end, 10) then
        log("骰子处理器未找到投骰子确认")
        return false
    end

    if not wait(function()
            if not findOne("战略帮助") then
                log("点击骰子确认 2次确认")
                tap({ mizuki_point.投骰子确认[1], mizuki_point.投骰子确认[2] })
            else
                return true
            end
        end, 10) then
        return false
    end

    log("骰子处理完成")
    return true
end

-- 水月肉鸽不期而遇处理器
mizuki_unexpect_solve = function()
    local select_unexpect = nil
    local unexpect_tag = mizuki_point.左侧标记[1] .. "|" ..
        mizuki_point.左侧标记[2] .. "|" ..
        mizuki_point.左侧标记[3]
    local unexpect_area = mizuki_point.不期而遇范围

    if not wait(function()
            -- 进入不期而遇
            log("尝试进入不期而遇")
            tap(mizuki_point.进入)
            if findOneStr(unexpect_tag, 0.9) then
                log("已进入不期而遇")
                return true
            end
        end, 5) then
        return false
    end

    if not wait(function()
            setDict(0, "水月_不期而遇.txt") -- 字库需要放到资源文件中
            useDict(0)
            select_unexpect = matrixOcr(unexpect_area[1], unexpect_area[2],
                unexpect_area[3], unexpect_area[4],
                "008AFF-215682", 0.90)
            if select_unexpect ~= nil then
                log(select_unexpect)
                return true
            end
        end, 5) then
        return false
    end

    if not wait(function()
            if #select_unexpect > 1 then
                -- 继承
                if select_unexpect:includes({ "继", "承" }) then
                    select_unexpect = "继承"
                    -- 噬尘扩散
                elseif select_unexpect:includes({ "噬", "尘", "扩", "散" }) then
                    select_unexpect = "噬尘扩散"
                    -- 天灾信使
                elseif select_unexpect:includes({ "天", "灾", "信", "使" }) then
                    select_unexpect = "天灾信使"
                    -- 悬高之葬
                elseif select_unexpect:includes({ "悬", "高", "之", "葬" }) then
                    select_unexpect = "悬高之葬"
                    -- 阴云如聚
                elseif select_unexpect:includes({ "阴", "云", "如", "聚" }) then
                    select_unexpect = "阴云如聚"
                    -- 远销海外
                elseif select_unexpect:includes({ "远", "销", "海", "外" }) then
                    select_unexpect = "远销海外"
                    -- 重返家园
                elseif select_unexpect:includes({ "重", "返", "家", "园" }) then
                    select_unexpect = "重返家园"
                    -- 狗眼婆娑
                elseif select_unexpect:includes({ "狗", "眼", "婆", "娑" }) then
                    select_unexpect = "狗眼婆娑"
                    -- 海嗣学者
                elseif select_unexpect:includes({ "嗣", "学", "者" }) then
                    select_unexpect = "海嗣学者"
                    -- 狂徒妄念
                elseif select_unexpect:includes({ "狂", "徒", "妄", "念" }) then
                    select_unexpect = "狂徒妄念"
                    -- 开端
                elseif select_unexpect:includes({ "开", "端" }) then
                    select_unexpect = "开端"
                else
                    log("不期而遇识别失败")
                    return
                end
                log("不期而遇: " .. select_unexpect)
                return true
            end
        end, 5) then
        stop("不知道不期而遇是什么", 'cur')
        return false
    end

    -- local pos = mizuki_point[select_unexpect][1] .."|" .. mizuki_point[select_unexpect][2] .. "|" .. mizuki_point[select_unexpect][3]
    local pos_2 = {
        mizuki_point[select_unexpect][1], mizuki_point[select_unexpect][2],
    }
    local dicePos = mizuki_point.投骰子确认[1] .. "|" ..
        mizuki_point.投骰子确认[2] .. "|" ..
        mizuki_point.投骰子确认[3]

    if not wait(function()
            if not findOne("战略帮助") then
                log("点击选项")
                tap(pos_2)
                tap(pos_2)
                tap(pos_2)
                tap(pos_2)
                tap(pos_2)
                ssleep(0.1)
                -- 处理投骰子
                if select_unexpect == "重返家园" and findOneStr(dicePos) then return mizuki_dice_solve() end
                return false
            else
                return true
            end
        end, 5) then
        return false
    end

    log("不期而遇处理完成")
    return true
end

-- 水月地区委托处理器
mizuki_entrust_solve = function()
    local pos = mizuki_point.左侧清单[1] .. "|" ..
        mizuki_point.左侧清单[2] .. "|" ..
        mizuki_point.左侧清单[3]
    log("尝试进入地区委托")

    if not wait(function()
            if not findOneStr(pos) then
                tap(mizuki_point.进入)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("成功进入地区委托")

    if not wait(function()
            if not findOne("战略帮助") then
                tap({ mizuki_point.关闭终端[1], mizuki_point.关闭终端[2] })
                ssleep(0.1)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("地区委托完成")
    return true
end

-- 水月得偿所愿处理器
mizuki_wish_solve = function()
    local pos = mizuki_point.左侧标记[1] .. "|" ..
        mizuki_point.左侧标记[2] .. "|" ..
        mizuki_point.左侧标记[3]
    log("尝试进入得偿所愿")

    if not wait(function()
            if not findOneStr(pos) then
                tap(mizuki_point.进入)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("成功进入得偿所愿")

    if not wait(function()
            if not findOne("战略帮助") then
                tap({ mizuki_point.消失的习俗[1], mizuki_point.消失的习俗[2] })
                ssleep(0.1)
                mizuki_dice_solve()
            else
                return true
            end
        end, 5) then
        return false
    end
    log("得偿所愿完成")
    return true
end

-- 水月兴致盎然处理器
mizuki_interesting_solve = function()
    local pos = mizuki_point.左侧标记[1] .. "|" ..
        mizuki_point.左侧标记[2] .. "|" ..
        mizuki_point.左侧标记[3]
    log("尝试进入兴致盎然")

    if not wait(function()
            if not findOneStr(pos) then
                tap(mizuki_point.进入)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("成功进入兴致盎然")

    if not wait(function()
            if not findOne("战略帮助") then
                tap({ mizuki_point.现买现印[1], mizuki_point.现买现印[2] })
                ssleep(0.1)
            else
                return true
            end
        end, 5) then
        return false
    end
    log("兴致盎然完成")
    return true
end

-- 水月肉鸽托管战斗
mizuki_fight = function(firstFight)
    local now_fight = mizuki_fight_select()

    -- 不期而遇
    if now_fight == "不期而遇" then
        log("跳转到不期而遇")
        return mizuki_unexpect_solve()
    end

    -- 诡异行商
    if now_fight == "诡异行商" then
        log("跳转到诡异行商")
        return mizuki_buy()
    end

    -- 地区委托
    if now_fight == "地区委托" then
        log("跳转到地区委托")
        return mizuki_entrust_solve()
    end

    -- 得偿所愿
    if now_fight == "得偿所愿" then
        log("跳转到得偿所愿")
        return mizuki_wish_solve()
    end

    -- 兴致盎然
    if now_fight == "兴致盎然" then
        log("跳转到兴致盎然")
        mizuki_interesting_solve()
        return true
    end

    if not wait(function()
            if findOne("快捷编队") then return true end
            tap("进入")
        end, 10) then
        return false
    end

    if firstFight then
        if not wait(function()
                if findOne("确认招募") then return true end
                tap("快捷编队")
            end, 10) then
            return false
        end

        if not wait(function()
                if findOne("攻击范围") and
                    (zl_skill_idx ~= 2 or zl_skill_idx == 2 and
                    findOne("战略二技能")) then
                    if not single_man_operation then tap("近卫招募列表2") end
                    return true
                end

                tap("近卫招募列表1")
                if not appear("攻击范围", 1) then return end
                if zl_skill_idx == 2 then
                    tap("战略二技能")
                    if not appear("战略二技能", 1) then return end
                end
            end, 10) then
            return false
        end

        if not wait(function()
                if not findOne("确认招募") then return true end
                tap("确认招募")
            end, 10) then
            return false
        end

        if not appear("快捷编队") then return false end
    end

    -- 开始游戏
    if not wait(function()
            tap("确认招募")
            if not findOne("快捷编队") then return true end
            -- 出现过在这儿卡死的
            if not disappear("正在提交反馈至神经", network_timeout) then
                restartapp(appid)
                return true
            end
        end, 10) then
        return false
    end

    -- 游戏界面
    if not wait(function()
            if findOne("单选确认框") then return true end
            if findOne("生命值") then return true end
        end, 30) then
        return false
    end

    if not findOne("生命值") then return false end

    -- 需要等等才能点两倍速
    appearTap("两倍速", 3)

    -- 部署干员到关卡位置
    mizuki_deploy(mizuki_point.deploy[now_fight])

    appear("生命值")

    local last_time_see_life = time()
    local skill_times = 0
    if not wait(function()
            if findOne("返回确认界面") then tap("左取消") end
            if findOne("暂停中") then
                tap("开包skip")
                disappear("暂停中")
            end
            if findOne("生命值") then last_time_see_life = time() end
            -- 超过3秒没看到生命值
            if time() - last_time_see_life > 5000 then
                tap("战略确认")
                return true
            end
            tap("开始行动1")
            local p = findOne("技能亮")
            if p and skill_times < zl_skill_times then
                skill_times = skill_times + 1
                tap({ p[1], p[2] + scale(200) })
                -- appear("技能ready", 5)
                appear("生命值蓝", 5)
                ssleep(0.5)
                wait(function()
                    tap("开技能")
                    if disappear("生命值蓝", 1) then return true end
                end)
            end
        end, 300) then
        return restartapp(appid)
    end

    appear({ "战略返回", "浪离灯熄" }, 30)
    if checkPointColor(mizuki_point.浪离灯熄) then
        mizuki_restart("战斗死亡")
        return false
    end
    if not findOne("战略返回") then return false end

    if not mizuki_after_fight() then
        log("未能完成战斗后拾取")
        return false
    end
    log("完成一次战斗")
    return true
end

-- 水月肉鸽战斗后拾取
mizuki_after_fight = function()
    local getTheBooty = function(x)
        if checkPointColor(x) then tap({ x[1], x[2] }) end
    end
    if not wait(function()
            tap("战略确认")
            getTheBooty(mizuki_point["已领取所有奖励"])
            getTheBooty(mizuki_point["源石锭"])
            getTheBooty(mizuki_point["招募券"])
            getTheBooty(mizuki_point["收藏品"])
            getTheBooty(mizuki_point["目标生命"])
            getTheBooty(mizuki_point["投掷次数"])
            getTheBooty(mizuki_point["漂流秘匣"])

            -- 误触到招募券处理
            if findOne("确认招募") then
                -- 放弃招募
                if not zl_more_experience then
                    if not wait(function()
                            if not findOne("确认招募") then return true end
                            tap("放弃招募")
                        end, 5) then
                        return
                    end

                    if not wait(function()
                            if findOne("编队") then return true end
                            tap("右右确认")
                        end, 5) then
                        return
                    end
                else
                    -- 招募
                    if findOne("确认招募") then
                        local start_time = time()
                        if not wait(function()
                                if findOne("编队") then return true end
                                if findOne("返回确认界面") then
                                    if time() - start_time < 2000 then
                                        tap("左取消")
                                    else
                                        tap("右确认")
                                    end
                                    disappear("返回确认界面")
                                    ssleep(.5)
                                end
                                tap("近卫招募列表" .. 1)
                                findTap("确认招募")
                                tap("开包skip")
                            end, 10) then
                            return
                        end
                    end
                end
            end

            if not findOne("战略返回") then
                if not appear({ "战略返回", "水月_战略帮助" }) then
                    tap("战略确认")
                end
            end
            -- if disappear("战略返回",0.5) then return true end
            if findAny({ "水月_常规行动", "水月_战略帮助" }) and
                not findOne("确认招募") then
                return true
            end

            if findOne("战略返回") and checkPointColor(mizuki_point.战略帮助) and not findOne("确认招募") then return true end
        end, 30) then
        return false
    end

    -- if not appear("战略返回", 5) then return end

    if not checkPointColor(mizuki_point.战略帮助) then
        log(2873)
        return false
    end
    log("完成拾取")
    return true
end

-- 水月肉鸽前往下一层
mizuki_goto_next_level = function()
    local pos = mizuki_point.投骰子确认[1] .. "|" ..
        mizuki_point.投骰子确认[2] .. "|" ..
        mizuki_point.投骰子确认[3]
    -- 去第二层
    log("诡意行商准备离开")
    if not wait(function()
            if findOneStr(pos) then return true end
            tap("诡意行商离开")
        end, 10) then
        return false
    end

    -- 处理投骰子
    log("处理诡意行商离开后的投骰子")
    if not mizuki_dice_solve() then return false end

    log("完成一轮")
    mizuki_restart("完成一轮")
    return true
end

-- 水月肉鸽行商购买
mizuki_buy = function()
    -- exit()
    local check_goods = function()
        if type(zl_need_goods) ~= 'string' or #zl_need_goods:trim() == 0 then
            return
        end
        local need_goods = zl_need_goods:filterSplit()
        local goods1 = table.join(map(function(x) return x.text end,
            ocr("战略第一行商品范围")))
        local goods2 = table.join(map(function(x) return x.text end,
            ocr("战略第二行商品范围")))
        local goods = table.join({ goods1, goods2 })
        if goods:includes(need_goods) then
            stop("已遇到所需商品" .. goods, '', true, true)
        end
        log("未找到商品", goods, need_goods)
    end

    local buy = function()
        log("正在购买")
        local p = appear(point["战略商品列表"], 1)
        p = findAny(point["战略商品列表"])
        if not p then
            log("未找到任何商品")
            return
        end
        if not wait(function()
                local x, y = point[p]:match("(%d+)" .. coord_delimeter .. "(%d+)")
                tap({ tonumber(x) - scale(111), tonumber(y) - scale(100) })
                if disappear(p, 1) then return true end
            end) then
            return
        end

        disappear("诡意行商离开", 1)
        if not wait(function(reset_wait_start_time)
                tap("诡意行商确认投资")
                if findOne("诡意行商离开") then return true end
                if findOne("确认招募") then
                    local start_time = time()
                    if not wait(function(reset_wait_start_time2)
                            if findOne("编队") then return true end
                            if findOne("返回确认界面") then
                                if time() - start_time < 2000 then
                                    tap("左取消")
                                else
                                    tap("右确认")
                                end
                                disappear("返回确认界面")
                                ssleep(.5)
                            end
                            if findOne("正在提交反馈至神经") then
                                reset_wait_start_time()
                                reset_wait_start_time2()
                            end
                            tap("近卫招募列表" .. 1)
                            findTap("确认招募")
                            tap("开包skip")
                        end, 10) then
                        return
                    end
                end
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
            end, 10) then
            return
        end
        return true
    end

    local coin = function()
        -- if not appear("诡意行商投资", 1) then return goto_next_level() end
        if not appear("诡意行商投资", 1) then
            log("本次无投币")
            return true
        end
        if not wait(function()
                if findOne("诡意行商投币") then return true end
                tap("诡意行商投资")
            end) then
            return
        end
        if not wait(function()
                if findOne("诡意行商投资入口") then return true end
                tap("诡意行商投币")
            end) then
            return
        end

        local coin_no_notification = sample("投币提示")

        -- 超时改为60秒，有时会出现上限极高情况
        wait(function(reset_wait_start_time)
            -- 不能投情况
            if not findOne("诡意行商投资入口") then return true end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            if not findOne(coin_no_notification) then reset_wait_start_time() end

            -- 6秒后，如果底部投币提示没有，那就说明投币结束
            -- 能投但币不够或者已投满
            -- if time() - coin_start_time > 6000 and findOne(coin_no_notification) then
            --   return true
            -- end
            tap("诡意行商确认投资")
        end, 6)
    end

    if not wait(function()
            -- if not findOne("战略帮助") then return true end
            if findAny({ "诡意行商投资", "诡意行商离开" }) then
                log("处于行商商店中")
                return true
            end
            tap("进入")
        end, 3) then
        -- check_goods()
        -- goto_next_level()
        return false
    end

    log("检查商品")
    check_goods()

    if not zl_skip_coin then
        log("开始投币")
        coin()
    end

    if zl_more_experience then
        if not wait(function()
                if findOne("诡意行商离开") then return true end
                tap("开包skip")
            end, 5) then
            return
        end
        for i = 1, 10 do if not buy() then break end end
    end

    return mizuki_goto_next_level()
end

-- 水月肉鸽 从选择关卡开始处理
mizuki_start_from_select = function()
    -- 水月肉鸽当前分支数量
    mizuki_now_path_count = mizuki_path_selecter()

    mizuki_now_level_info = mizuki_level_type(mizuki_now_path_count)

    if not mizuki_level_selecter(mizuki_now_level_info) then
        log("进入选择的关卡时出现错误")
        return flase
    end

    if not mizuki_fight() then return flase end

    return true
end

-- 沙中之火 导航
sandfire_navigation = function()
    log("沙中之火 导航")
    -- if not checkPointColor(sandfire_point.奖励) and not checkPointColor(sandfire_point.进入演算开启状态) then

    -- end
    path.跳转("首页")

    tap(global_point.活动2)
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
            return tapUntilCheckedPointColor(sandfire_point.作战关卡, sandfire_point.作战信息, "选择作战",
            0.3)
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
        end, 10) then
        return false
    end
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
