local insert = table.insert

local BD_Const = QYBattle.BD_Const
local B_Math = QYBattle.B_Math
local B_Vector = QYBattle.B_Vector
local BE_Type = QYBattle.BE_Type
local B_Buffs = QYBattle.B_Buffs
local BD_AID = QYBattle.BD_AID
local BAT_CMD = QYBattle.BAT_CMD
local BD_DPS_TYPE = QYBattle.BD_DPS.Type
local BD_DPS_TAG = QYBattle.BD_DPS.Tag

local BD_Arrow = QYBattle.BD_Arrow
local BuffsUpdate = B_Buffs.Update
local GetBuffsAtt = B_Buffs.GetAtt

local _base = QYBattle.BD_CombatUnit
local FrontFirstEnemy = _base.FrontFirstEnemy
local BackFirstEnemy = _base.BackFirstEnemy
local STATUS = _base.STATUS
local CheckEnemy = _base.CheckEnemy

local _so = { }

--是否即将遭遇敌人
local function EncounterEnemy(s)
    local map = s.map
    return s.isAtk and (s.x > map.defMinX - 6 and s.x < map.defMaxX + 6) or (s.x > map.atkMinX - 6 and s.x < map.atkMaxX + 6)
end
--指定方向区域是否有敌人
--dire : 指定的方向 true=正向 fals=反向
local function DireAreaHasEnemy(s, dire)
    local map = s.map
    return s.isAtk and (dire and x < map.defMaxX + 2 or x > map.defMinX - 2) or (dire and x < map.atkMaxX + 2 or x > map.atkMinX - 2)
end
--是否是远程兵种
local function IsCasterSoldier(s) return s.sn == 6 or s.sn == 12 end
--检测所属武将的统帅是否变更
local function CheckCapChange(s)
    if s.lastCap == s.belong.Cap then return end
    s.lastCap = s.belong.Cap
    s.attChanged[BD_AID.Str] = true
    s.attChanged[BD_AID.HP] = true
    s.dmg = -1
end

--region 行为部分
--计算远程兵种下次射击的时间
local function NextShotTime(s)
    local map = s.map
    s.nextShotTime = B_Math.round(map.time + s.MSPA * map.random:Next(2.5, 5))
end
--试图配置到指定位置
local function MoveToPos(s, tx, ty)
    local dhx, dhy = tx - s.x, ty - s.y
    if B_Math.abs(dhx) > B_Math.abs(dhy) then
        if s.map:PlaceCombatUnit(s, s.x + (dhx > 0 and 1 or -1), s.y) then
            s.status = STATUS.Move
            return true
        end
        if s.map:PlaceCombatUnit(s, s.x, s.y + (dhy > 0 and 1 or -1)) then
            s.status = STATUS.Move
            return true
        end
    else
        if s.map:PlaceCombatUnit(s, s.x, s.y + (dhy > 0 and 1 or -1)) then
            s.status = STATUS.Move
            return true
        end
        if s.map:PlaceCombatUnit(s, s.x + (dhx > 0 and 1 or -1), s.y) then
            s.status = STATUS.Move
            return true
        end
    end
end
--试图转到攻击动作
local function ToAttackStatus(s)
    if s.status == STATUS.Think or s.status == STATUS.Move then
        local target = s:GetMeleeEnemy(s.direction)
        if target then
            s.status = STATUS.Attack
            return true
        end
        target = s:GetMeleeEnemy(-s.direction)
        if target then
            s.status = STATUS.Attack
            return true
        end
        if IsCasterSoldier(s) and s.nextShotTime <= s.map.time then
            --远程
            if FrontFirstEnemy(s) and s.map:GetCombatUnit(s.x + s.direction, s.y) == nil then
                s.status = STATUS.Attack
                return true
            end
            if BackFirstEnemy(s) and s.map:GetCombatUnit(s.x - s.direction, s.y) == nil then
                s.status = STATUS.Attack
                return true
            end
        end
    end
