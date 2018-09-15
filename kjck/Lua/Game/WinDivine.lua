local Animation = UnityEngine.Animation
local coroutine = coroutine
local Time = Time
local ipairs = ipairs

local _w = { }
--[Comment]
--占卜
WinDivine = _w

local _body = nil
local _ref = nil
local _bg = nil

local _reverse = Vector3(0, 180, 0)
--[Comment]
--洗牌动画NO.1的时间点
local _resetAnim = nil
local _texFrontRect = Rect(-0.015, 0, 0.5, 1)
local _texBackRect = Rect(0.475, 0, 0.5, 1)
local _cameraWorldPos = Vector3(0, 0, 0)
local _dat = nil
local _cards = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c, { n = L("幸运占卜"), i = true, r = DB_Rule.Divine })

    _cards = { }
    local c = nil
    local ta = typeof(Animation)
    for i = 1, #_ref.cards do
        c = _ref.cards[i]
        _cards[i] = {
            anim = c:GetCmp(ta),
            btn = c.luaBtn,
            utx = c,
            trans = c.cachedTransform,
            igo = c:Child("item_goods").gameObject,
            tip = c:ChildWidget("tip"),
            turn = true
        }
        _cards[i].btn.param = i - 1
    end
    _ref.cards = nil

    _cameraWorldPos = UICamera.current and UICamera.current.transform.position or Vector3.zero
end

--[Comment]
--如果任意一个动画在播放
local function isAnim()
    return _resetAnim and coroutine.status(_resetAnim) ~= "dead"
end

--[Comment]
--当前已翻开的牌数
local function selectQty()
    return _dat and _dat.sltCards and #_dat.sltCards or 0
end

local function GetCardInitPos(i)
    i = i - 1
    return Vector3(-520 +(i % 5) * 260, 144 - math.toint(i / 5) * 282, 0)
end

--[Comment]
--配置卡牌的翻开信息
local function ApplyCard(c, db, id)
    c.btn.isEnabled = false

    c.tip.cachedTransform.localEulerAngles = Vector3(0, 0, 0)
    c.tip.cachedTransform:GetChild(0).gameObject:SetActive(false)

    local ig = Item.Get(c.igo)
    if db.sn > 0 then
        c.tip.text = L("幸运+") .. db.luck
        c.tip.color = ColorStyle.GetRareColor(db.rare)
        if ig == nil then
            ig = ItemGoods(c.igo)
            ig:HideName()
        end
        ig:Init(db.rws[1])
    else
        c.tip.text = L("无宝物")
        c.tip.color = Color.white
        if ig then
            ig:Init()
        end
    end

    if id then
        c.anim:Stop()
        c.utx.uvRect = _texFrontRect
        c.trans.localScale = Vector3(1, 1, 1)
        c.trans.localEulerAngles = Vector3(0, 0, 0)
        for i = 1, c.trans.childCount do
            c.trans:GetChild(i - 1).gameObject:SetActive(true)
        end
    end
end

local function CheckCards()
    if _dat == nil or _dat.sltPos == nil then
        return
    end

    for i, p in ipairs(_dat.sltPos) do
        p = _cards[p + 1]
        if p then
            ApplyCard(p, DB.GetDivine(_dat.sltCards and _dat.sltCards[i]), true)
        end
    end
end

local function isSelect(idx)
    if _dat and _dat.sltPos then
        for i, p in pairs(_dat.sltPos) do
            if p == idx then
                return true
            end
        end
    end
    return false
end

