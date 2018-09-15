local _props =
{
    --[Comment]
    --珠宝箱 编号
    ZHU_BAO_XIANG = 6,
    --[Comment]
    --精钢 编号
    JING_GANG = 4,
    --[Comment]
    --珠宝 编号
    ZHU_BAO = 5,
    --[Comment]
    --幻化石 编号
    HUAN_HUA_SHI = 10,
    --[Comment]
    --小经验丹 编号
    XIAO_JING_YANDAN = 11,
    --[Comment]
    --大经验丹 编号
    DA_JING_YAN_DAN = 12,
    --[Comment]
    --超级经验丹 编号
    CHAO_JI_JING_YAN_DAN = 21,
    --[Comment]
    --属性药剂 编号
    SHU_XING_YAO_JI = 14,
    --[Comment]
    --白旗 编号
    BAI_QI = 27,
    --[Comment]
    --魂元丹 编号
    HUN_YUAN_DAN = 20,
    --[Comment]
    --阵纹符 编号
    ZHEN_WEN_FU = 30,
    --[Comment]
    --挑战令 编号
    TIAO_ZHAN_LING = 31,
    --[Comment]
    --打孔锥 编号
    DA_KONG_ZHUI = 32,
    --[Comment]
    --暗渡陈仓 编号
    AN_DU_CHEN_CANG = 61,
    --[Comment]
    --刷新卷 编号
    SHUA_XIN_JUAN = 66,
    --[Comment]
    --替身草人 编号
    TI_SHEN_CAO_REN = 67,
    --[Comment]
    --修炼卡 编号
    XIU_LIAN_KA = 68,
    --[Comment]
    --改名卡
    GAI_MING = 77,
    --[Comment]
    --联盟改名卡
    LIAN_MENG_GAI_MING = 78,
    --[Comment]
    --洗炼石
    XI_LIAN_SHI = 79,
    --[Comment]
    --寒铁
    HAN_TIE = 83,
    --[Comment]
    --转盘币
    ZHUAN_PAN_BI = 123,

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
    --道具的类型描述
    ti = "",
    --[Comment]
    --图像
    img = 0,
    --[Comment]
    --道具稀有度
    rare = 0,
    --[Comment]
    --道具的分类 [0=其它 1=恢复 2=加强 3=宝箱 4=争霸 5=计谋 6=副将 7=五行 8=礼品 9=pve BUFF 10=铜雀台材料 11=铜雀台升星材料]
    kind = 0,
    --[Comment]
    --道具的使用对象[0=不可使用 1=对玩家自身 2=对武将 3=赠送物品 4=PVP城池使用道具, 5=计谋 6=副将]
    trg = 0,
    --[Comment]
    --排序索引
    sort = 0,
    --[Comment]
    --批量使用数量
    bat = 0,
    --[Comment]
    --作用值
    val = 0,
    --[Comment]
    --道具的价格,银币价格
    coin = 0,
    --[Comment]
    --道具的价格,金币价格
    gold = 0,
    --[Comment]
    --coin=银币 gold=金币 blood=医疗营加血 char=武将包 exp=武将加经验 troop=兵营征兵 attrib=武将加属性
    code = nil,

}

function _props.ShowData(p, qty)
    ToolTip.ShowPropTip(p.nm or L("未知"), L("类型") .. ":" .. p.ti ..(qty and "\n" .. L("数量") .. ":" .. qty or "") .. "\n" .. L("说明") .. ":" .. p.i)
end

function _props.ShowDesc(p)
    ToolTip.ShowPropTip(p.nm or L("未知"), L("说明") .. ":" .. p.i)
end

--[Comment]
--道具默认比较器
function _props.Compare(x, y)
    return x.sort < y.sort
end

--[Comment]
--Item接口(显示名称)
function _props.getName(p) return LN(p.nm) end
--[Comment]
--Item接口(显示信息)
function _props.getIntro(p) return L(p.i) end
--[Comment]
--ToolTip接口(显示名称和信息)
function _props.getPropTip(p, qty)
    qty = qty or p.qty
    return LN(p.nm), L("类型") .. ":" .. p.ti ..(qty and "\n" .. L("数量") .. ":" .. qty or "") .. "\n" .. L("说明") .. ":" .. L(p.i)
end

--继承
objext(_props)
--[Comment]
--未定义的
_props.undef = _props()
--[Comment]
--道具
--[31]={sn=31,nm="挑战令",i="用于挑战战役消耗，每个令牌相当于一次挑战机会(可在占卜、寻宝玩法中获得)",ti="",img=31,kind=2,trg=0,sort=31,bat=0,val=1,rare=4,coin=0,gold=0,rmb=0},
DB_Props = _props