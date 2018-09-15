local rawget = rawget
local tonumber = tonumber

local BD_Const = QYBattle.BD_Const
local B_Math = QYBattle.B_Math
local B_Util = QYBattle.B_Util

local _es = { }

--技能编号
--</summary>
--EnInt sn
--<summary>
--耗蓝
--</summary>
--EnInt sp
--<summary>
--CD基础值(CD = 100/(智力/220+CD基础值))
--</summary>
--EnInt cd
--<summary>
--持续时间 MS
--</summary>
--EnInt keep
--<summary>
--持续时间 S
--</summary>
--float keepSec
--<summary>
--X范围
--</summary>
--EnInt rangeX
--<summary>
--Y范围
--</summary>
--EnInt rangeY
--<summary>
--五行编号[1:金(伤害) 2:木(冷却) 3:水(恢复) 4:火(效果) 5:土(持续)]
--</summary>
--int fesn
--<summary>
--五行作用值
--</summary>
--int feval

--输出武力系数
--float dpsStr
--输出智力系数
--float dpsWis
--输出统帅系数
--float dpsCap
--输出常量系数
--float dpsCnt
--扩展属性
--string[] exts

--从S_SKC生成加密的武将技数组
--dat : S_SKC数据
--EnInt : 加密整数生成器
--fesn : 五行编号
--feval : 五行值
function _es.__call(t, dat, EnInt, fesn, feval)
    t = setmetatable(
    {
        sn = EnInt(dat.sn),
        sp = EnInt(dat.sp),
        cd = EnInt(dat.cd),
        fesn = fesn or 0,
        feval = feval or 0,

    }, _es)

    local var = fesn == BD_Const.FE_EARTH and (dat.keep * 1000 + feval) or (dat.keep * 1000)
    t.keep = EnInt(var)
    t.keepSec = var * 0.001

    t.exts = dat.ext and dat.ext ~= "" and B_Util.split(dat.ext, ",") or nil
    t.extLen = t.exts and #t.exts or 0

    if dat.range == nil or dat.range == "" then
        t.rangeX, t.rangeY = EnInt(0), EnInt(0)
    else
        var = B_Util.split(dat.range, ",")
        t.rangeX = EnInt(tonumber(var[1]))
        t.rangeY = EnInt(tonumber(var[2]))
    end

    if dat.dps == nil or dat.dps == "" then
        t.dpsStr, t.dpsWis, t.dpsCap, t.dpsCnt = 0, 0, 0, 0
    else
        var = B_Util.split(dat.dps, ",")
        t.dpsStr = (tonumber(var[1]) or 0) * 0.01
        t.dpsWis = (tonumber(var[2]) or 0) * 0.01
        t.dpsCap = (tonumber(var[3]) or 0) * 0.01
        t.dpsCnt = tonumber(var[4]) or 0
    end

    return t
end

function _es.__index(t, k) return rawget(_es, k) end

--从S_HeroSkill数组生成加密的武将技数组
--dat : S_SKC数组
--fes : S_SKC_FE数组
--EnInt : 加密整数生成器
function _es.FromArray(dat, fes, EnInt)
    if dat and #dat > 0 then
        local arr = { }
        if fes and #fes > 0 then
            local fesn, feval
            for i = 1, #dat, 1 do
                fesn, feval = 0, 0
                for j = 1, #fes, 1 do
                    if fes[j].sksn == dat[i].sn then
                        fesn = fes[j].fesn
                        feval = fes[j].val
                        break
                    end
                end
                arr[i] = _es(dat[i], EnInt, fesn, feval)
            end
        else
            for i = 1, #dat, 1 do arr[i] = _es(dat[i], EnInt) end
        end
        return arr
    end
end

--获取输出值
--str : 武力
--wis : 智力
--cap : 统帅
function _es.GetDps(s, str, wis, cap) return s.dpsStr * str + s.dpsWis * wis + s.dpsCap * cap + s.dpsCnt end
--获取输出值(属性万分比)
--str : 武力
--wis : 智力
--cap : 统帅
function _es.GetDpsLow(s, str, wis, cap) return (s.dpsStr * str + s.dpsWis * wis + s.dpsCap * cap) * 0.01 + s.dpsCnt end
--获取扩展属性值 字符串
function _es.GetExtStr(s, idx) return s.exts and s.exts[idx] or "" end
--获取扩展属性值 整型
function _es.GetExtInt(s, idx) return s.exts and tonumber(s.exts[idx]) or 0 end
--获取扩展属性值 百分比系数
function _es.GetExtPercent(s, idx) return s.exts and (tonumber(s.exts[idx]) or 0) * 0.01 or 0 end

--获取扩展属性值 持续时间 SEC To MS 受[五行-土]影响
function _es.GetExtKeepMS(s, idx)
    return s.exts and (tonumber(s.exts[idx]) or 0) * 1000 + (s.fesn == BD_Const.FE_EARTH and s.feval or 0) or 0
end
--获取扩展属性值 持续时间 MS 受[五行-土]影响
function _es.GetExtKeep(s, idx)
    idx = s.exts and tonumber(s.exts[idx]) or 0
    if idx ~= 0 and s.fesn == BD_Const.FE_EARTH then idx = idx + s.feval end
    return idx
end
--获取扩展值 受[五行-木]影响
function _es.GetExtVal(s, idx)
    idx = s.exts and tonumber(s.exts[idx]) or 0
    if idx ~= 0 and s.fesn == BD_Const.FE_WOOD then idx = idx * (1 + s.feval * 0.01) end
    return idx
end
--获取扩展值 四舍五入整型 受[五行-木]影响
function _es.GetExtValInt(s, idx)
    idx = s.exts and tonumber(s.exts[idx]) or 0
    if idx ~= 0 and s.fesn == BD_Const.FE_WOOD then idx = B_Math.round(idx * (1 + s.feval * 0.01)) end
    return idx
end
--获取扩展值 百分比例 受[五行-木]影响
function _es.GetExtValPercent(s, idx) return s.exts and (tonumber(s.exts[idx]) or 0) * 0.01 or 0 end

setmetatable(_es, _es)
--[Comment]
--加密武将技
QYBattle.EnSkc =_es