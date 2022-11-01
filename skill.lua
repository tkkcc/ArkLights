-----------  how to download skill image
-----------  first open https://prts.wiki/w/%E5%90%8E%E5%8B%A4%E6%8A%80%E8%83%BD%E4%B8%80%E8%A7%88, open console
-----------  then paste the following code, copy result and paste into skill.lua
-- let dex2hex = (x)=>{
--     return parseInt(x, 10).toString(16).padStart(2, '0')
-- }
-- let rgb2hex = (r,g,b)=>{
--     return '#' + dex2hex(r) + dex2hex(g) + dex2hex(b)
-- }
--
-- let canvas = document.createElement("canvas")
-- canvas.width = 36
-- canvas.height = 36
-- let context = canvas.getContext("2d")
-- let app = document.querySelector('#mw-content-text').querySelectorAll('tr')
-- // let ans='skill={'
-- let ans = new Set();
--
-- ans = {}
-- for (let tr of app) {
--     if (tr.children.length === 4 && tr.children) {
--         let name = tr.children[1].innerText
--         let description = tr.children[2].innerText
--         let operator = [...tr.children[3].querySelectorAll('a')].map(x=>{
--             let level = x.querySelectorAll('img')[3].dataset.src
--             console.log(typeof(level))
--             level = [0, 1, 2].findIndex(x=>level.indexOf(`_${x}_`) > -1)
--             return x.title + level
--         }
--         )
--
--         let img = tr.children[0].querySelector('img')
--         if (!img)
--             continue
--
--         ans +=  window.location.host+ img.dataset.src+'\n'
--         continue
--         let k = img.dataset.src.split('/').pop()
--         ans[k] = ans[k] || []
--         ans[k].push(...operator.map(x=>x.trim()))
--         continue
--         context.drawImage(img, 0, 0)
--         let data = context.getImageData(0, 0, canvas.width, canvas.height).data
--         let rgbs = []
--         let alphas = []
--         for (let i = 0; i < canvas.width * canvas.height; ++i) {
--             let rgb = rgb2hex(data[i * 4], data[i * 4 + 1], data[i * 4 + 2])
--             let alpha = data[i * 4 + 3]
--             rgbs.push(rgb)
--             alphas.push(alpha)
--         }
--         //operator.forEach(x=> ans.add(x.trim()))
--         ans += `{[[${name.trim()}]],[[${description.trim()}]],{${operator.map(x=>"\"" + x.trim() + "\"").join(',')}},{${rgbs.map(x=>"\"" + x + "\"").join(',')}},{${alphas.map(x=>x).join(',')}} },\n`
--         //     ans.push(    [name,description,operator,rgbs,alphas]    )
--         //     break
--     }
-- }
-- // ans=[...ans].join('')
-- // ans+='}'
-- console.log(ans)
-- // console.log(JSON.stringify(ans))
-- TODO 改为从解包文件获取而非prts
-- finished
fetchSkillIcon = function()
  toast("正在检查更新基建图标...")
  if disable_hotupdate then return end
  local url = update_source .. '/skill.zip'
  -- log("url", url)
  -- if beta_mode then url = url .. '.beta' end
  local md5url = url .. '.md5'
  local path = getWorkPath() .. '/skill.zip'
  local extract_path = getWorkPath() .. '/skill'
  local md5path = path .. '.md5'
  if downloadFile(md5url, md5path) == -1 then
    toast("下载基建图标校验数据失败")
    ssleep(3)
    return
  end
  local f = io.open(md5path, 'r')
  local expectmd5 = f:read() or '1'
  f:close()
  if expectmd5 == loadConfig("skill_md5", "2") then
    toast("已经是最新版基建图标")
    return
  end
  if downloadFile(url, path) == -1 then
    toast("下载最新基建图标失败")
    ssleep(3)
    return
  end
  if fileMD5(path) ~= expectmd5 then
    toast("基建图标校验失败")
    ssleep(3)
    return
  end
  unZip(path, extract_path)
  saveConfig("skill_md5", expectmd5)
  return restartScript()
end

