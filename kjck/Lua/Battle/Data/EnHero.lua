local rawget = rawget

local BD_Const = QYBattle.BD_Const
local B_Math = QYBattle.B_Math
local BD_ExtAtt = QYBattle.BD_ExtAtt
local BD_ANM = QYBattle.BD_ANM

local _eh = { }

--武将编号，非PVP为DBSN
--string sn;

--武将的DBSN
--EnInt dbsn;

--武将等阶
--EnInt evo;

--觉醒技能的编号
--EnInt evoSkill;

--武将等级
--EnInt level;

--武将武力
--EnInt strength;

--武将智力
--EnInt intelligent;

--武将统率
--EnInt cap;

--武将忠诚
--EnInt loyalty;

--武将初始HP
--int init_hp;

--武将当前HP
--EnInt hp;

--武将最大HP
--EnInt max_hp;

--武将初始SP
--int init_sp;

--武将当前SP
--EnInt sp;

--武将最大SP
--EnInt max_sp;

--武将初始TP
--int init_tp;

--武将当前TP
--EnInt tp;

--武将最大TP
--EnInt max_tp;

--武将兵种编号
--EnInt arm;

--武将阵形编号
--EnInt lnp;

--是否是将星技能
--bool isStar;

--将星
--int star;

--武将状态 1=可战 0/其它=不可战
--EnInt status;

--战斗次数统计
--EnInt stats;

--扩展属性(幻化 专属 觉醒)
--B_ExtraAtts extras;

--武将AI
--S_HeroAI ai;

--地宫房间Buff
--EnInt gveBuff;

--兵种特性Buff
--B_ExtraAtts armBuff;

------------统计数据
-- 技能使用记录
--skillRec,
-- 受到的伤害累计
--statDmgS,
----------

--从S_BattleHeroData生成加密的武将数据
--dat : S_BattleHeroData
--EnInt : 加密整数生成器
function _eh.__call(t, dat, EnInt)
    t = setmetatable(
    {
        sn = dat.sn,
        dbsn = EnInt(dat.dbsn),
        evo = EnInt(dat.evo),
        evoSkill = EnInt(0),
        lv = EnInt(dat.lv),
        str = EnInt(dat.str),
        wis = EnInt(dat.wis),
        cap = EnInt(dat.cap),
        loyalty = EnInt(dat.loyalty),
        init_hp = dat.hp,
        hp = EnInt(B_Math.max(1, dat.hp)),
        max_hp = EnInt(dat.max_hp),
        init_sp = dat.sp,
        sp = EnInt(B_Math.max(1, dat.sp)),
        max_sp = EnInt(dat.max_sp),
        init_tp = dat.tp,
        tp = EnInt(B_Math.max(1, dat.tp)),
        max_tp = EnInt(dat.max_tp),

        arm = EnInt(dat.arm),
        lnp = EnInt(dat.lnp),
        isStar = dat.star >= BD_Const.HERO_STAR_ACTIVE_LV,
        star = dat.star,

        status = EnInt(1),
        stats = EnInt(0),

        extras = BD_ExtAtt(dat.extra),

        gveBuff = EnInt(0),
        

        skillRec = 0,
        statDmgS = 0,
        
    }, _eh)

    dat = t.extras
    if #dat > 0 then
        t.str.value = t.str.value + (dat[BD_ANM.Str] or 0)
        dat:Remove(BD_ANM.Str)
        t.wis.value = t.wis.value + (dat[BD_ANM.Wis] or 0)
        dat:Remove(BD_ANM.Wis)
        t.cap.value = t.cap.value + (dat[BD_ANM.Cap] or 0)
        dat:Remove(BD_ANM.Cap)
        t.hp.value = t.hp.value + (dat[BD_ANM.HP] or 0)
        dat:Remove(BD_ANM.HP)
        t.sp.value = t.sp.value + (dat[BD_ANM.SP] or 0)
        dat:Remove(BD_ANM.SP)
        t.tp.value = t.tp.value + (dat[BD_ANM.TP] or 0)
        dat:Remove(BD_ANM.TP)
    end
    return t
end

function _eh.__index(t, k) return rawget(_eh, k) end

--获取扩展属性词条(幻化 专属 觉醒)的值
function _eh.GetExtAtt(e, k) return e.extras[k] or 0 end

--设置觉醒技能
--dat : S_BattleAtt
function _eh.SetEvoSkill(e, dat)
    if e.evoSkill.value > 0 or dat == nil or dat.sn == nil or dat.sn <=0 or dat.extra == nil or dat.extra == "" then return end
    e.evoSkill.value = dat.sn
    e.extras:Add(dat.extra)
end

--设置兵种Buff
function _eh.SetArmBuff(e, dat)
    e.armBuff = BD_ExtAtt(dat, false)
    e.hasArmBuff = #e.armBuff > 0
end

--设置地宫房间Buff
--dat : S_BattleAtt
function _eh.SetGveBuff(e, dat)
    if e.gveBuff.value > 0 or dat == nil or dat.sn == nil or dat.sn <=0 or dat.extra == nil or dat.extra == "" then return end
    e.gveBuff.value = dat.sn
    e.extras:Add(dat.extra)
end

--配置AI
--dat : S_HeroAI
function _eh.SetAI(e, dat)
    if dat and dat.skillWait then
        for i = 1, #dat.skillWait, 1 do
            dat.skillWait[i] = dat.skillWait[i] * 1000
        end
    end
    e.ai = dat
end

--[Comment]
--从S_BattleHeroData数组生成加密的武将数组
--dat : S_BattleHeroData数组
--EnInt : 加密整数生成器
function _eh.FromArray(dat, EnInt)
    if dat and #dat > 0 then
        local arr = { }
        for i = 1, #dat, 1 do arr[i] = _eh(dat[i], EnInt) end
        return arr
    end
end

setmetatable(_eh, _eh)
--[Comment]
--加密武将数据
QYBattle.EnHero = _eh