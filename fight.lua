discoverBeforeFight = still_wrapper(function(operators, pngdata, pageid)
  local prewhite = 0
  local y = scale(504)
  local corner = {}
  for x = scale(543), scale(1590) do
    if cmpColor(x, y, 'FFFFFF', default_findcolor_confidence) == 1 then
      prewhite = prewhite + 1
    elseif prewhite > scale(5) and
      cmpColor(x, y, '333333', default_findcolor_confidence) == 1 then
      prewhite = 0
      table.insert(corner, x)
    end
  end
  log(113, corner)

  local card = {}
  if #corner == 0 then
    log("找不到干员卡片")
    return
  end
  local prex = -math.huge
  for _, x in pairs(corner) do
    if x - prex > scale(207) then
      prex = x
      table.insert(card, {x - scale(6), scale(129)})
      table.insert(card, {x - scale(6), scale(553)})
    end
  end

  log(114, card)
  -- card = {card[3]}
  card = {card[7]}
  for idx, v in pairs(card) do
    -- 头像判断
    -- local y
    -- y = 133 -- 0.0275
    -- y = 130 -- 0.0481
    -- y = 136 -- 0.0194
    -- y = 138 -- 0.0181
    -- y = 140 -- 0.0179
    -- y = 150 -- 0.023
    -- y = 145 -- 0.022
    -- y = 142 -- 0.0172
    -- y = 141 -- 0.0183
    -- y = 143 -- 0.0172
    --
    -- y = 559 -- 0.031
    -- y = 556 -- 0.035
    -- -- y = 565 -- 0.033
    -- -- y = 570 -- 0.039
    local icon1 = {v[1], v[2], v[1] + scale(192), v[2] + scale(192)}
    log("icon1", icon1)
    local png =
      findAvatar(icon1[1], icon1[2], icon1[3], icon1[4], avatarPngdata) or
        'empty1.png'
    log(129, png)
    table.insert(operators, {png, pageid})
  end
end)

