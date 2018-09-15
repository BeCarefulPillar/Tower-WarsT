
local notnull = notnull
local isnull = isnull
local insert = table.insert
local remove = table.remove
local getmetatable = getmetatable
local ipairs = ipairs
local pairs = pairs

local Mathf = Mathf
local Vector2 = Vector2
local Time = Time

local QYBattle = QYBattle
local BD_Soldier = QYBattle.BD_Soldier
local BD_Arrow = QYBattle.BD_Arrow
local BD_SKC = QYBattle.BD_SKC
local BD_SKD = QYBattle.BD_SKD

local BU_Soldier = BU_Soldier
local BU_Arrow = BU_Arrow
local BU_SKC = BU_SKC
local BU_SKD = BU_SKD

local _map = class()
--[Comment]
--战斗模块-战场
BU_Map = _map

_map.FightSpace = 6
_map.DepthSpace = 20
_map.SkillDepthSpace = 10
_map.SkillHeadDepth = 400
_map.SkillFootDepth = 3
_map.SkillSkyDepth = 600

function _map.OnLoad(m, c)
    assert(type(m) == "table" and getmetatable(m) == _map, "the BU_Map.OnLoad must be a instance")
    m.body = c
    m.go = c.gameObject

    m.prefabSoldier = c.prefabSoldier
    m.prefabArrow = c.prefabArrow
    m.view = c.view
    m.uiRoot = c.uiRoot

    m.atkHero = BU_Hero(m, c.atkHero)
    m.defHero = BU_Hero(m, c.defHero)

    m.origin = c.origin
    m.size = c.size
    m.tilt = c.tilt
    if m.width == nil then m.width = c.width end
    if m.height == nil then m.height = c.height end
    m.active = false
    m.mSpeed = 1
    m.recSpeed = 1
    m.recFrameRate = CONFIG.FRAME_RATE
    m.own = true

    m.units = { }

    c:BindFunction("OnUnLoad", "Dispose", "ClickAtkHeroIcon", "ClickDefHeroIcon", "GetDepth", "InversePosition")

    m:CalculateUV()
end

function _map.OnUnLoad(m, c)
    if m.body == c then
        m:Dispose()
        m.body = nil
--        m:Dispose()
    end
end

--初始化
--dat : BD_Field
--own : boolean
function _map.Init(m, dat, own)
    if m.dat == dat then return end
    assert(notnull(m.body), "the BU_Map is not load body")
    assert(dat and getmetatable(dat) == QYBattle.BD_Field, "init BU_Map the arg dat must be BD_Field")

    m:Dispose()

    m.dat = dat
    m.width = dat.width
    m.height = dat.height
    m:CalculateUV()

    m.body.width = dat.width
    m.body.height = dat.height

    m.own = own ~= false

--if isDebug then
--    dat.defHero.maxHP.value = 99999999
--    dat.defHero:SetHP(99999999)
--    dat.atkHero.maxSP.value = 9999
--    dat.defHero:SetSP(9999)
--end
    m.atkHero:Init(dat.atkHero)
    m.defHero:Init(dat.defHero)
    m.atkHero.rival = m.defHero
    m.defHero.rival = m.atkHero

    m.atkHero.go:SetActive(true)
    m.defHero.go:SetActive(true)

    m:BuildNewUnit(dat:SearchNoBodyUnits())

    if m.updHandle == nil then
        m.updHandle = UpdateBeat:CreateListener(m.Update, m)
        UpdateBeat:AddListener(m.updHandle)
    end

    --更新C#端数据
    local var = m.body:InitCombatUnits()
    local len = var.length
    for i, u in pairs(dat.combatUnits) do
        if i > 0 and i <= len then
            var[i - 1] = u.isAtk and (getmetatable(u) == BD_Soldier and 2 or 1) or (getmetatable(u) == BD_Soldier and 4 or 3)
        end
    end
end

local function BattleEnd(m)
    if APP.targetFrameRate ~= m.recFrameRate then
        APP.targetFrameRate = m.recFrameRate
    end
    local func = m.onBattleEnd
    if func then
        m.onBattleEnd = nil
        func(m.dat and m.dat.result or 0)
    end
