
QYBattle = { }

require "Util/kjson"
require "Battle/Data/BD_Const"
require "Battle/Data/BD_Struct"
require "Battle/Data/B_Math"
require "Battle/Data/B_Random"
require "Battle/Data/B_Vector"
require "Battle/Data/EnInt"
require "Battle/Data/B_Util"

require "Battle/Data/BD_AID"
require "Battle/Data/BD_ANM"
require "Battle/Data/BD_ExtAtt"
require "Battle/Data/BE_Event"
require "Battle/Data/BD_DPS"

require "Battle/Data/EnHero"
require "Battle/Data/EnSkc"
require "Battle/Data/EnSkd"
require "Battle/Data/EnSks"

require "Battle/Data/Battle"
require "Battle/Data/BD_Field"

require "Battle/Data/Buff/BD_Buff"
require "Battle/Data/Buff/BD_BuffSlot"
require "Battle/Data/Buff/B_Buffs"

require "Battle/Data/BD_Unit"
require "Battle/Data/BD_CombatUnit"
require "Battle/Data/BD_Arrow"
require "Battle/Data/BD_Soldier"
require "Battle/Data/BD_SKD"
require "Battle/Data/BD_Dehero"
require "Battle/Data/BD_Hero"
require "Battle/Data/BD_SKC"
require "Battle/Data/BD_SKS"
require "Battle/Data/BD_AI"

--[[*******************************生成函数*****************************]]
--[Comment]
--攻城战斗-数据
--return : Battle
function QYBattle.GenBattleSiege(json)
    return QYBattle.Battle.NewSiege(kjson.ldec(json, QYBattle.BD_Struct.S_BattleSiege))
end
--[Comment]
--攻城战斗-单场
--b : Battle
--json : 数据
--return : BD_Field
function QYBattle.BattleSiegeFight(b, json)
    local dat = kjson.ldec(json, QYBattle.BD_Struct.S_BattleFightData)
    local atk = b.atkHeros[b:atkFightHeroIdx()]
    local def = b.defHeros[b:defFightHeroIdx()]
    atk:SetEvoSkill(dat.atkHero.ske)
    atk:SetGveBuff(dat.atkHero.gveBuff)
    atk:SetArmBuff(dat.atkHero.armBuff)
    def:SetEvoSkill(dat.defHero.ske)
    def:SetGveBuff(dat.defHero.gveBuff)
    def:SetArmBuff(dat.defHero.armBuff)
    local f = QYBattle.BD_Field(b, true)
    f:InitSiege(dat, atk, def)
    return f
end
--[Comment]
--国战等单对单
--return : BD_Field
function QYBattle.GenBttleSingle(json, recEvt)
    json = kjson.ldec(json, QYBattle.BD_Struct.S_BattleSingle)
    local dat = QYBattle.Battle.NewSingle(json)
    dat = QYBattle.BD_Field(dat, recEvt, json.seed)
    dat:InitSingle(json)
    return dat
end

--[Comment]
--国战等计算函数，完全隔离环境
--cmd : 发送的命令
--func : 功能
--fsn : 编号
--pos : 位置
--dat : 数据
function QYBattle.CalcBttleSingle(cmd, func, fsn, pos, dat)
    dat = kjson.ldec(dat, QYBattle.BD_Struct.S_BattleSingle)
    print(kjson.print(dat))
    local fd = QYBattle.BD_Field(QYBattle.Battle.NewSingle(dat), false, dat.seed)
    fd:InitSingle(dat)

    local resp = '{"sn":' .. fsn .. ',"func":"' .. func .. (pos and '","pos":' .. pos or '"')
    if fd and fd.battle.sn and fd.battle.sn > 0 then
        fd:ActivateAI(true)
        fd:ActivateAI(false)
        local fc = fd.maxFrameCount + 8
        while fd.result == 0 and fc > 0 do
            fc = fc - 1
            fd:Update()
        end
        local ret = fd.result
        if ret == 0 and fc <= 8 then ret = fd.defHero.HP > 0 and 1 or -1 end
        if ret == 0 then
            resp = resp .. ',"ret":0}'
        else
            local win = ret > 0 and fd.atkHero.dat or fd.defHero.dat
            resp = resp..',"hp":'..win.hp.value..',"sp":'..win.sp.value..',"tp":'..win.tp.value..',"ret":'..ret..'}'
        end
    else
        resp = resp .. ',"ret":0}'
    end
    print(resp)
    Send(cmd, resp)
end