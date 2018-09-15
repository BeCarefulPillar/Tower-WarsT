PopGveInvite = { }

local _body = nil
PopGveInvite.body = _body

local grid = nil
local data = { }

local function Refresh()
    SVR.GveCheckInvite(function(result)
        if result.success then 
            local res = SVR.datCache
            if #res > 0 then 
                table.copy(res, data)
                grid:Reset()
                grid.realCount = #data
            else
                MainUI.btns.palaceInvite.gameObject:SetActive(false)
                _body:Exit() 
             end
        end
    end)
end

function PopGveInvite.OnLoad(c)
    _body = c
    WinBackground(c, {k = WinBackground.MASK})

    c:BindFunction("OnInit", "ClickRefuse", "ClickAgree", "OnWrapGridInitItem", "OnDispose", "OnUnLoad")

    local gos = c.gos
    grid = gos[1]:GetCmp(typeof(UIWrapGrid))

end

function PopGveInvite.OnInit()
    Refresh()
end

function PopGveInvite.OnWrapGridInitItem(item, index)
    if item then
        local info = item:ChildWidget("lbl_describe")
        local time = item:ChildWidget("lbl_time")
        local btnR = item:ChildWidget("btn_refuse").luaBtn
        local btnA = item:ChildWidget("btn_agree").luaBtn

        info.text = "玩家[00FF00]" .. data[index+1].nick .. "[-]邀请您一起进行地宫探险!"
        time.text = data[index+1].time
        btnR.param = data[index+1]
        btnA.param = data[index+1]
        return true
    end

    return false
end

function PopGveInvite.ClickRefuse(d)
    local info = d
    SVR.GveInvite(info.psn, 1, info.tsn, function(result)
        if result.success then
            PopGveInvite.OnDispose()
            Refresh()
        end
    end)
end

function PopGveInvite.ClickAgree(d)
    if not user.IsGveUL then ToolTip.ShowPopTip("地宫探险需主城" .. DB.unlock.explorer .. "级开放!") return end
    local info = d
    SVR.GveInvite(info.psn, 2, info.tsn, function(result)
        if result.success then
            local dat = SVR.datCache
            Win.Open("WinTeam", dat)
            MainUI.CheckInvBtn()
            _body:Exit()
        else
            Refresh()
        end
    end)
end

function PopGveInvite.OnDispose()
    if grid.transform.childCount > 0 then grid:DesAllChild() end
end

function PopGveInvite.OnUnLoad()
    _body = nil
end
