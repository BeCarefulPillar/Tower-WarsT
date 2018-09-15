AnnoStyleLua_19 = { }
AnnoStyleLua_19.body = nil

local elements = { }   --消除的元素
local tempData = { }  --备份数据
local quests = { }    --从json数据读取的任务列表
local questNum = { }  --服务器发过来的任务完成情况[任务sn,完成值,任务sn,完成值,.........]
local selecteds = { } --元素被选中的选中框列表
local selectArray = { }  --被选中元素的索引列表
local chooseIndex = -1  --被选中元素的索引
local mSN = 18  --活动的SN
local mData = nil     --从json中读取的活动数据
local labTime = nil --截止时间

function AnnoStyleLua_19.OnLoad(c)
    AnnoStyleLua_19.body = c

    c:BindFunction("OnInit")
    c:BindFunction("OnDispose")
    c:BindFunction("ItemClick")
    c:BindFunction("ClickClean")
    c:BindFunction("ClickRW")
    c:BindFunction("ClickSpecialRw")
    c:BindFunction("ClickItemGoods")
    c:BindFunction("ClickRwOk")
    c:BindFunction("ClickQuest")
    c:BindFunction("ClickQuestClose")
    c:BindFunction("ClickRule")

    local gameObjects = c.gos
    local buttons = c.btns
    local widgets = c.widgets

    item_goods = gameObjects[12]
    --奖励的预制件
    item_quest = gameObjects[14]
    --任务窗口的任务显示模板

    item_element = gameObjects[0]
    --消除元素的显示模板
    item1 = gameObjects[1]
    --奶酪
    item2 = gameObjects[2]
    --酒
    itemSpecial = gameObjects[3]
    --鸡(特殊图案)
    rwPanel2 = gameObjects[5]
    --特殊图案奖励显示面板
    questPanel = gameObjects[6]
    --任务显示面板
    cleanPanel = gameObjects[7]
    rw2Items = gameObjects[13]
    questItems = gameObjects[15]

    rwPanel1 = gameObjects[4]
    --普通图案奖励显示面板
    rw1ScrolView = gameObjects[9]
    rw1Items = gameObjects[10]
    rw1ItemsEvery = gameObjects[11]

    btnClean = buttons[0]
    btnQuest = buttons[1]
    btnRule = buttons[2]
    btnRw1Close = buttons[3]
    btnRw1Ok = buttons[4]
    btnRw2Close = buttons[5]
    btnRw2Ok = buttons[6]
    btnQuestClose = buttons[7]

    cleanCost = widgets[0]
    tipWord = widgets[1]
    rw1Title = widgets[2]
    --   rw2Title = widgets[3]
    labTime = c.widgets[3]

    btnClean:GetComponent(typeof(LuaButton)):SetClick("ClickClean")
    btnQuest:GetComponent(typeof(LuaButton)):SetClick("ClickQuest")
    btnQuestClose:GetComponent(typeof(LuaButton)):SetClick("ClickQuestClose")
    item1:GetComponent(typeof(LuaButton)):SetClick("ClickRW", 1)
    item2:GetComponent(typeof(LuaButton)):SetClick("ClickRW", 2)
    itemSpecial:GetComponent(typeof(LuaButton)):SetClick("ClickSpecialRw")
    btnRw1Close:GetComponent(typeof(LuaButton)):SetClick("ClickRwOk", 1)
    btnRw1Ok:GetComponent(typeof(LuaButton)):SetClick("ClickRwOk", 1)
    btnRw2Close:GetComponent(typeof(LuaButton)):SetClick("ClickRwOk", 2)
    btnRw2Ok:GetComponent(typeof(LuaButton)):SetClick("ClickRwOk", 2)
    btnRule:GetComponent(typeof(LuaButton)):SetClick("ClickRule")
end

