--频道名称
local _chat_chn_nm = { "系统", "私聊", "世界", "联盟", "国家" }
--[Comment]
--聊天频道
local _cc = 
{
    --[Comment]
    --未知
    Unknown = 0,
    --[Comment]
    --系统
    System = 1,
    --[Comment]
    --私聊
    Private = 2,
    --[Comment]
    --世界
    World = 3,
    --[Comment]
    --联盟
    Ally = 4,
    --[Comment]
    --国家
    Nat = 5,

    --[Comment]
    --频道名称
    Name = function(chn) return LN(_chat_chn_nm[chn]) end,
    --[Comment]
    --是否无效频道
    Invalid = function(chn) return chn == nil or chn < 1 or chn > 5 end,
}
--[Comment]
--聊天频道
ChatChn = _cc

--[Comment]
--聊天方式
local _cs =
{
    --[Comment]
    --历史标签
    Hist = -1,
    --[Comment]
    --普通文本
    Text = 0,
    --[Comment]
    --语音
    Voice = 1,
    --[Comment]
    --红包
    RedPacket = 2,
    --[Comment]
    --分享武将
    ShareHero = 3,
    --[Comment]
    --分享装备
    ShareEquip = 4,
    --[Comment]
    --分享副将
    ShareDehero = 5,
    --[Comment]
    --分享军备
    ShareDequip = 6,
}
--[Comment]
--是否是分享方式
function _cs.IsShare(style)return style == _cs.ShareHero or style == _cs.ShareEquip or style == _cs.ShareDehero or style == _cs.ShareDequip end

--[Comment]
--聊天方式
ChatStyle = _cs

local _c = class()
--[Comment]
--聊天数据
PY_Chat = _c

--发送者PSN
_c.sender = nil
--目标编号[私聊:PSN,世界:0,联盟:联盟编号,国家:国家编号]
_c.trg = nil
--聊天频道[0:未知,1:系统,2:私聊,3:世界,4:联盟,5:国家]
_c.chn = 0
--聊天方式[-1:历史标签,0:普通聊天,1:语音聊天,2:红包,3:分享武将,4:分享装备,5:分享副将,6:分享军备]
_c.style = 0
--自定义标记[是否已读等]
_c.flag = 0
--文本内容
_c.text = nil
--扩展内容[普通:无,语音:语音url,红包:红包SN,分享:json数据]
_c.ext = nil
--发送者VIP
_c.vip = 0
--发送者头像
_c.ava = 0
--发送者称号
_c.httl = 0
--发送者某国国主
_c.master = 0
--发送者昵称
_c.nick = ""
--发送者联盟名称
_c.allyNm = nil

--时间戳
_c.ts = 0

--扩展对象缓存
local _extCache = { }

function _c.ctor(c, dat, chn, style, ext, sender, trg)
    local var = type(dat)
    if var == "string" then
        c.text = dat
        c.chn = chn or 0
        c.style = style or 0
        c.ext = ext
        if chn ~= _cc.System then c.sender = CheckSN(sender)
        elseif chn == _cc.Private then c.trg = CheckSN(trg) end
    else
        assert(var == "userdata" and dat:GetType() == typeof(SFSObject), "create PY_Chat param error : dat must be string or SFSObject current is ".. tostring(dat) .. "["..var.."]")
        c.sender = CheckSN(tostring(dat:GetLong("sender")))
        c.trg = CheckSN(tostring(dat:GetLong("target")))
        c.chn = dat:GetInt("channel")
        c.style = dat:GetInt("style")
        c.text = MsgData.ProcessMsg(dat:GetUtfString("text"))
        c.ext = dat:GetUtfString("ext")
        c.vip = dat:GetInt("vip")
        c.ava = dat:GetInt("avatar")
        c.httl = dat:GetInt("htitle")
        c.master = dat:GetInt("master")
        c.nick = dat:GetUtfString("senderName")
        c.allyName = dat:GetUtfString("allyName")
    end
    c.ts = SVR.SvrTime()
end

function _c.GetExtObj(c)
    local obj = _extCache[c]
    if obj == nil and c.ext and c.ext ~= "" then
        if c.style == _cs.ShareHero then
            obj = SH_Hero(kjson.ldec(c.ext, stab.SS_Hero), c.nick, c.allyName)
        elseif c.style == _cs.ShareEquip then
            obj = SH_Equip(kjson.ldec(c.ext, stab.SS_Equip), c.nick, c.allyName)
        elseif c.style == _cs.ShareDehero then
            obj = SH_Dehero(kjson.ldec(c.ext, stab.SS_Dehero), c.nick, c.allyName)
        elseif c.style == _cs.ShareDequip then
            obj = SH_Dequip(kjson.ldec(c.ext, stab.SS_Dequip), c.nick, c.allyName)
        end
        if obj then _extCache[c] = obj end
    end
    return obj
end

function _c.__tostring(c)
    return string.format("Chat:[sender:%s,target:%s,channel:%s,style:%s,text:%s,ext:%s,flag:%s,vip:%s,avatar:%s,htitle:%s,master:%s,nick:%s,allyName:%s]",
            c.sender, c.trg, c.chn, c.style, c.text, c.ext, c.flag, c.vip, c.ava, c.httl, c.master, c.nick, c.allyName)
end

function _c.HistChat(ts)
    return ts and ts > 0 and setmetatable({ chn = 1, style = -1, ts = ts, text = os.date(L("以上为 %Y年%m月%d日%H:%M 前的历史消息"), ts) }, _c)
end