end
--士兵撤退
local function SoldierTetreat(s)
    local map = s.map
    local x, y = s.x, s.y
    local belong = s.belong
    local by = belong.y

    local bcmd = belong.isAtk and map.atkHeroCmd or map.defHeroCmd
    local block = (x - belong.x) * belong.direction > 0 --是否可能阻塞武将
    local EnGetCombatUnit = map.EnGetCombatUnit

    if block and (bcmd == BAT_CMD.Retreat or bcmd == BAT_CMD.Attack) then
        if y == by then
            local down, up = 0, 0
            for i = 0, y - 1, 1 do if EnGetCombatUnit(x, i) then down = down + 1 end end
            for i = y + 1, map.height - 1, 1 do if EnGetCombatUnit(x, i) then up = up + 1 end end
            if map:PlaceCombatUnit(s, x, y + (down > up and 1 or - 1)) then
                s.status = STATUS.Move
                return
            end
        elseif y > by then
            local dispersion = true
            for i = 0, y - 1, 1 do 
                if EnGetCombatUnit(x, i) == nil then
                    dispersion = false
                    break
                end
            end
            if dispersion then
                if map:PlaceCombatUnit(s, x, y + 1) then
                    s.status = STATUS.Move
                    return
                end
                if map.random:NextInt(0, 100) < 50 then
                    s.status = STATUS.Think
                    return
                end
            end
        else
            local dispersion = true
            for i = y + 1, by - 1, 1 do
                if EnGetCombatUnit(x, i) == nil then
                    dispersion = false
                    break
                end
            end
            if dispersion then
                if map:PlaceCombatUnit(s, x, y - 1) then
                    s.status = STATUS.Move
                    return
                end
                if map.random:NextInt(0, 100) < 50 then
                    s.status = STATUS.Think
                    return
                end
            end
        end
    end

    --优先撤退
    if map:PlaceCombatUnit(s, x + (s.isAtk and -1 or 1), y) then
        s.status = STATUS.Move
        return
    end

    --两边分散
    if map.random:NextInt(0, 100) < 50 then
        if (not block or y - 1 ~= by) and map:PlaceCombatUnit(s, x, y - 1) then
            s.status = STATUS.Move
            return
        end
        if (not block or y + 1 ~= by) and map:PlaceCombatUnit(s, x, y + 1) then
            s.status = STATUS.Move
            return
        end
    else
        if (not block or y + 1 ~= by) and map:PlaceCombatUnit(s, x, y + 1) then
            s.status = STATUS.Move
            return
        end
        if (not block or y - 1 ~= by) and map:PlaceCombatUnit(s, x, y - 1) then
            s.status = STATUS.Move
            return
        end
    end

    --攻击
    if not ToAttackStatus(s) then s.status = STATUS.Think end
end

