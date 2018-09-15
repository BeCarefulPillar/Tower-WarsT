require "Game/ItemQuest"
local ipairs = ipairs

--[Comment]
--任务
local _w = { }
WinQuest = _w

local _body = nil
local _ref = nil

local _view = 0
local _list = nil
local _quests = nil
local _timeList = nil
local _sIdx = nil
local _selected = nil


function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { n = L("任务") })

    for i, v in ipairs(_ref.btnTabs) do
        v.param = i - 1
    end

    local t = os.date("*t")
    t = {year=t.year,month=t.month,day=t.day,hour=23,min=59,sec=59}
    LuaActTimer(c,t,LuaActTimer.quest)
end

local function ShowInfoPanel()
    _ref.desc.text = ""

    if _selected and _selected.dat.kind==2 then
        _ref.time:SetActive(true)
    else
        _ref.time:SetActive(false)
    end

    _ref.btnComplete:SetActive(false)

    _ref.rewards:DesAllChild()

    if _selected then
        _ref.desc.text = _selected.dat.i
        if _view == 2 then
            local flag = _selected.IsCompleded or string.notEmpty(_selected.dat.guide)
            _ref.btnComplete:SetActive(flag)
            _ref.btnComplete:ChildWidget("Label").text = _selected.IsCompleded and L("领 取") or L("去完成")
        else
            local flag = _selected.IsCompleded or string.notEmpty(_selected.dat.guide)
            _ref.btnComplete:SetActive(flag)
            _ref.btnComplete:ChildWidget("Label").text = _selected.IsCompleded and L("领 取") or L("去完成")
        end

        if _selected.dat.rws then
            for i, v in ipairs(_selected.dat.rws) do
                local ig = ItemGoods(_ref.rewards:AddChild(_ref.item_goods, string.format("reward_%02d", i)))
                ig:Init(v)
                ig.go.luaBtn.luaContainer = _body
            end
            _ref.rewards.repositionNow = true
        end
    end
end

local function DisposeObj()
    _selected = nil
    ShowInfoPanel()
end

local function RefreshTab()
    local mainCnt = 0
    local auxiliaryCnt = 0
    local timeCnt = 0
    if _list then
        for i = 1, #_list, 2 do
            local data = DB.GetQuest(_list[i])
            if _list[i + 1] >= data.trg then
                if data.kind == 1 then
                    mainCnt = mainCnt + 1
                elseif data.kind == 5 then
                    auxiliaryCnt = auxiliaryCnt + 1
                elseif data.kind == 2 then
                    timeCnt = timeCnt + 1
                end
            end
        end
    end

    if _timeList then
        for i = 1, #_timeList, 2 do
            local data = DB.GetQuest(_timeList[i])
            if _timeList[i + 1] >= data.trg then
                if data.kind == 1 then
                    mainCnt = mainCnt + 1
                elseif data.kind == 5 then
                    auxiliaryCnt = auxiliaryCnt + 1
                elseif data.kind == 2 then
                    timeCnt = timeCnt + 1
                end
            end
        end
    end

    _ref.btnTabs[1].text = L("主线") ..(mainCnt > 0 and ColorStyle.Good("[" .. mainCnt .. "]") or "")
    _ref.btnTabs[2].text = L("支线") ..(auxiliaryCnt > 0 and ColorStyle.Good("[" .. auxiliaryCnt .. "]") or "")
    _ref.btnTabs[3].text = L("限时") ..(timeCnt > 0 and ColorStyle.Good("[" .. timeCnt .. "]") or "")
end

local function BuildItems()
    local _curList = _view == 2 and _timeList or _list
    _sIdx = 1
    DisposeObj()

    local typ = -1
    if _view == 0 then
        typ = 1
    elseif _view == 1 then
        typ = 5
    elseif _view == 2 then
        typ = 2
    end

    _quests = { }
    for i = 1, #_curList, 2 do
        local data = DB.GetQuest(_curList[i])
        if data.kind == typ then
            table.insert(_quests, _curList[i])
            table.insert(_quests, _curList[i + 1])
        end
    end

    _ref.grid:Reset()
    _ref.grid.realCount = #_quests / 2
end

