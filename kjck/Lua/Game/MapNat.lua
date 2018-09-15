require "Data/DB_NatData"

local type = type
local ipairs = ipairs
local insert = table.insert

local _w = { isOpen = false }
--[Comment]
--国战地图
MapNat = _w

local _scale = 1.33333333333
--[Comment]
--国战放大倍数
_w.Scale = _scale

local _md = DB_NatData

local _body = nil

local _map = nil

local _itemCity = nil
local _tagHero = nil
local _arrRaid = nil
local _tagAtk = nil
local _tagNpc = nil
local _arr_bar_path = nil

local _mapView = nil
--[Comment]
--放大1.333333倍,,将地图上生成的东西都放到这个下面
local _mapViewItems = nil
local _cityMask = nil

local _ui = nil
local _uiHero = nil

local _gridTex = nil

local _coEnter = nil
local _repeatQty = 0

local _pathNode = nil
local _pathDis = nil
local _pathDim = 0

local _clickCity = 0
-- 0=起始城池 之后=可达城池
local _raidData = nil

local _cityItems = nil

local _heroQty = 0
local _heros = nil
local _heroTrail = nil

local _fightCityQty = 0
local _fightCityEffect = nil
local _qstTags = nil
local _flagTags = nil
local _raidArr = nil
--[Comment]
--NPC图标  蛮族图标
local _npcTags = nil
--[Comment]
--蛮族进攻路线
local _barPath = nil

local function UIHeroAlive(h) return h and notnull(_body) and notnull(h.icon) and _body.status ~= WIN_STAT.EXITED end

local function UIHeroDataChange(h, d)
    h.status.text = PY_NatHero.GetStatusDesc(h.ndat.CurStatus)
    h.rest:SetActive(h.ndat.food <= 0)
    h.food.value = h.ndat.food / h.dat.MaxHP
    h.fatig.text = h.ndat.fatig
    if h.ndat.fatig >= 60 then
        h.fatig.color = Color.green
    elseif h.ndat.fatig < 20 then
        h.fatig.color = Color.red
    else
        h.fatig.color = Color.yellow
    end
end

function _w.OnLoad(c)
    _body = c
    local var = c.gos
    _ui = { go = var[0] }
    _itemCity = var[1]
    _tagHero = var[2]
    _arrRaid = var[3]
    _tagAtk = var[4]
    _tagNpc = var[5]
    _mapViewItems = var[6]
    _arr_bar_path = var[7]
    var = c.cmps
    _mapView = var[0]
    _cityMask = var[1]
    _ui.flagTm = var[2]
    _ui.flagOn = false
    --实力
    _ui.score = var[3]
    --用户名
    _ui.nm = var[4]
    --头像
    _ui.ava = var[5]
    --VIP十位
    _ui.vip1 = var[6]
    --VIP个位
    _ui.vip2 = var[7]
    --等级
    _ui.lv = var[8]
    --体力
    _ui.vit = var[9]
    --体力条
    _ui.vitPro = var[10]
    --粮草
    _ui.food = var[11]
    --酒
    _ui.wine = var[12]
    --钻石
    _ui.rmb = var[13]

    _uiHero = { }
    local btns = c.btns
    for i = 1, btns.Length do
        var = btns[i - 1]
        _uiHero[i] =
        {
            btn = var,
            icon = var:ChildWidget("hero"),
            status = var:ChildWidget("status"),
            food = var:Child("food", typeof(UISlider)),
            rest = var:Child("rest").gameObject,
            mask = var:ChildWidget("mask"),
            fatig = var:ChildWidget("fatig"),

            alive = UIHeroAlive,
            OnDataChange = UIHeroDataChange,
        }
        var.param = i
    end

    c:BindFunction("OnUnLoad", "OnUnLoad", "OnEnter", "OnDispose",
        "PressCity", "ClickCity", "OnViewMove", "ClickUIHero", "ClickMapMain",
        "ClickNat", "ClickAvatar", "ClickAddRmb", "ClickAddFood", "ClickVip",
        "ClickHero", "ClickDeploy", "ClickQuest", "ClickTech", "ClickMine",
        "ClickMinMap", "ClickReport", "ClickTips", "ClickRank", "ClickFlag",
        "ClickLevy", "ClickBlood", "ClickAddWine")
end

