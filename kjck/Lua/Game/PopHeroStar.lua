local _w = { }

local _body = nil
local _ref = nil


local hero = nil
local heroIndex = nil
local curHero = nil
local rate = nil    
local listenerSleepTime = nil 
local dragDelta = nil

--绑定对象
local _infos = nil
local _mats = nil

local odds = nil
local oddsRate = nil
local oddsRatePro = nil
local btnAdd = nil
local btnReduce = nil
local btnUp = nil
local optionPanel = nil
local tip = nil
local heroName = nil
local heroRare = nil
local heroUtx = nil
local btnHelp = nil
local skill_js_name = nil
local skill_js_detail = nil
local btnLeft = nil
local btnRight = nil
local btnHero = nil
local heroQualify = nil

local function SetInfos(temp, text1, text2, text3)
    temp = temp + 1
    _infos[temp].text = L(text1) 
    temp = temp + 1
    _infos[temp].text = text2
    temp = temp + 1
    _infos[temp].text = text3
    return temp
end

--升星信息
local function ShowUpInfo()
    if hero == nil then return end
    local to = DB.GetHeroStar(hero.star + 1)
    if rate == nil then
        rate = 0
    end
    if (not hero.IsMaxStarLv) and hero.IsStarHero then
        local len = #to.odds
        if len > 0 then
            rate = math.clamp(rate, 1, len) 
            odds.text = to.odds[rate].."%"
            oddsRate.text = rate .. "/" .. len
            oddsRatePro:GetCmp(typeof(UIProgressBar)).value = rate / len
            btnAdd:GetCmp(typeof(UIButton)).isEnabled = rate < len 
            btnReduce:GetCmp(typeof(UIButton)).isEnabled = rate > 1
            btnUp:GetCmp(typeof(UIButton)).isEnabled = true
            btnUp:GetCmpInChilds(typeof(UILabel),false).text= to.GetLv == 0 and "升星" or "升级"
            optionPanel:SetActive(true)
            tip:SetActive(false)
            local lab = _mats[1]:Child("num"):GetCmp(typeof(UILabel))
            if to.soul > 0 then
                lab.text = user.GetSoulQty(hero.db.sn) .. "/" ..(to.soul * rate)
                lab.color =(to.soul * rate) > user.GetSoulQty(hero.db.sn) and Color.red or Color.green
            else
                lab.text = ""
            end
            len = #to.mat
            for i = 2, #_mats do
                local continue = nil
                if (i - 1 <= len) then
                    local rw = to.mat[i - 1]
                    if rw[1] == 2 then
                        local p = DB.GetProps(rw[2])
                        lab = _mats[i]:Child("num"):GetCmp(typeof(UILabel))
                        lab.text = user.GetPropsQty(p.sn) .. "/" .. rw[3]
                        lab.color =(rw[3] * rate) > user.GetPropsQty(p.sn) and Color.red or Color.green
                        continue = 1
                    end
                end
                if not continue then _mats[i]:Child("num"):GetCmp(typeof(UILabel)).text = "" end
            end
            return
        end
    end
    odds.text = "--"
    oddsRate.text = "-/-"
    oddsRatePro:GetCmp(typeof(UIProgressBar)).value = 1

    optionPanel:SetActive(false)
    tip:SetActive(true)

    if hero.IsMaxStarLv then
        tip.text = L("已升至最高将星等级")
    elseif not hero.IsStarHero then
        tip.text = L("五星武将方可升级将星")
    elseif hero.lv < to.clv then
        tip.text = L("武将") .. to.heroLv .. L("级方可继续升级将星")
    else
        tip.text = L("武将") .. to.clv .. L("武将无法升级将星")
    end
    for i = 1, #_mats do _mats[i]:Child("num"):GetCmp(typeof(UILabel)).text = "" end

end

