require "Game/ItemCountryOvGoods"

local _w = { }

local _body = nil
local _ref = nil
local _dat = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
end

local function BuildItems()
    if _dat and _dat.goods then
        _ref.grid:Reset()
        _ref.grid.realCount = #_dat.goods
    end
end

local function PriRefresh()
    SVR.CountryShop("all", function(t)
        if t.success then
            --stab.S_CountryShop
            _dat = SVR.datCache
            local pcs = Win.GetOpenWin("PopCountryShop")
            if pcs then
                pcs.SyncGoodsQty(_dat)
            end
            BuildItems()
        end
    end )
end

function _w.OnInit()
    _ref.lable.text = L("国库总览")
    if not _dat or not _dat.goods then
        PriRefresh()
    else
        BuildItems()
    end
end

function _w.Refresh()
    PriRefresh()
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_dat.goods then
        return
    end
    local ref = item:GetCmp(typeof(NGUISerializeRef)).ref
    ItemCountryOvGoods.Init(ref, _dat.goods[i + 1])
    return true
end

function _w.SyncGoodsQty(sn, qty)
    if _dat.goods then
        for i, v in ipairs(_dat.goods) do
            if v.sn == sn then
                v.qty = qty
                return
            end
        end
    end
end

function _w.SyncGoodsQty(d)
    if d.goods and _dat.goods then
        for i, v in ipairs(_dat.goods) do
            for j, u in ipairs(d.goods) do
                if v.sn == u.sn and v.qty ~= u.qty then
                    v.qty = u.qty
                end
            end
        end
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
        --package.loaded["Game.PopCountryShopOverview"] = nil
    end
end

---<summary>
---国库
---</summary>
PopCountryShopOverview = _w