--士兵出击
local function SoldierAttack(s)
    if s.Arrived < 1 then
        s.status = STATUS.Move
        return
    end

    local x, y = s.x, s.y
    local isAtk = s.isAtk
    local map = s.map
    
    local direction = s.direction
    if isAtk then
        direction = direction < 0 and (x > map.atkMinX - 2 and -1 or 1) or (x < map.defMaxX + 2 and 1 or -1)
    else
        direction = direction < 0 and (x > map.defMinX - 2 and -1 or 1) or (x < map.defMaxX + 2 and 1 or -1)
    end
    s.direction = direction

    local EnGetCombatUnit = map.EnGetCombatUnit

    if IsCasterSoldier(s) and FrontFirstEnemy(s) and s.nextShotTime <= map.time and EnGetCombatUnit(x + direction, y) == nil then
        --远程射击
        s.status = STATUS.Attack
        return
    end

    local target = nil

    --遭遇敌人
    if isAtk and (s.x > map.defMinX - 6 and s.x < map.defMaxX + 6) or not isAtk and (s.x > map.atkMinX - 6 and s.x < map.atkMaxX + 6) then
        target = s:GetMeleeEnemy(direction)
        if target then
            s.status = STATUS.Attack
            return
        end
        target = s:GetMeleeEnemy(-direction)
        if target then
            s.status = STATUS.Attack
            return  
        end
        target = EnGetCombatUnit(x + direction, y)
        if CheckEnemy(s, target) and target.status == STATUS.Move then
            s.status = STATUS.Think
            return  
        end
        target = EnGetCombatUnit(x - direction, y)
        if CheckEnemy(s, target) and target.status == STATUS.Move then
            s.status = STATUS.Think
            return  
        end

        local minX = B_Math.max(x - 6, 0)
        local maxX = B_Math.min(x + 6, map.width)
        local lst = { }
        for i = minX, maxX - 1, 1 do
            for j = 0, map.height - 1, 1 do
                target = EnGetCombatUnit(i, j)
                if CheckEnemy(s, target) and (EnGetCombatUnit(i + 1, j) == nil or EnGetCombatUnit(i - 1, j) == nil) then
                    insert(lst, target)
                end
            end
        end
        target = nil
        if #lst > 0 then
            local dis = 3.4E+38
            local v1, v2
            for _, u in ipairs(lst) do
                v1, v2 = u.x - x, u.y - y
                v1 = v1 * v1 + v2 * v2
                if v1 < dis then
                    target = u
                    dis = v1
                end
            end
        end
        if target then
            --攻击最近目标
            local tx, ty = target.x, target.y
            local tle = map:PosAvailableAndEmpty(tx - 1, ty)
            local tre = map:PosAvailableAndEmpty(tx + 1, ty)
            if tle or tre then
                tx = tx + (x > tx and (tre and 1 or -1) or (x < tx and (tle and -1 or 1) or (map.random:NextInt(0, 100) < 50 and (tle and -1 or 1) or (tre and 1 or -1))))
                if B_Math.abs(ty - y) > B_Math.abs(tx - x) then
                    if map:PlaceCombatUnit(s, x, y + (ty > y and 1 or -1)) then
                        s.status = STATUS.Move
                        return
                    end
                    if map:PlaceCombatUnit(s, x + (tx > x and 1 or -1), y) then
                        s.status = STATUS.Move
                        return
                    end
                else
                    if map:PlaceCombatUnit(s, x + (tx > x and 1 or -1), y) then
                        s.status = STATUS.Move
                        return
                    end
                    if map:PlaceCombatUnit(s, x, y + (ty > y and 1 or -1)) then
                        s.status = STATUS.Move
                        return
                    end
                end
            end
        end
    end

    local info = map.battleInfo
    local belong = s.belong
    local bx, by = belong.x, belong.y
    local rival = belong.rival
    local rx, ry = rival.x, rival.y

    local var = belong.isAtk and map.atkHeroCmd or map.defHeroCmd

    if info.hp ~= isAtk or var == BAT_CMD.Wait then
        --我方武将势弱或者是待机
        --敌将前后2格
        if B_Math.abs(bx - rx) > 1 and MoveToPos(s, rx + rival.direction * 2, ry) then return end
        if MoveToPos(s, rx - rival.direction * 2, ry) then return end

        --围攻敌将
        if MoveToPos(s, rx, ry) then return end

        local cc, nc = 0, 0
        if y < by then
            for i = 0, map.width - 1, 1 do
                target = EnGetCombatUnit(i, y)
                if target and target.isAtk == isAtk then cc = cc + 1 end
                target = EnGetCombatUnit(i, y + 1)
                if target and target.isAtk == isAtk then nc = nc + 1 end
            end
            if cc > nc and s.lastY ~= y + 1 and map:PlaceCombatUnit(s, x, y + 1) then
                s.status = STATUS.Move
                return
            end
        elseif y > by then
            for i = 0, map.width - 1, 1 do
                target = EnGetCombatUnit(i, y)
                if target and target.isAtk == isAtk then cc = cc + 1 end
                target = EnGetCombatUnit(i, y - 1)
                if target and target.isAtk == isAtk then nc = nc + 1 end
            end
            if cc > nc and s.lastY ~= y - 1 and map:PlaceCombatUnit(s, x, y - 1) then
                s.status = STATUS.Move
                return
            end
        end
    else
        if var == BAT_CMD.Attack and (x - bx) * belong.direction > 0 and not CheckEnemy(s, EnGetCombatUnit(bx + belong.direction, by)) then
            --武将进攻或者给武将让道
            if y == by then
                local dv = 0
                for i = 0, map.height - 1, 1 do
                    if i ~= y and EnGetCombatUnit(x, i) then dv = dv + (i < y and 1 or -1) end
                end
                if map:PlaceCombatUnit(s, x, y + (dv > 0 and 1 or -1)) then
                    s.status = STATUS.Move
                    return
                end
            elseif y > by then
                local dispersion = true
                for i = by, y - 1, 1 do
                    if EnGetCombatUnit(x, i) == nil then
                        dispersion = false
                        break
                    end
                end
                if dispersion then
                    if map:PlaceCombatUnit(s, x, y + 1) then
                        s.status = STATUS.Move
                        return
                    end
                    if map.random:NextInt(0, 100) < 50 then
                        s.status = STATUS.Think
                        return
                    end
                end
            else
                local dispersion = true
                for i = y + 1, by, 1 do
                    if EnGetCombatUnit(x, i) == nil then
                        dispersion = false
                        break
                    end
                end
                if dispersion then
                    if map:PlaceCombatUnit(s, x, y - 1) then
                        s.status = STATUS.Move
                        return
                    end
                    if map.random:NextInt(0, 100) < 50 then
                        s.status = STATUS.Think
                        return
                    end
                end
            end
        end

        --敌将前后2格
        if B_Math.abs(bx - rx) > 1 and MoveToPos(s, rx + rival.direction * 2, ry) then return end
        if MoveToPos(s, rx - rival.direction * 2, ry) then return end

        --围攻敌将
        if MoveToPos(s, rx, ry) then return end

        if info.force == isAtk then
            --我方兵锋正盛
            if map:PlaceCombatUnit(s, x + direction, y) then
                s.status = STATUS.Move
                return
            end 
        end
    end

    if map.random:NextInt(0, 100) < 10 then
        var = 0
        for i = 0, map.height - 1, 1 do
            if i ~= y and EnGetCombatUnit(x, i) then
                var = var + (i < y and 1 or -1)
            end
        end
        if var ~= 0 and map:PlaceCombatUnit(s, x, y + (var > 0 and 1 or -1)) then
            s.status = STATUS.Move
            return
        end
    end

    if map:PlaceCombatUnit(s, x + direction, y) then
        s.status = STATUS.Move
        return
    end

    if map.random:NextInt(0, 100) < 50 then
        if map:PlaceCombatUnit(s, x, y + 1) then
            s.status = STATUS.Move
            return
        end
        if map:PlaceCombatUnit(s, x, y - 1) then
            s.status = STATUS.Move
            return
        end
    else
        if map:PlaceCombatUnit(s, x, y - 1) then
            s.status = STATUS.Move
            return
        end
        if map:PlaceCombatUnit(s, x, y + 1) then
            s.status = STATUS.Move
            return
        end
    end

    s.status = STATUS.Think
