--此脚本仅做数据参考，不实际运行使用
local _aqst =
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
   --任务指引
    guide = nil,
   --[Comment]
   --任务分组
    grp = 0,
   --[Comment]
   --任务类型
    kind = 0,
   --[Comment]
   --任务稀有度
    rare = 0,
   --[Comment]
   --目标值
    trg = 0,
   --[Comment]
   --奖励接口
    rws = nil
}

--[Comment]
--通过分组和稀有度算得编号
function _aqst.GetSnFromGR(grp, rare) return grp * 1000 + rare end

function _aqst.getName(q) return LN(q.nm) end
function _aqst.getIntro(q) return L(q.i) end

--继承
objext(_aqst)
--[Comment]
--未定义的
_aqst.undef = _aqst()
--[Comment]
--联盟悬赏任务
-- 示例 [2005]={sn=2005,nm="战术家",i="在国战中使用一次计谋",guide="AtkNat",rws={{1,9,100},{14,1,500}},grp=2,kind=0,rare=5,trg=1},
DB_AllyQst = _aqst