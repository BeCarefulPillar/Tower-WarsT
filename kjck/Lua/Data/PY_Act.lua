local _act =
{
    --[Comment]
    -- 活动编号
    sn = 0,
    --[Comment]
    -- 活动全局得分
    scoreGl = 0,
    --[Comment]
    -- 活动时间内累积充值的金币
    recGold = 0,
    --[Comment]
    -- 活动时间内累积消费的金币
    conGold = 0,
    --[Comment]
    -- 我的排名(取排名信息时有效)
    myRank = 0,
    --[Comment]
    -- 活动得分
    score = 0,
    --[Comment]
    -- 活动领取/购买记录[aisn,qty,aisn,qty...]
    record = nil,
    --[Comment]
    -- 排行信息(取排名信息时有效)[S_ActRankPlayer]
    rank = nil,
    --[Comment]
    -- 历史获奖信息(取历史获奖信息时有效)[S_ActHstPlayer]
    hst = nil,

    --[Comment]
    -- 过期时间
    expTm = 0,
    --[Comment]
    -- 是否已获取排行
    rankExpTm = 0,
    --[Comment]
    -- 是否已获取历史信息
    hstExpTm = 0,
}

--[Comment]
--初始化[d=S_ActData]
local function Init(a, d)
    if a.sn ~= d.actSN then return end
    a.expTm = os.time() + 180
    a.scoreGl = d.scoreGl
    a.recGold = d.recGold
    a.conGold = d.conGold
    a.score = d.score
    a.record = d.record
    if "rank" == d.opt then
        a.myRank = d.myRank
        a.rank = d.rank
        a.rankExpTm = a.expTm
    elseif "hst" == d.opt then
        a.hst = d.hst
        a.hstExpTm = a.expTm
    end
end
--[Comment]
--初始化[d=S_ActData]
function _act.Sync(a, d)
    Init(a, d)
    a.changed = true
end
--[Comment]
--构造[d=S_ActData]
function _act.New(d)
    assert(d and d.actSN and d.actSN > 0, "new PY_Act invalid args [" .. tostring(d) .. "," ..(d and d.actSN or "nil") .. "]")
    local a = { sn = d.actSN }
    Init(a, d)
    return a
end

--[Comment]
--获取指定aisn的记录值
function _act.GetRecord(a, aisn)
    local lst = a.record
    if lst then
        for i = 1, #lst, 2 do
            if aisn == lst[i] then
                return lst[i + 1] or 0
            end
        end
    end
    return 0
end
--[Comment]
--增减积分
function _act.AddScore(a, v)
    a.score = a.score + v
    a.changed = true
end

_act.__get = 
{
    --[Comment]
    --是否过期
    isExpired = function(a) return os.time() > (a.expTm or 0) end,
    --[Comment]
    --是否已获取排行信息
    isExpired = function(a) return os.time() < (a.rankExpTm or 0) end,
    --[Comment]
    --是否已获取历史信息
    isGetHst = function(a) return os.time() < (a.hstExpTm or 0) end,
}

_act.__set = 
{
    --[Comment]
    --是否已获取排行信息
    isExpired = function(a, v) a.rankExpTm = v and os.time() + 180 or 0 end,
    --[Comment]
    --是否已获取历史信息
    isGetHst = function(a, v) a.hstExpTm = v and os.time() + 180 or 0 end
}

--继承
objext(_act, DataCell)
--[Comment]
--玩家活动
PY_Act = _act