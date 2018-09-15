local ipairs = ipairs
local pairs = pairs

local _w = { }
AnnoStyleLua_103 = _w

local _body = nil
local _ref = nil
local _dat = nil
local _act = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    c:BindFunction("OnInit", "OnUnLoad")
end
local function RefreshInfo()
    _ref.buyQty.text = string.format(L("已有[FFB16B][b]%d[/b][-]人购买"), _dat.val)
    local f = _dat.ext[1] == 1
    _ref.buy.isEnabled = not f
    _ref.buy.text = f and L("已购买") or L("购 买")

    for i, v in ipairs(_act.r) do
        if isnull(v.go) then
            v.go = _ref.grid:AddChild(_ref.item, string.format("item_%02d", i))
            v.btn = v.go:ChildBtn("btn_get")
            v.ig = ItemGoods(v.go:Child("item_goods").gameObject)
            v.qty = v.go:ChildWidget("lab_buyQty")
        end
        v.go:SetActive(true)
        v.btn.param = v.va[1]
        if v.rw then
            v.ig:Init(v.rw[1])
        end
        f = _dat.val >= v.va[2]
        if f then
            v.qty.text = string.format(L("购买人数 [00ff00]%s[-]人"), v.va[2])
        else
            v.qty.text = string.format(L("购买人数 [ff0000]%s[-]人"), v.va[2])
        end
        if table.contains(_dat.record, v.va[1]) then
            v.btn.isEnabled = false
            v.btn.text = L("已领取")
        else
            v.btn.isEnabled = f
            v.btn.text = L("领 取")
        end
    end
    _ref.grid.repositionNow = true
end
local function PriRefresh()
    SVR.AffairOption("inf|" .. _act.sn, function(t)
        if t.success then
            _dat = SVR.datCache
            RefreshInfo()
            WinLuaAffair.RefreshInfo(_dat.tips)
        end
    end )
end
function _w.OnInit()
    _act = WinLuaAffair.getDat(_body.data)
    _ref.title:LoadTexAsync(_act.title)
    PriRefresh()
end
function _w.ClickItem(btn, sn)
    if sn <= 0 then
        return
    end
    SVR.GetFundReward(sn, function(t)
        if t.success then
            table.insert(_dat.record, sn)
            btn.isEnabled = false
            btn.text = L("已领取")
            WinLuaAffair.RefreshInfo()
        end
    end )
end
function _w.ClickBuy()
    local btn = nil
    local dat = WinLuaAffair.Dat()
    for i,v in pairs(dat) do
        if v.sn==32 then
            btn = i
        end
    end
    if btn then
        WinLuaAffair.OnTabClicked(btn)
    end
end
function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end
function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
        for i, v in pairs(_act.r) do
            v.go = nil
            v.qty = nil
            v.ig = nil
            v.btn = nil
        end
        _act = nil
    end
end