local getmetatable = getmetatable
local ipairs = ipairs
local pairs = pairs

local QYBattle = QYBattle
local BD_Const = QYBattle.BD_Const
local B_Math = QYBattle.B_Math
local B_Vector = QYBattle.B_Vector
local BE_Type = QYBattle.BE_Type
local BD_AID = QYBattle.BD_AID
local BD_ANM = QYBattle.BD_ANM
local BAT_CMD = QYBattle.BAT_CMD
local BD_Soldier = QYBattle.BD_Soldier
local BD_DPS_TYPE = QYBattle.BD_DPS.Type
local BD_DPS_TAG = QYBattle.BD_DPS.Tag
local BD_Buff = QYBattle.BD_Buff

local BuffsUpdate = QYBattle.B_Buffs.Update
local GetBuffsAtt = QYBattle.B_Buffs.GetAtt

local _base = QYBattle.BD_CombatUnit
local STATUS = _base.STATUS
local CheckEnemy = _base.CheckEnemy

local _hero = { }

--region 数据部分

--获取对应的扩展加成
local function GetExtAtt(h, mark)
    return h.dat:GetExtAtt(mark) + h.battle:GetExtAtt(mark, h.isAtk) + (h.lnpImp[mark] or 0) + (h.dehero and h.dehero:GetExtAtt(mark) or 0)
end
--初始化所有属性
local function ResetAttrib(h)
    h.dmg.value = -1
    h.realTP = -1
    for i = 1, #h.attChanged do h.attChanged[i] = true end

    local dat = h.dat
    dat.hp.value = B_Math.min(dat.hp.value, h.MaxHP)
    dat.sp.value = B_Math.min(dat.sp.value, h.MaxSP)
    dat.tp.value = B_Math.min(dat.tp.value, h.MaxTP)

    h.infoChanged = true
end
--校对最大HP值
local function CheckMaxHP(h)
    h.attChanged[BD_AID.HP] = false
    local lastHP = h.maxHP.value
    local curHP = B_Math.max(B_Math.ceil(h.dat.max_hp.value * (1 + (h.bonus[4].value + GetBuffsAtt(h.buffs, BD_AID.HP)) * 0.01)), 1)
    h.maxHP.value = curHP
    if lastHP > 0 then
        if lastHP < curHP then
            h.dat.hp.value = B_Math.ceil(curHP * h.dat.hp.value / lastHP)
        elseif lastHP > curHP then
            h.dat.hp.value = B_Math.min(h.dat.hp.value, curHP)
        end
    end
end
--校对最大SP值
local function CheckMaxSP(h)
    h.attChanged[BD_AID.SP] = false
    local lastSP = h.maxSP.value
    local curSP = B_Math.max(B_Math.ceil(h.dat.max_sp.value * (1 + (h.bonus[5].value + GetBuffsAtt(h.buffs, BD_AID.SP)) * 0.01)), 1)
    h.maxSP.value = curSP
    if lastSP > 0 then
        if lastSP < curSP then
            h.dat.sp.value = B_Math.ceil(curSP * h.dat.sp.value / lastSP)
        elseif lastSP > curSP then
            h.dat.sp.value = B_Math.min(h.dat.sp.value, curSP)
        end
    end
