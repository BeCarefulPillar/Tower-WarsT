local ipairs = ipairs

local SKD_COND = QYBattle.BD_SKD_COND
local BE_Type = QYBattle.BE_Type
local BD_DPS = QYBattle.BD_DPS
local BD_DPS_TAG = BD_DPS.Tag
local B_Math = QYBattle.B_Math
local BD_SKD = QYBattle.BD_SKD

local _base = QYBattle.BD_Unit

local TT_Me = 1
local TT_Enemy = 2
local TT_MeAndEnemy = 3

local _dh = { }

--所属武将
--BD_Hero _hero
--副将编号
--dbsn
--副将等级
--lv
--副将星级
--star
--技能列表
--skill
--技能数量
--skillQty
--扩展属性(天赋)
--BD_ExtAtt extAtt
--武将伤害统计
--dps
--下次触发时间事件的时间
--nextTimeCond

--指定索引技能数据获取
function _dh.GetSkill(d, idx) return d.skill[idx] end
--获取扩展属性词条(专属 天赋)的值
function _dh.GetExtAtt(d, mark) return d.extAtt[mark] or 0 end

--获取最近(dt=0)或一段时间内(dt>0)武将受到的指定类型的伤害
--dtyp : 输出类型
--dt : 时间段(MS)
local function GetHeroDmg(d, dtyp, dt)
    local dps = d.dps
    if dps then
        if dt and dt > 0 then
            local v, t = 0, d.map.time - dt
            for i = #dps, 1, -1 do
                if dps[i].time >= t then
                    d = dps[i].dps
                    if d:CheckType(dtyp) and not d:ContainsAnyTag(BD_DPS_TAG.Miss, BD_DPS_TAG.Dodge) then
                         v = v + d.value
                    end
                end
            end
            return v
        end
        for i = #dps, 1, -1 do
            d = dps[i].dps
            if d:CheckType(dtyp) and not d:ContainsAnyTag(BD_DPS_TAG.Miss, BD_DPS_TAG.Dodge) then
                return d.value
            end
        end
    end
    return 0
end
--事件触发
local function TriggerSkill(d, s, isMe, cond, dat)
    local c = s:GetCond(1)
    if c ~= cond or s.curQty.value <= 0 or s:isCd() or s:NotCondTag(isMe and TT_Me or TT_Enemy) then return end
    if c == SKD_COND.T_Atk or c == SKD_COND.T_Skill then
        BD_SKD(d, s)
        return
    elseif c == SKD_COND.T_HeroCmd or c == SKD_COND.T_SoCmd then
        if dat == s:GetCond(2) then BD_SKD(d, s) end
        return
    elseif c == SKD_COND.T_Time then
        local ct = s:GetCond(2)
        if d.map.time < ct then
            d.nextTimeCond = B_Math.min(d.nextTimeCond, ct)
            return
        end
        if s.curQty.value > 1 then
            d.nextTimeCond = B_Math.min(d.nextTimeCond, ct + s.cd.value)
        end
        BD_SKD(d, s)
        return
    elseif c == SKD_COND.T_DPS then
        if not dat:CheckType(s:GetCond(2)) then return end
    elseif c == SKD_COND.T_HP or c == SKD_COND.T_SP or c == SKD_COND.T_TP then
        if type(dat) ~= "number" then return end
    end

    c = s.sn.value
    if c == 2       --援军：自身士兵低于X
    or c == 6       --决死意志：自身士兵低于X
    or c == 12      --回光返照：自身生命低于X
    or c == 15      --能量充沛：自身技力低于X
    or c == 22      --孤军奋战：自身士兵低于X
    or c == 25      --反间之道：自身士兵低于X
    or c == 26      --乘胜追击：敌将士兵低于X
    then
        if dat >= s:GetCond(2) then return end
    elseif c == 9 then
        --磐石护甲：X秒内自身受伤害大于Y
        if dat:ContainsAnyTag(BD_DPS_TAG.Miss, BD_DPS_TAG.Dodge) then return end
        if GetHeroDmg(d, s:GetCond(2), s:GetCond(4)) < s:GetCond(3) then return end
    elseif
       c == 10      --冰爆轰击：自身受到技能伤害
    or c == 11      --生命绽放：自身受到武力伤害
    or c == 20      --腐蚀：敌将受到技能伤害
    or c == 24      --烈火护体：自身受到武力伤害
    or c == 30      --能量倾泻：自身受到技能伤害
    or c == 34      --妙手回春：自身受到技能伤害
    or c == 36      --严防死守：自身受到技能伤害
    then
        if dat:ContainsAnyTag(BD_DPS_TAG.Miss, BD_DPS_TAG.Dodge, BD_DPS_TAG.Buff) then return end
    elseif c == 19 then
        --战意爆发：敌将生命低于百分之X
        if dat >= d.hero.MaxHP * s:GetCond(2) * 0.01 then return end
    elseif c == 23 then
        --决斗：敌我双方都无士兵
        if dat > 0 or (isMe and d.hero.rival or d.hero).RealTP > 0 then return end
    elseif c == 32 then
        --魅惑：主将造成技能伤害低于智力百分之X
        if isMe then return end
        if dat:ContainsAnyTag(BD_DPS_TAG.Miss, BD_DPS_TAG.Dodge, BD_DPS_TAG.Buff) then return end
        if dps.source ~= d.hero or dps.value >= d.hero.Wis * s:GetCond(3) * 0.01 then return end
    else
        return
    end

    BD_SKD(d, s)
