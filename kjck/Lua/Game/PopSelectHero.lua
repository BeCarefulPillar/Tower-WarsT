local _w = { }


local _body = nil
local _ref = nil

local _gridHeros = nil
local _arrow = nil
local _btnSure = nil
local _autoFatig = nil
local _btnAutoFatig = nil
local _atd = nil
local _btnjs = nil
local _jsSkillInfo = nil
local _selectBg = nil
local _panelSetJS = nil
local _gridHeroJS = nil
local _item_heroJS = nil
local _btnCloseJS = nil
local _ef_appear = nil
local _ef_click = nil
local _mask = nil
local _labTtl = nil

local _btnTabs = nil
local _slts = nil

    
local _pur = nil
local _citySN = nil
local _sort = nil

--[Comment]
--国战其他操作里用来检查将领是否在队列
local _check = false

--[Comment]
--将领选择目的
SelectHeroFor =
{
    None = 0,
    --[Comment]
    --PVE推图
    Pve = 1,
    --[Comment]
    --战役
    War = 2,
    --[Comment]
    --争霸战斗
    Pvp = 3,
    --[Comment]
    --副本
    Histroy = 4,
    --[Comment]
    --演武榜，选择驻守将领
    Rank = 5,
    --[Comment]
    --BOSS战
    Boss = 6,
    --[Comment]
    --过关斩将
    Tower = 7,
    --[Comment]
    --经验塔
    Exp = 8,
    --[Comment]
    --争霸驻守
    PvpGuard = 9,

    --[Comment]
    --国战选人
    Nat = 10,
    --[Comment]
    --国战其它操作
    NatOption = 11,
    --[Comment]
    --国战移动
    NatMove = 12,
    --[Comment]
    --乱世争雄
    ClanWar = 13,
    --[Comment]
    --联盟战
    AllyBattle = 14,
    --[Comment]
    --矿脉战
    Mine = 15,
    --[Comment]
    --跨服国战选人
    Snat = 16,
    --[Comment]
    --跨服国战其它操作
    SnatOption = 17,
    --[Comment]
    --跨服国战移动
    SnatMove = 18,
    --[Comment]
    --保存
    Save = 19,
    --[Comment]
    --演武榜，选择战斗将领
    RankForFight = 20,
    --[Comment]
    --借将
    BorrowHero = 21,
    --[Comment]
    --地宫探险
    GVE = 22,
    --[Comment]
    --地宫将领移动
    GveMove = 23,
}

local SelectHeroFor = SelectHeroFor
local defSortFunc = PY_Hero.Compare
local _sortFunc = 
{
    -- 将领排序
    --等级
    [1] = function(x, y)
        if x.lv > y.lv then return true end
        if x.lv < y.lv then return false end
        if x.rare > y.rare then return true end
        if x.rare < y.rare then return false end
        if x.ttl > y.ttl then return true end
        if x.ttl < y.ttl then return false end
    end,
    --官阶
    [2] = function(x, y)
        if x.ttl > y.ttl then return true end
        if x.ttl < y.ttl then return false end
        if x.lv > y.lv then return true end
        if x.lv < y.lv then return false end
        if x.rare > y.rare then return true end
        if x.rare < y.rare then return false end
    end,
    --武力
    [3] = function(x, y)
        local xv, yv = x.str, y.str
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --智力
    [4] = function(x, y)
        local xv, yv = x.wis, y.wis
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --统帅
    [5] = function(x, y)
        local xv, yv = x.cap, y.cap
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --生命
    [6] = function(x, y)
        local xv, yv = x.MaxHP, y.MaxHP
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --技力
    [7] = function(x, y)
        local xv, yv = x.MaxSP, y.MaxSP
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --兵力
    [8] = function(x, y)
        local xv, yv = x.MaxTP, y.MaxTP
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
    --国家
    [9] = function(x, y)
        local xv, yv = x.clan, y.clan
        if xv > yv then return true end
        if xv < yv then return false end
        return defSortFunc(x, y)
    end,
--    --位置
--    [10] = function(x, y)
--        local xv, yv = x.loc, y.loc
--        if xv > yv then return true end
--        if xv < yv then return false end
--        return defSortFunc(x, y)
--    end,
    [11] = function(x, y)
        local xb, yb = x.borrow, y.borrow
        if xb < yb then return true end
        if xb > yb then return false end
        return defSortFunc(x, y)
    end,

}
--[Comment]
--排序方法
_w.sortFunc = _sortFunc

--模块
local _mod = { }

local function MoveHero(movs, exps, ism)
    if _onSlted ~= nil then
        if #movs > 0 then
            local city = user.gmMaxCity
            SVR.MoveHero(movs, city, 1, function (r) if r.success then
                local hd = nil
                for i = 1, #movs do
                    hd = user.GetHero(movs[i])
                    if hd ~= nil then hd.loc = city end
                end
                _onSlted(exps)
                if ism then _w.ClickClose()
                else _body:Exit() end
            end end)
            return
        else _onSlted(exps)
        end
    end
    if ism and _pur ~= SelectHeroFor.Exp then _w.ClickClose()
    else _body:Exit() end
