local str_len = string.len
local str_byte = string.byte
local str_sub = string.sub
local str_find = string.find

local _m = class()

MsgData = _m

local function GenPlayer(dat)
    if dat then
        local len = #dat
        if len >= 2 then
            return 
            {
                name = dat[2],
                psn = len >= 3 and dat[3],
                pvpLocal = len >= 4 and tonumber(dat[4]),
            }
        end
    end
end
_m.GenPlayer = GenPlayer

local function GenEquip(dat)
    if dat then
        local len = #dat
        if len >= 2 then
            return 
            {
                name = dat[2],
                lv = len >= 3 and tonumber(dat[3]),
                evo = len >= 4 and tonumber(dat[4]),
                att = len >= 5 and dat[5],
            }
        end
    end
end

local function GenHero(dat)
    if dat then
        local len = #dat
        if len >= 2 then
            return 
            {
                name = dat[2],
                lv = len >= 3 and tonumber(dat[3]),
                evo = len >= 4 and tonumber(dat[4]),
                rank = len >= 5 and tonumber(dat[5]),
            }
        end
    end
end

function _m.ctor(m, msg)
    if msg == nil or msg == "" then return end

    local idx, idx2, len = 1, 0, str_len(msg)
    local ret = ""
    local c, i = 0, 0
    local u = nil
    while i < len do
        i = i + 1
        c = str_byte(msg, i)
        if c == 123 then
            c = i + 1
            idx2 = str_find(msg,"}", c, true)
            if idx2 then
                if idx2 > c then
                    local dat = string.split(str_sub(msg, c, idx2 - 1), ",")
                    if dat and #dat >= 2 then
                        c = dat[1]
                        if c == "p" then
                            c = ColorStyle.BLUE
                            u = GenPlayer(dat)
                        elseif c == "sq" then
                            c = "[EEB14B]"
                            u = GenPlayer(dat)
                        elseif c == "e" then
                            c = ColorStyle.GetRareColorStr(DB.GetEquipByNm(dat[2]).rare)
                            u = GenEquip(dat)
                        elseif c == "h" then
                            c = ColorStyle.GetRareColorStr(DB.GetHeroByNm(dat[2]).rare)
                            u = GenHero(dat)
                        elseif c == "dh" then
                            c = ColorStyle.GetRareColorStr(DB.GetDeheroByNm(dat[2]).rare)
                            u = nil
                        elseif c == "de" then
                            c = ColorStyle.GetRareColorStr(DB.GetDequipRare(dat[2]))
                            u = nil
                        elseif c == "i" then
                            c = ColorStyle.BLUE
                            u = nil
                        else
                            c, u = 0, nil
                        end
                        if c and c ~= 0 then
                            ret = ret .. str_sub(msg, idx, i - 1) .. "[c][u]" .. c .. dat[2] .. "[-][/u][/c]"
                            if u then
                                u.endIdx = str_len(ret) - 11
                                u.startIdx = u.endIdx - str_len(dat[2])
                                table.insert(m, u)
                            end
                        end
                    end
                end
                i = idx2 + 1
                idx = i
            else
                break
            end
        end
    end
    if idx < len then ret = ret .. str_sub(msg, idx, len) end
    m.msg = ret
end

function _m.GetData(m, idx)
    for i, u in ipairs(m) do
        if idx >= u.startIdx and idx <= u.endIdx then
            return u
        end
    end
end

function _m.ProcessMsg(msg)
    if msg == nil or msg == "" then return msg end

    local idx, idx2, len = 1, 0, str_len(msg)
    local ret = ""
    local c, i = 0, 0
    while i < len do
        i = i + 1
        c = str_byte(msg, i)
        if c == 123 then
            c = i + 1
            idx2 = str_find(msg,"}", c, true)
            if idx2 then
                if idx2 > c then
                    local dat = string.split(str_sub(msg, c, idx2 - 1), ",")
                    if dat and #dat >= 2 then
                        c = dat[1]
                        if c == "p" then
                            c = ColorStyle.BLUE
                        elseif c == "e" then
                            c = ColorStyle.GetRareColorStr(DB.GetEquipByNm(dat[2]).rare)
                        elseif c == "h" then
                            c = ColorStyle.GetRareColorStr(DB.GetHeroByNm(dat[2]).rare)
                        elseif c == "dh" then
                            c = ColorStyle.GetRareColorStr(DB.GetDeheroByNm(dat[2]).rare)
                        elseif c == "de" then
                            c = ColorStyle.GetRareColorStr(DB.GetDequipRare(dat[2]))
                        elseif c == "i" then
                            c = ColorStyle.BLUE
                        else
                            c = 0
                        end
                        if c and c ~= 0 then
                            ret = ret .. str_sub(idx, i - 2) .. "[c][u]" .. c .. dat[2] .. "[-][/u][/c]"
                            
                        end
                    end
                end
                i = idx2 + 1
                idx = i
            else
                break
            end
        end
    end
    if idx < len then ret = ret .. str_sub(msg, idx, len) end
    return ret
end