end
--思考行为
function _so.Think(s)
    local bufs = s.buffs
    if GetBuffsAtt(bufs, BD_AID.Stop) > 0 then return end
    s.actionTime = 0
    if s.Arrived < 1 then
        s.status = STATUS.Move
        return
    end
    local cmd = s.isAtk and s.map.atkArmCmd or s.map.defArmCmd
    if cmd == BAT_CMD.Wait then
        if GetBuffsAtt(bufs, BD_AID.Fear) > 0 then SoldierTetreat(s) --恐惧
        elseif GetBuffsAtt(bufs, BD_AID.FF) > 0 then SoldierAttack(s) --逼战
        elseif not ToAttackStatus(s) then s.status = STATUS.Think end
        return
    end
    if cmd == BAT_CMD.Attack then
        if GetBuffsAtt(bufs, BD_AID.Fear) > 0 then SoldierTetreat(s) --恐惧
        else SoldierAttack(s) end
        return
    end
    if cmd == BAT_CMD.Retreat then
        if GetBuffsAtt(bufs, BD_AID.FF) > 0 then SoldierAttack(s) --逼战
        else SoldierTetreat(s) end
        return
    end
end
--移动
function _so.Move(s)
    local ms = s.MoveSpeed
    if ms <= 0 then return end

    s.lastMoveTime = s.map.time
    local pos = s.pos
    local dire = B_Vector(s.x - pos.x, s.y - pos.y)
    local delta = ms * s.map.deltaTime

    if s.lastX ~= s.x then s.direction = s.lastX > s.x and -1 or 1 end

    if dire.magnitude > delta then
        B_Vector.Normalize(dire)
        pos:Set(pos.x + dire.x * delta, pos.y + dire.y * delta)
    else
        pos:Set(s.x, s.y)
        s.status = STATUS.Think
    end
