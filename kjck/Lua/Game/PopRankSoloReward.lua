local ipairs = ipairs

local _w = { }
--[Comment]
--竞技场中的排名奖励
PopRankSoloReward = _w

local _body = nil
local _ref = nil

local _dat = nil
local _items = nil

local _rank = nil
local _total = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c,{k=WinBackground.MASK})

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "ClickItemGoods",
    "ClickGetBtn",
    "OnUnLoad"
    )

    _rank = {
        UIGrid = _ref.rank,
        UIScrollView = _ref.rank:GetCmp(typeof(UIScrollView)),
    }
    _ref.rank = nil

    _total = {
        UIGrid = _ref.total,
        igs =
        {
            _ref.total:Child("item_goods").gameObject,
            _ref.total:Child("item_goods (1)").gameObject,
            _ref.total:Child("item_goods (2)").gameObject,
            _ref.total:Child("item_goods (3)").gameObject,
        }
    }
    _ref.total = nil
end

--[Comment]
--设置右上角的总收益
local function SetTotalReward(totalRewards)
    local len = #totalRewards
    local ig = nil
    for i, v in ipairs(_total.igs) do
        if i - 1 < len then
            ig = Item.Get(v) or ItemGoods(v)
            ig:Init(totalRewards[i])
            ig.go:SetActive(true)
        end
    end
    _total.UIGrid.repositionNow = true
end

--[Comment]
--设置Item
local function SetItem(d, r)
    _ref.rankValue.text = tostring(r.selfRank)

    _items = _items or { }
    for i = 1, #d do
        if not _items[i] then
            local it = _rank.UIGrid:AddChild(_ref.item, string.format("item_%02d", 99 - i))
            local t = it:Child("rewardItem")
            local b = it:ChildBtn("btn_get")
            _items[i] = {
                go = it,
                id = d[i].s,
                btn_get = b,
                btn_getw = b.widget,
                btn_getc = b:ChildWidget("Label"),
                lab_needc0 = it:Child("lab_need"):ChildWidget("lab_rank"),
                goodss =
                {
                    t:Child("item_goods").gameObject,
                    t:Child("item_goods (1)").gameObject,
                    t:Child("item_goods (2)").gameObject,
                    t:Child("item_goods (3)").gameObject,
                },
                wgt = it.widget
            }
        end
        _items[i].go:SetActive(true)
        _items[i].btn_get.param = i

        --设置已经领取的
        if r and r.totalRewardsId and
            table.exists(r.totalRewardsId,
            function(id)
                return id == d[i].s
            end )
        then
            _items[i].btn_get.isEnabled = false
            _items[i].btn_getc.text = L("已领取")
        else
            _items[i].btn_get.isEnabled = true
            _items[i].btn_getc.text = L("领 取")
        end

        --设置还未达到领取条件的
        _items[i].btn_get.isEnabled = false
        _items[i].lab_needc0.text = tostring(d[i].target)

        local igs = _items[i].goodss
        local ig = nil
        for j, u in ipairs(igs) do
            if j - 1 < #d[i].rws then
                ig = Item.Get(u) or ItemGoods(u)
                ig:Init(d[i].rws[j])
                ig.go:SetActive(true)
                ig.go.luaBtn.luaContainer = _body
            else
                u:SetActive(false)
            end
        end
        _items[i].wgt.alpha = 0
        TweenAlpha.Begin(_items[i].go, 0.2, 1,(#d - i + 1) * 0.1)
    end

    _rank.UIGrid.repositionNow = true
    _rank.UIScrollView:ConstraintPivot(UIWidget.Pivot.Left, false)

    --设置右上角的总收益
    SetTotalReward(r.totalRewardsGoods)
end

function _w.OnInit()
    _dat = DB.Get("rank_rw")

    SVR.GetRankRewardInfo( function(t)
        if t.success then
            --stab.S_ReciveRankReward
            SetItem(_dat, SVR.datCache)
        end
    end )
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then btn:ShowPropTip() end
end

function _w.ClickGetBtn(i)
    local item = _items[i].id
    SVR.ReciveRankReward(item.id, function(t)
        if t.success then
            --stab.S_ReciveRankReward
            --展示奖励
            local reciveData = SVR.datCache
            item.btn_get.isEnabled = false
            item.btn_getw.spriteName = "btn_disabled"
            item.btn_getc.text = L("已领取")
            --更新总收益
            SetTotalReward(reciveData.totalRewardsGoods)
        end
    end )
end

local function Despawn(its, nm)
    if its then
        if nm then
            for i, v in ipairs(its) do
                v[nm]:SetActive(false)
            end
        else
            for i, v in ipairs(its) do
                v:SetActive(false)
            end
        end
    end
end

function _w.OnDispose()
    Despawn(_items, "go")
    Despawn(_total.igs)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
        _items = nil
        _rank = nil
        _total = nil
    end
end