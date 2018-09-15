
local map = { }
LevelMap = map
LevelMap.isOpen = nil

local _body = nil

local _item = nil
local _exped = nil
local _texBg = nil
local _tws = nil
local _twa = nil
--[pve 0=详情 1=开发 2=副本 3=出征]
local _btns = nil
local _cityBtn = nil

local _ef = nil

local _datas = nil

local _items = nil
local _nodes = nil
local _cityNodes = nil
local _paths = nil
local _itemCitys = nil

local _heros = nil
local _path = nil
local _isMove = nil
local _from = nil
local _to = nil
local _clickCity = nil
local _locat = nil
local _isInit = nil


-- 释放 GameObject 缓存
local function DisposeObj()
    if _items ~= nil then
        for k, v in pairs(_items) do if k ~= nil then Destroy(k) end end
        _items = nil
    end
    if _itemCitys ~= nil then
        for i = 1, #_itemCitys do _itemCitys[i] = nil end
        _itemCitys = nil
    end
    if _ef ~= nil then
        Destroy(_ef)
        _ef = nil
    end
end
-- 获取经过的路径节点
local function GetPathNodes(from, to)
    _path = { }
    table.insert(_path, from)
    local tmp = from
    while tmp ~= to do
        for i = 1, #_paths do
            if _paths[i][1] == from then
                from = _paths[i][2]
                table.insert(_path, from)
                tmp = from
                break
            end
        end
    end
end
-- 是否在行动
local function IsExpedition() return _heros ~= nil and _from > 0 end
--[Comment]
-- 是否在行动
map.IsPrepareExpedition = function () return IsExpedition() and not _isMove end
-- 取消行动
local function ExpeditionCancle()
    if _isMove == true then return end
    _heros = nil
    _from = 0
    _to = 0
    UICamera.onClick = nil
end
--[Comment]
-- 取消行动
map.CancleExpedition = ExpeditionCancle

-- 设置是否正在移动
local function SetIsMove(m)
    _isMove = m
    _exped.gameObject:SetActive(m)
    Tools.SetUICameraEventMask(not m, {"MainUI"})
    m = _body:GetCmpsInChilds(typeof(UE.BoxCollider))
    for i = 0, m.length - 1 do m[i].enabled = not _isMove or m[i].gameObject == _texBg.gameObject end
    if not _isMove then
        _path = { }
        ExpeditionCancle()
    end
end
-- 移动到我方最后一座城池
local function MoveToLast(ins)
    if _itemCitys ~= nil then
        local len = #_itemCitys
        for i = len, 1, -1 do
            if _itemCitys[i].IsOwn then
                EF.MoveSVTo(_body, _itemCitys[i].go.transform.localPosition, ins)
                break
            end
        end
    end
end

-- 新手教学检测
local function CheckTutorial()
    --[[ if user.TutorialSN == 1 then
        if user.TutorialStep == 2 then -- 打第2城
            if user.gmMaxCity == 1 then
                EF.MoveSVTo(_itemCitys[2].go.transform.localPosition, false)
                Tutorial.PlayTutorial(true, _itemCitys[2].go.transform)
            end
        elseif user.TutorialStep == 11 then -- 打第3城
            if user.gmMaxCity == 2 then
                EF.MoveSVTo(_itemCitys[3].go.transform.localPosition, false)
                Tutorial.PlayTutorial(true, _itemCitys[3].go.transform)
            end
        elseif user.TutorialStep == 14 then -- 开发第3城
            if user.gmMaxCity > 2 then
                EF.MoveSVTo(_itemCitys[3].go.transform.localPosition, false)
                Tutorial.PlayTutorial(true, _itemCitys[3].go.transform)
            end
        elseif user.TutorialStep == 17 then -- 收获宝箱
            if _itemCitys[3].BtnChest ~= nil then
                EF.MoveSVTo(_itemCitys[3].go.transform.localPosition, false)
                Tutorial.PlayTutorial(true, _itemCitys[3].go.transform)
            end
        elseif user.TutorialStep == 22 then -- 打第4城
            if user.gmMaxCity == 3 then
                EF.MoveSVTo(_itemCitys[4].go.transform.localPosition, false)
                Tutorial.PlayTutorial(true, _itemCitys[4].go.transform)
            end
        elseif user.TutorialStep == 30 then -- 打第5城
            if user.gmMaxCity == 4 then
                EF.MoveSVTo(_itemCitys[5].go.transform.localPosition, false)
                Tutorial.PlayTutorial(true, _itemCitys[5].go.transform)
            end
        elseif user.TutorialStep == 34 then -- 打第6城
            if user.gmMaxCity == 5 then
                EF.MoveSVTo(_itemCitys[6].go.transform.localPosition, false)
                Tutorial.PlayTutorial(true, _itemCitys[6].go.transform)
            end
        elseif user.TutorialStep == 37 then -- 打第7城
            if user.gmMaxCity == 6 then
                EF.MoveSVTo(_itemCitys[7].go.transform.localPosition, false)
                Tutorial.PlayTutorial(true, _itemCitys[7].go.transform)
            end
        elseif user.TutorialStep == 47 then -- 打第9城
            if user.gmMaxCity == 8 then
                EF.MoveSVTo(_itemCitys[2].go.transform.localPosition, false)
                Tutorial.PlayTutorial(true, _itemCitys[2].go.transform)
            end
        end
    end ]]
