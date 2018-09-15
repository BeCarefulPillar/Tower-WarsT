
--活动表          act.lua
require "Data/DB_Act"
--兵种            soldier.lua
require "Data/DB_Arm"
--头像            avatar.lua
require "Data/DB_Avatar"
--联盟悬赏任务    guild_quest.lua
require "Data/DB_AllyQst"
--出战BUFF        buff.lua
require "Data/DB_Buff"
--城池信息        gamelv2.lua
require "Data/DB_City"
--装备            equip.lua
require "Data/DB_Equip"
--装备套装        equip_suit.lua
require "Data/DB_EquipSuit"
--宝石            gem.lua
require "Data/DB_Gem"
--将领信息        hero.lua
require "Data/DB_Hero"
--将星升级信息    hero_star.lua
require "Data/DB_HeroStar"
--阵形信息        lineup.lua
require "Data/DB_Lnp"
--道具信息        props.lua
require "Data/DB_Props"
--技能 武将技能   skill_c.lua
require "Data/DB_SKC"
--技能 觉醒技     skill_e.lua
require "Data/DB_SKE"
--技能 锦囊技     skill_p.lua
require "Data/DB_SKP"
--技能 军师技     skill_t.lua
require "Data/DB_SKT"
--名人堂          DB_Fame.lua（包内）
require "Data/DB_Fame"
--vip特权描述     vip_i.lua（包内）
require "Data/vip_i"
--对话(俘虏,对战,关卡,酒馆)    Dialogue.lua（包内）
require "Data/Dialogue" 
--地宫地图数据    DB_GveData(包内)
require "Data/DB_GveData"


--require "Data/DB_Beauty"    --铜雀台（没做）
--require "Data/DB_Dehero"    --副将（没做）
--require "Data/DB_Dequip"    --副将装备（没做）
--require "Data/DB_Httl"      --玩家称号（没做）
--require "Data/DB_NatState"  --州郡信息（没做）
--require "Data/DB_Sexcl"     --天机（没做）
--require "Data/DB_SKD"       --副将技（没做）
--require "Data/DB_SKS"       --天机技（没做）
--require "Data/SH_Hero"      --分享武将（没做）
--require "Data/SH_Equip"     --分享装备（没做）
--require "Data/SH_DeHero"    --分享副将（没做）
--require "Data/SH_DeEquip"   --分享副将装备（没做）

local inesrt = table.insert
local pairs = pairs
local ipairs = ipairs

--[Comment]
--通用未定义对象
local _undef = { getName = function(t) return LN(t and t.nm or nil) end, getIntro = function(t) return L(t and t.i) end }
_undef.__index = function(t, k) return rawget(_undef, k) or 0 end
setmetatable(_undef, _undef)
--[Comment]
--联盟科技[1=STR 2=CAP 3=INT]
local _allyTech = { "str","cap","wis" }

