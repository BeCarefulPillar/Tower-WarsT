local notnull = notnull
local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil

local _rivals = nil
local _heros = nil

local _data = nil
local _rivalDatas = nil
local _count = nil
local _rankRewardTag = nil
local _dayRewardTag = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { n = L("竞技场"), r = DB_Rule.Rank })

    c:BindFunction(
    "OnInit",
    "ClickSetHero",
    "Refresh",
    "OnEnter",
    "OnExit",
    "ClickRank",
    "ClickRankReward",
    "ClickRenownReward",
    "ClickRenownShop",
    "ClickFight",
    "ClickBtnAdd",
    "OnDispose",
    "OnUnLoad"
    )

    _rivals = { }
    for i, v in ipairs(_ref.rivals) do
        _rivals[i] = {
            go = v,
            wgt = v.widget,
            btn = v:ChildBtn("bg_main"),
            name = v:ChildWidget("name"),
            level = v:ChildWidget("level"),
            ally_name = v:ChildWidget("ally_name"),
            rank = v:ChildWidget("rank"),
            sp = v:ChildWidget("sp"),
            avatar = v:ChildWidget("avatar"),
        }
        _rivals[i].btn.param = i
    end
    _ref.rivals = nil

    _heros = { }
    for i, v in ipairs(_ref.heros) do
        _heros[i] = {
            sp = v,
            trans = v.transform,
            name = v:ChildWidget("name"),
            utx = v:ChildWidget("hero"),
            lock = v:Child("sp_lock"),
        }
    end
    _ref.heros = nil
end

local function CheckTutorial()
    if user.TutorialSN == 2 then
        if user.TutorialStep == Tutorial.Step.TutStep04 then
            Tutorial.PlayTutorial(true, _rivals[2].btn.transform)
        end
    end
end

local function PriRefresh()
    SVR.GetPvpRankRival( function(t)
        if t.success then
            --stab.S_PlayerInfo
            _rivalDatas = SVR.datCache.lst
            if _rivalDatas then
                local len = #_rivalDatas
                local d = nil
                for i, v in ipairs(_rivals) do
                    if i <= len then
                        d = _rivalDatas[i]
                        v.go:SetActive(true)
                        v.name.text = d.nick
                        v.level.text = d.hlv
                        v.ally_name.text = d.allyName
                        v.rank.text = L("排名") .. "：" .. d.rank
                        v.sp.spriteName = "hero_clan_" .. d.countrySN
                        v.avatar:LoadTexAsync(ResName.PlayerRole(d.ava))
                        v.avatar.uvRect = Rect(0.23, 0.31, 0.4858, 0.5771)
                    else
                        v.go:SetActive(false)
                        v.avatar:UnLoadTex()
                    end
                end
                CheckTutorial()
            else
                for i, v in ipairs(_rivals) do
                    v.go:SetActive(false)
                    v.avatar:UnLoadTex()
                end
            end
        end
    end )
end

--[Comment]
--设置可挑战次数信息
function _w.SetSoloTimesInfo(theData)
    _data = theData
    _count = theData.prices and #theData.prices or 0
    if theData.info then
        _ref.infos[1].text = tostring(theData.info[1])
        if theData.info[2] > 0 then
            _ref.infos[2].text = L("剩余挑战数:") .. theData.info[2]
            _ref.infos[2].color = Color.white
            _ref.infos[2].applyGradient = false
            _ref.infos[2].cachedTransform:GetChild(0):SetActive(false)
        elseif theData.info[3] < user.vipData.pvpRankQty then
            _ref.infos[2].text = L("挑战需要:") .. theData.info[4] .. "  "
            _ref.infos[2].color = Color.white
            _ref.infos[2].applyGradient = true
            _ref.infos[2].cachedTransform:GetChild(0):SetActive(true)
        else
            local needVip = DB.GetVipLv( function(v)
                return theData.info[2] < v.pvpRankQty
            end )
            if needVip > DB.maxVip or needVip <= user.vip then
                _ref.infos[2].text = L("剩余挑战数:") .. theData.info[2] .. "/5"
                _ref.infos[2].color = Color.gray
                _ref.infos[2].applyGradient = false
                _ref.infos[2].cachedTransform:GetChild(0):SetActive(false)
            else
                _ref.infos[2].text = string.format(L("VIP%d可继续挑战"), needVip)
                _ref.infos[2].color = Color.red
                _ref.infos[2].applyGradient = false
                _ref.infos[2].cachedTransform:GetChild(0):SetActive(false)
            end
        end
    else
        _ref.infos[1].text = ""
        _ref.infos[2].text = ""
        _ref.infos[2].cachedTransform:GetChild(0):SetActive(false)
    end
end