end
--事件触发
local function TriggerSkills(d, isMe, cond, dat)
    for _, s in ipairs(d.skill) do TriggerSkill(d, s, isMe, cond, dat) end
end
--事件触发
function _dh.Trigger(d, isMe, etyp, dat)
    local skill = d.skill
    if skill == nil then return end
    if isMe and etyp == BE_Type.DPS and d.dps then
        d.dps[#d.dps + 1] = { time = d.map.time, dps = dat }
    end
    TriggerSkills(d, isMe, etyp, dat)
end

function _dh.Update(d)
    if d.nextTimeCond < d.map.time then
        d.nextTimeCond = 2147483647
        TriggerSkills(d, true, SKD_COND.T_Time)
    end
    if d.skill then
        local c
        local dt = d.map.deltaMillisecond
        for _, s in ipairs(d.skill) do
            c = s.curCd.value
            if s.curQty.value > 0 and c < s.cd.value then
                c = c + dt
                s.curCd.value = c
                if c >= s.cd.value then
                    c = s:GetCond(1)
                    if c == SKD_COND.T_HP then
                        TriggerSkill(d, s, true, SKD_COND.T_HP, d.hero.HP)
                        TriggerSkill(d, s, false, SKD_COND.T_HP, d.hero.rival.HP)
                    elseif c == SKD_COND.T_SP then
                        TriggerSkill(d, s, true, SKD_COND.T_SP, d.hero.SP)
                        TriggerSkill(d, s, false, SKD_COND.T_SP, d.hero.rival.SP)
                    elseif c == SKD_COND.T_TP then
                        TriggerSkill(d, s, true, SKD_COND.T_TP, d.hero.RealTP)
                        TriggerSkill(d, s, false, SKD_COND.T_TP, d.hero.rival.RealTP)
                    end
                end
            end
        end
    end
end

--对给定单位进行技能伤害
function _dh.SkillDPS(d, target, v)
    return target:SufferDPS(BD_DPS(d.hero, BD_DPS.Type.Skill, v, BD_DPS_TAG.Dodge))
end
--对给定单位进行治疗
function _dh.CureDPS(d, target, v)
    return target:SufferDPS(BD_DPS(d.hero, BD_DPS.Type.Cure, v))
end

--构造
--hero : BD_Hero
--dat : S_BattleDehero
local function _ctor(t, hero, dat)
    t = setmetatable(_base(hero.map), _dh)
    t.hero = hero
    t.isAtk = hero.isAtk
    t.dbsn = dat.dbsn and dat.dbsn ~= 21 and dat.dbsn or 0
    t.lv = dat.lv or 0
    t.star = dat.star or 0
    t.extAtt = QYBattle.BD_ExtAtt(dat.extra)
    t.skill = QYBattle.EnSkd.FromArray(dat.skill, hero.battle.EnInt)
    t.skillQty = t.skill and #t.skill or 0
    t.nextTimeCond = 2147483647

    if t.skillQty > 0 then
        local c = 0
        for i, s in ipairs(t.skill) do
            c = s:GetCond(1)
            if c == SKD_COND.T_Time then
                t.nextTimeCond = B_Math.min(t.nextTimeCond, s:GetCond(2))
            elseif c == SKD_COND.T_DPS and t.dps == nil then
                t.dps = { }
            end
        end
    end

    return t
end
--继承扩展
_base:extend(_ctor, nil, nil, _dh)
--[Comment]
--战场副将
QYBattle.BD_Dehero = _dh