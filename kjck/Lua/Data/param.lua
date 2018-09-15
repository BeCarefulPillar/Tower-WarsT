--[Comment]
--游戏参数
DB.param = {
    --[Comment]
    --医馆加血价格
    prAddHp = 50,
    --[Comment]
    --战役刷新价格
    prReWar = 100,
    --[Comment]
    --酒馆刷新价格
    prReTvrn = 30,
    --[Comment]
    --酒馆喝酒价格(银币)
    prDrinkC = 8000,
    --[Comment]
    --酒馆喝酒价格(金币)
    prDrinkG = 50,
    --[Comment]
    --酒馆招募价格(金币)
    prRecruit = 180,
    --[Comment]
    --金币十连抽价格
    prRw10 = 380,
    --[Comment]
    --幻化需要的幻化石数量
    prEc = { 10, 25, 40 },
    --[Comment]
    --演武榜最大次数
    qtyRank = 10,
    --[Comment]
    --每天金换银的次数
    qtyG2C = 1,
    --[Comment]
    --每天副本挑战次数
    qtyFB = 3,
    --[Comment]
    --城池收获冷却时间(s)
    cdCityCrop = 600,
    --[Comment]
    --城池产出累积次数
    qtyCityCrop = 48,
    --[Comment]
    --城池最大等级
    mlvCity = 10,
    --[Comment]
    --医馆每30分钟恢复数量
    qtyReHP = 0,
    --[Comment]
    --重置兵种和阵形的价格
    prResetAL = 200,
    --[Comment]
    --创建联盟价格
    prAllyCreate = 200,
    --[Comment]
    --维护费用(联盟币)
    prAllyRent = 100,
    --[Comment]
    --联盟捐献价格(银币)
    prAllyDntC = 150000,
    --[Comment]
    --联盟捐献价格(金币)
    prAllyDntG = 200,
    --[Comment]
    --金币一抽价格
    prRw1 = 45,
    --[Comment]
    --经验塔高级修炼倍数
    qtyTrain = 2,
    --[Comment]
    --经验塔高级修炼VIP
    vipTrain = 2,
    --[Comment]
    --科技培养的基础价格(银币)
    prTechC = 96000,
    --[Comment]
    --科技培养的基础价格
    prTechG = 95,
    --[Comment]
    --装备的进阶上限
    mlvEqpEvo = 3,
    --[Comment]
    --装备进阶需要的道具编号(玄铁)
    eqpEvoProp = 17,
    --[Comment]
    --积分一抽价格
    prRmb1 = 35,
    --[Comment]
    --积分十连抽价格
    prRmb10 = 298,
    --[Comment]
    --过关斩将扫荡VIP
    vipTowerSD = 4,
    --[Comment]
    --过关斩将扫荡价格(积分)
    prTowerSD = 50,
    --[Comment]
    --过关斩将武将星级
    towerHeroRare = 5,
    --[Comment]
    --过关斩将武将等级
    towerHeroLv = 30,
    --[Comment]
    --武将觉醒需要稀有度
    rareHeroEvo = 5,
    --[Comment]
    --阵形铭刻道具数
    prLnpImp = 1,
    --[Comment]
    --阵形铭刻锁定单条价格(积分)
    prLnpImpLock = 10,
    --[Comment]
    --国战征粮次数
    qtyNatFood = 8,
    --[Comment]
    --国战单次征粮数
    natFood = 20000,
    --[Comment]
    --国战分身价格
    prNatCopy = 20,
    --[Comment]
    --国战单挑冷却
    cdNatSolo = 30,
    --[Comment]
    --占卜翻牌价格(积分)
    prDivine = { 0, 20, 20, 20 },
    --[Comment]
    --宝石合成需要的数量
    prGemUp = 4,
    --[Comment]
    --宝石打孔需要的数量
    prGemPunch = { 1, 3, 7 },
    --[Comment]
    --将魂分解可得魂币数
    prSellSoul = 1,
    --[Comment]
    --专属锻造需要的道具
    exclForgeProp = 55,
    --[Comment]
    --乱世争雄时间段
    tmGmClan = { { h = 18 }, { h = 20 } },
    --[Comment]
    --武将精力值上限
    heroEnergy = 50,
    --[Comment]
    --修炼抵挡心魔价格
    prDevil = 15,
    --[Comment]
    --副将重置技能的价格
    prDeheroResk = 20,
    --[Comment]
    --联盟任务刷新价格(积分)
    prAllyReQuest = 5,
    --[Comment]
    --军备洗炼消耗(洗炼石)
    prDqpExt = 10,
    --[Comment]
    --军备至尊洗炼消耗(积分)
    prDqpExtRmb = 20,
    --[Comment]
    --副将一抽价格
    prDehero1 = 35,
    --[Comment]
    --副将十连抽价格
    prDehero10 = 298,
    --[Comment]
    --联盟战报名价格(联盟币)
    prSwar = 20000,
    --[Comment]
    --PVP占领收入比例(百分之)
    pvpCrop = 70,
    --[Comment]
    --国战州郡关注加成(百分之)
    natStateAtt = 130,
    --[Comment]
    --国战州郡注资价格(金币)
    prNatState = 100,
    --[Comment]
    --淬炼基本价格(寒铁)
    prEquipCL = 500,
    --[Comment]
    --分享CD(秒)
    cdShare = 300,
    --[Comment]
    --解锁一键收获的主城等级
    lvCrop1k = 52,
    --[Comment]
    --跨服国战参数[金币募集价格,金币募集数量,积分募集价格,积分募集数量,粮草上限(万)]
    snat = { 200, 1000, 40, 5000, 50 },
    --[Comment]
    --天机属性比例
    slvAtt = 1,
    --[Comment]
    --联盟退出价格(银币)
    prAllyQuit = 200000,
    --[Comment]
    --联盟退出/解散冷却
    cdAllyQuit = 24,
}