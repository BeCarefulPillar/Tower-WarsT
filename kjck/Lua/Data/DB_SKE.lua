local _ske = {
    --[Comment]
    --序列号
    sn = 0,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --介绍
    i = "",
    --[Comment]
    --觉醒技的属性码
    mark = nil,
    --[Comment]
    --觉醒技的等级数值
    vals = nil,
}
--[Comment]
--觉醒技的等级描述
local function GetlvIntro(s, lv)
    lv = lv and lv or 0
    if lv and lv > 0 then
        local v = s.val
        lv = v and v[lv < 1 and 1 or lv > #v and #v or lv] or 0
    end
    return string.format(s.i,lv)
end

function _ske.getName(s) return LN(s.nm) end
--[Comment]
--觉醒技的等级描述
_ske.getIntro = GetlvIntro

function _ske.getPropTip(s, lv) 
    if lv and lv < 1 then lv = nil end
    return LN(s.nm), L("类型") .. ":" .. L("觉醒技") .."\n".. L("等级") .. ":" ..(lv or L("未解锁")) .. "\n" .. L("说明") .. ":" .. GetlvIntro(s, lv or 0)
end

--继承
objext(_ske)
--[Comment]
--未定义的
_ske.undef = _ske()
--[Comment]
--觉醒技
--[2]={sn=2,nm="破军之智",i="受到士兵攻击伤害降低%d%%",mark="bf",val={5,10,15,20,30}},
DB_SKE = _ske
