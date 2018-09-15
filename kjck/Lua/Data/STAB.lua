stab = {}

--[Comment]
--功能存储过程
Func =
{
    --[Comment]
    --smartFox的聊天扩展命令-聊天
    Chat = "c_chat",
    --[Comment]
    --smartFox的聊天扩展命令-跨服国战聊天
    ChatSnat = "snatChat",
    --[Comment]
    --smartFox的服务器消息扩展命令
    SysMsg = "sendSYSMsg",
    --[Comment]
    --smartFox的内部调用扩展命令
    In = "c_in",

    BindThirdId = "up_py_bind_p3",          --绑定第三方帐号
    ReLogin = "up_py_relogon",              --断线重连
    Login = "up_py_logon",                  --登录
    Register = "up_py_reg",                 --注册
    GetColdTime = "up_get_py_cd",           --获取全局冷却时间
    BanChat = "up_py_chat_cd",              --禁言用户
    SelectTiroHero = "up_tyro_set",         --新手武将选择

    --[Comment]
    --用户初始更改信息
    ChangeUser = "up_py_change",
    --[Comment]
    --用户更改信息
    ChangeUserInfo = "up_py_change_inf",
    --[Comment]
    --获取用户最新数据
    UpdateUserInfo = "up_get_py_info",      --获取用户最新数据
    SyncHero = "up_get_py_char",            --同步用户武将数据
    SyncEquip = "up_get_py_equip",          --同步用户装备数据
    SyncProps = "up_get_py_props",          --同步用户道具数据
    SyncHeroSoul = "up_char_soul_ls2",      --同步将魂
    SyncGem = "up_gem_ls",                  --同步宝石
    SyncDehero = "up_get_py_dechar",        --同步用户副将数据
    SyncDequip = "up_get_py_dequip",        --同步用户军备数据
    SyncDequipSp = "up_get_py_dequip_sp",   --同步用户军备残片数据
    SyncValue = "up_get_py_value",          --同步用户价值物品列表
    SyncItem = "up_py_sync_item",           --同步具体项

    HospitalAddHP = "up_py_blood",          --医馆加血
    CureHero = "up_char_treat",             --医馆治疗武将
    AddSoldier = "up_py_conscript",         --补兵
    HeroSolder = "up_char_troop",           --武将调整兵力

    HomeUpgrade = "up_py_home_upg",         --升级主城
    PvpCityInfo = "up_pvp_city_info",       --PVP城池详情获取
    CityUpgrade = "up_py_city_upg",         --城池升级
    SearchCity = "up_py_city_seek",         --收获城池
    SearchCityBatch = "up_city_seek_1key",  --一键收获
    GetCropInfo = "up_py_crop_val",         --获取征收信息
    GetCrop = "up_py_crop_get",             --征收

    Equip = "up_equip",                     --装备操作
    EquipOption = "up_py_equip",            --装备操作
    EquipUpgrade = "up_py_equip_upg",       --装备强化
    EquipUpOnekey = "up_py_equip_upg_1key", --装备一键强化
    EquipSellBatch = "up_equip_sell_1key",  --一键卖装
    EquipPiece = "up_py_equip_sp",          --装备碎片操作
    PieceSellBatch = "up_piece_sell_1key",  --一键出售装备碎片
    EquipEvo = "up_equip_plus",             --装备进阶
    EquipExclForge = "up_equip_excl",       --专属装备锻造

    LearnSkill = "up_char_skill",           --学习技能
    SoldierOption = "up_char_arms",         --学习/使用/重置/升级兵种
    LearnLineup = "up_char_lineup",         --学习/使用/重置阵形
    LineupImprint = "up_char_lineup_ext",   --阵形铭刻操作
    HeroEvolution = "up_char_plus",         --武将觉醒
    HeroUpStar = "up_char_star",            --武将升级将星
    SkpOption = "up_char_skp",              --锦囊技操作
    SkcFeOpt = "up_skc_fe_opt",             --武将技五行操作
    OneKeyLevelUp = "up_upg_five",          --武将一键升级

    --vip每日礼包
    VipGiftDay="up_vip_evd",
    --vip每周礼包
    VipGiftWeek="up_vip_wek",

    --vip过关斩将成就领取情况
    TowerAchievement="up_ta_achive",

    --天机
    HeroSecret = "up_char_secret",          --武将天机操作
    HeroChallenge = "up_char_jxtz",         --极限挑战
    
    --副将
    DeheroOpt = "up_dechar_opt",            --副将操作
    DequipOpt = "up_dequip_opt",            --军备操作
    DequipSp = "up_dequip_sp",              --军备残片操作

    UseProps = "up_props_usex2",            --使用道具
    BuyGoods = "up_shop_prop_buy",          --用指定货币购买商品
    SoulOption = "up_char_soul",            --将魂操作
    RmbShopOption = "up_shop_rmb",          --珍宝阁操作 信息/刷新/购买
    SoulShopOption = "up_shop_soul",        --魂币商店操作 信息/刷新/购买
    NatShopOption = "up_shop_nat",          --国战商城
    FantsyShopOption = "up_shop_hj",        --幻境商城操作
    PeakShopOption = "up_shop_df",          --巅峰商城操作

    TavernInfo = "up_tavern_info",          --获取酒馆信息
    ReTavern = "up_tavern_renew",           --刷新酒馆信息
    TavernOption = "up_tavern_opt",         --酒馆操作
    Tavern = "up_tavern",                   --酒馆

    QuestList = "up_py_task_lst",           --获取任务列表数据
    QuestCompleted = "up_py_task_rw",       --完成任务获取奖励
    QuestSide = "up_py_ottask_rw",          --完成支线任务获取奖励

    GetWar = "up_gm_ext_inf",               --获取战役信息
    RefreshWar = "up_py_game_ext",          --刷新挑战次数
    GetWarReward = "up_gm_ext_rw",          --获取战役奖励
    GetLevelMap = "up_get_py_glv_info",     --获取关卡地图数据
    GetLevelFB = "up_get_fb_inf",           --获取关卡副本次数
    MoveHero = "up_py_move",                --移动武将
    SDFB = "up_fb_mop",                     --扫荡副本

    BattleReady = "up_siege_ready",         --攻城战准备
    BattleFight = "up_siege_data",          --攻城战对战
    SetSkillT = "up_char_skill_set",        --设置军师技
    BattleResult = "up_siege_ret_lz",       --攻城战结果
    SiegeCaptive = "up_siege_captive",      --攻城战招降俘虏

    GetPvpZone = "up_get_py_zone",          --获取PVP区信息
    GetTerritoryList = "up_py_city_lst",    --获取主城内政外交信息

    CountryShop = "up_nat_fisc",            --国库商品
    CountryBuyGoods = "up_nat_fisc_buy",    --国库购买

    GetRankInfo = "up_rank_ls",             --获取排行信息
    GetFameInfo = "up_lead_rank",           --获取名人堂信息
    GetPlayerInfo = "up_pvp_py_info",       --获取其它玩家信息
    PlayerList = "up_py_lst",               --玩家列表操作
    PvpRankRival = "up_py_rank_lst",        --获取演武榜信息
    RankOption = "up_ywb",                  --演武榜操作
    PlayerMsg = "up_py_msg",                --消息的操作
    GetMsgAtt = "up_py_msg_att_lz",            --获取邮件附件
    GetMsgAtt1K = "up_py_msg_att_lz",        --提取邮件附件
    FriendOption = "up_py_fans",            --好友操作
    UseExCode = "up_excode_use",            --兑换码奖励兑换
    GetReward10 = "up_py_draw10",           --10连抽
    G2C = "up_py_g2c",                      --金换银
    GetSignData = "up_sign_inf",            --签到数据
    Sign = "up_sign_in",                    --签到
    VipGift = "up_vip_rw",                  --领取VIP奖励
    RewardSeven = "up_d7rw",                --领取7日奖励
    GetGifts = "up_gifts_get",              --领取奖励接口
    GetRechargeRank = "up_rank_pay_lst",    --获取充值排行活动
    GetFundOpt = "up_fund_opt",             --开服基金操作
    ActLst = "up_act_lst",                  --通用活动列表
    ActOpt = "up_act_opt",                  --通用活动接口
    ActRedGet = "up_act_red_get",           --活动获取红包
    ActOpt108 = "up_act_opt_108",           --活动108献帝宝库
    ActOpt17 = "up_act_opt_17",             --活动17对决
    ActOpt18 = "up_act_opt_18",             --活动18消消乐
    ActOpt20 = "up_act_opt_20",             --活动20幸运号
    ActRec20 = "up_act_20_rec",             --活动20记录
    ActOpt21 = "up_act_opt_21",             --活动21
    ActOpt34 = "up_act_opt_34",             --活动34
    ActOpt36 = "up_act_opt_36",             --活动36
    ActOpt38 = "up_act_opt_38",             --活动38
    ActOpt39 = "up_act_opt_39",             --活动39
    ActOpt306 = "up_act_opt_306",           --活动306 绑定手机
    ActGetHF = "up_act_get_hf",             --获取合服活动列表

    --议事厅
    AffairOption = "up_event",              --议事厅操作
    AffairRankOption = "up_event_rank",     --议事厅排行操作

    --联盟
    AllyCreat = "up_guild_create",          --创建联盟
    AllyDisband = "up_guild_destroy",       --解散联盟
    AllyList = "up_guild_lst",              --获取联盟列表
    AllyInfo = "up_guild_info",             --获取联盟信息
    AllyMember = "up_guild_usr_lst",        --获取联盟成员列表
    AllyAnno = "up_guild_post",             --联盟公告更改
    AllyOption = "up_guild_opt",            --联盟操作
    AllyMsgBoard = "up_guild_board",        --联盟留言板
    AllyTechDev = "up_gui_tech_opt",        --联盟科技培养操作
    AllyShopOption = "up_shop_guild",       --联盟商店操作 信息/刷新/购买
    AllyQuestOption = "up_guild_task",      --联盟任务操作
    AllyReName = "up_guild_rename",         --联盟改名卡改名
    AllyBattleInfo = "up_swar_info",              --联盟战 - 获取信息
    AllyBattleEnroll = "up_swar_reg",           --联盟战 - 报名
    AllyBattleTeamInfo = "up_swar_guild_team",   --联盟战 - 获取联盟战队信息
    AllyBattleMyTeamInfo = "up_swar_my_team",       --联盟战 - 获取我的战队信息
    AllyBattleOpt = "up_swar_team_opt",                 --联盟战 - 战队操作
    AllyBattleReport = "up_swar_combat_rec",              --联盟战 - 获取战报
    AllyBattleRec = "up_swar_combat_play",                 --联盟战 - 战斗回放
    AllyBattleRank = "up_swar_rank",                          --联盟战 - 获取排行榜
    AllyBattleShop = "up_shop_swar",                       --联盟战 - 军功商城

    --借将
    AllyBorrowHeroOpt = "up_py_borr_char",      --联盟借将操作
    AllyBorrowHeroCheck = "up_py_sel_char", --查询同意借将信息（可接收的）

    --BOSS
    GetBossInfo = "up_boss_inf",            --BOSS战信息
    BossOption = "up_boss_opt",             --BOSS操作
    Boss2 = "up_boss2",                --二代BOSS操作

    PartyOpt = "up_py_yh",                --宴会

    --过关斩将
    TowerOption = "up_tower_opt",           --过关斩将操作

    --武将修炼
    Train = "up_train_opt",                 --训练操作
    Cultive = "up_char_prac",               --修炼操作

    --国战
    GetNatInfo = "up_nation_inf",        --获取国家信息
    NatHeroMove = "up_nat_char_move",   --国战武将移动
    NatSetHero = "up_nat_char_set",     --国战配置武将
    NatHero = "up_nat_char_inf",        --国战武将信息
    NatOverview = "up_nat_battle",      --国战总览信息
    NatCityInfo = "up_nat_city_inf",    --国战城池信息
    NatReport = "up_nat_rec",           --国战城池历史战斗消息
    NatFood = "up_py_food",             --国战粮草操作
    NatHeroFood = "up_char_food",       --国战武将补充粮草
    HeroRankUp = "up_char_titl_up",         --武将升军阶
    HeroRank = "up_char_titl",              --武将军阶
    UserPeerageUp = "up_py_titl_up",        --玩家升级爵位
    NatShop = "up_nat_fisc",            --国库商品
    NatBuyGoods = "up_nat_fisc_buy",    --国库购买
    NatHeroOpt = "up_nat_char_opt",     --国战武将操作
    NatReplay = "up_nat_combat_play",   --国战战斗回放
    NatSolo = "up_nat_1v1",             --国战单挑
    NatActInfo = "up_nat_task_city",    --国战活动信息
    NatOption = "up_nat_opt",           --国家操作
    NatAct = "up_nact_opt",             --国战活跃
    NatState = "up_nat_state",          --国战州郡操作
    -- 矿脉
    NatMine = "up_nat_mine",            --国家矿脉操作
    -- 血战
    NatBlood = "up_nat_blood",          --血战操作
    TechPersonal = "up_nat_py_tech_opt",    --帝国个人科技
    NatDaily = "up_nat_daily",          --国战日常

    --内部操作
    HeartBeat = "in_heart_beat",            --内部事件通知
    InternalEvent = "in_event",             --内部事件通知
    GetSvrTime = "get_svr_time",            --获取服务器时间
    CalcNatBattle = "in_nat_combat",    --计算战斗结果
    EnterNat = "in_nat_enter",      --进入国战地图
    ExitNat = "in_nat_exit",        --退出国战地图
    NatBattle = "up_nat_combat",        --国战战斗广播
    CityChange = "in_city_change",          --国战城池发生变化
    CalcSwarBattle = "in_swar_combat",      --计算战斗结果

    --占卜
    DivineOption = "up_turn2_opt",          --占卜相关操作
    DivineRank = "up_turn2_rank",           --占卜排名

    --秘境巡游
    FamOption = "up_secret",                --秘境操作
    FamReward = "up_secret_rw",             --秘境通关奖励

    --宝石
    GemOption = "up_gem_opt",               --宝石操作

    CityOneUpgrade = "up_py_1key_city_upg", --城池一键升级
    Treasure = "up_act_308",                --天降秘宝

    --乱世争雄
    ClanWar = "up_game_lszx",               --获取乱世争雄操作

    --成就
    Achievement = "up_achievement",         --成就操作

    --等级 限时礼包
    GiftOpt = "up_get_gift",                --等级 限时礼包 操作

    --通用物品回收
    ItemSell = "up_item_sell",              --通用出售
    ItemMelt = "up_item_melt",              --通用熔铸

    --实名验证
    Verify = "up_py_verify",                --实名验证
    VerifySDK = "up_py_verify_sdk",            --实名验证
    VerifyCharge = "up_charge_verify",      --充值验证

    QuickOpt = "up_quick_opt",
    TiroStep = "up_py_tiro_step",

    --跨服国战
    SnatOpt = "up_snat_opt",                --跨服国战操作
    SnatEnter = "up_snat_enter",            --跨服国战进入数据
    SnatCity = "up_snat_city",              --跨服国城池信息
    SnatRec = "up_snat_rec",                --跨服国战报
    SnatReplay = "up_snat_replay",          --跨服国回放
    SnatSolo = "up_snat_solo",              --跨服国单挑
    SnatHeroInf = "up_snat_char_inf",       --跨服国战武将列表
    SnatHeroSet = "up_snat_char_set",       --跨服国战武将部署
    SnatHeroMove = "up_snat_char_move",     --跨服国战武将移动
    SnatHeroOpt = "up_snat_char_opt",       --跨服国战武将操作
    SnatRank = "up_snat_rank",              --跨服国战排行数据
    SnatExit = "in_snat_exit",              --跨服国战退出地图
    SnatCalcBattle = "in_snat_combat",      --跨服国战计算战斗

    --意见反馈
    SuggestOpt = "up_py_feedback",

    --日常
    DailyOpt = "up_daily",                  --日常操作
    -- 宴会
    Feast = "up_feast",                     --宴会
    --铜雀台
    Beauty = "up_beauty",                   --铜雀台

    --TCG
    TcgLogin = "up_tcg_login",              --TCG登录信息
    TcgMatch = "up_tcg_match",              --TCG匹配信息
    TcgOpt = "up_tcg_opt",                  --TCG操作

    -- 考试
    Exam = "up_exam",                       --考试初始信息
    ExamOpt = "up_exam_opt",                --考试操作
    ExamRank = "up_exam_rank",              --考试排名

    --幻境挑战
    Fantsy = "up_fantsy",                   --幻境挑战
    FantsySL = "up_fantsy_sl",              --幻境挑战兵种阵型

    --跨服 pvp
    PeakInfo = "up_srank_inf",              --跨服 PVP 信息
    PeakRank = "up_srank_rank",             --跨服 PVP 排行
    PeakJoin = "up_srank_reg",              --跨服 PVP 参赛
    PeakHero = "up_srank_char",             --跨服 PVP 配置武将
    PeakRival = "up_srank_opp",              --跨服 PVP 对手
    PeakRivalHero = "up_srank_opp_char",    --跨服 PVP 对手武将
    PeakFight = "up_srank_fight",           --跨服 PVP 战斗
    PeakFightRead = "up_srank_fight_read",  --跨服 PVP 战斗已读
    PeakReport = "up_srank_rec",            --跨服 PVP 战报
    PeakReplay = "up_srank_replay",            --跨服 PVP 回放
    PeakReportDetail = "up_srank_rec_dtl",  --跨服 PVP 战报详情
    PeakCalcBattle = "in_srank_combat",     --跨服 PVP 计算战斗 

    --地宫系统 GVE
    GveMatch = "up_exp_mat",                --组队匹配
    GveStart = "up_exp_start",              --点击地宫按钮发送开始命令
    GveCreate = "up_exp_create",            --创建地宫
    GveEnter = "up_exp_enter",              --进入地宫
    GveShowInfo = "up_exp_show",            --获取房间信息
    GveFriendList = "up_exp_fan_lst",       --获取好友列表
    GveInvite = "up_exp_fan_inv",           --邀请好友组队
    GveSetHero = "up_exp_chose",           --部署地宫武将
    GveAttack = "up_exp_march",             --点行军按钮发送命令
    GveHeroMove = "up_exp_char_move",       --武将移动命令
    GveReport = "up_exp_rec",               --获取战报信息
    GveCheckInfo = "up_exp_spy",            --侦察命令
    GveRecruitCD = "up_exp_zm_cd",          --获取招募按钮CD时间 
    GveRank = "up_exp_week_rk",             --地宫周排名信息
    GveCheckInvite = "up_exp_fan_cst",      --获取邀请信息
    GveLeave = "up_exp_giveup",              --退出地宫命令
    GveBattleReady = "up_exp_siege_ready",  --地宫战斗准备
    GveBattleFight = "up_exp_siege_data",   --地宫战斗数据
    GveBattleResult = "up_exp_siege_ret_lz",--地宫战斗结果

    --征战相关
    ExpeditionBox = "up_get_py_glv_info_lz",--征战宝箱

    OnlineOpt = "up_online_rw",             --在线奖励
    VipLvGiftStu = "up_py_vip_lz",          --在线奖励

    GetSoloRank = "up_rank_py_lst",         --获取竞技场中的排行
    GetDefendHero = "up_rk_hr",             --获取驻守武将
    RenownRewardOp = "up_jf_rank_rw",       --积分奖励操作（查询、领取、一键领取）
    RankRewardOp = "up_ywb_rw",             --排行奖励
    SoloRewardShop = "up_ywb_shop",         --竞技场声望商城

    --过关斩将
    TowerOption = "up_tower_opt",           --过关斩将操作
    TowerDeploy = "up_tower_bus",           --过关斩将部署

    AddVIT = "up_py_tl",              --补充体力
    AddWine = "up_py_wine",              --补充体力

    Turntable = "up_sup_turn",              --转盘（战役）
    SignCumRewardInf = "up_sign_lq",              --累计签到奖励

    Treasure = "up_act_308",                --天降秘宝

    TargetSeven = "up_target_7",                --七日目标

}

