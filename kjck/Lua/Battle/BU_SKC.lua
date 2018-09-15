
local Screen = UnityEngine.Screen
local isnull = tolua.isnull
local _math = Mathf
local rd = math.random
local insert = table.insert

local _base = BU_Unit

local _skc = class(_base)
BU_SKC = _skc


local FullSkill_DuWu = "ef_skc_full_duwu"
local FullSkill_HuaBan = "ef_skc_full_huaban"
local FullSkill_Ice = "ef_skc_full_ice"
local FullSkill_LeiDian = "ef_skc_full_leidian"
local FullSkill_LeiDian2 = "ef_skc_full_leidian2"
local FullSkill_ShengGuang = "ef_skc_full_shengguang"
local FullSkill_ZhiLiao = "ef_skc_full_zhiliao"
local FullSkill_SuDuXian = "ef_skc_full_suduxian"
local FullSkill_Fire = "ef_skc_fire"
local FullSkill_Fire2 = "ef_skc_full_fire2"
local FullSkill_Snow = "ef_skc_full_fengxue"

--region ----------- 通用 Object 处理函数 -----------

local function BuildWidget(s, tp, prt, pfb, nm, dp, tm, scale)
    tm = tm or 0
    local go = prt:AddChild(pfb, nm)
    if scale then go.transform.localScale = Vector3.one * 1.3 * scale
    else go.transform.localScale = Vector3.one * 1.3 end
    insert(s.objs, go)
    local t = go:GetCmp(tp)
    t.depth = dp
    if tm > 0 then
        local ta = EF.Alpha(go, 0.3, 0)
        ta.ignoreTimeScale = false
        ta.delay = tm - 0.2
        Destroy(go, tm + 0.04)
    end
    return t
end

local function BuildCopy(s, wdt, prt, scale)
    local cp = nil
    if s and wdt and prt then
        cp = prt:AddWidget(typeof(UICopy), wdt.gameObject.name)
        insert(s.objs, cp.cachedGameObject)
        cp.copy = wdt
        cp.cachedTransform.localPosition = wdt.cachedTransform.localPosition
        if scale then cp.cachedTransform.localScale = wdt.cachedTransform.localScale * scale
        else cp.cachedTransform.localScale = wdt.cachedTransform.localScale end
        cp.depth = wdt.depth
        local wd = wdt:GetCmp(typeof(BindSkillDepth))
        if wd then cp.cachedGameObject:AddCmp(typeof(BindSkillDepth)):Bind(wd.bindType, wd.offset) end
        EF.BindWidgetDepth(cp, wdt)

        prt = wdt.cachedTransform.childCount
        for i = 0, prt - 1 do
            wd = wdt.cachedTransform:GetChild(i):GetCmp(typeof(UIWidget))
            if wd then BuildCopy(s, wd, cp.cachedGameObject) end
        end
    end
    return cp
end

local function BuildObjectForPrefab(s, prt, pfb, nm, scale)
    local go = prt:AddChild(pfb, nm)
    if scale then go.transform.localScale = Vector3.one * 1.3 * scale
    else go.transform.localScale = Vector3.one * 1.3 end
    insert(s.objs, go)
    return go
end

local function BuildObject(s, prt, nm, scale)
    local go = prt:AddChild(nm)
    if scale then go.transform.localScale = Vector3.one * 1.3 * scale
    else go.transform.localScale = Vector3.one * 1.3 end
    insert(s.objs, go)
    return go
end

local function BuildSpriteAnim(s, prt, pfb, nm, dp, tm)
--    fps = fps or 24
--    loop = loop == nil and true or loop
    tm = tm or 0
--    pp = pp == nil and true or pp
    local go = prt:AddChild(pfb, nm)
    insert(s.objs, go)
    local sp = go:GetCmp(typeof(UIWidget))
    sp.depth = dp
--    local sp = go:AddCmp(typeof(UISprite))
--    sp.depth = dp
--    sp.atlas = s.atlas
--    sp.spriteName = nm.."_01"
--    sp:MakePixelPerfect()
    local spa = go:GetCmp(typeof(UISpriteAnimation))
    spa.ignoreTimeScale = false
--    spa.loop = loop
--    spa.framesPerSecond = _math.Max(1, fps)
--    spa.namePrefix = nm
--    spa.pixelPerfect = pp
    if tm > 0 or not spa.loop then
        local ta = EF.Alpha(go, 0.2, 0)
        ta.ignoreTimeScale = false
        ta.delay = tm > 0 and tm or spa.frames / spa.framesPerSecond
        Destroy(go, ta.delay + 0.24)
    end
    return sp
end

--local function BuildSprite(s, prt, nm, dp, tm)
--    local sp = prt:AddWidget(typeof(UISprite), nm)
--    insert(s.objs, sp.cachedGameObject)
--    sp.depth = dp
--    sp.atlas = s.atlas
--    sp.spriteName = nm
--    sp:MakePixelPerfect()
--    if tm > 0 then
--        local ta = EF.Alpha(sp, 0.3, 0)
--        ta.ignoreTimeScale = false
--        ta.delay = tm - 0.3
--    end
--    return sp
--end

local function AddAudioSource(go, loop)
    loop = loop == nil and false or loop
    local ads = nil
    if go then
        ads = go:AddCmp(typeof(UE.AudioSource))
        ads.minDistance = 3
        ads.volume = BGM.soeVolume
        ads.loop = loop
    end
    return ads
end

local function EffectFadeOut(ef, lifeTime)
    if ef then 
        if lifeTime < 0.3 then lifeTime = 0.3 end
        ef:Destruct(lifeTime)
        local delay = lifeTime - 0.3
        EF.Alpha(ef, 0.3, 0, delay)
    end
end

--<param name="ef"></param>
-- <param name="positive">方向 true 从释放技能的武将那边发射粒子</param>
-- <param name="lifeTime">生存时间</param>
-- <param name="isUpUI">是否在UI上层</param>
--<param name="scale">尺寸</param>
local function AddFullEffect(s, ef, positive, lifetime, isUpUI, scale)
    local go = AM.LoadPrefab(ef)
    if go then 
        go = s.map.go.transform.parent:AddChild(go)
        if go then 
            local _scale = Vector3(Screen.width/SCREEN.WIDTH, Screen.height/SCREEN.HEIGHT)
            --如果新窗口的宽增量比高增量大  则按新窗口的高来缩放
            if Screen.width / Screen.height > SCREEN.WIDTH / SCREEN.HEIGHT then
                _scale.x = _scale.x / _scale.y
                _scale.y = 1
            else
                _scale.y = _scale.y / _scale.x
                _scale.x = 1
            end
            go.transform.localScale = _scale * scale
            if lifetime > 0 then EffectFadeOut(go, 0) end
            if not positive then go.transform.localEulerAngles = Vector3(0, 180, 0) end
        end
    end

    insert(s.objs, go)
    return go
end

--添加全屏特效 不缩放
local function AddFullEffectNoAnchor(s, ef, positive, lifetime, isUpUI, scale)
    local go = AM.LoadPrefab(ef)
    if go then
        go = s.map.go.transform.parent:AddChild(go)
        if go then
            go.transform.localScale = Vector3.one * scale
            if lifetime > 0 then EffectFadeOut(go, 0) end
            if not positive then go.transform.localEulerAngles = Vector3(0, 180, 0) end
        end
    end

    insert(s.objs, go)
    return go
end
--endregion

local ShowFunc = {
--region ----------- 1 裂波斩 -----------
    [1] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local cp_a = AM.LoadAudioClip("sound_skc_1_a")
                local cp_b = AM.LoadAudioClip("sound_skc_1_b")
                local sps = { }
--                local dev = Vector3(-40, 80, 0)
                local ads = nil
                local efa = s.ef.transform:GetChild(0).gameObject
                local efb = s.ef.transform:GetChild(1).gameObject
--                local efc = s.ef.transform:GetChild(2).gameObject
                s.action = function ()
                    local tgs = s.dat:GetHitTarget()
                    if tgs ~= nil  and #tgs > 0 then
                        local tg = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                if ois(tg, BU_Hero) then
                                    tg = BuildObjectForPrefab(s, s.map.go, efb, efb.name)
                                    if sps[1] and s.map.view:IsFollow(sps[1].transform) then s.map:ViewStopFollow() end
                                else
                                    tg = BuildObjectForPrefab(s, s.map.go, efb, efb.name)
                                    tg.transform.localScale = Vector3.one * 0.6
                                end
                                if ads then ads:PlayOneShot(cp_b, BGM.soeVolume) end
                            end
                        end
                    end
                    
                    for i = 1, cnt do
                        if s.dat.units[i].status == 1 then
                            if not sps[i] then
                                sps[i] = BuildObjectForPrefab(s, s.map.go, efa, efa.name,0.8)
                                sps[i].transform.localEulerAngles = Vector3(0, s.dat.units[i].direction.x < 0 and 0 or 180, 0)
                                if i == 1 then
                                    s.ado:PlayOneShot(cp_a, BGM.soeVolume)
                                    if s.isOwn then
                                        s.map:ViewFollow(sps[1].transform)
                                        ads = AddAudioSource(sps[1].gameObject)
                                    end
                                end
                            end
                            sps[i].transform.localPosition = s.map:GetPosition(s.dat.units[i].pos.x, s.dat.units[i].pos.y)
--                            sps[i].depth = s.map:GetDepth(s.dat.units[i].pos.y) + BU_Map.SkillDepthSpace
                        elseif sps[i] then
                            Destroy(sps[i].gameObject)
                            sps[i] = nil
                        end
                    end
                    if not s.dat.isAlive then s:Destruct() end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 2 破军箭 -----------
    [2] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 or s.dat.units[1].status ~= 1 then s:Destruct()
            else
                local fef = AddFullEffect(s, FullSkill_SuDuXian, false, 0, true, 1)
                local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_2_b", BU_Map.SkillHeadDepth, 0, 0.8)
                local dev = Vector2(0, -13)
                local tmp = up.cachedTransform
                tmp.localPosition = s.map:GetPosition(s.dat.units[1].pos.x, s.dat.units[1].pos.y) + dev
                if s.dat.units[1].direction.x < 0 then
                    tmp.localEulerAngles = Vector3(0, 180, 0)
                    up:FlipHorizontal()
                end
                if s.isOwn then s.map:ViewFollow(tmp) end
                s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_2"), BGM.soeVolume)

                local cp = AM.LoadAudioClip("sound_skc_1_b")
                local vlm = BGM.soeVolume

                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(1)
                    end
                    tmp.localPosition = s.map:GetPosition(s.dat.units[1].pos.x, s.dat.units[1].pos.y) + dev
                    local tgs = s.dat:GetHitTarget()
                    local tg = nil
                    if tgs ~= nil and #tgs > 0 then
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                if ois(tg) == BU_Hero then
                                    local it = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_2_c_a", tg.depth + BU_Map.SkillHeadDepth)
                                    it.transform.localPosition = Vector3(40, 55, 0)
                                end
                                s.action = nil
                                s:Destruct(1)
                                tg:AddStunEffect(s.dat.buff.leftSecond)
                                EF.Alpha(up, 0.2, 0)
                                up = BuildWidget(s, typeof(UIParticle), tg.go, s.ef.transform:GetChild(2).gameObject, "skc_2_c", 0, 1)
                                up.cachedTransform.localPosition = Vector3(0, 45)
                                AddAudioSource(up.cachedGameObject):PlayOneShot(cp, vlm)
                                EffectFadeOut(fef, 0.5)
                                return
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 3 振奋 -----------
    [3] = function (s)
        if s.dat.step < 2 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_3"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        local kp = s.dat.dat.keepSec
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_3_a", BU_Map.SkillFootDepth)
        local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_3_b", BU_Map.SkillHeadDepth, kp)
        buf.cachedTransform.localPosition = Vector3(10000, 10000, 10000)
        if s.isOwn then s.map:ViewMoveX(s.hero_d.map:SearchUnitFocusX(s.hero_d.isAtk)) end

        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    tg = BuildCopy(s, buf, tg.go)
                    if tg.gameObject then
                        Destroy(tg.gameObject, kp + 0.3)
                        tg.cachedTransform.localPosition = Vector3.zero
                    end
                end
            end
        end
        s:Destruct(kp)
    end,
--endregion

--region ----------- 4 治疗术 -----------
    [4] = function (s)
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skc_4", BU_Map.SkillFootDepth)
        up.cachedGameObject:SetActive(false)
        coroutine.wait(0.24)
        up.cachedGameObject:SetActive(true)
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_4"), BGM.soeVolume)
        s:Destruct(3)
    end,
--endregion

--region ----------- 5 能量灌注 -----------
    [5] = function (s)
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skc_5", BU_Map.SkillFootDepth)
        up.cachedGameObject:SetActive(false)
        coroutine.wait(0.24)
        up.cachedGameObject:SetActive(true)
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_5"), BGM.soeVolume)
        s:Destruct(3)
    end,
--endregion

--region ----------- 6 绝命反击 -----------
    [6] = function (s)
        if s.dat.step < 2 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_6"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end 
        local up1 = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_6", BU_Map.SkillFootDepth)
        local up2 = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_6_b", BU_Map.SkillFootDepth, s.dat.dat.keepSec, 0.7)
        up2.transform.localPosition = Vector3(10,95,0)
        up1.cachedGameObject:SetActive(false)
        up2.cachedGameObject:SetActive(false)
        coroutine.step()
        up1.cachedGameObject:SetActive(true)
        up2.cachedGameObject:SetActive(true)
        s:Destruct(_math.Max(up1.duration * 2, s.dat.dat.keepSec))
    end,
--endregion

--region ----------- 7 气刃 -----------
    [7] = function (s)
        if s.dat.step < 2 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_7"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt > 0 then
                local sps = { }
                local units = s.dat.units
                local dev = Vector2(-45, 0)
                local ef0 = s.ef.transform:GetChild(0).gameObject
                local ef1 = s.ef.transform:GetChild(1).gameObject
                for i = 1, cnt do
                    sps[i] = BuildWidget(s, typeof(UIParticle), s.map.go, ef0, ef0.name, s.hero_v.depth)
                    sps[i].transform.localPosition = i == math.toint(cnt/2) and s.map:GetPosition(units[i].pos.x, units[i].pos.y) or s.map:GetPosition(units[i].pos.x, units[i].pos.y) + dev
                    sps[i].transform.localEulerAngles = Vector3(0, units[i].direction.x < 0 and 180 or 0, 0)
--                    sps[i].depth = s.map:GetDepth(units[i].pos.y) + BU_Map.SkillDepthSpace
                end

                s.action = function ()
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        local pt = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                pt = BuildWidget(s, typeof(UIParticle), tg.go, ef1, "skc_7_b", BU_Map.SkillHeadDepth)
                                pt = pt.cachedTransform
                                pt.localScale = ois(tg, BU_Hero) and Vector3.one or Vector3.one * rd(0.6, 0.8)
--                                pt.localPosition = ois(tg, BU_Hero) and Vector3(0, 40, 0) or Vector3(0, 30, 0)
                            end
                        end
                    end
                    tgs = s.dat.units
                    for i = 1, cnt do
                        if tgs[i].status == 1 then
                            if not isnull(sps[i]) then 
                                sps[i].cachedTransform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y) 
                                if i==2 then sps[i].transform.localPosition = sps[i].transform.localPosition + Vector3(30, 0, 0)
                                elseif i==3 then sps[i].transform.localPosition = sps[i].transform.localPosition + Vector3(-30, 0, 0) end
                            end
                        end
                    end
                    if not s.dat.isAlive then
                        for i=1, cnt do
                            if not isnull(sps[i]) then
                                EF.Alpha(sps[i].gameObject, 0.6, 0).duration = 0.1
                            end
                        end
                        s.action = nil
                        s:Destruct(1)
                    end
                end
            else s:Destruct() 
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 8 刀阵 -----------
    [8] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t < Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = 5
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if not s.dat.isAlive then s:Destruct()
        else
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local sps = { }
--                local dev = Vector3(1, 114, 0)
--                local efa = s.ef.transform:GetChild(0).gameObject
--                local efb = s.ef.transform:GetChild(1).gameObject
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(1)
                    end
                    local tgs = s.dat:GetHitTarget()
--                    if tgs and #tgs > 0 then
--                        local tg = nil
--                        for i = 1, #tgs do
--                            tg = tgs[i].body
--                            if tg then
--                                BuildWidget(s, typeof(UIParticle), tg.go, efa, "skc_8_b", tg.depth + BU_Map.SkillDepthSpace)
--                            end
--                        end
--                    end
                    tgs = s.dat.units
                    for i = 1, cnt do
                        if tgs[i].status == 1 and not sps[i] and tgs[i].time >= 0 then
                            sps[i] = BuildObjectForPrefab(s, s.map.go, s.ef, "skc_8_a", 1)
