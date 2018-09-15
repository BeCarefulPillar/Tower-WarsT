local _w = { }

--[Comment]
--页签
local _view = nil
--[Comment]
--展示的将领在heros中的索引
local _curIdx = nil
--[Comment]
--储存所有武将信息
local _heros = nil
--[Comment]
--展示的武将的PY数据
local _cur = nil

--[Comment]
--选择的数据
local _sltDat = nil
--[Comment]
--选择的对象
local _sltItem = nil
--[Comment]
--选择的装备类型
local _sltEqpKind = nil
--[Comment]
--数据
local _dats = nil

--[Comment]
--储存道具item
local _propItems = {}
--[Comment]
--储存技能item
local _skcItems = {}
--[Comment]
--储存兵种item
local _sldItems = {}
--[Comment]
--储存阵形item
local _lnpItems = {}

--[Comment]
--储存图片 GridTextrue
local _gridTex = nil

--[Comment]
--所有页签集合  1=将领信息 2=技能 3=兵种 4=阵形 5=装备
local _tabs = nil


--[Comment]
--将领信息面板
local _pnlHeroInfo = nil
--[Comment]
--技能面板
local _pnlSkill = nil
--[Comment]
--兵种面板
local _pnlSoldier = nil
--[Comment]
--阵形面板
local _pnlLnp = nil
--[Comment]
--装备面板
local _pnlEqp = nil

--[Comment]
--物品item
local _item_goods = nil
--[Comment]
--左边的panel
local _pnlLeft = nil

--[Comment]
--左边的图像控制   1:武将介绍显示  2:武将图片显示  3:装备详情
local function LeftPanelContrl(v)
    if v == 1 then
        EF.Scale(_pnlLeft.heroUtx, 0.2, Vector3(0, 1, 1))
        EF.FadeOut(_pnlLeft.heroUtx, 0.2)

        EF.Scale(_pnlLeft.heroStory, 0.2, Vector3.one)
        EF.FadeIn(_pnlLeft.heroStory, 0.2)

        EF.Scale(_pnlLeft.infoEquip, 0.2, Vector3(0, 1, 1))
        EF.FadeOut(_pnlLeft.infoEquip, 0.2)
    elseif v == 2 then
        EF.Scale(_pnlLeft.heroUtx, 0.2, Vector3.one)
        EF.FadeIn(_pnlLeft.heroUtx, 0.2)

        EF.Scale(_pnlLeft.heroStory, 0.2, Vector3(0, 1, 1))
        EF.FadeOut(_pnlLeft.heroStory, 0.2)

        EF.Scale(_pnlLeft.infoEquip, 0.2, Vector3(0, 1, 1))
        EF.FadeOut(_pnlLeft.infoEquip, 0.2)
    else
        EF.Scale(_pnlLeft.heroUtx, 0.2, Vector3(0, 1, 1))
        EF.FadeOut(_pnlLeft.heroUtx, 0.2)

        EF.Scale(_pnlLeft.heroStory, 0.2, Vector3(0, 1, 1))
        EF.FadeOut(_pnlLeft.heroStory, 0.2)

        EF.Scale(_pnlLeft.infoEquip, 0.2, Vector3.one)
        EF.FadeIn(_pnlLeft.infoEquip, 0.2)
    end
end

--[Comment]
--检测选择
local function CheckSelect(ig)
    if ig == nil then return end
    print("检测选择检测选择 ig  ",ig)
    print("检测选择检测选择 _sltDat  ",_sltDat)
    if ig.dat and ig.dat == _sltDat then
        print("检测选择检测选择   ",ig.dat.nm)
        _sltItem = ig
        ig.Selected = true
    else
        ig.Selected = false
    end
end

--退出选择或切换页签时 清空选择数据
local function ExitAllInfoPanel()
    if _sltDat then
        if objis(_sltDat, DataCell) then _sltDat:RemoveObserver(_w) end
        _sltDat = DataCell.DataChange(_sltDat, nil, _w)
    end
    if _sltItem then
        _sltItem.Selected = false
        _sltItem = nil
    end
end

--[Comment]
--显示左边的信息
local function ShowLeftInfo()
     --加载图片
    _pnlLeft.heroUtxMesh:LoadTexAsync(ResName.HeroImage(_cur.img));
    _pnlLeft.heroStars.TotalCount = _cur.rare
    _pnlLeft.skt.text = DB.GetSkt(_cur.db.skt).nm
    _pnlLeft.sktInfo.text = DB.GetSkt(_cur.db.skt).i

    --专属
    _pnlLeft.exclTip:SetActive(DB.GetExclEquip(_cur.dbsn) ~= nil)
    if DB.GetExclEquip(_cur.dbsn) ~= nil then
        if _cur:GetExclEquip() ~= nil and _cur:GetExclEquip().ExclActive then
            _pnlLeft.exclTipEf:SetActive(true)
        else
            _pnlLeft.exclTipEf:SetActive(false)
        end
    end

    --武将详情
    _pnlLeft.storyName.text = _cur.db.nm
    _pnlLeft.storyType.text = L("类型:")..number.ToCnString(_cur.db.rare)..L("星")..DB_Hero.GetKindName(_cur.db.kind)
    _pnlLeft.storyInfo.text = _cur.db.i

end

--[Comment]
--展示武将信息  0
local function ShowHeroInfo()
    if _cur then
        _pnlHeroInfo.name.text = _cur:getName()
        _pnlHeroInfo.qualify.text = L("资质:".. _cur.aptitude)
        _pnlHeroInfo.clan.text = DB.GetNatName(_cur.clan)
        _pnlHeroInfo.lv.text = L("lv:").._cur.lv
        _pnlHeroInfo.kind.text = DB.GetAttName(_cur.kind)..L("型")
        _pnlHeroInfo.heroTitle.text = LN(DB.GetHeroTtl(_cur.ttl).nm).."(".._cur.ttl..")" 
        _pnlHeroInfo.hp.text = _cur.MaxHP
        _pnlHeroInfo.sp.text = _cur.MaxSP
        _pnlHeroInfo.tp.text = _cur.MaxTP
        _pnlHeroInfo.str.text = _cur.str
        _pnlHeroInfo.wis.text = _cur.wis
        _pnlHeroInfo.cap.text = _cur.cap
        _pnlHeroInfo.exp.text = _cur.LvExp .. "/" .. _cur.MaxLvExp
        _pnlHeroInfo.sliderExp.value = _cur.PercentExp

       

        --武将晋升
        if _cur.ttl < DB.maxHeroTtl then
            local var = _cur.CanPromotion
            _pnlHeroInfo.btnTtl.isEnabled = var
--            _pnlHeroInfo.btnTtl:Child("ef_frame"):SetActive(var)

            _pnlHeroInfo.labTtl.text = _cur.TtlMerit .. "/" .. _cur.MaxTtlMerit
            _pnlHeroInfo.sliderTtl.value = _cur.PercentMerit
            _pnlHeroInfo.heroTitleTip:SetActive(false)
            _pnlHeroInfo.btnTtl:SetActive(true)
        else
            _pnlHeroInfo.labTtl.text = tostring(_cur.TtlMerit)
            _pnlHeroInfo.sliderTtl.value = 1
            _pnlHeroInfo.heroTitleTip:SetActive(true)
            _pnlHeroInfo.btnTtl:SetActive(false)
        end

        --将星
        if _cur.IsStarHero then
            _pnlHeroInfo.spStar.spriteName = "hero_star_"..DB_HeroStar.GetStar(_cur.star)
            _pnlHeroInfo.spStar:SetActive(true)
            _pnlHeroInfo.spStar:Child(0):SetActive(DB_HeroStar.GetStar(_cur.star) > 0)
            
        else
            _pnlHeroInfo.spStar.spriteName = ""
            _pnlHeroInfo.spStar:SetActive(false)
        end 

        --武将觉醒
        local sqty = user.GetSoulQty(_cur.dbsn)
        if _cur.rare < DB.param.rareHeroEvo then
            _pnlHeroInfo.sliderSoul:SetActive(false)
            _pnlHeroInfo.soul.text = "-/-"
        elseif _cur.evo < DB.maxHeroEvo then
            local eSoul, eLv, eProp, eCost = DB.GetHeroEvo(_cur.rare, _cur.evo)
            _pnlHeroInfo.btnSoul:SetActive(true)
            _pnlHeroInfo.sliderSoul:SetActive(true)
            _pnlHeroInfo.sliderSoul.value = sqty / eSoul
            _pnlHeroInfo.soul.text = sqty .."/".. eSoul
            if _cur.lv < eLv then
                _pnlHeroInfo.btnSoul:Child("ef_frame"):SetActive(false)
            elseif sqty < eSoul then
                _pnlHeroInfo.btnSoul:Child("ef_frame"):SetActive(false)
            else
