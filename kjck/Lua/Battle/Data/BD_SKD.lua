
local insert = table.insert
local ipairs = ipairs

local BD_Const = QYBattle.BD_Const
local B_Math = QYBattle.B_Math
local B_Vector = QYBattle.B_Vector
local BD_Buff = QYBattle.BD_Buff
local BD_AID = QYBattle.BD_AID
local BD_Soldier = QYBattle.BD_Soldier

local _base = QYBattle.BD_Unit

local LifeTime = 30000

local _skd = { }

--[[
map BD_Field                所属战场数据
pos B_Vector                位置
hero BD_Hero                所属武将数据
dehero BD_Dehero            所属副将数据
dat EnSkd                   副将技数据
sn int                      技能编号
isAtk bool                  攻守标记
lifeTime int                生命时间
maxLifeTime int             最大生命时间
action function             具体技能行为函数
eventListener function      事件侦听函数
dps int                     输出值
vals table                  辅助值
step int                    当前步骤
wait int                    等待时间
units table                 技能的子级单位
unitQty int                 技能的子级单位数量
buff BD_Buff                buff
hitTargetList table         触发单位列表
]]

--延迟tm毫秒后完成该技能
local function Dead(s, tm)
    if tm and tm > 0 then
        s.lifeTime = s.map.time + tm
    else
        s:Dead()
    end
end
--等待tm毫秒
local function WaitForTime(s, tm)
    s.wait = s.map.time + tm
end

local function HitTarget(s, target)
    if target and s.hitTargetList then
        insert(s.hitTargetList, target)
    end
end
--获取当前为止被技能击中的目标
function _skd.GetHitTarget(s)
    local lst = s.hitTargetList
    if lst and #lst > 0 then
        s.hitTargetList = { }
        return lst
    end
end
--技能单位
function _skd.GetUnit(s, idx) return s.units[idx] end

function _skd.Update(s)
    local tm = s.map.time
    if s.action and s.wait < tm then s:action() end
    if tm > s.lifeTime then s:Dead() end
end

function _skd.OnDead(s)
    s.step = 255
    s.dps = 0
    s.wait = 0
    s.action = nil
    if s.eventListener then
        s.hero.onEvent[s.eventListener] = nil
        s.eventListener = nil
    end
end

--构造
--dehero : BD_Dehero
--dat : EnSkd
local function _ctor(t, dehero, dat)
    t = setmetatable(_base(dehero.map), _skd)

    local sn = dat.sn.value

    t.name = "skd_"..sn

    t.dehero = dehero
    t.hero = dehero.hero
    t.isAtk = dehero.isAtk
    t.dat = dat
    t.sn = sn
    t.maxLifeTime = LifeTime
    t.step = 0
    t.wait = 0
    t.unitQty = 0

    dat.curQty.value = dat.curQty.value - 1
    dat.curCd.value = 0

    if t.map.hasEvent then t.hitTargetList = { } end

    t.action = rawget(_skd, sn)
    if t.action then
        Dead(t, LifeTime)
        t:action()
    else
        t:Dead()
    end

    return t
end

--继承扩展
_base:extend(_ctor, nil, nil, _skd)
--[Comment]
--战场副将技
QYBattle.BD_SKD = _skd

--[Comment]
--取伤害值
local function GetDmg(s)
    local h = s.hero
    return s.dat:GetDps(h.Str, h.Wis, h.Cap) * (1 + h.CSD * 0.01)
end
--[Comment]
--取治疗值
local function GetCure(s)
    local h = s.hero
    return s.dat:GetDps(h.Str, h.Wis, h.Cap)
end

local function CheckEnemy(s, target)
    return target and target.isAtk ~= s.hero.isAtk and not target.isDead
end

