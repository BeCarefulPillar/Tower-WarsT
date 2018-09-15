require "Battle/Data/QYBattle"
require "Game/FillScreen"
require "Game/PopBattleSelect"
local ipairs = ipairs
local Camera = UnityEngine.Camera
local EnInt = QYBattle.EnInt

local _w = { }
WinBattle = _w

local _body = nil
local _ref = nil

local _battle = nil
local _defName = nil
local _lineSet = nil
local _soldierSet = nil
local _go = nil
local _time = nil
local _tipTime = nil
local _delta = nil
--[Comment]
--1=胜利，-1=失败
local _result = nil
local _chooseAtkIndex = nil
local _chooseDefIndex = nil
local _ownHeros = nil
local _ownNoHeros = nil
local _enemyHeros = nil
local _enemyNoHeros = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref

    _defName = ""
    _lineSet = false
    _soldierSet = false
    _time = EnInt(60)
    _tipTime = 0
    _delta = 0
    _result = 0
    _chooseAtkIndex = 0
    _chooseDefIndex = 0
    _timeLab = _ref.timeLab
end

local _update = nil
local function Update()
    if _timeLab.enabled then
        if _time.value>0 then
            _delta = _delta + Time.deltaTime
            if _delta>=1 then
                local d = math.toint(_delta)
                _time = EnInt(_time.value - d)
                _delta = _delta - d
                _timeLab.text = string.format("%02d",_time.value)
            end
        else
            _timeLab.text = "00"
            _w.ClickFight()
        end
    end
end

local function BuildHero(hd, i, panel)
    local utx = panel:AddChild(_ref.item_hero_f, string.format("hero_%02d", i)):GetCmp(typeof(UITexture))
    local db = DB.GetHero(hd.dbsn.value)
    utx:LoadTexAsync(ResName.HeroIcon(db.img))
    utx:ChildWidget("name").text = db.nm
    utx:Child("stars", typeof(UIRepeat)).TotalCount = db.rare
    utx:AddCmp(typeof(UIDragScrollView)).scrollView = panel
    return utx
end

local function GetLock(index, noHero, panel, isOwn)
    local mask = noHero:ChildWidget("mask")
    local sp_lock = mask:ChildWidget("lock")
    local h_name = noHero:ChildWidget("name")
    mask:SetActive(true)
    noHero:Child("stars"):SetActive(false)
    h_name:SetActive(true)
    noHero:AddCmp(typeof(UIDragScrollView)).scrollView = panel
    if isOwn then
        local count = 0
        local lv = user.hlv + 1
        for i = lv, DB.maxHlv do
            count = DB.GetHome(lv).lead
            if index - 1 < count then
                break
            end
        end
        h_name.color = Color.red
        if count > DB.GetHome(user.hlv).lead then
            sp_lock.spriteName = "sp_lock_2"
            h_name.text = string.format(L("%d级解锁"), lv)
        else
            sp_lock.spriteName = "sp_no_hero"
            h_name.text = L("未上阵")
        end
    else
        h_name.color = Color.red
        h_name.text = L("未上阵")
        sp_lock.spriteName = "sp_no_hero"
    end
end