--[Comment]
--数据库
local _db =
{
    --[Comment]
    --游戏参数
    param = nil,
    --[Comment]
    --游戏功能解锁数据
    unlock = nil,
    --[Comment]
    --游戏提示
    gameTip = nil,

    --[Comment]
    --VIP等级
    vip = nil,
    --[Comment]
    --主城等级
    home = nil,
    --[Comment]
    --爵位
    ttl = nil,
    --[Comment]
    --荣誉称号
    httl = nil,
    --[Comment]
    --头像
    ava = nil,

    --[Comment]
    --主关卡
    gmLv = nil,
    --[Comment]
    --关卡城池
    gmCity = nil,
    --[Comment]
    --战役主章节
    gmWar = nil,
    --[Comment]
    --战役子关卡
    gmWarSub = nil,
    --[Comment]
    --乱世争雄
    gmClan = nil,
    --[Comment]
    --幻境挑战
    fantsy = nil,

    --[Comment]
    --道具
    props = nil,
    --[Comment]
    --任务
    quest = nil,
    --[Comment]
    --成就
    achv = nil,
    --[Comment]
    --天机专属
    sexcl = nil,
    --[Comment]
    --天机属性
    satt = nil,
    --[Comment]
    --日常功能
    daily = nil,
    --[Comment]
    --日常奖励(动态加载)
    dailyRw = nil,
    --[Comment]
    --铜雀台
    beauty = nil,
    --[Comment]
    --国战日常奖励(动态加载)
    natdailyRw = nil,

    --[Comment]
    --武将
    hero = nil,
    --[Comment]
    --武将等级
    heroLv = nil,
    --[Comment]
    --武将稀有度
    heroRare = nil,
    --[Comment]
    --武将官职
    heroTtl = nil,
    --[Comment]
    --军阶突破
    heroAdv = nil, 
    --[Comment]
    --武将星级
    heroStar = nil,
    --[Comment]
    --武将天机等级
    heroSlv = nil,

    --[Comment]
    --装备
    equip = nil,
    --[Comment]
    --装备等级
    equipLv = nil,
    --[Comment]
    --装备稀有度
    equipRare = nil,
    --[Comment]
    --装备套装
    equipSuit = nil,

    --[Comment]
    --副将
    dehero = nil,
    --[Comment]
    --副将等级
    deheroLv = nil,
    --[Comment]
    --副将星级
    deheroStar = nil,
    --[Comment]
    --副将军备
    dequip = nil,
    --[Comment]
    --副将军备等级
    dequipLv = nil,

    --[Comment]
    --宝石
    gem = nil,

    --[Comment]
    --武将技
    skc = nil,
    --[Comment]
    --武将技五行
    fe = nil,
    --[Comment]
    --武将技五行等级
    feLv = nil,

    --[Comment]
    --军师技
    skt = nil,
    --[Comment]
    --觉醒技
    ske = nil,
    --[Comment]
    --锦囊技
    skp = nil,
    --[Comment]
    --副将技
    skd = nil,
    --[Comment]
    --天机技
    sks = nil,

    --[Comment]
    --兵种
    arm = nil,
    --[Comment]
    --兵种等级
    armLv = nil,
    --[Comment]
    --阵型
    lnp = nil,
    --[Comment]
    --阵型铭刻属性
    lnpExt = nil,
    --[Comment]
    --阵型铭刻属性Mark
    lnpExtMark = nil,

    --[Comment]
    --联盟等级
    allyLv = nil,
    --[Comment]
    --联盟任务
    allyQuest = nil,

    --[Comment]
    --国战国家
    nat = nil,
    --[Comment]
    --国战国家等级数据
    natLv = nil,
    --[Comment]
    --国战城池
    natCity = nil,
    --[Comment]
    --国战州郡
    natState = nil,
    --[Comment]
    --国战矿脉
    natMine = nil,
    --[Comment]
    --国战活跃
    nact = nil,

    --[Comment]
    --活动
    act = nil,
    --[Comment]
    --活动红包
    actRed = nil,
    --[Comment]
    --占卜
    divine = nil,
    --[Comment]
    --宴会
    feast = nil,
    --[Comment]
    --等级礼包
    giftHLv = nil,
    --[Comment]
    --属性说明
    atti = nil,
    --[Comment]
    --战出BUFF
    buff = nil,
    --[Comment]
    --完美条件描述
    pdesc = nil,

    --[Comment]
    --TCG技能(动态加载)
    tcgSkill = nil,
    --[Comment]
    --TCG阵营(动态加载)
    tcgClan = nil,

    --------------------其它固有数据--------------------
    --[Comment]
    --性别名称[1:男,2:女]
    sexNm = { "男", "女" },
    --[Comment]
    --周名称表[1:一,2:二,3:三,4:四,5:五,6:六,7:日]
    weekNm = { "一", "二", "三", "四", "五", "六", "日" },
    --[Comment]
    --国家名称[0:群,1:魏,2:蜀,3:吴]
    natNm = { "群", "魏", "蜀", "吴", "蛮" },
    --[Comment]
    --阵营名称[1:魏国,2:蜀国,3:吴国,0:群雄]
    clanNm = { "魏", "蜀", "吴" },
    --[Comment]
    --基础属性名称[武力 智力 统帅 生命 技力 兵力]
    baseAttNm = { "武力", "智力", "统帅", "生命", "技力", "兵力" },
    --[Comment]
    --基础属性简称[武 智 统 命 技 兵]
    baseAttSNm = { "武", "智", "统", "命", "技", "兵" },
    --[Comment]
    --将领类型[武 智 统]
    kindNm = { "武将", "智将", "统将"},
    --[Comment]
    --兵种显示偏移
    armOffset = { Vector2(-11, -6), Vector2(-12, -5), Vector2(-6, -5), 
                Vector2(-11, -10), Vector2(7, -7), Vector2(-15, -8), 
                Vector2(-6, -9), Vector2(-1, -10), Vector2(-7, -3), 
                Vector2(-11, -9), Vector2(-8, -8), Vector2(1, -9) },
    --------------------其它运算数据--------------------
    --[Comment]
    --最大VIP
    maxVip = 0,
    --[Comment]
    --主城最大等级
    maxHlv = 0,
    --[Comment]
    --最高爵位
    maxTtl = 0,

    --[Comment]
    --联盟最大等级
    maxAllyLv = 0,
    --[Comment]
    --科技的最大数目
    maxTechQty = #_allyTech,
    --[Comment]
    --国家最大等级
    maxNatLv = 0,

    --[Comment]
    --最大关卡数
    maxGmLv = 0,
    --[Comment]
    --最大城池数
    maxCityQty = 0,
    --[Comment]
    --城池最高等级
    maxCityLv = 0,

    --[Comment]
    --武将最大等级
    maxHeroLv = 0,
    --[Comment]
    --武将最大等阶
    maxHeroEvo = 0,
    --[Comment]
    --武将最大官阶
    maxHeroTtl = 0,
    --[Comment]
    --武将最高军阶需要的荣誉
    maxHeroTtlMerit=0,
    --[Comment]
    --武将最高军阶突破
    maxHeroTtlAdv=0,
    --[Comment]
    --武将最高将星
    maxHeroStar = 0,
    --[Comment]
    --武将最高天机等级
    maxHeroSlv = 0,

    --[Comment]
    --装备最大等级
    maxEquipLv = 0,

    --[Comment]
    --最大兵种数量
    maxArmQty = 0,
    --[Comment]
    --最大兵种等级
    maxArmLv = 0,
    --[Comment]
    --最大阵形数量
    maxLnpQty = 0,

    --[Comment]
    --副将最高等级
    maxDeheroLv = 0,
    --[Comment]
    --副将最高星级
    maxDeheroStar = 0,
    --[Comment]
    --军备最高等级
    maxDequipLv = 0,
    
    --[Comment]
    --五行最高等级
    maxFeLv = 0,

}
--[Comment]
--数据库
DB = _db
--加载内置数据
require("Data/param")
require("Data/unlock")
require("Data/game_tip")

--加载协同
local _loadCo = nil

--[Comment]
--文字过滤
local _filter = WordFilter

