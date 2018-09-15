local isnull = isnull
local Time = Time
local ipairs = ipairs
local pairs = pairs
local table = table

local _w = { }

local _body = nil
local _ref = nil
local _dt = 0

local _items = {
    [0] =
    {
        cor = ColorStyle.Good,
        sort = "000",
        tip = "获取主城经验",
        status = function()
            return user.hlv < DB.maxHlv
        end,
        guide = function()
            Win.Open("PopAssistantTips", 1)
        end
    },
    [1] =
    {
        cor = ColorStyle.Good,
        sort = "001",
        tip = "获取装备",
        status = function()
            return true
        end,
        guide = function()
            Win.Open("PopAssistantTips", 2)
        end
    },
    [2] =
    {
        cor = ColorStyle.Good,
        sort = "002",
        tip = "获取银币",
        status = function()
            return true
        end,
        guide = function()
            Win.Open("PopAssistantTips", 3)
        end
    },
    [3] =
    {
        cor = ColorStyle.Good,
        sort = "003",
        tip = "进攻下一座城池！",
        btxt = "攻  占",
        status = function()
            return user.gmMaxCity < DB.maxCityQty
        end,
        guide = function()
            local win = Win.Open("LevelMap")
            if win then
                win.AttackNextCity()
            end
            _body:Exit()
        end
    },
    [4] =
    {
        cor = ColorStyle.Bad,
        sort = "004",
        tip = "您的主城被占领啦,\n赶快夺回来吧!",
        status = function()
            return user.IsPvpUL and user.occ ~= 0 and user.occ ~= user.psn
        end,
        guide = function()
            ToolTip.ShowPopTip("主城被攻占 条件:主城被占领，导向:PVP界面/定位主城")
        end
    },
    [5] =
    {
        cor = ColorStyle.Gold,
        sort = "005",
        tip = "可以免费寻宝啦！",
        btxt = "寻  宝",
        status = function()
            return user.rw1Tm.time <= 0 or user.rw10Tm.time <= 0
        end,
        guide = function()
            Win.Open("PopReward10")
        end
    },
    [6] =
    {
        cor = ColorStyle.Gold,
        sort = "006",
        tip = "您有VIP礼包可以领取",
        status = function()
            return user.vipGiftLv > 0
        end,
        guide = function()
            Win.Open("PopRecharge", 1)
        end
    },
    [7] =
    {
        cor = ColorStyle.Blue,
        sort = "007",
        tip = "您有VIP礼包可以购买",
        status = function()
            for i = 1, user.vip do
                if not user.GetVipRec(i) then
                    return true
                end
            end
            return false
        end,
        guide = function()
            Win.Open("WinShop", 5)
        end
    },
    [8] =
    {
        cor = ColorStyle.Gold,
        sort = "008",
        tip = "您今天还没有签到呢！",
        status = function()
            return user.IsSignUL and not user.sign
        end,
        guide = function()
            Win.Open("WinSign")
        end
    },
    [9] =
    {
        cor = ColorStyle.Gold,
        sort = "009",
        tip = "可以免费占卜啦!",
        status = function()
            return user.IsDivineUL and user.dvnQty
        end,
        guide = function()
            Win.Open("WinDivine")
        end
    },
    [10] =
    {
        cor = ColorStyle.Gold,
        sort = "010",
        tip = "可以免费秘境巡游啦!",
        status = function()
            return false
        end,
        guide = function()
            Win.Open("WinFam")
        end
    },
    [11] =
    {
        cor = ColorStyle.Good,
        sort = "011",
        tipf = function()
            return string.format(L("今日还可点石成金%d次"), user.g2cQty - user.g2cUsed)
        end,
        status = function()
            return user.g2cQty - user.g2cUsed > 0
        end,
        guide = function()
            Win.Open("PopG2C")
        end
    },
    [12] =
    {
        cor = ColorStyle.Gold,
        sort = "012",
        tipf = function()
            return string.format(L("有%d个任务可以完成"), user.questQty)
        end,
        status = function()
            return user.questQty > 0
        end,
        guide = function()
            Win.Open("WinQuest")
        end
    },
    [13] =
    {
        cor = ColorStyle.Good,
        sort = "013",
        tip = "可挑战副本",
        status = function()
            return user.IsTipHistory and user.HasFbPveCity
        end,
        guide = function()
            Win.Open("WinFB")
        end
    },
    [14] =
    {
        cor = ColorStyle.Gold,
        sort = "014",
        tip = "BOSS战已开启",
        status = function()
            return user.bossTm.tm <= 0 and user.IsBossUL
        end,
        guide = function()
            Win.Open("WinBoss")
        end
    },
    [15] =
    {
        cor = ColorStyle.Good,
        sort = "015",
        tip = "决斗已开启",
        status = function()
            return user.IsTowerUL and(user.towerInfo.resetQty or user.towerInfo.rank < 31)
        end,
        guide = function()
            Win.Open("WinTower")
        end
    },
    [16] =
    {
        cor = ColorStyle.Purple,
        sort = "016",
        tipf = function()
            return string.format(L("战役还可挑战%d次"), DB_Props.TIAO_ZHAN_LING)
        end,
        status = function()
            return user.IsWarUL and user.GetPropsQty(DB_Props.TIAO_ZHAN_LING) > 0 and user.IsWarBegin
        end,
        guide = function()
            Win.Open("WinWar")
        end
    },
    [17] =
    {
        cor = ColorStyle.Blue,
        sort = "017",
        tipf = function()
            return string.format(L("%d入盟申请"), user.ally.pendMember)
        end,
        status = function()
            return user.ally.myPerm == "2" and user.ally.pendMember and user.ally.pendMember > 0
        end,
        guide = function()
            Win.Open("PopAllyMember")
        end
    },
    [18] =
    {
        cor = ColorStyle.Gold,
        sort = "018",
        tip = "有可以开启的宝箱哦",
        status = function()
            return DB.AllProps( function(p)
                return p.kind == 3 and user.GetPropsQty(p.sn) > 0
            end )
        end,
        guide = function()
            Win.Open("WinGoods", -6)
        end
    },
    [19] =
    {
        cor = ColorStyle.Gold,
        sort = "019",
        tip = "将领进修完成",
        status = function()
            return user.HasTrainHero and user.TrainTime <= 0
        end,
        guide = function()
            Win.Open("WinHeroExp")
        end
    },
    [20] =
    {
        cor = ColorStyle.Blue,
        sort = "020",
        tip = "经验塔可进修",
        status = function()
            return user.IsGveUL and not user.HasTrainHero
        end,
        guide = function()
            Win.Open("WinHeroExp")
        end
    },
    [21] =
    {
        cor = ColorStyle.Blue,
        sort = "021",
        tip = "有精品经验药可培养武将",
        status = function()
            return user.GetPropsQty(DB_Props.DA_JING_YAN_DAN) > 0 and user.HasCanLvUpHero
        end,
        guide = function()
            local heros = user.GetHeros( function(h)
                return h.lv < user.hlv
            end )
            table.sort(heros, PY_Hero.Compare)
            Win.Open("PopHeroDetail", { heros, 0 })
        end
    },
    [22] =
    {
        cor = ColorStyle.Blue,
        sort = "022",
        tip = "有武将可以学习新兵种",
        status = function()
            return user.IsHeroUL and user.HasCanLearnArmHero
        end,
        guide = function()
            local heros = user.GetHeros( function(h)
                return h.HasCanLearnArmHero
            end )
            table.sort(heros, PY_Hero.Compare)
            Win.Open("PopHeroDetail", { heros, 2 })
        end
    },
    [23] =
    {
        cor = ColorStyle.Blue,
        sort = "023",
        tip = "有武将可以学习新阵形",
        status = function()
            return user.IsHeroUL and user.HasCanLearnLnpHero
        end,
        guide = function()
            local heros = user.GetHeros( function(h)
                return h.CanLearnLnp
            end )
            table.sort(heros, PY_Hero.Compare)
            Win.Open("PopHeroDetail", { heros, 3 })
        end
    },
    [24] =
    {
        cor = ColorStyle.Blue,
        sort = "024",
        tip = "可铭刻阵形",
        status = function()
            return user.GetPropsQty(DB_Props.ZHEN_WEN_FU) > 0 and user.HasCanImpLnpHero
        end,
        guide = function()
            Win.Open("PopHeroDetail", {
                user.GetHeros( function(h)
                    return h.CanImpLnp
                end ),3
            } )
        end
    },
    [25] =
    {
        cor = ColorStyle.Gold,
        sort = "025",
        tip = "有武将可觉醒",
        status = function()
            return user.HasCanEvolutionHero
        end,
        guide = function()
            Win.Open("PopHeroDetail", user.GetHeros( function(h)
                return h.CanEvo
            end ))
        end
    },
    [26] =
    {
        cor = ColorStyle.Gold,
        sort = "026",
        tip = "有武将可以升级将星",
        status = function()
            return user.HasCanUpStarHero
        end,
        guide = function()
            Win.Open("PopHeroStar", user.GetHeros( function(h)
                return h.CanUpStar
            end ))
        end
    },
    [27] =
    {
        cor = ColorStyle.Blue,
        sort = "027",
        tip = "有特级经验药可培养武将",
        status = function()
            return user.GetPropsQty(DB_Props.CHAO_JI_JING_YAN_DAN) > 0 and user.HasCanLvUpHero
        end,
        guide = function()
            local heros = user.GetHeros( function(h)
                return h.lv < user.hlv
            end )
            table.sort(heros, PY_Hero.Compare)
            Win.Open("PopHeroDetail", { heros, 0 })
        end
    },
    [28] =
    {
        cor = ColorStyle.Gold,
        sort = "028",
        tip = "可以晋升爵位",
        status = function()
            return user.ttl < DB.maxTtl and user.merit >= DB.GetTtl(user.ttl + 1).merit
        end,
        guide = function()
            Win.Open("PopPeerage")
        end
    },
    [29] =
    {
        cor = ColorStyle.Gold,
        sort = "029",
        tip = "有武将可晋升官阶",
        status = function()
            --有可以升官的武将
            return user.HasCanPromotionHero
        end,
        guide = function()
            Win.Open("PopHeroDetail", { user.GetHeros( function(h)
                return h.CanPromotion
            end ) , 0})
        end
    },
}

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
end

