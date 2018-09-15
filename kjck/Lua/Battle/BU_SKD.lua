
local isnull = tolua.isnull
local _math = Mathf
local rd = _math.random
local insert = table.insert

local _base = BU_Unit

local _skd = class(_base)
BU_SKD = _skd

local function BuildWidget(s, tp, prt, pfb, nm, dp, tm)
    tm = tm or 0
    local go = prt:AddChild(pfb, nm)
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

local function BuildCopy(s, wdt, prt)
    local cp = nil
    if s and wdt and prt then
        cp = prt:AddWidget(typeof(UICopy), wdt.nm)
        insert(s.objs, cp.cachedGameObject)
        cp.copy = wdt
        cp.cachedTransform.localPosition = wdt.cachedTransform.localPosition
        cp.cachedTransform.localScale = wdt.cachedTransform.localScale
        cp.depth = wdt.depth
        local wd = wdt:GetCmp(typeof(BindSkillDepth))
        if wd then cp.cachedGameObject:AddChild(typeof(BindSkillDepth)):Bind(wd.bindType, wd, offset) end
        EF.BindWidgetDepth(cp, wdt)

        prt = wdt.cachedTransform.childCount
        for i = 0, prt - 1 do
            wd = wdt.cachedTransform:GetChild(i):GetCmp(typeof(UIWidget))
            if wd then BuildCopy(s, wd, cp.cachedGameObject) end
        end
    end
    return cp
end

local function BuildObject(s, prt, pfb, nm)
    local go = prt:AddChild(pfb, nm)
    insert(s.objs, go)
    return go
end

local function BuildSpriteAnim(s, prt, nm, dp, fps, loop, tm, pp)
    fps = fps or 24
    loop = loop == nil and true or loop
    tm = tm or 0
    pp = pp == nil and true or pp
    local go = prt:AddChild(nm)
    insert(s.objs, go)
    local sp = go:AddCmp(typeof(UISprite))
    sp.depth = dp
    sp.atlas = s.atlas
    sp.spriteName = nm.."_01"
    sp:MakePixelPerfect()
    local spa = go:AddCmp(typeof(UISpriteAnimation))
    spa.ignoreTimeScale = false
    spa.loop = loop
    spa.framesPerSecond = _math.max(1, fps)
    spa.namePrefix = nm
    spa.pixelPerfect = pp
    if tm > 0 or not loop then
        local ta = EF.Alpha(go, 0.2, 0)
        ta.ignoreTimeScale = false
        ta.delay = tm > 0 and tm or spa.frames / spa.framesPerSecond
        Destroy(go, ta.delay + 0.24)
    end
    return sp
end

local function AddAudioSource(go, loop)
    loop = loop == nil and false or loop
    local ads = nil
    if go then
        ads = go:AddCmp(typeof(AudioSource))
        ads.minDistance = 3
        ads.volume = BGM.soeVolume
        ads.loop = loop
    end
    return ads
end

