local _w = { }

local _body = nil
local _ref = nil


local _pveLvImtes = nil
local _pveLvBg = nil
local _pveLvSelect = nil

local _view = -1
local _pveLv = 0
local _bg = nil

local _onChangeView = nil

local _res = nil
local _dats = nil
local _tms = nil
local _dt = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c, { n = L("主城"), i = true, r = DB_Rule.Home })
    _dt = 0
    for i, b in ipairs(_ref.tabs) do
        b.param = i - 1
    end
end

local function DestroyItem(its)
    if its then
        for i, v in ipairs(its) do
            Destroy(v)
        end
    end
end

local function DisposeObj()
    _pveLv = 0
    _ref.panelEffect:DesAllChild()
end

function _w.OnWrapGridInitOcc(item, i)
    local dat = _dats[i + 1]
    item:Child("bg"):SetActive(i % 2 == 0)
    item.luaBtn:SetClick(_w.ClickPvpCity, dat.sn)
    item:ChildWidget("name").text = dat.nm
    item:ChildWidget("pos").text = tostring(dat.sn)
    item:ChildWidget("level").text = "LV:" .. dat.lv
    -- 玩家主城，乘以比例
    item:ChildWidget("crop").text =
    tostring(dat.kind == 0 and math.ceil(dat.crop * DB.param.pvpCrop / 100) or dat.crop)
    item:ChildWidget("unit").spriteName =
    dat.kind == 1 and "sp_silver" or "sp_gold"
    local tm = item:ChildWidget("time")
    _tms[i+1] = tm

    tm.text = dat.tm>0 and TimeClock.TimeToString(dat.tm) or "--:--:--"

    return true
end

function _w.OnWrapGridInitAff(item, i)
    local dat = _dats[i + 1]
    item.luaBtn:SetClick(_w.ClickPveCity, dat.sn)
    item:ChildWidget("name").text = dat.nm
    item:ChildWidget("level").text = "LV:" .. dat.lv

    local crop = item:ChildWidget("crop_unit")
    local f = dat.tm < 28800
    crop.text = f and dat.crop .. " / " .. DB.param.cdCityCrop / 60 .. L("分钟") or L("储量已达上限")
    crop.color = f and Color.white or Color.green
    item:Child("sp_silver"):SetActive(f)

    item:ChildBtn("btn_dev"):SetClick( function(sn)
        Win.Open("PopCityUpgrade", sn)
    end , dat.sn)

    item:Child("bg"):SetActive(i % 2 == 0)
    local t = DB.param.cdCityCrop - dat.tm
    local p = t > 0
    _ref.btnSearch:SetActive(not p)
    local label = item:ChildWidget("time")
    label.text = p and TimeClock.TimeToString(t) or math.modf(user.GetPveCity(dat.sn).HasCrop) .. "  "
    label:Child("sp_silver"):SetActive(not p)
    _tms[i+1] = label
    return true
end

local function BuildAff()
    if _dats then
        _tms = { }
        _ref.gridAff:Reset()
        if _dats[1] and _dats[1].sn == 1 then
            table.remove(_dats, 1)
        end
        _ref.gridAff.realCount = #_dats

        if _pveLvImtes and _pveLvImtes[_pveLv] then
            if _pveLvSelect then
                _pveLvSelect.spriteName = "btn_08"
            end
            _pveLvSelect = _pveLvImtes[_pveLv].transform:GetChild(0).widget
            _pveLvSelect.spriteName = "btn_09"
        end
    end
end

local function BuildOcc()
    if _dats then
        _tms = { }
        _ref.gridOcc:Reset()
        _ref.gridOcc.realCount = #_dats
    end
end

local function ChangePveLv(lv,force)
    lv = math.clamp(lv, 1, user.gmMaxLv)
    if _pveLv == lv and not force then
        return
    end
    _pveLv = lv
    _ref.btnSearch:SetActive(false)
    SVR.GetTerritoryList("pve|" .. _pveLv, function(t)
        if t.success then
            local res = SVR.datCache
            _dats = res and res.cities
            BuildAff()
        end
    end )
