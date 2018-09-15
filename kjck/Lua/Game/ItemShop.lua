local tostring = tostring
local notnull = notnull

local _item =
{
    go = nil,
    icon = nil,
    priceIcon = nil,
    pName = nil,
    price = nil,
    desc = nil,
    btnBuy = nil,
    dat = nil,
}

function _item.New(go)
    assert(notnull(go), "go is not gameobject")
    return
    {
        go = go,
        icon = go:ChildWidget("icon"),
        priceIcon = go:ChildWidget("sp_price"),
        pName = go:ChildWidget("name"),
        price = go:ChildWidget("price"),
        desc = go:ChildWidget("desc"),
        btnBuy = go:ChildBtn("btn_buy"),
        dat = nil,
    }
end

function _item.Init(i, props)
    i.dat = props
    i.pName.text = props.nm
    i.price.text = props.rmb
    i.priceIcon.spriteName = "sp_diamond"
    i.desc.text = props.i
    i.icon:LoadTexAsync(ResName.PropsIcon(props.img))

    i.btnBuy:SetClick( function(p)
        Win.Open("PopBuyProps", {d=p,kind=PopBuyProps.Prop})
    end , i.dat)
end

objext(_item)

ItemShop = _item