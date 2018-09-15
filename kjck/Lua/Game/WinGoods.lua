WinGoods = { }

local isNull = tolua.isnull
local sort = table.sort

local _body = nil
WinGoods.body = _body

local _ref
local _gridTex = nil
local _dats
local _tabs
local _curDat = nil
local _curItem = nil

------宝石-------
local datasGems = { }
local data
     --合成
local gem1Name;
local gem1Num;
local gem2Name;
local gem2Num;
local cost;
local gem1Icon;
local gem2Icon;
local btnUp1;
local btnUpAll;
local btnUpHelp;
     --熔炼
local gems;
local targetGem
local targetName;
local targetIcon;
local btnMelt;
local btnMeltHelp;
----------------------

local _tabSub
local _tabEqp
local _tabProp
local _tabOther
local _btnSellBatch

local _itemGrid
local _btnGrid
local _btnSell
local _btnOpt
local _btnEvo
local _btnForge
local _btnEmbled

local _pnlEqp
local _pnlProp
local _pnlEqpSp
local _pnlSoul
local _pnlGem
local _pnlDqp
local _pnlDqpSp
local _pnlSexcl

local TabColorHightLight = Color(1, 1, 1, 1)
local TabColorNormal = Color(140/255, 157/255, 179/255, 1)

--[Commment]
--DateCell侦听休眠时间
local _obsSleepTm = 0

--[Comment]
--视图大类[1=装备,2=道具,3=其它]
local _vwKind = 0
--[Commment]
--[0|1=全部装备 2=武器 3=防具 4=坐骑 5=兵书 6=道具 -6=宝箱 7=宝石 8|9=材料 10=碎片 11=将魂 12=军备 13=残片]
local _view = -1
--[Commment]
--装备子项[0|1=全部装备 2=武器 3=防具 4=坐骑 5=兵书]
local _equipView = 0;
--[Commment]
--其它子项[8|9=材料 10=碎片 11=将魂 12=军备 13=残片]
local _otherView = 0;
--[Commment]
--是否是装备镶嵌界面
local isEquipEmbed = false

local _filter = 
{
        --装备-武器
    [2] = function(e) return e.kind == 1 end,
        --装备-防具
    [3] = function(e) return e.kind == 2 end,
        --装备-坐骑
    [4] = function(e) return e.kind == 3 end,
        --装备-兵书
    [5] = function(e) return e.kind == 4 end,
    --道具-宝箱
    [6] = function(p) return p.qty > 0 and p.kind == 3 end,
    --道具-消耗
    [14] = function(p) return p.qty > 0 and p.trg > 0 end,
    --道具-材料
    [15] = function(p) return p.qty > 0 and p.trg <= 0 end,
    --道具-强化石
    eup = function(p) return p.qty > 0 and p.sn == DB_Props.JING_GANG end,
}

--[Comment]
--刷新Tab
local function RefreshTab()
    if _vwKind == 1 then
        local max = DB.GetVip(user.vip).eqpQty
        local tmp = _pnlEqp.qty
        tmp.text = L("装备数").."\n"..user.equipQty .."/"..max
        tmp.color = max - user.equipQty <= CONFIG.EquipTipCount and Color.red or Color.green
--    elseif _view == 12 then
--        local max = DB.GetVip(user.vip).dqpQty
--        local tmp = _pnlDqp.qty
--        tmp.text = L("军备数").."\n"..user.dequipQty .."/"..max
--        tmp.color = max - user.dequipQty <= CONFIG.EquipTipCount and Color.red or Color.white
    end
end

--[Comment]
--切换面板
local function ChangePanel(pnl)
    _pnlEqp.go:SetActive(pnl == _pnlEqp)
    _pnlEqpSp.go:SetActive(pnl == _pnlEqpSp)
    _pnlProp.go:SetActive(pnl == _pnlProp)
    _pnlSoul.go:SetActive(pnl == _pnlSoul)
    _pnlGem.go:SetActive(pnl == _pnlGem)
--    _pnlDqp.go:SetActive(pnl == _pnlDqp)
--    _pnlDqpSp.go:SetActive(pnl == _pnlDqpSp)
--    _pnlSexcl.go:SetActive(pnl == _pnlSexcl)
end

local function RefreshGem()
    local lv = 0
    for i=1, #gems do
        if datasGems[i] == nil or datasGems[i].lv < 1 then datasGems[i] = nil
        elseif lv < 1 then lv = datasGems[i].lv
        elseif datasGems[i].lv ~= lv then datasGems[i] = nil end

        local cnt = gems[i]:ChildWidget("num")
        if datasGems[i] ~= nil then
            _gridTex:Add(gems[i]:LoadTexAsync(ResName.GemIcon(datasGems[i].sn)))
            cnt.text = "×"..1
            cnt.color = user.GetGemQty(datasGems[i].sn) > 0 and Color.green or Color.red
        else
            gems[i]:UnLoadTex()
            cnt.text = ""
        end

        if targetGem ~= nil then
            _gridTex:Add(targetIcon:LoadTexAsync(ResName.GemIcon(targetGem.sn)))
            targetName.text = targetGem.nm
            targetName.color = ColorStyle.GetGemColor(targetGem.color)
        elseif lv > 0 then
            _gridTex:Add(targetIcon:LoadTexAsync())
            targetName.text = "随机" .. lv .."级宝石"
            targetName.color = Color.white
        else
            targetIcon:UnLoadTex()
            targetName.text = "--"
            targetName.color = Color.white
        end
    end
end

local function RefreshGemUpgrade()
    if data ~= nil then
        gem1Name.text = ColorStyle.Gem(data)
        gem1Num.text = user.GetGemQty(data.sn) .. "/" .. DB.param.prGemUp
        gem1Num.color = user.GetGemQty(data.sn) < DB.param.prGemUp and Color.red or Color.green
        gem1Icon:LoadTexAsync(ResName.GemIcon(data.sn))
        
        local nex=DB.GetKindGem(data.kind, data.lv + 1)
        if nex~=nil then  
            gem2Name.text = ColorStyle.Gem(nex)
            gem2Num.text = "×".. math.floor(user.GetGemQty(data.sn) / DB.param.prGemUp)
            if nex.cost >user.coin then cost.text= L("单次升级")..":[c]" .. ColorStyle.Bad(tostring(nex.cost)) .. "[/c]"..L("银币")
            else cost.text = L("单次升级")..":"..nex.cost ..L("银币") end 

            gem2Icon:LoadTexAsync(ResName.GemIcon(nex.sn))
        else
            gem2Name.text = "--";
            gem2Name.color = Color.white;
            gem2Num.text = "";
            cost.text = L("该宝石不可合成")
            gem2Icon.UnLoadTex();
        end
    else
        gem1Name.text = L("点击选择宝石");
        gem1Name.color = Color.white;
        gem1Num.text = "";
        gem1Icon.UnLoadTex();

        gem2Name.text = "--";
        gem2Name.color = Color.white;
        gem2Num.text = "";
        cost.text = "";
        gem2Icon.UnLoadTex();
    end
end

local function SetData(gem)
    data = gem
    RefreshGemUpgrade()
end

