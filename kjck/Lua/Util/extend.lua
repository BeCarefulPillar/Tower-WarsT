require "Battle/Data/QYBattle"

local type = type
local _string = string
local _sbyte = string.byte
local _slen = string.len
local _sub = string.sub
local _table = table
local insert = table.insert
local pairs = pairs
local _math = math
local setmetatable = setmetatable
local rawget = rawget
local select = select
local QYBattle = QYBattle
local B_Math = QYBattle.B_Math

number={}

--[Comment]
--数组逆序 只能用于数组，不能用于哈希表
function table.reverse(tab)  
--    local tmp = {}
--    for i = 1, #tab do tmp[i] = _table.remove(tab) end
--    return tmp
    if tab == nil then return end
    local tmp = nil
    local idx, len = 0, #tab
    for i = 1, _math.modf(len / 2) do
        tmp, idx = tab[i], len - i + 1
        tab[i] = tab[idx]
        tab[idx] = tmp
    end
end  
--[Comment]
--浅表复制
function table.copy(t, d)  
    d = d or {}
    for k, v in pairs(t) do d[k] = v end
    return d
end
--[Comment]
--清理
function table.clear(t)
    if t then for k, _ in pairs(t) do t[k] = nil end end
end
--[Comment]
--查找所有匹配的
function table.findall(t, f)
    local arr = { }
    if f then
        for _, v in pairs(t) do if f(v) then insert(arr, v) end end
    else
        for _, v in pairs(t) do insert(arr, v) end
    end
    return arr
end
--[Comment]
--查找位置
function table.idxof(t, v, pos, e)
    e = e or #t
    for i = pos or 1, e do if t[i] == v then return i end end
    return nil
end
--[Comment]
--是否存在值
function table.exists(t, f) if t and f then for _, v in pairs(t) do if f(v) then return true end end end end

--[Comment]
--lua switch
function table.getswitch(t)
    setmetatable(t,{__index=function(_t) return rawget(_t,"default") end})
end

--[Comment]
-- 合并两个相同数据结构的表（根据指定键名过滤相同数据）
function table.AddNo(o, f, k)
    if o and f then
    local tmp = false
        for i = 1, #f do
            if k then 
                tmp = true
                for j = 1, #o do
                    if o[j][k] == f[i][k] then
                        tmp, o[j] = false, f[i]
                        break
                    end
                end
                if tmp then insert(o, f[i]) end
            else insert(o, f[i])
            end
        end
    end
    return o
end

--[Comment]
--math扩展
--限制[min,max]
function math.clamp(v, min, max)
    return v < min and min or v > max and max or v
end

--[Comment]
--math扩展
--限制[min,max]
function math.clamp01(v)
    return v < 0 and 0 or v > 1 and 1 or v
end

--[Comment]
--取整数部分
function math.toint(num)
    return (math.modf(num))
end

--[Comment]
--取浮点数的小数部分
function math.tofloat(num)
    return select(2, math.modf(num))
end

--[Comment]
--弹性取值
function math.slerp(from, to, str, dt)
    if dt > 1 then dt = 1 end
    local ms = dt * 1000 + 0.5
    dt = 0.001 * str
    for i = 1, ms, 1 do from = from + (to - from) * dt end
    return from
end

--[Comment]
--数组table
--返回index or 0
function table.find(tab, v)
    for i=1,#tab do if tab[i]==v then return i end end
    return 0
end

--[Comment]
--数组table
function table.removev(tab, v)
    local dx = table.find(tab, v)
    if dx~=0 then table.remove(tab, dx) end
end

--[Comment]
--table is array
function isArray(tab)
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

--[Comment]
--table to string
function tts(val, c)
    c = c or 1
    if c>=10 then
        return "##"
    end
    local eq = " = "
    local rep = "        "
    local cat = "\n"
    local str = "{\n"
    if type(val) == "table" then
        if isArray(val) then
            for i, v in ipairs(val) do
                if type(v) == "table" then
                    str = str .. string.rep(rep, c) .. tts(v, c + 1) .. cat
                else
                    str = str .. string.rep(rep, c) .. tostring(v) .. cat
                end
            end
        else
            for k, v in pairs(val) do
                if type(v) == "table" then
                    str = str .. string.rep(rep, c) .. tostring(k) .. eq .. tts(v, c + 1) .. cat
                else
                    str = str .. string.rep(rep, c) .. tostring(k) .. eq .. tostring(v) .. cat
                end
            end
        end
        str = str .. string.rep(rep, c - 1) .. "}"
    else
        str = tostring(val)
    end
    return str
