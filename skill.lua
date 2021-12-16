-----------  how to generate skill.lua
-----------  first open https://prts.wiki/w/%E5%90%8E%E5%8B%A4%E6%8A%80%E8%83%BD%E4%B8%80%E8%A7%88, open console
-----------  then paste the following code, copy result and paste into skill.lua
-- let dex2hex = (x)=>{
--     return parseInt(x,10).toString(16).padStart(2,'0')
-- }
-- let rgb2hex = (r,g,b)=>{
--     return '#'+ dex2hex(r)+dex2hex(g)+dex2hex(b)
-- }
-- let canvas = document.createElement("canvas")
-- canvas.width=36
-- canvas.height=36
-- let context = canvas.getContext("2d")
-- let app=document.querySelector('#mw-content-text').querySelectorAll('tr')
-- // let ans='skill={'
-- let ans = new Set();
-- for(let tr of app){
--   if(tr.children.length===4 && tr.children){
--     let name=tr.children[1].innerText
--     let description=tr.children[2].innerText
--     let operator=[...tr.children[3].querySelectorAll('a')].map(x=>x.title)
--     let img=tr.children[0].querySelector('img')
--     if (!img) continue
--     ans +=  window.location.host+ img.dataset.src+'\n'
--     continue
--     context.drawImage(img, 0, 0)
--     let data = context.getImageData(0, 0, canvas.width, canvas.height).data
--     let rgbs =[]
--     let alphas =[]
--     for(let i=0;i<canvas.width*canvas.height;++i){
--         let rgb = rgb2hex(data[i*4],data[i*4+1],data[i*4+2])
--         let alpha= data[i*4+3]
--         rgbs.push(rgb)
--         alphas.push(alpha)
--     }
--     //operator.forEach(x=> ans.add(x.trim()))
--     ans +=`{[[${name.trim()}]],[[${description.trim()}]],{${operator.map(x=>"\""+x.trim()+"\"").join(',')}},{${rgbs.map(x=>"\""+x+"\"").join(',')}},{${alphas.map(x=>x).join(',')}} },\n`
-- //     ans.push(    [name,description,operator,rgbs,alphas]    )
-- //     break
--   }
-- }
-- ans=[...ans].join('')
-- // ans+='}'
-- console.log(ans)
fetchSkillIcon = function() downloadFile() end

discover = function()
  local corner = findOnes("第一干员卡片")
  local card = {}
  if #corner == 0 then stop("基建换班2115") end
  for _, v in pairs(corner) do
    table.insert(card, {v.x, v.y})
    table.insert(card, {v.x, scale(801)})
  end
  log(card)
  for _, v in pairs(card) do
    -- 技能判断
    local icon1 = {
      v[1] + scale(7), v[2] + scale(18), v[1] + scale(60), v[2] + scale(70),
    }
    local icon2 = {
      v[1] + scale(70), v[2] + scale(18), v[1] + scale(123), v[2] + scale(70),
    }

    png = gg(table.unpack(icon1)) or 'empty1.png'
    -- png = 'empty1.png'
    operator = skillpng2operator[png]
    if #operator == 1 then

    else
      png = gg(table.unpack(icon2)) or 'empty2.png'
      operator2 = skillpng2operator[png]
      operator = table.intersect(operator, operator2)
    end

    if #operator < #skillpng2operator['empty2.png'] then log(operator) end

    -- exit()
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
    -- log(v, mood)
    -- if mood == 19 then break end
  end
end
discover = still_wrapper(discover)

