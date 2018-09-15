-- 超级转盘
AnnoStyleLua_13 = { }

local node = nil -- 当前节点
local data = { }	-- 从xml读取的数据
local actData = { } -- 从服务器获取的信息
local item_goods = nil -- 物品item
local grid_goods = nil -- 物品的父级
local goodsPositoin = { } -- 物品的位置
local tex_title = nil -- 标题图片
local btn_buy1 = nil -- 买一次按钮
local btn_buy10 = nil-- 买十次按钮
local btn_rule = nil-- 活动规则
local btn_exchange = nil-- 宝物兑换
local lbl_time = nil -- 时间
local playTag -- 转动的亮框
local sp_cost1 = nil  -- 购买一次价格
local sp_cost10 = nil -- 购买十次价格
local lbl_rule = nil -- 规则
local money = nil -- 欢乐币

local itemList = { } -- 生成的item

function AnnoStyleLua_13.OnLoad(c)
    AnnoStyleLua_13.body = c
    itemList = { }

    c:BindFunction("OnInit")
    c:BindFunction("OnDispose")
    c:BindFunction("OnUnLoad")
    c:BindFunction("ClickBuy")
    c:BindFunction("ClickRule")
    c:BindFunction("ClickExchange")

    grid_goods = c.gos[0]
    item_goods = c.gos[1]
    playTag = c.gos[2]
    btn_buy1 = c.btns[0]
    btn_buy10 = c.btns[1]
    btn_rule = c.btns[2]
    btn_exchange = c.btns[3]
    sp_cost1 = c.widgets[0]
    sp_cost10 = c.widgets[1]
    lbl_rule = c.widgets[2]
    money = c.widgets[3]
    tex_title = c.widgets[4]
    lbl_time = c.widgets[5]

    btn_buy1.param = 1
    btn_buy10.param = 10
end
function AnnoStyleLua_13.OnInit()
    data = WinLuaAffair.getDat(AnnoStyleLua_13.body.data)

    -- ↓创建Itme
    -- AnnoStyleLua_13.BuildItem()
    AnnoStyleLua_13.buildItem_ing = coroutine.create(AnnoStyleLua_13.BuildItem)
    coroutine.resume(AnnoStyleLua_13.buildItem_ing)

    local msg = string.format("%s,'inf'", data.sn)
    SVR.SendFunc(Func.ActOpt, msg, function(task)
        if task.success then
            actData = kjson.decode(task.data)
            AnnoStyleLua_13.UpdateShow()
        end
    end )

    -- 加载标题图片
    tex_title:GetComponent(typeof(UITexture)):LoadTexAsync(data.title)

    LuaActTimer(AnnoStyleLua_13.body, data.time)

    btn_buy1:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = true
    btn_buy10:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = true
end

function AnnoStyleLua_13.OnDispose()
    if AnnoStyleLua_13.anim_ing ~= nil then
        coroutine.stop(AnnoStyleLua_13.anim_ing)
        AnnoStyleLua_13.anim_ing = nil
    end
end

-- 创建物品
function AnnoStyleLua_13.BuildItem()
    AnnoStyleLua_13.InitPosition()
    for i = 1, 12 do
        coroutine.step()
        local ig = ItemGoods(grid_goods:AddChild(item_goods, "goods_" .. i))
        ig.go:SetActive(true)
        table.insert(itemList, ig.go:ChildWidget("GameObject"))
        ig.go.transform.localPosition = goodsPositoin[i]
        ig:Init(data.r[1].rw[i], false)
        -- ig.go.luaBtn.luaContainer = AnnoStyleLua_13.body
    end

    btn_buy1:GetComponentInChildren(typeof(UILabel)).text = data.btn1
    btn_buy10:GetComponentInChildren(typeof(UILabel)).text = data.btn10
    sp_cost1.spriteName = data.icr
    sp_cost10.spriteName = data.icr
    sp_cost1:GetComponentInChildren(typeof(UILabel)).text = data.cost1
    sp_cost10:GetComponentInChildren(typeof(UILabel)).text = data.cost10
    lbl_rule.text = data.t1

end

-- 更新显示
function AnnoStyleLua_13.UpdateShow()
    money.text = actData[7]
end

-- 点击购买
function AnnoStyleLua_13.ClickBuy(num)
    local msg
    if num == 1 then
        msg = string.format("%s,'get|%s|1'", data.sn, 601)
    elseif num == 10 then
        msg = string.format("%s,'get|%s|2'", data.sn, 618)
    end

    SVR.SendFunc(Func.ActOpt, msg, function(task)
        if task.success then
            actData = kjson.decode(task.data)
            AnnoStyleLua_13.PlayAnim(num)
            AnnoStyleLua_13.UpdateShow()
        end
    end )
