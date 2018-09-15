
local rawget = rawget
local ipairs = ipairs
local insert = table.insert
local BD_Const = QYBattle.BD_Const
local BD_ANM = QYBattle.BD_ANM
local BD_ExtAtt = QYBattle.BD_ExtAtt
local B_Math = QYBattle.B_Math

--[[
    private long sn;                           //攻城/副本=攻占城池编号，战役=战役子关卡编号，PVP为城池位置号，演武榜为守方玩家编号，过关斩将为关卡编号，乱世争雄为副本编号，极限挑战为武将DBSN，矿脉战为矿脉编号，幻境挑战为关卡编号
    private long defSN;                        //守方玩家SN，非PVP为0
    private EnInt vip;                       //当前玩家VIP
    /// <summary>
    /// 战斗类型 0=新手模拟战 1=攻城 2=战役 3=PVP攻城 4=副本 5=演武榜 6=BOSS战 7=过关斩将 8=国战 9=乱世争雄 10=极限挑战 11=矿脉战 12=幻境挑战 13=二代BOSS
    /// </summary>
    private EnInt type;
    private int seed;                        //随机种子

    private S_BattlePlayer atkPlayer;
    private S_BattlePlayer defPlayer;

    private EnInt atkFightHero;                 //攻方当前出战的武将
    private EnInt defFightHero;                 //守方当前出战的武将
    private EnInt defAdv;                         //守方当前军师DBSN

    private BD_ExtAtt atkAtlas;           //攻方名将谱
    private BD_ExtAtt defAtlas;           //守方名将谱

    private S_BattleAtt[] atkProps;             //攻方道具
    private S_BattleAtt[] defProps;             //守方道具
    private int[] atkPropsSn;                   //攻方道具SN列表
    private int[] defPropsSn;                   //守方道具SN列表
    private BD_ExtAtt atkPropsAtt;            //攻方道具扩展属性
    private BD_ExtAtt defPropsAtt;            //守方道具扩展属性

    private BD_ExtAtt atkTech;           //攻方联盟科技
    private BD_ExtAtt defTech;           //守方联盟科技

     // 新增BUFF
    private B_ExtraAtts _atkHeroWeak;           //攻方虚弱属性
    private B_ExtraAtts _defHeroWeak;           //守方虚弱属性

    private B_ExtraAtts _atkPersonalTech;           //攻方帝国个人科技属性
    private B_ExtraAtts _defPersonalTech;           //守方帝国个人科技属性

    private B_ExtraAtts _atkCountryTech;           //攻方帝国国家科技属性
    private B_ExtraAtts _defCountryTech;           //守方帝国国家科技属性

    private EnInt _atkPalaceTrapSN;            //地宫房间陷阱效果(只对攻方有效)

    private BD_BattleExtra atkBeauty;          //攻方美女
    private BD_BattleExtra defBeauty;          //守方美女

    /// <summary>
    /// 1=武力因子:(武将/士兵的武力输出 = 武力*武力因子/100)
    /// 2=士兵武力因子:(士兵武力 = 武将统帅*士兵武力因子/100)
    /// 3=士兵生命因子:(士兵生命 = 武将统帅*士兵生命因子/100)
    /// 4=CD极限:(S)
    /// 5=CD因子:(CD = (武将智力/CD因子 + 技能CD基础值))
    /// 6=阵形因子:(武将三围 -= 武将三围*阵形因子)
    /// 7=兵种因子:(士兵二围 -= 士兵二围*兵种因子)
    /// 8=闪避极限
    /// 9=技能闪避极限
    /// 10=武力减伤极限
    /// 11=技能减伤极限
    /// 12=武力击晕极限
    /// </summary>
    private EnInt[] param;               //战场参数
    private EnInt[] atkLmt;            //攻方极限数值(弃用)
    private EnInt[] defLmt;            //守方极限数值(弃用)

    //[1=SN,2=目标,3=武力增减,4=智力增减,5=统帅增减,6=生命增减,7=技力增减,8=兵力增减,9=CD增减,10=暴击,11=技能暴击,12=暴击伤害,13=命中,14=闪避,15=技能闪避,16=移动速度,17=攻击速度,18=造成武力伤害增减,19=造成技能伤害增减,20=受到武力伤害增减,21=受到技能伤害增减]
    private EnInt[] atkSkt;                 //攻方当前军师技数据
    private EnInt[] defSkt;                 //守方当前军师技数据

    private int atkSktSn;                   //攻方当前军师技SN
    private int defSktSn;                   //守方当前军师技SN

    private EnHero[] atkHeros;              //攻方武将列表 第一个为军师
    private EnHero[] defHeros;              //守方武将列表

    int _atkQty = 0;
    int _defQty = 0;

    private EnInt diff;
    private EnInt fightTime;

    private int playerHP;
    private int playerTP;

    private List<int> fightTimeRec;
]]

