MainMap = { }

local rd = Mathf.Random

local _body = nil
MainMap.body = _body

local _btns = { }

MainMap.btns = {
    --酒馆按钮
    tavern = _btns[0],
    --铁匠铺按钮
    smithy = _btns[1],
    --主城按钮
    home = _btns[2],
    --武斗场按钮
    rank = _btns[3],
    --名人堂按钮
    fame = _btns[4],
    --珍品阁按钮
    rareShop = _btns[5],
    --经验塔按钮
    expTower = _btns[6]
}

local function UpDateUserInfo()

end

local function Update()
    
end

local function CheckLock()
    local home = _btns[2].gameObject:GetCmp(typeof(UISprite))
    local tavern = _btns[0].gameObject:GetCmp(typeof(UISprite))
    local expTower = _btns[6].gameObject:GetCmp(typeof(UISprite))
    local rareShop = _btns[5].gameObject:GetCmp(typeof(UISprite))
    local rank = _btns[3].gameObject:GetCmp(typeof(UISprite))
    local fame = _btns[4].gameObject:GetCmp(typeof(UISprite))
    local smithy = _btns[1].gameObject:GetCmp(typeof(UISprite))

    local t = typeof(UISprite)
    if user.hlv > 4 then home:ChildWidget("lock", t):SetActive(false) end
    if user.hlv > 5 then smithy:ChildWidget("lock", t):SetActive(false) end
    if user.hlv > 6 then tavern:ChildWidget("lock", t):SetActive(false) end
    if user.IsRankUL then rank:ChildWidget("lock", t):SetActive(false) end
    if user.IsRareShopUL then rareShop:ChildWidget("lock", t):SetActive(false) end
    if user.IsFameUL then fame:ChildWidget("lock", t):SetActive(false) end
    if user.IsTrainUL then expTower:ChildWidget("lock", t):SetActive(false) end
end

local function CheckTutorial()
    
end
MainMap.CheckTutorial = CheckTutorial

local function OnShow()
    CheckLock()
    CheckTutorial()
end 

function MainMap.OnLoad(c)
    _body = c

    c:BindFunction("OnInit")
    c:BindFunction("OnEnter")
    c:BindFunction("OnExit")
    c:BindFunction("OnDispose")
    c:BindFunction("OnUnLoad")

    --点击事件
    c:BindFunction("ClickCity", "ClickStorage", "ClickFame", "ClickRareShop", "ClickRank", "ClickTavern", "ClickExpTower")

    _btns = c.btns
end

local _showTm = Timer.New(OnShow, 0.6, 0, true)
function MainMap.OnInit()
    if not _showTm.running then _showTm:Start() end
    
    if MainUI then MainUI.ChangeButton(MAP_TYPE.MAIN_CITY)
    else _body.transform.parent.gameObject:AddChild(AM.LoadPrefab("MainUI"), "MainUI") MainUI.ChangeButton(MAP_TYPE.MAIN_CITY) end
    
    UpDateUserInfo()
end

function MainMap.OnEnter()
    UserDataChange:Add(UpDateUserInfo)
    BGM.Play("bg_0")

    Win.ExitAllWin("MainMap")
    Win.Open("MapCloud")
    if MapCloud ~= nil then MapCloud.StartCutMap(true, true) end
    MainUI.ChangeMap(MainMap)

    _update = UpdateBeat:CreateListener(Update)
    UpdateBeat:AddListener(_update)
end

function MainMap.OnExit()
    UserDataChange:Remove(UpDateUserInfo)
    UpdateBeat:RemoveListener(_update)
end

function MainMap.OnDispose()
end

function MainMap.OnUnLoad()
    _btns = nil
end



-------- 按钮事件
-- 主城
function MainMap.ClickCity() Win.Open("PopHome") end
-- 铁匠铺
function MainMap.ClickStorage() Win.Open("WinGoods") end
-- 经验塔
function MainMap.ClickExpTower() Win.Open("WinHeroExp") end
-- 酒馆
function MainMap.ClickTavern() Win.Open("PopLuaSeven") end
-- 武场
function MainMap.ClickRank() Win.Open("WinRank") end
-- 珍品馆
function MainMap.ClickRareShop() Win.Open("WinRareShop") end
-- 名人堂
function MainMap.ClickFame() Win.Open("WinFame") end



