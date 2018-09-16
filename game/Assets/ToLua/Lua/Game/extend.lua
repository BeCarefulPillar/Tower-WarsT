local tostring = tostring
local string = string
local ipairs = ipairs
local pairs = pairs
local math = math
local type = type

---<summary>table is array</summary>
local function isArray(tab)
    if type(tab) ~= "table" then
        return false
    end
    local len = #tab
    local c = 0
    for k,_ in pairs(tab) do
        if type(k)~="number" or k<1 or k>len or k~= math.modf(k) or c==len then
            return false
        end
        c = c + 1
    end
    return true
end

---<summary>table to string</summary>
function tts(tab,c)
    c = c or 1
    local eq = " = "
    local rep = "        "
    local cat = "\n"
    local str = "{\n"
    if type(tab) == "table" then
        if isArray(tab) then
            for i, v in ipairs(tab) do
                if type(v) == "table" then
                    str = str .. string.rep(rep, c) .. tts(v, c + 1) .. cat
                else
                    str = str .. string.rep(rep, c) .. tostring(v) .. cat
                end
            end
        else
            for k, v in pairs(tab) do
                if type(v) == "table" and k~="__index" then
                    str = str .. string.rep(rep, c) .. tostring(k) .. eq .. tts(v, c + 1) .. cat
                else
                    str = str .. string.rep(rep, c) .. tostring(k) .. eq .. tostring(v) .. cat
                end
            end
        end
        str = str .. string.rep(rep, c - 1) .. "}"
    else
        str = tostring(tab)
    end
    return str
end