local function BuildHeros()
    _ref.ownHeroPanel.enabled = true
    _ref.enemyHeroPanel.enabled = true
    local len = _battle.atkQty
    _ownHeros = { }
    _ref.ownArrow:SetActive(len > 4)
    for i = 1, len do
        _ownHeros[i] = BuildHero(_battle:GetAtkHero(i), i, _ref.ownHeroPanel)
        _ownHeros[i].luaBtn:SetClick(_w.ClickHero, i)
    end
    if len < 4 then
        _ownNoHeros = { }
        for i = len, 3 do
            local v = _ref.ownHeroPanel:AddChild(_ref.item_hero_f, string.format("hero_%02d", len + 80))
            _ownNoHeros[i] = v.widget
            GetLock(len, v, _ref.ownHeroPanel, true)
        end
    end

    _ref.ownHeroPanel:ConstraintPivot(UIWidget.Pivot.Left, true)
    _ref.ownHeroPanel:GetCmp(typeof(UIGrid)).repositionNow = true
    if len <= 4 then
        _ref.ownHeroPanel.enabled = false
    end

    len = _battle.defQty
    _enemyHeros = { }
    _ref.enemyArrow:SetActive(len > 4)
    for i = 1, len do
        _enemyHeros[i] = BuildHero(_battle:GetDefHero(i), i, _ref.enemyHeroPanel)
        if _battle.type.value == 6 then
            local t = _enemyHeros[i]:GetComponentInChildren(typeof(UILabel))
            t.text = t.text .. L("·魂")
            if isDebug then
                _enemyHeros[i].luaBtn:SetClick(_w.ClickEnemyHero, i)
            end
        end
    end
    if len < 4 then
        _enemyNoHeros = { }
        for i = len, 3 do
            local v = _ref.enemyHeroPanel:AddChild(_ref.item_hero_f, string.format("hero_%02d", len + 80))
            _enemyNoHeros[i] = v.widget
            GetLock(i, v, _ref.enemyHeroPanel, false)
        end
    end
    _ref.enemyHeroPanel:GetCmp(typeof(UIGrid)).repositionNow = true
    _ref.enemyHeroPanel:ConstraintPivot(UIWidget.Pivot.Left, true)
    if len <= 4 then
        _ref.enemyHeroPanel.enabled = false
    end
end

--[Comment]
--演武榜获取守方玩家名字
--nm:直接传守方玩家名字
function _w.GetDefHeroName(nm)
    _defName = nm
end

