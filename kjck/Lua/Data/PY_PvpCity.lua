--[Comment]
--最大占领时间
local MAX_OCC_TIME = 21600

local _city =
{
    --[Comment]
    --城池编号 zone = (sn - 10000) / 100,pos = (sn - 10000) % 100
    sn = 0,
    --[Comment]
    --城池区号
    zone = 0,
    --[Comment]
    --城池位置号 1-10 为玩家 ，11与12为附属设施
    pos = 0,
    --[Comment]
    --玩家SN 若是附属设施则为nil
    psn = nil,
    --[Comment]
    --联盟SN
    gsn = nil,
    --[Comment]
    --联盟名称
    gnm = "",
    --[Comment]
    --联盟旗号
    allyBanner = "",
    --[Comment]
    --联盟旗帜
    allyFlag = 0,
    --[Comment]
    --城池类型 0=玩家 1=银矿 2=金矿 3=药园 4=黑市 5=农田
    kind = 0,
    --[Comment]
    --城池名称
    nm = "",
    --[Comment]
    --城池等级
    lv = 0,
    --[Comment]
    --国家官位 0=无 1=国主 2=将军
    ttl = 0,
    --[Comment]
    --占有者编号 大于0有占领者，否则无占领者
    occSN = nil,
    --[Comment]
    --占有者名称
    occNm = "",
    --[Comment]
    --驻守武将数
    heroQty = 0,
    --[Comment]
    --金币产出
    gold = 0,
    --[Comment]
    --占领时间
    occTm = nil,
    --[Comment]
    --保护时间
    proTm = nil,
    --[Comment]
    --道具插旗文本
    ppFlag = nil,
    --[Comment]
    --道具插旗时间
    ppFlagTm = nil,
    --[Comment]
    --道具状态(props,time)
    ppBuf = nil,
}

--[Comment]
--判断给定城池SN是否是PVP城池
local function IsPvpCity(sn) return sn and sn > 1000 end
--[Comment]
--判断给定城池SN是否是PVP城池
_city.IsPvpCity = IsPvpCity
--[Comment]
--给定的区号和位置号是否是可用的
local function IsZonePosAvailable(zone, pos) return zone and pos and zone > 0 and zone <= PVP_MAP_SIZE * PVP_MAP_SIZE and pos > 0 and pos <= 12 end
--[Comment]
--给定的区号和位置号是否是可用的
_city.IsZonePosAvailable = IsZonePosAvailable
--[Comment]
--区号和位置转为城池编号
local function ZonePosToSN(zone, pos) return zone and pos and zone * 1000 + pos or 0 end
--[Comment]
--区号和位置转为城池编号
_city.ZonePosToSN = ZonePosToSN
--[Comment]
--城池编号转区号和位置(返回 zone pos)
local function SNToZonePos(sn)
    if sn then
        local zone, pos =(math.modf(sn / 1000)), sn % 1000
        if zone > 0 and zone <= PVP_MAP_SIZE * PVP_MAP_SIZE and pos > 0 and pos <= 12 then return zone, pos end
    end
    return 0, 0
end
--[Comment]
--城池编号转区号和位置(返回 zone pos)
_city.SNToZonePos = SNToZonePos

local function IsOwn(c) return c.kind == 0 and c.psn == user.psn end
--[Comment]
--是否被占领
local function IsColony(c) return c.occSN and(c.kind ~= 0 or c.occSN ~= c.psn) end

--[Comment]
--构造
function _city.New(sn)
    if "number" == type(sn) then
        local zone, pos = SNToZonePos(sn)
        sn = zone > 0 and pos > 0 and sn or 0
        return { sn = sn, zone = zone, pos = pos, occTm = TimeClock(), proTm = TimeClock(), ppFlagTm = TimeClock() }
    end
end

