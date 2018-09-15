--[Comment]
--帮助
PopLuaHelp = { }

local _body = nil
local _ref = nil

--帮助数据
local data = nil
local itemPool = nil

function PopLuaHelp.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    data = DB_Help.GetAllC()
    itemPool = require("Data.ItemPool").new()
end

function PopLuaHelp.OnInit()
    itemPool:RemoveChilds(_ref.grid1)
    --创建一级标签
    for sn, v in ipairs(data) do
        local it = itemPool:CreateItem(_ref.grid1, _ref.item1)
        it.name = string.format("tab1_%02d", sn)
        it.widget.text = DB_Help.GetTittle(sn)
        it.luaBtn.param = sn
    end
    _ref.grid1:GetComponent(typeof(UIGrid)):Reposition()
    --打开上面第一个标签
    PopLuaHelp.ClickTab1(1)
end

function PopLuaHelp.OnDispose()
    itemPool:RemoveChilds(_ref.grid1)
    itemPool:RemoveChilds(_ref.grid2)
end

--[Comment]
--点击一级标签（上面的）
function PopLuaHelp.ClickTab1(tab1Sn)
    itemPool:RemoveChilds(_ref.grid2)
    --删掉所有二级标签
    PopLuaHelp.ToggleGroup_1(string.format("tab1_%02d", tab1Sn))

    for tab2Sn, v in pairs(data[tab1Sn]) do
        local it = itemPool:CreateItem(_ref.grid2, _ref.item2)
        it.name = string.format("tab2_%02d", tab2Sn)
        it.widget.text = v[1]
        it.luaBtn.param = { tab1Sn, tab2Sn }
    end
    _ref.grid2:GetComponent(typeof(UIGrid)):Reposition()
    _ref.grid2:GetComponent("UIScrollView"):ConstraintPivot(UIWidget.Pivot.Top, true)
    --滑到顶部
    --打开第一个
    PopLuaHelp.ClickTab2( { tab1Sn, 1 })
end

--[Comment]
--点击二级标签
function PopLuaHelp.ClickTab2(t)
    PopLuaHelp.ToggleGroup_2(string.format("tab2_%02d", t[2]))
    local str = data[t[1]][t[2]][2]
    _ref.content.text = string.gsub(str, "\\n", "\n")
end

--[Comment]
--一级标签toggle组
function PopLuaHelp.ToggleGroup_1(currentName)
    local tab1s = itemPool:GetAll(_ref.item1.name)
    for k, v in pairs(tab1s) do
        if v.activeSelf then
            v:Child("bg"):SetActive(v.name == currentName)
        end
    end
end

--[Comment]
--二级标签toggle组
function PopLuaHelp.ToggleGroup_2(currentName)
    local tab2s = itemPool:GetAll(_ref.item2.name)
    for k, v in pairs(tab2s) do
        if v.activeSelf then
            v:ChildWidget("bg").spriteName =
            v.name == currentName and "btn_13" or "btn_12"
        end
    end
end

function PopLuaHelp.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
    end
end