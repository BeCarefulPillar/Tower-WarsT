
local rawget = rawget
local rawset = rawset
local insert = table.insert
local getmetatable = getmetatable
local setmetatable = setmetatable
local pairs = pairs

local B_Math = QYBattle.B_Math
local B_Vector = QYBattle.B_Vector
local BD_Field = QYBattle.BD_Field
local BE_Event = QYBattle.BE_Event

--类型树
local _typTree = { }
--类型信息
local _typInf = { }
--全局编号
local gid = 1

--字段说明
--[[
map BD_Field            所属战场数据
id int                  ID
birthFrame int          出生的帧号
deathFrame int          死亡的帧号
pos B_Vector            位置
evts table              事件列表
]]

local _unit = 
{
    --[Comment]
    --更新循环
    Update = function(u) end,
    --[Comment]
    --死亡
    Dead = function(u)
        if u.map.frameCount < u.deathFrame then
            u.deathFrame = u.map.frameCount
            u:OnDead()
        end
    end,
    --[Comment]
    --死亡时
    OnDead = function(u) end,
    --[Comment]
    --上报一条事件
    AddEvent = function(u, typ, dat)
        if u.evts == nil then return end
        insert(u.evts, BE_Event(u.map.frameCount, typ, u, dat))
        if typ == QYBattle.BE_Type.Attack then
        end
    end,
    --[Comment]
    --获取到当前为止的事件
    GetEvents = function(u)
        local evts = u.evts
        if evts == nil or #evts == 0 then return end
        u.evts = { }
        return evts
    end,
    --[Comment]
    --清除到当前为止的事件
    ClearEvent = function(u)
        if u.evts == nil or #u.evts == 0 then return end
        u.evts = { }
    end,
    --[Comment]
    --事件记录
    --on:是否开启
    RecordEvent = function(u, on)
        if on == false then
            u.evts = nil
        elseif u.evts == nil then
            u.evts = { }
        end
    end,
    --[Comment]
    --将给定的时间转换成帧数
    TimeToFrameCount = function(u, t) return B_Math.ceil(t * u.map.frameRate) end,
    --[Comment]
    --获取一个随机整数
    --m=nil n=nil : 返回[0(包括)-Int32.MaxValue(不包括)]之间的值
    --n=nil : 返回[0(包括)-m(不包括)]之间的值
    --返回[m(包括)-n(不包括)]之间的值
    RandomInt = function(u, m, n) return u.map.random:NextInt(m, n) end,
    --[Comment]
    --获取一个随机浮点数
    --m=nil n=nil : 返回[0(包括)-1(不包括)]之间的值
    --n=nil : 返回[0(包括)-m(不包括)]之间的值
    --返回[m(包括)-n(不包括)]之间的值
    Random = function(u, m, n) return u.map.random:Next(m, n) end,
}
--[Comment]
--属性器
local _get = 
{
    --[Comment]
    --是否存活
    isAlive = function(u) return u.map.frameCount < u.deathFrame end,
    --[Comment]
    --是否记录事件
    hasEvt = function(u) return u.evts ~= nil end,
    --[Comment]
    --单位在战场上的X位置
    posX = function(u) return u.pos.x end,
    --[Comment]
    --单位在战场上的Y位置
    posY = function(u) return u.pos.y end,
    --[Comment]
    --战场的时间(MS)
    time = function(u) return u.map.time end,
    --[Comment]
    --战场当前帧的间隔时间(S)
    deltaTime = function(u) return u.map.deltaTime end,
    --[Comment]
    --战场当前帧的间隔时间(MS)
    deltaMillisecond = function(u) return u.map.deltaMillisecond end,
}

--类型信息
_typInf[_unit] =
{
    get = _get,

    __call = function(t, map)
        assert(map and getmetatable(map) == BD_Field, "unit must in a BD_Field")
        t = setmetatable(
        {
            map = map,
            birthFrame = map.frameCount,
            deathFrame = map.maxFrameCount * 2,
            pos = B_Vector(),
            evts = map.hasEvent and { } or nil,
        } , t)
        map:Add(t)
        t.id = gid
        gid = gid + 1
        return t
    end
}

--[Comment]
--索引器
function _unit.__index(t, k)
    local v = rawget(_unit, k)
    if v == nil then
        v = rawget(_get, k)
        return v and v(t)
    end
    return v
end

local function _is(self, s)
    if self == nil or s == nil or not _typTree[s] then return false end
    if self == s then return true end
    self = _typTree[self] or getmetatable(self)
    if self == s then return true end
    while self do
        self = _typTree[self]
        if self == s then return true end
    end
end

_unit.is = _is

function _unit:extend(ctor, get, set, c)
    local inf = self and _typInf[self]
    assert(inf ~= nil, "self not a unit type")
    if c then
        assert(getmetatable(c) == nil and _typInf[c] == nil, "child can not be instance or Type")
        assert(not _is(self, c), "self can not be extend child")
    else
        c = { }
    end
    
    if get or inf.get then
        if inf.get then
            get = get or { }
            for k, v in pairs(inf.get) do
                if rawget(c, k) == nil and rawget(get, k) == nil then
                    rawset(get, k, v)
                end
            end
        end
    end
    if set or inf.set then
        if inf.set then
            set = set or { }
            for k, v in pairs(inf.set) do
                if rawget(c, k) == nil and rawget(set, k) == nil then
                    rawset(set, k, v)
                end
            end
        end
    end
    for k, v in pairs(self) do
        if rawget(c, k) == nil and (get == nil or rawget(get, k) == nil) then
            rawset(c, k, v)
        end
    end

    if get then
        c.__index = function(t, k)
            local v = rawget(c, k)
            if v == nil then
                v = rawget(get, k)
                return v and v(t)
            end
            return v
        end
        if set then
            c.__newindex = function(t, k, v)
                local s = rawget(set, k)
                if s then return s(t, v) end
                assert(rawget(get, k) == nil, "not implement set ["..k.."]")
                rawset(t, k, v)
            end
        else
            c.__newindex = function(t, k, v)
                assert(rawget(get, k) == nil, "not implement set ["..k.."]")
                rawset(t, k, v)
            end
        end
    else
        c.__index = function(t, k) return rawget(c, k) end
        if set then
            c.__newindex = function(t, k, v)
                local s = rawget(set, k)
                if s then return s(t, v) end
                rawset(t, k, v)
            end
        end
    end

    inf = { get = get, set = set, __call = ctor or inf.__call }
    _typInf[c] = inf
    _typTree[c] = self

    return setmetatable(c, inf), get, set
end

setmetatable(_unit, _typInf[_unit])
--[Comment]
--战场单位基类
QYBattle.BD_Unit = _unit