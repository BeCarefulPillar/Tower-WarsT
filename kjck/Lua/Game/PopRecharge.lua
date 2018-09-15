local Destroy = UnityEngine.Object.Destroy
local BoxCollider = UnityEngine.BoxCollider
local notnull = notnull
local string = string
local table = table
local math = math

local _w = { }

local _body = nil
local _ref = nil

--[Comment]
--0是充值，1是Vip（详情）,2是月卡
local _type = nil
--[Comment]
--审核关闭充值通道
local _uc_permit = true

local _isFirst = true
local _VIP_items = nil
local _VIP_giftItems = nil
local _VIP_items = nil
local _VIP_getGift = nil
local _status = nil

local _VIP_curIndex = nil
local _VIP_len = nil
local _VIP_dx = nil

local _view = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref

    _VIP_curIndex = 1
    _VIP_len = 0
    _VIP_dx = 1
    _type = 0

    _ref.btnVip.param = 1
    _ref.btn_recharge.param = 0

    _view = {
        UIGrid = _ref.VIP_scrollView:GetCmp(typeof(UIGrid)),
        UICenterOnChild = _ref.VIP_scrollView,
    }
    _ref.VIP_scrollView = nil
    _view.UICenterOnChild.onFinished = _w.onFinished

    for i, b in ipairs(_ref.btns) do
        b.param = i - 1
    end
end

local function DestroyItems(its, p)
    if its then
        for i = 1, #its do
            if p then
                Destroy(its[i].p)
            else
                Destroy(its[i])
            end
        end
    end
end

local function DisposeVip()
    DestroyItems(_VIP_items)
    _VIP_items = nil

    _VIP_curIndex = 1
    _VIP_len = 0
    _VIP_dx = 1

    DestroyItems(_VIP_giftItems, "go")
    _VIP_giftItems = nil

    _VIP_getGift = -1
end

local function UpItemInfo(flag)
    local rec = DB.Get(LuaRes.Recharge)
    local cnt = #rec
    for i = 1, 8 do
        if i - 1 < cnt then
            local vals = rec[i]
            _ref.btnItem[i]:SetClick(_w.ClickItem, vals)
            local rmb = vals[2]
            if vals[1] == 0 then
                _ref.itemRmb[i].text = "[FFFAB4]" .. rmb .. L("元[-]")
                _ref.itemGold[i].text = "[CCCCCC]" .. vals[3] .. L("金币[-]立即到账")
                _ref.mIntro.text = L("每日上线领取[00FF00]") .. vals[4] .. L("金币×") .. vals[5] .. L("天[-]")
                _ref.first.text = number.ToCnString(vals[6]) .. L("倍")
            else
                _ref.itemRmb[i].text = "[FFFAB4]" .. rmb .. L("元[-]")
                _ref.itemGold[i].text = vals[3] .. L("金币")
                _ref.itemGoldS[i].text = L("另赠送") .. vals[4] .. L("金币") .. rmb .. L("钻石")
            end
            _ref.itemRmbS[i].text = "" .. rmb
        else
            _ref.btnItem[i]:ClearEvent()
            _ref.btnItem[i].gameObject:SetActive(false)
        end
    end
end

function CheckTutorial()
    --   if user.TutorialSN == 7 then
    --       if user.TutorialStep == Tutorial.Step.TutStep03 then
    --           local trans = _VIP_items[2]:Child("giftPanel"):Child("btn_recharge")
    --           Tutorial.PlayTutorial(true, trans)
    --       elseif user.TutorialStep == Tutorial.Step.TutStep04 then
    --           Tutorial.PlayTutorial(true, _VIP_btnRightPage.transform)
    --       elseif user.TutorialStep == Tutorial.Step.TutStep06 then
    --           Tutorial.PlayTutorial(true, _VIP_btnRightPage.transform)
    --       end
    --   end
end

