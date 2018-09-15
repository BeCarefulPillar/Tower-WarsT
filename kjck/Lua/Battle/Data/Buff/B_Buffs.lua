local getmetatable = getmetatable
local rawget = rawget
local ipairs = ipairs
local pairs = pairs
local insert = table.insert
local sort = table.sort

local BD_AID = QYBattle.BD_AID
local BD_DPS = QYBattle.BD_DPS
local BD_Buff = QYBattle.BD_Buff
local BD_BuffSlot = QYBattle.BD_BuffSlot

local _bufs = { }

--[Comment]
--更新指定AID的属性值
local function UpdateAtt(b, aid)
    local v = 0
    b._change[aid] = false
    for _, s in ipairs(b) do
        if s.isAlive then
            v = v + s:GetAtt(aid)
        end
    end
    b._att[aid] = v ~= 0 and v or nil
end
--[Comment]
--获取指定AID的属性值
local function GetAtt(b, aid)
    if b._change[aid] then UpdateAtt(b, aid) end
    return b._att[aid] or 0
end

--[Comment]
--排序函数
local function SortBuff(x, y) return x._buff.priority > y._buff.priority end

--[Comment]
--属性器
local _get =
{
    --[Comment]
    --拥有BD_BuffSlot数量
    Count = function(b) return #b end,

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
    --是否沉默
    isSilence = function(b) return GetAtt(b, BD_AID.Silence) > 0 end,
    --[Comment]
    --是否控制免疫
    isResControl = function(b) return GetAtt(b, BD_AID.ResControl) > 0 end,
}
--[Comment]
--构造器
function _bufs.__call(t, u)
    assert(u and QYBattle.BD_CombatUnit.is(u, QYBattle.BD_CombatUnit), "create B_Buffs need BD_CombatUnit")
    return setmetatable({ unit = u, map = u.map, _change = { }, _att = { } }, _bufs)
end
--[Comment]
--索引器
function _bufs.__index(t, k)
    local v = rawget(_bufs, k)
    if v == nil then
        v = rawget(_get, k)
        if v ~= nil then return v(t) end
    end
    return v
end

--[Comment]
--循环更新
function _bufs.Update(b)
    local dmg, sdmg, cure, energy = 0, 0, 0, 0
    local dt = b.map.deltaMillisecond
    for _, s in ipairs(b) do
        dmg, sdmg, cure, energy = s:Update(dt, dmg, sdmg, cure, energy)
    end
    local u = b.unit
    if cure > 0 then u:SufferDPS(BD_DPS(u.belong, BD_DPS.Type.Cure, cure, BD_DPS.Tag.Buff)) end
    if dmg > 0 then u:SufferDPS(BD_DPS(u.belong.rival, BD_DPS.Type.Strength, dmg, BD_DPS.Tag.Buff)) end
    if sdmg > 0 then u:SufferDPS(BD_DPS(u.belong.rival, BD_DPS.Type.Skill, sdmg, BD_DPS.Tag.Buff)) end
    if energy > 0 then u:SufferEnergy(energy) end
end
--[Comment]
--添加一个BUF
--buf : BD_Buff
--return : BD_BuffSlot
function _bufs.AddBuff(b, buf)
    assert(buf and getmetatable(buf) == BD_Buff, "BD_Buffs:AddBuff(buf) the arg[buf] must be a BD_Buff")
    local var = 0
    for i, s in ipairs(b) do
        if s.sn == buf.sn then
            s:Replace(buf)
            return s
        elseif var < 1 and s.isDead then
            var = i
        end
    end
    if var < 1 then
        var = BD_BuffSlot(b, buf)
        insert(b, var)
        if var._buff.priority > 0 then sort(b, SortBuff) end
    else
        var = b[var]
        local st = var._buff.priority > 0
        var:Replace(buf)
        if st or buf.priority > 0 then sort(b, SortBuff) end
    end
    return var
end
--[Comment]
--重置指定SN的BD_BuffSlot
--sn : buff sn
--return : 是否重置成功
function _bufs.ResetBuff(b, sn)
    for _, s in ipairs(b) do
        if s.sn == sn then
            s:Reset()
            return true
        end
    end
    return false
end

--[Comment]
--通过索引取Buf
--idx : buf 所在位置
--return:BD_BuffSlot
function _bufs.GetBuffByIdx(b, idx)
    b = b[idx]
    return b and b.isAlive and b or nil
end
--[Comment]
--通过buf sn取Buf
--sn : buf sn
--return:BD_BuffSlot
function _bufs.GetBuff(b, sn)
    for _, s in ipairs(b) do
        if s.sn == sn then
            return s.isAlive and s or nil
        end
    end
    return nil
end
--[Comment]
--是否有指定buf sn的buf存在
--sn : buf sn
--return : boolean
function _bufs.Contains(b, sn)
    for _, s in ipairs(b) do
        if s.sn == sn then
            return not s.isDead
        end
    end
    return false
end
--[Comment]
--移除指定buf sn的Buf
--sn : buf sn
function _bufs.Remove(b, sn)
    for _, s in ipairs(b) do
        if s.sn == sn then
            s:Dead()
            return
        end
    end
end
--[Comment]
--更新指定AID的属性值
_bufs.UpdateAtt = UpdateAtt
--[Comment]
--获取指定AID的属性值
_bufs.GetAtt = GetAtt
--[Comment]
--清理所有Buf
function _bufs.Clear(b)
    for i = 1, #b do b[i] = nil end
    b._att = { }
    b._change = { }
end
--[Comment]
--标记指定BD_BuffSlot已变更
--buf : BD_BuffSlot
function _bufs.MarkAsChanged(b, buf)
    assert(buf and getmetatable(buf) == BD_BuffSlot, "BD_Buffs:MarkAsChanged(buf) the arg[buf] must be a BD_BuffSlot")
    for aid, v in pairs(buf._buff.att) do
        if v ~= 0 then
            if not b._change[aid] then
                b._change[aid] = true
                if BD_AID.ResControl == aid then
                    for _, s in ipairs(b) do
                        if s ~= buf and not s.isDead then
                            _bufs:MarkAsChanged(s)
                        end
                    end
                end
            end
            b.unit:MarkAttChanged(aid)
        end
    end
end

setmetatable(_bufs, _bufs)
--[Comment]
--BUF管理
QYBattle.B_Buffs = _bufs