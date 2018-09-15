local pairs = pairs
local ipairs = ipairs
local rawget = rawget
local table = table

local _get = nil
local _set = nil

--[Comment]
--国战数据
local _nat = nil
--[Comment]
--跨服国战数据
local _snat = nil

--预定义基本
local _user =
{
    --[Comment]
    --服务器SN
    rsn = 0,
    --[Comment]
    --玩家编号(不要修改)
    psn = nil,
    --[Comment]
    --昵称
    nick = nil,
    --[Comment]
    --角色
    role = 0,
    --[Comment]
    --头像
    ava = 0,
    --[Comment]
    --称号
    htsn = 0,
    --[Comment]
    --主城等级
    hlv = 0,
    --[Comment]
    --主城经验
    exp = 0,
    --[Comment]
    --VIP等级
    vip = 0,
    --[Comment]
    --金币
    gold = 0,
    --[Comment]
    --银币
    coin = 0,
    --[Comment]
    --兵营
    tp = 0,
    --[Comment]
    --医馆
    hp = 0,
    --[Comment]
    --联盟编号
    gsn = nil,
    --[Comment]
    --联盟名称
    gnm = nil,
    --[Comment]
    --国家编号
    nsn = 0,
    --[Comment]
    --登录次数
    loginQty = 0,
    --[Comment]
    --密钥
    key = nil,
    --[Comment]
    --PVP地图中的区号
    zone = 0,
    --[Comment]
    --PVP地图区中的位置
    pos = 0,
    --[Comment]
    --7天登录奖励的领取情况
    seven = nil,
    --[Comment]
    --玩家注册日期
    regTm = 0,
    --[Comment]
    --玩家年龄(>0有效，否则未认证)
    age = 0,
    --[Comment]
    --体力值
    vit = 0,
    --[Comment]
    --回归时间
    rtnTm = 0,
    --[Comment]
    --回归天数
    rtnDay = 0,

    --[Comment]
    --人民币积分
    rmb = 0,
    --[Comment]
    --魂币
    soul = 0,
    --[Comment]
    --排名
    rank = 0,
    --[Comment]
    --实力
    score = 0,
    --[Comment]
    --可完成的任务数
    questQty = 0,
    --[Comment]
    --占领者PSN
    occ = nil,
    --[Comment]
    --新消息数
    newMsgNum = 0,
    --[Comment]
    --VIP经验
    vipExp = 0,
    --[Comment]
    --是否已经签到(0=未签 1=已签)
    sign = 0,
    --[Comment]
    --月卡剩余天数
    mcard = 0,
    --[Comment]
    --可领取的VIP礼包等级
    vipGiftLv = 0,
    --[Comment]
    --购买VIP礼包的记录
    vipGiftRec = nil,
    --[Comment]
    --玩家科技
    tech = nil,
    --[Comment]
    --爵位
    ttl = 0,
    --[Comment]
    --功勋
    merit = 0,
    --[Comment]
    --可领取的爵位礼包等级
    ttlGiftLv = 0,
    --[Comment]
    --是否已领取爵位俸禄(0=未领 1=已领)
    salary = 0,
    --[Comment]
    --我在联盟中的职位
    allyPerm = 0,
    --[Comment]
    --我在国家中的职位
    natPerm = 0,

    --[Comment]
    --服务器时间戳
    svrTm = 0,        
    --[Comment]
    --征兵次数
    tpQty = 0,        
    --[Comment]
    --免费征兵的次数
    tpFreeQty = 0,    
    --[Comment]
    --总征兵次数
    tpTotal = 0,      
    --[Comment]
    --战役挑战次数
    warQty = 0,       
    --[Comment]
    --金换银总次数
    g2cQty = 0,       
    --[Comment]
    --金换银已用次数
    g2cUsed = 0,      
    --[Comment]
    --禁言时间
    chatBanTm = nil,    
    --[Comment]
    --1次寻宝免费冷却
    rw1Tm = nil,        
    --[Comment]
    --10次寻宝免费冷却
    rw10Tm = nil,       
    --[Comment]
    --副将1次寻宝免费冷却
    drw1Tm = nil,       
    --[Comment]
    --副将寻宝剩余出副将次数
    drwQty = 0,       
    --[Comment]
    --BOSS开启时间
    bossTm = nil,       
    --[Comment]
    --武将修炼时间
    trainTm = nil,      
    --[Comment]
    --聚宝盆时间
    jbpTm = nil,        
    --[Comment]
    --副本免费扫荡次数
    fbSdQty = 0,      
    --[Comment]
    --副本扫荡价格
    fbSdPrice = 0,    
    --[Comment]
    --充值排行活动剩余时间
    rechargeRankTm = nil,
    --[Comment]
    --战役开始时间
    warBeginDate = nil, 
    --[Comment]
    --战役结束时间
    warEndDate = nil,   
    --[Comment]
    --免费占卜次数
    dvnQty = 0,       
    --[Comment]
    --基金剩余时间
    fundTm = nil,       
    --[Comment]
    --秘境剩余次数
    famQty = 0,       
    --[Comment]
    --夺旗战开启时间
    flagTm = nil,       
    --[Comment]
    --跨服国战开启时间
    snatBginTm = 0,   
    --[Comment]
    --已购买体力次数
    vitCount = 0,
    --[Comment]
    --总可购买体力次数
    vitTotal = 0,
    --[Comment]
    --当前购买体力价格
    vitPrice = 0,
    --[Comment]
    --蛮族入侵开启时间
    barbarianTime = nil,
    --[Comment]
    --攻守兼备开启时间
    atkAndDefTime = nil,
    --[Comment]
    --训练武将
    trainHero = nil,


    --[Comment]
    --封赏令
    token = 0,
    --[Comment]
    --幻境币
    fantsyCoin = 0,
    --[Comment]
    --巅峰币
    peakCoin = 0,
    --[Comment]
    --当前玩家查看的关卡
    gmLv = 0,
    --[Comment]
    --玩家攻占的最高关卡/章节
    gmMaxLv = 0,
    --[Comment]
    --玩家攻占的最高城池
    gmMaxCity = 0,
    --[Comment]
    --酒馆时间
    tvrnTm = nil,
    --[Comment]
    --开采值
    mine = 0,
    --[Comment]
    --矿脉是否已被占领
    mineIsOcc = 0,
    --[Comment]
    --聊天冷却时间
    chatTm = nil,
    --[Comment]
    --分享冷却时间
    shareTm = nil,
    --[Comment]
    --酒馆武将
    tavernHero = nil,

    --[Comment]
    --武将数量
    heroQty = 0,
    --[Comment]
    --装备数量
    equipQty = 0,
    --[Comment]
    --副将数量
    deheroQty = 0,
    --[Comment]
    --军备数量
    dequipQty = 0,

    --[Comment]
    --头像
    avaLst = nil,
    --[Comment]
    --荣誉称号
    httlLst = nil,
    --[Comment]
    --道具
    props = nil,
    --[Comment]
    --武将
    hero = nil,
    --[Comment]
    --武将DB映射
    dbhero = nil,
    --[Comment]
    --装备
    equip = nil,
    --[Comment]
    --装备碎片
    eqsp = nil,
    --[Comment]
    --副将
    dehero = nil,
    --[Comment]
    --军备
    dequip = nil,
    --[Comment]
    --军备碎片
    dqsp = nil,
    --[Comment]
    --将魂
    souls = nil,
    --[Comment]
    --天机专属
    sexcl = nil,
    --[Comment]
    --宝石
    gems = nil,
    --[Comment]
    --PVE城池
    pveCity = nil,
    --[Comment]
    --PVP城池
    pvpCity = nil,
    --[Comment]
    --PVP区时间
    pvpZoneTm = nil,
    --[Comment]
    --联盟战
    swarTeam = nil,
    --[Comment]
    --活动
    act = nil,
    --[Comment]
    --国家州郡
    state = nil,

    --[Comment]
    --联盟数据
    ally = nil,
    --[Comment]
    --国家数据
    nat = nil,
    --[Comment]
    --跨服国战数据
    snat = nil,

    --[Comment]
    --铜雀台属性
    butyAtt = nil,
    --[Comment]
    --过关斩将
    towerInfo = nil,
    --[Comment]
    --战斗结果
    battleRet = nil,

    --[Comment]
    --聊天数据
    chats = nil,

    --[Comment]
    --设置器
    __newindex = function(t, k, v)
        local s = rawget(_set, k)
        if s then return s(t, v) end
        assert(rawget(_get, k) == nil, "not implement set [" .. k .. "]")
        rawset(t, k, v)
    end,

    --[Comment]
    --国战单挑CD
    natSoloCD = 0,
    --[Comment]
    --跨服国战单挑CD
    snatSoloCD = 0,
    --[Comment]
    --国战州郡粮草上限加成
    stateFoodMax = 0,
    --[Comment]
    --国战州郡移动速度加成
    stateMoveAdd = 0,

    --[Comment]
    --出战武将记录
    expHeroRecord = nil,

    --[Comment]
    --数据变更
    changed = false,
    --[Comment]
    --联盟数据变更
    allyChanged = false,
}
--[Comment]
--索引器
function _user.__index(t, k)
    local ret = rawget(_user, k)
    if ret == nil then
        ret = rawget(_get, k)
        return ret and ret(t, k)
    end
    return ret
end

--[Comment]
--将SN转为字符串
local CheckSN = CheckSN
--[Comment]
--过滤数量0
local function filterzero(d) return d.qty > 0 end

--局部缓存
local u = _user
--[Comment]
--用户数据
user = _user
--[Comment]
--创建用户数据
local function CreateUser()
    --清除观察
    DataCell.Clear()
    --国战数据
    _nat = PY_Nat()
    --跨服国战数据
--    _snat = PY_Snat()
    --初始用户数据
    u = setmetatable(
    {
        --头像
        avaLst = { },
        --荣誉称号
        httlLst = { },
        --道具
        props = { },
        --武将
        hero = { },
        --副将
        dbhero = { },
        --装备
        equip = { },
        --装备碎片
        eqsp = { },
        --副将
        dehero = { },
        --军备
        dequip = { },
        --军备碎片
        dqsp = { },
        --将魂
        souls = { },
        --天机专属
        sexcl = { },
        --宝石
        gems = { },
        --PVE城池
        pveCity = { },
        --PVP城池
        pvpCity = { },
        --PVP区时间
        pvpZoneTm = { },
        --联盟战
        swarTeam = { },
        --活动
        act = { },
        --国家州郡
        state = { },
        --限时/等级礼包过期时间列表
        giftTmLst = { },

        --限时/等级礼包最短过期时间
        giftTm = TimeClock(),
        --聊天冷却
        chatTm = TimeClock(),
        --分享冷却时间
        shareTm = TimeClock(),
        --禁言时间
        chatBanTm = TimeClock(),
        --1次寻宝免费冷却
        rw1Tm = TimeClock(),
        --10次寻宝免费冷却
        rw10Tm = TimeClock(),
        --副将1次寻宝免费冷却
        drw1Tm = TimeClock(),
        --BOSS开启时间
        bossTm = TimeClock(),
        --武将修炼时间
        trainTm = TimeClock(),
        --聚宝盆时间
        jbpTm = TimeClock(),
        --充值排行活动剩余时间
        rechargeRankTm = TimeClock(),
        --基金剩余时间
        fundTm = TimeClock(),
        --夺旗战开启时间
        flagTm = TimeClock(),
        --蛮族入侵开启时间
        barbarianTime = TimeClock(),
        --攻守兼备开启时间
        atkAndDefTime = TimeClock(),

        --联盟数据
        ally = { },
        --国战数据
        nat = _nat,
        --跨服国战数据
        snat = _snat,
        --铜雀台属性
        butyAtt = { 0, 0, 0, 0 },
        --过关斩将数据
        towerInfo = { },
        --战斗结果数据
        battleRet = { },
        --酒馆时间
        tvrnTm = TimeClock(),
        --联盟悬赏时间
        allyQstTm = TimeClock(),

        --聊天队列
        chats = { },
    }, _user)

    user = u
