local SVR = SVR
local Func = Func
local stab = stab
local ldec = kjson.ldec
local string = string
local tostring = tostring
local tonumber = tonumber
local ipairs = ipairs

--NatFightHero
local function NatFightHeroCompare(x, y)
    return x.sort == y.sort and x.dbsn < y.dbsn or x.sort < y.sort
end

--添加一条新的聊天消息
local function AddNewChat(chat)
    if chat and chat.text then
        assert(ois(chat, PY_Chat), "AddNewChat arg must be PY_Chat")
        table.insert(user.chats, chat)
        if #user.chats > CONFIG.MAX_CHAT then table.remove(user.chats, 1) end
        user.SaveChatHist()
        OnNewChat()
    end
end
--[Comment]
--添加一条新的聊天消息
SVR.AddNewChat = AddNewChat

function TestCalcBattle()
local json = '{100,81,1753498952,[13,0,0,3,8000,12,20,70,100,80,80,50,200,400,60],0,0,{{116480,"烽少1",1,0,3},{42428,15,0,18,737,221,220,100,1029,1029,36,36,9,9,1,2,0,"|||||"},{[{5,0,8,0,"","","22"},{10,13,10,9,"","","40"},{47,10,10,0,"3,1","9,17,0,50",""}],{},{},"wf,600|bwf,600|bj,0|jb,0|bbj,0|ys,0|bys,0|sb,0|bsb,0|gs,0|bgs,0|bs,0|bbs,0",[3327,1400,1000,7000,500],"",1,[],{},"",[],[],{}},{[3,2,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"ak,30|ml,63|ts,0",[0,0,0,0,0],[],"","ak,0|ml,0|ts,0|lf,0|jl,0|bl,0|sb,0|js,0|cd,0|qwf,0|qmf,0|mz,0|cpd,0|ba,0|han,0|wf,0|bj,0|csd,0|bys,0|bgs,0|mf,0|bs,0|jb,0",""}},{{116428,"烽少666",1,0,1},{76282,15,1,69,2808,66172,66223,100,63860,69575,10,54,4,19,1,2,21,"||||bf,5|jb,2|"},{[{5,0,8,0,"","","22"},{10,13,10,9,"","","40"},{47,10,10,0,"3,1","9,17,0,50",""},{69,25,7,1,"5,5","20,0,0","15,3"}],{1,"mf,7"},{},"wf,600|bwf,600|bj,0|jb,0|bbj,0|ys,0|bys,0|sb,0|bsb,0|gs,0|bgs,0|bs,0|bbs,0",[3327,1400,1000,7000,500],"",1,[1,1,1],{},"",[],[],{}},{[3,2,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"ak,195|ml,210|ts,92",[0,0,0,0,0],[],"","ak,0|ml,0|ts,0|lf,0|jl,0|bl,0|sb,0|js,0|cd,0|qwf,0|qmf,0|mz,0|cpd,0|ba,0|han,0|wf,0|bj,0|csd,0|bys,0|bgs,0|mf,0|bs,0|jb,0",""}}}'
local str = string.format('require "Battle/Data/QYBattle" QYBattle.CalcBttleSingle("%s","%s",%s,%s,\'%s\')', "a", "a", 1, nil, json)
    print(str)
    BattleCalc.Calc(str)
end

local function CalcSingleBattle(func, dat, sfs)
    local fsn = sfs:GetInt("sn")
--    local ver = sfs:GetInt("ver")
    local cmd, pos = nil, nil
    if func == Func.PeakCalcBattle then
        cmd = Func.Peak
        pos = sfs:GetInt("pos")
    else
        cmd = Func.In
    end
--    local str = string.format('require "Battle/Data/QYBattle" QYBattle.CalcBttleSingle("%s","%s",%s,%s,\'%s\')', cmd, func, fsn, pos, dat)
--    print(str)
    BattleCalc.Calc(str)
end