end


-- 购买一次的动画
function AnnoStyleLua_13.Anim_ingOne(rewards)
    btn_buy1:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = false
    -- 把所有item的Sprite设置为暗的
    for i, item in ipairs(itemList) do
        item.spriteName = "tab_act_normal"
    end

    playTag:SetActive(true)
    -- 先转两圈
    for i = 1, 2 do
        for j = 1, 12 do
            playTag.transform.localPosition = goodsPositoin[j]
            coroutine.wait(0.05, AnnoStyleLua_13.anim_ing)
        end
    end
    -- 转一圈，检测奖品
    for j = 1, 12 do
        playTag.transform.localPosition = goodsPositoin[j]
        coroutine.wait(0.1, AnnoStyleLua_13.anim_ing)

        -- 判断是否相等
        b = false
        for i, v in ipairs(rewards) do
            if tonumber(data.r[1].rw[j][2]) == tonumber(v[2]) then
                -- SFSServer.AnalyzeReward(AnnoStyleLua_13.TableToJson(rewards))	--显示奖励
                PopRewardShow.Show(rewards)
                b = true
                break;
            end
        end
        if b then break end
    end

    btn_buy1:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = true
end

-- 购买十次的动画
function AnnoStyleLua_13.Anim_ingTen(rewards)
    btn_buy10:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = false
    playTag:SetActive(false)
    local b = false
    -- 转5次
    for i = 1, 5 do
        for j = 1, 12 do
            if j % 2 == 0 then
                itemList[j].spriteName = b and "tab_act_normal" or "tab_act_choose"
            else
                itemList[j].spriteName = b and "tab_act_choose" or "tab_act_normal"
            end
        end
        b = not b
        coroutine.wait(0.2, AnnoStyleLua_13.anim_ing)
    end

    -- 获得的奖励高亮
    for j = 1, 12 do
        itemList[j].spriteName = "tab_act_normal"
        for i, v in ipairs(rewards) do
            if tonumber(data.r[1].rw[j][2]) == tonumber(v[2]) then
                itemList[j].spriteName = "tab_act_choose"
            end
        end
    end

    coroutine.wait(0.4, AnnoStyleLua_13.anim_ing)
    -- SFSServer.AnalyzeReward(AnnoStyleLua_13.TableToJson(rewards))
    PopRewardShow.Show(rewards)

    btn_buy10:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = true
end

-- 播放流水灯动画（购买次数）
function AnnoStyleLua_13.PlayAnim(times)

    if (AnnoStyleLua_13.anim_ing ~= nil) then
        coroutine.stop(AnnoStyleLua_13.anim_ing)
        AnnoStyleLua_13.anim_ing = nil
    end
    AnnoStyleLua_13.anim_ing = coroutine.create(times == 1 and AnnoStyleLua_13.Anim_ingOne or AnnoStyleLua_13.Anim_ingTen)
    coroutine.resume(AnnoStyleLua_13.anim_ing, actData[#actData - 1])
end

-- 点击规则
function AnnoStyleLua_13.ClickRule()
    Win.Open("PopRule", data.rule)
end

function AnnoStyleLua_13.ClickExchange()

    Win.Open("PopLuaExchange")
    PopLuaExchange.SetInit(data, actData, function(theData)
        actData = theData
        money.text = actData[7]
    end )
end


function AnnoStyleLua_13.InitPosition()
    goodsPositoin[1] = Vector3(-365.4, 136.7, 0)
    goodsPositoin[2] = Vector3(-121.9, 136.7, 0)
    goodsPositoin[3] = Vector3(121.6, 136.7, 0)
    goodsPositoin[4] = Vector3(365.1, 136.7, 0)
    goodsPositoin[5] = Vector3(365.1, 48.7, 0)
    goodsPositoin[6] = Vector3(365.1, -39.3, 0)
    goodsPositoin[7] = Vector3(365.1, -127.3, 0)
    goodsPositoin[8] = Vector3(121.6, -127.3, 0)
    goodsPositoin[9] = Vector3(-121.9, -127.3, 0)
    goodsPositoin[10] = Vector3(-365.4, -127.3, 0)
    goodsPositoin[11] = Vector3(-365.4, -39.3, 0)
    goodsPositoin[12] = Vector3(-365.4, 48.7, 0)

end

-- 把奖励的表转为json
function AnnoStyleLua_13.TableToJson(rewardTable)

    local result = "{["
    for i, v in ipairs(rewardTable) do
        result = result .. "{" .. v[1] .. "," .. v[2] .. "," .. v[3] .. "},"
    end
    result = result .. "]}"

    return result
end