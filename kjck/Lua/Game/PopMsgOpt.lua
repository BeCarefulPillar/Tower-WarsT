
local _w = { }

PopMsgOpt = _w

local _body = nil
local _opt = nil

local _dat = nil

function _w.OnLoad(c)
    _body = c
    --组件绑定
    _opt = c:Child("option", typeof(UIPopupList))
    _opt.separatePanel = false
    -- 生命周期方法绑定
    c:BindFunction("OnUnLoad", "OnInit", "OnEnter", "OnDispose", "OnOptChange")
end

function _w.OnUnLoad(c)
    if _body == c then
        _body, _opt = nil, nil
    end
end

function _w.OnInit() 
    _dat = _w.initObj
    if _dat and _dat.name and _dat.psn then
        _opt:AddItem(L("好友"), 1)
        _opt:AddItem(L("私聊"), 2)
        _opt:AddItem(L("邮件"), 3)
        _opt:AddItem(L("定位"), 4)
        _opt:AddItem(L("拉黑"), 5)
    else
        _body:Exit()
    end
end

function _w.OnEnter() _opt:Show() return true end

function _w.OnDispose() 
    _dat = nil
    _opt:Clear()
end

function _w.OnOptChange()
    if _dat == nil or _dat.name == nil then return end
    local opt = _opt.data
    if _dat.psn then
        if opt == 1 then
            --好友
            SVR.FriendOption(_dat.psn, _dat.name, "add", function(t)
                if t.success then
                    ToolTip.ShowPopTip(ColorStyle.Blue(_dat.name) .. L("已加为好友！"))
                end
            end)
        elseif opt == 2 then
            --私聊
            if PopChat and PopChat.isOpen then PopChat.ToPri(_dat.psn, _dat.name) else Win.Open("PopChat", _dat) end
        elseif opt == 3 then
            --邮件
            if WinMail and WinMail.isOpen then WinMail.ToWrite(_dat.name) else Win.Open("WinMail", _dat.name) end
        elseif opt == 4 then
            --定位
            if PY_PvpCity.IsPvpCity(_dat.pvpLocal) then
                --待做定位
            elseif CheckSN(_dat.psn) then
                SVR.GetPlayerInfo(_dat.psn, function(t)
                    if t.success then
                        _dat.pvpLocal = SVR.datCache.city
                        --待做定位
                    end
                end)
            elseif _dat.nick ~= ""  then
                SVR.GetPlayerInfoByNm(_dat.name, function(t)
                    if t.success then
                        _dat.pvpLocal = SVR.datCache.city
                        --待做定位
                    end
                end)
            end
        elseif opt == 5 then
            --拉黑
            if _dat.name ~= "" then user.BlackLstAdd(_dat.name, true) end
        end
    end
end
