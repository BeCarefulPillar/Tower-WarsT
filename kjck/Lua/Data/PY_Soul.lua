local _soul =
{
    --[Comment]
    --DB编号
    dbsn = 0,
    --[Comment]
    --数量
    qty = 0,
}

--[Comment]
--构造
function _soul.New(sn, qty)
    local db = nil
    if "number" == type(sn) then
        db = DB.GetHero(sn)
    else
        db = sn
        assert(db and DB_Hero == getmetatable(db) and db.sn and db.sn > 0, "create PY_Soul invalid args [" .. tostring(db) .. "," .. tostring(qty) .. "]")
        sn = db.sn
    end
    return { dbsn = sn, db = db, __ext = db, qty = qty or 0 }
end

--[Comment]
--设置数量
function _soul.SetQty(s, v) if v and v ~= s.qty then s.qty, s.changed = v, true end end
--[Comment]
--增加/减少数量
function _soul.AddQty(s, v) if v and v ~= 0 then s.qty, s.changed = s.qty + v, true end end

--[Comment]
--Item接口(显示用的名称)
function _soul.getName(s) return NameStyle.Soul(LN(s.nm)) end
--[Comment]
--Item接口(显示用的名称)
function _soul.itemName(s) return LN(s.nm) end
--[Comment]
--ToolTip接口(显示用的信息)
function _soul.getPropTip(s, qty)
    qty = qty or s.qty
    local nm = LN(s.nm)
    return ColorStyle.Rare(NameStyle.Soul(nm), s.rare),
    string.format("%s:%s%s\n%s:%s", L("类型"), L("将魂"), qty and qty > 0 and "\n" .. L("数量") .. ":" .. tostring(qty) or "", L("说明"), string.format(L("用于觉醒%s，提升%s将星，或分解为魂币"), nm, nm))
end

--继承
objext(_soul, DataCell)
--[Comment]
--未定义
_soul.undef = setmetatable({ dbsn = 0, qty = 0, db = DB_Hero.undef, __ext = DB_Hero.undef, cellDead = true }, _soul)
--玩家将魂
PY_Soul = _soul