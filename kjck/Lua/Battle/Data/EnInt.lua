
local setmetatable = setmetatable
local rawget = rawget
local rawset = rawset
local type = type
local random = math.random
local bxor = bit.bxor
local modf = math.modf

local _int =
{
    value = 0,

    __index = function(t, k) return rawget(t, "value") end,

    __newindex = function(t, k, v) rawset(t, "value", modf(v)) end,

    __tostring = function(i) return tostring(i.value) end,

    __div = function(e, v)
        if type(v) == "number" then
            return e.value / v
        else
            return e.value / v.value
        end
    end,

    __mul = function(e, v)
        if type(v) == "number" then
            return e.value * v
        else
            return e.value * v.value
        end
    end,

    __add = function(e, v)
        if type(v) == "number" then
            return e.value + v
        else
            return e.value + v.value
        end
    end,

    __sub = function(e, v)
        if type(v) == "number" then
            return e.value - v
        else
            return e.value - v.value
        end
    end,

    __unm = function(e) return -e.value end,

    __eq = function(a, b) return a.value == b.value end,

    __lt = function(a, b) return a.value < b.value end,

    __le = function(a, b) return a.value <= b.value end,
}

setmetatable(_int, { __call = function(t, v) return setmetatable({ value = v }, _int) end })

local _eint =
{
    __index = function(t, k) return bxor(rawget(t, "_v"), rawget(t, "_k")) end,

    __newindex = function(t, k, v)
        k = random(-2147483648, 2147483647)
        rawset(t, "_k", k)
--        rawset(t, "_v", bxor((modf(v)), k))
        rawset(t, "_v", bxor(v, k))
    end,

    __tostring = _int.__tostring,
--    __div = _int.__div,
--    __mul = _int.__mul,
--    __add = _int.__add,
--    __sub = _int.__sub,
--    __unm = _int.__unm,
--    __eq = _int.__eq,
--    __lt = _int.__lt,
--    __le = _int.__le,
}

setmetatable(_eint, {
    __call = function(t, v)
        local k = random(-2147483648, 2147483647)
        -- return setmetatable({ _k = k, _v = bxor((modf(v)), k) }, _eint)
        return setmetatable( { _k = k, _v = bxor(v or 0, k) }, _eint)
    end
})


--[Comment]
--整数
QYBattle.Int = _int

--[Comment]
--加密整数
QYBattle.EnInt = _eint
