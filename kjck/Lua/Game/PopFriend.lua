local Animation = UnityEngine.Animation
require "Game/ItemFriend"

--[Comment]
--社交
PopFriend = { }
local self = PopFriend
local _ref = nil
local TabColorHightLight = Color(1, 1, 1, 1)
local TabColorNormal = Color(140/255, 157/255, 179/255, 1)

function PopFriend.OnLoad(c)
    WinBackground(c, {k = WinBackground.MASK})
    self.body = c
    _ref = self.body.nsrf.ref

    table.print("",user.BlackList)

    c:BindFunction("OnInit","OnWrapGridInitItem","OnDispose","OnWrapGridRequestCount")

    self.item_friend = _ref.item_friend
    self.item_blackList = _ref.item_blackList
    self.option = _ref.option
    self.grid = _ref.scrollView
    self.iptName = _ref.iptName

    --self.grid:Reset()
    --self.grid.realCount = 0

    self.btnAddFriend = _ref.btnAddFriend
    self.btnMail = _ref.btnMail
    self.btnChat = _ref.btnChat
    self.btnLocation = _ref.btnLocation
    self.btnGift = _ref.btnGift
    self.btnDel = _ref.btnDel
    self.btnTabs = _ref.btnTabs

    -- [Comment]
    -- 好友列表的查看方式 0=好友 1=仇人 2=黑名单
    self.view = -1
    self.isLoading = false
    self.isInit = true
    self.isSelecting = false
    self.isOver = false
    self.deltaTime = 0
    self.datas = {}

    -- self.btnClose:SetClick(function() self.body:Exit() end)
    self.btnAddFriend:SetClick(self.ClickAddFriend)
    self.btnMail:SetClick(self.ClickMail)
    self.btnChat:SetClick(self.ClickChat)
    self.btnLocation:SetClick(self.ClickLocation)
    self.btnGift:SetClick(self.ClickGift)
    self.btnDel:SetClick(self.ClickDelete)

    -- table.print("",user.blkList)

    for i = 1,#self.btnTabs do
        self.btnTabs[i]:SetClick(self.ClickTab, i)
    end
end

-- [Comment]
-- 初始参数 int: -1=邮件获取好友 0=好友列表 1=仇人列表 2=黑名单
function PopFriend.OnInit()
    if not self.gridTexture then
        self.gridTexture = GridTexture()
    end

    local iv = type(self.initObj)=="int" and self.initObj or 0
    self.view = -1
    self.ChangeView(iv < 0 and 0 or iv)
end

function PopFriend.ChangeView(v)
    v = v or 0

    if self.isLoading then
        return
    end

    self.ClearSelected()
    self.isInit = true
    self.isOver = false
    if self.view ~= v then
        self.view = v
        self.option.transform.parent = self.body.transform
        for i = 1,#self.btnTabs do
            self.btnTabs[i]:GetCmp(typeof(UIButton)).isEnabled = self.view ~= (i-1)
            self.btnTabs[i]:ChildWidget("Label").color = self.view ~= (i-1) and TabColorNormal or TabColorHightLight
        end
    end

    if v == 0 or v == 1 then
        self.datas = { }
        self.grid.itemPrefab = self.item_friend
        self.grid.gridHeight = 140
        self.RefreshData()
    elseif v == 2 then
        self.grid.gridHeight = 70
        self.grid:Reset()
        self.grid.realCount = 0
    else
        self.datas = { }
    end
end

function PopFriend.OnWrapGridInitItem(item, readIndex)
    if item and readIndex >= 0 then

        if self.view == 2 then
            -- 初始化黑名单
        elseif readIndex < #self.datas then
            -- 初始化好友或仇人
            local iFrd = ItemFriend(item)
            if iFrd then
                iFrd:Init(self.datas[readIndex + 1])
                iFrd.go:GetCmp(typeof(LuaButton)):SetClick(self.ClickItem, iFrd)
                --self.gridTexture:Add()
                iFrd.avatar:LoadTexAsync(ResName.PlayerIcon(iFrd.dat.ava))
            end
            local op = item.transform:Find("option")
            if op then
                self.ClearSelected()
            end
            return true
        end
    end
    return false
end

