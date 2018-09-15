#if TOLUA
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

public class LuaCmpItem : MonoBehaviour
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
        L.BeginClass(typeof(LuaCmpItem), typeof(MonoBehaviour));
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
                LuaCmpItem._Start = ToLua.CheckLuaFunction(L, 1);
                LuaCmpItem._OnEnable = ToLua.CheckLuaFunction(L, 2);
                LuaCmpItem._OnDisable = ToLua.CheckLuaFunction(L, 3);
                LuaCmpItem._OnDestroy = ToLua.CheckLuaFunction(L, 4);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.Init");
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
                LuaCmpItem lci;
                object obj = ToLua.ToObject(L, 1);
                if (obj is LuaCmpItem)
                {
                    lci = obj as LuaCmpItem;
                }
                else if (obj is GameObject)
                {
                    GameObject go = obj as GameObject;
                    lci = go.GetComponent<LuaCmpItem>() ?? go.AddComponent<LuaCmpItem>();
                }
                else if (obj is Component)
                {
                    Component cmp = obj as Component;
                    lci = cmp.GetComponent<LuaCmpItem>() ?? cmp.gameObject.AddComponent<LuaCmpItem>();
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.Set");
                }
                lci.start = LuaDLL.luaL_checkboolean(L, 2);
                lci.onEnable = LuaDLL.luaL_checkboolean(L, 3);
                lci.onDisable = LuaDLL.luaL_checkboolean(L, 4);
                lci.onDestroy = LuaDLL.luaL_checkboolean(L, 5);
                ToLua.Push(L, lci);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.Set");
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
                
                ToLua.Push(L, (ToLua.CheckObject<LuaCmpItem>(L, 1) as LuaCmpItem).start);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.start");
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
                (ToLua.CheckObject<LuaCmpItem>(L, 1) as LuaCmpItem).start = LuaDLL.luaL_checkboolean(L, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.start");
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

                ToLua.Push(L, (ToLua.CheckObject<LuaCmpItem>(L, 1) as LuaCmpItem).onEnable);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.onEnable");
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
                (ToLua.CheckObject<LuaCmpItem>(L, 1) as LuaCmpItem).onEnable = LuaDLL.luaL_checkboolean(L, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.onEnable");
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

                ToLua.Push(L, (ToLua.CheckObject<LuaCmpItem>(L, 1) as LuaCmpItem).onDisable);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.onDisable");
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
                (ToLua.CheckObject<LuaCmpItem>(L, 1) as LuaCmpItem).onDisable = LuaDLL.luaL_checkboolean(L, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.onDisable");
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

                ToLua.Push(L, (ToLua.CheckObject<LuaCmpItem>(L, 1) as LuaCmpItem).onDestroy);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.onDestroy");
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
                (ToLua.CheckObject<LuaCmpItem>(L, 1) as LuaCmpItem).onDestroy = LuaDLL.luaL_checkboolean(L, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpItem.onDestroy");
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