SceneLogin = { }

local _body

--登陆页
local _login
--注册页
local _reg
--服务器列表页
local _svr

--当前服务器
local _curSvr
local _curSvrLbl
--最近登陆
local _lastSvr
--开始游戏按钮
local _btnStart
--SDK登陆的提示
local _tip

--UIInput 登陆
local _iptAccL
local _iptPwdL
--UIInput 注册
local _iptAccR
local _iptPwdR

--当前正在播放的动画
local _curAni
local _aniLgn
local _aniReg
local _aniSvr

--当前服务器配置
local _svrCfg
--服务器列表
local _svrLst
--服务器sn索引
local _svrSns
--服务器Tab列表的UIWrapGrid
local _svrTabGrid
--服务器列表的UIWrapGrid
local _svrlstGrid

--用户记录
local _usr
local _usrPath = AM.rootPath .. "/usr"

function SceneLogin.OnLoad(c)
    _body = c

    c:BindFunction("OnUnLoad")
    c:BindFunction("Start")
    c:BindFunction("ClickBg")
    c:BindFunction("ClickCurSvr")
    c:BindFunction("ClickStart")
    c:BindFunction("ClickQuick")
    c:BindFunction("ClickReg")
    c:BindFunction("ClickToReg")
    c:BindFunction("ClickLogin")
    c:BindFunction("ClickSvrTab")
    c:BindFunction("ClickSvr")
    c:BindFunction("ClickMySvrTab")
    c:BindFunction("ClickMySvr")
    c:BindFunction("ClickReturnToLogin")
    c:BindFunction("OnWrapGridInitItem")

    local tmp = c.gos
    _login = tmp[0]
    _curSvr = tmp[1]
    _btnStart = tmp[2]
    _reg = tmp[3]
    _svr = tmp[4]
    _tip = tmp[5]

    _curSvrLbl = _curSvr:ChildWidget("cur_svr")
    
    _mySvrTab = _svr:ChildWidget("btn_myServers")

    local t = typeof(UIWrapGrid)
    _svrTabGrid = _svr:Child("servers", t)
    _svrlstGrid = _svr:Child("list", t)
    _svrRecGrid = _svr:Child("myservers", t)

    tmp = typeof(UnityEngine.Animation)
    _aniLgn = _login:GetCmp(tmp)
    _aniReg = _reg:GetCmp(tmp)
    _aniSvr = _svr:GetCmp(tmp)
end

local function Md5Pwd(pwd) return string.sub(CS.MD5(pwd), 11, 25) end

--------------用户记录部分--------------
-- 保存用户记录
local function SaveUserRec()
    if _usr then File.WriteCETextCRC(_usrPath, json.encode(_usr)) end
end
-- 添加用户记录
local function AddToUserRec(ur)
    if _usr == nil then _usr = {} end
    if ur then
        local c, svr, id = ur[1], ur[2], ur[3]
        if c and svr and id then
            local u
            for i = 1, #_usr do
                u = _usr[i]
                if c == u[1] and svr == u[2] and id == u[3] then return end
            end
            table.insert(_usr, ur)
        end
    end
end
-- 加载用户记录
local lgrec = { }
local function LoadUserRec()
    local files = File.DirFiles(_usrPath)
    for i=0, files.length - 1 do
        local js = File.ReadCETextCRC(files[i])
        if js then _usr = json.decode(js) end
        lgrec[i + 1] = _usr
    end
    

--    -- 合并老版数据
--    js = GM.GetOldUserRec(AM.rootPath.."ur2")
--    if js then
--        js = json.decode(js)
--        if js then
--            for i = 1, #js do
--                AddToUserRec(js[i])
--            end
--            SaveUserRec()
--        end
--        File.Delete(AM.rootPath.."ur2")
--    end
end
--[Comment]
--增加记录
function SceneLogin.AddRec(acc, pwd, cid, svr)
    if acc and svr and cid then
        if pwd then
            cfg.acc = acc
            cfg.pwd = pwd
            CfgSave()
        end

        AddToUserRec({cid,svr,acc})

        SaveUserRec()
    end
end
--[Comment]
--改名记录ID
function SceneLogin.ChangeAcc(last)
    if last and user and user.nick and user.rsn and SDK.cid == DEF_CID then
        if cfg.acc == last then
            cfg.acc = user.nick
            CfgSave()
        end
        if _usr then
            local u, c, svr = nil, DEF_CID, user.rsn
            for i = 1, #_usr do
                u = _usr[i]
                if c == u[1] and svr == u[2] and last == u[3] then
                    u[3] = user.nick
                    SaveUserRec()
                    return
                end
            end
        end
    end
