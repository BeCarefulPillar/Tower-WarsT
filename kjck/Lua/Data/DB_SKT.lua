local _skt =
{
    --序列号
    sn = 0,
    --名称
    nm = nil,
    --介绍
    i = "",
    --军师技的作用对象
    trg = nil,
}

function _skt.getName(s) return LN(s.nm) end
function _skt.getIntro(s) return L(s.i) end
function _skt.getPropTip(s)
    return LN(s.nm), L("类型") .. ":" .. L("军师技") .. "\n" .. L("目标") .. ":" ..(s.trg or L("未知")) .. "\n" .. L("说明") .. ":" .. L(s.i)
end

--继承
objext(_skt)
--[Comment]
--未定义的
_skt.undef = _skt()
--[Comment]
--军师技
--[11]={sn=11,nm="损兵益将",i="损失一半的兵力使武将武力、智力、统帅生命大幅上升",trg="武将"},
DB_SKT = _skt