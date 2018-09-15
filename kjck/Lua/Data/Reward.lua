--[[
奖励接口说明

值1:1=玩家属性 2=道具 3=装备 4=武将 5=装备碎片 6=将魂 7=宝石 8=副将 9=副将经验 10=军备 11=军备残片 12=活动代币 13=天机专属 14=联盟声望 负数=武将SN

值2:(玩家属性:1=银币 2=金币 3=血库 4=兵力 5=积分 6=粮草 7=封赏令 8=魂币 9=银票 10=军功 11=头像 12=称号 13=矿脉采集点 14=幻境币 15=巅峰币)
    (道具:道具编号)
    (武将:武将DB)
    (武将属性:1=EXP 2=HP 3=SP 4=兵力 5=武力 6=智力 7=忠诚 8=统帅 9=精力)
    (装备:装备等阶*1000+装备DB)
    (碎片:装备DB)
    (将魂:武将DB)
    (宝石:宝石DBSN)
    (副将:副将DBSN)
    (副将经验:经验值)
    (军备:军备DBSN*1000+等级)
    (军备残片:军备DBSN*1000+品质)
    (活动代币:代币编号)
    (天机专属:武将DBSN)

值3:一般为数量或值
    (玩家属性:数量(头像&称号为SN))
    (武将:武将SN)
    (装备:装备SN)
    (副将:SN)
    (副将经验：副将SN)
    (军备:军备SN)
]]--

local _byte = string.byte
local _sub = string.sub
local _find = string.find
local _tnum = tonumber
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable
local rawget = rawget

local _rw =
{
    --[Comment]
    --相关数据
    dat = nil,
    --[Comment]
    --数据类型
    datTyp = nil,

    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --描述
    i = nil,
    --[Comment]
    --稀有度
    rare = 0,
    --[Comment]
    --等阶
    evo = nil,
    --[Comment]
    --等级
    lv = nil,
    --[Comment]
    --数量
    qty = nil,

    --[Comment]
    --图标
    ico = nil,
    --[Comment]
    --显示框
    frame = "frame_props",

    --[Comment]
    --是否是碎片
    IsPiece = function(r) return r[1] == 5 end,
    --[Comment]
    --是否是将魂
    IsSoul = function(r) return r[1] == 6 end,
    --[Comment]
    --是否是武将
    IsHero = function(r) return r[1] == 4 end,

    --[Comment]
    --Item接口
    getName = function(r) return LN(r.nm) end,
    --[Comment]
    --Item接口
    getIntro = function(r) return L(r.i) end,
    --[Comment]
    --ToolTip接口
    getPropTip = function(r) return LN(r.nm), L(r.i) end,

    --[Comment]
    --比较两个奖励是否相同
    Equals = function(a, b)
        if a and b then
            local v1 = a[1]
            return v1 == b[1] and a[2] == b[2] and(v1 == 3 or v1 == 4 or v1 == 8 or v1 == 10 or a[3] == b[3])
        end
    end,
    --[Comment]
    --输出
    ToString = function(r)
        return r and "[firstType=" + tostring(r[1]) + ",secType=" + tostring(r[2]) + ",value=" + tostring(r[3]) + "]" or "nil";
    end,
}
--索引
_rw.__index = function(t, k)
    local v = rawget(_rw, k)
    if v == nil then
        v = rawget(t, "dat")
--        if type(v) == "table" then return rawget(v, k) end
        return v and v[k]
    end
    return v
 end

--[Comment]
--未定义
local undef = setmetatable({ 0, 0, 0, invalid = true }, _rw)

--[Comment]
--玩家属性名称
local _panm = { "银币", "金币", "血库", "兵力", "钻石", "粮草", "封赏令", "魂币", "盟券", "军功", "头像", "称号", "开采值", "VIP经验值", "主城经验值", "竞技场积分", "竞技场声望", "日常活跃度", "体力值", "酒值", "国战贡献值"}
--[Comment]
--玩家属性图标名称
local _painm = { "sp_silver", "sp_gold", "", "", "sp_diamond", "p_food", "p_token", "p_soul", "p_acash", "p_amerit", "", "htitle_common", "p_mine", "sp_vipexp", "sp_homeexp", "", "tex_ranksolo_renown", "tex_act", "tex_vit", "tex_wine", "tex_country_act"}

