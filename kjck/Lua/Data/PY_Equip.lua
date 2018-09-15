local ATT_NM = ATT_NM
local GetEvoAdd = DB_Equip.GetEvoAdd
local _len = table.maxn
local DB = DB

local _equip =
{
    --[Comment]
    --编号
    sn = nil,
    --[Comment]
    --等级
    lv = 0,
    --[Comment]
    --等阶
    evo = 0,
    --[Comment]
    --进阶经验
    evoExp = 0,
    --[Comment]
    --幻化属性
    ecAtt = nil,
    --[Comment]
    --淬炼次数
    ecRst = 0,
    --[Comment]
    --专属锻造星级
    exclStar = 0,

    --[Comment]
    --镶嵌的宝石
    gems = nil,
    --[Coment]
    --宝石孔数量
    slot = 0,

    --[Comment]
    --所属武将
    belong = nil,

    --[Comment]
    --DB数据
    db = nil,
    --名称
    nm = nil,
    --装备类型(1:武器,2:护甲,3:坐骑,4:宝物)
    kind = 0,
    --稀有度
    rare = 0,

--------------------以下为运算值--------------------
    -- 基本武力
    baseStr = 0,
    -- 基本智力
    baseWis = 0,
    -- 基本统帅
    baseCap = 0,
    -- 基本生命
    baseHP = 0,
    -- 基本技力
    baseSP = 0,
    -- 基本兵力
    baseTP = 0,

    --出售价格
    _price = 0,

    --升级需要的银币
    upCoin = 0,
    --升级需要的金币
    upGold = 0,
    --升级成功率
    upOdds = 0,

    --最大淬炼次数
    ecRstMax = 0,

    --升阶花费
    evoCost = 0,
    --升阶需要的最大经验值
    evoExpMax = 0,
    --作为祭品提供的进阶经验
    evoExpSup = 0,

    --专属属性
    exclAtt = nil,
    --专属锻造花费
    exclForgeCost = 0,
}

--[Comment]
--标记为已更改
local function MarkAsChanged(e)
    e.changed = true
    if e.belong then e.belong.changed = true end
end
--[Comment]
--校对基本属性值
local function CheckBaseAtt(e)
    if e == nil then return end
    local db = e.db
    if db == nil then return end

    local lv, evo = e.lv or 0, GetEvoAdd(e.evo)
    e.baseStr = db.str + lv * db.lstr + evo * db.estr
    e.baseWis = db.wis + lv * db.lwis + evo * db.ewis
    e.baseCap = db.cap + lv * db.lcap + evo * db.ecap
    e.baseHP = db.hp + lv * db.lhp + evo * db.ehp
    e.baseSP = db.sp + lv * db.lsp
    e.baseTP = db.tp + lv * db.ltp
end

--[Comment]
--计算出售价格
local function CalcPrice(e)
    if e.lv > 0 then
        local uc = 0
        for i = 0, e.lv - 1 do
            uc = uc + (DB.GetEquipLv(i, e.rare))
        end
        e._price = e.db.price + math.ceil(uc * 0.35)
    else
        e._price = e.db.price
    end
end

--[Comment]
--获取给定的扩展属性值
local function GetExtAtt(e, nm)
    if e == nil or anm == nil then return 0 end
    local v = ExtAtt.Get(e.ecAtt, anm) + ExtAtt.Get(e.exclAtt, anm)
    local gem = e.gems
    if gem then
        local g
        for i = _len(gem), 1, -1 do
            v = v + ExtAtt.Get(DB.GetGem(gem[i]).att)
        end
    end
    return v
end

--[Comment]
--最终武力
local function GetStr(e) return e and e.baseStr + GetExtAtt(e, ATT_NM.Str) or 0 end
--[Comment]
--最终智力
local function GetWis(e) return e and e.baseWis + GetExtAtt(e, ATT_NM.Wis) or 0 end
--[Comment]
--最终统帅
local function GetCap(e) return e and e.baseCap + GetExtAtt(e, ATT_NM.Cap) or 0 end
--[Comment]
--最终生命
local function GetHP(e) return e and e.baseHP + GetExtAtt(e, ATT_NM.HP) or 0 end
--[Comment]
--最终技力
local function GetSP(e) return e and e.baseSP + GetExtAtt(e, ATT_NM.SP) or 0 end
--[Comment]
--最终兵力
local function GetTP(e) return e and e.baseTP + GetExtAtt(e, ATT_NM.TP) or 0 end