--                            sps[i].width, sps[i].height = 104, 262
                            sps[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
--                            sps[i].depth = s.map:GetDepth(tgs[i].pos.y + 0.5) + BU_Map.SkillDepthSpace
                        end
                    end
                end
            end
        end
    end,
--endregion

--region ----------- 9 连环闪电 -----------
    [9] = function (s)
        if s.dat.step < 2 then
            local t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            if s.isOwn then
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = 2
            end
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_9"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local go = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_9_a")
            go.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y) + Vector2(15,10)
            local skc_b = s.ef.transform:GetChild(1).gameObject
            s.action = function ()
                if not s.dat.isAlive then
                    s.action = nil
                    s:Destruct(1)
                end
                local tgs = s.dat:GetHitTarget()
                if tgs and #tgs > 0 then
                    local tg = nil
                    for i = 1, #tgs do
                        tg = tgs[i].body
                        if tg then
                            go = BuildObjectForPrefab(s, tg.go, skc_b, "skc_9_b")
                            go.transform.localPosition = go.transform.localPosition + Vector3(5, 30, 0)
                            if ois(tg, BU_Soldier) then go.transform.localScale = Vector3.one * 0.7 end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 10 铜墙铁壁 -----------
    [10] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_10"), BGM.soeVolume)
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_10_a", BU_Map.SkillDepthSpace)
        coroutine.wait(0.3)
        local uw = BuildWidget(s, typeof(UIWidget), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_10_b", s.hero_v.depth + BU_Map.SkillDepthSpace)
        uw.alpha = 0
        EF.Alpha(uw, 0.3, 1)
        coroutine.wait(s.dat.dat.keepSec - 0.3)
        EF.Alpha(uw, 0.2, 0).ignoreTimeScale = false
        s:Destruct(0.2)
    end,
--endregion

--region ----------- 11 漫天箭雨 | 53 箭雨 -----------
    [11] = function (s)
        local t = nil
        if s.dat.step < 2 then
            t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            if s.isOwn then
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = s.dat.dat.keepSec
            end
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_11_a"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            t = s.dat.unitQty
            if t <= 0 then s:Destruct()
            else
                s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_11_b"), BGM.soeVolume)
                local pts ={ }
--                local mina = s.hero_d.isAtk and 15 or -30
--                local maxa = s.hero_d.isAtk and 30 or -15
                local uts = nil
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(1)
                    end
                    uts = s.dat.units
                    for i = 1, t do
                        if uts[i].status == 1 and not pts[i] and uts[i].time >= 0 then
                            pts[i] = BuildObjectForPrefab(s, s.map.go, s.ef, "skc_11_"..i)
                            pts[i].transform.localPosition = s.map:GetPosition(uts[i].pos.x, uts[i].pos.y)
                            pts[i].transform.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 12 百鬼索命 -----------
    [12] = function (s)
        local map = s.map
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                map.view.lockTime = s.dat.dat.keepSec
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local go = BuildWidget(s, typeof(UIParticle), map.go, s.ef.transform:GetChild(0).gameObject, "skc_12_a",BU_Map.SkillHeadDepth)
            go:SetActive(false)
            local buf = BuildWidget(s, typeof(UIParticle), map.go, s.ef.transform:GetChild(1).gameObject, "skc_12_b", BU_Map.SkillHeadDepth)
            buf.cachedTransform.localPosition = Vector3(10000, 10000, 10000)
            
            coroutine.step()
            AddAudioSource(go):PlayOneShot(AM.LoadAudioClip("sound_skc_12_1"), BGM.soeVolume)
            go.transform.localPosition = map:GetPosition(s.dat.pos.x, s.dat.pos.y)
            go:SetActive(true)
            local tgs = nil
            local temp_arr = { }

            s.action = function ()
                if not s.dat.isAlive then
--                    Destroy(buf.cachedGameObject)
                    s.action = nil
                    s:Destruct(1)
                end
                tgs = s.dat:GetHitTarget()
                if tgs ~= nil and #tgs > 0 then
                    local tg = nil
                    for i = 1, #tgs do
                        tg = tgs[i].body
                        if tg then
                            for j=1, #temp_arr do
                                if temp_arr[j] == tgs[i] then
                                    temp_arr[j] = nil
                                    break
                                end
                            end
                        end
                        if tg ~= nil and isnull(tg.trans:FindChild("skc_12_3")) then
                            tg = BuildCopy(s, buf, tg.go)
                            tg = tg.gameObject
                            tg.name = "skc_12_3"
                            Destroy(tg, 0.2)
                            tg = tg.transform
                            tg.localPosition = Vector3.zero
                            tg.localScale = Vector3(1, 0.4, 1)
                        end
                    end

                    for i=1, #temp_arr do
                        if temp_arr[i] ~= nil and ois(temp_arr[i].body, BU_Unit) and notnull(temp_arr[i].body) then
                            local t = temp_arr[i].body.transform:FindChild("skc_12_3")
                            if t then
                                EF.Alpha(t.gameObject, 0.2, 0)
                                Destroy(t.gameObject, 0.2)
                            end
                        end
                    end
                    temp_arr = tgs
                end
                if not s.dat.isAlive then
                    go:Stop()
                    buf:Stop()
                    EF.Alpha(go.gameObject, 0.2, 0)
                    for i=1, #temp_arr do
                        if temp_arr[i] ~= nil and ois(temp_arr[i].body, BU_Unit) and notnull(temp_arr[i].body) then
                            local t = temp_arr[i].body.transform:FindChild("skc_12_3")
                            if t then
                                EF.Alpha(t.gameObject, 0.2, 0)
                                Destroy(t.gameObject, 0.2)
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end

        coroutine.wait(0.33)
    end,
--endregion

--region ----------- 13 策反 | 44 离间 -----------
    [13] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = 2
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local tgs = s.dat:GetHitTarget()
        local obj = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_13_obj", BU_Map.SkillHeadDepth)
        obj.cachedTransform.localPosition = Vector3(0, 30, 0)
        if tgs and #tgs > 0 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_13"), BGM.soeVolume)
            local sk_a = s.ef.transform:GetChild(0).gameObject
            local sk_b = s.ef.transform:GetChild(1).gameObject
            local ef = nil
            local buf = nil
            local kp = 0
            if s.dat.buff ~= nil then
                kp = s.dat.buff.leftSecond
                buf = BuildWidget(s, typeof(UIParticle), s.map.go, sk_b, "skc_44", BU_Map.SkillHeadDepth, kp)
                buf.transform.localScale = Vector3.one * 0.8
                buf.transform.localPosition = Vector3(10000, 10000, 10000)
            end
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    if ef then
                        Destroy(BuildCopy(s, ef, tg.go).gameObject, ef.duration)
                    else
                        ef = BuildWidget(s, typeof(UIParticle), tg.go, sk_a, "skc_13", BU_Map.SkillHeadDepth)
                        ef.transform.localPosition = Vector3(0, 10, 0)
                    end
                    if buf and kp > 0 then
                        tg = BuildCopy(s, buf, tg.go)
                        if tg then
                            Destroy(tg.gameObject, kp)
                            tg.transform.localPosition = Vector3.one
                        end
                    end
                end
            end
        end
        s:Destruct(1.2)
    end,
--endregion

--region ----------- 14 八卦火 -----------
    [14] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            s.ado.clip = AM.LoadAudioClip("sound_skc_14")
            s.ado.loop = true
            s.ado:Play()

            local cnt = 5
            local a = 100
            local b = 20
            local as = { }
            local sps = { }
            local dev = Vector3(0, 30, 0)
            local pos = nil
            local rotate = nil
            for i = 1, cnt do
                as[i] = 2 * (i - 1) * _math.PI / cnt
                sps[i] = BuildWidget(s, typeof(UITexture), s.hero_v.go, s.ef, "skc_14", s.hero_v.depth)
                pos = Vector3(a * _math.Cos(as[i]), b * _math.Sin(as[i]), 0)
                rotate = Vector3(0, 180*_math.Sin(as[i]), 0)
                sps[i].transform.localPosition = pos + dev
                sps[i].transform.localEulerAngles = rotate
                sps[i].depth = s.hero_v.depth + (pos.y < 0 and 1 or -1) * BU_Map.SkillDepthSpace
            end
            local da = nil
            s.action = function ()
                if not s.dat.isAlive then
                    for i = 1, cnt do EF.Alpha(sps[i], 0.2, 0).ignoreTimeScale = false end
                    s.ado:Stop()
                    s.action = nil
                    s:Destruct(1)
                end
                da = Time.deltaTime * _math.PI
                for i = 1, cnt do
                    as[i] = as[i] + da
                    pos = Vector3(a * _math.Cos(as[i]), b * _math.Sin(as[i]), 0)
                    rotate = Vector3(0, 90*_math.Cos(as[i]), 0)
                    sps[i].cachedTransform.localPosition = pos + dev
                    sps[i].transform.localEulerAngles = rotate
                    sps[i].depth = s.hero_v.depth + (pos.y < 0 and 1 or -1) * BU_Map.SkillDepthSpace
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 15 飓风术 -----------
    [15] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = s.dat.dat.keepSec + 1
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if not s.dat.isAlive or s.dat.unitQty <= 0 then s:Destruct()
        else
            local ef = s.ef.transform:GetChild(0).gameObject
            local wind = BuildObjectForPrefab(s, s.map.go, ef, ef.name)
            local wd = wind.transform
            coroutine.step()
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_15"), BGM.soeVolume)
            s.action = function ()
                if not s.dat.isAlive then
                    EF.Alpha(wind, 0.2, 0).ignoreTimeScale = false
                    s.action = nil
                    s:Destruct(1)
                end
                local t =s.dat.units
                if t[1].status == 1 then
                    wd.localPosition = s.map:GetPosition(t[1].pos.x, t[1].pos.y)
                end
            end
        end
    end,
--endregion

--region ----------- 16 伏兵 -----------
    [16] = function (s)
        if s.dat.step < 2 then
            local obj = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_16_obj", BU_Map.SkillFootDepth)
            obj.transform.localPosition = Vector3(0, 30, 0)
            local t =Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            if s.isOwn then
                s.map:ViewMoveX(s.hero_d.isAtk and s.map.width - 1 or 0)
                s.map.view.lockTime = 2
            end
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_16"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        s:Destruct()
    end,
--endregion

--region ----------- 17 水龙阵 -----------
    [17] = function (s)
        if s.dat.step < 2 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_17"), BGM.soeVolume)
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = 3
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local p = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject, "ef_skc_7_obj")
        p.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)

        local kp = s.dat.dat.keepSec
        p = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_17_b", BU_Map.SkillHeadDepth, kp)
        p.transform.localPosition = Vector3(10000, 10000, 10000)
        while s.dat.isAlive do coroutine.step() end

        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    tg = BuildCopy(s, p, tg.go)
                    Destroy(tg.gameObject, kp + 0.3)
                    tg.cachedTransform.localPosition = Vector3(0, 5, 0)
                end
            end
        end
        s:Destruct(kp + 2)
    end,
--endregion

--region ----------- 18 回春道法 -----------
    [18] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(s.hero_d.isAtk)) end
            coroutine.wait(0.15)
            local go = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject,"ef_skc_18_act")
            go.transform.localPosition = s.hero_v.go.transform.localPosition
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(s.hero_d.isAtk))
                s.map.view.lockTime = 2
            end
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_18"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local p = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_18", BU_Map.SkillHeadDepth)
            
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if ois(tg, BU_Soldier) then
                    tg = BuildCopy(s, p, tg.go)
                end
            end
        end
        s:Destruct(2)
    end,
--endregion

--region ----------- 19 奇门幻阵 -----------
    [19] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(s.hero_d.isAtk)) end
            coroutine.wait(0.15)
            local go = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject,"ef_skc_19_act")
            go.transform.localPosition = s.hero_v.go.transform.localPosition

            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = s.dat.dat.keepSec
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_19_obj", BU_Map.SkillFootDepth,s.dat.dat.keepSec, 0.8)
            up.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)

            local sk_b = s.ef.transform:GetChild(2).gameObject
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_19"), BGM.soeVolume)
            local tmp = { }
            s.action = function ()
                if not s.dat.isAlive then
                    s.action = nil
                    s:Destruct(1)
                end
                local tgs = s.dat:GetHitTarget()
                if tgs and #tgs > 0 then
                    local tg = nil
                    for i = 1, #tgs do
                        tg = tgs[i].body
                        if tg then
                            for j = 1, #tmp do
                                if tmp[j] == tgs[i] then
                                    tmp[j] = nil
                                    break
                                end
                            end
                            if not tg.go.transform:FindChild(sk_b.name) then
                                local buf = BuildObjectForPrefab(s, tg.go, sk_b, sk_b.name, 0.6)
                                if ois(tg, BU_Hero) then
                                    buf.transform.localPosition = Vector3(0, 80, 0)
                                else 
                                    buf.transform.localPosition = Vector3(0, 45, 0)
                                end
                            end
                        end
                    end
                    for i = 1, #tmp do
                        if tmp[i] ~= nil and ois(tmp[i].body, BU_Unit) and not isnull(tmp[i].body.go) then
                            tg = tmp[i].body.trans:FindChild(sk_b.name)
                            if not isnull(tg) then Destroy(tg.gameObject) end
                        end
                    end
                    tmp = tgs
                end
                if not s.dat.isAlive then
                    EF.Alpha(up.gameObject, 0.2, 1).ignoreTimeScale = false
                    for i = 1, #tmp do
                        if tmp[i] ~= nil and ois(tmp[i].body, BU_Unit) and not isnull(tmp[i].body.go) then
                            tg = tmp[i].body.trans:FindChild("skc_19_b")
                            if not isnull(tg) then Destroy(tg.gameObject) end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 20 火石雨 -----------
    [20] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = s.dat.dat.keepSec + 1
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local cp = AM.LoadAudioClip("sound_skc_20")
                local efa = s.ef.transform:GetChild(0).gameObject
                local efb = s.ef.transform:GetChild(1).gameObject
                local pts = { }
                local tms = { }
                for i=1, cnt do table.insert(tms, 0) end
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(2)
                    end
                    local tgs = s.dat.units
                    for i = 1, cnt do
                        if tgs[i].status == 1 and tgs[i].time >= 0 then
                            if pts[i] then
                                tms[i] = (tms[i] or 0) + Time.deltaTime
                                if tms[i] > 0.2 and tms[i] < 1 then
                                    tms[i] = 1
                                    s.ado:PlayOneShot(cp, BGM.soeVolume)
                                end
                            elseif tms[i] == 0 then
                                pts[i] = BuildObjectForPrefab(s, s.map.go, s.ef, s.ef.name)
                                pts[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
                                pts[i].transform.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 21 增援 -----------
    [21] = function (s)
        if s.dat.step < 2 then
            local go = BuildObjectForPrefab(s, s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_21_obj", BU_Map.SkillFootDepth)
            go.transform.localPosition = Vector3(0, 30, 0)
            local t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            if s.isOwn then
                s.map:ViewMoveX(s.hero_d.isAtk and 0 or s.map.width - 1)
                s.map.view.lockTime = 2
            end
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_21"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        s:Destruct()
    end,
--endregion

--region ----------- 22 星火燎原 -----------
    [22] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = s.dat.dat.keepSec + 1
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                s.ado.clip = AM.LoadAudioClip("sound_skc_22")
                s.ado.loop = true
                s.ado:Play()
                local sk_a = s.ef.transform:GetChild(0).gameObject
                local pts = { }
                local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_22_b", BU_Map.SkillHeadDepth)
                buf.cachedTransform.localPosition = Vector3(10000, 10000, 10000)
                local kp = s.dat.buff.leftSecond
                s.action = function ()
                    if not s.dat.isAlive then
                        if s.ado.isPlaying then s.ado:Stop() end
                        s.action = nil
                        s:Destruct(1 + kp)
                    end
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        local b = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                b = BuildCopy(s, buf, tg.go)
                                EF.Alpha(b, 0.25, 0, kp).ignoreTimeScale = false
                                Destroy(b.cachedGameObject, kp + 0.3)
                                b = b.cachedTransform
                                if ois(tg, BU_Hero) then
                                    b.localPosition = Vector3.zero
                                    b.localScale = Vector3.one * 1.2
                                else
                                    b.localPosition = Vector3(5, 0, 0)
                                    b.localScale = Vector3.one * rd(0.7, 0.94)
                                end
                            end
                        end
                    end
                    tgs = s.dat.units
                    for i = 1, cnt do
                        if tgs[i].status == 1 and tgs[i].time >= 0 then
                            if not pts[i] then
                                pts[i] = BuildWidget(s, typeof(UIParticle), s.map.go, sk_a, "skc_22_a", BU_Map.SkillHeadDepth, 0.7)
                                pts[i].cachedTransform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 23 诸葛连弩 | 36 连弩激射 -----------
    [23] = function (s)
        if s.dat.step < 2 then 
            if s.dat.sn == 23 then
                local go = BuildObjectForPrefab(s, s.hero_v.go, s.ef.transform:GetChild(1).gameObject,"ef_skc_23_a")
                go.transform.localPosition = Vector3(-50, 50, 0)
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local sk_a = s.ef.transform:GetChild(0).gameObject
--                local sk_b = (s.dat.sn == 36 and s.hero_d.dat.isStar) and s.ef.transform:GetChild(1).gameObject or nil
                s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_23"), BGM.soeVolume)
                local sps = { }
                local dev = Vector3(-50,20)
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(2)
                    end
                    local tgs = nil
--                    if s.dat.sn == 36 then
--                        tgs = s.dat:GetHitTarget()
--                        if tgs and #tgs > 0 then
--                            local tg = nil
--                            for i = 1, #tgs do
--                                tg = tgs[i].body
--                                if tg then
--                                    tg:AddStunEffect(0.5)
--                                    if sk_b and ois(tg, BU_Hero) then
--                                        BuildWidget(s, typeof(UIPaticle), s.hero_v.go, sk_b, "skc_36", BU_Map.SkillHeadDepth)
--                                    end
--                                end
--                            end
--                        end
--                    end
                    tgs = s.dat.units
                    for i = 1, cnt do
                        if tgs[i].status == 1 then
                            if tgs[i].time >= 0 then
                                if not sps[i] then
                                    sps[i] = BuildObjectForPrefab(s, s.map.go, sk_a, sk_a.name, 0.8)
                                    sps[i].transform.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                                    EF.ShakePosition(s.map.go.transform.parent, "y", 30, "time", 0.24, "islocal", true)
                                    if i == 1 and s.isOw and s.dat.sn == 36 then
                                        s.map:ViewFollow(sps[1].transform)
                                        s.map.view.lockTime = 2
                                    end
                                end
                                sps[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y) + dev
                            end
                        elseif sps[i] then
                            Destroy(sps[i].gameObject)
                            sps[i] = nil
                        end
                    end

                    tgs = s.dat:GetHitTarget()
                    if tgs ~= nil and #tgs > 0 then
                        for i=1, #tgs do
                            local tg = tgs[i].body
                            if tg then
                                if s.dat.sn == 23 then
                                    if ois(tg, BU_Hero) then
                                        s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(tg))
                                        s.map.lockTime = 1
                                    end
                                    local up = BuildWidget(s, typeof(UIParticle), tg.go, s.ef.transform:GetChild(2),"ef_skc_23_hit", BU_Map.SkillFootDepth)
                                    up.transform.localScale = ois(tg, BU_Soldier) and Vector3.one or Vector3.one * 0.7
                                    up.transform.localPosition = Vector3(0, rd(40, 60), 0)
                                else
                                    BuildObjectForPrefab(s, tg.go, s.ef.transform:GetChild(1).gameObject, "ef_skc_36_hit")
                                end
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 24 金钟罩 | 79 金钟罩 -----------
    [24] = function (s)
        if s.dat.step < 2 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_24"), BGM.soeVolume)
            local upd = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject,"skc_24_b", BU_Map.SkillFootDepth, 0, 0.8)
            upd.transform.localPosition = Vector3(0, 15, 0)
            while s.dat.step < 2 do coroutine.step() end
        end
        local kp = s.dat.dat.keepSec
        local up = BuildObjectForPrefab(s, s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_24_a")
        up.transform.localPosition = Vector3(0, 7, 0)
        up:SetActive(false)
        coroutine.step()
        up:SetActive(true)
        EF.Alpha(up.gameObject, 0.3, 0, kp)
        s:Destruct(kp + 0.3)
    end,
--endregion

--region ----------- 25 夜幕天象 -----------
    [25] = function (s)
        if s.dat.step < 2 then
            local upd = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(2).gameObject, "skc_25_c", BU_Map.DepthSpace)
            upd.transform.localPosition = Vector3(0, 15, 0)
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_25"), BGM.soeVolume)
            local kp = s.dat.buff.leftSecond
            local dark = BuildWidget(s, typeof(UISprite), s.map.go.transform.parent.gameObject, s.ef.transform:GetChild(0).gameObject, "skc_25", BU_Map.SkillSkyDepth)
            local buf = BuildWidget(s, typeof(UIParticle), s.hero_v.rival.go, s.ef.transform:GetChild(1).gameObject, "skc_25_b", BU_Map.SkillHeadDepth, kp)
            buf.transform.localPosition = Vector3(0, 80, 0)
            local so = Vector3.one * 0.8
            s.action = function ()
                if not s.dat.isAlive then
                    s.action = nil
                    EF.Alpha(dark, 0.3, 0).ignoreTimeScale = false
                    s:Destruct(1)
                end
                local tgs = s.dat:GetHitTarget()
                if tgs and #tgs > 0 then
                    local tg = nil
                    for i = 1, #tgs do
                        tg = tgs[i].body
                        if tg and ois(tg, BU_Soldier) and not tg.trans:FindChild("skc_25_b") then
                            tg = BuildCopy(s, buf, tg.go)
                            tg = tg.transform
                            tg.localPosition = Vector3(5, 65, 0)
                            tg.localScale = so
                        end
                    end
                end
            end
        else s.Destruct()
        end
    end,