local _bat = 
{ 
    EnInt = function(v) return { value = v or 0 } end,

    cheat = 0,
}

--添加属性
local function AddExtAtt(src, att)
    if att and #att > 0 then
        for k, v in ipairs(att) do
            k = v[1]
            src[k] = (src[k] or 0) + v[2]
        end
    end
end

--老式的联盟科技数据转为通用属性
--tech : 科技数据 [HP,TP,STR,CAP,WIS]
local function TechToExtAtt(tech)
    local att = { }
    if tech and #tech > 2 then
        local v = tech[3]
        if v and v > 0 then insert(att, { BD_ANM.Str, v }) end
        v = tech[4]
        if v and v > 0 then insert(att, { BD_ANM.Cap, v }) end
        v = tech[5]
        if v and v > 0 then insert(att, { BD_ANM.Wis, v }) end
    end
    return BD_ExtAtt(att, false)
end

--转存战场参数
local function TransParam(b, param, EnInt)
    --武将武力因子:(武将/士兵的武力输出 = 武力*武力因子/100)
    b.fStr = EnInt(param[1])
    --士兵武力因子:(士兵武力 = 武将统帅*士兵武力因子/100)
    b.fArmStr = EnInt(param[2])
    --士兵生命因子:(士兵生命 = 武将统帅*士兵生命因子/100)
    b.fArmHP = EnInt(param[3])
    --CD因子:(CD = 100(武将智力/CD因子 + 技能基础CD))
    b.fCD = EnInt(param[5])
    --阵形因子:(武将三围 -= 武将三围*阵形因子)
    b.fLnpRes = EnInt(param[6])
    --兵种因子:(士兵二围 -= 士兵二围*兵种因子)
    b.fArmRes = EnInt(param[7])
    --CD极限(S)
    b.lmtCD = EnInt(param[4])
    --闪避极限
    b.lmtDodge = EnInt(param[8])
    --技能闪避极限
    b.lmtSDodge = EnInt(param[9])
    --武力减伤极限
    b.lmtSPD = EnInt(-param[10])
    --技能减伤极限
    b.lmtSSD = EnInt(-param[11])
    --武力击晕极限
    b.lmtStun = EnInt(param[12])
    --移动速度极限
    b.lmtMS = EnInt(param[13])
    --攻击速度极限
    b.lmtMSPA = EnInt(param[14])
    --技能暴击极限
    b.lmtScrit = EnInt(param[15])
end

--生成攻城战数据
--dat : S_BattleSiege
function _bat.NewSiege(dat)
    local EnInt = QYBattle.EnInt
    local b =
    {
        EnInt = EnInt,
        type = EnInt(dat.type),
        sn = dat.sn,
        seed = dat.seed,
        defSN = dat.defSN,
        vip = EnInt(dat.vip),
        atkFightHero = EnInt(0),
        defFightHero = EnInt(0),
        defAdv = EnInt(dat.defAdv),

        fightTime = EnInt(dat.fightTime),
        playerHP = dat.php,
        playerTP = dat.ptp,
        diff = EnInt(0),

        atkAtts = { },
        defAtts = { },
    }

    --赋值战场参数
    TransParam(b, dat.param, EnInt)