--[Comment]
--设置所属
function _equip.Belong(e, h)
    if e and h ~= e.belong then
        local lh = e.belong
        e.belong = h
        e.changed = true
        if lh then lh.changed = true end
    end
end
--[Comment]
--卸载
function _equip.UnEquip(e)
    if e and e.belong then e.belong:UnEquip(e) end
end
--[Comment]
--设置等集
function _equip.SetLv(e, lv)
    if e == nil or lv == nil or lv <= 0 or e.lv == lv then return end
    e.lv = lv
    -- 取得等级相关数据
    e.upCoin, e.upGold, e.upOdds = DB.GetEquipLv(lv, e.rare)
    CheckBaseAtt(e)
    CalcPrice(e)
    MarkAsChanged(e)
end
--[Comment]
--设置进阶经验
function _equip.SetEvoExp(e, exp)
    if e == nil or exp == nil or e.evoExp == exp then return end
    e.evoExp = exp
    MarkAsChanged(e)
end
--[Comment]
--设置等阶
function _equip.SetEvo(e, evo)
    if e == nil or evo == nil or e.evo == evo then return end
    e.evo = evo
    -- 取得等阶相关数据
    e.evoCost, e.evoExpMax, e.evoExpSup = DB.GetEquipEvo(e.evo, e.rare)
    CheckBaseAtt(e)
    MarkAsChanged(e)
end
--[Comment]
--添加幻化属性
function _equip.AddEC(e, att)
    if e == nil or att == nil then return end
    if e.ecAtt == nil then e.ecAtt = ExtAtt() end
    e.ecAtt:Add(att)
    MarkAsChanged(e)
end
--[Comment]
--打宝石孔
function _equip.AddSlot(e)
    if e and e.db.slot then
        e.slot = e.gems and _len(e.gems) or 0
        if e.slot < #e.db.slot then
            if e.gems then
                e.slot = e.slot + 1
                e.gems[e.slot] = 0
            else
                e.slot = 1
                e.gems = { 0 }
            end
            MarkAsChanged(e)
        end
    end
end
--[Comment]
--配置宝石
function _equip.SetGem(e, idx, gem)
    if e and idx and gem and idx > 0 and e.gems and idx <= _len(e.gems) then
        e.gems[idx] = gem
        MarkAsChanged(e)
    end
end
--[Comment]
--进阶祭品校验
function _equip.CheckEvoOblation(e, o) return e and o and e.sn ~= o.sn and e.dbsn == o.dbsn and e.evo == o.evo end
--[Comment]
--锻造祭品校验
function _equip.CheckForgeOblation(e, o) return e and o and e.sn ~= o.sn and e.dbsn == o.dbsn and o.exclStar == 0 end
--[Comment]
--设置专属星级
function _equip.SetExclStar(e, exclStar)
    if e == nil or exclStar == nil or e.exclStar == exclStar then return end
    e.exclStar = exclStar
    -- 取得专属星级相关数据
    e.exclAtt = e.db:GetExclAtt(exclStar + 1)
    e.exclForgeCost = DB.GetEquipFrogeCost(e.rare, exclStar)
    MarkAsChanged(e)
end
--[Comment]
--初始化[d=S_Equip]
local function Init(e, d)
    if e == nil then return end
    if d and e.sn == d.sn and d.dbsn and d.dbsn > 0 then
        table.copy(d, e)
        e.ecAtt = ExtAtt.Parse(d.ecAtt) --幻化属性
    end
        
    --DB数据接入
    d = DB.GetEquip(e.dbsn)
    if d == DB_Equip.undef then print("undef equip [", e.sn, e.dbsn, "]") end
    e.__ext = d
    e.db = d
    e.nm = d.nm
    e.kind = d.kind
    e.rare = d.rare

    -- 取得等级相关数据
    e.upCoin, e.upGold, e.upOdds = DB.GetEquipLv(e.lv, e.rare)
    -- 取得等阶相关数据
    e.evoCost, e.evoExpMax, e.evoExpSup = DB.GetEquipEvo(e.evo, e.rare)  
    -- 取得专属星级相关数据
    e.exclAtt = d:GetExclAtt(e.exclStar)
    e.exclForgeCost = DB.GetEquipFrogeCost(e.rare, e.exclStar)
    --宝石孔数
    e.slot = e.gems and _len(e.gems) or 0

    --校对基本属性值
    CheckBaseAtt(e)

    --校对武将
    if e.csn then
        d = user.GetHero(e.csn)
        if d ~= e.belong then
            if d then d:Equip(e) elseif e.belong then e.belong:UnEquip(e) end
        end
        e.csn = nil
    end

    --计算价格
