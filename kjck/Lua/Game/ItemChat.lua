local type = type
--local notnull = notnull
--local isnull = isnull

local _it =
{
    --[Comment]
    --ItemGoods的根对象
    go = nil,
    --[Comment]
    --普通消息根对象
    msg = nil,
    --[Comment]
    --系统消息根对象 UILabel
    msgSys = nil,
    --[Comment]
    --红包 UISprite
    red = nil,

    --[Comment]
    --头像 UITexture
    ava = nil,
    --[Comment]
    --VIP背景 UISprite
    vipBg = nil,
    --[Comment]
    --VIP 十位数 UISprite
    vip1 = nil,
    --[Comment]
    --VIP 个位数 UISprite
    vip2 = nil,
    --[Comment]
    --频道 UILabel
    chn = nil,
    --[Comment]
    --称号 UILabel
    httl = nil,
    --[Comment]
    --称号背景 UITexture
--    httlBg = nil,
    --[Comment]
    --国主标记 UISprite
    master = nil,
    --[Comment]
    --昵称 UILabel
    nm = nil,
    --[Comment]
    --文本内容 UILabel
    txt = nil,
    --[Comment]
    --文本背景 UISprite
    txtBg = nil,

    --[Comment]
    --是否Self预制件
    isSelf  = false,
    --[Comment]
    --数据对象 PY_Chat
    dat = nil,
    --[Comment]
    --玩家数据 MsgData.Player
    pyDat = nil,
}

local _const =
{
    V3_0 = Vector3.zero,
    V3_1 = Vector3.one,

    V3_Nick_1 = Vector3(250, 0, 0),
    V3_Nick_2 = Vector3(212, 0, 0),

    COR_W = Color.white,
    COR_G = Color.grey,
}

function _it.New(go, isSelf)
    assert(notnull(go), "create ItemChat need GameObject")
    local ava = go:Child("avatar")
    local vipBg = ava:Child("bg_vip")
    local vip1 = vipBg:ChildWidget("lab_vip_1")
    local vip2 = vipBg:ChildWidget("lab_vip_2")
    local httl = ava:ChildWidget("rank")
    local master = ava:ChildWidget("master")
    local nm = ava:ChildWidget("name")
    local txt = ava:ChildWidget("content")
    local txtBg = ava:ChildWidget("content/bg")
    local chn = ava:ChildWidget("filter")

    local sys = go:ChildWidget("systemMsg")
    local red = sys:ChildWidget("redPocket")
    return
    {
        isSelf = isSelf,

        go = go,

        vipBg = vipBg.widget,
        vip1 = vip1.widget,
        vip2 = vip2.widget,
        httl = httl.widget,
        master = master.widget,
        nm = nm.widget,
        txt = txt.widget,
        txtBg = txtBg.widget,

        sys = sys.widget,
        red = red.widget,
        ava = ava.widget,
        chn = chn.widget,
    }
end

local function ClickTxt(btn)
    btn = Item.Get(btn)
    btn = btn and btn.dat or nil
    if btn then
        if btn.style == ChatStyle.ShareHero then
            Win.Open("PopShowHero", btn:GetExtObj())
        elseif btn.style == ChatStyle.ShareEquip then
            Win.Open("PopShowEquip", btn:GetExtObj())
        elseif btn.style == ChatStyle.ShareDehero then
            Win.Open("PopShowDehero", btn:GetExtObj())
        elseif btn.style == ChatStyle.ShareDequip then
            Win.Open("PopShowDequip", btn:GetExtObj())
        end
    end
end

local function CheckShare(i, isShare)
    if isShare then
        i.txt.supportEncoding = true
        NGUITools.AddWidgetCollider(i.txtBg.cachedGameObject)
        local btn = i.txtBg.luaBtn
        if btn == nil then
            btn = i.txtBg:AddCmp(typeof(LuaButton))
            btn.transferSelf = true
            btn:SetClick(ClickTxt)
        end
    else
        i.txt.supportEncoding = false
        i.txtBg:DesCmp(typeof(UE.Collider))
    end
end

