PopLuaParty = { }
PopLuaParty.body = nil

local rewards = nil             -- 奖励
local selectPartyLv = nil       -- 宴会时间背景 
local rewardsGrid = nil
local level = 0                 -- 档次
local time = nil                -- 宴会倒计时   
local isGet = false             -- 宴会期间，奖励是否领取。0：未领取，1：已领取
local goods = nil               -- 显示的奖励道具
local levelTime = { }           -- 宴会三个时间label
local partyLv = nil              -- 宴会时间背景                        
local btnGo = nil                -- 赴宴按钮
local item_goods = nil             -- 道具prefab
local data = { }

function PopLuaParty.OnLoad(c)
    PopLuaParty.body = c
    WinBackground(c, { k = WinBackground.MASK })

    c:BindFunction("OnInit")
    c:BindFunction("OnDispose")
    c:BindFunction("BtnGo")
    c:BindFunction("ClickItemGoods")

    timeLab = c.widgets[0]
    btnGo = c.btns[0]
    btnGo.transform:GetComponentInChildren(typeof(UILabel)).text = L("赴 宴")
    levelTime[1] = c.gos[0]
    levelTime[2] = c.gos[1]
    levelTime[3] = c.gos[2]
    partyLv = c.gos[4]
    rewardsGrid = c.gos[3]
    item_goods = c.gos[5]
end

-- 赴宴
function PopLuaParty.BtnGo()
    local sendMessage = "'get'"
    SVR.SendFunc(Func.PartyOpt, sendMessage, function(task)
        if task.success then
            data = kjson.decode(task.data)
            local resLen = #data[3]
            local res = { }
            for i = 1, resLen do
                res[i] = data[3][i]
            end
            PopRewardShow.Show(res)
            PopLuaParty.body:Exit()
            level = data[1]
            time = data[2]
            rewards = data[3]
            isGet =(data[4] == 1)
        end
    end )
end

function PopLuaParty.OnDispose()
    delta = 0
    isGet = false
    level = 0
    selectPartyLv = nil
end  

-- 初始化
function PopLuaParty.OnInit()
    local sendMessage = "''"
    SVR.SendFunc(Func.PartyOpt, sendMessage, function(task)
        if task.success then
            local result = task.data
            js = kjson.decode(result)
            rewards = js[3]
            if rewards == nil then
                time = -1;
                timeLab.color = Color.red
                timeLab.text = L("宴会已结束")
                PopLuaParty.body.gameObject[2]:GetComponent(typeof(UILabel)).text = Color(179 / 255, 179 / 255, 179 / 255, 255 / 255)
            else
                level = js[1]
                time = js[2]
                if time > 0 then
                    timeLab.color = Color.red
                elseif time == 0 then
                    timeLab.color = Color.green;
                end
                isGet =(js[4] == 1)
                local length = table.getn(levelTime)

                for i = 1, length do
                    if i == level then
                        levelTime[i]:GetComponent(typeof(UILabel)).color = Color(254 / 255, 227 / 255, 0, 255 / 255)
                        selectPartyLv = levelTime[i]:AddChild(partyLv, "select")
                        selectPartyLv:SetActive(true)
                        selectPartyLv.transform.localPosition = Vector3(70, 0, 0)
                    else
                        levelTime[i]:GetComponent(typeof(UILabel)).color = Color(179 / 255, 179 / 255, 179 / 255, 255 / 255)

                    end
                end

                if time <= 0 and not(isGet) then
                    btnGo.isEnabled = true
                else
                    btnGo.isEnabled = false
                end
                PopLuaParty.BuildItems()
                LuaActTimer(PopLuaParty.body, time, LuaActTimer.party)
            end
        end
    end )
end

function PopLuaParty.OnActTimerEnd()
    btnGo.isEnabled = not isGet
    btnGo.text = isGet and L("已赴宴") or L("赴 宴")
end

-- 生成奖励道具
function PopLuaParty.BuildItems()
    if rewardsGrid.transform.childCount <= 0 then
        if rewards ~= nil then
            local len = table.getn(rewards)
            if len > 0 then
                for i = 1, len do
                    local ig = ItemGoods(rewardsGrid:AddChild(item_goods, string.format("item_%03d", i)))
                    ig:Init(rewards[i])
                    ig.go.luaBtn.luaContainer = PopLuaParty.body
                end
                rewardsGrid:GetComponent(typeof(UIGrid)):Reposition()
            end
        end
    end
end

function PopLuaParty.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end