--[Comment]
--验证值
local function Verify(v1, v2) return "number" == type(v2) and "number" == type(v1) and v1 ~= 0 and v1 <= 14 or "string" == type(v1) end
--[Comment]
--若奖励是装备，获取装备的DBSN
local function GetEquipDBSN(v2) return v2 and v2 % 1000 or 0 end
--[Comment]
--若奖励是装备，获取装备的DBSN
_rw.GetEquipDBSN = GetEquipDBSN
--[Comment]
--若奖励是装备，获取装备的进阶等级
local function GetEquipEvo(v2) return v2 and(math.modf(v2 / 1000)) or 0 end
--[Comment]
--若奖励是装备，获取装备的进阶等级
_rw.GetEquipEvo = GetEquipEvo
--[Comment]
--验证奖励数据
function _rw.Verify(rw)
    if "table" == type(rw) and #rw >= 3 then
        local tp = type(rw[1])
        if "string" == tp or  "number" == tp and rw[1] ~= 0 and rw[1] <= 13 then
            tp = type(rw[2])
            if "number" == tp or "string" == tp then
                tp = type(rw[3])
                return "number" == tp or "string" == tp
            end
        end
    end
end

--[Comment]
--接口方法
local _ifunc = 
{
    --[Comment]
    --玩家属性显示
    GetPattPropTip = function(r) return ColorStyle.PlayerAtt(LN(r.nm), r[2]),  L("数量") .. ":" ..(r.qty or 0) end,
    --[Comment]
    --活动分显示
    GetActScoreIntro = function(r) return DB_Act.ScoreIntro(r.dat)  end,
    --[Comment]
    --活动分显示
    GetActScorePropTip = function(r) return DB_Act.ScorePropTip(r.dat, r.qty) end,
}

--[Comment]
--获取图标名称
local function GetIcoNm(v1, v2, v3)
    --玩家属性
    if v1 == 1 then return v2 == 11 and ResName.PlayerIcon(v3 or 0) or _painm[v2] or "" end
    --道具
    if v1 == 2 then return ResName.PropsIcon(DB.GetProps(v2).img) end
    --装备
    if v1 == 3 then return ResName.EquipIcon(DB.GetEquip(GetEquipDBSN(v2)).img) end
    --武将
    if v1 == 4 then return ResName.HeroIcon(DB.GetHero(v2).img) end
    --装备碎片
    if v1 == 5 then return ResName.EquipIcon(DB.GetEquip(v2).img) end
    --将魂
    if v1 == 6 then return ResName.HeroIcon(DB.GetHero(v2).img) end
    --宝石
    if v1 == 7 then return ResName.GemIcon(v2 or 0) end
    --副将
    if v1 == 8 then return ResName.DeheroIcon(DB.GetDehero(v2).img) end
    --副将经验
    if v1 == 9 then
        v3 = user.GetDehero(v3)
        return v3 and ResName.DeHeroIcon(v3.img) or ""
    end
    --军备
    if v1 == 10 then
        v2, v3 = DB_Dequip.GetDbAndLvFromRsn(v2)
        return ResName.DequipIcon(DB.GetDequip(v2).img, DB.GetDequipLv(v3).rare)
    end
    --军备残片
    if v1 == 11 then
        v2, v3 = PY_DequipSp.GetDbAndRareFromSn(v2)
        return ResName.DequipIcon(DB.GetDequip(v2).img, v3 or 0)
    end
    --活动分
    if v1 == 12 then return ResName.ActScoreIcon(DB.GetAct(v2).ico) end
    --天机专属
    if v1 == 13 then return ResName.SexclIcon(DB.GetSexcl(v2).img) end
    --联盟声望
    if v1 == 14 then return "p_renown" end

    return ""
