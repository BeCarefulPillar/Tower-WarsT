--悬赏任务窗口
local win = {}
PopAllyBounty = win
PopAllyBounty.isOpen = false

local _body = nil
local _ref = nil

local _btnBL = nil
local _btnMB = nil
local _item = nil
local _grid = nil
local _tip = nil

local _labTime = nil
local _labAva = nil
local _labRef = nil

local _data = nil
local _items = nil
local _view = nil
local _gt = nil

local _buildItem = nil
local _update = nil

local function RefreshBtn(btn, isE, lab)
    btn.isEnabled = isE
    local txt = btn:GetCmpInChilds(typeof(UILabel))
    local sp = btn:GetCmp(typeof(UISprite))
    txt.text = lab
    if txt.text == "揭榜" then sp.width = 122  sp.height = 40 end
    btn.param = idx
    btn.gameObject:SetActive(true)
end

-- 刷新单个任务信息
local function UpdateQuest(idx)
    local qsts = _view == 1 and _data.myQstLst or _data.qstLst
    if idx > 0 and idx <= #qsts then
        local si = qsts[idx]
        local dbi = DB.GetAllyQuest(DB_AllyQst.GetSnFromGR(si.group, si.rare))
        local it = _items[idx]
        local btnR = it.transform:Find("btn_refresh"):GetCmp(typeof(LuaButton))
        btnR:SetClick("ClickRefresh", idx)
        local btnD = it.transform:Find("btn_delete"):GetCmp(typeof(LuaButton))
        btnD:SetClick("ClickDelete", idx)
        local labN = it.transform:Find("lab_questName"):GetCmp(typeof(UILabel))
        labN.text = dbi.nm
        it.transform:Find("lab_content"):GetCmp(typeof(UILabel)).text = dbi.i
        labN.color = ColorStyle.GetRareColor(si.rare)
        it.transform:Find("stars"):GetCmp(typeof(UIRepeat)).TotalCount = tonumber(si.rare)
        local grid = it.transform:Find("Grid")
        if grid then
            if grid.childCount > 0 then grid:DesAllChild(it.transform) end
            local pfb = AM.LoadPrefab("item_goods")
            local item = nil
            local btn = nil
            for i = 1, #dbi.rws do
                item = nil
                item = grid.gameObject:AddChild(pfb, string.format("reward_0%02d", i))
                item.transform.localScale = Vector3(0.8, 0.8, 0.8)
                item:GetCmp(typeof(UE.BoxCollider)).center = Vector3.zero
                btn = item:GetCmp(typeof(LuaButton))
                btn.luaContainer = _body
                item = ItemGoods(item)
                item:Init(dbi.rws[i])
                btn.param = item
                btn = item.go:AddCmp(typeof(UIButtonScale))
                btn.hover = Vector3.one
                btn.pressed = Vector3.one * 0.95
                _gt:Add(item.imgl)
                item:HideName()
            end
            grid:GetCmp(typeof(UIGrid)).repositionNow = true
        end
        local btnO = it.transform:Find("btn_option"):GetCmp(typeof(LuaButton))
        if _view == 1 then -- 我的任务
            local done = tonumber(si.done)
            it.transform:Find("lab_receiver").gameObject:SetActive(false)
            local tmp = it.transform:Find("lab_cost")
            tmp.gameObject:SetActive(false)
            btnR.gameObject:SetActive(done ~= 1 and done ~= 2 and DB.GetAllyQuestCnt(dbi.grp) > 1)
            btnD.gameObject:SetActive((done == 1 or done == 2 ) and false or true)
            it.transform:Find("sp_completed"):SetActive(done == 2)
            if btnR.gameObject.activeSelf then
                tmp:GetCmp(typeof(UILabel)).text = DB.param.prAllyReQuest
                tmp.localPosition = Vector3(-60, -173, 0)
                tmp.gameObject:SetActive(user.GetPropsQty(DB_Props.SHUA_XIN_JUAN) <= 0)
            end
            tmp = it.transform:Find("lab_progress"):GetCmp(typeof(UILabel))
            tmp.text = si.val.."/"..dbi.trg
            tmp.color = (done == 1 or done == 2) and Color.green or Color.red
            tmp.enabled = true
            if done == 1 then
                RefreshBtn(btnO, true, L("领奖"))
                btnO:SetClick(win.ClickGetReward, idx)
                btnO.transform.localPosition = Vector3(0, -140, 0)
            elseif done == 2 then
                RefreshBtn(btnO, false, L("已领"))
                btnO.transform.localPosition = Vector3(0, -140, 0)
            else
                RefreshBtn(btnO, true, L("出击"))
                btnO.transform.localPosition = Vector3(67, -140, 0)
                btnO:SetClick(win.ClickGoAttack, idx)
            end
        else
            it.transform:Find("sp_completed"):SetActive(false)
            it.transform:Find("lab_progress"):SetActive(false)
            btnR.gameObject:SetActive(false)
            btnD.gameObject:SetActive(false)
            btnO.transform.localPosition = Vector3(0, -140, 0)
            local tmp = it.transform:Find("lab_receiver").gameObject
            local cost = it.transform:Find("lab_cost")
            if not si.owner or si.owner == "" then
                tmp:SetActive(false)
                local allDone = true
                local mq = _data.myQstLst
                if #mq > 0 then
                    for i = 1, #mq do
                        -- 还有未完成的任务
                        if mq[i].done ~= 2 then allDone = false; break end
                    end
                end
                -- 还有未完成的任务，或者已无可揭榜次数
                if not allDone or _data.qty <= 0 then
                    print("还有未完成的任务，或者已无可揭榜次数")
                    RefreshBtn(btnO, false, L("揭榜"))
                    btnO.transform.localPosition = Vector3(0, -140, 0)
                    cost.gameObject:SetActive(false)
                else
                    if _data.vip > user.vip then -- 玩家 VIP 等级不够
                        RefreshBtn(btnO, false, L("需VIP").._data.vip)
                        btnO.transform.localPosition = Vector3(0, -140, 0)
                        cost.gameObject:SetActive(false)
                    else -- 可以揭榜
                        cost:GetCmp(typeof(UILabel)).text = _data.price
                        cost.localPosition = Vector3(-60, -173, 0)
                        cost.gameObject:SetActive(_data.price > 0)
                        RefreshBtn(btnO, true, L("揭榜"))
                        btnO:SetClick(win.ClickAccept, idx)
                        btnO.transform.localPosition = Vector3(0, -140, 0)
                    end
                end
            else
                tmp:GetCmp(typeof(UILabel)).text = si.owner
                btnO.gameObject:SetActive(false)
                cost.gameObject:SetActive(false)
                tmp:SetActive(true)
            end
        end
    end