local function OnUpdateUserInfo()
    if _type == 0 and _uc_permit then
        ToolTip.ShowPopTip(L("充值功能未开放！"))
        return
    end

    if _type == 0 then
        _ref.avatar:LoadTexAsync(ResName.PlayerIcon(user.ava))
        _ref.nickName.text = user.nick
        _ref.vipLv.text = L("等级") .. user.vip
        _ref.mTimes.text = L("剩 余:") .. user.mcard .. L("天")

        if user.vip < DB.maxVip then
            local v = math.clamp(user.vip + 1, 0, DB.maxVip)
            local exp = DB.GetVip(v).exp
            _ref.vipPro.value = user.vipExp / exp
            _ref.vipExp.text = user.vipExp .. "/" .. exp
            _ref.vipNext.text = L("再充值[00FF00]") ..(exp - user.vipExp) .. L("[-]金币，您将成为[FFC850]VIP") ..(user.vip + 1) .. "[-]"
        else
            _ref.vipPro.value = 1
            local exp = DB.GetVip(DB.maxVip).exp
            _ref.vipExp.text = exp .. "/" .. exp
            _ref.vipNext.text = L("您已是至高VIP会员")
        end

    elseif _type == 1 then
        --Vip（详情）—王伊烽
        if user.vip < DB.maxVip then
            _ref.VIP_vipLv.text = user.vip .. ""
            local v = math.clamp(user.vip + 1, 0, DB.maxVip)
            local exp = DB.GetVip(v).exp
            _ref.VIP_vipPro.value = user.vipExp / exp
            _ref.VIP_vipExp.text = user.vipExp .. "/" .. exp
            _ref.VIP_vip.text = L("再充值[00FF00]") ..(exp - user.vipExp) .. L("[-]金币，您将成为[FFC850]VIP") ..(user.vip + 1) .. "[-]"
        else
            _ref.VIP_vipLv.text = user.vip .. ""
            _ref.VIP_vipPro.value = 1
            local exp = DB.GetVip(DB.maxVip).exp
            _ref.VIP_vipExp.text = exp .. "/" .. exp
            _ref.VIP_vip.text = L("您已是至高VIP会员")
        end
    end
end

---<summary>Vip（详情）—王伊烽</summary>
local function InitVip()
    _VIP_dx = - _view.UIGrid.cellWidth
    local datas = DB.vip
    _VIP_len = table.len(datas)
    _VIP_items = { }

    for i = 0, #datas do
        _VIP_items[i + 1] = _view.UIGrid:AddChild(_ref.VIP_item_vip, string.format("%02d", i))
        _VIP_items[i + 1]:SetActive(true)
        local trans = _VIP_items[i + 1].transform
        local data = datas[i]
        local str = ""

        if data.vitQty > 0 then
            str = str .. "\n" .. string.format(DB.GetVipIntro(1), tostring(data.vitQty))
        end
        if data.g2cQty > 0 then
            str = str .. "\n" .. string.format(DB.GetVipIntro(2), tostring(data.g2cQty))
        end
        if data.eqpQty > 0 then
            str = str .. "\n" .. string.format(DB.GetVipIntro(3), tostring(data.eqpQty))
        end
        if data.towerQty > 0 then
            str = str .. "\n" .. string.format(DB.GetVipIntro(4), tostring(data.towerQty))
        end
        if data.rankQty > 0 then
            str = str .. "\n" .. string.format(DB.GetVipIntro(5), tostring(data.rankQty))
        end
        if i >= QYBattle.BD_Const.ACC_VIP then
            str = str .. "\n" .. DB.GetVipIntro(6)
        end
        if data.trainQty > 0 then
            str = str .. "\n" .. string.format(DB.GetVipIntro(7), tostring(data.trainQty))
        end
        if data.dvnQty or 0 > 0 then
            str = str .. "\n" .. string.format(DB.GetVipIntro(8), tostring(data.dvnQty))
        end
        if data.vipChat > 0 then
            str = str .. "\n" .. DB.GetVipIntro(9)
        end
        if data.autoFt > 0 then
            str = str .. "\n" .. DB.GetVipIntro(10)
        end
        if data.warSD > 0 then
            str = str .. "\n" .. DB.GetVipIntro(11)
        end

        trans:Child("content"):ChildWidget("content_1").text = str
        trans:ChildWidget("vip").text = "VIP" .. i .. " " .. L("特权")

        local gift = trans:Child("giftPanel")
        local lab_vipGift = gift:ChildWidget("vipGift")
        lab_vipGift.text = "VIP" .. i .. " " .. L("礼包")
        lab_vipGift:SetActive(i ~= 0)
        if i == 0 then
            gift:Child("btn_recharge"):SetActive(false)
        end
        gift:ChildBtn("btn_recharge").param = i
        --gift:ChildWidget("content").text = data.info

        local list = { }
        local grid = gift:Child("items", typeof(UIGrid))
        if data.rws and #data.rws > 0 then
            for j, u in ipairs(data.rws) do
                local ig = ItemGoods(grid:AddChild(_ref.item_goods, string.format("goods_%02d", j)))
                ig:Init(u)
                table.insert(list, ig)
                ig.go.luaBtn.luaContainer = _body
            end
        end
        local cnt = #list
        if cnt > 0 then
            _VIP_giftItems = list
            grid.repositionNow = true
        end
    end
    _view.UIGrid.repositionNow = true

    SVR.VipLvGiftOpt("", user.vip, function(t)
        if t.success then
            --stab.S_VipLvGiftStu
            local vipGiftStu = SVR.datCache
            _status = vipGiftStu.stat

            if _status[2] == 2 then
                user.TipVIP = false
            end

            --for i = 1, #_status do
            for i, v in ipairs(_status) do
                local btn = _VIP_items[i]:Child("giftPanel"):ChildWidget("btn_recharge")
                if v == 1 then
                    if _VIP_getGift < 1 then
                        _VIP_getGift = i
                    end
                else
                    btn.spriteName = "btn_disabled"
                    btn.color = Color.white
                    --btn:GetCmp(typeof(BoxCollider)).enabled = false
                    btn.luaBtn.isEnabled = false
                end
            end

            --Vip（详情）—王伊烽
            _view.UIGrid:Reposition()
            OnUpdateUserInfo()
            --[[
            if _VIP_items then
                if user.TutorialSN == 7 and user.TutorialStep == Tutorial.Step.TutStep03 then
                    _view.UICenterOnChild:CenterOn(_VIP_items[2].transform)
                else
                    if _VIP_getGift <= 1 then
                        _view.UICenterOnChild:CenterOn(_VIP_items[math.clamp(user.vip, 1, _VIP_len)].transform)
                    else
                        _view.UICenterOnChild:CenterOn(_VIP_items[_VIP_getGift].transform)
                    end
                end
            end
            ]]

            CheckTutorial()
        end
    end )
