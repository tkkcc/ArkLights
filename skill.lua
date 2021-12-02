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
  -- local card = {}
  -- table.insert(card, findOne("第一干员卡片"))
  -- table.insert(card, {card[1][1], scale(801)})
  local card = {}
  if #corner == 0 then stop("基建换班2115") end
  for _, v in pairs(corner) do
    table.insert(card, {v.x, v.y})
    table.insert(card, {v.x, scale(801)})
  end
  log(card)
  -- local pic = table.join(skillpng, "|")
  -- pic = 'Bskill_ws_evolve3.png'
  -- pic = 'aaa.png'
  -- w, h, t = getImage(pic)
  -- log(w, h)
  for _, v in pairs(card) do
    -- 技能判断
    local icon1 = {
      v[1] + scale(7), v[2] + scale(18), v[1] + scale(60), v[2] + scale(70),
    }
    local icon2 = {
      v[1] + scale(70), v[2] + scale(18), v[1] + scale(60), v[2] + scale(70),
    }

    -- local ret, x, y = findPicEx(icon1[1]-10, icon1[2]-10, icon1[3] + 10, icon1[4] + 10,
    --                             pic, 0.6)
    -- -- local ret, x, y = findImage(0, 0, 0, 0, pic, 0.8)
    -- log(icon1, ret, x, y)
    -- if ret > 0 then log(skillpng[ret]) end
    exit()

    -- 心情判断
    local moon = 0
    -- log(v[1])
    local moon1 = {v[1] + scale(49), v[2] + scale(93)}
    -- log(moon1)
    for i = 24, 1, -1 do
      local mooni = {moon1[1] + scale((i - 1) * 5.3478), moon1[2]}
      -- log(mooni, getColor(mooni[1], mooni[2]))
      -- if getColor(mooni[1], mooni[2]) == 'FFFFFF' then
      if cmpColor(mooni[1], mooni[2], 'FFFFFF', 0.5) == 1 then
        moon = i
        break
      end
    end
    -- log(v, moon)
    -- if moon == 19 then break end
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
"Bskill_train_vanguard1.png",
"Bskill_train_vanguard2.png",
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
-- LuaFormatter on