--获取指定区域
local function GetRange(s, rx, ry, x, y)
    local xMin = x - B_Math.modf(rx / 2)
    local yMin = y - B_Math.modf(ry / 2)
    local xMax = xMin + rx - 1
    local yMax = yMin + ry - 1
    local w, h = s.map.width, s.map.height
    if xMin < 0 then
        xMin, xMax = 0, B_Math.min(xMax - xMin, w - 1)
    elseif xMax >= w then
        xMin, xMax = B_Math.max(0, xMin - (xMax - w + 1)), w - 1
    end
    if yMin < 0 then
        yMin, yMax = 0, B_Math.min(yMax - yMin, h - 1)
    elseif yMax >= h then
        yMin, yMax = B_Math.max(0, yMin - (yMax - h + 1)), h - 1
    end
    return xMin, yMin, xMax, yMax
end
--获取敌军密集区域
local function GetEnemyDenseRange(s, rx, ry) return GetRange(s, rx, ry, s.map:SearchUnitFocus(not s.hero.isAtk)) end

--鼓舞
_skd[1] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local buff = BD_Buff.BD_BuffSingle(20010, s.dat:GetValMS(2), BD_AID.MSPA, s.dat:GetVal(1))
        buff.replace = s.dat.rep.value
        s.buff = buff
        local lst = s.map:SearchUnits(s.hero.isAtk, BD_Soldier)
        for _, u in ipairs(lst) do
            u:AddBuff(buff)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--援军
_skd[2] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local hero = s.hero
        local tp, maxTP = hero.TP, hero.MaxTP
        local val = B_Math.ceil(s.dat:GetValPercent(1) * maxTP)
        if tp + val > maxTP then val = maxTP - tp end
        if val <= 0 then
            s:Dead()
            return
        end

        local map = s.map
        local isAtk = hero.isAtk
        local qty = val
        local x = isAtk and 0 or map.width - 1
        local dx = isAtk and 1 or - 1
        local y1 = hero.y
        local y2 = y1 + 1
        local dy = true
        local cy = 0
        while qty > 0 and (isAtk and x < map.width or x > 0) do
            if dy then
                cy = y1
                y1 = y1 - 1
            else
                cy = y2
                y2 = y2 + 1
            end
            dy = not dy
            if qty > 0 and map:PosAvailableAndEmpty(x, cy) then
                qty = qty - 1
                local u = BD_Soldier(map, x, cy)
                u:InitData(hero)
                HitTarget(s, u)
            end

            if qty <= 0 then break end

            if y1 < 1 and y2 >= map.height - 1 then
                x = x + dx
                y1 = hero.y
                y2 = y1 + 1
            end
        end
        if val > qty then
            hero:SetTP(val - (qty > 0 and qty or 0))
        end
        s:Dead()
    end
end
--遮天蔽日
_skd[3] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local buff = BD_Buff.BD_BuffSingle(20030, s.dat:GetValMS(2), BD_AID.Acc, -s.dat:GetVal(1))
        buff.replace = s.dat.rep.value
        s.buff = buff
        local lst = s.map:SearchUnits(not s.hero.isAtk, BD_Soldier)
        for _, u in ipairs(lst) do
            u:AddBuff(buff)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--巨石碾压
_skd[4] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        local pos = s.hero.rival.pos
        s.pos:Set(pos.x, pos.y)

        WaitForTime(s, 200)
        s.step = 2
    elseif s.step == 2 then
        local rx = s.dat:GetVal(1) * 0.5
        local ry = s.dat:GetVal(2) * 0.5
        local pos = s.pos
        local dh = s.dehero
        local dps = s.dps
        s.map:ForeachAreaUnits(pos.x - rx, pos.y - ry, pos.x + rx, pos.y + ry, function(u)
            if CheckEnemy(s, u) and dh:SkillDPS(u, dps) then
                s.map:Log("巨石碾压对" .. u.DebugName .. "造成<" .. dps .. ">点伤害")
                HitTarget(u)
            end
        end)
        s:Dead()
    end
