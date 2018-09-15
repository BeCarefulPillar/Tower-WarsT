
local ipairs = ipairs
local Destroy = Destroy
local typSp = typeof(UISprite)
local BAT_CMD = QYBattle.BAT_CMD

local _const =
{
    ColorRed = Color.red,
    ColorWhite = Color.white,
    ColorBlack = Color.black,
    ColorGray = Color.gray,
    ColorTip = Color(1, 1, 0.25),

    V3TipHeroPosFrom = Vector3(39, 0, 0),
    V3TipHeroPosTo = Vector3(49, 0, 0),

    V3TipArmPosFrom = Vector3(-39, 0, 0),
    V3TipArmPosTo = Vector3(-49, 0, 0),

    V3Zero = Vector3.zero,
    V3One = Vector3.one,
    V3_Y = Vector3(1, -1, 1)
}

local _ctrl = class()
--[Comment]
--战场控件
BU_Control = _ctrl
--成员变量说明
--[[
mAcc bool               是否加速
tipTime int             提示时间
onTriggerSkd func       副将技触发函数
updHandle table         Update事件侦听节点句柄

Pause bool              是否暂停(get,set)
Accelerate bool         是否加速(get,set)

map BU_Map              地图的Lua对象
mapDat BD_Field         战场数据
hero BD_Hero            攻方武将数据
atkDehero BD_Dehero     攻方副将数据
defDehero BD_Dehero     守方副将数据

body LuaContainer       Lua容器
go GameObject           Lua容器的GameObject
mapBody BU_Map          地图C#组件对象
labTime UILabel         时间显示
gridTex GridTexture     网格纹理工具

itemSkc GameObject      预制件-武将技
itemSkd GameObject      预制件-副将技
pnlSkc GameObject       面板根-武将技
atkSkd GameObject       面板根-攻方副将技
defSkd GameObject       面板根-守方副将技
btnSkip GameObject      按钮-跳过
btnSpeed UISprite       按钮-加速
btnAll UISprite         按钮-全军出击
clickAnim GameObject    按钮-下面的提示箭头
tipGo GameObject        按钮-下面的提示特效
btnRetreat UISprite     按钮-全军撤退
btnHero UISprite        按钮-武将命令
btnArm UISprite         按钮-士兵命令

defView GameObject      敌方特写镜头

atkBuffs UITexture[]    攻方固有Buff的图标根
defBuffs UITexture[]    守方固有Buff的图标根

atkBuff BU_BuffControl  攻方Buf控件
defBuff BU_BuffControl  守方Buf控件

skcItems table        武将技Item表
[{
    go GameObject       Item根
    nm UILabel          技能名称
    sp UILabel          技力值
    cd UISprite         CD遮罩
    cdf UISprite        技能可用时的外框动画
}]

atkSkdItems table     攻方副将技Item表
[{
    go GameObject       Item根
    qty UILabel         可触发次数
    cd UISprite         CD遮罩
}]
defSkdItems table     守方方副将技Item表(表结构同攻方)
]]


local function CheckTutorial(t)
    if user.TutorialSN == 1 then
        -- 全军出击，武将待命
        if user.TutorialStep == 4 then
            user.TutorialStep = 6
            t.mapDat.atkArmCmd = BAT_CMD.Wait
            _ctrl:ClickArmCmd()
        -- 释放技能
        elseif user.TutorialStep == 6 then
            Tutorial.PlayTutorial(true, t.skcItems[1].transform)
            Tutorial.showFrame = false
            t.Pause = true
            if t.tipGo then Destroy(t.tipGo) end
            if t.clickAnim.activeSelf then t.clickAnim:SetActive(false) end
            t.tipTime = 0
        -- 士兵出击
        elseif user.TutorialStep == 13 then
            if t.mapDat.atkArmCmd == BAT_CMD.Attack then t.mapDat.atkArmCmd = BAT_CMD.Wait end
            Tutorial.PlayTutorial(true, t.btnArm.transform)
            t.Pause = true
            if t.tipGo then Destroy(t.tipGo) end
            if t.clickAnim.activeSelf then t.clickAnim:SetActive(false) end
            t.tipTime = 0
        -- 全军出击
        elseif user.TutorialStep == 24 then
            if t.mapDat.atkHeroCmd == BAT_CMD.Attack or t.mapDat.atkArmCmd == BAT_CMD.Attack then
                t.mapDat.atkHeroCmd = BAT_CMD.Wait
                t.mapDat.atkArmCmd = BAT_CMD.Wait
            end
            Tutorial.PlayTutorial(true, t.btnAll.transform)
            t.Pause = true
            if t.tipGo then Destroy(t.tipGo) end
            if t.clickAnim.activeSelf then t.clickAnim:SetActive(false) end
            t.tipTime = 0
        end
    end
end

