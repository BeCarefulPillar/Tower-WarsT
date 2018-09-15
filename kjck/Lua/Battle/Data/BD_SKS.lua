
local rawget = rawget
local rawget = rawget
local getmetatable = getmetatable

local B_Math = QYBattle.B_Math
local BD_Const = QYBattle.BD_Const
local BD_AID = QYBattle.BD_AID
local EnSks = QYBattle.EnSks
local SKD_COND = QYBattle.BD_SKD_COND
local BD_DPS = QYBattle.BD_DPS
local BD_Buff = QYBattle.BD_Buff
local BD_Soldier = QYBattle.BD_Soldier

local _base = QYBattle.BD_Unit

local _sks = { }

--所属武将
--BD_Hero hero
 --天机技能数据
--EnSks[] skill
--当前触发的条件
--t_cond
--当前触发的是否我方
--t_isMe
--当前触发的数据
--t_dat
--下次触发时间事件的时间
--nextTimeCond
--技能数量
--skillQty

--[Comment]
--技能数据获取
function _sks.GetSkill(s, idx) return s.skill[idx] end

local function CheckNextTimeCond(s)
    local tm = 2147483647
    if s.skill then
        for _, d in ipairs(s.skill) do
            if d.active and d:GetCond(1) == SKD_COND.T_Time then
                tm = B_Math.min(tm, d:GetCond(2))
            end
        end
    end
    if tm > s.map.time or s.map.time < 50 then
        s.nextTimeCond = tm
    else
        s.nextTimeCond = s.map.time + 1000
    end
end

--触发技能
--dat:EnSks
local function TriggerSkill(s, isMe, cond, dat)
    s.t_isMe = isMe
    s.t_cond = cond
    s.t_dat = dat
    local func
    for _, d in ipairs(s.skill) do
        if s.skill.active and cond == d:GetCond(1) or cond == d:GetCond2(1) then
            func = rawget(_sks, d.sn.value)
            if func then func(s, d) end
        end
    end
end

--触发技能
function _sks.Trigger(s, isMe, etyp, dat) if s.skill then TriggerSkill(s, isMe, etyp, dat) end end

function _sks.Update(s)
    if s.skill then
        if s.nextTimeCond < s.map.time then
            TriggerSkill(true, SKD_COND.T_Time)
            CheckNextTimeCond(s)
        end
        for _, d in ipairs(s.skill) do
            if d.action then d.action(s, d) end
        end
    end
end

--构造
--hero : BD_Hero
--dat : S_SKS数组
local function _ctor(t, hero, dat)
    t = setmetatable(_base(hero.map), _sks)
    t.hero = hero
    t.isAtk = hero.isAtk
    t.skill = EnSks.FromArray(dat, hero.battle.EnInt)
    t.nextTimeCond = 0

    t.t_curCond = 0
    t.t_isMe = false

    if t.skill then
        t.skillQty = #t.skill
        CheckNextTimeCond(t)
    else
        t.skillQty = 0
    end

    return t
end
--继承扩展
_base:extend(_ctor, nil, nil, _sks)
--[Comment]
--战场天机技
QYBattle.BD_SKS = _sks

local function HeroHpPercent(s) return s.hero.HP * 100 / s.hero.MaxHP end
local function HeroSpPercent(s) return s.hero.SP * 100 / s.hero.MaxSP end

--dat:EnSks
local function CheckDpsCond(s, dat)
    local dps = s.t_dat
    if dps and getmetatable(dps) == BD_DPS then
        if dps:ContainsAnyTag(BD_DPS.Tag.Miss, BD_DPS.Tag.Dodge, BD_DPS.Tag.Buff) then return false end
        return dps:CheckType(dat:GetCond(2))
    end
    return false
end
--dat:EnSks
local function CheckHeroDpsCond(s, dat)
    local dps = s.t_dat
    if dps and getmetatable(dps) == BD_DPS then
        if dps:ContainsAnyTag(BD_DPS.Tag.Miss, BD_DPS.Tag.Dodge, BD_DPS.Tag.Buff) then return false end
        return dps.source == s.hero.rival and dps:CheckType(dat:GetCond(2))
    end
    return false
