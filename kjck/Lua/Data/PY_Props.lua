local _props =
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
function _props.New(sn, qty)
    local db = nil
    if "number" == type(sn) then
        db = DB.GetProps(sn)
    else
        db = sn
        assert(db and DB_Props == getmetatable(db) and db.sn and db.sn > 0, "create PY_Props invalid args [" .. tostring(db).. "," ..(db and db.sn) .. "," .. tostring(qty) .. "]")
        sn = db.sn
    end
    return { dbsn = sn, db = db, __ext = db, qty = qty or 0 }
end

--[Comment]
--设置数量
function _props.SetQty(p, v) if v and v ~= p.qty then p.qty, p.changed = v or 0, true end end
--[Comment]
--增加/减少数量
function _props.AddQty(p, v) if v and v ~= 0 then p.qty, p.changed = p.qty + v, true end end

--继承
objext(_props, DataCell)
--[Comment]
--未定义
_props.undef = setmetatable({ dbsn = 0, qty = 0, db = DB_Props.undef, __ext = DB_Props.undef, cellDead = true }, _props)
--玩家道具
PY_Props = _props