local function OnCheckUnLock(t)
    if t.mapDat ~= nil and t.mapDat.battle.battleType == 1 then
        if user.gmMaxCity == 2 and t.mapDat.battle.sn == 3 then
            t.Pause = true
            local wait = true
            local t = Time.realtimeSinceStartup + 5
            UnLockEffect.Begin(t.btnArm.gameObject, L("战斗指令解锁"), l("控制士兵冲锋或待命"), function () wait = false end)
            while wait and t > Time.realtimeSinceStartup do coroutine.step() end
            t = Time.realtimeSinceStartup + 0.82
            while t > Time.realtimeSinceStartup do coroutine.step() end
            t.btnArm.gameObject:SetActive(true)
            t.Pause = false
            CheckTutorial(t)
        elseif user.gmMaxCity == 3 and t.mapDat.battle.sn == 4 then
            t.Pause = true
            local wait = true
            local t = Time.realtimeSinceStartup + 5
            UnLockEffect.Begin(t.btnAll.gameObject, L("战斗指令解锁"), l("控制全军冲锋或待命"), function () wait = false end)
            while wait and t > Time.realtimeSinceStartup do coroutine.step() end
            t = Time.realtimeSinceStartup + 0.82
            while t > Time.realtimeSinceStartup do coroutine.step() end
            t.btnAll.gameObject:SetActive(true)
            t.btnRetreat.gameObject:SetActive(true)
            t.btnHero.gameObject:SetActive(true)
            t.Pause = false
            CheckTutorial(t)
        else CheckTutorial(t)
        end
    end
end
_ctrl.CheckUnLock = function (t) coroutine.start(OnCheckUnLock, t) end

local function GetTriggerSkd(t)
    return function(dh, sn)
        if dh and dh.hero and dh.skillQty > 0 then
            local its = dh.hero.isAtk and t.atkSkdItems or t.defSkdItems
            for i, s in ipairs(dh.skill) do
                if s.sn.value == sn then
                    i = its[i]
                    if i then
                        i.go:AddChild(AM.LoadPrefab("ef_skd_act"), "ef_skd_act")
                        i.qty.text = "[b]".. s.curQty.value .. "/" .. s.qty.value
                    end
                end
            end
        end
    end
end
--构造函数
function _ctrl.ctor(t)
    t.mAcc = false
    t.tipTime = 0
    t.onTriggerSkd = GetTriggerSkd(t)
end
--LuaContainer加载
--c : LuaContainer
function _ctrl.OnLoad(t, c)
    t.body = c
    t.go = c.gameObject

    local var = c.nsrf.ref
    t.itemSkc, t.itemSkd, t.pnlSkc, t.defView = var.item_skill, var.item_skill_d, var.skillPanel, var.enemyView
    t.btnAuto, t.btnSkip, t.atkSkd, t.atkBuff, t.defSkd, t.defBuff = var.btnAutoFight, var.btnSkip, var.atkSkdPanel, BU_BuffControl(var.atkBuff), var.defSkdPanel, BU_BuffControl(var.defBuff)

    local buffs = var.atkBuffs
    local tmp = { }
    for i = 1, #buffs do tmp[i] = buffs[i]; tmp[i].luaBtn.param = i end
    t.atkBuffs = tmp

    buffs = var.defBuffs
    tmp = { }
    for i = 1, #buffs do tmp[i] = buffs[i]; tmp[i].luaBtn.param = i end
    t.defBuffs = tmp

    t.mapBody, t.labTime = var.map, var.timeLab
    t.btnSpeed, t.btnAll, t.btnRetreat = var.btnSpeed, var.btnAll, var.btnRetreat
    t.btnHero, t.btnArm = var.btnHero, var.btnSoldier

    t.clickAnim = var.clickAnim

    c:BindFunction("OnUnLoad", "Dispose", "ClickSpeed", "ClickSkip", "ClickSkc", "ClickSkd",
        "ClickAtkHeroIcon", "ClickDefHeroIcon", "PressAtkBuff", "PressDefBuff", "ClickAuto",
        "ClickAllCmd", "ClickHeroCmd", "ClickArmCmd", "ClickRetreat")

    if isDebug then
        var = t.mapBody:Child("bg_a"):AddCmp(typeof(LuaButton))
        var.luaContainer = c
        var:SetPress("PressMap")
        c:BindFunction("PressMap")
    end
end
--LuaContainer卸载
--c : LuaContainer
function _ctrl.OnUnLoad(t, c)
    if t.body == c then
        t.body = nil
        t:Dispose()
    end
end
--属性-攻方军师技UITexture
function _ctrl.get_AtkSktBuf(t) return t.atkBuffs[1] end
--属性-守方军师技UITexture
function _ctrl.get_DefSktBuf(t) return t.defBuffs[1] end
--属性-暂停游戏(get)
function _ctrl.get_Pause(t) return t.map and t.map.pause end
--属性-暂停游戏(set)
function _ctrl.set_Pause(t, v) if t.map then t.map.pause = v end end
--属性-是否加速(get)
function _ctrl.get_Accelerate(t) return t.mAcc and t.mapDat and t.mapDat.battle:canAccelerate() end
--属性-是否加速(set)
function _ctrl.set_Accelerate(t, v)
    local md = t.mapDat
    if md then
        local btyp = md.battle.type.value
        if btyp == 0 then
            t.mAcc = false
            t.map.speed = 2
        elseif btyp == 1 and user.gmMaxCity < CONFIG.T_LEVEL then
            t.mAcc = true
            t.map.speed = 2
        else
            t.mAcc = v and md.battle:canAccelerate() or false
            t.map.speed = t.mAcc and 2 or 1
        end
    end
    t.btnSpeed.spriteName = t.mAcc and "btn_battle_speed_2" or "btn_battle_speed_1"
