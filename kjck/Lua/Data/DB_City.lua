local _city =
{
    --[Comment]
    --DB序列号
    sn = 0,
    --[Comment]
    --图号
    img = 0,
    --[Comment]
    --战场图号
    map = 0,
    --[Comment]
    --所属关卡
    main = 0,
    --[Comment]
    --名称
    nm = nil,
    --[Comment]
    --副本特点
    fb = "",
    --[Comment]
    --介绍
    i = "",
    --[Comment]
    --副本奖励（简单）
    rwFB1 = nil,
    --[Comment]
    --副本奖励（普通）
    rwFB2 = nil,
    --[Comment]
    --副本奖励（困难）
    rwFB3 = nil,
    --[Comment]
    --品级
    rare = 0,
    --[Comment]
    --初始等级
    lv = 0,
    --[Comment]
    --升级所需的初始经验
    exp = 0,
    --[Comment]
    --基础产出
    crop = 0,
    --[Comment]
    --产出的等级增长
    cropG = 0,
    --[Comment]
    --初始武将列表
    npc = nil,
}

--[Comment]
--Item接口(显示名称)
function _city.getName(c) return LN(c.nm) end
--[Comment]
--Item接口(显示信息)
function _city.getIntro(c) return L(c.i) end
--[Comment]
--ToolTip接口(显示名称和信息)
function _city.getPropTip(c) return LN(c.nm), L("说明") .. ":" .. L(c.i) end

--继承
objext(_city)
--[Comment]
--未定义的
_city.undef = _city()
--[Comment]
--关卡城池
--[54]={sn=54,nm="长沙",i="",rwFB1={{1,1,4500},{2,12,2},{2,21,2},{1,15,200}},rwFB2={{1,1,4500},{2,12,3},{2,21,3},{1,15,200}},rwFB3={{1,1,4500},{2,12,4},{2,21,4},{1,15,200}},fb="经验",main=6,img=2,map=5,rare=6,lv=7,exp=6160,crop=148,cropG=62,npc={441,475,451,311,478,441,475,451,311,478,441,475,451,311,478}},
DB_City = _city