--    CalcPrice(e)

    e.changed = true
end
--[Comment]
--初始化[d=S_Equip]
_equip.Init = Init
--[Comment]
--构造[d=S_Equip]
function _equip.New(d)
    assert(d and ("string" == type(d.sn)) and d.dbsn and d.dbsn >= 0,
        "new PY_Equip arg ["..(d and tostring(d.sn)..","..tostring(d.dbsn) or "nil").."] err")
    d.ecAtt = ExtAtt.Parse(d.ecAtt) --幻化属性
    Init(setmetatable(d, _equip))
    return d
end

--[Comment]
--标记为已更改
_equip.MarkAsChanged = MarkAsChanged

--[Comment]
--Item接口(显示名称),可给入稀有度
function _equip.getName(e) return NameStyle.Plus(LN(e.nm), e.evo) end
--[Comment]
--用PropTip显示装备数据
function _equip.getPropTip(e)
    return ColorStyle.Rare(e), strng.format("%s:%s\n%s:%d%s\n%s:%d\n%s:%s", L("类型"), e.typeNm or "", L("等级"), e.lv or 0, e.belong and "\n"..L("装备于")..":"..LN(e.belong.nm) or "", L("出售价格"), e.price or 0, L("描述"), L(e.i))
end

--[Comment]
-- 默认武将比较器
function _equip.Compare(x, y)
    if x.rare > y.rare then return true end
    if x.rare < y.rare then return false end
    if x.dbsn < y.dbsn then return true end
    if x.dbsn > y.dbsn then return false end
    if x.evo > y.evo then return true end
    if x.evo < y.evo then return false end
    if x.exclStar > y.exclStar then return true end
    if x.exclStar < y.exclStar then return false end
    return x.lv > y.lv
end
--[Comment]
--  默认的反向排序
function _equip.CompareInv(x, y)
    if x.rare > y.rare then return false end
    if x.rare < y.rare then return true end
    if x.dbsn < y.dbsn then return false end
    if x.dbsn > y.dbsn then return true end
    if x.evo > y.evo then return false end
    if x.evo < y.evo then return true end
    if x.exclStar > y.exclStar then return false end
    if x.exclStar < y.exclStar then return true end
    return x.lv < y.lv
end

--获取器对接
local _get = { }

_get.str = GetStr
_get.wis = GetWis
_get.cap = GetCap
_get.hp = GetHP
_get.sp = GetSP
_get.tp = GetTP

--装备是否满级
_get.IsMaxLv = function(e) return e.lv >= DB.maxEquipLv end
--是否等级极限
_get.IsLvLmt = function(e) return e.lv >= user.hlv end
--是否可升级
_get.CanUpLv = function(e) return e.lv < user.hlv and user.IsSmithyUL end
--是否可进阶
_get.CanEvo = function(e) return e.rare > 3 and e.evo < DB.param.mlvEqpEvo end

--出售价格
_get.price = function(e) if e._price == 0 then CalcPrice(e) end; return e._price end

--当前幻化数量
_get.CurEcQty = function(e) return e.ecAtt and #e.ecAtt or 0 end
--最大幻化数量
_get.MaxEcQty = function(e) return e.db and e.db.ecQty or 0 end
--剩余淬炼次数
_get.EcRstRemain = function(e) return e.ecRstMax - e.ecRst end

--是否专属激活
_get.ExclActive = function(e)  return e.belong and e.belong.dbsn == e.db.excl and CheckSN(user.ally.gsn) ~= nil end
--是否可专属锻造
_get.CanExclForge = function(e)  return e.exclAtt ~= nil and #e.exclAtt > 0 and e.exclStar < e.db:MaxExclStar() end
--是否满级锻造
_get.IsMaxExclStar = function(e) return e.exclStar >= e.db:MaxExclStar() end

--是否有外框特效
_get.HasFrameEffect = function(e) return e.lv >= DB.maxEquipLv or (e.ecAtt and #e.ecAtt > 0) or _get.ExclActive(e) end

--是否已装备
_get.IsEquiped = function(e) return e.belong and e.belong.sn end
--套装是否激活
_get.SuitActive = function(e)
    local h = e and e.belong or nil
    if h then
        local suit = e.db.suit
        return suit and suit > 0 and h:GetSuitQty(suit) > 1 and DB.GetEquipSuit(suit):CheckExcl(h.dbsn)
    end
    return false
end

--配置获取器
_equip.__get = _get
--继承
objext(_equip, DataCell)
--[Comment]
--玩家装备对象
PY_Equip = _equip

