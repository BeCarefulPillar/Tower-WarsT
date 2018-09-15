--[Comment]
--默认加密跳数
EN_SKIP = 16

--[Comment]
--默认渠道编号
DEF_CID = -1

--[Comment]
--通用超时时间
TIMEOUT = 10

--[Comment]
--主力将稀有度（五星将）
MAIN_HERO_RARE = 5

--[Comment]
--PVP地图的区大小
PVP_MAP_SIZE = 64

--[Comment]
--程序集相关名称
ASB_NM = 
{
    U3D = "UnityEngine",
    CUR = "Assembly-CSharp",
}
--[Comment]
--StatusBarID
ST_ID = 
{
    CHECK_LINK = 1,
    CHECK_CLIENT = 2,
    CONNECT = 3,
    LOGIN = 4,
    LOGOUT = 5,
    LOAD_LUA = 6,
    LOAD_SCENE = 7,

    LOAD_DB = 101,
    LOAD_SVR_LST = 102
}
--[Comment]
--场景名称
SCENE=
{
    --[Comment]
    --入口
    ENTRY = "entry",
    --[Comment]
    --登录
    LOGIN = "login",
    --[Comment]
    --新手
    NOVICE = "novice",
    --[Comment]
    --游戏
    GAME = "game"
}
--[Comment]
--设定的屏幕
SCREEN=
{
    --[Comment]
    --宽
    WIDTH = 1280,
    --[Comment]
    --高
    HEIGHT = 720,
    --[Comment]
    --适配的最大分辨率宽
    MAX_WIDTH = 1600,
    --[Comment]
    --适配的最大分辨率高
    MAX_HEIGHT = 1280,
}
--[Comment]
--窗口状态
WIN_STAT =
{
    --[Comment]
    --初始
    INIT = 0,
    --[Comment]
    --进入中
    ENTERING = 1,
    --[Comment]
    --已进入
    ENTERED = 2,
    --[Comment]
    --退出中
    EXITING = 3,
    --[Comment]
    --已退出
    EXITED = 4,
}
--[Comment]
--AnimationOrTween.Direction
AOT_DRE=
{
    Reverse = -1,
	Toggle = 0,
	Forward = 1
}
--[Comment]
--AnimationOrTween.EnableCondition
AOT_EC=
{
    DoNothing = 0,
    EnableThenPlay = 1,
    IgnoreDisabledState = 2
}
--[Comment]
--AnimationOrTween.DisableCondition
AOT_DC=
{
    DisableAfterReverse = -1,
    DoNotDisable = 0,
    DisableAfterForward = 1
}
--[Comment]
--错误编号
ERR =
{
    Connect = 1001,
    Login = 1002,
    Unknown = 255,
    Hidden = 256,

    Cooling = 11,
    LackGold = 12,
    LackProps = 13,
    LackFood = 14,
    CityNoFight = 20,
    LackToken = 129,
    NoGuild = 130,
}

--[Comment]
--基本属性ID
ATT_BID = 
{
    --[Comment]
    --武力
    STR = 1,
    --[Comment]
    --智力
    WIS = 2,
    --[Comment]
    --统帅
    CAP = 3,
    --[Comment]
    --生命
    HP = 4,
    --[Comment]
    --技力
    SP = 5,
    --[Comment]
    --兵力
    TP = 6,
}
--[Comment]
--装备类型/位置
EQP_KIND =
{
    --[Comment]
    --武器[1]
    WEAPON = 1,
    --[Comment]
    --护甲[2]
    ARMOR = 2,
    --[Comment]
    --坐骑[3]
    HORSE = 3,
    --[Comment]
    --书/宝石[4]
    BOOK = 4,
    --[Comment]
    --最大装备位置
    MAX = 4,
}
--[Comment]
--军备类型/位置
DEQP_KIND =
{
    --[Comment]
    --武力加成[1]
    STR = 1,
    --[Comment]
    --智力加成[2]
    WIS = 2,
    --[Comment]
    --统帅加成[3]
    CAP = 3,
    --[Comment]
    --最大军备位置
    MAX = 4,
}
--[Comment]
-- 地图类型
MAP_TYPE =
{
    --[Comment]
    -- 主城 
    MAIN_CITY = 1,
    --[Comment]
    -- 关卡地图
    MAP_LEVEL = 2,
    --[Comment]
    -- 关卡世界地图
    MAP_MAIN = 3,
    --[Comment]
    -- 争霸地图
    MAP_PVP = 4,
    --[Comment]
    -- 国战地图
    MAP_NATION = 5
}
--[Comment]
--友盟事件定义
UM_EVENT =
{
    Step_1 = "step_1",
    Step_2 = "step_2",
    Step_3 = "step_3",
    Step_4 = "step_4",
    Step_5 = "step_5",
    Step_6 = "step_6",
    UpdateClient = "update_client",
    GameLine = "game_line",
    Guide = "guide",
    UpdateRes = "update_res",
    PvpSiege = "pvp_siege",
    PvpRank = "pvp_rank",
}
--[Comment]
--talkingData自定义事件
TD_EVENT =
{
    UpdateClient = "update_client",
    GameLine = "game_line",
    Guide = "guide",
    UpdateRes = "update_res",
    PvpSiege = "pvp_siege",
    PvpRank = "pvp_rank",
    Step_1 = "剧情对话",
    Step_2 = "模拟战",
    Step_3 = "攻打巨鹿",
    Step_4 = "Get a nickname",
    Step_5 = "Get a nickname success",
    Step_6 = "提示释放技能",
    Step_7 = "提示去酒馆",
    
    SilverSpend = "Sliver Spend",
    GoldSpend = "Gold Spend",
    RmbSpend = "RMB Spend",
}
DAILY_FUNC = 
{
    --[Comment]
    --BOSS
    SN_BOSS = 1,
    --[Comment]
    --过关斩将
    SN_TOWER = 2,
    --[Comment]
    --占卜
    SN_DIVINE = 6,
    --[Comment]
    --秘境
    SN_FAM = 7,
    --[Comment]
    --修炼
    SN_XL = 8,
    --[Comment]
    --幻境
    SN_FANTSY = 9,
}

local hero_x = nil
--[Comment]
-- 武将图片偏移
function HERO_X(imgSN)
    if not hero_x then
        hero_x = AM.LoadBytes("data_hero_x")
    end
    return imgSN >= 0 and imgSN < hero_x.length and hero_x[imgSN] * 0.01 or 0.27
end

ActiveAnimaStyle = 
{
    Rotate = 0,
    Move = 1,
    Scale = 2,
}