local _evtExt = 
{
    --region --------------------------------1-63 通用消息--------------------------------
    --通知给指定玩家消息[玩家PSN，文本消息，样式]
    [1] = function(dat)
        if #dat > 2 and user.psn == dat[2] and dat[3] ~= "" then
            dat[3] = MsgData.ProcessMsg(dat[3])
            if #dat > 3 then
                if "box" == dat[4] then
                    MsgBox.Show(dat[3])
                elseif "tip" == dat[4] then
                    ToolTip.ShowPropTip(dat[3])
                end
            end
            AddNewChat(PY_Chat(dat[3]))
        end
    end,
    --通知给指定联盟消息[联盟SN，文本消息，样式]
    [2] = function(dat)
        if #dat > 2 and user.ally.gsn == dat[2] and dat[3] ~= "" then
            dat[3] = MsgData.ProcessMsg(dat[3])
            if #dat > 3 then
                if "box" == dat[4] then
                    MsgBox.Show(dat[3])
                elseif "tip" == dat[4] then
                    ToolTip.ShowPropTip(dat[3])
                end
            end
            AddNewChat(PY_Chat(dat[3]))
        end
    end,
    --通知给指定国家消息[国家SN，文本消息，样式]
    [3] = function(dat)
        if #dat > 2 and tostring(user.ally.nsn) == dat[2] and dat[3] ~= "" then
            dat[3] = MsgData.ProcessMsg(dat[3])
            if #dat > 3 then
                if "box" == dat[4] then
                    MsgBox.Show(dat[3])
                elseif "tip" == dat[4] then
                    ToolTip.ShowPropTip(dat[3])
                end
            end
            AddNewChat(PY_Chat(dat[3]))
        end
    end,
    --发红包[发送者名称，红包SN，红包DBSN]
    [4] = function(dat)
        if #dat > 3 then
            local red = DB.GetRed(tonumber(dat[4]))
            if dat[2] == "" then dat[2] = L("匿名") end
            red = PY_Chat(string.format(L("[D7B694]%s[-][FF0000]在【%s】活动中购买了礼包\n分享了一个红包，点击打开"), dat[2], LN(red.nm)), ChatChn.System, ChatStyle.RedPacket, dat[3])
            red.nick = dat[2]
            AddNewChat(red)
        end
    end,
    --指定活动全局信息变更[活动SN，当前值]
    [5] = function(dat)
        if #dat > 2 then
            local act = user.GetAct(tonumber(dat[2]))
            if act then
                dat = tonumber(dat[3])
                if dat and dat > 0 and act.scoreGl ~= dat then
                    act.scoreGl = dat
                    act.isGetHst = false
                    act:MarkAsChanged()
                end
            end
        end
    end,
    --限时礼包的推送[礼包SN，礼包到期时间，礼包条件[等级需求，VIP需求,爵位需求，联盟等级需求，武将需求，注册时间需求]]
    [6] = function(dat)
        if #dat >= 3 then
            print("推送 ---- 有新的限时礼包")
            if tonumber(dat[3]) > SVR.SvrTime() and PopLevelGift.CheckIsBuyable(ldec(dat[4])) then
                --礼包可购买，更新礼包数据
                --MainPanel.Instance.CheckGiftBtn(new S_GiftOpt())
            end
        end
    end,
    --玩家充值[玩家PSN，人民币，金币，源]
    [10] = function(dat)
        if #dat > 4 and user.psn == dat[2]then
            SVR.UpdateUserInfo()
            SVR.GetColdTime()
            --Analytics.Pay(tonumber(dat[3]), CS.ToEnum(tonumber(dat[5]), typeof("Analytics.PaySource,"..ASB_NM.CUR)), tonumber(dat[4]))
        end
    end,
    --通知玩家更新信息[玩家PSN]
    [11] = function(dat)
        SVR.UpdateUserInfo()
        SVR.GetColdTime()
    end,
    --玩家完成任务[玩家PSN，任务SN，完成的任务数]
    [12] = function(dat)
        if #dat > 3 and user.psn == dat[2] then
            user.questQty = tonumber(dat[4]) or user.questQty
            user.changed = true
        end
    end,
    --玩家获得奖励[玩家PSN，文本消息，奖励接口]
    [13] = function(dat)
        if #dat > 3 and user.psn == dat[2] then
            user.SyncReward(RW.Parse(dat[4]))
        end
    end,
    --玩家完成悬赏任务[玩家PSN，任务SN，任务group，任务rare]
--    [14] = function(dat)
--        if #dat > 4 and user.psn == dat[2] then

--        end
--    end,
    --endregion

    --region --------------------------------64-127 1v1社交--------------------------------
    --添加好友[接受者PSN，发起者PSN，发起者名称]
--    [64] = function(dat)
--        if #dat > 3 and user.psn == dat[2] then

--        end
--    end,
    --删除好友[接受者PSN，发起者PSN，发起者名称]
    [65] = function(dat)
        if #dat > 3 and user.psn == dat[2] then
            
        end
    end,
    --发送邮件[接受者PSN，发起者PSN，发起者名称]
    [66] = function(dat)
        if #dat > 3 and user.psn == dat[2] then
            user.newMsgNum = user.newMsgNum + 1
            user.changed = true
        end
    end,
    --赠送道具[接受者PSN，发起者PSN，发起者名称，道具SN，奖励接口]
    [67] = function(dat)
        if #dat > 5 and user.psn == dat[2] then
            user.SyncReward(RW.Parse(dat[6]))
        end
    end,
    --演武榜挑战[接受者PSN，发起者PSN，发起者名称,胜败(1=胜 else=败)]
--    [68] = function(dat)
--        if #dat > 5 and user.psn == dat[2] then

--        end
--    end,
    --PVP攻城[守方PSN，守方城池SN，攻方PSN，攻方城池SN，攻方名称，胜败(1=胜 else=败)]
    [69] = function(dat)
        if #dat > 6 and user.psn == dat[2] then
            if dat[7] == "1" then
                local city = tonumber(dat[3])
                if city and city > 0 then
                    dat = user.GetCityHero(city)
                    if dat and #dat > 0 then
                        for _, v in ipairs(dat) do v:SetLoc(0) end
                    end
                end
            end
        end
    end,
    --PVP道具[接受者PSN，发起者PSN，发起者名称,城池SN，道具SN]
--    [70] = function(dat)
--        if #dat > 5 and user.psn == dat[2] then

--        end
--    end,
    --endregion

    --region -------------------------------71-72 地宫------------------------------------
    [71] = function(dat)
        if #dat > 3 then
            local opt = tonumber(dat[3])
            if opt == 1 then  --加入队伍
                local res = ldec(dat[5], stab.S_GveTeamInfo)
                local w = Win.GetOpenWin("WinTeam")
                if w then w.UpdateData(res)
                else Win.Open("WinTeam", res) end
            elseif opt == 2 then --退出队伍
                local res = ldec(dat[5], stab.S_GveTeamInfo)
                local w = Win.GetOpenWin("WinTeam")
                if w then w.UpdateData(res) end
            elseif opt == 3 then --被踢出队伍
                if user.psn == dat[4] then
                    Win.ExitAllWin("MainMap")
                    MsgBox.Show("您已被踢出队伍")
                else
                    local res = ldec(dat[5], stab.S_GveTeamInfo)
                    local w = Win.GetOpenWin("WinTeam")
                    if w then w.UpdateData(res) end
                end
            elseif opt == 4 then --准备
                local res = ldec(dat[5], stab.S_GveTeamInfo)
                local w = Win.GetOpenWin("WinTeam")
                if w then w.UpdateData(res) end
            elseif opt == 5 then --取消准备
                local res = ldec(dat[5], stab.S_GveTeamInfo)
                local w = Win.GetOpenWin("WinTeam")
                if w then w.UpdateData(res) end
            elseif opt == 6 then --匹配成功 / 队长点击开始
                local res = ldec(dat[5], stab.S_GveTeamInfo)
                local w = Win.GetOpenWin("WinTeam")
                if w then w.UpdateData(res) end
                SVR.GveEnter(function(result)
                    if result.success then
                        local d = SVR.datCache
                        ToolTip.ShowPopTip(L("进入地宫"))
                        Win.Open("WinExplorer", d)
                        Win.Close("WinTeam", true)
                    end
                end)
            elseif opt == 7 then  --更新武将显示
                local res = ldec(dat[5], stab.S_GveInfo)
                local w = Win.GetOpenWin("WinExplorer")
                if w then w.RefreshInfo(res) end
            elseif opt == 10 then --队友移动
                local res = string.split(dat[5], ",")
                local psn = tonumber(res[1])
                local from = tonumber(res[2])
                local to = tonumber(res[3])
                local w = Win.GetOpenWin("WinExplorer")
                if w then w.RefreshOthersPos(psn, from, to) end
            elseif opt == 12 then --同步信息
                local res = ldec(dat[5], stab.S_GveInfo)
                local w = Win.GetOpenWin("WinExplorer")
                if w then w.RefreshInfo(res) end
            elseif opt == 14 then
            end
        end
    end,

    [72] = function(dat)
        local opt = tonumber(dat[4])
        if opt == 0 then
            UpdateInviteBtn()
        elseif opt == 1 then
            if user.psn == dat[2] then
                local len = #dat[5]
                ToolTip.ShowPopTip("玩家[" .. string.sub(dat[5], 2, len-1) .. "][FF0000]已拒绝[-]您的邀请")
            end
        elseif opt == 2 then
            if user.psn == dat[2] then
                local len = #dat[5]
                ToolTip.ShowPopTip("玩家[" .. string.sub(dat[5], 2, len-1) .. "][FF0000]已同意[-]您的邀请")
            end
        end
    end,
    --endregion

    --region [--------------------------------128-191 联盟--------------------------------]
    --入盟申请[联盟SN，盟主PSN，申请者PSN，申请者名称]
--    [128] = function(dat)
--        if #dat > 4 and user.ally.gsn == dat[2] and user.psn == dat[3] then

--        end
--    end,
    --加入联盟[联盟SN，加入者SN，加入者名称，联盟名称，联盟所属国家]
    [129] = function(dat)
        if #dat > 5 and user.psn == dat[3] then
            local var = CheckSN(dat[2])
            if var == user.ally.gsn then return end
            user.ally.gsn = var
            user.ally.gnm = dat[5]
            user.ally.nsn = tonumber(dat[6]) or 0
            user.allyChanged = true
            var = Win.GetActiveWin("WinAllyList")
            if var then
                var:Exit()
                Win.Open("WinAlly")
            end
            var = user.MyPvpCity
            if var then var:SetAlly(user.ally.gsn, dat[5]) end
--            if MapManager.Instance and MapManager.Instance.MCountry.gameObject.activeSelf then
--                MapManager.Instance.ShowMainCity();
--                Win.GetActiveWin("PopSelectHero").Exit();
--            end
--            Win.ExitAll(w => { return w.WinName.Contains("Country"); });
            ToolTip.ShowPropTip(string.format(L("你已加入联盟\n%s"), ColorStyle.Blue(dat[5])))
        end
    end,
    --退出联盟[联盟SN，退出者SN，退出者名称，联盟名称]
    [130] = function(dat)
        if #dat > 4 and user.psn == dat[3] and user.ally.gsn == dat[2] then
            user.ally = { }
            user.allyChanged = true

            local val = user.MyPvpCity
            if val then val:SetAlly() end
--            if MapManager.Instance and MapManager.Instance.MCountry.gameObject.activeSelf then
--                MapManager.Instance.ShowMainCity()
--                Win.GetActiveWin("PopSelectHero").Exit()
--            end
            --Win.ExitAll(w => { return w.WinName.Contains("Country"); });
            
            ToolTip.ShowPropTip(string.format(L("你被退出联盟:%s"), ColorStyle.Blue(dat[5])))
        end
    end,
    --升职[联盟SN，升职者SN，升职者名称，职位]
    [131] = function(dat)
        print("升职[联盟SN，升职者SN，升职者名称，职位]")
        if #dat > 4 and user.psn == dat[3] and user.ally.gsn == dat[2] then
            user.ally.myPerm = tonumber(dat[5]) or user.ally.myPerm
            user.allyChanged = true
        end
    end,
    --降职[联盟SN，降职者SN，降职者名称，职位]
    [132] = function(dat)
        print("降职[联盟SN，降职者SN，降职者名称，职位]")
        if #dat > 4 and user.psn == dat[3] and user.ally.gsn == dat[2] then
            user.ally.myPerm = tonumber(dat[5]) or user.ally.myPerm
            user.allyChanged = true
        end
    end,
    --联盟升级[联盟SN，联盟等级]
--    [133] = function(dat)
--        if #dat > 2 and user.ally.gsn == dat[2] then

--        end
--    end,
    --科技升级[联盟SN，科技SN，科技等级]
--    [134] = function(dat)
--        if #dat > 3 and user.ally.gsn == dat[2] then

--        end
--    end,
    --更换国家[联盟SN，之前国家SN，现在国家SN，联盟名称]
--    [135] = function(dat)
--        if #dat > 4 and user.ally.gsn == dat[2] then

--        end
--    end,
    --任务变更[联盟SN，任务SN，所属玩家名称]
    [136] = function(dat)
        if #dat > 3 and user.ally.gsn == dat[2] then
            local var = PopAllyBounty
            if var and var.isOpen then var.UpdateQuestInfo(dat[3], dat[4]) end
        end
    end,
    --开启神勇令[联盟SN，神勇令剩余时间]
--    [160] = function(dat)
--        if #dat > 2 and user.ally.gsn == dat[2] then

--        end
--    end,
    --开启征召[联盟SN，征召的城池SN]
--    [161] = function(dat)
--        if #dat > 2 and user.ally.gsn == dat[2] then

--        end
--    end,
    [162] = function(dat)
        if #dat == 4 then
            if tonumber(dat[3]) == 0 then
                UpdateBorrowFromOther()  --有人向我申请借将
            else
                UpdateBorrowApplyStatus() --对方处理了我的申请
            end
        end
        UpdateBorrowBtn()
    end,
    --endregion

    --region --------------------------------192-255 国战--------------------------------
    --城池所属变更[城池SN，守方(所属)，攻方(>0战斗中),BUF]S_NatCity
    [192] = function(dat)
        if #dat > 3 then
            local res = {}
            res.sn = tonumber(dat[2])
            res.def = tonumber(dat[3])
            res.atk = tonumber(dat[4])
            res.bufTime = tonumber(dat[5])
            local city = user.nat.city
            if res.sn > 0 and res.def > 0 and city then
                for i = 1 ,#city do
                    if city[i].sn == res.sn then
                        local old = {}
                        table.copy(city[i],old)
                        city[i] = res
                        if res.def ~= old.ref then
                            UpdateNat()
                        end
                        user.nat:CityStatusChange(res.sn)
                        break
                    end
                end
            end
        end
    end,
    --限时任务[城池列表]
    [193] = function(dat)
        if #dat > 1 then
            local city = string.split(dat[2],',')
            user.nat.questCity = city
            UpdateNatAct()
        end
    end,
    --夺旗战[城池列表，属性(1=有旗 else=无旗)，方式(1=绝对 else=相对)]]
    [194] = function(dat)
        if #dat > 3 then
            local city = string.split(dat[2],',')
            if dat[4] == "1" then
                user.nat.flagCity = city
            else
                local list = {}
                if dat[3] == "1" then
                    for i = 1, #city do
                        --不包含
                        if table.find(list,city[i]) == 0 then
                            table.insert(list,city[i])
                        end
                    end
                else
                    for i = 1, #city do
                        table.remove(list,city[i])
                    end
                end
                user.nat.flagCity = list
            end
            UpdateNatAct()
        end
    end,
    --限时任务[城池SN，0=攻 1=守，BUF SN，BUF时间]
    [195] = function(dat)
        if #dat > 4 then
            local city = tonumber(dat[2])
            local bufSN = tonumber(dat[4])
            local bufTime = tonumber(dat[5])
            local w = Win.GetOpenWin(WinNatCity)
            if w then
                w.UpdateBuf(city, data[3] == "0", bufSN, bufTime)
            end
            if user.nat.city then
                local nCity = user.nat.city
                for i = 1 , #nCity do
                    if nCity[i].sn == city then
                        if bufTime > nCity[i].bufTm then
                            nCity[i].bufTm = bufTime
                            UpdateNat()
                        end
                        break
                    end
                end
            end
        end
    end,
    --同步国战NPC[同步数据]
    [196] = function(dat)
        if #dat > 1 then
            print("同步国战NPC   ",kjson.print(dat))
            user.nat.npc = ldec(dat[2], stab.S_NatCityNpc)
            print("同步国战NPC  22222 ",kjson.print(user.nat.npc))
            if user.nat.npc == nil then
                local city = DB_NatData.city
                print("同步国战NPC[同步数据] city",kjson.print(city))
                for i,v in ipairs(city) do
                    if PY_Nat.IsBarbarian(v.sn) then
                        city[i].atk = 0
                    end
                end
            end
            user.changed = true
            UpdateNat()
            UpdateNatNpc()
        end
    end,
    --单城NPC变更[城池SN,国家SN,新的NPC_LV（如果是蛮族，则是下一步所要进攻的城SN,0是死了）]
    [197] = function(dat)
        if #dat > 3 then
            print("单城NPC变更[   " ,kjson.print(dat))
        end
    end,
    --更新玩家信息
    [201] = function(dat)
        print("201~~~~~~~!```````!!!!!!    ", kjson.print(dat))
        if #dat > 1 then
            local psn = tonumber(dat[2])
            if psn > 0 then
                user.changed = true
            end
        end
    end,
    --endregion

    --region --------------------------------256-319 跨服国战--------------------------------
    --战斗结果送达[psn，S_PeakRet]
    [400] = function(dat) 
        if #dat > 2 and user.psn == dat[2] then
            local res=ldec(dat[3] ,stab.S_PeakRet) 
            if res.fsn>0 then
                SVR.PeakFightRead(res.fsn)
                Win.Open("PopCrossResult",res)
            end
        end
    end,
    --endregion
}

local _msgExt = 
{
    --新任务可完成[完成的任务数]
    ["2"] = function(vals)
        vals = tonumber(vals[2])
        if vals and vals > 0 then
            user.questQty = user.questQty +1
            user.changed = true
        end
    end,
    --撤离城池[城池编号]
    ["3"] = function(vals)
        vals = user.GetPvpCity(tonumber(vals[2]))
        if vals then vals:LeaveFromColony() end
    end,
    --盟主收到玩家申请加入联盟[玩家SN,玩家名称]
    ["4"] = function(vals)
        local sn = CheckSN(vals[2])
        if sn then
            user.ally.pendMember = user.ally.pendMember + 1
            user.changed = true
            user.allyChanged = true
            ToolTip.ShowPropTip(string.format(L("%s申请加入联盟"), ColorStyle.Blue(vals[3])))
        end
    end,
    --收到加入联盟通知[联盟SN,联盟名称]
    ["5"] = function(vals)
        local sn = CheckSN(vals[2])
        if sn then
            user.ally.gsn = sn
            user.ally.gnm = vals[3]
            user.allyChanged = true
            local val = user.MyPvpCity
            if val then val:SetAlly(sn, vals[3]) end
            val = Win.GetActiveWin("WinAllyList")
            if val then
                val:Exit()
                Win.Open("WinAlly")
            end
            ToolTip.ShowPropTip(string.format(L("你已加入联盟\n%s"), ColorStyle.Blue(vals[3])))
        end
    end,
    --收到退出联盟通知[联盟SN,联盟名称]
    ["6"] = function(vals)
        local sn = CheckSN(vals[2])
        if sn == user.ally.gsn then
            user.ally = { }
            user.allyChanged = true

            local val = user.MyPvpCity
            if val then val:SetAlly() end
--            if MapManager.Instance and MapManager.Instance.MCountry.gameObject.activeSelf then
--                MapManager.Instance.ShowMainCity()
--                Win.GetActiveWin("PopSelectHero").Exit()
--            end
            --Win.ExitAll(w => { return w.WinName.Contains("Country"); });
            
            ToolTip.ShowPropTip(string.format(L("你被退出联盟:%s"), ColorStyle.Blue(vals[3])))
        end
    end,
    --收到充值消息[RMB,Gold,Source]
    ["7"] = function(vals)
        SVR.UpdateUserInfo()
        SVR.GetColdTime()
    end,
    --收到更新公告
    ["8"] = function(vals)
--        PopAnno.needUpdate = true;
        user.changed = true
    end,
    --国家更换
    ["9"] = function(vals)
        if CheckSN(vals[2]) == user.ally.gsn then
            local sn = CheckSN(vals[3])
            if sn ~= user.ally.nsn then
                user.ally.nsn = sn
--                if MapManager.Instance and MapManager.Instance.MCountry.gameObject.activeSelf then
--                    MapManager.Instance.ShowMainCity();
--                    Win.GetActiveWin<PopSelectHero>().Exit();
--                end
--                Win.ExitAll(w => { return w.WinName.Contains("Country"); });
                MsgBox.Show(L("你的联盟已经更换了所属国家"))
            end
        end
    end,
    --奖励获得
    ["10"] = function(vals, msg)
        --PopRewardShow.Show(RW.Parse(string.sub(msg, 4)));
    end,
    --新邮件
    ["11"] = function(vals)
        user.newMsgNum = user.newMsgNum + 1
        user.changed = true
    end,
}

