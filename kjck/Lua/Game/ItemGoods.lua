local type = type
local isnull = tolua.isnull

local _item =
{
    --[Comment]
    --ItemGoods的根对象
    go = nil,
    --[Comment]
    --边框
    frame = nil,
    --[Comment]
    --图像加载器
    imgl = nil,
    --[Comment]
    --名称Label
    name = nil,
    --[Comment]
    --数量Label
    num = nil,
    --[Comment]
    --遮罩
    mask = nil,

    --[Comment]
    --数据对象
    dat = nil,
    --[Comment]
    --数据对象的类型
    datTyp = nil,
    --[Comment]
    --初始化参数
    intArg = nil,

    --[Comment]
    --选中框
    sltSp = nil,
    --[Comment]
    --禁用标签
    avaSp = nil,
    --[Comment]
    --使用标签
    useSp = nil,
    --[Comment]
    --碎片标签
    picSp = nil,
}

--[Comment]
--移除所有装备的效果
local function RemoveEquipEffect(go)
    if isnull(go) then return end
    go:DesChild("ef_equip_fl", "ef_equip_fr", "ef_equip_cn", "ef_equip_ch", "ef_equip_st")
end
--[Comment]
--移除所有装备的效果
_item.RemoveEquipEffect = RemoveEquipEffect
--[Comment]
--添加装备图标效果
local function AddEquipEffect(go, rare, frame, maxlv, excl, suit)
    if frame then
        local cor = rare == -1 and Color(1, 0.94, 0.66) or ColorStyle.GetRareColor(rare) * 1.6
        local eft = go:ChildWidget("ef_equip_fl") or go:AddChild(AM.LoadPrefab("ef_equip_fl"), "ef_equip_fl"):GetCmp(typeof(UITrail))
        eft.color = cor
        CS.Call(eft:GetCmp(typeof("PathMove")), "Reset")
        eft = go:ChildWidget("ef_equip_fr") or go:AddChild(AM.LoadPrefab("ef_equip_fr"), "ef_equip_fr"):GetCmp(typeof(UITrail))
        eft.color = cor
        CS.Call(eft:GetCmp(typeof("PathMove")), "Reset")
    else
        go:DesChild("ef_equip_fl", "ef_equip_fr")
    end

    if maxLv then
        if isnull(go:Child("ef_equip_cn")) then go:AddChild(AM.LoadPrefab("ef_equip_cn"), "ef_equip_cn") end
    else
        go:DesChild("ef_equip_cn")
    end

    if excl then
        if isnull(go:Child("ef_equip_ch")) then go:AddChild(AM.LoadPrefab("ef_equip_ch"), "ef_equip_ch") end
    else
        go:DesChild("ef_equip_ch")
    end
end
--[Comment]
--添加装备图标效果
_item.AddEquipEffect = AddEquipEffect
--[Comment]
--配置装备的进阶标签
local function SetEquipEvo(go, evo, rare)
    if isnull(go) then return end
    if evo and evo > 0 then
        local w = go:ChildWidget("equip_evo")
        if w then
            w.text = "[b]+" .. evo
            w:ChildWidget(0).spriteName = "sp_evo"
        else
            w = go:AddWidget(typeof(UILabel), "equip_evo")
            w.trueTypeFont = AM.mainFont
            w.fontSize = 32
            w.supportEncoding = true
            w.applyGradient = false
            --w.gradientBottom = Color.red
            --w.gradientTop = Color.yellow
            w.overflowMethod = UILabel.Overflow.ShrinkContent
            w.effectStyle = UILabel.Effect.Outline
            w.effectColor = Color.black
            w.effectDistance = Vector2(0.4, 0.4)
            w.width = 26
            w.height = 18
            w.depth = 15
            w.text = "[b]+" .. evo
            w.cachedTransform.localPosition = Vector3(33, 38, 0)

            w = w:AddWidget(typeof(UISprite), "bg")
            w.atlas = AM.mainAtlas
            w.spriteName = "sp_evo"
            w:MakePixelPerfect()
            w.depth = 11
        end
    else
        go:DesChild("equip_evo")
    end
