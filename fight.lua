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
      table.insert(card, {x, scale(379)})
      table.insert(card, {x, scale(801)})
    end
  end

  log(114, card)
  for idx, v in pairs(card) do
    -- 头像判断
    local y = 133
    local icon1 = {v[1], scale(y), v[1] + scale(180), v[2] + scale(y + 180)}
    local png =
      findAvatar(icon1[1], icon1[2], icon1[3], icon1[4], avatarPngdata) or
        'empty1.png'
    log(129, png)
    table.insert(operators, {png, pageid})
  end
end)

avatar2operator = JsonDecode(
                    [[{"char_285_medic2": "Lancet-2", "char_286_cast3": "Castle-3", "char_376_therex": "THRM-EX", "char_4000_jnight": "正义骑士号", "char_502_nblade": "夜刀", "char_500_noirc": "黑角", "char_503_rang": "巡林者", "char_501_durin": "杜林", "char_009_12fce": "12F", "char_123_fang": "芬", "char_240_wyvern": "香草", "char_504_rguard": "预备干员-近战", "char_192_falco": "翎羽", "char_208_melan": "玫兰莎", "char_281_popka": "泡普卡", "char_209_ardign": "卡缇", "char_122_beagle": "米格鲁", "char_284_spot": "斑点", "char_124_kroos": "克洛丝", "char_211_adnach": "安德切尔", "char_507_rsnipe": "预备干员-狙击", "char_121_lava": "炎熔", "char_120_hibisc": "芙蓉", "char_212_ansel": "安赛尔", "char_506_rmedic": "预备干员-后勤", "char_210_stward": "史都华德", "char_505_rcast": "预备干员-术师", "char_278_orchid": "梓兰", "char_141_nights": "夜烟", "char_109_fmout": "远山", "char_253_greyy": "格雷伊", "char_328_cammou": "卡达", "char_469_indigo": "深靛", "char_4004_pudd": "布丁", "char_235_jesica": "杰西卡", "char_126_shotst": "流星", "char_190_clour": "红云", "char_133_mm": "梅", "char_118_yuki": "白雪", "char_440_pinecn": "松果", "char_302_glaze": "安比尔", "char_366_acdrop": "酸糖", "char_198_blackd": "讯使", "char_149_scave": "清道夫", "char_290_vigna": "红豆", "char_151_myrtle": "桃金娘", "char_452_bstalk": "豆苗", "char_130_doberm": "杜宾", "char_289_gyuki": "缠丸", "char_159_peacok": "断罪者", "char_193_frostl": "霜叶", "char_127_estell": "艾丝黛尔", "char_185_frncat": "慕斯", "char_301_cutter": "刻刀", "char_337_utage": "宴", "char_271_spikes": "芳汀", "char_237_gravel": "砾", "char_272_strong": "孑", "char_236_rope": "暗索", "char_117_myrrh": "末药", "char_187_ccheal": "嘉维尔", "char_298_susuro": "苏苏洛", "char_181_flower": "调香师", "char_385_finlpp": "清流", "char_199_yak": "角峰", "char_150_snakek": "蛇屠箱", "char_381_bubble": "泡泡", "char_196_sunbr": "古米", "char_260_durnar": "坚雷", "char_110_deepcl": "深海色", "char_183_skgoat": "地灵", "char_258_podego": "波登可", "char_484_robrta": "罗比菈塔", "char_355_ethan": "伊桑", "char_277_sqrrel": "阿消", "char_128_plosis": "白面鸮", "char_275_breeze": "微风", "char_115_headbr": "凛冬", "char_102_texas": "德克萨斯", "char_349_chiave": "贾维", "char_261_sddrag": "苇草", "char_496_wildmn": "野鬃", "char_401_elysm": "极境", "char_476_blkngt": "夜半", "char_308_swire": "诗怀雅", "char_265_sophia": "鞭刃", "char_106_franka": "芙兰卡", "char_131_flameb": "炎客", "char_508_aguard": "Sharp", "char_155_tiger": "因陀罗", "char_415_flint": "燧石", "char_140_whitew": "拉普兰德", "char_294_ayer": "断崖", "char_252_bibeak": "柏喙", "char_459_tachak": "战车", "char_143_ghost": "幽灵鲨", "char_356_broca": "布洛卡", "char_274_astesi": "星极", "char_333_sidero": "铸铁", "char_475_akafyu": "赤冬", "char_421_crow": "羽毛笔", "char_486_takila": "龙舌兰", "char_129_bluep": "蓝毒", "char_204_platnm": "白金", "char_367_swllow": "灰喉", "char_511_asnipe": "Stormeye", "char_365_aprl": "四月", "char_1021_kroos2": "寒芒克洛丝", "char_219_meteo": "陨星", "char_379_sesa": "慑砂", "char_279_excu": "送葬人", "char_346_aosta": "奥斯塔", "char_002_amiya": "阿米娅", "char_405_absin": "苦艾", "char_411_tomimi": "特米米", "char_166_skfire": "天火", "char_509_acast": "Pith", "char_306_leizi": "惊蛰", "char_344_beewax": "蜜蜡", "char_373_lionhd": "莱恩哈特", "char_388_mint": "薄绿", "char_338_iris": "爱丽丝", "char_1011_lava2": "炎狱炎熔", "char_489_serum": "蚀清", "char_4013_kjera": "耶拉", "char_242_otter": "梅尔", "char_336_folivo": "稀音", "char_108_silent": "赫默", "char_171_bldsk": "华法琳", "char_345_folnic": "亚叶", "char_510_amedic": "Touch", "char_348_ceylon": "锡兰", "char_436_whispr": "絮雨", "char_402_tuye": "图耶", "char_473_mberry": "桑葚", "char_449_glider": "蜜莓", "char_148_nearl": "临光", "char_226_hmau": "吽", "char_144_red": "红", "char_243_waaifu": "槐琥", "char_214_kafka": "卡夫卡", "char_455_nothin": "乌有", "char_107_liskam": "雷蛇", "char_201_moeshd": "可颂", "char_325_bison": "拜松", "char_163_hpsts": "火神", "char_378_asbest": "石棉", "char_512_aprot": "暮落", "char_4025_aprot2": "暮落", "char_457_blitz": "闪击", "char_304_zebra": "暴雨", "char_431_ashlok": "灰毫", "char_422_aurora": "极光", "char_145_prove": "普罗旺斯", "char_158_milu": "守林 人", "char_218_cuttle": "安哲拉", "char_363_toddi": "熔泉", "char_173_slchan": "崖心", "char_383_snsant": "雪雉", "char_174_slbell": "初雪", "char_254_vodfox": "巫恋", "char_195_glassb": "真理", "char_326_glacus": "格劳克斯", "char_101_sora": "空", "char_343_tknogi": "月禾", "char_4019_ncdeer": "九色鹿", "char_492_quercu": "夏栎", "char_215_mantic": "狮蝎", "char_478_kirara": "绮良", "char_241_panda": "食铁兽", "char_4036_forcer": "见行者", "char_451_robin": "罗宾", "char_458_rfrost": "霜华", "char_369_bena": "贝娜", "char_4016_kazema": "风丸", "char_103_angel": "能天使", "char_332_archet": "空弦", "char_456_ash": "灰烬", "char_340_shwaz": "黑", "char_430_fartth": "远牙", "char_113_cqbw": "W", "char_300_phenxi": "菲亚梅塔", "char_197_poca": "早露", "char_391_rosmon": "迷迭香", "char_1013_chen2": "假日威龙陈", "char_112_siege": "推进之王", "char_222_bpipe": "风笛", "char_362_saga": "嵯峨", "char_479_sleach": "琴柳", "char_420_flamtl": "焰尾", "char_134_ifrit": "伊芙利特", "char_213_mostma": "莫斯提马", "char_180_amgoat": "艾雅法拉", "char_2013_cerber": "刻俄柏", "char_2015_dusk": "夕", "char_472_pasngr": "异客", "char_426_billro": "卡涅利安", "char_377_gdglow": "澄闪", "char_206_gnosis": "灵知", "char_291_aglina": "安洁莉娜", "char_358_lisa": "铃兰", "char_248_mgllan": "麦哲伦", "char_1012_skadi2": "浊心斯卡蒂", "char_2023_ling": "令", "char_250_phatom": "傀影", "char_322_lmlee": "老鲤", "char_400_weedy": "温蒂", "char_225_haak": "阿", "char_474_glady": "歌蕾蒂娅", "char_437_mizuki": "水月", "char_147_shining": "闪灵", "char_179_cgbird": "夜莺", "char_003_kalts": "凯尔希", "char_136_hsguma": "星熊", "char_202_demkni": "塞雷娅", "char_423_blemsh": "瑕光", "char_2014_nian": "年", "char_311_mudrok": "泥岩", "char_416_zumama": "森蚺", "char_264_f12yin": "山", "char_172_svrash": "银灰", "char_293_thorns": "棘刺", "char_010_chen": "陈", "char_017_huang": "煌", "char_350_surtr": "史尔特尔", "char_188_helage": "赫拉格", "char_485_pallas": "帕拉斯", "char_1014_nearl2": "耀骑士临光", "token_10000_silent_healrb": "医疗探机", "token_10001_deepcl_tentac": "触手", "token_10002_kalts_mon3tr": "Mon3tr", "token_10003_cgbird_bird": "幻影", "token_10004_otter_motter": "机械水獭", "token_10005_mgllan_drone1": "龙腾.F", "token_10005_mgllan_drone2": "龙腾.L", "token_10005_mgllan_drone3": "龙腾.A", "token_10006_vodfox_doll": "诅咒娃娃", "token_10007_phatom_twin": "镜中虚影", "token_10008_cqbw_box": "此面向敌", "token_10009_weedy_cannon": "工程蓄水炮", "token_10010_folivo_car": "移动摄影器", "token_10011_beewax_oblisk": "沙之碑", "token_10012_rosmon_shield": "迷迭香的战术装备", "token_10013_robin_mine": "\"夹子\"", "token_10014_bstalk_crab": "磐蟹护卫队", "token_10015_dusk_drgn": "\"小自在\"", "token_10016_rfrost_mine": "迎宾踏垫", "token_10017_skadi2_dedant": "斯卡蒂的海嗣", "token_10018_robrta_mach": "全自动造型仪", "token_10019_nearl2_sword": "“耀阳”", "token_10020_ling_soul1": "“清平”", "token_10020_ling_soul2": "“逍遥”", "token_10020_ling_soul3": "“弦惊”", "token_10021_blkngt_hypnos": "眠兽", "token_10022_kazema_shadow": "纸偶", "trap_001_crate": "障碍物", "trap_002_emp": "震撼装置", "trap_003_gate": "闸门", "trap_005_sensor": "侦测器", "trap_006_antidr": "干扰装置", "trap_007_ballis": "弩炮", "trap_008_farm": "指挥终端", "trap_009_battery": "便携式补给站", "trap_010_frosts": "源石冰晶", "trap_011_ore": "源石祭坛", "trap_012_mine": "干扰地雷", "trap_013_blower": "源石流发生装置", "trap_014_tower": "L-44\"留声机\"", "trap_015_tree": "巨蕈", "trap_016_peon": "罗德岛临时雇员", "trap_018_bomb": "轰隆隆先生", "trap_019_electric": "梅什科线圈", "trap_020_roadblock": "道路障碍物", "trap_021_flame": "能量聚合体", "trap_022_frosts_friend": "霜星的源石冰晶", "trap_023_ore_friend": "爱国者的源石祭坛", "trap_024_npcsld": "盾卫", "trap_025_prison": "禁锢装置", "trap_026_inverter": "改良型二踢脚", "trap_027_stone": "碎石", "trap_028_cannon": "脉冲防御模组", "trap_029_poison": "催泪瓦斯控制阀", "trap_030_factory": "无人机工厂", "trap_031_sleep": "雪雉的安全起重机", "trap_032_mound": "土石结构", "trap_033_sbomb": "高能源石炸弹", "trap_034_machst": "加固装置", "trap_035_emperor": "大帝", "trap_036_storm": "沙尘暴", "trap_037_airsup": "可移动战术机库", "trap_038_dsbell": "应急救治设施", "trap_039_dstnta": "子代", "trap_040_canoe": "特制水上平台", "trap_041_fcanon": "风筝", "trap_042_tidectrl": "涨潮控制", "trap_043_dupilr": "破碎支柱", "trap_044_duruin": "战场废墟", "trap_045_dublst": "爆破装置", "trap_046_oxygen": "防水蚀镀膜装置", "trap_048_neonlamp": "城市霓虹", "trap_049_candle": "骑士之徽", "trap_050_blizzard": "暴风雪", "trap_051_vultres": "无主的财富", "trap_052_slowfd": "失修舞台雾机", "trap_053_airbomb": "便携气罐", "trap_054_dancdol": "“报幕助手”", "trap_055_tileblock": "封印的地面", "trap_056_sfsuifire": "丹田", "trap_057_wpnsts": "“冰淇淋机”", "char_230_savage": "暴行", "char_282_catap": "空爆", "char_283_midn": "月见夜", "char_137_brownb": "猎蜂", "char_347_jaksel": "杰克", "char_164_nightm": "夜魔", "char_220_grani": "格拉尼", "char_263_skadi": "斯卡蒂"}]])