skillpng = {
  "Bskill_ctrl_aegir2.png", "Bskill_ctrl_aegir.png", "Bskill_ctrl_ash.png",
  "Bskill_ctrl_cost_aegir.png", "Bskill_ctrl_cost_bd1.png",
  "Bskill_ctrl_cost_bd2.png", "Bskill_ctrl_cost.png", "Bskill_ctrl_c_wt1.png",
  "Bskill_ctrl_c_wt2.png", "Bskill_ctrl_c_wt.png", "Bskill_ctrl_h_spd.png",
  "Bskill_ctrl_lda.png", "Bskill_ctrl_lungmen.png", "Bskill_ctrl_p_bot.png",
  "Bskill_ctrl_psk.png", "Bskill_ctrl_p_spd.png", "Bskill_ctrl_r6.png",
  "Bskill_ctrl_sp.png", "Bskill_ctrl_tachanka.png",
  "Bskill_ctrl_token_p_spd.png", "Bskill_ctrl_t_spd.png",
  "Bskill_ctrl_ussg.png", "Bskill_dorm_all1.png",
  "Bskill_dorm_all%26bd_n1_n2.png", "Bskill_dorm_all%26bd_n1.png",
  "Bskill_dorm_all%26one1.png", "Bskill_dorm_all%26one2.png",
  "Bskill_dorm_all%26one3.png", "Bskill_dorm_all2.png", "Bskill_dorm_all3.png",
  "Bskill_dorm_one1.png", "Bskill_dorm_one2.png", "Bskill_dorm_one3.png",
  "Bskill_dorm_one4.png", "Bskill_dorm_one5.png", "Bskill_dorm_one.png",
  "Bskill_dorm_single1.png", "Bskill_dorm_single%26one01.png",
  "Bskill_dorm_single%26one02.png", "Bskill_dorm_single%26one11.png",
  "Bskill_dorm_single%26one12.png", "Bskill_dorm_single%26one21.png",
  "Bskill_dorm_single%26one22.png", "Bskill_dorm_single2.png",
  "Bskill_dorm_single3.png", "Bskill_dorm_single4.png",
  "Bskill_dorm_single_indigo.png", "Bskill_dorm_single_schwarz.png",
  "Bskill_dorm_single_tomimi.png", "Bskill_hire_blitz.png",
  "Bskill_hire_skgoat.png", "Bskill_hire_spd1.png",
  "Bskill_hire_spd%26blacksteel2.png", "Bskill_hire_spd%26clue.png",
  "Bskill_hire_spd%26cost1.png", "Bskill_hire_spd%26cost2.png",
  "Bskill_hire_spd%26ursus2.png", "Bskill_hire_spd2.png",
  "Bskill_hire_spd4.png", "Bskill_hire_spd5.png",
  "Bskill_hire_spd_bd_n1_n1.png", "Bskill_hire_spd_bd_n2.png",
  "Bskill_hire_spd_memento.png", "Bskill_man_cost_all.png",
  "Bskill_man_exp1.png", "Bskill_man_exp%26cost.png",
  "Bskill_man_exp%26limit1.png", "Bskill_man_exp%26limit2.png",
  "Bskill_man_exp2.png", "Bskill_man_exp3.png", "Bskill_man_gold1.png",
  "Bskill_man_gold2.png", "Bskill_man_limit%26cost1.png",
  "Bskill_man_limit%26cost2.png", "Bskill_man_limit%26cost3.png",
  "Bskill_man_originium1.png", "Bskill_man_originium2.png",
  "Bskill_man_skill_spd.png", "Bskill_man_spd1.png",
  "Bskill_man_spd%26limit1.png", "Bskill_man_spd%26limit%26cost1.png",
  "Bskill_man_spd%26limit%26cost2.png", "Bskill_man_spd%26limit%26cost3.png",
  "Bskill_man_spd%26limit%26cost4.png", "Bskill_man_spd%26limit3.png",
  "Bskill_man_spd%26power1.png", "Bskill_man_spd%26power2.png",
  "Bskill_man_spd%26power3.png", "Bskill_man_spd%26trade.png",
  "Bskill_man_spd2.png", "Bskill_man_spd3.png", "Bskill_man_spd_add1.png",
  "Bskill_man_spd_add2.png", "Bskill_man_spd_bd1.png", "Bskill_man_spd_bd2.png",
  "Bskill_man_spd_bd_n1.png", "Bskill_man_spd_variable11.png",
  "Bskill_man_spd_variable21.png", "Bskill_man_spd_variable31.png",
  "Bskill_meet_blacksteel2.png", "Bskill_meet_flag_rhine.png",
  "Bskill_meet_flag_rhodes.png", "Bskill_meet_flag_ursus.png",
  "Bskill_meet_glasgow2.png", "Bskill_meet_kjerag2.png",
  "Bskill_meet_penguin1.png", "Bskill_meet_penguin2.png",
  "Bskill_meet_rhine2.png", "Bskill_meet_rhodes1.png",
  "Bskill_meet_rhodes2.png", "Bskill_meet_spd1.png", "Bskill_meet_spd2.png",
  "Bskill_meet_spd3.png", "Bskill_meet_ursus1.png", "Bskill_meet_ursus2.png",
  "Bskill_pow_jnight.png", "Bskill_pow_spd1.png", "Bskill_pow_spd%26cost.png",
  "Bskill_pow_spd2.png", "Bskill_pow_spd3.png", "Bskill_tra_bd_n2.png",
  "Bskill_tra_flow_gc1.png", "Bskill_tra_flow_gc2.png",
  "Bskill_tra_flow_gs1.png", "Bskill_tra_flow_gs2.png",
  "Bskill_train1_caster1.png", "Bskill_train1_guard1.png",
  "Bskill_train1_sniper2.png", "Bskill_train1_specialist1.png",
  "Bskill_train2_caster1.png", "Bskill_train2_defender1.png",
  "Bskill_train2_guard1.png", "Bskill_train3_guard1.png",
  "Bskill_train3_sniper2.png", "Bskill_train3_supporter2.png",
  "Bskill_train_all.png", "Bskill_train_caster1.png",
  "Bskill_train_caster2.png", "Bskill_train_caster3.png",
  "Bskill_train_chen.png", "Bskill_train_defender1.png",
  "Bskill_train_defender2.png", "Bskill_train_defender3.png",
  "Bskill_train_guard1.png", "Bskill_train_guard2.png",
  "Bskill_train_guard3.png", "Bskill_train_knight_bd1.png",
  "Bskill_train_knight_bd2.png", "Bskill_train_medic1.png",
  "Bskill_train_medic2.png", "Bskill_train_medic3.png",
  "Bskill_train_skadi.png", "Bskill_train_sniper1.png",
  "Bskill_train_sniper2.png", "Bskill_train_sniper3.png",
  "Bskill_train_specialist1.png", "Bskill_train_specialist2.png",
  "Bskill_train_specialist3.png", "Bskill_train_supporter1.png",
  "Bskill_train_supporter2.png", "Bskill_train_supporter3.png",
  "Bskill_train_vanguard1.png", "Bskill_train_vanguard2.png",
  "Bskill_train_vanguard3.png", "Bskill_train_w.png",
  "Bskill_tra_Lappland1.png", "Bskill_tra_Lappland2.png",
  "Bskill_tra_limit%26cost.png", "Bskill_tra_limit_count.png",
  "Bskill_tra_limit_diff.png", "Bskill_tra_long1.png", "Bskill_tra_long2.png",
  "Bskill_tra_spd1.png", "Bskill_tra_spd%26cost.png",
  "Bskill_tra_spd%26dorm1.png", "Bskill_tra_spd%26dorm2.png",
  "Bskill_tra_spd%26limit1.png", "Bskill_tra_spd%26limit2.png",
  "Bskill_tra_spd%26limit3.png", "Bskill_tra_spd%26limit4.png",
  "Bskill_tra_spd%26limit5.png", "Bskill_tra_spd%26limit6.png",
  "Bskill_tra_spd%26limit7.png", "Bskill_tra_spd2.png", "Bskill_tra_spd3.png",
  "Bskill_tra_spd_variable21.png", "Bskill_tra_spd_variable22.png",
  "Bskill_tra_texas1.png", "Bskill_tra_texas2.png", "Bskill_tra_vodfox.png",
  "Bskill_tra_wt%26cost1.png", "Bskill_tra_wt%26cost2.png",
  "Bskill_ws_asc1.png", "Bskill_ws_asc2.png", "Bskill_ws_asc_cost1.png",
  "Bskill_ws_build1.png", "Bskill_ws_build2.png", "Bskill_ws_build3.png",
  "Bskill_ws_build_cost2.png", "Bskill_ws_build_cost.png",
  "Bskill_ws_constant.png", "Bskill_ws_cost_blemishine.png",
  "Bskill_ws_cost_magallan.png", "Bskill_ws_device.png",
  "Bskill_ws_drop_oriron.png", "Bskill_ws_evolve1.png", "Bskill_ws_evolve2.png",
  "Bskill_ws_evolve3.png", "Bskill_ws_evolve4.png",
  "Bskill_ws_evolve_cost1.png", "Bskill_ws_evolve_cost2.png",
  "Bskill_ws_evolve_cost.png", "Bskill_ws_evolve_dorm1.png",
  "Bskill_ws_evolve_dorm2.png", "Bskill_ws_free.png", "Bskill_ws_frost.png",
  "Bskill_ws_nian.png", "Bskill_ws_orirock.png", "Bskill_ws_oriron.png",
  "Bskill_ws_p1.png", "Bskill_ws_p2.png", "Bskill_ws_p3.png",
  "Bskill_ws_p4.png", "Bskill_ws_p5.png", "Bskill_ws_polyester.png",
  "Bskill_ws_recovery.png", "Bskill_ws_skill1.png", "Bskill_ws_skill2.png",
  "Bskill_ws_skill3.png", "Bskill_ws_skill_cost1.png", -- "skillpng.txt",
  "empty2.png",
}