end

--用tag进行判断是否进行选择了将领    HeroSelected：已选择   Untagged：未选择
local function SetSltHero(lb, data)
    if not lb then return end
    local tl = lb:GetCmpInChilds(typeof(UITextureLoader))
    if data == nil then
        lb.gameObject.tag = "Untagged"
        lb.text = ""
        lb.param = nil
        tl:Dispose()
    else
        lb.gameObject.tag = "HeroSelected"
        lb.text = data:getName()
        lb.param = data
        tl:Load(ResName.HeroIcon(data.db.img))
    end
    return tl
end

local function CheckSltHero(idx, pur)
    local lb = _slts[idx]
    lb.param = nil
    lb.gameObject.tag = "Untagged"
    local lock = lb.gameObject:Child("sp_lock")
    if _mod[pur].checkNum(idx) == true then
        lb.text = ""
        lb.label.gameObject:SetActive(false)
        lb.gameObject:SetActive(true)
        lb:GetCmp(typeof(UISprite)).spriteName = "frame_12"
        lock:SetActive(false)
        return true
    else 
        lb:GetCmp(typeof(UISprite)).spriteName = "frane_expedition_lock"
        lb.label.gameObject:SetActive(true)
        lock:SetActive(true)
    end
    return false
end

local function CheckSelected()
    local s = 0
    for i = 1, #_slts do if _slts[i].gameObject.tag == "HeroSelected" then s = s + 1 end end
    _atd:CheckBelong()
    _btnSure.isEnabled = s > 0
    if _atd.CurSelect ~= nil and _atd.CurSelect >= 0 then
        _jsSkillInfo.text = DB.GetSkt(_slts[_atd.CurSelect + 1].param.db.skt).i
        _atd.transform.parent = _slts[_atd.CurSelect + 1].transform
        _atd.transform.localPosition = Vector3(0, -26, 0);
        _atd.transform.localScale = Vector3.one
    else
        _jsSkillInfo.text = ""
    end
    return s
end


--region -------------- 默认模块 --------------
local _defMod =
{
    --[Comment]
    --是否需要军师
    hasAdv = false,
    --[Comment]
    --是否会将将领移动到新的位置
    isMove = false,
    --[Comment]
    --是否有按钮
    isSure = false,
    --[Comment]
    --是否自动补酒
    isAuto = false,

    onInit = function ()
        _labTtl.text = L("选择将领")
        _heros = _citySN > 0 and user.GetCityHero(_citySN) or user.GetHeros()
        _btnSure.text = L("出 击")
        if _initHeros == nil or #_initHeros <= 0 then _initHeros = user.LastBattleHero end
        if _initHeros ~= nil and #_initHeros > 0 and _citySN >= 0 then
            local h = nil
            for i = 1, #_initHeros do
                h = _initHeros[i]
                if h ~= nil and ((_citySN > 0 and h.loc ~= _citySN) or h.InPvpCity) then _initHeros[i] = nil end
            end
        end
        return true
    end,

    checkNum = function (idx)
        local lv = user.MaxBattleHero
        if idx <= lv then return true end
        local cnt = 0
        for lv = user.hlv , DB.maxHlv - 1 do
            cnt = DB.GetHome(lv).lead
            if idx <= cnt then break end
            _slts[idx].text = string.format(L("主城%d级解锁"), lv + 1)
        end
        _slts[idx].gameObject:SetActive(idx <= cnt)
        return false
    end,

    onInitItem = function (go, dat)
        go = ItemHero(go)
        go:Init(dat, _pur)
        return go
    end,

    onSlt = function (it)
        if it.Selected then return true
        else return CheckSelected() < user.MaxBattleHero end
    end,

    onClose = function () Win.ShowMainPanel() end,
}
_defMod.meta = { __index = _defMod }
--endregion

--region -------------- PVE推图 --------------  现在去除了  血兵忠
_mod[SelectHeroFor.Pve] = setmetatable(
{
    hasAdv = true,
    isSure = true,
    isAuto = false,

    onSure = function ()
        local exps = { }
        local movs = { }
        local ism = _pur == SelectHeroFor.Pvp or SelectHeroFor.PvpGuard
        local dat = _slts[_atd.CurSelect + 1]
        if dat and dat.gameObject.tag == "HeroSelected" then table.insert(exps, dat.param.sn) end
        for i = 1, #_slts do
            if _slts[i].gameObject.tag == "HeroSelected" then
                if _slts[i] ~= dat and not table.contains(exps, _slts[i].param.sn) then table.insert(exps, _slts[i].param.sn) end
                if ism and _slts[i].param.IsPvpCity and not not table.contains(movs, _slts[i].param.sn) then table.insert(movs, _slts[i].param.sn) end
            end
        end
        MoveHero(movs, exps, ism)
    end,

}, _defMod.meta)
--endregion