local function RefreshInfoPanel()
    local tp = objt(_curDat)
    if tp == PY_Props then
        --道具
        local db = _curDat.db
        _pnlProp.nm.text = db:getName()
        _pnlProp.kind.text = L("类型")..":"..L(db.ti)
        _pnlProp.i.text = db:getIntro()

        _btnOpt.text = L("使 用")
        _btnOpt.isEnabled = db.trg == 1 or db.trg == 3
        _btnOpt:SetActive(true)
        _btnSell:SetActive(false)
        _btnEvo:SetActive(false)
        _btnEmbed:SetActive(false)
        _btnForge:SetActive(false)

        ChangePanel(_pnlProp)
    elseif tp == PY_Equip then
        --装备
        --基本显示部分
        _pnlEqp.nm.text = ColorStyle.Rare(_curDat)
        _pnlEqp.lv1.text = tostring(_curDat.lv)
        _pnlEqp.lv2.text = _curDat.IsMaxLv and  "" or tostring(_curDat.lv + 1)
        _pnlEqp.belong.text = _curDat.belong and _curDat.belong:getName() or ""
        _pnlEqp.belong:SetActive(_curDat.belong ~= nil)
        tp = _curDat.db
        if tp.str > 0 then
            _pnlEqp.anm.text = L("武力")..":"
            _pnlEqp.att1.text = tostring(_curDat.baseStr)
            _pnlEqp.att2.text = _curDat.IsMaxLv and "" or tostring(_curDat.baseStr + tp.lstr)
        elseif tp.wis > 0 then
            _pnlEqp.anm.text = L("智力")..":"
            _pnlEqp.att1.text = tostring(_curDat.baseWis)
            _pnlEqp.att2.text = _curDat.IsMaxLv and "" or tostring(_curDat.baseWis + tp.lwis)
        elseif tp.cap > 0 then
            _pnlEqp.anm.text = L("统帅")..":"
            _pnlEqp.att1.text = tostring(_curDat.baseCap)
            _pnlEqp.att2.text = _curDat.IsMaxLv and "" or tostring(_curDat.baseCap + tp.lcap)
        elseif tp.hp > 0 then
            _pnlEqp.anm.text = L("生命")..":"
            _pnlEqp.att1.text = tostring(_curDat.baseHP)
            _pnlEqp.att2.text = _curDat.IsMaxLv and "" or tostring(_curDat.baseHP + tp.lhp)
        elseif tp.sp > 0 then
            _pnlEqp.anm.text = L("技力")..":"
            _pnlEqp.att1.text = tostring(_curDat.baseSP)
            _pnlEqp.att2.text = _curDat.IsMaxLv and "" or tostring(_curDat.baseSP + tp.lsp)
        elseif tp.tp > 0 then
            _pnlEqp.anm.text = L("兵力")..":"
            _pnlEqp.att1.text = tostring(_curDat.baseTP)
            _pnlEqp.att2.text = _curDat.IsMaxLv and "" or tostring(_curDat.baseTP + tp.ltp)
        end
        --专属部分
        if tp.excl > 0 then
            _pnlEqp.excl:SetActive(true)
            _pnlEqp.exclEf:SetActive(_curDat.ExclActive)
        else
            _pnlEqp.excl:SetActive(false)
            _pnlEqp.exclEf:SetActive(false)
        end
        --套装部分
        if tp.suit > 0 then
            _pnlEqp.suit:SetActive(true)
            _pnlEqp.suitEf:SetActive(_curDat.SuitActive)
        else
            _pnlEqp.suit:SetActive(false)
            _pnlEqp.suitEf:SetActive(false)
        end

        _pnlEqp.nm.cachedTransform.localPosition = (tp.excl > 0 or tp.suit > 0) and Vector3(-90, 136, 0) or Vector3(-160, 136, 0)

        if isEquipEmbed and not tp:HasGemSlot() then isEquipEmbed = true end

        if isEquipEmbed then
            if user.IsEquipEmbedUL then
                _pnlEqp.tip:SetActive(false)        
                local dbQty = tp.slot and #tp.slot or 0
                local eqQty = _curDat.slot
                local qty = math.max(eqQty, dbQty)
                local trans = _pnlEqp.slots.transform
                local child = trans.childCount
                local ig, color, gem = nil, nil, nil
                local gnm, gatt, gbtn = nil, nil, nil
                local frame, uGem = nil, nil
                for i = 1, qty, 1 do
                    ig = i > child and  trans:AddChild(_pnlEqp.itemGem, "item_"..i) or trans:GetChild(i-1)
                    color = tp.slot[i] or 0
                    gnm, gatt = ig:ChildWidget("name"), ig:ChildWidget("attrib")
                    gbtn = ig:ChildWidget("btn_option")
                    frame = ig:ChildWidget("gem_frame")
                    uGem = frame:ChildWidget("gem_u")
                    if i <= eqQty then
                        if _curDat.gems[i] > 0 then
                            gem = DB.GetGem(_curDat.gems[i])
                            gnm.text = gem:getName()
                            gnm.color = ColorStyle.GetGemColor(gem.color)
                            gatt.text = gem:AttIntro()
                            gatt.color = ColorStyle.GetGemColor(gem.color)
                            _gridTex:Add(ig:ChildWidget("icon"):LoadTexAsync(ResName.GemIcon(gem.sn)))
                            gbtn:GetCmpInChilds(typeof(UILabel)).text = L("卸下")
                            frame.spriteName = "gem_"..color.."_f"
                            uGem.spriteName = "gem_"..color
                            uGem:SetActive(true)
                        else
                            gnm.text = DB_Gem.GetKindName(color) .. L("宝石孔")
                            gnm.color = ColorStyle.GetGemColor(color)
                            gatt.text = "未镶嵌"
                            gatt.color = Color.white
                            ig:ChildWidget("icon"):UnLoadTex()
                            gbtn:GetCmpInChilds(typeof(UILabel)).text = "镶嵌"
                            frame.spriteName = "gem_"..color.."_f"
                            uGem.spriteName = "gem_"..color
                            uGem:SetActive(true)
                        end
                        gbtn:GetCmp(typeof(UIButton)).isEnabled = true
                        gbtn:GetCmp(typeof(LuaButton)).param = {ig, i}
                        ig:DesChild("sp_lock")
                        ig:SetActive(true)
                    elseif i <= dbQty then
                        gnm.text = L("未打孔");
                        gnm.color = Color.white
                        ig:ChildWidget("icon"):UnLoadTex()
                        frame.spriteName = "gem_0_f"
                        uGem.spriteName = "gem_0"
                        gbtn:GetCmpInChilds(typeof(UILabel)).text = L("打孔")
                        gbtn:GetCmp(typeof(LuaButton)).param = {ig, i}
                        local lock = ig:ChildWidget("sp_lock")
                        if not lock then
                            lock = ig:AddWidget(typeof(UISprite), "sp_lock")
                            lock.atlas = AM.mainAtlas
                            lock.width, lock.height, lock.depth = 80, 82, 6
                        end
                        if i == eqQty + 1 then
                            gatt.text = L("需要")..ColorStyle.Rare(DB.GetProps(DB_Props.DA_KONG_ZHUI))..NameStyle.QtyTag(DB.param.prGemPunch[i] or 0)
                            gatt.color = Color.white
                            lock.spriteName = "sp_lock_2"
                            gbtn:GetCmp(typeof(UIButton)).isEnabled = true
                        else
                            gatt.text = L("上孔未开启")
                            gatt.color = Color.gray
                            lock.spriteName = "sp_lock_2"
                            gbtn:GetCmp(typeof(UIButton)).isEnabled = false
                        end
                        ig:SetActive(true)
                    else
                        ig:SetActive(false)
                    end
                end
                if qty < child then
                    for i = qty, child - 1, 1 do trans:GetChild(i):SetActive(false) end
                end
                _pnlEqp.slots.repositionNow = true

                local it = ItemGoods(_pnlEqp.embEquip)
                it:Init(_curDat)
                _gridTex:Add(it.imgl)
                it:ShowName()
            else
                _pnlEqp.tip.text = string.format(L("主城%s级开启装备镶嵌"), DB.unlock.gemEmbed)
                _pnlEqp.tip:SetActive(true)
            end

            _btnSellBatch:SetActive(not isEquipEmbed)
            _btnSell.text = L("卖 出")
            _btnSell:SetActive(not isEquipEmbed)
            _btnEvo:SetActive(not isEquipEmbed)
            _btnForge:SetActive(not isEquipEmbed)
            _btnEmbed:SetActive(not isEquipEmbed)
        else
            --幻化部分
            if user.IsEquipEcUL then
                _pnlEqp.tip:SetActive(false)
                _pnlEqp.btnEc.text = L("幻 化")
                local curEcQty, maxEcQty = _curDat.CurEcQty, _curDat.MaxEcQty
                local leftEcQty = maxEcQty - curEcQty
                if curEcQty > 0 then
                    local ett = ""
                    for i = 1, curEcQty do
                        ett = ett..(i > 1 and "\n" or "")..ColorStyle.GoldStar..ColorStyle.Good(DB.GetAttWord(_curDat.ecAtt[i]))
                    end
                    _pnlEqp.ecnum.text = leftEcQty > 0 and ColorStyle.Good(string.format(L("可幻化%s次"), leftEcQty)) or ColorStyle.Grey(L("不可幻化"))
                    _pnlEqp.ett.text = ett
                else
                    _pnlEqp.ecnum.text = maxEcQty > 0 and ColorStyle.Good(string.format(L("可幻化%s次"), maxEcQty)) or  ColorStyle.Grey(L("不可幻化"))
                    _pnlEqp.ett.text = ""
                end
                local sv = _pnlEqp.ett.cachedTransform.parent:GetCmp(typeof(UIScrollView))
                if sv and sv.panel then sv:MoveRelative(sv.panel.clipOffset) end
                if leftEcQty > 0 then
                    local eccost = DB.GetEquipEcCost(curEcQty)
                    _pnlEqp.ecs.text = L("幻化需要")..":"..(eccost > user.EcStone and ColorStyle.BAD or ColorStyle.GOOD).. user.EcStone .. "/" ..eccost
                else
                    _pnlEqp.ecs.text = L("幻化需要")..":--"
                end
                _pnlEqp.btnEc.isEnabled = leftEcQty > 0 
            else
                _pnlEqp.tip.text = ColorStyle.Bad(string.format(L("主城%s级开启装备幻化"), DB.unlock.eqpEC))
                _pnlEqp.tip:SetActive(true)
                _pnlEqp.goEc:SetActive(false)
            end

            --强化部分
            if _curDat.IsMaxLv then
                _pnlEqp.upc:SetActive(false)
                _pnlEqp.upc1key:SetActive(false)

            else
                local upcost = _curDat.upCoin
                _pnlEqp.upc.text = ""..(upcost > user.coin and ColorStyle.BAD or "") .. upcost
                _pnlEqp.upc:SetActive(true)
                local cost = 0
                local rare = tp.rare
                for i=_curDat.lv, user.hlv - 1 do
                    local c = DB.GetEquipLv(i, rare)
                    cost = cost + c
                end
                _pnlEqp.upc1key.text = cost
                _pnlEqp.upc1key:SetActive(true)
            end

            _btnSellBatch:SetActive(true)
            _btnSell.text = L("卖 出")
            _btnSell:SetActive(true)
            _btnEvo:SetActive(true)
            _btnEmbed:SetActive(true)
            _btnForge:SetActive(true)
            _btnOpt:SetActive(false)
            _btnEvo.isEnabled = user.IsEquipEvoUL and _curDat.CanEvo
            _btnEvo.text = user.IsEquipEvoUL and L("进 阶") or string.format(L("主城%s级解锁"), DB.unlock.eqpEvo)
            _btnEmbed.text = L("镶 嵌")
            _btnEmbed.isEnabled = _curDat.db:HasGemSlot()
            _btnForge.text = user.IsExclForgeUL and L("锻 造") or string.format(L("主城%s级解锁"), DB.unlock.exclForge)
            _btnForge.isEnabled = _curDat.CanExclForge and user.IsExclForgeUL 
        end
        if user.IsSmithyUL then
            _pnlEqp.goEmb:SetActive(isEquipEmbed and user.IsEquipEmbedUL)
        else
             _pnlEqp.goEmb:SetActive(false)
        end

        ChangePanel(_pnlEqp)
    elseif tp == PY_EquipSp then
        --装备碎片
         _pnlEqpSp.nm.text = ColorStyle.Rare(_curDat)
        _pnlEqpSp.i.text = _curDat:getIntro()

        local db = _curDat.db
        if db.str > 0 then _pnlEqpSp.att.text = L("属性")..":" .. L("武力").."+" .. db.str .. L("(完整)")
        elseif db.wis > 0 then _pnlEqpSp.att.text = L("属性")..":" .. L("智力").."+" .. db.wis .. L("(完整)")
        elseif db.cap > 0 then _pnlEqpSp.att.text = L("属性")..":" .. L("统帅").."+" .. db.cap .. L("(完整)")
        elseif db.hp > 0 then _pnlEqpSp.att.text = L("属性")..":" .. L("生命").."+" .. db.hp .. L("(完整)")
        elseif db.sp > 0 then _pnlEqpSp.att.text = L("属性")..":" .. L("技力").."+" .. db.sp .. L("(完整)")
        elseif db.tp > 0 then _pnlEqpSp.att.text = L("属性")..":" .. L("兵力").."+" .. db.tp .. L("(完整)") end

        _pnlEqpSp.qty.text = L("当前数量")..":"..(_curDat.qty < db.piece and ColorStyle.BAD or ColorStyle.GOOD).._curDat.qty .."/"..db.piece..ColorStyle.EncodeEnd
        _pnlEqpSp.cost.text = L("合成价格")..":"..db:MakePrice()
        _pnlEqpSp.price.text = L("出售价格")..":"..db:PicPrice()

        _btnSell.text = L("卖 出")
        _btnOpt.text = L("合 成")
        _btnOpt.isEnabled = _curDat.qty > 0 and _curDat.qty >= db.piece
        _btnSell:SetActive(true)
        _btnOpt:SetActive(true)
        _btnEvo:SetActive(false)
        _btnForge:SetActive(false)
        _btnEmbed:SetActive(false)

        ChangePanel(_pnlEqpSp)
    elseif tp == PY_Soul then
        --将魂
        local db = _curDat.db
        _pnlSoul.nm.text = db:getName()..L("之将魂")
        _pnlSoul.tnm.text = db:getName()..":"
        _pnlSoul.i.text = db:getIntro()
        local hero = user.ExistHero(db.sn)
        if hero then
            if hero.rare < DB.param.rareHeroEvo then
                _pnlSoul.qty.text = L("当前数量")..":".._curDat.qty
                _pnlSoul.tip.text = string.Format(L("仅%s星或以上的将领方可觉醒"), DB.param.rareHeroEvo)
                _pnlSoul.tip.color = Color(1, 0, 0, 0.75)
                _btnOpt:SetActive(false)
                _btnSell:SetActive(false)
            elseif hero.evo < DB.maxHeroEvo then
                local need = DB.GetHeroEvo(hero.rare, hero.evo)
                _pnlSoul.qty.text = L("当前数量")..":"..(_curDat.qty < need and ColorStyle.BAD or ColorStyle.GOOD).._curDat.qty.."/"..need..ColorStyle.EncodeEnd
                _pnlSoul.tip.text = ""
                _btnOpt:SetActive(true)
                _btnOpt.isEnabled = _curDat.qty >= need
                _btnSell:SetActive(user.IsHeroSoulUL)
            else
                _pnlSoul.qty.text = L("当前数量")..":".._curDat.qty
                _pnlSoul.tip.text = string.format(L("%s已达至高觉醒"), hero:getName())
                _pnlSoul.tip.color = Color(0, 1, 0, 0.75)
                _btnOpt:SetActive(false)
                _btnSell:SetActive(user.IsHeroSoulUL)
            end
        else
            _pnlSoul.qty.text = L("当前数量")..":".._curDat.qty
            _pnlSoul.tip.text = string.format(L("你还未拥有%s"), db:getName())
            _pnlSoul.tip.color = Color(1, 0, 0, 0.75)
            _btnOpt:SetActive(false)
            _btnSell:SetActive(user.IsHeroSoulUL)
        end

        _btnOpt.text = L("觉 醒")
        _btnSell.text = L("分 解")
        _btnEvo:SetActive(false)
        _btnForge:SetActive(false)
        _btnEmbed:SetActive(false)

        ChangePanel(_pnlSoul)
    elseif tp == PY_Gem then
        --宝石
        _pnlGem.nm.text = ColorStyle.Gem(_curDat)
        _pnlGem.color.text = L("类型")..":"..ColorStyle.Gem(DB_Gem.GetKindName(_curDat.color), _curDat.color)
        _pnlGem.att.text = L("属性")..":".._curDat:getIntro()
        _pnlGem.qty.text = L("数量")..":".._curDat.qty

        _btnOpt.text = L("合 成")
        _btnOpt.isEnabled = not _pnlGem.upg.activeSelf
        _btnEmbed.text = L("熔 炼")
        _btnEmbed.isEnabled = not _pnlGem.melt.activeSelf

        _btnOpt:SetActive(true)
        _btnEmbed:SetActive(true)
        _btnSell:SetActive(false)
        _btnEvo:SetActive(false)
        _btnForge:SetActive(false)

        datasGems[1] = _curDat
        SetData(_curDat)
        RefreshGem()

        ChangePanel(_pnlGem)
    else
        _btnSell:SetActive(false)
        _btnOpt:SetActive(false)
        _btnEvo:SetActive(false)
        _btnForge:SetActive(false)
        _btnEmbed:SetActive(false)
        ChangePanel()
    end
    if _body.gameObject.activeInHierarchy then _btnGrid:Reposition()
    else _btnGrid.repositionNow = true end
