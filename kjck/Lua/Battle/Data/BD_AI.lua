local ipairs = ipairs
local pairs = pairs
local insert = table.insert
local remove = table.remove
local getmetatable = getmetatable

local BD_Const = QYBattle.BD_Const
local B_Math = QYBattle.B_Math
local B_Vector =  QYBattle.B_Vector

local BAT_CMD = QYBattle.BAT_CMD
local BD_Hero = QYBattle.BD_Hero
local BD_Soldier = QYBattle.BD_Soldier

local FrontFirstEnemy = BD_Hero.FrontFirstEnemy

--字段说明
--[[
hero BD_Hero            控制的武将
map BD_Field            所属战场
heroKind int            武将主属性(1=武 2=智 3=统)

retreat bool            是否允许撤退
castSkill bool          是否允许释放技能
canRSP bool             是否有回技力的技能
lskMaxW int             小技能最大权重

weights table           权重缓存

skidx int               准备释放的技能索引
skMelee int             近战技能计数
skCast int              远程技能计数
needSP int              需要SP的技能数量
wait int                等待时间

ai S_HeroAI             AI
aiSidx int              AI技能索引
aiSwait int             AI等待时间
]]

local _ai = { }
--[Comment]
--战场AI
QYBattle.BD_AI = _ai
local _aim = { __index = _ai }

setmetatable(_ai, { __call = function(t, hero, retreat, castSkill)
    assert(hero and getmetatable(hero) == QYBattle.BD_Hero, "cerate BD_AI need BD_Hero")
    t =
    {
        hero = hero,
        map = hero.map,
        skidx = 0,
        retreat = retreat and true or false,
        castSkill = castSkill ~= false,
        ai = hero.dat.ai,
        heroKind = 0,

        wait = -1,
        skMelee = 0,
        skCast = 0,
        needSP = 0,
        aiSidx = 1,
        aiSwait = 1,

        canRSP = false,
        lskMaxW = 100,

        weights = { },
    }
    local var = hero.dat
    local s, w, c = var.str.value, var.wis.value, var.cap.value
    if w > s and w > c then
        t.heroKind = 2
    elseif c > s and c > w then
        t.heroKind = 3
    else
        t.heroKind = 1
    end

    if hero.skill then
        for _, s in ipairs(hero.skill) do
            var = s.sn.value
            if var == 5 or var == 33 or var == 93 then
                t.canRSP = true
                break
            end
        end
    end

    if t.canRSP then
        s = hero.Str + hero.Wis + hero.Cap + hero.MaxHP
        var = hero.rival
        w = var.Str + var.Wis + var.Cap + var.MaxHP
        t.lskMaxW = s > w * 3 and 100 or 99
    end

    return setmetatable(t, _aim)
end})

local function SetHeroCmd(h, cmd)
    if h.isAtk then
        h.map._atkHeroCmd = cmd
    else
        h.map._defHeroCmd = cmd
    end
end

local function SetArmCmd(h, cmd)
    if h.isAtk then
        h._atkArmCmd = cmd
    else
        h._defArmCmd = cmd
    end
end

local function SetHeroCmdDre(h, dre)
    if dre > 0 then
        if h.isAtk then
            h.map._atkHeroCmd = BAT_CMD.Attack
        else
            h.map._defHeroCmd = BAT_CMD.Retreat
        end
    elseif dre < 0 then
        if h.isAtk then
            h.map._atkHeroCmd = BAT_CMD.Retreat
        else
            h.map._defHeroCmd = BAT_CMD.Attack
        end
    else
        if h.isAtk then
            h.map._atkHeroCmd = BAT_CMD.Wait
        else
            h.map._defHeroCmd = BAT_CMD.Wait
        end
    end
end

--[Comment]
--检测给定敌人是否可攻击
local function CheckEnemy(e, isAtk) return e and e.isAtk ~= isAtk and not e.isDead end
--[Comment]
--当前是否交战
local function IsFighting(h) return h.map.IsFighting or h.IsCasterSoldier or h.rival.IsCasterSoldier end
--[Comment]
--是否是统帅将领
local function IsCap(h) return h.Cap >= h.Str and h.Cap >= h.Wis end
--[Comment]
--计算技能伤害
local function GetSDmg(h, sk)
    local csd = h.CSD
    if sk.fesn == BD_Const.FE_METAL then csd = csd + sk.feval end
    return sk:GetDps(h.Str, h.Wis, h.Cap) * (1 + csd * 0.01)
end
--[Comment]
--计算伤害
local function GetUnitDmg(u, dmg, sdodge)
    dmg = dmg + u.SSD * 0.01
    if dmg > 0 and sdodge then
        dmg = dmg * B_Math.clamp01(1 - B_Math.pow(u.SDodge * 0.0003, 2) * 3333)
        return dmg > 1 and dmg or 1
    end
    return dmg > 0 and dmg or 0
end
--[Comment]
--计算给敌将造成的有效伤害权值
local function GetHeroSDmgW(h, sk, pow, sdodge)
    local val = B_Math.clamp01(B_Math.ceil(GetUnitDmg(h.rival, GetSDmg(h, sk), sdodge)) / h.rival.HP)
    val = (pow and pow > 1 and B_Math.pow(val, pow) or val) * 100
    return val > 1 and B_Math.floor(val) or 1
end
--[Comment]
--计算给敌将造成的有效伤害权值
local function GetHeroSDmgSW(h, sk, scale, pow, sdodge)
    local val = B_Math.clamp01(B_Math.ceil(GetUnitDmg(h.rival, GetSDmg(h, sk) * scale, sdodge)) / h.rival.HP)
    val = (pow and pow > 1 and B_Math.pow(val, pow) or val) * 100
    return val > 1 and B_Math.floor(val) or 1
end
--[Comment]
--获取给定所属的密集范围
local function GetSkillArea(h, rx, ry)
    local m = h.map
    local inX, inY = m:SearchUnitFocus(not h.isAtk)
    local xMin, yMin = inX - B_Math.modf(rx / 2), inY - B_Math.modf(ry / 2)
    local xMax, yMax = xMin + rx - 1, yMin + ry - 1
    if xMin < 0 then xMin, xMax = 0, B_Math.min(xMax - xMin, m.width - 1)
    elseif xMax >= m.width then xMin, xMax = B_Math.max(0, xMin - (xMax - m.width + 1)), m.width - 1 end
    if yMin < 0 then yMin, yMax = 0, B_Math.min(yMax - yMin, m.height - 1)
    elseif yMax >= m.height then yMin, yMax = B_Math.max(0, yMin - (yMax - m.height + 1)), m.height - 1 end
    return xMin, yMin, xMax, yMax
end