--region -------------- 战役 --------------
_mod[SelectHeroFor.War] = setmetatable(
{
    hasAdv = true,
    isSure = true,
    isAuto = false,
    onSure = _mod[SelectHeroFor.Pve].onSure,
}, _defMod.meta)
--endregion

--region -------------- 争霸战斗 --------------
_mod[SelectHeroFor.Pvp] = setmetatable(
{
    hasAdv = true,
    isMove = true,
    isSure = true,
    isAuto = false,
    onSure = function ()
        local exps = { }
        local movs = { }
        local ism = _pur == SelectHeroFor.Pvp or SelectHeroFor.PvpGuard
        local dat = _slts[_atd.CurSelect + 1]
        if dat and dat.gameObject.tag == "HeroSelected" then table.insert(exps, dat.param.sn) end

        for i = 1, #_slts do
            if _slts[i].gameObject.tag == "HeroSelected" then
                if _slts[i] ~= dat and not table.contains(exps, _slts[i].param.sn) then table.insert(exps, _slts[i].param.sn) end
                if ism and _slts[i].param.IsPvpCity and not not table.contains(movs, _slts[i].param.sn) then table.insert(movs, _slts[i].param.sn) end
            end
        end
        MoveHero(movs, exps, ism)
    end,
}, _defMod.meta)
--endregion

--region -------------- 副本 --------------
_mod[SelectHeroFor.Histroy] = setmetatable(
{
    hasAdv = true,
    isSure = true,
    isAuto = false,
    onSure = _mod[SelectHeroFor.Pve].onSure,
}, _defMod.meta)
--endregion

--region -------------- 演武榜 --------------
_mod[SelectHeroFor.Rank] = setmetatable(
{
    hasAdv = true,
    isSure = true,
    isAuto = false,
    onInit = function ()
        _citySN = -1 --DB.specialCity.rank
        _labTtl.text = L("驻守将领")
        _heros = user.GetHeros()
        _btnSure.text = L("驻守")
        return true
    end,
    onSure = _mod[SelectHeroFor.Pvp].onSure,
}, _defMod.meta)
--endregion

--region -------------- BOSS战 --------------
_mod[SelectHeroFor.Boss] = setmetatable(
{
    hasAdv = true,
    isSure = true,
    isAuto = false,

    onInit = function ()
        --_citySN = DB.specialCity.boss
        _labTtl.text = L("选择将领")
        _heros = user.GetHeros()
        _btnSure.text = L("布 阵")
        return true
    end,

    onSlt = function (it)
        if it.Selected then return true
        else return CheckSelected() < 5 end
    end,

    onSure = _mod[SelectHeroFor.Pvp].onSure,

    onClose = function()
        _body:Exit()
    end,

}, _defMod.meta)
--endregion

--region -------------- 过关斩将 --------------
_mod[SelectHeroFor.Tower] = setmetatable(
{
    hasAdv = true,
    isSure = true,
    isAuto = false,

    onInit = function ()
        --_citySN = DB.specialCity.tower

        _labTtl.text = L("选择将领")

        if #user.towerInfo.hero>0 then
            --部署
            _heros = user.TowerBattleHero
            _btnSure.text = L("挑 战")
            _btnjs:SetActive(true)
        else
            --挑战
            _heros = user.GetHeros(function(h)
                return h and h.CanJoinTower
            end)
            _btnSure.text = L("部 署")
            _btnjs:SetActive(false)
        end

        if #_heros > 0 then
            --[[
            _initHeros = user.TowerBattleHero
            for i = 1, #_initHeros do
                if _initHeros[i] == nil or _initHeros[i].CanFightTower then _initHeros = nil end
            end
            ]]
        else
            ToolTip.ShowPopTip(
                string.format(L("挑战决斗将需要%d星且%d级及以上的武将"), 
                    DB.param.towerHeroRare, DB.param.towerHeroLv))
        end
        return true
    end,

    onSure = _mod[SelectHeroFor.Pvp].onSure,

    onSlt = function (it)
        if it.Selected then return true
        else
            if it.IsTowerDead then
                ToolTip.ShowPopTip(ColorStyle.Blue(it.hero:getName())..ColorStyle.Bad("已战败"))
                return false
            elseif it.hero.db.rare < DB.param.towerHeroRare then
                ToolTip.ShowPopTip(string.format(L("%s的星级小于%s"), ColorStyle.Blue(it.hero:getName()), ColorStyle.Bad(tostring(DB.param.towerHeroRare))))
                return false
            elseif it.hero.lv < DB.param.towerHeroLv then
                ToolTip.ShowPopTip(string.format(L("%s的等级小于%s"), ColorStyle.Blue(it.hero:getName()), ColorStyle.Bad(tostring(DB.param.towerHeroLv))))
                return false
            end
            return true
        end
    end,

    onClose = function()
        _body:Exit()
    end,

}, _defMod.meta)
--endregion

