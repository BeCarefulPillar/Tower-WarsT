local _ava =
{
    --[Comment]
    --头像编号
    sn = 0,
    --[Comment]
    --头像名称
    nm = nil,
    --[Comment]
    --头像说明
    i = "",
    --[Comment]
    --稀有度
    rare = 0,
}

--[Comment]
--Item接口(显示名称)
function _ava.getName(a) return LN(a.nm) end
--[Comment]
--Item接口(显示信息)
function _ava.getIntro(a) return L(a.i) end
--[Comment]
--ToolTip接口(显示名称和信息)
function _ava.getPropTip(a) return LN(a.nm), L("说明") .. ":" .. L(a.i) end
    
--继承
objext(_ava)
--[Comment]
--未定义的
_ava.undef = _ava()
--[Comment]
--头像
--[5]={sn=5,nm="小婵",i="客服头像",rare=5},
DB_Avatar = _ava
