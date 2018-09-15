
local isnull = tolua.isnull
local sort = table.sort
local ul = { }
UnLockEffect = ul

local _showObj = nil

local onBack = nil
local onFinished = nil
function ul.SetOnFinished(c) onFinished = c end

local _objCir = nil
local _objGlow = nil
local _objMask = nil
local _objTitle = nil
local _objIntro = nil
local _objSpk = nil
local _labNext = nil

local _source = nil
local _copy = nil
local _copy2 = nil
local _wait = nil

local function Sample()
    if ul.sample == nil then
        local tmp = AM.LoadPrefab("UnLockSample")
        if tmp then
            tmp = tmp.transform
            ul.sample = { 
                tavern = tmp:FindChild("b_tavern"),
                dev = tmp:FindChild("btn_dev"),
                smithy = tmp:FindChild("b_goods"),
                hospital = tmp:FindChild("b_hospital"),
                ass = tmp:FindChild("btn_assistant"),
                seven = tmp:FindChild("btn_seven"),
                home = tmp:FindChild("b_city"),
                fb = tmp:FindChild("btn_history"),
            }
        end
    end
end
if CS.onMainThread() then Sample() else CS.RunOnMainThread(Sample) end

local function OnStartShow()
    coroutine.step()
    local t = 0
    t = Time.realtimeSinceStartup + 7
    while t > Time.realtimeSinceStartup do
        if isnull(_showObj) then coroutine.step()
        else t = Time.realtimeSinceStartup end
    end
    if isnull(_showObj) then
        EF.Alpha(_showObj,  0.3, 1)
        if isnull(_source) then
            EF.MoveTo(_copy, "time", 1, "ignoretimescale", true, "path", tostring(_showObj:GetCmp(iTweenPath).nodes), "easetype", iTween.EaseType.easeOutExpo)
            EF.RotateFrom(_copy, "y", -90, "time", 1.5, "ignoretimescale", true, "islocal", true, "easetype", iTween.EaseType.easeOutBack)
            EF.ColorTo(_copy, "a", 1, "time", 0.3, "ignoretimescale", true)
            t = Time.realtimeSinceStartup + 1.2
            while t > Time.realtimeSinceStartup do coroutine.step() end
            EF.MoveTo(_copy, "time", 0.3, "ignoretimescale", true, "z", 0, "islocal", true, "easetype", iTween.EaseType.easeInExpo)
            t = Time.realtimeSinceStartup + 0.29
            while t > Time.realtimeSinceStartup do coroutine.step() end
        else EF.Alpha(_copy, 0.3, 1)
        end
        _objCir:SetActive(true)
        _objGlow:SetActive(true);
        coroutine.step()
        _objSpk:SetActive(true);
        EF.ColorTo(_objCir, "a", 0, "time", 0.5, "ignoretimescale", true, "delay", 0.2)
        EF.ScaleTo(_objCir, "scale", Vector3(8, 8, 1), "time", 0.7, "ignoretimescale", true, "easetype", iTween.EaseType.easeOutExpo)
        EF.ColorTo(_objGlow, "a", 0, "time", 0.5, "ignoretimescale", true)
        EF.ScaleTo(_objGlow, "scale", Vector3(0.5, 0.5, 1), "time", 1, "ignoretimescale", true, "easetype", iTween.EaseType.easeOutExpo)
        t = Time.realtimeSinceStartup + 0.5
        while t > Time.realtimeSinceStartup do coroutine.step() end
        wait = true
        t = Time.realtimeSinceStartup + 2
        while t > Time.realtimeSinceStartup and wait do coroutine.step() end
        if onBack then
            onBack()
            t = Time.realtimeSinceStartup + 0.32
            while t > Time.realtimeSinceStartup do coroutine.step() end
            EF.Alpha(_objCir, 0.3, 0)
            EF.Alpha(_objGlow, 0.3, 0)
            EF.Alpha(_objMask, 0.3, 0)
            EF.Alpha(_objTitle, 0.3, 0)
            EF.Alpha(_objIntro, 0.3, 0)
            EF.Alpha(_labNext.cachedGameObject, 0.3, 0)
            if isnull(_copy2) then EF.Alpha(_copy2, 0.3, 0) end
            EF.MoveTo(_copy, "position", _source.transform.position, "time", 0.5, "ignoretimescale", true)
            t = Time.realtimeSinceStartup + 0.62
            while t > Time.realtimeSinceStartup do coroutine.step() end
        else
            EF.Alpha(_showObj, 0.3, 0)
            t = Time.realtimeSinceStartup + 0.32
            while t > Time.realtimeSinceStartup do coroutine.step() end
        end
        Dispose()
    end
end

local function StartShow()
    _showObj = Scene.current.gameObject:AddChild(AM.Load("UnlockEffect", typeof(GameObject)), "UnlockEffect")
    local t = _showObj.transform
    _objCir = t:Find("sp_circle").gameObject
    _objGlow = t:Find("glow").gameObject
    _objMask = t:Find("mask").gameObject
    _objTitle = t:Find("Title").gameObject
    _objIntro = t:Find("Intro").gameObject
    _objSpk = t:Find("spark").gameObject
    _labNext = t:Find("next"):GetCmp(typeof(UILabel))
    coroutine.start(OnStartShow)