avatar2operator = JsonDecode([[
{"char_378_asbest_whirlwind#3": "石棉", "char_140_whitew_boc#1": "拉普兰德", "char_211_adnach": "安德切尔", "char_458_rfrost_2": "霜华", "char_121_lava": "炎熔", "char_367_swllow_2": "灰喉", "char_180_amgoat": "艾雅法拉", "char_017_huang_2": "煌", "char_511_asnipe": "Stormeye", "char_208_melan_epoque#1": "玫兰莎", "char_115_headbr_marthe#2": "凛冬", "char_215_mantic": "狮蝎", "char_242_otter_ghost#1": "梅尔", "char_103_angel_wild#1": "能天使", "char_271_spikes": "芳汀", "char_340_shwaz_striker#1": "黑", "char_283_midn": "月见夜", "char_241_panda_2": "食铁兽", "char_195_glassb_2": "真理", "char_126_shotst_epoque#10": "流星", "char_440_pinecn": "松果", "char_344_beewax": " 蜜蜡", "char_108_silent_winter#2": "赫默", "char_400_weedy": "温蒂", "char_103_angel": "能天使", "char_201_moeshd_2": "可颂", "char_405_absin_2": "苦艾", "char_219_meteo_2": "陨星", "char_145_prove": "普罗旺斯", "char_141_nights": "夜烟", "char_148_nearl_summer#2": "临光", "char_218_cuttle_epoque#12": "安哲拉", "char_400_weedy_2": "温蒂", "char_484_robrta": "罗比菈塔", "char_366_acdrop": "酸糖", "char_101_sora_summer#1": "空", "char_358_lisa": "铃兰", "char_290_vigna_summer#1": "红豆", "char_452_bstalk_snow#4": "豆苗", "char_507_rsnipe": "预备干员-狙击", "char_107_liskam_2": "雷蛇", "char_164_nightm_epoque#5": "夜魔", "char_179_cgbird_2": "夜莺", "char_222_bpipe": "风笛", "char_151_myrtle_2": "桃金娘", "char_2014_nian": "年", "char_201_moeshd_kfc#1": "可 颂", "char_422_aurora_2": "极光", "char_308_swire_2": "诗怀雅", "char_367_swllow": " 灰喉", "char_137_brownb": "猎蜂", "char_277_sqrrel": "阿消", "char_350_surtr": "史尔 特尔", "char_133_mm": "梅", "char_107_liskam": "雷蛇", "char_4004_pudd_2": "布丁", "char_149_scave_2": "清道夫", "char_226_hmau_2": "吽", "char_473_mberry_epoque#14": "桑葚", "char_1013_chen2": "假日威龙陈", "char_204_platnm": "白金", "char_356_broca": " 布洛卡", "char_279_excu_2": "送葬人", "char_237_gravel_winter#2": "砾", "char_421_crow_2": "羽毛笔", "char_506_rmedic": "预备干员-后勤", "char_381_bubble": "泡泡", "char_333_sidero_2": "铸铁", "char_415_flint": "燧石", "char_501_durin": "杜林", "char_1013_chen2_2": "假日威龙陈", "char_304_zebra": "暴雨", "char_150_snakek_wild#1": "蛇屠箱", "char_144_red_2": "红", "char_420_flamtl": "焰尾", "char_128_plosis": "白面鸮", "char_459_tachak": "战车", "char_109_fmout_epoque#2": "远山", "char_225_haak_2": "阿", "char_003_kalts_2": "凯尔希", "char_108_silent_sweep#1": "赫默", "char_130_doberm": " 杜宾", "char_181_flower_daily#1": "调香师", "char_358_lisa_2": "铃兰", "char_219_meteo": "陨星", "char_492_quercu": "夏栎", "char_017_huang2": "煌", "char_355_ethan": "伊桑", "char_110_deepcl_2": "深海色", "char_328_cammou": "卡达", "char_502_nblade": "夜刀", "char_126_shotst_2": "流星", "char_195_glassb": "真理", "char_199_yak_summer#1": "角峰", "char_294_ayer_boc#3": "断崖", "char_188_helage": "赫拉格", "char_213_mostma": "莫斯提马", "char_503_rang": "巡林者", "char_172_svrash_summer#4": "银灰", "char_237_gravel_2": "砾", "char_250_phatom_ghost#1": "傀影", "char_115_headbr": "凛冬", "char_2014_nian_nian#4": "年", "char_172_svrash": "银灰", "char_131_flameb_2": "炎客", "char_147_shining_summer#1": "闪灵", "char_253_greyy_epoque#8": "格雷伊", "char_4016_kazema_2": "风丸", "char_437_mizuki_2": "水月", "char_220_grani_epoque#6": "格拉尼", "char_308_swire": "诗怀雅", "char_283_midn_boc#1": "月见夜", "char_147_shining": "闪灵", "char_492_quercu_2": "夏栎", "char_010_chen_nian#2": "陈", "char_496_wildmn_2": " 野鬃", "char_173_slchan_wild#1": "崖心", "char_150_snakek": "蛇屠箱", "char_003_kalts": "凯尔希", "char_422_aurora": "极光", "char_369_bena_2": "贝娜", "char_171_bldsk_summer#7": "华法琳", "char_118_yuki": "白雪", "char_258_podego": "波登可", "char_426_billro": "卡涅利安", "char_129_bluep": "蓝毒", "char_416_zumama_boc#3": "森蚺", "char_274_astesi_2": "星极", "char_122_beagle": "米格鲁", "char_196_sunbr_summer#1": "古米", "char_158_milu": "守林人", "char_343_tknogi": "月禾", "char_1012_skadi2_2": "浊心斯 卡蒂", "char_2023_ling_2": "令", "char_272_strong_summer#6": "孑", "char_134_ifrit": "伊芙利特", "char_123_fang": "芬", "char_289_gyuki": "缠丸", "char_133_mm_2": "梅", "char_475_akafyu_2": "赤冬", "char_478_kirara": "绮良", "char_264_f12yin_2": "山", "char_101_sora_2": "空", "char_127_estell_2": "艾丝黛尔", "char_102_texas_2": "德克萨斯", "char_017_huang": "煌", "char_476_blkngt_2": "夜半", "char_4016_kazema": "风丸", "char_377_gdglow_2": "澄闪", "char_4013_kjera": "耶拉", "char_279_excu_boc#1": "送葬人", "char_4000_jnight": "正义骑士号", "char_452_bstalk_2": "豆苗", "char_277_sqrrel_2": "阿消", "char_128_plosis_epoque#3": "白面鸮", "char_311_mudrok_summer#6": "泥岩", "char_452_bstalk": "豆苗", "char_134_ifrit_summer#1": "伊芙利特", "char_2015_dusk": "夕", "char_475_akafyu": "赤冬", "char_347_jaksel_whirlwind#2": "杰克", "char_350_surtr_2": "史尔特尔", "char_130_doberm_epoque#7": "杜宾", "char_197_poca_epoque#12": "早露", "char_290_vigna": "红豆", "char_225_haak_nian#5": "阿", "char_306_leizi": "惊蛰", "char_235_jesica_nian#2": "杰西卡", "char_159_peacok_2": "断罪者", "char_420_flamtl_2": "焰尾", "char_340_shwaz_snow#1": "黑", "char_109_fmout_2": "远山", "char_010_chen_2": "陈", "char_134_ifrit_kfc#1": "伊芙利特", "char_430_fartth": "远牙", "char_343_tknogi_2": "月禾", "char_102_texas_winter#1": "德克萨斯", "char_363_toddi": "熔泉", "char_128_plosis_2": "白面鸮", "char_469_indigo": "深靛", "char_1011_lava2_2": "炎狱炎熔", "char_379_sesa": "慑砂", "char_173_slchan": "崖心", "char_185_frncat": "慕斯", "char_143_ghost": "幽灵鲨", "char_308_swire_nian#2": "诗怀雅", "char_002_amiya_2": "阿米 娅", "char_173_slchan_wwf#1": "崖心", "char_147_shining_2": "闪灵", "char_172_svrash_2": "银灰", "char_282_catap": "空爆", "char_213_mostma_epoque#5": "莫斯提马", "char_333_sidero": "铸铁", "char_1012_skadi2": "浊心斯卡蒂", "char_188_helage_boc#2": "赫拉 格", "char_291_aglina_boc#1": "安洁莉娜", "char_333_sidero_summer#6": "铸铁", "char_489_serum_2": "蚀清", "char_235_jesica_2": "杰西卡", "char_2013_cerber_summer#4": "刻 俄柏", "char_486_takila_2": "龙舌兰", "char_376_therex": "THRM-EX", "char_264_f12yin": "山", "char_240_wyvern": "香草", "char_103_angel_kfc#1": "能天使", "char_436_whispr_2": "絮雨", "char_258_podego_epoque#9": "波登可", "char_180_amgoat_2": "艾雅法拉", "char_355_ethan_2": "伊桑", "char_145_prove_wild#5": "普罗旺斯", "char_275_breeze_2": "微风", "char_1014_nearl2": "耀骑士临光", "char_158_milu_wild#2": "守林人", "char_391_rosmon": "迷迭香", "char_002_amiya_1+": "阿米娅", "char_107_liskam_nian#2": "雷蛇", "char_383_snsant_2": "雪雉", "char_137_brownb_kitchen#1": "猎蜂", "char_402_tuye_epoque#14": "图耶", "char_431_ashlok": "灰毫", "char_204_platnm_summer#3": "白金", "char_479_sleach": "琴柳", "char_2015_dusk_nian#7": "夕", "char_455_nothin_nian#7": "乌有", "char_338_iris": "爱丽丝", "char_208_melan": "玫兰莎", "char_1011_lava2": "炎狱炎熔", "char_336_folivo_2": "稀音", "char_127_estell": "艾丝黛尔", "char_254_vodfox": "巫 恋", "char_129_bluep_2": "蓝毒", "char_378_asbest_2": "石棉", "char_243_waaifu_2": " 槐琥", "char_293_thorns_it#1": "棘刺", "char_145_prove_2": "普罗旺斯", "char_430_fartth_2": "远牙", "char_248_mgllan_2": "麦哲伦", "char_421_crow": "羽毛笔", "char_222_bpipe_race#1": "风笛", "char_369_bena": "贝娜", "char_431_ashlok_2": "灰毫", "char_294_ayer_2": "断崖", "char_1021_kroos2": "寒芒克洛丝", "char_325_bison": "拜松", "char_1021_kroos2_2": "寒芒克洛丝", "char_163_hpsts": "火神", "char_426_billro_snow#3": "卡涅利安", "char_451_robin": "罗宾", "char_158_milu_2": "守林人", "char_137_brownb_2": " 猎蜂", "char_172_svrash_snow#1": "银灰", "char_300_phenxi": "菲亚梅塔", "char_130_doberm_2": "杜宾", "char_400_weedy_snow#2": "温蒂", "char_332_archet_shining#1": "空弦", "char_112_siege": "推进之王", "char_183_skgoat_2": "地灵", "char_187_ccheal_epoque#2": "嘉维尔", "char_010_chen2": "陈", "char_4036_forcer_2": "见行者", "char_202_demkni_boc#1": "塞雷娅", "char_328_cammou_2": "卡达", "char_155_tiger_2": "因陀罗", "char_508_aguard": "Sharp", "char_291_aglina_2": "安洁莉娜", "char_103_angel_2": "能天使", "char_235_jesica": "杰西卡", "char_129_bluep_marthe#3": "蓝毒", "char_271_spikes_2": "芳汀", "char_274_astesi_epoque#5": "星极", "char_479_sleach_2": "琴柳", "char_192_falco": "翎羽", "char_253_greyy_2": "格雷伊", "char_347_jaksel_2": "杰克", "char_102_texas": "德克萨斯", "char_220_grani_2": "格拉尼", "char_416_zumama": "森蚺", "char_496_wildmn": "野鬃", "char_120_hibisc_nian#1": "芙蓉", "char_241_panda": "食铁兽", "char_250_phatom": "傀影", "char_164_nightm_2": "夜魔", "char_356_broca_2": "布洛卡", "char_102_texas_epoque#7": "德克萨斯", "char_118_yuki_boc#2": "白雪", "char_253_greyy": "格雷伊", "char_485_pallas_epoque#12": "帕拉斯", "char_226_hmau_nian#4": "吽", "char_171_bldsk": "华法琳", "char_252_bibeak_2": "柏喙", "char_381_bubble_2": "泡泡", "char_2015_dusk_2": "夕", "char_222_bpipe_2": "风笛", "char_136_hsguma_nian#3": "星熊", "char_423_blemsh_2": "瑕光", "char_140_whitew": "拉普兰德", "char_196_sunbr": "古米", "char_366_acdrop_2": "酸糖", "char_346_aosta": "奥斯塔", "char_254_vodfox_witch#2": "巫恋", "char_117_myrrh_wild#1": "末药", "char_236_rope_2": "暗索", "char_291_aglina": "安洁莉娜", "char_388_mint": "薄绿", "char_218_cuttle_2": "安哲拉", "char_456_ash_2": " 灰烬", "char_190_clour_2": "红云", "char_174_slbell_snow#1": "初雪", "char_198_blackd_2": "讯使", "char_236_rope_witch#1": "暗索", "char_159_peacok": "断罪者", "char_440_pinecn_2": "松果", "char_510_amedic": "Touch", "char_183_skgoat": "地灵", "char_365_aprl_wild#3": "四月", "char_214_kafka": "卡夫卡", "char_263_skadi_summer#3": "斯卡蒂", "char_199_yak_2": "角峰", "char_243_waaifu_whirlwind#2": "槐琥", "char_385_finlpp_2": "清流", "char_405_absin": "苦艾", "char_181_flower": "调香师", "char_122_beagle_boc#1": "米格鲁", "char_478_kirara_2": "绮良", "char_143_ghost_2": "幽灵鲨", "char_301_cutter_2": "刻刀", "char_298_susuro_summer#6": "苏苏洛", "char_181_flower_epoque#9": "调香师", "char_500_noirc": "黑角", "char_101_sora": "空", "char_112_siege_2": "推进之王", "char_512_aprot_2": "暮落", "char_117_myrrh": "末药", "char_337_utage": "宴", "char_355_ethan_epoque#7": "伊桑", "char_2023_ling": "令", "char_338_iris_2": "爱丽丝", "char_469_indigo_nian#7": "深靛", "char_363_toddi_2": "熔泉", "char_144_red": "红", "char_214_kafka_2": "卡夫卡", "char_140_whitew_2": "拉普兰德", "char_4013_kjera_2": "耶拉", "char_383_snsant": "雪雉", "char_472_pasngr": "异客", "char_171_bldsk_witch#1": "华法琳", "char_236_rope_summer#2": "暗索", "char_226_hmau": "吽", "char_210_stward": "史都华德", "char_337_utage_summer#4": "宴", "char_437_mizuki": "水月", "char_193_frostl": "霜叶", "char_291_aglina_summer#5": "安洁莉娜", "char_411_tomimi_summer#5": "特米米", "char_459_tachak_2": "战车", "char_237_gravel": "砾", "char_144_red_summer#6": "红", "char_166_skfire_summer#1": "天火", "char_145_prove_summer#3": "普罗旺斯", "char_304_zebra_2": "暴雨", "char_193_frostl_2": "霜叶", "char_220_grani": "格拉尼", "char_113_cqbw_epoque#7": "W", "char_248_mgllan": "麦哲伦", "char_294_ayer": "断崖", "char_347_jaksel": "杰克", "char_401_elysm_snow#2": "极境", "char_250_phatom_2": "傀 影", "char_143_ghost_winter#1": "幽灵鲨", "char_509_acast": "Pith", "char_180_amgoat_summer#5": "艾雅法拉", "char_278_orchid": "梓兰", "char_322_lmlee": "老鲤", "char_349_chiave": "贾维", "char_402_tuye": "图耶", "char_426_billro_2": "卡涅利安", "char_002_amiya": "阿米娅", "char_181_flower_2": "调香师", "char_373_lionhd_wild#3": "莱恩哈特", "char_286_cast3_summer#1": "Castle-3", "char_401_elysm": "极境", "char_225_haak_nian#4": "阿", "char_188_helage_2": "赫拉格", "char_2014_nian_2": "年", "char_385_finlpp": "清流", "char_459_tachak_rainbow6#1": "战车", "char_215_mantic_2": "狮蝎", "char_148_nearl": "临光", "char_166_skfire": "天火", "char_187_ccheal": "嘉维尔", "char_113_cqbw_2": "W", "char_243_waaifu": "槐琥", "char_345_folnic_2": "亚叶", "char_373_lionhd": "莱恩哈特", "char_124_kroos_witch#1": "克洛丝", "char_440_pinecn_shining#1": "松果", "char_277_sqrrel_ghost#1": "阿消", "char_337_utage_2": "宴", "char_126_shotst": "流星", "char_106_franka": "芙兰卡", "char_479_sleach_epoque#14": "琴柳", "char_252_bibeak_winter#2": "柏喙", "char_484_robrta_2": "罗比菈塔", "char_206_gnosis_2": "灵知", "char_198_blackd": "讯使", "char_416_zumama_2": "森蚺", "char_265_sophia_2": "鞭刃", "char_378_asbest": "石棉", "char_365_aprl": "四月", "char_504_rguard": "预备干员-近战", "char_348_ceylon": "锡兰", "char_4004_pudd": "布丁", "char_473_mberry_2": "桑葚", "char_377_gdglow": "澄闪", "char_411_tomimi_2": "特米米", "char_252_bibeak": "柏喙", "char_230_savage": "暴行", "char_298_susuro": "苏苏洛", "char_219_meteo_sweep#1": "陨星", "char_151_myrtle": "桃金娘", "char_415_flint_boc#3": "燧石", "char_508_aguard_2": "Sharp", "char_136_hsguma": "星熊", "char_241_panda_nian#7": "食铁兽", "char_4025_aprot2_2": "暮落", "char_215_mantic_epoque#4": "狮蝎", "char_344_beewax_2": "蜜蜡", "char_457_blitz_2": "闪击", "char_340_shwaz": "黑", "char_436_whispr_nian#4": "絮雨", "char_134_ifrit_2": "伊芙利特", "char_328_cammou_witch#2": "卡达", "char_455_nothin_2": "乌有", "char_261_sddrag_2": "苇草", "char_174_slbell_2": "初雪", "char_402_tuye_2": "图耶", "char_173_slchan_2": "崖心", "char_195_glassb_kitchen#1": "真理", "char_362_saga_2": "嵯峨", "char_271_spikes_winter#2": "芳汀", "char_451_robin_2": "罗宾", "char_164_nightm": "夜魔", "char_265_sophia_epoque#11": "鞭刃", "char_179_cgbird": "夜莺", "char_261_sddrag": "苇草", "char_190_clour": "红云", "char_248_mgllan_kitchen#1": "麦哲伦", "char_236_rope": "暗索", "char_302_glaze": "安比尔", "char_293_thorns_2": "棘刺", "char_206_gnosis": "灵知", "char_423_blemsh_witch#2": "瑕光", "char_108_silent_2": "赫默", "char_486_takila": "龙舌兰", "char_345_folnic": "亚叶", "char_225_haak": "阿", "char_343_tknogi_epoque#9": "月禾", "char_118_yuki_2": "白雪", "char_391_rosmon_2": "迷迭香", "char_345_folnic_wild#4": "亚叶", "char_218_cuttle": "安哲拉", "char_367_swllow_boc#1": "灰喉", "char_241_panda_marthe#1": "食铁兽", "char_155_tiger": "因陀罗", "char_274_astesi_shining#1": "星极", "char_201_moeshd": "可颂", "char_1011_lava2_nian#6": "炎狱炎熔", "char_340_shwazr6": "黑", "char_2013_cerber": "刻俄柏", "char_124_kroos": "克洛丝", "char_235_jesica_sweep#1": "杰西卡", "char_473_mberry": "桑 葚", "char_213_mostma_2": "莫斯提马", "char_336_folivo": "稀音", "char_4036_forcer": "见行者", "char_401_elysm_2": "极境", "char_289_gyuki_2": "缠丸", "char_202_demkni_test#1": "塞雷娅", "char_1014_nearl2_2": "耀骑士临光", "char_373_lionhd_snow#3": "莱恩 哈特", "char_326_glacus": "格劳克斯", "char_110_deepcl": "深海色", "char_254_vodfox_2": "巫恋", "char_265_sophia": "鞭刃", "char_171_bldsk_2": "华法琳", "char_298_susuro_2": "苏苏洛", "char_002_amiya_winter#1": "阿米娅", "char_2013_cerber_whirlwind#2": " 刻俄柏", "char_185_frncat_2": "慕斯", "char_199_yak": "角峰", "char_456_ash_rainbow6#1": "灰烬", "char_346_aosta_2": "奥斯塔", "char_010_chen": "陈", "char_512_aprot": " 暮落", "char_112_siege_wild#2": "推进之王", "char_322_lmlee_2": "老鲤", "char_117_myrrh_2": "末药", "char_505_rcast": "预备干员-术师", "char_415_flint_2": "燧石", "char_212_ansel_summer#1": "安赛尔", "char_379_sesa_2": "慑砂", "char_272_strong_2": "孑", "char_485_pallas": "帕拉斯", "char_472_pasngr_2": "异客", "char_326_glacus_2": "格劳克斯", "char_123_fang_winter#1": "芬", "char_108_silent": "赫默", "char_458_rfrost": " 霜华", "char_209_ardign_snow#1": "卡缇", "char_009_12fce": "12F", "char_002_amiya_test#1": "阿米娅", "char_285_medic2": "Lancet-2", "char_423_blemsh": "瑕光", "char_201_moeshd_summer#4": "可颂", "char_489_serum": "蚀清", "char_281_popka": "泡普卡", "char_166_skfire_2": "天火", "char_158_milu_snow#2": "守林人", "char_293_thorns": "棘刺", "char_449_glider_2": "蜜莓", "char_311_mudrok_2": "泥岩", "char_510_amedic_2": "Touch", "char_148_nearl_2": "临光", "char_411_tomimi": "特米米", "char_212_ansel": "安赛尔", "char_136_hsguma_2": "星熊", "char_383_snsant_witch#2": "雪雉", "char_4019_ncdeer_2": "九色鹿", "char_456_ash": "灰烬", "char_272_strong": "孑", "char_242_otter": "梅尔", "char_115_headbr_it#1": "凛冬", "char_235_jesica_wild#2": "杰西卡", "char_332_archet_2": "空弦", "char_348_ceylon_2": "锡兰", "char_196_sunbr_2": "古米", "char_340_shwaz_2": "黑", "char_284_spot": "斑点", "char_509_acast_2": "Pith", "char_149_scave": "清道夫", "char_451_robin_epoque#13": "罗宾", "char_264_f12yin_boc#3": "山", "char_362_saga": "嵯峨", "char_358_lisa_wild#3": "铃兰", "char_197_poca_2": "早露", "char_457_blitz": "闪击", "char_455_nothin": "乌有", "char_198_blackd_as#1": "讯使", "char_131_flameb": "炎客", "char_302_glaze_2": "安比尔", "char_141_nights_2": "夜烟", "char_263_skadi_2": "斯卡蒂", "char_106_franka_2": "芙兰卡", "char_017_huang_as#1": "煌", "char_350_surtr_it#1": "史尔特尔", "char_002_amiya_epoque#4": "阿米娅", "char_286_cast3": "Castle-3", "char_476_blkngt": "夜半", "char_109_fmout": "远山", "char_436_whispr": "絮雨", "char_107_liskam_striker#1": "雷蛇", "char_306_leizi_2": "惊蛰", "char_260_durnar_2": "坚雷", "char_214_kafka_snow#3": "卡夫卡", "char_365_aprl_2": "四月", "char_511_asnipe_2": "Stormeye", "char_187_ccheal_2": "嘉维尔", "char_449_glider": "蜜莓", "char_179_cgbird_witch#1": "夜莺", "char_274_astesi": "星极", "char_4025_aprot2": "暮落", "char_151_myrtle_epoque#12": "桃金娘", "char_373_lionhd_2": "莱恩哈特", "char_311_mudrok": "泥岩", "char_300_phenxi_2": "菲亚梅塔", "char_163_hpsts_2": "火神", "char_290_vigna_2": "红豆", "char_344_beewax_epoque#9": "蜜蜡", "char_279_excu": "送葬人", "char_301_cutter": "刻刀", "char_284_spot_boc#3": "斑点", "char_174_slbell": "初雪", "char_332_archet": "空弦", "char_349_chiave_2": "贾维", "char_290_vigna_as#1": "红豆", "char_113_cqbw": "W", "char_242_otter_2": "梅尔", "char_469_indigo_2": "深靛", "char_275_breeze": "微风", "char_258_podego_2": "波登可", "char_388_mint_2": "薄绿", "char_485_pallas_2": "帕拉斯", "char_198_blackd_winter#1": "讯使", "char_474_glady": "歌蕾蒂娅", "char_202_demkni": "塞雷娅", "char_263_skadi": "斯卡蒂", "char_230_savage_2": "暴行", "char_204_platnm_2": "白金", "char_197_poca": "早露", "char_4019_ncdeer": "九色鹿", "char_474_glady_2": "歌蕾蒂娅", "char_260_durnar": "坚雷", "char_150_snakek_2": "蛇屠箱", "char_325_bison_2": "拜松", "char_326_glacus_ghost#1": "格劳克斯", "char_120_hibisc": "芙蓉", "char_2013_cerber_2": "刻俄柏", "char_202_demkni_2": "塞雷娅", "char_209_ardign": "卡缇", "char_115_headbr_2": "凛冬"}
]])
avatarpng = table.keys(avatar2operator)

