local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil

local _playQty = 0
local _playPrice = 0
local _clan = 0

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "ClickFight",
    "ClickItemGoods",
    "OnUnLoad"
    )
end

function _w.OnInit()
    _ref.lables[1].text = L("普通难度")
    _ref.lables[2].text = L("史诗难度")
    _ref.lables[3].text = L("传说难度")
    _ref.lables[4].text = L("有概率得奖")
    _ref.lables[5].text = L("有概率得奖")
    _ref.lables[6].text = L("有概率得奖")
    _ref.lables[7].text = L("挑 战")
    _ref.lables[8].text = L("挑 战")
    _ref.lables[9].text = L("挑 战")

    if type(_w.initObj) == "number" then
        local kind = _w.initObj
        local wars = DB.GetClanWarFromKind(kind)
        if #wars > 0 then
            table.sort(wars, function(x, y)
                return x.dif < y.dif
            end )
            local win = Win.GetOpenWin("WinClanWar")
            if win then
                _playQty = win.GetPlayQty(kind)
                _playPrice = win.playPrice()
                _clan = wars[1].clan
                _ref.title.text = L("乱世争雄") .. "-" .. wars[1].nm
                if _clan ~= 0 then
                    _ref.tip.text = string.format(L("只能使用%s武将出战"), DB.GetNatName(_clan))
                else
                    _ref.tip.text = string.format(L("只能使用%s武将出战"), L("群雄"))
                end
                local len = math.min(#_ref.items, #wars)
                for i = 1, len do
                    _ref.items[i]:ChildBtn("btn_fight").param = wars[i].sn
                    local lab = _ref.items[i]:ChildWidget("lab_play_qty")
                    lab.text = _playQty < 0 and tostring(_playPrice) or L("可挑战")
                    lab:Child("sp_rmb"):SetActive(_playQty < 0)
                    _ref.items[i]:SetActive(true)
                    local rws = wars[i].rws
                    local goods = _ref.items[i]:Child("grid", typeof(UIGrid))
                    if rws then
                        for j, u in ipairs(rws) do
                            local ig = ItemGoods(goods:AddChild(_ref.item_goods, string.format("item_%02d", j)))
                            ig:Init(u)
                            ig:HideName()
                            ig.go.transform.localScale = Vector3(0.64, 0.64, 0.64)
                            ig.go.luaBtn.luaContainer = _body
                        end
                        goods.repositionNow = true
                    end
                end
            end
        end
    end
end

function _w.ClickItemGoods(btn)
    btn = btn and Item.Get(btn.gameObject)
    if btn then
        btn:ShowPropTip()
    end
end

local function ToFigth(sn)
    Win.Open("PopSelectHero", {
        SelectHeroFor.ClanWar, function(hs)
            if #hs > 0 then
                SVR.ClanWarReady(sn, hs, function(t)
                    if t.success then
                        user.SetClanWarHero(_clan, hs)
                        Win.Open("WinBattle", SVR.datCache)
                    end
                end )
            end
        end,_clan
    } )
end

function _w.ClickFight(sn)
    if _playQty < 0 and CONFIG.tipClanWar then
        MsgBox.Show(string.format(L("是否花费%s%d钻石[-]购买一次挑战次数(已购买%d次)?"),
        ColorStyle.RMB, _playPrice, - _playQty - 1),
        L("否,是"), "{t}" .. L("不再提示"), function(bid, tgs)
            if bid == 1 then
                if tgs[0] then
                    CONFIG.tipClanWar = false
                end
                ToFigth(sn)
            end
        end )
    else
        ToFigth(sn)
    end
end

function _w.OnDispose()
    _ref.title.text = ""
    _ref.tip.text = ""
    for i, v in ipairs(_ref.items) do
        v:UnLoadTex()
        v:SetActive(false)
        v:Child("grid"):DesAllChild()
    end
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        --package.loaded["Game.PopClanWar"] = nil
    end
end

--[Comment]
--乱世争雄
PopClanWar = _w