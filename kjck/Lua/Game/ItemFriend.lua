local _item =
{
    go = nil,
    dat = nil,
    avatar = nil,
    level = nil,
    background = nil,
    pyName = nil,
    status = nil,
    vip = nil,
    ally = nil
}

function _item.New(go)
    assert(not tolua.isnull(go), "go is not gameobject")
    return
    {
        go = go,
        dat = nil,
        avatar = go:ChildWidget("icon"),
        level = go:ChildWidget("level"),
        background = go.widget,
        pyName = go:ChildWidget("name"),
        status = go.transform:FindChild("level"):ChildWidget("status"),
        vip = go:ChildWidget("vip"),
        ally = go:ChildWidget("ally")
    }
end

function _item:Init(data)
    self.dat = data
    self.pyName.text = data.nick
    self.level.text = L("主城等级:") .. data.hlv
    self.vip.text = "VIP" .. data.vip
    self.vip.cachedGameObject:SetActive(data.vip>0)
    self.ally.text = string.isEmpty(data.allyName) and "" or L("所属联盟:")..data.allyName
end

objext(_item)

ItemFriend = _item