--[Comment]
--同步精简信息[S_PvpCity]
function _city.SyncBrief(c, dat)
    if dat == nil then return end
    c.psn = CheckSN(dat.psn)
    c.gsn = CheckSN(dat.gsn)
    c.gnm = dat.gnm
    c.allyBanner = dat.allyBanner
    c.allyFlag = dat.allyFlag
    c.kind = dat.kind
    c.nm = dat.nm
    c.lv = dat.lv
    c.ttl = dat.ttl
    c.occSN = CheckSN(dat.occSN) 
    c.proTm.time = dat.proTm or dat.time

    c.ppFlagTm.time = dat.ppFlagTm
    c.ppFlag = dat.ppFlagTm > 0 and dat.ppFlag or nil 
    local dbuf, buf = dat.ppBuf, nil
    if dbuf then 
        local len = math.modf(#dbuf * 0.5) 
        if #dbuf >= 2 then
            buf = {}
            local t 
            for i=1,len do
                t = TimeClock(dbuf[ i * 2 ])
                t.props = dbuf[i*2-1]
                buf[i] = t
            end
        end
    end
    c.ppBuf = buf 
    if IsColony(c) and c.occTm.time <= 0 then
        c.occTm.time = MAX_OCC_TIME
    end

    if IsOwn(c) then
        user.occ = c.occSN
        user.ally.gsn = CheckSN(dat.gsn)
        user.ally.gnm = dat.gnm
    end

    c.changed = true
end
--[Comment]
--同步详细信息[S_PvpCityInfo]
function _city.SyncInfo(c, dat)
    if dat == nil then return end
    c.lv = dat.lv
    c.occSN = CheckSN(dat.occSN)
    c.occNm = dat.occNm
    c.heroQty = dat.heroQty
    c.gold = dat.gold
    c.occTm.time = dat.occTm
    c.proTm.time = dat.proTm

    if IsOwn(c) then
        user.occ = c.occSN
    end

    c.ppFlagTm.time = dat.ppFlagTm
    c.ppFlag = dat.ppFlagTm > 0 and dat.ppFlag or nil
    local dbuf, buf = dat.ppBuf, nil
    if dbuf then
        local len = math.modf(#dbuf * 0.5) 
        if #dbuf >= 2 then
            buf = {}
            local t 
            for i=1,len do
                t = TimeClock(dbuf[ i * 2 ])
                t.props = dbuf[i*2-1]
                buf[i] = t
            end
        end
    end
    c.ppBuf = buf

    c.changed = true
end

--function _city.OnMetabolize(c)
--   if c.occTm.changed and c.occTm.time == 0 then
--       LeaveFromColony(c)
--   end
--   if c.ppFlagTm.changed and c.ppFlagTm.time == 0 then
--       c.ppFlag = nil
--       c.changed = true
--   end
--end

--[Comment]
--设为我的占领城池
function _city.SetToMyColony(c, ...)
    c.occSN = user.psn
    if c.occTm.time <= 0 then c.occTm.time = MAX_OCC_TIME end
    c.changed = true
    local hero = {...}
    if #hero > 0 and IsPvpCity(c.sn) then
        local h
        for i = 1, #hero do
            h = user.GetHero(hero[i])
            if h then h:SetLoc(c.sn) end
        end
    end
end

--[Comment]
--撤离占领
function _city.LeaveFromColony(c, sync)
    if c.kind == 0 and c.psn and c.psn == c.occSN then return end

    if sync then
        SVR.MoveHero(nil, c.sn, 2, function(t)
            if t.success then
                local hero = user.GetCityHero(c.sn)
                if hero and #hero > 0 then for _k, v in ipairs(hero) do v:SetLoc(0) end end
            end
        end)
    else
        local hero = user.GetCityHero(c.sn)
        if hero and #hero > 0 then for _k, v in ipairs(hero) do v:SetLoc(0) end end
    end
    
    c.occSN = nil
    c.occNm = ""
    c.occTm.time = 0
    c.proTm.time = 0

    if IsOwn(c) then user.occ = nil end
    c.changed = true
end
--[Comment]
--设置白旗
function _city.SetPropsFlag(c, flag)
    c.ppFlag = flag
    c.ppFlagTm.time = 86400
    c.changed = true
end
--[Comment]
--设置联盟
function _city.SetAlly(c, sn, nm)
    c.gsn = CheckSN(sn)
    c.gnm = nm
    c.changed = true
end
--[Comment]
--设置等级
function _city.SetLv(c, lv)
    c.lv = lv
    c.changed = true
end
--[Comment]
--设置官阶
function _city.SetTtl(c, ttl)
    c.ttl = ttl
    c.changed = true
end
--[Comment]
--设置武将数量
function _city.SeHeroQty(c, qty)
    c.heroQty = qty
    c.changed = true
end
--[Comment]
--设置产出
function _city.SetGold(c, gold)
    c.gold = gold
    c.changed = true
end

--[Comment]
--属性获取器
_city.__get =
{
    --[Comment]
    --是否已配置数据
    IsSetZoneData = function(c) return c.psn or c.kind ~= 0 end,
    --[Comment]
    --是否是当前玩家的主城
    IsOwn = IsOwn,
    --[Comment]
    --是否是当前玩家占领的城池
    IsMyColony = function(c) return c.occSN == user.psn and not IsOwn(c) end,
    --[Comment]
    --是否被占领
    IsColony = IsColony,

    --[Comment]
    --占领时间
--    OccTime = function(c) return c.occTm.time end,
    --[Comment]
    --保护时间
--    ProTime = function(c) return c.proTm.time end,
    --[Comment]
    --是否被保护
    BeProtected = function(c) return c.kind == 0 and(c.lv < DB.unlock.pvp or (isNumber(c.proTm.time) and c.proTm.time or 0) > 0) end,
    --[Comment]
    --是否可用
    IsAvailable = function(c) return IsPvpCity(c.sn) end,
    --[Comment]
    --是否有BUF
    HasBuff = function(c)
        local buf = c.ppBuf
        if buf then
            local b
            for i = 1, #buf do
                b = buf[i]
                if b.props and b.props > 0 and b.time > 0 then return true end
            end
        end
        return false
    end,

--    PropsFlagTime = function(c) return pFlagTime.time end,
    --   PropsBuff = function(c) return c.ppBuf end,
}

--继承
objext(_city, DataCell)
--[Comment]
--玩家PVP城池
PY_PvpCity = _city
