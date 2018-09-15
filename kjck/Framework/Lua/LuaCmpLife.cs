#if TOLUA
using System;
using UnityEngine;
using LuaInterface;

public class LuaCmpLife : MonoBehaviour
{
    [SerializeField] private LuaContainer mLuaContainer;
    [SerializeField] private string mStart;
    [SerializeField] private string mOnEnable;
    [SerializeField] private string mOnDisable;
    [SerializeField] private string mOnDestroy;

    [NonSerialized] private LuaFunction mStartFunc;
    [NonSerialized] private LuaFunction mOnEnableFunc;
    [NonSerialized] private LuaFunction mOnDisableFunc;
    [NonSerialized] private LuaFunction mOnDestroyFunc;

    [NonSerialized] private GameObject mGo;

    private void OnBindToLua()
    {
        if (!mLuaContainer) return;
        mStartFunc = mLuaContainer.GetBindFunction(mStart);
        mOnEnableFunc = mLuaContainer.GetBindFunction(mOnEnable);
        mOnDisableFunc = mLuaContainer.GetBindFunction(mOnDisable);
        mOnDestroyFunc = mLuaContainer.GetBindFunction(mOnDestroy);
    }
    private void OnBindFunctionReplaced(string func)
    {
        if (mStart == func) SetStart(func);
        else if (mOnEnable == func) SetOnEnable(func);
        else if (mOnDisable == func) SetOnDisable(func);
        else if (mOnDestroy == func) SetOnDestroy(func);
    }

    public void SetContainer(LuaContainer lc)
    {
        if (lc == mLuaContainer) return;
        mLuaContainer = lc;
        if (mLuaContainer)
        {
            OnBindToLua();
        }
    }

    public void ClearEvent()
    {
        mStart = null;
        mStartFunc = null;
        mOnEnable = null;
        mOnEnableFunc = null;
        mOnDisable = null;
        mOnDisableFunc = null;
        mOnDestroy = null;
        mOnDestroyFunc = null;
    }

    public void SetStart(string func)
    {
        mStart = func;
        mStartFunc = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetOnEnable(string func)
    {
        mOnEnable = func;
        mOnEnableFunc = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetOnDisable(string func)
    {
        mOnDisable = func;
        mOnDisableFunc = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetOnDestroy(string func)
    {
        mOnDestroy = func;
        mOnDestroyFunc = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }

    private void Start()
    {
        mGo = gameObject;

        if (mLuaContainer == null) mLuaContainer = GetComponentInChildren<LuaContainer>();
        if (mLuaContainer)
        {
            mLuaContainer.onBindToLua += OnBindToLua;
            mLuaContainer.onBindFunctionReplaced += OnBindFunctionReplaced;
            OnBindToLua();

            if (mLuaContainer.NoFunction(ref mStartFunc)) return;
            if (mLuaContainer.isInstance)
            {
                mStartFunc.Call(mLuaContainer.luaTable, mGo);
            }
            else
            {
                mStartFunc.Call(mGo);
            }
        }
    }

    private void OnEnable()
    {
        if (mLuaContainer == null || mLuaContainer.NoFunction(ref mOnEnableFunc)) return;
        if (mLuaContainer.isInstance)
        {
            mOnEnableFunc.Call(mLuaContainer.luaTable, mGo);
        }
        else
        {
            mOnEnableFunc.Call(mGo);
        }
    }

    private void OnDisable()
    {
        if (mLuaContainer == null || mLuaContainer.NoFunction(ref mOnDisableFunc)) return;
        if (mLuaContainer.isInstance)
        {
            mOnDisableFunc.Call(mLuaContainer.luaTable, mGo);
        }
        else
        {
            mOnDisableFunc.Call(mGo);
        }
    }

    private void OnDestroy()
    {
        if (mLuaContainer)
        {
            mLuaContainer.onBindToLua -= OnBindToLua;
            mLuaContainer.onBindFunctionReplaced -= OnBindFunctionReplaced;
            if (mLuaContainer.NoFunction(ref mOnDestroyFunc)) return;
            if (mLuaContainer.isInstance)
            {
                mOnDestroyFunc.Call(mLuaContainer.luaTable, mGo);
            }
            else
            {
                mOnDestroyFunc.Call(mGo);
            }
        }
    }

    #region Lua注册
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(LuaCmpLife), typeof(MonoBehaviour));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("ClearEvent", ClearEvent);
        L.RegFunction("SetStart", SetStart);
        L.RegFunction("SetOnDisable", SetOnDisable);
        L.RegFunction("SetOnEnable", SetOnEnable);
        L.RegFunction("SetOnDestroy", SetOnDestroy);
        L.RegVar("luaContainer", tet_luaContainer, set_luaContainer);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ClearEvent(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(LuaCmpLife)))
            {
                ((LuaCmpLife)ToLua.ToObject(L, 1)).ClearEvent();
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaCmpLife.ClearEvent");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetStart(System.IntPtr lua) { return SetLuaFunction(lua, (cmp, func) => { cmp.SetStart(func); }); }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetOnEnable(System.IntPtr lua) { return SetLuaFunction(lua, (cmp, func) => { cmp.SetOnEnable(func); }); }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetOnDisable(System.IntPtr lua) { return SetLuaFunction(lua, (cmp, func) => { cmp.SetOnDisable(func); }); }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetOnDestroy(System.IntPtr lua) { return SetLuaFunction(lua, (cmp, func) => { cmp.SetOnDestroy(func); }); }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int tet_luaContainer(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(LuaCmpLife), 1))
            {
                ToLua.Push(lua, ((LuaCmpLife)ToLua.ToObject(lua, 1)).mLuaContainer);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaCmpLife.GetLuaContainer");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_luaContainer(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaCmpLife), typeof(LuaContainer)))
            {
                ((LuaCmpLife)ToLua.ToObject(lua, 1)).SetContainer((LuaContainer)ToLua.ToObject(lua, 2));
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaCmpLife.SetLuaContainer");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
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

    private static int SetLuaFunction(System.IntPtr lua, Action<LuaCmpLife, string> transfer)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count >= 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaCmpLife), typeof(string)))
            {
                string func = ToLua.ToString(lua, 2);
                if (string.IsNullOrEmpty(func)) return 0;
                transfer(ToLua.ToObject(lua, 1) as LuaCmpLife, func);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaCmpLife.SetLuaFunction");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    #endregion
}
#endif