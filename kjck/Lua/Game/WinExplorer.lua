local Resources = UnityEngine.Resources
local Font = UnityEngine.Font
local insert = table.insert
local m_pcpg = math.PathControlPointGenerator
local m_interp = math.Interp


WinExplorer = { }

local _body = nil
WinExplorer.body = _body

local _ref = nil
local data = { }
local map = nil
local scrollView 
local mySelf
local others ={ }
local mapData = nil
--[Comment]
--城池显示的图片
local sps = {}
local floor = nil

--是否进入了下一层
local fChanged = false

local _chatPop = nil
local _cahtPopIvk = nil
local leftGrid
local itemH
local itemP
local topGrid
local othersNm
local arrow
local showOther = true

local mPlayer
local otherPlayer = { }

local _pathNode = nil
local _pathDis = nil
local _pathDim = 0
local _mPath = nil
local request = 0
local _percent = 0
local _index = 2
local mCity = nil
local movePath = nil
local _clickcity = nil
local _tws = nil
local _twa = nil
local fighthero

--检测玩家位置是否重叠,重叠时只显示自己的头像
local function CheckPos()
    if #otherPlayer > 0 then
        for i=1, #otherPlayer do
            local go = otherPlayer[i]
            local pos = go.transform.localPosition
            if pos == mPlayer.transform.localPosition then go:SetActive(false) end
        end
    end
end

local function Reset()
    _index = 2
    _mPath = nil
    _movePath = nil
    _percent = 0
end

local function Move()
    if _mPath == nil or request > os.time() then return end
    if _index > #_mPath then Reset() return end

    if _percent < 1 then
        _percent = math.min(_percent + Time.unscaledDeltaTime * 0.25, 1)
        return
    end
    
    _percent = 1
    request = os.time() + 2
    SVR.GveMove(fighthero, data.infos[_mPath[_index]].csn, function(result)
        requst = 0
        if result.success then
            if fChanged then
                fChanged = false
                Reset()
                return
            end

            local city = SVR.datCache
            if city.status == 3 then 
                ToolTip.ShowPopTip("城池正在战斗中")
                Reset()
                return
            end

            mCity = _mPath[_index]
            _index = _index + 1
            _percent = 0 
            movePath = nil
            if _index <= #_mPath then return end
            Reset()
            CheckPos()
            if city.status == 1 then return end
            SVR.GveBattleReady(data.infos[mCity].csn, fighthero, function(task)
                if task.success then
                    local dat = SVR.datCache
                    Win.Open("WinBattle", dat)
                    if data.infos[mCity].marked == 0 and data.infos[mCity].citytype == 1 then 
                        ToolTip.ShowPopTip(L("已触发城池陷阱:[FF0000]") .. data.infos[mCity].intro .. "[-]") 
                    end
                end
            end)
        elseif result.code ~= 0 then
            result.hideErr = true
            if fChanged then
                fChanged = false
                mPlayer.transform.localPosition = mapData.city[mySelf.csn].pos
            else
                if isString(result.data) then ToolTip.ShowPopTip(ColorStyle.Warning(result.data)) end
                mPlayer.transform.localPosition = mapData.city[_mPath[_index -1]].pos
            end
        end
        Reset()
    end)
end

local function CalculatePath()
    local city, path = data.infos, DB_GveData.path
    _pathDim = #DB_GveData.city

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

    for x, y in ipairs(path) do
        x, y = y.c1, y.c2
        var = city and city[x].visible == 1 and city[y].visible == 1 and city[x].status == 1 and city[y].status == 1 and 1 or 13
        _pathDis[(x - 1) * _pathDim + y], _pathDis[(y - 1) * _pathDim + x] = var, var
    end

    if _pathNode == nil then _pathNode = { } end
    for i = 1, dim2 do _pathNode[i] = ((i - 1) % _pathDim) + 1 end
    
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
    local city = data.infos

    local path = { from }

    print("from" .. from .. ",to" .. to)

    local tmp = _pathNode[(from - 1) * _pathDim + to]
    print("tmp", tmp)
    while tmp ~= to do
        var = city[tmp]
        if var == nil or var.visible == 0 or var.status ~= 1 then
            ToolTip.ShowPopTip(L("城池不可到达!"))
            return
        end
        insert(path, tmp)
        tmp = _pathNode[(tmp - 1) * _pathDim + to]
    end
    insert(path, to)
    return path
