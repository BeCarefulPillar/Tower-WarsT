local _w = {}
PopGveCityInfo = _w

local _body = nil
PopGveCityInfo.body = _body

local _ref
local btnCrime
local labTrap
local labBuff
local item
local toggle
local grid
local city = 0

local data

local function InitItem(i, d)
    local it = i
    local hp = it:Child("heroHp"):GetCmp(typeof(UISlider))
    local mp = it:Child("heroMp"):GetCmp(typeof(UISlider))
    local name = it:ChildWidget("name")
    local icon = it:ChildWidget("icon")
    local atrib1 = it:ChildWidget("attrib_01")
    local atrib2 = it:ChildWidget("attrib_02")
    local atrib3 = it:ChildWidget("attrib_03")
    local atrib4 = it:ChildWidget("attrib_04")
    local atrib5 = it:ChildWidget("attrib_05")

    if d == nil then
        hp.value = 1
        hp:GetCmpInChilds(typeof(UILabel)).text = "??? / ???"
        mp.value = 1
        mp:GetCmpInChilds(typeof(UILabel)).text = "??? / ???"
        name.text = "???"
        atrib1.text = "职业: ???"
        atrib2.text = "武: ???"
        atrib3.text = "智: ???"
        atrib4.text = "统: ???"
        atrib5.text = "兵: ???"
        icon:LoadTexAsync(ResName.DefaultTexture)
    else
        hp.value = d.hp / d.maxHP
        hp:GetCmpInChilds(typeof(UILabel)).text = d.hp .. " / " .. d.maxHP
        mp.value = d.sp / d.maxSP
        mp:GetCmpInChilds(typeof(UILabel)).text = d.sp .. " / " .. d.maxSP
        name.text = d.nm
        atrib1.text = "职业: " .. d.kind
        atrib2.text = "武: " .. d.strength
        atrib3.text = "智: " .. d.wisdom
        atrib4.text = "统: " .. d.captain
        atrib5.text = "兵: " .. d.tp
        icon:LoadTexAsync(ResName.HeroIcon(d.ava))
    end
    it:SetActive(true)
end

local function BuildItems()
    local def = data.guarder
    for i=1, #def do
        local it = grid:AddChild(item, "item_"..i)
        if data.marked == 1 then InitItem(it, def[i])  --已侦察
        elseif data.marked == 0 then InitItem(it, nil) end --未侦察
    end 
    grid:Reposition()
    labBuff.text = "Buff:" .. data.buff
    labBuff:SetActive(not string.isEmpty(data.buff))
    labTrap.text = data.trap < 0 and L("已排除") or (data.trap > 0 and L("有陷阱") or L("无陷阱"))
end

function _w.OnLoad(c)
    WinBackground(c, {k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    btnCrime = _ref.btnCrime
    labTrap = _ref.labTrapstate
    labBuff = _ref.labBuff
    item = _ref.item
    toggle = _ref.use
    grid = _ref.grid
end

function _w.OnInit()
    local o = PopGveCityInfo.initObj
    if type(o) == "number" then
        city = o
        SVR.GveShowCityInfo(city, function(result)
            if result.success then
                data = SVR.datCache
                BuildItems()
            end
        end)
    end
end

function _w.ClickCrime()
    SVR.GveCheckCityInfo(city, toggle.value and 1 or 0, function(result)
        if result.success then
            data = SVR.datCache
            _w.OnDispose()
            BuildItems()
        end
    end)
end

function _w.OnDispose()
    if grid.transform.childCount > 0 then grid:DesAllChild() end
end


