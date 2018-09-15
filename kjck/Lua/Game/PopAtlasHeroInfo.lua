local _w = { }

local _body = nil
local _ref = nil

--组件绑定
local _heroName = nil
local _heroKind = nil
local _texHeroImage = nil
local _labAptitude = nil
local _jsSkillName = nil
local _jsSkillDescribe = nil
local _strength = nil
local _intelligent = nil
local _cap = nil
local _maxHP = nil
local _maxSP = nil
local _maxTP = nil
local _skillGrid = nil
local _item_goods = nil
local _startDescribe = nil
local _startDescribelab = nil


local h = nil
local items = nil   

local function UpdateInfo()
    _heroName.text = h.nm
    _heroKind.spriteName = "hero_kind_"..h.kind
    _texHeroImage:LoadTexAsync(ResName.HeroImage(h.img))
    _labAptitude.text = h.aptitude
    _jsSkillName.text = DB.GetSkt(h.skt).nm
    _jsSkillDescribe.text = DB.GetSkt(h.skt).i
    _strength.text = h.str
    _intelligent.text = h.wis
    _cap.text = h.cap
    _maxHP.text = h.hp
    _maxSP.text = h.sp
    _maxTP.text = h.tp
    for i = 1 ,5 do
        _startDescribe[i].text = i..L("星")
        _startDescribelab[i].text = h:GetStarDesc(i)
    end
    local skc = h.skc
    if not items then items = {} end
    for i = 1 ,#skc do
        local d = DB.GetSkc(skc[i])
        if items[i] then
        else    
            items[i] = ItemGoods(_skillGrid:AddChild(_item_goods, "skc_"..i))
            items[i].go.luaBtn.luaContainer = _body
        end
        
        items[i]:Init(d,true)
    end
    _skillGrid.repositionNow = true
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK })
    _body = c
    c:BindFunction("OnInit","OnEnter","OnFocus","OnExit","OnDispose","OnUnLoad","ClickItemGoods")
    _ref = c.nsrf.ref
    _heroName = _ref.heroName
    _heroKind = _ref.heroKind
    _texHeroImage = _ref.texHeroImage
    _labAptitude = _ref.labAptitude
    _jsSkillName = _ref.jsSkillName
    _jsSkillDescribe = _ref.jsSkillDescribe
    _strength = _ref.strength
    _intelligent = _ref.intelligent
    _cap = _ref.cap
    _maxHP = _ref.maxHP
    _maxSP = _ref.maxSP
    _maxTP = _ref.maxTP
    _skillGrid = _ref.skillGrid
    _item_goods = _ref.item_goods
    _startDescribe = _ref.startDescribe
    _startDescribelab = _ref.startDescribelab
end

function _w.OnInit() 
    h = _w.initObj
    if isNumber(h) and h > 0 then
        h = DB.GetHero(h)
        UpdateInfo()
    else
        _body:Exit()
    end
end

function _w.OnDispose()

end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
    _heroName = nil
    _heroKind = nil
    _texHeroImage = nil
    _labAptitude = nil
    _jsSkillName = nil
    _jsSkillDescribe = nil
    _strength = nil
    _intelligent = nil
    _cap = nil
    _maxHP = nil
    _maxSP = nil
    _maxTP = nil
    _skillGrid = nil
    _item_goods = nil
    _startDescribe = nil
    _startDescribelab = nil
end

function _w.ClickItemGoods(bt)
    local ig = Item.Get(bt.gameObject)
    if ig then
        ig:ShowPropTip()
    end
end

--[Comment]
--名将谱武将详情
PopAtlasHeroInfo = _w