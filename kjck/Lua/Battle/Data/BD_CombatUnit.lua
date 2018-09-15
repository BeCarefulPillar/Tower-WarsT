
local BD_Const = QYBattle.BD_Const
local B_Vector = QYBattle.B_Vector
local B_Math = QYBattle.B_Math
local BD_DPS = QYBattle.BD_DPS
local BD_ANM = QYBattle.BD_ANM
local GetCombatUnit = QYBattle.BD_Field.GetCombatUnit

local _base = QYBattle.BD_Unit

--单位状态
local STATUS =
{
    Think = 0,
    Move = 1,
    Attack = 2,
    Skill = 3,
    Dead = 4,
}

--是否死亡
local function isDead(c) return not c.isAlive or c.HP <= 0 end
--检测给定的单位是否是敌人
local function CheckEnemy(c, u) return u and u.isAtk ~= c.isAtk and u.isAlive and u.HP > 0 end

--属性器
local _get = 
{
    --所属势力
--    isAtk = function(c) return false end,
    --是否再地图中
    inMap = function(c) return GetCombatUnit(c.map, c.x, c.y) == c end,
    --单位的到达程度
    Arrived = function(c) return 1 - B_Math.max(B_Math.abs(c.pos.x - c.x), B_Math.abs(c.pos.y - c.y)) end,

    --移动速度（格/秒）
    MoveSpeed = function(c) return BD_Const.BASE_MOVE_SPEED_UNIT end,
    --武力命中
    Acc = function(c) return BD_Const.BASE_ACC end,
    --武力闪避
    Dodge = function(c) return 0 end,
    --SDodge
    SDodge = function(c) return 0 end,
    --攻击速度（毫秒/次）
    MSPA = function(c) return BD_Const.BASE_MSPA end,
    --护盾
    Shield = function(c) return 0 end,
    --生命
    HP = function(c) return 0 end,
    --武力伤害
    Dmg = function(c) return 0 end,
    --武力暴击几率
    Crit = function(c) return BD_Const.BASE_CRIT end,
    --技能暴击几率
    SCrit = function(c) return 0 end,
    --暴击伤害倍率
    CritDmg = function(c) return BD_Const.BASE_CRIT_DMG end,
    --造成武力伤害增减
    CPD = function(c) return 0 end,
    --造成技能伤害增加
    CSD = function(c) return 0 end,
    --受到武力伤害增加
    SPD = function(c) return 0 end,
    --受到技能伤害增加
    SSD = function(c) return 0 end,

    --是否已死亡
    isDead = isDead,
    --是否无敌
    isGod = function(c) return false end,
    --是否停止
    isStop = function(c) return false end,

    --前面的敌人
    FrontEnemy = function(c)
        local target = GetCombatUnit(c.map, c.x + c.direction, c.y)
        return CheckEnemy(c, target) and target or nil
    end,
    --背后的敌人
    BackEnemy = function(c)
        local target = GetCombatUnit(c.map, c.x - c.direction, c.y)
        return CheckEnemy(c, target) and target or nil
    end,
    --周围是否有敌人
    AroundEnemy = function(c)
        local x, y = c.x, c.y
        local target = GetCombatUnit(c.map, x, y + 1)
        if CheckEnemy(c, target) then return true end
        target = GetCombatUnit(c.map, x, y - 1)
        if CheckEnemy(c, target) then return true end
        target = GetCombatUnit(c.map, x + 1, y)
        if CheckEnemy(c, target) then return true end
        target = GetCombatUnit(c.map, x - 1, y)
        if CheckEnemy(c, target) then return true end
    end,

    DebugName = function(c) return (c.isAtk and "[我军-" or "[敌军-") .. c.id .. "]" end,
}

local _cunit =
{
    --[Comment]
    --单位状态
    STATUS = STATUS
}

function _cunit.OnDead(c)
    c.status = STATUS.Dead
    c.map:RemoveCombatUnit(c)
    c.lastX, c.lastY = -1, -1
    c.x, c.y = -1, -1
end

--[Comment]
--设置X,Y位置，用于 [BattleMap.PlaceCombatUnit]
function _cunit.SetPos(c, x, y)
    if GetCombatUnit(c.map, x, y) == c then
        c.lastX, c.lastY = c.x, c.y
        c.x, c.y = x, y
    end
