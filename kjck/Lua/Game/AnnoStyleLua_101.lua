AnnoStyleLua_101 = { }
AnnoStyleLua_101.body = nil

local texTitle = nil
local item_goods = nil -- 道具
local ef_frame = nil   -- 特效
local item_rw = nil     -- 子物体模板
local introLab = nil       -- 标题描述信息
local valueLab = nil
local timeLab = nil      -- 剩余时间
local rewards = nil      -- grid
local mData = { }          -- JSON取得数据
local items = { }       -- 存放生成的prefab
local unit = nil        -- “个”
local valuePrefix = nil  -- “当前五星将领”
local need = nil        -- "招募五星将领%s[-]"
local data = { }
local targetValue = { }   -- 存放json中数据

function AnnoStyleLua_101.OnLoad(c)
    AnnoStyleLua_101.body = c
    c:BindFunction("OnInit")
    c:BindFunction("Refresh")
    c:BindFunction("RefreshInfo")
    c:BindFunction("ClickGetReward")
    c:BindFunction("ClickItemGoods")
    c:BindFunction("OnUnLoad")
    c:BindFunction("OnDispose")
    item_goods = c.gos[0]
    ef_frame = c.gos[1]
    item_rw = c.gos[2]
    rewards = c.gos[3]
    texTitle = c.widgets[0]
    introLab = c.widgets[1]
    valueLab = c.widgets[2]
    timeLab = c.widgets[3]
end

function AnnoStyleLua_101.OnInit()
    rewards:DesAllChild()
    mData = WinLuaAffair.getDat(AnnoStyleLua_101.body.data)
    -- 图标加载
    local loader = texTitle.transform:GetComponent(typeof(UITexture)):LoadTexAsync(mData.title)
    if mData ~= nil then
        unit = mData.u
        introLab.text = mData.t1
        valuePrefix = mData.t2
        if valuePrefix ~= nil and valuePrefix ~= "" then
            valuePrefix = valuePrefix .. ":"
        end
        need = "招募五星将领%s[-]"
    else
        introLab.text = ""
        valueLab.text = ""
        item_rw.transform:FindChild("Label"):GetComponent(typeof(UILabel)).text = ""
    end
    local nodes = mData.r
    local cnt = #nodes
    -- 存json中value值
    local grid = rewards:GetComponent(typeof(UIGrid))
    for i = 1, cnt do
        local val = nodes[i].va
        targetValue[i] = val
        items[i] = rewards:AddChild(item_rw, string.format("item_%02d", i))
        items[i]:SetActive(true)
        items[i].transform.localPosition = Vector3(0, - i * grid.cellHeight, 0)
        local mef = items[i]:GetComponentInChildren(typeof(LuaButton))
        mef:SetClick("ClickGetReward", targetValue[i][1])
        mef:GetComponent(typeof(UIButton)).isEnabled = false
        mef:GetComponentInChildren(typeof(UILabel)).text = L("领 取")
        -- 生成奖励道具显示
        local s_rewards = nodes[i].rw
        if s_rewards ~= nil then
            local goods = nil
            for j = 1, #s_rewards do
                goods = items[i]:GetComponentInChildren(typeof(UIGrid))
                local fun = ItemGoods(goods.gameObject:AddChild(item_goods, string.format("item_%02d", i)))
                fun:Init(s_rewards[j])
                fun.go.transform.localScale = Vector3.one * 0.82
                local lBtn = fun.go:GetCmp(typeof(LuaButton))
                lBtn.luaContainer = AnnoStyleLua_101.body
            end
            goods.repositionNow = true
        end
    end
    grid.repositionNow = true
    AnnoStyleLua_101.Refresh()
end

function AnnoStyleLua_101.OnDispose()
    mData = { }
    items = { }
    data = { }
    targetValue = { }
    rewards:GetComponent(typeof(UIScrollView)):ConstraintPivot(UIWidget.Pivot.Top, true);
end

function AnnoStyleLua_101.Refresh()
    SVR.AffairOption("inf|" .. mData.sn, function(t)
        if t.success then
            data = SVR.datCache
            AnnoStyleLua_101.RefreshInfo()
        end
    end )
end

-- 名将招揽
function AnnoStyleLua_101.RefreshInfo()
    valueLab.text = valuePrefix .. data.val .. unit
    local recordIndex = AnnoStyleLua_101.GetRecordIndex()
    local time = data.tm
    LuaActTimer(AnnoStyleLua_101.body, time)
    if items ~= nil then
        for i = 1, #items do
            local itemLab = items[i].transform:FindChild("Label"):GetComponent(typeof(UILabel))
            local btn = items[i]:GetComponentInChildren(typeof(UIButton))
            local btnLab = btn:GetComponentInChildren(typeof(UILabel))
            btnLab.color = Color.white
            if data.val < targetValue[i][2] then
                itemLab.text = string.format(need, "[ff0000]" .. targetValue[i][2] .. unit)
                btn.isEnabled = false
                local needVIP = AnnoStyleLua_101.GetTargetVIP(i)
                if user.vip < needVIP then
                    btnLab.text = L("需VIP") .. needVIP
                    btnLab.color = Color.red
                else
                    btnLab.text = L("领 取")
                end
            else
                itemLab.text = string.format(need, "[00ff00]" .. targetValue[i][2] .. unit)
                if i < recordIndex then
                    btn.isEnabled = false
                    btnLab.text = L("已领取")
                else
                    local needVip = AnnoStyleLua_101.GetTargetVIP(i)
                    if user.vip < needVip then
                        btn.isEnabled = false
                        btnLab.text = L("需VIP") + needVip
                        btnLab:GetComponent(typeof(BindWidgetColor)).defaultColor = Color.red
                    else
                        if i == recordIndex then
                            btn.isEnabled = true
                            btnLab.text = L("领 取")
                        else
                            btn.isEnabled = false
                            btnLab.text = L("待领取")
                        end
                    end
                end
            end
        end
        rewards:GetComponent(typeof(UIGrid)):Reposition()
    end
end

function AnnoStyleLua_101.GetTargetVIP(index)
    return 0
end

function AnnoStyleLua_101.GetRecordIndex()
    local recordIndex = 1
    if targetValue ~= nil and #data.record > 0 then
        for i = 1, #targetValue do
            if targetValue[i][1] == data.record[1] then
                recordIndex = i + 1
                break
            end
        end
    end
    return recordIndex
end

-- 获取奖励
function AnnoStyleLua_101.ClickGetReward(sn)
    SVR.AffairOption("rew|" .. sn, function(t)
        if t.success then
            data = SVR.datCache
            local i = AnnoStyleLua_101.GetRecordIndex()
            AnnoStyleLua_101.RefreshInfo()
            WinLuaAffair.RefreshInfo(data.tips)
        end
    end )
end

--function AnnoStyleLua_101.RefreshItem(idx)
--    local btn1 = items[idx - 1]:GetComponentInChildren(typeof(UIButton))
--    btn1.isEnabled = false
--    btn1.transform:FindChild("Label"):GetComponent(typeof(UILabel)).text = L("已领取");
--    if data.val >= targetValue[idx][2] then
--        local btn2 = items[idx]:GetComponentInChildren(typeof(UIButton))
--        btn2.isEnabled = true
--        btn2.transform:FindChild("Label"):GetComponent(typeof(UILabel)).text = L("领 取");
--    end
--end

function AnnoStyleLua_101.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end