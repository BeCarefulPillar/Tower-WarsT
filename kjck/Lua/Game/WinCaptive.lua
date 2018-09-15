
local insert = table.insert

local win = { }
--[Comment]
--招降
WinCaptive = win

local _body = nil
local _ref = nil

local _item = nil
local _sv = nil
local _plot = nil
local _word = nil
local _arrow = nil
local _scrollArrow = nil
local _point = nil

local _btnConv = nil
local _btnFree = nil
local _btnKill = nil
local _btnCont = nil

local _labTip = nil
local _texLeft = nil
local _texRight = nil
local _labLeft = nil
local _labRight = nil

local _spBgSelect = nil

local _sf = nil
local _heros = nil
local _sltd = nil
local _opts = nil
local _curOpt = nil
local _dialogue = nil
local _curDlgs = nil
local _roles = nil

local function ExitAndDealWith(isf, isc)
    isc = isc or false
    local str = isf and "free" or "kill"
    local opt = isf and 3 or 4
    local tmp = user.battleRet.captive
    if tmp ~= nil then
        for i = 1, #tmp do
            if _opts[i] == nil or _opts[i] == 0 or _opts[i] == 2 or _opts[i] == 5 then
                if _opts[i] ~= nil then _opts[i] = opt end
                SVR.SiegeCaptive(tonumber(user.battleRet.sn), str, tmp[i])
            end
        end
    end
--    if isc then --[[ MapManager.Instance.AttackNextPveCity(); Exit() ]] -- 继续攻城
--    else --[[  ]] -- 返回主页
--    end
end

local function CheckFreeHeroTip()
    if user.IsTipCaptiveFree then
        local cnt = 0
        if _opts ~= nil then for i = 1, #_opts do if _opts[i] == 3 then cnt = cnt + 1 end end end
        if cnt > CONFIG.FreeCaptiveLimit then MsgBox.Show(string.format(L("本次释放武将已超过%d名，低星武将会自动流放！"), CONFIG.FreeCaptiveLimit), L("确定"), L("{t}不在提示"), function (bid, tgs)
            user.IsTipCaptiveFree = not tgs[0]
        end)
        end
    end
end

local function UpdateInfo(init)
    if _heros ~= nil then
        local tmp = nil
        local item = nil
        local exist = nil
        for i = 1, #_heros do
            tmp = DB.GetHero(user.battleRet.captive[i])
            item = _heros[i]
            exist = item.cachedTransform:FindChild("exist")
            if user.ExistHero(tmp.sn) ~= nil then
                if not exist then
                    tmp = _heros[i].cachedGameObject:AddWidget(typeof(UISprite), "exist")
                    tmp.atlas = AM.mainAtlas
                    tmp.spriteName = "sp_recreit"
                    tmp.width, tmp.height = 40, 35
                    tmp.cachedTransform.localPosition = Vector3(20, 23, 0)
                    tmp.depth = 7
                    if not init then
                        tmp.alpha = 0
                        tmp.cachedTransform.localScale = Vector3(1.5, 1.5, 1.5)
                        EF.Alpha(tmp, 0.3, 1)
                        EF.Scale(tmp, 0.3, Vector3.one)
                    end
                end
            else
                if exist ~= nil then Destroy(exist.gameObject) end
                tmp = item:GetCmp(typeof(UE.Collider))
                if _opts[i] == 4 and tmp and tmp.gameObject.luaBtn.enabled == true then
                    tmp.gameObject.luaBtn.enabled = false
                    item.color = Color(0.5, 0, 0.5, 1)
                end
            end
        end
    end
end

local function UpdateButton()
    local tmp = _opts[_sltd]
    _btnConv.gameObject.luaBtn.enabled = tmp == 0
    tmp = (tmp == 0 or tmp == 2) and user.gmMaxCity > 2
    _btnKill.gameObject.luaBtn.enabled =  tmp
    _btnFree.gameObject.luaBtn.enabled =  tmp
end

local function ShowBtn(s)
    _btnConv.gameObject:SetActive(s)
    _btnFree.gameObject:SetActive(s)
    _btnKill.gameObject:SetActive(s)
    _btnCont.gameObject:SetActive(s)
    _labTip.cachedGameObject:SetActive(s and (11 - user.gmMaxCity > 0))
    _arrow:SetActive(not s)
