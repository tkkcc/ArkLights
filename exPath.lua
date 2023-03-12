-- ===========================================
--          额外路径
-- 请所有贡献者在此处添加额外需要的路径
--
-- 命名规范推荐
--  1. 中文命名
--  2. 禁止重载path.lua中已有的路径，避免污染
--
-- ===========================================

path.水月与深蓝之树前瞻投资 = function()
    mizuki_fight_time = mizuki_fight_time or 10
    log("开始水月肉鸽")
    log("检查浪离灯熄")
    if checkPointColor(mizuki_point.浪离灯熄) then
        wait(function()
            if findAny({ "水月_常规行动", "面板" }) then return true end
            if checkPointColor(mizuki_point.等待开始页面标题) then
                return true
            end
            tap({ 630, 597 })
        end, 30)
        -- return
    end

    -- 每8小时做日常
    log("检查每8小时做日常")
    if not zl_no_waste_last_time or time() - zl_no_waste_last_time > 8 * 3600 *
        1000 then
        -- 并非首次
        if zl_no_waste_last_time then
            log("非首次8小时日常")
            zl_no_waste_last_time = nil
            setControlBar()
            restart_account()
            -- saveConfig("hideUIOnce", "true")
            -- save_extra_mode(extra_mode, extra_mode_multi)
            -- restartPackage()
        end

        -- 首次
        if zl_no_waste then
            log("首次做日常")
            setControlBar()
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
            running = "水月与深蓝之树"
            zl_no_waste_last_time = time()
            -- mizuki_navigation()
            -- return false
        end

        zl_no_waste_last_time = time()
    end

    local in_fight_return = ''

    local jumpout
    log("检查是否在关内")
    if findOne("战略返回") then
        tap("战略返回")
        appear("水月_常规行动", 2)
    end

    log("检查是否在暂停")
    if findOne("暂停中") and findOne("生命值") then
        restartapp(appid)
        return false
    end

    log("导航到水月肉鸽")
    if mizuki_navigation() then
        log("水月肉鸽导航成功")
    else
        log("水月肉鸽导航失败")
        return false
    end

    log("检查等级")
    if zl_level_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        stop("等级已满，肉鸽结束", '', false, true)
        return false
    end

    log("检查投币")
    if zl_coin_enough then
        if zl_no_waste then
            -- todo
            transfer_global_variable("multi_account_user0")
            update_state_from_ui()
            run(no_extra_job)
        end
        stop("投币已满，肉鸽结束", '', false, true)
        return false
    end

    -- 检测等级
    local zl_level_check = function()
        if not (str2int(zl_max_level, 0) > 0) then return false end
        if not checkPointColor(mizuki_point.等待开始页面标题) then
            log("未找到水月常规行动")
            return false
        end

        -- if not wait(function()
        --   if not findOne("水月_常规行动") then return true end
        --   tap("战略等级入口")
        -- end) then return end

        log("开始识别等级")

        local x = nil

        local handle = createOcr()
        if handle ~= nil then
            local text = ocrTextEx(handle, mizuki_point.战略等级[1],
                mizuki_point.战略等级[2],
                mizuki_point.战略等级[3],
                mizuki_point.战略等级[4])
            if text ~= nil then
                text = text:gsub(" ", "")
                text = text:gsub("O", "0")
                text = text:gsub("l", "1")
                x = str2int(text:match("%d+"))
                log("识别结果：" .. text)
                log("战略等级：" .. x)
            else
                x = -1
            end
            releaseOcr(handle)
        end

        -- if x == 125 and not findOne("战略等级" .. x) then return end
        if x >= 0 and x <= 155 then
            log("识别等级成功")
            return x
        else
            log("识别等级失败")
            return false
        end
    end

    log("检测等级")
    local zl_level = zl_level_check() or -1
    log("等级：" .. zl_level .. "/" .. zl_max_level)
    if not zl_level_enough and zl_level == str2int(zl_max_level, 10000) then
        zl_level_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成",
            table.join(qqmessage, ' ') .. " " ..
            (zl_level or '') .. "等级已满")
    end

    -- 检测源石锭
    local zl_coin_check = function()
        if not (str2int(zl_max_coin, 0) > 0) then return end
        if str2int(zl_max_coin, 0) >= 1000 then return end

        if not checkPointColor(mizuki_point.等待开始页面标题) then
            log("未找到水月常规行动")
            return false
        end

        if not wait(function()
                if not checkPointColor(mizuki_point.等待开始页面标题) then return true end
                tap(mizuki_point.战略源石锭入口)
            end) then
            return
        end

        local prex = -1
        local ans = wait(function()
            ssleep(.5)
            -- if not findOne("水月_常规行动") then return 0 end
            local x = ocr("战略源石锭") or {}
            log(4195, x)
            x = (x[1] or {}).text or ""
            x = number_ocr_correct(x)
            x = str2int(x:match("[^%d](%d+)$"), -1)
            log("4128", x)
            if x >= 0 and x == prex then return x end
            -- if x >= 0 then return x end
            prex = x
        end, 5)
        wait(function()
            tap("返回")
            if waitUntilFindColor(mizuki_point.等待开始页面标题) then return true end
        end, 5)
        if ans ~= nil and type(ans) == "number" then
            ans = ans % 1000
        end
        return ans
    end

    log("检测源石锭")
    local zl_coin = zl_coin_check() or -1
    log("源石锭：" .. zl_coin .. "/" .. zl_max_coin)
    if not zl_coin_enough and zl_coin >= str2int(zl_max_coin, 10000) then
        zl_coin_enough = true
        captureqqimagedeliver("INFO", "肉鸽任务完成",
            table.join(qqmessage, ' ') .. " " .. (zl_coin or '') ..
            "源石锭已满")
    end

    -- 等级/源石锭 阶段性通知
    log("等级/源石锭 阶段性通知")
    if not zl_captcha_time or time() - zl_captcha_time > 3600 * 1000 then
        zl_captcha_time = time()
        local info = ''
        if str2int(zl_max_level, 0) > 0 then
            info = info .. zl_level .. '/' .. zl_max_level .. ' '
        end
        if str2int(zl_max_coin, 0) > 0 then
            info = info .. zl_coin .. '/' .. zl_max_coin
        end
        captureqqimagedeliver("INFO", "肉鸽任务推送",
            table.join(qqmessage, ' ') .. " " .. info)
    end

    -- 放弃探索
    log("检测放弃探索")
    if checkPointColor(mizuki_point.放弃探索) then
        if not wait(function()
                if findOne("返回确认界面") then return true end
                tap("放弃本次探索")
            end, 5) then
            log(2608)
            -- 无法直接放弃的情况 不处理
            if not wait(function()
                    if not checkPointColor(mizuki_point.等待开始页面标题) then return true end
                    tap("继续探索")
                    ssleep(.5)
                    log(2613)
                end, 5) then
                return
            end

            if not wait(function()
                    if checkPointColor(mizuki_point.等待开始页面标题) then return true end
                    -- 第一次数据更新处理
                    if findAny({
                            "面板", "活动公告返回", "签到返回", "签到返回黄",
                            "开始唤醒", "bilibili_framelayout_only",
                        }) then
                        jumpout = true
                        return true
                    end
                    log("放弃探索")
                    tap("战略确认")
                end, 5) then
                return
            end
            if jumpout then return end
        end

        if not wait(function(reset_wait_start_time)
                if findOne("正在提交反馈至神经") then
                    reset_wait_start_time()
                end
                if findOne("返回确认界面") then
                    tap("右右确认")
                    return
                end
                tap("战略确认")
                if not checkPointColor(mizuki_point.放弃探索) then
                    return true
                end
                -- 第一次数据更新处理
                if findAny({
                        "面板", "活动公告返回", "签到返回", "签到返回黄",
                        "开始唤醒", "bilibili_framelayout_only",
                    }) then
                    jumpout = true
                    return true
                end
            end, 30) then
            return false
        end
    end
    if jumpout then
        log("水月强制跳出1")
        return false
    end

    -- 等级满了，放弃行动后回到首页再截个图
    if zl_level_enough or zl_coin_enough then
        -- wait(function(reset_wait_start_time)
        --   if not findOne("水月_常规行动") then return true end
        --   tap("战略确认")
        -- end,5)

        captureqqimagedeliver("INFO", "肉鸽行动结束",
            table.join(qqmessage, ' ') .. " 放弃行动后")

        wait(function(reset_wait_start_time)
            if checkPointColor(mizuki_point.等待开始页面标题) then return true end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
        end, 5)
        return false
        -- return path.fallback.签到返回()
    end

    -- 点认知塑造后继续
    -- if not lighter_enough and not zl_disable_lighter and mizuki_fight_time >= 10 then
    --     if mizuki_cognition() then
    --         return path.水月与深蓝之树前瞻投资()
    --     end
    -- end

    log("开始探索")
    if not wait(function(reset_wait_start_time)
            if findOne("战略返回") then return true end
            -- 第二次数据更新处理
            if findAny({
                    "面板", "活动公告返回", "签到返回", "签到返回黄",
                    "开始唤醒", "bilibili_framelayout_only",
                }) then
                jumpout = true
                return true
            end
            if findOne("正在提交反馈至神经") then
                reset_wait_start_time()
            end
            tap("战略确认")
            tap("继续探索")
        end, 20) then
        -- 初始选难度
        tap("战略难度列表" .. (zl_more_experience and "2" or "1"))
        -- 点认知塑造后继续
        if not lighter_enough and not zl_disable_lighter then
            if mizuki_cognition() then
                return path.水月与深蓝之树前瞻投资()
            end
        end
        return false
    end
    if jumpout then
        log("水月强制跳出2")
        return false
    end

    -- 选择分队
    log("选择分队")
    tapUntilCheckedPointColor(mizuki_point.指挥分队,
        mizuki_point.招募组合进度条,
        "点击近卫分队", 0.5)

    log("选择招募")
    tapUntilCheckedPointColor(mizuki_point.取长补短,
        mizuki_point.初始招募进度条,
        "点击取长补短")

    log("开始选人")
    log("不招辅助")
    if not wait(function()
            if findOne("确认招募") then return true end
            if findOne("剿灭说明") then tap("剿灭说明") end
            tap("辅助招募券")
            tap("招募说明关闭")
        end, 10) then
        return false
    end

    if not wait(function()
            tap("放弃招募")
            if findOne("剿灭说明") then tap("剿灭说明") end
            if not findOne("确认招募") then return true end
        end, 10) then
        return false
    end

    if not wait(function()
            tap("右右确认")
            if findOne("剿灭说明") then tap("剿灭说明") end
            -- if findOne("水月_初始招募") then return true end
            if checkPointColor(mizuki_point.初始招募进度条) then return true end
        end, 10) then
        return false
    end

    log("招募近卫")
    if not wait(function()
            tap("近卫招募券")
            tap("招募说明关闭")
            -- if not findOne("水月_初始招募") and findOne("确认招募") then
            --     return true
            -- end
            if not checkPointColor(mizuki_point.初始招募进度条, 0.98) and findOne("确认招募") then
                return true
            end
        end, 10) then
        return false
    end

    if not waitUntilFindColor(mizuki_point.选择助战按钮) then return false end

    if not wait(function()
            if findAny({ "水月_初始招募", "战略返回" }) then
                log(26)
                return true
            end
            if findOne("返回确认界面") then
                log(27)
                -- 虽然不知道会不会走这儿
                tap("左取消")
                disappear("返回确认界面")
                -- 不等会怎么样呢，有时会闪
                ssleep(.5)
            end
            log(28, zl_best_operator)
            local idx = str2int(zl_best_operator, -1)

            if idx >= 1 and idx <= 12 then
                -- 指定
                tap("近卫招募列表" .. (zl_best_operator or 1))
                findTap("确认招募")
                tap("开包skip")
            elseif idx == -1 then
                -- 助战自动
                mizuki_help_fight()
            else
                stop("请设置近卫干员序号(1~12)", '', true, false)
            end
        end, 10) then
        return false
    end

    if not single_man_operation then
        log("招募医疗")
        if not wait(function()
                tap("医疗招募券")
                tap("招募说明关闭")
                if not checkPointColor(mizuki_point.初始招募进度条, 0.98) and findOne("确认招募") then
                    return true
                end
            end, 10) then
            return false
        end

        if not waitUntilFindColor(mizuki_point.选择助战按钮) then return false end

        if not wait(function()
                if checkPointColor(mizuki_point.偏左战略返回) then
                    log("医疗干员选完")
                    return true
                end
                if findOne("返回确认界面") then
                    log(27)
                    -- 虽然不知道会不会走这儿
                    tap("左取消")
                    disappear("返回确认界面")
                    -- 不等会怎么样呢，有时会闪
                    ssleep(.5)
                end

                -- 借用近卫坐标
                tap("近卫招募列表" .. 1)
                findTap("确认招募")
                tap("开包skip")
            end, 10) then
            return false
        end
    else
        log("不招募医疗")
        if not wait(function()
                tap("医疗招募券")
                tap("招募说明关闭")
                if not checkPointColor(mizuki_point.初始招募进度条, 0.98) and findOne("确认招募") then
                    return true
                end
            end, 10) then
            return false
        end

        if not waitUntilFindColor(mizuki_point.选择助战按钮) then return false end

        if not wait(function()
                if checkPointColor(mizuki_point.偏左战略返回) then
                    log("医疗干员选完")
                    return true
                end
                if findOne("返回确认界面") then
                    log(27)
                    -- 虽然不知道会不会走这儿
                    tap("右右确认")
                    disappear("返回确认界面")
                    -- 不等会怎么样呢，有时会闪
                    ssleep(.5)
                end

                findTap("确认招募")
                tap("开包skip")
            end, 10) then
            return false
        end
    end

    -- 选医疗干员的时候可能点太快已经进地图了
    -- todo 处理没有进地图的情况 手动再点一下

    -- 检查是否进入水月正式作战
    if not waitUntilFindColor(mizuki_point.天光海岸) then return false end

    log("进入第一关作战")
    if not wait(function()
            tap(mizuki_point.第一关)
            tap(mizuki_point.第一关)
            tap(mizuki_point.第一关)
            if waitUntilFindColor(mizuki_point.选中关卡) then return true end
        end) then
        in_fight_return = "无法进入作战"
        return mizuki_restart("无法进入作战")
    end

    local firstFight = true
    -- 第一关作战
    if not mizuki_fight(firstFight) then
        log("第一关作战出现问题")
        return flase
    end

    for i = 1, 4 do if not mizuki_start_from_select() then break end end
end

path.沙中之火 = function()
    log("生息演算沙中之火")
    if checkPointColor(sandfire_point.提示) and checkPointColor(sandfire_point.驻扎地) then
        tapUntilCheckedPointColor(sandfire_point.退出, sandfire_point.奖励, "退出当前", 0.3)
    end
    if not sandfire_navigation() then return false end
    if not sand_fire_unstop then
        if sandfir_get_reward() then return false end
    end
    sandfire_check_giveup()
    sandfire_init_fight_group()
    if not sandfir_next() then
        toast("error")
        return path.沙中之火()
    end
end

path.生息演算沙中之火 = never_end_wrapper(path.沙中之火)

path.水月与深蓝之树 = never_end_wrapper(path.水月与深蓝之树前瞻投资)
