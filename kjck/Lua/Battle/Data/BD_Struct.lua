

local _struct = { }
QYBattle.BD_Struct = _struct

--[Comment]
--战斗玩家数据
_struct.S_BattlePlayer =
{
    --玩家PSN
    "psn",
    --string-玩家名称
    "nick",
    --玩家服武器编号
    "rsn",
    --玩家联盟SN
    "gsn",
    --玩家所属国家
    "nat",
}

--[Comment]
--战斗武将信息
_struct.S_BattleHero =
{
    --武将编号，非PVP为DBSN
    "sn",
    --武将的DBSN
    "dbsn",
    --武将等阶
    "evo",
    --武将等级
    "lv",
    --武将武力
    "str",
    --武将智力
    "wis",
    --武将统率
    "cap",
    --武将忠诚
    "loyalty",
    --武将当前HP
    "hp",
    --武将最大HP
    "max_hp",
    --武将当前SP
    "sp",
    --武将最大SP
    "max_sp",
    --武将当前TP
    "tp",
    --武将最大TP
    "max_tp",
    --武将兵种编号
    "arm",
    --武将阵形编号
    "lnp",
    --将星等级
    "star",
    --string-扩展属性:幻化、专属、套装、宝石、星级
    "extra",
}

--[Comment]
--武将AI
_struct.S_HeroAI =
{
    --int-武将行为(0=智能,1=不动,2=冲锋)
    "heroAct",
    --int[]-技能释放顺序
    "skidx",
    --int[]-技能释放间隔时间[MS]
    "skWait",
}

--[Comment]
--武将技具体数据
_struct.S_SKC =
{
    --技能编号
    "sn",
    --耗蓝
    "sp",
    --CD基础值
    "cd",
    --持续时间
    "keep",
    --string-范围(x,y)
    "range",
    --string-DPS(STR|INT|CAP|CNT)
    "dps",
    --string-扩展属性
    "ext",
}

--[Comment]
--武将技五行
_struct.S_SKC_FE =
{
    --技能编号
    "sksn",
    --五行编号[1:金 2:木 3:水 4:火 5:土]
    "fesn",
    --加成值
    "val",
}

--[Comment]
--副将技能
_struct.S_SKD =
{
    --技能编号
    "sn",
    --技能等级
    "lv",
    --冷却时间
    "cd",
    --触发次数
    "qty",
    --BUF可叠加次数
    "rep",
    --触发条件的源(-1=不需要，1=我方，2=敌方，3=双方)
    "condTag",
    --int[]-触发条件
    "cond",
    --int[]-输出
    "dps",
    --int[]-值
    "val",
}

--[Comment]
--天机技能
_struct.S_SKS =
{
    --技能编号
    "sn",
    --技能等级
    "lv",
    --BUF可叠加次数
    "rep",
    --string-触发条件
    "cond",
    --int[]-值
    "val",
}

--[Comment]
--战场通用属性
_struct.S_BattleAtt =
{
    --通用编号
    "sn",
    --string-扩展属性值
    "extra",
}

--[Comment]
--铜雀台属性
_struct.S_BattleBeauty =
{
    --美女编号
    "bsn",
    --美女星级
    "star",
    --string-扩展属性值
    "extra",
}

--[Comment]
--副将数据
_struct.S_BattleDehero =
{
    --副将DBSN
    "dbsn",
    --副将等级
    "lv",
    --副将星级
    "star",
    --string-天赋&专属加成
    "extra",
    --S_SKD-副将技能
    "skill",

    skill = _struct.S_SKD,
}

--[Comment]
--战场附加数据
_struct.S_BattleAdd =
{
    --int[]-军师技[军师技SN，目标，武力增减，智力增减，统帅增减，生命增减，技力增减，兵力增减，CD增减，暴击，命中，闪避，技能闪避，移动速度，攻击速度，造成武力伤害增减，造成技能伤害增减，受到武力伤害增减，受到技能伤害增减]
    "skt",
    --string-名将谱
    "atlas",
    --int[]-攻方联盟加成 HP TP STR CAP INT
    "tech",
    --S_BattleAtt[]-道具
    "props",
    --string-虚弱状态，疲劳值相关（仅限国战）
    "weak",
    --string-个人科技树（仅限国战）
    "perTech",
    --string-国家科技树（仅限国战）
    "natTech",
    --int-地宫房间陷阱编号
    "gveTrap",

    props = _struct.S_BattleAtt,
}

