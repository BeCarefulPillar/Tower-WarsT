local _w = { }

local _body = nil

function _w.OnLoad(c)
    _body = c
end

function _w.OnClose()
    Win.Close("WinPZInfo")
end

function _w.OnUnLoad(c)
    if _body==c then
        _body=nil
    end
end

WinPZInfo = _w