local math = math
local floor = math.floor

--[Comment]
--战场数学计算
QYBattle.B_Math = 
{
    --[Comment]
    --圆周率
    PI = 3.14159,
    --[Comment]
    --度到弧度
    Deg2Rad = 0.0174533,
    --[Comment]
    --弧度到度
    Rad2Deg = 57.2958,

    --随机函数
    random = math.random,

    --[Comment]
    --向上取整
    ceil = math.ceil,
    --[Comment]
    --向下取整
    floor = floor,
    --[Comment]
    --四舍五入
    round = function(n) return floor(n + 0.5) end,
    --[Comment]
    --取整数与小数部分
    modf = math.modf,
    --[Comment]
    --平方根
    sqrt = math.sqrt,
    --[Comment]
    --幂
    pow = math.pow,
    --[Comment]
    --正弦
    sin = math.sin,
    --[Comment]
    --反正弦
    asin = math.asin,
    --[Comment]
    --余弦
    cos = math.cos,
    --[Comment]
    --反余弦
    acos = math.acos,

    --[Comment]
    --绝对值
    abs = math.abs,
    --[Comment]
    --最小值
    min = math.min,
    --[Comment]
    --最大值
    max = math.max,
    
    --[Comment]
    --钳制值在区间内
    clamp = function(v, min, max) return v <= min and min or v >= max and max or v end, -- return v > min and (v < max and v or max) or min
    --[Comment]
    --钳制值在[0-1]之间
    clamp01 = function(v) return v <= 0 and 0 or v >= 1 and 1 or v end,
    --[Comment]
    --线性取值
    lerp = function(from, to, t) return t <= 0 and from or t >= 1 and to or from + (to - from) * t end, -- return from + (to - from) * (t <= 0 and 0 or t >= 1 and 1 or v)
    --[Comment]
    --弹性取值
    slerp = function(from, to, str, dt)
        if dt > 1 then dt = 1 end
        local ms = floor(dt * 1000 + 0.5)
        dt = 0.001 * str
        for i = 1, ms, 1 do from = from + (to - from) * dt end
        return from
    end,
}