end
--[Comment]
--配置装备的进阶标签
_item.SetEquipEvo = SetEquipEvo
--[Comment]
--给装备增加宝石图标
local function SetEquipGems(go, gems)
    if isnull(go) then return end
    local len = gems and table.maxn(gems) or 0
    if len < 1 then return go:DesChild("gems") end

    local t = go:Child("gems") or go:AddChild("gems").transform

    local qty = t.childCount
    local sp, g = nil, nil
    for i = 1, len do
        if i > qty then
            sp = t:AddWidget(typeof(UISprite), "gem_" .. i)
            sp.atlas = AM.mainAtlas
            sp.width, sp.height, sp.depth = 18, 18, 111
        else
            sp = t:ChildWidget(i - 1)
        end
        g = gems[len - i + 1]
        sp.spriteName = "gem_" ..(g and g > 0 and DB.GetGem(g).color or "f")
    end

    if qty > len then
        for i = len, qty - 1 do CS.DesGo(t:GetChild(i)) end
    end

    qty = t.childCount
    sp = qty > 4 and 80 / qty or 20
    for i = 0, qty - 1 do
        t:GetChild(i).localPosition = Vector3(-35, -35 + sp * i);
    end
end
--[Comment]
--给装备增加宝石图标
_item.SetEquipGems = SetEquipGems
--[Comment]
--配置装备专属锻造等级
local function SetEquipExclStar(go, star)
    if isnull(go) then return end
    if star and star > 0 then
        local t = go:Child("equip_excl_star")
        if isnull(t) then
            t = go:AddWidget(typeof(UISprite), "equip_excl_star")
            t.atlas = AM.mainAtlas
            t.spriteName = "tag_excl_forge";
            t.cachedTransform.localPosition = Vector3(30, 30, 0)
            t:MakePixelPerfect()
            t.depth = 6
        end
    else
        go:DesChild("equip_excl_star")
    end
end
--[Comment]
--配置装备专属锻造等级
_item.SetEquipExclStar = SetEquipExclStar
--[Comment]
--配置技能五行
local function SetSkcFe(go, fesn)
    if isnull(go) then return end
    if fesn and fesn > 0 then
        local t = go:Child("skc_fe")
        if isnull(t) then
            t = go:AddWidget(typeof(UISprite), "skc_fe")
            t.atlas = AM.mainAtlas
            t.spriteName = "tag_fe_" .. fesn
            t.cachedTransform.localPosition = Vector3(-22, 22, 0)
            t:MakePixelPerfect()
            t.width, t.height, t.depth = 32, 32, 6
        else
            t = t:GetCmp(typeof(UISprite))
            if t then t.spriteName = "tag_fe_" .. fesn end
        end
    else
        go:DesChild("skc_fe")
    end
end
--[Comment]
--移除所有标签
local function RemoveAllTag(go)
    SetEquipEvo(go)
    SetEquipGems(go)
    SetEquipExclStar(go)
    SetSkcFe(go)
end
--[Comment]
--配置技能五行
_item.SetSkcFe = SetSkcFe
--[Comment]
--类型和显示框的映射
local _typFrame =
{
    [DB_Arm] = "frame_props",
    [DB_Avatar] = "frame_vip",
--    [DB_Beauty] = "frame_hero",
    [DB_Buff] = "frame_hero",
    [DB_Equip] = "frame_",

    [DB_Gem] = "frame_gem",
    [DB_Hero] = "frame_props",
    [PY_Soul] = "frame_hero_soul",
    [DB_SKC] = "frame_props",
}
--_typFrame[DB_Dehero] = _typFrame[DB_Equip]
--_typFrame[DB_Dequip] = _typFrame[DB_Equip]
--_typFrame[DB_Beauty] = _typFrame[DB_Hero]
_typFrame[DB_Lnp] = _typFrame[DB_Arm]
_typFrame[DB_SKC] = _typFrame[DB_SKC]
--_typFrame[DB_SKD] = _typFrame[DB_Arm]
_typFrame[DB_SKE] = _typFrame[DB_Arm]
_typFrame[DB_SKP] = _typFrame[DB_Arm]
--_typFrame[DB_SKS] = _typFrame[DB_Arm]
_typFrame[DB_SKT] = _typFrame[DB_Arm]
--_typFrame[PY_Dehero] = _typFrame[DB_Dehero]
--_typFrame[PY_Dequip] = _typFrame[DB_Dequip]
--_typFrame[PY_DequipSp] = _typFrame[DB_Dequip]
_typFrame[PY_Equip] = _typFrame[DB_Equip]
_typFrame[PY_EquipSp] = _typFrame[DB_Equip]
_typFrame[PY_Gem] = _typFrame[DB_Gem]
_typFrame[PY_Hero] = _typFrame[DB_Equip]
--[Comment]
--配置框样式
local function SetFrame(sp, d, tp)
    if isnull(sp) or d == nil then return end
    tp = tp or objt(d)
    tp = _typFrame[tp] or d.frame or "frame_props"
    sp.spriteName = tp == "frame_" and tp ..(d.rare or 1) or tp
    if "frame_props" == tp then
        sp.width, sp.height = 100, 100
    elseif "frame_vip" == tp then
        sp.width, sp.height = 84, 84
    elseif "frame_props" == tp then
        sp.width, sp.height = 100, 100
    else
        sp.width, sp.height = 100, 100
    end
