
local BD_Const = QYBattle.BD_Const

local _base = QYBattle.BD_Unit
local CheckEnemy = QYBattle.BD_CombatUnit.CheckEnemy

local _arr = { }

function _arr.Update(a)
    local pos = a.pos
    local map = a.map
    local target = map:GetArrivedUnit(pos.x, pos.y)
    if CheckEnemy(a.archer, target) then
        a.archer:StrengthDPS(target, true)
        a:Dead()
        return
    end

    pos.x = pos.x + a.vx * map.deltaTime

    if not map:PosAvailable(pos.x, pos.y) then a:Dead() end
end

--构造函数
local function _ctor(t, archer, nm)
    t = setmetatable(_base(archer.map), _arr)
    t.archer = archer
    t.isAtk = archer.isAtk
    t.nm = nm or "arrow"
    t.vx = archer.direction * BD_Const.BASE_MOVE_SPEED_UNIT * 3
    t.pos:Set(archer.x + archer.direction, archer.y)
    return t
end

--继承扩展
_base:extend(_ctor, nil, nil, _arr)
--[Comment]
--战场战斗单位-箭矢
QYBattle.BD_Arrow = _arr