end
--dat:EnSks
local function CheckRivalDpsCond(s, dat)
    local dps = s.t_dat
    if dps and getmetatable(dps) == BD_DPS then
        if dps:ContainsAnyTag(BD_DPS.Tag.Miss, BD_DPS.Tag.Dodge, BD_DPS.Tag.Buff) then return false end
        return dps.source == s.hero and dps:CheckType(dat:GetCond(2))
    end
    return false
end

--地魁星
_sks[30] = function(s, dat)
    --我方技力低于指定值
    if s.t_isMe then
        if HeroSpPercent(s)  < dat:GetCond(2) then
            if dat.buff == nil then
                dat.buff = BD_Buff.BD_BuffSingle(30300, BD_Const.MAX_TIME, BD_AID.SSD, dat:GetVal(1))
                s.hero.rival:AddBuff(dat.buff)
            else
                local slot = s.hero.rival:GetBuff(30300)
                if slot then slot.isSleep = false end
            end
        elseif dat.buff then
            local slot = s.hero.rival:GetBuff(30300)
            if slot then slot.isSleep = true end
        end
    end
end
--地煞星
_sks[31] = function(s, dat)
    if s.map.time < dat:GetCond(2) then return end
    dat.active = false
    dat.buff = BD_Buff.BD_BuffSingle(30310, dat:GetValMS(2), BD_AID.SSD, -dat:GetVal(1))
    s.hero:AddBuff(dat.buff)
end
--地杰星
_sks[32] = function(s, dat)
    if s.map.time < dat:GetCond(2) then return end
    dat.active = false
    dat.buff = BD_Buff.BD_BuffSingle(30320, dat:GetValMS(2), BD_AID.SCrit, dat:GetVal(1))
    s.hero:AddBuff(dat.buff)
end
--地奇星
_sks[33] = function(s, dat)
    if s.map.time < dat:GetCond(2) then return end
    dat.active = false
    s.hero:AddExtBonus(3, dat:GetVal(1))
end
--地猛星
_sks[34] = function(s, dat)
    if s.map.time < dat:GetCond(2) then return end
    dat.active = false
    s.hero:AddExtBonus(1, dat:GetVal(1))
end
--地英星
_sks[35] = function(s, dat)
    --我方生命高于指定值
    if s.t_isMe then
        if HeroHpPercent(s)  < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30350)
                if slot then slot.isSleep = true end
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30350)
            if slot then slot.isSleep = false end
        else
            dat.buff = BD_Buff.BD_BuffSingle(30350, BD_Const.MAX_TIME, BD_AID.CSD, dat:GetVal(1))
            s.hero:AddBuff(dat.buff)
        end
    end
end
--地雄星
_sks[36] = function(s, dat)
    if s.t_isMe then
        local tp = s.hero.TP
        if dat.vals then
            if tp < dat.vals[1] then
                dat.active = false
                s.hero:RemoveBuff(30360)
            else
                dat.vals[1] = tp
            end
        elseif tp > 0 then
            dat.vals = { tp }
            dat.buff = BD_Buff.BD_BuffSingle(30360, BD_Const.MAX_TIME, BD_AID.Morale, dat:GetVal(1))
            s.hero:AddBuff(dat.buff)
        else
            dat.active = false
        end
    end
