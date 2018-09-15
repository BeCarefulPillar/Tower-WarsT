SVR = {}

local FUNC_LOGIN = "up_py_logon"
local FUNC_REG = "up_py_reg"

local DIS_RSN = { None = 0, Kick = 1, Ban = 2, Manual = 3 }

--[Comment]
--服务器状态
local SVR_STATUS =
{
    --[Comment]
    --空闲
    Stop = 0,
    --[Comment]
    --准备连接
    ReadyToConnect = 1,
    --[Comment]
    --正在连接
    Connecting = 2,
    --[Comment]
    --连接失败
    ConnectFailed = 3,
    --[Comment]
    --正在登录(已连接)
    Login = 4,
    --[Comment]
    --登录成功
    Logined = 5,
    --[Comment]
    --登录失败
    LoginFailed = 6,
}

--Server实体
local _svr
--账密记录
local _acc, _pwd, _cid = nil, nil, nil
--服务器时间
local _svrTm = TimeClock(os.time(), true)

--[Comment]
--数据缓存
SVR.datCache = nil

--[Comment]
--取得SFS服务
function SVR.getSfsSvr() return _svr end
--扩展
_svrExt = require("Game/SvrExt")

--------------服务器配置加载部分--------------
--服务器列表
local _svrLst
--服务器SN索引表
local _svrSns
--当前使用的配置
local _curCfg
--最新配置
local _lastCfg
--服务器配置是否有效
local function CfgVaild(s)
    return s and s.sn and s.sn > 0 and s.port and s.port > 100 and s.host and s.zone and s.host ~= "" and s.zone ~= ""
end
--加载服务器配置列表
local function OnLoadConfig(lua)
    _svrLst = loadstring(lua or File.ReadCEText(AM.svrPath))()
    print("Load Server Config Max SN : ", table.maxn(_svrLst))
    local now = os.time()
    _svrSns = {}
    _lastCfg = nil
    for n, s in pairs(_svrLst) do
        if CfgVaild(s) then
            _svrSns[#_svrSns + 1] = n
            s.nm = s.nm or tostring(s.sn)
            if s.dt then s.dt = CS.Timestamp(s.dt) end
            --开服2天之内是新服，否则爆满
            if s.st ~= 3 then s.st = s.dt and now - s.dt <= 172800 and 1 or 2 end
            --是否可显示判断
            if not (s.dt and s.dt > (s.ad and now + s.ad or now)) then
                s.show = true
                --最新开服
                if (not _lastCfg or _lastCfg.sn < s.sn) and s.st ~= 3 then _lastCfg = s end
            end
        else
            _svrLst[n] = nil
        end
    end
    table.sort(_svrSns, function(a, b) return a < b end)
end
--网络协同加载服务器配置列表
local function CoLoadConfig()
    local stp = StatusBar.Show(ST_ID.LOAD_SVR_LST)
    local www = WWW(AM.svrUrl)
    coroutine.www(www)
    if www.error and www.error ~= "" then
        ToolTip.ShowPropTip(ColorStyle.Bad(L("获取服务器列表失败")));
        return
    end
    local dat = www.bytes
    OnLoadConfig(CS.UnCompressText(dat, EN_SKIP))
    File.WriteByte(AM.svrPath, dat)
end
--[Comment]
--加载服务器配置
function SVR.LoadConfig(net)
    if net then
        coroutine.start(CoLoadConfig)
    else
        OnLoadConfig()
    end
end
--[Comment]
--获取服务器配置(n为字符串表示服务器名称,未nil表示最新服务器配置)
function SVR.GetConfig(n)
    if n and _svrLst then
        if isString(n) then
            local cfg
            for i = 1, #_svrSns do
                cfg = _svrLst[_svrSns[i]]
                if cfg.nm == n then return cfg end
            end
        else
            return _svrLst[n]
        end
    else
        return _lastCfg
    end
end
--[Comment]
--服务器配置列表,SN索引表
function SVR.cfgLst()
    if _svrLst == nil or _svrSns == nil then
        SVR.LoadConfig()
        if _svrLst == nil or _svrSns == nil then SVR.LoadConfig(true) end
    end
    return _svrLst, _svrSns
end
--[Comment]
--当前服务器配置
function SVR.curCfg() return _curCfg end
--[Comment]
--当前服务器是否调试模式
function SVR.isDebug() return _curCfg and _curCfg.debug or isDebug end
--[Comment]
--给定服务器配置是否有效
SVR.CfgVaild = CfgVaild
--初始加载
OnLoadConfig()
----------------------------------------------

--[Comment]
--初始化服务器
function SVR.Init()
    if tolua.isnull(_svr) then
        _svr = GM.instance:AddCmp(typeof(Server))
        _svr:Load("SVR")
        --关联战斗运算
        BattleCalc.server = _svr
    end
end

--加载
function SVR.OnLoad(s)
    _svr = s
    _svr.funcRegister = FUNC_REG
    _svr.funcLogin = FUNC_LOGIN

    s:BindFunction("OnError")
    s:BindFunction("OnDisconnect")
    s:BindFunction("OnLogin")
    s:BindFunction("OnLogout")
    s:BindFunction("OnGameEvent")

    --服务接口
    require("Game/SvrI")
end

--[Comment]
--配置服务器
function SVR.Config(s)
    if _svr and CfgVaild(s) then
        _curCfg = s
        _svr:Configure(s.host, s.port, s.zone, s.cp or 0, s.ec == 1, isDebug)
    end
end

--异常
function SVR.OnError(c, s)
    print("err:",c,"msg:",s)
    if c == ERR.Login then
        _acc, _pwd, _cid = nil, nil, nil
        StatusBar.Exit(ST_ID.LOGIN)
        MsgBox.Show(s or L("登录失败"))
    elseif c == ERR.Connect then
        StatusBar.Exit(ST_ID.CONNECT)
        MsgBox.Show(s or L("连接失败"))
    elseif s then
        if c == ERR.LackProps then 
            local idx = string.find(s, "|")
            s = string.sub(s, idx+1)
        end
        MsgBox.Show(s)
    end
end
--玩家掉线事件
function SVR.OnDisconnect(r)
    if DIS_RSN.Kick == r then
        --被踢
        MsgBox.Show(L("您的账号已在别处登录！"));
        Scene.Load(SCENE.LOGIN);
    elseif DIS_RSN.Ban == r then
        --被禁
        MsgBox.Show(L("您的账号已在别处登录！"));
        Scene.Load(SCENE.LOGIN);
    elseif DIS_RSN.Manual == r then
        return
    elseif Scene.CurrentIs(SCENE.LOGIN) or Scene.CurrentIs(SCENE.ENTRY) then
        return
    end
--    _svr:Startup()
end
--获取登录信息
local function CoLogin()
    local stp = StatusBar.ShowR("", 15, false)
    coroutine.wait(0.5)
    local opt = 0
    local time, to = Time, TIMEOUT
    local tm = time.realtimeSinceStartup + to
    local cb = function(t)
        if t.success then
            opt = 1
        else
            opt = -1
            MsgBox.Show(L("登录异常,请稍后重试"))
        end
    end

    --用户扩展信息
    _svr:Function(Func.UpdateUserInfo, user.psn..",''", cb)
    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN); return end
    --同步武将数据
    opt, tm = 0, time.realtimeSinceStartup + to
    _svr:Function(Func.SyncHero, user.psn..",0", cb)
    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN);return end
    --同步装备数据
    opt, tm = 0, time.realtimeSinceStartup + to
    _svr:Function(Func.SyncEquip, user.psn..",0", cb)
    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN);return end
    --同步副将数据
