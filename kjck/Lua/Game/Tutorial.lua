local _w  =  { }

local _body = nil
local _ref = nil
-- 当前显示
local _instance = nil

local _word = nil   
local _arrow = nil  
local _npc = nil
local _Mask = nil

local _trans = nil

local _sn = 0
local _steps = nil
local _npcPos = nil

--延迟调用返回的对象
local _invoke = nil

function _w.OnLoad(c)
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad")
    _ref = c.luaRef
    _npc = _ref.cmps[0]
    _word = _ref.cmps[1]   
    _arrow = _ref.cmps[2]  
    _Mask = _ref.cmps[3]
end

--（initObj = { bool canClick, Transform trans}）
function _w.OnInit()
    if user.TutorialSN <= 0 then _body:Exit() return end
    local var = _w.initObj
        print("var var var   ",kjson.print(var))
    if isTable(var) and #var > 1 and var[2] ~= nil then
        print("isTable isTable isTable   ",kjson.print(var))
        local c = var[1]
        local trans = var[2]
        _w.PlayTutorial(c, trans)
    else
        _body:Exit()
    end
end

local function Destruct()
    _body:Exit()
end

local function UpdateArea()
    print("UpdateArea")
    if _trans then
        local b  =  NGUIMath.CalculateRelativeWidgetBounds(_instance.transform, _trans, false)
        _arrow.localPosition  =  Vector2(b.center.x , b.center.y)
        _arrow:SetActive(true)
    else
        _arrow:SetActive(false)
    end
end

local function ClickNode()
    print("~~ClickNode~~~~")
end

local function Next()
    if trans~= nil then
        local idx = user.TutorialStep
        user.TutorialStep = user.TutorialStep + 1
        
        if idx > 0 and idx <= #_steps then
            if _npcPos[idx] == {} then
                _npc:SetActive(false)
                if not string.isEmpty(_steps[idx]) then
                    if idx ~= 0 then
                        PlotDialogue.TutorialPlot(_steps[idx], OnPlotFinished, idx == 78)
                    end
                end
            else
                _word.text = _steps[idx]
                _npc.localPosition = _npcPos[idx]
                _npc:localPosition(true)
            end
        else
            _body:Exit()
            return
        end

        if not _npc.gameObject.activeInHierarchy then
            _Mask.target = _trans
            UpdateArea()

            if user.TutorialSN == 1 and user.TutorialStep == 8 then
                Win.Open("PopBattleOptionTip")
            end

            if user.TutorialSN == 1 then
                if user.TutorialStep == 34 or user.TutorialStep == 37 then
                    ClickNode()
                end
            end
        else

            if _arrow.gameObject.activeSelf then
                _arrow.gameObject:SetActive(false)
            end

        end
    elseif user.TutorialStep > 0 and user.TutorialStep <= #_steps then 
        _npc:SetActive(false)
        _arrow:SetActive(false)
        if user.TutorialSN == 2 then  --竞技场引导
            if user.TutorialStep == 7 then
                --User.TipRankSolo = false
            end
            _body:Exit()
        else
            _body:Exit()
        end
    else
        if user.TutorialSN == 1 then
            user.TutorialSN = 0
            user.TutorialStep = 0
        else
            user.TutorialSN = 0
            user.TutorialStep = 0
        end
        _body:Exit()
    end
end


--开始新手（bool canClick, params Transform[] trans）
function _w.PlayTutorial(canClick, trans)
    if _invoke then _invoke:Stop() end

    if _sn ~= user.TutorialSN or _steps == nil then
        _sn = user.TutorialSN
        local list = {}
        for k,v in ipairs(_w.Step) do
            if v.sn == _sn then
                table.insert(list ,v)
            end
        end
        if #list > 0 then
            _steps = {}
            _npcPos = {}
            for k,v in ipairs(list) do
                local p = string.split(v.p ,',')
                if #p >1 then
                    table.insert(_npcPos, Vector2(tonumber(p[1]), tonumber(p[2])))
                else
                    table.insert(_npcPos, { })
                end
                table.insert(_steps, v.va)
            end
        else
            Destruct()
            return
        end
    end
    _trans = trans
    Next()
