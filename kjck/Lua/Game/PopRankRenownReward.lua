local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil

local _rewardDatas = nil
local _items = nil
local _grid = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c,{k=WinBackground.MASK})

    --一键领取
    _ref.btnOneGet.param = 0

    _grid = {
        UIGrid = _ref.grid,
        UIScrollView = _ref.grid:GetCmp(typeof(UIScrollView))
    }
    _ref.grid = nil
end

--[Comment]
--设置奖励
local function SetItem(d, r)
    _items = _items or { }
    for i, v in ipairs(d) do
        if not _items[i] then
            local item = _grid.UIGrid:AddChild(_ref.item, string.format("item_%02d", i))
            local btn = item:ChildBtn("btn_get")
            _items[i] = {
                go = item,
                wid = item.widget,
                lbl_requirValue = item:ChildWidget("lbl_requirValue"),
                btn_get = btn,
                btnlabel = btn:ChildWidget("Label"),
                grid_goods = item:Child("grid_goods",typeof(UIGrid)),
                igs = nil
            }
        end
        _items[i].go:SetActive(true)
        _items[i].lbl_requirValue.text = L("积分达到：") .. v.score
        _items[i].btn_get.param = v.sn
        --积分达不到，不能领取
        if v.score > r.selfScore then
            _items[i].btn_get.isEnabled = false
        end
        if r.reciveStatus[i] == 0 then
            _items[i].btnlabel.text = L("已领取")
        else
            _items[i].btnlabel.text = L("领 取")
        end

        _items[i].igs = _items[i].igs or { }
        local gd = _items[i].grid_goods
        local igs = _items[i].igs
        for j, u in ipairs(v.rws) do
            if not igs[j] then
                igs[j] = ItemGoods(gd:AddChild(_ref.item_goods, string.format("goods_%02d", j)))
            end
            igs[j]:Init(u)
            igs[j].go:SetActive(true)
            igs[j].go.luaBtn.luaContainer = _body
            igs[j].go.transform.localScale = Vector3(0.8, 0.8, 0.8)
        end
        gd.repositionNow = true
        _items[i].wid.alpha = 0
        TweenAlpha.Begin(_items[i].go, 0.2, 1,(i - 1) * 0.1)
    end
    _grid.UIGrid.repositionNow = true
    _grid.UIScrollView:ConstraintPivot(UIWidget.Pivot.Top, false)

    _ref.myScoreValue.text = tostring(r.selfScore)

    --是否能一键领取(把可领取的都领掉)
    local canAllRecive = false
    for i, v in pairs(r.reciveStatus) do
        if d[i].score <= r.selfScore and v ~= 0 then
            canAllRecive = true
            break
        end
    end

    _ref.btnOneGet.isEnabled = canAllRecive
end

function _w.ClickItemGoods(go)
    go = go and Item.Get(go)
    if go then
        go:ShowPropTip()
    end
end

function _w.OnInit()
    _rewardDatas = DB.Get("rank_jf_rw")

    SVR.GetRenownRewardInfo( function(t)
        if t.success then
            --stab.S_ReciveRenownReward
            local r = SVR.datCache
            local add = r.increaseValue
            _ref.otherLabels[2]:ChildWidget("Label").text = "+" .. add * 2
            _ref.otherLabels[3]:ChildWidget("Label").text = "+" .. add
            SetItem(_rewardDatas, r)
        end
    end )

    _ref.otherLabels[1].text = L("在竞技场与对手战斗可获得积分")
    _ref.otherLabels[2].text = L("胜利：积分")
    _ref.otherLabels[3].text = L("失败：积分")
    _ref.otherLabels[4].text = L("每天24:00重置")
    _ref.otherLabels[5].text = L("积分达到：")
    _ref.otherLabels[6].text = L("一键领取")
end

local function Despawn(its)
    if its then
        for i, v in ipairs(its) do
            v.go:SetActive(false)
            Despawn(v.igs)
        end
    end
end

function _w.OnDispose()
    Despawn(_items)
end

--[Comment]
--领取
function _w.ClickBtnGet(p)
    SVR.ReciveRenownReward(p, function(t)
        if t.success then
            --stab.S_ReciveRenownReward
            local r = SVR.datCache

            --已经领取的按钮失效
            local canAllRecive = false
            for i, v in ipairs(r.reciveStatus) do
                if v == 0 then
                    _items[i].btn_get.isEnabled = false
                    _items[i].btnlabel.text = L("已领取")
                else
                    if _rewardDatas[i].score <= r.selfScore and v ~= 0 then
                        canAllRecive = true
                    end
                end
            end

            _ref.btnOneGet.isEnabled = canAllRecive
        end
    end )
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _rewardDatas = nil
        _items = nil
        _grid = nil
    end
end

--[Comment]
--竞技场中的积分奖励
PopRankRenownReward = _w