--[Comment]
--数据配置
local _profile =
{
    vip         = { fn = "vip" },                                               --vip特权功能
    home        = { fn = "home", w = true },                                    --主城等级信息
    ttl         = { fn = "title" },                                             --加官进爵（爵位）
    ava         = { fn = "avatar", mt = DB_Avatar },                            --头像

    gmLv        = { fn = "gamelv1" },                                           --大关卡信息
    gmCity      = { fn = "gamelv2", mt = DB_City, w = true },                   --关卡城池信息
    gmWar       = { fn = "gameext1" },                                          --战役大关卡
    gmWarSub    = { fn = "gameext2" },                                          --战役小关卡
    gmClan      = { fn = "game_clan" },                                         --乱世争雄

    props       = { fn = "props", mt = DB_Props, w = true },                    --道具
    quest       = { fn = "quest", w = true },                                   --任务

    hero        = { fn = "hero", mt = DB_Hero, w = true },                      --将领数据
    heroLv      = { fn = "hero_lv" },                                           --将领升级经验
    heroRare    = { fn = "hero_rare" },                                         --将领稀有度数据
    heroTtl     = { fn = "hero_title", w = true },                              --将领军阶                        
    heroStar    = { fn = "hero_star", mt = DB_HeroStar },                       --将领星级

    equipLv     = { fn = "equip_lv" },                                          --装备等级信息
    equipRare   = { fn = "equip_rare" },                                        --装备稀有度信息
    equipSuit   = { fn = "equip_suit", mt = DB_EquipSuit },                     --装备套装信息
    equip       = { fn = "equip", mt = DB_Equip, w = true },                    --装备信息

    gem         = { fn = "gem", mt = DB_Gem, w = true },                        --宝石信息

    skc         = { fn = "skill_c", mt = DB_SKC, w = true },                    --将领技能
    skt         = { fn = "skill_t", mt = DB_SKT },                              --将领军师技
    ske         = { fn = "skill_e", mt = DB_SKE },                              --将领觉醒技
    skp         = { fn = "skill_p", mt = DB_SKP },                              --将领锦囊技

    arm         = { fn = "soldier", mt = DB_Arm },                              --兵种信息
    armLv       = { fn = "soldier_lv" },                                        --兵种等级信息
    lnp         = { fn = "lineup", mt = DB_Lnp },                               --阵形信息
    lnpExt      = { fn = "lineup_ext", w = true },                              --阵形铭刻

    allyLv      = { fn = "guild_lv" },                                          --联盟等级信息（包括联盟科技）
    allyQuest   = { fn = "guild_quest", w = true },                             --联盟悬赏任务

    nat         = { fn = "nat" },                                               --国战国家信息
    natLv       = { fn = "nation_lv" },                                         --国战国家等级信息
    natCity     = { fn = "nation" },                                            --国战城池信息

    act         = { fn = "act", mt = DB_Act },                                  --活动数据
    actRed      = { fn = "red" },                                               --红包活动
    divine      = { fn = "turn2" },                                             --占卜
    giftHLv     = { fn = "gift_hlv" },                                           --等级礼包
    atti        = { fn = "atti" },                                              --属性词条信息
    buff        = { fn = "buff", DB_Buff },                                     --出战BUFF


--    httl        = { fn = "htitle", mt = DB_Httl, w = true },                  --称号(没做)

--    fantsy      = { fn = "fantsy", w = true },                                --幻境挑战(没做)

--    achv        = { fn = "achv", w = true },                                  --成就(没做)
--    sexcl       = { fn = "sexcl", mt = DB_Sexcl },                            --天机(没做)
--    satt        = { fn = "satt" },                                            --天机属性(没做)
--    beauty      = { fn = "beauty", mt = DB_Beauty, w = true },                --铜雀台（没做）

--    heroAdv     = { fn = "hero_title_adv"},                                   --将领突破
--    heroSlv     = { fn = "hero_slv", w = true },                              --将领天机等级

--    dehero      = { fn = "dehero", mt = DB_Dehero },                          --副将（没做）
--    deheroLv    = { fn = "dehero_lv" },                                       --副将等级信息（没做）
--    deheroStar  = { fn = "dehero_star" },                                     --副将星级信息（没做）
--    dequip      = { fn = "dequip", mt = DB_Dequip },                          --副将装备信息（没做）
--    dequipLv    = { fn = "dequip_lv", w = true },                             --副将装备等级信息（没做）

--    fe          = { fn = "fe" },                                              --技能五行
--    feLv        = { fn = "felv" },                                            --技能五行等级
--    skd         = { fn = "skill_d", mt = DB_SKD, w = true },                  --副将技能
--    sks         = { fn = "skill_s", mt = DB_SKS, w = true },                  --将领天机技

--    natState    = { fn = "state", mt = DB_NatState },                         --国战州郡信息（没做）
--    natMine     = { fn = "nmine" },                                           --国战矿脉信息（没做）
--    nact        = { fn = "nact", w = true },                                  --国战活跃（换成国战日常）

--    feast       = { fn = "feast" },                                           --宴会（帝国宴会不是这个）
--    pdesc       = { fn = "pdesc", w = true },                                 --幻境完美通关条件
}
------------用时加载------------
--点石成金	            g2c
--名将谱	            hero_atlas
--国战活跃宝箱	        nat_daily_box
--地宫属性词条	        palace_att
--地宫房间BUFF	        palace_trap
--竞技场积分奖励	    rank_jf_rw
--竞技场排行奖励	    rank_rw
--兵种BUFF	            soldier_buff
--七日目标	            target7
--国家个人科技	        tech_p
--决斗	                tower
--决斗奖励	            tower_rw
--天降秘宝	            treasure
--战役转盘	            turntable
--vip礼包（商城购买）	vip_gifts
--帮助	                help
--规则	                rule
--嘉年华活动	        affair
--小助手提示	        assistant_tips
--国战帮助提示	        country_tips
--下一个解锁	        next_unlock
--新手指导	            tutorial


--俘虏对话 dlg_captive
--战斗对话 dlg_fight
--关卡对话 dlg_lv1
--酒馆对话 dlg_tavern

--TCG技能 tcg_skill
--TCG阵营 tcg_clan


--------------------------------


------------加载相关------------
--校检运算数据
local function Check()
    local tmp
    local len = table.maxn
    _db.maxVip = len(_db.vip)
    _db.maxHlv = len(_db.home)
    _db.maxTtl = len(_db.ttl)
    _db.maxAllyLv = len(_db.allyLv)
    _db.maxNatLv = len(_db.natLv)
    _db.maxGmLv = len(_db.gmLv)
    _db.maxCityQty = len(_db.gmCity)
    _db.maxCityLv = _db.param.mlvCity
    _db.maxHeroLv = len(_db.heroLv)
    tmp = _db.heroRare and _db.heroRare[MAIN_HERO_RARE]
    tmp = tmp and tmp.eSoul
    _db.maxHeroEvo = tmp and #tmp or 0
    _db.maxHeroTtl = len(_db.heroTtl)

    _db.maxHeroStar = len(_db.heroStar)
    _db.maxEquipLv = len(_db.equipLv)
    _db.maxArmQty = len(_db.arm)
    _db.maxArmLv = len(_db.armLv)
    _db.maxLnpQty = len(_db.lnp)