local function SwitchHero(index)
    local atkHeroPos = _ownHeros[_chooseAtkIndex].transform.localPosition
    _tipTime = 0

    _battle:SetAtkFightHeroIdx(index)
    index = _battle:atkFightHeroIdx()

    local heroData = _battle:GetAtkHero(index)
    _ref.ownInfo[5].text = tostring(heroData.str.value)
    _ref.ownInfo[6].text = tostring(heroData.wis.value)
    _ref.ownInfo[7].text = heroData.hp.value .. "/" .. heroData.max_hp.value
    _ref.ownInfo[8].text = heroData.sp.value .. "/" .. heroData.max_sp.value
    _ref.ownInfo[9].text = heroData.tp.value .. "/" .. heroData.max_tp.value

    _ref.ownInfo[7]:GetCmp(typeof(UISlider)).value = heroData.hp.value / heroData.max_hp.value
    _ref.ownInfo[8]:GetCmp(typeof(UISlider)).value = heroData.sp.value / heroData.max_sp.value
    _ref.ownInfo[9]:GetCmp(typeof(UISlider)).value = heroData.tp.value / heroData.max_tp.value
    _ref.ownInfo[10].text = tostring(heroData.cap.value)

    local db = DB.GetHero(heroData.dbsn.value)

    _ref.ownInfo[11].text = db.nm
    _ref.ownInfo[11]:Child("select_stars", typeof(UIRepeat)).TotalCount = db.rare

    _ref.ownHeroType.spriteName = "hero_kind_" .. db.kind

    _ref.ownSoldier:LoadTexAsync(ResName.SoldierIcon(heroData.arm.value))
    _ref.ownLineup:LoadTexAsync(ResName.LineupIcon(heroData.lnp.value))

    if _battle:isPvpFight() then
        _ref.ownSoRes:SetActive(false)
        _ref.enemySoRes:SetActive(false)
        _ref.ownLuRes:SetActive(false)
        _ref.enemyLuRes:SetActive(false)
        _ref.tipSoldier:SetActive(false)
        _ref.tipLineup:SetActive(false)
    else
        local enemyHeroData = _battle:GetDefHero(_battle:defFightHeroIdx())
        local osod = DB.GetArm(heroData.arm.value)
        local esod = DB.GetArm(enemyHeroData.arm.value)
        local res = 0
        for i, v in ipairs(osod.sup) do
            if v == esod.sn then
                res = 1
                break
            end
        end
        if res == 0 then
            for i, v in ipairs(esod.sup) do
                if v == osod.sn then
                    res = -1
                    break
                end
            end
        end

        _ref.ownSoRes:SetActive(res ~= 0)
        _ref.enemySoRes:SetActive(res ~= 0)
        _ref.tipSoldier:SetActive(res < 0)
        _soldierSet = res <= 0
        _ref.ownSoRes.spriteName = res > 0 and "sp_lineup_1" or "sp_lineup_2"
        _ref.enemySoRes.spriteName = res > 0 and "sp_lineup_2" or "sp_lineup_1"

        _ref.ownSoRes.cachedTransform.localPosition = res > 0 and Vector3(14, 15, 0) or Vector3(-14, -15, 0)
        _ref.ownSoRes.cachedTransform.localEulerAngles = Vector3(0, 0, res > 0 and 0 or -90)
        _ref.enemySoRes.cachedTransform.localPosition = res > 0 and Vector3(15, -14, 0) or Vector3(-14, 15, 0)
        _ref.enemySoRes.cachedTransform.localEulerAngles = Vector3(0, 0, 0)

        local lab = _ref.ownSoRes:GetComponentInChildren(typeof(UILabel))
        lab.text = res > 0 and L("克制") or L("被克")
        lab.cachedTransform.localEulerAngles = Vector3(0, 0, res > 0 and -45 or 45)
        lab.cachedTransform.localPosition = Vector3(10, res > 0 and 10 or -10, 0)
        lab = _ref.enemySoRes:GetComponentInChildren(typeof(UILabel))
        lab.text = res > 0 and L("被克") or L("克制")
        lab.cachedTransform.localEulerAngles = Vector3(0, 0, res > 0 and 45 or -45)
        lab.cachedTransform.localPosition = Vector3(10, res > 0 and -10 or 10, 0)
        _ref.tipGrid.repositionNow = true

        res = 0
        local olud = DB.GetLnp(heroData.lnp.value)
        local elud = DB.GetLnp(enemyHeroData.lnp.value)
        for i, v in ipairs(olud.sup) do
            if v == elud.sn then
                res = 1
                break
            end
        end
        if res == 0 then
            for i, v in ipairs(elud.sup) do
                if v == olud.sn then
                    res = -1
                    break
                end
            end
        end

        _ref.ownLuRes:SetActive(res ~= 0)
        _ref.enemyLuRes:SetActive(res ~= 0)
        _ref.tipLineup:SetActive(res < 0)
        _lineSet = res <= 0

        _ref.ownLuRes.spriteName = res > 0 and "sp_lineup_1" or "sp_lineup_2"
        --_ref.ownLuRes.color = res>0 and Color.white or Color.red
        _ref.ownLuRes.cachedTransform.localPosition = res > 0 and Vector3(14, 15, 0) or Vector3(-14, -15, 0)
        _ref.ownLuRes.cachedTransform.localEulerAngles = Vector3(0, 0, res > 0 and 0 or -90)

        _ref.enemyLuRes.spriteName = res > 0 and "sp_lineup_2" or "sp_lineup_1"
        --_ref.enemyLuRes.color = res>0 and Color.red or Color.white
        _ref.enemyLuRes.cachedTransform.localPosition = res > 0 and Vector3(15, -14, 0) or Vector3(14, 15, 0)
        _ref.enemyLuRes.cachedTransform.localEulerAngles = Vector3(0, 0, 0)

        lab = _ref.ownLuRes:GetComponentInChildren(typeof(UILabel))
        lab.text = res > 0 and L("克制") or L("被克")
        lab.cachedTransform.localEulerAngles = Vector3(0, 0, res > 0 and -45 or 45)
        lab.cachedTransform.localPosition = Vector3(10, res > 0 and 10 or -10, 0)

        lab = _ref.enemyLuRes:GetComponentInChildren(typeof(UILabel))
        lab.text = res > 0 and L("被克") or L("克制")
        lab.cachedTransform.localEulerAngles = Vector3(0, 0, res > 0 and 45 or -45)
        lab.cachedTransform.localEulerAngles = Vector3(0, res > 0 and -10 or 10, 0)
        _ref.tipGrid.repositionNow = true
    end

    for i = 1, _battle.atkQty do
        local hutx = _ownHeros[i]
        local flag = hutx:Child("flag_lose").gameObject
        local lost = _battle:GetAtkHero(i).status.value ~= 1
        hutx.color = lost and Color(0, 0, 0.5) or Color(0.5, 0.5, 0.5)
        flag:SetActive(lost)
        if lost then
            hutx.gameObject.name = string.format("hero_%02d", i + 30)
        end

        if i == index or lost then
            if not lost then
                local db = DB.GetHero(heroData.dbsn.value)
                _ref.ownHeroImg:LoadTexAsync(ResName.HeroImage(db.img))
            end
        else
            hutx.cachedTransform.localScale = Vector3(1, 1, 1)
        end
    end

    _ref.ownHeroPanel:GetCmp(typeof(UIGrid)).repositionNow = true
    _chooseAtkIndex = index