--endregion

--region ----------- 26 冰封灵柩 -----------
    [26] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = 2
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local p = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_26_a")
        p.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y) + Vector3(30, 10)
        local pa = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(2).gameObject, "skc_26_c")
        pa.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
        AddAudioSource(p.transform):PlayOneShot(AM.LoadAudioClip("sound_skc_26"), BGM.soeVolume)

        while s.dat.step < 3 do coroutine.step() end
        p = s.dat.dat.keepSec
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then tg:AddFreezeEffect(p) end
            end
        end
        s:Destruct(_math.Max(1, p))
    end,
--endregion

--region ----------- 27 焚天火 | 56 悬灯火 -----------
    [27] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                s.ado.clip = AM.LoadAudioClip("sound_skc_27")
                s.ado.loop = true
                s.ado:Play()

                local ska = s.ef.transform:GetChild(0).gameObject
                local skb = s.ef.transform:GetChild(1).gameObject
                local up1 = BuildWidget(s, typeof(UIParticle), s.hero_v.go, ska, "skc_27_a", s.hero_v.depth + BU_Map.SkillFootDepth)
                coroutine.wait(0.2)
                EF.ShakePosition(s.map.go.transform.parent.gameObject, "y", 30, "time", 0.24, "islocal", true)
                AddFullEffect(s, FullSkill_Fire, false, 0, true, 1)
                local ef = BuildObjectForPrefab(s, s.hero_v.go, skb, "skc_27_b")
                ef.transform.localPosition = Vector3(0, 45, 0)
                ef.transform.localEulerAngles = s.hero_v.isAtk and Vector3(-15, 0, 0) or Vector3(-15, 180, 0)
                
                s.action = function ()
                    if not s.dat.isAlive then
                        for i=1, 3 do
                            EF.Volume(s.ado, 0.3, 0).ignoreTimeScale = false
                            s.action = nil
                            s:Destruct(1.5)
                        end
                    end
                    up1.transform.localPosition = s.hero_v.go.transform.localPosition + Vector3(0, 15, 0)
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 28 天霜破 -----------
    [28] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = s.dat.dat.keepSec + 2
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_28"))
                local ska = s.ef.transform:GetChild(0).gameObject
                local skb = s.ef.transform:GetChild(1).gameObject
                local ws = { }
                local kp = s.dat.buff.leftSecond
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(2 + kp)
                    end
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        local up = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                up = tg.trans:FindChild("skc_28_b")
                                if not isnull(up) then
                                    up = up:GetCmp(typeof(UIParticle))
                                    if up then
                                        up:Stop()
                                        up:Play()
                                    end
                                else
                                    up = BuildWidget(s, typeof(UIParticle), tg.go, skb, "skc_28_b", tg.depth + BU_Map.SkillDepthSpace, kp, 0.8)
                                    EF.BindWidgetDepth(up, tg.body, BU_Map.SkillDepthSpace)
                                    up.duration = kp
                                    up:GetCmpInChilds(typeof(UIParticle), false).duration = kp
                                end
                            end
                        end
                    end
                    tgs = s.dat.units
                    for i = 1, cnt do
                        if tgs[i].status == 1 then
                            if not ws[i] and tgs[i].time >= 0 then
                                ws[i] = BuildWidget(s, typeof(UIWidget), s.map.go, ska, "skc_28_a", 1, 0, 0.8)
                                ws[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
                                ws[i].transform.localEulerAngles  = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                                ws[i].depth = s.map:GetDepth(tgs[i].pos.y) + BU_Map.SkillDepthSpace
                                EF.ShakePosition(s.map.go.transform.parent.gameObject, "y", 10, "time", 0.2, "islocal", true, "delay", 0.1)
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 29 火狼阵 -----------
    [29] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                s.ado.loop = false
                s.ado.clip = AM.LoadAudioClip("sound_skc_29_a")
                s.ado:Play()

                local cp = AM.LoadAudioClip("sound_skc_29_b")
                local sps = { }
                local dev = Vector3(-24, 36, 0)
                local fs = 1
                local p = nil

                local efe = AddFullEffect(s, FullSkill_SuDuXian, false, 0, true, 1)

                local kp = s.dat.units
                local ef = s.ef.transform:GetChild(0).gameObject
                for i = 1, cnt do
                    sps[i] = BuildWidget(s, typeof(UIWidget), s.map.go, ef, "skc_29", s.map:GetDepth(kp[i].pos.y) + BU_Map.SkillDepthSpace, 0, 0.8)
                    p = sps[i].transform
                    p.localPosition = s.map:GetPosition(kp[i].pos.x, kp[i].pos.y) + dev
                    p.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                    p:SetActive(false)

                    if kp[i].speed < kp[fs].speed then fs = i end
                end
                if s.isOwn then s.map:ViewFollow(sps[fs].transform) end
                coroutine.wait(0.18)
                kp = s.dat.buff.leftSecond
                p = nil
                local kp2 = 0
                if s.dat.buff2 then
                    kp2 = s.dat.buff2.leftSecond
                    p = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_29_c", BU_Map.SkillDepthSpace)
                    p.transform.localPosition = Vector3(10000, 10000, 10000)
                end
                s.ado.clip = cp
                s.ado.loop = true
                s.ado:Play()
                EF.Volume(s.ado, 0.3, 0, 3).ignoreTimeScale = false

                ef = s.ef.transform:GetChild(1).gameObject
                s.action = function ()
                    if not s.dat.isAlive then
                        if s.ado.isPlaying and s.ado.enabled then s.ado:Stop() end
                        s.action = nil
                        s:Destruct(0.2 + _math.Max(kp, kp2))
                    end
                    local tgs = s.dat:GetHitTarget()
                    if tgs ~= nil and #tgs > 0 then
                        local tg = nil
                        local d = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                local usp = BuildWidget(s, typeof(UIParticle), s.map.go, ef, "skc_20_b", tg.depth + BU_Map.SkillDepthSpace)
                                d = usp.transform
                                d.localPosition = tg.trans.localPosition + (ois(tg, BU_Hero) and Vector3(s.hero_d.isAtk and -10 or 15, 60, 0) or Vector3(s.hero_d.isAtk and -5 or 20, 45, 0))
                                if not s.hero_d.isAtk then d.localEulerAngles = Vector3(0, 180, 0) end
                                if ois(tg, BU_Soldier) then tg:AddFearEffect(kp) end
                                if kp2 > 0 and p then
                                    d = BuildCopy(s, p, tg.go)
                                    EF.Alpha(d.gameObject, 0.25, 0, kp2).ignoreTimeScale = false
                                    Destroy(d.gameObject, kp2 + 0.3)
                                    if ois(tg, BU_Hero) then
                                        d.transform.localPosition = Vector3.zero
                                        d.transform.localScale = Vector3.one * 1.2
                                        if s.isOwn then s.map:ViewStopFollow() end
                                    else
                                        d.transform.localPosition = Vector3(5, 0, 0)
                                        d.transform.localScale = Vector3.one * rd(0.7, 0.94)
                                    end
                                end
                            end
                        end
                    end
                    tgs = s.dat.units
                    for i = 1, cnt do
                        if tgs[i].status == 1 then
                            sps[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y) + dev
                        elseif sps[i] then
                            Destroy(sps[i].gameObject)
                            sps[i] =nil
                        end
                    end
                    if tgs[1].status ~= 1 and efe then EffectFadeOut(efe, 0.5) end
                end

                for i=1, cnt do
                    sps[i]:SetActive(true)
                    EF.Alpha(sps[i].gameObject, 0.25, 1)
                    coroutine.wait(0.1)
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 30 鬼神乱舞 -----------
    [30] = function (s)
        if s.dat.step < 2 then
            local skc_d = BuildObjectForPrefab(s, s.hero_v.go, s.ef.transform:GetChild(3).gameObject, "skc_30_d")
            skc_d.transform.localPosition = Vector3(0, 20, 0)
            if not s.hero_d.isAtk then skc_d.transform.localEulerAngles = Vector3(0, 180, 0) end
        end
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_30", s.hero_v.depth + BU_Map.SkillDepthSpace, 0, 0.8)
                up.Relative = s.map.go.transform
                up.transform.localPosition = s.map:GetPosition(s.dat.units[1].pos.x, s.dat.units[1].pos.y) + Vector3(0, 45, 0)
                up.depth = s.map:GetDepth(s.dat.units[1].pos.y) + BU_Map.SkillDepthSpace
                up.transform:SetActive(false)
                if not s.hero_d.isAtk then
                    up.flip = CS.ToEnum(3, typeof(UIEffectFlip))
                    up.transform.localEulerAngles = Vector3(0, 180, 0)
                end
                local ws = { }
                ws[1] = up
                coroutine.step()
                up.transform:SetActive(true)
                if s.isOwn then s.map:ViewFollow(up.transform) end
                AddAudioSource(up.cachedGameObject):PlayOneShot(AM.LoadAudioClip("sound_skc_30_a"))

                local cpb = AM.LoadAudioClip("sound_skc_30_b")
                local cpc = AM.LoadAudioClip("sound_skc_30_c")
                local skb = s.ef.transform:GetChild(1)
                local skc = s.ef.transform:GetChild(2)
                
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(1)
                    end
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                AddAudioSource(BuildWidget(s, typeof(UIParticle), tg.go, skc, "skc_30_c", tg.depth + BU_Map.SkillDepthSpace + 3).gameObject):PlayOneShot(cpb, BGM.soeVolume)
                                if ois(tg, BU_Hero) and up and s.map.view:IsFollow(up.transform) then
                                    s.map:ViewStopFollow()
                                    s.map.view.lockTime = 5
                                end
                            end
                        end
                    end
                    tgs = s.dat.units
                    if s.dat.units[1].status == 1  then
                        up.transform.localPosition = s.map:GetPosition(s.dat.units[1].pos.x, s.dat.units[1].pos.y) + Vector3(0, 30)
                    elseif up then
                        Destroy(up.gameObject)
                        up = nil
                    end
                    for i = 2, cnt do
                        if tgs[i].status == 1 then
                            if isnull(ws[i]) then
                                ws[i] = BuildWidget(s, typeof(UIWidget), s.map.go, skb, "skc_30_b", 0)
                                if not s.ado.isPlaying then
                                    s.ado.clip = cpc
                                    s.ado.loop = true
                                    s.ado:Play()
                                end
                            end
                            if s.dat.vals[1] < 300 then
                                ws[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y) + Vector3(0, _math.Pow(2, -10 * s.dat.vals[1] / 300) * 300, 0)
                            else
                                ws[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
                            end
                            ws[i].depth = s.map:GetDepth(tgs[i].pos.y)
                        elseif not isnull(ws[i]) then
                            EF.Alpha(ws[i], 0.2, 0).ignoreTimeScale = false
                            Destroy(ws[i].gameObject, 0.3)
                            ws[i] = nil
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 31 破釜沉舟 -----------
    [31] = function (s)
        if s.dat.step < 2 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_3"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_31"), BGM.soeVolume)
        local kp = s.dat.dat.keepSec
        local usp = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_31", BU_Map.SkillFootDepth, 1)
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local so = Vector3.one * 0.7
            local p = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_31_b", BU_Map.SkillHeadDepth, kp)
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if ois(tg, BU_Soldier) then
                    tg = BuildCopy(s, p, tg.go)
                    tg.transform.localScale = so
                end
            end
        end
        s:Destruct(_math.Max(usp.duration, kp))
    end,
--endregion

--region ----------- 32 幻影斩 -----------
    [32] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_32", BU_Map.SkillSkyDepth)
                local sk = s.dat.units
                up.transform.localPosition = s.map:GetPosition(sk[1].pos.x, sk[1].pos.y) + Vector3(0, 33, 0)
                up.depth = s.map:GetDepth(sk[1].pos.y) + BU_Map.SkillDepthSpace
                coroutine.step()
                up.cachedGameObject:SetActive(true)
                if s.isOwn then s.map:ViewFollow(up.transform) end
                AddAudioSource(up.cachedGameObject):PlayOneShot(AM.LoadAudioClip("sound_skc_30_a"))

                local cp = AM.LoadAudioClip("sound_skc_30_b")
                sk = s.ef.transform:GetChild(1).gameObject
                s.action = function ()
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                tg = BuildWidget(s, typeof(UIParticle), tg.go, sk, "skc_32_b", BU_Map.SkillFootDepth)
                                AddAudioSource(tg.gameObject):PlayOneShot(cp, BGM.soeVolume)
                                if ois(tg, BU_Hero) and up and s.map.view:IsFollow(up.transform) then
                                    s.map:ViewStopFollow()
                                    s.map.view.lockTime = 3
                                end
                            end
                        end
                    end
                    tgs = s.dat.units
                    if tgs[1].status == 1 then
                        up.cachedTransform.localPosition = s.map:GetPosition(tgs[1].pos.x, tgs[1].pos.y) + Vector3(0, 33, 0)
                    elseif up then
                        Destroy(up.gameObject)
                        up = nil
                    end
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct()
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 33 命疗术 -----------
    [33] = function (s)
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skc_33", BU_Map.SkillFootDepth)
        up = up.transform
        up:SetActive(false)
        coroutine.wait(0.45)
        up:SetActive(true)
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_5"), BGM.soeVolume)
        s:Destruct(2)
    end,
--endregion

