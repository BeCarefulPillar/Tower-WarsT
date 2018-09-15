require "LENV"

--update.json
local cfg = kjson.decode(GM.config)

Game = { }

function Game.Start(debug)
    -- 创建ToolTip
    ToolTip.Create()
    -- debug标签
    isDebug = debug
    
    if Game.needUpdate then return end

--    TestCalcBattle()

    if DB.isLoaded then
        Game.StartDone()
    else
        DB.Load()
    end
end

function Game.StartDone()
    if Scene.isEntry then Scene.Load(SCENE.LOGIN) end
end

--function Game.OnSceneLoaded(scene)

--end

--function Game.HandleError(msg, code)

--end

--function Game.OnPause(pause)

--end

--function Game.OnQuit()

--end

function Game.OnTimeout(p)

end

--创建实例表
function CreateTable(metatable)
    if metatable then
        if isClass(metatable) then
            return metatable()
        end
        local t = {}
        setmetatable(t, { __index = metatable })
        if t.Init then t:Init() end
        return t
    else
        return nil
    end
end

--执行语句
function DoString(chunk, nm)
    if chunk and nm then
        chunk = loadstring(chunk, nm)
        if chunk then chunk() end
    end
end

------------------渠道配置及版本更新------------------
--更新操作
local function ClientUpdate(btn)
    if btn == 0 then
        if isADR and lv ~= "4" and GM.instance then
            local go = GM.instance.AddChild(AM.LoadPrefab("ClientUpdate"));
            if tolua.isnull(go) then
                APP.OpenURL(url)
            end
        else
            APP.OpenURL(url)
        end
    elseif lv == "1" then
        APP.Quit()
    else
        APP.OpenURL(url)
    end

    if lv == "4" then DB.Load() end
end
-- 版本更新检测
local function ClientCheck()
    if cfg then
        cfg = cfg["C" .. SDK.cid] or cfg["C" .. DEF_CID]
        local c = cfg["F" .. SDK.fid] or cfg[ENV.BundleIdentifier]
        if c then table.copy(c, cfg) end
        Game.cfg = cfg
        c = ENV.BundleVersion
        if string.verCheck(cfg.v, c) then
            local lv, msg = cfg.lv, nil
            if lv and lv ~= "" and string.verCheck(lv, c) then
                lv, msg = cfg.lm, cfg.li
            else
                lv, msg = cfg.m, cfg.i
            end
            if msg == "" then msg = nil end
            if "0" == lv then
                MsgBox.Show(msg or L("客户端有新版本。是否更新"), ClientUpdate);
            elseif "1" == lv then
                MsgBox.Show(msg or L("客户端有新版本。必须更新才能继续游戏"), L("更新") .. "," .. L("退出"), ClientUpdate);
            elseif "2" == lv then
                MsgBox.Show(msg or L("客户端有新版本。必须更新才能继续游戏"), L("自动更新") .. "," .. L("手动更新"), ClientUpdate);
            elseif "3" == lv then
                MsgBox.Show(msg or L("客户端有新版本。必须更新才能继续游戏"), L("自动更新") .. "," .. L("手动更新"), ClientUpdate);
            elseif "4" == lv then
                MsgBox.Show(msg or L("主公，发现新版本可更新，若不更新仍可继续游戏，但新功能将无法使用，为保证游戏体验请尽快更新"), L("查看") .. "," .. L("继续"), ClientUpdate);
            elseif "5" == lv then
                MsgBox.Show(msg or L("主公，发现新版本可更新，若不更新仍可继续游戏，但新功能将无法使用，为保证游戏体验请尽快更新"));
                return
            elseif "6" == lv then
                return
            else
                MsgBox.Wait(msg or L("游戏正在更新维护，请稍候再进入游戏"));
            end
            Game.needUpdate = true
        end
    end
end
--版本更新检测
CS.RunOnMainThread(ClientCheck)
if Game.needUpdate then return end
--线程先加载数据
DB.Load()