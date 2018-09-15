local rawget = rawget
local setmetatable = setmetatable
local BD_Const = QYBattle.BD_Const
local BD_AID = QYBattle.BD_AID
local iaid = BD_AID.Invalid

local function GetAtt(b, aid) return b.att[aid] or 0 end

--属性接口
local _get =
{
    --[Comment]
    --是否永久性BUF
    isEver = function(b) return b.lifeTime >= BD_Const.MAX_TIME end,
    --[Comment]
    --是否存活
    isAlive = function(b) return false end,

    --[Comment]
    --剩余时长(MS)
    leftTime = function(b) return b.lifeTime end,
    --[Comment]
    --剩余时间(S)
    leftSecond = function(b) return b.lifeTime * 0.001 end,
    --[Comment]
    --时间百分比
    timePercent = function(b) return 0 end,
    --[Comment]
    --叠加倍数
    multi = function(b) return b.replace end,

    --[Comment]
    --是否有无敌
    isGod = function(b) return GetAtt(b, BD_AID.God) > 0 end,
    --[Comment]
    --是否有停止
    isStop = function(b) return GetAtt(b, BD_AID.Stop) > 0 end,
    --[Comment]
    --是否有禁锢
    isFixed = function(b) return GetAtt(b, BD_AID.Fixed) > 0 end,
    --[Comment]
    --是否有恐惧
    isFear = function(b) return GetAtt(b, BD_AID.Fear) > 0 end,
    --[Comment]
    --是否有逼战
    isFF = function(b) return GetAtt(b, BD_AID.FF) > 0 end,
    --[Comment]
    --是否有致盲
    isBlind = function(b) return GetAtt(b, BD_AID.Blind) > 0 end,
    --[Comment]
    --是否有流血
    isBleed = function(b) return GetAtt(b, BD_AID.Bleed) > 0 end,
}

local _buf =
{
    --[Comment]
    --无敌 SN
    SN_God = 100001,
    --[Comment]
    --击晕 SN
    SN_Stun = 100002,
    --[Comment]
    --恐惧 SN
    SN_Fear = 100003,
    --[Comment]
    --致盲 SN
    SN_Blind = 100004,
    --[Comment]
    --流血 SN
    SN_Bleed = 100005,

    --[Comment]
    --当前SN
    sn = 0,
    --[Comment]
    --持续时间(MS)
    lifeTime = 0,
    --[Comment]
    --叠加次数
    replace = 1,

    --[Comment]
    --获取属性值
    GetAtt = GetAtt,
    --[Comment]
    --设置属性值
    SetAtt = function(b, aid, val) b.att[aid] = val end,
}
--[Comment]
--构造器
function _buf.__call(t, sn, time)
    return setmetatable({ sn = sn, lifeTime = time, replace = 1, priority = 0, att = { } }, _buf)
end
--[Comment]
--索引器
function _buf.__index(t, k)
    local v = rawget(_buf, k)
    if v == nil then
        v = rawget(_get, k)
        if v ~= nil then return v(t) end
    end
    return v
end

setmetatable(_buf, _buf)
--[Comment]
--BUF对象
QYBattle.BD_Buff = _buf

--[Comment]
--构造单属性BUF
function _buf.BD_BuffSingle(sn, lifeTime, aid, val)
    return setmetatable({ sn = sn, lifeTime = lifeTime, replace = 1, priority = 0, att = { [aid] = val } }, _buf)
end
--[Comment]
--构造双属性BUF
function _buf.BD_BuffDouble(sn, lifeTime, aid1, val1, aid2, val2)
    local t = setmetatable({ sn = sn, lifeTime = lifeTime, replace = 1, priority = 0, att = { [aid1] = val1, [aid2] = val2 } }, _buf)
    return t
end
--[Comment]
--构造三属性BUF
function _buf.BD_BuffTriple(sn, lifeTime, aid1, val1, aid2, val2, aid3, val3)
    return setmetatable({ sn = sn, lifeTime = lifeTime, replace = 1, priority = 0, att = { [aid1] = val1, [aid2] = val2, [aid3] = val3 } }, _buf)
end

--[Comment]
--短暂的无敌
_buf.BF_ShortGod = _buf.BD_BuffSingle(_buf.SN_God, 500, BD_AID.God, 1)
--[Comment]
--短暂的击晕
_buf.BF_ShortStop = _buf.BD_BuffSingle(_buf.SN_Stun, 500, BD_AID.Stop, 1)
--[Comment]
--1秒眩晕
_buf.BF_1SStop = _buf.BD_BuffSingle(_buf.SN_Stun, 500, BD_AID.Stop, 1)