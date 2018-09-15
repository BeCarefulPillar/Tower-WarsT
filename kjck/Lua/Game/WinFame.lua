local _w = { }
-- [Comment]
-- 名人堂
WinFame = _w

local _body = nil
local _ref = nil

local _fame = nil
local _dat = nil

local _score = nil
local _players = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { n = L("名人堂"), r = DB_Rule.Fame })
end

local function BuildItems()
    SVR.PlayerList("score", 1, function(t)
        if t.success then
            -- stab.S_PlayerInfo
            _score = SVR.datCache
        end
    end )
    SVR.GveExplorerRank( function(t)
        if t.success then
            -- stab.S_PalaceRank
            local res = SVR.datCache
            _players = res and res.players
        end
    end )
    if _fame then
        _ref.grid:Reset()
        _ref.grid.realCount = #_fame
    end
end

local function PriRefresh()
    SVR.GetFameInfo( function(t)
        if t.success then
            --stab.S_FameInfo
            _dat = SVR.datCache
        end
    end )
end

function _w.OnInit()
    if not _fame then
        _fame = DB_Fame
    end
    if not _dat or not _dat.ranks then
        PriRefresh()
    end
    BuildItems()
    for i, btn in ipairs(_ref.tabs) do
        if i == #_ref.tabs - 1 then
            btn:SetClick(_w.ClickItemPower)
        elseif i == #_ref.tabs then
            btn:SetClick(_w.ClickItemPalace)
        else
            btn:SetClick(_w.ClickItem, _fame[i])
        end
    end
end

-- [Comment]
-- 获取指定名人堂的第一名
local function GetFameLeader(sn)
    if _dat and _dat.ranks and _dat.ranks[sn] then
        for i, v in ipairs(_dat.ranks[sn]) do
            if v.rank == 1 then
                return v
            end
        end
    end
    return nil
end

local _texIndex = { 337, 21, 25, 336, 15, 248 }

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_fame then
        return false
    end
    local d = _fame[i + 1]
    item:ChildWidget("title").text = d.n
    item:ChildBtn("title").param = d
    item.widget:LoadTexAsync("h_" .. _texIndex[i + 1])

    if i == #_fame - 2 then
        item:ChildWidget("name").text = _score[1].nick
        item.luaBtn:SetClick(_w.ClickItemPower)
    elseif i == #_fame - 1 then
        item.luaBtn:SetClick(_w.ClickItemPalace)
        if _players then
            item:ChildWidget("name").text = _players[1].nm
        end
    else
        item.luaBtn:SetClick(_w.ClickItem, d)
        local info = GetFameLeader(d.sn)
        item:ChildWidget("name").text = info and info.name or L("虚位以待")
    end

    return true
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _fame = nil
        _dat = nil
        _score = nil
        _players = nil
    end
end

function _w.ClickItemPower()
    Win.Open("WinRankPower")
end
function _w.ClickItemPalace()
    Win.Open("PopPalaceRank")
end
function _w.ClickItem(d)
    Win.Open("PopRankFame", { d, _dat })
end
function _w.ClickItemTitle(d)
    ToolTip.ShowPropTip(d.n, L("说明:") .. d.i)
end