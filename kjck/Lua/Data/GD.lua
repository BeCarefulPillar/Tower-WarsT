local type = type
local tostring = tostring

--[Comment]
--校验SN，返回nil或者字符串
function CheckSN(sn)
    if sn then
        return "number" == type(sn) and sn > 0 and tostring(sn) or "string" == type(sn) and sn ~= "" and sn ~= "0" and sn or nil
    end
    return nil
end

--[Comment]
--比较SN
function EqualSN(a, b) return a and b and tostring(a) == tostring(b) or false end

--------------------事件--------------------
--[Comment]
--用户数据变更事件
UserDataChange = event("UserDataChange", true)
--[Comment]
--用户时间冷却数据变更事件
UpdateColdTime = event("UpdateColdTime", true)
--[Comment]
--用户联盟数据变更事件
UserAllyChange = event("UserAllyChange", true)
--[Comment]
--加载 PVP 地图模块
LoadPvpZone = event("LoadPvpZone", true)

--[Comment]
--新的聊天
OnNewChat = event("OnNewChat", true)
--[Comment]
--新的国战聊天
OnNewChatSnat = event("OnNewChatSnat", true)

--[Comment]
--刷新国战
UpdateNat = event("UpdateNat", true)
--[Comment]
--刷新国战活动
UpdateNatAct = event("UpdateNatAct", true)
--[Comment]
--刷新国战NPC
UpdateNatNpc = event("UpdateNatNpc", true)
--[Comment]
--刷新国战武将
UpdateNatHero = event("UpdateNatHero", true)
--[Comment]
--刷新国战战斗
UpdateNatBattle = event("UpdateNatBattle", true)

--[Comment]
--刷新国家
UpdateCountry = event("UpdateCountry",true)

--[Comment]
--刷新主界面的借将按钮
UpdateBorrowBtn = event("UpdateBorrowBtn",true)

--[Comment]
--刷新主界面的邀请按钮
UpdateInviteBtn = event("UpdateInviteBtn",true)

--[Comment]
--刷新别人向我发起的申请
UpdateBorrowFromOther = event("UpdateBorrowFromOther",true)

--[Comment]
--对方已处理我发起的申请
UpdateBorrowApplyStatus = event("UpdateBorrowApplyStatus",true)

--[Comment]
--帝国科技树
UpdateEmpireTech = event("EmpireTech",true)

--------------------------------------------
--没做
--[Comment]
--掠夺刷新
SnatUpdate = event("UpdateSnat",true)
--[Comment]
--掠夺武将刷新
SnatUpdateHero=event("UpdateSnatHero",true)
--[Comment]
--掠夺战斗
SnatBattle=event("SnatBattle",true)
--[Comment]
--掠夺城池变化
SnatCityChange=event("SnatCityChange",true)
--[Comment]
--掠夺聊天
SnatChat=event("SnatChat",true)

---------------------------------------------

--服务器命令 通信命令  SocketStruct
require "Data/STAB"
--玩家数据
require "Data/User"
--玩家将领数据
require "Data/PY_Hero"
--玩家装备数据
require "Data/PY_Equip"
--玩家装备碎片数据
require "Data/PY_EquipSp"
--玩家宝石数据
require "Data/PY_Gem"
--玩家道具
require "Data/PY_Props"
--玩家PVE城池数据
require "Data/PY_City"
--玩家PVP城池
require "Data/PY_PvpCity"
--玩家将魂
require "Data/PY_Soul"
--玩家活动数据
require "Data/PY_Act"
--玩家国战数据
require "Data/PY_Nat"
--玩家国战将领
require "Data/PY_NatHero"
--玩家聊天数据
require "Data/PY_Chat"

require "Data/MsgData"



--require "Data/PY_Dehero"        --玩家副将数据（没做）
--require "Data/PY_Dequip"        --玩家副将装备数据（没做）
--require "Data/PY_DequipSp"      --玩家副将装备碎片数据（没做）
--require "Data/PY_Sexcl"         --玩家天机数据（没做）
--require "Data/PY_State"
--require "Data/PY_SwarTeam"
--require "Data/PY_Snat"