end

local function GetPosition(mData)
    if _mPath ~= nil then
        if movePath == nil then
            local f = mCity 
            local t = _mPath[_index]
            local paths = mData.path
            local city = mData.city
            for _, p in pairs(paths) do
                if p.c1 == f and p.c2 == t then
                    movePath = m_pcpg(p.pos)
                    break
                elseif p.c2 == f and p.c1 == t then
                    movePath = m_pcpg(p.pos, true)
                    break
                end
            end
            if movePath == nil then
                movePath = m_pcpg({city[mCity].pos, city[_mPath[_index]].pos})
            end
            
        end
        return Vector3(m_interp(movePath, _percent))
    else
        local p = mData.city[mCity].pos
        return Vector3(p.x, p.y)
    end
end

local function SetPath(p)
    _mPath = p
end

local function ExitButtons()
    _clickcity = nil
    _tws:Play(false)
    _twa:Play(false)
    coroutine.wait(0.1)
    _cityButtos:SetActive(false)
end

--加载地图
local function ShowMap()
    if map == nil then
        local p = AM.LoadPrefab("map_explorer_1")
        if p and p ~= nil then
            map = scrollView:ChildWidget("background"):AddChild(p, "map")
        end
    end

    if map ~= nil then 
        mapData = DB_GveData
        floor.text = "第".. number.ToCnString(data.floor) .."层"
        if mapData and mapData.city then
            if #sps > 0 then table.clear(sps) end
            local citys = mapData.city
            local atlas = Resources.Load("Atlas/atlas_map", typeof(UIAtlas))
            for i=1, #citys do
                local city = data.infos[i]
                if sps[i] == nil then
                    local sp = map:AddWidget(typeof(UISprite), "city_"..i)
                    sp.atlas = atlas
                    sp.spriteName = "city_2_1"
                    sp.color = Color.gray
                    local spd = sp:GetAtlasSprite()
                    sp.width, sp.height = spd.width, spd.height
                    sp.transform.localPosition = mapData.city[i].pos
                    sp.autoResizeBoxCollider = true;
                    sp.depth = 5
                    local cld = sp:AddCmp(typeof(UnityEngine.BoxCollider))
                    cld.center = Vector3.zero
                    cld.size = Vector3(spd.width, spd.height, 0)
                    local btn = sp:AddCmp(typeof(LuaButton))
                    btn.luaContainer = _body
                    btn:SetClick("ClickCity", city)
                    table.insert(sps, sp)
                end
                if city.citytype == 2 then sps[i].spriteName = "city_2_3" end

                local lbl = sps[i]:AddWidget(typeof(UILabel), "n_"..i)
                lbl.trueTypeFont = AM.mainFont
                lbl.text = data.infos[i].sn .. "号城"
                lbl.fontSize = 20
                lbl.transform.localPosition = Vector3(0,68,0)
                if city.status == 1 then lbl.color = Color.green
                else lbl.color = Color.white end
                lbl:SetActive(true)
            end

            coroutine.start(ExitButtons)
        end
    end
end

--自已上阵的武将
local function RefreshHero()
    if leftGrid.transform.childCount > 0 then leftGrid:DesAllChild() end

    for i=1, 3 do 
        local go = leftGrid:AddChild(itemH, "hero_"..i)
        local dat = mySelf.atk[i]
        local hero = user.GetHero(dat.csn) 

        local sld = go:Child("food")
        if hero == nil then
            go.luaBtn:SetClick("SelectHero")
            sld:SetActive(false)
        else
            go.luaBtn.enabled = false
            local ico = go:ChildWidget("hero", typeof(UITexture))
            local status = go:ChildWidget("status",typeof(UILabel))
            ico:LoadTexAsync(ResName.HeroIcon(hero.img))
            sld:SetActive(true)
            sld:GetCmp(typeof(UISlider)).value = dat.hp / dat.maxHP
            if dat.status == 0 then 
                status.text = L("待命中")
            elseif dat.status == 2 then
                status.text = L("战斗中")
            elseif dat.status == 3 then
                status.text = L("已阵亡")
            end
            status:SetActive(true)
        end

        go:SetActive(true)
    end

    leftGrid:Reposition()
    local sv = map.transform.parent.parent
    EF.MoveSVTo(sv, mapData.city[mySelf.csn].pos, true)