end

-- 显示剧情对话
-- 触发条件(0=无语 1=招降[拼接到2和3]，2=招降成功，3=招降失败，4=释放，5=见面，6=斩杀
local function ShowDialogue(c)
    _curDlgs = { }
    local tp = Dialogue.dlg_type.captive
    local cnt = 0
    local list = nil
    local digs = nil
    local rd = Mathf.Random
    if c == 2 or c == 3 then
        list = DB.AllDlg(tp, function (d) return d.c == 1 end)
        cnt = #list
        if cnt > 0 then
            -- 剧情对话(每段对话用|隔开，每段对话开头标记对象[N:表示武将，P:表示玩家] 例如[N:...|P:...])
            digs = string.split(list[rd(1, cnt)].tx, "|")
            for i = 1, #digs do insert(_curDlgs, digs[i]) end
        end
        list = DB.AllDlg(tp, function (d) return d.c == c end)
        cnt = #list
        if cnt > 0 then
            digs = string.split(list[rd(1, cnt)].tx, "|")
            for i = 1, #digs do insert(_curDlgs, digs[i]) end
        end
    else
        list = DB.AllDlg(tp, function (d) return d.c == c end)
        cnt = #list
        if cnt > 0 then
            digs = string.split(list[rd(1, cnt)].tx, "|")
            for i = 1, #digs do insert(_curDlgs, digs[i]) end
        end
    end
    cnt = #_curDlgs
    if cnt > 0 then
        if cnt > 1 then ShowBtn(false) end
        --[[ Tutorial.Active = false ]] -- 新手教程检测关闭
        win.ClickWin()
    else _curDlgs = nil
    end
end

local function RoleSwitch()
    local tmp = DB.GetHero(user.battleRet.captive[_sltd])
    _texLeft:LoadTexAsync(ResName.HeroImage(tmp.img))
    _texLeft:GetCmpInChilds(typeof(UIRepeat)).TotalCount = tmp.rare
    _texLeft.color = Color.white
    _texLeft.shader = UE.Shader.Find("Unlit/Transparent Colored")
    _texLeft.alpha = 1
    _texRight.alpha = 0
    _labLeft.text = tmp.nm
    _labRight.text = user.nick
    ShowDialogue(_opts[_sltd] == 0 and 5 or 0)
end

local function SelectHero(idx)
    local tmp = user.battleRet.captive
    if tmp[idx] ~= nil then
        if _opts[idx] == 3 or _opts[idx] == 4 then return end
        _sltd = idx
        if idx > 0 and idx <= #_heros then
            if _sf == nil then
                _sf = _spBgSelect;
                _sf.cachedGameObject:SetActive(true)
            end
            _sf.cachedTransform.parent = _heros[idx].cachedTransform
            _sf.cachedTransform.localPosition = Vector3(0,-31,0)
            _sf.cachedTransform.localScale = Vector3.one
        end
        UpdateButton()
        _plot:SetActive(true)


        RoleSwitch()

--        if _texLeft.cachedTransform.localPosition.x > -399 then
--            tmp = _texLeft:GetCmp(typeof(TweenAlpha))
--            tmp:Play(true)
--            tmp.callWhenFinished = "RoleSwitch"
--        print("99999999999999999999999999")

--        else 
--        print("88888888888888888888888888")

--            RoleSwitch()
--        end
    else
        _sltd = -1
        if _sf ~= nil then Destroy(_sf.cachedGameObject) end
        _plot:SetActive(false)
        _labLeft.text = ""
        _labRight.text = ""
        _word:TypeText("")
        EF.ResetToInit(_texLeft:GetCmp(typeof(TweenAlpha)))
        EF.ResetToInit(_texRight:GetCmp(typeof(TweenAlpha)))
        EF.ResetToInit(_texRight:GetCmp(typeof(TweenPosition)))
    end
end

local function FreeSelectHero()
            ShowDialogue(4)

--    if _opts[_sltd] == 0 or _opts[_sltd] == 2 or _opts[_sltd] == 5 then
--        SVR.SiegeCaptive(tonumber(user.battleRet.sn), "free", user.battleRet.captive[_sltd], function (r) if r.success then
--            _curOpt = 2
--            _opts[_sltd] = 3
--            UpdateButton()
--            ShowDialogue(4)
--        end end)
--    end
end

-- 单个操作完，如果还有可操作武将，自动选择下一个可操作武将
local function SelectNextValid()
    if _opts == nil or #_opts <= 0 then return end
    for i = 1, #_opts do
        -- 是否所有俘虏都处理完
        if _opts[i] == 0 then
            SelectHero(i)
            if #user.battleRet.captive > 3 then
                _sv.transform.localPosition = Vector3(-100 * i, 140, 0)
                _sv.panel.clipOffset = Vector2(100 * i, 0)
            end
            return
        end
    end
end

local _update = nil
local function Update()

end

local function BuildItems()
    local tmp = #user.battleRet.captive
    table.sort(user.battleRet.captive, function (a, b) return DB.GetHero(a).rare > DB.GetHero(b).rare end)
    _scrollArrow:SetActive(tmp > 3)
    _opts = { }
    _heros = { }
    local tmp1 = nil
    local dat = nil
    for i = 1, tmp do
        dat = DB.GetHero(user.battleRet.captive[i])
        tmp1 = _sv.gameObject:AddChild(_item, string.format("hero_%02d", i)):GetCmp(typeof(UITexture))
        _heros[i] = tmp1
        tmp1.gameObject:SetActive(true);
        tmp1:LoadTexAsync(ResName.HeroIcon(dat.img));
        tmp1:GetCmpInChilds(typeof(UILabel)).text = dat.nm
        tmp1:GetCmpInChilds(typeof(UIRepeat)).TotalCount = dat.rare
        tmp1:GetCmp(typeof(UIDragScrollView)).scrollView = _sv
        tmp1:GetCmp(typeof(LuaButton)).param = i
        if user.ExistHero(dat.sn) ~= nil then _opts[i] = 5
        else _opts[i] = 0 end
    end
end

function win.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK})
    _body = c
    _ref = c.nsrf.ref
    c:BindFunction("OnInit", "OnEnter", "OnExit", "OnDispose", "OnUnLoad",
    "ClickClose", "ClickFree", "ClickConv", "ClickContinue", "ClickKill", 
    "ClickHero", "ClickWin")

    local tmp = c.nsrf.ref
    _item = tmp.item_captive
    _sv = tmp.scrollView
    _plot = tmp.plot
    _word = tmp.word
    _arrow = tmp.arrow
    _scrollArrow = tmp.scrollArrow
    _btnConv = tmp.btnConv
    _btnFree = tmp.btnFree
    _btnKill = tmp.btnKill
    _btnCont = tmp.btnContinue
    _labTip = tmp.tip
    _texLeft = tmp.leftRole
    _texRight = tmp.rightRole
    _labLeft = tmp.leftName
    _labRight = tmp.rightName
    _spBgSelect = tmp.bgSelect
