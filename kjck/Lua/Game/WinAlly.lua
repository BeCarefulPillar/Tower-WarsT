WinAlly = {}

local _body = nil
WinAlly.body = _body

local _ref

local btnAllyList;
local btnRecruitCfg;   --招聘设置
local btnShop;
local btnTech;
local btnActivity;
local btnExitAlly;
local btnInfoList;--放大镜和问号的按钮
local btnChangeName;
local btnImpeach;
local btnEditAnno;
local btnEditIntro;
local banner;
local allyTicket;
local allyMoney;
local labImpeach;
local infos;
local pendMember

local function isBigDay(s, e)
    return e.year > s.year or (e.year >= s.year  and e.month > s.month) or ((e.year >= s.year  and e.month >= s.month) and e.day > s.day)
end

local function UpdateInfo()
    if CheckSN(user.ally.gsn) == nil then _body:Exit() return end
    btnChangeName:SetActive(user.ally.myPerm == 2 and user.GetPropsQty(DB_Props.LIAN_MENG_GAI_MING) > 0)
    btnEditAnno.value = user.ally.anno
    btnEditIntro.value = user.ally.i
    banner.text = user.ally.banner
    infos[1].text = user.ally.gnm
    infos[2].text = user.ally.chief
    infos[3].text = user.ally.lv
    infos[4].text = user.ally.mqty .."/".. user.ally.maxMqty
    infos[5].text = user.ally.renown .."/".. DB.GetAllyUpCost(user.ally.lv)
    infos[6].text = user.ally.renownWeek
    infos[7].text = string.format(L("联盟本周声望不足%s时,联盟自动解散"), 100)
    infos[7]:GetCmp(typeof(TweenColor)).enabled = true
    infos[8].text = DB.GetNatName(user.ally.nsn)
    allyMoney.text = user.ally.myRenown
    allyTicket.text = user.ally.myCash

    btnEditAnno:SetActive(user.ally.myPerm > 0)
    btnEditIntro:SetActive(user.ally.myPerm > 0)
    btnRecruitCfg:SetActive(user.ally.myPerm > 0)
    btnExitAlly.text = user.ally.myPerm == 2 and "解散联盟" or "退出联盟"

    if user.ally.myPerm > 0 and user.ally.pendMember > 0 then  --是否有人申请加入联盟
        if pendMember == nil then
            pendMember = btnRecruitCfg:AddWidget(typeof(UISprite), "pend_tag")
            pendMember.atlas = AM.mainAtlas
            pendMember.spriteName = "sp_mark"
            pendMember:MakePixelPerfect()
            pendMember.transform.localPosition = Vector3(66, 12, 0)
            pendMember.depth = 20
        end
    else
        if pendMember then Destroy(pendMember.gameObject) pendMember = nil end
    end

    if user.ally.impName and user.ally.impName ~= "" then --是否有人弹劾盟主
        btnImpeach:SetActive(true)
        labImpeach.text = L("投票中")
        btnImpeach:SetClick("ClickImpeachVote")
    else
        if user.ally.myPerm == 1 then
            local tmp = os.date("*t", tonumber(user.ally.impInfo[1]))
            if isBigDay(tmp, os.date("*t", SVR.SvrTime())) then
                -- 如果开始日期与现在日期差一天以上  则今天还没开始
                btnImpeach.gameObject:SetActive(true)
                btnImpeach.text = L("弹劾")
                btnImpeach:SetClick("ClickImpeach")
            else
                -- 否则今天投过票了
                btnImpeach.gameObject:SetActive(false)
                btnImpeach.text = L("弹劾")
                btnImpeach:GetCmp(typeof(UIButton)).isEnabled = false
            end
        else
            btnImpeach:SetActive(false)
        end
    end
end

local function Refresh()
    user.SyncAllyInfo(function()
        UpdateInfo()
    end)
end

function WinAlly.OnLoad(c)
    WinBackground(c,{n = "联盟", r = DB_Rule.Ally})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "ClickAllyList", "ClickShop", "ClickTech", "ClickActivity", "ClickChangeName",
                   "ClickRecruitCfg", "ClickExitAlly", "ClickImpeach", "ClickImpeachVote", "ClickMember",
                   "ClickAllyMoney", "ClickAllyTicket", "ClickAllyRenown", "ClickThisWeekRenown", 
                   "OnDispose", "OnUnLoad")

    btnAllyList = _ref.btnAllyList
    btnRecruitCfg = _ref.btnRecruitCfg
    btnShop = _ref.btnShop
    btnTech = _ref.btnTech
    btnActivity = _ref.btnActivity
    btnExitAlly = _ref.btnExitAlly
    btnInfoList = _ref.btnInfoList
    btnChangeName = _ref.btnChangeName
    btnImpeach = _ref.btnImpeach
    btnEditAnno = _ref.btnEditAnno
    btnEditIntro = _ref.btnEditIntro
    banner = _ref.banner
    allyTicket = _ref.allyTicket
    allyMoney = _ref.allyMoney
    labImpeach = _ref.labImpeach
    infos = _ref.infos

