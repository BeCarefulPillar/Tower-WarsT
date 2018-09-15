AnnoStyleLua_102 = { }

local _body = nil
local _ref = nil

local total = 0
local items = { }
local get = 0
local mData = { }  -- Affair json数据
local data = { } -- 相当于S_Affair 结构体数据
local targetValue = { }
local hCityLv = nil 

function AnnoStyleLua_102.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "ClickBuy",
    "OnUnLoad",
    "Refresh",
    "RefreshInfo",
    "ClickItem"
    )

    _ref.lab_1.text = L("您已领取:")
    _ref.lab_2.text = L("还可领取:")
    _ref.lab_3.text = L("已有")
    _ref.lab_4.text = L("人购买")
end

function AnnoStyleLua_102.OnInit()
    _ref.grid:DesAllChild()
    mData = WinLuaAffair.getDat(_body.data)
    _ref.texTitle:LoadTexAsync(mData.title)
    hCityLv = user.gmMaxCity

    AnnoStyleLua_102.Refresh()
end

local function BuildItems()
    -- 获取当前攻占 最高城池
    -- hCityLv = CS.GetSProperty("User", "HighCity")    -- 玩家攻占的最高城池User.HighCity
    hCityLv = user.gmMaxCity
    if _ref.grid.transform.childCount > 0 then
        _ref.grid:DesAllChild()
    end
    local nodes = mData.r
    -- 得到r标签
    local cnt = #nodes

    total = 0
    get = 0
    -- 得到r的长度
    for i = 1, cnt do
        -- 将r标签中的值转化为一个表
        targetValue[i] = nodes[i].va
        total = total + targetValue[i][3]
        items[i] = _ref.grid:AddChild(_ref.item, string.format("item_%02d", i))
        items[i]:SetActive(true)
        local t = items[i].transform
        local lv = t:FindChild("lab_level"):GetComponent(typeof(UILabel))
        if hCityLv < targetValue[i][2] then
            lv.text = L("通关") .. "[ff0000]" .. DB.GetGmCity(targetValue[i][2]).nm .. "[-]" .. L("可领取")
        else
            lv.text = L("通关") .. "[00ff00]" .. DB.GetGmCity(targetValue[i][2]).nm .. "[-]" .. L("可领取")
        end
        t:FindChild("lab_num"):GetComponent(typeof(UILabel)).text = "X" .. targetValue[i][3]
        t:ChildBtn("btn_get"):SetClick("ClickItem", targetValue[i][1])

        -- 设置每个物体上的button按钮点击
        local btn = t:GetComponentInChildren(typeof(UIButton))
        local lab = btn:GetComponentInChildren(typeof(UILabel))
        local btnBool = AnnoStyleLua_102.IsGet(data.record, targetValue[i][1]);
        local isBuy = AnnoStyleLua_102.IsBuy()
        if btnBool then
            get = get + targetValue[i][3]
            btn.isEnabled = false
            lab.text = L("已领取")
        else
            btn.isEnabled =(isBuy and(hCityLv >= targetValue[i][2]))
            if isBuy then
                lab.text = L("领 取")
            else
                lab.text = L("未购买")
            end
        end
    end

    _ref.grid:GetComponent(typeof(UIGrid)).repositionNow = true
    AnnoStyleLua_102.RefreshInfo()
end

function AnnoStyleLua_102.OnDispose()
    mData = { }
    items = { }
    data = { }
    total = 0
    get = 0
    targetValue = { }
end

-- 刷新data信息
function AnnoStyleLua_102.Refresh()
    SVR.AffairOption("inf|" .. mData.sn, function(t)
        if t.success then
            data = SVR.datCache
            table.print("data", data)
            BuildItems()
        end
    end )
end

-- 更新页面信息
function AnnoStyleLua_102.RefreshInfo()
    local isBuy = AnnoStyleLua_102.IsBuy()
    if isBuy then
        _ref.btnBuy:GetComponentInChildren(typeof(UILabel)).text = L("已 买")
        _ref.btnBuy:GetComponent(typeof(UIButton)).isEnabled = false
    else
        if user.vip < mData.vip then
            -- 判断用户vip等级<vip
            _ref.btnBuy:GetComponentInChildren(typeof(UILabel)).text = L("需VIP") .. mData.vip
            _ref.btnBuy:GetComponent(typeof(UIButton)).isEnabled = false
        else
            _ref.btnBuy:GetComponentInChildren(typeof(UILabel)).text = L("购 买")
            _ref.btnBuy:GetComponent(typeof(UIButton)).isEnabled = true
        end
    end

    if #data.ext > 1 then
        _ref.labBuyQty.text = string.format("已有%s人购买", "[FFB16B][b]" .. data.ext[2] .. "[/b][-]");
    else
        _ref.labBuyQty.text = string.format("已有%s人购买", "[FFB16B][b]0[/b][-]")
    end

    _ref.labGet.text = tostring(get)
    _ref.labRemain.text = tostring(total - get)


end

function AnnoStyleLua_102.IsBuy()
    local len = #data.ext
    if len > 0 then
        return data.ext[1] == 1
    else
        return false
    end
end

function AnnoStyleLua_102.OnUnLoad(c)
end

function AnnoStyleLua_102.IsGet(t, val)
    for k, v in ipairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

-- 购买开服基金
function AnnoStyleLua_102.ClickBuy()
    local data = "'buy|1'"
    SVR.SendFunc(Func.GetFundOpt, data, function(task)
        if task.success then
            AnnoStyleLua_102.Refresh()
            ToolTip.ShowPopTip(L("开服基金购买成功！"))
        end
    end )
end

-- 点击子物体中的按钮
function AnnoStyleLua_102.ClickItem(idx)
    if idx > 0 then
        local sendMessage = "'rew|" .. idx .. "'"
        SVR.SendFunc(Func.GetFundOpt, sendMessage, function(task)
            if task.success then
                local len = #targetValue
                local btn
                for i = 1, len do
                    if targetValue[i][1] == idx then
                        btn = items[i]:GetComponentInChildren(typeof(LuaButton))
                        get = get + targetValue[i][3]
                        break
                    end
                end
                if btn then
                    btn.isEnabled = false;
                    btn:GetComponentInChildren(typeof(UILabel)).text = L("已领取");
                end
                _ref.labGet.text = tostring(get)
                _ref.labRemain.text = tostring(total - get)
            end
            WinLuaAffair.RefreshInfo()
        end )
    end
end