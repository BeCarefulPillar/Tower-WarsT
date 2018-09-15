require "Battle/Data/QYBattle"

require "Battle/BU_Unit"
require "Battle/BU_Arrow"
require "Battle/BU_Hero"
require "Battle/BU_Soldier"
require "Battle/BU_SKC"
require "Battle/BU_SKD"
require "Battle/BU_BuffControl"
require "Battle/BU_Control"
require "Battle/FightPlotDialogue"
require "Battle/BU_Map"

local tostr = tostring
local i64tostr = int64.tostring
local newI64 = int64.new
local Camera = UnityEngine.Camera


local bat = { }

--region  -------------- TimeLine --------------

local timeLine = {
    tlac = 3,
    cbrq = 0,
    cbrq_s = 0,
    sb = 0,
    cbrc = 0,
    cbrc_s = 0,
    ctm = 0,
    -- -4=跳过 -3=完成结束 -2=抽查异常 -1=网络超时或错误 0=初始 1=初始的请求返回了|正常
    stat = -3,

    debug = "",
}

function timeLine.Begin(skip)
    local tl = timeLine
    if skip then
        tl.stat = -4
        tl.ctm = 0
        return
    end
    tl.stat = 0
    tl.sb = 0
    tl.cbrq = Time.realtimeSinceStartup
    tl.cbrc = tl.cbrq
    tl.cbrq_s = DT.Now.Ticks
    tl.cbrc_s = tl.cbrq_s
    tl.ctm = tl.cbrq + Mathf.Random(5, 20)

    SVR.GetSvrTime(function (r) if r.success then
        tl.stat = 1
        tl.cbrc = Time.realtimeSinceStartup
        tl.cbrc_s = DT.Now.Ticks
        tl.sb = SVR.datCache
if isDebug then
        tl.debug = "s_begin = ".. tl.sb .."\nc_begin_request = "..tl.cbrq.."\nc_begin_receive = "..tl.cbrc.."\nc_begin_request_s = "..i64tostr(tl.cbrq_s).."\nc_begin_receive_s = "..i64tostr(tl.cbrc_s).."\n"
end
    else tl.stat = -1
    end end)
end

function timeLine.Check()
    local tl = timeLine
    if tl.stat < 0 or tl.ctm <= 0 or Time.realtimeSinceStartup < tl.ctm then return end
    tl.ctm = 0
    local cerq = Time.realtimeSinceStartup
    local cerq_s = DT.Now.Ticks
    SVR.GetSvrTime(function (r) if r.success and tl.stat == 1 then
        local cerc = Time.realtimeSinceStartup
        local cerc_s = DT.Now.Ticks
        local se = SVR.datCache
        local sdt = (se - tl.sb) * 0.001
if isDebug then
        tl.debug = tl.debug.."\ns_end = "..se.."\nc_end_request = "..cerq.."\nc_end_receive = "..cerc.."\nc_end_request_s = "..i64tostr(cerq_s).."\nc_end_receive_s = "..i64tostr(cerc_s).."\n"
end

        local tmp = nil
        if tl.cbrc - tl.cbrq < tl.tlac then
            tmp = (tl.tlac - tl.cbrc + tl.cbrq) * 0.5
            tl.cbrq = tl.cbrq - tmp
            tl.cbrc = tl.cbrc + tmp
        end
        if cerc - cerq < tl.tlac then
            tmp = (tl.tlac - cerc + cerq) * 0.5
            cerq = cerq - tmp
            cerc = cerc + tmp
        end
        tl.stat = (sdt > cerq - tl.cbrc - tl.tlac and sdt < cerc - tl.cbrq + tl.tlac) and 1 or -2

        if tl.stat == 1 then
            local ssdt = newI64(tostr(sdt * CONFIG.SEC_TO_TICK))
            local csdt = tl.cbrc_s - tl.cbrq_s
            local tlac_t = newI64(tostr(tl.tlac * CONFIG.SEC_TO_TICK))
            if csdt < tlac_t then
                tmp = (tlac_t - csdt) / newI64("2")
                tl.cbrq_s = tl.cbrq_s - tmp
                tl.cbrc_s = tl.cbrc_s + tmp
            end
            csdt = cerc_s - cerq_s
            if csdt < tlac_t then
                tmp = (tlac_t - csdt) / newI64("2")
                cerq_s = cerq_s - tmp
                cerc_s = cerc_s + tmp
            end
            tl.stat = (ssdt > cerq_s - tl.cbrc_s - tlac_t and ssdt < cerc_s - tl.cbrq_s + tlac_t) and 1 or -2
        end

if isDebug then
        tl.debug = tl.debug.."c_begin_request = "..tl.cbrq.."\nc_begin_receive = "..tl.cbrc.."\n"
        tl.debug = tl.debug.."c_end_request = "..cerq.."\nc_begin_receive = "..cerc.."\n"
        tl.debug = tl.debug.."c_begin_request_s = "..i64tostr(tl.cbrq_s).."\nc_begin_receive_s = "..i64tostr(tl.cbrc_s).."\n"
        tl.debug = tl.debug.."c_end_request_s = "..i64tostr(cerq_s).."\nc_begin_receive_s = "..i64tostr(cerc_s).."\n"
        tl.debug = tl.debug.." = "..sdt.."\ncdt1 = "..(cerq - tl.cbrc).."\ncdt2 = "..(cerc - tl.cbrq).."\ncdts1 = "..i64tostr(cerq_s - tl.cbrc_s).."\ncdts2 = "..i64tostr(cerc_s - tl.cbrq_s).."\nerr = "..tl.stat
        print(tl.debug)
end
    elseif tl.stat >= 0 then tl.stat = -1
    end end)
