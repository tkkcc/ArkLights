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
      v[1] + scale(7), v[2] + scale(19), v[1] + scale(60), v[2] + scale(70),
    }
    local icon2 = {
      v[1] + scale(70), v[2] + scale(19), v[1] + scale(60), v[2] + scale(70),
    }

    png = g(icon1[1], icon1[2]) or 'empty1'
    operator = skillpng2operator[png]
    if #operator == 1 then

    else
      png = g(icon2[1], icon2[2]) or 'empty2'
      operator2 = skillpng2operator[png]
      operator = table.intersect(operator, operator2)
    end

    log(operator)

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

-- LuaFormatter off
skillpng = {
"Bskill_ctrl_aegir2.png",
"Bskill_ctrl_aegir.png",
"Bskill_ctrl_ash.png",
"Bskill_ctrl_cost_aegir.png",
"Bskill_ctrl_cost_bd1.png",
"Bskill_ctrl_cost_bd2.png",
"Bskill_ctrl_cost.png",
"Bskill_ctrl_c_wt1.png",
"Bskill_ctrl_c_wt2.png",
"Bskill_ctrl_c_wt.png",
"Bskill_ctrl_h_spd.png",
"Bskill_ctrl_lda.png",
"Bskill_ctrl_lungmen.png",
"Bskill_ctrl_p_bot.png",
"Bskill_ctrl_psk.png",
"Bskill_ctrl_p_spd.png",
"Bskill_ctrl_r6.png",
"Bskill_ctrl_sp.png",
"Bskill_ctrl_tachanka.png",
"Bskill_ctrl_token_p_spd.png",
"Bskill_ctrl_t_spd.png",
"Bskill_ctrl_ussg.png",
"Bskill_dorm_all1.png",
"Bskill_dorm_all%26bd_n1_n2.png",
"Bskill_dorm_all%26bd_n1.png",
"Bskill_dorm_all%26one1.png",
"Bskill_dorm_all%26one2.png",
"Bskill_dorm_all%26one3.png",
"Bskill_dorm_all2.png",
"Bskill_dorm_all3.png",
"Bskill_dorm_one1.png",
"Bskill_dorm_one2.png",
"Bskill_dorm_one3.png",
"Bskill_dorm_one4.png",
"Bskill_dorm_one5.png",
"Bskill_dorm_one.png",
"Bskill_dorm_single1.png",
"Bskill_dorm_single%26one01.png",
"Bskill_dorm_single%26one02.png",
"Bskill_dorm_single%26one11.png",
"Bskill_dorm_single%26one12.png",
"Bskill_dorm_single%26one21.png",
"Bskill_dorm_single%26one22.png",
"Bskill_dorm_single2.png",
"Bskill_dorm_single3.png",
"Bskill_dorm_single4.png",
"Bskill_dorm_single_indigo.png",
"Bskill_dorm_single_schwarz.png",
"Bskill_dorm_single_tomimi.png",
"Bskill_hire_blitz.png",
"Bskill_hire_skgoat.png",
"Bskill_hire_spd1.png",
"Bskill_hire_spd%26blacksteel2.png",
"Bskill_hire_spd%26clue.png",
"Bskill_hire_spd%26cost1.png",
"Bskill_hire_spd%26cost2.png",
"Bskill_hire_spd%26ursus2.png",
"Bskill_hire_spd2.png",
"Bskill_hire_spd4.png",
"Bskill_hire_spd5.png",
"Bskill_hire_spd_bd_n1_n1.png",
"Bskill_hire_spd_bd_n2.png",
"Bskill_hire_spd_memento.png",
"Bskill_man_cost_all.png",
"Bskill_man_exp1.png",
"Bskill_man_exp%26cost.png",
"Bskill_man_exp%26limit1.png",
"Bskill_man_exp%26limit2.png",
"Bskill_man_exp2.png",
"Bskill_man_exp3.png",
"Bskill_man_gold1.png",
"Bskill_man_gold2.png",
"Bskill_man_limit%26cost1.png",
"Bskill_man_limit%26cost2.png",
"Bskill_man_limit%26cost3.png",
"Bskill_man_originium1.png",
"Bskill_man_originium2.png",
"Bskill_man_skill_spd.png",
"Bskill_man_spd1.png",
"Bskill_man_spd%26limit1.png",
"Bskill_man_spd%26limit%26cost1.png",
"Bskill_man_spd%26limit%26cost2.png",
"Bskill_man_spd%26limit%26cost3.png",
"Bskill_man_spd%26limit%26cost4.png",
"Bskill_man_spd%26limit3.png",
"Bskill_man_spd%26power1.png",
"Bskill_man_spd%26power2.png",
"Bskill_man_spd%26power3.png",
"Bskill_man_spd%26trade.png",
"Bskill_man_spd2.png",
"Bskill_man_spd3.png",
"Bskill_man_spd_add1.png",
"Bskill_man_spd_add2.png",
"Bskill_man_spd_bd1.png",
"Bskill_man_spd_bd2.png",
"Bskill_man_spd_bd_n1.png",
"Bskill_man_spd_variable11.png",
"Bskill_man_spd_variable21.png",
"Bskill_man_spd_variable31.png",
"Bskill_meet_blacksteel2.png",
"Bskill_meet_flag_rhine.png",
"Bskill_meet_flag_rhodes.png",
"Bskill_meet_flag_ursus.png",
"Bskill_meet_glasgow2.png",
"Bskill_meet_kjerag2.png",
"Bskill_meet_penguin1.png",
"Bskill_meet_penguin2.png",
"Bskill_meet_rhine2.png",
"Bskill_meet_rhodes1.png",
"Bskill_meet_rhodes2.png",
"Bskill_meet_spd1.png",
"Bskill_meet_spd2.png",
"Bskill_meet_spd3.png",
"Bskill_meet_ursus1.png",
"Bskill_meet_ursus2.png",
"Bskill_pow_jnight.png",
"Bskill_pow_spd1.png",
"Bskill_pow_spd%26cost.png",
"Bskill_pow_spd2.png",
"Bskill_pow_spd3.png",
"Bskill_tra_bd_n2.png",
"Bskill_tra_flow_gc1.png",
"Bskill_tra_flow_gc2.png",
"Bskill_tra_flow_gs1.png",
"Bskill_tra_flow_gs2.png",
"Bskill_train1_caster1.png",
"Bskill_train1_guard1.png",
"Bskill_train1_sniper2.png",
"Bskill_train1_specialist1.png",
"Bskill_train2_caster1.png",
"Bskill_train2_defender1.png",
"Bskill_train2_guard1.png",
"Bskill_train3_guard1.png",
"Bskill_train3_sniper2.png",
"Bskill_train3_supporter2.png",
"Bskill_train_all.png",
"Bskill_train_caster1.png",
"Bskill_train_caster2.png",
"Bskill_train_caster3.png",
"Bskill_train_chen.png",
"Bskill_train_defender1.png",
"Bskill_train_defender2.png",
"Bskill_train_defender3.png",
"Bskill_train_guard1.png",
"Bskill_train_guard2.png",
"Bskill_train_guard3.png",
"Bskill_train_knight_bd1.png",
"Bskill_train_knight_bd2.png",
"Bskill_train_medic1.png",
"Bskill_train_medic2.png",
"Bskill_train_medic3.png",
"Bskill_train_skadi.png",
"Bskill_train_sniper1.png",
"Bskill_train_sniper2.png",
"Bskill_train_sniper3.png",
"Bskill_train_specialist1.png",
"Bskill_train_specialist2.png",
"Bskill_train_specialist3.png",
"Bskill_train_supporter1.png",
"Bskill_train_supporter2.png",
"Bskill_train_supporter3.png",
"Bskill_train_vanguard1.png", "Bskill_train_vanguard2.png",
"Bskill_train_vanguard3.png",
"Bskill_train_w.png",
"Bskill_tra_Lappland1.png",
"Bskill_tra_Lappland2.png",
"Bskill_tra_limit%26cost.png",
"Bskill_tra_limit_count.png",
"Bskill_tra_limit_diff.png",
"Bskill_tra_long1.png",
"Bskill_tra_long2.png",
"Bskill_tra_spd1.png",
"Bskill_tra_spd%26cost.png",
"Bskill_tra_spd%26dorm1.png",
"Bskill_tra_spd%26dorm2.png",
"Bskill_tra_spd%26limit1.png",
"Bskill_tra_spd%26limit2.png",
"Bskill_tra_spd%26limit3.png",
"Bskill_tra_spd%26limit4.png",
"Bskill_tra_spd%26limit5.png",
"Bskill_tra_spd%26limit6.png",
"Bskill_tra_spd%26limit7.png",
"Bskill_tra_spd2.png",
"Bskill_tra_spd3.png",
"Bskill_tra_spd_variable21.png",
"Bskill_tra_spd_variable22.png",
"Bskill_tra_texas1.png",
"Bskill_tra_texas2.png",
"Bskill_tra_vodfox.png",
"Bskill_tra_wt%26cost1.png",
"Bskill_tra_wt%26cost2.png",
"Bskill_ws_asc1.png",
"Bskill_ws_asc2.png",
"Bskill_ws_asc_cost1.png",
"Bskill_ws_build1.png",
"Bskill_ws_build2.png",
"Bskill_ws_build3.png",
"Bskill_ws_build_cost2.png",
"Bskill_ws_build_cost.png",
"Bskill_ws_constant.png",
"Bskill_ws_cost_blemishine.png",
"Bskill_ws_cost_magallan.png",
"Bskill_ws_device.png",
"Bskill_ws_drop_oriron.png",
"Bskill_ws_evolve1.png",
"Bskill_ws_evolve2.png",
"Bskill_ws_evolve3.png",
"Bskill_ws_evolve4.png",
"Bskill_ws_evolve_cost1.png",
"Bskill_ws_evolve_cost2.png",
"Bskill_ws_evolve_cost.png",
"Bskill_ws_evolve_dorm1.png",
"Bskill_ws_evolve_dorm2.png",
"Bskill_ws_free.png",
"Bskill_ws_frost.png",
"Bskill_ws_nian.png",
"Bskill_ws_orirock.png",
"Bskill_ws_oriron.png",
"Bskill_ws_p1.png",
"Bskill_ws_p2.png",
"Bskill_ws_p3.png",
"Bskill_ws_p4.png",
"Bskill_ws_p5.png",
"Bskill_ws_polyester.png",
"Bskill_ws_recovery.png",
"Bskill_ws_skill1.png",
"Bskill_ws_skill2.png",
"Bskill_ws_skill3.png",
"Bskill_ws_skill_cost1.png",
-- "skillpng.txt",
}

