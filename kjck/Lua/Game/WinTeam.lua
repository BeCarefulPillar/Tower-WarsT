WinTeam = { }

local _body = nil
WinTeam.body = _body

local t = typeof(UIButton)

--预制件的引用
local _ref
--队伍成员的显示Item
local items

--自动匹配按钮
local btnAuto 
--邀请好友按钮
local btnInv
--招募按钮
local btnRecru
--开始/准备按钮
local btnOpt

--队伍数据
local data
local match = 3
local gsn
local flag

local function BuildItems(refresh)
    flag = user.psn == data.leader and 0 or 6
    gsn = data.tsn
    local member = data.member
    if refresh then
        for i=1, #items do
            local it = items[i]
            it:ChildWidget("name").text = L("点击邀请好友")
            it:ChildWidget("close"):SetActive(false)
            it:ChildWidget("strength"):SetActive(false)
            it:ChildWidget("level"):SetActive(false)
            it:ChildWidget("leader"):SetActive(false)
            it:ChildWidget("icon"):UnLoadTex(false)
            it:ChildWidget("add"):SetActive(true)
            it:ChildWidget("idle").text = ""
            btnAuto:GetCmp(t).isEnabled = true
            btnAuto:ChildWidget("lab_auto").text = match == 3 and L("自动匹配") or L("取消匹配")
            local herolab = it:ChildWidget("heroLab")
            herolab:SetActive(false)
            local grid = herolab:GetCmpInChilds(typeof(UIGrid))
            if grid.transform.childCount > 0 then grid:DesAllChild() end
        end
    end

    if #member > 0 then
        for i=1, #member do
            local it = items[i]
            local p = member[i]

            local name = it:ChildWidget("name")
            local strength = it:ChildWidget("strength")  
            local lv = it:ChildWidget("level")
            local leader = it:ChildWidget("leader")
            local btn = it:ChildWidget("close")
            it:ChildWidget("icon"):LoadTexAsync(ResName.PlayerRole(p.ava))
            it:ChildWidget("idle").text = p.status == 1 and "[00FF00]已准备[-]" or ""
            it:ChildWidget("add"):SetActive(false)

            name.text = p.nick
            strength:SetActive(true)
            strength.text = L("实力:") .. p.pow 
            lv.text = L("LV:") .. p.hlv
            lv:SetActive(true)
            leader:SetActive(data.leader > 0 and (data.leader == p.psn) or false)
            btn:SetActive(data.leader > 0 and p.psn ~= data.leader and p.psn ~= tonumber(user.psn) or false)
            btn.luaBtn.param = p.psn

            local opt = btnOpt:ChildWidget("Label")

            if data.leader == p.psn then opt.text = L("开始")
            elseif tonumber(user.psn) == p.psn then
                if p.status == 1 then opt.text = L("取消准备")
                elseif p.status == 0 then opt.text = L("准备") end
            end

            local heros = p.hsn
            local herolab = it:ChildWidget("heroLab")
            herolab:SetActive(true)
            local grid = herolab:GetCmpInChilds(typeof(UIGrid))
            if #heros > 0 then
                herolab:ChildWidget("Label").text = ""

                for j=1, #heros do
                    local dbsn = heros[j]
                    local go = grid:AddChild(_ref.heroHead, "hero_"..j)
                    go:GetCmpInChilds(typeof(UITexture)):LoadTexAsync(ResName.HeroIcon(dbsn))
                    go:SetActive(true)
                end
                grid.repositionNow = true
            else
                herolab:ChildWidget("Label").text = L("暂时无常用将领")
            end
        end

        if data.leader > 0 and #member > 1 then btnAuto:GetCmp(t).isEnabled = false end
        if match == 4 and #member == 3 then
            SVR.GveEnter(function(result)
                if result.success then
                    ToolTip.ShowPopTip("自动匹配完成,进入地宫")
                    local res = SVR.datCache
                    Win.Open("WinExplorer", res)
                    _body:Exit()
                end
            end)
        end
    end
end