--将领信息
local function ShowHeroInfo()
    if hero == nil then return end
    -- 基本信息
    heroName.text = hero.db:GetEvoName(hero.evo)
    heroRare.TotalCount = hero.db.rare
    heroUtx:LoadTexAsync(ResName.HeroImage(hero.db.img))
    heroQualify.text = L("资质:")..hero.db.aptitude
    skill_js_name.text = DB.GetSkt(hero.db.skt).nm
    skill_js_detail.text = DB.GetSkt(hero.db.skt).i
    -- 将星信息
    local from = hero.star>0 and DB.GetHeroStar(hero.star) or DB_HeroStar.undef
    local to = DB.GetHeroStar(hero.star + 1)
    local s= from:Star().. L("星")..from:Lv()..L("级")
    _infos[1].text = hero.IsMaxStarLv and s .. L("至高将星") or s
    for i = 2, 7 do _infos[i].text = "" end
    local temp = 1
    if hero.db.sstr > 0 then
        temp=SetInfos(temp, "武力", hero.MaxStr, hero.MaxStr + hero.db.sstr)
    end
    if hero.db.swis > 0 then
        temp=SetInfos(temp, "智力", hero.MaxWis, hero.MaxWis + hero.db.swis)
    end
    if hero.db.scap > 0 then
        temp=SetInfos(temp, "统帅", hero.MaxCap, hero.MaxCap + hero.db.scap)
    end
    if hero.db.shp > 0 then
        temp=SetInfos(temp, "生命", hero.MaxHP, hero.MaxHP + hero.db.shp)
    end 
    if hero.IsMaxStr or to.lv or(not hero.IsStarHero) then
        _infos[4].gameObject:SetActive(false)
        _infos[7].gameObject:SetActive(false)
    else
        _infos[4].gameObject:SetActive(true)
        _infos[7].gameObject:SetActive(true)
    end
    temp = from : Star() 
    local n = 0
    for i = 8,17 do 
        if i % 2 == 1 then 
            n = n + 1
            _infos[i].text = hero.db:GetStarDesc(n)
        end
    end 
    n = 0
    for i = 8,17 do
        if i % 2 == 0 then n = n + 1 end
        _infos[i].color=temp < n and Color.gray or _infos[i].gradientBottom 
    end 

    -- 升级信息
    if not hero.IsMaxStarLv and hero.IsStarHero then 
        if to.soul > 0 then
            _mats[1]:LoadTexAsync(ResName.HeroIcon(hero.db.img))
            _mats[1]:GetCmp(typeof(LuaButton)):SetClick("ShowSoul", hero)
        else
            _mats[1]:LoadTexAsync("p_n")
        end
        temp = #to.mat
        local continue = nil
        for i = 1, #_mats do
            if i <= temp then 
                local rw = to.mat[i]
                if rw[1] == 2 then
                    local p = DB.GetProps(rw[2])
                    _mats[i+1]:LoadTexAsync(ResName.PropsIcon(p.img))
                    _mats[i+1]:GetCmp(typeof(LuaButton)):SetClick("ShowData", p)
                    continue = 1
                end
            end
            if not continue then _mats[i]:LoadTexAsync("p_n") end
        end
    else
        for i = 1,  #_mats do
            _mats[i]:LoadTexAsync("p_n")
        end
    end
    ShowUpInfo()
end

--改变将领
local function ChangeHero(hd)
    if hd == nil then return end
     -- 改变hero对象
    hero= DataCell.DataChange(hero, hd, _w)
    btnLeft:GetCmp(typeof(UIButton)).isEnabled =  heroIndex > 1
    btnRight:GetCmp(typeof(UIButton)).isEnabled = heroIndex < #heros
    ShowHeroInfo()
end

-- 控制DataCell的侦听睡眠
local function ListenerSleep(time)
    if not time then time = 0 end
    listenerSleepTime = time > 0 and Time.realtimeSinceStartup + time or 0
end

-- 升级特效
-- 0=失败 1=升级 2=升星
local function OnUpStar(style)
    for i = 1, #_mats do
        local continue = nil
        if i == 0 and style == 0 then continue = 1 end
    end
    if style == 1 then
        ToolTip.Mask(0.8)
        coroutine.step()
        _body:AddChild(AM.LoadPrefab("ef_hero_star_lv"), "ef_hero_star_lv", false)
        coroutine.wait(0.6)
    elseif style == 2 then
        ToolTip.Mask(0.8)
        coroutine.step()
        _body:AddChild(AM.LoadPrefab("ef_hero_star_up"), "ef_hero_star_up", false)
        coroutine.wait(0.6)
    else
        ToolTip.Mask(0.8)
        coroutine.step()
        _body:AddChild(AM.LoadPrefab("ef_hero_star_failed"), "ef_hero_star_failed", false)
        coroutine.wait(0.6)
    end
    ListenerSleep(0)
    ShowHeroInfo()
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK })
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad",
                    "ClickAdd","ClickReduce","ClickLeft","ClickRight","PressSwitchHero",
                    "DragSwitchHero","ShowSoul","ShowData","ClickUpgrade","ClickHelp")
    _ref = c.nsrf.ref

    _infos = _ref.infos
    _mats = _ref.mats

    odds = _ref.odds
    oddsRate = _ref.oddsRate
    oddsRatePro = _ref.oddsRatePro
    btnAdd = _ref.btnAdd
    btnReduce = _ref.btnReduce
    btnUp = _ref.btnUp
    optionPanel = _ref.optionPanel
    tip = _ref.tip
    heroName = _ref.heroName
    heroRare = _ref.heroRare
    heroUtx = _ref.heroUtx
    btnHelp = _ref.btnHelp
    skill_js_name = _ref.skill_js_name
    skill_js_detail = _ref.skill_js_detail
    btnLeft = _ref.btnLeft
    btnRight = _ref.btnRight
    heroQualify = _ref.heroQualify
