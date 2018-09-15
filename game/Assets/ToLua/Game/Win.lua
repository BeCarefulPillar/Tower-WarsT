local _G = _G
local _panelMgr = LuaHelper.GetPanelManager()

Win = {}

local _wins = {}

---<summary>打开指定名称的窗口</summary>
function Win.Open(nm, arg)
    local tmp = _G[nm]
    if not tmp then
    print(nm)
        require(nm)
        tmp = _G[nm]
        print(tmp)
        assert(tmp,"窗口"..nm.."不存在")
    end
    tmp.initObj = arg
    _panelMgr:CreatePanel(nm,function(go)
        _wins[nm] = tmp
        _wins[nm].go = go
    end)
    return tmp
end

---<summary>关闭指定名称的窗口</summary>
function Win.Close(nm)
    if _wins[nm] then
        _panelMgr:ClosePanel(nm)
        _wins[nm].go = nil
        _wins[nm] = nil
    end
end