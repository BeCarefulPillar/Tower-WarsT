local _w = { }
--[Comment]
--珍品馆购买界面
PopBuyRareProps = _w

local _body = nil
local _ref = nil

local _ig = nil
local _type = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
    _type = -1
end

--[Comment]
--0=珍宝阁 1=联盟商城 2=军功商城
function _w.OnInitRmbShop(data, idx, view)
    view = view or 0
    _type = view
    local info = RW(data.rw)
    _ref.propName.text = info:getName()
    _ref.propInfo.text = info.i
    _ig = ItemGoods(_ref.prop:AddChild(_ref.item_good, "item_good"))
    _ig:Init(data.rw)
    _ig:HideName()
    _ig.go.luaBtn.luaContainer = _body
    if RW.IsPiece(data.rw) then
        _ref.propName.text = info.nm .. L("(碎片)")
    end
    if data.gold > 0 then
        _ref.spPrice.spriteName = "sp_gold"
        _ref.labPrice.text = tostring(data.gold)
    elseif data.soul > 0 then
        _ref.spPrice.spriteName =
        _type == 0 and "sp_soul" or _type == 1 and "sp_acash" or "sp_amerit"
        _ref.labPrice.text = tostring(data.soul)
    else
        _ref.spPrice.spriteName = "sp_diamond"
        _ref.labPrice.text = tostring(data.rmb)
    end
    _ref.propTip.text = L("购买") .. "[ff0000]" .. _ref.propName.text ..(_ig.dat[3] > 0 and("*" .. _ig.dat[3]) or "") .. "?"
    _ref.propName.text = ColorStyle.Rare(_ref.propName.text, info.rare)
    _ref.btnBuy:SetClick(_w.ClickBuy, idx)
end

function _w.OnInitCountryShop(data)
    local info = RW(data.rw)
    _ref.propName.text = info.nm
    _ref.propInfo.text = info.i

    _ig = ItemGoods(_ref.prop:AddChild(_ref.item_good, "item_good"))
    _ig:Init(data.rw)
    _ig:HideName()
    _ig.go.luaBtn.luaContainer = _body
    if _ig.IsPiece then
        _ref.propName.text = info.nm .. L("(碎片)")
    end

    if data.gold > 0 then
        _ref.spPrice.spriteName = "sp_gold"
        _ref.labPrice.text = tostring(data.gold)
    elseif data.rmb > 0 then
        _ref.spPrice.spriteName = "sp_diamond"
        _ref.labPrice.text = tostring(data.rmb)
    elseif data.token > 0 then
        _ref.spPrice.spriteName = "sp_token"
        _ref.labPrice.text = tostring(data.token)
    end

    _ref.propTip.text = L("购买") .. "[ff0000]" .. _ref.propName.text ..(_ig.dat[3] > 0 and("*" .. _ig.dat[3]) or "") .. "?"
    --改变颜色
    _ref.propName.text = ColorStyle.Rare(_ref.propName.text, info.rare)
    _ref.btnBuy:SetClick(_w.ClickBuyCountryShopGoods, data.sn)
end

--[Comment]
--购买国库中的物品
function _w.ClickBuyCountryShopGoods(sn)
    local win = Win.GetOpenWin("PopCountryShop")
    if win then
        win.ClickBuyBack(sn)
    end
    _body:Exit()
end

--[Comment]
--声望商城购买界面
function _w.OnInitSoloRenown(data)
    local info = RW(data.rw)
    _ref.propName.text = info.nm
    _ref.propInfo.text = info.i

    _ig = ItemGoods(_ref.prop:AddChild(_ref.item_good, "item_good"))
    _ig:Init(data.rw)
    _ig:HideName()
    _ig.go.luaBtn.luaContainer = _body
    if _ig.IsPiece then
        _ref.propName.text = info.nm .. L("(碎片)")
    end
    if data.price > 0 then
        _ref.spPrice.spriteName = "sp_renown"
        _ref.labPrice.text = tostring(data.price)
    end
    _ref.propTip.text = L("购买") .. "[ff0000]" .. _ref.propName.text ..(_ig.dat[3] > 0 and("*" .. _ig.dat[3]) or "") .. "?"
    --改变颜色
    _ref.propName.text = ColorStyle.Rare(_ref.propName.text, info.rare)
    _ref.btnBuy:SetClick(_w.ClickBuyForSoloRenownShop, data)
end

--[Comment]
--竞技场声望商城中的购买
function _w.ClickBuyForSoloRenownShop(data)
    local win = Win.GetOpenWin("PopSoloRenownShop")
    if win then
        win.BuyCallback(data.id, 1)
    end
    _body:Exit()
end

function _w.ClickBuy(i)
    if _type > 0 then
        local win = Win.GetOpenWin("PopAllyShop")
        if win then
            win.ClickBuy(i)
        end
    else
        local win = Win.GetOpenWin("WinRareShop")
        if win then
            win.ClickBuy(i)
        end
    end
    _body:Exit()
end

function _w.ClickItemGoods(go)
    go = go and Item.Get(go)
    if go then
        go:ShowPropTip()
    end
end

function _w.OnDispose()
    if _ig then
        Destroy(_ig.go)
        ig = nil
    end
    _ref.propName.text = ""
    _ref.propInfo.text = ""
    _ref.labPrice.text = ""
    _ref.propTip.text = ""
    _type = -1
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _ig = nil
        _type = nil
    end
end