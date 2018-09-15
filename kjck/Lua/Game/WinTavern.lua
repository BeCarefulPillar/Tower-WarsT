local _w = { }

local _body = nil
local _ref = nil

--绑定组件
local _labTime = nil		
local _price = nil		   
local _labGood = nil		
local _btnRefresh = nil			
local _btnDrink = nil			
local _btnRecruit = nil			
local _btnAtlas = nil			
local _proGood	= nil		
local _plot = nil		   
local _leftRole = nil			
local _rightRole = nil			
local _bossRole = nil			
local _rightMain = nil			
local _rightDiInfo	= nil		
local _heroDetail = nil			
local _detailScroll= nil			
local _leftName = nil			
local _rightName = nil			
local _drinkPrice = nil			
local _recruitPrice = nil			
local _word = nil		   
local _arrow = nil		   
local _selectFrame	= nil		
local _odd = nil	   
local _skillGrid = nil			
local _item_goods = nil			
local _flagClan = nil			
local _spType = nil		
local _btnMask = nil
local _heros = 
{
    --[Comment]
    --根对象
    go = nil,
    name = nil,
    icon = nil,
    num = nil,
    star = nil,
}   
local _heroDetailInfo = nil
local _gridTex = nil
local _selectIdx = nil
--酒馆数据
local _tavernData = nil
local _update = nil

--对话数据
local _curDlgs = nil

--是否招募
local _isRecr = false

--是否是英雄
local function IsHero(i)
    if #_tavernData.item >= i then
        return _tavernData.item[i].rewards[1][1] == 4
    else    
        return false
    end
end



--[Comment]
--左边的图像控制  1:武将图片显示 _heroDetail  2: 将领详情显示 _rightMain
local function LeftPanelContrl(v)
    coroutine.start(function()
        if v == 1 then
            EF.Scale(_plot, 0.15, Vector3(0, 1, 1))
            EF.FadeOut(_heroDetail, 0.15)
            coroutine.wait(0.15)
            EF.Scale(_plot, 0.15, Vector3.one)
            EF.FadeIn(_rightMain, 0.15)
        elseif v == 2 then
            EF.Scale(_plot, 0.15, Vector3(0, 1, 1))
            EF.FadeOut(_rightMain, 0.15)
            coroutine.wait(0.15)
            EF.Scale(_plot, 0.15, Vector3.one)
            EF.FadeIn(_heroDetail, 0.15)
        end
    end)
    
end
--招募结果
local function OnRecruitResult()
    _isRecr = false
    _w.UpdateInfo()
    if IsHero(_selectIdx) then
        local hd= user.ExistHero(_tavernData.item[_selectIdx].rewards[1][2])
        print("OnRecruitResult  ",kjson.print(hd))
        if hd then
            _labGood.text = (hd.loyalty > 100 and 100 or hd.loyalty).."%"
            _proGood.value = hd.loyalty / 100
            _btnDrink.isEnabled = false
            _btnRecruit.isEnabled = false
            _btnRecruit.text = L("已招募")
            NewEffect.ShowNewHero(hd.db)
        else
            local good = math.floor(_tavernData.luck[_selectIdx] / 100)
            good = good > 100 and 100 or good
            _labGood.text = good .."%"
            _proGood.value = good / 100
            _btnRecruit.isEnabled = true
            if good < 100 then
                _btnDrink.isEnabled = true
            end
            ToolTip.ShowPopTip(ColorStyle.Bad(L("招募失败")))
        end
    end
end

--按钮显示
local function ShowBtn(show)
    _btnDrink:SetActive(show)
    _btnRecruit:SetActive(show)
    _drinkPrice:SetActive(show)
    _recruitPrice:SetActive(show)
    _arrow:SetActive(not show)
end

