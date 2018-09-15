
local math = math
local Mathf = Mathf
local SpringLerp = NGUIMath.SpringLerp
local notnull = notnull
local STATUS = QYBattle.BD_CombatUnit.STATUS
local BE_Type = QYBattle.BE_Type
local TW_Style = UITweener.Style
local HitWordEffect = HitWordEffect

local _const = 
{
    ColorWhite = Color.white,
    ColorCyan = Color.cyan,

    ColorCure1 = Color(0, 0.5, 0),
    ColorCure2 = Color(0.2, 1, 0.5),
    ColorMiss1 = Color(0.5, 0, 0),
    ColorMiss2 = Color(1, 0.2, 0.2),
    ColorDodge1 = Color(0, 0.5, 0),
    ColorDodge2 = Color(0.2, 1, 0.5),
    ColorCrit1 = Color(1, 0, 0),
    ColorCrit1P = Color(1, 1, 0),
    ColorCrit2 = Color(1, 1, 0),
    ColorDmg1 = Color(0.5, 0, 0),
    ColorDmg1P = Color(0.5, 0.8, 0),
    ColorDmg2 = Color(1, 0.2, 0.2),

    ColorEnergyUp1 = Color(0, 0.2, 0.5),
    ColorEnergyUp2 = Color(0.4, 0.77, 0.1),
    ColorEnergyDown1 = Color(0, 0.125, 0.25),
    ColorEnergyDown2 = Color(0.0625, 0.25, 0.5),

    V3Zero = Vector3.zero,
    V3Y180 = Vector3(0, 180, 0),

    V4Shield = Vector4(0, 0, 1, 1)
}

local _base = BU_Unit
local _hero = class(_base)
--[Comment]
--战场显示单位-武将
BU_Hero = _hero

function _hero.ctor(h, map, go)
    _base.ctor(h, map, go)
    h.enabled = false
    
    local srf = go:GetCmp(typeof(NGUISerializeRef)).ref
    h.body, h.anim = srf.body, srf.anim
    h.horse, h.horseAnim = srf.horse, srf.horseAnim
    h.shadow, h.halo, h.audio = srf.shadow, srf.halo, srf.audioSource

    h.labName, h.avatar, h.labPow = srf.labName,srf.avatar, srf.labPower
    h.labArm, h.proHP, h.labHP, h.proShield = srf.labSoldiers, srf.proHP, srf.labHP, nil
    h.proSP, h.labSP = srf.proSP, srf.labSP
    h.star = nil

    h.lastPos = Vector2.zero
    h.lastMoveSpeed = 0
    h.moveActionTime = 1.368
    h.lastDirection = 0

    h.lastStatus = STATUS.Think

    h.animHeroName = ""
    h.animHorseName = ""

    h.lastHP, h.lastSP, h.lastShield = 0, 0, 0
    h.animHP, h.animSP, h.animShield = 0, 0, 0
    h.animFlag = false

    h.shieldActive = false

    if isDebug then
        h.showExtInfo = true
    end
end

local function UpdatePower(h)
    h.labPow.text = string.format("[c8bb95]武力:[-][9abcd1]%-8d[-][c8bb95]智力:[-][9abcd1]%-8d[-][c8bb95]统帅:%d[-]", h.dat.Str, h.dat.Wis, h.dat.Cap)
    h.labArm.text = string.format("[c8bb95]兵力:[-][9abcd1]%s/%s[-]", h.dat.TP, h.dat.MaxTP)
end

local function PlayAction(h, act, time, style, force)
    if h.anim then
        if force or not h.anim:IsPlay(act) then
            h.anim:Play(h.animHeroName, act, time, style)
            if h.horseAnim then
                h.horseAnim:Play(h.animHorseName, act, time, style)
            end
        else
            h.anim.time = time
            if h.horseAnim then
                h.horseAnim.time = time
            end
        end
    end
end