end

--设置时间UILabel的显示值
local function SetTime(t, ms) t.labTime.text = L("时间")..":".. (math.modf(ms / 1000)) end
--Update循环
local function Update(t)
    local md = t.mapDat
    if md and md.result == 0 and t.map.active then
        --计时
        if md.frameCount % md.frameRate == 0 then SetTime(t, md.maxTime - md.time) end
        
        local var
        local h = t.hero
        --武将技
        if t.skcItems then
            local v
            local sp = h.SP
            local slst = h.skill
            for i, it in ipairs(t.skcItems) do
                var = slst and slst[i]
                if var then
                    if var.sp.value > sp then
                        it.sp.color = _const.ColorRed
                        v, it.cd.fillAmount = 1, 1
                    else
                        it.sp.color = _const.ColorWhite
                        v = 1 - h:GetSkillCDPercent(i)
                        if it.cd.fillAmount > 0 and v <= 0 then
                            it.cd.fillAmount = 0

                            --演示动画
                            if it.cdf == nil then
                                var = it.go:AddWidget(typSp, "cd_frame")
                                var.atlas = AM.mainAtlas
                                var.spriteName = "skc_frame";
                                var.depth = 5
                                var:MakePixelPerfect()
                                var.alpha = 0.2
                                TweenAlpha.Begin(var.cachedGameObject, 0.4, 1).style = UITweener.Style.PingPong
                                it.cdf = var
                            end
                            it.go:AddChild(AM.LoadPrefab("ef_skill"), "ef_skill")

                            --CheckTutorial(t)
                        else
                            it.cd.fillAmount = v
                        end
                    end
                else
                    v, it.cd.fillAmount = 1, 1
                end

                if v > 0 and it.cdf then
                    CS.DesGo(it.cdf)
                    it.cdf = nil
                end
            end
        end
        --攻方副将技
        var = t.atkSkdItems
        if var then
            local v
            local slst = t.atkDehero.skill
            for i, it in ipairs(var) do
                i = slst and slst[i]
                if i then
                    it.qty.color = i.curQty.value > 0 and _const.ColorWhite or _const.ColorRed
                    v = 1 - i:CDPercent()
                    if it.cd.fillAmount > 0 and v <= 0 then
                        it.cd.fillAmount = 0

                        --演示动画
                    else
                        it.cd.fillAmount = v
                    end
                else
                    it.cd.fillAmount = 1
                end
            end
        end
        --守方副将技
        var = t.defSkdItems
        if var then
            local v
            local slst = t.defDehero.skill
            for i, it in ipairs(var) do
                i = slst and slst[i]
                if i then
                    it.qty.color = i.curQty.value > 0 and _const.ColorWhite or _const.ColorRed
                    v = 1 - i:CDPercent()
                    if it.cd.fillAmount > 0 and v <= 0 then
                        it.cd.fillAmount = 0

                        --演示动画
                    else
                        it.cd.fillAmount = v
                    end
                else
                    it.cd.fillAmount = 1
                end
            end
        end

        --静止提示
        if md.atkHeroCmd == BAT_CMD.Wait and md.atkArmCmd == BAT_CMD.Wait and md.battle.type.value ~= 0 then
            if t.tipGo then
                t.tipTime = 0
            elseif t.tipTime > 3 then
                var = DB.GetHero(h.dat.dbsn).kind
                if var == 1 then
                    var = t.banAll:AddWidget(typSp, "sp_tip")
                    t.tipGo = var.cachedGameObject
                    var.atlas = t.banAll.atlas
                    var.spriteName = "sp_carcle"
                    var.width, var.height = 76, 76
                    var.depth = t.banAll.depth + 1
                    var.AddCmp("TipEffect")
                    var.color = _const.ColorTip

                    var = t.clickAnim.transform
                    var.parent = t.banAll.cachedTransform
                    var.localScale = _const.V3One
                    t.clickAnim:SetActive(true)

                    var = t.clickAnim:GetCmp(typeof(TweenPosition))
                    var.from = _const.V3TipHeroPosFrom
                    var.to = _const.V3TipHeroPosTo
                elseif var == 2 or var == 3 then
                    var = t.btnArm:AddWidget(typSp, "sp_tip")
                    t.tipGo = var.cachedGameObject
                    var.atlas = t.btnArm.atlas
                    var.spriteName = "sp_carcle"
                    var.width, var.height = 76, 76
                    var.depth = t.btnArm.depth + 1
                    var.AddCmp("TipEffect")
                    var.color = _const.ColorTip

                    var = t.clickAnim.transform
                    var.parent = t.btnArm.cachedTransform
                    var.localScale = _const.V3_Y
                    t.clickAnim:SetActive(true)

                    var = t.clickAnim:GetCmp(typeof(TweenPosition))
                    var.from = _const.V3TipArmPosFrom
                    var.to = _const.V3TipArmPosTo
                end
            else
                t.tipTime = t.tipTime + Time.deltaTime
            end
        else
            if t.tipGo then Destroy(t.tipGo); t.tipGo = nil end
            if t.clickAnim.activeSelf then t.clickAnim:SetActive(false) end
            t.tipTime = 0
        end

        --BU_BuffControl驱动
        t.atkBuff:Update(h)
        t.defBuff:Update(h)
    end