end

--[Comment]
--树形打印table
function table.print(nm, tab)
    print(nm .. tts(tab))
end

--[Comment]
--table中的元素去重
function table.unique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

--[Comment]
--去除字符串首尾的空格
function string.trim(s)
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

--[Comment]
--字符串分割函数，分割为数组
--传入字符串和分隔符，返回分割后的数组
function string.split(str, sep)
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
--[Comment]
--字符串分割函数，分割为Map
--传入字符串和分隔符，返回分割后的Map
function string.splitMap(str, sep)
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
                    ret[idx < i and _sub(str, idx, i - 1) or ""] = true
                    idx = i + 1
                end
            end
        else
            local slen2 = slen - 1
            for i = 1, len do
                if i >= idx and c1 == _sbyte(str, i) and _sub(str, i, i + slen2) == sep then
                    ret[idx < i and _sub(str, idx, i - 1) or ""] = true
                    idx = i + slen
                end
            end
        end
        ret[idx <= len and _sub(str, idx, len) or ""] = true
--        for m in(str .. sep):gmatch("(.-)%" .. sep) do ret[m] = true end
        return ret
    end
end
--[Comment]
--字符串按位分割函数
--传入字符串，返回分割后的table，必须为字母、数字，否则返回nil
function string.gsplit(str)
	if str and _string.len(str) ~= 0 then
        local str_tb = {}
		for i=1,_string.len(str) do
			new_str= _sub(str,i,i)			
			if (_sbyte(new_str) >=48 and _sbyte(new_str) <=57) or (_sbyte(new_str)>=65 and _sbyte(new_str)<=90) or (_sbyte(new_str)>=97 and _sbyte(new_str)<=122) then 				
				insert(str_tb,_sub(str,i,i))				
			else
				return nil
			end
		end
		return str_tb
	else
		return nil
	end
end

--[Comment]
--string扩展
--用字符se将arr中所有的元素分割并连接起来
function string.join(se, arr)
    if arr == nil then return "" end
    local len = #arr
    if len == 0 then return "" end
    local s = tostring(arr[1])
    if len >= 2 then for i = 2, len do s = s .. se .. tostring(arr[i]) end end
    return s
end

--[Comment]
--自定义JSON字符判断
function string.hasJsonChar(str)
    if str and _string.find(str, "[][{}\"\',|#&]") then return true end
    return false
end
--[Comment]
--版本字符串检测(目标版本，当前版本)
function string.verCheck(trg, cur)
    if trg == nil or trg == "" or trg == cur then return false end
    if cur == nil or cur == "" then return true end
    trg, cur = _string.split(trg, "."), _string.split(cur, ".")
    local t, c
    for i = 1, #trg do
        t, c = trg[i], cur[i]
        if t ~= c then
            if t == nil then return false end
            if c == nil then return true end
            t, c = tonumber(t) or 0, tonumber(c) or 0
            if c < t then return true end
            if c > t then return false end
        end
    end
end

--[Comment]
--整数转换为中文显示
function number.ToCnString(num)
    num = _math.floor(num);
    if num == 0 then return '零' end
    local len = 32
    local b = 0
    local res = num < 0
    if res then num = -num end

    local chars = {}
    local index = len;
    local zero = false;
    while index > 0 do
        local mod = num % 10

        if mod == 1 then chars[index] = '一'; index = index - 1; zero = true;
        elseif mod == 2 then chars[index] = '二'; index = index - 1; zero = true;
        elseif mod == 3 then chars[index] = '三'; index = index - 1; zero = true;
        elseif mod == 4 then chars[index] = '四'; index = index - 1; zero = true;
        elseif mod == 5 then chars[index] = '五'; index = index - 1; zero = true;
        elseif mod == 6 then chars[index] = '六'; index = index - 1; zero = true;
        elseif mod == 7 then chars[index] = '七'; index = index - 1; zero = true;
        elseif mod == 8 then chars[index] = '八'; index = index - 1; zero = true;
        elseif mod == 9 then chars[index] = '九'; index = index - 1; zero = true;
        elseif zero then chars[index] = '零'; index = index - 1; zero = false;
        end

        num = _math.floor(num/10)

        if num > 0 then
            mod = b % 4
            if mod == 0 then if num % 10 ~= 0 then chars[index] = '十'; index = index - 1; end
            elseif mod == 1 then if num % 10 ~= 0 then chars[index] = '百'; index = index - 1; end
            elseif mod == 2 then if num % 10 ~= 0 then chars[index] = '千'; index = index - 1; end
            elseif mod == 3 then
                if b % 8 == 7 then
                    if num % 10 == 0 then chars[index] = '零'; index = index - 1; end
                    chars[index] = '亿'; index = index - 1;
                    zero = false;
                elseif num % 10000 ~= 0 then
                    if num % 10 == 0 then chars[index] = '零'; index = index - 1; end
                    chars[index] = '万'; index = index - 1;
                    zero = false;
                end
            end
            b = b + 1;
        else
            if index < 31 and chars[index + 1] == '一' and chars[index + 2] == '十' then index = index + 1; end
            break;
        end
    end
    if res then chars[index] = '负'; index = index - 1; end
    return _table.concat(chars,nil,index+1,len);
