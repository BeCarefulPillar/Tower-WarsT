--[Comment]
--属性ID
QYBattle.BD_AID =
{
    --[Comment]
    --BUF属性SIZE
    SIZE = 36,

    --[Comment]
    --无敌
    God = 1,
    --[Comment]
    --完全停止
    Stop = 2,
    --[Comment]
    --禁锢
    Fixed = 3,
    --[Comment]
    --致盲
    Blind = 4,
    --[Comment]
    --恐惧
    Fear = 5,
    --[Comment]
    --逼战
    FF = 6,

    --[Comment]
    --武力增减百分比
    Str = 9,
    --[Comment]
    --智力增减百分比
    Wis = 10,
    --[Comment]
    --统率增减百分比
    Cap = 11,
    --[Comment]
    --生命增减百分比
    HP = 12,
    --[Comment]
    --技力增减百分比
    SP = 13,
    --[Comment]
    --CD增减百分比
    CD = 14,
    --[Comment]
    --造成武力伤害增减百分比
    CPD = 15,
    --[Comment]
    --造成技能伤害增减百分比
    CSD = 16,
    --[Comment]
    --受到武力伤害增减百分比
    SPD = 17,
    --[Comment]
    --受到技能伤害增减百分比
    SSD = 18,
    --[Comment]
    --每秒受到的物理伤害
    Dmg = 19,
    --[Comment]
    --每秒受到的技能伤害
    SDmg = 20,
    --[Comment]
    --每秒受到的治疗
    Cure = 21,
    --[Comment]
    --移动速度增减
    MoveSpeed = 22,
    --[Comment]
    --攻速增减
    MSPA = 23,
    --[Comment]
    --准确增减
    Acc = 24,
    --[Comment]
    --闪避增减
    Dodge = 25,
    --[Comment]
    --技能闪避
    SDodge = 26,
    --[Comment]
    --暴击几率
    Crit = 27,
    --[Comment]
    --技能暴击几率
    SCrit = 28,
    --[Comment]
    --暴击伤害
    CritDmg = 29,
    --[Comment]
    --士气
    Morale = 30,
    --[Comment]
    --伤害反射
    DmgRef = 31,
    --[Comment]
    --伤害反噬
    DmgBack = 32,
    --[Comment]
    --沉默
    Silence = 33,
    --[Comment]
    --技力减少
    Energy = 34,
    --[Comment]
    --护盾
    Shield = 35,
    --[Comment]
    --免疫控制
    ResControl = 36,

    --[Comment]
    --是否无效的属性ID
    Invalid = function(aid) return aid < 1 or aid > 36 end,

    --[Comment]
    --是否是控制属性ID (Stop Fixed Fear FF Silence)
    IsControlAid = function(aid) return aid == 2 or aid == 3 or aid == 5 or aid == 6 or aid == 33 end,

    --[Comment]
    --创建属性变更表
    CreateChangeTable = function(flag)
        local t = { }
        for i = 1, 36 do t[i] = flag ~= false end
        return t
    end,
}