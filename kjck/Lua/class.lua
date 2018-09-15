
local setmetatable = setmetatable
local getmetatable = getmetatable
local rawget = rawget
local rawset = rawset
local pcall = pcall
local ssub = string.sub
local type = type

--类型树
local _typTree = { }
--类型信息
local _typInf = { }

--给定的 类/对象c 是否继承/实现 类s
local function _is(c, s)
    if c and s and _typInf[s] then
        if c == s then return true end
        c = _typTree[c] or getmetatable(c)
        if c == s then return true end
        c = _typTree[c]
        while c do
            if c == s then return true end
            c = _typTree[c]
        end
    end
    return false
end
--获取给定对象的类
local function getClass(o)
    if _typInf[o] == nil then
        o = getmetatable(o)
        if _typInf[o] == nil then return nil end
    end
    return o
end

--[Comment]
--创建一个类型
--s : 父类
--例如 创建一个类 A = class(X) 类型A继承于类X
--构造函数(可无) function A:ctor(arg1, arg2, ...) self.id = arg1 end
--getter/setter(可无) function A:get_xxx() end, function A:set_xxx(v) end 前缀为get_/set_的函数，将可直接用属性的方式访问和设置
--创建A的实例 local a = A(1, 2, ...)
--固有属性 a.class当前对象类型，a.super父类型，a:is(X)判断a是否是类型X的实例
function class(s)
    local inf = s and _typInf[s]
    assert(s == nil or inf, "the arg s must be a class or nil")
    
    local c = { }
    local ctor = nil
    local get, set = { }, { }
    
    --索引键 堆栈表
    local istk = { }
    local baseIdx, baseNewIdx = nil, nil

    if inf then
        local sidx = inf.index
        local snewidx = inf.newindex
        --基本索引-读
        baseIdx = function(t, k)
            local v = rawget(c, k)
            if v ~= nil then return v end
            v = rawget(get, k)
            if v then return v(t) end

            return sidx(t, k)
        end
        --基本索引-写
        baseNewIdx = function(t, k, v)
            local s = rawget(set, k)
            if s then return s(t, v) end
            assert(rawget(get, k) == nil, "not implement set ["..k.."]")
            snewidx(t, k, v)
        end
    else
        --基本索引-读
        baseIdx = function(t, k)
            local v = rawget(c, k)
            if v == nil then
                v = rawget(get, k)
                if v ~= nil then return v(t) end
                v = rawget(t, "__ext")
                if v then return v[k] end
            end
            return v
        end
        --基本索引-写
        baseNewIdx = function(t, k, v)
            local s = rawget(set, k)
            if s then return s(t, v) end
            assert(rawget(get, k) == nil, "not implement set ["..k.."]")
            rawset(t, k, v)
        end
    end

    --[Comment]
    --构造堆栈
--    local ctorStk = nil
--    if s then
--        ctorStk = { s }
--        s = _typTree[s]
--        while s do
--            table.insert(ctorStk, s, 1)
--            s = _typTree[s]
--        end
--    end

    inf = 
    {
        --父级
        super = s,
        --属性-取
        get = get,
        --属性-写
        set = set,
        --索引-读
        index = function(t, k)
            if istk[k] then
                print("get index "..k.." stack overflow")
                return nil
            end
            istk[k] = true
            local ret, v = pcall(baseIdx, t, k)
            istk[k] = false
            assert(ret, v)
            return v
        end,
        --索引-写
        newindex = baseNewIdx,

        --类构造
        __call = function(t, ...)
            t = setmetatable({ }, c)
--            if ctorStk then for i = 1, #ctorStk do i = ctorStk[i].ctor if i then i(t, ...) end end end
            if ctor then ctor(t, ...) end
            return t
        end,

        --类索引-读
        __index = function(t, k)
            if k == "ctor" then return ctor end
            if k == "super" then return s end
        end,

        --类索引-写
        __newindex = function(t, k, v)
            if type(v) == "function" then
                if k == "ctor" then
                    ctor = v
                    return
                end
                local pk = ssub(k, 1, 4)
                if pk == "get_" then
                    pk = ssub(k, 5)
                    if pk and pk ~= "" then
                        rawset(get, pk, v)
                    end
                elseif pk == "set_" then
                    pk = ssub(k, 5)
                    if pk and pk ~= "" then
                        rawset(set, pk, v)
                    end
                end
            else
                assert(k ~= "ctor", "the class ctor can only be set to function")
            end
            assert(rawget(get, k) == nil and rawget(set, k) == nil, "the class's getter or setter is already exisit the index ["..k.."]")
            rawset(c, k, v)
        end,
    }

    --索引-类
    c.__index, c.__newindex = inf.index, inf.newindex
    --类型检测
    c.is = _is
    --父属性
    get.super = function(t) return s end
    --当前类型
    get.class = function(t) return c end

    --配置类原表
    setmetatable(c, inf)

    --写入类型信息
    _typInf[c] = inf
    --写入类型树
    _typTree[c] = s

    return c
end
--[Comment]
--给定的 类/对象o 是否继承/实现 类s
ois = _is
--[Comment]
--获取给定对象的类
getClass = getClass
--[Comment]
--给定的参数是否是一个类
function isClass(c) return _typInf[c] ~= nil end
