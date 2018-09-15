local _w = { }

local _body = nil
local _ref = nil

local _item_goods = nil
local _grid = nil
local _tip = nil

local _cityName = nil

local _btnUse = nil
----------------------------
local _selected = nil
local _cityIdx = -1
local _gridTex = nil


local function ClickItem(btn)
    local ig = Item.Get(btn.gameObject)
    if ig then
        ig:ShowPropTip()
        if _selected == ig then
            return
        end
        if _selected then
            _selected.Selected = false
        end
        _selected = ig
        _selected.Selected = true
--        UpdateSelectInfo()
    end
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK })
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad", "ClickUse")
    _ref = c.nsrf.ref
    _item_goods = _ref.item_goods
    _grid = _ref.grid
    _tip = _ref.tip
    _cityName = _ref.cityName
    _btnUse = _ref.btnUse
end

function _w.OnInit() 
     _cityIdx = type(_w.initObj) == "number" and _w.initObj or -1
    if _cityIdx < 0 or PY_Nat.IsCapital(_cityIdx) then
        ToolTip.ShowPopTip(L("选择的城池不正确"))
        Destroy(_body.gameObject)
        return
    end

    if _gridTex == nil then _gridTex = GridTexture(128) end

    _cityName.text = L("目标城池：")..DB.GetNatCity(_cityIdx).nm

    local props = nil
    props = user.GetProps(function(p)
        return p.trg == 5
    end)

    local len = #props
    for i = 1, len do
        local ig = ItemGoods(_grid:AddChild(_item_goods, string.format("goods_%02d", i)))
        ig:Init(props[i])
        ig.go.luaBtn:SetClick(ClickItem)
        ig:ShowName()

        if not _selected then
            _selected = ig
            _selected.Selected = true
        end
    end

    _tip:SetActive(len <= 0)
    _grid:GetCmp(typeof(UIGrid)).repositionNow = true

end

function _w.OnDispose()
    if _gridTex then
        _gridTex:Dispose()
        _gridTex = nil
    end
    _selected = nil
    _grid:DesAllChild()
end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
    
    _item_goods = nil
    _grid = nil
    _tip = nil
    _cityName = nil
    _btnUse = nil
end

function _w.ClickUse()
    if _cityIdx < 0 or PY_Nat.IsCapital(_cityIdx) then
        ToolTip.ShowPopTip(L("选择的城池不正确"))
        return
    end

    local p = _selected and _selected.dat or nil
    if p == nil or p.sn <= 0 or p.trg ~= 5 then
        ToolTip.ShowPopTip(L("请选择可使用的道具"))
        return
    end
    if p.sn == DB_Props.AN_DU_CHEN_CANG and p.qty > 0 then
        --暗渡陈仓
        Win.Open("PopSelectHero", {
            SelectHeroFor.NatOption, function(hero)
                if #hero > 0 then
                    local ch = user.nat:GetHero(hero[1])
                    if ch and ch.CurStatus == PY_NatHero.Status.Idle then
                        SVR.UsePropsForNat(p.sn, _cityIdx, hero[1], function(result)
                            if result.success then
                                ToolTip.ShowPopTip(L("使用成功"))
                                PY_NatHero.SetCity(ch, _cityIdx)
                                coroutine.start(Tools.ShowUseProps(_selected.go))
                            end
                        end )
                    end
                end
            end
        } )
    else
        --其它使用
        if p.qty > 0 then
            SVR.UsePropsForNat(p.sn, _cityIdx, 0, function(result)
                if result.success then
                    ToolTip.ShowPopTip(L("使用成功"))
                    BGM.PlaySOE("sound_cost_prop")
                    coroutine.start(Tools.ShowUseProps, _selected.go)
                end
            end)
        else
            ToolTip.ShowPopTip(L("主公，您还没有这个计谋卷轴，无法使用"))
        end
        
    end
end

--[Comment]
--国战使用计谋
PopNatProps = _w