end
--队友上阵的武将
local function UpdateOthersHero()
    for i=1, #topGrid do
        local grid = topGrid[i]
        if grid.transform.childCount > 0 then grid:DesAllChild() end
    end

    for i= 1, #others do
        local info = others[i]
        local name = othersNm[i]
        name.text = info.nick
        local grid = topGrid[i]
        for i=1, 3 do
            local go = grid:AddChild(itemH, "hero_".. i)
            go.transform.localScale = Vector3(0.8, 0.8, 0.8)
            local sld = go:Child("food")
            local dat = info.atk[i]
            if dat.dbsn ~= nil and dat.dbsn > 0 then
                local ico = go:ChildWidget("hero", typeof(UITexture))
                local status = go:ChildWidget("status",typeof(UILabel))
                local hero = DB.GetHero(dat.dbsn)
                ico:LoadTexAsync(ResName.HeroIcon(hero.img))
                sld:SetActive(true)
                sld:GetCmp(typeof(UISlider)).value = dat.hp / dat.maxHP
                if dat.status == 0 then 
                    status.text = L("待命中")
                elseif dat.status == 2 then
                    status.text = L("战斗中")
                elseif dat.status == 3 then
                    status.text = L("已阵亡")
                end
                status:SetActive(true)
            else
                sld:SetActive(false)
            end
            go:SetActive(true)
        end
        grid:Reposition()
    end
end

--更新队友的位置
function WinExplorer.RefreshOthersPos(psn, from, to)
    for i=1, #others do
        local other = others[i]
        local p = otherPlayer[i]
        if other.psn == psn then
            p:SetActive(true)
            EF.Move(p.gameObject, 0.5, mapData.city[to].pos)
            CheckPos()
        end
    end
end

--显示玩家位置
local function ShowPlayerPos()
    local depth = 150 
    local players = data.members
    if #otherPlayer > 0 then table.clear(otherPlayer) end
    if #others > 0 then table.clear(others) end 
    for i=1, #players do
        depth = depth + 1
        local go  = map:AddChild(itemP,"player_".. i)
        local ava = go:GetCmp(typeof(UIMeshTexture))
        local name = go:GetCmpInChilds(typeof(UILabel), false)
        local frame = go:ChildWidget("frame")
        ava:LoadTexAsync(ResName.PlayerIcon(players[i].ava))
        ava.depth = depth
        frame.depth = depth + 1 
        name.text = players[i].nick
        go.transform.localPosition = mapData.city[players[i].csn].pos
        go:SetActive(true)

        if players[i].psn == tonumber(user.psn) then
            mPlayer = go
            mySelf = players[i]
        else
            table.insert(otherPlayer, go)
            table.insert(others, players[i])
        end
    end

    CheckPos()
end
--选择上阵武将
function WinExplorer.SelectHero()
    local heros = {}
    local atk = mySelf.atk
    for i=1, #atk do 
        local h = user.GetHero(atk[i].csn)
        if h ~= nil then table.insert(heros, h) end
    end

    Win.Open("PopSelectHero", {SelectHeroFor.GVE, function(slt)
        if #slt > 0 then
            SVR.GveSetHero(slt, function(result)
                if result.success then
                    local res = SVR.datCache
                    local members = res.members
                    for i=1, #members do
                        if members[i].psn == tonumber(user.psn) then
                            mySelf = members[i]
                            break
                        end
                    end
                    RefreshHero()
                end
            end)
        end
    end, heros})
end
--头像及货币显示信息
local function UpdateInfo()
    CalculatePath()

    local ava = _ref.avatar
    local name = _ref.playerName
    local vip = _ref.vip
    local vippro = _ref.vipPro
    local gold = _ref.gold
    local diamond = _ref.rmb
    local scouts = _ref.Scouts
    local elite = _ref.elite
     
--    local members = data.members
--    for i=1, #members do
--        if tonumber(user.psn) == members[i].psn then mySelf = members[i]
--        else table.insert(others, members[i]) end
--    end

    mCity = mySelf.csn
    ava:LoadTexAsync(ResName.PlayerIconMain(mySelf.ava))
    name.text = mySelf.nick
    gold.text = mySelf.gold
    diamond.text = mySelf.diamond
    scouts.text = mySelf.scouts
    elite.text = mySelf.elite
    vip.text = user.vip
    if user.vip < DB.maxVip then
        local exp = DB.GetVip(user.vip + 1).exp
        vippro.value = user.vipExp / exp
    else
        vippro.value = 1
    end

    RefreshHero()
    if #others > 0 then UpdateOthersHero() end
