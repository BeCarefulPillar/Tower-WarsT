local _w = { }

local _body = nil
local _ref = nil

--组件绑定
local _item_goods = nil
local _grid = nil
local _labWine = nil
local _labCost = nil

--[Comment]
--道具数据
local _dats = nil

local _items = {}
local _selected = nil

local function UpdateInfo()
    _labWine.text = L("酒值").."："..user.nat.wine
    _labCost.text = tostring(DB.param.prAddHp)
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK })
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad","ClickUseGold","ClickUseProps")
    _ref = c.nsrf.ref
    _item_goods = _ref.item_goods
    _grid = _ref.grid
    _labWine = _ref.labWine
    _labCost = _ref.labCost
end

function _w.OnInit() 
    _dats = user.GetProps(function(p) return p.code == "wine" end)
    print("_dats_dats   ",kjson.print(_dats))
    UpdateInfo()
    for i = 1 ,#_dats  do
        local go = _grid:AddChild(_item_goods,"good_"..i)
        local it = ItemGoods(go)
        it:Init(_dats[i])
        it.go.luaBtn.luaContainer = _body
        it.go.luaBtn:SetClick("ClickItem",it)
        _items[i] = it
    end
    if #_dats > 0 then
        _selected = _items[1]
        _selected.Selected = false
    end
    _grid.repositionNow = true
end

function _w.OnDispose()
    _grid.gameObject:DesAllChild()
    _items = {}
    _dats = nil
end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
    
    _item_goods = nil
    _grid = nil
    _labWine = nil
    _labCost = nil
end

function _w.ClickUseGold()
    local owine = user.nat.wine
    SVR.AddWine(function(res)
        if res.success then
            ToolTip.ShowPopTip(L( string.format("增加[00FF00]%s[-]点酒", math.max(0, user.nat.wine - owine))))
            UpdateInfo()
        end
    end)
end

function _w.ClickUseProps()
    local p = _selected.dat
    if p and p.sn > 0 then
        local oWine = user.nat.wine
        PopUseProps.Use(p, p.sn, function(t)
            if t.success then
                ToolTip.ShowPopTip(L( string.format("增加[00FF00]%s[-]点酒", math.max(0, user.nat.wine - oWine))))
                UpdateInfo()
                oWine = user.nat.wine
                Tools.ShowUseProps(_selected.go)
            end
        end)
    end
end


--[Comment]
--购买使用酒
PopBuyWine = _w