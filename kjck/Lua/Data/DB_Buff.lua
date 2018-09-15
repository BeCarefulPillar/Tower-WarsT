local _buff =
{
    --buff编号
    sn = 0,
    --buff名字
    nm = nil,
    --buff说明
    i = "",
    --对应的属性ID
    aid = 0,
    --种类[0=双向正常，1=双向相反，2=增益，3=减益]
    kind = 0,
}

--[Comment]
--是否是负面效果BUFF
local function IsDebuff(b, dbf, v)
    if b then
        b = dbf.kind
        --1=双向相反
        if b == 1 then return v and v > 0 end
        --增益
        if b == 2 then return false end
        --减益
        if b == 3 then return true end
    end
    --双向正常
    return v and v < 0
end
--[Comment]
--根据值获取说明
local function GetIntro(b, v) return string.format(L(b.i), v and(b.aid == 34 and v < 0 and - v or v) or 0) or "" end
--[Comment]
--是否是负面效果BUFF
_buff.IsDebuff = IsDebuff
--[Comment]
--根据值获取说明(带颜色编码)
function _buff.GetIntroWithColor(b, v) return IsDebuff(b, v) and ColorStyle.Bad(GetIntro(v)) or ColorStyle.Good(GetIntro(v)) end

--[Comment]
--Item接口(显示名称)
function _buff.getName(b) return LN(b.nm) end
--[Comment]
--Item接口(显示信息)，可给入值
_buff.getIntro = GetIntro
--[Comment]
--ToolTip接口(显示名称和信息)
function _buff.getPropTip(b) return LN(b.nm), L("说明") .. ":" .. GetIntro(b.i, 0) end

--继承
objext(_buff)
--[Comment]
--未定义的
_buff.undef = _buff()
--[Comment]
--出战BUFF
--[26]={sn=26,nm="免控",i="无法被眩晕、减速、压制、禁锢",kind=2,aid=36}
DB_Buff = _buff