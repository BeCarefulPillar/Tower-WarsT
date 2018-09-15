local notnull = notnull

local _item = {
    go = nil,
    imgl = nil,
    frame = nil,
    heroName = nil,
    tip = nil,
    slock = nil,
    hero = nil,
}

function _item.New(go)
    assert(notnull(go), "create ItemHeroSelected need GameObject")
    return {
        go = go,
        imgl = go:Child("hero",typeof(UITextureLoader)),
        frame = go.widget,
        heroName = go:ChildWidget("name"),
        tip = go:ChildWidget("tip"),
        slock = go:ChildWidget("slock"),
        hero = nil,
    }
end

function _item:CheckStatus(index, purpose)
    self.hero = nil
    self.slock.spriteName = "asdasdasdasdsd"
    self.heroName.fontSize = 16
    local lv = 0
    if purpose == SelectHeroFor.Exp then
        lv = user.MaxTrainHero
    elseif purpose == SelectHeroFor.Nat then
        lv = user.MaxCountryHero
    elseif purpose == SelectHeroFor.NatOption then
        lv = 1
    elseif purpose == SelectHeroFor.ExploreMove or purpose == SelectHeroFor.GroundExplore then
        lv = 3
    else
        lv = user.MaxBattleHero
    end
    self.frame.spriteName = "frame_12"
    if index <= lv then
        self.heroName.text = ""
        if notnull(self.tip) then
            self.tip:SetActive(true)
        end
        if notnull(self.slock) then
            self.tip:SetActive(false)
            self.frame.spriteName = "frame_12"
        end
        self.go:SetActive(true)
        return true
    end

    if notnull(self.tip) then
        self.tip:SetActive(false)
    end
    if notnull(self.slock) then
        self.slock:SetActive(true)
        self.frame.spriteName = "sp_lock"
    end

    local count = 0
    lv = 0

    if purpose == SelectHeroFor.Exp then
        for i = user.vip, DB.maxVip - 1 do
            count = DB.GetVip(i).trainQty
            lv=i
            if index <= count then
                break
            end
        end
        self.heroName.text = string.format(L("VIP%d开启"), lv)
        self.heroName:SetActive(true)
    elseif purpose == SelectHeroFor.Nat then
        for i = user.ttl, DB.maxTtl - 1 do
            count = DB.GetTtl(i).heroQty
            lv=i
            if index <= count then
                break
            end
        end
        self.heroName.text = string.format(L("晋升%d解锁"), DB.GetTtl(lv).nm)
        self.heroName:SetActive(true)
    elseif purpose == SelectHeroFor.NatOption then
        count = 1
    elseif purpose == SelectHeroFor.GveMove or purpose == SelectHeroFor.GVE then
        count = 5
    else
        for i = user.hlv, DB.maxHlv - 1 do
            count = DB.GetHome(i).lead
            lv=i
            if index <= count then
                break
            end
        end
        self.heroName.text = string.format(L("主城%d级解锁"), lv)
        self.heroName:SetActive(true)
    end

    self.imgl:Dispose()
    self.go:SetActive(index <= count)
    return false
end

_item.__get = {
    IsLocked = function(i)
        return i.slock.activeSelf
    end,
    IsSelected = function(i)
        return i.hero and tonumber(i.hero.sn) > 0
    end,
    SelectedHero = function(i)
        return i.hero
    end
}

_item.__set = {
    SelectedHero = function(i, v)
        if v then
            i.hero = v
            i.heroName.text = ""
            i.imgl:Load(ResName.HeroIcon(i.hero.db.img))
        else
            i.hero = nil
            i.heroName.text = ""
            i.imgl:Dispose()
        end
        if notnull(i.tip) then
            i.tip:SetActive(not i.IsSelected and i.frame.spriteName == "frame_12")
        end
    end
}

objext(_item)

ItemHeroSelected = _item