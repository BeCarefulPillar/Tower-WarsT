local ipairs = ipairs
local insert = table.insert
local remove = table.remove

local _nat =
{
    --[Comment]
    --国家等级
    lv = 0,
    --[Comment]
    --玩家当前粮草
    food = 0,
    --[Comment]
    --粮草上限
    foodMax = 0,
--    --[Comment]
--    --征收粮草时间戳
--    getFoodTs = 0,
    --[Comment]
    --征收粮草次数
    getFoodQty = 0,
    --[Comment]
    --购买粮草次数
    buyFoodQty = 0,
    --[Comment]
    --购买粮草价格
    buyFoodPrice = 0,
    --[Comment]
    --突袭时间
    raidTm = 0,
    --[Comment]
    --血战CD
    bloodCD = 0,
    --[Comment]
    --血战时间
    bloodTm = nil,
    --[Comment]
    --血战目标城池
    bloodCity = 0,
    --[Comment]
    --血战是否暂停
    bloodPause = 0,
    --[Comment]
    --国战城池
    city = nil,
    --[Comment]
    --国战NPC
    npc = nil,
    --[Comment]
    --免费分身数量
    copyQty = 0,
    --[Comment]
    --酒
    wine = 0,

    --[Comment]
    --国战任务城池
    questCity = nil,
    --[Comment]
    --国战旗帜城池
    flagCity = nil,
    --[Comment]
    --夺旗战时间
    flagTm = nil,

    --[Comment]
    --国战武将
    heros = nil,
}

--[Comment]
--国家首都编号
local _capital = { 91, 92, 93 }
local _barCity = { 94, 95, 96, 97, 98, 99, 100 }

--[Comment]
--构造
function _nat.New()
    return { nsn = 0, flagTm = TimeClock(), bloodTm = TimeClock(), heros = { } }
end

--[Comment]
--同步国战总览数据[d=S_NatOverview]
function _nat.Sync(n, d)
    if d.rmb and user.rmb ~= d.rmb then
        user.rmb = d.rmb
        user.changed = true
    end
--    n.bloodTm.time = d.bloodTm or 0
--    d.rmb, d.bloodTm = nil, nil
    d.rmb = nil
    table.copy(d, n)
    n.nsn = user.ally.nsn
end
--[Comment]
--同步国战活动数据[d=S_NatActInfo]
function _nat.SyncAct(n, d)
    n.questCity = d.questCity
    n.flagCity = d.flagCity
    n.flagTm.time = d.flagTm
end

--[Comment]
--同步国战武将数据[d=S_NatHero[]]
function _nat.SyncHero(n, d)
    if d == nil then return end
    if #d > 0 then
        local h
        for _, v in ipairs(d) do
            v.csn = CheckSN(v.csn)
            if v.csn then
                h = user.GetHero(v.csn)
                if h then h:SetMerit(v.merit) end
                if h then h:SetFatig(v.fatig) end
            end
        end
        local hs = n.heros
        local flag
        for i = #hs, 1, -1 do
            flag = true
            h = hs[i]
            for _, v in ipairs(d) do
                if h.sn == v.csn then
                    h:Sync(v)
                    v.csn = nil
                    flag = false
                    break
                end
            end
            if flag then table.remove(hs, i) end
        end
        for _, v in ipairs(d) do
            if v.csn then
                table.insert(hs, PY_NatHero(v))
            end
        end
    else
        n.heros = { }
    end
end

--[Comment]
--城池状态发生变更
function _nat.CityStatusChange(n, city)
    for _, v in ipairs(n.heros) do
        if v.city == city then v:MarkAsChanged() end
    end
end

--[Comment]
--根据武将SN获取国战武将
function _nat.GetHero(n, csn)
    csn = tostring(csn)
    for _, v in ipairs(n.heros) do
        if v.sn == csn then return v end
    end
end
--[Comment]
--城池在战斗状态
function _nat.CityIsFight(n, city)
    city = n.city and n.city[city]
    return city and city.atk and city.atk > 0
end

--[Comment]
--获取目标城池
function _nat.GetTargetCity(n)
    if n.questCity or n.flagCity then
        local ret = { }
        if n.questCity then
            for _, c in ipairs(n.questCity) do insert(ret, c) end
        end
        if n.flagCity then
            for _, c in ipairs(n.flagCity) do insert(ret, c) end
        end
        return ret
    end
end

--[Comment]
--获取国家首都编号
function _nat.GetCapital(nsn) return _capital[nsn] or 0 end
--[Comment]
--城池是否是国都
function _nat.IsCapital(city) return city == 91 or city == 92 or city == 93 end

--[Comment]
--城池是否是蛮族营地 
function _nat.IsBarbarian(city) return city == 94 or city == 95 or city == 96 or city == 97 or city == 98 or city == 99 or city == 100 end

_nat.__get =
{
    --[Comment]
    -- 是否在血战中
    IsInBlood = function(n) return n.bloodTm.time > 0 and n.bloodPause == 0 end,
--    --[Comment]
--    --剩余征粮次数
--    getFoodQty = function(n) return getFoodQty end
}

--继承
objext(_nat)
--[Comment]
--国战数据
PY_Nat = _nat