end
--[Comment]
--立即配置实际位置到坐标位置
function _cunit.ApplyPos(c)
    c.pos:Set(c.x, c.y)
end
--[Comment]
--更新循环
function _cunit.Update(c)
    local var = c.map
    if var.result ~= 0 or GetCombatUnit(var, c.x, c.y) ~= c then
        c.status = STATUS.Think
        return
    end
    var = c.status
    if var == STATUS.Think then c:Think()
    elseif var == STATUS.Move then c:Move()
    elseif var == STATUS.Attack then c:Attack()
    elseif var == STATUS.Skill then c:OnCastSkill()
    end
    c:OnEndUpdate()
end

--在delta毫秒之前没有移动过
--dt : 间隔时间
function _cunit.NotMovedInPeriod(c, dt) return c.map.time - c.lastMoveTime > dt end
--对给定单位进行物理伤害
function _cunit.StrengthDPS(c, target, isRange)
    local dps = BD_DPS(c, BD_DPS.Type.Strength, 0, BD_DPS.Tag.Dodge)
    local rnd = c.map.random
    --判断命中
    if (isRange and c.Acc - 5000 or c.Acc) > rnd:NextInt(0, 10000) then
        --判读暴击
        if c.Crit > rnd:NextInt(0, 10000) then
            dps:AddTag(BD_DPS.Tag.Crit)
            dps.value = B_Math.ceil(c.Dmg * c.CritDmg * 0.01)
        else
            dps.value = c.Dmg
        end
    else
        --未命中
        dps:AddTag(BD_DPS.Tag.Miss)
    end
    c:OnCreateDps(target, dps)
    if target:SufferDPS(dps) then
        c:OnCreatedDps(target, dps)
        return true
    end
    return false
end
--对给定单位进行技能伤害
function _cunit.SkillDPS(c, target, val, isCrit, canDodge)
    local dps = BD_DPS(c, BD_DPS.Type.Skill, val)
    if isCrit or c.SCrit > c.map.random:NextInt(0, 10000) then
        --暴击
        dps:AddTag(BD_DPS.Tag.Crit)
        dps.value = B_Math.ceil(val * c.CritDmg * 0.01)
    end
    if canDodge == nil or canDodge then dps:AddTag(BD_DPS.Tag.Dodge) end
    dps.puncture = c:GetExtraAtt(BD_ANM.CC)
    c:OnCreateDps(target, dps)
    if target:SufferDPS(dps) then
        c:OnCreatedDps(target, dps)
        return true
    end
    return false
end
--对给定单位进行治疗
function _cunit.CureDPS(c, target, val)
    local dps = BD_DPS(c, BD_DPS.Type.Cure, val)
    c:OnCreateDps(target, dps)
    if target:SufferDPS(dps) then
        c:OnCreatedDps(target, dps)
        return true
    end
    return false
end
--对给定单位进行真实伤害
function _cunit.RealDPS(c, target, val)
    local dps = BD_DPS(c, BD_DPS.Type.Real, val)
    c:OnCreateDps(target, dps)
    if target:SufferDPS(dps) then
        c:OnCreatedDps(target, dps)
        return true
    end
    return false
end

--检测给定的单位是否是敌人
_cunit.CheckEnemy = CheckEnemy

--前方的第一个敌人
function _cunit.FrontFirstEnemy(c)
    local h = c.map.height
    if c.y >= 0 and c.y < h then
        local us = c.map.combatUnits
        if c.direction < 0 then
            for i = (c.x - 1) * h + c.y + 1, 1, -h do
                if CheckEnemy(c, us[i]) then return us[i] end
            end
        else
            for i = (c.x + 1) * h + c.y + 1, c.map.maxCombatUnit, h do
                if CheckEnemy(c, us[i]) then return us[i] end
            end
        end
    end
end
--后面的第一个敌人
function _cunit.BackFirstEnemy(c)
    local h = c.map.height
    if c.y >= 0 and c.y < h then
        local us = c.map.combatUnits
        if c.direction > 0 then
            for i = (c.x - 1) * h + c.y + 1, 1, -h do
                if CheckEnemy(c, us[i]) then return us[i] end
            end
        else
            for i = (c.x + 1) * h + c.y + 1, c.map.maxCombatUnit, h do
                if CheckEnemy(c, us[i]) then return us[i] end
            end
        end
    end