function _w.OnUnLoad(c)
    if _body == c then
        _body, _ui = nil, nil
        _map, _mapView,_mapViewItems, _cityMask = nil, nil, nil, nil
        _itemCity, _tagHero, _arrRaid, _tagAtk = nil, nil, nil, nil

        _cityItems, _heros, _heroTrail = nil, nil, nil
        _fightCityEffect, _qstTags, _flagTags = nil, nil, nil
        _raidArr, _npcTags, _barPath = nil, nil, nil

        if _uiHero then
            for _, h in ipairs(_uiHero) do
                if h.ndat then h.ndat = DataCell.DataChange(h.ndat, nil, h) end
                if h.dat then h.dat = DataCell.DataChange(h.dat, nil, h) end
            end
            _uiHero = nil
        end
    end
end

local function CalculateBattlePath()
    local city, path = user.nat.city, DB_NatData.path
    _pathDim = #DB_NatData.city

    if _pathDis == nil then _pathDis = { } end

    local dim2 = _pathDim * _pathDim
    local var, d = 1, _pathDim + 1
    for i = 1, dim2 do
        if i == var then
            _pathDis[i] = 0
            var = var + d
        else
            _pathDis[i] = 999
        end
    end
--    for i = 1, _pathDim do
--        for j = 1, _pathDim do
--            _pathDis[(i - 1) * _pathDim + j] = i == j and 0 or 9999
--        end
--    end

    local nsn = user.nat.nsn
    
    for x, y in ipairs(path) do
        x, y = y.c1, y.c2
        var = city and nsn == city[x].def and nsn == city[y].def and city[x].atk <= 0 and city[y].atk <= 0 and 1 or 150
        _pathDis[(x - 1) * _pathDim + y], _pathDis[(y - 1) * _pathDim + x] = var, var
    end

    if _pathNode == nil then _pathNode = { } end
    for i = 1, dim2 do _pathNode[i] = ((i - 1) % _pathDim) + 1 end
--    for i = 1, _pathDim do
--        for j = 1, _pathDim do
--            _pathNode[(i - 1) * _pathDim + j] = j
--        end
--    end
    
    local km, im, jm = 0, 0, 0
    for k = 1, _pathDim do
        im = 0
        for i = 1, _pathDim do
            jm = 0
            for j = 1, _pathDim do
                d = _pathDis[im + k] + _pathDis[km + j]
                var = im + j
                if d < _pathDis[var] then
                    _pathDis[var] = d
                    _pathNode[var] = _pathNode[im + k]
                end
                jm = jm + _pathDim
            end
            im = im + _pathDim
        end
        km = km + _pathDim
    end
end

local function GetPathNodes(from, to)
    if from == to or from == nil or to == nil then return end
    local nsn = user.nat.nsn
    local city = user.nat.city
    local var = city[from]
    if var == nil or var.def ~= nsn or var.atk > 0 then return end

    local path = { from }

    print("from" .. from .. ",to" .. to)

    local tmp = _pathNode[(from - 1) * _pathDim + to]
    while tmp ~= to do
        var = city[tmp]
        if var == nil or var.def ~= nsn or var.atk > 0 then
            ToolTip.ShowPopTip(L("城池不可到达!"))
            return nil
        end
        insert(path, tmp)
        tmp = _pathNode[(tmp - 1) * _pathDim + to]
    end
    insert(path, to)
    return path
end

local function CheckEffectVisual()
    if _fightCityQty > 1 then
        local pos = _mapViewItems.transform.localPosition
        local var
        for i = 2, _fightCityQty do
            var = _fightCityEffect[i].cachedTransform.localPosition + pos
            _fightCityEffect[i]:SetActive(math.abs(var.x) < 550 and math.abs(var.y) < 330)
        end
    end
end

local function UpdateUserInfo()
    print("UpdateUserInfo    ", kjson.print(user.nat))
    _ui.score.text = user.score
    _ui.nm.text = user.nick
    _ui.ava:LoadTexAsync(ResName.PlayerIconMain(user.ava))
    _ui.lv = user.hlv
    _ui.vit.text = user.vit.."/"..user.MaxVit
    _ui.vitPro.value = user.vit / user.MaxVit
    _ui.food.text = user.nat.food .."/"..user.nat.foodMax
    _ui.wine.text = user.nat.wine
    _ui.rmb.text = user.rmb
    --VIP等级显示
    if user.vip > 9 then
        _ui.vip1.gameObject:SetActive(true)
        _ui.vip1.spriteName = "lab_chat_vip_" .. user.vip / 10
        _ui.vip2.spriteName = "lab_chat_vip_" .. user.vip % 10
        _ui.vip1.transform.localPosition = Vector3.New(-4, 1, 0)
        _ui.vip2.transform.localPosition = Vector3.New(3, 1, 0)
    else
        _ui.vip1.gameObject:SetActive(false)
        _ui.vip2.spriteName = "lab_chat_vip_" .. user.vip
        _ui.vip2.transform.localPosition = Vector3.New(0, 1, 0)
    end
end

