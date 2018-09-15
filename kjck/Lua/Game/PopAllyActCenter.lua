local _w = { }
PopAllyActCenter = _w

local _body = nil
PopAllyActCenter.body = _body

local _ref
local act01
local act02
local act03
local title
local name01
local name02
local name03

function _w.OnLoad(c)
    WinBackground(c, {k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit","OnDispose","OnUnLoad", "OnAct01Click")

    act01 = _ref.act01
    act02 = _ref.act02
    act03 = _ref.act03
    title = _ref.title
    name01 = _ref.lable01
    name02 = _ref.lable02
    name03 = _ref.lable03
end

function _w.OnInit()
    title.text = L("活动中心")
    name01.text = L("悬赏任务")
    name02.text = L("敬请期待")
    name03.text = L("敬请期待")
    
    local btn01 = act01.luaBtn
    local btn02 = act02.luaBtn
    local btn03 = act03.luaBtn

    btn02.isEnabled = false
    btn03.isEnabled = false

    btn01:SetClick("OnAct01Click")
end

function _w.OnAct01Click()
    Win.Open("PopAllyBounty")
end

function _w.OnDispose()
end

function _w.OnUnLoad()
    _body = nil
end