function _hero.Init(h, dat)
    assert(dat and getmetatable(dat) == QYBattle.BD_Hero, "Init dat must be BD_Hero")
    h.dat = dat
    dat.body = h
    h.enabled = true
    h.body.color = dat.isAtk and _const.ColorWhite or _const.ColorCyan

    local var = dat.pos
    h.lastPos:Set(var.x, var.y)
    h.trans.localPosition = h.map:GetPosV2(h.lastPos)

    var = h.map:GetDepth(var.y)
    h.depth = var
    h.body.depth = var
    h.horse.depth = var - 1

    var = DB.GetHero(dat.dat.dbsn.value)
    h.animHeroName = "hb_"..var.body.."_"
    h.animHorseName = "hh_"..var.horse.."_"

    h.lastDirection = dat.direction
    h.trans.localEulerAngles = h.lastDirection < 0 and _const.V3Y180 or _const.V3Zero

    h.lastHP, h.lastSP, h.lastShield = dat.HP, dat.SP, dat.Shield
    h.animHP, h.animSP, h.animShield = h.lastHP, h.lastSP, h.lastShield

--    var = DB_HeroStar.GetStar(dat.dat.star)
--    if var > 0 then
--        h.star.spriteName = "hero_star_"..var
--        h.star:SetActive(true)
--    else
--        h.star:SetActive(false)
--    end

    h.shieldActive = false
    if notnull(h.shieldEffect) then h.shieldEffect:SetActive(false) end

    h.animFlag = true

    PlayAction(h, "idle", 1, TW_Style.PingPong)
    h:ShowBody()
    h:Update()
end

function _hero.Dispose(h)
    if h.dat then
        h.enabled = false
        if h.dat.body == h then h.dat.body = nil end
        h.dat = nil
        h.lastPos:Set(0, 0)
        h.lastMoveSpeed = 0
        h.lastDirection = 0
        h.lastStatus = STATUS.Think
        h.shieldActive = false
        if notnull(h.shieldEffect) then Destroy(h.shieldEffect) end
        h.shieldEffect = nil
        if h.anim then h.anim:Stop() end
    end
end

function _hero.Destruct(h, delay)
    if delay and delay > 0 then
        _base.Destruct(h, delay)
    else
        h:Dispose()
    end
end

local function EqualPos(a, b)
    return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) < 9.999999e-11
end