--    sp.type =(tp == "frame_dehero_exp" or tp == "frame_vip" or tp == "frame_gem") and UIBasicSprite.Type.Sliced or UIBasicSprite.Type.Simple
    sp.type = UIBasicSprite.Type.Sliced 
end
--[Comment]
--配置框样式
_item.SetFrame = SetFrame
--[Comment]
--名称是否配色
local function NameNoColor(d, tp)
    tp = tp or objt(d)
    if tp == RW then tp = tp.datTyp end
    return tp == DB_Props or tp == DB_Gem or tp == PY_Props or tp == PY_Gem or tp == PY_Soul
end

--[Comment]
--检测对象是否存活
local function CheckDead(i)
    if isnull(i.go) then
        if i.go then
            i.go = nil
            if i.dat and i.dat.RemoveObserver then i.dat:RemoveObserver(i) end
            table.clear(i)
        end
        return true
    end
end

--[Comment]
--释放(ef=保留特效)
local function Dispose(i)
    if i.frame then i.frame.type = UIBasicSprite.Type.Simple end
    i.dat = DataCell.DataChange(i.dat, nil, i)
    i.lock = nil
end

--[Comment]
--构造
function _item.New(go)
    assert(not isnull(go), "create ItemGoods need GameObject")
    return
    {
        go = go,
        frame = go.widget,
        imgl = go:Child("img",typeof(UITextureLoader)),
        name = go:ChildWidget("name"),
        num = go:ChildWidget("num"),
        mask = go:ChildWidget("mask"),
    }
end

--[Comment]
--初始化函数
local ifunc =
{
    --[Comment]
    --奖励对象初始化
    [RW] = function(i, d)
        i.Available = d.qty == nil or d.qty > 0
        i.BeUsed = false
        i.IsPiece = d:IsPiece()

        local go = i.go
        SetEquipEvo(go, d.evo, d.rare)
        SetEquipGems(go)
        SetEquipExclStar(go)
        SetSkcFe(go)

        local v1 = d[1]
        if v1 == 3 then
            AddEquipEffect(go, d.rare, d.rare > DB_Equip.RARE_VALUE)
        elseif v1 == 4 then
            AddEquipEffect(go, -1, true)
        else
            RemoveEquipEffect(go)
        end
    end,
    --道具
    [PY_Props] = function(i, d)
        i.Available = d.qty and d.qty > 0
        i.BeUsed, i.IsPiece = false, false
        RemoveAllTag(i.go)
        RemoveEquipEffect(i.go)
    end,
    --装备碎片
    [PY_EquipSp] = function(i, d)
        i.Available = d.qty and d.qty > 0
        i.BeUsed, i.IsPiece = false, true
        RemoveAllTag(i.go)
        AddEquipEffect(i.go, d.db.rare, d:Compose())
    end,
    --装备
    [PY_Equip] = function(i, d)
        i.Available, i.BeUsed, i.IsPiece = true, d.IsEquiped, false
        local go = i.go
        SetEquipEvo(go, d.evo, d.rare)
        SetEquipGems(go, d.gems)
        SetEquipExclStar(go, d.exclStar)
        SetSkcFe(go)
        AddEquipEffect(go, d.rare, d.HasFrameEffect, d.IsMaxLv, d.ExclActive, d.SuitActive and d.dbsn or 0)
    end,
    --军备
--    [PY_Dequip] = function(i, d)
--        i.Available, i.BeUsed, i.IsPiece = true, d.IsEquiped, false

--        local qty = 0
--        local extQty = d.ExtQty
--        if extQty > 0 then
--            for i = 1, extQty do
--                if d:GetExtLv(i) >= d.lvd.extLv then qty = qty + 1 end
--            end
--        end

--        local go = i.go
--        RemoveAllTag(go)
--        AddEquipEffect(go, d.rare, qty > 0 and qty >= extQty)
--    end,
    --兵种
    [DB_Arm] = function(i, d, ava, use, lock, lv)
        if lv and lv > 0 then i.num.text = NameStyle.LvTag(lv) end
        i.Available, i.BeUsed, i.lock, i.IsPiece = ava, use, lock, false
        RemoveAllTag(i.go)
        RemoveEquipEffect(i.go)
    end,
    --阵型
    [DB_Lnp] = function(i, d, ava, use, lock, imp)
        if imp and imp > 0 then i.num.text = NameStyle.PlusTag(imp) end
        i.Available, i.BeUsed, i.lock, i.IsPiece = ava, use, lock, false
        RemoveAllTag(i.go)
        RemoveEquipEffect(i.go)
    end,
    --武将技
    [DB_SKC] = function(i, d, ava, lv, lock, use, fe)
        if lv and lv > 0 then i.num.text = NameStyle.LvTag(lv) end
        i.Available, i.BeUsed, i.lock, i.IsPiece = ava, use, lock, false
        local go = i.go
        SetEquipEvo(go)
        SetEquipGems(go)
        SetEquipExclStar(go)
        SetSkcFe(go, fe)
        RemoveEquipEffect(go)
    end,
    --头像
    [DB_Avatar] = function(i, d, use)
        i.Available, i.BeUsed, i.IsPiece = true, use, false
        RemoveAllTag(i.go)
        RemoveEquipEffect(i.go)
    end,
}
ifunc[DB_SKT] = ifunc[DB_SKC]
ifunc[DB_SKE] = ifunc[DB_SKC]
ifunc[DB_SKP] = ifunc[DB_SKC]
--ifunc[DB_SKS] = ifunc[DB_SKC]
--ifunc[DB_SKD] = ifunc[DB_SKC]
ifunc[PY_Gem] = ifunc[PY_Props]
ifunc[PY_Soul] = ifunc[PY_Props]
--ifunc[PY_DequipSp] = ifunc[PY_EquipSp]
--ifunc[PY_Sexcl] = ifunc[PY_Props]

