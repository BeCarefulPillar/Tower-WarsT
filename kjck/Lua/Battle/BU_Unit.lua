local notnull = notnull
local Destroy = Destroy

local _unit = class()
--[Comment]
--战场显示单位
BU_Unit = _unit

--字段说明
--[[
map BU_Map              所属战场
go GameObject           Untiy根对象
trans Transform         Unity根
depth int               深度
dat BD_Unit             单位的数据部分
]]

--构造函数
function _unit.ctor(o, map, go)
    assert(ois(map, BU_Map) and notnull(go), "create BU_Unit need map[BU_Map] and gameObject")
    o.map = map
    o.go = go
    o.trans = go.transform
    o.depth = 0
    
end

function _unit.Init(u, dat)
    u:Dispose()
    if dat then
        u.dat = dat
        dat.body = u
    end
end

--属性 alive
function _unit.get_alive(u) return notnull(u.go) end
--循环
function _unit.Update(u) end

--单位是否是所属方
function _unit.IsAtk(u, isAtk) u = u.dat; return u and u.isAtk == isAtk end

function _unit.Dispose(u)
    if u.dat then
        if u.dat.body == u then u.dat.body = nil end
        u.dat = nil
    end
end

function _unit.Destruct(u, delay)
    if delay and delay > 0 then
        if u._dtm then
            u._dtm:Reset(function() u:Destruct() end, delay, 1)
        else
            u._dtm = Timer.New(function() u:Destruct() end, delay, 1, true)
        end
        if not u._dtm.running then u._dtm:Start() end
    else
        u:CancleDestruct()
        u:Dispose()
        if u.go then Destroy(u.go) end
    end
end

function _unit.CancleDestruct(u)
    if u._dtm and u._dtm.running then
        u._dtm:Stop()
    end
end

--添加眩晕显示效果
function _unit.AddStunEffect(u, time)
    if time > 0 then
        local t = u.trans:Child("ef_skc_stun")
        if t then
            local cmp = t:GetCmp(typeof(DoAfter))
            cmp.time = Mathf.Max(da.time, time)
            cmp = t:GetCmp(typeof(TweenAlpha))
            if cmp then
                cmp.delay = time - 0.2
                cmp:ResetToBeginning()
            end
        else
            t = u.type
            if t == BU_Hero or t == BU_Soldier then
                local go = u.go:AddChild(AM.LoadPrefab("ef_skc_stun"), "ef_skc_stun")
                go.transform.localY = t == BU_Hero and 80 or 60
                DoAfter.Do(go, DoAfter.Work.Destruct, time, false)
                go = TweenAlpha.Begin(go, 0.2, 0)
                go.delay = time - 0.2
                go.ignoreTimeScale = false
            end
        end
    end
end

--添加恐惧显示效果
function _unit.AddFearEffect(u, time)
    if time > 0 then
        local t = u.trans:Child("ef_skc_fear")
        if t then
            local cmp = t:GetCmp(typeof(DoAfter))
            cmp.time = Mathf.Max(da.time, time)
            cmp = t:GetCmp(typeof(TweenAlpha))
            if cmp then
                cmp.delay = time - 0.2
                cmp:ResetToBeginning()
            end
        else
            t = u.type
            if t == BU_Hero or t == BU_Soldier then
                local go = u.go:AddChild(AM.LoadPrefab("ef_skc_fear"), "ef_skc_stun")
                go.transform.localY = t == BU_Hero and 80 or 60
                go.transform.localScale = t == BU_Hero and Vector3(0.8, 0.8, 0.8) or Vector3(0.6, 0.6, 0.6)
                DoAfter.Do(go, DoAfter.Work.Destruct, time, false)
                go = TweenAlpha.Begin(go, 0.2, 0)
                go.delay = time - 0.2
                go.ignoreTimeScale = false
            end
        end
    end
end

--添加流血显示效果
function _unit.AddBleedEffect(u, time)
    if time > 0 then
        local t = u.trans:Child("ef_skc_bleed")
        if t then
            local cmp = t:GetCmp(typeof(DoAfter))
            cmp.time = Mathf.Max(da.time, time)
            cmp = t:GetCmp(typeof(TweenAlpha))
            if cmp then
                cmp.delay = time - 0.2
                cmp:ResetToBeginning()
            end
        else
            t = u.type
            if t == BU_Hero or t == BU_Soldier then
                local go = u.go:AddChild(AM.LoadPrefab("ef_skc_bleed"), "ef_skc_bleed")
                go.transform.localScale = t == BU_Hero and Vector3(1, 1, 1) or Vector3(0.6, 0.6, 0.6)
                DoAfter.Do(go, DoAfter.Work.Destruct, time, false)
                go = TweenAlpha.Begin(go, 0.2, 0)
                go.delay = time - 0.2
                go.ignoreTimeScale = false
            end
        end
    end
end

--AddFreezeEffect
function _unit.AddFreezeEffect(u, time)
    if time > 0 then
        local t = u.trans:Child("ef_skc_ice")
        if t then
            local cmp = t:GetCmp(typeof(DoAfter))
            cmp.time = Mathf.Max(da.time, time)
            cmp = t:GetCmp(typeof(TweenAlpha))
            if cmp then
                cmp.delay = time - 0.2
                cmp:ResetToBeginning()
            end
        else
            t = u.type
            local go
            if t == BU_Hero then
                go = u.go:AddChild(AM.LoadPrefab("ef_skc_ice_0"), "ef_skc_ice")
            elseif t == BU_Soldier then
                go = u.go:AddChild(AM.LoadPrefab("ef_skc_ice_0"), "ef_skc_ice")
                go.transform.localScale = Vector3.one * 0.7
            end
            if go then
                go.transform.localPosition = go.transform.localPosition + Vector3(0, 18, 0)
                DoAfter.Do(go, DoAfter.Work.Destruct, time, false)
                go = TweenAlpha.Begin(go, 0.2, 0)
                go.delay = time - 0.2
                go.ignoreTimeScale = false
            end
        end
    end
end