function _hero.Update(h)
    local dat = h.dat
    if h.enabled then
        local var
        if dat.isAlive then
            if h.lastDirection ~= dat.direction then
                h.lastDirection = dat.direction
                h.trans.localEulerAngles = h.lastDirection < 0 and _const.V3Y180 or _const.V3Zero
            end
            if dat.status == STATUS.Move or not EqualPos(h.lastPos, dat.pos) then
                h.lastPos:Set(dat.pos.x, dat.pos.y)
                h.trans.localPosition = h.map:GetPosV2(h.lastPos)
                --深度不改变
                var = dat.MoveSpeed
                if h.lastMoveSpeed ~= var then
                    h.lastMoveSpeed = var
                    if var > 0 then
                        h.moveActionTime = 1.368 / var
                    end
                end
                if var > 0 then
                    PlayAction(h, "move", h.moveActionTime, TW_Style.Loop)
                else
                    PlayAction(h, "idle", 1, TW_Style.PingPong)
                end
                h.lastStatus = STATUS.Move
            elseif dat.status ~= STATUS.Think then
                h.lastStatus = dat.status
            elseif h.lastStatus ~= STATUS.Think then
                h.lastStatus = STATUS.Think
            else
                PlayAction(h, "idle", 1, TW_Style.PingPong)
            end
        else
            h.enabled = false
            PlayAction(h, "die", 0.7, TW_Style.Once)
            h.audio:PlayOneShot(AM.LoadAudioClip(dat.sex.value == 2 and ("sound_death_famale_"..math.floor(math.random(5.999))) or ("sound_death_male_"..math.floor(math.random(3.999)))), BGM.soeVolume)
        end

        local evts = dat:GetEvents()
        if evts then
            for _, e in ipairs(evts) do
                var = e.type
                if var == BE_Type.DPS then
                    var = e.dat
                    if var.isCure then
                        HitWordEffect.Begin(h.trans, "+" .. var.value, _const.ColorCure1, _const.ColorCure2, BU_Map.SkillHeadDepth)
                    elseif var.isMiss then
                        var = var.source.body
                        if notnull(var) then
                            HitWordEffect.Begin(var.trans, "未命中", _const.ColorMiss1, _const.ColorMiss2, BU_Map.SkillHeadDepth)
                        end
                    elseif var.dodge then
                        HitWordEffect.Begin(h.trans, "闪", _const.ColorDodge1, _const.ColorDodge2, BU_Map.SkillHeadDepth)
                    elseif var.isCrit then
                        HitWordEffect.Begin(h.trans, (var.isBlock and "档 -" or "-") .. var.value, var.puncture and var.puncture > 0 and _const.ColorCrit1P or _const.ColorCrit1, _const.ColorCrit2, BU_Map.SkillHeadDepth)
                    else
                        HitWordEffect.Begin(h.trans, (var.isBlock and "档 -" or "-") .. var.value, var.puncture and var.puncture > 0 and _const.ColorDmg1P or _const.ColorDmg1, _const.ColorDmg2, BU_Map.SkillHeadDepth)
                    end
                elseif var == BE_Type.CastSkill then
                    if dat.isAlive then PlayAction(h, "atk1", 0.8, TW_Style.Once, true) end
                elseif var == BE_Type.Attack then
                    if dat.isAlive then
                        PlayAction(h, e.dat and "atk3" or ("atk" .. (math.floor(math.random(1.999)))), dat.MSPA * 0.001, TW_Style.Once, true)
                        h.audio:PlayOneShot(AM.LoadAudioClip("sound_slashing"), BGM.soeVolume)
                    end
                elseif var == BE_Type.Energy then
                    if e.dat > 0 then
                        HitWordEffect.Begin(h.trans, "+" .. e.dat, _const.ColorEnergyUp1, _const.ColorEnergyUp2, BU_Map.SkillHeadDepth)
                    else
                        HitWordEffect.Begin(h.trans, tostring(e.dat), _const.ColorEnergyDown1, _const.ColorEnergyDown2, BU_Map.SkillHeadDepth)
                    end
                elseif var == BE_Type.BuffAdd then
                    var = e.dat
                    if var then
                        if var.isStop then
                            h:AddStunEffect(var.leftSecond)
                        elseif var.isBleed then
                            h:AddBleedEffect(var.leftSecond)
                        end
                    end
                end
            end
        end
    end

    if dat then
        var = dat.HP
        if h.lastHP ~= var then
            h.animFlag = true
            h.lastHP = var
        end
        var = dat.SP
        if h.lastSP ~= var then
            h.animFlag = true
            h.lastSP = var
        end
        var = dat.Shield
        if h.lastShield ~= var then
            h.animFlag = true
            h.lastShield = var
        end

        if dat.infoChanged then
            dat.infoChanged = false
            UpdatePower(h)
        end

        if h.animFlag then
            local delta = Time.deltaTime

            if h.animHP ~= h.lastHP then
                var = SpringLerp(h.animHP, h.lastHP, 13, delta)
                if Mathf.Approximately(h.animHP, var) or Mathf.Abs(var - h.lastHP) < 1 then
                    h.animHP = h.lastHP
                else
                    h.animHP = var
                    h.animFlag = true
                end
            end
            if h.animSP ~= h.lastSP then
                var = SpringLerp(h.animSP, h.lastSP, 13, delta)
                if Mathf.Approximately(h.animSP, var) or Mathf.Abs(var - h.lastSP) < 1 then
                    h.animSP = h.lastSP
                else
                    h.animSP = var
                    h.animFlag = true
                end
            end
            if h.animShield ~= h.lastShield then
                var = SpringLerp(h.animShield, h.lastShield, 13, delta)
                if Mathf.Approximately(h.animShield, var) or Mathf.Abs(var - h.lastShield) < 1 then
                    h.animShield = h.lastShield
                else
                    h.animShield = var
                    h.animFlag = true
                end
            end

            var = dat.MaxSP
            h.labSP.text = (math.floor(h.animSP)) .. "/" .. var
            h.proSP.value = h.animSP / var

            if h.animShield > 0 then
                var = Mathf.Max(h.animHP + h.animShield, dat.MaxHP)
                h.labHP.text = (math.floor(h.animHP)) .. "/" .. var
                local val = h.animHP / var
                h.proHP.value = val
                _const.V4Shield.x = val
                _const.V4Shield.z = val + (h.animShield / var)
--                h.proShield.drawRegion = _const.V4Shield
--                h.proShield.enabled = true
            else
                var = dat.MaxHP
                h.labHP.text = (math.floor(h.animHP)) .. "/" .. var
                h.proHP.value = h.animHP / var