--显示对话内容
function _w.OnClick()
    if _curDlgs then
        local cnt = #_curDlgs
        if cnt > 0 then
            local dig = _curDlgs[1]
            table.remove(_curDlgs, 1)
            local lta = _leftRole:GetCmp(typeof(TweenAlpha))
            local rta = _rightRole:GetCmp(typeof(TweenAlpha))
            local rtp = _rightRole:GetCmp(typeof(TweenPosition))
            if string.find(dig, "N:") == 1 then
                lta:Play(true)
                rta:Play(false)
                rtp:Play(false)
            elseif string.find(dig, "P:") == 1 then

            end
            _word:TypeText( string.sub(dig, 3))
        end
        cnt = cnt - 1
        if cnt <= 0 then
            if _isRecr then
                OnRecruitResult()
            end
            _curDlgs = nil
            ShowBtn(true)
            _btnMask:SetActive(false)
        else
            _btnMask:SetActive(true)
        end
    end
end

--显示对话
local function ShowDialogue(c, thre)
    _curDlgs = { }
    local tp = Dialogue.dlg_type.tavern
    local cnt = 0
    local list = nil
    local digs = nil
    local rd = Mathf.Random
    local maxT = -1
    list = DB.AllDlg(tp, function (d) return d.c == c end)
    cnt = #list
    if cnt > 0 then
        for i = 1 , cnt do
            local t = list[i].t
            if thre >= t then
                if t > maxT then
                    digs = nil
                    digs = string.split(list[rd(1, cnt)].tx, "|")
                elseif t == maxT then
                    digs = string.split(list[rd(1, cnt)].tx, "|")
                end
            end
        end
        for i = 1, #digs do table.insert(_curDlgs, digs[i]) end
        cnt = #_curDlgs
        if cnt > 0 then
            if cnt > 1 then ShowBtn(false) end
            _w.OnClick()
        else 
            _curDlgs = nil
        end
    end
end

--显示武将介绍
local function HeroInfoShow()
    _skillGrid:DesAllChild()
    local dbsn = _tavernData.item[_selectIdx].rewards[1][2]
    if dbsn > 0 then
        local hs = DB.GetHero(dbsn)
        _heroDetailInfo[1].text = hs.nm
        _heroDetailInfo[2].text = L("类型:") .. number.ToCnString(hs.rare or 0) .. L("星") .. DB.kindNm[hs.kind];
        _heroDetailInfo[3].text = L("武力")..":" .. hs.str .. "     "..L("生命")..":" .. hs.hp .. "\n" ..
                                  L("智力")..":" .. hs.wis .. "     "..L("技力")..":" .. hs.sp .. "\n" ..
                                  L("统帅")..":" .. hs.cap .. "     "..L("兵力")..":" .. hs.tp;

        _heroDetailInfo[4].text = L("历史:") .. hs.i
        _detailScroll:ConstraintPivot(UIWidget.Pivot.Top, true)
        _detailScroll.enabled = _heroDetailInfo[4].localSize.y > 126

        local len = #hs.skc
         for i = 1, len do
            local go = _skillGrid:AddChild(_item_goods, "skc_"..i)
            local it = ItemGoods(go)
            local skcDat = DB.GetSkc(hs.skc[i])
            it:Init(skcDat, true)
            it.go.luaBtn.luaContainer = _body
            go.transform.localScale = Vector3.one * 0.6
        end
    
        _skillGrid.repositionNow = true
        _flagClan.spriteName = "hero_clan_" .. hs.clan
        _spType.spriteName = "hero_kind_" .. hs.kind 
    end
    
end

--角色移动开关
local function RoleSwitch(waitTm)
    print("RoleSwitchRoleSwitch  ",waitTm)
    if waitTm then
        coroutine.wait(waitTm)
    end
    local hdb = DB.GetHero(_tavernData.item[_selectIdx].rewards[1][2])
    _leftRole:LoadTexAsync(ResName.HeroImage(hdb.img))

    local rect = _leftRole.uvRect
    rect.x = HERO_X(hdb.img) * 0.5
    _leftRole.uvRect = rect

    _leftName.text = L("资质:")..hdb.aptitude
    _rightDiInfo:GetCmpInChilds(typeof(UIRepeat)).TotalCount = hdb.rare
    _leftRole.alpha = 0
    _rightRole.alpha = 0
    _rightName.text = user.nick
    _flagClan.spriteName = "hero_clan_" .. hdb.clan
    _spType.spriteName = "hero_kind_" .. hdb.kind

    local hd = user.ExistHero(hdb.sn)
    if hd ~= nil then
        ShowDialogue(5, hd.loyalty)
    else
        ShowDialogue(1, math.floor(_tavernData.luck[_selectIdx] / 100))
    end