end
--属性器
local _get =
{
    x = function(h) return h._x.value end,
    y = function(h) return h._y.value end,
    Command = function(h) return h.isAtk and h.map.atkHeroCmd or h.map.defHeroCmd end,
    SkillCount = function(h) return h.skill and #h.skill end,

    --是否是远程兵种
    IsCasterSoldier = function(h) h = h.dat.arm.value; return h == 4 or h == 6 end,

    --武力
    Str = function(h)
        if h.attChanged[BD_AID.Str] then
            h.attChanged[BD_AID.Str] = false
            h.str.value = B_Math.max(B_Math.ceil(h.dat.str.value * (1 + (h.bonus[1].value + GetBuffsAtt(h.buffs, BD_AID.Str)) * 0.01) + h.bonusExt[1].value), 1)
        end
        return h.str.value
    end,
    --智力
    Wis = function(h)
        if h.attChanged[BD_AID.Wis] then
            h.attChanged[BD_AID.Wis] = false
            h.wis.value = B_Math.max(B_Math.ceil(h.dat.wis.value * (1 + (h.bonus[2].value + GetBuffsAtt(h.buffs, BD_AID.Wis)) * 0.01) + h.bonusExt[2].value), 1)
        end
        return h.wis.value
    end,
    --统帅
    Cap = function(h)
        if h.attChanged[BD_AID.Cap] then
            h.attChanged[BD_AID.Cap] = false
            h.cap.value = B_Math.max(B_Math.ceil(h.dat.cap.value * (1 + (h.bonus[3].value + GetBuffsAtt(h.buffs, BD_AID.Cap)) * 0.01) + h.bonusExt[3].value), 1)
        end
        return h.cap.value
    end,
    --最大生命值
    MaxHP = function(h)
        if h.attChanged[BD_AID.HP] then CheckMaxHP(h) end
        return h.maxHP.value
    end,
    --最大技力
    MaxSP = function(h)
        if h.attChanged[BD_AID.SP] then CheckMaxSP(h) end
        return h.maxSP.value
    end,
    --最大兵力
    MaxTP = function(h) return h.dat.max_tp.value end,
    --护盾
    Shield = function(h)
        if h.attChanged[BD_AID.Shield] then
            h.attChanged[BD_AID.Shield] = false
            h.shield.value = GetBuffsAtt(h.buffs, BD_AID.Shield)
        end
        return h.shield.value
    end,
    --当前生命
    HP = function(h) return h.dat.hp.value end,
    --当前技力
    SP = function(h) return h.dat.sp.value end,
    --当前兵力
    TP = function(h) return h.dat.tp.value end,
    --真实兵力
    RealTP = function(h)
        if h.realTP < 0 then
            h.realTP = h.map:SearchUnitCount(h.isAtk, BD_Soldier)
        end
        return h.realTP
    end,
    --暴击几率(万分比)
    Crit = function(h)
        if h.attChanged[BD_AID.Crit] then
            h.attChanged[BD_AID.Crit] = false
            h.crit.value = B_Math.max(BD_Const.BASE_CRIT + (h.bonus[8].value + GetBuffsAtt(h.buffs, BD_AID.Crit)) * 100, 0)
        end
        return h.crit.value
    end,
    --技能暴击几率(万分比)
    SCrit = function(h)
        if h.attChanged[BD_AID.SCrit] then
            h.attChanged[BD_AID.SCrit] = false
            local val = GetBuffsAtt(h.buffs, BD_AID.SCrit)
            if val > 0 then
                h.scrit.value = (val + B_Math.clamp(h.bonus[9].value, 0, h.lmtScrit.value)) * 100
            else
                h.scrit.value = B_Math.clamp(val + h.bonus[9].value, 0, h.lmtScrit.value) * 100
            end
        end
        return h.scrit.value
    end,
    --暴击伤害
    CritDmg = function(h)
        if h.attChanged[BD_AID.CritDmg] then
            h.attChanged[BD_AID.CritDmg] = false
            h.critDmg.value = B_Math.max(BD_Const.BASE_CRIT_DMG + h.bonus[10].value + GetBuffsAtt(h.buffs, BD_AID.CritDmg), 0)
        end
        return h.critDmg.value
    end,
    --当前准确度(万分比)
    Acc = function(h)
        if GetBuffsAtt(h.buffs, BD_AID.Blind) > 0 then return 0 end
        if h.attChanged[BD_AID.Acc] then
            h.attChanged[BD_AID.Acc] = false
            h.acc.value = B_Math.max(BD_Const.BASE_ACC + (h.bonus[11].value + GetBuffsAtt(h.buffs, BD_AID.Acc)) * 100, 0)
        end
        return h.acc.value
    end,
    --当前闪避(万分比)
    Dodge = function(h)
        if h.attChanged[BD_AID.Dodge] then
            h.attChanged[BD_AID.Dodge] = false
            local val = GetBuffsAtt(h.buffs, BD_AID.Dodge)
            if val > 0 then
                h.dodge.value = (val + B_Math.min(h.bonus[12].value, h.lmtDodge.value)) * 100
            else
                h.dodge.value = B_Math.min(val + h.bonus[12].value, h.lmtDodge.value) * 100
            end
        end
        return h.dodge.value
    end,
    --技能闪避(万分比)
    SDodge = function(h)
        if h.attChanged[BD_AID.SDodge] then
            h.attChanged[BD_AID.SDodge] = false
            local val = GetBuffsAtt(h.buffs, BD_AID.SDodge)
            if val > 0 then
                h.sdodge.value = (val + B_Math.min(h.bonus[13].value, h.lmtSDodge.value)) * 100
            else
                h.sdodge.value = B_Math.min(val + h.bonus[13].value, h.lmtSDodge.value) * 100
            end
        end
        return h.sdodge.value
    end,
    --移动速度 u/s
    MoveSpeed = function(h)
        if GetBuffsAtt(h.buffs, BD_AID.Fixed) > 0 then return 0 end
        if h.attChanged[BD_AID.MoveSpeed] then
            h.attChanged[BD_AID.MoveSpeed] = false
            h.movespeed = B_Math.clamp(BD_Const.BASE_MOVE_SPEED_UNIT + BD_Const.BASE_MOVE_SPEED_UNIT * (h.bonus[14].value + GetBuffsAtt(h.buffs, BD_AID.MoveSpeed)) * 0.01, 0, h.battle.lmtMS.value)
        end
        return h.movespeed
    end,
    --当前攻击间隔 毫秒/次
    MSPA = function(h)
        if h.attChanged[BD_AID.MSPA] then
            h.attChanged[BD_AID.MSPA] = false
            h.mspa.value = B_Math.max(B_Math.ceil(B_Math.max(BD_Const.BASE_MSPA * (1 / (1 + (h.bonus[15].value + GetBuffsAtt(h.buffs, BD_AID.MSPA)) * 0.01)), 100)), h.battle.lmtMSPA.value)
        end
        return h.mspa.value
    end,
    --每次攻击造成的普通伤害(最终值)
    Dmg = function(h)
        local dmg = h.dmg.value
        if dmg < 0 then
            dmg = h.Str * h.battle.fStr.value * 0.01
            dmg = B_Math.max(B_Math.ceil(dmg + dmg * h.CPD * 0.01), 0)
            h.dmg.value = dmg
        end
        return dmg
    end,
    --造成武力伤害增减
    CPD = function(h)
        if h.attChanged[BD_AID.CPD] then
            h.attChanged[BD_AID.CPD] = false
            h.cpd.value = B_Math.max(h.bonus[16].value + GetBuffsAtt(h.buffs, BD_AID.CPD), -100)
        end
        return h.cpd.value
    end,
    --造成武力伤害增减
    CSD = function(h)
        if h.attChanged[BD_AID.CSD] then
            h.attChanged[BD_AID.CSD] = false
            h.csd.value = B_Math.max(h.bonus[17].value + GetBuffsAtt(h.buffs, BD_AID.CSD), -100)
        end
        return h.csd.value
    end,
    --受到武力伤害增减
    SPD = function(h)
        if h.attChanged[BD_AID.SPD] then
            h.attChanged[BD_AID.SPD] = false
            local val = GetBuffsAtt(h.buffs, BD_AID.SPD)
            if val < 0 then
                val = val + B_Math.max(h.bonus[18].value, h.lmtSPD.value)
            else
                val = B_Math.max(val + h.bonus[18].value, h.lmtSPD.value)
            end
            if val < 0 then
                local ep = h.bonusExt[8].value
                if ep ~= 0 then
                    val = B_Math.floor(val * B_Math.clamp01(1 + ep * 0.01))
                end
            end
            h.spd.value = val < -100 and -100 or val
        end
        return h.spd.value
    end,
    --受到技能伤害增减
    SSD = function(h)
        if h.attChanged[BD_AID.SSD] then
            h.attChanged[BD_AID.SSD] = false
            local val = GetBuffsAtt(h.buffs, BD_AID.SSD)
            if val < 0 then
                val = val + B_Math.max(h.bonus[19].value, h.lmtSSD.value)
            else
                val = B_Math.max(val + h.bonus[19].value, h.lmtSSD.value)
            end
            if val < 0 then
                local ep = h.bonusExt[9].value
                if ep ~= 0 then
                    val = B_Math.floor(val * B_Math.clamp01(1 + ep * 0.01))
                end
            end
            h.ssd.value = val < -100 and -100 or val
        end
        return h.ssd.value
    end,

    BuffCount = function(h) return #h.buffs end,

    --是否无敌
    isGod = function(h) return GetBuffsAtt(h.buffs, BD_AID.God) > 0 end,
    --是否停止
    isStop = function(h) return GetBuffsAtt(h.buffs, BD_AID.Stop) > 0 end,
    --是否禁锢
    isFixed = function(h) return GetBuffsAtt(h.buffs, BD_AID.Fixed) > 0 end,
    --是否恐惧
    isFear = function(h) return GetBuffsAtt(h.buffs, BD_AID.Fear) > 0 end,
    --是否逼战
    isFF = function(h) return GetBuffsAtt(h.buffs, BD_AID.FF) > 0 end,
    --是否致盲
    isBlind = function(h) return GetBuffsAtt(h.buffs, BD_AID.Blind) > 0 end,
    --是否沉默
    isSilence = function(h) return GetBuffsAtt(h.buffs, BD_AID.Silence) > 0 end,

    DebugName = function(h) return h.isAtk and "[攻方武将]" or "[守方武将]" end,

    --当前军师技编号
    SktSN = function(h) return h.isAtk and h.battle.atkSktSn or h.battle.defSktSn end,
    --锦囊技SN
    SkpSN = function(h) return h.skp and h.skp[1] or 0 end,
    --锦囊技等级
    SkpLv = function(h) return h.skp and h.skp[2] or 0 end,
    --是否有阵形铭刻的属性
    hasLnpImp = function(h) return h.lnpImp and #h.lnpImp > 0 end,
}
--属性器-设置
local _set = 
{
    x = function(h, v) h._x.value = v end,
    y = function(h, v) h._y.value = v end,
}
--设置XY(重写)
function _hero.SetPos(h, x, y)
    if h.map.EnGetCombatUnit(x, y) == h then
        h.lastX, h.lastY = h._x.value, h._y.value
        if h.lastX ~= x then h._x.value = x end
        if h.lastY ~= y then h._y.value = y end
    end
end
--设置HP
--v : 值
--direct : 为true表示设为给定值，否则为增量值
local function SetHP(h, v, direct)
    if h.map.result == 0 then
        local dat = h.dat
        local cur = dat.hp.value
        v = direct and v or (v + cur)
        if v < cur then
            --护盾值抵消
            local shield = h.Shield
            if shield > 0 then
                v = v - cur
                for _, b in ipairs(h.buffs) do
                    v = b:ShieldChange(v)
                    if v >= 0 then return end
                end
                v = v + cur
            end
        end

        v = B_Math.clamp(v, 0, h.MaxHP)
        if cur == v then return end

        dat.hp.value = v
--        dat.hp.value = 100

        if v < cur then dat.statDmgS = dat.statDmgS + cur - v end

        h:AddEvent(BE_Type.HP, dat.hp.value)
        if dat.hp.value <= 0 then
            h.actionTime = 0
            h:Dead()
        end
    end
