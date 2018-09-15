PopFriendForGve = { }

local _body = nil
PopFriendForGve.body = _body

local tabs
local btnFriend
local btnAlly
local grid
local _ref
local team
local data = { }
local opt = nil
local isOver = false
local isLoading = true
local change = true
local deltaTime = 0
local TabColorHightLight = Color(1, 1, 1, 1)
local TabColorNormal = Color(140/255, 157/255, 179/255, 1)

local function RefreshData(opt)
    if deltaTime > Time.realtimeSinceStartup then
        return
    end
    deltaTime = Time.realtimeSinceStartup + 0.2

    isLoading = true
    SVR.GveFriendList(opt, 1 + math.toint(#data/10), function(result)
        if result.success then
            local res = SVR.datCache
            table.AddNo(data, res, "psn")
            isOver = #res < 10
            if change then 
                change = false
                grid:Reset()
            end
            grid.realCount = #data
        end
        isLoading = false
    end)
end

function PopFriendForGve.OnLoad(c)
    _body = c
    local gos = c.gos
    grid = gos[0]:GetCmp(typeof(UIWrapGrid))

    local btns = c.btns
    btnFriend = btns[0]
    btnAlly = btns[1]

    c:BindFunction("OnInit", "ClickFriend", "ClickAllyMember", "OnWrapGridInitItem", "OnWrapGridRequestCount", 
                   "ClickItem", "OnDispose","OnUnLoad")
end

function PopFriendForGve.OnInit()
    local o = PopFriendForGve.initObj
    if o ~= nil and type(o) == "table" then
        team = o
        PopFriendForGve.ClickFriend()
    end
end

function PopFriendForGve.OnWrapGridInitItem(item, index)
    if item and index < #data then
        local ava = item:ChildWidget("icon")
        local name = item:ChildWidget("name")
        local lv = item:ChildWidget("level")
        local status = item:ChildWidget("online")
        local ally = item:ChildWidget("ally")
        local vip = item:ChildWidget("vip")
        local btn = item:ChildWidget("btn_inviFriend").luaBtn

        ava:LoadTexAsync(ResName.PlayerIcon(data[index+1].ava))
        name.text = data[index+1].nick
        lv.text = L("主城等级:") .. data[index+1].hlv
        ally.text = data[index+1].allyName == "" and "" or L("所属联盟:") .. data[index+1].allyName
        vip.text = data[index+1].vip > 0 and "vip" .. data[index+1].vip or ""
        status.text = data[index+1].online > 1 and "[FF0000]离线[-]" or "[00FF00]在线[-]"
        btn.param = data[index+1].psn
        btn.gameObject:GetCmp(typeof(UIButton)).isEnabled = data[index+1].online < 2
        btn.gameObject:SetActive(data[index+1].psn ~= tonumber(user.psn))
        
        return true
    end
    return false
end

function PopFriendForGve.OnWrapGridRequestCount()
    if isOver then return false end
    if not isLoading then
        RefreshData(opt)
        return true
    end
    return false
end

function PopFriendForGve.ClickFriend()
    btnFriend:GetCmp(typeof(UIButton)).isEnabled = false
    btnFriend:ChildWidget("Label").color = TabColorHightLight
    btnAlly:GetCmp(typeof(UIButton)).isEnabled = true
    btnAlly:ChildWidget("Label").color = TabColorNormal
    opt = "fan"
    data = { }
    change = true

    RefreshData(opt)
end 

function PopFriendForGve.ClickAllyMember()
    btnFriend:GetCmp(typeof(UIButton)).isEnabled = true
    btnFriend:ChildWidget("Label").color = TabColorNormal
    btnAlly:GetCmp(typeof(UIButton)).isEnabled = false
    btnAlly:ChildWidget("Label").color = TabColorHightLight
    opt = "gui"
    data = { }
    change = true

    RefreshData(opt)
end

function PopFriendForGve.ClickItem(sn)
    local psn = sn
    local tsn = team.tsn

    for i=1, #team.member do
        if psn == team.member[i].psn then
            ToolTip.ShowPopTip("该玩家已在队伍中")
            return
        end
    end
    SVR.GveInvite(psn, 0, tsn, function(result)
        if result.success then ToolTip.ShowPopTip("邀请成功") end
    end)
end

function PopFriendForGve.OnDispose()
    data = { }
    isOver = false
    isLoading = true
    change = true

    if grid.transform.childCount > 0 then grid:DesAllChild() end
end

function PopFriendForGve.OnUnLoad()
    _body = nil
end
