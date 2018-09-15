--require "Data.User"
--require "Data.Const"
--require "cjson.kjson"

PopLuaSeven = { }
local body = nil
local btn_Help = nil
local advertisement = nil--三张广告的父物体
local item_leftLab = nil--左边的标签（第一天、第二天。。）
local item_upSub = nil--上方的标签（每日福利、城池开发。。）
local item_task = nil--任务
local grid_leftLab = nil--左边标签的Grid
local grid_upSub = nil--上方标签的Grid
local grid_task = nil--任务的Grid
local item_goods = nil--奖励物品
local item_buy = nil --五折抢购的Item
local boxBtns = { } --宝箱
local lbl_boxValue = nil --宝箱进度
local slider_boxValue = nil --宝箱进度条

local leftSubList = { } --左边生成的所有标签
local upSubList = { }	--上方生成的所有标签
local taskItemList = { }	--生成的任务
local currentLeft = nil --当前的左边选项卡
local currentUp = nil --当前的上方选项卡

local localData = nil --本地数据
local dic = nil--保存了xml中读取的数据，按照天数、标签分类
--local _dat = nil --从服务器获取的数据
--local ruleData = nil --规则数据
--local day = 0;--剩余天数
local needUpdateInfo = false	--当获得焦点的时候是否需要刷新信息

local _dat = nil
local _sps = nil
local _bg = nil

function PopLuaSeven.OnLoad(c)
    leftSubList = { }
    upSubList = { }
    taskItemList = { }

    _bg = WinBackground(c, { i = true })
    body = c
    --WinBackground(c,{i=true})

    --[[
    c:BindFunction("OnInit")
    c:BindFunction("OnDispose")
    c:BindFunction("OnDisable")
    c:BindFunction("OnFocus")
    c:BindFunction("OnUnLoad")
    c:BindFunction("OnExit")
    c:BindFunction("ClickItemGoods")
    c:BindFunction("OnDestroyed")
    c:BindFunction("OnLeftSubClick")
    c:BindFunction("OnUpSubClick")
    c:BindFunction("ClickRecive")
    c:BindFunction("ClickGo")
    c:BindFunction("ClickBuy")
    c:BindFunction("ClickBox")
    c:BindFunction("ClickHelp")
    ]]

    advertisement = c.gos[0]
    item_leftLab = c.gos[1]
    item_upSub = c.gos[2]
    grid_leftLab = c.gos[3]:GetCmp(typeof(UIGrid))
    grid_upSub = c.gos[4]:GetCmp(typeof(UIGrid))
    item_task = c.gos[5]
    grid_task = c.gos[6]
    item_goods = c.gos[7]
    item_buy = c.gos[8]
    for i = 1, 4 do
        boxBtns[i] = c.btns[i - 1]
    end
    lbl_boxValue = c.widgets[0]
    slider_boxValue = c.gos[9]

    _sps = {
        c.cmps[0],
        c.cmps[1],
        c.cmps[2],
    }

    advertisement:GetCmp(typeof(UICenterOnChild)).onFinished = PopLuaSeven.OnDragFinish
    advertisement:GetCmp(typeof(UICenterOnChild)).onCenter = PopLuaSeven.OnCenter

end

local _cur = nil
local _pre = nil
function PopLuaSeven.OnCenter(go)
    _cur = go
end
function PopLuaSeven.OnDragFinish()
    if _cur ~= _pre then
        if _cur then
            _sps[tonumber(_cur.name)].spriteName = "seven_sp_ad_1"
        end
        if _pre then
            _sps[tonumber(_pre.name)].spriteName = "seven_sp_ad_0"
        end
    end
    _pre = _cur
end

function PopLuaSeven.OnUnLoad(c)
    if body == c then
        _pre = nil
        _cur = nil
        _bg:dispose()
        _bg = nil
        --package.loaded["Game.PopLuaSeven"] = nil
    end
end

local function BuildDic()
    dic = { }
    for i, v in ipairs(localData) do
        local day = v.day
        local lab = v.lab
        local sn = v.sn
        if not dic[day] then dic[day] = { } end
        if not dic[day][lab] then dic[day][lab] = { } end
        dic[day][lab][sn] = v
    end
