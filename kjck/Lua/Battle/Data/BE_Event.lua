
local _typ =
{
    None = 0,
    --[Comment]
    --攻击
    Attack = 1,
    --[Comment]
    --释放技能
    CastSkill = 2,
    --[Comment]
    --受到输出
    DPS = 3,
    --[Comment]
    --生命变更
    HP = 4,
    --[Comment]
    --技力变更
    SP = 5,
    --[Comment]
    --兵力变更
    TP = 6,
    --[Comment]
    --增加BUF
    BuffAdd = 7,
    --[Comment]
    --武将指令变更
    HeroCmd = 9,
    --[Comment]
    --士兵指令变更
    SoCmd = 10,
    --[Comment]
    --武将死亡
    HeroDead = 11,
    --[Comment]
    --能量变更(SP输出)
    Energy = 12,
}
--[Comment]
--事件类型
QYBattle.BE_Type = _typ

--local _evt = { }

--function _evt.__call(t, frame, typ, u, dat)
--    return { frame = frame, type = typ, unit = u, data = dat }
--end

--[Comment]
--事件
QYBattle.BE_Event = function(frame, typ, u, dat)
    return { frame = frame, type = typ, unit = u, dat = dat }
end
--QYBattle.BE_Event = _evt
