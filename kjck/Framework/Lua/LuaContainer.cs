#if TOLUA
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;

public class LuaContainer : MonoBehaviour
{
    public enum LoadType
    {
        None = 0,
        SpecificName = 1,
        TextAsset = 2,
    }

    private const string FUNC_ONLOAD = "OnLoad";
    private const string FUNC_ONUNLOAD = "OnUnLoad";

    [System.NonSerialized] private Dictionary<string, LuaFunction> mLuaFunction = new Dictionary<string,LuaFunction>();
    [System.NonSerialized] protected LuaTable mLua = null;
    [NoToLua][System.NonSerialized] public System.Action onBindToLua = null;
    [NoToLua][System.NonSerialized] public System.Action<string> onBindFunctionReplaced = null;
    [NoToLua][System.NonSerialized] public System.Action<string> onBindFunctionRmoved = null;

    [SerializeField] private LoadType mLoadType = LoadType.None;
    [SerializeField] private string mScriptName;
    [SerializeField] private TextAsset mScriptData;
    [SerializeField] private bool mIsInstance = false;
    [NoToLua][SerializeField] public LuaSerializeRef srf;
    [SerializeField] private LuaAssetLoader mAssetLoader;

    public bool isInstance { get { return mIsInstance; } }

    public LuaTable luaTable
    {
        get { return NoTable ? null : mLua; }
        set
        {
            if (mLua == value) return;
            Dispose();
            mLua = (value == null || !value.IsAlive) ? null : value;
            OnBindToLua();
        }
    }

    protected virtual void Awake()
    {
        if (!srf) srf = GetComponent<LuaSerializeRef>();
        if (mLoadType == LoadType.None) return;
        if (!mAssetLoader) mAssetLoader = GetComponent<LuaAssetLoader>();
        LoadLuaTable();
        OnBindToLua();
    }

    public void Load(string scriptName)
    {
        if (mLoadType == LoadType.SpecificName && scriptName == mScriptName) return;
        Dispose();
        if (string.IsNullOrEmpty(scriptName)) return;
        mLoadType = LoadType.SpecificName;
        mScriptName = scriptName;
        LoadLuaTable();
        OnBindToLua();
    }

    public void Load(TextAsset scriptData)
    {
        if (mLoadType == LoadType.TextAsset && scriptData && mScriptData && scriptData.name == mScriptData.name) return;
        Dispose();
        if (!scriptData) return;
        mLoadType = LoadType.TextAsset;
        mScriptData = scriptData;
        LoadLuaTable();
        OnBindToLua();
    }

    private void LoadLuaTable()
    {
        if (mLua != null && mLua.IsAlive) return;
        if (mLoadType == LoadType.SpecificName)
        {
            mLua = mIsInstance ? LuaManager.CreatLuaTable(mScriptName) : LuaManager.GetLuaTable(mScriptName);
        }
        else if (mLoadType == LoadType.TextAsset)
        {
            mLua = mIsInstance ? LuaManager.CreatLuaTable(mScriptData) : LuaManager.GetLuaTable(mScriptData);
        }
        else
        {
            mLua = null;
        }
    }

    protected bool NoTable { get { if (mLua == null) return true; if (mLua.IsAlive) return false; LoadLuaTable(); return mLua == null; } }
    [NoToLua]
    public bool NoFunction(ref LuaFunction luafunc)
    {
        if (luafunc == null) return true;
        if (luafunc.IsAlive) return false;
        luafunc = GetBindFunction(luafunc.bindName);
        return luafunc == null;
    }

    protected virtual void OnBindToLua()
    {
        if (mLua == null) return;
        LuaFunction func = mLua.GetLuaFunction(FUNC_ONLOAD);
        if (func == null) return;
        func.BeginPCall();
        if (mIsInstance) func.Push(mLua);
        func.PushObject(this);
        func.PCall();
        func.EndPCall();
        func.Dispose();
        func = null;
        if (onBindToLua == null) return;
        onBindToLua();
    }

    protected virtual void OnBindFunctionReplaced(string func) { if (onBindFunctionReplaced != null) onBindFunctionReplaced(func); }
    protected virtual void OnBindFunctionRemoved(string func) { if (onBindFunctionRmoved != null) onBindFunctionRmoved(func); }

