local _w = { }

local _body = nil
local _ref = nil

local _crCurIndex = 0
local _crLen = 0
local _crDx = 1
local _crData = nil
local _CrRewards = nil
local _crSp = nil
local _data = nil
local _bg = nil

local _align = false

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c, { n = L("签到"), r = DB_Rule.Sign, i = true })

    _ref.cumulativeReward:GetCmp(typeof(UICenterOnChild)).onFinished = _w.onFinished
end

local function BuildItems()
    _align = false
    if _data and _data.rws then
        _ref.grid:Reset()
        _ref.grid.realCount = #_data.rws
    end
    coroutine.start(_w.GetCumRewardInf)
end

function _w.OnInit()
    if not _data or not _data.rws then
        --获取签到数据
        SVR.GetSignData( function(rs)
            if rs.success then
                --stab.S_SignInfo
                _data = SVR.datCache
                _ref.title.text = string.format(L("%s月  签到奖励"),
                number.ToCnString(_data.month))
                _w.UpdateBuySignInfo()
                BuildItems()
            else
                _body:Exit()
            end
        end )
    else
        _ref.title.text = string.format(L("%s月  签到奖励"),
        number.ToCnString(_data.month))
        _w.UpdateBuySignInfo()
        BuildItems()
    end
end

local function DestroyItem(its)
    if its then
        for i, v in ipairs(its) do
            Destroy(v)
        end
    end
end

function _w.OnDispose()
    _crCurIndex = 0
    _crLen = 0
    _crDx = 1
    _align = false
    DestroyItem(_crSp)
    _crSp = nil
    DestroyItem(_CrRewards)
    _CrRewards = nil
end

function _w.UpdateBuySignInfo()
    _ref.buySignTip.text =
    (user.VipData.buySign == 0 and "[FF0000]VIP" or "[FFFFFF]VIP") ..
    DB.GetVipLv( function(v) return v.buySign ~= 0 end) .. L("[-]可以补签")

    _align = false

    _ref.buySignPrice.text = _data.price .. ""
    _ref.btnBuySign.isEnabled =(user.VipData.buySign ~= 0 and _data.signQty < _data.day and(_data.signQty < _data.day - 1 or _data.isSign ~= 0))
end

function _w.Refresh()
    _w.UpdateBuySignInfo()
    _ref.grid:Reset()
    _ref.grid.realCount = #_data.rws
end

--[Comment]
--创建累计奖励界面
--是否是刷新，如果是刷新就不用再创建新的界面和加载图片
local function BuildCrItemReward(refresh)
    _crDx = - _ref.cumulativeReward:GetCmp(typeof(UIGrid)).cellWidth
    _crLen = #_crData.srws
    local firstIndex = _crCurIndex
    if not _CrRewards then
        _CrRewards = { }
        _crSp = { }
    end

    for i = 1, #_crData.srws do
        local cs = _crData.srws[i]
        if not refresh then
            _CrRewards[i] = _ref.cumulativeReward:AddChild(_ref.item_reward,
            string.format("Cr_reward_%02d", i))
            _crSp[i] = _ref.gridSp:AddChild(_ref.item_sp.gameObject,
            string.format("sp_%02d", i)):GetCmp(typeof(UISprite))
            _crSp[i]:SetActive(true)
        end
        local btnSure = _CrRewards[i]:Child("btn_sure").gameObject
        btnSure:GetCmp(typeof(LuaButton)):SetClick(_w.ClickSureCrReward, i)
        btnSure:GetCmp(typeof(UIButton)).isEnabled = cs.isGet == 1
        if cs.isGet == 2 then
            btnSure.transform:GetComponentInChildren(typeof(UILabel)).text = L("已领取")
        else
            btnSure.transform:GetComponentInChildren(typeof(UILabel)).text = L("领 取")
        end

        _CrRewards[i]:ChildWidget("top_lab").text = string.format(L("累计签到%s次奖励"), cs.day)
        _CrRewards[i]:ChildWidget("pro_lab").text = _data.signQty .. "/" .. cs.day

        for j = 1, #cs.rws do
            local goods = _CrRewards[i]:Child("item_goods_" ..(j - 1)).gameObject
            goods:GetCmp(typeof(LuaButton)):SetClick(_w.OnClickShowCrTip, cs.rws[j])
            if not refresh then
                goods.widget:LoadTexAsync(RW.IcoName(cs.rws[j]))

                if cs.rws[j][1] == 5 then
                    --装备碎片
                    local g = goods:ChildWidget("sp")
                    g.spriteName = "sp_piece"
                    g.gameObject:SetActive(true)
                elseif cs.rws[j][1] == 6 then
                    --将魂
                    local g = goods:ChildWidget("sp")
                    g.spriteName = "frame_hero_soul"
                    g.gameObject:SetActive(true)
                else
                    goods:Child("sp").gameObject:SetActive(false)
                end

            end

            goods:ChildWidget("num").text = "x" .. cs.rws[j][3]
            goods:ChildWidget("name").text = RW(cs.rws[j]).nm
        end
        _CrRewards[i]:SetActive(true)
    end

    _ref.cumulativeReward:GetCmp(typeof(UIGrid)):Reposition()
    _ref.gridSp:Reposition()

    if not refresh then
        _ref.cumulativeReward:ConstraintPivot(UIWidget.Pivot.TopLeft, true)
    end

    --是否可以领累计签到（用来判断累计签到界面是否翻页）
    local changeCr = false
    for i = 1, #_crData.srws do
        local cs = _crData.srws[i]
        if cs.isGet == 1 then
            firstIndex = i - 1
            changeCr = true
            break
        elseif cs.isGet == 2 then
            if i < #_crData.srws then
                if _crData.srws[i + 1].isGet == 0 then
                    firstIndex = i
                    changeCr = true
                    break
                end
            end
        end
    end

    if not refresh or changeCr then
        _ref.cumulativeReward:GetCmp(typeof(UICenterOnChild)):CenterOn(_ref.cumulativeReward.transform:GetChild(firstIndex))
        _w.ChangeSp(firstIndex)
    end