--    _db.maxHeroTtlMerit=len(_db.heroAdv)    --军阶突破
--    _db.maxHeroTtlAdv=_db.heroAdv           --军阶突破
--    _db.maxHeroSlv = len(_db.heroSlv)       --将领天机
--    _db.maxDeheroLv = len(_db.deheroLv)     --副将等级
--    _db.maxDeheroStar = len(_db.deheroStar) --副将星级
--    _db.maxDequipLv = len(_db.dequipLv)     --副将军备
--    _db.maxFeLv = len(_db.feLv)             --五行

    --阵形铭刻属性Mark
    tmp = { }
    for k, _ in pairs(_db.lnpExt) do inesrt(tmp, k) end
    table.sort(tmp, ExtAtt.MarkSort)
    _db.lnpExtMark = tmp
end

local function LoadFile(fn, mt)
    local dat = dofile("Data/"..fn)
    if mt and dat then
--        if type(dat) == "string" then print("load db file error:"..fn, dat) end
        for _, v in pairs(dat) do setmetatable(v, mt) end
    end
    return dat or {}
end
--协同加载
local function CoLoad()
    local ret, d
    local stp = StatusBar.ShowR(ST_ID.LOAD_DB)

    ToolTip.ShowGameTip(true)

    _filter.Import(AM.LoadText("dat_word_filter"))
    AM.UnLoadAsset("dat_word_filter")

    for k, d in pairs(_profile) do
        ret, DB[k] = pcall(LoadFile, d.fn, d.mt)
        if not ret or type(DB[k]) ~= "table" then
            print(k, d.fn, "load error : ", DB[k])
            ret = false
            break
        end
        if d.w then coroutine.step() end
    end

    _loadCo = nil

    if stp then stp:Done() end

    if ret then
        Check()
        DB.isLoaded = true
        Game.StartDone()
    else
        MsgBox.Show(L("数据异常，请稍后重试"), DB.Load)
    end
end
--直接加载
local function Load()
    local ret, d
    local stp
    if CS.onMainThread() then
        _filter.Import(AM.LoadText("dat_word_filter"))
        AM.UnLoadAsset("dat_word_filter")
    else
        stp = CS.RunOnMainThread(StatusBar.Get, ST_ID.LOAD_LUA)
        _filter.Import(CS.RunOnMainThread(AM.LoadText, "dat_word_filter"))
        CS.RunOnMainThread(AM.UnLoadAsset, "dat_word_filter")
    end
    local s = 62
--    for _, _ in pairs(_profile) do s = s + 1 end
    for k, d in pairs(_profile) do
        ret, DB[k] = pcall(LoadFile, d.fn, d.mt)
        if not ret or type(DB[k]) ~= "table" then
            print(k, d.fn, "load error : ", DB[k])
            ret = false
            break
        end
        if stp then stp.process = i / s end
    end

    _loadCo = nil

    if ret then Check() end

    DB.isLoaded = ret
end
--[Comment]
--初始加载
function _db.Load()
    if CS.onMainThread() then
        if _loadCo and "dead" ~= coroutine.status(_loadCo) then return end
        _loadCo = coroutine.create(CoLoad)
        coroutine.resume(_loadCo)
    else
        Load()
    end
end
--[Comment]
--加载文件(fn, mt) return table
--_db.LoadFile = LoadFile

--[Comment]
--重新加载
local function ReLoad(nm)
    local p = _profile[nm]
    local ret, dat = nil, nil
    if p then
        ret, dat = pcall(LoadFile, p.fn, p.mt)
    else
        ret, dat = pcall(LoadFile, nm)
    end
    if ret then _db[nm] = dat; return dat end
end
local function CoReLoad(nm, nf)
    local fn = _profile[nm]
    fn = "Data/"..(fn and fn.fn or nm)
    local www = UE.WWW(AM.luaUrl..fn..".dat")
    coroutine.www(www)
    local err = www.error
    if err == nil or err == "" then
        File.WriteByte(AM.luaPath..CS.MD5(fn), www.bytes)
        nm = ReLoad(nm)
        nf(nm == nil)
    else
        print("reload [".. nm .. ",url="..www.url .. "] error : ".. print(err))
        nf(true)
    end
end
--[Comment]
--重加载文件
--nm : 名称
--nf : 网络下载侦听(若有则网络加载)
function _db.ReLoad(nm, nf) if nf then coroutine.start(CoReLoad, nm, nf) else return ReLoad(nm) end end
---------------------------------


----------------数据获取----------------
--[Comment]
--查找表的元素到数组
local function Find2Arr(t, f)
    local arr = { }
    if f then
        for _, v in pairs(t) do if f(v) then inesrt(arr, v) end end
    else
        for _, v in pairs(t) do inesrt(arr, v) end
    end
    return arr
end

--[Comment]
--是否是未定义的
function _db.IsUndef(d) return d == _undef end
--[Comment]
--获取指定名称的数据集
function _db.Get(nm) return _db[nm] or ReLoad(nm) end
--[Comment]
--获取VIP描述
function _db.GetVipIntro(index) return vip[index] or "未知" end
--[Comment]
--和谐检测
function _db.HX_Check(str) return string.hasJsonChar(str) or _filter.Check(str) end
--[Comment]
--和谐过滤转换
function _db.HX_Filter(str) return _filter.Filter(str) end
--[Comment]
--获取属性词条说明
function _db.GetAttIntro(k) return L(_db.atti[k]) or "" end
--[Comment]
--获取属性词条
function _db.GetAttWord(att) return string.format(L(_db.atti[att[1]]), att[2] or 0) end
--[Comment]
--获取属性词条
function _db.GetAttWordKV(k, v) return string.format(L(_db.atti[k]), v or 0) end
--[Comment]
--获取属性集合词条
function _db.GetAttsWord(atts)
    local str = ""
    if atts then
        for _, a in ipairs(atts) do
            str = str .. "\n" .. string.format(L(_db.atti[a[1]]), a[2] or 0)
        end
    end
    return str
end

