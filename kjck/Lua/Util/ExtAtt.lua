local _byte = string.byte
local _sub = string.sub
local type = type
local tonumber = tonumber
local insert = table.insert

--[Comment]
--扩展属性名称
ATT_NM = 
{
    --[Comment]
    --武力增加
    Str = "ak",
    --[Comment]
    --智力增加
    Wis = "ml",
    --[Comment]
    --统帅增加
    Cap = "ts",
    --[Comment]
    --生命增加
    HP = "lf",
    --[Comment]
    --技力增加
    SP = "jl",
    --[Comment]
    --兵力增加
    TP = "bl",
    --[Comment]
    --流血效果
    Bleed = "lx",
    --[Comment]
    --暴击几率增加
    Crit = "bj",
    --[Comment]
    --技能暴击几率增加
    SCrit = "jb",
    --[Comment]
    --暴击伤害
    CritDmg = "bs",
    --[Comment]
    --命中
    Acc = "mz",
    --[Comment]
    --闪避几率增加
    Dodge = "sb",
    --[Comment]
    --技能闪避几率
    SDodge = "js",
    --[Comment]
    --造成武力伤害增减
    CPD = "cpd",
    --[Comment]
    --造成技能伤害增减
    CSD = "csd",
    --[Comment]
    --受到武力伤害降低
    SPR = "wf",
    --[Comment]
    --受到技能伤害降低
    SSR = "mf",
    --[Comment]
    --移动速度
    MoveSpeed = "ys",
    --[Comment]
    --攻击速度
    AtkSpeed = "gs",
    --[Comment]
    --攻击击晕
    Stun = "xy",
    --[Comment]
    --技能击晕
    SStun = "jy",
    --[Comment]
    --CD缩短
    CD = "cd",
    --[Comment]
    --受到武将武力伤害降低
    SHPR = "cf",
    --[Comment]
    --受到士兵武力伤害降低
    SSPR = "bf",
    --[Comment]
    --士兵属性增加(生命和武力)
    SoA = "ba",
    --[Comment]
    --士兵暴击几率增加
    SoCrit = "bbj",
    --[Comment]
    --士兵暴击伤害
    SoCritDmg = "bbs",
    --[Comment]
    --士兵命中
    SoAcc = "bmz",
    --[Comment]
    --士兵闪避几率增加
    SoDodge = "bsb",
    --[Comment]
    --士兵技能闪避几率
    SoSDodge = "bjs",
    --[Comment]
    --士兵受到武力伤害降低
    SoSPR = "bwf",
    --[Comment]
    --士兵受到技能伤害降低
    SoSSR = "bmf",
    --[Comment]
    --士兵移动速度
    SoMoveSpeed = "bys",
    --[Comment]
    --士兵攻击速度
    SoAtkSpeed = "bgs",

    --[Comment]
    --武将全属性增加(百分比)(STR INT CAP HP)
    HeroAll = "ha",

    --[Comment]
    --武力增加(百分比)
    StrP = "akp",
    --[Comment]
    --智力增加(百分比)
    WisP = "mlp",
    --[Comment]
    --统帅增加(百分比)
    CapP = "tsp",
    --[Comment]
    --生命增加(百分比)
    HPP = "lfp",

    --[Comment]
    --全军受到武力伤害降低
    QSPR = "qwf",
    --[Comment]
    --全军受到技能伤害降低
    QSSR = "qmf",
    --[Comment]
    --全军攻速增加
    QAtkSpeed = "qgs",

    --[Comment]
    --敌将武力削减
    _Str = "-ak",
    --[Comment]
    --敌将智力削减
    _Wis = "-ml",
    --[Comment]
    --敌将统帅削减
    _Cap = "-ts",
    --[Comment]
    --敌将生命削减
    _HP = "-lf",
    --[Comment]
    --敌将技力削减
    _SP = "-jl",
    --[Comment]
    --敌将兵力削减
    _TP = "-bl",
    --[Comment]
    --敌将武力削减(百分比)
    _StrP = "-akp",
    --[Comment]
    --敌将智力削减(百分比)
    _WisP = "-mlp",
    --[Comment]
    --敌将统帅削减(百分比)
    _CapP = "-tsp",
    --[Comment]
    --敌将生命削减(百分比)
    _HPP = "-lfp",
    --[Comment]
    --敌将技力削减(百分比)
    _SPP = "-jlp",
    --[Comment]
    --敌将兵力削减(百分比)
    _TPP = "-blp",
    --[Comment]
    --敌将技能闪避削减
    _SDodge = "-js",
    --[Comment]
    --敌将CD延长
    _CD = "-cd",
    --[Comment]
    --敌方全军移速降低
    _QMoveSpeed = "-qys",
    --[Comment]
    --减武防效果
    _SPRP = "-wfp",
    --[Comment]
    --减技防效果
    _SSRP = "-mfp",

    --[Comment]
    --穿刺
    CC = "cc",
    --[Comment]
    --挡格
    DG = "dg",
}