end
--地威星
local function SKS_37(s, dat)
    dat = dat.vals
    local map = s.map
    if map.time < dat[1] then return end
    dat[1] = map.time + dat[2]
    local hero = s.hero
    if hero.RealTP < dat[3] then
        local qty = dat[4]
        local isAtk = hero.isAtk
        local x = isAtk and 0 or map.width - 1
        local dx = isAtk and 1 or -1
        local y1 = hero.y
        local y2 = y1 + 1
        local dy = true
        local cy

        while qty > 0 and (isAtk and x < map.width or x > 0) do
            if dy then
                y1 = y1 - 1
                cy = y1
            else
                y2 = y2 + 1
                cy = y2
            end
            dy = not dy
            if qty > 0 and map:PosAvailableAndEmpty(x, cy) then
                qty = qty - 1
                local unit = BD_Soldier(map, x, cy)
                unit:InitData(hero)
            end
            if qty <=0 then break end
            if y1 < 1 and y2 >= map.height - 1 then
                x = x + dx
                y1 = hero.y
                y2 = y1 + 1
            end
        end
        hero:SetTP(dat[4] - B_Math.max(0, qty))
    else
        dat.action = nil
    end
end
_sks[37] = function(s, dat)
    if s.t_isMe then
        if s.hero.RealTP < dat:GetCond(2) then
            if dat.vals == nil then dat.vals = { s.map.time + dat:GetValMS(2), dat:GetValMS(2), dat:GetCond(2), dat:GetVal(1) } end
            if dat.action == nil then dat.action = SKS_37 end
        elseif dat.action then
            dat.action = nil
        end
    end
end
--地佑星
_sks[38] = function(s, dat)
    if s.t_isMe and s.hero.RealTP < dat:GetCond(2) then
        dat.active = false
        dat.buff = BD_Buff.BD_BuffSingle(30380, BD_Const.MAX_TIME, BD_AID.SSD, -dat:GetVal(1))
        s.hero:AddBuff(dat.buff)
        s.hero:AddExtBonus(1, dat:GetVal(2))
    end
end
--地文星
_sks[39] = function(s, dat)
    if s.t_isMe and CheckHeroDpsCond(s, dat) then
        if HeroHpPercent(s) < dat:GetCond(3) then return end
        if dat.buff == nil then
            dat.buff = BD_Buff.BD_BuffSingle(30390, dat:GetValMS(2), BD_AID.SSD, dat:GetVal(1))
        end
        s.hero.rival:AddBuff(dat.buf)
    end
end
--地暗星
_sks[40] = function(s, dat)
    if s.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.vals == nil then dat.vals = { 0 } end
            if dat.vals[1] == 0 then
                dat.vals[1] = dat:GetVal(1)
                s.hero:AddExtBonus(1, dat.vals[1])
            end
        elseif dat.vals and dat.vals[1] ~= 0 then
            s.hero:AddExtBonus(1, -dat.vals[1])
            dat.vals[1] = 0
        end
    end
end
--地灵星
_sks[41] = function(s, dat)
    if s.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            s.hero:CureDPS(s.hero, dat:GetVal(1))
        end
    end
end
--地会星
_sks[42] = function(s, dat)
    if s.t_isMe and CheckDpsCond(s, dat) then
        if dat.buff == nil then
            dat.buff = BD_Buff.BD_BuffDouble(30420, dat:GetValMS(2), BD_AID.CPD, -dat:GetVal(1), BD_AID.CSD, -dat:GetVal(1))
        end
        s.hero.rival:AddBuff(dat.buff)
    end
end
--地微星
_sks[43] = function(s, dat)
    if s.t_isMe and CheckDpsCond(s, dat) then
        if dat.buff == nil then
            dat.buff = BD_Buff.BD_BuffSingle(30430, dat:GetValMS(2), BD_AID.Str, dat:GetVal(1))
        end
        s.hero:AddBuff(dat.buff)
    end
end
--天魁星
_sks[44] = function(s, dat)
    if s.t_isMe then return end
    dat.active = false
    s.hero:SufferEnergy(dat:GetVal(1))
