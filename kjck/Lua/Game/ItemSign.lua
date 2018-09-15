local _item = {
    go = nil,
    vip = nil,
    img = nil,
    wgt = nil,
    bg = nil,
    sign = nil,
    ef = nil,
    dat = nil,
}

function _item.New(go)
    assert(notnull(go), "go is not gameobject")
    return
    {
        go = go,
        vip = go:ChildWidget("sp_bg/vip"),
        img = go:ChildWidget("img"),
        wgt = go.widget,
        bg = go:ChildWidget("sp_bg"),
        sign = go:Child("sign"),
        ef = go:Child("ef_sign_frame"),
        dat = nil,
    }
end

function _item:Init(dat)
    self.dat = dat
    ItemGoods(self.go):Init(dat.rw)

    self.wgt.width = 110
    self.wgt.height = 110

    self.img.width = 104
    self.img.height = 104

    if dat.rate > 1 then
        self.bg:SetActive(true)
        self.vip.text = "v" .. dat.vip .. " "
        if type(dat.rate) == "number" then
            self.vip.text = self.vip.text .. L(number.ToCnString(dat.rate)) .. L("倍")
        end
        self.bg.spriteName = "vip_" .. dat.vip
    else
        self.bg:SetActive(false)
    end
end

function _item:setSignTag(flag)
    self.sign:SetActive(flag)
    self.wgt.color = flag and Color(0.5, 0.5, 0.5) or Color(1, 1, 1)
    self.img.color = flag and Color(0.5, 0.5, 0.5) or Color(1, 1, 1)
end

function _item:setFrameAnim(flag)
    self.ef:SetActive(flag)
end

function _item:getFrameAnim()
    return self.ef.activeSelf
end

objext(_item)

ItemSign = _item