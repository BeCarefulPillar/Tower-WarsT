local rawget = rawget
local tonumber = tonumber

local B_Util = QYBattle.B_Util
local BD_SKD_COND = QYBattle.BD_SKD_COND

local _es = { }

--技能编号
--EnInt sn
        
--技能等级
--int lv
        
--BUF可叠加次数
--EnInt rep
        
--触发条件的源(-1=不需要，1=我方，2=敌方，3=双方)
--int[] condTag
        
--触发条件
--int[] cond

--触发条件
--int[] cond2
        
--值
--EnInt[] val

--是否激活
--bool active
--Buf1
--BD_Buff buff
--Buf2
--BD_Buff buff2
--动态值
--vals[]
--行为函数
--function action

--从S_SKS生成加密的天机技数组
--dat : S_SKS数据
--EnInt : 加密整数生成器
function _es.__call(t, dat, EnInt)
    t = setmetatable(
    {
        sn = EnInt(dat.sn),
        lv = dat.lv or 0,
        rep = EnInt(dat.rep),
    }, _es)

    local var = dat.cond
    if var and var ~= "" then
        var = B_Util.split(var, "|")
        if #var > 0 then
            t.cond2 = B_Util.split(var[2], ",")
            if t.cond2 then for i = 1, #t.cond2, 1 do t.cond2[i] = tonumber(t.cond2[i]) or 0 end end
            var = B_Util.split(var[1], ",")
            for i = 1, #var, 1 do var[i] = tonumber(var[i]) or 0 end
            if var[1] == BD_SKD_COND.T_Time and #var > 1 then var[2] = var[2] * 1000 end
            t.cond = var
        end
    end
    var = dat.val
    if var and #var > 0 then
        t.val = { }
        for i = 1, #var, 1 do t.val[i] = EnInt(var[i]) end
    end

    t.isAvailable = dat.sn and dat.sn > 0 and t.cond and t.cond[1] and t.cond[1] > 0
    t.active = t.isAvailable

    return t
end

function _es.__index(t, k) return rawget(_es, k) end

--从S_SKS数组生成加密的天机技数组
--dat : S_SKS数组
--EnInt : 加密整数生成器
function _es.FromArray(dat, EnInt)
    if dat and #dat > 0 then
        local arr = { }
        for i = 1, #dat, 1 do arr[i] = _es(dat[i], EnInt) end
        return arr
    end
end

--获取值
function _es.GetVal(s, idx) idx = s.val and s.val[idx]; return idx and idx.value or 0 end
--获取值 百分比系数
function _es.GetValPercent(s, idx) idx = s.val and s.val[idx]; return idx and idx.value * 0.01 or 0 end
--获取值 毫秒
function _es.GetValMS(s, idx) idx = s.val and s.val[idx]; return idx and idx.value * 1000 or 0 end

--获取条件参数
function _es.GetCond(s, idx) return s.cond and s.cond[idx] or 0 end
--获取条件2参数
function _es.GetCond2(s, idx) return s.cond2 and s.cond2[idx] or 0 end

setmetatable(_es, _es)
--[Comment]
--加密天机技
QYBattle.EnSks =_es