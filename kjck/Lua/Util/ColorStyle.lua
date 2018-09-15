local type = type

local WHITE = "[FFFFFF]"

local SILVE = "[C0C0C0]"
local GOLD = "[FFFF64]"
local RMB = "[40DC50]"
local FOOD = "[B4E640]"
local TOKEN = "[FF6426]"
local SOUL = "[00FF00]"
local MINE = "[A06014]"

local GOOD = "[00FF00]"
local BAD = "[FF0000]"
local WARNING = "[FF8000]"
local BLUE = "[00B4FF]"
local GREY = "[808080]"
local PURPLE = "[FF3EF5]"
local ORANGE = "[FFA054]"

local STEELGRAY = "[8C9DB3]"

local EncodeEnd = "[-]"

local GreyStar = "[808080]★[-]"
local GoldStar = "[FFFF40]★[-]"

local TabColorHightLight = Color.New(255/255, 247/255, 171/255, 255/255)
local TabColorNormal = Color.New(207/255, 207/255, 205/255, 255/255)

--[Comment]
--玩家属性颜色[1=银币 2=金币 3=血库 4=兵力 5=积分 6=粮草 7=封赏令 8=魂币 9=银票 10=军功 11=头像 12=称号 13=矿脉采集点 14=幻境币]
local _pattcor = 
{
    --1 银币
    SILVE,
    --2 金币
    GOLD,
    --3 血库
    WHITE,
    --4 兵力
    WHITE,
    --5 积分
    RMB,
    --6 粮草
    FOOD,
    --7 封赏令
    TOKEN,
    --8 魂币
    SOUL,
    --9 银票
    SILVE,
    --10 军功
    ORANGE,
    --11 头像
    WHITE,
    --12 称号
    WHITE,
    --13 矿脉采集点
    MINE,
    --14 幻境币
    GOLD,
}

--[Comment]
--稀有度色
local _rcor =
{
    --1 白
    Color.white,
    --2 绿 120,253,114
    Color(0.471,0.992,0.447),
    --3 蓝 0 140 255
    Color(0,0.549,1),
    --4 紫 255 62 245
    Color(1,0.243,0.961),
    --5 橙 255 147 27
    Color(1,0.576,0.106),
    --6 红 255 51 51
    Color(1,0.2,0.2),
    --7 橙红 207 84 0
    Color(0.812,0.329,0),
}
--[Comment]
--稀有度色编码
local _rcode =
{
    --1 白
    "[FFFFFF]",
    --2 绿 120,253,114
    "[78FD72]",
    --3 蓝 0 140 255
    "[008CFF]",
    --4 紫 255 62 245
    "[FF3EF5]",
    --5 橙 255 147 27
    "[FF931B]",
    --6 红 255 51 51
    "[FF3333]",
    --7 橙红 207 84 0
    "[CF5400]",
}
--[Comment]
--宝石颜色
local _gcor =
{
    --1 琥珀 255 220 72
    Color(1,0.862,0.282),
    --2 血玉 184 12 12
    Color(0.722,0.047,0.047),
    --3 翡翠 0 220 30
    Color(0,0.862,0.118),
    --4 紫晶 240 0 240
    Color(0.941,0,0.941),
}
--[Comment]
--宝石颜色编码
local _gcode =
{
    --1 琥珀 255 220 72
    "[FFDC48]",
    --2 血玉 184 12 12
    "[B80C0C]",
    --3 翡翠 0 220 30
    "[00DC1E]",
    --4 紫晶 240 0 240
    "[F000F0]",
}
--[Comment]
--国家颜色
local _ncor =
{
    --1 魏
    Color(0.1765,0.4667,0.8627),
    --2 蜀
    Color(0.2118,0.7294,0.1569),
    --3 吴
    Color(0.7922,0.2824,0.1843),
    --4 蛮
    Color(0.9020, 0, 1),
}
_ncor["魏"] = _ncor[1]
_ncor["蜀"] = _ncor[2]
_ncor["吴"] = _ncor[3]
_ncor["蛮"] = _ncor[4]
--[Comment]
--国家颜色编码
local _ncode =
{
    --1 魏
    "[2D78DC]",
    --2 蜀
    "[36BA28]",
    --3 吴
    "[CA482F]",
    --4 蛮
    "[E600FF]",
}
_ncode["魏"] = _ncode[1]
_ncode["蜀"] = _ncode[2]
_ncode["吴"] = _ncode[3]
_ncode["蛮"] = _ncode[4]

