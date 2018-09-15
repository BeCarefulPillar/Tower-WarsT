local ATT_BID = ATT_BID
local ATT_NM = ATT_NM
local _len = table.maxn
local type = type

local _hero =
{
    --[Comment]
    --CSN
    sn = nil,
    --[Comment]
    --DBSN
    dbsn = 0,
    --[Comment]
    --所在地(1-999表示推图城池，>1000表示PVP城池)
    loc = 0,
    --[Comment]
    --等级
    lv = 0,
    --[Comment]
    --经验
    exp = 0,
    --[Comment]
    --进阶等级
    evo = 0,
    --[Comment]
    --星级
    star = 0,
    --[Comment]
    --将领军阶
    ttl = 0,
    --[Comment]
    --将领功勋
    merit = 0,
    --[Comment]
    --疲劳值
    fatig = 0,
    --[Comment]
    --天机等级
    slv = 0,

    --[Comment]
    --基本武力
    baseStr = 0,
    --[Comment]
    --基本智力
    baseWis = 0,
    --[Comment]
    --基本统帅
    baseCap = 0,
    --[Comment]
    --基本最大生命
    baseHP = 0,

    --[Comment]
    --当前生命
    hp = 0,
    --[Comment]
    --当前技力
    sp = 0,
    --[Comment]
    --当前兵力
    tp = 0,

    --[Comment]
    --当前忠诚
    loyalty = 0,

    --[Comment]
    --当前兵种
    arm = 0,
    --[Comment]
    --可用兵种列表
    armLst = nil,
    --[Comment]
    --可用兵种等级列表
    armLv = nil,

    --[Comment]
    --当前阵形
    lnp = 0,
    --[Comment]
    --可用阵形列表
    lnpLst = nil,
    --[Comment]
    --可用阵形的铭刻列表
    lnpExt = nil,
    --[Comment]
    --可用阵形的铭刻数列表
    lnpExtQty = nil,

    --[Comment]
    --将领技解锁数
    skc = 0,
    --[Comment]
    --将领技五行数据([{sksn:技能编号,cur:当前五行,exp:五行经验,time:上次获取时间}])
    fe = nil,
    --[Comment]
    --军师技解锁数
    skt = 0,

    --[Comment]
    --当前锦囊技
    skp = 0,
    --[Comment]
    --锦囊技列表
    skpLst = nil,
    --[Comment]
    --锦囊技等级列表
    skpLv = nil,

    --[Comment]
    --天机技能列表
    sksLst = nil,

    --[Comment]
    --修炼获得的属性[1=武，2=智，3=统，4=血](五星以下的将领为NULL)
    xlAtt = nil,

    --[Comment]
    --当前装备
    equip = nil,
    --[Comment]
    --套装
    suit = nil,
    --[Comment]
    --套装属性
    suitAtt = nil,

    --[Comment]
    --副将
    dehero = nil,

    --[Comment]
    --DB数据
    db = nil,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --职业类型
    kind = 0,
    --[Comment]
    --DB稀有度
    rare = 0,
    --[Comment]
    --官位名称
    tnm = nil,

    --------------------以下为运算值--------------------
    --[Comment]
    --基本最大技力
    baseSP = 0,
    --[Comment]
    --基本最大兵力
    baseTP = 0,
}

--[Comment]
--校对基本属性值
local function CheckBaseAtt(h)
    local db, lvc, evo = h.db, h.lv and h.lv - 1 or 0, h.evo or 0
    h.baseSP = db.sp +(lvc > 0 and math.ceil(lvc * db.lsp * 0.01) or 0) +(evo > 0 and db.esp * evo or 0)
    h.baseTP = db.tp +(lvc > 0 and math.ceil(lvc * db.ltp * 0.01) or 0) +(evo > 0 and db.etp * evo or 0)
end
--[Comment]
--校对兵种等级数据（修正兵种数据）
local function CheckArmData(h)
    if h.armLst == nil then h.armLst = { h.db.arm } end
    if h.arm == nil or h.arm == 0 then h.arm = h.db.arm end
    if h.armLv == nil then h.armLv = {} end
    
    local s = #h.armLst
    local tl = h.armLv
    for i = 1, s do if tl[i] == nil or tl[i] < 1 then tl[i] = 1 end end