local _ext = 
{
    --region --------------------------------聊天 系统消息--------------------------------
    --聊天消息
    [Func.Chat] = function(ret, dat, sfs)
        dat = PY_Chat(sfs)
        print(PY_Chat.__tostring(dat))
        if (dat.chn ~= ChatChn.Nat or tonumber(dat.trg) == user.ally.nsn)--国家匹配
            and (dat.chn ~= ChatChn.Ally or dat.trg == user.ally.gsn)--联盟匹配
            or (user.IsSystemUser(dat.sender) --[[or not user.BlackLstHas(dat.nick)]]) then --黑名单过滤
            --字符串编码剥离
            if not ChatStyle.IsShare(dat.style) and not user.IsSystemUser(dat.sender)
                and dat.nick and dat.nick ~= "" and dat.vip < CONFIG.ChatVip then
                dat.text = NGUIText.StripSymbols(dat.text)
            end
            AddNewChat(dat)
            if dat.sender == user.psn and ChatStyle.IsShare(dat.style) and dat.ext and dat.ext ~= "" then
                ToolTip.ShowPopTip(L("分享成功"))
            end
        end
    end,
    --跨服国战聊天消息
    [Func.ChatSnat] = function(ret, dat, sfs)
        dat = ChatSnat(sfs)
        if dat.channel ~= SnatChatChannel.Nat or dat.nat == user.snat.nsn then
            if not user.IsSystemUser(dat.sender) and dat.senderName and dat.senderName ~= "" and dat.vip < CONFIG.ChatVip then
                NGUIText.StripSymbols(dat.text)
            end
            OnNewChatSnat(dat)
        end
    end,
    --服务器消息
    [Func.SysMsg] = function(ret, dat, sfs)
        local kind = sfs:GetInt("msg_type")
        local msg = sfs:GetUtfString("msg_text")
        print("receive msg (" , kind + "):" , msg)
        if kind == 0 then
            --聊天
            AddNewChat(msg, sfs:GetUtfString("msg_ext"))
        elseif kind == 1 then
            --公告
            --ServerMessage.Show(MsgData.ProcessMsg(msg));
        elseif kind == 2 then
            --聊天+公告
            --ServerMessage.Show(MsgData.ProcessMsg(msgContent));
            AddNewChat(msg, sfs:GetUtfString("msg_ext"))
        elseif kind == 3 then
            --操作
            local vals = string.split(msg, ',')
            local f = _msgExt[vals[1]]
            if f then f(vals, mgs) end
        elseif kind == 4 then
            --国战消息
--            if Win.GetActiveWin("WinSnat") == nil then
--                ServerMessage.Show(MsgData.ProcessMsg(msg))
--            end
        end
    end,
    --endregion

    --region -------------------------------服务器内部调用--------------------------------
    --服务器内部事件
    [Func.InternalEvent] = function(ret, dat)
        if dat == nil or dat == "" then return end
        dat = string.split(dat, '&')
        ret = tonumber(dat[1])
        if ret == nil then return end
        ret = _evtExt[ret]
        if ret then return ret(dat) end
    end,
    --获取服务器时间
    [Func.GetSvrTime] = function(ret, dat, sfs)
        dat = tonumber(sfs:GetUtfString("ltime"))
        if dat then SVR.SetSvrTime(dat * 0.001) end
        return dat
    end,
    --计算国战结果
    [Func.CalcNatBattle] = function(ret, dat, sfs)
        if ret == 0 then
            CalcSingleBattle(Func.CalcNatBattle, dat, sfs)
        end
    end,
    --计算战斗结果
    [Func.CalcSwarBattle] = function(ret, dat, sfs)
        if ret == 0 then
            --CalcSingleBattle(obj.GetInt("guid"), obj.GetInt("ver"), data);
        end
    end,
    --计算跨服国战
    [Func.SnatCalcBattle] = function(ret, dat, sfs)
        if ret == 0 then
            --CalcSingleBattle(obj.GetInt("guid"), obj.GetInt("ver"), data);
        end
    end,
    --计算跨服PVP
    [Func.PeakCalcBattle] = function(ret,dat,sfs)
         if ret == 0 then 
            --CalcSingleBattle(obj.GetInt("guid"), obj.GetInt("ver"), data);
         end
    end,
    --endregion

    --region ----------------------------------同步部分-----------------------------------
    --同步武将数据
    [Func.SyncHero] = function(ret, dat) if ret == 0 then user.SyncHero(ldec(dat, stab.S_Hero)) end end,
    --同步装备
    [Func.SyncEquip] = function(ret, dat) if ret == 0 then user.SyncEquip(ldec(dat, stab.S_Equip)) end end,
    --同步道具
    [Func.SyncProps] = function(ret, dat) if ret == 0 then user.SyncProps(ldec(dat)) end end,
    --同步将魂
    [Func.SyncHeroSoul] = function(ret, dat) if ret == 0 then user.SyncSoul(ldec(dat)) end end,
    --同步宝石
    [Func.SyncGem] = function(ret, dat) if ret == 0 then user.SyncGem(ldec(dat)) end end,
    --同步副将
    [Func.SyncDehero] = function(ret, dat) if ret == 0 then user.SyncDehero(ldec(dat, stab.S_Dehero)) end end,
    --同步军备
    [Func.SyncDequip] = function(ret, dat) if ret == 0 then user.SyncDequip(ldec(dat, stab.S_Dequip)) end end,
    --同步残片
    [Func.SyncDequipSp] = function(ret, dat) if ret == 0 then user.SyncDequipSp(ldec(dat)) end end,
    --同步价值物品列表
    [Func.SyncValue] = function(ret, dat) if ret == 0 then user.SyncValueData(ldec(dat)) end end,

    --同步用户扩展信息
    [Func.UpdateUserInfo] = function(ret, dat) if ret == 0 then user.SyncInfo(ldec(dat, stab.UserInfoUpdate)) end end,
    --用户更改信息
    [Func.ChangeUserInfo] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_UserInfoChange)
            user.SyncInfoChange(dat)
            return dat
        end
    end,
    --时间CD等信息
    [Func.GetColdTime] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_ColdTime)
            SVR.SetSvrTime(dat.svrTm)
            user.SyncCD(dat)
            UpdateColdTime()
        end
    end,
    --endregion

    --region ------------------------------------城池-------------------------------------
    --获取关卡城池信息
    [Func.GetLevelMap] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_LevelMapInfo)
            if dat.gmLv <= 0 then dat.gmLv = dat.gmMaxLv end
            user.SyncPveCity(dat)
            if dat.captive and #dat.captive > 0 then
                print("登录赋值俘虏~~~~~~~~~~~~~~~~    更新关卡信息")
                user.battleRet = {sn = user.gmMaxCity , kind = 1, ret = 1, captive = dat.captive}
            end
            return dat
        end
    end,
    --升级主城
    [Func.HomeUpgrade] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HomeUpgrade)
            local leader = user.Home
            user.hlv = dat.lv
            user.coin = dat.coin
            user.PvpSN = dat.pvpCity
            user.changed = true

            local pcd = user.PvpHomeCity
            if pcd then pcd:SetLv(dat.lv) end

            --[[
                    SDK.SendRoleLvUp();

                    if (MainPanel.Instance) MainPanel.Instance.CheckUnlock();

                    if (User.HomeData.lead > leader)
                    {
                        User.newHeroPos = User.HomeData.lead - 1;
                        UnlockEffect.BenginHeroPos();
                    }

                    TdAnalytics.SetAccount(User.SN.ToString(), User.ServerSN.ToString("d3"), User.HomeLv, User.Name);--这里是更新用户等级

                    DB_GiftLv gift = GameData.GetLvGift(User.HomeLv);
                    if(gift!=DB_GiftLv.undefined) MainPanel.Instance.CheckGiftBtn(new S_GiftOpt());]]
        end
    end,
    --城池开发
    [Func.CityUpgrade] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_CityUpgrade)
            user.coin = dat.coin or user.coin
            user.changed = true
            return dat
        end
    end,
    --城池搜索
    [Func.SearchCity] = function(ret, dat) if ret == 0 then dat = ldec(dat); user.SyncReward(dat); return dat end end,
    --城池一键搜索
    [Func.SearchCityBatch] = function(ret, dat) if ret == 0 then dat = ldec(dat); user.SyncReward(dat[1]); return dat end end,
    --endregion

    --region ----------------------------------医馆 兵力----------------------------------
    --医馆加血
    [Func.HospitalAddHP] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HospitalAddHP)
            --Analytics.Buy("HP", 1, Mathf.Max(DB.param.prAddHp));
            user.hp = dat.hp or user.hp
            user.gold = dat.gold or user.gold
            user.changed = true
            return ret
        end
    end,
    --医馆治疗武将
    [Func.CureHero] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HospitalCure)
            user.hp = dat.hp or user.hp
            user.changed = true
            return dat
        end
    end,
    --征兵
    [Func.AddSoldier] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_AddSoldier)
            user.tp = dat.tp or user.tp
            user.coin = dat.coin or user.coin
            user.tpQty = dat.qty or user.tpQty
            user.changed = true
            return dat
        end
    end,
    --武将调整兵力
    [Func.HeroSolder] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HeroSolder)
            user.tp = dat.ptp
            ret = user.GetHero(dat.csn)
            if ret then ret:SetTP(dat.tp) end
            return dat
        end
    end,
    --endregion

    --region --------------------------------邮件 好友 排行-------------------------------
    --获取邮件
    [Func.PlayerMsg] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_Mail) end end,
    --提取邮件附件[一键提取也是用这个]
    [Func.GetMsgAtt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            return dat
        end
    end,
    -- 一键提取[暂时没用]
--    [Func.GetMsgAtt1K] = function(ret, dat)
--        if ret == 0 then
--            dat = ldec(dat)
--            if dat and #dat > 0 then for _, v in ipairs(dat) do user.SyncReward(v) end end
--            return dat
--        end
--    end,
    --好友操作
--    [Func.FriendOption] = function(ret, dat) if ret == 0 then end end,
    --返回的玩家列表
    [Func.PlayerList] = function(ret, dat) if ret == 0 then return ldec(dat, stab.PlayerList).lst end end,
    --获取其他玩家信息
    [Func.GetPlayerInfo] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_PlayerPvpInfo) end end,
    --获取排行信息
    [Func.GetRankInfo] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_RankInfo) end end,
    --获取名人堂信息
    [Func.GetFameInfo] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_FameInfo) end end,
    --endregion

    --region ------------------------------------装备-------------------------------------
    --装备操作
    [Func.Equip] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_EquipOpt)
            user.SyncReward(dat.rws)
            user.AddEquip(dat.equip)
            return dat
        end
    end,
    --装备操作
    [Func.EquipOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_EquipOption)
            ret = dat.opt
            if ret == "sell" then
                --出售
                user.SyncReward(dat.rws)
                ret = dat.vals
                if ret and #ret >=2 then
                    user.RemoveEquip(ret[1])
                    user.coin = ret[2]
                end
            elseif ret == "up" then
                --装备
                ret = dat.vals
                if ret and #ret >=2 then
                    dat = user.GetHero(ret[1])
                    if dat then dat:Equip(ret[2]) end
                end
            elseif ret == "down" then
                --卸下
                ret = dat.vals
                if ret and #ret >=2 then
                    dat = user.GetHero(ret[1])
                    if dat then dat:UnEquip(ret[2]) end
                end
            elseif ret == "slot" then
                --打孔
                user.SyncReward(dat.rws,true)
                ret = dat.vals
                if ret and #ret >=1 then
                    dat = user.GetEquip(ret[1])
                    if dat then dat:AddSlot() end
                end
            elseif ret == "gem" then
                --镶嵌
                user.SyncReward(dat.rws,true)
                ret = dat.vals
                if ret and #ret >=3 then
                    dat = user.GetEquip(ret[1])
                    if dat then dat:SetGem(ret[3], ret[2]) end
                end
            elseif string.sub(ret,1,3) == "hh|" then
                --幻化
                user.SyncReward(dat.rws,true)
                local e = user.GetEquip(dat.vals and dat.vals[1])
                if e then e:AddEC(string.sub(ret, 4)) end
            end
            return dat
        end
    end,
    --装备-升级
    [Func.EquipUpgrade] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_EquipUpgrade)
            user.coin = dat.coin
            user.gold = dat.gold
            user.AddPropsQty(dat.prop, -1)
            user.changed = true

            ret = user.GetEquip(dat.esn)
            if ret then ret:SetLv(dat.lv) end
            
            --if dat.prop and dat.prop > 0 then Analytics.Use(tostring(dat.prop), 1, DB.GetProps(dat.prop).gold) end
            return dat
        end
    end,
    --装备-一键强化
    [Func.EquipUpOnekey] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_EquipUpgrade)
            user.coin = dat.coin
            user.gold = dat.gold
            user.AddPropsQty(dat.prop, -1)
            user.changed = true

            ret = user.GetEquip(dat.esn)
            if ret then ret:SetLv(dat.lv) end
            
            --if dat.prop and dat.prop > 0 then Analytics.Use(tostring(dat.prop), 1, DB.GetProps(dat.prop).gold) end
            return dat
        end
    end,
    --装备-进阶
    [Func.EquipEvo] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_EquipEvo)
            user.coin = dat.coin
            user.gold = dat.gold
            user.SetPropsQty(DB.param.eqpEvoProp, dat.propQty)
            user.changed = true
            
            ret = dat.useLst
            if ret then
                ret = string.split(ret, ",")
                for i,v in ipairs(ret) do
                    i = tonumber(v)
                    if i and i > 0 then
                        user.AddPropsQty(i, -1)
                    end
                end
            end
            local ed = user.GetEquip(dat.esn)
            if ed then
                ret = ed.evoExp
                ed:SetEvoExp(dat.exp)
                if dat.exp > 0 then
                    dat.exp = math.max(1, dat.exp - ret)
                else
                    ed:SetEvo(ed.evo + 1)
                end
            end
            return dat
        end
    end,
    --装备-锻造
    [Func.EquipExclForge] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_EquipExclForge)
            user.SyncReward(dat.rws, true)
            user.SyncMoney(dat.money)
            user.RemoveEquip(dat.cesn)
            ret = user.GetEquip(dat.esn)
            if ret then ret:SetExclStar(dat.exclStar) end
            user.changed = true
            return dat
        end
    end,
    --装备-一键卖装
    [Func.EquipSellBatch] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_EquipSellBatch)
            user.SyncReward(dat.rws, true)
            if dat.qty > 0 then
                local tip = string.format(L("出售装备%s件"), ColorStyle.Good(tostring(dat.qty)))
                if #dat.rws > 0 then tip = tip .. L("获得:银币") .. ColorStyle.Silver("+" .. dat.rws[1][3]) end
                if #dat.rws > 1 and dat.rws[2][3] > 0 then tip = tip .. ColorStyle.Blue(" " .. DB.GetProps(DB_Props.HUAN_HUA_SHI):getName() .. "×" .. dat.rws[2][3] ) end
                ToolTip.ShowPopTip(tip)
            end
            return dat
        end
    end,
    --装备-碎片操作
    [Func.EquipPiece] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_EquipPiece)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --装备-一键出售碎片
    [Func.PieceSellBatch] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_EquipSellBatch)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --装备-宝石操作
    [Func.GemOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_GemOption)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --endregion

    --region ----------------------------------武将培养-----------------------------------
    --锦囊技
    [Func.SkpOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_SkpOpt)
            user.SyncReward(dat.rws)
            ret = user.GetHero(dat.csn)
            if ret then ret:SyncSkp(dat) end
            return dat
        end
    end,
    --学习技能