end
--释放
function _ctrl.Dispose(t)
    t.mapDat = nil
    t.hero, t.atkDehero, t.defDehero = nil, nil, nil
    t.tipTime = 0

    if t.map and t.map.onTriggerSkd == t.onTriggerSkd then t.map.onTriggerSkd = nil end

    if t.updHandle then UpdateBeat:RemoveListener(t.updHandle) end

     if t.gridTex then
        t.gridTex:Dispose()
        t.gridTex = nil
     end

    t.btnAll:ChildWidget("state").spriteName = "sp_start"
    t.btnArm:ChildWidget("state").spriteName = "sp_start"
    t.btnHero:ChildWidget("state").spriteName = "sp_start"

     if t.skcItems then
        for _, it in ipairs(t.skcItems) do Destroy(it.go) end
        t.skcItems = nil
     end
     if t.atkSkdItems then
        for _, it in ipairs(t.atkSkdItems) do Destroy(it.go) end
        t.atkSkdItems = nil
     end
     if t.defSkdItems then
        for _, it in ipairs(t.defSkdItems) do Destroy(it.go) end
        t.defSkdItems = nil
     end
     for _, v in ipairs(t.atkBuffs) do
        v:SetActive(false)
        v:SetEnable(false)
     end
     for _, v in ipairs(t.defBuffs) do
        v:SetActive(false)
        v:SetEnable(false)
     end

     if t.tipGo then Destroy(t.tipGo); t.tipGo = nil end
     t.clickAnim:SetActive(false)

     t.atkBuff:Dispose()
     t.defBuff:Dispose()
end
--是否可以自动战斗
local function CanAutoFight(t)
    local bat = t.mapDat.battle
    local btyp = bat.type.value 
    return btyp == 1 or btyp == 2 or btyp == 3 or btyp == 4 or btyp == 7 or btyp == 9 or btyp == 12
end
--自动战斗
local function AutoFight(t)
    local md = t.mapDat
    if user.IsUseAutoFight then
        md:ActivateAI(true)
        local sp = t.btnAuto:GetCmp(typeof(UISprite))
        sp.spriteName = "btn_autoBattle"

        t.btnHero:SetActive(false)
        t.btnAll:SetActive(false)
        t.btnArm:SetActive(false)
        t.btnRetreat:SetActive(false)

        for i=1, 4 do
            local it = t.skcItems[i]
            it.go:GetCmp(typeof(UE.Collider)).enabled = false
        end
    else
        md:DeactivateAI(true)
        local sp = t.btnAuto:GetCmp(typeof(UISprite))
        sp.spriteName = "btn_autoBattle_fight"

        t.btnHero:SetActive(true)
        t.btnAll:SetActive(true)
        t.btnArm:SetActive(true)
        t.btnRetreat:SetActive(true)

        if md.atkHeroCmd == BAT_CMD.Attack and md.atkArmCmd == BAT_CMD.Attack then
            t.btnAll:ChildWidget("state").spriteName = "sp_stop"
        else t.btnAll:ChildWidget("state").spriteName = "sp_start" end

        if md.atkHeroCmd == BAT_CMD.Attack then
            t.btnHero:ChildWidget("state").spriteName = "sp_stop"
        else t.btnHero:ChildWidget("state").spriteName = "sp_start" end

        t.btnArm:ChildWidget("state").spriteName = "sp_stop"

        for i=1, 4 do
            local it = t.skcItems[i]
            it.go:GetCmp(typeof(UE.Collider)).enabled = true
        end
    end
