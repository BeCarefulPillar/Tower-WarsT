local _w = { Prop = 1, Soul = 2, EquipSp = 3, Rank = 4, Renown = 5 }
-- [Comment]
-- 操作道具（购买，分解，出售）
PopBuyProps = _w

local _body = nil
local _ref = nil

local _piece = nil
local _num = nil
local _kind = nil
local _dat = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
    _ref.iptPrice.onChange:Clear()
    _ref.iptPrice.onChange:Add(EventDelegate(_w.OnIptChange))
end

local goods = nil

local function UpdatePrice()
    if _goods[_kind] then
        _goods[_kind].upt()
    end
end

_goods = {
    -- 道具
    [_w.Prop] =
    {
        init = function()
            print("道具")
            if _dat.rmb > 0 then
                _ref.title.text = L("购 买")
                _ref.propsName.text = _dat.nm
                _ref.spPriceUnit.spriteName = "sp_diamond"
                _ref.spPriceTaotal.spriteName = "sp_diamond"
                _ref.frame.spriteName = "frame_props"
                _ref.icon:LoadTexAsync(ResName.PropsIcon(_dat.img))

                _ref.priceUnit.text = L("[FFF0C1]单价:[-]") .. _dat.rmb
                _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. _dat.rmb
                _num = 1
                _ref.iptPrice.value = "1"

                _ref.buy.text = L("购 买")
                _ref.frameQty.text = ""
            else
                Destroy(_body.gameObject)
            end
        end,
        upt = function()
            _ref.iptPrice.value = tostring(_num)
            _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. _dat.rmb * _num
        end,
        buy = function()
            _num = math.clamp(_num, 1, 999999)
            SVR.BuyGoods(_dat.sn, _num, "rmb",
            function(t)
                if t.success then
                print(kjson.print(t))
                    ToolTip.ShowPopTip(string.format(L("获得 %s×%d"), ColorStyle.Blue(_dat.nm), _num))
                    -- 购买成功
                    _body:Exit()
                    user.changed = true
                end
            end )
        end
    },
    -- 将魂
    [_w.Soul] =
    {
        init = function()
            print("将魂")
            local hero = _dat
            if hero and hero.sn > 0 and user.GetSoulQty(hero.sn) > 0 then
                _ref.title.text = L("分解将魂")
                _ref.propsName.text = ColorStyle.Rare(hero.nm .. L("之将魂") .. hero.rare)
                _ref.spPriceTaotal.spriteName = "sp_soul"
                _ref.spPriceUnit.spriteName = "sp_soul"
                _ref.frame.spriteName = "frame_hero_soul"

                _ref.icon:LoadTexAsync(ResName.HeroIcon(hero.img))

                _ref.priceUnit.text = L("[FFF0C1]单价:[-]") .. DB.param.prSellSoul
                _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. DB.param.prSellSoul
                _num = 1
                _ref.iptPrice.value = "1"

                _ref.buy.text = L("分 解")
                _ref.frameQty.text = "x" .. user.GetSoulQty(hero.sn)
            else
                Destroy(_body.gameObject)
            end
        end,
        upt = function()
            local hero = _dat
            _num = math.clamp(_num, 1, user.GetSoulQty(hero.sn))
            _ref.iptPrice.value = tostring(_num)
            _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. _num * DB.param.prSellSoul
        end,
        buy = function()
            local hero = _dat
            _num = math.clamp(_num, 1, user.GetSoulQty(hero.sn))
            if hero.sn > 0 then
                SVR.HeroSellSoul(hero.sn, _num, function(t)
                    if t.success then
                        local qty = user.GetSoulQty(hero.sn)
                        if _num > qty then
                            _num = qty
                            user.changed = true
                            UpdatePrice()
                        end
                        _ref.frameQty.text = "x" .. qty
                        if qty <= 0 then
                            _body:Exit()
                        end
                        local win = Win.GetOpenWin("WinGoods")
                        if win then
                            win.RefreshData()
                        end
                    end
                end )
            end
        end
    },
    -- 装备碎片
    [_w.EquipSp] =
    {
        init = function()
            print("装备碎片")
            local equip = _dat
            if equip and equip.dbsn > 0 and user.GetEquipSp(equip.dbsn) > 0 then
                _ref.title.text = L("出 售")
                _ref.propsName.text = ColorStyle.Rare(equip.nm .. L("(碎片)"), equip.rare)
                _ref.spPriceTaotal.spriteName = "sp_silver"
                _ref.spPriceUnit.spriteName = "sp_silver"
                _ref.frame.spriteName = "frame_" .. equip.rare

                if notnull(_piece) then
                    _piece:SetActive(true)
                else
                    _piece = _ref.frame:AddWidget(typeof(UISprite), "piece")
                    _piece.atlas = AM.mainAtlas
                    _piece.spriteName = "sp_piece"
                    _piece.width = 90
                    _piece.height = 90
                    _piece.depth = 6
                end

                _ref.icon:LoadTexAsync(ResName.EquipIcon(equip.img))

                local p = equip.piece > 0 and math.modf(equip.price / equip.piece) or 0

                _ref.priceUnit.text = L("[FFF0C1]单价:[-]") .. p
                _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. p
                _num = 1
                _ref.iptPrice.value = "1"

                _ref.buy.text = L("出 售")

                _ref.frameQty.text = "x" .. user.GetEquipSp(equip.dbsn)
            else
                Destroy(_body.gameObject)
            end
        end,
        upt = function()
            local equip = _dat
            _num = math.clamp(_num, 1, user.GetEquipSp(equip.dbsn))
            _ref.iptPrice.value = tostring(_num)
            local p = equip.piece > 0 and math.modf(equip.price / equip.piece) or 0
            _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. _num * p
        end,
        buy = function()
            local equip = _dat
            _num = math.clamp(_num, 1, user.GetEquipSp(equip.sn))
            if equip.sn > 0 then
                SVR.EquipPieceOption("sell|" .. equip.sn .. "|" .. _num, function(t)
                    if t.success then
                        local qty = user.GetEquipSp(equip.sn)
                        if _num > qty then
                            _num = qty
                            UpdatePrice()
                        end
                        _ref.frameQty.text = "x" .. qty
                        BGM.PlaySOE("sound_click_sell")
                        if qty <= 0 then
                            _body:Exit()
                        end
                        local win = Win.GetOpenWin("WinGoods")
                        if win then
                            win.RefreshData()
                        end
                    end
                end )
            end
        end
    },
    -- 演武榜挑战次数
    [_w.Rank] =
    {
        init = function()
            print("演武榜挑战次数")
            _ref.title.text = L("购买挑战次数")
            _ref.propsName.text = ""
            _ref.spPriceUnit.spriteName = "frame_emptySprite"
            _ref.spPriceTaotal.spriteName = "sp_diamond"
            _ref.frame.spriteName = "frame_emptySprite"
            _ref.icon:UnLoadTex()

            local remainBuy = #_dat.prices
            _num = remainBuy == 0 and 0 or 1
            _ref.iptPrice.value = tostring(_num)
            _ref.priceUnit.text = L("剩余购买次数") .. remainBuy
            _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. _num * _dat.prices[1]

            _ref.buy.text = L("购 买")
            _ref.frameQty.text = ""
        end,
        upt = function()
            local remainBuy = #_dat.prices
            _num = remainBuy > 0 and math.clamp(_num, 1, remainBuy) or 0
            _ref.iptPrice.value = tostring(_num)
            local cost = 0
            for i = 1, _num do
                cost = cost + _dat.prices[i]
            end
            _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. cost
        end,
        buy = function()
            if _num == 0 then
                return
            end
            _num = math.clamp(_num, 1, #_dat.prices)
            local cost = 0
            for i = 1, _num do
                cost = cost + _dat.prices[i]
            end
            SVR.BuySoloTimes(cost, _num, function(t)
                if t.success then
                    local win = Win.GetOpenWin("WinRankSolo")
                    if win then
                        win.SetSoloTimesInfo(SVR.datCache)
                    end
                end
                _body:Exit()
            end )
        end
    },
    -- 声望商城
    [_w.Renown] =
    {
        init = function()
            print("声望商城")
            local info = RW(_dat)
            _ref.title.text = L("购 买")
            _ref.propsName.text = ColorStyle.Rare(info.nm, info.rare)
            _ref.spPriceTaotal.spriteName = "icon_renown"
            _ref.spPriceUnit.spriteName = "icon_renown"
            _ref.icon:UnLoadTex()

            _num = _dat.remainBuyTimes == 0 and 0 or 1
            _ref.iptPrice.value = tostring(_num)
            _ref.priceUnit.text = L("[FFF0C1]单价:[-]") .. _dat.price
            _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. _num * _dat.price

            _ref.buy.text = L("购 买")
            _ref.frameQty.text = info.qty
        end,
        upt = function()
            _num = _dat.remainBuyTimes > 0 and math.clamp(_num, 1, _dat.remainBuyTimes) or 0
            _ref.iptPrice.value = tostring(_num)
            _ref.priceTotal.text = L("[FFF0C1]总价:[-]") .. _dat.price
        end,
        buy = function()
            if _num == 0 then
                return
            end
            _num = math.clamp(_num, 1, _dat.remainBuyTimes)
            local win = Win.GetOpenWin("PopSoloRenownShop")
            if win then
                win.BuyCallback(_dat.id, _num)
            end
            _body:Exit()
        end
    },
}

function _w.OnInit()
    _ref.lables[1].text = L("购 买")
    _ref.lables[2].text = L("取 消")
    _ref.lables[3].text = L("购 买")

    local obj = _w.initObj
    if obj.d and obj.kind and _goods[obj.kind] then
        _dat = obj.d
        _kind = obj.kind
        _goods[_kind].init()
    else
        Destroy(_body.gameObject)
    end
end

function _w.OnDispose()
    _dat = nil
    num = 1
    if _piece and notnull(_piece) then
        _piece:SetActive(false)
    end
end

function _w.ClickBuy()
    if _goods[_kind] then
        _goods[_kind].buy()
    end
end

function _w.ClickAdd()
    _num = _num + 1
    UpdatePrice()
end

function _w.ClickReduce()
    _num = _num - 1
    UpdatePrice()
end

function _w.OnIptChange()
    _num = tonumber(_ref.iptPrice.value)
    UpdatePrice()
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _piece = nil
        _dat = nil
        _num = nil
        _kind = nil
    end
end