end
--回馈
_skd[5] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.hero:SufferEnergy(s.dat:GetVal(1))
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--决死意志
_skd[6] = function(s)
    if s.step == 0 then
        s.vals = { s.hero.TP, s.dat.rep.value }
        if s.vals[2] > 0 then
            WaitForTime(s, 100)
            s.step = 1
        else
            s:Dead()
        end
    elseif s.step == 1 then
        local dat = s.dat
        local hero = s.hero
        local tp = hero.TP
        if dat:GetCond(2) == 1 and tp / hero.MaxTP < dat:GetCond(3) or tp < dat:GetCond(3) then
            local stp, srep = s.vals[1], s.vals[2]
            if stp > tp then
                local d = stp - tp
                if d > srep then
                    d = srep
                    s.vals[2] = 0
                else
                    s.vals[2] = srep - d
                end
                if s.buff == nil then
                    s.buff = BD_Buff.BD_BuffSingle(20060, dat:GetValMS(2), BD_AID.CSD, dat:GetVal(1))
                    s.buff.replace = dat.rep.value
                end
                local slot = hero:AddBuff(s.buff)
                if d > 1 then solt.multi = solt.multi + d - 1 end
                HitTarget(hero)
            end
        end
    end
end
--飞刀暗袭
_skd[7] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        local pos = s.hero.rival.pos
        s.pos:Set(pos.x, pos.y)

        WaitForTime(s, 200)
        s.step = 2
    elseif s.step == 2 then
        local rx = s.dat:GetVal(1) * 0.5
        local ry = s.dat:GetVal(2) * 0.5
        local pos = s.pos
        local dh = s.dehero
        local dps = s.dps
        s.map:ForeachAreaUnits(pos.x - rx, pos.y - ry, pos.x + rx, pos.y + ry, function(u)
            if CheckEnemy(s, u) and dh:SkillDPS(u, dps) then
                s.map:Log("飞刀暗袭对" .. u.DebugName .. "造成<" .. dps .. ">点伤害")
                HitTarget(u)
            end
        end)
        s:Dead()
    end
end
--勇武战意
_skd[8] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20080, s.dat:GetValMS(2), BD_AID.SPD, -s.dat:GetVal(1))
        s.buff.replace = s.dat.rep.value
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--磐石护甲
_skd[9] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20090, s.dat:GetValMS(2), BD_AID.SSD, -s.dat:GetVal(1))
        s.buff.replace = s.dat.rep.value
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--冰爆轰击
_skd[10] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local buff = BD_Buff.BD_BuffSingle(20100, s.dat:GetValMS(4), BD_AID.MoveSpeed, -s.dat:GetVal(3))
        s.buff = buff
        local dps = B_Math.ceil(GetDmg(s))
        s.dps = dps
        local pos = s.hero.rival.pos
        s.pos:Set(pos.x, pos.y)

        local dh = s.dehero
        local rx = s.dat:GetVal(1) * 0.5
        local ry = s.dat:GetVal(2) * 0.5
        s.map:ForeachAreaUnits(pos.x - rx, pos.y - ry, pos.x + rx, pos.y + ry, function(u)
            if CheckEnemy(s, u) and dh:SkillDPS(u, dps) then
                s.map:Log("冰爆轰击对" .. u.DebugName .. "造成<"..dps .. ">点伤害")
                HitTarget(u)
            end
        end)
        s:Dead()
    end
end
--生命绽放
_skd[11] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20110, s.dat:GetValMS(2), BD_AID.Cure, B_Math.floor(s.dat:GetVal(1) * s.hero.MaxHP * 0.01))
        s.buff.replace = s.dat.rep
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--回光返照
_skd[12] = function(s)
    if s.step == 0 then
        if s.hero.dat.hp.value <= 0 then s.hero.dat.hp.value = 1 end
        s.hero:AddBuff(BD_Buff.BD_BuffSingle(20120, s.dat:GetValMS(1), BD_AID.God, 1))
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20121, s.dat:GetValMS(2), BD_AID.Cure, B_Math.floor(s.dat:GetVal(3) * s.hero.MaxHP * 0.01 + s.dat:GetVal(4) / s.dat:GetVal(2)))
        s.buff.replace = s.dat.rep
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--天雷连法
_skd[13] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local dps = B_Math.ceil(GetDmg(s))
        s.dps = dps
        local rival = s.hero.rival
        if s.dehero:SkillDPS(rival, dps) then
            s.map:Log("天雷连法对" .. rival.DebugName .. "造成<" .. dps .. ">点伤害")
            HitTarget(rival)
        end
        s:Dead()
    end