end


--更新数据
function _w.UpdateInfo(init)
    init = init and init or false
    for i = 1 , #_tavernData.item do
        _heros[i].go.isEnabled = true
        local reward = _tavernData.item[i].rewards[1]
        local it = ItemGoods(_heros[i].go.gameObject)
        it:Init(reward)

        --刷到将领
        if reward[1] == 4 then
            local dbsn = reward[2]
            if dbsn > 0 then
                _heros[i].go:SetActive(true)
                local hdb = DB.GetHero(dbsn)
                _gridTex:Add(_heros[i].go:GetCmp(typeof(UITexture)))
--                _heros[i].name = hdb.nm
                _heros[i].star:SetActive(true)
                _heros[i].star.TotalCount = hdb.rare
                _heros[i].num.text = ""
                if _selectIdx == i then
                    _flagClan.spriteName = "hero_clan_" .. hdb.clan
                    _spType.spriteName = "hero_kind_" .. hdb.kind
                end
                local exist = _heros[i].go.transform:FindChild("exist")
                if user.ExistHero(dbsn) then
                    if exist == nil then
                        local sp = _heros[i].go.gameObject:AddWidget(typeof(UISprite),"exist")
                        sp.atlas = AM.mainAtlas
                        sp.spriteName = "sp_recruit"
                        sp.depth = 9
                        sp.width = 44
                        sp.height = 44
                        sp.cachedTransform.localPosition = Vector3(-24, 24, 0)
                    end
                elseif exist then
                    Destroy(exist)
                end
            else
                _heros[i].go:SetActive(false)
            end
        else
            --刷到道具
            _heros[i].star:SetActive(false)
            local exist = _heros[i].go.transform:FindChild("exist")
            print("exist exist   ", exist)
            if exist then Destroy(exist.gameObject) end
            if _tavernData.luck[i] < 0 then
                local sp = _heros[i].go.gameObject:AddWidget(typeof(UISprite),"exist")
                sp.atlas = AM.mainAtlas
                sp.spriteName = "sp_tag_buy"
                sp.depth = 9
                sp.width = 44
                sp.height = 44
                sp.cachedTransform.localPosition = Vector3(-24, 24, 0)
            end
        end
    end
    

end