--    local var = { }
--    for k, v in ipairs(dat.param) do var[k] = EnInt(v) end
--    b.param = var

    --赋值军师技
    local var = { }
    for k, v in ipairs(dat.atkAdd.skt) do var[k] = EnInt(v) end
    b.atkSkt = var
    b.atkSktSn = var[1].value
    var = { }
    for k, v in ipairs(dat.defAdd.skt) do var[k] = EnInt(v) end
    b.defSkt = var
    b.defSktSn = var[1].value

    --赋值武将数据
    b.atkHeros = QYBattle.EnHero.FromArray(dat.atkHeros, EnInt)
    b.defHeros = QYBattle.EnHero.FromArray(dat.defHeros, EnInt)
    --计算双方武将数目
    b.atkQty = b.atkHeros and #b.atkHeros or 0
    b.defQty = b.defHeros and #b.defHeros or 0

    --删除重复，或无效武将
    if dat.type == 1 and b.defQty > 0 then
        var = { }
        for i = b.defQty, 1, -1 do
            if b.defHeros[i].dbsn.value > 0 and not var[i] then
                var[i] = true
            else
                table.remove(b.defHeros, i)
            end
        end
        b.defQty = #b.defHeros
    end

    --读取名将谱
    b.atkAtlas = BD_ExtAtt(dat.atkAdd.atlas, false)
    b.atkHasAtls = #b.atkAtlas > 0
    AddExtAtt(b.atkAtts, b.atkAtlas)
    b.defAtlas = BD_ExtAtt(dat.defAdd.atlas, false)
    b.defHasAtlas = #b.defAtlas > 0
    AddExtAtt(b.defAtts, b.defAtlas)

    --读取联盟科技
    b.atkTech = TechToExtAtt(dat.atkAdd.tech)
    b.atkHasTech = #b.atkTech > 0
    AddExtAtt(b.atkAtts, b.atkTech)
    b.defTech = TechToExtAtt(dat.defAdd.tech)
    b.defHasTech = #b.defTech > 0
    AddExtAtt(b.defAtts, b.defTech)

    --军师技扩展
--    var = dat.atkAdd.sktAtt
--    if var and var ~= "" then AddExtAtt(b.atkAtts, BD_ExtAtt(var, false)) end
--    var = dat.defAdd.sktAtt
--    if var and var ~= "" then AddExtAtt(b.defAtts, BD_ExtAtt(var, false)) end

--    --铜雀台扩展
--    var = dat.atkAdd.beauty
--    if var then
--        b.atkBeauty = { sn = var.bsn or 0, lv = var.star or 0, extAtt = BD_ExtAtt(var.extra) }
--        if b.atkBeauty.extAtt then AddExtAtt(b.atkAtts, b.atkBeauty.extAtt) end
--    end
--    var = dat.defAdd.beauty
--    if var then
--        b.defBeauty = { sn = var.bsn or 0, lv = var.star or 0, extAtt = BD_ExtAtt(var.extra) }
--        if b.defBeauty.extAtt then AddExtAtt(b.defAtts, b.defBeauty.extAtt) end
--    end

    --读取道具加成
    var = dat.atkAdd.props
    if var and #var > 0 then
        local sn = { }
        local att = BD_ExtAtt()
        for k, v in ipairs(var) do
            sn[k] = v.sn
            att:Add(v.extra)
        end
        b.atkProps = var
        b.atkPropsSn = sn
        AddExtAtt(b.atkAtts, att)
    end
    var = dat.defAdd.props
    if var and #var > 0 then
        local sn = { }
        local att = BD_ExtAtt()
        for k, v in ipairs(var) do
            sn[k] = v.sn
            att:Add(v.extra)
        end
        b.defProps = var
        b.defPropsSn = sn
        AddExtAtt(b.defAtts, att)
    end
    
    --新增Buff
    --读取虚弱属性
    b.atkHeroWeak = BD_ExtAtt(dat.atkAdd.weak, false)
    b.atkHasWeak = #b.atkHeroWeak > 0
    AddExtAtt(b.atkAtts, b.atkHeroWeak)
    b.defHeroWeak = BD_ExtAtt(dat.defAdd.weak, false)
    b.defHasWeak = #b.defHeroWeak > 0
    AddExtAtt(b.defAtts, b.defHeroWeak)
    --读取国家个人科技树
    b.atkPersonalTech = BD_ExtAtt(dat.atkAdd.perTech, false)
    b.atkHasPersonalTech = #b.atkPersonalTech > 0
    AddExtAtt(b.atkAtts, b.atkPersonalTech)
    b.defPersonalTech = BD_ExtAtt(dat.defAdd.perTech, false)
    b.defHasPersonalTech = #b.defPersonalTech > 0
    AddExtAtt(b.defAtts, b.defPersonalTech)
    --读取国家科技树
    b.atkCountryTech = BD_ExtAtt(dat.atkAdd.natTech, false)
    b.atkHasCountryTech = #b.atkCountryTech > 0
    AddExtAtt(b.atkAtts, b.atkCountryTech)
    b.defCountryTech = BD_ExtAtt(dat.defAdd.natTech, false)
    b.defHasCountryTech = #b.defCountryTech > 0
    AddExtAtt(b.defAtts, b.defCountryTech)
    --读取地宫房间陷阱
    b.gveTrap = EnInt(dat.atkAdd.gveTrap)
    b.hasGveTrap = b.gveTrap.value > 0
    return setmetatable(b, _bat)
