
local rawget = rawget
local rawset = rawset
local getmetatable = getmetatable
local setmetatable = setmetatable

local QYBattle = QYBattle
local B_Math = QYBattle.B_Math
local BD_Buff = QYBattle.BD_Buff
local BD_AID = QYBattle.BD_AID

local function IsAlive(b) return b._passTime.value < b._buff.lifeTime and not b._sleep end

local function MarkAsChanged(b) b._buffs:MarkAsChanged(b) end

--[Comment]
--属性器-读
local _get =
{
    --[Comment]
    --SN
    sn = function(b) return b._buff.sn end,
    --[Comment]
    --持续时间(MS)
    lifeTime = function(b) return b._buff.lifeTime end,
    --[Comment]
    --优先级
    priority = function(b) return b._buff.priority end,
    --[Comment]
    --已过时间(MS)
    passTime = function(b) return b._passTime.value end,
    --[Comment]
    --叠加倍数
    multi = function(b) return b._multi.value end,
    --[Comment]
    --当前护盾值
    shield = function(b) return b._buff:GetAtt(BD_AID.Shield) - b._shield.value end,
    --[Comment]
    --是否存活
    isAlive = IsAlive,
    --[Comment]
    --是否死亡
    isDead = function(b) return b._passTime.value >= b._buff.lifeTime end,
    --[Comment]
    --是否永久BUF
    isEver = function(b) return b._buff.isEver end,
    --[Comment]
    --是否休眠
    isSleep = function(b) return b._sleep end,

    --[Comment]
    --剩余时间(MS)
    leftTime = function(b) return b._buff.lifeTime - b._passTime.value end,
    --[Comment]
    --剩余时间(S)
    leftSecond = function(b) return (b._buff.lifeTime - b._passTime.value) * 0.001 end,
    --[Comment]
    --已过时间百分百
    timePercent = function(b) return b._buff.isEver and 0 or b._passTime.value / b._buff.lifeTime end,


    --[Comment]
    --是否有无敌
    isGod = function(b) return b._buff.isGod end,
    --[Comment]
    --是否有停止
    isStop = function(b) return b._buff.isStop end,
    --[Comment]
    --是否有禁锢
    isFixed = function(b) return b._buff.isFixed end,
    --[Comment]
    --是否有恐惧
    isFear = function(b) return b._buff.isFear end,
    --[Comment]
    --是否有逼战
    isFF = function(b) return b._buff.isFF end,
    --[Comment]
    --是否有致盲
    isBlind = function(b) return b._buff.isBlind end,
    --[Comment]
    --是否有流血
    isBleed = function(b) return b._buff.isBleed end,
}
--[Comment]
--属性器-写
local _set =
{
    --[Comment]
    --是否休眠
    isSleep = function(b, v)
        v = v and true or false
        if v == b._sleep then return end
        if IsAlive(b) then
            b._sleep = v
            MarkAsChanged(b)
        else
            b._sleep = v
        end
    end,
    --[Comment]
    --已过时间
    passTime = function(b, v)
        local alive = IsAlive(b)
        b._passTime.value = B_Math.max(0, v)
        if alive == IsAlive(b) then return end
        MarkAsChanged(b)
    end,
    --[Comment]
    --叠加次数
    multi = function(b, v)
        v = B_Math.clamp(v, 1, b._buff.replace)
        if b._multi.value == v then return end
        if IsAlive(b) then
            b._multi.value = v
            MarkAsChanged(b)
        else
            b._multi.value = v
        end
    end,
}
--[Comment]
--BUF槽位
local _slot = { }
--[Comment]
--构造器
function _slot.__call(t, buffs, buff)
    assert(buffs and getmetatable(buffs) == QYBattle.B_Buffs, "create BD_BuffSlot the B_Buffs can not be nil")
    assert(buff and getmetatable(buff) == BD_Buff, "create BD_BuffSlot the BD_Buff can not be nil")
    local EnInt = buffs.map.battle.EnInt
    t = setmetatable({
        _buffs = buffs,
        _buff = buff,
        _secDiff = 0,
        _shield = EnInt(),
        _passTime = EnInt(),
        _multi = EnInt(),
        _sleep = false,
    }, _slot)

    MarkAsChanged(t)
    return t
end
--[Comment]
--索引器
function _slot.__index(t, k)
    local v = rawget(_slot, k)
    if v == nil then
        v = rawget(_get, k)
        if v ~= nil then return v(t) end
    end
    return v
end
--[Comment]
--索引写入器
function _slot.__newindex(t, k, v)
    local set = rawget(_set, k)
    if set then return set(t, v) end
    assert(rawget(_get, k) == nil, "BD_BuffSlot not implement set ["..k.."]")
    rawset(t, k, v)
end

