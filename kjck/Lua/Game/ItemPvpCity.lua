

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
    --数据对象
    dat = nil,
    --[Comment]
    --地图数据
    map = nil,
    --[Comment]
    --节点号
    node = nil,
    --[Comment]
    --初始化参数
    intArg = nil,

    --[Comment]
    --旗帜
    flag = nil,
    --[Comment]
    --联盟旗帜
    af = nil,
    --[Comment]
    --道具旗帜
    pf = nil,
    --[Comment]
    --BUF 特效
    ef_buf = nil,
    --[Comment]
    --新道具动画
    newPro = nil,

    --[Comment]
    -- 删除回调
    onDes = nil
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
--释放
local function Dispose(i)
    i.dat = DataCell.DataChange(i.dat, nil, i)
end

--[Comment]
--构造
function _item.New(go)
    assert(not tolua.isnull(go), "create ItemCity need GameObject")
    return
    {
        go = go,
        city = go.widget,
        bsp = go:ChildWidget("bg_name"),
        cnm = go:ChildWidget("name"),
    }
end

--[Comment]
--初始化
function _item.Init(i, map, dat)
    if CheckDead(i) then return end
    Dispose(i)
    i.map = map
    i.dat = DataCell.DataChange(i.dat, dat, i)

    i.cnm.text = dat.nm
    i.bsp.color = dat.IsOwn and Color(0.353, 0.902, 1, 1) or (dat.IsMyColony and Color(0.784, 1, 0.251, 1) or Color(1, 0.392, 0.392, 1))
    i.bsp.width = math.ceil((i.cnm.printedSize.x + i.cnm.fontSize) * i.cnm.cachedTransform.localScale.x)
    -- 显示城池类型
    local tmp = nil
    local tmp1 = nil
    if dat.kind == 0 then
        if dat.ttl == 9 then i.city.spriteName = "city_c_1"
        elseif dat.ttl > 0 then i.city.spriteName = "city_c_2"
        else
            tmp = dat.lv
            local dl = DB.maxHlv / 10
            local dl1 = dl - (dl % 1)
            dl1 = dl1 > 0 and dl1 or tmp
            while tmp > 0 do
                tmp1 = "city_1_"..math.ceil(tmp / dl)
                tmp = tmp - dl1
                if i.city.atlas:GetSprite(tmp1) ~= nil then
                    i.city.spriteName = tmp1
                    break
                end
            end
        end
    else i.city.spriteName = "city_res_"..dat.kind
    end
    i.city:MakePixelPerfect()
    -- 更新旗帜
    if dat.allyFlag > 0 then
        if i.flag ~= nil then Destroy(i.flag.cachedGameObject) i.flag = nil end
        tmp = i.af
        if tmp == nil then
            tmp = i.go:AddChild(AM.LoadPrefab("flag_ally"), "flag")
            tmp.transform.localScale = Vector3.one * 0.5
            tmp.transform.localPosition = Vector3(32, 85, 0)
            EF.BindWidgetColor(tmp, i.city)
            tmp = tmp:GetCmp(typeof(UICloth))
        end
        tmp.Str = "flag_ally_"..dat.allyFlag
        tmp1 = Mathf.Random(0.8, 1)
        tmp.playScale = tmp1
        i.af = tmp
        tmp = tmp:GetCmpInChilds(typeof(UICloth), false)
        tmp.Str = dat.allyBanner
        tmp.playScale = tmp1
    else
        if i.af ~= nil then Destroy(i.af.gameObject) i.af = nil end
        if dat.kind == 0 then
            tmp = i.flag
            if tmp == nil then
                tmp =i.go:AddWidget(typeof(UISprite), "flag")
                tmp.atlas = i.city.atlas
                tmp.spriteName = "flag_p_01"
                tmp.depth, tmp.width, tmp.height = 4, 52, 52
                tmp.cachedTransform.localPosition = Vector3(42, 37, 0)
                EF.BindWidgetColor(tmp, i.city)
                i.flag = tmp
                tmp = tmp:AddCmp(typeof(UISpriteAnimation))
                tmp.namePrefix = "flag_p_"
                tmp.pixelPerfect = true
                tmp.loop = true
                tmp.framesPerSecond = 5
            end
        elseif i.flag ~= nil then Destroy(i.flag.gameObject) i.flag = nil
        end
    end
    --道具插旗文本
    if dat.ppFlag == nil or dat.ppFlag == "" then
        if i.pf ~= nil then Destroy(i.pf.cachedGameObject) i.pf = nil end
    else
        tmp = i.pf
        if tmp == nil then
            tmp = i.go:AddChild(AM.LoadPrefab("flag_ally"), "props_flag")
            tmp.transform.localScale = Vector3.one * 0.5
            tmp.transform.localPosition = Vector3(-20, 85, 0)
            EF.BindWidgetColor(tmp, i.city)
            tmp.Str = "flag_props"
            tmp.cachedGameObject:AddChild(AM.LoadPrefab("ef_flag"), "ef_flag")
            i.pf = tmp
        end
        tmp = tmp:GetCmpInChilds(typeof(UICloth), false)
        tmp.Str = dat.ppFlag
    end
    -- 显示道具特效
    if dat.HasBuff then
        tmp = i.ef_buf
        if tmp == nil then
            tmp = i.go:AddChild(AM.LoadPrefab("ef_city_buf"), "ef_city_buf", false)
            EF.BindWidgetColor(tmp, i.city)
            if dat.kind ~= 0 then tmp.transform.localPosition = Vector3(0, -8, 0) end
            i.ef_buf = tmp
        end
    elseif i.ef_buf ~= nil then Destroy(i.ef_buf) i.ef_buf = nil
    end
end

--[Comment]
--DataCell是否存活接口
function _item.alive(i) return not CheckDead(i) end
--[Comment]
--DataCell数据更改接口
function _item.OnDataChange(i, d) _item.Init(i, i.map, i.dat) end

--[Comment]
--销毁时
function _item.OnDestroy(i)
    CheckDead(i)
    if i.onDes ~= nil then i:onDes() end
    if i.dat and i.dat.RemoveObserver then i.dat:RemoveObserver(i) end
end

_item.OnDispose = Dispose

--属性 读
_item.__get =
{
    Map = function (i) return i.map end,
    Data = function (i) return i.dat end,
}

--继承
objext(_item, Item)
--[Comment]
--通用Item
ItemPvpCity = _item