end

local _strs = {
    [1] = L("主城产出金币:"),
    [2] = L("占领其他主城产出金币:"),
    [3] = L("占领金矿产出金币:"),
    [4] = L("占领银矿产出银币:"),
    [5] = L("占领药园产出医疗点:"),
    [6] = L("占领农田产出兵力:"),
    [7] = L("占领温泉产出体力:"),
}

local function IEChangeView()
    for i, v in ipairs(_ref.viewPanel) do
        if v.activeSelf then
            TweenAlpha.Begin(v, 0.2, 0)
        end
    end

    coroutine.wait(0.21)

    DisposeObj()

    for i, v in ipairs(_ref.viewPanel) do
        v:SetActive(i - 1 == _view)
    end

    for i, v in ipairs(_ref.tabs) do
        local f = _view ~= i - 1
        v.isEnabled = f
        v.label.color = f and ColorStyle.TabColorGlay or Color.white
        v.label.effectColor = f and Color.black or ColorStyle.OutLight
    end

    if _view == 0 then
        -- 内政
        _pveLvImtes = { }
        _ref.v0_leftPanel:DesAllChild()
        for i = 1, user.gmMaxLv do
            local lab = _ref.v0_leftPanel:AddWidget(typeof(UILabel), string.format("lv_%02d", i))
            _pveLvImtes[i] = lab
            lab.pivot = UIWidget.Pivot.Left
            lab.trueTypeFont = AM.mainFont
            lab.supportEncoding = false
            lab.applyGradient = false
            lab.overflowMethod = UILabel.Overflow.ShrinkContent
            lab.width = 145
            lab.height = 80
            lab.depth = 15
            lab.fontSize = 28
            lab.text = DB.GetGmLv(i).nm
            lab.pivot = UIWidget.Pivot.Center
            local t = lab.transform
            t.localPosition = Vector3(78,t.localPosition.y,0)

            NGUITools.AddWidgetCollider(lab.cachedGameObject, true)
            lab.gameObject:AddCmp(typeof(LuaButton)).luaContainer = _body
            lab.gameObject:GetCmp(typeof(LuaButton)):SetClick(_w.ClickPveLv, i)
            lab.gameObject:AddCmp(typeof(UIDragScrollView)).scrollView = _ref.v0_leftPanel

            _pveLvBg = _pveLvImtes[i]:AddWidget(typeof(UISprite), "bg")
            _pveLvBg.atlas = AM.mainAtlas
            _pveLvBg.spriteName = "btn_08"
            _pveLvBg.type = UIBasicSprite.Type.Sliced
            _pveLvBg.width = 145
            _pveLvBg.height = 80
            _pveLvBg.depth = 0
            _pveLvBg.cachedTransform.parent = _pveLvImtes[i].transform
            _pveLvBg.cachedTransform.localScale = Vector3.one
            _pveLvBg.cachedTransform.localPosition = Vector3.zero
        end

        _ref.v0_leftPanel:GetCmp(typeof(UIGrid)).repositionNow = true
        _ref.v0_leftPanel:ConstraintPivot(UIWidget.Pivot.Top, true)
        ChangePveLv(1,true)
        TweenAlpha.Begin(_ref.viewPanel[1], 0.2, 1)
    elseif _view == 1 then
        -- 外交
        BuildOcc()
    elseif _view == 2 then
        -- 科技
        if _res then
            local flag = false
            local t = math.min(#_res, 4)
            _ref.v2_Panel:DesAllChild()
            for i = 1, t do
                if _res[i] > 0 then
                    flag = true
                end
                local go = _ref.v2_Panel:AddChild(_ref.item_lab, string.format("Label_%02d", i))
                go:SetActive(true)
                go.widget.text = _strs[i] .. _res[i]
            end
            _ref.btnLevy:GetCmp(typeof(UIButton)).isEnabled = flag
            _ref.btnLevy:SetActive(true)
            _ref.v2_Panel:GetCmp(typeof(UIGrid)):Reposition()
            _ref.v2_Panel:GetCmp(typeof(UIGrid)).repositionNow=true
            _ref.v2_Panel:ConstraintPivot(UIWidget.Pivot.Top, true)
            TweenAlpha.Begin(_ref.viewPanel[3], 0.2, 1)
        end
    end
end

local function Update()
    _dt = _dt + Time.deltaTime
    if _dt >= 1 then
        _dt = _dt - 1
        if _view == 0 then
            if _dats and _tms then
                for i, d in ipairs(_dats) do
                    d.tm = d.tm + 1
                end
                for i, v in pairs(_tms) do
                    local t = DB.param.cdCityCrop - _dats[i].tm
                    local f = t > 0
                    _ref.btnSearch:SetActive(not f)
                    v.text = f and TimeClock.TimeToString(t) or math.modf(user.GetPveCity(_dats[i].sn).HasCrop) .. "  "
                    v:Child("sp_silver"):SetActive(not f)
                end
            end
        elseif _view == 1 then
            if _dats and _tms then
                for i, d in ipairs(_dats) do
                    d.tm = d.tm - 1
                end
                for i, v in pairs(_tms) do
                    local t = _dats[i].tm
                    v.text = t>0 and TimeClock.TimeToString(t) or "--:--:--"
                end
            end
        end
    end
end
local _update = UpdateBeat:CreateListener(Update)
function _w.OnEnter()
    UpdateBeat:AddListener(_update)
end
function _w.OnExit()
    UpdateBeat:RemoveListener(_update)
end

local function StopChangeView()
    if _onChangeView then
        coroutine.stop(_onChangeView)
        _onChangeView = nil
    end
end

local function OnChangeView()
    StopChangeView()
    _onChangeView = coroutine.start(IEChangeView)
end

local function ChangeView(v,force)
    if _view == v and not force then
        return
    end
    _view = v

    _dats = nil
    _tms = nil
    _res = nil

    if v == 0 then
        -- 内政
        OnChangeView()
    elseif v == 1 then
        -- 外交
        SVR.GetTerritoryList("pvp", function(t)
            if t.success then
                local res = SVR.datCache
                _dats = res and res.cities
                local c = _dats and table.findall(_dats,function(d)
                    return d.kind==0
                end)
                _ref.pvpCityCount.text = L("占领主城:") .. #c .. "/" .. user.Home.pvpQty
                OnChangeView()
            end
        end )
    elseif v == 2 then
        -- 征收
        SVR.GetCropInfo( function(t)
            if t.success then
                _res = SVR.datCache
                OnChangeView()
            end
        end )
    end
end

local function RefreshHomeInfo()
    _ref.homeInfos[1].text = tostring(user.hlv)
    local home = user.Home
    if user.hlv < DB.maxHlv then
        local remainExp = user.exp - home.cost
        _ref.slider_hExp.value = remainExp / home.nxtExp
        _ref.lab_homeExp.text = remainExp .. "/" .. home.nxtExp
    else
        _ref.slider_hExp.value = 1
        _ref.lab_homeExp.text = L("已达最高等级")
    end

    _ref.homeInfos[2].text = "" .. home.crop
    _ref.homeInfos[3].text = "" .. home.lead
    _ref.homeInfos[4].text = "" .. home.hp
    _ref.homeInfos[5].text = "" .. home.tp
    _ref.homeInfos[6].text = "" .. user.hlv
    _ref.homeInfos[7].text = "" .. user.hlv

    _ref.lables[1].text = L("主城")
    _ref.lables[2].text = L("产出")
    _ref.lables[3].text = L("内 政")
    _ref.lables[4].text = L("外 交")
    _ref.lables[5].text = L("征 收")
    _ref.lables[6].text = L("一键收获")
    _ref.lables[7].text = L("升级")
    _ref.lables[8].text = L("征 收")
    -- _ref.lables[9].text = L("")
    _ref.lables[10].text = L("出征武将数")
    _ref.lables[11].text = L("血库上限")
    _ref.lables[12].text = L("兵营上限")
    _ref.lables[13].text = L("武将等级上限:")
    _ref.lables[14].text = L("装备等级上限:")


    SVR.GetCropInfo( function(t)
        if t.success then
            _res = SVR.datCache
            local d = 0
            for i, v in ipairs(_res) do
                d = d + v
            end
            _ref.tabs[3]:Child("effect"):SetActive(d > 0)
        end
    end )
end

function _w.OnInit()
    ChangeView(0)
    RefreshHomeInfo()
end

-- [Comment]
-- 征收
function _w.ClickLevy()
    SVR.GetCrop( function(t)
        if t.success then
            user.changed = true
            _res = nil
            ChangeView(2,true)
            _ref.tabs[3]:Child("effect"):SetActive(false)
        end
    end )
end

-- [Comment]
-- 一键收获
function _w.ClickSearch()
    SVR.CitySearchBatch(0, function(t)
        if t.success then
            for i, v in ipairs(_dats) do
                v.tm = 0
            end
            BuildAff()
            -- MainPanel.Instance.UpdateBtn1Key();
        end
    end )
end

--[Comment]
--在城池升级界面（PopCityUpgrade）调用，用来刷新主城里的信息
local function RefreshCityInfo()
    _dats = nil
    ChangePveLv(_pveLv,true)
end
_w.RefreshCityInfo = RefreshCityInfo

--[Comment]
--一键开发
function _w.ClickDeve()
    _ref.panelEffect:DesAllChild()
    if not _dats or #_dats<1 then
        return
    end
    --如果是-1说明都是满级城池，如果是0说明玩家钱不够升级，大于0可以升级
    local cost = -1
    for i,p in ipairs(_dats) do
        if p.lv<10 then
            if cost<=0 then
                cost = 0
            end
            local upCost = user.GetPveCity(p.sn).upCost
            cost = cost + upCost
            if user.coin<cost then
                cost=cost-upCost
            end
        end
    end

    if cost<0 then
        ToolTip.ShowPopTip(L("城池等级已达最高级！"))
        return
    elseif cost==0 then
        ToolTip.ShowPopTip(L("资源不足，无法开发城池！"))
        return
    else
        local str = ColorStyle.Good( string.format(L("银币%d"),cost))
        str = L("本次开发将会对当前列表的所有城池开发一次，预计将会消耗 ") .. str .. L(" 是否需要继续?")
        MsgBox.Show(str,L("取消,确定"),function(bid)
            if bid==1 then
                SVR.CityOneUpgrade(_pveLv,function(t)
                    if t.success then
                        local go = _ref.panelEffect:AddChild(_ref.ef_deve)
                        Invoke(function()
                            if notnull(go) then
                                Destroy(go)
                            end
                        end,1)
                        RefreshCityInfo()
                    end
                end)
            elseif bid==0 then
                    --if (User.TutorialSN == 1 && User.HighCity < Config.T_LEVEL)
                    --{
                        --User.TutorialStep = (int)Tutorial.Step.TutStep24;
                        --Tutorial.PlayTutorial(true, btnDeve.transform);
                    --}
            end
        end)
    end
end

function _w.ClickChangeView(i)
    ChangeView(i)
end

function _w.ClickPveLv(i)
    ChangePveLv(i)
end

function _w.ClickPvpCity(i)
end

function _w.OnDispose()
    _ref.btnUpgrade.isEnabled = false
    _view = -1
    _dats = nil
    _tms = nil
    _res = nil
    StopChangeView()
    DisposeObj()
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _bg:dispose()
        _bg = nil
    end
end

-- [Comment]
-- 主城
PopHome = _w