end
--[Comment]
--设置HP
--v : 值
--direct : 为true表示设为给定值，否则为增量值
_hero.SetHP = SetHP
--设置SP
--v : 值
--direct : 为true表示设为给定值，否则为增量值
local function SetSP(h, v, direct)
    local cur = h.dat.sp.value
    v = B_Math.clamp(direct and v or (v + cur), 0, h.MaxSP)
    if cur == v then return end
    h.dat.sp.value = v
--    h.dat.sp.value = 200
    h:AddEvent(BE_Type.SP, v)
end
--[Comment]
--设置SP
--v : 值
--direct : 为true表示设为给定值，否则为增量值
_hero.SetSP = SetSP
--设置TP
--v : 值
--direct : 为true表示设为给定值，否则为增量值
function _hero.SetTP(h, v, direct)
    if h.map.result == 0 then
        local cur = h.dat.tp.value
        v = direct and v or (v + cur)
        if cur == v then return end
        local realTP = h.map:SearchUnitCount(h.isAtk, BD_Soldier)
        v = math.max(v, realTP)
        v = math.min(v, h.MaxTP)
        h.dat.tp.value = v
        h.realTP = realTP
        h.infoChanged = true
        h:AddEvent(BE_Type.TP, realTP)
    end
end

--初始化数据
--dat : EnHero
--fdat : S_BattleHeroFight
--armRes : 兵种克制关系
--lnpRes : 阵形克制关系
function _hero.InitData(h, dat, fdat, armRes, lnpRes)
    local var
    local EnInt = h.map.battle.EnInt
    --基本武将数据
    h.dat = dat
    --配置默认名称
    h.name = "hb_" .. dat.dbsn.value
    --清理BUFF系统
    h.buffs:Clear()
    --转存技能数据
    h.skill = QYBattle.EnSkc.FromArray(fdat.skill, fdat.skcFe, EnInt)
    --重置技能时间
    h.skillTime = EnInt(0)
    --重置技能CD数据
    if h.skill then
        var = { }
        for i = 1, #h.skill, 1 do var[i] = EnInt(0) end
        h.cd = var
        h.skillQty = #var
    else
        h.cd = nil
        h.skillQty = 0
    end
    --性别
    h.sex = EnInt(fdat.sex)
    --AI
    dat:SetAI(fdat.ai)

    local bat = h.battle
    --极限值重写
    if h.isAtk or bat:isPvpFight() then
        h.lmtScrit = bat.lmtScrit
        h.lmtDodge = bat.lmtDodge
        h.lmtSDodge = bat.lmtSDodge
        h.lmtSPD = bat.lmtSPD
        h.lmtSSD = bat.lmtSSD
    else
        h.lmtScrit = EnInt(100)
        h.lmtDodge, h.lmtSDodge = EnInt(100), EnInt(100)
        h.lmtSPD, h.lmtSSD = EnInt(-100), EnInt(-100)
    end

    --锦囊技
    h.skp = fdat.skp
    --以逸待劳时间(MS)
    h.restTime = EnInt(0)
    --火烧连营伤害
    h.keepFireDmg = 0
    
    --兵种阵型克制
    h.armRes = armRes
    h.lnpRes = lnpRes
    --阵型铭刻
    h.lnpImp = QYBattle.BD_ExtAtt(fdat.lnpImp)

    --副将
    if h.dehero then
        h.dehero:Dead()
        h.dehero = nil
    end
    var = fdat.dehero
    if var and var.dbsn and var.dbsn > 0 then
        h.dehero = QYBattle.BD_Dehero(h, var)
    end

    --天机
    if h.sks then
        h.sks:Dead()
        h,sks = nil
    end
    var = fdat.sks
    if var and #var > 0 then h.sks = QYBattle.BD_SKS(h, var) end
    
    -----------------------初始增益-----------------------
    --军师技
    var = h.isAtk and bat.atkSkt or bat.defSkt
    --武将初始加成
    local bonus = { }
    --1=武力增减,2=智力增减,3=统帅增减,4=生命增减,5=技力增减,6=兵力增减,7=冷却时间增减,8=暴击,9=技能暴击,10=暴击伤害,11=命中,
    --12=闪避,13=技能闪避,14=移动速度,15=攻击速度,16=造成武力伤害增减,17=造成技能伤害增减,18=受到武力伤害增减,19=受到技能伤害增减
    h.bonus = bonus

    local sktTag = var[2].value
    if sktTag == 0 or sktTag == 1 then
        for i = 1, 19 do bonus[i] = var[i + 2].value end
    else
        for i = 1, 19 do bonus[i] = 0 end
    end

    --兵种初始属性
    h.soldierAtt = fdat.armAtt and #fdat.armAtt >= 5 and fdat.armAtt or BD_Const.ArmAttLv1
    --兵种初始加成
    local soldierBonus = { }
    --1=武力增减,2=生命增减,3=暴击,4=暴击伤害,5=命中,6=闪避,7=技能闪避,8=移动速度,9=攻击速度,10=造成武力伤害增减,11=受到武力伤害增减,12=受到技能伤害增减
    h.soldierBonus = soldierBonus
    if sktTag == 0 or sktTag == 2 then
        soldierBonus[1] = var[3] and var[3].value or 0
        soldierBonus[2] = var[6] and var[6].value or 0
        soldierBonus[3] = var[10] and var[10].value or 0
        soldierBonus[4] = var[12] and var[12].value or 0
        soldierBonus[5] = var[13] and var[13].value or 0
        soldierBonus[6] = var[14] and var[14].value or 0
        soldierBonus[7] = var[15] and var[15].value or 0
        soldierBonus[8] = var[16] and var[16].value or 0
        soldierBonus[9] = var[17] and var[17].value or 0
        soldierBonus[10] = var[18] and var[18].value or 0
        soldierBonus[11] = var[20] and var[20].value or 0
        soldierBonus[12] = var[20] and var[21].value or 0
    else
        for i = 1, 12 do soldierBonus[i] = 0 end
    end

    --阵形克制
    if lnpRes then
        var = bat.fLnpRes.value
        bonus[1] = bonus[1] - var
        bonus[2] = bonus[2] - var
        bonus[3] = bonus[3] - var
        bonus[4] = bonus[4] - var
    end
    --兵种克制
    if armRes then
        var = bat.fArmRes.value
        soldierBonus[1] = soldierBonus[1] - var
        soldierBonus[2] = soldierBonus[2] - var
        soldierBonus[5] = soldierBonus[5] - var
    end

    -----------------------武将增益-----------------------
    --取得全属性增加值
    var = GetExtAtt(h, BD_ANM.HeroAll)
    --装备扩展 阵形铭刻 名将谱 科技 道具
    --武力百分比
    bonus[1] = bonus[1] + GetExtAtt(h, BD_ANM.StrP) + var
    --智力百分比
    bonus[2] = bonus[2] + GetExtAtt(h, BD_ANM.WisP) + var
    --统帅百分比
    bonus[3] = bonus[3] + GetExtAtt(h, BD_ANM.CapP) + var
    --统帅百分比
    bonus[4] = bonus[4] + GetExtAtt(h, BD_ANM.HPP) + var
    --技力百分比
    --bonus[5]
    --兵力百分比
    --bonus[6]
    --冷却缩短百分比
    bonus[7] = bonus[7] + GetExtAtt(h, BD_ANM.CD)
    --暴击
    bonus[8] = bonus[8] + GetExtAtt(h, BD_ANM.Crit)
    --技能暴击
    bonus[9] = bonus[9] + GetExtAtt(h, BD_ANM.SCrit)
    --暴击伤害
    bonus[10] = bonus[10] + GetExtAtt(h, BD_ANM.CritDmg)
    --命中
    bonus[11] = bonus[11] + GetExtAtt(h, BD_ANM.Acc)
    --闪避
    bonus[12] = bonus[12] + GetExtAtt(h, BD_ANM.Dodge)
    --技能闪避
    bonus[13] = bonus[13] + GetExtAtt(h, BD_ANM.SDodge)
    --移动速度百分比
    bonus[14] = bonus[14] + GetExtAtt(h, BD_ANM.MoveSpeed)
    --攻击速度百分比
    bonus[15] = bonus[15] + GetExtAtt(h, BD_ANM.AtkSpeed)
    --武力伤害百分比
    bonus[16] = bonus[16] + GetExtAtt(h, BD_ANM.CPD)
    --技能伤害百分比
    bonus[17] = bonus[17] + GetExtAtt(h, BD_ANM.CSD)
    --物防百分比
    bonus[18] = bonus[18] - GetExtAtt(h, BD_ANM.SPR)
    --技防百分比
    bonus[19] = bonus[19] - GetExtAtt(h, BD_ANM.SSR)

    --扩展增益
    var = { }
    --武力常量
    var[1] = EnInt(GetExtAtt(h, BD_ANM.Str))
    --智力常量
    var[2] = EnInt(GetExtAtt(h, BD_ANM.Wis))
    --统帅常量
    var[3] = EnInt(GetExtAtt(h, BD_ANM.Cap))
    --受到武将武力伤害
    var[4] = EnInt(-GetExtAtt(h, BD_ANM.SHPR))
    --受到士兵武力伤害
    var[5] = EnInt(-GetExtAtt(h, BD_ANM.SSPR))
    --其它
    for i = 6, 9 do var[i] = EnInt(0) end
    --1=武力常量增减 2=智力常量增减 3=统帅常量增减 4=受到武将武力伤害增减 5=受到士兵武力伤害增减 6=受到士兵武力伤害增加(常量) 7=对眩晕目标伤害增减 8=武防效果增减 9=技防效果增减
    h.bonusExt = var

    -----------------------士兵增益-----------------------
    --士气
    var = GetExtAtt(h, BD_ANM.SoA)
    soldierBonus[1] = soldierBonus[1] + var
    soldierBonus[2] = soldierBonus[2] + var
    soldierBonus[3] = soldierBonus[3] + GetExtAtt(h, BD_ANM.SoCrit)
    soldierBonus[4] = soldierBonus[4] + GetExtAtt(h, BD_ANM.SoCritDmg)
    soldierBonus[5] = soldierBonus[5] + GetExtAtt(h, BD_ANM.SoAcc)
    soldierBonus[6] = soldierBonus[6] + GetExtAtt(h, BD_ANM.SoDodge)
    soldierBonus[7] = soldierBonus[7] + GetExtAtt(h, BD_ANM.SoSDodge)
    soldierBonus[8] = soldierBonus[8] + GetExtAtt(h, BD_ANM.SoMoveSpeed)
    soldierBonus[9] = soldierBonus[9] + GetExtAtt(h, BD_ANM.SoAtkSpeed)
    --soldierBonus[10]
    soldierBonus[11] = soldierBonus[11] - GetExtAtt(h, BD_ANM.SoSPR)
    soldierBonus[12] = soldierBonus[12] - GetExtAtt(h, BD_ANM.SoSSR)

    -----------------------全军增益-----------------------
    var = GetExtAtt(h, BD_ANM.QAtkSpeed)
    if var ~= 0 then
        bonus[15] = bonus[15] + var
        soldierBonus[9] = soldierBonus[9] + var
    end
    var = GetExtAtt(h, BD_ANM.QSPR)
    if var ~= 0 then
        bonus[18] = bonus[18] - var
        soldierBonus[11] = soldierBonus[11] - var
    end
    var = GetExtAtt(h, BD_ANM.QSSR)
    if var ~= 0 then
        bonus[19] = bonus[19] - var
        soldierBonus[12] = soldierBonus[12] - var
    end
    
    --加密武将增益
    for i = 1, #bonus, 1 do bonus[i] = EnInt(bonus[i]) end