------------玩家相关数据获取------------
--[Comment]
--获取vip等级数据
function _db.GetVip(lv) return _db.vip[math.clamp(lv or 0, 0, _db.maxVip)] or _undef end
--[Comment]
--获取vip等级
function _db.GetVipLv(f) local tb = _db.vip; for i = 0, _db.maxVip do if f(tb[i]) then return i end end; return 0 end
--[Comment]
--获取主城等级数据
function _db.GetHome(lv) return _db.home[math.clamp(lv or 1, 1, _db.maxHlv)] or _undef end
--[Comment]
--获取爵位等级数据
function _db.GetTtl(lv) return _db.ttl[math.clamp(lv or 1, 1, _db.maxTtl)] or _undef end
--[Comment]
--获取头像
function _db.GetAvatar(sn) return _db.ava[sn] or DB_Avatar.undef end
--[Comment]
--获取荣誉称号
function _db.GetHttl(sn) return _db.httl[sn] or DB_Httl.undef end
--[Comment]
--获取所有荣誉称号
function _db.GetAllHttl(f) return Find2Arr(_db.httl, f) end
--[Comment]
--获取任务数据
function _db.GetQuest(sn) return _db.quest[sn] or _undef end
--[Comment]
--获取成就数据
function _db.GetAchv(sn) return _db.achv[sn] or DB_Achv.undef end
function _db.AllAchv(f) return Find2Arr(_db.achv, f) end
----------------------------------------

------------武将相关数据获取------------
--[Comment]
--获取武将数据
function _db.GetHero(sn) return _db.hero[sn] or DB_Hero.undef end
--[Comment]
--获取所有武将(可带过滤函数)
function _db.AllHero(f) return Find2Arr(_db.hero, f) end
--[Comment]
--通过名称获取武将数据
function _db.GetHeroByNm(nm)
    if nm then
        local ei = string.find(nm, "+", true)
        if ei > 1 then nm = string.sub(nm, 1, ei - 1) end
        for _, v in pairs(_db.hero) do if nm == v.nm then return v end end
    end
    return DB_Hero.undef
end
 --[Comment]
--获取给定武将等级的总经验值
 function _db.GetHeroLvExp(lv) return lv and lv > 0 and _db.heroLv[math.min(lv, _db.maxHeroLv)] or 0 end
--[Comment]
--获取给定武将等级的总经验值
 function _db.GetHeroLvByExp(exp)
    if exp == nil then return 0 end
    local lvs = _db.heroLv
    for i = 1, _db.maxHeroLv do if exp < lvs[i] then return i - 1 end end
    return _db.maxHeroLv
end
 --[Comment]
--获取武将进阶数据(所需将魂，所需等级，所需道具，所需金币)
function _db.GetHeroEvo(rare, evo)
    rare = _db.heroRare[rare] 
    if rare and evo then
        evo = evo + 1
        return rare.eSoul and rare.eSoul[evo] or 0, rare.eLv and rare.eLv[evo] or 0, rare.eProp and rare.eProp[evo] or 0, rare.eCost and rare.eCost[evo] or 0
    end
    return 0, 0, 0, 0
end
--[Comment]
--获取武将遣散银币
function _db.GetHeroRecCoin(rare)
    rare = _db.heroRare[rare]
    return rare and rare.coin or 0
end
--[Comment]
--获取武将官阶
function _db.GetHeroTtl(sn) return _db.heroTtl[math.clamp(sn, 1, _db.maxHeroTtl)] or _undef end
--[Comment]
--获取武将官阶名称
function _db.GetHeroTtlNm(sn) return sn and sn > 0 and((_db.heroTtl[math.clamp(sn, 1, _db.maxHeroTtl)] or _undef).nm or L("未知")) or "" end
--[Comment]
--获取武将星级数据
function _db.GetHeroStar(sn) return _db.heroStar[math.clamp(sn, 1, _db.maxHeroStar)] or _undef end
--[Comment]
--获取天机级别信息
function _db.GetHeroSlv(lv) return _db.heroSlv[lv] or _undef end
--[Comment]
--获取武将专属天机道具
function _db.GetSexcl(sn) return _db.sexcl[sn] or DB_Sexcl.undef end
--[Comment]
--所有天机专属
function _db.AllSexcl(f) return Find2Arr(_db.sexcl, f) end
--[Comment]
--激活给定数量的天机技能需要的天机等级
function _db.GetSksNeedSlv(qty)
    local lvs = _db.heroSlv
    if lvs and qty then
        local lv
        for i = 1, _db.maxHeroSlv do
            lv = lvs[i]
            if lv and lv.sqty and lv.sqty >= qty then return i end
        end
    end
    return _db.maxHeroSlv
end
----------------------------------------

------------装备相关数据获取------------
--[Comment]
--获取装备数据
function _db.GetEquip(sn) return _db.equip[sn] or DB_Equip.undef end
--[Comment]
--获取所有装备(可带过滤函数)
function _db.AllEquip(f) return Find2Arr(_db.equip, f) end
--[Comment]
--获取装备等级数据,返回(银币,金币,成功率)
function _db.GetEquipLv(lv, rare)
    lv = _db.equipLv[lv and lv + 1]
    if lv then
        lv = lv[rare]
        if lv then return lv[1] or 0, lv[2] or 0, (lv[3] or 0) * 0.01 end
    end
    return 0, 0, 0
end
--[Comment]
--获取给定武将DBSN的专属装备
function _db.GetExclEquip(sn) for _, v in pairs(_db.equip) do if v.excl == sn then return v end end end
--[Comment]
--获取装备进阶数据,返回(道具数量,熟练度,提供的熟练度)
function _db.GetEquipEvo(evo, rare)
    rare = _db.equipRare[rare]
    if rare and evo then
        rare = rare.evo
        if rare then
            return (math.modf((rare[1] or 0) * math.pow(2, evo))), (math.modf((rare[3] or 0) * math.pow(2, evo + 1))), rare[4] or 0
        end
    end
    return 0, 0, 0
