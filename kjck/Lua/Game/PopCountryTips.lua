require "Data/country_tips"

local _w = {}
PopCountryTips = _w

local _body = nil
PopCountryTips.body = _body

local _ref

local item_tips
local scrollView
local tipData

local function BuildItems()
    local len = #tipData
    for i=1, len do
        local dat = tipData[i]

        local it = scrollView:AddChild(item_tips, "item_"..i)
        local name = it:ChildWidget("title")
        local desc = it:ChildWidget("info")
        local img = it:ChildWidget("img")
        local btn = it:Child("btn_go").luaBtn
        btn.luaContainer = _body

        name.text = dat.n
        desc.text = dat.i
        img:LoadTexAsync("tex_countrytip_" .. dat.sn)

        if string.isEmpty(dat.g) then
            btn:SetActive(false)
            desc.width = 512
        else
            if string.isEmpty(dat.r) then
                btn:SetClick(function()
                    if dat.g ~= "WinEmpireTech" then
                        Win.Open(dat.g)
                    end
                end)
            else
                btn:SetClick(function()
                    Win.Open(dat.g, tonumber(dat.r))
                end)
            end
        end
        it:SetActive(true)
    end
    local grid = scrollView:GetCmp(typeof(UIGrid))
    grid.repositionNow = true
end

function _w.OnLoad(c)
    WinBackground(c, { k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    item_tips = _ref.item_tips
    scrollView = _ref.scrollView

    tipData = DB.GetNatTips()

    c:BindFunction("OnInit","OnDispose","OnUnLoad","ClickHelp")
end

function _w.OnInit()
    if tipData ~= nil then
        BuildItems()
    else 
        _body:Exit()
    end
end

function _w.ClickHelp()
    Win.Open("PopRule", DB_Rule.CountryTips)
end

function _w.OnDipose()
    if scrollView.transform.childCount > 0 then  scrollView:DesAllChild() end
end