end
--视野内是否有敌人
function _cunit.SeeEnemy(c)
    local map = c.map
    local sp = BD_Const.FIGHT_SPACE
    local clamp = B_Math.clamp
    local minx = clamp(c.x - sp, 0, map.width)
    local maxx = clamp(c.x + sp, 0, map.width) - 1
    local miny = clamp(c.y - sp, 0, map.height)
    local maxy = clamp(c.y + sp, 0, map.height) - 1
    for x = minx, maxx, 1 do
        for y = miny, maxy, 1 do
            if CheckEnemy(c, GetCombatUnit(map, x, y)) then return true end
        end
    end
end
--同势力的单位是否都在我前面
function _cunit.UnitAllInFront(c)
    local isAtk = c.isAtk
    local x = c.x
    for _, u in pairs(c.map.combatUnits) do
        if u ~= c and u.isAtk == isAtk then
            if c.direction > 0 then
                if u.x < x then return false end
            else
                if u.x > x then return false end
            end
        end
    end
    return true
end
--获取近战敌人
--dire : 方向
--isExpect : 预判
function _cunit.GetMeleeEnemy(c, dire, isExpect)
    local tx, ty = c.x + (dire < 0 and -1 or 1), c.y
    local target = c.map:GetArrivedUnit(tx, ty)
    if CheckEnemy(c, target) then
        if tx == target.x and ty == target.y then return target end
        if target.isStop or target.MoveSpeed <= 0 or B_Vector.Distance(target.pos, c.pos) < (isExpect == false and 1.6 or 0.8) then
            return target
        end
    end
end

--region 子级重写函数
--循环
function _cunit.OnEndUpdate(c) end
--行为:思考
function _cunit.Think(c) c.actionTime = 0 end
--行为:移动
function _cunit.Move(c) c.status = STATUS.Think end
--行为:攻击
function _cunit.Attack(c) c.status = STATUS.Think end
--行为:释放技能时
function _cunit.OnCastSkill(c) c.status = STATUS.Think end
--当创建DPS时
--target : BD_CombatUnit
--dps : BD_DPS
--returns : BD_DPS
function _cunit.OnCreateDps(c, target, dps) end
--创建DPS之后
--target : BD_CombatUnit
--dps : BD_DPS
function _cunit.OnCreatedDps(c, target, dps) end
--受到输出时
--dps : BD_DPS
--returns : 是否成功
function _cunit.SufferDPS(c, dps) return false end
--受到能量
function _cunit.SufferEnergy(c, energy) return false end
--获取扩展属性值
--mark : BD_ANM
--returns : 属性值
function _cunit.GetExtraAtt(c, mark) return 0 end
--将属性标记为改变
--aid : BD_AID
function _cunit.MarkAttChanged(c, aid) end
--添加一个BUFF，返回BD_BuffSlot (为nil表示添加不成功)
--buf : BD_Buff
function _cunit.AddBuff(c, buf) end
--重置指定SN的buf
--returns : 是否返回成功
function _cunit.ResetBuff(c, sn) return false end
--移除指定SN的buf
function _cunit.RemoveBuff(c, sn) end
--获取指定SN的buf
--returns : BD_BuffSlot
function _cunit.GetBuff(c, sn) return nil end
--是否有指定SN的Buff
--returns : 是否有
function _cunit.ContainsBuff(c, sn) return false end
--清除所有BUF
function _cunit.RemoveAllBuff(c, sn) end

--endregion

local function _ctor(t, map, x, y)
    t = setmetatable(_base(map), _cunit)
    if not map:PlaceCombatUnit(t, x, y) then
        x, y = -1, -1
    end
    t.lastX, t.x = x, x
    t.lastY, t.y = y, y
    t.pos:Set(x, y)
    t.direction = 1
    t.status = STATUS.Think
    t.actionTime = 0
    t.lastMoveTime = 0
    return t
end


--派生
_base:extend(_ctor, _get, nil, _cunit)
--[Comment]
--战场战斗单位
QYBattle.BD_CombatUnit = _cunit