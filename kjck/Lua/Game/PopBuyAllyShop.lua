PopBuyAllyShop = { }
local _body = nil
PopBuyAllyShop.body = _body

local _ref

local item_good
local prop
local btnBuy
local propName
local propIntro
local propTip
local spPrice
local labPrice

local data

function PopBuyAllyShop.OnLoad(c)
    WinBackground(c, {k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "ClickBuy", "OnDispose", "OnUnLoad")

    item_good = _ref.item_good
    prop = _ref.prop
    btnBuy = _ref.btnBuy
    propName = _ref.propName
    propIntro = _ref.propInfo
    propTip = _ref.propTip
    spPrice = _ref.spPrice
    labPrice = _ref.labPrice
end

function PopBuyAllyShop.OnInit()
    local o = PopBuyAllyShop.initObj
    if o ~= nil and type(o) == "table" then
        data = o
        local info = RW(data.rw)
        propName.text = info.nm
        propIntro.text = info.i
        local go = prop:AddChild(item_good, "item")
        ig = ItemGoods(go)
        ig:Init(data.rw)
        ig:HideName()
        if ig.IsPiece then propName.text = propName.text .."(碎片)" end

        if data.gold > 0 then 
            spPrice.spriteName = "sp_gold"
            labPrice.text = data.gold
        elseif data.soul > 0 then
            spPrice.spriteName = "sp_acash"
            labPrice.text = data.soul
        else
            spPrice.spriteName = "sp_diamond"
            labPrice.text = data.rmb
        end

        propTip.text = L("购买").."[FF0000]"..propName.text .. (tonumber(info.qty) > 0 and "*".. info.qty or "" ).."?"
        propName.color = ColorStyle.Rare(propName.text, info.rare)

        btnBuy:SetClick("ClickBuy", data.sn)
    end
end

function PopBuyAllyShop.ClickBuy(d)
    Win.GetOpenWin("PopAllyShop").ClickBuy(d)
    _body:Exit()
end

function PopBuyAllyShop.OnDispose()
    if prop.transform.childCount > 0 then prop:DesAllChild() end
end

function PopBuyAllyShop.OnUnLoad()
    _body = nil
end