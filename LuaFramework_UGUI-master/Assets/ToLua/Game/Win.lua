local _G = _G
local _panelMgr = LuaHelper.GetPanelManager()

Win = {}

local _ONLOAD = "OnLoad"

local _wins = {}

---<summary>打开指定名称的窗口</summary>
function Win.Open(nm, arg)
    local tmp = _G[nm]
    if not tmp then
        require(nm)
        tmp = _G[nm]
        assert(tmp,"窗口"..nm.."不存在")
    end
    tmp.initObj = arg
    _panelMgr:CreatePanel(nm,function(go)
        if tmp[_ONLOAD] then
            tmp[_ONLOAD](go)
            tmp.go = go
            _wins[nm] = tmp
        end
    end)
    return tmp
end

function Win.Close(nm)
    if _wins[nm] then
        UnityEngine.Object.Destroy(_wins[nm].go)
        _wins[nm] = nil
    end
end