end
--初始化
function _ctrl.Init(t)
    assert(t.body and t.mapBody, "you must Load LuaContainer first")

    t:Dispose()

    local map = t.mapBody.luaTable
    local md = map.dat
    local bat = md.battle
    local btyp = bat.type.value
    local atkH, defH = md.atkHero, md.defHero
    local atkDh, defDh = atkH.dehero, defH.dehero
    t.map, t.mapDat, t.hero = map, md, atkH
    t.atkDehero, t.defDehero = atkDh, defDh

    map.onTriggerSkd = t.onTriggerSkd

    SetTime(t, md.maxTime)

    local var, tmp

    local isAutoFight = bat:isAutoFight()

    if isAutoFight then
        t.btnAll:SetActive(false)
        t.btnRetreat:SetActive(false)
        t.btnHero:SetActive(false)
        t.btnArm:SetActive(false)
        t.btnSkip:SetActive(btyp > 0)
    elseif btyp == 1 then
        var = user.gmMaxCity
        t.btnAll:SetActive(var > 3)
        t.btnRetreat:SetActive(var > 3)
        t.btnHero:SetActive(var > 3)
        t.btnArm:SetActive(var > 2)
        t.btnSkip:SetActive(false)
    else
        t.btnAll:SetActive(true)
        t.btnRetreat:SetActive(true)
        t.btnHero:SetActive(true)
        t.btnArm:SetActive(true)
        t.btnSkip:SetActive(false)
    end

    t.btnSpeed:SetActive(btyp > 0 and user.gmMaxCity >= CONFIG.T_LEVEL)
    t.btnAuto:SetActive(CanAutoFight(t) and user.IsAutoFightUL and user.gmMaxCity > 3)

    local hdb = DB.GetHero(atkH.dat.dbsn.value)

    if t.gridTex == nil then t.gridTex = GridTexture(128) end
    local gridTex = t.gridTex

    --加载武将头像纹理
    gridTex:Add(map.atkHero.avatar:LoadTexAsync(ResName.HeroIcon(hdb.img)))
    gridTex:Add(map.defHero.avatar:LoadTexAsync(ResName.HeroIcon((DB.GetHero(md.defHero.dat.dbsn.value)).img)))
    --加载军师技BUF图标 1
    if bat.atkSktSn > 0 then
        var = t.atkBuffs[1]
        var:SetActive(true)
        gridTex:Add(var:LoadTexAsync(ResName.SkillIconT(bat.atkSktSn)))
    end
    if bat.defSktSn > 0 then
        var = t.defBuffs[1]
        var:SetActive(true)
        gridTex:Add(var:LoadTexAsync(ResName.SkillIconT(bat.defSktSn)))
    end
    --加载觉醒技BUF图标 2
    var = atkH.dat.evoSkill.value
    if var > 0 then
        tmp = t.atkBuffs[2]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync(ResName.SkillIconE(var)))
    end
    var = defH.dat.evoSkill.value
    if var > 0 then
        tmp = t.defBuffs[2]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync(ResName.SkillIconE(var)))
    end
    --加载锦囊技BUF图标 3
    var = atkH.SkpSN
    if var > 0 then
        tmp = t.atkBuffs[3]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync(ResName.SkillIconP(var)))
    end
    var = defH.SkpSN
    if var > 0 then
        tmp = t.defBuffs[3]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync(ResName.SkillIconP(var)))
    end
    --加载副将图标 4
    if atkDh and atkDh.dbsn > 0 then
        tmp = t.atkBuffs[4]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync(ResName.DeheroIcon(DB.GetDehero(atkDh.dbsn).img)))
    end
    if defDh and defDh.dbsn > 0 then
        tmp = t.defBuffs[4]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync(ResName.DeheroIcon(DB.GetDehero(defDh.dbsn).img)))
    end
    --加载阵形铭刻图标 5
    if atkH.hasLnpImp then
        tmp = t.atkBuffs[5]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("tex_lineup"))
    end
    if defH.hasLnpImp then
        tmp = t.defBuffs[5]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("tex_lineup"))
    end
    --加载名将谱图标 6
    if bat.atkHasAtlas then
        tmp = t.atkBuffs[6]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("tex_atlas"))
    end
    if bat.defHasAtlas then
        tmp = t.defBuffs[6]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("tex_atlas"))
    end
    --加载联盟科技图标 7
    if bat.atkHasTech then
        tmp = t.atkBuffs[7]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("tex_tech"))
    end
    if bat.defHasTech then
        tmp = t.defBuffs[7]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("tex_tech"))
    end
    --加载铜雀台 8
--    var = bat.atkBeauty
--    if var and var.sn > 0 then
--        tmp = t.atkBuffs[8]
--        tmp:SetActive(true)
--        gridTex:Add(tmp:LoadTexAsync(ResName.BeautyIcon(var.sn)))
--    end
--    var = bat.defBeauty
--    if var and var.sn > 0 then
--        tmp = t.defBuffs[8]
--        tmp:SetActive(true)
--        gridTex:Add(tmp:LoadTexAsync(ResName.BeautyIcon(var.sn)))
--    end
    --加载道具BUF图标 9+
    local fixedBuf = 8
    local leftBuf = #t.atkBuffs - fixedBuf
    var = bat.atkPropsSn
    if var then
        for i, p in ipairs(var) do
            if i > leftBuf then break end
            tmp = t.atkBuffs[fixedBuf + i]
            tmp:SetActive(true)
            gridTex:Add(tmp:LoadTexAsync(ResName.PropsIcon(DB.GetProps(p).img)))
        end
    end
    var = bat.defPropsSn
    if var then
        for i, p in ipairs(var) do
            if i > leftBuf then break end
            tmp = t.defBuffs[fixedBuf + i]
            tmp:SetActive(true)
            gridTex:Add(tmp:LoadTexAsync(ResName.PropsIcon(DB.GetProps(p).img)))
        end
    end
    --加载地宫房间BUF图标 11
    var = atkH.dat.gveBuff.value
    if var > 0 then
        tmp = t.atkBuffs[11]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("tex_palace"))
    end
    var = defH.dat.gveBuff.value
    if var > 0 then
        tmp = t.defBuffs[11]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("tex_palace"))
    end
    --加载地宫陷阱Buff 12 (只对攻方生效)
    var = bat.hasGveTrap
    if var then
        tmp = t.atkBuffs[12]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("tex_palace_trap"))
    end
    --加哉兵种Buff
    var = atkH.dat.hasArmBuff
    if var then
        tmp = t.atkBuffs[13]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("so_" .. atkH.dat.arm.value))
    end
    var = defH.dat.hasArmBuff
    if var then
        tmp = t.defBuffs[13]
        tmp:SetActive(true)
        gridTex:Add(tmp:LoadTexAsync("so_" .. defH.dat.arm.value))
    end

    --技能排序
    local sk = nil
    local tSkc, skill = hdb.skc, atkH.skill
    if btyp ~= 0 then atkH:SortSkill(tSkc) end
    --创建技能
    t.skcItems = { }
    for i = 1, 4 do
        var = t.pnlSkc:AddChild(t.itemSkc, "skc_"..i)
        var.luaBtn.luaContainer = t.body
        var:SetActive(true)
        tmp =
        {
            go = var,
            nm = var:ChildWidget("name"),
            sp = var:ChildWidget("sp"),
            cd = var:ChildWidget("flag"),
        }
        t.skcItems[i] = tmp
        if isAutoFight then
            var:DesCmp(typeof(UIButton))
            var:GetCmp(typeof(UE.Collider)).enabled = false
        end

        sk = skill[i]
        if sk then
            tmp.nm.text = DB.GetSkc(sk.sn.value):getName()
            tmp.sp.text = tostring(sk.sp.value)

            var.luaBtn.param = i

            var = var.widget
            gridTex:Add(var:LoadTexAsync(ResName.SkillIconC(sk.sn.value)))
            var.color = _const.ColorWhite

