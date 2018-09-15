local RenderTexture = UnityEngine.RenderTexture
local Destroy = UnityEngine.Object.Destroy
local Camera = UnityEngine.Camera
local Screen = UnityEngine.Screen
local Rect = UnityEngine.Rect
local math = math

local _tools = { }

--[Comment]
--设置UICamera的事件遮罩层
--根据 layer 层名称或者 layer 层
function _tools.SetUICameraEventMask(e, ls)
    if ls ~= nil then
        local len = #ls
        if len > 0 then
            local l = 0
            for i = 1, len do l = bit.bor(l, bit.lshift(1, Mathf.Clamp(isNumber(ls[i]) and ls[i] or CS.NameToLayer(ls[i]), 0, 31))) end
            len = UICamera.eventHandler.eventReceiverMask.value
            if e then
                UICamera.eventHandler.eventReceiverMask.value = bit.bor(len, l)
            else
                UICamera.eventHandler.eventReceiverMask.value = bit.band(len, bit.bnot(l))
            end
        end
    end
end

--[[
--//*****************************************************************

local FillPlace = {
    NotInit = 0,
    None = 1,
    Horizontal = 2,
    Vertical = 3,
}
local _screen = nil
local _screenUtx = nil
local _place = FillPlace.NotInit
local _zoom = 1

--[Comment]
--屏幕边框填充方位
local function Place()
    if _place == FillPlace.NotInit then
        local m = math.modf(100000 * SCREEN.WIDTH / SCREEN.HEIGHT)
        local s = math.modf(100000 * Screen.width / Screen.height)
        if m > s then
            --垂直填充上下
            _place = FillPlace.Vertical
            _zoom = Screen.width / SCREEN.WIDTH
        elseif m < s then
            --水平填充左右
            _place = FillPlace.Horizontal
            _zoom = Screen.height / SCREEN.HEIGHT
        else
            --不填充
            _place = FillPlace.None
            _zoom = Screen.height / SCREEN.HEIGHT
        end
    end
    return _place
end

--[Comment]
--游戏显示的屏幕像素矩形
local function ScreenRect()
    if Place() == FillPlace.Horizontal then
        local w = SCREEN.WIDTH * _zoom / Camera.main.pixelWidth
        return Rect((1 - w) * 0.5, 0, w, 1)
    else
        local h = SCREEN.HEIGHT * _zoom / Camera.main.pixelHeight
        return Rect(0,(1 - h) * 0.5, 1, h)
    end
end

function _tools.CaptureScrennTexture(utx,cam,setWH)
    if utx then
        if not _screen then
            _screen = RenderTexture(Screen.width, Screen.height, 0)
        end

        cam.targetTexture = _screen
        cam:Render()
        cam.targetTexture = nil

        _screenUtx = utx
        utx.mainTexture = _screen
        utx.uvRect = ScreenRect()
        if setWH then
            utx.width = SCREEN.WIDTH
            utx.height = SCREEN.HEIGHT
        end
    end
end

function _tools.ReleaseScrennTexture(utx)
    if _screen and (not _screenUtx or utx == _screenUtx) then
        _screenUtx = nil
        _screen:DiscardContents()
        _screen:Release()
        Destroy(_screen)
        _screen = nil
    end
end

--//******************************************************************************
]]

--[Comment]
--创建一个精灵按钮
local function GenerateButton(go, at, sp, lab)
    at = at or AM.mainAtlas
    sp = sp or ""
    lab = lab or ""

    go = go:AddWidget(typeof(UISprite), "btn_sprite")
    go.depth = NGUITools.CalculateNextDepth(go.cachedGameObject)
    go.atlas = at
    go.spriteName = sp
    go:MakePixelPerfect()
    if go.atlas ~= nil then NGUITools.AddWidgetCollider(go.cachedGameObject, true) end
    at = go.cachedGameObject:AddCmp(typeof(UIButton))
    at.hover = Color.white
    at.pressed = Color.gray
    at.disabledColor = Color.gray
    at.duration = 0.05
    at = go.cachedGameObject:AddCmp(typeof(UIButtonScale))
    at.hover = Vector3.one
    at.pressed = Vector3(0.95, 0.95, 0.95)
    at.duration = 0.05
    if lab ~= nil then
        at = go.cachedGameObject:AddWidget(typeof(UILabel))
        at.applyGradient = false
        at.trueTypeFont = AM.mainFont
        at.fontSize = 32
        at.depth = go.depth + 10
        at:MakePixelPerfect()
        at.text = lab
    end
    return go
end
--[Comment]
--创建一个精灵按钮
_tools.GenerateButton = GenerateButton

--[Comment]
--创建一个用于显示动画的Panel
local function CreatAnimPanel(go, depth, addCol, life)
    go = go:AddChild("AnimPanel")
    go:AddCmp(typeof(UIPanel)).depth = depth or 200
    if addCol then
        addCol = go:AddCmp(typeof(UE.BoxCollider))
        addCol.size = Vector3(SCREEN.MAX_WIDTH, SCREEN.MAX_HEIGHT)
    end
    Destroy(go, life or 5)
    return go
end
--[Comment]
--创建一个用于显示动画的Panel
_tools.CreatAnimPanel = CreatAnimPanel

--[Comment]
--显示使用道具动画，类型1
local function CoShowUseProps(go)
    go = go:AddChild(AM.LoadPrefab("ef_use_props"), "ef_use_props")
    if go then
        go:SetActive(false)
        Destroy(go, 2)
        coroutine.step()
        coroutine.step()
        go:SetActive(true)
    end