--选择item
local function SelectItem(index)
    print("IsHero(index)    ",IsHero(index))
    _selectIdx = index
    if IsHero(index) then
        local itDat = _tavernData.item[index]
        local dbsn = itDat.rewards[1][2]
        if dbsn > 0 then
            _selectIdx = index
            _btnRecruit.text = L("招 募")
            _btnDrink:SetActive(true)
            _drinkPrice:SetActive(true)
            if itDat.luckPrice[1] ~= 0 then
                _drinkPrice.text = itDat.luckPrice[1]
                _drinkPrice:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_silver"
            elseif itDat.luckPrice[2] ~= 0 then
                _drinkPrice.text = itDat.luckPrice[2]
                _drinkPrice:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_gold"
            elseif itDat.luckPrice[3] ~= 0 then
                _drinkPrice.text = itDat.luckPrice[3]
                _drinkPrice:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_diamond"
            else
                _drinkPrice.text = "0"
            end

            _plot:SetActive(true)
            if _bossRole.cachedTransform.localPosition.x < 500 then
                _bossRole:GetCmp(typeof(TweenAlpha)):PlayReverse()
                _bossRole:GetCmp(typeof(TweenPosition)):PlayReverse()
            end

            if _plot.transform.localPosition.x > 1155 then
                _plot:GetCmp(typeof(TweenPosition)):PlayForward()
            end

            if _leftRole.cachedTransform.localPosition.x < 1155 then
                if _leftRole.gameObject.activeInHierarchy then
                    _leftRole:GetCmp(typeof(TweenAlpha)):Play(false)
                    coroutine.start(RoleSwitch,0.3)
                else
                    coroutine.start(RoleSwitch)
                end
                HeroInfoShow()
            else
                coroutine.start(RoleSwitch)
            end

            local hd = user.ExistHero(dbsn)
            if hd then
                _odd.text = L("成功率：")
                _labGood.text = hd.loyalty > 100 and 100 or hd.loyalty .. "%"
                _proGood.value = hd.loyalty / 100
                _btnDrink.isEnabled = false
                _btnRecruit.isEnabled = false
                _btnRecruit.text = L("已招募")
            else
                local good = math.floor(_tavernData.luck[index] / 100)
                good = good > 100 and 100 or good
                _labGood.text = good .. "%"
                _proGood.value = good / 100
                _odd.text = L("成功率：")
                if good < 100 then
                    _btnDrink.isEnabled = true
                end
                _btnRecruit.isEnabled = true
                _btnRecruit.text = L("招 募")
            end
        else
            _selectIdx = -1
            _labGood.text = "-/-"
            _proGood.value = 1
            _odd.text = L("成功率:")
            _selectFrame:SetActive(false)
            _plot:SetActive(false)
            _leftName.text = ""
            _rightName.text = ""
            _word:TypeText("")
            _leftRole:GetCmp(typeof(TweenAlpha)).ResetToInit()
            _rightRole:GetCmp(typeof(TweenAlpha)).ResetToInit()
            _rightRole:GetCmp(typeof(TweenPosition)).ResetToInit()
        end
    else
        if _bossRole.cachedTransform.localPosition.x > 1155 then
            _bossRole:GetCmp(typeof(TweenAlpha)):PlayForward()
            _bossRole:GetCmp(typeof(TweenPosition)):PlayForward()
        end
        if _plot.transform.localPosition.x < 500 then
            _plot:GetCmp(typeof(TweenPosition)):PlayReverse()
        end
        _bossRole:SetActive(true)
        _leftRole:GetCmp(typeof(TweenAlpha)):PlayReverse()
        _btnRecruit.text = L("购 买")
        _btnDrink:SetActive(false)
        _drinkPrice:SetActive(false)
    end

    _selectIdx = index
    _selectFrame.transform.parent = _heros[index].go.transform
    _selectFrame.transform.localPosition = Vector3(0, -16, 0)
    _selectFrame.transform.localScale = Vector3.one
    _selectFrame:SetActive(true)

    if _tavernData.luck[_selectIdx] >= 0 then
        if not IsHero(_selectIdx) then
            _btnRecruit.isEnabled = true
        end
    else
        _btnRecruit.isEnabled = false
        _btnDrink.isEnabled = false
    end

    --设定购买价格和币种
    _recruitPrice:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_silver"
    _recruitPrice.text = "0"
    local ty = 0
    local price = 0
    if _tavernData.item[_selectIdx].price[1] ~= 0 then
        ty = 1
        price = _tavernData.item[_selectIdx].price[1]
    elseif _tavernData.item[_selectIdx].price[2] ~= 0 then
        ty = 2
        price = _tavernData.item[_selectIdx].price[2]
    elseif _tavernData.item[_selectIdx].price[3] ~= 0 then
        ty = 3
        price = _tavernData.item[_selectIdx].price[3]
    end
    if ty == 1 then
        _recruitPrice:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_silver"
    elseif ty == 2 then
        _recruitPrice:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_gold"
    elseif ty == 3 then
        _recruitPrice:GetCmpInChilds(typeof(UISprite)).spriteName = "sp_diamond"
    end
    _recruitPrice.text = tostring(price)
end

--酒馆信息
--S_Tavern结构数据
local function OnTavernInfo(d)
    _tavernData = d

    user.IsTavernRefresh = false
    _w.UpdateInfo(true)
    SelectItem(_selectIdx)

    _rightRole:LoadTexAsync(ResName.PlayerRole(user.role))

