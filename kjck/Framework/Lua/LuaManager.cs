#if TOLUA
using UnityEngine;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;

public class LuaManager : MonoBehaviour, IDisposable
{
    /// <summary>
    /// Lua文件最大1MB
    /// </summary>
    private const int DATA_SIZE_LIMT = 1048576;

    private const string LUA_CREATE_TABLE = "CreateTable";
    private const string LUA_DO_STRING = "DoString";

    private const string LUA_GAME = "Game";
    private const string LUA_GAME_START = LUA_GAME + ".Start";
    private const string LUA_GAME_QUIT = LUA_GAME + ".OnQuit";
    private const string LUA_ON_GAME_PAUSE = LUA_GAME + ".OnPause";
    private const string LUA_ON_SCENE_LOADED = LUA_GAME + ".OnSceneLoaded";
    private const string LUA_ON_HANDLE_ERROR = LUA_GAME + ".HandleError";

    private static LuaManager _Instance = null;

    [NonSerialized] private LuaState mLuaState;
    
    [NonSerialized] private HashSet<string> mTextAsset = new HashSet<string>();

    [NonSerialized] private LuaFunction mCreateTable;
    [NonSerialized] private LuaFunction mDoString;
    [NonSerialized] private LuaFunction mOnGamePause;
    [NonSerialized] private LuaFunction mOnSceneLoaded;
    [NonSerialized] private LuaFunction mOnHandleError;

    #region 启动及组件
    //private void Awake()
    //{
    //    //单例
    //    _Instance = this;
    //    //创建lua
    //    mLuaState = new LuaState();
    //    //加载lua依赖库
    //    OnLoadLibs(mLuaState);
    //    //重设lua堆栈顶部索引
    //    mLuaState.LuaSetTop(0);
    //    //绑定C#接口
    //    OnBind(mLuaState);
    //    //lua开始运行
    //    mLuaState.Start();
    //    //加载主入口
    //    mLuaState.DoFile(LUA_GAME);
    //}
    private void OnStart()
    {
        //创建lua
        LuaState luaState = new LuaState();
        try
        {
            //加载lua依赖库
            OnLoadLibs(luaState);
            //重设lua堆栈顶部索引
            luaState.LuaSetTop(0);
            //绑定C#接口
            OnBind(luaState);
            //lua开始运行
            luaState.Start();
            //开始
            OnStart(luaState);
            // 赋值
            mLuaState = luaState;
        }
        catch (Exception e)
        {
            Debug.LogError(e);
            luaState.Dispose();
        }
    }
    private IEnumerator Start()
    {
        // 先禁用
        enabled = false;
        //单例
        _Instance = this;

        StatusBar.TempProcess stp = StatusBar.Show(StatusBar.TempProcess.ID_LOAD_LUA, StatusBar.DEFAULT_TIMEOUT_LONG, false);

        // 线程加载
#if TEST
        float time = Time.realtimeSinceStartup;
#endif
        ThreadManager.Task task = ThreadManager.Call(OnStart);
        while (!task.isDone) yield return null;
#if TEST
        Debug.Log(Time.realtimeSinceStartup - time);
#endif
        stp.Done();
        if (mLuaState == null)
        {
            // 异常
            MessageBox.Show(L.Get(L.ERR_GENERIC), L.Retry + "," + L.Exit, input => { if (input.buttonIndex == 0) Game.instance.StartCoroutine(Start()); else Application.Quit(); });
            yield break;
        }

        //获取常驻函数
        mCreateTable = mLuaState.GetFunction(LUA_CREATE_TABLE);
        mDoString = mLuaState.GetFunction(LUA_DO_STRING);
        mOnGamePause = mLuaState.GetFunction(LUA_ON_GAME_PAUSE);
        mOnSceneLoaded = mLuaState.GetFunction(LUA_ON_SCENE_LOADED);
        mOnHandleError = mLuaState.GetFunction(LUA_ON_HANDLE_ERROR);

        UnityEngine.SceneManagement.SceneManager.sceneLoaded += OnLevelLoaded;

#if TEST
        LuaFunction func = mLuaState.GetFunction(LUA_GAME_START);
        if (func != null)
        {
            func.BeginPCall();
            func.Push(true);
            func.PCall();
            func.EndPCall();
            func.Dispose();
        }
#else
        _CallFunction(LUA_GAME_START);
#endif

        enabled = true;
    }

