WordFilter = {}

local _byte = string.byte
local _sub = string.sub
local _tree = nil

local function Import(str)
    if str == nil or type(str) ~= "string" then return end

    _tree = {}
    
    local len = string.len(str)
    local cur = _tree
    local pc = nil
    local c
    local t

    for i = 1, len do
        c = _byte(str, i)
        if c == 44 or c < 32 then -- 44(,)
            if pc then
                t = cur[pc]
                if t == nil then
                    cur[pc] = true
                elseif t ~= true then
                    t.tail = true
                end
                pc = nil
            end
            cur = _tree
        else
            if pc then
                t = cur[pc]
                if t == true then
                    t = { tail = true }
                    cur[pc] = t
                elseif t == nil then
                    t = {}
                    cur[pc] = t
                end
                cur = t
            end
            pc = c
        end
    end

    if pc then
        t = cur[pc]
        if t == nil then
            cur[pc] = true
        elseif t ~= true then
            t.tail = true
        end
        pc = nil
    end
end

local function Check(str)
    if _tree == nil or str == nil or type(str) ~= "string" then return false end

    local len = string.len(str)
    local cur

    for i = 1, len do
        cur = _tree
        for j = i, len do
            cur = cur[_byte(str, j)]
            if cur == nil then break end
            if cur == true or cur.tail then return true end
        end
    end

    return false
end

local function Filter(str, rep)
    if _tree == nil or str == nil or type(str) ~= "string" then return str end

    local len = string.len(str)
    local cur
    local ret = ""
    local idx = 1
    rep = rep or "**"

    for i = 1, len do
        cur = _tree
        for j = i, len do
            cur = cur[_byte(str, j)]
            if cur == nil then break end
            if cur == true or cur.tail then
                if idx < i then
                    ret = ret.._sub(str, idx, i - 1)..rep
                else
                    ret = ret..rep
                end
                i = j
                idx = i + 1
                break
            end
        end
    end

    if idx <= len then
        ret = ret.._sub(str, idx)
    end

    return ret
end

--[Comment]
--导入过滤文本
WordFilter.Import = Import
--[Comment]
--检测给定字符串是否包含敏感词
WordFilter.Check = Check
--[Comment]
--替换给定字符串中的敏感词
WordFilter.Filter = Filter