local ShowFunc = {

--region ----------- 1 鼓舞 -----------
    [1] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skd_1_b", BU_Map.SkillHeadDepth, kp)
        buf.cachedTransform.localPosition = Vector3(10000, 10000, 10000)

        local tgs = s.dat:GetHitTarget()
        if tgs ~= nil and #tgs > 0 then
            local tg = nil
            local go = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    go = tg.gameObject.transform:FindChild("skd_1_b")
                    if not isnull(go) then Destroy(go.gameObject) end
                    tg = BuildCopy(s, buf, tg.gameObject)
                    go = tg.gameObject
                    if not isnull(go) then Destroy(go, kp + 0.3) end
                    tg.go.transform.localPosition = Vector3.zero
                end
            end
        end
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 2 援军 -----------
    [2] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        s:Destruct()
    end,
--#endregion

--region ----------- 3 遮天蔽日 -----------
    [3] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        local go = s.hero_v.rival.go.transform:FindChild("skd_2_b")
        if not isnull(go) then Destroy(go.gameObject) end
        local buf = BuildWidget(s, typeof(UIParticle), s.hero_v.rival.go, s.ef, "skd_2_b", BU_Map.SkillHeadDepth, kp)
        buf.cachedTransform.localPosition = Vector3(0, 80, 0)

        local so = Vector3 * 0.8
        local tgs = s.dat:GetHitTarget()
        if tgs ~= nil and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if not ois(tg, BU_Hero) then
                    go = tg.go.transform:FindChild("skd_2_b")
                    if not isnull(go) then Destroy(go.gameObject) end
                    tg = BuildCopy(s, buf, tg.go)
                    tg = tg.go.transform
                    tg.localPosition = Vector3(5, 65, 0)
                    tg.localScale = so
                end
            end
        end
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 4 巨石碾压 -----------
    [4] = function (s)
        while s.dat.step < 2 do coroutine.step() end

        local clip = AM.LoadAudioClip("sound_skc_20")
        local star = BuildObject(s, s.map.go, s.ef.transform:GetChild(0).gameObject, "skd_4")
        star:SetActive(false)
        star.transform.localEulerAngles = Vector3(0, 0,s.hero_d.isAtk and rd(12, 20) or rd(-12, -20))
        coroutine.step()
        star:SetActive(true)
        star = star.transform
        star.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
        EF.MoveTo(star:GetChild(0).gameObject, "time", 0.2, "position", Vector3.zero, "islocal", true, "easetype", iTween.EaseType.easeOutQuad)

        coroutine.wait(0.22)
        star:GetCmpInChilds(typeof(UIParticle)):Stop()
        local pt = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef.transform:GetChild(1).gameObject, "skd_4_b", BU_Map.SkillFootDepth)
        pt.cachedTransform.localPosition = star.localPosition
        AddAudioSource(pt.cachedGameObject):PlayOneShot(clip, BGM.soeVolume)

        s:Destruct(5)
    end,
--#endregion

--region ----------- 5 回馈 -----------
    [5] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        HitWordEffect.Begin(s.hero_v.go, "+" + s.dat.dat:GetVal(1), Color(0.24, 0.24, 1), Color(0.32, 1, 1));
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skd_5", BU_Map.SkillHeadDepth).cachedTransform.localPosition = Vector3(2, 46, 0);
        s:Destruct(3);
    end,
--#endregion

--region ----------- 6 决死意志 -----------
    [6] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.hero_v.go.transform:FindChild("skd_6_b")
        if not isnull(kp) then Destroy(kp.gameObject) end
        kp = s.dat.buff.leftSecond
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skd_6_b", BU_Map.SkillHeadDepth, kp)
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 7 飞刀暗袭 -----------
    [7] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local tmp = BuildSpriteAnim(s, s.map.go, "", 1, 20, false, 0, false)
        tmp.width, tmp.height = 104, 262
        tmp.cachedGameObject:SetActive(false)
        coroutine.step()
        coroutine.step()
        tmp.cachedTransform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y) + Vector2(1, 114)
        tmp.depth = s.hero_v.rival.depth + BU_Map.SkillDepthSpace
        tmp.cachedGameObject:SetActive(true)

        while s.dat.isAlive do coroutine.step() end
        tmp = s.dat:GetHitTarget()
        if tmp ~= nil and #tmp > 0 then
            local tg = nil
            for i = 1, #tmp do
                tg = tmp[i].body
                if tg ~= nil then
                    BuildWidget(s, typeof(UIParticle), tg.go, s.ef, "skd_7_b", tg.depth + BU_Map.SkillDepthSpace)
                end
            end
        end 
        s:Destruct(5)
    end,
--endregion

--region ----------- 8 勇武战意 -----------
    [8] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.hero_v.go.transform:FindChild("skd_8")
        if not isnull(kp) then Destroy(kp.gameObject) end
        kp = s.dat.buff.leftSecond
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skd_8", BU_Map.SkillHeadDepth, kp)
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 9 磐石护甲 -----------
    [9] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.hero_v.go.transform:FindChild("skd_9")
        if not isnull(kp) then Destroy(kp.gameObject) end
        kp = s.dat.buff.leftSecond
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skd_9", BU_Map.SkillHeadDepth, kp)
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 10 冰爆轰击 -----------
    [10] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local tmp = BuildWidget(s, typeof(UIWidget), s.map.go, s.ef.transform:GetChild(0).gameObject, "skd_10_a", 1)
        tmp.cachedGameObject:SetActive(false)
        coroutine.step()
        coroutine.step()
        tmp.cachedTransform.localPosition = s.map:GetPosition(s.dat.pos.x, s.dat.pos.y)
        tmp.depth = s.hero_v.rival.depth + BU_Map.SkillDepthSpace
        tmp.cachedGameObject:SetActive(true)
        local kp = s.dat.buff.leftSecond
        tmp =s.ef.transform:GetChild(0).gameObject
        local tgs = s.dat:GetHitTarget()
        if tgs and #tgs > 0 then
            local tg = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    tg = BuildWidget(s, typeof(UIParticle), tg.go, tmp, "skd_10_b", tg.depth + BU_Map.SkillDepthSpace, kp)
                    tg.duration = kp
                    tg:GetCmpInChilds(typeof(UIParticle), false).duration = kp
                end
            end
        end
        s:Destruct(kp + 2)
    end,
