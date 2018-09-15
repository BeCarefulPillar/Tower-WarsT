
local insert = table.insert
local remove = table.remove
local ipairs = ipairs
local pairs = pairs
local getmetatable = getmetatable

local BD_Const = QYBattle.BD_Const
local B_Math = QYBattle.B_Math
local B_Vector = QYBattle.B_Vector
local BD_Buff = QYBattle.BD_Buff
local BD_AID = QYBattle.BD_AID
local BD_Soldier = QYBattle.BD_Soldier
local BD_Hero = QYBattle.BD_Hero

local _base = QYBattle.BD_Unit

local LifeTime = 30000

local _skc = { }
local _func = { }

--成员变量说明
--[[
lifeTime int            生命到期时间
hero BD_Hero            所属武将
dat EnSkc               技能数据
sn int                  技能sn
isAtk bool              技能所属势力
step int                当前步骤
wait int                等待到期时间
action function         当前技能函数

dps int                 输出值
vals table              附加扩展值
units table             子单位集合

list table              缓存的作战单位集合
dicTime table           缓存的时间标记
dicMark table           缓存的标记

buff BD_Buff            生成的Buff
buff2 BD_Buff           生成的Buff
buffs table             生成的Buff

hitLst table            缓存的击中单位
eftLst table            缓存的影响单位

func function           缓存的函数
func2 function          缓存的函数
]]

--延迟tm毫秒后完成该技能
local function Dead(s, tm)
    if tm and tm > 0 then
        s.lifeTime = tm
    else
        s:Dead()
    end
end

--构造
--hero : BD_Hero
--idx : 技能索引
local function _ctor(t, hero, idx)
    local dat = hero.skill[idx]
    if dat == nil or not hero:SkillCDReady(idx) then return end
    local var = dat.sp.value
    if hero.SP < var then return end

    hero:ResetSkillCD()
    hero:SetSP(-var)
    var = dat.sn.value

    t = setmetatable(_base(hero.map), _skc)
    t.hero = hero
    t.dat = dat
    t.isAtk = hero.isAtk
    t.step = 0
    t.wait = 0
    t.dps = 0
    t.sn = var
    t.maxLifeTime = LifeTime
    t.name = "skc_"..var
    if t.map.hasEvent then t.hitLst = { } end
    
    --五行-水
    if dat.fesn == BD_Const.FE_WATER and dat.feval > 0 and t.map.random:NextInt(0, 10000) < 3500  then
        hero:SufferEnergy(dat.feval)
    end

    var = rawget(_skc, var)
    if var then
        Dead(t, LifeTime)
        t.action = var
    else
        t:Dead()
    end
    return t
end

function _skc.Update(s)
    if s.action then
        if s.wait > 0 then
            s.wait = s.wait - s.map.deltaMillisecond
        else
            s:action()
        end
    end
    if s.lifeTime > 0 then
        s.lifeTime = s.lifeTime - s.map.deltaMillisecond
    else
        s:Dead()
    end
end

function _skc.OnDead(s)
    s.step = 255
    s.dps = 0
    s.wait = 0
    s.action = nil
    s.func, s.func2 = nil, nil
    s.list = nil
    s.dicTime, s.dicMark = nil, nil
end

--获取当前为止被技能击中的目标
function _skc.GetHitTarget(s)
    local lst = s.hitLst
    if lst and #lst > 0 then
        s.hitLst = { }
        return lst
    end
end

--获取当前为止受到影响的目标
function _skc.GetEffectTarget(s)
    local lst = s.eftLst
    if lst and #lst > 0 then
        s.eftLst = { }
        return lst
    end
end

--继承扩展
_base:extend(_ctor, { unitQty = function(s) return s.units and #s.units or 0 end }, nil, _skc)
--[Comment]
--战场武将技
QYBattle.BD_SKC = _skc

--等待tm毫秒
local function WaitForTime(s, tm)
    s.wait = tm
end
--击中目标
local function HitTarget(s, t)
    if s.hitLst then
        insert(s.hitLst, t)
    end
end
--技能影响目标
local function EffectTarget(s, t)
    if t and s.eftLst then
        insert(s.eftLst, t)
    end
end

local function CheckEnemy(s, t) return t and t.isAtk ~= s.isAtk and not t.isDead end

local function CheckEnemyWithMark(s, t)
    if CheckEnemy(s, t) then
        if s.dicMark[t] then return false end
        s.dicMark[t] = true
        return true
    end
    return false
end
local function CheckEnemyWithMarkIdx(s, t, idx)
    if CheckEnemy(s, t) then
        s = s.dicMark
        local tb = s[t]
        if tb then
            if tb[idx] then return false end
        else
            tb = { }
            s[t] = tb
        end
        tb[idx] = true
        return true
    end
    return false
end

--获取指定区域
local function GetRange(s, x, y)
    local rx, ry = s.dat.rangeX.value, s.dat.rangeY.value
    local xMin, yMin = x - B_Math.floor(rx / 2), y - B_Math.floor(ry / 2)
    local xMax, yMax = xMin + rx - 1, yMin + ry - 1
    local var = s.map.width
    if xMin < 0 then xMin, xMax = 0, B_Math.min(xMax - xMin, var - 1)
    elseif xMax >= var then xMin, xMax = B_Math.max(0, xMin - (xMax - var + 1)), var - 1 end
    var = s.map.height
    if yMin < 0 then yMin, yMax = 0, B_Math.min(yMax - yMin, var - 1)
    elseif yMax >= var then yMin, yMax = B_Math.max(0, yMin - (yMax - var + 1)), var - 1 end
    return xMin, yMin, xMax, yMax
end

--获取敌军密集区域
local function GetEnemyDenseRange(s) return GetRange(s, s.map:SearchUnitFocus(not s.isAtk)) end

local function GetDmg(s)
    local h, dat = s.hero, s.dat
    local v = h.CSD
    if dat.fesn == BD_Const.FE_METAL then v = v + dat.feval end
    return dat:GetDps(h.Str, h.Wis, h.Cap) * (1 + v * 0.01)
end

local function GetCure(s)
    local h, dat = s.hero, s.dat
    local v = dat:GetDps(h.Str, h.Wis, h.Cap)
    if dat.fesn == BD_Const.FE_WOOD then v = v + v * dat.feval * 0.01 end
    return v
end

local function GetEnergy(s)
    local h, dat = s.hero, s.dat
    local v = dat:GetDpsLow(h.Str, h.Wis, h.Cap)
    if dat.fesn == BD_Const.FE_WOOD then v = v + v * dat.feval * 0.01 end
    return v
end

local function ProDmg(s, dmg, sdmg)
    sdmg = sdmg ~= false and s.hero.CSD or s.hero.CPD
    s = s.dat
    if s.fesn == BD_Const.FE_METAL then sdmg = sdmg + s.feval end
    return sdmg ~= 0 and dmg + dmg * sdmg * 0.01 or dmg
end

local function ForceSetCasterPos(s, x, y)
    local t = s.map:GetCombatUnit(x, y)
    if t == s.hero then return true end
    if t and getmetatable(t) == BD_Soldier then
        t:SetHP(0, true)
        t:Dead()
    end
    return s.map:PlaceCombatUnit(s.hero, x, y)
end

--local function ClearList(lst) if lst then for i = #lst, 1, -1 do lst[i] = nil end end end

--生成多点伤害单位
--qty : 数量
--udx : 单位直径X
--udy : 单位直径Y
local function GenMultPointUnits(s, qty, udx, udy)
    if qty > 0 and udx > 0 and udy > 0 then
        local minX, minY, maxX, maxY = GetEnemyDenseRange(s)
        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        local lst = { }
        local var = minY + udy * 0.5 - 0.5
        for x = minX + udx * 0.5 - 0.5, maxX, udx do
            for y = var, maxY, udy do
                insert(lst, B_Vector(x, y)) -- 中心点
            end
        end
        local indef = #lst >= qty
        local dt = B_Math.floor(s.dat.keep.value / qty)
        local random = s.map.random
        local ridx
        var = { }
        for i = 1, qty do
            if #lst > 0 then
                ridx = math.clamp(random:NextInt(1, #lst), 1, #lst)
                var[i] =
                {
                    status = 1,
                    time = i > 1 and var[i - 1].time - random:NextInt(0, dt) or 0,
                    pos = lst[ridx],
                }
                if indef then remove(lst, ridx) end 
            end
        end
        s.units = var
        table.clear(lst)
        return minX, minY, maxX, maxY
    end
end

--失败的函数
_func.faild = function(trg) print("skc faild func") end
--[Comment]
--搜索攻击函数
--s, nm, hitLst, dmg
_func.dmg = function(s, nm, hitLst, dmg)
    if dmg and dmg > 0 then
        local h, m = s.hero, s.map
        local SkillDPS = h.SkillDPS
        if m.debug then
            if hitLst then
                return function(trg)
                    --伤害 日志 显示
                    if CheckEnemy(s, trg) and SkillDPS(h, trg, dmg) then
                        m:Log((nm or "").."对" .. trg.DebugName .. "造成<" .. dmg .. ">点伤害")
                        insert(s.hitLst, trg)
                    end
                end
            else
                --伤害 日志
                return function(trg)
                    if CheckEnemy(s, trg) and SkillDPS(h, trg, dmg) then m:Log((nm or "").."对" .. trg.DebugName .. "造成<" .. dmg .. ">点伤害") end
                end
            end
        elseif hitLst then
            --伤害 显示
            return function(trg)
                if CheckEnemy(s, trg) and SkillDPS(h, trg, dmg) then insert(s.hitLst, trg) end
            end
        else
            --伤害
            return function(trg) if CheckEnemy(s, trg) then SkillDPS(h, trg, dmg) end end
        end
    end
    return _func.faild
end
--[Comment]
--搜索+buff函数
--s, hitLst, buff
_func.buff = function(s, hitLst, buff)
    if buff then
        if hitLst then
            --BUFF 显示
            return function(trg)
                if CheckEnemy(s, trg) then
                    trg:AddBuff(buff)
                    insert(s.hitLst, trg)
                end
            end
        else
            --BUFF
            return function(trg) if CheckEnemy(s, trg) then trg:AddBuff(buff) end end
        end
    end
    return _func.faild
end
--[Comment]
--搜索攻击+buff函数
--s, nm, hitLst, dmg, buff
_func.dmg_buff = function(s, nm, hitLst, dmg, buff)
    if dmg and dmg > 0 and buff then
        local h, m = s.hero, s.map
        local SkillDPS = h.SkillDPS
        if m.debug then
            if hitLst then
                --伤害 BUFF 日志 显示
                return function(trg)
                    if CheckEnemy(s, trg) and SkillDPS(h, trg, dmg) then
                        m:Log((nm or "").."对" .. trg.DebugName .. "造成<" .. dmg .. ">点伤害")
                        trg:AddBuff(buff)
                        insert(s.hitLst, trg)
                    end
                end
            else
                --伤害 BUFF 日志
                return function(trg)
                    if CheckEnemy(s, trg) and SkillDPS(h, trg, dmg) then
                        m:Log((nm or "").."对" .. trg.DebugName .. "造成<" .. dmg .. ">点伤害")
                        trg:AddBuff(buff)
                    end
                end
            end
        elseif hitLst then
            --伤害 BUFF 显示
            return function(trg)
                if CheckEnemy(s, trg) and SkillDPS(h, trg, dmg) then
                    trg:AddBuff(buff)
                    insert(s.hitLst, trg)
                end
            end
        else
            --伤害 BUFF
            return function(trg)
                if CheckEnemy(s, trg) and SkillDPS(h, trg, dmg) then
                    trg:AddBuff(buff)
                end
            end
        end
    end
    return _func.faild
end
--[Comment]
--搜索范围状态+伤害(百鬼索命类)
--s, nm, hitLst, dmg, buff
_func.range_dmg_buff = function(s, nm, hitLst, dmg, buff)
    if buff then
        if dmg and dmg > 0 then
            local h, m = s.hero, s.map
            local SkillDPS = h.SkillDPS
            if m.debug then
                if hitLst then
                    --BUFF 伤害 日志 显示
                    return function(trg)
                        if CheckEnemy(s, trg) then
                            if SkillDPS(h, trg, dmg) then m:Log((nm or "").."对" .. trg.DebugName .. "造成<" .. dmg .. ">点伤害") end
                            trg:AddBuff(buff)
                            insert(s.hitLst, trg)
                        end
                    end
                else
                    --BUFF 伤害 日志
                    return function(trg)
                        if CheckEnemy(s, trg) then
                            if SkillDPS(h, trg, dmg) then m:Log((nm or "").."对" .. trg.DebugName .. "造成<" .. dmg .. ">点伤害") end
                            trg:AddBuff(buff)
                        end
                    end
                end
            elseif hitLst then
                --BUFF 伤害 显示
                return function(trg)
                    if CheckEnemy(s, trg) then
                        SkillDPS(h, trg, dmg)
                        trg:AddBuff(buff)
                        insert(s.hitLst, trg)
                    end
                end
            else
                --BUFF 伤害
                return function(trg)
                    if CheckEnemy(s, trg) then
                        SkillDPS(h, trg, dmg)
                        trg:AddBuff(buff)
                    end
                end
            end
        else
            return _func.buff(s, hitLst, buff)
        end
    end
    return _func.faild
end
--[Comment]
--搜索范围每秒时间标记状态+伤害
--s, nm, hitLst, dmg, buff
_func.tm_dmg_buf = function(s, nm, hitLst, dmg, buff)
    if dmg and dmg > 0 then
        local h, m, dicTime = s.hero, s.map, s.dicTime
        local SkillDPS = h.SkillDPS
        hitLst = hitLst and s.hitLst ~= nil
        if m.debug then
            return function(trg)
                if CheckEnemy(s, trg) and (dicTime[trg] or 0) <= m.time then
                    dicTime[trg] = m.time + 1000
                    if SkillDPS(h, trg, dmg) then
                        s.map:Log((nm or "") .. "对" .. trg.DebugName .. "造成<" .. dmg .. ">点伤害")
                        if buff then trg:AddBuff(buff) end
                        if hitLst then insert(s.hitLst, trg) end
                    end
                end
            end
        else
            return function(trg)
                if CheckEnemy(s, trg) and (dicTime[trg] or 0) <= m.time then
                    dicTime[trg] = m.time + 1000
                    if SkillDPS(h, trg, dmg) then
                        if buff then trg:AddBuff(buff) end
                        if hitLst then insert(s.hitLst, trg) end
                    end
                end
            end
        end
    end
    return _func.faild
end

--裂波斩
_skc[1] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        var = GetDmg(s)
        s.dps = B_Math.ceil(var)
        s.vals = { B_Math.ceil(var * s.dat:GetExtPercent(1)) }

        var = s.hero.isAtk and 1 or -1
        local v1 = 15 * B_Math.Deg2Rad
        local v2 = B_Math.sin(v1)
        v1 = B_Math.cos(v1) * var
        s.units =
        {
            {
                status = 1, speed = 5,
                pos = s.hero.pos:Clone(),
                direction = B_Vector(var, 0),
            },
            {
                status = 0,
                direction = B_Vector(v1, v2)
            },
            {
                status = 0,
                direction = B_Vector(v1, -v2)
            },
        }
        s.dicMark = { }
        s.step = 2
    elseif var == 2 then
        local units = s.units
        var = units[1]
        local d = s.map.deltaTime
        d, var.speed = var.speed * BD_Const.BASE_MOVE_SPEED_UNIT * s.map.deltaTime, B_Math.slerp(var.speed, 10, 13, d)

        local map = s.map
        local alive = false
        local trg

        for i = 1, 3 do
            var = units[i]
            if var.status == 1 then
                var.pos:AddMult(var.direction, d)
                trg = map:GetArrivedUnit(var.pos.x, var.pos.y)
                if CheckEnemyWithMark(s, trg) and s.hero:SkillDPS(trg, s.dps) then
                    map:Log("半月斩对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                    HitTarget(s, trg)
                    if i == 1 and units[2].status == 0 then
                        s.dps = s.vals[1]
                        for j = 2, 3 do
                            units[j].status = 1
                            units[j].pos = var.pos:Clone()
                        end
                    end
                end
                if not map:PosVecAvailable(var.pos) then var.status = 255 end
                alive = true
            end
        end

        if not alive then s:Dead() end
    end
end
--破军箭
_skc[2] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BF_ShortStop
        if s.hero.dat.isStar then s.vals = { } end
        var = s.hero
        s.units =
        {
            {
                status = 1, speed = 5,
                pos = var.pos:Clone(),
                direction = var.rival.pos - var.pos,
            }
        }
        s.step = 2
    elseif var == 2 then
        local h, u = s.hero, s.units[1]
        var = h.rival.pos - u.pos
        if var.magnitude > 1 then
            local d = s.map.deltaTime
            d, u.speed = u.speed * BD_Const.BASE_MOVE_SPEED_UNIT * d, B_Math.slerp(u.speed, 10, 13, d)
            u.pos:AddMult(var:Normalize(), d)
            if h.dat.isStar then s.vals[1] = s.vals[1] + d end
            if not s.map:PosVecAvailable(u.pos) then s:Dead() end
        else
            if h:SkillDPS(h.rival, s.dps) then
                s.map:Log("百步穿杨对" .. h.rival.DebugName .. "造成<" .. s.dps .. ">点伤害")
                if h.dat.isStar then
                    var = s.dat
                    s.buff = BD_Buff.BD_BuffSingle(10020,  B_Math.ceil(B_Math.lerp(var:GetExtKeepMS(1), var:GetExtKeepMS(2), B_Math.clamp01(s.vals[1] / B_Math.max(1, var:GetExtInt(3))))), BD_AID.Stop, 1)
                end
                h.rival:AddBuff(s.buff)
                HitTarget(s, h.rival)
            end
            s:Dead()
        end
    end
end
--振奋
_skc[3] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        var = BD_Buff.BD_BuffSingle(10030, s.dat.keep.value, BD_AID.Str, s.dat:GetExtValInt(1))
        s.buff = var
        for _, u in ipairs(s.map:SearchUnits(s.isAtk, BD_Soldier)) do
            u:AddBuff(var)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--治疗术
_skc[4] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetCure(s))
        s.hero:CureDPS(s.hero, s.dps)
        s.map:Log("圣光术恢复" .. s.hero.DebugName .. "<" .. s.dps .. ">点生命")
        s:Dead()
    end
end
--能量灌注
_skc[5] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = s.hero
        s.dps = B_Math.ceil(var.MaxSP * s.dat:GetExtValPercent(1))
        var:SufferEnergy(s.dps)
        s.map:Log("能量灌注恢复" .. var.DebugName .. "<" .. s.dps .. ">点技力")
        s:Dead()
    end
end
--绝命反击
_skc[6] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        --武将损失当前剩余30%血量增加50%武力
        var = s.dat
        s.hero:SetHP(-B_Math.floor(s.hero.HP * var:GetExtPercent(1)))
        s.buff = BD_Buff.BD_BuffSingle(10060, var.keep.value, BD_AID.Str, var:GetExtValInt(2))
        s.hero:AddBuff(s.buff)
        s:Dead()
    end
end
--气刃
_skc[7] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        var = s.hero
        local hx, hy = var.x, var.y
        var = var.isAtk and 1 or -1
        s.units =
        {
            {
                status = 1, speed = 5, time = 0,
                pos = B_Vector(hx, hy + 2),
                direction = B_Vector(var, 0),
            },
            {
                status = 1,
                pos = B_Vector(hx + var, hy),
                direction = B_Vector(var, 0),
            },
            {
                status = 1,
                pos = B_Vector(hx + var, hy - 2),
                direction = B_Vector(var, 0),
            }
        }
        s.dicMark = { }
        s.step = 2
    elseif var == 2 then
        var = s.units[1]
        local map = s.map
        if var.time < 400 then
            local d = map.deltaTime
            d, var.speed = var.speed * BD_Const.BASE_MOVE_SPEED_UNIT * d, B_Math.slerp(var.speed, 10, 13, d)
            for _, u in ipairs(s.units) do
                if u.status == 1 then
                    u.pos:AddMult(u.direction, d)
                    for j = 0, 1 do
                        local trg = map:GetArrivedUnit(u.pos.x, u.pos.y + j)
                        if CheckEnemyWithMark(s, trg) and s.hero:SkillDPS(trg, s.dps) then
                            map:Log("月波斩对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                            HitTarget(s, trg)
                        end
                    end
                end
            end
        else
            s:Dead()
        end
        s.units[1].time = var.time + map.deltaMillisecond
    end
end
--刀阵
_skc[8] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 600)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        local rx, ry = 2, 1 --直径
        s.vals = { rx * 0.5, ry * 0.5 } --半径
        GenMultPointUnits(s, qty, rx, ry)
        s.step = 2
    elseif var == 2 then
        local alive = false
        local rx, ry = s.vals[1], s.vals[2]
        local h, map = s.hero, s.map
        local dtm = map.deltaMillisecond
        local func = s.func
        for i, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 400  then
                    u.time, u.status = 0, 2
                    if func == nil then
                        func = _func.dmg(s, "刀阵", s.hitLst, s.dps)
                        s.func = func
                    end
                    var = u.pos
                    map:ForeachAreaUnits(var.x - rx, var.y - ry, var.x + rx, var.y + ry, func)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--连环闪电
_skc[9] = function(s)
    local var = s.step
    if var == 0 then
        s.list = s.map:SearchUnits(not s.hero.isAtk)
        if #s.list > 0 then
            WaitForTime(s, 600)
            s.step = 1
        else
            s:Dead()
        end
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        var = B_Math.floor(100 / B_Math.clamp(s.dat:GetExtInt(1), 1, 100))
        s.vals = 
        {
            var,--数量
            var,--最大数量
            1,--dis
            -1,--dis1
            2--index
        }
        var = B_Vector(s.map:SearchUnitFocus(not s.hero.isAtk))
        table.sort(s.list, function(x, y) return B_Vector.Distance2(x.pos, var) < B_Vector.Distance2(y.pos, var) end)
        var = s.list[1].pos
        s.pos:Copy(var)
        s.step = 2
    elseif var == 2 then
        var = remove(s.list, 1)
        local vals = s.vals
        local pos = s.pos
        while(var) do
            if CheckEnemy(s, var) then
                local d = B_Vector.Distance2(var.pos, pos)
                if d < vals[5] then
                    vals[1] = vals[1] - 1
                    local dmg = B_Math.ceil(s.dps * vals[1] / vals[2])
                    if s.hero:SkillDPS(var, dmg) then
                        s.map.Log("闪电链对" .. var.DebugName .. "造成<" .. dmg .. ">点伤害")
                    end
                    HitTarget(s, var)
                end
                if d > vals[4] then
                    vals[4] = vals[5]
                    vals[3] = vals[3] + 1
                    vals[5] = 2 * (vals[3] ^ 2)
                end
                if vals[1] > 0 then
                    WaitForTime(s, 70)
                    return
                end
                break
            end
            var = remove(s.list, 1)
        end
        s:Dead()
    end
end
--铜墙铁壁
_skc[10] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        --受到伤害减低,持续10秒
        var = s.dat
        s.buff = BD_Buff.BD_BuffDouble(10100, var.keep.value, BD_AID.SPD, -var:GetExtValInt(1), BD_AID.SSD, -var:GetExtValInt(1))      
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--漫天箭雨 | 53 箭雨
_skc[11] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 600)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))

        local minX, minY, maxX, maxY = GetEnemyDenseRange(s)

        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)

        local dt = B_Math.floor(s.dat.keep.value / qty)
        local random = s.map.random
        var = { }
        s.units = var
        for i = 1, qty do
            var[i] =
            {
                status = 1,
                time = i > 1 and var[i - 1].time - random:NextInt(0, dt) or 0,
                pos = B_Vector(random:NextInt(minX, maxX + 1), random:NextInt(minY, maxY + 1))
            }
        end
        s.step = 2
    elseif var == 2 then
        local alive = false
        local range = 1.5
        local hr = range * 0.5
        local h, map = s.hero, s.map
        local dtm = map.deltaMillisecond
        local func = s.func
        for i, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 100  then
                    u.time, u.status = 0, 255
                    if func == nil then
                        func = _func.dmg(s, s.sn == 11 and "万箭齐发" or "箭雨", s.hitLst, s.dps)
                        s.func = func
                    end
                    var = u.pos
                    map:ForeachAreaUnits(var.x - hr, var.y - hr, var.x + hr, var.y + hr, func)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--百鬼索命
