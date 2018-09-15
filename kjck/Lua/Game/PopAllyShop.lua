
local win = { }
PopAllyShop = win

local _body = nil
local _ref = nil

local _item = nil
local _tip = nil
local _grid = nil
--[Comment]
--盟券
local _money = nil
--[Comment]
--联盟币
local _renown = nil
local _rfTime = nil
local _rfPrice = nil

local _btns = nil

local _curData = nil
local _allyData = nil
local _eplData = nil
local _cd = nil
local _canRef = nil
local _gt = nil
-- 0 = 联盟 1 = 军功
local _view = -1

local _update = nil

local function UpdateInfo()  
    if _view == 0 then -- 联盟商城
        _curData = _allyData
        _money.text = _curData.money[5]
        _money:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_acash"
        _renown.text = _curData.money[6]
        _renown:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_ally"
        _rfPrice:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_ally"
    elseif _view == 1 then -- 军功商城
        _curData = _eplData
        _money.text = tostring(user.AMerit)
        _money:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_amerit"
        _renown.text = tostring(user.rmb)
        _renown:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_diamond"
        _rfPrice:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_diamond"
    end
    _rfTime.text = L("自动刷新:")..TimeClock.TimeToString(_curData.rfCD)
    _rfPrice.text = tostring(_curData.rfGold)
end

local function OpenView(v, f)
    v, f = v or 0, f or false
    if _view == v and not f then return end
    _view = v 
    if v == 0 then -- 联盟
        if not _allyData  then win.OnRefreshData(); return end
        _curData =  _allyData
    else -- 军功
        if not _eplData then win.OnRefreshData(); return end
        _curData = _eplData
    end 
    UpdateInfo()
    if _btns then for i = 0, #_btns - 1 do _btns[i + 1]:GetCmp(typeof(UIButton)).isEnabled = _view ~= i end end
    _tip:SetActive(#_curData.goods < 1) 
    _grid:Reset()
    _grid.realCount=#_curData.goods
end

local function RefreshData()
    -- 联盟商城
    if _view == 0 then
        SVR.GetAllyShopInfo(function (r) if r.success then
            _allyData = SVR.datCache
            _cd.time = _allyData.rfCD
            OpenView(0, true)
            if not _canRef then _canRef = true end
        end end)
    -- 军功商城
    elseif _view == 1 then
        SVR.AllyBattleShopInfo(function (r) if r.success then
            _eplData = SVR.datCache
            _cd.time = _eplData.rfCD
            OpenView(1, true)
            if not _canRef then _canRef = true end
        end end)
    end
end

win.OnRefreshData = RefreshData

local function Update()
    if not _cd then return end
    if not isNumber(_cd.time) then _cd.time = tonumber(_cd.time) end 
    _rfTime.text = L("自动刷新:")..TimeClock.TimeToString(_cd.time)
    if _cd.time <= 0 and _canRef then
        _canRef = false
        Invoke(RefreshData, 2, false)
    end
end

function win.OnLoad(c)
    WinBackground(c, {n = "联盟商城"})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "OnDispose", "OnUnLoad", "OnWrapGridInitItem", "OnWrapGridRequestCount",
    "ClickRefresh", "OpenBuyWin", "ClickBuy", "ClickSortTab", "ClickHelp", "ClickMoneyTip", "ClickRenownTip", "ClickItemInfo")

    _tip = _ref.emptyTip
    _grid = _ref.scrollView
    _money = _ref.money
    _renown = _ref.renown
    _rfTime = _ref.rfTime
    _rfPrice = _ref.rfPrice

    _btns = _ref.btnTabs
    if _btns then for i = 0, #_btns - 1 do _btns[i + 1]:SetClick("ClickSortTab", i) end end

    _update = UpdateBeat:CreateListener(Update)
    UpdateBeat:AddListener(_update)
end

function win.OnInit()
    _cd = TimeClock()
    if not _gt then _gt = GridTexture.New(128) end
    if PopAllyShop.initObj ~= nil then OpenView(PopAllyShop.initObj, true)
    else OpenView(0, true) end
end

function win.OnWrapGridInitItem(g, it, i)
    if not it or i < 0 or i >= #_curData.goods then return false end
    i = i + 1
    local data = RW(_curData.goods[i].rw)
    local tmp = it.transform:Find("icon/frame"):GetCmp(typeof(UISprite))
    tmp.spriteName = data.frame
