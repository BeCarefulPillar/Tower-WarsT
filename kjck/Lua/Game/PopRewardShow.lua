local isnull = tolua.isnull
local RW = RW

local _w = { }

local _queue = { }

local _body
local _ig
local _bg
local _grid
local _gridTex
local _ref

local _items = { }
local _onCallBack = nil
function _w.SetCallBack(c)
    if not c then return end
    _onCallBack = c
end

function _w.OnLoad(c)
    _body = c
    _ref = _body.nsrf.ref
    table.print("_ref", _ref)

    c:BindFunction("OnUnLoad", "OnInit", "OnDispose", "OnExit", "ClickSure", "GetBounds", "ClickItemGoods")
    if _ig == nil then _ig = AM.LoadPrefab("item_goods") end
    _bg = _ref.bg
    _grid = _ref.grid
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _bf, _grid = nil, nil
    end
end

function _w.OnInit()
    local qty = 0
    
    local rws = _w.initObj
    
    if _ig and rws and #rws > 0 then
        if _gridTex == nil then _gridTex = GridTexture(128) end
        local go, ig
        for i, r in ipairs(rws) do
            if RW.Verify(r) then
                qty = qty + 1
                go = _items[i]
                if go and not isnull(go) then
                    ig = _items[go]
                else
                    if go then _items[go] = nil end
                    go = _grid:AddChild(_ig, string.format("item_%02d", i))
                    ig = ItemGoods(go)
                    _items[i], _items[go] = go, ig
                    go.luaBtn.luaContainer = _body
                end
                ig:Init(r)
                _gridTex:Add(ig.imgl)
                ig:ShowName()
                go:SetActive(false)
                EF.FadeIn(go, 0.3)
                _w.ShowRare(r)
            end
        end
    end

    assert(qty > 0, "invalid reward data")
          
    _grid:GetCmp(typeof(UIGrid)).repositionNow = true
    local lineQty = qty < 6 and 5 or qty < 13 and math.ceil(qty * 0.5) or qty < 27 and math.ceil(qty / 3) or 9
    _grid:GetCmp(typeof(UIGrid)).maxPerLine = lineQty
    _bg.width = 1800  --Mathf.Clamp((qty > lineQty and lineQty or qty) * 100 + 40, 200, 960)
    _bg.height = Mathf.Clamp(150 * math.ceil(qty / lineQty) + 100, 250, 720)
    
    _body:AddChild(AM.LoadPrefab("ef_reward_show"), "ef_reward_show")

    _w.isOpen = true
end

function _w.OnDispose()
    _w.isOpen = false
--    if _gridTex then
--        _gridTex:Dispose()
--        _gridTex = nil
--    end
    local go
    for i = #_items, 1, -1 do
        go = _items[i]
        if isnull(go) then
            _items[go] = nil
            table.remove(_items,i)
        else
            go:SetActive(false)
            go:DesCmps(typeof("iTween"))
            go.transform.localScale = Vector3.one
        end
    end
    local f = _w.onExit
    if f then
        _w.onExit = nil
        go, f = pcall(f)
        if not go then Debugger.LogWarning(f) end
    end
    if #_queue > 0 then
        _body:Enter(table.remove(_queue, 1))
    elseif _gridTex then
        _gridTex:Dispose()
        _gridTex = nil
    end
end

function _w.GetBounds() return Bounds.empty end

function CoExit()
    local flag = false
    for i, go in ipairs(_items) do
        if go.activeSelf then
            EF.FadeOut(go, 0.3)
            EF.MoveTo(go, "position", (_items[go].dat:IsHero() and MainUI.btns.hero or MainUI.btns.bag).transform.position, "time", 0.5)
            EF.ScaleTo(go, "scale", Vector3(0.5, 0.5, 0.5), "time", 0.5)
            flag = true
        end
    end
    if flag then coroutine.wait(0.26) end
    _body.status = WIN_STAT.EXITED
end
function _w.OnExit()
    _body.status = WIN_STAT.EXITING
    coroutine.start(CoExit)
    return true
end

function _w.ClickSure()
    _body:Exit()
    if _onCallBack then
        local c = _onCallBack
        _onCallBack = nil
        c()
    end
end

function _w.ClickItemGoods(ig)
    ig = _items[ig.gameObject]
    if ig then ig:ShowPropTip() end
end

--[Comment]
--通用奖励显示接口，请使用 PopRewardShow.Show()
PopRewardShow = _w

