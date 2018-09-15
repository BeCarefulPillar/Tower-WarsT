require "Game/ItemHeroSelected"
local ipairs = ipairs

local _w = { }
--[Comment]
--boss战
WinBoss = _w

local _body = nil
local _ref = nil
local _bg = nil

local _dat = nil
local _dt = 0
local _persons = nil
local _allys = nil
local _heros = nil

local _panelPerson = nil
local _panelAlly = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c,{n=L("Boss战"),i=true,r=DB_Rule.Boss})

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "OnEnter",
    "OnExit",
    "OnDispose",
    "ClickPersonHelp",
    "ClickHero",
    "ClickAllyHelp",
    "ClickClearCD",
    "ClickAddAtt",
    "ClickFight",
    "OnUnLoad"
    )

    _panelPerson = {
        UIGrid = _ref.panelPerson,
        UIScrollView = _ref.panelPerson:GetCmp(typeof(UIScrollView)),
    }
    _ref.panelPerson = nil

    _panelAlly = {
        UIGrid = _ref.panelAlly,
        UIScrollView = _ref.panelAlly:GetCmp(typeof(UIScrollView)),
    }
    _ref.panelAlly = nil

    _heros = { }
    for i, v in ipairs(_ref.heros) do
        _heros[i] = ItemHeroSelected(v)
    end
    _ref.heros = nil
end

local function RefreshHero()
    local hds = user.LastBossBattleHero
    for i, v in ipairs(_heros) do
        if v:CheckStatus(i, SelectHeroFor.Boss) then
            v.SelectedHero = hds[i] or nil
        end
    end
end

local function RefreshAttInfo()
    _ref.attLab.text = L("属性加成:") .. _dat.att .. "%"
    _ref.attPrice.text = tostring(_dat.attPrice)
end

local function RefreshTimeInfo()
    if _dat.openTm > 0 then
        _ref.time.text = L("活动开始倒") .. TimeClock.TimeToSmart(_dat.openTm)
    elseif _dat.endTm > 0 then
        _ref.time.text = L("活动结束倒") .. TimeClock.TimeToSmart(_dat.endTm)
    elseif _ref.time.text == L("活动结束") then
        _ref.time.text = L("活动结束")
        RefreshData()
    end
    _ref.cdLab.text = L("冷却时间:") .. TimeClock.TimeToMS(_dat.coldTm)
    _ref.cdPrice.text = tostring(_dat.coldTm * _dat.cdUnitPrice)

    _ref.btnCD.isEnabled = _dat.coldTm > 0
    _ref.atkQty.text = L("可攻打次数：") .. _dat.atkQty
    local f = _dat.openTm <= 0 and _dat.endTm > 0 and _dat.coldTm <= 0 and _dat.atkQty > 0
    _ref.btnFight.isEnabled = f
    _ref.btnAtt.isEnabled = f
end

local function Update()
    _dt = _dt + Time.deltaTime
    if _dt >= 1 then
        _dt = _dt - 1
        _dat.openTm = math.max(_dat.openTm - 1, 0)
        _dat.endTm = math.max(_dat.endTm - 1, 0)
        _dat.coldTm = math.max(_dat.coldTm - 1, 0)
        RefreshTimeInfo()
    end
end

local _update = UpdateBeat:CreateListener(Update)

function _w.OnEnter()
    UpdateBeat:AddListener(_update)
end

function _w.OnExit()
    UpdateBeat:RemoveListener(_update)
end

local function Despawn(items)
    if items then
        for i, v in ipairs(items) do
            v:SetActive(false)
        end
    end
end

local function InitItem(item, index, rank, name, score)
    if item ~= _ref.myRank and item ~= _ref.myAllyRank then
        item:ChildWidget("rank_bg").spriteName = "sp_rank_" .. rank
    end
    local labs = item:GetComponentsInChildren(typeof(UILabel))
    labs[0].text = rank <= 0 and "--" or tostring(rank)
    labs[1].text = name
    labs[2].text = score <= 0 and "--" or(score > 9999999 and(math.toint(score / 10000) .. L("万")) or tostring(score))
    if index <= 3 then
        labs[0].color = Color(1, 224 / 255, 146 / 255)
        labs[1].color = Color(1, 224 / 255, 146 / 255)
        labs[2].color = Color(1, 224 / 255, 146 / 255)
    else
        labs[0].color = Color(191 / 255, 169 / 255, 113 / 255)
        labs[1].color = Color(191 / 255, 169 / 255, 113 / 255)
        labs[2].color = Color(191 / 255, 169 / 255, 113 / 255)
    end