--region -------------- 经验塔 --------------
_mod[SelectHeroFor.Exp] = setmetatable(
{
    hasAdv = false,
    isSure = true,
    isAuto = false,

    onInit = function ()
--        _citySN = DB.specialCity.exp
        _labTtl.text = L("选择将领")
        _heros = user.GetHeros()
        _btnSure.text = L("训练")
        return true
    end,

    checkNum = function (idx)
        local lv = user.MaxTrainHero
        if idx <= lv then return true end
        local cnt = 0
        for lv = user.vip + 1, DB.maxVip - 1 do
            cnt = DB.GetVip(lv).heroQty
            if idx <= cnt then break end
            _slts[idx].text = string.format(L("VIP%d开启"), lv)
        end
        _slts[idx].gameObject:SetActive(idx <= lv)
        return false
    end,

    onSure = _mod[SelectHeroFor.Pvp].onSure,

    onSlt = function (it)
        if it.Selected then return true
        else
            if CheckSelected() >= user.MaxTrainHero then return false end
            if it.hero.IsMaxLv then
                ToolTip.ShowPopTip(ColorStyle.Blue(it.hero:getName())..L("已升至最高级"))
                return false
            end
            if it.hero.IsLvLmt then
                MsgBox.Show(ColorStyle.Blue(it.hero:getName())..L("已达当前主城等级上限"), L("升级主城")..","..L("返回"), function (bsn) if bsn == 0 then Win.Open("PopHome") end end)
                return false
            end
            return true
        end
    end,

    onClose = function () _body:Exit() end,
}, _defMod.meta)
--endregion

--region -------------- 争霸驻守 --------------
_mod[SelectHeroFor.PvpGuard] = setmetatable(
{
    isMove = true,
    isSure = true,
    isAuto = false,

    onInit = function ()
        if not PY_PvpCity.IsPvpCity(_citySN) then
            Destroy(_body.gameObject)
            return false
        end
        _labTtl.text = L("驻守将领")
        _heros = user.GetHeros()
        _initHeros = user.GetHeros(function (h) return h.loc == _citySN end)
        _btnSure.text = L("驻守")
        return true
    end,

    onSure = function ()
        local sns = { }
        local chs = user.GetCityHero(_citySN)
        local city = user.GetPvpCity(_citySN)
        local pve = Mathf.Max(1, user.gmMaxCity)
        local qty = #chs

        for i = 1, _slts do
            if _slts[i].gameObject.tag == "HeroSelected" then table.insert(sns, _slts[i].param.sn) end
        end

        if #sns > 0 then
            SVR.MoveHero(sns, _citySN, 2, function (r) if r.success then
                for i = 1, qty do if chs[i] ~= nil then chs[i].loc = pve end end
                local h = nil
                for i = 1, #sns do
                    h = user.GetHero(sns[i])
                    if h then h.loc = _citySN end
                end
            end _body:Exit() end)
        else
            SVR.MoveHero(nil, _citySN, 2, function (r) if r.success then
                if city ~= nil then city:LeaveFromColony() end
            end _body:Exit() end)
        end
    end,
}, _defMod.meta)
--endregion

--region -------------- 国战选人 --------------
_mod[SelectHeroFor.Nat] = setmetatable(
{
    isSure = true,
    isAuto = true,

    onInit = function ()
        _labTtl.text = L("部署国战将领")
        _heros = user.GetHeros()
        local hasHero = user.nat.heros
        for i = 1, #hasHero do _initHeros[i] = user.GetHero(hasHero[i].sn) end
        _btnSure.text = L("部署")
        return true
    end,

    checkNum = function (idx)
        local lv = user.MaxNatHero
        if idx <= lv then return true end
        local cnt = 0
        for lv = user.ttl + 1, DB.maxTtl - 1 do
            cnt = DB.GetTtl(lv).lead
            if idx <= cnt then break end
            _slts[idx].text = string.format(L("晋升%s解锁"), DB.GetTtl(lv).nm)
        end
--        _slts[idx].gameObject:SetActive(idx <= lv)
        _slts[idx].gameObject:SetActive(true)
        return false
    end,

    onExit = function ()
        local sns = { }
        for i = 1, #_slts do
            if _slts[i].gameObject.tag == "HeroSelected" then
                table.insert(sns, _slts[i].param.sn)
            end
        end
        local isc = #user.nat.heros ~= #sns
        if not isc then
            for i = 1, #sns do
                if user.nat:GetHero(sns[i]) == nil then isc = true break end
            end
        end
        if isc then SVR.NatSetHero(sns) end
    end,

    onSlt = function (it)
        if it.Selected then
            local dat = user.nat:GetHero(it.hero.sn)
            if dat ~= nil then
                if not dat.InCapital or dat.CurStatus == PY_NatHero.Status.Move then
                    ToolTip.ShowPopTip(ColorStyle.Blue(it.hero:getName())..L("不在都城！"))
                    return false
                end
            end
        else
            if CheckSelected() >= user.MaxNatHero then return false end
        end
        return true
    end,

    onUnSlt = function (h)
        local dat = user.nat:GetHero(h.sn)
        if dat ~= nil then
            if not dat.InCapital or dat.CurStatus == PY_NatHero.Status.Move then
                ToolTip.ShowPopTip("["..ColorStyle.Blue(it.hero:getName())..L("]不在都城！"))
                return false
            end
        end
        return true
    end,

     onSure = function ()
        local sns = { }
        local chs = user.GetCityHero(_citySN)
        local city = user.GetPvpCity(_citySN)
        local pve = Mathf.Max(1, user.gmMaxCity)
        local qty = #chs

        for i = 1, #_slts do
            if _slts[i].gameObject.tag == "HeroSelected" then table.insert(sns, _slts[i].param.sn) end
        end
        print("datdat   ",kjson.print(sns))
        if #sns > 0 then
            SVR.NatSetHero(sns, function (r) 
                if r.success then
                    print("66666666666666    ",kjson.print(SVR.datCache))
                end 
                _body:Exit() 
            end)
        end
    end,

}, _defMod.meta)
--endregion

