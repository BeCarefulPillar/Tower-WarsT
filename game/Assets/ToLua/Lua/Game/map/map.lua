--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local _item = {
    mapName = "first",
    --二维数字，地图坐标
    mapArrat = {{}},
    mapRow,
    mapLow,
}

function _item.init(i)
    i.mapArrat ={{1,1,1,1,1,1},
                 {1,1,1,1,1,1},
                 {1,1,1,1,1,1},
                 {1,1,1,1,1,1},
                 {1,1,1,1,1,1}}
    
    

end

class(_item)
Map = _item

--endregion
