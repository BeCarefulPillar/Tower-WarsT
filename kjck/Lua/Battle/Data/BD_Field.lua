local insert = table.insert
local remove = table.remove
local getmetatable = getmetatable
local rawget = rawget
local pairs = pairs
local ipairs = ipairs
local isnull = tolua.isnull

local QYBattle = QYBattle
local BD_Const = QYBattle.BD_Const
local B_Math = QYBattle.B_Math
local BE_Type = QYBattle.BE_Type

local BAT_CMD = 
{
    --[Comment]
    --结束
    End = 0,
    --[Comment]
    --待命
    Wait = 1,
    --[Comment]
    --进攻
    Attack = 2,
    --[Comment]
    --撤退
    Retreat = 3,
}
--[Comment]
--战场指令
QYBattle.BAT_CMD = BAT_CMD

--[Comment]
--基本的帧时间间隔(MS)
local BASE_DELTA = 30

--[Comment]
--战场模板
local _field = 
{
    maxTime = BD_Const.MAX_TIME,
    frameRate = B_Math.modf(1000 / BASE_DELTA),
    maxFrameCount = B_Math.modf(BD_Const.MAX_TIME / BASE_DELTA),
    deltaTime = 0.001 * BASE_DELTA,
    deltaMillisecond = BASE_DELTA,

    result = 0,
}

--高性能获取作战单位
--returns : 高性能函数
local function EnGetCombatUnit(us, h) return function(x, y) return us[x * h + y + 1] end end

--[Comment]
--构造器
function _field.__call(t, bat, hasEvt, seed)
    assert(bat and getmetatable(bat) == QYBattle.Battle, "Battle is null")

    t = setmetatable(
    {
        battle = bat,
        width = BD_Const.BATTLE_WIDTH,
        height = BD_Const.BATTLE_HEIGHT,
        maxCombatUnit = BD_Const.BATTLE_WIDTH * BD_Const.BATTLE_HEIGHT,
        atkMinX = 0, atkMaxX = 0,
        defMinX = 0, defMaxX = 0,
        newUnits = hasEvt and { } or nil,
        random = QYBattle.B_Random(seed and seed ~= 0 and seed or math.modf(math.random(-2147483648, 2147483647))),

        maxTime = _field.maxTime,
        frameRate = _field.frameRate,
        maxFrameCount = _field.maxFrameCount,
        deltaTime = _field.deltaTime,
        deltaMillisecond = _field.deltaMillisecond,
        enFrameCount = bat.EnInt(0),
        frameCount = 0,
        time = 0,

        units = { },
        combatUnits = { },

        result = 0,

        _atkHeroCmd = BAT_CMD.Wait,
        _atkArmCmd = BAT_CMD.Wait,
        _defHeroCmd = BAT_CMD.Wait,
        _defArmCmd = BAT_CMD.Wait,

        atkHeroCmd = BAT_CMD.Wait,
        atkArmCmd = BAT_CMD.Wait,
        defHeroCmd = BAT_CMD.Wait,
        defArmCmd = BAT_CMD.Wait,

        updateBattleInfo = true,
        _battleInfo =
        {
            force = false,
--          str = false,
--          wis = false,
--          cap = false,
            hp = false,
        }
    }, _field)

    t.EnGetCombatUnit = EnGetCombatUnit(t.combatUnits, t.height)

    t.atkHero = QYBattle.BD_Hero(t, -1, -1, true)
    t.defHero = QYBattle.BD_Hero(t, -1, -1, false)
    t.atkHero.rival = t.defHero
    t.defHero.rival = t.atkHero

    return t
end

--[Comment]
--更新单位区域
local function UpdateUnitArea(f)
    local atkMinX = f.width
    local defMinX = atkMinX
    local atkMaxX, defMaxX = 0, 0
    for i, u in pairs(f.combatUnits) do
        i = u.x
        if u.isAtk then
            if i < atkMinX then atkMinX = i end
            if i > atkMaxX then atkMaxX = i end
        else
            if i < defMinX then defMinX = i end
            if i > defMaxX then defMaxX = i end
        end
    end
    f.atkMinX, f.atkMaxX = atkMinX, atkMaxX
    f.defMinX, f.defMaxX = defMinX, defMaxX