-- 熔铸操作结果
stab.S_ItemRecycle =
{
    -- 操作码
    "opt",
    -- 附加值(某些操作可能会有)
    "vals",
    -- 按操作码返回的销毁物品标识列表
    -- <para>(稀有度的为稀有度列表，具体物品列表的为SN列表)</para>
    "item",
    -- 奖励接口
    "rws",
}

stab.S_ArrayData = {
    "array"
}

--[Comment]
-- 服务器返回的玩家信息
stab.UserInfo =
{
    "rsn",          --上次登录的服务器SN
    "psn",          --用户SN
    "nick",         --账号名称
    "role",         --用户角色
    "ava",          --用户头像
    "htsn",         --用户称号
    "hlv",          --主城等级
    "exp",          --主城经验
    "vip",          --VIP等级
    "gold",         --金币
    "coin",         --银币
    "tp",           --当前兵力
    "hp",           --当前血池
    "gsn",          --联盟SN
    "gnm",          --联盟名称
    "nsn",          --国家编号
    "loginQty",     --登录次数
    "key",          --密钥
    "zone",         --玩家PVP地图中的区号
    "pos",          --玩家PVP地图区中的位置
    "seven",        --7天登录奖励的领取情况
    "regTm",        --玩家注册日期
    "age",          --玩家年龄(>0有效，否则未认证)
    "vit",          --玩家当前体力值
    "rtnTm",        --回归时间
    "rtnDay"        --回归天数
}
--[Comment]
--占领信息
stab.S_OccInfo =
{
    "citySN",       --占领城池的全局位置
    "time",         --剩余占领时间
}
--[Comment]
--全局冷却时间及限制
stab.S_ColdTime =
{
    "svrTm",        --服务器时间戳
    "tpQty",        --征兵次数
    "tpFreeQty",    --免费征兵的次数
    "tpTotal",      --总征兵次数
    "warQty",       --战役挑战次数
    "g2cQty",       --金换银总次数
    "g2cUsed",      --金换银已用次数
    "chatBanTm",    --禁言时间
    "occInfo",      --占领城池信息
    "rw1Tm",        --1次寻宝免费冷却
    "rw10Tm",       --10次寻宝免费冷却
    "drw1Tm",       --副将1次寻宝免费冷却
    "drwQty",       --副将寻宝剩余出副将次数
    "bossTm",       --BOSS开启时间
    "trainTm",      --武将修炼时间
    "jbpTm",        --聚宝盆时间
    "fbSdQty",      --副本免费扫荡次数
    "fbSdPrice",    --副本扫荡价格
    "rechargeRankTm",--充值排行活动剩余时间
    "warBeginDate", --战役开始时间
    "warEndDate",   --战役结束时间
    "dvnQty",       --免费占卜次数
    "fundTm",       --基金剩余时间
    "famQty",       --秘境剩余次数
    "flagTm",       --夺旗战开启时间
    "snatBginTm",   --跨服国战开启时间
    "vitCount",     --已购买体力次数
    "vitTotal",     --总可购买体力次数
    "vitPrice",     --当前购买体力价格
    "barbarianTime",--蛮族入侵开启时间
    "atkAndDefTime",--攻守兼备(限时)开启时间—王伊烽
    --"trainHero",    --训练武将


    occInfo = stab.S_OccInfo
}

--[Comment]
--用户信息的更新
stab.UserInfoUpdate =
{
    "gold",         --金币
    "coin",         --银币
    "rmb",          --人民币积分
    "soul",         --魂币
    "hp",           --血
    "tp",           --兵
    "rank",         --排名
    "score",        --实力
    "questQty",     --可完成的任务数
    "occ",          --占领者PSN
    "newMsgNum",    --新消息数
    "vipExp",       --VIP经验
    "vip",          --VIP等级
    "sign",         --是否已经签到(0=未签 1=已签)
    "mcard",        --月卡剩余天数
    "vipGiftLv",    --可领取的VIP礼包等级
    "vipGiftRec",   --购买VIP礼包的记录
    "tech",         --玩家科技
    "ttl",          --爵位
    "merit",        --功勋
--    "ttlGiftLv",    --可领取的爵位礼包等级
--    "salary",       --是否已领取爵位俸禄(0=未领 1=已领)
    "allyPerm",     --我在联盟中的职位
    "natPerm",       --我在国家中的职位
    "hlv",          --主城等级
    "exp",          --主城经验
    "vit",          --当前体力值
    "nsn",          --国家编号
    "zone",         --PVP地图编号
    "pos"           --PVP地图位置
}
--[Comment]
--用户更改信息返回结果
stab.S_UserInfoChange =
{
    "nick",         --昵称
    "role",         --角色
    "ava",          --头像
    "htsn",         --称号
    "rws",          --奖励接口
}

--[Comment]
-- 签到奖励
stab.S_SignReward =
{
    -- 需要的VIP等级
    "vip",
    -- 倍率
    "rate",
    -- 奖励对象
    "rw",
    
}
--[Comment]
-- 签到数据
stab.S_SignInfo =
{
    -- 当前月份
    "month",
    -- 是否已经签到(0=未签 1=已签)
    "isSign",
    -- 当月签到次数
    "signQty",
    -- 当月已过多少天
    "day",
    -- 补签价格
    "price",
    -- 奖励接口
    "rws",

    rws = stab.S_SignReward
}
--[Comment]
-- 签到返回
stab.S_Sign =
{
    -- 货币
    "money",
    -- [0=是否已经签到(0=未签 1=已签) 1=签到次数 2=补签价格]
    "info",
    -- 奖励接口
    "rws",
}

--[Comment]
--Vip等级礼包领取状态
stab.S_VipLvGiftStu = {
    "vip",
    "total",
    "stat",
    "rws",
}

-- VIP礼包领取接口
stab.S_VipGift =
{
    -- 领取的礼包等级
    "giftLv",
    -- 当前玩家的VIP等级
    "vipLv",
    -- 奖励接口
    "rws",
}