--    EventDelegate.Set(btnEditAnno.onSubmit, OnAnnoChanged)
--    EventDelegate.Set(btnEditIntro.onSubmit, OnIntroChanged)
end

function WinAlly.OnInit()
    Refresh()
end

function WinAlly.OnEnter()
    UserAllyChange:Add(Refresh)
    return true
end
--其他联盟
function WinAlly.ClickAllyList()
    Win.Open("WinAllyCheckList")
end
--联盟商店
function WinAlly.ClickShop()
    Win.Open("PopAllyShop", 0)
end
--联盟科技
function WinAlly.ClickTech()
    Win.Open("PopAllyTech")
end
--活动中心
function WinAlly.ClickActivity()
    Win.Open("PopAllyActCenter")
end
--招募设置
function WinAlly.ClickRecruitCfg()
    Win.Open("PopAllyRecruitCfg")
end
--弹劾
function WinAlly.ClickImpeach()
    Win.Open("PopImpeach")
end
--投票
function WinAlly.ClickImpeachVote()
    Win.Open("PopImpeachVote")
end
--点击联盟成员放大镜
function WinAlly.ClickMember()
    Win.Open("PopAllyMember")
end
--点击联盟币问号
function WinAlly.ClickAllyMoney()
    ToolTip.ShowToolTip("科技中心捐献可获得，用于联盟商店刷新");
end
--点击盟券
function WinAlly.ClickAllyTicket()
    ToolTip.ShowToolTip("完成悬赏任务可获得，用于联盟商店对换物品");
end
--点击联盟声望
function WinAlly.ClickAllyRenown()
    ToolTip.ShowToolTip("成员完成联盟活动获得，用于提升联盟等级");
end
--点击本周声望
function WinAlly.ClickThisWeekRenown()
    ToolTip.ShowToolTip("联盟本周累积获得的声望值");
end
--联盟改名
function WinAlly.ClickChangeName()
    if user.ally.myPerm ~= 2 then ToolTip.ShowPopTip("抱歉，你在联盟的职权不够，无法进行该操作!") end

    MsgBox.Show("更改联盟名称及旗号", "取消,确定", nil, "{b14}联盟名称,{c1}旗号", function(bid, ipts)
        if bid == 1 then
            print(type(ipts))
            print(ipts[0])
            print(ipts[1])
            if ipts[0] == user.ally.gnm and ipts[1] == user.ally.banner or ipts[0] == "" and ipts[1] == "" then
                ToolTip.ShowPopTip(ColorStyle.Warning("请输入新的联盟名称及旗号!"))
            else
                if DB.HX_Check(ipts[0]) or DB.HX_Check(ipts[1]) then
                    ToolTip.ShowPopTip(ColorStyle.Warning("输入的联盟名称或旗号含有非法字符!"))
                else
                    if string.len(ipts[0]) < 2 then ToolTip.ShowPopTip(ColorStyle.Warning("联盟名称需要至少2个字符！"))
                    else
                        local nm = ipts[0] == "" and user.ally.gnm or ipts[0]
                        local ban = ipts[1] == "" and user.ally.banner or ipts[1]
                        SVR.AllyReName(nm, ban, function(result)
                            if result.success then
                                ToolTip.ShowPopTip(ColorStyle.Warning("联盟名称及旗号修改成功!"))
                                MsgBox.Exit()
                                Refresh()
                            else
                                result.hideErr = true
                                ToolTip.ShowPopTip(ColorStyle.Warning(tostring(SVR.datCache)))
                            end
                        end)
                    end
                end
            end
        else
            MsgBox.Exit()
        end
    end, true)
    MsgBox.SetInput(0, user.ally.gnm)
    MsgBox.SetInput(1, user.ally.banner)
end
--退出/解散联盟
function WinAlly.ClickExitAlly()
    if user.ally.myPerm == 2 then  --盟主
        MsgBox.Show(ColorStyle.Bad("退出联盟后科技将会失效，你确定要退出联盟吗？"), L("取消,确定"), function(bid)
            if bid == 1 then
                SVR.AllyOption("free", function(result)
                    if result.success then
                        ToolTip.ShowPopTip(ColorStyle.Bad(string.format("联盟%s已被解散!", user.ally.gnm)))
                        user.ally = { }
                        if not Win.GetOpenWin("MainMap") then Win.Open("MainMap") end
                        UserAllyChange:Remove(Refresh)
                        _body:Exit()
                    end
                end)
            end
        end)
    else
        MsgBox.Show(ColorStyle.Bad("退出联盟后科技将会失效，你确定要退出联盟吗？"), L("取消,确定"), function(bid)
            if bid == 1 then
                SVR.AllyOption("quit", function(result)
                    if result.success then
                        ToolTip.ShowPopTip(ColorStyle.Bad(string.format("你已成功退出%s联盟！", user.ally.gnm)))
                        user.ally = { }
                        if not Win.GetOpenWin("MainMap") then Win.Open("MainMap") end
                        UserAllyChange:Remove(Refresh)
                        _body:Exit()
                    end
                end)
            end
        end)
    end
end

function WinAlly.OnDispose()
    pendMember = nil
    UserAllyChange:Remove(Refresh)
end

function WinAlly.OnUnLoad()
    _body = nil
end