--            var = var:ChildWidget("fe")
--            if sk.fesn > 0 then
--                var.spriteName = "tag_fe_" .. sk.fesn
--                var:SetActive(true)
--            else
--                var:SetActive(false)
--            end

            var = tmp.cd
            var.spriteName = "black"
            var.type = UIBasicSprite.Type.Filled
            var.fillDirection = UIBasicSprite.FillDirection.Radial360
            var.fillAmount = 1
            var.width, var.height = 64, 64
            var.color = _const.ColorBlack
            var.alpha = 0.6
            var.cachedTransform.localPosition = _const.V3Zero
        else
            sk = tSkc[i]
            if sk and sk > 0 then
                sk = DB.GetSkc(sk)
                tmp.nm.text = sk:getName()
                tmp.nm.color = _const.ColorGray
                tmp.sp.text = tostring(sk.sp)
                tmp.sp.color = _const.ColorGray

                if not isAutoFight then var:GetCmp(typeof(UE.Collider)).enabled = false end
--                var:Child("fe"):SetActive(false)

                var = var.widget
                gridTex:Add(var:LoadTexAsync(ResName.SkillIconC(sk.sn)))
                var.color = _const.ColorGray

                var = tmp.cd
                var.spriteName = "sp_lock_2"
                var.type = UIBasicSprite.Type.Simple
                var.width, var.height = 40, 40
                var.color = _const.ColorWhite
                var.alpha = 1
                var.cachedTransform.localPosition = _const.V3Zero
            else
                tmp.nm:SetActive(false)
                tmp.sp:SetActive(false)
                tmp.cd:SetActive(false)
                if not isAutoFight then var:GetCmp(typeof(UE.Collider)).enabled = false end
--                var:Child("fe"):SetActive(false)
                gridTex:Add(var.widget:LoadTexAsync("skc_n"))
            end
        end
        tmp.go:SetActive(true)
    end

    tmp = typeof(UIGrid)
    var = t.pnlSkc:GetCmp(tmp)
    if var then
        if t.go.activeInHierarchy then var:Reposition() else var.repositionNow = true end
    end

    t.atkBuffs[1].cachedTransform.parent:GetCmp(tmp).repositionNow = true
    t.defBuffs[1].cachedTransform.parent:GetCmp(tmp).repositionNow = true

    --创建副将技
    if atkDh and atkDh.skillQty > 0 then
        t.atkSkdItems = { }
        for i, sk in ipairs(atkDh.skill) do
            var = t.atkSkd:AddChild(t.itemSkd, "skd_"..i)
            tmp =
            {
                go = var,
                qty = var:ChildWidget("qty"),
                cd = var:ChildWidget("flag"),
            }
            t.atkSkdItems[i] = tmp
            tmp.qty.text = "[b]"..sk.curQty.value.."/"..sk.qty.value
            var.luaBtn.param = sk
            var = var.widget
            gridTex:Add(var:LoadTexAsync(ResName.SkillIconD(sk.sn.value)))
            var.color = _const.ColorWhite
            tmp.go:SetActive(true)
        end
        t.atkSkd:GetCmp(typeof(UIGrid)).repositionNow = true
    end
    if defDh and defDh.skillQty > 0 then
        t.defSkdItems = { }
        for i, sk in ipairs(defDh.skill) do
            var = t.defSkd:AddChild(t.itemSkd, "skd_"..i)
            tmp =
            {
                go = var,
                qty = var:ChildWidget("qty"),
                cd = var:ChildWidget("flag"),
            }
            t.defSkdItems[i] = tmp
            tmp.qty.text = "[b]"..sk.curQty.value.."/"..sk.qty.value
            var.luaBtn.param = sk
            var = var.widget
            gridTex:Add(var:LoadTexAsync(ResName.SkillIconD(sk.sn.value)))
            var.color = _const.ColorWhite
            tmp.go:SetActive(true)
        end
        t.defSkd:GetCmp(typeof(UIGrid)).repositionNow = true
    end

    --初始化BuffControl
    t.atkBuff:Init(atkH)
    t.atkBuff:Init(defH)

    if t.btnAuto.gameObject.activeSelf and user.IsUseAutoFight then AutoFight(t) end

    --添加Update
    if t.updHandle == nil then t.updHandle = UpdateBeat:CreateListener(Update, t) end
    UpdateBeat:AddListener(t.updHandle)