    protected virtual void OnDestroy()
    {
        onBindToLua = null;
        onBindFunctionReplaced = null;
        onBindFunctionRmoved = null;
        CallFunction("OnDestroy");
        Dispose();
    }

    private void Dispose()
    {
        CallFunction(FUNC_ONUNLOAD, this);
        foreach (LuaFunction func in mLuaFunction.Values)
        {
            if (func == null) continue;
            func.Dispose();
        }
        mLuaFunction.Clear();
        if (mLua == null) return;
        mLua.Dispose();
        mLua = null;
    }

    [NoToLua]
    protected LuaFunction BindFunction(string func)
    {
        if (string.IsNullOrEmpty(func) || NoTable) return null;
        LuaFunction luafunc = mLua.GetLuaFunction(func);
        if (luafunc == null) return null;
        luafunc.name = null;
        luafunc.bindName = func;
        LuaFunction old = null;
        if (mLuaFunction.TryGetValue(func, out old))
        {
            if (luafunc == old)
            {
                luafunc.Dispose();
                return luafunc;
            }
#if TEST || UNITY_EDITOR
            Debug.LogWarning("[" + name + "]LuaFunction.BindFunction(" + func + ")replaced)");
#endif
            if (old != null) old.Dispose();
        }
        mLuaFunction[func] = luafunc;
        if (old != null) OnBindFunctionReplaced(func);
        return luafunc;
    }
    [NoToLua]
    public bool RemoveBind(string func)
    {
        LuaFunction luafunc = null;
        if (mLuaFunction.TryGetValue(func, out luafunc))
        {
            if(mIsInstance)
            {
                LuaManager.SafeDisposeFunction(luafunc);
            }
            else
            {
                LuaManager.SafeDisposeFunction(luafunc, 1);
            }
            mLuaFunction.Remove(func);
            OnBindFunctionRemoved(func);
            return true;
        }
        return false;
    }

    [NoToLua]
    public LuaFunction GetBindFunction(string func)
    {
        if (string.IsNullOrEmpty(func)) return null;
        LuaFunction luaFunc = null;
        if (mLuaFunction.TryGetValue(func, out luaFunc) && (luaFunc == null || !luaFunc.IsAlive))
        {
            luaFunc = BindFunction(func);
            if (luaFunc == null) mLuaFunction.Remove(func);
            else mLuaFunction[func] = luaFunc;
        }
        return luaFunc;
    }