end
--攻击
function _so.Attack(s)
    local atkSpeed = s.MSPA
    if s.actionTime == 0 then
        local target = s:GetMeleeEnemy(s.direction)
        if target then
            s.actionTime = s.map.deltaMillisecond
            s:AddEvent(BE_Type.Attack)
            return
        end
        target = s:GetMeleeEnemy(-s.direction)
        if target then
            s.actionTime = s.map.deltaMillisecond
            s.direction = -s.direction
            s:AddEvent(BE_Type.Attack)
            return
        end
        if IsCasterSoldier(s) and s.nextShotTime < s.map.time then
            if FrontFirstEnemy(s) then
                s.actionTime = s.map.deltaMillisecond
                s:AddEvent(BE_Type.Attack)
                return
            elseif BackFirstEnemy(s) then
                s.actionTime = s.map.deltaMillisecond
                s.direction = -s.direction
                s:AddEvent(BE_Type.Attack)
                return
            end
        end
    elseif s.actionTime < atkSpeed then
        local ap = B_Math.modf(atkSpeed * 0.7)
        local flag = s.actionTime < ap
        s.actionTime = s.actionTime + s.map.deltaMillisecond
        if flag and s.actionTime >= ap then
            local target = s:GetMeleeEnemy(s.direction)
            if target then
                s:StrengthDPS(target)
            elseif IsCasterSoldier(s) then
                BD_Arrow(s, (s.sn == 4 or s.sn == 6) and "arrow" or (s.sn == 7 and "fireball" or nil))
            end
        end
        return
    else
        NextShotTime(s)
    end
    s.status = STATUS.Think
end
--死亡时
local cnt = 0
function _so.OnDead(s)
    _base.OnDead(s)
    if s.map.result == 0 then s.belong:SetTP(-1) end
end
--endregion

--region 数据部分

