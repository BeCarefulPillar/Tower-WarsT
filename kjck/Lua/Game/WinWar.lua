local _w = { }

local _body = nil
local _ref = nil
local _dat = nil

function _w.OnLoad(c)
    _body = c
    _w.body = _body
    _ref = c.nsrf.ref

    c:BindFunction(
    "OnInit",
    "Help",
    "OnFocus",
    "OnDispose",
    "ClickItem",
    "OnEnter",
    "ClickTurnTable",
    "OnWrapGridInitItem",
    "OnUnLoad"
    )
end

local function UpdateInfo()
    _ref.turncoin.text = tostring(user.GetPropsQty(DB_Props.ZHUAN_PAN_BI))
end
_w.UpdateInfo = UpdateInfo

local function BuildItems()
    if _dat and _dat.wars and #_dat.wars > 0 then
        _ref.grid:Reset()
        _ref.grid.realCount = #_dat.wars
    else
        _ref.grid:Reset()
        _ref.grid.realCount = 0
    end
end

function _w.OnInit()
    SVR.GetWarInfo("inf", function(t)
        if t.success then
            --stab.S_WarInfo
            _dat = SVR.datCache
            _ref.arrow:SetActive(#_dat.wars>3)
            UpdateInfo()
            BuildItems()
        end
    end )
end

function _w.OnEnter()
    UpdateInfo()
end

function _w.OnDispose()
    _ref.arrow:SetActive(false)
end

function _w.OnFocus(isFocus)
    if isFocus then
        UpdateInfo()
    end
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_dat.wars then
        return false
    end

    local wd = DB.GetWar(_dat.wars[i + 1])

    if wd and wd.rws then
        for i, v in ipairs(wd.rws) do
            if v[1] == 2 and v[2] == 123 then
                item:Child("tex_turntable"):ChildWidget("Label").text = tostring(v[3])
                break
            end
        end
    end

    item:Child("bg_di"):ChildWidget("name").text = wd.nm
    item:GetCmp(typeof(UITexture)):LoadTexAsync(ResName.WarImage(wd.sn))

    local btn = item.luaBtn
    if user.hlv >= wd.lock then
        btn.isEnabled = true
        btn.param = wd.sn
        btn.luaContainer = _body
    else
        btn.isEnabled = false
        local f = item:Child("frame")
        f:SetActive(true)
        f:ChildWidget("tip_lv").text = L("主城") .. wd.lock .. L("级解锁")
    end

    return true
end

function _w.ClickTurnTable()
    Win.Open("PopTurntable")
end

function _w.Help()
    Win.Open("PopRule", DB_Rule.War)
end

function _w.ClickItem(sn)
    local wd = DB.GetWar(sn)
    if user.hlv >= wd.lock then
        Win.Open("PopWarDetail", sn)
    else
        ToolTip.ShowPropTip(wd.nm, ColorStyle.Bad(L("需要主城达到") .. wd.lock .. L("级")))
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
        --package.loaded["Game.WinWar"] = nil
    end
end

--[Comment]
--战役
WinWar = _w