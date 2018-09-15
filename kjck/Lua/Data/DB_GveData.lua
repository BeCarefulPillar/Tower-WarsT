DB_GveData =
{
    city =
    {
        { typ = 1, rev = 0, pos = { x = -781, y = 247 }, flag = { x = -777, y = 307 } },
        { typ = 1, rev = 0, pos = { x = -326, y = 232 }, flag = { x = -312, y = 273 } },
        { typ = 1, rev = 0, pos = { x = -98, y = 320 }, flag = { x = -74, y = 365 } },
        { typ = 1, rev = 0, pos = { x = 123, y = 188 }, flag = { x = 134, y = 283 } },
        { typ = 1, rev = 0, pos = { x = 418, y = 2 }, flag = { x = 415, y = 100 } },
        { typ = 1, rev = 0, pos = { x = 663, y = 180 }, flag = { x = 666, y = 265 } },
        { typ = 1, rev = 0, pos = { x = 696, y = -163 }, flag = { x = 697, y = -79 } },
        { typ = 1, rev = 0, pos = { x = 73, y = -225 }, flag = { x = 87, y = -143 } },
        { typ = 1, rev = 0, pos = { x = -680, y = -301 }, flag = { x = -677, y = -233 } },
        { typ = 1, rev = 0, pos = { x = -647, y = 33 }, flag = { x = -637, y = 74 } },
        { typ = 1, rev = 0, pos = { x = -423, y = -182 }, flag = { x = -416, y = -96 } },
        { typ = 1, rev = 0, pos = { x = -259, y = 2 }, flag = { x = -247, y = 96 } },
        { typ = 1, rev = 0, pos = { x = -170, y = -176 }, flag = { x = -157, y = -50 } },
    },
    path =
    {
        { c1 = 1, c2 = 10, pos = { { x = -781, y = 247 }, { x = -687.6115, y = 160.3168 }, { x = -745.6542, y = 89.00725 }, { x = -647, y = 33 } } },
        { c1 = 1, c2 = 2, pos = { { x = -781, y = 247 }, { x = -514.0302, y = 318.002 }, { x = -326, y = 232 } } },
        { c1 = 2, c2 = 3, pos = { { x = -326, y = 232 }, { x = -191.6034, y = 302.0749 }, { x = -98, y = 320 } } },
        { c1 = 3, c2 = 4, pos = { { x = -98, y = 320 }, { x = 39.32025, y = 227.0237 }, { x = 123, y = 188 } } },
        { c1 = 4, c2 = 5, pos = { { x = 123, y = 188 }, { x = 280.5152, y = 42.09838 }, { x = 418, y = 2 } } },
        { c1 = 5, c2 = 6, pos = { { x = 418, y = 2 }, { x = 663, y = 180 } } },
        { c1 = 3, c2 = 6, pos = { { x = -98, y = 320 }, { x = 185.4189, y = 408.4987 }, { x = 663, y = 180 } } },
        { c1 = 5, c2 = 7, pos = { { x = 418, y = 2 }, { x = 696, y = -163 } } },
        { c1 = 6, c2 = 7, pos = { { x = 663, y = 180 }, { x = 876.2655, y = 36.50447 }, { x = 696, y = -163 } } },
        { c1 = 8, c2 = 13, pos = { { x = 73, y = -225 }, { x = -28.49701, y = -189.7532 }, { x = -167.7569, y = -176 } } },
        { c1 = 8, c2 = 4, pos = { { x = 73, y = -225 }, { x = -1.537421, y = 41.36067 }, { x = 123, y = 188 } } },
        { c1 = 4, c2 = 12, pos = { { x = 123, y = 188 }, { x = -37.67995, y = 75.0498 }, { x = -259, y = 2 } } },
        { c1 = 12, c2 = 13, pos = { { x = -259, y = 2 }, { x = -138.416, y = -113.5282 }, { x = -170, y = -176 } } },
        { c1 = 13, c2 = 11, pos = { { x = -170, y = -176 }, { x = -423, y = -182 } } },
        { c1 = 11, c2 = 9, pos = { { x = -423, y = -182 }, { x = -541.8474, y = -254.0087 }, { x = -680, y = -301 } } },
        { c1 = 9, c2 = 10, pos = { { x = -680, y = -301 }, { x = -903.855, y = -99.11992 }, { x = -647, y = 33 } } },
        { c1 = 10, c2 = 11, pos = { { x = -647, y = 33 }, { x = -512.9937, y = -110.7536 }, { x = -423, y = -182 } } },
        { c1 = 10, c2 = 12, pos = { { x = -647, y = 33 }, { x = -259, y = 2 } } },
        { c1 = 12, c2 = 2, pos = { { x = -259, y = 2 }, { x = -211.9436, y = 107.471 }, { x = -326, y = 232 } } },
        { c1 = 7, c2 = 8, pos = { { x = 696, y = -163 }, { x = 451.5761, y = -434.6678 }, { x = 73, y = -225 } } },
    }
}
for _, c in ipairs(DB_GveData.city) do setmetatable(c.pos, Vector2) setmetatable(c.flag, Vector2) end
for _, c in ipairs(DB_GveData.path) do if c.pos then for _, p in ipairs(c.pos) do setmetatable(p, Vector2) end end end