end

function WinGoods.ClickOption()
    local dat = _curDat
    local tp = objt(dat)

    if tp == PY_Props then
        --道具使用
        if dat.dbsn > 0 then
            tp = _curItem
            if dat.trg == 3 then
                Win.Open("PopGift", dat.dbsn)
                return
            end
            PopUseProps.Use(dat, 0, function(t)
                if t.success then
                    Tools.ShowUseProps(tp.go)
                    t = SVR.datCache
                    if t then
                        t = t.rws
                        if t and #t > 0 then
                            Invoke(PopRewardShow.Show, 0.6, true, t)
                        end
                    end
                end
            end)
        end
    elseif tp == PY_Soul then
        --将魂  觉醒
        coroutine.start(function()
            local db = _curDat.db
            local hero = user.ExistHero(db.sn)
            if hero and hero.evo < DB.maxHeroEvo then
                Win.Open("PopHeroDetail", hero)
                coroutine.wait(0.5)
                Win.Open("PopHeroEvo", hero)
            end
        end)
    elseif tp == PY_Equip then

    elseif tp == PY_EquipSp then
        --碎片  合成
        local db = _curDat.db
        if db.sn > 0 then
            SVR.EquipPieceOption("make|" .. db.sn, function(result) if result.success then  end end)
        end
    elseif tp == PY_Gem then
        _pnlGem.melt:SetActive(false)
        _pnlGem.upg:SetActive(true)
        _btnOpt.isEnabled = not _pnlGem.upg.activeSelf
        _btnEmbed.isEnabled = not _pnlGem.melt.activeSelf
    end