--属性
local _get =
{
    --武力
    Strength = function(s)
        CheckCapChange(s)
        if s.attChanged[BD_AID.Str] then
            s.attChanged[BD_AID.Str] = false
            local b = s.belong
            s.str = B_Math.max(B_Math.ceil(B_Math.ceil(b.Cap * (s.baseAtt[1] * 0.0001)) * (1 + (b.soldierBonus[1] + b:GetBuffAtt(BD_AID.Morale) + GetBuffsAtt(s.buffs, BD_AID.Str)) * 0.01)), 0)
        end
        return s.str
    end,
    --最大HP
    MaxHP = function(s)
        CheckCapChange(s)
        if s.attChanged[BD_AID.HP] then
            s.attChanged[BD_AID.HP] = false
            local b = s.belong
            s.maxHP = B_Math.max(B_Math.ceil(B_Math.ceil(b.Cap * (s.baseAtt[2] * 0.0001)) * (1 + (b.soldierBonus[2] + b:GetBuffAtt(BD_AID.Morale) + GetBuffsAtt(s.buffs, BD_AID.HP)) * 0.01)), 1)
        end
        return s.maxHP
    end,
    --当前HP
    HP = function(s) return B_Math.ceil(s.MaxHP * s.hp) end,
    --暴击几率(万分比)
    Crit = function(s)
        if s.attChanged[BD_AID.Crit] then
            s.attChanged[BD_AID.Crit] = false
            s.crit = B_Math.max(s.belong.soldierBonus[3] + GetBuffsAtt(s.buffs, BD_AID.Crit) * 100 + s.baseAtt[3], 0)
        end
        return s.crit
    end,
    --暴击伤害
    CritDmg = function(s)
        if s.attChanged[BD_AID.CritDmg] then
            s.attChanged[BD_AID.CritDmg] = false
            s.critDmg = B_Math.max(BD_Const.BASE_CRIT_DMG + s.belong.soldierBonus[4] + GetBuffsAtt(s.buffs, BD_AID.CritDmg), 0)
        end
        return s.critDmg
    end,
    --当前命中(万分比)
    Acc = function(s)
        --致盲状态
        if s.buffs.isBlind then return 0 end
        if s.attChanged[BD_AID.Acc] then
            s.attChanged[BD_AID.Acc] = false
            s.acc = B_Math.max(s.belong.soldierBonus[5] + GetBuffsAtt(s.buffs, BD_AID.Acc) * 100 + s.baseAtt[4], 0)
        end
        return s.acc
    end,
    --当前闪避(万分比)
    Dodge = function(s)
        if s.attChanged[BD_AID.Dodge] then
            s.attChanged[BD_AID.Dodge] = false
            local b = s.belong
            local v = GetBuffsAtt(s.buffs, BD_AID.Dodge)
            if v > 0 then
                s.dodge = v * 100 + B_Math.min(b.soldierBonus[6] * 100 + s.baseAtt[5], b.lmtDodge.value * 100)
            else
                s.dodge = B_Math.min((b.soldierBonus[6] + v) * 100 + s.baseAtt[5], b.lmtDodge.value * 100)
            end
        end
        return s.dodge
    end,
    --技能闪避(万分比)
    SDodge = function(s)
        if s.attChanged[BD_AID.SDodge] then
            s.attChanged[BD_AID.SDodge] = false
            local b = s.belong
            local v = GetBuffsAtt(s.buffs, BD_AID.SDodge)
            if v > 0 then
                s.sdodge = (v + B_Math.min(b.soldierBonus[7], b.lmtSDodge.value)) * 100
            else
                s.sdodge = B_Math.min(b.soldierBonus[7] + v, b.lmtSDodge.value) * 100
            end
        end
        return s.sdodge
    end,
    --移动速度 u/s
    MoveSpeed = function(s)
        --禁锢状态
        if s.buffs.isFixed then return 0 end
        if s.attChanged[BD_AID.MoveSpeed] then
            s.attChanged[BD_AID.MoveSpeed] = false
            s.moveSpeed = B_Math.clamp(BD_Const.BASE_MOVE_SPEED_UNIT + BD_Const.BASE_MOVE_SPEED_UNIT * (s.belong.soldierBonus[8] + GetBuffsAtt(s.buffs, BD_AID.MoveSpeed)) * 0.01, 0, s.map.battle.lmtMS.value)
        end
        return (s.isAtk and s.map.atkArmCmd or s.map.defArmCmd) == BAT_CMD.Retreat and s.moveSpeed * 0.7 or s.moveSpeed
    end,
    --当前攻击间隔 毫秒/次
    MSPA = function(s)
        if s.attChanged[BD_AID.MSPA] then
            s.attChanged[BD_AID.MSPA] = false
            s.mspa = B_Math.max(B_Math.ceil(B_Math.max(BD_Const.BASE_MSPA * (1 / (1 + (s.belong.soldierBonus[9] + GetBuffsAtt(s.buffs, BD_AID.MSPA)) * 0.01)), 100)), s.map.battle.lmtMSPA.value)
        end
        return s.mspa
    end,
    --最终输出
    Dmg = function(s)
        CheckCapChange(s)
        if s.dmg < 0 then
            local dmg = s.Strength * s.map.battle.fStr.value * 0.01
            s.dmg = B_Math.ceil(dmg + dmg * s.CPD * 0.01)
        end
        return s.dmg
    end,
    --造成武力伤害增减
    CPD = function(s)
        if s.attChanged[BD_AID.CPD] then
            s.attChanged[BD_AID.CPD] = false
            s.cpd = s.belong.soldierBonus[10] + GetBuffsAtt(s.buffs, BD_AID.CPD)
        end
        return s.cpd
    end,
    --受到武力伤害增减
    SPD = function(s)
        if s.attChanged[BD_AID.SPD] then
            s.attChanged[BD_AID.SPD] = false
            local b = s.belong
            local v = GetBuffsAtt(s.buffs, BD_AID.SPD)
            if v < 0 then
                v = v + B_Math.max(b.soldierBonus[11], b.lmtSPD.value)
            else
                v = B_Math.max(v + b.soldierBonus[11], b.lmtSPD.value)
            end
            s.spd = v < -100 and -100 or v
        end
        return s.spd
    end,
    --受到技能伤害增减
    SSD = function(s)
        if s.attChanged[BD_AID.SSD] then
            s.attChanged[BD_AID.SSD] = false
            local b = s.belong
            local v = GetBuffsAtt(s.buffs, BD_AID.SSD)
            if v < 0 then
                v = v + B_Math.max(b.soldierBonus[12], b.lmtSSD.value)
            else
                v = B_Math.max(v + b.soldierBonus[12], b.lmtSSD.value)
            end
            s.ssd = v < -100 and -100 or v
        end
        return s.ssd
    end,

    --满血
    isFullHP = function(s) return s.hp >= 1 end,

    --是否无敌
    isGod = function(s) return GetBuffsAtt(s.buffs, BD_AID.God) > 0 end,
    --是否停止
    isStop = function(s) return GetBuffsAtt(s.buffs, BD_AID.Stop) > 0 end,

    DebugName = function(s) return (s.isAtk and "[我方士兵-" or "[敌方士兵-") ..s.id.."]" end,
}

