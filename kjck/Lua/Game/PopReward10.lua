local Destroy = UnityEngine.Object.Destroy
local BoxCollider = UnityEngine.BoxCollider
local notnull = notnull
local Time = Time

local _w = { }
--[Comment]
--10连抽
PopReward10 = _w

--注释部分为副将功能

local _body = nil
local _ref = nil

local _items = nil
local _curAniObjects = nil
local _curObjsInitPosX = nil
local _isLieuEnable = nil
local _bg = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c, { n = L("寻宝"), i = true })
    _isLieuEnable = false
end

function _w.OnInit()
    _curAniObjects = { }
    _curObjsInitPosX = { }
    SVR.GetColdTime()
    _ref.priceRmb1.text = tostring(DB.param.prRmb1)
    _ref.priceRmb10.text = tostring(DB.param.prRmb10)
    _ref.priceLieu10.text = tostring(DB.param.pr_dehero_10)
    --[[
    _ref.LieuTipUpper.text = string.format(L("再抽[FF0000]%d次必得副将"), user.rewardDhQty)
    ]]

    if _isLieuEnable then
        _ref.rewardLieu:Child("mask"):SetActive(false)
        ref.lieuFree1:SetActive(true)
    else
        _ref.rewardLieu:Child("mask"):SetActive(true)
        _ref.lieuFree1:SetActive(false)
    end

    _ref.rewardGold:SetActive(true)
    _ref.rewardRmb:SetActive(true)
    _ref.ef_mask:SetActive(false)
end

local function Update()
    if user.rw1Tm.time > 0 then
        _ref.goldFree1.text = "[FF0000]" .. TimeClock.TimeToString(user.rw1Tm.time) .. L("[-]后免费")
        _ref.priceGold1.text = tostring(DB.param.prRw1)
    else
        _ref.goldFree1.text = " "
        _ref.priceGold1.text = L("[00FF00]免费")
    end

    if user.rw10Tm.time > 0 then
        _ref.goldFree10.text = "[FF0000]" .. TimeClock.TimeToString(user.rw10Tm.time) .. L("[-]后免费")
        _ref.priceGold10.text = tostring(DB.param.prRw10)
    else
        _ref.goldFree10.text = " "
        _ref.priceGold10.text = L("[00FF00]免费")
    end

    --[[
    if user.drw1Tm.time > 0 then
        --副将一次抽奖
        _ref.lieuFree1.text = "[FF0000]" .. TimeClock.TimeToString(user.drw1Tm.time) .. L("[-]后免费")
        _ref.priceLieu1.text = tostring(DB.param.pr_dehero_1)
    else
        _ref.lieuFree1.text = " "
        _ref.priceLieu1.text = L("[00FF00]免费")
    end
    ]]

    _ref.ef_free:SetActive(user.rw1Tm.time <= 0 or user.rw10Tm.time <= 0)
    --[[
    --副将免费特效
    _ref.ef_lieu_free:SetActive(user.drw1Tm.tm <= 0)
    ]]
end
local _update = UpdateBeat:CreateListener(Update)
function _w.OnEnter()
    UpdateBeat:AddListener(_update)
end
function _w.OnExit()
    UpdateBeat:RemoveListener(_update)
end

local function DisposeObj()
    if _items then
        for go, _ in pairs(_items) do
            Destroy(go)
        end
        _items = nil
    end

    _ref.btnSure:SetActive(false)
    _ref.btnAgain10:SetActive(false)

    EF.DampClear(_ref.rewardGold)
    EF.DampClear(_ref.rewardRmb)
    --[[
    EF.DampClear(_ref.rewardLieu)
    ]]

    --local its = nil
    --its = _ref.rewardGold:GetComponents(typeof(iTween))
    --for i=1,its.Length do
    --    Destroy(its[i-1])
    --end
    --its = _ref.rewardRmb:GetComponents(typeof(iTween))
    --for i=1,its.Length do
    --    Destroy(its[i-1])
    --end
    --[[
    its = _ref._ref.rewardLieu:GetComponents(typeof(iTween))
    for i=1,its.Length do
        Destroy(its[i-1])
    end
    ]]

    for i, v in ipairs(_ref.effects) do
        v:Stop()
    end

    _ref.effects[2]:SetActive(false)
    _ref.effects[5]:SetActive(false)
    _ref.effects[8]:SetActive(false)

    _ref.ef_mask:SetActive(false)
