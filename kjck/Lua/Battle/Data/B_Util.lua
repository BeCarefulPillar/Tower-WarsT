local _string = string
local _sbyte = _string.byte
local _sub = _string.sub
local insert = table.insert

local _util = { }
QYBattle.B_Util = _util

function _util.split(str, sep)
    if str then
        if str == "" or sep == nil or sep == "" then return { str } end
        local len = _string.len(str)
        local slen = _string.len(sep)
        if len <= slen then return { str } end
        
        local idx = 1
        local c1 = _sbyte(sep, 1)
        local ret = { }

        if slen == 1 then
            for i = 1, len do
                if c1 == _sbyte(str, i) then
                    insert(ret, idx < i and _sub(str, idx, i - 1) or "")
                    idx = i + 1
                end
            end
        else
            local slen2 = slen - 1
            for i = 1, len do
                if i >= idx and c1 == _sbyte(str, i) and _sub(str, i, i + slen2) == sep then
                    insert(ret, idx < i and _sub(str, idx, i - 1) or "")
                    idx = i + slen
                end
            end
        end
        insert(ret, idx <= len and _sub(str, idx, len) or "")
        --        for m in(str .. sep):gmatch("(.-)%" .. sep) do insert(ret, m) end
        return ret
    end
end