end
--[Comment]
-- 检查新手教程
LevelMap.CheckTutorial = CheckTutorial

local function CheckBtnTutorial()
    --[[ if user.TutorialSN == 1 then
        if user.TutorialStep == 15 then -- 开发
            if _btns[1].gameObject.activeSelf then Tutorial.PlayTutorial(true, _btns[1].transform) end
        end
    end ]]
end
-- 退出功能按钮
local function ExitButtons()
    _clickCity = nil
    for i = 0, _btns.length - 1 do
        if _btns[i].gameObject.activeSelf then
            EF.ClearITween(_btns[i])
            EF.MoveTo(_btns[i], "position", Vector3.zero, "islocal", true, "time", 0.3, "easetype", iTween.EaseType.easeOutExpo)
        end
    end
    _tws:Play(false)
    _twa:Play(false)
    coroutine.wait(0.4)
    _cityBtn:SetActive(false)
end

--[Comment]
--此地图下关卡通关数
local boxCount = nil
--[Comment]
--征战宝箱数据
local boxRws = nil
--[Comment]
--所有可领取的征战宝箱的关卡
local boxMap = nil

--[Comment]
--刷新宝箱
local function RefreshBox()
    local box = MainUI.expeditionBox
    local box1 = box:ChildWidget("box_1")
    local box2 = box:ChildWidget("box_2")
    local box3 = box:ChildWidget("box_3")
    local slider = box:Child("slider")
    slider = slider:GetCmp(typeof(UISlider))
    slider.value = boxCount > 3 and (boxCount <= 6 and (boxCount - 1) * 0.1 or boxCount * 0.1) or 0;
    box = { box1, box2, box3 }
    for i =1 , #box  do
        local btn = box[i].gameObject.luaBtn
        btn.param = boxRws[i]
        btn.enabled = true
        if boxRws[i].isGet == 0 then
            box[i].spriteName = "sp_country_box_" .. (i + 1);
            box[i].gameObject:Child("glow").gameObject:SetActive(false);
        elseif boxRws[i].isGet == 1 then
            box[i].spriteName = "sp_country_box_" .. (i + 1);
            box[i].gameObject:Child("glow").gameObject:SetActive(true);
        else
            box[i].spriteName = "sp_country_box_dis_" .. (i + 1);
            box[i].gameObject:Child("glow").gameObject:SetActive(false);
        end
    end
  
end

--[Comment]
--征战宝箱查询
local function ExpeditionBox()
    SVR.ExpeditionBox(user.gmLv,'',1,function(t)
        if t.success then
            local boxDt = SVR.datCache
            boxCount = boxDt.count
            boxRws = boxDt.boxRws
            boxMap = boxDt.map
            RefreshBox()
        end
    end)
end

