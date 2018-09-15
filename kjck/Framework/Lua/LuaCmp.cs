#if TOLUA
using UnityEngine;
using LuaInterface;

public class LuaCmp : MonoBehaviour
{
    private static LuaFunction _Start = null;
    private static LuaFunction _OnEnable = null;
    private static LuaFunction _OnDisable = null;
    private static LuaFunction _OnDestroy = null;

    [SerializeField] public bool start = false;
    [SerializeField] public bool onEnable = false;
    [SerializeField] public bool onDisable = false;
    [SerializeField] public bool onDestroy = false;

    private GameObject mGo;

    private void Start()
    {
        mGo = gameObject;
        if (start && _Start != null && _Start.IsAlive) _Start.Call(mGo);
    }

    private void OnEnable()
    {
        if (onEnable && _OnEnable != null && _OnEnable.IsAlive) _OnEnable.Call(mGo);
    }

    private void OnDisable()
    {
        if (onDisable && _OnDisable != null && _OnDisable.IsAlive) _OnDisable.Call(mGo);
    }

    private void OnDestroy()
    {
        if (onDestroy && _OnDestroy != null && _OnDestroy.IsAlive) _OnDestroy.Call(mGo);
    }

    #region Lua注册
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(LuaCmp), typeof(MonoBehaviour));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("Init", Init);
        L.RegFunction("Set", Set);
        L.RegVar("start", get_start, set_start);
        L.RegVar("onEnable", get_onEnable, set_onEnable);
        L.RegVar("onDisable", get_onDisable, set_onDisable);
        L.RegVar("onDestroy", get_onDestroy, set_onDestroy);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Init(System.IntPtr L)
    {
        try
        {
            if (4 == LuaDLL.lua_gettop(L))
            {
                if (_Start != null) _Start.Dispose();
                if (_OnEnable != null) _OnEnable.Dispose();
                if (_OnDisable != null) _OnDisable.Dispose();
                if (_OnDestroy != null) _OnDestroy.Dispose();
                _Start = ToLua.CheckLuaFunction(L, 1);
                _OnEnable = ToLua.CheckLuaFunction(L, 2);
                _OnDisable = ToLua.CheckLuaFunction(L, 3);
                _OnDestroy = ToLua.CheckLuaFunction(L, 4);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.Init");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Set(System.IntPtr L)
    {
        try
        {
            if (5 == LuaDLL.lua_gettop(L))
            {
                LuaCmp lc;
                object obj = ToLua.ToObject(L, 1);
                if (obj is LuaCmp)
                {
                    lc = obj as LuaCmp;
                }
                else if (obj is GameObject)
                {
                    GameObject go = obj as GameObject;
                    lc = go.GetComponent<LuaCmp>() ?? go.AddComponent<LuaCmp>();
                }
                else if (obj is Component)
                {
                    Component cmp = obj as Component;
                    lc = cmp.GetComponent<LuaCmp>() ?? cmp.gameObject.AddComponent<LuaCmp>();
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.Set");
                }
                lc.start = LuaDLL.luaL_checkboolean(L, 2);
                lc.onEnable = LuaDLL.luaL_checkboolean(L, 3);
                lc.onDisable = LuaDLL.luaL_checkboolean(L, 4);
                lc.onDestroy = LuaDLL.luaL_checkboolean(L, 5);
                ToLua.Push(L, lc);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.Set");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_start(System.IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {

                ToLua.Push(L, (ToLua.CheckObject<LuaCmp>(L, 1) as LuaCmp).start);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.start");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_start(System.IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                (ToLua.CheckObject<LuaCmp>(L, 1) as LuaCmp).start = LuaDLL.luaL_checkboolean(L, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.start");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_onEnable(System.IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {

                ToLua.Push(L, (ToLua.CheckObject<LuaCmp>(L, 1) as LuaCmp).onEnable);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.onEnable");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_onEnable(System.IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                (ToLua.CheckObject<LuaCmp>(L, 1) as LuaCmp).onEnable = LuaDLL.luaL_checkboolean(L, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.onEnable");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_onDisable(System.IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {

                ToLua.Push(L, (ToLua.CheckObject<LuaCmp>(L, 1) as LuaCmp).onDisable);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.onDisable");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_onDisable(System.IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                (ToLua.CheckObject<LuaCmp>(L, 1) as LuaCmp).onDisable = LuaDLL.luaL_checkboolean(L, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.onDisable");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_onDestroy(System.IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {

                ToLua.Push(L, (ToLua.CheckObject<LuaCmp>(L, 1) as LuaCmp).onDestroy);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.onDestroy");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_onDestroy(System.IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                (ToLua.CheckObject<LuaCmp>(L, 1) as LuaCmp).onDestroy = LuaDLL.luaL_checkboolean(L, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmp.onDestroy");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int op_Equality(System.IntPtr L)
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
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    #endregion
}
#endif