--region ----------- 34 死亡烈焰 -----------
    [34] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = s.dat.dat.keepSec + 1
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local kp = s.dat.dat.keepSec
            local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skc_34", BU_Map.SkillSkyDepth, kp)
            up.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y) + Vector3(0, 10, 0)
            up:SetActive(true)
            AddAudioSource(up, true):PlayOneShot(AM.LoadAudioClip("sound_skc_14"))
            s.action = function ()
                if not s.dat.isAlive then
                    s.action = nil
                    s:Destruct(1)
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 35 引雷术 -----------
    [35] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local up = BuildObjectForPrefab(s, s.map.go, s.ef, "skc_35")
        up.transform.localPosition = s.hero_v.rival.trans.localPosition 
        up:SetActive(true)
        AddAudioSource(up):PlayOneShot(AM.LoadAudioClip("sound_skc_20"))
        s:Destruct(3)
    end,
--endregion
--[[ 直接一次都落完了 ]]
--region ----------- 37 火雷连弹 -----------
    [37] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = s.dat.dat.keepSec + 1
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            if s.dat.unitQty <= 0 then s:Destruct()
            else
                local cp = AM.LoadAudioClip("sound_skc_20")
                local gos = { }
                local tms = { }
                local cnt = #s.dat.units
                for i=1, cnt do table.insert(tms, 0) end
                local units = nil
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(2)
                    end
                    units = s.dat.units
                    for i = 1, #units do
                        if units[i].status == 2 then
                            if not isnull(gos[i]) then
                                tms[i] = (tms[i] or 0) + Time.deltaTime
                                if tms[i] > 0.2 and tms[i] < 1 then
                                    tms[i] = 1
                                    s.ado:PlayOneShot(cp, BGM.soeVolume)
                                end
                            elseif tms[i] == 0 then
                                gos[i] = BuildObjectForPrefab(s, s.map.go, s.ef, s.ef.name)
                                gos[i].transform.localPosition = s.map:GetPosition(units[i].pos.x, units[i].pos.y)
                                gos[i].transform.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                            end
                        end
                    end
                end 
            end
        else s:Destruct()
        end
    end,
--endregion
--[[ 直接一次都落完了 ]]
--region ----------- 38 雷霆万钧 -----------
    [38] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = s.dat.dat.keepSec + 1
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local fef = AddFullEffect(s, FullSkill_LeiDian, false, 0, false, 0.8)
            
            local cnt = s.dat.unitQty
            local kp = s.dat.dat.keepSec
            local cp = AM.LoadAudioClip("sound_skc_20")
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_25"), BGM.soeVolume)
            local buf = BuildWidget(s, typeof(UIParticle), s.hero_v.rival.go, s.ef.transform:GetChild(1).gameObject, "skc_38_c",BU_Map.SkillHeadDepth, kp)
            buf.transform.localPosition = Vector3(0, 80, 0)
            local sk = s.ef.transform:GetChild(0).gameObject
            local pts = { }
            local isto = s.isOwn
            local so = Vector3.one * 0.8
            s.action = function ()
                if not s.dat.isAlive then
                    s.action = nil
                    s:Destruct(2)
                    if buf then buf:Stop() end
                    EffectFadeOut(fef, 0)
                end
                local tgs = s.dat:GetHitTarget()
                if tgs and #tgs > 0 then
                    local tg = nil
                    for i = 1, #tgs do
                        tg = tgs[i].body
                        if ois(tg, BU_Soldier) and not tg.trans:FindChild("skc_38_c") then
                            tg = BuildCopy(s, buf, tg.go)
                            tg = tg.transform
                            tg.localPosition = Vector3(5, 65, 0)
                            tg.localScale = so
                        end
                    end
                    if s.hero_d.rival.TP == 0 and isto then
                        isto = false
                        s.map:ViewMoveToBD(s.hero_d.rival)
                    end
                end
                tgs = s.dat.units
                for i = 1, #tgs do
                    if tgs[i].status == 2 and isnull(pts[i]) then
                        pts[i] = BuildWidget(s, typeof(UIParticle), s.map.go, sk, "skc_38_b", BU_Map.SkillHeadDepth)
                        pts[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
                        AddAudioSource(pts[i].cachedGameObject):PlayOneShot(cp, BGM.soeVolume)
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 39 紫云斩 | 55 乾坤扫月 -----------
    [39] = function (s)
        if s.dat.sn == 39 then
            local ef_c = BuildObjectForPrefab(s, s.hero_v.go, s.ef.transform:GetChild(2).gameObject, "ef_skc_39_c")
            ef_c.transform.localPosition = Vector3(0,30,0)
        end
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local cp = AM.LoadAudioClip("sound_skc_1_b")
                local sps = { }
                local efa = s.ef.transform:GetChild(0).gameObject
                sps[1] = BuildWidget(s, typeof(UIParticle), s.map.go, efa, efa.name, s.map:GetDepth(s.dat.units[1].pos.y) + BU_Map.SkillDepthSpace)
                sps[1].transform.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                sps[1].transform.localPosition = s.map:GetPosition(s.dat.units[1].pos.x, s.dat.units[1].pos.y)
                if s.isOwn then s.map:ViewFollow(sps[1].cachedTransform) end
                s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_1_a"), BGM.soeVolume)
                local ado = AddAudioSource(BuildObject(s, s.map.go, "skc_1_ads"))
                local kp = (s.dat.buff and s.dat.buff.isStop) and s.dat.buff.leftSecond or 0
                local efb = s.ef.transform:GetChild(1).gameObject
                s.action = function ()
                    local tgs = s.dat:GetHitTarget()
                    local p = nil
                    if tgs and #tgs > 0 then
                        local tg = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            local p = BuildObjectForPrefab(s, tg.go, efb, efb.name)
                            if ois(tg, BU_Hero) and sps[1] and s.map.view:IsFollow(sps[1].transform) then
                                s.map:ViewStopFollow()
                            elseif ois(tg, BU_Soldier) then
                                p = p.transform
                                p.localScale = Vector3.one * rd(0.7, 0.9)
                            end
                            if tg then
                                if ado then
                                    ado.transform.localPosition = tg.trans.localPosition
                                    ado:PlayOneShot(cp, BGM.soeVolume)
                                end
                                if kp > 0 then
                                    tg:AddStunEffect(kp)
                                end
                            end
                        end
                    end
                    tgs = s.dat.units
                    for i = 1, cnt do
                        if tgs[i].status == 1 then
                            if tgs[i].time >= 0 then
                                if isnull(sps[i]) then
                                    sps[i] = BuildWidget(s, typeof(UIParticle), s.map.go, efa, efa.name..i, s.map:GetDepth(tgs[i].pos.y) + BU_Map.SkillDepthSpace)
                                    sps[i].transform.localEulerAngles =Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                                    if s.dat.sn == 39 then sps[i].transform.localScale = Vector3.one * rd(0.7, 1.2) end
                                end
                                sps[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
                            end
                        elseif not isnull(sps[i]) then
                            Destroy(sps[i].cachedGameObject)
                            sps[i] = nil
                        end
                    end
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(2)
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 40 天罡剑阵 -----------
    [40] = function (s)
        local t = nil
        if s.dat.step < 2 then
            if s.isOwn then
                t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = 2
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        while s.dat.isAlive do
            local cnt = s.dat.unitQty
            if cnt <= 0 then t = nil break
            else
                s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_20"), BGM.soeVolume)
                for i = 1, cnt do
                    local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skc_40", BU_Map.SkillHeadDepth)
                    up.transform.localPosition = s.map:GetPosition(s.dat.units[i].pos.x, s.dat.units[i].pos.y)
                    coroutine.step(0.05)
                end
                while s.dat.step == 2 do coroutine.step() end
                if s.dat.step == 1 then
                    coroutine.wait(0.2)
                    s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                    s.map.view.lockTime = 2
                    while s.dat.step == 1 do coroutine.step() end
                else break
                end
            end
        end
        s:Destruct(t)
    end,
--endregion

--region ----------- 41 狮子吼 -----------
    [41] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local up = BuildObjectForPrefab(s, s.hero_v.go, s.ef, s.ef.name, 0.8)
        up:SetActive(false)
        coroutine.wait(0.3)
        up:SetActive(true)
        local kp = s.dat.dat.keepSec
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then tg:AddFearEffect(kp) end
            end
        end
        coroutine.wait(0.5)
        if s.isOwn then s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk)) end
        s:Destruct(2)
    end,
--endregion

--region ----------- 42 伏兵暗袭 -----------
    [42] = function (s)
        local obj = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject,"skc_42_obj", BU_Map.SkillFootDepth)
        obj.transform.localPosition = Vector3(0, 30, 0)
        while s.dat.step < 2 do coroutine.step() end
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_21"), BGM.soeVolume)
        s:Destruct()
    end,
--endregion

--region ----------- 43 威震天下 -----------
    [43] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        BuildObjectForPrefab(s, s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_43")
        coroutine.wait(0.2)
        EF.ShakePosition(s.map.go.transform.parent.gameObject, "y", 30, "time", 0.24, "islocal", true)
        local up = nil
        local kp = s.dat.dat.keepSec
        local kp2 = 0
        if s.dat.buff2 then
            kp2 = s.dat.buff2.leftSecond
            up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_43_b",BU_Map.SkillHeadDepth, kp2)
        end
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    if tg:IsAtk(s.hero_d.isAtk) then
                        if kp2 > 0 and ois(tg, BU_Soldier) then
                            local buf = BuildCopy(s, up, tg.go, 0.5)
                            Destroy(buf, kp2)
                        end
                    else tg:AddStunEffect(kp)
                    end
                end
            end
        end
        coroutine.wait(0.5)
        if s.isOwn then
            s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
            s.map.view.lockTime = kp
        end
        s:Destruct(kp2 + 2)
    end,
--endregion

--region ----------- 44 攻心 --------------
    [44] = function(s)
        if s.dat.step < 2 then
            BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(2).gameObject, "skc_44", BU_Map.SkillFootDepth)
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = 2
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_13"), BGM.soeVolume)
            local skc_a = s.ef.transform:GetChild(0).gameObject
            local skc_b = s.ef.transform:GetChild(1).gameObject
            local ef = nil
            local buf = nil
            local kp = 0
            if s.dat.buff then
                kp = s.dat.buff.leftSecond
                buf = BuildWidget(s, typeof(UIParticle), s.map.go, skc_b, skc_b.name, BU_Map.SkillHeadDepth, kp)
                buf.transform.localScale = Vector3.one * 0.8
                buf.transform.localPosition = Vector3(10000, 10000, 10000)
            end

            for i=1, #tgs do
                local tg = tgs[i].body
                if tg then
                    if ef then
                        Destroy(BuildCopy(s, ef, tg.go).gameObject, ef.duration)
                    else
                        ef = BuildWidget(s, typeof(UIParticle), tg.go, skc_a, skc_a.name, BU_Map.SkillHeadDepth)
                    end
                    if buf and kp > 0 then
                        local uc = BuildCopy(s, buf, tg.go)
                        uc.transform.localPosition = Vector3.zero
                        Destroy(uc.gameObject, kp)
                    end
                end
            end
        end

        s:Destruct(1.2)
    end,
--endregion

--region ----------- 45 四面楚歌 -----------
    [45] = function (s)
        if s.dat.step < 2 then
            BuildObjectForPrefab(s, s.hero_v.go, s.ef, "skc_45", 0.8)
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 3
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        s:Destruct()
    end,
--endregion

--region ----------- 46 冰牙突 -----------
    [46] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 3
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local sk = s.ef.transform
        local kp = BuildObjectForPrefab(s, s.map.go, sk:GetChild(0).gameObject, "skc_46_a")
        kp:SetActive(false)
        coroutine.step()
        coroutine.step()
        kp.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
        kp:SetActive(true)

        sk = sk:GetChild(1)
        kp = s.dat.dat.keepSec
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    BuildWidget(s, typeof(UIParticle), tg.go, sk, "skc_46_b", tg.depth + BU_Map.SkillDepthSpace, kp)
                end
            end
        end
        s:Destruct(kp + 2)
    end,
--endregion

--region ----------- 47 夺命飞刀 -----------
    [47] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 3
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        for i=1, 3 do
            local ef = BuildObjectForPrefab(s, s.map.go, s.ef, s.ef.name)
            ef:SetActive(false)
            coroutine.step()
            coroutine.step()
            ef.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
            if i==2 then ef.transform.localPosition  = ef.transform.localPosition + Vector3(10, 0, 0)
            elseif i==3 then ef.transform.localPosition  = ef.transform.localPosition + Vector3(-10, 0, 0) end
            
            ef:SetActive(true)
            coroutine.step()
        end

        while s.dat.isAlive do coroutine.step() end
        s:Destruct(5)
    end,
--endregion

--region ----------- 48 落石 -----------
    [48] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 3
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local obj = BuildObjectForPrefab(s, s.map.go, s.ef, s.ef.name)
        obj.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y) + Vector3(0, 10, 0)
        obj.transform.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
        s:Destruct(5)
    end,
--endregion

