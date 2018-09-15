local abs = math.abs
local modf = math.modf
local rawget = rawget

local MBIG = 0x7FFFFFFF
local MSEED = 161803398

local _rnd = { seed = 0 }

function _rnd.__index(t, k) return rawget(_rnd, k) end
--_rnd.__index = _rnd

function _rnd.__call(t, seed)
    local seedArr = { }
    local ii = seed > -2147483648 and seed < MBIG and math.abs(seed) or MBIG
    local mj, mk = MSEED - ii, 1
    seedArr[55] = mj
    for i = 1, 54 do
        ii = (21 * i) % 55
        seedArr[ii] = mk
        mk = mj - mk
        if mk < 0 then mk = mk + MBIG end
        mj = seedArr[ii]
    end
    for k = 1, 4 do
        for i = 1, 54 do
            ii = seedArr[i] - seedArr[1 + (i + 30) % 55]
            if ii < 0 then ii = ii + MBIG end
            seedArr[i] = ii
        end
    end
    return setmetatable({ seed = seed, seedArr = seedArr, inext = 0, inextp = 21 }, _rnd)
end

local function InternalSample(r)
    local locINext, locINextp = r.inext + 1, r.inextp + 1
    if locINext > 55 then locINext = 1 end
    if locINextp > 55 then locINextp = 1 end
    local seedArr = r.seedArr
    local ret = seedArr[locINext] - seedArr[locINextp]
    if ret == MBIG then ret = ret - 1 end
    if ret < 0 then ret = ret + MBIG end
    seedArr[locINext] = ret
    r.inext = locINext
    r.inextp = locINextp
    return ret
end

--local function GetSampleForLargeRange(r)
--    local ret = InternalSample(r)
--    if InternalSample(r) % 2 == 0 then ret = -ret end
--    return (ret + 2147483646) / 4294967293
--end

--local function Sample(r) return InternalSample(r) / MBIG end

--[Comment]
--m=nil n=nil : 返回[0(包括)-Int32.MaxValue(不包括)]之间的值
--n=nil : 返回[0(包括)-m(不包括)]之间的值
--返回[m(包括)-n(不包括)]之间的值
function _rnd.NextInt(r, m, n)
    r = InternalSample(r)
    if m then
        if n then
            return m < n and (modf(m + r * (n - m) / MBIG)) or m
        else
            return m > 0 and (modf(r * m / MBIG)) or 0
        end
    end
    return r
end
--[Comment]
--m=nil n=nil : 返回[0(包括)-1(不包括)]之间的值
--n=nil : 返回[0(包括)-m(不包括)]之间的值
--返回[m(包括)-n(不包括)]之间的值
function _rnd.Next(r, m, n)
    r = InternalSample(r) / MBIG
    if m then
        if n then
            return m < n and m + r * (n - m) or m
        else
            return m > 0 and r * m or 0
        end
    end
    return r
end

setmetatable(_rnd, _rnd)
--[Comment]
--随机数
QYBattle.B_Random = _rnd