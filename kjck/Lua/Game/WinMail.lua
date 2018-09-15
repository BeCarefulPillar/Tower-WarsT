local Destroy = UnityEngine.Object.Destroy
local tolua = tolua
require "Game/ItemMail"

-- [Comment]
-- 邮件
WinMail = { }
local self = WinMail
local _ref = nil
local _detlaTm = nil

function WinMail.OnLoad(c)
    WinBackground(c, {n = "邮件", k = WinBackground.BG, i = true})
    self.body = c
    _ref = self.body.nsrf.ref

    c:BindFunction("OnInit", "OnWrapGridInitItem", "Refresh", "OnDispose", "OnWrapGridRequestCount")

    self.item_mail = _ref.item_mail
    self.item_goods = _ref.item_goods
    self.grid = _ref.scrollView:GetCmp(typeof(UIWrapGrid))
    self.contentView = _ref.contentView
    self.goodsGrid = _ref.goodsGrid
    self.target = _ref.target
    self.content = _ref.content

    self.targetLab = _ref.targetLab

    self.contentOpt = _ref.contentOpt
    self.btnDelAll = _ref.btnDeleteAll
    self.btnRecAll = _ref.btnReceiveAll
    self.btnReply = _ref.btnReply
    self.btnOption = _ref.btnOption
    self.btnWrite = _ref.btnWrite
    self.btnFriend = _ref.btnFriend

    self.btnRecAll:SetClick(self.ClickRecAll)
    self.btnDelAll:SetClick(self.ClickDelAll)
    self.btnReply:SetClick(self.ClickReply)
    self.btnOption:SetClick(self.ClickOption)
    self.btnWrite:SetClick(self.ClickWrite)
    self.btnFriend:SetClick(self.ClickFriend)
    self.contentOpt:SetClick(self.PressContent)

    self.init = false
    self.changed = true
    self.isLoading = false
    self.mails = { }
    self.selected = nil
end

-- [Comment]
-- 初始参数 int:指定好友SN
function WinMail.OnInit()
    self.Refresh()

    self.btnFriend:SetActive(self.selected ~= nil)
    local fsn = type(self.initObj) == "number" and self.initObj or 0


    -- 指定好友
    if fsn > 0 then
    elseif type(self.initObj) == "string" then
        print(self.initObj)
        self.target.value = self.initObj
    end

    if not self.gridTexture then self.gridTexture = GridTexture() end

end

function WinMail.OnWrapGridRequestCount()
    if self.grid.realCount == #self.mails then
        if not self.isLoading and self.changed then
            self.RefreshData()
            return true
        end
        return false
    end
    self.grid.realCount = #self.mails
    return true
end

function WinMail.RefreshData()
    if _detlaTm and _detlaTm > Time.realtimeSinceStartup then return end
    _detlaTm = Time.realtimeSinceStartup + 0.05
    self.isLoading = true
    local curCnt = self.mails and #self.mails or 0
    SVR.PlayerMessage("lst|" ..(curCnt > 0 and self.mails[curCnt].sn or 0), "pri", function(result)
        if result.success then
            local res = SVR.datCache
            table.AddNo(self.mails, res, "sn")
            self.changed = #self.mails ~= self.grid.realCount
            if self.changed then self.grid.realCount = #self.mails end
            if not self.init then
                self.init = true
                self.grid:Reset()
            end
        end
        self.isLoading = false
    end )
end

function WinMail.OnWrapGridInitItem(item, index)
    if not self.mails or tolua.isnull(item) or index < 0 or index >= #self.mails then
        return false
    end

    local im = ItemMail(item)
    im.onClick = self.ClickItem
    im.onDelte = self.ClickDeleteItem
    im:Init(self.mails[index + 1])

    return true
end

function WinMail.ClickItem(im)
    if self.selected ~= im then
        if self.selected then
            self.selected.Selected = false
        end
        self.selected = im
        if not self.selected then
            self.selectMsg = nil
        else
            self.selectMsg = im.Mail
            table.print("", self.selectMsg)
            if self.selectMsg.isNew == 1 then
                SVR.PlayerMessage("see|" .. self.selectMsg.sn, "", function(result)
                    if result.success then
                        self.selectMsg.isNew = 0
                        user.newMsgNum = user.newMsgNum - 1
                        self.UpdateMaildata(self.selectMsg)
                        if user.newMsgNum <= 0 then
                            user.changed = true
                        end
                        if self.selected then
                            self.selected.Mail = self.selectMsg
                            self.selected.Selected = true
                        end
                    end
                end )
            end

            self.selected.Selected = true


            self.targetLab.text = L("发件人")
            self.target.value = self.selected.Mail.nick
            self.target.enabled = false
