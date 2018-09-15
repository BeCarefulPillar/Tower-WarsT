local ipairs = ipairs

local ChatChn = ChatChn

local _w = { isOpen = false }
--[Comment]
--聊天
PopChat = _w

local _body = nil
local _ref = nil

local _chns = nil
local _ui = nil
local _items = nil
local _itemPool = nil

local _chnLst = nil

local _curChn = nil
local _viewChn = 0
local _press = false

function _w.OnLoad(c)
    _body = c
    _ref = _body.nsrf.ref

    _ui = 
    {
        ipt = _ref.chatInput,
        iptLbl = _ref.inputLabel,
        chn = _ref.channel,
        chnLbl = _ref.curChannel,
    }
    _ui.itChat = _ref.item_chat
    _ui.itChatSelf = _ref.item_chat_self
    _ui.pnlItems = _ref.items
    _ui.pnlTb = _ui.pnlItems:GetCmp(typeof(UITable))
    _ui.pnlSV = _ui.pnlItems:GetCmp(typeof(UIScrollView))
    var = _ref.filterTab
    _chns = { }
    for i = 0, #var - 1 do
        _chns[i] = var[i+1]
        _chns[i].param = i
    end

    if _chnLst == nil or #_chnLst < 4 then
        _chnLst = 
        {
            { sn = ChatChn.World, nm = ColorStyle.ChatCode(ChatChn.Name(ChatChn.World), 3) },
            { sn = ChatChn.Nat, nm = ColorStyle.ChatCode(ChatChn.Name(ChatChn.Nat), 5) },
            { sn = ChatChn.Ally, nm = ColorStyle.ChatCode(ChatChn.Name(ChatChn.Ally), 4) },
            { sn = ChatChn.Private, nm = ColorStyle.ChatCode(ChatChn.Name(ChatChn.Private), 2) },
        }
    end
    _ui.chn:Clear()
    _ui.chn.separatePanel = false
    for i = #_chnLst, 1, -1 do _ui.chn:AddItem(_chnLst[i].nm) end
    _curChn = _chnLst[1]
    _ui.chnLbl.text = _curChn.nm
    
    _ui.newPri = _ref.newPri


    c:BindFunction("OnUnLoad", "OnInit", "OnDispose",
     "OnChnChange", "OnIptChange", "ClickSend", "PressBg",
     "ClickChn", "ClickItemAva", "ClickItemRedPkt")
end

function _w.OnUnLoad(c)
    if _body == c then
        _body, _chns, _ui = nil, nil, nil
        _items, _itemPool = nil, nil
    end
end

local function RecycleItem(idx)
    if _items and #_items > 0 then
        if _itemPool == nil then _itemPool = { } end
        if idx then
            idx = table.remove(_items, idx)
            idx.go:SetActive(false)
            table.insert(_itemPool, idx)
            for i, it in ipairs(_items) do it.go.name = string.format("item_%02d", i) end
        else
            for _, it in ipairs(_items) do
                it.go:SetActive(false)
                table.insert(_itemPool, it)
            end
            _items = { }
        end
    end
end

local function OnReposition(isCo, instant)
    if isCo then coroutine.step() coroutine.step() coroutine.step() end
    if _press then
        _ui.pnlSV:RestrictWithinBounds(false)
    else
        _ui.pnlSV:ConstraintPivot(UIWidget.Pivot.Bottom, instant == true, true)
    end
end

local function GenChat(d)
    if _viewChn == 0 or _viewChn == d.chn then
        if _items == nil then
            _items = { }
        elseif #_items > CONFIG.MAX_CHAT then
            RecycleItem(1)
        end