--    opt, tm = 0, time.realtimeSinceStartup + to
--    _svr:Function(Func.SyncDehero, user.psn, cb)
--    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
--    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN);return end
    --同步军备
--    opt, tm = 0, time.realtimeSinceStartup + to
--    _svr:Function(Func.SyncDequip, user.psn, cb)
--    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
--    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN);return end
    --同步道具
    opt, tm = 0, time.realtimeSinceStartup + to
    _svr:Function(Func.SyncProps, user.psn, cb)
    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN);return end
    --同步将魂
    opt, tm = 0, time.realtimeSinceStartup + to
    _svr:Function(Func.SyncHeroSoul, user.psn, cb)
    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN);return end
    --同步宝石
    opt, tm = 0, time.realtimeSinceStartup + to
    _svr:Function(Func.SyncGem, user.psn, cb)
    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN);return end
    --同步军备残片
--    opt, tm = 0, time.realtimeSinceStartup + to
--    _svr:Function(Func.SyncDequipSp, user.psn, cb)
--    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
--    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN);return end
    --同步地图信息
    opt, tm = 0, time.realtimeSinceStartup + to
    user.ClearPveCity()
    user.ClearPvpCity()
    _svr:Function(Func.GetLevelMap, user.psn..",0", cb)
    while opt == 0 and tm > time.realtimeSinceStartup do coroutine.step() end
    if opt ~= 1 then stp:Done();Scene.Load(SCENE.LOGIN);return end

    --同步数据完成
    stp:Done()
--Analytics.Event(UMEvent.GameLine, "4_GameBegin");
--Analytics.StartLevel(User.NextCity.ToString());
--TdAnalytics.OnEvent(TDEvent.GameLine, "4_GameBegin", "4_GameBegin");
--TdAnalytics.OnMission(TdAnalytics.MissionState.Begin, User.NextCity.ToString());
    --获取酒馆信息，用于小助手
    _svr:Function(Func.TavernInfo, user.psn)
    --铜雀台数据
