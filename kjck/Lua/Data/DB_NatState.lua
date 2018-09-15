local _nstt =
{
    --[Comment]
    --州郡编号
    sn = 0,
    --[Comment]
    --州郡名称
    nm = nil,
    --[Comment]
    --州郡描述
    i = "",
    --[Comment]
    --州郡科技名称
    tnm = nil,
    --[Comment]
    --州郡科技描述
    ti = "",
    --[Comment]
    --科技[2:粮草上限,3:粮草超限,6:移动速度]
    tsn = 0,

    --[Comment]
    --科技数据
    tech = nil,
}
--[Comment]
--根据经验取得等级
function _nstt.GetLv(s, exp)
    s = s and s.tech
    if s and exp then
        local t
        for i = 1, #s do
            t = s[i]
            if t.e and t.e > exp then return i - 1 end
        end
        return #s
    end
    return 0
end
--[Comment]
--根据等级取得经验
function _nstt.GetExp(s, lv)
    s = s and s.tech
    if s and lv then
        s = s[lv > #s and #s or lv]
        return s and s.e or 0
    end
    return 0
end
--[Comment]
--根据等级取得值
local function GetVal(s, lv)
    s = s and s.tech
    if s and lv then
        s = s[lv > #s and #s or lv]
        return s and s.v or 0
    end
    return 0
end
--[Comment]
--根据等级取得科技描述
function _nstt.TechIntro(s, lv) return string.format(L(s.ti), GetVal(s, lv)) end

--[Comment]
--最大等级
function _nstt.MaxLv(s) return s.tech and table.maxn(s.tech) or 0 end
--[Comment]
--根据等级取得值
_nstt.GetVal = GetVal

--[Comment]
--Item接口(显示名称)
function _nstt.getName(s) return LN(s.nm) end
--[Comment]
--Item接口(显示信息)
function _nstt.getIntro(s) return L(s.i) end
--[Comment]
--ToolTip接口(显示名称和信息)
function _nstt.getPropTip(s, lv)
    lv = lv or s.lv
    return LN(s.nm), L("科技") .. ":" ..LN(s.tnm) ..(lv and lv > 0 and("\n" .. L("等级") .. ":" .. lv) or "") .. "\n" .. L("效果") .. ":" .. string.format(L(s.ti), lv > 0 and GetVal(lv) or "?")
end

--继承
objext(_nstt)
--[Comment]
--未定义的
_nstt.undef = _nstt()
--[Comment]
--国战州郡
--{sn=1,nm="司隶州",i="",tnm="荣耀加持",ti="xxxx%d%",tsn=1,tech={{e=7300,v=45}}
DB_NatState = _nstt