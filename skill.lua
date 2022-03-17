-----------  how to generate skill.lua
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
fetchSkillIcon = function()
  toast("正在检查更新基建图标...")
  if disable_hotupdate then return end
  local url = 'https://gitee.com/bilabila/arknights/raw/master/skill.zip'
  -- if beta_mode then url = url .. '.beta' end
  local md5url = url .. '.md5'
  local path = getWorkPath() .. '/skill.zip'
  local extract_path = getWorkPath() .. '/skill'
  local md5path = path .. '.md5'
  if downloadFile(md5url, md5path) == -1 then
    toast("下载基建图标校验数据失败")
    return
  end
  io.input(md5path)
  local expectmd5 = io.read() or '1'
  io.close()
  if expectmd5 == loadConfig("skill_md5", "2") then
    toast("已经是最新版基建图标")
    return
  end
  if downloadFile(url, path) == -1 then
    toast("下载最新基建图标失败")
    return
  end
  if fileMD5(path) ~= expectmd5 then
    toast("基建图标校验失败")
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
    toast("基建换班找不到卡片，请反馈开发者")
    ssleep(5)
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

  log(114, card)
  for idx, v in pairs(card) do
    -- 技能判断
    local icon1 = {
      v[1] + scale(7), v[2] + scale(18), v[1] + scale(60), v[2] + scale(70),
    }
    local icon2 = {
      v[1] + scale(70), v[2] + scale(18), v[1] + scale(123), v[2] + scale(70),
    }
    local png = ''
    local png2 = ''
    if not mood_only then
      png = gg(icon1[1], icon1[2], icon1[3], icon1[4], pngdata)
      -- 已到结尾，返回
      if not png then
        log("page end", icon1, idx, v)
        return true
      end
      png2 = 'empty2.png'
      operator = skillpng2operator[png]
      if #operator == 1 then

      else
        png2 = gg(icon2[1], icon2[2], icon2[3], icon2[4], pngdata) or png2
        if png2 ~= 'empty2.png' and not disable_log then
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
    table.insert(operators, {png, png2, mood, icon1, pageid})
  end
  -- sleep(max(0, delay - (time() - start_time)))
end)

