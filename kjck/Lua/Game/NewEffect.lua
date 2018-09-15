
local cr = ColorStyle.Rare
local ts = ToolTip.ShowPopTip
local rdNum = Mathf.Random
local isnull = tolua.isnull

NewEffect = { }
-- 展示效果类型
local efType = {
    None = 0,
    NewHero = 1,
    NewEquip = 2,
    NewProps = 3,
    NewHeroSoul = 4,
    NewEvoEquip = 5,
    NewDehero = 6,
    NewDequip = 7,
    NewArtifact = 8,
}
-- 展示效果数据
--local efData = {}

local _body = nil

--local function NewData()
--    local ins = {
--        d = nil,
--        et = efType.None,
--        v = 0,
--        goBag = false,
--        tip = false,
--        }
--    setmetatable(ins, {__index = efData})
--    return ins
--end

local function GetIsAva(dat) return dat.et > 0 and isTable(dat.d) and CheckSN(dat.d.sn) end

--function efData:GetIsAva()
--    if self.et > 0 and self.et < #efType and isTable(self.d) and #self.d > 0 then
--        if isString(self.d.sn) then return  CheckSN(self.d.sn)
--        elseif isNumber(self.d.sn) then return self.d.sn > 0 
--        else return false end
--    end
--    return false
--end

-- 当前显示
local _curShow = nil
-- 显示队列
local queue = { }
-- 固定显示时间
local FixST = 1
-- 固定等待时间
local FixWT = 1.5

-- 是否在等待
local wait = false
-- 光环
local haloCnt = 0
-- 时间增量
local deltTime = 0
-- 效果数据s
local _data
-- 展示结束回调
local _onFinished = nil

local _tipCheck = nil
local _halo = nil