end
--初始化开始数据
function _hero.InitStartData(h)
    local rival = h.rival
    --计谋作用
    local var = h.isAtk and h.battle.atkProps or h.battle.defProps
    if var then
        for _, p in ipairs(var) do
            if p.sn == BD_Const.B_GuanMenZhuoZei then
                --关门捉贼
                rival.dat.sp.value = 0
            elseif p.sn == BD_Const.B_MeiRenJi then
                --美人计
                if p.extra and rival.sex.value == 1 then
                    p = tonumber(p.extra) or 0
                    --武力伤害百分比
                    rival.bonus[16].value = rival.bonus[16].value + p
                    --技能伤害百分比
                    rival.bonus[17].value = rival.bonus[17].value + p
                end
            end
        end
    end

    --锦囊技作用
    var = h.skp
    if var and #var > 2 then
        local sn = var[1]
        if sn == 1 then
            --以逸待劳
            h.restTime.value = var[3] * 1000
        elseif sn == 2 then
            --疑兵之计
            rival.soldierBonus[5] = rival.soldierBonus[5] - var[3]
        elseif sn == 3 then
            --火烧连营
            h.keepFireDmg = var[3]
        elseif sn == 4 then
            --借东风
            rival.bonus[14].value = rival.bonus[14].value - var[3]
            rival.soldierBonus[8] = rival.soldierBonus[8] - var[3]
        elseif sn == 5 then
            --镜花水月
            rival.bonus[19].value = rival.bonus[19].value + var[3]
            rival.soldierBonus[12] = rival.soldierBonus[12] + var[3]
        elseif sn == 6 then
            --乘风破浪
            rival.bonus[18].value = rival.bonus[18].value + var[3]
            rival.soldierBonus[11] = rival.soldierBonus[11] + var[3]
        elseif sn == 7 then
            --全神贯注
            rival.bonus[13].value = rival.bonus[13].value - var[3]
        elseif sn == 8 then
            --一力降十会
            rival.bonus[12].value = rival.bonus[12].value - var[3]
        end
    end

    --敌将减益
    var = rival.bonus
    var[1].value = var[1].value - GetExtAtt(h, BD_ANM._StrP)
    var[2].value = var[2].value - GetExtAtt(h, BD_ANM._WisP)
    var[3].value = var[3].value - GetExtAtt(h, BD_ANM._CapP)
    var[4].value = var[4].value - GetExtAtt(h, BD_ANM._HPP)
    var[5].value = var[5].value - GetExtAtt(h, BD_ANM._SPP)
    var[6].value = var[6].value - GetExtAtt(h, BD_ANM._TPP)
    var[7].value = var[7].value - GetExtAtt(h, BD_ANM._CD)
    var[13].value = var[13].value - GetExtAtt(h, BD_ANM._SDodge)

    var = rival.bonusExt
    var[1].value = var[1].value - GetExtAtt(h, BD_ANM._Str)
    var[2].value = var[2].value - GetExtAtt(h, BD_ANM._Wis)
    var[3].value = var[3].value - GetExtAtt(h, BD_ANM._Cap)
    var[8].value = var[8].value - GetExtAtt(h, BD_ANM._SPRP)
    var[9].value = var[9].value - GetExtAtt(h, BD_ANM._SSRP)

    --敌兵减益

    --敌方全军减益
    var = GetExtAtt(h, BD_ANM._QMoveSpeed)
    if var ~= 0 then
        rival.bonus[14].value = rival.bonus[14].value - var
        rival.soldierBonus[8] = rival.soldierBonus[8] - var
    end