end
--天雄星
_sks[45] = function(s, dat)
    if s.t_isMe then return end
    local rtp = s.hero.rival.TP
    if dat.vals == nil then
        dat.vals = { rtp, 0 }
        return
    end
    local vals = dat.vals
    if rtp < vals[1] then
        local dt = vals[1] - rtp
        local rep = dat.rep.value
        vals[2] = vals[2] + dt
        if vals[2] >= rep then
            dat.active = false
            dt = dt - (vals[2] - rep)
            vals[2] = rep
        end
        if dt > 0 then
            s.hero:AddExtBonus(1, dat:GetVal(1) * dt)
        end
    end
    vals[1] = rtp
end
--天闲星
_sks[46] = function(s, dat)
    if s.t_isMe then return end
    local rtp = s.hero.rival.TP
    if dat.vals == nil then
        dat.vals = { rtp, 0 }
        return
    end
    local vals = dat.vals
    if rtp < vals[1] then
        local dt = vals[1] - rtp
        local rep = dat.rep.value
        vals[2] = vals[2] + dt
        if vals[2] >= rep then
            dat.active = false
            dt = dt - (vals[2] - rep)
            vals[2] = rep
        end
        if dt > 0 then
            s.hero:AddExtBonus(2, dat:GetVal(1) * dt)
        end
    end
    vals[1] = rtp
end
--天英星
_sks[47] = function(s, dat)
    if s.t_isMe then return end
    local rtp = s.hero.rival.TP
    if dat.vals == nil then
        dat.vals = { rtp, 0 }
        return
    end
    local vals = dat.vals
    if rtp < vals[1] then
        local dt = vals[1] - rtp
        local rep = dat.rep.value
        vals[2] = vals[2] + dt
        if vals[2] >= rep then
            dat.active = false
            dt = dt - (vals[2] - rep)
            vals[2] = rep
        end
        if dt > 0 then
            s.hero:AddExtBonus(3, dat:GetVal(1) * dt)
        end
    end
    vals[1] = rtp
end
--天威星
_sks[48] = function(s, dat)
    if s.t_isMe and CheckHeroDpsCond(s, dat) then
        if dat.vals == nil then dat.vals = { 0 } end
        if dat.vals[1] < dat.rep.value then
            dat.vals[1] = dat.vals[1] + 1
            s.hero.rival:AddExtBonus(2, -dat:GetVal(1))
        else
            dat.active = false
        end
    end
end
--天猛星
_sks[49] = function(s, dat)
    if s.t_isMe and CheckHeroDpsCond(s, dat) then
        if dat.vals == nil then dat.vals = { 0 } end
        if dat.vals[1] < dat.rep.value then
            dat.vals[1] = dat.vals[1] + 1
            s.hero.rival:AddExtBonus(1, -dat:GetVal(1))
        else
            dat.active = false
        end
    end
end
--天贵星
_sks[50] = function(s, dat)
    if s.t_isMe then return end
    if CheckRivalDpsCond(s, dat) then
        if dat.buff == nil then
            dat.buff = BD_Buff.BD_BuffSingle(30500, dat:GetValMS(2), BD_Att.SSD, data.GetVal(1))
            dat.buff.replace = dat.rep.value
        end
        s.hero.rival:AddBuff(dat.buff)
    end
end
--天伤星
_sks[51] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff == nil then
                dat.buff = BD_Buff.BD_BuffDouble(30510, BD_Const.MAX_TIME, BD_AID.CPD, dat:GetVal(1), BD_AID.CSD, dat:GetVal(1))
                s.hero:AddBuff(dat.buff)
            else
                local slot = s.hero:GetBuff(30510)
                if slot then slot.isSleep = false end
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30510)
            if slot then slot.isSleep = true end
        end
    end
end
--天满星
_sks[52] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff == nil then
                dat.buff = BD_Buff.BD_BuffSingle(30520, BD_Const.MAX_TIME, BD_AID.Morale, dat:GetVal(1))
                s.hero:AddBuff(dat.buff)
            else
                local slot = s.hero:GetBuff(30520)
                if slot then slot.isSleep = false end
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30520)
            if slot then slot.isSleep = true end
        end
    end
