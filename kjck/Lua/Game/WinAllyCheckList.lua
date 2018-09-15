local _w = {}
WinAllyCheckList = _w

local _body = nil
WinAllyCheckList.body = _body

local _ref
local _grid

local _isInit = nil
local _isOver = nil
local _isLoading = nil
local _hasRqt = nil
local _datas = nil
local _detlaTm = nil

local function RefreshData()
    if _detlaTm and _detlaTm > Time.realtimeSinceStartup then return end
    _detlaTm = Time.realtimeSinceStartup + 0.03
    local pc = 10
    _isLoading = true
    SVR.GetAllyList(math.toint(#_datas / pc), function (r) 
        if r.success then
            local res = SVR.datCache.lst
            _datas = table.AddNo(_datas, res, "gsn")
            _isOver = #_datas == _grid.realCount
            _grid.realCount = #_datas
            if _isInit then _isInit = false; _grid:Reset() end
        end
        isLoading = false 
    end)
end

function _w.OnLoad(c)
    WinBackground(c, {k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "OnDispose", "OnUnLoad", "OnWrapGridInitItem", "OnWrapGridRequestCount")

    _grid = _ref.scrollView
end

function _w.OnInit()
    _datas = { }
    _isInit = true
end

function _w.OnWrapGridInitItem(grid, item, idx)
    if not _datas and isnull(item) or idx < 0 or idx >= #_datas then return false end
    idx = idx + 1
    local dat = _datas[idx]
    item:GetCmpInChilds(typeof(UIDragScrollView), false).scrollView = scrollView
    local tmp = item:GetCmpsInChilds(typeof(UILabel), false)
    tmp[0].text = dat.gnm
    tmp[1].text = DB.GetNatName(dat.nsn)
    tmp[1].color = ColorStyle.GetNatColor(_datas[idx].nsn)
    tmp[2].text = dat.banner
    tmp[3].text = dat.chief
    tmp[4].text = dat.lv
    tmp[5].text = dat.renown
    tmp[6].text = dat.memberQty

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

function _w.OnDispose()
    _isOver = nil
    _isLoading = nil
    _datas = nil
    _detlaTm = nil
    _isInit = nil
    _hasRqt = nil
    _datas = nil
    _grid:Reset()
end

function _w.OnUnLoad()
    _body = nil
end

