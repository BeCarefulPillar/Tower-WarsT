local _w = {}

local _body = nil
local _ui = nil

function _w.OnLoad(c)
    _body = c
    _ui = c:GetComponent(typeof(SerializeRef)).ref

    _ui.close.text = "退出"
end

function _w.OnUnLoad(c)
    print("OnXX")
end

function _w.OnClickClose()
    Win.Close("Message")
end

Message = _w