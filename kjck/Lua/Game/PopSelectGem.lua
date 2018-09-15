
local isnull = tolua.isnull

local win = { }
PopSelectGem = win

local _body = nil
PopSelectGem.body = _body

local _ref = nil
local _grid = nil
local _labCnt = nil

local _gt = nil
local _datas = nil
local _onSelect = nil
local _selects = nil
local _items = nil
local _limit = nil

local function RefreshCount()
    if _limit > 0 then
        _labCnt.text = _limit > 1 and #_selects.."/".._limit or ""
    else _labCnt.text = #_selects.."/"..#_datas
    end
end

local function GetItemSelect(it)
    local tmp = it.transform:FindChild("select");
    return tmp ~= nil and tmp.gameObject.activeSelf
end

local function SetItemSelect(it, isSlt)
    local tmp = it.transform:FindChild("select");
    if tmp == nil and isSlt then
        tmp = it:AddWidget(typeof(UISprite), "select")
        if tmp ~= nil then
            tmp.atlas = AM.mainAtlas
            tmp.spriteName = "sp_sign_tag"
            tmp.width, tmp.height, tmp.depth = 42, 42, 60
        end
    end
    if tmp ~= nil then tmp.gameObject:SetActive(isSlt) end
end

function win.OnLoad(c)
    _body = c
    _ref = _body.nsrf.ref
    WinBackground(c, {k = WinBackground.MASK})

    c:BindFunction("OnInit", "InitItem", "OnExit", "OnDispose", "OnUnLoad", "ClickItem")

    _grid = _ref.scrollView
    _labCnt = _ref.count
end

function win.OnInit()
    local arg = PopSelectGem.initObj
    _limit = 1
    if isFunction(arg) then _onSelect = arg
    elseif isTable(arg) then
        if #arg > 0 then _onSelect = arg[1] end
        if #arg > 1 then _datas = arg[2] end
        if #arg > 2 then
            if isNumber(arg[3]) then _limit = arg[3]
            elseif isTable(arg[3]) then _selects = arg[3]
            end
        end
        if #arg > 3 then _limit = arg[4] end
    end
    if _onSelect ~= nil then
        if _gt == nil then _gt = GridTexture(128) end
        if _datas == nil then
            _datas = DB.AllGem(function (g) return user.GetGemQty(g.sn) > 0 end)
        end
        table.sort(_datas, DB_Gem.Compare)
        if _selects == nil then _selects = { } end
        RefreshCount()
        _items = { }
        _grid:Reset()
        _grid.realCount = #_datas
    else Destroy(_body.gameObject)
    end
end

function win.InitItem(it, idx)
    if it == nil or idx < 0 or idx >= #_datas then return false end
    idx = _datas[idx + 1]
    SetItemSelect(it, table.contains(_selects, idx))
    local tmp = it.transform:FindChild("name")
    if tmp then
        tmp = tmp:GetCmp(typeof(UILabel))
        tmp.text = idx.nm
        tmp.color = ColorStyle.GetGemColor(idx.color)
    end
    tmp = it.transform:FindChild("num")
    if tmp then tmp:GetCmp(typeof(UILabel)).text = "x"..(user.GetGemQty(idx.sn)) end
    tmp = it.transform:FindChild("icon")
    if tmp then _gt:Add(tmp:GetCmp(typeof(UITexture)):LoadTexAsync(ResName.GemIcon(idx.sn))) end
    _items[it] = idx
    local btn = it.luaBtn
    btn.param = {it, idx}
    return true
end

function win.OnExit()
    if _onSelect then _onSelect(table.findall(_selects, function (e) return e ~= nil end)) end
end

function win.OnDispose()
    if _gt then
        _gt:Dispose()
        _gt = nil
    end
    _datas = nil
    _selects = nil
    _onSelect = nil
    if _items ~= nil then
        for k, v in pairs(_items) do if not isnull(k) then Destroy(k) end end
        _items = nil
    end
end

function win.OnUnLoad()
    _body = nil
    _grid = nil
    _labCnt = nil
end

-------------- 按钮事件

function win.ClickItem(p)
    local gem = p[1]
    local dat = p[2]
    if gem == nil then return end
    if _limit == 1 then
        _selects = { }
        table.insert(_selects, dat)
        _body:Exit()
    elseif GetItemSelect(gem.gameObject) then
        SetItemSelect(gem.gameObject, false)
        for i = 0, #_selects do
            if _selects[i].sn == dat.sn then
                table.remove(_selects, i)
                break;
            end
        end
    elseif _limit < 1 or #_selects < _limit then
        if not table.contains(_selects, dat) then table.insert(_selects, dat) end
        SetItemSelect(gem.gameObject, true)
    else ToolTip.ShowPopTip(L("最多可选择").._limit..L("颗宝石"));
    end
    RefreshCount()
end