end

function _w.RefreshInfo()
    local enemy = DB.GetHero(_battle.defAdv.value)
    _ref.ownInfo[1].text = user.nick
    _ref.ownInfo[2].text = L("可战武将:") .. _battle:atkAliveHeroQty() .. "/" .. _battle.atkQty
    local own = DB.GetHero(_battle:GetAtkHero(1).dbsn.value)
    _ref.ownInfo[3].text = L("军师:") .. own:GetEvoName(_battle:GetAtkHero(1).evo.value)
    _ref.ownInfo[4].text = DB.GetSkt(_battle.atkSktSn).i

    local kind = _battle.type.value
    if kind == 1 or kind == 4 then
        _ref.enemyInfo[1].text = DB.GetGmCity(_battle.sn).nm
    elseif kind == 2 then
        _ref.enemyInfo[1].text = DB.GetWarFromSub(_battle.sn).nm
    elseif kind == 3 then
        local pcd = user.GetPvpCity(_battle.sn)
        _ref.enemyInfo[1].text = pcd and pcd.occNm or ""
    elseif kind == 5 or kind == 0 then
        _ref.enemyInfo[1].text = _defName
    end

    _ref.enemyInfo[2].text = L("可战武将:") .. _battle:defAliveHeroQty() .. "/" .. _battle.defQty
    _ref.enemyInfo[3].text = L("军师:") .. enemy.nm
    _ref.enemyInfo[4].text = DB.GetSkt(_battle.defSktSn).i

    --出战武将的信息
    local enemyFightHero = _battle:defFightHeroIdx()
    local heroData = _battle:GetDefHero(enemyFightHero)
    local db = DB.GetHero(heroData.dbsn.value)
    _ref.enemyInfo[11].text = db.nm
    _ref.enemyInfo[11]:Child("select_stars", typeof(UIRepeat)).TotalCount = db.rare

    if _battle:isPvpFight() then
        for i = 5, 10 do
            _ref.enemyInfo[i].text = "???"
        end

        _ref.enemySoldier:LoadTexAsync()
        _ref.enemyLineup:LoadTexAsync()

        for i = 1, _battle.defQty do
            local hutx = _enemyHeros[i]
            local lost = _battle:GetDefHero(i).status.value ~= 1
            hutx.color = lost and Color(0, 0, 0) or Color(0.5, 0.5, 0.5)
        end
    else
        _ref.enemyInfo[5].text = tostring(heroData.str)
        _ref.enemyInfo[6].text = tostring(heroData.wis)

        _ref.enemyInfo[7].text = heroData.hp.value .. "/" .. heroData.max_hp.value
        _ref.enemyInfo[8].text = heroData.sp.value .. "/" .. heroData.max_sp.value
        _ref.enemyInfo[9].text = heroData.tp.value .. "/" .. heroData.max_tp.value

        _ref.enemyInfo[7]:GetCmp(typeof(UISlider)).value = heroData.hp.value / heroData.max_hp.value
        _ref.enemyInfo[8]:GetCmp(typeof(UISlider)).value = heroData.sp.value / heroData.max_sp.value
        _ref.enemyInfo[9]:GetCmp(typeof(UISlider)).value = heroData.tp.value / heroData.max_tp.value

        _ref.enemyInfo[10].text = tostring(heroData.cap.value)

        _ref.enemySoldier:LoadTexAsync(ResName.SoldierIcon(heroData.arm.value))
        _ref.enemyLineup:LoadTexAsync(ResName.LineupIcon(heroData.lnp.value))
    end

    for i = 1, _battle.defQty do
        local hutx = _enemyHeros[i]
        local flag = hutx:Child("flag_lose").gameObject
        local lost = _battle:GetDefHero(i).status.value ~= 1
        flag:SetActive(lost)
        hutx.color = lost and Color(0, 0, 0.5) or Color(0.5, 0.5, 0.5)
        if lost then
            hutx.gameObject.name = string.format("hero_%02d", i + 30)
        end
        if i == enemyFightHero or lost then
            if not lost then
                _ref.enemyHeroImg:LoadTexAsync(ResName.HeroImage(db.img))
            else
                hutx.cachedTransform.localScale = Vector3(1, 1, 1)
            end
        end
    end
    _ref.enemyHeroPanel:GetCmp(typeof(UIGrid)).repositionNow = true
    SwitchHero(_battle:atkFightHeroIdx())
    _update = UpdateBeat:CreateListener(Update)
    UpdateBeat:AddListener(_update)
