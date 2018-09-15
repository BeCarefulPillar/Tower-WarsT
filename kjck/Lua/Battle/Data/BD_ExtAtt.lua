local type = type
local setmetatable = setmetatable
local rawget = rawget
local _byte = string.byte
local _sub = string.sub
local strlen = string.len
local tonumber = tonumber
local remove = table.remove
local insert = table.insert
local pairs = pairs

--[Comment]
--属性名称
local _anm = QYBattle.BD_ANM
--[Comment]
--属性名称反映射
local _anmap = { }
--写入属性名称反映射
for k, v in pairs(_anm) do _anmap[v] = k end

--[Comment]
--属性集合
local _att = { }
--[Comment]
--给属性集添加一条属性
local function AddKV(att, k, v, pos)
    if k and v and _anmap[k] and "number" == type(v) then
        if pos and pos >= 1 and pos <= #att then
            insert(att, pos, { k, v })
        else
            insert(att, { k, v })
        end
        if att._conv then att[k] = (att[k] or 0)  + v end
        return true
    end
    return false
end
--[Comment]
--解析属性到源属性表
local function Parse(src, str, pos)
    if str == nil then return src end
    local len = strlen(str)
    if len < 4 then return src end
    
    src = src or setmetatable({ }, _att)
    local c
    local idx = 1
    local k, v = nil, nil
    for i = 1, len do
        c = _byte(str, i)
        if c == 124 then -- 124 (|)
            if AddKV(src, k, v or i > idx and k and tonumber(_sub(str, idx, i - 1)) or nil, pos) and pos then pos = pos + 1 end
            k, v = nil, nil
            idx = i + 1
        elseif c == 44 and i > idx then -- 44 (,)
            if k == nil then
                k = _sub(str, idx, i - 1)
            elseif v == nil then
                v = tonumber(_sub(str, idx, i - 1))
            end
            idx = i + 1
        end
    end

    if idx <= len and k and v == nil then
        v = tonumber(_sub(str, idx, len))
    end

    AddKV(src, k, v, pos)

    return src
end
--[Comment]
--合并,将目标属性(可是字符串、表)合并到源属性
local function Merge(src, att, pos)
    local t = type(att)
    if "string" == t then
        Parse(src, att, pos)
    elseif "table" == t then
        if #att >= 2 and AddKV(src, att[1], att[2], pos) then return end
        for i = 1, #att do
            t = att[i]
            if "table" == type(t) and #t >= 2 then
                if AddKV(src, t[1], t[2], pos) and pos then pos = pos + 1 end
            end
        end
    end
end
--[Comment]
--汇总属性
local function Conv(att)
    --清除原有
    for k, _ in pairs(_anmap) do if att[k] then att[k] = nil end end
    --汇总
    local a
    for i = 1, #att do
        a = att[i]
        if "table" == type(a) then ConvKV(att, a[1], a[2]) end
    end
end

--索引
function _att.__index(t, k)
    return rawget(_att, k) or (_anmap[k] and 0 or nil)
end
--构造
function _att.__call(t, arg, conv)
    if arg then
        t = type(arg)
        if "string" == t then
            return setmetatable(Parse({ _conv = conv ~= false }, arg), _att)
        elseif "table" == t then
            if getmetatable(arg) == _att then return arg end
            if conv ~= false then
                arg._conv = true
                Conv(arg)
            end
            return setmetatable(arg, _att)
        end
    end
    return setmetatable({ }, _att)
end
--相加
function _att.__add(a, b)
    if a or b then
        local att = _att()
        Merge(att, a)
        Merge(att, b)
        return att
    end
    return nil
end

--[Comment]
--取属性值
function _att.Get(att, k) return att and _anmap[k] and att[k] or 0 end
--[Comment]
--移除属性
function _att.Remove(att, k)
    if att == nil then return end
    local a
    if _anmap[k] then
        for i = #att, 1, -1 do
            a = att[i]
            if a and a[1] == k then
                remove(att, i)
--                att[k] = att[k] and (att[k] - a[2])
            end
        end
        if att[k] then att[k] = 0 end
        return
    end
    a = remove(att, k)
    if a then
         k = a[1]
        att[k] = att[k] and (att[k] - a[2])
    end
end
--[Comment]
--增加属性(self, att(字符串/表), pos(指定插入位置)),
_att.Add = Merge
--[Comment]
--增加属性(self, k(键), v(值), pos(指定插入位置))
_att.AddKV = AddKV

--配置元表
setmetatable(_att, _att)
--[Comment]
--扩展属性对象
QYBattle.BD_ExtAtt = _att