local function OnLoadShow()
    local atp = StatusBar.ShowR(L("加载中..."), 10, true)
    local tmp = _datas[user.gmLv]
    if tmp == nil then
        tmp = kjson.decode(AM.LoadText(ResName.LevelMapNode(user.gmLv)))
        _datas[user.gmLv] = tmp
    end
    MainUI.labMapLevel.text = L("第" .. number.ToCnString(user.gmLv) .. "章  " .. DB.GetGmLv(user.gmLv).nm)

    _nodes = tmp.node
    _cityNodes = tmp.city
    _paths = tmp.path
    _texBg.width, _texBg.height = tmp.width, tmp.height

    if MainUI ~= nil then
        tmp = MainUI.btns
        tmp.nextLv.gameObject:SetActive(user.gmLv < user.gmMaxLv)
        tmp.prevLv.gameObject:SetActive(user.gmLv > 1)
    end

    tmp = DB.GetGmLv((user.gmLv + 1 > DB.maxGmLv) and DB.maxGmLv or (user.gmLv + 1))
    local lut = MainUI.expeditionBox:ChildWidget("lab_unlock_tip")
    if user.hlv < tmp.unlockLv then
        lut.text = L("下一关卡需要主城[FF0000]"..tmp.unlockLv .."级[-]")
        lut.gameObject:SetActive(true)
    else
        lut.gameObject:SetActive(false)
    end

    coroutine.start(ExitButtons)

    tmp = nil
    EF.Alpha(_body, 0.25, 0.3)
    coroutine.step()
    if MapCloud ~= nil then
        if not MapCloud.isOpen then Win.Open("MapCloud") end
        MapCloud.StartCutMap(false, false)
    end
    -- 加载地图
    coroutine.wait(0.3)
    local tm = Time.realtimeSinceStartup + 0.3
    tmp = _texBg:LoadTexAsync(ResName.LevelMap(user.gmLv))
    while tmp.isDone == false do
        atp.process = tm < Time.realtimeSinceStartup and tmp.process or 0
        coroutine.step()
    end
    atp:Done()
    DisposeObj()

    --查询征战宝箱
    Invoke(ExpeditionBox, 0.3)

    -- 加载城池
    tmp = DB.GetGmLv(user.gmLv)
    tmp = tmp.city
    if tmp ~= nil then
        local len = #tmp
        _items = { }
        _itemCitys = { }
        local sc = _body:GetCmp(typeof(UIScrollView))
        local ic = nil
        local nd = nil
        for i = 1, len do
            ic = _body.gameObject:AddChild(_item, string.format("city_%03d", tmp[i]))
            if ic ~= nil then
                ic:AddCmp(typeof(UIDragScrollView)).scrollView = sc
                ic:GetCmp(typeof(LuaButton)).luaContainer = _body
                ic:SetActive(true)
                ic = ItemCity(ic)
                ic:Init(tmp[i])
                ic.node = -1
                for j = 1, #_cityNodes do
                    if _cityNodes[j][2] == ic.sn then
                        ic.node = _cityNodes[j][1]
                        nd = _nodes[ic.node]
                        ic.go.transform.localPosition = Vector3(nd[1], nd[2], 0)
                        break;
                    end
                end
                if ic.node < 0 then ic.go:SetActive(false) end
                --去除每张图的第一个城池，因为它是上一张图的最后一座城或原始城
                if i == 1 then
                    ic.go.transform.localScale = Vector3.one * 0.01
                    ic.go:SetActive(false)
                end
                _items[ic.go] = ic
                _itemCitys[i] = ic
            end
        end

        MoveToLast(true)
        Invoke(CheckTutorial, 0.6)
    end
    EF.Alpha(_body, 0.2, 1)

    if _locat ~= nil and _locat > 0 then
        if _locat == user.gmMaxCity + 1 then
            _locat = user.gmMaxCity
            map.AttackNextCity()
        end
        map.MoveTo(_locat, false)
        _locat = 0
    end

end

local function LoadMap(lv)
    if lv <= 0 or lv > user.gmMaxLv then lv = user.gmLv end
    if lv ~= user.gmLv then
        SVR.GetLevelMap(lv, function (r) if r.success then
            coroutine.start(OnLoadShow)
        end end)
    elseif not _body.gameObject.activeSelf then coroutine.start(OnLoadShow)
    elseif _locat ~= nil and _locat > 0 then
        if _locat == user.gmMaxCity + 1 then
            _locat = user.gmMaxCity
            map.AttackNextCity()
        end
        map.MoveTo(_locat, false)
        _locat = 0
    end
end

local function ClickGlobal(go) map.ClickMap() end
-- 出征 
local function ExpeditionBegin(hs, ic)
    if ic ~= nil and ic.sn > 0 and hs ~= nil and #hs > 0 then
        if ic.IsOwn == true then
            _heros = hs
            _from = ic.sn
            UICamera.onClick = ClickGlobal
        elseif _items ~= nil then
            for k, v in pairs(_items) do
                if v ~= nil and v.sn == ic.sn - 1 and v.IsOwn then
                    _heros = hs
                    _from = v.sn
                    _to = ic.sn
                    _exped.localPosition = v.go.transform.localPosition
                    GetPathNodes(v.node, ic.node)
                    SetIsMove(true)
                    return
                end
            end
        end
    end
