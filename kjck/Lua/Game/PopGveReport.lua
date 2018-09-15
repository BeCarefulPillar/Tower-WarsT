PopGveReport = { }

local _body = nil
PopGveReport.body = _body

local _ref = nil

local gsn
local scrollView
local page = 0
local datas
local itemR
local itemN
local itemG
local gridTexture

local function InitItem(item, dat)
    local cityName = item:ChildWidget("city_name")
    local info = item:ChildWidget("intro")
    local result = item:ChildWidget("result")
    
    cityName.text = string.format("第%s层%s号城", dat.fsn, dat.csn)
    if dat.rst == 1 then
        result.spriteName = "tag_win"
        info.text = "玩家[3C9A2C]" .. dat.nick .. "[-]战胜了[C11B1B]" .. cityName.text .. "[-]的守将"
    elseif dat.rst == 0 then
        result.spriteName = "tag_failed";
        info.text = "[C11B1B]" .. cityName.text + "[-]的守将战胜了玩家[3C9A2C]" .. dat.nick
    end
    local btn = item.luaBtn
    btn.param = {item, dat}
    btn:SetClick("ClickItem")
    item:SetActive(true)
end

local function BuildItems()
    local cnt = #datas

    for i=1, cnt do
        local it = scrollView:AddChild(itemR, "item_"..i)
        InitItem(it, datas[i])
    end

    scrollView:GetCmp(typeof(UITable)):Reposition()
end

local function InitNPC(it, dat)
    local arrow = it:ChildWidget("spread")
    local th = it:GetCmp(typeof(TweenHeight))
    local detail = it.transform:FindChild("detail")
    local grid = detail.transform:FindChild("grid"):GetCmp(typeof(UIGrid))
    if arrow.gameObject.activeSelf then 
        local npc = dat.def
        for i=1, #npc do
            local hero = npc[i]
            local skills = hero.skills

            local go = grid:AddChild(itemN, "npc_"..i)
            local avatar = go:ChildWidget("icon")
            local npcName = go:ChildWidget("name")
            local soldier = go:ChildWidget("soldier")
            local gridS = go:ChildWidget("skill"):GetCmpInChilds(typeof(UIGrid))
        
            local hp = go.transform:FindChild("heroHp"):GetCmp(typeof(UISlider))
            local sp = go.transform:FindChild("heroMp"):GetCmp(typeof(UISlider))
            avatar:LoadTexAsync(ResName.HeroIcon(hero.ava))
            npcName.text = hero.hnm
            soldier.text = "兵力:"..hero.maxTP
            hp.value = hero.hp /hero.maxHP
            hp:ChildWidget("Label").text = hero.hp .. " / " .. hero.maxHP
            sp.value = hero.sp /hero.maxSP
            sp:ChildWidget("Label").text = hero.sp .. " / " .. hero.maxSP

            if skills ~= nil then
                for j=1, #skills do
                    local s = gridS:AddChild(itemG, "skill_"..j)
                    s = ItemGoods(s)
                    s:Init(DB.GetSkc(skills[j]), true)
                    s.go.luaBtn.luaContainer = _body
                    s.go:SetActive(true)
                end
                gridS.repositionNow = true
            end
            go:SetActive(true)
        end
        grid.repositionNow = true

        th:PlayForward()
        arrow.gameObject:SetActive(false)
        detail.gameObject:SetActive(true)
    else
        th:PlayReverse()
        coroutine.wait(0.3)
        if grid.transform.childCount > 0 then grid:DesAllChild() end
        arrow.gameObject:SetActive(true)
        detail.gameObject:SetActive(false) 
    end
end

function PopGveReport.ClickItem(p)
    local it = p[1]
    local dat = p[2]
    coroutine.start(InitNPC, it, dat)
end

local function Refresh()
    SVR.GveReport(gsn, page, function(result)
        if result.success then
            datas = SVR.datCache
            BuildItems()
        end
    end)
end

function PopGveReport.OnLoad(c)
    _body = c

    c:BindFunction("OnInit", "ClickItem", "OnDispose", "OnUnLoad")

    _ref = _body.nsrf.ref
    table.print("_ref", _ref)

    itemR = _ref.item_report
    itemN = _ref.item_npc
    itemG = _ref.item_goods

    scrollView = _ref.scrollView
end

function PopGveReport.OnInit()
    local o = PopGveReport.initObj
    if o ~= nil and type(o) == "number" then
        gsn = o
    end

    if gridTexture == nil then gridTexture = GridTexture.New() end

    Refresh()
end

function PopGveReport.OnDispose()
    if scrollView.transform.childCount > 0 then scrollView:DesAllChild() end
end

function PopGveReport.OnUnLoad()
    _body = nil
end