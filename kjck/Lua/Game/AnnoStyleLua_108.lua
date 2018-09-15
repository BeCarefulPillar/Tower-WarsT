--凯撒宝库

--require("Data.LuaTool")
AnnoStyleLua_108 = {}
local body = nil

-- ↓ 游戏对象
local title = nil	--标题图片
local reasures = {}--三个宝库
local ef_reasures = {} --三个宝库特效
local btnGiveUp = nil --放弃按钮
local btnHunting = nil --探宝按钮
local btnRule = nil --规则
local cost = nil
local efFly = nil --宝库升级特效
local slider = nil --进度条
local lblHuntingTimes = nil--探宝次数
local boxList = {} --进度宝箱
local labTime = nil --截止时间
local data = {} --xml数据
local actData = {} --服务器返回的数据
local tLv = 0 --当前宝库的等级
local countNode = 0 -- 进度数量
local upData_ing = nil --升级特效的协程
function AnnoStyleLua_108.OnLoad(c)
	body = c
	c:BindFunction("OnInit")	
	c:BindFunction("ClickReasure")
	c:BindFunction("ClickBoxList")
	c:BindFunction("OnUnLoad")
	c:BindFunction("ClickGiveUp")
	c:BindFunction("ClickHunting")
	c:BindFunction("ClickRule")


	title = c.widgets[0]
	cost = c.widgets[1]
	lblHuntingTimes = c.widgets[2]
	labTime = c.widgets[3]

	efFly = c.gos[0]
	ef_reasures[1] = c.gos[1]
	ef_reasures[2] = c.gos[2]
	ef_reasures[3] = c.gos[3]
	slider = c.gos[4]:GetComponent(typeof(UISlider))
	for i=1,5 do
		boxList[i] = c.gos[i+4]
		boxList[i]:GetComponentInChildren(typeof(LuaButton)).param = i
	end
	for i=1,3 do
		reasures[i] = c.btns[i-1]
		reasures[i]:SetClick("ClickReasure",i)
	end
	btnGiveUp = c.btns[3]
	btnHunting = c.btns[4]
	btnRule = c.btns[5]
	btnGiveUp:SetClick("ClickGiveUp")
	btnHunting:SetClick("ClickHunting")
	btnRule:SetClick("ClickRule")


	
	--显示网络数据
	local data = "'info'"
	SVR.SendFunc(Func.ActOpt108,data,function(task)
		if task.success then
			actData = kjson.decode(task.data)
            table.print("act",actData)
			tLv = actData[1]
			AnnoStyleLua_108.UpdateShow()
			AnnoStyleLua_108.SetBoxEf(actData[1]+1)
		end
	end)


end

function AnnoStyleLua_108.OnInit()
    data = WinLuaAffair.getDat(body.data)

	--显示本地数据
	AnnoStyleLua_108.ShowInfo()

    LuaActTimer(body, data.time)

	btnHunting:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = true
	btnGiveUp:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = true
end

function AnnoStyleLua_108.OnDispose()
end

function AnnoStyleLua_108.ShowInfo()
	title:GetComponent(typeof(UITexture)):LoadTexAsync(data.title)

	btnGiveUp:GetComponentInChildren(typeof(UILabel)).text = data.btn1
	btnHunting:GetComponentInChildren(typeof(UILabel)).text = data.btn2
    print(tts(data))
	for i,box in ipairs(boxList) do
		box:GetComponent(typeof(UILabel)).text = data.num[i]
	end
end

--当点击宝库
function AnnoStyleLua_108.ClickReasure(i)
     Win.Open("PopRwdPreview",data.r[i].rw1)
end
--当点击上面那一排箱子
function AnnoStyleLua_108.ClickBoxList(i)
     Win.Open("PopRwdPreview",data.r1[i].rs1)