end
--[Comment]
--显示使用道具动画，类型1
function _tools.ShowUseProps(go) if go then coroutine.start(CoShowUseProps, go) end end

local function CoOnLearn(dat, ig, f)
    if dat.sn > 0 and ig:alive() then
        local typ = objt(dat)
        if typ == DB_Arm then
            typ = "so"
        elseif typ == DB_Lnp then
            typ = "lu"
        else
            return
        end

        local pnl = CreatAnimPanel(Scene.current, 200, true, 10)
        local mask = pnl:AddWidget(typeof(UISprite), "mask")
        mask.atlas = AM.mainAtlas
        mask.spriteName = "mask"
        mask.depth = -1
        mask.type = UIBasicSprite.Type.Sliced
        mask.width, mask.height = SCREEN.MAX_WIDTH, SCREEN.MAX_HEIGHT
        mask.color = Color(0, 0, 0, 0)

        local go = ig.go
        local col = go:GetCmp(typeof(UE.Collider))
        if col then col.enabled = false end
        local trans = go.transform
        local parent = trans.parent
        trans.parent = pnl.transform
        local pos = trans.localPosition
        local utex = ig.imgl.uiTexture

        local sp = pnl:AddWidget(typeof(UISprite), "anim")
        AtlasLoader.LoadAsync(sp, "anim_legacy", false, true)
        sp.spriteName = "get_" .. typ .. "_01"
        sp.depth = utex.depth + 1

        local uspa = sp:AddCmp(typeof(UISpriteAnimation))
        uspa.namePrefix = "get_" .. typ .. "_"
        uspa.pixelPerfect = false
        uspa.framesPerSecond = 12

        sp:SetActive(false)

        local spark = pnl:AddChild(AM.LoadPrefab("ef_goods_sparks"), "spark")
        if spark then spark:SetActive(false) end

        coroutine.step()
        local ws = go:GetCmpsInChilds(typeof(UIWidget))
        for i = 0, ws.Length - 1 do ws[i]:ParentHasChanged() end
        coroutine.step()

        TweenAlpha.Begin(mask.cachedGameObject, 0.3, 0.8)
        EF.MoveTo(go, "position", Vector3.zero, "time", 0.7, "islocal", true, "easetype", iTween.EaseType.easeOutExpo)
        EF.ScaleTo(go, "scale", Vector3.one * 1.5, "time", 1.5, "islocal", true, "easetype", iTween.EaseType.easeOutElastic)

        coroutine.wait(0.71)

        sp.width = utex.width * 1.5
        sp.height = utex.height * 1.5
        sp:SetActive(true)
        ig.Available = true

        coroutine.step()
        ig.imgl:Load(typ == "so" and ResName.SoldierIcon(dat.sn) or ResName.LineupIcon(dat.sn))

        coroutine.wait(1)
        local tm = Time.time + 3
        (pnl.luaBtn or pnl:AddCmp(typeof(LuaButton))):SetClick( function() tm = 0 end)
        while tm > Time.time do coroutine.step() end

        if spark then spark:SetActive(true) end
        sp:SetActive(false)
        ig:Init(dat, true, false, true, typ == "so" and 1 or nil)

        coroutine.wait(0.5)

        TweenAlpha.Begin(mask.cachedGameObject, 0.3, 0)
        EF.ScaleTo(go, "scale", Vector3.one, "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInOutSine)
        EF.MoveTo(go, "position", pos, "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInOutSine)

        coroutine.wait(0.35)
        trans.parent = parent
        if col then col.enabled = true end
        coroutine.step()
        ws = go:GetCmpsInChilds(typeof(UIWidget))
        for i = 0, ws.Length - 1 do ws[i]:ParentHasChanged() end
        coroutine.step()
        Destroy(pnl)
        if f then f() end
    end
end
function _tools.OnLearnArm(arm, ig, f) if arm and ig then coroutine.start(CoOnLearn, arm, ig, f) end end
function _tools.OnLearnLnp(lnp, ig, f) if lnp and ig then coroutine.start(CoOnLearn, lnp, ig, f) end end

local function CoShowSkillUL(dat, pos, isC)
    if dat.sn > 0 then
        local go = Scene.current:AddChild(AM.LoadPrefab("ef_skill_ul"), "ef_skill_ul")
        go.transform.localPosition = pos
        local utx = go:GetCmpInChilds(typeof(UITexture))
        utx:LoadTexAsync(objt(dat) == DB_SKT and ResName.SkillIconT(dat.sn) or ResName.SkillIconC(dat.sn))
        utx:GetCmpInChilds(typeof(UILabel), false).text = dat:getName()
        coroutine.step()
        coroutine.step()
        go:SetActive(true)
        --       coroutine.wait(2.5)
    end
end
function _tools.ShowSkillUL(dat, pos, isC) if dat and pos then coroutine.start(CoShowSkillUL, dat, pos, isC) end end

local function WidgetsAddDepth(go, dp)
    if go and dp ~= 0 then
        local tmp = go:GetCmpsInChilds(typeof(UIWidget))
        for i = 0, tmp.length - 1 do tmp[i].depth = tmp[i].depth + dp end
    end
end
--[Comment]
--给指定对象及其子级的所有UIWidget偏移深度
_tools.WidgetsAddDepth = WidgetsAddDepth


Tools = _tools