--    [Func.LearnSkill] = function(ret, dat) if ret == 0 then dat = ldec(dat, stab.S_LearnSkill) end end,
    --学习兵种
    [Func.SoldierOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_ArmOpt)
            if dat.coin then user.coin = dat.coin end
            if dat.gold then user.gold = dat.gold end
            user.changed = true
            ret = user.GetHero(dat.csn)
            if ret then ret:ArmOpt(dat) end
            return dat
        end
    end,
    --学习阵形
    [Func.LearnLineup] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_LearnUseLnp)
            if dat.coin then user.coin = dat.coin end
            if dat.gold then user.gold = dat.gold end
            user.changed = true
            ret = user.GetHero(dat.csn)
            if ret then ret:LnpOpt(dat) end
            return dat
        end
    end,
    --阵形铭刻
    [Func.LineupImprint] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_LnpImp)
            if dat.coin then user.coin = dat.coin end
            if dat.gold then user.gold = dat.gold end
            if dat.rmb then user.rmb = dat.rmb end
            user.changed = true
            user.SetPropsQty(DB_Props.ZHEN_WEN_FU, dat.rune)
            ret = user.GetHero(dat.csn)
            if ret then ret:SyncLnpImp(dat) end
            return dat
        end
    end,
    --武将修炼
    [Func.Train] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_TrainHero)
            if dat.coin then user.coin = dat.coin end
            if dat.gold then user.gold = dat.gold end
            if dat.tm then user.trainTm.time = dat.tm end
            user.changed = true
            if dat.opt == "end" then
                ret = dat.lst
                if ret then
                    user.trainTm.time = 0
                    local h, lv, exp
                    for i = 1, #ret - 2, 3 do
                        h = user.GetHero(ret[i])
                        if h then
                            lv, exp = h.lv, h.exp
                            h:SetLv(ret[i + 1], ret[i + 2])
                            ret[i + 1] = lv
                            ret[i + 2] = exp
                        end
                    end
                end
            end
            return dat
        end
    end,
    --武将觉醒
    [Func.HeroEvolution] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HeroEvo)
            if dat.coin then user.coin = dat.coin end
            if dat.gold then user.gold = dat.gold end
            if dat.rmb then user.rmb = dat.rmb end
            user.changed = true
            user.SetPropsQty(DB_Props.HUN_YUAN_DAN, dat.propQty)
            user.SetSoulQty(dat.dbsn, dat.soulQty)
            ret = user.GetHero(dat.csn)
            if ret then ret:SetEvo(dat.evo) end
            return dat
        end
    end,
    --武将升级将星
    [Func.HeroUpStar] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HeroStar)
            user.SyncReward(dat.rws)
            user.SyncMoney(dat.money)
            ret = user.GetHero(dat.csn)
            if ret then ret:SetStar(dat.star) end
            return dat
        end
    end,
    --武将修炼操作
    [Func.Cultive] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HeroCultive)
            user.SyncReward(dat.rws, true)
            return dat
        end
    end,
    --武将一键升级
    [Func.OneKeyLevelUp] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_UseMoreProps)
            print("123213213213   ",kjson.print(dat.useProps))