end
--天罪星
_sks[53] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30530)
                if slot then slot.isSleep = true end
            end
        elseif dat.t_cond == SKD_COND.T_DPS then
            if CheckHeroDpsCond(s, dat) then
                s.hero.rival:AddBuff(BD_Buff.BD_BuffSingle(30531, dat:GetValMS(3), BD_AID.SDmg, B_Math.ceil(s.hero.Wis * dat:GetVal(2) * 0.01)))
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30530)
            if slot then slot.isSleep = false end
        else
            dat.buff = BD_Buff.BD_BuffDouble(30531, BD_Const.MAX_TIME, BD_AID.SPD, -dat:GetVal(1), BD_AID.SSD, -dat:GetVal(1))
            s.hero:AddBuff(dat.buff)
        end
    end
end
--天牢星
_sks[54] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30540)
                if slot then slot.isSleep = true end
            end
        elseif dat.t_cond == SKD_COND.T_DPS then
            if CheckHeroDpsCond(s, dat) then
                s.hero.rival:AddBuff(BD_Buff.BD_BuffSingle(30541, dat:GetValMS(3), BD_AID.SDmg, dat:GetVal(2)))
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30540)
            if slot then slot.isSleep = false end
        else
            dat.buff = BD_Buff.BD_BuffDouble(30540, BD_Const.MAX_TIME, BD_AID.SPD, -dat:GetVal(1), BD_AID.SSD, -dat:GetVal(1))
            s.hero:AddBuff(dat.buff)
        end
    end
end
--天机星
_sks[55] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30550)
                if slot then slot.isSleep = false end
            else
                dat.buff = BD_Buff.BD_BuffDouble(30550, BD_Const.MAX_TIME, BD_AID.SSD, -dat:GetVal(1), BD_AID.CD, dat:GetVal(2))
                s.hero:AddBuff(dat.buff)
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30550)
            if slot then slot.isSleep = true end
        end
    end
end
--天富星
_sks[56] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero.rival:GetBuff(30560)
                if slot then slot.isSleep = true end
            end
        elseif dat.buff then
            local slot = s.hero.rival:GetBuff(30560)
            if slot then slot.isSleep = false end
        else
            dat.buff = BD_Buff.BD_BuffDouble(30560, BD_Const.MAX_TIME, BD_AID.CPD, -dat:GetVal(1), BD_AID.CSD, -dat:GetVal(1))
            s.hero.rival:AddBuff(dat.buff)
        end
    end
end
--天孤星
_sks[57] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero.rival:GetBuff(30570)
                if slot then slot.isSleep = true end
            end
        elseif dat.buff then
            local slot = s.hero.rival:GetBuff(30570)
            if slot then slot.isSleep = false end
        else
            dat.buff = BD_Buff.BD_BuffTriple(30570, BD_Const.MAX_TIME, BD_AID.CPD, -dat:GetVal(1), BD_AID.CSD, -dat:GetVal(1), BD_AID.CD, -dat:GetVal(2))
            s.hero.rival:AddBuff(dat.buff)
        end
    end
end
--天勇星
_sks[58] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30580)
                if slot then slot.isSleep = true end
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30580)
            if slot then slot.isSleep = false end
        else
            local buff = BD_Buff(30570, BD_Const.MAX_TIME)
            local v1, v2 = -dat:GetVal(1), dat:GetVal(2)
            buff:SetAtt(BD_Att.SPD, v1)
            buff:SetAtt(BD_Att.SSD, v1)
            buff:SetAtt(BD_Att.CPD, v2)
            buff:SetAtt(BD_Att.CSD, v2)
            dat.buff = buff
            s.hero:AddBuff(buff)
        end
    end
end
--天罡星
_sks[59] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero.rival:GetBuff(30590)
                if slot then slot.isSleep = true end
            end
        elseif dat.buff then
            local slot = s.hero.rival:GetBuff(30590)
            if slot then slot.isSleep = false end
        else
            local v = -dat:GetVal(1)
            dat.buff = BD_Buff.BD_BuffTriple(30590, BD_Const.MAX_TIME, BD_AID.Str, v, BD_AID.Wis, v, BD_AID.CAP, v)
            s.hero.rival:AddBuff(dat.buff)
        end
    end
