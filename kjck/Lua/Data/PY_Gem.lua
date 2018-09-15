local _gem =
{
    --[Comment]
    --DB编号
    dbsn = 0,
    --[Comment]
    --数量
    qty = 0
}

--[Comment]
--构造
function _gem.New(sn, qty)
    local db = nil
    if "number" == type(sn) then
        db = DB.GetGem(sn)
    else
        db = sn
        assert(db and DB_Gem == getmetatable(db) and db.sn and db.sn > 0, "create PY_Gem invalid args [" .. tostring(sn) .. "," .. tostring(qty) .. "]")
        sn = db.sn
    end
    return { dbsn = sn, db = db, __ext = db, qty = qty or 0 }
end

--[Comment]
--设置数量
function _gem.SetQty(g, v) if v and v ~= g.qty then g.qty, g.changed = v, true end end
--[Comment]
--增加/减少数量
function _gem.AddQty(g, v) if v and v ~= 0 then g.qty, g.changed = g.qty + v, true end end

--继承
objext(_gem, DataCell)
--[Comment]
--未定义
_gem.undef = setmetatable({ dbsn = 0, qty = 0, db = DB_Gem.undef, __ext = DB_Gem.undef, cellDead = true }, _gem)
--玩家宝石
PY_Gem = _gem