--                _pnlHeroInfo.btnSoul:Child("ef_frame"):SetActive(true)
            end
        else
            _pnlHeroInfo.btnSoul:SetActive(false)
            _pnlHeroInfo.sliderSoul:SetActive(true)
            _pnlHeroInfo.sliderSoul.value = 1
            _pnlHeroInfo.soul.text = tostring(sqty)
        end

        --生成道具
        _dats = user.GetProps(function(p) 
        return p.sn == DB_Props.XIAO_JING_YANDAN or  
                p.sn == DB_Props.DA_JING_YAN_DAN or  
                p.sn == DB_Props.CHAO_JI_JING_YAN_DAN
        end)

        if _pnlHeroInfo.gridProps.transform.childCount < 1 then
            for i = 1 , #_dats do
                local go = _pnlHeroInfo.gridProps:AddChild(_item_goods,"good_"..i)
                local it = ItemGoods(go)
                it:Init(_dats[i])
                ItemGoods.ShowName(it)
                it.name.transform.localPosition = Vector3(0,-60,0)
                _gridTex:Add(it.imgl)
                it.name.text= _dats[i].ti.."+".._dats[i].val
                it.name.color = ColorStyle.GetRareColor(_dats[i].rare)
                it.go.luaBtn.luaContainer = _body
                it.go.luaBtn:SetClick("ClickPropsUse",it)
                _propItems[i] = it
            end
        else
            if _propItems then
                for i = 1, #_propItems do
                    _propItems[i].name.text = _dats[i].ti.."+".._dats[i].val
                    _propItems[i].name.color = ColorStyle.GetRareColor(_dats[i].rare)
                end
            end
        end

        _pnlHeroInfo.go:SetActive(true)
    end
end

--[Comment]
--显示技能面板  1
local function ShowSkillPanel()
    local var = _cur.db.skc
    local qty = var and #var or 0
    local go = nil
    local it = nil
    local selIt = nil
    --将领技
    for i = 1 ,qty do
        go = _skcItems[i]
        it = go and Item.Get(go)
        if it == nil then
            go = _pnlSkill.skcGrid:AddChild(_item_goods,"skill_"..i)
            it = ItemGoods(go)
            _skcItems[i] = go
            go.luaBtn.luaContainer = _body
		    go:SetActive(true)
        end
        it:Init(DB.GetSkc(var[i]), _cur:SkcAvailable(var[i]), 0, _cur:GetCurFe(var[i]))
        _gridTex:Add(it.imgl)
        ItemGoods.ShowName(it)
        it.name.transform.localPosition = Vector3(0,-71,0)
        CheckSelect(it)
        if i == 1 then
            selIt = go
        end
    end
    if qty <#_skcItems then
        for i = qty + 1, #_skcItems do if notnull(_skcItems[i]) then _skcItems[i]:SetActive(false) end end
    end
    _pnlSkill.skcGrid:GetCmp(typeof(UIGrid)).repositionNow = true


    --觉醒技
    go = _skcItems.ske
    var = DB.GetSke(_cur.db.ske)
    if var.sn > 0 then
        it = Item.Get(go)
        if it == nil then
            go = _pnlSkill.skeGrid:AddChild(_item_goods, "skill_1")
            it = ItemGoods(go)
            _skcItems.ske = go
            go.luaBtn.luaContainer = _body
        end
        it:Init(var, _cur.evo > 0, _cur.evo)
        ItemGoods.ShowName(it)
        it.name.transform.localPosition = Vector3(0,-71,0)
        _gridTex:Add(it.imgl)
        CheckSelect(it)
        go:SetActive(true)
    elseif notnull(go) then
        go:SetActive(false)
    end
    

    --战法
    go = _skcItems.skp
	it = Item.Get(go)
	if it == nil then
		go = _pnlSkill.skeGrid:AddChild(_item_goods,"skill_2")
        it = ItemGoods(go)
        _skcItems.skp = go
        go.luaBtn.luaContainer = _body
		go:SetActive(true)
	end
    var = DB.GetSkp(_cur.skp)
    print("varvar  ",kjson.print(var))
    it:Init(var,_cur.lv >= DB.unlock.skp, var.sn > 0 and _cur:GetSkpLv(var.sn) or 0)
    if var.sn == 0 then it.name.text = "" end
    ItemGoods.ShowName(it)
    it.name.transform.localPosition = Vector3(0,-71,0)
    _gridTex:Add(it.imgl)
    CheckSelect(it)
    _pnlSkill.skeGrid:GetCmp(typeof(UIGrid)).repositionNow = true 
    _w.ClickItemGoods(selIt)
    _pnlSkill.go:SetActive(true)
end

--[Comment]
--显示技能信息  1
local function ShowSkillInfo()
    if _sltDat ~= nil then
        _pnlSkill.skillName.text = _sltDat.nm
        local var = objt(_sltDat)
        if var == DB_SKC then
            local needLv = _cur:SkcNeedLv(_sltDat.sn)
            local ava = needLv > 0 and _cur.lv >= needLv
            _pnlSkill.skillStatus.text = ava and string.format(L("技能消耗:%s"),_sltDat:GetCost()) or
                                        string.format(L("激活状态:[FF0000]未激活[-]          激活等级:[FF0000]%s          [-]技能消耗:%s"),needLv,_sltDat:GetCost())
            _pnlSkill.skillDesc.text = _sltDat.i
            _pnlSkill.btnOpt:SetActive(false)
        elseif var == DB_SKE then
            if _cur.evo > 0 then
                _pnlSkill.skillStatus.text = string.format(L("技能等级:%s          作用对象:自身"), _cur.evo)
                _pnlSkill.skillDesc.text = _sltDat:getIntro(_cur.evo)
            else
                _pnlSkill.skillStatus.text = string.format(L("激活状态:[FF0000]未激活[-]          激活条件:[FF0000]觉醒[-]          作用对象:自身"))
                _pnlSkill.skillDesc.text = _sltDat:getIntro()
            end
            _pnlSkill.btnOpt:SetActive(false)
        elseif var == DB_SKP then
            if _sltDat.sn > 0 then
                local lv = _cur:GetSkpLv(_sltDat.sn)
                _pnlSkill.skillName.text = _sltDat:getName()
                _pnlSkill.skillStatus.text = L("当前等级: ")..lv
                _pnlSkill.skillDesc.text = _sltDat:getIntro(lv)
            elseif _cur.lv < DB.unlock.skp then 
                _pnlSkill.skillName.text = L("未解锁")
                _pnlSkill.skillStatus.text = L("解锁等级: ").."[FF0000]"..DB.unlock.skp.."[-]"
                _pnlSkill.skillDesc.text = string.format(L("将领%s级可解锁战法"),DB.unlock.skp)
            else
                _pnlSkill.skillName.text = L("不使用战法")
                _pnlSkill.skillStatus.text = ""
                _pnlSkill.skillDesc.text = L("点击详情可选择、学习、升级战法")
            end
            _pnlSkill.btnOpt.text = L("详 情")
            _pnlSkill.btnOpt:SetActive(_cur.lv >= DB.unlock.skp)
        end
    end

end

--[Comment]
--显示兵种面板  2
local function ShowSoldierPanel()
    print("显示兵种面板   " , kjson.print(_dats))
    local var = _dats
    local qty = var and #var or 0
    local go = nil
    local it = nil
    local selIt = nil
    --生成兵种
    for i = 1 ,qty do
        go = _sldItems[i]
        it = go and Item.Get(go)
        if it == nil then
            go = _pnlSoldier.sldGrid:AddChild(_item_goods,"sld_"..i)
            it = ItemGoods(go)
            _sldItems[i] = go
            _sldItems[go] = it
            go.luaBtn.luaContainer = _body
		    go:SetActive(true)
        end
        local sn = var[i].sn
        if sn > 0 then
            it:Init(var[i], sn > 0, _cur.arm == sn, _cur.lv >= DB.ArmUL(sn), _cur:GetArmLv(sn))
            ItemGoods.ShowName(it)
        else
            it:Init(var[i])
            ItemGoods.ShowName(it)
            local idx = math.clamp(math.abs(sn), 1, DB.maxArmQty - 1)
            local needlv = DB.ArmUL(idx)
            local canL1 = _cur.lv >= needlv
            local canL2 = true
            for j = 1 , #_sldItems do
                local g = _sldItems[j]
                local d = _sldItems[g].dat
                if var[i] == d and j > 1 then
                    g = _sldItems[j - 1]
                    d = _sldItems[g].dat
                    if sn < 0 and d.sn < 0 then
                        canL2 = false
                    end
                    break
                end
            end
            it.name.text = (canL1 and canL2) and L("[32d932]可学习[-]") or L("[e93434]不可学[-]")
        end
        if _cur.arm == sn then
            _w.ClickItemGoods(go)
        end
        _gridTex:Add(it.imgl)
        CheckSelect(it)
    end
    _pnlSoldier.sldGrid:GetCmp(typeof(UIGrid)).repositionNow = true
    _pnlSoldier.btnReset.isEnabled = #_cur.armLst > 1
    _pnlSoldier.resetCost.text = tostring(DB.param.prResetAL)
    _pnlSoldier.resetCost:SetActive(true)
    _pnlSoldier.go:SetActive(true)
end

