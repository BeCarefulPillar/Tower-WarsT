local _hstar =
{
    --[Comment]
    --序列号
    sn = 0,
    --[Comment]
    --成功率
    odds = nil,
    --[Comment]
    --需要的将魂数量
    soul = 0,
    --[Comment]
    --需要的武将等级
    clv = 0,
    --[Comment]
    --需要的材料
    mat = nil,
}

--[Comment]
--取得星级对应的将星
local function GetStar(lv) return lv and(math.modf(lv / 10)) or 0 end
--[Comment]
--取得星级对应的将星
_hstar.GetStar = GetStar
--[Comment]
--取得星级对应的将星小级
local function GetLv(lv) return lv and lv % 10 or 0 end
--[Comment]
--取得星级对应的将星小级
_hstar.GetLv = GetLv
--[Comment]
--当前星级的将星
function _hstar.Star(h) return GetStar(h.sn) end
--[Comment]
--当前星级的将星小级
function _hstar.Lv(h) return GetLv(h.sn) end

--继承
objext(_hstar)
--[Comment]
--未定义的
_hstar.undef = _hstar()
--[Comment]
--武将星级
--[20]={sn=20,odds={25,45,65,85,100},mat={{2,50,40},{2,51,16},{2,52,4}},soul=20,clv=40},
DB_HeroStar = _hstar
