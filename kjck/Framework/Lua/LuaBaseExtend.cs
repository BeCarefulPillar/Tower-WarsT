#if TOLUA
using UnityEngine;
using System;
using System.Collections.Generic;
using LuaInterface;


public static class LuaBaseExtend
{
    #region 辅助
    private static Transform GetTransform(IntPtr L, int pos)
    {
        object obj = ToLua.ToObject(L, pos);
        if (obj is Transform) return obj as Transform;
        else if (obj is GameObject) return (obj as GameObject).transform;
        else if (obj is Component) return (obj as Component).transform;
        return null;
    }
    /// <summary>
    /// 获取Lua给定位置上给定类型的组件
    /// </summary>
    /// <typeparam name="T">组件类型</typeparam>
    public static T GetCmp<T>(this IntPtr L, int pos) where T : Component
    {
        object obj = ToLua.ToObject(L, pos);
        if (obj is T) return obj as T;
        if (obj is Component) return (obj as Component).GetComponent<T>();
        if (obj is GameObject) return (obj as GameObject).GetComponent<T>();
        return null;
    }
    /// <summary>
    /// 获取Lua给定位置上给定类型的GameObject
    /// </summary>
    public static GameObject GetGo(this IntPtr L, int pos)
    {
        object obj = ToLua.ToObject(L, pos);
        if (obj is GameObject) return obj as GameObject;
        if (obj is Component) return (obj as Component).gameObject;
        return null;
    }
    ///// <summary>
    ///// 获取对象上给定类型的GameObject
    ///// </summary>
    //public static GameObject GetGo(this object obj)
    //{
    //    if (obj is GameObject) return obj as GameObject;
    //    if (obj is Component) return (obj as Component).gameObject;
    //    return null;
    //}
    ///// <summary>
    ///// 获取对象上给定类型的组件
    ///// </summary>
    ///// <typeparam name="T">组件类型</typeparam>
    //public static T GetCmp<T>(this object obj) where T : Component
    //{
    //    if (obj is T) return obj as T;
    //    if (obj is Component) return (obj as Component).GetComponent<T>();
    //    if (obj is GameObject) return (obj as GameObject).GetComponent<T>();
    //    return null;
    //}
    #endregion

