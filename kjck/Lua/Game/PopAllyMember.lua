PopAllyMember = {}
local _body = nil
PopAllyMember.body = _body

local _ref = nil
local _grid = nil
local fri = nil

local _msgTtl = nil
local _msgPnl = nil
local _msgIpt = nil
local _btnSure = nil

local _isInit = nil
local _isOver = nil
local _isLoading = nil
local _hasRqt = nil
local _datas = nil
local _detlaTm = nil

local allyMember = -1

local function RefreshData()
    if _detlaTm and _detlaTm > Time.realtimeSinceStartup then return end
    _detlaTm = Time.realtimeSinceStartup + 0.03
    local pc = 10
    _isLoading = true
    SVR.GetAllyMemberList("usr", math.toint(#_datas / pc), function (r) 
        if r.success then
            local res = SVR.datCache.lst
            fri = SVR.datCache.friends
            _datas = table.AddNo(_datas, res, "psn")
            _isOver = #_datas == _grid.realCount
            if _isInit then _isInit = false _grid:Reset() end
            _grid.realCount = #_datas
        end
        isLoading = false 
    end)
end

local function UpdateAllyInfo()
    if not CheckSN(user.ally.gsn) then _body:Exit() return end

    if allyMember ~= user.ally.mqty then
        allyMember = user.ally.mqty
        _isInit = true
        _datas = { }
        RefreshData()
    end
end

function PopAllyMember.OnLoad(c)
    WinBackground(c, { k = WinBackground.MASK })
    _body = c
    _ref = _body.nsrf.ref
    table.print("_ref", _ref)

    c:BindFunction("OnInit", "OnWrapGridInitItem", "OnWrapGridRequestCount", "ClickPopupList",
                   "ClickBorrowHero", "ClickAddFriend", "ClickMsgCancel", "ClickMsgSure","OnDispose", "OnUnLoad")

    _grid = _ref.grid
    _msgPnl = _ref.msgpnl
    _msgTtl = _ref.msgtl
    _msgIpt = _ref.msgipt
    _btnSure = _ref.msgsure
end

function PopAllyMember.OnInit()
    UserAllyChange:Add(UpdateAllyInfo)
    _datas = { }
    _isInit = true
end

local function GetPermName(perm)
    if perm == 0 then return L("成员")
    elseif perm == 1 then return L("副盟主")
    elseif perm == 2 then return L("盟主") end
end

local function InitItem(i, d)
    local item = i
    local dat = d

    local tmp = item:GetCmpsInChilds(typeof(UILabel), false)
    tmp[0].text = dat.nick
    tmp[1].text = dat.hlv
    tmp[2].text = GetPermName(dat.perm)
    tmp[3].text = dat.renown
    tmp[4].text = dat.renownWeek
    tmp[5].text = dat.status == 1 and L("在线") or L("离线")
    tmp[5].color = dat.status == 1 and Color(94/255 ,191/255 ,97/255,1) or Color(122/255 ,135/255 ,147/255,1)

    if dat.status == 0 then
        tmp[0].color = Color(122/255 ,135/255 ,147/255,1)
        tmp[1].color = Color(122/255 ,135/255 ,147/255,1)
        tmp[2].color = Color(122/255 ,135/255 ,147/255,1)
        tmp[3].color = Color(122/255 ,135/255 ,147/255,1)
        tmp[4].color = Color(122/255 ,135/255 ,147/255,1)
    end
    
    local tp = typeof(LuaButton)
    local btnO = item:ChildWidget("btn_option", tp).luaBtn
    local btnB = item:ChildWidget("btn_borrowHero", tp).luaBtn
    if dat.psn == tonumber(user.psn) then
        btnO.param = nil
        btnO:SetActive(false)
        btnB.param = nil
        btnB:SetActive(false)
    else
        if dat.hlv < DB.unlock.tower or dat.status == 0 then
            btnB:GetCmp(typeof(UIButton)).isEnabled = false
        else
            if dat.hasBorrow == 0 then
                btnB:GetCmp(typeof(UIButton)).isEnabled = true
                btnB:SetClick("ClickBorrowHero", {item, dat.psn})
            else
                btnB:GetCmp(typeof(UIButton)).isEnabled = false
            end
        end

        local plist = btnO:GetCmp(typeof(UIPopupList))
        local wdt = btnO:GetCmp(typeof(UIWidget))
        local arrow = btnO:ChildWidget("arrow")
        local lbl = btnO:GetCmpInChilds(typeof(UILabel))
        if user.ally.myPerm == 2 then
            plist.enabled = true
            wdt.width = 128
            arrow:SetActive(true)
            lbl.text = L("管理成员")
            lbl.transform.localPosition = Vector3(-4,0,0)
            btnO:SetClick(nil ,dat)
            plist:Clear()
            if fri == nil then plist:AddItem(L("加为好友"))
            elseif not table.contains(fri, dat.psn) then plist:AddItem(L("加为好友")) end
            
            if dat.perm == 1 then
                plist:AddItem(L("转让盟主"))
                plist:AddItem(L("降为成员"))
            else plist:AddItem(L("升副盟主")) end
            plist:AddItem(L("踢出联盟"))
            plist.value = ""
        else
            plist.enabled = false
            wdt.width = 112
            arrow:SetActive(false)
            if fri == nil then 
                lbl.text = L("加为好友")
                btnO:GetCmp(typeof(UIButton)).isEnabled = true
            else
                if table.contains(fri, dat.psn) then 
                    lbl.text = L("已是好友")
                    btnO:GetCmp(typeof(UIButton)).isEnabled = false
                else
                    lbl.text = L("加为好友")
                    btnO:GetCmp(typeof(UIButton)).isEnabled = true
                end
            end
            lbl.transform.localPosition = Vector3.zero
            plist:Clear()
            btnO.param = {btnO, dat}
            btnO:SetClick("ClickAddFriend")
        end
        btnO:SetActive(true)
    end
end

function PopAllyMember.ClickBorrowHero(p)
    _msgTtl.text = L("借将")
    _msgIpt.value = ""
    _msgPnl:GetCmp(typeof(UIPanel)).alpha = 0.01
    EF.PlayAni(_msgPnl, "PopLiteIn", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DoNotDisable)
    _btnSure:SetClick(function(r)
        local it = r[1]
        local sn = r[2]
        local btn = it:ChildWidget("btn_borrowHero")
        PopAllyMember.ClickMsgCancel()
        SVR.AllyBorrowHero(sn, _msgIpt.value, function(result)
            if result.success then
                btn:GetCmp(typeof(UIButton)).isEnabled = false
                ToolTip.ShowPopTip("申请成功!")
            end
        end)
    end, p)
end

function PopAllyMember.OnWrapGridInitItem(grid, item, idx)
    if not _datas and isnull(item) or idx < 0 or idx > #_datas then return false end
    idx = idx + 1
    local dat = _datas[idx]
    InitItem(item, dat)
    return true
end

local function SetData(d)
    if _datas then
        for i = 1, #_datas do
            if _datas[i].psn == d.psn then _datas[i] = d end
        end
    end
end

function PopAllyMember.ClickPopupList()
    local plist = UIPopupList.current
    if plist == nil and plist.value == nil then return end
    local it = plist.transform.parent.gameObject
    local data = plist:GetCmp(typeof(LuaButton)).param
    if data and CheckSN(data.psn) ~= nil then
        if plist.value == "加为好友" then
            SVR.FriendOption(0, data.nick, "add", function (r) 
                if r.success then
                    ToolTip.ShowPopTip(ColorStyle.Blue(data.nick) .. L("已加为好友！"))
                end
            end)
        elseif plist.value == "转让盟主" then
            MsgBox.Show(string.format(L("你确定要将盟主之位转让给%s吗？"), ColorStyle.Blue(data.nick)), L("取消,确定"), function (bid) 
                if bid == 1 then
                    SVR.AllyOption("perm|"..data.psn.."|2", function (r) 
                        if r.success then
                            user.ally.myPerm = 1
                            user.ally.chief = data.nick
                            data.perm = 2
                            SetData(data)
                            if _datas ~= nil then
                                local d
                                for i = 1, #_datas do
                                    d = _datas[i]
                                    if d.psn == tonumber(user.psn) then
                                        d.perm = 1
                                        _datas[i] = d
                                        break
                                    end
                                end
                            end

                            _grid:Reset()
                        end 
                    end)
                end 
            end)
        elseif plist.value == "升副盟主" then
            SVR.AllyOption("perm|"..data.psn.."|1", function (r) if r.success then
                data.perm = 1
                SetData(data)
                InitItem(it, data)
                ToolTip.ShowPopTip(string.format(L("%s已经被提升为副盟主"), ColorStyle.Blue(data.nick)))
            end end)
        elseif plist.value == "降为成员" then
            SVR.AllyOption("perm|"..data.psn.."|0", function (r) if r.success then
                data.perm = 0
                SetData(data)
                InitItem(it, data)
                ToolTip.ShowPopTip(string.format(L("%s已经被降为普通成员"), ColorStyle.Blue(data.nick)))
            end end)
        elseif plist.value == "踢出联盟" then
            _msgTtl.text = string.format(L("将%s踢出联盟"), ColorStyle.Blue(data.nick))
            _msgPnl:GetCmp(typeof(UIPanel)).alpha = 0.01
            EF.PlayAni(_msgPnl, "PopLiteIn", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DoNotDisable)
            _btnSure:SetClick("ClickMsgSure", data)
        end
    end
    UIPopupList.current = nil
end

function PopAllyMember.ClickAddFriend(p)
    local btn = p[1]
    local dat = p[2]
    if CheckSN(dat.psn) ~= nil then
        SVR.FriendOption(0, dat.nick, "add", function(result) 
            if result.success then
                btn.isEnabled = false
                btn.text = L("已是好友")
                ToolTip.ShowPopTip(ColorStyle.Blue(dat.nick) .. L("已加为好友"))
            end
        end)
    end
end

function PopAllyMember.ClickMsgSure(p)
    if CheckSN(p.psn) ~= nil then
        SVR.AllyOption("kick|"..p.psn.."|"..DB.HX_Filter(_msgIpt.value), function(result)
            if result.success then
                user.ally.mqty = math.clamp(user.ally.mqty - 1, 1, user.ally.maxMqty)
                PopAllyMember.ClickMsgCancel()
                ToolTip.ShowPopTip(string.format(L("%s已经被踢出联盟"), ColorStyle.Blue(p.nick)))
            end
        end)
    end
end

function PopAllyMember.ClickMsgCancel()
    _btnSure.param = nil
    EF.PlayAni(_msgPnl, "PopLiteOut", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DisableAfterForward)
end

function PopAllyMember.OnWrapGridRequestCount(grid)
    if grid.realCount == #_datas then
        if not _isLoading and not _isOver then 
            RefreshData() 
            return true
        end
        return false
    end
    grid.realCount = #_datas
    return true
end

function PopAllyMember.OnDispose()
    _isInit = nil
    _isOver = nil
    _isLoading = nil
    _hasRqt = nil
    _datas = nil
    _detlaTm = nil
    UserAllyChange:Remove(UpdateAllyInfo)

    _grid:Reset()
end

function PopAllyMember.OnUnLoad()
    _body = nil
end
