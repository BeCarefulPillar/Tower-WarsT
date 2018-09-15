local _lnp =
{
    --[Comment]
    --序列号
    sn = 0,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --介绍
    i = uL,
    --[Comment]
    --价格
    coin = 0,
    --[Comment]
    --克制的阵形
    sup = nil,
}

--[Comment]
--Item接口(显示名称)
function _lnp.getName(l) return LN(l.nm) end
--[Comment]
--Item接口(显示信息)
function _lnp.getIntro(l) return L(l.i) end
--[Comment]
--ToolTip接口(显示名称和信息)
function _lnp.getPropTip(l)
    local str, sup = "", l.sup
    if sup then for i = 1, #sup do str = str .. L(DB.GetLnp(sup[i]).nm) .. " " end end
    return LN(l.nm), L("克制") .. ":" .. str .. "\n" .. L("价格") .. ":" .. l.coin .. "\n" .. L("说明") .. ":" .. L(l.i)
end

--继承
objext(_lnp)
--[Comment]
--未定义的
_lnp.undef = _lnp()
--[Comment]
--阵形
--[1]={sn=1,nm="方形",i="",coin=50000,sup={2,4,5,7}},
DB_Lnp = _lnp