end
--[Comment]
--根据装备幻化次数获取当前幻化所需的幻化石数目
function _db.GetEquipEcCost(qty) return qty and _db.param.prEc and _db.param.prEc[qty + 1] or 0 end
--[Comment]
--获取专属装备锻造的消耗
function _db.GetEquipFrogeCost(rare, star)
    rare = _db.equipRare[rare]
    if rare and star then
        rare = rare.excl
        return rare and rare[math.clamp(star+1,1,#rare)] or 0
    end
    return 0
end
--[Comment]
--获取装备套装
function _db.GetEquipSuit(sn) return _db.equipSuit[sn] or DB_EquipSuit.undef end
--[Comment]
--获取给定武将DBSN的专属套装
function _db.GetExclSuit(sn) for _, v in pairs(_db.equipSuit) do if v.excl == sn then return v end end end
----------------------------------------

------------道具宝石相关数据获取------------
--[Comment]
--获取道具
function _db.GetProps(sn) return _db.props[sn] or DB_Props.undef end
--[Comment]
--获取所有道具(可带过滤函数)
function _db.AllProps(f) return Find2Arr(_db.props, f) end
--[Comment]
--获取指定类型的所有道具
function _db.GetKindProps(kind)
    local ret = { }
    for _, v in pairs(_db.props) do if v.kind == kind then inesrt(ret, v) end end
    return ret
end
--[Comment]
--获取宝石数据
function _db.GetGem(sn)
 return _db.gem[sn] or DB_Gem.undef end
--[Comment]
--获取所有宝石数据
function _db.AllGem(f) return Find2Arr(_db.gem, f) end
--[Comment]
--根据宝石类型和等级获取宝石数据(宝石类型, 宝石等级)
function _db.GetKindGem(kind, lv) for _, v in pairs(_db.gem) do if v.kind == kind and v.lv == lv then  return v end end end
--------------------------------------------

------------兵种阵形相关数据获取------------
--[Comment]
--获取兵种数据
function _db.GetArm(sn) return _db.arm[sn] or DB_Arm.undef end
--[Comment]
--获取所有兵种(可带过滤函数)
function _db.AllArm(f) return Find2Arr(_db.arm, f) end
--[Comment]
--获取兵种等级
function _db.GetArmLv(lv) return _db.armLv[math.clamp(lv or 1, 1, _db.maxArmLv)] or _undef end
--[Comment]
--兵种解锁等级(兵种索引)
function _db.ArmUL(idx) local ul = _db.unlock.arm; return ul and idx and ul[math.clamp(idx, 1, #ul)] or 0 end
--[Comment]
--兵种解锁数(武将等级)
function _db.ArmUN(lv)
    local ul = _db.unlock.arm
    if lv then
        for i = 1, #ul do
            if lv < ul[i] then
                return i
            end
        end
    end
    return #ul
end

--[Comment]
--获取阵形
function _db.GetLnp(sn) return _db.lnp[sn] or DB_Lnp.undef end
--[Comment]
--获取所有阵形(可带过滤函数)
function _db.AllLnp(f) return Find2Arr(_db.lnp, f) end
--[Comment]
--获取指定阵形铭刻属性的稀有度
function _db.GetLnpImpRare(k, v)
    k = _db.lnpExt[k]
    if k and v then
        for i = #k, 1, -1 do if v >= k[i] then return i end end
    end
    return 1
end
--[Comment]
--获取阵形铭刻的所有属性Mark
function _db.GetLnpImpMarks() return _db.lnpExtMark end
--[Comment]
--阵形解锁等级(阵形索引)
function _db.LnpUL(idx) local ul = _db.unlock.lnp return ul and idx and ul[math.clamp(idx, 1, #ul)] or 0 end
--[Comment]
--阵形解锁数(武将等级)
function _db.LnpUN(lv)
    local ul = _db.unlock.lnp
    if lv then
        for i = 1, #ul do
            if lv < ul[i] then
                return i
            end
        end
    end
    return #ul
end
--------------------------------------------

------------副将军备相关数据获取------------
--[Comment]
--获取副将数据
function _db.GetDehero(sn) return _db.dehero[sn] or DB_Dehero.undef end
--[Comment]
--根据副将名称获取副将数据
function _db.GetDeheroByNm(nm)
    if nm then
        local ei = string.find(nm, "+", true)
        if ei > 1 then nm = string.sub(nm, 1, ei - 1) end
        for _, v in pairs(_db.dehero) do if nm == v.nm then return v end end
    end
    return DB_Dehero.undef
end
--[Comment]
--获取副将等级数据
function _db.GetDeheroLv(lv) return _db.deheroLv[lv] or _undef end
--[Comment]
--获取星级材料
function _db.GetDeheroStarMat(star) return _db.deheroStar[star] end
--[Comment]
--获取军备数据
function _db.GetDequip(sn) return _db.dequip[sn] or DB_Dequip.undef end
--[Comment]
--根据军备名称获取军备稀有度
function _db.GetDequipRare(nm)
    if nm then
        local ei = string.find(nm, "+", true)
        if ei > 1 then nm = string.sub(nm, 1, ei - 1) end
        for _, v in pairs(_db.dequip) do
            ei = v:GetNmRare(nm)
            if ei > 0 then return ei end
        end
    end
    return 0
end
--[Comment]
--获取军备等级数据
function _db.GetDequipLv(lv) return _db.dequipLv[lv] or _undef end
--[Comment]
--获取军备残片合成需要的数量(返回0表示不可合成)
--<param name="spRare">当前残片稀有度</param>
function _db.GetDequipSpUpCnt(rare)
    rare = rare and rare + 1 or 1
    for _, v in pairs(_db.dequipLv) do if v.rare == rare then return v.costS end end
    return 0
end
--------------------------------------------

------------技能相关数据获取------------
--[Comment]
--获取武将技数据
function _db.GetSkc(sn) return _db.skc[sn] or DB_SKC.undef end
--[Comment]
--获取军师技数据
function _db.GetSkt(sn) return _db.skt[sn] or DB_SKT.undef end
--[Comment]
--获取觉醒技数据
function _db.GetSke(sn) return _db.ske[sn] or DB_SKE.undef end
--[Comment]
--获取锦囊技数据
function _db.GetSkp(sn) return _db.skp[sn] or DB_SKP.undef end
--[Comment]
--获取副将技数据
function _db.GetSkd(sn) return _db.skd[sn] or DB_SKD.undef end
--[Comment]
--获取天机技数据
function _db.GetSks(sn) return _db.sks[sn] or DB_SKS.undef end

--[Comment]
--武将技解锁等级(武将技索引)
function _db.SkcUL(idx) local ul = _db.unlock.skc; return ul and idx and ul[math.clamp(idx, 1, #ul)] or 0 end
--[Comment]
--获取给定武将等级解锁的武将技索引
function _db.GetULSkcIdx(lv) local ul = _db.unlock.skc; for i = 1, #ul do if lv == ul[i] then return i end end end
--[Comment]
--军师技解锁等级(军师技索引)
function _db.SktUL(idx) return _db.unlock.skt or 1 end
--[Comment]
--获取给定武将等级解锁的军师技索引
function _db.GetULSktIdx(lv) return lv == _db.unlock.skt and 1 or nil end

--[Comment]
--获取五行数据
function _db.GetFe(sn) return _db.fe[sn] or _undef end
--[Comment]
--获取五行等级经验
function _db.GetFeExp(lv) return _db.feLv[math.clamp(lv or 1, 1, _db.maxFeLv)] or 0 end
--[Comment]
--最大经验
function _db.GetFeMaxExp() return _db.feLv[_db.maxFeLv] or 0 end
--[Comment]
--获取五行等级经验
function _db.GetFeLv(exp)
    local lvs = _db.feLv
    for i = _db.maxFeLv, 1,-1 do
        if lvs[i] and exp >= lvs[i] then return i end
    end
    return 0
end

--[Comment]
--获取战场BUFF
function _db.GetBattleBuff(sn) return _db.buff[sn] or DB_Buff.undef end
----------------------------------------

------------PVE相关数据获取------------
--[Comment]
--获取游戏主关卡数据
function _db.GetGmLv(sn) return _db.gmLv[sn] or _undef end
--[Comment]
--获取游戏主关卡城池数据
function _db.GetGmCity(sn) return _db.gmCity[sn] or DB_City.undef end

--[Comment]
--获取战役大关卡数据
function _db.GetWar(sn) return _db.gmWar[sn] or _undef end
--[Comment]
--获取战役小关卡数据
function _db.GetWarSub(sn) return _db.gmWarSub[sn] or _undef end
--[Comment]
--根据子关卡编号获取战役数据
function _db.GetWarFromSub(sn) return _db.gmWar[(_db.gmWarSub[sn] or _undef).warSN] or _undef end
--[Comment]
--获取给定战役大关卡的所有小关卡数据
function _db.GetWarSubs(sn)
    local ret = { }
    for _, v in pairs(_db.gmWarSub) do if v.main == sn then inesrt(ret, v) end end
    return ret
end

--[Comment]
--获取乱世争雄数据
function _db.GetClanWar(sn) return _db.gmClan[sn] or _undef end
--[Comment]
--每个类别的副本取第一个
function _db.GetClanWarByKind()
    local ret = { }
    local flag
    for i = 1, 100 do
        flag = true
        for _, v in pairs(_db.gmClan) do
            if v.kind == i then
                flag = false
                inesrt(ret, v)
                break
            end
        end
        if flag then break end
    end
    return ret
end
--[Comment]
--获取指定类别的所有乱世争雄数据
function _db.GetClanWarFromKind(kind)
    local ret = { }
    for _, v in pairs(_db.gmClan) do if v.kind == kind then inesrt(ret, v) end end
    return ret
end
--[Comment]
--获取指定关卡的幻境数据
function _db.GetFantsyLv(lv) return _db.fantsy[lv] or _undef end
--[Comment]
--按标签获取所有幻境关卡数据
function _db.GetFantsyByTag()
    local ret = { }
    local lst
    for k, v in pairs(_db.fantsy) do
        k = v.tag
        if k then
            lst = ret[k]
            if lst == nil then
                lst = { }
                ret[k] = lst
            end
            inesrt(lst, v)
        end
    end
    return ret
end
--[Comment]
--完美描述
function _db.GetPerfectDesc(id) return _db.pdesc[id] or "" end
---------------------------------------

------------PVP相关数据获取------------
--[Comment]
--联盟悬赏任务
function _db.GetAllyQuest(sn) return _db.allyQuest[sn] or _undef end
--[Comment]
--获取给定分组的任务数目
function _db.GetAllyQuestCnt(g)
        local cnt = 0
        for _k, v in pairs(_db.allyQuest) do if v.grp == g then cnt = cnt + 1 end end
        return cnt
end
--[Comment]
--获取给定等级联盟升级所需的联盟币
function _db.GetAllyUpCost(lv) return (_db.allyLv[math.clamp(lv or 1, 1, _db.maxAllyLv)] or _undef).cost or 0 end
--[Comment]
--获取给定联盟等级的最大成员数
function _db.GetAllyMaxMember(lv) return (_db.allyLv[math.clamp(lv or 1, 1, _db.maxAllyLv)] or _undef).maxm or 0 end
--[Comment]
--获取联盟科技的解锁联盟等级[1=HP 2=TP 3=STR 4=CAP 5=WIS]
function _db.GetAllyTechUnLockLv(tech)
    tech = _allyTech[tech]
    if tech then
        local lv
        local lvs = _db.allyLv
        for i = 1, _db.maxAllyLv do
            lv = lvs[i]
            if lv and lv[tech] then return i end
        end
    end
    return 0
end
--[Comment]
--获取联盟科技数据
local function GetAllyTech(tech, lv, i)
    tech = _allyTech[tech]
    if tech then
        lv = _db.allyLv[math.clamp(lv, 0, _db.maxAllyLv)]
        if lv then
            tech = lv[tech]
            return tech and tech[i] or 0
        end
    end
    return 0
end
--[Comment]
--获取给定联盟等级和科技的等级上限[1=STR 2=CAP 3=WIS]
function _db.GetAllyTechLvLimit(tech, lv) return GetAllyTech(tech, user.ally.lv, 1) end
--[Comment]
--获取给定科技的最大等级[3=STR 4=CAP 5=WIS]
function _db.GetAllyTechMaxLv(tech) return GetAllyTech(tech, _db.maxAllyLv, 1) end
--[Comment]
--获取联盟科技捐献金币消耗[1=STR 2=CAP 3=WIS]
function _db.GetAllyTechUpCostGold(tech, lv) return GetAllyTech(tech, lv, 2) end
--[Comment]
--获取联盟科技捐献钻石消耗[1=STR 2=CAP 3=WIS]
function _db.GetAllyTechUpCostDiamond(tech, lv) return GetAllyTech(tech, lv, 3) end
--[Comment]
--获取联盟科技的加成值[1=STR 2=CAP 3=WIS]
function _db.GetAllyTechGain(tech, lv) return GetAllyTech(tech, lv, 4) end
--[Comment]
--获取联盟科技的升级经验值[1=STR 2=CAP 3=WIS]
function _db.GetAllyTechExp(tech, lv) return GetAllyTech(tech, lv, 5) end

--[Comment]
--获取国战国家数据
function _db.GetNat(sn) return _db.nat[sn] or _undef end
--[Comment]
--获取国战城池数据
function _db.GetNatCity(sn) return _db.natCity[sn] or _undef end
--[Comment]
--获取国战州郡数据
function _db.GetNatState(sn) return _db.natState[sn] or _undef end
--[Comment]
--获取国战矿脉数据
function _db.GetNatMine(sn) return _db.natMine[sn] or _undef end
--[Comment]
--获取国战国家矿脉数据
function _db.GetNatMines(sn)
    local ret = { }
    for _, v in pairs(_db.natMine) do if v.nsn == sn then inesrt(ret, v) end end
    return ret
end
--[Comment]
--获取国战国家等级数据
function _db.GetNatLv(lv) return _db.natLv[math.clamp(lv or 1,1, _db.maxNatLv)] or _undef end
--[Comment]
--根据用户爵位等级获取活跃度宝箱数据
function _db.GetNact(ttl)
    ttl = ttl or 1

    local ret
    for _, v in pairs(_db.nact) do if v.ttl and v.ttl <= ttl and(ret == nil or ret.ttl < v.ttl) then ret = v end end
    if ret == nil then
        for _, v in pairs(_db.nact) do if v.ttl and(ret == nil or ret.ttl < v.ttl) then ret = v end end
    end
    return ret or _undef
end
--[Comment]
--根据当前爵位获取升到下阶活跃宝箱的爵位(若已是最高阶，返回0)
function _db.GetNextNactTtl(ttl)
    ttl = ttl or 1
    local ret = 0
    for _, v in pairs(_db.nact) do if v.ttl and v.ttl > ttl and(ret == 0 or ret > v.ttl) then ret = v.ttl end end
    return ret
end
--[Comment]
--获取国战玩法数据
function _db.GetNatTips() return LoadFile(LuaRes.Country_Tips) end
---------------------------------------

------------玩法数据------------
--[Comment]
--红包数据获取
function _db.GetRed(sn) return _db.actRed[sn] or _undef end
--[Comment]
--活动数据获取
function _db.GetAct(sn) return _db.act[sn] or DB_Act.undef end
--[Comment]
--获取等级礼包
function _db.GetLvGift(lv) return _db.giftHLv[lv] or _undef  end
--[Comment]
--获取占卜数据
function _db.GetDivine(sn) return _db.divine[sn] or _undef end

--[Comment]
--日常功能
function _db.AllDaily(f) return Find2Arr(_db.daily, f) end
--[Comment]
--日常功能
function _db.GetDaily(sn) return _db.daily[sn] or _undef end
--[Comment]
--日常奖励
function _db.AllDailyRw() _db.dailyRw = _db.dailyRw or LoadFile("daily_r"); return _db.dailyRw end
--[Comment]
--宴会数据
function _db.AllFeast(f) return Find2Arr(_db.feast, f) end
--[Comment]
--铜雀台数据
function _db.GetBeauty(sn) return _db.beauty[sn] or DB_Beauty.undef end
--[Comment]
--铜雀台数据
function _db.AllBeauty(f) return Find2Arr(_db.beauty, f) end
--[Comment]
--国战日常奖励
function _db.NatDailyRw() _db.natdailyRw = _db.natdailyRw or LoadFile("nat_daily_box"); return _db.natdailyRw end

--[Comment]
--获取TCG技能
function _db.GetTcgSkill(sn)
    local tb = _db.tcgSkill
    if tb == nil then
        tb = LoadFile("tcg_skill")
        _db.tcgSkill = tb
    end
    return tb[sn] or _undef
end
--[Comment]
--获取TCG阵营
function _db.GetTcgClan(clan)
    local tb = _db.tcgClan
    if tb == nil then
        tb = LoadFile("tcg_clan")
        _db.tcgClan = tb
    end
    return tb[sn] or _undef
end
--------------------------------

------------情景对话------------
--[Comment]
--情景对话数据（tp = 对话类型[详见 Dialogue.dlg_type ]）
--可选参数 f （ f = 筛选条件函数）
function _db.AllDlg(tp, f) return Find2Arr(Dialogue[tp], f)  end

--------------------------------

--------------------其它游戏数据--------------------
--[Comment]
--获取基础属性名称
function _db.GetAttName(baid) return L(_db.baseAttNm[baid] or "未知") end
--[Comment]
--获取基础属性简称
function _db.GetAttSName(baid) return L(_db.baseAttSNm[baid] or "无") end
--[Comment]
--获取性别名称
function _db.GetSexName(sex) return L(_db.sexNm[sex] or "未知性别") end
--[Comment]
--获取周名称
function _db.GetWeekName(day) return L(_db.weekNm[day] or "未知") end
--[Comment]
--获取国家名称
function _db.GetNatName(day) return L(_db.natNm[day + 1] or "无") end
--[Comment]
--获取阵营名称
function _db.GetClanName(day) return L(_db.clanNm[day] or "群雄") end
--[Comment]
--获取兵种显示偏移
function _db.GetArmOffset(sn) return _db.armOffset[sn] or Vector2.zero end
--[Comment]
--当前小时数
function _db.NowHour() return (math.modf(os.time() / 3600)) end