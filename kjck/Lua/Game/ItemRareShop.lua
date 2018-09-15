local notnull = notnull

local _item = {
    go = nil,
    imgl = nil,
    btnBuy = nil,
    frame = nil,
    propsName = nil,
    priceIcon = nil,
    price = nil,
    vip = nil,
    num = nil,
    intro = nil,
    remain = nil,
    wgt = nil,
}

function _item.New(go)
    assert(not isnull(go), "create ItemRareShop need GameObject")
    local icon = go:Child("icon",typeof(UITextureLoader))
    return {
        go = go,
        imgl = icon,
        btnBuy = go.luaBtn,
        frame = icon:ChildWidget("frame"),
        propsName = go:ChildWidget("name"),
        priceIcon = go:ChildWidget("sp_price"),
        price = go:ChildWidget("price"),
        vip = go:ChildWidget("vip"),
        num = icon:ChildWidget("num"),
        intro = go:ChildWidget("desc"),
        remain = go:ChildWidget("lbl_remainBuy"),
        wgt = go.widget,
    }
end

--[Comment]
--0=珍宝阁 1=联盟商城 2=军功商城
function _item:InitRmbShop(data, type)
    type = type or 0

    local info = RW(data.rw)

    self.frame.spriteName = info.frame
    self.propsName.text = info:getName()
    self.num.text = info.qty and "x" .. info.qty or ""
    self.intro.text = info[1] == 2 and info.i or ""

    ItemGoods.SetEquipEvo(self.imgl.gameObject, info.evo, info.rare)
    self.IsPiece = RW.IsPiece(info)

    if info.dat then
        self.imgl:Load(info.ico)
        self.imgl.luaBtn:SetClick( function(i)
            ItemGoods.ShowPropTip(i)
        end , info)
    else
        self.imgl:Dispose()
    end

    if data.gold > 0 then
        self.priceIcon.spriteName = "sp_gold"
        self.price.text = tostring(data.gold)
    elseif data.soul > 0 then
        self.priceIcon.spriteName = 
            type==0 and "sp_soul" or type==1 and "sp_acash" or "sp_amerit"
        self.price.text = tostring(data.soul)
    else
        self.priceIcon.spriteName = "sp_diamond"
        self.price.text = tostring(data.rmb)
    end

    self.vip.color = user.vip < data.vip and Color.red or Color.white
    self.vip.text = data.vip > 0 and string.format("VIP:%d", data.vip) or ""
    self.go:SetActive(true)
end

--[Comment]
--设置声望商城Item显示
function _item:InitSoloRenown(data)
    self.propsName.text = ""
    local info = RW(data.rw)
    self.frame.spriteName = info.frame
    self.propsName.text = info.nm
    self.num.text = info.qty and "x" .. info.qty or ""
    self.intro.text = data.rw[1] == 2 and info.i or ""
    ItemGoods.SetEquipEvo(self.imgl.gameObject, info.evo, info.rare)
    self.IsPiece = RW.IsPiece(info)
    if info.dat then
        self.imgl:Load(info.ico)
        self.imgl:GetCmp(typeof(LuaButton)):SetClick( function(i)
            ItemGoods.ShowPropTip(i)
        end , info)
    else
        self.imgl:Dispose()
    end
    if data.price > 0 then
        self.priceIcon.spriteName = "sp_renown"
        self.price.text = tostring(data.price)
    end
end

_item.__get = {
    IsPiece = function(i)
        local t = i.imgl:Child("piece")
        return notnull(t) and t.activeSelf
    end
}

_item.__set = {
    IsPiece = function(i, v)
        local t = i.imgl:Child("piece")
        if notnull(t) then
            t:SetActive(v)
        elseif v then
            t = i.imgl:AddWidget(typeof(UISprite), "piece")
            t.atlas = AM.mainAtlas
            t.spriteName = "sp_piece"
            t.width = 98
            t.height = 98
            t.depth = i.imgl.widget.depth+1
        end
    end
}

objext(_item)

ItemRareShop = _item