end
--地慧星
_sks[60] = function(s, dat)
    if s.map.time < dat:GetCond(2) then return end
    dat.active = false
    dat.buff = BD_Buff.BD_BuffSingle(30600, dat:GetValMS(2), BD_AID.SDmg, B_Math.ceil(s.hero.Wis * dat:GetVal(1) * 0.01))
    s.hero.rival:AddBuff(dat.buff)
end
--地暴星
_sks[61] = function(s, dat)
    if s.t_isMe then
        if dat.buff == nil then
            dat.buff = BD_Buff.BD_BuffSingle(30610, dat:GetValMS(2), BD_AID.SSD, -dat:GetVal(1))
        end
        s.hero:AddBuff(dat.buff)
    end
end
--地幽星
_sks[62] = function(s, dat)
    if s.t_isMe then
        if HeroSpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30620)
                if slot then slot.isSleep = true end
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30620)
            if slot then slot.isSleep = false end
        else
            dat.buff = BD_Buff.BD_BuffSingle(30620, BD_Const.MAX_TIME, BD_AID.SCrit, dat:GetVal(1))
            s.hero:AddBuff(dat.buff)
        end
    end
end
--地速星
_sks[63] = function(s, dat)
    if s.t_isMe then
        if s.hero.RealTP < dat:GetCond(2) then
            if dat.buff and dat.vals[1] ~= 0 then
                dat.vals[1] = 0
                local slot
                local isAtk = s.hero.isAtk
                s.map:ForeachUnit(function(u)
                    if u.isAtk == isAtk then
                        slot = u:GetBuff(30630)
                        if slot then slot.isSleep = true end
                    end
                end, BD_Soldier)
            end
        elseif dat.buff then
            local slot
            local isAtk = s.hero.isAtk
            dat.vals[1] = 1
            s.map:ForeachUnit(function(u)
                if u.isAtk == isAtk then
                    slot = u:GetBuff(30630)
                    if slot then
                        slot.isSleep = false
                    else
                        u:AddBuff(dat.buff)
                    end
                end
            end, BD_Soldier)
        else
            dat.vals = { 1 }
            dat.buff = BD_Buff.BD_BuffSingle(30630, BD_Const.MAX_TIME, BD_AID.MSPA, dat:GetVal(1))
            s.hero:AddBuff(dat.buff)
            local isAtk = s.hero.isAtk
            s.map:ForeachUnit(function(u)
                if u.isAtk == isAtk then
                    u:AddBuff(dat.buff)
                end
            end, BD_Soldier)
        end
    end
end
--地异星
_sks[64] = function(s, dat)
    if s.map.time < dat:GetCond(2) then return end
    dat.active = false
    s.hero:AddExtBonus(6, -dat:GetVal(1))
end
--地空星
_sks[65] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30650)
                if slot then slot.isSleep = true end
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30650)
            if slot then slot.isSleep = false end
        else
            local v = -dat:GetVal(1)
            dat.buff = BD_Buff.BD_BuffDouble(30650, BD_Const.MAX_TIME, BD_AID.SPD, v, BD_AID.SSD, v)
            s.hero:AddBuff(dat.buff)
        end
    end
end
--地恶星
_sks[66] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30660)
                if slot then slot.isSleep = false end
            else
                dat.buff = BD_Buff.BD_BuffSingle(30660, BD_Const.MAX_TIME, BD_AID.CD, dat:GetVal(1))
                s.hero:AddBuff(dat.buff)
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30660)
            if slot then slot.isSleep = true end
        end
    end
end
--地乐星
_sks[67] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30670)
                if slot then slot.isSleep = false end
            else
                dat.buff = BD_Buff.BD_BuffSingle(30670, BD_Const.MAX_TIME, BD_AID.Cure, dat:GetVal(1))
                s.hero:AddBuff(dat.buff)
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30670)
            if slot then slot.isSleep = true end
        end
    end
