PopAllyTech = {}
local _body = nil
PopAllyTech.body = _body

local _ref = nil
local items = nil

local map = {"wlg", "zlg", "tsg"}
local data = nil
local techExps = { }

local function GetDesc(sn, lv)
    if sn == 1 then return "武力增加:"..DB.GetAllyTechGain(sn, lv)
    elseif sn == 2 then return "智力增加:"..DB.GetAllyTechGain(sn, lv)
    elseif sn == 3 then return "统帅增加:"..DB.GetAllyTechGain(sn, lv) 
    else return "" end
end

--[Comment]
--获取等级进度条的值
local function GetLevelRate(lv, sn, exp)
    local needExp = DB.GetAllyTechExp(sn, lv)
    if lv == 0 then return exp / needExp
    elseif lv == DB.maxAllyLv then return 1 
    else
        local lastLvExp = DB.GetAllyTechExp(sn, lv - 1)
        return (exp - lastLvExp) / (needExp - lastLvExp)
    end
end

local function UpdateAllyInfo()
    for i=1, #items do
        local lv = user.GetAllyTechLv(i)
        local maxLv = DB.GetAllyTechMaxLv(i)
        local item = items[i]

        local icon = item:ChildWidget("icon")
        local level = item:ChildWidget("level")
        local lvsld = item:GetCmpInChilds(typeof(UISlider))
        local desc = item:ChildWidget("desc_1")
        local costG = item:ChildWidget("lbl_cost_value_gold")
        local costD = item:ChildWidget("lbl_cost_value_diamond")
        local btnG = items[i]:ChildWidget("btn_donate_gold").luaBtn
        local btnD = items[i]:ChildWidget("btn_donate_diamond").luaBtn

        icon:LoadTexAsync("tex_ally_tech_" .. i .. "_1")
        level.text = L("LV:")..lv
        if #techExps > 0 then
            local v = GetLevelRate(lv, i, techExps[i])
            lvsld.value = v
        end
        desc.text = GetDesc(i, lv)

        if lv < maxLv then
            if lv < DB.GetAllyTechLvLimit(i) then
                costG.text = DB.GetAllyTechUpCostGold(i, lv)
                costD.text = DB.GetAllyTechUpCostDiamond(i, lv)
                btnG.isEnabled = true
                btnD.isEnabled = true
            else
                costG.text = L("已达上限")
                costD.text = L("已达上限")
                btnG.isEnabled = false
                btnD.isEnabled = false
            end
        else
            costG.text = L("已满级")
            costD.text = L("已满级")
            btnG.isEnabled = false
            btnD.isEnabled = false
        end
    end
end

function PopAllyTech.OnLoad(c)
    WinBackground(c, { n = "科技中心", i = true, r = DB_Rule.AllyTech})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit","OnDispose","OnUnLoad","ClickDonate")

    items = _ref.items

    for i=1, #items do
        local btnG = items[i]:ChildWidget("btn_donate_gold").luaBtn
        local btnD = items[i]:ChildWidget("btn_donate_diamond").luaBtn
        btnG:SetClick("ClickDonate", {"g", map[i]})
        btnD:SetClick("ClickDonate", {"r", map[i]})
    end
end

function PopAllyTech.ClickDonate(p)
    local moneytype = p[1]
    local tech = p[2]
    SVR.AllyTechDonate(moneytype, tech, function(result)
        if result.success then
            local dat = SVR.datCache
            techExps = data.exps
            for i=1, #items do user.SetAllyTechLv(i, data.levels[i]) end
            UpdateAllyInfo()

            local tip = ""
            local expAdd = 0
            if tech == "wlg" then 
                tip = "武斗场经验增加:+"
                expAdd = dat.exps[1] - data.exps[1]
            elseif tech == "zlg" then 
                tip = "计策府经验增加:+"
                expAdd = dat.exps[2] - data.exps[2]
            elseif tech == "tsg" then 
                tip = "演兵场经验增加:+"
                expAdd = dat.exps[3] - data.exps[3]
            end
            
            local renownAdd = dat.myRenown - data.myRenown
            ToolTip.ShowPopTip(tip..expAdd .."\n联盟币增加:+"..renownAdd)
            data = dat
        end
    end)
end

function PopAllyTech.OnInit()
    print(kjson.print(DB.allyLv))
    SVR.GetAllyTechInfo(function(result)
        if result.success then
            data = SVR.datCache
            techExps = data.exps

            for i=1, #items do
                user.SetAllyTechLv(i, data.levels[i])
            end

            UpdateAllyInfo()

        end
    end)
end

function PopAllyTech.OnDispose()
    data = nil
    techExps = { }
end

function PopAllyTech.OnUnLoad()
    _body = nil
end