end

function WinGoods.ClickEmbed()
    local db = _curDat.db
    if objt(db) == DB_Gem then
        _pnlGem.melt:SetActive(true)
        _pnlGem.upg:SetActive(false)
        _btnOpt.isEnabled = not _pnlGem.upg.activeSelf
        _btnEmbed.isEnabled = not _pnlGem.melt.activeSelf
    elseif objt(_curDat) == PY_Equip then
        isEquipEmbed = not isEquipEmbed
        RefreshInfoPanel()
    end
end

--强化成功特效
local function ShowUpEffect(e, lv)
    if e.lv > lv then
        RefreshInfoPanel()
        local var = ""
        local db = e.db
        local difLv = e.lv -lv
        if db.str > 0 then var = L("武力").."+"..db.lstr * difLv
        elseif db.wis > 0 then var = L("智力").."+"..db.lwis * difLv
        elseif db.cap > 0 then var = L("统帅").."+"..db.lcap * difLv
        elseif db.hp > 0 then var = L("生命").."+"..db.lhp * difLv
        elseif db.sp > 0 then var = L("技力").."+"..db.lsp * difLv
        elseif db.tp > 0 then var = L("兵力").."+"..db.ltp * difLv end
        BGM.PlaySOE("sound_up_success")
        _pnlEqp.go:AddChild(AM.LoadPrefab("ef_equip_up"),"ef_equip_up")
    end
end

--强化
function WinGoods.ClickEquipUp()
    local tp = objt(_curDat)
    if tp == PY_Equip then
        if _curDat.IsLvLmt then ToolTip.ShowPopTip("当前装备等级已经达到主城上限，请升级主城等级") return end

        local lv = _curDat.lv
        local cost = _curDat.upCoin
        SVR.EquipUpgrade(_curDat.sn, 0, false, function(result)
            if result.success then
                ShowUpEffect(_curDat, lv)
            end
        end)
    end
