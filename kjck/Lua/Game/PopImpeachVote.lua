PopImpeachVote = { }
local _body = nil
PopImpeachVote.body = _body

local _ref

local btnY
local btnN

--弹劾文本
local labContent
--弹劾所需人数
local labNeed
--参与人数
local labVote

function PopImpeachVote.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit","OnEnter","ClickOpt","OnUnLoad")

    btnY = _ref.btnYes
    btnN = _ref.btnNo
    labContent = _ref.labContent
    labNeed = _ref.labNeed
    labVote = _ref.labVote
end

function PopImpeachVote.OnInit()
    btnY:SetClick("ClickOpt", 1)
    btnN:SetClick("ClickOpt", 0)

    if user.ally.impInfo and user.ally.impInfo[6] == 1 then
        btnY:SetActive(false)
        btnN:SetActive(false)
    end

    labContent.text = string.format("副盟主【%s】对盟主【%s】发起弹劾,是否同意【%s】成为新盟主?", user.ally.impName, user.ally.chief, user.ally.impName)
    labNeed.text = L("弹劾所需:") .. user.ally.impInfo[2] .. "/" .. user.ally.impInfo[3]
    labVote.text = L("参与投票:") .. user.ally.impInfo[4] .. "/" .. user.ally.impInfo[5]
end

function PopImpeachVote.OnEnter()
    EF.PlayAni(_body, "PopLiteIn", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DoNotDisable)
    return true
end

function PopImpeachVote.ClickOpt(p)
    local opt = p
    local msg = ""
    if opt == 1 then msg = L("投票成功,您同意了此次弹劾")
    elseif opt == 0 then msg = L("投票成功,您否决了此次弹劾") end
    SVR.AllyOption("imp|"..opt, function(result)
        if result.success then
            ToolTip.ShowPopTip(msg)
            _body:Exit()
        end
    end)
end

function PopImpeachVote.OnUnLoad()
    _body = nil
end