------------------武将、装备、道具等信息及同步------------------
--[Comment]
-- 武将同步数据
stab.S_Hero =
{
    "sn",           --SN 10
    "dbsn",         --DBSN 5
    "evo",          --武将等阶 2
    "star",         --武将星级 2
    "lv",           --等级 3
    "exp",          --经验 10
    "baseStr",      --武力 4
    "baseWis",      --智力 4
    "baseCap",      --统帅 4
    "hp",           --当前HP 4
    "baseHP",       --最大HP 4
    "sp",           --当前SP 4
    "loyalty",      --当前忠诚 3
    "tp",           --当前兵力 3
    "arm",          --当前兵种 2
    "armLst",       --可用兵种列表 
    "armLv",        --可用兵种等级列表 
    "lnp",          --当前阵形  2
    "lnpLst",       --可用阵形列表 
    "lnpExtQty",    --可用阵形的铭刻数列表 
    "loc",          --所在城市 2
    "skc",          --武将技解锁数 2
    "skt",          --军师技解锁数 2
    "ttl",          --武将军阶
    "merit",        --武将功勋
    "xlAtt",        --修炼获得的属性[0=武，1=智，2=统，3=血](五星以下的武将为NULL)
    "skp",          --当前锦囊技
    "skpLst",       --锦囊技列表
    "skpLv",        --锦囊技等级列表
    "slv",          --天机等级
    "sksLst",       --天机技能列表
    "fe",           --武将技五行数据
    "isTraining",   --是否在训练中
    "pvpCity",      --争霸里驻守的城池
    "borrow",       --借将[0:未借出  1:借过来的 2:借出去还未被接收的 3:已借出的]
    "fatig",        --疲劳值
    "isTower"       --武将是否部署在决斗
}
--[Comment]
-- 装备同步数据
stab.S_Equip =
{
    "sn",           --唯一编号
    "dbsn",         --DB编号
    "lv",           --等级
    "csn",          --所属武将
    "ecAtt",        --幻化属性
    "evo",          --等阶
    "evoExp",       --等阶熟练度
    "gems",         --镶嵌的宝石
    "exclStar",     --专属星级
    "ecRst"         --幻化已淬炼次数
}
--[Comment]
--副将同步数据
stab.S_Dehero =
{
    "sn",           --编号
    "dbsn",         --DBSN
    "csn",          --所属武将
    "exp",          --经验
    "lv",           --等级
    "star",         --星级
    "point",        --当前技能点
    "pointMax",     --最大技能点
    "equips",       --副将装备(不用)
    "skd"           --副将技能
}
--[Comment]
-- 军备同步数据
stab.S_Dequip =
{
    "sn",           --编号
    "dbsn",         --DBSN
    "dcsn",         --所属副将
    "lv",           --等级
    "att",          --洗炼属性
    "attLv"         --洗炼等级
}


-------------------城池操作-------------------
--[Comment]
-- 关卡城池信息
stab.S_LevelCity =
{
    -- 城池编号
    "sn",
    -- 城池等级
    "lv",
    -- 城池武将数
    "heroQty",
    -- 城池副本剩余次数
    "fbQty",
    -- 副本通关最高难度
    "fbDif",
    -- 距离上次搜索的间隔时间
    "tm",
    -- 活动副本奖励(不为空=是活动副本 else=不是)
    "actRws",
}
--[Comment]
-- 玩家通关记录
stab.S_LevelMapInfo =
{
    -- 最高关卡
    "gmMaxLv",
    -- 最高城池编号
    "gmMaxCity",
    -- 当前关卡
    "gmLv",
    -- [[城池唯一编号，城池等级，城池经验，武将数，副本剩余次数，副本通关的最高难度，收获后的时间差]...]
    "mapInfo",
    -- 未招募的俘虏
    "captive",

    mapInfo = stab.S_LevelCity
}
--[Comment]
-- 城池升级结果
stab.S_CityUpgrade =
{
    -- 城池等级
    "lv",
    -- 剩余银币
    "coin"
}
--[Comment]
-- 主城升级
stab.S_HomeUpgrade =
{
    -- 城池等级
    "lv",
    -- PVP城池编号
    "pvpCity",
    -- 剩余银币
    "coin"
}
--[Comment]
-- 城池副本信息
stab.S_CityFB =
{
    -- 城池编号
    "sn",
    -- 副本通关的最高难度
    "fbDif",
    -- 副本剩余次数
    "fbQty",
    -- 活动副本奖励(不为空=是活动副本 else=不是)
    "actRws",
    -- 可扫荡难度（挑战赢了哪个难度，判断是否能扫荡。0：都没过，1：过简单，2：过普通，3：过困难）
    "diffLv",
}
--[Comment]
-- 副本扫荡结果
stab.S_FBSD =
{
    -- 副本剩余次数
    "fbQty",
    -- 副本免费扫荡次数
    "fbSdQty",
    -- 副本扫荡价格
    "fbSdPrice",
    -- 玩家剩余金币
    "gold",
    -- 玩家剩余银币
    "coin",
    -- 玩家剩余积分
    "rmb",
    -- 奖励接口
    "rws",
    -- 玩家剩余体力
    "vit",
}

--region 医馆及兵力
--[Comment]
-- 医馆补血
stab.S_HospitalAddHP =
{
    -- 医馆剩余治疗点
    "hp",
    -- 玩家剩余金币
    "gold"
}
--[Comment]
-- 医馆治疗
stab.S_HospitalCure =
{
    -- 医馆剩余治疗点
    "hp",
    -- 武将HP列表
    "heroHP"
}
--[Comment]
-- 征兵
stab.S_AddSoldier =
{
    -- 剩余士兵数
    "tp",
    -- 玩家剩余银币
    "coin",
    -- 今日补兵次数
    "qty"
}
--[Comment]
-- 武将配兵
stab.S_HeroSolder =
{
    -- 武将SN
    "csn",
    -- 武将当前兵力
    "tp",
    -- 玩家当前兵营兵力
    "ptp"
}
--endregion

-- 装备相关
--[Comment]
-- 装备操作结果
stab.S_EquipOpt =
{
    -- 装备数据
    "equip",
    -- 奖励接口
    "rws",

    equip = stab.S_Equip,
}
--[Comment]
-- 装备操作结果
stab.S_EquipOption =
{
    -- 操作符 sell=出售 up=装备 down=卸下 hh=幻化
    "opt",
    -- sell[装备SN，剩余银币] up[武将SN，装备SN] down[武将SN，装备位置] hh[装备SN] slot[装备SN] gem[装备SN，宝石SN，位置]
    "vals",
    -- 出售装备时获得的道具
    "rws",
}
--[Comment]
-- 装备强化结果
stab.S_EquipUpgrade =
{
    -- 强化的装备编号
    "esn",
    -- 装备当前的等级
    "lv",
    -- 使用道具的编号（0表示未使用）
    "prop",
    -- 玩家剩余银币
    "coin",
    -- 玩家剩余金币
    "gold"
}
--[Comment]
-- 一键批量出售装备结果
stab.S_EquipSellBatch =
{
    "qty",
    "rws",
}
--[Comment]
-- 装备碎片的操作
stab.S_EquipPiece =
{
    -- 操作码
    "opt",
    -- 奖励借接口
    "rws",
}
--[Comment]
-- 装备进阶结果
stab.S_EquipEvo =
{
    --装备编号
    "esn",
    --熟练度
    "exp",
    --道具数量
    "propQty",
    --当前银币
    "coin",
    --当前金币
    "gold",
    --消耗列表(<0装备 >0道具)
    "useLst"
}
--[Comment]
-- 专属装备锻造结果
stab.S_EquipExclForge =
{
--装备SN
    "esn",
    --消耗的装备SN
    "cesn",
    --专属星级
    "exclStar",
    -- [金，银，积分]
    "money",
    --奖励接口
    "rws",
}

----------------技能、兵种、阵形相关----------------
--[Comment]
-- 锦囊技操作返回
stab.S_SkpOpt =
{
    -- 武将编号
    "csn",
    -- 当前装备的锦囊技
    "skp",
    -- 锦囊技列表
    "skpLst",
    -- 锦囊技等级列表
    "skpLv",
    -- 消耗型奖励接口
    "rws",
}
--[Comment]
-- 学习技能结果
stab.S_LearnSkill =
{
    -- 武将编号
    "csn",
    -- 武将技解锁数
    "skc",
    -- 军师技解锁数
    "skt",
    -- 剩余银币
    "coin"
}
--[Comment]
-- 学习兵种结果
stab.S_ArmOpt =
{
    -- 操作码 buy=学习 use=使用 set=重置 upg=升级
    "opt",
    -- 武将编号
    "csn",
    -- 解锁的兵种编号
    "arm",
    -- 剩余银币
    "coin",
    -- 剩余金币
    "gold"
}
--[Comment]
-- 学习阵形结果
stab.S_LearnUseLnp =
{
    -- 操作码 buy=学习 use=使用
    "opt",
    -- 武将编号
    "csn",
    -- 解锁的阵形编号
    "lnp",
    -- 剩余银币
    "coin",
    -- 剩余金币
    "gold"
}
--[Comment]
-- 阵形铭刻操作(信息，铭刻，重铸)
stab.S_LnpImp =
{
    -- 当前操作(信息:inf, 铭刻:upg, 重置:set|锁定的条目索引号序列[1,2,3])
    "opt",
    -- 武将编号
    "csn",
    -- 阵形索引
    "lnpIdx",
    -- 剩余符文
    "rune",
    -- 剩余银币
    "coin",
    -- 剩余金币
    "gold",
    -- 剩余积分
    "rmb",
    -- 铭刻的属性字符串
    "imp"
    -- 铭刻的属性数组
    --  string[] imprint { get { return string.IsNullOrEmpty(imprintStr) ? null : imprintStr.Split('|'), } }
}


--region 任务相关
--[Comment]
-- 任务列表
stab.S_QuestList =
{
    -- 可完成任务数量
    "doneQty",
    -- [编号，完成值，编号，完成值...]
    "lst"
}
--endregion

-- 战斗相关
-- 战斗回放
stab.S_BattleDataRec =
{
    "ver",
    "ret",
    "dat"
}
-- 单挑结果
stab.S_BattleSoloResult =
{
    "winner",
    "loser",
    "rec",

    rec = stab.S_BattleDataRec
}

--[Comment]
-- 战斗结算武将数据
stab.S_BattleResultHero =
{
    "csn",
    "lv",
    "exp",
    "hp",
    "sp",
    "tp",
    "loyalty"
}
--[Comment]
-- 战斗结算
stab.S_BattleResult =
{
    -- 战斗类型 0=新手模拟战 1=攻城 2=战役 3=PVP攻城 4=副本 5=演武榜 6=BOSS战 7=过关斩将 8=国战 9=乱世争雄  10=极限挑战 11=矿脉战 12=幻境挑战 13=二代BOSS
    "kind",
    -- 攻城/副本=攻占城池编号，战役=战役子关卡编号，PVP为城池位置号，演武榜为玩家编号，过关斩将为关卡编号，乱世争雄为副本编号
    "sn",
    -- 结果 0=失败 1=胜利
    "ret",
    -- 我方武将信息
    "heros",
    -- 奖励接口
    "rws",
    -- 俘虏DBSN列表
    "captive",
    -- 附加数据
    "add",

    heros = stab.S_BattleResultHero,
}
--[Comment]
-- 俘虏操作
stab.S_SiegeCaptive =
{
    -- 操作码 conv=招降，kill=斩杀，free=流放
    "opt",
    -- 俘虏城号
    "city",
    -- 俘虏DBSN
    "dbsn",
    -- 招降成功后 俘虏的SN
    "csn"
}
--[Comment]
-- 玩家战役信息
stab.S_WarInfo =
{
    -- 剩余挑战次数
    "leftQty",
    -- 剩余挑战令
    "leftTicket",
    -- 全部战役
    "wars",
    -- 当前可挑战的战役
    "available",
    -- 挑战记录
    "record",
    --奖励
    "rws",
}
--[Comment]
--玩家刷新战役结果
stab.S_RefreshWar =
{
    -- 剩余金币
    "gold",
    -- 剩余银币
    "coin",
    -- 当前战役挑战次数
    "warQty"
}

--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

--region 酒馆相关
--[Comment]
--酒馆信息
stab.S_TavernInfo =
{
    -- 10连抽冷却时间
    "rw10Tm",
    -- 剩余刷新时间
    "time",
    -- 玩家剩余金币
    "gold",
    -- 玩家剩余银币
    "coin",
    -- 武将DB列表[3]
    "heros",
    -- 武将好感度[3]
    "good",
    --奖励接口
    "rws",
}
--[Comment]
-- 酒馆操作返回
stab.S_TavernOpt =
{
    -- 玩家剩余金币
    "gold",
    -- 玩家剩余银币
    "coin",
    -- 武将好感度
    "good",
    -- 奖励接口
    "rws",
}
--[Comment]
-- 物品结构
stab.S_TavernItem =
{
    --[Comment]
    --编号
    "sn",
    --[Comment]
    --奖励对象
    "rewards",
    --[Comment]
    --购买/招募价格[银，金，钻]
    "price",
    --[Comment]
    --加幸运值价格[银，金，钻]
    "luckPrice",
}
--[Comment]
-- 酒馆新结构
stab.S_Tavern =
{
    -- 自动刷新剩余时间
    "refCd",
    -- 当前各物品幸运值
    "luck",
    -- 物品结构
    "item",
    -- 返回的奖励接口
    "rewards",
    item = stab.S_TavernItem,
}
--[Comment]
-- 10连抽结果
stab.S_Reward10 =
{
    -- 副将寻宝产出副将的次数
    "dhQty",
    -- 冷却时间[金币1次,金币10次，副将1次]
    "cds",
    -- 通用货币同步
    "money",
    -- 奖励接口
    "rws",
}
--endregion

--region 商城/道具相关
--[Comment]
-- 购买道具的结果
stab.S_BuyResult =
{
    "sn",-- 道具编号
    "qty",-- 购买数量
    "gold",-- 剩余金币
    "coin",-- 剩余银币
    "rmb",--钻石（积分）
}
--[Comment]
-- 使用道具
stab.S_UseProps =
{
    "sn",-- 道具编号
    "leftQty",-- 道具剩余数量
    "usedQty",-- 道具使用数量
    "rws",-- 奖励接口
}