end

--生成国战、盟战等单对单战斗数据
--dat : S_BattleSingle
function _bat.NewSingle(dat)
    local EnInt = _bat.EnInt
    print(kjson.print(dat))
    local b =
    {
        EnInt = EnInt,
        type = EnInt(dat.type),
        sn = dat.sn,
        seed = dat.seed,
        defSN = dat.def.player.psn,
        vip = EnInt(user and user.vip or BD_Const.ACC_VIP),
        atkFightHero = EnInt(0),
        defFightHero = EnInt(0),
        defAdv = EnInt(dat.def.hero.dbsn),

        atkPlayer = dat.atk.palyer,
        defPlayer = dat.def.palyer,

        fightTime = 0,
        playerHP = 0,
        playerTP = 0,
        diff = EnInt(0),

        accVip = BD_Const.ACC_VIP,
        skipVip = BD_Const.SKIP_VIP,

        atkAtts = { },
        defAtts = { },
    }

    --赋值战场参数
    TransParam(b, dat.param, EnInt)
--    local var = { }
--    for k, v in ipairs(dat.param) do var[k] = EnInt(v) end
--    b.param = var

    --赋值军师技
    local var = { }
    for k, v in ipairs(dat.atk.add.skt) do var[k] = EnInt(v) end
    b.atkSkt = var
    b.atkSktSn = var[1].value
    var = { }
    for k, v in ipairs(dat.def.add.skt) do var[k] = EnInt(v) end
    b.defSkt = var
    b.defSktSn = var[1].value

    --赋值武将数据
    b.atkHeros = { QYBattle.EnHero(dat.atk.hero, EnInt) }
    b.defHeros = { QYBattle.EnHero(dat.def.hero, EnInt) }
    print("b.atkHeros   ",kjson.print(b.atkHeros))
    b.atkHeros[1]:SetEvoSkill(dat.atk.fight.ske)
    b.defHeros[1]:SetEvoSkill(dat.def.fight.ske)
    --计算双方武将数目
    b.atkQty, b.defQty = 1, 1

    --读取名将谱
    b.atkAtlas = BD_ExtAtt(dat.atk.add.atlas, false)
    b.atkHasAtlas = #b.atkAtlas > 0
    AddExtAtt(b.atkAtts, b.atkAtlas)
    b.defAtlas = BD_ExtAtt(dat.def.add.atlas, false)
    b.defHasAtlas = #b.defAtlas > 0
    AddExtAtt(b.defAtts, b.defAtlas)

    --读取联盟科技
    b.atkTech = TechToExtAtt(dat.atk.add.tech)
    b.atkHasTech = #b.atkTech > 0
    AddExtAtt(b.atkAtts, b.atkTech)
    b.defTech = TechToExtAtt(dat.def.add.tech)
    b.defHasTech = #b.defTech > 0
    AddExtAtt(b.defAtts, b.defTech)

    --军师技扩展
    var = dat.atk.add.sktAtt
    if var and var ~= "" then AddExtAtt(b.atkAtts, BD_ExtAtt(var, false)) end
    var = dat.def.add.sktAtt
    if var and var ~= "" then AddExtAtt(b.defAtts, BD_ExtAtt(var, false)) end

    --铜雀台扩展
    var = dat.atk.add.beauty
    if var then
        b.atkBeauty = { sn = var.bsn or 0, lv = var.star or 0, extAtt = BD_ExtAtt(var.extra) }
        if b.atkBeauty.extAtt then AddExtAtt(b.atkAtts, b.atkBeauty.extAtt) end
    end
    var = dat.def.add.beauty
    if var then
        b.defBeauty = { sn = var.bsn or 0, lv = var.star or 0, extAtt = BD_ExtAtt(var.extra) }
        if b.defBeauty.extAtt then AddExtAtt(b.defAtts, b.defBeauty.extAtt) end
    end

    --读取道具加成
    var = dat.atk.add.props
    if var and #var > 0 then
        local sn = { }
        local att = BD_ExtAtt()
        for k, v in ipairs(var) do
            sn[k] = v.sn
            att:Add(v.extra)
        end
        table.sort(sn)
        b.atkProps = var
        b.atkPropsSn = sn
        AddExtAtt(b.atkAtts, att)
    end
    var = dat.def.add.props
    if var and #var > 0 then
        local sn = { }
        local att = BD_ExtAtt()
        for k, v in ipairs(var) do
            sn[k] = v.sn
            att:Add(v.extra)
        end
        table.sort(sn)
        b.defProps = var
        b.defPropsSn = sn
        AddExtAtt(b.defAtts, att)
    end
    return setmetatable(b, _bat)
