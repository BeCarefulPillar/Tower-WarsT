local _w = { }

local _body = nil
local _ref = nil
local _type = nil
local _dat = nil
local _ds = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })

    c:BindFunction(
    "OnInit",
    "OnClickGuide",
    "OnWrapGridInitItem",
    "OnUnLoad"
    )

    _dat = DB.Get(LuaRes.Assistant_Tips)
end

local _ts = {
    [1] = "获取经验",
    [2] = "获取装备",
    [3] = "获取银币",
    def = "玩法",
}

local function BuildItem()
    _ref.title.text = _ts[_type] and L(_ts[_type]) or L(_ts.def)
    if _dat then
        _ds = table.findall(_dat, function(d)
            return d.t == _type
        end )
        _ref.grid:Reset()
        _ref.grid.realCount = _ds and #_ds or 0
    end
end

function _w.OnInit()
    if type(_w.initObj) == "number" then
        _type = _w.initObj
    end
    BuildItem()
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_ds then
        return false
    end
    local d = _ds[i + 1]
    item:ChildWidget("title").text = d.n
    item:ChildWidget("info").text = d.i
    item:ChildWidget("img"):LoadTexAsync(d.img)
    if d.g then
        item:ChildBtn("btn_go").param = d.g
    end
    return true
end

function _w.OnClickGuide(guide)
    ToolTip.ShowPopTip(guide)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _type = nil
        _dat = nil
        _ds = nil
        -- package.loaded["Game.PopAssistantTips"] = nil
    end
end

--- <summary>
--- 小助手
--- </summary>
PopAssistantTips = _w