end

function PopLuaSeven.OnInit()
    if localData == nil then localData = DB.Get(LuaRes.Target7) end

    needUpdateInfo = true
    if currentLeft == nil then
        currentLeft = 1;
    end
    if currentUp == nil then
        currentUp = L("每日福利")
    end

    BuildDic()
end

local function AnalysisActData(d)
    local quest = { }
    for i = 1, #d.qs, 3 do
        local sn = d.qs[i]
        local com = d.qs[i + 1]
        local rec = d.qs[i + 2]
        quest[sn] = { completion = com, isRecive = rec }
    end
    d.qs = quest
end

--当获得焦点，开发城池返回需更新信息
function PopLuaSeven.OnFocus(isFocus)
    if isFocus == true and needUpdateInfo == true then
        needUpdateInfo = false
        local data = "''"
        SVR.TargetSeven("", function(t)
            if t.success then
                _dat = SVR.datCache
                AnalysisActData(_dat)

                if (#leftSubList == 0) then
                    PopLuaSeven.BuildLab()
                end
                PopLuaSeven.UpdateByActData()

                --根据天数调整图片
                if _dat.day < 2 then
                    PopLuaSeven.ChangeAd(0)
                elseif _dat.day >= 2 and _dat.day < 5 then
                    PopLuaSeven.ChangeAd(1)
                else
                    PopLuaSeven.ChangeAd(2)
                end
            end
        end )
    end
end



function PopLuaSeven.OnDispose()
    if PopLuaSeven.SetRedPoint_ing ~= nil then
        coroutine.stop(PopLuaSeven.SetRedPoint_ing)
        PopLuaSeven.SetRedPoint_ing = nil
    end

    if PopLuaSeven.OnFocusUpdateInfo ~= nil then
        coroutine.stop(PopLuaSeven.OnFocusUpdateInfo)
        PopLuaSeven.OnFocusUpdateInfo = nil
    end
end

--创建左边的标签
function PopLuaSeven.BuildLab()
    --初始化帝王宝箱
    local i = 1
    for _, v in ipairs(localData) do
        if v.day >= 100 then
            boxBtns[i].param = v
            i = i + 1
        end
    end

    grid_leftLab:DesAllChild()
    leftSubList = { }
    for day, _ in ipairs(dic) do
        local it = grid_leftLab:AddChild(item_leftLab, string.format("lab_%02d", day))
        it:SetActive(true)
        it:ChildWidget("Label").text = string.format(L("第%d天"), day)
        it.luaBtn.param = day
        leftSubList[day] = it
    end
    grid_leftLab.repositionNow = true
    PopLuaSeven.OnLeftSubClick(grid_leftLab:ChildBtn("lab_0" .. _dat.day), _dat.day)

    LuaActTimer(body, user.regTm + 7 * 86400 - SVR.SvrTime(), LuaActTimer.seven)
end

--当左边的标签被点击的时候，创建左边的标签
function PopLuaSeven.OnLeftSubClick(btn, day)
    if day > _dat.day then
        ToolTip.ShowPopTip("暂未开启，请保持每日登陆并开启相应的目标与大奖")
        return
    end

    currentLeft = day

    PopLuaSeven.ChangeTabView(btn, "seven_lab_1", "seven_lab_0", true)

    local index = 1
    upSubList = { }
    grid_upSub:DesAllChild()
    for lab, v in pairs(dic[day]) do
        local rank = index
        if lab == L("每日福利") then
            rank = 0
        elseif lab == L("五折抢购") then
            rank = 9
        end
        local it = grid_upSub:AddChild(item_upSub, string.format("upLab_%02d", rank))
        it:SetActive(true)
        it:ChildWidget("Label").text = lab
        it.luaBtn.param = { day, L(lab) }
        upSubList[lab] = it
        --把上方的item保存起来，以便更新信息用
        index = index + 1
    end
    grid_upSub.repositionNow = true
    --开启上方的第一个标签
    --PopLuaSeven.OnUpSubClick( { [0] = grid_upSub.transform:FindChild("upLab_00"), [1] = day, [2] = L("每日福利") })
    PopLuaSeven.OnUpSubClick(grid_upSub:ChildBtn("upLab_00"), { day, L("每日福利") })

    PopLuaSeven.SetRedPoint()
    --设置小红点
end

--当上方的标签被点击的时候，创建任务列表
function PopLuaSeven.OnUpSubClick(btn, d)
    local day = d[1]
    local lab = d[2]
    currentUp = lab

    PopLuaSeven.ChangeTabView(btn, "seven_tab_1", "seven_tab_0", false)
    grid_task:GetComponent(typeof(UIGrid)):DesAllChild()

    --让滑动区域回到最上面
    grid_task:GetComponent(typeof(UIScrollView)):ResetPosition()
    grid_task:GetComponent(typeof(UIPanel)).clipOffset = Vector2.zero
    grid_task.transform.localPosition = Vector3(-115, 119, 0)

    local count = 0;

    for i, taskData in next, dic[day][lab] do
        --↓创建任务领取item
        if taskData.cost == nil or taskData.cost[1] == nil then
            local it = grid_task:AddChild(item_task, string.format("quest_%05d", taskData.sn))
            it:SetActive(true)

            --创建物品
            local rewardGrid = it.transform:FindChild("grid_reward");
            for j, goods in next, taskData.rws do
                local gd = ItemGoods(rewardGrid.gameObject:AddChild(item_goods))
                gd:Init(goods)
                gd.go.luaBtn.luaContainer = body
            end
            rewardGrid:GetComponent(typeof(UIGrid)):Reposition()
            taskItemList[taskData.sn] = it
            --把任务item保存起来，更新信息用

            --↓创建五折抢购
        else
            local it = grid_task:AddChild(item_buy, string.format("buy_%02d", i))
            it:SetActive(true)

            it.transform:FindChild("lab_name"):GetComponent(typeof(UILabel)).text = taskData.nm
            it.transform:FindChild("lab_cost_old"):GetComponent(typeof(UILabel)).text = L("原价") .. taskData.original[3]
            it.transform:FindChild("lab_cost_now"):GetComponent(typeof(UILabel)).text = L("现价") .. taskData.cost[3]


            --创建物品
            local grid = it.transform:FindChild("goods")
            for j, goods in next, taskData.rws do
                local gd = ItemGoods(grid.gameObject:AddChild(item_goods))
                gd.go.transform.localPosition = Vector3.zero
                gd.go.transform.localScale = Vector3.one
                gd:Init(goods)
                gd.go.luaBtn.luaContainer = body
            end
            taskItemList[taskData.sn] = it
        end
        count = count + 1
    end
    PopLuaSeven.SetTaskInfo()
    grid_task:GetComponent(typeof(UIGrid)):Reposition()
    grid_task:GetCmp(typeof(UIGrid)).repositionNow = true
    local scroll = grid_task:GetComponent(typeof(UIScrollView))
    scroll.enabled = count > 2

    --PopLuaSeven.CheckTutrial()
end

--点击领取
function PopLuaSeven.ClickRecive(sn)
    SVR.TargetSeven("get|" .. sn, function(t)
        if t.success then
            _dat = SVR.datCache
            AnalysisActData(_dat)
            user.changed = true
            PopLuaSeven.UpdateByActData()
        end
    end )
end

--点击前往
function PopLuaSeven.ClickGo(win)
    --当前往任务再返回时，需要刷新显示
    needUpdateInfo = true
    Guide.PaseGuide(win)
end

--点击购买
function PopLuaSeven.ClickBuy(sn)
    SVR.TargetSeven("get|" .. sn, function(t)
        if t.success then
            _dat = SVR.datCache
            AnalysisActData(_dat)
            user.changed = true
            PopLuaSeven.UpdateByActData()
        end
    end )
end

--点击宝箱
function PopLuaSeven.ClickBox(data)
    local d = { rws = data.rws, str = L("进度达到") .. data.tarVal .. L("奖励") .. "：" }
    Win.Open("PopRwdPreview", d)
end

--根据_dat来更新显示
function PopLuaSeven.UpdateByActData()
    --设置小红点
    PopLuaSeven.SetRedPoint()
    --设置任务列表信息
    PopLuaSeven.SetTaskInfo()

    grid_task:GetComponent(typeof(UIGrid)):Reposition()

    --↓ 设置进度宝箱
    local boxDatas = { }

    local completeCount = 0;
    local targetCount = 0;
    for taskSn, taskData in next, localData do
        if taskData.lab ~= L("每日福利") and taskData.lab ~= L("五折抢购") and taskData.lab ~= L("帝王宝箱") then
            targetCount = targetCount + 1
            if _dat.qs[taskSn].completion >= taskData.tarVal then
                completeCount = completeCount + 1
            end
        end
        if taskData.isBox == 1 then
            --帝王宝箱
            table.insert(boxDatas, taskData)
        end
    end

    local noCompleteBox = { }
    --当前的箱子
    for k, boxData in next, boxDatas do
        if completeCount < boxDatas[k].tarVal then
            boxBtns[k]:GetComponent(typeof(UISprite)).spriteName = "sp_country_box_dis_" .. k
            table.insert(noCompleteBox, boxData)
        else
            boxBtns[k]:GetComponent(typeof(UISprite)).spriteName = "sp_country_box_" .. k
        end
    end

    lbl_boxValue.text = completeCount .. "/" .. targetCount
    slider_boxValue:GetComponent("UISlider").value = completeCount / boxDatas[#boxDatas].tarVal
end



--设置当前天数、当前任务类型 下的任务信息
function PopLuaSeven.SetTaskInfo()
    local currentTaskList = dic[currentLeft][currentUp]

    for taskSn, taskData in next, currentTaskList do
        local btn = taskItemList[taskSn].transform:FindChild("btn_sure"):GetComponent(typeof(LuaButton))
        local uiButton = btn:GetComponent(typeof(UIButton))
        local btnText = btn:GetComponentInChildren(typeof(UILabel))
        local btnTSp = btn:GetComponent(typeof(UISprite))
        if taskData.cost == nil or taskData.cost[1] == nil then
            --任务
            local lblIntro = taskItemList[taskSn].transform:FindChild("lab_name"):GetComponent(typeof(UILabel))
            local lblCompletion = taskItemList[taskSn].transform:FindChild("lab_completion"):GetComponent(typeof(UILabel))
            lblIntro.text = taskData.intro
            if currentUp == L("每日福利") then
                lblCompletion.text = _dat.day .. "/" .. currentLeft
            else
                lblCompletion.text = _dat.qs[taskSn].completion .. "/" .. taskData.tarVal
            end
            if _dat.qs[taskSn].completion >= taskData.tarVal then
                --完成
                if _dat.qs[taskSn].isRecive > 0 then
                    --已领取
                    if string.find(taskItemList[taskSn].transform.name, "z") ~= 1 then
                        taskItemList[taskSn].transform.name = "z_" .. taskItemList[taskSn].transform.name
                    end
                    btnText.text = L("已领取")
                    uiButton.isEnabled = false
                    btnTSp.spriteName = "btn_disabled"
                else
                    --未领取
                    if string.find(taskItemList[taskSn].transform.name, "c") ~= 1 then
                        taskItemList[taskSn].transform.name = "c_" .. taskItemList[taskSn].transform.name
                    end
                    btnText.text = L("领 取")
                    btnTSp.spriteName = "sp_btn_login"
                    uiButton.normalSprite = "sp_btn_login"
                    uiButton.isEnabled = true
                    btn:SetClick("ClickRecive", taskData.sn)
                end
            else
                btnText.text = L("前往")
                btn:SetClick("ClickGo", taskData.guide)
                btnTSp.spriteName = "btn_02"
                uiButton.isEnabled = true
            end
        else
            --购买
            if _dat.qs[taskSn].isRecive > 0 then
                --已购买
                btnText.text = L("已购买")
                uiButton.isEnabled = false
            else
                --未购买
                btnText.text = L("购 买")
                btn:SetClick("ClickBuy", taskData.sn)
                uiButton.isEnabled = true
            end
        end
    end
end

--设置小红点
function PopLuaSeven.SetRedPoint()
    if PopLuaSeven.SetRedPoint_ing ~= nil then
        coroutine.stop(PopLuaSeven.SetRedPoint_ing)
        PopLuaSeven.SetRedPoint_ing = nil
    end

    PopLuaSeven.SetRedPoint_ing = coroutine.create(PopLuaSeven.IESetRedPoint)
    coroutine.resume(PopLuaSeven.SetRedPoint_ing)
end

function PopLuaSeven.IESetRedPoint()
    coroutine.step()
    for day, v1 in pairs(dic) do
        if leftSubList[day] and day <= _dat.day then
            local leftPoint = leftSubList[day]:Child("tip_tag")
            leftPoint:SetActive(false)
            for up, v2 in next, v1 do
                for taskSn, taskData in next, v2 do
                    --天数 <= 当前登录天数 && 完成度 >= 目标 && 未领取 && 不属于“限购”
                    if _dat.qs[taskSn].completion >= taskData.tarVal and
                        _dat.qs[taskSn].isRecive == 0 and
                        #taskData.cost <= 0 then
                        leftPoint:SetActive(true)
                        break
                    end
                end
            end
        end
    end

    for left, v1 in next, dic do
        if leftSubList[left] ~= nil and tonumber(left) == currentLeft then
            for up, v2 in next, v1 do
                if upSubList[up] ~= nil then
                    upSubList[up].transform:FindChild("tip_tag"):SetActive(false)
                end
                for taskSn, taskData in next, v2 do
                    --天数 <= 当前登录天数 && 完成度 >= 目标 && 未领取 && 不属于“限购”
                    if _dat.qs[taskSn].completion >= taskData.tarVal and
                        _dat.qs[taskSn].isRecive == 0 and
                        #taskData.cost <= 0 then
                        --完成但未领取
                        if upSubList[up] ~= nil then
                            upSubList[up].transform:FindChild("tip_tag"):SetActive(true)
                        end
                    end
                end
            end
        end
    end
end

--改变tab的sp，仿toggle组显示
function PopLuaSeven.ChangeTabView(currentTab, enableSpName, disabledSpName, isChangeLabel)
    local parent = currentTab.transform.parent
    for i = 0, parent.childCount - 1 do
        local tab = parent:GetChild(i)
        if tab.name == currentTab.name then
            tab:GetComponent(typeof(UISprite)).spriteName = enableSpName
            if isChangeLabel then tab:GetComponentInChildren(typeof(UILabel)).color = Color(1, 180 / 255, 0, 1); end
        else
            tab:GetComponent(typeof(UISprite)).spriteName = disabledSpName
            if isChangeLabel then tab:GetComponentInChildren(typeof(UILabel)).color = Color(190 / 255, 166 / 255, 109 / 255, 1); end
        end
    end
end

function PopLuaSeven.Help()
    Win.Open("PopRule", DB_Rule.TargetSeven)
end

function PopLuaSeven.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end

function PopLuaSeven.CheckTutrial()
    --  local TutorialSN = UserL.userTutorialSN
    --  local step = UserL.userTutorialStep

    --  if TutorialSN == 6 then
    --      if step == 3 then
    --          CS.SCall("Tutorial", "PlayTutorial", true, taskItemList[1].transform:FindChild("btn_sure").transform)
    --      end
    --  end
end

--改变广告页位置  n：显示的第几张   0 1 2   398是UIGrid的距离   380是advertisement的初始位置
function PopLuaSeven.ChangeAd(n)
    --初始化广告页位置
    local adPanel = advertisement.transform:GetComponent("UIPanel")
    adPanel.clipOffset = Vector2(398 * n, 0)
    advertisement.transform.localPosition = Vector3(380 - 398 * n, -30, 0)
    local uiCenter = advertisement.transform:GetComponent("UICenterOnChild")
    uiCenter.enabled = true;
end