end

function _w.OnInit()
--    _w.initObj = QYBattle.GenBattleSiege('{4,576532978,84,0,12,43,2331231,2331231,60,[13,0,0,3,8000,12,20,70,100,80,80,50,200,400,60],[{42116,15,5,80,7127,823,911,100,8210,8210,58,58,21,21,1,5,50,"||||bf,5|jb,2|sb,8|cd,12"},{42225,34,0,80,3530,2441,875,100,3026,3026,55,55,21,21,5,6,1,"ml,120|jy,11|ts,157|||ak,1400|ak,1400|"},{42226,30,5,80,6674,2612,2342,100,12498,12498,53,53,22,22,2,6,50,"sb,2|ak,145|cpd,2|ml,94|mf,2|wf,3|xy,5|jy,13|bj,2|||ts,1450|ak,1400|ak,1400|ts,1100|ak,1400|ml,1400|ak,110|ak,110|cd,7|xy,10|bj,8|mf,12"},{42228,13,5,80,6837,2260,2362,100,12075,12075,56,56,21,21,9,3,50,"wf,2|wf,2|ts,117|wf,3|ml,66|js,2|bf,3|cpd,6|mf,3|||ak,1400|ak,1400|ak,1400|ak,1400|ts,1450|ak,1400|xy,10|js,7|sb,10|bj,12"},{42347,16,4,80,24914,3291,743,95,6028,6028,156,156,16,16,2,6,9,"xy,4|cpd,5|wf,4|lx,29|xy,3|xy,4|lx,13|mf,2|cd,2|||ak,60|ak,1400|"}],[{25,43,0,144,2016,4776,2390,100,4978,4978,101,101,52,52,5,7,0,""},{411,435,0,144,1927,4554,2279,100,4762,4762,101,101,52,52,3,6,0,""},{412,414,0,144,2284,2099,4560,100,4966,4966,79,79,73,73,4,7,0,""},{413,423,0,144,4568,1920,2101,100,5781,5781,79,79,52,52,5,8,0,""},{414,445,0,144,1927,4554,2279,100,4762,4762,101,101,52,52,6,9,0,""}],{[2,1,0,0,0,0,0,0,20,0,0,0,0,0,0,0,0,0,0,0,0],"ak,1075|ml,1165|ts,1011",[0,0,0,0,0],[],"","",""},{[11,1,20,20,20,0,0,-50,0,0,0,0,0,0,0,0,0,0,0,0,0],"",[],[],"","",""}}')
    _battle = _w.initObj
    _w.Data = _battle
    _chooseAtkIndex = _battle.atkQty
    _chooseDefIndex = 1
    if _battle and _battle.atkQty > 0 and _battle.defQty > 0 then
        BuildHeros()
        Invoke(_w.RefreshInfo, 1)
    else
        Destroy(_body.gameObject)
    end