end

local function ExpeditionTo(ic)
    if IsExpedition() then
        if _from == ic.sn then
            ToolTip.ShowPopTip(L("目标不能是自身"))
            return
        end
        for k, v in pairs(_items) do
            if v.sn == _from then
                _to = ic.sn
                _exped.localPosition = k.transform.localPosition
                GetPathNodes(v.node, ic.node)
                SetIsMove(true)
                return
            end
        end
    end
    ExpeditionCancle()
end

--移动完毕准备打架
local function Expedition()
    if IsExpedition() and _to > 0 then
        for k, v in pairs(_items) do

            if v.sn == _to then
                if v.IsOwn == true then
                    local hs = _heros
                    local from = _from
                    local to = _to
                    SVR.MoveHero(_heros, _to, 1, function (r) if r.success then
                        local len = #hs
                        for k, v in pairs(_items) do
                            if v ~= nil then
                                --帝国不看驻守将领数量
--                                if v.sn == from then v.HeroCount = v.HeroCount - len
--                                elseif v.sn == to then v.HeroCount = v.HeroCount + len end
                            end
                        end
                        local hd = nil
                        for i = 1, len do
                            hd = user.GetHero(hs[i])
                            if hd ~= nil then hd:SetLoc(to) end
                        end
                    end end)
                else
                    SVR.SiegeReady(_to, _heros, 
                        function (r) 
                            if r.success then
                                Win.Open("WinBattle", SVR.datCache)
                            end 
                        end)
                end
                return
            end
        end
    end
    SetIsMove(false)
end
-- 打开城池操作按钮（目前没用，点击城池是直接选将）
local function ShowCityButtons(ic)
    if ic == nil then
        if _cityBtn.activeSelf then coroutine.start(ExitButtons) end
        return
    end
    if _clickCity == ic and _cityBtn.activeSelf then coroutine.start(ExitButtons) return end

    _clickCity = ic
    -- 按钮复位
    _cityBtn.transform.position = ic.go.transform.position
    _cityBtn.transform.localScale = Vector3.zero
    for i = 0, _btns.length - 1 do _btns[i].transform.localPosition = Vector3.zero end
    -- 设置按钮状态
    _btns[1].gameObject:SetActive(user.IsDevUL and ic.sn > 1 and ic.IsOwn and (ic.lv == nil or ic.lv < DB.maxCityLv))
    _btns[2].gameObject:SetActive(user.IsHistroyUL and ic.sn > 1 and ic.IsOwn)
    _btns[3].gameObject:SetActive(ic.sn == user.gmMaxCity + 1 or ic.IsOwn)  --(ic.IsOwn and ic.HeroCount > 0))--帝国不看驻守将领数量
    _btns[3].text = ic.IsOwn and L("移动") or L("攻占")
    -- 整体动画
    _tws:ResetToBeginning()
    _twa:ResetToBeginning()
    _cityBtn:SetActive(true)
    _tws:Play(true)
    _twa:Play(true)
    -- 按钮显示动画
    local dis = 75
    local cnt = 0
    for i = 0, _btns.length - 1 do if _btns[i].gameObject.activeSelf then cnt = cnt + 1 end end
    local inty = _cityBtn.transform.localPosition.y > 200 and -dis or dis
    local pos = { }
    local ba = Mathf.PI / 3
    local angle = Mathf.PI / cnt
    if angle < ba then angle = Mathf.Min(ba, 2 * angle) end
    local tmp = cnt / 2
    local a = nil
    if cnt % 2 == 0 then
        for i = 1, tmp do
            a = (i - 0.5)  * angle
            pos[i * 2 - 1] = Vector3(dis * Mathf.Sin(-a), inty * Mathf.Cos(- a), 0)
            pos[i * 2] = Vector3(dis * Mathf.Sin(a), inty * Mathf.Cos(a), 0) 
        end
    else
        pos[1] = Vector3(0, inty, 0)
        for i = 1, tmp do
            a = i * angle
            pos[i * 2] = Vector3(dis * Mathf.Sin(-a), inty * Mathf.Cos(-a), 0)
            pos[i * 2 + 1] = Vector3(dis * Mathf.Sin(a), inty * Mathf.Cos(a), 0)
        end
    end
    tmp = 1
    for i = 0, _btns.length - 1 do
        if _btns[i].gameObject.activeSelf then
            EF.ClearITween(_btns[i])
            EF.MoveTo(_btns[i], "position", pos[tmp], "islocal", true, "time", 0.3, "easetype", iTween.EaseType.easeOutExpo)
            tmp = tmp + 1
        end
    end
    Invoke(CheckBtnTutorial, 0.4)
