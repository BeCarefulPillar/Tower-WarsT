local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil

local _war = nil
local _sub = nil
local _dat = nil
local _battleWin = false

local _items = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref

    c:BindFunction(
    "OnInit",
    "OnEnter",
    "ClickFight",
    "ClickItemGoods",
    "ClickSD",
    "OnDispose",
    "OnUnLoad"
    )
end

local function UpdateInfo()
    _ref.lab_sp_war.text = tostring(user.GetPropsQty(DB_Props.TIAO_ZHAN_LING))
end

local function Despawn(its)
    if its then
        for i, v in ipairs(its) do
            v.go:SetActive(false)
        end
    end
end

local function BuildTreasure()
    if _war and _war.rws and #_war.rws then
        _items = _items or { }
        Despawn(_items)
        for i, v in ipairs(_war.rws) do
            if not _items[i] then
                _items[i] = ItemGoods(_ref.rewardGrid:AddChild(_ref.item_goods, string.format("goods_%02d", i)))
                _items[i].go.transform.localScale = Vector3(0.8, 0.8, 0.8)
                _items[i].go.luaBtn.luaContainer = _body
            else
                _items[i].go:SetActive(true)
            end
            _items[i]:Init(v)
        end
        _ref.rewardGrid.repositionNow = true
    end
end

--[Comment]
--是否通关次关卡
local function isPass(sn)
    if _dat and _dat.record then
        for i, v in ipairs(_dat.record) do
            if v == sn then
                return true
            end
        end
    end
    return false
end

local function isAllPass()
    if _sub then
        for i, v in ipairs(_sub) do
            if not isPass(v.sn) then
                return false
            end
        end
    end
    return true
end

local function BuildItems()
    for i, v in ipairs(_sub) do
        if isPass(v.sn) and user.vip >= 5 then
            _ref.btnFight:ChildWidget("Label").text = L("扫 荡")
            _ref.btnFight:SetClick(_w.ClickSD)
        else
            _ref.btnFight:ChildWidget("Label").text = L("挑 战")
            _ref.btnFight:SetClick(_w.ClickFight)
        end
        local len = #v.npc
        for j, u in ipairs(_ref.heros) do
            if j <= len then
                u:SetActive(true)
                local hd = DB.GetHero(v.npc[j])
                u:ChildWidget("name").text = hd.nm
                u:ChildWidget("hero"):LoadTexAsync(ResName.HeroIcon(hd.img))
            else
                u:SetActive(false)
                u:ChildWidget("name").text = ""
                u:ChildWidget("hero"):UnLoadTex()
            end
        end
    end
    _ref.heroGrid:Reposition()
    _ref.heroGrid.repositionNow = true
end

function _w.OnInit()
    local iv = type(_w.initObj) == "number" and _w.initObj or 0
    if iv <= 0 and user.battleRet and user.battleRet.kind == 2 then
        iv = DB.GetWarSub(user.battleRet.sn).warSN
        _battleWin = user.battleRet.result == 1
    end
    _war = DB.GetWar(iv)
    _sub = DB.GetWarSubs(iv)

    SVR.GetWarInfo("inf", function(t)
        if t.success then
            --stab.S_WarInfo
            _dat = SVR.datCache
        end
    end )

    UpdateInfo()
    BuildTreasure()
    BuildItems()
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end

function _w.ClickSD()
    local sn = _sub and _sub[1] and _sub[1].sn or 0
    if sn > 0 then
        SVR.GetWarInfo("lst|" .. sn, function(t)
            if t.success then
                UpdateInfo()
                table.print("",SVR.datCache)
                PopRewardShow.Show(SVR.datCache.rws)
            end
        end )
    end
end

function _w.ClickFight()
    if user.GetPropsQty(DB_Props.TIAO_ZHAN_LING) > 0 then
        Win.Open("PopSelectHero", {
            SelectHeroFor.War,
            function(hs)
                local sn = _sub and _sub[1] and _sub[1].sn or 0
                if sn > 0 and #hs > 0 then
                    SVR.WarReady(sn, hs, function(t)
                        if t.success then
                            table.print("svr", SVR.datCache)
                            Win.Open("WinBattle", SVR.datCache)
                        end
                    end )
                end
            end
        } )
    else
        ToolTip.ShowPopTip(L("你的挑战令不够！"))
    end
end

function _w.OnEnter()
    if _battleWin then
        Invoke( function()
            UpdateInfo()
            if isAllPass() and user.vip >= 5 then
                _ref.btnFight:ChildWidget("Label").text = L("扫 荡")
                _ref.btnFight:SetClick(_w.ClickSD)
            else
                _ref.btnFight:ChildWidget("Label").text = L("挑 战")
                _ref.btnFight:SetClick(_w.ClickFight)
            end
        end , 0.6)
    end
end

function _w.OnDispose()
    _battleWin = false
    Despawn(_items)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _war = nil
        _sub = nil
        _dat = nil
        _items = nil
        --package.loaded["Game.PopWarDetail"] = nil
    end
end

--[Comment]
--
PopWarDetail = _w