--[Comment]
-- 使用多个道具（一键升级）
stab.S_UseMoreProps =
{
    "level",-- 道具编号
    "useProps",-- 道具剩余数量
    useProps = stab.S_UseProps,
}
--[Comment]
-- 金换银结果
stab.S_G2C =
{
    -- 总次数
    "qty",
    -- 已用次数
    "usedQty",
    -- 玩家金币
    "gold",
    -- 玩家银币
    "coin"
}
--[Comment]
-- 购买礼包数据
stab.S_BuyGift =
{
    "gold",-- 剩余金币
    "coin",-- 剩余银币
    "rws",-- 奖励接口
}
--[Comment]
-- 珍宝阁商品信息
stab.S_RmbShopGoods =
{
    -- 奖励对象
    "rw",
    -- 商品编号
    "sn",
    -- 商品金币价格
    "gold",
    -- 商品积分价格
    "rmb",
    -- 魂币价格
    "soul",
    -- 商品需求VIP
    "vip",
}
--[Comment]
-- 珍宝阁信息
stab.S_RmbShopInfo =
{
    -- 刷新次数
    "rfQty",
    -- 刷新CD
    "rfCD",
    -- 刷新价格（联盟商城时为联盟声望，盟战商城为积分）
    "rfGold",
    -- [0=金币 1=银币 2=积分 3=魂币 4=盟券 5=声望]
    "money",
    -- 商品列表
    "goods",
    -- 奖励接口
    "rws",

    goods = stab.S_RmbShopGoods,
}
--endregion

--region 社交相关
--[Comment]
--邮件
stab.S_Mail =
{
    "sn",
    "psn",
    "nick",
    "ava",
    "vip",
    "tm",
    -- 0旧，1新
    "isNew",
    "rws",
    "msg",
}
--[Comment]
-- 玩家信息
stab.S_PlayerInfo =
{
    "rank",
    "psn",
    "nick",
    "ava",
    "hlv",
    "vip",
    "allyName",
    "countrySN",
    "online"
}
--[Comment]
--玩家信息列表
stab.S_PlayerInfos = {
    "lst",
    lst = stab.S_PlayerInfo
}
--[Comment]
-- 玩家列表
stab.PlayerList =
{
    -- 列表类型 "fun"=好友 "score"=实力
    "kind",
    "lst",
    lst = stab.S_PlayerInfo
}
--[Comment]
--地宫积分排名信息
stab.S_PalaceRankPlayer = {
    --排名
    "rank",
    --玩家昵称
    "nm",
    --积分
    "score",
    --奖励
    "rws",
}
stab.S_PalaceRank = {
    --自己排名
    "myRank",
    --全部排名信息
    "players",
    players = stab.S_PalaceRankPlayer,
}
--[Comment]
--演武榜信息
stab.S_PvpRankInfo =
{
    --货币
    "money",
    --信息[我的排名，剩余挑战次数，已购买次数，购买价格]
    "info",
    --驻守武将
    "hero",
    --价格
    "prices",
    --目标奖励红点提示
    "rankRewardTip",
    --积分奖励红点提示
    "dayRewardTip",
}
--[Comment]
-- 玩家信息
stab.S_PlayerPvpInfo =
{
    "psn",
    "nick",
    "city",
    "ava",
    "hlv",
    "vip",
    "gsn"
}
--[Comment]
-- 排行玩家
stab.S_RankPlayer =
{
    -- 排名
    "rank",
    -- 玩家sn
    "psn",
    -- 玩家昵称
    "nick",
    -- 玩家icon
    "ava",
    -- 玩家等级
    "hlv",
    -- 玩家VIP
    "vip",
    -- 排行数据
    "val"
}
--[Comment]
-- 排行信息
stab.S_RankInfo =
{
    -- 排行数据（一般为[我的排名，我的排名数据]）
    "info",
    "lst",
    lst = stab.S_RankPlayer
}
-- 通用排行单位
stab.S_RankUnit =
{
    -- 排名
    "rank",
    -- 排行数据
    "val",
    -- 单位sn
    "sn",
    -- 单位名称
    "name",
    -- 所属服务器
    "rsn",
    -- 扩展信息
    "ext"
}
--[Comment]
-- 通用排行信息
stab.S_RankList =
{
    -- 排行数据（一般为[我的排名，我的排名数据]）
    "info",
    "lst",
    lst = stab.S_RankUnit
}
--endregion

--region PVP相关
--[Comment]
-- PVP地图玩家简短信息
stab.S_PvpCity = 
{
    -- 城池位置号 1-10 ，11与12为保留
    "pos",
    -- 玩家SN
    "psn",
    -- 城池类型 0=玩家 1=银矿 2=金矿 3=药园 4=黑市 5=农田
    "kind",
    -- 城池名称
    "nm",
    -- 联盟SN
    "gsn",
    -- 联盟名称
    "gnm",
    -- 联盟旗号
    "allyBanner",
    -- 你们旗帜
    "allyFlag",
    -- 城池等级
    "lv",
    -- 国家官级
    "ttl",
    -- 占有者SN
    "occSN",
    -- 冷却时间
    "time",
    -- 道具插旗
    "ppFlag",
    -- 道具插旗的冷却时间
    "ppFlagTm",
    -- 道具buff [sn,cd,sn,cd...]
    "ppBuf"
}
--[Comment]
-- PVP地图区数据
stab.S_PvpZone =
{
    -- 区号
    "zone",
    -- 城池列表
    "cities",

    cities = stab.S_PvpCity
}
--[Comment]
-- PVP城池详情
stab.S_PvpCityInfo =
{
    -- 占有者SN
    "occSN",
    -- 占有者
    "occNm",
    -- 城池等级
    "lv",
    -- 武将数
    "heroQty",
    -- 金币产出
    "gold",
    -- 占领时间
    "occTm",
    -- 保护时间
    "proTm",
    -- 道具插旗
    "ppFlag",
    -- 道具插旗的冷却时间
    "ppFlagTm",
    --  道具旗帜的来源
    "ppFlagSrc",
    -- 道具buff [sn,cd,sn,cd...]
    "ppBuf"
}
--endregion

stab.S_Territory =
{
    -- 城池编号
    "sn",
    -- 城池名称
    "nm",
    -- 城池等级
    "lv",
    -- 城池产出
    "crop",
    -- 城池CD时间
    "tm",
    -- 城池类型 0=玩家城池 1=银矿 2=金矿 3=药园 4=黑市 5=农田
    "kind"
}

stab.S_TerritoryList =
{
    "opt",
    "cities",

    cities = stab.S_Territory
}


--region 联盟相关
--[Comment]
-- 创建联盟结果
stab.S_CreatAlly =
{
    -- 联盟SN
    "gsn",
    -- 玩家剩余金币
    "gold",
    -- 玩家剩余银币
    "coin",
    --联盟名称
    "gnm",
    --联盟旗号
    "banner",
    --联盟旗帜
    "flag",
}
--[Comment]
-- 解散联盟
stab.S_DisbandAlly =
{
    -- 玩家剩余金币
    "gold",
    -- 玩家剩余银币
    "coin"
}
--[Comment]
-- 联盟列表单条简约信息
stab.S_AllySimple =
{
    -- 联盟SN
    "gsn",
    -- 联盟名称
    "gnm",
    -- 联盟所属国家
    "nsn",
    -- 联盟旗号
    "banner",
    -- 联盟等级
    "lv",
    -- 联盟声望
    "renown",
    -- 联盟资金
    "money",
    -- 联盟成员数
    "memberQty",
    -- 联盟盟主
    "chief"
}
--[Comment]
-- 联盟列表单页信息每页10条数据
stab.S_AllyList =
{
    -- 总联盟数量
    "qty",
    --列表
    "lst",
    lst = stab.S_AllySimple
}
--[Comment]
-- 联盟成员信息
stab.S_AllyMember =
{
    -- 玩家sn
    "psn",
    -- 玩家昵称
    "nick",
    -- 玩家等级
    "hlv",
    -- 成员的职位 0=普通成员 1=副盟主 2=盟主
    "perm",
    -- 成员的总贡献度
    "renown",
    -- 成员的周贡献度
    "renownWeek",
    --在线状态 0:离线 1:在线
    "status",
    --是否借过将 0:没有借过将 1:已借过
    "hasBorrow",
    -- 联盟成员的介绍
    "intro"
}
--[Comment]
-- 联盟成员列表单页信息每页
stab.S_AllyMemberList =
{
    -- 联盟的总成员数量
    "qty",
    --成员列表
    "lst",
    --申请加入条件 0:无限制 1:需盟主审批
    "condition",
    --好友的psn
    "friends",
    lst = stab.S_AllyMember
}
--[Comment]
-- 联盟操作的返回
stab.S_AllyOption =
{
    -- 联盟所属国家(0不用)
    "nsn",
    -- 如果联盟等级返回是0,就不要用这个数据
    "lv",
    "money",
    "renown",
    "renownWeek",
    "myRenown",
    "myRenownWeek",
    "gold",
    "coin",
    "donGold",
    "donCoin",
    -- 弹劾者
    "impName",
    -- 弹劾数据[弹劾开始时间，当前票数，需求票数，参与人数，最大人数，是否已投]，不为NULL时有效
    "impInfo"
}
--[Comment]
-- 联盟详细信息
stab.S_AllyInfo =
{
    -- 联盟编号
    "gsn",
    -- 我的职位 0=普通成员 1=副盟主 2=盟主
    "myPerm",
    -- 我的声望
    "myRenown",
    -- 我的周声望
    "myRenownWeek",
    -- 我的银票
    "myCash",
    -- 军功
    "myMerit",
    -- 联盟名称
    "gnm",
    -- 盟主
    "chief",
    -- 联盟所属国家
    "nsn",
    -- 旗号
    "banner",
    -- 旗帜
    "flag",
    -- 联盟简介
    "i",
    -- 联盟资金
    "money",
    -- 联盟等级
    "lv",
    -- 申请加入成员数量
    "pendMember",
    -- 成员数
    "mqty",
    -- 成员上限
    "maxMqty",
    -- 公告
    "anno",
    -- 联盟声望
    "renown",
    -- 联盟周声望
    "renownWeek",
    -- 租期
    "rent",
    -- 科技等级
    "tech",
    -- 金币捐献次数
    "donGold",
    -- 银币捐献次数
    "donCoin",
    -- 推荐的国家
    "remdNat",
    -- 弹劾者
    "impName",
    -- 弹劾数据[弹劾开始时间，当前票数，需求票数，参与人数，最大人数，是否已投]
    "impInfo"
}
--[Comment]
-- 联盟科技培养结果
stab.S_AllyTechDev =
{
    -- 玩家剩余金币
    "gold",
    -- 玩家剩余银币
    "coin",
    -- 培养/保存结果
    "tech"
}
--[Comment]
--联盟科技捐献信息
stab.S_AllyTechDonate =
{
    --钻石 
    "diamond",
    --银币 
    "silver",
    --金币 
    "gold",
    --联盟等级 
    "allyLv",
    --等级[0=武斗场 1=计策府 2=演兵场] 
    "levels",
    --经验值[0=武斗场 1=计策府 2=演兵场] 
    "exps",
    --自己的个人声望 
    "myRenown",
    --自己的个人周声望 
    "myRenownWeek"
}
--[Comment]
-- 联盟任务数据
stab.S_AllyQuest =
{
    -- 生成任务的唯一SN
    "sn",
    -- 任务分组
    "group",
    -- 任务稀有度
    "rare",
    -- 任务完成值
    "val",
    -- 任务所有者
    "owner",
    -- 是否完成 1=已完成，未领奖 2= 已领奖 其他=未完成
    "done"
}
--[Comment]
-- 联盟任务操作返回
stab.S_AllyQuestOption =
{
    -- 联盟任务刷新剩余时间
    "cd",
    -- 玩家剩余领取次数
    "qty",
    -- 领取任务需求的VIP等级
    "vip",
    -- 领取任务需要的积分
    "price",
    -- 联盟任务列表
    "qstLst",
    -- 我的任务列表
    "myQstLst",
    -- 奖励接口
    "rws",

    qstLst = stab.S_AllyQuest,
    myQstLst = stab.S_AllyQuest,
}
--[Comment]
-- 联盟战的联盟信息
stab.S_AllyBattle_Ally =
{
    -- 所属服务器sn
    "rsn",
    -- 联盟sn
    "gsn",    
    -- 联盟名称
    "name",
    -- 旗号
    "banner",
    -- 旗帜
    "flag",
    -- 联盟等级
    "lv",
    -- 联盟人数
    "member"
}
--[Comment]
-- 联盟战信息
stab.S_AllyBattle =
{
    -- 下次开始报名剩余时间
    "enrollTime",
    -- >0报名 else未报名
    "status",
    -- 赛季数
    "season",
    -- 轮数
    "round",
    -- 赛程时间线。0=当前服务器时间 1=报名开始时间 2=匹配开始时间 3=准备开始时间 4=行军开始时间 5=战斗开始时间 6=战斗结束时间
    "timeLine",
    -- 攻方联盟信息
    "atkAlly",
    -- 守方联盟信息
    "defAlly",
    -- 要塞战斗信息。0=战斗中 1=攻方胜利 -1=守方胜利 。分别为上中下路
    "results",

    atkAlly = stab.S_AllyBattle_Ally,
    defAlly = stab.S_AllyBattle_Ally
}
--[Comment]
-- 单个联盟玩家战队信息
stab.S_AllyBattleTeam =
{
    -- 玩家名称
    "name",
    -- 头像编号
    "icon",
    -- 玩家vip
    "vip",
    -- 国家职位
    "position",
    -- 战队数
    "teamNum",
    -- 武将数
    "heroNum",
    -- 线路
    "route"
}
--[Comment]
-- 单个武将联盟战信息
stab.S_AllyBattleHero =
{
    -- 武将SN
    "csn",
    -- 战队SN
    "tsn",
    -- 武将在战队中位置（1-5）
    "pos",
    -- 武将所在线路（1-3）
    "route",
    -- 所在战队 军师DBSN
    "advDBSN"
}
--[Comment]
-- 联盟战联盟操作返回
stab.S_AllyBattleOpt =
{
    -- 战队编号
    "tsn",
    -- 路线。1-3。0表示本次操作未改变路线
    "route",
    -- 军师DBSN。0表示未改变 
    "advDBSN",
    -- 武将SN列表(null表示为改变或解散)
    "heroSN"
}
stab.S_AllyBattleRankItem =
{
    -- 服务器编号（暂时无用因为都是同一个服务器的排名）
    "ssn",
    -- 联盟名称
    "allyName",
    -- 旗号
    "banner",
    -- 得分
    "score"
}
--[Comment]
-- 联盟战 排行榜返回
stab.S_AllyBattleRank =
{
    -- 我的排行榜信息。第一位=我盟排名，为0时表示我没有联盟 或者联盟未参战，或者联盟未得分    第二位=我盟得分
    "myRank",
    -- 排行榜数据
    "items",

    items = stab.S_AllyBattleRankItem
}
--endregion

