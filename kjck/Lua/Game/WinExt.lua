--需要提前加载的窗口
require "Game/PopUseProps"
require "Game/PopRewardShow"
require "Game/PopSelectHero"

local _G = _G
local _winOpen = Win.Open
local _winGetOpenWin = Win.GetOpenWin
local _winClose = Win.Close
local _winExitAllWin = Win.ExitAllWin
local _showMainPanel = Win.ShowMainPanel
    
-- 禁用窗口，窗口名称和检测函数(返回是否禁用)
local _banWin = 
{
    WinHero = function () 
        if not user.IsHeroUL then 
            ToolTip.ShowPopTip(string.format(L("攻陷%s解锁"), ColorStyle.Bad(DB.GetGmCity(DB.unlock.hero).name)))
            return true end
        return end,
    WinWar = function () 
        if not user.IsWarUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.gmWar))))
            return true end
        return end,
    PopHistory = function () 
        if not user.IsHistroyUL then 
            ToolTip.ShowPopTip(string.format(L("攻陷%s解锁"), ColorStyle.Bad(DB.GetGmCity(DB.unlock.gmFB).name)))
            return true end
        return end,
    WinFB = function () 
        if not user.IsHistroyUL then 
            ToolTip.ShowPopTip(string.format(L("攻陷%s解锁"), ColorStyle.Bad(DB.GetGmCity(DB.unlock.gmFB).name)))
            return true end
        return end,
    WinRankSolo = function () 
        if not user.IsRankUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.rank))))
            return true end
        return end,
    WinAllyList = function () 
        if not user.IsAllyUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.ally))))
            return true end
        return end,
    PopAllyUpgrade = function () 
        if user.allyPerm ~= 2 then 
            ToolTip.ShowPopTip(ColorStyle.Bad(L("抱歉，你在联盟的职权不够，无法进行该操作！")))
            return true end
        return end,
    WinSmithy = function () 
        if not user.IsEquipEvoUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.eqpEvo))))
            return true end
        return end,
    WinTower = function () 
        if not user.IsTowerUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.tower))))
            return true end
        return end,
    WinFame = function () 
        if not user.IsFameUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.fame))))
            return true end
        return end,
    WinRareShop = function () 
        if not user.IsRareShopUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.rareShop))))
            return true end
        return end,
    WinBoss = function () 
        if not user.IsBossUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.boss))))
            return true end
        return end,
    WinDivine = function () 
        if not user.IsDivineUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.divine))))
            return true end
        return end,
    WinFam = function () 
        if not user.IsFamUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.fam))))
            return true end
        return end,
    PopExclForge = function () 
        if not user.IsExclForgeUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.exclForge))))
            return true end
        return end,
    WinClanWar = function () 
        if not user.IsClanWarUL then 
            ToolTip.ShowPopTip(DB.unlock.gmClan > DB.maxHlv and ColorStyle.Bad(L("暂未开放")) or string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.gmClan))))
            return true end
        return end,
    PopClanWar = function () 
        if not user.IsClanWarUL then 
            ToolTip.ShowPopTip(DB.unlock.gmClan > DB.maxHlv and ColorStyle.Bad(L("暂未开放")) or string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.gmClan))))
            return true end
        return end,
    PopLieuInfo = function () 
        if not user.IsDeHeroUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.dehero))))
            return true end
        return end,
    PopLegatusList = function () 
        if not user.IsDeHeroUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.dehero))))
            return true end
        return end,
    PopDeheroExcl = function () 
        if not user.IsDeHeroUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.dehero))))
            return true end
        return end,
    PopAchievement = function () 
        if not user.IsAhvUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.achv))))
            return true end
        return end,
    PopCountryBlood = function () 
        if not user.IsNatBloodUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.natBlood))))
            return true end
        return end,
    WinBeauty = function () 
        if not user.IsBeautyUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.beauty))))
            return true end
        return end,
    WinFantsy = function () 
        if not user.IsFantsyUL then 
            ToolTip.ShowPopTip(string.format(L("主城%s级后开放"), ColorStyle.Bad(tostring(DB.unlock.fantsy))))
            return true end
        return end
}

--[Comment]
--打开指定名称的窗口
function Win.Open(nm, arg)
    local tmp = _banWin[nm]
    if tmp and tmp() then return end
    tmp = _G[nm]
    if tmp == nil then
        if nm == "BattleManager" then require("Battle/"..nm)
        else require("Game/"..nm) end
        tmp = _G[nm]
        assert(tmp, "win ["..nm.."] dose not exisit")
    end
    tmp.initObj = arg
    _winOpen(nm, arg and tostring(arg))
    return tmp
end

--[Comment]
--获取打开的窗体Table
function Win.GetOpenWin(nm)
    local win = _G[nm]
    return win and (win.isOpen or (win.isOpen == nil and _winGetOpenWin(nm))) and win or nil
end
--[Comment]
-- 关闭窗口，默认只关闭，第二个参数为 true 时删除窗体
function Win.Close(nm, del)
    local win = Win.GetWin(nm)
    if win then
        win:Exit()
        if del then
            Destroy(win.gameObject)
        end
    end
end
--[Comment]
-- 关闭所有窗口
-- 可选参数 wnm 指定名字的窗口不被退出
function Win.ExitAllWin(wnm)
    local wins = Win.GetWins()
    if wins ~= nil then
        for i = 0, wins.length - 1 do
            if wins[i].winName ~= wnm then wins[i]:Exit() end
        end
    end
end
--[Comment]
-- 退出所有活动的窗口显示主界面
function Win.ShowMainPanel()
    local wins = Win.GetWins()
    if wins ~= nil then
        for i = 0, wins.length - 1 do
            if wins[i].isBackLayer == false then wins[i]:Exit() end
        end
    end
end