end
--[Comment]
--{xx}替换
function string.crep(s, rep)
    if s == nil or s == "" or rep == nil then return s end
    local len = _string.len(s)
    local b, e = 0, 1
    local c = type(rep)
    local ret = ""
    if "function" == c then
        for i = 1, len do
            c = _sbyte(s, i)
            
            if c == 123 then --123({)
                b = i + 1
            elseif c == 125 and b > 0 and i > b then --125(})
                ret = ret.._sub(s, e, b - 2)..(rep(_sub(s, b, i - 1)) or "")
                b, e = 0, i + 1
            end
        end
    elseif "table" == c then
        local function trynum(s) return tonumber(s) or s end
        for i = 1, len do
            c = _sbyte(s, i)
            if c == 123 then --123({)
                b = i + 1
            elseif c == 125 and b > 0 and i > b then --125(})
                ret = ret.._sub(s, e, b - 2)..(rep[trynum(_sub(s, b, i - 1))] or "")
                b, e = 0, i + 1
            end
        end
    else
        rep = rep and tostring(rep) or ""
        for i = 1, len do
            c = _sbyte(s, i)
            if c == 123 then --123({)
                b = i + 1
            elseif c == 125 and b > 0 and i > b then --125(})
                ret = ret.._sub(s, e, b - 2)..rep
                b, e = 0, i + 1
            end
        end
    end
    return ret
end

function string.isEmpty(str) return str == nil or str == "" end
function string.notEmpty(str) return str and str ~= "" end

--[Comment]
--整数缩写
function number.ToAbridge(num)
    if num > 10000000000 then
        return _math.floor(num / 100000000).."亿";
    elseif num > 1000000 then
        return _math.floor(num / 10000).."万";
    else
        return tostring(_math.floor(num));
    end
end

function isNumber(arg)
    return type(arg) == "number"
end

function isBoolean(arg)
    return type(arg) == "boolean"
end

function isString(arg)
    return type(arg) == "string"
end

function isFunction(arg)
    return type(arg) == "function"
end

function isTable(arg)
    return type(arg) == "table"
end

function isUserdata(arg)
    return type(arg) == "userdata"
end

function isThread(arg)
    return type(arg) == "thread"
end

function arrayAdd(arr, add)
    if arr then
        if add then
            local len = #arr
            for i = 1, #add do arr[len + i] = add[i] end
        end
    else
        arr = add
    end
    return arr
end

function arrayRemove(arr, begin, count)
    if not arr or begin == 0 or count < 1 then return end
    local len = #arr
    if len < 1 then return end
    local to
    if begin < 0 then
        to = len + begin + 1
        begin = _math.max(to - count + 1, 1)
    else
        to = _math.min(begin + count - 1, len)
    end
    local idx = 1
    for i = 1, len do
        if i < begin then
            idx = idx + 1
        elseif i > to then
            arr[idx] = arr[i]
            idx = idx + 1
        else
            arr[i] = nil
        end
    end
end

--[Comment]
function table.len(t)
    local len = 0
    for _,_ in pairs(t) do len = len + 1 end
    return len
end

--[Comment]
--value
function table.contains(tab, item)
    if not tab or not item then
        return false
    end
    for _,v in pairs(tab) do
        if v==item then
            return true
        end
    end
    return false
end

