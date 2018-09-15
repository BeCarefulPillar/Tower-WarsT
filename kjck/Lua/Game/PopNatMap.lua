require "Data/DB_NatData"

local ipairs = ipairs
local insert = table.insert

local Screen = UE.Screen

local _w = { }

local MAP_SZIE = 2580

local _body = nil
local _ref = nil

local _lblNnm = nil
local _lblCity = nil
local _lblFood = nil

local _goFight = nil
local _goTarget = nil

local _mspMap = nil
local _spView = nil
local _mcpFight = nil
local _mcpTarget = nil
local _mspHero = nil

local _mapTrans = nil
local _viewTrans = nil

local _dat = nil
local _heroQty = 0
local _width, _height = 484 / MAP_SZIE, 484 / MAP_SZIE

local function MapToLocal(pos) return Vector3(pos.x * _width, pos.y * _height) end
local function LocalToMap(pos) return Vector3(pos.x / _width, pos.y / _height) end

local function Refresh()
    if _dat == nil then return end
    local var
    local qty = 0
    if _dat.city then
        for _, c in ipairs(_dat.city) do if c.def == _dat.nsn then qty = qty + 1 end end
    end
    _lblCity.text = "x" .. qty

    var = { }
    --刷新地图
    local city = _dat.city
    for i = 1, _mspMap.unitCount, 1 do
        qty = city and city[i]
        _mspMap:SetUnitColor(i - 1, ColorStyle.GetNatColor(qty and qty.def))
        if qty and qty.atk > 0 then insert(var, i - 1) end
    end

    --交战城池
    qty = #var
    _goFight:SetActive(qty > 0)
    _mcpFight:SetActive(qty > 1)
    if qty > 0 then
        _goFight.transform.localPosition = _mspMap:GetUnitPos(var[1])
        if qty > 1 then
            _mcpFight.unitCount = qty - 1
            for i = 2, qty do
                _mcpFight:SetUnit(i - 2, _mspMap:GetUnitPos(var[i]), math.random(360))
            end
        end
    end
    --目标城池
    var = _dat:GetTargetCity()
    print("目标城池目标城池    ",  kjson.print(var))
    qty = var and #var or 0
    _goTarget:SetActive(qty > 0)
    _mcpTarget:SetActive(qty > 1)
    if qty > 0 then
        _goTarget.transform.localPosition = _mspMap:GetUnitPos(var[1] - 1)
        if qty > 1 then
            _mcpTarget.unitCount = qty - 1
            for i = 2, qty do
                _mcpTarget:SetUnitPos(i - 2, _mspMap:GetUnitPos(var[i] - 1))
            end
        end
    end

    var = #_dat.heros
    print("vavavava    ",var)
    print("_heroQty    ",_heroQty)
    if _heroQty ~= var then
        _heroQty = var
        _mspHero.unitCount = var
    end

    if var > 0 then
        for i, h in ipairs(_dat.heros) do
            local p = h:GetPos()
            p.x = p.x * _width
            p.y = p.y * _height + 17
            _mspHero:SetUnitPos(i - 1, p)
        end
    end
end

local function CheckView(min, max)
    min = min / MapNat.Scale
    max = max / MapNat.Scale
    min.x, min.y = min.x * _width, min.y * _height
    max.x, max.y = max.x * _width - min.x, max.y * _height - min.y
    _viewTrans.localPosition = Vector3(min.x + max.x * 0.5, min.y + max.y * 0.5)
    _spView.width, _spView.height = max.x, max.y
end

local _update = UpdateBeat:CreateListener(function()
    local var 
    var = _dat.getFoodQty
    if var > 0 then
        _lblFood.text = string.format(L("[00FF00]可征收:[-]%d/%d"), var, DB.param.qtyNatFood)
    else
        _lblFood.text = L("下次军粮发放:") .. TimeClock.TimeToMS(900 - SVR.SvrTime() % 900)
    end

    if _spView then CheckView(MapNat.getViewArea()) end

    var = #_dat.heros
    if _heroQty ~= var then
        _heroQty = var
        _mspHero.unitCount = var
    end

    if var > 0 then
        for i, h in ipairs(_dat.heros) do
            if h.CurStatus == PY_NatHero.Status.Move then
                var = 0
                local p = h:GetPos()
                p.x = p.x * _width
                p.y = p.y * _height + 17
                _mspHero:SetUnitPos(i - 1, p)
            end
        end
        if var == 0 then _mspHero:MarkAsChanged() end
    end
end)

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK })
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad","PressMap","DragMap","ClickGetFood")
    _ref = c.nsrf.ref
     
    _goFight = _ref.tagFight
    _goTarget = _ref.tagTarget

    _lblNnm = _ref.natName
    _lblCity = _ref.cityQty
    _lblFood = _ref.rewardQty
    _mspMap = _ref.miniMap
    _spView = _ref.viewFrame
    _mcpFight = _ref.mcpFight
    _mcpTarget = _ref.mcpTarget
    _mspHero = _ref.mspHero

    _mapTrans, _viewTrans = _mspMap.cachedTransform, _spView.cachedTransform
end

function _w.OnInit() 
    _dat = user.nat
    if _dat == nil then _body:Exit() return end

    _lblNnm.text = string.format(L("%s国城池"), DB.GetNatName(_dat.nsn))
    
    UpdateNat:Add(Refresh)
    UpdateNatAct:Add(Refresh)

    if _spView then
        _spView.color = ColorStyle.GetNatColor(_dat.nsn)
    end

    local city = DB_NatData.city
    _mspMap.unitCount = #city
    for i = 1, #city do _mspMap:SetUnitPos(i - 1, MapToLocal(city[i].pos)) end

    Refresh()

    UpdateBeat:AddListener(_update)
end

function _w.OnDispose()
    UpdateBeat:RemoveListener(_update)
    UpdateNat:Remove(Refresh)
    UpdateNatAct:Remove(Refresh)
    _heroQty = 0
end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
    _goFight = nil
    _goTarget = nil
    _lblNnm = nil
    _lblCity = nil
    _lblFood = nil
    _mspMap = nil
    _spView = nil
    _mcpFight = nil
    _mcpTarget = nil
    _mspHero = nil
    _mapTrans = nil
    _viewTrans = nil
end

function _w.PressMap(p)
    if p and _mspMap then
        if MapNat then
            MapNat.MoveTo(LocalToMap(_mapTrans:InverseTransformPoint(UICamera.lastHit.point)))
        end
    end
end

function _w.DragMap(d)
    if MapNat then
        MapNat.MoveTo(LocalToMap(_mapTrans:InverseTransformPoint(UICamera.lastHit.point)))
    end
end

function _w.ClickGetFood()
    SVR.NatFood("get", function(t)
        if t.success then
            ToolTip.ShowPopTip(L("粮草+") .. "[B4E640]" .. SVR.datCache.food .. "[-]")
        end
    end)
end

--[Comment]
--国战小地图
PopNatMap = _w