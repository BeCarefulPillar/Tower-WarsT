
local setmetatable = setmetatable
local rawget = rawget
local sqrt = math.sqrt
local acos = math.acos
local max = math.max
local min = math.min
local type = type

local kEpsilon = 1e-5

local _vec = { }
local _get = { }

function _vec.__index(t, k)
	local v = rawget(_vec, k)
	if v == nil then							
		v = rawget(_get, k)
		if v ~= nil then return v(t) end
	end
	return v
end

function _vec.__call(t, x, y) return setmetatable({ x = x or 0, y = y or 0 }, _vec) end

function _vec.New(x, y) return setmetatable({ x = x or 0, y = y or 0 }, _vec) end

function _vec.Set(v, x, y) v.x, v.y = x or 0, y or 0 end

function _vec.Get(v) return v.x, v.y end

function _vec.Scale(v, vs) v.x, v.y = v.x * vs.x, v.y * vs.y end
--[Comment]
--克隆一个新的B_Vector
function _vec.Clone(v) return setmetatable({ x = v.x or 0, y = v.y or 0 }, _vec) end

--[Comment]
--从src复制数据
--src : B_Vector
function _vec.Copy(v, src) v.x, v.y = src.x, src.y end
--[Comment]
--增量
--dv : B_Vector
function _vec.Add(v, dv) v.x, v.y = v.x + dv.x, v.y + dv.y end
--[Comment]
--增量乘数 公式: v = v + dv * m
--dv : B_Vector
--m : number
function _vec.AddMult(v, dv, m) v.x, v.y = v.x + dv.x * m, v.y + dv.y * m end
--获取增量乘数 公式: v = v + dv * m
--dv : B_Vector
--m : number
--return : x, y
function _vec.GetAddMult(v, dv, m) return v.x + dv.x * m, v.y + dv.y * m end

--[Comment]
--归一化向量
local function Normalize(v)
    local m = sqrt(v.x * v.x + v.y * v.y)
	if m > kEpsilon then
		v.x, v.y = v.x / m, v.y / m
    else
        v.x, v.y = 0, 0
	end

    return v
--    return setmetatable({ x = x, y = y }, _vec)
end
--[Comment]
--归一化自身
_vec.Normalize = Normalize

--[Comment]
--二者之间的角度
function _vec.Angle(from, to)
    local x1, y1 = from.x, from.y
    local d = sqrt(x1 * x1 + y1 * y1)
    if d > kEpsilon then
        x1, y1 = x1 / d, y1 / d
    else
        x1, y1 = 0, 0
    end

    local x2, y2 = to.x, to.y
    d = sqrt(x2 * x2 + y2 * y2)
    if d > kEpsilon then
        x2, y2 = x2 / d, y2 / d
    else
        x2, y2 = 0, 0
    end

    d = x1 * x2 + y1 * y2

    if d < -1 then
        d = -1
    elseif d > 1 then
        d = 1
    end

    return acos(d) * 57.29578
end
--[Comment]
--二者之间的距离
function _vec.Distance(a, b) return sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) end
--[Comment]
--二者之间距离的平方
function _vec.Distance2(a, b) return sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) end
--[Comment]
--点乘
function _vec.Dot(lhs, rhs) return lhs.x * rhs.x + lhs.y * rhs.y end

function _vec.Max(a, b) return setmetatable({x = max(a.x, b.x), y = max(a.y, b.y)}, _vec) end

function _vec.Min(a, b) return setmetatable({x = min(a.x, b.x), y = min(a.y, b.y)}, _vec) end

function _vec.__tostring(v) return string.format("(%f,%f)", v.x, v.y) end

function _vec.__div(v, d) return setmetatable({ x = v.x / d, y = v.y / d }, _vec) end

function _vec.__mul(v, d) return type(d) == "number" and setmetatable({ x = v.x * d, y = v.y * d }, _vec) or setmetatable({ x = v * d.x, y = v * d.y }, _vec) end

function _vec.__add(a, b) return setmetatable({ x = a.x + b.x, y = a.y + b.y }, _vec) end

function _vec.__sub(a, b) return setmetatable({ x = a.x - b.x, y = a.y - b.y }, _vec) end

function _vec.__unm(v) return setmetatable({ x = -v.x, y = -v.y }, _vec) end

function _vec.__eq(a, b) return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) < 9.999999e-11 end

--[Comment]
--平方长度
function _get.sqrMagnitude(v) return v.x * v.x + v.y * v.y end
--[Comment]
--长度
function _get.magnitude(v) return sqrt(v.x * v.x + v.y * v.y) end
--[Comment]
--归一化
function _get.normalized(v) return Normalize(setmetatable({ x = v.x, y = v.y }, _vec)) end
--[Comment]
--零向量
function _get.zero(v) return setmetatable({ x = 0, y = 0 }, _vec) end

setmetatable(_vec, _vec)
--[Comment]
--向量
QYBattle.B_Vector = _vec