--新消息
local _onNewChat = UpdateBeat:CreateListener(function()
    if _chatPop and _body.activeSelf and PopChat == nil or not PopChat.isOpen and #user.chats > 0 then
        local d = user.chats[#user.chats]
        _chatPop.color = ColorStyle.Chat(d.chn)
        _chatPop.text = "[" .. ChatChn.Name(d.chn) .. "]" .. (d.nick and d.nick ~= "" and d.nick .. ":" or "") .. (d.text or "")
        EF.FadeIn(_chatPop, 0.3)
        if _cahtPopIvk then
            _cahtPopIvk:Reset(nil, 3)
        else
            _cahtPopIvk = Invoke(function() EF.FadeOut(_chatPop, 0.3) end, 3)
        end
    end
end)

local function UpdateData(d)
    data = d
    BuildItems(true)
end
WinTeam.UpdateData = UpdateData

function WinTeam.OnLoad(c)
    _body = c
    _ref = _body.nsrf.ref
    WinBackground(c, { n = "地宫探险", r = DB_Rule.GVERule})

    _chatPop = _ref.chatPop
    items = _ref.items
    btnAuto = _ref.btnAuto
    btnRecru = _ref.btnRecruit
    btnOpt = _ref.btnGo

    c:BindFunction("OnInit", "ClickAtuoMatch", "KnickMember", "InviteMember", "ClickRecruit",
                    "ClickChat","ClickOpt", "ClickLeave", "OnDispose", "OnUnLoad")

    OnNewChat:AddListener(_onNewChat)
end

function WinTeam.OnInit()
    local o = WinTeam.initObj
    if o ~= nil and type(o) == "table" then
        data = o
        BuildItems(true)
    end
end

--点击自动匹配
function WinTeam.ClickAtuoMatch()
    if match == 3 then
        SVR.GveMatch(match, 0, function(result)
            if result.success then
                match = 4
                data = SVR.datCache
                local mb = data.member
                btnOpt:GetCmp(t).isEnabled = #mb == 3
                btnRecru:GetCmp(t).isEnabled = false

                BuildItems(true)
            end
        end)
    elseif match == 4 then
        SVR.GveMatch(match, 0, function(result)
            if result.success then
                match = 3
                data = SVR.datCache
                btnOpt:GetCmp(t).isEnabled = true
                btnRecru:GetCmp(t).isEnabled = true

                BuildItems(true)
            end
        end)
    end

    
end

--聊天
function WinTeam.ClickChat()
    Win.Open("PopChat")
end
--踢人
function WinTeam.KnickMember(m)
    local psn = m
    SVR.GveMatch(5, psn, function(result)
        if result.success then
            data = SVR.datCache
            BuildItems(true)
        end
    end)
end
--邀请
function WinTeam.InviteMember()
    if match == 4 then ToolTip.ShowPopTip("自动匹配中不能进行邀请好友操作!")  return end
    Win.Open("PopFriendForGve", data)
end
--招募
function WinTeam.ClickRecruit()
    MsgBox.Show("聊天功能未完成")
end
--检查准备状态
local function CheckUnReady()
    local unReady ={}
    local mem = data.member
    for i=1, #mem do
        local m = mem[i]
        if m.status == 0 then table.insert(unReady, m) end
    end
    return #unReady <= 0
end
--开始
function WinTeam.ClickOpt()
    local leader = data.leader
    if leader > 0 then
        if tonumber(user.psn) == leader then
            if CheckUnReady() then
                MsgBox.Show("确定开始地宫探秘?", "取消,确定", function(bid)
                    if bid == 1 then
                        SVR.GveCreate(gsn, function(result)
                            if result.success then
                                ToolTip.ShowPopTip("进入地宫")
                                local res = SVR.datCache
                                Win.Open("WinExplorer", res)
                                _body:Exit()
                            end
                        end)
                    end
                end)
            else
                ToolTip.ShowPopTip("还有队友未准备,请稍等")
            end
        else
            local mem = data.member
            local m  
            for i=1, #mem do
                if mem[i].psn == tonumber(user.psn) then m = mem[i] end
            end
            if m.status == 0 then
                SVR.GveMatch(6, data.tsn, function(result)
                    local dat = SVR.datCache
                    table.copy(dat, data)
                    BuildItems(true)
                    ToolTip.ShowPopTip("已准备")
                end)
            elseif m.status == 1 then
                SVR.GveMatch(7, data.tsn, function(result)
                    local dat = SVR.datCache
                    table.copy(dat, data)
                    BuildItems(true)
                    ToolTip.ShowPopTip("取消准备")
                end)
            end
        end
    end
end
--离队
function WinTeam.ClickLeave()
    MsgBox.Show("您正在地宫匹配队伍中,请确认是否退出队伍", "取消,确定", function(bid)
        if bid == 1 then 
            SVR.GveMatch(2, gsn, function(result) 
                if result.success then 
                    if not MainMap.isOpen then Win.Open("MainMap") end
                    _body:Exit() 
                else 
                    result.hideErr = true
                    if not MainMap.isOpen then Win.Open("MainMap") end
                    _body:Exit()
                end
            end)
        end
    end)
end

function WinTeam.OnDispose()
    match = 3

    for i=1, #items do
        local it = items[i]
        it:ChildWidget("name").text = "点击邀请好友"
        it:ChildWidget("close"):SetActive(false)
        it:ChildWidget("strength"):SetActive(false)
        it:ChildWidget("level"):SetActive(false)
        it:ChildWidget("leader"):SetActive(false)
        it:ChildWidget("icon"):UnLoadTex(false)
        it:ChildWidget("idle").text = ""
        local herolab = it:ChildWidget("heroLab")
        herolab:SetActive(false)
        local grid = herolab:GetCmpInChilds(typeof(UIGrid))
        if grid.transform.childCount > 0 then grid:DesAllChild() end
    end

    btnRecru:GetCmp(t).isEnabled = true
    btnOpt:GetCmp(t).isEnabled = true
    btnAuto:GetCmp(t).isEnabled = true
    btnAuto:ChildWidget("lab_auto").text = "自动匹配"
end

function WinTeam.OnUnLoad()
    _body = nil
end

