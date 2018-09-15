local _skc =
{
    --[Comment]
    --序列号
    sn = 0,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --介绍
    i = "",
    --[Comment]
    --将星技能能附加描述(仅限武将技)
    si = "",
    --[Comment]
    --基本消耗(武将技为技力值，锦囊技为精力值)
    sp = 0,
    --[Comment]
    --将星升级后的耗蓝(仅限武将技)
    sps = 0,
    --[Comment]
    --战场BUF
    buf = nil,
    --[Comment]
    --可用五行
    fes = nil,
    --[Comment]
    --五行特别描述
    fi = nil,
}

--[Comment]
--根据是否将星获取耗蓝
function _skc.GetCost(s, star) return star and s.sps or s.sp end
--[Comment]
--获取战场BUF
function _skc.GetBattleBuff(s, idx) return s.buf and s.buf[idx] or nil end

function _skc.getName(s) return LN(s.nm) end
function _skc.getIntro(s) return L(s.i) end
function _skc.getPropTip(s, fe)
    local str = ""
    if fe and fe > 0 then
        fe = DB.GetFe(fe)
        if fe and fe.sn > 0 then
            str = str .. "\n" .. L("五行") .. ":" ..(fe.nm or L("未知"))
        end
    end
    return LN(s.nm), L("类型") .. ":" .. L("武将技") .. "\n" .. L("技力") .. ":" .. s.sp .. str .. "\n" .. L("说明") .. ":" .. L(s.i)
end

--继承
objext(_skc)
--[Comment]
--未定义的
_skc.undef = _skc()
--[Comment]
--武将技
--[58]={sn=58,i="召唤一大阵凤凰状火焰冲击敌阵，对经过的所有敌人造成伤害并附加灼烧效果(伤害受智力影响)",si="凤求凰命中目标后灼烧时间增加1秒",sp=30,sps=30,buf={{17}}},
DB_SKC = _skc