local function GetRangeDmgW(rival, hdmg, kill, kill2)
    local w = 0
    if hdmg > 0 then w = w + B_Math.clamp01(hdmg / rival.HP) end
    if kill > 0 then w = w + B_Math.clamp01(kill / rival.MaxTP) * 0.3 end
    if kill2 > 0 then w = w + B_Math.clamp01(kill2 / rival.MaxTP) * 0.2 end
    return w > 0 and B_Math.floor(B_Math.clamp01(w) * 100) or 0
end

--范围伤害权重缓存
local _wCache = nil
--范围伤害搜索函数
local function RangeDmgFunc(trg)
    if CheckEnemy(trg, _wCache.isAtk) then
        local uhp = trg.HP
        local udmg = B_Math.min(B_Math.ceil(GetUnitDmg(trg, _wCache.dmg, _wCache.sdodge)), uhp)
        if getmetatable(trg) == BD_Hero then
            _wCache.heroDmg = udmg
        else
            _wCache.sQty = _wCache.sQty + 1
            if udmg < uhp then
                _wCache.kill2 = _wCache.kill2 + udmg / uhp
            else
                _wCache.kill = _wCache.kill + 1
            end
        end
    end
end
--[Comment]
--计算多点范围技能的权值
local function RangeDmgW(h, xMin, yMin, xMax, yMax, dmg, sdodge)
    _wCache = { isAtk = not h.isAtk, dmg = dmg, sdodge = sdodge, weight = 0, heroDmg = 0, sQty = 0, kill = 0, kill2 = 0 }
    h.map:ForeachAreaUnits(xMin, yMin, xMax, yMax, RangeDmgFunc)
    _wCache.weight = GetRangeDmgW(h.rival, _wCache.heroDmg, _wCache.kill, _wCache.kill2)
    return _wCache
end
--[Comment]
--计算单范围技能的权值
local function RangeDmgHW(h, sk, dmg, sdodge)
    local xMin, yMin, xMax, yMax = GetSkillArea(h, sk.rangeX.value, sk.rangeY.value)
    return RangeDmgW(h, xMin - 0.5, yMin - 0.5, xMax + 0.5, yMax + 0.5, dmg, sdodge)
end
--[Comment]
--计算多点范围技能的权值
local function MultRangeDmgW(h, rx, ry, sk, dmg, sdodge)
    dmg = B_Math.clamp01((rx * ry) / (sk.rangeX.value * sk.rangeY.value)) * sk:GetExtInt(1) * (dmg and dmg > 0 and dmg or B_Math.ceil(GetSDmg(h, sk)))
    local xMin, yMin, xMax, yMax = GetSkillArea(h, sk.rangeX.value, sk.rangeY.value)
    return RangeDmgW(h, xMin - 0.5, yMin - 0.5, xMax + 0.5, yMax + 0.5, dmg, sdodge)
end

local function CalculateStrategicDre(h)
    local dre = 0
    local map = h.map
    local x, isAtk = h.x, h.isAtk
    local w = map.width
    h = map.height - 1
    local EnGetCombatUnit = map.EnGetCombatUnit
    local u
    for i = 0, x - 1, 1 do
        for j = 0, h, 1 do
            u = EnGetCombatUnit(i, j)
            if u and u.isAtk ~= isAtk then
                dre = dre + 1
            end
        end
    end
    for i = x + 1, w - 1, 1 do
        for j = 0, h, 1 do
            u = EnGetCombatUnit(i, j)
            if u and u.isAtk ~= isAtk then
                dre = dre - 1
            end
        end
    end
    if dre < 0 then
        if x < 2 then dre = 0 end
    elseif dre > 0 then
        if x > w - 3 then dre = 0 end
    end
    return dre
end

local _skai = { }
local function CalculatingWeights(a)
    local h = a.hero
    a.wait = h.map.time + 1000
    if h.rival.HP <= 0 then return -1 end

    a.skCast, a.skMelee = 0, 0

    local sp = h.SP
    local sqty = h.skill and #h.skill
    if sqty > 0 then
        local weights = a.weights
        local var = 0
        for i, s in ipairs(h.skill) do
            if s.sp.value > sp then
                var = var + 1
                weights[i] = 0
            else
                weights[i] = 1
            end
        end
        a.needSP = var
        if var < sqty then
            local max, func = 0, nil
--            h.map:Log("开始计算技能计算权值[" .. h.map.frameCount .. "]...")
            for i, s in ipairs(h.skill) do
                var = weights[i]
                if var > 0 then
                    func = _skai[s.sn.value]
                    var = func and func(a, s) or 0
                    --999为特殊处理
                    if var == 999 then return i end
                    if var >= 100 then var = 100 end
                    if var > max then max = var end
                    weights[i] = var
                    if DB then
--                        h.map:Log(DB.GetSkc(s.sn.value):getName() .. " = " .. weights[i])
                    else
--                        h.map:Log("skill[" .. s.sn.value .. "] = " .. weights[i])
                    end
                end
            end
            if max > 0 then
                local skidx, sksp = 0, 0
                for i, s in ipairs(h.skill) do
                    if weights[i] == max then
                        var = s.sp.value
                        if skidx <= 0 or var < sksp then
                            skidx = i
                            sksp = var
                        end
                    end
                end
                return skidx
            end
        end
    end
    return 0
end

