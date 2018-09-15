--[Comment]
--本地化
L = {}

local map = {}
local language = GM.language
pcall(require, "Lang/L_"..language)
map = L[language] or map

function L.Language(lang)
    if lang == nil or lang < 0 or language == lang then return end
    GM.language = lang
    language = lang
    pcall(require, "Lang/L_"..language)
    map = L[language] or map
end

L.__call = function(t, txt) return map[txt] or txt or "" end
L.__index = function(t, txt) return map[txt] or txt or "" end

--[Comment]
--未知
function L.UNK() return L("未知") end

setmetatable(L, L)

--[Comment]
--本地化名称，为nil会显示 未知
function LN(nm) return map[nm or "未知"] or nm or "未知" end