end

--[Comment]
--数据更新
local function Update()
    if u.psn == nil then return end
    --国战武将移动
    if #_nat.heros > 0 then
        for _, v in ipairs(_nat.heros) do v:Move() end
    end
    --跨服国战武将移动
--    if #_snat.heros > 0 then
--        for _, v in ipairs(_snat.heros) do v:Move() end
--    end

    if u.changed then
        u.changed = false
        UserDataChange()
    end
    if u.allyChanged then
        u.allyChanged = false
        UserAllyChange()
    end
end
--添加循环
local _update = UpdateBeat:CreateListener(Update)
UpdateBeat:AddListener(_update)

-------------------------------内部操作-------------------------------
--[Comment]
--校对全局天机
local function CheckGlobalSecret()
    if u.gsatt then return end
    local gslv, gsatt = 0, { 0, 0, 0, 0 }
    local lst, sks = nil, nil
    local lv = nil
    for _, v in pairs(u.hero) do
        if v and v.rare >= MAIN_HERO_RARE then
            gslv = gslv + v.slv
            lst = v.db.sks
            if lst and #lst > 0 then
                for i = 1, #lst do
                    if DB_SKS.GetLvFromLVSN(lst[i]) > 0 then
                        sks = DB.GetSks(lst[i])
                        if sks:IsAllAtt() then
                            lv = DB_SKS.GetLvFromLVSN(sks[i])
                            for j = 1, 4 do gsatt[j] = gsatt[j] + sks:GetAtt(j) * lv end
                        end
                    end
                end
            end
        end
    end

    u.gslv = gslv
    u.gsatt = gsatt

    if gslv > 0 then
        lst = DB.satt
        if lst then
            for _, v in pairs(lst) do
                if gslv >= v.sn then
                    gsatt[1] = gsatt[1] + ExtAtt.Get(v.att, ATT_NM.Str)
                    gsatt[2] = gsatt[2] + ExtAtt.Get(v.att, ATT_NM.Wis)
                    gsatt[3] = gsatt[3] + ExtAtt.Get(v.att, ATT_NM.Cap)
                end
            end
        end

        lv = math.modf(gslv * DB.param.slvAtt)
        gsatt[1] = gsatt[1] + lv
        gsatt[2] = gsatt[2] + lv
        gsatt[3] = gsatt[3] + lv
    end
end

--[Comment]
--添加武将
local function AddHero(d)
    if d == nil or d.dbsn == nil or d.dbsn <= 0 then return nil end
    d.sn = CheckSN(d.sn)
    if d.sn then
        local h = u.hero[d.sn]
        if h then
            h:Init(d)
        else
            h = PY_Hero(d)
            assert(h.sn == d.sn and h.dbsn == d.dbsn, "add PY_Hero err: sn not match")
            u.hero[h.sn] = h
            u.heroQty = u.heroQty + 1
        end
        u.dbhero[h.dbsn] = h
        return h
    end
end
--[Comment]
--移除指定SN的武将
local function RemoveHero(sn)
    sn = tostring(sn)
    local h = u.hero[sn]
    if h then
        u.hero[sn] = nil
        u.heroQty = u.heroQty - 1
        if u.dbhero[h.dbsn] == h then u.dbhero[h.dbsn] = nil end
        h:CellDead()
        h:UnEquip()
        if u.trainHero then table.remove(u.trainHero, table.idxof(u.trainHero,sn)) end
    end
end
--[Comment]
--添加武将
local function AddEquip(d)
    if d == nil or d.dbsn == nil or d.dbsn <= 0 then return nil end
    d.sn = CheckSN(d.sn)
    if d.sn then
        local e = u.equip[d.sn]
        if e then
            e:Init(d)
        else
            e = PY_Equip(d)
            assert(e.sn == d.sn and e.dbsn == d.dbsn, "add PY_Equip err: sn not match")
            u.equip[e.sn] = e
            u.equipQty = u.equipQty + 1
        end
        return e
    end
end
--[Comment]
--移除指定SN的武将
local function RemoveEquip(sn)
    sn = tostring(sn)
    local e = u.equip[sn]
    if e then
        u.equip[sn] = nil
        u.equipQty = u.equipQty - 1
        e:CellDead()
        e:UnEquip()
    end
end
--[Comment]
--添加副将
local function AddDehero(d)
    if d == nil or d.dbsn == nil or d.dbsn <= 0 then return nil end
    d.sn = CheckSN(d.sn)
    if d.sn then
        local dh = u.dehero[d.sn]
        if dh then
            dh:Init(d)
        else
            dh = PY_Dehero(d)
            assert(dh.sn == d.sn and dh.dbsn == d.dbsn, "add PY_Dehero err: sn not match")
            u.dehero[dh.sn] = dh
            u.deheroQty = u.deheroQty + 1
        end
        return dh
    end
end
--[Comment]
--移除指定SN的副将将
local function RemoveDehero(sn)
    sn = tostring(sn)
    local dh = u.dehero[sn]
    if dh then
        u.dehero[sn] = nil
        u.deheroQty = u.deheroQty - 1
        dh:CellDead()
        if dh.belong and dh.belong.dehero == dh then dh.belong:SetDehero() end
        dh:UnEquip()
    end
