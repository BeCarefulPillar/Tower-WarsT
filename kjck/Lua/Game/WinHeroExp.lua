local _w = { }

local _body = nil
local _ref = nil
local _update = nil

--绑定组件
local _detail = nil
local _time = nil
local _buttons = nil
local _btnBeginSilver = nil
local _btnBeginGold = nil
local _btnDone = nil
local _priceSilver = nil
local _priceGold = nil
local _doubleExp = nil
local _goldAdd = nil
local _items = nil

local heros = {
    icon = nil,
    name = nil,
    level = nil,
    stars = nil,
    starsBg = nil,
    exp = nil,
    expLab = nil,
    expFlash = nil,
    add = nil,
    tip = nil,
    vipLock = nil,
    labTitleTip = nil,
    bg_begin = nil,
    bg_end = nil,
    trainEffect = nil,

    toExp = 0,
    showAttTime = 0,
    heroData = nil,
    lastLab = nil,
    effect = nil,
    attQueue = nil,
}

--[Comment]
--训练中的将领csn
local heroDatas = nil
--[Comment]
--是否有训练中的将领
local isTraining = false
--[Comment]
--是否能点击
local canClick = true


--清楚hero数据
local function HerosDispose(h)
    h.toExp = 0
    h.showAttTime = 0
    h.heroData = nil
    h.lastLab = nil
    h.attQueue = nil
end


--[Comment]
--加载训练中的将领
local function LoadTrainHero()
    local cnt = heroDatas and #heroDatas or 0
    _priceSilver.text = tostring(cnt * user.Home.trainS)
    _priceGold.text = tostring(cnt * user.Home.trainG)
    _doubleExp.text = L( string.format("(%s倍经验)", DB.param.qtyTrain))

    if user.vip < DB.param.vipTrain then
        _btnBeginGold.isEnabled = false
        _btnBeginGold.text = L( string.format("VIP%s开启", DB.param.vipTrain))
        _btnBeginGold.label.color = Color.red
    else
        _btnBeginGold.isEnabled = true
        _btnBeginGold.text = L("高等训练")
        _btnBeginGold.label.color = Color.white
    end

    local vip = user.VipData
    for i = 1 , #heros  do
        local ihd = heros[i]
        ihd.trainEffect:SetActive(false)
        HerosDispose(ihd)
        ihd.expFlash:SetActive(false)
        ihd.add.text = ""
        if i <= cnt then
            local hd = user.GetHero(heroDatas[i])
            ihd.name.color = Color.white
            ihd.level:SetActive(true)
            ihd.exp:SetActive(true)
            ihd.starsBg:SetActive(true);
            ihd.tip:SetActive(false);
            ihd.vipLock:SetActive(false);
            
            --开始训练
            if hd then
                ihd.name.text = hd:getName()
                ihd.level.text = hd.lv
                ihd.exp.value = hd.PercentExp
                ihd.expLab.text = string.format("%0.1f%%",ihd.exp.value * 100)
                ihd.stars.TotalCount = hd.db.rare
                ihd.icon:LoadTexAsync(ResName.HeroImage(hd.db.img))
                local rect = ihd.icon.uvRect
                rect.x = HERO_X(hd.db.img)
                print("rect.xrect.x    " , HERO_X(hd.db.img))
                ihd.icon.uvRect = rect
                ihd.trainEffect:SetActive(true)
            else
                ihd.name.text = L("未知")
                ihd.level.text = "0"
                ihd.exp.value = 0
                ihd.expLab.text = "0%"
                ihd.stars.TotalCount = 0
                ihd.icon:UnLoadTex()
                ihd.trainEffect:SetActive(false)
            end
        elseif i <= vip.trainQty then
            ihd.name.text = isTraining and L("训练中") or L("开启中")
            ihd.name.color = isTraining and Color.grey or Color.green
            ihd.level:SetActive(false)
            ihd.exp:SetActive(false)
            ihd.starsBg:SetActive(false)
            ihd.tip:SetActive(true)
            ihd.tip.text = isTraining and L("正在\n训练") or L("点击\n配置")
            ihd.vipLock:SetActive(false)
        else
            ihd.name.color = Color.red
            ihd.level:SetActive(false);
            ihd.exp:SetActive(false);
            ihd.starsBg:SetActive(false);
            ihd.tip:SetActive(false);
            ihd.vipLock:SetActive(true);

            local lv = 0
            for j = user.vip ,DB.maxVip  do
                lv = j + 1
                if i <= DB.GetVip(lv).trainQty then
                    break
                end
            end
            ihd.name.text = L( string.format("VIP%s开启",lv))
        end

        --更换背景
        if ihd.starsBg.activeSelf then
            ihd.bg_begin:SetActive(false)
            ihd.bg_end:SetActive(true)
        else
            ihd.bg_begin:SetActive(true)
            ihd.bg_end:SetActive(false)
            if ihd.icon then
                ihd.icon:UnLoadTex()
            end
        end
        ihd.labTitleTip.text = ihd.name.text
        ihd.labTitleTip.color = ihd.name.color
    end
end

--[Comment]
--刷新信息
local function Refresh()
    _detail.text = L("当前训练可获得经验:")..user.Home.trainExp
    heroDatas = user.trainHero
    print("当前训练的将领CSN   " , kjson.print(heroDatas))
    isTraining = user.HasTrainHero
    canClick = not isTraining

    LoadTrainHero()

    _buttons:SetActive(canClick)
    _btnDone:SetActive(isTraining)
    _btnDone.text = user.trainTm.time > 0 and L("中断训练") or L("完成训练")
