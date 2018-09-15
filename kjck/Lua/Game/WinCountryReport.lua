local _w = {}
WinCountryReport = _w

local _body = nil
WinCountryReport.body = _body

local _ref

local item_report
local item_good
local _grid
local goodsGrid
local title
local content
local content2
local btnReplay

local selected

local datas

local _isloading = false
local _isinit = true
local _isOver = false
local _changed = false
local _deltTm = nil

local function Refresh()
    if _deltTm and _deltTm > Time.realtimeSinceStartup then return end
    _deltTm = Time.realtimeSinceStartup + 0.03

    if datas == nil then datas = {} end
    isloading = true
    SVR.NatReport(#datas > 0 and datas[#datas].sn or 0, function(result)
        if result.success then
            local res = SVR.datCache
            table.AddNo(datas, res, "sn")
            _isOver = #res < 15
            _changed = _grid.realCount ~= #datas
            if _changed then _grid.realCount = #datas end
            if isinit then isinit = false _grid:Reset() end
        end
        isloading = false
    end)
end

function _w.OnLoad(c)
    WinBackground(c, { k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    item_report = _ref.item_report
    item_goood = _ref.item_goods
    _grid = _ref.scrollView
    goodsGrid = _ref.goodsGrid
    title = _ref.title
    content = _ref.content
    content2 = _ref.content2
    btnReplay = _ref.btnReplay

    c:BindFunction("OnInit","OnWrapGridInitItem","OnWrapGridRequestCount","OnDispose","OnUnLoad",
                   "ClickItem","ClickReplay")
end

function _w.OnInit()
    Refresh()
end

function _w.OnWrapGridInitItem(item, idx)
    if item and idx >= 0 and idx <= #datas then
        idx = idx + 1
        local dat = datas[idx]

        local time = item:ChildWidget("time")
        local title = item:ChildWidget("title")
        local tag = item:ChildWidget("tag")
        local btn = item.luaBtn

        time.text = dat.time
        if dat.atk.psn == tonumber(user.psn) then
            tag.spriteName = "tag_" .. (dat.ret > 0 and "win" or "failed" )
            title.text = DB.GetNatCity(dat.city).nm .. "攻城战"
        elseif dat.def.psn == tonumber(user.psn) then
            tag.spriteName = "tag_" .. (dat.ret > 0 and "failed" or "win" )
            title.text = DB.GetNatCity(dat.city).nm .. "防守战"
        else
            tag.spriteName = ""
            title.text = DB.GetNatCity(dat.city).nm .. "之战"
        end

        btn.param = {item, dat}
        return true
    end
    return false
end

function _w.OnWrapGridRequestCount()
    if _grid.realCount == #datas then
        if not isloading and not _isOver and _changed then
            Refresh()
            return true
        end
        return false
    end
    _grid.realCount = #datas
    return true
end

local function HeroName(dbsn, evo, ttl, iscopy)
    local hero = DB.GetHero(dbsn)
    return iscopy == 1 and hero:GetEvoName(evo) .. "分身" or DB.GetHeroTtlNm(ttl) .. hero:GetEvoName(evo)
end

local function PlayerName(psn, nsn, name)
    return ColorStyle.GetNatColorStr(nsn) .. ((string.isEmpty(name) or psn == 0) and DB.GetNatName(nsn).."国" or name ).."[-]"
end

function _w.ClickItem(p)
    local it = p[1]
    local dat = p[2]

    if selected ~= nil then selected:GetCmp(typeof(UIButton)).isEnabled = true  selected = nil end
    selected = it
    it:GetCmp(typeof(UIButton)).isEnabled = false

    local str =""
    local str2 = ""
    if dat.atk.psn == tonumber(user.psn) then
        title.text = string.format("%s攻城战", DB.GetNatCity(dat.city).nm)
        if dat.ret > 0 then
            if dat.def.nsn > 0 and dat.def.dbsn > 0 then
                str = string.format("[ADADAD]你的[FADB50]%s[-][ADADAD]战胜了%s[ADADAD]的[FADB50]%s[-]", 
                                    HeroName(dat.atk.dbsn, dat.atk.evo, dat.atk.ttl, dat.atk.isCopy),
                                    PlayerName(dat.def.psn, dat.def.nsn, dat.def.pnm),
                                    HeroName(dat.def.dbsn, dat.def.evo, dat.def.ttl, dat.def.isCopy))
            else
                str = string.format("[ADADAD]你的[FADB50]%s[-][ADADAD]战胜了" , HeroName(dat.atk.dbsn, dat.atk.evo, dat.atk.ttl, dat.atk.isCopy))
            end

            if dat.ret > 1 then
                str = str .. "\n[00FF00]你成功夺取了".. DB.GetNatCity(dat.city).nm.."[-]"
            end
        else 
            if dat.def.nsn > 0 and dat.def.dbsn > 0 then
                str = string.format("[ADADAD]你的[FADB50]%s[-][ADADAD]被%s[ADADAD]的[FADB50]%s[-][ADADAD]打败了", 
                                    HeroName(dat.atk.dbsn, dat.atk.evo, dat.atk.ttl, dat.atk.isCopy),
                                    PlayerName(dat.def.psn, dat.def.nsn, dat.def.pnm),
                                    HeroName(dat.def.dbsn, dat.def.evo, dat.def.ttl, dat.def.isCopy))
            else
                str = string.format("[ADADAD]你的[FADB50]%s[-][ADADAD]被[ADADAD]打败了" , HeroName(dat.def.dbsn, dat.def.evo, dat.def.ttl, dat.def.isCopy))
            end
        end
        str2 = "[00FF00]功勋 +" ..dat.atk.pmerit .."\n" .. "荣誉 +" .. dat.atk.merit .."[-]"
    elseif dat.def.psn == tonumber(user.psn) then
        title.text = string.format("%s防守战", DB.GetNatCity(dat.city).nm)
        if dat.ret > 0 then
            str = string.format("[ADADAD]你的[FADB50]%s[-][ADADAD]被%s[ADADAD]的[FADB50]%s[-][ADADAD]打败了", 
                                HeroName(dat.def.dbsn, dat.def.evo, dat.def.ttl, dat.def.isCopy),
                                PlayerName(dat.def.psn, dat.def.nsn, dat.def.pnm),
                                HeroName(dat.atk.dbsn, dat.atk.evo, dat.atk.ttl, dat.atk.isCopy))

            if dat.ret > 1 then
                str = str .. "\n[00FF00]".. DB.GetNatCity(dat.city).nm.."失守了[-]"
            end
        else 
            str = string.format("[ADADAD]你的[FADB50]%s[-][ADADAD]战胜了%s[ADADAD]的[FADB50]%s[-]", 
                                HeroName(dat.def.dbsn, dat.def.evo, dat.def.ttl, dat.def.isCopy),
                                PlayerName(dat.def.psn, dat.def.nsn, dat.def.pnm),
                                HeroName(dat.atk.dbsn, dat.atk.evo, dat.atk.ttl, dat.atk.isCopy))
        end
        str2 = "[00FF00]功勋 +" ..dat.def.pmerit .."\n" .. "荣誉 +" .. dat.def.merit .."[-]"
    else
        title.text = string.format("%s之战", DB.GetNatCity(dat.city).nm)
    end

    content.text = str
    content2.text = str2
    btnReplay.luaBtn:SetClick("ClickReplay", dat.sn)
end

function _w.ClickReplay(sn)
    SVR.NatReplay(sn, function(result)
        if result.success then
            ToolTip.ShowPopTip("回放功能暂未完成!")
        end
    end)
end

function _w.OnDispose()
    _isinit = true
    _isloading = false
    _isOver = false
    _changed = false
    _deltTm = nil
    datas = nil

    if _grid.transform.childCount > 0 then _grid:DesAllChild() end
    _grid:Reset()
end

function _w.OnUnLoad()
    _body = nil
end

