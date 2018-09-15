
local insert = table.insert


local win = { }
WinSmithy = win

local _body = nil
local _ref = nil

local _ef_1 = nil
local _ef_2 = nil
local _ef_f = nil
local _mainE = nil
local _subE = nil
local _texProps = nil
local _labNum = nil
local _sldPro = nil
local _sldProT = nil
local _matEquips = nil
-- [等阶from，等阶to，属性标签，属性from，属性to]
local _infos = nil
local _btnEvo = nil

local _mainEd = nil
local _subEd = nil
local _matEds = nil
local _props = nil
local _gt = nil


local function InitEquip(tmp, data)
    if tmp then
        tmp = tmp.transform
        if data ~= nil then
            if tonumber(data.sn) > 0 then
                tmp:GetCmp(typeof(UISprite)).spriteName = "frame_"..data.rare
                _gt:Add(tmp:FindChild("img"):GetCmp(typeof(UITexture)):LoadTexAsync(ResName.EquipIcon(data.db.img)))
                tmp:FindChild("lv"):GetCmp(typeof(UILabel)).text = "Lv:"..data.lv
                tmp:FindChild("tip").gameObject:SetActive(false)

                ItemGoods.SetEquipGems(tmp.gameObject, data.gems)
                ItemGoods.SetEquipExclStar(tmp.gameObject, data.exclStar)
                ItemGoods.SetEquipEvo(tmp.gameObject, data.evo, data.rare)
                ItemGoods.AddEquipEffect(tmp.gameObject, data.rare, data.HasFrameEffect, data.IsMaxLv, data.ExclActive, data.SuitActive and data.db.sn or 0)

                tmp = tmp:FindChild("name"):GetCmp(typeof(UILabel))
                tmp.text = data.nm
                tmp.color = ColorStyle.GetRareColor(data.rare)
            else
                data = DB.GetProps(-data.sn)
                tmp:GetCmp(typeof(UISprite)).spriteName = "frame_"..data.rare
                _gt:Add(tmp:FindChild("img"):GetCmp(typeof(UITexture)):LoadTexAsync(ResName.PropsIcon(data.img)))
                tmp:FindChild("lv"):GetCmp(typeof(UILabel)).text = "x1"
                tmp:FindChild("tip").gameObject:SetActive(false)

                ItemGoods.SetEquipGems(tmp.gameObject)
                ItemGoods.SetEquipExclStar(tmp.gameObject)
                ItemGoods.SetEquipEvo(tmp.gameObject)
                ItemGoods.AddEquipEffect(tmp.gameObject, data.rare, data.rare > DB_Equip.RARE_VALUE)

                tmp = tmp:FindChild("name"):GetCmp(typeof(UILabel))
                tmp.text = data.nm
                tmp.color = ColorStyle.GetRareColor(data.rare)
            end
        else
            tmp:GetCmp(typeof(UISprite)).spriteName = ""
            tmp:FindChild("img"):GetCmp(typeof(UITexture)):UnLoadTex()
            tmp:FindChild("name"):GetCmp(typeof(UILabel)).text = ""
            tmp:FindChild("lv"):GetCmp(typeof(UILabel)).text = ""
            tmp:FindChild("tip").gameObject:SetActive(true)

            ItemGoods.SetEquipGems(tmp.gameObject)
            ItemGoods.SetEquipExclStar(tmp.gameObject)
            ItemGoods.SetEquipEvo(tmp.gameObject)
            ItemGoods.AddEquipEffect(tmp.gameObject)
        end
    end
end

