local rawget = rawget
local rawset = rawset
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable
local pcall = pcall

--region -------------------Object-------------------
local _obj = {}
--继承表
local _extTab  = { }
--类型信息
local _typInf = { } 

function _obj.__index(t, k) return rawget(_obj, k) end
    
_obj.__newindex = rawset

function _obj.__call(t, ...) return setmetatable(t.New and t.New(...) or { }, t) end

--[Comment]
--c是否继承于p
local function is(c, p)
    if p == nil or c == nil then return false end

    c = _extTab[c] or getmetatable(c)
    if c == p then return true end

    while c do
        c = _extTab[c]
        if c == p then return true end
    end

    return false
end
--[Comment]
--c是否继承于p
_obj.is = is

--[Comment]
--给定对象是否为派生的
function _obj.contain(p, c) return is(c, p) end
--[Comment]
--获取类型
function _obj.getType(o) return o and getmetatable(o) end
    
--[Comment]
--将c继承于p(nil=Obj),e为扩展
function _obj.extend(c, p)
    assert(c, "child can not be nil")
    if p then assert(_typInf[p], "parent not a type") else p = Obj end
    assert(not is(p, c), "parent can not be extend child")

    --继承关系
    _extTab[c] = p
    --构造连接
    c.__call = c.__call or p.__call or _obj.__call

    ---------closure---------
    --属性器
    local get, set = rawget(c, "__get"), rawget(c, "__set")
    --索引键 堆栈表
    local istk = { }
    --类型信息
    local inf = _typInf[p]
    --父级类型信息
    local si, sn = inf.index, inf.newindex
    --当前类型信息
    inf = { }
    _typInf[c] = inf

    --基本取索引
    local baseIdx = function(t, k)
        local v = rawget(c, k)
        if v ~= nil then return v end
        if get then
            v = rawget(get, k)
            if v then return v(t) end
        end
        return si(t, k)
    end
    --扩展取索引
    local extIdx = function(t, k)
        local v = rawget(c, k)
        if v ~= nil then return v end
        if get then
            v = rawget(get, k)
            if v then return v(t) end
        end
        v = rawget(t, "__ext")
        if v then
            v = v[k]
            if v ~= nil then return v end
        end
        return si(t, k)
    end

    --基本读索引
    inf.index = function(t, k)
        if istk[k] then
            print("get index "..k.." stack overflow")
            return nil
        end
        istk[k] = true
        local ret, v = pcall(baseIdx, t, k)
        istk[k] = false
        assert(ret, v)
        return v
    end
    --基本写索引
    inf.newindex = function(t, k, v)
        if set then
            local s = rawget(set, k)
            if s then return s(t, v) end
        end
        assert(get == nil or rawget(get, k) == nil, "not implement set ["..k.."]")
--        if get and get[k] then return print("not implement set ["..k.."]") end
        sn(t, k, v)
    end
    --当前读索引
    c.__index = function(t, k)
        if istk[k] then
            print("get index "..k.." stack overflow")
            return nil
        end
        istk[k] = true
        local ret, v = pcall(extIdx, t, k)
        istk[k] = false
        assert(ret, v)
        return v
    end
    --当前写索引
    c.__newindex = inf.newindex
    -----------end---------

    return setmetatable(c, p)
end

--Obj类型信息
_typInf[_obj] = 
{
    index = _obj.__index,
    newindex = rawset,
}
--配置元表
setmetatable(_obj, _obj)
--[Comment]
--基本对象
Obj = _obj

--[Comment]
--将c继承于p(nil=Obj)
objext = _obj.extend
--[Comment]
--将c继承于p(nil=Obj)
objis = is
--[Comment]
--获取对象的直接类型
objt = _obj.getType
--endregion

--region -------------------DataCell-------------------
local _cell = { cellId = nil, changed = false, cellDead = nil, observer = nil }

local _cells = {}
local _cellIdls = {}
local _cellSize = 0

--压缩空间
local function CellTrim()
    local idx = nil
    local c = nil
    for i = 1, _cellSize do
        c = _cells[i]
        if c then
            if idx then
                _cells[idx] = c
                _cells[i] = nil
                c.cellId = idx
                idx = idx + 1
            end
        elseif idx == nil then
            idx = i
        end
    end

    if #_cellIdls > 0 then for i = #_cellIdls, 1, -1 do table.remove(_cellIdls, i) end end
        
    _cellSize = #_cells
end
--添加DataCell
local function AddCell(c)
    if c.cellDead then return end
    if c.cellId then
        if c == _cells[c.cellId] then return end

        for i = _cellSize, 1, -1 do
            if c == _cells[i] then
                c.cellId = i
                return
            end
        end
    end
    
    if #_cellIdls > 0 then
        local id
        for i = #_cellIdls, 1, -1 do
            id = _cellIdls[i]
            if id <= _cellSize and _cells[id] == nil then
                _cells[id] = c
                c.cellId = id
                return
            else
                table.remove(_cellIdls, i)
            end
        end
    end

    _cellSize = _cellSize + 1
    _cells[_cellSize] = c
    c.cellId = _cellSize
end
--移除DataCell
local function RemoveCell(c)
    local id = c.cellId
    if id and c == _cells[id] then
        _cells[id] = nil
        c.cellId = nil
        table.insert(_cellIdls, id)
    else
        for i = 1, _cellSize do
            if c == _cells[i] then
                _cells[i] = nil
                c.cellId = nil
                table.insert(_cellIdls, i)
                break
            end
        end
    end
