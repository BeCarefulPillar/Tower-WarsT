--VIP礼包
PopLuaVipGift = { }
local body = nil

local item_gift = nil
local item_goods = nil
local grid = nil
local btnDayGift = nil
local btnWeekGift = nil
local dragTipArrow = nil

--数据 ↓
local dayData = nil --每日礼包数据
local weekData = nil --每周礼包数据

--
local itemPool = nil
local pageTurn = nil

local currentTab = -1	--当前标签，防止重复点击相同的	1=每日奖励	2 = 每周奖励
local isLoading = false		--正在加载

function PopLuaVipGift.OnLoad(c)
    WinBackground(c, { k = WinBackground.MASK })
    body = c
    c:BindFunction("OnInit")
    c:BindFunction("OnUnLoad")
    c:BindFunction("ClickTab")
    c:BindFunction("ClickItemGoods")
    c:BindFunction("ClickGet")
    c:BindFunction("ClickBuy")

    item_gift = c.gos[0]
    item_goods = c.gos[1]
    grid = c.gos[2]
    dragTipArrow = c.gos[3]
    btnDayGift = c.btns[0]
    btnWeekGift = c.btns[1]
    btnDayGift:SetClick("ClickTab", 1)
    btnWeekGift:SetClick("ClickTab", 2)

    itemPool = require("Data.ItemPool").new()

end

function PopLuaVipGift.OnInit()


    currentTab = -1
    isLoading = false
    PopLuaVipGift.ClickTab(1)
    --打开每日福利
end

--点击每天礼包 1=每日礼包		2=每周礼包
function PopLuaVipGift.ClickTab(i)
    if currentTab == i or isLoading then return end
    btnDayGift:GetComponent(typeof(UISprite)).spriteName =(i == 1) and "btn_13" or "btn_12"
    btnWeekGift:GetComponent(typeof(UISprite)).spriteName =(i == 2) and "btn_13" or "btn_12"
    currentTab = i

    local sendData = "''"
    if i == 2 then sendData = sendData .. ",0" end
    isLoading = true
    SVR.SendFunc((i == 1) and Func.VipGiftDay or Func.VipGiftWeek, sendData, function(task)
        if task.success then
            if i == 1 then
                dayData = kjson.decode(task.data)
                PopLuaVipGift.BuildItem_Day(true)
            else
                weekData = kjson.decode(task.data)
                PopLuaVipGift.BuildItem_Week(true)
            end
        end
        isLoading = false
    end )
end

--建立“每日礼包”item
function PopLuaVipGift.BuildItem_Day(toTop)
    itemPool:RemoveChilds(grid)
    for k, v in ipairs(dayData[1]) do
        local it = itemPool:CreateItem(grid, item_gift)
        it.name = string.format("item_%02d", k)
        PopLuaVipGift.InitToDay(it, v)
    end
    grid:GetComponent(typeof(UIGrid)):Reposition()
    if toTop == true then
        grid:GetComponent("UIScrollView"):ConstraintPivot(UIWidget.Pivot.Top, true)
    end
end
--建立“每周礼包”item
function PopLuaVipGift.BuildItem_Week(toTop)
    itemPool:RemoveChilds(grid)
    for k, v in ipairs(weekData[1]) do
        local it = itemPool:CreateItem(grid, item_gift)
        it.name = string.format("item_%02d", k)
        PopLuaVipGift.InitToWeek(it, v)
    end
    grid:GetComponent(typeof(UIGrid)):Reposition()
    if toTop == true then
        grid:GetComponent("UIScrollView"):ConstraintPivot(UIWidget.Pivot.Top, true)
    end
end

--把item初始化为每日礼包
function PopLuaVipGift.InitToDay(item, data)
    item.transform:FindChild("vip_num"):GetComponent(typeof(UILabel)).text = "VIP" .. data[1] .. L("礼包")
    item.transform:FindChild("sp_discount").gameObject:SetActive(false)
    item.transform:FindChild("buy_count").gameObject:SetActive(false)
    item.transform:FindChild("price").gameObject:SetActive(false)

    local tip = item.transform:FindChild("tip")
    local btnBuy = item.transform:FindChild("btn_buy"):GetComponent(typeof(LuaButton))
    local btnText = btnBuy:GetComponentInChildren(typeof(UILabel))
    local btnSp = btnBuy:GetComponent(typeof(UISprite))
    local btnCollider = btnBuy:GetComponent(typeof(UnityEngine.BoxCollider))

    --达到vip等级
    if user.vip == data[1] then
        tip.gameObject:SetActive(false)

        if data[3] == 1 then
            --已领取	
            btnCollider.enabled = false
            btnText.text = L("已领取")
            btnSp.spriteName = "btn_disabled"
        else
            --未领取
            btnCollider.enabled = true
            btnText.text = L("领 取")
            btnSp.spriteName = "sp_btn_login"
        end
        btnBuy:SetClick("ClickGet");

        --未达到
    else
        tip.gameObject:SetActive(true)
        local db_vip = DB.GetVip(data[1])
        --LuaToCSWrap.GetVipData(data[1])
        table.print("vip", db_vip)
        local needGold = db_vip.exp
        --CS.GetValue(db_vip,"needGold")
        --原代码
        --tip:GetComponent(typeof(UILabel)).text = L("再充值")..needGold..L("金币即可每日领取")
        --       btnCollider.enabled = true
        --	btnSp.spriteName = "sp_btn_register"
        --	btnText.text =  L("充值")
        --	btnBuy:SetClick("ClickRecharge");

        --7月20日封测临时更改
        tip:GetComponent(typeof(UILabel)).text = "达到 VIP" .. data[1] .. " 可领取"
        btnCollider.enabled = false
        btnSp.spriteName = "btn_disabled"
        btnText.text = "领 取"
    end

    --创建奖励物品 ↓
    local goodsGrid = item.transform:FindChild("reward_grid").gameObject
    itemPool:RemoveChilds(goodsGrid)
    for k, v in ipairs(data[2]) do
        local ig = ItemGoods(itemPool:CreateItem(goodsGrid, item_goods))
        ig.go.name = string.format("rw_%02d", k)
        ig:Init(v)
        ig.go.luaBtn.luaContainer = body
    end
    goodsGrid:GetComponent(typeof(UIGrid)).repositionNow = true