end
--侵蚀
_skd[14] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20140, s.dat:GetValMS(2), BD_AID.SSD, s.dat:GetVal(1))
        s.buff.replace = s.dat.rep.value
        s.hero.rival:AddBuff(s.buff)
        HitTarget(s, s.hero.rival)
        s:Dead()
    end
end
--能量充沛
_skd[15] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.hero:SufferEnergy(s.dat:GetVal(1))
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--风驰电掣
_skd[16] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local buff = BD_Buff.BD_BuffSingle(20160, s.dat:GetValMS(2), BD_AID.MoveSpeed, s.dat:GetVal(1))
        buff.replace = s.dat.rep.value
        s.buff = buff
        local lst = s.map:SearchUnits(s.hero.isAtk, BD_Soldier)
        for _, u in ipairs(lst) do
            u:AddBuff(buff)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--法术屏障
_skd[17] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local buff = BD_Buff.BD_BuffSingle(20170, s.dat:GetValMS(2), BD_AID.SSD, -s.dat:GetVal(1))
        buff.replace = s.dat.rep.value
        s.buff = buff
        local lst = s.map:SearchUnits(s.hero.isAtk, BD_Soldier)
        for _, u in ipairs(lst) do
            u:AddBuff(buff)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--箭雨伏击
_skd[18] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local qty = s.dat:GetVal(1)
        if qty <= 0 then s:Dead(); return end

        s.dps = B_Math.ceil(GetDmg(s))
        
        local units = { }

        local minX, minY, maxX, maxY = GetEnemyDenseRange(s, s.dat:GetVal(2), s.dat:GetVal(3))
        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)

        local rnd = s.map.random
        local dt = B_Math.modf(s.dat:GetValMS(4) / qty)
        for i = 1, qty, 1 do
            units[i] = 
            {
                status = 1,
                pos = B_Vector(rnd:NextInt(minX, maxX + 1), rnd:NextInt(minY, maxY + 1)),
                time = i > 1 and units[i - 1].time - rnd:NextInt(0, dt) or 0,
            }
        end
        s.units = units
        s.unitQty = qty
        s.step = 2
    elseif s.step == 2 then
        local alive = false

        local range = 1.5
        local hr = range * 0.5
        local pos, dps = s.pos, s.dps

        local minX, minY, maxX, maxY = pos.x - hr, pos.y - hr, pos.x + hr, pos.y + hr
        
        local map = s.map
        local dtm = map.deltaMillisecond
        local dh = s.dehero
        
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                u.time = u.time + dtm
                if u.time >= 100 then
                    u.time = 0
                    u.status = 255
                    map:ForeachAreaUnits(minX, minY, maxX, maxY, function(u)
                        if CheckEnemy(s, u) and dh:SkillDPS(u, dps) then
                            s.map:Log("箭雨伏击对" .. u.DebugName .. "造成<" .. dps .. ">点伤害")
                            HitTarget(u)
                        end
                    end)
                end
                alive = true
            end
        end
        if not alive then s:Dead() end
    end
end
--战意爆发
_skd[19] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20190, s.dat:GetValMS(2), BD_AID.CSD, s.dat:GetVal(1))
        s.buff.replace = s.dat.rep.value
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--腐蚀
_skd[20] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20200, s.dat:GetValMS(1), BD_AID.SDmg, B_Math.ceil(GetDmg(s)))
        s.buff.replace = s.dat.rep.value
        s.hero.rival:AddBuff(s.buff)
        HitTarget(s, s.hero.rival)
        s:Dead()
    end