    private void Update()
    {
#if UNITY_EDITOR
        if (mLuaState == null)
        {
            return;
        }
#endif
        if (mLuaState.LuaUpdate(Time.deltaTime, Time.unscaledDeltaTime) != 0)
        {
            ThrowException();
        }

        mLuaState.LuaPop(1);
        mLuaState.Collect();
#if UNITY_EDITOR
        mLuaState.CheckTop();

        if (Input.GetKey(KeyCode.G))
        {
            GC();
        }
#endif
    }

    private void LateUpdate()
    {
#if UNITY_EDITOR
        if (mLuaState == null)
        {
            return;
        }
#endif
        if (mLuaState.LuaLateUpdate() != 0)
        {
            ThrowException();
        }

        mLuaState.LuaPop(1);
    }

    private void FixedUpdate()
    {
#if UNITY_EDITOR
        if (mLuaState == null)
        {
            return;
        }
#endif
        if (mLuaState.LuaFixedUpdate(Time.fixedDeltaTime) != 0)
        {
            ThrowException();
        }

        mLuaState.LuaPop(1);
    }

    private void OnLevelLoaded(UnityEngine.SceneManagement.Scene scene, UnityEngine.SceneManagement.LoadSceneMode mode)
    {
        if (CheckFunction(LUA_ON_SCENE_LOADED, ref mOnSceneLoaded))
        {
            mOnSceneLoaded.BeginPCall();
            mOnSceneLoaded.Push(scene.name);
            mOnSceneLoaded.PCall();
            mOnSceneLoaded.EndPCall();
        }
    }

    private void OnApplicationPause(bool pause)
    {
        if (CheckFunction(LUA_ON_GAME_PAUSE, ref mOnGamePause))
        {
            mOnGamePause.BeginPCall();
            mOnGamePause.Push(pause);
            mOnGamePause.PCall();
            mOnGamePause.EndPCall();
        }
    }

    private void OnDestroy()
    {
        UnityEngine.SceneManagement.SceneManager.sceneLoaded -= OnLevelLoaded;
        Dispose();
    }

    private void OnApplicationQuit() { Dispose(); }

    public void Dispose()
    {
        if (mLuaState != null)
        {
            if (mCreateTable != null) { mCreateTable.Dispose(); mCreateTable = null; }
            if (mOnGamePause != null) { mOnGamePause.Dispose(); mOnGamePause = null; }
            if (mOnSceneLoaded != null) { mOnSceneLoaded.Dispose(); mOnSceneLoaded = null; }
            if (mOnHandleError != null) { mOnHandleError.Dispose(); mOnHandleError = null; }
            _CallFunction(LUA_GAME_QUIT);
            mLuaState.Dispose();
            mLuaState = null;
        }
        if (_Instance == this)
        {
            this.DestructIfOnly();
        }
    }
    #endregion

    #region 内部模块加载