end

local function InitItemDat(item, index, dat)
    InitItem(item, index, index, dat.nm, dat.score)
end

local function RefreshInfo()
    --WinBg.RefreshInfo();
    RefreshTimeInfo()
    RefreshAttInfo()
    InitItem(_ref.myRank, 0, _dat.myRank, user.nick, _dat.myScore)

    if user.ally.nsn > 0 then
        InitItem(_ref.myAllyRank, 0, _dat.myAllyRank,
        string.isEmpty(user.ally.gnm) and L("我的联盟") or user.ally.gnm,
        _dat.myAllyScore)
    else
        InitItem(_ref.myAllyRank, 0, -1, "--", -1)
    end

    _persons = _persons or { }
    Despawn(_persons)
    for i, v in ipairs(_dat.personRank) do
        if not _persons[i] then
            _persons[i] = _panelPerson.UIGrid:AddChild(_ref.item_rank, string.format("item_%02d", i))
        end
        InitItemDat(_persons[i], i, _dat.personRank[i])
        _persons[i]:SetActive(true)
    end
    _panelPerson.UIGrid.repositionNow = true
    _panelPerson.UIScrollView:ConstraintPivot(UIWidget.Pivot.Top, true)
    _panelPerson.UIScrollView.enabled = false

    _allys = _allys or { }
    Despawn(_allys)
    for i, v in ipairs(_dat.allyRank) do
        if not _allys[i] then
            _allys[i] = _panelAlly.UIGrid:AddChild(_ref.item_rank, string.format("item_%02d", i))
        end
        InitItemDat(_allys[i], i, _dat.allyRank[i])
        _allys[i]:SetActive(true)
    end
    _panelAlly.UIGrid.repositionNow = true
    _panelAlly.UIScrollView:ConstraintPivot(UIWidget.Pivot.Top, true)
    _panelAlly.UIScrollView.enabled = false
end

local function RefreshData()
    SVR.GetBossInfo( function(t)
        if t.success then
            --stab.S_BossInfo
            _dat = SVR.datCache
            user.bossTm = _dat.openTm
            RefreshInfo()
        end
    end )
end

function _w.OnInit()
    RefreshHero()
    RefreshData()
end

function _w.ClickHero()
    print("11111111111111    ",kjson.print(user.LastBossBattleHero))
    Win.Open("PopSelectHero", {
        SelectHeroFor.Boss, user.LastBossBattleHero, function(hs)
            user.LastBossBattleHero = hs
            RefreshHero()
        end
    } )
end

function _w.ClickPersonHelp()
    Win.Open("PopRule", DB_Rule.BossPerson)
end

function _w.ClickAllyHelp()
    Win.Open("PopRule", DB_Rule.BossAlly)
end

function _w.ClickClearCD()
    --int rmb = User.Rmb;
    SVR.BossOption("cd", function(t)
        if t.success then
            --TdAnalytics.OnPurchase(L.Get("B战消除CD"), 1, rmb - User.Rmb);
            _dat.coldTm = 0
            RefreshTimeInfo()
        end
    end )
end

function _w.ClickAddAtt()
    --int rmb = User.Rmb;
    SVR.BossOption("gw", function(t)
        if t.success then
            --TdAnalytics.OnPurchase(L.Get("Boss战鼓舞"), 1, rmb - User.Rmb);
            --stab.S_BossOption
            local res = SVR.datCache
            _dat.att = res.att
            _dat.attPrice = res.attPrice
            RefreshAttInfo()
        end
    end )
end

function _w.ClickFight()
    local list = { }
    for i, v in ipairs(_heros) do
        if v.IsSelected then
            table.insert(list, v.SelectedHero.sn)
        end
    end
    if #list > 0 then
        SVR.BoosReady(list, function(t)
            if t.success then
                Win.Open("WinBattle", SVR.datCache)
            end
        end )
    else
        ToolTip.ShowPopTip(ColorStyle.Warning(L("先配置武将")))
        _w.ClickHero(nil)
    end
end

function _w.OnDispose()
    _dt = 0
    Despawn(_persons)
    Despawn(_allys)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _persons = nil
        _ally = nil
        _bg:dispose()
        _bg = nil
    end
end