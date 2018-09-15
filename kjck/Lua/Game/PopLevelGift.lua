local _w = { }

local _body = nil
local _ref = nil

-- [Comment]
-- 本次打开内已经购买的礼包
local _boughtGifts = { }
local _curTime = TimeClock()
-- [Comment]
-- 当前选择的tab按钮。
local _curSelectedGo = nil
-- [Comment]
-- 当前选择项。限时礼包传入-SN，等级礼包传入等级
local _curSelected = 0
local _data = nil
-- [Comment]
-- 0：等级/限时礼包  1：VIP豪礼
local _kinds = 0

local _dat = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c,{k=WinBackground.MASK})
    _boughtGifts = { }
end

function _w.OnInit()
    _kinds = 0--_w.initObj
    SVR.GetGift("inf", function(t)
        if t.success then
            _data = SVR.datCache
            if _kinds == 0 then
                _ref.title.spriteName = "title_gift"
                _ref.tex_title:Load("tex_levelgift")
                _dat = DB.Get(LuaRes.Gift_Hlv)
            elseif _kinds == 1 then
                _ref.title.spriteName = "title_vip_Hl"
                _ref.tex_title:Load("tex_viphl")
                _dat = DB.Get(LuaRes.Gift_Vlv)
            else
                Destroy(_body.gameObject)
            end
            _w.UpdateTab(_data)
        end
    end )
end

local function Update()
    _ref.labTime.text = TimeClock.TimeToString(_curTime.time)
end

function _w.OnEnable()
    UpdateBeat:Add(Update)
end

function _w.OnDisable()
    UpdateBeat:Remove(Update)
end

function _w.OnDispose()
    _curSelected = 0
    _curSelectedGo = nil
    _boughtGifts = { }
    _ref.gridTab:DesAllChild()
    _ref.gridItems:DesAllChild()
end

-- [Comment]
-- 判断指定需求的礼包是否能购买 [等级需求min,等级需求max,VIP需求min,VIP需求max,爵位需求min，爵位需求max，联盟等级需求min，联盟等级需求max，武将需求，注册时间需求]
local function CheckIsBuyable(requires)
    if user.hlv < requires[1] or(requires[2] > 0 and user.hlv > requires[2]) then
        return false
    end
    if user.vip < requires[3] or(requires[4] > 0 and user.vip > requires[4]) then
        return false
    end
    if user.ttl < requires[5] or(requires[6] > 0 and user.ttl > requires[6]) then
        return false
    end
    if user.ally.lv < requires[7] or(requires[8] > 0 and user.ally.lv > requires[8]) then
        return false
    end
    if requires[9] > 0 and not user.ExistHero(requires[9]) then
        return false
    end
    if requires[10] > 0 and user.regTm <(SVR.SvrTime - requires[10] * 3600) then
        return false
    end
    return true
end

-- [Comment]
-- 更新礼包信息
function _w.UpdateContent()
    _ref.gridItems:DesAllChild()

    local ct = 0
    -- [Comment]
    -- 等级礼包：等级。限时礼包：-SN
    local sn = 0
    local rewards = nil
    local priceOld = nil
    local priceNew = nil

    if _curSelected < 0 and _kinds == 0 then
        -- 限时礼包
        for i = 1, #_data.tmGift do
            local tg = _data.tmGift[i]
            if tg.sn == - _curSelected then
                ct = tg.expTime - SVR.SvrTime()
                sn = - tg.sn

                rewards = { }
                local t = string.split(tg.rws, '|')
                for m = 1, #t do
                    rewards[m] = string.split(t[m], ',')
                    for n = 1, #rewards[m] do
                        rewards[m][n] = tonumber(rewards[m][n])
                    end
                end

                priceOld = tg.opr
                priceNew = tg.price
                break
            end
        end
    elseif _curSelected > 0 then
        -- 等级礼包
        for i = 1, #_data.snGift, 2 do
            local sg = _data.snGift[i]
            if sg == _curSelected then
                ct = _data.snGift[i + 1] - SVR.SvrTime()
                sn = sg
                local dbData = _dat[sn]
                rewards = dbData.rws
                priceOld = dbData.opr
                priceNew = dbData.price
                break
            end
        end
    end

    _w.UpdateBuyBtn(sn)

    _curTime = TimeClock(ct)

    -- 生成奖励
    for i = 1, #rewards do
        local ig = ItemGoods(_ref.gridItems:AddChild(_ref.item_goods, string.format("item_%02d", i)))
        ig:Init(rewards[i])
        ig.go:GetCmp(typeof(LuaButton)):SetClick( function(bt)
            local ig = Item.Get(bt.gameObject)
            if ig then
                ig:ShowPropTip()
            end
        end )
        ig:HideName()
    end
    _ref.gridItems:GetCmp(typeof(UIGrid)).repositionNow = true

    for w = 1, #priceOld do
        -- 原价
        if priceOld[w] > 0 then
            _ref.labOldPrice.text = tostring(priceOld[w])
            _ref.labOldPrice:GetComponentInChildren(typeof(UISprite)).spriteName =(w == 1 and "sp_diamond" or(w == 2 and "sp_gold" or "sp_silver"))
            break
        end
    end

    for i = 1, #priceNew do
        -- 现价
        if priceNew[i] > 0 then
            _ref.labNewPrice.text = tostring(priceNew[i])
            _ref.labNewPrice:GetComponentInChildren(typeof(UISprite)).spriteName =(i == 1 and "sp_diamond" or(i == 1 and "sp_gold" or "sp_silver"))
            break
        end
    end
