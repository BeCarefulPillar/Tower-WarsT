local function _new(c, ...)
    local ins = setmetatable( { }, c)
    ins:init(...)
    return ins
end

local function _init(c)
    if c.base then
        c.base:init()
    end
end

function class(c, s)
    assert(c,"c is nil")
    assert(c.cnm,"c.cnm is nil")
    assert(c.cnm~="","c.cnm is ''")
    c.__index = c
    c.new = _new
    if c.init == nil then
        c.init = _init
    end
    if s then
        assert(s.base, "base need class(s)")
        setmetatable(c, s)
        c.base = s
    else
        setmetatable(c, object)
        c.base = object
    end
end

function objt(c)
    return c and getmetatable(c)
end

function objis(a, b)
    return objt(a) == objt(b)
end

--- <summary>a:子类 b:父类</summary>
function objsub(a, b)
    if a == nil or b == nil then
        return false
    end
    while a do
        if objis(a, b) then
            return true
        end
        a = getmetatable(a)
    end
    return false
end