end

function _w.OnInit() 
    local data = _w.initObj
    listenerSleepTime = 0   
    dragDelta = 0
    if objis(data, PY_Hero) then
        curHero = data
        local win = Win.GetOpenWin("WinHero")
        if win then heros = WinHero.Heros end
    elseif type(data) == "table" then
        heros={}
        for i, val in pairs(data) do  
                if objt(val)== PY_Hero then
                     curHero = val
                elseif type(val) == "table" then
                      heros = val
                end 
        end 
        if heros == nil then
            heros = table.findall( user.GetHeros(),function(h) return h.IsStarHero end)
            table.sort(heros, function(a, b) heros.Compare(a, b) end)
        else
            heros = table.findall(heros,function(h) return h.IsStarHero end)
        end 
        local len = #heros 
        if len > 0 then
            if curHero then
                for i = 1, len do
                    if curHero.sn == heros[i].sn then heroIndex = i break end
                end
            end
            hero = heros[heroIndex]
            --添加观察者
            hero:AddObserver(_w)
            btnLeft:GetCmp(typeof(UIButton)).isEnabled = heroIndex >1
            btnRight:GetCmp(typeof(UIButton)).isEnabled = heroIndex < #heros
            ShowHeroInfo()
        end
    end

end

function _w.OnDispose()
    hero = nil
    heroIndex = nil
    curHero = nil
    rate = nil    
    listenerSleepTime = nil 
    dragDelta = nil
end

function _w.OnUnLoad(c)
    _infos = nil
    _mats = nil
    
    odds = nil
    oddsRate = nil
    oddsRatePro = nil
    btnAdd = nil
    btnReduce = nil
    btnUp = nil
    optionPanel = nil
    tip = nil
    heroName = nil
    heroRare = nil
    heroUtx = nil
    btnHelp = nil
    skill_js_name = nil
    skill_js_detail = nil
    btnLeft = nil
    btnRight = nil
    btnHero = nil
    heroQualify = nil
end

--加材料
function _w.ClickAdd()
    rate = rate + 1
    ShowUpInfo()
end

--减材料
function _w.ClickReduce()
    rate = rate - 1
    ShowUpInfo()
end

--切换将领左
function _w.ClickLeft()
    if heroIndex > 1 then
        heroIndex = heroIndex - 1
        ChangeHero(heros[heroIndex])
    end
end

--切换将领右
function _w.ClickRight() 
    print(heroIndex)
    if heroIndex<#heros then
        heroIndex = heroIndex + 1
        ChangeHero(heros[heroIndex])
    end
end

--拖拽切换武将
function _w.PressSwitchHero(pressd)
    if pressd then
        dragDelta = 0
    elseif dragDelta > 35 then
        _w.ClickLeft()
    elseif dragDelta < -35 then
        _w.ClickRight()
    end
end

--拖拽切换武将
function _w.DragSwitchHero(delta) 
    if delta.x * dragDelta < 0 then 
        dragDelta = 0
    end
    dragDelta=dragDelta+ delta.x
end

--显示将魂提示
function _w.ShowSoul(h) 
    if h then
        ToolTip.ShowPropTip(L(ColorStyle.Rare(h.nm .. "(将魂)", h.rare)), "类型:将魂".."\n".."说明:" .. string.format("用于觉醒%s，提升%s将星，或分解为魂币", h.nm,h.nm))
    end
end

--显示道具提示
function _w.ShowData(p) 
    if p then p:ShowData(p.count) end
end

--点击觉醒
function _w.ClickUpgrade()
    if hero then
        local h = hero
        local lastLv = hero.star
        SVR.HeroUpStar(hero.sn, math.max(rate, 1), function(re)
            if re.success then
                ListenerSleep(5)
                coroutine.start(OnUpStar, h.star > lastLv and(DB_HeroStar.GetStar(h.star) > DB_HeroStar.GetStar(lastLv) and 2 or 1) or 0)
            end
        end )
    end
end

function _w.ClickHelp()
    Win.Open("PopRule" , DB_Rule.HeroStar)
end

--[Comment]
--升星
PopHeroStar = _w