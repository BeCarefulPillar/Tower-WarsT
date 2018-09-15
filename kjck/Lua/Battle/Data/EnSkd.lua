local rawget = rawget
local band = bit.band

local _cond =
{
    T_Atk = 1,
    T_Skill = 2,
    T_DPS = 3,
    T_HP = 4,
    T_SP = 5,
    T_TP = 6,
    T_Time = 8,
    T_HeroCmd = 9,
    T_SoCmd = 10,
}
--[Comment]
--副将技出发条件
QYBattle.BD_SKD_COND = _cond

local _ed = { }

--技能编号
--EnInt sn
        
--技能等级
--int lv
        
--冷却时间
--EnInt cd
        
--触发次数
--EnInt qty
        
--BUF可叠加次数
--EnInt rep
        
--触发条件的源(-1=不需要，1=我方，2=敌方，3=双方)
--int condTag
        
--触发条件
--int[] cond
        
--值
--EnInt[] val

--输出武力系数
--float dpsStr
--输出智力系数
--float dpsWis
--输出统帅系数
--float dpsCap
--输出常量系数
--float dpsCnt

--当前剩余次数
--EnInt curQty
        
--当前CD
--EnInt curCd

--从S_SKD生成加密的副将技数组
--dat : S_SKD数据
--EnInt : 加密整数生成器
function _ed.__call(t, dat, EnInt)
    t = setmetatable(
    {
        sn = EnInt(dat.sn),
        lv = dat.lv or 0,
        cd = EnInt(dat.cd),
        qty = EnInt(dat.qty),
        rep = EnInt(dat.rep),
        condTag = dat.condTag or 0,

        curQty = EnInt(dat.qty),
        curCd = EnInt(dat.cd),

        ava = dat.sn and dat.sn > 0 and dat.cond and dat.cond[1] > 0,
    }, _ed)

    local var = dat.cond
    if var and #var > 0 then
        if var[1] == _cond.T_Time and #var > 1 then
            var[2] = var[2] * 1000
        elseif var[1] == _cond.T_DPS and #var > 4 then
            var[4] = var[4] * 1000
        end
        t.cond = var
    end

    var = dat.val
    if var and #var > 0 then
        t.val = { }
        for i = 1, #var, 1 do t.val[i] = EnInt(var[i]) end
    end

    var = dat.dps
    if var and #var > 0 then
        t.dpsStr = (var[1] or 0) * 0.01
        t.dpsWis = (var[2] or 0) * 0.01
        t.dpsCap = (var[3] or 0) * 0.01
        t.dpsCnt = var[4] or 0
    else
        t.dpsStr, t.dpsWis, t.dpsCap, t.dpsCnt = 0, 0, 0, 0
    end

    return t
end

function _ed.__index(t, k) return rawget(_ed, k) end

--从S_SKD数组生成加密的副将技数组
--dat : S_SKD数组
--EnInt : 加密整数生成器
function _ed.FromArray(dat, EnInt)
    if dat and #dat > 0 then
        local arr = { }
        for i = 1, #dat, 1 do arr[i] = _ed(dat[i], EnInt) end
        return arr
    end
end

--获取输出值
--str : 武力
--wis : 智力
--cap : 统帅
function _ed.GetDps(d, str, wis, cap) return d.dpsStr * str + d.dpsWis * wis + d.dpsCap * cap + d.dpsCnt end
--获取值
function _ed.GetVal(d, idx) idx = d.val and d.val[idx]; return idx and idx.value or 0 end
--获取值 百分比系数
function _ed.GetValPercent(d, idx) idx = d.val and d.val[idx]; return idx and idx.value * 0.01 or 0 end
--获取值 毫秒
function _ed.GetValMS(d, idx) idx = d.val and d.val[idx]; return idx and idx.value * 1000 or 0 end

--获取条件参数
function _ed.GetCond(d, idx) return d.cond and d.cond[idx] or 0 end
--检测原条件
function _ed.NotCondTag(d, tag) return band(d.condTag, tag) == 0 end

--是否可用
function _ed.isAvailable(d) return d.ava and d.curQty.value > 0 end
--是否冷却中
function _ed.isCd(d) return d.curCd.value < d.cd.value end
--获取CD百分比
function _ed.CDPercent(d) return d.cd.value > 0 and d.curCd.value / d.cd.value or 1 end


setmetatable(_ed, _ed)
--[Comment]
--加密副将技
QYBattle.EnSkd =_ed