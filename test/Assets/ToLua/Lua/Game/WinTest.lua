require "typeof"


local AssetBundle = UnityEngine.AssetBundle
local GameObject = UnityEngine.GameObject
local Resources = UnityEngine.Resources


local w = {}
local body = nil

local shared = nil
local loader = nil

local function OnLoad()
    local req = loader:LoadPrefabAsync("WinPrompt")
    while not req.isDone do
        print(req.progress)
        coroutine.step()
    end
        print(req.progress)
end

function w.OnLoad(c)
    body = c
    loader = c:GetCmp(typeof(LuaAssetLoader))

    c:BindFunction("Click","DoubleClick")

    local t = c:AddChild(loader:LoadPrefab("GUI")):Child("Camera")

--    shared = AssetBundle.LoadFromFile("c:/test/dialog.unity3d")
--    shared:LoadAsset("Dialog",typeof(GameObject))

--    coroutine.start(OnLoad)

--    local ui = t:AddChild(loader:LoadPrefab("WinPrompt")):GetCmp(typeof(LuaRef)).ref
--    print(LuaButton)

--    local btn = nil
--    for i=1,30 do
--        btn = ui.grid:AddChild(ui.item, string.format("item_%03d",i))
--        btn:SetActive(true)
--        btn = btn:GetCmp(typeof(LuaButton))
--        btn.luaContainer = body
--        btn.param = i
--    end
end

function w.Click(p)
    print("Click" .. p)
end

function w.DoubleClick(p)
    print("DoubleClick" .. p)
end

function w.OnUnLoad(c)
    if shared then
        shared:Unload(true)
        print("hh")
    end
end

WinTest = w