--            local len = #dat.useProps
--            for i = 1 ,len do
--                local res1 = dat.useProps[i]
--                if res1.propsUseNum > 0 then
--                    local lastCnt = user.GetPropsQty(res1.propsSN);
--                    user.SyncReward(res1.rewards, false)
--                    User.SetPropsQty(res1.propsSN, res1.propsNum);
--                end
--            end
            SVR.SyncHeroData()
            return dat
        end
    end,
    --副将操作
    [Func.DeheroOpt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_DeheroOpt)
            user.SyncReward(dat.rws, true)
            ret = user.GetDehero(dat.dcsn)
            if ret then ret:Sync(dat) end
            return dat
        end
    end,
    --天机技能
    [Func.HeroSecret] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HeroSecret)
            user.SyncReward(dat.rws, true)
            ret = user.GetHero(dat.csn)
            if ret then ret:SetSecret(dat.slv, dat.sksLst) end
            return dat
        end
    end,
    --极限挑战
    [Func.HeroChallenge] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HeroChallenge)
            user.SyncReward(dat.rws, true)
            user.SyncMoney(dat.money)
            return dat
        end
    end,
    --技能五行
    [Func.SkcFeOpt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_SkcFeOpt)
            user.SyncReward(dat.rws)
            ret = dat.fe
            if ret then ret.tm = os.time() end
            ret = user.GetHero(dat.csn)
            if ret then ret:SyncFe(dat) end
            return dat
        end
    end,
    --endregion

    --region ------------------------------------军备-------------------------------------
    --军备操作
    [Func.DequipOpt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_DequipOpt)
            user.SyncReward(dat.rws)
            if tonumber(dat.desn) < 0 then
                user.RemoveDequip(dat.desn)
            else
                ret = user.GetDequip(dat.desn)
                if ret then ret:Sync(dat) end
            end
            return dat
        end
    end,
    --军备残片操作
    [Func.DequipSp] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat)
            return dat
        end
    end,
    --endregion

    --region ------------------------------------任务-------------------------------------
    --任务列表
    [Func.QuestList] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_QuestList) end end,
    --任务完成
    [Func.QuestCompleted] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat)
            if user.questQty > 0 then
                user.questQty = user.questQty - 1
                user.changed = true
            end
            return dat
        end
    end,
    --支线任务完成
    [Func.QuestSide] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat)
            if user.questQty > 0 then
                user.questQty = user.questQty - 1
                user.changed = true
            end
            return dat
        end
    end,
    --endregion

    --region ------------------------------------酒馆-------------------------------------
    --酒馆信息
    [Func.TavernInfo] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_TavernInfo)
            user.SyncTavern(dat)
            return dat
        end
    end,
    --刷新酒馆信息
    [Func.ReTavern] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_TavernInfo)
            --Analytics.Buy("RE_TAVERN", 1, mat.max(0, user.gold - dat.gold))
            user.SyncTavern(dat)
            user.changed = true
            return dat
        end
    end,
    --刷新酒馆信息
    [Func.TavernOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_TavernOpt)
            --if user.gold > dat.gold then Analytics.Buy("HERO", 1, user.gold - dat.gold) end
            user.SyncReward(dat.rws)
            user.SyncTavern(dat)
            user.changed = true
            return dat
        end
    end,
    --酒馆
    [Func.Tavern] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Tavern)
            --if user.gold > dat.gold then Analytics.Buy("HERO", 1, user.gold - dat.gold) end
            user.SyncReward(dat.rewards, true)
            user.SyncTavern(dat)
            user.changed = true
            return dat
        end
    end,
    --endregion

    --region --------------------------------意见反馈-------------------------------------
    [Func.SuggestOpt] = function(ret, dat) end,
    --endregion

    --region ----------------------------------商城 消费----------------------------------
    --商城购买结果
    [Func.BuyGoods] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_BuyResult)
            if dat.coin then user.coin = dat.coin end
            if dat.gold then user.gold = dat.gold end
            if dat.rmb then user.rmb = dat.rmb end
            user.changed = true
            user.AddPropsQty(dat.sn, dat.qty)
            --Analytics.Buy(tostring(dat.sn), dat.qty, DB.GetProps(dat.sn).gold)
            return dat
        end
    end,
    --金换银
    [Func.G2C] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_G2C)
            if dat.coin then
                ret = math.max(0, dat.coin - user.coin)
                user.coin = dat.coin
                dat.coin = ret
            end
            if dat.gold then
                ret = math.max(0, user.gold - dat.gold)
                user.gold = dat.gold
                dat.gold = ret
                --Analytics.Buy("G2C", 1, ret);
            end
            if dat.qty then user.g2cQty = dat.qty end
            if dat.usedQty then user.g2cUsed = dat.usedQty end
            user.changed = true
            return dat
        end
    end,
    --10连抽
    [Func.GetReward10] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Reward10)
            --Analytics.Buy("RW10", 1, DB.param.prRw10)
            user.SyncReward(dat.rws, true)
            user.drwQty = dat.dhQty
            ret = dat.cds
            if ret then
                if ret[1] then user.rw1Tm.time = ret[1] end
                if ret[2] then user.rw10Tm.time = ret[2] end
                if ret[3] then user.drw1Tm.time = ret[3] end
            end
            user.SyncMoney(dat.money)
            user.changed=true
            return dat
        end
    end,
    --珍宝阁商品操作
    [Func.RmbShopOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_RmbShopInfo)
            user.SyncReward(dat.rws)
            user.SyncMoney(dat.money)
            return dat
        end
    end,
    --幻境商城
    [Func.FantsyShopOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_RmbShopInfo)
            user.SyncReward(dat.rws)
            ret = dat.money
            if ret then
                if ret[1] then user.gold = ret[1] end
                if ret[2] then user.coin = ret[2] end
                if ret[3] then user.rmb = ret[3] end
                if ret[4] then user.fantsyCoin = ret[4] end
                user.changed = true
            end
            return dat
        end
    end,
    --巅峰商城
    [Func.PeakShopOption] = function(ret,dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_RmbShopInfo)
            user.SyncReward(dat.rws)
            ret = dat.money
            if ret then
                if ret[1] then user.gold = ret[1] end
                if ret[2] then user.coin = ret[2] end
                if ret[3] then user.rmb = ret[3] end
                if ret[4] then user.peakCoin = ret[4] end
                user.changed = true
            end
            return dat
        end
    end,
    --购买礼包结果
    [Func.GetGifts] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_BuyGift)
            user.SyncReward(dat.rws)
            if dat.gold then user.gold = dat.gold end
            if dat.coin then user.coin = dat.coin end
            if dat.rmb then user.rmb = dat.rmb end
            user.changed = true
            return dat
        end
    end,
    --使用/赠送道具
    [Func.UseProps] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_UseProps)
            user.SyncReward(dat.rws, true)
            user.SetPropsQty(dat.sn, dat.leftQty)
            -- Analytics.Use(res.propsSN.ToString(), math.max(0, ret - dat.leftQty), DB.GetProps(dat.sn).gold)
            return dat
        end
    end,
    --将魂操作
    [Func.SoulOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HeroSoulOption)
            user.SyncReward(dat.rws)
            user.SyncMoney(dat.money)
            user.SetSoulQty(dat.dbsn, dat.soulQty)
            user.changed = true
            return dat
        end
    end,
    --endregion

    --region -----------------------------------战斗玩法----------------------------------
    --副本次数同步
    [Func.GetLevelFB] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_CityFB)
            user.SyncPveCityFB(dat)
            return dat
        end
    end,
    --副本扫荡
    [Func.SDFB] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_FBSD)
            user.SyncReward(dat.rws)
            if dat.gold then user.gold = dat.gold end
            if dat.coin then user.coin = dat.coin end
            if dat.rmb then user.rmb = dat.rmb end
            if dat.fbSdQty then user.fbSdQty = dat.fbSdQty end
            if dat.fbSdPrice then user.fbSdPrice = dat.fbSdPrice end
            if dat.vit then user.vit = dat.vit end
            user.changed = true
            return dat
        end
    end,
    --获取战役信息
    [Func.GetWar] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_WarInfo)
            user.SetPropsQty(DB_Props.TIAO_ZHAN_LING, dat.leftTicket)
			if (dat.available and #dat.available or 0) < (dat.wars and #dat.wars or 0) then
				if dat.available then
					table.insert(dat.available, dat.wars[#dat.available + 1])
				else
					dat.available = { dat.wars[1] }
				end
			end
            return dat
        end
    end,
    --刷新战役挑战次数
    [Func.RefreshWar] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_RefreshWar)
            --Analytics.Buy("RE_WAR", 1, math.max(0, user.gold - dat.gold))
            if dat.gold then user.gold = dat.gold end
            if dat.coin then user.coin = dat.coin end
            user.changed = true
            return dat
        end
    end,
    --获取战役奖励
    [Func.GetWarReward] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat)
        end
    end,
    --演武榜对手列表
    [Func.PvpRankRival] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_PlayerInfos) end end,
    --演武榜操作
    [Func.RankOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_PvpRankInfo)
            user.SyncMoney(dat.money)
            return dat
        end
    end,
    --获取BOSS战信息
    [Func.GetBossInfo] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_BossInfo) end end,
    --BOSS操作
    [Func.BossOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_BossOption)
            if dat.rmb then user.rmb = dat.rmb end
            if dat.coin then user.coin = dat.coin end
            user.changed = true
            return dat
        end
    end,
    --二代BOSS
    [Func.Boss2] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_Boss2) end end,
    --过关斩将
    [Func.TowerOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_TowerInfo)
            user.towerInfo = dat
            user.SyncReward(dat.rws)
            if dat.gold then user.gold = dat.gold end
            if dat.coin then user.coin = dat.coin end
            if dat.rmb then user.rmb = dat.rmb end
            user.changed = true
            return dat
        end
    end,
    --乱世争雄操作
    [Func.ClanWar] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_ClanWarInfo) end end,
    --幻境挑战
    [Func.Fantsy] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_Fantsy) end end,
    --幻境挑战兵种阵型设置
    [Func.FantsySL] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_FantsyHeroSL) end end,
    --endregion

    --region ------------------------------------战斗-------------------------------------
    --设置军师技
--    [Func.SetSkillT] = function(ret, dat) end,
    --战斗准备信息
    [Func.BattleReady] = function(ret, dat, sfs)
        if ret == 0 then
            local bat = QYBattle.GenBattleSiege(dat, tonumber(sfs:GetClass("ou_ver")) or 0)
            user.hp = bat.playerHP
            user.tp = bat.playerTP

            if bat.atkQty > 0 then
                if bat.isConsume then
                    local temp = nil
                    local ph = nil
                    for i = 1, bat.atkQty do
                        temp = bat:GetAtkHero(i)
                        ph = user.GetHero(temp.sn)
                        if ph then
                            ph.hp = temp.hp.value
                            ph.sp = temp.sp.value
                            ph.tp = temp.tp.value
                            ph.loyalty = temp.loyalty.value
                        end
                    end
                elseif bat.isConsumeLoyaty then
                    local temp = nil
                    local ph = nil
                    for i = 1, bat.atkQty do
                        temp = bat:GetAtkHero(i)
                        ph = user.GetHero(temp.sn)
                        if ph then  ph.loyalty = temp.dat.loyalty.value end
                    end
                end
                bat:SortAtkHero(user.expHeroRecord)
            end
            if bat.defQty > 0 then user.inBattle = true
            else bat = nil end
            user.changed = true
            return bat
        end
    end,
    --战斗对战信息
    [Func.BattleFight] = function(ret, dat)
        if ret == 0 then
            return dat 
        end
    end,
    --战斗结算
    [Func.BattleResult] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_BattleResult)
            user.battleRet = dat
            user.inBattle = false
            user.SyncReward(dat.rws, true)
            local heros = dat.heros
            local qty = heros and #heros or 0
            local tmp = nil
            local flag = false
            if qty > 0 then
                --战胜后记录上次出战武将
                if dat.ret == 1 then
                    local ret = user.expHeroRecord 
                    local lenR = ret and #ret or 0
                    local idx = 1
                    for i = 1, qty do
                        tmp, flag = heros[i], false
                        while idx <= lenR do
                            for j = i, qty do
                                if tostring(heros[j].csn) == tostring(ret[idx]) then
                                    flag = true
                                    if i ~= j then
                                        heros[i] = heros[j]
                                        heros[j] = tmp
                                    end
                                    break
                                end
                            end
                            idx = idx + 1
                            if flag then break end
                        end
                    end
                    if dat.kind > 0 and dat.kind < 5  then
                        tmp = { }
                        for i = 1, qty do tmp[i] = tostring(heros[i].csn) end
                        user.LastBattleHero = tmp
                    end
                end
                --更新武将HP SP TP LT
                if QYBattle.Battle.IsConsume(dat.kind) then
                    --全消耗战
                    for i = 1, qty do
                        tmp = heros[i]
                        ret = user.GetHero(tmp.csn)
                        if ret then
                            ret.hp = tmp.hp or ret.hp
                            ret.sp = tmp.sp or ret.sp
                            ret.tp = tmp.tp or ret.tp
                            ret.loyalty = tmp.loyalty or ret.loyalty
                        end
                    end
                elseif QYBattle.Battle.IsConsumeLoyaty(dat.kind) then
                    --仅消耗忠诚
                    for i = 1, qty do
                        tmp = heros[i]
                        ret = user.GetHero(tmp.csn)
                        if ret then ret.loyalty = tmp.loyalty or ret.loyalty end
                    end
                end
            end
            if dat.kind == 1 then
                --PVE
                --胜利重新获取关卡信息
                if dat.ret == 1 then SVR.GetLevelMap(user.gmLv) end
                local fromCity = nil
                if qty > 0 then
                    for i = 1, qty do
                        tmp = heros[i]
                        ret = user.GetHero(tmp.csn)
                        if ret then
                            if dat.ret == 1 then
                                if fromCity == nil then fromCity = { } end
                                flag = true
                                if i > 1 then
                                    for j = 1, i - 1 do
                                        if fromCity[j] == ret.loc then
                                            flag = false
                                            break
                                        end
                                    end
                                end
                                if flag then fromCity[i] = ret.loc end
                                ret:SetLoc(dat.sn)
                            end
                            --经验和等级互换保存，用于演示升级
                            local lv, exp = ret.lv, ret.exp
                            ret:SetLv(tmp.lv, tmp.exp)
                            tmp.lv, tmp.exp = lv, exp
                        end
                    end
                end

                if dat.ret == 1 then
                    --更新地图数据
                    user.gmMaxCity = dat.sn or user.gmMaxCity

--                    Analytics.FinishLevel(tostring(user.gmMaxCity))
--                    Analytics.StartLevel(tostring(user.NextCity))
                    user.AddPveCity({ sn = dat.sn, heroQty = qty, lv = 1, fbQty = user.FbQty, fbDif = 1, tm = DB.param.cdCityCrop })
                    if fromCity then
                        for _, v in pairs(fromCity) do
                            if v > 0 then
                                ret = user.GetPveCity(v)
                                if ret then ret:CalcHeroQty() end
                            end
                        end
                    end
--                else
--                    Analytics.FailLevel(tostring(dat.sn))
--                    Analytics.StartLevel(tostring(dat.sn))
                end

--                if MapManager.Instance then MapManager.Instance.RefreshLevelMapCity()
--            elseif dat.kind == 2 then
                --战役，改为直接刷新
            elseif dat.kind == 3 then
                --PVP
                if dat.ret == 1 then
                    --原有武将清理
                    ret = user.GetCityHero(dat.sn)
                    if #ret > 0 then
                        tmp = math.max(1, user.gmMaxCity)
                        for i = 1, #ret do ret[i]:SetLoc(tmp) end
                    end
                    --更新武将位置
                    if qty > 0 then
                        for i = 1, qty do
                            tmp = heros[i]
                            ret = user.GetHero(tmp.csn)
                            if ret then ret:SetLoc(dat.sn) end
                        end
                    end
                    --添加占领城池
                    ret = user.GetPvpCity(dat.sn)
                    if ret then ret:SetToMyColony() end
                end
            elseif dat.kind == 4 then
                --副本
                if dat.ret == 1 then
                    ret = user.GetPveCity(dat.sn)
                    if ret then
                        ret:SetFbQty(ret.fbQty - 1)