avatarpng = table.keys(avatar2operator)

avatarIconMask = {}
avatarIconCenterMask = {}
w, h = 36, 36
for i = 1, h do
  for j = 1, w do
    if true then
      table.insert(avatarIconMask, {i, j})
      -- log(613,i,j)
    end
    if ((i - 18.5) ^ 2 + (j - 18.5) ^ 2) < 17 ^ 2 then
      table.insert(avatarIconCenterMask, {i, j})
    end
  end
end
-- exit()

findAvatar = function(x1, y1, x2, y2, pngdata)
  local s = ''
  local w, h, color = getScreenPixel(x1, y1, x2, y2)
  local i, j, b, g, r
  local data = {}
  for _, m in pairs(avatarIconMask) do
    i, j = m[1], m[2]
    -- b, g, r = colorToRGB(color[(i - 1) * w + j])
    b, g, r = colorToRGB(color[scale((i - 1) * 5) * w + scale(j * 5)])
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
  local best_score = 100000
  -- local threshold = 100
  local best = nil
  local score = 0
  local scoreBase = 0
  local pointScore = 0
  -- local flatPoint = 0
  local abs = math.abs

  local flatScoreTable = {}
  local flatScore = 0
  for i = 1, #avatarIconMask - 36 do
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
    for i = 1, #avatarIconMask do
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
  exit()
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