--初始化属性
local function InitAttrib(s)
    s.dmg = -1
    for i = 1, BD_AID.SIZE do s.attChanged[i] = true end
end
--设置所属武将
local function SetBelong(s, hero)
    if s.belong == hero then return end
    s.belong = hero
    s.isAtk = hero.isAtk
    s.lastCap = hero.Cap
    InitAttrib(s)
end
--设置生命值
--v : 值
--direct : 为true表示设为给定值，否则为增量值
local function SetHP(s, v, direct)
    if s.map.result == 0 then
        local max = s.MaxHP
        v = B_Math.clamp(direct and v or (max * s.hp + v), 0, max)
        s.hp = v / max
        if v <= 0 then
            s.actionTime = 0
            s:Dead()
        end
    end
end

function _so.InitData(s, hero)
    s.buffs:Clear()
    SetBelong(s, hero)
    s.belong = hero
    s.direction = s.isAtk and 1 or -1
    s.sn = hero.dat.arm.value
    s.baseAtt = hero.soldierAtt
    s.hp = 1
    s.name = "sob_" .. s.sn .. "_"
    NextShotTime(s)
end
--[Comment]
--设置所属武将
_so.SetBelong = SetBelong
--[Comment]
--设置生命值
_so.SetHP = SetHP

function _so.OnEndUpdate(s)
    --s.buffs:Update()
    BuffsUpdate(s.buffs)
end

function _so.MarkAttChanged(s, aid)
    s.attChanged[aid] = true
    if aid == BD_AID.Str or aid == BD_AID.CPD then
        s.dmg = -1
    end
end

function _so.LogData() end

--增加一个BUFF
--buf : BD_Buff
--returns : BD_BuffSlot
function _so.AddBuff(s, buf)
    local slot = s.buffs:AddBuff(buf)
    if buf.isStop or buf.isFixed then s.status = STATUS.Think end
    return slot
