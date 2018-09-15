
local _w = { }

local _ref = nil
local _body = nil


local _cfgs =
{
    LevelMap = { tip = "", asSquare = true, ext = { x = 12, y = 32, z = 12, w = 10 }, grid = { 90, 90, 5 }, offset = Vector3(-20, 0, 0) },
    --   PopItemA20 = { asSquare = true, ext = { x = 12, y = 12, z = 12, w = 12 }, grid = { 88, 132, 6 }, offset = Vector3.zero },
    undef = { asSquare = false, ext = { x = 0, y = 0, z = 0, w = 0 }, grid = { 80, 80, 5 }, offset = Vector3.zero }
}
local _cfg = nil
local _rwsLen = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _cfg = _cfgs["LevelMap"] or _cfgs.undef
    c:BindFunction("OnUnLoad", "OnInit", "OnEnter", "OnDispose", "FloatExit")
end

function _w.OnUnLoad(c)
    if _body ~= c then return end
    _body = nil
end

function _w.OnInit()
    local obj = _w.initObj
    local rws = nil

    if obj and obj.str and obj.rws then
        _ref.labTips.text = obj.str
        rws = obj.rws
        _rwsLen = #rws
        _cfg.offset = Vector3(-20, _ref.labTips.height, 0)
        if _rwsLen < 1 then
            _body:Exit()
            return
        end
    elseif obj and #obj > 0 then
        rws = obj
        _rwsLen = #rws
        if _rwsLen < 1 then
            _body:Exit()
            return
        end
    else
        _body:Exit()
        return
    end

    _w.ShowRewards(rws)
end

function _w.ShowRewards(rws)
    local prefab, root, grid = _ref.itemGood, _ref.itemGrid, _cfg.grid
    local ig = nil
    for i = 1, _rwsLen do
        ig = ItemGoods(root:AddChild(prefab, string.format("item_%02d", i), false))
        ig:Init(rws[i])
        ig.go:SetActive(true)
        if ig.dat then
            ig.go:GetCmp(typeof(LuaButton)):SetClick(_w.ClickGoods)
            ig:HideName()
        else
            Destroy(ig.go)
        end
    end
    if _ref.itemGrid.activeInHierarchy then
        _w.CheckPosition();
    end
end

function _w.ClickGoods(btn)
    local ig = Item.Get(btn.gameObject)
    if ig then
        ig:ShowPropTip()
    end
end

function _w.CheckPosition()
    local grid = _ref.itemGrid:GetCmp(typeof(UIGrid))
    if grid ~= nil then
        if _cfg.asSquare then
            if _rwsLen > 3 then
                grid.maxPerLine = math.ceil(Mathf.Sqrt(_rwsLen));
            end
        end
        grid.onReposition = _w.OnReposition
        if _ref.itemGrid.activeInHierarchy then
            grid:Reposition()
        else
            grid.repositionNow = true;
        end
    else
        _w.OnReposition()
    end
end

function _w.OnEnter()
    _w.CheckPosition();
end