local function ShowRw(v)
    local i = v[1]
    if i == 1 then
        --玩家属性
        i = v[2]
        if i == 1 then--银币
            ToolTip.ShowPopTip(L("银币")..ColorStyle.Silver(NameStyle.PlusTag(v[3])))
        elseif i == 2 then--金币
            ToolTip.ShowPopTip(L("金币")..ColorStyle.Gold(NameStyle.PlusTag(v[3])))
        elseif i == 3 then--血库
            ToolTip.ShowPopTip(L("血库")..ColorStyle.Good(NameStyle.PlusTag(v[3])))
        elseif i == 4 then--兵力
            ToolTip.ShowPopTip(L("兵力")..ColorStyle.Blue(NameStyle.PlusTag(v[3])))
        elseif i == 5 then--钻石
            ToolTip.ShowPopTip(L("钻石")..ColorStyle.Rmb(NameStyle.PlusTag(v[3])))
        elseif i == 6 then--粮草
            ToolTip.ShowPopTip(L("粮草")..ColorStyle.Food(NameStyle.PlusTag(v[3])))
        elseif i == 7 then--封赏令
            ToolTip.ShowPopTip(L("封赏令")..ColorStyle.Token(NameStyle.PlusTag(v[3])))
        elseif i == 8 then--魂币
            ToolTip.ShowPopTip(L("魂币")..ColorStyle.Soul(NameStyle.PlusTag(v[3])))
        elseif i == 9 then--银票
            ToolTip.ShowPopTip(L("银票")..ColorStyle.Silver(NameStyle.PlusTag(v[3])))
        elseif i == 10 then--军功
            ToolTip.ShowPopTip(L("军功")..ColorStyle.Orange(NameStyle.PlusTag(v[3])))
        elseif i == 11 then--头像
            ToolTip.ShowPopTip(L("获得头像")..ColorStyle.Orange(DB.GetAvatar(v[3]):getName()))
        elseif i == 12 then--称号
            ToolTip.ShowPopTip(L("获得称号")..ColorStyle.Orange(DB.GetHttl(v[3]):getName()))
        end
    elseif i == 2 then--道具
        NewEffect.ShowNewProps(DB.GetProps(v[2]), v[3], true, true)
    elseif i == 3 then--装备
        NewEffect.ShowNewEquip(DB.GetEquip(RW.GetEquipDBSN(v[2])), RW.GetEquipEvo(v[2]))
    elseif i == 4 then--武将
        NewEffect.ShowNewHero(DB.GetHero(v[2]))
    elseif i == 5 then--装备碎片
        i = DB.GetEquip(v[2])
        ToolTip.ShowPopTip(L("获得") .. ColorStyle.Rare(NameStyle.Piece(LN(i.nm)), i.rare) .. "×" .. (v[3] or 0))
    elseif i == 6 then--将魂
        NewEffect.ShowNewHeroSoul(DB.GetHero(v[2]))
    elseif i == 7 then--宝石
        ToolTip.ShowPopTip(L("获得宝石") .. ColorStyle.Gem(DB.GetGem(v[2])).."×" .. (v[3] or 0))
    elseif i == 8 then--副将
        NewEffect.ShowNewDehero(DB.GetDeHero(v[2]))
    elseif i == 9 then--副将经验
        i = user.GetDehero(v[3])
        if i then ToolTip.ShowPopTip(ColorStyle.Rare(i) .. " " .. ColorStyle.Blue(L("经验") .. NameStyle.PlusTag(v[2]))) end
    elseif i == 10 then--军备
        NewEffect.ShowNewDequip(user.GetDequip(v[3]))
    elseif i == 11 then--军备残片
        local dbsn, rare = PY_DequipSp.GetDbAndRareFromSn(v[2])
        i = DB.GetDequip(dbsn)
        ToolTip.ShowPopTip(L("获得") .. ColorStyle.Rare(NameStyle.Frag(i:getName(rare)), rare) .. "×" .. (v[3] or 0))
    elseif i == 12 then--玩家活动分
        i = DB.GetAct(v[2])
        ToolTip.ShowPopTip(L(i.snm) .. NameStyle.QtyTag(v[3]) .. ColorStyle.Blue(" (" .. i:getName() .. ")"))
    elseif i == 13 then
        i = DB.GetSexcl(v[2])
        ToolTip.ShowPopTip(L("获得") .. ColorStyle.Rare(i) .. "×" .. (v[3] or 0))
    elseif tonumber(i) < 0 then
        local h = user.GetHero(string.sub(tostring(i), 2))
        if h then
            i = v[2]
            if i == 1 then--EXP
                ToolTip.ShowPopTip(ColorStyle.Rare(h) .. " " .. L(""..L("EXP") .. ColorStyle.Good(NameStyle.PlusTag(v[3]))))
            elseif i == 2 then--HP
                ToolTip.ShowPopTip(ColorStyle.Rare(h) .. " " .. L("生命上限") .. ":" .. math.max(h.MaxHP - v[3], 0) .. "→" .. h.MaxHP .. "[" .. ColorStyle.Good(NameStyle.PlusTag(v[3])) .. "]")
            elseif i == 3 then--SP
                ToolTip.ShowPopTip(ColorStyle.Rare(h) .. " " .. L("技力") .. ":" .. math.max(h.MaxSP - v[3], 0) .. "→" .. h.MaxSP .. "[" .. ColorStyle.Good(NameStyle.PlusTag(v[3])) .. "]")
            elseif i == 4 then--TP
                ToolTip.ShowPopTip(ColorStyle.Rare(h) .. " " .. L("兵力") .. ":" .. math.max(h.MaxTP - v[3], 0) .. "→" .. h.MaxTP .. "[" .. ColorStyle.Good(NameStyle.PlusTag(v[3])) .. "]")
            elseif i == 5 then--武力
                ToolTip.ShowPopTip(ColorStyle.Rare(h) .. " " .. L("武力") .. ":" .. math.max(h.MaxStr - v[3], 0) .. "→" .. h.MaxStr .. "[" .. ColorStyle.Good(NameStyle.PlusTag(v[3])) .. "]")
            elseif i == 6 then--智力
                ToolTip.ShowPopTip(ColorStyle.Rare(h) .. " " .. L("智力") .. ":" .. math.max(h.MaxWis - v[3], 0) .. "→" .. h.MaxWis .. "[" .. ColorStyle.Good(NameStyle.PlusTag(v[3])) .. "]")
            elseif i == 7 then--忠诚
                ToolTip.ShowPopTip(ColorStyle.Rare(h) .. " " .. L("忠诚") .. ColorStyle.Good(NameStyle.PlusTag(v[3])))
            elseif i == 8 then--统帅
                ToolTip.ShowPopTip(ColorStyle.Rare(h) .. " " .. L("统帅") .. ":" .. math.max(h.MaxCap - v[3], 0) .. "→" .. h.MaxCap .. "[" .. ColorStyle.Good(NameStyle.PlusTag(v[3])) .. "]")
            elseif i == 9 then--精力
                ToolTip.ShowPopTip(ColorStyle.Rare(h) .. " " .. L("精力") .. ColorStyle.Good(NameStyle.PlusTag(v[3])))
            end
        end
    end
