local _w = { }

local _body = nil

function _w.OnLoad(c)
    _body = c
end

function _w.OnUnLoad(c)
    if _body==c then
        _body=nil
    end
end

WinHall = _w