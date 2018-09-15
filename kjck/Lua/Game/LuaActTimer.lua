local _t = { }

local _day = L("天")

--- <summary>3</summary>
_t.style = {
    g0 = L("活动剩余时间") .. ":",
    g0end = "",
    e0 = L("活动剩余时间") .. ":" .. "[FF0000]" .. L("已结束") .. "[-]",
    l0 = L("活动剩余时间") .. ":" .. "[00FF00]" .. L("永 久") .. "[-]",
}

--- <summary>2</summary>
_t.seven = {
    g0 = L("活动剩余时间") .. ":",
    g0end = "",
    e0 = L("活动剩余时间") .. ":" .. "[FF0000]" .. L("已结束") .. "[-]",
    l0 = L("活动剩余时间") .. ":" .. "[00FF00]" .. L("已结束") .. "[-]",
}

--- <summary>2</summary>
_t.online = {
    g0 = "",
    g0end = "",
    e0 = L("领取奖励"),
    l0 = L("领取奖励"),
}

--- <summary>2</summary>
_t.party = {
    g0 = L("离宴会开始:"),
    g0end = "",
    e0 = L("宴会进行中"),
    l0 = L("宴会进行中"),
}

_t.quest = {
    g0 = L("剩余时间") .. ":",
    g0end = "\n" .. ColorStyle.Grey(L("任务结束后结算领奖")),
    e0 = L("任务已结束"),
    l0 = L("任务已结束"),
}

local function gettm(tm)
    local kind = type(tm)
    if kind == "table" then
        return math.max(0, math.modf(os.time(tm) - SVR.SvrTime()))
    elseif kind == "number" then
        return tm
    end
    return -1
end

local function _call(t, c, tm, style)
    tm = gettm(tm)
    style = style or t.style
    local act = c:GetCmp("ActTimer")
    if act then
        act:Init(tm, style.g0, style.g0end, style.e0, style.l0, _day)
    end
end
setmetatable(_t, { __call = _call })

LuaActTimer = _t