end

local function Updata()
    if user.tvrnTm.time > 0 then
        _labTime.text = L("自动刷新")..TimeClock.TimeToString(user.tvrnTm.time)
    else
--        SVR.Tavern("inf",function(res)
--            if res.success then
--                OnTavernInfo(SVR.datCache)
--            end
--        end)
--        user.tavernHero = nil
    end
end
function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.BG , n = L("酒馆") ,i = true ,r = DB_Rule.Tavern})
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad",
                    "ClickAtlas","ClickHero","ClickItemGoods","ClickHeroImg","ClickHeroDetail",
                    "ClickRefresh","ClickDrink","ClickRecruit","OnClick")
    _ref = c.nsrf.ref

    _labTime = _ref.labTime
    _price = _ref.price
    _labGood = _ref.labGood
    _btnRefresh = _ref.btnRefresh
    _btnDrink = _ref.btnDrink
    _btnRecruit = _ref.btnRecruit
    _btnAtlas = _ref.btnAtlas
    _proGood = _ref.proGood
    _plot = _ref.plot
    _leftRole = _ref.leftRole
    _rightRole = _ref.rightRole
    _bossRole = _ref.bossRole
    _rightMain = _ref.rightMain
    _rightDiInfo = _ref.rightDiInfo
    _heroDetail = _ref.heroDetail
    _detailScroll = _ref.detailScroll
    _leftName = _ref.leftName
    _rightName = _ref.rightName
    _drinkPrice = _ref.drinkPrice
    _recruitPrice = _ref.recruitPrice
    _word = _ref.word
    _arrow = _ref.arrow
    _selectFrame = _ref.selectFrame
    _odd = _ref.odd
    _skillGrid = _ref.skillGrid
    _item_goods = _ref.item_goods
    _flagClan = _ref.flagClan
    _spType = _ref.spType
    _heroDetailInfo = _ref.heroDetailInfo
    _btnMask = _ref.btnMask
    local temp = _ref.heros
    for i = 1 , #temp do
        _heros[i] = {}
        _heros[i].go = temp[i]
        _heros[i].name = temp[i]:ChildWidget("name")
        _heros[i].icon = temp[i]:ChildWidget("icon")
        _heros[i].num = temp[i]:ChildWidget("num")
        _heros[i].star = temp[i]:ChildWidget("star")
        _heros[i].go:SetClick("ClickHero", i)
    end
    

end

function _w.OnInit() 
    if _gridTex == nil then _gridTex = GridTexture(128, 32) end
    _selectIdx = 1
    SVR.Tavern("inf",function(res)
        if res.success then
            OnTavernInfo(SVR.datCache)
        end
    end)
    _update = UpdateBeat:CreateListener(Updata)
    UpdateBeat:AddListener(_update)
end

function _w.OnDispose()
    if _gridTex then
        _gridTex:Dispose()
        _gridTex = nil
    end
    UpdateBeat:Remove(_update)
    _update = nil
end

function _w.OnUnLoad(c)
end

--点击名将谱
function _w.ClickAtlas()
    Win.Open("WinAtlas")
end

--点击将领
function _w.ClickHero(i)
    print("点击将领  ",i)
    if _selectIdx ~= i then
        SelectItem(i)
    end
end

--点击技能
function _w.ClickItemGoods(bt)
    local ig = Item.Get(bt.gameObject)
    if ig then
        ig:ShowPropTip()
    end
end

--点击左边的将领图像
function _w.ClickHeroImg()
    LeftPanelContrl(2)
end

--点击左边的将领详情界面
function _w.ClickHeroDetail()
    LeftPanelContrl(1)
end

