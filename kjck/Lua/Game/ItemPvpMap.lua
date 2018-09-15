
local isnull = tolua.isnull

local _item =
{
    --[Comment]
    --ItemGoods的根对象
    go = nil,
    --[Comment]
    --地图
    bg = nil,

    --[Comment]
    --城池
    items = nil,
    --[Comment]
    --区块号
    zone = nil,

    --[Comment]
    --节点位置
    nodes = nil,
    --[Comment]
    --城池节点
    cityNodes = nil,
    --[Comment]
    --路径
    paths = nil,

    --[Comment]
    --初始化参数
    intArg = nil,
}

local function OnLoadData(i, datas)
    if i == nil or i.go == nil or isnull(i.go) then return end
    local tmp = { }
    local pfb = PvpMap.pfbCity
    local item = nil
    local pos = nil
    for k = 1, #datas do
        if not isnull(i.go) then
            item = i.go:AddChild(pfb, "city_"..tostring(datas[k].pos))
            item:GetCmp(typeof(LuaButton)).param = i
            item:SetActive(true)
            item = ItemPvpCity(item)
            item:Init(i, datas[k])
            item.node = -1
            for j = 1, #i.cityNodes do
                if i.cityNodes[j][2] == datas[k].pos then
                    item.node = i.cityNodes[j][1]
                    pos = Vector3(i.nodes[item.node][1], i.nodes[item.node][2], 0)
                    item.go.transform.localPosition = pos
                    break
                end
            end
            tmp[item.go] = item
            if item.node < 0 then item.go:SetActive(false) end
            coroutine.wait(0.05)
        else
            if tmp ~= nil then
                for e, v in pairs(tmp) do
                    if not isnull(e) then Destroy(e) end
                end
                tmp = nil
            end
        end
    end
    i.items = tmp
end

local function LoadData(i, isr)
    if isr and user.PvpZoneNeedUpdata(i.zone) then SVR.GetPvpZone(i.zone)
    else
        local tmp = i.items
        if tmp ~= nil then
             for k, v in pairs(tmp) do if k ~= nil then Destroy(k) tmp[k] = nil end end
             i.items = nil
        end
        tmp = user.GetZonePvpCity(i.zone)
        if #tmp > 0 then coroutine.start(OnLoadData, i, tmp) end
    end
end
--[Comment]
--构造
function _item.New(go)
    assert(not isnull(go), "create ItemCity need GameObject")
    return
    {
        go = go,
        bg = go:GetCmp(typeof(UITexture)),
    }
end

--[Comment]
--初始化
function _item.Init(i, zone, info, tex)
    if i == nil or info == nil or zone <= 0 then return end
    i.zone = zone
    i.nodes = info.node
    i.cityNodes = info.city
    i.paths = info.path
    i.bg.mainTexture = tex
    LoadData(i, true)
end
_item.LoadData = LoadData

--[Comment]
-- 获取节点相对坐标
function _item.GetNodePos(i, nd)
    return i.go.transform.localPosition + Vector3(i.nodes[nd][1], i.nodes[nd][2], 0)
end
--[Comment].
-- 获取节点世界坐标
function _item.GetNodeWorldPos(i, nd)
    i.go.transform.TransformPoint(Vector3(i.nodes[nd][1], i.nodes[nd][2], 0))
end

_item.OnDispose = Dispose

--属性 读
_item.__get =
{
    Zone = function (i) return i.zone end,
    Nodes = function (i) return i.nodes end,
    CityNodes = function (i) return i.cityNodes end,
    Paths  = function (i) return i.Paths end,
    Cities = function (i) return i.items end,
}

--继承
objext(_item, Item)
--[Comment]
--通用Item
ItemPvpMap = _item
