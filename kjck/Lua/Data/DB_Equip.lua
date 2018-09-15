local _equip =
{
    --[Comment]
    --稀有值
    RARE_VALUE = 2,

    --[Comment]
    --序列号
    sn = 0,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --介绍
    i = "",
    --[Comment]
    --图号
    img = 0,
    --[Comment]
    --稀有度
    rare = 0,
    --[Comment]
    --类型(EQP_KIND)[1=武器,2=防具,3=马,4=兵书]
    kind = 0,
    --[Comment]
    --武力加成
    str = 0,
    --[Comment]
    --武力成长
    lstr = 0,
    --[Comment]
    --智力加成
    wis = 0,
    --[Comment]
    --智力成长
    lwis = 0,
    --[Comment]
    --统帅加成
    cap = 0,
    --[Comment]
    --统帅成长
    lcap = 0,
    --[Comment]
    --生命加成
    hp = 0,
    --[Comment]
    --生命成长
    lhp = 0,
    --[Comment]
    --技力加成
    sp = 0,
    --[Comment]
    --技力成长
    lsp = 0,
    --[Comment]
    --兵力加成
    tp = 0,
    --[Comment]
    --兵力成长
    ltp = 0,
    --[Comment]
    --出售的初始价格
    price = 0,
    --[Comment]
    --专属武将
    excl = 0,
    --[Comment]
    --合成需要的碎片数
    piece = 0,
    --[Comment]
    --武力进阶成长
    estr = 0,
    --[Comment]
    --智力进阶成长
    ewis = 0,
    --[Comment]
    --统帅进阶成长
    ecap = 0,
    --[Comment]
    --生命进阶成长
    ehp = 0,
    --[Comment]
    --套装ID
    suit = 0,
    --[Comment]
    --最大幻化次数
    ecQty = 0,
    --[Comment]
    --淬炼基本次数
    ecRst = 0,
    --[Comment]
    --淬炼进阶成长
    ecRstG = 0,
    --[Comment]
    --专属特殊属性
    exclAtt = nil,
    --[Comment]
    --专属星级属性
    exclAttS = nil,
    --[Comment]
    --宝石插槽
    slot = nil,
}

--[Comment]
--装备类型名称表[1:武器,2:防具,3:坐骑,4:兵书]
local _knm = { "武器", "防具", "坐骑", "兵书" }
--[Comment]
--获取装备的类型名称
local function GetKindName(kind) return L(_knm[kind] or "未知") end

--[Comment]
--获取装备的类型名称
_equip.GetKindName = GetKindName
--[Comment]
--获取类型名称
function _equip.KindName(e) return GetKindName(e.kind) end
--[Comment]
--碎片的出售价格
function _equip.PicPrice(e) return e.piece > 0 and math.floor(e.price / e.piece) or 0 end
--[Comment]
--碎片的合成价格
function _equip.MakePrice(e) return e.price * 2 end
--[Comment]
--最大专属星级
function _equip.MaxExclStar(e) return e and e.exclAttS and #e.exclAttS-1   or 0 end
--[Comment]
--获取对应专属星级的专属属性
function _equip.GetExclAtt(e, star)
    local att = e._exclAtt
    if att == nil then
        local ae, as = e.exclAtt, e.exclAttS
        if ae or as then
            att = { }
            e._exclAtt = att
            if as and #as > 0 then
                local a
                for i = 1, #as do
                    a = ExtAtt()
                    a:Add(ae)
                    a:Add(as[i])
                    att[i] = a
                end
            elseif ae then
                att[1] = ae
            end
        end
    end
    return att and star and att[star < 1 and 1 or star > #att and #att or star] or nil
end
--[Comment]
--是否有宝石孔
function _equip.HasGemSlot(e) return e.slot and #e.slot > 0 or false end

--[Comment]
--装备进阶属性加成倍数的算法
local function GetEvoAdd(evo)
    if evo and evo > 0 then
        evo = evo + 1
        return(math.modf((evo * evo + evo) / 2 - 1))
        --和服务器同步
    end
    return 0
end
--[Comment]
--装备进阶属性加成倍数的算法
_equip.GetEvoAdd = GetEvoAdd
--[Comment]
--装备属性字符串描述
local function GetAttStr(e, evo)
    evo = GetEvoAdd(evo)
    return(e.str > 0 and L("武力") .. "+" ..(e.str +(e.estr > 0 and e.estr * evo or 0))
    or e.wis > 0 and L("智力") .. "+" ..(e.wis +(e.ewis > 0 and e.ewis * evo or 0))
    or e.cap > 0 and L("统帅") .. "+" ..(e.cap +(e.ecap > 0 and e.ecap * evo or 0))
    or e.hp > 0 and L("生命") .. "+" ..(e.hp +(e.ehp > 0 and e.ehp * evo or 0))
    or e.sp > 0 and L("技力") .. "+" .. e.sp
    or e.tp > 0 and L("兵力") .. "+" .. e.tp
    or L("无")) ..(e.excl > 0 and "\n" .. L("专属武将") .. ":" ..LN(DB.GetHero(e.excl).nm) or "")
end
--[Comment]
--装备属性字符串描述
_equip.GetAttStr = GetAttStr

--[Comment]
--默认比较器
function _equip.Compare(x, y)
    if x.rare > y.rare then return true end
    if x.rare < y.rare then return false end
    return x.sn < y.sn
end

--[Comment]
--Item接口(显示名称),可传入等阶
function _equip.getName(e, evo) return NameStyle.Plus(LN(e.nm), evo) end
--[Comment]
--Item接口(显示信息)
function _equip.getIntro(e) return L(e.i) end
--[Comment]
--ToolTip接口(显示名称和信息),可传入等阶
function _equip.getPropTip(e, evo)
    return ColorStyle.Rare(e),(evo and evo > 0 and L("等阶") .. ":" .. evo .. "\n" or "") .. L("类型") .. ":" .. GetKindName(e.kind) .. "\n" .. L("属性") .. ":" .. GetAttStr(e) .. "\n" .. L("出售价格") .. ":" .. e.price .. "\n" .. L("描述") .. ":" .. L(e.i)
end

function _equip.__tostring(t) return "DB_Equip["..(t.sn or 0)..","..(t.nm or "").."]" end

--继承
objext(_equip)
--[Comment]
--未定义的
_equip.undef = _equip()
--[Comment]
--装备
--{sn=75,nm="百鸟朝凤弓",i="描述。",img=75,rare=5,kind=1,str=161,lstr=9,wis=0,lwis=0,cap=0,lcap=0,hp=0,lhp=0,sp=0,lsp=0,tp=0,ltp=0,price=50000,excl=334,piece=60,estr=95,ewis=0,ecap=0,ehp=0,suit=0,ecQty=3,ecRst=0,ecRstG=0,exclAtt={{"cd",12}},exclAttS={{"ak",181},{"ak",236},{"ak",328},{"ak",473},{"ak",692},{"ak",1001}},slot={2,3}},
DB_Equip = _equip