--[Comment]
--战场对战武将数据
_struct.S_BattleHeroFight =
{
    --S_SKC[]-武将技
    "skill",
    --S_BattleAtt-觉醒技
    "ske",
    --S_BattleAtt 地宫房间buff
    "gveBuff",
    --string 兵种buff
    "armBuff",
    --int[]-士兵基本属性[0=STR 1=HP 2=CRIT 3=ACC 4=DODGE]
    "armAtt",
    --string-阵形铭刻
    "lnpImp",
    --武将性别(1=男 2=女 else=未知)
    "sex",
    --int[]-锦囊技数据[SN,LV,VALS]
    "skp",
    --S_BattleDehero-副将
    "dehero",
    --阵形位置数据(为空表示相同)
    "lnpData",
    --S_SKS[]-天机技能
    "sks",
    --S_SKC_FE[]-武将技五行加成
    "skcFe",
    --S_HeroAI-AI配置
    "ai",

    skill = _struct.S_SKC,
    ske = _struct.S_BattleAtt,
    gveBuff = _struct.S_BattleAtt,
    dehero = _struct.S_BattleDehero,
    sks = _struct.S_SKS,
    skcFe = _struct.S_SKC_FE,
    ai = _struct.S_HeroAI,
}

--[Comment]
--对战数据
_struct.S_BattleFightData =
{
    --阵形克制关系 0=双方无克制 1=敌方被克制 2=我方被克制
    "lnpRes",
    --兵种克制关系 0=双方无克制 1=敌方被克制 2=我方被克制
    "armRes",
    --S_BattleHeroFightData-我方武将数据
    "atkHero",
    --S_BattleHeroFight-敌方武将数据
    "defHero",

    atkHero = _struct.S_BattleHeroFight,
    defHero = _struct.S_BattleHeroFight,
}

--[Comment]
--一般队伍攻城战
_struct.S_BattleSiege =
{
    --战斗类型 0=新手模拟战 1=攻城 2=战役 3=PVP攻城 4=副本 5=演武榜 6=BOSS战 7=过关斩将 8=国战 9=乱世争雄 10=极限挑战 11=矿脉战 12=幻境挑战 13=二代BOSS
    "type",
    --种子
    "seed",
    --攻城/副本=攻占城池编号，战役=战役子关卡编号，PVP为城池位置号，演武榜为玩家编号，过关斩将为关卡编号，乱世争雄为副本编号，极限挑战为武将DBSN，矿脉战为矿脉SN，幻境挑战为关卡编号
    "sn",
    --守方玩家编号,没有则为0
    "defSN",
    --当前玩家VIP等级
    "vip",
    --敌方军师DBSN
    "defAdv",
    --玩家当前总血库
    "php",
    --玩家当前总兵力
    "ptp",
    --强制开战时间
    "fightTime",
    --int[]-战场参数
    "param",
    --S_BattleHero[]-攻方武将列表
    "atkHeros",
    --S_BattleHero[]-守方武将列表
    "defHeros",
    --S_BattleAdd-攻方附加
    "atkAdd",
    --S_BattleAdd-守方附加
    "defAdd",

    atkHeros = _struct.S_BattleHero,
    defHeros = _struct.S_BattleHero,
    atkAdd = _struct.S_BattleAdd,
    defAdd = _struct.S_BattleAdd,
}

--[Comment]
--战斗单方数据 国战 盟战
_struct.S_BattleSide =
{
    --S_BattlePlayer-玩家信息
    "player",
    --S_BattleHero武将基本数据
    "hero",
    --S_BattleHeroFight-武将战斗数据
    "fight",
    --S_BattleAdd-战场附加
    "add",

    player = _struct.S_BattlePlayer,
    hero = _struct.S_BattleHero,
    fight = _struct.S_BattleHeroFight,
    add = _struct.S_BattleAdd,
}

--[Comment]
--单次自动战斗，国战，盟战
_struct.S_BattleSingle =
{
    --战斗类型(100:国战,101:盟战,102:跨服国战,103:跨服PVP)
    "type",
    --SN,国战为城池编号，盟战为路线
    "sn",
    --战斗种子
    "seed",
    --int[]-战场参数
    --1:武力因子(武将/士兵的武力输出 = 武力*武力因子/100)  2:士兵武力因子(士兵武力 = 武将武力*士兵武力因子/100)
    --3:士兵生命因子(士兵生命 = 武将生命*士兵生命因子/100) 4:CD极限 
    --5:CD因子:(CD = (武将智力/CD因子 + 技能CD基础值))     6:阵形因子(武将三围 -= 武将三围*阵形因子/100) 
    --7:兵种因子(士兵二围 -= 士兵二围*兵种因子/100)        8:闪避极限(百分之)
    --9:技能闪避极限(百分之) 10:武力减伤极限(百分之) 11:技能减伤极限(百分之) 12:武力击晕上限(百分之) 13:移动速度极限 14:攻击速度极限 15:技能暴击的上限
    "param",
    --阵形克制关系 0=双方无克制 1=敌方被克制 2=我方被克制
    "lnpRes",
    --兵种克制关系 0=双方无克制 1=敌方被克制 2=我方被克制
    "armRes",
    --S_BattleDataSide-攻方数据
    "atk",
    --S_BattleDataSide守方数据
    "def",

    atk = _struct.S_BattleSide,
    def = _struct.S_BattleSide,
}