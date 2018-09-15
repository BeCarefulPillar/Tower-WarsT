local _esp =
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
function _esp.New(sn, qty)
    local db = nil
    if "number" == type(sn) then
        db = DB.GetEquip(sn)
    else
        db = sn
        assert(db and DB_Equip == getmetatable(db) and db.sn and db.sn > 0, "create PY_EquipSp invalid args [" .. tostring(sn) .. "," .. tostring(qty) .. "]")
        sn = db.sn
    end
    return { dbsn = sn, db = db, __ext = db, qty = qty or 0 }
end

--[Comment]
--设置数量
function _esp.SetQty(e, v) if v and v ~= e.qty then e.qty, e.changed = v, true end end
--[Comment]
--增加/减少数量
function _esp.AddQty(e, v) if v and v ~= 0 then e.qty, e.changed = e.qty + v, true end end

function _esp.ShowData(e) e.db:ShowPiece(e.qty) end

--[Comment]
--Item接口(显示名称)
function _esp.getName(e) return NameStyle.Piece(LN(e.nm)) end
--[Comment]
--Item接口(显示名称)
function _esp.itemName(e) return LN(e.nm) end
--[Comment]
--Item接口(显示信息)
function _esp.getIntro(e) return L(e.i) end

--当前碎片是否能合成
function _esp.Compose(e)
    return e.qty > e.db.piece
end
--根据是否能合成来排序
function _esp.CompareCompose(x, y)
    if x:Compose() and y:Compose() then
        return DB_Equip.Compare(x.db, y.db)
    elseif x:Compose() and not y:Compose() then
        return true
    elseif not x:Compose() and y:Compose() then
        return false
    elseif not x:Compose() and not y:Compose() then 
        return DB_Equip.Compare(x.db, y.db)
    end

    return DB_Equip.Compare(x.db, y.db)
end


--[Comment]
--ToolTip接口(显示名称和信息)
function _esp.getPropTip(e)
    return ColorStyle.Rare(e), L("数量") .. ":" .. (e.qty or 0) .. "\n" .. L("类型") .. ":" .. e:KindName() .. "\n" .. L("属性") .. ":" .. e:GetAttStr() .. "\n" .. L("描述") .. ":" .. L(e.i)
end

function _esp.__tostring(t) return "PY_EquipSp["..(t.dbsn or 0)..","..(t.nm or "")..","..(t.qty or 0).."]" end

--继承
objext(_esp, DataCell)
--[Comment]
--未定义
_esp.undef = setmetatable({ dbsn = 0, qty = 0, db = DB_Equip.undef, __ext = DB_Equip.undef, cellDead = true }, _esp)
--玩家装备碎片
PY_EquipSp = _esp