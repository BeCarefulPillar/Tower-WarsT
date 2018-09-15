

local qs = UE.QualitySettings
local screen = UE.Screen

--[Comment]
--游戏动态配置数据
CONFIG =
{
    --[Comment]
    --基础帧率
    FRAME_RATE = isIOS and 60 or 33,
    --[Comment]
    --最大帧率
    FRAME_RATE_MAX = 60,
    --[Comment]
    --tan 30
    TAN_30 = 0.57735,
    --[Comment]
    --秒到纳秒
    SEC_TO_TICK = 10000000,
    --[Comment]
    --纳秒到秒
    TICK_TO_SEC = 0.0000001,
    --[Comment]
    --超时时间
    TIME_OUT = 15,
    --[Comment]
    --超时极限
    TIME_OUT_LIMIT = 60,

    --[Comment]
    --最大聊天存储数
    MAX_CHAT = 50,
    --[Comment]
    --世界聊天CD
    CHAT_WORLD_CD = 10,
    --[Comment]
    --更新间隔
    UPDATE_INTERVAL = 5,
    --[Comment]
    --高更新间隔
    UPDATE_INTERVAL_HIGH = 60,
    --[Comment]
    --summary
    MAX_BATTLE_HERO = 5,
    --[Comment]
    --审核模式
    apple_permit = true,
    --[Comment]
    --客服地址
    kfUrl = "",
    --[Comment]
    --是否需要实名验证
    needVerify = false,
    --[Comment]
    --实名验证是否限制充值
    verifyCharge = false,
    --[Comment]
    --实名验证是否限制功能
    verifyFunc = false,

    --[Comment]
    --新手指引关卡
    T_LEVEL = 7,
    --[Comment]
    --在装备剩余空间低于或等于此值时提示警告
    EquipTipCount = 10,
    --[Comment]
    --释放俘虏的极限数目
    FreeCaptiveLimit = 10,
    --[Comment]
    --聊天特权等级
    ChatVip = 3,

    --[Comment]
    --是否提示出征武将
    tipSelectHero = true,
    --[Comment]
    --十连抽提示
    tipRw10 = true,
    --[Comment]
    --副将十连抽ishi
    tipRwDe10 = true,
    --[Comment]
    --联盟的提示
    tipAlly = false,
    --[Comment]
    --武将补血提示
    tipHeroRest = true,
    --[Comment]
    --秘境巡游提示
    tipFamCost = false,
    --[Comment]
    --提示乱世争雄
    tipClanWar = true,
    --[Comment]
    --提示演武榜
    tipRankSolo = true,
    --[Comment]
    --提示悬赏榜花费积分
    tipAllyBounty = true,
    --[Comment]
    --盟战商城提示
    tipAllyBattleShopRef = true,
    --[Comment]
    --武将展示稀有度
    tipHeroRare = 0,
    --[Comment]
    --装备展示稀有度
    tipEquipRare = 2,
    --[Comment]
    --装备进阶展示
    tipEquipPlus = true,
    --[Comment]
    --军备展示稀有度
    tipDeEquipRare = 2,
    --[Comment]
    --道具展示稀有度
    tipPropsRare = 4,
    --[Comment]
    --将魂展示稀有度
    tipSoulRare = 4,
    --[Comment]
    --副将展示稀有度
    tipDeHeroRare = 0,
}

--[Comment]
-- 武将列表功能类型
HERO_FOR = 
{
    none = 0,
    --[Comment]
    -- 幻境部署武将
    fantsy_deploy = 1,
    --[Comment]
    -- 幻境出战选择武将
    fantsy_battle = 2,
    --[Comment]
    -- 巅峰演武防御
    peak_defence=4,
    --[Comment]
    -- 巅峰演武出战
    peak_attack=8
}