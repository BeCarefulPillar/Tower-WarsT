#if TOLUA
using UnityEngine;
using LuaInterface;

[NoToLua]
public class LuaSerializeRef : MonoBehaviour
{
    [SerializeField] public GameObject[] gameObjects;
    [SerializeField] public Component[] cmps;
    [SerializeField] public UIWidget[] widgets;
    [SerializeField] public LuaButton[] buttons;
    [SerializeField] public Object[] objects;
    [SerializeField] public AnimationCurve[] curves;

    #region LUA注册
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(LuaSerializeRef), typeof(MonoBehaviour));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegVar("gos", GetGameObject, null);
        L.RegVar("cmps", GetCompoent, null);
        L.RegVar("btns", GetButton, null);
        L.RegVar("widgets", GetWidget, null);
        L.RegVar("objs", GetObject, null);
        L.RegVar("curves", GetCures, null);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetGameObject(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1)
            {
                LuaSerializeRef sr = ToLua.CheckObject<LuaSerializeRef>(L, 1) as LuaSerializeRef;
                if (sr && sr.gameObjects != null && sr.gameObjects.Length > 0)
                {
                    if (count == 1)
                    {
                        ToLua.Push(L, sr.gameObjects); return 1;
                    }
                    if (TypeChecker.CheckType(L, typeof(int), 2))
                    {
                        int idx = LuaDLL.tolua_tointeger(L, 2);
                        if (sr.gameObjects.IndexAvailable(idx))
                        {
                            ToLua.Push(L, sr.gameObjects[idx]); return 1;
                        }
                    }
                    else if (TypeChecker.CheckType(L, typeof(string), 2))
                    {
                        string nm = ToLua.ToString(L, 2);
                        GameObject target = System.Array.Find(sr.gameObjects, g => { return g && g.name == nm; });
                        if (target)
                        {
                            ToLua.Push(L, target); return 1;
                        }
                    }
                }
            }
            LuaDLL.lua_pushnil(L);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetCompoent(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1)
            {
                LuaSerializeRef sr = ToLua.CheckObject<LuaSerializeRef>(L, 1) as LuaSerializeRef;
                if (sr && sr.cmps != null && sr.cmps.Length > 0)
                {
                    if (count == 1)
                    {
                        ToLua.Push(L, sr.cmps); return 1;
                    }
                    if (TypeChecker.CheckType(L, typeof(int), 2))
                    {
                        int idx = LuaDLL.tolua_tointeger(L, 2);
                        if (sr.cmps.IndexAvailable(idx))
                        {
                            ToLua.Push(L, sr.cmps[idx]); return 1;
                        }
                    }
                    else if (TypeChecker.CheckType(L, typeof(string), 2))
                    {
                        string nm = ToLua.ToString(L, 2);
                        Component target = System.Array.Find(sr.cmps, c => { return c && c.name == nm; });
                        if (target)
                        {
                            ToLua.Push(L, target); return 1;
                        }
                    }
                }
            }
            LuaDLL.lua_pushnil(L);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetWidget(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count >= 1)
            {
                LuaSerializeRef sr = ToLua.CheckObject<LuaSerializeRef>(L, 1) as LuaSerializeRef;
                if (sr && sr.widgets != null && sr.widgets.Length > 0)
                {
                    if (count == 1)
                    {
                        ToLua.Push(L, sr.widgets); return 1;
                    }
                    if (TypeChecker.CheckType(L, typeof(int), 2))
                    {
                        int idx = LuaDLL.tolua_tointeger(L, 2);
                        if (sr.widgets.IndexAvailable(idx))
                        {
                            ToLua.Push(L, sr.widgets[idx]); return 1;
                        }
                    }
                    else if (TypeChecker.CheckType(L, typeof(string), 2))
                    {
                        string nm = ToLua.ToString(L, 2);
                        UIWidget target = System.Array.Find(sr.widgets, w => { return w && w.name == nm; });
                        if (target)
                        {
                            ToLua.Push(L, target); return 1;
                        }
                    }
                }
            }
            LuaDLL.lua_pushnil(L);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetButton(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count >= 1)
            {
                LuaSerializeRef sr = ToLua.CheckObject<LuaSerializeRef>(L, 1) as LuaSerializeRef;
                if (sr && sr.buttons != null && sr.buttons.Length > 0)
                {
                    if (count == 1)
                    {
                        ToLua.Push(L, sr.buttons); return 1;
                    }
                    if (TypeChecker.CheckType(L, typeof(int), 2))
                    {
                        int idx = LuaDLL.tolua_tointeger(L, 2);
                        if (sr.buttons.IndexAvailable(idx))
                        {
                            ToLua.Push(L, sr.buttons[idx]); return 1;
                        }
                    }
                    else if (TypeChecker.CheckType(L, typeof(string), 2))
                    {
                        string nm = ToLua.ToString(L, 2);
                        LuaButton target = System.Array.Find(sr.buttons, b => { return b && b.name == nm; });
                        if (target)
                        {
                            ToLua.Push(L, target); return 1;
                        }
                    }
                }
            }
            LuaDLL.lua_pushnil(L);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetObject(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count >= 1)
            {
                LuaSerializeRef sr = ToLua.CheckObject<LuaSerializeRef>(L, 1) as LuaSerializeRef;
                if (sr && sr.objects != null && sr.objects.Length > 0)
                {
                    if (count == 1)
                    {
                        ToLua.Push(L, sr.objects); return 1;
                    }
                    if (TypeChecker.CheckType(L, typeof(int), 2))
                    {
                        
                        int idx = LuaDLL.tolua_tointeger(L, 2);
                        if (sr.objects.IndexAvailable(idx))
                        {
                            ToLua.Push(L, sr.objects[idx]); return 1;
                        }
                    }
                    else if (TypeChecker.CheckType(L, typeof(string), 2))
                    {
                        string nm = ToLua.ToString(L, 2);
                        Object target = System.Array.Find(sr.objects, o => { return o && o.name == nm; });
                        if (target)
                        {
                            ToLua.Push(L, target); return 1;
                        }
                    }
                }
            }
            LuaDLL.lua_pushnil(L);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetCures(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count >= 1)
            {
                LuaSerializeRef sr = ToLua.CheckObject<LuaSerializeRef>(L, 1) as LuaSerializeRef;
                if (sr && sr.curves != null && sr.curves.Length > 0)
                {
                    if (count == 1)
                    {
                        ToLua.Push(L, sr.curves); return 1;
                    }
                    int idx = LuaDLL.luaL_checkinteger(L, 2);
                    if (sr.curves.IndexAvailable(idx))
                    {
                        ToLua.Push(L, sr.curves[idx]); return 1;
                    }
                }
            }
            LuaDLL.lua_pushnil(L);
            return 1;
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