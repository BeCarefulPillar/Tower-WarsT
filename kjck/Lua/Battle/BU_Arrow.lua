
local V3Zero = Vector3.zero
local V3X180 = Vector3(0, 180, 0)

local typSp = typeof(UISprite)

local _base = BU_Unit
local _arr = class(_base)
--[Comment]
--战场显示单位-士兵
BU_Arrow = _arr

function _arr.ctor(a, map, go)
    _base.ctor(a, map, go)
    a.enabled = false
end

function _arr.Init(a, dat)
    assert(dat and getmetatable(dat) == QYBattle.BD_Arrow, "Init dat must be BD_Arrow")
    a.dat = dat
    dat.body = a
    a.enabled = true

    local var = a.map:GetPosV2(dat.pos)
    var.y = var.y + 30
    a.trans.localPosition = var
    a.trans.localEulerAngles = dat.vx < 0 and V3X180 or V3Zero

    var = a.go:GetCmp(typSp)
    var.spriteName = dat.name
    var.depth = a.map:GetDepth(dat.pos.y) + 2
end

function _arr.Update(a)
    if a.enabled then
        local var = a.dat
        if var.isAlive then
            var = a.map:GetPosV2(var.pos)
            var.y = var.y + 30
            a.trans.localPosition = var
        else
            a:Destruct()
        end
    end
end