end
--更新自己的位置
local _update = UpdateBeat:CreateListener(function()
    if _mPath ~= nil then
        Move()
        mPlayer.transform.localPosition = GetPosition(mapData)
    end
end)

--新消息
local _onNewChat = UpdateBeat:CreateListener(function()
    if _chatPop and _body.activeSelf and PopChat == nil or not PopChat.isOpen and #user.chats > 0 then
        local d = user.chats[#user.chats]
        _chatPop.color = ColorStyle.Chat(d.chn)
        _chatPop.text = "[" .. ChatChn.Name(d.chn) .. "]" .. (d.nick and d.nick ~= "" and d.nick .. ":" or "") .. (d.text or "")
        EF.FadeIn(_chatPop, 0.3)
        if _cahtPopIvk then
            _cahtPopIvk:Reset(nil, 3)
        else
            _cahtPopIvk = Invoke(function() EF.FadeOut(_chatPop, 0.3) end, 3)
        end
    end
end)

function WinExplorer.OnLoad(c)
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "ClickReport", "ClickCity", "ClickLeave", "OnDispose", "OnUnLoad")
    
    _chatPop = _ref.chatpop
    scrollView = _ref.scrollView
    floor = _ref.floor
    leftGrid = _ref.leftgrid
    itemH = _ref.gveHero
    itemP = _ref.taghero
    topGrid = _ref.playerHero
    othersNm = _ref.heroName
    _cityButtos = _ref.citybuttons
    arrow = _ref.arrow
    _tws = _cityButtos:GetCmp(typeof(TweenScale))
    _twa = _cityButtos:GetCmp(typeof(TweenAlpha))
    _btns = _ref.btns
    for i=1, #_btns do _btns[i]:SetClick("ClickOptionBtn", i) end

    UpdateBeat:AddListener(_update)
    OnNewChat:AddListener(_onNewChat)
end

function WinExplorer.OnInit()
    local o = WinExplorer.initObj
    Win.ExitAllWin("WinExplorer")
    if o ~= nil and type(o) == "table" then
        data = o
        ShowMap()
        ShowPlayerPos()
        UpdateInfo()
    else
        SVR.GveEnter(function(result)
            if result.success then
                data = SVR.datCache
                ShowMap()
                ShowPlayerPos()
                UpdateInfo()
            end
        end)
    end
    
end

function WinExplorer.RefreshInfo(d)
    local flr = data.floor
    data = d
    if data.floor ~= flr then fChanged = true end
    local members = data.members
    if #others > 0 then table.clear(others) end
    for i=1, #members do
        if tonumber(user.psn) == members[i].psn then mySelf = members[i]
        else table.insert(others, members[i]) end
    end
    UpdateOthersHero()

    if fChanged then
        Destroy(map.gameObject)
        ShowMap()
        ShowPlayerPos()
        UpdateInfo()
    else
        UpdateInfo()
    end
end

function WinExplorer.ClickArrow()
    local parent = arrow.transform.parent
    local tp = parent:GetCmp(typeof(TweenPosition))
    local ta = parent:GetCmpInChilds(typeof(TweenAlpha))
    if not showOther then
        showOther = true
        tp:Play(true)
        ta:Play(true)
        arrow.transform.localRotation = Quaternion.Euler(0,0,0)
    elseif showOther then
        showOther = false
        tp:Play(false)
        ta:Play(false)
        arrow.transform.localRotation = Quaternion.Euler(0,0,180)
    end
end

--点击头像
function WinExplorer.ClickAvatar()
    Win.Open("PopShowAchi")
end
--点击说明
function WinExplorer.ClickHelp()
    Win.Open("PopRule", DB_Rule.GVERule)
end
--点击聊天
function WinExplorer.ClickChat()
    Win.Open("PopChat")
end
--点击充值
function WinExplorer.ClickRecharge()
    Win.Open("PopRecharge")
end
--点击斥候
function WinExplorer.ClickScouts()
    local parent = _ref.Scouts.transform.parent
    local tip = parent:Child("tip").gameObject
    coroutine.start(function()
        TweenAlpha.Begin(tip, 0.3, 1)
        coroutine.wait(2)
        TweenAlpha.Begin(tip, 1, 0)
    end)
