
local _w = { }
--[Comment]
--城池按钮
PopCityButtons = _w

local _body = nil
local _trans = nil

local _btns = { }

local _callback = nil
local _pos = Vector3.zero
local _btnTags = { }

function _w.Open(cb, pos, b1, b2, b3, b4)
    if cb and (b1 or b2 or b3 or b4) then
        _callback = cb
        _pos = pos or _pos
        _btnTags[1] = b1
        _btnTags[2] = b2
        _btnTags[3] = b3
        _btnTags[4] = b4
        Win.Open("PopCityButtons")
    end
end

function _w.OnLoad(c)
    _body = c
    _trans = c.transform
    local var = c.btns
    for i = 1, 4 do
        _btns[i] = _trans:ChildBtn(i - 1)
        _btns[i].param = i
    end
    
    c:BindFunction("OnUnLoad", "OnUnLoad", "OnEnter", "OnExit", "OnDispose", "ClickBtn")
end

function _w.OnUnLoad(c)
    if _body == c then
        _body, _trans = nil, nil
    end
end

function _w.OnEnter()
    local qty = 0
    for i = 1, 4 do
        if _btnTags[i] then
            qty = qty + 1
            _btns[i].text = _btnTags[i]
            _btns[i].transform.localPosition = Vector3.zero
            _btns[i]:SetActive(true)
        else
            _btns[i]:SetActive(false)
        end
    end
    if qty < 1 then _body:Exit() return end

    _trans.position = _pos

    local intY = select(2, _trans:GetScreen()).y - 60
    intY = _trans.localPosition.y > intY and -75 or 75

    local pos = { }
    local ba = math.pi / 3
    local a = math.pi / qty

    if a < ba then a = math.min(ba, 2 * a) end
    if qty % 2 == 0 then
        for i = 1, qty / 2, 1 do
            var = (i - 0.5) * a
            pos[i * 2 - 1] = Vector3(75 * math.sin(-var), intY * math.cos(-var))
            pos[i * 2] = Vector3(75 * math.sin(var), intY * math.cos(var))
        end
    else
        pos[1] = Vector3(0, intY)
        if qty > 1 then
            for i = 1, qty / 2, 1 do
                var = i * a
                pos[i * 2] = Vector3(75 * math.sin(-var), intY * math.cos(-var))
                pos[i * 2 + 1] = Vector3(75 * math.sin(var), intY * math.cos(var))
            end
        end
    end

    var = 1
    for i = 1, 4 do
        if _btnTags[i] then
            _btns[i]:DesCmp("iTween")
            EF.MoveTo(_btns[i].gameObject, "position", pos[var], "islocal", true, "time", 0.3, "easetype", iTween.EaseType.easeOutExpo)
            var = var + 1
        end
    end

    _w.isOpen = true
end

function _w.OnExit()
    _w.isOpen = false
    for i = 1, 4 do
        if _btnTags[i] then
            EF.MoveTo(_btns[i].gameObject, "position", Vector3.zero, "islocal", true, "time", 0.3, "easetype", iTween.EaseType.easeOutExpo)
        end
    end
    _callback = nil
end

function _w.OnDispose()
    for i = 1, 4 do _btns[i]:DesCmp("iTween") end
end

function _w.GetBtn(idx) return _btns[idx] end

function _w.ClickBtn(idx)
--    print("_callback_callback    ",idx)
--    print("_callback_callback    ",_callback)
    if _callback then _callback(idx) end
    _body:Exit()
end