end
--初始化属性
function _hero.InitAttrib(h)
    local dat = h.dat
    local bonus = h.bonus
    if h.isAtk or h.battle.type ~= 13 then
        local v = dat.hp.value
        dat.hp.value = B_Math.max(B_Math.ceil(v + v * bonus[4].value * 0.01), 1)
        v = dat.sp.value
        dat.sp.value = B_Math.max(B_Math.ceil(v + v * bonus[5].value * 0.01), 0)
        v = dat.tp.value
        dat.tp.value = B_Math.max(B_Math.ceil(v + v * bonus[6].value * 0.01), 0)
    else
        local v = dat.max_hp.value
        dat.hp.value = B_Math.max(B_Math.ceil(v + v * bonus[4].value * 0.01), 1)
        v = dat.max_sp.value
        dat.sp.value = B_Math.max(B_Math.ceil(v + v * bonus[5].value * 0.01), 0)
        v = dat.max_tp.value
        dat.tp.value = B_Math.max(B_Math.ceil(v + v * bonus[6].value * 0.01), 0)
    end

    --计谋-偷梁换柱
    if dat.sp.value <= 0 then
        local pe = h.isAtk and h.battle.atkProps or h.battle.defProps
        if pe then
            for _, p in ipairs(pe) do
                if BD_Const.B_TouLiangHuanZhu == p.sn then
                    p = QYBattle.B_Util.split(p.extra, ",")
                    if p and #p > 1 then
                        dat.hp.value = B_Math.max(B_Math.ceil(dat.hp.value * (1 - tonumber(p[1]) * 0.01)), 1)
                        dat.sp.value = B_Math.max(B_Math.ceil(dat.max_sp.value * (1 + bonus[5].value * 0.01) * tonumber(p[2]) * 0.01), 0)
                    end
                    break
                end
            end
        end
    end

    --初始化属性
    ResetAttrib(h)

    if isDebug then
        print(string.format("%s方武将属性:\n武力:%d 智力:%d 忠诚:%d\nHP:%d/%d\nSP:%d/%d\nTP:%d/%d\n怒气恢复:%d(点/秒)\n移动速度:%.4f(像素/秒)\n攻击速度:%d(毫秒/次)\n准确:%.2f%%\n闪避:%.2f%%\nCPD:%d%% CSD:%d%% SPD:%d%% SSD:%d%%",
            h.isAtk and "攻" or "守", h.Str, h.Wis, h.dat.loyalty.value, h.HP, h.MaxHP, h.SP, h.MaxSP, h.TP, h.MaxTP, 0, h.MoveSpeed, h.MSPA, h.Acc * 0.01, h.Dodge * 0.0001, h.CPD, h.CSD, h.SPD, h.SSD))
    end
end
--循环
function _hero.OnEndUpdate(h)
    local map = h.map
    if map.frameCount == 0 then
        --初始触发
        local d, rd = h.dehero, h.rival.dehero
        local hp, sp, tp = h.HP, h.SP, h.RealTP
        if d or rd then
            if hp < h.MaxHP then
                if d then d:Trigger(true, BE_Type.HP, hp) end
                if rd then rd:Trigger(true, BE_Type.HP, hp) end
            end
            if sp < h.MaxSP then
                if d then d:Trigger(true, BE_Type.SP, sp) end
                if rd then rd:Trigger(true, BE_Type.SP, sp) end
            end
            if h.TP < h.MaxTP then
                if d then d:Trigger(true, BE_Type.TP, tp) end
                if rd then rd:Trigger(true, BE_Type.TP, tp) end
            end
        end
        d = h.sks
        if d then
            d:Trigger(true, BE_Type.HP, hp)
            d:Trigger(true, BE_Type.SP, sp)
            d:Trigger(true, BE_Type.TP, tp)
        end
        rd = h.rival.sks
        if rd then
            rd:Trigger(true, BE_Type.HP, hp)
            rd:Trigger(true, BE_Type.SP, sp)
            rd:Trigger(true, BE_Type.TP, tp)
        end
        for e, _ in pairs(h.onEvent) do
            e(h, BE_Type.HP, hp)
            e(h, BE_Type.SP, sp)
            e(h, BE_Type.TP, tp)
        end
    end

    h.skillTime.value = h.skillTime.value + map.deltaMillisecond

    BuffsUpdate(h.buffs)

    if h.keepFireDmg > 0 and map.isSecondFrame then
        local tm = map.time
        for _, u in pairs(map.combatUnits) do
            if CheckEnemy(h, u) and tm - u.lastMoveTime > 800 then
                u:SufferDPS(BD_DPS(h, BD_DPS_TYPE.Skill, h.keepFireDmg, BD_DPS_TAG.Buff))
            end
        end
    end

    if h.castIdx > 0 and GetBuffsAtt(h.buffs, BD_AID.Stop) <= 0 and h.isAlive then
        local sk = QYBattle.BD_SKC(h, h.castIdx)
        h.dat.skillRec = bit.bor(h.dat.skillRec, bit.lshift(1, h.castIdx - 1))
        h.castIdx = 0
        h.status = STATUS.Skill
        h:AddEvent(BE_Type.CastSkill, sk)
    end
end
--重写添加事件
function _hero.AddEvent(h, typ, dat)
    local d = h.dehero
    if d then d:Trigger(true, typ, dat) end
    d = h.rival.dehero
    if d then d:Trigger(false, typ, dat) end
    d = h.sks
    if d then d:Trigger(true, typ, dat) end
    d = h.rival.sks
    if d then d:Trigger(false, typ, dat) end
    for e, _ in pairs(h.onEvent) do e(h, typ, dat) end
    _base.AddEvent(h, typ, dat)
end
--获取指定索引技能的CD
--idx : 技能索引
local function GetCD(h, idx)
    if h.cd then
        if h.attChanged[BD_AID.CD] then
            h.attChanged[BD_AID.CD] = false
            local skc = h.skill
            local ip = h.Wis / h.battle.fCD.value
            local lmt = h.battle.lmtCD.value
            local b = 100 - (h.bonus[7].value + GetBuffsAtt(h.buffs, BD_AID.CD))
            local v
            for i, t in ipairs(h.cd) do
                i = skc[i]
                v = B_Math.max(lmt, b / (ip + i.cd.value))
                --五行-火 减破极限，可达至物理极限1秒
                if i.fesn == BD_Const.FE_FIRE then
                    v = B_Math.max(2, v * (1 - i.feval * 0.01))
                end
                t.value = B_Math.round(v * 1000)
            end
        end
        idx = h.cd[idx]
        return idx and idx.value or BD_Const.MAX_TIME
    end
    return BD_Const.MAX_TIME
end
--[Comment]
--获取指定索引技能的CD
--idx : 技能索引
_hero.GetCD = GetCD
--技能数据获取
--idx : 技能索引
function _hero.GetSkill(h, idx) return h.skill[idx] end
--获取给定技能索引的CD
--idx : 技能索引
function _hero.GetSkillCDPercent(h, idx) return h.skillTime.value / GetCD(h, idx) end
--给定技能索引的技能是否冷却完成
--idx : 技能索引
function _hero.SkillCDReady(h, idx) return h.skillTime.value >= GetCD(h, idx) end
--重置所有技能CD，用于释放技能后
function _hero.ResetSkillCD(h) h.skillTime.value = 0 end
--减伤CD time ms
--time : 减少CD的毫秒数
function _hero.ReduceCD(h, time) h.skillTime.value = h.skillTime.value + time end
--给定技能索引的技能是否可用
--idx : 技能索引
function _hero.SkillIsAvailable(h, idx) idx = h.skill[idx]; return idx and idx.sp.value <= h.SP end
--释放一个技能
--idx : 技能索引
function _hero.CastSkill(h, idx)
    if h.skill and h.skill[idx]
    and GetBuffsAtt(h.buffs, BD_AID.Stop) <= 0 and GetBuffsAtt(h.buffs, BD_AID.Silence) <= 0
    and h.skill[idx].sp.value <= h.SP and h.skillTime.value >= GetCD(h, idx) then
        h.castIdx = idx
        return true
    end
    return false
end