end
-- 定位到指定的PVE城池
local function Location(c)
    if isNumber(c) then c = DB.GetGmCity(c)
    elseif not isTable(c) then c = DB.GetGmCity(user.gmMaxCity)
    end
    if c ~= nil and c.sn > 0 and c.main > 0 and c.main <= user.gmMaxLv then
        _locat = c.sn
        LoadMap(c.main)
    end
end

local _update = nil
local function Update()
    -- 武将移动
    if _isMove then
        if _items ~= nil and #_path > 0 then
            local tmp = _path[1]
            local pos = Vector3(_nodes[tmp][1], _nodes[tmp][2], 0)
            local tmp1 = _exped.localPosition
            tmp1.z = 0
            tmp1 = pos - tmp1
            local d = 100 * Time.deltaTime
            tmp = _exped.localPosition
            _exped.localPosition = tmp + (Vector3.Normalize(tmp1) * d)
            _exped.localEulerAngles = Vector3(0, tmp1.x < 0 and 180 or 0, 0)

            if tmp1:Magnitude() <= d then
                tmp = _path[1]
                table.remove(_path, 1)
                _exped.localPosition = pos
                tmp1 = nil
                for k, v in pairs(_items) do if v.node == tmp then
                    tmp1 = v
                    break
                end end
                if #_path <= 0 then -- 移动到目的地
                    Expedition()
                    SetIsMove(false)
                -- 遇到敌方城池
                elseif tmp1 ~= nil and not tmp1.IsOwn then
                    _to = tmp1.sn
                    Expedition()
                    SetIsMove(false)
                end
            end
        else SetIsMove(false)
        end
    end
end

--[Comment]
-- 城池功能按钮
map.Btns = _btns

function map.OnLoad(c)
    _body = c

    c:BindFunction("OnInit", "OnEnable", "OnDispose", "OnUnLoad",
    "ClickNextLevel", "ClickPrevLevel", "ClickCity", "ClickOptionBtn", "ClickMap")

    local tmp = c.gos
    _item = tmp[0]
    _exped = tmp[1].transform
    _texBg = tmp[2]:GetCmp(typeof(UITexture))
    _cityBtn = tmp[3]
    _tws = tmp[3]:GetCmp(typeof(TweenScale))
    _twa = tmp[3]:GetCmp(typeof(TweenAlpha))
    --[pve 0=详情 1=开发 2=副本 3=出征]
    _btns = c.btns
    for i = 0, _btns.length - 1 do _btns[i].param = i end

    _datas = { }
end

function map.OnInit()
    _path = { }

    local dat = user.GetLevelPveCity(user.gmLv)
    if dat == nil or #dat <= 0 then
        Win.Open("MainMap")
        _body:Exit()
        return
    end
    -- 退出所有窗体
--    Win.ExitAllWin("LevelMap")

    if user.gmLv >= user.gmMaxLv then BGM.Play("bg_1")
    else BGM.Play("bg_0") end
    if MainUI ~= nil then
        MainUI.ChangeButton(MAP_TYPE.MAP_LEVEL)
        MainUI.btns.nextLv.luaContainer = _body
        MainUI.btns.prevLv.luaContainer = _body
    end
    Location(LevelMap.initObj)

    _update = UpdateBeat:CreateListener(Update)
    UpdateBeat:AddListener(_update)
    LevelMap.isOpen = true
end
--[Comment]
-- 进攻下一座城池
function map.AttackNextCity()
    if Win.GetOpenWin("PopSelectHero") then return end
    if _items ~= nil then
        for k, v in pairs(_items) do
            if v ~= nil and not v.IsOwn then
                --[[ PopSelectHero.Open(SelectHeroFor.Pve, function (heros) ExpeditionBegin(heros, v) end) ]]
                EF.MoveSVTo(k.transform.localPosition, false)
                break
            end
        end
    end
