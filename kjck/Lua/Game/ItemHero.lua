local SelectHeroFor = SelectHeroFor

local _item = 
{
    --[Comment]
    -- 背景
    bg = nil,
    --[Comment]
    --武将名字
    name = nil,
    --[Comment]
    --星级
    rare = nil,
    --[Comment]
    --等级
    lv = nil,
    --[Comment]
    --官阶
    ttl = nil,
    --[Comment]
    --武力
    str = nil,
    --[Comment]
    --智力
    wis = nil,
    --[Comment]
    --统帅
    cap = nil,
    --[Comment]
    --血量
    hp = nil,
    --[Comment]
    --技力
    sp = nil,
    --[Comment]
    --兵力
    tp = nil,
    --[Comment]
    -- 忠诚度
    loyalty = nil,
    --[Comment]
    --位置
    loc = nil,
    --[Comment]
    --国家
    country = nil,

    --武将数据
    hero = nil,
}

--[Comment]
--检测对象是否存活
local function CheckDead(i)
    if tolua.isnull(i.go) then
        if i.go then
            i.go = nil
            if i.hero and i.hero.RemoveObserver then i.hero:RemoveObserver(i) end
            table.clear(i)
        end
        return true
    end
end

--[Comment]
--构造
function _item.New(go)
    assert(not tolua.isnull(go), "create ItemHero need GameObject")
    return
    {
        go = go,
        bg = go:ChildWidget("bg_select"),
        unbg = go:ChildWidget("bg_unselect"),
        name = go:ChildWidget("name"),
        rare = go:ChildWidget("rare"),
        lv = go:ChildWidget("lv"),
        ttl = go:ChildWidget("ttl"),
        str = go:ChildWidget("str"),
        wis = go:ChildWidget("wis"),
        cap = go:ChildWidget("cap"),
        hp = go:ChildWidget("hp"),
        sp = go:ChildWidget("sp"),
        tp = go:ChildWidget("tp"),
        country = go:ChildWidget("country"),
--        loyalty = go:ChildWidget("loyalty"),
--        loc = go:ChildWidget("loc"),
    }
end

local function UpdateHeroInfo(i)
    local h, p = i.hero, i.purpose
    if h then
        i.name.text = h:getName()
        i.rare.TotalCount = h.rare
        i.lv.text = tostring(h.lv)
        i.ttl.text = LN(h.tnm)
        i.country.text = DB.GetNatName(h.clan)

        if p == SelectHeroFor.Nat or p == SelectHeroFor.NatOption or p == SelectHeroFor.NatMove then
            i.str.text = tostring(h.MaxStr)
            i.wis.text = tostring(h.MaxWis)
            i.cap.text = tostring(h.MaxCap)
            i.hp.color = Color.white
            i.hp.text = tostring(h.MaxHP)
            i.sp.text = tostring(h.MaxSP)
            i.tp.text = tostring(h.MaxTP)
        elseif p ==SelectHeroFor.BorrowHero then  --借将给别人
            i.str.text = tostring(h.MaxStr)
            i.wis.text = tostring(h.MaxWis)
            i.cap.text = tostring(h.MaxCap)
            i.hp.color = Color.white
            i.hp.text = tostring(h.MaxHP)
            i.sp.text = tostring(h.MaxSP)
            i.tp.text = tostring(h.MaxTP)
        else
            i.str.text = tostring(h.str)
            i.wis.text = tostring(h.wis)
            i.cap.text = tostring(h.cap)

            local th = nil
            if p == SelectHeroFor.Tower and user.towerInfo.hero then --决斗
                for _, v in ipairs(user.towerInfo.hero) do
                    if tostring(v.csn) == h.sn then
                        th = v
                        break
                    end

                end
            else
                i.hp.text = tostring(h.MaxHP)
                i.sp.text = tostring(h.MaxSP)
                i.tp.text = tostring(h.MaxTP) 
            end
        end

        i.str.color = h.kind == 1 and i.str.effectColor or Color.white
        i.wis.color = h.kind == 2 and i.str.effectColor or Color.white
        i.cap.color = h.kind == 3 and i.str.effectColor or Color.white
    else
        i.name.text = nil
        i.lv.text = nil
        i.ttl.text = nil
        i.str.text = nil
        i.wis.text = nil
        i.cap.text = nil
        i.hp.text = nil
        i.sp.text = nil
        i.tp.text = nil
        i.rare.text = nil
    end
end

function _item.Init(i, hero, purpose)
    i.purpose = purpose
    i.hero = DataCell.DataChange(i.hero, hero, i)
    UpdateHeroInfo(i)
end

function _item.OnDataChange(i, d) UpdateHeroInfo(i) end

function _item.alive(i) return not CheckDead(i) end

function _item.OnDestroy(i)
    i.hero = DataCell.DataChange(i.hero, nil, i)
end

_item.__get = 
{
    Selected = function(i) return i.bg.activeSelf end,

    IsTowerDead = function(i) return i.purpose == SelectHeroFor.Tower and i.hp.color == Color.red end,
}
_item.__set = 
{
    Selected =  function(i, v) 
                    if v then
                        i.bg.gameObject:SetActive(true)
                        i.unbg.gameObject:SetActive(false)
                    else
                        i.bg.gameObject:SetActive(false)
                        i.unbg.gameObject:SetActive(true)
                    end
                end
}

--继承
objext(_item, Item)
--[Comment]
--通用ItemHero
ItemHero = _item