--增加一个BUFF 1000号BUF为眩晕
--buf : BD_Buff
--returns : BD_BuffSlot
function _hero.AddBuff(h, buf)
    local slot = h.buffs:AddBuff(buf)
    buf = buf.att
    if (buf[BD_AID.Stop] or 0) > 0 or (buf[BD_AID.Fixed] or 0) > 0 then
        h.status = STATUS.Think
        local a = h.Arrived
        if a < 0.5 and (a > 0.25 or h.map:GetArrivedUnit(h.lastX, h.lastY) ~= h or not h.map:PlaceCombatUnit(h, h.lastX, h.lastY)) then
            a = h.x
            local pos = h.pos
            if B_Math.abs(a - pos.x) > 0.5 then
                pos.x = pos.x + (pos.x > a and -0.5 or 0.5)
            end
            a = h.y
            if B_Math.abs(a - pos.y) > 0.5 then
                pos.y = pos.y + (pos.y > a and -0.5 or 0.5)
            end
        end
    end
    return slot
end
--重置BUF
--sn : buf sn
function _hero.ResetBuff(h, sn) return h.buffs:ResetBuff(sn) end
--移除指定编号的BUFF
--sn : buf sn
function _hero.RemoveBuff(h, sn) h.buffs:Remove(sn) end
--移除所有BUFF
function _hero.RemoveAllBuff(h, sn) h.buffs:Clear(); ResetAttrib(h) end
--获取指定SN的buf，若没有则为null
--sn : buf sn
function _hero.GetBuff(h, sn) return h.buffs:GetBuff(sn) end
--获取指定索引的buf，若没有则为null
--idx : 索引
function _hero.GetBuffByIdx(h, idx) return h.buffs:GetBuffByIdx(idx) end
--单位是否包含给定编号的BUF
--sn : buf sn
function _hero.ContainsBuff(h, sn) return h.buffs:Contains(sn) end
--获取BUF加成值
--aid : 属性ID
function _hero.GetBuffAtt(h, aid) return GetBuffsAtt(h.buffs, aid) end

function _hero.MarkAttChanged(h, aid)
    h.attChanged[aid] = true
    if isDebug then h.infoChanged = true end

    if aid == BD_AID.Wis then
        h.attChanged[BD_AID.CD], h.infoChanged = true, true
    elseif aid == BD_AID.Str then
        h.dmg.value, h.infoChanged = -1, true
    elseif aid == BD_AID.Cap then
        h.infoChanged = true
    elseif aid == BD_AID.CPD then
        h.dmg.value = -1
    elseif aid == BD_AID.HP then
        CheckMaxHP(h)
        h.infoChanged = true
    elseif aid == BD_AID.SP then
        CheckMaxSP(h)
        h.infoChanged = true
    elseif aid == BD_AID.Morale then
        local isAtk = h.isAtk
        local func = BD_Soldier.MarkAttChanged
        for _, u in pairs(h.map.combatUnits) do
            if u.isAtk == isAtk and getmetatable(u) == BD_Soldier then
                func(u, BD_AID.Str)
                func(u, BD_AID.Wis)
            end
        end
    elseif aid == BD_AID.Shield then
        h.infoChanged = true
    end
end

function _hero.OnCreateDps(h, target, dps)
    if dps.type == BD_DPS_TYPE.Strength or dps.type == BD_DPS_TYPE.Skill then
        local v = h.bonusExt[7].value
        if v ~= 0 and target.isStop then
            dps.value = B_Math.ceil(dps.value * (1 + v * 0.01))
        end
    end
end

function _hero.OnCreatedDps(h, target, dps)
    if dps.type == BD_DPS_TYPE.Strength then
        local v = h.dat:GetExtAtt(BD_ANM.Bleed)
        if v > 0 and 30 > h.map.random:NextInt(0, 100) then
            if h.bf_bleed == nil then
                h.bf_bleed = BD_Buff.BD_BuffSingle(BD_Buff.SN_Bleed, 5000, BD_AID.Dmg, v)
            elseif h.bf_bleed:GetAtt(BD_AID.Dmg) ~= v then
                h.bf_bleed:SetAtt(BD_AID.Dmg, v)
            end
            target:AddEvent(BE_Type.BuffAdd, target:AddBuff(h.bf_bleed))
        end

        v = h.dat:GetExtAtt(BD_ANM.Stun)
        if v > 0 then
            v = B_Math.min(v, h.battle.lmtStun.value)
            if v > h.map.random:NextInt(0, 100) then
                target:AddEvent(BE_Type.BuffAdd, target:AddBuff(BD_Buff.BF_1SStop))
            end
        end
    elseif dps.type == BD_DPS_TYPE.Skill then
        local v = h.dat:GetExtAtt(BD_ANM.SStun)
        if v > 0 and v > h.map.random:NextInt(0, 100) then
            target:AddEvent(BE_Type.BuffAdd, target:AddBuff(BD_Buff.BF_1SStop))
        end

        if dps.isCrit then h.lastSCritTime = h.map.time end
    end
end

function _hero.SufferEnergy(h, v)
    SetSP(h, v)
    h:AddEvent(BE_Type.Energy, v)
end
--获取最终受到武力伤害增减
local function GetFinalDps(h, dps)
    local spd = h.SPD
    local typ = getmetatable(dps.source)
    if typ == _hero then spd = spd + h.bonusExt[4].value
    elseif typ == BD_Soldier then spd = spd + h.bonusExt[5].value end
    if spd < h.lmtSPD.value then spd = h.lmtSPD.value end
    return B_Math.ceil(dps.value * (1 + spd * 0.01)) + (typ == BD_Soldier and h.bonusExt[6].value or 0)
end
--挡格伤害检测
local function CheckBlockDmg(h, dps)
    if dps:CheckType(BD_DPS_TYPE.Cure) or dps:ContainsAnyTag(BD_DPS_TAG.Miss, BD_DPS_TAG.Dodge, BD_DPS_TAG.Buff) then return end
    local dg = GetExtAtt(h, BD_ANM.DG)
    if dg > 0 and 30 > h.map.random:NextInt(0, 100) then
        dps.value = B_Math.max(0, dps.value - dg)
        dps:AddTag(BD_DPS_TAG.Block)
    end
end
--反伤检测
local function CheckDpsBack(h, dps)
    if h.isDead then return end
    if dps.value > 0 and (dps.type == BD_DPS_TYPE.Strength or dps.type == BD_DPS_TYPE.Skill) then
        --伤害反弹
        local v = GetBuffsAtt(h.buffs, BD_AID.DmgRef)
        if v > 0 then
            h:RealDPS(dps.source, B_Math.ceil(dps.value * v * 0.01))
        end
        --伤害反噬
        if dps.source == h.rival then
            v = GetBuffsAtt(h.rival.buffs, BD_AID.DmgBack)
            if v > 0 then
                h:RealDPS(dps.source, B_Math.ceil(dps.value * v * 0.01))
            end
        end
    end