end

function win.OnInit()

    local tmp = #user.battleRet.captive
    if tmp > 0 then
        BuildItems()
        _texRight:LoadTexAsync(ResName.PlayerRole(user.role))
        if 10 - user.gmMaxCity > 0 then
            _labTip.text = L("距离招募[FF6600]五星张角[-]还有") + tostring(10 - user.gmMaxCity) + lL("关!");
            _labTip.gameObject:SetActive(true)
        else
             _labTip.gameObject:SetActive(false)
        end
    else
        Destroy(_body.gameObject)
        return
    end

    _update = UpdateBeat:CreateListener(Update)
    UpdateBeat:AddListener(_update)
end

function win.OnEnter()
    UpdateInfo(true)
    SelectHero(1)
end

function win.OnExit()
    CheckFreeHeroTip()
    user.battleRet.captive = nil
    --[[ BattleManager.BattleEndEvent() ]]
end

function win.OnDispose()
    _heros = nil
    _sltd = nil
    _opts = nil
    _curOpt = nil
    _dialogue = nil
    _curDlgs = nil
    _roles = nil
    SelectHero(-1)
    _texLeft.shader = UE.Shader.Find("Unlit/Transparent Colored")
    _texLeft:UnLoadTex()
    _texRight:UnLoadTex()
    if _sf ~= nil then
        Destroy(_sf.gameObject)
        _sf = nil
    end
end

