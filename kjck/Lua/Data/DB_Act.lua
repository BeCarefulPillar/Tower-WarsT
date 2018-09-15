local _act =
{
    --[Comment]
    --活动编号
    sn = 0,
    --[Comment]
    --活动名称
    nm = nil,
    --[Comment]
    --活动基本说明
    i = nil,
    --[Comment]
    --积分名称
    snm = nil,
    --[Comment]
    --活动积分图标
    ico = 0,
}

--[Comment]
--获取活动币提示说明
local function ScoreIntro(a) return string.format(L("用于活动%s"), ColorStyle.Blue(LN(a.nm))) end
--[Comment]
--获取活动币提示说明
_act.ScoreIntro = ScoreIntro
--[Comment]
--获取活动币ToolTip提示说明
function _act.ScorePropTip(a, qty)
    local nm = a.nm
    if nm and nm ~= "" then
        return LN(nm), L("数量") .. ":" ..(qty or 0) .. "\n" .. L("说明") .. ":" ..ScoreIntro(a)
    end
end

--[Comment]
--Item接口(显示名称)
function _act.getName(a) return LN(a.nm) end
--[Comment]
--Item接口(显示信息)
function _act.getIntro(a) return L(a.i) end
--[Comment]
--ToolTip接口(显示名称和信息)
function _act.getPropTip(a) return L(a.nm), L(a.i) end

--[Comment]
--活动
--{sn=999,nm="BOSS奖励双倍",snm="",ico=0}
DB_Act = _act
--继承
objext(_act)
--[Comment]
--未定义的
_act.undef = _act()