end

---<summary>0是充值，1是Vip（详情）</summary>
local function ChangeView(v)
    if v == 0 and _uc_permit then
        ToolTip.ShowPopTip(L("充值功能未开放！"))
        return
    end

    DisposeVip()
    _type = v

    if v == 0 then
        UpItemInfo(true)
        OnUpdateUserInfo()
    elseif v == 1 then
        InitVip()
    elseif v == 2 then
        print("月卡~~~~~~~~~~")
    end

    for i, b in ipairs(_ref.btns) do
        local f = i - 1 == v
        b.isEnabled = not f
        b.label.color = f and Color.white or Color(53 / 255, 53 / 255, 53 / 255)
        _ref.panels[i]:SetActive(f)
    end
end

function _w.OnInit()
    if type(_w.initObj) == "number" then
        _type = _w.initObj
        if _type == 0 and _uc_permit then
            _body:Exit()
        end
    end
    SVR.UpdateUserInfo()

    if _type == 0 and _uc_permit then
        ToolTip.ShowPopTip(L("充值功能未开放！"))
        Destroy(_body.gameObject)
        return
    end

    ChangeView(_type)
end

function _w.OnDispose()
    _type = 0
    DisposeVip()
end

local _userdatachange = UserDataChange:CreateListener(OnUpdateUserInfo)
function _w.OnEnabled()
    UserDataChange:AddListener(_userdatachange)
end
function _w.OnDisabled()
    UserDataChange:RemoveListener(_userdatachange)
end

function _w.ClickSortTab(i)
    ChangeView(i)
end

local function CorOnEnter()
    if _type == 0 then
        OnUpdateUserInfo()
        coroutine.step()
    elseif _type == 1 then
        _view.UIGrid:Reposition()
        coroutine.step()
        OnUpdateUserInfo()
        if _VIP_items then
            if user.TutorialSN == 7 and user.TutorialStep == Tutorial.Step.TutStep03 then
                _view.UICenterOnChild:CenterOn(_VIP_items[2].transform)
            else
                if _VIP_getGift <= 1 then
                    _view.UICenterOnChild:CenterOn(_VIP_items[math.clamp(user.vip + 1, 1, _VIP_len)].transform)
                else
                    _view.UICenterOnChild:CenterOn(_VIP_items[_VIP_getGift].transform)
                end
            end
        end
    end
end

function _w.OnEnter()
    coroutine.start(CorOnEnter)
end

function _w.OnFocus(isFocus)
    if isFocus then
        if not _isFirst then
            CheckTutorial()
        end
    end
end

