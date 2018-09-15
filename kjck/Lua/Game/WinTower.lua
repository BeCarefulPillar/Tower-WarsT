local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil
local _bg = nil

local _boss = nil
local _fight = nil

local _datas = nil
local _goods = nil


function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c,{n=L("决斗"),r=DB_Rule.Tower,i=true})

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "ClickReset",
    "ClickFight",
    "ClickSD",
    "ClickItemGoods",
    "ClickAchievement",
    "OnWrapGridInitItem",
    "ClickDeploy",
    "Help",
    "OnUnLoad"
    )

    _boss = { }
    for i, v in ipairs(_ref.item_bossList) do
        _boss[i] = {
            go = v,
            utx = v:ChildWidget("hero")
        }
    end
    _ref.item_bossList = nil

    _fight = {
        btn = _ref.btnFight,
        tip = _ref.btnFight:Child("tip").gameObject,
        wgt = _ref.btnFight.widget,
        lab = _ref.btnFight:ChildWidget("Label"),
    }
    _ref.btnFight = nil
end

local function TowerSort(x, y)
    return x.sn < y.sn
end

local function Despawn(items)
    if items then
        for i, v in ipairs(items) do
            v.go:SetActive(false)
        end
    end
end

local function UpdateInfo()
    Despawn(_goods)
    if user.towerInfo.rank <= 0 or not _datas then
        return
    end
    _ref.resetQty.text = L("重置次数:") .. user.towerInfo.resetQty
    if #_datas <= 0 then
        return
    end
    table.sort(_datas, TowerSort)

    local inDif = user.towerInfo.rank >= _datas[1].sn and user.towerInfo.rank >= _datas[#_datas].sn
    _fight.btn.isEnabled = inDif

    local ri = 0
    for i, v in ipairs(_datas) do
        if v.sn < user.towerInfo.rank then
            ri = ri + 1
        end
    end
    local cidx = ri < #_datas and ri + 1 or #_datas
    --设置boss头像
    local npc = nil
    for i, v in ipairs(_boss) do
        npc = _datas[cidx].npc
        if i <= #npc then
            v.go:SetActive(true)
            local h = DB.GetHero(npc[i][2])
            v.utx:LoadTexAsync(ResName.HeroIcon(h.img))
        else
            v.utx:UnLoadTex()
        end
    end
    _ref.bossGrid:Reposition()

    print(kjson.print(_datas[cidx]))

    if user.towerInfo.sd == 1 then
        _ref.perfect.text =  L("[93a1a7]完美通关条件：[-][01da00]") .. _datas[cidx].perfect .. "[-]"
        _fight.btn.isEnabled = true
        _fight.tip:SetActive(false)
        _fight.wgt.spriteName = "sp_btn_login"
        _fight.btn.normalSprite = "sp_btn_login"
        _fight.lab.text = L("扫 荡")
        _fight.btn.luaBtn:SetClick(_w.ClickSD)
    else
        _ref.perfect.text = L("[93a1a7]完美通关条件：[-][70a1b1]") .. _datas[cidx].perfect .. "[-]"
        _fight.wgt.spriteName = "sp_btn_register"
        _fight.btn.normalSprite = "sp_btn_register"
        _fight.lab.text = L("挑 战")
        _fight.btn.luaBtn:SetClick(_w.ClickFight)
    end

    local f = #user.towerInfo.hero > 0
    _fight.btn.isEnabled = f
    _fight.tip:SetActive(not f)
    _ref.btnDeploy.isEnabled = not f

    --设置奖励物品
    local rws = _datas[cidx].rws
    if rws then
        _goods = _goods or { }
        for i, v in ipairs(rws) do
            if not _goods[i] then
                _goods[i] = ItemGoods(_ref.rewards:AddChild(_ref.item_goods, string.format("item_%02d", i)))
                _goods[i].go.luaBtn.luaContainer = _body
                _goods[i]:HideName()
            else
                _goods[i].go:SetActive(true)
            end
            _goods[i]:Init(v)
        end
        _ref.rewards.repositionNow = true
    end
    if ri < #_datas then
        _ref.rank.text = string.format("[b]" .. L("第%s关") .. "[/b]", number.ToCnString(ri + 1))
        _ref.rank:SetActive(true)
        _ref.rankPass:SetActive(false)
    else
        _ref.rank:SetActive(false)
        _ref.rankPass:SetActive(true)
    end

    --跳转图片
    _ref.grid:Reset()
    _ref.grid.realCount = #_datas
    _ref.grid:AlignItem(user.towerInfo.rank)
end

local function CheckUpdate()
    print(kjson.print(_datas))
    if user.towerInfo.rank > 0 and _datas then
--        for i, v in ipairs(_datas) do
--            if v.sn >= user.towerInfo.rank or i == #_datas then
--                _dif = v.diff or 0
--                break
--            end
--        end
        coroutine.start(UpdateInfo)
    end
end

local function PriRefresh()
    SVR.GetTowerInfo( function(t)
        if t.success then
            --stab.S_TowerInfo
            print(kjson.print(SVR.datCache))
            print(kjson.print(user.towerInfo))
            CheckUpdate()
        end
    end )
end

function _w.OnInit()
    if not _datas then
        _datas = DB.Get(LuaRes.Tower)
        if _datas then
            table.sort(_datas, TowerSort)
            CheckUpdate()
        end
    elseif user.towerInfo.rank > 0 then
        CheckUpdate()
    end
    PriRefresh()
end

function _w.OnDispose()
    Despawn(_goods)
end

--[Comment]
--重置
function _w.ClickReset()
    MsgBox.Show(L("重置后将清空当前的挑战进度重新开始，是否重置？"),
    L("否,是"),
    function(bid)
        if bid == 1 then
            SVR.ResetTower( function(t)
                if t.success then
                    CheckUpdate()
                end
            end )
        end
    end )
end

--[Comment]
--部署
function _w.ClickDeploy()
    Win.Open("PopSelectHero", {
        SelectHeroFor.Tower,
        function(hs)
            local h = { }
            local t = nil
            print(kjson.encode(hs))
            for i, v in ipairs(hs) do
                t = user.GetHero(v)
                h[i] = string.join(",", { v, t.MaxStr, t.MaxWis, t.MaxCap, t.MaxHP })
            end
            local herosStr = string.join('|', h)
            if hs then
                SVR.DeployTowerHero(herosStr, function(t)
                    if t.success then
                        user.TowerBattleHero = hs
                        local f = #user.towerInfo.hero > 0
                        _fight.btn.isEnabled = true
                        _fight.tip:SetActive(not f)
                        _ref.btnDeploy.isEnabled = not f
                        ToolTip.ShowPopTip(L("部署成功！"))
                    end
                end )
            end
        end
    } )
end

--[Comment]
--成就
function _w.ClickAchievement()
    Win.Open("PopLuaTowerAchievement")
end

--[Comment]
--扫荡
function _w.ClickSD()
    StatusBar.Show()
    SVR.BlitzTower(0, function(t)
        StatusBar.Exit()
        if t.success then
            coroutine.start(UpdateInfo)
        end
    end )
end

--[Comment]
--出击
function _w.ClickFight()
    if user.towerInfo.rank > 0 then
        Win.Open("PopSelectHero", {
            SelectHeroFor.Tower,
            function(hs)
                if hs then
                    SVR.TowerReady(user.towerInfo.rank, 1, hs, function(t)
                        if t.success then
                            local battle = SVR.datCache
                            if battle then
                                --battle.diff = 1
                                Win.Open("WinBattle", SVR.datCache)
                            end
                        end
                    end )
                end
            end
        } )
    end
end

function _w.Help()
    Win.Open("PopRule", DB_Rule.Tower)
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_datas then
        return false
    end

    item:ChildWidget("rank").text = string.format(L("第%s关"), number.ToCnString(i + 1))
    local wgt = item.widget
    wgt:LoadTexAsync("tex_tower_" ..(i % 6 + 1))
    wgt.color = _datas[i + 1].sn <= user.towerInfo.rank and Color(0.5, 0.5, 0.5) or Color(0.5, 0, 0.5)
    item:Child("pass"):SetActive(_datas[i + 1].sn < user.towerInfo.rank)

    return true
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _bg:dispose()
        _bg = nil
        _goods = nil
        --package.loaded["Game.WinTower"] = nil
    end
end

--[Comment]
--过关斩将
WinTower = _w