--region -------------- 国战其它操作 --------------
_mod[SelectHeroFor.NatOption] = setmetatable(
{
    isSure = true,
    isAuto = true,


    onInit = function ()
        local hds = user.nat.heros
        if _citySN > 0 then
            local idx = _citySN
            for i = 1, #hds do
                if hds[i].city == idx then table.insert(_heros, user.GetHero(hds[i].sn)) end
            end
        else
            for i = 1, #hds do table.insert(_heros, user.GetHero(hds[i].sn)) end
        end
        _labTtl.text = L("选择将领")
        _btnSure.text = L("确定")
        return true
    end,

    checkNum = function (idx)
        local lv = 1
        if idx <= lv then return true end
        lv = 1
        _slts[idx].gameObject:SetActive(idx <= lv)
        return false
    end,

    onSure = function ()
        if _onSlted ~= nil then
            local sns = { }
            for i = 1, #_slts do
                if _slts[i].gameObject.tag == "HeroSelected" then table.insert(sns, _slts[i].param.sn) end
            end
            _onSlted(sns)
        end
        _body:Exit()
    end,

    onSlt = function (it)
        if it.Selected then return true
        else
            if _mod[SelectHeroFor.NatMove].onSlt(it) then
                if CheckSelected() >= 1 then
                    for i = 1, #_slts do SetSltHero(_slts[i], nil) end
                    for _, v in pairs(_items) do
                        if v then v.Selected = false end
                    end
                end
            else return false
            end
            return true
        end
    end,
}, _defMod.meta)
--endregion

--region -------------- 国战移动 --------------
_mod[SelectHeroFor.NatMove] = setmetatable(
{
    isSure = true,
    isAuto = true,

    onInit = _mod[SelectHeroFor.NatOption].onInit,

    onSure = _mod[SelectHeroFor.NatOption].onSure,

    onSlt = function (it)
        if it.Selected then return true
        else
            local dat = user.nat:GetHero(it.hero.sn)
            if dat ~= nil then
                dat = dat.CurStatus
                if dat == PY_NatHero.Status.Rest then
                    ToolTip.ShowPopTip(ColorStyle.Blue(it.hero:getName())..L("正在修整中！"))
                    return false
                elseif dat == PY_NatHero.Status.Move then
                    ToolTip.ShowPopTip(ColorStyle.Blue(it.hero:getName())..L("正在移动中！"))
                    return false
                elseif _citySN == 0 and dat == PY_NatHero.Status.Fight then
                    ToolTip.ShowPopTip(ColorStyle.Blue(it.hero:getName())..L("正在交战中！"))
                    return false
                end
                if _onCheckHero ~= nil and not _onCheckHero(it.hero) then return false end
                if _check then
                    return WinNatCity.CheckQueueHero(it.hero)
                end
                return true
            else 
                return false
            end
            return true
        end
    end,
}, _defMod.meta)
--endregion

--region -------------- 乱世争雄 --------------
_mod[SelectHeroFor.ClanWar] = setmetatable(
{
    hasAdv = true,
    isSure = true,
    isAuto = false,

    onInit = function ()
        local dat = DB.GetClanWar(_citySN)
        _heros = user.GetHeros(function (h) return h ~= nil and (dat.clan < 0 or h.db.clan == dat.clan) --[[and (dat.sex <= 0 or h.db.sex == dat.sex)]] and h.CanJoinClanWar end)
        --if dat.sex > 0 then
            --_initHeros = table.findall(user.GetClanWarSexHero(dat.sex), function (h) return h ~= nil and h.db.sex == dat.sex end)
        --else
            _initHeros = table.findall(user.GetClanWarHero(dat.clan), function (h) return h ~= nil and h.db.clan == dat.clan end)
        --end
        _labTtl.text = L("选择将领")
        _btnSure.text = L("出击")
        return true
    end,

    onSure = _mod[SelectHeroFor.Pve].onSure,
}, _defMod.meta)
--endregion

