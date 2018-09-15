local Destroy = UnityEngine.Object.Destroy
local string = string

local _item =
{
    go = nil,
    dat = nil,
    background = nil,
    time = nil,
    mark = nil,
    read = nil,
    content = nil,
    playerName = nil,
    btnDelete = nil,
    isSelected = nil,
    onClick = nil,
    onDelte = nil,
}

function _item.New(go)
    assert(not tolua.isnull(go), "create ItemMail need GameObject")
    return
    {
        go = go,
        dat = nil,
        background = go.widget,
        time = go:ChildWidget("time"),
        mark = go:Child("mark",typeof(UIGrid)),
        read = go:Child("read", typeof(UISprite)),
        playerName = go:ChildWidget("name"),
        content = go:ChildWidget("content"),
        btnDelete = go:Child("btn_delete",typeof(LuaButton)),
        isSelected = false,
        onClick = nil,
        onDelte = nil,
    }
end

function _item:Init(mail)
    self.dat = mail

    self.btnDelete:SetClick(self.ClickDelete, self)
    local bt = self.go:GetCmp(typeof(LuaButton))
    bt:SetClick(self.onClick, self)
--    bt:SetPress(self.OnPress, self)

    self.btnDelete:GetCmp(typeof(UIButton)).defaultColor = Color(1, 1, 1, 1)

    self.time.text = mail.tm
    self.playerName.text = mail.nick
    self.content.text = utf8.len(mail.msg) > 14 and string.sub(mail.msg,1,24) .."...." or mail.msg

    local sp = self.mark.transform:FindChild("mark_0")
    if mail.isNew == 1 then
        self.read.spriteName = "sp_status_3"
    elseif mail.isNew == 0 then
        self.read.spriteName = ""
    elseif sp then
        Destroy(sp.gameObject)
    end

    sp = self.mark.transform:FindChild("mark_1")

    if #mail.rws > 0 then
        if not sp then
            self:BuildMark("mark_1", "btn_m_gift")
        end
    elseif sp then
        Destroy(sp.gameObject)
    end
    self.mark:Reposition()
end

--function _item.OnPress(isPress, i)
--    if not i.Selected then
--        i.background.spriteName = isPress and "btn_09" or "btn_08"
--    end
--end

function _item:OnClick()
    if self.onClick then
        self.onClick(self)
    end
end

_item.__get =
{
    Selected = function(i) return i.isSelected end,
    Mail = function(i) return i.dat end
}

_item.__set =
{
    Selected = function(i, v)
        i.isSelected = v
        i.background.spriteName = i.isSelected and "btn_09" or "btn_08"
    end,
    Mail = function(i, v)
        if v.sn > 0 then
            i:Init(v)
        end
    end
}

function _item:CliclAddFriend()
    if self.dat.sn <= 0 then
        return
    end

    -- 添加好友
    SVR.FriendOption(self.dat.psn, "", "add", function(result)
        if result.success then
            ToolTip.ShowPopTip(string.format(L("已将%s添加为好友!", ColorStyle.Blue(self.dat.nick))))
        end
    end )
end

function _item:ClickDelete()
    if self.dat.rws ~= nil then
        local r = self.dat.rws
        if #r > 0 then MsgBox.Show("请先领取附件中的奖励后再删除邮件!")
        else
            if self.onDelte then
            self.onDelte(self)
        end
        end
    else
        if self.onDelte then
            self.onDelte(self)
        end
    end
end

function _item:BuildMark(name, spname)
    local sp = self.mark.gameObject:AddWidget(typeof(UISprite), name)
    sp.atlas = self.background.atlas
    sp.spriteName = spname
    sp.width = 48
    sp.height = 44
    sp.depth = 5
end

objext(_item, Item)

ItemMail = _item