end
--展示上面Buf效果的协程
function _ctrl.ShowBuffEffect(t)
    coroutine.wait(1)
    local ef, e = nil, nil
    for i, v in ipairs(t.atkBuffs) do
        if i > 1 and v.activeSelf then
            if ef == nil then ef = AM.LoadPrefab("ef_hit_flash") end
            e = t.go:AddChild(ef, "ef_hit_flash")
            Destroy(e, 2.6)
            e.transform.position = v.cachedTransform.position
        end
    end
    for i, v in ipairs(t.defBuffs) do
        if i > 1 and v.activeSelf then
            if ef == nil then ef = AM.LoadPrefab("ef_hit_flash") end
            e = t.go:AddChild(ef, "ef_hit_flash")
            Destroy(e, 2.6)
            e.transform.position = v.cachedTransform.position
        end
    end

    coroutine.wait(0.1)

    for i, v in ipairs(t.atkBuffs) do
        if i > 0 and v.activeSelf then
            v:SetEnable(true)
        end
    end
    for i, v in ipairs(t.defBuffs) do
        if i > 0 and v.activeSelf then
            v:SetEnable(true)
        end
    end
end
--隐藏守方特写
local function HideEnemyView(v) v:SetActive(false) end
--显示守方特写
function _ctrl.ShowEnemyView(t)
    if Mathf.Abs(t.go.transform:InverseTransformPoint(t.map.defHero.trans.position).x) > 450 then
        t.defView:SetActive(true)
        Invoke(HideEnemyView, 3, false, t.defView)
    end
end

--按下地图(调试时暂停)
function _ctrl.PressMap(t, pressed) t.map.pause = pressed end

--点击加速
function _ctrl.ClickSpeed(t)
    if t.mapDat and t.mapDat.battle:canAccelerate() then
        local acc = not t.Accelerate
        t.Accelerate = acc
        user.IsBattleAccelerate = acc
    else
        ToolTip.ShowToolTip(string.format(L("VIP{0}开启加速功能"), t.mapDat.battle.accVip))
    end
end
--点击跳过
function _ctrl.ClickSkip(t)
    if t.mapDat and t.mapDat.battle:isAutoFight() then
        if t.mapDat:canSkipBattle() then
            t.mapDat:SkipBattle()
        else
            ToolTip.ShowToolTip(string.format(L("VIP{0}开启跳过功能"), t.mapDat.battle.skipVip))
        end
    end
end
--点击自动战斗
function _ctrl.ClickAuto(t)
    if not user.IsUseAutoFight then user.IsUseAutoFight = true
    else user.IsUseAutoFight = fasle end
    AutoFight(t)
end
--点击攻方武将头像
function _ctrl.ClickAtkHeroIcon(t) if t.map then t.map.atkHero:ClickAvatar() end end
--点击守方武将头像
function _ctrl.ClickDefHeroIcon(t) if t.map then t.map.defHero:ClickAvatar() end end
--点击武将技
function _ctrl.ClickSkc(t, idx)
    local md = t.mapDat
    if md and md.result == 0 and t.map.active and not md.battle:isAutoFight() then
        t.map.pause = false
        t.hero:CastSkill(idx)
    end
end
--点击副将技
--skd : EnSkd
function _ctrl.ClickSkd(t, skd)
    if skd then
        local db = DB.GetSkd(skd.sn.value)
        ToolTip.ShowToolTip(db:getName() .. "(Lv"..skd.lv.."):\n" ..db:getIntro(skd.lv))
    end
end
--按下攻方固有Buf
function _ctrl.PressAtkBuff(t, pressed, idx)
    if pressed and t.map then
        t.map.atkHero:ShowBuffTip(idx)
    else
        ToolTip.HideToolTip()
    end
end
--按下守方方固有
function _ctrl.PressDefBuff(t, pressed, idx)
    if pressed and t.map then
        t.map.defHero:ShowBuffTip(idx)
    else
        ToolTip.HideToolTip()
    end
end

