
local notnull = notnull
local STATUS = QYBattle.BD_CombatUnit.STATUS
local BE_Type = QYBattle.BE_Type
local TW_Style = UITweener.Style

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

    V3Zero = Vector3.zero,
    V3Y180 = Vector3(0, 180, 0),
}

local _base = BU_Unit
local _so = class(_base)
--[Comment]
--战场显示单位-士兵
BU_Soldier = _so

function _so.ctor(s, map, go)
    _base.ctor(s, map, go)
    s.enabled = false
    
    local srf = go:GetCmp(typeof(NGUISerializeRef)).ref
    s.body, s.anim, s.shadow = srf.body, srf.anim, nil

    s.lastPos = Vector2.zero
    s.lastMoveSpeed = 0
    s.moveActionTime = 1.368
    s.lastDirection = 0

    s.lastStatus = STATUS.Think
    s.lastBelong = true

    s.animName = ""
end

local function PlayAction(s, act, time, style, force)
    local anim = s.anim
    if anim then
        if force or not anim:IsPlay(act) then
            anim:Play(s.animName, act, time, style)
        else
            anim.time = time
        end
    end
end

function _so.Init(s, dat)
    assert(dat and getmetatable(dat) == QYBattle.BD_Soldier, "Init dat must be BD_Soldier")
    s.dat = dat
    dat.body = s
    s.enabled = true

    local var = dat.pos
    s.lastPos:Set(var.x, var.y)
    s.lastBelong = dat.isAtk
    s.lastDirection = dat.direction

    s.trans.localPosition = s.map:GetPosV2(var)
    s.trans.localEulerAngles = s.lastDirection < 0 and _const.V3Y180 or _const.V3Zero

    var = s.map:GetDepth(var.y)
    s.depth = var
    s.body.depth = var
    s.body.color = s.lastBelong and _const.ColorWhite or _const.ColorCyan
--    s.body.cachedTransform.localPosition = DB.GetArmOffset(s.dat.sn)

--    var = s.shadow:GetCmp(typeof(TweenAlpha))
--    if var then Destroy(var) end
--    s.shadow.alpha = 1

    s.animName = "sob_"..s.dat.sn.."_"
    PlayAction(s, "idle", 1, TW_Style.PingPong)
    s:Update()
end

function _so.Dispose(s)
    if s.dat then
        s.enabled = false
        if s.dat.body == s then s.dat.body = nil end
        s.dat = nil
        s.lastPos:Set(0, 0)
        s.lastMoveSpeed = 0
        s.lastDirection = 0
        s.lastStatus = STATUS.Think
        s.lastBelong = true
        s.animName = ""
    end
end

local function EqualPos(a, b)
    return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) < 9.999999e-11
end
local xxxxx
function _so.Update(s)
    if s.enabled then
        local var
        local dat = s.dat
        if dat.isAlive then
            var = dat.isAtk
            if s.lastBelong ~= var then
                s.lastBelong = var
                s.go.name = var and string.gsub(s.go.name, "def", "atk") or string.gsub(s.go.name, "atk", "def")
                s.body.color = var and _const.ColorWhite or _const.ColorCyan
            end
            var = dat.direction
            if s.lastDirection ~= var then
                s.lastDirection = var
                s.trans.localEulerAngles = var < 0 and _const.V3Y180 or _const.V3Zero
            end
            var = dat.pos
            if dat.status == STATUS.Move or not EqualPos(s.lastPos, var) then
                s.lastStatus = STATUS.Move
                s.lastPos:Set(var.x, var.y)
                s.trans.localPosition = s.map:GetPosV2(var)
                var = s.map:GetDepth(var.y)
                s.depth = var
                s.body.depth = var

                var = dat.MoveSpeed
                if s.lastMoveSpeed ~= var then
                    s.lastMoveSpeed = var
                    if var > 0 then
                        s.moveActionTime = 1.368 / var
                    end
                end
                if var > 0 then
                    PlayAction(s, "move", s.moveActionTime, TW_Style.Loop)
                else
                    PlayAction(s, "idle", 1, TW_Style.PingPong)
                end
            elseif dat.status ~= STATUS.Think then
                s.lastStatus = dat.status
            elseif s.lastStatus ~= STATUS.Think then
                s.lastStatus = STATUS.Think
            else
                PlayAction(s, "idle", 1, TW_Style.PingPong)
            end
        else
            s.enabled = false
            s:Destruct(1)
            PlayAction(s, "die", 0.7, TW_Style.Once)
            var = TweenAlpha.Begin(s.go, 0.3, 0)
            var.delay = 0.7
            var.ignoreTimeScale = false
        end

        local evts = dat:GetEvents()
        if evts then
            for _, e in ipairs(evts) do
                var = e.type
                if var == BE_Type.Attack then
                    if dat.isAlive then
                        PlayAction(s, "atk", dat.MSPA * 0.001, TW_Style.Once, true)
                    end
                elseif var == BE_Type.BuffAdd then
                    var = e.dat
                    if var then
                        if var.isStop then
                            s:AddStunEffect(var.leftSecond)
                        elseif var.isBleed then
                            s:AddBleedEffect(var.leftSecond)
                        end
                    end
                elseif var == BE_Type.DPS and isDebug then
                    var = e.dat
                    if var.isCure then
                        HitWordEffect.Begin(s.trans, "+" .. var.value, _const.ColorCure1, _const.ColorCure2, BU_Map.SkillHeadDepth).transform.localScale = Vector3.one * 0.5
                    elseif var.isMiss then
                        var = var.source.body
                        if notnull(var) then
                            HitWordEffect.Begin(var.trans, "未命中", _const.ColorMiss1, _const.ColorMiss2, BU_Map.SkillHeadDepth).transform.localScale = Vector3.one * 0.5
                        end
                    elseif var.dodge then
                        HitWordEffect.Begin(s.trans, "闪", _const.ColorDodge1, _const.ColorDodge2, BU_Map.SkillHeadDepth).transform.localScale = Vector3.one * 0.5
                    elseif var.isCrit then
                        HitWordEffect.Begin(s.trans, (var.isBlock and "档 -" or "-") .. var.value, var.puncture and var.puncture > 0 and _const.ColorCrit1P or _const.ColorCrit1, _const.ColorCrit2, BU_Map.SkillHeadDepth).transform.localScale = Vector3.one * 0.5
                    else
                        HitWordEffect.Begin(s.trans, (var.isBlock and "档 -" or "-") .. var.value, var.puncture and var.puncture > 0 and _const.ColorDmg1P or _const.ColorDmg1, _const.ColorDmg2, BU_Map.SkillHeadDepth).transform.localScale = Vector3.one * 0.5
                    end
                end
            end
        end
    end
end