local _arm =
{
    --[Comment]
    --序列号
    sn = 0,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --学习价格
    coin = 0,
    --[Comment]
    --克制的兵种
    sup = nil,
}

--[Comment]
--是否是远程兵种
local function IsRange(a) return a.sn == 4 or a.sn == 6 end
--[Comment]
--是否是远程兵种
_arm.IsRange = IsRange

--[Comment]
--Item接口(显示名称)
function _arm.getName(a) return LN(a.nm) end
--[Comment]
--Item接口(显示信息)
function _arm.getIntro(a) return L(a.i) end
--[Comment]
--ToolTip接口(显示名称和信息)
function _arm.getPropTip(a) 
    local str, sup = "", a.sup
    if sup then for i = 1, #sup do str = str ..L(DB.GetArm(sup[i]).nm) .. " " end end
    return LN(a.nm), L("类型") .. ":" .. L(IsRange(a) and "远程" or "近战") .. L("克制") .. ":" .. str .. "\n" .. L("价格") .. ":" .. a.coin .. "\n" .. L("说明") .. ":" .. L(a.i)
end

--继承
objext(_arm)
--[Comment]
--未定义的
_arm.undef = _arm()
--[Comment]
--兵种
--[1]={sn=1,nm="盾剑兵",coin=0,sup={0,2,4,6,8,10,12}},
DB_Arm = _arm