end

function _map.Dispose(m)
    m.active = false
    m.body.active = false
    m.mSpeed = 1

    if m.updHandle then
        UpdateBeat:RemoveListener(m.updHandle)
        m.updHandle = nil
    end

    BattleEnd(m)
    
    if #m.units > 0 then
        for _, u in ipairs(m.units) do u:Destruct() end
        m.units = { }
    end

    if m.dat then
        m.dat:Dispose()
        m.dat = nil
    end

    m.atkHero:Dispose()
    m.defHero:Dispose()
end

function _map.StartBattle(m, onBattleEnd)
    m.onBattleEnd = onBattleEnd
    m.recFrameRate = APP.targetFrameRate

    local dat = m.dat
    if dat == nil or dat.result ~= 0 then
        m.active = false
        m.body.active = false
        BattleEnd(m)
        return
    end

    APP.targetFrameRate = isIOS and 60 or dat.frameRate

    m.active = true
    m.body.active = true
    m.pause = false

    local cmd = QYBattle.BAT_CMD.Wait
    dat:SetAtkHeroCmd(cmd)
    dat:SetAtkArmCmd(cmd)
    dat:SetDefHeroCmd(cmd)
    dat:SetDefArmCmd(cmd)
end

function _map.SkipBattle(m)
    local dat = m.dat
    if m.active and dat and dat.result == 0 then
        dat:ActivateAI(true)
        dat:ActivateAI(false)
        dat:RecordEvent(false)
        --跳过战斗
    end
end

function _map.Update(m)
    if m.active then
        if isIOS and Time.frameCount % 2 == 0 then return end
        
        local var = m.mSpeed
        if var > 0 then
            local dat = m.dat
            if var > 1 then
                for i = 1, var do dat:Update() end
            else
                dat:Update()
            end

            if dat.result == 0 then
                m:BuildNewUnit(dat:GetNewUnits())

                --更新C#端数据
                var = m.body:InitCombatUnits()
                local len = var.length
                for i, u in pairs(dat.combatUnits) do
                    if i > 0 and i <= len then
                        var[i - 1] = u.isAtk and (getmetatable(u) == BD_Soldier and 2 or 1) or (getmetatable(u) == BD_Soldier and 4 or 3)
                    end
                end
            else
                BattleEnd(m)
            end

            local units = m.units
            --显示对象Update
--            for _, u in ipairs(units) do u:Update() end
--            for i = #units, 1, -1 do if notnull(units[i]) then remove(units, i) end end
            m.atkHero:Update()
            m.defHero:Update()
            local dq = 0
            for i = 1, #units, 1 do
                i = i - dq
                var = units[i]
                var:Update()
                if isnull(var.go) then
                    remove(units, i)
                    dq = dq + 1
                end
            end
        end
    end
end

function _map.BuildNewUnit(m, us)
    if us then
        for _, u in ipairs(us) do
            if u.isAlive and (u.body == nil or isnull(u.body.go)) then
                local typ = getmetatable(u)
                if typ == BD_Soldier then
                    typ = BU_Soldier(m, m.go:AddChild(m.prefabSoldier, (u.isAtk and "atk_soldier_" or "def_soldier")..u.id))
                elseif typ == BD_Arrow then
                    typ = BU_Arrow(m, m.go:AddChild(m.prefabArrow, "arrow"))
                elseif typ == BD_SKC then
                    typ = BU_SKC(m, (u.isAtk and m.atkHero or m.defHero).go:AddChild("skc_"..u.sn))
                elseif typ == BD_SKD then
                    typ = BU_SKD(m, (u.isAtk and m.atkHero or m.defHero).go:AddChild("skd_"..u.sn))
                else
                    typ = nil
                end
                if typ then
                    typ:Init(u)
                    insert(m.units, typ)
                end
            end
        end
    end
end

--战斗激活状态
function _map.get_Active(m) return m.active and m.dat.result == 0 end
--倍速
function _map.get_speed(m) return m.recSpeed end
--倍速
function _map.set_speed(m, v)
    v = Mathf.Clamp(v, 1, 5)
    m.mSpeed = v
    m.recSpeed = v
    Time.timeScale = isIOS and v * 0.9 or v