end

function _w.UpdateTab(data)
    local btn = nil
    local sn = nil

    local dt = { }
    if #data.snGift > 0 or #data.tmGift > 0 then
        -- 配置等级礼包
        if #data.snGift > 0 then
            for a = 2, #data.snGift, 2 do
                -- 礼包未过期
                if data.snGift[a] > SVR.SvrTime() then
                    local k = data.snGift[a - 1]
                    local dbData = _dat[k]

                    if dbData then
                        if dbData.lv > 0 and _kinds == 0 then
                            local go = _ref.gridTab:AddChild(_ref.item_tab, string.format("btn_%02d", a))
                            go:GetComponentInChildren(typeof(UILabel)).text = dbData.lv .. L("级限购礼包")
                            go:GetCmp(typeof(LuaButton)):SetClick(_w.OnTabClicked, k)
                            go:SetActive(true)
                            btn = btn or go.luaBtn
                            sn = sn or k
                        elseif _kinds == 1 and dbData.lv > 0 then
                            local go = _ref.gridTab:AddChild(_ref.item_tab, string.format("btn_%02d", a))
                            go:GetComponentInChildren(typeof(UILabel)).text = "V" .. dbData.lv .. L("豪礼")
                            go:GetCmp(typeof(LuaButton)):SetClick(_w.OnTabClicked, k)
                            go:SetActive(true)
                            btn = btn or go.luaBtn
                            sn = sn or k
                        end
                    end
                end
            end
        end

        if _kinds == 0 then
            -- 配置限时礼包(记录里有的剔除)
            if #data.tmGift > 0 then
                for a = 1, #data.tmGift do
                    local tg = data.tmGift[a]
                    -- 该限时礼包还没买过，显示
                    if not table.contains(data.snGift, tg.sn) and CheckIsBuyable(tg.require) then
                        local go = _ref.gridTab:AddChild(_ref.item_tab, string.format("btn_%02d", #data.snGift + a))
                        go:GetComponentInChildren(typeof(UILabel)).text = L("限时礼包")
                        go:GetCmp(typeof(LuaButton)):SetClick(_w.OnTabClicked, - k)
                        btn = btn or go.luaBtn
                        sn = sn or - k
                        go:SetActive(true)
                    end
                end
            end
        end
    end

    _w.OnTabClicked(btn, sn)
    _ref.gridTab:GetCmp(typeof(UIGrid)).repositionNow = true

    _ref.gridTab:GetCmp(typeof(UIScrollView)):ConstraintPivot(UIWidget.Pivot.Top, true)
    _ref.gridTab:GetCmp(typeof(UIScrollView)).enabled = _ref.gridTab.transform.childCount > 4
end

function _w.OnRechargeClicked()
    Win.Open("PopRecharge", 0)
end

function _w.UpdateBuyBtn(sn)
    if table.contains(_boughtGifts, sn) then
        _ref.btnBuy.isEnabled = false
        _ref.buyLabel.text = L("已购买")
        _ref.labAmount.text = "0/1"
    else
        _ref.btnBuy.isEnabled = true
        _ref.buyLabel.text = L("购 买")
        _ref.labAmount.text = "1/1"
    end
end

-- [Comment]
-- 切换标签。限时礼包传入-SN，等级礼包传入等级
function _w.OnTabClicked(btn, p)
    if _curSelected == p then
        return
    end

    if _curSelectedGo then
        _curSelectedGo:GetCmp(typeof(UISprite)).spriteName = "btn_01"
        _curSelectedGo:GetComponentInChildren(typeof(UILabel)).color = Color(190 / 255, 166 / 255, 109 / 255)
    end

    _curSelectedGo = btn.gameObject
    _curSelected = p
    btn:GetCmp(typeof(UISprite)).spriteName = "btn_02"
    btn:GetComponentInChildren(typeof(UILabel)).color = Color(1, 180 / 255, 0)
    _w.UpdateContent()
end

-- [Comment]
-- 点击购买
function _w.OnBuyClicked()
    if _curSelected < 0 then
        -- 限时礼包
        SVR.GetGift("btm|" ..(- _curSelected), function(rs)
            if rs.success then
                local res = SVR.datCache
                PopRewardShow.Show(res.rws)
                -- 把sn添加到list
                for s = 1, #res.snGift do
                    if not table.contains(_data.snGift, s) and not table.contains(_boughtGifts, - s) then
                        table.insert(_boughtGifts, - s)
                        -- 更新购买记录缓存
                        _data.snGift = res.snGift
                        break
                    end
                end

                _ref.gridTab:DesAllChild()
                _w.UpdateTab(_data)
                user.changed = true
            end
        end )
    elseif _curSelected > 0 then
        -- 等级礼包
        SVR.GetGift("blv|" .. _curSelected, function(rs)
            if rs.success then
                local res = SVR.datCache
                PopRewardShow.Show(res.rws)
                -- 把sn添加到list
                for i = 1, #_data.snGift, 2 do
                    local d = _data.snGift[i]
                    if not table.contains(res.snGift, d) and not table.contains(_boughtGifts, d) then
                        table.insert(_boughtGifts, d)
                        break
                    end
                end

                -- 更新购买记录缓存
                _data.snGift = res.snGift
                _ref.gridTab:DesAllChild()
                _w.UpdateTab(_data)
                user.changed = true
            end
        end )
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
    end
end

-- [Comment]
-- 限时礼包
PopLevelGift = _w