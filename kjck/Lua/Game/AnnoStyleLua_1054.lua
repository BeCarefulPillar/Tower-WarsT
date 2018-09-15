AnnoStyleLua_1054 = { }

function AnnoStyleLua_1054:OnLoad(c)
    self.body = c

    c:BindFunction("OnInit")

    local gameObjects = c.gos
    self.item_rank = gameObjects[0]
    self.item_reward = gameObjects[1]
    self.rankPanel = gameObjects[2]
    self.gridRanks = gameObjects[3]
    self.rewardGrid = gameObjects[4]
    self.item_goods = gameObjects[5]

    local widgets = c.widgets
    self.intro = widgets[0]
    self.value1Lab = widgets[1]
    self.value2Lab = widgets[2]
    self.timeLab = widgets[3]
    self.labMyRank = widgets[4]
    self.labNo1Name = widgets[5]

    local objects = c.objs
    self.rankBg = objects[0]
    self.gridNo1Rw = objects[1]
    self.texNo1Head = objects[2]
end

function AnnoStyleLua_1054:OnInit()
    self.mData = WinLuaAffair.getDat(self.body.data)
    if self.mData then
        self.intro.text = self.mData.t1
        self.value1Lab.text = self.mData.t2
        self.value2Lab.text = self.mData.t3
    else
        self.intro.text = ""
        self.value1Lab.text = ""
        self.value2Lab.text = ""
    end
    self:Refresh()
end

function AnnoStyleLua_1054:OnDispose()
    self.intro.text = ""
    self.value1Lab.text = ""
    self.value2Lab.text = ""
    self:ShowRank(false)
    self:DestroyRankItems()

    self.labNo1Name.text = ""
    self.rewardGrid:DesAllChild()
    self.gridNo1Rw:DesAllChild()
end

function AnnoStyleLua_1054:DestroyRankItems()
    self.gridRanks:DesAllChild()
end

function AnnoStyleLua_1054:Refresh()
    local str = "'inf|" .. self.mData.sn .. "'"
    SVR.SendFunc(Func.AffairRankOption, str, function(result)
        if result.success then
            kjs = kjson.decode(result.data)
            self:RefreshInfo(kjs)
        end
    end )
end