function _w.OnReposition()
    local pos = _body.cachedTransform
    pos.position = UICamera.lastWorldPosition
    pos = pos.localPosition

    local ext = _cfg.ext
    local offset = _cfg.offset
    local b = NGUIMath.CalculateRelativeWidgetBounds(_ref.itemGrid.transform)

    local width = Mathf.Round(b.size.x + ext.x + ext.z)
    local height = Mathf.Round(b.size.y + ext.y + ext.w)

    local bg = _ref.background
    if bg then
        bg.width = width
        bg.height = height
    end

    local halfX = SCREEN.WIDTH * 0.5
    local halfY = SCREEN.HEIGHT * 0.5

    if pos.y + height + offset.y <= halfY then
        if _ref.labTips and string.notEmpty(_ref.labTips.text) then
            --背景拉长
            _ref.background.height = _ref.background.height + _ref.labTips.height
            if _ref.labTips.width>width then
                _ref.background.width=_ref.background.width+_ref.labTips.width-width+14
            end
            _ref.labTips.transform.localPosition = Vector3(-_ref.background.width/2+10,_ref.background.height/2-10,0)
        end
        if width + offset.x + pos.x <= halfX then
            --右上
            _ref.itemGrid.transform.localPosition = offset - b.min + Vector3(ext.x, ext.y)
            if bg then
                bg.flip = UIBasicSprite.Flip.Nothing
                bg = bg.cachedTransform
                b = NGUIMath.CalculateRelativeWidgetBounds(bg)
                bg.localPosition = offset - b.min
            end
            return
        end
        if pos.x - width - offset.x >= - halfX then
            --左上
            _ref.itemGrid.transform.localPosition = Vector3(- ext.x - b.max.x - offset.x, ext.y - b.min.y + offset.y)
            if bg then
                bg.flip = UIBasicSprite.Flip.Horizontally
                bg = bg.cachedTransform
                b = NGUIMath.CalculateRelativeWidgetBounds(bg)
                bg.localPosition = - Vector3(b.max.x + offset.x, b.min.y - offset.y)
            end
            return
        end
    elseif pos.y - height - offset.y >= - halfY then
        if width + offset.x + pos.x <= halfX then
            --右下
            _ref.itemGrid.transform.localPosition = Vector3(ext.x - b.min.x + offset.x, - ext.y - b.max.y - offset.y)
            if bg then
                bg.flip = UIBasicSprite.Flip.Vertically
                bg = bg.cachedTransform
                b = NGUIMath.CalculateRelativeWidgetBounds(bg)
                bg.localPosition = - Vector3(b.min.x - offset.x, b.max.y + offset.y)
            end
            return
        end
        if pos.x - width - offset.x >= - halfX then
            --左下
            _ref.itemGrid.transform.localPosition = - offset - b.max + Vector3(- ext.x, - ext.y)
            if bg then
                bg.flip = UIBasicSprite.Flip.Both
                bg = bg.cachedTransform
                b = NGUIMath.CalculateRelativeWidgetBounds(bg)
                bg.localPosition = - offset - b.max
            end
            return
        end
    end

    --默认
    if pos.y >= 0 then
        if pos.x >= 0 then
            --右上
            _ref.itemGrid.transform.localPosition = offset - b.min + Vector3(ext.x, ext.y)
            if bg then
                bg.flip = UIBasicSprite.Flip.Nothing
                bg = bg.cachedTransform
                b = NGUIMath.CalculateRelativeWidgetBounds(bg)
                bg.localPosition = offset - b.min
            end
            return
        end
        --左上
        _ref.itemGrid.transform.localPosition = Vector3(- ext.x - b.max.x - offset.x, ext.y - b.min.y + offset.y)
        if bg then
            bg.flip = UIBasicSprite.Flip.Horizontally
            bg = bg.cachedTransform
            b = NGUIMath.CalculateRelativeWidgetBounds(bg)
            bg.localPosition = - Vector3(b.max.x + offset.x, b.min.y - offset.y)
        end
        return
    end
    if pos.x >= 0 then
        --右下
        _ref.itemGrid.transform.localPosition = Vector3(ext.x - b.min.x + offset.x, - ext.y - b.max.y - offset.y)
        if bg then
            bg.flip = UIBasicSprite.Flip.Vertically
            bg = bg.cachedTransform
            b = NGUIMath.CalculateRelativeWidgetBounds(bg)
            bg.localPosition = - Vector3(bounds.min.x - offset.x, bounds.max.y + offset.y)
        end
        return
    end
    --左下
    _ref.itemGrid.transform.localPosition = - offset - b.max + Vector3(- ext.x, - ext.y)
    if bg then
        bg.flip = UIBasicSprite.Flip.Both
        bg = bg.cachedTransform
        b = NGUIMath.CalculateRelativeWidgetBounds(bg)
        bg.localPosition = - offset - bounds.max
    end
end

function _w.OnDispose()
    _ref.itemGrid:DesAllChild(_body.cachedTransform)
end

function _w.FloatExit()
    _body:Exit()
end

PopRwdPreview = _w