--region ---------------借将-------------------
_mod[SelectHeroFor.BorrowHero] = setmetatable(
{
    hasAdv = false,
    isSure = true,
    isAuto = false,

    onInit =  function()
        _labTtl.text = L("选择武将")
        _btnSure.text = L("借将")
        _heros = user.GetHeros(function(h) return h.borrow ~= 1 end)
        return true
    end,

    onSlt = function(it)
        if it.hero.borrow == 2 or it.hero.borrow == 3 then
            ToolTip.ShowPopTip(ColorStyle.Blue(it.hero.nm).. L("已被借出!"))
            return false
        end
        return true
    end,

    onSure = function ()
        if _onSlted ~= nil then
            local sns = { }
            for i = 1, #_slts do
                if _slts[i].gameObject.tag == "HeroSelected" then table.insert(sns, _slts[i].param.sn) end
            end
            _onSlted(sns)
        end
        _body:Exit()
    end,

}, _defMod.meta)
-----------------------------------------------
---------------------地宫  设置上阵武将-------------
_mod[SelectHeroFor.GVE] = setmetatable(
{
    hasAdv = false,
    isSure = true,
    isAuto = false,

    onInit =  function()
        _labTtl.text = L("选择武将")
        _btnSure.text = L("确定")
        _heros = user.GetHeros(function(h) return not table.contains(_slts, h) end)
        return true
    end,

    checkNum = function(idx)
        local lv = 3
        if idx <= lv then return true end
        return false
    end,

    onSlt = function (it)
        if it.Selected then return true
        else return CheckSelected() < 3 end
    end,

    onSure = function ()
        if _onSlted ~= nil then
            local sns = { }
            for i = 1, #_slts do
                if _slts[i].gameObject.tag == "HeroSelected" then table.insert(sns, _slts[i].param.sn) end
            end
            _onSlted(sns)
        end
        _body:Exit()
    end,
}, _defMod.meta)
---------------------------------------------------
---------------------地宫  选择武将出征-------------
_mod[SelectHeroFor.GveMove] = setmetatable(
{
    hasAdv = false,
    isSure = true,
    isAuto = false,

    onInit =  function()
        _labTtl.text = L("选择武将")
        _btnSure.text = L("确定")
        _heros = user.GetHeros(function(h) return table.contains(_initHeros, h) end)
        table.clear(_initHeros)
        return true
    end,

    checkNum = function(idx)
        local lv = 3
        if idx <= lv then return true end
        return false
    end,

    onSlt = function (it)
        if it.Selected then return true
        else return CheckSelected() < 3 end
    end,

    onSure = function ()
        if _onSlted ~= nil then
            local sns = { }
            for i = 1, #_slts do
                if _slts[i].gameObject.tag == "HeroSelected" then table.insert(sns, _slts[i].param.sn) end
            end
            _onSlted(sns)
        end
        _body:Exit()
    end,
}, _defMod.meta)
---------------------------------------------------

-- 武将排序
local function SortHero(s)
    s = s or 0
    if _sort == s then
        table.reverse(_heros)
        _arrow.localEulerAngles = _arrow.localEulerAngles * -1
        if _pur == SelectHeroFor.BorrowHero then table.sort(_heros, _sortFunc[11]) end
    else
        --排序
        table.sort(_heros, _sortFunc[s] or PY_Hero.Compare)
        _arrow.parent = _btnTabs[s + 1].transform
        _arrow.localPosition = Vector3(40, 0, 0)

        if _pur == SelectHeroFor.BorrowHero then table.sort(_heros, _sortFunc[11]) end
    end
    _sort = s
    _gridHeros:Reset()
    _gridHeros.realCount = #_heros
end

--region   -------------设置军师--------------
local _heroJS = nil
--[Comment]
--初始化军师界面
function OnInitSetJS()
    _panelSetJS:SetActive(true)
    local len = #_slts
    _heroJS = {}
    for i = 1 ,len  do
        if _slts[i].gameObject.tag == "HeroSelected" then
            local hd = _slts[i].param
            _heroJS[i] = _gridHeroJS.gameObject:AddChild(_item_heroJS,"js_"..i)
            local utxL = _heroJS[i]:GetCmpInChilds(typeof(UITextureLoader))
            utxL:Load(ResName.HeroImage(hd.db.img))
            --武将名字
            utxL.gameObject:ChildWidget("lab_name").text = hd:getName()
            --军师技名字
            local skt = DB.GetSkt(hd.db.skt)
            utxL.gameObject:ChildWidget("lab_js_name").text = skt.nm
            --军师技介绍
            utxL.gameObject:ChildWidget("lab_js_info").text = skt.i
            --军师角标
            local jSp = utxL.gameObject:ChildWidget("sp_js")
            if _atd.CurSelect ~= nil then
                if _atd.CurSelect + 1 == i then
                    jSp:SetActive(true)
                else
                    jSp:SetActive(false)
                end
            end
            utxL.gameObject.luaBtn.param = i
        end
    end
    _gridHeroJS.repositionNow = true;
    coroutine.start(ShowHero)
