local _w = { }

local _body = nil
local _ref = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
end

local function UpdateInfo()
    local cur = user.Title
    _ref.peerage.text = cur.nm

    local cm = user.merit - cur.merit

    if user.ttl < DB.maxTtl then
        local next = DB.GetTtl(user.ttl + 1)
        local n = next.merit - cur.merit
        _ref.meritPro.value = cm / n
        _ref.meritLab1.text = tostring(cm)
        _ref.meritLab2.text = "/" .. tostring(n)
        if cm < n then
            _ref.meritTip.text =
            string.format(L("再获得[00FF00]%d[-]功勋，可晋升[00FF00]%s[-]"), n - cm, next.nm)
            _ref.btnUp.isEnabled = false
        else
            _ref.meritTip.text =
            string.format(L("可晋升为[00FF00]%s[-]"), next.nm)
            _ref.meritLip.text =
            string.format(L("可晋升为[00FF00]%s[-]"), next.nm)
            _ref.btnUp.isEnabled = true
        end
    else
        _ref.meritPro.value = 1
        _ref.meritLab1.text = " "
        _ref.meritLab2.text = tostring(cm)
        _ref.meritTip.text = L("您已是至高爵位")
        _ref.meritLip.text = L("您已是至高爵位")
        _ref.btnUp.isEnabled = false
    end

    _ref.infos[1].text = cur.nm .. L("特权")
    _ref.infos[2].text = L("国战出战位：") .. "[00FF00]" .. cur.lead .. "[-]"
    _ref.infos[3].text = L("粮草上限：") .. "[00FF00]" .. cur.food .. "[-]"
    _ref.infos[4].text = L("每日钻石征粮次数：") .. "[00FF00]" .. cur.fqty .. "[-]"
end

function _w.OnInit()
    _ref.lables[1].text = L("爵位")
    _ref.lables[2].text = L("爵位特权")
    _ref.lables[3].text = L("晋 升")
    _ref.playerName.text = user.nick
    _ref.icon:LoadTexAsync(ResName.PlayerIcon(user.ava))
    UpdateInfo()
    SVR.UpdateUserInfo()
end

function _w.Refresh()
    SVR.UpdateUserInfo()
end

function _w.OnEnter()
    UserDataChange:Add(UpdateInfo)
end

function _w.OnExit()
    UserDataChange:Remove(UpdateInfo)
end

function _w.ClickUp()
    local prevHeroQty = user.Title.lead
    SVR.UserUpPeerage( function(t)
        if t.success then
            local ef = _body:AddChild(AM.LoadPrefab("ef_peerage_up"), "ef_peerage_up", false)
            if notnull(ef) then
                Destroy(ef, 2.5)
            end
            Invoke(UpdateInfo, 1.2)
            ToolTip.Mask(1.5)
            if user.Title.lead > prevHeroQty and MainUI then
                --CountryPanel cp = MainPanel.Instance.GetComponentInAllChild<CountryPanel>(false);
                --if (cp) cp.UpdateHero();
            end
        end
    end )
end

function _w.Help()
    Win.Open("PopRule", DB_Rule.Peerage)
end

function _w.OnDispose()
    _ref.icon:UnLoadTex()
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        --package.loaded["Game.PopPeerage"] = nil
    end
end

---<summary>
---爵位
---</summary>
PopPeerage = _w