end
--[Comment]
--获取图像名称
function _rw.IcoName(v1, v2, v3) return v2 and GetIcoNm(v1, v2, v3) or GetIcoNm(v1[1], v1[2], v1[3]) end
--[Comment]
--获取ToolTip接口
local function GetPropTip(v1, v2, v3)
    if "table" == type(v1) then
        v2 = v1[2]
        v3 = v1[3]
        v1 = v1[1]
    end

    --玩家属性
    if v1 == 1 then
        if v2 == 10 then return DB.GetAvatar(v3):getPropTip() end
        if v2 == 11 then return DB.GetHttl(v3):getPropTip() end
        return ColorStyle.PlayerAtt(LN(_panm[v2]), v2), L("数量") .. ":" ..(v3 or 0)
    end
    --道具
    if v1 == 2 then return DB.GetProps(v2):getPropTip(v3 or 0) end
    --装备
    if v1 == 3 then return DB.GetEquip(GetEquipDBSN(v2)):getPropTip(GetEquipEvo(v2)) end
    --武将
    if v1 == 4 then return DB.GetHero(v2):getPropTip() end
    --装备碎片
    if v1 == 5 then return DB.GetEquip(v2):getPropTip(v3 or 0) end
    --将魂
    if v1 == 6 then return PY_Soul.getPropTip(DB.GetHero(v2), v3 or 0) end
    --宝石
    if v1 == 7 then return DB.GetGem(v2):getPropTip(v3 or 0) end
    --副将
    if v1 == 8 then return DB.GetDehero(v2):getPropTip() end
    --副将经验
    if v1 == 9 then
        v3 = user.GetDehero(v3)
        return v3 and DB_Dehero.getExpPropTip(v3, v2)
    end
    --军备
    if v1 == 10 then
        v2, v3 = DB_Dequip.GetDbAndLvFromRsn(v2)
        return DB.GetDequip(v2):getPropTip(v3)
    end
    --军备残片
    if v1 == 11 then
        v1, v2 = PY_DequipSp.GetDbAndRareFromSn(v2)
        return PY_DequipSp.getPropTip(DB.GetDequip(v1), v2, v3)
    end
    --活动分
    if v1 == 12 then return DB.GetAct(v2):ScorePropTip(v3 or 0) end
    --天机专属
    if v1 == 13 then return DB.GetSexcl(v2):getPropTip(v3 or 0) end
    
end
--[Comment]
--显示奖励提示
function _rw.ShowPropTip(v1, v2, v3) ToolTip.ShowPropTip(GetPropTip(v1, v2, v3)) end

--[Comment]
--解析奖励值
local function getval(v)
    if v == nil or v == "" then return 0 end
    local n = _tnum(v)
    --暂不解析int64，以字符串返回
    return n and((n >= -99999999999999 and n <= 99999999999999) or _find(v, '.', 1, true)) and n or v
end
--[Comment]
--解析奖励字符串
function _rw.Parse(str)
    if str == nil then return src end
    local len = string.len(str)
    if len < 3 then return src end

    local ret = { }
    local c
    local idx = 1
    local v1, v2, v3 = nil, nil, nil
    for i = 1, len do
        c = _byte(str, i)
        if c == 124 then
            --124 (|)
            if v1 and v2 then table.insert(ret, { v1, v2, v3 or i > idx and getval(_sub(str, idx, i - 1) or 0) }) end
            v1, v2, v3 = nil, nil, nil
            idx = i + 1
        elseif c == 44 and i > idx then
            --44 (,)
            if v1 == nil then
                v1 = getval(_sub(str, idx, i - 1))
            elseif v2 == nil then
                v2 = getval(_sub(str, idx, i - 1))
            elseif v3 == nil then
                v3 = getval(_sub(str, idx, i - 1))
            end
            idx = i + 1
        end
    end

    if idx <= len and v1 and v2 and v3 == nil then
        v3 = getval(_sub(str, idx, len))
    end

    if v1 and v2 then table.insert(ret, { v1, v2, v3 or 0 }) end

    return ret
end

--[Comment]
--剔除消耗的
function _rw.CullCon(rws)
    if rws == nil then return end
    return table.findall(rws, function(r) r = r[3]; return r and r > 0 or "string" == type(r) end)
end
--[Comment]
--塌缩奖励接口
function _rw.CollapseReward(rws)
    if rws == nil or #rws < 2 then return end
    local idx, len = 1, #rws
    local rw
    local v1, v2, v3
    for i = 2, len do
        rw = rws[i]
        v1 = rw[1]
        if (v1 == 1 or v1 == 2 or v1 == 5 or v1 == 6 or v1 == 9 or v1 == 11 or v1 == 12 or v1 == 13 or "string" == type(v1) or v1 < 0) and "number" == type(v3) then
            v2, v3 = rw[2], rw[3]
            for j = 1, idx do
                rw = rws[j]
                if v1 == rw[1] and v2 == rw[2] and "number" == type(rw[3]) then
                    rw[3] = rw[3] + v3
                    v1 = 0
                    break
                end
            end
        end
        if v1 ~= 0 then
            if i > idx then rws[idx] = rws[i] end
            idx = idx + 1
        end
    end
    if len > idx then for i = len, idx, -1 do table.remove(rws, i) end end