end
--地巧星
_sks[68] = function(s, dat)
    if dat.t_isMe then return end
    if CheckRivalDpsCond(s, dat) and dat:GetVal(3) > s.map.random:NextInf(0, 100) then
        dat.buff = BD_Buff.BD_BuffSingle(30680, dat:GetValMS(2), BD_AID.SDmg, B_Math.ceil(s.hero.Wis * dat:GetVal(1) * 0.01))
        s.hero.rival:AddBuff(dat.buff)
    end
end
--地魔星
_sks[69] = function(s, dat)
    if dat.t_isMe then return end
    if CheckRivalDpsCond(s, dat) and dat:GetVal(3) > s.map.random:NextInf(0, 100) then
        if dat.buff == nil then
            dat.buff = BD_Buff.BD_BuffSingle(30690, dat:GetValMS(2), BD_AID.SDmg, dat:GetVal(1))
            dat.buff.replace = dat.rep.value
        end
        s.hero.rival:AddBuff(dat.buff)
    end
end
--地佐星
_sks[70] = function(s, dat)
    if dat.t_isMe then return end
    if CheckRivalDpsCond(s, dat) then
        if dat.buff == nil then
            dat.buff = BD_Buff.BD_BuffDouble(30700, dat:GetValMS(3), BD_AID.Str, dat:GetVal(1), BD_AID.Crit, dat:GetVal(2))
        end
        s.hero:AddBuff(dat.buff)
    end
end
--地走星
_sks[71] = function(s, dat)
    if s.map.time < dat:GetCond(2) then return end
    dat.active = false
    s.hero:AddExtBonus(7, dat:GetVal(1))
end
--地伏星
_sks[72] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                local slot = s.hero:GetBuff(30720)
                if slot then slot.isSleep = true end
            end
        elseif dat.buff then
            local slot = s.hero:GetBuff(30720)
            if slot then slot.isSleep = false end
        else
            local v = dat:GetVal(1)
            dat.buff = BD_Buff.BD_BuffDouble(30720, BD_Const.MAX_TIME, BD_AID.CPD, v, BD_AID.CSD, v)
            s.hero:AddBuff(dat.buff)
        end
    end
end
--地藏星
_sks[73] = function(s, dat)
    if dat.t_isMe then
        if HeroHpPercent(s) < dat:GetCond(2) then
            if dat.buff then
                dat.vals = { 1 }
                local buff = BD_Buff(30730, BD_Const.MAX_TIME)
                local v1, v2 = -dat:GetVal(1), dat:GetVal(2)
                buff:SetAtt(BD_AID.SPD, v1)
                buff:SetAtt(BD_AID.SSD, v1)
                buff:SetAtt(BD_AID.CPD, v2)
                buff:SetAtt(BD_AID.CSD, v2)
                dat.buff = buff
                local isAtk = s.hero.isAtk
                s.map:ForeachUnit(function(u)
                    if u.isAtk == isAtk then
                        u:AddBuff(buff)
                    end
                end, BD_Soldier)
            else
                dat.vals[1] = 1
                local slot
                local isAtk = s.hero.isAtk
                s.map:ForeachUnit(function(u)
                    if u.isAtk == isAtk then
                        u:GeBuff(30730)
                        if slot then
                            slot.isSleep = false
                        else
                            u:AddBuff(dat.buff)
                        end
                    end
                end, BD_Soldier)
            end
        elseif dat.buff and dat.vals[1] ~= 0 then
            dat.vals[1] = 0
            local slot
            local isAtk = s.hero.isAtk
            s.map:ForeachUnit(function(u)
                if u.isAtk == isAtk then
                    u:GeBuff(30730)
                    if slot then
                        slot.isSleep = true
                    end
                end
            end, BD_Soldier)
        end
    end
end