end

function timeLine.End(onres)
    if onres == nil then return end
    local tl = timeLine
    if tl.stat < 0 then onres(tl.stat == -4) return end
    local cerq = Time.realtimeSinceStartup
    local cerq_s = DT.Now.Ticks
    SVR.GetSvrTime(function (r) local pass = false if r.success and tl.stat == 1 then
        local cerc = Time.realtimeSinceStartup
        local cerc_s = DT.Now.Ticks
        local se = SVR.datCache
        local sdt = (se - tl.sb) * 0.001
        
if isDebug then
        tl.debug = tl.debug.."\ns_end = "..se.."\nc_end_request = "..cerq.."\nc_end_receive = "..cerc.."\nc_end_request_s = "..i64tostr(cerq_s).."\nc_end_receive_s = "..i64tostr(cerc_s).."\n"
end

        local tmp = nil
        if tl.cbrc - tl.cbrq < tl.tlac then
            tmp = (tl.tlac - tl.cbrc + tl.cbrq) * 0.5
            tl.cbrq = tl.cbrq - tmp
            tl.cbrc = tl.cbrc + tmp
        end
        if cerc - cerq < tl.tlac then
            tmp = (tl.tlac - cerc + cerq) * 0.5
            cerq = cerq - tmp
            cerc = cerc + tmp
        end
        pass = sdt > cerq - tl.cbrc - tl.tlac and sdt < cerc - tl.cbrq + tl.tlac

        if pass then
            local ssdt = newI64(tostr(sdt * CONFIG.SEC_TO_TICK))
            local csdt = tl.cbrc_s - tl.cbrq_s
            local tlac_t = newI64(tostr(tl.tlac * CONFIG.SEC_TO_TICK))
            if csdt < tlac_t then
                tmp = (tlac_t - csdt) / newI64("2")
                tl.cbrq_s = tl.cbrq_s - tmp
                tl.cbrc_s = tl.cbrc_s + tmp
            end
            csdt = cerc_s - cerq_s
            if csdt < tlac_t then
                tmp = (tlac_t - csdt) / newI64("2")
                cerq_s = cerq_s - tmp
                cerc_s = cerc_s + tmp
            end
            pass = ssdt > cerq_s - tl.cbrc_s - tlac_t and ssdt < cerc_s - tl.cbrq_s + tlac_t
        end
        tl.stat = -3

if isDebug then
        tl.debug = tl.debug.."c_begin_request = "..tl.cbrq.."\nc_begin_receive = "..tl.cbrc.."\n"
        tl.debug = tl.debug.."c_end_request = "..cerq.."\nc_begin_receive = "..cerc.."\n"
        tl.debug = tl.debug.."c_begin_request_s = "..i64tostr(tl.cbrq_s).."\nc_begin_receive_s = "..i64tostr(tl.cbrc_s).."\n"
        tl.debug = tl.debug.."c_end_request_s = "..i64tostr(cerq_s).."\nc_begin_receive_s = "..i64tostr(cerc_s).."\n"
        tl.debug = tl.debug.."sdt = "..sdt.."\ncdt1 = "..(cerq - tl.cbrc).."\ncdt2 = "..(cerc - tl.cbrq).."\ncdts1 = "..i64tostr(cerq_s - tl.cbrc_s).."\ncdts2 = "..i64tostr(cerc_s - tl.cbrq_s).."\nerr = "..tl.stat
        print(tl.debug)
end
    elseif tl.stat >= 0 then tl.stat = -1
    end if onres ~= nil then onres(pass) end end)
end

if isDebug then
function timeLine.output() return timeLine.debug end
end

function timeLine.isNetErr() return timeLine.stat == -1 end

--endregion

local _body = nil
local _ref = nil

local _left = nil
local _right = nil
local _bg_a = nil
local _bg_b = nil
local _bg_c = nil
local _map = nil
local _ctlr = nil
local _plot = nil
local _ownSk = nil
local _enemySk = nil

local _mapsn = nil
local _auto = nil
local _data = nil

local _isBegin = nil

local function CheckIsBegin() return _body ~= nil and _body.gameObject.activeInHierarchy and _isBegin end

