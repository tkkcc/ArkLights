-- ===========================================
--          额外路径
-- 请所有贡献者在此处添加额外需要的路径
--
-- 命名规范推荐
--  1. 中文命名
--  2. 禁止重载path.lua中已有的路径，避免污染
--
-- ===========================================

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