end

--[Comment]
--构造
function _rw.__call(t, v1, v2, v3)
    if v1 == nil then return undef end
    if "table" == type(v1) then
        t = getmetatable(v1)
        if t == _rw then return v1 end
        if t == nil and #v1 >= 2 and Verify(v1[1], v1[2]) then
            t, v1, v2, v3 = v1, v1[1], v1[2], v1[3] or 0
            t[3] = v3
        else
            return undef
        end
    elseif Verify(v1, v2) then
        v3 = v3 or 0
        t = { v1, v2, v3 }
    else
        return undef
    end
    --玩家属性
    if v1 == 1 then
        if v2 == 11 then
            v2 = DB.GetAvatar(v3)
            t.dat = v2
            t.datTyp = DB_Avatar
            t.i = v2.i
            t.rare = v2.rare
            t.frame = "frame_vip"
            t.ico = ResName.PlayerIcon(v3 or 0)
            t.getPropTip = DB_Avatar.getPropTip
        elseif v2 == 12 then
            v2 = DB.GetHttl(v3)
            t.dat = v2
            t.datTyp = DB_Httl
            t.nm = v2.nm
            t.i = v2.i
            t.rare = v2.rare
            t.ico = _painm[12]
            t.getPropTip = DB_Httl.getPropTip
        else
            t.nm = _panm[v2]
            if t.nm == nil then return undef end
            t.dat = "player_att"
            t.qty = v3 or 0
            t.ico = _painm[v2]
            t.getPropTip = _ifunc.GetPattPropTip
        end
    --道具
    elseif v1 == 2 then
        v2 = DB.GetProps(v2)
        t.dat = v2
        t.datTyp = DB_Props
        t.nm = v2.nm
        t.i = v2.i
        t.ti = v2.ti
        t.qty = v3 or 0
        t.ico = ResName.PropsIcon(v2.img)
        t.getPropTip = DB_Props.getPropTip
    --装备
    elseif v1 == 3 then
        v3 = DB.GetEquip(GetEquipDBSN(v2))
        t.dat = v3
        t.datTyp = DB_Equip
        t.nm = v3.nm
        t.i = v3.i
        t.rare = v3.rare or 1
        t.frame = "frame_" .. t.rare
        t.evo = GetEquipEvo(v2)
        t.lv = 0
        t.ico = ResName.EquipIcon(v3.img)
        t.getName = DB_Equip.getName
        t.getPropTip = DB_Equip.getPropTip
    --武将
    elseif v1 == 4 then
        v3 = DB.GetHero(v2)
        t.dat = v3
        t.datTyp = DB_Hero
        t.nm = v3.nm
        t.i = v3.i
        t.rare = v3.rare or 1
        t.frame = "frame_props"
        t.evo = 0
        t.lv = 0
        t.ico = ResName.HeroIcon(v3.img)
        t.getPropTip = DB_Hero.getPropTip
    --装备碎片
    elseif v1 == 5 then
        v2 = DB.GetEquip(v2)
        t.dat = v2
        t.datTyp = DB_Equip
        t.nm = v2.nm
        t.i = v2.i
        t.rare = v2.rare or 1
        t.frame = "frame_" .. t.rare
        t.qty = v3 or 0
        t.ico = ResName.EquipIcon(v2.img)
        t.getName = PY_EquipSp.getName
        t.itemName = PY_EquipSp.itemName
        t.getPropTip = PY_EquipSp.getPropTip
    --将魂
    elseif v1 == 6 then
        v2 = DB.GetHero(v2)
        t.dat = v2
        t.datTyp = DB_Hero
        t.nm = PY_Soul.itemName(v2)--PY_Soul.getName(v2)
        t.getName = PY_Soul.getName
        t.getPropTip = PY_Soul.getPropTip
        t.rare = v2.rare or 1
        t.frame = "frame_hero_soul"
        t.qty = v3 or 0
        t.ico = ResName.HeroIcon(v2.img)
        t.getName = PY_Soul.getName
        t.itemName = PY_Soul.getName
        t.getPropTip = PY_Soul.getPropTip
    --宝石
    elseif v1 == 7 then
        v2 = DB.GetGem(v2)
        t.dat = v2
        t.datTyp = DB_Gem
        t.nm = v2.nm
        t.frame = "frame_gem"
        t.qty = v3 or 0
        t.ico = ResName.GemIcon(v2.sn or 0)
        t.getName = DB_Gem.getName
        t.getPropTip = DB_Gem.getPropTip
    --副将
    elseif v1 == 8 then
        v2 = DB.GetDehero(v2)
        t.dat = v2
        t.datTyp = DB_Dehero
        t.nm = v2.nm
        t.i = v2.i
        t.rare = v2.rare or 1
        t.frame = "frame_" .. t.rare
        t.ico = ResName.DeheroIcon(v2.img)
        t.getPropTip = DB_Dehero.getPropTip
    --副将经验
    elseif v1 == 9 then
        v3 = user.GetDehero(v3)
        if v3 then
            t.dat = v3
            t.datTyp = DB_Dehero
            t.nm = v3.nm
            t.i = string.format(L("副将%s 经验增加%s"), LN(v3.rnm or v3.nm), v2)
            t.rare = v3.rare or 1
            t.frame = "frame_dehero_exp"
            t.qty = v2 or 0
            t.ico = ResName.DeheroIcon(v3.img)
            t.getName = DB_Dehero.getExpName
            t.getIntro = DB_Dehero.getExpIntro
            t.getPropTip = DB_Dehero.getExpPropTip
        end
    --军备
    elseif v1 == 10 then
        v1, v2 = DB_Dequip.GetDbAndLvFromRsn(v2)
        v1 = DB.GetDequip(v1)
        v2 = DB.GetDequipLv(v2)
        t.dat = v1
        t.datTyp = DB_Dequip
        t.lvd = v2
        t.rare = v2.rare or 1
        t.nm = v1:GetRareName(t.rare)
        t.i = v1:GetRareIntro(t.rare)
        t.frame = "frame_" .. t.rare
        t.getName = PY_Dequip.getName
        t.getPropTip = PY_Dequip.getPropTip
        t.ico = ResName.DequipIcon(v1.img, v2.rare)
    --军备残片
    elseif v1 == 11 then
        v2 = PY_DequipSp(v2, v3)
        t.dat = v2
        t.datTyp = PY_DequipSp
        t.db = v2
        t.rare = v2.rare
        t.nm = v2.nm
        t.i = v2.i
        t.frame = "frame_" .. t.rare
        t.qty = v3 or 0
        t.getName = PY_DequipSp.getName
        t.getIntro = PY_DequipSp.getIntro
        t.getPropTip = PY_DequipSp.getPropTip
        t.ico = ResName.DequipIcon(v2.img, v2.rare)
    --活动积分
    elseif v1 == 12 then
        v2 = DB.GetAct(v2)
        t.dat = v2
        t.datTyp = DB_Act
        t.nm = v2.snm
        t.qty = v3 or 0
        t.getIntro = _ifunc.GetActScoreIntro
        t.getPropTip = _ifunc.GetActScorePropTip
        t.ico = ResName.ActScoreIcon(v2.ico)
    --天机专属
    elseif v1 == 13 then
        v2 = DB.GetSexcl(v2)
        t.dat = v2
        t.datTyp = DB_Sexcl
        t.rare = v2.rare or 1
        t.nm = v2.nm
        t.i = v2.i
        t.qty = v3 or 0
        t.getPropTip = DB_Sexcl.getPropTip
        t.ico = ResName.SexclIcon(v2.img)
    --联盟声望
    elseif v1 == 14 then
        t.dat = {"ally_Renown"}
        t.nm = "联盟声望"
        t.qty = v3 or 0
        t.getPropTip = _ifunc.GetPattPropTip
        t.ico = "p_renown"
    end

    return setmetatable(t, _rw)
end

function _rw.__tostring(r)
    return "["..tostring(r[1])..","..tostring(r[2])..","..tostring(r[3]).."]"
end

--[Comment]
--未定义
_rw.undef = undef
--设置元表
setmetatable(_rw, _rw)
--[Comment]
--奖励对象
RW = _rw

