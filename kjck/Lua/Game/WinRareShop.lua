require "Game/ItemRareShop"

local _w = { }

local _body = nil
local _ref = nil
local _bg = nil

local _data = nil
local _data_rmb = nil
local _data_soul = nil
local _cd_rmb = nil
local _cd_soul = nil

---<summary>1=魂店 else=珍宝阁</summary>
local _view = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c, { n = L("珍品馆"), r = DB_Rule.RareShop, i = true })
    _cd_rmb = TimeClock()
    _cd_soul = TimeClock()
    _view = -1
    for i, btn in ipairs(_ref.btnTabs) do
        btn.param = i - 1
    end
end

local ups = {
    [1] = function()
        _ref.money.text = tostring(user.soul)
        _ref.moneySP.spriteName = "sp_soul"
        _ref.money:SetActive(true)
        _ref.decSoulTip:SetActive(true)
    end,
    def = function()
        _ref.money:SetActive(false)
        _ref.decSoulTip:SetActive(false)
    end,
}

local function UpdateInfo()
    if ups[_view] then
        ups[_view]()
    else
        ups.def()
    end
    _ref.rfGold.text = tostring(_data and _data.rfGold or 0)
end

local svrs = {
    [1] = function()
        SVR.GetSoulShopInfo( function(r)
            if r.success then
                _data_soul = SVR.datCache
                _cd_soul.time = _data_soul.rfCD
                UpdateInfo()
                _w.ChangeView(_view, true)
            end
        end )
    end,
    def = function()
        SVR.GetRmbShopInfo( function(r)
            if r.success then
                _data_rmb = SVR.datCache
                _cd_rmb.time = _data_rmb.rfCD
                UpdateInfo()
                _w.ChangeView(_view, true)
            end
        end )
    end,
}

local function RefreshFromServer()
    if svrs[_view] then
        svrs[_view]()
    else
        svrs.def()
    end
end

function _w.ChangeView(v, force)
    v = v or 0

    if v == 1 and not user.IsHeroSoulUL then
        v = 0
    end

    if _view == v and not force then
        return
    end
    if v == 1 then
        --将魂
        if _data_soul == nil then
            _view = 1
            RefreshFromServer()
            return
        end
        _data = _data_soul
    elseif v == 2 then
        --商城
        Win.Open("WinShop")
    elseif v == 0 then
        --珍宝
        if _data_rmb == nil then
            _view = 0
            RefreshFromServer()
            return
        end
        v = 0
        _data = _data_rmb
    end

    if v ~= 2 then
        _view = v
        UpdateInfo()
        local f = nil
        for i, btn in ipairs(_ref.btnTabs) do
            f = _view ~= i - 1
            btn.isEnabled = f
            btn.label.color = f and Color(140 / 255, 157 / 255, 179 / 255) or Color.white
            btn.label.effectColor = Color.black
        end
        _ref.emptyTip:SetActive(#_data.goods < 1)
        _ref.grid:Reset()
        _ref.grid.realCount = #_data.goods
    end
end

function _w.OnInit()
    _ref.btnTabs[2]:SetActive(user.IsHeroSoulUL)
    _ref.tab.repositionNow = true
    _w.ChangeView(type(_w.initObj) == "number" and _w.initObj or 0, true)
end

function _w.ClickSortTab(i)
    _w.ChangeView(i)
end

local infs = {
    [1] = function()
        --int gold = User.Gold;
        SVR.SoulShopRefresh( function(result)
            if result.success then
                --TdAnalytics.OnPurchase(L.Get("珍宝阁魂店"), 1, gold - User.Gold);
                _data_soul = SVR.datCache
                _cd_soul.time = _data_soul.rfCD
                UpdateInfo()
                _w.ChangeView(_view, true)
            end
        end )
    end,
    def = function()
        --int gold = User.Gold;
        SVR.RmbShopRefresh( function(r)
            if r.success then
                --TdAnalytics.OnPurchase(L.Get("珍宝阁珍宝"), 1, gold - User.Gold);
                _data_rmb = SVR.datCache
                _cd_rmb.time = _data_rmb.rfCD
                UpdateInfo()
                _w.ChangeView(_view, true)
            end
        end )
    end,
}

local function PriRefresh()
    if infs[_view] then
        infs[_view]()
    else
        infs.def()
    end
end

function _w.Refresh()
    PriRefresh()
end

local function Update()
    if _view == 1 then
        _ref.rfTime.text = L("自动刷新:") .. TimeClock.TimeToString(_cd_soul.time)
        if _cd_soul.time <= 0 then
            RefreshFromServer()
        end
    else
        _ref.rfTime.text = L("自动刷新:") .. TimeClock.TimeToString(_cd_rmb.time)
        if _cd_rmb.time <= 0 then
            RefreshFromServer()
        end
    end
end
local _update = UpdateBeat:CreateListener(Update)
local _userdatachange = UserDataChange:CreateListener(UpdateInfo)
function _w.OnEnter()
    UpdateBeat:AddListener(_update)
    UserDataChange:AddListener(_userdatachange)
end
function _w.OnExit()
    UpdateBeat:RemoveListener(_update)
    UserDataChange:RemoveListener(_userdatachange)
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_data.goods then
        return false
    end

    local it = ItemRareShop(item)
    it:InitRmbShop(_data.goods[i + 1])
    it.btnBuy.param = i + 1

    return true
end

function _w.ClickDecomposeSoul()
    Win.Open("WinGoods", 11)
end

function _w.OpenBuyWin(i)
    if _data and _data.goods then
        Win.Open("PopBuyRareProps").OnInitRmbShop(_data.goods[i], i)
    end
end

local buys = {
    [1] = function(i)
        SVR.SoulShopBuy(_data.goods[i].sn, function(t)
            if t.success then
                _data_soul = SVR.datCache
                _cd_soul.time = _data_soul.rfCD
                if #_data_soul.goods > 0 then
                    UpdateInfo()
                    _w.ChangeView(_view, true)
                else
                    RefreshFromServer()
                end
            end
        end )
    end,
    def = function(i)
        --[[
        int moneyType = 0;
        int money = 0;
        if (data.goods[i].gold > 0) { moneyType = 0; money = data.goods[i].gold; }
        else if (data.goods[i].rmb > 0) { moneyType = 1; money = data.goods[i].rmb; }
        else if (data.goods[i].soul > 0) { moneyType = 2; money = data.goods[i].soul; }
        --]]
        SVR.RmbShopBuy(_data.goods[i].sn, function(t)
            if t.success then
                _data_rmb = SVR.datCache
                _cd_rmb.time = _data_rmb.rfCD
                --[[
                if (moneyType == 0) TdAnalytics.OnPurchase(L.Get("金币购买珍"), 1, money);
                else if (moneyType == 1) TdAnalytics.OnEvent(TDEvent.RmbSpend, L.Get("钻石购买珍"), money);
                --]]
                if #_data_rmb.goods > 0 then
                    UpdateInfo()
                    _w.ChangeView(_view, true)
                else
                    RefreshFromServer()
                end
            end
        end )
    end,
}

function _w.ClickBuy(i)
    if buys[_view] then
        buys[_view](i)
    else
        buys.def(i)
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _bg:dispose()
        _bg = nil
        _data = nil
        _data_rmb = nil
        _data_soul = nil
        _cd_rmb = nil
        _cd_soul = nil
        _view = nil
    end
end

---<summary>商城</summary>
WinRareShop = _w