skillpng2operator = JsonDecode(
                      '{"Bskill_ctrl_p_spd.png":["凯尔希2"],"Bskill_ctrl_token_p_spd.png":["布丁1"],"Bskill_ctrl_p_bot.png":["森蚺2"],"Bskill_ctrl_t_spd.png":["阿米娅0","诗怀雅0"],"Bskill_ctrl_h_spd.png":["琴柳2"],"Bskill_ctrl_cost_aegir.png":["歌蕾蒂娅0"],"Bskill_ctrl_aegir.png":["歌蕾蒂娅0"],"Bskill_ctrl_aegir2.png":["歌蕾蒂娅2"],"Bskill_ctrl_psk.png":["焰尾2"],"Bskill_ctrl_lda.png":["吽2"],"Bskill_ctrl_lungmen.png":["陈0"],"Bskill_ctrl_ussg.png":["早露0"],"Bskill_ctrl_sp.png":["炎狱炎熔0"],"Bskill_ctrl_cost.png":["焰尾0","灰喉0","苇草2","暴雨0","送葬人2","临光0","杜宾0","清道夫0","红0","坚雷1"],"Bskill_ctrl_cost_bd1.png":["夕0"],"Bskill_ctrl_cost_bd2.png":["夕0"],"Bskill_ctrl_ash.png":["灰烬2"],"Bskill_ctrl_r6.png":["战车0","灰烬0","闪击0","霜华0"],"Bskill_ctrl_tachanka.png":["战车2"],"Bskill_ctrl_c_wt.png":["阿0"],"Bskill_ctrl_c_wt2.png":["惊蛰2"],"Bskill_ctrl_c_wt1.png":["惊蛰0"],"Bskill_pow_spd3.png":["雷蛇2","炎狱炎熔2","格雷伊0"],"Bskill_pow_spd2.png":["伊芙利特2","异客2","格劳克斯2","深靛1","雷蛇0","布丁0","阿消1","清流0"],"Bskill_pow_spd1.png":["异客0","格劳克斯0","深靛0","伊芙利特0","炎熔0","煌0","Castle-30","Lancet-20","THRM-EX0","正义骑士号0"],"Bskill_pow_spd%26cost.png":["THRM-EX0"],"Bskill_pow_jnight.png":["正义骑士号0"],"Bskill_man_exp3.png":["断罪者1","食铁兽2"],"Bskill_man_exp2.png":["Castle-30","白雪1","红豆0","霜叶1","食铁兽0"],"Bskill_man_exp1.png":["帕拉斯2"],"Bskill_man_gold2.png":["砾1"],"Bskill_man_gold1.png":["夜烟0","斑点1"],"Bskill_man_spd%26trade.png":["清流1"],"Bskill_man_spd_bd_n1.png":["迷迭香0"],"Bskill_man_spd_bd1.png":["迷迭香0"],"Bskill_man_spd_bd2.png":["迷迭香2"],"Bskill_man_spd_variable21.png":["槐琥2"],"Bskill_man_spd3.png":["梅尔2"],"Bskill_man_spd2.png":["灰毫2","远牙2","野鬃2","白面鸮2","赫默2","调香师1","史都华德1","杰西卡0","水月2","罗比菈塔1","香草0"],"Bskill_man_limit%26cost3.png":["石棉2"],"Bskill_man_spd%26limit%26cost3.png":["石棉0","泡普卡0"],"Bskill_man_spd_add1.png":["芬0","刻俄柏2"],"Bskill_man_spd_add2.png":["稀音0","克洛丝0"],"Bskill_man_spd1.png":["灰毫0","远牙0","野鬃0","白面鸮0","赫默0","豆苗0","夜刀0","流星0"],"Bskill_man_spd%26power3.png":["温蒂2"],"Bskill_man_spd%26power2.png":["森蚺2","温蒂0"],"Bskill_man_spd%26power1.png":["异客2","森蚺0"],"Bskill_man_skill_spd.png":["水月0"],"Bskill_man_spd%26limit3.png":["蛇屠箱0","黑角0"],"Bskill_man_spd%26limit1.png":["卡缇0","米格鲁0"],"Bskill_man_spd%26limit%26cost2.png":["火神2"],"Bskill_man_spd%26limit%26cost1.png":["火神0"],"Bskill_man_spd%26limit%26cost4.png":["贝娜0"],"Bskill_man_exp%26limit2.png":["卡达1"],"Bskill_man_exp%26limit1.png":["稀音2"],"Bskill_man_limit%26cost2.png":["泡泡0"],"Bskill_man_spd_variable31.png":["泡泡1"],"Bskill_man_limit%26cost1.png":["帕拉斯0","刻俄柏0","豆苗1","清道夫1","红云0"],"Bskill_man_spd_variable11.png":["红云1"],"Bskill_man_exp%26cost.png":["卡达0"],"Bskill_man_originium2.png":["艾雅法拉0","锡兰2","地灵1","炎熔1"],"Bskill_man_originium1.png":["薄绿1","月见夜1"],"Bskill_man_cost_all.png":["槐琥0"],"Bskill_tra_Lappland1.png":["拉普兰德0"],"Bskill_tra_Lappland2.png":["拉普兰德2"],"Bskill_tra_texas1.png":["德克萨斯0"],"Bskill_tra_texas2.png":["德克萨斯2"],"Bskill_tra_vodfox.png":["巫恋2"],"Bskill_tra_spd3.png":["能天使2"],"Bskill_tra_spd_variable22.png":["雪雉2"],"Bskill_tra_spd%26cost.png":["古米0","月见夜0","空爆0"],"Bskill_tra_spd%26limit7.png":["可颂2","拜松2"],"Bskill_tra_spd2.png":["空2","夜刀0","夜烟1","安比尔1","慕斯0","缠丸1","芬1"],"Bskill_tra_spd%26limit6.png":["梓兰1","玫兰莎0","远山0"],"Bskill_tra_spd_variable21.png":["雪雉0"],"Bskill_tra_spd%26limit5.png":["银灰2"],"Bskill_tra_spd1.png":["可颂0","能天使0","拜松0","安德切尔0","深海色0","蛇屠箱1","香草1"],"Bskill_tra_spd%26limit4.png":["崖心2"],"Bskill_tra_spd%26limit3.png":["角峰0","讯使0","银灰0"],"Bskill_tra_spd%26limit2.png":["四月2"],"Bskill_tra_spd%26limit1.png":["四月0","翎羽1","黑角0"],"Bskill_tra_flow_gs2.png":["图耶2"],"Bskill_tra_flow_gs1.png":["图耶0"],"Bskill_tra_flow_gc2.png":["绮良2"],"Bskill_tra_flow_gc1.png":["绮良0"],"Bskill_tra_limit_diff.png":["孑0"],"Bskill_tra_limit_count.png":["孑1"],"Bskill_tra_spd%26dorm2.png":["空弦2"],"Bskill_tra_spd%26dorm1.png":["空弦0"],"Bskill_tra_wt%26cost2.png":["柏喙2","卡夫卡2"],"Bskill_tra_wt%26cost1.png":["巫恋0","柏喙0","贝娜2","卡夫卡0"],"Bskill_tra_bd_n2.png":["乌有2"],"Bskill_tra_long2.png":["龙舌兰2"],"Bskill_tra_long1.png":["龙舌兰0"],"Bskill_tra_limit%26cost.png":["史都华德0","暗索1","桃金娘0"],"Bskill_dorm_all%26one2.png":["杜林0"],"Bskill_dorm_all%26one1.png":["安比尔0","杜林0"],"Bskill_dorm_all3.png":["推进之王2","夜莺2","凛冬2"],"Bskill_dorm_all2.png":["阿米娅2","空0","波登可1","凛冬0","推进之王0","桃金娘1"],"Bskill_dorm_all%26one3.png":["远牙0","风笛0","赫拉格2"],"Bskill_dorm_all1.png":["赫拉格1","四月0","夜莺0"],"Bskill_dorm_all%26bd_n1_n2.png":["爱丽丝0"],"Bskill_dorm_all%26bd_n1.png":["爱丽丝2"],"Bskill_dorm_single4.png":["闪灵2"],"Bskill_dorm_single3.png":["琴柳0","蜜莓2","断罪者0"],"Bskill_dorm_single2.png":["波登可1","Lancet-20"],"Bskill_dorm_single_schwarz.png":["黑0"],"Bskill_dorm_single_tomimi.png":["特米米0"],"Bskill_dorm_single_indigo.png":["深靛0"],"Bskill_dorm_single1.png":["安赛尔0","末药1","波登可0","流星1","芙蓉0","闪灵0"],"Bskill_dorm_single%26one22.png":["临光2","初雪0"],"Bskill_dorm_single%26one21.png":["泡普卡1"],"Bskill_dorm_single%26one12.png":["酸糖1","古米1","暴行2"],"Bskill_dorm_single%26one11.png":["慕斯1"],"Bskill_dorm_single%26one02.png":["崖心0"],"Bskill_dorm_single%26one01.png":["卡缇1","杰克0","米格鲁1"],"Bskill_dorm_one5.png":["斯卡蒂2"],"Bskill_dorm_one4.png":["幽灵鲨2","安哲拉2"],"Bskill_dorm_one3.png":["伊桑1"],"Bskill_dorm_one.png":["芳汀1"],"Bskill_dorm_one2.png":["克洛丝1","安哲拉0","幽灵鲨0","斯卡蒂0","灰喉2","艾丝黛尔1","苇草0","霜叶0"],"Bskill_dorm_one1.png":["赫拉格0"],"Bskill_ws_nian.png":["年0"],"Bskill_ws_evolve4.png":["年0"],"Bskill_ws_evolve_dorm2.png":["芳汀1"],"Bskill_ws_evolve_dorm1.png":["芳汀0"],"Bskill_ws_constant.png":["泥岩0"],"Bskill_ws_orirock.png":["泥岩2"],"Bskill_ws_polyester.png":["奥斯塔2"],"Bskill_ws_oriron.png":["熔泉2"],"Bskill_ws_device.png":["贾维2"],"Bskill_ws_evolve3.png":["锡兰0","蜜莓2","蚀清2","空爆1","陨星2","蓝毒2","苏苏洛1"],"Bskill_ws_drop_oriron.png":["蚀清2"],"Bskill_ws_evolve2.png":["慑砂2","蜜莓0","蚀清0","陨星0","亚叶0","蓝毒0","调香师0","嘉维尔0","安赛尔1","末药0"],"Bskill_ws_evolve_cost.png":["亚叶2"],"Bskill_ws_evolve1.png":["芙蓉1"],"Bskill_ws_cost_blemishine.png":["瑕光2"],"Bskill_ws_free.png":["瑕光0"],"Bskill_ws_build3.png":["煌1"],"Bskill_ws_build_cost2.png":["莱恩哈特2"],"Bskill_ws_build2.png":["莱恩哈特0"],"Bskill_ws_build_cost.png":["松果1"],"Bskill_ws_build1.png":["松果0","罗比菈塔0","阿消0"],"Bskill_ws_skill3.png":["赫拉格0","炎客2"],"Bskill_ws_skill_cost1.png":["羽毛笔0"],"Bskill_ws_skill2.png":["羽毛笔2"],"Bskill_ws_skill1.png":["暴行0","炎客0","缠丸0"],"Bskill_ws_asc2.png":["风笛2"],"Bskill_ws_asc_cost1.png":["刻刀1"],"Bskill_ws_asc1.png":["12F0","刻刀0","猎蜂1"],"Bskill_ws_p5.png":["凯尔希0"],"Bskill_ws_p4.png":["梅尔0"],"Bskill_ws_p3.png":["深海色1","艾丝黛尔0","巡林者0"],"Bskill_ws_p2.png":["棘刺0","麦哲伦0","吽0","安德切尔1","斑点0","格雷伊1"],"Bskill_ws_recovery.png":["棘刺2"],"Bskill_ws_cost_magallan.png":["麦哲伦2"],"Bskill_ws_frost.png":["霜华2"],"Bskill_ws_p1.png":["玫兰莎1","砾0"],"Bskill_ws_evolve_cost2.png":["慑砂0"],"Bskill_ws_evolve_cost1.png":["熔泉0","奥斯塔0","贾维0"],"Bskill_hire_skgoat.png":["地灵1"],"Bskill_hire_spd5.png":["普罗旺斯2","艾雅法拉2"],"Bskill_hire_spd4.png":["伊桑0","酸糖0","夜魔2","宴0","梓兰0"],"Bskill_hire_spd%26clue.png":["月禾2","乌有0"],"Bskill_hire_spd2.png":["地灵0","普罗旺斯0","月禾0"],"Bskill_hire_spd%26ursus2.png":["早露2"],"Bskill_hire_spd%26blacksteel2.png":["山0"],"Bskill_hire_spd_bd_n1_n1.png":["絮雨0"],"Bskill_hire_spd_memento.png":["絮雨2"],"Bskill_hire_spd%26cost2.png":["桑葚1"],"Bskill_hire_spd_bd_n2.png":["桑葚2"],"Bskill_hire_blitz.png":["闪击2"],"Bskill_hire_spd1.png":["巡林者0"],"Bskill_hire_spd%26cost1.png":["桑葚0"],"Bskill_train_vanguard3.png":["嵯峨2"],"Bskill_train_vanguard2.png":["格拉尼2","红豆1"],"Bskill_train_vanguard1.png":["嵯峨0","格拉尼0","翎羽0"],"Bskill_train3_guard1.png":["铸铁2"],"Bskill_train2_guard1.png":["燧石2"],"Bskill_train1_guard1.png":["赤冬2"],"Bskill_train_guard3.png":["史尔特尔2"],"Bskill_train_guard2.png":["布洛卡2","芙兰卡2"],"Bskill_train_guard1.png":["史尔特尔0","布洛卡0","燧石0","猎蜂0","芙兰卡0","赤冬0","铸铁0","鞭刃0"],"Bskill_train2_defender1.png":["暴雨2"],"Bskill_train_defender3.png":["星熊2"],"Bskill_train_defender2.png":["角峰1"],"Bskill_train_defender1.png":["坚雷0","星熊0","暴雨0"],"Bskill_train3_sniper2.png":["W2"],"Bskill_train_w.png":["W2"],"Bskill_train1_sniper2.png":["假日威龙陈2"],"Bskill_train_sniper3.png":["黑2"],"Bskill_train_sniper2.png":["白金2"],"Bskill_train_sniper1.png":["W0","假日威龙陈0","白金0","送葬人0"],"Bskill_train2_caster1.png":["薄绿2"],"Bskill_train_caster3.png":["卡涅利安2"],"Bskill_train1_caster1.png":["特米米2"],"Bskill_train_caster2.png":["天火2","蜜蜡2"],"Bskill_train_caster1.png":["卡涅利安0","夜魔0","天火0","薄绿0","蜜蜡0"],"Bskill_train3_supporter2.png":["浊心斯卡蒂2"],"Bskill_train_chen.png":["假日威龙陈2"],"Bskill_train_skadi.png":["浊心斯卡蒂2"],"Bskill_train_supporter3.png":["铃兰2"],"Bskill_train_supporter2.png":["初雪2"],"Bskill_train_supporter1.png":["浊心斯卡蒂0","真理0","铃兰0"],"Bskill_train_medic3.png":["阿2"],"Bskill_train_medic2.png":["华法琳2"],"Bskill_train_medic1.png":["华法琳0","嘉维尔1","苏苏洛0"],"Bskill_train1_specialist1.png":["罗宾2"],"Bskill_train_specialist3.png":["傀影2"],"Bskill_train_specialist2.png":["狮蝎2"],"Bskill_train_specialist1.png":["傀影0","狮蝎0","罗宾0"],"Bskill_train_all.png":["杜宾1","诗怀雅2","鞭刃2"],"Bskill_train_knight_bd1.png":["耀骑士临光0"],"Bskill_train_knight_bd2.png":["耀骑士临光2"],"Bskill_meet_rhodes2.png":["安洁莉娜2"],"Bskill_meet_rhodes1.png":["极境0"],"Bskill_meet_flag_rhodes.png":["极境2"],"Bskill_meet_kjerag2.png":["讯使1"],"Bskill_meet_glasgow2.png":["因陀罗2","微风2"],"Bskill_meet_ursus2.png":["真理2"],"Bskill_meet_ursus1.png":["苦艾0"],"Bskill_meet_flag_ursus.png":["苦艾2"],"Bskill_meet_blacksteel2.png":["芙兰卡2","杰西卡1"],"Bskill_meet_penguin2.png":["莫斯提马2"],"Bskill_meet_penguin1.png":["梅1"],"Bskill_meet_rhine2.png":["塞雷娅2"],"Bskill_meet_flag_rhine.png":["山2"],"Bskill_meet_spd3.png":["陈2","红2","星极2","远山1"],"Bskill_meet_spd2.png":["12F0","守林人2","宴1","断崖2","暗索0","杰克1","梅0","白雪0"],"Bskill_meet_spd1.png":["因陀罗0","塞雷娅0","守林人0","安洁莉娜0","微风0","断崖0","星极0","芙兰卡0","莫斯提马0"]}')