local function UpdateInfo()
    _gt:Add(_texProps:LoadTexAsync(ResName.PropsIcon(DB.param.eqpEvoProp)))
    if _mainEd ~= nil then
        local tmp = user.GetPropsQty(DB.param.eqpEvoProp)
        local cost = _mainEd.evoCost
        _labNum.text = tmp.."/"..cost
        _labNum.color = tmp < cost and Color.Red or Color.green

        tmp = _mainEd.evo + 1
        _infos[1].text = tostring(_mainEd.evo)
        _infos[2].text = tostring(tmp)
        tmp = tmp + 1   -- 服务器修正
        if tonumber(_mainEd.db.estr) > 0 then
            _infos[3].text = L("武力加成:")
            _infos[4].text = _mainEd.baseStr
            _infos[5].text = _mainEd.baseStr + _mainEd.db.estr * tmp
        elseif tonumber(_mainEd.db.ehp) > 0 then
            _infos[3].text = L("生命加成:")
            _infos[4].text = tostring(_mainEd.baseHP)
            _infos[5].text = tostring(_mainEd.baseHP + _mainEd.db.ehp * tmp)
        elseif tonumber(_mainEd.db.ewis) > 0 then
            _infos[3].text = L("智力加成:")
            _infos[4].text = tostring(_mainEd.baseWis)
            _infos[5].text = tostring(_mainEd.baseWis + _mainEd.db.ewis * tmp)
        elseif tonumber(_mainEd.db.ecap) > 0 then
            _infos[3].text = L("统帅加成:")
            _infos[4].text = tostring(_mainEd.baseCap)
            _infos[5].text = tostring(_mainEd.baseCap + _mainEd.db.ecap * tmp)
        end
        if _mainEd.CanEvo then
            _infos[2].cachedGameObject:SetActive(true)
            _infos[5].cachedGameObject:SetActive(true)
        else
            _infos[2].cachedGameObject:SetActive(false)
            _infos[5].cachedGameObject:SetActive(false)
        end
        if not _mainEd:CheckEvoOblation(_subEd) then _subEd = nil end
        tmp = cost + _mainEd.evoExp
        local _a = nil 
        local _b = nil
        for i = 1, #_matEds do
            if _matEds[i] == _mainEd or _matEds[i] == _subEd then _matEds[i] = nil end
            if _matEds[i] ~= nil then
                _a, _b, cost = DB.GetEquipEvo(_matEds[i].evo, _matEds[i].rare)
                tmp = tmp + (tonumber(_matEds[i].sn) > 0 and cost or DB.GetProps(-_matEds[i].sn).val)
            end
        end
        _btnEvo.isEnabled = _subEd ~= nil
        _a, _b, cost = DB.GetEquipEvo(_mainEd.evo, _mainEd.rare)
        cost =  tmp / _b
        EF.SpringProgress(_sldPro, _mainEd.evoExp / _b, 13)
        EF.SpringProgress(_sldProT, cost, 13)
        _sldPro.transform:FindChild("evo"):GetCmp(typeof(UILabel)).text = tmp.."/".._b..string.format("(%.2f", (cost * 100)).."%)"
    else
        _labNum.text = tostring(user.GetPropsQty(DB.param.eqpEvoProp))
        _labNum.color = Color.white
        for i = 1, #_infos do _infos[i].text = "" end
        _infos[2].cachedGameObject:SetActive(false)
        _infos[5].cachedGameObject:SetActive(false)
        _subEd = nil
        _btnEvo.isEnabled = false
        _sldPro.value = 0
        _sldPro.cachedTransform:FindChild("evo"):GetCmp(typeof(UILabel)).text = ""
    end
    InitEquip(_mainE, _mainEd)
    InitEquip(_subE, _subEd)
    for i = 1, #_matEquips do InitEquip(_matEquips[i], _matEds[i]) end
end

local function OnEvo(exp)
    local wt = 3
    local mask = _body.gameObject:AddChild("mask")
    if mask then
        mask = mask:AddCmp(typeof(UIPanel))
        mask.depth = _body:GetCmp(typeof(UIPanel)).depth + 8
        mask = mask.gameObject:AddCmp(typeof(UnityEngine.BoxCollider))
        mask.isTrigger = true
        mask.size = Vector3(2160, 1080, 0)
    end

    local ef = _body:AddChild(_ef_1)
    ef:SetActive(true)
    Destroy(ef, wt+1)
   
    coroutine.wait(wt)

    if exp > 0 then
        _ef_f.text = L("熟练度+")..exp
        _ef_f:SetActive(true)
        EF.Alpha(_ef_f, 0.3, 1)
    else
        NewEffect.ShowNewEvoEquip(_mainEd)
    end
    
    coroutine.wait(0.1)

    UpdateInfo()
    if exp > 0 then
        coroutine.wait(1)
        EF.Alpha(_ef_f, 0.3, 0)
        coroutine.wait(0.3)
        _ef_f:SetActive(false)
    end

    if mask then Destroy(mask.gameObject) end