--                        tmp = WinBattle 待做
                    end
                end
            elseif dat.kind == 7 then
                --过关斩将
                user.towerInfo.rank = 0
            elseif dat.kind == 11 then
                --矿脉
                Win.Open("WinNatMineMap")
            end
            return dat
        end
    end,
    --俘虏操作
    [Func.SiegeCaptive] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_SiegeCaptive)
            if dat.opt == "conv" and dat.csn ~= 0 and dat.dbsn > 0 then
                user.AddHero(dat.csn, dat.dbsn, dat.city or 0)
            end
            return dat
        end
    end,
    --endregion

    --region -----------------------------------奖励玩法----------------------------------
    --占卜操作
    [Func.DivineOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_DivineOption)
            user.SyncReward(dat.rws, true)
            user.coin = dat.coin or user.coin
            user.gold = dat.gold or user.gold
            user.rmb = dat.rmb or user.rmb
            user.dvnQty = dat.freeQty
            user.changed = true
            return dat
        end
    end,
    --占卜排行
    [Func.DivineRank] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_DivineRank) end end,
    --秘境操作
    [Func.FamOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Fam)
            user.SyncReward(dat.rws)
            user.SyncMoney(dat.money)
            user.famQty = dat.diceQty
            return dat
        end
    end,
    --秘境通关奖励
    [Func.FamReward] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_FamReward)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --宴会[int,rws]
    [Func.Feast] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.feasRec = dat[1] or user.feasRec
            user.SyncReward(dat[2])
            return dat
        end
    end,
    --endregion

    --region -----------------------------------奖励目标----------------------------------
    --获取签到数据
    [Func.GetSignData] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_SignInfo)
            user.sign = dat.isSign
            return dat
        end
    end,
    --签到操作
    [Func.Sign] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Sign)
            user.SyncMoney(dat.money)
            user.SyncReward(dat.rws)
            user.sign = dat.info and dat.info[1] ~= 0
            return dat
        end
    end,
    --VIP礼包领取
    [Func.VipGift] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_VipGift)
            user.SyncReward(dat.rws)
            user.vipGiftLv = dat.giftLv + 1
            user.vip = dat.vipLv
            return dat
        end
    end,
    --七日签到奖励
    [Func.RewardSeven] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat)
            user.SetSevenRw()
            return dat
        end
    end,
    --议事厅
    [Func.AffairOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Affair)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --议事厅排行
    [Func.AffairRankOption] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_AffairRank) end end,
    --成就
    [Func.Achievement] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Achievement)
            user.SyncReward(dat.rws, true)
            return dat
        end
    end,
    --等级限时礼包
    [Func.GiftOpt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_GiftOpt)
            user.SyncReward(dat.rws, true)
--            MainPanel.Instance.RefreshGiftBtn(res) 待做
            return dat
        end
    end,
    --日常操作[int,int[],rws]
    [Func.DailyOpt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat[4])
            return dat
        end
    end,
    --endregion

    --region -------------------------------------联盟------------------------------------
    --创建联盟
    [Func.AllyCreat] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_CreatAlly)
            user.coin = dat.coin or user.coin
            user.gold = dat.gold or user.gold
            ret = user.ally
            ret.gsn = CheckSN(dat.gsn)
            ret.gnm = dat.gnm
            ret.banner = dat.banner
            ret.flag = dat.flag
            ret.nsn = 0
            user.changed = true
            user.allyChanged = true
            ret = user.MyPvpCity
            if ret then ret:SetAlly(user.ally.gsn, dat.gnm) end
            return dat
        end
    end,
    --解散联盟
    [Func.AllyDisband] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_DisbandAlly)
            user.coin = dat.coin or user.coin
            user.gold = dat.gold or user.gold
            user.changed = true
            return dat
        end
    end,
    --联盟列表
    [Func.AllyList] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_AllyList) end end,
    --联盟信息
    [Func.AllyInfo] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_AllyInfo) end end,
    --联盟成员列表
    [Func.AllyMember] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_AllyMemberList) end end,
    --联盟操作
    [Func.AllyOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_AllyOption)
            user.coin = dat.coin or user.coin
            user.gold = dat.gold or user.gold
            user.changed = true

            ret = user.ally
            if dat.nsn and dat.nsn > 0 then ret.nsn = dat.nsn end
            if dat.lv and dat.lv > 0 then ret.lv = dat.lv end
            if dat.money and dat.money >= 0 then ret.money = dat.money end
            if dat.renown and dat.renown >= 0 then ret.renown = dat.renown end
            if dat.renownWeek and dat.renownWeek >= 0 then ret.renownWeek = dat.renownWeek end
            if dat.myRenown and dat.myRenown >= 0 then ret.myRenown = dat.myRenown end
            if dat.donCoin and dat.donCoin >= 0 then ret.donCoin = dat.donCoin end
            if dat.donGold and dat.donGold >= 0 then ret.donGold = dat.donGold end
            if dat.impInfo and #dat.impInfo > 0 then
                ret.impName = dat.impName
                ret.impInfo = dat.impInfo
            end
            user.allyChanged = true
            return dat
        end
    end,
    --联盟留言板操作
--    [Func.AllyMsgBoard] = function(ret, dat) end,
    --联盟留言板操作
--    [Func.AllyAnno] = function(ret, dat) end,
    --联盟科技捐献
    [Func.AllyTechDev] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_AllyTechDonate)
            user.coin = dat.silver or user.coin
            user.rmb = dat.diamond or user.rmb
            user.ally.myRenown = dat.myRenown
            user.ally.myRenownWeek = dat.myRenownWeek
            user.changed = true
            user.allyChanged = true
            return dat
        end
    end,
    --联盟商店商品操作
    [Func.AllyShopOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_RmbShopInfo)
            user.SyncReward(dat.rws)
            user.SyncMoney(dat.money)
            user.changed = true
            user.allyChanged = true
            return dat
        end
    end,
    --联盟任务操作
    [Func.AllyQuestOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_AllyQuestOption)
            user.SyncReward(dat.rws)
            if dat.cd then user.allyQstTm.time = dat.cd end
            return dat
        end
    end,
    --联盟改名
    [Func.AllyReName] = function(ret, dat)
        if ret == 0 then
            user.AddPropsQty(DB_Props.LIAN_MENG_GAI_MING, - 1)
            dat = string.split(dat, ',')
            if dat and dat[1] == user.ally.gsn then
                if dat[2] then user.ally.gnm = dat[2] end
                if dat[3] then user.ally.banner = dat[3] end
                user.allyChanged = true
            end
            return dat
        end
    end,
    --联盟战 - 初始信息
    [Func.AllyBattleInfo] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_AllyBattle)
            if dat.timeLine and dat.timeLine[1] > 0 then SVR.SetSvrTime(dat.timeLine[1]) end
            return dat
        end
    end,
    --联盟战 - 报名
