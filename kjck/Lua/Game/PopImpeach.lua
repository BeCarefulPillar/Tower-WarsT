PopImpeach = { }
local _body = nil
PopImpeach.body = _body

local _ref
local btnY

function PopImpeach.OnLoad(c)
    WinBackground(c,{ k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "OnEnter", "ClickBtnY","OnUnLoad")

    btnY = _ref.btnYes
end

function PopImpeach.OnInit()
    btnY:SetClick("ClickBtnY", 1)
end

function PopImpeach.OnEnter()
    EF.PlayAni(_body, "PopLiteIn", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DoNotDisable)
    return true
end


function PopImpeach.ClickBtnY(p)
    SVR.AllyOption("imp|"..p, function(result)
        if result.success then
            ToolTip.ShowPopTip(L("成功发起弹劾"))
            _body:Exit()
        end
    end)
end

function PopImpeach.OnUnLoad()
    _body = nil
end

