--精简全局对象名称
UE = UnityEngine
String = System.String
DT = System.DateTime
APP = UE.Application
AM = AssetManager
GameObject = UE.GameObject
Destroy = UE.Object.Destroy
Input = UE.Input
SFSObject = Sfs2X.Entities.Data.SFSObject
MB = UE.MonoBehaviour

--全局变量
isDebug = false
isADR = false
isIOS = false

-- 检测平台
local platform = tostring(APP.platform)
if platform == "Android" then isADR = true
elseif platform == "IPhonePlayer" then isIOS = true end

-- 组件加载
json = require("cjson")
require "Util/extend"
require "Util/kjson"
require "Data/Const"
require "Data/Config"
require "Util/Invoke"
require "Util/Tools"
--require "Util/ResName"
require "Util/TimeClock"
require "Util/ColorStyle"
require "Util/NameStyle"
require "Util/WordFilter"
require "Util/ExtAtt"
require "Util/ToolTip"
require "Util/NGUIMath"
require "Util/NGUIText"
require "core"
require "class"
require "cfg"
require "Lang/L"
require "Data/Reward"
require "Data/DB"
require "Data/GD"
reimport "SDK"
require "SVR"
require "Data/DB_Rule" 
require "Data/DB_Help" 
require "Util/ResName"
require "Game/WinExt"
--放SceneGame中加载
--require "Game/NewEffect"
--require "Game/UnLockEffect"
--require "Game/ItemGoods"
--require "Game/ItemSign"
--require "Game/ItemHero"
--require "Game/ItemCity"
--require "Game/ItemPvpMap"
--require "Game/ItemPvpCity"
require "Game/ItemChat"
require "Data/affair"
require "Data/LuaRes"
require "Game/WinBackground"
require "Battle/Data/QYBattle"
require "Game/Guide"
require "Game/LuaActTimer"
require "Game/PopBuyProps"
require "Game/FillScreen"

--常用方法
local _notnull = CS.NotNull
local _isnull = tolua.isnull
--[Comment]
--检测Unity对象是否非空
function notnull(o) return o and _notnull(o) end
--[Comment]
--检测Unity对象是否为空
function isnull(o) return o == nil or _isnull(o) end

--[Comment]
--外部资源树
ResTree = kjson.decode(File.ReadCEText(AM.resPath .. "index.dat"))