local function OnGetTimeQuestList(t)
    if t.success then
        --stab.S_QuestList
        local res = SVR.datCache
        user.questQty = res.doneQty
        user.changed = true
        _timeList = res.lst
        RefreshTab()
        if _view == 2 then
            BuildItems()
        end
    end
end

local function OnGetQuestList(t)
    if t.success then
        --stab.S_QuestList
        local res = SVR.datCache
        user.questQty = res.doneQty
        user.changed = true
        _list = res.lst
        RefreshTab()
        if _view ~= 2 then
            local iv = type(_w.initObj) == "number" and _w.initObj or 0
            if iv == -1 then
                _w.initObj = 0
                local v = 0
                if _list then
                    local c0 = 0
                    local c1 = 0
                    for i = 1, #_list, 2 do
                        local data = DB.GetQuest(_list[i])
                        if _list[i + 1] >= data.trg then
                            if data.kind == 1 then
                                c0 = c0 + 1
                            elseif data.kind == 5 then
                                c1 = c1 + 1
                            end
                        end
                    end
                    v =(c0 <= 0 and c1 > 0) and 1 or 0
                end
                ChangeView(v, true)
            else
                BuildItems()
            end
        end
    end
end

local function GetData()
    if _view == 2 then
        SVR.GetTimeQuestList(OnGetTimeQuestList)
        coroutine.wait(0.2)
        SVR.GetQuestList(OnGetQuestList)
    else
        SVR.GetQuestList(OnGetQuestList)
        coroutine.wait(0.2)
        SVR.GetTimeQuestList(OnGetTimeQuestList)
    end
end

local function ChangeView(v, force, reload)
    if _view == v and not force then
        return
    end
    DisposeObj()
    ShowInfoPanel()
    _view = v

    local t = nil
    for i, v in ipairs(_ref.btnTabs) do
        f = i - 1 ~= _view
        v.isEnabled = f
        v.label.color = f and ColorStyle.TabColorNormal_2 or Color(1, 1, 1)
        v.label.effectColor = ColorStyle.black or ColorStyle.OutLight_2
    end

    if reload then
        coroutine.start(GetData)
    else
        BuildItems()
    end
end

function _w.OnInit()
    local t = type(_w.initObj) == "number" and _w.initObj or 0
    ChangeView(math.clamp(t, 0, #_ref.btnTabs), true, true)
end

function _w.ClickItemGoods(btn)
    local ig = Item.Get(btn.gameObject)
    if ig then
        ig:ShowPropTip()
    end
end

function _w.ClickSortTab(i)
    BGM.PlaySOE("sound_click_btn")
    ChangeView(i, false)
end

function _w.ClickItemQuest(btn)
    local iq = Item.Get(btn.gameObject)

    if iq and iq.dat.sn > 0 and iq ~= _selected then
        if _selected then
            _selected.Selected = false
        end
        for i, v in ipairs(_quests) do
            if v == iq.dat.sn then
                _sIdx = i
            end
        end
        _selected = iq
        _selected.Selected = true
        ShowInfoPanel()
    end
end

function _w.OnWrapGridInitItem(item, i)
    local ti = i * 2 + 1
    local data = DB.GetQuest(_quests[ti])

    local iq = ItemQuest(item)
    iq:Init(data, _quests[ti + 1])
    iq.go.luaBtn.luaContainer = _body
    iq.go.widget.alpha = 0
    TweenAlpha.Begin(iq.go, 0.2, 1)

    iq.Selected = ti == _sIdx
    if ti == _sIdx then
        _w.ClickItemQuest(iq.go.luaBtn)
    end

    return true
end

function _w.ClickComplete()
    if not _selected or _selected.dat.sn <= 0 then
        return
    end
    if _selected.IsCompleded then
        if _selected.dat.kind == 5 then
            SVR.SideQuest(_selected.dat.sn, function(result)
                if result.success then
                    ChangeView(_view, true, true)
                end
            end )
        else
            SVR.CompleteQuest(_selected.dat.sn, function(result)
                if result.success then
                    ChangeView(_view, true, true)
                end
            end )
        end
    elseif (Guide.PaseGuide(_selected.dat.guide)) then
        _body:Exit()
    end
end

function _w.OnDispose()
    _list = nil
    _timeList = nil
    _view = 0
    DisposeObj()
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _list = nil
        _quests = nil
        _timeList = nil
        _sIdx = nil
        _selected = nil
    end
end