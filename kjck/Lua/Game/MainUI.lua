require "Game/PopChat"

local isnull = tolua.isnull
local notnull = notnull

MainUI = { }
MainUI.isOpen = false
local _body = nil


--右上第一排按钮的UIGrid
local _objGrid = nil
--右上第二排按钮的UIGrid
local _objGrid1 = nil
--快捷任务栏
local _objSimpleQuest = nil
--右下按钮的UIGrid
local _objGridBottom = nil
--左边按钮的UIGrid
local _objGridLeft = nil
--体力进度条
local _objVit = nil
--[Comment]
--征战宝箱
local _expeditionBox = nil
MainUI.expeditionBox = nil
--[Comment]
--每一关卡的名字
local _labMapLevel = nil
MainUI.labMapLevel = nil


--角色名
local _labName = nil
--角色等级(主城等级)
local _labLV = nil
--体力值
local _labVit = nil
--vip等级(十位)
local _labVipLV1 = nil
--vip等级(个位)
local _labVipLV2 = nil
--实力值
local _labPower = nil
--金币
local _labGold = nil
--银币
local _labSilver = nil
--钻石
local _labDiamond = nil
--头像
local _texAvatar = nil
--聊天消息提示
local _chatPop = nil
local _cahtPopIvk = nil

local _btns = {
    --联盟按钮
    ally = nil,
    --副本按钮
    fb = nil,
    --任务按钮
    quest = nil,
    --背包按钮
    bag = nil,
    --武将按钮
    hero = nil,
    --聊天按钮
    chat = nil,
    --主城等级相关礼包按钮
    homeLVGift = nil,
    --福利按钮
    affair = nil,
    --建议按钮
    suggest = nil,
    --邮件按钮
    mail = nil,
    --社交按钮
    social = nil,
    --在线奖励按钮
    onlineRW = nil,
    --晏会按钮
    party = nil,
    --福利里的VIP相关礼包
    vipDayGift = nil,
    --福利的关闭按钮
    affairClose = nil,
    --日常按钮
    daily = nil,
    --签到按钮
    sign = nil,
    --天降秘宝
    treasure = nil,
    --嘉年华按钮
    carnival = nil,
    --寻宝按钮
    reward10 = nil,
    --小助手按钮
    assistant = nil,
    --首充按钮
    firstCharge = nil,
    --活动按钮
    act = nil,
    --充值按钮
    recharge = nil,
    --VIP豪礼按钮
    vipHL = nil,
    --占卜按钮
    divine = nil,
    --地宫按钮
    gve = nil,
    --决斗按钮
    tower = nil,
    --BOSS战按钮
    boss = nil,
    --七日目标按钮
    seven = nil,
    --成就按钮
    achv = nil,
    --答题按钮
    question = nil,
    --关卡地图上一关按钮
    prevLv = nil,
    --关卡地图下一关按钮
    nextLv = nil,
    --快捷任务栏
    simpleQuest = nil,
    --征战按钮
    campaign = nil,
    --世界按钮
    pvp = nil,
    --主城按钮
    mainCity = nil,
    --角色头像
    avatar = nil,
    --购买体力按钮
    addVit = nil,
    --实力榜按钮
    power = nil,
    --购买金币按钮
    addGold = nil,
    --购买银币按钮
    addSilver = nil,
    --购买钻石按钮
    addDiamond = nil,
    --借将按钮
    borrowHero = nil,
    --地宫组队邀请按钮
    palaceInvite = nil,
    --VIP等级礼包按钮
    vipLV = nil
}

MainUI.btns = _btns

local _curShowMap = nil
local OnCL = nil
local checkUI = nil
--[Comment]
--是否显示快捷任务栏
local isOpenSQ = false

local function Update()
    
end

local function ShowBorrowBtn()
    _btns.borrowHero.gameObject:SetActive(true)
end

local function CheckBorrowBtn()
    --查询收到的申请
    SVR.AllyBorrowHeroCheckFromOther(function(result)
        if result.success then
            local res = SVR.datCache
            for i=1, #res do
                if res[i].status == 0 and res[i].refused == 0 then
                    _btns.borrowHero.gameObject:SetActive(true)
                end
            end
        end
    end)
    --查询自己发起的申请
    SVR.AllyBorrowHeroCheck(function(result)
        if result.success then
            local res = SVR.datCache.applies
            for i=1, #res do
                if res[i].opt == 0 then
                    _btns.borrowHero.gameObject:SetActive(true)
                    break
                end
            end
        end
    end)
end
MainUI.CheckBorrowBtn = CheckBorrowBtn

local function UpdateInvBtn()
    _btns.palaceInvite.gameObject:SetActive(true)
end

