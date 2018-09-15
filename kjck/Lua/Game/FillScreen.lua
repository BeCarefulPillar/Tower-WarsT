local Screen = UnityEngine.Screen
local Camera = UnityEngine.Camera

FillScreen = { }

FillPlace = { NotInit=0, None=1, Horizontal=2, Vertical=3 }

local _screenUtx = nil
local _screen = nil
local _place = FillPlace.NotInit
local _zoom = nil

--[Comment]
--初始化
local function InitFill()
    local m = math.modf(100000 * SCREEN.WIDTH / SCREEN.HEIGHT)
    local s = math.modf(100000 * Screen.width / Screen.height)
    if m > s then
        --垂直填充上下
        _place = FillPlace.Vertical
        _zoom = Screen.width / SCREEN.WIDTH
    elseif m < s then
        --水平填充左右
        _place = FillPlace.Horizontal
        _zoom = Screen.height / SCREEN.HEIGHT
    else
        --不填充
        _place = FillPlace.None
        _zoom = Screen.height / SCREEN.HEIGHT
    end
end

--[Comment]
--最终游戏缩放比例
function FillScreen.getZoom()
    if _place==FillPlace.NotInit then
        InitFill()
    end
    return _zoom
end

--[Comment]
--屏幕边框填充方位
function FillScreen.getPlace()
    if _place == FillPlace.NotInit then
        InitFill()
    end
    return _place
end

--[[
function FillScreen.setPlace()
end
]]

--[Comment]
--游戏显示的屏幕像素矩形
function FillScreen.getScreenRect()
    if FillScreen.getPlace() == FillPlace.Horizontal then
        local w = SCREEN.WIDTH * _zoom / Camera.main.pixelWidth
        return Rect((1 - w) * 0.5, 0, w, 1)
    else
        local h = SCREEN.HEIGHT * _zoom / Camera.main.pixelHeight
        return Rect(0,(1 - h) * 0.5, 1, h)
    end
end

--[[
function FillScreen.setScreenRect()
end
]]

function FillScreen.CaptureScrennTexture(utx, cam, setWH)
    if utx then
        if not _screen then
            _screen = UE.RenderTexture(Screen.width, Screen.height, 0)
        end
        cam.targetTexture = _screen
        cam:Render()
        cam.targetTexture = nil
        _screenUtx = utx
        utx.mainTexture = _screen
        utx.uvRect = FillScreen.getScreenRect()
        if setWH then
            utx.width = SCREEN.WIDTH
            utx.height = SCREEN.HEIGHT
        end
    end
end

function FillScreen.ReleaseScrennTexture(utx)
    if _screen and (not _screenUtx or utx == _screenUtx) then
        _screenUtx = nil
        _screen:DiscardContents()
        _screen:Release()
        Destroy(_screen)
        _screen = nil
    end
end