end




_w.Step  =  
{
    [1]  = {p = "",s = 1,sn = 1,va = "关羽,15 = 尔等逆贼，如土鸡瓦狗插标卖首之辈，看关某取汝首级！|张梁,108 = 你这红脸莽汉，忒的自大，看招！"},	[2]  = {p = "-127,-67",s = 2,sn = 1,va = "主公，点击[c][F10325]快速任务栏[-][/c]可完成相关任务，完成任务可获得大量奖励!"},	[3]  = {p = "",s = 3,sn = 1,va = ""},	[4]  = {p = "-127,-67",s = 4,sn = 1,va = "主公，张梁是一名[c][F10325]“智”[-][/c]将，趁现在[c][65cb49]体力[-][/c]正盛，派他攻下前面的城池吧。"},	[5]  = {p = "",s = 5,sn = 1,va = ""},	[6]  = {p = "-127,-67",s = 6,sn = 1,va = "[c][F10325]智将[-][/c]运筹帷幄，决胜千里!"},	[7]  = {p = "",s = 7,sn = 1,va = ""},	[8]  = {p = "-127,-67",s = 8,sn = 1,va = "主公，[c][F10325]“智”[-][/c]将擅用[c][F10325]技能[-][/c]远程攻击，在敌将未靠近之前击杀即可获得胜利。"},	[9]  = {p = "",s = 9,sn = 1,va = ""}, 	[10] = {p = "-127,-67",s = 10,sn = 1,va = "主公,完成主线任务,领取奖励可升级主城!"},	[11] = {p = "",s = 11,sn = 1,va = ""},	[12] = {p = "-127,-67",s = 12,sn = 1,va = "主公,点击快捷任务栏可继续完成主线任务!"},	[13] = {p = "",s = 13,sn = 1,va = ""},	[14] = {p = "-127,-67",s = 14,sn = 1,va = "主公,周仓是一名[c][F10325]“武”[-][/c]将,试试武将的威力吧！"},	[15] = {p = "",s = 15,sn = 1,va = ""},	[16] = {p = "-127,-67",s = 16,sn = 1,va = "[c][F10325]武将[-][/c]擅长近身作战，可一骑当千!"},	[17] = {p = "",s = 17,sn = 1,va = ""},	[18] = {p = "",s = 18,sn = 1,va = ""},	[19] = {p = "",s = 19,sn = 1,va = ""},	[20] = {p = "",s = 20,sn = 1,va = ""},	[21] = {p = "",s = 21,sn = 1,va = ""},	[22] = {p = "",s = 22,sn = 1,va = ""},	[23] = {p = "",s = 23,sn = 1,va = ""},	[24] = {p = "-127,-67",s = 24,sn = 1,va = "[c][F10325]开发[-][/c]城池可以升经城池,获得更大产出!"},	[25] = {p = "",s = 25,sn = 1,va = ""},	[26] = {p = "-127,-67",s = 26,sn = 1,va = "[c][F10325]收获[-][/c]城池可获得城池产出"},	[27] = {p = "",s = 27,sn = 1,va = ""},	[28] = {p = "-127,-67",s = 28,sn = 1,va = "主公，获得装备后为将领[c][F10325]穿戴装备[-][/c],能够大幅提升将领的战斗力！"},	[29] = {p = "",s = 29,sn = 1,va = ""},	[30] = {p = "",s = 30,sn = 1,va = ""},	[31] = {p = "-127,-67",s = 31,sn = 1,va = "点击[c][F10325]装备[-][/c]页签,即可为武将穿戴装备。"},	[32] = {p = "",s = 32,sn = 1,va = ""},	[33] = {p = "",s = 33,sn = 1,va = ""},	[34] = {p = "-127,-67",s = 34,sn = 1,va = "装备防具[c][008CFF][连环铠][-][/c]之后，[c][F10325]将领防御[-][/c]大幅提高。"},	[35] = {p = "",s = 35,sn = 1,va = ""},	[36] = {p = "",s = 36,sn = 1,va = ""},	[37] = {p = "-127,-67",s = 37,sn = 1,va = "装备兵书[c][008CFF][三略][-][/c]之后，[c][F10325]将领智力[-][/c]大幅提高。"},	[38] = {p = "",s = 38,sn = 1,va = ""},	[39] = {p = "",s = 39,sn = 1,va = ""},	[40] = {p = "",s = 40,sn = 1,va = ""},	[41] = {p = "",s = 41,sn = 1,va = ""},	[42] = {p = "",s = 42,sn = 1,va = ""},	[43] = {p = "-127,-67",s = 43,sn = 1,va = "装备也可以进行[c][F10325]强化[-][/c]，能够再次提升将领战斗力。"},	[44] = {p = "",s = 44,sn = 1,va = ""},	[45] = {p = "",s = 45,sn = 1,va = ""},	[46] = {p = "",s = 46,sn = 1,va = ""},	[47] = {p = "",s = 47,sn = 1,va = ""},	[48] = {p = "",s = 48,sn = 1,va = ""},	[49] = {p = "-127,-67",s = 49,sn = 1,va = "装备还可以进行[c][F10325]一键强化[-][/c]。"},	[50] = {p = "",s = 50,sn = 1,va = ""},	[51] = {p = "",s = 51,sn = 1,va = ""},	[52] = {p = "",s = 52,sn = 1,va = ""},	[53] = {p = "",s = 53,sn = 1,va = ""},	[54] = {p = "-127,-67",s = 54,sn = 1,va = "主公，目前[c][F10325]酒馆[-][/c]已经开放，可以在其中招募到优秀的将领!快回主城看看吧!"},	[55] = {p = "",s = 55,sn = 1,va = ""},	[56] = {p = "-127,-67",s = 56,sn = 1,va = "[c][F10325]酒馆[-][/c]招募[c][F10325]五星[-][/c]将，可助主公成就霸业！"},--	[] = {p = "",s = 57,sn = 1,va = ""},
--	[] = {p = "-127,-67",s = 58,sn = 1,va = "主公,点击[c][F10325]刷新[-][/c]按钮有机会刷出[c][F10325]五星[-][/c]将!试试运气吧!"},
--	[] = {p = "",s = 59,sn = 1,va = ""},
--	[] = {p = "-127,-67",s = 60,sn = 1,va = "与将领[c][F10325]喝酒[-][/c]能够增加[c][F10325]好感度[-][/c]，招募会变得更加容易。"},
--	[] = {p = "",s = 61,sn = 1,va = ""},
--	[] = {p = "",s = 62,sn = 1,va = ""},
--	[] = {p = "",s = 63,sn = 1,va = ""},
--	[] = {p = "",s = 64,sn = 1,va = ""},
--	[] = {p = "-127,-67",s = 65,sn = 1,va = "主公，[c][F10325]经验药[-][/c]是一种神奇的道具，可以迅速提升[c][F10325]将领等级[-][/c]！"},
--	[] = {p = "",s = 66,sn = 1,va = ""},
--	[] = {p = "",s = 67,sn = 1,va = ""},
--	[] = {p = "",s = 68,sn = 1,va = ""},
--	[] = {p = "-127,-67",s = 69,sn = 1,va = "主公，吾为您准备了[c][F10325]小助手[-][/c]功能，它可以方便地指引您处理当前事务。"},
--	[] = {p = "",s = 70,sn = 1,va = ""},
--	[] = {p = "-127,-67",s = 71,sn = 1,va = "点击相关任务可快速跳转至此任务。"},
--	[] = {p = "",s = 72,sn = 1,va = ""},
--	[] = {p = "",s = 73,sn = 1,va = ""},
--	[] = {p = "-127,-67",s = 74,sn = 1,va = "当前阵型被敌方克制，我方出战的[c][F10325]武将属性[-][/c]将会[c][F10325]被压制[-][/c]，所以我们需要[c][F10325]更换阵型[-][/c]避免被克。"},
--	[] = {p = "",s = 75,sn = 1,va = ""},
--	[] = {p = "",s = 76,sn = 1,va = ""},
--	[] = {p = "",s = 77,sn = 1,va = ""},
--	[] = {p = "",s = 78,sn = 1,va = ""},
--	[] = {p = "",s = 79,sn = 1,va = "张角,337 = 此战我军势弱，若你能在[FF0000]南阳[-]再次战胜我，便加入你麾下！|月英,1004 = 主公，[FF9933]五星张角[-]退守南阳，距离战胜并招募他还有[FF0000]4[-]关！"},
--	[] = {p = "-127,-67",s = 1,sn = 2,va = "主公,竞技场已开启,可挑战其他玩家,获取排行奖励!"},
--	[] = {p = "",s = 2,sn = 2,va = ""},
--	[] = {p = "",s = 3,sn = 2,va = ""},
--	[] = {p = "",s = 4,sn = 2,va = ""},
--	[] = {p = "",s = 5,sn = 2,va = ""},
--	[] = {p = "",s = 6,sn = 2,va = ""},
--	[] = {p = "",s = 7,sn = 2,va = ""},
--	[] = {p = "-127,-67",s = 1,sn = 3,va = "主公,国战已开启,部署武将,成就霸业!"},
--	[] = {p = "",s = 2,sn = 3,va = ""},
--	[] = {p = "",s = 3,sn = 3,va = ""},
--	[] = {p = "",s = 4,sn = 3,va = ""},
--	[] = {p = "",s = 5,sn = 3,va = ""},
--	[] = {p = "",s = 6,sn = 3,va = ""},
--	[] = {p = "",s = 7,sn = 3,va = ""},
--	[] = {p = "",s = 8,sn = 3,va = ""},
--	[] = {p = "",s = 9,sn = 3,va = ""},
--	[] = {p = "",s = 10,sn = 3,va = ""},
--	[] = {p = "",s = 11,sn = 3,va = ""},
--	[] = {p = "",s = 1,sn = 4,va = ""},
--	[] = {p = "",s = 2,sn = 4,va = ""},
--	[] = {p = "",s = 3,sn = 4,va = ""},
--	[] = {p = "",s = 4,sn = 4,va = ""},
--	[] = {p = "",s = 5,sn = 4,va = ""},
--	[] = {p = "",s = 1,sn = 5,va = ""},
--	[] = {p = "",s = 2,sn = 5,va = ""},
--	[] = {p = "",s = 3,sn = 5,va = ""},
--	[] = {p = "",s = 4,sn = 5,va = ""},
--	[] = {p = "-127,-67",s = 1,sn = 6,va = "主公,完成[c][F10325]七日目标[-][/c]任务可获得丰厚任务奖励!"},
--	[] = {p = "",s = 2,sn = 6,va = ""},
--	[] = {p = "",s = 3,sn = 6,va = ""},
--	[] = {p = "",s = 4,sn = 6,va = ""},
--	[] = {p = "-127,-67",s = 1,sn = 7,va = "主公,获得[c][F10325]VIP经验[-][/c]后,VIP等级会自动提升,并可领取相应的VIP等级奖励!"},
--	[] = {p = "",s = 2,sn = 7,va = ""},
--	[] = {p = "",s = 3,sn = 7,va = ""},
--	[] = {p = "",s = 4,sn = 7,va = ""},
--	[] = {p = "",s = 5,sn = 7,va = ""},
--	[] = {p = "",s = 6,sn = 7,va = ""},
--	[] = {p = "",s = 7,sn = 7,va = ""}
}

--[Comment]
--新手指导
Tutorial = _w