end
--暂停
function _map.get_pause(m) return m.mSpeed <= 0 end
--暂停
function _map.set_pause(m, v)
    if v then
        m.mSpeed = 0
        Time.timeScale = 0
    else
        local sp = m.recSpeed
        m.mSpeed = sp
        Time.timeScale = isIOS and sp * 0.9 or sp
    end
end

function _map.CalculateUV(m)
    m.uvx = Vector2(m.size.x / m.width, 0)
    local dy = m.size.y / m.height
    m.uvy = Vector2(Mathf.Sin(m.tilt * Mathf.Deg2Rad) * dy, Mathf.Cos(m.tilt * Mathf.Deg2Rad) * dy)
    m.m = m.uvx.x * m.uvy.y - m.uvy.x * m.uvx.y
end

--给定的位置在地图上是否可用
function _map.PosAvailable(m, x, y) return m.dat and m.dat:PosAvailable(x, y) end
--获取单位的实际位置
function _map.GetPosition(m, x, y)
    x, y = x + 0.5, y + 0.5
    local o, ux, uy = m.origin, m.uvx, m.uvy
    return Vector2(o.x + ux.x * x + uy.x * y, o.y + ux.y * x + uy.y * y)
end
--获取单位的实际位置
function _map.GetPosV2(m, v2)
    local x, y = v2.x + 0.5, v2.y + 0.5
    v2 = m.origin
    local ux, uy = m.uvx, m.uvy
    return Vector2(v2.x + ux.x * x + uy.x * y, v2.y + ux.y * x + uy.y * y)
end
--获取单位的实际位置
function _map.GetVector(m, x, y)
    local ux, uy = m.origin, m.uvx, m.uvy
    return Vector2(ux.x * x + uy.x * y, ux.y * x + uy.y * y)
end
--获取单位的实际位置
function _map.GetVectorV2(m, v2)
    local ux, uy = m.uvx, m.uvy
    return Vector2(ux.x * v2.x + uy.x * v2.y, ux.y * v2.x + uy.y * v2.y)
end
--根据实际位置获取地图位置
function _map.InversePosition(m, v2)
    if m.m == nil or m.m == 0 then return Vector2(Mathf.Infinity, Mathf.Infinity) end
    v2 = v2 - m.origin
    v2:Set(((v2.x * m.uvy.y - m.uvy.x * v2.y) / m.m) - 0.5, ((m.uvx.x * v2.y - v2.x * m.uvx.y) / m.m) - 0.5)
    return v2
end
--根据实际向量获取地图向量
function _map.InverseVector(m, v2)
    if m.m == nil or m.m == 0 then return Vector2(Mathf.Infinity, Mathf.Infinity) end
    return Vector2((v2.x * m.uvy.y - m.uvy.x * v2.y) / m.m, (m.uvx.x * v2.y - v2.x * m.uvx.y) / m.m)
end
--通过Y位置获取单位的深度排序
function _map.GetDepth(m, y) return(m.height - Mathf.Ceil(y)) * _map.DepthSpace end

--视图移动到X位置
--x : number
function _map.ViewMoveX(m, x)
    local view = m.view
    if view then view:MoveTo(m:GetPosition(x, m.height * 0.5)) end
end
--视图移动BD_Unit位置
--bd : BD_Unit
function _map.ViewMoveToBD(m, bd)
    local view = m.view
    if view then view:MoveTo(m:GetPosition(bd.pos.x, m.height * 0.5)) end
end
--视图移动BU_Unit位置
--bu : BU_Unit
function _map.ViewMoveToBU(m, bu)
    m = m.view
    if m then m:MoveTo(bu.trans) end
end
--视图跟随Trasnform位置
--trans : Trasnform
function _map.ViewFollow(m, trans)
    m = m.view
    if m then m:Follow(trans) end
end
--视图跟随BU_Unit位置
--bu : BU_Unit
function _map.ViewFollowBU(m, bu)
    m = m.view
    if m then m:Follow(bu.trans) end
