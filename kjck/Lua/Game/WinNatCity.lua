local _w = { }

local _body = nil
local _ref = nil

--[Comment]
--buff最长时间 单位:s
local maxBufTm = 600;

local _city = 0
local _gridTex = nil
--[Comment]
--国战城池历史信息
local _datas = nil
--[Comment]
--观战页面数据
local _data = nil   
--[Comment]
--突袭CD
local _raidCD = nil
--[Comment]
--单挑CD
local _soloCD = nil

local _atkBufMask = nil
local _defBufMask = nil

local _bufBuffer = {}

local _items = {}

--绑定组件
local _itemReport = nil
local _itemBuf = nil
local _btnClose = nil
local _btnRaid = nil
local _btnSolo = nil
local _btnCopy = nil
local _btnRetreat = nil
local _btnHelp = nil
local _title = nil
local _reportPanel = nil
local _atkBufPanel = nil
local _defBufPanel = nil
local _atkLab = nil
local _defLab = nil
local _raidTime = nil
local _soloTime = nil
local _copyPrice = nil
local _atkHeros = nil
local _defHeros = nil

--是否匹配指定编号的武将，主要是排除分身
local function EqualHero(h, hSN)
    return h.isCopy == 0 and tostring(h.csn) == tostring(hSN)
end
-- 拼合的武将名称,用于显示  S_NatReportUnit
local function HeroName(h)
    return h.isCopy == 1 and DB.GetHero(h.dbsn):getName()..L("(分身)") or DB.GetHeroTtlNm(h.dbsn)..DB.GetHero(h.dbsn):getName()
end
-- 拼合的玩家名称,用于显示  S_NatReportUnit
local function PlayerName(h)
    return ColorStyle.GetNatColorStr(h.nsn)..((string.isEmpty(h.pnm) or h.psn == 0) and DB.GetNatName(h.nsn).."国" or h.pnm).."[-]"
end

local function BuildItems()
    for i = 1, #_datas  do
        local item = _reportPanel:AddChild(_itemReport, string.format("item_%2d",i))
        local c = ""
        local dat = _datas[i]
        if dat.def.nsn > 0 and dat.def.dbsn > 0 then
            local winner = nil
            local loser = nil 
            if dat.ret > 0 then
                winner = dat.atk
                loser = dat.def
            else
                winner = dat.def
                loser = dat.atk
            end  
            c = L( string.format("[%s]%s的[FADB50]%s[-]战胜了%s的[FADB50]%s[-]", dat.time, PlayerName(winner), HeroName(winner), PlayerName(loser), HeroName(loser)))
        elseif dat.ret > 0 then
            c = L( string.format("[%s]%s的[FADB50]%s[-]已战胜"), dat.time, PlayerName(dat.atk), HeroName(dat.atk))
        else
            c = L( string.format("[%s]%s的[FADB50]%s[-]已战败"), dat.time, PlayerName(dat.atk), HeroName(dat.atk))
        end
        if dat.ret > 1 then
            if dat.atk.nsn == 0 then
                print("guid = "..dat.sn.."atk = "..PlayerName(dat.atk))
            end
            local str = string.format("[%s]%s占领了%s",dat.time, ColorStyle.GetNatColorStr(dat.atk.nsn) .. DB.GetNatName(dat.atk.nsn).."国[-]", DB.GetNatCity(dat.city).nm)
            c = L( string.isEmpty(c) and str or (c.."\n"..str))
        end
        item:GetCmp(typeof(UILabel)).text = c
        item:SetActive(true)
    end
    _reportPanel:GetCmp(typeof(UITable)):Reposition()
end

local function RefreshReport()
    SVR.NatCityReport(_city, 0,function(res)
        if res.success then
            local r = SVR.datCache
            print("RefreshReport     ", kjson.print(r))
        end
    end)
end