end
----------------------------------------

--将服务器信息配置到UILabel
local function ApplyServerToLabel(lbl, s)
    local sp = lbl.gameObject:ChildWidget("status_svr", typeof(UISprite))
    if s then
        if s.st == 1 then
            lbl.text = s.nm.."["..L("新服").."]"
            sp.spriteName = "sp_status_3"
            lbl.color = Color.green
        elseif s.st == 2 then
            lbl.text = s.nm.."["..L("爆满").."]"
            sp.spriteName = "sp_status_2"
            lbl.color = Color.white
        elseif s.st == 3 then
            lbl.text = s.nm.."["..L("维护").."]"
            sp.spriteName = ""
            lbl.color = Color.grey
        else
            lbl.text = s.nm
            sp.spriteName = "sp_status_1"
            lbl.color = Color.white
        end
    else
        lbl.text = ""
        lbl.color = Color.white;
    end
end
-- 配置服务器列表
local function ApplyLastServer()
    if _usr then
        local cid = SDK.cid
        local uid = SDK.IsLogin() and SDK.uuid or _iptAccL.value
        local u
        for i = 1, #_usr do
            u = _usr[i]
            if cid == u[1] and uid == u[3] then
                _svrCfg = SVR.GetConfig(u[2])
                break
            end
        end
    end

    if not SVR.CfgVaild(_svrCfg) then _svrCfg = SVR.GetConfig() end

    ApplyServerToLabel(_curSvrLbl, _svrCfg)
--    ApplyServerToLabel(_lastSvr, _svrCfg)

--    _lastSvr.luaBtn.param = _svrCfg.sn
end
-- SDK登录
local function OnSdkLogin()
    if SDK.IsLogin() then
        ToolTip.ShowGameTip(false)
        _btnStart:SetActive(true)
        _curSvr:SetActive(true)
        _tip:SetActive(false)
        _curSvr.transform.localY = -64

        ApplyLastServer()

        if _curAni then
            EF.PlayAni(_curAni, "LoginPanelOut", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DisableAfterForward)
            _curAni = nil
        end
    else
        _tip.SetActive(true)
        _btnStart.SetActive(false)
        _curSvr.SetActive(false)
    end
end
-- 转到登录页
local function ToLogin()
    if _curAni and _curAni ~= _aniLgn then
        EF.PlayAni(_curAni, "LoginPanelOut", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DisableAfterForward)
    end
    EF.PlayAni(_aniLgn, "LoginPanelIn", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DoNotDisable)
    _curAni = _aniLgn
    _iptAccL.value = nil
    _iptPwdL.value = nil
    if cfg.acc and cfg.acc ~= "" and cfg.pwd and cfg.pwd ~= "" then
        _iptAccL.value = cfg.acc
        _iptPwdL.value = cfg.pwd
--        _iptAccL.inputType = CS.ToEnum("Password", typeof("UIInput+InputType"))
    end
    _curSvr:SetActive(true)
--    _curSvr.transform.localY = -198
end
-- 转到注册页
local function ToRegister()
    if _curAni and _curAni ~= _aniReg then
        EF.PlayAni(_curAni, "LoginPanelOut", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DisableAfterForward)
    end
    EF.PlayAni(_aniReg, "LoginPanelIn", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DoNotDisable)
    _curAni = _aniReg
    _iptAccR.value = nil
    _iptPwdR.value = nil
    _curSvr:SetActive(true)
--    _curSvr.transform.localY = -157
end
-- 开始
function SceneLogin.Start()
    BGM.Play("bgm_login")

    LoadUserRec()

    SVR.Init()

    _svrLst, _svrSns = SVR.cfgLst()

    if SDK.IsLogin() then
        OnSdkLogin()
    elseif SDK.Login() then
        _tip:SetActive(true)
        ToolTip.ShowGameTip(true)
    else
        local t = typeof(UIInput)
        _iptAccL = _login:Child("Account", t)
        _iptPwdL = _login:Child("Password", t)
        _iptAccR = _reg:Child("Account", t)
        _iptPwdR = _reg:Child("Password", t)

        _tip:SetActive(false)
        ToLogin()
        ApplyLastServer()
    end

    _body.loadingProgress = 1
end

--------------服务器列表部分--------------
--服务器起始编号
local _svrIdx = 1
--每页显示的服务器数量
local _svrPage = 20
--左边Tab的缓存
local _svrTabs
--服务器列表的缓存
local _svrs
--我的服务器列表缓存
local _svrsRec
--每页的服务器显示起始编号
local sid
--每页的服务器显示结束编号
local eid