end

--把item初始化为每周礼包
function PopLuaVipGift.InitToWeek(item, data)
    item.transform:FindChild("vip_num"):GetComponent(typeof(UILabel)).text = "VIP" .. data[1] .. L("礼包")
    --设置打折
    local discount = item.transform:FindChild("sp_discount").gameObject
    discount:SetActive(true)
    discount:GetComponentInChildren(typeof(UILabel)).text = data[3] .. L("折")
    --设置购买次数
    local buyCount = item.transform:FindChild("buy_count").gameObject
    buyCount:SetActive(true)
    buyCount:GetComponent(typeof(UILabel)).text = string.format(L("可买%d次"), data[4])
    --设置价格
    local price = item.transform:FindChild("price").gameObject
    price:SetActive(true)
    local spMap = { "sp_silver", "sp_gold", "sp_diamond" }
    for k, v in ipairs(data[5]) do
        if v > 0 then
            price:GetComponent(typeof(UILabel)).text = v
            price:GetComponentInChildren(typeof(UISprite)).spriteName = spMap[k]
            break
        end
    end

    local tip = item.transform:FindChild("tip"):GetComponent(typeof(UILabel))
    local btnBuy = item.transform:FindChild("btn_buy"):GetComponent(typeof(LuaButton))
    local btnText = btnBuy:GetComponentInChildren(typeof(UILabel))
    local btnSp = btnBuy:GetComponent(typeof(UISprite))
    local btnCollider = btnBuy:GetComponent(typeof(UnityEngine.BoxCollider))

    --达到vip等级 ↓
    if user.vip >= data[1] then
        tip.gameObject:SetActive(false)

        if data[6] == 1 then
            --未售罄
            btnCollider.enabled = true
            btnText.text = L("购 买")
            btnSp.spriteName = "sp_btn_login"
        else
            --已售罄
            btnCollider.enabled = false
            btnText.text = L("售 罄")
            btnSp.spriteName = "btn_disabled"
        end
        btnBuy:SetClick("ClickBuy", data[1])

        --未达到vip等级 ↓
    else
        --原代码
        --       tip.gameObject:SetActive(true)
        --	tip.text = L("vip等级不足，请充值")
        --	btnCollider.enabled = true
        --	btnSp.spriteName = "sp_btn_register"		
        --	btnText.text = L("充 值");
        --	btnBuy:SetClick("ClickRecharge")
        --    price:SetActive(false)
        --    buyCount:SetActive(false)

        --7月20日封测临时更改
        tip.gameObject:SetActive(true)
        tip.text = "vip等级不足，无法购买"
        btnCollider.enabled = false
        btnSp.spriteName = "btn_disabled"
        btnText.text = L("购 买");
        price:SetActive(false)
        buyCount:SetActive(false)
    end

    --创建奖励物品 ↓
    local goodsGrid = item.transform:FindChild("reward_grid").gameObject
    itemPool:RemoveChilds(goodsGrid)
    for k, v in ipairs(data[2]) do
        local ig = ItemGoods(itemPool:CreateItem(goodsGrid, item_goods))
        ig.go.name = string.format("rw_%02d", k)
        ig:Init(v)
        ig.go.luaBtn.luaContainer = body
    end
    goodsGrid:GetComponent(typeof(UIGrid)).repositionNow = true

end


--点击领取按钮
function PopLuaVipGift.ClickGet()
    local sendData = "'get'"
    isLoading = true
    SVR.SendFunc(Func.VipGiftDay, sendData, function(task)
        isLoading = false
        if task.success then
            dayData = kjson.decode(task.data)
            --解析奖励
            table.print("", dayData[1][1][2])
            PopRewardShow.Show(dayData[1][1][2])
            --刷新显示
            PopLuaVipGift.BuildItem_Day(false)
            user.changed=true
            SVR.UpdateUserInfo()
        end
    end )
end

--点击充值
function PopLuaVipGift.ClickRecharge()
    Win.Open("PopRecharge")
end

--点击购买（当前购买的vip等级）
function PopLuaVipGift.ClickBuy(vipLv)
    print("点击购买", vipLv)
    local sendData = "'get'," .. vipLv
    SVR.SendFunc(Func.VipGiftWeek, sendData, function(task)
        isLoading = false
        if task.success then
            weekData = kjson.decode(task.data)
            PopRewardShow.Show(weekData[1][vipLv + 1][2])
            PopLuaVipGift.BuildItem_Week(false)
            SVR.UpdateUserInfo()
        end
    end )
end

--点击奖励物品显示信息
function PopLuaVipGift.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end