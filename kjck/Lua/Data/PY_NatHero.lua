local now = os.time
local ipairs = ipairs
local m_pcpg = math.PathControlPointGenerator
local m_interp = math.Interp

local _hero =
{
    --[Comment]
    --编号
    sn = nil,
    --[Comment]
    --粮草
    food = 0,
    --[Comment]
    --所在城池
    city = 0,
    --[Comment]
    --功勋
    merit = 0,
    --[Comment]
    --疲劳值
    fatig = 0,

    --[Comment]
    --移动百分比
    percent = 0,
    --[Comment]
    --路径索引
    index = 0,
    --[Comment]
    --路径
    path = nil,

    --[Comment]
    --请求时间
    request = 0;
    --[Comment]
    --城池路径
    cityPath = nil,
}
--[Comment]
--国战武将状态
local Status =
{
    --[Comment]
    --休整
    Rest = 1,
    --[Comment]
    --移动
    Move = 2,
    --[Comment]
    --战斗
    Fight = 3,
    --[Comment]
    --空闲
    Idle = 4,
}
--[Comment]
--国战武将状态
_hero.Status = Status
--[Comment]
--国战武将状态描述
local _sdesc = { "休整中", "移动中", "战斗中", "待命中" }

--[Comment]
--重置状态
local function Reset(h)
    h.index = 0
    h.path = nil
    h.cityPath = nil
    h.percent = nil
    h.changed = true
end
--[Comment]
--重置状态
_hero.Reset = Reset
--[Comment]
--同步[d=S_NatHero]
local function Sync(h, d)
    h.food = d.food
    h.city = d.city
    h.merit = d.merit
    h.fatig = d.fatig
    local p, c = h.path, h.city
    if p and p[h.index] then
        if p[h.index - 1] == c then return end
        for i = 1, #p do
            if p[i] == c then
                h.index = i + 1
                h.percent = 0
                h.changed = true
                if p[h.index] then return end
                break
            end
        end
    end
    Reset(h)
end
--[Comment]
--同步[d=S_NatHero]
_hero.Sync = Sync
--[Comment]
--构造[d=S_NatHero]
function _hero.New(d)
    return { sn = d.csn, food = d.food, city = d.city, merit = d.merit, fatig = d.fatig}
end
--[Comment]
--设置粮草
function _hero.SetFood(h, v) h.food, h.changed = v, true end
--[Comment]
--设置功勋
function _hero.SetMerit(h, v) h.merit, h.changed = v, true end
--[Comment]
--设置疲劳
function _hero.SetFatig(h, v) h.fatig, h.changed = v, true end
--[Comment]
--设置所在城池
function _hero.SetCity(h, v)
    if v and v > 0 and h.city ~= v then
        h.city = v
        Reset(h)
    end
end
--[Comment]
--设置突袭城池
function _hero.SetRaid(h, city)
    if h.food < 1 or h.path then return end
    h.cityPath = nil
    h.path = { h.city, city }
    h.index = 2
    h.percent = 0
    h.changed = true
end
--[Comment]
--设置移动路径(d=路径列表)
function _hero.SetPath(h, d)
    if d == nil or h.CurStatus ~= Status.Idle then return end
    h.cityPath = nil,
    print("Path=", string.join(",", d))
    h.index = 2
    h.path = d
    h.percent = 0
    h.changed = true
end

--[Comment]
--到达下个城池后停止移动
function _hero.StopMove(h)
    local p = h.path
    if p == nil or h.index < 1 or h.index >= #p then return end
    for i = #p, h.index + 1, -1 do table.remove(p, i) end
end

--[Comment]
--返回首都
function _hero.ReturnCapital(h)
    h.city = PY_Nat.GetCapital(user.ally.nsn)
    Reset(h)
end

--[Comment]
--获取位置
function _hero.GetPos(h)
    if h.path then
        local cd, pd = DB_NatData.city, DB_NatData.path
        local cp = h.cityPath
        local city, cityTo = h.city, h.path[h.index]
        if cp == nil then
            for _, p in ipairs(pd)  do
                if p.c1 == city and p.c2 == cityTo then
                    cp = m_pcpg(p.pos)
                    h.cityPath = cp
                    break
                elseif p.c1 == cityTo and p.c2 == city then
                    cp = m_pcpg(p.pos, true)
                    h.cityPath = cp
                    break
                end
            end
            if cp == nil then
                cp = m_pcpg({ cd[city].pos, cd[h.index].pos })
                h.cityPath = cp
            end
        end
        return Vector3(m_interp(cp, h.percent))
    else
        h = DB_NatData.city[h.city].pos
        return Vector3(h.x, h.y)
    end
end

--[Comment]
--获取状态描述
function _hero.GetStatusDesc(stat) return L(_sdesc[stat] or "待命中") end

--[Comment]
--移动
function _hero.Move(h)
    local path = h.path
    if path == nil or h.request > now() then return end
    if user.nat.IsInBlood then Reset(h); return end
    local idx = h.index
    if idx > #path then Reset(h); return end

    if h.percent < 1 then
        h.percent = math.min(h.percent + Time.unscaledDeltaTime * 0.125 *(1 + user.stateMoveAdd), 1)
        return
    end

    h.percent = 1
    h.request = now() + TIMEOUT + 2
    print("From=",(path[idx - 1]), ",To=" ..(path[idx]))
    SVR.NatHeroMove(path[idx], h.sn, function(t)
        h.request = 0
        h.percent = 0
        if t.success then
            local path = h.path
            if path then
                h.city = path[h.index]
                h.index = h.index + 1
                h.cityPath = nil
                h.changed = true
                if h.index <= #path and not user.nat:CityIsFight(h.city) then return end
            end
            --待做
            --      local wcc = Win.GetActiveWin("WinCountryCity")
            --      if wcc and wcc.CitySN == h.city then wcc:Refresh() end
        elseif t.code ~= 0 then
            t.hideErr = true
            if isString(t.data) then ToolTip.ShowPopTip(ColorStyle.Warning(t.data)) end
        end
        Reset(h)
    end)
end

_hero.__get =
{
    --[Comment]
    --获取武将当前状态
    CurStatus = function(h)
        if h.food <= 0 then return Status.Rest end
        if h.path then return Status.Move end
        local nat = user.nat
        if nat:CityIsFight(h.city) then return Status.Fight end
        if nat.IsInBlood and nat.bloodCity > 0 and h.city ~= nat.bloodCity then return Status.Move end
        return Status.Idle
    end,

    --[Comment]
    --是否满粮草
    IsFullFood = function(h) local hd = user.GetHero(h.sn); return hd == nil or h.food >= hd.MaxHP end,
    --[Comment]
    --是否在首都
    InCapital = function(h) return h.city == PY_Nat.GetCapital(user.ally.nsn) end,
    --[Comment]
    --是否还有多个城池节点移动
    IsMultiNode = function(h) return h.path and h.index < #h.path end,
}

--继承
objext(_hero, DataCell)
--[Comment]
--国战武将
PY_NatHero = _hero