end
--绝命反击
_skd[21] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        Dead(s, BD_Const.MAX_TIME)
        s.buff = BD_Buff.BD_BuffSingle(20210, BD_Const.MAX_TIME, BD_AID.Wis, s.dat:GetVal(2))
        s.buff.replace = 9999
        s.vals = { 0, s.hero.HP }
        s.step = 2
    elseif s.step == 2 then
        local vals = s.vals
        local hero = s.hero
        local curHP = hero.HP
        if vals[2] > curHP then
            vals[1] = vals[1] + vals[2] - curHP
        end
        vals[2] = curHP
        local threshold = B_Math.ceil(hero.MaxHP * s.dat:GetValPercent(1))
        if threshold > 0 and vals[1] >= threshold then
            vals[1] = vals[1] - threshold
            hero:AddBuff(s.buff)
            HitTarget(s, hero)
        end
    end
end
--孤军奋战
_skd[22] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local buff = BD_Buff(20220, BD_Const.MAX_TIME)
        local v1, v2 = s.dat:GetVal(1), s.dat:GetVal(2)
        buff:SetAtt(BD_AID.SPD, v1)
        buff:SetAtt(BD_AID.SSD, v1)
        buff:SetAtt(BD_AID.CPD, v2)
        buff:SetAtt(BD_AID.CSD, v2)
        buff.replace = s.dat.rep.value
        s.buff = buff
        s.hero:AddBuff(buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--决斗
_skd[23] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local var = s.dat:GetVal(2)
        local buff = BD_Buff.BD_BuffDouble(20230, BD_Const.MAX_TIME, BD_AID.CPD, -var, BD_AID.CSD, -var)
        buff.replace = s.dat.rep.value
        s.hero.rival:AddBuff(buff)
        buff = BD_Buff.BD_BuffSingle(20231, BD_Const.MAX_TIME, BD_AID.MoveSpeed, s.dat:GetVal(1))
        buff.replace = s.dat.rep.value
        s.buff = buff
        s.hero:AddBuff(buff)
        HitTarget(s, s.hero.rival)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--烈火护体
_skd[24] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.vals = { 0 }
        Dead(s, s.dat:GetValMS(1))
        s.step = 2
    elseif s.step == 2 then
        local vals = s.vals
        if vals[1] > 0 then
            vals[1] = vals[1] - s.map.deltaMillisecond
        else
            vals[1] = 1000
            local pos = s.hero.pos
            local dh = s.dehero
            local dps = s.dps
            s.map:ForeachAreaUnits(pos.x - 1.5, pos.y - 1.5, pos.x + 1.5, pos.y + 1.5, function(u)
                if CheckEnemy(s, u) and dh:SkillDPS(u, dps) then
                    s.map:Log("烈火护体" .. u.DebugName .. "造成<" .. dps .. ">点伤害")
                    HitTarget(u)
                end
            end)
        end
    end
end
--反间之道
_skd[25] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local hero = s.hero
        local tp, maxTP = hero.TP, hero.MaxTP
        local qty = B_Math.CeilToInt(s.dat:GetValPercent(1) * hero.rival.MaxTP)
        qty = B_Math.min(qty, hero.rival.TP, maxTP - tp)
        if qty <= 0 then s:Dead(); return end
        local lst = s.map:SearchUnits(not hero.isAtk, BD_Soldier)
        if #lst > 0 then
            local q = qty
            if #lst > qty then
                local rx, ry = hero.rival.x, hero.rival.y
                table.sort(lst, function(a, b)
                    return B_Math.abs(a.x - rx) + B_Math.abs(a.y - ry) > B_Math.abs(b.x - rx) + B_Math.abs(b.y - ry)
                end)
            end
            for _, u in ipairs(lst) do
                u:SetBelong(hero)
                HitTarget(s, u)
                q = q - 1
                if q <= 0 then break end
            end
            if qty > q then
                qty = qty - (q > 0 and q or 0)
                hero:SetTP(qty)
                hero.rival:SetTP(-qty)
            end
        end
    end
end
--乘胜追击
_skd[26] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local buff = BD_Buff.BD_BuffDouble(20260, s.dat:GetValMS(3), BD_AID.CPD, s.dat:GetVal(1), BD_AID.MSPA, s.dat:GetVal(2))
        buff.replace = s.dat.rep.value
        s.buff = buff
        local lst = s.map:SearchUnits(s.hero.isAtk, BD_Soldier)
        for _, u in ipairs(lst) do
            u:AddBuff(buff)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--战意激昂
_skd[27] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local buff = BD_Buff.BD_BuffSingle(20270, s.dat:GetValMS(2), BD_AID.Str, s.dat:GetVal(1))
        buff.replace = s.dat.rep.value
        s.buff = buff
        local lst = s.map:SearchUnits(s.hero.isAtk, BD_Soldier)
        for _, u in ipairs(lst) do
            u:AddBuff(buff)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--迟缓
_skd[28] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        local buff = BD_Buff.BD_BuffSingle(20280, s.dat:GetValMS(2), BD_AID.MoveSpeed, -s.dat:GetVal(1))
        buff.replace = s.dat.rep.value
        s.buff = buff
        local lst = s.map:SearchUnits(not s.hero.isAtk, BD_Soldier)
        for _, u in ipairs(lst) do
            u:AddBuff(buff)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--越战越勇
_skd[29] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        Dead(s, BD_Const.MAX_TIME)
        s.buff = BD_Buff.BD_BuffSingle(20290, BD_Const.MAX_TIME, BD_AID.SCrit, s.dat:GetVal(2))
        s.buff.replace = s.dat.rep.value
        s.vals = { s.map.time, 0, s.dat:GetValMS(1) }
        s.vals[2] = s.vals[3] - 100
        s.step = 2
    elseif s.step == 2 then
        local vals = s.vals
        if s.hero:IsSCritAfterTime(vals[1]) then
            s.hero:RemoveBuff(20290)
        elseif s.map.time - vals[2] > vals[3] then
            vals[2] = s.map.time
            s.hero:AddBuff(s.buff)
            HitTarget(s, s.hero)
        end
    end
end
--能量倾泻
_skd[30] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.hero:SufferEnergy(s.dat:GetVal(1))
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--铁布衫
_skd[31] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20310, BD_Const.MAX_TIME, BD_AID.Shield, B_Math.ceil(s.dat:GetValPercent(1) * s.hero.MaxHP))
        s.buff.replace = s.dat.rep.value
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--魅惑
_skd[32] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20320, s.dat:GetVal(1), BD_AID.Stop, 1)
        s.buff.replace = s.dat.rep.value
        s.hero.rival:AddBuff(s.buff)
        HitTarget(s, s.hero.rival)
        s:Dead()
    end