function AnnoStyleLua_1054:RefreshInfo(kjs)
    if kjs ~= nil then
        local sn = kjs[1]
        local time = kjs[2]
        local value = kjs[3]
        self.player = kjs[4]

        print(time)
        LuaActTimer(self.body,time)
        if value == 0 then
            self.labMyRank.text = L("未上榜")
        else
            self.labMyRank.text = string.format(L("第%d名"), value)
        end

        nodes = self.mData.r
        nodes2 = self.mData.r2
        local cnt = #nodes
        if cnt < 1 then return end
        grid = self.rewardGrid:GetComponent(typeof(UIGrid))
        -- 获取UIGrid组件
        for i = 1, cnt do
            rws = self.mData.r
            if i == 1 then
                -- 如果是第一个奖励  则视为第一名
                if sn == 0 then return end
                self.labNo1Name.text = self.player[1][2]
                local ld = self.texNo1Head:GetComponent(typeof(UITexture)):LoadTexAsync("ava_" .. self.player[1][5])
                for j = 1, #rws[1].rw do
                    local ig = ItemGoods(self.gridNo1Rw:AddChild(self.item_goods, "item_" .. j))
                    ig:Init(rws[1].rw[j])
                    ig.go:SetActive(true)
                    if ig ~= nil then
                        ig.go.luaBtn.luaContainer = self.body
                        ig.go.transform.localScale = Vector3.one * 0.75
                    else
                        ig:DesAllChild()
                    end
                end
                self.gridNo1Rw:GetComponent(typeof(UIGrid)).repositionNow = true
            else
                -- 界面左边显示
                go = self.rewardGrid:AddChild(self.item_reward, "item_" .. i)

                go:SetActive(true)
                go.transform.localPosition = Vector3(0,(cnt - 1 - 2 * i) * grid.cellHeight * 0.5, 0)

                local strRank = string.format(L("第%d名"), i)
                if (cnt > 3 and i > cnt - 1) then
                    strRank = string.format(L("第%s名"), i .. "-10")
                    -- strRank = "第" + (i + 1)+"-10" + "名"
                end
                go.transform:FindChild("rank"):GetComponent(typeof(UILabel)).text = strRank

                if #rws < 1 then return end
                goods = go:GetComponentInChildren(typeof(UIGrid))
                for j = 1, #rws[i].rw do
                    local ig = ItemGoods(goods.gameObject:AddChild(self.item_goods, "item_" .. j))
                    ig.go:SetActive(true)
                    ig:Init(rws[i].rw[j])
                    if ig ~= nil then
                        ig.go.luaBtn.luaContainer = self.body
                        ig.go.transform.localScale = Vector3.one * 0.82
                    else
                        ig.gameObject:DesAllChild()
                    end

                end
                goods:GetComponent(typeof(UIGrid)).repositionNow = true

                if #rws[i].rw <= 2 then
                    goods:GetComponent(typeof(UIScrollView)).ConstraintPivot(UIWidget.Pivot.Left, false)
                    goods:GetComponent(typeof(UIScrollView)).enabled = false
                end
            end
        end
        -- 加载通关目标奖励
        local b = cnt + #nodes2
        for i = cnt, cnt do
            -- 写死
            go = self.rewardGrid:AddChild(self.item_reward, "item2_" .. i)

            go:SetActive(true)
            go.transform.localPosition = Vector3(0,(cnt + #nodes2 - 1 - 2 * i) * grid.cellHeight * 0.5, 0)
            local st = nodes2[i - cnt + 1].t
            go.transform:FindChild("rank"):GetComponent(typeof(UILabel)).text = st
            local res = nodes2[i - cnt + 1].rw

            if #res < 1 then return end
            goods = go:GetComponentInChildren(typeof(UIGrid))
            for j = 1, #res do
                local ig = ItemGoods(goods.gameObject:AddChild(self.item_goods, "item_" .. j))
                ig.go:SetActive(true)
                ig:Init(res[j])
                if ig ~= nil then
                    ig.go.luaBtn.luaContainer = self.body
                    ig.go.transform.localScale = Vector3.one * 0.82

                else
                    ig.gameObject:DesAllChild()
                end
            end
            goods:GetComponent(typeof(UIGrid)).repositionNow = true

            if #res <= 3 then goods:GetComponent(typeof(UIScrollView)).enabled = false end

            if self.rewardGrid.activeInHierarchy then
                grid:GetComponent(typeof(UIGrid)):Reposition()
            else
                grid:GetComponent(typeof(UIGrid)).repositionNow = true
            end
        end
        self.rewardGrid:GetComponent(typeof(UIGrid)).repositionNow = true
    end
end

function AnnoStyleLua_1054:ClickShowRank()
    self:DestroyRankItems()
    if #self.player > 0 then
        local grid = self.gridRanks:GetComponent(typeof(UIGrid))
        for i = 1, #self.player do
            local rank_items = self.gridRanks:AddChild(self.item_rank, "item_" .. i)
            if i % 2 == 0 then
                local a = true
            else
                local a = false
            end
            rank_items:GetComponent(typeof(UISprite)).enabled = a
            local playerName = self.player[i][2]
            local playerValue1 = self.player[i][3]
            local playerValue2 = self.player[i][4]
            rank_items.transform:FindChild("rank"):GetComponent(typeof(UILabel)).text = tostring(i)
            rank_items.transform:FindChild("name"):GetComponent(typeof(UILabel)).text = playerName
            rank_items.transform:FindChild("value1"):GetComponent(typeof(UILabel)).text = playerValue1
            rank_items.transform:FindChild("value2"):GetComponent(typeof(UILabel)).text = playerValue2
            rank_items.transform.localPosition = Vector3(0, - grid.cellHeight * i, 0)
            rank_items:SetActive(true)
        end
        if #self.player > 9 then
            local b = true
        else
            local b = false
        end
        grid:GetComponent(typeof(UIGrid)):Reposition()
        self.gridRanks:GetComponent(typeof(UIScrollView)):ConstraintPivot(UIWidget.Pivot.Top, true)


        self:ShowRank(true)
    end
end 

function AnnoStyleLua_1054:ShowRank(show)
    if show == true then
        self.rankPanel:SetActive(true)
        selectedObject = self.rankBg.gameObject
    else
        self.rankPanel:SetActive(false)
    end
end

function AnnoStyleLua_1054:OnClickClosePanel()
    self.rankPanel:SetActive(false)
end

-- 点击奖励
function AnnoStyleLua_1054:ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end