function AnnoStyleLua_19.OnInit()
    mData = WinLuaAffair.getDat(AnnoStyleLua_19.body.data)

    rwPanel1.transform.localScale = Vector3.zero
    rwPanel2.transform.localScale = Vector3.zero
    questPanel.transform.localScale = Vector3.zero

    cleanPanel:DesAllChild()
    AnnoStyleLua_19.ClearTable(selecteds)

    local data = "'inf'"
    SVR.SendFunc(Func.ActOpt18, data, function(task)
        if task.success then
            local result = kjson.decode(task.data)
            local str = result[1]
            questNum = result[2]
            elemetData = AnnoStyleLua_19.StringToTable(str)
            for i = 1, #elemetData do
                elements[i] = cleanPanel:AddChild(item_element, string.format("item_element_%02d", i))
                --               elements[i].transform:FindChild("tex"):GetComponent(typeof(UITextureLoader)):Load("tex_act19_e"..elemetData[i])

                local tp = elements[i]:GetComponent(typeof(TweenPosition))
                tp.from = Vector3.New(math.floor((i - 1) / 3) * 104, 104 *((i - 1) % 3 + 1), 0)
                tp.to = Vector3.New(math.floor((i - 1) / 3) * 104, -104 *(3 -(i - 1) % 3 - 1), 0)
                tp.duration = 0.2

                elements[i]:SetActive(true)
                elements[i]:GetComponent(typeof(LuaButton)):SetClick("ItemClick", i)
            end
            for i = 1, #elements do
                elements[i].transform:FindChild("tex"):GetComponent(typeof(UITextureLoader)):Load("tex_act19_e" .. elemetData[i])
            end


            tempData = AnnoStyleLua_19.CopyTable(elemetData)
            AnnoStyleLua_19.InitInfo()
            AnnoStyleLua_19.UpdateInfo()
        end
    end )

end

