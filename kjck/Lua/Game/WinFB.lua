local _w = { }

local _body = nil 
local _ref = nil

--得到绑定的对象
local _item_fb = nil
local _item_goods = nil
local _item_tab = nil
local _leftTab = nil
local _scrollView = nil
local _fbInfo = nil
local _labVit = nil
local _btnAddVit = nil
local _title = nil
local _tipSD = nil
local _introduce = nil
local _rewardGrid = nil
local _btnFight = nil
local _btnSD = nil
local _btnSD10 = nil
local _btnSimple = nil
local _btnNormal = nil
local _toggleDiffs = nil

--脚本里的定义的对象

--战斗完返回到相应的副本上
--副本战斗前的所点击的城池sn，
local _battleSn = nil
--[Comment]
--储存上方tab
local _tabs = nil
--[Comment]
--上方标签页数
local _view = nil
--[Comment]
--城池数据
local _mDatas = nil
--[Commen]
--被选择的副本对象
local _selectItem = nil
--[Commen]
--被选择的副本数据
local _selectData = nil  
--[Commen]
--被选择的副本难度
local _selectDiff = nil  


--[Comment]
--更新上方tab
local function OnUpdateTabs()
    if _tabs == nil then
        local list,cList = {},{}
        for k,v in ipairs(user.pveCity) do
            if string.notEmpty(v.FbSpecial) then
                local idx = table.idxof(list,v.FbSpecial) or 0
                if idx <= 0 then
                    table.insert(list, v.FbSpecial)
                    idx = #list
                end
                if not cList[idx] then
                    cList[idx] = {}
                end
                table.insert(cList[idx], v)
            end
        end
        --战斗完返回到相应的副本上
        _view = _battleSn > 0 and table.idxof(list, user.GetPveCity(_battleSn).FbSpecial) or (_view == nil and 1 or _view)
        local cnt = #cList
        _mDatas = {}
        for i = 1, cnt do
            if cList[i][1] and not string.isEmpty(cList[i][1].fb) then
                table.insert(_mDatas, cList[i])
            end
        end
        _tabs = {}
        for i = 1, #_mDatas do
            local go = _leftTab:AddChild(_item_tab , string.format("tab_%02d",i))
            go:SetActive(true)
            go.luaBtn.text = _mDatas[i][1].FbSpecial
            go.luaBtn:SetClick("ClickSortTab" ,i)
            _tabs[i] = go
        end
        _leftTab.repositionNow = true
    end
end

--[Comment]
--生成对应的副本item
local function BuildItems(v)
    _scrollView:Reset()
    _scrollView.realCount = #_mDatas[v]
end

--[Comment]
--改变页签
local function ChangeView(v, force)
    print("ChangeView   ",v)
    if force == nil then force = false end
    if v == nil or v < 0 then v = 0 end
    if _view == v and not force then
        return
    end

    v = math.clamp( v, 1, #_mDatas + 1)
   _view = v
   for i=1,#_tabs do 
        _tabs[i].luaBtn.isEnabled = _view ~= i
        _tabs[i].luaBtn.label.color = _view ~= i and ColorStyle.GetTabColor(1) or ColorStyle.GetTabColor(0)
   end
   BuildItems(_view)
end

--[Comment]
--更新副本信息
local function RefreshData()
    SVR.GetLevelFB(function(r)
        if r.success then
            OnUpdateTabs()
            ChangeView(_view, true);
        end
    end)
end



--[Comment]
--对应的副本奖励介绍
local function LabIntroduce(spl)
    local t = "";
    if spl == L("经验") then
        t = L("通关有概率获得银币、经验药水等奖励")
    elseif spl == L("银币") then
        t = L("通关有概率获得银币等奖励")
    elseif spl == L("装备") then
        t = L("通关有概率获得银币、装备、装备碎片等奖励")
    end
    return t
end

--[Comment]
--更新所选择的对应副本的信息
local function UpdateItemInfo(dt)
    _selectData = dt
    _title.text = dt.FbSpecial.."·"..dt.db.nm
    _introduce.text = LabIntroduce(dt.FbSpecial)

    --设置难度勾选  可扫荡难度：dt.diffLv  已解锁难度:dt.fbDif
    for i = 1, #_toggleDiffs do
        local lock = _toggleDiffs[i]:ChildWidget("lock")
        if i <= dt.fbDif then
            lock:SetActive(false)
            _toggleDiffs[i].luaBtn.isEnabled = true
        else
            lock:SetActive(true)
            _toggleDiffs[i].luaBtn.isEnabled = false
        end
        if dt.diffLv == 0 then
            _toggleDiffs[1].value = true
        elseif i == dt.diffLv then
            _toggleDiffs[i].value = true
        end
    end
     for i = 1, #_toggleDiffs do
        if _toggleDiffs[i].value then
            _w.ClickToggle(i)
        end
    end
    
end

--[Comment]
--更新副本奖励和按钮  diff：勾选的难度
local function UpdateRewards(diff)
    local rws = {}
    _rewardGrid:DesAllChild()
    if diff == 1 then
        rws = _selectData.db.rwFB1
    elseif diff == 2 then
        rws = _selectData.db.rwFB2
    elseif diff == 3 then
        rws = _selectData.db.rwFB3
    end
    --奖励生成
    local ig
    for i = 1 ,#rws do
        ig = ItemGoods(_rewardGrid:AddChild(_item_goods, string.format("item_%02d", i), false))
        ig:Init(rws[i])
        if ig.dat then
            ig.go.luaBtn.luaContainer = _body
            ig.go.luaBtn:SetClick("ClickGoods")
            ig:HideName()
        else
            Destroy(ig.go)
        end
    end
    _rewardGrid.repositionNow = true

    --可扫荡
    if diff <= _selectData.diffLv then
        _btnSD.isEnabled = true
        _btnSD10.isEnabled = true
        _tipSD.text = L("")
    else    
        _btnSD.isEnabled = false
        _btnSD10.isEnabled = false
        _tipSD.text = L("需挑战一次当前难度")
    end
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.BG , n = L("副本") , r = DB_Rule.FB})
    _body = c
    c:BindFunction("OnInit","OnFocus","OnUnLoad","OnDispose","OnWrapGridInitItem",
                    "ClickSortTab", "ClickFBItem", "ClickToggle", "ClickGoods", "ClickAddVit",
                    "ClickFight", "ClickSD", "ClickClose")
    _ref = c.nsrf.ref

    _item_fb = _ref.item_fb  
    _item_goods = _ref.item_goods  
    _item_tab = _ref.item_tab  
    _leftTab = _ref.leftTab  
    _scrollView = _ref.scrollView  
    _fbInfo = _ref.fbInfo  
    _labVit = _ref.labVit  
    _btnAddVit = _ref.btnAddVit  
    _title = _ref.title  
    _tipSD = _ref.tipSD  
    _introduce = _ref.introduce  
    _rewardGrid = _ref.rewardGrid  
    _btnFight = _ref.btnFight  
    _btnSD = _ref.btnSD  
    _btnSD10 = _ref.btnSD10  
    _btnSimple = _ref.btnSimple  
    _btnNormal = _ref.btnNormal  
    _toggleDiffs = _ref.toggleDiffs  

