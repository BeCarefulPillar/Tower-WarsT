local _w = { }
PopBorrowHeroApply = _w

local _body = nil
PopBorrowHeroApply.body = _body

local _ref = nil
--[Comment]
--自己发起的申请模板
local itemS
--[Comment]
--收到的申请模板
local itemR
local grid
local tabApplyS
local tabApplyR

local dataR
local dataS

----------------------发起的申请------------------------
local function InitItemS(i, d)
    local it = i
    local dat = d

    local avaTex = it:GetCmpInChilds(typeof(UITexture))
    local name = it:ChildWidget("lbl_name")
    local desc = it:ChildWidget("lbl_describe")
    local btnA = it:ChildWidget("btn_agree", typeof(LuaButton)).luaBtn
    local status = it:ChildWidget("lbl_status")

    local hero = DB.GetHero(dat.dbsn)
    if hero ~= nil and CheckSN(hero.sn) ~= nil then
        avaTex:LoadTexAsync(ResName.HeroIcon(hero.img))
        name.text = "[00FF00]【武将接收】[-]"
        desc.text = "[ffd99c]" .. dat.nick .. "[-]派遣了武将[ffd99c]"..hero.nm .."[-]来支援你!"

        if dat.opt == 0 then  --未接收
            status:SetActive(false)
            btnA:SetActive(true)
            btnA:SetClick("ClickRecieve", {dat.csn, dat.psn})
        elseif dat.opt == 1 then --已接收
            btnA:SetActive(false)
            status.text = "已接收"
            status.color = Color.green
            status:SetActive(true)
        elseif dat.opt == 3 then --被召回
            btnA:SetActive(false)
            status.text = "已被召回"
            status.color = Color.red
            status:SetActive(true)
        end
    else
        avaTex:LoadTexAsync(ResName.PlayerIcon(dat.ava))
        name.text = "[00FF00]【消息通知】[-]"
        desc.text = "[ffd99c]" .. dat.nick .. "[-]拒绝了你的借将申请!"
        if dat.opt == 2 then
            btnA:SetActive(false)
            status.text = "已被拒"
            status.color = Color.red
            status:SetActive(true)
        end
    end

    it:SetActive(true)
end

local function BuildApplySItem()
    if dataS == nil then return end
    if grid.transform.childCount > 0 then grid:DesAllChild() end

    for i=1, #dataS do
        local go = grid:AddChild(itemS, "items_" .. i)
        InitItemS(go, dataS[i])
    end

    grid.repositionNow = true
end

--接收武将
function _w.ClickRecieve(p)
    local csn = p[1]
    local sn = p[2]

    SVR.AllyBorrowHeroRecive(csn, sn, function(result)
        if result.success then
            local res = SVR.datCache
            dataS = res.applies
            BuildApplySItem()
            SVR.SyncHeroData(function(result)end)
        end
    end)
end
--------------------------------------------------------------------------

--------------------------------收到的申请---------------------------------
local function InitItemR(i, d)
    local it = i
    local dat = d

    local avaTex = it:GetCmpInChilds(typeof(UITexture))
    local name = it:ChildWidget("lbl_name")
    local desc = it:ChildWidget("lbl_describe")
    local btnA = it:ChildWidget("btn_agree", typeof(LuaButton)).luaBtn
    local btnR = it:ChildWidget("btn_refuse", typeof(LuaButton)).luaBtn
    local btnC = it:ChildWidget("btn_recall", typeof(LuaButton)).luaBtn
    local status = it:ChildWidget("lbl_status")

    avaTex:LoadTexAsync(ResName.PlayerIcon(dat.ava))
    name.text = "[ff0000]【借将申请】[-]" .. dat.nick .. "向你申请借将"
    desc.text = string.isEmpty(dat.msg) and "请求支援!!!" or dat.msg

    if dat.refused == 1 then
        btnR:SetActive(false)
        btnA:SetActive(false)
        status:SetActive(true)
        status.text = "[FF0000]已经拒绝"
        status.color = Color.red
        btnC:SetActive(false)
    elseif dat.agreed ~= 0 then
        btnR:SetActive(false)
        btnA:SetActive(false)

        if dat.status == 0 then --未被接收
            status:SetActive(false)
            btnC:SetActive(true)
            btnC:SetClick("ClickCallBack", dat)
        elseif dat.status == 1 then --已接收
            status:SetActive(true)
            status.text = "[00FF00]已被接收"
            status.color = Color.green
            btnC:SetActive(false)
        elseif dat.status == 2 then -- 已被拒绝接收
            status:SetActive(true)
            status.text = "[FF0000]已被拒收"
            status.color = Color.red
            btnC:SetActive(false)
        elseif dat.status == 3 then --已召回
            status:SetActive(true)
            status.text = "[00FF00]已召回"
            status.color = Color.green
            btnC:SetActive(false)
        end
    else
        btnR:SetActive(true)
        btnA:SetActive(true)
        status:SetActive(false)
        btnC:SetActive(false)
        btnR:SetClick("ClickRefuse", dat)
        btnA:SetClick("ClickAgree", dat)
    end

    it:SetActive(true)