local function CheckInvBtn()
    SVR.GveCheckInvite(function(result)
        if result.success then
            local res = SVR.datCache
            _btns.palaceInvite.gameObject:SetActive(#res > 0)
        end
    end)
end
MainUI.CheckInvBtn = CheckInvBtn

local function UpdateExtInfo()
    if user.gmMaxCity < 7 then _labName.text = "天命之人"
    else _labName.text = user.nick end
    
    _labGold.text = user.gold
    _labSilver.text = user.coin
    _labDiamond.text = user.rmb
    _labLV.text = user.hlv
    _labPower.text = user.score
    _labVit.text = user.vit .. "/" .. user.MaxVit
    --体力进度条
    _objVit:GetCmp(typeof(UISlider)).value = user.vit / user.MaxVit

    --VIP等级显示
    if user.vip > 9 then
        _labVipLV1.gameObject:SetActive(true)
        _labVipLV1.spriteName = "lab_chat_vip_" .. user.vip / 10
        _labVipLV2.spriteName = "lab_chat_vip_" .. user.vip % 10
        _labVipLV1.transform.localPosition = Vector3.New(-4, 1, 0)
        _labVipLV2.transform.localPosition = Vector3.New(3, 1, 0)
    else
        _labVipLV1.gameObject:SetActive(false)
        _labVipLV2.spriteName = "lab_chat_vip_" .. user.vip
        _labVipLV2.transform.localPosition = Vector3.New(0, 1, 0)
    end

    --按钮激活
    _btns.fb.gameObject:SetActive(user.IsHistroyUL)
    _btns.ally.gameObject:SetActive(user.IsAllyUL)
    _objGridBottom:GetCmp(typeof(UIGrid)).repositionNow = true

    _btns.daily.gameObject:SetActive(user.IsDailyUL)
    _btns.sign.gameObject:SetActive(user.IsSignUL)
    _btns.reward10.gameObject:SetActive(user.IsReward10UL)
    _btns.carnival.gameObject:SetActive(user.IsCarnivalUL)
    _objGrid:GetCmp(typeof(UIGrid)).repositionNow = true

    if user.seven ~= nil and user.seven ~= "" then 
       _btns.seven.gameObject:SetActive(user.IsTarget7UL)
    else 
        _btns.seven.gameObject:SetActive(false)
    end
    _btns.boss.gameObject:SetActive(user.IsBossUL)
    _btns.divine.gameObject:SetActive(user.IsDivineUL)
    _btns.tower.gameObject:SetActive(user.IsTowerUL)
    _btns.gve.gameObject:SetActive(user.IsGveUL)
    _objGrid1:GetCmp(typeof(UIGrid)).repositionNow = true

    MainUI.SQRefresh()
end

local function UpdateUserInfo()
    if user.gmMaxCity < 7 then _texAvatar:LoadTexAsync("ava_3_m")
    else _texAvatar:LoadTexAsync(ResName.PlayerIconMain(user.ava)) end

    UpdateExtInfo()
end
MainUI.UpdateUserInfo = UpdateUserInfo

local _onNewChat = UpdateBeat:CreateListener(function()
    if _chatPop and _body.activeSelf and PopChat == nil or not PopChat.isOpen and #user.chats > 0 then
        local d = user.chats[#user.chats]
        _chatPop.color = ColorStyle.Chat(d.chn)
        _chatPop.text = "[" .. ChatChn.Name(d.chn) .. "]" .. (d.nick and d.nick ~= "" and d.nick .. ":" or "") .. (d.text or "")
        EF.FadeIn(_chatPop, 0.3)
        if _cahtPopIvk then
            _cahtPopIvk:Reset(nil, 3)
        else
            _cahtPopIvk = Invoke(function() EF.FadeOut(_chatPop, 0.3) end, 3)
        end
    end
end)

local function Refresh()
    UpdateUserInfo()
    MainUI.ChecGiftBtn(nil)
    CheckInvBtn()
    CheckBorrowBtn()
end

function MainUI.Init()
    if isnull(_body) and notnull(SceneGame.body) then
        SceneGame.body:AddChild(AM.LoadPrefab("MainUI"), "MainUI")
    end
end

function MainUI.OnLoad(c)
    _body = c
    MainUI.body = _body

    c:BindFunction("OnUnLoad")

    c:BindFunction("ClickAlly", "ClickFB", "ClickQuest", "ClickStorage", "ClickHero",
    "ClickChat", "ClickGift", "ClickSuggest", "ClickMail", "ClickSocial",
    "ClickAffair", "ClickCloseAffair", "ClickOnline", "ClickParty", "ClickVipDayRW",
    "ClickDaily", "ClickSign", "ClickTreasure", "ClickCarnival", "ClickReward10",
    "ClickAssistant", "ClickFirstCharge", "ClickAct", "ClickRecharge", "ClickVipHL",
    "ClickDivine", "ClickGve", "ClickTower", "ClickBoss", "ClickSeven",
    "ClickAchv", "ClickAnwser", "ClickSimpleQuest", "ClickCampaign", "ClickPVP",
    "ClickMainCity", "ClickAvatar", "ClickAddVit", "ClickPower", "ClickAddSilver",
    "ClickBorrowHeroApply", "ClickPalaceApply", "ClickVIP",
    "ClickGuide", "ClickComplete")

    --征战界面按钮事件绑定
    c:BindFunction("ClickBox")
    

    local tmp = c.gos
    _objGrid = tmp[0]
    _objGrid1 = tmp[1]
    _objSimpleQuest = tmp[2]
    _objGridBottom = tmp[3]
    _objVit = tmp[4]
    _objGridLeft = tmp[5]
    _expeditionBox = tmp[6]
--    --快捷任务栏
    local cmp = _objSimpleQuest.luaSrf
    local arr =  cmp.gos
    local cmps =  cmp.cmps
    _objSimpleQuest = 
    {
        --[Comment]
        --左边的根对象
        go = _objSimpleQuest,
        --[Comment]
        --内容Item
        item_SQ = arr[0],

        --[Comment]
        --UITable
        items = cmps[0],
        --[Comment]
        --显示关闭按钮
        btnSQ = cmps[1],
        --[Comment]
        --显示栏
        sp_bg = cmps[2],

    }

    tmp = c.widgets
    _labVit = tmp[0]
    _labName = tmp[1]
    _labLV = tmp[2]
    _labPower = tmp[3]
    _labGold = tmp[4]
    _labSilver = tmp[5]
    _labDiamond = tmp[6]
    _labVipLV1 = tmp[7]
    _labVipLV2 = tmp[8]
    _texAvatar = tmp[9]
    _labMapLevel = tmp[10]
    _chatPop = tmp[11]

    tmp = c.btns
    _btns.ally = tmp[0]
    _btns.fb = tmp[1]
    _btns.quest = tmp[2]
    _btns.bag = tmp[3]
    _btns.hero = tmp[4]
    _btns.chat = tmp[5]
    _btns.homeLVGift = tmp[6]
    _btns.affair = tmp[7]
    _btns.suggest = tmp[8]
    _btns.mail = tmp[9]
    _btns.social = tmp[10]
    _btns.onlineRW = tmp[11]
    _btns.party = tmp[12]
    _btns.vipDayGift = tmp[13]
    _btns.affairClose = tmp[14]
    _btns.daily = tmp[15]
    _btns.sign = tmp[16]
    _btns.treasure = tmp[17]
    _btns.carnival = tmp[18]
    _btns.reward10 = tmp[19]
    _btns.assistant = tmp[20]
    _btns.firtsCharge = tmp[21]
    _btns.act = tmp[22]
    _btns.recharge = tmp[23]
    _btns.vipHL = tmp[24]
    _btns.divine = tmp[25]
    _btns.gve = tmp[26]
    _btns.tower = tmp[27]
    _btns.boss = tmp[28]
    _btns.seven = tmp[29]
    _btns.achv = tmp[30]
    _btns.question = tmp[31]
    _btns.nextLv = tmp[32]
    _btns.prevLv = tmp[33]
    _btns.simpleQuest = tmp[34]
    _btns.campaign = tmp[35]
    _btns.pvp = tmp[36]
    _btns.mainCity = tmp[37]
    _btns.avatar = tmp[38]
    _btns.addVit = tmp[39]
    _btns.power = tmp[40]
    _btns.addGold = tmp[41]
    _btns.addSilver = tmp[42]
    _btns.addDiamond = tmp[43]
    _btns.borrowHero = tmp[44]
    _btns.palaceInvite = tmp[45]
    _btns.vipLV = tmp[46]

    local _labBossTm = _btns.boss.gameObject:GetCmpInChilds(typeof(UILabel))
    
--    _update = UpdateBeat:CreateListener(Update)
--    UpdateBeat:AddListener(_update)
    UserDataChange:Add(UpdateExtInfo)
    UpdateInviteBtn:Add(UpdateInvBtn)
    UpdateBorrowBtn:Add(ShowBorrowBtn)
    OnNewChat:AddListener(_onNewChat)
    Refresh()
    MainUI.isOpen = true
    MainUI.labMapLevel = _labMapLevel
    MainUI.expeditionBox = _expeditionBox
    MainUI.ClickSimpleQuest()
end

function MainUI.ChangeButton(m)
    _curShowMap = m
    local show = {}
    local hide = {}
    local go = nil
    local pos = nil
    if m == MAP_TYPE.MAIN_CITY then
        show[1] = _btns.campaign.gameObject
        show[2] = _btns.pvp.gameObject
        show[3] = _objGrid
        show[4] = _objGrid1
        show[5] = _objGridLeft
        show[6] = _objSimpleQuest.go

        hide[1] = _btns.mainCity.gameObject
        hide[2] = _expeditionBox
        hide[3] = _labMapLevel.gameObject
    elseif m == MAP_TYPE.MAP_LEVEL then
        show[1] = _btns.mainCity.gameObject
        show[2] = _objSimpleQuest.go
        show[3] = _expeditionBox
        show[4] = _labMapLevel.gameObject

        hide[1] = _btns.campaign.gameObject
        hide[2] = _btns.pvp.gameObject
        hide[3] = _objGrid
        hide[4] = _objGrid1
        hide[5] = _objGridLeft
    elseif m == MAP_TYPE.MAP_PVP then

    end

    for i = 1, #show do
        go = show[i]
        if not go then break end
        if not go.activeSelf then
            pos = go.transform.localPosition
            if go == _objGridLeft then pos.x = -560
            else pos.x = 560 end
            go.transform.localPosition = pos
            go:SetActive(go == _btns.pvp.gameObject and user.IsCountryUL or true)
        end
        if go == _objGridLeft then
            EF.MoveTo(go, "x", 46, "islocal", true, "time", 0.3, "delay", 0.3, "easetype", iTween.EaseType.easeOutExpo)
        elseif go == _objSimpleQuest.go then
            go.transform.localPosition = Vector3.New(-140, 0)
        elseif go == _expeditionBox then
            go.transform.localPosition = Vector3.New(-60, -95)
        elseif go == _labMapLevel.gameObject then
            go.transform.localPosition = Vector3.New(0, -86)
        else
            EF.MoveTo(go, "x", ((go == _objGrid or go == _objGrid1) and 0 or 412), "islocal", true, "time", 0.3, "delay", 0.3, "easettype", iTween.EaseType.easeOutExpo)
        end
    end
    for i = 1, #hide do
        go = hide[i]
        if not go then break end
        if go.activeSelf then 
            if go == _objGridLeft then
                EF.MoveTo(go, "x", -560, "islocal", true, "time", 0.3, "easetype", iTween.EaseType.easeOutExpo, "oncompletetarget", _body.gameObject, "oncomplete", "OnITweenOver", "oncompleteparams", go)
            elseif go == _objSimpleQuest.go then
                go.transform.localPosition = Vector3.New(290, 0);
            elseif go == _expeditionBox then
                go.transform.localPosition = Vector3.New(-60, -95)
            elseif go == _labMapLevel.gameObject then
                go.transform.localPosition = Vector3.New(0, -86)
            else
                EF.MoveTo(go, "x", 560, "islocal", true, "time", 0.3, "easetype", iTween.EaseType.easeOutExpo, "oncompletetarget", _body.gameObject, "oncomplete", "OnITweenOver", "oncompleteparams", go) 
            end
            go:SetActive(false)
        end
    end
    local isShow = m == MAP_TYPE.MAP_LEVEL
    _btns.prevLv.gameObject:SetActive(isShow)
    _btns.nextLv.gameObject:SetActive(isShow)
end

function MainUI.ChecGiftBtn(res)

end

-- 检查解锁按钮
function MainUI.CheckUnlock(isGetCity)
    OnCL = coroutine.create(OnCheckLock)
    coroutine.resume(OnCL, isGetCity)
end

--[Comment]
-- 检查UI
function MainUI.CheckUI()
--    if _curShowMap and _curShowMap == MainMap then
--        _btns.rw10:SetActive(CONFIG.apple_permit)
--        _btns.hf:SetActive(CONFIG.apple_permit and user.hfActQty > 0)
--    else
--         _btns.rw10:SetActive(false)
--        _btns.hf:SetActive(false)
--    end
end

function MainUI.OnUnLoad()
    _body = nil
    _objGrid = nil
    _objGrid1 = nil
    _objGridBottom = nil
    _objSimpleQuest = nil
    _objVit = nil
    _labName = nil
    _labDiamond = nil
    _labLV = nil
    _labPower = nil
    _labGold = nil
    _labVipLV1 = nil
    _labVipLV2 = nil
    _labSilver = nil
    _labVit = nil
    _texAvatar = nil
    _curShowMap = nil

    UserDataChange:Remove(UpdateExtInfo)
    UpdateInviteBtn:Remove(UpdateInvBtn)
    UpdateBorrowBtn:Remove(ShowBorrowBtn)
    OnNewChat:Remove(_onNewChat)

    MainUI.isOpen = false
    isOpenSQ = false
end

function MainUI.ChangeMap(m)
    if isnull(_body) then return end

    _curShowMap = m
    local show, hide = nil, nil

    if m == MainMap then
        MainUI.ChangeButton(MAP_TYPE.MAIN_CITY)
    elseif m == LevelMap then
        MainUI.ChangeButton(MAP_TYPE.MAP_LEVEL)
    elseif m == MapNat then
        EF.FadeOut(_body, 0.3)
        return
    else
        --MainMap 或 默认
        Win.Open("MainMap")
        return
    end

    MainUI.CheckUI()
    EF.FadeIn(_body, 0.3)
end

local function OnCheckLock(isGetCity)
    local wait = true
    local t = Time.realtimeSinceStartup
    if isGetCity then
        --日常解锁 关卡12
        if CheckSN(user.battleRet.sn) == DB.unlock.daily and user.gmMaxCity == DB.unlock.daily then
            _btns.daily.gameObject:SetActive(false)
            wait, t = true, Time.realtimeSinceStartup
            UnlockEffect.Begin(_btns.daily.gameObject, "日常功能已开启", "完成日常任务，获得相应奖励", function () wait = false end )
            while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
            _btns.daily:GetCmp(typeof(UISprite)).alpha = 0
            _btns.daily.gameObject:SetActive(true)
            _objGrid:Reposition()
            coroutine.wait(0.82)
            _btns.daily:GetCmp(typeof(UISprite)).alpha = 1
        end

        --副本解锁 关卡14
        if CheckSN(user.battleRet.sn) == DB.unlock.gmFB and user.gmMaxCity == DB.unlock.gmFB then
            _btns.fb.gameObject:SetActive(false)
            wait, t = true, Time.realtimeSinceStartup
            UnlockEffect.Begin(_btns.fb.gameObject, "副本已开启", "挑战高难度剧本，获得稀有物品", function () wait = false end )
            while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
            _btns.fb:GetCmp(typeof(UISprite)).alpha = 0
            _btns.fb.gameObject:SetActive(true)
            _objGridBottom:Reposition()
            coroutine.wait(0.82)
            _btns.fb:GetCmp(typeof(UISprite)).alpha = 1
        end

        return
    end

    local utex
    local ul
    --武斗场解锁 主城15级
    if user.hlv == DB.unlock.rank then UnlockEffect.BeginBuilding(MainMap.btns.rank.gameObject, "武斗场已开启", "挑战其他玩家，获得排名奖励") end
    --七日目标解锁 主城16级
    if user.hlv == db.unlock.target7 and user.seven ~= nil and user.seven ~= "" then
        _btns.seven.gameObject:SetActive(false)
        wait, t = true, Time.realtimeSinceStartup
        UnlockEffect.Begin(_btns.seven.gameObject, "七日目标已开启", "完成七日任务，获得相应奖励", function () wait = false end )
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.seven:GetCmp(typeof(UISprite)).alpha = 0
        _btns.seven.gameObject:SetActive(true)
        _objGrid1:Reposition()
        coroutine.wait(0.82)
        _btns.seven:GetCmp(typeof(UISprite)).alpha = 1
    end
    --珍品阁和签到解锁 主城18级
    if user.hlv == DB.unlock.rareShop then
        local ul = UnlockEffect.BeginBuilding(MainMap.btns.rareShop.gameObject, "珍品阁已解锁", "稀世珍宝，重现于世")
        ul:SetOnFinished(function() 
            _btns.sign.gameObject:SetActive(false)
            wait, t = true, Time.realtimeSinceStartup
            UnlockEffect.Begin(_btns.sign.gameObject, "签到已开启", "每日签到，获得相应奖励", function () wait = false end )
            while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
            _btns.sign:GetCmp(typeof(UISprite)).alpha = 0
            _btns.sign.gameObject:SetActive(true)
            _objGrid1:Reposition()
            coroutine.wait(0.82)
            _btns.sign:GetCmp(typeof(UISprite)).alpha = 1
        end)
    end
    --战役解锁 主城19级
    if user.hlv == DB.unlock.gmWar then UnlockEffect.BeginBuilding(MainMap.btns.rank.gameObject,"战役已解锁", "回顾历史，征战沙场") end
    --国战解锁 主城20级
    if user.hlv == DB.unlock.country then
        _btns.pvp.gameObject:SetActive(false)
        wait, t = true, Time.realtimeSinceStartup
        UnlockEffect.Begin(_btns.pvp.gameObject, "国战已开启", "一统天下", function () wait = false end )
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.pvp:GetCmp(typeof(UISprite)).alpha = 0
        _btns.pvp.gameObject:SetActive(true)
        coroutine.wait(0.82)
       _btns.pvp:GetCmp(typeof(UISprite)).alpha = 1
    end
    --嘉年华解锁 主城22级
    if user.hlv == DB.unlock.affair then
        _btns.carnival.gameObject:SetActive(false)
        wait, t = true, Time.realtimeSinceStartup
        UnlockEffect.Begin(_btns.carnival.gameObject, "嘉年华已开启", "玩转嘉年华!", function () wait = false end )
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.carnival:GetCmp(typeof(UISprite)).alpha = 0
        _btns.carnival.gameObject:SetActive(true)
        _objGrid:Reposition()
        coroutine.wait(0.82)
        _btns.carnival:GetCmp(typeof(UISprite)).alpha = 1
    end
    --经验塔解锁 主城25级
    if user.hlv == DB.unlock.heroExp then UnlockEffect.BeginBuilding(MainMap.btns.expTower.gameObject,"经验塔已解锁", "训练武将,增强战力!") end
    --寻宝解锁 主城27级
    if user.hlv == DB.unlock.reward10 then
        _btns.reward10.gameObject:SetActive(false)
        wait, t = true, Time.realtimeSinceStartup
        UnlockEffect.Begin(_btns.reward10.gameObject, "寻宝已开启", "抽奖得奖励!", function () wait = false end )
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.reward10:GetCmp(typeof(UISprite)).alpha = 0
        _btns.reward10.gameObject:SetActive(true)
        _objGrid:Reposition()
        coroutine.wait(0.82)
        _btns.reward10:GetCmp(typeof(UISprite)).alpha = 1        
    end
    --BOSS战解锁 主城28级
    if user.hlv == DB.unlock.boss then
        _btns.boss.gameObject:SetActive(false)
        wait, t = true, Time.realtimeSinceStartup
        UnlockEffect.Begin(_btns.boss.gameObject, "BOSS战已开启", "妖师来袭，乱世之争", function () wait = false end )
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.boss:GetCmp(typeof(UISprite)).alpha = 0
        _btns.boss.gameObject:SetActive(true)
        _objGrid1:Reposition()
        coroutine.wait(0.82)
        _btns.boss:GetCmp(typeof(UISprite)).alpha = 1        
    end
    --争霸解锁 主城30级
    if user.hlv == DB.unlock.pvp then
        _btns.pvp.gameObject:SetActive(false)
        wait, t = true, Time.realtimeSinceStartup
        UnlockEffect.Begin(_btns.pvp.gameObject, "争霸已开启", "与其他玩家一起争夺天下", function () wait = false end )
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.pvp:GetCmp(typeof(UISprite)).alpha = 0
        _btns.pvp.gameObject:SetActive(true)
        coroutine.wait(0.82)
        _btns.pvp:GetCmp(typeof(UISprite)).alpha = 1   
        
        for i = 1, 6 do AM.LoadAssetAsync(ResName.PvpMap(i), true) end
    end
    -- 联盟解锁 主城30级
    if user.hlv == DB.unlock.ally then
        _btns.ally.gameObject:SetActive(false);
        wait, t = true, Time.realtimeSinceStartup;
        UnlockEffect.Begin(_btns.ally.gameObject, "联盟已开启", "合纵连横，争霸天下", function ()  wait = false end)
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.ally:GetCmp(typeof(UISprite)).alpha = 0
        _btns.ally.gameObject:SetActive(true)
        _objGridBottom:Reposition()
        coroutine.wait(0.82)
        _btns.ally:GetCmp(typeof(UISprite)).alpha = 1
        if CheckSN(user.ally.gsn) > 0 then return end
    end
    -- 名人堂解锁 主城34级
    if user.hlv == DB.unlock.fame then UnlockEffect.BeginBuilding(MainMap.btns.fame.gameObject, "名人堂已开启", "丰功伟绩，荣耀之争") end
    --决斗解锁 主城35级
    if user.hlv == DB.unlock.tower then
        _btns.tower.gameObject:SetActive(false);
        wait, t = true, Time.realtimeSinceStartup;
        UnlockEffect.Begin(_btns.tower.gameObject, "决斗已开启", "勇武之道，势不可挡", function ()  wait = false end)
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.tower:GetCmp(typeof(UISprite)).alpha = 0
        _btns.tower.gameObject:SetActive(true)
        _objGrid1:Reposition()
        coroutine.wait(0.82)
        _btns.tower:GetCmp(typeof(UISprite)).alpha = 1
    end
    --地宫解锁 主城40级
    if user.hlv == DB.unlock.explorer then
        _btns.gve.gameObject:SetActive(false);
        wait, t = true, Time.realtimeSinceStartup;
        UnlockEffect.Begin(_btns.gve.gameObject, "地宫探秘已开启", "探索秘境，发掘宝藏", function ()  wait = false end)
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.gve:GetCmp(typeof(UISprite)).alpha = 0
        _btns.gve.gameObject:SetActive(true)
        _objGrid1:Reposition()
        coroutine.wait(0.82)
        _btns.gve:GetCmp(typeof(UISprite)).alpha = 1
    end
    --占卜解锁 主城43级
    if user.hlv == DB.unlock.divine then
        _btns.divine.gameObject:SetActive(false);
        wait, t = true, Time.realtimeSinceStartup;
        UnlockEffect.Begin(_btns.divine.gameObject, "占卜已开启", "推演天机，占卜秘宝", function ()  wait = false end)
        while wait and Time.realtimeSinceStartup - t < 10 do coroutine.step() end
        _btns.divine:GetCmp(typeof(UISprite)).alpha = 0
        _btns.divine.gameObject:SetActive(true)
        _objGrid1:Reposition()
        coroutine.wait(0.82)
        _btns.divine:GetCmp(typeof(UISprite)).alpha = 1
    end
    --乱世争雄解锁 主城50级
    if user.hlv == DB.unlock.gmClan then UnlockEffect.BeginBuilding(MainMap.btns.rank.gameObject, "乱世争雄已开启", "群雄崛起,乱世争雄") end
end

-----------------快捷任务栏-----------------
local _SQlist = nil
--主线任务sn和完成度
local _SQmain = nil 
--储存items
local _SQitems = nil

local function SQDispose()
    if _SQitems then
        for k,v in pairs(_SQitems) do
            Destroy(v)
        end
    end
    _SQitems = nil
end

local function SQBuildItems()
    if _SQitems == nil then
        _SQitems = {}
        for i = 1, #_SQmain, 2  do
            local d = DB.GetQuest(_SQmain[i])
            local it = _objSimpleQuest.items:AddChild(_objSimpleQuest.item_SQ, string.format("sq_%02d", (i + 1) * 0.5))
            local tl = it:ChildWidget("title")
            local des = it:ChildWidget("lbl_describe")
            local ef = it.transform:FindChild("ef_frame")
            local clk = it:GetCmp(typeof(LuaButton))
            --已完成
            if _SQmain[i + 1] >= d.trg then
                ef:SetActive(true)
                --绿色下划线
                tl.text = "[u][01da00]【主线】".. d.nm.. "（领取奖励）".. "[-][/u]"
                clk:SetClick("ClickComplete", {d , i})
            else--未完成
                ef:SetActive(false)
                tl.text = "[eeb14b]【主线】"..d.nm.."[-]"
                local a = string.gsub(d.i, d.tk, "{sq,"..d.tk.."}")
                des.text = MsgData(a).msg
                clk:SetClick("ClickGuide", d.guide)
            end
            _SQitems[i] = it
            it:SetActive(true)
        end
    else
        
    end
    _objSimpleQuest.items.repositionNow = true
end
--刷新
local function SQRefresh()
    SQDispose()
    SVR.GetQuestList(function(res)
        if res.success then
            local r = SVR.datCache
            _SQlist = r.lst
            _SQmain = {}
            for i = 1 ,#_SQlist ,2 do
                local d = DB.GetQuest(_SQlist[i])
                if d.kind == 1 then
                    table.insert(_SQmain, _SQlist[i])
                    table.insert(_SQmain, _SQlist[i + 1])
                end
            end
            print("isOpenSQ   ",isOpenSQ)
            if #_SQmain > 0 and isOpenSQ then
                SQBuildItems()
            end
        end
    end)
end
MainUI.SQRefresh = SQRefresh

--[Comment]
--导航
function MainUI.ClickGuide(g)
    Guide.PaseGuide(g)
end

--[Comment]
--完成
function MainUI.ClickComplete(p)
    print("ClickCompleteClickComplete   ",kjson.print(p))
    local d = p[1]
    local i = p[2]
    local it = _SQitems[i]

    SVR.CompleteQuest(d.sn,function(res)
        if res.success then
            table.remove(_SQmain, i)
            table.remove(_SQmain, i + 1)
            Destroy(it)
            _objSimpleQuest.items.repositionNow = true
        end
    end)
end



--------------------------------------------


-------- 按钮事件 --------
--联盟
function MainUI.ClickAlly()
    if CheckSN(user.nsn) then
        if CheckSN(user.ally.gsn) ~= nil then Win.Open("WinAlly")
        else Win.Open("WinAllyList") end
    else
        MsgBox.Show("查看联盟请先加入国家！", "取消,加入", function(bid)
            if bid == 1 then
                ToolTip.ShowPopTip("选择国家界面未完成")
                Win.Open("PopSelectCountry")
            end
        end)
    end
end
--副本
function MainUI.ClickFB() Win.Open("WinFB") end
--任务
function MainUI.ClickQuest() Win.Open("WinQuest") end
--背包
function MainUI.ClickStorage() Win.Open("WinGoods", 6) end
--武将
function MainUI.ClickHero() Win.Open("WinHero") end
--聊天
function MainUI.ClickChat() Win.Open("PopChat") if _cahtPopIvk and _cahtPopIvk:isRunning() then _cahtPopIvk:Reset(nil, 0) end end
--主城等级礼包
function MainUI.ClickGift(res) Win.Open("PopLevelGift",0) end
--福利
function MainUI.ClickAffair() end
--关闭福利的子界面
function MainUI.ClickCloseAffair() end
--在线奖励
function MainUI.ClickOnline() Win.Open("PopOnline") end
--VIP每日奖励
function MainUI.ClickVipDayRW() Win.Open("PopLuaVipGift") end
--晏会
function MainUI.ClickParty() Win.Open("PopLuaParty") end
--建议
function MainUI.ClickSuggest() Win.Open("PopSuggest") end
--邮件
function MainUI.ClickMail() Win.Open("WinMail") end
--社交
function MainUI.ClickSocial() Win.Open("PopFriend") end
--日常
function MainUI.ClickDaily() Win.Open("WinDaily") end
--签到
function MainUI.ClickSign() Win.Open("WinSign") end
--天降秘宝
function MainUI.ClickTreasure() Win.Open("PopLuaTreasure") end
--嘉年华
function MainUI.ClickCarnival() Win.Open("WinLuaAffair") end
--寻宝
function MainUI.ClickReward10() Win.Open("PopReward10") end
--小助手
function MainUI.ClickAssistant() Win.Open("PopAssistant") end
--首充
function MainUI.ClickFirstCharge() end
--活动
function MainUI.ClickAct() end
--充值
function MainUI.ClickRecharge() Win.Open("PopRecharge") end
--VIP豪礼
function MainUI.ClickVipHL(res) Win.Open("PopLevelGift",{res,1}) end
--占卜
function MainUI.ClickDivine() Win.Open("WinDivine") end
--地宫 
function MainUI.ClickGve() 
    if CheckSN(user.ally.gsn) then
        SVR.GveStart(function(result)
            if result.success then
                local res = SVR.datCache
                if res == "0" then
                    SVR.GveMatch(0, 0, function(task)
                        if task.success then
                            local data = SVR.datCache
                            Win.Open("WinTeam", data)
                        end
                    end)
                elseif res == "2" then
                    ToolTip.ShowPopTip("进入地宫")
                    Win.Open("WinExplorer")
                end
            end
        end)
    else
        ToolTip.ShowPopTip("需要加入或创建联盟")
    end
end
--决斗
function MainUI.ClickTower() Win.Open("WinTower") end
--BOSS战
function MainUI.ClickBoss() end
--七日目标
function MainUI.ClickSeven() Win.Open("PopLuaSeven") end
--成就
function MainUI.ClickAchv() end
--答题
function MainUI.ClickAnwser() end
--快捷任务栏
function MainUI.ClickSimpleQuest() 
    --打开
    if not isOpenSQ then
        _objSimpleQuest.sp_bg:PlayForward()
        _objSimpleQuest.btnSQ.spriteName = "simpleQuest_btnHide" 
        print("12312321321321   ",isOpenSQ)
        isOpenSQ = true
        MainUI.SQRefresh()
    else--关闭
        _objSimpleQuest.sp_bg:PlayReverse()
        _objSimpleQuest.btnSQ.spriteName = "simpleQuest_btnShow" 
        SQDispose()
        isOpenSQ = false
    end
end
--征战
function MainUI.ClickCampaign() Win.Open("LevelMap") end
--世界
function MainUI.ClickPVP() Win.Open("PopSelectPvp") end
--主城
function MainUI.ClickMainCity() Win.ExitAllWin() Win.Open("MainMap") end
--BOSS
function MainUI.ClickBoss() Win.Open("WinBoss") end
--头像
function MainUI.ClickAvatar() Win.Open("PopShowAchi") end
--体力
function MainUI.ClickAddVit() Win.Open("PopVIT") end
--实力榜
function MainUI.ClickPower() 
    user.TutorialSN = 1
    user.TutorialStep = 2 
--    Tutorial.PlayTutorial(true,_SQitems[1].transform) 
    Win.Open("Tutorial",{ true, _SQitems[1].transform})

--    PlotDialogue.TutorialPlot("关羽,15 = 尔等逆贼，如土鸡瓦狗插标卖首之辈，看关某取汝首级！|张梁,108 = 你这红脸莽汉，忒的自大，看招！",nil ,true)
end
--点石成金
function MainUI.ClickAddSilver() Win.Open("PopG2C") end
--借将申请
function MainUI.ClickBorrowHeroApply() Win.Open("PopBorrowHeroApply") end
--地宫邀请
function MainUI.ClickPalaceApply() Win.Open("PopGveInvite") end
--VIP等级礼包
function MainUI.ClickVIP() Win.Open("PopRecharge", 1) end

-------- 征战界面按钮事件 --------
function MainUI.ClickBox(lb) LevelMap.ClickBox(lb) end