end

function _w.OnDispose()
    _curAniObjects = nil
    _curObjsInitPosX = nil

    DisposeObj()

    _ref.rewardGold:GetCmp(typeof(BoxCollider)).enabled = false
    _ref.rewardGold.transform.localEulerAngles = Vector3(0, 0, 0)

    _ref.rewardRmb:GetCmp(typeof(BoxCollider)).enabled = false
    _ref.rewardRmb.transform.localEulerAngles = Vector3(0, 0, 0)

    --[[
    _ref.rewardLieu:GetCmp(typeof(BoxCollider)).enabled = false
    _ref.rewardLieu.transform.localEulerAngles = Vector3(0, 0, 0)
    ]]

    _ref.btnBuyGold1.isEnabled = true
    _ref.btnBuyGold10.isEnabled = true
    _ref.btnBuyRmb1.isEnabled = true
    _ref.btnBuyRmb10.isEnabled = true
    --[[
    _ref.btnBuyLieu1.isEnabled = true
    _ref.btnBuyLieu10.isEnabled = true
    ]]

    _ref.rewardRmb:SetActive(true)
    _ref.rewardGold:SetActive(true)

    local taGold = _ref.rewardGold:GetCmp(typeof(TweenAlpha))
    local taRmb = _ref.rewardRmb:GetCmp(typeof(TweenAlpha))
    if taGold then
        taGold.value = 1
    end
    if taRmb then
        taGold.value = 1
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _items = nil
        _curAniObjects = nil
        _curObjsInitPosX = nil
        _isLieuEnable = false
        _bg:dispose()
        _bg = nil
        --package.loaded["Game.PopReward10"] = nil
    end
end

--[Comment]
--单抽特效
local function OnShowGold1(rw, tp)
    _ref.btnBuyGold1.isEnabled = false
    _ref.btnBuyRmb1.isEnabled = false
    _ref.btnBuyLieu1.isEnabled = false

    local root = nil
    local ef = nil

    if tp == 1 then
        root = _ref.rewardGold
        ef = _ref.effects[1]
    elseif tp == 2 then
        root = _ref.rewardLieu
        ef = _ref.effects[7]
    else
        root = _ref.rewardRmb
        ef = _ref.effects[4]
    end

    local tmp = root:AddChild(_ref.item_goods, "item_1")
    Destroy(tmp, 3)
    tmp.transform.localPosition = Vector3(0, 14, 0)
    tmp.luaBtn.luaContainer = _body
    tmp:GetCmp(typeof(UIRect)).alpha = 0
    Tools.WidgetsAddDepth(tmp, 20)

    tmp = ItemGoods(tmp)
    tmp:Init(rw)

    coroutine.step()
    coroutine.step()

    PopRewardShow.ShowRare(rw, false)

    ef:Stop()
    ef:Play()

    EF.Alpha(tmp.go, 0.2, 1)

    local t = Time.realtimeSinceStartup + 0.2
    while t > Time.realtimeSinceStartup do
        coroutine.step()
    end
    t = Time.realtimeSinceStartup + 1

    local btn = root:GetCmp(typeof(LuaButton)) or root:AddCmp(typeof(LuaButton))
    btn:GetCmp(typeof(BoxCollider)).enabled = true
    btn:SetClick( function()
        t = 0
    end )

    while t > Time.realtimeSinceStartup do
        coroutine.step()
    end

    Destroy(btn)
    root:GetCmp(typeof(BoxCollider)).enabled = false

    _ref.btnBuyGold1.luaBtn.isEnabled = true
    _ref.btnBuyRmb1.luaBtn.isEnabled = true
    _ref.btnBuyLieu1.luaBtn.isEnabled = true

    if MainUI then
        tmp.go.transform.parent = _body.transform
        local pos = objt(tmp) == DB_Hero and MainUI.btns.hero or MainUI.btns.bag
        EF.MoveTo(tmp.go, "position", pos.transform.position, "time", 0.5)
        EF.ScaleTo(tmp.go, "scale", Vector3(0.5, 0.5, 0.5), "time", 0.5)
        EF.RotateTo(tmp.go, Vector3.zero, 0.5)
    end

    EF.Alpha(tmp.go, 0.3, 0, 0.2)
    coroutine.wait(0.5)
    Destroy(tmp.go)