--    [Func.AllyBattleEnroll] = function(ret, dat) end,
    --联盟战 - 获取联盟战队信息
    [Func.AllyBattleTeamInfo] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_AllyBattleTeam) end end,
    --联盟战 - 获取我的战队信息
    [Func.AllyBattleMyTeamInfo] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_AllyBattleHero) end end,
    --联盟战 - 联盟操作
    [Func.AllyBattleOpt] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_AllyBattleOpt) end end,
    --联盟战 - 获取战报
    [Func.AllyBattleReport] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_SwarReport) end end,
    --联盟战 - 战斗回放
    [Func.AllyBattleRec] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_BattleDataRec) end end,
    --联盟战 - 排行榜
    [Func.AllyBattleRank] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_AllyBattleRank) end end,
    --联盟 - 商城
    [Func.AllyBattleShop] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_RmbShopInfo)
            user.SyncReward(dat.rws)
            user.SyncMoney(dat.money)
            user.allyChanged = true
            return dat
        end
    end,
    --endregion

    --region ---------------------------------借将-----------------------------------
    --借将申请的处理
    [Func.AllyBorrowHeroOpt] = function(ret,dat) if ret == 0 then return ldec(dat, stab.S_AllyBorrowHeroFromOther) end end,
    --借将申请查询
    [Func.AllyBorrowHeroCheck] = function(ret,dat) if ret == 0 then return ldec(dat, stab.S_AllyBorrowHeroCheck) end end,
    --endregion

    --region -----------------------------------PVP争霸-----------------------------------
    --获取PVP地图区信息
    [Func.GetPvpZone] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_PvpZone)
            user.SetPvpZoneUpTime(dat.zone)
            user.AddPvpZone(dat)
            --通知MapPvp更新
            LoadPvpZone(dat.zone)
            return dat.zone
        end
    end,
    --联盟列表
    [Func.PvpCityInfo] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_PvpCityInfo) end end,
    --征收信息 1=金币,2=银币,3=医馆,4=兵力,5=体力,6=寒铁
    [Func.GetCropInfo] = function(ret, dat) if ret == 0 then return ldec(dat) end end,
    --征收结果 1=金币,2=银币,3=医馆,4=兵力,5=体力,6=寒铁
    [Func.GetCrop] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            local addGold = dat[1] - user.gold
            local addCoin = dat[2] - user.coin
            local addHP = dat[3] - user.hp
            local addTP = dat[4] - user.tp
            local addHT = dat[5] - user.GetPropsQty(DB_Props.HAN_TIE)
            user.gold = dat[1] or user.gold
            user.coin = dat[2] or user.coin
            user.hp = dat[3] or user.hp
            user.tp = dat[4] or user.tp
            user.changed = true
            user.SetPropsQty(DB_Props.HAN_TIE, dat[6])
            ret = (addGold > 0 and "\n"..L("金币")..ColorStyle.Gold("+"..addGold) or "")
                ..(addCoin > 0 and "\n"..L("银币")..ColorStyle.Silver("+"..addCoin) or "")
                ..(addHP > 0 and "\n"..L("血库")..ColorStyle.Good("+"..addHP) or "")
                ..(addTP > 0 and "\n"..L("兵力")..ColorStyle.Blue("+"..addTP) or "")
                ..(addHT > 0 and "\n"..L("寒铁")..ColorStyle.Blue("+"..addHT) or "")
            if ret ~= "" then ToolTip.ShowPopTip(string.sub(ret, 2)) end
            return dat    
        end
    end,
    --PVP城池列表
    [Func.GetTerritoryList] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_TerritoryList)
            if dat.opt == "pve" then
                user.SyncPveCityTer(dat)
            elseif dat.opt == "pvp" then
                user.SyncColonyFromPvpList(dat)
            end
            return dat
        end
    end,
    --endregion

    --region -------------------------------------活动------------------------------------
    --活动列表
    [Func.ActLst] = function(ret, dat) if ret == 0 then return ldec(dat) end end,
    --活动通用操作
    [Func.ActOpt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_ActData)
            user.SyncReward(dat.rws, true)
            user.SyncReward(dat.rws2, true)
            user.SyncAct(dat)
            return dat
        end
    end,
    --活动-献帝宝库
    [Func.ActOpt108] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Act108)
            user.SyncReward(dat.rws, true)
            user.SyncReward(dat.rws2, true)
            return dat
        end
    end,
    --活动-CP对决
    [Func.ActOpt17] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_Act17) end end,
    --活动-消消乐
    [Func.ActOpt18] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Act18)
            user.SyncReward(dat.rws, true)
            user.SyncReward(dat.rws2, true)
            return dat
        end
    end,
    --活动-幸运号
    [Func.ActOpt20] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Act20)
            user.SyncReward(dat.rws, true)
            return dat
        end
    end,
    --活动-幸运号记录 [int,int[]]
    [Func.ActRec20] = function(ret, dat) if ret == 0 then return ldec(dat) end end,
    --活动-有限转盘 [int[],rws,rws2]
    [Func.ActOpt21] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat[2], true)
            user.SyncReward(dat[3], true)
            return dat
        end
    end,
    --活动-群英客栈 [int[],int[],rws]
    [Func.ActOpt34] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat[3])
            return dat
        end
    end,
    --活动-武将拼图 [int,int[],string[],rws]
    [Func.ActOpt36] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat[4], true)
            return dat
        end
    end,
    --活动-合服活动列表
    [Func.ActGetHF] = function(ret, dat) if ret == 0 then return ldec(dat) end end,
    --活动-充值排行
    [Func.GetRechargeRank] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_RechargeRank) end end,
    --活动-开服基金操作
    [Func.GetFundOpt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_FundOption)
            print(kjson.print(dat.rws))
            user.SyncReward(dat.rws)
            user.coin = dat.coin or user.coin
            user.gold = dat.gold or user.gold
            user.rmb = dat.rmb or user.rmb
            user.changed = true
            return dat
        end
    end,
    --活动-活动红包打开结果
    [Func.ActRedGet] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_ActRed)
            if res.partGet and res.partGet > 0 then
                local red = DB.GetRed(dat.redbsn)
                if red.part > 0 then
                    local rate = dat.partGet / red.part
                    if red.asn > 0 and red.score > 0 then
                        ret = user.GetAct(red.asn)
                        if ret then ret:AddScore(math.ceil(red.score * rate)) end
                    end
                    if red.coin > 0 then user.coin = user.coin + math.ceil(red.coin * rate) end
                    if red.gold > 0 then user.gold = user.gold + math.ceil(red.gold * rate) end
                    if red.rmb > 0 then user.rmb = user.rmb + math.ceil(red.rmb * rate) end
                    user.changed = true
                end
            end
            return dat
        end
    end,
    --活动-考试
    [Func.Exam] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_ExamInfo) end end,
    --活动-考试
    [Func.ExamOpt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_ExamOpt)
            user.SyncReward(dat.rws, true)
            return dat
        end
    end,
    --活动-考试
    [Func.ExamRank] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_ExamRankList) end end,
    --endregion

    --region -------------------------------------国战------------------------------------
    --活跃
    [Func.NatAct] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatAct)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --觐见
    [Func.NatOption] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatCult)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --国家信息
    [Func.GetNatInfo] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_NatInfo) end end,
    --总览
    [Func.NatOverview] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatOverview)
            user.nat:Sync(dat)
            UpdateNat()
            UpdateNatNpc()
            user.changed = true
            return dat
        end
    end,
    --国战武将信息
    [Func.NatHero] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatHeroArray)
            dat = dat.heros
            user.nat:SyncHero(dat)
            --EventManager.Broadcast(EventName.UpdateCountryHero)
            return dat
        end
    end,
    --国战城池信息
    [Func.NatCityInfo] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatFightInfo)
            if dat.atkHeros then table.sort(dat.atkHeros, NatFightHeroCompare) end
            if dat.defHeros then table.sort(dat.defHeros, NatFightHeroCompare) end
            return dat
        end
    end,
    --部署国战武将
    [Func.NatSetHero] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatHeroArray)
            dat = dat.heros
            user.nat:SyncHero(dat)
            --EventManager.Broadcast(EventName.UpdateCountryHero)
            return dat
        end
    end,
    --武将移动
    [Func.NatHeroMove] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatHeroMove)
            user.nat.raidTm = dat.raidTm or user.nat.raidTm
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --国战武将操作
    [Func.NatHeroOpt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatHeroOpt)
            user.gold = dat.gold or user.gold
            user.coin = dat.coin or user.coin
            user.rmb = dat.rmb or user.rmb
            user.token = dat.token or user.token
            user.changed = true
            user.nat.food = dat.pfood or user.nat.food
            user.nat.copyQty = dat.copyQty or user.nat.copyQty
            ret = user.nat:GetHero(dat.csn)
            if ret then ret:Sync(dat) end
            return dat
        end
    end,
    --国战单挑
    [Func.NatSolo] = function(ret, dat)
        if ret == 0 then
            user.natSoloCD = DB.param.cdNatSolo
            dat = ldec(dat, stab.S_BattleSoloResult)
            return dat
        end
    end,
    --国战战报
    [Func.NatReport] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatReport)
            if dat and #dat > 0 then
                for i, v in ipairs(dat) do
                    if v.time then
                        i = string.find(v.time," ", 1, true)
                        if i then v.time = string.sub(v.time, i + 1) end
                    end
                end
            end
            return dat
        end
    end,
    --国战回放
    [Func.NatReplay] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_BattleDataRec) end end,
    --国战活动信息
    [Func.NatActInfo] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatActInfo)
            user.nat:SyncAct(dat)
            UpdateNatAct()
            --EventManager.Broadcast(EventName.UpdateCountryAct);
            return dat
        end
    end,
    --国战粮草
    [Func.NatFood] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_GetFoodResult)
            if dat.food then
                ret = user.nat.food
                user.nat.food = dat.food
                dat.food = dat.food - ret
            end
            user.nat.getFoodQty = dat.getFoodQty or user.nat.getFoodQty
            user.nat.buyFoodQty = dat.buyFoodQty or user.nat.buyFoodQty
            user.nat.buyFoodPrice = dat.buyFoodPrice or user.nat.buyFoodPrice
            user.coin = dat.coin or user.coin
            user.gold = dat.gold or user.gold
            user.rmb = dat.rmb or user.rmb
            user.changed = true
            return dat
        end
    end,
    --国战武将补充粮草
    [Func.NatHeroFood] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatHeroFood)
            user.nat.food = dat.pfood or user.nat.food
            ret = user.nat:GetHero(dat.csn)
            if ret then 
                ret.food = dat.food 
                ret.changed = true
            end
            user.changed = true
            --EventManager.Broadcast(EventName.UpdateUserInfo)
            return dat
        end
    end,
    --武将晋升军阶
    [Func.HeroRankUp] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HeroRankUp)
            ret = user.GetHero(dat.csn)
            if ret then
                local s, w, c, h = ret.baseStr, ret.baseWis, ret.baseCap, ret.baseHP
                ret:SetBaseStr(dat.str)
                ret:SetBaseWis(dat.wis)
                ret:SetBaseCap(dat.cap)
                ret:SetBaseHP(dat.hp)
                ret:SetTtl(dat.ttl)
                if dat.str then dat.str = dat.str - s end
                if dat.wis then dat.wis = dat.wis - w end
                if dat.cap then dat.cap = dat.cap - c end
                if dat.hp then dat.hp = dat.hp - h end
            end
            return dat
        end
    end,
    --突破军阶
    [Func.HeroRank]=function(ret,dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_HeroRankUp)
            ret = user.GetHero(dat.csn)
            if ret then
                local s, w, c, h = ret.baseStr, ret.baseWis, ret.baseCap, ret.baseHP
                ret:SetBaseStr(dat.str)
                ret:SetBaseWis(dat.wis)
                ret:SetBaseCap(dat.cap)
                ret:SetBaseHP(dat.hp)
                ret:SetTtl(dat.ttl)
                if dat.str then dat.str = dat.str - s end
                if dat.wis then dat.wis = dat.wis - w end
                if dat.cap then dat.cap = dat.cap - c end
                if dat.hp then dat.hp = dat.hp - h end
            end
            return dat
        end
    end,
    --玩家晋升爵位
    [Func.UserPeerageUp] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_UserTtlUp)
            if dat.ttl then
                ret = user.Title.food
                user.ttl = dat.ttl
                user.nat.foodMax = user.nat.foodMax + math.max(0, user.Title.food - ret)
                user.changed = true
                --EventManager.Broadcast(EventName.UpdateCountryHero)
            end
            
            return dat
        end
    end,
    --国库
    [Func.NatShop] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatShop)
            user.nat.lv = dat.natLv or user.nat.lv
            user.gold = dat.gold or user.gold
            user.coin = dat.coin or user.coin
            user.rmb = dat.rmb or user.rmb
            user.token = dat.token or user.token
            user.changed = true
            return dat
        end
    end,
    --国库购买
    [Func.NatBuyGoods] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatBuyGoods)
            user.SyncReward(dat.rws)
            user.gold = dat.gold or user.gold
            user.coin = dat.coin or user.coin
            user.rmb = dat.rmb or user.rmb
            user.token = dat.token or user.token
            user.changed = true
            return dat
        end
    end,
    --州郡操作
    [Func.NatState] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatStateOpt)
            user.SyncState(dat.states)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --矿脉
    [Func.NatMine] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatMineOpt)
            user.SyncReward(dat.rws)
            user.mine = dat.mine or user.mine
            user.mineIsOcc = dat.isOcc or user.mineIsOcc
            return dat
        end
    end,
    --血战
    [Func.NatBlood] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatBlood)
            user.SyncReward(dat.rws)
            user.nat.bloodCD = dat.cd or user.nat.bloodCD
            user.nat.bloodTm = dat.time or user.nat.bloodTm
            user.nat.bloodCity = dat.city or user.nat.bloodCity
            user.nat.bloodPause = dat.pause or user.nat.bloodPause
            return dat
        end
    end,
    --城池变更精简广播
    [Func.CityChange] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_NatCity)
            if dat.sn and dat.sn > 0  and user.nat.city then
                for i, c in ipairs(user.nat.city) do
                    if c.sn == dat.sn then
                        user.nat.city[i] = dat
                        if dat.def ~= c.def then
                            --EventManager.Broadcast(EventName.CountryCityChange, res.sn)
                        end
                        --EventManager.Broadcast(EventName.UpdateCountry
                        user.nat:CityStatusChange(dat.sn)
                        break
                    end
                end
            end
            return dat
        end
    end,
    --国战战斗广播
    [Func.NatBattle] = function(ret, dat)
        if ret == 0 then
            local res = ldec(dat, stab.S_NatBattle)
            print("国战战斗广播    ",kjson.print(res))
            if res.atk.psn == user.psn then
                user.merit = res.atk.pmerit
            elseif res.def.psn == user.psn then
                user.merit = res.def.pmerit
            end

            local ch = nil
            local hd = nil
            local winner, loser = nil, nil
            if res.ret > 0 then
                winner = res.atk
                loser = res.def
            else
                winner = res.def
                loser = res.atk
            end

            --胜者设置
            if winner.csn > 0 then
                if winner.isCopy == 0 then
                    ch = user.nat:GetHero(winner.csn)
                    if ch ~= nil then
                        print("胜者设置~~~~~~~~~~~~~~~~~~~~~")
                        ch.food = winner.hp
                        ch.fatig = winner.fatig
                    end
                end
                hd = user.GetHero(winner.csn)
                if hd ~= nil then
                    hd.merit = winner.pmerit
                end
            end
            --败者设置
            if loser.csn > 0 then
                if loser.isCopy == 0 then
                    ch = user.nat:GetHero(loser.csn)
                    if ch ~= nil then
                        ch.food = loser.hp
                        ch.fatig = loser.fatig
                        ch:ReturnCapital()
                    end
                end
                hd = user.GetHero(loser.csn)
                if hd ~= nil then
                    hd.merit = loser.pmerit
                end
            end

            --城池状态
            print("城池状态   city ",kjson.print(user.nat.city))
            print("城池状态 hero ",kjson.print(user.nat.heros))
            local city = user.nat.city
            if res.city > 0 and res.nsn and city ~= nil then
                for i = 1 ,#city do
                    if city[i].sn == res.city then
                        --城池战斗状态发生改变
                        local f1 = false
                        --城池所属发生改变
                        local f2 = false
                        if res.atkQty > 0 then
                            if city[i].atk <= 0 then
                                city.atk = res.atkQty
                                f1 = true
                            end
                        elseif city[i].atk > 0 then 
                            city[i].atk = 0
                            f1 = true
                        end
                        if res.nsn ~= city[i].def then
                            --蛮族入侵判断  蛮族期间且是都城
                            if user.barbarianTime <= 0 and PY_Nat.IsBarbarian(city[i].sn) then
                                --改变城池状态
                                city[i].atk = -1
                                --让英雄回城
                                for j = 1 ,#user.nat.heros  do
                                    local hDat = user.nat.heros[j]
                                    if hDat then
                                        if hDat.city == res.city then
                                            hDat:ReturnCapital()
                                        end
                                    end
                                end
                            else
                                city[i].def = res.nsn
                                f2 = true
                            end
                        end
                        if f2 then
                            user.nat:CityStatusChange(res.sn)
                        end
                        if f1 or f2 then
                            UpdateNat()
                        end
                        if f1 then
                            user.nat:CityStatusChange(res.sn)
                        end
                        break
                    end
                end
            end
            if true then
                print("分身的判断！！！未做")
            end
--            UpdateNatHero()
        end
    end,
    --国战日常
    [Func.NatDaily] = function(ret, dat)
        if ret==0 then
            dat = ldec(dat)
            return dat
        end
    end,
    --endregion

    --region -----------------------------------跨服国战----------------------------------

    --endregion

    --region -------------------------------------其它------------------------------------
    --物品出售
    [Func.ItemSell] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_ItemRecycle)
            user.SyncReward(dat.rws)
            ret = dat.item
            if ret and #ret > 0 then
                if dat.opt == "eq" then
                    --装备出售
                    for _, v in ipairs(ret) do user.RemoveEquip(v) end
                elseif dat.opt == "eqr" then
                    --装备出售 按稀有度
                    local rare = { }
                    for _, v in ipairs(ret) do rare[v] = true end
                    ret = user.GetEquips(function(e) return rare[e.rare] and not e.IsEquiped end)
                    if ret and #ret > 0 then
                        for _, v in ipairs(ret) do user.RemoveEquip(v.sn) end
                    end
                elseif dat.opt == "dq" then
                    --军备出售
                    for _, v in ipairs(ret) do user.RemoveDequip(v) end
                elseif dat.opt == "dqr" then
                    local rare = { }
                    for _, v in ipairs(ret) do rare[v] = true end
                    ret = user.GetDequips(function(e) return rare[e.rare] and not e.IsEquiped end)
                    if ret and #ret > 0 then
                        for _, v in ipairs(ret) do user.RemoveDequip(v.sn) end
                    end
                end
            end
            return dat
        end
    end,
    --物品熔铸
    [Func.ItemMelt] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_ItemRecycle)
            user.SyncReward(dat.rws)
            ret = dat.item
            if ret and #ret > 0 then
                if dat.opt == "dq" then
                    --军备熔铸
                    for _, v in ipairs(ret) do user.RemoveDequip(v) end
                elseif dat.opt == "ch" then
                    --武将遣散
                    for _, v in ipairs(ret) do user.RemoveHero(v) end
                end
            end
            return dat
        end
    end,
    --兑换码兑换
    [Func.UseExCode] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat)
            user.SyncReward(dat)
            return dat
        end
    end,
    --物品出售
    [Func.BanChat] = function(ret, dat) if ret == 0 then return ldec(dat) end end,
    --实名验证
    [Func.Verify] = function(ret, dat) if ret == 0 then user.age = tonumber(dat) or user.age end end,
    --快捷操作
    [Func.QuickOpt] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_Quick) end end,
    --铜雀台
    [Func.Beauty] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_Beauty)
            user.SyncBeauty(dat)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --TCG登录数据