--[Comment]
--显示兵种信息  2
local function ShowSoldierInfo()
    if objt(_sltDat) == DB_Arm then
        if _sltDat.sn > 0 then
            --分离克制和被克制
            local sup = {}
            table.copy(_sltDat.sup ,sup)
            table.remove(sup,1)
            local bsup = {}
            if sup ~= nil then
                for i = 1, DB.maxArmQty  do
                    if i ~= _sltDat.sn then
                        if table.find(sup, i) == 0 then
                            table.insert(bsup, i)
                        end
                    end
                end
            end
            --加载兵种图片
            --克制
            for i = 1 , #_pnlSoldier.sup  do
                local n = _pnlSoldier.sup[i].gameObject:ChildWidget("name")
                n.text = DB.GetArm(sup[i]).nm
                n:SetActive(sup[i] < 7)
                _gridTex:Add(_pnlSoldier.sup[i]:LoadTexAsync(sup[i] > 6 and "p_n" or ResName.SoldierIcon(sup[i])))
            end
            --被克制
            for i = 1 , #_pnlSoldier.bsup  do
            local n = _pnlSoldier.bsup[i].gameObject:ChildWidget("name")
                n.text = DB.GetArm(bsup[i]).nm
                n:SetActive(bsup[i] < 7)
                _gridTex:Add(_pnlSoldier.bsup[i]:LoadTexAsync(bsup[i] > 6 and "p_n" or ResName.SoldierIcon(bsup[i])))
            end
        else
            --加载兵种图片
            --克制
            for i = 1 , #_pnlSoldier.sup  do
                local n = _pnlSoldier.sup[i].gameObject:ChildWidget("name")
                n.text = ""
                n:SetActive(false)
                _gridTex:Add(_pnlSoldier.sup[i]:LoadTexAsync("p_n"))
            end
            --被克制
            for i = 1 , #_pnlSoldier.bsup  do
            local n = _pnlSoldier.bsup[i].gameObject:ChildWidget("name")
                n.text = ""
                n:SetActive(false)
                _gridTex:Add(_pnlSoldier.bsup[i]:LoadTexAsync("p_n"))
            end
        end
        
        --显示兵种属性
        local ava = _cur:ArmAvailable(_sltDat.sn)
        if ava then
            _pnlSoldier.state.text = L("状态:[00FF00]已学得[-]")
            _pnlSoldier.lerCost.text = ""
            _pnlSoldier.tip.text = ""
            _pnlSoldier.lerCost:SetActive(false)
            --设置功能按钮
            if _cur.arm ~= _sltDat.sn then
                _pnlSoldier.btnOpt.isEnabled = true
                _pnlSoldier.btnOpt.text = L("使用")
            else
                _pnlSoldier.btnOpt.isEnabled = false
                _pnlSoldier.btnOpt.text = L("使用中")
            end
            --显示具体属性
            local temp = _cur:GetArmLv(_sltDat.sn)
            temp = DB.GetArmLv(temp)
            local from = _pnlSoldier.from
            from[1].text = L("等级：Lv.")..temp.sn
            from[2].text = L( string.format("武力：%s" , math.ceil(_cur.MaxCap * temp.str * 0.01)))
            from[3].text = L( string.format("生命：%s" , math.ceil(_cur.MaxCap * temp.hp * 0.01)))
            from[4].text = L( string.format("暴击：%s%%" ,temp.crit))
            from[5].text = L( string.format("命中：%s%%" ,temp.acc))
            from[6].text = L( string.format("闪避：%s%%" ,temp.dodge))
            from[7].text = L( string.format("兵种BUFF"))
            if temp.sn < DB.maxArmLv then
                if user.hlv < DB.unlock.armLv then
                    _pnlSoldier.upCost.text = L( string.format("主城%s级开启", DB.unlock.armLv))
                    _pnlSoldier.upCost.color = Color.red
                    _pnlSoldier.pnlTo:SetActive(false)
                    _pnlSoldier.upCost.go:ChildWidget("sp_gold"):SetActive(false)
                    _pnlSoldier.btnUp.isEnabled = false
                else
                    temp = DB.GetArmLv(temp.sn + 1)
                    local to = _pnlSoldier.to
                    to[1].text = L("Lv.")..temp.sn
                    to[2].text = L( string.format("%s" , math.ceil(_cur.MaxCap * temp.str * 0.01)))
                    to[3].text = L( string.format("%s" , math.ceil(_cur.MaxCap * temp.hp * 0.01)))
                    to[4].text = L( string.format("%s%%" ,temp.crit))
                    to[5].text = L( string.format("%s%%" ,temp.acc))
                    to[6].text = L( string.format("%s%%" ,temp.dodge))
                    to[7].text = L( string.format("兵种BUFF"))  

                    _pnlSoldier.upCost.text = temp.cost
                    _pnlSoldier.upCost.color = Color.white
                    _pnlSoldier.pnlTo:SetActive(true)
                    _pnlSoldier.upCost.gameObject:ChildWidget("sp_gold"):SetActive(true)
                    _pnlSoldier.btnUp.isEnabled = true

                end
                _pnlSoldier.upCost:SetActive(true)
            else
                _pnlSoldier.upCost:SetActive(false)
                _pnlSoldier.pnlTo:SetActive(false)
            end
            _pnlSoldier.btnOpt:SetActive(true)
            _pnlSoldier.upCost.transform.parent:SetActive(true)
        else
            local idx = math.clamp(math.abs(_sltDat.sn), 1, DB.maxArmQty - 1)
            local needlv = DB.ArmUL(idx)
            local canL1 = _cur.lv >= needlv
            local canL2 = true
            for i = 1 , #_sldItems do
                local g = _sldItems[i]
                local d = _sldItems[g].dat
                if _sltDat == d and i > 1 then
                    g = _sldItems[i - 1]
                    d = _sldItems[g].dat
                    if _sltDat.sn < 0 and d.sn < 0 then
                        canL2 = false
                    end
                    break
                end
            end
            _pnlSoldier.state.text = (canL1 and canL2) and L("状态:[32d932]可学习[-]") or L("状态:[e93434]不可学[-]")
            _pnlSoldier.lerCost.text = canL1 and tostring(1500 * _cur.lv * (idx + 1)) or ""
            _pnlSoldier.lerCost:SetActive(canL1 and canL2)
            if not canL1 then
                _pnlSoldier.tip.text = L( string.format("武将%s级可学习", needlv))
            elseif not canL2 then
                _pnlSoldier.tip.text = L("需先学上一兵种")
            else
                _pnlSoldier.tip.text = ""
            end
            _pnlSoldier.tip:SetActive(not canL1 or not canL2)
            _pnlSoldier.upCost.transform.parent:SetActive(false)

            _pnlSoldier.btnOpt.text = L("学习")
            _pnlSoldier.btnOpt.isEnabled = canL1 and canL2
            _pnlSoldier.btnOpt:SetActive(canL1 and canL2)
        end
    end
end

--[Comment]
--显示阵形面板  3
local function ShowLinePanel()
     print("显示阵形面板   " , kjson.print(_dats))
    local var = _dats
    local qty = var and #var or 0
    local go = nil
    local it = nil
    local selIt = nil
    --生成阵形
    for i = 1 ,qty do
        go = _lnpItems[i]
        it = go and Item.Get(go)
        if it == nil then
            go = _pnlLnp.lnpGrid:AddChild(_item_goods,"line_"..i)
            it = ItemGoods(go)
            _lnpItems[i] = go
            _lnpItems[go] = it
            go.luaBtn.luaContainer = _body
		    go:SetActive(true)
        end
        local sn = var[i].sn
        if sn > 0 then
            it:Init(var[i], sn > 0, _cur.lnp == sn, _cur.lv >= DB.LnpUL(sn), _cur:GetLnpImpQty(sn))
            ItemGoods.ShowName(it)
        else
            it:Init(var[i])
            ItemGoods.ShowName(it)
            local idx = math.clamp(math.abs(sn), 1, DB.maxLnpQty - 1)
            local needlv = DB.ArmUL(idx)
            local canL1 = _cur.lv >= needlv
            local canL2 = true
            for j = 1 , #_lnpItems do
                local g = _lnpItems[j]
                local d = _lnpItems[g].dat
                if var[i] == d and j > 1 then
                    g = _lnpItems[j - 1]
                    d = _lnpItems[g].dat
                    if sn < 0 and d.sn < 0 then
                        canL2 = false
                    end
                    break
                end
            end
            it.name.text = (canL1 and canL2) and L("[32d932]可学习[-]") or L("[e93434]不可学[-]")
        end
        if _cur.lnp == sn then
            _w.ClickItemGoods(go)
        end
        _gridTex:Add(it.imgl)
        CheckSelect(it)
    end
    _pnlLnp.lnpGrid:GetCmp(typeof(UIGrid)).repositionNow = true
    _pnlLnp.btnReset.isEnabled = #_cur.lnpLst > 1
    _pnlLnp.resetCost.text = tostring(DB.param.prResetAL)
    _pnlLnp.resetCost:SetActive(true)

    _pnlLnp.go:SetActive(true)
end

