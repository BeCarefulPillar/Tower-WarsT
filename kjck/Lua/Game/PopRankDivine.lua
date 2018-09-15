local Destroy = UnityEngine.Object.Destroy
local notnull = notnull

local _w = { }

local _body = nil
local _ref = nil

local _items = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c,{k=WinBackground.MASK})

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "OnUnLoad"
    )

    _ref.btnClose:SetClick( function()
        _body:Exit()
    end )
end

local function InitData(data)
    _w.OnDispose()

    table.print("data",data)

    _ref.myRank.text = data.myRank > 10 and "10+" or tostring(data.myRank)
    _ref.myName.text = user.nick
    _ref.myLucky.text = tostring(data.myLucky)
    local len = #data.rank
    _items = { }
    for i = 1, len do
        _items[i] = _ref.grid:AddChild(_ref.item_rank, string.format("item_%02d", i))
        _items[i]:ChildWidget("rank").text = tostring(i)
        _items[i]:ChildWidget("name").text = data.rank[i].name
        _items[i]:ChildWidget("lucky").text = tostring(data.rank[i].lucky)
        _items[i]:SetActive(true)
    end
    _ref.grid:GetCmp(typeof(UIGrid)).repositionNow = true
end

function _w.OnInit()
    SVR.DivineRank( function(result)
        if result.success then
            InitData(SVR.datCache)
        end
    end )
end

function _w.OnDispose()
    if _items then
        for i = 1, #_items do
            if notnull(_items[i]) then
                Destroy(_items[i])
            end
        end
        _items = nil
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
    end
end

--[Comment]
--占卜排行
PopRankDivine = _w