local function RefreshItems()
    if isnull(_body) then
        return
    end

    local it = nil
    local changed = false

    for i = 0, #_items, 1 do
        it = _items[i]
        if it.status() then
            if isnull(it.go) then
                it.go = _ref.grid1:AddChild(_ref.item_ass, "item_" ..(it.sort or ""))
                it.go:SetActive(true)
                it.txt = it.go:ChildWidget("content")
                it.txt.text = it.cor(it.tipf and it.tipf() or L(it.tip)) .. "[-]"
                it.btn = it.go:ChildBtn("btn_guide")
                it.btn.luaContainer = _body
                it.btn.param = i
                it.btn.text = it.btxt and L(it.btxt) or L("查  看")
                changed = true
            end
        elseif it.go then
            it.go.transform.parent = _body.transform
            Destroy(it.go)
            changed = true
            it.go = nil
            it.txt = nil
            it.btn = nil
        end
    end
    if changed then
        local qty = 0
        for _, it in pairs(_items) do
            if it.go then
                qty = qty + 1
            end
        end
        local grid = _ref.grid1:GetCmp(typeof(UIGrid))
        grid.animateSmoothly = _body.activeSelf
        grid.repositionNow = true
    end
end

function _w.OnInit()
    local comp = _body:GetCmp(typeof(TweenPosition))
    if FillScreen.getPlace() == FillPlace.Horizontal then
        local zoom = Screen.height / SCREEN.HEIGHT
        comp.from = Vector3(Screen.width / zoom / 2 + 400, 0, 0)
        comp.to = Vector3(Screen.width / zoom / 2 - 205 + 28, 0, 0)
    else
        comp.from = Vector3(900, 0, 0)
        comp.to = Vector3(458, 0, 0)
    end
    _ref.title.text = L("小助手")
    RefreshItems()
    --if (User.HighCity < Config.T_LEVEL) Tutorial.Mask();