end

function win.OnLoad(c)
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "Help", "OnDispose", "OnUnLoad",
    "ClickProps", "ClickMatEquip", "ClickSubEquip", "ClickMainEquip", "ClickEvolution")

    _mainE = _ref.mainEquip
    _subE = _ref.subEquip
    _sldPro = _ref.evoPro
    _sldProT = _ref.evoProTotal
    _btnEvo = _ref.btnEvo
    _matEquips = _ref.matEquip
    
    for i=1, #_matEquips do
        local btn = _matEquips[i].luaBtn
        btn.luaContainer = _body
        btn:SetClick("ClickMatEquip", i)
    end

    _ef_1 = _ref.ef_1
    _ef_f = _ref.ef_f
    _texProps = _ref.propsUtx
    _labNum = _ref.propsNum
    --[等阶from，等阶to，属性标签，属性from，属性to]
    _infos = _ref.infos
end

function win.OnInit()
    if _gt == nil then _gt = GridTexture(128) end
    _mainEd = WinSmithy.initObj
    _props = { }
    _matEds = { }
    if _mainEd ~= nil then
        local heros = { }
        local eds = user.GetEquips(function (ed) return _mainEd:CheckEvoOblation(ed) end)
        for i = 1, #eds do
            if eds[i].IsEquiped then insert(heros, eds[i].belong)
            elseif _subEd == nil or PY_Equip.Compare(eds[i], _subEd) == false then _subEd = eds[i]
            end
        end
        if _subEd == nil then
            if #heros > 0 then
                MsgBox.Show(ColorStyle.Warning(L("可用的祭品装备正被武将穿戴")), L("查看")..","..L("确定"), function (bid) if bid == 0 then
                    Win.Open("PopHeroDetail", heros)
                end end)
            else ToolTip.ShowPopTip(ColorStyle.Warning(L("未找到可用的祭品装备")));
            end
        end
    end
    UpdateInfo()
end

function win.Help() Win.Open("PopRule", DB_Rule.EquipEvo) end

function win.OnDispose()
    if _gt ~= nil then
         _gt:Dispose()
         _gt = nil
    end
    _mainEd = nil
    _subEd = nil
    _matEds = nil
    _props = nil
end

function win.OnUnLoad()
    _body = nil
    _ef_1 = nil
    _ef_2 = nil
    _ef_f = nil
    _mainE = nil
    _subE = nil
    _texProps = nil
    _labNum = nil
    _sldPro = nil
    _sldProT = nil
    _matEquips = nil
    _infos = nil
    _btnEvo = nil
end

-------------- 按钮事件 

function win.ClickEvolution()
    if _mainEd == nil then
        ToolTip.ShowPopTip(ColorStyle.Warning(L("请先选择进阶装备")))
        return
    end
    if not _mainEd:CheckEvoOblation(_subEd) then
        _subEd = nil
        UpdateInfo()
    end
    if _subEd == nil then
         ToolTip.ShowPopTip(ColorStyle.Warning(L("请选择祭品装备")))
         return
    end

    local em = { }
    local pm = { }
    for i = 1, #_matEds do
        if tonumber(_matEds[i].sn) < 0 then insert(pm, -_matEds[i].sn)
        elseif _matEds[i].sn ~= _mainEd.sn and _matEds[i].sn ~= _subEd.sn and not table.contains(em, _matEds[i].sn) then
            insert(em, _matEds[i].sn)
        end
    end
    SVR.EquipEvo(_mainEd.sn, _subEd.sn, em, pm, function (r) if r.success then
        local exp = SVR.datCache.exp
        if tonumber(exp) <= 0 then
            user.RemoveEquip(_subEd.sn)
            _subEd = nil
        end
        for i = 1, #em do user.RemoveEquip(em[i]) end
        if #pm > 0 then _props = { } end
        _matEds = { }
        if _subEd == nil or #em > 0 then
            local pop = Win.GetOpenWin("WinGoods")
            if pop ~= nil then pop.Refresh() end
        end
        coroutine.start(OnEvo, exp)
    end end)
