local ipairs = ipairs

local _w = { }
--[Comment]
--乱世争雄
WinClanWar = _w

local _body = nil
local _ref = nil

local _wars = nil
local _dat = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { n = L("乱世争雄"), r = DB_Rule.ClanWar })
end

local function PriRefresh()
    SVR.GetClanWarInfo( function(t)
        if t.success then
            _dat = SVR.datCache
        end
    end )
end

--[Comment]
--是否是开放日
local function isOpenDay(d)
    if d and d.day and #d.day > 0 then
        local t = tonumber(os.date("%w"))
        for i, v in ipairs(d.day) do
            if v % 7 == t then
                return true
            end
        end
    end
    return false
end

local function BuildItems()
    if _wars and #_wars > 0 then
        _ref.grid:Reset()
        _ref.grid.realCount = #_wars
    end
end

function _w.OnInit()
    PriRefresh()
    _wars = DB.GetClanWarByKind()

    table.sort(_wars, function(a, b)
        local fa = isOpenDay(a)
        local fb = isOpenDay(b)
        if fa == true and fb == false then
            return true
        end
        if fa == false and fb == true then
            return false
        end
        return a.kind < b.kind
    end )

    BuildItems()
end

--[Comment]
--开放日提示
local function openDayTip(d)
    if d and d.day and #d.day > 0 then
        local tip = L("每周")
        for i, v in ipairs(d.day) do
            tip = tip .. DB.GetWeekName(v) .. " "
        end
        tip = string.sub(tip, 1, #tip - 1) .. L("开放")
        return tip
    end
    return L("暂未开放")
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_wars then
        return false
    end

    local d = _wars[i + 1]
    local open = isOpenDay(d)
    local btn = item.luaBtn
    btn.isEnabled = open
    btn.param = d.kind
    item.widget:LoadTexAsync("w_c_" ..(i + 1))
    item:ChildWidget("name").text = d.nm
    item:ChildWidget("bg").spriteName = i % 2 == 1 and "bg_jiaobiao1" or "bg_jiaobiao2"
    local lab = item:ChildWidget("tip")
    lab.text = open and L("已开启") or openDayTip(d)
    lab.color = open and Color.green or Color.red
    item:ChildWidget("frame"):SetActive(not open)

    return true
end

function _w.ClickItem(k)
    Win.Open("PopClanWar", k)
end

function _w.GetPlayQty(idx)
    return _dat.qty[idx] or 0
end

function _w.playPrice()
    return _dat.price
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
        _wars = nil
    end
end