function _it.Init(i, d)
    i.dat = d
    if d.style == ChatStyle.RedPacket then
        --红包
        i.ava:SetActive(false)
        i.sys.text = "[ec0404][" .. L("系统消息") .. "][-]" .. (d.text or "")
        i.red.spriteName = d.flag == 0 and "sp_closedRP" or "sp_openedRP"
        i.sys:SetActive(true)
        i.red:SetActive(true)
        CheckShare(i, false)
    else
        i.red:SetActive(false)
        if d.chn == ChatChn.System then
            --系统消息
            i.ava:SetActive(false)
            i.sys.text = "[ec0404][" .. L("系统消息") .. "][-]" .. (d.text or "")
            i.sys:SetActive(true)
            i.txt:SetActive(false)
        else
            i.sys:SetActive(false)

            i.ava:LoadTexAsync(ResName.PlayerIconMain(d.ava));
            i.chn.text = "【".. ChatChn.Name(d.chn) .."】"
            i.chn.color = ColorStyle.Chat(d.chn)
            i.nm.text = d.nick or L("匿名")
            i.txt.color = ColorStyle.Chat(d.chn)
            i.txt.text = d.text or ""
            
            --设置VIP图片显示等级
            if d.vip == 1 then
                i.vip1:SetActive(false)
                i.vip2.spriteName = "lab_chat_vip_1"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_1_4"
                i.vipBg:SetActive(true)
            elseif d.vip == 2 then
                i.vip1:SetActive(false)
                i.vip2.spriteName = "lab_chat_vip_2"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_1_4"
                i.vipBg:SetActive(true)
            elseif d.vip == 3 then
                i.vip1:SetActive(false)
                i.vip2.spriteName = "lab_chat_vip_3"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_1_4"
                i.vipBg:SetActive(true)
            elseif d.vip == 4 then
                i.vip1:SetActive(false)
                i.vip2.spriteName = "lab_chat_vip_4"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_1_4"
                i.vipBg:SetActive(true)
            elseif d.vip == 5 then
                i.vip1:SetActive(false)
                i.vip2.spriteName = "lab_chat_vip_5"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_5_8"
                i.vipBg:SetActive(true)
            elseif d.vip == 6 then
                i.vip1:SetActive(false)
                i.vip2.spriteName = "lab_chat_vip_6"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_5_8"
                i.vipBg:SetActive(true)
            elseif d.vip == 7 then
                i.vip1:SetActive(false)
                i.vip2.spriteName = "lab_chat_vip_7"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_5_8"
                i.vipBg:SetActive(true)
            elseif d.vip == 8 then
                i.vip1:SetActive(false)
                i.vip2.spriteName = "lab_chat_vip_8"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_5_8"
                i.vipBg:SetActive(true)
            elseif d.vip == 9 then
                i.vip1:SetActive(false)
                i.vip2.spriteName = "lab_chat_vip_9"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_5_8"
                i.vipBg:SetActive(true)
            elseif d.vip == 10 then
                i.vip1.spriteName = "lab_chat_vip_1"
                i.vip1:SetActive(true)
                i.vip2.spriteName = "lab_chat_vip_0"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_9_12"
                i.vipBg:SetActive(true)
            elseif d.vip == 11 then
                i.vip1.spriteName = "lab_chat_vip_1"
                i.vip1:SetActive(true)
                i.vip2.spriteName = "lab_chat_vip_1"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_9_12"
                i.vipBg:SetActive(true)
            elseif d.vip == 12 then
                i.vip1.spriteName = "lab_chat_vip_1"
                i.vip1:SetActive(true)
                i.vip2.spriteName = "lab_chat_vip_2"
                i.vip2:SetActive(true)
                i.vipBg.spriteName = "bg_main_vip_9_12"
                i.vipBg:SetActive(true)
            else
                i.vipBg:SetActive(false)
            end

            if d.vip >= 10 then 
                i.vip1.transform.localPosition = Vector3(-5,0,0)
                i.vip2.transform.localPosition = Vector3(3,0,0)
            else
                i.vip2.transform.localPosition = _const.V3_0
            end

            --设置国主头像 名字位置
--            if d.master > 0 then
--                i.master.spriteName = "sp_c_perm_" + d.master
--                i.master.cachedTransform.localScale = _const.V3_1
----                if d.sender ~= user.psn then i.nm.cachedTransform.localPosition = _const.V3_Nick_1 end
--            else
--                i.master.cachedTransform.localScale = _const.V3_0
----                if d.sender ~= user.psn then i.nm.cachedTransform.localPosition = _const.V3_Nick_2 end
--            end

--            local var = nil

            --设置称号
--            if d.httl > 0 then
--                var = DB.GetHttl(d.httl)
----                if var.img > 0 then
----                    i.httl.text = ""
----                    i.httl:SetActive(false)
----                    i.httlBg:SetActive(true)
----                    i.httlBg:LoadTexAsync(ResName.PlayerHtitleIcon(var.img), false, false)
----                    var = true
----                else
--                    i.httl.text = var:getName()
--                    i.httl.color = _const.COR_W
--                    i.httl.applyGradient = true
--                    i.httl.gradientBottom = ColorStyle.GetRareColor(var.rare)
--                    i.httl:SetActive(true)
----                    i.httlBg:SetActive(false)
----                end
--            else
--                i.httl.text = L("无称号")
--                i.httl.color = _const.COR_G
--                i.httl.applyGradient = false
--                i.httl:SetActive(true)
----                i.httlBg:SetActive(false)
--            end

--            EF.BindRectCorner(i.isSelf and i.chn or i.master, var == true and i.httlBg or i.httl)

--            var = i.txt.printedSize

            i.ava.luaBtn.isEnabled = d.sender ~= user.psn

            i.ava:SetActive(true)
        end
        CheckShare(i, ChatStyle.IsShare(d.style))
    end
    i.pyDat = nil
    i.go:SetActive(true)
end

--继承
objext(_it, Item)
--[Comment]
--通用Item
ItemChat = _it