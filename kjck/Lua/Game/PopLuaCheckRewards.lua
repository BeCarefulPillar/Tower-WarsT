local _w = { }

local _body = nil
local _ref = nil

local _items = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "ClickItemGoods"
    )
end

function _w.OnInit()
    if type(_w.initObj)=="table" and
        type(_w.initObj[1])=="string" and
        type(_w.initObj[2]=="table") then
        _ref.tip.text = _w.initObj[1]
        _w.BuildItems(_w.initObj[2])
    else
        _body:Exit()
    end
end

local function Despawn(items)
    if items then
        for i = 1, #items do
            if items[i].go then
                items[i].go:SetActive(false)
            end
        end
    end
end

function _w.BuildItems(rws)
    if rws == nil then
        return
    end
    _items = _items or { }
    Despawn(_items)
    for i = 1, #rws do
        if not _items[i] then
            _items[i] = ItemGoods(_ref.grid:AddChild(_ref.item_goods, string.format("item_%03d", i)))
            _items[i].go.luaBtn.luaContainer = _body
        else
            _items[i].go:SetActive(true)
        end
        _items[i]:Init(rws[i][1])
    end
    _ref.grid.repositionNow = true
end

function _w.OnUnLoad(c)
    if _body==c then
        _body = nil
        _ref = nil
        _items = nil
    end
end

function _w.OnDispose()
    Despawn(_items)
    _ref.tip.text = ""
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then btn:ShowPropTip() end
end

PopLuaCheckRewards = _w