function _w.ClickGetGift(i)
    SVR.VipLvGiftOpt("get", i, function(t)
        if t.success then
            --stab.S_VipLvGiftStu
            local vipGiftStu = SVR.datCache
            PopRewardShow.Show(vipGiftStu.rws)
            _status = vipGiftStu.stat
            if _status[2] == 2 then
                user.TipVIP = false
            end
            for i, v in ipairs(_status) do
                local btn = _VIP_items[i]:Child("giftPanel"):ChildWidget("btn_recharge")
                if v ~= 1 then
                    btn.spriteName = "btn_disabled"
                    --btn:GetCmp(typeof(BoxCollider)).enabled = false
                    btn.isEnabled = false
                end
            end
            OnUpdateUserInfo()
            _w.OnEnabled()
            user.changed = true
        end
    end )
end

function _w.ClickItem(p)
    --      string[] vals = mef.Param as string[];
    --      if (vals.GetLength() > 2)
    --      {
    --          float rmb = ByteConvert.ConvertType<float>(vals[1]);
    --          if (rmb > 0)
    --          {
    --              string pid = vals[0];
    --              if (SDK.CurChannelID == SDK.Channel.UC)
    --              {
    --                  pid = GetLenovoPid(vals[0]);
    --              }
    --              else if (SDK.CurChannelID == SDK.Channel.XIAOMI)
    --              {
    --                  pid = GetMoMoPid(vals[0]);
    --                  Debug.Log(pid);
    --              }
    --              else
    --              {
    --                  pid = vals[2];
    --              }
    --              SDK.Pay(rmb, pid);
    --          }
    --      }
end

function _w.ClickItemGoods(btn)
    local ig = Item.Get(btn.gameObject)
    if ig then
        ig:ShowPropTip()
    end
end

local lpid = {
    [0] = "689",
    [1] = "682",
    [2] = "683",
    [3] = "684",
    [4] = "685",
    [5] = "686",
    [6] = "687",
    [7] = "689",
    [8] = "688",
}

function _w.GetLenovoPid(sn)
    return lpid[sn]
end

local mpid = {
    [0] = "com.wemomo.game.sgqyhd.18",
    [1] = "com.wemomo.game.sgqyhd.11",
    [2] = "com.wemomo.game.sgqyhd.12",
    [3] = "com.wemomo.game.sgqyhd.13",
    [4] = "com.wemomo.game.sgqyhd.14",
    [5] = "com.wemomo.game.sgqyhd.15",
    [6] = "com.wemomo.game.sgqyhd.16",
    [7] = "com.wemomo.game.sgqyhd.18",
    [8] = "com.wemomo.game.sgqyhd.17",
}

function _w.GetMoMoPid(sn)
    return mpid[sn]
end

function _w.ClickLeftPage()
    if _VIP_curIndex > 1 then
        _view.UICenterOnChild:CenterOn(_VIP_items[_VIP_curIndex - 1].transform)
    end
    _VIP_curIndex = _VIP_curIndex - 1
end

function _w.ClickRightPage()
    if _VIP_curIndex < _VIP_len then
        _view.UICenterOnChild:CenterOn(_VIP_items[_VIP_curIndex + 1].transform)
    end
    _VIP_curIndex = _VIP_curIndex + 1
    --   if user.TutorialSN == 7 then
    --       UISprite.BeginTimer(_ref.VIP_btnRightPage, 1.5)
    --   end
end

function _w.onFinished()
    print("--")
    _VIP_curIndex = tonumber(_view.UICenterOnChild.centeredObject.name) + 1
    _ref.VIP_page.text = _VIP_curIndex .. "/" .. _VIP_len
    _ref.VIP_btnLeftPage:SetActive(_VIP_curIndex > 1)
    _ref.VIP_btnRightPage:SetActive(_VIP_curIndex < _VIP_len)
    print(_VIP_curIndex)

    --   if user.TutorialSN == 7 then
    --       if user.TutorialSN == Tutorial.Step.TutStep05 then
    --           local trans = _VIP_items[3]:Child("giftPanel"):Child("btn_recharge")
    --           Tutorial.PlayTutorial(true, trans)
    --       elseif user.TutorialSN == Tutorial.Step.TutStep07 then
    --           local trans = _VIP_items[4]:Child("giftPanel"):Child("btn_recharge")
    --           Tutorial.PlayTutorial(true, trans)
    --       end
    --   end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _VIP_curIndex = nil
        _VIP_len = nil
        _VIP_dx = nil
        _type = nil
    end
end

--[Comment]
--充值
PopRecharge = _w