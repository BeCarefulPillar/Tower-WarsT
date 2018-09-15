--过关斩将中的成就
PopLuaTowerAchievement = { }
local body = nil

local localData = nil	--本地json数据
local netDatas = nil		--网络数据
local currentTab = nil	--当前标签
local count = 20		--20个一组

local tabTemplate = nil		--标签item
local itemTemplate = nil	--奖励item
local gridTabs = nil		--标签父物体
local gridItems = nil		--奖励父物体
local item_goods = nil

local gridTexture = nil

local itemPool = nil
local tabs = { }
local createItem_ing = nil	--创建item的协程

function PopLuaTowerAchievement.OnLoad(c)
    body = c

    c:BindFunction("OnInit")
    c:BindFunction("ClickTab")
    c:BindFunction("ClickGetRw")
    c:BindFunction("ClickGetRwPerfect")
    c:BindFunction("ClickItemGoods")
    c:BindFunction("OnFocus")

    tabTemplate = c.gos[0]
    itemTemplate = c.gos[1]
    gridTabs = c.gos[2]
    gridItems = c.gos[3]
    item_goods = c.gos[4]

    itemPool = require("Data/ItemPool").new()
    localData = DB.Get("tower_rw")
end

function PopLuaTowerAchievement.OnInit()
    if gridTexture == nil then
        gridTexture = GridTexture()
    end

    currentTab = nil
    netDatas = { }
    PopLuaTowerAchievement.BuildTab()
end

