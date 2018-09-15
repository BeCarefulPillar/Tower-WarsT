PopLuaTreasure = { }
PopLuaTreasure.body = nil

local labGold = nil
local btnSelect = nil
local btnGet = nil
local btnRefresh = nil
local btnCheckReward = nil
local selectTip = nil
local item_goods = nil
local item_select = nil
local todayReward = nil
local ef_Refresh = nil
local gridItems = nil
local tomDayIndex = nil     -- 明日奖励索引(1 2 3)
local selectFrame = nil        -- 选择框
local selectItem = nil      -- 选择列表
local selectIndex = 0       -- 选择索引

local leftTime = 0
local delta = 0
local annoRewards = { }  -- xml表中的r
local annoSn = { }       -- xml表中的sn
local annoDay = { }      -- xml表中的d
local itemsTom = nil        -- 奖励列表的值
local toDay = 0 -- 索引到的当前天数
local tomIndex = 0     -- 明日奖励索引

local _db = nil
local _dat = nil

function PopLuaTreasure.OnLoad(c)
    WinBackground(c, { k = WinBackground.MASK })


    PopLuaTreasure.body = c
    local body = PopLuaTreasure.body

    _db = DB.Get(LuaRes.Treasure)

    local widgets = PopLuaTreasure.body.widgets
    labGold = widgets[0]

    local buttons = PopLuaTreasure.body.btns
    btnSelect = buttons[1]
    btnGet = buttons[2]
    btnRefresh = buttons[4]
    btnCheckReward = buttons[5]

    local gameObjects = PopLuaTreasure.body.gos
    selectTip = gameObjects[0]
    item_goods = gameObjects[1]
    item_select = gameObjects[2]
    todayReward = gameObjects[3]
    ef_Refresh = gameObjects[4]

    local objects = PopLuaTreasure.body.objs
    gridItems = objects[0]
end