--        if SVR.isDebug() then
--            print("内容：" .. tostring(d.text) .. "\ndata.senderSN:" .. tostring(d.sender) .. "\nUser.SN:" .. tostring(user.psn) ..
--                    "\n data.ext:" .. tostring(d.ext) .. "\n玩家：" .. tostring(d.nick) .. "\n玩家头像：" .. tostring(d.ava) .. "\n玩家称号：" .. tostring(d.httl))
--        end

        local it = nil
        local slf = d.sender == user.psn and d.style ~= ChatStyle.RedPacket
        if _itemPool then for i, t in ipairs(_itemPool) do if t.isSelf == slf then it = table.remove(_itemPool, i) break end end end
        if it then
            it.go.name = string.format("item_%02d", #_items + 1)
        else
            it = ItemChat(_ui.pnlItems:AddChild(slf and _ui.itChatSelf or _ui.itChat, string.format("item_%02d", #_items + 1)), slf)
        end
        table.insert(_items, it)
        it:Init(d)
        local btn = it.ava.luaBtn
        btn:SetClick("ClickItemAva", it.go)
        return it
    end
end

local function ChangeView(v, force)
    if _viewChn == v and not force then return end

    _viewChn = v
    if v == ChatChn.Private and _ui.newPri then _ui.newPri:SetActive(false) end
    RecycleItem()

    for i = 0, #_chns do _chns[i].isEnabled = i ~= v end
    for _, c in ipairs(user.chats) do GenChat(c) end
    if _ui.pnlItems.activeInHierarchy then
        _ui.pnlTb:Reposition()
        OnReposition(false, force)
    else
        _ui.pnlTb.repositionNow = true
        coroutine.start(OnReposition, true, force)
    end
end
--新消息
local _onNewChat = OnNewChat:CreateListener(function()
    if _body and _w.isOpen then
        local d = user.chats[#user.chats]
        if _items and #_items > 0 and _items[#_items].dat == d then return end

        if GenChat(d) then
            if _ui.pnlItems.activeInHierarchy then
                _ui.pnlTb:Reposition()
                OnReposition()
            else
                _ui.pnlTb.repositionNow = true
                coroutine.start(OnReposition, true)
            end
        end
    end
end)

local function AddPriItem(psn, name)
    psn = CheckSN(psn)
    if psn and name then
        local chn = nil
        name = ColorStyle.ChatCode(name, ChatChn.Private)
        for _, c in ipairs(_chnLst) do
            if c.nm == nm or c.sn == psn then
                chn = c
                break
            end
        end
        if chn == nil then
            chn = { sn = psn, nm = name }
            table.insert(_chnLst, chn)
            _ui.chn:InsertItem(0, chn.nm)
            if #_chnLst > 10 then
                for i, c in ipairs(_chnLst) do
                    if type(c.sn) == "string" then
                        c = table.remove(_chnLst, i)
                        _ui.chn:RemoveItem(c.nm)
                        break
                    end
                end
            end
        end
        _curChn = chn
        _ui.chnLbl.text = chn.nm
    end
end

function _w.OnInit()
    ChangeView(_viewChn, true)
    _w.isOpen = true
    OnNewChat:AddListener(_onNewChat)
    local var = _w.initObj
    if var then
        if type(var) == "table" then
            if var.psn and var.name then
                AddPriItem(var.psn, var.name)
            end
        end
    end
end

function _w.OnDispose()
    _press = false
    _w.isOpen = false
    OnNewChat:RemoveListener(_onNewChat)
    _ui.ipt.value = ""
    RecycleItem()
end

local function GetChnByNm(nm) for _, c in ipairs(_chnLst) do if c.nm == nm then return c end end end

function _w.OnChnChange()
    local chn = GetChnByNm(_ui.chn.value)
    if chn == nil or (type(chn.sn) == "number" and ChatChn.Invalid(chn.sn)) then return end
    if chn.sn == ChatChn.Private then
        MsgBox.Show(L("输入私聊玩家名字"), L("取消,确定"), nil, "{b16}" .. L("名字"), function(bid, ipt)
            if bid == 1 then
                ipt = ipt[0]
                if ipt and ipt ~= "" then
                    chn = GetChnByNm(ColorStyle.ChatCode(ipt, ChatChn.Private))
                    if chn then
                        _curChn = chn
                        _ui.chnLbl.text = _curChn.nm
                        return
                    end
                    SVR.GetPlayerInfo(ipt, function(t)
                        if t.success then
                            t = SVR.datCache
                            if CheckSN(t.psn) == user.psn then
                                MsgBox.Show(L("你想和自己聊聊天么？"), L("不想") .. "," .. L("不知道") .. "," .. L("想"), function(bid)
                                    if bid == 1 then
                                        ipt = Mathf.Round(math.random(100))
                                        bid = ipt < 51 and 2 or 0
                                        ToolTip.ShowPopTip(string.format(L(ipt < 51 and "老神仙给你卜了一卦(%s):\n\"是时候安慰一下自己啦^-^\"" or "老神仙给你卜了一卦(%s):\n\"小伙子，保请持纯洁哦-_-！\""), ipt))
                                    end
                                    if bid == 2 then AddPriItem(t.psn, t.nick) end
                                end)
                            else
                                AddPriItem(t.psn, t.nick)
                            end
                        end
                    end)
                end
            end
        end)
        return
    elseif chn.sn == ChatChn.Ally then
        if not CheckSN(user.ally.gsn) then
            ToolTip.ShowPopTip(L("你还没有创建或加入联盟"))
            return
        end
    elseif chn.sn == ChatChn.Nat then
        if not CheckSN(user.ally.gsn) then
            ToolTip.ShowPopTip(L("你还没有创建或加入联盟"))
            return
        end
        if not CheckSN(user.ally.nsn) then
            ToolTip.ShowPopTip(L("你所在的联盟还没有加入国家"))
            return
        end
    end
    _curChn = chn
    _ui.chnLbl.text = _curChn.nm
end

function _w.OnIptChange()
    local str = _ui.ipt.value
    local idx = string.find(str, "\n", 1, true)
    if idx then
        idx = string.find(str, "\n", idx + 1, true)
        if idx then
            _ui.ipt.value = string.sub(str, 1, idx - 1)
        end
    end
end

function _w.ClickSend()
    local txt = DB.HX_Filter(_ui.ipt.value)
    if txt == nil or txt == "" then return end

    if not isDebug then
        if user.chatBanTm.time > 0 then
            ToolTip.ShowPopTip(ColorStyle.Bad(string.format(L("您已被禁言！请%s分钟后再发言"), math.ceil(user.chatBanTm.time / 60))))
            return
        end
        if user.chatTm.time > 0 then
            ToolTip.ShowPopTip(ColorStyle.Warning(string.format(L("发言过于频繁，请%s秒后再发言"), user.chatTm.time)))
            return
        end
    end

    local chn = _curChn
    if chn.sn == ChatChn.World then
        SVR.SendChat(0, ChatChn.World, ChatStyle.Text, txt)
    elseif chn.sn == ChatChn.Ally then
        if CheckSN(user.ally.gsn) then
            SVR.SendChat(user.ally.gsn, ChatChn.Ally, ChatStyle.Text, txt)
        else
            _curChn = _chnLst[1]
            _ui.chnLbl.text = _curChn.nm
        end
    elseif chn.sn == ChatChn.Nat then
        if CheckSN(user.ally.nsn) then
            SVR.SendChat(user.ally.nsn, ChatChn.Nat, ChatStyle.Text, txt)
        else
            _curChn = _chnLst[1]
            _ui.chnLbl.text = _curChn.nm
        end
    elseif type(chn.sn) == "string" then
        --私聊
        if CheckSN(chn.sn) then
            local chat = PY_Chat(txt, ChatChn.Private, ChatStyle.Text, nil, user.psn, chn.sn)
            chat.nick = chn.sn == user.psn and L("自言自语中") or string.format(L("我对[FF00FF]%s[-]说"), NGUIText.StripSymbols(chn.nm))
            chat.vip = user.vip
            chat.ava = user.ava
            chat.httl = user.htsn
            SVR.AddNewChat(chat)
            if chn.sn ~= user.psn then
                SVR.SendChat(chn.sn, ChatChn.Private, ChatStyle.Text, txt)
            end
        else
            _curChn = _chnLst[1]
            _ui.chnLbl.text = _curChn.nm
        end
    else
        _curChn = _chnLst[1]
        _ui.chnLbl.text = _curChn.nm
    end
    _ui.ipt.value = ""
end

function _w.ClickChn(chn) ChangeView(chn) end

function _w.PressBg(p) _press = p end

function _w.ClickItemAva(btn)
    btn = Item.Get(btn)
    if btn then
        local cd = btn.dat
        if cd == nil or cd.chn == ChatChn.System or cd.nick == nil or cd.nick == "" then return end
        if CheckSN(cd.sender) then
            if btn.pyDat == nil  then
                btn.pyDat = MsgData.GenPlayer({ "p", cd.nick, cd.sender })
            end
            Win.Open("PopMsgOpt", btn.pyDat)
        end
    end
end

function _w.ClickItemRedPkt(c)
    btn = Item.Get(btn)
    if btn then
        local cd = btn.dat
        if cd == nil or cd.style ~= ChatStyle.RedPacket or cd.ext == nil or cd.ext == "" then return end
        local redsn = tonumber(cd.ext)
        if redsn and redsn > 0 then
            SVR.GetComActRed(redsn, function(t)
                if t.success then
                    Win.Open("PopRedPocket", { dat = SVR.datCache, nick = cd.nick })
                    btn.red.spriteName = "sp_openedRP"
                    cd.flag = 1
                end
            end)
        end
    end
end

_w.ToPri = AddPriItem