function win.OnUnLoad()
    _body = nil
    _item = nil
    _sv = nil
    _plot = nil
    _word = nil
    _arrow = nil
    _scrollArrow = nil
    _btnConv = nil
    _btnFree = nil
    _btnKill = nil
    _btnCont = nil
    _labTip = nil
    _texLeft = nil
    _texRight = nil
    _labLeft = nil
    _labRight = nil
end

-------------- 按钮事件

function win.ClickWin()
    if _curDlgs ~= nil then
        local cnt = #_curDlgs
        local dig = nil
        local tmp1 = nil
        local tmp2 = nil
        local tmp3 = nil
        local tmp4 = nil
        if cnt > 0 then
            dig = _curDlgs[1]
            table.remove(_curDlgs, 1)
            tmp1 = _texLeft:GetCmp(typeof(TweenAlpha))
            tmp3 = _texRight:GetCmp(typeof(TweenAlpha))
            tmp4 = _texRight:GetCmp(typeof(TweenPosition))
            if string.find(dig, "N:") == 1 then
                tmp1:Play(true)
                tmp3:Play(false)
                tmp4:Play(false)
            elseif string.find(dig, "P:") == 1 then
                tmp1:Play(false)
                tmp3:Play(true)
                tmp4:Play(true)
            end
            _word:TypeText( string.sub(dig, 3))
        end
        cnt = cnt - 1
        if cnt <= 0 then
            _curDlgs = nil
            ShowBtn(true)
            if _curOpt == nil then
                _curOpt = 0
            end
            if _curOpt > 0 then Invoke(SelectNextValid, 1) end
            if _curOpt == 1 then
                UpdateInfo()
                tmp1 = user.ExistHero(user.battleRet.captive[_sltd])
                if tmp ~= nil then NewEffect.ShowNewHero(hd.db) -- 招募成功
                else ToolTip.ShowPopTip(ColorStyle.Bad(L("招募失败"))) -- 招募失败
                end
            elseif _curOpt == 3 then
                UpdateInfo()
                BGM.PlaySOE(AM.LoadAudioClip("sound_decapitate"), BGM.volume)
                tmp1 = _texLeft.cachedGameObject:AddWidget(typeof(UISprite), "anim")
                tmp1.cachedTransform.localPosition = Vector3(0, 155, 0)
                tmp1.cachedTransform.localEulerAngles = Vector3(0, 0, 45)
                tmp1.depth = 25
                tmp2 = tmp1.cachedGameObject:AddCmp(typeof(UISpriteAnimation))
                tmp2.namePrefix = "decapitate_"
                tmp2.loop = false
                tmp2:ResetToBeginning()
                tmp2.framesPerSecond = 8
                EF.Alpha(tmp1, 0.2, 0, 0.4)
                Destroy(tmp1.cachedGameObject, 0.6)
                AtlasLoader.LoadAsync(tmp1, "anim_legacy", false, true)
                _texLeft.shader = UE.Shader.Find("Unlit/Transparent HSB")
                _texLeft.color = Color(0.5, 0.5, 0.5, 1)
                EF.Color(_texLeft, 0.2, Color(0.5, 0, 0.5, 1))
            end
            _curOpt = 0
        end
    end
end

function win.ClickHero(idx)
    if idx ~= _sltd then SelectHero(idx) end
end

--斩杀
function win.ClickKill()
    local tmp = user.battleRet
    if user.gmMaxCity == 11 and tmp.sn == 11 then
        tmp = table.idxof(tmp.captive, DB_Hero.ZHI_JIANG)
        if _opts[tmp] ~= nil and _opts[tmp] == 0 then
            ToolTip.ShowPopTip( string.format(L("%s是不可多得的勇武之将，请陛下珍惜。"), ColorStyle.Rare(DB.GetHero(DB_Hero.ZHI_JIANG))))
        end
        return
    end
    SVR.SiegeCaptive(tonumber(tmp.sn), "kill", tmp.captive[_sltd], function (r) 
        if r.success then
            _curOpt = 3
            _opts[_sltd] = 4
            ShowDialogue(6)
            UpdateButton()
        end 
    end)
end