skillpng2operator = JsonDecode(
                      '{"Bskill_ctrl_p_spd.png":["凯尔希2"],"Bskill_ctrl_token_p_spd.png":["布丁1"],"Bskill_ctrl_p_bot.png":["森蚺2"],"Bskill_ctrl_t_spd.png":["阿米娅0","诗怀雅0"],"Bskill_ctrl_c_spd.png":["老鲤2"],"Bskill_ctrl_h_spd.png":["琴柳2"],"Bskill_ctrl_cost_aegir.png":["歌蕾蒂娅0"],"Bskill_ctrl_aegir.png":["歌蕾蒂娅0"],"Bskill_ctrl_aegir2.png":["歌蕾蒂娅2"],"Bskill_ctrl_psk.png":["焰尾2"],"Bskill_ctrl_t_limit%26spd.png":["灵知2"],"Bskill_ctrl_lda.png":["老鲤0"],"Bskill_ctrl_lda_add.png":["吽2"],"Bskill_ctrl_karlan.png":["灵知0"],"Bskill_ctrl_lungmen.png":["陈0"],"Bskill_ctrl_ussg.png":["早露0"],"Bskill_ctrl_sp.png":["寒芒克洛丝0","炎狱炎熔0"],"Bskill_ctrl_cost.png":["焰尾0","灰喉0","苇草2","暴雨0","送葬人2","临光0","杜宾0","清道夫0","红0","坚雷1"],"Bskill_ctrl_clear_sui.png":["令0"],"Bskill_ctrl_cost_bd1%26bd2.png":["令2"],"Bskill_ctrl_cost_bd1.png":["夕0"],"Bskill_ctrl_cost_bd2.png":["夕0"],"Bskill_ctrl_ash.png":["灰烬2"],"Bskill_ctrl_r6.png":["战车0","灰烬0","闪击0","霜华0"],"Bskill_ctrl_tachanka.png":["战车2"],"Bskill_ctrl_c_wt.png":["阿0"],"Bskill_ctrl_c_wt2.png":["惊蛰2"],"Bskill_ctrl_c_wt1.png":["惊蛰0"],"Bskill_pow_spd3.png":["澄闪2","雷蛇2","炎狱炎熔2","格雷伊0"],"Bskill_pow_spd2.png":["伊芙利特2","异客2","格劳克斯2","深靛1","雷蛇0","布丁0","阿消1","清流0"],"Bskill_pow_spd1.png":["异客0","格劳克斯0","澄闪0","深靛0","伊芙利特0","炎熔0","煌0","Castle-30","Lancet-20","THRM-EX0","正义骑士号0"],"Bskill_pow_spd%26cost.png":["THRM-EX0"],"Bskill_pow_jnight.png":["正义骑士号0"],"Bskill_man_exp3.png":["断罪者1","食铁兽2"],"Bskill_man_exp2.png":["Castle-30","白雪1","红豆0","霜叶1","食铁兽0"],"Bskill_man_exp1.png":["帕拉斯2"],"Bskill_man_gold2.png":["砾1"],"Bskill_man_gold1.png":["夜烟0","斑点1"],"Bskill_man_spd%26trade.png":["清流1"],"Bskill_man_spd_bd_n1.png":["迷迭香0"],"Bskill_man_spd_bd1.png":["迷迭香0"],"Bskill_man_spd_bd2.png":["迷迭香2"],"Bskill_man_spd_variable21.png":["槐琥2"],"Bskill_man_spd3.png":["梅尔2"],"Bskill_man_spd2.png":["灰毫2","远牙2","野鬃2","白面鸮2","赫默2","调香师1","史都华德1","杰西卡0","水月2","罗比菈塔1","香草0"],"Bskill_man_limit%26cost3.png":["石棉2"],"Bskill_man_spd%26limit%26cost3.png":["石棉0","泡普卡0"],"Bskill_man_spd_add1.png":["芬0","刻俄柏2"],"Bskill_man_spd_add2.png":["稀音0","克洛丝0"],"Bskill_man_spd1.png":["灰毫0","远牙0","野鬃0","白面鸮0","赫默0","豆苗0","夜刀0","流星0"],"Bskill_man_spd%26power3.png":["温蒂2"],"Bskill_man_spd%26power2.png":["森蚺2","温蒂0"],"Bskill_man_spd%26power1.png":["异客2","森蚺0"],"Bskill_man_skill_spd.png":["水月0"],"Bskill_man_spd%26limit3.png":["蛇屠箱0","黑角0"],"Bskill_man_spd%26limit1.png":["卡缇0","米格鲁0"],"Bskill_man_spd%26limit%26cost2.png":["火神2"],"Bskill_man_spd%26limit%26cost1.png":["火神0"],"Bskill_man_spd%26limit%26cost4.png":["贝娜0"],"Bskill_man_exp%26limit2.png":["卡达1"],"Bskill_man_exp%26limit1.png":["稀音2"],"Bskill_man_limit%26cost2.png":["泡泡0"],"Bskill_man_spd_variable31.png":["泡泡1"],"Bskill_man_limit%26cost1.png":["帕拉斯0","刻俄柏0","豆苗1","清道夫1","红云0"],"Bskill_man_spd_variable11.png":["红云1"],"Bskill_man_exp%26cost.png":["卡达0"],"Bskill_man_originium2.png":["艾雅法拉0","锡兰2","地灵1","炎熔1"],"Bskill_man_originium1.png":["薄绿1","月见夜1"],"Bskill_man_cost_all.png":["槐琥0"],"Bskill_tra_Lappland1.png":["拉普兰德0"],"Bskill_tra_Lappland2.png":["拉普兰德2"],"Bskill_tra_texas1.png":["德克萨斯0"],"Bskill_tra_texas2.png":["德克萨斯2"],"Bskill_tra_vodfox.png":["巫恋2"],"Bskill_tra_spd3.png":["能天使2"],"Bskill_tra_spd_variable22.png":["雪雉2"],"Bskill_tra_spd%26cost.png":["古米0","月见夜0","空爆0"],"Bskill_tra_spd%26limit7.png":["可颂2","拜松2"],"Bskill_tra_spd2.png":["空2","夜刀0","夜烟1","安比尔1","慕斯0","缠丸1","芬1"],"Bskill_tra_spd%26limit6.png":["梓兰1","玫兰莎0","远山0"],"Bskill_tra_spd_variable21.png":["雪雉0"],"Bskill_tra_spd%26limit5.png":["银灰2"],"Bskill_tra_spd1.png":["可颂0","能天使0","拜松0","安德切尔0","深海色0","蛇屠箱1","香草1"],"Bskill_tra_spd%26limit4.png":["崖心2"],"Bskill_tra_spd%26limit3.png":["角峰0","讯使0","银灰0"],"Bskill_tra_spd%26limit2.png":["四月2"],"Bskill_tra_spd%26limit1.png":["四月0","翎羽1","黑角0"],"Bskill_tra_flow_gs2.png":["图耶2"],"Bskill_tra_flow_gs1.png":["图耶0"],"Bskill_tra_flow_gc2.png":["绮良2"],"Bskill_tra_flow_gc1.png":["绮良0"],"Bskill_tra_limit_diff.png":["孑0"],"Bskill_tra_limit_count.png":["孑1"],"Bskill_tra_spd%26dorm2.png":["空弦2"],"Bskill_tra_spd%26dorm1.png":["空弦0"],"Bskill_tra_wt%26cost2.png":["柏喙2","卡夫卡2"],"Bskill_tra_wt%26cost1.png":["巫恋0","柏喙0","贝娜2","卡夫卡0"],"Bskill_tra_bd_n2.png":["乌有2"],"Bskill_tra_long2.png":["龙舌兰2"],"Bskill_tra_long1.png":["龙舌兰0"],"Bskill_tra_limit%26cost.png":["史都华德0","暗索1","桃金娘0"],"Bskill_dorm_all%26one2.png":["杜林0"],"Bskill_dorm_all%26one1.png":["安比尔0","杜林0"],"Bskill_dorm_all3.png":["推进之王2","夜莺2","凛冬2"],"Bskill_dorm_all2.png":["阿米娅2","空0","波登可1","凛冬0","推进之王0","桃金娘1"],"Bskill_dorm_all%26one3.png":["远牙0","风笛0","赫拉格2"],"Bskill_dorm_all1.png":["赫拉格1","四月0","夜莺0"],"Bskill_dorm_all%26bd_n1_n2.png":["爱丽丝0"],"Bskill_dorm_all%26bd_n1.png":["爱丽丝2"],"Bskill_dorm_single4.png":["闪灵2"],"Bskill_dorm_single3.png":["琴柳0","蜜莓2"]}')