--    tmp.type = data[1] == 7 and UIBasicSprite.Type.Sliced or UIBasicSprite.Type.Simple
    it.transform:Find("name"):GetCmp(typeof(UILabel)).text = data.nm
    it.transform:Find("icon/num"):GetCmp(typeof(UILabel)).text = data.qty
    it.transform:Find("desc"):GetCmp(typeof(UILabel)).text = data[1] == 2 and data.i or ""
    it:GetCmp(typeof(LuaButton)):SetClick("OpenBuyWin",_curData.goods[i])
    tmp = it.transform:Find("icon").gameObject
    ItemGoods.SetEquipEvo(tmp, data.evo, data.rare)
    -- 显示碎片效果
    local tmp1 = tmp.transform:Find("piece")
    if data.isPiece then
        if not tmp1 then
            tmp1 = tmp:AddWidget(typeof(UISprite), "piece")
            tmp1.atlas = AM.mainAtlas
            tmp1.spriteName = "sp_piece"
            tmp1.width, tmp1.height, tmp1.depth = 98, 98, 6
        end
    else
        if tmp1 then Destroy(tmp1.gameObject) end
    end
    -- 加载图标
    if data.dat then
        _gt:Add(tmp:GetCmp(typeof(UITexture)):LoadTexAsync(data.ico))
        tmp:GetCmp(typeof(LuaButton)):SetClick("ClickItemInfo",data)
    else tmp:GetCmp(typeof(UITextureLoader)):Dispose()
    end
    -- 设置价格信息
    data = _curData.goods[i]
    tmp = it.transform:Find("sp_price"):GetCmp(typeof(UISprite))
    tmp1 = it.transform:Find("price"):GetCmp(typeof(UILabel))
    if data.gold > 0 then
        tmp.spriteName = "sp_gold"
        tmp1.text = tostring(data.gold)
    elseif data.soul > 0 then
        if _view  == 0 then tmp.spriteName = "sp_acash"
        elseif _view  == 1 then tmp.spriteName = "sp_soul"
        else tmp.spriteName = "sp_amerit"
        end
        tmp1.text = tostring(data.soul)
    else
        tmp.spriteName = "sp_diamond"
        tmp1.text = tostring(data.rmb)
    end
    -- 设置 VIP 信息
    tmp = it.transform:Find("vip"):GetCmp(typeof(UILabel))
    tmp.color = user.vip < data.vip and Color.red or Color.white
    tmp.text = data.vip > 0 and "VIP:"..data.vip or ""
    it:SetActive(true)
    return true
end


function win.OnDispose()
    if _gt then _gt:Dispose(); _gt = nil end
    if _items then for i = 1, #_items do Destroy(_items[i]) end end
    _view = -1
    _curData = nil
    _allyData = nil
    _eplData = nil
    _canRef = nil
end

function win.OnUnLoad()
    if _update then UpdateBeat:RemoveListener(_update) end
    _body = nil
    _item = nil
    _tip = nil
    _grid = nil
    _money = nil
    _renown = nil
    _rfTime = nil
    _rfPrice = nil
end
---------- 按钮事件
-- 帮助
function win.ClickHelp() Win.Open("PopRule", DB_Rule.AllyShop) end
-- 商店类型
function win.ClickSortTab(lb) OpenView(lb, true) end
-- 商品信息
function win.ClickItemInfo(lb) ToolTip.ShowPropTip(lb.getPropTip()) end

function win.OpenBuyWin(d)
    Win.Open("PopBuyAllyShop", d)
end
-- 购买
function win.ClickBuy(lb)
    if _curData.goods then
        local sn = lb
        for i = 1, #_curData.goods do 
            if _curData.goods[i].sn == sn then
                if _view == 0 then
                    SVR.AllyShopBuy(sn, function (r) if r.success then
                        _allyData = SVR.datCache
                        _cd.time = _allyData.rfCD
                        if #_allyData.goods > 0 then
                            OpenView(_view, true)
                        else
                            Invoke(RefreshData, 0.2, true)
                        end
                    end end)
                    return
                elseif _view == 1 then
                    SVR.AllyBattleShopBuy(sn, function (r) if r.success then
                        _eplData = SVR.datCache
                        _cd.time = _eplData.rfCD
                        if #_eplData.goods > 0 then
                            OpenView(_view, true)
                        else
                            Invoke(RefreshData, 0.2, true)
                        end
                    end end)
                return
                end
            end
        end 
    end
end
-- 刷新
function win.ClickRefresh()
    if _view == 0 then -- 联盟商城
        SVR.AllyShopRefresh(function (r) if r.success then
            _allyData = SVR.datCache
            _cd.time = _allyData.rfCD
            UpdateInfo()
            OpenView(0, true)
        end end)
    elseif _view == 1 then -- 军功商城
        if CONFIG.tipAllyBattleShopRef then
            MsgBox.Show(L("是否消耗钻石刷新？"), L("是")..","..L("否"), L("{t}不再提示"), function (bid,ipt) if bid == 0 then
                CONFIG.tipAllyBattleShopRef = not ipt[0]
                SVR.AllyBattleShopRef(function (r) if r.success then
                    _eplData = SVR.datCache
                    _cd.time = _eplData.rfCD
                    OpenView(1, true)
                end end)
            end end)
        else
            SVR.AllyBattleShopRef(function (r) if r.success then
                _eplData = SVR.datCache
                _cd.time = _eplData.rfCD
                OpenView(1, true)
            end end)
        end
    end
end

--点击盟券提示
function win.ClickMoneyTip()
    ToolTip.ShowToolTip("完成悬赏任务可获得，用于联盟商店对换物品");
end
--点击联盟币提示
function win.ClickRenownTip()
    ToolTip.ShowToolTip("科技中心捐献可获得，用于联盟商店刷新");
end
