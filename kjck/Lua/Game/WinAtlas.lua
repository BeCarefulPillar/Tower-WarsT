local _w = { }

local _body = nil
local _ref = nil

local item_hero_a = nil
local tab_0 = nil
local leftTab = nil
local collection = nil
local attribe = nil
local intro = nil
local scrollView = nil
local arrow = nil

local tabs = nil
local mDatas = nil
local extraAtt = nil
local view  =  -1
local data = nil
local defaultColor = nil

local function GetAtlasAttDesc(atts)
    local ret = ""
    if atts ~= nil then for i,item in ipairs(atts) do ret = ( string.len(ret) > 0 and ret or "").." "..DB.GetAttWord(item) end end
    return string.len(ret) > 0 and ret or L("无")
end
 


local function ChangeView(v,force)
    if not v then v = 1 end
    if force == nil then force = false end
    v = math.clamp(v, 1 ,#mDatas)
    view = v
    tab_0.luaBtn.isEnabled = view ~= 1
    tab_0.luaBtn.label.color = view ~= 1 and  Color.New(46 / 255, 52 / 255, 59 / 255,1) or Color.white
    for i = 1,#tabs do 
        tabs[i].luaBtn.isEnabled  = view ~= i + 1 
        tabs[i].luaBtn.label.color = view ~= i + 1 and  Color.New(46 / 255, 52 / 255, 59 / 255,1) or Color.white
    end
    local tab = view > 1 and tabs[view - 1] or tab_0 
    local lab = tab.transform:Child("count"):GetCmp(typeof(UILabel))
    collection.text = lab.text
    collection.color = defaultColor
    attribe.text = extraAtt[view] 
    attribe.color = collection.color == Color.green and Color.green or Color.New(0.57,0.57,0.57,1)--Color.grey
    intro.text = view == 1 and L("收集越多，战场增益越高") or L("集齐以下所有武将触发战场增益") 
    scrollView.enabled = mDatas[view] and #mDatas[view]>5 or false
    arrow:SetActive(scrollView.enabled)
    local grid = scrollView:GetCmp(typeof(UIWrapGrid))
    grid:Reset()
    grid.realCount = #mDatas[view] 
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.BG , n = L("名将谱")})
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad","OnWrapGridInitItem",
                    "ClickSortTab","ClickItem")
    _ref = c.nsrf.ref
    -- 组件绑定
    item_hero_a = _ref.item_hero_a
    tab_0 = _ref.tab_0
    collection = _ref.collection
    attribe = _ref.attribe
    intro = _ref.intro
    arrow = _ref.arrow
    leftTab = _ref.leftTab
    scrollView = _ref.scrollView
end

function _w.OnInit() 
    print("WinAtlas: -----OnInit------") 
    local d = DB.Get("hero_atlas")
    print(kjson.encode(d))
    if not d then ToolTip.ShowPopTip(ColorStyle.Bad(L("图鉴数据加载失败！请尝试重新启动游戏。"))) end
    data = d
    local count = #d
    tabs = {}
    mDatas = {}
    extraAtt = {}
    local cur,total
    local lab 
    for i = 1,count do 
        local idx = i + 1
        local n = d[i]
        cur = 0
        mDatas[idx] = {}
        local s = ""
        for k = 1,#n.att do s = s..DB.GetAttWordKV(n.att[k][1],n.att[k][2]) end
        extraAtt[idx] =  s  
        total = #n.hero
        for j = 1,total do 
            mDatas[idx][j] = DB.GetHero(n.hero[j]) 
            if user.ExistHero(n.hero[j]) then cur = cur + 1 end
        end
        local go = leftTab:AddChild(tab_0,"tab_"..idx)
        go.transform:Child("name"):GetCmp(typeof(UILabel)).text = n.nm
        lab = go.transform:Child("count"):GetCmp(typeof(UILabel))
        lab.text  =  cur .. "/" ..total
        lab.color =  cur > 0 and Color.green or Color.white
        defaultColor = lab.color
        go:GetCmp(typeof(LuaButton)):SetClick("ClickSortTab",idx)
        tabs[i] = go
    end
    
    mDatas[1] = table.findall(DB.AllHero(),function(hdb) return next(hdb.atlasAtt[1]) end) 
    cur  =  0
    print("mDatasmDatas  " ,kjson.encode(mDatas[1])) 
    local atts = ExtAtt()
    for k,item in ipairs(mDatas[1]) do  
        if user.ExistHero(item.sn) then 
            cur = cur + 1
            for i,v in ipairs(item.atlasAtt) do
                atts:ConvKV(v[1],v[2])
            end
        end
    end 
    local str = ""
    for k,v in pairs(atts) do str = str..(k == 1 and "" or " ")..DB.GetAttWordKV(k,v) end
    extraAtt[1] = str
    lab = tab_0.transform:ChildWidget("count")
    tab_0:GetCmp(typeof(LuaButton)):SetClick("ClickSortTab",1)
    lab.text  =  cur.."/"..#mDatas[1]
    lab.color  =  cur > 0 and Color.green or Color.white 
    leftTab:GetCmp(typeof(UIGrid)).repositionNow  =  true
    ChangeView()
end

function _w.OnDispose()
    view = -1
    extraAtt = nil
    mDatas = nil
    if tabs then for k,v in ipairs(tabs) do v.gameObject:Destroy() end  end
    tabs = nil
end

function _w.OnUnLoad(c)
    _ref = nil
    _body = nil

    item_hero_a = nil
    tab_0 = nil
    leftTab = nil
    collection = nil
    attribe = nil
    intro = nil
    scrollView = nil
    arrow = nil
end

function _w.OnWrapGridInitItem(go, index)
    if index < 0 then return false end
    index = index + 1
    local datas = mDatas[view] or nil
    if not datas then return false end
    local hero = datas[index] 
    item = go:GetCmp(typeof(UITexture))
    item.color = user.ExistHero(hero.sn) and Color.New(0.5,0.5,0.5,1) or Color.New(0.5,0,0.5,1)  
    item:LoadTexAsync(ResName.HeroImage(hero.img))
    local rect = item.uvRect
    rect.x = HERO_X(hero.img)
    item.uvRect = rect
    go:GetCmp(typeof(LuaButton)):SetClick("ClickItem", hero)
    local lab = item:GetCmpInChilds(typeof(UILabel))
    lab.text = hero.nm
    lab.color = user.ExistHero(hero.sn) and lab.gradientTop or Color.New(0.5,0.5,0.5,1) 
    if view == 1 and hero.atlasAtt then 
        lab = item.transform:ChildWidget("att") or item:AddChild(lab.gameObject, "att"):GetCmp(typeof(UILabel))
        lab.transform.localPosition = Vector3(0, -180, 0)
        lab.text = GetAtlasAttDesc(hero.atlasAtt)
        lab.color = user.ExistHero(hero.sn) and Color.green or Color.New(0.5,0.5,0.5,1) 
    else 
        if item.transform:ChildWidget("att") then item.transform:ChildWidget("att").gameObject:Destroy() end
    end
    return true 
end

function _w.ClickSortTab(i)
    ChangeView(i)
end

function _w.ClickItem(h)
    print("hhhhhhhhhhhhhh    ",kjson.print(h))
    Win.Open("PopAtlasHeroInfo", h.sn)
end

--[Comment]
--名将谱
WinAtlas = _w