--            self.content.gameObject:SetActive(false)
            local cl = self.content.characterLimit
            self.content.characterLimit = 0
            if user.IsSystemUser(self.selected.Mail.psn) then
                self.content.label.supportEncoding = true
                self.content.value = self.selected.Mail.msg
            else
                self.content.label.supportEncoding = false
                self.content.value = self.selected.Mail.msg
            end

            self.content.characterLimit = cl
            self.contentView:ConstraintPivot(UIWidget.Pivot.Top, false)

            self.btnWrite.text = L("写 信")
            self.btnWrite.transform.localPosition = Vector3(324, -275, 0)
            self.btnReply.gameObject:SetActive(true)
            self.btnReply.transform.localPosition = Vector3(495, -275, 0)

            self.ClearGoods()

            if self.selected.Mail.rws then
                local len = #self.selected.Mail.rws
                if len > 0 then
                    self.goods = { }
                    for i = 1, len do
                        local ig = ItemGoods(self.goodsGrid:AddChild(self.item_goods, string.format("goods_%02d", i)))
                        self.goods[i] = ig
                        ig:Init(self.selected.Mail.rws[i])
                        if ig.dat then
                            self.gridTexture:Add(ig.imgl)
                            ig.go.transform.localScale = Vector3(0.8, 0.8, 0.8)
                            ig:HideName()
                        else
                            if not tolua.isnull(ig.go) then
                                Destroy(ig.go)
                            end
                        end
                    end

                    self.goodsGrid:GetCmp(typeof(UIGrid)):Reposition()
                end
                self.btnOption.gameObject:SetActive(len > 0)
                self.btnOption.text = L("提取附件")
                self.btnOption.transform.localPosition = Vector3(151, -275, 0)
            else
                self.btnOption.gameObject:SetActive(false)
            end
        end
        self.btnFriend:SetActive(self.selected ~= nil)
    end
end

function WinMail.OnClickItem(im, tm)
    coroutine.wait(tm)
    self.ClickItem(im)
end

function WinMail.ClickGoods()
end

function WinMail.ClearGoods()
    if self.goods then
        self.goodsGrid.transform:DetachChildren()
        for i = 1, #self.goods do
            if self.goods[i] then
                Destroy(self.goods[i].go)
            end
        end
        self.goods = nil
    end
end

function WinMail.UpdateMaildata(data)
    for i = 1, #self.mails do
        if self.mails[i].sn == data.sn then
            self.mails[i] = data
            break
        end
    end
end

function WinMail.ClickDeleteItem(im)
    if not im and im.Mail.sn <= 0 then
        return
    end

    -- 删除消息
    SVR.PlayerMessage("del|" .. im.Mail.sn, "pri", function(result)
        if result.success then
            ToolTip.ShowPopTip(L("删除成功!"))
            if im.Mail.isNew == 1 then
                user.newMsgNum = user.newMsgNum - 1
                if user.newMsgNum <= 0 then
                    user.changed = true
                end
            end

            local dx = table.find(self.mails, im.Mail)

            if dx ~= 0 then
                table.remove(self.mails, dx)
                self.grid:Remove(dx - 1)

                if dx <= #self.mails then
                    coroutine.start(self.OnClickItem, Item.Get(self.grid:GetItem(dx - 1)), 0.2)
                else
                    self.ToWrite()
                end
            end
        end
    end )
end

function WinMail.OnDispose()
    if self.onGetAtt then
        coroutine.stop(self.onGetAtt)
        self.onGetAtt = nil
    end

    _detlaTm = nil
    self.init = false
    self.changed = true
    self.isLoading = false
    self.mails = { }
    self.selectMsg = nil

    if self.gridTexture then
        self.gridTexture:Dispose()
    end

    self.ClickWrite()

    self.grid.gameObject:DesAllChild()
end

function WinMail.Refresh()
    self.OnDispose()
    self.RefreshData()
end

function WinMail.ClickDelAll()
    if #self.mails <= 0 then return end

    local flag = false
    for _, v in pairs(self.mails) do
        print(kjson.print(v))
        local len = #v.rws
        if v.isNew == 0 and len <= 0 then flag = true break end
    end

    if flag then
        MsgBox.Show(L("确定删除所有已读且没有附件的邮件?"), L("取消,确定"), function(bid)
            if bid == 1 then
                SVR.PlayerMessage("del|0", "pri", function(result)
                    if result.success then
                        ToolTip.ShowPopTip(L("删除成功!"))
                        Invoke(self.Refresh, 0.2)
                    end
                end )
            end
        end )
    else
        ToolTip.ShowPopTip(L("没有可删除的邮件,请先领取附件中的奖励!"))
    end
end

local function GetRewards(rws)
    print(kjson.print(rws))
    for i=1, #rws do
        user.SyncReward(rws[i])
    end
