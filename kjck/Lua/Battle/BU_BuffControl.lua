
require "Game/ItemBuff"

local isnull = tolua.isnull


local _cst = {
    sn_god = 100001,
    --[Comment]
    -- 击晕 SN
    ns_stun = 100002,
    --[Comment]
    -- 恐惧 SN
    sn_fear = 100003,
    --[Comment]
    -- 致盲 SN
    sn_blind = 100004,
    --[Comment]
    -- 流血 SN
    sn_bleed = 100005,
}

local _ctrl = class()
BU_BuffControl = _ctrl

--[[
    go =       BuffController 的根对象
    hero =     数据
    sort =     排序号
    item =     子项预制件
    items =    子项
    bfs =      buffData 集合
    gt =       图标渲染存储
]]

local function CreateBuffCahe(bf)
    return {
        bf = bf,
        sn = 0,
    }
end

local function GenItemBuff(c, bc)
    local bf = bc.bf
    local sn = bf.sn
    bc.sn = sn
    local temp = math.div(sn, 10000)
    local dbfs = nil
    if temp == 1 then -- 武将技
        dbfs = DB.GetSkc(math.div((sn % 10000), 10)):GetBattleBuff((sn % 10) + 1)
    elseif temp == 2 then -- 副将技
        dbfs = DB.GetSkd(math.div((sn % 10000), 10)):GetBattleBuff((sn % 10) + 1)
    elseif temp == 3 then -- 天机技
        dbfs = DB.GetSks(math.div((sn % 10000), 10)):GetBattleBuff((sn % 10) + 1)
    elseif sn == _cst.sn_bleed then -- 流血
        dbfs = { 16 }
    elseif sn == _cst.ns_stun then -- 眩晕
        dbfs = { 20 }
    end
    if dbfs == nil then return end

    local sort = c.sort + 1
    c.sort = sort
    local view = c.go:GetCmp(typeof(UIScrollView))
    for i = 1, #dbfs do
        temp = nil
        for _, v in pairs(c.items) do
            if v and v.go then
                if v.go.activeSelf then
                    if v:MatchAddsn(bf, dbfs[i]) then
                        temp = v
                        break
                    end
                else temp = v
                end
            end
        end
        if temp == nil then
            temp = c.go:AddChild(c.item)
            temp.transform.localScale = Vector3.one * 0.5
            if view then (temp:GetCmp(typeof(UIDragScrollView)) or temp:AddCmp(typeof(UIDragScrollView))).scrollView = view end
            temp = ItemBuff(c, temp)
            temp:Init(bf, DB.GetBattleBuff(dbfs[i]))
            table.insert(c.items, temp)
        elseif not temp.go.activeSelf then temp:Init(bf, DB.GetBattleBuff(dbfs[i]))
        end
        temp.go.name = string.format("item_%06d_%d", sort, sn)
    end
end

function _ctrl.ctor(c, go)
    assert(notnull(go), "create BU_BuffControl need gameObject")
    c.go = go
    c.item = AM.LoadPrefab("item_buff")
end

function _ctrl.Init(c, h)
    c.hero = h
    c.sort = 0
    c.items = { }
    c.bfs = { }
    if c.gt == nil then c.gt = GridTexture(128) end
end

function _ctrl.Update(c, h)
    if c.hero == nil then return end
    c.hero = h
    if #c.bfs < c.hero.BuffCount then
        local bf = nil
        for i = 1, c.hero.BuffCount do
            bf = c.hero:GetBuffByIdx(i)
            for j = 1, #c.bfs do
                if bf == c.bfs.bf then
                    bf = nil
                    break
                end
            end
            if bf ~= nil then
                table.insert(c.bfs, CreateBuffCahe(bf))
            end
        end
    end
    for i = 1, #c.bfs do
        if c.bfs[i].bf.isAlive then
            GenItemBuff(c, c.bfs[i])
        else 
            c.bfs[i].sn = 0
        end
    end

    if c.items ~= nil then
        for _, v in pairs(c.items) do
            if v then v:Update() end
        end
    end
end

function _ctrl.OnItemDispose(c, i)
    if i == nil or i.go.activeSelf then return end
    for j = 1, #c.bfs do
        if i:Match(c.bfs[j].bf) then
            c.bfs[j].sn = 0
            break
        end
    end
end

function _ctrl.Dispose(c)
    c.sort = 0
    c.hero = nil
    c.bfs = nil
    if c.gt ~= nil then
        c.gt:Dispose()
        c.gt = nil
    end
    if c.items ~= nil then
        for _, v in pairs(c.items) do
            if v and not isnull(v.go) then Destroy(v.go) end
        end
        c.items = nil
    end
end