--[Commen]
--更新城池信息
local function UpdateInfo()
    local city = user.nat.city
    print("更新城池信息    ", kjson.print(city))
    if city then
        local var = user.MaxFood
        _fightCityQty = 0
        if _cityItems == nil then _cityItems = { } end
        if _fightCityEffect == nil then _fightCityEffect = { } end
        for i, c in ipairs(_md.city) do
            if _cityItems[i] == nil then
                var = _map:AddChild(_itemCity, "city_" .. i).widget
                _cityItems[i] = var
                var.luaBtn.param = i
                var.cachedTransform.localPosition = c.flag
                local spd = var.atlas:GetSprite("city_" .. c.typ)
                var = var:GetCmp(typeof(UE.BoxCollider))
                var.center = c.pos - c.flag
                if spd then var.size = Vector3(spd.width, spd.height, 0) end
                var:SetActive(true)
            end
            var = city[i]
            _cityItems[i].spriteName = "flag_c_" .. (var and var.def or 0)
            if var.atk and var.atk > 0 then
                _fightCityQty = _fightCityQty + 1
                if _fightCityQty > #_fightCityEffect then
                    if #_fightCityEffect > 0 then
                        _fightCityEffect[_fightCityQty] = UICopy.Copy(_fightCityEffect[1], _map)
                    else
                        _fightCityEffect[_fightCityQty] = _map:AddChild(AM.LoadPrefab("ef_fight"), "ef_fight").widget
                    end
                else
                    _fightCityEffect[_fightCityQty]:SetActive(true)
                end
                _fightCityEffect[_fightCityQty].cachedTransform.localPosition = c.pos
            end
        end

        if _fightCityQty < #_fightCityEffect then
            for i = _fightCityQty + 1, #_fightCityEffect do _fightCityEffect[i]:SetActive(false) end
        end
            
        CalculateBattlePath()

        CheckEffectVisual()
    end

    _w.CheckRaid(_raidData and #_raidData > 0 and _raidData[1] or nil)
end

local function UpdateHero()
    local heros = user.nat.heros
    local qty = heros and #heros or 0
    if _heros == nil then
        _heros, _heroTrail = { }, { }
    end
    print("UpdateHero   ",kjson.print(heros[1]))
    if qty > 0 then
        if _gridTex == nil then _gridTex = GridTexture(128) end
        local depth = 150
        local h, hd, utx = nil, nil, nil
        for i = 1, qty do
            h = _heros[i]
            if h == nil then
                h = _mapViewItems:AddChild(_tagHero, "hero_" .. i).transform
                _heros[i] = h
            end
            h:SetActive(true)
            hd = user.GetHero(heros[i].sn)
            if hd then
                utx = h.widget
                utx.depth, depth = depth, depth + 1
                _gridTex:Add(utx:LoadTexAsync(ResName.HeroIcon(hd.img)))
                utx = h:ChildWidget(0)
                utx.depth, depth = depth, depth + 1
                _gridTex:Add(utx:LoadTexAsync("frame_hero_r"))
            end

            h = _uiHero[i]
            if h then
                h.ndat = DataCell.DataChange(h.hdat, heros[i], h)
                h.dat = DataCell.DataChange(h.dat, hd, h)
                h.food:SetActive(true)
                h.fatig:SetActive(true)
                h.btn:DesChild("lock")
                h.btn.isEnabled = true
--                h.mask.depth, h.mask.height = 6, 12
                h.mask:SetActive(false)
                if hd then _gridTex:Add(h.icon:LoadTexAsync(ResName.HeroIcon(hd.img))) end

                UIHeroDataChange(h)
            end
        end
    end
    if qty < #_heros then
        for i = qty + 1, #_heros do
            _heros[i]:SetActive(false)
        end
    end
    if qty < #_uiHero then
        local h, var = nil, nil
        local max = user.MaxNatHero

        for i = qty + 1, #_uiHero do
            h = _uiHero[i]
            if h.ndat then h.ndat = DataCell.DataChange(h.ndat, nil, h) end
            if h.dat then h.dat = DataCell.DataChange(h.dat, nil, h) end
            if i > max then
                h.btn.isEnabled = false
                var = user.ttl + 1
                for j = var, DB.maxTtl do if i == DB.ttl[j].lead then var = j break end end
                h.status.text = ColorStyle.Warning(L("需") .. DB.GetTtl(var).nm)
                var = h.btn:Child("lock")
                if var == nil then
                    var = h.btn:AddWidget(typeof(UISprite), "lock")
                    var.atlas = AM.mainAtlas
                    var.spriteName = "sp_lock_heroExp"
                    var.depth, var.width, var.height = 8, 100, 100
                    var.transform.localPosition = Vector3(0, 8, 0)

                end
            else
                h.status.text = L("未部署")
                h.btn.isEnabled = true
                h.btn:DesChild("lock")
            end
            h.icon:UnLoadTex()
            h.rest:SetActive(false)
            h.mask.depth, h.mask.height = 4, 92
            h.mask:SetActive(true)
            h.food:SetActive(false)
            h.fatig:SetActive(false)
        end
    end
    _heroQty = qty
end

local function OnHourlyEvent()

end

--加载活动城
local function UpdateAct()
    local var = nil
    local idx = 0
    local city =_md.city

    if _qstTags == nil then _qstTags = { } end
    local tags = user.nat.questCity
    print("questCityquestCity限时任务城池    ", kjson.print(tags))
    if tags then
        for _, c in ipairs(tags) do
            c = city[c]
            if c then
                idx = idx + 1
                if idx > #_qstTags then
                    var = _map:AddChild(_tagAtk, "tag_atk")
                    insert(_qstTags, var)
                else
                    var = _qstTags[idx]
                end
                var.transform.localPosition = c.pos + Vector2(0, 50)
                var:SetActive(true)
            end
        end
    end
    if idx < #_qstTags then
        for i = idx + 1, #_qstTags do
            _qstTags[i]:SetActive(false)
        end
    end
    
    if _flagTags == nil then _flagTags = { } end
    idx = 0
    tags = user.nat.flagCity
    print("flagCityflagCity夺旗战城池    ", kjson.print(tags))
    if tags then
        local arr, tp = nil, nil
        for _, c in ipairs(tags) do
            c = city[c]
            if c then
                idx = idx + 1
                if idx > #_flagTags then
                    if #_flagTags > 0 then
                        var = UICopy.Copy(_flagTags[1], _map)
                        arr = var:Child("arrow")
                        if arr then
                            if tp == nil then
                                tp = _flagTags[1]:Child("arrow", typeof(TweenPosition))
                            end
                            if tp then
                                arr = arr:AddCmp(typeof(TweenPosition))
                                arr.from, arr.to = tp.from, tp.to
                                arr.style = tp.style
                                arr.animationCurve = tp.animationCurve
                                arr.duration = tp.duration
                            end
                        end
                    else
                        var = _map:AddChild(AM.LoadPrefab("ef_nat_flag"), "ef_nat_flag").widget
                    end
                    insert(_flagTags, var)
                else
                    var = _flagTags[idx]
                end
                var.transform.localPosition = c.pos + Vector2(0, 55)
                var:SetActive(true)
            end
        end
    end
    if idx < #_flagTags then
        for i = idx + 1, #_flagTags do
            _flagTags[i]:SetActive(false)
        end
    end
end


--更新蛮族路线
local function UpdateBarInfo()

end

--计算相对角度，to相对于from的角度(Vector3,Vector3)
local function RelativeAngle(from , to)
    --两点的x、y值
    local x = from.x - to.x
    local y = from.y - to.y

    --斜边长度
    local hypotenuse = math.sqrt( math.pow(x, 2) + math.pow(y, 2))

    --求出弧度
    local cos = x / hypotenuse
    local radian = math.acos(cos)

    --用弧度算出角度
    local angle = 180 / ( math.pi / radian)

    if y < 0 then
        angle = -angle
    elseif ((y == 0) and (x < 0)) then
        angle = 180
    end
    return angle
end

--更新NPC
local function UpdateNpc(npcCity)
    if _npcTags == nil then _npcTags = { } end
    if _barPath == nil then _barPath = { } end
    local var
    local nsn = user.nat.nsn
    print("~~~~更新NPC      " ,kjson.print(npcCity))
    print("~~~~更新user.nat.npc      " ,kjson.print(user.nat.npc))
    if npcCity and npcCity.city > 0 then
        --同步单个城池
        var = _npcTags[npcCity.city]
        var = _barPath[npcCity.city]
        if var then CS.DesGo(var) end
        local loadNat, loadLv = 0, 0
        local lvs = { npcCity.wei or 0, npcCity.shu or 0, npcCity.wu or 0 }
        for i, lv in ipairs(lvs) do
            if lv > loadLv and (loadLv == 0 or i ~= nsn) then
                loadNat, loadLv = i, lv
            end
        end
        if loadNat == 0 or loadLv == 0 then return end

        var = _map:AddChild(_tagNpc, "npc_c_" .. loadLv)
        _npcTags[npcCity.city] = var
        var.widget.spriteName = "npc_c_" .. loadLv
        var:ChildWidget("bg").spriteName = "npc_bg_" .. loadLv
    else
        if next(_npcTags) then
            for _, n in pairs(_npcTags) do CS.DesGo(n) end
            _npcTags = { }
        end
        if next(_barPath) then
            for _, n in pairs(_barPath) do 
                for _, p in pairs(n) do
                    CS.DesGo(p) 
                end
            end
            _barPath = { }
        end
        local loadNat, loadLv = 0, 0
        local lvs = { }
        print("~~~~更新user.nat.npc  length      " ,#user.nat.npc)
        if user.nat.npc and #user.nat.npc > 0 then
            for i, c in ipairs(user.nat.npc) do
                loadNat, loadLv = 0, 0
                lvs[1], lvs[2], lvs[3], lvs[4] = c.wei or 0, c.shu or 0, c.wu or 0, c.barAtkCitySn[1] or 0
                for i, lv in ipairs(lvs) do
                    if lv > loadLv and (loadLv == 0 or i ~= nsn) then
                        loadNat, loadLv = i, lv
                    end
                end
                if loadNat > 0 and loadLv > 0 then
                    --生成NPC
                    var = _map:AddChild(_tagNpc, "npc_c_" .. loadLv)
                    _npcTags[c.city] = var
                    var.widget.spriteName = "npc_c_" .. loadNat
                    var:ChildWidget("bg").spriteName = "npc_bg_" .. loadNat
                    var.transform.localPosition = _md.city[c.city].pos + Vector2(0, 10)
                    var:SetActive(true)

                    --生成蛮族路线
                    c.barAtkCitySn = table.unique(c.barAtkCitySn)
                    if #c.barAtkCitySn > 0 then
                        _barPath[c.city] = {}
                        for i,v in ipairs(c.barAtkCitySn) do
                            if v > 0 then
                                var = _map:AddChild(_arr_bar_path, "arr_"..c.city.."_"..v):GetCmp(typeof(UITexture))
                                local fPos = _md.city[c.city].pos
                                local tPos = _md.city[v].pos
                                local angle = RelativeAngle(fPos ,tPos)
                                local dis = Vector2.Distance(fPos, tPos)

                                local num = math.ceil(dis / 20)
                                var.transform.localPosition = fPos
                                var.width = num *20
                                var.transform.localRotation = Quaternion.Euler(0, 0, angle)
                                var:SetActive(true)
                                table.insert(_barPath[c.city],var)
                            end
                        end
                    end
                end
            end
        end
    end
end


local _update = UpdateBeat:CreateListener(function()
    local var = nil
    if _heros then
        local nhs = user.nat.heros
        if _heroQty ~= #nhs then UpdateHero() end
        for i, h in ipairs(nhs) do
            _heros[i].localPosition = h:GetPos()
            if h.CurStatus == PY_NatHero.Status.Move then
                if not _heroTrail[i] then
                    _heroTrail[i] = true
                    var = _heros[i]:ChildWidget("trail")
                    if var then EF.FadeIn(var, 0.2) end
                end
            elseif _heroTrail[i] then
                _heroTrail[i] = false
                var = _heros[i]:ChildWidget("trail")
                if var then EF.FadeOut(var, 0.3) end
            end
        end
    end

    var = user.nat.flagTm.time
    if var > 0 then
        _ui.flagTm.text = TimeClock.TimeToString(var)
        if _ui.flagOn then
            _ui.flagOn = false
            _ui.flagTm.applyGradient = false
        end
    elseif not _ui.flagOn then
        _ui.flagOn = true
        _ui.flagTm.applyGradient = true
        _ui.flagTm.text = L("已开战")
    end

--    var = user.nat.bloodTm.time
--    if var > 0 then
--        _ui.bloodTm.text = TimeClock.TimeToString(var)
--    else
--        _ui.bloodTm.text = ""
--    end
end)

local function CoEnter()
    coroutine.step()
    _body:SetActive(false)
    local atp = StatusBar.ShowR(L("加载中").."...", 60)
    if isnull(_map) then
        local asset = _body:LoadAssetAsync(ResName.MapNat)
        while not asset.isDone do
            atp.process = asset.process
            coroutine.step()
        end
        local go = asset.prefab
        if go then
            _map = _mapViewItems:AddChild(go, ResName.MapNat)
            _mapView:GetCmp(typeof(ClampBackgroundView)).background = _map.transform
            _map.transform.localScale = Vector3.one
        end
    end
    atp:Done()
    if _map then
        _repeatQty = 0
        local var = _map:GetCmp(typeof(DragMapEffect)) or _map:AddCmp(typeof(DragMapEffect))
        var.mainUI = _ui.go
        var.scrollView = _mapView
        UpdateUserInfo()
        UpdateInfo()
        UpdateHero()
        UserDataChange:Add(UpdateUserInfo)
        UpdateNat:Add(UpdateInfo)
        UpdateNatHero:Add(UpdateHero)
        UpdateNatAct:Add(UpdateAct)
        UpdateNatNpc:Add(UpdateNpc)
        SVR.NatOverview()
        SVR.GetNatHero()
        SVR.NatActInfo()
        SVR.NatEnter()
        _w.isOpen = true

        UpdateBeat:AddListener(_update)

        var = DB_NatData.city[PY_Nat.GetCapital(user.nat.nsn)]
        if var then _w.MoveTo(var.pos) end

        coroutine.step()
        coroutine.step()

        EF.FadeIn(_body, 0.3)
        MainUI.ChangeMap(_w)

        Win.Open("MapCloud")
        if MapCloud ~= nil then MapCloud.StartCutMap(true, true) end

        coroutine.wait(0.3)

        _coEnter = nil
        _body.status = WIN_STAT.ENTERED
    else
        _coEnter = nil
        MsgBox.Show(L("资源加载发生错误"), L("重试") .. "," .. L("取消"), function(bid)
            if bid == 0 then
                local asset = AM.GetAsset(ResName.MapNat)
                if asset then asset:Dispose(true) end
                _repeatQty = _repeatQty + 1
                if _repeatQty > 1 and _map == nil then
                    if _repeatQty > 2 then
                        _repeatQty = 0
                        AM.DeleteLocalAsset(ResName.MapNat)
                    else
                        AM.UnloadAssets(100)
                    end
                end

                Win.Open("MapNat")
            end
        end)
        _body:Exit()
    end
end

function _w.OnEnter()
    if _coEnter == nil or coroutine.status(_coEnter) == "dead" then
        _body.status = WIN_STAT.ENTERING
        _coEnter = coroutine.start(CoEnter)
    end
    return false
end

function _w.OnDispose()
    UserDataChange:Remove(UpdateUserInfo)
    UpdateNat:Remove(UpdateInfo)
    UpdateNatHero:Remove(UpdateHero)
    UpdateNatAct:Remove(UpdateAct)
    UpdateNatNpc:Remove(UpdateNpc)

    _clickCity = 0
    _repeatQty = 0
    _fightCityQty = 0
    _heroQty = 0
    _raidData = nil

    UpdateBeat:RemoveListener(_update)

    if _gridTex then
        _gridTex:Dispose()
        _gridTex = nil
    end

    if _w.isOpen then
        _w.isOpen = false
        SVR.NatExit()
    end

    _body:DisposeAsset()

--    Win.ExitWin("PopNatBlood")
end

--[Commnet]
--查找可行进路线
function _w.CheckRaid(from)
    _raidData = (_raidData and #_raidData > 0) and { } or _raidData
    local var = nil
    if from and from > 0 then
        local nsn = user.nat.nsn
        local var = user.nat.city
        _raidData = {}
        for _, p in ipairs(_md.path) do
            local x, y = p.c1, p.c2
            x = x == from and y or (y == from and x or 0)
            if x > 0 and not PY_Nat.IsCapital(x) and var[x] and var[x].def ~= nsn then
                insert(_raidData, x)
            end
        end
        if _raidData and #_raidData > 0 then insert(_raidData, 1, from) end
    end
    local len = _raidData and #_raidData - 1 or 0
    if len > 0 then
        if _raidArr == nil then _raidArr = { } end
        for i = 1, len do
            if i > #_raidArr then
                var = _map:AddChild(_arrRaid, "arr_raid_copy")
                insert(_raidArr, var)
            else
                var = _raidArr[i]
            end
            var.transform.localPosition = _md.city[_raidData[i + 1]].pos
            var:SetActive(true)
        end
    end

    if _raidArr and len < #_raidArr then
        len = len <= 0 and 1 or len
        for i = len, #_raidArr do
            _raidArr[i]:SetActive(false)
        end
    end
end

--[Comment]
--点击弹出按钮
local function OnClickCityButton(id)
    if _md.city[_clickCity] then
        if id == 1 then
            --进军
            id = _clickCity
            if user.nat.IsInBlood then
                ToolTip.ShowPopTip(L("主公，请先暂停血战再发布此命令"))
            else
                Win.Open("PopSelectHero",{SelectHeroFor.NatMove, function(hero)
                    if #hero > 0 then
                        for i = 1, #hero do
                            local ch = user.nat:GetHero(hero[i])
                            if ch ~= nil and ch.CurStatus == PY_NatHero.Status.Idle then
                                ch:SetPath(GetPathNodes(ch.city, id))
                            end
                        end
                        
                    end
                end})
            end
        elseif id == 2 then
            --召集
            print("召集召集召集召集")
--            if user.nat.IsInBlood then
--                ToolTip.ShowPopTip(L("主公，请先暂停血战再发布此命令"))
--            elseif user.nat.heros then
--                for _, h in ipairs(user.nat.heros) do
--                    if h.CurStatus == PY_NatHero.Status.Idle then
--                        h:SetPath(GetPathNodes(h.city, _clickCity))
--                    end
--                end
--            end
            if user.nat.heros then
                for _, h in ipairs(user.nat.heros) do
                    if h.CurStatus == PY_NatHero.Status.Idle then
                        h:SetPath(GetPathNodes(h.city, _clickCity))
                    end
                end
            end
        elseif id == 3 then
            --观战
            Win.Open("WinNatCity", _clickCity)
        elseif id == 4 then
            --计谋
            Win.Open("PopNatProps", _clickCity)
        end
    end
    _clickCity = 0
    _w.CheckRaid(0)
end

function _w.ClickCity(city)
    print("PressCityPressCity    ",kjson.print(city))

    if PopNatBlood and PopNatBlood.isSelectCity() then
        PopNatBlood.SelectCity(city)
    elseif _raidData and #_raidData > 1 then
        for i = 2, #_raidData do
            if _raidData[i] == city then
                Win.Open("PopSelectHero",{SelectHeroFor.NatOption, function(hero)
                    if #hero > 0 then
                        local ch = user.nat:GetHero(hero[1])
                        if ch then
                            ch:SetRaid(city)
                        end
                    end
                end,_raidData[1],true})
                _w.CheckRaid(0)
                return
            end
        end
        _w.CheckRaid(0)
        ToolTip.ShowPopTip(L("该城池不在突袭范围内!"))
    elseif city == _clickCity and PopCityButtons.isOpen then
        _clickCity = 0
    elseif not PY_Nat.IsCapital(city) or city == PY_Nat.GetCapital(user.nat.nsn) then
        _clickCity = city
        if isDebug then
            PopCityButtons.Open(OnClickCityButton, _mapViewItems.transform:TransformPoint(_md.city[city].pos ), L("进军"), L("召集"), L("观战"), not PY_Nat.IsCapital(city) and L("计谋") or nil)
        else
            PopCityButtons.Open(OnClickCityButton, _mapViewItems.transform:TransformPoint(_md.city[city].pos ), L("进军"), L("召集"), not PY_Nat.IsCapital(city) and user.nat:CityIsFight(city) and L("观战") or nil, not PY_Nat.IsCapital(city) and L("计谋") or nil)
        end
    end
end

--长按显示城池阴影
function _w.PressCity(press, city)
    if press then
        city = _md.city[city]
        _cityMask.spriteName = "city_" .. city.typ
        local trans = _cityMask.cachedTransform
        trans.localEulerAngles = Vector3(0, city.rev == 1 and 180 or 0, 0)
        trans.localPosition = city.pos
        _cityMask:MakePixelPerfect()
        _cityMask:SetActive(true)
    else
        _cityMask:SetActive(false)
    end
end

_w.OnViewMove = CheckEffectVisual

function _w.MoveTo(pos, instant)
    if type(pos) == "number" then
        pos = DB_NatData.city[pos]
    end
    if pos and _mapView and _mapView.activeSelf then
        _mapView:MoveTo(pos * _scale, instant ~= false)
    end
end

function _w.LocateToHero(h)
    if h and _body and _body.activeSelf then _w.MoveTo(h:GetPos(), false) end
end

function _w.getViewArea()
    if _mapView then return _mapView:GetScreen() end
    return Vector3.zero, Vector3.zero
end

local _ui_hero_invoke = nil
local function UIHeroCure(h)
    if h.food > 0 and user.nat.food <= 0 then return end
    SVR.NatHeroFood(h.sn, function(t)
        if not t.success and t.code == ERR.LackFood then
            t.hideErr = true
            local btn = ""
            local bv = 0
            if user.nat.buyFoodQty > 0 then btn = btn .. L("购买") .. ","; bv = 1 end
            if user.nat.getFoodQty > 0 then btn = btn .. L("征粮") .. ","; bv = bv + 2 end
            btn = btn .. (btn == "" and L("确定") or L("取消"))
            MsgBox.Show(t.data, function(bid)
                if bid == 0 and (bv == 1 or bv == 3) then
                    _w.ClickAddFood()
                elseif bid == 1 and (bv == 2 or bv == 3) then
                    Win.Open("PopNatMap")
                end
            end)
        end
    end)
end
local function UIHeroOpt(h)
    h = h.ndat
    if h then
        if h.IsFullFood or h.CurStatus == PY_NatHero.Status.Fight then return end
        if CONFIG.tipHeroRest then
            MsgBox.Show(L("是否消耗粮草补满武将血量?"), L("否")..","..L("是"), "{t}"..L("不再提示"), function(bid, tog)
                if bid == 1 then
                    UIHeroCure(h)
                    CONFIG.tipHeroRest = not tog[0]
                end
            end)
        else
            UIHeroCure(h)
        end
    else
        --[待做]
        print("待做待做待做待做待做待做待做待做待做?")
        Win.Open("PopSelectHero", { SelectHeroFor.Nat, function(hs) 
            print("~~~~~~~~~!!!!!!!!!!!!!!!    " , kjson.print(hs))
        end })
    end
end

function _w.ClickUIHero(idx)
    idx = _uiHero and _body and _body.activeSelf and _uiHero[idx] or nil
    if idx == nil then return end
    if idx.ndat then _w.MoveTo(idx.ndat:GetPos(), false) end
    if _ui_hero_invoke and _ui_hero_invoke:isRunning() then
        _ui_hero_invoke:Stop()
        _ui_hero_invoke = nil
        local nh = idx.ndat
        if nh and nh.IsMultiNode then
            MsgBox.Show(string.format(L("停止%s行军\n(到达下个城池后停止移动)"), idx.dat and ColorStyle.Blue(idx.dat:getName()) or ""), L("确定")..","..L("取消"), function(bid)
                if bid == 0 then nh:StopMove() end
            end)
        end
    else
        _ui_hero_invoke = Invoke(UIHeroOpt, 0.2, true, idx)
    end
end

function _w.ClickAvatar() Win.Open("PopShowAchi") end

function _w.ClickVip() Win.Open("PopVip") end

function _w.ClickAddRmb() Win.Open("PopRecharge") end

function _w.ClickAddFood()
    MsgBox.Show(string.format(L("是否花费%s购买%s?\n(今日剩余购买次数:[FFFFB4]%s[-])"), ColorStyle.Rmb(user.nat.buyFoodPrice .. L("积分")), ColorStyle.Food(DB.param.natFood .. L("粮草")), user.nat.buyFoodQty), L("确定")..","..L("取消"), function(bid)
        if bid == 0 then
            SVR.NatFood("buy", function(t)
                if t.success then
                    ToolTip.ShowPopTip(L("粮草") .. ColorStyle.Food("+" .. SVR.datCache.food))
                end
            end)
        end
    end)
end

function _w.ClickAddWine()
    Win.Open("PopBuyWine")
end

function _w.ClickMapMain() Win.ExitAllWin() Win.Open("MainMap") end

function _w.ClickNat() Win.Open("WinCountry") end

function _w.ClickHero() Win.Open("WinHero") end

function _w.ClickDeploy()         
    Win.Open("PopSelectHero", { SelectHeroFor.Nat, function(hs) 
        print("~~~~~~~~~!!!!!!!!!!!!!!!    " , kjson.print(hs))
    end })
 end

function _w.ClickNatDaily() Win.Open("WinCountryActiveBox") end

function _w.ClickQuest() Win.Open("WinQuest", 2) end

function _w.ClickTech() Win.Open("PopNatTech") end

function _w.ClickMine() Win.Open("PopNatMine") end

function _w.ClickMinMap() Win.Open("PopNatMap") end

function _w.ClickReport() Win.Open("WinCountryReport") end


function _w.ClickTips() Win.Open("PopCountryTips") end

--排行榜
--3:攻城略地(夺旗)   5:蛮族入侵  7:攻守兼备(限时) 
function _w.ClickRank() 
    print("攻守兼备 时间7777777",kjson.print(user.atkAndDefTime))
    print("攻守兼备 时间",user.atkAndDefTime.time)
    print("蛮族入侵 时间555555",kjson.print(user.barbarianTime))
    print("蛮族入侵 时间",user.barbarianTime.time)
    print("夺旗战 Time时间3333333",kjson.print(user.flagTm))
    print("夺旗战 Time时间",user.flagTm.time)
    local t = {[3] = user.flagTm.time, [5] = user.barbarianTime.time, [7] = user.atkAndDefTime.time}
    local kind = 3
    local temp = t[3]
    for v,k in pairs(t) do
        if k <= 0 then
            kind = v
            break
        end
        if math.min(temp,k) == k then
            kind = v
        end
    end
    print("kind     ",kind)
    Win.Open("PopNatRankAct", kind) 
end

function _w.ClickFlag() Win.Open("PopNatFlag") end

function _w.ClickLevy() Win.Open("PopLevy") end

function _w.ClickBlood() Win.Open("PopNatBlood") end