end

--[Comment]
--获取战场扩展属性加成
function _bat.GetExtAtt(b, mark, isAtk)
    if isAtk then return b.atkAtts[mark] or 0 end
    return b.defAtts[mark] or 0
end


--添加战斗时间记录，用于幻境挑战完美通关
function _bat.AddFightTimeRec(b, tm)
    if b.fightTimeRec == nil then b.fightTimeRec = { } end
    insert(b.fightTimeRec, tm)
end
--是否是PVE
function _bat.isPveFight(b)
    b = b.type.value
    return b == 1 or b == 2 or b == 4 or b == 6 or b == 7 or b == 9 or b == 10 or b == 12 or b == 13
end
--是否是PVP
function _bat.isPvpFight(b)
    b = b.type.value
    return b == 3 or b == 5 or b == 8 or b == 11
end
--给定的战斗类型是否消耗 血 兵 忠诚
function _bat.isConsume(b)
    b = b.type.value
    return b == 1 or b == 2 or b == 4 or b == 9
end
--[Comment]
--给定的战斗类型是否仅消耗 忠诚
function _bat.IsConsume(kind)
    return kind == 1 or kind == 2 or kind == 4 or kind == 9
end
--[Comment]
--给定的战斗类型是否仅消耗 忠诚
function _bat.IsConsumeLoyaty(kind)
    return kind == 3
end
--给定的战斗类型是否仅消耗 忠诚
function _bat.isConsumeLoyaty(b)
    return b.type.value == 3
end
--是否是自动战斗
function _bat.isAutoFight(b)
    b = b.type.value
    return b == 0 or b == 5 or b == 6 or b == 11
end
--是否可以战斗加速
function _bat.canAccelerate(b)
    return b.vip.value >= BD_Const.ACC_VIP
end
--是否可以战斗加速
function _bat.canSkipBattle(b)
    return b.vip.value >= BD_Const.SKIP_VIP
end
--攻方存活武将数量
function _bat.atkAliveHeroQty(b)
    local c = 0
    for _, h in ipairs(b.atkHeros) do if h.status.value == 1 then c = c + 1 end end
    return c
end
--守方存活武将数量
function _bat.defAliveHeroQty(b)
    local c = 0
    for _, h in ipairs(b.defHeros) do if h.status.value == 1 then c = c + 1 end end
    return c
end

--随机我方出战武将
local function RandomAtkFightHero(b)
    for i, h in ipairs(b.atkHeros) do
        if h.status.value == 1 then
            b.atkFightHero.value = i
            return
        end
    end
end
--我方出战武将索引
function _bat.atkFightHeroIdx(b)
    local h = b.atkHeros[b.atkFightHero.value]
    if h == nil or h.status.value ~= 1 then RandomAtkFightHero(b) end
    return b.atkFightHero.value
end
--设置我方出战武将索引
function _bat.SetAtkFightHeroIdx(b, idx)
    local h = b.atkHeros[idx]
    if h and h.status.value == 1 then
        b.atkFightHero.value = idx
    else
        RandomAtkFightHero(b)
    end
end
--随机敌方出战武将
local function RandomDefFightHero(b)
    local lst = { }
    for i, h in ipairs(b.defHeros) do
        if h.status.value == 1 then
            insert(lst, i)
        end
    end
    b.defFightHero.value = #lst > 0 and lst[B_Math.floor(B_Math.random(#lst + 0.99))] or 1
end
--敌方方出战武将索引
function _bat.defFightHeroIdx(b)
    local h = b.defHeros[b.defFightHero.value]
    if h == nil or h.status.value ~= 1 then RandomDefFightHero(b) end
    return b.defFightHero.value
end
if isDebug then
    --测试 选择敌方武将
    function _bat.SetFightIdx(b, idx)
        local h = b.defHeros[idx]
        if h and h.status.value == 1 then b.defFightHero.value = idx end
    end
end

