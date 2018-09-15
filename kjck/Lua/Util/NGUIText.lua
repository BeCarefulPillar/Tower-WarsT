local byte = string.byte
local sub = string.sub
local find = string.find
local insert = table.insert
local remove = table.remove
local string = string

local NGUIMath = NGUIMath
local Hex2Dec = NGUIMath.HexToDecimal
local bit = bit

local invisible = Color(0, 0, 0, 0)
local cache = { }

local _text =
{
    alpha = 1
}

--[Comment]
--Parse a RrGgBb color encoded in the string.
local function ParseColor24(text, offset)
    local f = 1 / 255
    return Color(
        bit.bor(bit.lshift(Hex2Dec(byte(text, offset)), 4), Hex2Dec(byte(text, offset + 1))) * f,
        bit.bor(bit.lshift(Hex2Dec(byte(text, offset + 2)), 4), Hex2Dec(byte(text, offset + 3))) * f,
        bit.bor(bit.lshift(Hex2Dec(byte(text, offset + 4)), 4), Hex2Dec(byte(text, offset + 5))) * f
    )
end
--[Comment]
--Parse a RrGgBbAa color encoded in the string.
local function ParseColor32(text, offset)
    local f = 1 / 255
    return Color(
        bit.bor(bit.lshift(Hex2Dec(byte(text, offset)), 4), Hex2Dec(byte(text, offset + 1))) * f,
        bit.bor(bit.lshift(Hex2Dec(byte(text, offset + 2)), 4), Hex2Dec(byte(text, offset + 3))) * f,
        bit.bor(bit.lshift(Hex2Dec(byte(text, offset + 4)), 4), Hex2Dec(byte(text, offset + 5))) * f,
        bit.bor(bit.lshift(Hex2Dec(byte(text, offset + 6)), 4), Hex2Dec(byte(text, offset + 7))) * f
    )
end
--[Comment]
--The reverse of ParseColor24 -- encodes a color in RrGgBb format.
local function EncodeColor24(c)
    return bit.tohex(bit.rshift(NGUIMath.ColorToInt(c), 8), -6)
end
--[Comment]
--The reverse of ParseColor32 -- encodes a color in RrGgBb format.
local function EncodeColor32(c)
    return bit.tohex(NGUIMath.ColorToInt(c), -8)
end

--[Comment]
--Parse the symbol, if possible. Returns 'true' if the 'index' was adjusted.
--Advanced symbol support originally contributed by Rudy Pangestu.
--arg={idx, colors, premultiply, sub, bold, italic, underline, strike, ignoreCor}
local function ParseSymbol(text, arg)
    idx = arg.idx or 1
    
    local len = string.len(text)
    if idx + 2 > len or byte(text, idx) ~= 91 then return false end
    local cors = arg.colors
    local c1, c2 = byte(text, idx + 1), byte(text, idx + 2)
    if c2 == 93 then -- ]
        if c1 == 45 then -- -
            if cors and #cors > 1 then remove(cors) end
            arg.idx = idx + 3
            return true
        end

        if c1 == 98 then --[b]
            arg.bold, arg.idx = true, idx + 3
            return true
        end
        if c1 == 105 then --[i]
            arg.italic, arg.idx = true, idx + 3
            return true
        end
        if c1 == 117 then --[u]
            arg.underline, arg.idx = true, idx + 3
            return true
        end
        if c1 == 115 then --[s]
            arg.strike, arg.idx = true, idx + 3
            return true
        end
        if c1 == 99 then --[c]
            arg.ignoreColor, arg.idx = true, idx + 3
            return true
        end
    end

    if idx + 3 > len then return false end
    local c3 = byte(text, idx + 3)
    if c3 == 93 then -- ]
        if c1 == 47 then -- /
            if c2 == 98 then --[/b]
                arg.bold, arg.idx = false, idx + 4
                return true
            end
            if c2 == 105 then --[/i]
                arg.italic, arg.idx = false, idx + 4
                return true
            end
            if c2 == 117 then --[/u]
                arg.underline, arg.idx = false, idx + 4
                return true
            end
            if c2 == 115 then --[/s]
                arg.strike, arg.idx = false, idx + 4
                return true
            end
            if c2 == 99 then --[/c]
                arg.ignoreColor, arg.idx = false, idx + 4
                return true
            end
        end

        if c1 > 127 or c2 > 127 then return false end
        _text.alpha = bit.bor(bit.lshift(Hex2Dec(c1), 4), Hex2Dec(c2)) / 255
        arg.idx = idx + 4
    end

    if idx + 4 > len then return false end
    local c4 = byte(text, idx + 4)
    if c4 == 93 then -- ]
        if c1 == 115 and c2 == 117 then -- su
            if c3 == 98 then -- [sub]
                arg.sub, arg.idx = 1, idx + 5
                return true
            elseif c3 == 112 then -- [sup]
                arg.sub, arg.idx = 2, idx + 5
                return true
            end
        end
    end

    if idx + 5 > len then return false end
    local c5 = byte(text, idx + 5)
    if c5 == 93 then -- ]
        if c1 == 47 then -- /
            if c2 == 115 and c3 == 117 and (c4 == 98 or c4 == 112) then -- [/sub] or [/sup]
                arg.sub, arg.idx = 0, idx + 6
                return true
            end
            if c2 == 117 and c3 == 114 and c4 == 108 then -- [/url]
                arg.idx = idx + 6
                return true
            end
        end
    end

    if c1 == 117 and c2 == 114 and c3 == 108 and c4 == 61 then -- url=
        local closingBracket = find(text, "]", idx + 4, true)
        arg.idx = closingBracket and closingBracket + 1 or len
        return true
    end
    
    if idx + 7 > len then return false end
    if byte(text, idx + 7) == 91 then -- ]
        local c = ParseColor24(text, idx + 1)
        if EncodeColor24(c) ~= string.upper(sub(text, idx + 1, idx + 6)) then return false end
        if cors and #cors > 0 then
            c.a = cors[#cors].a
            if arg.premultiply and c.a ~= 1 then c = Color.Lerp(invisible, c, c.a) end
            insert(cors, c)
        end
        arg.idx = idx + 8
        return true
    end

    if idx + 9 > len then return false end
    if byte(text, idx + 9) == 91 then -- ]
        local c = ParseColor32(text, idx + 1)
        if EncodeColor32(c) ~= string.upper(sub(text, idx + 1, idx + 8)) then return false end
        if cors then
            if arg.premultiply and c.a ~= 1 then c = Color.Lerp(invisible, c, c.a) end
            insert(cors, c)
        end
        arg.idx = idx + 10
        return true
    end
    return false
end
--[Comment]
--Parse the symbol, if possible. Returns 'true' if the 'index' was adjusted.
--Advanced symbol support originally contributed by Rudy Pangestu.
_text.ParseSymbol = ParseSymbol
--[Comment]
--Runs through the specified string and removes all color-encoding symbols
function _text.StripSymbols(text)
    if text and text ~= "" then
        local len = string.len(text)
        local i = 0
        local arg = { }
        while i < len do
            i = i + 1
            if byte(text, i) == 91 then --[
                arg.idx = i
                if ParseSymbol(text, arg) then
                    text = sub(text, 1, idx - 1)..sub(text, arg.idx)
                    len = string.len(text)
                end
            end
        end
    end
    return text
end



NGUIText = _text