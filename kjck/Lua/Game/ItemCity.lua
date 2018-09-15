local type = type
local isnull = tolua.isnull

local _item =
{
    --[Comment]
    --ItemGoods的根对象
    go = nil,
    --[Comment]
    --城池
    city = nil,
    --[Comment]
    --背景图标
    bsp = nil,
    --[Comment]
    --名称Label
    cnm = nil,
    --[Comment]
    --城池编号   大关卡-小关卡
    cityNum = nil,

    --[Comment]
    --数据对象
    dat = nil,
    --[Comment]
    --DB 数据
    db = nil,
    --[Comment]
    --节点号
    node = nil,
    --[Comment]
    --初始化参数
    intArg = nil,

    --[Comment]
    --可攻打指向提示
    arrow = nil,
}

--[Comment]
--检测对象是否存活
local function CheckDead(i)
    if isnull(i.go) then
        if i.go then
            i.go = nil
            if i.dat and i.dat.RemoveObserver then i.dat:RemoveObserver(i) end
            table.clear(i)
        end
        return true
    end
end

--[Comment]
--释放(ef=保留特效)
local function Dispose(i)
    i.dat = DataCell.DataChange(i.dat, nil, i)
end

--[Comment]
--构造
function _item.New(go)
    assert(not isnull(go), "create ItemCity need GameObject")
    return
    {
        go = go,
        city = go.widget,
        bsp = go:ChildWidget("bg_name"),
        cnm = go:ChildWidget("name"),
        cityNum = go:ChildWidget("num"),
    }
end

--[Comment]
--初始化
function _item.Init(i, sn)
    if CheckDead(i) then return end
    if sn <= 0 then
        i.dat = nil
        i.cnm.text = ""
        return
    end

    Dispose(i)

    i.db = DB.GetGmCity(sn)
    i.dat = DataCell.DataChange(i.dat, user.GetPveCity(sn), i)
    local tmp1 = i.Level
    local tmp2 = i.db.img
    local tmp3 = nil
    --设置城池图片
    i.city.spriteName = "city_2_"..tmp2
    --snap
    i.city:MakePixelPerfect()

    tmp2 = i.db
    tmp3 = i.dat

    --城池颜色
    i.city.color = i.IsOwn and Color(0.5, 0.5, 0.5, 1) or Color(0.5, 0, 0.5, 1)

    --城池名字
    i.cnm.text = tmp2.nm
    --城池编号
    i.cityNum.text = tmp2.main.."-"..(((tmp2.sn - 1) % 10) == 0 and 10 or ((tmp2.sn - 1) % 10))

    --可攻打提示
    if sn == user.gmMaxCity + 1 then
        tmp1 = i.arrow
        if tmp1 == nil then
            tmp1 = i.go:AddChild(AM.LoadPrefab("ef_ui_cityTip"),"ef_arrow")
            tmp1.transform.localPosition = Vector3.zero
            i.arrow = tmp1
        end
    else
        if i.arrow ~= nil then
            Destroy(i.arrow.gameObject)
            i.tag = nil
        end
    end
end

--[Comment]
--DataCell是否存活接口
function _item.alive(i) return not CheckDead(i) end
--[Comment]
--DataCell数据更改接口
function _item.OnDataChange(i, d) _item.Init(i, i.sn) end

--[Comment]
--销毁时
_item.OnDispose = CheckDead

--属性 读
_item.__get =
{
    sn = function (i) return i.db.sn end,
    IsOwn = function (i) return i.dat ~= nil end,
    Level = function (i) return i.IsOwn and i.dat.lv or DB.lv end,
    --帝国不看助手将领数量
--    HeroCount = function (i) return i.IsOwn and i.dat.heroQty or (i.npc and #i.npc or 0) end,
    Name = function (i) return i.cnm.text end,
    BtnChest = function (i) return i.btn_cst end,
}
--属性 写
_item.__set =
{
--帝国不看助手将领数量
--    HeroCount = function (i, v)
--        if i.IsOwn then
--            i.dat.heroQty = v
--            i.bsp.color = v > 0 and Color(0.35, 0.9, 1, 1) or Color(1, 1, 1, 1)
--        end
--    end,
    Level = function (i, v) if i.IsOwn then i.dat.lv = v end end,
    BtnChest = function (i, v) i.btn_cst = v end
}

--继承
objext(_item, Item)
--[Comment]
--通用Item
ItemCity = _item