--#endregion

--region ----------- 11 生命绽放 -----------
    [11] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.hero_v.go.transform:FindChild("skd_11")
        if not isnull(kp) then Destroy(kp.gameObject) end
        kp = s.dat.buff.leftSecond
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skd_11", BU_Map.SkillHeadDepth, kp)
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 12 回光返照 -----------
    [12] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        local tmp = s.hero_v.go.transform:FindChild("skd_12")
        if not isnull(tmp) then Destroy(tmp.gameObject) end
        tmp = BuildWidget(s, s.hero_v.go, s.ef, "skd_12", BU_Map.SkillHeadDepth, kp)
        tmp = tmp.cachedTransform:FindChild("god")
        if tmp then
            tmp = tmp:GetCmpsInChilds(typeof((UIParticle)))
            for i = 0, tmp.length - 1 do
                tmp[i].startLifetime.min = s.dat.dat:GetVal(1)
            end
        end
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 13 天雷连法 -----------
    [13] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local up = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skd_13", BU_Map.SkillFootDepth)
        up.cachedTransform.localPosition = s.hero_v.rival.go.transform.localPosition
        up.cachedGameObject:SetActive(true)
        AddAudioSource(up.cachedGameObject):PlayOneShot(AM.LoadAudioClip("sound_skc_20"))
        s:Destruct(3)
    end,
--#endregion

--region ----------- 14 侵蚀 -----------
    [14] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.hero_v.go.transform:FindChild("skd_14")
        if not isnull(kp) then Destroy(kp.gameObject) end
        kp = s.dat.buff.leftSecond
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skd_14", BU_Map.SkillHeadDepth, kp)
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 15 能量充沛 -----------
    [15] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        HitWordEffect.Begin(s.hero_v, "+"..s.dat.data.GetVal(1), Color(0.24, 0.24, 1), Color(0.32, 1, 1))
        BuildWidget(s, typeof(UIParticle), s.hero_v, s.ef, "skd_15", BU_Map.SkillHeadDepth).cachedTransform.localPosition = Vector3(2, 46, 0)
        s:Destruct(3)
    end,
--#endregion