end
--当点击放弃探宝
function AnnoStyleLua_108.ClickGiveUp()
	local data = "'gu'"
	SVR.SendFunc(Func.ActOpt108,data,function(task)
		if task.success then
			print("*放弃探宝，更新信息")
			actData = kjson.decode(task.data)
			if upData_ing ~= nil then
				coroutine.stop(upData_ing)
				upData_ing = nil
			end
			upData_ing = coroutine.create(AnnoStyleLua_108.OnUpdateActInfo)
			coroutine.resume(upData_ing)
		end
	end)

end

--点击探宝
function AnnoStyleLua_108.ClickHunting()
	local data = "'get'"
	SVR.SendFunc(Func.ActOpt108,data,function(task)
		if task.success then
			print("*探宝，更新信息")
			actData = kjson.decode(task.data)
			--{0,2,[{2,50,20},{2,51,10},{2,52,3},{2,72,1},{1,5,-20}],[{1,2,20}]}
			--等级，分数，[奖励1],[奖励2]
			if upData_ing ~= nil then
				coroutine.stop(upData_ing)
				upData_ing = nil
			end
			upData_ing = coroutine.create(AnnoStyleLua_108.OnUpdateActInfo)
			coroutine.resume(upData_ing)
		end
	end)
end
--点击规则
function AnnoStyleLua_108.ClickRule()
    Win.Open("PopRule",{L("规则说明"),data.rule})
end

--更新信息
function AnnoStyleLua_108.OnUpdateActInfo()

	btnHunting:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = false
	btnGiveUp:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = false
	AnnoStyleLua_108.UpdateShow()

	print("升级了吗",tLv ~= actData[1])

	-- ↓ 升级了，显示飞行特效，然后显示奖励	
	if tLv ~= actData[1] then
		efFly.transform.localPosition = reasures[tLv+1].transform.localPosition
		coroutine.wait(0.05,upData_ing)
		efFly:SetActive(true)
		local tweenPosition = efFly:GetComponent(typeof(TweenPosition))
		tweenPosition.from = efFly.transform.localPosition
		tweenPosition.to = reasures[actData[1]+1].transform.localPosition
		tweenPosition.duration = 1
		tweenPosition:ResetToBeginning()
		tweenPosition:PlayForward()
		coroutine.wait(1,upData_ing)
		AnnoStyleLua_108.SetBoxEf(actData[1]+1)
		coroutine.wait(0.3,upData_ing)
		AnnoStyleLua_108.ShowReward()
		coroutine.wait(1,upData_ing)
		efFly:SetActive(false)

	-- ↓ 没升级，直接显示奖励
	else
		AnnoStyleLua_108.ShowReward()
	end
	tLv = actData[1]
end

function AnnoStyleLua_108.UpdateShow()
	slider.value = actData[2] / data.num[#data.num]
	lblHuntingTimes.text = actData[2]
	AnnoStyleLua_108.SetBoxListComplete()
	cost:GetComponentInChildren(typeof(UILabel)).text = data.r[actData[1]+1].cost
	--cost.spriteName = data.treasures[tLv+1].icr
end

--显示奖励
function AnnoStyleLua_108.ShowReward()
	btnHunting:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = true
	btnGiveUp:GetComponent(typeof(UnityEngine.BoxCollider)).enabled = true
    PopRewardShow.Show(actData[3])
end

--设置当前宝箱的特效
function AnnoStyleLua_108.SetBoxEf(lv)
	for i =1,3 do
		if i == lv then
			ef_reasures[i]:SetActive(true)
		else
			ef_reasures[i]:SetActive(false)
		end
	end
end
--设置探索次数进度（上面那一排宝箱的明暗）
function AnnoStyleLua_108.SetBoxListComplete()
	for i,v in ipairs(data.num) do
		if actData[2] >= tonumber(v) then
			boxList[i]:GetComponentInChildren(typeof(UISprite)).spriteName = "sp_country_box_"..(i-1)
			boxList[i].transform:FindChild("ef"):SetActive(true)
		else
			boxList[i]:GetComponentInChildren(typeof(UISprite)).spriteName = "sp_country_box_dis_"..(i-1)
			boxList[i].transform:FindChild("ef"):SetActive(false)
		end
	end
end