end

local function Dispose()
    if onFinished then
        local f = onFinished
        f()
    end
    if _showObj then
        Destroy(_showObj)
        _showObj = nil
    end
    _objCir = nil
    _objGlow = nil
    _objMask = nil
    _objTitle = nil
    _objIntro = nil
    _objSpk = nil
    _labNext = nil
    _source = nil
    _copy = nil
    _copy2 = nil
    onBack = nil
    onFinished = nil
    _wait = nil
end

function ul.OnLoad(c)
    c:BindFunction("OnClick")
end

function ul.OnClick()
    wait = false
end

function ul.SetNext(ns, tip)
    if isnull(_showObj) then
        _labNext.text = tip
        if isnull(ns) and ns:GetCmp(typeof(UIRect)) then
            _copy2 = _showObj:AddChild(ns, "copy")
            _copy2:SetActive(true)
            local tmp = _copy2:GetCmpsInChilds(typeof(UIWidget))
            sort(tmp, function (a, b) return a.depth > b.depth end)
            for i = 1, #tmp do tmp[i].depth = i * 5 + 5 end
            if _copy2:GetCmp(typeof(UE.Collider)) then Destroy(_copy2:GetCmp(typeof(UE.Collider))) end
            tmp = NGUIMath.CalculateRelativeWidgetBounds(copy2.transform)
            local s = 60 / Mathf.Min(tmp.size.x, tmp.size.y)
            _copy2.transform.localScale = Vector3(s, s, s)
            _copy2.transform.localPosition = Vector3(470 - tmp.extents.x * s, tmp.extents.y * s - 260, 0)
            _labNext.transform.localPosition = Vector3(460 - tmp.size.x * s, -230, 0)
        end
    end
end
--[Comment]
-- 新功能解锁 
function ul.BeginSource(s, t, i)
    if s and s:GetCmp(typeof(UIWidget)) then
        StartShow()
        s.transform:SetParent(_showObj.transform)
        s:GetCmp(typeof(UIWidget)):ParentHasChanged()
        _source = s
        onBack = nil
        _copy = s
        _objTitle:GetCmp(typeof(UILabel)).text = (t or t == "") and L("新功能开放") or t
        _objIntro:GetCmp(typeof(UILabel)).text = i
    end
end
--[Comment]
-- 按钮类解锁
function ul.Begin(s, t, i, ob)
    ob = ob or nil
    if s and s:GetCmp(typeof(UISprite)) then
        StartShow()
        _sourc = s
        onBack = ob
        _objTitle:GetCmp(typeof(UILabel)).text = (t or t == "") and L("新功能开放") or t
        _objIntro:GetCmp(typeof(UILabel)).text = i
        _copy = _showObj:AddChild(s, "copy")
        local tmp = _copy.transform:Find("tip_tag")
        if tmp then Destroy(tmp.gameObject) end
        _copy:SetActive(true)
        tmp = _copy:GetCmpsInChilds(typeof(UIWidget))
        sort(tmp, function (a, b) return a.depth > b.depth end)
        for i = 1, #tmp do tmp[i].depth = i * 5 + 5 end
        if _copy2:GetCmp(typeof(UE.Collider)) then Destroy(_copy2:GetCmp(typeof(UE.Collider))) end
    end
end
--[Comment]
--  建筑类开放
function ul.BeginBuilding(s, t, i)
    if s and s:GetCmp(typeof(UIRect)) then
        StartShow()
        _sourc = nil
        onBack = nil
        _objTitle:GetCmp(typeof(UILabel)).text = (t or t == "") and L("新功能开放") or t
        _objIntro:GetCmp(typeof(UILabel)).text = i
        _copy = _showObj:AddChild(s, "copy")
        _copy:SetActive(true)
        local tmp = _copy:GetCmpsInChilds(typeof(UIWidget))
        sort(tmp, function (a, b) return a.depth > b.depth end)
        for i = 1, #tmp do tmp[i].depth = i * 5 + 5 end
        if _copy2:GetCmp(typeof(UE.Collider)) then Destroy(_copy2:GetCmp(typeof(UE.Collider))) end
    end
end
--[Comment]
--  武将位解锁专用
function ul.BenginHeroPos()
    StartShow()
    _sourc = nil
    onBack = nil
    _objTitle:GetCmp(typeof(UILabel)).text = L("新武将位解锁")
    _objIntro:GetCmp(typeof(UILabel)).text = L("带领更多武将征战天下")
    local tmp = _showObj:AddWidget(typeof(UITexture), "hero")
    tmp:LoadTexAsync("tex_hero_pos", false)
    tmp.width, tmp.height, tmp.depth = 127, 156, 5
    _sourc = tmp.cachedGameObject
    _copy = _sourc
end