--region ----------- 16 风驰电掣 -----------
    [16] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skd_16_b", BU_Map.SkillHeadDepth, kp)
        buf.cachedTransform.localPosition = Vector3(10000, 10000, 10000)

        local tgs = s.dat:GetHitTarget()
        if tgs ~= nil and #tgs > 0 then
            local tg = nil
            local go = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    go = tg.gameObject.transform:FindChild("skd_16_b")
                    if not isnull(go) then Destroy(go.gameObject) end
                    tg = BuildCopy(s, buf, tg.gameObject)
                    go = tg.gameObject
                    if not isnull(go) then Destroy(go, kp + 0.3) end
                    tg.go.transform.localPosition = Vector3.zero
                end
            end
        end
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 17 法术屏障 -----------
    [17] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skd_17_b", BU_Map.SkillHeadDepth, kp)
        buf.cachedTransform.localPosition = Vector3(10000, 10000, 10000)

        local tgs = s.dat:GetHitTarget()
        if tgs ~= nil and #tgs > 0 then
            local tg = nil
            local go = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    go = tg.gameObject.transform:FindChild("skd_17_b")
                    if not isnull(go) then Destroy(go.gameObject) end
                    tg = BuildCopy(s, buf, tg.gameObject)
                    go = tg.gameObject
                    if not isnull(go) then Destroy(go, kp + 0.3) end
                    tg.go.transform.localPosition = Vector3(0, 24, 0)
                end
            end
        end
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 18 箭雨伏击 -----------
    [18] = function (s)
        local tmp = nil
        if s.dat.step < 2 then
            tmp = Time.time + 0.3
            while s.dat.step < 2 and tmp > Time.time do coroutine.step() end
            if s.isOwn then
                s.map:ViewMoveX(s.hero_d.map:SearchUnitFocusX(not s.hero_d.isAtk))
                s.map.view.lockTime = s.dat.dat:GetVal(4)
            end
            AddAudioSource(s.go):PlayOneShot(AM.LoadAudioClip("sound_skc_11_a"), BGM.soeVolume)
            while s.dat.step < 2 do coroutine.step() end
        end
        local cnt = s.dat.unitQty
        if s.dat.isAlive and cnt > 0 then
            AddAudioSource(s.go):PlayOneShot(AM.LoadAudioClip("sound_skc_11_b"), BGM.soeVolume)
            tmp = { }
            local mina = s.hero_d.isAtk and 15 or -30
            local maxa = s.hero_d.isAtk and 30 or -15
            while s.dat.isAlive do
                for i = 1, cnt do
                    if s.dat.units[i].status == 1 and not tmp[i] and s.dat.units[i].time >= 0 then
                        tmp[i] = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skd_18_"..i, s.map:GetDepth(s.dat.units[i]))
                        tmp[i].cachedTransform.localPosition = s.map:GetPosition(s.dat.units[i].pos.x, s.dat.units[i].pos.y, 0)
                        tmp[i].cachedTransform.localEulerAngles = Vector3(0, 0, rd(mina, maxa))
                    end
                end
                coroutine.step()
            end
        else s:Destruct()
        end
        s:Destruct(1)
    end,
--#endregion

--region ----------- 19 决死意志 -----------
    [19] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.hero_v.go.transform:FindChild("skd_19_b")
        if not isnull(kp) then Destroy(kp.gameObject) end
        kp = s.dat.buff.leftSecond
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skd_19_b", BU_Map.SkillHeadDepth, kp)
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 20 腐蚀 -----------
    [20] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        s.hero_v.rival:AddBleedEffect(s.dat.buff.leftSecond)
        s:Destruct()
    end,
--#endregion

--region ----------- 21 绝命反击 -----------
    [21] = function (s)
        s:CancleDestruct()
        while s.dat.step < 2 do coroutine.step() end
        local tgs = nil
        local tg = nil
        local t = nil
        while s.dat.isAlive do
            tgs = s.dat:GetHitTarget()
            if tgs and #tgs > 0 then
                for i = 1, #tgs do
                    tg = tgs[i].body
                    if tg then
                        t = tg.go.transform:FindChild("skd_21_b")
                        if t then t:GetCmp(typeof(UIParticle)):Play()
                        else BuildWidget(s, typeof(UIParticle), tg.go, s.ef, "skd_21_b", tg.depth + BU_Map.SkillDepthSpace).cachedTransform.localPosition = Vector3(0, 40, 0)
                        end
                    end
                end
            end
            coroutine.step()
        end
        s:Destruct(1)
        for i = 1, #objs do
            if s.objs[i] then EF.Alpha(s.objs[i], 0.2, 0).ignoreTimeScale = false end
        end
    end,
--#endregion

