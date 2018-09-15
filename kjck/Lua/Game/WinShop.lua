require "Game/ItemShop"
local ipairs = ipairs

local _w = { }
--[Comment]
--商城
WinShop = _w

local _body = nil
local _ref = nil

local _props = nil
local _dat = nil
local _isProps = nil
local _view = nil
local _bg = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c, { n = L("商城"), i=true })

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "ClickItemGoods",
    "OnWrapGridInitItem",
    "ClickSortTab",
    "OnUnLoad"
    )

    _view = -1
    _props = DB.AllProps()

    for i, btn in ipairs(_ref.btnTabs) do
        btn.param = i - 1
    end
end

local function ChangeView(v, force)
    v = v or 0

    if _view == v and not force then
        return
    end

    _isProps = true

    if v == 1 then
        --特价
        _dat = { }
    elseif v == 2 then
        --恢复
        _dat = table.findall(_props, function(p)
            return p.kind == 1 and p.rmb > 0
        end )
    elseif v == 3 then
        --加强
        _dat = table.findall(_props, function(p)
            return p.kind == 2 and p.rmb > 0
        end )
    elseif v == 4 then
        --宝箱
        _dat = table.findall(_props, function(p)
            return p.kind == 3 and p.rmb > 0
        end )
    elseif v == 5 then
        --VIP礼包
        _isProps = false
        _dat = DB.Get(LuaRes.Vip_Gifts)
    elseif v == 0 then
        --全部
        v = 0
        _dat = table.findall(_props, function(p)
            return p.kind >= 1 and p.kind <= 3 and p.rmb > 0
        end )
    end

    _view = v
    local f = nil
    for i, btn in ipairs(_ref.btnTabs) do
        f = _view ~= i - 1
        btn.luaBtn.isEnabled = f
        btn.label.color = f and Color(140 / 255, 157 / 255, 179 / 255) or Color.white
    end

    if _isProps then
        table.sort(_dat, DB_Props.Compare)
        _ref.grid.itemPrefab = _ref.item_shop
    else
        _ref.grid.itemPrefab = _ref.item_shop_vip
    end

    _ref.grid:Reset()
    _ref.grid.realCount = #_dat
end

function _w.OnInit()
    _ref.btnTabs[2]:SetActive(false)
    _ref.btnTabs[3]:SetActive(table.exists(_props, function(p) return p.kind == 1 and p.rmb > 0 end))
    _ref.btnTabs[4]:SetActive(table.exists(_props, function(p) return p.kind == 2 and p.rmb > 0 end))
    _ref.btnTabs[5]:SetActive(table.exists(_props, function(p) return p.kind == 3 and p.rmb > 0 end))

    ChangeView(type(_w.initObj) == "number" and _w.initObj or 0)
    _ref.tab.repositionNow = true
end

function _w.ClickSortTab(i)
    ChangeView(i)
end

function _w.ClickVipGift(btn, sn)
    --int gold = User.Gold;
    SVR.BuyVipGift(sn, function(r)
        if r.success then
            --TdAnalytics.OnPurchase(L.Get("VIP礼包")+sn+L.Get("购买"),1,gold - User.Gold);
            user.SetVipRec(sn)
            btn.isEnabled = false
            btn.label.text = L("已购买")
            user.changed = true
        end
    end )
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_dat then
        return false
    end

    local d = _dat[i + 1]

    if _isProps then
        local it = ItemShop(item)
        it:Init(d)
    else
        local btn = item:ChildBtn("btn_buy")
        if user.vip < d.vip then
            btn.isEnabled = false
            btn.label.text = L("需VIP") .. d.vip
        elseif user.GetVipRec(tostring(d.sn)) then
            btn.isEnabled = false
            btn.label.text = L("已购买")
        else
            btn.isEnabled = true
            btn.label.text = L("购 买")
        end

        btn:SetClick(_w.ClickVipGift, d.sn)
        item:ChildWidget("vip_1").text = tostring(d.vip)
        item:ChildWidget("vip_2").text = tostring(d.vip)
        item:ChildWidget("price").text = tostring(d.price)
        item:ChildWidget("sp_gold").spriteName = "sp_gold"

        local grid = item:Child("goods", typeof(UIGrid))
        grid:DesAllChild()
        for j, u in ipairs(d.rws) do
            local ig = ItemGoods(grid:AddChild(_ref.item_goods, string.format("item_%02d", j)))
            ig:Init(u)
            ig.go.luaBtn.luaContainer = _body
            ig.go.transform.localScale = Vector3(0.7, 0.7, 0.7)
            ig:HideName()
        end
        grid.repositionNow = true
    end

    return true
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end

function _w.OnDispose()
    _view = -1
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _props = nil
        _dat = nil
        _isProps = nil
        _view = nil
        _bg:dispose()
        _bg = nil
    end
end