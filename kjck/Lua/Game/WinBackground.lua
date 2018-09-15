local tp = typeof(NGUISerializeRef)
local setmetatable = setmetatable
local tostring = tostring
local pairs = pairs


local _w = {
    BG = 1,
    MASK = 2,
}

local _arg = {
    --标题
    n = "",
    --类型
    k = _w.BG,
    --是否显示信息
    i = false,
    --帮助id
    r = false,
    --退出回调函数
    exitfc = false,
}

local function RefreshInfo(w)
    if w.k == w.BG and w.i then
        w.labGold.text = tostring(user.gold)
        w.labDiamond.text = tostring(user.rmb)
        w.labSilver.text = tostring(user.coin)
    end
end

local function init(w)
    for i, v in ipairs(w.needs) do
        v:SetActive(i == w.k)
    end

    if w.k == w.BG then
        w.Title = w.labTitle
        w.labTitle.text = w.n

        if w.exitfc then
            w.btnClose:SetClick(w.exitfc)
        else
            w.btnClose:SetClick( function()
--                if not Win.GetOpenWin("MainMap") then
--                    Win.Open("MainMap")
--                end
                w.body:Exit()
            end )
        end

        if w.i then
            w.labGold:SetActive(false)
            w.labDiamond:SetActive(true)
            w.labSilver:SetActive(true)
            w.btnAddGold:SetClick( function()
                Win.Open("PopRecharge", 0)
            end )
            w.btnAddDiamond:SetClick( function()
                Win.Open("PopRecharge", 0)
            end )
            w.btnAddSilver:SetClick( function()
                Win.Open("PopG2C")
            end )

            RefreshInfo(w)

            w.handle = UserDataChange:CreateListener(RefreshInfo, w)
            UserDataChange:AddListener(w.handle)
        end

        if w.r then
            w.btnHelp:SetActive(true)
            w.btnHelp:SetClick( function()
                Win.Open("PopRule", w.r)
            end )
        end

    elseif w.k == w.MASK then
        if w.exitfc then
            w.btnMaskClose:SetClick(w.exitfc)
        else
            w.btnMaskClose:SetClick( function()
                w.body:Exit()
            end )
        end
    end
end

function _w.dispose(w)
    if w.i then
        UserDataChange:RemoveListener(w.handle)
    end
end

local function _call(w, c, arg)
    arg = arg or { }
    local t = c:Child("WinBackground", tp).ref
    t.body = c
    for k, v in pairs(_arg) do
        t[k] = arg[k] == nil and _arg[k] or arg[k]
    end
    setmetatable(t, { __index = w })
    init(t)
    return t
end
setmetatable(_w, { __call = _call })

--[Comment]
--全屏窗口
WinBackground = _w