skillpng2operator = table.filterKV(skillpng2operator, function(k, v)
  return k:startsWith("Bskill_man") or k:startsWith("Bskill_tra")
end)
skillpng = table.remove_duplicate(table.keys(skillpng2operator))
-- table.insert(skillpng, "empty2.png")

-- 扩充干员等级， TODO
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

-- -- 只有1个技能干员
-- skillpng2operator['empty2.png'] = table.appear_times(table.flatten(
--                                                        skillpng2operator), 1)
-- 所有干员
skillpng2operator['empty1.png'] = table.remove_duplicate(table.flatten(
                                                           skillpng2operator))
skillpng2operator['empty2.png'] = skillpng2operator['empty1.png']

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
      if icon == 'Bskill_tra_spd3.png' then
        base = base + 0.35
      elseif icon == 'Bskill_tra_spd%26cost.png' then
        base = base + 0.3
      elseif icon == 'Bskill_tra_spd%26limit7.png' then
        base = base + 0.3
        storage = storage + 1
      elseif icon == 'Bskill_tra_spd%26limit6.png' then
        base = base + 0.25
        storage = storage + 1
      elseif icon == 'Bskill_tra_spd%26limit5.png' then
        base = base + 0.20
        storage = storage + 4
      elseif icon == 'Bskill_tra_spd%26limit4.png' then
        base = base + 0.15
        storage = storage + 4
      elseif icon == 'Bskill_tra_spd%26limit3.png' then
        base = base + 0.15
        storage = storage + 2
      elseif icon == 'Bskill_tra_spd%26limit2.png' then
        base = base + 0.1
        storage = storage + 4
      elseif icon == 'Bskill_tra_spd%26limit1.png' then
        base = base + 0.1
        storage = storage + 2
      elseif icon == 'Bskill_tra_spd2.png' then
        base = base + 0.3
      elseif icon == 'Bskill_tra_spd1.png' then
        base = base + 0.2
      elseif icon == 'Bskill_tra_flow_gc2.png' then
        base = base + 0.05
        gold = gold + (gold // 2) * 2
      elseif icon == 'Bskill_tra_flow_gc1.png' then
        base = base + 0.05
        gold = gold + (gold // 4) * 2
      elseif icon == 'Bskill_tra_spd%26dorm2.png' then
        base = base + 0.02 * dormitoryLevelSum
      elseif icon == 'Bskill_tra_spd%26dorm1.png' then
        base = base + 0.01 * dormitoryLevelSum
      elseif icon == 'Bskill_tra_bd_n2.png' then
        -- 忽略其他站人间烟火
        base = base + 0.01 * dormitoryCapacity
      elseif icon == 'Bskill_tra_limit%26cost.png"' then
        storage = storage + 5
      elseif icon == 'Bskill_tra_wt%26cost2.png' and goodType == '贵金属' then
        -- 认为裁缝B单独用效果极小
        base = base + 0.02
      elseif icon == 'Bskill_tra_wt%26cost1.png' and goodType == '贵金属' then
        -- 认为裁缝B单独用效果极小
        base = base + 0.01
      elseif all['Bskill_tra_long2.png'] and goodType == '贵金属' then
        -- 认为投资B单独用效果极小
        base = base + 0.02
      elseif all['Bskill_tra_long1.png'] and goodType == '贵金属' then
        -- 认为投资A单独用效果极小
        base = base + 0.01
      end
    end

    -- 应用全局性技能
    -- 拉狗徳狗
    local texas = all['Bskill_tra_texas1.png'] or all['Bskill_tra_texas2.png']
    if all['Bskill_tra_Lappland1.png'] then
      if texas then
        storage = storage + 2
        base = base + 0.65
      end
    elseif all['Bskill_tra_Lappland2.png'] then
      if texas then
        storage = storage + 4
        base = base + 0.65
      end
    end

    -- 雪雉
    if all['Bskill_tra_spd_variable22.png'] then
      base = base + min(0.35, base // 0.05 * 0.05) *
               all['Bskill_tra_spd_variable22.png']
    end

    -- 图耶
    if all['Bskill_tra_flow_gs2.png'] then
      base = base + 0.05 + (gold // 2) * 0.15 * all['Bskill_tra_flow_gs2.png']
    end
    if all['Bskill_tra_flow_gs1.png'] then
      base = base + 0.05 + (gold // 4) * 0.15 * all['Bskill_tra_flow_gs1.png']
    end

    -- 孑 
    if all['Bskill_tra_limit_count.png'] then
      -- 孑精1
      base = base + max(1, (maxStorage + storage - base // 0.1)) * 0.04
    elseif all['Bskill_tra_limit_diff.png'] then
      -- 孑精0 近似 14及以上仓库时为0.36
      base = base + 0.36 * min(1, (maxStorage + storage) / 14)
    end

    -- 巫恋
    if all['Bskill_tra_vodfox.png'] and goodType == '贵金属' then
      if maxOperator == 1 then
        base = 0
      elseif maxOperator == 2 then
        base = 0.45 + 0.01
      else
        -- 参考 https://bbs.nga.cn/read.php?tid=25965441&rand=365
        if all['Bskill_tra_wt%26cost2.png'] and all['Bskill_tra_long2.png'] then
          only_need = {
            'Bskill_tra_vodfox.png', 'Bskill_tra_wt%26cost2.png',
            'Bskill_tra_long2.png',
          }
          base = 1.7192
        elseif all['Bskill_tra_wt%26cost2.png'] and all['Bskill_tra_long1.png'] then
          only_need = {
            'Bskill_tra_vodfox.png', 'Bskill_tra_wt%26cost2.png',
            'Bskill_tra_long1.png',
          }
          base = 1.3205
        elseif all['Bskill_tra_wt%26cost2.png'] then
          only_need = {'Bskill_tra_vodfox.png', 'Bskill_tra_wt%26cost2.png'}
          base = 0.9218
        elseif all['Bskill_tra_long2.png'] then
          only_need = {'Bskill_tra_vodfox.png', 'Bskill_tra_long2.png'}
          base = 1.4734
        elseif all['Bskill_tra_long1.png'] then
          only_need = {'Bskill_tra_vodfox.png', 'Bskill_tra_long1.png'}
          base = 1.1927
        else
          only_need = {'Bskill_tra_vodfox.png'}
          base = 0.9120
        end
      end
    end
    return base, only_need
  end

  -- 过滤心情小于阈值的干员
  local minAllowedMood = 12
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
    {'Bskill_man_exp3.png', 'Bskill_man_exp1.png', 12},
    {'Bskill_man_exp2.png', '', 12}, {'', 'Bskill_man_spd_variable31.png', 12},
    {'Bskill_man_spd2.png', '', 12},
    {'', 'Bskill_man_spd%26limit%26cost2.png', 12},
    {'', 'Bskill_man_spd%26limit%26cost4.png', 12},
  }
  local tradingStationNum = 3
  local powerStationNum = 3
  local goodType = "作战记录"
  local level = 3
  local best, best_score
  best, best_score = manufacturingStationOperatorBest(operator,
                                                      tradingStationNum,
                                                      powerStationNum, goodType,
                                                      level)

  log(best, best_score)
end

-- 制造站干员选择
-- operator: 列表，每个元素包含两个技能图标与心情
-- tradingStationNum: 贸易站数量
-- powerStationNum: 发电站数量
-- type: 制造物类别
-- level: 制造站等级
-- 返回效率最高的index
manufacturingStationOperatorBest = function(operator, tradingStationNum,
                                            powerStationNum, goodType, level)
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
        station_only, only_need

  local score = function(icons)
    base = 0
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
      if debug_mode then log(427, icon, icons, base, station) end
      all[icon] = (all[icon] or 0) + 1
      -- log(266, icon, goodType, base)
      if icon == 'Bskill_man_exp3.png' then
        if goodType == '作战记录' then base = base + 0.35 end
        -- log(272, base)
      elseif icon == 'Bskill_man_exp2.png' then
        if goodType == '作战记录' then base = base + 0.30 end
      elseif icon == 'Bskill_man_exp1.png' then
        if goodType == '作战记录' then base = base + 0.25 end
      elseif icon == 'Bskill_man_gold2.png' then
        if goodType == '贵金属' then base = base + 0.35 end
      elseif icon == 'Bskill_man_gold1.png' then
        if goodType == '贵金属' then base = base + 0.30 end
      elseif icon == 'Bskill_man_spd%26trade.png' then
        -- 清流，使用贸易站数量
        if goodType == '贵金属' then
          -- base = base + 0.20 * tradingStationNum
          station = station + 0.20 * tradingStationNum
        end
      elseif icon == 'Bskill_man_spd_bd_n1.png' then
        -- 迷迭香不考虑
      elseif icon == 'Bskill_man_spd_bd1.png' then
        -- 迷迭香不考虑
      elseif icon == 'Bskill_man_spd_bd2.png' then
        -- 迷迭香不考虑
      elseif icon == 'Bskill_man_spd3.png' then
        base = base + 0.30
      elseif icon == 'Bskill_man_spd2.png' then
        base = base + 0.25
      elseif icon == 'Bskill_man_limit%26cost3.png' then
        storage[idx // 3] = (storage[idx // 3] or 0) + 16
        -- table.insert(storage, 16)
      elseif icon == 'Bskill_man_spd%26limit%26cost3.png' then
        base = base + 0.25
        storage[idx // 3] = (storage[idx // 3] or 0) - 12
        -- table.insert(storage, -12)
      elseif icon == 'Bskill_man_spd_add1.png' then
        -- 8小时平均收益 ((0.2+0.24)/2*5+0.25*3)/8
        base = base + 0.23125
      elseif icon == 'Bskill_man_spd_add2.png' then
        -- 8小时平均收益 ((0.15+0.23)/2*5+0.25*3)/8
        base = base + 0.2125
      elseif icon == 'Bskill_man_spd1.png' then
        base = base + 0.15
      elseif icon == 'Bskill_man_spd%26limit3.png' then
        base = base + 0.1
        storage[idx // 3] = (storage[idx // 3] or 0) + 10
        -- table.insert(storage, 10)
      elseif icon == 'Bskill_man_spd%26limit1.png' then
        base = base + 0.1
        -- table.insert(storage, 6)
        storage[idx // 3] = (storage[idx // 3] or 0) + 6
      elseif icon == 'Bskill_man_spd%26limit%26cost2.png' then
        base = base - 0.05
        -- table.insert(storage, 19)
        storage[idx // 3] = (storage[idx // 3] or 0) + 19
      elseif icon == 'Bskill_man_spd%26limit%26cost1.png' then
        base = base - 0.05
        -- table.insert(storage, 16)
        storage[idx // 3] = (storage[idx // 3] or 0) + 16
      elseif icon == 'Bskill_man_spd%26limit%26cost4.png' then
        base = base - 0.2
        -- table.insert(storage, 17)
        storage[idx // 3] = (storage[idx // 3] or 0) + 17
      elseif icon == 'Bskill_man_exp%26limit2.png' then
        if goodType == '作战记录' then
          -- table.insert(storage, 15)
          storage[idx // 3] = (storage[idx // 3] or 0) + 15
        end
      elseif icon == 'Bskill_man_exp%26limit1.png' then
        if goodType == '作战记录' then
          -- table.insert(storage, 12) 
          storage[idx // 3] = (storage[idx // 3] or 0) + 12
        end
      elseif icon == 'Bskill_man_limit%26cost2.png' then
        -- table.insert(storage, 10)
        storage[idx // 3] = (storage[idx // 3] or 0) + 10
      elseif icon == 'Bskill_man_limit%26cost1.png' then
        -- table.insert(storage, 8)
        storage[idx // 3] = (storage[idx // 3] or 0) + 8
      elseif icon == 'Bskill_man_exp%26cost.png' then
        -- Vlog 心情消耗不考虑
      elseif icon == 'Bskill_man_originium2.png' then
        if goodType == '源石' then base = base + 0.35 end
      elseif icon == 'Bskill_man_originium1.png' then
        if goodType == '源石' then base = base + 0.3 end
      elseif icon == 'empty.png' then
        log('empty')
      end
    end

    if debug_mode then log(428, icon, icons, base, station, storage) end

    -- 应用全局性技能
    if all['Bskill_man_spd_variable31.png'] then
      -- 泡泡
      for _, s in pairs(storage) do
        if s > 0 and s <= 16 then
          base = base + s * 0.01 * all['Bskill_man_spd_variable31.png']
        elseif s > 16 then
          base = base + s * 0.03 * all['Bskill_man_spd_variable31.png']
        end
      end
    elseif all['Bskill_man_spd_variable11.png'] then
      -- 红云
      base = base + max(table.sum(storage), 0) * 0.02 *
               all['Bskill_man_spd_variable11.png']
    end
    if all['Bskill_man_spd_variable21.png'] then
      -- 槐虎
      base = base + min(0.4, base // 0.05 * 0.05) *
               all['Bskill_man_spd_variable21.png']
    end

    -- 发电站数
    if all['Bskill_man_spd%26power3.png'] then
      station_only = true
      station = station + 0.15 * powerStationNum *
                  all['Bskill_man_spd%26power3.png']
      table.extend(only_need, {'Bskill_man_spd%26power3.png'})
    end
    if all['Bskill_man_spd%26power2.png'] then
      station_only = true
      station = station + 0.1 * powerStationNum *
                  all['Bskill_man_spd%26power2.png']
      table.extend(only_need, {'Bskill_man_spd%26power2.png'})
    end
    if all['Bskill_man_spd%26power1.png'] then
      station_only = true
      station = station + 0.05 * powerStationNum *
                  all['Bskill_man_spd%26power1.png']
      table.extend(only_need, {'Bskill_man_spd%26power1.png'})
    end
    if all['Bskill_man_skill_spd.png'] then
      -- 水月，标准化技能数量
      base = base + standard * 0.05 * all['Bskill_man_skill_spd.png']
    end
    if debug_mode then log(428.5, icon, icons, base, station, storage) end

    if station_only then
      base = station
      table.extend(only_need, {'Bskill_man_spd%26trade.png'})
    else
      base = base + station
    end
    if debug_mode then log(429, icon, icons, base, station) end

    return base, only_need
  end

  -- 过滤心情小于阈值的干员
  local minAllowedMood = 12
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

gg = function(x1, y1, x2, y2, pngdata)
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

    -- if k == 'Bskill_tra_long1.png' then log(662, score, tmp) end
    -- if k == 'Bskill_tra_flow_gc1.png' then log(663, score, tmp) end
    --
    -- if k == 'Bskill_tra_texas1.png' then log(662, score, tmp) end
    -- if k == 'Bskill_tra_Lappland2.png' then log(663, score, tmp) end
    -- exit()

    if best_score > score then
      best_score = score
      best = k
    end
  end
  log(2208, best_score, best, x1, y1, x2, y2)
  -- exit()
  return best
end

initPngdata = function()
  -- 读取图标图像，300个36x36的png，可能比较耗时
  if not tradingPngdata then
    manufacturingPngdata = {}
    tradingPngdata = {}

    local s = ''
    for _, v in pairs(skillpng) do
      local pngdata
      if v:startsWith("Bskill_man") then
        pngdata = manufacturingPngdata
      elseif v:startsWith("Bskill_tra") then
        pngdata = tradingPngdata
      end

      local _, _, color = getImage(getWorkPath() .. '/skill/' .. v)
      pngdata[v] = {}
      for _, m in pairs(stationIconMask) do
        i, j = m[1], m[2]
        b, g, r = colorToRGB(color[(w - i - 1) * w + j])
        table.extend(pngdata[v], {r, g, b})
        if nil and v == 'Bskill_man_exp2.png' then
          -- if v == 'Bskill_ws_evolve2.png' then
          r = string.format('%X', r):padStart(2, '0')
          g = string.format('%X', g):padStart(2, '0')
          b = string.format('%X', b):padStart(2, '0')
          s = s .. i .. '|' .. j .. '|' .. r .. g .. b .. ','
        end
      end
    end
  end
  if not manufacturingPngdata['Bskill_man_exp2.png'] then
    stop("基建图标数据异常")
  end
end

-- 是否是贸易站，商品类别
chooseOperator = function(trading, goodType, stationLevel, tradingStationNum,
                          powerStationNum, dormitoryCapacity, dormitoryLevelSum,
                          goldStationNum)
  log("trading", trading)
  log("goodType", goodType)
  log("stationLevel", stationLevel)
  log("tradingStationNum", tradingStationNum)
  log("powerStationNum", powerStationNum)
  log("dormitoryCapacity", dormitoryCapacity)
  log("dormitoryLevelSum", dormitoryLevelSum)
  log("goldStationNum", goldStationNum)
  -- exit()

  initPngdata()
  -- exit()
  -- ==> 滑动获取所有技能

  local maxSwipTimes = 10
  local operator = {}
  for i = 1, maxSwipTimes do
    if discover(operator,
                (not trading) and manufacturingPngdata or tradingPngdata, i) then
      break
    end
    log(operator)
    -- exit()
    swipo()
  end

  swipo(true, true)
  local start_time = time()

  log(671, operator)
  -- exit()

  -- TODO 滑动时就可以开始计算
  -- 计算最优技能
  local best, best_score
  if not trading then
    best, best_score = manufacturingStationOperatorBest(operator,
                                                        tradingStationNum,
                                                        powerStationNum,
                                                        goodType, stationLevel)
  else
    best, best_score = tradingStationOperatorBest(operator, dormitoryCapacity,
                                                  dormitoryLevelSum,
                                                  goldStationNum, goodType,
                                                  stationLevel)
  end

  sleep(max(0, 500 - (time() - start_time)))

  -- 选择干员
  operator = best
  log(692, operator, best_score)
  local pageid = 1
  for i = 1, #operator do
    log(i, operator[i])
    while operator[i][5] > pageid do
      swipo()
      pageid = pageid + 1
    end
    local p = operator[i][4]
    tap({p[1] + scale(106), p[2]})
    sleep(50)
  end
  swipo(true, true)
  -- exit()
end
