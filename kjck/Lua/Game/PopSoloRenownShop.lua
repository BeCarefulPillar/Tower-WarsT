require "Game/ItemRareShop"
local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil

local _items = nil
local _data = nil
local _grid = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { n = L("声望商城") })

    _grid = {
        UIGrid = _ref.grid,
        UIScrollView = _ref.grid:GetCmp(typeof(UIScrollView))
    }
    _ref.grid = nil
end

local function BuildItems()
    _ref.lbl_renownValue.text = tostring(_data.soloRenown)

    _items = _items or { }
    for i, v in ipairs(_data.gs) do
        if not _items[i] then
            _items[i] = ItemRareShop(_grid.UIGrid:AddChild(_ref.item_shop, "item_" .. i))
        end
        _items[i].go:SetActive(true)
        _items[i]:InitSoloRenown(v)
        _items[i].remain.text = string.format(L("剩余%d次"), v.remainBuyTimes)
        _items[i].btnBuy.param = i
        _items[i].wgt.alpha = 0
        TweenAlpha.Begin(_items[i].go, 0.2, 1,(i - 1) * 0.1)
    end
    _ref.emptyTip:SetActive(#_data.gs == 0)
    _grid.UIGrid.repositionNow = true
    _grid.UIScrollView:ConstraintPivot(UIWidget.Pivot.Top, false)
end

function _w.OnInit()
    _ref.labels[1].text = L("竞技场")
    _ref.labels[2].text = L("商品已售罄")
    _ref.sp_money.spriteName = "sp_renown"

    SVR.GetSoloRenownShop( function(t)
        if t.success then
            --stab.S_SoloRenownShopInfo
            _data = SVR.datCache
            BuildItems()
        end
    end )
end

--[Comment]
--更新剩余购买数量
local function UpdateItemInfo()
    _ref.lbl_renownValue.text = tostring(_data.soloRenown)
    for i, v in ipairs(_data.gs) do
        _items[i].remain.text = string.format(L("剩余%d次"), v.remainBuyTimes)
    end
end

--[Comment]
--购买界面点击购买后的回调（物品id，购买次数）
function _w.BuyCallback(id, num)
    SVR.BuySoloRenownShop(id, num, function(t)
        if t.success then
            --stab.S_SoloRenownShopInfo
            _data = SVR.datCache
            PopRewardShow.Show(_data.rws)
            UpdateItemInfo()
        end
    end )
end

function _w.ClickGoods(i)
    if _data.gs[i].remainBuyTimes > 0 then
        Win.Open("PopBuyRareProps").OnInitSoloRenown(_data.gs[i])
    else
        ToolTip.ShowPopTip(L("商品已售罄"))
    end
end

local function Despawn(its)
    if its then
        for i, v in ipairs(its) do
            v.go:SetActive(false)
        end
    end
end

function _w.OnDispose()
    Despawn(_items)
    _items = nil
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _items = nil
        _data = nil
        _grid = nil
    end
end

--[Comment]
--竞技场中的声望商城
PopSoloRenownShop = _w