local _gem =
{
    --[Comment]
    --序列号
    sn = 0,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --宝石的稀有度
    rare = 0,
    --[Comment]
    --宝石颜色[1=黄 2=红 3=绿 4=紫]
    color = 0,
    --[Comment]
    --宝石类型
    kind = 0,
    --[Comment]
    --宝石的等级
    lv = 0,
    --[Comment]
    --升到改级别花费的银币
    cost = 0,
    --[Comment]
    --宝石的属性加成(非生命宝石)
    att = nil,
}

--[Comment]
--颜色名称表[1:琥珀,2:血玉,3:翡翠,4:紫晶]
local _cnm = { "琥珀", "血玉", "翡翠", "紫晶" }
--[Comment]
--获取宝石颜色对应的名称
local function GetKindName(c) return LN(_cnm[c]) end
--[Comment]
--获取宝石颜色对应的名称
_gem.GetKindName = GetKindName
--[Comment]
--获取宝石属性描述
local function AttIntro(g) g = g.att; return g and #g > 0 and DB.GetAttWord(g[1]) or "" end
--[Comment]
--获取宝石属性描述
_gem.AttIntro = AttIntro

--[Comment]
--宝石默认排序器
function _gem.Compare(x, y)
    if x.kind < y.kind then return true end
    if x.kind > y.kind then return false end
    return x.lv < y.lv
end

--[Comment]
--Item接口(显示名称)
function _gem.getName(g) return LN(g.nm) end
--[Comment]
--Item接口(显示信息)
function _gem.getIntro(g) return AttIntro(g) end
--[Comment]
--ToolTip接口(显示名称和信息)
function _gem.getPropTip(g, qty)
    qty = qty or g.qty
    
    return ColorStyle.Gem(LN(g.nm), g.color),L("类型") .. ":" .. GetKindName(g.color) .. "\n" .. L("等级") .. ":" .. g.lv ..(qty and qty > 0 and "\n" .. L("数量") .. ":" .. qty or "") .. "\n" .. L("属性") .. ":" .. AttIntro(g)
end

--继承
objext(_gem)
--[Comment]
--未定义的
_gem.undef = _gem()
--[Comment]
--宝石
--[202]={sn=202,nm="2级智力琥珀",att=ExtAtt({{"ml",35}}),rare=4,color=1,kind=2,lv=2,cost=10000},
DB_Gem = _gem