--region ---------借将---------
--[Comment]
--别人向我发起的申请数据
stab.S_AllyBorrowHeroFromOther ={
    --玩家psn 
    "psn",
    --请求留言 
    "msg",
    --申请者名字 
    "nick",
    --申请者头像 
    "ava",
    --我是否同意 1=已同意 
    "agreed",
    --我是否拒绝 1=已拒绝 
    "refused",
    --武将的csn 
    "csn",
    --借出武将的状态 0=未处理状态,1=接受，2=拒绝 3=已召回 
    "status"
}
--[Comment]
--自已发起的申请数据
stab.S_AllyBorrowHeroApply ={
    --武将的DBSN 
    "dbsn",
    --玩家的psn 
    "psn",
    --玩家的昵称 
    "nick",
    --玩家的头像 
    "ava",
    --武将的csn 
    "csn",
    --是否已接受 0=未接收，1=已接收，2=已拒绝 ，3=被召回 
    "opt"
}
--[Comment]
--借将数据
stab.S_AllyBorrowHeroCheck ={
    --自已发起的所有申请数据
    "applies",
    --已借将次数
    "qty",
    --当天借将限制次数
    "maxQty",
    applies = stab.S_AllyBorrowHeroApply
}
--endregion

--region BOSS战
--[Comment]
-- BOSS战排行数据
stab.S_BossRank =
{
    "sn",
    "nm",
    "score"
}
--[Comment]
-- BOSS战信息
stab.S_BossInfo =
{
    "personRank",
    "allyRank",
    -- 活动开启倒计时
    "openTm",
    -- 活动结束倒计时
    "endTm",
    "coldTm",
    "cdUnitPrice",
    "att",
    "attPrice",
    "myScore",
    "myRank",
    "myAllyScore",
    "myAllyRank",
    "atkQty",

    personRank = stab.S_BossRank,
    allyRank = stab.S_BossRank
}
--[Comment]
-- BOSS战操作
stab.S_BossOption =
{
    "rmb",
    "coin",
    "att",
    "attPrice"
}
--[Comment]
-- 二代BOSS属性
stab.S_Boss2Att =
{
    "dbsn",
    "name",
    "lv",
    "exp",
    "atk",
    "wis",
    "cap",
    "ext"
}
--[Comment]
-- 二代BOSS战数据
stab.S_Boss2 =
{
    "time",
    "self",
    "ally",
    "rankPerson",
    "rankAlly",
    "bossAtt",

    rankPerson = stab.S_BossRank,
    rankAlly = stab.S_BossRank,
    bossAtt = stab.S_Boss2Att
}
--endregion

--region 武将修炼
--[Comment]
-- 武将修炼操作返回
stab.S_TrainHero =
{
    -- begin开始修炼 end结束修炼
    "opt",
    -- 修炼剩余时间
    "tm",
    -- 玩家当前银币
    "coin",
    -- 玩家当前金币
    "gold",
    -- 修炼完成的结果/武将列表
    "lst"
}
--[Comment]
-- 武将修炼操作
stab.S_HeroCultive =
{
    -- 当前修炼的武将SN
    "csn",
    -- 当前修炼的类型(1=武 2=智 3=统 4=血)
    "kind",
    -- 当前修炼状态(0=正常 1=心魔 2=结束)
    "stat",
    -- 心魔总数
    "devil",
    -- 翻牌数组(值含义：0=未翻开 1=+1 2=+2 3=+3 4=+4 5=+5 -1=心魔 -2=x2 -3=x3)
    "cards",
    -- 奖励接口,用于消耗物品
    "rws",
}
--endregion

--[Comment]
-- 副将操作
stab.S_DeheroOpt =
{
    "dcsn",
    -- 所属武将
    "csn",
    -- 等级
    "lv",
    -- 星级
    "star",
    -- 当前技能点
    "point",
    -- 最大技能点
    "pointMax",
    -- 副将装备
    "equips",
    -- 副将技能
    "skd",
    -- 奖励接口
    "rws",
}

--[Comment]
--军备操作
stab.S_DequipOpt =
{
    -- 编号
    "desn",
    -- 所属副将
    "dcsn",
    -- 等级
    "lv",
    -- 洗炼属性
    "att",
    -- 洗炼属性等级
    "attLv",
    -- 奖励接口
    "rws",
}


--region 过关斩将
--[Comment]
-- 过关斩将武将信息
stab.S_TowerHero =
{
    --武将csn
    "csn",      
    --武将dbsn
    "dbsn",
    --武将级别
    "lv",
    --官阶
    "heroRank",
    --武力值
    "str",
    --智力值
    "wis",
    --统帅值
    "cap",
    --现有生命值
    "curHP",
    --总的生命值
    "maxHP",
    --技能值
    "curSP",
    --现有兵力
    "curTP",
    --总兵力值
    "maxTP",
    --武将所在位置
    "city",
}
--[Comment]
-- 过关斩将信息
stab.S_TowerInfo =
{
    -- 玩家金币
    "gold",
    -- 玩家银币
    "coin",
    -- 玩家积分
    "rmb",
    -- 重置次数
    "resetQty",
    -- 当前关卡
    "rank",
    -- 关卡BOSS信息
    "boss",
    -- 我方武将信息
    "hero",
    -- 扫荡的奖励
    "rws",
    --通关的最高关卡记录
    "maxRank",
    --通关的最高关卡记录
    "sd",

    boss = stab.S_TowerHero,
    hero = stab.S_TowerHero,
}
--endregion

--region 武将觉醒/将星
--[Comment]
-- 武将觉醒返回
stab.S_HeroEvo =
{
    -- 武将SN
    "csn",
    -- 武将DBSN
    "dbsn",
    -- 武将等阶
    "evo",
    -- 玩家金币
    "gold",
    -- 玩家银币
    "coin",
    -- 玩家积分
    "rmb",
    -- 丹剩余数
    "propQty",
    -- 魂剩余数
    "soulQty"
}
--[Comment]
-- 将魂操作
stab.S_HeroSoulOption =
{
    -- 武将DBSN
    "dbsn",
    -- 剩余将魂
    "soulQty",
    -- 货币[0=金币 1=银币 2=积分 3=魂币]
    "money",
    -- 奖励接口
    "rws",
}
--[Comment]
--武将将星
stab.S_HeroStar =
{
    -- 武将SN
    "csn",
    -- 武将DBSN
    "dbsn",
    -- 武将当前星级
    "star",
    -- 当前货币
    "money",
    -- 消耗物品
    "rws",
}
--endregion

--region 名人堂
--[Comment]
-- 名人堂排名玩家信息
stab.S_FamePlayerInfo =
{
    -- 排名
    "rank",
    "sn",
    "name",
    -- 当前排名因素
    "fame"
}
--[Comment]
-- 名人堂信息
stab.S_FameInfo =
{
    -- 我的名人堂数据
    "myInfo",
    -- 排名数据
    "ranks",

    ranks = stab.S_FamePlayerInfo,
    
}
--endregion

-- 活动相关
stab.S_RechargeRankPlayer =
{
    "rank",
    "psn",
    "playerName",
    "pay"
}
stab.S_RechargeRank =
{
    "myRank",
    "myPay",
    "ranks",

    ranks = stab.S_RechargeRankPlayer
}
stab.S_FundOption =
{
    "coin",
    "gold",
    "rmb",
    "rws",
}

stab.S_ActRankPlayer =
{
    -- 排名
    "rank",
    -- 玩家名称
    "name",
    -- 得分
    "score"
}

stab.S_ActHstPlayer =
{
    -- 获奖玩家
    "name",
    -- 获奖得分
    "score",
    -- 奖励接口
    "rw",
    -- 获奖时间
    "time",
    -- 服务器编号
    "sevrSN"
}
--[Comment]
-- 活动数据
stab.S_ActData =
{
    -- 当前操作
    "opt",
    -- 活动编号
    "actSN",
    -- 活动全局得分
    "scoreGl",
    -- 活动时间内累积充值的金币
    "recGold",
    -- 活动时间内累积消费的金币
    "conGold",
    -- 我的排名(取排名信息时有效)
    "myRank",
    -- 活动得分
    "score",
    -- 活动领取/购买记录[aisn,qty,aisn,qty...]
    "record",
    -- 任务记录[atsn,val,rec,atsn,val,rec...]
    "task",
    -- 扩展附加数据
    "extData",
    -- 排行信息(取排名信息时有效)
    "rank",
    -- 历史获奖信息(取历史获奖信息时有效)
    "hst",
    -- 奖励接口
    "rws",
    -- 购买物品
    "rws2",

    rank = stab.S_ActRankPlayer,
    hst = stab.S_ActHstPlayer,
}

stab.S_ActRedPlayer =
{
    -- 玩家名称
    "name",
    -- 获得份额
    "part"
}
stab.S_ActRed =
{
    -- 红包SN
    "redsn",
    -- 红包DBSN
    "redbsn",
    -- 当前获得份额[>0新获得份额,else=未获得/已领取]
    "partGet",
    -- 领取记录
    "rec",

    rec = stab.S_ActRedPlayer
}

--[Comment]
-- 献帝宝库[108]活动数据
stab.S_Act108 =
{
    "lv",
    "score",
    "rws",
    "rws2",
}
--[Comment]
-- 对决[17]活动数据
stab.S_Act17 =
{
    -- 选择的角色
    "srsn",
    -- 剩余呐喊数量
    "qty",
    -- 角色状态[[角色sn，角色名次，角色分数1，角色分数2],[角色2...]]，注：角色分数若为小于零，则表示相对于玩家隐藏该分数
    "roles"
}
--[Comment]
-- 消消乐[18]活动数据
stab.S_Act18 =
{
    -- 消消乐元素[3x3]
    "element",
    -- 任务数据[IDX,VAL...]
    "ask",
    -- 消除奖励
    "rws",
    -- 必得奖励
    "rws2",
}
--[Comment]
-- 幸运号[20]活动操作数据
stab.S_Act20 =
{
    -- 信息[总号数]
    "info",
    -- 我的号码[[sn,rec,rec_get],...]
    "nums",
    -- 奖励接口
    "rws",
}


--region 国战相关
--[Comment]
-- 觐见信息
stab.S_NatCult =
{
    "opt",--操作名称
    "val",--操作val值
    -- 膜拜数量。[国主，左，右]
    "cultQty",
    -- 今日是否已经膜拜过。[左1，右2，国主9]。无固定顺序
    "isCult",
    "rws",--奖励结构
}
--[Comment]
-- 国家信息
stab.S_NatInfo =
{
    -- 国家SN
    "sn",
    -- 国家公告
    "anno",
    -- 国家等级
    "lv",
    -- 国家功勋
    "merit",
    -- 国家拥有城池数
    "cityQty",
    -- 第一联盟
    "masterAlly",
    -- 国民数量
    "member",
    -- 联盟数量
    "ally",
    -- 左，右，国王
    "master",
    -- 活跃宝箱可领取状态(0==不可领取  1==可领取)
    "boxRws",
    --下次限时任务名字
    "qnm",
    --皇帝头像编号
    "mava",
    --繁荣值
    "boom",
    --盟国
    "friendQty",
    --任务描述
    "qi",
    --任务胜利增加繁荣值
    "win",
    --任务失败增加繁荣值
    "lose",
    --国家科技提示(0=剩余点数==0   1=剩余点数>0 )
    "techTip",
    --爵位提示(0=不可晋升   1=可晋升 )
    "peerTip",
}

--[Comment]
-- 国战城池精简信息
stab.S_NatCity =
{
    -- 编号
    "sn",
    -- 守方(所属)
    "def",
    -- 攻方(>0战斗中)
    "atk",
    -- 最大buf时间
    "bufTm"
}
--[Comment]
-- 国战城池NPC信息
stab.S_NatCityNpc =
{
    "city",
    --魏
    "wei",
    --蜀
    "shu",
    --吴
    "wu",
    --蛮族下一步攻击的城池编号
    "barAtkCitySn"
}
--[Comment]
-- 国战信息总览
stab.S_NatOverview =
{
    "lv",
    "rmb",
    "food",
    "foodMax",
    "getFoodQty",
    "buyFoodQty",
    "buyFoodPrice",
    "raidTm",
--    "bloodCD",
--    "bloodTm",
--    "bloodCity",
--    "bloodPause",
    "city",
    "npc",
    "copyQty",
    --酒数量
    "wine",

    city = stab.S_NatCity,
    npc = stab.S_NatCityNpc
}