end

local function Update()
    if _dt < Time.realtimeSinceStartup then
        _dt = Time.realtimeSinceStartup + 1
        RefreshItems()
    end
end
local _update = UpdateBeat:CreateListener(Update)
local _refreshitems = UserDataChange:CreateListener(RefreshItems)
function _w.OnEnter()
    _ref.scroll:ConstraintPivot(UIWidget.Pivot.Top, true)
    local tp = _body:GetCmp(typeof(TweenPosition))
    _body.transform.localPosition = tp.from
    UpdateBeat:AddListener(_update)
    UserDataChange:AddListener(_refreshitems)
    if tp then
        tp:PlayForward()
    end
    --if (User.TutorialSN == 1 && User.TutorialStep == 40)
    --     {
    --         if (items != null && items[0])
    --         {
    --             Tutorial.PlayTutorial(true, items[0].button.transform);
    --         }
    --         else
    --         {
    --             User.TutorialStep = 41;
    --             MapManager.Instance.MapLevel.AttackNextCity();
    --             Exit();
    --         }
    --     }
end
local function Active()
    return _body.transform.activeSelf
end
function _w.OnExit()
    UpdateBeat:RemoveListener(_update)
    UserDataChange:RemoveListener(_refreshitems)
    local tp = _body:GetCmp(typeof(TweenPosition))
    if Active() then
        if tp then
            tp:PlayReverse()
        end
    else
        if tp then
            EF.ResetToInit(tp)
        end
    end
