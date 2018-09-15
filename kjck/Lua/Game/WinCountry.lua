local _w = { }

local _body = nil
local _ref = nil

local _info = nil

local _techTag = nil
local _peerTag = nil

--[Comment]
--当前国家编号，用于移民判断
local _countryIndex = nil
local _changeCountry = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { n = L("国家"), r = DB_Rule.Country })
    _countryIndex = 0
    _changeCountry = false
    _ref.btnEditAnno.onSubmit:Add(EventDelegate(_w.OnAnnoChanged))
end

local function UpdateInfo(info)
    _countryIndex = info.sn
    _info = info
    _ref.level.text = "Lv." .. info.lv
    _ref.nextLevel.text = "Lv." ..(info.lv < DB.maxNatLv and info.lv + 1 or DB.maxNatLv)

    _ref.btnEditAnno.value = info.anno
    _ref.countrySp.spriteName = "sp_lab_c_" .. info.sn
    _ref.avaMaster:LoadTexAsync(ResName.PlayerIcon(info.mava))
    _ref.questTip.text = info.qi
    _ref.questTip:Child("win"):ChildWidget("Label").text = L("繁荣度[00FF00]+") .. info.win
    _ref.questTip:Child("lose"):ChildWidget("Label").text = L("繁荣度[00FF00]+") .. info.lose

    _ref.infos[1].text = string.isEmpty(info.master[3]) and L("虚位以待") or info.master[3]
    _ref.infos[2].text = string.isEmpty(info.master[1]) and L("虚位以待") or info.master[1]
    _ref.infos[3].text = string.isEmpty(info.master[2]) and L("虚位以待") or info.master[2]

    _ref.duty_left:SetActive(user.nick == info.master[3])
    _ref.duty_right:SetActive(user.nick == info.master[3])
    _ref.btnEditAnno:SetActive(user.nick == info.master[3])

    _ref.infos[4].text = string.isEmpty(info.masterAlly) and L("虚位以待") or info.masterAlly
    _ref.infos[5].text = tostring(info.ally)
    _ref.infos[6].text = tostring(info.member)
    _ref.infos[7].text = string.isEmpty(info.masterAlly) and L("无") or info.friendQty

    --科技
    if notnull(_techTag) then
        _techTag:SetActive(info.techTip == 1)
    elseif info.techTip == 1 then
        _techTag = _ref.btnTech:AddWidget(typeof(UISprite), "tip_tag")
        _techTag.atlas = _ref.btnTech.widget.atlas
        _techTag.spriteName = "sp_redpoint"
        _techTag:MakePixelPerfect()
        _techTag.width = 24
        _techTag.height = 24
        _techTag.cachedTransform.localPosition = Vector3(72, 17, 0)
    end

    --爵位
    if notnull(_peerTag) then
        _peerTag:SetActive(info.peerTip == 1)
    elseif info.peerTip == 1 then
        _peerTag = _ref.btnPeerage:AddWidget(typeof(UISprite), "tip_tag")
        _peerTag.atlas = _ref.btnTech.widget.atlas
        _peerTag.spriteName = "sp_redpoint"
        _peerTag:MakePixelPerfect()
        _peerTag.width = 24
        _peerTag.height = 24
        _peerTag.cachedTransform.localPosition = Vector3(72, 17, 0)
    end

    local lv = 1
    local curBoom = 0
    local nxtBoom = 0
    local tempCity = 0

    while lv < DB.maxNatLv do
        local t = DB.GetNatLv(lv + 1)
        nxtBoom = t.merit
        tempCity = t.qty
        if info.boom < nxtBoom then
            break
        end
        lv = lv + 1
    end

    if lv < DB.maxNatLv then
        local t = DB.GetNatLv(lv)
        curBoom = t.merit
        tempCity = t.qty
        local cm = info.boom - curBoom
        local nm = nxtBoom - curBoom
        _ref.meritPro.value = math.clamp(cm / nm, 0, 1)
        _ref.meritPro:ChildWidget("exp").text = cm .. "/" .. nm
        _ref.meritPro.text = tostring(nm - cm)
    else
        _ref.meritPro.value = 1
        _ref.meritPro:ChildWidget("exp").text = L("已达最高等级")
        _ref.merit.text = "0"
    end
end

local function PriRefresh()
    SVR.GetNatInfo( function(t)
        if t.success then
            --stab.S_NatInfo
            UpdateInfo(SVR.datCache)
        end
    end )
end

function _w.OnDispose()
    if notnull(_techTag) then
        _techTag:SetActive(false)
    end
    if notnull(_peerTag) then
        _peerTag:SetActive(false)
    end
end

function _w.OnFocus(isFocus)
    if isFocus then
        PriRefresh()
        if user.nsn ~= _countryIndex then
            --if (MapManager.Instance.gameObject.activeSelf)
            --{
            --MapManager.Instance.ShowCountryMap();
            --}
        end
    end
end

function _w.OnAnnoChanged()
    if _info.anno == _ref.btnEditAnno.value then
        return
    end
    if info.master[3] == user.nick then
        MsgBox.Show(L("帝国公告已经被修改，你确定保存吗？"),
        function(flag)
            if flag then
                --btnEditAnno.value = GameData.FilterChat((string)btnEditAnno.value);
                SVR.NatAnno(_ref.btnEditAnno.value, function(t)
                    if t.success then
                        _info.anno = _ref.btnEditAnno.value
                        ToolTip.ShowPopTip(L("帝国公告修改成功！"))
                    end
                end )
            else
            end
        end )
    else
        _ref.btnEditAnno.value = _info.anno
        ToolTip.ShowPopTip(L("抱歉，该操作只能由国主进行！"))
    end
end

function _w.ClickCountry()
    Win.Open("PopCountryIntro")
end

function _w.ClickTech()
    Win.Open("WinEmpireTech")
end

function _w.Help()
    Win.Open("PopRule", DB_Rule.CountryTips)
end

function _w.ClickForeign()
    Win.Open("PopForeign")
end

function _w.ClickPeerage()
    Win.Open("PopPeerage")
end

function _w.ClickShop()
    Win.Open("PopCountryShop")
end

function _w.ClickDuty()
    Win.Open("PopAllyMember")
end

function _w.ClickChange()
    Win.Open("PopSelectCountry")
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _countryIndex = nil
        _info = nil
        _techTag = nil
        _peerTag = nil
        _countryIndex = nil
        _changeCountry = nil
        --package.loaded["Game.WinCountry"] = nil
    end
end

---<summary>
---国家
---</summary>
WinCountry = _w