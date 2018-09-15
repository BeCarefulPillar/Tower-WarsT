
local pop = { }
PopAllyCreat = pop

local _body = nil
PopAllyCreat.body = _body

local _ref
local _iptName = nil
local _iptBanner = nil
local _iptIntro = nil
local _labHL = nil
local _labCost = nil

local _flagSN = 1


local function OnBannerChanged()
    if string.isEmpty(_iptBanner.value) then _iptBanner.value = _banner.Str return end
    if _iptBanner.value.len > 1 then _iptBanner.value = utf8.sub(_iptBanner.value, 1, 2) end
    _banner.Str = _iptBanner.value
end

function pop.OnLoad(c)
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "OnEnter", "OnDispose", "OnUnLoad", "ClickSure")

    _iptName = _ref.allyName
    _iptBanner = _ref.allyBanner
    _iptIntro = _ref.allyIntro
    _labHL = _ref.homeLv
    _labCost = _ref.cost
end

function pop.OnInit()
--    EventDelegate.Set(_iptBanner.onSubmit, EventDelegate(OnBannerChanged))
    if CheckSN(user.ally.gsn) then ToolTip.ShowPopTip(L("你已经加入联盟!")) Destroy(_body.gameObject)
    else
        _flagSN = 1
        _labHL.text = L("需要主城等级:")..DB.unlock.ally
        _labHL.color = user.hlv < DB.unlock.ally and Color.red or Color(1, 240 / 255, 200 / 255)
        _labCost.text = tostring(DB.param.prAllyCreate)
    end
end

function pop.OnEnter()
    _body:GetCmp(typeof(UIPanel)).alpha = 0.01
    EF.PlayAni(_body.gameObject, "PopMidIn",1)
end

function pop.OnDispose()
    _flagSN = 1
end

function pop.OnUnLoad()
    _body = nil
    _iptName = nil
    _iptBanner = nil
    _iptIntro = nil
    _flag = nil
    _banner = nil
    _labHL = nil
    _labCost.text = ""
    _labCost = nil
    _objFlags = nil
end

function pop.ClickSure()
    -- 字符检测
    if not _iptName.value or _iptName.value == "" then ToolTip.ShowPopTip(ColorStyle.Warning(L("请输入联盟名称！"))) return end
    if  string.len(_iptName.value) < 2 then ToolTip.ShowPopTip(ColorStyle.Warning(L("联盟名称需要至少2个字符！"))) return end
    if DB.HX_Check(_iptName.value) then ToolTip.ShowPopTip(ColorStyle.Warning(L("输入的联盟名称含有非法字符！"))) return end
    if string.find(_iptName.value, " ") then ToolTip.ShowPopTip(ColorStyle.Warning(L("输入的联盟名称含有空白字符！"))) return end
    if not _iptBanner.value or _iptBanner.value == "" then ToolTip.ShowPopTip(ColorStyle.Warning(L("请输入联盟旗号！"))) return end
    if  string.len(_iptBanner.value) > 1 then ToolTip.ShowPopTip(ColorStyle.Warning(L("联盟旗号仅允许一个字符！"))) return end
    if DB.HX_Check(_iptBanner.value) then ToolTip.ShowPopTip(ColorStyle.Warning(L("输入的旗号含有非法字符！"))) return end
    if string.find(_iptBanner.value, " ") then ToolTip.ShowPopTip(ColorStyle.Warning(L("输入的旗号含空白字符！"))) return end

    SVR.CreatAlly(_iptName.value, _iptBanner.value, math.max(1, _flagSN), DB.HX_Filter(_iptIntro.value), function (r) if r.success then
        Win.ExitAllWin("MainMap")
        Win.Open("WinAlly")
        ToolTip.ShowPopTip(L("联盟创建成功！"))
    end end)
end


