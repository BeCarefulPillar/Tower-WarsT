
--[Comment]
--名称/文本 样式
NameStyle =
{
    --[Comment]
    --扩展名称样式(xx+1),若plus为nil或0则为原名
    Plus = function(nm, plus) return plus and plus > 0 and nm.."+"..plus or nm end,
    --[Comment]
    --等级标签(Lv1)
    LvTag = function(lv) return "Lv"..(lv or 0) end,
    --[Comment]
    --数量标签(x1)
    QtyTag = function(qty) return "x"..(qty or 0) end,
    --[Comment]
    --扩展标签(+1)
    PlusTag = function(plus) return "+"..(plus or 0) end,
    --[Comment]
    --将星名称
    HeroStar = function(lv) return string.format(L("%s星%s级"), DB_HeroStar.GetStar(lv), DB_HeroStar.GetLv(lv)) end,

    --[Comment]
    --将魂
    Soul = function(nm) return nm.."("..L("将魂")..")" end,
    --[Comment]
    --碎片
    Piece = function(nm) return nm.."("..L("碎片")..")" end,
    --[Comment]
    --残片
    Frag = function(nm) return nm.."("..L("残片")..")" end,
    --[Comment]
    --经验
    Exp = function(nm) return nm.."("..L("经验")..")" end,
}