--region ----------- 49 半月剑气 -----------
    [49] = function (s)
        if s.dat.step < 2 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_7"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local sps = { }
                local sk = s.dat.units
                local ef = s.ef.transform
                for i = 1, 1 do
                    sps[i] = BuildObjectForPrefab(s, s.map.go, ef, "skc_49_a")
                    sps[i].transform.localPosition = s.map:GetPosition(sk[i].pos.x, sk[i].pos.y)
                    sps[i].transform.localEulerAngles = Vector3(0, sk[i].direction.x < 0 and 0 or 180, 0)
                    sps[i].transform.localScale = i==1 and sps[i].transform.localScale or sps[i].transform.localScale * 0.6
                end
                if s.isOwn then s.map:ViewFollow(sps[1].transform) end

                ef = s.ef.transform:GetChild(1).gameObject
                s.action = function ()
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        local up = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                if ois(tg, BU_Hero) and sps[1] and s.map.view:IsFollow(sps[1].transform) then s.map:ViewStopFollow() end
                            end
                        end
                    end
                    tgs = s.dat.units
                    for i = 1, 1 do
                        if tgs[i].status == 1 then
                            sps[i].transform.localPosition = i==1 and s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y) or s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y) + Vector3(-90, 0, 0)
                        elseif not isnull(sps[i]) then
                            Destroy(sps[i].gameObject)
                            sps[i] = nil
                        end
                    end
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(1)
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 50 野蛮冲撞 -----------
    [50] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local sk = s.dat.units
                local dev = Vector3(-24, 36, 0)
                local up = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_50_a", 0.8)
                up.transform.localPosition = s.map:GetPosition(sk[1].pos.x, sk[1].pos.y) + dev
                up.transform.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                up:GetCmp(typeof(UIWidget)).depth = s.map:GetDepth(sk[1].pos.y) + BU_Map.SkillDepthSpace

                
                if s.isOwn then s.map:ViewFollow(up.transform) end
                coroutine.wait(0.18)

                local ef = s.ef.transform:GetChild(1).gameObject
                local cp = AM.LoadAudioClip("sound_skc_29_b")
                s.ado.clip = AM.LoadAudioClip("sound_skc_29_a")
                s.ado.loop = false
                s.ado:Play()
                s.action = function ()
                    if not s.dat.isAlive then
                        if s.ado.isPlaying then s.ado:Stop() end
                        s.action = nil
                        s:Destruct(1)
                    end
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                sp = BuildObjectForPrefab(s, tg.go, ef, "skc_50_hit")
                                sp.transform.localPosition =(ois(tg, BU_Hero) and Vector3(s.hero_d.isAtk and -10 or 15, 60, 0) or Vector3(s.hero_d.isAtk and -5 or 20, 45, 0))
                                if not s.hero_d.isAtk then sp.transform.localEulerAngles = Vector3(0, 180, 0) end
                                if ois(tg, BU_Hero) and up and s.map.view:IsFollow(up.transform) then
                                    s.map:ViewStopFollow()
                                    s.map.view.lockTime = 2
                                end
                            end
                        end
                    end
                    tgs = s.dat.units
                    if tgs[1].status == 1 then
                        if not s.ado.isPlaying and s.ado.enabled then
                            s.ado.clip = cp
                            s.ado.loop = true
                            s.ado:Play()
                            EF.Volume(s.ado, 0.3, 0, 3).ignoreTimeScale = false
                        end
                        up.transform.localPosition = s.map:GetPosition(tgs[1].pos.x, tgs[1].pos.y) + dev
                    elseif not isnull(up) then
                        Destroy(up.gameObject)
                        up = nil
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 51 连环火柱 -----------
    [51] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.25
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 6
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local sk = s.ef.transform:GetChild(0).gameObject
                local pts = { }
                local cp = s.dat.units
                for i = 1, cnt do
                    pts[i] = BuildObjectForPrefab(s, s.map.go, sk, "skc_51")
                    pts[i].transform.localPosition = s.map:GetPosition(cp[i].pos.x, cp[i].pos.y)
                    pts[i]:SetActive(false)
                end
                coroutine.step()
                for i = 1, cnt do pts[i]:SetActive(true) end

                cp = AM.LoadAudioClip("sound_skc_30_c")
                sk = s.ef.transform:GetChild(1).gameObject
                s.action = function ()
                    if not s.dat.isAlive then
                        for i = 1, cnt do EF.Alpha(pts[i], 0.2, 0).ignoreTimeScale = false end
                        s.action = nil
                        s:Destruct(1)
                    elseif not s.ado.isPlaying then
                        s.ado.clip = cp
                        s.ado.loop = true
                        s.ado:Play()
                    end
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                BuildWidget(s, typeof(UIParticle), tg.go, sk, "skc_51_b", tg.depth + BU_Map.SkillDepthSpace + 1, 0, 0.8)
                            end
                        end
                    end
                    tgs = s.dat.units
                    for i = 1, cnt do
                        pts[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 52 仙愈甘露 -----------
    [52] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local obj = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_52_a",BU_Map.SkillHeadDepth)
        obj.cachedTransform.localScale = Vector3.one
        local usp = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_52_b",BU_Map.SkillHeadDepth)
        usp.transform.localScale = Vector3.one
        usp.transform:SetActive(false)
        coroutine.step()
        usp.cachedGameObject:SetActive(true)
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_18"), BGM.soeVolume)

        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    tg = BuildCopy(s, usp, tg.go)
                    tg.cachedTransform.localScale = Vector3.one * 0.7
                end
            end
        end
        s:Destruct(2)
    end,
--endregion

--region ----------- 54 呼风唤雨 -----------
    [54] = function (s)
        local map = s.map
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.25
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                map.view.lockTime = s.dat.dat.keepSec + 1
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_54_a", s.map:GetDepth(s.dat.units[1].pos.y) + BU_Map.SkillDepthSpace)
        up.transform.localPosition = map:GetPosition(s.dat.units[1].pos.x, s.dat.units[1].pos.y)

        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local ef = s.ef
                local gos = { }
                local units = s.dat.units
                for i = 1, cnt do
                    if units[i].status == 1 then
                        gos[i] = BuildWidget(s, typeof(UIParticle), map.go, ef.transform:GetChild(1).gameObject, "skc_54_b", s.map:GetDepth(units[1].pos.y) + BU_Map.SkillDepthSpace)
                        gos[i].transform.localPosition = map:GetPosition(units[i].pos.x, units[i].pos.y)
                        gos[i].depth = s.map:GetDepth(units[i].pos.y) + BU_Map.SkillDepthSpace
                        gos[i]:SetActive(false)
                    end
                end
                coroutine.step()
                for i = 1, cnt do if gos[i] then gos[i]:SetActive(true) end end

                local hry = s.dat.dat.rangeY.value * 0.5
                s.action = function ()
                    if not s.dat.iaAlive then
--                        for i = 1, cnt do EF.Alpha(gos[i], 0.2, 0).ignoreTimeScale = false end
                        s.action = nil
                        s:Destruct(2)
                     end
                     units = s.dat.units
                     for i = 1, cnt do
                        if units[i].status == 1 then 
                            gos[i].transform.localPosition = map:GetPosition(units[i].pos.x, units[i].pos.y) 
                            gos[i].depth = map:GetDepth(units[i].pos.y - hry) + BU_Map.SkillDepthSpace
                        end
                     end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region -----------56 冥炎符法 ------------
    [56] = function(s)
        local skc_c = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(2).gameObject, "skc_27_c", s.hero_v.depth + BU_Map.SkillDepthSpace)
        skc_c.transform.localPosition = s.hero_v.go.transform.localPosition
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt < 0 then s:Destruct() coroutine.step() end

            local skc_a = s.ef.transform:GetChild(0).gameObject
            local skc_b = s.ef.transform:GetChild(1).gameObject

            s.ado.clip = AM.LoadAudioClip("sound_skc_27")
            s.ado.loop = true
            s.ado:Play()

            local ups = {}
            for i=1, cnt do
                ups[i] = i > 1 and BuildCopy(s, ups[1], s.map.go) or BuildWidget(s, typeof(UIParticle), s.map.go, skc_a, "skc_27", s.hero_v.depth + BU_Map.SkillDepthSpace)
                ups[i].transform.localPosition = s.hero_v.go.transform.localPosition + Vector3(0, 30, 0)
            end

            s.action = function()
                if not s.dat.isAlive then
                    ups[1]:Stop()
                    EF.Alpha(ups[1]:GetCmpInChilds(typeof(UIWidget), false).gameObject, 0.3, 0).ignoreTimeScale = false
                    EF.Volume(s.ado, 0.3, 0).ignoreTimeScale = false
                    s.action = nil
                    s:Destruct(1)
                end
                local tgs = s.dat.units
                if tgs and #tgs > 0 then
                    for i=1, cnt do
                        local tg = tgs[i].body
                        if tg then
                            BuildWidget(s, typeof(UIParticle), tg.go, skc_b, "skc_27_b", tg.depth + BU_Map.SkillDepthSpace + 1)
                        end
                    end
                end
                for i=1, cnt do
                    ups[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x + s.hero_d.pos.x, tgs[i].pos.y + s.hero_d.pos.y)
                    ups[i].depth = s.map:GetDepth(tgs[i].pos.y + 5)
                    
                    local qty = ups[i].transform.childCount
                    for j=1, qty do
                        ups[i].transform:GetChild(j-1):GetCmp(typeof(UIWidget)).depth = ups[i].depth + j
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 57 破胆怒吼 -----------
    [57] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.dat.keepSec
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_57_a",BU_Map.SkillFootDepth)
        up:SetActive(false)
        local buf = BuildWidget(s, typeof(UIParticle), s.hero_v.rival.go, s.ef.transform:GetChild(1).gameObject, "skc_57_c",BU_Map.SkillHeadDepth, kp, 0.8)
        buf.transform.localPosition = Vector3(0, 90, 0)
        buf:SetActive(false)
        coroutine.step()
        up:SetActive(true)
        buf:SetActive(true)

        local so = Vector3.one * 0.8
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    tg = BuildCopy(s, buf, tg.go)
                    tg = tg.transform
                    tg.localPosition = Vector3(5, 60, 0)
                    tg.localScale = so
                end
            end
        end
        coroutine.wait(0.8)
        if s.isOwn then
            s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
            s.map.view.lockTime = kp
        end
        s:Destruct(kp)
    end,
--endregion

--region ----------- 58 凤求凰 -----------
    [58] = function (s)
        if s.dat.step < 2 then
--            if s.isOwn then s.map:ViewMoveToBU(s.hero_v) end
            local start = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(0).gameObject, "ef_skc_58_act", BU_Map.SkillFootDepth)
            start.transform.localPosition = s.hero_v.go.transform.localPosition + Vector3(-90, 70, 0)
            if not s.hero_d.isAtk then start.transform.localEulerAngles = Vector3(0, 180, 0) end
            start:SetActive(false)
            coroutine.wait(0.15)
            start:SetActive(true)
            while s.dat.step < 2 do coroutine.step() end
        end
        EF.ShakePosition(s.map.go.transform.parent.gameObject, "y", 30, "time", 0.24, "islocal", true)
        
        local kp = s.ef.transform
        local fly = BuildWidget(s, typeof(UIParticle), s.map.go, kp:GetChild(1).gameObject, "ef_skc_58_obj", BU_Map.SkillSkyDepth, 0, 0.6)
        fly.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
        if s.hero_d.isAtk then fly.transform.localEulerAngles = Vector3(0, 0, 0) end
        fly:SetActive(false)
        local buf = BuildWidget(s, typeof(UIParticle), s.map.go, kp:GetChild(2).gameObject, "ef_skc_58_buf", s.hero_v.depth + BU_Map.SkillSkyDepth)
        buf.loop = true
        buf.transform.localPosition = Vector3(10000, 10000, 10000)
        coroutine.step()
        fly:SetActive(true)

        local fef = AddFullEffect(s, FullSkill_Fire, false, 0, false, 1)
        if s.isOwn then s.map:ViewFollow(fly.transform)  end

        kp = s.dat.buff.leftSecond
        s.action = function ()
            local tgs = s.dat:GetHitTarget()
            if tgs and #tgs > 0 then
                local tg = nil
                local b = nil
                for i = 1, #tgs do
                    tg = tgs[i].body
                    if tg then
                        b = BuildCopy(s, buf, tg.go)
                        EF.Alpha(b, 0.25, 0, kp).ignoreTimeScale = false
                        Destroy(b.gameObject, kp + 0.3)
                        if ois(tg, BU_Hero) then
                            b.transform.localPosition = Vector3.zero
                            b.transform.localScale = Vector3.one * 1.2
                            if fly and s.map.view:IsFollow(fly.transform) then s.map:ViewStopFollow() end
                        else
                            b.transform.localPosition = Vector3(5, 0, 0)
                            b.transform.localScale = Vector3.one * rd(0.7, 0.94)
                        end
                    end
                end
            end
            fly.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
            if not s.dat.isAlive then
                s.action = nil
                s:Destruct(kp)
                Destroy(fly.gameObject)
                EffectFadeOut(fef, 0)
            end
        end
    end,
--endregion

--region ----------- 59 飞火流星 -----------
    [59] = function (s)
        local map = s.map
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                map.view.lockTime = s.dat.dat.keepSec + 3
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local cp = AM.LoadAudioClip("sound_skc_20")
                local efe = AddFullEffect(s, FullSkill_Fire2, false, 0, true, 1.4)
                efe.transform.localPosition = Vector3(0, -135, 0)
                local ef = s.ef
                local stars = { }
                local exps = { }
                local tms = { }
                for i=1, cnt do table.insert(tms, 0) end
                local r = 0
                local units = nil
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        EffectFadeOut(efe, 2)
                        s:Destruct(2)
                    end
                    units = s.dat.units
                    for i = 1, cnt do
                        if units[i].status == 1 and units[i].time >= 0 then
                            r = units[i].speed
                            if isnull(stars[i]) then
                                stars[i] = s.map.go:AddChild(ef.transform:GetChild(0).gameObject, "skc_59_a")
                                insert(s.objs, stars[i])
                                Destroy(stars[i], 2.2)
                                stars[i].transform.localPosition = map:GetPosition(units[i].pos.x + r * 0.5, units[i].pos.y + r * 0.5)
                                stars[i].transform.localScale = Vector3.one * (0.1 + 0.3 * r) * 1.3
                                EF.MoveTo(stars[i].transform:GetChild(0).gameObject, "time", 0.2, "position", Vector3.zero, "islocal", true, "easetype", iTween.EaseType.easeOutQuad)
                                Destroy(stars[i], 0.5)
                            end
                            tms[i] = (tms[i] or 0) + Time.deltaTime
                            if not exps[i] and tms[i] > 0.2 then 
                                exps[i] = BuildWidget(s, typeof(UIParticle), s.map.go, ef.transform:GetChild(1).gameObject, "skc_59_b", BU_Map.SkillFootDepth)
                                Destroy(exps[i], 2.2)
                                exps[i].transform.localPosition = stars[i].transform.localPosition
                                exps[i].transform.localScale = stars[i].transform:GetChild(0).localScale
                                if r > 1 then AddAudioSource(exps[i]):PlayOneShot(cp, BGM.soeVolume) end
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 60 玄雷光阵 -----------
    [60] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.25
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = s.dat.dat.keepSec + 1
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local skc_c = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(2).gameObject, "skc_60_c", 0.8)
                skc_c.transform.localPosition = s.hero_v.go.transform.localPosition
                local kp = s.dat.dat.keepSec
                local cp = s.dat.units
                local sk = s.ef.transform:GetChild(0)
                local pts = { }
                local cnt1 = s.dat.vals[2]
                local hr2 = s.dat.vals[4]
                for i = 1, cnt1 do
                    if cp[i].status == 1 then
                        pts[i] = BuildWidget(s, typeof(UIParticle), s.map.go, sk, "skc_60_a", BU_Map.SkillFootDepth, kp + 0.2)
                        pts[i].transform.localPosition = s.map:GetPosition(cp[i].pos.x, cp[i].pos.y) + Vector3(0, 300, 0)
                        pts[i].depth = s.map:GetDepth(cp[i].pos.y - 1)
                        pts[i]:SetActive(false)
                    end
                end
                coroutine.step()
                for i = 1, cnt1 do pts[i]:SetActive(true) end

                cp = AM.LoadAudioClip("sound_skc_20")
                sk = s.ef.transform:GetChild(1)
                local tm = 0
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        for i = 1, cnt1 do if not isnull(pts[i]) then pts[i]:Stop() end end
                        s:Destruct(1)
                    end
                    local tgs = s.dat.units
                    if tm < 0.3 then
                        tm = tm + Time.deltaTime
                        for i = 1, cnt1 do
                            if pts[i] then pts[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y) + Vector3(0, _math.Pow(2, -10 * tm / 0.3) * 300, 0) end
                        end
                    end
                    for i = cnt1, cnt do
                        if tgs[i].status == 1 and tgs[i].time >= 0 and isnull(pts[i]) then
                            pts[i] = BuildWidget(s, typeof(UIParticle), s.map.go, sk, "skc_60_b", s.map:GetDepth(tgs[i].pos.y - hr2))
                            pts[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
                            AddAudioSource(pts[i].gameObject):PlayOneShot(cp, BGM.soeVolume)
                        end
                    end
                    skc_c.transform.localPosition = Vector3(s.map.go.transform.localPosition.x * -1 , 0, 0)
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 61 桃园结义 -----------
    [61] = function (s)
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "ef_skc_61_a", BU_Map.SkillDepthSpace)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.buff then
            local kp = s.dat.buff.leftSecond
            local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "ef_skc_61_b",BU_Map.SkillHeadDepth, kp)
            buf.transform.localPosition = Vector3(10000, 10000, 10000)
            coroutine.step()

            local tgs = s.dat:GetHitTarget()
            if tgs and #tgs > 0 then
                local tg = nil
                for i = 1, #tgs do
                    tg = tgs[i].body
                    if tg then
                        tg = BuildCopy(s, buf, tg.go)
                        Destroy(tg.cachedGameObject, kp)
                        tg.transform.localPosition = Vector3.zero
                    end
                end
            end
        else s:Destruct(1)
        end
    end,
--endregion

--region ----------- 62 王者之气 -----------
    [62] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_62_1",BU_Map.SkillFootDepth)
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_62_2",BU_Map.SkillFootDepth)
        up:SetActive(false)
        coroutine.step()
        up:SetActive(true)
        coroutine.wait(s.dat.dat.keepSec)
        if not isnull(up) then up:Stop() end
        s:Destruct(1)
    end,
--endregion

--region ----------- 63 天剑斩 -----------
    [63] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = 2
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local up = BuildObjectForPrefab(s, s.map.go, s.ef, "skc_63")
        up:SetActive(false)
        coroutine.step()
        up.transform.localPosition = s.hero_v.rival.trans.localPosition + Vector3(0, 35, 0)
        up:SetActive(true)
        coroutine.wait(0.1)

        if s.dat.buff then s.hero_v.rival:AddBleedEffect(s.dat.buff.leftSecond) end
        coroutine.wait(0.26)
        EF.ShakePosition(s.map.go.transform.parent, "y", 30, "time", 0.24, "islocal", true)

        EF.ClearITween(s.map.go.transform.parent)
        s.map.go.transform.parent.localPosition = Vector3.zero
        s:Destruct(2)
    end,
--endregion

