local _w = { }
--[Comment]
--体力
PopVIT = _w

local _body = nil
local _ref = nil

local _items = nil
local _selected = nil
local _price = nil
local _tm = nil
local _timeClock = nil
local _dt = 0

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK, exitfc = _w.ClickClose })
    _timeClock = TimeClock()
end

local function Active()
    return _body.gameObject.activeSelf
end

function _w.OnSpringValueUpdate(sv,a)
    sv = EF.SpringValue(sv,"Value")
    _ref.infos[1].text = math.modf(user.MaxVit * sv) .. "/" .. user.MaxVit
    _ref.proVIT.value = sv
end

function _w.OnSpringValueFinished(sv)
    _ref.infos[1].text = user.vit .. "/" .. user.MaxVit
    _ref.proVIT.value = EF.SpringValue(sv,"to")
end

--[Comment]
--更新数据
local function UpdateInfo()
    _price = user.vitPrice
    _ref.infos[2].text = tostring(_price)
    if Active() then
        EF.SpringValue(_body, _ref.proVIT.value, user.vit / user.MaxVit, 13,
        _w.OnSpringValueUpdate, _w.OnSpringValueFinished)
    else
        _ref.infos[1].text = user.vit .. "/" .. user.MaxVit
        _ref.proVIT.value = user.vit / user.MaxVit
    end
    local counts = math.max(0, user.vitTotal - user.vitCount)
    _ref.infos[3].text = counts .. "/" .. user.vitTotal
    _timeClock.time = _tm
    if _tm > 0 and user.vit < user.MaxVit then
        _ref.vitTime:SetActive(true)
    else
        _ref.vitTime:SetActive(true)
        _ref.vitTime.text = L("已回满")
    end
end

--[Comment]
--从服务器等到数据
local function GetInfo()
    SVR.AddVIT("inf", function(t)
        if t.success then
            --stab.S_AddVIT
            local res = SVR.datCache
            _tm = res.tm + 3
            UpdateInfo()
        end
    end )
end

function _w.OnInit()
print("oninit")
    GetInfo()
    local props = user.GetProps( function(p)
        return p.code == "vit"
    end )
    _items = { }
    for i, v in ipairs(props) do
        local ig = ItemGoods(_ref.grid:AddChild(_ref.item_goods, "goods_" .. v.sn))
        _items[i] = ig
        ig:Init(v)
        ig.go.luaBtn.luaContainer = _body
        local desc = ig.go:AddWidget(typeof(UILabel), "desc")
        desc.trueTypeFont = AM.mainFont
        desc.fontSize = 20
        desc.overflowMethod = UILabel.Overflow.ResizeFreely
        desc.text = L("体力[00FF00]+") .. v.val
        desc.transform.localPosition = Vector3(0, -71, 0)
    end
    _ref.grid.repositionNow = true
    if #props > 0 then
        _selected = _items[1]
        _selected.Selected = true
    end
end

local function Update()
    if _dt<Time.realtimeSinceStartup then
        _dt=Time.realtimeSinceStartup+1
        if _timeClock.time > 0 and user.vit < user.MaxVit then
            _ref.vitTime.text = TimeClock.TimeToString(_timeClock.time)
            if _timeClock.time % 30 == 0 then
                GetInfo()
            end
        end
    end
end

local _update = UpdateBeat:CreateListener(Update)

function _w.OnEnter()
    UpdateBeat:AddListener(_update)
    _body.transform.localPosition = Vector3(0, 500, 0)
    EF.MoveTo(_body, "y", 0, "islocal", true, "time",
    0.44, "easetype", iTween.EaseType.easeOutBack)
end

function _w.ClickClose()
    UpdateBeat:RemoveListener(_update)
    if Active() then
        EF.MoveTo(_body, "y", 500, "islocal", true, "time", 0.3,
        "easetype", iTween.EaseType.easeInCirc)
        Invoke( function()
            _body:Exit()
        end , 0.3)
    end
end

--[Comment]
--购买体力
function _w.ClickUseGold()
    local old = user.vit
    SVR.AddVIT("buy", function(t)
        if t.success then
            local res = SVR.datCache
            _tm = res.tm + 3
            --TdAnalytics.OnPurchase("购买体力", 1, price);
            ToolTip.ShowPopTip(string.format(L("增加[00FF00]%d[-]点体力"), math.max(0, res.vit - old)))
            UpdateInfo()
            user.changed = true
        end
    end )
end

--[Comment]
--使用道具
function _w.ClickUseProps()
    if _selected and objt(_selected.dat) == PY_Props then
        local props = _selected.dat
        if props.sn > 0 then
            local old = user.vit
            PopUseProps.Use(props, 0, function(t)
                if t.success then
                    SVR.AddVIT("inf", function(t)
                        if t.success then
                            ToolTip.ShowPopTip(string.format(L("增加[00FF00]%d[-]点体力"), math.max(0, user.vit - old)))
                            local a = user.vit - old
                            if user.vit < user.MaxVit then
                                _tm = _tm - a * 300
                            end
                            old = user.vit
                            UpdateInfo()
                            coroutine.start(Tools.ShowUseProps, _selected.go)
                        end
                    end )
                end
            end )
        end
    end
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        if _selected == btn then
            return
        end
        if _selected then
            _selected.Selected = false
        end
        _selected = btn
        _selected.Selected = true
    end
end

local function DestroyItem(its)
    if its then
        for i, v in ipairs(its) do
            Destroy(v.go)
        end
    end
end

function _w.OnDispose()
    _selected = nil
    DestroyItem(_items)
    _items = nil
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _items = nil
        _selected = nil
        _price = nil
        _tm = nil
        _timeClock = nil
    end
end