--[Comment]
--聊天颜色编码
local _ccode =
{
    --系统
    "[FF0000]",
    --2 私聊
    "[FF49E7]",
    --3 世界
    "[49B4FF]",
    --4 联盟
    "[00F900]",
    --5 国家
    "[49FFDB]",
}
_ccode["系统"] = _ccode[1]
_ccode["私聊"] = _ccode[2]
_ccode["世界"] = _ccode[3]
_ccode["联盟"] = _ccode[4]
_ccode["国家"] = _ccode[5]

--[Comment]
--武将阵营颜色
local _hcor =
{
    Color(0.3,0.42,1),
    Color(0.52,1,0.43),
    Color(1,0.35,0.35),
    Color(0.25,0.25,0.33),

    undef = Color(1,0.78,0.27),
}

--[Comment]
--武将属性颜色
local _hattcor =
{
    Color(1,0.353,0),--武力
    Color(0,0.55,1),--智力
    Color(0.98,0.98,0.3137),--统帅
    Color(0.98,0,0),--生命
    Color(0,1,0.941),--技力
    Color(0.7843,1,0),--兵力
}

--[Comment]
--页签tab字体颜色
local _tab = 
{
    Color(0.55, 0.6157, 0.7),--蓝灰
}

--[Comment]
--颜色样式
ColorStyle =
{
    --[Comment]
    --编码结尾
    EncodeEnd = EncodeEnd,

    --[Comment]
    --银色
    SILVE = SILVE,
    --[Comment]
    --金色
    GOLD = GOLD,
    --[Comment]
    --积分色
    RMB = RMB,
    --[Comment]
    --粮草
    FOOD = FOOD,
    --[Comment]
    --封赏令
    TOKEN = TOKEN,
    --[Comment]
    --将魂
    SOUL = SOUL,
    --[Comment]
    --矿点
    MINE = MINE,

    --[Comment]
    --良好的绿色
    GOOD = GOOD,
    --[Comment]
    --反面的红色
    BAD = BAD,
    --[Comment]
    --警告色
    WARNING = WARNING,
    --[Comment]
    --蓝色
    BLUE = BLUE,
    --[Comment]
    --灰色
    GREY = GREY,
    --[Comment]
    --紫色
    PURPLE = PURPLE,
    --[Comment]
    --橙色
    ORANGE = ORANGE,
    --[Comment]
    --蓝灰色
    STEELGRAY = STEELGRAY,

    --[Comment]
    --灰色星
    GreyStar = GreyStar,
    --[Comment]
    --金色星
    GoldStar = GoldStar,
}

--[Comment]
--外发光颜色
ColorStyle.OutLight_2 = Color(170/255, 170/255, 270/155)
--[Comment]
--红
ColorStyle.Red = Color(1, 0, 0)
--[Comment]
--shader  HSB 正常颜色
ColorStyle.HSB_Normal = Color(128/255, 128/255, 128/255)
--[Comment]
--shader  HSB 置灰
ColorStyle.HSB_Disabled = Color(0, 0, 128/255)
--[Comment]
--tab初始颜色
ColorStyle.TabColorGlay = Color(48/255, 46/255, 41/255)
--[Comment]
--外发光颜色
ColorStyle.OutLight = Color(150/255,150/255,150/255)
--[Comment]
--tab标签高亮颜色
ColorStyle.TabColorNormal_2 = Color(217/255, 217/255, 217/255)

--聊天显示颜色
local _ccor = {
    --未知
    [0] = Color.gray,
    --系统
    [1] = Color.red,
    --私聊
    [2] = Color(255/255,73/255,231/255),
    --世界
    [3] = Color(73/255,180/255,255/255),
    --联盟
    [4] = Color(0/255,249/255,0/255),
    --国家
    [5] = Color(73/255,255/255,219/255),
}
--[Comment]
--获取聊天频道显示颜色
function ColorStyle.Chat(idx) return _ccor[idx] end
--[Comment]
--银色
function ColorStyle.Silver(str) return SILVE .. str .. EncodeEnd end
--[Comment]
--金色
function ColorStyle.Gold(str) return GOLD .. str .. EncodeEnd end
--[Comment]
--积分颜色
function ColorStyle.Rmb(str) return RMB .. str .. EncodeEnd end
--[Comment]
--粮草颜色
function ColorStyle.Food(str) return FOOD .. str .. EncodeEnd end
--[Comment]
--封赏令颜色
function ColorStyle.Token(str) return TOKEN .. str .. EncodeEnd end
--[Comment]
--矿脉采集点
function ColorStyle.Mine(str) return TOKEN .. str .. EncodeEnd end
--[Comment]
--魂币颜色
function ColorStyle.Soul(str) return SOUL .. str .. EncodeEnd end

