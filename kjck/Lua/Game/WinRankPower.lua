local _w = { }

local _body = nil
local _ref = nil

local _dat = nil
local _pageNum = nil
local _init = nil
local _isLoading = nil
local _needInf = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })

    _pageNum = 10
    _init = true
    _isLoading = false
    _needInf = true
end

local function RefreshDat()
    _isLoading = true
    SVR.PlayerList("score", math.modf(#_dat / _pageNum) + 1,
    function(t)
        if t.success then
            local res = SVR.datCache
            table.AddNo(_dat, res, "psn")
            if _init then
                _init = false
                _ref.grid:Reset()
            end
            _ref.grid.realCount = #_dat
        end
        _isLoading = false
    end )
end

function _w.OnInit()
    _dat = { }
    RefreshDat()
end

function _w.OnDispose()
    _isLoading = false
    _init = true
    _dat = nil
end

local function UpdateSelfInfo()
    _needInf = false
    _ref.selfInfo[1].text = tostring(user.rank)
    _ref.selfInfo[2].text = user.nick
    _ref.selfInfo[3].text = tostring(user.score)
    _ref.selfInfo[4].text = tostring(user.hlv)
end
function _w.OnEnabled()
    UserDataChange:Add(UpdateSelfInfo)
end
function _w.OnDisabled()
    UserDataChange:Remove(UpdateSelfInfo)
end

function _w.OnEnter()
    if _needInf then
        SVR.UpdateUserInfo(function(t)
            if t.success then
                UpdateSelfInfo()
            end
        end)
    else
        UpdateSelfInfo()
    end
end

local _cors = {
    [1] = "[ffe553]",
    [2] = "[89cdfb]",
    [3] = "[ffa880]",
    def = "[dddddd]",
}

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_dat then
        return false
    end
    local d = _dat[i + 1]
    local labs = item:GetComponentsInChildren(typeof(UILabel))
    labs[0].text = d.nick
    local c = _cors[i + 1] or _cors.def
    labs[1].text = c ..(i + 1)
    labs[2].text = tostring(d.rank)
    labs[3].text = tostring(d.hlv)
    return true
end

function _w.OnWrapGridRequestCount()
    if not _isLoading then
        RefreshDat()
        return true
    end
    return false
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _pageNum = nil
        _init = nil
        _isLoading = nil
        _needInf = nil
   end
end

---<summary>
---实力榜
---</summary>
WinRankPower = _w