_skc[12] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 600)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffSingle(10120, 100, BD_AID.MoveSpeed, -s.dat:GetExtValInt(1))
        local minX, minY, maxX, maxY = GetEnemyDenseRange(s)
        --时间，minX,minY,maxX,maxY
        s.vals = { 0, minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5 }
        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        Dead(s, 370 + s.dat.keep.value)
        WaitForTime(s, 370)
        s.step = 2
    elseif var == 2 then
        local vals = s.vals
        var = s.hitLst
        if var and #var > 0 then s.hitLst = { } end
        var = vals[1] > 0
        vals[1] = var and vals[1] - s.map.deltaMillisecond or 1000
        if var and s.dps and s.dps > 0 then
            if s.func then
                var = s.func
            else
                var = _func.range_dmg_buff(s, "百鬼索命", s.hitLst, s.dps, s.buff)
                s.func = var
            end
        elseif s.func2 then
            var = s.func2
        else
            var = _func.buff(s, s.hitLst, s.buff)
            s.func2 = var
        end
        s.map:ForeachAreaUnits(vals[2], vals[3], vals[4], vals[5], var)
    end
end
--策反 | 44 离间
_skc[13] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h, var = s.hero, s.dat
        local tp, maxTP = h.TP, h.MaxTP
        local qty = B_Math.ceil(var:GetExtValPercent(1) * h.rival.MaxTP)
        qty = B_Math.min(qty, h.rival.TP, maxTP - tp)
        if qty <= 0 then s:Dead() return end

        local lst = s.map:SearchUnits(not h.isAtk, BD_Soldier)

        local q = qty
        if #lst > qty then
            local rx, ry = h.rival.x, h.rival.y
            table.sort(lst, function(a, b)
                return B_Math.abs(a.x - rx) + B_Math.abs(a.y - ry) > B_Math.abs(b.x - rx) + B_Math.abs(b.y - ry)
            end)
        end

        if s.sn == 44 and h.dat.isStar then
            --将星技
            var = BD_Buff.BD_BuffSingle(10440, var:GetExtKeepMS(2), BD_AID.Str, var:GetExtValInt(3))
            s.buff = var
            for _, u in ipairs(lst) do
                u:SetBelong(h)
                i:AddBuff(var)
                q = q - 1
                HitTarget(s, u)
                if q <= 0 then break end
            end
        else
            for _, u in ipairs(lst) do
                u:SetBelong(h)
                q = q - 1
                HitTarget(s, u)
                if q <= 0 then break end
            end
        end
        if qty > q then
            qty = qty - (q > 0 and q or 0)
            h:SetTP(qty)
            h.rival:SetTP(-qty)
        end
    end
end
--风火轮
_skc[14] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.vals = { 0 }
        Dead(s, s.dat.keep.value)
        s.step = 2
    elseif var == 2 then
        var = s.vals
        if var[1] > 0 then
            var[1] = var[1] - s.map.deltaMillisecond
        else
            var[1] = 1000
            var = s.hero.pos
            if s.func == nil then s.func = _func.dmg(s, "风火轮", s.hitLst, s.dps) end
            s.map:ForeachAreaUnits(var.x - 1.5, var.y - 1.5, var.x + 1.5, var.y + 1.5, s.func)
        end
    end
end
--飓风术
_skc[15] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local minX, minY, maxX, maxY = GetEnemyDenseRange(s)
        var = { s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5 }
        s.vals = var
        local random = s.map.random
        var =
        {
            status = 1, time = s.dat.keep.value,
            speed = random:Next(0.8, 1) * BD_Const.BASE_MOVE_SPEED_UNIT,
            pos = B_Vector(minX + var[1] - 0.5, minY + var[2] - 0.5),
            direction = B_Vector(random:Next(-1, 1), random:Next(-1, 1))
        }
        s.units = { var }
        var.direction:Normalize()
        s.step = 2
        Dead(s, 600 + var.time)
        WaitForTime(s, 600)
    elseif var == 2 then
        var = s.units[1]
        if var.status == 1 then
            if var.time > 0 then
                local map = s.map
                var.time = var.time - map.deltaMillisecond
                local pos = B_Vector(var.pos:Clone():GetAddMult(var.direction, var.speed * map.deltaTime))
                if map:PosVecAvailable(pos) then
                    var.pos:Copy(pos)
                else
                    pos = var.pos
                end
                local rx, ry = s.vals[1], s.vals[2]
                if s.func == nil then
                    s.func = function(trg)
                        if getmetatable(trg) == BD_Soldier and CheckEnemy(s, trg) then
                            map:Log("飓风术对" .. trg.DebugName .. "造成<" .. trg.HP .. ">点伤害")
                            trg:SetHP(0, true)
                            HitTarget(s, trg)
                        end
                    end
                end
                map:ForeachAreaUnits(pos.x - rx, pos.y - ry, pos.x + rx, pos.y + ry, s.func)
            else
                var.status = 255
                s:Dead()
            end
        end
    end
end
--奇袭
_skc[16] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h = s.hero
        local tp, maxTP = h.TP, h.MaxTP
        local qty = B_Math.ceil(s.dat:GetExtValPercent(1) * maxTP)
        if tp + qty > maxTP then qty = maxTP - tp end
        if qty <= 0 then s:Dead() return end
        local map = s.map
        local isAtk = h.isAtk
        local q = qty
        local x = isAtk and map.width - 1 or 0
        local dx = isAtk and -1 or 1
        local y1 = h.y
        local y2 = y1 + 1
        local dy = true
        local cy = 0
        while q > 0 and (isAtk and x >= 0 or x < map.width) do
            if dy then
                y1 = y1 - 1
                cy = y1
            else
                y2 = y2 + 1
                cy = y2
            end
            dy = not dy
            if q > 0 and map:PosAvailableAndEmpty(x, cy) then
                q = q - 1
                local u = BD_Soldier(map, x, cy)
                u:InitData(h)
                HitTarget(s, u)
            end
            if q <=0 then break end
            if y1 < 1 and y2 >= map.height - 1 then
                x = x + dx
                y1 = h.y
                y2 = y1 + 1
            end
        end
        if qty > q then
            h:SetTP(qty - (q > 0 and q or 0))
        end
        s:Dead()
    end
end
--水龙阵
_skc[17] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = s.dat
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffDouble(10170, var.keep.value, BD_AID.MoveSpeed, -var:GetExtValInt(1), BD_AID.MSPA, -var:GetExtValInt(2))
        local minX, minY, maxX, maxY = GetEnemyDenseRange(s)
        s.vals = { minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5 } --[minX,minY,maxX,maxY]
        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        WaitForTime(s, 400)
        s.step = 2
    elseif var == 2 then
        var = s.vals
        if s.func == nil then s.func = _func.dmg_buff(s, "水龙阵", s.hitLst, s.dps, s.buff) end
        s.map:ForeachAreaUnits(var[1], var[2], var[3], var[4], s.func)
        s:Dead()
    end
end
--神圣之光
_skc[18] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h = s.hero
        var = s.dat:GetExtValPercent(1)
        for _, u in ipairs(s.map:SearchUnits(h.isAtk)) do
            h:CureDPS(u, B_Math.ceil(var * u.MaxHP))
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--八卦阵
_skc[19] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.buff = BD_Buff.BD_BuffSingle(10190, 100, BD_AID.Blind, 1)
        local minX, minY, maxX, maxY = GetEnemyDenseRange(s)
        s.vals = { minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5 }--[minX,minY,maxX,maxY]
        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        Dead(s, s.dat.keep.value)
        s.step = 2
    elseif var == 2 then
        var = s.vals
        if s.func == nil then s.func = _func.buff(s, s.hitLst, s.buff) end
        s.map:ForeachAreaUnits(var[1], var[2], var[3], var[4], s.func)
    end
end
--灭杀阵
_skc[20] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        local range = 2.5
        s.vals = { range * 0.5 }
        GenMultPointUnits(s, qty, range, range)
        s.step = 2
    elseif var == 2 then
        local alive = false
        local r = s.vals[1]
        local map = s.map
        local dtm = map.deltaMillisecond
        local func = s.func
        for i, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 220  then
                    u.time, u.status = 0, 255
                    if func == nil then
                        func = _func.dmg(s, "灭杀阵", s.hitLst, s.dps)
                        s.func = func
                    end
                    var = u.pos
                    map:ForeachAreaUnits(var.x - r, var.y - r, var.x + r, var.y + r, func)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--增援
_skc[21] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h = s.hero
        local tp, maxTP = h.TP, h.MaxTP
        local qty = B_Math.ceil(s.dat:GetExtValPercent(1) * maxTP)
        if tp + qty > maxTP then qty = maxTP - tp end
        if qty <= 0 then s:Dead() return end
        local map = s.map
        local isAtk = h.isAtk
        local q = qty
        local x = isAtk and 0 or map.width - 1
        local dx = isAtk and 1 or -1
        local y1 = h.y
        local y2 = y1 + 1
        local dy = true
        local cy = 0
        while q > 0 and (isAtk and x < map.width or x >= 0) do
            if dy then
                y1 = y1 - 1
                cy = y1
            else
                y2 = y2 + 1
                cy = y2
            end
            dy = not dy
            if q > 0 and map:PosAvailableAndEmpty(x, cy) then
                q = q - 1
                local u = BD_Soldier(map, x, cy)
                u:InitData(h)
                HitTarget(s, u)
            end
            if q <=0 then break end
            if y1 < 1 and y2 >= map.height - 1 then
                x = x + dx
                y1 = h.y
                y2 = y1 + 1
            end
        end
        if qty > q then
            h:SetTP(qty - (q > 0 and q or 0))
        end
        s:Dead()
    end
