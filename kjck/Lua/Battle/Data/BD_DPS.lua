
local rawget = rawget
local setmetatable = setmetatable
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

local _type =
{
    --[Comment]
    --武力
    Strength = 1,
    --[Comment]
    --技能
    Skill = 2,
    --[Comment]
    --治疗
    Cure = 4,
    --[Comment]
    --真实伤害
    Real = 8,
}
local _tag =
{
    --[Comment]
    --无
    None = 0,
    --[Comment]
    --未命中
    Miss = 1,
    --[Comment]
    --闪避
    Dodge = 2,
    --[Comment]
    --暴击
    Crit = 4,
    --[Comment]
    --Buff
    Buff = 8,
    --[Comment]
    --格挡
    Block = 16,
}

--[Comment]
--属性器
local _get =
{
    --[Comment]
    --未命中
    isMiss = function(d) return band(d.tag, _tag.Miss) == _tag.Miss end,
    --[Comment]
    --可被闪避/已经被闪避
    dodge = function(d) return band(d.tag, _tag.Dodge) == _tag.Dodge end,
    --[Comment]
    --暴击
    isCrit = function(d) return band(d.tag, _tag.Crit) == _tag.Crit end,
    --[Comment]
    --是Buff
    isBuff = function(d) return band(d.tag, _tag.Buff) == _tag.Buff end,
    --[Comment]
    --是否被挡格了
    isBlock = function(d) return band(d.tag, _tag.Block) == _tag.Block end,
    --[Comment]
    --是否是纯治疗
    isCure = function(d) return d.type == _type.Cure end,
}

local _dps =
{
    Type = _type,
    Tag = _tag,
}

--[Comment]
--构造器
function _dps.__call(t, u, typ, v, tag)
    return setmetatable({ source = u, type = typ, value = v or 0, tag = tag or _tag.None, puncture = 0 }, _dps)
end
--[Comment]
--索引器
function _dps.__index(t, k)
    local v = rawget(_dps, k)
    if v == nil then
        v = rawget(_get, k)
        if v ~= nil then return v(t) end
    end
    return v
end

--[Comment]
--输出类型是否在给定的类型中
function _dps.CheckType(d, typ) return band(d.type, typ) ~= 0  end
--[Comment]
--添加标签
function _dps.AddTag(d, tag) d.tag = bor(d.tag, tag) end
--[Comment]
--添加标签
function _dps.AddTags(d, ...) d.tag = bor(d.tag, ...) end
--[Comment]
--移除标签
function _dps.RemoveTag(d, tag) d.tag = band(d.tag, bnot(tag)) end
--[Comment]
--是否包含给定的标签中的任意一个
function _dps.ContainsAnyTag(d, ...) return band(d.tag, bor(...)) ~= _tag.None  end
--[Comment]
--是否包含给定的全部标签
--function _bufs.ContainsAllTag(d, ...) local tag = bor(...); return band(d.tag, tag) == tag end

setmetatable(_dps, _dps)
--[Comment]
--输出
QYBattle.BD_DPS = _dps