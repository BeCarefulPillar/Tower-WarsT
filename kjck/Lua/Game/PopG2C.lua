local _w = { }
---<summary>货币兑换</summary>
PopG2C = _w

local _body = nil
local _ref = nil
local _dat = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK, exitfc = _w.Close })
    _dat = DB.Get(LuaRes.G2C)
end

function _w.OnInit()
    _ref.lables[1].text = L("点石成金")
    _ref.lables[2].text = L("今日可用:")
    _ref.lables[3].text = L("用少量金币换取大量银币")
    _ref.lables[4].text = L("使 用")

    _ref.times.text =(user.g2cQty - user.g2cUsed) .. "/" .. user.g2cQty
    _ref.gold.text = "0"
    _ref.silver.text = "0"

    _ref.btnUse.isEnabled = user.g2cQty > 0

    if user.g2cUsed < #_dat then
        _ref.gold.text = _dat[user.g2cUsed + 1].gold
        _ref.silver.text = _dat[user.g2cUsed + 1].coin
    end
end

local function Active()
    return _body.gameObject.activeSelf
end

function _w.OnEnter()
    _body.transform.localPosition = Vector3(0, 500, 0)
    EF.MoveTo(_body, "y", 0, "islocal", true, "time",
    0.44, "easetype", iTween.EaseType.easeOutBack)
end

function _w.Close()
    if Active() then
        EF.MoveTo(_body, "y", 500, "islocal", true, "time", 0.3,
        "easetype", iTween.EaseType.easeInCirc)
        Invoke( function()
            _body:Exit()
        end , 0.3)
    end
end

function _w.ClickUse()
    if user.g2cQty > 0 then
        local s = _dat and #_dat > user.g2cUsed and _dat[user.g2cUsed + 1].coin or 0
        SVR.G2C( function(t)
            if t.success then
                --stab.S_G2C
                local res = SVR.datCache
                ToolTip.ShowPopTip(
                L("花费金币:") .. ColorStyle.Gold(res.gold .. "") ..
                "," ..
                L("获得银币:") .. ColorStyle.Silver(res.coin .. ""))
                _w.OnInit()
                --TdAnalytics.OnPurchase(L.Get("点石成金"), 1, res.gold);
                if s > 0 and res.coin >= s * 2 then
                    _body:AddChild(AM.LoadPrefab("ef_g2c"), "ef_g2c", false)
                end
            end
        end )
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
    end
end