end
--免疫控制
_skd[33] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20330, BD_Const.MAX_TIME, BD_AID.ResControl, 1)
        s.buff.replace = s.dat.rep.value
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--妙手回春
_skd[34] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.dehero:CureDPS(s.hero, B_Math.ceil(s.dat:GetValPercent(1) * s.hero.MaxHP))
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--固若金汤
_skd[35] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.buff = BD_Buff.BD_BuffSingle(20350, s.dat:GetVal(1), BD_AID.God, 1)
        --s.buff.replace = s.dat.rep.value
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--严防死守
_skd[36] = function(s)
    if s.step == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif s.step == 1 then
        s.step = 255
        s.action = nil
        local time = s.dat:GetValMS(1)
        Dead(s, time)
        s.buff = BD_Buff.BD_BuffSingle(20360, time, BD_AID.SSD, -s.dat:GetVal(2))
        s.buff.replace = s.dat.rep.value
        local hero = s.hero
        local slot = hero:AddBuff(s.buff)
        HitTarget(s, hero)

        local ET_DPS = QYBattle.BE_Type.DPS
        local DT_SKC = QYBattle.BD_DPS.Type.Skill
        local DTAG = QYBattle.BD_DPS.Tag
        s.eventListener = function(u, typ, dat)
            if slot.sn == 20360 and u == hero and typ == ET_DPS then
                if dat:CheckType(DT_SKC) then
                    if dat:ContainsAnyTag(DTAG.Miss, DTAG.Dodge, DTAG.Buff) then return end
                    slot.multi = slot.multi + 1
                end
            end
        end
        hero.onEvent[s.eventListener] = true
    end
end