--[Comment]
-- 国战武将数据
stab.S_NatHero =
{
    "csn",
    "city",
    "food",
    "merit",
    "fatig",
}
--[Comment]
-- 国战武将数组数据
stab.S_NatHeroArray =
{
    "heros",
    heros = stab.S_NatHero,
}
--[Comment]
-- 国战活动信息
stab.S_NatActInfo =
{
    -- 神勇令CD
    "braveTokenCD",
    -- 神勇令购买价格
    "braveTokenPrice",
    -- 征召令购买价格
    "callTokenPrice",
    -- 限时任务城池
    "questCity",
    -- 夺旗战城池
    "flagCity",
    -- 征召城池
    "callCity",
    -- 夺旗战开启时间
    "flagTm",
    --蛮族入侵开启时间
    "barbarianTm"
}
--[Comment]
-- 国战观战页面单个武将数据
stab.S_NatFightHero =
{
    -- 武将SN（NPC为0）
    "csn",
    -- 武将DBSN用于显示图像
    "dbsn",
    -- 武将等级
    "lv",
    -- 武将等阶
    "evo",
    -- 武将军衔
    "ttl",
    -- 玩家名称
    "pnm",
    -- 所属国家
    "nsn",
    -- 是否是分身
    "isCopy",
    -- 时间排序数
    "sort"
}
--[Comment]
-- 国战观战页面数据
stab.S_NatFightInfo =
{
    -- [守方(国家，武将数) 攻方1 攻方2 ]
    "info",
    "atkHeros",
    "defHeros",
    -- 攻方道具BUF[SN,CD,SN,CD...]
    "atkPropsBuff",
    -- 守方道具BUF[SN,CD,SN,CD...]
    "defPropsBuff",

    atkHeros = stab.S_NatFightHero,
    defHeros = stab.S_NatFightHero
}

--[Comment]
-- 国战战斗单个武将结果数据
stab.S_NatBattleHero =
{
    -- 所属玩家SN
    "psn",
    -- 所属玩家当前的功勋
    "pmerit",
    -- 所属国家
    "nsn",
    -- 武将SN(NPC为0)
    "csn",
    -- 武将当前的功勋
    "merit",
    -- 武将当前剩余生命
    "hp",
    -- 是否是分身(0=非分身)
    "isCopy",
    --武将当前的疲劳值
    "fatig"
}
--[Comment]
-- 国战一场战斗结果
stab.S_NatBattle =
{
    -- 战斗结果(1=攻方胜 -1=守方胜)
    "ret",
    -- 战斗发生的城池SN
    "city",
    -- 城池所属国家
    "nsn",
    -- 剩余攻方武将数量
    "atkQty",
    -- 剩余守方武将数量
    "defQty",
    -- 攻方
    "atk",
    -- 守方
    "def",

    atk = stab.S_NatBattleHero,
    def = stab.S_NatBattleHero
}
--[Comment]
--战报
stab.S_NatReportUnit =
{
    -- 玩家SN
    "psn",
    -- 玩家名称
    "pnm",
    -- 玩家所属国家
    "nsn",
    -- 武将DBSN
    "dbsn",
    -- 武将官阶
    "ttl",
    -- 武将觉醒等级
    "evo",
    -- 玩家获得的功勋
    "pmerit",
    -- 武将获得的荣誉
    "merit",
    -- 是否是分身
    "isCopy"
}
--[Comment]
-- 国战城池历史消息
stab.S_NatReport =
{
    -- 消息编号
    "sn",
    -- 战斗结果（0=攻方败 1=攻方胜 2=攻方胜且夺取城池 3=攻方胜且夺取城池和旗帜）
    "ret",
    -- 时间
    "time",
    -- 城池SN
    "city",
    -- 攻方数据
    "atk",
    -- 守方数据
    "def",
    -- 附件
    "rws",
    --新旧[0:旧  1:新]
    "isNew",

    atk = stab.S_NatReportUnit,
    def = stab.S_NatReportUnit,
}

stab.S_GetFoodResult =
{
    "getFoodQty",
    "buyFoodQty",
    "buyFoodPrice",
    "food",
    "coin",
    "gold",
    "rmb"
}

stab.S_NatHeroFood =
{
    "csn",
    "food",
    "pfood"
}

stab.S_HeroRankUp =
{
    "csn",
    "ttl",
    "str",
    "wis",
    "cap",
    "hp"
}

stab.S_UserTtlUp =
{
    "ttl"
}
stab.S_NatShopGoods =
{
    -- 商品code
    "rw",
    -- 商品编号
    "sn",
    -- 金币价格
    "gold",
    -- 积分价格
    "rmb",
    -- 封赏令价格
    "token",
    -- 商品数量
    "qty",
    -- 限购次数
    "lmt",
    -- 需求的国家等级
    "natLv",
    -- 需求的VIP
    "vip",
    -- 稀有度(0=未知 1=低概率 2=中等概率 3=高概率)
    "rare",
}
stab.S_NatShop =
{
    -- 国家等级
    "natLv",
    -- 刷新次数
    "rfQty",
    -- 刷新CD
    "rfCD",
    -- 刷新价格
    "rfGold",
    -- 玩家金币
    "gold",
    -- 玩家银币
    "coin",
    -- 玩家积分
    "rmb",
    -- 玩家封赏令
    "token",
    -- 商品列表
    "goods",

    goods = stab.S_NatShopGoods
}

--[Comment]
--在线奖励数据
stab.S_OnlineReward = {
    --距下次奖励领取时间
    "tm",
    --当前可领取的奖励
    "rws",
    --可获得奖励（下一次奖励）
    "nrws",
}

stab.S_NatBuyGoods =
{
    -- 商品编号
    "sn",
    -- 剩余数量
    "qty",
    -- 玩家金币
    "gold",
    -- 玩家银币
    "coin",
    -- 玩家积分
    "rmb",
    -- 玩家封赏令
    "token",
    -- 提示（失败时显示）
    "tip",
    -- 物品code
    "rw",
}

stab.S_NatHeroMove =
{
    "raidTm",
    "rws",
}

stab.S_NatHeroOpt =
{
    "csn",
    "city",
    "food",
    "gold",
    "coin",
    "rmb",
    "token",
    "pfood",
    "copyQty"
}

-- 国战活动
stab.S_NatAct =
{
    -- 活跃度[杀敌，占城，补粮，计谋]
    "acts",
    -- 领取记录-稀有度序号
    "recRare",
    -- 领取记录-宝箱序号
    "recIdx",
    -- 奖励接口
    "rws",
}
--[Comment]
-- 州郡数据
stab.S_NatState =
{
    "nssn",
    "isAct",
    "isAtt",
    "exp",
    "notBuyExp"
}
-- 州郡操作返回数据
stab.S_NatStateOpt =
{
    "states",
    "rws",

    states = stab.S_NatState,
}

-- 国家矿脉
stab.S_NatMine =
{
    -- 矿脉唯一SN
    "mineSn",
    -- 占领者PSN
    "occPsn",
    -- 占领者名称
    "occName",
    -- 占领者头像
    "occAvatar",
    -- 战斗剩余时间
    "batTime",
    -- 驻守的武将列表
    "occHeros"
}

-- 矿脉操作
stab.S_NatMineOpt =
{
    -- 矿脉开采值(<0表示已领取)
    "mine",
    -- 征收剩余时间(<0表示未占领,或已征收)
    "pickTime",
    -- 是否攻打过
    "isOcc",
    -- 是否征收过
    "isPick",
    -- 矿脉信息列表
    "mines",
    -- 奖励接口
    "rws",

    mines = stab.S_NatMine,
}

-- 血战数据
stab.S_NatBlood =
{
    "cd",
    "time",
    "city",
    "pause",
    "rws",
}
--endregion

--region 占卜相关
--[Comment]
--占卜操作
stab.S_DivineOption =
{
    -- 玩家当前幸运点
    "lucky",
    "gold",
    "coin",
    "rmb",
    -- 免费洗牌次数
    "freeQty",
    -- 洗牌价格
    "refPrice",
    -- 当前所有卡牌SN
    "cards",
    -- 已翻牌的SN
    "sltCards",
    -- 已翻牌的位置
    "sltPos",
    -- 翻牌奖励
    "rws",
}
--[Comment]
--占卜排行
stab.S_DivineRankPlayer =
{
    "psn",
    "name",
    "lucky"
}
--[Comment]
--占卜排行
stab.S_DivineRank =
{
    "myLucky",
    "myRank",
    "rank",

    rank = stab.S_DivineRankPlayer
}
--endregion

--region 竞技场
--[Comment]
--竞技场积分奖励操作
stab.S_ReciveRenownReward = {
    --[Comment]
    --自己的积分
    "selfScore",
    --[Comment]
    --领取状态，等于0表示已经领取过了
    "reciveStatus",
    --[Comment]
    --领取到的物品
    "rewardGoods",
    --[Comment]
    --挑战失败积分增加值(挑战成功 增加值×2) 
    "increaseValue",
}
--[Comment]
--竞技场排行单个人的数据
stab.S_SoloRankPlayerInfo = {
    --排名
    "rank",
    --序列号
    "sn",
    --名字
    "nm",
    --实力分
    "score",
}
--[Comment]
--竞技场排行数据
stab.S_SoloRankInfo = {
    "ranks",
    ranks=stab.S_SoloRankPlayerInfo
}
--endregion

--[Comment]
-- 秘境巡游
stab.S_Fam =
{
    -- 秘境等级
    "lv",
    -- 当前累积功勋
    "curMerit",
    -- 下级需要功勋
    "needMerit",
    -- 通关次数
    "clearQty",
    -- 抛骰剩余次数
    "diceQty",
    -- 抛骰价格
    "dicePrice",
    -- 当前骰子点数
    "dice",
    -- 事件数据列表
    "event",
    -- 玩家位置列表
    "playerPos",
    -- 当前货币
    "money",
    -- 奖励接口
    "rws",
}
--[Comment]
-- 秘境巡游奖励
stab.S_FamReward =
{
    -- 通关次数
    "clearQty",
    -- 领奖记录
    "record",
    -- 奖励接口
    "rws",
}

--[Comment]
-- 宝石操作
stab.S_GemOption =
{
    "opt",
    "rws",
}

--[Comment]
-- 乱世争雄
stab.S_ClanWarInfo =
{
    -- 购买价格
    "price",
    -- 挑战次数
    "qty"
}

--region 议事厅
--[Comment]
-- 议事厅数据
stab.S_Affair =
{
    -- 活动SN
    "sn",
    -- 开放时间(>=0表示时间 -1=永久 其它=关闭)
    "tm",
    -- 当前值
    "val",
    -- 扩展数据 基金=[是否已购买(0=未 1=已)，购买人数]，呼朋唤友=[被招待人等级列表]
    "ext",
    -- 扩展字符串 呼朋唤友=[招待码(未达条件为空)]，友情招待=[招待人名称(未使用为空)]
    "extStr",
    -- 领奖记录/活动列表    呼朋唤友=[SN列表]
    "record",
    -- 奖励接口
    "rws",
    --可领取奖励提示[开服基金, 全民福利, 名将招募, 招贤纳仕]
    "tips"
}
--[Comment]
-- 议事厅排行数据
stab.S_AffairRankPlayer =
{
    "psn",
    "name",
    "val1",
    "val2"
}
--[Comment]
-- 议事厅排行数据
stab.S_AffairRank =
{
    -- 活动SN
    "sn",
    -- 开放时间(>=0表示时间 -1=永久 其它=关闭)
    "tm",
    -- 我的排名
    "val",
    -- 排行的玩家
    "player",

    player = stab.S_AffairRankPlayer
}
--endregion

-- 盟战相关
stab.S_SwarReportUnit =
{
    -- 所在服务器
    "rsn",
    -- 玩家SN
    "playerSN",
    -- 玩家名称
    "playerName",
    -- 武将DBSN
    "heroDBSN",
    -- 武将官阶
    "heroRank",
    -- 武将觉醒等级
    "heroEvo"
}
-- 盟战历史消息
stab.S_SwarReport =
{
    -- 消息编号
    "sn",
    -- 战斗结果(1=攻方胜,2=攻方胜且攻占线路,-1=守方胜,-2=守方胜且夺取城池和旗帜)
    "result",
    -- 线路[1-3]
    "way",
    -- 时间
    "time",
    -- 攻方数据
    "attaker",
    -- 守方数据
    "defender",

    attaker = stab.S_SwarReportUnit,
    defender = stab.S_SwarReportUnit
}

-- 成就
-- 成就数据
stab.S_Achievement =
{
    -- 成就类型
    "kind",
    -- 当前类型的所有子项SN
    "sn",
    -- 子项对应的当前完成值
    "vals",
    -- 该类型成就的领取记录(子项SN列表，有表示已领)
    "record",
    -- 奖励接口
    "rws",
}


-- 等级礼包 限时礼包
-- 限时礼包数据
stab.S_TmGift =
{
    -- SN
    "sn",
    -- 奖励字符串，需要解析
    "rws",
    -- 过期时间
    "expTime",
    -- 原价格[积分,金币,银币]
    "priceOrigin",
    -- 价格[积分,金币,银币]
    "price",
    -- 需求条件[等级需求min,等级需求max,VIP需求min,VIP需求max,爵位需求min，爵位需求max，联盟等级需求min，联盟等级需求max，武将需求，注册时间需求]
    "require"
}
-- 等级和限时礼包操作
stab.S_GiftOpt =
{
    -- 可购买的等级礼包[LV,EXP,LV,EXP...]
    "snGift",
    -- 限时礼包购买记录[sn列表]
    "tmGiftRecord",
    -- 可用的限时礼包
    "tmGift",
    -- 奖励接口
    "rws",

    tmGift = stab.S_TmGift,
}