end

function _w.OnInit()
    _battleSn = _w.initObj == nil and -1 or _w.initObj
    _labVit.text = user.vit
    _btnFight:SetClick("ClickFight")
    _btnSD:SetClick("ClickSD", 1)
    _btnSD10:SetClick("ClickSD", 10)
    for i = 1,#_toggleDiffs do
        _toggleDiffs[i].gameObject.luaBtn:SetClick("ClickToggle", i)
    end
    RefreshData()
end

function _w.OnFocus()
    
end

function _w.OnUnLoad(c)
    if _body ~= c then return end
    _body = nil
    _ref = nil
end

function _w.OnDispose()
    _leftTab:DesAllChild()	
    _scrollView:DesAllChild()	

    battleSn = nil
    _tabs = nil
    _view = nil
    _mDatas = nil
    _selectItem = nil
    _selectData = nil  
    _selectDiff = nil  
    AM.UnloadUnusedAsset()
end

--[Commen]
--生成对应的副本item
function _w.OnWrapGridInitItem(it, idx)
    print("titititiit 2222222222222  ")

    print("titititiit   ",it)
    print("idxidxidxidxidx   ",idx)
    if idx < 0 then return false end
    local data = _mDatas[_view][idx + 1]
    if not data then return false end
    local it_btn = it.luaBtn
    it_btn.text = data.db.nm
    it_btn:SetClick("ClickFBItem" , data)

    --战斗完返回到相应的副本上
    if _battleSn > 0 then
        if data.sn == _battleSn then
            _w.ClickFBItem(it,data)
            _battleSn = -1
        end
    elseif it ~= nil and idx == 0 then
        _w.ClickFBItem(it,data)
    end
    return true
end



--[Comment]
--页签点击事件
function _w.ClickSortTab(lb)
    ChangeView(lb)
end

--[Comment]
--点击对应副本item
function _w.ClickFBItem(ig,mef)
    if _selectItem == nil then
        _selectItem = ig
        _selectItem.luaBtn.isEnabled = false
    else
        _selectItem.luaBtn.isEnabled = true 
        ig.luaBtn.isEnabled = false
        _selectItem = ig
    end
    UpdateItemInfo(mef)
end

--[Comment]
--检测勾选的难度
function _w.ClickToggle(diff)
    _selectDiff = diff
    UpdateRewards(diff)
end

--[Comment]
--点击物品显示提示
function _w.ClickGoods(btn)
    print("点击物品显示提示点击物品显示提示")
    local ig = Item.Get(btn.gameObject)
    if ig then
        ig:ShowPropTip()
    end
end

--[Comment]
--点击增加体力
function _w.ClickAddVit()
    Win.Open("PopVIT")
end

--[Comment]
--挑战
function _w.ClickFight()
    local heros = nil
    Win.Open("PopSelectHero",{SelectHeroFor.Histroy,function(heros)
        if heros ~= nil then
            SVR.HistoryReady(_selectData.sn, _selectDiff, heros, function(res)
                if res.success then
                    Win.Open("WinBattle", SVR.datCache)
                end
            end)
        end
    end})
end

--[Comment]
--扫荡  opt:1扫荡一次  10扫荡10次
function _w.ClickSD(opt)
    if user.vit >= 10 * opt then
        SVR.FBSD(_selectData.sn, opt ,_selectDiff ,function(res)
            if res.success then
                _labVit.text = user.vit
            end
        end)
    else
        MsgBox.Show(L("主公，我们体力不够，是否需要前往获取"),L("取消")..L("确定"),function(idx)
            if idx == 1 then
                Win.Open("PopVIT")
            end
        end)
    end
end

--[Comment]
--副本
WinFB = _w