--[Comment]
--替换
function _slot.Replace(b, buf)
    assert(buf and getmetatable(buf) == BD_Buff, "BD_BuffSlot.Replace the BD_Buff can not be nil")
    local pt, mt = b._passTime, b._multi
    if b._sleep then
        b._buff = buf
        if pt.value < buf.lifeTime and mt.value < buf.replace then
            mt.value = mt.value + 1
        else
            mt.value = 1
        end
        b._secDiff = 0
        b._shield.value = 0
        pt.value = 0
    elseif b._buff.sn == buf.sn then
        if pt.value < b._buff.lifeTime then
            b._shield.value = 0
            pt.value = 0
            if buf == b._buff then
                if mt.value < buf.replace then
                    mt.value = mt.value + 1
                    MarkAsChanged(b)
                end
            else
                b._buff = buf
                if mt.value < buf.replace then
                    mt.value = mt.value + 1
                end
                MarkAsChanged(b)
            end
        else
            b._buff = buf
            b._secDiff = 0
            b._shield.value = 0
            pt.value = 0
            mt.value = 0
            MarkAsChanged(b)
        end
    else
        MarkAsChanged(b)
        b._buff = buf
        b._secDiff = 0
        b._shield.value = 0
        pt.value = 0
        mt.value = 0
        MarkAsChanged(b)
    end
end
--[Comment]
--重置
function _slot.Reset(b)
    if b._sleep or b._passTime.value < b._buff.lifeTime then
        --b._secDiff = b._passTime.value % 1000
        b._passTime.value = 0
    else
        b._secDiff = 0
        b._shield.value = 0
        b._passTime.value = 0
        MarkAsChanged(b)
    end
end
--[Comment]
--消亡
function _slot.Dead(b)
    if b._passTime.value < b._buff.lifeTime then
        b._secDiff = 0
        b._shield.value = 0
        b._passTime.value = b._buff.lifeTime
        MarkAsChanged(b)
    end
end
--[Comment]
--循环更新
function _slot.Update(b, dt, dmg, sdmg, cure, energy)
    if b._sleep then return dmg, sdmg, cure, energy end
    local pt, bf = b._passTime, b._buff
    if pt.value < bf.lifeTime then
        pt.value = pt.value + dt
        local sd = b._secDiff + dt
        if sd >= 1000 then
            sd = sd - 1000
            local mt = b._multi.value
            if mt > 1 then
                dmg = dmg + bf:GetAtt(BD_AID.Dmg) * mt
                sdmg = sdmg + bf:GetAtt(BD_AID.SDmg) * mt
                cure = cure + bf:GetAtt(BD_AID.Cure) * mt
                energy = cure + bf:GetAtt(BD_AID.Energy) * mt
            else
                dmg = dmg + bf:GetAtt(BD_AID.Dmg)
                sdmg = sdmg + bf:GetAtt(BD_AID.SDmg)
                cure = cure + bf:GetAtt(BD_AID.Cure)
                energy = cure + bf:GetAtt(BD_AID.Energy)
            end
        end
        b._secDiff = sd
        if pt.value < bf.lifeTime then return dmg, sdmg, cure, energy end
        MarkAsChanged(b)
    end
    return dmg, sdmg, cure, energy
end
--[Comment]
--获取给定属性ID的当前值
function _slot.GetAtt(b, aid)
    local v = b._buff:GetAtt(aid)
    if v ~= 0 then
        if (BD_AID.IsControlAid(aid) or (BD_AID.MoveSpeed == aid and v < 0)) and b._buffs.isResControl then
            return 0
        end
        local mt = b._multi.value
        if mt > 1 then v = v * mt end
        return BD_AID.Shield == aid and v - b._shield.value or v
    end
    return 0
end
--[Comment]
--护盾改变
--v : 改变值
--return : 改变值的剩余量
function _slot.ShieldChange(b, v)
    if v ~= 0 and IsAlive(b) then
        local max = b._buff:GetAtt(BD_AID.Shield)
        if max > 0 then
            local cur = b._shield.value
            if v < 0 then
                --减少护盾值，无法超过护盾上限
                local mt = b._multi.value
                if mt > 1 then max = max * mt end
                if cur < max then
                    if cur - v < max then
                        b._shield.value = cur - v
                        v = 0
                    else
                        b._shield.value = max
                        v = v + max - cur
                    end
                    MarkAsChanged(b)
                end
            elseif cur > 0 then
                --增加护盾值，无法超过护盾上限
                if cur > v then
                    b._shield.value = cur - v
                    v = 0
                else
                    b._shield.value = 0
                    v = v - cur
                end
            end
        end
    end
    return v
end
--[Comment]
--是否护盾耗尽
function _slot.IsShieldEmpty(b) return b._shield.value >= b._buff:GetAtt(BD_AID.Shield) end


--[Comment]
--标记已变更
_slot.MarkAsChanged = MarkAsChanged

setmetatable(_slot, _slot)
--[Comment]
--BUF槽位
QYBattle.BD_BuffSlot = _slot