--region ----------- 22 孤军奋战 -----------
    [22] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.hero_v.go.transform:FindChild("skd_22_b")
        if not isnull(kp) then Destroy(kp.gameObject) end
        kp = s.dat.buff.leftSecond
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skd_22_b", BU_Map.SkillHeadDepth, kp)
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 23 决斗 -----------
    [23] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.hero_v.go.transform:FindChild("skd_23_b")
        if not isnull(kp) then Destroy(kp.gameObject) end
        kp = s.hero_v.rival.go.transform:FindChild("skd_24_b")
        if not isnull(kp) then Destroy(kp.gameObject) end
        kp = s.dat.buff.leftSecond
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef.transform:GetChild(0).gameObject, "skd_23_b", BU_Map.SkillHeadDepth, kp)
        BuildWidget(s, typeof(UIParticle), s.hero_v.rival.go, s.ef.transform:GetChild(1).gameObject, "skd_24_b", BU_Map.SkillHeadDepth, kp)
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 24 风火轮 -----------
    [24] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        if s.dat.isAlive then
            local ado = AddAudioSource(s.go)
            ado.clip = AM.LoadAudioClip("sound_skc_14")
            ado.loop = true
            ado:Play()

            local cnt = 4
            local a = 50
            local b = 10
            local as = { }
            local sps = { }
            local dev = Vector3(0, 35, 0)
            local pos = nil
            for i = 1, cnt do
                as[i] = 2 * (i - 1) * _math.PI / cnt
                sps[i] = BuildWidget(s, typeof(UISprite), s.hero_v.go, s.ef, "skd_24", s.hero_v, depth)
                pos = Vector3(a * _math.cos(as[i]), b * _math.sin(as[i]), 0)
                sps[i].cachedTransform.localPosition = pos + dev
                sps[i].depth = s.hero_v.depth + (pos.y < 0 and 1 or -1) * BU_Map.SkillDepthSpace
            end
            local da = nil
            while s.dat.isAlive do
                da = Time.deltaTime * _math.PI
                for i = 1, cnt do
                    as[i] = as[i] + da
                    pos = Vector3(a * _math.cos(as[i]), b * _math.sin(as[i]), 0)
                    sps[i].cachedTransform.localPosition = pos + dev
                    sps[i].depth = s.hero_v.depth + (pos.y < 0 and 1 or -1) * BU_Map.SkillDepthSpace
                end
                coroutine.step()
            end
            ado:Stop()
            s:Destruct()
            for i = 1, cnt do EF.Alpha(sps[i], 0.2, 0).ignoreTimeScale = false end
        else s:Destruct()
        end
    end,
--#endregion

--region ----------- 25 反间之道 -----------
    [25] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        s:Destruct()
    end,
--#endregion

--region ----------- 26 乘胜追击 -----------
    [26] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skd_26_b", BU_Map.SkillHeadDepth, kp)
        buf.cachedTransform.localPosition = Vector3(10000, 10000, 10000)

        local tgs = s.dat:GetHitTarget()
        if tgs ~= nil and #tgs > 0 then
            local tg = nil
            local go = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    go = tg.gameObject.transform:FindChild("skd_26_b")
                    if not isnull(go) then Destroy(go.gameObject) end
                    tg = BuildCopy(s, buf, tg.gameObject)
                    go = tg.gameObject
                    if not isnull(go) then Destroy(go, kp + 0.3) end
                    tg.go.transform.localPosition = Vector3.zero
                end
            end
        end
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 27 战意激昂 -----------
    [27] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skd_27_b", BU_Map.SkillHeadDepth, kp)
        buf.cachedTransform.localPosition = Vector3(10000, 10000, 10000)

        local tgs = s.dat:GetHitTarget()
        if tgs ~= nil and #tgs > 0 then
            local tg = nil
            local go = nil
            local b = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    go = tg.gameObject.transform:FindChild("skd_27_b")
                    if not isnull(go) then Destroy(go.gameObject) end
                    b = BuildCopy(s, buf, tg.gameObject)
                    go = b.gameObject
                    if not isnull(go) then Destroy(go, kp + 0.3) end
                    b.go.transform.localPosition = ois(tg, BU_Soldier) and Vector3(5, 65, 0) or Vector3(0, 80, 0)
                end
            end
        end
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 28 迟缓 -----------
    [28] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        local buf = BuildWidget(s, typeof(UIParticle), s.map.go, s.ef, "skd_27_b", BU_Map.SkillHeadDepth, kp)
        buf.cachedTransform.localPosition = Vector3(10000, 10000, 10000)

        local tgs = s.dat:GetHitTarget()
        if tgs ~= nil and #tgs > 0 then
            local tg = nil
            local go = nil
            for i = 1, #tgs do
                tg = tgs[i].body
                if tg then
                    go = tg.gameObject.transform:FindChild("skd_27_b")
                    if not isnull(go) then Destroy(go.gameObject) end
                    tg = BuildCopy(s, buf, tg.gameObject)
                    go = tg.gameObject
                    if not isnull(go) then Destroy(go, kp + 0.3) end
                    tg.go.transform.localPosition = Vector3.zero
                end
            end
        end
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 29 越战越勇 -----------
    [29] = function (s)
        s:CancleDestruct()

        local tgs = nil
        local tg = nil
        local t = nil
        while s.dat.isAlive do
            tgs = s.dat:GetHitTarget()
            if tgs and #tgs > 0 then
                for i = 1, #tgs do
                    tg = tgs[i].body
                    if tg then
                        t = tg.go.transform:FindChild("skd_29_b")
                        if t then t:GetCmp(typeof(UIParticle)):Play()
                        else BuildWidget(s, typeof(UIParticle), tg.go, s.ef, "skd_29_b", tg.depth + BU_Map.SkillDepthSpace)
                        end
                    end
                end
            end
            coroutine.step()
        end
        s:Destruct(1)
        tgs = s.objs
        for i = 1, #tgs do
            if tgs[i] then EF.Alpha(tgs[i], 0.2, 0).ignoreTimeScale = false end
        end
    end,