    protected virtual void OnLoadLibs(LuaState luaState)
    {
        luaState.OpenLibs(LuaDLL.luaopen_pb);
        luaState.OpenLibs(LuaDLL.luaopen_struct);
        luaState.OpenLibs(LuaDLL.luaopen_lpeg);
#if UNITY_STANDALONE_OSX || UNITY_EDITOR_OSX
        L.OpenLibs(LuaDLL.luaopen_bit);
#endif
        //////cjson
        luaState.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
        luaState.OpenLibs(LuaDLL.luaopen_cjson);
        luaState.LuaSetField(-2, "cjson");
        luaState.OpenLibs(LuaDLL.luaopen_cjson_safe);
        luaState.LuaSetField(-2, "cjson.safe");
        //////////
#if TEST
        if (LuaConst.openLuaSocket) OpenLuaSocket(luaState);
        if (LuaConst.openLuaDebugger) OpenZbsDebugger(luaState);
#endif
    }
    protected virtual void OnBind(LuaState luaState)
    {
        DelegateFactory.Register();
        LuaBindCustom.Bind(luaState);
        LuaBinder.Bind(luaState);
        LuaCoroutine.Register(luaState, this);
    }
    protected virtual void OnStart(LuaState luaState)
    {
        //值类型注册
        LuaValueTypeExtend.Register(luaState);
        //加载主入口
        luaState.DoFile(LUA_GAME);
    }
    private void _CallFunction(string fname)
    {
        if (mLuaState == null) return;
        LuaFunction func = mLuaState.GetFunction(fname);
        if (func != null)
        {
            func.Call();
            func.Dispose();
        }
    }
    /// <summary>
    /// 用全路径获取方法，并给予缓存，缓存可用时直接返回
    /// </summary>
    /// <param name="fullName">方法全路径</param>
    /// <param name="luafunc">缓存的方法</param>
    private bool CheckFunction(string fullName, ref LuaFunction luafunc)
    {
        if (luafunc != null && luafunc.IsAlive) return true;
        luafunc = mLuaState == null ? null : mLuaState.GetFunction(fullName);
        return luafunc != null;
    }
    private void ThrowException()
    {
        string error = mLuaState.LuaToString(-1);
        mLuaState.LuaPop(2);
        throw new LuaException(error, LuaException.GetLastError());
    }
    #endregion