--[Comment]
--初始化
function _item.Init(i, d, ...)
    if CheckDead(i) then return end
    if d == nil then
        i.dat, i.datTyp = nil, nil
        i.name.text = nil
        i.num.text = nil
        sp.spriteName = "frame_props"
        i.imgl:Dispose()
        RemoveEquipEffect()
        RemoveAllTag()
        i.Available, i.BeUsed, i.IsPiece = true, false, false
        return
    end

    Dispose(i)

    local tp = objt(d)
    if tp == nil then
        tp = RW
        d = tp(d)
        if d == RW.undef then return end
    else
        i.dat = DataCell.DataChange(i.dat, d, i)
    end

    i.dat, i.datTyp = d, tp

    local fn = d.itemName or d.getName
    i.name.text = fn and fn(d) or LN(d.nm)
    if tp == PY_Soul then i.name.text = i.name.text .."(将魂)" end
    i.name.color = NameNoColor(d, tp) and Color.white or ColorStyle.GetRareColor(d.rare)
    i.num.text = d.qty and NameStyle.QtyTag(d.qty) or d.lv and NameStyle.LvTag(d.lv) or ""
    if RW.IsHero(d) then
        i.num.text = nil
    end
    SetFrame(i.frame, d, tp)

    local ifc = ifunc[tp]
    if ifc then
        ifc(i, d, ...)
    else
        i.Available = true
        i.BeUsed = false
        i.IsPiece = false
        RemoveEquipEffect()
        RemoveAllTag()
    end

    i.imgl:Load(ResName.GetItemIco(d, tp))
end

--[Comment]
--DataCell是否存活接口
function _item.alive(i) return not CheckDead(i) end
--[Comment]
--DataCell数据更改接口
function _item.OnDataChange(i, d) _item.Init(i, i.dat) end

--[Comment]
--ToolTip显示
function _item.ShowPropTip(i)
    i = i.dat
    local f = i.getPropTip
    if f then ToolTip.ShowPropTip(f(i)) end
end

--[Comment]
--销毁时
_item.OnDestroy = Dispose

--[Comment]
--隐藏名称
function _item.HideName(i) i.name:SetActive(false) end
--[Comment]
--显示名称
function _item.ShowName(i) i.name:SetActive(true) end