avatarIconMask = {}
avatarIconCenterList = {}
w, h = 36, 36
for i = 1, h do
  for j = 1, w do
    if true then
      table.insert(avatarIconMask, {i, j})
      -- log(613,i,j)
    end
    if ((i - 18.5) ^ 2 + (j - 18.5) ^ 2) < 10 ^ 2 then
      table.insert(avatarIconCenterList, j + (i - 1) * 36)
    end
  end
end
-- log(avatarIconCenterList)
-- exit()

findAvatar = function(x1, y1, x2, y2, pngdata)
  local s = ''
  local w, h, color = getScreenPixel(x1, y1, x2, y2)
  local i, j, b, g, r
  local data = {}
  log(87, x1, y1, x2, y2, w, h, #color, #avatarIconMask)
  for _, m in pairs(avatarIconMask) do
    i, j = m[1], m[2]
    -- b, g, r = colorToRGB(color[(i - 1) * w + j])
    b, g, r = colorToRGB(color[math.round((i - 1) * scale(192) / 36) * w +
                           math.round(j * scale(192) / 36)])
    table.extend(data, {r, g, b})

    if 1 then
      r = string.format('%X', r):padStart(2, '0')
      g = string.format('%X', g):padStart(2, '0')
      b = string.format('%X', b):padStart(2, '0')
      s = s .. i .. '|' .. j .. '|' .. r .. g .. b .. ','
    end
  end
  -- log(103, #data)
  -- log(s)
  -- exit()
  --
  local best_score = 100000
  -- local threshold = 100
  local best = nil
  local score = 0
  local scoreBase = 0
  local pointScore = 0
  -- local flatPoint = 0
  local abs = math.abs
  local white_num = 0

  local flatScoreTable = {}
  local flatScore = 0
  for _, i in pairs(avatarIconCenterList) do
    flatScore = abs(data[i * 3 - 2] - data[(i + 1) * 3 - 2]) +
                  abs(data[i * 3 - 1] - data[(i + 1) * 3 - 1]) +
                  abs(data[i * 3] - data[(i + 1) * 3]) +
                  abs(data[i * 3 - 2] - data[(i + 36) * 3 - 2]) +
                  abs(data[i * 3 - 1] - data[(i + 36) * 3 - 1]) +
                  abs(data[i * 3] - data[(i + 36) * 3])
    flatScore = 0
    table.insert(flatScoreTable, 1 / (1 + flatScore))
    scoreBase = scoreBase + flatScoreTable[#flatScoreTable]
  end

  -- log(109)
  local tmp = ''
  for k, v in pairs(pngdata) do
    tmp = ''
    score = 0
    white_num = 0
    for idx, i in pairs(avatarIconCenterList) do
      -- log(137, k, #v, i, score)
      if v[i * 3 - 2] == 255 and v[i * 3 - 1] == 255 and v[i * 3] == 255 then
        pointScore = 0
        white_num = white_num + 1
      else
        -- log(142)
        pointScore = abs(data[i * 3 - 2] - v[i * 3 - 2]) +
                       abs(data[i * 3 - 1] - v[i * 3 - 1]) +
                       abs(data[i * 3] - v[i * 3])
      end

      score = score + pointScore * flatScoreTable[idx]
      if i % 36 == 1 then tmp = tmp .. '\n' end
      if pointScore > 200 then
        tmp = tmp .. '1'
      else
        tmp = tmp .. ' '
      end
      -- if score / (36 * 36 - white_num) / scoreBase > best_score then break end
    end
    score = score / (#avatarIconCenterList - white_num) / scoreBase

    -- if k == 'char_293_thorns_2' then log(662, score, tmp) end
    -- if k == 'char_1014_nearl2' then log(662, score, tmp) end
    -- if k == 'Bskill_tra_flow_gc1.png' then log(663, score, tmp) end
    -- if k == 'char_350_surtr_2' then log(663, score, white_num, tmp) end
    --
    -- if k == 'Bskill_tra_texas1.png' then log(662, score, tmp) end
    -- if k == 'Bskill_tra_Lappland2.png' then log(663, score, tmp) end
    if k == 'char_264_f12yin_2' then log(663, score, white_num, tmp) end
    -- exit()

    if best_score > score then
      best_score = score
      best = k
      best_w = white_num
    end
  end
  log(2208, best_score, best, avatar2operator[best])
  return best
end

initAvatarPngdata = function()
  -- 读取图标图像，300个36x36的png，可能比较耗时
  if avatarPngdata then return end
  avatarPngdata = {}

  local s = ''
  for _, v in pairs(avatarpng) do
    local pngdata = avatarPngdata
    -- local _, _, color = getImage(getWorkPath() .. '/skill/' .. v)
    local _, _, color = getImage('/sdcard/png_noalpha3/' .. v .. '.png')
    pngdata[v] = {}
    for _, m in pairs(avatarIconMask) do
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

chooseOperatorBeforeFight = function()
  initAvatarPngdata()

  -- 两遍模式
  -- 第一遍尽可能选作业中的干员
  -- 第二遍选替换干员

  local maxSwipTimes = 10
  local operator = {}
  for i = 1, maxSwipTimes do
    if discoverBeforeFight(operator, pngdata, i) then break end
    log(operator)
    log(map(function(x) return avatar2operator[x[1]] end, operator))
    exit()
    -- 三次重试
    local state = sample("干员第一个")
    for j = 1, 3 do
      log("842尝试翻页", j)
      swipo()
      if not findOne(state) then break end
    end
  end
  swipo(true, true)

  local start_time = time()

  log(671, operator)

  -- 选择干员
  -- operator = best
  -- log(692, operator, best_score)
  -- local pageid = 1
  -- for i = 1, #operator do
  --   log(i, operator[i])
  --   while operator[i][5] > pageid do
  --     local state = sample("干员第一个")
  --     for j = 1, 3 do
  --       log("844尝试翻页", j)
  --       swipo()
  --       if not findOne(state) then break end
  --     end
  --     pageid = pageid + 1
  --   end
  --   local p = operator[i][4]
  --   tap({p[1] + scale(106), p[2]})
  --   sleep(50)
  -- end
  swipo(true, true)
end
