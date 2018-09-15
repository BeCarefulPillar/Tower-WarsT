local ipairs = ipairs

local _w = { }
WinLuaAffair = _w

local _body = nil
local _ref = nil
local _bg = nil

--[Comment]
--btn - 数据
local _dat = nil
local _tips = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c, { i = true })
end

local function BuildAffair()
    _w.OnDispose()
    --[[
    local jsonData = DB_Affair
    for i = 1, table.maxn(jsonData) do
        if jsonData[i] then
            local jData = jsonData[i]
            if jData.keep == 1 then
                --常开活动
                affairs[i] = jData
            elseif jData.keep == 0 then
                --有时间限制的活动
                local sTime = os.time(jData.stime)
                --GetTimeStamp(jData.stime)  --活动开启时间
                local endTime = os.time(jData.time)
                --GetTimeStamp(jData.time) --活动结束时间
                local now = os.time()
                local t1 = now - sTime
                local t2 = endTime - now
                if t1 > 0 and t2 > 0 then
                    affairs[i] = jData
                end
            end
        end
    end
    ]]

    _dat = { }
    local sBtn, wBtn = nil, nil
    local act = DB.Get(LuaRes.Affair)
    for i, v in ipairs(act) do
        local btn = _ref.tab:AddChild(_ref.item, string.format("tab_%02d", i)).luaBtn
        _dat[btn] = v
        btn:SetActive(true)
        local t = table.find(_tips, v.sn)
        btn:Child("tip_tag"):SetActive(t ~= 0 and _tips[t + 1] == 1)
        btn:ChildWidget("Label").text = v.name
        if v.name == _w.initObj then
            wBtn = btn
        end
        if not sBtn then
            sBtn = btn
        end
    end
    _ref.tab.repositionNow = true

    if wBtn then
        _w.OnTabClicked(wBtn)
    elseif sBtn then
        _w.OnTabClicked(sBtn)
    end
end

local function PriRefresh()
    SVR.AffairOption("lst", function(t)
        if t.success then
            _tips = SVR.datCache.tips
            BuildAffair()
        end
    end )
end

function _w.OnInit()
    PriRefresh()
end

function _w.OnDispose()
    _ref.tab:DesAllChild()
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
        _tips = nil
        _bg:dispose()
        _bg = nil
    end
end

function _w.OnTabClicked(btn)
    for b, _ in pairs(_dat) do
        b.isEnabled = true
        b.label.color = Color(0.74, 0.65, 0.43)
        b.label.effectStyle = UILabel.Effect.None
    end
    btn.isEnabled = false
    btn.label.color = Color(1, 0.95, 0.54)
    btn.label.effectStyle = UILabel.Effect.Outline
    _body:ShowPage(_dat[btn].style, _body.transform, btn)
end

local function UpdateTips()
    for btn, d in pairs(_dat) do
        local t = table.find(_tips, d.sn)
        btn:Child("tip_tag"):SetActive(t ~= 0 and _tips[t + 1] == 1)
    end
end

function _w.RefreshInfo(tips)
    if tips then
        _tips = tips
        UpdateTips()
    else
        SVR.AffairOption("lst", function(t)
            if t.success then
                _tips = SVR.datCache.tips
                UpdateTips()
            end
        end )
    end
end

function _w.Dat()
    return _dat
end

function _w.getDat(btn)
    return btn and _dat and _dat[btn] or nil
end