end
--[Comment]
-- 移动到指定城池SN的位置
function map.MoveTo(sn, ins)
    if _items ~= nil then
        for k, v in pairs(_items) do
            if v ~= nil and v.sn == sn then
                EF.MoveSVTo(k.transform.localPosition, ins)
                break
            end
        end
    end
end
--[Comment]
-- 刷新所有城池
function map.RefreshAllCity()
    if _itemCitys ~= nil then
        for i = 1, #_itemCitys do
            if _itemCitys[i] ~= nil then _itemCitys[i]:Init(_itemCitys[i].sn) end
        end
    end
end

function map.OnEnable()
    if user.gmLv < user.gmMaxLv then BGM.Play("bg_0")
    else BGM.Play("bg_1") end
    -- 某些手机会出现层级错误
    _body.gameObject.layer = CS.NameToLayer("Default")
end

function map.OnDispose()
    if _update ~= nil then UpdateBeat:RemoveListener(_update) end
    for i = 1, _btns.length - 1 do _btns[i].gameObject:SetActive(false) end
    DisposeObj()
    ExpeditionCancle()
    SetIsMove(false)
    _nodes = nil
    _cityNodes = nil
    _paths = nil
    _path = nil
    _from = nil
    _to = nil
    _clickCity = nil
    LevelMap.isOpen = nil
    _locat = nil
    _isInit = nil
end

function map.OnUnLoad()
    _body = nil
    _item = nil
    _exped = nil
    _texBg = nil
    _btns = nil
    _datas = nil
    _cityBtn = nil
    _tws = nil
    _twa = nil
end

------------ 按钮事件

function map.ClickMap()
    if not _isMove and IsExpedition() then
        if UICamera.currentTouch.current.layer == CS.NameToLayer("MainUI") or UICamera.currentTouch.current.layer == 0 then
            ExpeditionCancle()
        end
    end
end

function map.ClickOptionBtn(lb)
    if _clickCity == nil then return end
    local tmp = lb.param
    if tmp == 0 then -- 详情
       Win.Open("PopCityInfo", _clickCity.sn)
    elseif tmp == 1 then -- 开发
       Win.Open("PopCityUpgrade", _clickCity.sn)
    elseif tmp == 2 then -- 副本
       Win.Open("PopHistory", _clickCity.sn)
    elseif tmp == 3 then -- 移动/攻占
       Win.Open("PopSelectHero", { SelectHeroFor.Pve, function (hs) ExpeditionBegin(hs, _clickCity) end, _clickCity.IsOwn and _clickCity.sn or 0 })
    end
    coroutine.start(ExitButtons)
end

--点击城池直接打开选将界面
function map.ClickCity(lb)
    local dat = _items[lb.gameObject]
    if dat.IsOwn or dat.sn ~= user.gmMaxCity + 1 then
        return
    end
    if IsExpedition() then ExpeditionTo(dat) end
    print("11111111111111    ",kjson.print(user.LastBattleHero))
    Win.Open("PopSelectHero", { SelectHeroFor.Pve, user.LastBattleHero, 
        function (hs) 
            user.LastBattleHero = hs 
            ExpeditionBegin(hs, dat) 
        end })
end

function map.ClickPrevLevel()
    if user.gmLv > 1 then LoadMap(user.gmLv - 1) end
end

function map.ClickNextLevel()
    local tmp = DB.GetGmLv((user.gmLv + 1 > DB.maxGmLv) and DB.maxGmLv or (user.gmLv + 1))
    if user.hlv < tmp.unlockLv then
        ToolTip.ShowPopTip( L("下一关卡需要主城[FF0000]"..tmp.unlockLv .."级[-]"))
        return
    end

    if user.gmLv < Mathf.Min(user.gmMaxLv, DB.maxGmLv) then LoadMap(user.gmLv + 1) end
end

--[Comment]
--接引MainUI下的Box点击事件
--征战宝箱领取
function map.ClickBox(boxRw)
    if boxCount >= boxRw.needConut and boxRw.isGet ~= 2 then
        SVR.ExpeditionBox(user.gmLv,"get",boxRw.boxSn,function(t)
        if t.success then
            local boxDt = SVR.datCache
            boxCount = boxDt.count
            boxRws = boxDt.boxRws
            print("征战宝箱领取   ", kjson.print(boxDt.rw))
            user.SyncReward(boxDt.rw)
            RefreshBox()
        end
    end)
    else
        Win.Open("PopRwdPreview",boxRw.rws)
    end
end


