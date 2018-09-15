#if TOLUA
using UnityEngine;
using LuaInterface;

public class LuaCmpFloat : MonoBehaviour
{
    [SerializeField] private LuaContainer mLuaContainer;
    [SerializeField] private bool mTransferSelf = false;
    [SerializeField] private string mLeaveFocus;

    [System.NonSerialized] private LuaFunction mFunc;
    private Transform mTrans;

    private void Start()
    {
        mTrans = transform;
        if (mLuaContainer)
        {
            mLuaContainer.onBindToLua += OnBindToLua;
            mLuaContainer.onBindFunctionReplaced += OnBindFunctionReplaced;
            OnBindToLua();
        }
    }

    private void OnBindToLua()
    {
        if (mLuaContainer == null || string.IsNullOrEmpty(mLeaveFocus)) return;
        mFunc = mLuaContainer.GetBindFunction(mLeaveFocus);
    }

    public void SetContainer(LuaContainer lc)
    {
        if (lc == mLuaContainer) return;
        if (mLuaContainer)
        {
            mLuaContainer.onBindToLua -= OnBindToLua;
            mLuaContainer.onBindFunctionReplaced -= OnBindFunctionReplaced;
        }
        if (mFunc != null && string.IsNullOrEmpty(mFunc.bindName)) mFunc.Dispose();
        mLuaContainer = lc;
        if (mLuaContainer)
        {
            mLuaContainer.onBindToLua += OnBindToLua;
            mLuaContainer.onBindFunctionReplaced += OnBindFunctionReplaced;
            OnBindToLua();
        }
    }

    private void OnBindFunctionReplaced(string func)
    {
        if (mLeaveFocus == func) SetListener(func);
    }

    public void SetListener(string func)
    {
        mLeaveFocus = func;
        if (mFunc != null && string.IsNullOrEmpty(mFunc.bindName)) mFunc.Dispose();
        mFunc = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }

    public void SetListener(LuaFunction func)
    {
        mLeaveFocus = func == null ? null : func.bindName;
        if (mFunc != null && string.IsNullOrEmpty(mFunc.bindName)) mFunc.Dispose();
        mFunc = func;
    }

    private void OnEnable() { UICamera.onPress += OnPress; }

    private void OnDisable() { UICamera.onPress -= OnPress; }

    private void OnPress(GameObject go, bool pressed)
    {
        if (pressed && this && mTrans != go.transform && !NGUITools.IsChild(mTrans, go.transform))
        {
            if (mFunc == null) return;
            if (!mFunc.IsAlive)
            {
                if (mLuaContainer == null) return;
                mFunc = mLuaContainer.GetBindFunction(mFunc.bindName);
                if (mFunc == null) return;
            }
            mFunc.BeginPCall();
            if (mLuaContainer && mLuaContainer.isInstance) mFunc.Push(mLuaContainer.luaTable);
            if (mTransferSelf) mFunc.Push(this);
            mFunc.PCall();
            mFunc.EndPCall();
        }
    }

    #region Lua注册
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(LuaCmpFloat), typeof(MonoBehaviour));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("SetListener", SetListener);
        L.RegVar("transferSelf", get_transferSelf, set_transferSelf);
        L.RegVar("luaContainer", tet_luaContainer, set_luaContainer);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetListener(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);
            if (count == 2)
            {
                LuaCmpFloat btn = ToLua.CheckObject<LuaCmpFloat>(lua, 1) as LuaCmpFloat;
                if (LuaTypes.LUA_TFUNCTION == LuaDLL.lua_type(lua, 2))
                {
                    btn.SetListener(ToLua.ToLuaFunction(lua, 2));
                }
                else
                {
                    btn.SetListener(ToLua.CheckString(lua, 2));
                }
                return 0;
            }


            return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaFloatCmp.SetListener");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_transferSelf(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(LuaCmpFloat), 1))
            {
                LuaDLL.lua_pushboolean(lua, ((LuaCmpFloat)ToLua.ToObject(lua, 1)).mTransferSelf);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaFloatCmp.GetTransferSelf");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_transferSelf(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaCmpFloat), typeof(bool)))
            {
                ((LuaCmpFloat)ToLua.ToObject(lua, 1)).mTransferSelf = (bool)LuaDLL.luaL_checkboolean(lua, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaFloatCmp.SetTransferSelf");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int tet_luaContainer(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(LuaCmpFloat), 1))
            {
                ToLua.Push(lua, ((LuaCmpFloat)ToLua.ToObject(lua, 1)).mLuaContainer);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaFloatCmp.GetLuaContainer");
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

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaCmpFloat), typeof(LuaContainer)))
            {
                ((LuaCmpFloat)ToLua.ToObject(lua, 1)).SetContainer((LuaContainer)ToLua.ToObject(lua, 2));
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaFloatCmp.SetLuaContainer");
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
    #endregion
}
#endif