end

--初始化数据
local function InitData(f)
    local atk, def = f.atkHero, f.defHero
    --初始化武将开始数据
    atk:InitStartData()
    atk:InitStartData()
    --初始化武将属性
    atk:InitAttrib()
    def:InitAttrib()

    local atkLnp = BD_Const.GetLnpPosData(atk.dat.lnp.value)
    local defLnp = BD_Const.GetLnpPosData(def.dat.lnp.value)

    --初始化士兵
    local unit = nil
    local BD_Soldier = QYBattle.BD_Soldier
    local qty = B_Math.min(atk.TP, #atkLnp)
    for i = 1, qty, 1 do
        unit = BD_Soldier(f, (B_Math.modf(atkLnp[i] / f.height)), atkLnp[i] % f.height)
        unit:InitData(atk)
--        if i == 1 then unit:LogData() end
    end
    qty = B_Math.min(def.TP, #defLnp)
    for i = 1, qty, 1 do
        unit = BD_Soldier(f, (f.width - B_Math.modf(defLnp[i] / f.height)), defLnp[i] % f.height)
        unit:InitData(def)
--        if i == 1 then unit:LogData() end
    end
    --配置武将位置
    local atkX, defX = 0, f.width - 1
    for _, u in pairs(f.combatUnits) do
        if getmetatable(u) == BD_Soldier then
            if u.isAtk then
                if u.x > atkX then atkX = u.x end
            else
                if u.x < defX then defX = u.x end
            end
        end
    end
    while atkX < f.width do atkX = atkX + 1; if f:PlaceCombatUnit(atk, B_Math.max(9, atkX), 6) then break end end
    while defX > 0 do defX = defX - 1; if f:PlaceCombatUnit(def, B_Math.min(f.width - 10, defX), 6) then break end end
    atk:ApplyPos()
    def:ApplyPos()
    --更新战斗区域
    UpdateUnitArea(f)
end
--攻城战单场战都初始
--dat : S_BattleFightData
--atk : 攻方EnHero
--def : 守方EnHero
function _field.InitSiege(f, dat, atk, def)
    f.atkHero:InitData(atk, dat.atkHero, dat.armRes == 2, dat.lnpRes == 2)
    f.defHero:InitData(def, dat.defHero, dat.armRes == 1, dat.lnpRes == 1)
    InitData(f)
end
--单场战初始
--dat : S_BattleSingle
function _field.InitSingle(f, dat)
    f.atkHero:InitData(f.battle.atkHeros[1], dat.atk.fight, dat.armRes == 2, dat.lnpRes == 2)
    f.defHero:InitData(f.battle.defHeros[1], dat.def.fight, dat.armRes == 1, dat.lnpRes == 1)
    InitData(f)
end

--[Comment]
--属性器
local _get =
{
    --[Comment]
    --战斗是否结束
    isBattleEnd = function(f) return f.result ~= 0 end,
    --[Comment]
    --是否记录事件
    hasEvent = function(f) return f.newUnits ~= nil end,
    --[Comment]
    --当前帧是否是整秒(用于每秒事件)
    isSecondFrame = function(f) return f.frameCount % f.frameRate == 0 end,
    --[Comment]
    --是否已经交战
    IsFighting = function(f) return f.atkMinX < f.defMaxX + 2 and f.defMinX < f.atkMaxX + 2 end,
    --[Comment]
    --两军间距
    ArmiesSpace = function(f) return f.atkMinX < f.defMaxX + 2 and f.defMinX < f.atkMaxX + 2 and 0 or B_Math.max(f.defMinX - f.atkMaxX, f.atkMinX - f.defMaxX) end,
    --[Comment]
    --战场信息
    battleInfo = function(f)
        local info = f._battleInfo
        if f.updateBattleInfo then
            f.updateBattleInfo = false
            local atk, def = f.atkHero, f.defHero
            info.force = atk.TP > def.TP
--            info.str = atk.Strength > def.Strength
--            info.wis = atk.Intelligent > def.Intelligent
--            info.cap = atk.Cap > def.Cap
            info.hp = B_Math.ceil(atk.HP / def.Dmg) > B_Math.ceil(def.HP / atk.Dmg)
        end
        return info
    end
}
--[Comment]
--索引器
function _field.__index(t, k)
    local v = rawget(_field, k)
    if v == nil then
        v = rawget(_get, k)
        return v and v(t)
    end
    return v
end

--[Comment]
--结束释放
function _field.Dispose(f)
    if f.result == 0 then
        local dat = f.atkHero and f.atkHero.dat
        if dat then
            dat.status.value = 0
            dat.stats.value = dat.stats.value + 1
        end
        dat = f.defHero and f.defHero.dat
        if dat then
            dat.stats.value = dat.stats.value + 1
        end
        if f.atkHero ~= nil and f.atkHero.dat ~= nil then
            f.atkHero.dat.status.value = 0
        end
        f.result = -1
    end

    f.atkAI, f.defAI = nil, nil

    if f.newUnits ~= nil and #f.newUnits > 0 then f.newUnits = { } end

    if f.units ~= nil and #f.units > 0 then
        for i, u in ipairs(f.units) do u:Dead() end
    end
end

--[Comment]
--事件记录
--on:是否开启
function _field.RecordEvent(f, on)
    if on == false then
        f.newUnits = nil
    elseif f.newUnits == nil then
        f.newUnits = { }
    end
    for i, u in ipairs(f.units) do u:RecordEvent(on) end
end
--[Comment]
-- 清除当前为止的所有事件
function _field.ClearAllEvents()
    if f.newUnits and #f.newUnits > 0 then f.newUnits = { } end
    for i, u in ipairs(f.units) do u:ClearEvent() end
end

--[Comment]
--激活AI
function _field.ActivateAI(f, isAtk, retreat, castSkill)
    if isAtk then
        if f.atkAI == nil then
            f.atkAI = QYBattle.BD_AI(f.atkHero, retreat, castSkill)
        end
    elseif f.defAI == nil then
        f.defAI = QYBattle.BD_AI(f.defHero, false, castSkill)
--        f.defAI = QYBattle.BD_AI(f.defHero, retreat, castSkill)
    end
end
--[Comment]
--移除AI
function _field.DeactivateAI(f, isAtk)
    if isAtk then
        f.atkAI = nil
    else
        f.defAI = nil
    end
end

--[Comment]
--设置攻方武将指令
function _field.SetAtkHeroCmd(f, cmd) f._atkHeroCmd = cmd end
--[Comment]
--设置攻方士兵指令
function _field.SetAtkArmCmd(f, cmd) f._atkArmCmd = cmd end
--[Comment]
--设置守方武将指令
function _field.SetDefHeroCmd(f, cmd) f._defHeroCmd = cmd end
--[Comment]
--设置守方士兵指令
function _field.SetDefArmCmd(f, cmd) f._defArmCmd = cmd end

--[Comment]
--添加一个战斗数据到列表
function _field.Add(f, u)
    if u and u.isAlive and u.id == nil then
        insert(f.units, u)
        if f.newUnits then insert(f.newUnits, u) end
    end
end

--[Comment]
--更新循环
function _field.Update(f)
    f.frameCount = f.enFrameCount.value
    local var
    if f.result == 0 then
        var = f.atkHero
        if var.isDead or var.x <= 0 or not var.inMap or f.frameCount >= f.maxFrameCount then
            print("攻方战败", var.isDead, var.x <= 0, not var.inMap, f.frameCount >= f.maxFrameCount)
            --攻方战败
            f.result = -1
            var = var.dat
            var.status.value = 0
            var.stats.value = var.stats.value + 1
            var = f.defHero.dat.stats
            var.value = var.value + 1
            if f.battle.battleType == 12 then f.battle:AddFightTimeRec(B_Math.floor(f.frameCount * f.deltaMillisecond * 0.001)) end
        else
            var = f.defHero
            if var.isDead or var.x >= f.width - 1 or not var.inMap then
                print("守方战败", var.isDead, var.x >= f.width - 1, not var.inMap)
                f.result = 1
                var = var.dat
                var.status.value = 0
                var.stats.value = var.stats.value + 1
                var = f.atkHero.dat.stats
                var.value = var.value + 1
                if f.battle.battleType == 12 then f.battle:AddFightTimeRec(B_Math.floor(f.frameCount * f.deltaMillisecond * 0.001)) end
            end
        end
    end

    UpdateUnitArea(f)

    if f.atkAI then f.atkAI:Update() end
    if f.defAI then f.defAI:Update() end

    if f.atkHeroCmd ~= f._atkHeroCmd then
        print("atk change hero cmd",f._atkHeroCmd )
        f.atkHeroCmd = f._atkHeroCmd
        f.atkHero:AddEvent(BE_Type.HeroCmd, f.atkHeroCmd)
    end
    if f.atkArmCmd ~= f._atkArmCmd then
        print("atk change arm cmd",f._atkHeroCmd )
        f.atkArmCmd = f._atkArmCmd
        f.atkHero:AddEvent(BE_Type.SoCmd, f.atkArmCmd)
    end
    if f.defHeroCmd ~= f._defHeroCmd then
        print("def change hero cmd",f._atkHeroCmd )
        f.defHeroCmd = f._defHeroCmd
        f.defHero:AddEvent(BE_Type.HeroCmd, f.defHeroCmd)
    end
    if f.defArmCmd ~= f._defArmCmd then
        print("atk change arm cmd",f._atkHeroCmd )
        f.defArmCmd = f._defArmCmd
        f.defHero:AddEvent(BE_Type.SoCmd, f.defArmCmd)
    end

    var = 0
    for i, u in ipairs(f.units) do
        if u.isAlive then
            u:Update()
        else
            var = var + 1
        end
    end

    if var > 20 then
        var = f.units
        for i = #var, 1, -1 do
            if not var[i].isAlive then remove(var, i) end
        end
    end
    
    f.updateBattleInfo = true

    var = f.enFrameCount
    var.value = var.value + 1
    f.time = var.value * f.deltaMillisecond
end

-- region 战斗单位部分
--[Comment]
--单位XY位置转索引
local function PosToIdx(f, x, y) return x and x * f.height + y + 1 or 0 end
--[Comment]
--给定的单位XY位置是否可用
function _field.PosAvailable(f, x, y)
    x = PosToIdx(f, x, y)
    return x >= 1 and x <= f.maxCombatUnit
end
--[Comment]
--给定的Vector位置是否可用
function _field.PosVecAvailable(f, v)
    v = PosToIdx(f, v.x, v.y)
    return v >= 1 and v <= f.maxCombatUnit
end
--[Comment]
--给定的单位XY位置是否可用并且无单位占用
function _field.PosAvailableAndEmpty(f, x, y)
    x = PosToIdx(f, x, y)
    return x >= 1 and x <= f.maxCombatUnit and f.combatUnits[x] == nil
end
--[Comment]
--请求一个地图位置，返回成功与否，输出[MapPosInfo]地图位置信息
--f : 战场
--u : 发送请求的作战单位
--x : 请求的X位置
--y : 请求的Y位置
--return : 成功与否
function _field.PlaceCombatUnit(f, u, x, y)
    if u then
        local i, us = PosToIdx(f, x, y), f.combatUnits
        if i >= 1 and i <= f.maxCombatUnit and us[i] == nil then
            us[PosToIdx(f, u.x, u.y)] = nil
            us[i] = u
            u:SetPos(x, y)
            return true
        end
    end
    return false
end
--[Comment]
--清除一个作战单位
function _field.RemoveCombatUnit(f, u)
    if u then
        local i = PosToIdx(f, u.x, u.y)
        if f.combatUnits[i] == u then f.combatUnits[i] = nil end
        --u:Dead()
    end
end
--[Comment]
--通过XY位置获取一个作战单位
function _field.GetCombatUnit(f, x, y) return f.combatUnits[PosToIdx(f, x, y)] end
--[Comment]
--遍历作战单位
function _field.ForeachUnit(f, func, typ)
    if func then
        for i, u in pairs(f.combatUnits) do
            if (typ == nil or typ == getmetatable(u)) and not u.isDead then
                func(u)
            end
        end
    end
end
--[Comment]
--在地图中搜寻第一个指定类型和势力的作战单位
function _field.SearchUnit(f, isAtk, typ) for _, u in pairs(f.combatUnits) do if (isAtk == nil or isAtk == u.isAtk) and (typ == nil or getmetatable(u) == typ) and not u.isDead then return u end end end
--[Comment]
--在地图中搜寻所有指定类型和势力的作战单位
function _field.SearchUnits(f, isAtk, typ)
    local ret = { }
    for _, u in pairs(f.combatUnits) do
        if (isAtk == nil or isAtk == u.isAtk) and (typ == nil or typ == getmetatable(u)) and not u.isDead then
            insert(ret, u)
        end
    end
    return ret
end
--[Comment]
--在地图中搜寻所有指定类型和势力的作战单位数量
function _field.SearchUnitCount(f, isAtk, typ)
    local qty = 0
    for _, u in pairs(f.combatUnits) do if (isAtk == nil or isAtk == u.isAtk) and (typ == nil or getmetatable(u) == typ) and not u.isDead then qty = qty + 1 end end
    return qty
end
--[Comment]
--在地图中搜寻指定势力单位最多的列
function _field.SearchUnitFocusX(f, isAtk)
    local tnt, h, us = 0, f.height, f.combatUnits
    local fx, u, cnt
    for i = 1, f.maxCombatUnit - 1, h do
        cnt = 0
        for j = i, i + h - 1, 1 do
            u = us[j]
            if u and (isAtk == nil or isAtk == u.isAtk) then cnt = cnt + 1 end
        end
        if cnt > tnt then
            fx = i
            tnt = cnt
        end
    end
    return fx and B_Math.floor(fx / h) or B_Math.floor(f.width * 0.5)
end
--[Comment]
--在地图中搜寻指定势力单位最多的行
function _field.SearchUnitFocusY(f, isAtk)
    local w, h = f.width, f.height
    local us = f.combatUnits
    local tnt = 0
    local fy, u, cnt
    for i = 1, h, 1 do
        cnt = 0
        for j = i, w, h do
            u = us[j]
            if u and (isAtk == nil or isAtk == u.isAtk) then cnt = cnt + 1 end
        end
        if cnt > tnt then
            fy = i
            tnt = cnt
        end
    end
    return fy and fy - 1 or B_Math.floor(h * 0.5)
end
--[Comment]
--在地图中搜寻指定势力单位最多的 X, Y
--return : x, y
function _field.SearchUnitFocus(f, isAtk)
    local w, h, us = f.width, f.height, f.combatUnits
    local tnt = 0
    local fx, fy, u, cnt
    for i = 1, f.maxCombatUnit - 1, h do
        cnt = 0
        for j = i, i + h - 1, 1 do
            u = us[j]
            if u and (isAtk == nil or isAtk == u.isAtk) then cnt = cnt + 1 end
        end
        if cnt > tnt then
            fx = i
            tnt = cnt
        end
    end
    tnt = 0
    for i = 1, h, 1 do
        cnt = 0
        for j = i, w, h do
            u = us[j]
            if u and (isAtk == nil or isAtk == u.isAtk) then cnt = cnt + 1 end
        end
        if cnt > tnt then
            fy = i
            tnt = cnt
        end
    end
    return fx and B_Math.floor(fx / h) or B_Math.floor(f.width * 0.5), fy and fy - 1 or B_Math.floor(h * 0.5)
end
--[Comment]
--遍历指定范围的所有单位
--xMin : 地图位置左边
--yMin : 地图位置下边
--xMax : 地图位置右边
--yMax : 地图位置上边
--func : 遍历函数
function _field.ForeachAreaUnits(f, xMin, yMin, xMax, yMax, func)
    if func then
        local xi, xa = B_Math.max(B_Math.round(xMin) - 1, 0), B_Math.min(B_Math.round(xMax) + 1, f.width - 1)
        local yi, ya = B_Math.max(B_Math.round(yMin) - 1, 0), B_Math.min(B_Math.round(yMax) + 1, f.height - 1)
        local us, h = f.combatUnits, f.height
        local u, pos
        for x = xi, xa, 1 do
            for y = yi, ya, 1 do
                u = us[x * h + y + 1]
                if u then -- and (typ == nil or getmetatable(u) == typ) 
                    x, y = u.pos.x, u.pos.y
                    if x <= xMax and x >= xMin and y <= yMax and y >= yMin then func(u) end
                end
            end
        end
    end
end
--[Comment]
--获取实际位置到达给定地图坐标的单位
function _field.GetArrivedUnit(f, x, y)
    local xMin, xMax = x - 0.5, x + 0.5
    local yMin, yMax = y - 0.5, y + 0.5
    local h, us = f.height, f.combatUnits
    local xi, xa = B_Math.max(B_Math.round(xMin) - 1, 0), B_Math.min(B_Math.round(xMax) + 1, f.width - 1)
    local yi, ya = B_Math.max(B_Math.round(yMin) - 1, 0), B_Math.min(B_Math.round(yMax) + 1, h - 1)
    local u
    for x = xi, xa, 1 do
        for y = yi, ya, 1 do
            u = us[x * h + y + 1]
            if u then
                x, y = u.pos.x, u.pos.y
                if x <= xMax and x >= xMin and y <= yMax and y >= yMin then return u end
            end
        end
    end
end
-- endregion

-- region 扩展部分
--[Comment]
--获取一个随机整数
--m=nil n=nil : 返回[0(包括)-Int32.MaxValue(不包括)]之间的值
--n=nil : 返回[0(包括)-m(不包括)]之间的值
--返回[m(包括)-n(不包括)]之间的值
function _field.RandomInt(f, m, n) return f.random:NextInt(m, n) end
--[Comment]
--获取一个随机浮点数
--m=nil n=nil : 返回[0(包括)-1(不包括)]之间的值
--n=nil : 返回[0(包括)-m(不包括)]之间的值
--返回[m(包括)-n(不包括)]之间的值
function _field.Random(f, m, n) return f.random:Next(m, n) end

--[Comment]
--输出日志
function _field.Log(f, o) if f.debug then print(o) end end
--[Comment]
--静态输出日志
function _field.GLog(o) print(o) end

--[Comment]
--获取所有新生成的单位
function _field.GetNewUnits(f)
    local us = f.newUnits
    if us and #us > 0 then
        f.newUnits = { }
        return us
    end
end
--[Comment]
--获取所以没有显示层的单位
function _field.SearchNoBodyUnits(f)
    local us = f.units
    if us and #us > 0 then
        local ret = { }
        for i, u in ipairs(us) do if u.isAlive and (u.body == nil or isnull(u.body.go)) then insert(ret, u) end end
        return ret
    end
end
-- endregion

setmetatable(_field, _field)
--[Comment]
--战场
QYBattle.BD_Field = _field