skillpng2operator = JsonDecode('{"Bskill_ctrl_p_spd.png":["凯尔希"],"Bskill_ctrl_token_p_spd.png":["布丁"],"Bskill_ctrl_p_bot.png":["森蚺"],"Bskill_ctrl_t_spd.png":["阿米娅","诗怀雅"],"Bskill_ctrl_h_spd.png":["琴柳"],"Bskill_ctrl_cost_aegir.png":["歌蕾蒂娅"],"Bskill_ctrl_aegir.png":["歌蕾蒂娅"],"Bskill_ctrl_aegir2.png":["歌蕾蒂娅"],"Bskill_ctrl_psk.png":["焰尾"],"Bskill_ctrl_lda.png":["吽"],"Bskill_ctrl_lungmen.png":["陈"],"Bskill_ctrl_ussg.png":["早露"],"Bskill_ctrl_sp.png":["炎狱炎熔"],"Bskill_ctrl_cost.png":["焰尾","灰喉","苇草","暴雨","送葬人","临光","杜宾","清道夫","红","坚雷"],"Bskill_ctrl_cost_bd1.png":["夕"],"Bskill_ctrl_cost_bd2.png":["夕"],"Bskill_ctrl_ash.png":["灰烬"],"Bskill_ctrl_r6.png":["战车","灰烬","闪击","霜华"],"Bskill_ctrl_tachanka.png":["战车"],"Bskill_ctrl_c_wt.png":["阿"],"Bskill_ctrl_c_wt2.png":["惊蛰"],"Bskill_ctrl_c_wt1.png":["惊蛰"],"Bskill_pow_spd3.png":["雷蛇","炎狱炎熔","格雷伊"],"Bskill_pow_spd2.png":["伊芙利特","异客","格劳克斯","深靛","雷蛇","布丁","阿消","清流"],"Bskill_pow_spd1.png":["异客","格劳克斯","深靛","伊芙利特","炎熔","煌","Castle-3","Lancet-2","THRM-EX","正义骑士号"],"Bskill_pow_spd%26cost.png":["THRM-EX"],"Bskill_pow_jnight.png":["正义骑士号"],"Bskill_man_exp3.png":["断罪者","食铁兽"],"Bskill_man_exp2.png":["Castle-3","白雪","红豆","霜叶","食铁兽"],"Bskill_man_exp1.png":["帕拉斯"],"Bskill_man_gold2.png":["砾"],"Bskill_man_gold1.png":["夜烟","斑点"],"Bskill_man_spd%26trade.png":["清流"],"Bskill_man_spd_bd_n1.png":["迷迭香"],"Bskill_man_spd_bd1.png":["迷迭香"],"Bskill_man_spd_bd2.png":["迷迭香"],"Bskill_man_spd_variable21.png":["槐琥"],"Bskill_man_spd3.png":["梅尔"],"Bskill_man_spd2.png":["灰毫","远牙","野鬃","白面鸮","赫默","调香师","史都华德","杰西卡","水月","罗比菈塔","香草"],"Bskill_man_limit%26cost3.png":["石棉"],"Bskill_man_spd%26limit%26cost3.png":["石棉","泡普卡"],"Bskill_man_spd_add1.png":["芬","刻俄柏"],"Bskill_man_spd_add2.png":["稀音","克洛丝"],"Bskill_man_spd1.png":["灰毫","远牙","野鬃","白面鸮","赫默","豆苗","夜刀","流星"],"Bskill_man_spd%26power3.png":["温蒂"],"Bskill_man_spd%26power2.png":["森蚺","温蒂"],"Bskill_man_spd%26power1.png":["异客","森蚺"],"Bskill_man_skill_spd.png":["水月"],"Bskill_man_spd%26limit3.png":["蛇屠箱","黑角"],"Bskill_man_spd%26limit1.png":["卡缇","米格鲁"],"Bskill_man_spd%26limit%26cost2.png":["火神"],"Bskill_man_spd%26limit%26cost1.png":["火神"],"Bskill_man_spd%26limit%26cost4.png":["贝娜"],"Bskill_man_exp%26limit2.png":["卡达"],"Bskill_man_exp%26limit1.png":["稀音"],"Bskill_man_limit%26cost2.png":["泡泡"],"Bskill_man_spd_variable31.png":["泡泡"],"Bskill_man_limit%26cost1.png":["帕拉斯","刻俄柏","豆苗","清道夫","红云"],"Bskill_man_spd_variable11.png":["红云"],"Bskill_man_exp%26cost.png":["卡达"],"Bskill_man_originium2.png":["艾雅法拉","锡兰","地灵","炎熔"],"Bskill_man_originium1.png":["薄绿","月见夜"],"Bskill_man_cost_all.png":["槐琥"],"Bskill_tra_Lappland1.png":["拉普兰德"],"Bskill_tra_Lappland2.png":["拉普兰德"],"Bskill_tra_texas1.png":["德克萨斯"],"Bskill_tra_texas2.png":["德克萨斯"],"Bskill_tra_vodfox.png":["巫恋"],"Bskill_tra_spd3.png":["能天使"],"Bskill_tra_spd_variable22.png":["雪雉"],"Bskill_tra_spd%26cost.png":["古米","月见夜","空爆"],"Bskill_tra_spd%26limit7.png":["可颂","拜松"],"Bskill_tra_spd2.png":["空","夜刀","夜烟","安比尔","慕斯","缠丸","芬"],"Bskill_tra_spd%26limit6.png":["梓兰","玫兰莎","远山"],"Bskill_tra_spd_variable21.png":["雪雉"],"Bskill_tra_spd%26limit5.png":["银灰"],"Bskill_tra_spd1.png":["可颂","能天使","拜松","安德切尔","深海色","蛇屠箱","香草"],"Bskill_tra_spd%26limit4.png":["崖心"],"Bskill_tra_spd%26limit3.png":["角峰","讯使","银灰"],"Bskill_tra_spd%26limit2.png":["四月"],"Bskill_tra_spd%26limit1.png":["四月","翎羽","黑角"],"Bskill_tra_flow_gs2.png":["图耶"],"Bskill_tra_flow_gs1.png":["图耶"],"Bskill_tra_flow_gc2.png":["绮良"],"Bskill_tra_flow_gc1.png":["绮良"],"Bskill_tra_limit_diff.png":["孑"],"Bskill_tra_limit_count.png":["孑"],"Bskill_tra_spd%26dorm2.png":["空弦"],"Bskill_tra_spd%26dorm1.png":["空弦"],"Bskill_tra_wt%26cost2.png":["柏喙","卡夫卡"],"Bskill_tra_wt%26cost1.png":["巫恋","柏喙","贝娜","卡夫卡"],"Bskill_tra_bd_n2.png":["乌有"],"Bskill_tra_long2.png":["龙舌兰"],"Bskill_tra_long1.png":["龙舌兰"],"Bskill_tra_limit%26cost.png":["史都华德","暗索","桃金娘"],"Bskill_dorm_all%26one2.png":["杜林"],"Bskill_dorm_all%26one1.png":["安比尔","杜林"],"Bskill_dorm_all3.png":["推进之王","夜莺","凛冬"],"Bskill_dorm_all2.png":["阿米娅","空","波登可","凛冬","推进之王","桃金娘"],"Bskill_dorm_all%26one3.png":["远牙","风笛","赫拉格"],"Bskill_dorm_all1.png":["赫拉格","四月","夜莺"],"Bskill_dorm_all%26bd_n1_n2.png":["爱丽丝"],"Bskill_dorm_all%26bd_n1.png":["爱丽丝"],"Bskill_dorm_single4.png":["闪灵"],"Bskill_dorm_single3.png":["琴柳","蜜莓","断罪者"],"Bskill_dorm_single2.png":["波登可","Lancet-2"],"Bskill_dorm_single_schwarz.png":["黑"],"Bskill_dorm_single_tomimi.png":["特米米"],"Bskill_dorm_single_indigo.png":["深靛"],"Bskill_dorm_single1.png":["安赛尔","末药","波登可","流星","芙蓉","闪灵"],"Bskill_dorm_single%26one22.png":["临光","初雪"],"Bskill_dorm_single%26one21.png":["泡普卡"],"Bskill_dorm_single%26one12.png":["酸糖","古米","暴行"],"Bskill_dorm_single%26one11.png":["慕斯"],"Bskill_dorm_single%26one02.png":["崖心"],"Bskill_dorm_single%26one01.png":["卡缇","杰克","米格鲁"],"Bskill_dorm_one5.png":["斯卡蒂"],"Bskill_dorm_one4.png":["幽灵鲨","安哲拉"],"Bskill_dorm_one3.png":["伊桑"],"Bskill_dorm_one.png":["芳汀"],"Bskill_dorm_one2.png":["克洛丝","安哲拉","幽灵鲨","斯卡蒂","灰喉","艾丝黛尔","苇草","霜叶"],"Bskill_dorm_one1.png":["赫拉格"],"Bskill_ws_nian.png":["年"],"Bskill_ws_evolve4.png":["年"],"Bskill_ws_evolve_dorm2.png":["芳汀"],"Bskill_ws_evolve_dorm1.png":["芳汀"],"Bskill_ws_constant.png":["泥岩"],"Bskill_ws_orirock.png":["泥岩"],"Bskill_ws_polyester.png":["奥斯塔"],"Bskill_ws_oriron.png":["熔泉"],"Bskill_ws_device.png":["贾维"],"Bskill_ws_evolve3.png":["锡兰","蜜莓","蚀清","空爆","陨星","蓝毒","苏苏洛"],"Bskill_ws_drop_oriron.png":["蚀清"],"Bskill_ws_evolve2.png":["慑砂","蜜莓","蚀清","陨星","亚叶","蓝毒","调香师","嘉维尔","安赛尔","末药"],"Bskill_ws_evolve_cost.png":["亚叶"],"Bskill_ws_evolve1.png":["芙蓉"],"Bskill_ws_cost_blemishine.png":["瑕光"],"Bskill_ws_free.png":["瑕光"],"Bskill_ws_build3.png":["煌"],"Bskill_ws_build_cost2.png":["莱恩哈特"],"Bskill_ws_build2.png":["莱恩哈特"],"Bskill_ws_build_cost.png":["松果"],"Bskill_ws_build1.png":["松果","罗比菈塔","阿消"],"Bskill_ws_skill3.png":["赫拉格","炎客"],"Bskill_ws_skill_cost1.png":["羽毛笔"],"Bskill_ws_skill2.png":["羽毛笔"],"Bskill_ws_skill1.png":["暴行","炎客","缠丸"],"Bskill_ws_asc2.png":["风笛"],"Bskill_ws_asc_cost1.png":["刻刀"],"Bskill_ws_asc1.png":["12F","刻刀","猎蜂"],"Bskill_ws_p5.png":["凯尔希"],"Bskill_ws_p4.png":["梅尔"],"Bskill_ws_p3.png":["深海色","艾丝黛尔","巡林者"],"Bskill_ws_p2.png":["棘刺","麦哲伦","吽","安德切尔","斑点","格雷伊"],"Bskill_ws_recovery.png":["棘刺"],"Bskill_ws_cost_magallan.png":["麦哲伦"],"Bskill_ws_frost.png":["霜华"],"Bskill_ws_p1.png":["玫兰莎","砾"],"Bskill_ws_evolve_cost2.png":["慑砂"],"Bskill_ws_evolve_cost1.png":["熔泉","奥斯塔","贾维"],"Bskill_hire_skgoat.png":["地灵"],"Bskill_hire_spd5.png":["普罗旺斯","艾雅法拉"],"Bskill_hire_spd4.png":["伊桑","酸糖","夜魔","宴","梓兰"],"Bskill_hire_spd%26clue.png":["月禾","乌有"],"Bskill_hire_spd2.png":["地灵","普罗旺斯","月禾"],"Bskill_hire_spd%26ursus2.png":["早露"],"Bskill_hire_spd%26blacksteel2.png":["山"],"Bskill_hire_spd_bd_n1_n1.png":["絮雨"],"Bskill_hire_spd_memento.png":["絮雨"],"Bskill_hire_spd%26cost2.png":["桑葚"],"Bskill_hire_spd_bd_n2.png":["桑葚"],"Bskill_hire_blitz.png":["闪击"],"Bskill_hire_spd1.png":["巡林者"],"Bskill_hire_spd%26cost1.png":["桑葚"],"Bskill_train_vanguard3.png":["嵯峨"],"Bskill_train_vanguard2.png":["格拉尼","红豆"],"Bskill_train_vanguard1.png":["嵯峨","格拉尼","翎羽"],"Bskill_train3_guard1.png":["铸铁"],"Bskill_train2_guard1.png":["燧石"],"Bskill_train1_guard1.png":["赤冬"],"Bskill_train_guard3.png":["史尔特尔"],"Bskill_train_guard2.png":["布洛卡","芙兰卡"],"Bskill_train_guard1.png":["史尔特尔","布洛卡","燧石","猎蜂","芙兰卡","赤冬","铸铁","鞭刃"],"Bskill_train2_defender1.png":["暴雨"],"Bskill_train_defender3.png":["星熊"],"Bskill_train_defender2.png":["角峰"],"Bskill_train_defender1.png":["坚雷","星熊","暴雨"],"Bskill_train3_sniper2.png":["W"],"Bskill_train_w.png":["W"],"Bskill_train1_sniper2.png":["假日威龙陈"],"Bskill_train_sniper3.png":["黑"],"Bskill_train_sniper2.png":["白金"],"Bskill_train_sniper1.png":["W","假日威龙陈","白金","送葬人"],"Bskill_train2_caster1.png":["薄绿"],"Bskill_train_caster3.png":["卡涅利安"],"Bskill_train1_caster1.png":["特米米"],"Bskill_train_caster2.png":["天火","蜜蜡"],"Bskill_train_caster1.png":["卡涅利安","夜魔","天火","薄绿","蜜蜡"],"Bskill_train3_supporter2.png":["浊心斯卡蒂"],"Bskill_train_chen.png":["假日威龙陈"],"Bskill_train_skadi.png":["浊心斯卡蒂"],"Bskill_train_supporter3.png":["铃兰"],"Bskill_train_supporter2.png":["初雪"],"Bskill_train_supporter1.png":["浊心斯卡蒂","真理","铃兰"],"Bskill_train_medic3.png":["阿"],"Bskill_train_medic2.png":["华法琳"],"Bskill_train_medic1.png":["华法琳","嘉维尔","苏苏洛"],"Bskill_train1_specialist1.png":["罗宾"],"Bskill_train_specialist3.png":["傀影"],"Bskill_train_specialist2.png":["狮蝎"],"Bskill_train_specialist1.png":["傀影","狮蝎","罗宾"],"Bskill_train_all.png":["杜宾","诗怀雅","鞭刃"],"Bskill_train_knight_bd1.png":["耀骑士临光"],"Bskill_train_knight_bd2.png":["耀骑士临光"],"Bskill_meet_rhodes2.png":["安洁莉娜"],"Bskill_meet_rhodes1.png":["极境"],"Bskill_meet_flag_rhodes.png":["极境"],"Bskill_meet_kjerag2.png":["讯使"],"Bskill_meet_glasgow2.png":["因陀罗","微风"],"Bskill_meet_ursus2.png":["真理"],"Bskill_meet_ursus1.png":["苦艾"],"Bskill_meet_flag_ursus.png":["苦艾"],"Bskill_meet_blacksteel2.png":["芙兰卡","杰西卡"],"Bskill_meet_penguin2.png":["莫斯提马"],"Bskill_meet_penguin1.png":["梅"],"Bskill_meet_rhine2.png":["塞雷娅"],"Bskill_meet_flag_rhine.png":["山"],"Bskill_meet_spd3.png":["陈","红","星极","远山"],"Bskill_meet_spd2.png":["12F","守林人","宴","断崖","暗索","杰克","梅","白雪"],"Bskill_meet_spd1.png":["因陀罗","塞雷娅","守林人","安洁莉娜","微风","断崖","星极","芙兰卡","莫斯提马"]}')
-- 有技能干员
skillpng2operator.empty1 = table.remove_duplicate(table.flatten(skillpng2operator))
log(skillpng2operator.empty1)
-- 只有1个技能干员
skillpng2operator.empty2 = table.appear_times(table.flatten(skillpng2operator),1)

-- log("skillpng2operator",skillpng2operator)
-- exit()

-- LuaFormatter on
--
--
--
--