end
--[Comment]
--添加军备
local function AddDequip(d, new)
    if d == nil or d.dbsn == nil or d.dbsn <= 0 then return nil end
    d.sn = CheckSN(d.sn)
    if d.sn then
        local de = u.dequip[d.sn]
        if de then
            de:Init(d)
        else
            de = PY_Dequip(d)
            assert(de.sn == d.sn and de.dbsn == d.dbsn, "add PY_Equip err: sn not match")
            u.dequip[de.sn] = de
            u.dequipQty = u.dequipQty + 1
            --获取洗炼属性
            if new and de.lvd.extQty > 0 and (d.attLv == nil or #d.attLv < 1) then
                SVR.DequipOption(de.sn, "inf")
            end
        end
        return de
    end
end
--[Comment]
--移除指定SN的军备
local function RemoveDequip(sn)
    sn = tostring(sn)
    local de = u.dequip[sn]
    if de then
        u.dequip[sn] = nil
        u.dequipQty = u.dequipQty - 1
        de:CellDead()
        de:UnEquip()
    end
end

--[Comment]
--从S_LevelMapInfo.mapInfo[d=S_LevelCity]增加一个城池数据[0=SN 1=等级 2=武将数 3=副本次数 4=副本通关最高难度 5=收获时间差 6=是否活动]
local function AddPveCity(d)
    if d and d.sn and d.sn > 0 and d.sn <= DB.maxCityQty then
        local c = u.pveCity[d.sn]
        if c == nil then
            c = PY_City(d.sn)
            u.pveCity[d.sn] = c
        end
        c:SyncMap(d)
        return c
    end
end
----------------------------------------------------------------------

-------------------------------同步部分-------------------------------
--[Comment]
--登录初始化[d=UserInfo]
function _user.Init(d)
    if d == nil then return end
    d.psn = CheckSN(d.psn)
    if d.psn == nil then return end
    if u.psn ~= d.psn then CreateUser() end
    d.gsn = CheckSN(d.gsn)
    table.copy(d, u)

    u.vit = d.vit
    u.ally.gsn = u.gsn
    u.ally.gnm = u.gnm
    u.ally.nsn = u.nsn
    u.nat.nsn = u.nsn


    local tipRare = u.hlv > 39 and 3 or DB_Equip.RARE_VALUE
    if CONFIG.tipEquipRare < tipRare then CONFIG.tipEquipRare = tipRare end
    if CONFIG.tipDeEquipRare < tipRare then CONFIG.tipDeEquipRare = tipRare end

    --初始化州郡
--    d = { }
--    for _, v in pairs(DB.natState) do d[v.sn] = PY_State(v) end
--    u.state = d
end
--[Comment]
--同步扩展信息[d=UserInfoUpdate]
function _user.SyncInfo(d)
    if d and d.rmb and d.vip and d.natPerm then
        d.sign = d.sign == 1
        d.salary = d.salary == 1
        d.vipGiftRec = string.splitMap(d.vipGiftRec,',')
        table.copy(d, u)
        u.ally.myPerm = u.allyPerm
        if d.hlv then
            u.hlv = d.hlv
        end

        u.changed = true
    end
end
--[Comment]
--同步信息变更[d=S_UserInfoChange]
function _user.SyncInfoChange(d)
    if d == nil then return end
    u.nick = d.nick or u.nick
    if d.role > 0 then u.role = d.role end
    u.ava = d.ava
    u.htsn = d.htsn

    u.changed = true
end
--[Comment]
--同部扩展信息
function _user.SyncCD(d)
    if d == nil then return end
    u.svrTm = d.svrTm
    u.tpQty = d.tpQty
    u.tpFreeQty = d.tpFreeQty
    u.tpTotal = d.tpTotal
    u.warQty = d.warQty
    u.g2cQty = d.g2cQty
    u.g2cUsed = d.g2cUsed
    u.chatBanTm.time = d.chatBanTm
    --occInfo
    u.rw1Tm.time = d.rw1Tm
    u.rw10Tm.time = d.rw10Tm
    u.drw1Tm.time = d.drw1Tm
    u.drwQty = d.drwQty
    u.bossTm.time = d.bossTm
    u.trainTm.time = d.trainTm
    u.jbpTm.time = d.jbpTm
    u.fbSdQty = d.fbSdQty
    u.fbSdPrice = d.fbSdPrice
    u.rechargeRankTm.time = d.rechargeRankTm
    u.warBeginDate = CS.Timestamp(d.warBeginDate) or os.time()
    u.warEndDate = CS.Timestamp(d.warEndDate) or os.time()
    u.dvnQty = d.dvnQty
    u.fundTm.time = d.fundTm
    u.famQty = d.famQty
    u.flagTm.time = d.flagTm
    u.snatBginTm = d.snatBginTm
    u.vitCount = d.vitCount
    u.vitTotal = d.vitTotal
    u.vitPrice = d.vitPrice
    u.barbarianTime.time = d.barbarianTime
    u.atkAndDefTime.time = d.atkAndDefTime
    u.trainHero = d.trainHero
end
--[Comment]
--同步价值物列表信息{opt,[lst]}
function _user.SyncValueData(d)
    if d == nil then return end
    if d[1] == "ava" then
        d = d[2]
        if d and #d > 0 then
            local lst = u.avaLst
            table.clear(lst)
            for i = 1, #d do lst[d[i]] = true end
        end
    elseif d[1] == "ht" then
        local lst = u.httlLst
        table.clear(lst)
        d = d[2]
        if d and #d > 0 then
            for i = 1, #d do lst[d[i]] = true end
        else
            lst[0] = true
        end
    end
end
--[Comment]
--同步道具[[道具列表],[装备碎片SN-QTY]]
function _user.SyncProps(d)
    if d == nil then return end
    local arr = d[1]
    local lst, t
    if arr then
        lst = u.props
        for _, v in pairs(lst) do v:SetQty(0) end
        for i = 1, #arr do
            t = lst[i]
            if t then
                t:SetQty(arr[i])
            else
                lst[i] = PY_Props(i, arr[i])
            end
        end
    end
    arr = d[2]
    if arr then
        lst = u.eqsp
        local sn
        for _, v in pairs(lst) do v:SetQty(0) end
        for i = 1, #arr, 2 do
            sn = arr[i]
            if sn and sn > 0 then
                t = lst[sn]
                if t then
                    t:SetQty(arr[i +1])
                else
                    lst[sn] = PY_EquipSp(sn, arr[i + 1])
                end
            end
        end
    end
end
--[Comment]
--同步武将
function _user.SyncHero(d)
    local db = u.dbhero
    table.clear(db)
    if d ~= nil then
        for i = 1, #d do AddHero(d[i]) end
        local h = 0
        for k, v in pairs(u.hero) do
            if db[v.dbsn] == v then
                h = h + 1
            else
                RemoveHero(k)
            end
        end
        u.heroQty = h
    end
end
--[Comment]
--同步装备
function _user.SyncEquip(d)
    local tb = { }
    local e
    for i = 1, #d do
        e = AddEquip(d[i])
        if e then tb[e] = true end
    end
    e = 0
    for k, v in pairs(u.equip) do
        if tb[v] then
            e = e + 1
        else
            RemoveEquip(k)
        end
    end
    u.equipQty = e
end
--[Comment]
--同步副将
function _user.SyncDehero(d)
    local tb = { }
    local dh
    if d then
        for i = 1, #d do
            dh = AddDehero(d[i])
            if e then tb[dh] = true end
        end
    end
    dh = 0
    for k, v in pairs(u.dehero) do
        if tb[v] then
            dh = dh + 1
        else
            RemoveEquip(k)
        end
    end
    u.deheroQty = dh
end
--[Comment]
--同步军备
function _user.SyncDequip(d)
    local tb = { }
    local de
    for i = 1, #d do
        de = AddDequip(d[i])
        if de then tb[de] = true end
    end
    de = 0
    for k, v in pairs(u.dequip) do
        if tb[v] then
            de = de + 1
        else
            RemoveDequip(k)
        end
    end
    u.dequipQty = de
end
--[Comment]
--同步武将将魂和专属[DB,SOUL,SEXCL]
function _user.SyncSoul(d)
    if d == nil then return end

    local soul, sexcl = u.souls, u.sexcl

    for _, v in pairs(soul) do v:SetQty(0) end
    for _, v in pairs(sexcl) do v:SetQty(0) end

    local sn, t
    for i = 1, #d, 3 do
        sn = d[i]
        if sn and sn > 0 then
            t = soul[sn]
            if t then
                t:SetQty(d[i + 1])
            else
                soul[sn] = PY_Soul(sn , d[i + 1])
            end
--            t = sexcl[sn]
--            if t then
--                t:SetQty(d[i + 2])
--            else
--                sn = DB.GetSexcl(sn)
--                if sn and sn.sn > 0 then sexcl[sn.sn] = PY_Sexcl(sn , d[i + 2]) end
--            end
        end
    end
end
--[Comment]
--同步宝石[DB,QTY]
function _user.SyncGem(d)
    if d == nil then return end
    local lst = u.gems
    for _, v in pairs(lst) do v:SetQty(0) end

    local sn, t
    for i = 1, #d, 2 do
        sn = d[i]
        if sn and sn > 0 then
            t = lst[sn]
            if t then
                t:SetQty(d[i + 1])
            else
                lst[sn] = PY_Gem(sn, d[i + 1])
            end
        end
    end
end
--[Comment]
--同步军备碎片[DB,QTY]
function _user.SyncDequipSp(d)
    if d == nil then return end
    local lst = u.dqsp
    for _, v in pairs(lst) do v:SetQty(0) end
    local sn, t
    for i = 1, #d, 2 do
        sn = d[i]
        if sn and sn > 0 then
            t = lst[sn]
            if t then
                t:SetQty(d[i + 1])
            else
                lst[sn] = PY_DequipSp(sn, d[i + 1])
            end
        end
    end
end
--[Comment]
--同步奖励接口
function _user.SyncReward(rws, hide)
    if type(rws) ~= "table" then return end
    local hasEqp, hasDqp = false, false
    local vf = RW.Verify
    for i, rw in ipairs(rws) do
        if vf(rw) then
            i = rw[1]
            if i == 1 then
                --玩家属性
                i = rw[2]
                if i == 1 then
                    --银币
                    u.coin = u.coin + rw[3]
                elseif i == 2 then
                    --金币
                    u.gold = u.gold + rw[3]
                elseif i == 3 then
                    --血
                    u.hp = u.hp + rw[3]
                elseif i == 4 then
                    --兵
                    u.tp = u.tp + rw[3]
                elseif i == 5 then
                    --积分
                    u.rmb = u.rmb + rw[3]
                elseif i == 6 then
                    --粮草
                    u.nat.food = u.nat.food + rw[3]
                elseif i == 7 then
                    --封赏令
                    u.token = u.token + rw[3]
                elseif i == 8 then
                    --魂币
                    u.soul = u.soul + rw[3]
                elseif i == 9 then
                    --银票
                    u.ally.myCash = u.ally.myCash + rw[3]
                elseif i == 10 then
                    --军功
                    u.ally.myMerit = u.ally.myMerit + rw[3]
                elseif i == 11 then
                    --头像
                    u.avaLst[rw[3]] = true
                elseif i == 12 then
                    --称号
                    u.httlLst[rw[3]] = true
                elseif i == 13 then
                    --矿脉值
                    u.mine = u.mine + rw[3]
                elseif i == 14 then
                    --VIP经验值
                elseif i == 15 then
                    --主城经验值
                    u.exp = u.exp + rw[3]
                elseif i == 16 then
                    --竞技场积分
                elseif i == 17 then
                    --竞技场声望
                elseif i == 18 then
                    --日常活跃度
                elseif i == 19 then
                    --体力值
                    u.vit = u.vit + rw[3]
                elseif i == 20 then
                    --酒值
                    u.nat.wine = u.nat.wine + rw[3]
                elseif i == 21 then
                    --国战贡献值
                end
                u.changed = true
            elseif i == 2 then
                --道具
                u.AddPropsQty(rw[2], rw[3])
            elseif i == 3 then
                --装备
                i = rw[3]
                if tonumber(i) > 0 then
                    u.AddEquip(i, RW.GetEquipDBSN(rw[2]), 0, RW.GetEquipEvo(rw[2]))
                    hasEqp = true
                else
                    RemoveEquip(string.sub(tostring(i), 2))
                end
            elseif i == 4 then
                --武将
                i = rw[3]
                if tonumber(i) > 0 then
                    u.AddHero(i, rw[2], math.max(1,u.gmMaxCity))
                else
                    RemoveHero(string.sub(tostring(i), 2))
                end
            elseif i == 5 then
                --装备碎片
                u.AddEquipSp(rw[2], rw[3])
            elseif i == 6 then
                --将魂
                u.AddSoulQty(rw[2], rw[3])
            elseif i == 7 then
                --宝石
                u.AddGemQty(rw[2], rw[3])
            elseif i == 8 then
                --副将
                u.AddDehero(rw[3], rw[2])
            elseif i == 9 then
                --副将经验
                i = u.GetDehero(rw[3])
                if i then i:SetExp(rw[2]) end
            elseif i == 10 then
                --军备
                u.AddDequip(rw[3], DB_Dequip.GetDbAndLvFromRsn(rw[2]))
                hasDqp = true
            elseif i == 11 then
                --军备残片
                u.AddDequipSp(rw[2], rw[3])
            elseif i == 12 then
                --活动得分
                 i = u.act[rw[2]]
                 if i then i:AddScore(rw[3]) end
            elseif i == 13 then
                --天机专属
                u.AddSexclQty(rw[2], rw[3])
            elseif tonumber(i) < 0 then
                --武将属性
                local h = u.GetHero(string.sub(tostring(i), 2))
                if h then
                    i = rw[2]
                    if i == 1 then
                        --经验
                        h:SetExp(h.exp + rw[3])
                    elseif i == 2 then
                        --生命
                        i = rw[3]
                        h:SetBaseHP(h.baseHP + i)
                        h:SetHP(h.hp + i)
                    elseif i == 3 then
                        --技力
                        h:SetSP(h.sp + rw[3])
                    elseif i == 4 then
                        --兵力
                        h:SetTP(h.tp + rw[3])
                    elseif i == 5 then
                        --武力
                        h:SetBaseStr(h.baseStr + rw[3])
                    elseif i == 6 then
                        --智力
                        h:SetBaseWis(h.baseWis + rw[3])
                    elseif i == 7 then
                        --忠诚
                        h:SetLoyalty(h.loyalty + rw[3])
                    elseif i == 8 then
                        --统帅
                        h:SetBaseCap(h.baseCap + rw[3])
--                    elseif i == 9 then
                        --精力
                    end
                end
            end
        end
    end

    if hasEqp then
        local space = DB.GetVip(u.vip).eqpQty - user.equipQty
        if space > 0 then
            if space <= CONFIG.EquipTipCount then
                MsgBox.Show(string.format(L("您的背包空间仅剩%s个\n[FF0000](超过上限时装备将会转换为碎片)[-]"), ColorStyle.Bad(space)), L("确定")..","..L("查看"), function(bidx) if bidx == 1 then Win.Open("WinGoods") end end)
            end
        else
            MsgBox.Show(ColorStyle.Bad(L("您的背包空间已满\n再获得装备将会转换为碎片")),  L("确定")..","..L("查看"), function(bidx) if bidx == 1 then Win.Open("WinGoods") end end)
        end
    end
    if hasDqp then
        local space = DB.GetVip(u.vip).dqpQty - user.dequipQty
        if space > 0 then
            if space <= CONFIG.EquipTipCount then
                MsgBox.Show(string.format(L("您的背包空间仅剩%d个\n[FF0000](超过上限时军备将会转换为残片)[-]"), ColorStyle.Bad(space)), L("确定")..","..L("查看"), function(bidx) if bidx == 1 then Win.Open("WinGoods", 12) end end)
            end
        else
            MsgBox.Show(ColorStyle.Bad(L("您的背包空间已满\n再获得军备将会转换为残片")),  L("确定")..","..L("查看"), function(bidx) if bidx == 1 then Win.Open("WinGoods", 12) end end)
        end
    end

    if hide then return end
    PopRewardShow.Show(rws)
end
--[Comment]
--同步货币[金币,银币,积分,魂币,银票,联盟声望]
function _user.SyncMoney(m)
    if m == nil then return end
    if m[1] then u.gold = m[1] end
    if m[2] then u.coin = m[2]  end
    if m[3] then u.rmb = m[3] end
    if m[4] then u.ally.myCash = m[4] end
    if m[5] then u.ally.myRenown = m[5] end
    if m[6] then u.token = m[6] end
    user.changed = true
end
--[Comment]
--同步酒馆信息[d=S_Tavern]
function _user.SyncTavern(d)
    if d == nil then return end
--    if d.time then u.tvrnTm.time = d.time end
--    if d.rw10Tm then u.rw10Tm.time = d.rw10Tm end
--    if d.gold then u.gold = d.gold end
--    if d.coin then u.coin = d.coin end
    if d.refCd then u.tvrnTm.time = d.refCd end
    local len = u.tavernHero and #u.tavernHero or 0
    if len > 0 then
        for i = 1, len do
            if d.luck[i] then
                tavernHero[i] = d.luck[i]
            end
        end
    end
end
--[Comment]
--同步联盟数据(同步完成时回调)[S_AllyInfo]
function _user.SyncAllyInfo(fc)
    SVR.GetAllyInfo(0, function(t)
        if t.success then
--            u.ally = kjson.ldec(t.data) or u.ally
            u.ally = SVR.datCache or u.ally
            u.ally.gsn = CheckSN(u.ally.gsn)
            u.nat.nsn = u.ally.nsn
        end
        if fc then fc() end
    end)
end
--[Comment]
--同步铜雀台[d=S_Beauty]
function _user.SyncBeauty(d)
    if d == nil then return end
    local buty = u.butyAtt
    for i = 1, #buty do buty[i] = 0 end

    d = d.buty
    if d == nil then return end
    local b, db, lv, add
    for i = 1, #d do
        b = d[i]
        db = DB.GetBeauty(b.bsn)
        lv = db:GetLv(b.lv)
        if lv then
            if b.star and b.star > 0 then
                add = db:GetStar(b.star)
                add = 1 + (add and add.ate or 0) * 0.01
                buty[1] = buty[1] + (math.modf(lv.str * add))
                buty[2] = buty[2] + (math.modf(lv.wis * add))
                buty[3] = buty[3] + (math.modf(lv.cap * add))
                buty[4] = buty[4] + (math.modf(lv.hp * add))
            else
                buty[1] = buty[1] + lv.str
                buty[2] = buty[2] + lv.wis
                buty[3] = buty[3] + lv.cap
                buty[4] = buty[4] + lv.hp
            end
        end
    end
end
----------------------------------------------------------------------

-------------------------------清理部分-------------------------------
--[Comment]
--清除所有PVE城池
function _user.ClearPveCity()
    if u then
        for _, v in pairs(u.pveCity) do if v then v:CellDead() end end
        u.pveCity = {}
    end
end
--[Comment]
--清除所有PVP城池
function _user.ClearPvpCity()
    if u then
        for _, v in pairs(u.pvpCity) do if v then v:CellDead() end end
        u.pvpCity = {}
    end
end
----------------------------------------------------------------------

-------------------------------数据部分-------------------------------
--[Comment]
--获取玩家科技增益[1=STR 2=INT 3=CAP]
function _user.GetTechGain(sn) return u.ally.gsn and u.tech and u.tech[sn] or 0 end
--[Comment]
--设置玩家科技增益
function _user.SetTechGain(tech) u.tech = tech end
--[Comment]
--全局天机等级
function _user.GSlv() CheckGlobalSecret(); return u.gslv end
--[Comment]
--全局天机属性[武,智,统,血]
function _user.GSatt(aid) CheckGlobalSecret(); return u.gsatt[aid] or 0 end
--[Comment]
--获取联盟科技等级[1=STR 2=INT 3=CAP]
function _user.GetAllyTechLv(sn) return u.ally.tech and u.ally.tech[sn] or 0 end
--[Comment]
--设置联盟科技等级[1=STR 2=INT 3=CAP]
function _user.SetAllyTechLv(sn, v) if u.ally.tech then u.ally.tech[sn] = v else u.ally.tech = { [sn] = v } end end
--[Comment]
--铜雀台加成
--function _user.GetBeautyAtt(aid) return u.butyAtt[aid] or 0 end
function _user.GetBeautyAtt(aid) return 0 end
--[Comment]
--指定编号的VIP礼包是否已购买
function _user.GetVipRec(sn) return u.vipGiftRec and u.vipGiftRec[sn] end
--[Comment]
--设置指定编号VIP礼包已购买
function _user.SetVipRec(sn) if sn and sn > 0 then if u.vipGiftRec then u.vipGiftRec[sn] = true else u.vipGiftRec = { [sn] = true } end end end
--[Comment]
--设置7天登录奖励的领取
function _user.SetSevenRw()
    local str = u.seven
    if str == nil then return end
    local idx = u.loginQty
    if idx < 1 then return end
    local len = string.len(str)
    if idx > len or string.byte(str, idx) == 48 then return end
    if idx == 1 then
        u.seven = "0" .. string.sub(str, 2)
    elseif idx == len then
        u.seven = string.sub(str, 1, idx - 1) .. "0"
    else
        u.seven = string.sub(str, 1, idx - 1) .. "0" .. string.sub(str, idx + 1)
    end
end
--[Comment]
--检测实名认证登录
function _user.CheckVerifyLogin()
    if u.TutorialSN == 0 and u.ForceVerify and Scene.CurrentIs(SCENE.GAME) then
        Win.Open("PopVerify")
        return true
    end
    return false
end
----------------------------------------------------------------------

---------------------------------属性---------------------------------
_get = 
{
    --荣誉称号
    HonorTitle = function(u) return u.htsn > 0 and DB.GetHttl(u.htsn).nm or "" end,
    --是否未实名认证
    NotVerified = function(u) return u.age <= 0 end,
    --是否防沉迷受限
    VerifyRestricted = function(u) return CONFIG.verifyFunc and u.age < 18 end,
    --强制实名认证
    ForceVerify = function(u) return CONFIG.needVerify and CONFIG.verifyFunc and u.age == -127 end,

    --当前粮草
    Food = function(u) return u.nat.food end,
    --免费分身数量
    CopyQty = function(u) return u.nat.copyQty end,

    --[Comment]
    --联盟银票
    ACash = function(u) return u.ally.myCash or 0 end,
    --[Comment]
    --盟战军功
    AMerit = function(u) return u.ally.myMerit or 0 end,

    --[Comment]
    --主城数据
    Home = function(u) return DB.GetHome(u.hlv) end,
    --[Comment]
    --玩家当前爵位数据
    Title = function(u) return DB.GetTtl(u.ttl) end,
    --[Comment]
    --最大体力值(可超上限)
    MaxVit = function(u) return 200 end,
    --[Comment]
    --最大血库
    MaxHP = function(u) return DB.GetHome(u.hlv).hp + u.GetTechGain(1) end,
    --[Comment]
    --最大兵力
    MaxTP = function(u) return DB.GetHome(u.hlv).tp + u.GetTechGain(2) end,
    --[Comment]
    --最大粮草
    MaxFood = function(u) return u.nat.foodMax + u.stateFoodMax end,
    --[Comment]
    --可带领的武将数
    MaxBattleHero = function(u) return DB.GetHome(u.hlv).lead end,
    --[Comment]
    --最大修炼武将数
    MaxTrainHero = function(u) return DB.GetVip(u.vip).trainQty end,
    --[Comment]
    --最大可带领的国战武将数
    MaxNatHero = function(u) return DB.GetTtl(u.ttl).lead end,
    --[Comment]
    --幻化石数量
    EcStone = function(u) return u.GetPropsQty(DB_Props.HUAN_HUA_SHI) end,
    --[Comment]
    --VIP数据
    VipData = function(u) return DB.GetVip(u.vip) end,
    --[Comment]
    --是否可以一键收获
    CanQuickSearch = function(u) return DB.GetVip(u.vip).seek == 1 or u.hlv >= DB.param.lvCrop1k end,
    --[Comment]
    --下一关
    NextCity = function(u) return math.min(u.gmMaxCity + 1, DB.maxCityQty) end,
    --[Comment]
    --PVP城池编号
    PvpSN = function(u) return PY_PvpCity.ZonePosToSN(u.zone, u.pos) end,
    --[Comment]
    --玩家PVP地图城池数据
    PvpHomeCity = function(u) return u.GetPvpCity(u.zone, u.pos) end,

    --[Comment]
    --战役是否开启
    IsWarBegin = function(u) local now = os.time(); return now >= u.warBeginDate and now < u.warEndDate end,
    --[Comment]
    --当前玩家没30分钟恢复的HP

    RestoreHP = function(u) return DB.param.qtyReHP + DB.GetVip(u.vip).hpCrop end,
    --[Comment]
    --当前玩家每天副本能挑战的次数
    FbQty = function(u) return DB.GetVip(u.vip).fbQty end,
    --[Comment]
    --征兵花费
    TPCost = function(u) local v = u.tpQty - u.tpFree + 1;return v > 0 and (v  + (v > 10 and v - 10 or 0)) * 10000 or 0 end,
    --[Comment]
    --当前玩家可将主城升到的最高等级
    HomeMaxLv = function(u)
        local home = DB.home
        for i = 1, table.maxn(home) do
            if home[i] and u.gmMaxLv < home[i].gmLv  then
                return i
            end
        end
        return DB.maxHlv
    end,

    --[Comment]
    --玩家展现装备的稀有度
    EquipRareValue = function(u) return u.hlv > 39 and 3 or DB_Equip.RARE_VALUE end,
    --[Comment]
    --玩家展现道具的稀有度
    PropsRareValue = function(u) return 4 end,

    --以下为解锁判断
    IsDevUL = function(u) return u.gmMaxCity >= DB.unlock.dev end,
    IsHeroUL = function(u) return u.gmMaxCity >= DB.unlock.hero end,
    IsSmithyUL = function(u) return u.gmMaxCity >= DB.unlock.smithy end,
    IsLoyaltyUL = function(u) return u.gmMaxCity >= DB.unlock.loyalty end,
    IsHistroyUL = function(u) return u.gmMaxCity >= DB.unlock.gmFB end,
    IsWarUL = function(u) return u.hlv >= DB.unlock.gmWar end,
    IsRankUL = function(u) return u.hlv >= DB.unlock.rank end,
    IsPvpUL = function(u) return u.hlv >= DB.unlock.pvp end,
    IsAllyUL = function(u) return u.hlv >= DB.unlock.ally end,
    IsEquipEvoUL = function(u) return u.hlv >= DB.unlock.eqpEvo end,
    IsTowerUL = function(u) return u.hlv >= DB.unlock.tower end,
    IsRareShopUL = function(u) return u.hlv >= DB.unlock.rareShop end,
    IsFameUL = function(u) return u.hlv >= DB.unlock.fame end,
    IsBossUL = function(u) return u.hlv >= DB.unlock.boss end,
    IsDivineUL = function(u) return u.hlv >= DB.unlock.divine end,
    IsFamUL = function(u) return u.hlv >= DB.unlock.fam end,
    IsExclForgeUL = function(u) return u.hlv >= DB.unlock.exclForge end,
    IsEquipEcUL = function(u) return u.hlv >= DB.unlock.eqpEC end,
    IsEquipEmbedUL = function(u) return u.hlv >= DB.unlock.gemEmbed end,
    IsHeroSoulUL = function(u) return u.hlv >= DB.unlock.heroSoul end,
    IsClanWarUL = function(u) return u.hlv >= DB.unlock.gmClan end,
    IsCultiveUL = function(u) return u.hlv >= DB.unlock.xlLv end,
    IsDeheroUL = function(u) return u.hlv >= DB.unlock.dehero end,
    IsAhvUL = function(u) return u.hlv >= DB.unlock.achv end,
    IsNatBloodUL = function(u) return u.hlv >= DB.unlock.natBlood end,
    IsBeautyUL = function(u) return u.hlv >= DB.unlock.beauty end,
    IsFantsyUL = function(u) return u.hlv >= DB.unlock.fantsy end,
    IsDailyUL = function(u) return u.gmMaxCity >= DB.unlock.daily end,
    IsReward10UL = function(u) return u.hlv >= DB.unlock.reward10 end,
    IsTarget7UL = function(u) return u.hlv >= DB.unlock.target7 end,
    IsSignUL = function(u) return u.hlv >= DB.unlock.sign end,
    IsCarnivalUL = function(u) return u.hlv >= DB.unlock.affair end,
    IsGveUL = function(u) return u.hlv >= DB.unlock.explorer end,
    IsCountryUL = function(u) return u.hlv >= DB.unlock.country end,
    IsAutoFightUL = function(u) return u.hlv >= DB.unlock.autoFightHome or u.vip >= DB.unlock.autoFightVip end,
    IsTrainUL = function(u) return u.hlv > DB.unlock.heroExp end
}
_set = 
{
    --当前粮草
    Food = function(u, v) u.nat.food = v end,
    --免费分身数量
    CopyQty = function(u, v) u.nat.copyQty = v end,

    --[Comment]
    --联盟银票
    ACash = function(u, v)  u.ally.myCash = v or 0 end,
    --[Comment]
    --盟战军功
    AMerit = function(u, v) u.ally.myMerit = v or 0 end,

    --[Comment]
    --PVP城池编号
    PvpSN = function(u, v) u.zone, u.pos = PY_PvpCity.SNToZonePos(v) end,
}
----------------------------------------------------------------------

-------------------------------其它部分-------------------------------
--[Comment]
--判断给定的SN是否是系统管理员
function _user.IsSystemUser(psn) return string.len(tostring(psn)) == 1 end

----------------------------------------------------------------------

-------------------------------道具宝石-------------------------------
--[Comment]
--获取指定编号道具的数量
function _user.GetPropsQty(sn) sn = u.props[sn]; return sn and sn.qty or 0 end

function _user.GetPropsDat(sn)
    local d = u.props[sn]
    if d then return d end
    d = DB.GetProps(sn)
    if d.sn > 0 then
        d = PY_Props(d, 0)
        u.props[d.sn] = d
        return d
    end
    return PY_Props.undef
end
--[Comment]
--设置指定编号道具的数量
function _user.SetPropsQty(sn, qty)
    if sn and qty and sn > 0 then
        local d = u.props[sn]
        if d then
            d:SetQty(qty)
        else
            d = DB.GetProps(sn)
            if d.sn > 0 then u.props[d.sn] = PY_Props(d, qty) end
        end
    end
end
--[Comment]
--增加/减少指定编号道具的数量
function _user.AddPropsQty(sn, qty)
    if sn and qty and sn > 0 then
        local d = u.props[sn]
        if d then
            d:AddQty(qty)
        else
            d = DB.GetProps(sn)
            if d.sn > 0 then u.props[d.sn] = PY_Props(d, qty) end
        end
    end
end
--[Comment]
--获取所有道具
function _user.GetProps(f) return table.findall(u.props, f == true and filterzero or f) end

--[Comment]
--获取指定编号宝石的数量
function _user.GetGemQty(sn) sn = u.gems[sn]; return sn and sn.qty or 0 end
--[Comment]
--设置指定编号宝石的数量
function _user.SetGemQty(sn, qty)
    if sn and qty and sn > 0 then
        local g = u.gems[sn]
        if g then
            g:SetQty(qty)
        else
            sn = DB.GetGem(sn)
            if sn.sn > 0 then u.gems[sn.sn] = PY_Gem(sn, qty) end
        end
    end
end
--[Comment]
--增加/减少指定编号宝石的数量
function _user.AddGemQty(sn, qty)
    if sn and qty and sn > 0 then
        local g = u.gems[sn]
        if g then
            g:AddQty(qty)
        else
            sn = DB.GetGem(sn)
            if sn.sn > 0 then u.gems[sn.sn] = PY_Gem(sn, qty) end
        end
    end
end
--[Comment]
--获取玩家所有宝石
function _user.GetGems(f) return table.findall(u.gems, f == true and filterzero or f)end
----------------------------------------------------------------------

-------------------------------武将数据-------------------------------
--[Comment]
--添加新武将数据，初始属性武将(csn, dbsn, loc)
function _user.AddHero(csn, dbsn, loc)
    if "table" == type(csn) then return AddHero(csn) end

    csn = CheckSN(csn)
    if csn and dbsn > 0 then
        local db = DB.GetHero(dbsn)
        -- 配置[stab.S_Hero]数据
        local d =
        {
            sn = csn,
            dbsn = dbsn,
            lv = 1,
            ttl = 1,
            baseStr = db.str,
            baseWis = db.wis,
            baseCap = db.cap,
            hp = db.hp,
            baseHP = db.hp,
            sp = db.sp,
            loyalty = 100,
            tp = db.tp,
            arm = db.arm,
            armLst = { db.arm },
            lnp = db.lnp,
            lnpLst = { db.lnp },
            skc = 1,
            skt = 1,
            loc = loc or 1,
        }
        d = AddHero(d)

        local city = u.GetPveCity(d.loc)
        if city then
            city:CalcHeroQty()
            --if (MapManager.Instance) MapManager.Instance.RefreshLevelMapCity();
        end
        return d
    end
end
---<summary>获取指定SN的武将</summary>
---<returns type="PY_Hero"></returns>
function _user.GetHero(csn) return u.hero[tostring(csn)] end
--[Comment]
--移除指定SN的武将
_user.RemoveHero = RemoveHero
--[Comment]
--获取玩家所有武将
function _user.GetHeros(f) return table.findall(u.hero, f) end
---<summary>获取玩家最强武将</summary>
---<returns type="PY_Hero"></returns>
function _user.GetFirstStrHero()
    local h = nil
    for _, v in pairs(u.hero) do
        if h == nil or h.rare < v.rare or (h.rare == v.rare and v.kind < h.kind)
            or (h.rare == v.rare and v.kind == h.kind and h.db.str < hd.db.str) then h = v end  
    end
    return h
end
---<summary>通过DBSN获取武将</summary>
---<returns type="PY_Hero"></returns>
function _user.ExistHero(dbsn) return u.dbhero[dbsn] end
--[Comment]
--获取指定城市武将
function _user.GetCityHero(loc)
    local ret = { }
    for _, v in pairs(u.hero) do if v.loc == loc then table.insert(ret, v) end end
    return ret
end
---<summary>找到匹配条件的武将</summary>
---<returns type="PY_Hero"></returns>
function _user.FindHero(f)
    if f then for _, v in pairs(u.hero) do if f(v) then return v end end end
end
--[Comment]
--获取指定城池的武将数
function _user.GetCityHeroQty(loc)
    local qty = 0
    for _, v in pairs(u.hero) do if v.loc == loc then qty = qty + 1 end end
    return qty
end
--[Comment]
--是否有忠诚度较低的武将
_get.HasLowLoyatyHero = function(u) for _, v in pairs(u.hero) do if v.IsLowLoyalty then return true end end end
--[Comment]
--是否有生命值较低的武将
_get.HasLowHPHero = function(u) for _, v in pairs(u.hero) do if v.IsLowHP then return true end end end
--[Comment]
--是否有兵力值较低的武将
_get.HasLowTPHero = function(u) for _, v in pairs(u.hero) do if v.IsLowTP then return true end end end
--[Comment]
--是否有能学习新兵种的武将
_get.HasCanLearnArmHero = function(u) for _, v in pairs(u.hero) do if v.CanLearnArm then return true end end end
--[Comment]
--是否有能学习新阵形的武将
_get.HasCanLearnLnpHero = function(u) for _, v in pairs(u.hero) do if v.CanLearnLnp then return true end end end
--[Comment]
--是否有能铭刻阵形的武将
_get.HasCanImpLnpHero = function(u) for _, v in pairs(u.hero) do if v.CanImpLnp then return true end end end
--[Comment]
--有可升级的武将
_get.HasCanLvUpHero = function(u) for _, v in pairs(u.hero) do if v.lv < u.hlv then return true end end end
--[Comment]
--有训练中的武将
_get.HasTrainHero = function(u) return u.trainHero and #u.trainHero > 0 end
--[Comment]
--是否有可以觉醒的武将
_get.HasCanEvoHero = function(u) for _, v in pairs(u.hero) do if v.CanEvo then return true end end end
--[Comment]
--有可以升官的武将
_get.HasCanPromotionHero = function(u) for _, v in pairs(u.hero) do if v.CanPromotion then return true end end end
--[Comment]
--是否有可以升级将星的武将
_get.HasCanUpStarHero = function(u) for _, v in pairs(u.hero) do if v.CanUpStar then return true end end end
--[Comment]
--是否有可以升级将星的武将
_get.HeroLvLmt = function(u) return math.min(u.hlv, DB.maxHeroLv) end

--[Comment]
--获取武将将魂数量
function _user.GetSoulQty(sn) sn = u.souls[sn]; return sn and sn.qty or 0 end
--[Comment]
--获取武将将魂数量
function _user.SetSoulQty(sn, qty)
    if sn and qty and sn > 0 and qty >= 0 then
        local s = u.souls[sn]
        if s then
            s:SetQty(qty)
        else
            sn = DB.GetHero(sn)
            if sn.sn > 0 then u.souls[sn.sn] = PY_Soul(sn, qty) end
        end
    end
end
--[Comment]
--获取武将将魂数量
function _user.AddSoulQty(sn, qty)
    if sn and qty and sn > 0 and qty ~= 0 then
        local s = u.souls[sn]
        if s then
            s:AddQty(qty)
        else
            sn = DB.GetHero(sn)
            if sn.sn > 0 then u.souls[sn.sn] = PY_Soul(sn, qty) end
        end
    end
end
--[Comment]
--获取玩家所有武将将魂
function _user.GetSouls(f) return table.findall(u.souls, f == true and filterzero or f)end

--[Comment]
--获取武将天机专属数量
function _user.GetSexclQty(sn) sn = u.sexcl[sn]; return sn and sn.qty or 0 end
--[Comment]
--获取武将天机专属数量
function _user.SetSexclQty(sn, qty)
    if sn and qty and sn > 0 and qty ~= 0 then
        local s = u.sexcl[sn]
        if s then
            s:SetQty(qty)
        else
            sn = DB.GetSexcl(sn)
            if sn.sn > 0 then u.sexcl[sn.sn] = PY_Sexcl(sn, qty) end
        end
    end
end
--[Comment]
--获取武将天机专属数量
function _user.AddSexclQty(sn, qty)
    if sn and qty and sn > 0 and qty ~= 0 then
        local s = u.sexcl[sn]
        if s then
            s:AddQty(qty)
        else
            sn = DB.GetSexcl(sn)
            if sn.sn > 0 then u.sexcl[sn.sn] = PY_Sexcl(sn, qty) end
        end
    end
end
--[Comment]
--获取玩家所有武将将魂
function _user.GetSexcls(f) return table.findall(u.sexcl, f == true and filterzero or f)end
----------------------------------------------------------------------

-------------------------------装备数据-------------------------------
--[Comment]
--添加新装备(esn,dbsn,lv,evo)
function _user.AddEquip(esn, dbsn, lv, evo)
    return AddEquip("table" == type(esn) and esn or { sn = esn, dbsn = dbsn, lv = lv or 0, evo = evo or 0 })
end
---<summary>获取指定SN的装备</summary>
---<returns type="PY_Equip"></returns>
function _user.GetEquip(esn) return u.equip[tostring(esn)] end
--[Comment]
--移除指定SN的装备
_user.RemoveEquip = RemoveEquip
--[Comment]
--获取玩家所有装备
function _user.GetEquips(f) return table.findall(u.equip, f) end
--[Comment]
--获取所有垃圾装备
function _user.GetGarbageEquip()
    local ret = { }
    for _, v in pairs(u.equip) do if v.rare < 3 and not v.IsEquiped then table.insert(ret, v) end end
    return ret
end
--[Comment]
--是否有垃圾装备
_get.HasGarbageEquip = function(u) for _, v in pairs(u.equip) do if v.rare < 3 and not v.IsEquiped then return true end end end

--[Comment]
--获取装备碎片数量
function _user.GetEquipSp(sn) sn = u.eqsp[sn]; return sn and sn.qty or 0 end
--[Comment]
--设置装备碎片数量
function _user.SetEquipSp(sn, qty)
    if sn and qty and sn > 0 and qty ~= 0 then
        local e = u.eqsp[sn]
        if e then
            e:SetQty(qty)
        else
            sn = DB.GetEquip(sn)
            if sn.sn > 0 then u.eqsp[sn.sn] = PY_EquipSp(sn, qty) end
        end
    end
end
--[Comment]
--增加/减少装备碎片数量
function _user.AddEquipSp(sn, qty)
    if sn and qty and sn > 0 and qty ~= 0 then
        local e = u.eqsp[sn]
        if e then
            e:AddQty(qty)
        else
            sn = DB.GetEquip(sn)
            if sn.sn > 0 then u.eqsp[sn.sn] = PY_EquipSp(sn, qty) end
        end
    end
end
--[Comment]
--获取玩家所有装备残片
function _user.GetEquipSps(f) return table.findall(u.eqsp, f == true and filterzero or f)end
----------------------------------------------------------------------

-------------------------------副将数据-------------------------------
--[Comment]
--添加新副将(dcsn, dbsn)
function _user.AddDehero(dcsn, dbsn)
    return AddDehero("table" == type(dcsn) and dcsn or
    {
        sn = dcsn,
        dbsn = dbsn,
        lv = 1,
        star = 1,
        point = 1,
        pointMax = 1,
        skd = DB.GetDehero(dbsn).skd
    })
end
---<summary>获取指定SN的副将</summary>
---<returns type="PY_Dehero"></returns>
function _user.GetDehero(dcsn) return u.dehero[tostring(dcsn)] end
--[Comment]
--移除指定SN的副将
_user.RemoveDeHero = RemoveDeHero
--[Comment]
--获取玩家所有副将
function _user.GetDeheros(f) return table.findall(u.dehero, f) end
----------------------------------------------------------------------

-------------------------------军备数据-------------------------------
--[Comment]
--添加新军备(desn, dbsn, lv)
function _user.AddDequip(desn, dbsn, lv) return AddDequip("table" == type(desn) and desn or { sn = desn, dbsn = dbsn, lv = lv or 1 }) end
---<summary>获取指定SN的军备</summary>
---<returns type="PY_Dequip"></returns>
function _user.GetDequip(desn) return u.dequip[tostring(desn)] end
--[Comment]
--移除指定SN的军备
_user.RemoveDequip = RemoveDequip
--[Comment]
--获取玩家所有军备
function _user.GetDequips(f) return table.findall(u.dequip, f) end

--[Comment]
--获取军备残片的数量(dbsn/sn, rare)(sn=残片DBSN*1000+残片品质)
function _user.GetDequipSp(sn, rare)
    sn = u.dqsp[rare and PY_DequipSp.GetSnFromDbAndRare(sn, rare) or sn]
    return sn and sn.qty or 0
end
--[Comment]
--添加军备残片(sn=残片DBSN*1000+残片品质)
function _user.AddDequipSp(sn, qty)
    if sn and qty and sn > 1000 and qty ~= 0 then
        local de = u.dqsp[sn]
        if de then
            de:AddQty(qty)
        else
            u.dqsp[sn] = PY_DequipSp(sn, qty)
        end
    end
end

--[Comment]
--获取玩家所有军备残片
function _user.GetDequipSps(f) return table.findall(u.dqsp, f == true and filterzero or f)end
----------------------------------------------------------------------

-------------------------------PVE城池数据-------------------------------
--[Comment]
--从[d=S_LevelCity]添加Pve城池
_user.AddPveCity = AddPveCity
--[Comment]
--从[d=S_LevelMapInfo]更新PVE数据
function _user.SyncPveCity(d)
    if d == nil then return end

    u.gmLv = d.gmLv
    u.gmMaxLv = d.gmMaxLv
    u.gmMaxCity = d.gmMaxCity

    local t = u.pveCity
    if table.maxn(t) <= 0 then
--        local tm = math.max(0, SVR.SvrTime() - Save.lastQuitTime) 待做
        local tm = math.max(0, SVR.SvrTime() - 0)
        local c
        for i = 1, u.gmMaxCity do
            c = PY_City(i)
            t[i] = c
            c.fbQty = 1
            c.searchTm.time = tm
        end
    end

    d = d.mapInfo
    if d and #d > 0 then for i = 1, #d do AddPveCity(d[i]) end end
end
--[Comment]
--同步pve城池副本次数[d=S_CityFB[]][次数,最高难度,次数,最高难度...]
function _user.SyncPveCityFB(d)
    if d and #d > 0 then
        local c
        local t = u.pveCity
        if d and #d > 0 then for i = 1, #d do
            c = t[d[i].sn]
            if c then c:SyncFB(d[i]) end
        end end
    end
end
--[Comment]
--从S_TerritoryList.S_Territory[]更新PVE数据
function _user.SyncPveCityTer(d)
    if d and d.opt == "pve" then
        d = d.cities
        if d == nil or #d < 1 then return end
        local c, v
        local t = u.pveCity
        for i = 1, #d do
            v = d[i]
            c = t[v.sn]
            if c == nil then
                c = PY_City(v.sn)
                t[v.sn] = c
            end
            c:SyncTer(v)
        end
    end
end
---<summary>获取指定编号的PVE城池数据</summary>
---<returns type="PY_City"></returns>
function _user.GetPveCity(sn) return u.pveCity[sn] end
--[Comment]
--获取所有PVE城池数据
function _user.GetPveCities() return table.copy(u.pveCity) end
--[Comment]
--获取指定关卡所有城池数据(关卡编号)
function _user.GetLevelPveCity(lv)
    lv = DB.GetGmLv(lv).city
    if lv and #lv > 0 then
        local ret, lst = { }, u.pveCity
        for i = 1, #lv do table.insert(ret, lst[lv[i]]) end
        return ret
    end
end
--[Comment]
--有可收获的城池
_get.HasCanSearchPveCity = function(u) u = u.pveCity; for _, v in pairs(u) do if v.CanSearch then return true end end end
--[Comment]
--有副本城池
_get.HasFbPveCity = function(u) u = u.pveCity; for _, v in pairs(u) do if string.notEmpty(v.FbSpecial) and v.fbQty > 0 then return true end end end
--[Comment]
--恢复所有城池的副本数
_get.RestorePveCityFb = function(u) u, qty = u.pveCity, DB.GetVip(u.vip).fbQty or 1; for _, v in pairs(u) do v:SetFbQty(qty) end end
-------------------------------------------------------------------------

-------------------------------PVP城池数据-------------------------------
--[Comment]
--设置PVP区块更新时间
function _user.SetPvpZoneUpTime(zone) u.pvpZoneTm[zone] = os.time() + 60 end
--[Comment]
--PVP区块是否需要更新
function _user.PvpZoneNeedUpdata(zone) zone = u.pvpZoneTm[zone]; return zone == nil or zone < os.time() end
--[Comment]
--清除PVP区块更新时间
function _user.ClearPvpZoneUpTime() u.pvpZoneTm = { } end

--[Comment]
--添加一个新的PVP城池数据(城池编号)
function _user.AddPvpCity(sn)
    if PY_PvpCity.IsPvpCity(sn) then
        local c = u.pvpCity[sn]
        if c == nil then
            c = PY_PvpCity(sn)
            u.pvpCity[sn] = c
        end
        return c
    end
end
--[Comment]
--添加一个区的PVP城池数据(PVP区块信息 d=S_PvpZone)
function _user.AddPvpZone(d)
    local zone = d and d.zone
    if zone then
        d = d.cities
        if d and #d > 0 then
            local c, f = nil, PY_PvpCity.ZonePosToSN
            for i=1,#d do
                c = u.AddPvpCity(f(zone, d[i].pos))
                c:SyncBrief(d[i])
            end
        end
    end
end
---<summary>获取指定编号的PVP城池数据</summary>
---<returns type="PY_PvpCity"></returns>
function _user.GetPvpCity(sn) return u.pvpCity[sn] end
--[Comment]
--我的PVP主城
_get.MyPvpCity = function(u) return u.pvpCity[PY_PvpCity.ZonePosToSN(u.zone, u.pos)] end
--[Comment]
--获取指定区号的已配置区数据的所有城池(区号)
function _user.GetZonePvpCity(zone)
    local ret = { }
    for _, v in pairs(u.pvpCity) do if v.zone == zone and v.IsSetZoneData then table.insert(ret, v) end end
    table.sort(ret, function(x, y) return x.pos < y.pos end)
    return ret
end
--[Comment]
--从主城信息中同步城池占领信息(d=S_TerritoryList)
function _user.SyncColonyFromPvpList(d)
    if d and d.opt == "pvp" then
        local lst, d = { }, d.cities
        for _, v in pairs(u.pvpCity) do if v.IsMyColony then lst[v] = true end end
        if d and #d > 0 then
            local c, cs = nil, u.pvpCity
            for _, v in ipairs(d) do
                c = cs[v.sn]
                if c == nil then
                    c = PY_PvpCity(v.sn)
                    cs[v.sn] = c
                end
                if c then
                    c.occTm.time = v.tm
                    c:SetToMyColony()
                    lst[c] = nil 
                end
            end
        end
        for _, v in pairs(lst) do v:LeaveFromColony() end
    end
end
--[Comment]
--清除所有非我PVP城池数据
function _user.RemoveNotMyPvpCity()
    local cs = u.pvpCity
    for k, v in pairs(cs) do
        if not v.IsMyColony then
            v:CellDead()
            cs[k] = nil
        end
    end
end
-------------------------------------------------------------------------

-------------------------------州郡数据-------------------------------
--[Comment]
--添加州郡数据(d=S_NatState[])
function _user.SyncState(d)
    if d and #d > 0 then
        local s, ss = nil, u.state
        for _, v in ipairs(d) do
            if v.nssn then
                s = ss[v.nssn]
                if s == nil then
                    s = PY_State(d.nssn)
                    ss[d.nssn] = s
                end
                s:Sync(v)
            end
        end
    end
end
---<summary>根据州郡编号获取州郡数据</summary>
---<returns type="PY_State"></returns>
function _user.GetState(sn) return u.state[sn]  end
--[Comment]
--获取所有州郡，按SN排序
function _user.GetStates() return table.findall(u.state) end
----------------------------------------------------------------------

------------------------------联盟战数据------------------------------
--[Comment]
--新增战队。可替换更新同一SN的队伍
function _user.AddTeam(sn, heros, adv, route)
    sn = CheckSN(sn)
    if sn == nil then return end
    if heros then for i = 1, #heros do heros[i] = CheckSN(heros[i]) end end
    local t = u.swarTeam[sn]
    if t then
        t:Init(sn, heros, adv, route)
    else
        t = PY_SwarTeam(sn, heros, adv, route)
        u.swarTeam[sn] = t
    end
end
--[Comment]
--移除战队
function _user.RemoveTeam(sn) u.swarTeam[CheckSN(sn)] = nil end
--[Comment]
--移除所有本地缓存队伍，重置是否同步的标识
function _user.RemoveAllTeams() u.swarTeam, u.isGotTeamInfo = { }, false end
--[Comment]
--更新战队。可只更新某一属性。不更新的属性传入nil
function _user.UpdateTeam(sn, heros, route, adv)
    local t = u.swarTeam[CheckSN(sn)]
    if t then
        if heros then
            for i = 1, #heros do heros[i] = CheckSN(heros[i]) end
            t.heros = heros
        end
        if route and route > 0 then t.route = route end
        if adv and adv > 0 then t.adv = adv end
    end
end
--[Comment]
--获取所有战队中武将
function _user.GetSwarHeros()
    local ret = { }
    for _, v in pairs(u.swarTeam) do
        if v.heros then
            for _, v in pairs(v.heros) do
                v = CheckSN(v)
                if v then table.insert(ret, v) end
            end
        end
    end
    return ret
end

--[Comment]
--获取某条线路所有战队（1-3）
function _user.GetTeams(route)
    local ret = { }
    for _, v in pairs(u.swarTeam) do
        if v.route == route then
            table.insert(ret, v)
        end
    end
    return ret
end
--[Comment]
--是否从服务器同步了联盟战队信息
_get.IsGotSwarTeam = function (u) return u.isGotSwarTeam end
_set.IsGotSwarTeam = function (u, v) u.isGotSwarTeam = v end
----------------------------------------------------------------------

-------------------------------活动数据-------------------------------
--[Comment]
--同步活动数据[d=S_ActData]
function _user.SyncAct(d)
    if d and d.actSN and d.actSN > 0 then
        local a = u.act[d.actSN]
        if a then
            a:Sync(d)
        else
            a = PY_Act(d)
            u.act[d.actSN] = a
        end
        return a
    end
end
---<summary>获取活动数据</summary>
---<returns type="PY_Act"></returns>
function _user.GetAct(asn) return u.act[asn] end
----------------------------------------------------------------------

-------------------------------存档部分-------------------------------
local _us = { }

local function GetPath(psn) return AM.userPath..psn end

-- 酒馆是否刷新了
local _tavRef = false
-- 悬赏任务是否刷新了
local _botRef = false

--[Comment]
--加载存档
function _user.LoadSave()
    if not CheckSN(u.psn) then return end
    print("调用加载存档")
    _us = kjson.decode(File.ReadCETextCRC(GetPath(u.psn))) or { }
    -- 用户编号
    _us.psn = u.psn
    -- 用户账号
    _us.nick = u.nick
    --用户头像
    _us.ava = u.ava
    --用户主城等级
    _us.hlv = u.hlv
    --用户服务器编号
    _us.rsn = u.rsn
    -- 是否是快速注册的用户(1=true)
    _us.tUser = _us.tUser or 0
    -- 新手指导的主步骤
    _us.tutSN = _us.tutSN or 0
    -- 新手指导的子步骤
    _us.tut = _us.tut or 0
    -- 是否自动补血
    _us.aah = _us.aah or 1
    -- 是否自动补兵
    _us.aat = _us.aat or 1
    -- 强化使用道具编号
    _us.uup = _us.uup or 0
    -- 下次需要提示预期时间
    _us.tipTime = _us.tipTime or 0
    -- 上次出战的武将
    _us.lastBH = _us.lastBH or {}
    -- 上次竞技场出战的武将
    _us.lastSBH = _us.lastSBH or {}
    -- 上次退出游戏的时间(S)
    _us.lastQT = _us.lastQT or SVR.SvrTime()
    -- 上次退出游戏时酒馆的冷却时间
    _us.lastTT = _us.lastTT or 0
    -- 上次退出游戏时悬赏任务的冷却时间
    _us.lastBT = _us.lastBT or 0
    -- 上次提示副本的天
    _us.lastTFD = _us.lastTFD or 0
    -- 提示俘虏释放
    _us.tipCF = _us.tipCF or 0
    -- 提示俘虏释放极限值
    _us.tipCFL = _us.tipCFL or 0
    -- 上次BOSS战武将
    _us.lastBBH = _us.lastBBH or {}
    -- 是否使用金币强化装备
    _us.useGUE = _us.useGUE or 0
    -- 是否使用金币培养科技
    _us.useGDT = _us.useGDT or 0
    -- 是否启用战斗加速
    _us.batAclr = _us.batAclr or 1
    -- 上次挑战过关斩将的武将
    _us.lastTBH = _us.lastTBH or {}
    -- 是否首次提示阵型重铸
    _us.tipLR = _us.tipLR or 0
    -- 是否提示国家按钮
    _us.tipCB = _us.tipCB or 0
    -- 是否使用自动战斗
    _us.useAuto = _us.useAuto or 0
    -- 自动使用挑战令
    _us.aut = _us.aut or 0
    -- 是否首次提示将星标识
    _us.tipHSB = _us.tipHSB or 0
    -- 乱世争雄挑战的武将
    _us.clanWH = _us.clanWH or {{},{}}
    -- 黑名单
    _us.blkList = _us.blkList or {}
    -- 是否首次提示锦囊技
    _us.tipHPS = _us.tipHPS or 0
    -- 上次修炼选择的武将
    _us.lastCH = _us.lastCH or 0
    -- 上传播放活动幸运号[20]的编号
    _us.lastA20SN = _us.lastA20SN or 0
    -- 乱世争雄武将性别
    _us.clanWSH = _us.clanWSH or {{},{}}

    local time = DB.NowHour()
    if _us.tipTime > time + 48 then _us.tipTime = time end
    time = SVR.SvrTime()
    if _us.lastQT > time or _us.lastQT <= 0 then _us.lastQT = time end
    -- 设置酒馆是否刷新
    _set.IsTavernRefresh(u, _us.lastTT > 0 and SVR.SvrTime() - _us.lastQT > _us.lastTT)
    -- 检验新手教学
    --[[ ]]
    _us.tipCF = 0
    _us.tipCFL = 0
    -- 加载黑名单
    --[[ ]]
    _user.SaveUserData()

    -- 加载历史消息记录
    -- 加载历史消息记录
    local chats = u.chats
    if #chats < CONFIG.MAX_CHAT - 1 then
        local hist = kjson.decode(File.ReadCEText(GetPath(u.psn)..".chat"))
        if hist and #hist > 0 and (#chats < 1 or chats[1].ts > hist[1].ts) then
            --插入历史标签
            table.insert(chats, 1, PY_Chat.HistChat(hist[1].ts))
            for i = 1, math.min(#hist, CONFIG.MAX_CHAT - #chats) do
                table.insert(chats, 1, setmetatable(hist[i], PY_Chat))
            end
        end
    end
end
--[Comment]
-- 存储用户本地数据
function _user.SaveUserData()
    if CheckSN(_us.psn) then File.WriteCETextCRC(GetPath(_us.psn), kjson.encode(_us)) end
end
--[Comment]
--存储用户聊天记录
function _user.SaveChatHist()
    if CheckSN(u.psn) and #u.chats > 0 then
        local hist = { }
        local chats = u.chats
        for i = math.min(20, #chats), 1, -1 do
            if chats[i].style ~= -1 then
                table.insert(hist, chats[i])
            end
        end
        if #hist > 0 then File.WriteCEText(GetPath(u.psn) .. ".chat", kjson.encode(hist)) end
    end
end

-- 获取新手指导的主步骤
_get.TutorialSN = function (u) return _us.tutSN end
-- 获取新手指导的子步骤
_get.TutorialStep = function (u) return _us.tut end
-- 获取当前用户是否为临时用户
_get.IsTempUser = function (u) return _us.tUser ~= 0 end
-- 获取是否自动补血
_get.IsAutoAddHP = function (u) return _us.aah ~= 0 end
-- 获取是否自动补兵
 _get.IsAutoAddTP = function (u) return _us.aat ~= 0 end
-- 获取强化使用道具(>0 道具编号，else 不使用)
_get.UpUseProps = function (u) return _us.uup end
-- 获取是否需要提示副本
_get.IsTipHistory = function (u) return _us.lastTFD < os.date("*t").day end
-- 获取是否提示俘虏释放
_get.IsTipCaptiveFree = function (u) return _us.tipCF == 0 end
-- 获取是否提示俘虏释放极限
_get.IsTipCaptiveFreeLimit = function (u) return _us.tipCFL == 0 end
-- 获取首次阵型重铸是否提示
_get.IsTipLineupReset = function (u) return _us.tipLR == 0 end
-- 获取是否首次提示国家按钮
_get.IsTipCountryBtn = function (u) return _us.tipCB == 0 end
-- 获取首次提示将星按钮
_get.IsTipHeroStarBtn = function (u) return _us.tipHSB == 0 end
-- 获取首次提示锦囊技
_get.IsTipHeroSkp = function (u) return _us.tipHPS == 0 end
-- 获取是否使用金币强化装备
_get.IsUseGoldUpEquip = function (u) return _us.useGUE ~= 0 end
-- 获取是否使用金币培养科技
_get.IsUseGoldDevTech = function (u) return _us.useGDT ~= 0 end
-- 获取用户是否是自动战斗状态
_get.IsUseAutoFight = function(u) return _us.useAuto ~= 0 end
-- 获取是否启用战斗加速
_get.IsBattleAccelerate = function (u) return _us.batAclr ~= 0 end
-- 获取是否自动使用挑战令
_get.IsAutoUseTicket = function (u) return _us.aut ~= 0 end
-- 获取用户本地黑名单
_get.BlackList = function (u) return _us.blkList end
-- 获取上次修炼选择的武将
_get.CultiveHero = function (u) return _us.lastCH end
-- 获取上次播放活动幸运号[20]的编号
_get.Act20Sn = function (u) return _us.lastA20SN end
-- 获取酒馆是否刷新了
_get.IsTavernRefresh = function (u) return _tavRef end
-- 获取悬赏任务是否刷新了
_get.BountyRefresh = function (u) return _botRef end
-- 获取下次提示预期时间
_get.TipTime = function (u) return _us.tipTime end
-- 获取上次出战的武将
_get.LastBattleHero = function (u)
    local hs = { }
    for i = 1, #_us.lastBH do table.insert(hs, user.GetHero(_us.lastBH[i])) end
    return table.findall(hs, function (hd) return hd and tonumber(hd.sn) > 0 end)
end
-- 获取上次退出游戏的时间
_get.LastQuitTime = function (u) return _us.lastQT end
-- 获取上次BOSS战武将
_get.LastBossBattleHero = function (u)
    local hs = { }
    for i = 1, #_us.lastBBH do table.insert(hs, user.GetHero(_us.lastBBH[i])) end
    return table.findall(hs, function (hd) return hd and tonumber(hd.sn) > 0 end)
end
-- 获取上次挑战过关斩将的武将
_get.TowerBattleHero = function (u)
    local hs = { }
    for i = 1, #_us.lastTBH do table.insert(hs, user.GetHero(_us.lastTBH[i])) end
    return table.findall(hs, function (hd) return hd and tonumber(hd.sn) > 0 end)
end
-- 获取上次乱世争雄的武将
function _user.GetClanWarHero(c)
    local hs = { }
    if _us.clanWH[c] then
    for i = 1, #_us.clanWH[c] do table.insert(hs, user.GetHero(_us.clanWH[c][i])) end
    end
    return table.findall(hs, function (hd) return hd and hd.sn > 0 end)
end
-- 获取乱世争雄武将性别
function _user.GetClanWarSexHero (s)
    local hs = { }
    for i = 1, #_us.clanWSH[s] do table.insert(hs, user.GetHero(_us.clanWSH[s][i])) end
    return table.findall(hs, function (hd) return hd and hd.sn > 0 end)
end

-- 设置新手指导的主步骤{arg[number], return[]}
_set.TutorialSN = function(u, v)
    if _us.tutSN == v then return end
    _us.tutSN = v or 0
    _user.SaveUserData()
end
-- 设置新手指导的子步骤
_set.TutorialStep = function (u, v)
    if _us.tut == v then return end
    _us.tut = v
    _user.SaveUserData()
end
-- 设置当前用户是否为临时用户
_set.IsTempUser = function (u, v)
    if _user.IsTempUser == v then return end
    _us.tUser = v and 1 or 0
    _user.SaveUserData()
end
-- 设置是否自动补血
_set.IsAutoAddHP = function (u, v)
    if _user.IsAutoAddHP == v then return end
    _us.aah = v and 1 or 0
    _user.SaveUserData()
end
-- 设置是否自动补兵
_set.IsAutoAddTP = function (u, v)
    if _user.IsAutoAddHP == v then return end
    _us.aat = v and 1 or 0
    _user.SaveUserData()
end
-- 设置强化使用道具(>0 道具编号，else 不使用)
_set.UpUseProps = function (u, v)
    if _us.uup == v then return end
    _us.uup = v
    _user.SaveUserData()
end
-- 设置是否需要提示副本
_set.IsTipHistory = function (u, v)
    if _user.IsTipHistory() == v then return end
    _us.lastTFD = v and 0 or os.date("*t").day
    _user.SaveUserData()
end
-- 设置是否提示俘虏释放x
_set.IsTipCaptiveFree = function (u, v)
    if _user.IsTipCaptiveFree == v then return end
    _us.tipCF = v and 0 or 1
    _user.SaveUserData()
end
-- 设置是否提示俘虏释放极限
_set.IsTipCaptiveFreeLimit = function (u, v)
    if _user.IsTipCaptiveFreeLimit == v then return end
    _us.tipCFL = v and 0 or 1
    _user.SaveUserData()
end
-- 设置首次阵型重铸是否提示
_set.IsTipLineupReset = function (u, v)
    if _user.IsTipLineupReset == v then return end
    _us.tipLR = v and 0 or 1
    _user.SaveUserData()
end
-- 设置是否首次提示国家按钮
_set.IsTipCountryBtn = function (u, v)
    if _user.IsTipCountryBtn == v then return end
    _us.tipCB = v and 0 or 1
    _user.SaveUserData()
end
-- 设置首次提示将星按钮
_set.IsTipHeroStarBtn = function (u, v)
    if _user.IsTipHeroStarBtn == v then return end
    _us.tipHSB = v and 0 or 1
    _user.SaveUserData()
end
_set.IsTipHeroSkp = function (u, v)
    if _user.IsTipHeroSkp == v then return end
    _us.tipHPS = v and 0 or 1
    _user.SaveUserData()
end
-- 设置首次提示锦囊技
_set.IsTipSkp = function (u, v)
    if _user.IsTipSkp == v then return end
    _us.tipHPS = v and 0 or 1
    _user.SaveUserData()
end
-- 设置是否使用金币强化装备
_set.IsUseGoldUpEquip = function (u, v)
    if _user.IsUseGoldUpEquip == v then return end
    _us.useGUE = v and 1 or 0
    _user.SaveUserData()
end
-- 设置是否使用金币培养科技
_set.IsUseGoldDevTech = function (u, v)
    if _user.IsUseGoldDevTech == v then return end
    _us.useGDT = v and 1 or 0
    _user.SaveUserData()
end
-- 设置是否启用战斗加速
_set.IsBattleAccelerate = function (u, v)
    if _user.IsBattleAccelerate == v then return end
    _us.batAclr = v and 1 or 0
    _user.SaveUserData()
end
-- 设置是否自动使用挑战令
_set.IsAutoUseTicket = function (u, v)
    if _user.IsAutoUseTicket == v then return end
    _us.aut = v and 1 or 0
    _user.SaveUserData()
end
-- 设置用户本地黑名单
_set.BlackList = function (u, v)
    local temp = {}
    for i = 1, 6 do
        temp[i] = hs[i]
    end
    _us.blkList = temp
    _user.SaveUserData()
end
-- 设置上次修炼选择的武将
_set.CultiveHero = function (u, v)
    if _us.lastCH == v then return
    elseif v > 0 then _us.lastCH = v end
    _user.SaveUserData()
end
-- 设置上次播放活动幸运号[20]的编号
_set.Act20Sn = function (u, v)
    if _us.lastA20SN == v then return end
    _us.lastA20SN = v
    _user.SaveUserData()
end
-- 设置酒馆是否刷新了
_set.IsTavernRefresh = function (u, v)
    if _tavRef == v then return end
    _tavRef = v
    if not _tavRef and _us.lastTT > 0 then
        _us.lastTT = 0
        _user.SaveUserData()
    end
end
--设置是否使用自动战斗
_set.IsUseAutoFight = function(u, v)
    if _us.useAuto == v then return end
    _us.useAuto = v and 1 or 0
    _user.SaveUserData()
end
-- 设置悬赏任务是否刷新了
 _set.BountyRefresh = function(u, v)
    if _botRef == v then return end
    _botRef = v
    if not _botRef and _us.lastBT > 0 then
        _us.lastBT = 0
        _user.SaveUserData()
    end
end
-- 设置下次提示预期时间
_set.TipTime = function (u, v)
    if _us.tipTime == v then return end
    _us.tipTime = v
    _user.SaveUserData()
end
-- 设置上次出战的武将
_set.LastBattleHero = function (u, hs)
    print("LastBattleHero    ",kjson.print(hs))
    if not hs or not isTable(hs) then return end
    local tmp = { }
    if isString(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i] end
    elseif isTable(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i].sn end
    end
    _us.lastBH = tmp
    _user.SaveUserData()
end
---<summary>获取竞技场出战武将</summary>
---<returns type="PY_Hero"></returns>
function _user.GetSoloBattleHero(u)
    local hs = { }
    for i = 1, #_us.lastSBH do table.insert(hs, user.GetHero(_us.lastSBH[i])) end
    return table.findall(hs, function (hd) return hd and tonumber(hd.sn) > 0 end)
end
---<summary>设置竞技场出战武将</summary>
function _user.SetSoloBattleHero(u, hs)
    if not hs or not isTable(hs) then return end
    local tmp = { }
    if isString(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i] end
    elseif isTable(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i].sn end
    end
    _us.lastSBH = tmp
    _user.SaveUserData()
end
-- 设置上次BOSS战武将
_set.LastBossBattleHero = function (u, hs)
    if not hs or not isTable(hs) then return end
    local tmp = { }
    if isString(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i] end
    elseif isTable(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i].sn end
    end
    _us.lastBBH = tmp
    _user.SaveUserData()
end
-- 设置上次挑战过关斩将的武将
_set.TowerBattleHero = function (u, hs)
    if not hs or not isTable then return end
    local tmp = { }
    if isString(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i] end
    elseif isTable(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i].sn end
    end
    _us.lastTBH = tmp
    _user.SaveUserData()
end
-- 设置上次乱世争雄的武将
function _user.SetClanWarHero (c, hs)
    if c < 0 or not hs or not isTable then return end
    local tmp = { }
    if isNumber(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i] end
    elseif isTable(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i].sn end
    end
    _us.clanWH[c] = tmp
end
-- 设置乱世争雄武将性别
function _user.SetClanWarSexHero (s, hs)
    if s < 0 or not hs or not isTable then return end
    local tmp = { }
    if isNumber(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i] end
    elseif isTable(hs[1]) then
        for i = 1, #hs do tmp[i] = hs[i].sn end
    end
    _us.clanWSH[s] = tmp
end

--[Comment]
-- 游戏退出时保存{arg[], return[]}
function _user.QuitSave()
    _us.lastQT = SVR.SvrTime()
    -- 保存酒馆刷新
    --[[ ]]
    -- 保存悬赏任务刷新
    --[[ ]]
    _user.SaveUserData()
    --保存聊天记录
    _user.SaveChatHist()
end

----------------------------------------------------------------------