local _update = UpdateBeat:CreateListener(function()
    if CheckIsBegin() and _map.Active then timeLine.Check() end
end)

-- 释放
local function Dispose()
    UpdateBeat:RemoveListener(_update)
    _data = nil
    _ctlr:Dispose()
    _plot.Dispose()
    _map:Dispose()
    _map:DisposeSkillRes()
    local tmp = _map.go.transform.parent
    EF.ClearITween(tmp)
    tmp.localPosition = Vector3.zero
    Time.timeScale = 1
end

local function ShowResult(res)
    local opt = 1
    local ed = true
    local tm = 0
    -- 创建动画面板
    local go = Tools.CreatAnimPanel(SceneGame.body.gameObject, 110, true, CONFIG.TIME_OUT + 8)
    local tmp = nil
    if res ~= 0 then
        local dat = _data.battle
        local ocf = dat:atkAliveHeroQty()
        local ecf = dat:defAliveHeroQty()
        ed = ocf <= 0 or ecf <= 0
        tm = Time.realtimeSinceStartup
        -- 战场结束
        if ed and dat.type.value then
            -- 向服务器发送结算，并显示结算画面
            opt = 0
            if dat.type.value == 12 then
                SVR.GveBattleResult(ocf > 0 and 1 or 0, dat, function (r) opt = r.success and 1 or -1 end)
            else
                SVR.BattleResult(ocf > 0 and 1 or 0, dat, function (r) opt = r.success and 1 or -1 end)
            end
        end
        if dat.type.value == 0 then
            tmp = { }
            tmp.kind = 0
            tmp.sn = 1
            tmp.ret = 1
            tmp.rws = {{ 1, 1, 50 }, { 1, 2, 50}}
            tmp.captive = { 108 }
            tmp.add = nil
            tmp.heros = {{ csn = 15, lv = 60, exp = 0, hp = 0, sp = 0, tp = 0, loyalty = 0 }}
            user.battleRet = tmp
            -- 等待对话结束
            local cor = coroutine.start(_plot.Show, L("R:我...竟然败了！"))
            local stat = coroutine.status(cor)
            while stat ~= "dead" do
                stat = coroutine.status(cor)
                coroutine.step()
            end
        end
        -- 创建标题动画
        tmp = go:AddChild(AM.LoadPrefab(res > 0 and "ef_ui_zhandoushengli02" or "ef_ui_zhandoushibai02"))
        tmp:SetActive(false)
        coroutine.wait(2)
        -- 播放标题动画
        tmp:SetActive(true)
