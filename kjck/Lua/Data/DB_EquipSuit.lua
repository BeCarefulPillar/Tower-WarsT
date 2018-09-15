local _eqs =
{
    --[Comment]
    --编号
    sn = 0,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --简介
    i = "",
    --[Comment]
    --专属武将
    excl = 0,
    --[Comment]
    --套装属性
    att = nil,
}

function _eqs.CheckExcl(h, dbsn)  return h.excl == 0 or h.excl == dbsn  end

--[Comment]
--Item接口(显示名称)
function _eqs.getName(e) return LN(e.nm) end
--[Comment]
--Item接口(显示信息)
function _eqs.getIntro(e) return L(e.i) end
--[Comment]
--ToolTip接口(显示名称和信息)
function _eqs.getPropTip(e)
    return ColorStyle.Rare(LN(e.nm), 6), L(e.i)
end

--继承
objext(_eqs)
--[Comment]
--未定义的
_eqs.undef = _eqs()
--[Comment]
--套装
--[4]={sn=4,nm="玄武",i="",att=ExtAtt({{"bf",21},{"mf",21},{"cf",21}}),excl=0}
DB_EquipSuit = _eqs
