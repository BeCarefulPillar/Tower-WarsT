AnnoStyleLua_10148 = { }
AnnoStyleLua_10148.body = nil

local texTitle = nil
local item_goods = nil -- 道具
local ef_frame = nil   -- 特效
local item_rw = nil     -- 子物体模板
local introLab = nil       -- 标题描述信息
local valueLab = nil
local timeLab = nil      -- 剩余时间
local rewards = nil      -- grid
local mData = { }          -- JSON取得数据
local items = { }
local data = { }
local targetValue = { }
local SN = 0
function AnnoStyleLua_10148.OnLoad(c)
    AnnoStyleLua_10148.body = c
    c:BindFunction("OnInit")
    c:BindFunction("Refresh")
    c:BindFunction("RefreshInfo")
    c:BindFunction("OnUnLoad")
    c:BindFunction("ClickGetReward")
    c:BindFunction("ClickItemGoods")
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

function AnnoStyleLua_10148.OnInit()
    rewards:DesAllChild()
    rewards:GetComponent(typeof(UIScrollView)):ResetPosition()
    mData = WinLuaAffair.getDat(AnnoStyleLua_10148.body.data)
    SN = mData.sn
    if SN <= 0 then
        return
    end
    -- 图标加载
    texTitle.transform:GetComponent(typeof(UITexture)):LoadTexAsync(mData.title)
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
                local ig = ItemGoods(goods.gameObject:AddChild(item_goods, string.format("item_%02d", i)))
                ig:Init(s_rewards[j])
                ig.go.transform.localScale = Vector3.one * 0.82
                ig.go.luaBtn.luaContainer = AnnoStyleLua_10148.body
            end
            goods.repositionNow = true
        end
    end
    grid.repositionNow = true
    AnnoStyleLua_10148.Refresh()
end
function AnnoStyleLua_10148.OnDispose()
    mData = { }
    items = { }
    data = { }
    SN = 0
    targetValue = { }
    rewards:GetComponent(typeof(UIScrollView)):ResetPosition()
end

function AnnoStyleLua_10148.Refresh()
    SVR.AffairOption("inf|" .. mData.sn, function(t)
        if t.success then
            data = SVR.datCache
            AnnoStyleLua_10148.RefreshInfo()
        end
    end )
end
-- 招贤纳士
function AnnoStyleLua_10148.RefreshInfo()
    valueLab.text = valuePrefix .. data.val .. unit
    local time = data.tm
    print(time)
    LuaActTimer(AnnoStyleLua_10148.body, time)
    if items ~= nil then
        for i = 1, #items do
            -- 获取指定武将的名字
            local name = DB.GetHero(targetValue[i][2]).nm
            -- DB_Hero[targetValue[i][2]].n
            items[i].transform:FindChild("Label"):GetComponent(typeof(UILabel)).text = string.format(need, "[00ff00]" .. name)
            items[i].transform:FindChild("Label"):GetComponent(typeof(UILabel)).overflowMethod = UILabel.Overflow.ResizeFreely
            local btn = items[i]:GetComponentInChildren(typeof(UIButton))
            local btnLab = btn:GetComponentInChildren(typeof(UILabel))
            btnLab.color = Color.white
            local goName = items[i].name
            if table.contains(data.ext, targetValue[i][1]) then
                if table.contains(data.record, targetValue[i][1]) then
                    btn.isEnabled = false
                    btnLab.text = L("已领取")
                    items[i].name = "z_" .. goName
                else
                    btn.isEnabled = true
                    btnLab.text = L("领 取")
                    items[i].name = "c_" .. goName
                end
            else
                btn.isEnabled = false
                btnLab.text = L("领 取")
            end
        end
    end
    local grid = rewards:GetComponent(typeof(UIGrid))
    grid:Reposition()
end
-- 获取奖励
function AnnoStyleLua_10148.ClickGetReward(sn)
    SVR.AffairOption("rew|" .. sn, function(t)
        if t.success then
            data = SVR.datCache
            AnnoStyleLua_10148.RefreshItem()
            WinLuaAffair.RefreshInfo(data.tips)
        end
    end )
end

function AnnoStyleLua_10148.RefreshItem()
    for i = 1, #items do
        local btn = items[i]:GetComponentInChildren(typeof(UIButton))
        local btnLab = btn:GetComponentInChildren(typeof(UILabel))
        btnLab.color = Color.white
        local goName = items[i].name
        if table.contains(data.ext, targetValue[i][1]) then
            if table.contains(data.record, targetValue[i][1]) then
                btn.isEnabled = false
                btnLab.text = L("已领取")
                items[i].name = "z_" .. goName
            else
                btn.isEnabled = true
                btnLab.text = L("领 取")
                items[i].name = "c_" .. goName
            end
        else
            btn.isEnabled = false
            btnLab.text = L("领 取")
        end
    end
    local grid = rewards:GetComponent(typeof(UIGrid))
    grid:Reposition()
end

-- 物品点击事件
function AnnoStyleLua_10148.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end