local function ToSvrLst()
    if _curAni ~= nil and _curAni ~= _aniSvr then
        EF.PlayAni(_curAni, "LoginPanelOut", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DisableAfterForward)
    end
    EF.PlayAni(_aniSvr, "LoginPanelIn", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DoNotDisable)
    _curAni = _aniSvr

    _svrTabGrid:Reset()
    _svrTabGrid.realCount = math.ceil(#_svrSns / _svrPage)
end

function SceneLogin.OnWrapGridInitItem(grid, item, index)
    if item and index + 1 > 0 and index < #_svrSns then
        if grid == _svrTabGrid then
            if _svrTabs == nil then _svrTabs = { } end

            local lbl = item:ChildWidget("lab_Servers")
            local slt = item:ChildWidget("select")
            local btn = item.luaBtn
            btn.param = index + 1
            local sidx = index == 0 and index + 1 or index * _svrPage + 1
            local eidx = (index + 1) * _svrPage < #_svrSns and (index + 1) * _svrPage or #_svrSns
            
            lbl.text = (sidx == eidx and eidx or sidx .. " - " .. eidx) .. "服"
            if tolua.isnull(item:GetCmp(typeof(UIDragScrollView))) then item:AddCmp(typeof(UIDragScrollView)) end
            _svrTabs[index + 1] = item
            if index == 0 then SceneLogin.ClickSvrTab(index + 1) end
        elseif grid == _svrlstGrid then
            if _svrs == nil then _svrs = { } end
            index = sid > _svrPage and (index + (math.ceil(sid / _svrPage) - 1) * _svrPage) or index
            local s = _svrLst[_svrSns[index + 1]]
            local lbl = item:GetCmp(typeof(UILabel))
            local sp = item:ChildWidget("sp_tuijie", typeof(UISprite))
            if s.st ~= 1 then sp.gameObject:SetActive(false) end
            ApplyServerToLabel(lbl, s)
            item.luaBtn.param = s
            if tolua.isnull(item:GetCmp(typeof(UIDragScrollView))) then item:AddCmp(typeof(UIDragScrollView)) end
            _svrs[index + 1] = item
        elseif grid == _svrRecGrid then
            if _svrsRec == nil then _svrsRec = { } end

            local ava = item:ChildWidget("avatar")
            local lv = item:ChildWidget("level")
            local nm = item:ChildWidget("name")
            local snm = item:ChildWidget("servername")
            local time = item:ChildWidget("latestlogintime")

            local rec = lgrec[index + 1]
            ava:LoadTexAsync(ResName.PlayerIcon(rec.ava))
            lv.text = rec.hlv
            nm.text = rec.nick
            snm.text = _svrLst[rec.rsn].nm
            time.text = "最近登在" .. math.ceil((os.time() - rec.lastQT) / 60) .. "分钟前"
            if tolua.isnull(item:GetCmp(typeof(UIDragScrollView))) then item:AddCmp(typeof(UIDragScrollView)) end
            item.luaBtn.param = rec
            _svrsRec[index + 1] = item
        end
        return true
    end
    return false
end

function SceneLogin.ClickSvr(s)
    if SVR.CfgVaild(s) then
        _svrCfg = s
        ApplyServerToLabel(_curSvrLbl, s)
        if SDK.IsLogin() then
            if _curAni then
                EF.PlayAni(_curAni, "LoginPanelOut", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DisableAfterForward)
                _curAni = nil
            end
        elseif _curAni ~= _aniLgn and _curAni ~= _aniReg then
            ToLogin()
        end
    end
end

function SceneLogin.ClickSvrTab(t)
    _svrlstGrid.gameObject:SetActive(true)
    _svrRecGrid.gameObject:SetActive(false)

    for i=1, table.maxn(_svrTabs) do
        local tab = _svrTabs[i]
        local slt = tab:ChildWidget("select")
        slt:SetActive(false)
    end
    _mySvrTab:ChildWidget("select"):SetActive(false)

    if t and t > 0 then 
        local tab = _svrTabs[t]
        local slt = tab:ChildWidget("select")
        slt:SetActive(true)
    end

    local index = _svrTabs[t].luaBtn.param - 1
    sid = index == 0 and index + 1 or index * _svrPage + 1
    eid = (index + 1) * _svrPage < #_svrSns and (index + 1) * _svrPage or #_svrSns

    _svrlstGrid:Reset()
    _svrlstGrid.realCount = sid == eid and 1 or eid - sid + 1
end

function SceneLogin.ClickMySvrTab()
    for i=1, table.maxn(_svrTabs) do
        local tab = _svrTabs[i]
        local slt = tab:ChildWidget("select")
        slt:SetActive(false)
    end
    _mySvrTab:ChildWidget("select"):SetActive(true)

    _svrlstGrid.gameObject:SetActive(false)
    _svrRecGrid.gameObject:SetActive(true)

    _svrRecGrid:Reset()
    _svrRecGrid.realCount = #lgrec
end

function SceneLogin.ClickMySvr(r)
    local rec = r
    local s = _svrLst[rec.rsn]

    if SVR.CfgVaild(s) then
        _svrCfg = s
        ApplyServerToLabel(_curSvrLbl, s)
        if SDK.IsLogin() then
            if _curAni then
                EF.PlayAni(_curAni, "LoginPanelOut", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DisableAfterForward)
                _curAni = nil
            end
        elseif _curAni ~= _aniLgn and _curAni ~= _aniReg then
            ToLogin()
            _iptAccL.value = rec.nick
            _iptPwdL.value = ""
        end
    end
end

function SceneLogin.ClickReturnToLogin()
    if _curAni ~= _aniLgn then ToLogin() end
end

--------------交互事件部分--------------
-- 点击背景层
function SceneLogin.ClickBg()
    if SDK.IsLogin() then if not _btnStart.activeSelf then OnSdkLogin() end elseif not SDK.Login() and _curAni ~= _aniLgn and _curAni == _aniReg then ToLogin() end
end
-- 点击登陆页-登录
function SceneLogin.ClickLogin()
    local acc = _iptAccL.value
    local pwd = _iptPwdL.value
    
    if acc and pwd then
        local accLen = utf8.len(acc)
        local pwdLen = utf8.len(pwd)
        if accLen < 1 or pwdLen < 1 then return end

        if accLen < 2 then
            MsgBox.Show(L("账号长度不足！"))
        elseif pwdLen < 6 then
            MsgBox.Show(L("密码长度不足！"))
        elseif DB.HX_Check(acc) then
            MsgBox.Show(L("输入的账号含有非法字符！"))
        elseif SVR.CfgVaild(_svrCfg) then
            SVR.Config(_svrCfg)
            SVR.Login(acc, acc == cfg.acc and pwd == cfg.pwd and pwd or Md5Pwd(pwd))
        else
            MsgBox.Show(L("请选择合适的服务器！"))
        end
    end
end
-- 点击登陆页-注册
function SceneLogin.ClickToReg()
    ToRegister()
end
-- 点击注册页-注册
function SceneLogin.ClickReg()
    local acc = _iptAccR.value
    local pwd = _iptPwdR.value
    if acc and pwd then
        local accLen = utf8.len(acc)
        local pwdLen = utf8.len(pwd)
        if accLen == 0 or pwdLen == 0 then return end

        if accLen < 2 then
            MsgBox.Show(L("账号长度不足！"))
        elseif pwdLen < 6 then
            MsgBox.Show(L("密码长度不足！"))
        elseif DB.HX_Check(acc) then
            MsgBox.Show(L("输入的账号含有非法字符！"))
        elseif _iptAccR.hasInvChar then
            MsgBox.Show(L("输入的账号含有空白字符！"))
        elseif SVR.CfgVaild(_svrCfg) then
            SVR.Config(_svrCfg)
            SVR.Register(acc, Md5Pwd(pwd))
        else
            MsgBox.Show(L("请选择合适的服务器！"))
        end
    end
end
-- 点击注册页-返回
function SceneLogin.ClickRegRtn()
    ToLogin()
end
-- 点击快速开始
function SceneLogin.ClickQuick()
    if SVR.CfgVaild(_svrCfg) then
        SVR.Config(_svrCfg)
        SVR.Register()
    else
        MsgBox.Show(L("请选择合适的服务器！"))
    end
end
-- 点击开始
function SceneLogin.ClickStart()
    if SVR.CfgVaild(_svrCfg) then
        if SDK.IsLogin() then
            SVR.Config(_svrCfg)
            SVR.SdkLogin(SDK.uuid, SDK.cid, SDK.age)
        else
            _tip:SetActive(true)
            _btnStart:SetActive(false)
            _curSvr:SetActive(false)
            if SDK.Login() then return end
            ToLogin()
        end
    else
        MsgBox.Show(L("请选择合适的服务器！"))
    end
end
-- 点击当前服务器配置
function SceneLogin.ClickCurSvr() ToSvrLst() end

function SceneLogin.OnUnLoad()
    _body = nil
end