end

local function BeginTiming()
    _time = _battle.fightTime
    _delta = 0
    _timeLab.text = "60"
    _timeLab.enabled = true
end

WinBattle.BeginTiming = BeginTiming

local function CoOnEnter()
    --VS隐藏
    _ref.flagvs:SetActive(false)
    --创建动画面板
    _go = Tools.CreatAnimPanel(_body.gameObject, 110, true)

    --创建屏幕纹理
    local left = _go:AddChild(_ref.screen_left, "left", false):GetCmp(typeof(UIMeshTexture))
    local right = _go:AddChild(_ref.screen_right, "right", false):GetCmp(typeof(UIMeshTexture))

    local kind = _battle.type.value
    if kind == 1 then
        FillScreen.CaptureScrennTexture(left, Camera.main, false)
        FillScreen.CaptureScrennTexture(right, Camera.main, false)
    elseif kind > 1 then
        FillScreen.CaptureScrennTexture(left, UE.Camera.main, false)
        FillScreen.CaptureScrennTexture(right, UE.Camera.main, false)
    else
        FillScreen.CaptureScrennTexture(left, Camera.main, false)
        FillScreen.CaptureScrennTexture(right, Camera.main, false)
    end
    --if (MapManager.Instance) MapManager.Instance.gameObject.SetActive(false);
    --if (MainPanel.Instance) MainPanel.Instance.gameObject.SetActive(false);

    if FillScreen.getPlace() == FillPlace.Horizontal then
        --水平
        left.width = Screen.width / FillScreen.getZoom()
        right.width = Screen.width / FillScreen.getZoom()
    elseif FillScreen.getPlace() == FillPlace.Vertical then
        --垂直
        left.height = Screen.height / FillScreen.getZoom()
        right.height = Screen.height / FillScreen.getZoom()
    end
    left.uvRect = Rect(0, 0, 1, 1)
    right.uvRect = Rect(0, 0, 1, 1)

    --创建标题动画
    local ef_vs_1 = _go:AddChild(AM.LoadPrefab("ef_ui_VS05"))
    local ef_vs_2 = _body:AddChild(AM.LoadPrefab("ef_ui_VS06"))

    --播放标题动画
    ef_vs_1:SetActive(true)
    coroutine.wait(0.1)

    --移开左右屏
    EF.MoveTo(left, "x", -900, "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInExpo)
    EF.MoveTo(right, "x", 900, "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInExpo)

    --VS出现
    coroutine.wait(0.3)

    --删除动画面板
    FillScreen.ReleaseScrennTexture(right)

    Destroy(_go)
    _go = nil

    Destroy(ef_vs_1)

    ef_vs_2:SetActive(true)

    coroutine.wait(1.15)

    _ref.flagvs:SetActive(true)

    Destroy(ef_vs_2)

    BeginTiming()
end

function _w.OnEnter()
    coroutine.start(CoOnEnter)
end

local function DestroyUTXs(utxs)
    if utxs then
        for i, v in ipairs(utxs) do
            v:UnLoadTex()
            Destroy(v.gameObject)
        end
        utxs = nil
    end
end

function _w.Active(v)
    if v == true then
        _update = UpdateBeat:CreateListener(Update)
        UpdateBeat:AddListener(_update)
    else
        if _update ~= nil then UpdateBeat:RemoveListener(_update) end
    end
    _body.active = v
end

function _w.OnDispose()
    if _update ~= nil then UpdateBeat:RemoveListener(_update) end
    DestroyUTXs(_ownHeros)
    _ownHeros = nil
    DestroyUTXs(_enemyHeros)
    _enemyHeros = nil
    DestroyUTXs(_ownNoHeros)
    _ownNoHeros = nil
    DestroyUTXs(_enemyNoHeros)
    _enemyNoHeros = nil

    _ref.enemyHeroImg:UnLoadTex()
    _ref.ownHeroImg:UnLoadTex()
    _ref.ownLineup:UnLoadTex()
    _ref.ownSoldier:UnLoadTex()
    _ref.enemyLineup:UnLoadTex()
    _ref.enemySoldier:UnLoadTex()

    _ref.ownLuRes:SetActive(false)
    _ref.ownSoRes:SetActive(false)

    _ref.enemyLuRes:SetActive(false)
    _ref.enemySoRes:SetActive(false)

    _ref.tipLineup:SetActive(false)
    _ref.tipSoldier:SetActive(false)

    for i, v in ipairs(_ref.ownInfo) do
        v.text = ""
    end
    for i, v in ipairs(_ref.enemyInfo) do
        v.text = ""
    end
end

function _w.OnEnabled()
    BGM.PlaySOE("bg_3")
    _ref.eff_ready.enabled = true
    _ref.eff_start.enabled = false
    _ref.eff_start:Child("men_l"):SetActive(false)
    _ref.eff_start:Child("men_r"):SetActive(false)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _battle = nil
        _defName = nil
        _lineSet = nil
        _soldierSet = nil
        _go = nil
        _time = nil
        _tipTime = nil
        _delta = nil
        _result = nil
        _chooseAtkIndex = nil
        _chooseDefIndex = nil
        _ownHeros = nil
        _ownNoHeros = nil
        _enemyHeros = nil
        _enemyNoHeros = nil
        _w.Data = nil
    end
end

local function Retreat()
    local kind = _battle.type.value
    if kind > 0 then
        _body:Exit()
        if kind == 12 then
            --地宫探险
        else
        end
        return
    end
end

--[Comment]
--撤退
function _w.ClickRetreat()
    if _battle.type.value == 1 and user.gmMaxCity < CONFIG.T_LEVEL then
        ToolTip.ShowPopTip(L("我军兵锋正盛，正可一举破城！"))
        return
    end
    MsgBox.Show(L("您确定要撤退吗？"),L("取消,确定"), function(bid)
        if bid == 1 then
            Retreat()
        end
    end )
end
--[Comment]
--战斗
function _w.ClickFight()
    if BattleManager ~= nil and BattleManager.CheckIsBegin() then return end
    if _battle and  _battle:atkAliveHeroQty()>0 and _battle:defAliveHeroQty()>0 then
        local atkHero = _battle:GetAtkHero(_battle:atkFightHeroIdx())
        local defHero = _battle:GetDefHero(_battle:defFightHeroIdx())
        if atkHero and defHero and atkHero.status.value==1 and defHero.status.value==1 then
            _timeLab.enabled = false
            if _battle.type.value == 12 then
                SVR.GveBattleFight(atkHero.sn,defHero.sn,_battle:typeSend(),
                function(result) if result.success then
                    Win.Open("BattleManager", QYBattle.BattleSiegeFight(_battle, SVR.datCache))
                    BGM.PlaySOE("sound_click_fight")
                end end)
            else
                SVR.BattleFight(atkHero.sn,defHero.sn,_battle:typeSend(),
                function(result) if result.success then
                    Win.Open("BattleManager", QYBattle.BattleSiegeFight(_battle, SVR.datCache))
                    BGM.PlaySOE("sound_click_fight")
                end end)
            end
        end
    end
end
--[Comment]
--一键备战
function _w.ClickFastSet()
    --只有被克制了和相同才进去
    if _lineSet then
        PopBattleSelect.FastSet( { _battle:GetAtkHero(_battle:atkFightHeroIdx()), 1 })
    end
    if _soldierSet then
        PopBattleSelect.FastSet( { _battle:GetAtkHero(_battle:atkFightHeroIdx()), 2 })
    end
end
function _w.ClickOwnSoldier()
    Win.Open("PopBattleSelect", { _battle:GetAtkHero(_battle:atkFightHeroIdx()), 2 })
end
function _w.ClickOwnLineup()
    Win.Open("PopBattleSelect", { _battle:GetAtkHero(_battle:atkFightHeroIdx()), 1 })
end
function _w.ClickHero(i)
    if i ~= _battle:atkFightHeroIdx() then
        SwitchHero(i)
    end
end
if isDebug then
    function _w.ClickEnemyHero(i)
        _battle:SetFightIdx(i)
    end
end