function PopFriend.RefreshData()
    if self.deltaTime>Time.realtimeSinceStartup then
        return
    end
    self.deltaTime=Time.realtimeSinceStartup+0.2

    if self.view == 0 then
        opt = "fan"
    elseif self.view == 1 then
        opt = "foe"
    else
        return
    end

    self.isLoading = true

    SVR.PlayerList(opt, 1 + math.toint(#self.datas / 10), function(result)
        if result.success then
            local res = SVR.datCache
            self.isLoading = #res == 0
            table.AddNo(self.datas, res, "psn")
            self.isOver = #res < 10
            if self.isInit then
                self.isInit = false
                self.grid:Reset()
            end
            self.grid.realCount = #self.datas
        end
        self.isLoading = false
    end )
end

function PopFriend.ClearSelected()
    local anim = self.option:GetCmp(typeof(UnityEngine.Animation))
    if anim and anim.clip then
        anim:get_Item(anim.clip.name).time = 0
        anim:Sample()
    end
    self.option.gameObject:SetActive(false)
    self.selected = nil
end

function PopFriend.OnDispose()
    self.view = -1
    self.isLoading = false
    self.isSelecting = false
    self.isInit = true
    self.isOver = false
    self.option.transform.parent = self.body.transform

    if self.gridTexture then
        self.gridTexture:Dispose()
    end
    self.ClearSelected()
end

function PopFriend.ClickTab(i)
    self.ChangeView(i-1)
end

function PopFriend.OnWrapGridRequestCount(grid)
    if self.view ~= 2 then
        if self.isOver then
            return false
        end
        if not self.isLoading then
            self.RefreshData()
            return true 
        end
        return false
    end
    return false
end

function PopFriend.ClickAddFriend()
    if string.isEmpty(self.iptName.value) then
        return
    end

    -- 添加好友
    SVR.FriendOption(0, self.iptName.value, "add", function(result)
        if result.success then
            ToolTip.ShowPopTip(L("添加成功!"))

            self.iptName.value= ""
            self.isInit = true
            self.RefreshData()
        end
    end )
end

function PopFriend.ClickMail()
    if not self.selected then
        return
    end

    Win.Open("WinMail", self.selected.dat.nick)
end

function PopFriend.ClickChat()
    if not self.selected then
        return
    end
    local data = { psn = self.selected.dat.psn, name = self.selected.dat.nick}
    Win.Open("PopChat", data)
end

function PopFriend.ClickItem(item)
    if item and type(self.initObj)=="number" then
        if self.initObj==-1 then
            local win = Win.GetOpenWin("WinMail")
            if win then
                win.ToWrite(item.dat.nick)
                self.body:Exit()
                return
            end
        elseif self.initObj==-2 then
            local win = Win.GetOpenWin("PopGift")
            if win then
                win.SetTarget(item.dat.nick)
                self.body:Exit()
                return
            end
        end
    end

    self.selected = self.selected ~= item and item or nil
    coroutine.start(self.OnSelecting)
end

function PopFriend.OnSelecting()
    if self.isSelecting then
        return
    end

    self.isSelecting = true
    if self.option.gameObject.activeSelf then
        local ani = self.option:GetCmp(typeof(Animation))
         EF.PlayAni(ani,ani.clip.name, -1)
         while EF.AniIsPlaying(ani) do
            coroutine.step()
         end
    end

    if self.selected then
        self.option.transform.parent = self.selected.go.transform
        self.option.transform.localPosition = Vector3(375, 20, 0)
        self.option.gameObject:SetActive(true)
        local ani = self.option:GetCmp(typeof(Animation))
        EF.PlayAni(ani,ani.clip.name, 1)
    else
        self.ClearSelected()
    end

    self.isSelecting = false
end

function PopFriend.ClickLocation()
end

function PopFriend.ClickGift()
    if self.selected then
        Win.Open("PopGift", self.selected.dat.nick)
    end
end

function PopFriend.ClickDelete()
    if not self.selected then
        return
    end

    -- 删除好友
    local opt = ""
    if self.view == 0 then
        opt = "del"
    elseif self.view == 1 then
        opt = "foe|del"
    else
        return
    end

    SVR.FriendOption(self.selected.dat.psn, "", opt, function(result)
        if result.success then
            ToolTip.ShowPopTip(L("删除成功!"))
            self.option.transform.parent = self.body.transform

            local dx = table.find(self.datas, self.selected.dat)
            if dx~=0 then
                table.remove(self.datas, dx)
                self.grid:Remove(dx-1)
            end

            self.ClearSelected()
        end
    end )
end