--[Comment]
--扩展属性排序值
local _att_sort =
{
    --[Comment]
    --武力增加
    ["ak"] =  1,
    --[Comment]
    --智力增加
    ["ml"] = 2,
    --[Comment]
    --统帅增加
    ["ts"] = 3,
    --[Comment]
    --生命增加
    ["lf"] = 4,
    --[Comment]
    --技力增加
    ["jl"] = 5,
    --[Comment]
    --兵力增加
    ["bl"] = 6,
    --[Comment]
    --武力增加(百分比)
    ["akp"] = 7,
    --[Comment]
    --智力增加(百分比)
    ["mlp"] = 8,
    --[Comment]
    --统帅增加(百分比)
    ["tsp"] = 9,
    --[Comment]
    --生命增加(百分比)
    ["lfp"] = 10,
    --[Comment]
    --武将全属性增加(百分比)(STR INT CAP HP)
    ["ha"] = 11,
    --[Comment]
    --暴击几率增加
    ["bj"] = 12,
    --[Comment]
    --技能暴击几率增加
    ["jb"] = 13,
    --[Comment]
    --暴击伤害
    ["bs"] = 14,
    --[Comment]
    --命中
    ["mz"] = 15,
    --[Comment]
    --闪避几率增加
    ["sb"] = 16,
    --[Comment]
    --技能闪避几率
    ["js"] = 17,
    --[Comment]
    --造成武力伤害增减
    ["cpd"] = 18,
    --[Comment]
    --造成技能伤害增减
    ["csd"] = 19,
    --[Comment]
    --受到武力伤害降低
    ["wf"] = 20,
    --[Comment]
    --受到技能伤害降低
    ["mf"] = 21,
    --[Comment]
    --移动速度
    ["ys"] = 22,
    --[Comment]
    --攻击速度
    ["gs"] = 23,
    --[Comment]
    --CD缩短
    ["cd"] = 24,
    --[Comment]
    --穿刺
    ["cc"] = 25,
    --[Comment]
    --挡格
    ["dg"] = 26,
    --[Comment]
    --攻击击晕
    ["xy"] = 28,
    --[Comment]
    --技能击晕
    ["jy"] = 29,
    --[Comment]
    --流血效果
    ["lx"] = 27,

    --[Comment]
    --士兵属性增加(生命和武力)
    ["ba"] = 28,
    --[Comment]
    --士兵暴击几率增加
    ["bbj"] = 29,
    --[Comment]
    --士兵暴击伤害
    ["bbs"] = 30,
    --[Comment]
    --士兵命中
    ["bmz"] = 31,
    --[Comment]
    --士兵闪避几率增加
    ["bsb"] = 32,
    --[Comment]
    --士兵技能闪避几率
    ["bjs"] = 33,
    --[Comment]
    --士兵受到武力伤害降低
    ["bwf"] = 34,
    --[Comment]
    --士兵受到技能伤害降低
    ["bmf"] = 35,
    --[Comment]
    --士兵移动速度
    ["bys"] = 36,
    --[Comment]
    --士兵攻击速度
    ["bgs"] = 37,

    --[Comment]
    --全军受到武力伤害降低
    ["qwf"] = 38,
    --[Comment]
    --全军受到技能伤害降低
    ["qmf"] = 39,
    --[Comment]
    --全军攻速增加
    ["qgs"] = 40,
   
    --[Comment]
    --受到武将武力伤害降低
    ["cf"] = 41,
    --[Comment]
    --受到士兵武力伤害降低
    ["bf"] = 42,

    --[Comment]
    --敌将武力削减
    ["-ak"] = 43,
    --[Comment]
    --敌将智力削减
    ["-ml"] = 44,
    --[Comment]
    --敌将统帅削减
    ["-ts"] = 45,
    --[Comment]
    --敌将生命削减
    ["-lf"] = 46,
    --[Comment]
    --敌将技力削减
    ["-jl"] = 47,
    --[Comment]
    --敌将兵力削减
    ["-bl"] = 48,
    
    --[Comment]
    --敌将武力削减(百分比)
    ["-akp"] = 49,
    --[Comment]
    --敌将智力削减(百分比)
    ["-mlp"] = 50,
    --[Comment]
    --敌将统帅削减(百分比)
    ["-tsp"] = 51,
    --[Comment]
    --敌将生命削减(百分比)
    ["-lfp"] = 52,
    --[Comment]
    --敌将技力削减(百分比)
    ["-jlp"] = 53,
    --[Comment]
    --敌将兵力削减(百分比)
    ["-blp"] = 54,
    --[Comment]
    --敌将技能闪避削减
    ["-js"] = 66,
    --[Comment]
    --敌将CD延长
    ["-cd"] = 67,
    --[Comment]
    --敌方全军移速降低
    ["-qys"] = 77,
    --[Comment]
    --减武防效果
    ["-wfp"] = 78,
    --[Comment]
    --减技防效果
    ["-mfp"] = 79,
}
--[Comment]
--扩展属性排序值
ATT_SORT = setmetatable(_att_sort, { __index = function(t, k) return 0 end })