-- 扩充干员等级 
for k, v in pairs(skillpng2operator) do
  local extra = {}
  for _, o in pairs(v) do if o:endsWith('1') then table.insert(extra, 1) end end
  table.extend(v, extra)
end
-- 只有1个技能干员
skillpng2operator['empty2.png'] = table.appear_times(table.flatten(
                                                       skillpng2operator), 1)
-- 所有干员
skillpng2operator['empty1.png'] = table.remove_duplicate(table.flatten(
                                                           skillpng2operator))

-- log(table.flatten(skillpng2operator))
-- log("skillpng2operator",skillpng2operator["empty2.png"])
-- exit()

-- 制造站干员选择
-- operator: 列表，每个元素包含两个技能图标与心情
-- tradingStationNum: 贸易站数量
-- type: 制造物类别
-- level: 制造站等级
-- 返回效率最高的index
manufacturingStationOperatorBest = function(operator, tradingStationNum, type,
                                            level)
  -- 参考 https://prts.wiki/w/罗德岛基建/制造站
  local maxStorage, maxOperator
  maxOperator = level
  local workhour = 8
  if level == 1 then
    maxStorage = 24
  elseif level == 2 then
    maxStorage = 36
  else
    maxStorage = 54
  end
  log("maxStorage", maxStorage)
  log("maxOperator", maxOperator)

  -- 输入index组合，计算8小时平均加成，心情12以上才允许。
  local base, disable_moon_effect, mood, storage, standard, all
  local score = function(c)
    base = 0
    storage = 0
    standard = 0
    all = {}
    for i = 1,#level do
      if c[i][3] <minmood then
        minmood = c[i][3]
      end
    end
    for i = 1, #level do
      if 0 then
      elseif c[i][1] == 'Bskill_man_exp3.png' then
        if type == '作战记录' then
          base = base + 0.35
        end
      elseif c[i][1] == 'Bskill_man_exp2.png' then
        if type == '作战记录' then
          base = base + 0.30
        end
      elseif c[i][1] == 'Bskill_man_exp1.png' then
        if type == '作战记录' then
          base = base + 0.25
        end
      elseif c[i][1] == 'Bskill_man_gold2.png' then
        if type == '贵金属' then
          base = base + 0.35
        end
      elseif c[i][1] == 'Bskill_man_gold1.png' then
        if type == '贵金属' then
          base = base + 0.30
        end
      elseif c[i][1] == 'Bskill_man_spd%26trade.png' then
        if type == '贵金属' then
          base = base + 0.20
        end

        -- 迷迭香不考虑
      elseif c[i][1] == 'Bskill_man_spd_bd_n1.png' then
      elseif c[i][1] == 'Bskill_man_spd_bd1.png' then
      elseif c[i][1] == 'Bskill_man_spd_bd2.png' then

      elseif c[i][1] == 'Bskill_man_spd3.png' then
        base = base + 0.30
      elseif c[i][1] == 'Bskill_man_spd2.png' then
        base = base + 0.25
      elseif c[i][1] == 'Bskill_man_limit%26cost3.png' then
        base = base + 0.25
      elseif c[i][1] == 'Bskill_man_spd_add1.png' then
        for j = 1, min(c[i][3], workhour) do
          base = base + j <= 5 and (0.20 + (j - 1) * 0.01) or 0.25
        end
      elseif c[i][1] == 'Bskill_man_spd_add2.png' then
        for j = 1, min(c[i][3], workhour) do
          base = base + j <= 5 and (0.15 + (j - 1) * 0.02) or 0.25
        end
      elseif c[i][1] == 'Bskill_man_spd1.png' then
        base = base + 0.15 *
                 min(c[i][3] / (disable_moon_effect and 1 or 1.25), workhour)
      elseif c[i][1] == 'Bskill_man_spd%26limit3.png' then
        base = base + 0.1 * min(c[i][3], workhour)
      elseif c[i][1] == 'Bskill_man_spd%26limit1.png' then
        base = base + 0.1 * min(c[i][3], workhour)
      elseif c[i][1] == 'Bskill_man_spd%26limit%26cost2.png' then
      elseif c[i][1] == 'Bskill_man_spd%26limit%26cost1.png' then
      elseif c[i][1] == 'Bskill_man_spd%26limit%26cost4.png' then
      elseif c[i][1] == 'Bskill_man_exp%26limit2.png' then
      elseif c[i][1] == 'Bskill_man_exp%26limit1.png' then
      elseif c[i][1] == 'Bskill_man_limit%26cost2.png' then
      elseif c[i][1] == 'Bskill_man_limit%26cost1.png' then
      elseif c[i][1] == 'Bskill_man_exp%26cost.png' then
        if type == '作战记录' then end
      elseif c[i][1] == 'Bskill_man_originium2.png' then
        if type == '源石' then
          base = base + 0.35 * min(c[i][3], workhour)
        end
      elseif c[i][1] == 'Bskill_man_originium1.png' then
        if type == '源石' then
          base = base + 0.3 * min(c[i][3], workhour)
        end
      elseif c[i][1] == 'empty.png' then
        log('empty')
      else
        stop()
      end
    end

    -- 检查是否有需要全局考虑技能
    for i = 1, #level do
      all[c[i][1]] = 1
      all[c[i][2]] = 1
    end

    -- 消除心情消耗
    if all['Bskill_man_cost_all.png'] then disable_moon_effect = true end
    if all['Bskill_man_spd_variable31.png'] then
      -- 泡泡，需要
    end
    if all['Bskill_man_spd_variable21.png'] then
      -- 虎，需要优先
    end
    if all['Bskill_man_spd_variable11.png'] then
      -- 红云，需要优先
    end
    if 0 then
    elseif c[i][1] == 'Bskill_man_spd%26power3.png' then
      -- 需要优先，发电站数
    elseif c[i][1] == 'Bskill_man_spd%26power2.png' then
    elseif c[i][1] == 'Bskill_man_spd%26power1.png' then
    elseif c[i][1] == 'Bskill_man_skill_spd.png' then
      -- 水月
      -- 需计算标准化技能数量
    end

    return base
  end

  -- 遍历全部组合
  local best
  local best_score = -1
  for _, c in pairs(table.combination(range(1, #operator), maxOperator)) do
    local s = score(c)
    if s > best_score then
      best = c
      best_score = s
    end
  end
  return best
end

