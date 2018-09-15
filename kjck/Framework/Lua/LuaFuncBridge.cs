#if TOLUA
using UnityEngine;
using LuaInterface;

public abstract class LuaFuncBridge : MonoBehaviour
{
    [SerializeField] protected LuaContainer mLua;
    [SerializeField] protected bool mTransferSelf;
    [SerializeField] protected string[] mFuncName;

    [System.NonSerialized] protected LuaFunction[] mLuaFunc;
    [System.NonSerialized] protected object mParam;

    private void Start()
    {
        mLuaFunc = mFuncName == null ? null : new LuaFunction[mFuncName.Length];
        if (!mLua) mLua = GetComponent<LuaContainer>();
        if (mLua)
        {
            mLua.onBindToLua += OnBindToLua;
            mLua.onBindFunctionReplaced += OnBindFunctionReplaced;
            OnBindToLua();
        }
    }

    protected virtual void OnBindToLua()
    {
        if (mLua && mFuncName != null && mLuaFunc != null)
        {
            for (int i = 0; i < mFuncName.Length && i < mLuaFunc.Length; i++)
            {
                mLuaFunc[i] = mLua.GetBindFunction(mFuncName[i]);
            }
        }
    }

    protected virtual void OnBindFunctionReplaced(string func)
    {
        if (mLua && mFuncName != null && mLuaFunc != null)
        {
            for (int i = 0; i < mFuncName.Length && i < mLuaFunc.Length; i++)
            {
                if (mFuncName[i] == func)
                {
                    mLuaFunc[i] = mLua.GetBindFunction(func);
                }
            }
        }
    }

    protected virtual void OnSetFunction(int index, string func)
    {
        if (mLua && CheckFuncCount(index + 1) && mFuncName.IndexAvailable(index) && mLuaFunc.IndexAvailable(index))
        {
            mFuncName[index] = func;
            mLuaFunc[index] = mLua.GetBindFunction(func);
        }
    }

    public void CheckFuncCount()
    {
        if (mFuncName == null) mFuncName = new string[MaxFuncCount];
        else if (mFuncName.Length != MaxFuncCount) System.Array.Resize(ref mFuncName, MaxFuncCount);
        if (mLuaFunc == null) mLuaFunc = new LuaFunction[MaxFuncCount];
        else if (mLuaFunc.Length != MaxFuncCount) System.Array.Resize(ref mLuaFunc, MaxFuncCount);
    }

    public bool CheckFuncCount(int count)
    {
        if (count > MaxFuncCount) return false;
        if (mFuncName == null) mFuncName = new string[count];
        else if (mFuncName.Length < count) System.Array.Resize(ref mFuncName, count);
        if (mLuaFunc == null) mLuaFunc = new LuaFunction[count];
        else if (mLuaFunc.Length < count) System.Array.Resize(ref mLuaFunc, count);
        return true;
    }

    public virtual byte MaxFuncCount { get { return 1; } }

    protected virtual void CallFunction(int index)
    {
        if (mLua && mLuaFunc.IndexAvailable(index))
        {
            if (mLua.NoFunction(ref mLuaFunc[index])) return;
            mLuaFunc[index].BeginPCall();
            if (mLua.isInstance) mLuaFunc[index].Push(mLua.luaTable);
            if (mTransferSelf) mLuaFunc[index].Push(this);
            if (mParam != null) mLuaFunc[index].Push(mParam);
            mLuaFunc[index].PCall();
            mLuaFunc[index].EndPCall();
        }
    }
    protected virtual void CallFunction(int index, System.Action<LuaFunction> pushArg)
    {
        if (mLua && mLuaFunc.IndexAvailable(index))
        {
            if (mLua.NoFunction(ref mLuaFunc[index])) return;
            mLuaFunc[index].BeginPCall();
            if (mLua.isInstance) mLuaFunc[index].Push(mLua.luaTable);
            if (mTransferSelf) mLuaFunc[index].Push(this);
            if (pushArg != null) pushArg(mLuaFunc[index]);
            if (mParam != null) mLuaFunc[index].Push(mParam);
            mLuaFunc[index].PCall();
            mLuaFunc[index].EndPCall();
        }
    }

