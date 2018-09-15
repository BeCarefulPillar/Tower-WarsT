
local isnull = tolua.isnull

local win = { }
PopSelectEquip = win

local _body = nil
PopSelectEquip.body = _body

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

local function GetItemUsed(it)
    local tmp = it.transform:FindChild("used");
    return tmp ~= nil and tmp.gameObject.activeSelf
end

local function SetItemUsed(it, isUse)
    isUse = isUse and true or false
    local tmp = it.transform:FindChild("used");
    if tmp == nil and isUse then
        tmp = it:AddWidget(typeof(UISprite), "used")
        if tmp ~= nil then
            tmp.atlas = AM.mainAtlas
            tmp.spriteName = "sp_equip"
            tmp.width, tmp.height, tmp.depth = 43, 43, 60
            tmp.cachedTransform.localPosition = Vector3(-24, 25, 0)
        end
    end
    if tmp ~= nil then tmp.gameObject:SetActive(isUse) end
end

local function InitItemEquip(it, dat)
    if it == nil or dat == nil then return end
    dat:RemoveObserver(PopSelectEquip)
    local tmp = nil
    if tonumber(dat.sn) > 0 then
        tmp = it:GetCmp(typeof(UISprite))
        if tmp then tmp.spriteName = "frame_"..dat.rare end
        tmp = it.transform:FindChild("name")
        if tmp then
            tmp = tmp:GetCmp(typeof(UILabel))
            tmp.text = dat.nm
            tmp.color = ColorStyle.GetRareColor(dat.rare)
        end
        tmp =  it.transform:FindChild("lv")
        if tmp then tmp:GetCmp(typeof(UILabel)).text = "Lv:"..dat.lv end
        SetItemUsed(it, dat.IsEquiped)
        dat:AddObserver(PopSelectEquip)
        ItemGoods.SetEquipEvo(it, dat.evo, dat.rare)
        ItemGoods.SetEquipGems(it, dat.gems)
        ItemGoods.SetEquipExclStar(it, dat.exclStar)
        if dat.HasFrameEffect then
            ItemGoods.AddEquipEffect(it, dat.rare, true, dat.IsMaxLv, dat.ExclActive, dat.SuitActive and dat.db.sn or 0)
        end
    else
        local db = DB.GetProps(-dat.sn)
        tmp = it:GetCmp(typeof(UISprite))
        if tmp then tmp.spriteName = "frame_"..db.rare end
        tmp = it.transform:FindChild("name")
        if tmp then
            tmp = tmp:GetCmp(typeof(UILabel))
            tmp.text = db.nm
            tmp.color = ColorStyle.GetRareColor(db.rare)
        end
        tmp =  it.transform:FindChild("lv")
        if tmp then tmp:GetCmp(typeof(UILabel)).text = "x1" end
        SetItemUsed(it, false)
        ItemGoods.SetEquipEvo(it)
        ItemGoods.SetEquipGems(it)
        ItemGoods.SetEquipExclStar(it)
        if db.rare > DB_Equip.RARE_VALUE then ItemGoods.AddEquipEffect(it, dat.rare, true) end
    end
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
    local arg = PopSelectEquip.initObj
    if isFunction(arg) then _onSelect = arg
    elseif isTable(arg) then
        if #arg > 0 then _onSelect = arg[1] end
        if #arg > 1 then _datas = arg[2] end
        if #arg > 2 then _selects = arg[3] end
        if #arg > 3 then _limit = arg[4] end
    end

    if #_datas  > 0 then table.reverse(_datas) end

    if _onSelect ~= nil then
        if _gt == nil then _gt = GridTexture(128) end
        if _datas == nil then
            _datas = user.GetEquips()
            table.sort(_datas, PY_Equip.Compare)
        end
        if _selects == nil then _selects = { } end
        if _limit == nil then _limit = 1 end
        RefreshCount()
        _items = { }
        _grid:Reset()
        _grid.realCount = #_datas
    else Destroy(_body.gameObject)
    end
end

function win.InitItem(it, idx)
    if it == nil or idx < 0 or idx > #_datas then return false end
    local dat = _datas[idx + 1]
    SetItemSelect(it, table.contains(_selects, dat))
    _items[it] = dat
    it.luaBtn.param = {it, dat}
    InitItemEquip(it, dat)
    it = it.transform:FindChild("img")
    if it then _gt:Add(it:GetCmp(typeof(UITexture)):LoadTexAsync(tonumber(dat.sn) > 0 and ResName.EquipIcon(dat.db.img) or ResName.PropsIcon(-dat.sn))) end
    return true
end

function win.OnDataChange(w, d)
    if w ~= PopSelectEquip or d == nil then return end
    local tmp = nil
    tmp = table.idxof(_datas, d)
    if tmp then InitItemEquip(_grid:GetItem(tmp - 1), d) end
end

function win.alive(w)
    if w ~= PopSelectEquip then return false end
    return not isnull(w.body)
end

function win.OnExit()
    if _onSelect then _onSelect(table.findall(_selects, function (e) return e ~= nil end)) end
end

function win.OnDispose()
    if _gt then
        _gt:Dispose()
        _gt = nil
    end
    _limit = nil
    _datas = nil
    _onSelect = nil
    _selects = nil
    if _items ~= nil then
        for k, v in pairs(_items) do
            if not isnull(k) then Destroy(k) end
            if v then v:RemoveObserver(PopSelectEquip) end
        end
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
    local it = p[1]
    local dat = p[2]
    if _limit == 1 then
        _selects = { }
        table.insert(_selects, dat)
        _body:Exit()
    elseif GetItemSelect(it) then
        SetItemSelect(it, false)
        for i = 1, #_selects do
            if _selects[i].sn == dat.sn then
                table.remove(_selects, i)
                break;
            end
        end
    elseif _limit < 1 or #_selects < _limit then
        if not table.contains(_selects, dat) then table.insert(_selects, dat) end
        SetItemSelect(it, true)
    else ToolTip.ShowPopTip(L("最多可选择").._limit..L("件装备"));
    end
    RefreshCount()
end

