local _fmt = string.format
local _tstr = tostring
local _join = string.join
local _cla = math.clamp

local _fc = Func
local _svr = SVR.getSfsSvr()
local _send = _svr.Function

--[Comment]
--发送聊天信息，返回请侦听[OnNewChat]广播
--trg : 目标SN
--chn : 聊天频道
--style : 聊天方式
--txt : 消息内容
--ext : 扩展数据
function SVR.SendChat(trg, chn, style, txt, ext)
    local dat = SFSObject()
    dat:PutLong("tg", int64.new(trg or 0))
    dat:PutInt("ch", chn or 0)
    dat:PutInt("st", style or 0)
    dat:PutUtfString("txt", txt or "")
    if ext then dat:PutUtfString("ext", ext) end
    if chn == ChatChn.World or chn == ChatChn.Nat then
        user.chatTm.time = CONFIG.CHAT_WORLD_CD
    end
    if ChatStyle.IsShare(style) then
        user.shareTm.time = DB.param.cdShare
    end
    _svr:Send(_fc.Chat, dat, nil)
--    user.chatQty = user.chatQty + 1
--    if user.chatQty >= 10 then
--        user.chatQty = 0
--        SVR.GetColdTime()
--    end
end

--[Comment]
--更新用户信息
function SVR.UpdateUserInfo(f) _send(_svr, _fc.UpdateUserInfo, _fmt("%s,'%s'", user.psn, user.nick), f) end

--[Comment]
--更改用户信息
--opt 操作码(nm|新名称:改名,ava|头像编号:改头像,ht|称号编号:改称号)
function SVR.ChangeUserInfo(opt, f) _send(_svr, _fc.ChangeUserInfo, _fmt("%s,'%s'", user.psn, opt), f) end

--------------------------------------同步数据相关--------------------------------------
--[Comment]
--同步武将数据
function SVR.SyncHeroData(f) _send(_svr, _fc.SyncHero, _fmt("%s,0", user.psn), f) end
--[Comment]
--同步装备数据
function SVR.SyncEquipData(f) _send(_svr, _fc.SyncEquip, _fmt("%s,0", user.psn), f) end
--[Comment]
--同步装备数据
function SVR.SyncPropsData(f) _send(_svr, _fc.SyncProps, _fmt("%s", user.psn), f) end
--[Comment]
--同步武将将魂
function SVR.SyncHeroSoul(f) _send(_svr, _fc.SyncHeroSoul, user.psn, f) end
--[Comment]
--同步宝石
function SVR.SyncGem(f) _send(_svr, _fc.SyncGem, user.psn, f) end
--[Comment]
--同步副将
function SVR.SyncDehero(f) _send(_svr, _fc.SyncDeHero, user.psn, f) end
--[Comment]
--同步军备
function SVR.SyncDequip(f) _send(_svr, _fc.SyncDequip, user.psn, f) end

--[Comment]
--同步具体项
function SVR.SyncItem(kind,sn,f) _send(_svr, _fc.SyncItem, _fmt("%s,%s,'%s'",user.psn,kind, _join(",",sn)), f) end

--[Comment]
--同步军备残片
function SVR.SyncDequipSp(f) _send(_svr, _fc.SyncDequipSp, user.psn, f) end
--[Comment]
--同步价值物品列表
--opt 操作(ava:头像列表，ht:称号列表)
function SVR.SyncValue(opt, f) _send(_svr, _fc.SyncValue, _fmt("%s,'%s'", user.psn, opt), f) end

--------------------------------------城池相关--------------------------------------
--[Comment]
--主城升级
function SVR.HomeUpgrade(f) _send(_svr, _fc.HomeUpgrade, user.psn, f) end
--[Comment]
--城池升级
--city 城池编号
function SVR.CityUpgrade(city, f) _send(_svr, _fc.CityUpgrade, _fmt("%s,%s", user.psn, city), f) end
--[Comment]
--收获城池
--city 城池编号
function SVR.CitySearch(city, f) _send(_svr, _fc.SearchCity, _fmt("%s,%s", user.psn, city), f) end
--[Comment]
--一键收获指定关卡所有城池
--lv 关卡
function SVR.CitySearchBatch(lv, f) _send(_svr, _fc.SearchCityBatch, _fmt("%s,%s", user.psn, lv), f) end

--------------------------------------医馆及兵力--------------------------------------
--[Comment]
--医馆补血
function SVR.HospitalAddBlood(f) _send(_svr, _fc.HospitalAddHP, user.psn, f) end
--[Comment]
--医馆治疗武将
--heros 武将列表
function SVR.CureHero(heros, f) _send(_svr, _fc.CureHero, _fmt("%s,'%s'", user.psn, _join(",", heros)), f) end
--[Comment]
--补满兵
function SVR.AddSoldier(f) _send(_svr, _fc.AddSoldier, user.psn, f) end
--[Comment]
--调整兵力
--csn 武将CSN
--tp 设置的兵力
function SVR.HeroSolder(csn, tp, f) _send(_svr, _fc.HeroSolder, _fmt("%s,%s,%s", user.psn, csn, tp), f) end