end
local function CoShowRws(rws)
    if rws == nil or #rws < 1 then return end
    for i, v in ipairs(rws) do
        ShowRw(v)
        coroutine.wait(0.3)
    end
end
function _w.Show(rws)
        print(#rws)
    if RW.Verify(rws) then
        ShowRw(rws)
    else
        rws = RW.CullCon(rws)
        print(#rws)
        if #rws < 1 then return end
        --武将属性特殊处理
        if #rws > 1 and tonumber(rws[1][1]) > 0 then
            if _w.isOpen then
                table.insert(_queue, rws)
            else
                Win.Open("PopRewardShow", rws)
            end
        else
            coroutine.start(CoShowRws, rws)
        end
    end
end

local function ShowRare(r, showTip)
    local i = r[1]
    if i == 2 then--道具
        NewEffect.ShowNewProps(DB.GetProps(r[2]), r[3] or 0, true, showTip)
    elseif i == 3 then--装备
        NewEffect.ShowNewEquip(DB.GetEquip(RW.GetEquipDBSN(r[2])), RW.GetEquipEvo(r[2]), true, showTip)
    elseif i == 4 then--武将
        NewEffect.ShowNewHero(DB.GetHero(r[2]), showTip)
    elseif i == 6 then--将魂
        NewEffect.ShowNewHeroSoul(DB.GetHero(r[2]), true, showTip)
    elseif i == 8 then--副将
        NewEffect.ShowNewDehero(DB.GetDeHero(r[2]), true, showTip)
    elseif i == 10 then--军备
        NewEffect.ShowNewDequip(user.GetDequip(v[3]), true, showTip)
    end
end
---<summary>稀有物品显示</summary>
function _w.ShowRare(rws, showTip)
    if RW.Verify(rws) then
        ShowRare(rws, showTip)
    elseif #rws > 0 then
        for _, v in ipairs(rws) do
            ShowRare(v, showTip)
        end
    end
end