end

--[Comment]
--渐变的形式显示英雄
function ShowHero()
    for i = 1 ,#_heroJS do
        if _heroJS[i] ~= nil then
            _heroJS[i]:AddChild(_ef_appear)
            _heroJS[i]:SetActive(true)
            coroutine.wait(0.1)
        end
    end
    
end

--[Comment]
--卸载军师界面资源
function DisposeJS()
    _gridHeroJS:DesAllChild()
    _heroJS = nil
end
--endregion

local _bg= nil

function _w.OnLoad(c)
    _bg = WinBackground(c,{k = WinBackground.BG , n = L("选择将领")})
    _labTtl = _bg.Title
--    _labTtl = WinBackground.__get.Title(c)
    _body = c
    c:BindFunction("OnInit", "OnEnter", "OnExit", "OnWrapGridInitItem", "OnDispose", "OnUnLoad",
                    "ClickSortTab", "ClickItemHero", "ClickUnSelect", "ClickClose", "ClickSure",
                    "ClickBtnSetJs", "ClickCloseSetJS", "ClickSetJS")
    _ref = c.nsrf.ref

    _item = _ref.item_hero
    _gridHeros = _ref.gridHeros
    _arrow = _ref.arrow
    _btnSure = _ref.btnSure
    _autoFatig = _ref.autoFatig
    _btnAutoFatig = _ref.btnAutoFatig
    _atd = _ref.atd
    _btnjs = _ref.btnjs
    _jsSkillInfo = _ref.jsSkillInfo
    _selectBg = _ref.selectBg
    _panelSetJS = _ref.panelSetJS
    _gridHeroJS = _ref.gridHeroJS
    _item_heroJS = _ref.item_heroJS
    _btnCloseJS = _ref.btnCloseJS
    _ef_appear = _ref.ef_appear
    _ef_click = _ref.ef_click
    _mask = _ref.mask

    _btnTabs = _ref.btnTabs
    for i = 1 ,#_btnTabs do
        _btnTabs[i].param = i - 1
    end
    _slts = _ref.selectHeros
end

function _w.OnInit()
    _heros = { }
    _initHeros = { }
    _sort = -1
    _citySN = 0

    local temp = PopSelectHero.initObj
    if temp ~= nil then
        if isNumber(temp) then _pur = temp
        elseif isTable(temp) then
            for _, v in pairs(temp) do
                if isNumber(v) then
                    if _pur == nil then _pur = v
                    elseif _citySN == 0 then _citySN = v end
                elseif isFunction(v) and _onSlted == nil then _onSlted = v
                elseif isTable(v) and #_initHeros <= 0 then _initHeros = v
                elseif isBoolean(v) then _check = v 
                end
            end
        end
    end
    if _pur == nil or _pur == SelectHeroFor.None then
        Destroy(_body.gameObject)
        return
    end
    print(_pur)
    print(tts(_mod))
    temp = _mod[_pur]
    if not temp.onInit() then Destroy(_body.gameObject) return end
    _btnSure.gameObject:SetActive(temp.isSure)
    _autoFatig.gameObject:SetActive(temp.isAuto)
    _btnjs.gameObject:SetActive(temp.hasAdv)
    for i = 1, #_slts do
        if CheckSltHero(i, _pur) then
            if i <= #_initHeros then SetSltHero(_slts[i], _initHeros[i])
            else SetSltHero(_slts[i], nil) end
        end
    end

    _items = { }

    SortHero(0)
    _atd.HasAdvisor = temp.hasAdv
--    _autoFatig.value = user.IsAutoAddTP

    CheckSelected()
end

function _w.OnEnter() 

end

function _w.OnExit()
    if _body.active then
        local mod = _mod[_pur]
        if mod.onExit ~= nil then mod.onExit() end
    end
end

function _w.OnWrapGridInitItem(it, idx)
    local mod = _mod[_pur]
    local dat = _heros[idx + 1]
    if mod.onInitItem ~= nil then
        it:GetCmp(typeof(UIDragScrollView)).scrollView = _gridHeros:GetCmp(typeof(UIScrollView))
        it:GetCmp(typeof(LuaButton)).luaContainer = _body
        mod = mod.onInitItem(it, dat)
        mod.Selected = false
        for i = 1, #_slts do
            if dat ~= nil and _slts[i].param ~= nil and dat.sn == _slts[i].param.sn then
                mod.Selected = true
                break
            end
        end
        _items[it] = mod
        return true
    end
    return false
end

function _w.OnDispose()
    if _items ~= nil then
        for k, v in pairs(_items) do
            if not tolua.isnull(k) then Destroy(k) end
        end
        _items = nil
    end
    _check = false
    _onSlted = nil
    _heros = nil
    _initHeros = nil
    _pur = nil
    _citySN = nil
    _sort = nil