end
--一键强化
function WinGoods.ClickEquipUpOnekey()
    local tp = objt(_curDat)
    if tp == PY_Equip then
        if _curDat.IsLvLmt then ToolTip.ShowPopTip("当前装备等级已经达到主城上限，请升级主城等级") return end

        local lv = _curDat.lv
        local cost = 0
        local upLv = 0
        local rare = _curDat.db.rare
        for i=_curDat.lv, user.hlv - 1 do
            local c = DB.GetEquipLv(i, rare)
            cost = cost + c
            if cost > user.coin then 
                cost = cost - c  
                break 
            end
            upLv = i + 1
        end
        if upLv <= 0 then
            MsgBox.Show("银币不足,是否兑换银币？", "取消,兑换", function(bid)
                if bid == 1 then Win.Open("PopG2C") end
            end)
        else
            MsgBox.Show(string.format("强化到%s级,将消耗%s银币,是否强化？", ColorStyle.Bad(upLv), ColorStyle.Silver(cost)), "否,是", function(bid)
                if bid == 1 then
                    SVR.EquipUpOnekey(_curDat.sn, 0, false, function(result)
                        if result.success then
                            ShowUpEffect(_curDat, lv)
                        end
                    end)
                end
            end)
        end
    end
end

--幻化特效
local function CoEquipEc()
    local go = _pnlEqp.go:AddChild(AM.LoadPrefab("ef_en"), "ef_en")
    if go then
        local mask = ToolTip.Mask(6)
--        go.transform.localPosition = Vector3(0, 70, 0)
        coroutine.step()
        go:SetActive(true)
        coroutine.wait(1)
        if mask then mask.tm = 0 end
    end
    WinGoods.ObsSleep()
    RefreshInfoPanel()
end
--幻化
function WinGoods.ClickEC()
    local tp = objt(_curDat)
    if tp == PY_Equip and _curDat.sn then
        local maxEcQty = _curDat.MaxEcQty
        if maxEcQty < 1 then return end
        local curEcQty = _curDat.CurEcQty
        if curEcQty < maxEcQty then
            --幻化
            WinGoods.ObsSleep(15)
            SVR.EquipOption("hh", _curDat.sn, 0, function(t)
                if t.success then
                    coroutine.start(CoEquipEc)
                    BGM.PlaySOE("sound_excl_evo")
                end
            end)
        end
    end
end

--[Comment]
--点击 装备面板-专属标记
function WinGoods.ClickEquipExcl()
    local w = PopEquipExcl
    if w and w.isOpen then
        w:Exit()
    elseif objt(_curDat) == PY_Equip and _curDat.sn and _curDat.excl > 0 then
        Win.Open("PopEquipExcl", _curDat)
    end
end
--[Comment]
--点击 装备面板-套装标记
function WinGoods.ClickEquipSuit()
    local w = PopEquipSuit
    if w and w.isOpen then
        w:Exit()
    elseif objt(_curDat) == PY_Equip and _curDat.sn and _curDat.suit > 0 then
        Win.Open("PopEquipSuit", _curDat)
    end
end