end

local function BuildApplyRItem()
    if dataR == nil then return end
    if grid.transform.childCount > 0 then grid:DesAllChild() end

    for i=1, #dataR do
        local go = grid:AddChild(itemR, "itemR_"..i)
        InitItemR(go, dataR[i])
    end
    grid.repositionNow = true
end

--拒绝申请
function _w.ClickRefuse(p)
    SVR.AllyBorrowHeroRefuseOpt(p.psn, function(result)
        if result.success then
            dataR = SVR.datCache
            BuildApplyRItem()
        end
    end)
end

--同意申请
function _w.ClickAgree(p)
    SVR.SyncHeroData(function(result) end)
    Win.Open("PopSelectHero", {SelectHeroFor.BorrowHero, function(slt)
        SVR.AllyBorrowHeroAgreeOpt(p.psn, slt[1], function(result)
            if result.success then
                dataR = SVR.datCache
                BuildApplyRItem()
                ToolTip.ShowPopTip("武将成功借出!")
                SVR.SyncHeroData(function(result) end)
            end
        end)
    end})
end

--召回武将
function _w.ClickCallBack(p)
    print(kjson.print(p))
    SVR.AllyBorrowHeroReCall(p.csn, p.psn, function(result)
        if result.success then
           dataR = SVR.datCache
           BuildApplyRItem()
           ToolTip.ShowPopTip("召回成功!")
           SVR.SyncHeroData(function(result) end)
        end
    end)
end
--------------------------------------------------------------------------

function _w.OnLoad(c)
    WinBackground(c, { k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref
    table.print("_ref", _ref)

    c:BindFunction("OnInit","OnDispose","OnUnLoad", "ClickRefuse", "ClickAgree", "ClickCallBack", 
                   "ClickRecieve", "ClickTabApllyS", "ClickTabApllyR", "OnExit")

    itemR = _ref.itemR
    itemS = _ref.itemS
    grid = _ref.grid
    tabApplyS = _ref.tabApply
    tabApplyR = _ref.tabApplyRecieve
end
--发起的申请
function _w.ClickTabApllyS()
    tabApplyR:GetCmp(typeof(UIButton)).isEnabled = true
    tabApplyS:GetCmp(typeof(UIButton)).isEnabled = false

    SVR.AllyBorrowHeroCheck(function(result)
        if result.success then
            local res = SVR.datCache
            dataS = res.applies
            local time = tabApplyS:ChildWidget("time")
            time.text = "(".. (res.maxQty - res.qty) .. "/" .. res.maxQty .. ")"

            BuildApplySItem()
        end
    end)
end
--收到的申请
function _w.ClickTabApllyR()
    tabApplyR:GetCmp(typeof(UIButton)).isEnabled = false
    tabApplyS:GetCmp(typeof(UIButton)).isEnabled = true

    SVR.AllyBorrowHeroCheckFromOther(function(result) 
        if result.success then
            dataR = SVR.datCache

            BuildApplyRItem()
        end
    end)
end

function _w.OnInit()
    _w.ClickTabApllyS()
end

function _w.OnEnter()
    UpdateBorrowApplyStatus:Add(_w.ClickTabApllyS)
    UpdateBorrowFromOther:Add(_w.ClickTabApllyR)
end

function _w.OnExit()
    if MainUI then MainUI.CheckBorrowBtn() end
end

function _w.OnDispose()
    UpdateBorrowApplyStatus:Remove(_w.ClickTabApllyS)
    UpdateBorrowFromOther:Remove(_w.ClickTabApllyR)
end

function _w.OnUnLoad()
    _body = nil
end