--属性 读
_item.__get =
{
    --[Comment]
    --是否被选择
    Selected = function(i) return i.sltSp end,
    --[Comment]
    --是否为熔炼界面被选择（打勾勾）
    MeltSelected = function(i) return i.sltSp end,
    --[Comment]
    --是否可用
    Available = function(i) return i.avaSp == nil end,
    --[Comment]
    --是否被使用
    BeUsed = function(i) return i.useSp end,
    --[Comment]
    --是否是碎片
    IsPiece = function(i) return i.picSp end,
}
--属性 写
_item.__set =
{
    --[Comment]
    --是否被选择
    Selected = function(i, v)
        if CheckDead(i) then return end
        local sp = i.sltSp
        if v then
            if sp == nil then
                sp = i.go:AddWidget(typeof(UISprite), "sp_slt")
                i.sltSp = sp
                sp.atlas = AM.mainAtlas
                sp.spriteName = "frame_selected"
                sp.type = UIBasicSprite.Type.Sliced
                v = i.frame and i.frame.spriteName
                if "frame_props" == v then
                    sp.width, sp.height = 118, 118
                elseif "frame_props" == v then
                    sp.width, sp.height = 100, 100
                elseif v and "frame_" == string.sub(v, 1, 6) then
                    sp.width, sp.height = 118, 118
                end
                sp.depth = 9
            end
        elseif sp then
            CS.DesGo(sp)
            i.sltSp = nil
        end
    end,
    --[Comment]
    --是否为熔炼界面被选择（打勾勾）
    MeltSelected = function(i, v)
        if CheckDead(i) then return end
        local sp = i.sltSp
        if v then
            if sp == nil then
                sp = i.go:AddWidget(typeof(UISprite), "sp_slt")
                i.sltSp = sp
                sp.atlas = AM.mainAtlas
                sp.cachedTransform.localPosition = Vector3(15, -15, 0)
                sp.spriteName = "check_true"
                sp.width, sp.height = 40, 40
                sp.depth = 9;
            end
        elseif sp then
            CS.DesGo(sp)
            i.sltSp = nil
        end
    end,
    --[Comment]
    --是否可用
    Available = function(i, v)
        if CheckDead(i) then return end
        local sp = i.avaSp
        if v then
            if sp then
                i.mask:SetActive(false)
                if sp.isVisible then
                    EF.ShakePosition(sp, "amount", Vector3(2, 2), "islocal", true, "time", 0.5)
                    WidgetEffect.Detonate(sp, 5, 5, 0.5, true, 10, 30);
                else
                    CS.DesGo(sp)
                end
                i.avaSp = nil
            end
        else
            i.mask:SetActive(true)
            if sp == nil then
                sp = i.go:AddWidget(typeof(UISprite), "sp_ava")
                i.avaSp = sp
                sp.atlas = AM.mainAtlas
                v = i.frame and i.frame.spriteName
                if "frame_props" == v then
                    sp.width, sp.height = 90, 85
                else
                    sp.width, sp.height = 80, 80
                end
            end
            v = objt(i.dat)
            if v == DB_SKC or v == DB_SKT or v == DB_SKE or v == DB_SKP or v == DB_Arm or v == DB_Lnp then
                sp.spriteName = "sp_lock_2"
                sp:MakePixelPerfect()
            else
                sp.spriteName = "check_false"
                sp.color = Color(0, 0, 0, 0.6)
            end
        end
    end,
    --[Comment]
    --是否被使用
    BeUsed = function(i, v) 
        if CheckDead(i) then return end
        if v then
            v = i.datTyp
            if v == DB_Arm or v == DB_Lnp or v == PY_Equip or v == DB_SKP or v == PY_Dequip or v == DB_Avatar then
                local sp = i.useSp
                if sp == nil then 
                    sp = i.go:AddWidget(typeof(UISprite), "used")
                    i.useSp = sp
                    sp.atlas = AM.mainAtlas
                    sp.spriteName =(v == PY_Equip or v == PY_Dequip) and "sp_equip" or "sp_using"
                    sp.width, sp.height = 43, 43
                    sp.cachedTransform.localPosition = Vector3(-24, 25, 0)
                    sp.depth = 9
                end
                return
            end
        else
            if i.useSp then CS.DesGo(i.useSp); i.useSp = nil end
        end
    end,
    --[Comment]
    --是否被使用
    IsPiece = function(i, v)
        if CheckDead(i) then return end
        if v then
            v = i.datTyp
            if v == PY_EquipSp or v == PY_DequipSp or(v == RW and RW.IsPiece(i.dat)) then
                local sp = i.picSp
                if sp == nil then
                    sp = i.go:AddWidget(typeof(UISprite), "piece")
                    i.picSp = sp
                    sp.atlas = AM.mainAtlas
                    sp.spriteName = "sp_piece";
                    sp.width, sp.height = 100, 100
                    sp.depth = 9
                end
                return
            end
        end
        if i.picSp then CS.DesGo(i.picSp); i.picSp = nil end
    end,
}

--继承
objext(_item, Item)
--[Comment]
--通用Item
ItemGoods = _item