--[Comment]
--加载铭刻属性信息
local function LoadLnpImp(imp)
    if imp then
        local marks = DB.GetLnpImpMarks()
        local len = math.ceil(#marks * 0.5)
        local str1, str2 = "", ""
        for i = 1 ,#_pnlLnp.impInfs do
            _pnlLnp.impInfs[i].text = ""
        end
        for i = 1, len do
            _pnlLnp.impInfs[i].text = _pnlLnp.impInfs[i].text..(i == 1 and "" or "")..( string.gsub("[badeed]"..DB.GetAttWordKV(marks[i], imp:Get(marks[i])),"+", "：[-]+"))
        end
        len = len + 1
        for i = len, #marks do
            _pnlLnp.impInfs[i].text = _pnlLnp.impInfs[i].text..(i == len and "" or "")..( string.gsub("[badeed]"..DB.GetAttWordKV(marks[i], imp:Get(marks[i])),"+", "：[-]+"))
        end
    else
        for i = 1 ,#_pnlLnp.impInfs do
            _pnlLnp.impInfs[i].text = ""
        end
    end
end
--[Comment]
--显示阵形信息  3
local function ShowLineInfo()
    print("显示阵形信息 3333INFO   " , kjson.print(_sltDat))
    if objt(_sltDat) == DB_Lnp then
        --显示阵形属性
        local ava = _cur:LnpAvailable(_sltDat.sn)
        _pnlLnp.supGo:SetActive(false)
        _pnlLnp.bsupGo:SetActive(false)
        if ava then
            if _sltDat.sn > 0 then
                --分离克制和被克制
                local sup = {}
                table.copy(_sltDat.sup ,sup)
                local bsup = {}
                if sup ~= nil then
                    for i = 1, DB.maxLnpQty  do
                        if i ~= _sltDat.sn then
                            if table.find(sup, i) == 0 then
                                table.insert(bsup, i)
                            end
                        end
                    end
                end
                --加载阵形图片
                --克制
                for i = 1 , #_pnlLnp.sup  do
                    local n = _pnlLnp.sup[i].gameObject:ChildWidget("name")
                    n.text = DB.GetLnp(sup[i]).nm
                    if i <= #sup then
                        _gridTex:Add(_pnlLnp.sup[i]:LoadTexAsync(ResName.LineupIcon(sup[i])))
                    else
                        _gridTex:Add(_pnlLnp.sup[i]:LoadTexAsync("p_n"))
                    end
                end
                --被克制
                for i = 1 , #_pnlLnp.bsup  do
                    local n = _pnlLnp.bsup[i].gameObject:ChildWidget("name")
                    n.text = DB.GetLnp(bsup[i]).nm
                    if i <= #bsup then
                        _gridTex:Add(_pnlLnp.bsup[i]:LoadTexAsync(ResName.LineupIcon(bsup[i])))
                    else
                        _gridTex:Add(_pnlLnp.bsup[i]:LoadTexAsync("p_n"))
                    end
                end 
            end

            _pnlLnp.state.text = L("状态:[00FF00]已学得[-]")
            _pnlLnp.supGo:SetActive(true)
            _pnlLnp.bsupGo:SetActive(true)
            _pnlLnp.lerCost.text = ""
            _pnlLnp.lerCost:SetActive(false)
            _pnlLnp.requir:SetActive(false)
            _pnlLnp.imp:SetActive(true)

            --判断功能按钮
            if _cur.lnp ~= _sltDat.sn then
                _pnlLnp.btnOpt.isEnabled = true
                _pnlLnp.btnOpt.text = L("使用")
            else
                _pnlLnp.btnOpt.isEnabled = false
                _pnlLnp.btnOpt.text = L("使用中")
            end

            --未解锁提示
            if _cur.lv < DB.unlock.lnpImp then
                _pnlLnp.imp.text = L( string.format("将领%s级开启", DB.unlock.lnpImp))
                _pnlLnp.imp.color = Color.red
                for i = 1, #_pnlLnp.impInfs do
                    _pnlLnp.impInfs[i].text = ""
                end
                _pnlLnp.imp.transform:FindChild("tip"):SetActive(false)
                _pnlLnp.btnImp.isEnabled = false
            else
                _pnlLnp.imp.text = ""
                _pnlLnp.imp.color = Color(1, 0.94, 0.47)
                LoadLnpImp()
                _cur:GetLnpImp(_sltDat.sn, LoadLnpImp)
                _pnlLnp.imp.transform:FindChild("tip"):SetActive(true)
                _pnlLnp.btnImp.isEnabled = true
            end
            _pnlLnp.btnOpt:SetActive(true)
            _pnlLnp.btnImp:SetActive(true)
        else
            local idx = math.clamp(math.abs(_sltDat.sn), 1, DB.maxLnpQty - 1)
            local needlv = DB.LnpUL(idx)
            local canL1 = _cur.lv >= needlv
            local canL2 = true
            for i = 1 , #_lnpItems do
                local g = _lnpItems[i]
                local d = _lnpItems[g].dat
                if _sltDat == d and i > 1 then
                    g = _lnpItems[i - 1]
                    d = _lnpItems[g].dat
                    if _sltDat.sn < 0 and d.sn < 0 then
                        canL2 = false
                    end
                    break
                end
            end
            _pnlLnp.state.text = (canL1 and canL2) and L("状态:[32d932]可学习[-]") or L("状态:[e93434]不可学[-]")
            _pnlLnp.lerCost.text = tostring(2000 * _cur.lv * (idx + 1))
            _pnlLnp.lerCost:SetActive(canL1 and canL2)
            if not canL1 then
                _pnlLnp.requir.text = L( string.format("武将%s级可学习", needlv))
            elseif not canL2 then
                _pnlLnp.requir.text = L("需先学上一兵种")
            else
                _pnlLnp.requir.text = ""
            end
            _pnlLnp.requir:SetActive(not canL1 or not canL2)
            _pnlLnp.imp:SetActive(false)

            _pnlLnp.btnOpt.text = L("学习")
            _pnlLnp.btnOpt.isEnabled = canL1 and canL2
            _pnlLnp.btnOpt:SetActive(canL1 and canL2)
            _pnlLnp.btnImp:SetActive(false)
        end
    end
end
--[Comment]
--显示装备面板  4
local function ShowEquipPanel()
    print("显示装备面板  " , kjson.print(_dats))
    --装备
    local e, utx, sp, slt
    local eqps = _pnlEqp.eqps
    for i = 1, #eqps do
        e = _cur:GetEquip(i)
        utx = eqps[i]:GetCmp(typeof(UITexture))
        sp = utx:ChildWidget("frame")
        slt = utx:ChildWidget("select")
        lv = utx:ChildWidget("lv")
        slt:SetActive(false)
        if e then
            --如果被选中了
            if _sltEqpKind == i then
                slt:SetActive(true)
                slt.width, slt.height = 124, 124
            end
            sp.spriteName = "frame_"..e.rare
            sp.width, sp.height = 106, 106

            _gridTex:Add(utx:LoadTexAsync(ResName.EquipIcon(e.img)))
            eqps[i].text = e.nm
            lv.text = L("lv:")..e.lv
            ItemGoods.SetEquipEvo(utx, e.evo, e.rare)
            ItemGoods.SetEquipGems(utx, e.gems)
            ItemGoods.SetEquipExclStar(utx, e.exclStar)
            ItemGoods.AddEquipEffect(utx, e.rare, e.HasFrameEffect, e.IsMaxLv, e.ExclActive, e.SuitActive and e.dbsn or 0)
        else
            sp.spriteName = "frame_equit"
            eqps[i].text = ""
            lv.text = ""
            sp.width, sp.height = 106, 106
            ItemGoods.SetEquipEvo(utx)
            ItemGoods.SetEquipGems(utx)
            ItemGoods.SetEquipExclStar(utx)
            ItemGoods.RemoveEquipEffect(utx)
            sp = utx:GetCmp(typeof(UITextureLoader))
            if sp then
                sp:Dispose()
            else
                utx.material, utx.mainTexture = nil, nil
            end
        end
    end

    --生成装备
    _pnlEqp.eqpGrid:Reset()
    _pnlEqp.eqpGrid.realCount = _dats and #_dats or 0
    _pnlEqp.go:SetActive(true)
end
--[Comment]
--显示所选择的装备信息  4
local function ShowEquipInfo()
    print("显示所选择的装备信息 _sltDat  " ,kjson.print(_sltDat))
    if objt(_sltDat) ~= PY_Equip then return end
    print("1111111111111111111")

    local e = _sltDat
    _pnlEqp.nm.text = LN(e.nm)
    _pnlEqp.nm.gradientBottom = ColorStyle.GetRareColor(e.rare)
    _pnlEqp.lv.text = L("等级")..":"..e.lv
    _pnlEqp.att.text = ""
    _pnlEqp.ext.text = ""
    _pnlEqp.evo.text = L("等阶")..":"..e.evo

    local he = _cur:GetEquip(e.kind)
    local var = e.db
    if var.str > 0 then
        var = he and e.baseStr - he.baseStr or e.baseStr
        _pnlEqp.att.text = L("武力").."+"..e.baseStr .. (var == 0 and "" or (var > 0 and ColorStyle.GOOD.."+" or ColorStyle.BAD) .. var .. ColorStyle.EncodeEnd)
    elseif var.wis > 0 then
        var = he and e.baseWis - he.baseWis or e.baseWis
        _pnlEqp.att.text = L("智力").."+"..e.baseWis .. (var == 0 and "" or (var > 0 and ColorStyle.GOOD.."+" or ColorStyle.BAD) .. var .. ColorStyle.EncodeEnd)
    elseif var.cap > 0 then
        var = he and e.baseCap - he.baseCap or e.baseCap
        _pnlEqp.att.text = L("统帅").."+"..e.baseCap .. (var == 0 and "" or (var > 0 and ColorStyle.GOOD.."+" or ColorStyle.BAD) .. var .. ColorStyle.EncodeEnd)
    elseif var.hp > 0 then
        var = he and e.baseHP - he.baseHP or e.baseHP
        _pnlEqp.att.text = L("生命").."+"..e.baseHP .. (var == 0 and "" or (var > 0 and ColorStyle.GOOD.."+" or ColorStyle.BAD) .. var .. ColorStyle.EncodeEnd)
    elseif var.sp > 0 then
        var = he and e.baseSP - he.baseSP or e.baseSP
        _pnlEqp.att.text = L("技力").."+"..e.baseSP .. (var == 0 and "" or (var > 0 and ColorStyle.GOOD.."+" or ColorStyle.BAD) .. var .. ColorStyle.EncodeEnd)
    elseif var.tp > 0 then
        var = he and e.baseTP - he.baseTP or e.baseTP
        _pnlEqp.att.text = L("兵力").."+"..e.baseTP .. (var == 0 and "" or (var > 0 and ColorStyle.GOOD.."+" or ColorStyle.BAD) .. var .. ColorStyle.EncodeEnd)
    else
        _pnlEqp.att.text = ""
    end

    --专属部分
    if e.excl > 0 then
        _pnlEqp.btnExcl:SetActive(true)
        _pnlEqp.efExcl:SetActive(e.ExclActive)
    else
        _pnlEqp.btnExcl:SetActive(false)
        _pnlEqp.efExcl:SetActive(false)
    end

    --套装部分
    if e.suit > 0 then
        _pnlEqp.btnSuit:SetActive(true)
        _pnlEqp.efSuit:SetActive(e.SuitActive)
    else
        _pnlEqp.btnSuit:SetActive(false)
        _pnlEqp.efSuit:SetActive(false)
    end

    var = ""
    --幻化属性
    he = e.CurEcQty
    if he > 0 then
        var = ColorStyle.Good(L("幻化属性").."：\n")
        for i = 1, he do
            var = var .. ColorStyle.GoldStar .. ColorStyle.Good(DB.GetAttWord(e.ecAtt[i])) .. "\n"
        end
    end
    --宝石属性
    if e.slot > 0 then
        local str = ""
        for i = 1, table.maxn(e.gems) do
            he = e.gems[i]
            if he > 0 then
                he = DB.GetGem(he)
                str = str .. ColorStyle.Gem("◆", he.color) .. ColorStyle.Good(he:AttIntro()) .. "\n"
            end
        end
        if str ~= "" then var = var .. ColorStyle.Good(L("宝石属性").."：\n")..str end
    end
    he = string.len(var)
    _pnlEqp.ext.text = he > 0 and string.byte(var, he) == 10 and string.sub(var, 1, he - 1) or var
    he = _pnlEqp.ext.cachedTransform.parent:GetCmp(typeof(UIScrollView))
    if he then
        var = he.panel
        if var then he:MoveRelative(var.clipOffset) end
    end

    _pnlEqp.belong.text = e.belong and "["..e.belong:getName().."]" or ""
    _pnlEqp.btnOpt.text = L(e.IsEquiped and "卸 下" or "装 备")
    _pnlEqp.btnSell.isEnabled = true
    if e.IsEquiped then
        if e.IsMaxLv then
            if e.db:HasGemSlot() then
                _pnlEqp.btnSell.text = L("镶 嵌")
            elseif e.CurEcQty < e.MaxEcQty then
                _pnlEqp.btnSell.text = L("幻 化")
            elseif e.CanEvo then
                _pnlEqp.btnSell.text = L("进 阶")
            else
                _pnlEqp.btnSell.text = L("出 售")
                _pnlEqp.btnSell.isEnabled = false
            end
        else
            _pnlEqp.btnSell.text = L("强 化")
        end
    else
        _pnlEqp.btnSell.text = L("出 售")
    end
end

--[Comment]
--切换显示信息  0：将领信息   1：技能  2：兵种  3：阵形  4：装备
local function ChangeInfo()
    print("切换显示信息 _sltDat   " , kjson.print(_sltDat))
    if _view == 0 then
        --将领信息
        ShowHeroInfo()
    elseif _view == 1 then
        --技能
        ShowSkillInfo()
    elseif _view == 2 then  
        --兵种
        ShowSoldierInfo()
    elseif _view == 3 then  
        --阵形
        ShowLineInfo()
    elseif _view ==4 then
        --装备
        ShowEquipInfo()
    end
end

--[Comment]
--改变页签
local function ChangeView(v, force, epnl)
    if _view == v and not force then return end
    _view = v
    _pnlHeroInfo.go:SetActive(false)
    _pnlSkill.go:SetActive(false)
    _pnlSoldier.go:SetActive(false)
    _pnlLnp.go:SetActive(false)
    _pnlEqp.go:SetActive(false)
    if _view ~= 4 then
        if _pnlLeft.infoEquip.activeSelf then
            LeftPanelContrl(2)
        end
    end
--    _pnlDh.go:SetActive(false)
--    _pnlSrc.go:SetActive(false)
    local d = nil
    local len1, len2 = 0, 0
    if v == 0 then
        --属性
        _dats = nil
        ShowHeroInfo()
    elseif v == 1 then
        --技能
        _dats = nil
        ShowSkillPanel()
    elseif v == 2 then
        --兵种
        len1 = #_cur.armLst
        len2 = #DB.unlock.arm
        _dats = { }
        for i = 1, len2 do
            if i > len1 then
                d = DB_Arm()
                d.sn = -i
                d.nm = "学习中"
                _dats[i] = d
            else
                _dats[i] = DB.GetArm(_cur.armLst[i])
            end
        end
        ShowSoldierPanel()
    elseif v == 3 then
        --阵形
        len1 = #_cur.lnpLst
        len2 = #DB.unlock.lnp
        _dats = { }
        for i = 1, len2 do
            if i > len1 then
                d = DB_Lnp()
                d.sn = -i
                d.nm = "学习中"
                _dats[i] = d
            else
                _dats[i] = DB.GetLnp(_cur.lnpLst[i])
            end
        end
        ShowLinePanel()
    elseif v == 4 then
        --装备
        _dats = user.GetEquips(_sltEqpKind >= 1 and _sltEqpKind <= EQP_KIND.MAX and function(e) return e.kind == _sltEqpKind end)
        table.sort(_dats, PY_Equip.Compare)
        ShowEquipPanel()
    else
        return
    end

    for i = 1 ,#_tabs do
        _tabs[i].luaBtn.isEnabled = _view ~= (i-1)
        _tabs[i].luaBtn.label.color = _view ~= (i-1) and ColorStyle.GetTabColor(1) or ColorStyle.GetTabColor(0)
    end
end

--装备进行锻造后进行界面刷新
local function RefreshView()
    ChangeView(_view, true)
end
_w.RefreshView = RefreshView

--[Comment]
--改变将领
local function ChangeHero(hidx, init)
    if hidx == nil or _heros == nil then return end
    
    _cur = DataCell.DataChange(_cur, _heros[hidx], _w)
    ExitAllInfoPanel()
    _pnlLeft.btnLeft.isEnabled = _curIdx > 1
    _pnlLeft.btnRight.isEnabled = _curIdx < #_heros
    ShowLeftInfo()
    ChangeView(_view,true)
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.BG , n = L("将领"), i = true})
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad","OnWrapGridInitItem","OnFocus",
                    "ClickTab","ClickItemGoods",
                    "ClickLeft","ClickRight","PressSwitchHero","DragSwitchHero","ClickLeftPanel",
                    "ClickAttribTip","ClickDetail","ClickHeroEvo","ClickHeroRank","ClickExclTip","ClickHeroStar","ClickPropsUse","ClickLvUp1","ClickLvUp5",
                    "ClickSkillOpt",
                    "ClickSoldierUp","ClickSoldierReset","ClickSoldierOpt",
                    "ClickLnpReset","ClickLnpOpt","ClickLnpImp",
                    "ClickHeroEquip","ClickEquipExcl","ClickEquipSuit","ClickEquipOpt","ClickEquipSell")
    _ref = c.nsrf.ref
    _pnlLeft = _ref.pnl_left
    _pnlHeroInfo = _ref.pnl_heroInfo
    _pnlSkill = _ref.pnl_skill
    _pnlSoldier = _ref.pnl_soldier
    _pnlLnp = _ref.pnl_lineup
    _pnlEqp = _ref.pnl_equip
    
    
    _item_goods = _ref.item_goods
    _tabs = _ref.btnTab
    for i = 1 ,#_tabs do
        _tabs[i]:SetClick("ClickTab",i - 1)
    end
    

    --左边面板（武将图像，武将历史介绍，装备信息）
    --region 
    local cmp = _pnlLeft.luaSrf
    local wdt = cmp.widgets
    local arr =  cmp.gos
    local cmps =  cmp.cmps
    _pnlLeft = 
    {
        --[Comment]
        --左边的根对象
        go = _pnlLeft,
        --[Comment]
        --将领图片根对象
        heroUtx = arr[0],
        --[Comment]
        --历史介绍根对象
        heroStory = arr[1],
        --[Comment]
        --装备信息根对象
        infoEquip = arr[2],

        --[Comment]
        --将领图片
        heroUtxMesh = cmps[0],
        --[Comment]
        --专属提示
        exclTip = cmps[1],
        --[Comment]
        --专属提示特效
        exclTipEf = cmps[2],
        --[Comment]
        --军师技
        skt = cmps[3],
        --[Comment]
        --军师技介绍
        sktInfo = cmps[4],
        --[Comment]
        --箭头  左
        btnLeft = cmps[5],
        --[Comment]
        --箭头  右
        btnRight = cmps[6],
        --[Comment]
        --星级
        heroStars = cmps[7],


        --[Comment]
        --介绍 姓名
        storyName = cmps[8],
        --[Comment]
        --介绍 类型
        storyType = cmps[9],
        --[Comment]
        --介绍 详情
        storyInfo = cmps[10],
    }
    _pnlLeft.heroUtx.luaBtn:SetClick("ClickLeftPanel",1)
    _pnlLeft.heroStory.luaBtn:SetClick("ClickLeftPanel",2)
