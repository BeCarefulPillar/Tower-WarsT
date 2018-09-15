local _w = { }

local _body = nil
local _ref = nil

--组件绑定
local _btnHelpLeft = nil
local _btnHelpRight = nil
local _panelLeft = nil
local _panelRight = nil
local _myRankLeft = nil
local _myRankRight = nil
local _tipLeft = nil
local _tipRight = nil
local _btnLeft = nil
local _btnRight = nil
local _itemMain = nil
local _title = nil

--3:夺旗（攻城略地）-国家             4:夺旗（攻城略地）-个人
--5:蛮族（蛮族入侵）国家积分榜        6：蛮族（蛮族入侵）个人积分榜 
--7:限时战役（攻守兼备）国家排行      8：限时战役（攻守兼备）个人积分排名)

--3:攻城略地(夺旗)   5:蛮族入侵   7:攻守兼备(限时)  
local kind = -1

--[Comment]
--左边国家数据
local _dataLeft = nil
--[Comment]
--右边个人数据
local _dataRight = nil

--获取数据
local  function GetData()
    _btnLeft:SetActive(kind > 3)
    _btnRight:SetActive(kind < 7)
    if kind == 3 then
        _title.text = L("攻城略地")
    elseif kind == 5 then
        _title.text = L("蛮族入侵")
    elseif kind == 7 then
        _title.text = L("攻守兼备")
    else
        _title.text = L("排行榜")
    end
    SVR.GetRankInfo(kind, function(res)
        if res.success then
            _dataLeft = SVR.datCache
            local nm = _myRankLeft:ChildWidget("name")
            local rk = _myRankLeft:ChildWidget("rank")
            local sc = _myRankLeft:ChildWidget("score")
            --自己排名
            if _dataLeft.info == nil or #_dataLeft.info <= 0 then
                rk.text = "--"
                nm.text = DB.GetNatName(user.nsn)
                sc.text = "--"
            else
                rk.text = _dataLeft.info[1]
                nm.text = DB.GetNatName(user.nsn)
                sc.text = _dataLeft.info[2]
            end
            --所有排名（前10）
            if _dataLeft.lst == nil or #_dataLeft.lst <= 0 then
                _tipLeft:SetActive(true)
            else
                _tipLeft:SetActive(false)
            end
            _panelLeft:Reset()
            _panelLeft.realCount = _dataLeft.lst and #_dataLeft.lst or 0
            print("1111111111111 _dataLeft   ",kjson.print(_dataLeft))
        end
    end)
    coroutine.wait(0.2)
    SVR.GetRankInfo(kind + 1, function(res)
        if res.success then
            _dataRight = SVR.datCache
            local nm = _myRankRight:ChildWidget("name")
            local rk = _myRankRight:ChildWidget("rank")
            local sc = _myRankRight:ChildWidget("score")
            --自己排名
            if _dataRight.info == nil or #_dataRight.info <= 0 then
                rk.text = "--"
                nm.text = user.nick
                sc.text = "--"
            else
                rk.text = _dataRight.info[1]
                nm.text = user.nick
                sc.text = _dataRight.info[2]
            end
            --所有排名（前10）
            if _dataRight.lst == nil or #_dataRight.lst <= 0 then
                _tipRight:SetActive(true)
            else
                _tipRight:SetActive(false)
            end
            _panelRight:Reset()
            _panelRight.realCount = _dataRight.lst and #_dataRight.lst or 0
            print("222222222222222  _dataRight  ",kjson.print(_dataRight))
        end
    end)
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK })
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad","OnWrapGridInitItemLeft","OnWrapGridInitItemRight",
                    "ClickLeft","ClickRight","PressSwitch","DragSwitch")
    _ref = c.nsrf.ref

    _btnHelpLeft = _ref.btnHelpLeft
    _btnHelpRight = _ref.btnHelpRight
    _panelLeft = _ref.panelLeft
    _panelRight = _ref.panelRight
    _myRankLeft = _ref.myRankLeft
    _myRankRight = _ref.myRankRight
    _tipLeft = _ref.tipLeft
    _tipRight = _ref.tipRight
    _btnLeft = _ref.btnLeft
    _btnRight = _ref.btnRight
    _itemMain = _ref.itemMain
    _title = _ref.title

end

function _w.OnInit()
    print("_w.initObj_w.initObj    ",_w.initObj)
    kind = isNumber(_w.initObj) and (_w.initObj > 0 and _w.initObj or 3) or 3
    coroutine.start(GetData)
end

--切换  左
function _w.ClickLeft()
    print("左左左左左左左左左左左")
    if kind <= 3 then
        return
    end
    kind = kind - 2
    coroutine.start(GetData)
end

--切换  右
function _w.ClickRight()
    print("右右右右右右右右右右右")
    if kind >= 7 then
        return
    end
    kind = kind + 2
    coroutine.start(GetData)
end

--长按翻页
function _w.PressSwitch(pressed)
    if pressed then _w.dragDelta = 0
    elseif _w.dragDelta > 35 then _w.ClickLeft()
    elseif _w.dragDelta < -35 then _w.ClickRight()
    end
end

--拖拽翻页
function _w.DragSwitch(delta)
    if delta.x * _w.dragDelta < 0 then _w.dragDelta = 0 end
    _w.dragDelta = _w.dragDelta + delta.x
end

function _w.OnDispose()

end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil

    _btnHelpLeft = nil
    _btnHelpRight = nil
    _panelLeft = nil
    _panelRight = nil
    _myRankLeft = nil
    _myRankRight = nil
    _tipLeft = nil
    _tipRight = nil
    _btnLeft = nil
    _btnRight = nil
    _itemMain = nil
    _title = nil
end

function _w.OnWrapGridInitItemRight(it, idx)
    if idx < 0 then
        return false
    end
    local d = _dataRight.lst[idx + 1]
    local r = it:ChildWidget("rank")
    local rb = it:ChildWidget("rank_bg")
    r:SetActive(d.rank > 3)
    rb:SetActive(d.rank <= 3)
    r.text = d.rank
    rb.spriteName = "sp_rank_"..d.rank

    it:ChildWidget("name").text = d.nick
    it:ChildWidget("score").text = d.val
    return true
end

function _w.OnWrapGridInitItemLeft(it, idx)
    if idx < 0 then
        return false
    end
    local d = _dataLeft.lst[idx + 1]
    local r = it:ChildWidget("rank")
    local rb = it:ChildWidget("rank_bg")
    r:SetActive(d.rank > 3)
    rb:SetActive(d.rank <= 3)
    r.text = d.rank
    rb.spriteName = "sp_rank_"..d.rank

    it:ChildWidget("name").text = d.nick
    it:ChildWidget("score").text = d.val
    
    return true
end

--[Comment]
--国战排行榜
PopNatRankAct = _w