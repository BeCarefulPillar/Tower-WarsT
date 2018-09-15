Guide = {}

local function ShowNatMap()
    if user.nsn<=0 then
        MsgBox.Show(L("参加国战需要先加入国家！"),L("否,是"),function(bid)
            if bid==1 then
                Win.Open("PopSelectCountry")
            end
        end)
        return nil
    end
    return Win.Open("MapNat")
end

local function MoveToNat(k,v)
    local w = ShowNatMap()
    coroutine.step()
    if w and w.isOpen then
        coroutine.step()
        coroutine.step()
    end
end

local gs = {
    --主线关卡
    AtkPve = function()
        print("AtkPve")
        local w = Win.Open("LevelMap")
        if w then
            w.AttackNextCity()
        end
        return true
    end,
    --城池开发
    DevPve = function()
        print("DevPve")
        local cities = user.GetLevelPveCity(user.gmLv)
        for i,pcd in ipairs(cities) do
            if pcd and pcd.lv<DB.maxCityLv then
                Win.Open("PopHome")
                Win.Open("PopCityUpgrade",pcd.sn)
                return true
            end
        end
        cities = user.GetPveCities()
        for i,pcd in ipairs(cities) do
            if pcd and pcd.lv<DB.maxCityLv then
                i = pcd.db.main
                if i>0 and i<=user.gmMaxLv then
                    Win.Open("PopHome")
                    Win.Open("PopCityUpgrade",pcd.sn)
                    return true
                end
            end
        end
        Win.Open("PopHome")
        return true
    end,
    GainPve = function()
        print("AtkPve")
        return true
    end,
    --副本
    HisPve = function()
        Win.Open("WinFB")
        return true
    end,
    AtkPvp = function()
        print("AtkPve")
        return true
    end,
    AtkNat = function(v)
        print("AtkNat")
        coroutine.start(MoveToNat,k,v)
        return true
    end,
    PopPeerage = function(v)
        print("PopPeerage")
        coroutine.start(MoveToNat,k,v)
        return true
    end,
    Country = function(v)
        print("Country")
        coroutine.start(MoveToNat,k,v)
        return true
    end,
    WinAlly = function(k,v)
        if tonumber(user.ally.gsn)<=0 then
            ToolTip.ShowPopTip(L("你还没有加入联盟!"))
            return false
        end
        Win.Open(k)
        return true
    end,
    PopHeroStar = function(k)
        local hs = user.GetHeros(function(h)
            return h.CanUpStar
        end)
        if #hs>0 then
            Win.Open(k)
            return true
        end
        ToolTip.ShowPopTip(L("暂无武将可升级将星!"))
        return false
    end,
    WinGroundPalace = function(k)
        if user.IsGveUL then
            if tonumber(user.ally.nsn)>0 then
                SVR.GveExplorerStart(function(t)
                    if t.success then
                        local k = SVR.datCache
                        if k==1 then
                            SVR.GveExplorerMatch(0,0,function(t1)
                                if t1.success then
                                    Win.Open(k,SVR.datCache)
                                end
                            end)
                        elseif k==2 then
                            ToolTip.ShowPopTip(L("领取奖励"))
                            SVR.GveExplorerReward(function(t2)
                                if t2.success then
                                    Win.Open("PopResult")
                                end
                            end)
                        elseif k==3 then
                            SVR.GveExplorerEntert(function(t3)
                                if t3.success then
                                    ToolTip.ShowPopTip(L("进入地宫"))
                                    Win.Open("WinExplorer",SVR.datCache)
                                end
                            end)
                        end
                    end
                end)
                return true
            else
                ToolTip.ShowPopTip(L("需要加入或创建联盟"))
            end
        else
            ToolTip.ShowPopTip( string.format(L("主城[ff0000]%d[-]级开启地宫探秘"), DB.unlock.explorer))
        end
        return false
    end,
    def = function(k,v)
        Win.Open(k,v)
        return true
    end,
}

---<summary>为了配合自动国战  将前往判断单独提出来</summary>
local function PaseGuideGo(g)
    g = string.split(g,'|')
    local k,v = g[1],g[2]
    local f = gs[k] or gs.def
    if f then
        return f(k,v)
    end
    return false
end

---<summary>解析向导数据</summary>
function Guide.PaseGuide(g)
    if string.isEmpty(g) then
        return false
    end
    --自动国战的临时赋值
    local tempAuto = false
    --if MapCountry.IsAutoPath then
    if false then
    else
        return PaseGuideGo(g)
    end
    return tempAuto
end