--        tmp.cachedTransform.localPosition = Vector3(0, 180, 0)
--        tmp.alpha = 0
--        if res > 0 then
--            tmp.width, tmp.height = 363, 134
--            EF.Alpha(tmp, 0.27, 1)
--            EF.MoveFrom(tmp, "position", Vector3(0, 0, -400), "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInExpo)
--            EF.RotateFrom(tmp, "x", -math.random(30, 60), "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInExpo)
--            EF.wsCast(tmp, 0.1)
--        else
--            tmp.width, tmp.height = 364, 145
--            EF.Alpha(tmp, 0.3, 1)
--        end
--        -- 等待标题进入动画结束 0.3
--        -- 等待标题显示一段时间 1.5
--        coroutine.wait(1.8)
--        -- "成功标题"退出动画
--        if res > 0 then
--            EF.Alpha(tmp, 0.2, 0)
--            EF.Scale(tmp, 0.2, Vector3.one * 1.5)
--        -- "失败标题"退出动画
--        else WidgetEffect.Detonate(tmp, 6, 5, 0, true)
--        end
        -- "等待标题"退出动画完成
        coroutine.wait(2.5)
    else
        ed = 1
        opt = -1
    end
    -- 创建屏幕纹理
    -- 创建屏幕UITexture
    local utx = go:AddWidget(typeof(UITexture), "temp_screen")
    FillScreen.CaptureScrennTexture(utx, Camera.main, true)
--    utx.uvRect = new Rect(0, 0, 1, 1);
--    //水平
--    if (FillScreen.Place == FillScreen.FillPlace.Horizontal)
--    {
--        utx.width = (int)(Screen.width / FillScreen.Zoom);
--    }
--    //垂直
--    else if (FillScreen.Place == FillScreen.FillPlace.Vertical)
--    {
--        utx.height = (int)(Screen.height / FillScreen.Zoom);
--    }
    coroutine.step()
    -- 卸载战场
    _body:Exit()
    -- 卸载未使用的资源
    --AM.UnloadUnusedAssets()
    -- 战场结束
    if SceneGame ~= nil then SceneGame.ShowMainUIAndMap() end
    if ed then
        if user.gmMaxCity < CONFIG.T_LEVEL then Tutorial.Active = true end
        -- 激活背景
        if WinBattle and WinBattle.body ~= nil then WinBattle.body:Exit() end

        while opt == 0 and Time.realtimeSinceStartup - tm < CONFIG.TIME_OUT do coroutine.step() end
        -- 战斗结束后续
        if opt > 0 then
            if WinBattle then Win.Close("WinBattle", true) end

            -- PVE PVP 副本
            if user.battleRet.kind == 0 or user.battleRet.kind == 1 or user.battleRet.kind == 3 or user.battleRet.kind == 4 then
                -- 战斗结束打开结算界面
                Win.Open("PopResult")
            -- 战役
            elseif user.battleRet.kind == 2 then Win.Open("PopWarDetail", 0)
            -- 演武榜
            elseif user.battleRet.kind == 5 then Win.Open("WinRankSolo")
            -- BOSS战
            elseif user.battleRet.kind == 6 then Win.Open("WinBoss")
            -- 过关斩将
            elseif user.battleRet.kind == 7 then
                Win.Open("WinTower")
                PopRewardShow.Show(user.battleRet.rws)
            -- 乱世争雄
            elseif user.battleRet.kind == 9 then
                tmp = DB.GetClanWar(user.battleRet.sn)
                Win.Open("WinClanWar", tmp)
            -- 极限挑战
            elseif user.battleRet.kind == 10 then Win.Open("PopResult")
            -- 地宫探险
            elseif user.battleRet.kind == 12 then
                Win.Open("WinExplorer")
            -- 修罗降临
            elseif user.battleRet.kind == 13 then
                Win.Open("WinBoss2")
                WinBoss2.Refresh()
            end
        end
    elseif WinBattle then
        WinBattle.Active(true)
        WinBattle.RefreshInfo()
    end

    coroutine.step()
    coroutine.step()
    WidgetEffect.Elimination(utx, 16, 9, 0, true, 0.7, -1)
    coroutine.wait(1.2)

    if not ed and WinBattle then WinBattle.BeginTiming() end
    -- 卸载动画资源
    FillScreen.ReleaseScrennTexture(utx)
    Destroy(go)
end

local function ShowSkillT2(e2, e3, iso)
    coroutine.wait(0.3)
    e3:SetActive(true)
    local tmp = e2:GetCmpsInChilds(typeof(UE.ParticleSystem))
    for i = 0, tmp.length - 1 do tmp[i]:Stop() end
    tmp = e2:GetCmpsInChilds(typeof(UIParticle))
    for i = 0, tmp.length - 1 do tmp[i]:Stop() end
    coroutine.wait(0.1)
    if iso then _ctlr.AtkSktBuf:SetEnable(true)
    else _ctlr.DefSktBuf:SetEnable(true) end
end

local function OnFightEnd(res)
    if res ~= 0 then
        timeLine.End(function (pass)
            if pass then coroutine.start(ShowResult, res)
            elseif timeLine.isNetErr() then
                coroutine.start(ShowResult, 0)
                MsgBox.Show(L("非常抱歉，网络连接发生错误!"))
            else
                _data.battle.cheat = _data.battle.cheat + 1
                if _data.battle.type.value == 6 then --[[ Boss战清除伤害 ]] end
                SVR.BattleResult(0, _data.battle)
                coroutine.start(ShowResult, 0)
if isDebug then
                MsgBox.Show(L("检测到异常，本次战斗无效!\n")..timeLine.output())
else
                MsgBox.Show(L("检测到异常，本次战斗无效!"))
end
            end
        end)
    end
end

local function OnBegin()
    -- 加载武将名称
    local dat = _data.battle
    local odb = DB.GetHero(_data.atkHero.dat.dbsn.value)
    _map.atkHero.labName.text = odb:GetEvoName(_data.atkHero.dat.evo.value)
    local edb = DB.GetHero(_data.defHero.dat.dbsn.value)
    _map.defHero.labName.text = dat.type.value == 6 and edb.nm..L("·魂") or edb:GetEvoName(_data.defHero.dat.evo.value)
    -- 创建动画面板
    local go = Tools.CreatAnimPanel(SceneGame.body.gameObject, 110, true)
    -- 创建屏幕纹理
    local left = go:AddChild(_left, "left"):GetCmp(typeof(UIMeshTexture))
    local right = go:AddChild(_right, "right"):GetCmp(typeof(UIMeshTexture))
    FillScreen.CaptureScrennTexture(left, Camera.main, false)
    FillScreen.CaptureScrennTexture(right, Camera.main, false)

--    left.uvRect = new Rect(0, 0, 1, 1);
--    right.uvRect = new Rect(0, 0, 1, 1);
--    //水平
--    if (FillScreen.Place == FillScreen.FillPlace.Horizontal)
--    {
--        left.width = (int)(Screen.width / FillScreen.Zoom);
--        right.width = (int)(Screen.width / FillScreen.Zoom);
--    }
--    //垂直
--    else if (FillScreen.Place == FillScreen.FillPlace.Vertical)
--    {
--        left.height = (int)(Screen.height / FillScreen.Zoom);
--        right.height = (int)(Screen.height / FillScreen.Zoom);
--    }

    coroutine.step()
    _body.gameObject:SetActive(true) -- 激活战场
    coroutine.step()
    -- 隐藏主界面UI和地图
    if SceneGame ~= nil then SceneGame.HideMainUIAndMap() end
    -- 镜头跟随我方武将
    _map:ViewMoveToBU(_map.atkHero)
    coroutine.step()
    coroutine.step()

    if WinBattle ~= nil then WinBattle.Active(false) end
    if WinDaily ~= nil and WinDaily.body ~= nil then WinDaily.body:SetActive(false) end
    -- 移开左右屏
    EF.MoveTo(left, "x", -600, "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInExpo)
    EF.MoveTo(right, "x", 600, "time", 0.3, "islocal", true, "easetype", iTween.EaseType.easeInExpo)

    _plot.Init(odb, edb)
    -- 加载技能特效
    _map:LoadSkillRes()
    coroutine.wait(0.6)
    -- 删除动画面板
    FillScreen.ReleaseScrennTexture(right)
    Destroy(go)

    if Tutorial then Tutorial.Active = false end
    -- 等待对话结束
    local cor = coroutine.start(_plot.OnShow)
    local stat = coroutine.status(cor)
    while stat ~= "dead" do
        stat = coroutine.status(cor)
        coroutine.step()
    end

    -- 演示军师技及其他
    if dat.type.value > 0 then
        local ef1 = nil
        local ef2 = nil
        local ef3 = nil
        local rq = _ctlr.body:GetCmp(typeof(UIPanel)).startingRenderQueue + 10
        local h = nil
        local skt = nil
        local skp = nil
        local labs = nil
        local e1 = nil
        local e2 = nil
        local e3 = nil
        go = _map.body.gameObject
        for i = 1, 2 do
            h = i == 1 and _map.defHero or _map.atkHero
            skt = DB.GetSkt(h.dat.SktSN)
            skp = DB.GetSkp(h.dat.SkpSN)
            if skt.sn > 0 and skt.nm ~= nil and skt.nm ~= nil then
                if ef1 == nil then ef1 = AM.LoadPrefab("ef_skill_word") end
                if ef2 == nil then ef2 = AM.LoadPrefab("ef_holy_missile") end
                if ef3 == nil then ef3 = AM.LoadPrefab("ef_hit_flash") end
                e1 = go:AddChild(ef1, "ef_skill_word")
                e1:SetActive(false)
                e2 = go:AddChild(ef2, "ef_holy_missile")
                e2:SetActive(false)
                e3 = go:AddChild(ef3, "ef_hit_flash")
                e3:SetActive(false)
                Destroy(e1, 2.6)
                Destroy(e2, 2.6)
                Destroy(e3, 2.6)

                labs = e1:GetCmpsInChilds(typeof(UILabel))
                for i = 0, labs.length - 1 do labs[i].text = L("军师技·")..skt.nm..(skp.sn > 0 and L("\n锦囊技·")..skp.nm or "") end

                skt = h.go.transform.localPosition + Vector3(0, 120, 0)
                e1.transform.localPosition = skt
                e2.transform.localPosition = skt
                e3.transform.position = h.dat.isAtk and _ctlr.AtkSktBuf.transform.position or _ctlr.DefSktBuf.transform.position

                coroutine.step()
                coroutine.step()
                _map:ViewMoveToBU(h)
                coroutine.wait(0.2)
                e1:SetActive(true)
                coroutine.wait(0.5)
                EF.Scale(e1, 0.2, Vector3.zero).ignoreTimeScale = false
                e2.transform.parent = _ctlr.body.transform
                e2:SetActive(true)
                coroutine.wait(0.2)
                EF.MoveTo(e2, "position", e3.transform.position, "time", 0.3)
                coroutine.start(ShowSkillT2, e2, e3, h.dat.isAtk)
            end
        end
        coroutine.start(_ctlr.ShowBuffEffect, _ctlr)
    end
    -- 战斗开始
    if _data ~= nil then
        -- 若自动战斗则激活我方AI
        if _auto or dat:isAutoFight() then _data:ActivateAI(true) end
        -- 激活敌方AI
        _data:ActivateAI(false, ((dat.type.value == 1 and dat.sn <= 16) or dat.type.value == 8) and false or _data:RandomInt(0, 100) < 30, dat.type.value ~= 1 or dat.sn > 3)
        -- 激活战场
        _map:StartBattle(OnFightEnd)
        -- 读取加速设置
        _ctlr.Accelerate = user.IsBattleAccelerate
        -- 配置战斗特殊设置
        -- 第4关自动攻击
        if dat.type.value == 1 and dat.sn == 4 then _data:SetAtkArmCmd(QYBattle.BAT_CMD.Attack) end
    else
         if user.gmMaxCity < CONFIG.T_LEVEL then Tutorial.Active = true end
         if WinBattle ~= nil then
            WinBattle.Active(true)
            WinBattle.RefreshInfo()
        else
            if SceneGame ~= nil then SceneGame.ShowMainUIAndMap() end
         end
         _body:Exit()
         return
    end
--    if dat.type.value == 1 and ((user.gmMaxCity == 1 and dat.sn == 2) or user.gmMaxCity == 2 and dat.sn == 3) then
--        _map.view.defaultUnit = CS.ToEnum(1, typeof(MapView.UnitType))
--    else _map.view.defaultUnit = CS.ToEnum(0, typeof(MapView.UnitType))
--    end
    _map:ViewStopFollow()
    _map:ViewFollow(_map.atkHero.trans)

    coroutine.wait(0.5)
--    _ctlr:CheckUnLock()
end



function bat.OnLoad(c)
    if not Scene.CurrentIs(SCENE.GAME) then Scene.Load(SCENE.GAME) end
    _body = c
    _ref = _body.nsrf.ref
    c.lifeTime = 70

    c:BindFunction("OnInit", "OnDispose", "OnUnLoad")

    _left = _ref.screen_left
    _right = _ref.screen_right
    _bg_a = _ref.mapBgA
    _bg_b = _ref.mapBgB
    _bg_c = _ref.mapBgC
    _ownSk = _ref.ownSkillShow
    _enemySk = _ref.enemySkillShow

    local lt = BU_Control()
    _ref.control.luaTable = lt
    _ctlr = lt
    lt = BU_Map()
    _ref.map.luaTable = lt
    _map = lt
    _ref.plot.luaTable = FightPlotDialogue
    _plot = _ref.plot.luaTable

    _mapsn = 1
end
--[Comment]
-- 是否在战斗中(function)
bat.CheckIsBegin = CheckIsBegin
--[Comment]
-- 开始执行战斗
-- [ dat : BD_Filed ]
function bat.OnInit()
    dat = BattleManager.initObj
    if dat == nil or dat.isBattleEnd or (_data ~= nil and _map.Active and not _data.isBattleEnd) then return end
    -- 初始化
    _body.gameObject:SetActive(false)
    UpdateBeat:AddListener(_update)
    _data = dat
    _data.debug = true
    -- 反加速
    dat = dat.battle
    timeLine.Begin(dat.type.value == 0 or (dat.type.value == 1 and user.gmMaxCity < CONFIG.T_LEVEL))
    -- 加载战场视图
    _map:Init(_data)
    -- 初始化操作控件
    _ctlr:Init()
    -- 加载地图纹理
    local mapsn = 1
    mapsn = QYBattle.B_Math.random(1, 4)

if isDebug then
    mapsn = _mapsn
end
    _bg_a.spriteName = "bg_a_"..mapsn
    _bg_b.spriteName = "bg_b_"..mapsn
    _bg_c.spriteName = "bg_c_"..mapsn

    if mapsn == 1 then
        _bg_a.transform.localPosition = Vector2(_bg_a.transform.localPosition.x, 233)
        _bg_b.transform.localPosition = Vector2(_bg_b.transform.localPosition.x, 373)
        _bg_c.transform.localPosition = Vector2(_bg_c.transform.localPosition.x, 97)
    elseif mapsn == 2 then
        _bg_a.transform.localPosition = Vector2(_bg_a.transform.localPosition.x, 233)
        _bg_b.transform.localPosition = Vector2(_bg_b.transform.localPosition.x, 314)
        _bg_c.transform.localPosition = Vector2(_bg_c.transform.localPosition.x, 97)
    elseif mapsn == 3 then
        _bg_a.transform.localPosition = Vector2(_bg_a.transform.localPosition.x, 233)
        _bg_b.transform.localPosition = Vector2(_bg_b.transform.localPosition.x, 297)
        _bg_c.transform.localPosition = Vector2(_bg_c.transform.localPosition.x, 97) 
    end

    _bg_b:MakePixelPerfect()

    -- 协同开始战斗
    coroutine.start(OnBegin)

    _isBegin = true
end

function bat.OnDispose()
    Dispose()
    _isBegin = false
end

--[Comment]
-- param[dat] : BD_Hero
-- param[sn] : skillSN
function bat.OnCastSkill(dat, sn)
    if dat == nil or sn <= 0 then return end
    if dat.isAtk == _map.own then _map:ViewMoveToBD(dat)
    else _ctlr:ShowEnemyView() end
    sn = DB.GetSkc(sn).nm
    if dat.isAtk == _map.own then EF.ShowSkill(_ownSk, sn)
    else EF.ShowSkill(_enemySk, sn)
    end
end

BU_Map.OnCastSkill = bat.OnCastSkill

function bat.ShowTutorialCaptive(f)
    if user.battleRet.captive and #user.battleRet.captive > 0 then
        SVR.SiegeCaptive(user.battleRet.sn, "conv", user.battleRet.captive[1], function (r)
            if r.success then
                local res = SVR.datCache
                if res.csn > 0 and res.dbsn > 0 then
                    res = DB.GetHero(res.dbsn)
                    if f ~= nil then
                        local cb = nil
                        cb = function ()
                            f()
                            NewEffect.RemoveOnFinished(cb)
                        end
                        NewEffect.AddOnFinished(cb)
                    end
                    if user.battleRet.kind == 0 then
                        --[[ PlotDialogue.TutorialPlot(L("关羽,15:张梁，主公仁慈，饶你不死，你是否愿意为主效劳？|")..res.nm..","..res.sn..L(":谢主公饶命，吾愿效犬马之劳，请问主公大名！"), fucntion ()
                            NewEffect.ShowNewHero(res)
                        end) ]]
                    else NewEffect.ShowNewHero(res)
                    end
                    return
                end
            end
            if user.battleRet.sn == 2 and user.gmMaxCity == 2 then
                ToolTip.ShowPopTip(ColorStyle.Warning(L("网络数据异常")))
                Scene.Load(SCENE.GAME)
            elseif f ~= nil then f()
            end
        end)
    elseif f ~= nil then f()
    end
end

function bat.BattleEndEvent()
    if user.battleRet.kind == 0 and user.heroQty == 0 then
        if MapMain and MapMain.body then
            local cos = MapMain.body:GetCmpsInChilds(typeof(UE.Collider))
            for i = 0, cos.length - 1 do cos[i].enabled = false end
        end
        bat.ShowTutorialCaptive(function ()
            if user.heroQty > 0 then Scene.Load(user.role > 0 and SCENE.LOGIN or SCENE.NOVICE)
            else
                ToolTip.ShowPopTip(ColorStyle.Warning(L("网络数据异常")))
                Scene.Load(SCENE.LOGIN)
            end
        end)
    elseif user.battleRet.ret == 1 then
        if user.battleRet.kind == 1 then
            -- 酒馆解锁 去酒馆
            if user.battleRet.sn == 2 and user.gmMaxCity == 2 then
                bat.ShowTutorialCaptive(function ()
                    local ul = UnLockEffect.BeginBuilding(UnLockEffect.sample.tavern, L("酒馆已开启"), L("酒馆中可招募极品武将"))
                    ul:SetNext(UnLockEffect.sample.dev, L("下一关解锁:")..ColorStyle.Blue(L("开发")))
                    ul:SetOnFinished(function ()
                        user.TutorialSN = 1
                        user.TutorialStep = 7
                        MainUI.CheckTutorial()
                    end)
                end)
            -- 开发解锁 搜索宝箱
            elseif user.battleRet.sn == 3 and user.gmMaxCity == 3 then
                bat.ShowTutorialCaptive(function ()
                    local ul = UnLockEffect.BeginBuilding(UnLockEffect.sample.dev, L("开发已解锁"), L("升城池 收银币 搜装备"))
                    ul:SetNext(UnLockEffect.sample.smithy, L("下一关解锁:")..ColorStyle.Blue(L("铁匠铺")))
                    ul:SetOnFinished(function ()
                        user.TutorialSN = 1
                        user.TutorialStep = 14
                        if MapLevel then MapLevel.CheckTutorial() else Win.Open("MapLevel") end
                    end)
                end)
            -- 铁匠铺解锁 搜索宝箱
            elseif user.battleRet.sn == 4 and user.gmMaxCity == 4 then
                bat.ShowTutorialCaptive(function ()
                    local ul = UnLockEffect.BeginBuilding(UnLockEffect.sample.smithy, L("铁匠铺已开启"), L("强化装备提升战力"))
                    ul:SetNext(UnLockEffect.sample.hospital, L("攻陷")..DB.GetGmCity(5).nm..L("解锁:")..ColorStyle.Blue(L("医馆")))
                    ul:SetOnFinished(function ()
                        user.TutorialSN = 1
                        user.TutorialStep = 25
                        MainUI.CheckTutorial()
                    end)
                end)
            -- 给武将吃经验丹和属性药剂
            elseif user.battleRet.sn == 5 and user.gmMaxCity == 5 then
                bat.ShowTutorialCaptive(function ()
                    user.TutorialSN = 1
                    user.TutorialStep = 32
                    MainUI.CheckTutorial()
                end)
            -- 医馆解锁 补血
            elseif user.battleRet.sn == 6 and user.gmMaxCity == 6 then
                bat.ShowTutorialCaptive(function ()
                    local ul = UnLockEffect.BeginBuilding(UnLockEffect.sample.hospital, L("医馆已开启"), L("补充武将生命值"))
                    ul:SetNext(UnLockEffect.sample.ass, L("下一关解锁:")..ColorStyle.Blue(L("小助手")))
                    ul:SetOnFinished(function ()
                        user.TutorialSN = 1
                        user.TutorialStep = 36
                        MainUI.CheckTutorial()
                    end)
                end)
            -- 小助手解锁
            elseif user.battleRet.sn == 7 and user.gmMaxCity == 7 then
                bat.ShowTutorialCaptive(function ()
                    local ul = UnLockEffect.BeginBuilding(UnLockEffect.sample.ass, L("小助手已解锁"), L("跟着小助手走升级快"))
                    ul:SetNext(UnLockEffect.sample.seven, L("下一关解锁:")..ColorStyle.Blue(L("7日签到")))
                    ul:SetOnFinished(function ()
                        user.TutorialSN = 1
                        user.TutorialStep = 39
                        MainUI.CheckTutorial()
                    end)
                end)
            -- 7天登录解锁
            elseif user.battleRet.sn == 8 and user.gmMaxCity == 8 then
                if user.gmMaxLv <= user.gmLv then user.gmMaxLv = user.gmLv + 1 end
                AM.LoadAssetAsync(ResName.MapLevel(user.gmMaxLv), true)
                bat.ShowTutorialCaptive(function ()
                    local ul = UnLockEffect.BeginBuilding(UnLockEffect.sample.seven, L("7日签到已解锁"), L("开服7天豪礼天天送"))
                    ul:SetNext(UnLockEffect.sample.home, L("下一关解锁:")..ColorStyle.Blue(L("7主城")))
                    ul:SetOnFinished(function ()
                        user.TutorialSN = 1
                        user.TutorialStep = 42
                        MainUI.CheckTutorial()
                    end)
                end)
            -- 升级主城
            elseif user.battleRet.sn == 9 and user.gmMaxCity == 9 then
                bat.ShowTutorialCaptive(function ()
                    local ul = UnLockEffect.BeginBuilding(UnLockEffect.sample.home, L("主城已开启"), L("升级主城提升整体实力"))
                    ul:SetNext(UnLockEffect.sample.fb, L("攻陷")..DB.GetGmCity(DB.unlock.gmFB).nm..L("解锁:")..ColorStyle.Blue(L("副本")))
                    ul:SetOnFinished(function ()
                        user.TutorialSN = 1
                        user.TutorialStep = 49
                        if MapMain and MapMain.body and MapMain.body then MapMain.CheckTutorial()
                        else Win.Open("MapMain") end
                    end)
                end)
            elseif user.battleRet.sn == 10 and user.gmMaxCity == 10 then
                user.TutorialSN = 1
                user.TutorialStep = 58
                --[[ Tutorial.PlayTutorial(false, { }) ]]
            else
                local cts = DB.GetGmLv(user.gmLv).cities
                table.sort(cts)
                if user.gmMaxCity == cts[#cts] then
                    --[[ PlotDialogue.LevelPlot(user.gmLv) ]]
                    if user.gmMaxLv <= user.gmLv then user.gmMaxLv = user.gmLv + 1 end
                    if user.gmLv > 1 then Win.Open("MapMain") end
                end
            end
        end
    else
        if user.battleRet.kind == 1 then
            local gmCity = user.gmMaxCity
            if gmCity == 1 then
                user.TutorialSN, user.TutorialStep = 1, 2
            elseif gmCity == 2 then
                user.TutorialSN, user.TutorialStep = 1, 11
            elseif gmCity == 3 then
                user.TutorialSN, user.TutorialStep = 1, 22
            elseif gmCity == 4 then
                user.TutorialSN, user.TutorialStep = 1, 30
            elseif gmCity == 5 then
                user.TutorialSN, user.TutorialStep = 1, 34
            elseif gmCity == 6 then
                user.TutorialSN, user.TutorialStep = 1, 37
            elseif gmCity == 7 then
                user.TutorialSN, user.TutorialStep = 1, 39
            elseif gmCity == 8 then
                user.TutorialSN, user.TutorialStep = 1, 47
            elseif gmCity == 9 then
                user.TutorialSN, user.TutorialStep = 1, 54
            else
                gmCity = false
            end
            if gmCity then
                if MapLevel then MapLevel.CheckTutorial() else Win.Open("MapLevel") end
            end
        end
    end
    if user.gmMaxCity >= DB.unlock.loyalty and user.gmMaxCity < DB.unlock.loyalty + 5 then
        -- 启动新手教学 忠诚 篇
        if user.HasLowLoyatyHero and user.GetPropsQty(DB_Props.ZHU_BAO) > 0 then
            user.TutorialSN = 2
            user.TutorialStep = 1
            --[[ Tutorial.PlayTutorial(false, { }) ]]
        end
    end
end

function bat.OnUnLoad()
    Dispose()
    _body = nil
    _left = nil
    _right = nil
    _bg_a = nil
    _bg_b = nil
    _bg_c = nil
    _map = nil
    _ctlr = nil
    _plot = nil
    _ownSk = nil
    _enemySk = nil
    _mapsn = nil
end

BattleManager = bat