end

--[Comment]
--十连抽特效
local function OnShow10(rws, tp)
    local len = #rws
    if len <= 0 then
        return
    end
    if len > 10 then
        local rs2 = { }
        for i = 1, len - 10 do
            table.insert(rs2, rws[10 + i])
        end
        PopRewardShow.Show(rs2)
        len = 10
    end
    DisposeObj()
    _ref.ef_mask:SetActive(true)

    _ref.btnBuyGold1:GetCmp(typeof(BoxCollider)).enabled = false
    _ref.btnBuyGold10:GetCmp(typeof(BoxCollider)).enabled = false
    _ref.btnBuyRmb1:GetCmp(typeof(BoxCollider)).enabled = false
    _ref.btnBuyRmb10:GetCmp(typeof(BoxCollider)).enabled = false
    --[[
        _ref.btnBuyLieu1:GetCmp(typeof(BoxCollider)).enabled = false
        _ref.btnBuyLieu10:GetCmp(typeof(BoxCollider)).enabled = false
        ]]

    local ef = nil

    if tp == 1 then
        ef = _ref.grid.transform.parent:AddChild(_ref.ef_reward10_1, "ef_reward10_1")
        _ref.btnAgain10:ChildWidget("sp_price").spriteName = "sp_gold"
        _ref.btnAgain10:ChildWidget("price_10").text = tostring(DB.param.prRw10)
        _ref.btnAgain10:SetClick(_w.ClickBuyGold10)
    elseif tp == 2 then
        ef = _ref.grid.transform.parent:AddChild(_ref.ef_reward10_2, "ef_reward10_2")
    elseif tp == 3 then
        ef = _ref.grid.transform.parent:AddChild(_ref.ef_reward10_3, "ef_reward10_3")
        _ref.btnAgain10:ChildWidget("sp_price").spriteName = "sp_diamond"
        _ref.btnAgain10:ChildWidget("price_10").text = tostring(DB.param.prRmb10)
        _ref.btnAgain10:SetClick(_w.ClickBuyRmb10)
    end

    Tools.WidgetsAddDepth(ef, 30)

    coroutine.step()
    coroutine.step()

    local t = Time.realtimeSinceStartup + 1.6
    while t > Time.realtimeSinceStartup do
        coroutine.step()
    end

    _items = { }
    for i = 1, len do
        local it = ItemGoods(_ref.grid:AddChild(_ref.item_goods, string.format("item_%02d", i)))
        _items[it.go] = it
        it.go.transform.localPosition = Vector3(0, 14, 0)
        it:Init(rws[i])
        it.go.luaBtn.luaContainer = _body
        it.go.widget.alpha = 0
        Tools.WidgetsAddDepth(it.go, 30)

        if it then
            PopRewardShow.ShowRare(rws[i], false)
            TweenAlpha.Begin(it.go, 0.3, 1)

            t = Time.realtimeSinceStartup + 0.05
            while t > Time.realtimeSinceStartup do
                coroutine.step()
            end
            _ref.grid.repositionNow = true
            t = Time.realtimeSinceStartup + 0.02
            while t > Time.realtimeSinceStartup do
                coroutine.step()
            end

            local ef_rs = it.go:AddChild(AM.LoadPrefab("ef_reward_show2"), "ef_reward_show")
            Tools.WidgetsAddDepth(ef_rs, 40)
        end
    end

    t = Time.realtimeSinceStartup + 0.2
    while t > Time.realtimeSinceStartup do
        coroutine.step()
    end

    _ref.btnSure:SetActive(true)
    _ref.btnAgain10:SetActive(true)

    _ref.btnBuyGold1:GetCmp(typeof(BoxCollider)).enabled = true
    _ref.btnBuyGold10:GetCmp(typeof(BoxCollider)).enabled = true
    _ref.btnBuyRmb1:GetCmp(typeof(BoxCollider)).enabled = true
    _ref.btnBuyRmb10:GetCmp(typeof(BoxCollider)).enabled = true
    --[[
        _ref.btnBuyLieu1:GetCmp(typeof(BoxCollider)).enabled = true
        _ref.btnBuyLieu10:GetCmp(typeof(BoxCollider)).enabled = true
        ]]

    if notnull(ef) then
        Destroy(ef)
    end