--[Comment]
function table.AddRange(tab, t)
    for k=1,#t do table.insert(tab,t[k]) end
end

--[Comment]
--给定索引是否在数组指定维数索引范围内
--tab必须是个数组
--dimension维度，同c#一样，从0开始
function table.IndexAvailable(tab, index, dimension)
    if tab==nil then
        return false
    end
    return index>=1 and index<=table.GetLength(tab,dimension)
end

--[Comment]
--Array.GetLength(int dimension)
--dimension维度，同c#一样，从0开始
function table.GetLength(tab, dimension)
    local t = tab
    for i=1,dimension do
        if t[1]==nil then return 0 end
        t = t[1]
    end
    return #t
end

--[Comment]
--Mathf.RoundToInt(float f)
--返回 f 指定的值四舍五入到最近的整数
--如果数字末尾是.5，因此它是在两个整数中间，不管是偶数或是奇数，将返回偶数
function math.RoundToInt(f)
    if f==0 then return 0 end

    local _f = math.floor(f)

    if math.abs(f-_f)==0.5 then
        return math.abs(_f)%2==0 and _f or _f+1
    else
        return math.floor(f+0.5)
    end
end

--将字符串转换为时间戳  格式："2018-01-24,02:05:08"     "02:07:08" --> 输出当天的02:07:08的时间戳  即年月日是当天
function string.UnixTimeStamp (str)
    if string.match(str,"-") == nil and string.match(str,":") == nil then
        return 
    end
     local date
     local time
    
     local y 
     local mon
     local d 
    
     local h 
     local m 
     local s 
    
    if string.match(str,"-") then
        date = string.split(str , ",")[1]
        time = string.split(str , ",")[2]

        y = string.split(date , "-")[1]
        mon = string.split(date , "-")[2]
        d = string.split(date , "-")[3]

        h = string.split(time , ":")[1]
        m = string.split(time , ":")[2]
        s = string.split(time , ":")[3]
    else
        y = os.date("%Y")
        mon = os.date("%m")
        d = os.date("%d")

        h = string.split(str , ":")[1]
        m = string.split(str , ":")[2]
        s = string.split(str , ":")[3]
    end
    return os.time({ year = tonumber(y) , month = tonumber(mon) ,day = tonumber(d) ,hour = tonumber(h) ,min = tonumber(m) ,sec = tonumber(s) })
end

--[Comment]
--整除
function math.div(a, b) return (_math.modf(a / b)) end

--[Comment]
--曲线节点生成
--path : 节点集合(Vector2[])
--rev ; 是否反向
function math.PathControlPointGenerator(path, rev)
    if rev then
        rev, path = path, { }
        for i = #rev, 1, -1 do insert(path, rev[i]:Clone()) end
    else
        rev, path = path, { }
        for i = 1, #rev do insert(path, rev[i]:Clone()) end
    end
    local len = #path
    local v1, v2 = path[len], path[len - 1]
    insert(path, Vector2(v1.x * 2 - v2.x, v1.y * 2 - v2.y))
    v1, v2 = path[1], path[2]
    insert(path, 1, Vector2(v1.x * 2 - v2.x, v1.y * 2 - v2.y))
    len = #path
    if path[2] == path[len - 1] then
        v1, v2 = path[1], path[len - 2]
        v1.x, v1.y = v2.x, v2.y
        v1, v2 = path[len], path[3]
        v1.x, v1.y = v2.x, v2.y
    end

    return path
end
--[Comment]
--曲线取样
--path : 曲线路径
--t : 0-1
--rturns : x, y
function math.Interp(path, t)
    local numSections = #path - 3
    local currPt = B_Math.min(B_Math.floor(t * numSections), numSections - 1)
    t = t * numSections - currPt
    local a, b, c, d = path[currPt + 1], path[currPt + 2], path[currPt + 3], path[currPt + 4]
    local t2 = t * t
    local t3 = t2 * t
    return 0.5 * (
        (-a.x + 3 * b.x - 3 * c.x + d.x) * t3
        + (2 * a.x - 5 * b.x + 4 * c.x - d.x) * t2
        + (c.x - a.x) * t
        + 2 * b.x
    ),
    0.5 * (
        (-a.y + 3 * b.y - 3 * c.y + d.y) * t3
        + (2 * a.y - 5 * b.y + 4 * c.y - d.y) * t2
        + (c.y - a.y) * t
        + 2 * b.y
    )
end