end

function _w.Sign()
    if _data.isSign == 0 then
        SVR.Sign(true, function(rs)
            if rs.success then
                local res = SVR.datCache
                if res.info then
                    _data.isSign = res.info[1]
                    _data.signQty = res.info[2]
                    _data.price = res.info[3]
                    _w.Refresh()
                    coroutine.start(_w.GetCumRewardInf, true)
                end
            end
        end )
    end
end

--[Comment]
--得到累计签到奖励数据
--是否是刷新数据
function _w.GetCumRewardInf(refresh)
    coroutine.wait(0.2)
    SVR.SignCumRewardInf("", 0, function(rs)
        if rs.success then
            _crData = SVR.datCache
            BuildCrItemReward(refresh)
        end
    end )
end

function _w.ClickBuySign()
    --int rmb = User.Rmb;
    if _data.signQty < _data.day and(_data.signQty < _data.day - 1 or _data.isSign ~= 0) then
        SVR.Sign(false, function(rs)
            if rs.success then
                --TdAnalytics.OnEvent(TDEvent.RmbSpend, L.Get("补签"), rmb - User.Rmb);
                local res = SVR.datCache
                if res.info then
                    _data.isSign = res.info[1]
                    _data.signQty = res.info[2]
                    _data.price = res.info[3]
                    _w.Refresh()
                    coroutine.start(_w.GetCumRewardInf, true)
                end
            end
        end )
    end
end

function _w.OnWrapGridInitItem(item, i)
    if isnull(item) or i < 0 or i >= #_data.rws then
        return false
    end

    local is = ItemSign(item)
    is:Init(_data.rws[i + 1])
    is:setSignTag(i < _data.signQty)
    is.go:ChildWidget("lab_day").text = string.format(L("第%d天"), i + 1)
    ItemSign.setFrameAnim(is, i == _data.signQty and _data.isSign == 0)
    is.go:SetActive(true)

    if not _align then
        _align = true
        local m = 15
        if _data.signQty > 15 then
            _ref.grid:AlignItem(math.clamp(_data.signQty, m, _ref.grid.realCount - 1))
        end
    end

    return true
end

function _w.onFinished()
    _crCurIndex = _crDx ~= 0 and math.clamp(math.RoundToInt(_ref.cumulativeReward.transform.localPosition.x / _crDx), 0, _crLen - 1) or 0
    _w.ChangeSp(_crCurIndex)
end

--[Comment]
--根据图片更改图片显示的白点
function _w.ChangeSp(idx)
    for i = 1, #_crSp do
        if idx == i - 1 then
            _crSp[i].spriteName = "seven_sp_ad_1"
        else
            _crSp[i].spriteName = "seven_sp_ad_0"
        end
    end
end

--[Comment]
--累计签到道具提示
function _w.OnClickShowCrTip(rw)
    rw:ShowPropTip()
end

function _w.ClickItemGoods(btn)
    if btn:Child("ef_sign_frame").activeSelf then
        _w.Sign()
    else
        btn = btn and Item.Get(btn.gameObject)
        if btn then
            btn:ShowPropTip()
        end
    end
end

function _w.ClickSureCrReward(i)
    SVR.SignCumRewardInf("get", i, function(rs)
        if rs.success then
            local res = SVR.datCache
            user.SyncReward(res.srws[1].rws)
            coroutine.start(_w.GetCumRewardInf, true)
        end
    end )
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _bg:dispose()
        _bg = nil
    end
end

--[Comment]
--签到
WinSign = _w