end
--点击精锐斥候
function WinExplorer.ClickElite()
    local parent = _ref.elite.transform.parent
    local tip = parent:Child("tip").gameObject
    coroutine.start(function()
        TweenAlpha.Begin(tip, 0.3, 1)
        coroutine.wait(2)
        TweenAlpha.Begin(tip, 1, 0)
    end)
end

local function ShowCityButtons(ic)
    if ic == nil then if _cityButtos.activeSelf then coroutine.start(ExitButtons) end return end

    if _clickcity == ic and _cityButtos.activeSelf then coroutine.start(ExitButtons) end

    _clickcity = ic
    -- 按钮复位
    _cityButtos.transform.localPosition = mapData.city[ic.sn].pos + Vector3(35, 0, 0)
    _cityButtos.transform.localScale = Vector3.zero
    -- 整体动画
    _tws:ResetToBeginning()
    _twa:ResetToBeginning()
    _cityButtos:SetActive(true)
    _tws:Play(true)
    _twa:Play(true)
end

function WinExplorer.ClickCity(ic)
    local dat = ic
    if dat.status == 3 then ToolTip.ShowPopTip("城池正在战斗中") return end
    ShowCityButtons(dat)
end

function WinExplorer.ClickOptionBtn(idx)
    if _clickcity == nil then return end

    if idx == 1 then --行军
        if _mPath ~= nil then return end
        if _clickcity.status == 3 then ToolTip.ShowPopTip("城池正在战斗中") return end

        if mySelf.atk[1].csn ~= nil then
            local heros = {}
            local cnt = #mySelf.atk
            for i=1, cnt do
                local h = user.GetHero(mySelf.atk[i].csn)
                if h ~= nil then table.insert(heros, h) end
            end

            Win.Open("PopSelectHero", {SelectHeroFor.GveMove, function(slt)
                if #slt > 0 then
                    fighthero = slt
                    SVR.GveAttack(fighthero, _clickcity.csn, function(result)
                        if result.success then
                            SetPath(GetPathNodes(mCity, _clickcity.sn))
                            coroutine.start(ExitButtons)
                        end
                    end)
                end
            end, heros})
        else
            ToolTip.ShowPopTip(L("请先设置上阵武将"))
            return
        end
    elseif idx == 2 then -- 侦察
        if _mPath ~= nil then return end
        if _clickcity.status == 1 then MsgBox.Show(L("此城已被攻占!")) return end
        Win.Open("PopGveCityInfo", _clickcity.csn)
        coroutine.start(ExitButtons)
    elseif idx == 3 then -- 召集
        if _mPath ~= nil then return end
        if mySelf.atk[1].csn == nil then ToolTip.ShowPopTip(L("请先设置上阵武将")) return end
        local sns = {}
        for _, h in pairs(mySelf.atk) do
            if h.status ~= 3 then table.insert(sns, h.csn) end
        end
        if #sns <= 0 then ToolTip.ShowPopTip(L("没有可战斗的武将")) return end
        SVR.GveAttack(sns, _clickcity.csn, function(result)
            if result.success then
                fighthero = sns
                SetPath(GetPathNodes(mCity, _clickcity.sn))
                coroutine.start(ExitButtons)
            end
        end)
    end 
end

function WinExplorer.ClickReport()
    Win.Open("PopGveReport", data.gsn)
end

function WinExplorer.ClickLeave()
    MsgBox.Show("请确认是否放弃地宫探秘?", "取消,确定", function(bid) 
        if bid == 1 then 
            SVR.GveLeave(function(result)
                if result.success then
                    if not MainMap.isOpen then Win.Open("MainMap") end
                    _body:Exit()
                else
                    result.hideErr = true
                    if not MainMap.isOpen then Win.Open("MainMap") end
                    _body:Exit()
                end
            end)
        end
    end)
end

function WinExplorer.OnDispose()
    _mPath = nil
    _pathDim = 0
    _pathDis = nil
    _pathNode = nil
    _percent = 0
    _index = 2
    sps = { }
    mySelf = nil
    others = { }

    UpdateBeat:Remove(_update)
    OnNewChat:Remove(_onNewChat)
end

function WinExplorer.OnUnLoad()
    map = nil
    _body = nil
end