--切换全体命令 进攻/待命
function _ctrl.ClickAllCmd(t)
    local md = t.mapDat
    if md and md.result == 0 and t.map.active and not md.battle:isAutoFight() then
        t.map.pause = false
        if md.atkHeroCmd == BAT_CMD.Attack and md.atkArmCmd == BAT_CMD.Attack then
            if md.battle.type.value == 1 then
                if user.gmMaxCity < 3 and md.battle.sn < 4 and md.atkArmCmd == BAT_CMD.Attack then
                    md:SetAtkHeroCmd(BAT_CMD.Wait)
                    md:SetAtkArmCmd(BAT_CMD.Attack)
                    ToolTip.ShowToolTip(L("我军兵锋正盛，正可一举冲破敌阵"))
                    return
                elseif user.gmMaxCity == 3 and md.battle.sn == 4 then
                    md:SetAtkHeroCmd(BAT_CMD.Attack)
                    md:SetAtkArmCmd(BAT_CMD.Attack)
                    t.btnAll:ChildWidget("state").spriteName = "sp_stop"
                    t.btnArm:ChildWidget("state").spriteName = "sp_stop"
                    t.btnHero:ChildWidget("state").spriteName = "sp_stop"
                    return
                end
            end
            md:SetAtkHeroCmd(BAT_CMD.Wait)
            md:SetAtkArmCmd(BAT_CMD.Wait)
            t.btnAll:ChildWidget("state").spriteName = "sp_start"
            t.btnArm:ChildWidget("state").spriteName = "sp_start"
            t.btnHero:ChildWidget("state").spriteName = "sp_start"
        else
            if md.battle.type.value == 1 then
                if user.gmMaxCity < 3 and md.battle.sn < 4 and md.atkArmCmd == BAT_CMD.Attack then
                    md:SetAtkHeroCmd(BAT_CMD.Wait)
                    md:SetAtkArmCmd(BAT_CMD.Attack)
                    ToolTip.ShowToolTip(L("我军兵锋正盛，正可一举冲破敌阵"))
                    return
                end
            end
            md:SetAtkHeroCmd(BAT_CMD.Attack)
            md:SetAtkArmCmd(BAT_CMD.Attack)
            t.btnAll:ChildWidget("state").spriteName = "sp_stop"
            t.btnArm:ChildWidget("state").spriteName = "sp_stop"
            t.btnHero:ChildWidget("state").spriteName = "sp_stop"
            BGM.PlaySOE("sound_assault")
        end
    end
end
--切换武将命令
function _ctrl.ClickHeroCmd(t)
    local md = t.mapDat
    if md and md.result == 0 and t.map.active and not md.battle:isAutoFight() then
        if md.atkHeroCmd == BAT_CMD.Attack then
            if md.battle.type.value == 1 and user.gmMaxCity == 3 and md.battle.sn == 4 then
                ToolTip.ShowToolTip(L("猛将之道，勇往直前"))
                return
            end
            md:SetAtkHeroCmd(BAT_CMD.Wait)
            t.btnAll:ChildWidget("state").spriteName = "sp_start"
            t.btnHero:ChildWidget("state").spriteName = "sp_start"
        else
            if md.battle.type.value == 1 and user.gmMaxCity == 2 and md.battle.sn == 3 then
                ToolTip.ShowToolTip(L("统帅之道，用兵为上"))
                return
            end
            md:SetAtkHeroCmd(BAT_CMD.Attack)
            if md.atkArmCmd == BAT_CMD.Attack then t.btnAll:ChildWidget("state").spriteName = "sp_stop" end
            t.btnHero:ChildWidget("state").spriteName = "sp_stop"
        end
        t.map.pause = false
    end
end
--切换士兵命令 进攻/待命
function _ctrl.ClickArmCmd(t)
    local md = t.mapDat
    if md and md.result == 0 and t.map.active and not md.battle:isAutoFight() then
        if md.atkArmCmd == BAT_CMD.Attack then
            if md.battle.type.value == 1 and user.gmMaxCity < 3 and md.battle.sn < 4 then
                ToolTip.ShowToolTip(L("我军兵锋正盛，正可一举冲破敌阵"))
                return
            end
            md:SetAtkArmCmd(BAT_CMD.Wait)
            t.btnAll:ChildWidget("state").spriteName = "sp_start"
            t.btnArm:ChildWidget("state").spriteName = "sp_start"
        else
            md:SetAtkArmCmd(BAT_CMD.Attack)
            if md.atkHeroCmd == BAT_CMD.Attack then t.btnAll:ChildWidget("state").spriteName = "sp_stop" end
            t.btnArm:ChildWidget("state").spriteName = "sp_stop"
            BGM.PlaySOE("sound_assault")
        end
        t.map.pause = false
    end
end
--撤退
function _ctrl.ClickRetreat(t)
    local md = t.mapDat
    if md and md.result == 0 and t.map.active and not md.battle:isAutoFight() then
        if md.battle.type.value == 1 and user.gmMaxCity < CONFIG.T_LEVEL then
            ToolTip.ShowToolTip(L("我军兵锋正盛，正可一举冲破敌阵"))
            return
        end
        md:SetAtkHeroCmd(BAT_CMD.Retreat)
        md:SetAtkArmCmd(BAT_CMD.Retreat)
        t.btnAll:ChildWidget("state").spriteName = "sp_start"
        t.btnArm:ChildWidget("state").spriteName = "sp_start"
        t.btnHero:ChildWidget("state").spriteName = "sp_start"
        t.map.pause = false
    end
end