local function ChangeView(v, force)
    if isnull(_body) then return end
    if v == 0 then v = _equipView
    elseif v == 8 then v = _otherView < 8 and 8 or _otherView end
    if _view == v and not force then return end
    if v == 0 or v == 1 then  --装备-全部装备
        v, _equipView = 1, 1
        _dats = user.GetEquips()
        sort(_dats, PY_Equip.Compare)
    elseif v == 2 then  --武器
        _equipView = 2
        _dats = user.GetEquips(_filter[v])
        sort(_dats, PY_Equip.Compare)
    elseif v == 3 then  --防具
        _equipView = 3
        _dats = user.GetEquips(_filter[v])
        sort(_dats, PY_Equip.Compare)
    elseif v == 4 then  --坐骑
        _equipView = 4
        _dats = user.GetEquips(_filter[v])
        sort(_dats, PY_Equip.Compare)
    elseif v == 5 then  --兵书
        _equipView = 5
        _dats = user.GetEquips(_filter[v])
        sort(_dats, PY_Equip.Compare)
    elseif v == 6 or v == 16 then --道具-全部道具
        v = 16
        _dats = user.GetProps(true)
        sort(_dats, DB_Props.Compare)
    elseif v == 14 then  --消耗
        v = 14
        _dats = user.GetProps(_filter[v])
        sort(_dats, DB_Props.Compare)
    elseif v == 15 then --材料
        v = 15
        _dats = user.GetProps(_filter[v])
        sort(_dats, DB_Props.Compare)
    elseif v == -6 then --宝箱
        v = 6
        _dats = user.GetProps(_filter[v])
        sort(_dats, DB_Props.Compare)
    elseif v == 7 then --宝石
        _dats = user.GetGems(true)
        sort(_dats, DB_Gem.Compare)
    elseif v == 8 or v == 10 then  --其他-碎片
        v, _otherView = 10, 10
        _dats = user.GetEquipSps(true)
        sort(_dats,PY_EquipSp.CompareCompose)
    elseif v == 9 then  --天机
        _otherView = 9
        _dats = user.GetSexcls(true)
        sort(_dats, DB_Sexcl.Compare)
    elseif v == 11 then --将魂
        _otherView = 11
        _dats = user.GetSouls(true)
        sort(_dats, DB_Hero.Compare)
    elseif v == 12 then --军备
        _otherView = 12
        _dats = user.GetDequips(true)
        sort(_dats, PY_Dequip.Compare)
    elseif v == 13 then --残片
        _otherView = 13
        _dats = user.GetDequipSps(true)
        sort(_dats, PY_DequipSp.Compare)
    else 
        _dats = nil
        return
    end

    _vwKind = v < 6 and 1 or (v > 7 and v < 14 and 3 or ((v == 16 or v == 14 or v == 15) and 2 or 0))

    if _view == v then
        if _curDat and not table.idxof(_dats, _curDat) then _curDat = _dats[1]; RefreshInfoPanel() end
    else 
        _view = v
        _curDat = nil
        if #_dats <= 0 then RefreshInfoPanel() end
        _btnSellBatch:SetActive((v<6 or v==10 or v==12) and #_dats > 0)
        _pnlEqp.qty:SetActive(_vwKind == 1)
--        _pnlDqp.qty:SetActive(v==12)
        for i=1, #_tabs do 
            _tabs[i].isEnabled = v ~= (i-1) 
            if i-1 ~= 0 and i-1 ~= 8 and i-1 ~= 6 and i-1 ~= 7 then
                if i-1 ~= _view then
                    _tabs[i]:GetCmpInChilds(typeof(UILabel)).color = TabColorNormal
                else
                    _tabs[i]:GetCmpInChilds(typeof(UILabel)).color = TabColorHightLight
                end
            end
        end
        _tabs[1].isEnabled = _vwKind ~= 1
        _tabs[1]:GetCmpInChilds(typeof(UILabel)).color = _tabs[1].isEnabled and TabColorNormal or TabColorHightLight
        _tabs[7].isEnabled = _vwKind ~= 2
        _tabs[7]:GetCmpInChilds(typeof(UILabel)).color = _tabs[7].isEnabled and TabColorNormal or TabColorHightLight
        _tabs[8]:GetCmpInChilds(typeof(UILabel)).color = _tabs[8].isEnabled and TabColorNormal or TabColorHightLight
        _tabs[9].isEnabled = _vwKind ~= 3
        _tabs[9]:GetCmpInChilds(typeof(UILabel)).color = _tabs[9].isEnabled and TabColorNormal or TabColorHightLight
    end

    if _vwKind > 0 then
        _tabSub:SetActive(true)
        _tabEqp:SetActive(_vwKind == 1)
        _tabProp:SetActive(_vwKind == 2)
        _tabOther:SetActive(_vwKind == 3)
        EF.FadeIn(_tabSub, 0.2)
        EF.Scale(_tabSub, 0.2, Vector3.one)
    else
        EF.FadeOut(_tabSub, 0.2)
        EF.Scale(_tabSub, 0.2, Vector3(1, 0, 1))
    end

    _itemGrid:Reset()
    _itemGrid.realCount = #_dats
    RefreshTab()
end

--[Comment]
--刷新
local function Refresh(t)
    if t and not t.success then return end
    ChangeView(_view, true)
    RefreshInfoPanel()
end
WinGoods.Refresh = Refresh
--点击-一键出售
function WinGoods.ClickSellBatch()
    if _vwKind == 1 then
        --装备
        MsgBox.Show(L("请选择出售品级"), L("取消") .. "," .. L("确定"), "{t}" .. L("白色装备") .. ",{t}" .. ColorStyle.Rare(L("绿色装备"), 2) .. "," .. ColorStyle.Rare(L("蓝色装备"), 3) .. "," .. ColorStyle.Rare(L("紫色装备"), 4),
        function(bid, tog, ipt)
            if bid ~= 1 then return end
            local len = tog and tog.Length or 0
            if len < 1 then return end
            local rare = ""
            for i = 0, len - 1 do if tog[i] then rare = rare ..","..(i + 1) end end
            if rare == nil or string.len(rare) < 2 then return end
            rare = string.sub(rare, 2)
            local eqs = user.GetEquips(function(e) if e.IsEquiped then return end; e = e.rare - 1; return tog:IndexAvailable(e) and tog[e] end)
            if #eqs < 1 then return end
            SVR.EquipSellBatch(rare, function(t)
                if t.success then
                    if SVR.datCache.qty < 1 then return end
                    for i = 1, #eqs do user.RemoveEquip(eqs[i].sn) end
                    Refresh()
                end
            end)
        end)
    elseif _view == 10 then
        --碎片
        MsgBox.Show(L("请选择出售品级"), L("取消") .. "," .. L("确定"), "{t}" .. L("白色碎片") .. ",{t}" .. ColorStyle.Rare(L("绿色碎片"), 2) .. "," .. ColorStyle.Rare(L("蓝色碎片"), 3) .. "," .. ColorStyle.Rare(L("紫色碎片"), 4),
        function(bid, tog, ipt)
            if bid ~= 1 then return end
            local len = tog and tog.Length or 0
            if len < 1 then return end
            local rare = ""
            for i = 0, len - 1 do if tog[i] then rare = rare ..","..(i + 1) end end
            if rare == nil or string.len(rare) < 2 then return end
            rare = string.sub(rare, 2)
            local eqs = user.GetEquipSps(function(e) if e.qty < 0 then return end; e = e.rare - 1; return tog:IndexAvailable(e) and tog[e] end)
            if #eqs < 1 then return end
            SVR.PieceSellBatch(rare, function(t)
                if t.success then
                    if SVR.datCache.qty < 1 then return end
                    for i = 1, #eqs do eqs[i]:SetQty(0) end
                    Refresh()
                end
            end)
        end)
    end
end
--点击-出售
function WinGoods.ClickSell()
    local dat = _curDat
    local tp = objt(dat)
    if tp == PY_Equip then
        --出售装备
        if dat.sn then
            if dat.rare > 2 then
                MsgBox.Show(string.format(L("你确定卖出[%s]吗?"), ColorStyle.Rare(dat) .. (dat.lv > 0 and "(Lv:" .. dat.lv .. ")" or "")), L("取消")..","..L("确定"), function(bid)
                    if bid == 1 then
                        SVR.EquipOption("sell", dat.sn, 0, function(t)
                            if t.success then
                                Refresh()
                                user.changed = true
                                ToolTip.ShowPopTip(string.format("卖出[%s], 银币%s", ColorStyle.Rare(dat) .. (dat.lv > 0 and "(Lv:" .. dat.lv .. ")" or ""), ColorStyle.Silver("+" .. dat.price)))
                            end
                        end)
                    end
                end)
            else
                SVR.EquipOption("sell", dat.sn, 0, function(t)
                    if t.success then
                        Refresh()
                        user.changed = true
                        ToolTip.ShowPopTip(string.format("卖出[%s], 银币%s", ColorStyle.Rare(dat) .. (dat.lv > 0 and "(Lv:" .. dat.lv .. ")" or ""), ColorStyle.Silver("+" .. dat.price)))
                    end
                end)
            end
        end
    elseif tp == PY_EquipSp then
        --出售碎片
        Win.Open("PopBuyProps", {d=dat,kind=PopBuyProps.EquipSp})
    elseif tp == PY_Soul then
        --分解将魂
        Win.Open("PopBuyProps", {d=dat,kind=PopBuyProps.Soul})
    end
end


 ----------------------------宝石合成---------------------
local function OnUpEnd(data,newadd)
    ToolTip.Mask(2)
    _pnlGem.upg:AddChild(AM.LoadPrefab("ef_gem_up"),"ef_gem_up")
    coroutine.wait(2)
    if newadd then 
        WinGoods.RefreshData()
    else
        Refresh()
    end
end
--全部合成
function WinGoods.ClickUpAll()
    if data==nil then return end
    local nex=DB.GetKindGem(data.kind,data.lv+1)
    if not nex then return end
    local newAdd = user.GetGemQty(nex.sn)==0 
    SVR.GemUpgrade(data.sn,true,function(res)
        if res.success then 
            coroutine.start(OnUpEnd,SVR.datCache,newAdd)
        end
    end)
end

function WinGoods.ClickSelectGem()
    Win.Open("PopSelectGem",{function(s) if #s>0 then SetData(s[1]) end end,table.findall(DB.AllGem(), function(g) return user.GetGemQty(g.sn)>=DB.param.prGemUp  end),{data}})
end
--合成
function WinGoods.ClickUp1()
    if not data then return end
    local nex=DB.GetKindGem(data.kind,data.lv+1)
    if not nex then return end
    local newadd=user.GetGemQty(nex.sn)==0
    SVR.GemUpgrade(data.sn,false,function(res)
        if res.success then
            coroutine.start(OnUpEnd,SVR.datCache,newadd)
        end
    end)
end
--合成帮助
function WinGoods.GemUpHelp()
    Win.Open("PopRule", DB_Rule.GemUpgrade)
end
-----------------------------------------------------------------------
----------------------------宝石熔炼------------------------------------
function WinGoods.ClickGem(idx)
    if datasGems[idx] == nil then
        local gem
        for i=1,#datasGems do if datasGems[i]~=nil then gem=datasGems[i];break end end
        local gs={}
        if gem and gem.sn>0 then  
            if user.GetGemQty(gem.sn)>1 then gs=table.findall(DB.AllGem(),function(g) return user.GetGemQty(g.sn)>0 and g.lv==gem.lv end)
            else gs=table.findall(DB.AllGem(),function(g) return user.GetGemQty(g.sn)>0 and g.sn ~= gem.sn and g.lv==gem.lv end)
            end
        else gs=table.findall(DB.AllGem(),function(g) return user.GetGemQty(g.sn)>0 end)  
        end
        if #gs<1 then ToolTip.ShowPopTip(L("没有足够的宝石"));return end 
        Win.Open("PopSelectGem",{function(sel) if #sel>0 then datasGems[idx]=sel[1]; RefreshGem() end end,gs})
    else
        datasGems[idx] = nil
        RefreshGem()
    end
end

function WinGoods.ClickMelt()
    for i=1, #gems do 
        if datasGems[i] == nil then return end 
    end

    local gstr = ""
    for i=1, #datasGems do 
        gstr = gstr.. datasGems[i].sn .. (i ~= #datasGems and "|" or "")
    end
    SVR.GemMelt(gstr,function(res)
       if res.success then
          targetGem=nil 
          local r=SVR.datCache 
          for i=1,#r.rws do if r.rws[i][1]==7 and r.rws[i][3]>0 then target=DB.GetGem(r.rws[i][2]);break end end
--          ToolTip.Mask(1)
          coroutine.start(OnUpEnd,r)
          _pnlGem.melt:AddChild(AM.LoadPrefab("ef_gem_melt"), "ef_gem_melt"):Destroy(1)
       end
    end)
end
--熔炼帮助
function WinGoods.GemMeltHelp()
    Win.Open("PopRule", DB_Rule.GemMelt)
end
------------------------------------------------------------------------
-----------------------------宝石镶嵌------------------------------------
function WinGoods.ClickGemOption(p)
    local it = p[1]
    local idx = p[2]
    local slot = _curDat.slot
    if idx <= slot then
        if _curDat.gems[idx] > 0 then --卸下
            SVR.EquipGem(_curDat.sn, 0, idx, function(result) 
                if result.success then
                end
            end)
        else  --镶嵌
            local db = _curDat.db
            local color = db.slot[idx] or 0
            local gems = table.findall(DB.AllGem(), function(g) return user.GetGemQty(g.sn) > 0 and g.color == color end)
            if #gems <= 0 then ToolTip.ShowPopTip("您没有该颜色宝石") return end
            Win.Open("PopSelectGem",{function(slt) 
                if #slt > 0 then 
                    SVR.EquipGem(_curDat.sn, slt[1].sn, idx, function(result) 
                        if result.success then
                        end
                    end)
                end 
            end, gems})
        end
    else
        SVR.EquipOption("slot", _curDat.sn, 0, function(result) 
            if result.success then
                local frame = it:ChildWidget("gem_frame")
                frame:AddChild(AM.LoadPrefab("ef_gem_open"), "ef_gem_open")
            end
        end)
    end
end
--镶嵌帮助
function WinGoods.GemEmbledHelp()
    Win.Open("PopRule", DB_Rule.GemEmbed)
end
-------------------------------------------------------------------------

---------------------------------装备进阶---------------------------------
function WinGoods.ClickEvolution()
    local tp = objt(_curDat)
    if tp == PY_Equip and _curDat.CanEvo then
        Win.Open("WinSmithy", _curDat)
    end
end
--------------------------------------------------------------------------

---------------------------------装备锻造----------------------------------
function WinGoods.ClickForge()
    local tp = objt(_curDat)
    if tp == PY_Equip then
        Win.Open("PopExclForge", _curDat)
    end
end
---------------------------------------------------------------------------


function WinGoods.ClickTab(arg) ChangeView(arg) end

function WinGoods.RefreshData()
    if _vwKind == 1 then
        SVR.SyncEquipData(Refresh)
    elseif _vwKind == 2 then
        SVR.SyncPropsData(Refresh)
    elseif _view == 7 then
        SVR.SyncGem(Refresh)
    elseif _view == 11 or _view == 9 then
        SVR.SyncHeroSoul(Refresh)
    else
        Refresh()
    end
end

function WinGoods.OnLoad(c)
    WinBackground(c,{n = L("背包"), i = true})
    _body = c

    c:BindFunction("OnInit", "ClickTab", "RefreshData", "ClickOption", "ClickItemGoods","OnWrapGridInitItem", 
                   "ClickEquipUp", "ClickEquipUpOnekey", "ClickEC", "ClickEquipExcl", "ClickEquipSuit",
                   "ClickSell", "ClickSellBatch", "ClickEquipBelong", "ClickUp1", "ClickUpAll", "ClickSelectGem",
                    "ClickEmbed", "ClickGem", "ClickEvolution", "ClickForge", "ClickGemOption", "ClickMelt", "OnDispose", "OnUnLoad")

    _ref = _body.nsrf.ref
    table.print("_ref", _ref)

    _tabs = _ref.btnTabs
    for i=1, #_tabs do
        local tab = _tabs[i]
        tab.luaBtn.luaContainer = _body
        tab.luaBtn:SetClick("ClickTab", i-1)
    end

    _tabSub = _ref.subTab
    _tabEqp = _ref.equipTab2
    _tabProp = _ref.propTab2
    _tabOther = _ref.otherTab2
    
    _itemGrid = _ref.scrollView:GetCmp(typeof(UIWrapGrid))
    _btnGrid = _ref.btnGrid

    _btnSellBatch = _ref.btnSellBatch
    _btnSell = _ref.btnSell
    _btnOpt = _ref.btnOption3
    --[Comment]
    --进阶按钮
    _btnEvo = _ref.btnEvolution1
    --[Comment]
    --锻造按钮
    _btnForge = _ref.btnForge0
    --[Comment]
    --镶嵌按钮
    _btnEmbed = _ref.btnEmbed2

    ---------宝石-------------
        --合成
    gem1Name = _ref.gem1Name
    gem1Num = _ref.gem1Num
    gem2Name = _ref.gem2Name
    gem2Num = _ref.gem2Num
    cost = _ref.cost
    gem1Icon = _ref.gem1Icon
    gem2Icon = _ref.gem2Icon
    btnUp1 = _ref.btnUp1
    btnUpAll = _ref.btnUpAll
    btnUpHelp = _ref.btnUpHelp
        --熔炼
    gems = _ref.gems
    targetName = _ref.targetName
    targetIcon = _ref.targetIcon
    btnMelt = _ref.btnMelt
    btnMeltHelp = _ref.btnMeltHelp

    for i=1, #gems do
        local btn = gems[i].luaBtn
        btn.luaContainer = _body
        btn:SetClick("ClickGem", i)
    end
    --------------------------

    _pnlEqp = _ref.equipPanel 
    _pnlProp = _ref.propsPanel
    _pnlSoul = _ref.soulPanel
    _pnlGem = _ref.gemPanel
    _pnlSexcl = _ref.sexclPanel
    _pnlEqpSp = _ref.piecePanel
    _pnlDqp = _ref.lieuEquipPanel
    _pnlDqpSp = _ref.lieuPiecePanel

    --道具面板
    local arr = _ref.propsInfos
    _pnlProp = { go = _pnlProp, nm = arr[1], kind = arr[2], i = arr[3] }

    --装备面板
    arr = _ref.equipInfos
    _pnlEqp = {
        --[Comment]
        --面板根对象
        go = _pnlEqp,
        --[Comment]
        --强化面板
        goUp = _ref.equipUp,
        --[Comment]
        --幻化面板
        goEc = _ref.equipEc,
        --[Comment]
        --镶嵌面板
        goEmb = _ref.equipEmbed,
        --[Comment]
        --镶嵌装备
        embEquip = _ref.embEquip,
        --[Comment]
        --专属图标
        excl = _ref.equipExcl,
        --[Comment]
        --专属图标特效
        exclEf = _ref.equipExclEffect,
        --[Comment]
        --套装图标
        suit = _ref.equipSuit,
        --[Comment]
        --套装图标特效
        suitEf = _ref.equipSuitEffect,
        --[Comment]
        --镶嵌宝石预制件
        itemGem = _ref.item_gem_slot,
        --[Comment]
        --幻化提示
        tip = _ref.equipExtTip,
        --[Comment]
        --镶嵌列表
        slots = _ref.equipSlots,
        --[Comment]
        --装备数量
        qty = _ref.equipCount,
        --[Comment]
        --所属武将
        belong = _ref.equipBelong,
        --[Comment]
        --名称
        nm = arr[1],
        --[Comment]
        --当前等级
        lv1 = arr[2],
        --[Comment]
        --下个等级
        lv2 = arr[3],
        --[Comment]
        --属性名称
        anm = arr[4],
        --[Comment]
        --当前属性
        att1 = arr[5],
        --[Comment]
        --下级属性
        att2 = arr[6],
        --[Comment]
        --幻化属性
        ett = arr[7],
        --[Comment]
        --强化花费
        upc = arr[8],
        --[Comment]
        --一键强化花费
        upc1key = arr[12],
        --[Comment]
        --幻化花费
        ecs = arr[10],
        --[Comment]
        --幻化次数
        ecnum = arr[11],
        --[Comment]
        --幻化按钮
        btnEc = _ref.btnEc,
        --[Comment]
        --强化按钮
        btnEqpUP = _ref.btnEquipUp,
        --[Comment]
        --进阶按钮
        btnEvo = _btnEvo,
        --[Comment]
        --锻造按钮
        btnForge = _btnForge,
        --[Comment]
        --镶嵌按钮
        btnEmbed = _btnEmbed,
        --[Comment]
        --一键强化按钮
        btnEqpUP1Key = _ref.btnEquipUpOnekey,
        --[Comment]
        --强化特效
        upEf = _ref.ef_equp,
    }

    --装备碎片面板
    arr = _ref.pieceInfos
    _pnlEqpSp = { go = _pnlEqpSp, nm = arr[1], i = arr[2], att = arr[3], qty = arr[4], cost = arr[5], price = arr[6] }

    --将魂面板
    arr = _ref.heroSoulInfos
    _pnlSoul = { go = _pnlSoul, nm = arr[1], tnm = arr[2], i = arr[3], qty = arr[4], tip = arr[5] }

    --宝石面板
    arr = _ref.gemInfos
    _pnlGem = { 
        go = _pnlGem, 
        nm = arr[1], 
        color = arr[2],
--        lv = arr[3],
        att = arr[4],
        qty = arr[5],
        --熔炼界面
        melt = _ref.gemMelt,
        --合成界面
        upg = _ref.gemUpgrade,
    }

end

function WinGoods.OnInit()
    if _gridTex == nil then _gridTex = GridTexture(128, 32) end

    local o = WinGoods.initObj
    local tp = type(o)
    if tp == "number" then  ChangeView(o) return end
    if tp == "table" then
        tp = objt(tp)
        ChangeView(tp == PY_Equip and 0 or (tp == PY_Dequip and 12 or (tp == PY_Gem and 7 or (tp == PY_Props and 14 or 0))))
        if _dats then
            for i, v in ipairs(_dats) do
                if v == o then
                    table.insert(_dats, 1, table.remove(_dats, i))
                end
            end
        end
        return
    end

    ChangeView(0)

    WinGoods.isOpen = true
end

--[Comment]
--观察数据变更休眠一段时间
function WinGoods.ObsSleep(tm) _obsSleepTm = tm and tm > 0 and Time.realtimeSinceStartup + tm or 0 end
--[Comment]
--Datacell接口是否存活
function WinGoods.alive() return not tolua.isnull(_body) end
--[Comment]
--Datacell接口数据变更
function WinGoods.OnDataChange(w, d) if _obsSleepTm < Time.realtimeSinceStartup then RefreshInfoPanel() end end

function WinGoods.OnWrapGridInitItem(go,idx)
    if idx < 0 or _dats == nil or idx >= #_dats then return false end

    local ig = Item.Get(go)
    if ig == nil then
        ig = ItemGoods(go);
        go.luaBtn.luaContainer = _body
    end
    ig:Init(_dats[idx + 1])
	ig:ShowName()
    _gridTex:Add(ig.imgl)
    if ig.dat and (ig.dat == _curDat or _curDat == nil) then
        _curItem = ig
        if _curDat == nil then
            _curDat = ig.dat
            RefreshInfoPanel()
        end
        ig.Selected = true
    else
        ig.Selected = false
    end
    return true
end

function WinGoods.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if _curItem ~= btn then
        if _curItem then _curItem.Selected = false end
        _curItem = btn
        if _curItem then _curItem.Selected = true end
    end

    btn = btn and btn.dat
    if btn ~= _curDat then
        _curDat = DataCell.DataChange(_curDat, btn, WinGoods)
        RefreshInfoPanel()
    end
end

function WinGoods.OnDispose()
    _view , _vwKind, _equipView, _otherView = -1, 0, 0, 0
    isEquipEmbed = false
    _obsSleepTm = 0
    if _gridTex then
        _gridTex:Dispose()
        _gridTex = nil
    end
    _itemGrid:Reset()
    WinGoods.ClickItemGoods(nil)
--    _pnlEqp.go:DesChild("ef_en")
end

function WinGoods.OnUnLoad()
    WinGoods.isOpen = false
    _body = nil
    _tabSub, _tabEqp, _tabProp, _tabOther, _btnSellBatch = nil, nil, nil, nil, nil
    _tabs  = nil
    _itemGrid, _btnSell, _btnOpt, _btnEvo = nil, nil, nil, nil
    _pnlEqp, _pnlProp, _pnlEqpSp, _pnlSoul = nil, nil, nil, nil
    _pnlGem, _pnlDqp, _pnlDqpSp, _pnlSexcl = nil, nil, nil, nil
end
