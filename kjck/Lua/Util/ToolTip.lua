ToolTip={}

local Time = Time

local _body
--PropTip
local _pt
local _ptTtl
local _ptIntro
local _ptBg
local _ptSep
local _pTm
--ToolTip
local _tt
local _ttTxt
local _tTm
--ItemTip
local _it
local _itRt
--GameTip
local _gt
local _gtTxt
local _gTm
--Mask
local _mask
local _mm
local _mTm

--创建对象
function ToolTip.Create()
    if tolua.isnull(_body) then
        GM.instance:AddChild(AM.LoadPrefab("ToolTip"))
    end
end

function ToolTip.OnLoad(b)
    _body = b
    
    b:BindFunction("OnClickPorpBg")
    b:BindFunction("ClickMask")

    local arr = b.gos
    _it = arr[0]
    _itRt = arr[1]
    _gt = arr[2]
    _mask = arr[3]

    _pt = b.cmps[0]

    _tt = b.widgets[0]

    _ttTxt = _tt:ChildWidget("lbl")

    _ptTtl = _pt:ChildWidget("lbl_t")
    _ptIntro = _pt:ChildWidget("lbl_i")
    _ptBg = _pt:ChildWidget("bg")
    _ptSep = _pt:ChildWidget("sep")

    _gtTxt = _gt:ChildWidget("lbl")
end

local function OnMask()
    if _mm then
        if _mm.tm > (_mm.real and Time.realtimeSinceStartup or Time.time) then return end
        _mm = _mm.nxt
        while _mm do
            if _mm.tm > (_mask.real and Time.realtimeSinceStartup or Time.time) then return end
            _mm = _mm.nxt
        end
    end
    _mask:SetActive(false)
    _mTm:Stop()
end
--[Comment]
--屏蔽交互事件一段时间
function ToolTip.Mask(tm, real)
    if tm and tm > 0 then
        local m = { tm = (real and Time.realtimeSinceStartup or Time.time) + tm, real = real }
        m.nxt = _mm
        _mm = m
        if not _mTm then
            _mTm = FrameTimer.New(OnMask, 1, -1)
        elseif _mTm.running then
            return
        end
        _mTm:Start()
        _mask:SetActive(true)
        return m
    end
end

--[Comment]
--显示弹出Item提示
function ToolTip.ShowPopTip(str)
    if str == nil or str == "" then return end
    local it = _itRt:AddChild(_it)
    it:ChildWidget("lbl").text = str
    it:SetActive(true)
end
--[Comment]
--清除所有弹出的Item提示
function ToolTip.ClearPopTip()
    _itRt:DestroyChilds()
end

local function OnPropTipHide()
    EF.FadeOut(_pt, 1)
end
--[Comment]
--显示道具提示(若str为nil则仅显示ttl)
function ToolTip.ShowPropTip(ttl, str)
    _pt:SetActive(true)
    _ptTtl.text = ttl or ""
    if str and str ~= "" then
        _ptSep:SetActive(true)
        _ptIntro.text = str
        _ptBg.width = 300;
        _ptBg.height = _ptIntro.printedSize.y + 60;
    else
        local ts = _ptTtl.printedSize
        _ptSep:SetActive(false)
        _ptIntro.text = ""
        _ptBg.width = ts.x + 24;
        _ptBg.height = ts.y + 12;
    end

    EF.FadeIn(_pt, 0.2)

    if _pTm then
        _pTm:Reset(OnPropTipHide, 3, 1, true)
    else
        _pTm = Timer.New(OnPropTipHide, 3, 1, true)
    end
    if not _pTm.running then _pTm:Start() end
end

local function OnToolTipHide()
    EF.FadeOut(_tt, 1)
end
--[Comment]
--在鼠标点击位置显示工具提示
function ToolTip.ShowToolTip(str)
    if str == nil or str == "" then return end

    _tt:SetActive(true)
    _ttTxt.text = str

    local ps = _ttTxt.printedSize * 0.75
    local w = ps.x + 36;
    local h = ps.y + 16 + 10;
    _tt.width = w;
    _tt.height = h;

    local pos = _body.mousePos
    local min, max = _body:GetScreen()

    if w >= max.x - min.x then
        pos.x = min.x
    elseif pos.x + w > max.x then
        if pos.x - w < min.x then
            pos.x = pos.x - w
        else
            pos.x = max.x - w
        end
    end

    if h >= max.y - min.y then
        pos.y = max.y
    elseif pos.y - h < min.y then
        if pos.y + h < max.y then
            pos.y = pos.y + h
        else
            pos.y = min.y + h
        end
    end
    
    _tt.cachedTransform.localPosition = pos

    EF.FadeIn(_tt, 0.2)

    if _tTm then
        _tTm:Reset(OnToolTipHide, 3, 1, true)
    else
        _tTm = Timer.New(OnToolTipHide, 3, 1, true)
    end
    if not _tTm.running then _tTm:Start() end
end
--[Comment]
--隐藏工具提示
function ToolTip.HideToolTip()
    if _tt and _tt.activeSelf then
        if _tTm and _tTm.running then _tTm:Stop() end
        EF.FadeOut(_tt, 1)
    end
end

local function SetGameTip()
    if Scene.isEntry or Scene.isTransition then
        local gametip = DB.gameTip
        local str = gametip[math.random(1, #gametip)]
        if str == nil or str == "" then return end
        _gtTxt.text = str
        return true
    end
    ToolTip.ShowGameTip(false)
    return false
end
--[Comment]
--显示游戏提示
function ToolTip.ShowGameTip(show)
    if show then
        if _gt.activeSelf and _gTm and _gTm.running then return end
        _gt:SetActive(true)
        if not SetGameTip() then return end
        if _gTm then
            _gTm:Reset(SetGameTip, 5, -1, true)
        else
            _gTm = Timer.New(SetGameTip, 5, -1, true)
        end
        if not _gTm.running then _gTm:Start() end
    else
        if _gTm and _gTm.running then _gTm:Stop() end
        _gt:SetActive(false)
        _gtTxt.text = ""
    end
end

function ToolTip.OnClickPorpBg()
    if _pTm and _pTm.running then _pTm:Stop() end
    EF.FadeOut(_pt, 0.3)
end

function ToolTip.ClickMask()
    ToolTip.ShowToolTip("啊实打实大胜对手")
end