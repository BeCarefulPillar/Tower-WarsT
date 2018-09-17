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

function class(c, base)
    if type(c) == "table" and string.notEmpty(c.cnm) then
        c.__index = c
        c.new = _new
        if c.init==nil then
            c.init = _init
        end
        if type(base) == "table" and string.notEmpty(c.cnm) then
            setmetatable(c, base)
            c.base = base
        else
            setmetatable(c, object)
            c.base = object
        end
    end
end

function objt(c)
    return c and getmetatable(c)
end

function objis(a,b)
    return objt(a)==objt(b)
end

---<summary>a:子类 b:父类</summary>
function objsub(a,b)
    if a==nil or b==nil then
        return false
    end
    while a do
        if objis(a,b) then
            return true
        end
        a = getmetatable(a)
    end
    return false
end