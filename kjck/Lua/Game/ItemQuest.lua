local notnull = notnull

local _item =
{
    go = nil,
    bg = nil,
    questName = nil,
    content = nil,
    status = nil,
    sp_status = nil,
    dat = nil,
}

function _item.New(go)
    assert(notnull(go), "go is not gameobject")
    return {
        go = go,
        bg = go.widget,
        questName = go:ChildWidget("name"),
        content = go:ChildWidget("content"),
        status = go:ChildWidget("status"),
        sp_status = go:ChildWidget("sp_status"),
        dat = nil
    }
end

local function set(i)
    i.questName.text = i.dat.nm
    i.questName.fontSize = 28
    local t = i.questName.transform
    t.localPosition = Vector3(t.localPosition.x, 0, 0)

    t = i.status.transform
    t.localPosition = Vector3(t.localPosition.x, 0, 0)
    i.content:SetActive(false)
end

function _item.Init(i, quest, value)
    value = value or 0

    if quest.sn <= 0 then
        return
    end

    i.questName.transform.localPosition = Vector3(-27, 20.1, 0)
    i.status.transform.localPosition = Vector3(100.5, -12.5, 0)

    i.content:SetActive(true)

    i.dat = quest
    if quest.kind == 0 then
        set(i)
    elseif quest.kind == 1 then
        local t = string.find(quest.nm, "-")
        if t and t >= 1 then
            i.questName.text = "[EFE0B7]" .. string.sub(quest.nm, 1, t - 1)
            i.content.text = string.sub(quest.nm, t + 1)
        else
            i.questName.text = quest.nm
            i.content:SetActive(false)
        end
    elseif quest.kind == 2 then
        local t = string.find(quest.nm, "-")
        if t and t >= 1 then
            i.questName.text = "[EFE0B7]" .. string.sub(quest.nm, 1, t - 1)
            i.content.text = string.sub(quest.nm, t + 1)
        else
            set(i)
        end
    elseif quest.kind == 5 then
        set(i)
    end

    if value < quest.trg then
        i.status.text = "(" .. value .. "/" .. quest.trg .. ")"
        i.status:SetActive(quest.kind ~= 1)
        i.status.applyGradient = false
        i.sp_status:SetActive(false)
    else
        i.status.text = L("已完成")
        i.status:SetActive(false)
        i.status.applyGradient = true
        i.sp_status:SetActive(true)
    end
end

_item.__get =
{
    Selected = function(i)
        return i.bg.spriteName == "btn_09"
    end,
    IsCompleded = function(i)
        return i.status.text == L("已完成")
    end
}

_item.__set =
{
    Selected = function(i, value)
        if i.Selected ~= value then
            i.bg.spriteName = value and "btn_09" or "btn_08"
        end
    end
}

objext(_item, Item)

ItemQuest = _item