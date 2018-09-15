
local isnull = tolua.isnull
local win = { }
WinAllyList = win

local _body = nil
WinAllyList.body = _body

local _ref

local _btnCreat = nil
local _btnSeek = nil
local _pnlMsg = nil
local _labMsgT = nil
local _labMsg = nil
local _grid = nil
local _btnSure = nil
local _btnCancel = nil
local _iptName = nil

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

local function UpdateAllyInfo()
    local tmp = not CheckSN(user.ally.gsn)
    _btnCreat:SetActive(tmp)
    _btnSeek:SetActive(tmp)
    if CONFIG.tipAlly and not _btnCreat.transform:FindChild("ef_frame") then btnCreat:AddChild(ef_frame, "ef_frame") end
    local items = _grid.items
    local tmp1 = nil
    if items and #items > 0 then
        for i = 1, #items do 
            tmp1 = items[i]:GetCmpInChilds(typeof(LuaButton))
            if tmp1 then tmp1.gameObject:SetActive(tmp) end
        end
    end
end

local function OpenJoinPanel(sn, name)
    if sn > 0 then
        _labMsgT.text = L("申请加入:")..name
        _pnlMsg:GetCmp(typeof(UIPanel)).alpha = 0.01
        EF.PlayAni(_pnlMsg, "PopLiteIn", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DoNotDisable)
        _btnSure.param = sn
    end
end

function win.OnLoad(c)
    _body = c
    _ref = _body.nsrf.ref
    WinBackground(c, {k = WinBackground.MASK})

    c:BindFunction("OnInit", "OnDispose", "OnUnLoad", "OnWrapGridInitItem", "OnWrapGridRequestCount",
    "ClickJoin", "ClickJoinSure", "ClickJoinCancel", "ClickCreat", "ClickSeek")

    _btnCreat = _ref.btnCreat
    _btnSeek = _ref.btnSeek
    _pnlMsg = _ref.msgPanel
    _labMsgT = _ref.msgTitle
    _labMsg = _ref.message
    _grid = _ref.scrollView
    _btnSure = _ref.btnSure
    _btnCancel = _ref.btnCancel
    _iptName = _ref.iptName
end

function win.OnInit()
    _datas = { }
    UserAllyChange:Add(UpdateAllyInfo)
    _isInit = true
    UpdateAllyInfo()
end

function win.OnWrapGridInitItem(grid, item, idx)
    if not _datas and isnull(item) or idx < 0 or idx >= #_datas then return false end
    idx = idx + 1
    item:GetCmpInChilds(typeof(UIDragScrollView), false).scrollView = scrollView
    local tmp = item:GetCmpsInChilds(typeof(UILabel), false)
    tmp[0].text = _datas[idx].gnm
    tmp[1].text = DB.GetNatName(_datas[idx].nsn)
    tmp[1].color = ColorStyle.GetNatColor(_datas[idx].nsn)
    tmp[2].text = _datas[idx].banner
    tmp[3].text = _datas[idx].chief
    tmp[4].text = _datas[idx].lv
    tmp[5].text = _datas[idx].renown
    tmp[6].text = _datas[idx].memberQty

    tmp = item:GetCmpInChilds(typeof(LuaButton), false)
    if CheckSN(user.ally.gsn) ~= nil then tmp.gameObject:SetActive(false)
    else
        tmp.gameObject:SetActive(true)
        tmp.param = _datas[idx]
    end
    return true
end

function win.OnWrapGridRequestCount(grid)
    if grid.realCount == #_datas then
        if not _isLoading and not _isOver then RefreshData(); return true end
        return false
    end
    grid.realCount = #_datas
    return true
end

function win.OnDispose()
    _isOver = nil
    _isLoading = nil
    _datas = nil
    _detlaTm = nil
    _isInit = nil
    UserAllyChange:Remove(UpdateAllyInfo)
    local tmp = _btnCreat.transform:FindChild("ef_frame")
    if tmp then Destroy(tmp.gameObject) end
    if CONFIG.tipAlly and (_hasRqt or CheckSN(user.ally.gsn)) then CONFIG.tipAlly = false end
    _hasRqt = nil
end

function win.OnUnLoad()
    _body = nil
    
    _efFrame = nil
    _btnSeek = nil
    _btnCreat = nil
    _pnlMsg = nil
    _labMsgT = nil
    _labMsg = nil
    _btnSure = nil
end

function win.ClickJoin(l)
    OpenJoinPanel(l.gsn, l.gnm)
end

function win.ClickJoinSure(l)
    local tmp = isNumber(l) and l or tonumber(l)
    if tmp > 0 then
        SVR.AllyOption("join|"..tmp.."|"..DB.HX_Filter(_labMsg.value), function (r) if r.success then
            _hasRqt = true
            ToolTip.ShowPopTip(L("申请提交成功!"))
            win.ClickJoinCancel()
        end end)
    end
end

function win.ClickJoinCancel()
    _btnSure.param = nil
    EF.PlayAni(_pnlMsg, "PopLiteOut", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DisableAfterForward)
end

function win.ClickCreat() Win.Open("PopAllyCreat") end

function win.ClickSeek()
    if _iptName.value == "" then return end

    SVR.GetAllyInfoByName(_iptName.value, function (r) 
        if r.success then
            local tmp = SVR.datCache
            OpenJoinPanel(tmp.gsn, tmp.gnm)
        end 
    end)
end