--中间的战斗信息
local function OnDragPage()
    SVR.NatCityReport(_city, #_datas > 0 and _datas[#_datas].sn or 0,function(res)
        if res.success then
            local r = SVR.datCache
            print("rrrrrrrrrrrrrr     ", #r)
            table.AddNo(_datas, r, "sn")
            BuildItems()
            print("kjsonjjooo  ondrfada    ", kjson.print(_datas))
            print("_datas_datas_datas     ", #_datas)

        end
    end)
end

local function UpdateBufMask()
    if _atkBufMask ~= nil then
        for i = 1, #_atkBufMask do
            local idx = i * 2
            if _data.atkPropsBuff:IndexAvailable(idx) then
                _atkBufMask[i].fillAmount = math.clamp(maxBufTm - _data.atkPropsBuff[idx], 0 ,maxBufTm) / maxBufTm
            else
                _atkBufMask[i].fillAmount = 1
            end
        end
    end

    if _defBufMask ~= nil then
        for i = 1, #_defBufMask do
            local idx = i * 2
            if _data.defPropsBuff:IndexAvailable(idx) then
                _defBufMask[i].fillAmount = math.clamp(maxBufTm - _data.defPropsBuff[idx], 0 ,maxBufTm) / maxBufTm
            else
                _defBufMask[i].fillAmount = 1
            end
        end
    end
end

local function UpdateBuf()
    local idx = 0
    if #_data.atkPropsBuff > 1 then
        _atkBufMask = {}
        for i = 1, #_data.atkPropsBuff, 2 do
            local utx = nil
            if idx < _bufBuffer then
                utx = _bufBuffer[idx]
                utx.name = "buf"..i
                utx.transform.parent = _atkBufPanel.transform
            else
                utx = _atkBufPanel:AddChild(_itemBuf,"buf_1"..i,false):GetCmp(typeof(UITexture))
                table.insert(_bufBuffer,utx)
            end
            idx = idx + 1
            utx:SetActive(true)
            utx.luaBtn:SetClick("ShowAtkBuf",_data.atkPropsBuff[i])
            _gridTex:Add(utx:LoadTexAsync(ResName.PropsIcon(DB.GetProps(_data.atkPropsBuff[i]).img)))
            _atkBufMask[ math.floor( (i + 1) / 2)] = utx:ChildWidget("mask")
        end
    else
        _atkBufMask = nil
    end

    if #_data.defPropsBuff > 1 then
        _defBufMask = {}
        for i = 1, #_data.defPropsBuff, 2 do
            local utx = nil
            
            if idx < _bufBuffer then
                utx = _bufBuffer[idx]
                utx.name = "buf"..i
                utx.transform.parent = _defBufPanel.transform
            else
                utx = _defBufPanel:AddChild(_itemBuf,"buf_1"..i,false):GetCmp(typeof(UITexture))
                table.insert(_bufBuffer,utx)
            end
            idx = idx + 1
            utx:SetActive(true)
            utx.luaBtn:SetClick("ShowDefBuf",_data.defPropsBuff[i])
            _gridTex:Add(utx:LoadTexAsync(ResName.PropsIcon(DB.GetProps(_data.defPropsBuff[i]).img)))
            _defBufMask[ math.floor( (i + 1) / 2)] = utx:ChildWidget("mask")
        end
    else
        _defBufMask = nil
    end
    print("_bufBuffer_bufBuffer    ",kjson.print(_bufBuffer))
    if #_bufBuffer > 0 then
        for i = idx ,#_bufBuffer do
            _bufBuffer[i]:SetActive(false)
        end
    end


    _atkBufPanel:GetCmp(typeof(UIGrid)).repositionNow = true
    _defBufPanel:GetCmp(typeof(UIGrid)).repositionNow = true

    UpdateBufMask()
end

local function UpdateInfo()
    local fight = false
    local dataLen = #_data.info
    if dataLen > 1 then
        _defLab.text = DB.GetNatName(_data.info[1])..":".._data.info[2]
        _atkLab.text = ""
    end
    if dataLen > 3 and dataLen < 6 then
        _atkLab.text = DB.GetNatName(_data.info[3])..":".._data.info[4]
        fight = _data.info[4] > 0
    elseif dataLen > 5 then
        _atkLab.text = DB.GetNatName(_data.info[3])..":".._data.info[4].." "..DB.GetNatName(_data.info[5])..":".._data.info[6]
        fight = _data.info[4] > 0 or _data.info[6] > 0
    end
    dataLen = #_data.atkHeros
    fight = dataLen > 0
    local size = 0 
    local myHeros = {}
    for i = 1, #user.nat.heros do
        if user.nat.heros[i].city == _city then
            table.insert(myHeros,user.nat.heros[i].sn)
            size = size + 1
        end
    end
    print("sizesize    ", size)
    --攻方
    for i = 1, #_atkHeros do
        if i <= dataLen then
            for j = 1, size do
                if EqualHero(_data.atkHeros[i], myHeros[j]) then
                    myHeros[j] = 0
                end
            end
            local aHero = _atkHeros[i]
            local dHero = _data.atkHeros[i]
            aHero:ChildWidget("hero_name").text = dHero.isCopy == 1 and DB.GetHero(dHero.dbsn):getName()..L("(分身)") or DB.GetHeroTtlNm(dHero.dbsn) .. " "..DB.GetHero(dHero.dbsn):getName()
            aHero:ChildWidget("hero_lv").text = L("Lv:")..dHero.lv
            aHero:ChildWidget("player_name").text = dHero.pnm..ColorStyle.GetNatColorStr(dHero.nsn).."["..DB.GetNatName(dHero.nsn).."][-]"
            _gridTex:Add(aHero:GetCmp(typeof(UITexture)):LoadTexAsync(ResName.HeroIcon(DB.GetHero(dHero.dbsn).img)))
            aHero:SetActive(true)
        else
            _atkHeros[i]:SetActive(false)
            _atkHeros[i]:GetCmp(typeof(UITexture)):UnLoadTex()
        end
    end
    --守方
    dataLen = #_data.defHeros
    for i = 1, #_defHeros do
        if i <= dataLen then
            for j = 1, size do
                if EqualHero(_data.defHeros[i], myHeros[j]) then
                    myHeros[j] = 0
                end
            end
            local aHero = _defHeros[i]
            local dHero = _data.defHeros[i]
            aHero:ChildWidget("hero_name").text = dHero.isCopy == 1 and DB.GetHero(dHero.dbsn):getName()..L("(分身)") or DB.GetHeroTtlNm(dHero.dbsn) .. " "..DB.GetHero(dHero.dbsn):getName()
            aHero:ChildWidget("hero_lv").text = L("Lv:")..dHero.lv
            aHero:ChildWidget("player_name").text = dHero.pnm..ColorStyle.GetNatColorStr(dHero.nsn).."["..DB.GetNatName(dHero.nsn).."][-]"
            _gridTex:Add(aHero:GetCmp(typeof(UITexture)):LoadTexAsync(ResName.HeroIcon(DB.GetHero(dHero.dbsn).img)))
            local stat = aHero:ChildWidget("status")
            if fight then
                for j = 1, size do
                    if EqualHero(dHero,myHeros[j]) then
                        myHeros[j] = 0
                    end
                end
                stat.text = i == 1 and L("战斗中") or L("备战中")
                stat.color = i == 1 and Color(0.882, 0, 0) or Color(0.11, 0.8, 0.15)
            else
                stat.text = L("驻守中")
                stat.color = Color(0.11, 0.8, 0.15)
            end
            aHero:SetActive(true)
        else
            _defHeros[i]:SetActive(false)
            _defHeros[i]:GetCmp(typeof(UITexture)):UnLoadTex()
        end
    end

    _atkHeros[1].transform:FindChild("EF_Frame"):SetActive(fight)
    _defHeros[1].transform:FindChild("EF_Frame"):SetActive(fight)

    _raidCD = user.nat.raidTm > 0
    _soloCD = user.natSoloCD > 0

    print("fight`````````````     ", fight)

    if fight then
        local hasQueueHero = false
        for i = 1, size do
            print("myHerosmyHeros    ", tonumber(myHeros[i]))
            if tonumber(myHeros[i]) > 0 then
                hasQueueHero = true
                break
            end
        end
        print("hasQueueHero    ", hasQueueHero)
        print("_raidCD    ", _raidCD)
        print("size    ", size)
        _btnRaid.isEnabled = hasQueueHero and not _raidCD
        _btnSolo.isEnabled = hasQueueHero and not _soloCD
        _btnCopy.isEnabled = size > 0
        _btnRetreat.isEnabled = hasQueueHero
    else
        _btnRaid.isEnabled = false
        _btnSolo.isEnabled = false
        _btnCopy.isEnabled = false
        _btnRetreat.isEnabled = false
    end
    UpdateBuf()
end

function _w.Refresh()
    print("Refresh")
    SVR.NatCityFightInfo(_city,function(res)
        if res.success then
            _data = SVR.datCache
            print("Refresh  data  ",kjson.print(_data))
            UpdateInfo()
        else
            if res.code == ERR.CityNoFight then
                local idx = _city - 1
                if user.nat.city[idx] and user.nat.city[idx].atk > 0 then
                    user.nat.city[idx].atk = 0
                    UpdateNat()
                end
            end
            if not debug then
                _body:Exit()
            end
        end
    end)
end

--battle  S_NatBattle  更新战斗信息
local function UpdateNatBattleInfo(battle)
    print("battlebattle    ",kjson.print(battle))
    if battle.city > 0 and battle.city == _city then
        local go = _body.gameObject:AddChild(AM.LoadPrefab("ef_fight_cw"),"ef_fight_cw")
        Destroy(go,1)
        go.transform.localPosition = battle.ret > 0 and Vector3(-340, 123, 0) or Vector3(338, 127, 0)
        
        go = _body.gameObject:AddChild(AM.LoadPrefab("ef_fight_cf"),"ef_fight_cf")
        WidgetEffect:Detonate(go:GetCmp(typeof(UIWidget)), math.random(4, 8), math.random(2, 4), 0.5, true, 5, 15)
        Destroy(go,1)
        go.transform.localPosition = battle.ret > 0 and Vector3(338, 127, 0) or Vector3(-340, 123, 0)
        
        if battle.atkQty > 0 then
            Invoke(_w.Refresh, 0.8)
        else
            local list = {}
            if #_data.atkHeros > 0 then
                for i = 1, #_data.atkHeros  do
                    if _data.atkHeros[i].nsn == battle.nsn then
                        table.insert(_data.atkHeros[i])
                    end
                end
            end
            if #_data.defHeros > 0  then
                for i = 1, #_data.defHeros  do
                    if _data.defHeros[i].nsn == battle.nsn then
                        table.insert(_data.defHeros[i])
                    end
                end
            end

            local info = {battle.nsn, #list}
            if #_data.info > 2 then
                for i = 1, #_data.info, 2 do
                    if _data.info[i] == battle.nsn then
                        if i + 1 <= #_data.info then
                            info[2] = _data.info[i + 1]
                        end
                        break
                    end
                end
            end

            _data.atkHeros = {}
            _data.defHeros = list
            _data.info = info
            Invoke(UpdateInfo, 0.8)
        end
        RefreshReport()
    end
end

--更新国战武将信息
local function UpdateNatInfo()
    if #_data.info < 3 then
        local idx = _city - 1
        if user.nat.flagCity[idx] and user.nat.flagCity[idx].atk > 0 then
            _w.Refresh()
        end
    end
end

function _w.OnLoad(c)
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad","OnWrapGridInitItem",
                    "Refresh","ClickRaid","ClickSolo","ClickCopy","ClickRetreat")
    _ref = c.nsrf.ref
    _itemReport = _ref.itemReport
    _itemBuf = _ref.itemBuf
    _btnClose = _ref.btnClose
    _btnRaid = _ref.btnRaid
    _btnSolo = _ref.btnSolo
    _btnCopy = _ref.btnCopy
    _btnRetreat = _ref.btnRetreat
    _btnHelp = _ref.btnHelp
    _title = _ref.title
    _reportPanel = _ref.reportPanel
    _atkBufPanel = _ref.atkBufPanel
    _defBufPanel = _ref.defBufPanel
    _atkLab = _ref.atkLab
    _defLab = _ref.defLab
    _raidTime = _ref.raidTime
    _soloTime = _ref.soloTime
    _copyPrice = _ref.copyPrice
    _atkHeros = _ref.atkHeros
    _defHeros = _ref.defHeros
end

function _w.OnInit() 
    if isNumber(_w.initObj) then
        _city = _w.initObj
        print("111   ",_city)
        print("111   ",kjson.print(user.nat.city[_city]))
        
        if _gridTex == nil then _gridTex = GridTexture(128, 32) end
        _datas = {}
        _w.Refresh()
        _title.text = DB.GetNatCity(_city).nm
        UpdateNat:Add(UpdateNatInfo)
        UpdateNatBattle:Add(UpdateNatBattleInfo)
        OnDragPage()
        _copyPrice.text = DB.param.prNatCopy
        return
    end
    Destroy(_body.gameObject)
end

function _w.OnDispose()
    UpdateNat:Remove(UpdateNatInfo)
    UpdateNatBattle:Remove(UpdateNatBattleInfo)
    _city = 0
    _datas = nil
    _atkBufMask = nil
    _defBufMask = nil
    _bufBuffer = {}
    if _gridTex then
        _gridTex:Dispose()
        _gridTex = nil
    end

    for i,v in ipairs(_atkHeros) do
        v:SetActive(false)
    end
    for i,v in ipairs(_defHeros) do
        v:SetActive(false)
    end
end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
    _itemReport = nil
    _itemBuf = nil
    _btnClose = nil
    _btnRaid = nil
    _btnSolo = nil
    _btnCopy = nil
    _btnRetreat = nil
    _btnHelp = nil
    _title = nil
    _reportPanel = nil
    _atkBufPanel = nil
    _defBufPanel = nil
    _atkLab = nil
    _defLab = nil
    _raidTime = nil
    _soloTime = nil
    _copyPrice = nil
    _atkHeros = nil
    _defHeros = nil
end

function _w.OnWrapGridInitItem(it, idx)

end

--[Comment]
--攻方显示BUFF说明
function _w.ShowAtkBuf(m)
    print("攻方mmmmmmmmmmmmm     ",m)
    local sn = m
    local p = DB.GetProps(sn)
    if #_data.atkPropsBuff > 1 then
        for i = 1, #_data.atkPropsBuff, 2 do
            if _data.atkPropsBuff[i] == sn and i + 1 <= #_data.atkPropsBuff then
                ToolTip.ShowPropTip(p.nm, L("剩余时间:")..TimeClock.TimeToSmart(_data.atkPropsBuff[i + 1]).."\n"..L("说明:")..p.i)
                return
            end
        end
    end
    ToolTip.ShowPropTip(p.nm, L("说明:")..p.i)
end

--[Comment]
--守方显示BUFF说明
function _w.ShowDefBuf(m)
    print("守方mmmmmmmmmmmmm     ",m)
    local sn = m
    local p = DB.GetProps(sn)
    if #_data.defPropsBuff > 1 then
        for i = 1, #_data.defPropsBuff, 2 do
            if _data.defPropsBuff[i] == sn and i + 1 <= #_data.defPropsBuff then
                ToolTip.ShowPropTip(p.nm, L("剩余时间:")..TimeClock.TimeToSmart(_data.defPropsBuff[i + 1]).."\n"..L("说明:")..p.i)
                return
            end
        end
    end
    ToolTip.ShowPropTip(p.nm, L("说明:")..p.i)
end

--[Comment]
--查看队列中的将领
local function CheckQueueHero(hero)
    print("heroheroheroherohero    ",kjson.print(hero))
    local len = math.min(#_atkHeros,#_data.atkHeros)
    for i = 1, len do
        if EqualHero(_data.atkHeros[i],hero.sn) then
            ToolTip.ShowPopTip(L(ColorStyle.Blue(hero:getName())..(i > 1 and "正在备战中！" or "正在战斗中！")))
            return false
        end
    end
    local len = math.min(#_defHeros,#_data.defHeros)
    for i = 1, len do
        if EqualHero(_data.defHeros[i],hero.sn) then
            ToolTip.ShowPopTip(L(ColorStyle.Blue(hero:getName())..(i > 1 and "正在备战中！" or "正在战斗中！")))
            return false
        end
    end
    return true
end
_w.CheckQueueHero = CheckQueueHero

--[Comment]
--突袭
function _w.ClickRaid()
    if user.nat.raidTm > 0 then
        ToolTip.ShowPopTip(L("突袭冷却中"))
        return
    end
    if MapNat.isOpen then
        print("1233333333333    ", _city)
        MapNat.CheckRaid(_city)
    end
    _body:Exit()
end

--[Comment]
--单挑
function _w.ClickSolo()
    if user.natSoloCD > 0 then
        ToolTip.ShowPopTip(L("单挑冷却中"))
        return
    end
    Win.Open("PopSelectHero",{SelectHeroFor.NatOption , function(hero)
        print("ClickSolo  单挑~~~~~   " ,kjson.print(hero))
        if #hero > 0 and tonumber(hero[1]) > 0 then
            if not CheckQueueHero(hero) then
                return
            end
            SVR.NatSolo(hero[1], _city, function(res)
                if res.success then
                    res = SVR.datCache
                    _w.Refresh()
                    --单挑赢了
                    if user.psn == res.winner then
                        MsgBox.Show(L("你在单挑中战胜了对手"),L("查看")..L("确定"),function(idx)
                            if idx == 1 then
                                Win.Open("WinBattleReplay", res.rec)
                            end
                        end)
                    elseif user.psn == res.loser then
                        MsgBox.Show(L("你在单挑中战败了"),L("查看")..L("确定"),function(idx)
                            if idx == 1 then
                                Win.Open("WinBattleReplay", res.rec)
                            end
                        end)
                    end
                else
                    MsgBox.Show(L("单挑结束"))
                end
            end)
        end
    end, _city, true})
end

--[Comment]
--分身
function _w.ClickCopy()
    Win.Open("PopSelectHero",{SelectHeroFor.NatOption , function(hero)
        print("ClickCopy  分身~~~~~   " ,kjson.print(hero))
        if #hero > 0 and tonumber(hero[1]) > 0 then
            SVR.NatHeroOpt("copy", _city, hero[1], function(res)
                if res.success then
                    res = SVR.datCache
                    local hd = user.GetHero(res.csn)
                    if hd then
                        ToolTip.ShowPopTip(ColorStyle.Blue(L(DB.GetHeroTtlNm(hd.ttl).. hd:getName())).. L("分身成功!"))
                    end
                    _w.Refresh()
                end
            end)
        end
    end, _city})
end

--[Comment]
--撤退
function _w.ClickRetreat()
    Win.Open("PopSelectHero", {SelectHeroFor.NatOption, function(hero)
        if #hero and tonumber(hero[1]) > 0 then
            SVR.NatHeroOpt("back", _city, hero[1], function(res)
                if res.success then
                    res = SVR.datCache
                    local hd = user.GetHero(res.csn)
                    if hd then
                        ToolTip.ShowPopTip(ColorStyle.Blue(L(DB.GetHeroTtlNm(hd.ttl).. hd:getName())).. L( string.format("已从%s撤退!", ColorStyle.Blue(DB.GetNatCity(_city).nm))))
                    end
                end
            end)
        end
    end,_city, true})
end

--[Comment]
--国战观战
WinNatCity = _w