local function EnQueue(dat)
    if GetIsAva(dat) then queue[#queue + 1] = dat end
end

local function DeQueue()
    local dat = nil
    for i = 1, #queue do
        if queue[i] ~= nil then
            dat = queue[i]
            table.remove(queue, i)
            break
        end
    end
    return dat
end

local function OnHaloDis() haloCnt = haloCnt - 1 end

local function BuildHalo()
    if not isnull(_curShow) then
        local tex = _curShow:AddWidget(typeof(UITexture), "halo")
        tex.mainTexture = _halo
        tex.shader = UE.Shader.Find("Particles/Additive")
        tex.depth = 1
        tex:MakePixelPerfect()
        tex.cachedTransform.localPosition = Vector3(rdNum(-480, 480), rdNum(-270, 270), 0)
        tex.alpha = 0
        local s = rdNum(0.2, 0.7)
        tex.cachedTransform.localScale = Vector3(s, s, s)
        local d = rdNum(0.5, 2)
        local tos = rdNum(s, 1.5)
        EF.Scale(tex, d, Vector3(tos, tos, tos), 0.2)
        local ta = EF.Alpha(tex, d, 0, 0.2)
        ta.from = 1
        Invoke(OnHaloDis,0.25)
--        ta:SetOnFinished(OnHaloDis)
        EF.ColorTo(tex.cachedGameObject, "a", 1, "time", 0.2)
        Destroy(tex.cachedGameObject, d + 0.3)
        haloCnt = haloCnt + 1
        return tex
    end
end

local _update = UpdateBeat:CreateListener(function ()
    if _halo and haloCnt < 20 then
        if deltTime > 0 then deltTime = deltTime - Time.deltaTime
        else
            deltTime = haloCnt < 10 and 0 or rdNum(0, 0.1)
            BuildHalo()
        end
    end
end)

local function CheckTipRare(t, r)
    if isnull(_tipCheck) or not t or not r then return end
    if _tipCheck.value then
        if r > t then t = r end
    elseif t >= r then t = r - 1
    end
    if _data.et == efType.NewEquip then CONFIG.tipEquipRare = t
    elseif _data.et == efType.NewProps then CONFIG.tipPropsRare = t
    elseif _data.et == efType.NewDequip then CONFIG.tipDeEquipRare = t
    elseif _data.et == efType.NewHeroSoul then CONFIG.tipSoulRare = t
    elseif _data.et == efType.NewHero then CONFIG.tipHeroRare = t
    elseif _data.et == efType.NewDehero then CONFIG.tipDeHeroRare = t
    elseif _data.et == efType.NewArtifact then CONFIG.tipArtifactRare = t
    end
end

local function OnDispose()
    if _update ~= nil then UpdateBeat:RemoveListener(_update) end
    if _data.et == efType.NewEquip then CheckTipRare(CONFIG.tipEquipRare, _data.d.rare)
    elseif _data.et == efType.NewProps then CheckTipRare(CONFIG.tipPropsRare, _data.d.rare)
    elseif _data.et == efType.NewDequip then CheckTipRare(CONFIG.tipDeEquipRare, _data.d.rare)
    elseif _data.et == efType.NewHeroSoul then CheckTipRare(CONFIG.tipSoulRare, _data.d.rare)
    elseif _data.et == efType.NewHero then CheckTipRare(CONFIG.tipHeroRare, _data.d.rare)
    elseif _data.et == efType.NewDehero then CheckTipRare(CONFIG.tipDeHeroRare, _data.d.rare)
    elseif _data.et == efType.NewEvoEquip then if _tipCheck then CONFIG.tipEquipPlus = not _tipCheck.value end
    elseif _data.et == efType.NewArtifact then CheckTipRare(CONFIG.tipArtifactRare, _data.d.rare)
    end
    AM.UnloadUnusedAsset()
    if not isnull(_curShow) then
        Destroy(_curShow)
        _curShow = nil
        if _onFinished then
            for i = 1, #_onFinished do _onFinished[i]() end
        end
    end
    _tipCheck = nil
    NewEffect.CheakQueue()
end

local function OnClick() wait = false end

local function StartShow()
    if not GetIsAva(_data) then
        OnDispose()
        return
    end
    if not isnull(_curShow) then
        -- 设置随机种子
        math.randomseed(string.reverse(os.time()))
        if _update ~= nil then UpdateBeat:AddListener(_update) end
        _curShow:GetCmp(typeof(LuaButton)):SetClick(OnClick)
        local _icon = _curShow:ChildWidget("icon")
        local _labName = _curShow:ChildWidget("name")
        local _labIntro = _curShow:ChildWidget("intro")
        local _sparks = _curShow:ChildWidget("spark")
        local _glow = _curShow:ChildWidget("glow")
        local _lightBeam = _glow:ChildWidget("Light")
        _tipCheck = _curShow.transform:FindChild("anchor_ButtomRight/check_tip"):GetCmp(typeof(UIToggle))
        print("_tipCheck    ", kjson.print(_tipCheck))
        if _data.et ~= efType.NewProps and _data.et ~= efType.NewHeroSoul then _halo = AM.LoadTexture("tex_new_obtain")
        else _halo = nil end
        local CorMethod = function ()
            local d = _data.d
            local clr = nil
            local loader = nil
            -- 展示新武将
            if _data.et == efType.NewHero then
                _icon = _curShow.transform:FindChild("ef_1/ef_ui_zhaowujiang/kapairen/hero_utx"):GetCmp(typeof(UITexture))
                _labName = _icon:ChildWidget("name")
                _labName.text = d.nm
                clr = ColorStyle.GetRareColor(d.rare)
                _labName.color = clr
                _lightBeam.color = clr
                _glow.color = clr + Color(0.12, 0.12, 0.12, 0)
                _icon:ChildWidget("stars").TotalCount = d.rare
                _icon:ChildWidget("clan").spriteName = "hero_clan_"..d.clan
                _icon:ChildWidget("kind").spriteName = "hero_kind_"..d.kind
                loader = _icon:LoadTexAsync(ResName.HeroImage(d.img))
                while not loader.isDone do coroutine.step() end
                _labIntro.text = user.gmMaxCity < CONFIG.T_LEVEL and L("武将来源：[F10325]关卡[-]招降、[F10325]酒馆[-]招募") or ""
                if _tipCheck then 
                    _tipCheck.value = CONFIG.tipHeroRare > d.rare
                    _tipCheck.gameObject:SetActive(user.gmMaxCity >= CONFIG.T_LEVEL)
                end
            -- 展示新装备
            elseif _data.et == efType.NewEquip then
                _labName.text = d.nm
                clr = ColorStyle.GetRareColor(d.rare)
                _labName.color = clr
                _lightBeam.color = clr
                _glow.color = clr + Color(0.12, 0.12, 0.12, 0)
                loader = _icon:LoadTexAsync(ResName.EquipIcon(d.img))
                while not loader.isDone do coroutine.step() end
                _icon:ChildWidget("frame").spriteName = "frame_"..d.rare
                ItemGoods.SetEquipEvo(_icon.cachedGameObject, _data.v, d.rare)
                _labIntro.text = user.gmMaxCity < CONFIG.T_LEVEL and L("装备来源：[F10325]关卡、副本、搜索宝箱[-]") or ""
                if _tipCheck then
                    _tipCheck.value = CONFIG.tipEquipRare > d.rare
                    _tipCheck.gameObject:SetActive(user.gmMaxCity >= CONFIG.T_LEVEL)
                end
            -- 展示新道具
            elseif _data.et == efType.NewProps then
                _labName = _icon:ChildWidget("name")
                _labName.text = d.nm
                clr = _labName.gradientBottom
                _lightBeam.color = clr
                _glow.color = clr + Color(0.12, 0.12, 0.12, 0)
                loader = _icon:LoadTexAsync(ResName.PropsIcon(d.img))
                while not loader.isDone do coroutine.step() end
                _icon:ChildWidget("num").text = "x".._data.v
                if user.gmMaxCity < CONFIG.T_LEVEL then
                    if d.sn == DB.props.DA_JING_YAN_DAN then _labIntro.text = L(string.format("[F10325]%s[-]快速提升实力\n来源：[F10325]关卡、副本、活动[-]", d.name))
                    elseif d.sn == DB.props.SHU_XING_YAO_JI then _labIntro.text = L(string.format("[F10325]%s[-]随机提升单项值\n来源：[F10325]关卡、副本、活动[-]", d.name))
                    else _labIntro.text = d.intro end
                else _labIntro.text = d.intro end
                if _tipCheck then
                    _tipCheck.value = CONFIG.tipPropsRare > d.rare
                    _tipCheck.gameObject:SetActive(user.gmMaxCity >= CONFIG.T_LEVEL)
                end
            -- 展示新将魂
            elseif _data.et == efType.NewHeroSoul then
                _curShow:ChildWidget("title").text = L("获得将魂")
                _labName = _icon:ChildWidget("name")
                _labName.text = d.nm.."("..L("将魂")..")"
                _labName.applyGradient = false
                clr = ColorStyle.GetRareColor(d.rare)
                _labName.color = clr
                _lightBeam.color = clr
                _glow.color = clr + Color(0.12, 0.12, 0.12, 0)
                loader = _icon:LoadTexAsync(ResName.HeroIcon(d.img))
                while not loader.isDone do coroutine.step() end
                _icon:ChildWidget("frame").spriteName = "frame_hero_soul"
                _icon.width = 112
                _icon.height = 112
                _labIntro.text = ""
                if _tipCheck then
                    _tipCheck.value = CONFIG.tipSoulRare > d.rare
                    _tipCheck.gameObject:SetActive(user.gmMaxCity >= CONFIG.T_LEVEL)
                end
            -- 展示新装备
            elseif _data.et == efType.NewEvoEquip then
                _curShow:ChildWidget("title").text = L("进阶成功")
                _labName.text = d.nm
                clr =ColorStyle.GetRareColor(d.rare)
                _labName.color = clr
                _lightBeam.color = clr
                _glow.color = clr + Color(0.12, 0.12, 0.12, 0)
                _icon:ChildWidget("frame").spriteName = "frame_"..d.rare
                loader = _icon:LoadTexAsync(ResName.EquipIcon(d.img))
                while not loader.isDone do coroutine.step() end
                _labIntro.cachedTransform.localPosition = Vector3(0, -140, 0)
                _labIntro.applyGradient = true
                _labIntro.supportEncoding = false
                _labIntro.gradientBottom = Color(0.98, 0.712, 0, 1)
                _labIntro.gradientTop = Color(1, 0.94, 0.63, 1)
                local toStr = ""
                if d.db.estr > 0 then
                    toStr = tostring(d.baseStr)
                    _labIntro.text = L(string.format("武力:%s    %s", d.baseStr - d.db.estr * (d.evo + 1), toStr))
                elseif d.db.ehp > 0 then
                    toStr = tostring(d.baseHP)
                    _labIntro.text = L(string.format("生命:%s    %s", d.baseHP - d.db.ehp * (d.evo + 1), toStr))
                elseif d.db.ewis > 0 then
                    toStr = tostring(d.baseWis)
                    _labIntro.text = L(string.format("智力:%s    %s", d.baseWis - d.db.ewis * (d.evo + 1), toStr))
                elseif d.db.ecap > 0 then
                    toStr = tostring(d.baseCap)
                    _labIntro.text = L(string.format("统帅:%s    %s", d.baseCap - d.db.ecap * (d.evo + 1), toStr))
                end
                if string.notEmpty(toStr) then
                    local arr = _curShow:AddWidget(typeof(UISprite), "arrow")
                    arr.atlas = AM.mainAtlas
                    arr.spriteName = "sp_arrow"
                    arr.width = 34
                    arr.height = 32
                    arr.depth = 5
                    arr.cachedTransform.localPosition = Vector3(_labIntro.printedSize.x * 0.5 - (string.len(toStr) + 1) * _labIntro.fontSize * 0.5, -140, 0)
                    arr.cachedTransform.localRotation = Quaternion.Euler(0, 0, 180)
                end
                ItemGoods.SetEquipEvo(_icon.cachedGameObject, d.evo, d.rare)
                ItemGoods.SetEquipGems(_icon.cachedGameObject, d.Gems)
                ItemGoods.SetEquipExclStar(_icon.cachedGameObject, d.exclStar)
                if _tipCheck then
                    _tipCheck.value = CONFIG.tipDeHeroRare > d.rare
                    _tipCheck.gameObject:SetActive(user.gmMaxCity >= CONFIG.T_LEVEL)
                end
                if _tipCheck then
                    _tipCheck.value = not CONFIG.tipEquipPlus
                    _tipCheck.gameObject:SetActive(true)
                end
            -- 展示新副将
            elseif _data.et == efType.NewDehero then
                _labName.text = d.nm
                clr = ColorStyle.GetRareColor(d.rare)
                _labName.gradientBottom = clr
                _lightBeam.color = clr
                _glow.color = clr + Color(0.12, 0.12, 0.12, 0)
                loader = _icon:LoadTexAsync(ResName.DeHeroIcon(d.img))
                while not loader.isDone do coroutine.step() end
                _icon:ChildWidget("frame").spriteName = "frame"..d.rare
                ItemGoods.SetEquipEvo(_icon.cachedGameObject, _data.v, d.rare)
                _labIntro.text = ""
                if _tipCheck then
                    _tipCheck.value = CONFIG.tipDeHeroRare > d.rare
                    _tipCheck.gameObject:SetActive(user.gmMaxCity >= CONFIG.T_LEVEL)
                end
            -- 展示新军备
            elseif _data.et == efType.NewDequip then
                _curShow:ChildWidget("title").text = L("获得军备")
                _labName.text = d.nm
                clr = ColorStyle.GetRareColor(d.rare)
                _labName.gradientBottom = clr
                _lightBeam.color = clr
                _glow.color = Color(clr.r + 0.12, clr.g + 0.12, clr.b + 0.12, clr.a + 0)
                loader = _icon:LoadTexAsync(ResName.DequipIcon(d.db.img, d.rare))
                while not loader.isDone do coroutine.step() end
                _icon:ChildWidget("frame").spriteName = "frame_"..d.rare
                ItemGoods.SetEquipEvo(_icon.cachedGameObject, _data.v, d.rare)
                _labIntro.text = ""
                if _tipCheck then
                    _tipCheck.value = CONFIG.tipDeEquipRare > d.rare
                    _tipCheck.gameObject:SetActive(user.gmMaxCity >= CONFIG.T_LEVEL)
                end
            -- 展示新神器
            elseif _data.et == efType.NewArtifact then
                _labName.text = d.nm
                clr = ColorStyle.GetRareColor(d.rare)
                _labName.color = clr
                _lightBeam.color = clr
                _glow.color = clr + Color(0.12, 0.12, 0.12, 0)
                loader = _icon:LoadTexAsync(ResName.EquipIcon(d.img))
                while not loader.isDone do coroutine.step() end
                _icon:ChildWidget("frame").spriteName = "frame_"..d.rare
                ItemGoods.SetEquipEvo(_icon.cachedGameObject, _data.v, d.rare)
                _labIntro.text = ""
                if _tipCheck then
                    _tipCheck.value = CONFIG.tipArtifactRare > d.rare
                    _tipCheck.gameObject:SetActive(user.gmMaxCity >= CONFIG.T_LEVEL)
                end
            end
            coroutine.step()
            coroutine.step()
            _sparks:Play()
            _curShow:GetCmp(typeof(TweenAlpha)):Play(true)
            _icon:GetCmp(typeof(TweenScale)):Play(true)
            local t = Time.realtimeSinceStartup + FixST
            while t > Time.realtimeSinceStartup do coroutine.step() end
            t = Time.realtimeSinceStartup + FixWT
            wait = true
            while wait and t > Time.realtimeSinceStartup do coroutine.step() end
            EF.Alpha(_curShow, 0.3, 0)
            if _data.goBag and MainUI and MainUI.body and MainUI.body:GetCmp(typeof(UIRect)).alpha > 0 then
                EF.MoveTo(_icon.cachedGameObject, "position", MainUI.body.transform.position, "time", 0.5)
                EF.ScaleTo(_icon.cachedGameObject, "scale", Vector3(0.3, 0.3, 0.3), "time", 0.5)
                EF.Alpha(_icon.gameObject, 0.3, 0, 0.2)
                t = Time.realtimeSinceStartup + 0.52
            else t = Time.realtimeSinceStartup + 0.32 end
            while t > Time.realtimeSinceStartup do coroutine.step() end
            OnDispose()
        end
        coroutine.start(CorMethod)
    end
end

local function AddEffect(d)
    if not GetIsAva(d) then return end
    if not isnull(_curShow) then EnQueue(d)
    else
        local pn = ""
        local dat = d.d
        if d.et == efType.NewEvoEquip then
            if not CONFIG.tipEquipPlus then
                ts(L("获得装备 ")..cr(dat:getName(), dat.rare))
                return
            end
            pn = "NewEquipEffect"
        elseif d.et == efType.NewEquip then
            if dat.rare <= CONFIG.tipEquipRare then
                ts(L("获得装备 ")..cr(dat:getName(), dat.rare))
                return
            end
            pn = "NewEquipEffect"
        elseif d.et == efType.NewHero then
            if dat.rare <= CONFIG.tipHeroRare then
                ts(L("获得武将 ")..cr(dat.nm, dat.rare))
                return
            end
            pn = "NewHeroEffect"
        elseif d.et == efType.NewProps then
            if dat.rare <= CONFIG.tipPropsRare then
                ts(L("获得道具 ")..cr(dat.nm).."×"..d.v)
                return
            end
            pn = "NewPropsEffect"
        elseif d.et == efType.NewHeroSoul then
            if dat.rare <= CONFIG.tipSoulRare then
                ts(L("获得将魂 ")..cr(dat.nm..L("(将魂)"), dat.rare))
                return
            end
            pn = "NewPropsEffect"
        elseif d.et == efType.NewDehero then
            if dat.rare <= CONFIG.tipDeHeroRare then
                ts(L("获得副将 ")..cr(dat.nm, dat.rare))
                return
            end
            pn = "NewDeheroEffect"
        elseif d.et == efType.NewDequip then
            if dat.rare <= CONFIG.tipDeEquipRare then
                ts(L("获得军备 ")..cr(dat.nm, dat.rare))
                return
            end
            pn = "NewEquipEffect"
        elseif d.et == efType.NewArtifact then
            if dat.rare <= CONFIG.tipArtifactRare then
                ts(L("获得神器 ")..cr(dat.nm, dat.rare))
            end
            pn = "NewEquipEffect"
        else 
            NewEffect.CheakQueue()
            return
        end
        _curShow = Scene.current.gameObject:AddChild(AM.LoadPrefab(pn), pn)
        _curShow:SetActive(true)
        BGM.PlaySOE("sound_get_rare_stuff")
        if _curShow.activeInHierarchy then 
            _data = d
            StartShow()
        else Destroy(_curShow) _curShow = nil end
    end
end

function NewEffect.CheakQueue()
    if not isnull(_curShow) or #queue <= 0 then return end
    local dat = DeQueue()
    if dat ~= nil then AddEffect(dat) end
end

--[Comment]
-- 获取当前显示效果引用{arg[], return[GameObject]}
function NewEffect.GetCurEffect() return _curShow end

function NewEffect.AddOnFinished(f)
    if _onFinished == nil then _onFinished = { } end
    if f ~= nil then table.insert(_onFinished, f) end
end

function NewEffect.RemoveOnFinished(f)
    if f == nil or _onFinished == nil then return end
    for i = 1, #_onFinished do
        if _onFinished[i] == f then
            table.remove(_onFinished, i)
            break
        end
    end
end
--[Comment]
-- 显示新获得的武将{arg[DB_Hero], return[]}
function NewEffect.ShowNewHero(hero, st)
    if not hero or not CheckSN(hero.sn) then return end
    if hero.rare > CONFIG.tipHeroRare then
        local d = { }
        d.et = efType.NewHero
        d.d = hero
        d.v = 0
        d.goBag = false
        AddEffect(d)
    else ts(L("获得武将 ")..cr(hero.nm, hero.rare)) end
end
--[Comment]
-- 显示新获得的副将{arg[DB_DeHero, boolean = true, boolean = true], return[]}
function NewEffect.ShowNewDeHero(dh, gb, st)
    if not dh or not CheckSN(dh.sn) then return end
    st = st ~= false
    if dh.rare > CONFIG.tipDeHeroRare then
        local d = { }
        d.et = efType.NewDehero
        d.d = dh
        d.goBag = gb ~= false
        AddEffect(d)
    elseif st then ts(L("获得副将 ")..cr(dh.nm, dh.rare)) end
end
--[Comment]
-- 显示新获得的装备{arg[DB_Equip, number = 0, boolean goBag = true, boolean showTip = true], return[]}
function NewEffect.ShowNewEquip(e, evo, gb, st)
    if not e or not CheckSN(e.sn) then return end
    st = st ~= false
    if e.rare > CONFIG.tipEquipRare then
        local d = { }
        d.et = efType.NewEquip
        d.d = e
        d.v = evo
        d.goBag = gb ~= false
        AddEffect(d)
    elseif st then ts(L("获得装备 ")..cr(e:getName(), e.rare)) end
end
--[Comment]
-- 显示新获得的道具{arg[DB_Props, number, boolean = true, boolean = true], return[]}
function NewEffect.ShowNewProps(p, c, gb, st)
    if c == nil then return end
    if not p or not CheckSN(p.sn) or c <= 0 then return end
    st = st ~= false
    if p.rare > CONFIG.tipPropsRare then
        local d = { }
        d.et = efType.NewProps
        d.d = p
        d.v = c
        d.goBag = gb ~= false
        AddEffect(d)
    elseif st then ts(L("获得道具 ")..cr(p.nm, p.rare).."×"..c) end
end
--[Comment]
-- 显示新获得的军备{arg[PY_Dequip, boolean = true, boolean = true], return[]}
function NewEffect.ShowNewDequip(e, gb, st)
    if not e or not CheckSN(e.sn) then return end
    st = st ~= false
    if e.rare > CONFIG.tipDeEquipRare then
        local d = { }
        d.et = efType.NewDequip
        d.d = e
        d.goBag = gb ~= false
        AddEffect(d)
    elseif st then ts(L("获得军备 ")..cr(e.nm, e.rare)) end
end
--[Comment]
-- 显示新获得的将魂{arg[DB_Hero, boolean = true, boolean = true], return[]}
function NewEffect.ShowNewHeroSoul(hero, gb, st)
    if not hero or not CheckSN(hero.sn) then return end
    st = st ~= false
    if hero.rare > CONFIG.tipSoulRare then
        local d = { }
        d.et = efType.NewHeroSoul
        d.d = hero
        d.v = 0
        d.goBag = gb ~= false
        AddEffect(d)
    elseif st then ts(L("获得将魂 ")..cr(hero.nm..L("(将魂)"), hero.rare)) end
end
--[Comment]
-- 显示获得的道具{arg[DB_Props, number, boolean = true], return[]}
function NewEffect.ShowProps(p, c, gb)
    if not p or not CheckSN(p.sn) or c <= 0 then return end
    local d = { }
    d.et = efType.NewProps
    d.d = p
    d.v = c
    d.goBag = gb ~= false
    AddEffect(d) 
end
--[Comment]
-- 显示新获得的装备{arg[PY_Equip], return[]}
function NewEffect.ShowNewEvoEquip(e)
    if not e or not CheckSN(e.sn) then return end
    if CONFIG.tipEquipPlus then
        local d = { }
        d.et = efType.NewEvoEquip
        d.d = e
        d.v = 0
        d.goBag = false
        AddEffect(d)
    else ts(L("获得装备 ")..cr(e:getName(), e.rare)) end
end
--[Comment]
-- 显示新获得的神器{arg[PY_Artifact, boolean = true, boolean = true], return[]}
function NewEffect.ShowNewArtifact(af, gb, st)
    if not af or not CheckSN(af.sn) then return end
    st = st ~= false
    if af.rare <= CONFIG.tipArtifactRare then
        local d = { }
        d.et = efType.NewArtifact
        d.d = af
        d.goBag = gb ~= false
        AddEffect(d)
    elseif st then ts(L("获得神器 ")..cr(af.nm, af.rare)) end
end
