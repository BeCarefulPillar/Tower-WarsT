local Destroy = UnityEngine.Object.Destroy

PopLuaExchange = {}

local grid = nil
local item = nil
local money = nil
local itemGoods = nil

local thisLocalData = nil
local thisActData = nil
local thisCallBack = nil --当点击兑换时
--生成的item保存起来，更新数据时用
local itemList = {}
local buildItem_ing = nil --创建item的协同程序

function PopLuaExchange.OnLoad(c)
    PopLuaExchange.body = c

	c:BindFunction("ClickClose")
	c:BindFunction("ClickExchange")
	c:BindFunction("OnDispose")
    c:BindFunction("ClickItemGoods")

	grid = c.gos[0]
	item = c.gos[1]
	itemGoods = c.gos[2]
	money = c.widgets[0]

end
function PopLuaExchange.OnDispose()
    grid:DesAllChild()
	if buildItem_ing ~= nil then
		coroutine.stop(buildItem_ing)
		buildItem_ing = nil
	end
end

function PopLuaExchange.SetInit(localData,actData,callBack)	
	thisLocalData = localData
	thisActData = actData
	thisCallBack = callBack
	
	if buildItem_ing ~= nil then
		coroutine.stop(buildItem_ing)
		buildItem_ing = nil
	end
	buildItem_ing = coroutine.create(PopLuaExchange.BuildItem)
	coroutine.resume(buildItem_ing)

end

function PopLuaExchange.BuildItem()
	local uiGrid =grid:GetComponent(typeof(UIGrid)) 
	local r = thisLocalData.r
	itemList = {}
	for i=2,#r do
		coroutine.step()
		local key = tonumber(r[i].va[1])
		local it = grid:AddChild(item,key)
		it:SetActive(true)
		PopLuaExchange.InitItem(it,r[i])
		itemList[key] = it
		uiGrid.repositionNow = true
	end
	PopLuaExchange.UpdateInfo()

end


function PopLuaExchange.InitItem(it,r)
	it:GetComponent(typeof(UILabel)).text = "00/00"
	
	local item = ItemGoods(it:AddChild(itemGoods,"costItem"))
	item.go.transform.localPosition = Vector3(156, 14, 0)
	item.go.transform.localScale = Vector3(0.8,0.8,0.8)
    item:Init(r.rw[1])

	local ig = ItemGoods(it:AddChild(itemGoods,"getItem"))
	ig.go.transform.localPosition = Vector3(365, 14, 0.8)
	ig.go.transform.localScale = Vector3(0.8,0.8,0.8)
    ig:Init(r.rw[2])
    ig.go.luaBtn.luaContainer = PopLuaExchange.body                                   

	it:GetComponentInChildren(typeof(LuaButton)):SetClick("ClickExchange",r.va[1])
end

function PopLuaExchange.ClickItemGoods(btn)                            
    btn = btn and Item.Get(btn.gameObject)
    if btn then btn:ShowPropTip() end
end

--更新信息
function PopLuaExchange.UpdateInfo()
	-- ↓ 欢乐币
	money.text = thisActData[7]
	-- ↓ 领取数量
	getCounts = PopLuaExchange.ParseGetCount(thisActData[8])
	for i,it in next,itemList do
		it:GetComponent(typeof(UILabel)).text = getCounts[i].."/10"
	end
	
end

--点击兑换（操作码）
function PopLuaExchange.ClickExchange(opNum)
	
	local data = string.format("%s,'get|%s|1'",thisLocalData.sn,opNum)
	SVR.SendFunc(Func.ActOpt,data,function(task)
		if task.success then
			thisActData = kjson.decode(task.data)
			PopLuaExchange.UpdateInfo()
			--SFSServer.AnalyzeReward(AnnoStyleLua_13.TableToJson(thisActData[13]))
            PopRewardShow.Show(thisActData[13])
			thisCallBack(thisActData)
		end
	end)

end


--转为{[操作码]=领取数量,....}
function PopLuaExchange.ParseGetCount(getData)
	local result = {}

	local len = #getData
	for i=1,len,2 do
		result[getData[i]] = getData[i+1]
	end
	
	return result
end