--region 天机 极限挑战
--[Comment]
-- 天机操作返回
stab.S_HeroSecret =
{
    -- 武将SN
    "csn",
    -- 武将当前天机等级
    "slv",
    -- 武将当前天机技能列表
    "sksLst",
    -- 奖励接口
    "rws",
}
--[Comment]
-- 极限挑战操作返回
stab.S_HeroChallenge =
{
    -- 已刷新次数
    "qty",
    -- 下次刷新价格
    "refPrice",
    -- 货币同步
    "money",
    -- 可挑战列表[<0表示已挑战/已扫荡]
    "heros",
    -- 对应武将的当前难度[0-5],0表示还未挑战通过任何难度
    "diff",
    -- 奖励接口
    "rws",
}
--endregion

----------------装逼展示----------------
--[Comment]
-- 军备
stab.SS_Dequip =
{
    "dbsn",            --DBSN
    "lv",           --等级
    "att",        --洗炼属性
    "attLv"       --洗炼等级
}
--[Comment]
-- 副将
stab.SS_Dehero =
{
    "dbsn",            --DBSN
    "lv",           --等级
    "star",            --星级
    "skd",         --副将技能
    "dequip", --副将军备

    dequip = stab.SS_Dequip
}
--[Comment]
-- 装备
stab.SS_Equip =
{
    "dbsn",
    "lv",
    "evo",
    "excl",
    "gems",
    "att"
}
--[Comment]
-- 武将
stab.SS_Hero =
{
    "dbsn",-- DBSN
    "evo",-- 武将等阶
    "star",-- 武将星级
    "lv",-- 等级
    "str",-- 武力
    "wis",-- 智力
    "cap",-- 统帅
    "hp",-- 最大HP
    "loyalty",-- 当前忠诚
    "arm",-- 当前兵种
    "armLv",-- 当前兵种等级
    "lnp",-- 当前阵形
    "lnpImp",-- 当前阵形铭刻属性
    "skc",-- 武将技解锁数
    "skt",-- 军师技解锁数
    "ttl",-- 武将军阶
    "skp",-- 锦囊技
    "slv",-- 天机等级
    "equip",-- 装备
    "dehero",-- 副将
    "fes",-- 技能五行
    "gslv",-- 全局天机等级

    equip = stab.SS_Equip,
    dehero = stab.SS_Dehero
}

--region 跨服国战
-- 跨服国战基本信息
stab.S_SnatInfo =
{
    -- 所属国家
    "nsn",
    -- 玩家已粮草用量
    "food",
    -- 国家粮草上限
    "foodMax",
    -- 卖粮次数
    "buyFoodQty",
    -- 卖粮价格
    "buyFoodPrice",
    -- 今日是否可募集
    "canRaise",
    -- 活动时间[准备开始,准备结束,战斗开始,战斗结束,结束显示时间]
    "time",
    -- 奖励接口
    "rws",
}

-- 跨服国战基本数据
stab.S_SnatData =
{
    -- 所属国家
    "nsn",
    -- 粮草
    "food",
    -- 国家粮草上限
    "foodMax",
    -- 速度加成百分比
    "speed",
    -- 突袭CD
    "raidCd",
    -- 城池所属
    "cityBelong",
    -- 城池战斗状态
    "cityFight",
    -- 各国家统计[[国家编号,得分,取得的奖励城池...]...]
    "natStat",
    -- 分身使用剩余次数
    "copyQty",
    -- 计谋道具剩余使用次数，不在列表中表示禁止使用
    "propsQty"
}

-- 武将精简数据
stab.S_SnatHeroLite =
{
    -- 编号
    "csn",
    -- 所在城池
    "city",
    -- 当前血量
    "hp"
}

-- 跨服国战武将操作
stab.S_SnatHeroOpt =
{
    "csn",
    "heroCity",
    "heroFood",
    "food",
    "foodMax",
    "rws",
}

-- 武将移动返回
stab.S_SnatHeroMove =
{
    "city",
    "isFight",
    "raidCd"
}

-- 武将移动返回
stab.S_SnatHeroSolo =
{
}
-- 国战观战页面单个武将数据
stab.S_SnatCityHero =
{
    -- 所属国家
    "nsn",
    -- 武将SN（NPC为0）
    "heroSN",
    -- 是否是NPC
    "isNpc",
    -- 服务器编号
    "rsn",
    -- 玩家名称
    "playerName",
    -- 武将DBSN
    "heroDBSN",
    -- 武将等级
    "heroLv",
    -- 武将等阶
    "heroEvo",
    -- 武将军衔
    "heroRank",
    -- 武将星级
    "heroStar"
}
-- 国战观战页面数据
stab.S_SnatCity =
{
    -- 城池编号
    "city",
    -- 是否交战[1:是,0否]
    "isFight",
    -- [守方(国家，武将数) 攻方1 攻方2 ]
    "info",
    "atkHeros",
    "defHeros",
    -- 攻方道具BUF[SN,CD,SN,CD...]
    "atkPropsBuff",
    -- 守方道具BUF[SN,CD,SN,CD...]
    "defPropsBuff",

    atkHeros = stab.S_SnatCityHero,
    defHeros = stab.S_SnatCityHero
}
-- 国战战斗单个武将结果数据
stab.S_SnatBattleHero =
{
    -- 所属服
    "rsn",
    -- 所属国家
    "nsn",
    -- 所属玩家SN
    "playerSN",
    -- 武将SN(NPC为0)
    "heroSN",
    -- 是否是NPC
    "isNpc",
    -- 武将当前剩余生命
    "heroHP"
}
-- 国战一场战斗结果
stab.S_SnatBattle =
{
    -- 战斗结果(1=攻方胜 -1=守方胜 0=平局)
    "result",
    -- 战斗类型[1:攻城战，2:单挑]
    "kind",
    -- 战斗发生的城池SN
    "city",
    -- 攻方
    "attacker",
    -- 守方
    "defender",

    attacker = stab.S_SnatBattleHero,
    defender = stab.S_SnatBattleHero
}
-- 跨服国战战报单位
stab.S_SnatReportUnit =
{
    -- 所属国家
    "nsn",
    -- 玩家SN
    "playerSN",
    -- 武将SN（NPC为0）
    "heroSN",
    -- 是否是NPC
    "isNpc",
    -- 服务器编号
    "rsn",
    -- 玩家名称
    "playerName",
    -- 武将DBSN
    "heroDBSN",
    -- 武将等级
    "heroLv",
    -- 武将等阶
    "heroEvo",
    -- 武将军衔
    "heroRank",
    -- 武将星级
    "heroStar"
}
-- 跨服国战城池历史消息
stab.S_SnatReport =
{
    -- 消息编号
    "sn",
    -- 战斗结果（0=攻方败 1=攻方胜）
    "result",
    -- 时间
    "time",
    -- 城池SN
    "city",
    -- 攻方数据
    "attaker",
    -- 守方数据
    "defender",

    attaker = stab.S_SnatReportUnit,
    defender = stab.S_SnatReportUnit
}
--endregion

--region 技能五行
--[Comment]
-- 五行数据
stab.S_SkcFe =
{
    -- 技能编号
    "sksn",
    -- 当前五行
    "cur",
    -- 五行经验
    "exp",
    -- 上次获取时间(本地写入)
    "tm"
}
--[Comment]
-- 五行操作
stab.S_SkcFeOpt =
{
    -- 武将CSN
    "csn",
    -- 五行数据
    "fe",
    -- 奖励接口
    "rws",

    fe = stab.S_SkcFe,
}
--endregion

--region 铜雀台
--[Comment]
-- 美女数据
stab.S_BeautyUnit =
{
    -- 编号
    "bsn",
    -- 等级
    "lv",
    -- 星级
    "star",
    -- 当前升星经验
    "exp"
}
--[Comment]
-- 铜雀台操作数据
stab.S_Beauty =
{
    -- 结缘美女编号
    "fate",
    -- 美女数据
    "buty",
    -- 奖励接口
    "rws",

    buty = stab.S_BeautyUnit,
}
--endregion

--region 逐鹿中原
--[Comment]
-- TCG玩家项
stab.S_TcgPlayer =
{
    -- 所属服务器编号
    "rsn",
    -- 昵称
    "nick",
    -- 头像
    "avatar",
    -- 得分
    "score"
}
--[Comment]
-- TCG登录数据
stab.S_TcgPlayerInfo =
{
    -- 游戏号
    "gsn",
    -- 得分
    "score",
    -- 排名
    "rank",
    -- 当前连胜次数
    "win_streak",
    -- 前3名
    "topThree",

    topThree = stab.S_TcgPlayer
}
--[Comment]
-- TCG操作
stab.S_TcgOpt =
{
    -- 武将收集数据
    "heroCollect",
    -- 武将分组数据
    "heroGroup"
}
--[Comment]
--TCG房间信息
stab.S_TcgRoomInf =
{
    -- 游戏唯一编号
    "gsn",
    -- 房间状态 [0:空闲 1:游戏中 2:结束]
    "status",
    -- 玩家在线标记(按位)
    "onlineFlag",
    -- 当前回合数
    "curRound",
    -- 出牌超时时间(MS)
    "outExpTime"
}
--[Comment]
-- TCG武将数据
stab.S_TcgRoomHero =
{
    -- 武将DBSN
    "dbsn",
    -- 武将状态(0:未上阵 1:胜利 2:失败)
    "status",
    -- 武将出战后的武将技状态()
    "skcStatus",
    -- 武将出战后的阵营技状态()
    "skgStatus"
}
--[Comment]
-- TCG玩家数据
stab.S_TcgRoomPlayer =
{
    -- 玩家PSN(>1为玩家 <0为NPC)
    "psn",
    -- 玩家昵称
    "nick",
    -- 玩家头像
    "avatar",
    -- 玩家VIP等级
    "vip",
    -- 玩家得分
    "score",
    -- 当前生命
    "hp",
    -- 当前兵力
    "tp",
    -- 玩家武将数据
    "heros",

    heros = stab.S_TcgRoomHero
}
--[Comment]
-- TCG房间完整数据
stab.S_TcgRoom =
{
    -- 房间基本信息
    "inf",
    -- 玩家数据
    "players",
    -- 行为队列[[行为标识(参照TcgGmAct),行为数据],...]
    "actions",

    inf = stab.S_TcgRoomInf,
    players = stab.S_TcgRoomPlayer
}
--[Comment]
-- TCG游戏行为
stab.TcgGmAct =
{
    -- 无
    NONE = 0,
    -- 出战[出战，出战玩家索引，出战武将编号，携带兵力，是否爆兵]
    OUT_HERO = 1,
    -- 回合结算[回合结算，胜方玩家索引，0剩余生命，0剩余兵力，0本次出兵，0是否爆兵，0武将技状态，0阵营技状态，1剩余生命，1剩余兵力1，1本次出兵，1是否爆兵，1武将技状态，1阵营技状态]
    ROUND_RESULT = 7,
    -- 结束[结束，胜方玩家索引]
    END = 8,
    -- 同步心跳
    Sync = 32,
}
--[Comment]
-- TCG技能状态
stab.TcgSkillStatus =
{
    -- 不可用[0000]
    INVALID = 0,
    -- 位标-存在[0001]
    EXISIT = 1,
    -- 位标-附加[0010]
    ADDITIONAL = 2,
    -- 正常[0011]
    NORMAL = 3,
    -- 位标-条件[0100]
    CONDITION = 4,
    -- 激活[0111]
    ACTIVE = 7,
    -- 位标-被禁[1000]
    BAN = 8,
}
--endregion

--region 答题系统

-- 考场记录
stab.S_ExamRec =
{
    -- 累积的积分
    "rmb",
    -- 参考人数
    "qty",
    -- 答对人数
    "done",
    -- 开考日期
    "date"
}
stab.S_Exam =
{
    -- 考场编号
    "sn",
    -- 当前参考人数
    "qty",
    -- 当前累积积分
    "rmb",
    -- 考场历史记录
    "recs",

    recs = stab.S_ExamRec
}
-- 考场信息
stab.S_ExamInfo =
{
    -- 当前参考的考场
    "exam",
    -- 当前开考的考场列表
    "examList",

    examList = stab.S_Exam
}

-- 考试操作
stab.S_ExamOpt =
{
    -- 当前考场累积积分
    "rmb",
    -- 当前考场编号
    "exam",
    -- 当前考场剩余题目数量
    "qty",
    -- 当前剩余时间(>0可答题，0:超时，-1:答错)
    "time",
    -- 题目
    "question",
    -- 答案
    "answer",
    -- 奖励接口
    "rws",
}
-- 考试排名玩家数据
stab.S_ExamRankPlayer =
{
    -- 玩家服号
    "rsn",
    -- 玩家昵称
    "nick",
    -- 玩家头像
    "avatar",
    -- 玩家VIP
    "vip",
    -- 玩家最好时间
    "time"
}
-- 考试排名玩家数据
stab.S_ExamRankList =
{
    "inf",
    "lst",
    lst = stab.S_ExamRankPlayer
}
--endregion

