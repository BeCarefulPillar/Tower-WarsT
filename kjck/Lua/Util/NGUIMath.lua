local bit = bit
local math = Mathf

local _math = NGUIMath

--16进制转整数
local _hex2Dec = {
["0"] = 0, ["1"] = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4,
["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9,
a = 10, b = 11, c = 12, d = 13, e = 14, f = 15,
A = 10, B = 11, C = 12, D = 13, E = 14, F = 15,
[48] = 0, [49] = 1, [50] = 2, [51] = 3, [52] = 4,
[53] = 5, [54] = 6, [55] = 7, [56] = 8, [57] = 9,
[65] = 10, [66] = 11, [67] = 12, [68] = 13, [69] = 14, [70] = 15,
[97] = 10, [98] = 11, [99] = 12, [100] = 13, [101] = 14, [102] = 15,
}
--[Comment]
--Convert a hexadecimal character to its decimal value.
function _math.HexToDecimal(c)
    return _hex2Dec[c] or 15
end
--[Comment]
--Convert the specified color to RGBA32 integer format
function _math.ColorToInt(c)
    return bit.bor(
        bit.lshif(math.Round(c.r * 255), 24),
        bit.lshif(math.Round(c.g * 255), 16),
        bit.lshif(math.Round(c.b * 255), 8),
        math.Round(c.a * 255)
    )
end
--[Comment]
--Convert a decimal value to its hex representation
function _math.DecimalToHex24(num)
    return bit.tohex(num, -6)
end

--NGUIMath = _math