--    _svr:Function(Func.Beauty, user.psn..",'inf'")
    --过关斩将
    if user.hlv >= DB.unlock.tower then _svr:Function(Func.TowerOption, user.psn..",'inf'") end
    --加载用户存档
    user.LoadSave()
    --场景切换
    Scene.Load(user.heroQty > 0 and user.gmMaxCity == 1 and user.role == 0 and SCENE.NOVICE or SCENE.GAME)
end
--玩家登录成功事件
function SVR.OnLogin(dat)
    StatusBar.Exit(ST_ID.LOGIN)
    local func = dat:GetUtfString("func")
    dat = _svr.GetJsonDat(dat)

    print("<-  func:"..func.."  dat:"..dat)

    local psn = user.psn

    user.Init(kjson.ldec(dat, stab.UserInfo))

--    if psn == user.psn then return end

    _acc = _acc or user.nick

--    if _svr.loginData == nil then
--        _svr:Login(string.format("%d,'%s','%s',%d,'%s',%d,'{ip}','%s','%s'", _curCfg.sn, acc, pwd, cid, acc, 0, ENV.DeviceInfo, ENV.DeviceId))
--    end

    --SDK.SendExtendData()

    if SceneLogin then SceneLogin.AddRec(_acc, _pwd, _cid, _curCfg.sn) end
    _acc, _pwd, _cid = nil, nil, nil

    SVR.GetColdTime()

    coroutine.start(CoLogin)

--    user.CheckVerifyLogin()
end
--玩家登出事件
function SVR.OnLogout()
    Scene.Load(SCENE.LOGIN)
end
--玩家登录成功事件
function SVR.OnGameEvent(ret, fn, dat, sfs)
    fn = _svrExt[fn]
    SVR.datCache = fn and fn(ret, dat, sfs)
end

--------------通用接口--------------
--[Comment]
--账号密码登录
function SVR.Register(acc, pwd, cid)
    if _svr and _curCfg then
        if _svr.isStop then _svr:Startup() end
        StatusBar.Show(ST_ID.LOGIN, "", 10, false)
        cid = cid or DEF_CID
        if acc then
            _svr:Register(FUNC_REG, string.format("%d,'%s','%s',%d,'',0,'{ip}','%s','%s',''", _curCfg.sn, acc, pwd, cid, ENV.DeviceInfo, ENV.DeviceId))
        else
            if pwd == nil or pwd == "" then
                local src = "01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                local len = string.len(src)
                pwd = {}
                for i = 1, 16 do
                    table.insert(pwd, string.byte(src, math.random(len)))
                end
                pwd = string.sub(CS.MD5(table.concat(pwd)), 11, 25)
            end
            _svr:Register(FUNC_REG, string.format("%d,'','%s',%d,'',0,'{ip}','%s','%s','taste'", _curCfg.sn, pwd, cid, ENV.DeviceInfo, ENV.DeviceId))
        end
        _acc, _pwd, _cid = acc, pwd, cid
    end
end
--[Comment]
--账号密码登录
function SVR.Login(acc, pwd, cid)
    if _svr and acc and pwd and _curCfg then
        if _svr.isStop then _svr:Startup() end
        cid = cid or DEF_CID
        _acc, _pwd, _cid = acc, pwd, cid
        _svr:Login(string.format("%d,'%s','%s',%d,'%s',%d,'{ip}','%s','%s'", _curCfg.sn, acc, pwd, cid, "", 0, ENV.DeviceInfo, ENV.DeviceId))
        if _svr.status == SVR_STATUS.Logined then coroutine.start(CoLogin) else StatusBar.Show(ST_ID.LOGIN, "", 10, false) end
    end
end
--[Comment]
--SDK登录
function SVR.SdkLogin(cid, uid, age)
    if _svr and uid and _curCfg then
        if _svr.isStop then _svr:Startup() end
        cid = cid or DEF_CID
        _acc, _pwd, _cid = uid, nil, cid
        _svr:Login(string.format("%d,'%s','%s',%d,'%s',%d,'{ip}','%s','%s'", _curCfg.sn, uid, "", cid, uid, age or 0, ENV.DeviceInfo, ENV.DeviceId))
        if _svr.status == SVR_STATUS.Logined then coroutine.start(CoLogin) else StatusBar.Show(ST_ID.LOGIN, "", 10, false) end
    end
end

--登出
function SVR.LogOut()
    if _svr then
        _svr:Logout()
    end
end

--[Comment]
--发送一个命令
function SVR.SendFuncMini(f) _svr:Function(f, user.psn) end
--[Comment]
--发送一个命令并侦听回调
function SVR.SendFuncBrief(f, cb) _svr:Function(f, user.psn, cb) end
--[Comment]
--发送一个带有参数的命令并侦听回调
function SVR.SendFunc(f, arg, cb) _svr:Function(f, user.psn..","..tostring(arg), cb) end
--[Comment]
--服务器当前时间（秒）
function SVR.SvrTime() return _svrTm.time end
--[Comment]
--设置服务器当前时间（秒）
function SVR.SetSvrTime(tm) if tm and tm > 0 then _svrTm.time = tm end end
------------------------------------