--                h.proShield.enabled = false
            end
        end

        if h.lastShield > 0 then
            if not h.shieldActive then
                h.shieldActive = true
                if notnull(h.shieldEffect) then
                    h.shieldEffect:SetActive(true)
                else
                    h.shieldEffect = h.go:AddChild(AM.LoadPrefab("ef_skc_shield"), "ef_skc_shield")
                    if h.shieldEffect then h.shieldEffect:SetActive(true) end
                end
            end
        elseif h.shieldActive then
            h.shieldActive = false
            if notnull(h.shieldEffect) then h.shieldEffect:SetActive(false) end
        end
    end
end

function _hero.ShowBody(h)
    h.body.enabled = true
    h.horse.enabled = true
end
function _hero.HideBody(h)
    h.body.enabled = false
    h.horse.enabled = false
end



function _hero.ClickAvatar(h)
    if isDebug then
        h.showExtInfo = not h.showExtInfo
        UpdatePower(h)
    end
    h.map.view:MoveTo(h.trans)
end

local _bufTipFunc = 
{
    --军师技
    [1] = function(h) ToolTip.ShowToolTip(DB.GetSkt(h.dat.SktSN):getIntro()) end,
    --觉醒技
    [2] = function(h)
        h = h.dat.dat
        local ske = h.evoSkill.value
        if ske > 0 then
            ToolTip.ShowToolTip(DB.GetSke(ske):getIntro(h.evo.value))
        end
    end,
    --锦囊技
    [3] = function(h)
        h = h.dat
        local skp = h.SkpSN
        if skp > 0 then
            skp = DB.GetSkp(skp)
            h = h.SkpLv
            ToolTip.ShowToolTip(skp:getName().."(Lv"..h.."):"..skp:getIntro(h))
        end
    end,
    --副将
    [4] = function(h)
        h = h.dat.dehero
        if h and h.dbsn > 0 then
            ToolTip.ShowToolTip(ColorStyle.Rare(DB.GetDehero(h.dbsn):getName(), h.star) .. "(Lv" .. h.lv .."):" .. DB.GetAttsWord(h.extAtt))
        end
    end,
    --阵形铭刻
    [5] = function(h) ToolTip.ShowToolTip(L("阵形铭刻")..":"..DB.GetAttsWord(h.dat.lnpImp)) end,
    --名将谱
    [6] = function(h) ToolTip.ShowToolTip(L("名将谱")..":"..DB.GetAttsWord(h.dat.battle:GetHeroAtlas(h.dat.isAtk))) end,
    --联盟科技
    [7] = function(h) ToolTip.ShowToolTip(L("联盟科技")..":"..DB.GetAttsWord(h.dat.battle:GetAllyTech(h.dat.isAtk))) end,
--    --铜雀台
--    [8] = function(h)
--        h = h.dat
--        h = h.isAtk and h.battle.atkBeauty or h.battle.defBeauty
--        if h and h.sn > 0 then
--            ToolTip.ShowToolTip(DB.GetBeauty(h.sn):getName().."-"..L("结缘技")..":"..DB.GetAttsWord(h.extAtt))
--        end
--    end,
    --地宫房间buff
    [11] = function(h)
        h = h.dat.dat
        local buf = DB.Get(LuaRes.Palace_Att)
        buf = buf[h.gveBuff.value]
        ToolTip.ShowToolTip(L("地宫BUff")..":\n"..string.format(buf.info, buf.buffAtt[1][2]))
     end,
    --地宫陷阱buff
    [12] = function(h) 
        local buf = DB.Get(LuaRes.Palace_Trap)
        buf = buf[h.dat.battle.gveTrap.value]
        ToolTip.ShowToolTip(L("地宫陷阱")..":\n"..string.format(buf.info, buf.vals))
    end,
    --兵种buff
    [13] = function(h)
        
    end,
}

function _hero.ShowBuffTip(h, idx)
    local func = _bufTipFunc[idx]
    if func then
        func(h)
    else
        h = h.dat
        idx = h.battle:GetPropsSn(h.isAtk, idx - 8)
        if idx then ToolTip.ShowPropTip(DB.GetProps(idx):getPropTip()) end
    end
end