end

function _w.ClickItemBtn(i)
    i = _items[i]
    if i then
        i.guide()
    end
end

--[Comment]
--是否提醒
function _w.AssistantActive()
    for i = 0, #_items, 1 do
        if i ~= 14 and _items[i].status() then
            return true
        end
    end
    return false
end

--[Comment]
--高亮的项
local _brtItem = {
    1,2,5,9,3,16,11,22,25,26,6,23,7
}

--[Comment]
--是否高亮
function _w.Brilliant()
    for _, i in ipairs(_brtItem) do
        if _items[i].status() then
            return true
        end
    end
    return false
end

---<summary>
---0=攻打下一座城池，1=主城被攻占，2=免费寻宝已经可用，3=领取VIP礼包，4=购买VIP礼包，5=可以签到，6=免费占卜，7=秘境巡游，8=点石成金
---9=有可完成的任务，10=副本，11=BOSS战已开启，12=过关斩将，13=战役，14=联盟，15=有可以使用的宝箱，16=武将修炼完成（修炼塔），17=武将可以修炼（修炼塔）
---18=大经验丹，19=有可以学习阵形的武将，20=有可以学习兵种的武将，21=铭刻阵形，22=武将觉醒，23=武将将星，24=超级经验丹，25=玩家可升爵位，26=武将可升官阶
---27=医馆的血库需要补充，28=兵营的兵力需要补充，29=有未读邮件，30=城池收获提醒
---</summary>
function _w.GetStatus(s)
    s = _items[s]
    return s and s.status() ~= false
end

function _w.OnDispose()
    for _, it in pairs(_items) do
        if it.go then
            Destroy(it.go)
            it.go = nil
            it.txt = nil
            it.btn = nil
        end
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
    end
end

---<summary>小助手</summary>
PopAssistant = _w