    [NoToLua]
    public bool CallFunction(ref LuaFunction luafunc)
    {
        if (luafunc == null) return false;
        if (!luafunc.IsAlive)
        {
            luafunc = GetBindFunction(luafunc.bindName);
            if (luafunc == null) return false;
        }
        luafunc.BeginPCall();
        if (isInstance) luafunc.Push(luaTable);
        luafunc.PCall();
        luafunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(ref LuaFunction luafunc, bool arg)
    {
        if (luafunc == null) return false;
        if (!luafunc.IsAlive)
        {
            luafunc = GetBindFunction(luafunc.bindName);
            if (luafunc == null) return false;
        }
        luafunc.BeginPCall();
        if (isInstance) luafunc.Push(luaTable);
        luafunc.Push(arg);
        luafunc.PCall();
        luafunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(ref LuaFunction luafunc, Object arg)
    {
        if (luafunc == null) return false;
        if (!luafunc.IsAlive)
        {
            luafunc = GetBindFunction(luafunc.bindName);
            if (luafunc == null) return false;
        }
        luafunc.BeginPCall();
        if (isInstance) luafunc.Push(luaTable);
        luafunc.Push(arg);
        luafunc.PCall();
        luafunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(ref LuaFunction luafunc, object arg)
    {
        if (luafunc == null) return false;
        if (!luafunc.IsAlive)
        {
            luafunc = GetBindFunction(luafunc.bindName);
            if (luafunc == null) return false;
        }
        luafunc.BeginPCall();
        if (isInstance) luafunc.Push(luaTable);
        luafunc.Push(arg);
        luafunc.PCall();
        luafunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(ref LuaFunction luafunc, params object[] args)
    {
        if (luafunc == null) return false;
        if (!luafunc.IsAlive)
        {
            luafunc = GetBindFunction(luafunc.bindName);
            if (luafunc == null) return false;
        }
        luafunc.BeginPCall();
        if (isInstance) luafunc.Push(luaTable);
        luafunc.PushArgs(args);
        luafunc.PCall();
        luafunc.EndPCall();
        return true;
    }

    [NoToLua]
    public bool CallFunction(string func)
    {
        LuaFunction luaFunc = GetBindFunction(func);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mIsInstance) luaFunc.Push(luaTable);
        luaFunc.PCall();
        luaFunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(string func, bool arg)
    {
        LuaFunction luaFunc = GetBindFunction(func);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mIsInstance) luaFunc.Push(luaTable);
        luaFunc.Push(arg);
        luaFunc.PCall();
        luaFunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(string func, int arg)
    {
        LuaFunction luaFunc = GetBindFunction(func);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mIsInstance) luaFunc.Push(luaTable);
        luaFunc.Push(arg);
        luaFunc.PCall();
        luaFunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(string func, float arg)
    {
        LuaFunction luaFunc = GetBindFunction(func);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mIsInstance) luaFunc.Push(luaTable);
        luaFunc.Push(arg);
        luaFunc.PCall();
        luaFunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(string func, string arg)
    {
        LuaFunction luaFunc = GetBindFunction(func);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mIsInstance) luaFunc.Push(luaTable);
        luaFunc.Push(arg);
        luaFunc.PCall();
        luaFunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(string func, Object arg)
    {
        LuaFunction luaFunc = GetBindFunction(func);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mIsInstance) luaFunc.Push(luaTable);
        luaFunc.Push(arg);
        luaFunc.PCall();
        luaFunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(string func, object arg)
    {
        LuaFunction luaFunc = GetBindFunction(func);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mIsInstance) luaFunc.Push(luaTable);
        luaFunc.Push(arg);
        luaFunc.PCall();
        luaFunc.EndPCall();
        return true;
    }
    [NoToLua]
    public bool CallFunction(string func, params object[] args)
    {
        LuaFunction luaFunc = GetBindFunction(func);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mIsInstance) luaFunc.Push(luaTable);
        luaFunc.PushArgs(args);
        luaFunc.PCall();
        luaFunc.EndPCall();
        return true;
    }

    #region 辅助函数
    public void Invoke(LuaFunction luaFunc, float delay)
    {
        if (luaFunc == null) return;
        if (delay > 0f)
        {
            StartCoroutine(OnInvoke(luaFunc, delay));
        }
        else
        {
            luaFunc.Call(); luaFunc.Dispose(); luaFunc = null;
        }
    }
    private IEnumerator OnInvoke(LuaFunction luaFunc, float delay)
    {
        yield return new WaitForSeconds(delay);
        if (luaFunc.IsAlive)
        {
            luaFunc.Call(); luaFunc.Dispose(); luaFunc = null;
        }
    }
    public void Invoke(LuaFunction luaFunc, float delay, params object[] arg)
    {
        if (luaFunc == null) return;
        if (delay > 0f)
        {
            StartCoroutine(OnInvoke(luaFunc, delay, arg));
        }
        else
        {

            luaFunc.BeginPCall(); luaFunc.PushArgs(arg); luaFunc.PCall(); luaFunc.EndPCall(); luaFunc.Dispose(); luaFunc = null;
        }
    }
    private IEnumerator OnInvoke(LuaFunction luaFunc, float delay, params object[] arg)
    {
        yield return new WaitForSeconds(delay);
        if (luaFunc.IsAlive)
        {
            luaFunc.BeginPCall(); luaFunc.PushArgs(arg); luaFunc.PCall(); luaFunc.EndPCall(); luaFunc.Dispose(); luaFunc = null;
        }
    }
    #endregion

    #region LUA注册
    [NoToLua]
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(LuaContainer), typeof(MonoBehaviour));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("Load", Load);
        L.RegFunction("BindFunction", BindFunction);
        L.RegFunction("RemoveBind", RemoveBind);
        L.RegFunction("LoadAssetAsync", LuaLoadAssetAsync);
        L.RegFunction("LoadAsset", LuaLoadAsset);
        L.RegFunction("GetAsset", LuaGetAsset);
        L.RegFunction("DisposeAsset", LuaDisposeAsset);
        L.RegFunction("Invoke", Invoke);
        L.RegVar("srf", LuaGetSrf, null);
        L.RegVar("gos", LuaGetSrfGo, null);
        L.RegVar("cmps", LuaGetSrfCmp, null);
        L.RegVar("btns", LuaGetSrfBtn, null);
        L.RegVar("widgets", LuaGetSrfWdg, null);
        L.RegVar("objs", LuaGetSrfObj, null);
        L.RegVar("luaTable", LuaGetTable, LuaSetTable);
        L.RegVar("isInstance", LuaGetIsInstance, null);
        L.RegVar("assetLoader", LuaGetAssetLoader, null);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Load(System.IntPtr L)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(L))
            {
                LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
                if (lc)
                {
                    LuaTypes luaType = LuaDLL.lua_type(L, 2);
                    switch (luaType)
                    {
                        case LuaTypes.LUA_TSTRING: lc.Load(LuaDLL.lua_tostring(L, 2)); return 0;
                        case LuaTypes.LUA_TUSERDATA:
                            object obj = ToLua.ToObject(L, 2);
                            if (obj is string) { lc.Load(obj as string); return 0; }
                            if (obj is TextAsset) { lc.Load(obj as TextAsset); return 0; }
                            break;
                        default: break;
                    }
                }
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaContainer.Load");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int BindFunction(System.IntPtr L)
    {
        try
        {
            int qty = LuaDLL.lua_gettop(L);
            if (qty == 2)
            {
                (ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer).BindFunction(ToLua.ToString(L, 2));
                return 0;
            }
            if (qty > 2)
            {
                LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
                for (int i = 2; i <= qty; i++)
                {
                    lc.BindFunction(ToLua.ToString(L, i));
                }
                return 0;
            }
            throw new LuaException(string.Format("no overload for method takes '{0}' arguments", qty));
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int RemoveBind(System.IntPtr L)
    {
        try
        {
            int qty = LuaDLL.lua_gettop(L);
            if (qty == 2)
            {
                (ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer).RemoveBind(ToLua.ToString(L, 2));
                return 0;
            }
            if (qty > 2)
            {
                LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
                for (int i = 2; i <= qty; i++)
                {
                    lc.RemoveBind(ToLua.ToString(L, i));
                }
                return 0;
            }
            throw new LuaException(string.Format("no overload for method takes '{0}' arguments", qty));
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetTable(System.IntPtr L)
    {
        try
        {
            LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
            ToLua.Push(L, lc ? lc.mLua : null);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaSetTable(System.IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer).luaTable = ToLua.CheckLuaTable(L, 2);
            return 0;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetIsInstance(System.IntPtr L)
    {
        try
        {
            LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
            ToLua.Push(L, lc && lc.mIsInstance);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetSrf(System.IntPtr L)
    {
        try
        {
            LuaContainer lc = ToLua.ToObject(L, 1) as LuaContainer;
            if (lc)
            {
                ToLua.Push(L, lc.srf);
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetSrfGo(System.IntPtr L)
    {
        try
        {
            LuaContainer lc = ToLua.ToObject(L, 1) as LuaContainer;
            if (lc && lc.srf)
            {
                ToLua.Push(L, lc.srf.gameObjects);
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetSrfCmp(System.IntPtr L)
    {
        try
        {
            LuaContainer lc = ToLua.ToObject(L, 1) as LuaContainer;
            if (lc && lc.srf)
            {
                ToLua.Push(L, lc.srf.cmps);
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetSrfBtn(System.IntPtr L)
    {
        try
        {
            LuaContainer lc = ToLua.ToObject(L, 1) as LuaContainer;
            if (lc && lc.srf)
            {
                ToLua.Push(L, lc.srf.buttons);
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetSrfWdg(System.IntPtr L)
    {
        try
        {
            LuaContainer lc = ToLua.ToObject(L, 1) as LuaContainer;
            if (lc && lc.srf)
            {
                ToLua.Push(L, lc.srf.widgets);
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetSrfObj(System.IntPtr L)
    {
        try
        {
            LuaContainer lc = ToLua.ToObject(L, 1) as LuaContainer;
            if (lc && lc.srf)
            {
                ToLua.Push(L, lc.srf.objects);
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetAssetLoader(System.IntPtr L)
    {
        try
        {
            LuaContainer lc = ToLua.ToObject(L, 1) as LuaContainer;
            if (lc && lc.mAssetLoader)
            {
                ToLua.Push(L, lc.mAssetLoader);
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaLoadAssetAsync(System.IntPtr L)
    {
        try
        {
            int qty = LuaDLL.lua_gettop(L);
            if (qty < 2)
            {
                throw new LuaException(string.Format("no overload for method takes 2 arguments"));
            }
            LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
            if (lc)
            {
                if (!lc.mAssetLoader)
                {
                    lc.mAssetLoader = lc.GetComponent<LuaAssetLoader>() ?? lc.gameObject.AddComponent<LuaAssetLoader>();
                }
                if (qty == 2)
                {
                    ToLua.Push(L, lc.mAssetLoader.Load(ToLua.CheckString(L, 2)));
                }
                else
                {
                    for (int i = 2; i <= qty; i++)
                    {
                        lc.mAssetLoader.Load(ToLua.ToString(L, 2));
                    }
                    ToLua.Push(L, lc.mAssetLoader);
                }
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaLoadAsset(System.IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
            if (lc)
            {
                if (!lc.mAssetLoader)
                {
                    lc.mAssetLoader = lc.GetComponent<LuaAssetLoader>() ?? lc.gameObject.AddComponent<LuaAssetLoader>();
                }
                ToLua.Push(L, lc.mAssetLoader.LoadImmediate(ToLua.CheckString(L, 2)));
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaGetAsset(System.IntPtr L)
    {
        try
        {
            int qty = LuaDLL.lua_gettop(L);
            if (qty > 1)
            {
                LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
                if (lc && lc.mAssetLoader)
                {
                    if (qty == 2)
                    {
                        ToLua.Push(L, lc.mAssetLoader.GetAsset(ToLua.CheckString(L, 2)));
                    }
                    else
                    {
                        LuaTypes luaType = LuaDLL.lua_type(L, 3);
                        if (luaType == LuaTypes.LUA_TSTRING)
                        {
                            ToLua.Push(L, lc.mAssetLoader.GetAsset(ToLua.CheckString(L, 2), System.Type.GetType(ToLua.ToString(L, 3), true)));
                        }
                        else if (luaType == LuaTypes.LUA_TUSERDATA)
                        {
                            object obj = ToLua.ToObject(L, 3);
                            if (obj is System.Type)
                            {
                                ToLua.Push(L, lc.mAssetLoader.GetAsset(ToLua.CheckString(L, 2), obj as System.Type));
                            }
                            else if (obj is string)
                            {
                                ToLua.Push(L, lc.mAssetLoader.GetAsset(ToLua.CheckString(L, 2), System.Type.GetType(obj as string, true)));
                            }
                            else
                            {
                                LuaDLL.lua_pushnil(L);
                            }
                        }
                    }
                    return 1;
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
    private static int LuaDisposeAsset(System.IntPtr L)
    {
        try
        {
            int qty = LuaDLL.lua_gettop(L);
            if (qty > 0)
            {
                LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
                if (lc && lc.mAssetLoader)
                {
                    if (qty == 1)
                    {
                        lc.mAssetLoader.Dispose();
                    }
                    else
                    {
                        lc.mAssetLoader.Dispose(ToLua.CheckString(L, 2));
                    }
                }
            }
            return 0;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Invoke(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 3)
            {
                LuaContainer lc = ToLua.CheckObject<LuaContainer>(L, 1) as LuaContainer;
                if (lc)
                {
                    float delay = (float)LuaDLL.luaL_checknumber(L, 3);
                    LuaTypes luaType = LuaDLL.lua_type(L, 2);
                    switch (luaType)
                    {
                        case LuaTypes.LUA_TSTRING: lc.Invoke(LuaDLL.lua_tostring(L, 2), delay); return 0;
                        case LuaTypes.LUA_TUSERDATA:
                            object obj = ToLua.ToObject(L, 2);
                            if (obj is string) { lc.Invoke(ToLua.ToObject(L, 2) as string, delay); return 0; }
                            break;
                        case LuaTypes.LUA_TFUNCTION:
                            LuaFunction luaFunc = ToLua.ToLuaFunction(L, 2);
                            if (count > 3)
                            {
                                object[] args = new object[count - 3];
                                for (int i = 4; i <= count; i++) args[i - 4] = ToLua.ToVarObject(L, i);
                                lc.Invoke(luaFunc, delay, args);
                            }
                            else
                            {
                                lc.Invoke(luaFunc, delay);
                            }
                            return 0;
                        default: break;
                    }
                }
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: Scene.Invoke");
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
            LuaDLL.lua_pushboolean(L, (ToLua.ToObject(L, 1) as Object) == (ToLua.ToObject(L, 2) as Object));
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