function PopLuaTreasure.OnInit()
    -- local str = "'inf'"
    local refresh = false
    PopLuaTreasure.BuildAnno()
    -- SVR.SendFunc(Func.Treasure, str, function(result)
    SVR.Treasure("inf", function(result)
        if result.success then
            _dat = SVR.datCache
            tomDayIndex = _dat.tomIndex
            local dexSn = _dat.sn
            if dexSn < 0 then dexSn = - dexSn end
            toDay = PopLuaTreasure.GetDaySn(dexSn) + 1
            PopLuaTreasure.UpdataTod(_dat)
            PopLuaTreasure.UpdataTom(refresh, _dat)
        end
    end )
end

function PopLuaTreasure.BuildAnno()
    print("~~~~~~~~~~~~~BuildAnno~~~~~~~~~~~~~")
    local annoData = _db
    -- 获取Json数据
    local annoR = annoData
    for i = 1, #annoR do
        table.insert(annoRewards, annoR[i].rws)
        table.insert(annoSn, annoR[i].sn)
        table.insert(annoDay, annoR[i].day)
    end

    --    local node = XmlDataGet.RewardString("a308",data.a308)
    --    local nodecp = XmlDataGet.TagValue("c",data.a308)
    --    if data == nil then
    --         --print("~~~~~~~~~~~~~data~~~~~~~~~~~~~",data)
    --        ToolTip.ShowPopTip(ColorStyle.Bad( L("加载失败！请尝试刷新。")))
    --        Exit()
    --            return
    --    end
    if annoRewards == nil then
        MsgBox.Show(L("数据异常！"))
        PopLuaTreasure.body:Exit()
    end
    -- 刷新剩余时间
    --    leftTime = PopLuaTreasure.GetLeftTime()
    --    labTime.text = L("活动剩余时间:") .. PopLuaTreasure.GetLeftTimeDesc(leftTime)

    LuaActTimer(PopLuaTreasure.body, user.regTm+7*86400-SVR.SvrTime(), LuaActTimer.seven)
end




-- 生成今天和明天的奖励
function PopLuaTreasure.UpdataTod(dat)
    --     print("~~~~~~~~~~~~~~~~~~UpdataTod________________")

    local rewToday = dat.rws
    local sn = dat.sn

    if dat.sn > 0 then
        btnGet:GetComponent(typeof(UIButton)).isEnabled = true
        btnGet:GetComponentInChildren(typeof(UILabel)).text = L("领 取")
    else
        btnGet:GetComponent(typeof(UIButton)).isEnabled = false
        if dat.sn == 0 then
            btnGet:GetComponentInChildren(typeof(UILabel)).text = L("无奖励")
        else
            btnGet:GetComponentInChildren(typeof(UILabel)).text = L("已领取")
        end
    end
    if dat.sn < 0 then sn = - dat.sn end
    -- 生成今天
    if rewToday ~= nil then
        local rewards = { }
        if sn < 0 then sn = - sn end
        rewards = annoRewards[sn]
        -- 根据sn 获取奖励
        for i = 0, #rewToday do
            local ig = ItemGoods(todayReward:AddChild(item_goods, string.format("item_%03d", i)))
            -- itemsTod = go.gameObject
            ig:Init(rewards[1])
            ig.go:SetActive(true)
            ig.go.luaBtn.luaContainer = PopLuaTreasure.body
        end
    end
end

-- 生成明日奖励
function PopLuaTreasure.UpdataTom(refresh, dat)
    print("~~~~~~~~~~~~~~_UpdataTom____明日奖励__________")
    labGold.text = dat.refPrice
    itemsTom = #dat.tomRewards
    -- 明日奖励列表,有3个sn
    tomIndex = dat.tomIndex
    -- 当前选择的明日奖励索引(1 2 3)
    print(tomIndex)
    if tomIndex > 0 then
        -- 已经选择
        if itemsTom ~= nil then
            -- for   j = 1,itemsTom  do
            local sn = dat.tomRewards[tomIndex]
            -- 通过已经选好奖励索引到sn
            --            print("_________sn:___ " ,sn )
            local b = annoRewards[sn]
            -- 根据sn 获取奖励
            local ig = ItemGoods(gridItems:AddChild(item_goods, string.format("item_%03d", tomIndex)))
            ig.go:SetActive(true)
            ig:Init(b[1])
            ig.go.luaBtn.luaContainer = PopLuaTreasure.body

            print("----")
            selectFrame = ig.go:AddChild(item_select, "select")
            selectFrame:SetActive(true)
            btnSelect:GetComponent(typeof(UIButton)).isEnabled = false
            btnSelect:GetComponentInChildren(typeof(UILabel)).text = L("明日可领秘宝")
        end
        -- end
        btnRefresh:SetActive(false)
        selectTip:SetActive(false)

    else
        -- 还未选择
        ----print("__________【还未选择】________________")
        for i = 1, itemsTom do
            local sn = dat.tomRewards[i]
            -- for循环寻找每个sn
            --            print("_________sn:___ " ,sn )
            local b = annoRewards[sn]
            -- 根据sn 获取奖励
            local ig = ItemGoods(gridItems:AddChild(item_goods, string.format("item_%03d", i)))
            if b ~= nil then
                for j = 0, #b[1] do
                    ig:Init(b[1])
                    if tomIndex == 0 then
                        ig.go.luaBtn:SetClick(PopLuaTreasure.OnClickGoods, i)
                    elseif i == tomIndex then
                        selectFrame = ig.go:AddChild(item_select, "select")
                        selectItem = ig.go
                        selectFrame:SetActive(true)
                        btnSelect:GetComponent(typeof(UIButton)).isEnabled = false
                        btnSelect:GetComponentInChildren(typeof(UILabel)).text = L("明可领秘宝")
                    end
                end
            end
            ig.go:SetActive(true)
        end
        selectTip:SetActive(true)
        btnRefresh:SetActive(true)
    end
    if refresh then
        for i = 1, itemsTom do
            local itemsEf = gridItems.transform:FindChild(string.format("item_%03d", i)).gameObject
            local ef = itemsEf:AddChild(ef_Refresh, "ef_refresh")
            ef:SetActive(true)
        end
    end
    gridItems:GetComponent(typeof(UIGrid)).repositionNow = true
end

-- 根据sn得到天数
function PopLuaTreasure.GetDaySn(dexsn)
    -- print("~~~~~~~~~~~~PopLuaTreasure.GetDaySn")
    local sn = annoSn
    -- 获取XML表中的所有SN
    local day = annoDay
    -- 获取XML表中的所有day
    if sn ~= nil then
        for i = 0, #sn do
            if sn[i] == dexsn then
                ----print("______根据sn得到dai[i]_____",day[i])
                return day[i]
            end
        end
    else
        return nil
    end
end

function PopLuaTreasure.OnDispose()
    -- 删除明日道具
    if tomIndex > 0 then
        Destroy(gridItems.transform:FindChild(string.format("item_%03d", tomIndex)).gameObject)
    else
        if gridItems.transform.childCount > 0 then
            for i = 1, 3 do
                -- 写死，3个奖励
                selectItem = gridItems.transform:FindChild(string.format("item_%03d", i)).gameObject
                Destroy(selectItem.gameObject)
            end
        end
    end
    itemsTom = nil
    selectFrame = nil
    selectItem = nil
    selectIndex = 0
    delta = 0
    annoRewards = { }
end

-- 选择明天想要的物品
function PopLuaTreasure.OnClickGoods(btn, i)
    local ig = btn and Item.Get(btn.gameObject)
    local index = i
    if index == selectIndex then return end
    if selectItem then
        -- 删除原有的
        for i = 1, 3 do
            -- 写死 删除3个选择框
            if selectFrame then
                selectFrame.gameObject:Destroy()
                selectFrame = nil
            end
        end
    end
    -- 新建选择框
    selectIndex = index
    selectItem = gridItems.transform:FindChild("item_00" .. index).gameObject
    selectFrame = selectItem:AddChild(item_select, "select")
    selectFrame:SetActive(true)
    ig:ShowPropTip()
end

-- 确认选择明天的奖励
function PopLuaTreasure.OnClickSelect()
    if selectIndex <= 0 then
        MsgBox.Show(L("请选择明天的奖励！"))
        return
    end
    MsgBox.Show(L("确认选择后，明日登录可领取选择的奖励，选择后不可修改，是否确认？"), L("取消,确定"), function(input)
        if input == 1 then
            local str = "'slt|" .. selectIndex .. "'"
            SVR.Treasure("slt|" .. selectIndex, function(t)
                if t.success then
                    _dat = SVR.datCache
                    PopLuaTreasure.Dispose()
                    PopLuaTreasure.BuildAnno()
                    PopLuaTreasure.UpdataTom(false, _dat)
                end
            end )
        end
    end )
end

-- 领取
function PopLuaTreasure.OnClickGet()
    SVR.Treasure("get", function(t)
        if t.success then
            _dat = SVR.datCache
            if _dat.sn > 0 then
                btnGet:GetComponent(typeof(UIButton)).isEnabled = true
                btnGet:GetComponentInChildren(typeof(UILabel)).text = L("领 取")
            else
                btnGet:GetComponent(typeof(UIButton)).isEnabled = false
                if _dat.sn == 0 then
                    btnGet:GetComponentInChildren(typeof(UILabel)).text = L("无奖励")
                else
                    btnGet:GetComponentInChildren(typeof(UILabel)).text = L("已领取")
                end
            end
        end
    end )
end

-- 大宝箱
function PopLuaTreasure.OnClickBigBox()
    local f = annoRewards
    if annoRewards ~= nil and f ~= nil then
        f = nil
        local lrw = { }
        for i = 0, #annoRewards do
            if i >= 42 then
                table.insert(lrw, annoRewards[i])
            end
        end
        Win.Open("PopLuaCheckRewards", { L("秘宝高概率"), lrw })
    end
end

function PopLuaTreasure.Dispose()
    -- 删除明日道具
    if tomIndex > 0 then
        gridItems.transform:FindChild(string.format("item_%03d", tomIndex)).gameObject:Destroy()
    else
        if gridItems.transform.childCount > 0 then
            for i = 1, 3 do
                -- 写死，3个奖励
                selectItem = gridItems.transform:FindChild(string.format("item_%03d", i)).gameObject
                selectItem.gameObject:Destroy()
            end
        end
    end
    itemsTom = nil
    selectFrame = nil
    selectItem = nil
    selectIndex = 0
    delta = 0
    annoRewards = { }
end

-- 刷新--todo
function PopLuaTreasure.OnClickRefresh()
    SVR.Treasure("ref", function(t)
        if t.success then
            _dat = SVR.datCache
            SVR.UpdateUserInfo()
            PopLuaTreasure.Dispose()
            PopLuaTreasure.BuildAnno()
            PopLuaTreasure.UpdataTom(true, _dat)
        end
    end )
end

-- 查看奖励
function PopLuaTreasure.OnClickCheckReward(mef)
    local r = annoRewards
    local d = annoDay
    local lrw = { }
    if toDay ~= nil then
        for i = 0, #d do
            if d[i] == toDay then
                table.insert(lrw, r[i])
            end
        end
    end
    Win.Open("PopLuaCheckRewards", { L("秘宝高概率"), lrw })
end

function PopLuaTreasure.Help()
    Win.Open("PopRule", DB_Rule.Treasure)
end

function PopLuaTreasure.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then btn:ShowPropTip() end
end