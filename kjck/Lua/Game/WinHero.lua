local _w = { }

local _body = nil
local _ref = nil

--得到绑定的对象
local _gridHeros = nil
local _arrow = nil
local _btnTabs = nil

--[Comment]
--得到所有将领数据
local _dats = nil

local defSortFunc = PY_Hero.Compare
local _sortFunc = 
{
    -- 将领排序
    --等级
    [1] = function(x, y)
        if x.lv > y.lv then return true end
        if x.lv < y.lv then return false end
        if x.rare > y.rare then return true end
        if x.rare < y.rare then return false end
        if x.ttl > y.ttl then return true end
        if x.ttl < y.ttl then return false end
    end,
    --官阶
    [2] = function(x, y)
        if x.ttl > y.ttl then return true end
        if x.ttl < y.ttl then return false end
        if x.lv > y.lv then return true end
        if x.lv < y.lv then return false end
        if x.rare > y.rare then return true end
        if x.rare < y.rare then return false end
    end,
    --武力
    [3] = function(x, y)
        local xv, yv = x.str, y.str
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --智力
    [4] = function(x, y)
        local xv, yv = x.wis, y.wis
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --统帅
    [5] = function(x, y)
        local xv, yv = x.cap, y.cap
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --生命
    [6] = function(x, y)
        local xv, yv = x.MaxHP, y.MaxHP
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --技力
    [7] = function(x, y)
        local xv, yv = x.MaxSP, y.MaxSP
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --兵力
    [8] = function(x, y)
        local xv, yv = x.MaxTP, y.MaxTP
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --国家
    [9] = function(x, y)
        local xv, yv = x.clan, y.clan
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
}
--[Comment]
--排序方法
_w.sortFunc = _sortFunc


-- 武将排序
local function SortHero(s)
    s = s or 0
    if _sort == s then
        table.reverse(_dats)
        _arrow.localEulerAngles = _arrow.localEulerAngles * -1
    else
        --排序
        table.sort(_dats, _sortFunc[s] or PY_Hero.Compare)
        _arrow.parent = _btnTabs[s + 1].transform
        _arrow.localPosition = Vector3(40, 0, 0)
    end
    _sort = s
    _gridHeros:Reset()
    _gridHeros.realCount = #_dats
end


function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.BG , n = L("将领")})
    _body = c

    c:BindFunction("OnInit","OnDispose","OnUnLoad","OnWrapGridInitItem",
                    "ClickSortTab","ClickItemHero")

    _ref = c.nsrf.ref
    _gridHeros = _ref.gridHeros
    _arrow = _ref.arrow
    _btnTabs = _ref.btnTabs
    for i = 1 ,#_btnTabs do
        _btnTabs[i].param = i - 1
    end
end

function _w.OnInit()
    local var = _w.initObj
    if type(var) == "table" then
        _dats = var.heros or { }
        _callback = var.callback
    else
        if type(var) ~= "number" then var = 0 end
        _dats = var > 0 and user.GetCityHero(var) or user.GetHeros(function(h) return h.borrow ~= 1 end)
    end
    _w.heros = _dats
    SortHero()
    _w.isOpen = true
end


function _w.OnDispose()
    _w.isOpen = false
    _dats = nil
    _sort = -1
--    _gridHeros:DesAllChild()
end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
    _gridHeros = nil
    _arrow = nil
    _btnTabs = nil
end

function _w.OnWrapGridInitItem(go, idx)
    if idx < 0 then return false end
    local dat = _dats[idx + 1]
    if not dat then return false end
    local it = ItemHero(go)
    it:Init(dat)
    go.luaBtn.luaContainer = _body
    go.luaBtn:SetClick("ClickItemHero", dat)
    return true
end

function _w.ClickSortTab(s)
    SortHero(s)
end

function _w.ClickItemHero(d)
    if d.param ~= nil then
        Win.Open("PopHeroDetail",d.param)
    end
end

--[Comment]
--将领列表
WinHero = _w