function AnnoStyleLua_19.ItemClick(s)
    elemetData = AnnoStyleLua_19.CopyTable(tempData)
    if #selecteds > 0 then
        for i = 1, #selecteds do
            if selecteds[i] and selecteds[i].gameObject.activeSelf then selecteds[i]:SetActive(false) end
        end
    end

    AnnoStyleLua_19.ClearTable(selectArray)

    chooseIndex = s
    btnClean:GetComponent(typeof(LuaButton)):SetClick("ClickClean")

    table.insert(selectArray, chooseIndex)

    local s = 1
    while s <= #selectArray and s <= #elemetData do
        local sIdx = selectArray[s]
        if (sIdx - 1) % 3 - 1 >= 0 then
            --下边
            if elemetData[sIdx - 1] == elemetData[sIdx] and elemetData[sIdx - 1] ~= -1 then
                if not AnnoStyleLua_19.IsInTable(sIdx - 1, selectArray) then table.insert(selectArray, sIdx - 1) end
            end
        end
        if (sIdx - 1) -3 >= 0 then
            --左边
            if elemetData[sIdx - 3] == elemetData[sIdx] and elemetData[sIdx - 3] ~= -1 then
                if not AnnoStyleLua_19.IsInTable(sIdx - 3, selectArray) then table.insert(selectArray, sIdx - 3) end
            end
        end
        if (sIdx - 1) % 3 + 1 <= math.sqrt(#elemetData) -1 then
            --上边
            if elemetData[sIdx + 1] == elemetData[sIdx] and elemetData[sIdx + 1] ~= -1 then
                if not AnnoStyleLua_19.IsInTable(sIdx + 1, selectArray) then table.insert(selectArray, sIdx + 1) end
            end
        end
        if (sIdx - 1) + 3 <= #elemetData - 1 then
            --右边
            if elemetData[sIdx + 3] == elemetData[sIdx] and elemetData[sIdx + 3] ~= -1 then
                if not AnnoStyleLua_19.IsInTable(sIdx + 3, selectArray) then table.insert(selectArray, sIdx + 3) end
            end
        end

        elemetData[sIdx] = -(sIdx + 1)
        s = s + 1
    end
    for i = 1, #selectArray do
        local go = elements[selectArray[i]].transform:FindChild("choice")
        go:SetActive(true)
        selecteds[i] = go
    end

end

function AnnoStyleLua_19.ClickClean()
    if chooseIndex < 0 then
        MsgBox.Show("主公，请先选择一个要消除的图案")
    else
        local data = "'get|" .. chooseIndex .. "'"
        SVR.SendFunc(Func.ActOpt18, data, function(task)
            if task.success then
                for i = 1, #selectArray do
                    if elements[selectArray[i]] then
                        elements[selectArray[i]].gameObject:Destroy()
                        elements[selectArray[i]] = nil
                    end
                end
                AnnoStyleLua_19.ClearTable(selectArray)
                local result = kjson.decode(task.data)
                local ele = AnnoStyleLua_19.StringToTable(result[1])
                rewards = result[3]
                questNum = result[2]
                AnnoStyleLua_19.RefreshElement(ele)
                --SFSServer.AnalyzeReward(LuaTool.RewardTabToStr(rewards))
                PopRewardShow.Show(rewards)

                AnnoStyleLua_19.UpdateInfo()
                chooseIndex = -1
            end
        end )
    end
end

function AnnoStyleLua_19.RefreshElement(e)
    for i = 1, #elemetData do
        if tonumber(elemetData[i]) < 0 then
            --如果这个位置是空的
            if elements[i] == nil then
                --如果此位置的物体是空的
                if (i - 1) % 3 + 1 < 3 then
                    --上面没越界
                    if tonumber(elemetData[i + 1]) >= 0 then
                        --如果它上面一行不是空的
                        if (i - 1) % 3 + 2 < 3 then
                            --如果上上层没越界  是第一行
                            if tonumber(elemetData[i + 2]) >= 0 then
                                --如果上上面一行不是空的
                                elemetData[i] = elemetData[i + 1]
                                elemetData[i + 1] = elemetData[i + 2]
                                elemetData[i + 2] = -1

                                elements[i] = elements[i + 1]
                                elements[i + 1].name = "item_element_0" .. i

                                elements[i + 1] = elements[i + 2]
                                elements[i + 1].name = "item_element_0" ..(i + 1)
                                elements[i + 2] = cleanPanel:AddChild(item_element, "item_element_0" ..(i + 2))
                            else
                                --上上面一行是空的
                                elemetData[i] = elemetData[i + 1]
                                elemetData[i + 1] = -1

                                elements[i] = elements[i + 1]
                                elements[i + 1].name = "item_element_0" .. i
                                elements[i + 1] = cleanPanel:AddChild(item_element, "item_element_0" ..(i + 1))
                                elements[i + 2] = cleanPanel:AddChild(item_element, "item_element_0" ..(i + 2))
                            end
                        else
                            --第二行
                            elemetData[i] = elemetData[i + 1]
                            elemetData[i + 1] = -1

                            elements[i] = elements[i + 1]
                            elements[i + 1].name = "item_element_0" .. i
                            elements[i + 1] = cleanPanel:AddChild(item_element, "item_element_0" ..(i + 1))
                        end
                    else
                        --上面一行是空的
                        if (i - 1) % 3 + 2 < 3 then
                            --第一层
                            if tonumber(elemetData[i + 2]) >= 0 then
                                --上上层不是空的
                                elemetData[i] = elemetData[i + 2]
                                elemetData[i + 2] = -1

                                elements[i] = elements[i + 2]
                                elements[i + 2].name = "item_element_0" .. i
                                elements[i + 1] = cleanPanel:AddChild(item_element, "item_element_0" ..(i + 1))
                                elements[i + 2] = cleanPanel:AddChild(item_element, "item_element_0" ..(i + 2))
                            else
                                --上面都为空
                                elements[i] = cleanPanel:AddChild(item_element, "item_element_0" .. i)
                                elements[i + 1] = cleanPanel:AddChild(item_element, "item_element_0" ..(i + 1))
                                elements[i + 2] = cleanPanel:AddChild(item_element, "item_element_0" ..(i + 2))
                            end
                        else
                            --第二层
                            elements[i] = cleanPanel:AddChild(item_element, "item_element_0" .. i)
                            elements[i + 1] = cleanPanel:AddChild(item_element, "item_element_0" ..(i + 1))
                        end
                    end
                else
                    --最上一层
                    elements[i] = cleanPanel:AddChild(item_element, "item_element_0" .. i)
                end
            end
        end
    end
    tempData = AnnoStyleLua_19.CopyTable(elemetData)
    elemetData = AnnoStyleLua_19.CopyTable(e)

    for i = 1, #tempData do
        --elements[i].transform:FindChild("tex"):GetComponent(typeof(UITextureLoader)):Load("tex_act19_e"..elemetData[i])
        if tonumber(tempData[i]) < 0 then
            --如果为空 则在上面生成
            local tp = elements[i]:GetComponent(typeof(TweenPosition))
            tp.from = Vector3.New(math.floor((i - 1) / 3) * 104, 104 *((i - 1) % 3 + 1), 0)
            tp.to = Vector3.New(math.floor((i - 1) / 3) * 104, -104 *(3 -(i - 1) % 3 - 1), 0)
            tp.duration = 0.2

            elements[i]:SetActive(true)
            elements[i]:GetComponent(typeof(LuaButton)):SetClick("ItemClick", i)
        else
            local len = string.len(elements[i].name)
            local newIdx = string.sub(elements[i].name, len)
            local tp = elements[i]:GetComponent(typeof(TweenPosition))
            tp.from = elements[i].transform.localPosition
            tp.to = Vector3.New(math.floor((tonumber(newIdx) -1) / 3) * 104, -104 *(3 -(tonumber(newIdx) -1) % 3 - 1), 0)
            elements[i]:GetComponent(typeof(LuaButton)):SetClick("ItemClick", i)
            elements[i].transform.localPosition = tp.to
        end
    end
    for i = 1, #elements do
        elements[i].transform:FindChild("tex"):GetComponent(typeof(UITextureLoader)):Load("tex_act19_e" .. elemetData[i])
    end

    tempData = AnnoStyleLua_19.CopyTable(elemetData)
    AnnoStyleLua_19.ClearTable(selecteds)
    AnnoStyleLua_19.ClearTable(selectArray)
end

--点击任务按钮
function AnnoStyleLua_19.ClickQuest()
    questItems:DesAllChild()
    for i = 3, #quests do
        local item = questItems:AddChild(item_quest, string.format("item_quest_%03d", i))
        local content = item.transform:FindChild("content"):GetComponent(typeof(UILabel))
        local num = item.transform:FindChild("num"):GetComponent(typeof(UILabel))
        local rwItems = item.transform:FindChild("items"):GetComponent(typeof(UIGrid))

        content.text = quests[i].c
        if questNum[i * 2] < quests[i].t then
            num.text = questNum[i * 2] .. "/" .. quests[i].t
        else
            num.text = "[00FF00]" .. L("已完成") .. "[-]"
            item.name = string.format("item_quested_%03d", i)
        end

        local rew = quests[i].rw
        for m = 1, #rew do
            local ig = ItemGoods(rwItems.gameObject:AddChild(item_goods, "rw_" .. m))
            ig.go.transform.localScale = Vector3.one * 0.95
            ig:Init(rew[m])
            ig.go.luaBtn.luaContainer = AnnoStyleLua_19.body
            ig:HideName()
        end

        rwItems.repositionNow = true
        item:SetActive(true)
    end
    local grid = questItems:GetComponent(typeof(UIGrid))
    grid.repositionNow = true
    AnnoStyleLua_19.PlayTween(questPanel)
end

--点击任务关闭按钮
function AnnoStyleLua_19.ClickQuestClose()
    questItems:DesAllChild()
    questPanel:GetComponent(typeof(TweenScale)):PlayReverse()
    questPanel:GetComponent(typeof(TweenAlpha)):PlayReverse()
    questItems:GetComponent(typeof(UIScrollView)):ResetPosition()
end

--点击普通图案
function AnnoStyleLua_19.ClickRW(s)
    rw1ScrolView:GetComponent(typeof(UIScrollView)):ResetPosition()
    local rw = s == 1 and reward1 or reward2

    rw1Items:DesAllChild()
    rw1ItemsEvery:DesAllChild()
    --销毁奖励
    for i = 1, #rw do
        local ig = ItemGoods(rw1Items:AddChild(item_goods, string.format("item_%03d", i)))
        ig:Init(rw[i])
        ig.go.luaBtn.luaContainer = AnnoStyleLua_19.body
    end
    --每个图案的奖励
    local rwe = s == 1 and rewardEvery1 or rewardEvery2
    if rwe then
        for i = 1, #rwe do
            local ig = ItemGoods(rw1ItemsEvery:AddChild(item_goods, string.format("item_%03d", i)))
            ig:Init(rwe[i])
            ig.go.luaBtn.luaContainer = AnnoStyleLua_19.body
        end
    end

    rw1Items:GetComponent(typeof(UIGrid)).repositionNow = true
    rw1ItemsEvery:GetComponent(typeof(UIGrid)).repositionNow = true

    AnnoStyleLua_19.PlayTween(rwPanel1)
end

--点击说明按钮
function AnnoStyleLua_19.ClickRule()
    Win.Open("PopRule", mData.rule)
end

function AnnoStyleLua_19.PlayTween(panel)
    coroutine.resume(
    coroutine.create( function()
        coroutine.wait(0.05)
        panel:GetComponent(typeof(TweenScale)):PlayForward()
        panel:GetComponent(typeof(TweenAlpha)):PlayForward()
    end )
    )
end

function AnnoStyleLua_19.ClickRwOk(s)
    if s == 1 then
        rwPanel1:GetComponent(typeof(TweenScale)):PlayReverse()
        rwPanel1:GetComponent(typeof(TweenAlpha)):PlayReverse()
        --       CloseRwPreview(s, rwPanel1)
    elseif s == 2 then
        rwPanel2:GetComponent(typeof(TweenScale)):PlayReverse()
        rwPanel2:GetComponent(typeof(TweenAlpha)):PlayReverse()
        --       CloseRwPreview(s, rwPanel2)
    end
end

--关闭窗口后删除子物体(暂时不能用 否则窗口只能打开一次)
function AnnoStyleLua_19.CloseRwPreview(s, panel)
    coroutine.resume(
    coroutine.create( function()
        coroutine.wait(0.2)
        panel:DesAllChild()
    end )
    )
end

function AnnoStyleLua_19.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then btn:ShowPropTip() end
end

--点击特殊图案
function AnnoStyleLua_19.ClickSpecialRw()
    rw2Items:DesAllChild()
    rw2Items:GetComponent(typeof(UIScrollView)):ResetPosition()
    for i = 1, #specialRW do
        local ig = ItemGoods(rw2Items:AddChild(item_goods, string.format("item_%03d", i)))
        ig:Init(specialRW[i])
        ig.go.luaBtn.luaContainer = AnnoStyleLua_19.body
        ig:HideName()
    end
    rw2Items:GetComponent(typeof(UIGrid)).repositionNow = true
    AnnoStyleLua_19.PlayTween(rwPanel2)
end

function AnnoStyleLua_19.InitInfo()
    if mData then
        tipWord.text = mData.btn
        cleanCost.text = mData.cost
    end

    quests = mData.q
    reward1 = quests[1].rw
    --销毁奖励1
    reward2 = quests[2].rw
    --销毁奖励2
    rw1Title.text = quests[1].c

    rewardEvery1 = quests[1].rwe
    --每次销毁奖励1
    rewardEvery2 = quests[2].rwe
    --每次销毁奖励2

    specialRW = mData.rs.rw
    --AnnoStyleLua_19.time_ing = coroutine.create(AnnoStyleLua_19.UpdateTime)
    --coroutine.resume(AnnoStyleLua_19.time_ing, mData.time)
    LuaActTimer(AnnoStyleLua_19.body,mData.time)
end

function AnnoStyleLua_19.UpdateInfo()
    local num1 = item1.transform:FindChild("num")
    num1:GetComponent(typeof(UILabel)).text =(questNum[2] % quests[1].t)
    local slider1 = item1.transform:FindChild("slider")
    slider1:GetComponent(typeof(UISprite)).fillAmount =(questNum[2] % quests[1].t) / quests[1].t

    local num2 = item2.transform:FindChild("num")
    num2:GetComponent(typeof(UILabel)).text =(questNum[4] % quests[2].t)
    local slider2 = item2.transform:FindChild("slider")
    slider2:GetComponent(typeof(UISprite)).fillAmount =(questNum[4] % quests[2].t) / quests[2].t
end

--将字符串按字节的方式转换成table(需注意字符串的编码格式)
function AnnoStyleLua_19.StringToTable(str)
    local table = { }
    for i = 1, string.len(str) do
        local byte = string.byte(str, i)
        local char = string.char(byte)
        table[i] = char
    end
    return table
end

--检查指定元素是否在table里
function AnnoStyleLua_19.IsInTable(value, table)
    for k, v in pairs(table) do
        if v == value then return true end
    end
    return false
end

--复制table
function AnnoStyleLua_19.CopyTable(obj)
    local InTable = { };
    local function Func(obj)
        if type(obj) ~= "table" then
            --判断表中是否有表
            return obj;
        end
        local NewTable = { };
        --定义一个新表
        InTable[obj] = NewTable;
        --若表中有表，则先把表给InTable，再用NewTable去接收内嵌的表
        for k, v in pairs(obj) do
            --把旧表的key和Value赋给新表
            NewTable[Func(k)] = Func(v);
        end
        return setmetatable(NewTable, getmetatable(obj))
        --赋值元表
    end
    return Func(obj)
    --若表中有表，则把内嵌的表也复制了
end

--清空table
function AnnoStyleLua_19.ClearTable(t)
    if "table" == type(t) then
        while #t > 0 do
            table.remove(t)
        end
        return t
    end
end