end
function _hero.SufferDPS(h, dps)
    if dps.source == nil or h.map.result ~= 0 then return false end
    if dps.type == BD_DPS_TYPE.Strength then
        --有无敌状态则不受伤害
        if dps.source.isAtk == h.isAtk or GetBuffsAtt(h.buffs, BD_AID.God) > 0 then return false end
        if dps.isMiss then
            --未命中
            h:AddEvent(BE_Type.DPS, dps)
            h.map:Log(dps.source.DebugName .. "攻击" .. h.DebugName .. " <未命中>")
            return false
        elseif dps.dodge and h.Dodge > h.map.random:NextInt(0, 10000) then
            --闪
            h:AddEvent(BE_Type.DPS, dps)
            h.map:Log(dps.source.DebugName .. "攻击" .. h.DebugName .. " <闪避>")
            return false
        else
            dps:RemoveTag(BD_DPS_TAG.Dodge)
            dps.value = B_Math.max(1, GetFinalDps(h, dps))
            CheckBlockDmg(h, dps)
            if dps.value > 0 then SetHP(h, -dps.value) end
            CheckDpsBack(h, dps)
            h:AddEvent(BE_Type.DPS, dps)
            h.map:Log(dps.source.DebugName .. "攻击" .. h.DebugName .. "造成<" .. dps.value .. ">点" .. (dps.isCrit and "<暴击>伤害" or "伤害"))
            return true
        end
    elseif dps.type == BD_DPS_TYPE.Skill then
        --有无敌状态则不受伤害
        if dps.source.isAtk == h.isAtk or GetBuffsAtt(h.buffs, BD_AID.God) > 0 then return false end
        --新手教程需求
        if h.battle.type == 1 and not h.isAtk and h.battle.sn == 2 then
            --第二城秒杀敌将
            SetHP(h, 0)
            return true
        end
        if dps.dodge and h.SDodge > h.map.random:NextInt(0, 10000) then
            --闪
            h:AddEvent(BE_Type.DPS, dps)
            h.map:Log(h.DebugName .. " <技能闪避>")
            return false
        else
            dps:RemoveTag(BD_DPS_TAG.Dodge)
            if dps.value > 0 then
                dps.value = B_Math.max(1, B_Math.ceil(dps.value * (1 + h.SSD * 0.01) + (dps.puncture > 0 and dps.puncture or 0)))
                CheckBlockDmg(h, dps)
                if dps.value > 0 then SetHP(h, -dps.value) end
                CheckDpsBack(h, dps)
                h:AddEvent(BE_Type.DPS, dps)
                h.map:Log(h.DebugName .. "受到<" .. dps.value .. ">点技能" .. (dps.isCrit and "<暴击>伤害" or "伤害"))
            end
            return true
        end
    elseif dps.type == BD_DPS_TYPE.Cure then
        SetHP(h, B_Math.max(0, dps.value))
        h:AddEvent(BE_Type.DPS, dps)
        return true
    elseif dps.type == BD_DPS_TYPE.Real then
        --h:AddEvent(BE_Type.DPS, dps)
        if dps.source.isAtk == h.isAtk or dps.value < 1 or GetBuffsAtt(h.buffs, BD_AID.God) > 0 then return false end
        SetHP(h, -dps.value)
        h:AddEvent(BE_Type.DPS, dps)
        h.map:Log(h.DebugName .. "受到<" .. dps.value .. ">点真实伤害")
        return true
    end
end

--改变基本加成值
--idx : 1=武力增减,2=智力增减,3=统帅增减,4=生命增减,5=技力增减,6=兵力增减,7=冷却时间增减,8=暴击,9=技能暴击,10=暴击伤害,11=命中,
--12=闪避,13=技能闪避,14=移动速度,15=攻击速度 16=造成武力伤害增减,17=造成技能伤害增减,18=受到武力伤害增减,19=受到技能伤害增减
function _hero.AddBonus(h, idx, v)
    if v == nil or v == 0 or idx < 1 or idx == 6 or idx > 19 then return end
    h.bonus[idx].value = h.bonus[idx].value + v
    if idx == 1 then h:MarkAttChanged(BD_AID.Str)
    elseif idx == 2 then h:MarkAttChanged(BD_AID.Wis)
    elseif idx == 3 then h:MarkAttChanged(BD_AID.Cap)
    elseif idx == 4 then h:MarkAttChanged(BD_AID.HP)
    elseif idx == 5 then h:MarkAttChanged(BD_AID.SP)
    elseif idx == 7 then h:MarkAttChanged(BD_AID.CD)
    elseif idx == 8 then h:MarkAttChanged(BD_AID.Crit)
    elseif idx == 9 then h:MarkAttChanged(BD_AID.SCrit)
    elseif idx == 10 then h:MarkAttChanged(BD_AID.CritDmg)
    elseif idx == 11 then h:MarkAttChanged(BD_AID.Acc)
    elseif idx == 12 then h:MarkAttChanged(BD_AID.Dodge)
    elseif idx == 13 then h:MarkAttChanged(BD_AID.SDodge)
    elseif idx == 14 then h:MarkAttChanged(BD_AID.MoveSpeed)
    elseif idx == 15 then h:MarkAttChanged(BD_AID.MSPA)
    elseif idx == 16 then h:MarkAttChanged(BD_AID.CPD)
    elseif idx == 17 then h:MarkAttChanged(BD_AID.CSD)
    elseif idx == 18 then h:MarkAttChanged(BD_AID.SPD)
    elseif idx == 19 then h:MarkAttChanged(BD_AID.SSD)
    end
end
--改变扩展加成值
--idx : 1=武力常量增减 2=智力常量增减 3=统帅常量增减 4=受到武将武力伤害增减 5=受到士兵武力伤害增减 6=受到士兵武力伤害增加(常量) 7=对眩晕目标伤害增减 8=武防效果增减 9=技防效果增减
function _hero.AddExtBonus(h, idx, v)
    if v == nil or v == 0 or idx < 1 or idx > #h.bonusExt then return end

    h.bonusExt[idx].value = h.bonusExt[idx].value + v

    if idx == 1 then h:MarkAttChanged(BD_AID.Str)
    elseif idx == 2 then h:MarkAttChanged(BD_AID.Wis)
    elseif idx == 3 then h:MarkAttChanged(BD_AID.Cap)
    elseif idx == 8 then h:MarkAttChanged(BD_AID.SPD)
    elseif idx == 9 then h:MarkAttChanged(BD_AID.SSD)
    end
end
--在给定战场时间之后是否技能暴击过
--t : 某一战场时间(MS)
function _hero.IsSCritAfterTime(h, t) return h.lastSCritTime > t end

--endregion

--region 行为部分
function _hero.OnDead(h)
    h.actionTime = 0
    h.status = STATUS.Dead
    h:AddEvent(BE_Type.HeroDead, h)
    if h.dehero then h.dehero:Dead() end
end
--思考武将下一步是处于攻击状态、移动状态、等待状态这个三种状态的哪一种
local function ThinkHeroAction(h)
    --攻击前方的敌人
    local target = h:GetMeleeEnemy(h.direction)
    if target then
        h.status = STATUS.Attack
        return
    end
    --新手需求
    if h.battle.type == 1 and h.battle.sn == 3 and not h.isAtk then
        --若无法前进，则攻击后面的敌人
        target = h:GetMeleeEnemy(-h.direction)
        if target then
            h.status = STATUS.Attack
            return
        end
        if h.AroundEnemy then
            h.status = STATUS.Think
            return
        end
    end

    --前方无敌人，则向前方移动
    if h.map:PlaceCombatUnit(h, h.x + h.direction, h.y) then
        h.status = STATUS.Move
        return
    end

    --若无法前进，则攻击后面的敌人
    target = h:GetMeleeEnemy(-h.direction)
    if target then
        h.status = STATUS.Attack
        return
    end

    h.status = STATUS.Think
end
--待机
local function Wait(h)
    --攻击前面的敌人
    local target = h:GetMeleeEnemy(h.direction)
    if target then
        h.status = STATUS.Attack
        return
    end
    --攻击后面的敌人
    target = h.map:GetCombatUnit(h.x - h.direction, h.y)
    if CheckEnemy(h, target) then
        h.status = STATUS.Attack
        return
    end
    h.status = STATUS.Think
end
--进军
local function Forward(h)
    h.direction = h.isAtk and 1 or -1
    ThinkHeroAction(h)
end
--撤退
local function Backward(h)
    h.direction = h.isAtk and -1 or 1
    ThinkHeroAction(h)