function _ai.Update(a)
    local h, map = a.hero, a.map
    local isAtk = h.isAtk
    local skidx = a.skidx
    if isAtk then
        map._atkArmCmd = BAT_CMD.Attack
    else
        map._defArmCmd = BAT_CMD.Attack
    end

    local btyp = map.battle.type.value
    if btyp == 0 then
        SetHeroCmd(h, BAT_CMD.Attack)
        if h:SkillIsAvailable(skidx) then
            if h:CastSkill(skidx) then
                a.skidx = skidx + 1
            end
        elseif h.skillQty > 0 then
            a.skidx = (skidx % h.skillQty) + 1
        end
        return
    end

    local ai = a.ai
    if a.castSkill then
        if ai and ai.skidx then
            if a.wait < map.time then
                if skidx > 0 then
                    if not h.isStop and not h.isSilence then
                        h:CastSkill(skidx)
                        skidx, a.skidx = 0, 0
                    end
                elseif #ai.skidx > 0 then
                    skidx = ai.skidx[a.aiSidx] + 1
                    a.skidx = skidx
                    a.aiSidx = (a.aiSidx % #ai.skidx) + 1
                    local wait = h:GetCD(skidx)
                    if wait >= BD_Const.MAX_TIME then
                        wait = 0
                    end
                    if ai.skWait and #ai.skWait > 0 then
                        wait = B_Math.max(wait, ai.skWait[a.aiSwait])
                        a.aiSwait = (a.aiSwait % #ai.skWait) + 1
                    end
                    a.wait = map.time + (wait > 0 and wait or 1000)
                end
            end
        elseif h:CastSkill(a.skidx) or a.wait < map.time then
            skidx = CalculatingWeights(a)
            a.skidx = skidx
        end
    end

    if btyp == 1 and map.battle.sn < 18 then
        SetHeroCmd(h, BAT_CMD.Attack)
        return
    end
    if ai then
        if ai.heroAct == 1 then
            SetHeroCmd(h, BAT_CMD.Wait)
            return
        end
        if ai.heroAct == 2 then
            SetHeroCmd(h, BAT_CMD.Attack)
            return
        end
    end
    
    local rh = h.rival
    local hp, tp, cap = h.HP, h.RealTP, h.Cap
    local ehp, etp, ecap = rh.HP, rh.RealTP, rh.Cap

    local def = B_Math.clamp01(1 - h.Dodge * 0.0001) * (1 + h.SPD * 0.01)

    local dmg, sdmg, shp = 0, 0, 0
    local edmg, esdmg, eshp = 0, 0, 0
    local heroBalance, armBalance = 0, 0

    dmg = h.Dmg * B_Math.clamp01(h.Acc * 0.0001) * B_Math.clamp01(h.Crit * 0.0001) * h.CritDmg * 0.01
    edmg = rh.Dmg * B_Math.clamp01(rh.Acc * 0.0001) * B_Math.clamp01(rh.Crit * 0.0001) * rh.CritDmg * 0.01

    if hp > 0 and ehp > 0 then
        heroBalance = B_Math.clamp(hp / (edmg * def), 1, 100) / B_Math.clamp(ehp / (dmg * B_Math.clamp01(1 - rh.Dodge * 0.0001) * (1 + rh.SPD * 0.01)), 1, 100)
        if heroBalance <= 1 then heroBalance = 1 / (heroBalance - 1) end
    end

--    if tp > 0 then
--        shp = h.soldierAtt[2] * 0.0001 * cap * (1 + h.soldierBonus[2] * 0.01)
--        sdmg = h.soldierAtt[1] * 0.0001 * cap * (1 + h.soldierBonus[1] * 0.01)--士兵武力
--        sdmg = sdmg * map.battle.fStr.value * 0.01--造成的原始伤害
--        sdmg = sdmg * (1 + h.soldierBonus[10] * 0.01)--计算伤害增减
--        sdmg = sdmg * B_Math.clamp01(h.soldierAtt[4] * 0.0001 + h.soldierBonus[5] * 0.01)--计算命中影响
--    end
--    if etp > 0 then
--        eshp = rh.soldierAtt[2] * 0.0001 * cap * (1 + rh.soldierBonus[2] * 0.01)
--        esdmg = rh.soldierAtt[1] * 0.0001 * cap * (1 + rh.soldierBonus[1] * 0.01)--士兵武力
--        esdmg = esdmg * map.battle.fStr.value * 0.01--造成的原始伤害
--        esdmg = esdmg * (1 + rh.soldierBonus[10] * 0.01)--计算伤害增减
--        esdmg = esdmg * B_Math.clamp01(rh.soldierAtt[4] * 0.0001 + rh.soldierBonus[5] * 0.01)--计算命中影响
--    end

--    if shp > 0 and eshp > 0 then
--        armBalance = B_Math.clamp(shp * tp / (esdmg * (1 + h.soldierBonus[11] * 0.01)), 1, 100) / B_Math.clamp(eshp * etp / (sdmg * (1 + rh.soldierBonus[11] * 0.01)), 1, 100)
--        if armBalance <= 1 then armBalance = 1 / (armBalance - 1) end
--    elseif shp > 0 then
--        armBalance = 100
--    elseif eshp > 0 then
--        armBalance = -100
--    end

    local dying = not h.isGod and (hp < edmg * def * 2 or hp < esdmg * def * (tp > 0 and B_Math.clamp(etp / tp, 1, 2) or 2) * 2)--是否将死
    if a.retreat and dying then
        SetHeroCmd(h, BAT_CMD.Retreat)
    else
        if a.heroKind == 2 or a.heroKind == 3 then
            --智将/统将
            if (skidx <= 0 and tp < 1) or (skidx > 0 and a.skMelee > a.skCast) then
                SetHeroCmd(h, BAT_CMD.Attack)
            elseif h.SeeEnemy then
                SetHeroCmdDre(h, CalculateStrategicDre(h))
            else
                SetHeroCmd(h, BAT_CMD.Wait)
            end
        else
            --武将
            if (skidx <= 0 and tp < 1) or (skidx > 0 and a.skMelee > a.skCast) or h.SeeEnemy then
                SetHeroCmd(h, BAT_CMD.Attack)
            elseif heroBalance < 0 then
                SetHeroCmd(h, BAT_CMD.Wait)
            else
                SetHeroCmd(h, BAT_CMD.Attack)
            end
        end
    end
end

--半月斩
_skai[1] = function(a, s)
    a.skCast = a.skCast + 1
    local w = B_Math.min(GetHeroSDmgW(a.hero, s, 3, true), a.lskMaxW)
    local trg = FrontFirstEnemy(a.hero)
    return trg and getmetatable(trg) == BD_Soldier and B_Math.floor(w / 3) or w
end
--百步穿杨
_skai[2] = function(a, s)
    a.skCast = a.skCast + 4
    return GetHeroSDmgW(a.hero, s, 2)
end
--振奋 80
_skai[3] = function(a, s)
    a.skCast = a.skCast + 1
    a = a.hero
    if a.TP > 0 and IsFighting(a) then
        s = a.map:SearchUnit(a.isAtk, BD_Soldier)
        --有士兵且没有振奋状态
        if s and not s:ContainsBuff(10030) then
            return B_Math.clamp(B_Math.floor(a.TP * 60 / a.MaxTP), 0, 60)
        end
    end
    return 0
end
--圣光术
_skai[4] = function(a, s)
    a.skCast = a.skCast + 1
    --血量在0-70%按掉血量计算权值
    return B_Math.floor(100 * B_Math.sqrt(B_Math.clamp01(1 - B_Math.clamp01(a.hero.HP / a.hero.MaxHP) * 1.42857)))
end
--能量灌注(50) 93 能量充盈
_skai[5] = function(a, s)
    a.skCast = a.skCast + 1
    local h = a.hero
    return h.SP < h.MaxSP and B_Math.floor(100 * B_Math.clamp01(a.needSP / (h.skillQty - 2))) or 0
end
--背水一战 80
_skai[6] = function(a, s)
    a.skMelee = a.skMelee + 1
    if s.exts and #s.exts > 0 then
        local h = a.hero
        if not h:ContainsBuff(10060) then
            local e = h.map:GetCombatUnit(h.x + h.direction, h.y)
            if CheckEnemy(e) then
                if getmetatable(e) == BD_Hero then
                    local nhp = h.HP
                    nhp = nhp - B_Math.floor(nhp * s:GetExtPercent(1))
                    local rdmg = e.Dmg * B_Math.clamp01(e.Acc * 0.0001) * B_Math.clamp01(1 - h.Dodge * 0.0001) * (1 + h.SPD * 0.01)
                    local holdTime = (nhp / rdmg) * e.MSPA --我方能坚持的时间
                    local dmg = h.dat.str.value
                    dmg = h.Str + B_Math.ceil(dmg * s:GetExtValPercent(2))
                    dmg = dmg * h.battle.fStr.value * 0.01
                    dmg = B_Math.ceil(dmg + dmg * h.CPD * 0.01) * B_Math.clamp01(h.Acc * 0.0001) * B_Math.clamp01(1 - e.Dodge * 0.0001) * (1 + e.SPD * 0.01)
                    local eTime = (e.HP / dmg) * h.MSPA --敌方能坚持的时间
                    return B_Math.floor(80 * B_Math.clamp01(holdTime / eTime))
                else
                    return B_Math.floor(40 * B_Math.clamp01(h.HP / h.MaxHP - 0.5))
                end
            end
        end
    end
    return 0
end
--月波斩
_skai[7] = function(a, s)
    a.skMelee = a.skMelee + 1
    local h = a.hero
    local minX, maxX = h.x, h.isAtk
    minX, maxX = maxX and minX or minX - 2, maxX and minX + 2 or minX
    return B_Math.min(RangeDmgW(h, minX - 0.5, h.y - 2.5, maxX + 0.5, h.y + 3.5, B_Math.ceil(GetSDmg(h, s)), true).weight, a.lskMaxW)
end
--刀阵
_skai[8] = function(a, s)
    a.skCast = a.skCast + 2
    return B_Math.min(MultRangeDmgW(a.hero, 2, 1, s, 0, true).weight, a.lskMaxW)
end
--闪电链
_skai[9] = function(a, s)
    a.skCast = a.skCast + 2
    local units = a.map:SearchUnits(not a.hero.isAtk)
    if #units > 0 then
        local pos = B_Vector(a.map:SearchUnitFocus(not a.hero.isAtk))
        table.sort(units, function(x, y) return B_Vector.Distance2(x.pos, pos) < B_Vector.Distance2(y.pos, pos) end)
        pos = units[1].pos

        local qty, maxQty = 10, 10
        local dis, dis1, dis2 = 1, -1, 2
        local dmg = B_Math.ceil(GetSDmg(a.hero, s))
        local heroDmg, kill, kill2 = 0, 0, 0
        for _, u in ipairs(units) do
            local d = B_Vector.Distance2(u.pos, pos)
            if d < dis2 then
                local uhp = u.HP
                local cdmg = dmg * qty / maxQty
                local udmg = B_Math.min(B_Math.ceil(GetUnitDmg(u, cdmg, true)), uhp)
                if getmetatable(u) == BD_Hero then
                    heroDmg = udmg
                elseif udmg < uhp then
                    kill2 = kill2 + udmg / uhp
                else
                    kill = kill + 1
                end
                qty = qty - 1
            end
            if d > dis1 then
                dis1 = dis2
                dis = dis + 1
                dis2 = 2 * dis * dis
            end
            if qty <= 0 then break end
        end
        return B_Math.min(GetRangeDmgW(a.hero.rival, heroDmg, kill, kill2), a.lskMaxW)
    end
    return 0
end
--不动如山 80
_skai[10] = function(a, s)
    a.skMelee = a.skMelee + 2
    local h = a.hero
    local x, y = h.x, h.y
    local fu = a.map:GetCombatUnit(x + a.hero.direction, y)
    local bu = a.map:GetCombatUnit(x - a.hero.direction, y)
    local keep = s.keepSec
    local rdmg = 0
    if CheckEnemy(fu, h.isAtk) then
        rdmg = fu.Dmg * B_Math.clamp01(fu.Acc * 0.0001) * keep * fu.MSPA * 0.001
    end
    if CheckEnemy(bu, h.isAtk) then
        rdmg = bu.Dmg * B_Math.clamp01(bu.Acc * 0.0001) * keep * bu.MSPA * 0.001
    end
    if rdmg > 0 then
        rdmg = rdmg * s:GetExtValPercent(1) * 0.01
        return B_Math.floor(80 * B_Math.clamp01(rdmg / h.HP))
    end
    return 0
end
--万箭齐发 60
_skai[11] = function(a, s)
    a.skCast = a.skCast + 2
    return B_Math.min(MultRangeDmgW(a.hero, 1.5, 1.5, s, 0, true).weight, 60)
end
--百鬼索命 60
_skai[12] = function(a, s)
    a.skCast = a.skCast + 2
    local dmg = B_Math.ceil(GetSDmg(a.hero, s)) * B_Math.max(1, s.keepSec * 0.5)
    local w = RangeDmgHW(a.hero, s, dmg, true).weight
    if w > 0 then w = w + B_Math.ceil(20 * a.map.ArmiesSpace / a.map.width) end
    return B_Math.min(w, 60)
end
--策反 80
_skai[13] = function(a, s)
    a.skCast = a.skCast + 1
    local rate = s:GetExtValPercent(1)
    local val = a.hero.rival
    local etp ,emtp = val.TP, val.MaxTP
    local max = B_Math.min(B_Math.ceil(rate * emtp), emtp)
    val = B_Math.min(B_Math.ceil(rate * etp), etp, emtp - a.hero.TP)
    return B_Math.floor(80 * val / max)
end
--风火轮
_skai[14] = function(a, s)
    a.skCast = a.skCast + 1
    local h = a.hero
    local x, y = h.x, h.y
    local dmg = B_Math.ceil(GetSDmg(h, s)) * B_Math.max(1, s.keepSec * 0.5)
    return B_Math.min(RangeDmgW(h, x - 1.5, y - 1.5, x + 1.5, y + 1.5, dmg, true).weight, a.lskMaxW)
end
--飓风术 80
_skai[15] = function(a, s)
    a.skCast = a.skCast + 1
    local d = B_Math.round(s.keepSec * BD_Const.BASE_MOVE_SPEED_UNIT)
    local rx, ry = s.rangeX.value, s.rangeY.value
    local minX, minY, maxX, maxY = GetSkillArea(a.hero, rx + d, ry + d)
    local qty = 0
    local isAtk = a.hero.isAtk
    a.map:ForeachAreaUnits(minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5, function(trg)
        if getmetatable(trg) == BD_Soldier and CheckEnemy(trg, isAtk) then
            qty = qty + 1
        end
    end)
    return B_Math.floor(80 * B_Math.clamp01(qty / ((rx + d) * (ry + d))))
end
--奇袭 80
_skai[16] = function(a, s)
    a.skCast = a.skCast + 1
    local h = a.hero
    local mtp = h.MaxTP
    local max = B_Math.ceil(s:GetExtValPercent(1) * mtp)
    local val = B_Math.min(max, mtp - h.TP)
    local dis = B_Math.abs(h.map:SearchUnitFocusX(not h.isAtk) - (h.isAtk and h.map.width - 1 or 0))
    if IsCap(h) then
        return B_Math.floor(90 * (1 - B_Math.clamp01(dis / a.map.width)) * B_Math.clamp01(val / max))
    else
        return B_Math.floor(50 * (1 - B_Math.clamp01(dis / a.map.width)) * B_Math.clamp01(val / mtp))
    end
end
--水龙阵
_skai[17] = function(a, s)
    a.skCast = a.skCast + 2
    return B_Math.min(RangeDmgHW(a.hero, s, 0, true).weight, a.lskMaxW)
end
--圣神之光
_skai[18] = function(a, s)
    a.skCast = a.skCast + 2
    local h = a.hero
    local hp, maxHP = h.HP, h.MaxHP
    local qty = hp < maxHP and 1 or 0
    for _, u in ipairs(a.map:SearchUnits(h.isAtk, BD_Soldier)) do
        if u.hp < 1 then qty = qty + 1 end
    end
    return B_Math.floor(30 * B_Math.sqrt(1 - B_Math.clamp01(hp / maxHP)) + 70 * B_Math.clamp01(qty / h.MaxTP))
end
--八卦阵 90
_skai[19] = function(a, s)
    a.skCast = a.skCast + 2
    if a.map.IsFighting then
        local h = a.hero
        local rx, ry = s.rangeX.value, s.rangeY.value
        local minX, minY, maxX, maxY = GetSkillArea(h, rx, ry)
        local area = rx * ry
        local oQty, eQty = 0, 0
        local oIn, eIn = false, false
        local isAtk = h.isAtk
        a.map:ForeachAreaUnits(minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5, function(trg)
            if not trg.isDead then
                if trg.isAtk == isAtk then oQty = oQty + 1
                else eQty = eQty + 1 end
                if trg == h then oIn = true
                elseif trg == h.rival then eIn = true end
            end
        end)
        return B_Math.floor((oIn and 45 or 0) + (eIn and 35 or 0) + 10 * B_Math.min(B_Math.clamp01(2 * oQty / area), B_Math.clamp01(2 * eQty / area)))
    end
    return 0
end
--灭杀阵
_skai[20] = function(a, s)
    a.skCast = a.skCast + 2
    return B_Math.min(MultRangeDmgW(a.hero, 2.5, 2.5, s, 0, true).weight, a.lskMaxW)
end
--增援 90
_skai[21] = function(a, s)
    a.skCast = a.skCast + 1
    local h = a.hero
    local mtp = h.MaxTP
    local max = B_Math.ceil(s:GetExtValPercent(1) * mtp)
    local val = B_Math.min(max, mtp - h.TP)
    local dis = B_Math.abs(h.map:SearchUnitFocusX(not h.isAtk) - (h.isAtk and 0 or h.map.width - 1))
    if IsCap(h) then
        return B_Math.floor(90 * (1 - B_Math.clamp01(dis / a.map.width)) * B_Math.clamp01(val / max))
    else
        return B_Math.floor(50 * (1 - B_Math.clamp01(dis / a.map.width)) * B_Math.clamp01(val / mtp))
    end
end
--野火燎原 90
_skai[22] = function(a, s)
    a.skCast = a.skCast + 2
    local h = a.hero
    local dmg = B_Math.ceil(GetSDmg(h, s))
    dmg = dmg + s:GetExtPercent(2) * dmg * s.keepSec
    return B_Math.min(MultRangeDmgW(h, 2, 2, s, dmg, true).weight, a.lskMaxW)
end
--连弩 | 36 连弩激射
_skai[23] = function(a, s)
    a.skCast = a.skCast + 4
    local h = a.hero
    if h.dat.isStar and s.sn.value == 23 then return 100 end
    
    local dmg = B_Math.ceil(GetSDmg(h, s))
    local qty = s:GetExtInt(1)
    local minX, maxX, kill, kill2 = h.x, h.rival.x, 0, 0
    if minX > maxX then minX, maxX = maxX + 1, minX
    else minX, maxX = minX + 1, maxX end
    local hy, isAtk = h.y, h.isAtk
    local e
    local GetCombatUnit = h.map.EnGetCombatUnit
    for j = minX, maxX - 1, 1 do
        if qty < 1 then break end
        e = GetCombatUnit(j, hy)
        if CheckEnemy(e, isAtk) then
            local uhp = e.HP
            local udmg = 0
            udmg = B_Math.ceil(GetUnitDmg(e, dmg))
            local q = B_Math.ceil(uhp / udmg)
            qty = qty - q
            udmg = B_Math.min(udmg * q, uhp)
            if udmg < uhp then
                kill2 = kill2 + udmg / uhp
            else
                kill = kill + 1
            end
        end
    end
    dmg = qty > 0 and B_Math.ceil(dmg + dmg * h.rival.SSD * 0.01) * qty or 0
    dmg = GetRangeDmgW(h.rival, dmg, kill, kill2)
    return dmg > 0 and s.sn.value == 36 and dmg + 8 or dmg
end
--金钟罩 | 79 金钟罩
_skai[24] = function(a, s)
    a.skMelee = a.skMelee + 4
    local h = a.hero
    if not h.isGod and h.AroundEnemy then
        return B_Math.floor(100 * B_Math.sqrt(B_Math.clamp01(1 - B_Math.clamp01(h.HP / h.MaxHP) * 1.42857)))
    end
    return 0
end
--夜幕 60
_skai[25] = function(a, s)
    a.skCast = a.skCast + 1
    local h = a.hero
    if IsFighting(h) and not h.rival:ContainsBuff(10250) then
        local val = s:GetExtValInt(1)
        val = B_Math.floor((val + (100 - val) * B_Math.clamp01((h.rival.TP + 1) / h.rival.MaxTP)) * 0.6)
        return B_Math.min(val, 60)
    end
    return 0
end
--冰锥术
_skai[26] = function(a, s)
    a.skCast = a.skCast + 1
    return B_Math.floor(B_Math.min(RangeDmgHW(a.hero, s, 0, true).weight * 1.1, a.lskMaxW))
end
--烈火悬灯 | 56 悬灯火
_skai[27] = function(a, s)
    a.skMelee = a.skMelee + 4
    local rx, ry = s.rangeX.value, s.rangeY.value
    local hrx, hry = rx * 0.5, ry * 0.5
    local dmg = B_Math.ceil(GetSDmg(a.hero, s)) * (B_Math.max(1, s.keepSec * 0.5) * s:GetExtInt(1) / (rx * ry))
    local x, y = a.hero.x, a.hero.y
    local sksn = s.sn.value
    local w = RangeDmgW(a.hero, x - hrx, y - hry, x + hrx, y + hry, dmg, sksn == 56)
    if w.weight > 0 and a.hero.dat.isStar and sksn == 27 and w.heroDmg > 0 then
        return 100
    else
        return sksn == 56 and B_Math.min(w.weight, a.lskMaxW) or w.weight
    end
end
--冰风刃舞
_skai[28] = function(a, s)
    a.skCast = a.skCast + 4
    return B_Math.clamp(B_Math.floor(MultRangeDmgW(a.hero, 3, 2, s).weight * 1.5), 50, 100)
end
--火牛烈崩
_skai[29] = function(a, s)
    a.skCast = a.skCast + 4
    local map = a.map
    local rnd = map.random
    local qty = B_Math.clamp(0, s:GetExtInt(1), map.height - 1)
    local perDmg = B_Math.ceil(GetSDmg(a.hero, s))
    local kill, kill2, heroDmg = 0, 0, 0
    local rows = { }
    for j = 0, map.height - 1, 1 do insert(rows, j) end
    local row = { }
    for j = 1, qty, 1 do
        row[i] = remove(rows, rnd:NextInt(0, #rows) + 1)
    end
    local isAtk = a.hero.isAtk
    local GetCombatUnit = map.EnGetCombatUnit
    for j = 1, qty, 1 do
        for k = map.defMinX, map.defMinX, 1 do
            local e = GetCombatUnit(k, row[j])
            if CheckEnemy(e, isAtk) then
                local uhp = e.HP
                local udmg = B_Math.min(B_Math.ceil(GetUnitDmg(e, perDmg)), uhp)
                if getmetatable(e) == BD_Hero then
                    heroDmg = udmg
                elseif udmg < uhp then
                    kill2 = kill2 + udmg / uhp
                else
                    kill = kill + 1
                end
            end
        end
    end
    return GetRangeDmgW(a.hero.rival, heroDmg, kill, kill2)
end
--鬼哭神嚎
_skai[30] = function(a, s)
    a.skCast = a.skCast + 4
    return 100
end
--破釜沉舟 10
_skai[31] = function(a, s)
    a.skMelee = a.skMelee + 2
    if (a.map.IsFighting or a.hero.IsCasterSoldier) and not a.hero:ContainsBuff(10310) then
        return a.map.random:NextInt(1, 10)
    end
    return 0
end
--分身斩
_skai[32] = function(a, s)
    a.skCast = a.skCast + 1
    local h = a.hero
    local dmg = B_Math.ceil(GetSDmg(h, s))
    return B_Math.min(h.isAtk and RangeDmgW(h, h.x - 0.5, h.y - 0.5, map.width, h.y + 0.5, dmg, true).weight or RangeDmgW(h, 0, h.y - 0.5, h.x + 0.5, h.y + 0.5, dmg, true).weight, a.lskMaxW)
end
--命疗术
_skai[33] = function(a, s)
    a.skCast = a.skCast + 3
    --血量在0-70%按掉血量计算权值
    local h = a.hero
    return B_Math.floor((100 * B_Math.sqrt(B_Math.clamp01(1 - B_Math.clamp01((h.HP / h.MaxHP) * 1.42857))) + 100 * B_Math.clamp01(a.needSP / h.skillQty)))
end
--赤焰火海
_skai[34] = function(a, s)
    a.skCast = a.skCast + 2
    local dmg = B_Math.ceil(GetSDmg(a.hero, s)) * B_Math.max(1, s.keepSec * 0.5)
    local x, y = a.hero.rival.x, a.hero.rival.y
    local hrx, hry = s.rangeX.value * 0.5, s.rangeY.value * 0.5
    return B_Math.min(RangeDmgW(a.hero, x - hrx, y - hry, x + hrx, y + hry, dmg, true).weight, a.lskMaxW)
end
--雷击闪
_skai[35] = function(a, s)
    a.skCast = a.skCast + 1
    return B_Math.min(GetHeroSDmgW(a.hero, s, 3, true), a.lskMaxW)
end
--连弩激射
_skai[36] = _skai[23]
--火雷星雨
_skai[37] = function(a, s)
    a.skCast = a.skCast + 2
    local rival = a.hero.rival
    local range = 2
    local minX = rival.x - 4
    local maxX = minX + 8
    local dmg = B_Math.ceil(GetSDmg(a.hero, s)) * s:GetExtInt(1) * B_Math.clamp01(range / (maxX - minX))
    return B_Math.min(RangeDmgW(a.hero, minX - 0.5, rival.y - 0.5, maxX + 0.5, rival.y + 0.5, dmg, true).weight, a.lskMaxW)
end
--天地无用
_skai[38] = _skai[30]
--五狱华斩 | 55乾坤扫月
_skai[39] = function(a, s)
    a.skCast = a.skCast + 4
    local h = a.hero
    local x, y = h.x, h.y
    local perDmg = B_Math.ceil(GetSDmg(h, s))
    local minX, maxX = h.isAtk and x or 0, h.isAtk and h.map.width - 1 or x
    local hry = s.sn.value == 39 and 2 or 1
    return RangeDmgW(h, minX - 0.5, y - hry - 0.5, maxX + 0.5, y + hry + 0.5, perDmg, false).weight
end
--五雷轰顶
_skai[40] = _skai[30]
--虎啸 50
_skai[41] = function(a, s)
    a.skCast = a.skCast + 2
    if a.map.IsFighting then
        local h = a.hero
        local cmd = h.Command
        local ertp = h.rival.RealTP
        if (ertp > 3 and ertp > h.RealTP and cmd == BAT_CMD.Attack) or cmd == BAT_CMD.Retreat or (B_Math.abs(h.x - h.rival.x) > 1 and cmd == BAT_CMD.Wait) then
            return a.map.random:NextInt(1, 50)
        end
    end
    return 0
end
--伏兵连阵 90
_skai[42] = function(a, s)
    a.skCast = a.skCast + 3
    local h = a.hero
    local mtp = h.MaxTP
    local max = B_Math.ceil(s:GetExtValPercent(1) * mtp)
    local val = B_Math.min(max, mtp - h.TP)
    local dis = h.map:SearchUnitFocusX(not h.isAtk)
    dis = B_Math.min(B_Math.abs(dis - h.map.width + 1), dis)
    if IsCap(h) then
        return B_Math.floor(90 * (1 - B_Math.clamp01(dis / a.map.width)) * B_Math.clamp01(val / max))
    else
        return B_Math.floor(80 * (1 - B_Math.clamp01(dis / a.map.width)) * B_Math.clamp01(val / mtp))
    end
end
--虎咆震
_skai[43] = function(a, s)
    a.skCast = a.skCast + 4
    if a.map.IsFighting then
        return a.hero.dat.isStar and 100 or a.map.random:NextInt(1, 100)
    end
    return 0
end
--离间
_skai[44] = function(a, s)
    a.skCast = a.skCast + 4
    local rate = s:GetExtValPercent(1)
    local val = a.hero.rival
    local etp ,emtp = val.TP, val.MaxTP
    local max = B_Math.min(B_Math.ceil(rate * emtp), emtp)
    val = B_Math.Min(B_Math.ceil(rate * etp), etp, emtp - a.hero.TP)
    return B_Math.floor(((IsCap(a.hero) or IsCap(a.hero.rival)) and 100 or 60) * B_Math.clamp01(val / max))
end
--十面埋伏
_skai[45] = function(a, s)
    a.skCast = a.skCast + 4
    if a.hero.dat.isStar then return 100 end
    local val = a.hero.MaxTP
    local max = B_Math.ceil(s:GetExtValPercent(1) * val)
    val = B_Math.min(max, val - a.hero.TP)
    return B_Math.floor(100 * B_Math.clamp01(val / max))
end
--冰爆术
_skai[46] = function(a, s)
    a.skCast = a.skCast + 1
    return B_Math.min(GetHeroSDmgW(a.hero, s, 2, true), a.lskMaxW)
end
--御飞刀
_skai[47] = function(a, s)
    a.skCast = a.skCast + 1
    return B_Math.min(GetHeroSDmgW(a.hero, s, 3, true), a.lskMaxW)
end
--落石
_skai[48] = function(a, s)
    a.skCast = a.skCast + 1
    return B_Math.min(GetHeroSDmgW(a.hero, s, 3, true), a.lskMaxW)
end
--三日月斩
_skai[49] = function(a, s)
    a.skCast = a.skCast + 3
    local h = a.hero
    local x, y = h.x, h.y
    local perDmg = B_Math.ceil(GetSDmg(h, s))
    local minX, maxX = h.isAtk and x or 0, h.isAtk and h.map.width - 1 or x
    return B_Math.min(RangeDmgW(h, minX - 0.5, y - 2.5, maxX + 0.5, y + 3.5, perDmg, true).weight, a.lskMaxW)
end
--野牛冲撞
_skai[50] = function(a, s)
    a.skCast = a.skCast + 1
    local y = a.hero.y
    return B_Math.min(RangeDmgW(a.hero, 0, y - 0.5, a.map.width, y + 0.5, B_Math.ceil(GetSDmg(a.hero, s)), true).weight, a.lskMaxW)
end
--集火柱
_skai[51] = function(a, s)
    a.skCast = a.skCast + 3
    local dmg = 2 * B_Math.ceil(GetSDmg(a.hero, s))
    local hr = a.hero.rival
    local x, y = hr.x, hr.y
    hr = a.map.height * 0.5
    return B_Math.min(RangeDmgW(a.hero, x - hr, y - hr, x + hr, y + hr, dmg, true).weight, a.lskMaxW)
end
--圣光荣耀
_skai[52] = _skai[18]
--箭雨 60
_skai[53] = _skai[11]
--龙卷风暴
_skai[54] = function(a, s)
    a.skCast = a.skCast + 4
    if a.hero.dat.isStar then return 100 end
    local hr = a.hero.rival
    return B_Math.floor(100 * B_Math.pow(hr.TP / hr.MaxTP, 2))
end
--乾坤扫月
_skai[55] = _skai[39]
--悬灯火
_skai[56] = _skai[27]
--死亡咆哮
_skai[57] = function(a, s)
    a.skMelee = a.skMelee + 4
    return (a.hero.data.isStar or a.map.IsFighting) and 100 or 0
end
--赤壁火
_skai[58] = _skai[30]
--群星陨落
_skai[59] = _skai[30]
--雷霆万钧
_skai[60] = _skai[30]
--仁德
_skai[61] = function(a, s)
    a.skCast = a.skCast + 4
    local h = a.hero
    local mtp = h.MaxTP
    local max = B_Math.ceil(s:GetExtValPercent(1) * mtp)
    local val = B_Math.min(max, mtp - h.TP)
    return B_Math.floor(100 * B_Math.clamp01(val / max))
end
--制霸
_skai[62] = function(a, s)
    a.skMelee = a.skMelee + 4
    return a.hero.AroundEnemy and 100 or 0
end
--神剑闪
_skai[63] = function(a, s)
    a.skCast = a.skCast + 4
    return B_Math.max(50, GetHeroSDmgSW(a.hero, s, 1.5, 1))
end
--幻影斩
_skai[64] = _skai[30]
--英魂
_skai[65] = function(a, s)
    a.skCast = a.skCast + 4
    return B_Math.floor(100 * B_Math.sqrt(B_Math.clamp01(1 - B_Math.clamp01(a.hero.HP / a.hero.MaxHP) * 1.42857)))
end
--一身是胆
_skai[66] = _skai[62]
--古之恶来
_skai[67] = _skai[62]
--孤胆刺杀
_skai[68] = _skai[62]
--堕天一击
_skai[69] = function(a, s)
    a.skMelee = a.skMelee + 4
    --关羽特殊处理
    return B_Math.abs(a.hero.x - a.hero.rival.x) > 1 and 999 or 100
end
--药泉
_skai[70] = function(a, s)
    a.skCast = a.skCast + 4
    --血量在0-70%按掉血量计算权值
    local h = a.hero
    local w = B_Math.floor(100 * B_Math.sqrt(B_Math.clamp01(1 - B_Math.clamp01(h.HP / h.MaxHP) * 1.42857)))
    if h.AroundEnemy then
        w = w + RangeDmgHW(h, s, B_Math.ceil(GetSDmg(h, s)) * B_Math.max(1, s.keepSec * 0.5)).weight
    end
    return w
end
--倾国倾城
_skai[71] = function(a, s)
    a.skCast = a.skCast + 4
    local r = a.hero.rival
    return B_Math.round(100 * (B_Math.clamp01(r.TP / r.MaxTP) - 0.3) / 0.7)
end
--洛神决
_skai[72] = function(a, s)
    a.skCast = a.skCast + 4
    return GetHeroSDmgSW(a.hero, s, 2, 1)
end
--死亡沼泽
_skai[73] = function(a, s)
    a.skCast = a.skCast + 4
    local dmg = B_Math.ceil(GetSDmg(a.hero, s)) * B_Math.max(1, s.keepSec * 0.5)
    dmg = RangeDmgHW(a.hero, s, dmg).weight
    return dmg > 0 and dmg + B_Math.ceil(40 * a.map.ArmiesSpace / a.map.width) + 10 or 0
end
--虎痴
_skai[74] = _skai[62]
--谦逊
_skai[75] = function(a, s)
    a.skMelee = a.skMelee + 4
    if s.exts and #s.exts > 0 then
        if IsFighting(a.hero) and not a.hero:ContainsBuff(10750) then
            return a.map.random:NextInt(50, 100)
        end
    end
    return 0
end
--爆裂箭
_skai[76] = function(a, s)
    a.skCast = a.skCast + 4
    return GetHeroSDmgSW(a.hero, s, 2, 1)
end
--逼战
_skai[77] = function(a, s)
    a.skMelee = a.skMelee + 4
    return a.hero.rival.Command ~= BAT_CMD.Attack and a.map.random:NextInt(40, 100) or 0
end
--地动波
_skai[78] = function(a, s)
    a.skMelee = a.skMelee + 4
    local rx, ry = s.rangeX.value, s.rangeY.value
    local minX, minY = a.hero.x - B_Math.modf(rx * 0.5), a.hero.y - B_Math.modf(ry * 0.5)
    local maxX, maxY = minX + rx, minY + ry
    local w = RangeDmgW(a.hero, minX - 0.5, minY - 0.5, maxX + 0.5, maxY + 0.5, B_Math.ceil(GetSDmg(a.hero, s)), false).weight;
    return w.heroDmg > 0 and 100 or w.weight
end
--金钟罩
_skai[79] = _skai[24]
--白马加身
_skai[80] = function(a, s)
    a.skMelee = a.skMelee + 4
    local h = a.hero
    if h.AroundEnemy then return 100 end
    local x = h.pos.x + (h.isAtk and 1 or -1) * s:GetExtValPercent(1) * BD_Const.BASE_MOVE_SPEED_UNIT * s.keepSec
    local pos = h.rival.pos
    if h.isAtk and pos.x <= x or pos.x >= x then return 100 end
    if not a.hero.isGod then
        return B_Math.floor(100 * B_Math.sqrt(B_Math.clamp01(1 - B_Math.clamp01(h.HP / h.MaxHP) * 1.42857)))
    end
    return 0
end
--星辰爆裂
_skai[81] = _skai[30]
--九霄神雷
_skai[82] = _skai[30]
--奇谋
_skai[83] = function(a, s)
    a.skCast = a.skCast + 4
    local var = a.hero.TP
    if var > 0 and var > a.hero.rival.TP then
        if IsFighting(a.hero) then
            var = a.map:SearchUnit(a.hero.isAtk, BD_Soldier)
            if var and not var:ContainsBuff(10830) then
                return 100
            end
        end
    else
        return 100
    end
    return 0
end
--凤舞九天
_skai[84] = _skai[30]
--日月双辉
_skai[85] = function(a, s)
    a.skCast = a.skCast + 4
    local h = a.hero
    local r = h.rival
    local x, y = r.pos.x, r.pos.y
    local rx, ry = s.rangeX.value * 0.5, s.rangeY.value * 0.5
    local qty = 0
    local isAtk = h.isAtk
    a.map:ForeachAreaUnits(x - rx, y - ry, x + rx, y + ry, function(trg) if CheckEnemy(trg, isAtk) then qty = qty + 1 end end)
    if qty > 0 then return 100 end
    local bufDmg = s.keepSec * h.Wis * s:GetExtPercent(1)
    if s.fesn == BD_Const.FE_EARTH then bufDmg = bufDmg + bufDmg * s.feval * 0.01 end
    local heroDmg = h.Wis * s:GetExtPercent(2)
    if s.fesn == BD_Const.FE_EARTH then heroDmg = heroDmg + heroDmg * s.feval * 0.01 end
    heroDmg = heroDmg + B_Math.ceil(GetDmg(h, s)) + bufDmg
    heroDmg = B_Math.ceil(heroDmg + heroDmg * r.SSD * 0.01)
    if heroDmg < r.HP then
        local kill, kill2 = 0, 0
        for _, u in pairs(a.map.combatUnits) do
            if CheckEnemy(u, isAtk) and getmetatable(u) == BD_Soldier then
                local uhp = u.HP
                local udmg = B_Math.min(B_Math.ceil(bufDmg + bufDmg * u.SSD * 0.01), uhp)
                if udmg < uhp then
                    kill2 = kill2 + udmg / uhp
                else
                    kill = kill + 1
                end
            end
        end
        return GetRangeDmgW(r, heroDmg, kill, kill2)
    else
        return 100
    end
end
--天下布武
_skai[86] = function(a, s)
    a.skMelee = a.skMelee + 4
    local dmg = s.keepSec * (1000 / s:GetExtInt(2)) * B_Math.ceil(GetSDmg(a.hero, s))
    local hrx, hry = s.rangeX.value * 0.5, s.rangeY.value * 0.5
    local x, y = a.hero.x, a.hero.y
    local w = RangeDmgW(a.hero, x - hrx, y - hry, x + hrx, y + hry, dmg)
    if w.heroDmg > 0 or w.kill > 0 or w.kill2 > 0 then
        return 100
    else
        return w.weight
    end
end
--五行天崩
_skai[87] = function(a, s)
    a.skCast = a.skCast + 4
    return GetHeroSDmgSW(a.hero, s, s:GetExtInt(1), 1)
end
--风牙破天
_skai[88] = function(a, s)
    a.skCast = a.skCast + 4
    return GetHeroSDmgSW(a.hero, s, 1.5, 1)
end
--幻梦琴音
_skai[89] = _skai[30]
--碧落
_skai[90] = _skai[30]
--掌控
_skai[91] = _skai[30]
--七进七出
_skai[92] = _skai[30]
--能量充盈
_skai[93] = _skai[5]
--风火灭世
_skai[94] = _skai[30]
--火神破
_skai[95] = _skai[30]
--天魔妙舞
_skai[96] = _skai[30]
--号令群雄
_skai[97] = function(a, s)
    a.skCast = a.skCast + 4
    if a.hero.TP > 0 and IsFighting(a.hero) then
        local var = a.map:SearchUnit(a.hero.isAtk, BD_Soldier)
        if var and not var:ContainsBuff(10970) then
            return 100
        end
    end
    return 0
end
--星罗棋盘
_skai[98] = _skai[30]
--天谴
_skai[99] = _skai[30]
--不灭铁壁
_skai[100] = function(a, s)
    a.skCast = a.skCast + 4
    return a.hero:ContainsBuff(11000) and 0 or 100
end
--饕餮盛宴
_skai[101] = _skai[30]