--刷新
function _w.ClickRefresh()
    for i = 1 ,#_heros do
        if IsHero(i) then
            local  dbsn = _tavernData.item[i].rewards[1][2]
            if DB.GetHero(dbsn).rare > 4 and user.ExistHero(dbsn) == nil then
                MsgBox.Show(L("主公，酒馆中有未招募的五星将！确定要刷新吗？"),L("取消")..","..L("确定"), function(idx)
                    if idx == 1 then
                        LeftPanelContrl(1)
                        SVR.Tavern("ref",function(res)
                            if res.success then
                                OnTavernInfo(SVR.datCache)

                            end
                        end)
                    end
                end)
                return
            end
        end
    end
    LeftPanelContrl(1)
    SVR.Tavern("ref",function(res)
        if res.success then
            for j = 1 ,#_heros do
                _heros[j].go.gameObject:AddChild(AM.LoadPrefab("ef_ui_jiuguanshuaxin"), "ef_ui_jiuguanshuaxin")
            end
            OnTavernInfo(SVR.datCache)
        end
    end)
end

--喝酒
function _w.ClickDrink()
    if _selectIdx < 0 or _selectIdx > 3 then
        return
    end
    local ty = 0
    if _tavernData.item[_selectIdx].luckPrice[1] ~= 0 then
        ty = 1
    elseif _tavernData.item[_selectIdx].luckPrice[2] ~= 0 then
        ty = 2
    elseif _tavernData.item[_selectIdx].luckPrice[3] ~= 0 then
        ty = 3
    end
    local opt = "luk|".._selectIdx.."|"..ty
    SVR.Tavern(opt,function(res)
        if res.success then
            _tavernData = SVR.datCache
            local hd = user.ExistHero(_tavernData.item[_selectIdx].rewards[1][2])
            local ef = _proGood.gameObject:AddChild(AM.LoadPrefab("ef_hero_up5"),"ef_hero_up")
            ef.transform.localPosition = Vector3(125, 25 ,0)
            if hd then
                _labGood.text =(hd.loyalty > 100 and 100 or hd.loyalty) .."%"
                _proGood.value = hd.loyalty / 100
                ShowDialogue(6 ,hd.loyalty)
            else
                local good = math.floor( _tavernData.luck[_selectIdx] / 100)
                good = good > 100 and 100 or good
                _odd.text = L("成功率:")
                _labGood.text = good .. "%"
                _proGood.value = good / 100
                ShowDialogue(2, good)
            end
            _w.UpdateInfo()
        end
    end)
end

--招募
local function Recruit()
    if _selectIdx < 0 or _selectIdx > 3 then
        return
    end
    local ty = 0
    if _tavernData.item[_selectIdx].price[1] ~= 0 then
        ty = 1
    elseif _tavernData.item[_selectIdx].price[2] ~= 0 then
        ty = 2
    elseif _tavernData.item[_selectIdx].price[3] ~= 0 then
        ty = 3
    end
    local opt = "buy|".._selectIdx.."|"..ty
    SVR.Tavern(opt,function(res)
        if res.success then
            _isRecr = true
            _btnRecruit.isEnabled = false
            _btnDrink.isEnabled = false
            _tavernData = SVR.datCache
            if IsHero(_selectIdx) then
                local hd = user.ExistHero(_tavernData.item[_selectIdx].rewards[1][2])
                if hd then
                    ShowDialogue(4,0)
                else
                    ShowDialogue(3,0)
                end
            else
                PopRewardShow.Show(_tavernData.item[_selectIdx].rewards)
                _w.UpdateInfo(false)
                _isRecr = false
            end
        end
    end)
end
function _w.ClickRecruit()
    if _selectIdx < 0 or _selectIdx > 3 then
        return
    end
    if IsHero(_selectIdx) then
        if _tavernData.luck[_selectIdx] / 100 > 50 then
            Recruit()
        else
            MsgBox.Show(L("主公，直接招募很容易失败。先请对方喝酒提高好感度来增加招募的成功率。"),L("取消")..","..L("喝酒")..","..L("直接招募"),function(idx)
                if idx == 1 then
                    _w.ClickDrink()
                elseif idx == 2 then
                    Recruit()
                end
            end)
        end
    else
        Recruit()
    end
end

--[Comment]
--酒馆
WinTavern = _w