--    _pnlLeft.infoEquip.luaBtn:SetClick("ClickLeftPanel",3)
    --endregion

    --将领信息面板
    --region 
    cmp = _pnlHeroInfo.luaSrf
    wdt = cmp.widgets
    arr =  cmp.gos
    cmps =  cmp.cmps
    _pnlHeroInfo = 
    {
        --[Comment]
        --面板根对象
        go = _pnlHeroInfo,
        --[Comment]
        --星级图片
        spStar = wdt[0],
        --[Comment]
        --武将资质
        qualify = cmps[0],
        --[Comment]
        --武将所属国家
        clan = cmps[1],
        --[Comment]
        --武将类型（武智统）
        kind = cmps[2],
        --[Comment]
        --武将军衔
        heroTitle = cmps[3],
        --[Comment]
        --武将军衔提示
        heroTitleTip = cmps[4],
        --[Comment]
        --经验值
        exp = cmps[5],
        --[Comment]
        --生命
        hp = cmps[6],
        --[Comment]
        --技力
        sp = cmps[7],
        --[Comment]
        --兵力
        tp = cmps[8],
        --[Comment]
        --武力
        str = cmps[9],
        --[Comment]
        --智力
        wis = cmps[10],
        --[Comment]
        --统帅
        cap = cmps[11],
        --[Comment]
        --将魂
        soul = cmps[12],
        --[Comment]
        --荣誉
        rank = cmps[13],
        --[Comment]
        --名字
        name = cmps[14],
        --[Comment]
        --等级
        lv = cmps[15],
        --[Comment]
        --军衔 lable
        labTtl = cmps[16],
         --[Comment]
        --军衔 luabutton
        btnTtl = cmps[17],
         --[Comment]
        --军衔 slider
        sliderTtl = cmps[18],
        --[Comment]
        --经验值 slider
        sliderExp = cmps[19],
        --[Comment]
        --将魂 slider
        sliderSoul = cmps[20],
        --[Comment]
        --将魂 luabutton
        btnSoul = cmps[21],
        --[Comment]
        --将领显示界面道具父级
        gridProps = arr[0],
    }
    --endregion

    --技能面板
    --region 
    cmp = _pnlSkill.luaSrf
    wdt = cmp.widgets
    arr =  cmp.gos
    cmps =  cmp.cmps
    _pnlSkill = 
    {
        --[Comment]
        --面板根对象
        go = _pnlSkill,
        --[Comment]
        --技能根对象
        skcGrid = arr[0],
        --[Comment]
        --觉醒技能根对象
        skeGrid = arr[1],
        --[Comment]
        --技能名字
        skillName = cmps[0],
        --[Comment]
        --技能状态
        skillStatus = cmps[1],
        --[Comment]
        --技能描述
        skillDesc = cmps[2],
        --[Comment]
        --详情按钮
        btnOpt = cmps[3],
    }
    --endregion
    
    --兵种面板
    --region 
    cmp = _pnlSoldier.luaSrf
    wdt = cmp.widgets
    arr =  cmp.gos
    cmps =  cmp.cmps
    _pnlSoldier = 
    {
        --[Comment]
        --面板根对象
        go = _pnlSoldier,
        --[Comment]
        --兵种根对象
        sldGrid = arr[0],
        --[Comment]
        --原始属性根对象
        pnlFrom = arr[1],
        --[Comment]
        --升级属性根对象
        pnlTo = arr[2],
        --[Comment]
        --克制兵种对象
        sup = {cmps[0], cmps[1], cmps[2]},
        --[Comment]
        --兵种根对象
        bsup = {cmps[3], cmps[4], cmps[5]},
        --[Comment]
        --功能按钮
        btnOpt = cmps[6],
        --[Comment]
        --学习价钱
        lerCost = cmps[7],
        --[Comment]
        --原始属性
        from = {cmps[8], cmps[9], cmps[10], cmps[11], cmps[12], cmps[13], cmps[14]},
        --[Comment]
        --升级后属性
        to = {cmps[15], cmps[16], cmps[17], cmps[18], cmps[19], cmps[20], cmps[21]},
        --[Comment]
        --提示
        tip = cmps[22],
        --[Comment]
        --升级按钮
        btnUp = cmps[23],
        --[Comment]
        --升级价钱
        upCost = cmps[24],
        --[Comment]
        --状态
        state = cmps[25],
        --[Comment]
        --重置按钮
        btnReset = cmps[26],
        --[Comment]
        --重置价钱
        resetCost = cmps[27],
    }
    --endregion

    --阵形面板
    --region 
    cmp = _pnlLnp.luaSrf
    wdt = cmp.widgets
    arr =  cmp.gos
    cmps =  cmp.cmps
     _pnlLnp = 
    {
        --[Comment]
        --面板根对象
        go = _pnlLnp,
        --[Comment]
        --阵形根对象
        lnpGrid = arr[0],
        --[Comment]
        --克制根对象
        supGo = arr[1],
        --[Comment]
        --被克制根对象
        bsupGo = arr[2],
        --[Comment]
        --重置按钮
        btnReset = cmps[0],
        --[Comment]
        --重置价钱
        resetCost = cmps[1],
        --[Comment]
        --克制
        sup = {cmps[2], cmps[3], cmps[4], cmps[5]},
        --[Comment]
        --被克制
        bsup ={cmps[6], cmps[7], cmps[8], cmps[9]},
        --[Comment]
        --状态
        state = cmps[10],
        --[Comment]
        --功能按钮
        btnOpt = cmps[11],
        --[Comment]
        --学习价钱
        lerCost = cmps[12],
        --[Comment]
        --需求提示
        requir = cmps[13],
        --[Comment]
        --阵形铭刻等级提示，也是铭刻根对象
        imp = cmps[14],
        --[Comment]
        --阵形铭刻具体属性
        impInfs = {cmps[15], cmps[16], cmps[17], cmps[18], cmps[19], cmps[20]},
        --[Comment]
        --阵形铭刻具体属性
        btnImp = cmps[21],
    }
    --endregion

    --装备面板
    --region 
    cmp = _pnlEqp.luaSrf
    wdt = cmp.widgets
    arr =  cmp.gos
    cmps =  cmp.cmps
     _pnlEqp = 
    {
        --[Comment]
        --面板根对象
        go = _pnlEqp,
        --[Comment]
        --穿戴装备对象   武器  护甲  坐骑  书
        eqps = {cmps[0], cmps[1], cmps[2], cmps[3]},
        --[Comment]
        --装备根对象
        eqpGrid = cmps[4],
        --[Comment]
        --装备名字
        nm = cmps[5],
        --[Comment]
        --装备等级
        lv = cmps[6],
        --[Comment]
        --装备基本属性
        att = cmps[7],
        --[Comment]
        --装备附加属性
        ext = cmps[8],
        --[Comment]
        --装备所属
        belong = cmps[9],
        --[Comment]
        --装备进阶等级
        evo = cmps[10],
        --[Comment]
        --功能按钮
        btnOpt = cmps[11],
        --[Comment]
        --装备出售 / 强化
        btnSell = cmps[12],
        --[Comment]
        --专属图标按钮
        btnExcl = cmps[13],
        --[Comment]
        --套装图片按钮
        btnSuit = cmps[14],
        --[Comment]
        --专属特效
        efExcl = arr[0],
        --[Comment]
        --套装特效
        efSuit = arr[1],
        
    }
    for i = 1, #_pnlEqp.eqps do
        _pnlEqp.eqps[i]:SetClick("ClickHeroEquip" , i)
    end
    
    --endregion

    LeftPanelContrl(2)
