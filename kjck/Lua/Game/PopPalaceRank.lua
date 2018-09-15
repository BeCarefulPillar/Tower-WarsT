local _w = { }

local _body = nil
local _ref = nil

local _dat = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
end

local function BuildItems()
    if not _dat then
        ToolTip.ShowPopTip(L("暂无排名数据!"))
        _body:Exit()
        return
    end
    _ref.grid:Reset()
    _ref.grid.realCount = #_dat.players
end

local function InitItemSelf()
    if not _dat then
        return
    end
    local d = _dat.myRank
    _ref.itemSelf:ChildWidget("rank").text = d[1] > 30 and "30+" or tostring(d[1])
    _ref.itemSelf:ChildWidget("name").text = user.nick
    _ref.itemSelf:ChildWidget("score").text = tostring(d[2])
end

function _w.OnInit()
    if not _dat then
        SVR.GveExplorerRank( function(t)
            if t.success then
                -- stab.S_PalaceRank
                _dat = SVR.datCache
                BuildItems()
                InitItemSelf()
            end
        end )
    end
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_dat.players then
        return false
    end
    local d = _dat.players[i + 1]
    item:ChildWidget("rank").text = tostring(d.rank)
    item:ChildWidget("name").text = d.nm
    item:ChildWidget("score").text = tostring(d.score)

    return true
end

function _w.OnDispose()
    _dat = nil
end

function _w.Help()
    Win.Open("PopRule", DB_Rule.Tower)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        -- package.loaded["Game.PopPalaceRank"] = nil
    end
end

--- <summary>
--- 名人堂
--- </summary>
PopPalaceRank = _w