discover = still_wrapper(function(operators, pngdata, pageid, mood_only)
  -- 异步滑动
  -- local delay = swipo(false, true)
  -- local start_time = time()
  -- local w, h, color = getScreenPixel(table.unpack(point.第一干员卡片范围))

  local prewhite = 0
  -- TODO 是这个导致卡片没识别到吗
  local y = scale(383)
  local corner = {}
  for x = scale(600), scale(1590) do
    if cmpColor(x, y, 'FFFFFF', default_findcolor_confidence) == 1 then
      prewhite = prewhite + 1
    elseif prewhite > scale(5) and
      cmpColor(x, y, '898989', default_findcolor_confidence) == 1 then
      prewhite = 0
      table.insert(corner, x)
    end
  end
  log(113, #corner)

  local card = {}
  if #corner == 0 then
    log("基建换班找不到卡片")
    return
  end
  local prex = -math.huge
  for _, x in pairs(corner) do
    if x - prex > scale(207) then
      prex = x
      table.insert(card, {x, scale(379)})
      table.insert(card, {x, scale(801)})
    end
  end

  -- card = table.slice(card, 4, 4)
  -- log(114, card)
  local empty1_num = 0
  for idx, v in pairs(card) do
    -- 技能判断
    local icon1 = {
      v[1] + scale(7), v[2] + scale(18), v[1] + scale(60), v[2] + scale(70),
    }
    local icon2 = {
      v[1] + scale(70), v[2] + scale(18), v[1] + scale(123), v[2] + scale(70),
    }
    -- log(147, icon1)
    local png = ''
    local png2 = ''
    if not mood_only then
      png = 'empty1'
      png =
        findBuildingSkill(icon1[1], icon1[2], icon1[3], icon1[4], pngdata) or
          png

      -- 已到结尾，返回
      if png == 'empty1' then
        empty1_num = empty1_num + 1
        -- 第一页有可能有多个
        if pageid > 1 or pageid == 1 and empty1_num > 3 then
          log("page end", icon1, idx, v)
          return true
        end
      end
      png2 = 'empty2'
      operator = skillpng2operator[png]
      if #operator == 1 then

      else
        png2 =
          findBuildingSkill(icon2[1], icon2[2], icon2[3], icon2[4], pngdata) or
            png2
        if png2 ~= 'empty2' and not disable_log then
          operator2 = skillpng2operator[png2]
          operator = table.intersect(operator, operator2)
        end
      end
    end

    -- 心情判断
    local mood = 0
    -- log(v[1])
    local mood1 = {v[1] + scale(49), v[2] + scale(93)}
    -- log(mood1)
    for i = 24, 1, -1 do
      local moodi = {mood1[1] + scale((i - 1) * 5.3478), mood1[2]}
      -- log(moodi, getColor(moodi[1], moodi[2]))
      -- if getColor(moodi[1], moodi[2]) == 'FFFFFF' then
      if cmpColor(moodi[1], moodi[2], 'FFFFFF', 0.4) == 1 then
        mood = i
        break
      end
    end
    log(129, idx, operator, mood)

    -- 异格将心情设为负值
    local yg1 = {v[1] + scale(7), v[2] - scale(219)}
    local yg2 = {v[1] + scale(7), v[2] - scale(205)}
    local yg3 = {v[1] + scale(15), v[2] - scale(264)}

    -- "1276|801|898989,1291|537|272727"
    log("yg1", yg1)
    log("yg2", yg2)
    log("yg3", yg3)
    yg1 = getPixelColor(yg1[1], yg1[2])
    yg2 = getPixelColor(yg2[1], yg2[2])
    yg3 = getPixelColor(yg3[1], yg3[2])
    log("yg1", yg1)
    log("yg2", yg2)
    log("yg3", yg3)
    if math.abs(colorDiff(yg1, yg2)) < 36 and table.any(ygStaitonColor,
                                                        function(color)
      return math.abs(colorDiff(yg1, color)) < 36
    end) and (math.abs(colorDiff(yg3, "ff003030")) < 75) then
      -- ffffbb22
      log("异格干员")
      mood = -mood
      if mood == 0 then mood = -1 end
    end
    -- exit()

    table.insert(operators, {png, png2, mood, icon1, pageid})
  end
  -- sleep(max(0, delay - (time() - start_time)))
  log(217, operators)
  -- exit()
end)

-- 贸易站干员选择
-- operator: 列表，每个元素包含两个技能图标
-- dormitoryCapacity: 宿舍可容纳人数
-- dormitoryLevelSum: 宿舍等级之和
-- goldStationNum: 赤金生产线数
-- 返回效率最高的index
tradingStationOperatorBest = function(operator, dormitoryCapacity,
                                      dormitoryLevelSum, goldStationNum,
                                      goodType, level)
  log("194,goldStationNum,dormitoryCapacity,dormitoryLevelSum", 194,
      goldStationNum, dormitoryCapacity, dormitoryLevelSum)
  -- 参考 https://prts.wiki/w/罗德岛基建
  local maxStorage, maxOperator
  maxOperator = level
  if level == 1 then
    maxStorage = 6
  elseif level == 2 then
    maxStorage = 8
  else
    maxStorage = 10
  end

  -- 输入index组合，计算平均加成，与groundtruth差距：
  -- 1. 只考虑8小时平均收益，非实际换班间隔
  -- 2. 12心情以下干员不考虑，也忽略心情消耗
  -- 3. 忽略 ?? 效果
  local base, storage, all, gold, extra, only_need
  local score = function(icons)
    base = 0
    storage = 0 -- 容量
    extra = 0 -- 额外加成
    gold = goldStationNum
    all = {}
    only_need = {}

    -- 应用独立技能效果
    for _, icon in pairs(table.flatten(icons)) do
      all[icon] = (all[icon] or 0) + 1
      -- log(266, icon, goodType, base)
      if icon == 'bskill_tra_spd3' then
        base = base + 0.35
      elseif icon == 'bskill_tra_spd&formula1' then
        base = base + 0.3 + 0.04 -- 近似两种产物
      elseif icon == 'bskill_tra_spd&meet1' then
        base = base + 0.4 -- 近似满级会客厅
      elseif icon == 'bskill_tra_spd&cost' then
        base = base + 0.3
      elseif icon == 'bskill_tra_spd&limit7' then
        base = base + 0.3
        storage = storage + 1
      elseif icon == 'bskill_tra_spd&limit6' then
        base = base + 0.25
        storage = storage + 1
      elseif icon == 'bskill_tra_spd&limit5' then
        base = base + 0.20
        storage = storage + 4
      elseif icon == 'bskill_tra_spd&limit4' then
        base = base + 0.15
        storage = storage + 4
      elseif icon == 'bskill_tra_spd&limit3' then
        base = base + 0.15
        storage = storage + 2
      elseif icon == 'bskill_tra_spd&limit2' then
        base = base + 0.1
        storage = storage + 4
      elseif icon == 'bskill_tra_spd&limit1' then
        base = base + 0.1
        storage = storage + 2
      elseif icon == 'bskill_tra_spd2' then
        base = base + 0.3
      elseif icon == 'bskill_tra_spd1' then
        base = base + 0.2
      elseif icon == 'bskill_tra_flow_gc2' then
        base = base + 0.05
        gold = gold + (gold // 2) * 2
      elseif icon == 'bskill_tra_flow_gc1' then
        base = base + 0.05
        gold = gold + (gold // 4) * 2
      elseif icon == 'bskill_tra_spd&dorm2' then
        base = base + 0.02 * dormitoryLevelSum
      elseif icon == 'bskill_tra_spd&dorm1' then
        base = base + 0.01 * dormitoryLevelSum
      elseif icon == 'bskill_tra_bd_n2' then
        -- 忽略其他站人间烟火
        base = base + 0.01 * dormitoryCapacity
      elseif icon == 'bskill_tra_limit&cost"' then
        storage = storage + 5
      elseif icon == 'bskill_tra_wt&cost2' and goodType == '贵金属' then
        -- 认为裁缝B单独用效果极小
        base = base + 0.02
      elseif icon == 'bskill_tra_wt&cost1' and goodType == '贵金属' then
        -- 认为裁缝B单独用效果极小
        base = base + 0.01
      elseif all['bskill_tra_long2'] and goodType == '贵金属' then
        -- 认为投资B单独用效果极小
        base = base + 0.02
      elseif all['bskill_tra_long1'] and goodType == '贵金属' then
        -- 认为投资A单独用效果极小
        base = base + 0.01
      end
    end

    -- 应用全局性技能
    --
    -- 拉狗徳狗
    local texas = all['bskill_tra_texas1'] or all['bskill_tra_texas2']
    if all['bskill_tra_lappland1'] then
      if texas then
        storage = storage + 2
        base = base + 0.65
      end
    elseif all['bskill_tra_lappland2'] then
      if texas then
        storage = storage + 4
        base = base + 0.65
      end
    end

    -- 雪雉
    if all['bskill_tra_spd_variable22'] then
      base = base + min(0.35, base // 0.05 * 0.05) *
               all['bskill_tra_spd_variable22']
    end

    -- 图耶
    if all['bskill_tra_flow_gs2'] then
      base = base + 0.05 + (gold // 2) * 0.15 * all['bskill_tra_flow_gs2']
    end
    if all['bskill_tra_flow_gs1'] then
      base = base + 0.05 + (gold // 4) * 0.15 * all['bskill_tra_flow_gs1']
    end
    -- 鸿雪
    if all['bskill_tra_flow_gs'] then
      base = base + 0.00 + (gold // 1) * 0.05 * all['bskill_tra_flow_gs']
    end

    -- 孑 
    if all['bskill_tra_limit_count'] then
      -- 孑精1
      base = base + max(1, (maxStorage + storage - base // 0.1)) * 0.04
    elseif all['bskill_tra_limit_diff'] then
      -- https://ngabbs.com/read.php?tid=26013244&rand=499
      -- 孑0 / 德拉ii =112% (1天3换(18/6) 、只在换班时收单)
      -- 孑0 近似
      base = base + (maxStorage + storage) * 0.04 / (level + 1.12) * 4.034
    end

    -- 巫恋
    if all['bskill_tra_vodfox'] and goodType == '贵金属' then
      if maxOperator == 1 then
        base = 0
      elseif maxOperator == 2 then
        base = 0.45 + 0.01
      else
        -- 参考 https://bbs.nga.cn/read.php?tid=25965441&rand=365
        -- 即使柏喙/卡夫卡等价白板，也倾向于选，因为其他地方也不怎么用
        if all['bskill_tra_wt&cost2'] and all['bskill_tra_long2'] then
          only_need = {
            'bskill_tra_vodfox', 'bskill_tra_wt&cost2', 'bskill_tra_long2',
          }
          base = 1.7192
        elseif all['bskill_tra_wt&cost2'] and all['bskill_tra_long1'] then
          only_need = {
            'bskill_tra_vodfox', 'bskill_tra_wt&cost2', 'bskill_tra_long1',
          }
          base = 1.3205
        elseif all['bskill_tra_wt&cost2'] then
          only_need = {'bskill_tra_vodfox', 'bskill_tra_wt&cost2'}
          base = 0.9218
        elseif all['bskill_tra_long2'] then
          only_need = {
            'bskill_tra_vodfox', 'bskill_tra_long2', 'bskill_tra_wt&cost1',
          }
          base = 1.4734 + 0.001 * all['bskill_tra_wt&cost1']
        elseif all['bskill_tra_long1'] then
          only_need = {
            'bskill_tra_vodfox', 'bskill_tra_long1', 'bskill_tra_wt&cost1',
          }
          base = 1.1927 + 0.001 * all['bskill_tra_wt&cost1']
        else
          only_need = {'bskill_tra_vodfox', 'bskill_tra_wt&cost1'}
          base = 0.9120 + 0.001 * all['bskill_tra_wt&cost1']
        end
      end
    end

    -- 但书，禁用巫恋
    if not all['bskill_tra_vodfox'] and goodType == "贵金属" then
      if all['bskill_tra_against'] then base = (1 + base) * 1.276 - 1 end
      if all['bskill_tra_against2'] then base = (1 + base) * 1.556 - 1 end
    end

    return base, only_need
  end

  -- 过滤心情小于阈值的干员
  local minAllowedMood = shift_min_mood
  if disable_shift_mood then minAllowedMood = -1 end
  operator = table.filter(operator,
                          function(x) return x[3] >= minAllowedMood end)
  -- 移除心情
  operatorIcon = map(function(x) return {x[1], x[2]} end, operator)

  -- 遍历全部组合
  local best = {}
  local best_score = -1
  local best_only_need = {}
  log(354, #operator, maxOperator)
  for _, c in pairs(table.combination(range(1, #operator), maxOperator)) do
    local s, only_need = score(table.index(operatorIcon, c))
    -- log(401, table.index(operator, c), s)
    if s > best_score then
      best = c
      best_score = s
      best_only_need = only_need
    end
  end

  best = table.index(operator, best)

  -- 特殊处理，只需要部分干员
  if #best_only_need > 0 then
    best = table.filter(best, function(v)
      return #table.intersect(best_only_need, {v[1], v[2]}) > 0
    end)
  end
  return best, best_score
end

testManufacturingStationOperatorBest = function()
  local operator = {
    {'bskill_man_exp3', 'bskill_man_exp1', 12}, {'bskill_man_exp2', '', 12},
    {'', 'bskill_man_spd_variable31', 12}, {'bskill_man_spd2', '', 12},
    {'', 'bskill_man_spd&limit&cost2', 12},
    {'', 'bskill_man_spd&limit&cost4', 12},
  }
  local tradingStationNum = 3
  local powerStationNum = 3
  local goodType = "作战记录"
  local level = 3
  local best, best_score
  best, best_score = manufacturingStationOperatorBest(operator,
                                                      tradingStationNum,
                                                      powerStationNum, 0,
                                                      goodType, level)

  log(best, best_score)
end

-- 制造站干员选择
-- operator: 列表，每个元素包含两个技能图标与心情
-- tradingStationNum: 贸易站数量
-- powerStationNum: 发电站数量
-- totalStationLevel: 等级总量
-- type: 制造物类别
-- level: 制造站等级
-- 返回效率最高的index
manufacturingStationOperatorBest = function(operator, tradingStationNum,
                                            powerStationNum, totalStationLevel,
                                            goodType, level)
  -- 参考 https://prts.wiki/w/罗德岛基建/制造站
  local maxStorage, maxOperator
  maxOperator = level
  if level == 1 then
    maxStorage = 24
  elseif level == 2 then
    maxStorage = 36
  else
    maxStorage = 54
  end
  log("401,goodType", goodType, operator[1])
  -- log("maxStorage", maxStorage)
  -- log("maxOperator", maxOperator)

  -- 输入index组合，计算平均加成，与groundtruth差距：
  -- 1. 只考虑8小时平均收益，非实际换班间隔
  -- 2. 12心情以下干员不考虑，也忽略心情消耗
  -- 3. 忽略 迷迭香所有技能 效果
  -- 4. 忽略 意识协议 效果（标准化技能识别不支持）
  -- 5. 忽略 我寻思能行 效果（发电站技能加成）
  local base, disable_moon_effect, storage, storages, standard, all, station,
        station_only, only_need, robot

  local score = function(icons)
    base = 0
    robot = 0 -- 工程机器人
    storage = {} -- 容量效果
    standard = 0 -- 标准化技能数量
    station = 0 -- 根据设施加成
    station_only = false -- 是否只根据设施加成
    all = {}
    only_need = {}
    -- log(icons)
    -- log(table.flatten(icons))

    -- 应用独立技能效果
    for idx, icon in pairs(table.flatten(icons)) do
      operatoridx = (idx + 1) // 2
      if debug_mode then log(427, icon, icons, base, station) end
      all[icon] = (all[icon] or 0) + 1
      -- log(266, icon, goodType, base)
      if icon == 'bskill_man_exp3' then
        if goodType == '作战记录' then base = base + 0.35 end
        -- log(272, base)
      elseif icon == 'bskill_man_exp2' then
        if goodType == '作战记录' then base = base + 0.30 end
      elseif icon == 'bskill_man_exp1' then
        if goodType == '作战记录' then base = base + 0.25 end
      elseif icon == 'bskill_man_gold2' then
        if goodType == '贵金属' then base = base + 0.35 end
      elseif icon == 'bskill_man_gold1' then
        if goodType == '贵金属' then base = base + 0.30 end
      elseif icon == 'bskill_man_spd&trade' then
        -- 清流，使用贸易站数量
        if goodType == '贵金属' then
          -- base = base + 0.20 * tradingStationNum
          station = station + 0.20 * tradingStationNum
        end
      elseif icon == 'bskill_man_spd_bd_n1' then
        -- 迷迭香不考虑
      elseif icon == 'bskill_man_spd_bd1' then
        -- 迷迭香不考虑
      elseif icon == 'bskill_man_spd_bd2' then
        -- 迷迭香不考虑
      elseif icon == 'bskill_man_spd3' then
        base = base + 0.30
      elseif icon == 'bskill_man_spd2' then
        base = base + 0.25
      elseif icon == 'bskill_man_limit&cost3' then
        storage[operatoridx] = (storage[operatoridx] or 0) + 16
        -- table.insert(storage, 16)
      elseif icon == 'bskill_man_spd&limit&cost3' then
        base = base + 0.25
        storage[operatoridx] = (storage[operatoridx] or 0) - 12
        -- table.insert(storage, -12)
      elseif icon == 'bskill_man_spd_add1' then
        -- 8小时平均收益 ((0.2+0.24)/2*5+0.25*3)/8
        base = base + 0.23125
      elseif icon == 'bskill_man_spd_add2' then
        -- 8小时平均收益 ((0.15+0.23)/2*5+0.25*3)/8
        base = base + 0.2125
      elseif icon == 'bskill_man_spd1' then
        base = base + 0.15
      elseif icon == 'bskill_man_spd&limit3' then
        base = base + 0.1
        storage[operatoridx] = (storage[operatoridx] or 0) + 10
        -- table.insert(storage, 10)
      elseif icon == 'bskill_man_spd&limit1' then
        base = base + 0.1
        -- table.insert(storage, 6)
        storage[operatoridx] = (storage[operatoridx] or 0) + 6
      elseif icon == 'bskill_man_spd&limit&cost2' then
        base = base - 0.05
        -- table.insert(storage, 19)
        storage[operatoridx] = (storage[operatoridx] or 0) + 19
      elseif icon == 'bskill_man_spd&limit&cost1' then
        base = base - 0.05
        -- table.insert(storage, 16)
        storage[operatoridx] = (storage[operatoridx] or 0) + 16
      elseif icon == 'bskill_man_spd&limit&cost4' then
        base = base - 0.2
        -- table.insert(storage, 17)
        storage[operatoridx] = (storage[operatoridx] or 0) + 17
      elseif icon == 'bskill_man_exp&limit2' then
        if goodType == '作战记录' then
          -- table.insert(storage, 15)
          storage[operatoridx] = (storage[operatoridx] or 0) + 15
        end
      elseif icon == 'bskill_man_exp&limit1' then
        if goodType == '作战记录' then
          -- table.insert(storage, 12) 
          storage[operatoridx] = (storage[operatoridx] or 0) + 12
        end
      elseif icon == 'bskill_man_limit&cost2' then
        -- table.insert(storage, 10)
        storage[operatoridx] = (storage[operatoridx] or 0) + 10
      elseif icon == 'bskill_man_limit&cost1' then
        -- table.insert(storage, 8)
        storage[operatoridx] = (storage[operatoridx] or 0) + 8
      elseif icon == 'bskill_man_exp&cost' then
        -- Vlog 心情消耗不考虑
      elseif icon == 'bskill_man_originium2' then
        if goodType == '源石' then base = base + 0.35 end
      elseif icon == 'bskill_man_originium1' then
        if goodType == '源石' then base = base + 0.3 end
      elseif icon == 'bskill_man_constrlv' then
        robot = min(64, robot + totalStationLevel)
      elseif icon == 'empty' then
        log('empty')
      end
    end

    if debug_mode then log(428, icon, icons, base, station, storage) end

    -- 应用全局性技能
    -- 至简
    if all["bskill_man_spd_bd3"] then base = base + (robot // 16) * 0.05 end
    if all["bskill_man_spd_bd4"] then base = base + (robot // 8) * 0.05 end

    if all['bskill_man_spd_variable31'] then
      -- 泡泡
      for _, s in pairs(storage) do
        if s > 0 and s <= 16 then
          base = base + s * 0.01 * all['bskill_man_spd_variable31']
        elseif s > 16 then
          base = base + s * 0.03 * all['bskill_man_spd_variable31']
        end
      end
    elseif all['bskill_man_spd_variable11'] then
      -- 红云
      base = base + max(table.sum(storage), 0) * 0.02 *
               all['bskill_man_spd_variable11']
    end
    if all['bskill_man_spd_variable21'] then
      -- 槐虎
      base = base + min(0.4, base // 0.05 * 0.05) *
               all['bskill_man_spd_variable21']
    end

    -- 发电站数
    if all['bskill_man_spd&power3'] then
      station_only = true
      station = station + 0.15 * powerStationNum * all['bskill_man_spd&power3']
      table.extend(only_need, {'bskill_man_spd&power3'})
    end
    if all['bskill_man_spd&power2'] then
      station_only = true
      station = station + 0.1 * powerStationNum * all['bskill_man_spd&power2']
      table.extend(only_need, {'bskill_man_spd&power2'})
    end
    if all['bskill_man_spd&power1'] then
      station_only = true
      station = station + 0.05 * powerStationNum * all['bskill_man_spd&power1']
      table.extend(only_need, {'bskill_man_spd&power1'})
    end
    if all['bskill_man_skill_spd'] then
      -- 水月，标准化技能数量
      base = base + standard * 0.05 * all['bskill_man_skill_spd']
      -- base = base + 0
      -- 目前水月还是选0.25
    end

    -- 禁止过小容量
    if maxStorage + table.sum(storage) < 20 then base = -1 end
    -- 禁止多次减容量
    if table.sum(storage) < -15 then base = -1 end

    if debug_mode then log(428.5, icon, icons, base, station, storage) end

    if station_only then
      base = station
      table.extend(only_need, {'bskill_man_spd&trade'})
    else
      base = base + station
    end
    if debug_mode then log(429, icon, icons, base, station) end

    return base, only_need
  end

  -- 过滤心情小于阈值的干员
  local minAllowedMood = shift_min_mood
  if disable_shift_mood then minAllowedMood = -1 end
  operator = table.filter(operator,
                          function(x) return x[3] >= minAllowedMood end)
  -- 移除心情
  operatorIcon = map(function(x) return {x[1], x[2]} end, operator)

  -- 遍历全部组合
  local best = {}
  local best_score = -1
  local best_only_need = {}
  for _, c in pairs(table.combination(range(1, #operator), maxOperator)) do
    -- if table.equal(c, {1, 2, 3}) then debug_mode=true end
    local s, only_need = score(table.index(operatorIcon, c))
    if s > best_score then
      best = c
      best_score = s
      best_only_need = only_need
    end
    -- log(401, c, s)
    -- if table.equal(c, {1, 2, 3}) then exit() end
  end
  best = table.index(operator, best)

  -- 特殊处理，白板干员用白板
  if #best_only_need > 0 then
    best = table.filter(best, function(v)
      return #table.intersect(best_only_need, {v[1], v[2]}) > 0
    end)
  end
  return best, best_score
end

stationIconMask = {}
stationIconCenterMask = {}
w, h = 36, 36
for i = 1, h do
  for j = 1, w do
    if true then
      table.insert(stationIconMask, {i, j})
      -- log(613,i,j)
    end
    if ((i - 18.5) ^ 2 + (j - 18.5) ^ 2) < 17 ^ 2 then
      table.insert(stationIconCenterMask, {i, j})
    end
  end
end
-- exit()

findBuildingSkill = function(x1, y1, x2, y2, pngdata)
  local s = ''
  local w, h, color = getScreenPixel(x1, y1, x2, y2)
  local i, j, b, g, r
  local data = {}
  for _, m in pairs(stationIconMask) do
    i, j = m[1], m[2]
    -- b, g, r = colorToRGB(color[(i - 1) * w + j])
    b, g, r = colorToRGB(color[scale((i - 1) / 720 * 1080) * w +
                           scale(j / 720 * 1080)])
    table.extend(data, {r, g, b})

    if nil then
      r = string.format('%X', r):padStart(2, '0')
      g = string.format('%X', g):padStart(2, '0')
      b = string.format('%X', b):padStart(2, '0')
      s = s .. i .. '|' .. j .. '|' .. r .. g .. b .. ','
    end
  end
  -- log(s)
  -- exit()
  --
  local best_score = 100
  -- local threshold = 100
  local best = nil
  local score = 0
  local scoreBase = 0
  local pointScore = 0
  -- local flatPoint = 0
  local abs = math.abs

  local flatScoreTable = {}
  local flatScore = 0
  for i = 1, #stationIconMask - 36 do
    flatScore = abs(data[i * 3 - 2] - data[(i + 1) * 3 - 2]) +
                  abs(data[i * 3 - 1] - data[(i + 1) * 3 - 1]) +
                  abs(data[i * 3] - data[(i + 1) * 3]) +
                  abs(data[i * 3 - 2] - data[(i + 36) * 3 - 2]) +
                  abs(data[i * 3 - 1] - data[(i + 36) * 3 - 1]) +
                  abs(data[i * 3] - data[(i + 36) * 3])
    table.insert(flatScoreTable, 1 / (1 + flatScore))
    scoreBase = scoreBase + flatScoreTable[#flatScoreTable]
  end

  -- local tmp = ''
  for k, v in pairs(pngdata) do
    -- tmp = ''
    score = 0
    for i = 1, #stationIconMask do
      pointScore = abs(data[i * 3 - 2] - v[i * 3 - 2]) +
                     abs(data[i * 3 - 1] - v[i * 3 - 1]) +
                     abs(data[i * 3] - v[i * 3])
      score = score + pointScore * flatScoreTable[i]
      -- if i % 36 == 1 then tmp = tmp .. '\n' end
      -- if pointScore > 200 then
      --   tmp = tmp .. '1'
      -- else
      --   tmp = tmp .. ' '
      -- end
      if score / scoreBase > best_score then break end
    end
    score = score / scoreBase

    -- if k == 'bskill_tra_long1' then log(662, score, tmp) end
    -- if k == 'bskill_tra_flow_gc1' then log(663, score, tmp) end
    --
    -- if k == 'bskill_tra_texas1' then log(662, score, tmp) end
    -- if k == 'bskill_tra_lappland2' then log(663, score, tmp) end
    -- if k == 'bskill_meet_spd3' then log(663, score, tmp) end
    -- if k == 'bskill_meet_spd2' then log(662, score, tmp) end
    -- if k == 'bskill_man_spd2' then log(663, score, tmp) end
    -- if k == 'bskill_man_exp2' then log(662, score, tmp) end
    -- if k == 'bskill_ctrl_t_spd' then log('t', score, tmp) end
    -- if k == 'bskill_ctrl_c_spd' then log('c', score, tmp) end
    -- exit()

    if best_score > score then
      best_score = score
      best = k
    end
  end
  -- log(2208, best_score, best, x1, y1, x2, y2)
  -- exit()
  return best
end

initPngdata = function()
  if skillpng2operator then return end

  -- 读取数据
  local f = io.open(getWorkPath() .. '/skill/skillicon2operator.json', 'r')
  skillpng2operator = f:read()
  f:close()
  local status
  status, skillpng2operator = pcall(JsonDecode, skillpng2operator)
  if not status then stop("基建图标数据异常", 'cur') end

  -- 扩充精英化等级
  for k, v in pairs(skillpng2operator) do
    local extra = {}
    for _, o in pairs(v) do
      if o:endsWith('1') then table.insert(extra, o:sub(1, #o - 1) .. '2') end
      if o:endsWith('0') then
        table.insert(extra, o:sub(1, #o - 1) .. '1')
        table.insert(extra, o:sub(1, #o - 1) .. '2')
      end
    end
    table.extend(v, extra)
  end

  -- 第一技能缺失，无需再考虑
  skillpng2operator['empty1'] = {}

  -- 第二技能缺失，所有干员
  skillpng2operator['empty2'] = table.remove_duplicate(table.flatten(
                                                         skillpng2operator))

  -- 读取图标
  manufacturingPngdata = {}
  tradingPngdata = {}
  meetingPngdata = {}
  controlPngdata = {}
  officePngdata = {}
  stationType2pngData = {
    制造站 = manufacturingPngdata,
    贸易站 = tradingPngdata,
    会客厅 = meetingPngdata,
    控制中枢 = controlPngdata,
    办公室 = officePngdata,
  }

  local s = ''
  for v, _ in pairs(skillpng2operator) do
    local pngdata
    if v:startsWith("bskill_man") then
      pngdata = manufacturingPngdata
    elseif v:startsWith("bskill_tra_") then
      pngdata = tradingPngdata
    elseif v:startsWith("bskill_meet") then
      pngdata = meetingPngdata
    elseif v:startsWith("bskill_ctrl") then
      pngdata = controlPngdata
    elseif v:startsWith("bskill_hire") then
      pngdata = officePngdata
    else
      pngdata = {}
    end

    local _, _, color = getImage(getWorkPath() .. '/skill/' .. v .. '.png')
    -- if v=='empty1' then
    --   print(color)
    -- end
    pngdata[v] = {}
    for _, m in pairs(stationIconMask) do
      i, j = m[1], m[2]
      b, g, r = colorToRGB(color[(w - i - 1) * w + j])
      table.extend(pngdata[v], {r, g, b})
      if nil and v == 'bskill_man_exp2' then
        -- if v == 'bskill_ws_evolve2' then
        r = string.format('%X', r):padStart(2, '0')
        g = string.format('%X', g):padStart(2, '0')
        b = string.format('%X', b):padStart(2, '0')
        s = s .. i .. '|' .. j .. '|' .. r .. g .. b .. ','
      end
    end
  end
  if not manufacturingPngdata['bskill_man_exp2'] then
    stop("基建图标数据异常", 'cur')
  end

end

-- 是否是贸易站，商品类别
chooseOperator = function(stationType, goodType, stationLevel,
                          tradingStationNum, powerStationNum, dormitoryCapacity,
                          dormitoryLevelSum, goldStationNum, totalStationLevel)
  log("stationType", stationType)
  log("goodType", goodType)
  log("stationLevel", stationLevel)
  log("tradingStationNum", tradingStationNum)
  log("powerStationNum", powerStationNum)
  log("dormitoryCapacity", dormitoryCapacity)
  log("dormitoryLevelSum", dormitoryLevelSum)
  log("goldStationNum", goldStationNum)
  log("totalStationLevel", totalStationLevel)
  -- exit()

  local start_time = time()
  initPngdata()
  -- 至少等一秒
  sleep(max(0, 1000 - (time() - start_time)))

  -- exit()
  -- ==> 滑动获取所有技能

  local maxSwipTimes = 10
  local operator = {}
  for i = 1, maxSwipTimes do
    -- if discover(operator,
    --             (not trading) and manufacturingPngdata or tradingPngdata, i) then
    -- log(stationType, #stationType2pngData[stationType])
    if discover(operator, stationType2pngData[stationType], i) then break end

    -- exit()
    -- 三次重试
    local state = sample("干员第一个")
    for j = 1, 3 do
      log("842尝试翻页", j)
      if findOne("正在提交反馈至神经") then
        disappear("正在提交反馈至神经", network_timeout)
        ssleep(.5)
      end
      swipo()
      if not findOne(state) then break end
    end
  end
  swipo(true, true)

  start_time = time()

  -- log(671, operator)
  -- exit()

  -- TODO 滑动时就可以开始计算
  -- 计算最优技能
  local best, best_score
  if stationType == "制造站" then
    best, best_score = manufacturingStationOperatorBest(operator,
                                                        tradingStationNum,
                                                        powerStationNum,
                                                        totalStationLevel,
                                                        goodType, stationLevel)
  elseif stationType == "贸易站" then
    best, best_score = tradingStationOperatorBest(operator, dormitoryCapacity,
                                                  dormitoryLevelSum,
                                                  goldStationNum, goodType,
                                                  stationLevel)
  elseif stationType == "会客厅" then
    best, best_score = meetingStationOperatorBest(operator)
  elseif stationType == "办公室" then
    best, best_score = officeStationOperatorBest(operator)
  elseif stationType == "控制中枢" then
    best, best_score = controlStationOperatorBest(operator)
  end
  sleep(max(0, 500 - (time() - start_time)))

  -- 按页数排序
  table.sort(best, function(a, b) return a[5] < b[5] end)

  -- 选择干员
  operator = best
  log(692, operator, best_score)
  local pageid = 1
  for i = 1, #operator do
    log(i, operator[i])
    while operator[i][5] > pageid do
      local state = sample("干员第一个")
      for j = 1, 3 do
        log("844尝试翻页", j)
        if findOne("正在提交反馈至神经") then
          disappear("正在提交反馈至神经", network_timeout)
          ssleep(.5)
        end
        swipo()
        if not findOne(state) then break end
      end
      pageid = pageid + 1
    end
    local p = operator[i][4]
    tap({p[1] + scale(106), p[2]})
    sleep(50)
  end
  swipo(true, true)
  -- exit()
end

-- 会客厅干员选择：先选+25%，剩下按鹰序
-- 返回效率最高的index
meetingStationOperatorBest = function(operator)
  -- 过滤心情小于阈值的干员
  local minAllowedMood = shift_min_mood
  if disable_shift_mood then minAllowedMood = -1 end
  operator = table.filter(operator,
                          function(x) return x[3] >= minAllowedMood end)
  local best = {}
  local best_score = -1
  local remain = {}
  for _, o in pairs(operator) do
    if o[1] == "bskill_meet_spd&cost" or o[2] == "bskill_meet_spd&cost" then
      table.insert(best, 1, o)
    elseif o[1] == "bskill_meet_spdnotowned2" or o[2] ==
      "bskill_meet_spdnotowned2" then
      -- 晓歌有人评测过吗
      table.insert(best, 1, o)
    elseif o[1] == "bskill_meet_spd3" or o[2] == "bskill_meet_spd3" then
      table.insert(best, o)
    else
      table.insert(remain, o)
    end
  end
  log(best)
  best = table.slice(table.extend(best, remain), 1, 2)
  -- exit()
  return best, best_score
end

-- 办公室干员选择：
-- 按联络速度加成选，忽略彩6体系与迷迭香体系效果。
-- 返回效率最高的index
officeStationOperatorBest = function(operator)
  -- 过滤心情小于阈值的干员
  local minAllowedMood = shift_min_mood
  if disable_shift_mood then minAllowedMood = -1 end
  operator = table.filter(operator,
                          function(x) return x[3] >= minAllowedMood end)
  local best = {}
  local best_score = -1
  for _, o in pairs(operator) do
    local s = 0
    for _, icon in pairs({o[1], o[2]}) do
      if icon == "bskill_hire_skgoat" then
        s = s + 0.45
      elseif icon == "bskill_hire_spd5" then
        s = s + 0.45
      elseif icon == "bskill_hire_spd4" then
        s = s + 0.4
      elseif icon == "bskill_hire_spd3" then
        s = s + 0.35
      elseif icon == "bskill_hire_spd&clue" then
        s = s + 0.35 + 0.01
      elseif icon == "bskill_hire_spd2" then
        s = s + 0.3
      elseif icon == "bskill_hire_spd&ursus2" then
        s = s + 0.2
      elseif icon == "bskill_hire_spd&blacksteel2" then
        s = s + 0.2
      elseif icon == "bskill_hire_spd_bd_n1_n1" then
        s = s + 0.2
      elseif icon == "bskill_hire_spd&cost2" then
        s = s + 0.2
      elseif icon == "bskill_hire_blitz" then
        s = s + 0.2
      elseif icon == "bskill_hire_spd1" then
        s = s + 0.2
      elseif icon == "bskill_hire_spd&cost1" then
        s = s + 0.1
      elseif icon == "bskill_hire_spd" then
        s = s + 0.1
      end
    end
    table.insert(best, {s, o})
  end
  table.sort(best, function(a, b) return a[1] > b[1] end)
  best = best[1][2]
  return {best}, best_score
end

-- 控制中枢干员选择：同类技能不一起上
-- 返回效率最高的index
controlStationOperatorBest = function(operator)
  -- 过滤心情小于阈值的干员
  local minAllowedMood = shift_min_mood
  if disable_shift_mood then minAllowedMood = -1 end
  operator = table.filter(operator,
                          function(x) return x[3] >= minAllowedMood end)
  local best = {}
  local best_score = -1
  local remain = {}
  local goodicon = {
    'bskill_ctrl_t_spd', -- +贸易7%
    'bskill_ctrl_p_spd', -- +制造2%
    'bskill_ctrl_c_spd', -- +线索25%
    'bskill_ctrl_cost_bd1&bd2', -- 令 进驻控制中枢时，当自身心情大于12时，人间烟火+15；当自身心情处于12以下时，感知信息+10
    'bskill_ctrl_cost_bd1', -- 夕 进驻控制中枢时，控制中枢内所有干员的心情每小时恢复+0.05；当自身心情处于12以下时，人间烟火+15
    'bskill_ctrl_cost_bd2', -- 夕 进驻控制中枢时，自身心情每小时消耗+0.5；当自身心情大于12时，感知信息+10
    'bskill_ctrl_ash', -- ash
    'bskill_ctrl_tachanka', -- 机枪
    -- 'bskill_ctrl_p_bot', -- +小车,加发电站数
    -- 'bskill_ctrl_token_p_spd', -- +小车,+制造2%
    -- 'bskill_ctrl_h_spd', -- 进驻控制中枢时，人力办公室联络速度小于30%时（其中包含基础联络速度5%），则联络速度额外+20%（该加成全局效果唯一，不受其它加成影响）
    'bskill_ctrl_psk', -- 焰尾 进驻控制中枢时，每个进驻在制造站的红松骑士团干员，作战记录类配方的生产力+10%，贵金属类配方的生产力-10%
    'bskill_ctrl_t_limit&spd.png', -- 灵知 进驻控制中枢时，每个进驻在贸易站的喀兰贸易干员，订单获取效率-15%，订单上限+6
  }

  local manu_acc = false
  local trading_acc = false

  for _, o in pairs(operator) do
    if table.includes({o[1], o[2]}, 'bskill_ctrl_t_spd') then
      if not trading_acc then
        trading_acc = true
        table.insert(best, o)
      end
    elseif table.includes({o[1], o[2]}, 'bskill_ctrl_c_spd') and
      not table.includes({o[1], o[2]}, 'bskill_ctrl_lda') then
      -- 老鲤c与t会判错
      if not trading_acc then
        trading_acc = true
        table.insert(best, o)
      end
    elseif table.includes({o[1], o[2]}, 'bskill_ctrl_p_spd') then
      -- or o[1] ==
      -- 'bskill_ctrl_c_spd' or o[2] == 'bskill_ctrl_c_spd' then
      if not manu_acc then
        manu_acc = true
        table.insert(best, o)
      end
      -- elseif o[1] == 'bskill_ctrl_c_spd' or o[2] == 'bskill_ctrl_c_spd' then
      --   table.insert(best, o)
    else
      table.insert(remain, o)
    end
  end
  log(best)
  best = table.slice(table.extend(best, remain), 1, 5)
  return best, best_score
end

ygStaitonColor = {
  'ffffbb22', -- 贸易,
  'ff00d8ff', -- 制造,
  'ff77dcc7', -- 发电,
  'ffffffff', -- 宿舍,
  -- 'ffffffff', -- 控制,
  -- 'ffffffff', -- 会客,
}
