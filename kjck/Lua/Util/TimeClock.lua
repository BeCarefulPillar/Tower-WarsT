local now = os.time
local fmt = string.format

local function GetTmAdd(t) return t.tm + now() end
local function Sub(a, b) return a > b and a - b or 0 end
local function GetTmSub(t) return Sub(t.tm, now()) end

--[Comment]
--将时间输出成计时字符串(时:分:秒)
local function TimeToString(t)
    local s, m, h = t % 60,(t / 60) % 60, t / 3600
    return fmt("%02d:%02d:%02d", h, m, s)
end

--[Comment]
--计时器
TimeClock =
{
    --[Comment]
    --时间值(S)
    tm = 0,
    --[Comment]
    --是否是增量
    isAdd = nil,

    --[Comment]
    --构造函数
    __call = function(t, tm, add)
        return setmetatable({ isAdd = add, tm = (tm or 0) +(add and - now() or now()), Time = add and GetTmAdd or GetTmSub }, TimeClock)
    end,
    --[Comment]
    --取值
    __index = function(t, k) 
        return "time" == k and t:Time()
    end,
    --[Comment]
    --写值
    __newindex = function(t, k, v)
        if "time" == k then
            t.tm = v +(t.isAdd and - now() or now())
            return
        end
        rawset(t, k, v)
    end,
    --[Comment]
    --转字符串
    __tostring = function(t) return TimeToString(t:Time()) end,

    --[Comment]
    --设置时间
    SetTime = function(t, v) t.tm = v +(t.isAdd and - now() or now()) end,

    --[Comment]
    --是否计时结束
    IsOver = function(t) if t.isAdd then return false end; return t.tm <= now() end,

    ToString = function(t) return TimeToString(t:Time()) end,

    --[Comment]
    --将时间输出成计时字符串(时:分:秒)
    TimeToString = TimeToString,
    --[Comment]
    --将时间输出成计时字符串(分:秒)
    TimeToMS = function(t)
        local s, m = t % 60,(t / 60)
        return fmt("%02d:%02d", m, s)
    end,
    --[Comment]
    --将时间输出成计时字符串(天时分秒)
    TimeToDHMS = function(t)
        local s, m, h, d = t % 60,(t / 60) % 60,(t / 3600) % 24, t / 86400
        return fmt("%d天%d时%d分%d秒", d, h, m, s)
    end,
    --[Comment]
    --将时间输出成计时字符串
    TimeToSmart = function(t)
        return t > 86400 and(math.modf(t / 86400)) .. "天" or TimeToString(t)
    end
}

setmetatable(TimeClock, TimeClock)