end

local function OnReward10End(bk)
    bk = bk == nil and true or bk
    _ref.btnSure:SetActive(false)
    _ref.btnAgain10:SetActive(false)
    local t = 0
    if _items then
        for go, v in pairs(_items) do
            if notnull(go) then
                go.transform.parent = _body.transform
                local pos = objt(v.dat) == DB_Hero and MainUI.btns.hero or MainUI.btns.bag
                EF.MoveTo(go, "position", pos.transform.position, "time", 0.5)
                EF.ScaleTo(go, "scale", Vector3(0.5, 0.5, 0.5), "time", 0.5)
                EF.Alpha(go, 0.3, 0, 0.2)
                Destroy(go, 0.6)
            end
        end
        _items = nil
        t = Time.realtimeSinceStartup + 0.3
        while t > Time.realtimeSinceStartup do
            coroutine.step()
        end
    end
end

function _w.ClickBuyGold1()
    --过滤免费
    local isFree = user.rw1Tm.time > 0
    SVR.GetReward10(isFree and 1 or 0, false, function(t)
        if t.success then
            --if (isFree) TdAnalytics.OnPurchase(L.Get("金币单抽"), 1, (double)GameData.GameParam.pr_reward1);
            --stab.S_Reward10
            local rs = SVR.datCache.rws
            if #rs > 0 then
                coroutine.start(OnShowGold1, rs[1], 1)
            end
        end
    end )
end
function _w.ClickBuyGold10()
    local isFree = user.rw10Tm.time > 0
    local isReset = true
    if _ref.btnSure.activeSelf then
        coroutine.start(OnReward10End, false)
        isReset = false
    end
    SVR.GetReward10(isFree and 1 or 0, true, function(t)
        if t.success then
            --if (isFree) TdAnalytics.OnPurchase(L.Get("金币十连抽"), 1, (double)GameData.GameParam.pr_reward10);
            --stab.S_Reward10
            if isReset then
                _curAniObjects[1] = _ref.rewardGold
                _curAniObjects[2] = _isLieuEnable and _ref.rewardLieu or _ref.rewardRmb
            end
            coroutine.start(OnShow10, SVR.datCache.rws, 1)
        else
            _ref.ef_mask:SetActive(false)
        end
    end )
end
function _w.ClickBuyRmb1()
    SVR.GetReward10(2, false, function(t)
        if t.success then
            --stab.S_Reward10
            local rs = SVR.datCache.rws
            if #rs > 0 then
                coroutine.start(OnShowGold1, rs[1], 3)
            end
            --TdAnalytics.OnEvent(TDEvent.RmbSpend, L.Get("钻石单抽"), (object)GameData.GameParam.pr_rmb_1);
        end
    end )
end
function _w.ClickBuyRmb10()
    local isReset = true
    if _ref.btnSure.activeSelf then
        coroutine.start(OnReward10End, false)
        isReset = false
    end
    SVR.GetReward10(2, true, function(t)
        if t.success then
            --stab.S_Reward10
            if isReset then
                _curAniObjects[1] = _isLieuEnable and _ref.rewardLieu or _ref.rewardGold
                _curAniObjects[2] = _ref.rewardRmb
            end
            coroutine.start(OnShow10, SVR.datCache.rws, 3)
            --TdAnalytics.OnEvent(TDEvent.RmbSpend, L.Get("钻石十连抽"), (object)GameData.GameParam.pr_rmb_10);
        else
            _ref.ef_mask:SetActive(false)
        end
    end )
end
function _w.ClickSure()
    if _ref.btnSure.activeSelf then
        coroutine.start(OnReward10End)
    end
    _ref.ef_mask:SetActive(false)
end
function _w.ClickItemGoods(btn)
    local ig = _items[btn.gameObject]
    if ig then
        ig:ShowPropTip()
    end
end