end
--循环
local function OnCellCycle()
    if _cellSize < 1 then return end
    
    local c, obs, o
    for i = 1, _cellSize do
        c = _cells[i]
        if c and c.changed then
            if c.OnDataChange then pcall(c.OnDataChange, c) end
            c.changed = false
            obs = c.observer
            if obs and #obs > 0 then
                for j = #obs, 1, -1 do
                    o = obs[j]
                    if o and o.alive and o.OnDataChange and o:alive() then
                        o:OnDataChange(c)
                    else
                        table.remove(obs, j)
                    end
                end
                if #obs < 1 then RemoveCell(c) end
            else
                RemoveCell(c)
            end
        end
    end

    if #_cellIdls > 8 then CellTrim() end
end
--添加循环
local _handle = UpdateBeat:CreateListener(OnCellCycle)
UpdateBeat:AddListener(_handle)

--[Comment]
--添加观察者
function _cell:AddObserver(o)
    if self.cellDead then 
--        print("DataCell is dead", self)
        return
    end
    if o and o.alive and o.OnDataChange and o:alive() then
        local obs = self.observer
        if obs == nil then
            self.changed = false
            self.observer = { o }
        elseif #obs < 1 then
            self.changed = false
            obs[1] = o
        else
            for i = #obs, 1, -1 do if o == obs[i] then o = nil end end
            if o then table.insert(obs, o) end
        end
        AddCell(self)
    else
        print(string.format("DataCell:AddObserver(o) self, the o[%s] can not be nil and alive[%s] and has OnDataChange[%s] function", tostring(o), tostring(o and o.alive and o:alive() or nil), tostring(o and o.OnDataChange)))
    end
end
--[Comment]
--移除观察者
function _cell:RemoveObserver(o)
    if o == nil then return end
    local obs = self.observer
    if obs == nil or #obs < 1 then return end
    for i = #obs, 1, -1 do
        if o == obs[i] then
            table.remove(obs, i)
            if #obs < 1 then RemoveCell(self) end
            return
        end
    end
end
--[Comment]
--是否有给定的观察者，若给定观察者为nil则返回是否有任何观察者
function _cell:HasObserver(o)
    local obs = self.observer
    if obs == nil or #obs < 1 then return false end
    if o then
        for i = #obs, 1, -1 do
            if o == obs[i] then return true end
        end
        return false
    end
    return true
end
--[Comment]
--睡眠，将移除观所有察者
function _cell:CellSleep()
    self.observer = nil
    self.changed = false
    RemoveCell(self)
end
--[Comment]
--死亡，将移除观所有察者
function _cell:CellDead()
    self.observer = nil
    self.changed = false
    RemoveCell(self)
    self.cellDead = true
end
--[Comment]
--标记为已变更
function _cell:MarkAsChanged()
    self.changed = true
end
--[Comment]
--数据的更换
function _cell.DataChange(from, to, o)
    if from == to then return to end
    local f = from and from.RemoveObserver
    if f then f(from, o) end
    f = to and to.AddObserver
    if f then f(to, o) end
    return to
end
--[Comment]
--清除所有观察数据
function _cell.Clear()
    if _cellSize < 1 then return end

    local c
    for i = 1, _cellSize do
        c = _cells[i]
        if c then
            c.cellId = nil
            c.observer = nil
            c.changed = nil
        end
    end

    _cells = {}
    _cellSize = 0
    _cellIdls = {}
end

--继承
objext(_cell)
--[Comment]
--可观察变更的数据
DataCell = _cell
--endregion

--region Item
local isnull = tolua.isnull
local isgo = CS.IsGo
local _itemSet = LuaCmpItem.Set
local _itemMap = { }
local _item = { }
local _itemQty = 0
local _itemMaxQty = 100

local function ItemStart(go)
    go = _itemMap[go]
    if go == nil then return end
    local f = go.Start
    if f then f(go) end
end
local function ItemOnEnable(go)
    go = _itemMap[go]
    if go == nil then return end
    local f = go.OnEnable
    if f then f(go) end
end
local function ItemOnDisable(go)
    go = _itemMap[go]
    if go == nil then return end
    local f = go.OnDisable
    if f then f(go) end
end
local function ItemOnDestroy(go)
    go = _itemMap[go]
    if go == nil then return end
    _itemMap[go] = nil
    _itemQty = _itemQty - 1
    local f = go.OnDestroy
    if f then f(go) end
    go.go = nil
end

local function ItemTrim()
    _itemQty = 0
    for go, i in pairs(_itemMap) do
        if isnull(go) then
            _itemMap[go] = nil
        else
            _itemQty = _itemQty + 1
        end
    end
    _itemMaxQty = math.max(_itemQty + 80, 100)
end

_item.__call = function(t, go, ...)
    assert(go and isgo(go), "create Item need GameObject")
    local i = _itemMap[go]
    if i == nil then
        i = setmetatable(t.New and t.New(go, ...) or { go = go }, t)
        if i.go == nil then i.go = go end
        _itemSet(go, t.Start ~= nil, t.OnEnable ~= nil, t.OnDisable ~= nil, true)
        _itemMap[go] = i
        if _itemQty > _itemMaxQty then
            ItemTrim()
        else
            _itemQty = _itemQty + 1
        end
    end
    return i
end

function _item.alive(i) return not isnull(i.go) end

--[Comment]
--取得GameObject对应的Item
function _item.Get(go)
    local i = _itemMap[go]
    if i and isnull(go) then
        i, _itemMap[go] = nil, nil
        _itemQty = _itemQty - 1
    end
    return i
end

LuaCmpItem.Init(ItemStart, ItemOnEnable, ItemOnDisable, ItemOnDestroy)
--继承
objext(_item)
--[Comment]
--Item基类
Item = _item
--endregion