--region 幻境挑战
--[Comment]
-- 幻境挑战武将信息
stab.S_FantsyHero =
{
    -- 武将SN
    "csn",
    -- 武力
    "str",
    -- 智力
    "wis",
    -- 统帅
    "cap",
    -- 当前生命
    "hp",
    -- 当前技力
    "sp",
    -- 当前兵力
    "tp",
    -- 拓展属性
    "extAtt",
}
--[Comment]
-- 幻境挑战数据
stab.S_Fantsy =
{
    -- 可挑战的关卡(<=0表示今日未配置武将)
    "curLv",
    -- 玩家通过的最高关卡
    "maxLv",
    -- 幻境币
    "fantsyCoin",
    -- 首通奖励领取记录(Base64字符串，按位存储)
    "firstRwRec",
    -- 完美通关记录(Base64字符串，按位存储)
    "perfectRec",
    -- 完美通过奖励领取记录(Base64字符串，按位存储)
    "perfectRwRec",
    -- 配置的武将列表
    "heros",
    -- 奖励接口
    "rws",

    heros = stab.S_FantsyHero,
}
--[Comment]
-- 幻境挑战武将兵种阵型
stab.S_FantsyHeroSL =
{
    -- 武将编号
    "csn",
    -- 兵种列表
    "armLst",
    -- 兵种等级列表
    "armLv",
    -- 阵型列表
    "lnpLst",
    -- 阵型铭刻数据
    "lnpImp",
}
--endregion

NatPerm =
{
    Master = 9,
    LeftGeneral = 1,
    RightGeneral = 2
}

-- 快捷操作
stab.S_Quick =
{
    -- 操作
    "opt",
    -- 数据
    "dat"
}

------------------跨服 PVP----------------------
--[Comment]
--巅峰信息

stab.S_PeakHero={
    --DB编号
    "dbsn",
    --是否军师(1=是) 
    "isAdv",
    --等阶
    "evo",
    --等级
    "lv"
}

stab.S_PeakPlayerInfo={
    -- 玩家 SN 
    "psn",
    -- 玩家昵称 
    "nick",
    -- 玩家服务器 SN 
    "rsn",
    -- 玩家VIP 
    "vip",
    -- 玩家头像 
    "avatar",
    -- 玩家属性 
    "attribute",
    -- 玩家分数 
    "score",
    -- 扩展值(对手列表[联盟,是否已挑战],战斗结果[胜场]) 
    "extVal",
    -- 驻守的武将(为null表示需要另行获取) 
    "heros",
    heros=stab.S_PeakHero,
}

--巅峰比赛类型
stab.S_PeakGame={
    --类型
    "kind",
    --名称
    "nm",
    --开始时间
    "otm",
    --结束时间
    "etm",
}

stab.S_Peak={
    --参赛类型(0表示未参赛,1=将军,2=帝王)
    "kind",
    --当kind>0时为当前赛事数据，否则为所有赛事的数据
    "games",
    --我的排名 
    "rank",
    --我的分数
    "score",
    --属性值
    "attribute",
    --我的防守武将
    "heros",
    --玩家排名信息
    "rankInfos",
    heros=stab.S_PeakHero,
    rankInfos=stab.S_PeakPlayerInfo,
    games=stab.S_PeakGame
}

--巅峰战斗结果
stab.S_PeakRet={
    --战斗编号
    "fsn",
    --[己方得分,对方得分,己方胜场,对方胜场]
    "score",
    --我方
    "atk",
    --对手
    "def",
    --奖励[0=获得的,其它=展示]
    "rws",
    atk=stab.S_PeakPlayerInfo,
    def=stab.S_PeakPlayerInfo,
}

--巅峰战斗战报
stab.S_PeakReport={
    --战斗编号
    "fsn",
    --结果(大于0攻方胜,小于0攻方败)
    "stat",
    --时间
    "time",
    --进攻方
    "atk",
    --防守方
    "def",
    --得分[攻方,守方]
    "score",
    atk=stab.S_PeakPlayerInfo,
    def=stab.S_PeakPlayerInfo,
}

--巅峰战斗战报细节
stab.S_PeakReportDetail={
    -- 战斗序号
    "fsn",
    -- 战斗位置
    "pos",
    -- 结果(大于0攻方胜,小于0攻方败)
    "stat",
    -- 进攻方
    "atk",
    -- 防守方
    "def",
    atk=stab.S_PeakHero,
    def=stab.S_PeakHero, 
}

----------------地宫----------------
--[Comment]
--地宫邀请信息
stab.S_GveInvite ={
    --邀请者psn
    "psn",
    --邀请者昵称
    "nick",
    --邀请时间
    "time",
    --队伍编号
    "tsn"
}

--[Comment]
--地宫玩家信息[用于匹配界面]
stab.S_GvePlayerInfo ={
    --玩家psn
    "psn",
    --玩家昵称
    "nick",
    --玩家头像
    "ava",
    --玩家实力
    "pow",
    --玩家主城等级
    "hlv",
    --准备状态[0:未准备 1:已准备]
    "status",
    --常用武将DBSN
    "hsn"
}

--[Comment]
--地宫队伍信息
stab.S_GveTeamInfo ={
    --队伍sn
    "tsn",
    --队长
    "leader",
    --队伍准备状态[0:未准备 1:已准备]
    "ready",
    --队员信息
    "member",
    member = stab.S_GvePlayerInfo
}
--[Comment]
--部署武将信息
stab.S_GveAtkHero ={
    --csn
    "csn",
    --dbsn
    "dbsn",
    --当前血量
    "hp",
    --最大血量
    "maxHP",
    --当前蓝量
    "sp",
    --最大蓝量
    "maxSP",
    --当前兵力
    "tp",
    --最大兵力
    "maaxTP",
    --状态
    "status"
}

--[Comment]
--地宫成员信息
stab.S_GveMemberInfo ={
    --玩家psn
    "psn",
    --所在城池编号
    "csn",
    --昵称
    "nick",
    --头像
    "ava",
    --金币
    "gold",
    --钻石
    "diamond",
    --普通斥候数量
    "scouts",
    --最大使用次数
    "slimited",
    --已使用次数
    "sUsed",
    --精锐斥候数量
    "elite",
    --最大使用次数
    "elimeted",
    --已使用次数
    "eUsed",
    --部署武将信息
    "atk",
    atk = stab.S_GveAtkHero
}

--[Comment]
--城池守将信息
stab.S_GveDefHero ={
    --守将sn
    "sn",
    --名字
    "nm",
    --头像
    "ava",
    --职业
    "kind",
    --当前血量
    "hp",
    --最大血量
    "maxHP",
    --当前蓝量
    "sp",
    --最大蓝量
    "maxSP",
    --当前兵力
    "tp",
    --最大兵力
    "mapTP",
    --武力值
    "strength", 
    --智力值
    "wisdom",
    --统帅值
    "captain"
}

--[Comment]
--地宫城池信息
stab.S_GveCityInfo ={
    --城池在地图上的编号
    "sn",
    --城池序号
    "csn",
    --迷雾状态[0:有迷雾 1:无]
    "visible",
    --侦察状态[0:未侦察 1:已侦察]
    "marked",
    --陷阱状态[0:无陷阱 -2:已排除 >0:有陷阱]
    "trap",
    --城池状态[0:空闲 1:已占领 2:失败 3:战斗中]
    "status",
    --城池类型[0:普通 1:有陷阱 2:BOSS]
    "citytype",
    --城池Buff
    "buff",
    --陷阱效果
    "intro",
    --守将
    "guarder",
    guarder = stab.S_GveDefHero
}

--[Comment]
--地宫信息
stab.S_GveInfo ={
    --地宫编号
    "gsn",
    --所在地宫层号
    "floor",
    --地宫所有成员信息
    "members",
    --所在层的地宫城池信息
    "infos",
    members = stab.S_GveMemberInfo,
    infos = stab.S_GveCityInfo
}

--[Comment]
--地宫战报里的武将信息
stab.S_GveFightHero ={
    --武将sn
    "sn",
    --武将名称
    "hnm",
    --武将头像编号
    "ava",
    --血
    "hp",
    --最大血
    "maxHP",
    --蓝
    "sp",
    --最大蓝
    "maxSP",
    --兵力
    "tp",
    --最大兵力
    "maxTP",
    --技能
    "skills"
}

--[Comment]
--地宫战报
stab.S_GveReport ={
    --战报编号
    "sn",
    --地宫编号
    "gsn",
    --所在地宫层数
    "fsn",
    --所在地宫城池编号
    "csn",
    --战斗时间
    "time",
    --战斗结果 [0:失败 1:胜利]
    "rst",
    --玩家昵称
    "nick",
    --攻方武将信息
    "atk",
    --守方武将信息
    "def",
    atk = stab.S_GveFightHero,
    def = stab.S_GveFightHero
}

--[Comment]
--征战宝箱奖励
stab.S_ExpeditionBoxRw ={
    -- 所领取的宝箱编号
    "boxSn",
    -- 奖励
    "rws",
    --需要通关的次数
    "needConut",
    -- 0：不能领取，1：可领取，2：已领取
    "isGet",
}

--[Comment]
--征战宝箱查询
stab.S_ExpeditionBox ={
    --地图编号
    "sn",
    --当前地图通关数
    "count",
    --宝箱奖励
    "boxRws",
    --可领取的奖励
    "rw",
    --所有可领取征战宝箱编号
    "map",
    boxRws = stab.S_ExpeditionBoxRw
}

--[Comment]
--竞技场声望商城单个商品
stab.S_SoloRenownGoods = {
    --商品id
    "id",
    --奖励对象
    "rw",
    --商品价格
    "price",
    --剩余购买的次数
    "remainBuyTimes"
}

--[Comment]
--竞技场中声望商城信息
stab.S_SoloRenownShopInfo = {
    --商品
    "gs",
    --自己的声望值
    "soloRenown",
    --购买的物品
    "rws",
    gs = stab.S_SoloRenownGoods
}

--[Comment]
--竞技场排名奖励操作
stab.S_ReciveRankReward = {
    --自己的排名
    "selfRank",
    --总收益物品
    "totalRewardsGoods",
    --总收益，已经领取过的奖励id
    "totalRewardsId",
    --奖励
    "rws",
}

--[Comment]
 --转盘（战役）
stab.S_Turntable = {
    --剩余的转盘币
    "turnCoin",
    --刷新CD
    "cdTime",
    --金币数
    "gold",
    --刷新价格
    "price",
    --转盘上的物品[编号，数量]
    "goods",
    --所得奖励档次
    "lv",
    --所得奖励
    "rws",
}

--[Comment]
--累计签到奖励领取数据
stab.S_SignCumReward = {
    --档次需要的天数
    "day",
    --当前档次奖励
    "rws",
    --奖励是否领取。0：不能领取，1：未领取，2：已领取
    "isGet"
}

--[Comment]
--累计签到奖励查询数据
stab.S_SignCumRewardInf = {
    --查询所有档次奖励,返回5组数据。。。。如果领取单个奖励，则返回1组数据
    "srws",
    srws = stab.S_SignCumReward
}

--[Comment]
--购买体力
stab.S_AddVIT = {
    --当前体力
    "vit",
    --钻石数量
    "diamond",
    --已经购买次数
    "buyQty",
    --总的购买次数
    "vitTotal",
    --当前购买价格
    "price",
    --体力回满时间
    "tm",
}
--[Comment]
--购买酒值
stab.S_AddWine = {
    --当前酒值
    "wine",
    --金币数量
    "gold",
}
--[Comment]
--帝国个人科技树
stab.S_TechP = {
    --所剩技能点
    "skillPoint",
    --技能详情[技能编号SN，技能等级]
    "techSkill",
    --重置卡数量
    "resetCard",
    --钻石数
    "rmb",
}
--
stab.S_CountryShopGoods = {
    --商品code
    "rw",
    --商品编号
    "sn",
    --金币价格
    "gold",
    --积分价格
    "rmb",
    --封赏令价格
    "token",
    --商品数量
    "qty",
    --限购次数
    "lmt",
    --需求的国家等级
    "nLv",
    --需求的VIP
    "vip",
    --稀有度(0=未知 1=低概率 2=中等概率 3=高概率)
    "rare",
}
--[Comment]
--国库
stab.S_CountryShop = {
    --国家等级
    "lv",
    --刷新次数
    "rfQty",
    --刷新CD
    "rfCD",
    --刷新价格
    "rfGold",
    --玩家金币
    "gold",
    --玩家银币
    "coin",
    --玩家积分
    "rmb",
    --玩家封赏令
    "token",
    --商品列表
    "goods",
    --剩余购买次数
    "buyQty",
    goods = stab.S_CountryShopGoods
}
--[Comment]
--国库购买
stab.S_CountryBuyGoods = {
    --商品编号
    "sn",
    --剩余数量
    "qty",
    --玩家金币
    "gold",
    --玩家银币
    "coin",
    --玩家积分
    "rmb",
    --玩家封赏令
    "token",
    --提示（失败时显示）
    "tip",
    --物品code
    "rws",
    --还剩下的购买次数
    "buyQty",
}
--[Comment]
--城池一键升级
stab.S_CityOneUpgrade = {
    --剩余银币
    "coin",
    --城池
    "players",
    players = stab.S_Territory
}
---<summary>天降秘宝</summary>
stab.S_Treasure = {
    --当前奖励编号(大于0表示未领取，小于0已领取，0无奖励)
    "sn",
    --当前选择的明日奖励索引(1 2 3)
    "tomIndex",
    --当前刷新价格
    "refPrice",
    --明日奖励列表,XML中的sn
    "tomRewards",
    --奖励接口
    "rws",
}
--<summary>七日目标</summary>
stab.S_TargetSeven = {
    --注册天数
    "day",
    --任务数据，每3个为一组（任务编号，完成度，是否完成（0：未领  >0：领取次数（已领取）））
    "qs",
    --奖励
    "rws",
}