local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil

local _dbTurn = nil
local _items = nil
local _dat = nil
local _angles = nil

local _time = 0
local _dt = 0

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, {k=WinBackground.MASK})

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "OnEnter",
    "OnExit",
    "ClickOne",
    "ClickTen",
    "ClickItemGoods",
    "ClickClose",
    "Refresh",
    "Help",
    "OnUnLoad"
    )

    --[Comment]
    --根据档次得到角度
    _angles = {
        [1] = function() return math.random(30, 60) end,
        [2] = function() return math.random(300, 330) end,
        [3] = function() return math.random(120, 150) end,
        [4] = function() return math.random(210, 240) end,
        [5] = function() return math.random(165, 195) end,
        [6] = function() return math.random(345, 375) end,
        [7] = function() return math.random(75, 109) end,
        [8] = function() return math.random(255, 285) end,
        def = function() return 0 end
    }

    _dbTurn = DB.Get(LuaRes.Turntable)
end

--[Comment]
--改变按钮状态
local function ChangeButton()
    if _dat.turnCoin < 1 then
        _ref.btnOne.isEnabled = false
        _ref.btnTen.isEnabled = false
    elseif _dat.turnCoin >= 1 and _dat.turnCoin < 10 then
        _ref.btnOne.isEnabled = true
        _ref.btnTen.isEnabled = false
    else
        _ref.btnOne.isEnabled = true
        _ref.btnTen.isEnabled = true
    end
end

local function BuildItems()
    _ref.labPrice.text = tostring(_dat.price)
    _ref.labTurnCoin.text = tostring(_dat.turnCoin)
    ChangeButton()
    _time = _dat.cdTime
    _dt = 0
    _ref.labTime.text = TimeClock.TimeToSmart(_dat.cdTime)
    local goods = _dat.goods
    if goods then
        _items = { }
        table.print("goo",goods)
        for i = 1, #goods, 2 do
            local idx =(i + 1) / 2
            local sn = goods[i]
            local count = goods[i + 1]
            _items[idx] = ItemGoods(_ref.rewards[idx]:AddChild(_ref.item_goodshsb, string.format("item_%02d", idx)))
            _items[idx]:Init(_dbTurn[sn].rws[1])
            _items[idx].sn = sn
            _items[idx].go.luaBtn.luaContainer = _body
            _items[idx].go.transform.localScale = Vector3(0.8, 0.8, 0.8)
            if count <= 0 then
                _items[idx].imgl.uiTexture.color = ColorStyle.HSB_Disabled
                local sp = _items[idx].go:AddWidget(typeof(UISprite), "sp_sellout")
                sp.atlas = AM.mainAtlas
                sp.spriteName = "sp_turntable_gou"
                sp.cachedTransform.localPosition = Vector3(0, 0, 0)
                sp.width = 32
                sp.height = 34
                sp.depth = 13
            else
                _items[idx].imgl.uiTexture.color = ColorStyle.HSB_Normal
            end
        end
    end
end

function _w.OnInit()
    _ref.mask:SetActive(false)
    _ref.panelTip:SetActive(false)
    SVR.Turntable("inf", function(t)
        if t.success then
            --stab.S_Turntable
            _dat = SVR.datCache
            BuildItems()
        end
    end )
end

--region Update
local function Update()
    if _time < 0 then
        return
    end
    if _time > 0 then
        _dt = _dt + Time.unscaledDeltaTime
        if _dt > 1 then
            local d = math.modf(_dt)
            _dt = _dt - d
            _time = math.max(_time - d, 0)
            _ref.labTime.text = TimeClock.TimeToSmart(_time)
        end
    end
end
local _update = UpdateBeat:CreateListener(Update)
function _w.OnEnter()
    UpdateBeat:AddListener(_update)
end
function _w.OnExit()
    UpdateBeat:RemoveListener(_update)
end
--endregion

