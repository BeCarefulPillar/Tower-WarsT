local EnInt = QYBattle.EnInt

local _w = { }
PopBattleSelect = _w

local _body = nil
local _ref = nil

local _battle = nil
local _hero = nil
local _items = nil
local _selectFrame = nil
local _select = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
end

local function Active()
    return _body.activeSelf
end

function _w.OnInit()
    if type(_w.initObj) == "table" then
        _hero = _w.initObj[1]
        local winBattle = Win.GetOpenWin("WinBattle")
        if winBattle and _hero and _hero.sn > 0 then
            _battle = winBattle.Data
            _view = type(_w.initObj[2]) == "number" and _w.initObj[2] or 0

            local enemySN = 0
            local dataSN = nil
            local hd = user.GetHero(_hero.sn)
            if not hd then
                return
            end

            if _view == 1 then
                --选择阵形
                _ref.title.text = L("选择阵形")
                dataSN = hd.lnpLst
                local enemyHeroData = _battle:isPvpFight() and nil or _battle:GetDefHero(_battle:defFightHeroIdx())
                if enemyHeroData then
                    enemySN = enemyHeroData.lnp.value
                end
            elseif _view == 2 then
                --选择兵种
                _ref.title.text = L("选择军兵种")
                dataSN = hd.armLst
                local enemyHeroData = _battle:isPvpFight() and nil or _battle:GetDefHero(_battle:defFightHeroIdx())
                if enemyHeroData then
                    enemySN = enemyHeroData.arm.value
                end
            end

            local len = #dataSN
            if len <= 0 then
                return
            end

            _items = { }
            local ownTag = -1
            for i = 1, len do
                local item = _ref.scrollView:AddChild(_ref.item_battle_select, string.format("item_%02d", i))
                local utx = item:GetComponentInChildren(typeof(UITexture))
                local nameLab = item:ChildWidget("name")
                local lvLab = item:ChildWidget("lv")
                local bwc = nameLab.gameObject
                item.luaBtn.luaContainer = _body

                local dt = nil

                if _view == 1 then
                    --选择阵形
                    local lu = DB.GetLnp(dataSN[i])
                    dt = lu

                    item.luaBtn.param = lu
                    nameLab.text = lu.nm
                    local imp = hd:GetLnpImpQty(lu.sn)
                    lvLab.text = imp > 0 and "+" .. imp or ""
                    if enemySN > 0 then
                        for j, u in ipairs(lu.sup) do
                            if u == enemySN then
                                EF.BindWidgetColor(bwc, Color.green)
                                break
                            end
                        end
                        --if EF.GetDefBindWidgetColor(bwc) ~= Color.green then
                        local t = DB.GetLnp(enemySN).sup
                        for j, u in ipairs(t) do
                            if u == lu.sn then
                                EF.BindWidgetColor(bwc, Color.red)
                                break
                            end
                        end
                        --end
                    end
                    utx:LoadTexAsync(ResName.LineupIcon(lu.sn))
                    if lu.sn == _hero.lnp.value then
                        ownTag = i
                    end

                elseif _view == 2 then
                    --选择兵种
                    local so = DB.GetArm(dataSN[i])
                    dt = so
                    item.luaBtn.param = so
                    nameLab.text = so.nm
                    lvLab.text = "Lv:" .. hd:GetArmLv(so.sn)
                    if enemySN > 0 then
                        for j, u in ipairs(so.sup) do
                            if u == enemySN then
                                EF.BindWidgetColor(bwc, Color.green)
                                break
                            end
                        end
                        --if EF.GetDefBindWidgetColor(bwc) ~= Color.green then
                        local t = DB.GetArm(enemySN).sup
                        for j, u in ipairs(t) do
                            if u == so.sn then
                                EF.BindWidgetColor(bwc, Color.red)
                                break
                            end
                        end
                        --end
                    end
                    utx:LoadTexAsync(ResName.SoldierIcon(so.sn))
                    if so.sn == _hero.arm.value then
                        ownTag = i
                    end
                end

                table.insert(_items, { go = item, d = dt })
            end

            ownTag = math.clamp(ownTag, 0, len)
            _w.ClickItem(_items[ownTag].go.luaBtn, _items[ownTag].d)

            if Active() then
                _ref.scrollView:GetCmp(typeof(UIGrid)):Reposition()
            else
                _ref.scrollView:GetCmp(typeof(UIGrid)).repositionNow = true
            end

            return
        end
    end
    Destroy(_body.gameObject)
end

function _w.OnDispose()
    _ref.lineupImprint:SetActive(false)
    _ref.soldierBuff:SetActive(false)
    _ref.title.text = ""
    _ref.info.text = ""
    _hero = nil
    _select = nil

    if notnull(_selectFrame) then
        Destroy(_selectFrame.cachedGameObject)
    end
    _selectFrame = nil

    if _items then
        for i, v in ipairs(_items) do
            if notnull(v.go) then
                Destroy(v.go)
            end
        end
        _items = nil
    end
end