    #region 数组
    public static void ArrayReg(LuaState L)
    {
        L.BeginClass(typeof(System.Array), typeof(System.Object));
        L.RegFunction("IndexOf", IndexOf);
        L.RegFunction("IndexAvailable", IndexAvailable);
        L.RegVar("length", Length, null);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Length(IntPtr L)
    {
        try
        {
            Array arr = ToLua.ToObject(L, 1) as Array;
            LuaDLL.lua_pushinteger(L, arr == null? 0 : arr.Length);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IndexOf(IntPtr L)
    {
        try
        {
            Array arr = ToLua.ToObject(L, 1) as Array;
            if (arr != null)
            {
                object e = ToLua.ToObject(L, 2);
                for (int i = 0; i < arr.Length; i++)
                {
                    if (arr.GetValue(i) == e)
                    {
                        LuaDLL.lua_pushinteger(L, i);
                        return 1;
                    }
                }
            }
            LuaDLL.lua_pushinteger(L, -1);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IndexAvailable(IntPtr L)
    {
        try
        {
            Array arr = ToLua.ToObject(L, 1) as Array;
            if (arr == null)
            {
                LuaDLL.lua_pushboolean(L, false);
            }
            else
            {
                int idx = (int)LuaDLL.luaL_checknumber(L, 2);
                LuaDLL.lua_pushboolean(L, idx >= 0 && idx < arr.Length);
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region Common
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetCmpInChilds(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "GetCmpInChilds(GameObject/Component, string/Type, bool self = true, bool inactive = true) requires at least 2 params");
            }
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmpInChilds(GameObject/Component, string/Type, bool self = true, bool inactive = true) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            Type type = null;
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                type = Type.GetType(ToLua.ToString(L, 2), true);
            }
            else if (TypeChecker.CheckType(L, typeof(Type), 2))
            {
                type = ToLua.ToObject(L, 2) as Type;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmpInChilds(GameObject/Component, string/Type, bool self = true, bool inactive = true) the second param must be string or Type");
            }
            if (argCnt < 3 || LuaDLL.luaL_checkboolean(L, 3))
            {
                Component cmp = go.GetComponent(type);
                if (cmp)
                {
                    ToLua.Push(L, cmp); return 1;
                }
            }
            ToLua.Push(L, go.GetComponentInChildren(type, argCnt < 4 || LuaDLL.luaL_checkboolean(L, 4)));
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetCmpsInChilds(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "GetCmpsInChilds(GameObject/Component, string/Type, bool self = true, bool inactive = true) requires at least 2 params");
            }
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmpsInChilds(GameObject/Component, string/Type, bool self = true, bool inactive = true) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            Type type = null;
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                type = Type.GetType(ToLua.ToString(L, 2), true);
            }
            else if (TypeChecker.CheckType(L, typeof(Type), 2))
            {
                type = ToLua.ToObject(L, 2) as Type;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmpsInChilds(GameObject/Component, string/Type, bool self = true, bool inactive = true) the second param must be string or Type");
            }
            if (argCnt < 3 || LuaDLL.luaL_checkboolean(L, 3))
            {
                Component[] cmps = go.GetComponents(type);
                if (cmps != null && cmps.Length > 0)
                {
                    List<Component> lst = new List<Component>(cmps);
                    cmps = go.GetComponentsInChildren(type, argCnt < 4 || LuaDLL.luaL_checkboolean(L, 4));
                    if (cmps != null) lst.AddRange(cmps);
                    ToLua.Push(L, lst.ToArray());
                    return 1;
                }
            }
            ToLua.Push(L, go.GetComponentsInChildren(type, argCnt < 4 || LuaDLL.luaL_checkboolean(L, 4)));
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int AddCmp(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "AddCmp(GameObject/Component, string/Type) requires at least 2 params");
            }
            Component ret = null;
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "AddCmp(GameObject/Component, string/Type) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                ret = go.AddComponent(Type.GetType(ToLua.ToString(L, 2), true));
            }
            else if (TypeChecker.CheckType(L, typeof(Type), 2))
            {
                ret = go.AddComponent(ToLua.ToObject(L, 2) as Type);
            }
            else
            {
                return LuaDLL.luaL_throw(L, "AddCmp(GameObject/Component, string/Type) the second param must be string or Type");
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetCmp(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if(argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "GetCmp(GameObject/Component, string/Type) requires at least 2 params");
            }
            Component ret = null;
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmp(GameObject/Component, string/Type) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                ret = go.GetComponent(ToLua.ToString(L, 2));
            }
            else if (TypeChecker.CheckType(L, typeof(Type), 2))
            {
                ret = go.GetComponent(ToLua.ToObject(L, 2) as Type);
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmp(GameObject/Component, string/Type) the second param must be string or Type");
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetCmps(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "GetCmps(GameObject/Component, string/Type) requires at least 2 params");
            }
            Component[] ret = null;
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmps(GameObject/Component, string/Type) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                ret = go.GetComponents(Type.GetType(ToLua.ToString(L, 2), true));
            }
            else if (TypeChecker.CheckType(L, typeof(Type), 2))
            {
                ret = go.GetComponents(ToLua.ToObject(L, 2) as Type);
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmps(GameObject/Component, string/Type) the second param must be string or Type");
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetCmpInParent(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "GetCmpInParent(GameObject/Component, string/Type, bool inactive = true) requires at least 2 params");
            }
            Component ret = null;
            object obj = ToLua.ToObject(L, 1);
            if (argCnt < 3 || LuaDLL.luaL_checkboolean(L, 3))
            {
                Transform trans = null;
                if (obj is GameObject)
                {
                    trans = (obj as GameObject).transform;
                }
                else if (obj is Transform)
                {
                    trans = obj as Transform;
                }
                else if (obj is Component)
                {
                    trans = (obj as Component).transform;
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "GetCmpInParent(GameObject/Component, string/Type, bool inactive = true) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
                }
                if (TypeChecker.CheckType(L, typeof(string), 2))
                {
                    string type = ToLua.ToString(L, 2);
                    trans = trans.parent;
                    while (trans)
                    {
                        ret = trans.GetComponent(type);
                        if (ret) break;
                        trans = trans.parent;
                    }
                }
                else if (TypeChecker.CheckType(L, typeof(Type), 2))
                {
                    Type type = ToLua.ToObject(L, 2) as Type;
                    trans = trans.parent;
                    while (trans)
                    {
                        ret = trans.GetComponent(type);
                        if (ret) break;
                        trans = trans.parent;
                    }
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "GetCmpInParent(GameObject/Component, string/Type, bool inactive = true) the second param must be string or Type");
                }
            }
            else
            {
                GameObject go = null;
                if (obj is GameObject)
                {
                    go = obj as GameObject;
                }
                else if (obj is Component)
                {
                    go = (obj as Component).gameObject;
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "GetCmpInP(GameObject/Component, string/Type, bool inactive = true) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
                }
                if (TypeChecker.CheckType(L, typeof(string), 2))
                {
                    ret = go.GetComponentInParent(Type.GetType(ToLua.ToString(L, 2), true));
                }
                else if (TypeChecker.CheckType(L, typeof(Type), 2))
                {
                    ret = go.GetComponentInParent(ToLua.ToObject(L, 2) as Type);
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "GetCmpInP(GameObject/Component, string/Type, bool inactive = true) the second param must be string or Type");
                }
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetCmpsInParent(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "GetCmpsInParent(GameObject/Component, string/Type, bool inactive = true) requires at least 2 params");
            }
            Component[] ret = null;
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmpsInParent(GameObject/Component, string/Type, bool inactive = true) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                ret = go.GetComponentsInParent(Type.GetType(ToLua.ToString(L, 2), true), argCnt < 3 || LuaDLL.luaL_checkboolean(L, 3));
            }
            else if (TypeChecker.CheckType(L, typeof(Type), 2))
            {
                ret = go.GetComponentsInParent(ToLua.ToObject(L, 2) as Type, argCnt < 3 || LuaDLL.luaL_checkboolean(L, 3));
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmpsInParent(GameObject/Component, string/Type, bool inactive = true) the second param must be string or Type");
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int AddChild(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 1)
            {
                return LuaDLL.luaL_throw(L, "AddChild(GameObject/Component, string/GameObject/Component, string name, bool init) requires at least 1 params");
            }
            GameObject ret = null;
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "AddChild(GameObject/Component, string/GameObject/Component, string name, bool init) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (argCnt == 1)
            {
                ret = go.AddChild(string.Empty);
            }
            else
            {
                if (TypeChecker.CheckType(L, typeof(string), 2))
                {
                    ret = go.AddChild(ToLua.ToString(L, 2), argCnt < 3 || !LuaDLL.lua_isboolean(L, 3) || LuaDLL.lua_toboolean(L, 3));
                }
                else
                {
                    GameObject prefab = null;
                    obj = ToLua.ToObject(L, 2);
                    if (obj is GameObject)
                    {
                        prefab = obj as GameObject;
                    }
                    else if (obj is Component)
                    {
                        prefab = (obj as Component).gameObject;
                    }
                    else
                    {
                        return LuaDLL.luaL_throw(L, "AddChild(GameObject/Component, string/GameObject/Component, string name, bool init) the second param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
                    }
                    ret = go.AddChild(prefab, argCnt < 3 ? string.Empty : ToLua.CheckString(L, 3), argCnt < 4 || !LuaDLL.lua_isboolean(L, 4) || LuaDLL.lua_toboolean(L, 4));
                }
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int AddWidget(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "AddWidget(GameObject/Component, string/Type, string name = \"\") requires at least 2 params");
            }
            Component ret = null;
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "AddWidget(GameObject/Component, string/Type, string name = \"\") the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                ret = go.AddWidget(Type.GetType(ToLua.ToString(L, 2), true), argCnt < 3 ? string.Empty : ToLua.CheckString(L, 3));
            }
            else if (TypeChecker.CheckType(L, typeof(Type), 2))
            {
                ret = go.AddWidget(ToLua.ToObject(L, 2) as Type, argCnt < 3 ? string.Empty : ToLua.CheckString(L, 3));
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmps(GameObject/Component, string/Type) the second param must be string or Type");
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DesCmp(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return argCnt == 1 ? 0 : LuaDLL.luaL_throw(L, "DesCmp(GameObject/Component, string/Type...) requires at least 1 params");
            }
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "DesCmp(GameObject/Component, string/Type...) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (argCnt == 2)
            {
                Component cmp = null;
                switch (LuaDLL.lua_type(L, 2))
                {
                    case LuaTypes.LUA_TSTRING:
                        cmp = go.GetComponent(LuaDLL.lua_tostring(L, 2)); break;
                    case LuaTypes.LUA_TUSERDATA:
                        obj = ToLua.ToObject(L, 2);
                        if (obj is string) cmp = go.GetComponent(obj as string);
                        else if (obj is Type) cmp = go.GetComponent(obj as Type);
                        break;
                    default: break;
                }
                if (cmp)
                {
                    UnityEngine.Object.Destroy(cmp);
                    ToLua.Push(L, 1); return 1;
                }
            }
            else
            {
                int cnt = 0;
                Component cmp = null;
                for (int i = 2; i <= argCnt; i++)
                {
                    switch (LuaDLL.lua_type(L, i))
                    {
                        case LuaTypes.LUA_TSTRING:
                            cmp = go.GetComponent(LuaDLL.lua_tostring(L, i)); break;
                        case LuaTypes.LUA_TUSERDATA:
                            obj = ToLua.ToObject(L, i);
                            if (obj is string) { cmp = go.GetComponent(obj as string); break; }
                            if (obj is Type) { cmp = go.GetComponent(obj as Type); break; }
                            continue;
                        default: continue;
                    }
                    if (cmp == null) continue;
                    UnityEngine.Object.Destroy(cmp);
                    cnt++;
                }
                if (cnt > 0)
                {
                    ToLua.Push(L, cnt); return 1;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DesCmps(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return argCnt == 1 ? 0 : LuaDLL.luaL_throw(L, "DesCmps(GameObject/Component, string/Type...) requires at least 1 params");
            }
            GameObject go = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                go = obj as GameObject;
            }
            else if (obj is Component)
            {
                go = (obj as Component).gameObject;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "DesCmps(GameObject/Component, string/Type...) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (argCnt == 2)
            {
                Component[] cmps = null;
                switch (LuaDLL.lua_type(L, 2))
                {
                    case LuaTypes.LUA_TSTRING:
                        cmps = go.GetComponents(Type.GetType(LuaDLL.lua_tostring(L, 2), true)); break;
                    case LuaTypes.LUA_TUSERDATA:
                        obj = ToLua.ToObject(L, 2);
                        if (obj is string) cmps = go.GetComponents(Type.GetType(obj as string, true));
                        else if (obj is Type) cmps = go.GetComponents(obj as Type);
                        break;
                    default: break;
                }
                if (cmps != null && cmps.Length > 1)
                {
                    foreach (Component cmp in cmps) UnityEngine.Object.Destroy(cmp);
                    ToLua.Push(L, cmps.Length); return 1;
                }
            }
            else
            {
                int cnt = 0;
                Component[] cmps = null;
                for (int i = 2; i <= argCnt; i++)
                {
                    switch (LuaDLL.lua_type(L, i))
                    {
                        case LuaTypes.LUA_TSTRING:
                            cmps = go.GetComponents(Type.GetType(LuaDLL.lua_tostring(L, i), true)); break;
                        case LuaTypes.LUA_TUSERDATA:
                            obj = ToLua.ToObject(L, i);
                            if (obj is string) { cmps = go.GetComponents(Type.GetType(obj as string, true)); break; }
                            if (obj is Type) { cmps = go.GetComponents(obj as Type); break; }
                            continue;
                        default: continue;
                    }
                    if (cmps == null || cmps.Length <= 0) continue;
                    foreach (Component cmp in cmps) UnityEngine.Object.Destroy(cmp);
                    cnt += cmps.Length;
                }
                if (cnt > 0)
                {
                    ToLua.Push(L, cnt); return 1;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Destruct(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count < 1)
            {
                return LuaDLL.luaL_throw(L, "Destruct(GameObject/Component, bool) requires at least 1 params");
            }
            object obj = ToLua.ToObject(L, 1);
            if (obj is GameObject)
            {
                UnityEngine.Object.Destroy(obj as GameObject);
            }
            else if (obj is Component)
            {
                if (count > 1 && LuaDLL.luaL_checkboolean(L, 2))
                {
                    UnityEngine.Object.Destroy((obj as Component).gameObject);
                }
                else
                {
                    UnityEngine.Object.Destroy(obj as Component);
                }
            }
            else
            {
                return LuaDLL.luaL_throw(L, "Destruct(GameObject/Component, bool) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetChild(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "GetChild(GameObject/Component, string/int, string/Type) requires at least 2 params");
            }
            Component ret = null;
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetChild(GameObject/Component, string/int, string/Type) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                ret = trans.FindChild(ToLua.ToString(L, 2));
            }
            else if (TypeChecker.CheckType(L, typeof(int), 2))
            {
                ret = trans.GetChild(LuaDLL.tolua_tointeger(L, 2));
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetChild(GameObject/Component, string/int, string/Type) the second param must be string or int");
            }
            if (ret && argCnt > 2)
            {
                if (TypeChecker.CheckType(L, typeof(string), 3))
                {
                    ret = ret.GetComponent(ToLua.CheckString(L, 3));
                }
                else if (TypeChecker.CheckType(L, typeof(Type), 3))
                {
                    ret = ret.GetComponent(ToLua.ToObject(L, 3) as Type);
                }
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetChildWidget(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "GetChildWidget(GameObject/Component, string/int) requires at least 2 params");
            }
            Component ret = null;
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetChildWidget(GameObject/Component, string/int) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                ret = trans.FindChild(ToLua.ToString(L, 2));
            }
            else if (TypeChecker.CheckType(L, typeof(int), 2))
            {
                ret = trans.GetChild(LuaDLL.tolua_tointeger(L, 2));
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetChildWidget(GameObject/Component, string/int) the second param must be string or int");
            }
            if (ret)
            {
                ret = ret.GetComponent<UIWidget>();
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetChildBtn(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "GetChildBtn(GameObject/Component, string/int) requires at least 2 params");
            }
            Component ret = null;
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetChildBtn(GameObject/Component, string/int) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (TypeChecker.CheckType(L, typeof(string), 2))
            {
                ret = trans.FindChild(ToLua.ToString(L, 2));
            }
            else if (TypeChecker.CheckType(L, typeof(int), 2))
            {
                ret = trans.GetChild(LuaDLL.tolua_tointeger(L, 2));
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetChildBtn(GameObject/Component, string/int) the second param must be string or int");
            }
            if (ret)
            {
                ret = ret.GetComponent<LuaButton>();
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DestroyChild(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count < 1)
            {
                return LuaDLL.luaL_throw(L, "DestroyChildByNm(GameObject/Component, ...) requires at least 1 params");
            }
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "DestroyChildByNm(GameObject/Component, ..) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }

            if (count > 1)
            {
                int cnt = 0;
                string nm;
                Transform temp;
                for (int i = 2; i <= count; i++)
                {
                    nm = ToLua.ToString(L, i);
                    if (nm == null) continue;
                    temp = trans.FindChild(nm);
                    if (temp)
                    {
                        UnityEngine.Object.Destroy(temp.gameObject);
                        cnt++;
                    }
                }
                if (cnt > 0)
                {
                    ToLua.Push(L, cnt);
                    return 1;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetAllChild(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count < 1)
            {
                return LuaDLL.luaL_throw(L, "GetAllChild(GameObject/Component, Type type = null) requires at least 1 params");
            }
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetAllChild(GameObject/Component, Type type = null) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (count > 1)
            {
                Type type = ToLua.CheckObject<Type>(L, 2) as Type;
                if (type == typeof(GameObject))
                {
                    LuaDLL.lua_createtable(L, 0, 0);
                    for (int i = 0; i < trans.childCount; i++)
                    {
                        LuaDLL.lua_pushnumber(L, i + 1);
                        ToLua.PushSealed(L, trans.GetChild(i).gameObject);
                        LuaDLL.lua_rawset(L, -3);
                    }
                }
                else
                {
                    int idx = 0;
                    LuaDLL.lua_createtable(L, 0, 0);
                    for (int i = 0; i < trans.childCount; i++)
                    {
                        Component cmp = trans.GetChild(i).GetComponent(type);
                        if (cmp)
                        {
                            LuaDLL.lua_pushnumber(L, ++idx);
                            ToLua.Push(L, cmp);
                            LuaDLL.lua_rawset(L, -3);
                        }
                    }
                }
            }
            else
            {
                LuaDLL.lua_createtable(L, 0, 0);
                for (int i = 0; i < trans.childCount; i++)
                {
                    LuaDLL.lua_pushnumber(L, i + 1);
                    ToLua.PushSealed(L, trans.GetChild(i));
                    LuaDLL.lua_rawset(L, -3);
                }
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DestroyAllChild(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count < 1)
            {
                return LuaDLL.luaL_throw(L, "DestroyChilds(GameObject/Component, GameObject/Component temp = null) requires at least 1 params");
            }
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "DestroyChilds(GameObject/Component, GameObject/Component temp = null) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            Transform temp = null;
            if (count > 1)
            {
                obj = ToLua.ToObject(L, 1);
                if (obj is Transform)
                {
                    temp = obj as Transform;
                }
                else if (obj is GameObject)
                {
                    temp = (obj as GameObject).transform;
                }
                else if (obj is Component)
                {
                    temp = (obj as Component).transform;
                }
            }

            if (trans)
            {
                for (int i = trans.childCount - 1; i >= 0; i--)
                {
                    Transform t = trans.GetChild(i);
                    if (t)
                    {
                        t.gameObject.SetActive(false);
                        t.parent = temp;
                        UnityEngine.Object.Destroy(t.gameObject);
                    }
                }
            }

            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ActChild(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 3)
            {
                return LuaDLL.luaL_throw(L, "ActChild(GameObject/Component, bool, int/string ...) requires at least 3 params");
            }
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "ActChild(GameObject/Component, bool, int/string ...) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            if (argCnt == 3)
            {
                LuaTypes luaType = LuaDLL.lua_type(L, 3);
                if (luaType == LuaTypes.LUA_TNUMBER)
                {
                    trans = trans.GetChild(LuaDLL.luaL_checkinteger(L, 3));
                }
                else if (luaType == LuaTypes.LUA_TSTRING)
                {
                    trans = trans.FindChild(LuaDLL.lua_tostring(L, 3));
                }
                else if (luaType == LuaTypes.LUA_TUSERDATA)
                {
                    trans = trans.FindChild(ToLua.ToObject(L, 3) as string);
                }
                else
                {
                    trans = null;
                }
                if (trans) trans.gameObject.SetActive(LuaDLL.luaL_checkboolean(L, 2));
                return 0;
            }
            bool act = LuaDLL.luaL_checkboolean(L, 2);
            for (int i = 3; i <= argCnt; i++)
            {
                LuaTypes luaType = LuaDLL.lua_type(L, i);
                Transform t = null;
                if (luaType == LuaTypes.LUA_TNUMBER)
                {
                    t = trans.GetChild(LuaDLL.luaL_checkinteger(L, i));
                }
                else if (luaType == LuaTypes.LUA_TSTRING)
                {
                    t = trans.FindChild(LuaDLL.lua_tostring(L, i));
                }
                else if (luaType == LuaTypes.LUA_TUSERDATA)
                {
                    t = trans.FindChild(ToLua.ToObject(L, i) as string);
                }
                if (t) t.gameObject.SetActive(act);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ActAllChild(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 3)
            {
                return LuaDLL.luaL_throw(L, "ActChild(GameObject/Component, bool) requires at least 2 params");
            }
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "ActChild(GameObject/Component, bool) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            bool act = LuaDLL.luaL_checkboolean(L, 2);
            for (int i = 0; i < trans.childCount; i++)
            {
                trans.GetChild(i).gameObject.SetActive(act);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetScreenArea(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count < 1)
            {
                return LuaDLL.luaL_throw(L, "GetScreenArea(GameObject/Component, Camera cam = UICamera.currentCamera) requires at least 1 params");
            }
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetScreenArea(GameObject/Component, Camera cam = UICamera.currentCamera) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            Camera cam = count == 1 ? UICamera.currentCamera : ToLua.CheckObject<Camera>(L, 2) as Camera;
            if (cam == null)
            {
                if (count == 1)
                {
                    cam = NGUITools.FindCameraForLayer(trans.gameObject.layer);
                    if (cam == null)
                    {
                        return LuaDLL.luaL_throw(L, "GetScreenArea(GameObject/Component, Camera cam = UICamera.currentCamera) can not find any camera for layer[" + trans.gameObject.layer + "]");
                    }
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "GetScreenArea(GameObject/Component, Camera cam = UICamera.currentCamera) the second param must be Camera");
                }
            }

            Matrix4x4 m = trans.worldToLocalMatrix;
            float z = trans.position.z - cam.transform.position.z;
            Vector3 min = m.MultiplyPoint3x4(cam.ScreenToWorldPoint(new Vector3(0f, 0f, z)));
            Vector3 max = m.MultiplyPoint3x4(cam.ScreenToWorldPoint(new Vector3(Screen.width, Screen.height, z)));

            ToLua.Push(L, min);
            ToLua.Push(L, max);
            return 2;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetWidget(IntPtr L) { return GetCmp<UIWidget>(L); }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetLuaSrf(IntPtr L) { return GetCmp<LuaSerializeRef>(L); }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetLuaBtn(IntPtr L) { return GetCmp<LuaButton>(L); }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetLuaContainer(IntPtr L) { return GetCmp<LuaContainer>(L); }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetMousePos(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count < 1)
            {
                return LuaDLL.luaL_throw(L, "GetMousePos(GameObject/Component, Camera cam = UICamera.currentCamera) requires at least 1 params");
            }
            Transform trans = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Transform)
            {
                trans = obj as Transform;
            }
            else if (obj is Component)
            {
                trans = (obj as Component).transform;
            }
            else if (obj is GameObject)
            {
                trans = (obj as GameObject).transform;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetMousePos(GameObject/Component, Camera cam = UICamera.currentCamera) the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            Camera cam = count == 1 ? UICamera.currentCamera : ToLua.CheckObject<Camera>(L, 2) as Camera;
            if (cam == null)
            {
                if (count == 1)
                {
                    cam = NGUITools.FindCameraForLayer(trans.gameObject.layer);
                    if (cam == null)
                    {
                        return LuaDLL.luaL_throw(L, "GetMousePos(GameObject/Component, Camera cam = UICamera.currentCamera) can not find any camera for layer[" + trans.gameObject.layer + "]");
                    }
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "GetMousePos(GameObject/Component, Camera cam = UICamera.currentCamera) the second param must be Camera");
                }
            }
            Vector3 pos = Input.mousePosition;
            pos.z = trans.position.z - cam.transform.position.z;
            ToLua.Push(L, trans.worldToLocalMatrix.MultiplyPoint3x4(cam.ScreenToWorldPoint(pos)));
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    private static int GetCmp<T>(IntPtr L) where T : Component
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count < 1)
            {
                return LuaDLL.luaL_throw(L, "GetCmp(GameObject/Component) requires at least 1 params");
            }
            T ret = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is T)
            {
                ret = obj as T;
            }
            else if (obj is Component)
            {
                ret = (obj as Component).GetComponent<T>();
            }
            else if (obj is GameObject)
            {
                ret = (obj as GameObject).GetComponent<T>();
            }
            else
            {
                return LuaDLL.luaL_throw(L, "GetCmp(GameObject/Component the first param[" + (obj == null ? "null" : obj.GetType().Name) + "] must be GameObject or Component");
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region GameObject
    public static void GameObjectReg(LuaState L)
    {
        L.BeginClass(typeof(GameObject), typeof(UnityEngine.Object));
        L.RegFunction("GetCmpInChilds", GetCmpInChilds);
        L.RegFunction("GetCmpsInChilds", GetCmpsInChilds);
        L.RegFunction("AddCmp", AddCmp);
        L.RegFunction("GetCmp", GetCmp);
        L.RegFunction("GetCmps", GetCmps);
        L.RegFunction("GetCmpInParent", GetCmpInParent);
        L.RegFunction("GetCmpsInParent", GetCmpsInParent);
        L.RegFunction("AddChild", AddChild);
        L.RegFunction("AddWidget", AddWidget);
        L.RegFunction("Child", GetChild);
        L.RegFunction("ChildWidget", GetChildWidget);
        L.RegFunction("ChildBtn", GetChildBtn);
        L.RegFunction("DesCmp", DesCmp);
        L.RegFunction("DesCmps", DesCmps);
        L.RegFunction("Destruct", Destruct);
        L.RegFunction("DesChild", DestroyChild);
        L.RegFunction("GetAllChild", GetAllChild);
        L.RegFunction("DesAllChild", DestroyAllChild);
        L.RegFunction("ActChild", ActChild);
        L.RegFunction("ActAllChild", ActAllChild);
        L.RegFunction("GetScreen", GetScreenArea);
        L.RegVar("widget", GetWidget, null);
        L.RegVar("luaC", GetLuaContainer, null);
        L.RegVar("luaSrf", GetLuaSrf, null);
        L.RegVar("luaBtn", GetLuaBtn, null);
        L.RegVar("mousePos", GetMousePos, null);
        L.EndClass();
    }
    

    #endregion

    #region Component
    public static void ComponentReg(LuaState L)
    {
        L.BeginClass(typeof(Component), typeof(UnityEngine.Object));
        L.RegFunction("GetCmpInChilds", GetCmpInChilds);
        L.RegFunction("GetCmpsInChilds", GetCmpsInChilds);
        L.RegFunction("AddCmp", AddCmp);
        L.RegFunction("GetCmp", GetCmp);
        L.RegFunction("GetCmps", GetCmps);
        L.RegFunction("GetCmpInParent", GetCmpInParent);
        L.RegFunction("GetCmpsInParent", GetCmpsInParent);
        L.RegFunction("AddChild", AddChild);
        L.RegFunction("AddWidget", AddWidget);
        L.RegFunction("Child", GetChild);
        L.RegFunction("ChildWidget", GetChildWidget);
        L.RegFunction("ChildBtn", GetChildBtn);
        L.RegFunction("DesCmp", DesCmp);
        L.RegFunction("DesCmps", DesCmps);
        L.RegFunction("Destruct", Destruct);
        L.RegFunction("DesChild", DestroyChild);
        L.RegFunction("GetAllChild", GetAllChild);
        L.RegFunction("DesAllChild", DestroyAllChild);
        L.RegFunction("ActChild", ActChild);
        L.RegFunction("ActAllChild", ActAllChild);
        L.RegFunction("DestructIfOnly", CmpDestructIfOnly);
        L.RegFunction("DestroyOther", CmpDestroyOther);
        L.RegFunction("SetActive", CmpSetActive);
        L.RegFunction("GetScreen", GetScreenArea);
        L.RegVar("activeSelf", get_cmpActiveSelf, null);
        L.RegVar("widget", GetWidget, null);
        L.RegVar("luaC", GetLuaContainer, null);
        L.RegVar("luaRef", GetLuaSrf, null);
        L.RegVar("luaBtn", GetLuaBtn, null);
        L.RegVar("mousePos", GetMousePos, null);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CmpDestructIfOnly(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 1)
            {
                Component cmp = ToLua.CheckObject<Component>(L, 1) as Component;
                ToLua.Destroy(L);
                if (cmp.GetComponents<Component>().GetLength() > 2)
                {
                    UnityEngine.Object.Destroy(cmp);
                }
                else
                {
                    UnityEngine.Object.Destroy(cmp.gameObject);
                }
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: Component.DestructIfOnly");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CmpDestroyOther(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 1)
            {
                Component cmp = ToLua.CheckObject<Component>(L, 1) as Component;
                if (cmp)
                {
                    Component[] cpms = cmp.GetComponents<Component>();
                    for (int i = 0; i < cpms.Length; i++)
                    {
                        if (cpms[i] is Transform || cpms[i] == cmp) continue;
                        UnityEngine.Object.Destroy(cmp);
                    }
                }
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: Component.DestroyOther");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    private static int CmpSetActive(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Component>(L, 1) as Component).gameObject.SetActive(LuaDLL.luaL_checkboolean(L, 2));
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_cmpActiveSelf(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, (ToLua.CheckObject<Component>(L, 1) as Component).gameObject.activeSelf);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region Transform
    public static void TransformReg(LuaState L)
    {
        L.BeginClass(typeof(Transform), typeof(Component));
        L.RegVar("localX", GetLocalX, SetLocalX);
        L.RegVar("localY", GetLocalY, SetLocalY);
        L.RegVar("localZ", GetLocalZ, SetLocalZ);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetLocalX(IntPtr L)
    {
        try
        {
            Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
            LuaDLL.lua_pushnumber(L, trans ? trans.localPosition.x : 0);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetLocalY(IntPtr L)
    {
        try
        {
            Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
            LuaDLL.lua_pushnumber(L, trans ? trans.localPosition.y : 0);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetLocalZ(IntPtr L)
    {
        try
        {
            Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
            LuaDLL.lua_pushnumber(L, trans ? trans.localPosition.z : 0);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetLocalX(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
            if (trans && LuaDLL.lua_isnumber(L, 2) != 0)
            {
                Vector3 pos = trans.localPosition;
                pos.x = (float)LuaDLL.lua_tonumber(L, 2);
                trans.localPosition = pos;
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetLocalY(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
            if (trans && LuaDLL.lua_isnumber(L, 2) != 0)
            {
                Vector3 pos = trans.localPosition;
                pos.y = (float)LuaDLL.lua_tonumber(L, 2);
                trans.localPosition = pos;
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetLocalZ(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
            if (trans && LuaDLL.lua_isnumber(L, 2) != 0)
            {
                Vector3 pos = trans.localPosition;
                pos.z = (float)LuaDLL.lua_tonumber(L, 2);
                trans.localPosition = pos;
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int TransDestroyChilds(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1)
            {
                Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
                Transform t = null;
                if (count >= 2)
                {
                    object obj = ToLua.ToObject(L, 2);
                    if (obj is Transform)
                    {
                        t = obj as Transform;
                    }
                    else if (obj is GameObject)
                    {
                        t = (obj as GameObject).transform;
                    }
                    else if (obj is Component)
                    {
                        t = (obj as Component).transform;
                    }
                }
                trans.DestroyAllChild(t);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int TransGetChild(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            Component ret = null;
            if (argCnt >= 2)
            {
                Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
                if (trans)
                {
                    if (TypeChecker.CheckType(L, typeof(string), 2))
                    {
                        ret = trans.FindChild(ToLua.CheckString(L, 2));
                    }
                    else if (TypeChecker.CheckType(L, typeof(int), 2))
                    {
                        ret = trans.GetChild((int)LuaDLL.lua_tonumber(L, 2));
                    }
                    if (ret && argCnt > 2)
                    {
                        if (TypeChecker.CheckType(L, typeof(string), 3))
                        {
                            ret = ret.GetComponent(ToLua.CheckString(L, 3));
                        }
                        else if (TypeChecker.CheckType(L, typeof(Type), 3))
                        {
                            ret = ret.GetComponent(ToLua.ToObject(L, 3) as Type);
                        }
                    }
                }
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int TransGetChildWidget(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            UIWidget ret = null;
            if (argCnt == 2)
            {
                Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
                if (trans)
                {
                    Transform child = null;
                    if (TypeChecker.CheckType(L, typeof(string), 2))
                    {
                        child = trans.FindChild(ToLua.CheckString(L, 2));
                    }
                    else if (TypeChecker.CheckType(L, typeof(int), 2))
                    {
                        child = trans.GetChild((int)LuaDLL.lua_tonumber(L, 2));
                    }
                    if (child)
                    {
                        ret = child.GetComponent<UIWidget>();
                    }
                }
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int TransGetChildButton(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            LuaButton ret = null;
            if (argCnt == 2)
            {
                Transform trans = ToLua.CheckObject<Transform>(L, 1) as Transform;
                if (trans)
                {
                    Transform child = null;
                    if (TypeChecker.CheckType(L, typeof(string), 2))
                    {
                        child = trans.FindChild(ToLua.CheckString(L, 2));
                    }
                    else if (TypeChecker.CheckType(L, typeof(int), 2))
                    {
                        child = trans.GetChild((int)LuaDLL.lua_tonumber(L, 2));
                    }
                    if (child)
                    {
                        ret = child.GetComponent<LuaButton>();
                    }
                }
            }
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region Material
    public static void MaterialReg(LuaState L)
    {
        //L.BeginClass(typeof(UnityEngine.Material), typeof(UnityEngine.Material));
        //L.RegFunction("IsMergeShader", IsMergeShader);
        //L.RegFunction("GetMergeTexture", GetMergeTexture);
        //L.RegFunction("SetMergeTexture", SetMergeTexture);
        //L.EndClass();
    }
    #endregion

    #region WWW
    public static void WWWReg(LuaState L)
    {
        L.BeginClass(typeof(WWW), typeof(System.Object));
        L.RegVar("errNotFound", Is404NotFound, null);
        L.RegVar("errBadLen", IsBadFileLength, null);
        L.RegVar("errRes", HasGetResError, null);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int HasGetResError(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            WWW www = ToLua.ToObject(L, 1) as WWW;
            LuaDLL.lua_pushboolean(L, www != null && www.HasGetResError());
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Is404NotFound(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            WWW www = ToLua.ToObject(L, 1) as WWW;
            LuaDLL.lua_pushboolean(L, www != null && www.Is404NotFound());
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsBadFileLength(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            WWW www = ToLua.ToObject(L, 1) as WWW;
            LuaDLL.lua_pushboolean(L, www != null && www.IsBadFileLength());
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region UIRect
    public static void UIRectReg(LuaState L)
    {
        L.BeginClass(typeof(UIRect), typeof(MonoBehaviour));
        L.RegFunction("ChangeAnchor", ChangeAnchor);
        L.EndClass();
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int ChangeAnchor(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 0)
            {
                UIRect rect = ToLua.CheckObject<UIRect>(L, 1) as UIRect;
                if (rect)
                {
                    //左 右 上 下
                    rect.leftAnchor.target = count > 1 ? GetTransform(L, 2) : null;
                    rect.rightAnchor.target = count > 2 ? GetTransform(L, 3) : null;
                    rect.topAnchor.target = count > 3 ? GetTransform(L, 4) : null;
                    rect.bottomAnchor.target = count > 4 ? GetTransform(L, 5) : null;
                    rect.ResetAnchors();
                    rect.UpdateAnchors();
                    return 0;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region UIWidget
    public static void UIWidgetReg(LuaState L)
    {
        L.BeginClass(typeof(UIWidget), typeof(UIRect));
        L.RegFunction("BindColor", BindColor);
        L.RegFunction("BindDepth", BindDepth);
        L.RegFunction("SetEnable", SetEnable);
        L.EndClass();
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int BindColor(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 0 && TypeChecker.CheckType(L, typeof(UIWidget), 1))
            {
                UIWidget w = ToLua.ToObject(L, 1) as UIWidget;
                if (w)
                {
                    if (count > 1)
                    {
                        UIWidget trg = ToLua.CheckObject<UIWidget>(L, 2) as UIWidget;
                        if (w != trg)
                        {
                            BindWidgetColor bwc = w.GetComponent<BindWidgetColor>() ?? w.cachedGameObject.AddComponent<BindWidgetColor>();
                            bwc.bind = trg;
                            bwc.defaultColor = count > 2 ? ToLua.CheckColor(L, 3) : Color.white;
                            return 0;
                        }
                    }
                    w.GetComponent<BindWidgetColor>().Destruct();
                    return 0;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int BindDepth(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 0 && TypeChecker.CheckType(L, typeof(UIWidget), 1))
            {
                UIWidget w = ToLua.ToObject(L, 1) as UIWidget;
                if (w)
                {
                    if (count > 1)
                    {
                        UIWidget trg = ToLua.CheckObject<UIWidget>(L, 2) as UIWidget;
                        if (w != trg)
                        {
                            BindWidgetDepth bwc = w.GetComponent<BindWidgetDepth>() ?? w.cachedGameObject.AddComponent<BindWidgetDepth>();
                            bwc.bind = trg;
                            bwc.depthOffset = count > 2 ? LuaDLL.luaL_checkinteger(L, 3) : 1;
                            return 0;
                        }
                    }
                    w.GetComponent<BindWidgetDepth>().Destruct();
                    return 0;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int SetEnable(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) > 1 && TypeChecker.CheckType(L, typeof(UIWidget), 1))
            {
                UIWidget w = ToLua.ToObject(L, 1) as UIWidget;
                if (w)
                {
                    bool enabled = LuaDLL.luaL_checkboolean(L, 2);
                    UIWidget[] ws = w.GetComponentsInAllChild<UIWidget>();
                    for (int i = 0; i < ws.Length; i++) ws[i].enabled = enabled;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region UIPanel
    public static void UIPanelReg(LuaState L)
    {
        L.BeginClass(typeof(UIPanel), typeof(UIRect));
        L.RegFunction("BindPanel", LBindPanel);
        L.EndClass();
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int LBindPanel(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 0 && TypeChecker.CheckType(L, typeof(UIPanel), 1))
            {
                UIPanel pnl = ToLua.ToObject(L, 1) as UIPanel;
                if (pnl)
                {
                    if (count > 1)
                    {
                        UIPanel trg = ToLua.CheckObject<UIPanel>(L, 2) as UIPanel;
                        if (pnl != trg)
                        {
                            BindPanel bp = pnl.GetComponent<BindPanel>() ?? pnl.cachedGameObject.AddComponent<BindPanel>();
                            bp.bind = trg;
                            bp.depthOffset = count > 2 ? LuaDLL.luaL_checkinteger(L, 3) : 1;
                            bp.bindEnable = count > 3 ? LuaDLL.luaL_checkboolean(L, 4) : true;
                            return 0;
                        }
                    }
                    pnl.GetComponent<BindWidgetColor>().Destruct();
                    return 0;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region UITexture
    public static void UITextureReg(LuaState L)
    {
        L.BeginClass(typeof(UITexture), typeof(UIBasicSprite));
        L.RegFunction("LoadTexAsync", LoadTexAsync);
        L.RegFunction("LoadTexSync", LoadTexSync);
        L.RegFunction("UnLoadTex", UnLoadTex);
        L.RegFunction("LoadAvatar", LoadAvatar);
        L.RegFunction("UnLoadAvatar", UnLoadAvatar);
        L.EndClass();
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int LoadTexAsync(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 0 && TypeChecker.CheckType(L, typeof(UITexture), 1))
            {
                UITexture utx = ToLua.ToObject(L, 1) as UITexture;
                if (utx)
                {
                    string assetName = count < 2 ? AssetName.DEFAUL_TTEXTURE : (ToLua.CheckString(L, 2) ?? AssetName.DEFAUL_TTEXTURE);
                    bool loadDefault = count < 3 || LuaDLL.lua_isboolean(L, 3) ? LuaDLL.lua_toboolean(L, 3) : true;
                    bool useAnim = count < 4 || LuaDLL.lua_isboolean(L, 4) ? LuaDLL.lua_toboolean(L, 4) : true;
                    bool isParallel = count < 5 || LuaDLL.lua_isboolean(L, 5) ? LuaDLL.lua_toboolean(L, 5) : true;
                    ToLua.Push(L, UITextureLoader.LoadAsync(utx, assetName, loadDefault, useAnim, isParallel));
                    return 1;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int LoadTexSync(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 0 && TypeChecker.CheckType(L, typeof(UITexture), 1))
            {
                UITexture utx = ToLua.ToObject(L, 1) as UITexture;
                if (utx)
                {
                    string assetName = count < 2 ? AssetName.DEFAUL_TTEXTURE : (ToLua.CheckString(L, 2) ?? AssetName.DEFAUL_TTEXTURE);
                    bool loadDefault = count < 3 || LuaDLL.lua_isboolean(L, 3) ? LuaDLL.lua_toboolean(L, 3) : true;
                    ToLua.Push(L, UITextureLoader.LoadSync(utx, assetName, loadDefault));
                    return 1;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnLoadTex(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 0 && TypeChecker.CheckType(L, typeof(UITexture), 1))
            {
                UITextureLoader.UnLoad(ToLua.ToObject(L, 1) as UITexture, count > 1 && LuaDLL.luaL_checkboolean(L, 2));
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int LoadAvatar(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 1 && TypeChecker.CheckType(L, typeof(UITexture), 1))
            {
                UITexture utx = ToLua.ToObject(L, 1) as UITexture;
                if (utx)
                {
                    string avaUrl = ToLua.CheckString(L, 2);
                    bool loadDefault = count < 2 || LuaDLL.lua_isboolean(L, 3) ? LuaDLL.lua_toboolean(L, 3) : true;
                    bool useAnim = count < 3 || LuaDLL.lua_isboolean(L, 4) ? LuaDLL.lua_toboolean(L, 4) : true;
                    ToLua.Push(L, AvatarLoader.LoadAvatar(utx, avaUrl, loadDefault, useAnim));
                    return 1;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnLoadAvatar(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(UITexture), 1))
            {
                AvatarLoader.UnLoadAvatar(ToLua.ToObject(L, 1) as UITexture);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region UISprite
    public static void UISpriteReg(LuaState L)
    {
        L.BeginClass(typeof(UISprite), typeof(UIBasicSprite));
        L.RegFunction("BeginTimer", BeginTimer);
        L.RegFunction("EndTimer", EndTimer);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int BeginTimer(IntPtr L)
    {
        try
        {
            int qty = LuaDLL.lua_gettop(L);
            if (qty >= 2)
            {
                UISpriteTimer.Begin(ToLua.CheckObject<UISprite>(L, 1) as UISprite, (float)LuaDLL.luaL_checknumber(L, 2), qty >= 3 ? (float)LuaDLL.luaL_checknumber(L, 3) : 0f);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int EndTimer(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            UISpriteTimer.End(ToLua.CheckObject<UISprite>(L, 1) as UISprite);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region UIScrollView
    public static void UIScrollViewReg(LuaState L)
    {
        L.BeginClass(typeof(UIScrollView), typeof(MonoBehaviour));
        L.RegFunction("ConstraintPivot", ConstraintPivot);
        L.RegFunction("MoveTo", MoveTo);
        L.EndClass();
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int ConstraintPivot(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 3 && TypeChecker.CheckTypes(L, 1, typeof(UIScrollView), typeof(UIWidget.Pivot), typeof(bool)))
            {
                UIScrollView usv = ToLua.ToObject(L, 1) as UIScrollView;
                if (usv)
                {
                    UIWidget.Pivot pivot = (UIWidget.Pivot)ToLua.ToObject(L, 2);
                    bool instant = LuaDLL.lua_toboolean(L, 3);
                    bool hideInactive = count >= 4 && LuaDLL.luaL_checkboolean(L, 4);
                    usv.ConstraintPivot(pivot, instant, hideInactive);
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    public static int MoveTo(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 2)
            {
                UIScrollView usv = ToLua.CheckObject(L, 1) as UIScrollView;
                if (usv)
                {
                    usv.MoveTo(ToLua.ToVector3(L, 2), count < 3 || LuaDLL.luaL_checkboolean(L, 3));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region UIInput
    public static void UIInputReg(LuaState L)
    {
        L.BeginClass(typeof(UIInput), typeof(MonoBehaviour));
        L.RegFunction("ClearText", ClearText);
        L.RegVar("hasInvChar", HasInvChar, null);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ClearText(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            UIInput ipt = ToLua.CheckObject<UIInput>(L, 1) as UIInput;
            ipt.value = "";
            ipt.label.text = ipt.defaultText;
            ipt.label.color = ipt.defaultColor;
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int HasInvChar(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            UIInput ipt = ToLua.CheckObject<UIInput>(L, 1) as UIInput;
            int size = 2;
            Font font = null;
            if (ipt.label)
            {
                font = ipt.label.trueTypeFont;
                size = ipt.label.fontSize;
            }
            LuaDLL.lua_pushboolean(L, ipt.value.HasInvisibleChar(font, size));
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region UIPopupList
    public static void UIPopupListReg(LuaState L)
    {
        L.BeginClass(typeof(UIPopupList), typeof(MonoBehaviour));
        L.RegFunction("SetData", SetData);
        L.RegFunction("InsertItem", InsertItem);
        L.RegFunction("RemoveItemAt", RemoveItemAt);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetData(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            UIPopupList pop = ToLua.CheckObject<UIPopupList>(L, 1) as UIPopupList;
            int idx = pop.itemData.IndexOf(ToLua.ToVarObject(L, 2));
            if (idx >= 0 && idx < pop.items.Count)
            {
                pop.Set(pop.items[idx]);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int InsertItem(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 3)
            {
                UIPopupList pop = (UIPopupList)ToLua.CheckObject(L, 1, typeof(UIPopupList));
                int idx = LuaDLL.luaL_checkinteger(L, 2);
                string txt = ToLua.CheckString(L, 3);
                pop.items.Insert(idx, txt);
                pop.itemData.Insert(idx, txt);
                return 0;
            }
            else if (count == 4)
            {
                UIPopupList pop = (UIPopupList)ToLua.CheckObject(L, 1, typeof(UIPopupList));
                int idx = LuaDLL.luaL_checkinteger(L, 2);
                string txt = ToLua.CheckString(L, 3);
                object dat = ToLua.ToVarObject(L, 4);
                pop.items.Insert(idx, txt);
                pop.itemData.Insert(idx, dat);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: UIPopupList.InsertItem");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int RemoveItemAt(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 2)
            {
                UIPopupList pop = (UIPopupList)ToLua.CheckObject(L, 1, typeof(UIPopupList));
                int idx = LuaDLL.luaL_checkinteger(L, 2);
                pop.items.RemoveAt(idx);
                pop.itemData.RemoveAt(idx);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: UIPopupList.RemoveItemAt");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion
}
#endif