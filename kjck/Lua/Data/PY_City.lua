local _city =
{
    --[Comment]
    --编号
    sn = 0,
    --[Comment]
    --等级
    lv = 0,
    --[Comment]
    --武将数
    heroQty = 0,
    --[Comment]
    --副本数
    fbQty = 0,
    --[Comment]
    --副本难度
    fbDif = 0,
    --[Comment]
    --搜索时间
    searchTm = nil,
    --[Comment]
    --活动奖励
    actRws = nil,
    --[Comment]
    --升级花费
    upCost = 0,
    --[Comment]
    -- 可扫荡难度（挑战赢了哪个难度，判断是否能扫荡。0：都没过，1：过简单，2：过普通，3：过困难）
    diffLv = 0,

    --[Comment]
    --DB数据
    db = nil,
}

--[Comment]
--计算产出
local function CalcCrop(db, lv) return math.ceil((db.crop +(lv > 1 and lv - 1 or 0) * db.cropG) *(1 + user.VipData.cropInc * 0.01)) end
--[Comment]
--计算升级花费
local function CalcUpCost(db, lv) return Mathf.Round(Mathf.Round(db.exp + db.exp * 0.0001 * db.exp * lv * lv)) end

--[Comment]
--设置武将数量
local function SetHeroQty(c, qty)
    if qty == c.heroQty then return end
    c.heroQty = qty or 0
    c.changed = true
end
--[Comment]
--设置武将数量
_city.SetHeroQty = SetHeroQty
--[Comment]
--设置副本数量
local function SetFbQty(c, qty)
    if qty == c.fbQty then return end
    c.fbQty = qty or 0
    c.changed = true
end
--[Comment]
--设置副本数量
_city.SetFbQty = SetFbQty
--[Comment]
--设置副本难度
local function SetFbDif(c, dif)
    if dif == c.fbDif then return end
    c.fbDif = qty or 0
    c.changed = true
end
--[Comment]
--设置副本难度
_city.SetFbDif = SetFbDif
--[Comment]
--设置城池等级
local function SetLv(c, lv)
    if lv == c.lv then return end
    c.lv = lv or 0
    c.crop = CalcCrop(c.db, lv);
    c.upCost = CalcUpCost(c.db, lv)
    c.changed = true
end
--[Comment]
--设置城池等级
_city.SetLv = SetLv

--[Comment]
--构造
function _city.New(sn)
    local db = nil
    if "number" == type(sn) then
        db = DB.GetGmCity(sn)
    else
        db = sn
        assert(db and DB_City == getmetatable(db) and db.sn and db.sn > 0, "create PY_City invalid args [" .. tostring(sn) .. "]")
        sn = db.sn
    end
    return { sn = sn, db = db, __ext = db, searchTm = TimeClock(0, true) }
end

--[Comment]
--从地图数据更新[S_LevelMapInfo.mapInfo][d=S_LevelCity]
function _city.SyncMap(c, d)
    if d and c.sn == d.sn then
        c.heroQty = d.heroQty
        c.fbQty = d.fbQty
        c.fbDif = d.fbDif
        c.searchTm.time = d.tm
        SetLv(c, d.lv)
        c.actRws = ExtAtt.Parse(d.actRws)
    end
end
--[Comment]
--从主城同步的数据更新[d=S_Territory]
function _city.SyncTer(c, d)
    if d and c.sn == d.sn then
        SetLv(c, d.lv)
        c.crop = d.crop
        c.searchTm.time = d.tm
    end
end
--[Comment]
--从副本同步数据[d=S_CityFB]
function _city.SyncFB(c, d)
    if d and c.sn == d.sn then
        c.fbQty = d.fbQty
        c.fbDif = d.fbDif
        c.actRws = ExtAtt.Parse(d.actRws)
        c.diffLv = d.diffLv
    end
end
--[Comment]
--重算武将数
function _city.CalcHeroQty(c) SetHeroQty(c, user.GetCityHeroQty(c.sn)) end
--[Comment]
--重置收获时间，用于城池收获之后
function _city.RestSearchTime(c) c.searchTm.time = 0 end
--[Comment]
--根据城池编号和城池等级计算城池产出
function _city.CalcCrop(sn, lv) return CalcCrop(DB.GetGmCity(sn), lv) end

--属性获取器
_city.__get =
{
    --[Comment]
    --当前已产出
    HasCrop = function(c) return math.min(c.searchTm.time / DB.param.cdCityCrop, DB.param.qtyCityCrop) * c.crop end,
    --[Comment]
    --收获冷却时间
    SearchTime = function(c) return math.max(0, DB.param.cdCityCrop - c.searchTm.time) end,
    --[Comment]
    --是否可收获
    CanSearch = function(c) return c.sn > 1 and c.searchTm.time > DB.param.cdCityCrop + 3 end,
    --[Comment]
    --特殊副本标识
    FbSpecial = function(c) return c.actRws and L("活动") or c.db.fb end,
    --[Comment]
    --副本奖励
    FbRewards = function(c) return c.actRws and actRws or c.db.rwFB end,
}

--继承
objext(_city, DataCell)
--[Comment]
--玩家PVE城池
PY_City = _city