end
function _hero.Think(h)
    local bufs = h.buffs
    --停止状态
    if GetBuffsAtt(bufs, BD_AID.Stop) > 0 then return end

    h.actionTime = 0

    if h.Arrived < 1 then
        h.status = STATUS.Move
        return
    end

    local cmd = h.isAtk and h.map.atkHeroCmd or h.map.defHeroCmd
    if cmd == BAT_CMD.Wait then
        if GetBuffsAtt(bufs, BD_AID.FF) > 0 and GetBuffsAtt(bufs, BD_AID.Fear) <= 0 then Forward(h) --逼战
        else Wait(h) end
    elseif cmd == BAT_CMD.Attack then
        if GetBuffsAtt(bufs, BD_AID.Fear) > 0 or (h.map.time < h.restTime.value and GetBuffsAtt(bufs, BD_AID.FF) <= 0) then Wait(h) --恐惧状态 | 以逸待劳效果
        else Forward(h) end
    elseif cmd == BAT_CMD.Retreat then
        if GetBuffsAtt(bufs, BD_AID.FF) > 0 and GetBuffsAtt(bufs, BD_AID.Fear) <= 0 then Forward(h) --逼战
        else Backward(h) end
    end
end
--将武将移动到前方的位置
function _hero.Move(h)
    local ms = h.MoveSpeed
    if ms <= 0 then return end

    h.lastMoveTime = h.map.time
    local x, y = h.x, h.y
    local pos = h.pos
    local dire = B_Vector(x - pos.x, y - pos.y)
    local delta = ms * h.map.deltaTime
    if h.lastX ~= x then h.direction = h.lastX > x and -1 or 1 end
    if dire.magnitude > delta then
        B_Vector.Normalize(dire)
        pos:Set(pos.x + dire.x * delta, pos.y + dire.y * delta)
    else
        pos:Set(x, y)
        h.status = STATUS.Think
    end
end
--武将将攻击敌人
function _hero.Attack(h)
    local atkSpeed = h.MSPA
    if atkSpeed > 0 then
        if h.actionTime == 0 then
            local target = h:GetMeleeEnemy(h.direction, false)
            if target then
                h.actionTime = h.map.deltaMillisecond
                h:AddEvent(BE_Type.Attack, false)
                return
            end
            target = h:GetMeleeEnemy(-h.direction, false)
            if target then
                h.actionTime = -h.map.deltaMillisecond
                h:AddEvent(BE_Type.Attack, false)
                return
            end
        elseif h.actionTime < 0 then
            if h.actionTime > -atkSpeed then
                local ap = B_Math.floor(atkSpeed * 0.7)
                local flag = h.actionTime > -ap
                h.actionTime = h.actionTime - h.map.deltaMillisecond
                if flag and h.actionTime <= -ap then
                    local target = h:GetMeleeEnemy(-h.direction, false)
                    if target then h:StrengthDPS(target) end
                end
                return
            end
        elseif h.actionTime < atkSpeed then
            local ap = B_Math.floor(atkSpeed * 0.7)
            local flag = h.actionTime < ap
            h.actionTime = h.actionTime + h.map.deltaMillisecond
            if flag and h.actionTime >= ap then
                local target = h:GetMeleeEnemy(h.direction, false)
                if target then h:StrengthDPS(target) end
            end
            return
        end
    end
    h.status = STATUS.Think
end
--释放技能动作
function _hero.OnCastSkill(h)
    h.actionTime = h.actionTime + h.map.deltaMillisecond
    if h.actionTime >= 800 then
        h.status = STATUS.Think
    end
end
--endregion

--技能排序
--sksn : 技能编号列表
function _hero.SortSkill(h, sksn)
    local skill = h.skill
    local len = skill and #skill
    if len < 2 then return end
    local cnt = sksn and #sksn
    if cnt < 1 then return end

    local pos = { }
    for i, s in ipairs(skill) do
        pos[i] = 2147483647
        for j = 1, cnt, 1 do
            if s.sn == sksn[j] then
                pos[i] = j
                break
            end
        end
    end
    local sk -- , loc
    for i = 1, len, 1 do
        for j = i + 1, len, 1 do
            if pos[i] > pos[j] then
                skill[i], skill[j] = skill[j], skill[i]
                pos[i], pos[j] = pos[j], pos[i]

--                sk = skill[i]
--                skill[i] = skill[j]
--                skill[j] = sk
--                loc = pos[i]
--                pos[i] = pos[j]
--                pos[j] = loc
            end
        end
    end
end
--调试信息
function _hero.GetDebugInfo(h)
    local wtb, wt = 0.01, 0.0001
    local cap = h.Cap
    return "武将属性:\n命中:"..(h.Acc * wtb)..
    "% 闪避:"..(h.Dodge * wtb)..
    "% 技闪:"..(h.SDodge * wtb)..
    "%\n暴击:"..(h.Crit * wtb)..
    "% 技暴:"..(h.SCrit * wtb)..
    "% 暴伤:"..h.CritDmg..
    "\n移动:"..h.MoveSpeed..
    "/s 攻速:"..(1000 / h.MSPA)..
    "/s\n物伤:"..h.CPD..
    "% 技伤:"..h.CSD..
    "%\n物防:"..(-h.SPD)..
    "% 技防:"..(-h.SSD)..
    "%\n士兵属性:\n武力:"..B_Math.ceil(cap * h.soldierAtt[1] * wt * (1 + soldierBonus[1] * 0.01))..
    " 生命:"..B_Math.ceil(cap * h.soldierAtt[2] * wt * (1 + soldierBonus[2] * 0.01))..
    "\n命中:"..B_Math.max(soldierAtt[4] * wtb + soldierBonus[5], 0)..
    " 闪避:"..B_Math.clamp(soldierAtt[5] * wtb + soldierBonus[6], 0, h.lmtDodge.value)..
    " 技闪:"..B_Math.clamp(soldierBonus[7], 0, h.lmtSDodge.value)..
    "\n暴击:"..B_Math.max(soldierAtt[3] * wtb + soldierBonus[3], 0)..
    " 暴伤:"..soldierBonus[4]..
    "\n移动:"..B_Math.clamp(BD_Const.BASE_MOVE_SPEED_UNIT + BD_Const.BASE_MOVE_SPEED_UNIT * soldierBonus[8] * 0.01, 0, h.lmtMS.value)..
    " 攻速:"..(1000 / B_Math.max(B_Math.ceil(B_Math.max(BD_Const.BASE_MSPA * (1 / (1 + soldierBonus[9] * 0.01)), 100)), h.lmtMSPA.value))..
    "\n物伤:"..soldierBonus[10]..
    " 物防:"..(-soldierBonus[11])..
    " 技防:"..(-soldierBonus[12])
end

--构造函数
local function _ctor(t, map, x, y, isAtk)
    t = setmetatable(_base(map, x, y), _hero)
    
    t.isAtk = isAtk
    t.belong = t
    t.battle = map.battle
    t.direction = isAtk and 1 or -1
    t.onEvent = { }
    t.attChanged = BD_AID.CreateChangeTable()
    t.buffs = QYBattle.B_Buffs(t)
    local EnInt = map.battle.EnInt
    --加密XY
    t._x, t._y = EnInt(rawget(t, "x")), EnInt(t.y)
    rawset(t, "x", nil)
    rawset(t, "y", nil)
    t.dmg = EnInt(-1)
    t.str, t.wis, t.cap = EnInt(0), EnInt(0), EnInt(0)
    t.maxHP, t.maxSP = EnInt(0), EnInt(0)
    t.crit, t.scrit, t.critDmg = EnInt(0), EnInt(0), EnInt(0)
    t.acc, t.dodge, t.sdodge = EnInt(0), EnInt(0), EnInt(0)
    t.movespeed, t.mspa = 0, EnInt(0)
    t.cpd, t.csd = EnInt(0), EnInt(0)
    t.spd, t.ssd = EnInt(0), EnInt(0)
    t.shield = EnInt(0)

    --准备释放的武将技能
    t.castIdx = 0
    --信息已改变
    t.infoChanged = true
    --真实兵力
    t.realTP = -1
    --上次技能暴击的时间
    t.lastSCritTime = 0
    --上次移动的时间
    t.lastMoveTime = 0

    return t
end

--继承扩展
_base:extend(_ctor, _get, _set, _hero)
--[Comment]
--战场战斗单位-武将
QYBattle.BD_Hero = _hero