local function LoadLineupImprint(imp)
    local marks = DB.GetLnpImpMarks()
    local l = math.ceil(#marks * 0.5)

    local lstr = ""
    local rstr = ""

    for i = 1, l do
        lstr = lstr ..(i == 1 and "" or "\n") .. DB.GetAttWordKV(marks[i], imp[marks[i]])
    end
    for i = l + 1, #marks do
        rstr = rstr ..(i == l + 1 and "" or "\n") .. DB.GetAttWordKV(marks[i], imp[marks[i]])
    end

    _ref.lineupImprintL.text = lstr
    _ref.lineupImprintR.text = rstr
end

function _w.ClickItem(btn, dt)
    if _select == dt then
        return
    end

    local go = btn
    local p = dt

    if isnull(_selectFrame) then
        _selectFrame = go:AddWidget(typeof(UISprite), "select_frame")
        _selectFrame.atlas = AM.mainAtlas
        _selectFrame.type = UIBasicSprite.Type.Sliced
        _selectFrame.spriteName = "frame_selected"
        _selectFrame.depth = 6
        _selectFrame.width = 118
        _selectFrame.height = 118
    else
        _selectFrame.transform.parent = go.transform
    end

    _selectFrame.cachedTransform.localScale = Vector3(1, 1, 1)
    _selectFrame.cachedTransform.localPosition = Vector3(0, 0, 0)

    _ref.lineupImprint:SetActive(false)

    _ref.info.text = ""

    if objt(p) == DB_SKT then
        --技能
        _select = p
        _ref.info.text = L("选择:") .. _select.nm .. L("\n说明:") .. _select.i

    elseif objt(p) == DB_Lnp then
        --阵形
        _select = p
        local lu = _select
        local text = L("选择：") .. lu.nm .. L("\n克制：")
        if lu.sup and #lu.sup > 0 then
            for i, v in ipairs(lu.sup) do
                text = text .. DB.GetLnp(v).nm .. " "
            end
            text = string.sub(text, 1, #text - 1)
        end
        --被克阵型数据
        text = text .. L("\n被克：")
        local ls = DB.AllLnp()
        for i, v in ipairs(ls) do
            if v and v.sup then
                for j, u in ipairs(v.sup) do
                    if u == lu.sn then
                        text = text .. v.nm .. " "
                        break
                    end
                end
            end
        end
        text = string.sub(text, 1, #text - 1)
        _ref.info.text = text

        --铭刻属性
        local hd = user.GetHero(_hero.sn)
        if hd and hd:LnpAvailable(lu.sn) and hd.lv >= DB.unlock.lnpImp then
            _ref.lineupImprint.text = lu.nm
            hd:GetLnpImp(lu.sn, LoadLineupImprint)
            _ref.lineupImprint:SetActive(true)
        end

    elseif objt(p) == DB_Arm then
        --兵种
        _select = p
        local so = _select
        local text = L("选择：") .. so.nm .. L("\n克制：")
        if so.sup and #so.sup > 0 then
            for i, v in ipairs(so.sup) do
                if v <= 6 and v >= 1 then
                    text = text .. DB.GetArm(v).nm .. " "
                end
            end
            text = string.sub(text, 0, #text - 1)
        end
        text = text .. L("\n被克：")
        local ss = DB.AllArm()
        for i, v in ipairs(ss) do
            if v and v.sup and v.sn <= 6 then
                for j, u in ipairs(v.sup) do
                    if u == so.sn then
                        text = text .. v.nm .. " "
                        break
                    end
                end
            end
        end
        text = string.sub(text, 0, #text - 1)
        _ref.info.text = text

        --兵种Buff特性
        local hd = user.GetHero(_hero.sn)
        local solBuff = DB.Get("soldier_buff")
        local soLv = PY_Hero.GetArmLv(hd, so.sn)
        _ref.soldierBuff.text = L("特性：") .. string.format("%s+%0.2f%%", solBuff[so.sn].ty, solBuff[so.sn].vals[soLv] * 0.01)
        _ref.soldierBuff:SetActive(true)
    end
end

function _w.ClickSure()
    if not _select then
        return
    end

    local hd = user.GetHero(_hero.sn)
    local tp = objt(_select)
    if tp == DB_SKT then
        --技能
    elseif tp == DB_Lnp then
        --阵形
        local sn = _select.sn
        if sn == _hero.lnp.value then
            _body:Exit()
            return
        end
        SVR.UseLineup(_hero.sn, sn, function(t)
            if t.success then
                _hero.lnp = EnInt(sn)
                local win = Win.GetOpenWin("WinBattle")
                if win then
                    win.RefreshInfo()
                end
                ToolTip.ShowPopTip(string.format(L("%s的阵形更换为[%s]"),
                ColorStyle.Blue(hd.db:GetEvoName(hd.evo)), ColorStyle.Blue(DB.GetLnp(sn).nm)))
                _body:Exit()
            end
        end )

    elseif tp == DB_Arm then
        --兵种
        local sn = _select.sn
        if sn == _hero.arm.value then
            _body:Exit()
            return
        end

        SVR.UseArm(_hero.sn, sn, function(t)
            if t.success then
                _hero.arm = EnInt(sn)
                local win = Win.GetOpenWin("WinBattle")
                if win then
                    win.RefreshInfo()
                end
                ToolTip.ShowPopTip(string.format(L("%s的士兵更换为[%s]"),
                ColorStyle.Blue(hd.db:GetEvoName(hd.evo)), ColorStyle.Blue(DB.GetArm(sn).nm)))
                _body:Exit()
            end
        end )
    end
end

--[Comment]
--快速配置（只有被克制和相同的才会进来）
function _w.FastSet(atkHero)
    if type(atkHero) == "table" then
        local hero = atkHero[1]
        local winBattle = Win.GetOpenWin("WinBattle")
        if winBattle and hero and hero.sn then
            local battle = winBattle.Data
            local view = atkHero[2]

            local enemySN = 0
            local dataSN = { }
            local hd = user.GetHero(hero.sn)
            if not hd then
                return
            end

            if view == 1 then
                --选择阵形
                dataSN = hd.lnpLst
                local enemyHeroData = battle:isPvpFight() and nil or battle:GetDefHero(battle:defFightHeroIdx())
                if enemyHeroData then
                    enemySN = enemyHeroData.lnp.value
                end
            elseif view == 2 then
                --选择兵种
                dataSN = hd.armLst
                local enemyHeroData = battle:isPvpFight() and nil or battle:GetDefHero(battle:defFightHeroIdx())
                if enemyHeroData then
                    enemySN = enemyHeroData.arm.value
                end
            end

            local len = #dataSN
            if len <= 0 then
                return
            end
            --最后得到的sn就是要选择的阵型或兵种
            local sn = -1
            if view == 1 then
                sn = hero.lnp.value
            elseif view == 2 then
                sn = hero.arm.value
            end

            --得到最大的级数
            local maxLevel = -1
            for i = 1, len do
                --兵种或阵型是否是被克  1克制 -1被克制 0相等
                local res = 0
                if view == 1 then
                    --选择阵形
                    local lu = DB.GetLnp(dataSN[i])
                    local elu = DB.GetLnp(enemySN)
                    local imp = PY_Hero.GetLnpImpQty(hd, lu.sn)
                    if enemySN > 0 then
                        --克制的阵型
                        for _, r in ipairs(lu.sup) do
                            if r == enemySN then
                                maxLevel = imp
                                sn = lu.sn
                                res = 1
                                break
                            end
                        end
                        if res == 1 then
                            break
                        end
                        if res == 0 then
                            for _, r in ipairs(elu.sup) do
                                if r == lu.sn then
                                    res = -1
                                end
                            end
                        end
                        if res == 0 then
                            maxLevel = imp
                            sn = lu.sn
                        end
                    end
                elseif view == 2 then
                    --选择兵种
                    local so = DB.GetArm(dataSN[i])
                    local eso = DB.GetArm(enemySN)
                    local soLevel = PY_Hero.GetArmLv(hd, so.sn)
                    if enemySN > 0 then
                        for _, r in ipairs(so.sup) do
                            if r == enemySN then
                                maxLevel = soLevel
                                sn = so.sn
                                res = 1
                                break
                            end
                        end
                        if res == 1 then
                            break
                        end
                        if res == 0 then
                            for _, r in ipairs(eso.sup) do
                                if r == so.sn then
                                    res = -1
                                end
                            end
                        end
                        if res == 0 then
                            maxLevel = soLevel
                            sn = so.sn
                        end
                    end
                end
            end

            --更换阵型和兵种
            if view == 1 then
                if sn == hero.lnp.value or maxLevel == -1 then
                    return
                end
                SVR.UseLineup(hero.sn, sn, function(t)
                    if t.success then
                        hero.lnp = EnInt(sn)
                        local win = Win.GetOpenWin("WinBattle")
                        if win then
                            win.RefreshInfo()
                        end
                        ToolTip.ShowPopTip(string.format(L("%s的阵形更换为[%s]"),
                        ColorStyle.Blue(hd.db:GetEvoName(hd.evo)), ColorStyle.Blue(DB.GetLnp(sn).nm)))
                        _body:Exit()
                    end
                end )
            elseif view == 2 then
                if sn == hero.arm.value or maxLevel == -1 then
                    return
                end
                SVR.UseArm(hero.sn, sn, function(t)
                    if t.success then
                        hero.arm = EnInt(sn)
                        local win = Win.GetOpenWin("WinBattle")
                        if win then
                            win.RefreshInfo()
                        end
                        ToolTip.ShowPopTip(string.format(L("%s的士兵更换为[%s]"),
                        ColorStyle.Blue(hd.db:GetEvoName(hd.evo)), ColorStyle.Blue(DB.GetArm(sn).nm)))
                        _body:Exit()
                    end
                end )
            end
        end
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _battle = nil
        _hero = nil
        _items = nil
        _selectFrame = nil
        _select = nil
    end
end