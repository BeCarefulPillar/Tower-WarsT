local _w = { }
--[Comment]
--排名
PopRankFame = _w

local _body = nil
local _ref = nil

local _items = nil
local _heros = nil
local _grid = nil
local _def = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "ClickShowDefendHero",
    "Help",
    "OnUnLoad"
    )

    _grid = {
        UIGrid = _ref.grid,
        UIScrollView = _ref.grid:GetCmp(typeof(UIScrollView)),
    }
    _ref.grid = nil

    _def = {
        go = _ref.def,
        UIGrid = _ref.def:Child("Items",typeof(UIGrid)),
        itemdhero = _ref.def:Child("item_defendHero").gameObject,
    }
    _ref.def = nil
end

local _ranks = {
    [1] = "[ffe553]",
    [2] = "[89cdfb]",
    [3] = "[ffa880]",
    def = "[dddddd]",
}
local function SetRankColor(r)
    return _ranks[r] or _ranks.def
end

function _w.OnInit()
    _ref.btnHelp:SetActive(false)

    --[[
    if objt(_w.initObj) == stab.S_AllyBattle_Rank then
        --联盟战排名
        local data = _w.initObj
        _ref.nameLab.text = L("联盟")
        _ref.fameLab.text = L("钻石")
        _ref.title.text = L("盟战排名")
        if data.myRank[1] <= 0 then
            --联盟没报名或者没联盟或者没得分
            if user.ally.sn > 0 then
                --有联盟
                _ref.myRank.text = "--"
                _ref.myName.text = user.ally.nm
                local isEnrolled = false
                local w = Win.GetOpenWin("WinAllyBattle")
                if w then
                    isEnrolled = w.data.status > 0
                end
                if isEnrolled then
                    --已报名
                    _ref.myFame.text = "0"
                else
                    --没报名
                    _ref.myFame.text = "--"
                end
            else
                _ref.myRank.text = "--"
                _ref.myFame.text = "--"
                _ref.myName.text = "--"
            end
        else
            _ref.myRank.text = tostring(data.myRank[1])
            _ref.myFame.text = user.ally.nm
            _ref.myName.text = tostring(data.myRank[2])
        end

        if data.items and #data.items > 0 then
            --有排名数据
            _ref.tip:SetActive(false)
            _ref.tip:SetActive(false)
            local len = math.min(#_ranks, 10)
            _items = _items or { }
            for i = 1, len do
                _items[i] = _items[i] or _grid.go:AddChild(_ref.item_rank, i)
                _items[i]:ChildWidget("rank").text = SetRankColor(i) .. i
                _items[i]:ChildWidget("name").text = data.items[i].allyName
                _items[i]:ChildWidget("fame").text = tostring(data.items[i].score)
                _items[i].widget.enabled = i % 2 == 1
                _items[i]:SetActive(true)
            end
            _grid.UIGrid.repositionNow = true
            _grid.UIScrollView:ConstraintPivot(UIWidget.Pivot.Top, false)
        else
            _ref.tip:SetActive(true)
        end
    else]]
    if objt(_w.initObj) == stab.S_SoloRankInfo then
        --竞技场（演武榜）中的排行榜
        _ref.btnHelp:SetActive(true)
        _ref.title.text = L("竞技场排名")
        _ref.fameLab.text = L("实力")
        _ref.myName.text = user.nick
        _ref.myFame.text = tostring(user.score)

        local info = _w.initObj.ranks
        local len = #info

        _items = _items or { }
        for i = 1, len do
            if not _items[i] then
                local item = _items[i] or _grid.UIGrid:AddChild(_ref.item_rank, string.format("item_%02d", i))
                _items[i] = {
                    go = item,
                    rank = item:ChildWidget("rank"),
                    name = item:ChildWidget("name"),
                    fame = item:ChildWidget("fame"),
                    btn = item.luaBtn,
                    wgt = item.widget
                }
            end
            _items[i].go:SetActive(true)
            _items[i].rank.text = SetRankColor(info[i].rank) .. info[i].rank
            _items[i].name.text = info[i].nm
            _items[i].fame.text = tostring(info[i].score)
            _items[i].btn.param = info[i]
            _items[i].wgt.enabled = true
            _items[i].wgt.spriteName = i % 2 == 1 and "bg_select_hero" or "emptySprite"
        end
        _grid.UIGrid.repositionNow = true
        _grid.UIScrollView:ConstraintPivot(UIWidget.Pivot.Top, true)

    elseif type(_w.initObj) == "table" and _w.initObj[1] and _w.initObj[2] then
        --名人堂中的排名
        _ref.nameLab.text = L("君主")
        local data = _w.initObj[1]
        local info = _w.initObj[2]

        if data and info then
            local sn = data.sn
            if sn > 0 then
                local idx = sn
                _ref.title.text = data.n .. L("排名")
                _ref.fameLab.text = data.t
                _ref.myRank.text = "--"
                _ref.myName.text = user.nick
                _ref.myFame.text = info.myInfo and info.myInfo[idx] and tostring(info.myInfo[idx]) or "0"

                local _ranks = info.ranks and info.ranks[idx]
                if _ranks and #_ranks > 0 then
                    _ref.tip:SetActive(false)
                    local len = math.min(#_ranks, 10)
                    _items = _items or { }
                    for i = 1, len do
                        if _ranks[i].sn == user.psn then
                            _ref.myRank.text = tostring(_ranks[i].rank)
                        end
                        if not _items[i] then
                            local item = _grid.UIGrid:AddChild(_ref.item_rank, string.format("item_%02d", _ranks[i].rank))
                            _items[i] = {
                                go = item,
                                rank = item:ChildWidget("rank"),
                                name = item:ChildWidget("name"),
                                fame = item:ChildWidget("fame"),
                                btn = item.luaBtn,
                                wgt = item.widget
                            }
                        end
                        _items[i].go:SetActive(true)
                        _items[i].rank.text = SetRankColor(_ranks[i].rank) .. _ranks[i].rank
                        _items[i].name.text = _ranks[i].name
                        _items[i].fame.text = tostring(_ranks[i].fame)
                        _items[i].wgt.enabled = i % 2 == 1
                    end
                    if len == 10 and _ref.myRank.text == "--" then
                        _ref.myRank.text = "10+"
                    end
                    _grid.UIGrid.repositionNow = true
                    _grid.UIScrollView:ConstraintPivot(UIWidget.Pivot.Top, false)
                else
                    _ref.tip:SetActive(true)
                end
                return
            end
        end
    else
        Destroy(_body.gameObject)
    end
end

local function Despawn(its)
    if its then
        for _, v in ipairs(its) do
            v.go:SetActive(false)
        end
    end
end

function _w.OnDispose()
    Despawn(_items)
    _def.go:SetActive(false)
    Despawn(_heros)
end

function _w.SetSelfRankForSoloRank(i)
    _ref.myRank.text = tostring(i)
end

--[Comment]
--竞技场排名，点击玩家显示驻守武将
function _w.ClickShowDefendHero(p)
    local info = p
    SVR.GetDefendHero(info.sn, function(t)
        if t.success then
            local heroDbsn = SVR.datCache

            _def.go:SetActive(true)
            _heros = _heros or { }
            Despawn(_heros)
            for i = 1, #heroDbsn do
                if not _heros[i] then
                    local hero = _def.UIGrid:AddChild(_def.itemdhero, string.format("item_%02d", i))
                    _heros[i] = {
                        go = hero,
                        name = hero:ChildWidget("name"),
                        img = hero:ChildWidget("img"),
                        wgt = hero.widget,
                    }
                end
                _heros[i].go:SetActive(true)
                local h = DB.GetHero(heroDbsn[i])
                _heros[i].name.text = h.nm
                _heros[i].img:LoadTexAsync(ResName.HeroIcon(h.img))
                _heros[i].wgt.alpha = 0
                TweenAlpha.Begin(_heros[i].go, 0.2, 1,(i - 1) * 0.1)
            end
            _def.UIGrid.repositionNow = true
        end
    end )
end

function _w.Help()
    Win.Open("PopRule", DB_Rule.RankFame)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _items = nil
        _heros = nil
        _grid = nil
        _def = nil
    end
end