--合成战斗类型和编号，用于发生给服务器
function _bat.typeSend(b)
    local t = b.type.value
    if t == 1 then return "siege|"..b.sn end
    if t == 2 then return "battle|"..b.sn end
    if t == 3 then return "pvp|"..b.sn.."|"..b.defSN end
    if t == 4 then return "fb|"..b.sn.."|"..B_Math.clamp(b.diff.value, 1, 3) end
    if t == 5 then return "rank|"..b.sn end
    if t == 6 then return "boss" end
    if t == 7 then return "ta|"..b.sn.."|"..B_Math.clamp(b.diff.value, 1, 3) end
    if t == 8 then return "" end
    if t == 9 then return "lszx|"..b.sn end
    if t == 10 then return "jxtz|"..b.sn end
    if t == 11 then return "mine|"..b.sn end
    if t == 12 then return "exp|"..b.sn end
    if t == 13 then return "test|"..b.sn end
    return ""
end
--战场附加信息
function _bat.addtionInfo(b)
    local str = ""
    if b.fightTimeRec then
        for i, v in ipairs(b.fightTimeRec) do
            if i == 1 then
                str  = v
            else
                str = str .. "," .. v
            end
        end
    end
    return b.vip.value .. "|" .. b.seed .."|" .. str
end
--攻方战斗结果[SN|HP|SP|TP|ST|REC],用于发生给服务器
function _bat.atkHeroResult(b)
    local ret = ""
    local isFantasy = b.type.value == 12
    for i, h in ipairs(b.atkHeros) do
        if i > 1 then ret = ret .. "," end
        ret = ret .. h.sn .. "|" .. h.hp.value .. "|" .. h.sp.value .. "|" .. h.tp.value .. "|" .. h.status.value .. "|" .. h.stats.value
        if isFantasy then
            --幻境挑战需要扩展数据
            ret = ret .. "|" .. B_Math.modf((h.hp.value / h.max_hp.value) * 1000) .. "|" .. B_Math.modf((h.sp.value / h.max_sp.value) * 1000) .. "|" .. math.modf((h.tp.value / h.max_tp.value) * 1000) .. "|" .. h.skillRec
        end
    end
    return ret
end
--守方战斗结果[DBSN|HP|SP|TP|SU|ST],用于发生给服务器
function _bat.defHeroResult(b)
    local ret = ""
    local t = b.type.value
    for i, h in ipairs(b.defHeros) do
        if i > 1 then ret = ret .. "," end
        ret = ret .. h.sn .. "|"
        if t == 6 then
            ret = ret .. (b.cheat == 0 and B_Math.max(0, h.max_hp.value - h.hp.value) or 0)
        elseif t == 13 then
            ret = ret .. h.statDmgS
        else
            ret = ret .. h.hp.value
        end
        ret = ret .. "|" .. h.sp.value .. "|" .. h.tp.value .. "|" .. h.status.value .. "|" .. h.stats.value
        if t == 12 then
            --幻境挑战需要扩展数据
            ret = ret .. "|" .. B_Math.modf((h.hp.value / h.max_hp.value) * 1000) .. "|" .. B_Math.modf((h.sp.value / h.max_sp.value) * 1000) .. "|" .. B_Math.modf((h.tp.value / h.max_tp.value) * 1000) .. "|" .. h.skillRec
        end
    end
    return ret
end

--武将排序
--heroSn : 武将SN列表
function _bat.SortAtkHero(b, heroSn)
    local lenR = #heroSn
    local lst = b.atkHeros
    local idx = 1
    local h, flag
    for i = 1, #lst, 1 do
        h = lst[i]
        flag = false
        while idx < lenR do
            for j = i, #lst, 1 do
                if lst[j].sn == heroSn[idx] then
                    flag = true
                    if i ~= j then
                        lst[i] = lst[j]
                        lst[j] = h
                    end
                    break
                end
            end
            idx = idx + 1
            if flag then break end
        end
    end
end
--获取攻方武将数据
function _bat.GetAtkHero(b, idx) return b.atkHeros[idx] end
--获取攻方武将数据
function _bat.GetDefHero(b, idx) return b.defHeros[idx] end
--获取名将谱属性枚举
--isAtk : 是否攻方
function _bat.GetHeroAtlas(b, isAtk) return isAtk and b.atkAtlas or b.defAtlas end
--获取联盟科技属性枚举
--isAtk : 是否攻方
function _bat.GetAllyTech(b, isAtk) return isAtk and b.atkTech or b.defTech end
--获取道具SN
--isAtk : 是否攻方
--idx : 索引
function _bat.GetPropsSn(b, isAtk, idx) isAtk = isAtk and b.atkPropsSn or b.defPropsSn; return isAtk and isAtk[idx] or 0 end

function _bat.__index(t, k) return rawget(_bat, k) end
setmetatable(_bat, _bat)
--[Comment]
--战斗数据
QYBattle.Battle = _bat