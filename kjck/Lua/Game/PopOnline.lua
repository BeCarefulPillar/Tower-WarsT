local _w = { }
--- <summary>在线奖励</summary>
PopOnline = _w

local _body = nil
local _ref = nil
local _dat = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
    _ref.tip.text = L("倒计时结束能领取奖励哦！")
    _ref.title.text = L("在线奖励")
end

local function BuildItems()
    if _dat and _dat.nrws then
        for i, v in ipairs(_dat.nrws) do
            local ig = ItemGoods(_ref.goodsGrid:AddChild(_ref.item_goods, string.format("goods_%02d", i)))
            ig:Init(v)
            ig.go.luaBtn.luaContainer = _body
        end
        _ref.goodsGrid:Reposition()
    end
end

function _w.OnInit()
    SVR.OnlineOpt("", function(t)
        if t.success then
            -- stab.S_OnlineReward
            _dat = SVR.datCache
            LuaActTimer(_body, _dat.tm, LuaActTimer.online)
            _ref.btnSure.isEnabled = _dat.tm <= 0
            BuildItems()
        end
    end )
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end

function _w.ClickSure()
    SVR.OnlineOpt("get", function(t)
        if t.success then
            -- stab.S_OnlineReward
            _dat = SVR.datCache
            PopRewardShow.Show(_dat.rws)
            -- MainPanel.Instance.CheckOnlineReward(olr);
            user.changed = true
            if not _dat.nrws or #_dat.nrws <= 0 then
                _body:Exit()
            end
            LuaActTimer(_body, _dat.tm, LuaActTimer.online)
            _ref.btnSure.isEnabled = false
            _w.OnDispose()
            BuildItems()
        end
    end )
end

function _w.OnActTimerEnd()
    _ref.btnSure.isEnabled = true
end

function _w.OnDispose()
    _ref.goodsGrid:DesAllChild()
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
    end
end