end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
    
    _gridHeros = nil
    _arrow = nil
    _btnSure = nil
    _autoFatig = nil
    _btnAutoFatig = nil
    _atd = nil
    _btnjs = nil
    _jsSkillInfo = nil
    _selectBg = nil
    _panelSetJS = nil
    _gridHeroJS = nil
    _item_heroJS = nil
    _btnCloseJS = nil
    _ef_appear = nil
    _ef_click = nil
    _mask = nil
    _labTtl = nil
    
    _btnTabs = nil
    _slts = nil
end

function _w.ClickSortTab(s)
    SortHero(s)
end

function _w.ClickItemHero(lb)
    local it = lb.gameObject
    if _items[it] then
        it = _items[it]
        local mod = _mod[_pur]
        if mod.onSlt == nil or mod.onSlt(it) then
            if it.Selected then
                it.Selected = false
                for i = 1, #_slts do
                    if _slts[i].param ~= nil and it.hero.sn == _slts[i].param.sn then
                        SetSltHero(_slts[i], nil)
                    end
                end
            else
                if CONFIG.tipSelectHero and mod.isMove and it.hero.InPvpCity and it.hero.loc ~= _citySN then
                    MsgBox.Show(string.format(L("{0}正在驻守，是否将他调离？"), ColorStyle.Blue(it.hero.nm)), L("是")..","..L("否"), L("{t}不再提示"), function (bsn, ipts)
                        if bsn == 0 then
                            CONFIG.tipSelectHero = not ipts[0]
                            for i = 1, #_slts do
                                if _slts[i].gameObject.tag ~= "HeroSelected" then
                                    SetSltHero(_slts[i], it.hero)
                                    if _slts[i].gameObject.tag == "HeroSelected" then it.Selected = true end
                                    break
                                end
                            end
                            CheckSelected()
                        end
                    end)
                    return
                else
                    for i = 1, #_slts do
                        if _slts[i].gameObject.tag ~= "HeroSelected" then
                            SetSltHero(_slts[i], it.hero)
                            if _slts[i].gameObject.tag == "HeroSelected" then it.Selected = true end
                            break
                        end
                    end
                end
            end
            CheckSelected()
        end
    end
end

function _w.ClickUnSelect(lb)
    if lb then
        local dat = lb.param
        local it = lb.gameObject
        if dat ~= nil then
            local mod = _mod[_pur]
            if mod.onUnSlt == nil or mod.onUnSlt(dat) then
                for _, v in pairs(_items) do
                    if v ~= nil and v.hero ~= nil then
                        if v.hero.sn == dat.sn then
                            v.Selected = false
                            break
                        end
                    end
                end
                SetSltHero(lb, nil)
                CheckSelected()
            end
        end
    end
end

function _w.ClickClose()
    local mod = _mod[_pur]
    if mod.onClose then mod.onClose()
    else _body:Exit() end
end

function _w.ClickSure()
    local mod = _mod[_pur]
    if mod.onSure then mod.onSure() end
end

--region -------------------------设置军师------------------------

--用tag进行判断是否进行选择了将领    HeroSelected：已选择   Untagged：未选择
function _w.ClickBtnSetJs()
    --创角之前禁用设置军师按钮,防止引导出错
    if user.gmMaxCity <= CONFIG.T_LEVEL then return end

    --选择的武将数量
    local num = 0
    for i = 1 , #_slts do
        if _slts[i].gameObject.tag == "HeroSelected" then
            num = num + 1
        end
    end
    if num == 0 then
        ToolTip.ShowPopTip(L("请您先选择将领上阵"))
        return
    end
    OnInitSetJS()
end

function _w.ClickCloseSetJS()
    coroutine.stop(ShowHero);
    _panelSetJS:SetActive(false)
    DisposeJS()
end

function _w.ClickSetJS(lb)
    _atd.CurSelect = lb - 1
    local itemObj = _heroJS[lb]
    local tweenScal = nil
    for i = 1, #_heroJS do
        if _heroJS[i] ~= nil then
            if i == lb then
                itemObj:AddChild(_ef_click)
                EF.Move(itemObj, 0.2, Vector3.one);
                EF.Scale(itemObj, 0.2, Vector3.one * 1.2)
                tweenScal = itemObj:GetCmp(typeof(TweenScale))
            else
                EF.Alpha(_heroJS[i].gameObject, 0.2, 0)
                _heroJS[i].gameObject:SetActive(false)
            end
        end
    end
    if tweenScal ~= nil then
        coroutine.start( function(s)
            coroutine.wait(0.25)
            EF.Scale(itemObj, 0.2, Vector3.one * 2, 0.5)
            EF.Alpha(itemObj, 0.2, 0, 0.5)
            coroutine.wait(0.3)
            CheckSelected()
            _w.ClickCloseSetJS()
        end)
    else
        _w.ClickCloseSetJS();
    end
end

--endregion

PopSelectHero = _w