--[Comment]
--转盘旋转
local function Round(level)
    local z = _ref.roundTurntable.transform.localEulerAngles.z
    _ref.roundTurntable:ResetToBeginning()
    _ref.roundTurntable.from = Vector3(0, 0, 720 + z)
    local t = _angles[level] and _angles[level]() or _angles.def()
    _ref.roundTurntable.to = Vector3(0, 0, t)
    _ref.roundTurntable:PlayForward()
end

local function UpdateInfo()
    _ref.labTurnCoin.text = tostring(_dat.turnCoin)
    local w = Win.GetOpenWin("WinWar")
    if w then
        w.UpdateInfo()
    end
    ChangeButton()
    Invoke( function()
        _ref.mask:SetActive(false)
        if _items then
            local goods = _dat.goods
            for i = 1, #goods, 2 do
                local idx =(i + 1) / 2
                local sn = goods[i]
                local count = goods[i + 1]
                if count <= 0 then
                    _items[idx].imgl.uiTexture.color = ColorStyle.HSB_Disabled
                    local sp = _items[idx].go:AddWidget(typeof(UISprite), "sp_sellout")
                    sp.atlas = AM.mainAtlas
                    sp.spriteName = "sp_turntable_gou"
                    sp.cachedTransform.localPosition = Vector3.zero
                    sp.width = 32
                    sp.height = 34
                    sp.depth = 13
                else
                    _items[idx].imgl.uiTexture.color = ColorStyle.HSB_Normal
                end
            end
            PopRewardShow.Show(_dat.rws)
        else
            BuildItems()
        end
    end , 2)
end

function _w.ClickClose()
    _ref.tip:SetActive(false)
    _ref.items:DesAllChild()
    _ref.labName.text = ""
    _ref.labValue.text = ""
    _ref.labPr.text = ""
    _ref.labInfo.text = ""
end

local function ShowInfo(sn)
    local ig = ItemGoods(_ref.items:AddChild(_ref.item_goods, "item"))
    local t = _dbTurn[sn].rws[1]
    ig:Init(t)
    ig.go.luaBtn.luaContainer = _body
    _ref.labName.text = ig.name.text
    _ref.labPr.text = L("概率:") .. _dbTurn[sn].pro .. "%"

    local dat = ig.dat
    if dat.GetAttStr then
        _ref.labValue.text = L("属性:") .. dat:GetAttStr()
    end
    if dat.AttIntro then
        _ref.labValue.text = L("属性:") .. dat:AttIntro()
    end
    _ref.labInfo.text = dat.i or ""
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if not btn then
        return
    end
    _ref.panelTip:SetActive(true)
    ShowInfo(btn.sn)
end

--[Comment]
--抽一次
function _w.ClickOne()
    SVR.Turntable("get|1", function(t)
        if t.success then
            _ref.mask:SetActive(true)
            --stab.S_Turntable
            _dat = SVR.datCache
            Round(_dat.lv)
            UpdateInfo()
        end
    end )
end

--[Comment]
--抽十次
function _w.ClickTen()
    SVR.Turntable("get|10", function(t)
        if t.success then
            _ref.mask:SetActive(true)
            --stab.S_Turntable
            _dat = SVR.datCache
            Round(_dat.lv)
            UpdateInfo()
        end
    end )
end

local function Dispose()
    for i, v in ipairs(_ref.rewards) do
        v:DesAllChild()
    end
    _items = nil
end

--[Comment]
--刷新
function _w.Refresh()
    SVR.Turntable("ref", function(t)
        if t.success then
            --stab.S_Turntable
            _dat = SVR.datCache
            Dispose()
            BuildItems()
        end
    end )
end

function _w.Help()
    Win.Open("PopRule", DB_Rule.Turntable)
end

function _w.OnDispose()
    _ref.mask:SetActive(false)
    _ref.panelTip:SetActive(false)
    Dispose()
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dbTurn = nil
        _items = nil
        _dat = nil
        _angles = nil
        --package.loaded["Game.PopTurntable"] = nil
    end
end

--[Comment]
--战役转盘
PopTurntable = _w