local rawget = rawget
local setmetatable = setmetatable
local type = type
local min = math.min

local Rect = 
{
    x = 0,
    y = 0,
    width = 0,
    height = 0,
}

local get = tolua.initget(Rect)

Rect.__index = function(t, k)
	local var = rawget(Rect, k)
	if var == nil then
		var = rawget(get, k)
		return var and var(t)
	end
	return var
end

Rect.__call = function(t, x, y, w, h) return setmetatable( { x = x or 0, y = y or 0, width = w or 0, height = h or 0 }, Rect) end

function Rect.New(x, y, w, h) return setmetatable( { x = x or 0, y = y or 0, width = w or 0, height = h or 0 }, Rect) end

function Rect.Get(r) return r.x, r.y, r.width, r.height end

function Rect.Set(r, x, y, w, h) r.x, r.y, r.width, r.height = x or 0, y or 0, w or 0, h or 0 end

function Rect.GetCenter(r) return Vector2(r.x + r.width * 0.5, r.y + r.height * 0.5) end
function Rect.SetCenter(r, v) r.x, r.y = v.x - r.width * 0.5, v.y - r.height * 0.5 end

function Rect.GetMax(r) return Vector2(r.x + r.width, r.y + r.height) end
function Rect.SetMax(r, v) r.width, r.height = v.x - r.x, v.y - r.y end

function Rect.GetMin(r) return Vector2(r.x, r.y) end
function Rect.SetMin(r, v) r.x, r.y = v.x, v.y end

Rect.SetPosition = SetMin

function Rect.GetSize(r) return Vector2(r.width, r.height) end
function Rect.SetSize(r, v) r.width, r.height = v.x, v.y end

function Rect.GetXMin(r) return r.x end
function Rect.SetXMin(r, v) r.x = v end

function Rect.GetYMin(r) return r.y end
function Rect.SetYMin(r, v) r.y = v end

function Rect.GetXMax(r) return r.x + r.width end
function Rect.SetXMax(r, v) r.width = v - r.x end

function Rect.GetYMax(r) return r.y + r.height end
function Rect.SetYMax(r, v) r.height = v - r.y end

function Rect.MinMaxRect(xmin, ymin, xmax, ymax) return setmetatable( { x = xmin or 0, y = ymin or 0, width = (xmax or 0) -(xmin or 0), height = (ymax or 0) -(ymin or 0) }, Rect) end
--[Comment]
--通过给定矩形和归一坐标获取真实坐标
function Rect.NormalizedToPoint(r, n) return Vector2(n.x <= 0 and r.x or n.x >= 1 and r.x + r.width or r.x + r.width * n.x, n.y <= 0 and r.y or n.y >= 1 and r.y + r.height or r.y + r.height * n.y) end
--[Comment]
--通过给定矩形和点获取相对矩形的归一坐标
function Rect.PointToNormalized(r, p) return Vector2(r.width > 0 and p.x > r.x and min(1, (p.x - r.x) / r.width) or 0, r.height > 0 and p.y > r.y and min(1, (p.y - r.y) / r.height) or 0) end

--[Comment]
--点是否在矩形区域内
--allowInverse : 当矩形高宽为负数时也有效
function Rect.Contains(r, vec, allowInverse)
    if allowInverse then
        if r.width == 0 or r.height == 0 then return false end
--        local x1, x2, y1, y2
--        if r.width > 0 then x1, x2 = r.x, r.x + r.width else x1, x2 = r.x + r.width, r.x end
--        if r.height > 0 then y1, y2 = r.y, r.y + r.height else y1, y2 = r.y + r.height, r.y end
--        return vec.x >= x1 and vec.y >= y1 and vec.x <= x2 and vec.y <= y2
        if r.width > 0 then
            if r.height > 0 then return vec.x >= r.x and vec.y >= r.y and vec.x <= r.x + r.width and vec.y <= r.y + r.height end
            return vec.x >= r.x and vec.y <= r.y and vec.x <= r.x + r.width and vec.y >= r.y + r.height
        end
        if r.height > 0 then return vec.x <= r.x and vec.y >= r.y and vec.x >= r.x + r.width and vec.y <= r.y + r.height end
        return vec.x <= r.x and vec.y <= r.y and vec.x >= r.x + r.width and vec.y >= r.y + r.height
    end
    return r.width > 0 and r.height > 0 and vec.x >= r.x and vec.y >= r.y and vec.x <= r.x + r.width and vec.y <= r.y + r.height
end

--[Comment]
--矩形是否有重叠是
--allowInverse : 当矩形高宽为负数时也有效
function Rect.Overlaps(r, rect, allowInverse)
    if allowInverse then
        if r.width == 0 or r.height == 0 or rect.width == 0 or rect.height == 0 then return false end
        local ix1, mx1, iy1, my1, ix2, mx2, iy2, my2
        if r.width > 0 then ix1, mx1 = r.x, r.x + r.width else ix1, mx1 = r.x + r.width, r.x end
        if r.height > 0 then iy1, my1 = r.y, r.y + r.height else iy1, my1 = r.y + r.height, r.y end
        if rect.width > 0 then ix2, mx2 = rect.x, rect.x + rect.width else ix2, mx2 = rect.x + rect.width, rect.x end
        if rect.height > 0 then iy2, my2 = rect.y, rect.y + rect.height else iy2, my2 = rect.y + rect.height, rect.y end
        return ix1 < mx2 and ix2 < mx1 and iy1 < my2 and iy2 < my1
    end
    return r.width > 0 and r.height > 0 and rect.width > 0 and rect.height > 0 and r.x < rect.x + rect.width and rect.x < r.x + r.width and r.y < rect.y + rect.height and rect.y < r.y + r.height
end

Rect.__eq = function(a, b)
	local dx, dy = a.x - b.x, a.y - b.y
    if dx * dx + dy * dy >= 1e-10 then return false end
    dx, dy = a.width - b.width, a.height - b.height
    return dx * dx + dy * dy < 1e-10
end

Rect.__tostring = function(r) return "(x:"..r.x..", y:"..r.y..", width:"..r.width..", height:"..r.height..")" end

get.zero = Rect

get.center = Rect.GetCenter
get.max = Rect.GetMax
get.min = Rect.GetMin
get.position = Rect.GetMin
get.size = Rect.GetSize
get.xMin = Rect.GetXMin
get.yMin = Rect.GetYMin
get.xMax = Rect.GetXMax
get.yMax = Rect.GetYMax

UnityEngine.Rect = Rect
setmetatable(Rect, Rect)
AddValueType(Rect, 13)
return Rect