--------------------------------------装备相关--------------------------------------
--[Comment]
--装备操作
--esn 装备编号
--opt 操作码(cl|锁定位置:淬炼，clr|祭品装备SN:提炼)
function SVR.EquipOpt(esn, opt, f) _send(_svr, _fc.Equip, _fmt("%s,%s,'%s'", user.psn, esn, opt), f) end
--[Comment]
--装备操作
--opt 操作码（sell|装备编号:出售，up|装备编号|武将编号:装备，down|装备位置|武将编号:卸下，hh|装备编号:幻化，slot|装备编号:打孔
--esn 装备编号，卸下时为位置(1=武器，2=护甲，3=坐骑，4=兵书)
--csn (武将编号,不需要填0)|(宝石编号，卸下填0)
function SVR.EquipOption(opt, esn, csn, f) _send(_svr, _fc.EquipOption, _fmt("%s,'%s|%s|%s'", user.psn, opt, esn, csn or ""), f) end
--[Comment]
--装备镶嵌和卸下宝石
--esn 装备编号
--gem 宝石编号
--pos 镶嵌位置
function SVR.EquipGem(esn, gem, pos, f) _send(_svr, _fc.EquipOption, _fmt("%s,'gem|%s|%s|%s'", user.psn, esn, gem, pos), f) end
--[Comment]
--装备强化
--esn 装备编号
--props 0=不使用道具，其它=使用道具
--gold 是否使用金币强化
function SVR.EquipUpgrade(esn, props, gold, f) _send(_svr, _fc.EquipUpgrade, _fmt("%s,%s,%s", user.psn, esn, props and props > 0 and(gold and 3 or 1) or(gold and 2 or 0)), f) end
--[Comment]
--装备一键强化
--esn 装备编号
--props 0=不使用道具，其它=使用道具
--gold 是否使用金币强化
function SVR.EquipUpOnekey(esn, props, gold, f) _send(_svr, _fc.EquipUpOnekey, _fmt("%s,%s,%s", user.psn, esn, props and props > 0 and(gold and 3 or 1) or(gold and 2 or 0)), f) end
--[Comment]
--装备进阶
--mesn 主装备编号
--sesn 祭品装备编号
--me 材料装备编号列表
--mp 材料道具编号列表
function SVR.EquipEvo(mesn, sesn, me, mp, f) _send(_svr, _fc.EquipEvo, _fmt("%s,%s,'1|%s|%s|%s'", user.psn, mesn, sesn, _join(",", me), _join(",", mp)), f) end
--[Comment]
--装备锻造
--mesn 主装备编号
--sesn 祭品装备编号
function SVR.EquipExclForge(mesn, sesn, f) _send(_svr, _fc.EquipExclForge, _fmt("%s,%s,'up|%s'", user.psn, mesn, sesn), f) end
--[Comment]
--一键出售装备
--rlst 稀有度列表
function SVR.EquipSellBatch(rlst, f) _send(_svr, _fc.EquipSellBatch, _fmt("%s,'%s'", user.psn, rlst), f) end
--[Comment]
--碎片操作
--opt 出售:sell|dbsn|qty，合成:make|dbsn
function SVR.EquipPieceOption(opt, f) _send(_svr, _fc.EquipPiece, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--一键出售装备碎片
--rlst 稀有度列表
function SVR.PieceSellBatch(rlst, f) _send(_svr, _fc.PieceSellBatch, _fmt("%s,'%s'", user.psn, rlst), f) end

--------------------------------------技能、兵种、阵形相关--------------------------------------
--[Comment]
--升级/学习锦囊技
--csn 武将SN
--skp 锦囊技SN
function SVR.LearnUpSkp(csn, skp, f) _send(_svr, _fc.SkpOption, _fmt("%s,%s,'up|%s'", user.psn, csn, skp), f) end
--[Comment]
--设置选择锦囊技
--csn 武将SN
--skp 锦囊技SN
function SVR.SetSkp(csn, skp, f) _send(_svr, _fc.SkpOption, _fmt("%s,%s,'set|%s'", user.psn, csn, skp), f) end
--[Comment]
--学习武将技能
--csn 武将编号
--kind 技能类型(1:武将技 2:军师技)
function SVR.LearnSkill(csn, kind, f) _send(_svr, _fc.LearnSkill, _fmt("%s,%s,%s", user.psn, csn, kind), f) end
--[Comment]
--武将技能五行操作
--csn 武将SN
--skc 武将技SN
--opt 操作(选择:[sl|fesn], 升级:[up|fesn|qty],信息:[inf])
function SVR.SkcFeOpt(csn, skc, opt, f) _send(_svr, _fc.SkcFeOpt, _fmt("%s,%s,%s,'%s'", user.psn, csn, skc, opt), f) end
--[Comment]
--学习兵种
--csn 武将编号
--arm 兵种编号
function SVR.LearnArm(csn, arm, f) _send(_svr, _fc.SoldierOption, _fmt("%s,%s,'buy|%s'", user.psn, csn, arm), f) end
--[Comment]
--使用兵种
--csn 武将编号
--arm 兵种编号
function SVR.UseArm(csn, arm, f) _send(_svr, _fc.SoldierOption, _fmt("%s,%s,'use|%s'", user.psn, csn, arm), f) end
--[Comment]
--重置武将的兵种
--csn 武将编号
function SVR.ResetArm(csn, f) _send(_svr, _fc.SoldierOption, _fmt("%s,%s,'set'", user.psn, csn), f) end
--[Comment]
--升级兵种
--csn 武将编号
--arm 兵种编号
function SVR.UpArm(csn, arm, f) _send(_svr, _fc.SoldierOption, _fmt("%s,%s,'upg|%s'", user.psn, csn, arm), f) end
--[Comment]
--学习阵形
--csn 武将编号
--lnp 阵形编号
function SVR.LearnLnp(csn, lnp, f) _send(_svr, _fc.LearnLineup, _fmt("%s,%s,'buy|%s'", user.psn, csn, lnp), f) end
--[Comment]
--使用阵形
--csn 武将编号
--lnp 阵形编号
function SVR.UseLineup(csn, lnp, f) _send(_svr, _fc.LearnLineup, _fmt("%s,%s,'use|%s'", user.psn, csn, lnp), f) end
--[Comment]
--重置武将的阵形
--csn 武将编号
function SVR.ResetLineup(csn, f) _send(_svr, _fc.LearnLineup, _fmt("%s,%s,'set'", user.psn, csn), f) end
--[Comment]
--阵形铭刻操作
--csn 武将编号
--idx 阵形编号
--opt (信息:inf, 铭刻:upg, 重置:set|锁定的条目索引号序列[1,2,3])
function SVR.ImpLnp(csn, idx, opt, f) _send(_svr, _fc.LineupImprint, _fmt("%s,%s,%s,'%s'", user.psn, csn, idx, opt), f) end
    
--------------------------------------武将培养--------------------------------------
--[Comment]
--武将觉醒
--csn 武将SN
function SVR.HeroEvolution(csn, f) _send(_svr, _fc.HeroEvolution, _fmt("%s,%s,'1'", user.psn, csn), f) end
--[Comment]
--武将升级将星
--csn 武将SN
--rate 消耗倍率
function SVR.HeroUpStar(csn, rate, f) _send(_svr, _fc.HeroUpStar, _fmt("%s,%s,'up|%s'", user.psn, csn, rate), f) end
--[Comment]
--修炼武将
--heros 武将列表
--gold 是否是金币修炼
function SVR.TrainHeroBegin(heros, gold, f) _send(_svr, _fc.Train, _fmt("%s,'begin|%s|%s'", user.psn, _join(",", heros), gold and 2 or 1), f) end
--[Comment]
--修炼结束
function SVR.TrainDone(f) _send(_svr, _fc.Train, _fmt("%s,'end'", user.psn), f) end
--[Comment]
--获取武将修炼信息
function SVR.CultiveInfo(f) _send(_svr, _fc.Cultive, _fmt("%s,0,'info'", user.psn), f) end
--[Comment]
--武将修炼开始
--csn 修炼武将的SN
--kind 修炼的类型(1=武 2=智 3=统 4=血)
function SVR.CultiveBegin(csn, kind, f) _send(_svr, _fc.Cultive, _fmt("%s,%s,'prac|%s'", user.psn, csn, kind), f) end
--[Comment]
--武将修炼翻牌
--csn 修炼武将的SN
--idx 翻牌索引(1-9)
function SVR.CultiveTurn(csn, idx, f) _send(_svr, _fc.Cultive, _fmt("%s,%s,'turn|%s'", user.psn, csn, idx), f) end
--[Comment]
--武将修炼心魔操作
--csn 修炼武将的SN
--opt 心魔操作(1=抵挡，2=结束)
function SVR.CultiveDevil(csn, opt, f) _send(_svr, _fc.Cultive, _fmt("%s,%s,'devi|%s'", user.psn, csn, opt), f) end
    
--[Comment]
--武将一键升级
--csn 修炼武将的SN
--opt 1：升一级  5：升五级
function SVR.OneKeyLevelUp(csn, opt, f) _send(_svr, _fc.OneKeyLevelUp, _fmt("%s,%s,'%s'", user.psn, csn, opt), f) end
    

--------------------------------------副将相关--------------------------------------
--[Comment]
--副将操作
--dcsn 副将SN
--opt 操作码(up|武将编号:任命，down:卸任，lv:升级，star:升星，skill|技能索引(1,2,3):升级技能，resk:重置技能)
function SVR.DeheroOption(dcsn, opt, f) _send(_svr, _fc.DeheroOpt, _fmt("%s,%s,'%s'", user.psn, dcsn, opt), f) end
    
--------------------------------------军备相关--------------------------------------
--[Comment]
--军备操作
--desn 军备SN
--opt 操作码(up|副将编号:装备，down:卸下，lv:升级，xl|类型(1=至尊 else=普通):洗练，sell:出售，melt:熔炼)
function SVR.DequipOption(desn, opt, f) _send(_svr, _fc.DequipOpt, _fmt("%s,%s,'%s'", user.psn, desn, opt), f) end
--[Comment]
--军备残片操作
--opt 操作码(up|DequipSpData.GetSnFromDbAndRare(军备碎片编号,品质)|要合成的数量:合成)
function SVR.DequipSpOption(opt, f) _send(_svr, _fc.DequipSp, _fmt("%s,'%s'", user.psn, opt), f) end

--------------------------------------任务相关--------------------------------------
--[Comment]
--获取任务列表
function SVR.GetQuestList(f) _send(_svr, _fc.QuestList, _fmt("%s,0", user.psn), f) end
--[Comment]
--获取限时任务列表
function SVR.GetTimeQuestList(f) _send(_svr, _fc.QuestList, _fmt("%s,2", user.psn), f) end
--[Comment]
--完成任务
--qsn 任务SN
function SVR.CompleteQuest(qsn, f) _send(_svr, _fc.QuestCompleted, _fmt("%s,%s", user.psn, qsn), f) end
--[Comment]
--完成支线任务
--qsn 任务SN
function SVR.SideQuest(qsn, f) _send(_svr, _fc.QuestSide, _fmt("%s,%s", user.psn, qsn), f) end

--------------------------------------战斗相关--------------------------------------
--[Comment]
--请求攻城战 敌城编号 是否补血 是否补兵 武将列表
--city 攻打城
--heros 出战武将
function SVR.SiegeReady(city, heros, f)
    user.expHeroRecord = heros
    _send(_svr, _fc.BattleReady, _fmt("%s,'siege|%s',%s,%s,'%s'", user.psn, city, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f)
end
--[Comment]
--请求战役 战役编号 是否补血 是否补兵 武将列表
--sn 战役唯一编号
--heros 出战武将
function SVR.WarReady(sn, heros, f)
    user.expHeroRecord = heros
    _send(_svr, _fc.BattleReady, _fmt("%s,'battle|%s',%s,%s,'%s'", user.psn, sn, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f)
end
--[Comment]
--PVP攻城战
--city 攻打城
--heros 出战武将
function SVR.PvpReady(city, heros, f)
    user.expHeroRecord = heros
    _send(_svr, _fc.BattleReady, _fmt("%s,'pvp|%s|%s',%s,%s,'%s'", user.psn, city, user.rsn, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f)
end
--[Comment]
--副本攻城
--city 攻打城
--dif 难度 1-3
--heros 出战武将
function SVR.HistoryReady(city, dif, heros, f)
    user.expHeroRecord = heros
    _send(_svr, _fc.BattleReady, _fmt("%s,'fb|%s|%s',%s,%s,'%s'", user.psn, city, _cla(dif, 1, 3), user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f)
end
--[Comment]
--演武榜
--psn 玩家编号
--heros 出战武将
function SVR.RankReady(psn, heros, f)
    user.expHeroRecord = heros
    _send(_svr, _fc.BattleReady, _fmt("%s,'rank|%s',%s,%s,'%s'", user.psn, psn, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f)
end
--[Comment]
--BOSS战
--heros 出战武将
function SVR.BoosReady(heros, f) 
    user.expHeroRecord = heros
    _send(_svr, _fc.BattleReady, _fmt("%s,'boss',%s,%s,'%s'", user.psn, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f) 
end
--[Comment]
--二代BOSS战
function SVR.Boos2Ready(heros, f) _send(_svr, _fc.BattleReady, _fmt("%s,'boss2',%s,%s,'%s'", user.psn, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, user.Join(",", heros)), f) end
--[Comment]
--过关斩将
--sn 关卡编号
--dif 难度 1-3
--heros 出战武将
function SVR.TowerReady(sn, dif, heros, f)
    user.expHeroRecord = heros
    _send(_svr, _fc.BattleReady, _fmt("%s,'ta|%s|%s',%s,%s,'%s'", user.psn, sn, dif, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f)
end
--[Comment]
--乱世争雄
--sn 关卡编号
--heros 出战武将
function SVR.ClanWarReady(sn, heros, f)
    user.expHeroRecord = heros
    _send(_svr, _fc.BattleReady, _fmt("%s,'lszx|%s',%s,%s,'%s'", user.psn, sn, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f)
end
--[Comment]
--极限挑战
--sn 关卡编号
function SVR.HeroChallengeReady(sn, f) _send(_svr, _fc.BattleReady, _fmt("%s,'jxtz|%s',%s,%s,'%s'", user.psn, sn, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, ""), f) end
--[Comment]
--矿脉战
--sn 矿脉编号
--heros 出战武将
function SVR.MineReady(sn, heros, f) _send(_svr, _fc.BattleReady, _fmt("%s,'mine|%s',%s,%s,'%s'", user.psn, sn, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f) end
--[Comment]
--幻境挑战
--heros 出战武将
function SVR.FantsyReady(heros, f) _send(_svr, _fc.BattleReady, _fmt("%s,'hjtz',%s,%s,'%s'", user.psn, user.AutoAddHP and 1 or 0, user.AutoAddTP and 1 or 0, _join(",", heros)), f) end
--[Comment]
--攻城战对战
--csn 我方武将SN
--idx 敌将索引,PVP为DBSN
--kind 战场类型信息
function SVR.BattleFight(csn, idx, kind, f) _send(_svr, _fc.BattleFight, _fmt("%s,%s,'%s',%s", user.psn, csn, kind, idx), f) end
--[Comment]
--战斗结果
--ret 结果0=我方输 1=我方胜
--battle 战斗数据
function SVR.BattleResult(ret, battle, f)
    if battle == nil then return end
    local oh = battle:atkHeroResult()
    local eh = battle:defHeroResult()
    local check = CS.MD5(_fmt("%s%s%d%d%d%s%s", user.psn, battle:addtionInfo(), battle.sn, ret, battle.cheat, oh, eh))
    check = string.sub(check, 8, 10)..string.sub(check, 18, 21)..string.sub(check, 30, 30) -- 第8位取3个,第18位取4个,第30位取1个
    local d = _fmt("%s,'%s','%s',%d,%d,'%s','%s','%s'", user.psn, battle:typeSend(), battle:addtionInfo(), ret, battle.cheat, oh, eh, check)
    _send(_svr, _fc.BattleResult, d, f)
end
--[Comment]
--设置军师技
--csn 武将编号
--idx 军师技索引
function SVR.SetSkillT(csn, idx, f) _send(_svr, _fc.SetSkillT, _fmt("%s,%s,%s", user.psn, csn, idx), f) end
--[Comment]
--招降武将
--city 俘虏所在城池操作码
--opt (招降:conv|dbsn 斩杀:kill|dbsn 流放:free|dbsn)
--dbsn 武将DBSN
function SVR.SiegeCaptive(city, opt, dbsn, f) _send(_svr, _fc.SiegeCaptive, _fmt("%s,%s,'%s|%s'", user.psn, city, opt, dbsn), f) end
--[Comment]
--获取主线关卡记录
--gmlv 主线关卡编号 0表示最高关卡
function SVR.GetLevelMap(gmlv, f) _send(_svr, _fc.GetLevelMap, _fmt("%s,%s", user.psn, gmlv), f) end
--[Comment]
--获取所有城池的副本次数
function SVR.GetLevelFB(f) _send(_svr, _fc.GetLevelFB, user.psn, f) end
--[Comment]
--移动武将到城池
--heros 要移动的武将
--city 目标城池
--opt 1=移动 2=替换
function SVR.MoveHero(heros, city, opt, f) _send(_svr, _fc.MoveHero, _fmt("%s,%s,%s,'%s'", user.psn, city, opt, _join(",", heros)), f) end
--[Comment]
--获取战役信息
function SVR.GetWarInfo(opt,f) _send(_svr, _fc.GetWar, _fmt("%s,'%s'",user.psn,opt), f) end
--[Comment]
--刷新战役挑战次数
function SVR.RefreshWar(f) _send(_svr, _fc.RefreshWar, _fmt("%s,'reset'", user.psn), f) end
--[Comment]
--领取战役奖励
--wsn 战役编号
function SVR.GetWarReward(wsn, f) _send(_svr, _fc.GetWarReward, _fmt("%s,%s", user.psn, wsn), f) end
--[Comment]
--获取乱世争雄信息
--(inf:取信息 buy|sn[类型号1~5]:买次数)
function SVR.GetClanWarInfo(f) _send(_svr, _fc.ClanWar, _fmt("%s,'inf'", user.psn), f) end

--------------------------------------酒馆相关--------------------------------------
--[Comment]
--获取酒馆信息
function SVR.GetTavernInfo(f) _send(_svr, _fc.TavernInfo, user.psn, f) end
--[Comment]
--刷新酒馆信息
function SVR.RefreshTavern(f) _send(_svr, _fc.ReTavern, user.psn, f) end
--[Comment]
--酒馆操作
--idx 武将索引[1-3]
--opt 招募:recr, 金币喝酒:drinkg, 银币喝酒:drinkc
function SVR.TavernOption(idx, opt, f) _send(_svr, _fc.TavernOption, _fmt("%s,'%s|%s'", user.psn, opt, idx), f) end
--[Comment]
--酒馆
--opt 购买："buy"  喝酒："luk"  刷新："ref"  信息："inf"
function SVR.Tavern(opt, f) _send(_svr, _fc.Tavern, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--10连抽
--kind 0=免费 1=金币 2=积分 3=副将
--ten 是否十连
function SVR.GetReward10(kind, ten, f) _send(_svr, _fc.GetReward10, _fmt("%s,'%s|%s'", user.psn, kind == 0 and "free" or kind == 2 and "rmb" or kind == 3 and "dc" or "gold", ten and 10 or 1), f) end
--[Comment]
--副将十连抽
--ten 是否十连
--free 是否免费
function SVR.GetRewardLieu(ten, free, f) _send(_svr, _fc.GetReward10, _fmt("%s,'dc|%s'", user.psn, ten and "10" or free and "1|1" or "1"), f) end

--------------------------------------商城相关--------------------------------------
--[Comment]
--购买商城道具
--sn 商品编号
--qty 购买数量
--kind 货币类型(gold coin rmb)
function SVR.BuyGoods(sn, qty, kind, f) _send(_svr, _fc.BuyGoods, _fmt("%s,%d,%d,'%s'", user.psn, sn, qty, kind or "gold"), f) end
--[Comment]
--使用道具
--sn 道具编号
--qty 使用数量
--csn 目标武将编号
function SVR.UseProps(sn, qty, csn, f) _send(_svr, _fc.UseProps, _fmt("%s,%s,%s,'%s'", user.psn, sn, qty, csn and "csn|" .. csn or ""), f) end
--[Comment]
--使用道具 副将
--sn 道具编号
--qty 使用数量
--dcsn 目标副将编号
function SVR.UsePropsForDehero(sn, qty, dcsn, f) _send(_svr, _fc.UseProps, _fmt("%s,%s,%s,'%s'", user.psn, sn, qty, dcsn and "dcsn|" .. dcsn or ""), f) end
--[Comment]
--使用道具 赠送
--sn 道具SN
--psn 赠送对象SN
--qty 赠送数量
--msg 赠送留言
function SVR.UsePropsForPsn(sn, psn, qty, msg, f) _send(_svr, _fc.UseProps, _fmt("%s,%s,%s,'psn|%s|%s'", user.psn, sn, qty, psn, msg and DB.HX_Filter(msg) or ""), f) end
--[Comment]
--使用道具 赠送
--sn 道具SN
--pnm 赠送对象昵称
--qty 赠送数量
--msg 赠送留言
function SVR.UsePropsForPnm(sn, pnm, qty, msg, f) _send(_svr, _fc.UseProps, _fmt("%s,%s,%s,'pnm|%s|%s'", user.psn, sn, qty, pnm, msg and DB.HX_Filter(msg) or ""), f) end
--[Comment]
--使用PVP道具
--sn 道具SN
--qty 使用数量
--lsn 城池SN
--msg 文本
function SVR.UsePropsForPvp(sn, qty, lsn, msg, f) _send(_svr, _fc.UseProps, _fmt("%s,%s,%s,'lsn|%s|%s'", user.psn, sn, qty, lsn, msg and DB.HX_Filter(msg) or ""), f) end
--[Comment]
--使用国战道具
--sn 道具SN
--city 城池SN
--csn 武将编号
function SVR.UsePropsForNat(sn, city, csn, f) _send(_svr, _fc.UseProps, _fmt("%s,%s,%s,'nat|%s|%s'", user.psn, sn, 1, city, csn), f) end
--[Comment]
--使用跨服国战道具
--citySN 城池SN
--heroSN 武将编号
function SVR.UsePropsForSnat(sn, city, csn, f) _send(_svr, _fc.UseProps, _fmt("%s,%s,%s,'snat|%s|%s'", user.psn, sn, 1, city, csn), f) end
--[Comment]
--金换银
function SVR.G2C(f) _send(_svr, _fc.G2C, user.psn, f) end
--[Comment]
--获取珍宝阁信息
function SVR.GetRmbShopInfo(f) _send(_svr, _fc.RmbShopOption, _fmt("%s,'inf'", user.psn), f) end
--[Comment]
--刷新珍宝阁
function SVR.RmbShopRefresh(f) _send(_svr, _fc.RmbShopOption, _fmt("%s,'ref'", user.psn), f) end
--[Comment]
--购买珍宝阁商品
--sn 商品SN
function SVR.RmbShopBuy(sn, f) _send(_svr, _fc.RmbShopOption, _fmt("%s,'buy|%s'", user.psn, sn), f) end
--[Comment]
--获取魂店信息
function SVR.GetSoulShopInfo(f) _send(_svr, _fc.SoulShopOption, _fmt("%s,'inf'", user.psn), f) end
--[Comment]
--刷新魂店
function SVR.SoulShopRefresh(f) _send(_svr, _fc.SoulShopOption, _fmt("%s,'ref'", user.psn), f) end
--[Comment]
--购买魂店商品
--sn 商品SN
function SVR.SoulShopBuy(sn, f) _send(_svr, _fc.SoulShopOption, _fmt("%s,'buy|%s'", user.psn, sn), f) end
--[Comment]
--幻境商店操作
--opt inf:信息 ref:刷新 buf|sn:购买指定编号的商品
function SVR.FantsyShop(opt, f) _send(_svr, _fc.FantsyShopOption, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--巅峰商城操作
function SVR.PeakShop(opt, f) _send(_svr, _fc.PeakShopOption, _fmt("%s,'%s'",user.psn,opt),f) end
--[Comment]
--出售将魂
--dbsn 武将DBSN
--qty 出售数量
function SVR.HeroSellSoul(dbsn, qty, f) _send(_svr, _fc.SoulOption, _fmt("%s,'soul|%s|%s'", user.psn, dbsn, qty), f) end
--[Comment]
--获取国战商城信息
function SVR.GetNatShopInfo(f) _send(_svr, _fc.NatShopOption, _fmt("%s,'inf'", user.psn), f) end
--[Comment]
--刷新国战商城
function SVR.NatShopRefresh(f) _send(_svr, _fc.NatShopOption, _fmt("%s,'ref'", user.psn), f) end
--[Comment]
--购买国战商城商品
--sn 商品SN
function SVR.NatShopBuy(sn, f) _send(_svr, _fc.NatShopOption, _fmt("%s,'buy|%s'", user.psn, sn), f) end
----------------------------------意见反馈-----------------------------------------
--[Comment]
--意见反馈 kind:反馈类型  content:反馈内容
function SVR.SuggestOpt(kind, content, f) _send(_svr, _fc.SuggestOpt, _fmt("%s,%s,'%s','%s',%s,'%s'", user.psn, kind, content, user.nick, user.hlv, user.rsn), f) end
----------------------------------------------------------------------------------

--------------------------------------社交相关--------------------------------------
--[Comment]
--玩家消息操作
--opt 操作([bro：广播],[ssn|发送对象编号],[snm|发送对象名称|服务器编号], [del|消息编号], [lst|起始消息编号：消息列表5个], [see|消息编号]，[att|消息SN])
--msg 消息内容,(当opt为lst/del时，,[bro：广播],[pri: 私有])
function SVR.PlayerMessage(opt, msg, f) _send(_svr, _fc.PlayerMsg, _fmt("%s,'%s','%s'", user.psn, opt, msg), f) end
--[Comment]
--获取邮件的附件
--sn 邮件编号
function SVR.GetMsgAtt(sn, f) _send(_svr, _fc.GetMsgAtt, _fmt("%s,%s", user.psn, sn), f) end
--[Comment]
--一键提取附件
--sn 邮件编号传0
function SVR.GetMsgAtt1K(sn, f) _send(_svr, _fc.GetMsgAtt, _fmt("%s,%s", user.psn, sn), f) end
--[Comment]
--好友操作，编号名称二选一
--psn 好友编号
--pnm 好友名称
--opt 操作(add, del, foe|del)
function SVR.FriendOption(psn, pnm, opt, f) _send(_svr, _fc.FriendOption, _fmt("%s,%s,'%s','%s'", user.psn, psn, pnm, opt), f) end
--[Comment]
--地宫积分周排名
function SVR.GveExplorerRank(f) _send(_svr, _fc.GveRank, _fmt("%s", user.psn), f) end
--[Comment]
--获取玩家列表
--opt 操作符(money:财富榜 score:实力榜 char:武将榜 fan:好友 foe:仇人)
--page 页码(1=开始)
function SVR.PlayerList(opt, page, f) _send(_svr, _fc.PlayerList, _fmt("%s,'%s|%s'", user.psn, opt, page), f) end
--[Comment]
--获取演武榜数据 
function SVR.GetPvpRankRival(f) _send(_svr, _fc.PvpRankRival, user.psn, f) end
--[Comment]
--获取排行榜武将
function SVR.GetPvpRankHero(f) _send(_svr, _fc.RankOption, _fmt("%s,'inf'", user.psn), f) end
--[Comment]
--配置演武榜武将
--hreos 武将列表
function SVR.SetRankHero(heros, f) _send(_svr, _fc.RankOption, _fmt("%s,'set|%s'", user.psn, _join(",", heros)), f) end
--[Comment]
--通过玩家SN获取玩家信息
--psn 玩家SN
function SVR.GetPlayerInfo(psn, f) _send(_svr, _fc.GetPlayerInfo, _fmt("%s,'sn|%s'", user.psn, psn), f) end
--[Comment]
--通过玩家名称获取玩家信息
--pnm 玩家名称
function SVR.GetPlayerInfo(pnm, f) _send(_svr, _fc.GetPlayerInfo, _fmt("%s,'nm|%s'", user.psn, pnm), f) end
--[Comment]
--通用排行信息
--kind 排行类别 0:演武榜 1:国战击杀榜 2:国战战斗榜 3:夺旗-国家 4:夺旗-联盟
function SVR.GetRankInfo(kind, f) _send(_svr, _fc.GetRankInfo, _fmt("%s,%s", user.psn, kind), f) end
--[Comment]
--PVP地图
--获取PVP区域信息
--zone 区号
function SVR.GetPvpZone(zone) _send(_svr, _fc.GetPvpZone, _fmt("%s,%s", user.psn, zone)) end
--[Comment]
--获取PVP城池信息
--lsn 城池编号
--psn 城池拥有者的玩家编号(主城才有这个编号,不是主城就发0)
function SVR.GetPvpCityInfo(lsn, psn, f) _send(_svr, _fc.PvpCityInfo, _fmt("%s,%s,%s", user.psn, lsn, psn or 0), f) end
---<summary>领取竞技场积分奖励</summary>
function SVR.ReciveRenownReward(sn,f) _send(_svr, _fc.RenownRewardOp, _fmt("%s,'rw|%d'", user.psn, sn), f) end
--[Comment]
--获取征收信息
function SVR.GetCropInfo(f) _send(_svr, _fc.GetCropInfo, user.psn, f) end
--[Comment]
--征收操作
function SVR.GetCrop(f) _send(_svr, _fc.GetCrop, user.psn, f) end
--[Comment]
--获取玩家占领城池列表
--opt 操作符(my:占领的城池包括资源 pvp:占领的玩家城池 pve|lsn:占领的PVE城池)
function SVR.GetTerritoryList(opt, f) _send(_svr, _fc.GetTerritoryList, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--副本扫荡
--city 城池编号
function SVR.FBSD(city, opt, dif, f) _send(_svr, _fc.SDFB, _fmt("%s,%s,%s,%s", user.psn, city, opt, dif), f) end
--[Comment]
--联盟相关
--创建联盟
--gnm 联盟名称
--banner 联盟旗号
--flag 联盟旗帜样式
--i 联盟简介
function SVR.CreatAlly(gnm, banner, flag, i, f) _send(_svr, _fc.AllyCreat, _fmt("%s,'%s','%s',%s,'%s'", user.psn, gnm, banner, flag, i), f) end
--[Comment]
--获取联盟列表
--page 页码(每页10条信息)
function SVR.GetAllyList(page, f) _send(_svr, _fc.AllyList, _fmt("%s,%s", user.psn, page), f) end
--[Comment]
--获取联盟细信息
--gsn 联盟编号 自己填0
function SVR.GetAllyInfo(gsn, f) _send(_svr, _fc.AllyInfo, _fmt("%s,'sn|%s'", user.psn, gsn or 0), f) end
--[Comment]
--获取联盟详细信息
--gnm 联盟名称
function SVR.GetAllyInfoByName(gnm, f) _send(_svr, _fc.AllyInfo, _fmt("%s,'nm|%s'", user.psn, gnm), f) end
--[Comment]
--获取联盟成员列表
--opt usr:联盟成员 req:请求加入的成员
--page 页码(每页10条信息)
function SVR.GetAllyMemberList(opt, page, f) _send(_svr, _fc.AllyMember, _fmt("%s,'%s',%s", user.psn, opt, page), f) end
--[Comment]
--联盟操作 申请加入,退出,拒绝,同意,踢人,权限,公告,升级,国家
--opt [加入:join|联盟编号|留言],[退出:quit],[拒绝:refu|PSN],[同意:agre|PSN],[踢人:kick|PSN|留言],[权限:perm|PSN|(0,1,2)],[公告:post|文本],[简介:intr|文本],[升级:upgr],[维护:rent],[捐献:dona|金币数量|银币数量],[解散:free],[科技升级:tech|upg|???],[国家:nati|123]，[弹劾:imp|(1=弹劾 else否决)]
function SVR.AllyOption(opt, f) _send(_svr, _fc.AllyOption, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--联盟留言板操作
--opt [增加:add|留言],[删除:del|留言编号]
function SVR.AllyMessageBoard(opt, f) _send(_svr, _fc.AllyMsgBoard, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--联盟科技升级
--sn 1=HP 2=TP 3=STR 4=CAP 5=INT
function SVR.AllyTechUpgrade(sn, f) _send(_svr, _fc.AllyOption, _fmt("%s,'tech|upg|%s'", user.psn, sn == 1 and "tyg" or sn == 2 and "byg" or sn == 3 and "wlg" or sn == 4 and "tsg" or sn == 5 and "zlg" or ""), f) end
--[Comment]
--联盟科技培养
--gold 使用金币
--lockLst 锁定列表 "2,3,..."
function SVR.AllyTechDev(gold, lockLst, f) _send(_svr, _fc.AllyTechDev, _fmt("%s,'cult|%s|%s'", user.psn, useGold and "g" or "c", lockLst), f) end
--[Comment]
--联盟科技培养保存
--save 是保存 否则取消
function SVR.AllyTechDevSC(save, f) _send(_svr, _fc.AllyTechDev, _fmt("%s,'%s'", user.psn, save and "save" or "canc"), f) end
--[Comment]
--联盟科技捐献  money:[g==金币 r==钻石]  tech:[1:武 2:智 3:统]
function SVR.AllyTechDonate(money, tech, f) _send(_svr, _fc.AllyTechDev, _fmt("%s,'%s|%s'", user.psn, money, tech), f) end
--[Comment]
--获取联盟科技信息
function SVR.GetAllyTechInfo(f) _send(_svr, _fc.AllyTechDev, _fmt("%s,'inf'", user.psn), f) end
--[Comment]
--获取联盟商城信息
function SVR.GetAllyShopInfo(f) _send(_svr, _fc.AllyShopOption, _fmt("%s,'inf'", user.psn), f) end
--[Comment]
--刷新联盟商城
function SVR.AllyShopRefresh(f) _send(_svr, _fc.AllyShopOption, _fmt("%s,'ref'", user.psn), f) end
--[Comment]
--购买联盟商店商品
--sn 商品SN
function SVR.AllyShopBuy(sn, f) _send(_svr, _fc.AllyShopOption, _fmt("%s,'buy|%s'", user.psn, sn), f) end
--[Comment]
--获取联盟任务信息
function SVR.GetAllyQuestInfo(f) _send(_svr, _fc.AllyQuestOption, _fmt("%s,'infg'", user.psn), f) end
--[Comment]
--获取我接取的联盟任务信息
function SVR.GetMyAllyQuestInfo(f) _send(_svr, _fc.AllyQuestOption, _fmt("%s,'infp'", user.psn), f) end
--[Comment]
--接受联盟任务
--qsn 任务编号
function SVR.AcceptAllyQuest(qsn, f) _send(_svr, _fc.AllyQuestOption, _fmt("%s,'accp|%s'", user.psn, qsn), f) end
--[Comment]
--放弃联盟任务
--qsn 任务编号
function SVR.GiveUpAllyQuest(qsn, f) _send(_svr, _fc.AllyQuestOption, _fmt("%s,'canc|%s'", user.psn, qsn), f) end
--[Comment]
--完成联盟任务
--qsn 任务编号
function SVR.DoneAllyQuest(qsn, f) _send(_svr, _fc.AllyQuestOption, _fmt("%s,'rewd|%s'", user.psn, qsn), f) end
--[Comment]
--刷新我接取的联盟任务
--qsn 任务编号
--rmb 是否积分刷新
function SVR.RefreshMyAllyQuest(qsn, rmb, f) _send(_svr, _fc.AllyQuestOption, _fmt("%s,'rnew|%s|%s'", user.psn, qsn, rmb and 1 or 0), f) end
--[Comment]
--联盟改名
--gnm 新的名称
--banner 新的旗号
function SVR.AllyReName(gnm, banner, f) _send(_svr, _fc.AllyReName, _fmt("%s,'%s','%s'", user.psn, gnm, banner), f) end
--[Comment]
--联盟战 - 获取信息
function SVR.GetAllyBattleInfo(f) _send(_svr, _fc.AllyBattleInfo, _fmt("%s", user.psn), f) end
--[Comment]
--联盟战 - 报名
function SVR.EnrollAllyBattle(f) _send(_svr, _fc.AllyBattleEnroll, _fmt("%s", user.psn), f) end
--[Comment]
--联盟战 - 获取联盟战队信息（按线路）
function SVR.AllyBattleGetAllyTeamInfo(way, f) _send(_svr, _fc.AllyBattleAllyTeamInfo, _fmt("%s,%s", user.psn, way), f) end
--[Comment]
--联盟战 - 获取我的战队信息（返回数据以武将为单位）
function SVR.AllyBattleGetMyTeamInfo(f) _send(_svr, _fc.AllyBattleMyTeamInfo, user.psn, f) end
--[Comment]
--联盟战 - 战队操作
--opt 操作码 (new|路线|武将列表|军师索引:新建战队，sav|战队编号|武将列表|军师索引:保存战队，way|战队编号|路线:战队换线，dis|战队编号:解散战队，js|战队编号|军师位置)
function SVR.AllyBattleOpt(opt, f) _send(_svr, _fc.AllyBattleOpt, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--联盟战 - 获取自己的战报
--way 路线
--ssn 起始sn
function SVR.AllyBattleGetReports(way, ssn, f) _send(_svr, _fc.AllyBattleReport, _fmt("%s,'sef|%s|%s'", user.psn, way, ssn), f) end
--[Comment]
--联盟战 - 战斗回放
--fsn - 战报编号
function SVR.AllyBattleRec(fsn, f) _send(_svr, _fc.AllyBattleRec, _fmt("%s,%s", user.psn, fsn), f) end
--[Comment]
--联盟战 - 排行榜获取
function SVR.AllyBattleRank(f) _send(_svr, _fc.AllyBattleRank, user.psn, f) end
--[Comment]
--联盟战 商城获取信息
function SVR.AllyBattleShopInfo(f) _send(_svr, _fc.AllyBattleShop, _fmt("%s,'inf'", user.psn), f) end
--[Comment]
--联盟战 商城刷新
function SVR.AllyBattleShopRef(f) _send(_svr, _fc.AllyBattleShop, _fmt("%s,'ref'", user.psn), f) end
--[Comment]
--联盟战 - 商城购买
--sn 商品SN
function SVR.AllyBattleShopBuy(sn, f) _send(_svr, _fc.AllyBattleShop, _fmt("%s,'buy|%s'", user.psn, sn), f) end
--[Comment]
--向别人发起借将申请  sn:对方的psn   msg:留言
function SVR.AllyBorrowHero(sn, msg, f) _send(_svr, _fc.AllyBorrowHeroOpt, _fmt("%s, 'appl|%s|%s'", user.psn, msg, sn), f) end
--[Comment]
--同意别人的申请  sn:对方的psn   csn:武将编号
function SVR.AllyBorrowHeroAgreeOpt(sn, csn, f) _send(_svr, _fc.AllyBorrowHeroOpt, _fmt("%s, 'agr|%s|%s'", user.psn, csn, sn), f) end
--[Comment]
--拒绝别人的申请  sn:对方的psn
function SVR.AllyBorrowHeroRefuseOpt(sn, f) _send(_svr, _fc.AllyBorrowHeroOpt, _fmt("%s, 'reg|%s'", user.psn, sn), f) end
--[Comment]
--召回借出的还未被接收的武将  csn:借出武将的csn sn:对方的psn
function SVR.AllyBorrowHeroReCall(csn, sn, f) _send(_svr, _fc.AllyBorrowHeroOpt, _fmt("%s, 'call|%s|%s'", user.psn, csn, sn), f) end
--[Comment]
--查询收到的借将申请
function SVR.AllyBorrowHeroCheckFromOther(f) _send(_svr, _fc.AllyBorrowHeroOpt, _fmt("%s, 'inf'", user.psn), f) end
--[Comment]
--查询发起的借将申请
function SVR.AllyBorrowHeroCheck(f) _send(_svr, _fc.AllyBorrowHeroCheck, _fmt("%s, 'inf'", user.psn), f) end
--[Comment]
--接收别人同意借出的武将 csn:对方同意借出武将的csn  sn:对方的psn
function SVR.AllyBorrowHeroRecive(csn, sn, f) _send(_svr, _fc.AllyBorrowHeroCheck, _fmt("%s, 'agr|%s|%s'", user.psn, csn, sn), f) end
--[Comment]
--BOSS战操作
--获取BOSS战信息
function SVR.GetBossInfo(f) _send(_svr, _fc.GetBossInfo, user.psn, f) end
--[Comment]
--BOSS操作
--opt [CD:cd|,[鼓舞:gw]
function SVR.BossOption(opt, f) _send(_svr, _fc.BossOption, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--二代BOSS信息
function SVR.Boss2Info(f) _send(_svr, _fc.Boss2, user.psn, f) end
--[Comment]
--过关斩将
--获取过关斩将的信息
function SVR.GetTowerInfo(f) _send(_svr, _fc.TowerOption, _fmt("%s,'inf'", user.psn), f) end
--[Comment]
--重置过关斩将
function SVR.ResetTower(f) _send(_svr, _fc.TowerOption, _fmt("%s,'set'", user.psn), f) end
--[Comment]
--过关斩将扫荡
function SVR.BlitzTower(dif,f) _send(_svr, _fc.TowerOption, _fmt("%s,'mop|%d'", user.psn,dif), f) end
--[Comment]
--名人堂
--获取名人堂信息
function SVR.GetFameInfo(f) _send(_svr, _fc.GetFameInfo, user.psn, f) end

--------------------------------------宝石--------------------------------------
--[Comment]
--宝石升级
--gem 升级目标
--all 是否全升
function SVR.GemUpgrade(gem, all, f) _send(_svr, _fc.GemOption, _fmt("%s,'upgr|%s|%s'", user.psn, gem, all and 0 or 1), f) end
--[Comment]
--宝石熔炼
--gems 消耗宝石(dbsn|dbsn...)
function SVR.GemMelt(gems, f) _send(_svr, _fc.GemOption, _fmt("%s,'melt|%s'", user.psn, gems), f) end

--------------------------------------其它常用操作--------------------------------------
--[Comment]
--获取全局冷却时间
function SVR.GetColdTime() _send(_svr, _fc.GetColdTime, user.psn) end
--[Comment]
--兑换码兑换奖励
--code 兑换码
function SVR.UseExCode(code, f) _send(_svr, _fc.UseExCode, _fmt("%s,'%s'", user.psn, code), f) end
--[Comment]
--获取签到数据
function SVR.GetSignData(f) _send(_svr, _fc.GetSignData, user.psn, f) end
--[Comment]
--签到
--free 是否免费
function SVR.Sign(free, f) _send(_svr, _fc.Sign, _fmt("%s,'%s'", user.psn, free and "free" or "rmb"), f) end
--[Comment]
--VIP礼包领取
function SVR.GetVipGift(f) _send(_svr, _fc.VipGift, user.psn, f) end
--[Comment]
--领取七日登录奖励
function SVR.GetRewardSeven(f) _send(_svr, _fc.RewardSeven, user.psn, f) end
--[Comment]
--购买VIP礼包
--sn 礼包SN
function SVR.BuyVipGift(sn, f) _send(_svr, _fc.GetGifts, _fmt("%s,'%s'", user.psn, "buy|" .. sn), f) end
--[Comment]
--用户禁言
function SVR.PlayerChatBan(f) _send(_svr, _fc.BanChat, _fmt("%s,'set|5'", user.psn), f) end
--[Comment]
--物品出售
--opt 操作码(eq:装备出售，eqr:装备按稀有度出售，dq:军备出售，dqr:军备按稀有度出售，csx|dbsn|qty:出售天机专属)
--lst 操作码需求的列表(稀有度列表或者SN列表)
function SVR.ItemSell(opt, lst, f) if lst and #lst > 0 then _send(_svr, _fc.ItemSell, _fmt("%s,'%s|%s'", user.psn, opt, _join(",", list)), f) end end
--[Comment]
--物品出售
--opt 操作码(eq:装备出售，eqr:装备按稀有度出售，dq:军备出售，dqr:军备按稀有度出售，csx|dbsn|qty:出售天机专属)
function SVR.ItemSell(opt, f) _send(_svr, _fc.ItemSell, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--物品熔铸
--opt 操作码(dq:军备熔铸)
--item 物品SN列表
function SVR.ItemMelt(opt, item, f) if item and #item > 0 then _send(_svr, _fc.ItemMelt, _fmt("%s,'%s|%s'", user.psn, opt, _join(",", item)), f) end end
--[Comment
--实名验证
--nm 姓名
--id 证件ID
function SVR.Verify(nm, id, f) _send(_svr, _fc.Verify, _fmt("%s,'%s','%s'", user.psn, nm, id), f) end
--[Comment]
--实名验证 SDK
--age 年龄
function SVR.VerifySDK(age, f) _send(_svr, _fc.VerifySDK, _fmt("%s,%s", user.psn, age), f) end
--[Comment]
--实名验证-充值限制
function SVR.VerifyCharge(f) _send(_svr, _fc.VerifyCharge, user.psn, f) end
--[Comment]
--快捷操作
--opt 操作码(gnc:获取国战武将sn)
function SVR.QuickOption(opt, f) _send(_svr, _fc.QuickOpt, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--新手步骤
--step 步骤
function SVR.TuriStep(step) _send(_svr, _fc.TiroStep, _fmt("%s,%s", user.psn, step)) end

--------------------------------------活动相关--------------------------------------
--[Comment]
--获取通用活动列表
function SVR.GetActLst(f) _send(_svr, _fc.ActLst, user.psn, f) end
--[Comment]
--获取通用活动信息
--asn 活动SN
function SVR.GetComActInfo(asn, f) _send(_svr, _fc.ActOpt, _fmt("%s,%s,'inf'", user.psn, asn), f) end
--[Comment]
--通用活动购买/获取
--asn 活动SN
--aisn 活动子项SN
--qty 购买/领取数量(仅在部分活动有效)
function SVR.GetComAct(asn, aisn, qty, f) _send(_svr, _fc.ActOpt, _fmt("%s,%s,'get|%s|%s'", user.psn, asn, aisn, qty), f) end
--[Comment]
--通用活动完成任务
--asn 活动SN
--atsn 任务SN
function SVR.GetComActTask(asn, atsn, f) _send(_svr, _fc.ActOpt, _fmt("%s,%s,'task|%s'", user.psn, asn, atsn), f) end
--[Comment]
--获取通用活动排行信息
--asn 活动SN
function SVR.GetComActRank(asn, f) _send(_svr, _fc.ActOpt, _fmt("%s,%s,'rank'", user.psn, asn), f) end
--[Comment]
--获取通用活动历史获奖信息
--asn 活动SN
function SVR.GetComActHst(asn, f) _send(_svr, _fc.ActOpt, _fmt("%s,%s,'hst'", user.psn, asn), f) end
--[Comment]
--打开红包
--redsn 红包SN
function SVR.GetComActRed(redsn, f) _send(_svr, _fc.ActRedGet, _fmt("%s,%s", user.psn, redsn), f) end
--[Comment]
--充值排行奖励
function SVR.GetRechargeRank(f) _send(_svr, _fc.GetRechargeRank, user.psn, f) end
--[Comment]
--购买基金
function SVR.BuyFund(f) _send(_svr, _fc.GetFundOpt, _fmt("%s,'buy|1'", user.psn), f) end
--[Comment]
--领取奖励
--sn 领取sn
function SVR.GetFundReward(sn, f) _send(_svr, _fc.GetFundOpt, _fmt("%s,'rew|%s'", user.psn, sn), f) end
--[Comment]
--通用活动购买/获取
--opt get:买宝箱，gu:放弃，其它:取信息
function SVR.GetAct108(opt, f) _send(_svr, _fc.ActOpt108, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--对决活动
--opt chs|角色SN:选择角色，sup|数量:鼓舞，其它:取信息
function SVR.GetAct17(opt, f) _send(_svr, _fc.ActOpt17, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--消消乐活动
--opt get|位置:消除，其它:取信息
function SVR.GetAct18(opt, f) _send(_svr, _fc.ActOpt18, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--幸运号活动
--opt get|alsn:获取奖励，其它:取信息
function SVR.GetAct20(opt, f) _send(_svr, _fc.ActOpt20, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--幸运号记录
function SVR.GetAct20Rec(start, f) _send(_svr, _fc.ActRec20, _fmt("%s,%s", user.psn, start), f) end
--[Comment]
--有限转盘
--opt get|alsn:获取奖励，其它:取信息
function SVR.GetAct21(opt, f) _send(_svr, _fc.ActOpt21, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--群英客栈
--opt ref:刷新，get|idx[1,2,3]:获取奖励，其它:取信息
function SVR.GetAct34(opt, f) _send(_svr, _fc.ActOpt34, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--竞猜活动
--inf:取信息，bet|sn|props|ret|qty:投注[竞猜项SN，下注道具SN，下注项，下注数量]， get|sn|qty:兑换道具[兑换项SN，道具数量]
function SVR.GetAct38(opt, f) _send(_svr, _fc.ActOpt38, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--充值礼包
--inf:取信息， get|sn:购买礼包[礼包项SN]
function SVR.GetAct39(opt, f) _send(_svr, _fc.ActOpt39, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--绑定手机
function SVR.GetAct306(p3acc) _send(_svr, _fc.ActOpt306, _fmt("%s,'%s'", user.psn, p3acc)) end
--[Comment]
--合服活动列表
function SVR.GetActHFList(f) _send(_svr, _fc.ActGetHF, user.psn, f) end

    

--------------------------------------国战相关--------------------------------------
--[Comment]
--更改国家公告
--anno 公告
function SVR.NatAnno(anno, f) _send(_svr, _fc.NatOption, _fmt("%s,'anno|%s'", user.psn, anno), f) end
--[Comment]
--觐见
--opt 获取信息：info。任命：duty|1左2右|任命对象SN。膜拜：cult|1左2右9国主
function SVR.NatCult(opt, f) _send(_svr, _fc.NatOption, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--国战活跃
--opt 信息:[info], 领取:[get|idx宝箱索引1-4]
function SVR.NatAct(opt, f) _send(_svr, _fc.NatAct, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--获取国家信息
function SVR.GetNatInfo(f) _send(_svr, _fc.GetNatInfo, _fmt("%s,'sn|0'", user.psn), f) end
--[Comment]
--获取国家信息
function SVR.GetNatHero(f) _send(_svr, _fc.NatHero, user.psn, f) end
--[Comment]
--国战移动武将
--city 目标城池
--csn 武将编号
function SVR.NatHeroMove(city, csn, f) _send(_svr, _fc.NatHeroMove, _fmt("%s,%s,%s", user.psn, city, csn), f) end
--[Comment]
--获取国战总览
function SVR.NatOverview(f) _send(_svr, _fc.NatOverview, _fmt("%s,0", user.psn), f) end
--[Comment]
--国家城池信息
--city 城池编号
function SVR.NatCityFightInfo(city, f) _send(_svr, _fc.NatCityInfo, _fmt("%s,%s", user.psn, city), f) end
--[Comment]
--国战配置武将
--hero 武将列表
function SVR.NatSetHero(hero, f) _send(_svr, _fc.NatSetHero, _fmt("%s,'%s'", user.psn, _join(",", hero)), f) end
--[Comment]
--获取国战城池战斗消息
--city 城池编号
--last 最后的消息编号
function SVR.NatCityReport(city, last, f) _send(_svr, _fc.NatReport, _fmt("%s,'cit|%s|%s'", user.psn, city, last), f) end
--[Comment]
--获取国战与我相关的战斗消息
--last 最后的消息编号
function SVR.NatReport(last, f) _send(_svr, _fc.NatReport, _fmt("%s,'psn|%s|%s'", user.psn, user.psn, last), f) end
--[Comment]
--国战粮草操作
--opt get,buy
function SVR.NatFood(opt, f) _send(_svr, _fc.NatFood, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--国战武将粮草操作
--csn 武将编号
function SVR.NatHeroFood(csn, f) _send(_svr, _fc.NatHeroFood, _fmt("%s,%s", user.psn, csn), f) end
--[Comment]
--武将晋升军阶
--csn 武将编号
function SVR.HeroRankUp(csn, f) _send(_svr, _fc.HeroRankUp, _fmt("%s,%s", user.psn, csn), f) end
--[Comment]
--武将军阶突破
function SVR.HeroRankAdv(csn,f) _send(_svr,_fc.HeroRank,_fmt("%s,%s,'adv'",user.psn,csn),f) end
--[Comment]
--玩家晋升爵位
function SVR.UserUpPeerage(f) _send(_svr, _fc.UserPeerageUp, user.psn, f) end
--[Comment]
--国库
--opt 刷新:ref 信息:inf 所有:all
function SVR.NatShop(opt, f) _send(_svr, _fc.NatShop, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--购买国库商品
--商品编号
function SVR.NatBuyGoods(sn, f) _send(_svr, _fc.NatBuyGoods, _fmt("%s,'buy|%s'", user.psn, sn), f) end
--[Comment]
--武将操作
--opt (分身:[copy|ncsn|csn] , 撤退:[back|ncsn|csn])
--city 城池编号
--csn 武将编号 
function SVR.NatHeroOpt(opt, city, csn, f) _send(_svr, _fc.NatHeroOpt, _fmt("%s,'%s|%s|%s'", user.psn, opt, city, csn), f) end
--[Comment]
--获取战斗回放数据
--sn 战报SN
function SVR.NatReplay(sn, f) _send(_svr, _fc.NatReplay, _fmt("%s,%s", user.psn, sn), f) end
--[Comment]
--国战单挑
--csn 武将编号
--city 城池编号 
function SVR.NatSolo(csn, city, f) _send(_svr, _fc.NatSolo, _fmt("%s,%s,%s", user.psn, csn, city), f) end
--[Comment]
--获取国战任务城池
function SVR.NatActInfo(f) _send(_svr, _fc.NatActInfo, user.psn, f) end
--[Comment]
--州郡操作
--opt up:注资,att:关注
--nssn 州郡编号
function SVR.NatState(opt, nssn, f) send(_svr, _fc.NatState, _fmt("%s,'%s|%s'", user.psn, opt, nssn), f) end
--[Comment]
--国家矿脉操作
--opt inf:取信息,pick:征收,set|武将列表:配置驻守,exc:领取矿脉宝箱
--nmsn 矿脉SN
function SVR.NatMine(opt, nmsn, f) _send(_svr, _fc.NatMine, _fmt("%s,%s,'%s'", user.psn, nmsn, opt), f) end
--[Comment]
--国战血战操作
--opt inf:取信息,target|citySn:设置目标,free:免费开启,rmb:积分开启
function SVR.NatBlood(opt, f) _send(_svr, _fc.NatBlood, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--国战日常[信息:[inf], 领取:[get|idx宝箱索引1-4]]
function SVR.NatDailyOpt(opt, f) _send(_svr, _fc.NatDaily, _fmt("%s,'%s'", user.psn, opt), f) end
    
--------------------------------------占卜相关--------------------------------------
--[Comment]
--占卜操作
--opt 操作(info:信息 shuf:洗牌 turn|idx:翻牌idx为位置,从1开始)
function SVR.DivineOption(opt, f) _send(_svr, _fc.DivineOption, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--占卜排行数据
function SVR.DivineRank(f) _send(_svr, _fc.DivineRank, user.psn, f) end
    
--------------------------------------秘境巡游--------------------------------------
--[Comment]
--秘境巡游操作
--opt 操作(inf:信息 go:走动)
function SVR.FamOption(opt, f) _send(_svr, _fc.FamOption, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--秘境通关奖励信息
function SVR.FamRewardInfo(f) _send(_svr, _fc.FamReward, _fmt("%s,'inf'", user.psn), f) end
--[Comment]
--秘境通关奖励获取
--sn 奖励编号
function SVR.FamGetReward(sn, f) _send(_svr, _fc.FamReward, _fmt("%s,'get|%s'", user.psn, sn), f) end
    
--------------------------------------议事厅--------------------------------------
--[Comment]
--议事厅操作
--opt 操作(inf|sn:取信息 rew|sn:领奖励 buy|sn:买基金 lst:取列表 inv|code:输入招待码)
function SVR.AffairOption(opt, f) _send(_svr, _fc.AffairOption, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--议事厅排行操作
--opt 操作(inf|sn:取信息)
function SVR.AffairRankOption(opt, f) _send(_svr, _fc.AffairRankOption, _fmt("%s,'%s'", user.psn, opt), f) end

--------------------------------------成就--------------------------------------
--[Comment]
--成就操作
--opt 操作(inf|类型:取指定类型的成就数据，get|编号:领取成就奖励)
function SVR.AchievementOption(opt, f) _send(_svr, _fc.Achievement, _fmt("%s,'%s'", user.psn, opt), f) end
    
--------------------------------------等级 限时礼包--------------------------------------
--[Comment]
--等级 限时礼包操作
--opt inf:信息，blv|lv:购买等级礼包，btm|sn:购买限时礼包，clv:校验等级礼包
function SVR.GetGift(opt, f) _send(_svr, _fc.GiftOpt, _fmt("%s,'%s'", user.psn, opt), f) end


--------------------------------------天机 极限挑战--------------------------------------
--[Comment]
--天机
--csn 武将编号
--opt inf:信息，up:升级天机等级，ups|技能索引(从1开始):升级指定天机技能
function SVR.HeroSecret(csn, opt, f) _send(_svr, _fc.HeroSecret, _fmt("%s,%s,'%s'", user.psn, csn, opt), f) end
--[Comment]
--极限挑战
--opt inf:信息，ref:刷新，mop|武将DBSN|难度(1-5):扫荡
function SVR.HeroChallengeOpt(opt, f) _send(_svr, _fc.HeroChallenge, _fmt("%s,'%s'", user.psn, opt), f) end

    
--------------------------------------跨服国战--------------------------------------
--[Comment]
--跨服国战操作
--opt 信息:inf,募集:raise|gold金币 rmb积分,buy购买粮草
function SVR.SnatOpt(opt, f) _send(_svr, _fc.SnatOpt, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--跨服国战进入
function SVR.SnatEnter(f) _send(_svr, _fc.SnatEnter, user.psn, f) end
--[Comment]
--跨服国战武将列表
function SVR.SnatHeroList(f) _send(_svr, _fc.SnatHeroInf, user.psn, f) end
--[Comment]
--跨服国战武将配置
--hero 武将SN列表
function SVR.SnatHeroSet(hero, f) _send(_svr, _fc.SnatHeroSet, _fmt("%s,'%s'", user.psn, _join(",", hero)), f) end
--[Comment]
--武将操作(分身:[fs] , 撤退:[back]，补粮:[food])
--csn 武将编号
--opt (分身:[copy] , 撤退:[back]，补粮:[food])
function SVR.SnatHeroOpt(csn, opt, f) _send(_svr, _fc.SnatHeroOpt, _fmt("%s,%s,'%s'", user.psn, csn, opt), f) end
--[Comment]
--跨服国战移动武将
--city 目标城池
--csn 武将编号
function SVR.SnatHeroMove(city, csn, f) _send(_svr, _fc.SnatHeroMove, _fmt("%s,%s,%s", user.psn, csn, city), f) end
--[Comment]
--国战单挑
--csn 武将编号
function SVR.SnatSolo(csn, f) _send(_svr, _fc.SnatSolo, _fmt("%s,%s", user.psn, csn), f) end
--[Comment]
--跨服国战城池信息
--city 城池
function SVR.SnatCity(city, f) _send(_svr, _fc.SnatCity, _fmt("%s,%s", user.psn, city), f) end
--[Comment]
--获取跨服国战城池战斗消息
--city 城池
--last 最后的消息编号
function SVR.SnatCityReport(city, last, f) _send(_svr, _fc.SnatRec, _fmt("%s,%s,%s", user.psn, city, last), f) end
--[Comment]
--获取跨服国战玩家战报
--last 最后的消息编号
function SVR.SnatReport(last, f) _send(_svr, _fc.SnatRec, _fmt("%s,0,%s", user.psn, last), f) end
--[Comment]
--跨服国战回放
--fsn 战斗SN
function SVR.SnatReplay(fsn, f) _send(_svr, _fc.SnatReplay, _fmt("%s,%s", user.psn, fsn), f) end
--[Comment]
--跨服国战排名信息
function SVR.SnatRank(f) _send(_svr, _fc.SnatRank, user.psn, f) end
    
--------------------------------------日常功能--------------------------------------
--[Comment]
--日常操作
--opt inf:信息，get|sn领取奖励
function SVR.DailyOpt(opt, f) _send(_svr, _fc.DailyOpt, _fmt("%s,'%s'", user.psn, opt), f) end

--------------------------------------宴会--------------------------------------
--[Comment]
--宴会
function SVR.Feast(f) _send(_svr, _fc.Feast, user.psn, f) end
    
--------------------------------------铜雀台--------------------------------------
--[Comment]
--铜雀台操作
--opt 操作(inf:信息，enc|bsn:邂逅，up|bsn:升级指定美女，up1|bsn|lv:一键升级指定美女到指定等级，fate|bsn:结缘指定美女，star|bsn|prop|num:升星指定美女)
function SVR.Beauty(opt, f) _send(_svr, _fc.Beauty, _fmt("%s,'%s'", user.psn, opt), f) end

--------------------------------------逐鹿中原--------------------------------------

--[Comment]
--TCG登录数据获取
function SVR.GetTcgLogin(f) _send(_svr, _fc.TcgLogin, _fmt("%s,'%s'", user.psn, SDK.uuid), f) end
    

--[Comment]
--TCG匹配数据获取
--star 比赛星级 
function SVR.GetTcgMatch(star, f) _send(_svr, _fc.TcgMatch, _fmt("%s,%s", user.psn, star), f) end
--[Comment]
--TCG操作
--opt 操作码 inf:信息，grp|idx|clst:配置阵容
function SVR.GetTcgOpt(opt, f) _send(_svr, _fc.TcgOpt, _fmt("%s,'%s'", user.psn, opt), f) end

--------------------------------------考试--------------------------------------
--[Comment]
--考试信息
function SVR.ExamInfo(f) _send(_svr, _fc.Exam, user.psn, f) end
--[Comment]
--考试操作
--exam 考场编号
--opt inf:信息，join:加入，ans|答案:答题，rev:复活
function SVR.ExamOpt(exam, opt, f) _send(_svr, _fc.ExamOpt, _fmt("%s,%s,'%s'", user.psn, exam, opt), f) end
--[Comment]
--考试排名数据
--exam 考场编号
function SVR.ExamRank(exam, f) _send(_svr, _fc.ExamRank, _fmt("%s,%s", user.psn, exam), f) end
    
--------------------------------------幻境挑战--------------------------------------
--[Comment]
--幻境挑战
--opt inf:信息，set|chars:配置武将，rwf|lsn:领取首通奖励，rwp|lsn:领取完美奖励，mop:扫荡
function SVR.Fantsy(opt, f) _send(_svr, _fc.Fantsy, _fmt("%s,'%s'", user.psn, opt), f) end
--[Comment]
--幻境挑指定武将战兵种阵型
--csn 武将编号
--opt inf:信息，ss|兵种编号:配置兵种，sl|阵型编号:配置阵型
function SVR.FantsySL(csn, opt, f) _send(_svr, _fc.FantsySL, _fmt("%s,%s,'%s'", user.psn, csn, opt), f) end


-------------------------------跨服 PVP-------------------------------------------
--[Comment]
--跨服 PVP 命令
local CMD_PEAK="g_srank"

--[Comment]
--取跨服PVP信息          外加参数 服号,开服时间
function SVR.PeakInfo(f) _send(_svr,CMD_PEAK ,_fc.PeakInfo,_fmt("%s,%%s",user.psn),f) end
--[Comment]
--取跨服PVP排名   page:页码
function SVR.PeakRank(page,f) _send(_svr,CMD_PEAK,_fc.PeakRank,_fmt("%s,%%s,%s",user.psn,page),f) end
--[Comment]
--参加跨服PVP   kind:赛事类型   外加参数 服号,库名,开服时间,昵称,vip,头像,联盟名称
function SVR.PeakJoin(kind,f) _send(_svr,CMD_PEAK,_fc.PeakJoin,_fmt("%s,%s,%%s",user.psn,kind),f) end
--[Comment]
--取跨服PVP配置武将    heros:武将列表，为null表示不驻守，否则维持数组为5个元素,空置位置补0  advPos:军师位置(1-5)
function SVR.PeakHero(heros,advPos,f)  _send(_svr,CMD_PEAK,_fc.PeakHero,_fmt("%s,%%s,'%s',%s,",user.psn,heros==nil and "" or _join(",",heros),advPos),f) end
--[Comment]
--取跨服PVP 对手 refresh:是否是刷新
function SVR.PeakRival(refresh,f) _send(_svr,CMD_PEAK,_fc.PeakRival,_fmt("%s,%%s,%s",user.psn,refresh and 1 or 0),f) end
--[Comment]
--取跨服PVP 对手武将 oppPsn:对手PSN oppRsn:对手RSN
function SVR.PeakRivalHero(oppPsn,oppRsn,f) _send(_svr,CMD_PEAK,_fc.PeakRivalHero,_fmt("%s,%s,%s",user.psn,oppPsn,oppRsn),f) end
--[Comment]
--取跨服PVP 挑战 oppPsn:对手PSN oppRsn:对手RSN  heros:出战武将(5个元素)
function SVR.PeakFightTZ(oppPsn,oppRsn,heros,advPos,f,waitTime)
    if not waitTime then waitTime=20 end 
    if heros==nil then return end
    local task=_send(_svr,CMD_PEAK,_fc.PeakFight,_fmt("%s,%%s,'py|%s|%s','%s',%s",user.psn,oppPsn,oppRsn,_join(",",heros),advPos),f)
    if task then 
        task:SetTimeout(waitTime)
        StatusBar.Exit(task)
    end
end
--[Comment]
--取跨服PVP 反击 fsn:战斗SN  heros:出战武将(5个元素)
function SVR.PeakFightFJ(fsn,heros,advPos,f,waitTime)
    if not waitTime then waitTime=20 end 
    if heros==nil then return end
    local task=_send(_svr,CMD_PEAK,_fc.PeakFight,_fmt("%s,%%s,'fb|%s','%s',%s",user.psn,fsn,_join(",",heros),advPos),f)
    if task then
        task:SetTimeout(waitTime)
        StatusBar.Exit(task)
    end
end
--[Comment]
--取跨服PVP 已读战斗消息 fsn:战斗SN
function SVR.PeakFightRead(fsn,f) _send(_svr,CMD_PEAK,_fc.PeakFightRead,_fmt("%s,%%s,%s",user.psn,fsn),f) end
--[Comment]
--取跨服PVP 战报
function SVR.PeakFightReportZB(f) _send(_svr,CMD_PEAK,_fc.PeakReport,_fmt("%s,%%s",user.psn),f) end
--[Comment]
--取跨服PVP 战报详情
function SVR.PeakFightReportDetail(fsn,f) _send(_svr,CMD_PEAK,_fc.PeakReportDetail,_fmt("%s,%%s,%s",user.psn,fsn),f) end
--[Comment]
--回放
function SVR.PeakReplay(fsn,pos,f) _send(_svr,CMD_PEAK,_fc.PeakReplay,_fmt("%s,%%s,%s,%s",user.psn,fsn,pos),f) end

--[Comment]
--在线奖励
function SVR.OnlineOpt(opt,f)
    _send(_svr,_fc.OnlineOpt,_fmt("%s,'%s'",user.psn,opt),f)
end

--[Comment]
--VIP等级礼包
function SVR.VipLvGiftOpt(opt,vipLv,f)
    _send(_svr,_fc.VipLvGiftStu,_fmt("%s,%d,'%s'",user.psn,vipLv,opt),f)
end

--region 竞技场
--[Comment]
--查询竞技场积分奖励信息
function SVR.GetRenownRewardInfo(f)
    _send(_svr, _fc.RenownRewardOp, _fmt("%s,'inf'",user.psn),f)
end
--endregion

--[Comment]
--查询声望商城
function SVR.GetSoloRenownShop(f)
    _send(_svr,_fc.SoloRewardShop,_fmt("%s,'inf'",user.psn),f)
end

--[Comment]
--领取竞技场排名奖励
function SVR.ReciveRankReward(sn,f)
    _send(_svr,_fc.RankRewardOp,_fmt("%s,'rw|%d'",user.psn,sn),f)
end

--[Comment]
--查询竞技场排名奖励
function SVR.GetRankRewardInfo(f)
    _send(_svr,_fc.RankRewardOp,_fmt("%s,'inf'",user.psn),f)
end

--[Comment]
--购买声望商城的东西
function SVR.BuySoloRenownShop(sn,num,f)
    _send(_svr,_fc.SoloRewardShop,_fmt("%s,'buy|%d|%d'",user.psn,sn,num),f)
end

--[Comment]
--获取指定玩家的驻守武将
function SVR.GetDefendHero(psn,f)
    _send(_svr,_fc.GetDefendHero,_fmt("%s,%d",user.psn,psn),f)
end

--[Comment]
--获取竞技场中的排行榜
function SVR.GetSoloRank(f)
    _send(_svr,_fc.GetSoloRank,user.psn,f)
end

--[Comment]
--部署过关斩将的英雄
--英雄的sn  csn1,武力，智力，统帅，生命|csn2,武力，智力，统帅，生命|csn3,武力，智力，统帅，生命.
function SVR.DeployTowerHero(hs,f)
    _send(_svr,_fc.TowerDeploy,_fmt("%s,'%s'",user.psn,hs),f)
end

--[Comment]
--转盘（战役）
--'inf':查看 'get|1':一次抽 'get|10':十连抽 'ref':刷新 
function SVR.Turntable(opt,f)
    _send(_svr,_fc.Turntable,_fmt("%s,'%s'",user.psn,opt),f)
end

---<summary>
---补充体力
---</summary>
function SVR.AddVIT(opt,f)
    _send(_svr,_fc.AddVIT,_fmt("%s,'%s'",user.psn,opt),f)
end

---<summary>
---补充酒值
---</summary>
function SVR.AddWine(f)
    _send(_svr,_fc.AddWine,_fmt("%s",user.psn),f)
end

--[Comment]
--累计签到奖励
function SVR.SignCumRewardInf(opt,lv,f)
    _send(_svr,_fc.SignCumRewardInf,_fmt("%s,'%s',%d",user.psn,opt,lv),f)
end
--[Comment]
--帝国个人科技
--inf:查询，up:升级：up|sn|1:升级，up|sn|2:一键升级，（sn:需要升级的技能） ， reset:重置 ，buy:购买重置
function SVR.TechPersonal(opt,f)
    _send(_svr,_fc.TechPersonal,_fmt("%s,'%s'",user.psn,opt),f)
end
--[Comment]
--国库(刷新:ref 信息:inf 所有:all)
function SVR.CountryShop(opt,f)
    _send(_svr,_fc.CountryShop,_fmt("%s,'%s'",user.psn,opt),f)
end
--[Comment]
--购买竞技场挑战次数（消耗的钻石，购买的数量）
function SVR.BuySoloTimes(cost,num,f)
    _send(_svr,_fc.RankOption,_fmt("%s,'%s'",user.psn,"buy|"..cost.."|"..num),f)
end
--[Comment]
--购买国库道具
function SVR.CountryBuyGoods(sn,f)
    _send(_svr,_fc.CountryBuyGoods,_fmt("%s,'buy|%s'",user.psn,sn),f)
end

-----------------------地宫相关---------------------------
--[Comment]
--地宫开始命令
function SVR.GveStart(f) _send(_svr, _fc.GveStart, _fmt("%s", user.psn), f) end
--[Comment]
--匹配命令  tsn:队伍编号  flv:地宫层数
function SVR.GveMatch(tsn, flv, f) _send(_svr, _fc.GveMatch, _fmt("%s,%s,%s", user.psn, tsn, flv), f) end
--[Comment]
--进入地宫命令
function SVR.GveEnter(f) _send(_svr, _fc.GveEnter, _fmt("%s", user.psn), f) end
--[Comment]
--创建地宫命令 tsn:队伍编号
function SVR.GveCreate(tsn, f) _send(_svr, _fc.GveCreate, _fmt("%s,%s", user.psn, tsn), f) end
--[Comment]
-- 离开地宫命令
function SVR.GveLeave(f) _send(_svr, _fc.GveLeave, _fmt("%s", user.psn), f) end
--[Comment]
--获取好友列表
function SVR.GveFriendList(opt, page, f) _send(_svr, _fc.GveFriendList, _fmt("%s,'%s|%s'", user.psn, opt, page), f) end
--[Comment]
--邀请好友 psn:被邀请人的psn  opt: 0=发送邀请 1=拒绝邀请  tsn:队伍编号 
function SVR.GveInvite(psn, opt, tsn, f) _send(_svr, _fc.GveInvite, _fmt("%s,%s,%s,%s", user.psn, psn, opt, tsn), f) end
--[Comment]
--获取地宫邀请信息
function SVR.GveCheckInvite(f) _send(_svr, _fc.GveCheckInvite, _fmt("%s", user.psn), f) end
--[Comment]
--获取战报 gsn:地宫编号 page:页码
function SVR.GveReport(gsn, page, f) _send(_svr, _fc.GveReport, _fmt("%s,%s,%s", user.psn, gsn, page), f) end
--[Comment]
--选择上阵武将
function SVR.GveSetHero(sns, f) _send(_svr, _fc.GveSetHero, _fmt("%s,'%s'", user.psn, table.concat(sns, ",")), f) end
--[Comment]
--行军命令 heros:要移动的武将sn  city:目的地城池编号
function SVR.GveAttack(heros, city, f) _send(_svr, _fc.GveAttack, _fmt("%s,'%s',%s",user.psn, table.concat(heros, ","), city), f) end
--[Comment]
--移动命令 heros:要移动的武将sn  city:目的地城池编号
function SVR.GveMove(heros, city, f) _send(_svr, _fc.GveHeroMove, _fmt("%s,'%s',%s",user.psn, table.concat(heros, ","), city), f) end
--[Comment]
--地宫战斗准备
function SVR.GveBattleReady(city, heros,f) 
    user.expHeroRecord = heros
    _send(_svr, _fc.GveBattleReady, _fmt("%s,'%s',%s,%s,'%s'", user.psn, "exp|"..city, user.IsAutoAddHP and 1 or 0 , user.IsAutoAddTP and 1 or 0, table.concat(heros, ",")), f) 
end
--[Comment]
--地宫战斗数据 atk:已方武将sn   def:守方武将sn  btype:发送的战斗类型
function SVR.GveBattleFight(atk, def, btype, f) _send(_svr, _fc.GveBattleFight, _fmt("%s,%s,'%s',%s", user.psn, atk, btype, def), f) end
--[Comment]
--点击信息按钮
function SVR.GveShowCityInfo(city, f) _send(_svr, _fc.GveShowInfo, _fmt("%s,%s", user.psn, city), f) end
--[Comment]
--战斗结果
--ret 结果0=我方输 1=我方胜
--battle 战斗数据
function SVR.GveBattleResult(ret, battle, f)
    if battle == nil then return end
    local oh = battle:atkHeroResult()
    local eh = battle:defHeroResult()
    local check = CS.MD5(_fmt("%s%s%d%d%d%s%s", user.psn, battle:addtionInfo(), battle.sn, ret, battle.cheat, oh, eh))
    check = string.sub(check, 8, 10)..string.sub(check, 18, 21)..string.sub(check, 30, 30) -- 第8位取3个,第18位取4个,第30位取1个
    local d = _fmt("%s,'%s','%s',%d,%d,'%s','%s','%s'", user.psn, battle:typeSend(), battle:addtionInfo(), ret, battle.cheat, oh, eh, check)
    _send(_svr, _fc.GveBattleResult, d, f)
end
--[Comment]
--侦察命令 city:城池编号 prop:斥候或精锐斥候
function SVR.GveCheckCityInfo(city, prop, f) _send(_svr, _fc.GveCheckInfo, _fmt("%s,%s,%s", user.psn, city, prop), f) end 
-----------------------征战相关---------------------------
--[Comment]
--征战宝箱  levelSn:关卡编号    opt:操作：查看传：''，获取传'get'      boxSn:宝箱编号
function SVR.ExpeditionBox(levelSn, opt, boxSn, f) _send(_svr, _fc.ExpeditionBox, _fmt("%s,%s,'%s','%s'", user.psn, levelSn, opt, boxSn), f) end

--[Comment]
--城池一键升级  cityLevel:大关卡sn
function SVR.CityOneUpgrade(cityLevel, f) _send(_svr, _fc.CityOneUpgrade, _fmt("%s,%d", user.psn, cityLevel),f) end

--[Comment]
--天降秘宝
--get：获取今日奖励，ref：刷新，slt|idx：选择
function SVR.Treasure(opt, f) _send(_svr, _fc.Treasure, _fmt("%s,'%s'", user.psn, opt),f) end


------------------------------- 内部调用 -------------------------------------------
--[Comment]
-- 内部调用
function SVR.SendIn(func, dat, f) _send(_svr, _fc.In, func, dat, f) end
--[Comment]
--进入国战
function SVR.NatEnter() _send(_svr, _fc.In, _fc.EnterNat, nil, nil) end
--[Comment]
--退出国战
function SVR.NatExit() _send(_svr, _fc.In, _fc.ExitNat, nil, nil) end
--[Comment]
--退出跨服国战
function SVR.SnatExit() _send(_svr, _fc.In, _fc.SnatExit, nil, nil) end
--[Comment]
-- 获取服务器时间
function SVR.GetSvrTime(f) _send(_svr, _fc.In, _fc.GetSvrTime, nil, f) end
--[Comment]
--七日目标
function SVR.TargetSeven(opt,f) _send(_svr, _fc.TargetSeven, _fmt("%s,'%s'", user.psn, opt),f) end
---<summary>点击地宫图标</summary>
function SVR.GveExplorerStart(f) _send(_svr, _fc.ExplorerStart, _fmt("%s", user.psn),f) end
--[Comment]
--探险匹配
--操作数含义: 0-创建队伍 1-加入队伍-队伍编号 2-离开队伍-队伍编号 3-自动匹配 4-停止自动匹配 5-踢出队伍-玩家psn 6-准备-队伍编号 7-取消准备-队伍编号
function SVR.GveExplorerMatch(gsn,flv,f) _send(_svr, _fc.ExplorerMatch, _fmt("%s,%d,%d", user.psn, gsn, flv),f) end
--<summary>领取地宫奖励</summary>
function SVR.GveExplorerReward(f) _send(_svr, _fc.ExplorerReward, _fmt("%s", user.psn),f) end
--<summary>进入地宫</summary>
function SVR.GveExplorerEntert(f) _send(_svr, _fc.ExplorerEnter, _fmt("%s", user.psn),f) end