--region ----------- 64 分身斩 -----------
    [64] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local sk = s.dat.units
                local up = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_64")
                up.transform.localPosition = s.map:GetPosition(sk[1].pos.x, sk[1].pos.y) + Vector3(0, 43, 0)
                up.transform.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
                up:SetActive(false)
                
                coroutine.step()
                up:SetActive(true)
                if s.isOwn then s.map:ViewFollow(up.transform) end
                AddAudioSource(up.gameObject):PlayOneShot(AM.LoadAudioClip("sound_skc_30_a"))

                local cp = AM.LoadAudioClip("sound_skc_30_b")
                sk = s.ef.transform:GetChild(1).gameObject
                local kp = s.dat.dat.keepSec
                s.action = function ()
                    local tgs = s.dat:GetHitTarget()
                    if tgs then
                        local tg = nil
                        local p = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                p = BuildWidget(s, typeof(UIParticle), tg.go, sk, "skc_32_b",BU_Map.SkillDepthSpace)
                                if ois(tg, BU_Soldier) then p.transform.localScale = Vector3.one * 0.6 end
                                AddAudioSource(p.gameObject):PlayOneShot(cp, BGM.soeVolume)
                                tg:AddStunEffect(kp)
                            end
                        end
                    end
                    tgs = s.dat.units
                    if tgs[1].status == 1 then
                        up.transform.localPosition = s.map:GetPosition(tgs[1].pos.x, tgs[1].pos.y) + Vector3(0, 33, 0)
                    elseif up then
                        Destroy(up.gameObject)
                        up = nil
                    end
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct()
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 65 逆天改命 -----------
    [65] = function (s)
        local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_65_a",BU_Map.SkillFootDepth)
        up:SetActive(false)
        coroutine.wait(0.3)
        up.transform.localPosition = s.hero_v.trans.localPosition
        up:SetActive(true)
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_4"), BGM.soeVolume)

        coroutine.wait(0.3)
        local go = BuildWidget(s, typeof(UIParticle),s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_65_b", BU_Map.SkillSkyDepth, 0, 0.8)
        go.transform.localPosition = s.map.go.transform.localPosition * -1
        
        s:Destruct(4)
    end,
--endregion

--region ----------- 66 一骑当千 -----------
    [66] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skc_66",BU_Map.SkillFootDepth)
        up:SetActive(false)
        coroutine.step()
        up:SetActive(true)
        up:Stop()
        s:Destruct(1)
    end,
--endregion

--region ----------- 67 苦肉计 -----------
    [67] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skc_67",BU_Map.SkillFootDepth)
        up.transform.localScale = Vector3(1, 1.5, 1)
        up:SetActive(false)
        coroutine.step()
        up:SetActive(true)
        if s.dat.step == 2 then
            while s.dat.step == 2 do coroutine.step() end
            up:Stop(false)
            up.transform:GetChild(0).gameObject:SetActive(true)
            s:Destruct(2)
        else
            coroutine.wait(s.dat.dat.keepSec)
            up:Stop()
            s:Destruct(1)
        end
    end,
--endregion

--region ----------- 68 孤胆刺杀 -----------
    [68] = function (s)
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_68_a", BU_Map.SkillFootDepth)
        while s.dat.step < 2 do coroutine.step() end
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_68", BU_Map.SkillFootDepth)
        up:SetActive(false)
        coroutine.step()
        up:SetActive(true)
        coroutine.wait(s.dat.dat.keepSec)
        up:Stop()
        s:Destruct(1)
    end,
--endregion

--region ----------- 69 武圣式 -----------
    [69] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local go = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_69_a")
        go:SetActive(false)
        coroutine.step()
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_3"), BGM.soeVolume)
        go.transform.localPosition = s.hero_v.trans.localPosition
        go:SetActive(true)
        local t = Time.time + 0.1
        while s.dat.isAlive and t > Time.time do coroutine.step() end
        s.hero_v:HideBody()

        t = Time.time + 0.2
        while s.dat.isAlive and t > Time.time do coroutine.step() end
        s.map:ViewFollowBU(s.hero_v.rival)
        while s.dat.isAlive do coroutine.step() end
        s.hero_v:ShowBody()
        s.map:ViewFollowBU(s.hero_v)

        go = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_69_b")
        go:SetActive(false)
        coroutine.step()
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_1_b"), BGM.soeVolume)
        go.transform.localPosition = s.hero_v.trans.localPosition
        go:SetActive(true)
        EF.ShakePosition(s.map.go.transform.parent, "y", 30, "time", 0.24, "islocal", true)

        go = s.ef.transform:GetChild(2).gameObject
        t = s.dat.dat.keepSec
        local kp2 = s.dat.buff.leftSecond
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            local b = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    b = BuildWidget(s, typeof(UIWidget), tg.go, go, "skc_69_c", 0, kp2)
                    b.transform.localPosition = ois(tg, BU_Hero) and Vector3(0, 80, 0) or Vector3(5, 65, 0)
                    if ois(tg, BU_Soldier) then b.cachedTransform.localScale = Vector3.one * 0.8 end
                    b:SetActive(true)
                    tg:AddStunEffect(t)
                end
            end
        end
        coroutine.wait(0.3)
        EF.ClearITween(s.map.go.transform.parent)
        s.map.go.transform.parent.localPosition = Vector3.zero
        s:Destruct(_math.Max(t, kp2, 3))
    end,
--endregion

--region ----------- 70 麻沸散 -----------
    [70] = function (s)
        local up = nil
        local sk = s.ef.transform
        if s.dat.step < 2 then
            up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, sk:GetChild(0).gameObject, "skc_70_a", BU_Map.SkillFootDepth)
            up:SetActive(false)
            local t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up:SetActive(true)
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            up = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(1).gameObject, "skc_70_b", BU_Map.SkillFootDepth, 0, 0.8)
            up.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
            sk = s.ef.transform:GetChild(2).gameObject

            local arr = { }
            local tgs = nil
            s.action = function ()
                if not s.dat.isAlive then
                    s.action = nil
                    s:Destruct(2)
                end
                tgs = s.dat:GetHitTarget()
                if tgs and #tgs > 0 then
                    local tg = nil
                    for i = 1, #tgs do
                        tg = tgs[i].body
                        if tg then
                            for j = 1, #arr do
                                if arr[j] == tgs[i] then arr[j] = nil break end
                            end
                            if not tg.trans:FindChild("skc_70_c") then
                                local p = BuildWidget(s, typeof(UIParticle), tg.go, sk, "skc_70_c", tg.depth + BU_Map.SkillDepthSpace)
                                p.transform.localScale = ois(tg, BU_Hero) and Vector3.one * 0.8 or Vector3.one
                            end
                        end
                    end
                    for j = 1, #arr do
                        if arr[j] ~= nil and ois(arr[j].body, BU_Unit) and not isnull(arr[j].body) then
                            tg = arr[j].body.trans:FindChild("skc_70_c")
                            if tg then
                                EF.Alpha(tg, 0.2, 0)
                                Destroy(tg.gameObject, 0.2)
                            end
                        end
                    end
                    arr = tgs
                end

                if not s.dat.isAlive then
                    up:Stop()
                    for j = 1, #arr do
                        if arr[j] ~= nil and ois(arr[j].body, BU_Unit) and not isnull(arr[j].body) then
                            tg = arr[j].body.trans:FindChild("skc_70_c")
                            if tg then
                                EF.Alpha(tg, 0.2, 0)
                                Destroy(tg.gameObject, 0.2)
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 71 塑梦术 -----------
    [71] = function (s)
        local up = nil
        local sk = s.ef.transform
        if s.dat.step < 2 then
            up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, sk:GetChild(0).gameObject, "skc_71_a", BU_Map.SkillFootDepth)
            up.transform.localPosition = Vector3(0, 30, 0)
            up:SetActive(false)
            local t = Time.time + 0.5
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up:SetActive(true)

            if s.isOwn then
                local t = Time.time + 1
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = 3
            end
            while s.dat.step < 2 do coroutine.step() end
        end

        local fef = AddFullEffect(s, FullSkill_HuaBan, s.hero_d.isAtk, 0, true, 1)

        tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            sk = s.ef.transform:GetChild(1).gameObject
            up = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    if up then BuildCopy(s, up, tg.go)
                    else
                        up = BuildWidget(s, typeof(UIParticle), tg.go, sk, "skc_71_b", tg.depth + BU_Map.SkillDepthSpace)
                    end
                end
            end
        end
        coroutine.wait(3)
        EffectFadeOut(fef, 0)
        s:Destruct(2)
    end,
--endregion

--region ----------- 72 洛神赋 -----------
    [72] = function (s)
        local up = nil
        local sk = s.ef.transform
        local fef = AddFullEffect(s, FullSkill_ShengGuang, s.hero_d.isAtk, 0, true, 0.8)
        if s.dat.step < 2 then
            up = BuildObjectForPrefab(s, s.hero_v.go, sk:GetChild(0).gameObject, "skc_72_a")
            up:SetActive(false)
            local t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up:SetActive(true)
            
            t = Time.time + 0.6
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            if s.isOwn then
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 3
            end
            up = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(1).gameObject, "skc_72_b", BU_Map.SkillFootDepth)
            up:SetActive(false)
            t = Time.time + 0.2
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up.transform.localPosition = s.hero_v.rival.trans.localPosition
            up:SetActive(true)
            while s.dat.step < 2 do coroutine.step() end
        end
        local kp = s.dat.dat.keepSec
        up = nil
        if s.dat.buff then
            kp = s.dat.buff.leftSecond
            up = sk:GetChild(2).gameObject
        end 
        tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    tg:AddStunEffect(kp)
                    if up and kp > 0 then
                        local go = BuildWidget(s, typeof(UIParticle), tg.go, up, "skc_72_c", BU_Map.SkillHeadDepth, kp)
                        go.transform.localPosition = Vector3(0, 80, 0)
                    end
                end
            end
        end
        EffectFadeOut(fef, kp + 2)
        s:Destruct(2 + kp)
    end,
--endregion

--region ----------- 73 剧毒沼泽 -----------
    [73] = function (s)
        local up = nil
        local sk = s.ef.transform
        if s.dat.step < 2 then
            up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, sk:GetChild(0).gameObject, "skc_73_a", BU_Map.SkillFootDepth)
            up:SetActive(false)
            local t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up:SetActive(true)
            while s.dat.step < 2 do coroutine.step() end
        end

        local fef = AddFullEffect(s, FullSkill_DuWu, s.hero_d.isAtk, 0, true, 0.9)
        if s.dat.isAlive then
            local kp = s.dat.dat.keepSec
            if s.isOwn then
                s.map:ViewMoveX(s.dat.pos.x)
                s.map.view.lockTime = kp + 1
            end

            up = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(1).gameObject, "skc_73_b", BU_Map.SkillFootDepth)
            sk = s.ef.transform:GetChild(2).gameObject
            up:SetActive(false)
            up.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
            coroutine.step()
            up:SetActive(true)

            AddAudioSource(up.gameObject):PlayOneShot(AM.LoadAudioClip("sound_skc_12_a"),BGM.soeVolume)

            local arr = { }
            local tgs = nil
            s.action = function ()
                if not s.dat.isAlive then
                    s.action = nil
                    s:Destruct(2)
                end
                tgs = s.dat:GetHitTarget()
                if tgs then
                    local tg = nil
                    for i = 1, #tgs do
                        tg = tgs[i].body
                        if tg then
                            for j = 1, #arr do
                                if arr[j] == tgs[i] then arr[j] = nil break end
                            end
                            if not tg.trans:FindChild("skc_73_c") then
                                local p = BuildWidget(s, typeof(UIParticle), tg.go, sk, "skc_73_c", tg.depth + BU_Map.SkillDepthSpace)
                                p.transform.localScale = ois(tg, BU_Hero) and Vector3.one * 0.8 or Vector3.one
                            end
                        end
                    end
                    for j = 1, #arr do
                        if arr[j] ~= nil and ois(arr[j].body, BU_Unit) and not isnull(arr[j].body) then
                            tg = arr[j].body.trans:FindChild("skc_73_c")
                            if tg then
                                EF.Alpha(tg, 0.2, 0)
                                Destroy(tg.gameObject, 0.2)
                            end
                        end
                    end
                    arr = tgs
                end

                if not s.dat.isAlive then
                    up:Stop()
                    EffectFadeOut(fef, 0.5)
                    for j = 1, #arr do
                        if arr[j] ~= nil and ois(arr[j].body, BU_Unit) and not isnull(arr[j].body) then
                            tg = arr[j].body.trans:FindChild("skc_70_c")
                            if tg then
                                EF.Alpha(tg, 0.2, 0)
                                Destroy(tg.gameObject, 0.2)
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 74 嗜血狂袭 -----------
    [74] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skc_74",BU_Map.SkillFootDepth)
        up.transform.localPosition = Vector3(0, 10, 0)
        up:SetActive(false)
        coroutine.step()
        up:SetActive(true)
        coroutine.wait(s.dat.dat.keepSec)
        up:Stop()
        s:Destruct(1)
    end,
--endregion

--region ----------- 75 谦逊 -----------
    [75] = function (s)
        if s.dat.step < 2 then
            up = AddFullEffectNoAnchor(s, "ef_skc_75", false, 0, false, 1.3)
            up:SetActive(false)
            local t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up:SetActive(true)
            EF.ShakePosition(s.map.go.transform.parent.gameObject, "y", 30, "time", 0.4, "islocal", true)
            while s.dat.step < 2 do coroutine.step() end
        end

--        tgs = s.dat:GetHitTarget()
--        if tgs then
--            local tg = nil
--            sk = s.ef.transform:GetChild(1).gameObject
--            up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, sk, "skc_75_b", BU_Map.SkillFootDepth)
--            local so = Vector3.one * 0.8
--            for i = 1, #tgs do
--                tg = tgs[i].body
--                if tg then
--                    BuildCopy(s, up, tg.go).cachedTransform.localScale = so
--                end
--            end
--            coroutine.wait(s.dat.dat.keep.value)
--            up:Stop()
--        end
        s:Destruct(s.dat.dat.keepSec + 0.3)
    end,
--endregion

--region ----------- 76 百步穿杨 -----------
    [76] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 or s.dat.units[1].status ~= 1 then s:Destruct()
            else
                local up = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_76_a", 0.8)
                local trans = up.transform
                local units = s.dat.units
                trans.localEulerAngles = Vector3(0, units[1].direction.x < 0 and 180 or 0, 0)
                trans.localPosition = s.map:GetPosition(units[1].pos.x, units[1].pos.y)
                if s.isOwn then s.map:ViewFollow(trans) end

                local fef = AddFullEffect(s, FullSkill_SuDuXian, s.hero_d.isAtk, 0, true, 1)

                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(1)
                    end
                    units = s.dat.units
                    trans.localPosition = s.map:GetPosition(units[1].pos.x, units[1].pos.y)

                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                EF.Alpha(up, 0.2, 0)
                                tg:AddStunEffect(s.dat.dat.keepSec)
                                BuildObjectForPrefab(s, tg.go, s.ef.transform:GetChild(1).gameObject, "skc_76_2")
                                s.action = nil
                                s:Destruct(1)
                                EffectFadeOut(fef, 0)
                                return
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 77 挑衅 -----------
    [77] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.isOwn then s.map:ViewMoveToBD(s.hero_d.rival) end
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, s.ef.name, BU_Map.SkillSkyDepth, s.dat.dat.keepSec)
        up.transform.localPosition = Vector3(0,0,0)
        up.transform.localEulerAngles = s.hero_d.isAtk and Vector3(0,0,0) or Vector3(0, 180, 0)

        s:Destruct(s.dat.dat.keepSec)
    end,
--endregion

--region ----------- 78 蛮荒践踏 -----------
    [78] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skc_78", BU_Map.SkillFootDepth)
        up:SetActive(false)
        coroutine.step()
        up:SetActive(true)
        EF.ShakePosition(s.map.go.transform.parent, "y", 30, "time", 0.24, "islocal", true)
        
        local kp = s.dat.dat.keepSec
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then tg:AddStunEffect(kp) end
            end
        end
        coroutine.wait(0.26)
        EF.ClearITween(s.map.go.transform.parent)
        s.map.go.transform.parent.localPosition = Vector3.zero
        s:Destruct(2)
    end,
--endregion

--region ----------- 80 白马飞驰 -----------
    [80] = function (s)
        local up = nil
        local kp = s.ef.transform
        local tgs = nil
        local fef = AddFullEffect(s, FullSkill_SuDuXian, false, 0, true, 1)
        if s.dat.step < 2 then
            up = BuildObjectForPrefab(s, s.hero_v.go, kp:GetChild(0).gameObject, "skc_80_a")
            up.transform.localPosition = Vector3(65, 40, 0)
            BuildObjectForPrefab(s, s.hero_v.go, kp:GetChild(1).gameObject, "skc_80_b")
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.isOwn then s.map:ViewMoveToBU(s.hero_v) end

        while s.dat.isAlive do coroutine.step() end

        kp = s.dat.buff.leftSecond
        tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg and not isnull(tg.body) then tg:AddStunEffect(kp) end
            end
        end
        EffectFadeOut(fef, 0.5)
        s:Destruct(0.5)
    end,
--endregion

