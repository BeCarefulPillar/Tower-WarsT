local _w = {}
PopAllyRecruitCfg = _w 

local _body = nil
PopAllyRecruitCfg.body = _body

local _ref
local _grid
local _plist

local _isInit = nil
local _isOver = nil
local _isLoading = nil
local _hasRqt = nil
local _datas = nil
local _detlaTm = nil

local pc = 10

local function RefreshData()
    if _detlaTm and _detlaTm > Time.realtimeSinceStartup then return end
    _detlaTm = Time.realtimeSinceStartup + 0.03
    _isLoading = true
    SVR.GetAllyMemberList("req",math.toint(#_datas / pc), function (r) 
        if r.success then
            local res = SVR.datCache.lst
            _datas = table.AddNo(_datas, res, "psn")
            _isOver = #_datas == _grid.realCount
            if _isInit then _isInit = false; _grid:Reset() end
            _grid.realCount = #_datas
        end
        isLoading = false 
    end)
end

function _w.OnLoad(c)
    WinBackground(c, {k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "OnWrapGridInitItem", "OnWrapGridRequestCount", "ClickPopupList", 
                   "ClickAgree", "ClickRefuse", "OnDispose", "OnUnLoad")

    _grid = _ref.grid
    _plist = _ref.plist
end

function _w.OnInit()
    _datas = { }
    _isInit = true
    
    if user.ally.myPerm == 2 then
        _plist.enabled = true
        _plist:Clear()
        _plist:AddItem(L("无限制"))
        _plist:AddItem(L("需审批"))
    else
        _plist.enabled = false
        _plist:Clear()
        _plist.gameObject:SetActive(false)
    end
end

function _w.OnWrapGridInitItem(grid, item, idx)
    if not _datas and isnull(item) or idx < 0 or idx >= #_datas then return false end
    idx = idx + 1
    local dat = _datas[idx]
    item:GetCmpInChilds(typeof(UIDragScrollView), false).scrollView = scrollView
    local tmp = item:GetCmpsInChilds(typeof(UILabel), false)
    tmp[0].text = dat.nick
    tmp[1].text = dat.hlv
    tmp[2].text = dat.intro
    
    local btnY = item:ChildWidget("btn_agree").luaBtn
    local btnN = item:ChildWidget("btn_refuse").luaBtn
    btnY.param = dat
    btnN.param = dat
    return true
end

function _w.OnWrapGridRequestCount(grid)
    if grid.realCount == #_datas then
        if not _isLoading and not _isOver then RefreshData(); return true end
        return false
    end
    grid.realCount = #_datas
    return true
end

function _w.ClickPopupList()
    if _plist.value == "无限制" then
        SVR.GetAllyMemberList("res|0", math.toint(#_datas/pc), function(result) 
            if result.success then
            else
                result.hideErr = true
                ToolTip.ShowPopTip("联盟加入条件已设置为:[00FF00]无限制[-]")
            end 
        end)
    elseif _plist.value == "需审批" then
        SVR.GetAllyMemberList("res|1", math.toint(#_datas/pc), function(result) 
            if result.success then
            else
                result.hideErr = true
                ToolTip.ShowPopTip("联盟加入条件已设置为:[FF0000]需盟主审批[-]")
            end 
        end)
    end
end

local function SetData(d)
    if _datas then
        for i = 1, #_datas do
            if _datas[i].sn == d.sn then _datas[i] = d return end
        end
    end
end

function _w.ClickAgree(p)
    local dat = p
    if CheckSN(dat.psn) ~= nil then
        SVR.AllyOption("agree|"..dat.psn, function(result)
            if result.success then
                _isInit = true
                _datas = {}
                RefreshData()
            end 
        end)
    end
end

function _w.ClickRefuse(p)
    local dat = p
    if CheckSN(dat.psn) ~= nil then
        SVR.AllyOption("refu|"..dat.psn, function(result)
            if result.success then
                _isInit = true
                _datas = {}
                RefreshData()
            end 
        end)
    end
end

function _w.OnDispose()
    _isOver = nil
    _isLoading = nil
    _datas = nil
    _detlaTm = nil
    _isInit = nil
    _hasRqt = nil
    if _grid.transform.childCount > 0 then 
        _grid:DesAllChild() 
        _grid:Reset()
    end
end

function _w.OnUnLoad()
    _body = nil
end

