kjson = { }

local _byte = string.byte
local _sub = string.sub
local _find = string.find
local _gsub = string.gsub
local _len = string.len
local _tonumber = tonumber

local _next = next
local _insert = table.insert
local _remove = table.remove
local _type = type
local _tostring = tostring

local MAX_DEPTH = 1000
local whiteSpace = 32

--[Comment]
-- 尝试解析数字
local function getval(v)
    if v == nil or v == "" then return v end
    v = _gsub(v, "^%s*(.-)%s*$", "%1")
    if v == "true" then return true end
    if v == "false" then return false end
    local n = _tonumber(v)
    -- 暂不解析int64，以字符串返回
    return n and ((n >= -99999999999999 and n <= 99999999999999) or _find(v, '.', 1, true)) and n or v
end

--[Comment]
--将Json字符串解析为table
function kjson.decode(jsonStr)
    if "string" ~= _type(jsonStr) then return nil end

    local len = _len(jsonStr)

    if len < 1 then return nil end

    local c, nm, val
    local idx = 1
    local tidx = 1
    local inStr = nil
    local inEc = nil
    local isVal = true
    local stk = { }
    local ret, cur = { }, nil

    for i = 1, len do
        c = _byte(jsonStr, i)
        if inEc then
            inEc = nil
        elseif c > whiteSpace then
            if inStr then
                if c == 92 then --92 (\)
                    inEc = true
                elseif c == inStr then  -- 34(") 39=(')
                    val = _gsub(_sub(jsonStr, idx, i - 1), "\\n", "\n")
                    idx = i + 1
                    inStr = nil
                end
            elseif c == 44 then -- 44(,)
                if isVal then
                    cur = cur or ret
                    tidx = (stk[cur] or 0) + 1
                    cur[nm or tidx] = val or idx < i and getval(_sub(jsonStr, idx, i - 1)) or nil
                    stk[cur] = tidx
                end
                idx = i + 1
                nm, val, isVal = nil, nil, true
            elseif c == 58 then -- 58(:)
                if isVal and nm == nil then
                    nm = val or idx < i and _sub(jsonStr, idx, i - 1) or nil
                    idx = i + 1
                    val = nil
                end
            elseif c == 34 or c == 39 then  -- 34(") 39=(')
                idx = i + 1
                inStr = c
            elseif c == 91 or c == 123 then -- 91([) 123({)
                if cur then
                    _insert(stk, cur)
                    val = { }
                    tidx = (stk[cur] or 0) + 1
                    cur[nm or tidx] = val
                    stk[cur] = tidx
                    cur = val
                else
                    cur = ret
                end

                idx = i + 1
                nm, val = nil, nil
            elseif c == 93 or c == 125 then -- 93(]) 125(})
                if isVal and (val or idx < i) then
                    tidx = (stk[cur] or 0) + 1
                    cur[nm or tidx] = val or idx < i and getval(_sub(jsonStr, idx, i - 1)) or nil
                    stk[cur] = tidx
                end
                cur = _remove(stk)
                isVal = false
                idx = idx + 1
                nm, val, isVal = nil, nil, false
            end
        end
    end
    return ret
end
--[Comment]
--将table编码为json字符串
function kjson.encode(t)
    if "table" ~= _type(t) then return _tostring(t) end

    local stk = { }
    local idx = { }
    local ret = { }

    local ct, ti, tk, tp

    while t do
        ct, ti, tk = t, idx[t], stk[t]
        if ti == nil then
            _insert(ret, "{")
            ti = #ret
            idx[t] = ti
        end
        
        for k, v in _next, t, tk do
            tp = _type(v)
            if "number" == tp or "boolean" == tp then
                if tk then _insert(ret, ",") else tk = true end
                if "string" == _type(k) then
                    _insert(ret, "\""..k.."\":".._tostring(v))
                    if ti > 0 then
                        ti = -ti
                        idx[t] = ti
                    end
                else
                    _insert(ret, _tostring(v))
                end
--                _insert(ret, "string" == _type(k) and "\""..k.."\":"..v or v)
            elseif "string" == tp then
                if tk then _insert(ret, ",") else tk = true end
                if "string" == _type(k) then
                    _insert(ret, "\""..k.."\":\""..v.."\"")
                    if ti > 0 then
                        ti = -ti
                        idx[t] = ti
                    end
                else
                    _insert(ret, "\""..v.."\"")
                end
--                _insert(ret, "string" == _type(k) and "\""..k.."\":\""..v.."\"" or "\""..v.."\"")
            elseif "table" == tp then
                if #stk > 1000 then
                    print("too many table[".._tostring(k).."] nested!!")
                elseif idx[v] or stk[v] then
                    print("the table[".._tostring(k).."] was recursive nested")
                else
                    if tk then _insert(ret, ",") else tk = true end
                    if "string" == _type(k) then
                        _insert(ret, "\""..k.."\":")
                        if ti > 0 then
                            ti = -ti
                            idx[t] = ti
                        end
                    end
                    _insert(stk, t)
                    stk[t] = k
                    t = v
                    break
                end
            end
        end

        if ct == t then
            if ti > 0 then
                ret[ti] = "["
                _insert(ret, "]")
            else
                _insert(ret, "}")
            end
            idx[t] = nil
            stk[t] = nil

            t = _remove(stk)
        end
    end

    return table.concat(ret)
end

--[Comment]
--精简json解析
function kjson.ldec(js, ntab)
    if "string" ~= _type(js) then return nil end

    local len = _len(js)

    if len < 1 then return nil end

    local c, val
    local idx = 1
    local tidx = 1
    local inStr = nil
    local inEc = nil
    local isVal = true
    local stk = { }
    local ret, cur = { }, nil
    local ntk, nms, cnm = nil, nil, nil
    if ntab then ntk, nms = { }, { } end

    for i = 1, len do
        c = _byte(js, i)
        if inEc then
            inEc = nil
        elseif c > whiteSpace then
            if inStr then
                if c == 92 then --92 (\)
                    inEc = true
                elseif c == inStr then  -- 34(") 39=(')
                    val = _gsub(_sub(js, idx, i - 1), "\\n", "\n")
                    idx = i + 1
                    inStr = nil
                end
            elseif c == 44 then -- 44(,)
                if isVal then
                    if cur == nil then cur, cnm = ret, ntab end
                    tidx = (stk[cur] or 0) + 1
                    cur[cnm and cnm[tidx] or tidx] = val or idx < i and getval(_sub(js, idx, i - 1)) or nil
                    stk[cur] = tidx
                end
                idx = i + 1
                val, isVal = nil, true
            elseif c == 34 or c == 39 then  -- 34(") 39=(')
                idx = i + 1
                inStr = c
            elseif c == 91 or c == 123 then -- 91([) 123({)
                if cur then
                    _insert(stk, cur)
                    tidx = (stk[cur] or 0) + 1
                    if ntk then
                        val = #stk
                        ntk[val] = ntab
                        nms[val] = cnm
                        if cnm then
                            ntab = cnm[cnm[tidx]] or c == 91 and ntab or nil
                        end
                    end
                    val = { }
                    cur[cnm and cnm[tidx] or tidx] = val
                    stk[cur] = tidx
                    cur = val
                else
                    cur = ret
                end

                if c == 91 then
                    cnm = nil
                else
                    cnm, ntab = ntab, nil
                end

                idx = i + 1
                val = nil
            elseif c == 93 or c == 125 then -- 93(]) 125(})
                if isVal and (val or idx < i) then
                    tidx = (stk[cur] or 0) + 1
                    cur[cnm and cnm[tidx] or tidx] = val or idx < i and getval(_sub(js, idx, i - 1)) or nil
                    stk[cur] = tidx
                end
                if ntk then
                    val = #stk
                    ntab, cnm = ntk[val], nms[val]
                    ntk[val], nms[val] = nil, nil
                end
                cur = _remove(stk)
                isVal = false
                idx = idx + 1
                val, isVal = nil, false
            end
        end
    end
    return ret
end

--[Comment]
--打印table
function kjson.print(t)
    if "table" ~= _type(t) then return _tostring(t) end

    local stk = { }
    local idx = { }
    local ret = { }

    local ct, ti, tk, tp

    local enint = QYBattle and QYBattle.EnInt

    while t do
        ct, ti, tk = t, idx[t], stk[t]
        if ti == nil then
            _insert(ret, "\n" .. string.rep(" ", #stk * 4).."{")
            ti = #ret
            idx[t] = ti
        end

        local sep = "\n" .. string.rep(" ", (#stk + 1) * 4)

        for k, v in _next, t, tk do
            _insert(ret, sep)
            _insert(ret, _type(k) == "string" and (tostring(k) .. " = ") or ("["..tostring(k).."] = "))
            tp = _type(v)
            if "string" == tp then
                _insert(ret, '"'..v..'"')
            elseif "table" == tp then
                if enint and getmetatable(v) == enint then
                    local val = v.value
                    if val and _type(val) == "number" then _insert(ret, val) end
                end
                if #stk > 1000 then
                    _insert(ret, tostring(v).. "  (too many table nested!)")
                elseif idx[v] or stk[v] then
                    _insert(ret, tostring(v).. "  (table was recursive nested!)")
                else
                    _insert(stk, t)
                    stk[t] = k
                    t = v
                    break
                end
            else
                _insert(ret, tostring(v))
            end
        end

        if ct == t then
            _insert(ret, "\n" .. string.rep(" ", #stk * 4).."}")
            idx[t] = nil
            stk[t] = nil

            t = _remove(stk)
        end
    end

    return table.concat(ret)
--    ret = table.concat(ret)
--    print(ret)
--    return ret
end