end
--视图停止跟随Trasnform位置
--trans : Trasnform
function _map.ViewStopFollow(m, trans)
    m = m.view
    if m then
        if trans then m:StopFollow(trans) else m:StopFollow() end
    end
end
--视图停止跟随BU_Unit位置
--bu : BU_Unit
function _map.ViewStopFollowBU(m, bu)
    m = m.view
    if m then
        if bu then m:StopFollow(bu.trans) else m:StopFollow() end
    end
end

--region 技能资源部分
local function LoadSkillAsset(m, assetName, async)
    if assetName == nil or assetName == "" then return end
    if async then
        m.body:LoadAssetAsync(assetName)
    else
        m.body:LoadAsset(assetName)
    end
end
--加载技能资源
function _map.LoadSkillRes(m)
    if m.dat == nil then return end
    local h = m.dat.atkHero
    if h.skill then
        for _, s in ipairs(h.skill) do
            s = s.sn.value
            LoadSkillAsset(m, ResName.SkcEffect(s))
            LoadSkillAsset(m, ResName.SkcAnim(s), true)
        end
    end
    h = h.dehero
    if h and h.skill then
        for _, s in ipairs(h.skill) do
            s = s.sn.value
            LoadSkillAsset(m, ResName.SkdEffect(s))
            LoadSkillAsset(m, ResName.SkdAnim(s), true)
        end
    end
    h = m.dat.defHero
    if h.skill then
        for _, s in ipairs(h.skill) do
            s = s.sn.value
            LoadSkillAsset(m, ResName.SkcEffect(s))
            LoadSkillAsset(m, ResName.SkcAnim(s), true)
        end
    end
    h = h.dehero
    if h and h.skill then
        for _, s in ipairs(h.skill) do
            s = s.sn.value
            LoadSkillAsset(m, ResName.SkdEffect(s))
            LoadSkillAsset(m, ResName.SkdAnim(s), true)
        end
    end
end
--获取武将技图集
function _map.GetSkcAtlas(m, sksn) return m.body:GetAsset(ResName.SkcAnim(sksn), typeof(UIAtlas)) end
--获取武将技特效
function _map.GetSkcEffect(m, sksn) return m.body:GetAsset(ResName.SkcEffect(sksn), typeof(GameObject)) end
--获取副将技图集
function _map.GetSkdAtlas(m, sksn) return m.body:GetAsset(ResName.SkdAnim(sksn), typeof(UIAtlas)) end
--获取副将技特效
function _map.GetSkdEffect(m, sksn) return m.body:GetAsset(ResName.SkdEffect(sksn), typeof(GameObject)) end
--释放技能资源
function _map.DisposeSkillRes(m) m.body:DisposeAsset() end
--endregion

if isDebug then
    function _map.ShowExInfo(m, isOwn, isShow, str)
        local lab = isOwn and m.exLab1 or m.exLab2
        if isShow then
            if isnull(lab) then
                lab = m.go.transform.parent:AddWidget(typeof(UIlabel), "ex_lab")
                if isOwn then m.exLab1 = lab else m.exLab2 = lab end
                lab.applyGradient = false
                lab.fontSize = 24
                lab.trueTypeFont = AM.mainFont
                lab.pivot = isOwn and UIWidget.Pivot.TopLeft or UIWidget.Pivot.TopRight
                lab.effectDistance = Vector2(0.4, 0.4)
                lab.effectStyle = UILabel.Effect.Shadow
                lab.overflowMethod = UILabel.Overflow.ResizeFreely
                lab.depth = _map.SkillSkyDepth + 100
                lab.cachedTransform.localPosition = Vector3(isOwn and -480 or 480, 180, 0)
                local sp = lab.cachedGameObject:AddWidget(typeof(UISprite), "bg")
                sp.atlas = AM.mainAtlas
                sp.spriteName = "mask"
                sp.type = UIBasicSprite.Type.Sliced
                sp.depth = lab.depth - 1
                sp.color = Color(0, 0, 0, 0.5)
                sp:SetAnchor(lab.cachedGameObject, 0, 0, 0, 0)
            else
                lab:SetActive(true)
            end
            lab.text = str
        elseif notnull(lab) then
            lab:SetActive(false)
        end
    end
end