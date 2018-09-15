#if TOLUA
using System.Collections;
using UnityEngine;
using LuaInterface;
using System;

public partial class Scene : LuaContainer
{
    #region 组件
    private void Start()
    {
        if (NoTable)
        {
            mLoadingProgress = 1f;
        }
        else
        {
            CallFunction("Start");
        }
    }
    #endregion

    #region Lua注册
    public new static void Register(LuaState L)
    {
        L.BeginClass(typeof(Scene), typeof(LuaContainer));
        L.RegFunction("CurrentIs", CurrentIs);
        L.RegFunction("IsLoaded", IsLoaded);
        L.RegFunction("Load", LoadScene);
        L.RegFunction("OpenWin", OpenWin);
        L.RegFunction("GetWin", GetWin);
        L.RegFunction("GetActiveWin", GetActiveWin);
        L.RegFunction("GetWins", GetWins);
        L.RegFunction("ExitWin", ExitWin);
        L.RegFunction("ExitBackWin", ExitBackWin);
        L.RegFunction("ExitMutexWin", ExitMutexWin);
        L.RegFunction("ExitAllWin", ExitAllWin);
        L.RegFunction("CheckWinLayer", CheckWinLayer);
        L.RegFunction("Invoke", Invoke);
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegVar("current", get_current, null);
        L.RegVar("isEntry", get_isEntry, null);
        L.RegVar("isTransition", get_isTransition, null);
        L.RegVar("loadingProgress", get_loadingProgress, set_loadingProgress);
        L.RegVar("focusWin", get_focusWin, set_focusWin);
        L.RegVar("depthStart", get_depthStart, set_depthStart);
        L.RegVar("depthBack", get_depthBack, set_depthBack);
        L.RegVar("depthSpace", get_depthSpace, set_depthSpace);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CurrentIs(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, SceneManager.CurrentIs(ToLua.CheckString(L, 1)));
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsLoaded(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, SceneManager.IsLoaded(ToLua.CheckString(L, 1)));
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LoadScene(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if(count == 1)
            {
                SceneManager.LoadScene(ToLua.CheckString(L, 1)); return 0;
            }
            if (count == 2)
            {
                SceneManager.LoadScene(ToLua.CheckString(L, 1), (float)LuaDLL.luaL_checknumber(L, 2)); return 0;
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.LoadScene");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int OpenWin(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count > 0)
            {
                if (TypeChecker.CheckType(L, typeof(Scene), 1))
                {
                    if (count == 2)
                    {
                        ToLua.Push(L, (ToLua.ToObject(L, 1) as Scene).OpenWin(ToLua.CheckString(L, 2))); return 1;
                    }
                    else if (count == 3)
                    {
                        ToLua.Push(L, (ToLua.ToObject(L, 1) as Scene).OpenWin(ToLua.CheckString(L, 2), ToLua.ToVarObject(L, 3))); return 1;
                    }
                }
                else if (SceneManager.current)
                {
                    if (count == 1)
                    {
                        ToLua.Push(L, SceneManager.current.OpenWin(ToLua.CheckString(L, 1))); return 1;
                    }
                    if (count == 2)
                    {
                        ToLua.Push(L, SceneManager.current.OpenWin(ToLua.CheckString(L, 1), ToLua.ToVarObject(L, 2))); return 1;
                    }
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
                }
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.OpenWin");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetWin(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 1)
            {
                if (SceneManager.current)
                {
                    ToLua.Push(L, SceneManager.current.GetWin(ToLua.CheckString(L, 1))); return 1;
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
                }
            }
            else if (count == 2 && TypeChecker.CheckType(L, typeof(Scene), 1))
            {
                ToLua.Push(L, (ToLua.ToObject(L, 1) as Scene).GetWin(ToLua.CheckString(L, 2))); return 1;
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.GetWin");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetActiveWin(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 1)
            {
                if (SceneManager.current)
                {
                    ToLua.Push(L, SceneManager.current.GetActiveWin(ToLua.CheckString(L, 1))); return 1;
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
                }
            }
            else if (count == 2 && TypeChecker.CheckType(L, typeof(Scene), 1))
            {
                ToLua.Push(L, (ToLua.ToObject(L, 1) as Scene).GetActiveWin(ToLua.CheckString(L, 2))); return 1;
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.GetActiveWin");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetWins(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count > 0)
            {
                if (TypeChecker.CheckType(L, typeof(Scene), 1))
                {
                    if (count == 1)
                    {
                        ToLua.Push(L, (ToLua.ToObject(L, 1) as Scene).GetWins()); return 1;
                    }
                    else if (count == 2)
                    {
                        ToLua.Push(L, (ToLua.ToObject(L, 1) as Scene).GetWins(LuaDLL.luaL_checkboolean(L, 2))); return 1;
                    }
                }
                else if (SceneManager.current)
                {
                    if (count == 0)
                    {
                        ToLua.Push(L, SceneManager.current.GetWins()); return 1;
                    }
                    if (count == 1)
                    {
                        ToLua.Push(L, SceneManager.current.GetWins(LuaDLL.luaL_checkboolean(L, 1))); return 1;
                    }
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
                }
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.GetWins");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ExitWin(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count >= 1 && TypeChecker.CheckType(L, typeof(Scene), 1))
            {
                if (count == 1)
                {
                    (ToLua.CheckObject<Scene>(L, 1) as Scene).ExitWin(); return 0;
                }
                if (count == 2)
                {
                    (ToLua.CheckObject<Scene>(L, 1) as Scene).ExitWin(LuaDLL.luaL_checkboolean(L, 2)); return 0;
                }
            }
            else if (SceneManager.current)
            {
                if (count == 0)
                {
                    SceneManager.current.ExitWin(); return 0;
                }
                if (count == 1)
                {
                    SceneManager.current.ExitWin(LuaDLL.luaL_checkboolean(L, 1)); return 0;
                }
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.ExitWin");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ExitBackWin(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count >= 1 && TypeChecker.CheckType(L, typeof(Scene), 1))
            {
                if (count == 1)
                {
                    (ToLua.CheckObject<Scene>(L, 1) as Scene).ExitBackWin(); return 0;
                }
                if (count == 2)
                {
                    (ToLua.CheckObject<Scene>(L, 1) as Scene).ExitBackWin(LuaDLL.luaL_checkboolean(L, 2)); return 0;
                }
            }
            else if (SceneManager.current)
            {
                if (count == 0)
                {
                    SceneManager.current.ExitBackWin(); return 0;
                }
                if (count == 1)
                {
                    SceneManager.current.ExitBackWin(LuaDLL.luaL_checkboolean(L, 1)); return 0;
                }
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.ExitBackWin");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ExitMutexWin(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 1)
            {
                if (SceneManager.current)
                {
                    SceneManager.current.ExitMutexWin((int)LuaDLL.luaL_checknumber(L, 1)); return 0;
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
                }
            }
            else if (count == 2)
            {
                (ToLua.CheckObject<Scene>(L, 1) as Scene).ExitMutexWin((int)LuaDLL.luaL_checknumber(L, 2)); return 0;
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.ExitMutexWin");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ExitAllWin(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 1)
            {
                (ToLua.CheckObject<Scene>(L, 1) as Scene).ExitAllWin(); return 0;
            }
            if (SceneManager.current)
            {
                SceneManager.current.ExitAllWin(); return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CheckWinLayer(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count >= 1 && TypeChecker.CheckType(L, typeof(Scene), 1))
            {
                if (count == 1)
                {
                    (ToLua.CheckObject<Scene>(L, 1) as Scene).CheckWinLayer(); return 0;
                }
                if (count == 2)
                {
                    (ToLua.CheckObject<Scene>(L, 1) as Scene).CheckWinLayer(LuaDLL.luaL_checkboolean(L, 2)); return 0;
                }
                if (count == 3)
                {
                    (ToLua.CheckObject<Scene>(L, 1) as Scene).CheckWinLayer(LuaDLL.luaL_checkboolean(L, 2), LuaDLL.luaL_checkboolean(L, 3)); return 0;
                }
            }
            else if (SceneManager.current)
            {
                if (count == 0)
                {
                    SceneManager.current.CheckWinLayer(); return 0;
                }
                if (count == 1)
                {
                    SceneManager.current.CheckWinLayer(LuaDLL.luaL_checkboolean(L, 1)); return 0;
                }
                if (count == 2)
                {
                    SceneManager.current.CheckWinLayer(LuaDLL.luaL_checkboolean(L, 1), LuaDLL.luaL_checkboolean(L, 2)); return 0;
                }
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.CheckWinLayer");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Invoke(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if(count >= 3)
            {
                Scene scene = ToLua.CheckObject<Scene>(L, 1) as Scene;
                if (scene)
                {
                    float delay = (float)LuaDLL.luaL_checknumber(L, 3);
                    LuaTypes luaType = LuaDLL.lua_type(L, 2);
                    switch (luaType)
                    {
                        case LuaTypes.LUA_TSTRING: scene.Invoke(LuaDLL.lua_tostring(L, 2), delay); return 0;
                        case LuaTypes.LUA_TUSERDATA:
                            object obj = ToLua.ToObject(L, 2);
                            if (obj is string) { scene.Invoke(ToLua.ToObject(L, 2) as string, delay); return 0; }
                            break;
                        case LuaTypes.LUA_TFUNCTION:
                            LuaFunction luaFunc = ToLua.ToLuaFunction(L, 2);
                            if (count > 3)
                            {
                                object[] args = new object[count - 3];
                                for (int i = 4; i <= count; i++) args[i - 4] = ToLua.ToVarObject(L, i);
                                scene.Invoke(luaFunc, delay, args);
                            }
                            else
                            {
                                scene.Invoke(luaFunc, delay); 
                            }
                            return 0;
                        default: break;
                    }
                }
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.Invoke");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_current(IntPtr L)
    {
        try
        {
            ToLua.Push(L, SceneManager.current);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isEntry(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, SceneManager.isEntry);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isTransition(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, SceneManager.isTransition);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_loadingProgress(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (ToLua.CheckObject<Scene>(L, 1) as Scene).loadingProgress);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_loadingProgress(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Scene>(L, 1) as Scene).mLoadingProgress = (float)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_focusWin(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Scene>(L, 1) as Scene).focusWin);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_focusWin(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Scene>(L, 1) as Scene).focusWin = ToLua.CheckObject<Win>(L, 2) as Win;
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_depthStart(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (ToLua.CheckObject<Scene>(L, 1) as Scene).depthStart);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_depthStart(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Scene>(L, 1) as Scene).depthStart = (int)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_depthBack(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (ToLua.CheckObject<Scene>(L, 1) as Scene).depthBack);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_depthBack(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Scene>(L, 1) as Scene).depthBack = (int)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_depthSpace(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (ToLua.CheckObject<Scene>(L, 1) as Scene).depthSpace);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_depthSpace(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Scene>(L, 1) as Scene).depthSpace = (int)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int op_Equality(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
            UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
            bool o = arg0 == arg1;
            LuaDLL.lua_pushboolean(L, o);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion
}
#endif