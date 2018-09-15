PopGift = { }
local item_goods = nil
local btnFriend = nil
local btnGift = nil
local grid = nil
local tip = nil
local target = nil
local msg = nil

local items = nil
local gridTexture = nil
local selected = nil

local _body = nil
local _ref = nil
PopGift.body = _body
function PopGift.OnLoad(c)
    WinBackground(c, {k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    -- 生命周期方法绑定
    c:BindFunction("OnEnter", "OnEnable")
    c:BindFunction("Refresh", "OnDisable")
    c:BindFunction("OnExit", "Help")
    c:BindFunction("OnInit")
    c:BindFunction("OnDispose")
    -- 监听事件
    c:BindFunction("ClickItem", "ClickFriend", "ClickGift")
    -- 组件绑定
    item_goods = _ref.item_goods
    btnFriend = _ref.btnFriend
    btnGift = _ref.btnGift
    tip = _ref.tip
    grid = _ref.grid
    target = _ref.target
    msg = _ref.msg
end

function PopGift.OnEnter()
    print("PopGift: -----OnEnter------")
    btnFriend:GetCmp(typeof(LuaButton)):SetClick("ClickFriend")
    btnGift:GetCmp(typeof(LuaButton)):SetClick("ClickGift")
end

function PopGift.OnInit()
    print("PopGift: -----OnInit------")
    local ip = 0
    local d = PopGift.initObj
    local t = type(d)
    if t == "string" then
        target.value = d
    elseif t == "number" then
        ip = d
    elseif t == "table" then
        for i = 0, #d do
            if type(d[i]) == "string" then
                if string.isEmpty(target.value) then
                    target.value = d[i]
                elseif type(d[i]) == "number" then
                    if ip == 0 then ip = d[i] end
                end
            end
        end
    end
    local props = table.findall(DB.AllProps(), function(p) return p.trg == 3 and user.GetPropsQty(p.sn) > 0 end) 
    print(kjson.encode(props))
    local len = #props
    items = { }
    if gridTexture == nil then gridTexture = GridTexture.New() end
    for i = 1, len do
        local p = props[i]
        items[i] = grid.gameObject:AddChild(item_goods, "goods_" .. p.sn).gameObject
        ig = ItemGoods(items[i])
        ig.go:SetActive(true)
        ig:Init(p)
        ig.num.text=user.GetPropsQty(p.sn)
        ig.go:GetCmp(typeof(LuaButton)):SetClick("ClickItem", ig)
        if (p.sn == ip) then selected = ig; selected.Selected = true end
    end
    if (len > 0 and not selected) then
        selected = ItemGoods(items[1].gameObject)
        selected.go:SetActive(true)
        selected.Selected = true
    end
    tip:SetActive(len <= 0)
    grid:GetCmp(typeof(UIGrid)).repositionNow = true
end

function PopGift.OnDispose()
    print("PopGift: -----OnDispose------")
    selected = nil
    if items ~= nil then
        for i, val in ipairs(items) do val:Destroy() end
        items = nil
    end
    if (gridTexture ~= nil) then gridTexture:Dispose() end
end

function PopGift.Help() print("PopGift: -----help------") end

function PopGift.ClickItem(ig)
    if (ig) then
        ig:ShowPropTip()
        if (selected == ig) then return end
        if (selected) then selected.Selected = false end
        selected = ig
        selected.Selected = true
    end
end

function PopGift.ClickFriend() Win.Open("PopFriend", -2) end

local function ShowUseProps(ig, p)
    local parent=ig.go
    if parent and not tolua.isnull(parent) then 
        local go = parent:AddChild(AM.LoadPrefab("ef_use_props"), "ef_use_props")
        if go and not tolua.isnull(go) then
            go:SetActive(false) 
            go:Destroy(2)
            coroutine.step()
            coroutine.step()
            ig.num.text=user.GetPropsQty(p.sn)
            go:SetActive(true)
        end
    end
end

function PopGift.ClickGift()
    if string.isEmpty(target.value) then ToolTip.ShowPopTip(L("请先选择赠送的玩家")); return end
    local p = selected and selected.dat
    if not objis(p,PY_Props) then p=PY_Props(p) end
    if p == nil or p.sn <= 0 or p.trg ~= 3 then ToolTip.ShowPopTip(L("请选择可赠送的道具")); return end
    PopUseProps.Use(p, target.value,function(res)
        if res.success then
            ToolTip.ShowPopTip(L("赠送成功"));
            coroutine.start(ShowUseProps, selected,p)
        end
    end,DB.HX_Filter(msg.value))
end

function PopGift.SetTarget(tn) target.value = tn end