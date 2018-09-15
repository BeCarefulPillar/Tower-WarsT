local _w = { }
--- <summary>战斗结算</summary>
PopResult = _w

local _body = nil
local _ref = nil

local _dat = nil

local _goods = nil
local _items = nil
local _isOver = nil
local _ShowTip = nil
--- <summary>快速显示</summary>
local _ShowQuickly = nil

local _coEnter = nil
local _coExit = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _isOver = false
    _ShowTip = false
    _ShowQuickly = false
    WinBackground(c, { k = WinBackground.MASK })
end

local function Active()
    return _body.activeSelf
end

local function IsShowExp()
    if _items then
        for i, v in ipairs(_items) do
            if v and ItemHeroResult.IsShow(v) then
                return true
            end
        end
    end
    return false
end

local function StopAllCoroutines()
    if _coEnter then
        coroutine.stop(_coEnter)
        _coEnter = nil
    end
    if _coExit then
        coroutine.stop(_coExit)
        _coExit = nil
    end
end

function _w.OnInit()
--    local str = '{1,93,1,[{15,51,863291,1616,26,17,100},{41709,51,825188,3222,43,13,100},{42225,80,8595058,2786,27,21,100},{42369,51,819682,1554,43,13,100},{42415,51,813254,938,32,36,100}],[{1,1,20600},{1,15,100}],[],[]}'
--    _dat = kjson.ldec(str, stab.S_BattleResult)
    _dat = user.battleRet
    print(tts(_dat))

    if not _dat then
        return
    end

    if _dat.heros then
        _isOver = false
        if #_dat.heros > 0 then
            _items = { }
            for i, v in ipairs(_dat.heros) do
                local it = _ref.heroGrid:AddChild(_ref.item_hero_result,
                string.format("item_%02d", i)).luaC.luaTable
                _items[i] = it
                ItemHeroResult.Init(it, user.GetHero(v.csn), v.lv, v.exp)
            end
            _ref.heroGrid:Reposition()
            _ref.heroGrid.repositionNow = true
        end
    end

    if _dat.rws then
        if #_dat.rws > 0 then
            _goods = { }
            for i, v in ipairs(_dat.rws) do
                local ig = ItemGoods(_ref.goodsGrid:AddChild(_ref.item_goods,
                    string.format("goods_%02d", i)))
                _goods[i] = ig
                ig:Init(v)
                ig.go.luaBtn.luaContainer = _body
                ig:HideName()
                ig.go:SetActive(false)
            end
            _ref.goodsGrid:Reposition()
            _ref.goodsGrid.repositionNow = true
        end
    end

    _body:GetCmp(typeof(UE.BoxCollider)).enabled = notnull(_ref.failed)
end