end

function win.ClickMainEquip()
    local datas = user.GetEquips(function (ed) return ed.CanEvo end)
    if datas ~= nil and #datas > 0 then
        table.sort(datas, PY_Equip.Compare)
        Win.Open("PopSelectEquip", { function (slts) 
            if slts ~= nil and #slts > 0 then
                _mainEd = slts[1]
                UpdateInfo()
            end 
        end, datas, { _mainEd }})
    else ToolTip.ShowPopTip(ColorStyle.Warning(L("没有可进阶的装备")))
    end
end

function win.ClickSubEquip()
    if _mainEd == nil then
        ToolTip.ShowPopTip(ColorStyle.Warning(L("请先选择进阶装备")))
        return
    end
    local datas = user.GetEquips(function (ed) return _mainEd:CheckEvoOblation(ed) end)
    if datas ~= nil and #datas > 0 then
        local avas = table.findall(datas, function (ed) return not ed.IsEquiped end)
        if avas ~= nil and #avas > 0 then
            table.sort(avas, PY_Equip.CompareInv)
            Win.Open("PopSelectEquip", { function (slts) if slts ~= nil and #slts > 0 then
                _subEd = slts[1]
                UpdateInfo()
            end end, datas, { _subEd }})
        else
            MsgBox.Show(ColorStyle.Warning(L("可用的同等阶祭品装备正被武将穿戴")), L("查看")..","..L("确定"), function (bid) if bid == 0 then
                local heros = { }
                for i = 1, #datas do insert(heros, datas[i].belong) end
                Win.Open("PopHeroDetail", heros)
            end end)
        end
    else ToolTip.ShowPopTip(ColorStyle.Warning(L("没有同等阶的祭品装备")))
    end
end

function win.ClickMatEquip(idx)
    if _matEds == nil then 
        _matEds = { } 
    end
    if _matEds[idx] ~= nil then
        _matEds[idx] = nil
        InitEquip(_matEquips[idx], nil)
        UpdateInfo()
        return
    end
    local tmp = user.GetEquips(function (ed) return not ed.IsEquiped and ed.rare > 3 and (_mainEd == nil or ed.sn ~= _mainEd.sn) and (_subEd == nil or ed.sn ~= _subEd.sn) end)
    table.sort(tmp, PY_Equip.CompareInv)
    local pm = DB.AllProps(function (p) return p.code == "equip_exp" end)
    if pm then
        table.sort(pm, DB_Props.Compare)
        local cnt = 0
        for i = #pm, 1, -1 do
            cnt = user.GetPropsQty(pm[i].sn)
            if cnt > 0 then
                cnt = Mathf.Min(#_matEquips, cnt) - #(table.findall(_props, function (ed) return -ed.sn == pm[i].sn end))
                if cnt > 0 then for j = 1, cnt do insert(_props, PY_Equip({sn = tostring(-pm[i].sn), dbsn = 0})) end end
            end
        end
    end
    for i = 1, #_props do insert(tmp, _props[i]) end
    if tmp ~= nil and #tmp > 0 then
        Win.Open("PopSelectEquip", { function (slts) 
            _matEds = slts
            if _matEds == nil then _matEds = { }
            elseif #_matEds ~= #_matEquips then
                tmp = { }
                for i = 1, #_matEquips do tmp[i] = _matEds[i] end
                _matEds = tmp
            end
            UpdateInfo()
        end, tmp, _matEds, #_matEquips })
    else ToolTip.ShowPopTip(ColorStyle.Warning(L("未找到可用的进阶材料")))
    end
end

function win.ClickProps() DB.GetProps(DB.param.eqpEvoProp):ShowData() end
