local _w = { }

local _body = nil
local _ref = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
--    WinBackground(c, { k = WinBackground.MASK })
end

function _w.OnInit()
    _ref.content.pivot = UIWidget.Pivot.Center
    _ref.content.cachedTransform.localPosition = Vector3(0, -17, 0)

    local d = _w.initObj
    local kind = type(d)

    if kind == "number" then
        local t, c = DB_Rule.GetRule(d)
        _ref.title.text = t or L("游戏规则")
        _ref.content.text = c or ""
    elseif kind == "string" then
        _ref.title.text = L("游戏规则")
        _ref.content.text = d
    elseif kind == "table" then
        _ref.title.text = d[1] and L(d[1]) or ""
        _ref.content.text = d[2] and L(d[2]) or ""
    else
        _body:Exit()
        return
    end

    _ref.content.pivot = UIWidget.Pivot.Center
    _ref.content.cachedTransform.localPosition = Vector3(0, -17, 0)
    _ref.content.pivot = UIWidget.Pivot.Left
end

function _w.OnDispose()
    _ref.title.text = ""
    _ref.content.text = ""
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        -- package.loaded["Game.PopRule"] = nil
    end
end

--- <summary>
--- 规则
--- </summary>
PopRule = _w