--[Comment]
--绿色
function ColorStyle.Good(str) return GOOD .. str .. EncodeEnd end
--[Comment]
--红色
function ColorStyle.Bad(str) return BAD .. str .. EncodeEnd end
--[Comment]
--警告色
function ColorStyle.Warning(str) return WARNING .. str .. EncodeEnd end
--[Comment]
--蓝色
function ColorStyle.Blue(str) return BLUE .. str .. EncodeEnd end
--[Comment]
--灰色
function ColorStyle.Grey(str) return GREY .. str .. EncodeEnd end
--[Comment]
--紫色
function ColorStyle.Purple(str) return PURPLE .. str .. EncodeEnd end
--[Comment]
--橙色
function ColorStyle.Orange(str) return ORANGE .. str .. EncodeEnd end
--[Comment]
--蓝灰色
function ColorStyle.SteelGray(str) return STEELGRAY .. str .. EncodeEnd end

--[Comment]
--聊天界面频道显示颜色
function ColorStyle.ChatCode(str, chn) return _ccode[chn] .. str .. EncodeEnd end

--[Comment]
--玩家属性颜色[1=银币 2=金币 3=血库 4=兵力 5=积分 6=粮草 7=封赏令 8=魂币 9=银票 10=军功 11=头像 12=称号 13=矿脉采集点 14=幻境币]
function ColorStyle.PlayerAtt(nm, paid) return nm and (_pattcor[paid] or WHITE)..nm..EncodeEnd end

--[Comment]
--各个稀有度的颜色(稀有度 1-6 五级)，返回Color对象
function ColorStyle.GetRareColor(rare) return _rcor[rare] or Color.white end
--[Comment]
--各个稀有度的颜色编码(稀有度 1-6 五级)，返回字符串编码
local function GetRareColorStr(rare) return _rcode[rare] or WHITE end
ColorStyle.GetRareColorStr = GetRareColorStr

--[Comment]
--各个稀有度的颜色(稀有度 1-6 五级)，返回Color对象
function ColorStyle.GetGemColor(rare) return _gcor[rare] or Color.white end

--[Comment]
--各个稀有度的颜色编码(稀有度 1-6 五级)，返回字符串编码
local function GetGemColorStr(rare) return _gcode[rare] or WHITE end
ColorStyle.GetGemColorStr = GetGemColorStr

--[Comment]
--按稀有度给色
function ColorStyle.Rare(str, r)
    if "table" == type(str) then
        r, str = str.rare, str.getName and str:getName() or L(str.nm)
    end
    return r and str and GetRareColorStr(r) .. str .. EncodeEnd or ""
end
--[Comment]
--宝石颜色
function ColorStyle.Gem(str, c)
    if "table" == type(str) then
        c, str = str.color, str.getName and str:getName() or L(str.nm)
    end
    return c and GetGemColorStr(c) .. str .. EncodeEnd or ""
end
    
--[Comment]
--获取国家颜色
function ColorStyle.GetNatColor(snm) return _ncor[snm] or Color.white end
--[Comment]
--获取国家的颜色字编码
function ColorStyle.GetNatColorStr(snm) return _ncode[snm] or WHITE end
    
--[Comment]
--获取带颜色颜色字符串的国家名称
function ColorStyle.GetNatNmWithColor(nsn) return(_ncode[snm] or WHITE) .. DB.GetNatName(nsn) .. EncodeEnd end
    
--[Comment]
--获取武将国别颜色
function ColorStyle.GetHeroClanColor(clan) return _hcor[clan] or _hcor.undef end
    
--[Comment]
--获取武将各属性颜色[1武力 2智力 3统帅 4生命 5技力 6兵力]
function ColorStyle.GetHeroAttColor(aid) return _hattcor[aid] or Color.white end

--[Comment]
--获取页签tab的颜色[1蓝灰 其他白色]
function ColorStyle.GetTabColor(aid) return _tab[aid] or Color.white end