    protected virtual void Clear()
    {
        if (mFuncName != null) System.Array.Clear(mFuncName, 0, mFuncName.Length);
        if (mLuaFunc != null) System.Array.Clear(mLuaFunc, 0, mLuaFunc.Length);
    }

    private void SetContainer(LuaContainer lc)
    {
        if (lc == mLua) return;
        mLua = lc;
        OnBindToLua();
    }

    private void OnDestroy()
    {
        if (mLua)
        {
            mLua.onBindToLua -= OnBindToLua;
            mLua.onBindFunctionReplaced -= OnBindFunctionReplaced;
        }
    }

    #region LUA注册
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(LuaFuncBridge), typeof(MonoBehaviour));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("Clear", Clear);
        L.RegFunction("SetFunction", SetFunction);
        L.RegFunction("CheckFuncCount", CheckFuncCount);
        L.RegVar("transferSelf", get_transferSelf, set_transferSelf);
        L.RegVar("luaContainer", get_luaContainer, set_luaContainer);
        L.RegVar("param", get_param, set_param);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Clear(System.IntPtr lua)
    {
        try
        {
            if (LuaDLL.lua_gettop(lua) == 1 && TypeChecker.CheckTypes(lua, 1, typeof(LuaFuncBridge)))
            {
                ((LuaFuncBridge)ToLua.ToObject(lua, 1)).Clear();
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaEventBridge.Clear");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CheckFuncCount(System.IntPtr lua)
    {
        try
        {
            if (LuaDLL.lua_gettop(lua) == 1 && TypeChecker.CheckTypes(lua, 1, typeof(LuaFuncBridge)))
            {
                ((LuaFuncBridge)ToLua.ToObject(lua, 1)).CheckFuncCount();
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaEventBridge.CheckFuncCount");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetFunction(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 3 && TypeChecker.CheckTypes(lua, 1, typeof(LuaFuncBridge), typeof(int), typeof(string)))
            {
                string func = ToLua.ToString(lua, 2);
                if (string.IsNullOrEmpty(func)) return 0;
                LuaFuncBridge obj = (LuaFuncBridge)ToLua.ToObject(lua, 1);
                obj.OnSetFunction((int)LuaDLL.luaL_checknumber(lua, 2), ToLua.ToString(lua, 3));
                if (count >= 3) obj.mParam = ToLua.ToVarObject(lua, 3);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaEventBridge.SetFunction");
            }
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

            if (count == 1 && TypeChecker.CheckType(lua, typeof(LuaFuncBridge), 1))
            {
                LuaDLL.lua_pushboolean(lua, ((LuaFuncBridge)ToLua.ToObject(lua, 1)).mTransferSelf);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaEventBridge.GetTransferSelf");
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

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaFuncBridge), typeof(bool)))
            {
                ((LuaFuncBridge)ToLua.ToObject(lua, 1)).mTransferSelf = (bool)LuaDLL.luaL_checkboolean(lua, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaEventBridge.SetTransferSelf");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_luaContainer(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(LuaFuncBridge), 1))
            {
                ToLua.Push(lua, ((LuaFuncBridge)ToLua.ToObject(lua, 1)).mLua);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaEventBridge.GetLuaContainer");
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

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaFuncBridge), typeof(LuaContainer)))
            {
                ((LuaFuncBridge)ToLua.ToObject(lua, 1)).SetContainer((LuaContainer)ToLua.ToObject(lua, 2));
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaEventBridge.SetLuaContainer");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_param(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(LuaFuncBridge), 1))
            {
                ToLua.Push(lua, ((LuaFuncBridge)ToLua.ToObject(lua, 1)).mParam);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaEventBridge.GetParam");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_param(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaFuncBridge)))
            {
                ((LuaFuncBridge)ToLua.ToObject(lua, 1)).mParam = ToLua.ToObject(lua, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaEventBridge.SetParam");
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