end
--野火燎原
_skc[22] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        var = GetDmg(s)
        s.dps = B_Math.ceil(var)
        s.buff = BD_Buff.BD_BuffSingle(10220, s.dat:GetExtKeepMS(3), BD_AID.SDmg, B_Math.max(0, B_Math.ceil(var * s.dat:GetExtPercent(2))))
        
        local range = 2.5
        s.vals = { range * 0.5 }
        GenMultPointUnits(s, qty, range, range)
        s.step = 2
    elseif var == 2 then
        local alive = false
        local r = s.vals[1]
        local map = s.map
        local dtm = map.deltaMillisecond
        local func = s.func
        for i, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 600  then
                    u.time, u.status = 0, 255
                    if func == nil then
                        func = _func.dmg_buff(s, "野火燎原", s.hitLst, s.dps, s.buff)
                        s.func = func
                    end
                    var = u.pos
                    map:ForeachAreaUnits(var.x - r, var.y - r, var.x + r, var.y + r, func)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--诸葛连弩 | 36 连弩激射
_skc[23] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <=0 then
            s:Dead()
            return
        end
        s.dps = B_Math.ceil(GetDmg(s))

        var = s.hero.pos
        local x, y = var.x, var.y
        local dire = s.hero.isAtk and 1 or -1
        local speed = BD_Const.BASE_MOVE_SPEED_UNIT * 5
        var = { }
        s.units = var
        for i = 1, qty do
            var[i] = 
            {
                status = 1, speed = speed, time = -280 * i,
                pos = B_Vector(x, y),
                direction = B_Vector(dire, 0)
            }
        end
        s.step = 2
    elseif var == 2 then
        local alive = false
        local h, map = s.hero, s.map
        local hpos = h.pos
        local dt, dtm = map.deltaTime, map.deltaMillisecond
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time > 0 then
                    u.pos:AddMult(u.direction, u.speed * dt)
                    if map:PosVecAvailable(u.pos) then
                        local trg = map:GetArrivedUnit(u.pos.x, u.pos.y)
                        if CheckEnemy(s, trg) then
                            u.status = 255
                            if h:SkillDPS(trg, s.dps) then
                                if h.dat.isStar then
                                    --将星技
                                    if s.sn == 23 and getmetatable(trg) == BD_Soldier then
                                        u.status = 1
                                    elseif s.sn == 36 and getmetatable(trg) == BD_Hero then
                                        h:CureDPS(h, s.dat:GetExtValInt(2))
                                    end
                                end
                                map:Log((s.sn == 23 and "诸葛连弩" or "连弩激射") .. "对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                                if s.sn == 36 then trg:AddBuff(BD_Buff.BF_ShortStop) end
                                HitTarget(s, trg)
                            end
                        end
                    else
                        u.status = 255
                    end
                else
                    u.pos:Copy(hpos)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--金钟罩 || 79 金钟罩
_skc[24] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.buff = BD_Buff.BD_BuffSingle(10240, s.dat.keep.value, BD_AID.God, 1)
        s.hero:AddBuff(s.buff)
        --将星技
        if s.sn == 79 and s.hero.dat.isStar then
            s.buff2 = BD_Buff.BD_BuffSingle(10791, s.dat:GetExtKeepMS(1), BD_AID.Cure, s.dat:GetExtValInt(2))
            WaitForTime(s, s.buff.lifeTime)
            s.step = 2
        else
            s:Dead()
        end
    elseif var == 2 then
        s.hero:AddBuff(s.buff2)
        s:Dead()
    end
end
--夜幕
_skc[25] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.buff = BD_Buff.BD_BuffSingle(10250, s.dat.keep.value, BD_AID.Acc, -s.dat:GetExtValInt(1))
        s.vals = { -1, s.map.time }
        Dead(s, s.buff.lifeTime)
        s.step = 2
    elseif var == 2 then
        var = s.hero.rival.RealTP
        if var > s.vals[1] then
            local passTime = s.map.time - s.vals[2]
            for _, u in ipairs(s.map:SearchUnits(not s.hero.isAtk)) do
                if not u:ContainsBuff(10250) then
                    u:AddBuff(s.buff).passTime = passTime
                    HitTarget(s, u)
                end
            end
        end
        s.vals[1] = var
    end
end
--冰锥
_skc[26] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        local minX, minY, maxX, maxY = GetEnemyDenseRange(s)
        s.vals = { minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5 }--[minX,minY,maxX,maxY]
        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        s.buff = BD_Buff.BD_BuffSingle(10260, s.dat.keep.value, BD_AID.Stop, 1)
        s.list = { }
        WaitForTime(s, 250)
        s.step = 2
    elseif var == 2 then
        var = s.vals
        local lst, buf = s.list, s.buff
        s.map:ForeachAreaUnits(var[1], var[2], var[3], var[4], function(trg)
            if CheckEnemy(s, trg) then
                insert(lst, trg)
                trg:AddBuff(buf)
                HitTarget(s, trg)
            end
        end)
        WaitForTime(s, 340)
        s.step = 3
    elseif var == 3 then
        local h = s.hero
        local SkillDPS = h.SkillDPS
        var = s.dps
        for _, u in ipairs(s.list) do
            if SkillDPS(h, u, var) then
                s.map:Log("冰锥对" .. u.DebugName .. "造成<" .. var .. ">点伤害")
            end
        end
        s:Dead()
    end
end
--烈火悬灯 | 56 悬灯火
_skc[27] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        if s.sn == 27 and s.hero.dat.isStar then
            s.buff = BD_Buff.BD_BuffSingle(10270, 1000, BD_AID.Stop, 1)
        end
        s.vals = { 0, s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5 }
        local da = B_Math.PI * 2 / qty
        local random = s.map.random
        var = { }
        s.units = var
        for i = 1, qty do
            var[i] = 
            {
                status = 1,
                pos = B_Vector(),
                direction = B_Vector(random:Next(da * (i - 1), da * i), random:Next(0.4, 1))
            }
        end
        s.dicTime = { }
        Dead(s, s.dat.keep.value)
        s.step = 2
    elseif var == 2 then
        local h, map = s.hero, s.map
        local hpos = h.pos
        local vals = s.vals
        local dt, tm = map.deltaTime, map.time
        local flag = vals[1] < 300
        local r = flag and 1 - B_Math.pow(2, -10 * vals[1] / 300) or 1
        vals[1] = vals[1] + map.deltaMillisecond
        for _, u in ipairs(s.units) do
            if not flag then
                u.direction.x = u.direction.x + 2 * dt
            end
            var = u.direction.y * r
            u.pos:Set(vals[2] * B_Math.cos(u.direction.x) * var, vals[3] * B_Math.sin(u.direction.x) * var)
            var = u.pos
            u = map:GetArrivedUnit(hpos.x + var.x, hpos.y + var.y)
            if CheckEnemy(s, u) then
                var = s.dicTime[u] or 0
                if var <= tm then
                    s.dicTime[u] = tm + 1000
                    if h:SkillDPS(u, s.dps) then
                        map:Log("烈火悬灯对" .. u.DebugName .. "造成<" .. s.dps .. ">点伤害")
                        if s.buff then u:AddBuff(s.buff) end
                        HitTarget(s, u)
                    end
                end
            end
        end
    end
end
--冰风刃舞
_skc[28] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffSingle(10280, s.dat:GetExtKeepMS(3), BD_AID.MoveSpeed, -s.dat:GetExtValInt(2))
        local rx, ry = 3, 2 --直径
        s.vals = { rx * 0.5, ry * 0.5 } --半径
        GenMultPointUnits(s, qty, rx, ry)
        s.step = 2
    elseif var == 2 then
        local alive = false
        local rx, ry = s.vals[1], s.vals[2]
        local h, map = s.hero, s.map
        local dtm = map.deltaMillisecond
        local func = s.func
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 100 then
                    u.time, u.status = 0, 255
                    if func == nil then
                        func = _func.dmg_buff(s, "冰风刃舞", s.hitLst, s.dps, s.buff)
                        s.func = func
                    end
                    var = u.pos
                    map:ForeachAreaUnits(var.x - rx, var.y - ry, var.x + rx, var.y + ry, func)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--火牛烈崩
_skc[29] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then return s:Dead() end
        s.buff = BD_Buff.BD_BuffSingle(10290, s.dat.keep.value, BD_AID.Fear, 1)
        if s.hero.dat.isStar then
            var = GetDmg(s)
            s.dps = B_Math.ceil(var)
            s.buff2 = BD_Buff.BD_BuffSingle(10291, s.dat:GetExtKeepMS(2), BD_AID.SDmg, B_Math.ceil(s.dat:GetExtPercent(3) * var))
        else
            s.dps = B_Math.ceil(GetDmg(s))
        end
        s.dicMark = { }
        local ix = B_Math.clamp(s.hero.isAtk and s.map.defMinX - 4 or s.map.atkMaxX + 4, 0, s.map.width - 1)
        local dire = s.hero.isAtk and 1 or -1
        local rows = { }
        local random = s.map.random
        var = { }
        s.units = var
        for i = 0, s.map.height - 1 do insert(rows, i) end
        for i = 1, qty do
            var[i] = 
            {
                status = 1, speed = random:Next(4, 6) * BD_Const.BASE_MOVE_SPEED_UNIT,
                pos = B_Vector(ix, remove(rows, random:NextInt(0, #rows) + 1)),
                direction = B_Vector(dire, 0)
            }
        end
        WaitForTime(s, 200)
        s.step = 2
    elseif var == 2 then
        local alive = false
        local h, map = s.hero, s.map
        local dt = map.deltaTime
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.pos:AddMult(u.direction, u.speed * dt)
                var = map:GetArrivedUnit(u.pos.x, u.pos.y)
                if CheckEnemyWithMark(s, var) and h:SkillDPS(var, s.dps) then
                    map:Log("火牛烈崩对" .. var.DebugName .. "造成<" .. s.dps .. ">点伤害")
                    if getmetatable(var) == BD_Soldier  then var:AddBuff(s.buff) end
                    if s.buff2 then var:AddBuff(s.buff2) end
                    HitTarget(s, var)
                end
                if not map:PosVecAvailable(u.pos) then u.status = 255 end
            end
        end
        if not alive then s:Dead() end
    end
end
--鬼哭神嚎
_skc[30] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = GetDmg(s)
        s.dps = B_Math.ceil(var)
        --[二次打击时间，二次打击伤害，二次打击的半径,单个范围X，单个范围Y]
        s.vals = { -1, B_Math.ceil(s.dat:GetExtPercent(2) * var), 1, s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5 }
        local units =
        {
            {
                status = 1, speed = 0,
                pos = s.hero.pos:Clone(),
                direction = B_Vector(s.hero.isAtk and 1 or -1, 0)
            }
        }
        s.units = units
        local qty = B_Math.max(1, s.dat:GetExtInt(1))
        if qty > 1 then
            var = B_Math.PI * 2 / (qty - 1)
            for i = 2, qty do
                units[i] = 
                {
                    status = 0, speed = var * (i - 2)
                }
            end
        end
        s.dicMark = { }
        s.dicTime = { }
        s.step = 2
    elseif var == 2 then
        local alive = false
        local map = s.map
        local dt = map.deltaTime
        local units = s.units
        local vals = s.vals
        local r = vals[3]
        var = units[1]
        if var.status == 1 then
            alive = true
            if var.speed < 10 then var.speed = var.speed + 10 * dt end
            var.pos:AddMult(var.direction, var.speed * BD_Const.BASE_MOVE_SPEED_UNIT * dt)
            if not map:PosVecAvailable(var.pos) then var.status = 255 end
            var = map:GetArrivedUnit(var.pos.x, var.pos.y)
            if CheckEnemyWithMark(s, var) then
                if getmetatable(var) == BD_Hero and vals[1] == -1 then
                    vals[1] = 0
                    local pos = var.pos
                    s.pos:Copy(pos)
                    for i = 2, #units, 1 do
                        units[i].status = 1
                        units[i].pos = B_Vector(pos.x + B_Math.cos(units[i].speed) * r, pos.y + B_Math.sin(units[i].speed) * r)
                    end
                end
                if s.hero:SkillDPS(var, s.dps) then
                    s.map:Log("鬼哭神嚎对" .. var.DebugName .. "造成<" .. s.dps .. ">点伤害")
                    HitTarget(s, var)
                end
            end
        end
        if vals[1] >= 0 then
            alive = true
            vals[1] = vals[1] + map.deltaMillisecond
            if vals[1] >= 300 then
                if vals[1] >= 1000 then
                    if r * 2 < map.height then
                        vals[3] = vals[3] + 1.5 * dt
                        var = s.pos
                        for i = 2, #units, 1 do
                            units[i].speed = units[i].speed + B_Math.PI * dt
                            units[i].pos:Set(var.x + B_Math.cos(units[i].speed) * r, var.y + B_Math.sin(units[i].speed) * r)
                        end
                    else
                        for i = 2, #units, 1 do units[i].status = 255 end
                        vals[1] = -2
                    end
                end
                if vals[1] > 0 then
                    local h = s.hero
                    local tm = map.time
                    local rx, ry = vals[4], vals[5]
                    local func = s.func
                    if func == nil then 
                        func = _func.tm_dmg_buf(s, "鬼哭神嚎", s.hitLst, vals[2])
                        s.func = func
                    end
                    for i = 2, #units, 1 do
                        var = units[i].pos
                        map:ForeachAreaUnits(var.x - rx, var.y - ry, var.x + rx, var.y + ry, func)
                    end
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--破釜沉舟
_skc[31] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = s.dat:GetExtPercent(1)
        s.buff = BD_Buff.BD_BuffSingle(10310, s.dat.keep.value, BD_AID.Str, s.dat:GetExtValInt(2))
        for i, u in ipairs(s.map:SearchUnits(s.hero.isAtk)) do
            u:SetHP(-B_Math.floor(u.HP * var))
            u:AddBuff(s.buff)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--分身斩
_skc[32] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.units =
        {
            {
                status = 1, speed = 0,
                pos = s.hero.pos:Clone(),
                direction = B_Vector(s.hero.isAtk and 1 or -1, 0)
            }
        }
        s.dicMark = { }
        s.step = 2
    elseif var == 2 then
        local u = s.units[1]
        if u.status == 1 then
            local map = s.map
            if u.speed < 10 then u.speed = u.speed + 10 * map.deltaTime end
            u.pos:AddMult(u.direction, u.speed * BD_Const.BASE_MOVE_SPEED_UNIT * map.deltaTime)
            if not map:PosVecAvailable(u.pos) then u.status = 255 end
            var = map:GetArrivedUnit(u.pos.x, u.pos.y)
            if CheckEnemyWithMark(s, var) and s.hero:SkillDPS(var, s.dps) then
                map:Log("分身斩对" .. var.DebugName .. "造成<" .. s.dps .. ">点伤害")
                HitTarget(s, var)
            end
        else
            s:Dead()
        end
    end
end
--命疗术
_skc[33] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = s.hero
        local v = s.dat:GetExtValPercent(1)
        var:CureDPS(var, B_Math.ceil(var.MaxHP * v))
        var:SufferEnergy(B_Math.ceil(var.MaxSP * v))
        s:Dead()
    end
end
--赤焰火海
_skc[34] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        var = s.hero.rival
        local minX, minY, maxX, maxY = GetRange(s, var.x, var.y)
        --[dt, minX,minY,maxX,maxY]
        s.vals = { 0, minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5 }
        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        Dead(s, s.dat.keep.value)
        s.step = 2
    elseif var == 2 then
        var = s.vals
        if var[1] > 0 then
            var[1] = var[1] - s.map.deltaMillisecond
        else
            var[1] = 1000
            if s.func == nil then s.func = _func.dmg(s, "赤焰火海", s.hitLst, s.dps) end
            s.map:ForeachAreaUnits(var[2], var[3], var[4], var[5], s.func)
        end
    end
end
--雷击闪
_skc[35] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = s.hero.rival
        s.dps = B_Math.ceil(GetDmg(s))
        if s.hero:SkillDPS(var, s.dps) then
            s.map:Log("雷击闪对" .. var.DebugName .. "造成<" .. s.dps .. ">点伤害")
            HitTarget(s, var)
        end
        Dead(s)
    end
end
--连弩激射
_skc[36] = _skc[23]
--火雷星雨
_skc[37] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        --设置单个半径
        s.vals = { 1 }
        var = s.map.random
        local units = { }
        s.units = units
        for i = 1, qty do
            units[i] = 
            {
                status = 1,
                time = i > 1 and units[i - 1].time - var:NextInt(0, dt) or 0,
                pos = B_Vector()
            }
        end
        s.step = 2
    elseif var == 2 then
        local r = s.vals[1]
        local alive = false
        local map = s.map
        local func = s.func
        local dtm = map.deltaMillisecond
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 0 then
                    var = s.hero.rival.pos
                    u.pos:Set(var.x + map.random:Next(-3, 3), var.y)
                    u.time = 0
                    u.status = 2
                end
            elseif u.status == 2 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 300 then
                    u.time, u.status = 0, 255
                    if func == nil then
                        func = _func.dmg(s, "火雷星雨", s.hitLst, s.dps)
                        s.func = func
                    end
                    var = u.pos
                    map:ForeachAreaUnits(var.x - r, var.y - r, var.x + r, var.y + r, func)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--天地无用
_skc[38] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = GetDmg(s)
        s.dps = B_Math.ceil(var)
        local dat = s.dat
        --[伤害递减，当前兵数，开始时间，单半径X，单半径Y，士兵伤害比例(将星)]
        s.vals = { B_Math.ceil(var * 0.1), -1, s.map.time, dat.rangeX.value * 0.5, dat.rangeY.value * 0.5 }
        if s.hero.dat.isStar then s.vals[6] = 1 + dat:GetExtValPercent(3) end
        var = dat.keep.value
        s.buff = BD_Buff.BD_BuffSingle(10380, var, BD_AID.Acc, -dat:GetExtValInt(2))

        local qty = dat:GetExtInt(1)
        local units = { }
        s.units = units
        local dmint = B_Math.round(var * 0.6 / qty)
        local dmaxt = B_Math.round(var * 0.9 / qty)
        local random = s.map.random
        for i = 1, qty do
            units[i] = 
            {
                status = 1,
                time = i > 1 and units[i - 1].time - random:NextInt(dmint, dmaxt) or 0,
                pos = B_Vector()
            }
        end
        s.step = 2
    elseif var == 2 then
        local alive = false
        local map = s.map
        local vals = s.vals
        var = s.hero.rival.RealTP
        if var > vals[2] then
            local passTime = map.time - vals[3]
            s.list = map:SearchUnits(not s.hero.isAtk)
            for _, u in ipairs(s.list) do
                if not u:ContainsBuff(10380) then
                    u:AddBuff(s.buff).passTime = passTime
                    HitTarget(s, u)
                end
            end
        end
        vals[2] = var

        local h = s.hero
        local list = s.list
        local dtm = map.deltaMillisecond
        local rx, ry = vals[4], vals[5]
        local rnd = map.random
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 0 then
                    u.time = 0
                    var = #list
                    if var > 0 then
                        var = var > 1 and list[math.clamp(rnd:NextInt(0, var) + 1, 1, var)].pos or list[1].pos
                        u.pos:Copy(var)
                        u.status = 2
                    else
                        u.status = 255
                    end
                end
            elseif u.status == 2 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 100 then
                    u.time, u.status = 0, 255
                    local dmg = s.dps
                    local sd = vals[6] or 1
                    var = u.pos
                    map:ForeachAreaUnits(var.x - rx, var.y - ry, var.x + rx, var.y + ry, function(trg)
                        if CheckEnemy(s, trg) then
                            var = getmetatable(trg) == BD_Soldier and B_Math.ceil(sd * dmg) or dmg
                            if h:SkillDPS(trg, var)  then
                                map:Log("天地无用对" .. trg.DebugName .. "造成<" .. var .. ">点伤害")
                                if trg.isDead then
                                    for i, u in ipairs(list) do if u == trg then remove(list, i) break end end
                                end
                            end
                            dmg = dmg - vals[1]
                            if dmg <=0 then return end
                        end
                    end)
                end
            end
        end

        if not alive then s:Dead() end
    end
end
--五狱华斩 | 55 乾坤扫月
_skc[39] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        s.vals = { 5 } --速度
        if s.hero.dat.isStar then
            if s.sn == 39 then s.vals[2] = s.dat:GetExtValInt(2)
            elseif s.sn == 55 then s.buff = BD_Buff.BD_BuffSingle(10550, data.keep.value, BD_AID.Stop, 1) end
        end
        local units = { }
        s.units = units
        var = s.hero.isAtk and 1 or -1
        local pos = s.hero.pos:Clone()
        for i = 1, qty do
            units[i] = 
            {
                status = 1, direction = B_Vector(var, 0),
                time = i > 1 and -(B_Math.floor(((i - 2) / 2)) + 1) * 50 or 0,
                pos = i > 1 and B_Vector(pos.x, pos.y + ((i % 2 == 1 and 1 or -1) * (B_Math.floor(((i - 2) / 2))+ 1))) or pos
            }
        end
        s.dicMark = { }
        s.step = 2
    elseif var == 2 then
        local alive = false
        local vals = s.vals
        local map = s.map
        local dtm = map.deltaMillisecond
        local trg
        var = map.deltaTime
        var, vals[1] = vals[1] * BD_Const.BASE_MOVE_SPEED_UNIT * var, B_Math.slerp(vals[1], 10, 13, var)
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 0 then
                    u.pos:AddMult(u.direction, var)
                    trg = map:GetArrivedUnit(u.pos.x, u.pos.y)
                    if CheckEnemyWithMark(s, trg) and s.hero:SkillDPS(trg, s.dps) then
                        map:Log("五狱华斩对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                        if s.buff and s.buff.sn == 10550 then trg:AddBuff(s.buff)
                        elseif vals[2] then s.hero:ReduceCD(vals[2]) end
                        HitTarget(s, trg)
                    end
                end
            end
        end
    end
end
--五雷轰顶
_skc[40] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        local rx, ry = s.dat.rangeX.value, s.dat.rangeY.value
        var = s.vals
        if var == nil then
            var = GetDmg(s)
            s.dps = B_Math.ceil(var)
            --[索引,伤害递减,二次打击,半径X，半径Y]
            s.vals = { 0, B_Math.ceil(var * 0.1), s.hero.dat.isStar and 1 or 0, rx * 0.5, ry * 0.5 }
        elseif var[3] > 0 then
            var[1], var[3] = 0, 0
            var = GetDmg(s) * 0.5
            s.vals[2] = B_Math.ceil(var * 0.1)
            s.dps = B_Math.ceil(var)
        else
            s:Dead()
            return
        end
        local map = s.map
        local dr = B_Vector(rx, ry).magnitude * 0.5
        local inX, inY = map:SearchUnitFocus(not s.hero.isAtk)
        if inX - dr < 0 then inX = B_Math.ceil(dr)
        elseif inX + dr >= map.width then inX = map.width - B_Math.ceil(dr) end
        if inY - dr < 0 then inY = B_Math.ceil(dr)
        elseif inY + dr >= map.height then inY = map.height - B_Math.ceil(dr) end

        local units = { { status = 1, pos = B_Vector(inX, inY) } }
        s.units = units
        if qty > 1 then
            var = B_Math.PI * 2 / qty
            for i = 2, qty do
                units[i] =
                {
                    status = 1,
                    pos = B_Vector(inX + B_Math.cos(var * (i - 1)) * dr, inY + B_Math.sin(var * (i - 1)) * dr)
                }
            end
        end
        s.step = 2
    elseif var == 2 then
        local vals = s.vals
        if vals[1] < #s.units then
            vals[1] = vals[1] + 1
            local pos = s.units[vals[1]].pos
            var = s.dps
            s.map:ForeachAreaUnits(pos.x - vals[4], pos.y - vals[5], pos.x + vals[4], pos.y + vals[5], function(trg)
                if var > 0 then
                    if s.hero:SkillDPS(trg, var) then
                        s.map:Log("五雷轰顶对" .. trg.DebugName .. "造成<" .. var .. ">点伤害")
                        HitTarget(s, trg)
                    end
                    var = var - vals[2]
                end
            end)
            WaitForTime(s, 50)
        elseif vals[3] > 0 then
            WaitForTime(s, 300)
            s.step = 1
        else
            s:Dead()
        end
    end
end
--虎啸
_skc[41] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        var = BD_Buff.BD_BuffSingle(10410, s.dat.keep.value, BD_AID.Fear, 1)
        s.buff = var
        for _, u in ipairs(s.map:SearchUnits(not s.hero.isAtk)) do
            u:AddBuff(var)
            HitTarget(s, u)
        end
    end
end
--伏兵连阵
_skc[42] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h, map = s.hero, s.map
        local tp, maxTP = h.TP, h.MaxTP
        local qty = B_Math.ceil(s.dat:GetExtValPercent(1) * maxTP)
        if tp + qty > maxTP then qty = maxTP - tp end
        if qty <= 0 then s:Dead() return end
        local q = qty
        local x1, x2, hx = 0, map.width - 1, B_Math.floor(map.width / 2)
        local y1 = h.y
        local y2 = y1 + 1
        local dy = true
        local cx, cy = 0, 0
        while q > 0 and x1 < hx and x2 > hx do
            if dy then
                y1 = y1 - 1
                cy = y1
            else
                y2 = y2 + 1
                cy = y2
            end
            dy = not dy
            for i = 1, 2 do
                cx = h.isAtk and (i == 1 and x1 or x2) or (i == 1 and x2 or x1)
                if q > 0 and map:PosAvailableAndEmpty(cx, cy) then
                    q = q - 1
                    local u = BD_Soldier(map, cx, cy)
                    u:InitData(h)
                    HitTarget(s, u)
                end
            end
            if y1 < 1 and y2 >= map.height - 1 then
                x1, x2 = x1 + 1, x2 - 1
                y1 = h.y
                y2 = y1 + 1
            end
        end
        if qty > q then
            h:SetTP(qty - (q > 0 and q or 0))
        end
        s:Dead()
    end
end
--虎咆震
_skc[43] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 600)
        s.step = 1
    elseif var == 1 then
        var = BD_Buff.BD_BuffSingle(10430, s.dat.keep.value, BD_AID.Stop, 1)
        s.buff = var
        if s.hero.dat.isStar then
            local isAtk = s.hero.isAtk
            local bf2 = BD_Buff.BD_BuffSingle(10431, s.dat:GetExtKeepMS(1), BD_AID.Str, s.dat:GetExtValInt(2))
            for _, u in ipairs(s.map:SearchUnits()) do
                u:AddBuff(u.isAtk == isAtk and bf2 or var)
                HitTarget(s, u)
            end
        else
            for _, u in ipairs(s.map:SearchUnits(not s.hero.isAtk)) do
                u:AddBuff(var)
                HitTarget(s, u)
            end
        end
        s:Dead()
    end
end
--离间
_skc[44] = _skc[13]
--十面埋伏
_skc[45] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h, map = s.hero, s.map
        local tp, maxTP = h.TP, h.MaxTP
        local qty = B_Math.ceil(s.dat:GetExtValPercent(1) * maxTP)
        if not h.dat.isStar and tp + qty > maxTP then qty = maxTP - tp end
        if qty <= 0 then s:Dead() return end
        local q = qty
        local x1, x2 = h.rival.x - 2, h.rival.x + 2
        local y1 = h.y
        local y2 = y1 + 1
        local dx, dy = h.direction < 0, true
        local cx, cy = 0, 0
        while q > 0 and (x1 >= 0 or x2 < map.width) do
            if dy then
                y1 = y1 - 1
                cy = y1
            else
                y2 = y2 + 1
                cy = y2
            end
            dy = not dy
            for i = 1, 2 do
                cx = dx and (i == 1 and x1 or x2) or (i == 1 and x2 or x1)
                if q > 0 and map:PosAvailableAndEmpty(cx, cy) then
                    q = q - 1
                    local u = BD_Soldier(map, cx, cy)
                    u:InitData(h)
                    HitTarget(s, u)
                end
                if q <= 0 then break end
            end
            if y1 < 2 and y2 >= map.height - 2 then
                x1, x2 = x1 - 1, x2 + 1
                y1 = h.y
                y2 = y1 + 1
            end
        end
        if qty > q then
            h:SetTP(qty - (q > 0 and q or 0))
        end
        s:Dead()
    end
end
--冰爆术
_skc[46] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.buff = BD_Buff.BD_BuffSingle(10460, s.dat.keep.value, BD_AID.MoveSpeed, -s.dat:GetExtValInt(1))
        s.dps = B_Math.ceil(GetDmg(s))
        local rx, ry = s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5
        var = s.hero.rival.pos
        s.pos:Copy(var)
        s.map:ForeachAreaUnits(var.x - rx, var.y - ry, var.x + rx, var.y + ry, _func.dmg_buff(s, "冰爆术", s.hitLst, s.dps, s.buff))
        s:Dead()
    end
end
--御飞刀
_skc[47] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.pos:Copy(s.hero.rival.pos)
        WaitForTime(s, 300)
        s.step = 2
    elseif var == 2 then
        local rx, ry = s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5
        var = s.pos
        s.map:ForeachAreaUnits(var.x - rx, var.y - ry, var.x + rx, var.y + ry, _func.dmg(s, "御飞刀", s.hitLst, s.dps))
        s:Dead()
    end
end
--落石
_skc[48] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.pos:Copy(s.hero.rival.pos)
        WaitForTime(s, 200)
        s.step = 2
    elseif var == 2 then
        local rx, ry = s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5
        var = s.pos
        s.map:ForeachAreaUnits(var.x - rx, var.y - ry, var.x + rx, var.y + ry, _func.dmg(s, "落石", s.hitLst, s.dps))
        s:Dead()
    end
end
--三日月斩
_skc[49] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        var = s.hero
        local hx, hy = var.x, var.y
        var = var.isAtk and 1 or -1
        s.units =
        {
            {
                status = 1, speed = 5,
                pos = B_Vector(hx, hy + 2),
                direction = B_Vector(var, 0),
            },
            {
                status = 1,
                pos = B_Vector(hx + var, hy),
                direction = B_Vector(var, 0),
            },
            {
                status = 1,
                pos = B_Vector(hx + var, hy - 2),
                direction = B_Vector(var, 0),
            }
        }
        s.dicMark = { }
        s.step = 2
    elseif var == 2 then
        local alive = false
        var = s.units[1]
        local map = s.map
        local d = map.deltaTime
        d, var.speed = var.speed * BD_Const.BASE_MOVE_SPEED_UNIT * d, B_Math.slerp(var.speed, 10, 13, d)
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.pos:AddMult(u.direction, d)
                if not map:PosVecAvailable(u.pos) then u.status = 255 end
                for j = 0, 1 do
                    var = map:GetArrivedUnit(u.pos.x, u.pos.y + j)
                    if CheckEnemyWithMark(s, var) and s.hero:SkillDPS(var, s.dps) then
                        map:Log("三日月斩对" .. var.DebugName .. "造成<" .. s.dps .. ">点伤害")
                        HitTarget(s, var)
                    end
                end
            end
        end
    end
end
--野牛冲撞
_skc[50] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        var = B_Math.clamp(s.hero.isAtk and s.map.defMinX - 4 or s.map.atkMaxX + 4, 0, s.map.width - 1)
        s.units =
        {
            {
                status = 1, speed = 5 * BD_Const.BASE_MOVE_SPEED_UNIT,
                pos = B_Vector(ix, s.hero.y),
                direction = B_Vector(s.hero.isAtk and 1 or -1, 0)
            }
        }
        s.dicMark = { }
        WaitForTime(s, 200)
        s.step = 2
    elseif var == 2 then
        local alive = false
        local u = s.units[1]
        if u.status == 1 then
            local map = s.map
            u.pos:AddMult(u.direction, u.speed * map.deltaTime)
            if not map:PosVecAvailable(u.pos) then u.status = 255 end
            var = map:GetArrivedUnit(u.pos.x, u.pos.y)
            if CheckEnemyWithMark(s, var) and s.hero:SkillDPS(var, s.dps) then
                map:Log("野牛冲撞对" .. var.DebugName .. "造成<" .. s.dps .. ">点伤害")
                HitTarget(s, var)
            end
        else
            s:Dead()
        end
    end
end
--集火柱
_skc[51] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        var = s.hero.rival.pos
        s.pos:Copy(var)
        --单半径X，单半径Y，动态半径
        s.vals = { s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5 }
        s.vals[3] = s.vals[1]
        local da = B_Math.PI * 2 / qty
        local a, r = 0, s.vals[1]
        s.units = { }
        for i = 1, qty do
            a = da * (i - 1)
            s.units[i] = 
            {
                time = 0, speed = a,
                pos = B_Vector(var.x + B_Math.cos(a) * r, var.y + B_Math.sin(a) * r)
            }
        end
        s.dicTime = { }
        s.step = 2
    elseif var == 2 then
        local alive = true
        local map, vals = s.map, s.vals
        var = s.units[1]
        var.time = var.time + map.deltaMillisecond
        if var.time >= 500 then
            local r = vals[3]
            if r * 2 < map.height then
                var = map.deltaTime
                vals[3] = vals[3] + 1.5 * var
                local pos = s.pos
                for _, u in ipairs(s.units) do
                    u.speed = u.speed + B_Math.PI * var
                    u.pos:Set(pos.x + B_Math.cos(u.speed) * r, pos.y + B_Math.sin(u.speed) * r)
                end
            else
                alive = false
            end
        end
        if alive then
            local rx, ry = vals[1], vals[2]
            local func = s.func
            if func == nil then
                func = _func.tm_dmg_buf(s, "集火柱", s.hitLst, s.dps)
                s.func = func
            end
            for _, u in ipairs(s.units) do
                u = u.pos
                map:ForeachAreaUnits(u.x - rx, u.y - ry, u.x + rx, u.y + ry, func)
            end
        else
            s:Dead()
        end
    end
end
--圣光荣耀
_skc[52] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = s.hero
        s.dps = B_Math.ceil(GetDmg(s))
        for _, u in ipairs(s.map:SearchUnits(var.isAtk)) do
            var:CureDPS(u, s.dps)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--箭雨
_skc[53] = _skc[11]
--龙卷风暴
_skc[54] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        local range = s.dat:GetExtInt(2)
        if range <=0 then s:Dead() return end
        s.vals = { range * 0.5 }
        if s.hero.dat.isStar then
            s.dps = B_Math.ceil(GetDmg(s))
            s.vals[2] = 0
        else
            s.dps = 0
        end
        GenMultPointUnits(s, qty, range, range)
        var = s.map.random
        for _, u in ipairs(s.units) do
            u.speed = BD_Const.BASE_MOVE_SPEED_UNIT
            u.direction = B_Vector(var:Next(-1, 1), var:Next(-1, 1)):Normalize()
        end
        WaitForTime(s, 600)
        Dead(s, 600 + s.dat.keepSec)
        s.step = 2
    elseif var == 2 then
        local r = s.vals[1]
        local map = s.map
        if s.dps > 0 then
            var = s.vals[2]
            if var > 0 then
                var = var - map.deltaMillisecond
                s.vals[2] = var
            end
        end
        local func = nil
        if var > 0 then
            func = s.func
            if func == nil then
                func = function(trg)
                    if CheckEnemy(s, trg) and getmetatable(trg) == BD_Soldier then
                        trg:SetHP(0, true)
                        map:Log("龙卷风暴对" .. trg.DebugName .. "造成<" .. trg.HP .. ">点伤害")
                        HitTarget(s, trg)
                    end
                end
                s.func = func
            end
        else
            func = s.func2
            if func == nil then
                func = function(trg)
                    if CheckEnemy(s, trg) then
                        if getmetatable(trg) == BD_Soldier then
                            trg:SetHP(0, true)
                            map:Log("龙卷风暴对" .. trg.DebugName .. "造成<" .. trg.HP .. ">点伤害")
                            HitTarget(s, trg)
                        elseif s.vals[2] <= 0 then
                            s.vals[2] = 1000
                            if s.hero:SkillDPS(trg, s.dps) then
                                map:Log("龙卷风暴对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                            end
                        end
                    end
                end
                s.func2 = func
            end
        end
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                local x, y = u.pos:GetAddMult(u.direction, u.speed * map.deltaTime)
                if map:PosAvailable(x, y) then
                    u.pos:Set(x, y)
                else
                    x, y = u.pos:Get()
                end
                map:ForeachAreaUnits(x - r, y - r, x + r, y + r, func)
            end
        end
    end
end
--乾坤扫月
_skc[55] = _skc[39]
--悬灯火
_skc[56] = _skc[27]
--死亡咆哮
_skc[57] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        local h = s.hero
        var = s.dat:GetExtValInt(1)
        s.buff = BD_Buff.BD_BuffSingle(10570, s.dat.keep.value, BD_AID.CPD, -var, BD_AID.CSD, -var)
        var = h.dat.isStar and B_Math.ceil(ProDmg(s, h.Str * (1 + h.CSD * 0.01) * 0.01 * B_Math.lerp(s.dat:GetExtInt(3), s.dat:GetExtInt(2), B_Math.clamp01(B_Math.abs(h.x - h.rival.x) / B_Math.max(1, s.dat:GetExtInt(3)))))) or 0
        s.dps = var
        for _, u in ipairs(s.map:SearchUnits(not h.isAtk)) do
            if var > 0 and getmetatable(u) == BD_Hero and CheckEnemy(s, u) and h:SkillDPS(u, var) then
                s.map:Log("死亡咆哮对" .. u.DebugName .. "造成<" .. var .. ">点伤害")
            end
            u:AddBuff(s.buff)
            HitTarget(s, u)
        end
        s:Dead()
    end
end
--赤壁火
local function PathControlPointGenerator(path)
    local len = #path
    local v1, v2 = path[len], path[len - 1]
    insert(path, B_Vector(v1.x * 2 - v2.x, v1.y * 2 - v2.y))
    v1, v2 = path[1], path[2]
    insert(path, 1, B_Vector(v1.x * 2 - v2.x, v1.y * 2 - v2.y))
    len = #path
    if path[2] == path[len - 1] then
        v1 = path[len - 2]
        path[1]:Copy(v1)
        v1 = path[3]
        path[len]:Copy(v1)
    end
end
local function Interp(path, t)
    local numSections = #path - 3
    local currPt = B_Math.min(B_Math.floor(t * numSections), numSections - 1)
    t = t * numSections - currPt
    local a, b, c, d = path[currPt + 1], path[currPt + 2], path[currPt + 3], path[currPt + 4]
    local t2 = t * t
    local t3 = t2 * t
    return 0.5 * (
        (-a.x + 3 * b.x - 3 * c.x + d.x) * t3
        + (2 * a.x - 5 * b.x + 4 * c.x - d.x) * t2
        + (c.x - a.x) * t
        + 2 * b.x
    ),
    0.5 * (
        (-a.y + 3 * b.y - 3 * c.y + d.y) * t3
        + (2 * a.y - 5 * b.y + 4 * c.y - d.y) * t2
        + (c.y - a.y) * t
        + 2 * b.y
    )
end
--赤壁火
_skc[58] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        var = GetDmg(s)
        s.dps = B_Math.ceil(var)
        local val = s.dat:GetExtPercent(1)
        if var > 0 then
            s.buff = BD_Buff.BD_BuffSingle(10580, s.dat.keepSec, BD_AID.SDmg, B_Math.max(0, B_Math.ceil(var * val)))
        end
        s.dicMark = { }
        --当前时间，总时间
        s.vals = { (s.hero.isAtk and 5 or -5) * BD_Const.BASE_MOVE_SPEED_UNIT }
--        var = 
--        {
--            B_Vector(-13.8440, 29.2970),
--            B_Vector(1.3432, 7.2398),
--            B_Vector(11.5079, 5.1616),
--            B_Vector(22.2571, 6.8855),
--            B_Vector(34.7154, 4.8648),
--            B_Vector(46.8545, 6.4438),
--            B_Vector(55.6976, 10.5887),
--            B_Vector(54.8244, 31.2323),
--        }
--        s.skc58path = var
--        if not s.hero.isAtk  then table.reverse(var)end
        s.pos = table.copy(s.hero.pos)
--        PathControlPointGenerator(var)
        s.step = 2
    elseif var == 2 then
        if s.map:PosAvailable(s.pos.x, s.pos.y) then
--            local h, map = s.hero, s.map
--            s.pos:Set(Interp(s.skc58path, var[1] / var[2]))
--            var[1] = var[1] + map.deltaTime
            s.pos.x = s.pos.x + s.vals[1] * s.map.deltaTime
            local minX, maxX
            if s.hero.isAtk then
                maxX = B_Math.round(s.pos.x)
                minX = maxX - 5
            else
                minX = B_Math.round(s.pos.x)
                maxX = minX + 5
            end
            if maxX < 0 or minX > s.map.width then return end
            minX = B_Math.max(0, minX)
            maxX = B_Math.min(s.map.width, maxX)
            var = s.map.height
            local buff = s.buff
            local EnGetCombatUnit = s.map.EnGetCombatUnit
            local trg
            for i = minX, maxX, 1 do
                for j = 1, var, 1 do
                    trg = EnGetCombatUnit(i, j)
                    if CheckEnemyWithMark(s, trg) and s.hero:SkillDPS(trg, s.dps) then
                        s.map:Log("赤壁火对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                        if buff then trg:AddBuff(s.buff) end
                        HitTarget(s, trg)
                    end
                end
            end
        else
            s:Dead()
        end
    end
end
--群星陨落
_skc[59] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        GenMultPointUnits(s, qty, 3, 3)
        var = s.map.random
        for _, u in ipairs(s.units) do
            u.speed = var:NextInt(2, 5)
            pos = u.pos
            pos.x = pos.x - 0.5
            pos.y = pos.y - 0.5
        end
        s.step = 2
    elseif var == 2 then
        local alive = false
        local h, map = s.hero, s.map
        local dtm = map.deltaMillisecond
        local func = s.func
        if func == nil then
            func = _func.dmg(s, "群星陨落", s.hitLst, s.dps)
            s.func = func
        end
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 350 then
                    u.time, u.status = 0, 255
                    var = u.pos
                    map:ForeachAreaUnits(var.x, var.y, var.x + u.speed, var.y + u.speed, func)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--雷霆万钧
_skc[60] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local qty1 = s.dat:GetExtInt(1)
        local qty2 = s.dat:GetExtInt(2)
        local qty = qty1 + qty2
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        local r1, r2 = 4, 3
        local hr1, hr2 = r1 * 0.5, r2 * 0.5
        --[持续时间，数量1，半径1，半径2]
        s.vals = { s.dat.keepSec + s.map.time, qty1, hr1, hr2 }
        local minX, minY, maxX, maxY
        if qty2 > 0 then
            minX, minY, maxX, maxY = GenMultPointUnits(s, qty2, r2, r2)
        else
            s.units = { }
            minX, minY, maxX, maxY = GetEnemyDenseRange(s)
        end
        if qty1 > 0 then
            var = s.units
            local map = s.map
            local isAtk = s.hero.isAtk
            for i = 1, qty1 do
                insert(s.units, 1,
                {
                    time = 0, status = 1,
                    pos = i == 1 and B_Vector(isAtk and minX or maxX, qty1 == 2 and map.height * 0.25 - 0.5 or map.height * 0.5 - 0.5)
                        or i == 2 and (qty1 == 2 and B_Vector(isAtk and minX or maxX, map.height * 0.75 - 0.5) or B_Vector(isAtk and minX + 2 or maxX, map.height / 6 - 0.5))
                        or i == 3 and B_Vector(isAtk and minX or maxX - 2, map.height * 5 / 6 - 0.5)
                        or i == 4 and B_Vector(isAtk and maxX or minX, qty1 == 5 and map.height * 0.25 - 0.5 or map.height * 0.5 - 0.5)
                        or i == 5 and (qty1 == 5 and B_Vector(isAtk and maxX or minX, map.height * 0.75 - 0.5) or B_Vector(isAtk and maxX or minX + 2, map.height / 6 - 0.5))
                        or i == 6 and B_Vector(isAtk and maxX - 2 or minX, map.height * 5 / 6 - 0.5)
                        or B_Vector(map.random:Next(minX + hr1, maxX - hr1), map.random:Next(minY + hr1, maxY - hr1))
                })
            end
        end
        s.dicTime = { }
        WaitForTime(s, 300)
        s.step = 2
    elseif var == 2 then
        local map, vals, units = s.map, s.vals, s.units
        local qty1, r = vals[2], vals[3]
        local alive = qty1 > 0 and vals[1] > map.time
        local func
        if alive then
            func = s.func
            if func == nil then
                func = _func.tm_dmg_buf(s, "雷霆万钧", s.hitLst, s.dps)
                s.func = func
            end
            for i = 1, qty1 do
                var = units[i]
                if var.status == 1 then
                    var = var.pos
                    map:ForeachAreaUnits(var.x - r, var.y - r, var.x + r, var.y + r, func)
                end
            end
        end
        r = vals[4]
        local dtm = map.deltaMillisecond
        func = s.func2
        if func == nil then
            func = _func.dmg(s, "雷霆万钧", s.hitLst, s.dps)
            s.func2 = func
        end
        for i = qty1, #s.units, 1 do
            var = units[i]
            if var.status == 1 then
                alive = true
                var.time = var.time + dtm
                if var.time >= 100 then
                    var.time, var.status = 0, 255
                    var = var.pos
                    map:ForeachAreaUnits(var.x - r, var.y - r, var.x + r, var.y + r, func)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--仁德
_skc[61] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h, map = s.hero, s.map
        local tp, maxTP = h.TP, h.MaxTP
        local qty = B_Math.ceil(s.dat:GetExtValPercent(1) * maxTP)
        if tp + qty > maxTP then qty = maxTP - tp end
        if qty <= 0 then s:Dead() return end
        local q = qty
        local x1, x2 = h.x - 2, h.x + 2
        local y1 = h.y
        local y2 = y1 + 1
        local dx, dy = h.direction < 0, true
        local cx, cy = 0, 0
        
        var = h.dat.isStar and BD_Buff.BD_BuffSingle(10610, s.dat:GetExtKeepMS(2), BD_AID.Str, s.dat:GetExtValInt(3)) or nil
        s.buff = var

        while q > 0 and (x1 >= 0 or x2 < map.width) do
            if dy then
                y1 = y1 - 1
                cy = y1
            else
                y2 = y2 + 1
                cy = y2
            end
            dy = not dy
            for i = 1, 2 do
                cx = dx and (i == 1 and x1 or x2) or (i == 1 and x2 or x1)
                if q > 0 and map:PosAvailableAndEmpty(cx, cy) then
                    q = q - 1
                    local u = BD_Soldier(map, cx, cy)
                    u:InitData(h)
                    if var then u:AddBuff(var) end
                    HitTarget(s, u)
                end
                if q <= 0 then break end
            end
            if y1 < 2 and y2 >= map.height - 2 then
                x1, x2 = x1 - 1, x2 + 1
                y1 = h.y
                y2 = y1 + 1
            end
        end
        if qty > q then
            h:SetTP(qty - (q > 0 and q or 0))
        end
        s:Dead()
    end
end
--制霸
_skc[62] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        if s.hero.dat.isStar then
            s.buff = BD_Buff.BD_BuffDouble(10620, s.dat.keep.value, BD_AID.Dodge, s.dat:GetExtValInt(1), BD_AID.SSD, -s.dat:GetExtValInt(2))
        else
            s.buff = BD_Buff.BD_BuffSingle(10620, s.dat.keep.value, BD_AID.Dodge, s.dat:GetExtValInt(1))
        end
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--神剑闪
_skc[63] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        WaitForTime(s, 100)
        s.step = 2
    elseif var == 2 then
        s.dps = B_Math.ceil(GetDmg(s))
        var = s.hero
        if var:SkillDPS(var.rival, s.dps) then
            if var.dat.isStar then
                s.buff = BD_Buff.BD_BuffSingle(10630, s.dat:GetExtKeepMS(1), BD_AID.Dmg, B_Math.ceil(ProDmg(s, s.dat:GetExtInt(2), false)))
                var.rival:AddBuff(s.buff)
            end
            s.map:Log("神剑闪对" .. var.rival.DebugName .. "造成<" .. s.dps .. ">点伤害")
        end
        s:Dead()
    end
end
--幻影斩
_skc[64] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffSingle(10640, s.dat.keep.value, BD_AID.Stop, 1)
        s.dicMark = { }
        s.units = 
        {
            {
                status = 1, speed = 0,
                pos = s.hero.pos:Clone(),
                direction = B_Vector(s.hero.isAtk and 1 or -1, 0)
            }
        }
        s.step = 2
    elseif var == 2 then
        local u = s.units[1]
        if u.status == 1 then
            local map = s.map
            var = map.deltaTime
            if u.speed < 10 then u.speed = u.speed + 10 * var end
            u.pos:AddMult(u.direction, u.speed * BD_Const.BASE_MOVE_SPEED_UNIT * var)
            var = map:GetArrivedUnit(u.pos.x, u.pos.y)
            if CheckEnemyWithMark(s, var) and s.hero:SkillDPS(var, s.dps) then
                var:AddBuff(s.buff)
                map:Log("幻影斩对" .. var.DebugName .. "造成<" .. s.dps .. ">点伤害")
                HitTarget(s, var)
            end

            if not map:PosVecAvailable(u.pos) then u.status = 255 end
        else
            s:Dead()
        end
    end
end
--英魂
_skc[65] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.hero:CureDPS(s.hero, B_Math.ceil(s.hero.MaxHP * s.dat:GetExtValPercent(1)))
        s:Dead()
    end
end
--一身是胆
_skc[66] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        if s.hero.dat.isStar then
            s.buff = BD_Buff.BD_BuffDouble(10660, s.dat.keep.value, BD_AID.Dodge, s.dat:GetExtValInt(1), BD_AID.Str, s.dat:GetExtValInt(2))
        else
            s.buff = BD_Buff.BD_BuffSingle(10660, s.dat.keep.value, BD_AID.Dodge, s.dat:GetExtValInt(1))
        end
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--古之恶来
_skc[67] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        var = -s.dat:GetExtValInt(1)
        s.buff = BD_Buff.BD_BuffDouble(10670, s.dat.keep.value, BD_AID.SPD, var, BD_AID.SSD, var)
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        if s.hero.dat.isStar then
            WaitForTime(s, s.buff.lifeTime)
            s.step = 2
        else
            s:Dead()
        end
    elseif var == 2 then
        s.dps = B_Math.ceil(GetDmg(s))
        local rx, ry = s.dat.rangeX.value, s.dat.rangeY.value
        local minX, minY = s.hero.x - rx / 2 - 0.5, s.hero.y - ry / 2 - 0.5
        local maxX, maxY = minX + rx - 0.5, minY + ry - 0.5
        s.map:ForeachAreaUnits(minX, minY, maxX, maxY, _func.dmg(s, "古之恶来", s.hitLst, s.dps))
    end
end
--孤胆刺杀
_skc[68] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        if s.hero.dat.isStar then
            s.buff = BD_Buff.BD_BuffDouble(10680, s.dat.keep.value, BD_AID.Crit, s.dat:GetExtValInt(1), BD_AID.SDodge, s.dat:GetExtValInt(2))
        else
            s.buff = BD_Buff.BD_BuffSingle(10680, s.dat.keep.value, BD_AID.Crit, s.dat:GetExtValInt(1))
        end
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--堕天一击
_skc[69] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffSingle(10680, s.dat:GetExtKeepMS(2), BD_AID.SPD, s.dat:GetExtValInt(1))
        s.hero:AddBuff(BD_Buff.BF_ShortGod)
        WaitForTime(s, 500)
        s.step = 2
    elseif var == 2 then
        local h, map = s.hero, s.map
        local dx = h.isAtk and -1 or 1
        local x, y = h.rival.x + dx, h.y
        for i = x, dx < 0 and 0 or map.width, dx do
            if ForceSetCasterPos(s, x, y) then
                h:ApplyPos()
                break
            end
        end
        var = BD_Buff.BD_BuffSingle(10691, s.dat.keep.value, BD_AID.Stop, 1)
        x = h.x
        local hx, hy = s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5
        map:ForeachAreaUnits(x - hx, y - hy, x + hx, y + hy, function(trg)
            if CheckEnemy(s, trg) and h:SkillDPS(trg, s.dps) then
                trg:AddBuff(var)
                trg:AddBuff(s.buff)
                map:Log("堕天一击对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                HitTarget(s, trg)
            end
        end)
        s:Dead()
    end
end
--药泉
_skc[70] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffSingle(10700, 100, BD_AID.MoveSpeed, -s.dat:GetExtValInt(1))
        var = B_Math.modf(s.dat.rangeX.value / 4)
        local minX, minY, maxX, maxY = GetRange(s, s.hero.x + (s.hero.isAtk and s.map.random:NextInt(1, var) or s.map.random:NextInt(-var, - 1)), s.hero.y)
        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        --[dt,cure,minX,minY,maxX,maxY]
        s.vals = { 0, B_Math.ceil(GetCure(s)), minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5 }
        Dead(s, 370 + s.dat.keep.value)
        WaitForTime(s, 370)
        s.step = 2
    elseif var == 2 then
        local vals = s.vals
        var = s.hitLst
        if var and #var > 0 then s.hitLst = { } end
        var = vals[1] <= 0
        vals[1] = var and 1000 or vals[1] - s.map.deltaMillisecond
        if var and s.dps and s.dps > 0 then
            if s.func then
                var = s.func
            else
                local h, cure = s.hero, vals[2]
                var = function(trg)
                    if CheckEnemy(s, trg) then
                        if h:SkillDPS(trg, s.dps) then
                            s.map:Log("药泉对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                        end
                        if not trg:ResetBuff(10700) then trg:AddBuff(s.buff) end
                        HitTarget(s, trg)
                    elseif trg.isAtk == h.isAtk and not trg.isDead then
                        h:CureDPS(trg, cure)
                        s.map:Log("药泉对" .. trg.DebugName .. "造成<" .. cure .. ">点治疗")
                    end
                end
                s.func = var
            end
        elseif s.func2 then
            var = s.func2
        else
            var = _func.buff(s, s.hitLst, s.buff)
            s.func2 = var
        end    
        s.map:ForeachAreaUnits(vals[3], vals[4], vals[5], vals[6], var)
    end
end
--倾国倾城
_skc[71] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 1000)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtValPercent(1)
        if qty <= 0 then s:Dead() return end
        local h = s.hero
        var = s.map:SearchUnits(not h.isAtk, BD_Soldier)
        qty = B_Math.min(B_Math.ceil(h.rival.MaxTP * qty), #var)
        if qty > 0 then
            for _, u in ipairs(var) do
                u:SetBelong(h)
                HitTarget(s, u)
            end
            h:SetTP(qty)
            h.rival:SetTP(-qty)
        end
        s:Dead()
    end
end
--洛神决
_skc[72] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 1200)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        var = s.hero.rival
        if s.hero:SkillDPS(var, s.dps) then
            s.map:Log("洛神决对" .. var.DebugName .. "造成<" .. s.dps .. ">点伤害")
            var:AddBuff(BD_Buff.BD_BuffSingle(10720, s.dat.keep.value, BD_AID.Stop, 1))
            if s.hero.dat.isStar then
                local bf = BD_Buff(10721, s.dat:GetExtKeepMS(1))
                local v = s.dat:GetExtKeepMS(2)
                bf:SetAtt(BD_AID.SPD, v)
                bf:SetAtt(BD_AID.SSD, v)
                v = -s.dat:GetExtKeepMS(3)
                bf:SetAtt(BD_AID.CPD, v)
                bf:SetAtt(BD_AID.CSD, v)
                s.buff = bf
                var:AddBuff(bf)
            end
            HitTarget(s, var)
        end
        s:Dead()
    end
end
--死亡沼泽
_skc[73] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffSingle(10730, 100, BD_AID.MoveSpeed, -s.dat:GetExtValInt(1))
        local minX, minY, maxX, maxY = GetEnemyDenseRange(s)
        --[dr,minX,minY,maxX,maxY]
        s.vals = { 0, minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5 }
        s.pos:Set((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        Dead(s, 370 + s.dat.keep.value)
        WaitForTime(s, 370)
        s.step = 2
    elseif var == 2 then
        local vals = s.vals
        var = s.hitLst
        if var and #var > 0 then s.hitLst = { } end
        var = vals[1] > 0
        vals[1] = var and vals[1] - s.map.deltaMillisecond or 1000
        if var and s.dps and s.dps > 0 then
            if s.func then
                var = s.func
            else
                var = _func.range_dmg_buff(s, "死亡沼泽", s.hitLst, s.dps, s.buff)
                s.func = var
            end
        elseif s.func2 then
            var = s.func2
        else
            var = _func.buff(s, s.hitLst, s.buff)
            s.func2 = var
        end
        s.map:ForeachAreaUnits(vals[2], vals[3], vals[4], vals[5], var)
    end
end
--虎痴
_skc[74] = function(s)
    
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
         local bf = BD_Buff(10740, s.dat.keep.value)
         local v = -s.dat:GetExtKeepMS(1)
         bf:SetAtt(BD_AID.SPD, v)
         bf:SetAtt(BD_AID.SSD, v)
         v = s.dat:GetExtKeepMS(2)
         bf:SetAtt(BD_AID.CPD, v)
         bf:SetAtt(BD_AID.CSD, v)
         s.buff = bf
         s.hero:AddBuff(bf)
         HitTarget(s, s.hero)
         s:Dead()
    end
end
--谦逊
_skc[75] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = s.dat:GetExtValInt(1)
        s.buff = BD_Buff.BD_BuffTriple(10750, s.dat.keep.value, BD_AID.Str, var, BD_AID.Wis, var, BD_AID.Cap, var)
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        s:Dead()
    end
end
--爆裂箭
_skc[76] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffSingle(10760, s.dat.keep.value, BD_AID.Stop, 1)
        var = s.hero
        s.units =
        {
            {
                status = 1, speed = 5,
                pos = var.pos:Clone(),
                direction = var.rival.pos - var.pos,
            }
        }
        s.step = 2
    elseif var == 2 then
        local h, u = s.hero, s.units[1]
        var = h.rival.pos - u.pos
        if var.magnitude > 1 then
            local d = s.map.deltaTime
            d, u.speed = u.speed * BD_Const.BASE_MOVE_SPEED_UNIT * d, B_Math.slerp(u.speed, 10, 13, d)
            u.pos:AddMult(var:Normalize(), d)
            if not s.map:PosVecAvailable(u.pos) then s:Dead() end
        else
            if h:SkillDPS(h.rival, s.dps, s.dat:GetExtVal(1) * 100 > s.map.random:NextInt(0, 10000)) then
                s.map:Log("爆裂箭对" .. h.rival.DebugName .. "造成<" .. s.dps .. ">点伤害")
                h.rival:AddBuff(s.buff)
                HitTarget(s, h.rival)
            end
            s:Dead()
        end
    end
end
--逼战
_skc[77] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        var = -s.dat:GetExtValInt(1)
        if s.hero.dat.isStar then
            s.buff = BD_Buff.BD_BuffTriple(10770, s.dat.keep.value, BD_AID.SPD, var, BD_AID.SSD, var, BD_AID.Str, s.dat:GetExtValInt(2))
        else
            s.buff = BD_Buff.BD_BuffDouble(10770, s.dat.keep.value, BD_AID.SPD, var, BD_AID.SSD, var)
        end
        s.hero:AddBuff(s.buff)
        s.hero.rival:AddBuff(BD_Buff.BD_BuffSingle(10771, s.buff.lifeTime, BD_AID.FF, 1))
        HitTarget(s, s.hero)
        HitTarget(s, s.hero.rival)
        s:Dead()
    end
end
--地动波
_skc[78] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffSingle(10780, s.dat.keep.value, BD_AID.Stop, 1)
        local rx, ry = s.dat.rangeX.value, s.dat.rangeY.value
        local minX, minY = s.hero.x - rx / 2 - 0.5, s.hero.y - ry / 2 - 0.5
        local maxX, maxY = minX + rx - 0.5, minY + ry - 0.5
        s.map:ForeachAreaUnits(minX, minY, maxX, maxY, _func.dmg_buff(s, "地动波", s.hitLst, s.dps, s.buff))
        s:Dead()
    end
end
--金钟罩
_skc[79] = _skc[24]
--白马加身
_skc[80] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        var = s.hero
        local keep = s.dat.keep.value
        var:AddBuff(BD_Buff.BD_BuffDouble(10800, keep, BD_AID.God, 1, BD_AID.Stop, 1))
        s.dps = B_Math.ceil(GetDmg(s))
        s.buff = BD_Buff.BD_BuffSingle(10801, s.dat:GetExtKeep(2), BD_AID.Stop, 1)
        local dr = var.isAtk and 1 or -1
        --dr, data.GetExtValPercent(0) * BD_Const.BASE_MOVE_SPEED_UNIT * dr
        s.vals = { dr, s.dat:GetExtValPercent(1) * BD_Const.BASE_MOVE_SPEED_UNIT * dr }
        var = var.pos
        s.pos:Copy(var)
        Dead(s, keep)
        s.step = 2
    elseif var == 2 then
        local h = s.hero
        if h.isAlive then
            local vals = s.vals
            local pos = s.pos
            local posx = pos.x + vals[2] * s.map.deltaTime
            if s.func == nil then
                s.func = function(trg)
                    if CheckEnemy(s, trg) then
                        if getmetatable(trg) == BD_Hero then
                            if h:SkillDPS(trg, s.dps) then
                                trg:AddBuff(s.buff)
                                s.map:Log("白马加身对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                                HitTarget(s, trg)
                            end
                            s:Dead()
                        else
                            trg:SetHP(0, true)
                            trg:Dead()
                        end
                    end
                end
            end
            s.map:ForeachAreaUnits(B_Math.min(posx, pos.x) - 0.8, pos.y - 0.8, B_Math.max(posx, pos.x) + 0.8, pos.y + 0.8, s.func)
            
            local x
            local isRetreat = h.Command == QYBattle.BAT_CMD.Retreat
            if h.isAtk then
                posx = B_Math.min(posx, h.rival.pos.x - 0.5)
                x = B_Math.clamp(isRetreat and B_Math.floor(posx) or B_Math.ceil(posx), 0, h.rival.x - 1)
            else
                posx = B_Math.min(posx, h.rival.pos.x + 0.5)
                x = B_Math.clamp(isRetreat and B_Math.ceil(posx) or B_Math.floor(posx), h.rival.x + 1, s.map.width - 1)
            end
            ForceSetCasterPos(s, x, h.y)
            pos.x = posx
            h:SetPos(pos.x, pos.y)
            h.direction = vals[1]
            if s.isAlive and posx >= 0 and posx < s.map.width then return end
            h:RemoveBuff(10800)
            s:Dead()
        end
    end
end
--星辰爆裂
_skc[81] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        if s.map.hasEvent then s.eftLst = { } end
        s.dicMark = { }
        local dat = s.dat
        var = GetDmg(s)
        s.dps = B_Math.ceil(var)
        s.buff = BD_Buff.BD_BuffSingle(10810, dat:GetExtKeep(3), BD_AID.Stop, 1)
        local vals =
        {
            -- 1 冰箭伤害
            B_Math.ceil(var * dat:GetExtPercent(2)),
            -- 2 冰箭存活时间
            dat:GetExtInt(6),
            -- 3 冰箭下次发射时间
            s.map.time,
            -- 4 冰箭发射时间间隔
            0,
            -- 5 冰球伤害半径
            1,
            -- 6 冰球爆炸半径X
            dat.rangeX.value * 0.5,
            -- 7 冰球爆炸半径Y
            dat.rangeY.value * 0.5,
            -- 8 当前发射角
            s.hero.isAtk and B_Math.PI or 0,
            -- 9 发射角增量
            0.4,
        }
        s.vals = vals

        var = B_Math.min(dat:GetExtInt(1), 50)
        if var > 0 then
            vals[4] = B_Math.round(1000 / var)
            vals[9] = B_Math.PI * B_Math.max(dat:GetExtPercent(7), 0.5) * vals[4] * 0.001
            var = B_Math.floor(vals[2] * 0.001 * var) + 1
        else
            var = 0
        end
        
        vals =
        {
            {
                status = 1, speed = dat:GetExtPercent(4) * BD_Const.BASE_MOVE_SPEED_UNIT,
                pos = B_Vector(s.hero.pos.x + (s.hero.isAtk and 1 or -1), s.hero.pos.y),
                direction = B_Vector(s.hero.isAtk and 1 or -1, 0)
            }
        }
        s.units = vals
        if var > 0 then
            var = dat:GetExtPercent(5) * BD_Const.BASE_MOVE_SPEED_UNIT
            for i = 2, var + 1 do
                vals[i] = { status = 0, speed = var, pos = B_Vector(), direction = B_Vector() }
            end
        end
        s.step = 2
    elseif var == 2 then
        local alive = false
        local vals, units = s.vals, s.units
        local map = s.map
        local dt = map.deltaTime
        local u = units[1]
        local pos = u.pos
        if u.status == 1 then
            u.pos:AddMult(u.direction, u.speed * dt)
            var = vals[5]
            if s.func == nil then
                local h = s.hero
                s.func = function(trg)
                    if CheckEnemyWithMarkIdx(s, trg, 1) then
                        if h:SkillDPS(trg, s.dps) then
                            if getmetatable(trg) == BD_Hero then
                                u.status = 2
                                trg:AddBuff(s.buff)
                                EffectTarget(s, trg)
                            end
                            map:Log("星辰爆裂对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                            HitTarget(s, trg);
                        elseif getmetatable(trg) == BD_Hero then
                            u.status = 2
                        end
                    end
                end
            end
            map:ForeachAreaUnits(pos.x - var, pos.y - var, pos.x + var, pos.y + var, s.func)
            if u.status == 2 then
                var = vals[6]
                map:ForeachAreaUnits(pos.x - var, pos.y - vals[7], pos.x + var, pos.y + vals[7], function(trg)
                    if getmetatable(trg) == BD_Hero then return end
                    if CheckEnemy(s, trg) then
                        if s.hero:SkillDPS(trg, 0) then
                            trg:AddBuff(s.buff)
                            EffectTarget(s, trg)
                        end
                        if CheckEnemyWithMarkIdx(s, trg, 1) and s.hero:SkillDPS(trg, s.dps) then
                            map:Log("星辰爆裂对" .. trg.DebugName .. "造成<" .. s.dps + ">点伤害")
                            HitTarget(s, trg)
                        end
                    end
                end)
            elseif map:PosVecAvailable(pos) then
                alive = true
            else
                u.status = 255
            end
        else
            vals[4] = 0
        end

        local dtm = map.deltaMillisecond
        for i = 2, #units, 1 do
            u = units[i]
            if u.status == 1 then
                u.time = u.time + dtm
                u.pos:AddMult(u.direction, u.speed * dt)
                var = map:GetArrivedUnit(u.pos.x, u.pos.y)
                if CheckEnemyWithMarkIdx(s, var, i) and s.hero:SkillDPS(var, vals[1]) then
                    map:Log("星辰爆裂对" .. var.DebugName .. "造成<" .. vals[1] .. ">点伤害")
                    HitTarget(s, var)
                end
                if u.time < vals[2] and map:PosVecAvailable(u.pos) then
                    alive = true
                else
                    u.status = 255
                end
            elseif vals[4] > 0 and vals[3] <= map.time then
                alive = true
                vals[3] = vals[3] + vals[4]
                u.status, u.time = 1, 0
                u.direction:Set(B_Math.cos(vals[8]), B_Math.sin(vals[8]))
                u.pos:Set(pos.x + u.direction.x, pos.y + u.direction.y)
                vals[8] = vals[8] + vals[9]
                for _, m in pairs(s.dicMark) do m[i] = false end
            end
        end
        if not alive then s:Dead() end
    end
end
--九霄神雷
_skc[82] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        var = GetDmg(s)
        local pos, r = s.hero.rival.pos, s.map.height * 0.5
        s.dicMark = { }
        s.dps = B_Math.ceil(var)
        s.buff = BD_Buff.BD_BuffSingle(10820, s.dat:GetExtKeep(3), BD_AID.Fixed, 1)
        s.pos:Copy(pos)
        --[电柱伤害,动态半径,半径速度,单半径X,爆炸半径x,爆炸半径y]
        s.vals = { B_Math.ceil(s.dat:GetExtPercent(2) * var), r, 1.5, 1, s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5 }
        s.units = { }
        var = B_Math.PI * 2 / qty
        for i = 1, qty do
            local a = var * (i - 1)
            s.units[i] =
            {
                status = 0, speed = a, time = 0,
                pos = B_Vector(pos.x + B_Math.cos(a) * r, pos.y + B_Math.sin(a) * r)
            }
        end
        s.step = 2
    elseif var == 2 then
        local map, pos, vals = s.map, s.pos, s.vals
        s.units[1].time = s.units[1].time + s.map.deltaMillisecond
        local r = vals[2]
        if r > 0 then
            var = map.deltaTime
            vals[2] = r - vals[3] * var
            vals[3] = vals[3] + 2.8 * var
            local rd = vals[4]
            local pos1 = nil
            for i, u in ipairs(s.units) do
                u.speed = u.speed + B_Math.PI * var
                u.pos:Set(pos.x + B_Math.cos(u.speed) * r, pos.y + B_Math.sin(u.speed) * r)
                pos1 = u.pos
                map:ForeachAreaUnits(pos1.x - rd, pos1.y - rd, pos1.x + rd, pos1.y + rd, function(trg)
                    if CheckEnemyWithMarkIdx(s, trg, i) and s.hero:SkillDPS(trg, vals[1]) then
                        trg:AddBuff(s.buff)
                        map:Log("九霄神雷对" .. trg.DebugName .. "造成<" .. vals[1] .. ">点伤害");
                        HitTarget(s, trg)
                    end
                end)
            end
        else
            local crit = s.hero.dat.isStar and s.dat:GetExtInt(4) * 100 > map.random:NextInt(0, 10000)
            if s.func == nil then
                s.func = function(trg)
                    if CheckEnemy(s, trg) and s.hero:SkillDPS(trg, s.dps, crit) then
                        map:Log("九霄神雷对" .. trg.DebugName .. "造成<" .. s.dps .. ">点伤害")
                    end
                end
            end
            map:ForeachAreaUnits(pos.x - vals[5], pos.y - vals[6], pos.x + vals[5], pos.y + vals[6], s.func)
            s:Dead()
        end
    end
end
--奇谋
_skc[83] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h = s.hero
        var = h.TP
        if var > 0 and var > h.rival.TP then
            var = BD_Buff.BD_BuffDouble(10830, s.dat.keep.value, BD_AID.Str, s.dat:GetExtValInt(2), BD_AID.MSPA, s.dat:GetExtValInt(3))
            s.buff = var
            for _, u in ipairs(s.map:SearchUnits(h.isAtk, BD_Soldier)) do
                u:AddBuff(var)
                HitTarget(s, u)
            end
        else
            local qty = B_Math.ceil(s.dat:GetExtValPercent(1) * h.MaxTP)
            if qty <= 0 then s:Dead() return end
            local map = s.map
            local q = qty
            local x1, x2, hx = 0, map.width - 1, B_Math.floor(map.width / 2)
            local y1 = h.y
            local y2 = y1 + 1
            local dy = true
            local cx, cy = 0, 0
            while q > 0 and x1 < hx and x2 > hx do
                if dy then
                    y1 = y1 - 1
                    cy = y1
                else
                    y2 = y2 + 1
                    cy = y2
                end
                dy = not dy
                for i = 1, 2 do
                    cx = h.isAtk and (i == 1 and x1 or x2) or (i == 1 and x2 or x1)
                    if q > 0 and map:PosAvailableAndEmpty(cx, cy) then
                        q = q - 1
                        local u = BD_Soldier(map, cx, cy)
                        u:InitData(h)
                        HitTarget(s, u)
                    end
                    if q <= 0 then break end
                end
                if y1 < 1 and y2 >= map.height - 1 then
                    x1, x2 = x1 + 1, x2 - 1
                    y1 = h.y
                    y2 = y1 + 1
                end
            end
            if qty > q then
                h:SetTP(qty - (q > 0 and q or 0))
            end
        end
        s:Dead()
    end
end
--凤舞九天
_skc[84] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local dat = s.dat
        local qty = dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        --定身BUF
        s.buff = BD_Buff.BD_BuffSingle(10840, dat:GetExtKeepMS(2), BD_AID.Fixed, 1)
        s.hero.rival:AddBuff(s.buff)
        --buf暗器 3种BUF
        s.buffs = { }
        --暗器
        s.units = { }
        var = B_Math.max(120, B_Math.floor(dat.keep.value / qty))
        local rnd = s.map.random
        for i = 1, qty do
            s.units[i] =
            {
                status = rnd:NextInt(1, 5),
                time = i > 1 and (s.units[i - 1].time - rnd:NextInt(100, var)) or 0,
            }
        end
        --附加值
        local str, wis = s.hero.Str, s.hero.Wis
        s.vals = 
        {
            --[1] 飞刀伤害 武力%
            B_Math.ceil(ProDmg(s, dat:GetExtPercent(4) * str)),
            --[2] 飞轮伤害 武力%
            B_Math.ceil(ProDmg(s, dat:GetExtPercent(5) * str)),
            --[3] 冰箭伤害 智力%
            B_Math.ceil(ProDmg(s, dat:GetExtPercent(6) * wis)),
            --[4] 火失伤害 智力%
            B_Math.ceil(ProDmg(s, dat:GetExtPercent(7) * wis)),
            --[5] 飞刀BUF值 受伤增加%
            dat:GetExtValInt(8),
            --[6] 冰箭BUF值 移速降低%
            dat:GetExtValInt(9),
            --[7] 火失BUF值 伤害 智力%
            B_Math.ceil(ProDmg(s, dat:GetExtPercent(10) * wis)),
            --[8] BUF时间
            dat:GetExtKeepMS(3),
        }
        s.step = 2
        WaitForTime(s, 300)
    elseif var == 2 then
        local alive = false
        local h, map, vals, buffs = s.hero, s.map, s.vals, s.buffs
        local rival = h.rival
        local dtm = map.deltaMillisecond
        for _, u in ipairs(s.units) do
            if u.status >= 1 and u.status <= 4 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 300 then
                    var = u.status + 1
                    u.status = 255
                    if h:SkillDPS(rival, vals[var], var == 2) then
                        map:Log("凤舞九天[" .. var .. "]对" .. rival.DebugName .. "造成<" .. vals[var] .. ">点伤害")
                        HitTarget(s, rival)
                        if var ~= 2 then
                            if var == 1 then --飞刀BUF
                                if buffs[1] == nil then
                                    buffs[1] = BD_Buff.BD_BuffDouble(10841, vals[8], BD_AID.SPD, vals[5], BD_AID.SSD, vals[5])
                                end
                            elseif var == 3 then --冰箭BUF
                                if buffs[2] == nil then
                                    buffs[2] = BD_Buff.BD_BuffSingle(10843, vals[8], BD_AID.MoveSpeed, -vals[6])
                                end
                            elseif var == 4 then --火失BUF
                                if buffs[4] == nil then
                                    buffs[4] = BD_Buff.BD_BuffSingle(10844, vals[8], BD_AID.SDmg, vals[7])
                                end
                            end
                            var = buffs[var]
                            if var then rival:AddBuff(var) end
                        end
                    end
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--日月双辉
_skc[85] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        var = BD_Buff.BD_BuffSingle(10850, s.dat.keep.value, BD_AID.SDmg, B_Math.ceil(ProDmg(s, s.dat:GetExtPercent(1) * s.hero.Wis)))
        s.buff = var
        s.vals =
        {
            -- [1] 伤害
            B_Math.ceil(ProDmg(s, s.dat:GetExtPercent(2) * s.hero.Wis)),
            -- [2] 范围X
            s.dat.rangeX.value * 0.5,
            -- [3] 范围Y
            s.dat.rangeY.value * 0.5,
        }
        s.dicMark = { }
        s.list = { }
        if s.map.hasEvent then s.eftLst = { } end
        for _, u in pairs(s.map.combatUnits) do
            if CheckEnemy(s, u) then
                u:AddBuff(var)
                EffectTarget(s, u)
            end
        end
        WaitForTime(s, 1200)
        s.step = 2
    elseif var == 2 then
        var = s.hero.rival
        if s.hero:SkillDPS(var, s.dps) then
            s.dicMark[var] = nil
            insert(s.list, var)
            s.step = 3
            s.map:Log("日月双辉-月击对" .. var.DebugName .. "造成<" .. s.dps .. ">点伤害")
            HitTarget(s, var)
            WaitForTime(s, 200)
        else
            s:Dead()
        end
    elseif var == 3 then
        var = s.list
        if #var > 0 then
            s.list = { }
            local map = s.map
            local func = s.func
            if func == nil then
                local h, dmg, dicMark = s.hero, s.vals[1], s.dicMark
                func = function(trg)
                    if CheckEnemy(s, trg) and h:SkillDPS(trg, dmg) then
                        map:Log("日月双辉-月爆对" .. trg.DebugName .. "造成<" .. dmg .. ">点伤害")
                        if dicMark[trg] or not trg:ContainsBuff(10850) then return end
                        dicMark[trg] = true
                        insert(s.list, trg)
                        HitTarget(s, trg)
                    end
                end
            end
            local rx, ry = s.vals[2], s.vals[3]
            for _, u in pairs(var) do
                u = u.pos
                map:ForeachAreaUnits(u.x - rx, u.y - ry, u.x + rx, u.y + ry, func)
            end
        end
        if #s.list > 0 then
            WaitForTime(s, 200)
        else
            s:Dead()
        end
    end
end
--天下布武
_skc[86] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 200)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        var = s.dat:GetExtValInt(1)
        s.buff = BD_Buff.BD_BuffDouble(10860, s.dat.keep.value, BD_AID.SPD, -var, BD_AID.SSD, -var)
        s.hero:AddBuff(s.buff)
        if s.hero.dat.isStar then
            var = s.dat:GetExtValInt(3)
            s.buff2 = BD_Buff.BD_BuffDouble(10861, s.dat:GetExtKeepMS(4), BD_AID.SPD, var, BD_AID.SSD, var)
        end
        s.vals =
        {
            -- [1] 下次伤害时间
            s.map.time,
            -- [2] 伤害间隔时间
            B_Math.max(s.dat:GetExtInt(2), 100),
            -- [3] 半径X
            s.dat.rangeX.value * 0.5,
            -- [4] 半径Y
            s.dat.rangeY.value * 0.5,
        }
        Dead(s, s.dat.keep.value)
        s.step = 2
    elseif var == 2 then
        var = s.vals
        if var[1] > s.map.time then return end
        var[1] = var[1] + var[2]
        local pos = s.hero.pos
        local rx, ry = var[3], var[4]
        if s.buff2 then
            if s.hitLst and #s.hitLst > 0 then s.hitLst = { } end
            if s.func == nil then s.func = _func.dmg_buff(s, "天下布武", s.hitLst, s.dps, s.buff2) end
            s.map:ForeachAreaUnits(pos.x - rx, pos.y - ry, pos.x + rx, pos.y + ry, s.func)
        else
            if s.func == nil then s.func = _func.dmg(s, "天下布武", s.hitLst, s.dps) end
            s.map:ForeachAreaUnits(pos.x - rx, pos.y - ry, pos.x + rx, pos.y + ry, s.func)
        end
    end
end
--五行天崩
_skc[87] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        local qty = 1
        var = s.dat:GetExtInt(2) * 100
        local rnd = s.map.random
        for i = 1, s.dat:GetExtInt(1) - 1, 1 do
            if var > rnd:NextInt(0, 10000) then
                qty = qty + 1
            end
        end
        s.vals = { qty, 0 }
        WaitForTime(s, 1960)
        s.step = 2
    elseif var == 2 then
        var = s.vals
        if var[1] > var[2] then
            var[2] = var[2] + 1
                var = B_Math.ceil(GetDmg(s))
            if s.hero:SkillDPS(s.hero.rival, var) then
                s.map.Log("五行天崩对" .. s.hero.rival.DebugName .. "造成<" .. var .. ">点伤害")
            end
            WaitForTime(s, 120)
        else
            s:Dead()
        end
    end
end
--风牙破天
_skc[88] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif var == 1 then
        WaitForTime(s, 500)
        s.step = 2
    elseif var == 2 then
        s.dps = B_Math.ceil(s.hero.dat.isStar and GetDmg(s) * (1 + s.dat:GetExtPercent(1)) or GetDmg(s))
        if s.hero:SkillDPS(s.hero.rival, s.dps) then
            s.map:Log("风牙破天对" .. s.hero.rival.DebugName .. "造成<" .. s.dps .. ">点伤害")
        end
        s:Dead()
    end
end
--幻梦琴音
_skc[89] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 100)
        s.step = 1
    elseif var == 1 then
        WaitForTime(s, 500)
        s.step = 2
    elseif var == 2 then
        s.dps = B_Math.ceil(GetDmg(s))
        if s.hero:SkillDPS(s.hero.rival, s.dps) then
            s.buff = BD_Buff.BD_BuffSingle(10890, s.dat.keep.value, BD_AID.DmgBack, s.dat:GetExtValInt(1))
            s.hero.rival:AddBuff(s.buff)
            s.map:Log("幻梦琴音" .. s.hero.rival.DebugName .. "造成<" .. s.dps .. ">点伤害")
        end
        s:Dead()
    end
end
--碧落
_skc[90] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 1000)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetDmg(s))
        local h = s.hero
        if h:SkillDPS(h.rival, s.dps) then
            s.map:Log("碧落对" .. h.rival.DebugName .. "造成<" .. s.dps .. ">点伤害")
            HitTarget(s, h.rival)
        end
        local dat = s.dat
        local minDis, maxDis = dat:GetExtInt(3), dat:GetExtInt(4)
        local rate = B_Math.clamp01(((B_Math.abs(h.pos.x - h.rival.pos.x) - minDis)) / (maxDis - minDis))
        var = dat.rangeX.value
        local rangeX = (var + B_Math.max(dat:GetExtInt(1) - var, 0) * rate) * 0.5
        var = dat.rangeY.value
        local rangeY = (var + B_Math.max(dat:GetExtInt(2) - var, 0) * rate) * 0.5
        var = h.rival.pos
        local vals =
        {
            --[1] dt_cur, [2] dt_max, [3] dmg_rate
            0, dat:GetExtInt(6), dat:GetExtInt(5),
            --[4]minX,[5]minY,[6]maxX,[7]maxY
            var.x - rangeX, var.y - rangeY, var.x + rangeX, var.y + rangeY
        }
        s.vals = vals
        s.pos:Copy(var)
        var = dat.keep.value
        if var > 0 then
            Dead(s, var + 100)
            WaitForTime(s, 100)
            s.step = 2
        else
            s:Dead()
        end
    elseif var == 2 then
        if s.vals[1] > s.map.time then return end
        local vals = s.vals
        vals[1] = s.map.time + vals[2]
        var = B_Math.ceil(GetDmg(s) * vals[3] * 0.01)
        if s.hitLst and #s.hitLst > 0  then s.hitLst = { } end
        s.map:ForeachAreaUnits(vals[4], vals[5], vals[6], vals[7], _func.dmg(s, "碧落", s.hitLst, var))
    end
end
--掌控
_skc[91] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 600)
        s.step = 1
    elseif var == 1 then
        local dat = s.dat
        var = dat.keep.value
        s.buff = BD_Buff.BD_BuffDouble(10910, var, BD_AID.Fixed, 1, BD_AID.Silence, 1)
        if s.hero.dat.isStar then
            local bf = BD_Buff(10911, var)
            var = -dat:GetExtValInt(2)
            bf:SetAtt(BD_AID.SPD, var)
            bf:SetAtt(BD_AID.SSD, var)
            bf:SetAtt(BD_AID.Fixed, 1)
            bf:SetAtt(BD_AID.Silence, 1)
        end
        WaitForTime(s, 200)
        s.step = 2
        local qty = B_Math.ceil(dat:GetExtValPercent(1) * s.hero.MaxTP)
        if qty > 0 then
            local h, map = s.hero, s.map
            local x1 = B_Math.floor(map.width / 2)
            local x2 = x1 + 1
            local y1 = h.y
            local y2 = y1 + 1
            local q = qty
            local dx, dy = h.direction < 0, true
            local cx, cy = 0, 0
            while q > 0 and (x1 >= 0 or x2 < map.width) do
                if dy then
                    y1 = y1 - 1
                    cy = y1
                else
                    y2 = y2 + 1
                    cy = y2
                end
                dy = not dy
                for i = 1, 2 do
                    cx = dx and (i == 1 and x1 or x2) or (i == 1 and x2 or x1)
                    if q > 0 and map:PosAvailableAndEmpty(cx, cy) then
                        q = q - 1
                        local u = BD_Soldier(map, cx, cy)
                        u:InitData(h)
                    end
                    if q <= 0 then break end
                end
                if y1 < 2 and y2 >= map.height - 2 then
                    x1, x2 = x1 - 1, x2 + 1
                    y1 = h.y
                    y2 = y1 + 1
                end
            end
            if qty > q then
                h:SetTP(qty - (q > 0 and q or 0))
            end
        end
    elseif var == 2 then
        if s.buff2 then
            s.hero:AddBuff(s.buff2)
            s.hero.rival:AddBuff(s.buff)
        else
            s.hero:AddBuff(s.buff)
            s.hero.rival:AddBuff(s.buff)
        end
    end
end
--七进七出
_skc[92] = function(s)
    local var = s.step
    if var == 0 then
        s.vals = { s.dat:GetExtInt(1), s.dat:GetExtKeep(2), 0 }
        s.buff = BD_Buff.BD_BuffDouble(10920, B_Math.max(500, s.vals[2] + 500), BD_AID.God, 1, BD_AID.Stop, 1)
        s.hero:AddBuff(s.buff)
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = s.vals
        if var[1] > 0 then
            var[2] = B_Math.modf(var[2] / var[1])
            s.dps = B_Math.ceil(GetDmg(s))
        end
        WaitForTime(s, 60)
        s.step = 2
    elseif var == 2 then
        var = s.vals
        print(kjson.print(var))
        if var[1] > 0 then
            if var[3] < s.map.time then
                var[1] = var[1] - 1
                var[3] = s.map.time + var[2]
                var = s.hero
                if var:SkillDPS(var.rival, s.dps, false, not var.dat.isStar) then
                    s.map:Log("七进七出对" .. var.rival.DebugName .. "造成<" .. s.dps .. ">点伤害")
                end
            end
        else
            s.buff2 = BD_Buff.BD_BuffSingle(10921, s.dat:GetExtKeep(3), BD_AID.Stop, 1)
            local rx, ry = s.dat.rangeX.value * 0.5, s.dat.rangeY.value * 0.5
            local dodge = s.dat.isStar
            var = s.hero.pos
            s.map:ForeachAreaUnits(var.x - rx, var.y - ry, var.x + rx, var.y + ry, function(trg)
                if CheckEnemy(s, trg) and (dodge or s.hero:SkillDPS(trg, 0)) then
                    trg:AddBuff(s.buff2)
                    HitTarget(s, trg)
                end
            end)
            s:Dead()
        end
    end
end
--能量充盈
_skc[93] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.dps = B_Math.ceil(GetEnergy(s))
        s.hero:SufferEnergy(s.dps)
        s.map:Log("能量灌注恢复" .. s.hero.DebugName .. "<" .. s.dps .. ">点技力")
        s:Dead()
    end
end
--风火灭世
_skc[94] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local dat, pos = s.dat, s.pos
        var = GetDmg(s)
        s.dps = B_Math.ceil(var)
        pos:Copy(s.hero.rival.pos)

        --灼烧BUFF
        s.buff = BD_Buff.BD_BuffSingle(10940, dat:GetExtKeepMS(7), BD_AID.SDmg, B_Math.ceil(var * dat:GetExtPercent(6)))
        s.buff.replace = dat:GetExtInt(8)
        --风场BUFF
        var = dat:GetExtValInt(10)
        if var == 0 then
            s.buff2 = BD_Buff.BD_BuffSingle(10941, 100, BD_AID.Energy, -dat:GetExtValInt(9))
        else
            s.buff2 = BD_Buff.BD_BuffDouble(10941, 100, BD_AID.Energy, -dat:GetExtValInt(9), BD_AID.MoveSpeed, -var)
        end

        s.dicMark = { }
        if s.map.hasEvent then s.eftLst = { } end

        local rangeMain = dat:GetExtInt(2) * 0.5
        var =
        {
            --[1]下次伤害时间，[2]伤害间隔，[3]子火伤害
            s.map.time, dat:GetExtInt(1), B_Math.ceil(var * dat:GetExtPercent(5)),
            --母火[4]minX,[5]minY,[6]maxX,[7]maxY，[8]子火范围
            pos.x - rangeMain, pos.y - rangeMain, pos.x + rangeMain, pos.y + rangeMain, dat:GetExtInt(3),
        }
        s.vals = var
        if not s.hero.dat.isStar then
            local rx, ry = dat.rangeX.value * 0.5, dat.rangeY.value * 0.5
            --风场[9]minX,[10]minY,[11]maxX,[12]maxY
            var[9], var[10], var[11], var[12] = pos.x - rx, pos.y - ry, pos.x + rx, pos.y + ry
        end
        local qty = dat:GetExtInt(4)
        if qty > 0 then
            local rangeHalf = var[8] * 0.5
            local r = B_Math.max(rangeMain * 0.5 + dat.rangeY.value * 0.25, rangeMain + rangeHalf)
            local da = B_Math.PI * 2 / qty
            local a = 0
            s.units = { }
            for i = 1, qty do
                a = da * (i - 1)
                var = B_Vector(r * B_Math.cos(a) + pos.x, r * B_Math.sin(a) + pos.y)
                s.units[i] =
                {
                    status = 0,
                    pos = var,
                    direction = B_Vector(var.x - rangeHalf, var.y - rangeHalf)
                }
            end
        end

        Dead(s, dat.keep.value)
        s.step = 2
    elseif var == 2 then
        var = s.vals
        local map = s.map
        --风场BUFF
        if s.hero.dat.isStar then
            for _, u in pairs(map.combatUnits) do
                if CheckEnemy(s, u) then
                    u:AddBuff(s.buff2)
                    EffectTarget(s, u)
                end
            end
        else
            map:ForeachAreaUnits(var[9], var[10], var[11], var[12], function(trg)
                if CheckEnemy(s, trg) then
                    trg:AddBuff(s.buff2)
                    EffectTarget(s, trg)
                end
            end)
        end

        --火焰伤害
        if map.time < var[1] then return end
        var[1] = var[1] + var[2]
        s.dirMark = { }
        
        --主火
        if s.func == nil then
            local h, dps, buff = s.hero, s.dps, s.buff
            s.func = function(trg)
                if CheckEnemyWithMark(s, trg) and h:SkillDPS(trg, dps) then
                    trg:AddBuff(buff)
                    map:Log("风火灭世对" .. trg.DebugName .. "造成<" .. dps .. ">点伤害")
                    HitTarget(s, trg)
                end
            end
        end
        map:ForeachAreaUnits(var[4], var[5], var[6], var[7], s.func)

        --子火
        if s.units then
            local sr = var[8]
            local minX, minY, maxX, maxY
            if s.func2 == nil then
                local h, dps, buff = s.hero, var[3], s.buff
                s.func2 = function(trg)
                    if CheckEnemyWithMark(s, trg) and h:SkillDPS(trg, dps) then
                        trg:AddBuff(buff)
                        HitTarget(s, trg)
                        map:Log("风火灭世对" .. trg.DebugName .. "造成<" .. dps .. ">点伤害")
                    end
                end
            end
            for _, u in ipairs(s.units) do
                minX, minY = u.direction.x, u.direction.y
                maxX, maxY = minX + sr, minY + sr
                map:ForeachAreaUnits(minX, minY, maxX, maxY, s.func2)
            end
        end
    end
end
--火神破
_skc[95] = function(s)
    local var = s.step
    if var == 0 then
        s.hero.direction = s.hero.isAtk and 1 or -1
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        var = GetDmg(s)
        s.dps = B_Math.ceil(var)
        s.buff = BD_Buff.BD_BuffSingle(10950, s.dat.keep.value, BD_AID.SDmg, B_Math.ceil(var * s.dat:GetExtPercent(1)))
        s.buff.replace = s.dat:GetExtInt(2)
        --打击的lasX,minY,maxY
        var = s.dat.rangeY.value
        s.vals = { s.hero.pos.x, s.hero.pos.y - var * 0.5, s.hero.pos.y + var * 0.5 }
        s.units =
        {
            {
                status = 1, speed = 0,
                pos = s.hero.pos:Clone(),
                direction = B_Vector(s.hero.isAtk and 1 or -1, 0)
            }
        }
        s.step = 2
    elseif var == 2 then
        local u = s.units[1]
        if u.status == 1 then
            var = s.map.deltaTime
            if u.speed < 10 then u.speed = u.speed + 10 * var end
            u.pos:AddMult(u.direction, u.speed * BD_Const.BASE_MOVE_SPEED_UNIT * var)
            var = s.vals[1]
            local pos = u.pos
            local minX, maxX = 0, 0
            if pos.x < var then
                minX, maxX = pos.x - 1, var + 1
            elseif pos.x > var then
                minX, maxX = var - 1, pos.x + 1
            else
                if not map.PosVecAvailable(pos) then s:Dead() end
                return
            end
            s.vals[1] = pos.x
            if s.func == nil then
                local val = s.dat:GetExtVal(3) * 100
                local h, map, dps, buff = s.hero, s.map, s.dps, s.buff
                local rnd = map.random
                s.func = function(trg)
                    if CheckEnemy(s, trg) then
                        if getmetatable(trg) == BD_Hero then
                            if h:SkillDPS(trg, dps, val > rnd:NextInt(0, 10000)) then
                                map:Log("火神破对" .. trg.DebugName .. "造成<" .. dps .. ">点伤害")
                                trg:AddBuff(buff)
                            end
                            HitTarget(s, trg)
                            u.status = 255
                            s:Dead()
                        else
                            trg:Dead()
                            HitTarget(s, trg)
                        end
                    end
                end
            end
            s.map:ForeachAreaUnits(minX, s.vals[2], maxX, s.vals[3], s.func)
            if not s.map:PosVecAvailable(pos) then s:Dead() end
        else
            s:Dead()
        end
    end
end
--天魔妙舞
_skc[96] = function(s)
    local var = s.step
    if var == 0 then
        var = s.dat.keep.value
        s.buff = BD_Buff.BD_BuffDouble(10960, B_Math.max(300, var + 300), BD_AID.God, 1, BD_AID.Stop, 1)
        s.hero:AddBuff(s.buff)
        WaitForTime(s, 300 + B_Math.round(var * 0.7))
        s.step = 1
    elseif var == 1 then
        local rival = s.hero.rival
        local lst = s.map:SearchUnits(rival.isAtk, BD_Soldier)
        local qty = B_Math.min(#lst, B_Math.ceil(s.dat:GetExtValPercent(1) * B_Math.min(BD_Const.MAX_SOLDIER_COUNT, rival.MaxTP)))
        if qty > 0 then
            var = rival.pos
            table.sort(lst, function(x, y) return B_Vector.Distance2(x, var) < B_Vector.Distance2(y, var) end)
            s.buff2 = BD_Buff.BD_BuffDouble(10961, BD_Const.MAX_TIME, BD_AID.CPD, s.dat:GetExtInt(2), BD_AID.CSD, s.dat:GetExtInt(3))
            s.buff2.replace = B_Math.max(1, s.dat:GetExtInt(4))
            var = s.hero:AddBuff(s.buff2)
            var.multi = var.multi + (qty > 1 and qty - 1 or 0)
            for i = 1, qty do
                lst[i]:Dead()
                HitTarget(s, lst[i])
            end
        end
        WaitForTime(s, B_Math.round(s.dat.keep.value * 0.3))
        s.step = 2
    elseif var == 2 then
        var = s.hero
        s.dps = B_Math.ceil(GetDmg(s))
        if var:SkillDPS(var.rival, s.dps, false, not var.dat.isStar) then
            s.map:Log("天魔妙舞对" .. var.rival.DebugName .. "造成<" .. s.dps .. ">点伤害")
            HitTarget(s, var.rival)
        end
        s:Dead()
    end
end
--号令群雄
_skc[97] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 300)
        s.step = 1
    elseif var == 1 then
        local keep = s.dat.keep.value
        if s.hero.dat.isStar then
            s.buff = BD_Buff.BD_BuffSingle(10970, keep, BD_AID.God, 1)
        else
            var = -s.dat:GetExtValInt(1)
            s.buff = BD_Buff.BD_BuffDouble(10970, keep, BD_AID.SPD, var, BD_AID.SSD, var)
        end 
        for _, u in ipairs(s.map:SearchUnits(s.hero.isAtk, BD_Soldier)) do
            u:AddBuff(s.buff)
            HitTarget(s, u)
        end
        s.buff2 = BD_Buff.BD_BuffSingle(10971, keep, BD_AID.Fixed, 1)
        s.hero:AddBuff(s.buff2)
        s:Dead()
    end
end
--星罗棋布
_skc[98] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        s.buff = BD_Buff.BD_BuffDouble(10980, s.dat:GetExtKeep(2), BD_AID.Fixed, 1, BD_AID.Silence, 1)
        s.hero:AddBuff(s.buff)
        HitTarget(s, s.hero)
        local qty = s.dat:GetExtInt(1)
        if qty <= 0 then s:Dead() return end
        s.dps = B_Math.ceil(GetDmg(s))
        --时间增量,设置单个半径,X偏移量,Y偏移量
        s.vals = { s.dat:GetExtKeep(3), 1.3, s.dat.rangeX.value, s.dat.rangeY.value }
        local dt = B_Math.modf(s.dat.keep.value / qty)
        local rnd = s.map.random
        print("rnd:NextInt(0, dt) ", s.dat.keep.value, qty,  dt,  rnd:NextInt(0, dt))
        var = { }
        for i = 1, qty do
            var[i] =
            {
                status = 1, pos = B_Vector(),
                time = i > 1 and var[i - 1].time - rnd:NextInt(0, dt) or 0
            }
        end
        s.units = var
        s.step = 2
    elseif var == 2 then
        local r = s.vals[2]
        local alive = false
        local map = s.map
        local dtm = map.deltaMillisecond
        local rpos = s.hero.rival.pos
        local rnd = map.random
        local rx, ry = s.vals[3], s.vals[4]
        for _, u in ipairs(s.units) do
            if u.status == 1 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 0 then
                    u.pos:Set(rpos.x + rnd:Next(-rx, rx), rpos.y + rnd:Next(-ry, ry))
                    u.time, u.status = 0, 2
                end
            elseif u.status == 2 then
                alive = true
                u.time = u.time + dtm
                if u.time >= 250 then
                    u.time, u.status = 0, 255
                    if s.func == nil then
                        local h, dps, buff = s.hero, s.dps, s.buff
                        local canDodge, ddt = not h.dat.isStar, s.vals[1]
                        s.func = function(trg)
                            if CheckEnemy(s, trg) and h:SkillDPS(trg, dps, false, canDodge) then
                                map:Log("星罗棋布对" .. trg.DebugName .. "造成<" .. dps .. ">点伤害")
                                if ddt ~= 0  and getmetatable(trg) == BD_Hero then
                                    local bs = trg:GetBuff(10980)
                                    if bs and bf.isAlive then
                                        buff.lifeTime = buff.lifeTime + ddt
                                        if not bs.isAlive then bs:MarkAsChanged() end
                                    end
                                end
                            end
                        end
                    end
                    var = u.pos
                    map:ForeachAreaUnits(var.x - r, var.y - r, var.x + r, var.y + r, s.func)
                end
            end
        end
        if not alive then s:Dead() end
    end
end
--天谴
_skc[99] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        var = s.hero.rival
        var.dat.hp.value = 0
        var.infoChanged = true
        var:Dead()
        s.map:Log("天谴对" .. var.DebugName .. "造成死亡")
        HitTarget(s, var)
        s:Dead()
    end
end
--不灭铁壁
_skc[100] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h = s.hero
        local buff = BD_Buff.BD_BuffSingle(11000, BD_Const.MAX_TIME, BD_AID.Shield, B_Math.ceil(s.dat:GetExtValPercent(1) * s.hero.MaxHP))
        s.buff = buff
        buff.priority = 1
        var = h:GetBuff(11000)
        if var == nil or var:IsShieldEmpty() then
            h:AddBuff(buff)
            s.step = 2
            Dead(s, BD_Const.MAX_TIME)
        else
            var:Replace(buff)
            s:Dead()
        end
        HitTarget(s, h)
    elseif var == 2 then
        var = s.hero:GetBuff(11000)
        if var == nil then
            s:Dead()
        elseif var:IsShieldEmpty() then
            var:Dead()
            var = B_Math.ceil(ProDmg(s, s.dat:GetExtPercent(2) * s.hero.Str))
            if var > 0 then
                s.hero:SkillDPS(s.hero.rival, var)
                HitTarget(s.hero.rival)
            end
            s:Dead()
            s.step = 254
        end
    end
end
--饕餮盛宴
_skc[101] = function(s)
    local var = s.step
    if var == 0 then
        WaitForTime(s, 500)
        s.step = 1
    elseif var == 1 then
        local h = s.hero
        local rx, ry = s.dat.rangeX.value, s.dat.rangeY.value
        local minX, minY = h.rival.x - rx / 2 - 0.5, h.rival.y - ry / 2 - 0.5
        local maxX, maxY = minX + rx - 0.5, minY + ry - 0.5
        local qty = 0
        var = B_Math.ceil(GetDmg(s))
        s.map:ForeachAreaUnits(minX, minY, maxX, maxY, function(trg)
            if CheckEnemy(s, trg) and h:SkillDPS(trg, var) then
                qty = qty + 1
                HitTarget(s, trg)
                s.map:Log("饕餮盛宴对" .. trg.DebugName .. "造成<" .. var .. ">点伤害")
            end
        end)
        if qty > 0 then
            var = qty * s.dat:GetExtKeep(1)
            if var > 0 then
                local buf = h:GetBuff(11010)
                if buf == nil or buf.leftTime < var then
                    buf = BD_Buff(11010, var)
                    var = B_Math.ceil(s.dat:GetExtValPercent(2) * h.MaxHP)
                    buf:SetAtt(BD_AID.Cure, var)
                    var = s.dat:GetExtValInt(3)
                    buf:SetAtt(BD_AID.Str, var)
                    buf:SetAtt(BD_AID.Wis, var)
                    buf:SetAtt(BD_AID.Cap, var)
                    s.buff = buf
                    h:AddBuff(buf)
                end
            end
        end
        s:Dead()
    end
end