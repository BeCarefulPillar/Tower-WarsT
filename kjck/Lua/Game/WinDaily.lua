require "Game/ItemDaily"
local bit = require "bit"

local _w = { }

local _body = nil
local _ref = nil

local PROMIN = 0
local PROMAX = 1

local _targets = nil
local _data = {}
-- [Comment]
-- 当前活跃度
local _curActVal = 0
-- [Comment]
-- 最大活跃度
local _maxActVal = 0
local _items_dy = nil
local _questList = nil
-- [Comment]
-- 进度条的总长度
local _pro_width = 452
local _buildItems = nil
local _bg = nil
local _lastTask = 0

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c,{n=L("日常"),i=true,r=DB_Rule.Daily})
end

local function PriRefresh()
    _lastTask = 0
    _w.OnDispose()
    SVR.DailyOpt("inf", function(rs)
        if rs.success then
            -- {当前活跃度，领取记录（以二进制形式进行判断），未完成的任务，奖励}
            _data = SVR.datCache
            _curActVal = _data[1]
            _questList = _data[3]
            -- 全部任务完成后的提示
            if #_questList > 0 then
                _ref.labTip:SetActive(false)
            else
                _ref.labTip:SetActive(true)
            end
            _w.BuildItems()
            _w.UpdateInfo()
        end
    end )
end

function _w.OnInit()
    local drws = DB.AllDailyRw()
    _maxActVal = drws[#drws].val
    table.sort(drws,function(x, y)
        return x.val < y.val
    end)
    local tpos = _w.GetTargetPos(#drws)

    _targets = {}
    _ref.targetRoot:DesAllChild()
    for i,v in ipairs(drws) do
        local tar = { }
        table.insert(_targets, tar)
        tar.data = drws[i]
        tar.body = _ref.targetRoot:AddChild(_ref.item_target, string.format("item_%02d", i))
        tar.body.luaBtn.param = tar
        tar.body.transform.localPosition = Vector3(v.val / _maxActVal * _pro_width, 0, 0)
        tar.body.transform.localScale = Vector3(0.9, 0.9, 0.9)
        tar.glow = tar.body:Child("glow").gameObject
        tar.labTar = tar.body:ChildWidget("Label")
        tar.labTar.text = tostring(tar.data.val)
        local sp = tar.body.widget
        if notnull(sp) then
            sp.spriteName = "sp_country_box_" ..(i - 1)
        end
        tar.body:SetActive(true)
    end

    _w.UpdateInfo()
    PriRefresh()
end

local function GetRec(sn)
    return sn > 0 and bit.band(bit.rshift(_data[2] or 0, sn - 1), 1) == 1
end

function _w.UpdateInfo()
    _ref.labAct.text = tostring(_curActVal)
    _ref.sldAct.value = _curActVal / _targets[#_targets].data.val

    for i,v in ipairs(_targets) do
        local hasAct = v.data.val <= _curActVal
        local notRec = not GetRec(v.data.sn)
        v.body.widget.spriteName =(notRec and "sp_country_box_" ..(i - 1) or "sp_country_box_dis_" ..(i - 1))
        v.glow:SetActive(hasAct and notRec)
        v.labTar.applyGradient = hasAct
    end
end

function _w.OnClickTarget(p)
    local tar = p
    if GetRec(tar.data.sn) or _curActVal < tar.data.val then
        Win.Open("PopRwdPreview",tar.data.rws)
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
    if Guide.PaseGuide(p) then
--        if Win.GetWins().Length<5 then
--            _body:Exit()
--        end
    end
end

function _w.OnGetQuestList()
    if not _questList then
        return
    end

    if _items_dy then
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
                        if user.hlv >= data.openLv then
                            if data.guide == "WinFB" and not user.IsHistroyUL then
                                labGuide.text = string.format(L("攻陷%s解锁"), DB.GetGmCity(DB.UL_History).nm)
                                btnGuide:GetCmp(typeof(UIButton)).isEnabled = false
                            else
                                btnGuide:GetCmp(typeof(UIButton)).isEnabled = true
                                times.text = "(" .. _questList[i + 1] .. "/" .. data.trg .. ")"
                            end
                        else
                            labGuide.text = L("主城") .. data.openLv .. L("级开放")
                            btnGuide:GetCmp(typeof(UIButton)).isEnabled = false
                        end
                        break
                    end
                end
            end
        end
        _ref.itemRoot:GetCmp(typeof(UIGrid)).repositionNow = true
        _ref.itemRoot:ConstraintPivot(UIWidget.Pivot.Top, true)
        return
    end

    local len = #_questList
    _items_dy = { }
    local first = true
    local grid = _ref.itemRoot:GetCmp(typeof(UIGrid))
    for i = 1, len, 2 do
        local data = DB.GetQuest(_questList[i])
        -- 将日常分离出来
        if data.kind == 0 then
            local index = i / 2
            local itd = ItemDaily(_ref.itemRoot:AddChild(_ref.item_daily, string.format("item_%02d", index)))
            itd:Init(data, _questList[i + 1])
            table.insert(data, itd)

            local btnGuide = itd.go:GetComponentInChildren(typeof(LuaButton))
            local labGuide = btnGuide:GetComponentInChildren(typeof(UILabel))
            if user.hlv >= data.openLv then
                if data.guide == "WinFB" and not user.IsHistroyUL then
                    itd.go.name = "z_" .. itd.go.name
                    labGuide.text = string.format(L("攻陷%s开放"), DB.GetGmCity(DB.UL_History).nm)
                    btnGuide:GetCmp(typeof(UIButton)).isEnabled = false
                else
                    btnGuide:GetCmp(typeof(UIButton)).isEnabled = true
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
                end
            else
                itd.go.name = "z_" .. itd.go.name
                labGuide.text = L("主城") .. data.openLv .. L("级开放")
                btnGuide:GetCmp(typeof(UIButton)).isEnabled = false
            end
            itd.go:SetActive(true)

            grid.repositionNow = true
            itd.go:GetCmp(typeof(UIWidget)).alpha=0
            TweenAlpha.Begin(itd.go,0.2,1)
            coroutine.wait(0.01)
            if first then
                first=fale
                if toTop then
                    _ref.itemRoot:ConstraintPivot(UIWidget.Pivot.Top,true)
                else
                    _ref.itemRoot:RestrictWithinBounds(true)
                end
            end
        end
    end

    _ref.itemRoot:GetCmp(typeof(UIGrid)):Reposition()
    _ref.itemRoot:GetCmp(typeof(UIGrid)).repositionNow = true
    _ref.itemRoot:ConstraintPivot(UIWidget.Pivot.Top,true)
    _w.CheckTutorial()
end

function _w.CheckTutorial()
    if user.TutorialSN==5 then
        if user.TutorialStep==Tutorial.Step.TutStep02 then
            Tutorial.PlayTutorial(true,_items_dy[1]:Child("btn_guide"))
        end
    end
end

function _w.OnFocus(isFocus)
    if isFocus then
        if _lastTask>0 and _lastTask~=SvrTask.GID then
            PriRefresh()
        else
            _lastTask = 0
        end
    else
        _lastTask = SvrTask.GID
    end
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
            _ref.itemRoot:GetCmp(typeof(UIGrid)).repositionNow = true
            _ref.itemRoot:ConstraintPivot(UIWidget.Pivot.Top,true)
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
    _items_dy=nil
    _questList=nil
    _w.StopBuildItems()
    _lastTask = 0
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _bg:dispose()
        _bg = nil
    end
end

-- [Comment]
-- 日常
WinDaily = _w