--#endregion

--region ----------- 30 能量倾泻 -----------
    [30] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        HitWordEffect.Begin(s.hero_v, "+"..s.dat.data.GetVal(1), Color(0.24, 0.24, 1), Color(0.32, 1, 1))
        BuildWidget(s, typeof(UIParticle), s.hero_v.go, s.ef, "skd_30", BU_Map.SkillHeadDepth).cachedTransform.localPosition = Vector3(2, 46, 0)
        s:Destruct(3)
    end,
--#endregion

--region ----------- 31 铁布衫 -----------
    [31] = function (s)
        s:Destruct(1)
    end,
--#endregion

--region ----------- 32 魅惑 -----------
    [32] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        BuildWidget(s, typeof(UIParticle), s.hero_v.rival.go, s.ef, "skd_32", BU_Map.SkillHeadDepth).cachedTransform.localPosition = Vector3(2, 46, 0)
        s:Destruct(3)
    end,
--#endregion

--region ----------- 34 妙手回春 -----------
    [34] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        BuildWidget(s, typeof(UIWidget), s.hero_v.go, s.ef, "skd_34", BU_Map.SkillHeadDepth)
        s:Destruct(3)
    end,
--#endregion

--region ----------- 35 固若金汤 -----------
    [35] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        uildWidget(typeof(UIWidget), s.hero_v.go, s.ef, "skd_35", BU_Map.SkillHeadDepth, kp)
        s:Destruct(kp + 1)
    end,
--#endregion

--region ----------- 36 严防死守 -----------
    [36] = function (s)
        while s.dat.step < 2 do coroutine.step() end
        local kp = s.dat.buff.leftSecond
        uildWidget(typeof(UIWidget), s.hero_v.go, s.ef, "skd_36", BU_Map.SkillHeadDepth, kp).cachedTransform.localPosition = Vector3(0, 46, 0)
        s:Destruct(kp + 1)
    end,
--#endregion
}

function _skd.ctor(s, map, go)
    _base.ctor(s, map, go)
    s.enabled = false
    if map == nil or go == nil then s:Destruct() return end
end

--初始化数据
-- param[dat] : BD_SKD
function _skd.Init(s, dat)
    assert(dat and getmetatable(dat) == QYBattle.BD_SKD, "Init dat must be BD_SKD")
    s.dat = dat
    if dat.isAlive then
        local map = s.map
        local sn = dat.sn
        s.ef = map:GetSkdEffect(sn)
        s.atlas = map:GetSkdAtlas(sn)
        if s.ef or s.atlas or sn == 2 or sn == 20 or sn == 25 then
            local func = ShowFunc[sn]
            if func then
                s.enabled = true
                dat.body = s
                s.hero_d = s.dat.hero
                s.hero_v = s.hero_d.isAtk and map.atkHero or map.defHero
                s.isOwn = s.hero_d.isAtk == map.own
                if dat.step < 2 and map.onTriggerSkd ~= nil then
                    map.onTriggerSkd(s.dat.dehero, sn)
                    
                end
                s.objs = { }
                s.cor = coroutine.create(func)
                coroutine.resume(s.cor, s)
                s:Destruct(s.dat.maxLifeTime * 0.001)
                return
            end
        end
    end
    s:Destruct()
end

function _skd.Dispose(s)
    _base:Dispose()
    if s and s.objs and #s.objs > 0 then
        for i = 1, #s.objs do if s.objs[i] then Destroy(s.objs[i]) end end
        s.objs = nil
    end
    if s.cor ~= nil and coroutine.status(s.cor) ~= "dead" then coroutine.stop(s.cor) end
end