end
--重置BUF
--sn : buf sn
--returns : 是否重置成功
function _so.ResetBuff(s, sn) return s.buffs:ResetBuff(sn) end
--移除指定编号的BUFF
--sn : buf sn
function _so.RemoveBuff(s, sn) s.buffs:Remove(sn) end
--移除所有BUFF
function _so.RemoveAllBuff(s) s.buffs:Clear(); InitAttrib(s) end
--获取指定SN的buf，若没有则为null
function _so.GetBuff(s, sn) return s.buffs:GetBuff(sn) end
--单位是否包含给定编号的BUF
function _so.ContainsBuff(s, sn) return s.buffs:Contains(sn) end

--收到输出
function _so.SufferDPS(s, dps)
    if dps.source == nil or s.map.result ~= 0 then return false end
    if dps.type == BD_DPS_TYPE.Strength then
        --武力伤害
        if isDebug then
            if dps.source.isAtk == s.isAtk or GetBuffsAtt(s.buffs, BD_AID.God) > 0 then return false end
            if dps.isMiss then
                --未命中
                s:AddEvent(BE_Type.DPS, dps)
                return false
            end
            if dps.dodge and s.Dodge > s.map.random:NextInt(0, 10000) then
                --闪
                s:AddEvent(BE_Type.DPS, dps)
                return false
            end
            dps:RemoveTag(BD_DPS_TAG.Dodge)
            s:AddEvent(BE_Type.DPS, dps)
        else
            if dps.source.isAtk == s.isAtk or dps.isMiss or GetBuffsAtt(s.buffs, BD_AID.God) > 0 or (dps.dodge and s.SDodge > s.map.random:NextInt(0, 10000)) then return false end
        end
        local v = dps.value
        if v > 0 then
            v = B_Math.max(1, B_Math.ceil(v + v * s.SPD * 0.01))
            SetHP(s, -v)
        end
        return true
    elseif dps.type == BD_DPS_TYPE.Skill then
        --技能伤害
        if isDebug then
            if dps.source.isAtk == s.isAtk or GetBuffsAtt(s.buffs, BD_AID.God) > 0 then return false end
            if dps.dodge and s.SDodge > s.map.random:NextInt(0, 10000) then
                --闪
                s:AddEvent(BE_Type.DPS, dps)
                return false
            end
            dps:RemoveTag(BD_DPS_TAG.Dodge)
            s:AddEvent(BE_Type.DPS, dps)
        else
            if dps.source.isAtk == s.isAtk or GetBuffsAtt(s.buffs, BD_AID.God) > 0 or (dps.dodge and s.SDodge > s.map.random:NextInt(0, 10000)) then return false end
        end
        local v = dps.value
        if v > 0 then
            v = B_Math.max(1, B_Math.ceil(v + v * s.SSD * 0.01) + (dps.puncture > 0 and dps.puncture or 0))
            SetHP(s, -v)
        end
        return true
    elseif dps.type == BD_DPS_TYPE.Cure then
        --治疗
        if dps.value > 0 then
            SetHP(s, dps.value)
            if isDebug then s:AddEvent(BE_Type.DPS, dps) end
        end
        return true
    elseif dps.type == BD_DPS_TYPE.Real then
        --真实伤害
        if dps.value < 1 or dps.source.isAtk == s.isAtk or GetBuffsAtt(s.buffs, BD_AID.God) > 0 then return false end
        SetHP(s, -dps.value)
        if isDebug then s:AddEvent(BE_Type.DPS, dps) end
        return true
    end
end

--endregion

--构造函数
local function _ctor(t, map, x, y)
    t = setmetatable(_base(map, x, y), _so)
    t.nextShotTime = 0
    t.buffs = B_Buffs(t)
    t.attChanged = BD_AID.CreateChangeTable()
    t.lastCap = 0
    t.dmg = -1
--    t.str = 0
--    t.hp = 0
--    t.maxHP = 0
--    t.crit = 0
--    t.critDmg = 0
--    t.acc = 0
--    t.dodge = 0
--    t.sdodge = 0
--    t.moveSpeed = 0
--    t.mspa = 0
--    t.cpd = 0
--    t.spd = 0
--    t.ssd = 0
    return t
end

--继承扩展
_base:extend(_ctor, _get, nil, _so)
--[Comment]
--战场战斗单位-士兵
QYBattle.BD_Soldier = _so