end

function _w.OnInit()
    if _gridTex == nil then _gridTex = GridTexture(128, 32) end
    local var = _w.initObj
    local h = nil
    _view = 0
    if type(var) == "number" then
        _view = var
    elseif type(var) == "table" then
        if objt(var) == PY_Hero then
            h = var
            if WinHero then
                _heros = WinHero.heros
            end
        elseif #var > 0 then
            for i=1, #var do
                if objt(var[i] ~= PY_Hero) then return end
            end
            _heros = var
        else
            _heros = var[1]
            _view = var[2]
        end
    end

    if _heros == nil then
        _heros = user.GetHeros()
        table.sort(_heros, PY_Hero.Compare)
    else
        assert(#_heros > 0, "no hero")
    end

    _curIdx = 1
    if #_heros > 0 then
        if h then
            for i, v in ipairs(_heros) do
                if v.sn == h.sn then
                    _curIdx = i
                    break
                end
            end
        end
    end
--    ShowHeroInfo()
    _sltEqpKind = 0

    ChangeHero(_curIdx , true)
    ChangeView(_view, true)
end

function _w.OnFocus(f)
    if f then
        print("_view  ", _view)
        ChangeView(_view, true)
    end
end

function _w.OnDispose()
end

function _w.OnUnLoad(c)

end

function _w.OnWrapGridInitItem(go, idx)
    if idx < 0 or _dats == nil or idx >= #_dats then return false end
    local ig = Item.Get(go)
    if ig == nil then
        ig = ItemGoods(go);
        go.luaBtn.luaContainer = _body
    end
    local d = _dats[idx + 1]
    local typ = objt(d)
    ig:Init(d)
    ItemGoods.ShowName(ig)
    _gridTex:Add(ig.imgl)
    ig.Selected = ig.dat and (ig.dat == _sltDat)
    return true
end

--切换将领  左
function _w.ClickLeft() 
    if _curIdx > 1 then 
        _curIdx = _curIdx - 1
        ChangeHero(_curIdx) 
    end 
end

--切换将领  右
function _w.ClickRight() 
    if _curIdx < #_heros then 
        _curIdx = _curIdx + 1
        ChangeHero(_curIdx) 
    end 
end

--长按将领翻页
function _w.PressSwitchHero(pressed)
    if pressed then _w.dragDelta = 0
    elseif _w.dragDelta > 35 then _w.ClickLeft()
    elseif _w.dragDelta < -35 then _w.ClickRight()
    end
end

--拖拽将领翻页
function _w.DragSwitchHero(delta)
    if delta.x * _w.dragDelta < 0 then _w.dragDelta = 0 end
    _w.dragDelta = _w.dragDelta + delta.x
end

--点击属性显示属性提示  btn_attrib_tip
function _w.ClickAttribTip()
    ToolTip.ShowToolTip(L("生命，将领的血量 \n技力，释放技能需要消耗 \n武力，影响将领普通攻击 \n智力，影响将领技能冷却 \n统帅，影响将领带兵的属性"))
end

--点击左侧panel进行翻转
function _w.ClickLeftPanel(v)
    LeftPanelContrl(v.param)
end

--点击显示将领详情  btn_detail
function _w.ClickDetail()
    Win.Open("PopHeroInfo",_cur)
end

--点击觉醒  btn_soul    将魂
function _w.ClickHeroEvo()
    if _cur.lv < 35 then
        ToolTip.ShowPopTip(L("需武将达到[FF0000]35[-]级"))
        return
    end
    if _cur == nil or _cur.IsMaxEvo then
        return
    end
    Win.Open("PopHeroEvo",_cur)
end

--点击升级军阶  btn_hero_title   荣誉
function _w.ClickHeroRank()
    if _cur == nil then
        return
    end
    if not _cur.CanPromotion then
        ToolTip.ShowPopTip(L("通过国战战斗获得,可提升将领军衔！"))
        return
    end
    SVR.HeroRankUp(_cur.sn,function(res)
        if res.success then
            BGM.PlaySOE("sound_line_soldier")
            Invoke(ShowHeroInfo, 0.6)
            local ef = _pnlHeroInfo.go:AddChild(AM.LoadPrefab("ef_hero_rank_up"))
            ef.transform.localPosition = Vector3(-565, -80, 0)
            Destroy(ef, 2)
        end
    end)
end

--点击专属图标弹提示
function _w.ClickExclTip()
    if _cur ~= nil then
        Win.Open("PopExclTip",_cur)
    end
end

--将领升星
function _w.ClickHeroStar()
    if _cur == nil or not _cur.IsStarHero then
        return
    end
    local minL = DB.GetHeroStar(1).clv
    if _cur.lv < minL then
        MsgBox.Show(L( string.format("陛下，本次武将升星需要武将等级为%s级，我们没达标", minL)))
        return  
    end
    Win.Open("PopHeroStar",{_cur,_heros})
end

local function OnPropsUse(p, rws, hero, exp)
    PopRewardShow.Show(rws)
    if p.trg ~= 2 then return end
    ChangeInfo()
end

--使用道具
function _w.ClickPropsUse(it)
    print("123123  ClickPropsUse   ",kjson.print(it))
    local dat = Item.Get(it.gameObject).dat
    print("1333333333333333 ClickPropsUse   ",kjson.print(dat))
    if objt(dat) ~= PY_Props or dat.sn < 1 then return end
    local p, ig, hero = dat, it.gameObject, _cur
    local exp = hero.exp
    local oLv = hero.lv
    PopUseProps.Use(p, _cur, function(t)
        if t.success then
            Tools.ShowUseProps(ig)
            Invoke(OnPropsUse, 0.2, false, p, SVR.datCache.rws, hero, exp)
            if oLv < hero.lv then
                _pnlLeft.heroUtx:AddChild(AM.LoadPrefab("ef_hero_up5"),"ef_hero_up5")
                _pnlHeroInfo.sliderExp:AddChild(AM.LoadPrefab("ef_hero_up4"),"ef_hero_up4")
            end
        end
    end, nil ,true)
end

--升一级
function _w.ClickLvUp1()
    SVR.OneKeyLevelUp(_cur.sn, "1" ,function(res)
        if res.success then
            local p = SVR.datCache
            for i = 1 , #p.useProps do
                local pr = p.useProps[i]
                if pr.usedQty > 0 then
                    Tools.ShowUseProps(_propItems[i] and _propItems[i].go or nil)
                end
                PopRewardShow.Show(pr.rws)
            end
            Invoke(ChangeInfo ,0.2)
            _pnlLeft.heroUtx:AddChild(AM.LoadPrefab("ef_hero_up5"),"ef_hero_up5")
            _pnlHeroInfo.sliderExp:AddChild(AM.LoadPrefab("ef_hero_up4"),"ef_hero_up4")
        end
    end)
end

--升五级
function _w.ClickLvUp5()
    SVR.OneKeyLevelUp(_cur.sn, "5" ,function(res)
        if res.success then
            local p = SVR.datCache
            for i = 1 , #p.useProps do
                local pr = p.useProps[i]
                if pr.usedQty > 0 then
                    Tools.ShowUseProps(_propItems[i] and _propItems[i].go or nil)
                end
                PopRewardShow.Show(pr.rws)
            end
            Invoke(ChangeInfo ,0.2)
            _pnlLeft.heroUtx:AddChild(AM.LoadPrefab("ef_hero_up5"),"ef_hero_up5")
            _pnlHeroInfo.sliderExp:AddChild(AM.LoadPrefab("ef_hero_up4"),"ef_hero_up4")
        end
    end)
end


--点击-技能操作
function _w.ClickSkillOpt()
    local typ = objt(_sltDat)
    if typ == DB_SKP then
        Win.Open("PopPocketSkill", _cur)
    end
end

--兵种升级
function _w.ClickSoldierUp()
    if _cur == nil or objt(_sltDat) ~= DB_Arm then return end
    if _cur:ArmAvailable(_sltDat.sn) then
        local h , a = _cur ,_sltDat
        SVR.UpArm(h.sn, a.sn, function(t)
            if t.success then
                ShowSoldierInfo()
                local sn = _sltDat.sn
                _sltItem:Init(_sltDat, sn > 0, _cur.arm == sn, _cur.lv >= DB.ArmUL(sn), _cur:GetArmLv(sn))
                _sltItem.go:AddChild(AM.LoadPrefab("ef_soldier_up"), "ef_soldier_up")
            end
        end)
    end
end

--兵种重置
function _w.ClickSoldierReset()
    if _cur == nil then return end
    if #_cur.armLst > 1 then
        MsgBox.Show(L( string.format("你确定要重置%s所学的兵种吗？\n(重置后仅保留初始兵种且清除兵种等级)", ColorStyle.Rare(_cur))),L("取消")..","..L("确定"),function(idx)
            if idx == 1 then
                SVR.ResetArm(_cur.sn, function(t)
                    if t.success then
                        ToolTip.ShowPopTip(string.format(L("%s的兵种已经重置！"), ColorStyle.Rare(_cur)))
                        ChangeView(2, true) 
                    end
                end)    
            end
        end)
    end
end

--兵种操作（使用和学习）
function _w.ClickSoldierOpt()
    if _cur == nil or objt(_sltDat) ~= DB_Arm then return end
    local h, a = _cur, _sltDat
    if a.sn > 0 and _cur:ArmAvailable(a.sn) then
        if h.arm == a.sn then return end
        --配置兵种
        SVR.UseArm(_cur.sn, a.sn, function(t)
            if t.success then
                ChangeView(2,true)
                ToolTip.ShowPopTip(string.format("%s的兵种更换为[%s]", ColorStyle.Rare(h), ColorStyle.Blue(a:getName())))
            end
        end)
    else
        --学习兵种
        SVR.LearnArm(h.sn, 0, function(t)
            if t.success then
                if _cur == h and _view == 2 and _dats then
                    for i, d in ipairs(_dats) do
                        if d == a then
                            a = DB.GetArm(SVR.datCache.arm)
                            _dats[i] = a
                            if _sltDat == d then _sltDat = a end
                            local temp = Item.Get(_sldItems[i])
                            if temp == nil then break end
                            Tools.OnLearnArm(a, temp, function()
                                if _cur == h then
                                    _sltItem.go.transform.localScale = Vector3.one
                                    if i < 4 then
                                        local g = _sldItems[i + 1]
                                        _sldItems[g].name.text = _cur.lv >= DB.ArmUL(i + 1) and L("[32d932]可学习[-]") or L("[e93434]不可学[-]")
                                    end
                                    ShowSoldierInfo()
                                    _pnlSoldier.btnReset.isEnabled = #h.armLst > 1
                                end
                                ToolTip.ShowPopTip(string.format("%s已学得[%s]兵!", ColorStyle.Rare(h), ColorStyle.Blue(a:getName())))
                            end)
                            return
                        end
                    end
                end
                ToolTip.ShowPopTip(string.format("%s已学得[%s]兵!", ColorStyle.Rare(h), ColorStyle.Blue(DB.GetArm(SVR.datCache.arm):getName())))
            end
        end)
    end
end

--阵形重置
function _w.ClickLnpReset()
    if _cur == nil then return end
    local h = _cur
    if h.lnpLst == nil or #h.lnpLst < 2 then return end
    MsgBox.Show(string.format(L("你确定要重置%s所学的阵形吗？\n(重置后仅保留初始阵形)"), ColorStyle.Rare(h)), L("确定")..","..L("取消"), function(bid)
        if bid == 0 then
            SVR.ResetLineup(h.sn, function(t)
                if t.success then
                    ToolTip.ShowPopTip(string.format(L("%s的阵形已经重置！"), ColorStyle.Rare(h)))
                    ChangeView(3, true) 
                end
            end)
        end
    end)
end

--阵形操作
function _w.ClickLnpOpt()
    if _cur == nil or objt(_sltDat) ~= DB_Lnp then return end
    local h, a = _cur, _sltDat
    if h:LnpAvailable(a.sn) then
        if h.lnp == a.sn then return end
        --使用阵形
        SVR.UseLineup(h.sn, a.sn, function(t)
            if t.success then
                ChangeView(3,true)
                ToolTip.ShowPopTip(string.format("%s的阵形更换为[%s]", ColorStyle.Rare(h), ColorStyle.Blue(a:getName())))
            end
        end)
    else
        --学习阵形
        SVR.LearnLnp(h.sn, 0, function(t)
            if t.success then
                if _cur == h and _view == 3 and _dats then
                    for i, d in ipairs(_dats) do
                        if d == a then
                            a = DB.GetLnp(SVR.datCache.lnp)
                            _dats[i] = a
                            if _sltDat == d then _sltDat = a end
                            local temp = Item.Get(_lnpItems[i])
                            if temp == nil then break end
                            Tools.OnLearnLnp(a, temp, function()
                                if _cur == h then
                                    _sltItem.go.transform.localScale = Vector3.one
                                    if i < 4 then
                                        local g = _lnpItems[i + 1]
                                        _lnpItems[g].name.text = _cur.lv >= DB.LnpUL(i + 1) and L("[32d932]可学习[-]") or L("[e93434]不可学[-]")
                                    end
                                    ShowLineInfo()
                                    _pnlLnp.btnReset.isEnabled = #h.lnpLst > 1
                                end
                                ToolTip.ShowPopTip(string.format("%s已学得[%s]阵!", ColorStyle.Rare(h), ColorStyle.Blue(a:getName())))
                            end)
                            return
                        end
                    end
                end
                ToolTip.ShowPopTip(string.format("%s已学得[%s]阵!", ColorStyle.Rare(h), ColorStyle.Blue(DB.GetLnp(SVR.datCache.lnp):getName())))
            end
        end)
    end
end

--阵形铭刻
function _w.ClickLnpImp()
    print("阵形铭刻阵形铭刻   " , _sltDat)
    print("阵形铭刻阵形铭刻   " , _cur)
    if _cur == nil or _sltDat == nil or not _cur:LnpAvailable(_sltDat.sn) then
        return
    end
    if objt(_sltDat) == DB_Lnp then
        if _cur:LnpAvailable(_sltDat.sn) then
            Win.Open("PopLineupImprint",{_cur, _sltDat})
        end
    end
end

--点击穿戴的装备
function _w.ClickHeroEquip(kind)
    local eqs = _pnlEqp.eqps
    local sp, e
    for i = 1, #eqs do
        sp = eqs[i]:ChildWidget("frame")
        eqs[i]:ChildWidget("select"):SetActive(false)
        e = _cur and _cur:GetEquip(i) or nil
        if e then
            sp.spriteName = "frame_" .. e.rare
        end
    end

    sp = eqs[kind]
    if sp == nil then return end
    e = _cur and _cur:GetEquip(kind) or nil
    if kind == _sltEqpKind then
        _sltEqpKind = 0
        if e or _sltDat or _sltItem then 
            ExitAllInfoPanel()
        end
        LeftPanelContrl(2)
        ChangeView(4, true)
    else
        _sltEqpKind = kind
        if e or _sltDat or _sltItem then 
            ExitAllInfoPanel()
        end
        sp = sp:ChildWidget("select")
        sp:SetActive(true)
        LeftPanelContrl(3)
        ChangeView(4, true, false)
        _sltDat, _sltItem = e, nil
        ChangeInfo()
    end
end

--点击强化  卖出 
function _w.ClickEquipSell(e)
    if objt(_sltDat) ~= PY_Equip then return end
    local e = _sltDat
    if e.IsEquiped then
        --强化
        if e.IsMaxLv then
            if e.db:HasGemSlot() then
                Win.Open("WinGoods", e)
                WinGoods.isEquipEmbed = true
            elseif e.CurEcQty < e.MaxEcQty or e.CanCanEvo then
                Win.Open("WinGoods", e)
            else
                
            end
        else
            Win.Open("WinGoods", e)
        end
    elseif e.rare > 2 then
        MsgBox.Show(string.format(L("你确定卖出%s吗?"), ColorStyle.Rare(e:getName().."(Lv:"..e.lv..")", e.rare)), L("确定")..","..L("取消"), function(bid)
             if bid == 0 then 
                SVR.EquipOption("sell", e.sn, 0, function(t)
                    if t.success then
                        ExitAllInfoPanel()
                        ChangeView(4, true)
                        user.changed = true
                        ToolTip.ShowPopTip(string.format(L("卖出[%s]，%s"), ColorStyle.Rare(e:getName().."(Lv:"..e.lv..")"), L("银币").."+"..e.price))
                    end
                end)
             end 
        end)
    else
        --卖出
        if e == nil or not e.sn then return end
        SVR.EquipOption("sell", e.sn, 0, function(t)
            if t.success then
                ExitAllInfoPanel()
                ChangeView(4, true)
                user.changed = true
                ToolTip.ShowPopTip(string.format(L("卖出[%s]，%s"), ColorStyle.Rare(e:getName().."(Lv:"..e.lv..")"), L("银币").."+"..e.price))
            end
        end)
    end
end

--装备操作  装备 卸装   已知BUG：界面不刷新
function _w.ClickEquipOpt(e)
    e = e or _sltDat
    if objt(e) ~= PY_Equip then return end
    if e.IsEquiped then
        --卸下装备
        local bh = _sltDat.belong
        local att = { e.str, e.wis, e.cap, e.hp, e.sp, e.tp }
        SVR.EquipOption("down", e.kind, e.belong.sn, function(t)
            if t.success then
                if e.kind == EQP_KIND.ARMOR then user.changed = true end
                local tip = ""
                for i, v in ipairs(att) do if v > 0 then tip = tip.." "..DB.GetAttName(i).."-"..v end end
                tip = ColorStyle.Bad(tip)
                ToolTip.ShowPopTip(string.format(L("%s卸下[%s(Lv:%s)]%s"), ColorStyle.Rare(bh),  ColorStyle.Rare(e), e.lv, tip))
            end
        end)
    elseif _cur and _cur.sn then
        --穿上装备
        local h = _cur
        local le = _cur:GetEquip(e.kind)
        local att = last and { le.str, le.wis, le.cap, le.hp, le.sp, le.tp }
        SVR.EquipOption("up", e.sn, _cur.sn, function(t)
            if t.success then
                if e.kind == EQP_KIND.ARMOR then user.changed = true end
                local tip = ""
                local catt = { e.str, e.wis, e.cap, e.hp, e.sp, e.tp }
                if att then
                    for i, v in ipairs(att) do
                        v = catt[i] - v
                        if v ~= 0 then
                            i = DB.GetAttName(i)
                            tip = tip .. (v > 0 and ColorStyle.Good(i.."+"..v) or v < 0 and ColorStyle.Bad(i.."-"..v))
                        end
                    end
                else
                    for i, v in ipairs(catt) do if v > 0 then tip = tip.." "..DB.GetAttName(i).."+"..v end end
                    tip = ColorStyle.Good(tip)
                end
                ToolTip.ShowPopTip(string.format(L("%s装备[%s(Lv:%s)]%s"), ColorStyle.Rare(h),  ColorStyle.Rare(e), e.lv, tip))
            end
        end)
    end
end

--点击专属图标
function _w.ClickEquipExcl()
    local w = Win.GetActiveWin("PopEquipExcl")
    if w then
        w:Exit()
    else
        w = _sltDat
        if objt(w) == PY_Equip and w.sn and w.excl > 0 then Win.Open("PopEquipExcl", w) end
    end
end

--点击套装图标
function _w.ClickEquipSuit()
    local w = Win.GetActiveWin("PopEquipSuit")
    if w then
        w:Exit()
    else
        w = _sltDat
        if objt(w) == PY_Equip and w.sn and w.suit > 0 then Win.Open("PopEquipSuit", w) end
    end
end

--点击页签
function _w.ClickTab(v)
    ChangeView(v,true)
end

--点击物品
function _w.ClickItemGoods(btn)
    print("_sltItem_sltItem  ClickItemGoods```````````````  " ,kjson.print(btn))
    btn = btn and Item.Get(btn.gameObject)

    if btn == _sltItem then
        ChangeInfo()
    else    
        ExitAllInfoPanel()
        _sltItem = btn
        print("btn   " , btn.name)
        print("_sltItem   " , _sltItem.name)
        if _sltItem then
            _sltItem.Selected = true
            _sltDat = DataCell.DataChange(_sltDat, _sltItem.dat, _w)
        end
        ChangeInfo()
    end
end

--[Comment]
--将领浏览
PopHeroDetail = _w