local function UpdateInfo()
    _w.SetSoloTimesInfo(_data)
    _ref.js_tag:SetActive(false)

    local hero = nil
    local spLock = nil
    local cnt = #_data.hero
    for i, v in ipairs(_heros) do
        if i <= user.MaxBattleHero then
            if i <= cnt then
                hero = user.GetHero(_data.hero[i])
            else
                hero = nil
            end
            v.sp.spriteName = "frame_12"
            if hero then
                v.name.text = hero.evo
                v.utx:LoadTexAsync(ResName.HeroIcon(hero.db.img))
                if not _ref.js_tag.activeSelf then
                    _ref.js_tag.transform.parent = v.trans
                    _ref.js_tag.transform.localPosition = Vector3(0, -25)
                    _ref.js_tag:SetActive(true)
                end
            else
                v.name.text = ""
                v.utx:UnLoadTex()
            end
        else
            v.lock:SetActive(true)
            v.utx:UnLoadTex()
            local lv = 0
            for j = user.hlv, DB.maxHlv - 1 do
                lv = j
                if i <= DB.GetHome(j).lead then
                    break
                end
            end
            v.name.text = string.format(L("主城%d级解锁"), lv)
            v.name:SetActive(true)
        end
    end

    _ref.targetTip:SetActive(_data.rankRewardTip == 1)
    _ref.rmbTip:SetActive(_data.dayRewardTip == 1)
end

local function RefreshInfo()
    SVR.GetPvpRankHero( function(t)
        if t.success then
            --stab.S_PvpRankInfo
            _data = SVR.datCache
            _count = _data.prices and #_data.prices or 0
            UpdateInfo()
        end
    end )
end

function _w.OnInit()
    RefreshInfo()
    PriRefresh()
end

function _w.Refresh()
    PriRefresh()
end

function _w.OnEnter()
    BGM.Play("bg_2")
end

function _w.OnExit()
end

function _w.ClickFight(i)
    if _rivalDatas[i] then
        if _data.info[2] < 1 then
            MsgBox.Show(L("挑战次数已用完"))
        else
            --打开选择武将界面
            Win.Open("PopSelectHero", {
                SelectHeroFor.RankForFight, function(hs)
                    --把设置好的武将保存到本地
                    user:SetSoloBattleHero(hs)
                    SVR.RankReady(_rivalDatas[i].sn, hs, function(t)
                        if t.success and objt(SVR.datCache) == QYBridge.B_Battle then
                            Win.Open("WinBattle", SVR.datCache).GetDefHeroName(_rivalDatas[i].nick)
                            RefreshInfo()
                        end
                    end )
                    --更新可挑战次数
                end
            } , user:GetSoloBattleHero())
        end
    end
end

--[Comment]
--点击声望商城
function _w.ClickRenownShop()
    Win.Open("PopSoloRenownShop")
end

function _w.ClickSetHero()
    local hs = nil
    if #_data.hero > 0 then
        hs = { }
        for i, v in ipairs(_data.hero) do
            hs[i] = user.GetHero(v)
        end
    end
    Win.Open("PopSelectHero", {
        SelectHeroFor.Rank, function(hs)
            local noChange = #hs == #_data.hero
            if noChange then
                if hs and _data.hero then
                    for i = 1, #hs do
                        if hs[i] ~= _data.hero[i] then
                            noChange = false
                            break
                        end
                    end
                end
            end
            if noChange then
                return
            end
            SVR.SetRankHero(hs, function(t)
                if t.success then
                    _data = SVR.datCache
                    UpdateInfo()
                end
            end )
        end,hs
    } )
end

function _w.ClickRenownReward()
    Win.Open("PopRankRenownReward")
end

function _w.ClickRankReward()
    Win.Open("PopRankSoloReward")
end

--[Comment]
--点击排行榜
function _w.ClickRank()
    SVR.GetSoloRank( function(t)
        if t.success then
            --stab.S_SoloRankInfo
            local res = setmetatable(SVR.datCache, stab.S_SoloRankInfo)
            Win.Open("PopRankFame", res).SetSelfRankForSoloRank(_data.info[1])
        end
    end )
end

--[Comment]
--购买挑战次数
function _w.ClickBtnAdd()
    if _count > 0 then
        SVR.GetPvpRankHero( function(t)
            if t.success then
                --stab.S_PvpRankInfo
                local res = SVR.datCache
                _count = res.prices and #res.prices or 0
                Win.Open("PopBuyProps", {d=res,kind=PopBuyProps.Rank})
            end
        end )
    else
        ToolTip.ShowPopTip(L("今日购买次数已用完!"))
    end
end

function _w.OnDispose()
    _rivalDatas = nil
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
    end
end

--[Comment]
--演武榜
WinRankSolo = _w