end

--[Comment]
--开始训练
local function TrainBegin(isGold)
    isGold = isGold and isGold or false
    if isTraining then
        ToolTip.ShowPopTip(ColorStyle.Warning(L("正在训练中")))
        Refresh()
        return
    end
    heroDatas = heroDatas and heroDatas or {}
    print("heroDatasheroDatas    ", kjson.print(heroDatas))

    if #heroDatas > 0 then
        SVR.TrainHeroBegin(heroDatas ,isGold ,function(res)
            if res.success then
                user.trainHero = heroDatas
                Refresh()
            end
        end)
    else
        ToolTip.ShowPopTip(ColorStyle.Warning(L("请先配置训练武将！")))
        _w.ClickHero()
    end
end

--[Comment]
--训练完成
local function OnDone()
    SVR.TrainDone(function(res)
        if res.success then
            local dat = SVR.datCache
            print("训练完成训练完成   ", kjson.print(dat))
            if dat.opt ~= "end" then
                Refresh()
                return
            end
            local len = #dat.lst
            if len <= 0 then
                Refresh()
                return
            end

            local hds = {}
            for i = 1 ,len do
                hds[i] = dat.lst[i * 3]
            end
            
            user.trainHero = {}
            isTraining = false
            _btnDone.isEnabled = false

            for i = 1, #heros do
                local ihd = heros[i]
                HerosDispose(ihd)
                if ihd.name.text ~= L("训练中") then
                    for j = 1, len  do
                        hd = user.GetHero(hds[j])
                        if hd and ihd.name.text == hd:getName() then
                            local idx = j * 3
                            ihd.add.text = L("经验").."+".. math.max(hd.Exp - dat.lst[idx + 2], 0)
                            break
                        end
                    end
                end
            end
            
            _btnDone.isEnabled = true
            _btnDone.text = L("确定")
            canClick = false
        end
    end)
end

local function Update()
    if isTraining then
        if not _time.enabled then
            _time.enabled = true
        end
        if user.trainTm.time > 0 then
            _time.text = L("剩余时间:") .. TimeClock.TimeToString(user.trainTm.time)
            if _time.color ~= Color.red then
                _time.color = Color.red
                _btnDone.text = L("中断训练")
            end
        else
            _time.text = L("完成训练")
            if _time.color ~= Color.green then
                _time.color = Color.green
                _btnDone.text = L("完成训练")
            end 
        end
    elseif _time.enabled then
        _time.enabled = false
    end
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.BG , n = L("经验塔"), i = true, r = DB_Rule.HeroExp})
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad",
                    "ClickHero","ClickBeginSilver","ClickBeginGold","ClickDone")
    _ref = c.nsrf.ref
    
    
    --绑定组件
    _detail = _ref.detail
    _time = _ref.time
    _buttons = _ref.buttons
    _btnBeginSilver = _ref.btnBeginSilver
    _btnBeginGold = _ref.btnBeginGold
    _btnDone = _ref.btnDone
    _priceSilver = _ref.priceSilver
    _priceGold = _ref.priceGold
    _doubleExp = _ref.doubleExp
    _goldAdd = _ref.goldAdd
    _items = _ref.items

    for i = 1, #_items do
        local itRef = _items[i]:GetCmp(typeof(NGUISerializeRef)).ref
        heros[i] = {}
        heros[i].icon = itRef.icon                
        heros[i].name = itRef.name                
        heros[i].level = itRef.level              
        heros[i].stars = itRef.stars              
        heros[i].starsBg = itRef.starsBg          
        heros[i].exp = itRef.exp                  
        heros[i].expLab = itRef.expLab            
        heros[i].expFlash = itRef.expFlash        
        heros[i].add = itRef.add                  
        heros[i].tip = itRef.tip                  
        heros[i].vipLock = itRef.vipLock          
        heros[i].labTitleTip = itRef.labTitleTip  
        heros[i].bg_begin = itRef.bg_begin        
        heros[i].bg_end = itRef.bg_end            
        heros[i].trainEffect = itRef.trainEffect  
    end

end

function _w.OnInit() 
    Refresh()
    _update = UpdateBeat:CreateListener(Update)
    UpdateBeat:AddListener(_update)
end

function _w.OnDispose()
    UpdateBeat:Remove(Update)
    _update = nil

end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
    _update = nil
    _detail = nil
    _time = nil
    _buttons = nil
    _btnBeginSilver = nil
    _btnBeginGold = nil
    _btnDone = nil
    _priceSilver = nil
    _priceGold = nil
    _doubleExp = nil
    _goldAdd = nil
    _items = nil
    
end

--点击配置
function _w.ClickHero()
    if not isTraining and canClick then
        Win.Open("PopSelectHero", { 
        SelectHeroFor.Exp, function(hs)
            local len = hs and #hs or 0
            if len > 0 then
                heroDatas = hs
                LoadTrainHero()
            end
        end},heroDatas)
    end
end

--银币训练
function _w.ClickBeginSilver()
    TrainBegin(false)
end

--金币训练
function _w.ClickBeginGold()
    TrainBegin(true)
end

--完成或终止训练
function _w.ClickDone()
    print("完成或终止训练完成或终止训练")
    if isTraining then
        if user.trainTm.time > 0 then
            MsgBox.Show(L("主公，训练尚未结束，是否中断训练？"), L("取消")..","..L("确定"), function(bix)
                if bix == 1 then
                    OnDone()
                end  
            end)
        else
            OnDone()
        end
    else
        Refresh()
    end
end


--[Comment]
--经验塔
WinHeroExp = _w