--region ----------- 81 冰天刃舞 -----------
    [81] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local ska = s.ef.transform:GetChild(0).gameObject
                local up = BuildWidget(s, typeof(UIParticle), s.map.go, ska, "skc_81_a", BU_Map.SkillHeadDepth)
                local b = up.transform:Find("bingqiu")
                local dev = Vector3(0, 50, 0)
                b.transform:Find("star"):GetCmp(typeof(UIParticle)).Relative = s.map.go.transform
                up.transform.localPosition = s.hero_v.go.transform.localPosition + dev
                local sps = { }
                sps[1] = up
                ska = s.ef.transform:GetChild(1).gameObject
                local skb = s.ef.transform:GetChild(2).gameObject
                if s.isOwn then s.map:ViewFollow(up.transform) end

                local kp = s.dat.buff.leftSecond
                local fef = nil
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(1)
                    end
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            -- 冰冻效果
                            if tg then tg:AddBleedEffect(kp) end
                        end
                    end
                    tgs = s.dat.units
                    if tgs[1].status == 1 then
                        up.transform.localPosition = s.map:GetPosition(tgs[1].pos.x, tgs[1].pos.y) + dev
                    elseif up and not isnull(up) then
                        if tgs[1].status == 2 then
                            fef = AddFullEffect(s, FullSkill_Ice, s.hero_d.isAtk, 0, true, 0.8)
                            local p = BuildWidget(s, typeof(UIParticle), s.map.go, skb, "skc_81_c", BU_Map.SkillHeadDepth)
                            p.transform.localPosition = s.map:GetPosition(tgs[1].pos.x, tgs[1].pos.y)
                            EF.ShakePosition(s.map.go.transform.parent, "y", 30, "time", 0.24, "islocal", true)
                        end
                        EF.Alpha(up.gameObject, 0.2, 0)
                        up:Stop()
                        up = nil
                    end
                    local v = nil
                    local sd = nil
                    for i = 2, cnt do
                        if tgs[i].status == 1 then
                            if not sps[i] or sps[i].isStopped then
                                if not sps[i] then sps[i] = BuildWidget(s, typeof(UIParticle), s.map.go, ska, "skc_81_b" .. i, BU_Map.SkillHeadDepth) end
                                v = s.map:GetVector(tgs[i].direction.x, tgs[i].direction.y)
                                sps[i].transform.localEulerAngles = Vector3(0, 0, _math.Atan2(v.y, v.x) * _math.Rad2Deg)
                                sd = sps[i]:GetCmpInChilds(typeof(UISprite), false)
                                if sd then
                                    sd.transform.localPosition = Vector2(-v.y, -v.x).normalized * dev.y
                                    EF.Alpha(sd, 0.2, 0.25)
                                end
                                sps[i]:Play()
                            end
                            sps[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y) + dev
                        elseif sps[i] and not sps[i].isStopped then
                            sps[i]:Stop()
                            if sd then EF.Alpha(sd, 0.2, 0) end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 82 五雷正法 -----------
    [82] = function (s)
        local fef = AddFullEffect(s, FullSkill_LeiDian2, s.hero_d.isAtk, 0, false, 1.4)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.25
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 6
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local cp = AM.LoadAudioClip("sound_skc_30_c")
                local skc_a = s.ef.transform:GetChild(0).gameObject
                local skc_b = s.ef.transform:GetChild(1).gameObject
                local skc_c = s.ef.transform:GetChild(2).gameObject
                local skc_d = s.ef.transform:GetChild(3).gameObject
                local pts = { }
                local kp = s.dat.units
                for i = 1, cnt do
                    pts[i] = BuildWidget(s, typeof(UIParticle), s.map.go, skc_a, "skc_82_a", BU_Map.SkillFootDepth)
                    pts[i].transform.localPosition = s.map:GetPosition(kp[i].pos.x, kp[i].pos.y)
                    pts[i].depth = s.map:GetDepth(kp[i].pos.y) + BU_Map.SkillDepthSpace
                    pts[i]:SetActive(false)
                end
                coroutine.step()
                for i = 1, cnt do pts[i]:SetActive(true) end

                kp = s.dat.buff.leftSecond
                s.action = function ()
                    if not s.dat.isAlive then
                        local p = BuildWidget(s, typeof(UIParticle), s.map.go, skc_b, "skc_81_b", BU_Map.SkillHeadDepth)
                        p.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
                        for i = 1, cnt do 
                            if not isnull(pts[i]) then
                                pts[i]:Stop()
                                EF.Alpha(pts[i], 0.2, 0).ignoreTimeScale = false
                            end 
                        end
                        s.action = nil
                        EffectFadeOut(fef, 2)
                        s:Destruct(1)
                    elseif not s.ado.isPlaying then
                        s.ado.clip = cp
                        s.ado.loop = true
                        s.ado:Play()
                    end
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        local t = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                t = tg.trans:FindChild("skc_82_c")
                                if t then t:GetCmp(typeof(TweenAlpha)):ResetToBeginning()
                                else 
                                    local buf = BuildWidget(s, typeof(UIParticle), tg.go, ois(tg, BU_Hero) and skc_d or skc_c, "skc_82_c", tg.depth + BU_Map.SkillDepthSpace + 1, kp)
                                    if ois(tg, BU_Hero) then buf.transform.localPosition = buf.transform.localPosition + Vector3(0,45,0)
                                    else buf.transform.localPosition = buf.transform.localPosition + Vector3(0, 30, 0) end
                                end
                            end
                        end
                    end
                    tgs = s.dat.units
                    for i = 1, cnt do
                        pts[i].transform.localPosition = s.map:GetPosition(tgs[i].pos.x, tgs[i].pos.y)
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 83 太公兵法 -----------
    [83] = function (s)
        if s.dat.step < 2 then
            BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_83_a",BU_Map.SkillHeadDepth)
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.buff then
            local kp = s.dat.dat.keepSec
            local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_83_b",BU_Map.SkillHeadDepth, kp)
            buf.transform.localPosition = Vector3(10000, 10000, 10000)

            local tgs = s.dat:GetHitTarget()
            if tgs and #tgs > 0 then
                local tg = nil
                for i = 1, #tgs do
                    tg = tgs[i].body
                    if tg then
                        tg = BuildCopy(s, buf, tg.go)
                        Destroy(tg.cachedGameObject, kp + 0.3)
                        tg.transform.localPosition = Vector3.zero
                    end
                end
            end
            if s.isOwn then
                coroutine.wait(1)
                s.map:ViewMoveX(s.dat.map:SearchUnitFocusX(not s.hero_d.isAtk))
            end
            s:Destruct(_math.Max(3, kp))
        else
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_21"), BGM.soeVolume)
            s:Destruct(3)
        end
    end,
--endregion

--region ----------- 84 凤舞九天 -----------
    [84] = function (s)
        if s.isOwn then s.map:ViewMoveToBU(s.hero_v) end
        BuildObjectForPrefab(s, s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_84_a")
        while s.dat.step < 2 do coroutine.step() end
        if s.isOwn then
            s.map:ViewMoveToBU(s.hero_v.rival)
            s.map.view.lockTime = s.dat.dat.keepSec
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt > 0 then
                local efi = s.ef.transform
                local efp = {
                    efi:GetChild(1),
                    efi:GetChild(2),
                    efi:GetChild(3),
                    efi:GetChild(4),
                }
                local efe = {
                    efi:GetChild(5),
                    efi:GetChild(6),
                    efi:GetChild(7),
                    efi:GetChild(8),
                }
                local eff = efi:GetChild(10)
                efi = efi:GetChild(9)

                local pro = { }
                local expo = { }
                local tms = { }
                local tgs = nil
                while s.dat.isAlive do
                    tgs = s.dat.units
                    for i = 1, cnt do
                        if tgs[i].time >= 0 and tgs[i].status > 0 and tgs[i].status <= 4 then
                            if isnull(pro[i]) then
                                pro[i] = BuildObjectForPrefab(s, s.map.go, efp[tgs[i].status], "skc_84_b")
                                pro[i].transform.localPosition = s.hero_v.rival.trans.localPosition
                                pro[i].transform.localEulerAngles = Vector3(0, 0, rd(-45, 45))
                                tms[i] = Time.time + 0.22
                                expo[i] = BuildWidget(s, typeof(UIParticle), s.map.go, efe[tgs[i].status], "skc_84_c", BU_Map.SkillHeadDepth)
                                expo[i].transform.localPosition = s.hero_v.rival.trans.localPosition
                            elseif tms[i] <= Time.time and not expo[i].activeSelf then expo[i]:SetActive(true)
                            end
                        end
                    end
                    tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        local t = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                if tgs[i]:GetBuff(87) ~= nil then
                                    t = tg.trans:FindChild("skc_84_d")
                                    if not isnull(t) then t:GetCmp(typeof(UIParticle)):Replay()
                                    else
                                        t = BuildWidget(s, typeof(UIParticle), tg.go, efi, "skc_84_d", BU_Map.SkillFootDepth)
                                        t.duration = s.dat.vals[1] * 0.001
                                    end
                                end
                                if tgs[i]:GetBuff(88) ~= nil then
                                    t = tg.trans:FindChild("skc_84_e")
                                    if not isnull(t) then t:GetCmp(typeof(UIParticle)):Replay()
                                    else
                                        t = BuildWidget(s, typeof(UIParticle), tg.go, eff, "skc_84_e", BU_Map.SkillFootDepth)
                                        t.duration = s.dat.vals[1] * 0.001
                                    end
                                end
                            end
                        end
                    end
                    coroutine.step()
                end
            end 
        end
        s:Destruct(5)
    end,
--endregion

--region ----------- 85 日月双辉 -----------
    [85] = function (s)
        if s.isOwn then s.map:ViewMoveToBU(s.hero_v) end
        while s.dat.step < 2 do coroutine.step() end
        local p = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_85_a", BU_Map.SkillHeadDepth)
        p.transform.localPosition = Vector3(0, 32, 0)
        local sk = s.dat.buff.leftSecond
        local tgs = nil
        local tg = nil
        if sk > 0 then
            tgs = s.dat:GetHitTarget()
            if tgs then
                local buf = BuildWidget(s, typeof(UIParticle), s.hero_v.rival.go, s.ef.transform:GetChild(3).gameObject, "skc_85_b", s.hero_v.depth + BU_Map.SkillDepthSpace)
                buf.transform.localScale = Vector3(1, 0.4, 1)
                buf.duration = sk
                for i = 1, #tgs do
                    tg = tgs[i].body
                    if ois(tg, BU_Soldier) then
                        Destroy(BuildCopy(s, buf, tg.go).gameObject, sk + 0.3)
                    end
                end
                buf.transform.localPosition = Vector3(0, 20, 0)
            end
        end
        if s.isOwn then
            coroutine.wait(0.5)
            s.map:ViewMoveToBU(s.hero_v.rival)
            s.map.view.lockTime = 3
            coroutine.wait(0.2)
        else coroutine.wait(0.7)
        end
        p = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_85_c", BU_Map.SkillHeadDepth)
        p.transform.localPosition = s.hero_v.rival.trans.localPosition
        sk = s.ef.transform:GetChild(2).gameObject
        while s.dat.step < 3 do coroutine.step() end

        while s.dat.isAlive do
            tgs = s.dat:GetHitTarget()
            if tgs and #tgs > 0 then
                local ub = nil
                local uc = nil
                for i = 1, #tgs do
                    tg = tgs[i].body
                    if tg then
                        if ub then
                            uc = BuildCopy(s, ub, s.map.go)
                            Destroy(uc.gameObject, ub.duration + 0.3)
                            uc.transform.localPosition = tg.trans.localPosition + Vector3(0, ois(tg, BU_Hero) and 50 or 30, 0)
                        else
                            ub = BuildWidget(s, typeof(UIParticle), s.map.go, sk, "skc_85_d", BU_Map.SkillHeadDepth)
                            ub.transform.localPosition =  tg.trans.localPosition + Vector3(0, ois(tg, BU_Hero) and 50 or 30, 0)
                            if s.hero_d.dat.IsStar then
                                ub.transform.localScale = ub.transform.localScale * 1.33
                            end
                        end
                    end
                end
            end
            coroutine.step()
        end
        s:Destruct(5)
    end,
--endregion

--region ----------- 86 死亡之舞 -----------
    [86] = function (s)
        local kp = s.dat.dat.keepSec
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skc_86", BU_Map.SkillFootDepth, kp + 0.2)
        if s.dat.step < 2 then
            up:SetActive(false)
            coroutine.step()
            up:SetActive(true)
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            if s.isOwn then
                s.map:ViewMoveToBU(s.hero_v)
                s.map.view.lockTime = kp + 1
            end
        else s:Destruct() 
        end
    end,
--endregion

--region ----------- 87 黄天秘法 -----------
    [87] = function (s)
        local up = nil
        local sk = s.ef.transform
        if s.dat.step < 2 then
            up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, sk:GetChild(0).gameObject, "skc_87_a", BU_Map.SkillFootDepth)
            up:SetActive(false)
            if s.isOwn then
                s.map:ViewMoveToBD(s.hero_d)
                s.map.view.lockTime = 2
            end
            local t = Time.time + 0.15
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up:SetActive(true)

            while s.dat.step < 2 do coroutine.step() end
        end
        up = BuildObjectForPrefab(s, s.hero_v.rival.go, sk:GetChild(1).gameObject, "skc_87_b")
        up:SetActive(false)
        local cnt = 5 - s.dat.vals[1]
        if cnt > 0 then
            sk = up.transform:GetChild(0)
            local idxs = {0, 1, 2, 3, 4}
            while cnt > 0 do
                sk:GetChild(idxs[cnt]).gameObject:SetActive(false)
                cnt = cnt - 1
            end
        end
        if s.isOwn then
            s.map:ViewMoveToBD(s.hero_d.rival)
            s.map.view.lockTime = 4
        end
        coroutine.step()
        up:SetActive(true)
        coroutine.wait(2)
        EF.ShakePosition(s.map.go.transform.parent, "amount", Vector3(30, 30, 0), "time", 0.24, "islocal", true)
        coroutine.wait(0.26)
        EF.ClearITween(s.map.go.transform.parent)
        s.map.go.transform.parent.localPosition = Vector3.zero
        s:Destruct(2)
    end,
--endregion

--region ----------- 88 风牙破天 -----------
    [88] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local ef = BuildObjectForPrefab(s, s.hero_v.rival.go, s.ef, "skc_88")
        ef:SetActive(false)

        if s.hero_d.dat.IsStar then
            local d = ef.transform:FindChild("long_feng")
            if d then
                local d2 = ef:AddChild(d.gameObject, d.name).transform
                d2.localPosition = d.localPosition
                d2.localEulerAngles = Vector3(0, 140, 0)
                d2.localScale = d.localScale
            end
        end
        if s.isOwn then
            s.map:ViewMoveToBD(s.hero_d.rival)
            s.map.view.lockTime = 3
        end
        coroutine.step()
        ef:SetActive(true)
        s:Destruct(3)
    end,
--endregion

--region ----------- 89 魔音摄魄 -----------
    [89] = function (s)
        local up = nil
        local sk = s.ef.transform
        if s.dat.step < 2 then
            up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, sk:GetChild(0).gameObject, "skc_89_a", BU_Map.SkillFootDepth)
            up.transform.localEulerAngles = Vector3(0, s.hero_d.isAtk and 0 or 180, 0)
            up.transform.localPosition = Vector3(80, 0, 0)
            up:SetActive(false)
            if s.isOwn then
                s.map:ViewMoveToBD(s.hero_d)
                s.map.view.lockTime = 2
            end
            local t = Time.time + 0.15
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up:SetActive(true)
            while s.dat.step < 2 do coroutine.step() end
        end
        up = BuildObjectForPrefab(s, s.hero_v.rival.go, sk:GetChild(1).gameObject, "skc_89_b")
        up:SetActive(false)
        if s.isOwn then
            coroutine.wait(0.3)
            s.map:ViewMoveToBD(s.hero_d.rival)
            s.map.view.lockTime = 4
            coroutine.wait(0.2)
        else coroutine.wait(0.5)
        end
        up:SetActive(true)

        local p = BuildWidget(s, typeof(UIParticle), s.hero_v.rival.go, sk:GetChild(2).gameObject, "skc_89_c", BU_Map.SkillFootDepth, s.dat.dat.keepSec)
        p.transform.localPosition = Vector3(0, 40, 0)
        s:Destruct(s.dat.dat.keepSec + 2)
    end,
--endregion

--region ----------- 90 碧落 -----------
    [90] = function (s)
        local up = nil
        local sk = s.ef.transform
        if s.dat.step < 2 then
            up = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(0).gameObject, "skc_90_a", BU_Map.SkillFootDepth)
            local vec = up.transform.localScale
            up.transform.localScale = vec * 1.5
            up:SetActive(false)
            local t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up.transform.localPosition = s.hero_v.trans.localPosition
            up:SetActive(true)
            
            t = Time.time + 0.4
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            if s.isOwn then
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 3
            end

            up = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(1).gameObject, "skc_90_b", BU_Map.SkillFootDepth)
            vec = up.transform.localScale
            up.transform.localScale = vec * 1.5
            up:SetActive(false)
            t = Time.time + 0.2
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up.transform.localPosition = s.hero_v.rival.trans.localPosition
            up:SetActive(true)
            while s.dat.step < 2 do coroutine.step() end
        end
        up = BuildWidget(s, typeof(UIWidget), s.map.go, sk:GetChild(2).gameObject, "skc_90_c", BU_Map.SkillHeadDepth, s.dat.dat.keepSec)
        up.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
        up.transform.localScale = Vector3((s.dat.vals[6] - s.dat.vals[4]) * 0.125 + 0.125, (s.dat.vals[7] - s.dat.vals[5]) * 0.15 + 0.05, 1)
        s:Destruct(2 + s.dat.dat.keepSec)
    end,
--endregion

--region ----------- 91 掌控 -----------
    [91] = function (s)
        local up = nil
        local sk = s.ef.transform
        if s.dat.step < 2 then
            up = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(0).gameObject, "skc_91_a", BU_Map.SkillFootDepth)
            local vec = up.cachedTransform.localScale
            up.transform.localScale = vec * 1.5
            up:SetActive(false)
            local t = Time.time + 0.2
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up.transform.localPosition = s.hero_v.trans.localPosition
            up:SetActive(true)
            
            t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            if s.isOwn then
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 3
            end
            while s.dat.step < 2 do coroutine.step() end
            if s.dat.buff ~= nil then
                up = BuildWidget(s, typeof(UIWidget), s.hero_v.rival.go, sk:GetChild(1).gameObject, "skc_91_b", BU_Map.SkillFootDepth, s.dat.buff.leftSecond)
                up:SetActive(false)
                coroutine.wait(0.2)
                up:SetActive(true)
            end
        end
        s:Destruct(2 + (s.dat.buff == nil and 0 or s.dat.buff.leftSecond))
    end,
--endregion

--region ----------- 92 七进七出 -----------
    [92] = function (s)
        local up = nil
        local sk = s.ef.transform
        local fs = BuildWidget(s, typeof(UIWidget), s.map.go, sk:GetChild(3).gameObject, "skc_92_d", BU_Map.SkillSkyDepth)
        if s.dat.step < 2 then
            up = BuildObjectForPrefab(s, s.hero_v.go, sk:GetChild(0).gameObject, "skc_92_a")
            up:SetActive(false)
            s.map:ViewMoveToBU(s.hero_v)
            s.map.view.lockTime = 1
            coroutine.step()
            up:SetActive(true)
            while s.dat.isAlive and s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.step == 2 then
            s.hero_v:HideBody()
            up = BuildObjectForPrefab(s, s.hero_v.rival.go, sk:GetChild(1).gameObject, "skc_92_b")
            up:SetActive(false)
            s.map:ViewMoveToBU(s.hero_v.rival)
            s.map.view.lockTime = s.dat.dat.keepSec
            coroutine.step()
            up:SetActive(true)
            coroutine.wait(s.dat.buff.leftSecond - 0.4)
            EF.ShakePosition(s.map.go.transform.parent, "y", 30, "time", 0.24, "islocal", true)
            while s.dat.isAlive and s.dat.step == 2 do coroutine.step() end

            up = BuildObjectForPrefab(s, s.hero_v.go, sk:GetChild(2).gameObject, "skc_92_c")
            up:SetActive(false)
            if s.dat.buff then
                local tgs = s.dat:GetHitTarget()
                if tgs and #tgs > 0 then
                    local tg = nil
                    for i = 1, #tgs do
                        tg = tgs[i].body
                        if tg then
                            tg:AddStunEffect(s.dat.buff.leftSecond)
                        end
                    end
                end
            end
            coroutine.step()
            up:SetActive(true)
            coroutine.wait(0.2)
            s.hero_v:ShowBody()
            EF.ShakePosition(s.map.go.transform.parent, "y", 30, "time", 0.24, "islocal", true)
            coroutine.wait(0.3)
            EF.ClearITween(s.map.go.transform.parent)
            s.map.go.transform.parent.localPosition = Vector3.zero
        end
        EF.Alpha(fs, 0.2, 0)
        Destroy(fs.gameObject, 0.2)
        s:Destruct(3)
    end,
