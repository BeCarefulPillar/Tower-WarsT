local _skp =
{
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
    --需求的技能
    rsk = 0,
    --[Comment]
    --需求的技能等级
    rlv = 0,
    --[Comment]
    --每级的数据(升级/学习需要的材料)
    lvs = nil,
}

function _skp.getName(s) return LN(s.nm) end
--[Comment]
--获取等级描述
function _skp.getIntro(s, lv)
    local v = s.lvs
    if v then
        if lv and lv > 0 then
            v = v[lv < 1 and 1 or lv > #v and #v or lv]
            return string.format(s.i, v and v.v or 0)
        else
            return string.format(s.i,(v[1] and v[1].v or 0) .. "-" ..(v[#v] and v[#v].v or 0))
        end
    end
    return ""
end
function _skp.getPropTip(s, lv)
    local v = s.lvs
    if v then
        if lv and lv > 0 then
            v = v[lv < 1 and 1 or lv > #v and #v or lv]
            return LN(s.nm), L("类型") .. ":" .. L("锦囊技") .. "\n" .. L("等级") .. ":" .. lv .. "\n" .. L("说明") .. ":" .. string.format(s.i, v and v.v or 0)
        else
            return LN(s.nm), L("类型") .. ":" .. L("锦囊技") .. "\n" .. L("说明") .. ":" .. string.format(s.i,(v[1] and v[1].v or 0) .. "-" ..(v[#v] and v[#v].v or 0))
        end
    end
end

--[Comment]
--获取指定等级需求的材料
function _skp.GetMat(s, lv) return s.lvs and s.lvs[lv] or nil end
--[Comment]
--取得最大等级
function _skp.MaxLevel(s) return s.lvs and #s.lvs or 0 end
--[Comment]
--等级编号是否有效
function _skp.LsnIsAvailable(lsn) return lsn > 1000 end
--[Comment]
--从等级编号取得锦囊技编号
function _skp.GetSnFromLsn(lsn) return(math.modf(lsn / 1000)) end
--[Comment]
--从等级编号取得锦囊技等级
function _skp.GetLvFromLsn(lsn) return lsn % 1000 end

--继承
objext(_skp)
--[Comment]
--未定义的
_skp.undef = _skp()
--[Comment]
--锦囊技
--[1]={sn=1,nm="以静制动",i="%s秒之内己方武将始终不会主动出击",img=1,rsk=0,rlv=0,lvs={
--[1]={l=1,m={{2,69,5},{2,71,1},{1,1,10000}},v=1},}
DB_SKP = _skp