local _w = { }

local _body = nil
local _ref = nil
local _props = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
    _props = user.GetPropsDat(122)
end

local function RefreshInfo()
    local f = _props.qty > 0
    _ref.btnReset.widget.spriteName = f and "sp_btn_register" or "sp_btn_login"
    _ref.btnReset.text = f and L("免 费") or L("购 买")
    if f then
        _ref.btnReset:SetClick(_w.ClickReset)
    else
        _ref.btnReset:SetClick(_w.ClickBuy)
    end
    _ref.labPrice:SetActive(not f)
end

function _w.OnInit()
    _ref.labCount.text = tostring(_props.qty)
    _ref.labName.text = tostring(_props.nm)
    _ref.labInfo.text = tostring(_props.i)
    RefreshInfo()
end

function _w.ClickReset()
    SVR.TechPersonal("reset", function(t)
        if t.success then
            --stab.S_TechP
            local res = SVR.datCache
            user.SetPropsQty(_props.sn, res.resetCard)
            _ref.labCount.text = tostring(_props.qty)
            RefreshInfo()
            ToolTip.ShowPopTip(L("重置成功！"))
            _body:Exit()
        end
    end )
end

function _w.ClickBuy()
    SVR.TechPersonal("buy", function(t)
        if t.success then
            --stab.S_TechP
            local res = SVR.datCache
            user.SetPropsQty(_props.sn, res.resetCard)
            _ref.labCount.text = tostring(_props.qty)
            user.rmb = res.rmb
            user.changed = true
            RefreshInfo()
            ToolTip.ShowPopTip(L("重置成功！"))
            _body:Exit()
        end
    end )
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _props = nil
    end
end

---<summary>
---科技
---</summary>
PopTechReset = _w