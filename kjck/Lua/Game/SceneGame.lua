require "Game/MainUI"
require "Game/NewEffect"
require "Game/UnLockEffect"
require "Game/ItemGoods"
require "Game/ItemSign"
require "Game/ItemHero"
require "Game/ItemCity"
require "Game/ItemPvpMap"
require "Game/ItemPvpCity"

--��Ҫ��ǰ���صĴ���
require "Game/PopUseProps"
require "Game/PopRewardShow"
require "Game/PopSelectHero"
require "Game/PopAssistant"
require "Game/PlotDialogue"
require "Game/PopCityButtons"
require "Game/Tutorial"

SceneGame = {}

local _body = nil

local _mainUI = nil
local _winStats = nil

function SceneGame.OnLoad(c)
    _body = c
    SceneGame.body = c

    c:BindFunction("OnUnLoad", "Start", "OnEnter", "OnExit")

end

local function OnReturn()
    if --[[ Tutorial.IsShow ]] false then SDK.ShowExitView()
    elseif Scene.focusWin ~= nil then Scene.focusWin.Return()
    elseif LevelMap ~= nil and LevelMap.IsPrepareExpedition then LevelMap.CancleExpedition()
    else SDK.ShowExitView() end
end

function SceneGame.Start()
    --����UI
    MainUI.Init()
    -- ��������
    Win.Open("MainMap")
    -- ������ֽ�ѧ

--    if user.GetTutorialSN() == 1 and user.GetTutorialStep() == 1 then
--        --[[ //BeginScript.Begin();
--            MapManager.Instance.MainMap.LoadAndShow()
--            MapManager.Instance.MainMap.GetCpt(TweenAlpha).PlayForward()
--            MapManager.Instance.MainMap.Roles[0].gameObject.SetActive(false)
--            MainPanel.Instance.GetCptUIPanel).enabled = false
--            Tutorial.PlayTutorial(false, t)//�������ֽ�ѧ��ƪ
--        ]]
--    -- ��������
--    else Win.Open("MainUI") end
--    if user.GetTutorialSN() == 2 and user.GetTutorialStep() == 1 then
--        if user.HasLowLoyatyHero() and user.GetPropsQty(DB_Props.ZHU_BAO) > 0 then --[[ Tutorial.PlayTutorial(false,t) ]] end
--    end
--    print("��������  ��ʾ��²~~~~~~~  " , kjson.print( user.battleRet))
--    if user.gmMaxCity > 1 and #user.battleRet.captive > 0 then
--        if user.gmMaxCity < CONFIG.T_LEVEL then --[[ BattleManager.ShowTutorialCapTive(nil)]]
--        else Win.Open("WinCaptive") end 
--    end

--    if user.GetTutorialSN() == 0 then SceneGame.InitEvent() end 

    _body.loadingProgress = 1

end

function SceneGame.InitEvent()
    Win.Open("PopAnno", "showSign")
    user.CheckVerifyLogin()
end 

--[Comment]
-- ����������UI�͵�ͼ
function SceneGame.ShowMainUIAndMap()
    if _winStats ~= nil then
        for k, v in pairs(_winStats) do
            if k then k:SetActive(v) end
        end
    end
    _winStats = nil
end 

--[Comment]
-- ����������UI�͵�ͼ
function SceneGame.HideMainUIAndMap()
    _winStats = { }
    if _mainUI == nil then _mainUI = MainUI.body.gameObject end
    local isa = _mainUI.activeSelf
    _winStats[_mainUI] = isa
    _mainUI:SetActive(false)
    local wins = Win.GetWins()
    if wins ~= nil then
        for i = 0, wins.length - 1 do
            if wins[i].isBackLayer or wins[i].winName == "BattleManager" or wins[i].winName == "WinBattle" or wins[i].winName == "WinDaily" then
                if wins[i].isBackLayer then
                    isa = wins[i].gameObject.activeSelf
                    _winStats[wins[i].gameObject] = isa
                    wins[i].active = false
                end
            else wins[i]:Exit()
            end
        end
    end
end 

function SceneGame.OnEnter()
    --[[ EventManager.AddListener(EventName.ReturnKey, OnReturn) ]]
end

function SceneGame.OnExit()
    --[[ EventManager.RemoveListener(EventName.ReturnKey, OnReturn) ]]
end

function SceneGame.OnUnLoad()
    _body = nil
    _mainUI = nil
end