--[Comment]
--更新所有卡牌的提示
local function RefreshAllTip()
    local price, str = false, ""
    local cor, sq = Color.white, selectQty()

    if _dat == nil or _dat.cards == nil or #_dat.cards <= 0 then
        str = L("请洗牌")
    elseif sq < user.VipData.dvnQty then
        sq = DB.param.prDivine[sq + 1] or DB.param.prDivine[#DB.param.prDivine]
        if sq then
            if sq > 0 then
                price = true
                str = tostring(sq)
            else
                str = L("免费")
            end
        else
            price = true
            str = L("未知")
        end
    else
        local vip = -1
        for i = user.vip, DB.maxVip do
            if DB.vip[i] and DB.vip[i].dvnQty > sq then
                vip = i
                break
            end
        end
        str = vip > 0 and L("需VIP") .. vip or L("请洗牌")
        if vip > 0 then cor = Color.red end
    end

    for i, c in pairs(_cards) do
        if not isSelect(i - 1) then
            c.tip.text = str
            c.tip.color = cor
            c.tip.cachedTransform.localEulerAngles = c.trans.localEulerAngles
            c.tip:SetActive(true)
            c.tip.cachedTransform:GetChild(0):SetActive(price)
        end
    end
end

local function UpdateInfo()
    if not _dat then
        return
    end
    _ref.labLucky.text = L("幸运点") .. ":" ..(_dat.lucky or 0)
    if _dat.freeQty and _dat.freeQty > 0 then
        _ref.labQty.text = L("免费次数") .. ":" .. _dat.freeQty
        _ref.labQty.cachedTransform:GetChild(0):SetActive(false)
    else
        _ref.labQty.text = "" ..(_dat.refPrice or 0)
        _ref.labQty.cachedTransform:GetChild(0):SetActive(true)
    end
end

function _w.OnInit()
    --刷新修炼卡
    _ref.cultiveCards.text = tostring(user.GetPropsQty(DB_Props.XiuLianKa))
    _w.isOpen = true
    SVR.DivineOption("info", function(result)
        if result.success then
            --stab.S_DivineOption
            _dat = SVR.datCache
            UpdateInfo()
            RefreshAllTip()
            Invoke(CheckCards, 0.02)
        end
    end )
end

local function CoRestCard()
    --卡牌缩小
    for i, c in ipairs(_cards) do
        c.btn.isEnabled = false
        c.anim:Play("CardNarrow")
    end
    coroutine.wait(0.5)

    --配置卡牌,卡牌放大
    for i, c in ipairs(_cards) do
        ApplyCard(c, DB.GetDivine(_dat.cards and _dat.cards[i]), true)
        c.anim:Play("CardGrow")
    end

    --停留
    local t = 1.8
    while t > 0 do
        coroutine.step()
        if not Input.anyKey then
            t = t - Time.deltaTime
        end
    end

    --卡牌盖上
    for i, c in ipairs(_cards) do
        c.anim:Play("CardClose")
    end
    coroutine.wait(0.5)

    --强制重置
    for i, c in pairs(_cards) do
        c.utx.uvRect = _texBackRect
        i = c.trans
        for j = 1, i.childCount do
            i:GetChild(j - 1):SetActive(false)
        end
    end

    --洗牌
    _ref.resetAnim:get_Item("ResetCards").speed = 1.5
    _ref.resetAnim:Play("ResetCards")
    coroutine.wait(2)

    --卡牌归位
    _ref.resetAnim:Stop()
    RefreshAllTip()
    for i, c in ipairs(_cards) do
        c.trans.localPosition = GetCardInitPos(i)
        c.btn.isEnabled = true
        c.tip:SetActive(true)
    end

    coroutine.step()
    _resetAnim = nil
end

local function ResetCard()
    --local rmb = user.rmb
    SVR.DivineOption("shuf", function(t)
        if t.success then
            _dat = SVR.datCache
            UpdateInfo()
            _resetAnim = coroutine.start(CoRestCard)
            --TdAnalytics.OnEvent(TDEvent.RmbSpend,"占卜_洗牌",rmb - user.rmb)
        end
    end )
end

local function Update()
    --控制牌的正反面图案
    for i, c in ipairs(_cards) do
        if c.anim:IsPlaying("CardClose") then
            --卡牌盖住
            if c.turn then
                i = c.trans
                if Vector3.Angle(i.forward, _cameraWorldPos - i.position) < 90 then
                    c.turn = false
                    c.utx.uvRect = _texBackRect
                    for j = 0, i.childCount - 1 do
                        i:GetChild(j):SetActive(false)
                    end
                end
            end
        elseif c.anim:IsPlaying("CardOpen") then
            --卡牌翻开
            if c.turn then
                i = c.trans
                if Vector3.Angle(- i.forward, _cameraWorldPos - i.position) < 90 then
                    c.turn = false
                    c.utx.uvRect = _texFrontRect
                    for j = 0, i.childCount - 1 do
                        i:GetChild(j):SetActive(true)
                    end
                end
            end
        else
            c.turn = true
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

function _w.OnDispose()
    _w.isOpen = false

    if _resetAnim then
        coroutine.stop(_resetAnim)
        _resetAnim = nil
    end

    local c = nil
    local t = nil
    for i = 1, #_cards do
        c = _cards[i]
        c.anim:Stop()
        c.btn.isEnabled = true
        c.utx.uvRect = _texBackRect
        c.trans.localPosition = GetCardInitPos(i)
        c.trans.localScale = Vector3(1, 1, 1)
        c.trans.localEulerAngles = _reverse
        for j = 1, c.trans.childCount do
            t = c.trans:GetChild(j - 1).gameObject
            t:SetActive(t.name == "tip")
        end
        t = Item.Get(c.igo)
        if t then
            t.imgl:Dispose()
        end
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _bg:dispose()
        _bg = nil
        _resetAnim = nil
        _dat = nil
        _cards = nil
    end
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end
function _w.ClickRank()
    Win.Open("PopRankDivine")
end
function _w.ClickReset()
    if isAnim() then
        return
    end
    if _dat and _dat.cards and #_dat.cards > 0 and selectQty() < user.VipData.dvnQty then
        MsgBox.Show(L("你还有未翻开的卡牌，是否继续洗牌？"), L("否") .. "," .. L("是"), function(bid)
            if bid == 1 then
                ResetCard()
            end
        end )
    else
        ResetCard()
    end
end
local function ShowReward()
    UpdateInfo()
    RefreshAllTip()
    if _dat and _dat.sltCards and #_dat.sltCards > 0 then
        PopRewardShow.Show(DB.GetDivine(_dat.sltCards[#_dat.sltCards]).rws)
    end
end
function _w.ClickCard(idx)
    if not _dat or not _dat.cards or #_dat.cards < 1 or isAnim() or selectQty() >= user.VipData.dvnQty or isSelect(idx) then
        return
    end
    --local rmb = user.rmb
    SVR.DivineOption("turn|" .. idx, function(t)
        if t.success then
            --if rmb - user.rmb > 0 then TdAnalytics.OnEvent(TDEvent.RmbSpend,"占卜_翻牌",rmb - user.rmb)
            _dat = SVR.datCache
            if _dat and _dat.sltCards and #_dat.sltCards > 0 then
                idx = _cards[idx + 1]
                idx.tip:SetActive(false)

                ApplyCard(idx, DB.GetDivine(_dat.sltCards[#_dat.sltCards]))
                idx.anim:Play("CardOpen")
                Invoke(ShowReward, 0.3)
            end
        end
    end )
end