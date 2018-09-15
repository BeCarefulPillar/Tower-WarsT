--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
local _hero =
{
    --[Comment]
    --周仓的DBSN   统将
    TONG_JIANG = 50,
    --[Comment]
    --张角的DBSN   智将
    ZHI_JIANG = 337,
    --[Comment]
    --华雄的DBSN   武将
    WU_JIANG = 47,
    --[Comment]
    --吕布的DBSN
    LV_BU = 3,

    --[Comment]
    --编号
    sn = 0,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --历史描述
    i = "",
    --[Comment]
    --头像编号
    img = 0,
    --[Comment]
    --性别 1=男 2=女 else=未知
    sex = 0,
    --[Comment]
    --类型 (1:猛将 2:智将 3:帅)
    kind = 0,
    --[Comment]
    --国别 1=魏 2=蜀 3-吴 else=群雄
    clan = 0,
    --星级
    rare = 0,
    --[Comment]
    --外形(1=大刀 2=刀 3=戟 4=剑 5=女 6=扇)
    body = 0,
    --[Comment]
    --马(1=白 2=黑 3=红 4=黄 5=土)
    horse = 0,
    --[Comment]
    --是否隐藏
    hide = 0,
    --[Comment]
    --初始阵形
    lnp = 0,
    --[Comment]
    --兵种
    arm = 0,
    --[Comment]
    --拥有的武将技SN
    skc = nil,
    --[Comment]
    --拥有的军师技SN
    skt = 0,
    --[Comment]
    --武将修炼最高属性基础值 [武 智 统 血]
    xlAtt = nil,
    --[Comment]
    --武将修炼最高属性成长值 [武 智 统 血]
    xlGrow = nil,
    --[Comment]
    --武力
    str = 0,
    --[Comment]
    --智力
    wis = 0,
    --[Comment]
    --统帅
    cap = 0,
    --[Comment]
    --生命值
    hp = 0,
    --[Comment]
    --技能值
    sp = 0,
    --[Comment]
    --兵力
    tp = 0,
    --[Comment]
    --力量每级成长
    lstr = 0,
    --[Comment]
    --智力每级成长
    lwis = 0,
    --[Comment]
    --统帅每级成长
    lcap = 0,
    --[Comment]
    --生命值每级成长
    lhp = 0,
    --[Comment]
    --技能值每级成长百分之
    lsp = 0,
    --[Comment]
    --兵力每级成长百分之
    ltp = 0,
    --[Comment]
    --进阶武力增量参数
    estr = 0,
    --[Comment]
    --进阶智力增量参数
    ewis = 0,
    --[Comment]
    --进阶统帅增量参数
    ecap = 0,
    --[Comment]
    --进阶生命增量参数
    ehp = 0,
    --[Comment]
    --进阶技力增量参数
    esp = 0,
    --[Comment]
    --进阶兵力增量参数
    etp = 0,
    --[Comment]
    --觉醒技能
    ske = 0,
    --[Comment]
    --升星武力成长值
    sstr = 0,
    --[Comment]
    --升星智力成长值
    swis = 0,
    --[Comment]
    --升星统帅成长值
    scap = 0,
    --[Comment]
    --升星生命成长值
    shp = 0,
    --[Comment]
    --将星扩展属性
    starAtt = nil,
    --[Comment]
    --天机技能列表
    sks = nil,
    --[Comment]
    --极限挑战奖励
    jxRws = nil,
    --[Comment]
    --TCG稀有度
    tcgRare = 0,
    --[Comment]
    --TCG阵营
    tcgClan = 0,
    --[Comment]
    --TCG武力
    tcgStr = 0,
    --[Comment]
    --TCG伤害
    tcgDmg = 0,
    --[Comment]
    --TCG武将技
    tcgSkl = 0,
    --[Comment]
    --群英荟萃扩展属性
    atlasAtt = nil,
    --[Comment]
    --资质
    aptitude = 0,
}