--[Comment]
--属性名称反映射
local _attmap = {}
--写入属性名称反映射
for k, v in pairs(ATT_NM) do _attmap[v] = k end

--[Comment]
--属性集合
local _att = {}

--[Comment]
--属性键排序
function _att.MarkSort(m1, m2) return _att_sort[m1] < _att_sort[m2] end
--[Comment]
--属性排序
function _att.AttSort(a1, a2) return _att_sort[a1[1]] < _att_sort[a2[1]] end

--[Comment]
--给属性集添加一条属性
local function AddKV(att, k, v, pos)
    if k and v and _attmap[k] and "number" == type(v) then
        if pos and pos >= 1 and pos <= #att then
            insert(att, pos, { k, v })
        else
            insert(att, { k, v })
        end
        att[k] = (att[k] or 0)  + v
        return true
    end
    return false
end
--[Comment]
--解析属性到源属性表
local function Parse(src, str, pos)
    if str == nil then return src end
    local len = string.len(str)
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
--汇入一条属性
local function ConvKV(att, k, v)
    if _attmap[k] and "number" == type(v) then att[k] = (att[k] or 0) + v end
end
--[Comment]
--汇总属性
local function Conv(att)
    --清除原有
    for k, _ in pairs(_attmap) do if att[k] then att[k] = nil end end
    --汇总
    local a
    for i = 1, #att do
        a = att[i]
        if "table" == type(a) then ConvKV(att, a[1], a[2]) end
    end
end
--索引
function _att.__index(t, k)
    return rawget(_att, k) or (_attmap[k] and 0 or nil)
end
--构造
function _att.__call(t, arg)
    if arg then
        t = type(arg)
        if "string" == t then
            return setmetatable(Parse({ }, arg), _att)
        elseif "table" == t then
            if Obj.is(arg, _att) then return arg end
            Conv(arg)
            return setmetatable(arg, _att)
        end
    end
    return setmetatable( { }, _att)
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
--联合给定的所有属性(字符串、表)
function _att.Union(...)
    local args = {...}
    local s = table.maxn(args)
    if s < 1 then return nil end
    local t
    local att = _att()
    for i = 1, s do Merge(att, args[i]) end
    return att
end
--[Comment]
--取属性值
function _att.Get(att, k) return att and _attmap[k] and att[k] or 0 end
--[Comment]
--取属性项(匹配给定的键)的值
function _att.IKGet(ai, k) return ai and k == ai[1] and _attmap[k] and ai[2] or 0 end
--[Comment]
--验证属性Key
function _att.Verify(k) return _attmap[k] and k or nil end
--[Comment]
--尝试解析属性字符串为属性表，可为nil
function _att.Parse(str) return Parse(nil, str) end
--[Comment]
--移除属性
function _att.Remove(att, k)
    if att == nil then return end
    local a
    if _attmap[k] then
        for i = #att, 1, -1 do
            a = att[i]
            if a and a[1] == k then
                table.remove(att, i)
--                att[k] = att[k] and (att[k] - a[2])
            end
        end
        att[k] = nil
        return
    end
    a = table.remove(att, k)
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
--[Comment]
--汇总属性
_att.Conv = Conv
--[Comment]
--汇入一条不写入列表的属性(self, k(键), v(值))
_att.ConvKV = ConvKV
--配置元表
setmetatable(_att, _att)
--[Comment]
--扩展属性对象
ExtAtt = _att