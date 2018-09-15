local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
end

function _w.OnInit()
    if _w.initObj then
        local data = _w.initObj
        _ref.grid:DesAllChild()
        for i, v in ipairs(data.vals) do
            local item = _ref.grid:AddChild(_ref.item, string.format("item_%02d", i))
            item:SetActive(true)
            local lv = item:ChildWidget("lab_lv")
            lv.text = i .. ""
            lv:ChildWidget("lab_info").text = string.format(data.intro, v)
        end
        _ref.grid.repositionNow = true
    end
end

function _w.OnDispose()
    _ref.grid:DesAllChild()
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
    end
end

---<summary>
---科技
---</summary>
PopTechBrowse = _w