--继续攻城
function win.ClickContinue()
    local tmp = false
    if _opts ~= nil then
        for i = 1, #_opts do
            if _opts[i] == 0 or _opts[i] == 2 or _opts[i] == 5 then tmp = true break end
        end
    end
    if tmp == true then
        tmp = user.battleRet
        if user.gmMaxCity == 11 and tmp.sn == 11 and table.exists(tmp.captive, function (sn) return sn == DB_Hero.ZHI_JIANG end) then -- 吕布必须处理
            ToolTip.ShowPopTip(string.format(L("绝世猛将%s已被抓获，请主公发落！"), ColorStyle.Rare(DB.GetHero(DB_Hero.ZHI_JIANG))));
            return
        end
        MsgBox.Show(L("还有未处理的俘虏，请主公定夺"), L("斩杀")..","..L("释放")..","..L("取消"), function (bid)
            if bid == 0 then 
                ExitAndDealWith(false, true)
            elseif bid == 1 then
                if user.IsTipCaptiveFree then
                    MsgBox.Show(L("俘虏释放后会逃往下一城池，增加攻打难度，你确定释放吗？"), L("确定")..","..L("取消"), L("{t}不在提示"), function (bid, tgs) if bid == 0 then
                        user.IsTipCaptiveFree = not tgs[0]
                        ExitAndDealWith(true, true)
                    end end)
                else
                    ExitAndDealWith(true, true)
                end
            end
        end)
    else 
        ExitAndDealWith(true, true)
    end
end

--招降
function win.ClickConv()
    if _opts[_sltd] == nil or _opts[_sltd] ~= 0 then return end
    local tmp = user.battleRet
    SVR.SiegeCaptive(tonumber(tmp.sn), "conv", tmp.captive[_sltd], function (r)
        if r.success then
            _curOpt = 1
            local res = SVR.datCache
            if res.csn > 0 and res.dbsn > 0 then
                _opts[_sltd] = 1
                ShowDialogue(2)
            else
                _opts[_sltd] = 2
                ShowDialogue(3)
            end
            UpdateButton()
        end 
    end)
end

--释放
function win.ClickFree()
FreeSelectHero()
--    if user.gmMaxCity == 11 and user.battleRet.sn == 11 then -- 吕布只能招降
--        local tmp = table.idxof(user.battleRet.captive, DB_Hero.ZHI_JIANG)
--        if _opts[tmp] ~= nil and _opts[tmp] == 0 then
--            ToolTip.ShowPopTip(string.format(L("%s乃绝世猛将将，放之如放虎归山，请主公三思！"), ColorStyle.Rare(DB.GetHero(DB_Hero.ZHI_JIANG))))
--        end
--        return
--    end
--    if user.IsTipCaptiveFree then
--        MsgBox.Show(L("俘虏释放后会逃往下一城池，增加攻打难度，你确定释放吗？"), L("确定")..","..L("取消"), L("{t}不在提示"), function (bid, tgs) if bid == 0 then
--            user.IsTipCaptiveFree = not tgs[0]
--            FreeSelectHero()
--        end end)
--    else FreeSelectHero()
--    end
end

--关闭
function win.ClickClose()
    if _opts ~= nil then
        for i = 1, #_opts do
            if _opts[i] == 0 or _opts[i] == 2 or _opts[i] == 5 then
                if user.gmMaxCity == 11 and user.battleRet.sn == 11 and table.exists(user.battleRet.captive, function (sn) return sn == DB_Hero.ZHI_JIANG end) then -- 吕布必须处理
                    ToolTip.ShowPopTip( string.format("绝世猛将%s已被抓获，请主公发落！", ColorStyle.Rare(DB.GetHero(DB_Hero.ZHI_JIANG))))
                    return
                end
                MsgBox.Show(L("还有未处理的俘虏，请主公定夺"), L("斩杀")..","..L("释放")..","..L("取消"), function (bid)
                    if bid == 0 then ExitAndDealWith(false)
                    elseif bid == 1 then
                        if user.IsTipCaptiveFree then
                            MsgBox.Show(L("俘虏释放后会逃往下一城池，增加攻打难度，你确定释放吗？"), L("确定")..","..L("取消"), L("{t}不在提示"), function (bid1, tgs) if bid1 == 0 then
                                user.IsTipCaptiveFree = not tgs[0]
                                ExitAndDealWith(true)
                            end end)
                        else ExitAndDealWith(true)
                        end
                    end
                end)
                return
            end
        end
    end
    ExitAndDealWith(false)
end