end

function WinMail.ClickRecAll()
    if #self.mails <= 0 then return end

    local flag = false
    for _, v in pairs(self.mails) do
        if #v.rws > 0 then flag = true break end
    end

    if flag then
        SVR.GetMsgAtt1K(0, function(result)
            if result.success then
                local dat = SVR.datCache
                local maxCnt = 21
                local cnt = math.ceil(#dat/maxCnt)
                local tmp = {}
                for i=1, cnt do
                    local start = (i-1) * maxCnt + 1
                    if i == cnt then maxCnt = #dat - start + 1 end
                    tmp[i] = {}
                    for j=1, maxCnt do
                        local t = dat[start + j - 1]
                        table.insert(tmp[i], t)
                    end
                end
                coroutine.start(GetRewards, tmp)
                Invoke(self.Refresh, 0.2)
            end
        end)
    end
end

function WinMail.ClickReply()
    if self.selectMsg and self.selectMsg.sn <= 0 then
        return
    end
    self.ToWrite()
end

function WinMail.ClickOption()
    if self.selectMsg and self.selectMsg.sn > 0 then
        if self.selectMsg.rws then
            SVR.GetMsgAtt(self.selectMsg.sn, function(result)
                if result.success then
                    local dat = SVR.datCache
                    user.SyncReward(dat)
                    self.selectMsg.rws = nil
                    self.UpdateMaildata(self.selectMsg)
                    if self.selected then self.selected.dat = self.selectMsg end
                    self.ClearGoods()
                    self.btnOption:SetActive(false)
                    Invoke(self.Refresh, 0.2)
                end
            end)
        end
    else
        if string.isEmpty(self.target.value) or #self.target.value < 2 then
            ToolTip.ShowPopTip(L("请输入收信方名称!"))
        elseif string.isEmpty(self.content.value) then
            ToolTip.ShowPopTip(L("请输入信件内容!"))
        else
            -- 发送消息
            SVR.PlayerMessage("snm|" .. self.target.value .. "|" .. user.rsn, self.content.value, function(result)
                if result.success then
                    self.target.value = ""
                    self.content.value = ""
                    self.content.label.text = ""
                    self.content.label.color = Color(1, 1, 1, 1)
                    ToolTip.ShowPopTip(ColorStyle.Good(L("发送成功!")))
                end
            end )
        end
    end
end

function WinMail.OnGetAtt()
    local refresh = false
    local flag = true
    local t = 0
    while flag do
        t = Time.realtimeSinceStartup + CONFIG.TIME_OUT
        SVR.GetMsgAtt1k(0, function(result)
            if result.success then
                local res = SVR.datCache
                if #res < 5 then
                    t = 0
                    flag = false
                else
                    t = 1 + t - CONFIG.TIME_OUT
                end
                if not refresh then
                    refresh = #res >= 1
                end
            else
                flag = false
            end
        end )
        while t > Time.realtimeSinceStartup do
            coroutine.step(1)
        end
    end
    if refresh then
        SVR.UpdateUserInfo()
        self.Refresh()
    end
end

function WinMail.ToWrite(name)
    name = name or ""

    self.targetLab.text = L("收件人:")

    self.target.value = ""
    self.target.label.text = ""
    self.target.label.color = Color(1, 1, 1, 1)

    self.content.value = ""
    self.content.label.text = ""
    self.content.label.color = Color(1, 1, 1, 1)

    self.target.enabled = true
    self.content.gameObject:SetActive(true)
    self.content.label.supportEncoding = false
    if self.selectMsg and self.selectMsg.sn > 0 then
        self.target.value = self.selectMsg.nick
        self.ClickItem(nil)
    end
    self.ClearGoods()
    self.btnReply.gameObject:SetActive(false)
    self.btnOption.gameObject:SetActive(true)
    self.btnOption.transform.localPosition = Vector3(495, -275, 0)
    self.btnOption:GetComponentInChildren(typeof(UIButton)).isEnabled = true
    self.btnOption:GetComponentInChildren(typeof(UILabel)).text = L("发送")
    self.btnWrite.text = L("重写")
    self.btnWrite.transform.localPosition = Vector3(324, -275, 0)

    if string.notEmpty(name) then
        self.target.value = name
    end
end

function WinMail.ClickWrite()
    self.ClickItem(nil)
    self.ToWrite()
end

function WinMail.ClickFriend()
    if self.selectMsg.sn <= 0 then return end

    SVR.FriendOption(self.selectMsg.psn, "", "add", function(result)
        if result.success then
            ToolTip.ShowPopTip(string.format(L("添加好友%s成功"), ColorStyle.Blue(self.selectMsg.nick)))
        end
    end)
end

function WinMail.PressContent(isPress)
    print(isPress)
end