    #region 调试相关
#if TEST
    protected void OpenLuaSocket(LuaState luaState)
    {
        LuaConst.openLuaSocket = true;
        luaState.BeginPreLoad();
        luaState.RegFunction("socket.core", LuaOpen_Socket_Core);
        luaState.RegFunction("mime.core", LuaOpen_Mime_Core);
        luaState.EndPreLoad();
    }
    public void OpenZbsDebugger(LuaState luaState, string ip = "localhost")
    {
        if (!Directory.Exists(LuaConst.zbsDir))
        {
            Debugger.LogWarning("ZeroBraneStudio not install or LuaConst.zbsDir not right");
            return;
        }

        if (!LuaConst.openLuaSocket)
        {
            OpenLuaSocket(luaState);
        }

        if (!string.IsNullOrEmpty(LuaConst.zbsDir))
        {
            luaState.AddSearchPath(LuaConst.zbsDir);
        }

        luaState.LuaDoString(string.Format("DebugServerIp = '{0}'", ip));
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaOpen_Socket_Core(IntPtr L) { return LuaDLL.luaopen_socket_core(L); }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaOpen_Mime_Core(IntPtr L) { return LuaDLL.luaopen_mime_core(L); }
#endif
    #endregion

    #region Lua相关静态接口
    /// <summary>
    /// LuaState
    /// </summary>
    public static LuaState luaState { get { return _Instance ? _Instance.mLuaState : null; } }
    /// <summary>
    /// GC
    /// </summary>
    public static void GC()
    {
        if (_Instance == null || _Instance.mLuaState == null) return;
        _Instance.mLuaState.Collect();
        _Instance.mLuaState.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
    }
    /// <summary>
    /// 根据名称获取表(确保name的全局唯一性)
    /// </summary>
    public static LuaTable GetLuaTable(string name)
    {
        if (_Instance == null || _Instance.mLuaState == null || string.IsNullOrEmpty(name)) return null;
        LuaTable table = _Instance.mLuaState.GetTable(name, false);
        if (table == null)
        {
            _Instance.mLuaState.Require(name);
            int idx = name.LastIndexOf("/");
            table = _Instance.mLuaState.GetTable(idx < 0 ? name : name.Substring(idx + 1));
        }
        return table;
    }
    /// <summary>
    /// 根据TextAsset获取表(确保TextAsset.name的全局唯一性)
    /// </summary>
    public static LuaTable GetLuaTable(TextAsset ta)
    {
        if (ta == null || _Instance == null || _Instance.mLuaState == null || ta.bytes.Length >= DATA_SIZE_LIMT) return null;
        LuaTable table = _Instance.mLuaState.GetTable(ta.name);
        if (table == null && !_Instance.mTextAsset.Contains(ta.name))
        {
            //_Instance.mLuaState.DoString(ta.name, ta.text);
            _Instance.mLuaState.DoString(ta.name, Kiol.Util.Encryption.DecompressStr(ta.bytes, Kiol.Util.Encryption.DEFAULT_ENCRYPT_SKIP));
            _Instance.mTextAsset.Add(ta.name);
            table = _Instance.mLuaState.GetTable(ta.name);
        }
        return table;
    }
    /// <summary>
    /// 根据名称创建一个表实例(确保name的全局唯一性)
    /// </summary>
    public static LuaTable CreatLuaTable(string name) { return CreatTable(GetLuaTable(name)); }
    /// <summary>
    /// 根据TextAsset创建一个表实例(确保TextAsset.name的全局唯一性)
    /// </summary>
    public static LuaTable CreatLuaTable(TextAsset ta) { return CreatTable(GetLuaTable(ta)); }
    /// <summary>
    /// 创建表实例
    /// </summary>
    /// <param name="setmetatable">元表</param>
    private static LuaTable CreatTable(LuaTable setmetatable)
    {
        if (setmetatable == null || _Instance == null || _Instance.mLuaState == null) return null;
        if (!setmetatable.IsAlive)
        {
            if (string.IsNullOrEmpty(setmetatable.name)) return null;
            setmetatable = _Instance.mLuaState.GetTable(setmetatable.name);
            if (setmetatable == null) return null;
        }
        //if (setmetatable.refCount > 1) setmetatable.Dispose();
        if (_Instance.CheckFunction(LUA_CREATE_TABLE, ref _Instance.mCreateTable))
        {
            _Instance.mCreateTable.BeginPCall();
            _Instance.mCreateTable.Push(setmetatable);
            _Instance.mCreateTable.PCall();
            setmetatable = _Instance.mCreateTable.CheckLuaTable();
            _Instance.mCreateTable.EndPCall();
            return setmetatable;
        }
        return null;
    }
    /// <summary>
    /// 执行语句
    /// </summary>
    /// <param name="chunk"></param>
    /// <param name="name"></param>
    public static void DoString(string chunk, string name)
    {
        if (_Instance && _Instance.CheckFunction(LUA_DO_STRING, ref _Instance.mDoString))
        {
            _Instance.mDoString.Call(chunk, name);
        }
    }
    /// <summary>
    /// 用全路径获取方法，并给予缓存，缓存可用时直接返回
    /// </summary>
    /// <param name="fullName">方法全路径</param>
    /// <param name="luafunc">缓存的方法</param>
    public static bool GetFunction(string fullName, ref LuaFunction luafunc)
    {
        if (luafunc != null && luafunc.IsAlive) return true;
        luafunc = _Instance == null || _Instance.mLuaState == null ? null : _Instance.mLuaState.GetFunction(fullName);
        return luafunc != null;
    }
    /// <summary>
    /// 调用方法
    /// </summary>
    /// <param name="fullName">方法全路径</param>
    public static bool CallFunction(string fullName)
    {
        if (_Instance == null || _Instance.mLuaState == null) return false;
        LuaFunction func = _Instance.mLuaState.GetFunction(fullName);
        if (func == null) return false;
        func.Call();
        func.Dispose();
        return true;
    }
    /// <summary>
    /// 调用方法
    /// </summary>
    /// <param name="fullName">方法全路径</param>
    public static bool CallFunction(string fullName, string param)
    {
        if (_Instance == null || _Instance.mLuaState == null) return false;
        LuaFunction luaFunc = _Instance.mLuaState.GetFunction(fullName);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        luaFunc.Push(param);
        luaFunc.PCall();
        luaFunc.EndPCall();
        luaFunc.Dispose();
        return true;
    }
    /// <summary>
    /// 调用方法
    /// </summary>
    /// <param name="fullName">方法全路径</param>
    public static bool CallFunction(string fullName, int param)
    {
        if (_Instance == null || _Instance.mLuaState == null) return false;
        LuaFunction luaFunc = _Instance.mLuaState.GetFunction(fullName);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        luaFunc.Push(param);
        luaFunc.PCall();
        luaFunc.EndPCall();
        luaFunc.Dispose();
        return true;
    }
    /// <summary>
    /// 安全释放LuaFunction
    /// </summary>
    public static void SafeDisposeFunction(LuaFunction luafunc)
    {
        if (luafunc == null || _Instance == null) return;
        if (luafunc.IsBegin())
        {
            _Instance.StartCoroutine(OnSafeDisposeFunction(luafunc));
        }
        else
        {
            luafunc.Dispose();
        }
    }
    /// <summary>
    /// 安全释放LuaFunction
    /// </summary>
    public static void SafeDisposeFunction(LuaFunction luafunc, int generation)
    {
        if (luafunc == null || _Instance == null) return;
        if (luafunc.IsBegin())
        {
            _Instance.StartCoroutine(OnSafeDisposeFunction(luafunc, generation));
        }
        else
        {
            luafunc.Dispose();
            luafunc.Dispose(generation);
        }
    }
    private static IEnumerator OnSafeDisposeFunction(LuaFunction luafunc)
    {
        yield return null;
        luafunc.Dispose();
    }
    private static IEnumerator OnSafeDisposeFunction(LuaFunction luafunc, int generation)
    {
        yield return null;
        luafunc.Dispose();
        luafunc.Dispose(generation);
    }
    /// <summary>
    /// 延时调用
    /// </summary>
    public static void Invoke(LuaFunction luaFunc, float delay)
    {
        if (luaFunc == null) return;
        if (delay > 0f && _Instance)
        {
            _Instance.StartCoroutine(OnInvoke(luaFunc, delay));
        }
        else
        {
            luaFunc.Call(); luaFunc.Dispose(); luaFunc = null;
        }
    }
    private static IEnumerator OnInvoke(LuaFunction luaFunc, float delay)
    {
        yield return new WaitForSeconds(delay);
        if (luaFunc.IsAlive)
        {
            luaFunc.Call(); luaFunc.Dispose(); luaFunc = null;
        }
    }
    /// <summary>
    /// 延时调用
    /// </summary>
    public static void Invoke(LuaFunction luaFunc, float delay, params object[] arg)
    {
        if (luaFunc == null) return;
        if (delay > 0f && _Instance)
        {
            _Instance.StartCoroutine(OnInvoke(luaFunc, delay, arg));
        }
        else
        {

            luaFunc.BeginPCall(); luaFunc.PushArgs(arg); luaFunc.PCall(); luaFunc.EndPCall(); luaFunc.Dispose(); luaFunc = null;
        }
    }
    private static IEnumerator OnInvoke(LuaFunction luaFunc, float delay, params object[] arg)
    {
        yield return new WaitForSeconds(delay);
        if (luaFunc.IsAlive)
        {
            luaFunc.BeginPCall(); luaFunc.PushArgs(arg); luaFunc.PCall(); luaFunc.EndPCall(); luaFunc.Dispose(); luaFunc = null;
        }
    }
    #endregion

    #region 一般功能接口
    /// <summary>
    /// 是否已启动
    /// </summary>
    public static bool isStart { get { return _Instance && _Instance.mLuaState != null; } }
    /// <summary>
    /// 错误消息抛出
    /// </summary>
    /// <param name="content">错误内容</param>
    /// <param name="code">错误代码</param>
    public static void HandleError(string content, int code = 0)
    {
        if (_Instance && _Instance.CheckFunction(LUA_ON_HANDLE_ERROR, ref _Instance.mOnHandleError))
        {
            _Instance.mOnHandleError.BeginPCall();
            _Instance.mOnHandleError.Push(content);
            _Instance.mOnHandleError.Push(code);
            _Instance.mOnHandleError.PCall();
            _Instance.mOnHandleError.EndPCall();
        }
        else
        {
            StatusBar.Exit();
            if (code == 256) return;
            MessageBox.Show(content);
        }
    }
    #endregion
}
#endif