end

local function UpdateOtherShowInfo()
    if _data then _labAva.text = _data.qty.."/"..user.VipData.allyQstQty end
    _labRef.text = tostring(user.GetPropsQty(DB_Props.SHUA_XIN_JUAN))
    _tip:SetActive(_view == 1 and #_data.myQstLst <= 0)
    if _view == 1 then
        _btnMB.isEnabled = false
        _btnBL.isEnabled = true
        _labRef.gameObject:SetActive(true)
    else
        _btnMB.isEnabled = true
        _btnBL.isEnabled = false
        _labRef.gameObject:SetActive(false)
    end
end

-- 转换界面
local function ChangeView(v, isr)
    if v < 0 or v > 1 or (v == _view and not isr) then return end
    _view = v
    UpdateOtherShowInfo()
    if _items ~= nil then for i = 1, #_items do Destroy(_items[i]) end end
    local qsts = v == 1 and _data.myQstLst or _data.qstLst
    _grid:GetCmp(typeof(UIScrollView)).enabled = #qsts > 3
    if #qsts > 0 then
        _items = { }
        local go
        for i = 1, #qsts do
            go = _grid:AddChild(_item, string.format("quest_0%02d", i))
            go:SetActive(false)
            table.insert(_items, go)
            UpdateQuest(i)
        end
        _grid.transform.localPosition = Vector3(-290, -25, 0)
        _grid:GetCmp(typeof(UIPanel)).clipOffset = Vector2(290, 0)
        

        if coroutine.running(_buildItem) then coroutine.stop(_buildItem); _buildItem = nil end
        _buildItem = coroutine.create(IEbuildItems)
        coroutine.resume(_buildItem)
        _grid.repositionNow = true
    end
end

-- 
function IEbuildItems()
    coroutine.wait(0.05)
    if _items then
        for i = 1, #_items do
            _items[i]:SetActive(true)
            coroutine.wait(0.05)
        end
    end
end
-- 刷新数据信息
local function UpdateViewFromServer(v)
    SVR.GetAllyQuestInfo(function (r) if r.success then
        _data = SVR.datCache
        ChangeView(v)
    end end)
end

local function Update()
    -- 刷新时间
    if _data then
        if user.allyQstTm.time > 0 then _labTime.text = TimeClock.TimeToString(user.allyQstTm.time)
        else UpdateViewFromServer(0); _data = nil
        end
    end
end

function win.OnLoad(c)
    WinBackground(c, {k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    _body:BindFunction("OnInit", "OnDispose", "OnDispose", "OnExit", "ClickHelp", "ClickMyBounty",
                       "ClickBountyList", "ClickRefresh", "ClickItemGoods", "ClickDelete", 
                       "ClickGoAttack", "ClickGetReward", "ClickAccept")

    _btnBL = _ref.btnBountyList
    _btnMB = _ref.btnMyBounty
    _item = _ref.questItem
    _grid = _ref.questsParent
    _tip = _ref.tip
    _labTime = _ref.refTime
    _labAva = _ref.availableTime
    _labRef = _ref.refProp

    _update = UpdateBeat:CreateListener(Update)
    UpdateBeat:AddListener(_update)

end

function win.OnInit()
    _items = { }
    _view = -1
    PopAllyBounty.isOpen = true
    if _gt == nil then _gt = GridTexture.New(128) end
    local v = PopAllyBounty.initObj or 0
    UpdateViewFromServer(v)
end
-- 刷新任务信息
function win.UpdateQuestInfo(sn, rn)
    if _data and #_data.qstLst > 0 then
        for i = 1, #_data.qstLst do
            if _data.qstLst[i].sn == sn then
                _data.qstLst[i].owner = rn
                break
            end
        end
    end
    if _view ~= 1 then ChangeView(0) end
end

function win.OnExit()
    
end

function win.OnDispose()
    PopAllyBounty.isOpen = false
    if _gt ~= nil then
        _gt:Dispose()
        _gt = nil
    end
    _gt = nil
    _data = nil
    if _items then for i = 1, #_items do Destroy(_items[i]) end end
    _items = nil
    _view = nil
end

function win.OnUnLoad()
    UpdateBeat:RemoveListener(_update)
    _update = nil
    _btnBL = nil
    _btnMB = nil
    _labTime = nil
    _labAva = nil
    _labRef = nil
    _item = nil
    _grid = nil
    _tip = nil
end

------------- 按钮事件

function win.ClickItemGoods(lb) Item.Get(lb):ShowPropTip() end
-- 任务列表
function win.ClickBountyList() ChangeView(0) end
-- 我的任务
function win.ClickMyBounty() ChangeView(1) end
-- 帮助
function win.ClickHelp() Win.Open("PopRule", DB_Rule.AllyQuest) end
-- 揭榜
function win.ClickAccept(lb)
    local info = _data.qstLst[lb]
    if _data.price > 0 then
        MsgBox.Show(string.format(L("主公，是否要花费%d钻石接取悬赏？"), _data.price), L("取消")..","..L("确定"), function (bid) if bid == 1 then
            SVR.AcceptAllyQuest(info.sn, function (r) if r.success then
                _data = SVR.datCache
                ChangeView(_view, true)
                ToolTip.ShowPopTip(L("成功揭榜"))
            end end)
        end end)
    else
        MsgBox.Show(L("主公，是否要接取悬赏？"), L("取消")..","..L("确定"), function (bid) if bid == 1 then
            SVR.AcceptAllyQuest(info.sn, function (r) if r.success then
                _data = SVR.datCache
                ChangeView(_view, true)
                ToolTip.ShowPopTip(L("成功揭榜"))
            end end)
        end end)
    end
end
-- 领取奖励
function win.ClickGetReward(lb)
    SVR.DoneAllyQuest(_data.myQstLst[lb].sn, function (r) if r.success then
        _data = SVR.datCache
        UpdateQuest(lb)
    end end)
end
-- 出击
function win.ClickGoAttack(lb)
    MsgBox.Show("导航功能未完成")
--    local dbi = DB.GetAllyQuest(DB_AllyQst.GetSnFromGR(_data.myQstLst[lb].group, _data.myQstLst[lb].rare))
--    if --[[ PopAssiatant.PaseGuide(dbi.guide) ]] true then 
--        Win.ExitAllWin()
--    end
end
-- 删除任务
function win.ClickDelete(lb)
    MsgBox.Show(L("确定放弃任务？"), L("取消")..","..L("确定"), function (bid) if bid == 1 then
        SVR.GiveUpAllyQuest(_data.myQstLst[lb].sn, function (r) if r.success then
            _data = SVR.datCache
            ChangeView(_view, true)
        end end)
    end end)
end
-- 刷新任务
function win.ClickRefresh(lb)
    local info = _data.myQstLst[lb]
    if info.rare > 4 then MsgBox.Show("任务品质已达最高,无需刷新") return end
    if user.GetPropsQty(DB_Props.SHUA_XIN_JUAN) > 0 then
        SVR.RefreshMyAllyQuest(info.sn, false, function (r) if r.success then
            _data = SVR.datCache
            UpdateQuest(lb)
            UpdateOtherShowInfo()
        end end)
    else
        local str = string.format(L("是否使用%d钻石刷新悬赏任务"), DB.param.prAllyReQuest)
        if CONFIG.tipAllyBounty then
            MsgBox.Show(str, L("否")..","..L("是"), L("{t}不再提示"), function (bid, tgs) if bid == 1 then
                CONFIG.tipAllyBounty = not tgs[0]
                SVR.RefreshMyAllyQuest(info.sn, true, function (r) if r.success then
                    _data = SVR.datCache
                    UpdateQuest(lb)
                    UpdateOtherShowInfo()
                end end)
            end end)
        else
            SVR.RefreshMyAllyQuest(info.sn, true, function (r) if r.success then
                _data = SVR.datCache
                UpdateQuest(lb)
                UpdateOtherShowInfo()
            end end)
        end
    end
end