--    [Func.TcgLogin] = function(ret, dat) end,
    --TCG匹配数据
--    [Func.TcgMatch] = function(ret, dat) end,
    --TCG操作
    [Func.TcgOpt] = function(ret, dat) if ret == 0 then return ldec(dat, stab.S_TcgOpt) end end,
    ----------------------------------跨服PVP---------------------------------
    --跨服PVP 信息，参赛，配置武将
    [Func.PeakInfo]= function(ret,dat) if ret==0 then dat= ldec(dat,stab.S_Peak) return dat end end,
    [Func.PeakJoin]= function(ret,dat) if ret==0 then dat= ldec(dat,stab.S_Peak) return dat end end,
    [Func.PeakHero]= function(ret,dat) if ret==0 then dat= ldec(dat,stab.S_Peak) return dat end end,
    --跨服PVP 排名 对手
    [Func.PeakRank]= function(ret,dat)  if ret==0 then dat= ldec(dat,stab.S_PeakPlayerInfo) return dat end end,
    [Func.PeakRival]= function(ret,dat) if ret==0 then dat= ldec(dat,stab.S_PeakPlayerInfo) return dat end end,
    --跨服PVP 对手武将
    [Func.PeakRivalHero]= function(ret,dat) if ret==0 then dat= ldec(dat,stab.S_PeakHero) return dat end end,
    --战斗
    [Func.PeakFight]= function(ret,dat) if ret==0 then dat= ldec(dat,stab.S_PeakRet) return dat  end end,
    --战报                                               
    [Func.PeakReport]= function(ret,dat) if ret==0 then dat= ldec(dat,stab.S_PeakReport) return dat  end end,
    --战报详情
    [Func.PeakReportDetail]= function(ret,dat) if ret==0 then dat= ldec(dat,stab.S_PeakReportDetail) return dat  end end,
    --跨服PVP回放
    [Func.PeakReplay]= function(ret,dat) if ret==0 then dat= ldec(dat, stab.S_BattleDataRec) return dat end end,
    --endregion

    --region ----------------------------------地宫-------------------------------------
    --地宫开始命令
    [Func.GveStart] = function(ret,dat) if ret==0 then return dat end end,
    --地宫匹配命令
    [Func.GveMatch] = function(ret,dat) if ret==0 then print("1111111111111") dat = ldec(dat, stab.S_GveTeamInfo) print("~~~~~~", type(dat)) return dat end end,
    --获取好友列表
    [Func.GveFriendList] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.PlayerList) return dat.lst end end,
    --邀请好友
    [Func.GveInvite] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_GveTeamInfo) return dat end end,
    --获取邀请信息
    [Func.GveCheckInvite] = function(ret,dat) if ret==0 then return ldec(dat, stab.S_GveInvite) end end,
    --进入地宫
    [Func.GveEnter] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_GveInfo) return dat end end,
    --地宫战报
    [Func.GveReport] = function(ret,dat) if ret==0 then dat = ldec(dat,stab.S_GveReport) return dat end end,
    --设置上阵武将
    [Func.GveSetHero] = function(ret,dat) if ret==0 then return ldec(dat, stab.S_GveInfo) end end,
    --武将移动
    [Func.GveHeroMove] = function(ret,dat) if ret==0 then return ldec(dat,stab.S_GveCityInfo) end end,
    --点击信息按钮
    [Func.GveShowInfo] = function(ret,dat) if ret==0 then return ldec(dat, stab.S_GveCityInfo) end end,
    --侦察命令
    [Func.GveCheckInfo] = function(ret,dat) if ret==0 then return ldec(dat, stab.S_GveCityInfo) end end,
    --地宫战斗准备信息
    [Func.GveBattleReady] = function(ret, dat, sfs) 
        if ret == 0 then
            local bat = QYBattle.GenBattleSiege(dat, tonumber(sfs:GetClass("ou_ver")) or 0)
            user.hp = bat.playerHP
            user.tp = bat.playerTP

            if bat.atkQty > 0 then
                if bat.isConsume then
                    local temp = nil
                    local ph = nil
                    for i = 1, bat.atkQty do
                        temp = bat:GetAtkHero(i)
                        ph = user.GetHero(temp.sn)
                        if ph then
                            ph.hp = temp.hp.value
                            ph.sp = temp.sp.value
                            ph.tp = temp.tp.value
                            ph.loyalty = temp.loyalty.value
                        end
                    end
                elseif bat.isConsumeLoyaty then
                    local temp = nil
                    local ph = nil
                    for i = 1, bat.atkQty do
                        temp = bat:GetAtkHero(i)
                        ph = user.GetHero(temp.sn)
                        if ph then  ph.loyalty = temp.dat.loyalty.value end
                    end
                end
                bat:SortAtkHero(user.expHeroRecord)
            end
            if bat.defQty > 0 then user.inBattle = true
            else bat = nil end
            user.changed = true
            return bat
        end
    end,
    --地宫战斗对战信息
    [Func.GveBattleFight] = function(ret, dat)
        if ret == 0 then
            return dat 
        end
    end,
    --地宫战斗结算
    [Func.GveBattleResult] = function(ret, dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_BattleResult)
            user.battleRet = dat
            user.inBattle = false
            user.SyncReward(dat.rws, true)
            local heros = dat.heros
            local qty = heros and #heros or 0
            local tmp = nil
            local flag = false
            if qty > 0 then
                --战胜后记录上次出战武将
                if dat.ret == 1 then
                    local ret = user.expHeroRecord 
                    local lenR = ret and #ret or 0
                    local idx = 1
                    for i = 1, qty do
                        tmp, flag = heros[i], false
                        while idx <= lenR do
                            for j = i, qty do
                                if tostring(heros[j].csn) == tostring(ret[idx]) then
                                    flag = true
                                    if i ~= j then
                                        heros[i] = heros[j]
                                        heros[j] = tmp
                                    end
                                    break
                                end
                            end
                            idx = idx + 1
                            if flag then break end
                        end
                    end
                    if dat.kind > 0 and dat.kind < 5  then
                        tmp = { }
                        for i = 1, qty do tmp[i] = tostring(heros[i].csn) end
                        user.LastBattleHero = tmp
                    end
                end
                
            end
            
            return dat
        end
    end,
    --endregion

    --region -----------------------------------征战相关----------------------------------
    --征战宝箱
    [Func.ExpeditionBox] = function(ret, dat) if ret == 0 then dat = ldec(dat, stab.S_ExpeditionBox) return dat end end,
    --endregion

    --在线奖励
    [Func.OnlineOpt] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_OnlineReward) return dat end end,

    --VIP等级礼包
    [Func.VipLvGiftStu] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_VipLvGiftStu) return dat end end,

    --查询竞技场积分奖励信息
    [Func.RenownRewardOp] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_ReciveRenownReward) return dat end end,

    --查询声望商城
    [Func.SoloRewardShop] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_SoloRenownShopInfo) return dat end end,

    --购买声望商城的东西
    [Func.SoloRewardShop] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_SoloRenownShopInfo) return dat end end,

    --获取指定玩家的驻守武将
    [Func.GetDefendHero] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_ArrayData) return dat end end,

    --获取竞技场中的排行榜
    [Func.GetSoloRank] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_SoloRankInfo) return dat end end,

    --转盘（战役）
    [Func.Turntable] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_Turntable)
            user.gold = dat.gold
            user.SetPropsQty(DB_Props.ZHUAN_PAN_BI,dat.turnCoin)
            user.changed = true
            return dat
        end
    end,

    --
    [Func.SignCumRewardInf] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_SignCumRewardInf)
            user.SyncReward()
            return dat
        end
    end,

    --过关斩将部署
    [Func.TowerDeploy] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_TowerInfo)
            RW.CollapseReward(dat.rws)
            user.SyncReward(dat.rws)
            if dat.coin then user.coin = dat.coin end
            if dat.gold then user.gold = dat.gold end
            if dat.rmb then user.rmb = dat.rmb end
            user.changed = true
            user.towerInfo = dat
        end
    end,

    [Func.GveRank] = function(ret,dat) if ret==0 then dat = ldec(dat, stab.S_PalaceRank) return dat end end,

    --国库
    [Func.CountryShop] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_CountryShop)
            user.nat.lv=dat.lv
            user.gold=dat.gold
            user.coin=dat.coin
            user.rmb=dat.rmb
            user.token=dat.token
            user.changed=true
            return dat
        end
    end,

    --国库购买
    [Func.CountryBuyGoods] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_CountryBuyGoods)
            user.SyncReward(dat.rws)
            user.gold=dat.gold
            user.coin=dat.coin
            user.rmb=dat.rmb
            user.token=dat.token
            user.changed=true
            return dat
        end
    end,

    --天降秘宝
    [Func.Treasure] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_Treasure)
            user.SyncReward(dat.rws)
            return dat
        end
    end,

    --排名奖励操作（查询，领取）
    [Func.RankRewardOp] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_ReciveRankReward)
            user.SyncReward(dat.rws)
            return dat
        end
    end,

    --帝国个人科技
    [Func.TechPersonal] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_TechP)
            UpdateEmpireTech(dat)
            return dat
        end
    end,

    --城池一键开发
    [Func.CityOneUpgrade] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_CityOneUpgrade)
            user.coin = dat.coin
            user.SyncPveCityTer(dat.players)
            user.changed=true
            return dat
        end
    end,

    --七日目标
    [Func.TargetSeven] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_TargetSeven)
            user.SyncReward(dat.rws)
            return dat
        end
    end,
    --补充体力
    [Func.AddVIT] = function(ret,dat)
        if ret==0 then
            dat = ldec(dat, stab.S_AddVIT)
            user.vit = dat.vit
            user.vitCount = dat.buyQty
            user.vitTotal = dat.vitTotal
            user.rmb = dat.diamond
            user.vitPrice = dat.price
            return dat
        end
    end,
    --增加酒值
    [Func.AddWine] = function(ret,dat)
        if ret == 0 then
            dat = ldec(dat, stab.S_AddWine)
            user.nat.wine = dat.wine
            user.gold = dat.gold
            user.changed = true
            return dat
        end
    end,
}

--魂店的商品操作
_ext[Func.SoulShopOption] = _ext[Func.RmbShopOption]
--国战商城的商品操作
_ext[Func.NatShopOption] = _ext[Func.RmbShopOption]
--SDK实名验证
_ext[Func.VerifySDK] = _ext[Func.Verify]

return _ext