local function CorEnter()
    _body:GetCmp(typeof(TweenScale)):PlayForward()
    TweenAlpha.Begin(_body.gameObject, 0.3, 1)

    -- 加载结果
    _ref.result:SetActive(false)
    _ref.win:SetActive(_dat.ret == 1)
    _ref.failed:SetActive(_dat.ret ~= 1)

    if _dat.ret == 1 then
        -- 结果动画
        _ref.btnCityFB:SetActive(false)
        _ref.btnCityDev:SetActive(false)

        BGM.PlaySOE("sound_battle_win")

        -- 创建动画面板
        local go = Tools.CreatAnimPanel(_body.gameObject, 100)

        -- 标题移动效果
        local temp = go:AddChild(_ref.result.cachedGameObject, "result").widget
        temp.cachedTransform.position = _ref.result.cachedTransform.position
        temp:SetActive(true)
        temp.alpha = 0
        TweenAlpha.Begin(temp.cachedGameObject, 0.27, 1)
        EF.MoveFrom(temp, "position", Vector3(0, 0, -400),
        "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInExpo)
        EF.RotateFrom(temp, "rotation", Vector3(math.random(-90, 0), math.random(-45, 45), 0),
        "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInExpo)
        EF.wsCast(temp, 0.1)
        coroutine.wait(0.3)

        -- 结果出现 删除动画面板
        _ref.result:SetActive(true)
        Destroy(go)

        coroutine.step()
        coroutine.step()

        if _ShowQuickly then
            _ref.result:AddChild(AM.LoadPrefab("ef_result_1_quickly"), "ef_result_1_quickly")
        else
            _ref.result:AddChild(AM.LoadPrefab("ef_result_1"), "ef_result_1")
            EF.ShakePosition(_body, "y", 30, "time", 0.24, "islocal", true)
            coroutine.wait(0.4)
            EF.ShakePosition(_body, "y", 30, "time", 0.24, "islocal", true)
            coroutine.wait(0.6)
        end

        -- 开始显示经验值增加动画
        if _ShowQuickly then
            if _items then
                for i, v in ipairs(_items) do
                    if v then
                        ItemHeroResult.ShowEffectQuickly(v)
                    end
                end
            end
        else
            if _items then
                for i, v in ipairs(_items) do
                    if v then
                        ItemHeroResult.ShowEffect(v)
                    end
                end
            end
        end

        -- 显示稀有奖励
        PopRewardShow.ShowRare(_dat.rws, false)

        -- 道具出现粒子效果
        if _goods then
            for i, ig in ipairs(_goods) do
                if ig then
                    if _dat.kind == 1 and _dat.sn < CONFIG.T_LEVEL and user.gmMaxCity < CONFIG.T_LEVEL and objt(ig.dat) == DB_Props then
                        local dp = ig.dat
                        if dp.rare <= CONFIG.tipPropsRare and
                            (dp.sn == DB_Props.DA_JING_YAN_DAN or
                            dp.sn == DB_Props.SHU_XING_YAO_JI) then
                            NewEffect.ShowProps(dp, user.GetPropsQty(dp.sn))
                        end
                    end
                    if _ShowQuickly then
                        ig.go:SetActive(true)
                    else
                        ig.go:SetActive(true)
                        local ef = ig.go:AddChild(AM.LoadPrefab("ef_goods_sparks"), "ef_goods_sparks").transform
                        ef.rotation:SetFromToRotation(ef.forward, ef.position)
                        coroutine.step()
                        coroutine.step()
                        coroutine.wait(0.2)
                    end
                end
            end
        end
    else
        BGM.PlaySOE("sound_battle_failed")
        _ref.failedGrid:SetActive(user.gmMaxCity >= CONFIG.T_LEVEL)
        _ref.result:SetActive(true)
        coroutine.step()
        coroutine.step()
        _ref.result:AddChild(AM.LoadPrefab("ef_result_0"), "ef_result_0")
        coroutine.wait(1)
        _ref.result.alpha = 0
        TweenAlpha.Begin(_ref.result.cachedGameObject, 0.3, 1)
        coroutine.wait(2)
    end

    while _dat.ret == 1 and IsShowExp() do
        coroutine.step()
    end

    _isOver = true

    _coEnter = nil
end
function _w.OnEnter()
    _coEnter = coroutine.start(CorEnter)
end

local function CorExit()
    _ShowQuickly = false
    if Active() then
        _body:GetCmp(typeof(TweenScale)):PlayReverse()
        local ta = TweenAlpha.Begin(_body.gameObject, 0.3, 0)
        while ta.enabled do
            coroutine.step()
        end
    end
    if user.gmMaxCity >= CONFIG.T_LEVEL and #_dat.captive > 0 then
        Win.Open("WinCaptive")
    else
        -- BattleManager.BattleEndEvent();
    end

    -- 播放升级特效
    if user.hlv > user.olv then
        local res = { user.olv, user.hlv, user.ovit, user.vit }
        Win.Open("PopLevelUpInfo", res)
    end

    -- if (User.TutorialSN == 1)
    -- {
    -- if (User.TutorialStep == (int)Tutorial.Step.TutStep02)
    -- {
    -- if (MainPanel.Instance) MainPanel.Instance.QuestTrace.CheckTutorial();
    -- }
    -- }

    _coExit = nil
end
function _w.OnExit()
    StopAllCoroutines()
    _coExit = coroutine.start(CorExit)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        --package.loaded["Game.PopResult"] = nil
    end
end

function _w.OnDispose()
    StopAllCoroutines()
    _isOver = false
    _ref.goodsGrid:DesAllChild()
    _goods = nil
    _ref.heroGrid:DesAllChild()
    _items = nil
    _ShowTip = false
    _ref.tip_level:SetActive(false)
end

function _w.ClickWar()
    Win.Open("WinDaily")
    if _isOver then
        _body:Exit()
    end
end
function _w.ClickFB()
    Win.Open("WinFB")
    if _isOver then
        _body:Exit()
    end
end
function _w.ClickTavern()
    Win.Open("WinHero")
    if _isOver then
        _body:Exit()
    end
end
function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn)
    if btn then
        btn:ShowPropTip()
    end
end
function _w.ClickClose()
    _ShowQuickly = true
    _isOver = true
    -- 极限挑战
    if _dat.kind == 10 then
        SVR.HeroChallengeOpt("inf", function(t)
            if t.success then
                Win.Open("PopChallenge", SVR.datCache)
            end
        end )
    end
    print(Win)
    _body:Exit()
end
function _w.ClickCityDev()
    if _dat.kind == 1 and _dat.ret == 1 then
        Win.Open("PopCityUpgrade", _dat.sn)
    end
    _body:Exit()
end
function _w.ClickCityFB()
    if _dat.kind == 1 and _dat.ret == 1 then
        Win.Open("PopHistory", _dat.sn)
    end
    _body:Exit()
end
function _w.ClickFB()
    if _dat.kind == 1 then
        local pcd = user.GetPveCity(_dat.sn)
        if pcd and pcd.fbQty > 0 then
            Win.Open("PopHistory", pcd.sn)
            _body:Exit()
            return
        end
    end
    local hc = user.gmMaxCity
    while hc > 1 do
        local pcd = user.GetPveCity(hc)
        hc = hc - 1
        if pcd and pcd.fbQty > 0 then
            Win.Open("PopHistory", pcd.sn)
            _body:Exit()
            return
        end
    end
end