--endregion

--region ----------- 93 能量充盈 -----------
    [93] = function (s)
        local up = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skc_93",BU_Map.SkillFootDepth)
        up:SetActive(false)
        coroutine.wait(0.24)
        up:SetActive(true)
        s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_5"), BGM.soeVolume)
        s:Destruct(3)
    end,
--endregion

--region ----------- 94 风火灭世 -----------
    [94] = function (s)
        local up = nil
        local sk = s.ef.transform
        local kp = s.dat.dat.keepSec
        if s.dat.step < 2 then
            up = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(0).gameObject, "skc_94_a", BU_Map.SkillHeadDepth)
            up.transform.localPosition = s.hero_v.trans.localPosition
            up:SetActive(false)
            local t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up:SetActive(true)
            t = Time.time + 0.2
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            if s.isOwn then
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = kp + 2
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        local kp2 = s.dat.buff ~= nil and s.dat.buff.leftSecond or 0
        local ws = { }

        up = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(1).gameObject, "skc_94_b", BU_Map.SkillFootDepth, kp)
        up.transform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
        up:SetActive(false)
        insert(ws, up)
        if s.dat.unitQty > 0 then
            up = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(2).gameObject, "skc_94_c", BU_Map.SkillFootDepth, kp)
            up.transform.localPosition = s.map:GetPosition(s.dat.units[1].pos.x, s.dat.units[1].pos.y)
            up:SetActive(false)
            insert(ws, up)
            local w = nil
            for i = 1, s.dat.unitQty do
                w = BuildCopy(s, up, s.map.go)
                w.transform.localPosition = s.map:GetPosition(s.dat.units[i].pos.x, s.dat.units[i].pos.y)
                EF.Alpha(w, 0.25, 0, kp).ignoreTimeScale = false
                Destroy(w.gameObject, kp + 0.3)
                w:SetActive(false)
                insert(ws, up)
            end
        end

        up = BuildWidget(s, typeof(UIParticle), s.map.go.transform.parent.gameObject, sk:GetChild(3).gameObject, "skc_94_d", BU_Map.SkillHeadDepth, kp)
        local buf = BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(4).gameObject, "skc_94_e", BU_Map.SkillHeadDepth)
        buf.loop = true
        buf.transform.localPosition = Vector3(10000, 10000, 10000)
        coroutine.step()
        coroutine.step()
        up:SetActive(true)

        for i = 1, #ws do ws[i]:SetActive(true) end

        local tgs = nil
        s.action = function ()
            if not s.dat.isAlive then
                s.action = nil
                s:Destruct(kp2 + _math.Max(1, kp2))
            end
            tgs = s.dat:GetHitTarget()
            if tgs and #tgs then
                local tg = nil
                local t = nil
                for i = 1, #tgs do
                    tg = tgs[i].body
                    if tg then
                        t = tg.trans:FindChild("skc_94_e")
                        if t then t:GetCmp(typeof(UITweener)):ResetToBeginning()
                        else
                            t = BuildCopy(s, buf, tg.go).transform
                            if ois(tg, BU_Hero) then
                                t.localPosition = Vector3.zero
                                t.localScale = Vector3.one * 1.2
                            else
                                t.localPosition = Vector3(5, 0, 0)
                                t.localScale = Vector3.one * rd(0.7, 0.94)
                            end
                            EF.Alpha(t, 0.25, 0, kp2).ignoreTimeScale = false
                        end
                        return
                    end
                end
            end
        end
        s:Destruct(kp + kp2 + 1)
    end,
--endregion

--region ----------- 95 火神破 -----------
    [95] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local ska = s.ef.transform:GetChild(0).gameObject
                local up = BuildWidget(s, typeof(UIWidget), s.map.go, ska, "skc_95_a", BU_Map.SkillHeadDepth)
                ska = s.dat.units
                up.transform.localPosition = s.map:GetPosition(ska[1].pos.x, ska[1].pos.y)
                up:SetActive(false)
                if not s.hero_d.isAtk then
                    up.cachedTransform.localEulerAngles = Vector3(0, 180, 0)
                end
                coroutine.step()

                up:SetActive(true)
                if s.isOwn then s.map:ViewFollow(up.transform) end
                AddAudioSource(up.gameObject):PlayOneShot(AM.LoadAudioClip("sound_skc_30_a"))
                local kp = s.dat.buff ~= nil and s.dat.buff.leftSecond or 0

                ska = s.ef.transform:GetChild(1).gameObject
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(_math.Max(1, kp))
                    end
                    local tgs = s.dat:GetHitTarget()
                    if tgs and #tgs > 0 then
                        local tg = nil
                        local t = nil
                        for i = 1, #tgs do
                            tg = tgs[i].body
                            if tg then
                                if ois(tg, BU_Hero) then
                                    if up and s.map.view:IsFollow(up.transform) then
                                        s.map:ViewStopFollow()
                                        s.map.view.lockTime = 2
                                    end
                                    BuildWidget(s, typeof(UIParticle), tg.go, ska, "skc_95_a", BU_Map.SkillHeadDepth)

                                    if kp > 0 then
                                        t = tg.trans:FindChild("skc_95_c")
                                        if t then t:GetCmp(typeof(UITweener)):ResetToBeginning()
                                        else
                                            t = BuildWidget(s, typeof(UIParticle), tg.go, s.ef.transform:GetChild(2).gameObject, "skc_95_c", BU_Map.SkillHeadDepth)
                                            t.transform.localPosition = Vector3.zero
                                            t.transform.localScale = Vector3.one * 1.2
                                            EF.Alpha(t, 0.25, 0, kp).ignoreTimeScale = false
                                        end
                                    end
                                end
                            end
                        end
                    end

                    tgs = s.dat.units
                    if s.dat.isAlive and tgs[1].status == 1 then
                        up.transform.localPosition = s.map:GetPosition(tgs[1].pos.x, tgs[1].pos.y)
                    elseif up and not isnull(up) then
                        EF.Alpha(up, 0.2, 0)
                        Destroy(up.gameObject, 0.2)
                        up = nil
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 96 天魔妙舞 -----------
    [96] = function (s)
        local up = nil
        local sk = s.ef.transform
        if s.dat.step < 2 then
            up = BuildWidget(s, typeof(UIWidget), s.map.go, sk:GetChild(0).gameObject, "skc_96_a", BU_Map.SkillHeadDepth)
            up.transform.localPosition = s.hero_v.trans.localPosition
            up:SetActive(false)
            local t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            up:SetActive(true)

            t = Time.time + 0.2
            while s.dat.step < 2 and t > Time.time do coroutine.step() end
            s.hero_v:HideBody()
            t = Time.time + 0.3
            while s.dat.step < 2 and t > Time.time do coroutine.step() end

            if s.isOwn then
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 3
            end

            up = BuildWidget(s, typeof(UIWidget), s.hero_v.rival.go, sk:GetChild(1).gameObject, "skc_96_b", BU_Map.SkillHeadDepth)
            up:SetActive(false)

            local up2 = BuildWidget(s, typeof(UIParticle), s.map.go.transform.parent.gameObject, sk:GetChild(3).gameObject, "skc_94_d", BU_Map.SkillHeadDepth, s.dat.dat.keepSec)
            up2:SetActive(false)
            coroutine.step()
            up:SetActive(true)
            up2:SetActive(true)
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.step == 2 then
            local t =s.dat.dat.keepSec * 0.3 - 0.2
            if t > 0 then coroutine.wait(t) end
            BuildWidget(s, typeof(UIParticle), s.map.go, sk:GetChild(2).gameObject, "skc_96_c", BU_Map.SkillHeadDepth).transform.localPosition = s.hero_v.rival.trans.localPosition
            BuildWidget(s, typeof(UIWidget), s.map.go, sk:GetChild(0).gameObject, "skc_96_a", BU_Map.SkillHeadDepth).transform.localPosition = s.hero_v.trans.localPosition
            coroutine.wait(0.2)
            s.hero_v:ShowBody()
        end
        s:Destruct(2)
    end,
--endregion

--region ----------- 97 号令群雄 -----------
    [97] = function (s)
        if s.dat.step < 2 then
            s.ado:PlayOneShot(AM.LoadAudioClip("sound_skc_3"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        local kp = s.dat.dat.keepSec
        BuildWidget(s, typeof(UIWidget), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_97_0", BU_Map.SkillFootDepth, 3).transform.localScale = Vector3(1, 1, 0)
        local buf = s.ef.transform:GetChild(1).gameObject
        if s.isOwn then s.map:ViewMoveX(s.hero_d.map:SearchUnitFocusX(s.hero_d.isAtk)) end

        tgs = s.dat:GetHitTarget()
        if tgs then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    BuildWidget(s, typeof(UIWidget), tg.go, buf, "skc_97_1", BU_Map.SkillHeadDepth, kp).transform.localPosition = Vector3(0, 60, 0)
                end
            end
        end
        s:Destruct(kp)
    end,
--endregion

--region ----------- 98 星罗棋布 -----------
    [98] = function (s)
        local kp = s.dat.dat.keepSec
        if s.dat.step < 2 then
            BuildWidget(s, typeof(UIWidget), s.map.go.transform.parent.gameObject, s.ef.transform:GetChild(0).gameObject, "skc_98_0", BU_Map.SkillSkyDepth, kp + 3)
            local up = BuildWidget(s, typeof(UIWidget), s.map.go, s.ef.transform:GetChild(1).gameObject, "skc_98_1", BU_Map.SkillSkyDepth, kp + 1)
            up:SetActive(false)
            if s.isOwn then
                local t = Time.time + 0.2
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = kp + 1
                up.transform.localPosition = s.hero_v.rival.trans.localPosition
                up:SetActive(true)
            end
            while s.dat.step < 2 do coroutine.step() end
        end
        if s.dat.isAlive then
            local cnt = s.dat.unitQty
            if cnt <= 0 then s:Destruct()
            else
                local ska = s.ef.transform:GetChild(2).gameObject
                local skb = s.ef.transform:GetChild(3).gameObject

                local sts = { }
                local units = nil
                s.action = function ()
                    if not s.dat.isAlive then
                        s.action = nil
                        s:Destruct(3)
                    end
                    units = s.dat.units
                    for i = 1, cnt do
                        if units[i].status == 2 then
                            if not sts[i] or isnull(sts[i]) then
                                sts[i] = BuildWidget(s, typeof(UIWidget), s.map.go, rd(0, 100) < 50 and ska or skb, "skc_98_2", BU_Map.SkillHeadDepth, 1.8)
                                Destroy(sts[i], 2.2)
                                sts[i].transform.localPosition = s.map:GetPosition(units[i].pos.x, units[i].pos.y)
                                sts[i].transform.localEulerAngles = Vector3.zero
                            end
                        end
                    end
                end
            end
        else s:Destruct()
        end
    end,
--endregion

--region ----------- 99 神罚 -----------
    [99] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
            end
            while s.dat.step < 2 do coroutine.step() end
        end

        local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skc_99", BU_Map.SkillFootDepth)
        up.cachedTransform.localPosition = s.hero_v.rival.trans.localPosition
        up.cachedGameObject:SetActive(true)
        AddAudioSource(up.cachedGameObject):PlayOneShot(AM.LoadAudioClip("sound_skc_20"))
        s:Destruct(3)
    end,
--endregion

--region ----------- 100 不灭铁壁 -----------
    [100] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local ef = s.hero_v.trans:FindChild("skc_100_a")
        if isnull(ef) then
            ef = BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skc_100_a", BU_Map.SkillDepthSpace)
        end
        ef = ef:GetCmpsInChilds(typeof(UIParticle))
        for i = 0, ef.length - 1 do ef[i]:Play() end
        local ef = s.hero_v.trans:FindChild("skc_100_b")
        if isnull(ef) then
            ef = BuildObjectForPrefab(s, s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_100_b")
            ef = ef.transform
            ef.localPosition = Vector3(0, 32, 0)
            ef.localEulerAngles = Vector3(-25, 0, 0)
            ef = ef.gameObject
            ef:SetActive(false)
            coroutine.step()
            ef:SetActive(true)
        else ef.gameObject:SetActive(true)
        end

        while s.dat.isAlive do coroutine.step() end
        if s.dat.step == 254 then
            s.map:ViewMoveToBD(s.hero_d.rival)
            s.map.view.lockTime = 2
            ef = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(2).gameObject, "skc_100_c")
            ef:SetActive(true)

            EF.ShakePosition(s.map.go.transform.parent, "y", 30, "time", 0.24, "islocal", true)
            coroutine.wait(0.26)
            EF.ClearITween(s.map.go.transform.parent)
            s.map.go.transform.parent.localPosition = Vector3.zero
        end
        s:Destruct()
    end,
--endregion

--region ----------- 101 饕餮盛宴 -----------
    [101] = function (s)
        if s.dat.step < 2 then
            if s.isOwn then
                local t = Time.time + 0.3
                while s.dat.step < 2 and t > Time.time do coroutine.step() end
                s.map:ViewMoveToBD(s.hero_d.rival)
                s.map.view.lockTime = 5
            end
            while s.dat.step < 2 do coroutine.step() end
        end

        local temp = BuildObjectForPrefab(s, s.map.go, s.ef.transform:GetChild(0).gameObject, "skc_101_a")
        temp.transform.position = s.hero_v.rival.trans.position
        local rx = s.dat.dat.rangeX.value / 6.00
        local ry = s.dat.dat.rangeY.value / 4.00
        local voc = temp.transform:FindChild("ef_skc_taotieshengyan_a").localScale
        voc = Vector3(voc.x * rx, voc.y * ry, voc.z)
        temp.transform:FindChild("ef_skc_taotieshengyan_a").localScale = voc
        coroutine.wait(2.5)
        Destroy(temp)
        s.map:ViewMoveToBU(s.hero_v)

        temp = s.dat.buff
        if temp ~= nil then
            BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(1).gameObject, "skc_100_b", BU_Map.SkillHeadDepth)
            rx = temp.sn
            temp = s.hero_d:GetBuff(rx)
            while temp ~= nil do
                coroutine.step()
                if temp.sn ~= rx then
                    temp = s.hero_d:GetBuff(rx)
                    if temp ~= nil and temp.sn ~= rx then break end
                end
            end
        end
        s:Destruct()
    end,
--endregion
}
--36 三连射
ShowFunc[36] = ShowFunc[23]
--53 乱箭飞射
ShowFunc[53] = ShowFunc[11]
--55 月光斩
ShowFunc[55] = ShowFunc[39]
--79 金刚不坏
ShowFunc[79] = ShowFunc[24]


function _skc.ctor(s, map, go)
    _base.ctor(s, map, go)
    s.enabled = false
    if map == nil or go == nil then s:Destruct() return end
end

--初始化数据
-- param[dat] : BD_SKC
function _skc.Init(s, dat)
    assert(dat and getmetatable(dat) == QYBattle.BD_SKC, "Init dat must be BD_SKC")
    s.dat = dat
    if dat.isAlive then
        local map = s.map
        local sn = dat.sn
        s.ef = map:GetSkcEffect(sn)
--        s.atlas = map:GetSkcAtlas(sn)
        if s.ef or sn == 16 or sn == 21 or sn == 42 or sn == 45 or sn == 77 then
            local func = ShowFunc[sn]
            if func ~= nil then
                dat.body = s
                s.hero_d = dat.hero
                s.hero_v = s.hero_d.isAtk and map.atkHero or map.defHero
                s.isOwn = s.hero_d.isAtk == map.own
                if dat.step < 2 and map.OnCastSkill ~= nil then
                    map.OnCastSkill(s.hero_d, sn)
                end

                s.ado = AddAudioSource(s.go:AddChild("Audio_"..sn))

                s.objs = { }
                s.cor = coroutine.create(func)
                coroutine.resume(s.cor, s)

                s:Destruct(dat.maxLifeTime)
                return
            end
        else
            print("can not load skill " .. DB.GetSkc(sn).nm .. "[" .. sn .. "] asset!")
        end
    end
    s:Destruct()
end

function _skc.Update(s)
    if s.action ~= nil then s.action() end
end

function _skc.Dispose(s)
    if s ~= nil then
        _base.Dispose(s)
        if s.ado ~= nil then Destroy(s.ado.gameObject) end
        local obj = nil
        if s.objs ~= nil and #s.objs > 0 then
            for i = 1, #s.objs do
                obj = s.objs[i]
                if not isnull(obj) then Destroy(obj) end
            end
        end
        s.objs = nil
        if s.cor ~= nil and coroutine.status(s.cor) ~= "dead" then coroutine.stop(s.cor) end
    end
end