--创建左边的标签
function PopLuaTowerAchievement.BuildTab()
    local len = math.ceil(#localData / count)
    itemPool:RemoveChilds(gridTabs)
    tabs = { }
    for i = 1, len do
        local it = itemPool:CreateItem(gridTabs, tabTemplate)
        it.name = "tab_" .. i
        it.luaBtn.param = i

        local startIdx =(i - 1) * count + 1
        --起始点
        local endIdx = startIdx + count - 1
        --结束点
        if endIdx > #localData then endIdx = #localData end
        it:GetComponentInChildren(typeof(UILabel)).text = L("第") .. i .. L("层")
        tabs[i] = it
    end
    gridTabs:GetComponent(typeof(UIGrid)).repositionNow = true
    PopLuaTowerAchievement.ClickTab(1)
end

--当标签被点击，创建item	i=关卡
function PopLuaTowerAchievement.ClickTab(i)
    if currentTab == i then return end

    currentTab = i
    if netDatas[i] == nil then
        netDatas[i] = { }
        local sendData = string.format("'',%s", i)
        SVR.SendFunc(Func.TowerAchievement, sendData, function(result)
            if result.success == true then
                local arr = kjson.decode(result.data)[2]
                --把sn作为键
                for k, v in ipairs(arr) do
                    netDatas[i][v[1]] = v
                end
                if createItem_ing ~= nil then coroutine.stop(createItem_ing) end
                createItem_ing = coroutine.create(PopLuaTowerAchievement.BuildItem)
                coroutine.resume(createItem_ing, i, true)
            end
        end )
    else
        if createItem_ing ~= nil then coroutine.stop(createItem_ing) end
        createItem_ing = coroutine.create(PopLuaTowerAchievement.BuildItem)
        coroutine.resume(createItem_ing, i, true)
    end
end

function PopLuaTowerAchievement.BuildItem(i, toTop)
    PopLuaTowerAchievement.ChangeTabView()
    itemPool:RemoveChilds(gridItems)
    local startIdx =(currentTab - 1) * count + 1
    --起始点
    local endIdx = startIdx + count - 1
    --结束点
    local len = #localData
    if endIdx > len then endIdx = len end

    for i = startIdx, endIdx do
        coroutine.step()
        local it = itemPool:CreateItem(gridItems, itemTemplate)
        it.name = string.format("%03d", i)
        local rwData = localData[i]
        if rwData ~= nil then
            local ref = it:GetComponent(typeof(LuaSerializeRef))
            ref.widgets[0].text = L("第") .. rwData.sn .. L("关")
            local btn1 = ref.btns[0]
            local btn2 = ref.btns[1]

            if netDatas[currentTab][i] == nil then break end
            if netDatas[currentTab][i][2] == 1 then
                --还没打到那一关
                PopLuaTowerAchievement.SetBtnEnabled(btn1, false, L("未通关"))
            elseif netDatas[currentTab][i][2] == 0 then
                --首次通关未领取
                btn1:SetClick("ClickGetRw", rwData.sn)
                PopLuaTowerAchievement.SetBtnEnabled(btn1, true, L("领 取"))
            elseif netDatas[currentTab][i][2] == 2 then
                --已领取
                PopLuaTowerAchievement.SetBtnEnabled(btn1, false, L("已领取"))
            end
            if netDatas[currentTab][i][3] == 1 then
                PopLuaTowerAchievement.SetBtnEnabled(btn2, false, L("未通关"))
            elseif netDatas[currentTab][i][3] == 0 then
                --完美通关未领取
                btn2:SetClick("ClickGetRwPerfect", rwData.sn)
                PopLuaTowerAchievement.SetBtnEnabled(btn2, true, L("领 取"))
            elseif netDatas[currentTab][i][3] == 2 then
                --已领取
                PopLuaTowerAchievement.SetBtnEnabled(btn2, false, L("已领取"))
            end

            --创建通关goods
            local goodss1 = ref.gos[0]
            itemPool:RemoveChilds(goodss1)
            if rwData.rws1 then
                for i = 1, #rwData.rws1 do
                    local gd = itemPool:CreateItem(goodss1, item_goods)
                    gd.transform.localScale = Vector3.one * 0.75
                    PopLuaTowerAchievement.InitGoods(gd, rwData.rws1[i])
                    gridTexture:Add(gd:GetComponentInChildren(typeof(UITextureLoader)))
                end
            end
            goodss1:GetComponent(typeof(UIGrid)).repositionNow = true
            --完美通关goods
            local goodss2 = ref.gos[1]
            itemPool:RemoveChilds(goodss2)
            if rwData.rws2 then
                for i = 1, #rwData.rws2 do
                    local gd = itemPool:CreateItem(goodss2, item_goods)
                    gd.transform.localScale = Vector3.one * 0.75
                    PopLuaTowerAchievement.InitGoods(gd, rwData.rws2[i])
                    gridTexture:Add(gd:GetComponentInChildren(typeof(UITextureLoader)))
                end
            end
            goodss2:GetComponent(typeof(UIGrid)).repositionNow = true
        end
        gridItems:GetComponent(typeof(UIGrid)):Reposition()
        --每创建一个item设置一下位置
        if i == startIdx and toTop == true then
            --回到顶部
            gridItems:GetComponent(typeof(UIScrollView)):ConstraintPivot(UIWidget.Pivot.Top, true)
        end
    end
end

--[Comment]
--点击领取奖励
function PopLuaTowerAchievement.ClickGetRw(i)
    local sendData = string.format("'ps|%s',%s", i, currentTab)
    SVR.SendFunc(Func.TowerAchievement, sendData, function(result)
        if result.success == true then
            local arr = kjson.decode(result.data)
            netDatas[currentTab] = { }
            for k, v in ipairs(arr[2]) do
                netDatas[currentTab][v[1]] = v
            end
            PopRewardShow.Show(arr[3])
        end
    end )
end

--[Comment]
--点击领取完美奖励
function PopLuaTowerAchievement.ClickGetRwPerfect(i)
    local sendData = string.format("'pf|%s',%s", i, currentTab)

    SVR.SendFunc(Func.TowerAchievement, sendData, function(result)
        if result.success == true then
            local arr = kjson.decode(result.data)
            netDatas[currentTab] = { }
            for k, v in ipairs(arr[2]) do
                netDatas[currentTab][v[1]] = v
            end
            PopRewardShow.Show(arr[3])
        end
    end )
end

--[Comment]
--刷新状态
function PopLuaTowerAchievement.OnFocus(isFocus)
    if isFocus then
        if createItem_ing then
            coroutine.stop(createItem_ing)
        end
        createItem_ing = coroutine.create(PopLuaTowerAchievement.BuildItem)
        coroutine.resume(createItem_ing, i, false)
    end
end

--初始化item_goods
function PopLuaTowerAchievement.InitGoods(gd, gData)
    local ig = ItemGoods(gd)
    ig:Init(gData)
    ig.go.luaBtn.luaContainer = body
end

--[Comment]
--点击goods
function PopLuaTowerAchievement.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then btn:ShowPropTip() end
end

--[Comment]
--改变tab的高亮，模仿toggle组
function PopLuaTowerAchievement.ChangeTabView()
    for k, v in ipairs(tabs) do
        if k == currentTab then
            v:GetComponent(typeof(UISprite)).spriteName = "btn_13"
        else
            v:GetComponent(typeof(UISprite)).spriteName = "btn_12"
        end
    end
end

--[Comment]
--设置按钮
function PopLuaTowerAchievement.SetBtnEnabled(btn, isEnabled, lbl)
    btn:GetComponent(typeof(UISprite)).spriteName = isEnabled and "sp_btn_login" or "btn_disabled"
    btn:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = isEnabled
    btn:GetComponentInChildren(typeof(UILabel)).text = lbl
end