--    local ls = _len(tl)
--    if s >= ls then return end
--    for i = s + 1, ls do tl[i] = nil end
end
--[Comment]
--校对阵形铭刻数据（修正阵形数据）
local function CheckLnpData(h)
    if h.lnpLst == nil then h.lnpLst = { h.db.lnp } end
    if h.lnp == nil or h.lnp == 0 then h.lnp = h.db.lnp end
    if h.lnpExt == nil then h.lnpExt = {} end
    if h.lnpExtQty == nil then h.lnpExtQty = {} end
end
--[Comment]
--校对装备套装
local function CheckSuit(h)
    if h == nil then return end
    local suit, suitAtt = nil, nil
    local es = h.equip
    if es then
        local e
        for i = _len(es), 1, -1 do
            e = es[i]
            if e then
                e = e.db
                if e then
                    e = e.suit
                    if e and e > 0 then
                        if suit == nil then suit = {} end
                        suit[e] = (suit[e] or 0) + 1
                    end
                end
            end
        end
    end

    if suit then
        local att, a
        for k, v in pairs(suit) do
            if v > 1 then
                es = DB.GetEquipSuit(k)
                att = es.att
                v = math.min(v - 1, att and #att or 0)
                if v > 0 and es:CheckExcl(h.dbsn) then
                    for i = 1, v do
                        a = att[i]
                        if "table" == type(a) then
                            if suitAtt == nil then suitAtt = { } end
                            ExtAtt.ConvKV(suitAtt, a[1], a[2])
                        end
                    end
                end
            end
        end
    end
    h.suit, h.suitAtt = suit, suitAtt
end
--[Comment]
--转换技能五行{sksn,cur,exp,time}
local function ConvFe(d, fe)
    if d then
        local len = #d
        if len < 2 then return nil end
        if len % 2 == 1 then len = len - 1 end
        fe = fe or { }
        local sn, cur, tf
        for i = 1, len, 2 do
            sn, cur = d[i], d[i + 1]
            if sn then
                tf = fe[sn]
                if tf then tf.cur = cur else fe[sn] = { sksn = sn, cur = cur } end
            end
        end
        return fe
    end
    return nil
end

--[Comment]
--取得装备属性
local function GetEquipAtt(h, aid) 
    if h == nil or aid == nil then return 0 end  
    local es = h.equip
    if es == nil then return 0 end
    local l = _len(es)
    if l < 1 then return  0 end
    local ret = 0
    local e
    local suit = h.suitAtt
    if ATT_BID.STR == aid then 
        for i = 1, l do e = es[i]; if e then ret = ret + e.str end end 
        if suit then  ret = ret + ExtAtt.Get(suit, ATT_NM.Str) end
    elseif ATT_BID.WIS == aid then
        for i = 1, l do e = es[i]; if e then ret = ret + e.wis end end
        if suit then ret = ret + ExtAtt.Get(suit, ATT_NM.Wis) end
    elseif ATT_BID.CAP == aid then
        for i = 1, l do e = es[i]; if e then ret = ret + e.cap end end
        if suit then ret = ret + ExtAtt.Get(suit, ATT_NM.Cap) end
    elseif ATT_BID.HP == aid then
        for i = 1, l do e = es[i]; if e then ret = ret + e.hp end end
        if suit then ret = ret + ExtAtt.Get(suit, ATT_NM.HP) end
    elseif ATT_BID.SP == aid then
        for i = 1, l do e = es[i]; if e then ret = ret + e.sp end end
        if suit then ret = ret + ExtAtt.Get(suit, ATT_NM.SP) end
    elseif ATT_BID.TP == aid then
        for i = 1, l do e = es[i]; if e then ret = ret + e.tp end end
        if suit then ret = ret + ExtAtt.Get(suit, ATT_NM.TP) end
    end 
    return ret
end
--[Comment]
--获取副将属性加成[0=武力 1=智力 2=统帅 3=HP 4=SP 5=TP]
local function GetDeheroAtt(h, aid)
    return 0
--    h = h.dehero
--    if h == nil then return 0 end
--    return aid == ATT_BID.STR and h.HeroStr or aid == ATT_BID.WIS and h.HeroWis or aid == ATT_BID.CAP and h.HeroCap or 
--        aid == ATT_BID.HP and h.HeroHP or aid == ATT_BID.SP and h.HeroSP or aid == ATT_BID.TP and h.HeroTP or 0
end
--[Comment]
--天机加成属性
local function GetSecretAtt(h, aid)
    return 0
--    if h.rare < MAIN_HERO_RARE then return 0 end
--    local ret = user.GSatt(aid)
--    local lst = h.sksLst
--    local sks = nil
--    if lst and #lst > 0 then
--        for i = 1, #lst do
--            if DB_SKS.GetLvFromLVSN(lst[i]) > 0 then
--                sks = DB.GetSks(lst[i])
--                if sks:IsSingleAtt() then
--                    ret = ret + (sks:GetAtt(aid) * DB_SKS.GetLvFromLVSN(lst[i]))
--                end
--            end
--        end
--    end
--    return ret
end
--[Comment]
--获取修炼属性[1=武 2=智 3=统 4=血]
--local function GetCultiveAtt(h, aid) return h.xlAtt and h.xlAtt[aid] or 0 end
local function GetCultiveAtt(h, aid) return 0 end
--[Comment]
--获取修炼属性[1=武 2=智 3=统 4=血]
_hero.GetCultiveAtt = GetCultiveAtt

--[Comment]
--卸下装备
local function UnEquip(h, e)
	local es = h and h.equip or nil
	if es == nil then return end
	if e then
		local tp = type(e)
		if "number" == tp then
			tp = es[e]
			if tp then
				es[e] = nil
                h.changed = true
				tp:Belong()
			end
		elseif "string" == tp then
			for i = _len(es), 1, -1 do
				tp = es[i]
				if tp and tp.sn == e then
					es[i] = nil
                    h.changed = true
					tp:Belong()
				end
			end
		elseif "table" == tp then
			for i = _len(es), 1, -1 do
				if es[i] == e then
					es[i] = nil
                    h.changed = true
                    e:Belong()
				end
			end
		end
	else
		for i = _len(es), 1, -1 do
			e = es[i]
			if e then
				es[i] = nil
                h.changed = true
				e:Belong()
			end
		end
	end
    if h.changed then CheckSuit(h) end
end
--[Comment]
--卸下装备
_hero.UnEquip = UnEquip
--[Comment]
--穿戴装备
local function Equip(h, e)
    if h == nil or e == nil then return end
	local es = h.equip
	if es == nil then es = {};h.equip = es end
	if "table" ~= type(e) then e = user.GetEquip(e) end

    assert(e and getmetatable(e) == PY_Equip, "hero equip target ["..tostring(de).."] invaild")

	for i = _len(es), 1, -1 do
		if es[i] == e then
            if h == e.belong then return end
            UnEquip(e.belong, e)
            e:Belong(h)
			return
		end
	end
    local pos = e.kind
	if pos and pos >= 1 and pos <= EQP_KIND.MAX then
        UnEquip(e.belong, e)
        local te = es[pos]
        es[pos] = e
        if te then te:Belong() end
        e:Belong(h)
        h.changed = true
        CheckSuit(h)
    end
end
--[Comment]
--穿戴装备
_hero.Equip = Equip
--[Comment]
--获取指定类型的装备
function _hero.GetEquip(h, kind) return h and h.equip and h.equip[kind] or nil end
--[Comment]
--获取专属装备
function _hero.GetExclEquip(h)
    local es = h and h.equip
    if es then
        local e
        for i = _len(es), 1, -1 do
            e = es[i]
            if e and e.db and e.db.excl == h.dbsn then return e end
        end  
    end
end
--[Comment]
--获取指定套装编号的数量
function _hero.GetSuitQty(h, suit) return h.suit and h.suit[suit] or 0 end

--[Comment]
--设置基本武力
function _hero.SetBaseStr(h, v) if v and v > 0 and v ~= h.baseStr then h.baseStr = v; h.changed = true end end
--[Comment]
--设置基本智力
function _hero.SetBaseWis(h, v) if v and v > 0 and v ~= h.baseWis then h.baseWis = v; h.changed = true end end
--[Comment]
--设置基本统帅
function _hero.SetBaseCap(h, v) if v and v > 0 and v ~= h.baseCap then h.baseCap = v; h.changed = true end end
--[Comment]
--设置基本生命
function _hero.SetBaseHP(h, v) if v and v > 0 and v ~= h.baseHP then h.baseHP = v; h.changed = true end end
--[Comment]
--设置当前生命
function _hero.SetHP(h, v) if v == nil then return end; v = math.clamp(v, 1, h.MaxHP); if v ~= h.baseHP then h.baseHP = v; h.changed = true end end
--[Comment]
--设置当前技力
function _hero.SetSP(h, v) if v == nil then return end; v = math.clamp(v, 0, h.MaxSP); if v ~= h.baseSP then h.baseSP = v; h.changed = true end end
--[Comment]
--设置当前兵力
function _hero.SetTP(h, v) if v == nil then return end; v = math.clamp(v, 0, h.MaxTP); if v ~= h.baseTP then h.baseTP = v; h.changed = true end end
--[Comment]
--设置忠诚
function _hero.SetLoyalty(h, v) if v == nil or v == h.loyalty then return end; h.loyalty = v; h.changed = true end
--[Comment]
--设置位置
function _hero.SetLoc(h, v) if v == nil or v == h.loc then return end; h.loc = v; h.changed = true end
--[Comment]
--设置等级
local function SetLv(h, lv, exp)
    lv = math.clamp(lv or h.lv, 1, user.HeroLvLmt)
    if lv > h.lv then
        local d = lv - h.lv
        h.lv = lv
        h.baseStr = h.baseStr + d * h.db.lstr
        h.baseWis = h.baseWis + d * h.db.lwis
        h.baseCap = h.baseCap + d * h.db.lcap
        h.baseHP = h.baseHP + d * h.db.lhp
        CheckBaseAtt(h)
    end
    h.exp = math.max(exp or h.exp, DB.GetHeroLvExp(h.lv))
    h.changed = true
end
--[Comment]
--设置等级
_hero.SetLv = SetLv
--[Comment]
--设置经验
function _hero.SetExp(h, exp)
    if exp and exp > h.exp then
        h.exp = exp
        SetLv( h, math.max(h.lv, DB.GetHeroLvByExp(exp)))
    end
end
--[Comment]
--设置功勋
function _hero.SetMerit(h, v) if v == nil then return end; h.merit = v end
--[Comment]
--设置疲劳值
function _hero.SetFatig(h, v) if v == nil then return end; h.fatig = v end
--[Comment]
--设置官阶
function _hero.SetTtl(h, v)
    if v == nil then return end
    h.ttl = math.clamp(v, 1, DB.maxHeroTtl)
    h.merit = math.max(h.merit, DB.GetHeroTtl(h.ttl).merit or 0)
    h.tnm = DB.GetHeroTtlNm(h.ttl)
end
--[Comment]
--设置等阶
function _hero.SetEvo(h, v)
    if v == nil then return end
    v = math.clamp(v, 0, DB.maxHeroEvo)
    if v > h.evo then
        local d = v - h.evo
        h.evo = v
        h.baseStr = h.baseStr + d * h.db.estr
        h.baseWis = h.baseWis + d * h.db.ewis
        h.baseCap = h.baseCap + d * h.db.ecap
        h.baseHP = h.baseHP + d * h.db.ehp
        CheckBaseAtt(h)
        h.changed = true
    end
end
--[Comment]
--设置将星
function _hero.SetStar(h, v)
    if v == nil then return end
    v = math.clamp(v, 0, DB.maxHeroStar)
    if v > h.star then
        local d = v - h.star
        d = d - (math.modf((d + h.star % 10) / 10));
        h.star = v
        if d > 0 then
            h.baseStr = h.baseStr + d * h.db.sstr
            h.baseWis = h.baseWis + d * h.db.swis
            h.baseCap = h.baseCap + d * h.db.scap
            h.baseHP = h.baseHP + d * h.db.shp
        end
        h.changed = true
    end
end
--[Comment]
--同步天机
function _hero.SetSecret(h, slv, sks)
    if slv or sks then
        h.slv = slv or h.slv
        h.sksLst = sks or h.sksLst
        user.gsatt = nil
        h.changed = true
    end
end
--[Comment]
--设置副将
function _hero.SetDehero(h, dh)
    if h.dehero == dh then return end
    local tmp = h.dehero
    h.dehero = dh
    if dh then dh.belong = h end
    if tmp then tmp.belong = nil end
    h.changed = true
end
--[Comment]
--增加修炼属性[1=武 2=智 3=统 4=血],给入增量
function _hero.AddCultiveAtt(h, aid, add)
    if h.rare < MAIN_HERO_RARE or add == nil or add == 0 then return end
    local att = h.xlAtt
    if att == nil then
        att = {}
        h.xlAtt = att
    end
    att[aid] = (att[aid] or 0) + add
    h.changed = true
end

--[Comment]
--初始化[d=S_Hero]
local function Init(h, d)
    if h == nil then return end
    if d and h.sn == d.sn and d.dbsn and d.dbsn > 0 then
        table.copy(d, h)
        -- 转换五行数据
        h.fe = ConvFe(d.fe)
    end

    -- DB数据接入
    d = DB.GetHero(h.dbsn)
    if d == DB_Hero.undef then print("undef hero [", h.sn, "]") end
    h.__ext = d
    h.db = d
    h.nm = d.nm
    h.kind = d.kind
    h.rare = d.rare
    h.tnm = DB.GetHeroTtlNm(h.ttl)
   
    CheckBaseAtt(h)
    CheckArmData(h)
    CheckLnpData(h)
end
--[Comment]
--初始化[d=S_Hero]
_hero.Init = Init
--[Comment]
--构造[d=S_Hero]
function _hero.New(d)
    assert(d and "string" == type(d.sn) and d.dbsn and d.dbsn > 0,
        "new PY_Hero arg ["..(d and tostring(d.sn)..","..tostring(d.dbsn) or "nil").."] err")
    --转换五行数据
    d.fe = ConvFe(d.fe) 
    Init(d)
    return d
end

-------------------------技能相关-------------------------
--[Comment]
--获取将领技需要的等级(nil1表示没有该技能)
function _hero.SkcNeedLv(h, sksn)
    local lst = h.db.skc
    if lst and sksn then
        for i = 1, #lst do
            if sksn == lst[i] then return DB.SkcUL(i) end
        end
    end
end
--[Comment]
--获取军师技需要的等级(nil表示没有该技能)
function _hero.SktNeedLv(h, sksn) return h.db.skt == sksn and DB.SktUL(1) or nil end
--[Comment]
--指定将领技是否可用
function _hero.SkcAvailable(h, sksn)
    local lst = h.db.skc
    if lst and sksn then
        for i = 1, #lst do
            if sksn == lst[i] then return h.lv >= DB.SkcUL(i) end
        end
    end
    return false
end
--[Comment]
--指定军师技是否可用
function _hero.SktAvailable(h, sksn) return h.db.skt == sksn and h.lv >= DB.SktUL(1) end
--[Comment]
--学习解锁技能
--function _hero.LearnSkill(h, skcQty, sktQty)
--    h.skc = skcQty or h.skc
--    h.skt = sktQty or h.skt
--    h.changed = true
--end
--[Comment]
--获取给定等级解锁的将领技
function _hero.LvULSkc(h, lv) local lst = h.db.skc; return lst and DB.GetSkc(lst[DB.GetULSkcIdx(lv)]) or DB_SKC.undef end
--[Comment]
--获取给定等级解锁的军师技
function _hero.LvULSkt(h, lv) local skt = h.db.skt; return skt and DB.GetULSktIdx(lv) and DB.GetSkt(skt) or DB_SKC.undef end
--[Comment]
--获取指定锦囊技等级
local function GetSkpLv(h, sksn)
    local lst = h.skpLst
    if lst and #lst > 0 then
        local lvs = h.skpLv
        if lvs and #lvs >= #lst then
            for i = 1, #lst do
                if lst[i] == sksn then return lvs[i] end
            end
        end
    end
    return 0
end
--[Comment]
--获取指定锦囊技等级
_hero.GetSkpLv = GetSkpLv
--[Comment]
--同步锦囊技相关数据，如将领当前装备的锦囊技、将领精力值
function _hero.SyncSkp(h, dat)
    if h.sn == tostring(dat.csn) then
        print("同步锦囊技相关数据  ",kjson.print(dat))
        h.skp = dat.skp or h.skp
        h.skpLst = dat.skpLst or h.skpLst
        h.skpLv = dat.skpLv or h.skpLv
        h.changed = true
    end
end
--[Comment]
--指定锦囊技是否达到学习条件
function _hero.CanLearnSkp(h, skp) return skp and skp.sn ~= 0 and (skp.rsk <= 0 or GetSkpLv(h, skp.rsk) >= skp.rlv) end
----------------------------------------------------------

-------------------------阵形相关-------------------------
--[Comment]
--指定阵形是否可用
function _hero.LnpAvailable(h, sn) local lst = h.lnpLst; if lst then for i = 1, #lst do if sn == lst[i] then return true end end end end
--[Comment]
--获取阵形的索引(1-4,没有为nil)
function _hero.GetLnpIdx(h, sn) local lst = h.lnpLst; if lst then for i = 1, #lst do if sn == lst[i] then return i end end end end
--[Commen]
--学习/使用/升级阵形
function _hero.LnpOpt(h, dat)
    if dat == nil or h.sn ~= tostring(dat. csn) then return end
    local sn = dat.lnp
    if sn and sn > 0 then
        if "buy" == dat.opt then
            local lst = h.lnpLst
            if lst then
                 for i = 1, #lst do if sn == lst[i] then return end end
                 table.insert(lst, sn)
            else
                h.lnpLst = { sn }
            end
            CheckLnpData(h)
        elseif "use" == dat.opt then
            h.lnp = sn
        end
    elseif "set" == dat.opt then
        h.lnp = h.lnpLst and h.lnpLst[1] or h.db.lnp
        if h.lnpLst then for i = 2, #h.lnpLst do h.lnpLst[i] = nil end end
        if h.lnpExt then for i = 2, #h.lnpExt do h.lnpExt[i] = nil end end
        if h.lnpExtQty then for i = 2, #h.lnpExtQty do h.lnpExtQty[i] = nil end end
        CheckLnpData(h)
    end
    h.changed = true
end
--[Commen]
--获取指定阵形的铭刻数
function _hero.GetLnpImpQty(h, sn)
    local lst = h.lnpLst
    if lst then
        for i = 1, _len(lst) do
            if sn == lst[i] then
                lst = h.lnpExtQty
                if lst == nil then CheckLnpData(h); lst = h.lnpExt end
                return lst[i] or 0
            end
        end
    end
    return 0
end
--[Commen]
--获取指定阵形的完整铭刻属性
function _hero.GetLnpImp(h, sn, f)
    local lst = h.lnpLst
    if lst then
        for i = 1, _len(lst) do
            if sn == lst[i] then
                lst = h.lnpExt
                if lst == nil then CheckLnpData(h); lst = h.lnpExt end
                if lst[i] then
                    if f then f(lst[i]) end
                else
                    SVR.ImpLnp(h.sn, i, "inf", function(t) if f then f(lst[i]) end end)
                end
                return
            end
        end
    end
    if f then f() end
end
--[Commen]
--同步阵形铭刻数据
function _hero.SyncLnpImp(h, dat)
    local idx = dat and dat.lnpIdx
    if idx then
        if h.lnpExt == nil or h.lnpExtQty == nil then CheckLnpData(h) end
        local imp = ExtAtt(dat.imp)
        h.lnpExt[idx] = imp
        h.lnpExtQty[idx] = #imp
    end
end
----------------------------------------------------------

-------------------------兵种相关-------------------------
--[Commen]
--指定兵种是否可用
function _hero.ArmAvailable(h, sn) local lst = h.armLst; if lst then for i = 1, #lst do if sn == lst[i] then return true end end end end
--[Commen]
-- 获取兵种等级
function _hero.GetArmLv(h, sn)
    local lst = h.armLst
    if lst then
        for i = 1, _len(lst) do
            if sn == lst[i] then
                lst = h.armLv
                if lst == nil or lst[i] == nil or lst[i] <= 0 then CheckArmData(h); lst = lst or h.armLv end
                return lst[i] or 1
            end
        end
    end
    return 0
end
--[Commen]
-- 学习/使用/升级兵种
function _hero.ArmOpt(h, dat)
    if dat == nil or h.sn ~= tostring(dat.csn) then return end
    local sn = dat.arm
    if sn and sn > 0 then
        if "buy" == dat.opt then
            local lst = h.armLst
            if lst then
                for i = 1, #lst do if sn == lst[i] then return end end
                table.insert(lst, sn)
            else
                h.armLst = { sn }
            end
            CheckArmData(h)
        elseif "use" == dat.opt then
            h.arm = sn
        elseif "upg" == dat.opt then
            local lst = h.armLst
            if lst then
                for i = 1, #lst do
                    if sn == lst[i] then
                        lst = h.armLv
                        if lst == nil or lst[i] == nil or lst[i] <= 0 then CheckArmData(h); lst = lst or h.armLv end
                        lst[i] = math.clamp((lst[i] or 1) + 1, 1, DB.maxArmLv)
                        break
                    end
                end
            end
        end
    elseif "set" == dat.opt then
        h.arm = h.db.arm
        if h.armLst then for i = 2, #h.armLst do h.armLst[i] = nil end end
        if h.armLv then for i = 1, #h.armLv do h.armLv[i] = nil end end
        CheckArmData(h)
    end
    h.changed = true
end
----------------------------------------------------------

-------------------------五行相关-------------------------
--[Commen]
--校对五行数据
function _hero.SyncFe(h, dat)
    if dat == nil or h.sn ~= tostring(dat.csn) then return end
    dat = dat.fe
    local sn = dat.sksn
    if dat == nil or sn == nil or sn == 0 then return end
    local fes = h.fe
    if fes == nil then fes = { }; h.fe = fes end
    local fe = fes[sn]
    if fe == nil then fe = { }; fes[sn] = fe end
    fe.sksn, fe.cur, fe.exp = sn, dat.cur or 0, dat.exp or 0
    h.changed = true
end
--[Commen]
-- 获取技能当前五行
function _hero.GetCurFe(h, sn) h = h.fe; if h then h = h[sn]; return h and h.cur or 0 end end
--[Commen]
--获取技能五行数据
function _hero.GetFe(h, sn) h = h.fe; return h and h[sn] end
----------------------------------------------------------

--获取器对接
local _get = { }
--是否可升阶
_get.CanEvo = function(h)
    if h.rare >= DB.param.rareHeroEvo and h.evo < DB.maxHeroEvo then
        local es, el = DB.GetHeroEvo(h.rare, h.evo)
        return h.lv >= el and user.GetSoulQty(h.dbsn) >= es
    end
end

--当前等级拥有的经验
local function LvExp(h) return math.max(0, h.exp - DB.GetHeroLvExp(h.lv)) end
--当前升级所需的经验
local function MaxLvExp(h) return math.max(1, DB.GetHeroLvExp(h.lv + 1) - DB.GetHeroLvExp(h.lv)) end
--当前等级拥有的经验
_get.LvExp = LvExp
--当前升级所需的经验
_get.MaxLvExp = MaxLvExp
--当前经验百分比
_get.PercentExp = function(h) return math.clamp(LvExp(h) / MaxLvExp(h), 0, 1) end
-- 是否是最大将星等级
_get.IsMaxStarLv = function(h) return h.star >= DB.maxHeroStar end
--  是否拥有将星
_get.IsStarHero = function(h) return h.rare >= MAIN_HERO_RARE end
--当前是否可升级将星（用于小助手）
_get.CanUpStar = function(h)
    if h.rare < MAIN_HERO_RARE or h.star >= DB.maxHeroStar then return false end
    local nxt = DB.GetHeroStar(h.star + 1)
    if h.lv < nxt.clv or user.GetSoulQty(h.dbsn) < nxt.soul then return false end
    if nxt.mat then
        for _, v in ipairs(nxt.mat) do
            if v[1] == 2 and user.GetPropsQty(v[2]) < (v[3] or 0) then return false end
        end
    end
    return true
end

--当前官阶拥有的功勋
local function TtlMerit(h) return math.max(0, h.merit - DB.GetHeroTtl(h.ttl).merit) end
--当前升官所需的功勋
local function MaxTtlMerit(h) return math.max(1, DB.GetHeroTtl(h.ttl + 1).merit - DB.GetHeroTtl(h.ttl).merit) end
--当前官阶拥有的功勋
_get.TtlMerit = TtlMerit
--当前升官所需的功勋
_get.MaxTtlMerit = MaxTtlMerit
--当前功勋百分比
_get.PercentMerit = function(h) return math.clamp(TtlMerit(h) / MaxTtlMerit(h), 0, 1) end
--将领是否可以晋级
_get.CanPromotion = function(h) return h.ttl < DB.maxHeroTtl and h.merit >= DB.GetHeroTtl(h.ttl + 1).merit end

--根据属性ID取得值
local function GetAtt(h, aid) return GetEquipAtt(h, aid) + GetCultiveAtt(h, aid) + GetDeheroAtt(h, aid) + GetSecretAtt(h, aid) + user.GetBeautyAtt(aid) end
--不受忠诚影响的最高武力
_get.MaxStr = function(h)  return h.baseStr + GetAtt(h, ATT_BID.STR) end
--不受忠诚影响的最高智力
_get.MaxWis = function(h) return h.baseWis + GetAtt(h, ATT_BID.WIS) end
--不受忠诚影响的最高统帅
_get.MaxCap = function(h) return h.baseCap + GetAtt(h, ATT_BID.CAP) end
--当前最大生命
_get.MaxHP = function(h) return h.baseHP + GetAtt(h, ATT_BID.HP) end
--当前最大技力
_get.MaxSP = function(h) return h.baseSP + GetEquipAtt(h, ATT_BID.SP) + GetDeheroAtt(h, ATT_BID.SP) end
--当前最大兵力
_get.MaxTP = function(h) return h.baseTP + GetEquipAtt(h, ATT_BID.TP) + GetDeheroAtt(h, ATT_BID.TP) end

--忠诚影响
local function LoyaltyRate(l) return(l < 80 and l + 20 or 100) / 100 end
--最终武力
_get.str = function(h) return math.ceil(_get.MaxStr(h) * LoyaltyRate(h.loyalty)) end
--最终智力
_get.wis = function(h) return math.ceil(_get.MaxWis(h) * LoyaltyRate(h.loyalty)) end
--最终统帅
_get.cap = function(h) return math.ceil(_get.MaxCap(h) * LoyaltyRate(h.loyalty)) end

--是否在PVP城池
_get.InPvpCity = function(h) return PY_PvpCity.IsPvpCity(h.loc) end
--将领是否在训练中
_get.InTrain = function(h) if user.trainHero then for _, v in ipairs(user.trainHero) do if v == h.sn then return true end end end return false end
--是否可参与过关斩将
_get.CanJoinTower = function(h) return h.rare >= DB.param.towerHeroRare and h.lv >= DB.param.towerHeroLv end
--是否可参战过关斩将
_get.CanFightTower = function(h)
    if h.rare >= DB.param.towerHeroRare and h.lv >= DB.param.towerHeroLv then
        local lst = user.towerInfo
        if lst then
            lst = lst.hero
            if lst and #lst > 0 then
                for i = 1, #lst do
                    if tostring(lst[i].csn) == h.sn then
                        return lst[i].hp > 0
                    end
                end
            end
        end
        return true
    end
    return false
end
--是否可以参与乱世争雄
_get.CanJoinClanWar = function(h) return h.rare >= MAIN_HERO_RARE end

--忠诚度较低
_get.IsLowLoyalty = function(h) return h.loyalty < 80 end
--生命值较低
_get.IsLowHP = function(h) return h.hp < _get.MaxHP(h) * 0.5 end
--兵力值较低
_get.IsLowTP = function(h) return h.tp < _get.MaxTP(h) * 0.5 end
--是否到底等级极限,主要是主城限制
_get.IsLvLmt = function(h) return h.lv >= user.HeroLvLmt end
--是否是最高等阶
_get.IsMaxEvo = function(h) return h.evo >= DB.maxHeroEvo end
--是否是最高等级
_get.IsMaxLv = function(h) return h.lv >= DB.maxHeroLv end
--是否可学新的兵种
_get.CanLearnArm = function(h) return DB.ArmUN(h.lv) > (h.armLst and #h.armLst or 0) end
--是否可学新的阵形
_get.CanLearnLnp = function(h) return DB.LnpUN(h.lv) > (h.lnpLst and #h.lnpLst or 0) end
--是否可铭刻阵形
_get.CanImpLnp = function(h) return h.lv >= DB.unlock.lnpImp and table.exists(h.lnpExtQty, function(v) return v < 10 end) end
_get.Intu = function() return 90 end
--[Commen]
-- 将领的默认排序
function _hero.Compare(x, y)
    if x.rare > y.rare then return true end
    if x.rare < y.rare then return false end
    if x.lv > y.lv then return true end
    if x.lv < y.lv then return false end
--    if x.ttl > y.ttl then return true end
--    if x.ttl < y.ttl then return false end
    return x.ttl > y.ttl
end

--[Commen]
-- 将领的默认反排序
function _hero.CompareReverse(x, y)
    if x.rare > y.rare then return false end
    if x.rare < y.rare then return true end
    if x.lv > y.lv then return false end
    if x.lv < y.lv then return true end
--    if x.ttl > y.ttl then return true end
--    if x.ttl < y.ttl then return false end
    return x.ttl < y.ttl
end

--[Comment]
--Item接口(显示用的名称)
function _hero.getName(h) return NameStyle.Plus(LN(h.nm), h.evo) end
--[Comment]
--Item接口(显示用的名称)
function _hero.itemName(h) return LN(h.nm) end

--配置获取器
_hero.__get = _get
--继承
objext(_hero, DataCell)
--[Comment]
--玩家将领数据
PY_Hero = _hero

