require "Game/ItemCountryGoods"

local _w = { }

local _body = nil
local _ref = nil

local _dat = nil
local _dt = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { n = L("国库"), r = DB_Rule.CountryShop, i = true })
    _dt = 0
end

local function UpdateInfo()
    _ref.token.text = tostring(user.token)
    _ref.time.text = L("自动刷新:") .. TimeClock.TimeToString(_dat.rfCD)
    _ref.gold.text = tostring(_dat.rfGold)
end

local function BuildItems()
    if _dat and _dat.goods then
        _ref.grid:Reset()
        _ref.grid.realCount = #_dat.goods
    end
end

local function PriRefresh()
    SVR.CountryShop("inf", function(result)
        if result.success then
            --stab.S_CountryShop
            _dat = SVR.datCache
            _ref.buyCount.text = tostring(_dat.buyQty)
            UpdateInfo()
            BuildItems()
        end
    end )
end

local function Update()
    _dt = _dt + Time.deltaTime
    if _dt > 1 then
        _dt = _dt - 1
        if _dat.rfCD > 0 then
            _dat.rfCD = _dat.rfCD - 1
            _ref.time.text = L("自动刷新:") .. TimeClock.TimeToString(_dat.rfCD)
            if _dat.rfCD <= 0 then
                PriRefresh()
            end
        end
    end
end
local _update = UpdateBeat:CreateListener(Update)
function _w.OnEnter()
    UpdateBeat:AddListener(_update)
end
function _w.OnExit()
    UpdateBeat:RemoveListener(_update)
end

function _w.OnInit()
    _ref.lables[1].text = L("国库总览")
    _ref.lables[2].text = L("刷 新")

    if not _dat or not _dat.goods then
        PriRefresh()
    else
        UpdateInfo()
        BuildItems()
    end
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_dat.goods then
        return false
    end
    local ref = item:GetCmp(typeof(NGUISerializeRef)).ref
    ItemCountryGoods.Init(ref, _dat.goods[i + 1])
    ref.btnBuy.param = i + 1
    return true
end

function _w.Refresh()
    SVR.CountryShop("ref", function(t)
        if t.success then
            _dat = SVR.datCache
            _ref.buyCount.text = tostring(_dat.buyQty)
            local w = Win.GetOpenWin("PopCountryShopOverview")
            if w then
                w.SyncGoodsQtyBySp(_dat)
            end
            UpdateInfo()
            BuildItems()
        end
    end )
end

function _w.ClickOverview()
    Win.Open("PopCountryShopOverview")
end

function _w.ClickTokenTip()
    ToolTip.ShowToolTip(L("国家的封赏令，通过国战日常和限时任务获得，可以兑换国库宝物。"))
end

function _w.ClickBuy(i)
    if _dat.buyQty < 1 then
        MsgBox.Show(L("今日购买次数已用完！请明日购买！"))
        return
    end
    if _dat.goods then
        Win.Open("PopBuyRareProps").OnInitCountryShop(_dat.goods[i])
    end
end

function _w.ClickBuyBack(sn)
    SVR.CountryBuyGoods(sn, function(t)
        if t.success then
            --stab.S_CountryBuyGoods
            local res = SVR.datCache
            _ref.buyCount.text = tostring(res.buyQty or 0)
            if not res.rws then
                if string.notEmpty(res.tip) then
                    MsgBox.Show(res.tip)
                    return
                end
            end
            if _dat.goods then
                UpdateInfo()
                for i, v in ipairs(_dat.goods) do
                    if v.sn == res.sn then
                        table.remove(_dat.goods, i)
                        BuildItems()
                        break
                    end
                end
            else
                PriRefresh()
            end
        end
    end )
end

function _w.SyncGoodsQty(d)
    local change = false
    if d.goods and _dat.goods then
        for i = 1, #_dat.goods do
            for j = 1, #d.goods do
                if _dat.goods[i].sn == d.goods[j].sn and _dat.goods[i].qty ~= d.goods[j].qty then
                    _dat.goods[i].qty = d.goods[j].qty
                    change = true
                end
            end
        end
    end
    if change and _ref.grid.realCount > 0 then
        BuildItems()
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
        _dt = nil
        --package.loaded["Game.PopCountryShop"] = nil
    end
end

---<summary>
---国库
---</summary>
PopCountryShop = _w