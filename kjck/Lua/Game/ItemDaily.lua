local Resources = UnityEngine.Resources
local isnull = isnull

local _item = {
    go = nil,
    questName = nil,
    content = nil,
    times = nil,
    grid = nil,
    texs = nil,
    data = nil,
    funcdata = nil,
}

local _itemGoods = nil

function _item.New(go)
    assert(notnull(go), "go is not gameobject")

    if isnull(_itemGoods) then
        _itemGoods = Resources.Load("Prefab/item_goods")
    end

    return
    {
        go = go,
        questName = go:ChildWidget("lab_name"),
        content = go:ChildWidget("lab_content"),
        times = go:ChildWidget("lab_qty"),
        grid = go:Child("gird_rw",typeof(UIGrid)),
    }
end

function _item:Init(quest, value)
    value = value or 0

    if objt(quest) == DB_Quest then
        if quest.sn <= 0 then
            return
        end
        self.data = quest
        self.questName.text = quest.nm
        self.content.text = quest.i
        if value < quest.trg then
            self.times.text = "(" .. value .. "/" .. quest.trg .. ")"
            self.times.color = Color.red
        else
            self.times.text = L("已完成")
            self.times.color = Color.green
        end
        local len = #quest.rws
        self.texs = { }
        for i = 1, len do
            local ig = ItemGoods(self.grid:AddChild(_itemGoods, string.format("rw_%02d", i)))
            ig:Init(quest.rws[i])
            table.insert(self.texs, ig.imgl)
            ig.go:GetCmp(typeof(LuaButton)):SetClick(function(btn)
                btn = Item.Get(btn.gameObject)
                if btn then
                    btn:ShowPropTip()
                end
            end )
        end
        self.grid.repositionNow = true
    end
end

function _item:GetData()
    return self.data
end

function _item:GetFuncData()
    return self.funcdata
end

function _item:Times()
    return self.times
end

objext(_item)

ItemDaily = _item