--[Comment]
--武将职业类型名称表[1:武将,2:谋士,3:统帅]
local _knm = { "武将", "智将", "统帅" }
--[Comment]
--获取武将职业类型名称
local function GetKindName(kind) return LN(_knm[kind]) end
--[Comment]
--获取武将职业类型名称
_hero.GetKindName = GetKindName

--[Comment]
--获取极限挑战对应难度的奖励
function _hero.GetJXRw(h, dif) return h and h.jxRws and h.jxRws[dif] or nil end
--[Comment]
--武将EVO名称显示
function _hero.GetEvoName(h, evo)
    if h.nm == nil then return L.UNK() end
    return evo and evo > 0 and L(h.nm) .. "+" .. evo or L(h.nm)
end

--[Comment]
--获取星级属性说明
function _hero.GetStarDesc(h, star)
    if h.starAtt and #h.starAtt > 0 then
        if star <= #h.starAtt then return DB.GetAttWord(h.starAtt[star]) end
        if h.skc then return DB.GetSkc(h.skc[#h.skc]).si end
    end
    return ""
end

--[Comment]
--获取修炼属性最大值(aid:1=武 2=智 3=统 4=血,rank:给定的武将官阶)
function _hero.GetMaxXLAtt(h, aid, rank)
    return(h.xlAtt and h.xlAtt[aid] or 0) +(rank and rank > 1 and(h.xlGrow and h.xlGrow[aid] or 0) *(rank - 1) or 0)
end

--[Comment]
--武将类型名称
function _hero.KindNm(h) return GetKindName(h and h.kind) end
--武将是否将星武将
--[Comment]
function _hero.IsStar(h) return h.rare >= 5 end

--[Comment]
--默认比较器
function _hero.Compare(x, y)
    if x.rare > y.rare then return true end
    if x.rare < y.rare then return false end
    return x.nm < y.nm
    --return String.Compare(x.nm, y.nm) == -1
end

--[Comment]
--Item接口(显示用的名称)
function _hero.getName(h) return LN(h.nm) end
--[Comment]
--Item接口(显示信息)
function _hero.getIntro(h) return L(h.i) end
--[Comment]
--ToolTip接口(显示用的信息)
function _hero.getPropTip(h) return ColorStyle.Rare(h), string.format("%s:%s%s%s\n%s:%-7d%s:%d\n%s:%-7d%s:%d\n%s:%-7d%s:%d\n%s:%s",
    L("类型"), number.ToCnString(h.rare or 0), L("星"), GetKindName(h.kind),
    L("武力"), h.str or 0, L("生命"), h.hp or 0,
    L("智力"), h.wis or 0, L("技力"), h.sp or 0,
    L("统帅"), h.cap or 0, L("兵力"), h.tp or 0,
    L("历史"), h.i)
end

--[Comment]
--显示将魂说明
function _hero.ShowSoulDesc(h)
    ToolTip.ShowPropTip(L(ColorStyle.Rare(h.nm .. "(将魂)", h.rare)), L("类型:将魂").."\n"..L("说明:") .. string.format(L("用于觉醒%s，提升%s将星，或分解为魂币"), h.nm,h.nm))
end



--继承
objext(_hero)
--[Comment]
--未定义的
_hero.undef = _hero()
--[Comment]
--武将
--{sn=29,nm="马腾",i="说明。",jxRws={},sks={},atlasAtt=ExtAtt({}),starAtt=ExtAtt({}),xlAtt={},xlGrow={},img=29,sex=1,clan=0,kind=3,rare=4,body=2,horse=3,str=99,wis=71,cap=222,hp=189,sp=22,tp=10,lstr=7,lwis=7,lcap=18,lhp=14,lsp=40,ltp=40,estr=0,ewis=0,ecap=0,ehp=0,esp=0,etp=0,ske=0,sstr=0,swis=0,scap=0,shp=0,arm=3,lnp=4,skc={47,16,52},skt=10,aptitude=80},
DB_Hero = _hero 
