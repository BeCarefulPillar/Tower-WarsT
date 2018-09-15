require "Game/ItemDaily"
local bit = require "bit"

local _w = { }

local _body = nil
local _ref = nil

local PROMIN = 0
local PROMAX = 1

local _targets = { }
local _data = {}
-- [Comment]
-- 当前活跃度
local _curActVal = 0
-- [Comment]
-- 最大活跃度
local _maxActVal = 0
local _focusFlag = 0
local _items_dy = nil
local _questList = nil
-- [Comment]
-- 进度条的总长度
local _pro_width = 452
local _buildItems = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c,{n=L("日常"),r=DB_Rule.Daily})

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "OnFocus",
    "OnUnLoad"
    )
end

local function GetUserPeer(p)
    local lv = 0
    if p < 5 then
        lv = 1
    elseif p >= 5 and p < 10 then
        lv = 5
    elseif p >= 10 and p < 15 then
        lv = 10
    elseif p >= 15 and p < 20 then
        lv = 15
    elseif p >= 20 then
        lv = 20
    end
    return lv
end

function _w.OnInit()
    local drws = DB.NatDailyRw()
    _maxActVal = drws[#drws].val
    table.sort(drws,function(x, y)
        return x.val < y.val
    end)
    local tpos = _w.GetTargetPos(#drws)

    for i,v in ipairs(drws) do
        if drws[i].ti == GetUserPeer(user.ttl) then
            local tar = { }
            table.insert(_targets, tar)
            tar.data = drws[i]
            tar.body = _ref.targetRoot:AddChild(_ref.item_target, string.format("item_%02d", i))
            tar.body.luaBtn:SetClick(_w.OnClickTarget, tar)
            tar.body.transform.localPosition = Vector3(v.val / _maxActVal * _pro_width, 0, 0)
            tar.body.transform.localScale = Vector3(0.9, 0.9, 0.9)
            tar.glow = tar.body:Child("glow").gameObject
            tar.labTar = tar.body:ChildWidget("Label")
            tar.labTar.text = tostring(tar.data.val)
            local sp = tar.body.widget
            if notnull(sp) then
                sp.spriteName = "sp_country_box_" ..i
            end
            tar.body:SetActive(true)
        end
    end

    _w.UpdateInfo()
    _w.Refresh()
end

local function GetRec(sn)
    return sn > 0 and bit.band(bit.rshift(_data[2] or 0, (sn +2)%4), 1) == 1
end

function _w.UpdateInfo()
    _ref.labAct.text = tostring(_curActVal)
    _ref.sldAct.value = _curActVal / _targets[#_targets].data.val

    for i,v in ipairs(_targets) do
        local hasAct = v.data.val <= _curActVal
        local notRec = not GetRec(v.data.sn)
        v.body.widget.spriteName =(hasAct and notRec and "sp_country_box_" ..i or "sp_country_box_dis_" ..i)
        v.glow:SetActive(hasAct and notRec)
        v.labTar.applyGradient = hasAct
    end
end

function _w.OnClickTarget(p)
    local tar = p
    if GetRec(tar.data.sn) or _curActVal < tar.data.val then
        --Win.Open("PopItemRw", p)
        Win.Open("PopRwdPreview",tar.data.rw)
    else
        SVR.DailyOpt("get|" .. tar.data.sn, function(rs)
            if rs.success then
                _data = SVR.datCache
                _w.UpdateInfo()
            end
        end )
    end
end

function _w.OnClickGuide(p)
    ToolTip.ShowPopTip(p)
--        if (Manager.PaseGuide(mef.Param as string))
--        {
--            focusFlag = NetTask.CurTaskID;
--            if (Win.GetWins().Length<2)
--            {
--                Exit();
--            }
--        }
end

function _w.OnGetQuestList()
    if not _questList then
        return
    end

    if _items_dy then
        print("_questList",kjson.print(_questList))
        for i = 1, #_questList, 2 do
            local data = DB.GetQuest(_questList[i])
            if _questList[i + 1] >= data.trg then
                for j = 1, #_items_dy do
                    local dy = _items_dy[j]
                    local dt_item = dy:GetData()
                    if dt_item.sn == data.sn then
                        local times = dy:Times()
                        local btnGuide = dy:GetComponentInChildren(typeof(LuaButton))
                        btnGuide:GetCmp(typeof(UIButton)).isEnabled = true
                        local labGuide = btnGuide:GetComponentInChildren(typeof(UILabel))
                        times.text = L("已完成")
                        times.color = Color.green()
                        labGuide.text = L("领 取")
                        btnGuide:GetCmp(typeof(UISprite)).spriteName = "sp_btn_login"
                        btnGuide:GetCmp(typeof(UIButton)).normalSprite = "sp_btn_login"
                        local t = btnGuide.transform.parent.gameObject
                        t.name = "0" .. t.name
                        btnGuide:SetClick(_w.OnClickComplete, dy)
                        break
                    end
                end
            elseif _questList[i + 1] > 0 then
                for j = 1, #_items_dy do
                    local dy = _items_dy[j]
                    local dt_item = dy:GetData()
                    if dt_item.sn == data.sn then
                        local times = dy:Times()
                        local btnGuide = dy:GetComponentInChildren(typeof(LuaButton))
                        local labGuide = btnGuide:GetComponentInChildren(typeof(UILabel))
                        times.text = "(" .. _questList[i + 1] .. "/" .. data.trg .. ")"
                        break
                    end
                end
            end
        end
        _ref.itemRoot:GetCmp(typeof(UIGrid)).repositionNow = true
        _ref.scrollView:ConstraintPivot(UIWidget.Pivot.Top, true)
        return
    end

    local len = #_questList
    _items_dy = { }
    local first = true
    local grid = _ref.itemRoot:GetCmp(typeof(UIGrid))
    _ref.itemRoot:SetActive(false)
    for i = 1, len, 2 do
        local data = DB.GetQuest(_questList[i])
        -- 将国战日常日常分离出来
        if data.kind == 4 then
            local index = i / 2
            local itd = ItemDaily(_ref.itemRoot:AddChild(_ref.item_daily, string.format("item_%02d", index)))
            itd:Init(data, _questList[i + 1])
            table.insert(_items_dy, itd)
            local btnGuide = itd.go:Child("btn_guide").luaBtn
            local labGuide = btnGuide:GetCmpInChilds(typeof(UILabel))
            if _questList[i + 1] < data.trg then
                -- 未完成
                labGuide.text = L("前 往")
                btnGuide:GetCmp(typeof(UISprite)).spriteName = "sp_btn_register"
                btnGuide:SetClick(_w.OnClickGuide, data.guide)
            else
                -- 已完成
                labGuide.text = L("领 取")
                btnGuide:GetCmp(typeof(UISprite)).spriteName = "sp_btn_login"
                btnGuide:SetClick(_w.OnClickComplete, itd)
            end
            itd.go:SetActive(true)

            grid.repositionNow = true
            itd.go:GetCmp(typeof(UIWidget)).alpha=0
            TweenAlpha.Begin(itd.go,0.2,1)
            coroutine.wait(0.01)
            if first then
                first=false
                if toTop then
                    _ref.scrollView:ConstraintPivot(UIWidget.Pivot.Top,true)
                else
                    _ref.scrollView:RestrictWithinBounds(true)
                end
            end
        end
    end

    _ref.itemRoot:GetCmp(typeof(UIGrid)).repositionNow = true
    _ref.scrollView:ConstraintPivot(UIWidget.Pivot.Top,true)
    _ref.itemRoot.gameObject:SetActive(true)
--    _w.CheckTutorial()
end

function _w.CheckTutorial()
    if user.TutorialSN==5 then
        if user.TutorialStep==Tutorial.Step.TutStep02 then
            Tutorial.PlayTutorial(true,_items_dy[1]:Child("btn_guide"))
        end
    end
end

function _w.OnFocus(isFocus)
--        if (isFocus)
--        {
--            if (focusFlag > 0 && focusFlag != NetTask.CurTaskID)
--            {
--                Refresh();
--            }
--            else
--            {
--                focusFlag = 0;
--            }
--        }
--        else
--        {
--            focusFlag = NetTask.CurTaskID;
--        }
end

function _w.OnClickComplete(p)
    local itemdly = p
    local sn = itemdly:GetData().sn
    SVR.CompleteQuest(sn,function(rs)
        if rs.success then
            local res = SVR.datCache
            for i=1,#res do
                local rw=res[i]
                if rw[1]==1 and rw[2]==18 then
                    _curActVal=_curActVal+rw[3]
                    break
                end
            end
            itemdly.go:SetActive(false)
            _w.UpdateInfo()
            _ref.scrollView:GetCmp(typeof(UIGrid)).repositionNow = true
        end
    end)
end

function _w.BuildItems(toTop)
    _w.StopBuildItems()
    _buildItems = coroutine.start(_w.OnGetQuestList)
end

function _w.StopBuildItems()
    if _buildItems then
        coroutine.stop(_buildItems)
        _buildItems = nil
    end
end

local function GetPeerBox(p)
    local name = ""
    if p < 5 then
        name = "[73CC42]优秀[-]"
    elseif p >= 5 and p < 10 then
        name = "[4290cc]精良[-]"
    elseif p >= 10 and p < 15 then
        name = "[a042cc]史诗[-]"
    elseif p >= 15 and p < 20 then
        name = "[cca742]传说[-]"
    elseif p >= 20 then
        name = "[c7241f]神话[-]"
    end
    return name
end

local function GetPeerBoxColor(p)
    local col = ""
    if p < 5 then
        col = "[73CC42]"
    elseif p >= 5 and p < 10 then
        col = "[4290cc]"
    elseif p >= 10 and p < 15 then
        col = "[a042cc]"
    elseif p >= 15 and p < 20 then
        col = "[cca742]"
    elseif p >= 20 then
        col = "[c7241f]"
    end
    return col
end

local function GetNextPeerage(cur)
    local dat = DB.NatDailyRw()
    local nex = 0
    for i=1, #dat do
        if dat[i].ti > cur and (nex == 0 or nex > dat[i].ti) then
            nex = dat[i].ti
        end
    end
    return nex
end

local function ShowPeer()
    _ref.labStatusL.text = GetPeerBox(user.ttl)
    local nex = GetNextPeerage(user.ttl)
    if nex <= 0 then
        _ref.tipBottomRight:SetActive(false)
    else
        _ref.tipBottomRight.text = "[a9a9a8]提升至[-]"..GetPeerBox(nex) .. "[a9a9a8]需要爵位达到[-]" .. GetPeerBoxColor(nex) .. DB.GetTtl(nex).nm
        _ref.tipBottomRight:SetActive(true)
    end
end

function _w.Refresh()
    _focusFlag = 0
    SVR.NatDailyOpt("inf", function(rs)
        if rs.success then
            -- {当前活跃度，领取记录（以二进制形式进行判断），未完成的任务，奖励}
            _data = SVR.datCache
            _curActVal = _data[1]
            _questList = _data[3]
            _w.BuildItems()
            ShowPeer()
            _w.UpdateInfo()
        end
    end )
end

function _w.GetTargetPos(c)
    local p = { }
    if c == 1 then
        p[1] = Vector3(_pro_width, 0, 0)
    elseif c == 2 then
        p[1] = Vector3(0, 0, 0)
        p[2] = Vector3(_pro_width, 0, 0)
    elseif c > 2 then
        c = c - 1
        local dw = _pro_width / c
        for i = 1, c do
            p[i] = Vector3(dw *(i - 1), 0, 0)
        end
        p[c] = Vector3(452, 0, 0)
    end
    return p
end

function _w.OnDispose()
    _ref.itemRoot:DesAllChild()
    _ref.targetRoot:DesAllChild()
    _items_dy=nil
    _questList=nil
    _targets={}
    _w.StopBuildItems()
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        --package.loaded["Game.WinDaily"] = nil
    end
end

-- [Comment]
-- 国战日常
WinCountryActiveBox = _w