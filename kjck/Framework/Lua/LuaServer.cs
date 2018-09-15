#if TOLUA
using System;
using Sfs2X.Entities.Data;
using Sfs2X.Requests;
using UnityEngine;
using LuaInterface;

public partial class Server : LuaContainer
{
    [SerializeField] private string mOnDisconnect = "OnDisconnect";
    [SerializeField] private string mOnLogin = "OnLogin";
    [SerializeField] private string mOnError = "OnError";
    [SerializeField] private string mOnGameEvent = "OnGameEvent";

    [NonSerialized] private LuaFunction mLuaOnDisconnect = null;
    [NonSerialized] private LuaFunction mLuaOnLogin = null;
    [NonSerialized] private LuaFunction mLuaOnError = null;
    [NonSerialized] private LuaFunction mLuaOnGameEvent = null;

    protected override void OnBindToLua()
    {
        base.OnBindToLua();
        mLuaOnDisconnect = GetBindFunction(mOnDisconnect);
        mLuaOnLogin = GetBindFunction(mOnLogin);
        mLuaOnError = GetBindFunction(mOnError);
        mLuaOnGameEvent = GetBindFunction(mOnGameEvent);
    }

    protected override void OnBindFunctionReplaced(string func)
    {
        base.OnBindFunctionReplaced(func);
        if (func == mOnGameEvent) { mLuaOnGameEvent = GetBindFunction(func); return; }
        if (func == mOnLogin) { mLuaOnLogin = GetBindFunction(func); return; }
        if (func == mOnDisconnect) { mLuaOnDisconnect = GetBindFunction(func); return; }
        if (func == mOnError) { mLuaOnError = GetBindFunction(func); return; }
    }

    #region API
    /// <summary>
    /// 调用存储过程
    /// </summary>
    /// <param name="func">存储过程名</param>
    /// <param name="data">参数</param>
    /// <param name="callback">回调</param>
    public SvrTask LuaFunction(string func, string data, LuaFunction callback) { return LuaFunction(cmdFunction, func, data, callback); }
    /// <summary>
    /// 调用存储过程
    /// </summary>
    /// <param name="cmd">命令</param>
    /// <param name="func">存储过程名</param>
    /// <param name="data">参数</param>
    /// <param name="callback">回调</param>
    public SvrTask LuaFunction(string cmd, string func, string data, LuaFunction callback)
    {
        if (mStatus == Status.Stop || mStopTime > 0)
        {
            Debug.LogWarning(debugTag + " want send Function, but not started!");
            return null;
        }
        if (mStatus == Status.ConnectFailed || mStatus == Status.LoginFailed)
        {
            Debug.LogWarning(debugTag + " want send Function, but status is [" + mStatus + "]!");
            return null;
        }
        if (string.IsNullOrEmpty(cmd))
        {
            Debug.LogWarning(debugTag + " you can not send Function with empty cmd!");
            return null;
        }

        if (mConfig.debug)
        {
            Debug.Log(debugTag + " -> call " + func + "(" + data + "," + mVersion + ",@out);");
        }

        return LuaSend(cmd, CreateSFSObject(func, (string.IsNullOrEmpty(data) ? string.Empty : data + ",") + mVersion + ",@out"), callback);
    }
    /// <summary>
    /// 发送数据
    /// </summary>
    /// <param name="cmd">命令</param>
    /// <param name="data">Json数据</param>
    /// <param name="callback">回调</param>
    public SvrTask LuaSend(string cmd, string data, LuaFunction callback)
    {
        if (mStatus == Status.Stop || mStopTime > 0)
        {
            Debug.LogWarning(debugTag + " want send request, but not started!");
            return null;
        }
        if (mStatus == Status.ConnectFailed || mStatus == Status.LoginFailed)
        {
            Debug.LogWarning(debugTag + " want send request, but status is [" + mStatus + "]!");
            return null;
        }
        if (string.IsNullOrEmpty(cmd))
        {
            Debug.LogWarning(debugTag + " you can not send request with empty cmd!");
            return null;
        }

        //if (mConfig.debug)
        //{
        //    Debug.Log(debugTag + " -> send [" + cmd + "]  data:" + data);
        //}

        return LuaSend(cmd, JsonToSFSObject(data), callback);
    }
    /// <summary>
    /// 发送数据
    /// </summary>
    /// <param name="cmd">命令</param>
    /// <param name="data">数据</param>
    /// <param name="callback">回调</param>
    public SvrTask LuaSend(string cmd, SFSObject data, LuaFunction callback)
    {
        if (mStatus == Status.Stop || mStopTime > 0)
        {
            Debug.LogWarning(debugTag + " want send request, but not started!");
            return null;
        }
        if (mStatus == Status.ConnectFailed || mStatus == Status.LoginFailed)
        {
            Debug.LogWarning(debugTag + " want send request, but status is [" + mStatus + "]!");
            return null;
        }
        if (string.IsNullOrEmpty(cmd))
        {
            Debug.LogWarning(debugTag + " you can not send request with empty cmd!");
            return null;
        }

        if (callback == null)
        {
            if (mStatus == Status.Logined)
            {
                if (mConfig.debug)
                {
                    Debug.Log(debugTag + " -> send [" + cmd + "] data:" + (data == null ? "null" : data.GetDump()));
                }
                SendRequest(new ExtensionRequest(cmd, data));
            }
            else
            {
                Debug.LogWarning(debugTag + " -> send without lisenter but not Logined");
            }
            return null;
        }

        SvrTask task = AddTask(cmd, callback);
        data = data ?? SFSObject.NewInstance();
        data.PutInt(FN_TASK_ID, task.id);
        task.mRequest = new ExtensionRequest(cmd, data);
        if (mConfig.debug)
        {
            Debug.Log(debugTag + " -> send [" + cmd + "] data:" + (data == null ? "null" : data.GetDump()));
        }
        return task;
    }
    #endregion

    #region 内部
    /// <summary>
    /// 添加一个网络任务
    /// </summary>
    /// <param name="name">任务名称</param>
    /// <param name="callback">任务回调</param>
    private SvrTask AddTask(string name, LuaFunction callback)
    {
        if (callback == null) return null;

        foreach (SvrTask t in mTasks.Values)
        {
            if (t.CheckCallback(callback))
            {
                t.Init();
                return t;
            }
        }
        SvrTask task = new SvrTask(this, name, callback);
        mTasks[task.id] = task;
        mNextCheckTaskTime = 0f;
        if (taskInStatusBar) StatusBar.Show(task);
        return task;
    }
    #endregion

    #region 重写项
    /// <summary>
    /// 丢失连接
    /// </summary>
    /// <param name="sfsObj"></param>
    protected virtual void OnDisconnect(DisconnectReason reason)
    {
        if (NoFunction(ref mLuaOnDisconnect))
        {
            Debug.LogWarning(debugTag +  " OnDisconnect missing");
            return;
        }
        mLuaOnDisconnect.BeginPCall();
        if (isInstance) mLuaOnDisconnect.Push(luaTable);
        mLuaOnDisconnect.Push((int)reason);
        mLuaOnDisconnect.PCall();
        mLuaOnDisconnect.EndPCall();
    }
    /// <summary>
    /// 登录返回
    /// </summary>
    /// <param name="sfsObj">返回数据</param>
    protected virtual void OnLogin(SFSObject sfsObj)
    {
        if (NoFunction(ref mLuaOnLogin))
        {
            Debug.LogWarning(debugTag + " OnLogin missing");
            return;
        }
        mLuaOnLogin.BeginPCall();
        if (isInstance) mLuaOnLogin.Push(luaTable);
        mLuaOnLogin.Push(sfsObj);
        mLuaOnLogin.PCall();
        mLuaOnLogin.EndPCall();
    }
    /// <summary>
    /// 错误处理
    /// </summary>
    /// <param name="code">错误码</param>
    protected virtual void OnError(int code, string msg)
    {
        if (NoFunction(ref mLuaOnError))
        {
            Debug.LogWarning(debugTag + " OnError missing");
            return;
        }
        mLuaOnError.BeginPCall();
        if (isInstance) mLuaOnError.Push(luaTable);
        mLuaOnError.Push(code);
        mLuaOnError.Push(msg);
        mLuaOnError.PCall();
        mLuaOnError.EndPCall();
    }
    /// <summary>
    /// 游戏事件
    /// </summary>
    /// <param name="ret">结果码</param>
    /// <param name="func">事件名称</param>
    /// <param name="data">字符串数据</param>
    /// <param name="sfsObj">SFSObject数据</param>
    protected virtual void OnGameEvent(int ret, string func, string data, SFSObject sfsObj)
    {
        if (NoFunction(ref mLuaOnGameEvent))
        {
            Debug.LogWarning(debugTag + " OnGameEvent missing");
            return;
        }
        mLuaOnGameEvent.BeginPCall();
        if (isInstance) mLuaOnGameEvent.Push(luaTable);
        mLuaOnGameEvent.Push(ret);
        mLuaOnGameEvent.Push(func);
        mLuaOnGameEvent.Push(data);
        mLuaOnGameEvent.Push(sfsObj);
        mLuaOnGameEvent.PCall();
        mLuaOnGameEvent.EndPCall();
    }
    #endregion

    #region Lua注册
    public new static void Register(LuaState L)
    {
        L.BeginClass(typeof(Server), typeof(LuaContainer));
        L.RegFunction("Configure", Configure);
        L.RegFunction("Startup", Startup);
        L.RegFunction("Stop", Stop);
        L.RegFunction("Register", Register);
        L.RegFunction("Login", Login);
        L.RegFunction("HeartBeat", HeartBeat);
        L.RegFunction("Logout", Logout);
        L.RegFunction("Function", Function);
        L.RegFunction("Send", Send);
        L.RegFunction("RemoveTask", RemoveTask);
        L.RegFunction("GetJsonDat", GetJsonDat);
        L.RegFunction("Json2So", Json2So);
        L.RegFunction("So2Json", So2Json);

        L.RegVar("ver", get_version, set_version);
        L.RegVar("debugTag", get_debugTag, set_debugTag);
        L.RegVar("useUdp", get_useUdp, set_useUdp);
        L.RegVar("stopKeepTime", get_stopKeepTime, set_stopKeepTime);
        L.RegVar("heartBeatInterval", get_heartBeatInterval, set_heartBeatInterval);
        L.RegVar("reconnectCount", get_reconnectCount, set_reconnectCount);
        L.RegVar("connectDeltaTime", get_connectDeltaTime, set_connectDeltaTime);
        L.RegVar("requestTimeout", get_requestTimeout, set_requestTimeout);
        L.RegVar("emergencyInterval", get_emergencyInterval, set_emergencyInterval);
        L.RegVar("emergencyCount", get_emergencyCount, set_emergencyCount);
        L.RegVar("cmdHeartBeat", get_cmdHeartBeat, set_cmdHeartBeat);
        L.RegVar("cmdFunction", get_cmdFunction, set_cmdFunction);
        L.RegVar("funcRegister", get_funcRegister, set_funcRegister);
        L.RegVar("funcLogin", get_funcLogin, set_funcLogin);
        L.RegVar("taskInStatusBar", get_taskInStatusBar, set_taskInStatusBar);
        L.RegVar("offlineSleepTime", get_offlineSleepTime, set_offlineSleepTime);
        L.RegVar("isStop", get_isStop, null);
        L.RegVar("isLogined", get_isLogined, null);
        L.RegVar("isBackground", get_isBackground, null);
        L.RegVar("status", get_status, null);
        L.RegVar("loginData", get_loginData, null);
        L.RegVar("compress", get_compress, set_compress);
        L.RegVar("encrypt", get_encrypt, set_encrypt);
        L.RegVar("debug", get_debug, set_debug);
        L.EndClass();
    }
    /// <summary>
    /// 配置
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Configure(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count > 1)
            {
                Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
                if (svr == null)
                {
                    throw new ArgumentException("Server.Configure first arg must be Server");
                }
                if (count == 2)
                {
                    svr.Configure(ToLua.CheckObject<Config>(L, 2) as Config); return 0;
                }
                if (count == 4)
                {
                    svr.Configure(ToLua.CheckString(L, 2), LuaDLL.luaL_checkinteger(L, 3), ToLua.CheckString(L, 4)); return 0;
                }
                if (count == 5)
                {
                    svr.Configure(ToLua.CheckString(L, 2), LuaDLL.luaL_checkinteger(L, 3), ToLua.CheckString(L, 4), LuaDLL.luaL_checkinteger(L, 5)); return 0;
                }
                if (count == 6)
                {
                    svr.Configure(ToLua.CheckString(L, 2), LuaDLL.luaL_checkinteger(L, 3), ToLua.CheckString(L, 4), LuaDLL.luaL_checkinteger(L, 5), LuaDLL.luaL_checkboolean(L, 6)); return 0;
                }
                if (count == 7)
                {
                    svr.Configure(ToLua.CheckString(L, 2), LuaDLL.luaL_checkinteger(L, 3), ToLua.CheckString(L, 4), LuaDLL.luaL_checkinteger(L, 5), LuaDLL.luaL_checkboolean(L, 6), LuaDLL.luaL_checkboolean(L, 7)); return 0;
                }
            }

            throw new ArgumentException("Server.Configure arg count [" + count + "] not match");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 启动
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Startup(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.Startup first arg must be Server");
            }
            svr.Startup();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 停止
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Stop(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if(count >= 1)
            {
                Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
                if (svr == null)
                {
                    throw new ArgumentException("Server.Stop first arg must be Server");
                }
                if (count == 2)
                {
                    svr.Stop(LuaDLL.luaL_checkboolean(L, 2)); return 0;
                }
                if (count == 1)
                {
                    svr.Stop(); return 0;
                }
            }
            throw new ArgumentException("Server.Stop arg count [" + count + "] not match");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 登录
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Register(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count == 2)
            {
                Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
                if (svr == null)
                {
                    throw new ArgumentException("Server.Register first arg must be Server");
                }
                svr.Register(ToLua.CheckString(L, 2)); return 0;
            }
            throw new ArgumentException("Server.Register arg count [" + count + "] not match 3");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 登录
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Login(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1)
            {
                Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
                if (svr == null)
                {
                    throw new ArgumentException("Server.Login first arg must be Server");
                }
                if (count == 2)
                {
                    svr.Login(ToLua.CheckString(L, 2)); return 0;
                }
                if (count == 1)
                {
                    svr.Login(null); return 0;
                }
            }
            throw new ArgumentException("Server.Login arg count [" + count + "] not match");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 心跳
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int HeartBeat(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.Logout first arg must Server");
            }
            svr.HeartBeat();
            return 0;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 登出
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Logout(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.Logout first arg must Server");
            }
            svr.Logout();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 发送存储过程
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Function(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count > 1)
            {
                Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
                if (svr == null)
                {
                    throw new ArgumentException("Server.Function first arg must be Server");
                }
                if (count == 2)
                {
                    svr.Function(ToLua.CheckString(L, 2), ""); return 0;
                }
                if (count == 3)
                {
                    svr.Function(ToLua.CheckString(L, 2), ToLua.CheckString(L, 3)); return 0;
                }
                if (count == 4)
                {
                    LuaTypes luaType = LuaDLL.lua_type(L, 4);
                    if (LuaTypes.LUA_TFUNCTION == luaType || LuaTypes.LUA_TNIL == luaType)
                    {
                        ToLua.Push(L, svr.LuaFunction(svr.cmdFunction, ToLua.CheckString(L, 2), ToLua.CheckString(L, 3), ToLua.CheckLuaFunction(L, 4))); return 1;
                    }
                    svr.LuaFunction(ToLua.CheckString(L, 2), ToLua.CheckString(L, 3), ToLua.CheckString(L, 4), null); return 0;
                }
                if (count == 5)
                {
                    ToLua.Push(L, svr.LuaFunction(ToLua.CheckString(L, 2), ToLua.CheckString(L, 3), ToLua.CheckString(L, 4), ToLua.CheckLuaFunction(L, 5))); return 1;
                }
            }

            throw new ArgumentException("Server.Function arg count [" + count + "] not match");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 发送
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Send(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count > 1)
            {
                Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
                if (svr == null)
                {
                    throw new ArgumentException("Server.Send first arg must be Server");
                }
                if (count == 2)
                {
                    svr.LuaSend(ToLua.CheckString(L, 2), string.Empty, null); return 0;
                }
                if (count == 3)
                {
                    LuaTypes luaType = LuaDLL.lua_type(L, 3);
                    switch (luaType)
                    {
                        case LuaTypes.LUA_TNIL:
                            SFSObject sfs = null;
                            svr.LuaSend(ToLua.CheckString(L, 2), sfs, null);
                            return 0;
                        case LuaTypes.LUA_TSTRING:
                            svr.LuaSend(ToLua.CheckString(L, 2), ToLua.ToString(L, 3), null);
                            return 0;
                        case LuaTypes.LUA_TFUNCTION:
                            ToLua.Push(L, svr.LuaSend(ToLua.CheckString(L, 2), string.Empty, ToLua.ToLuaFunction(L, 3)));
                            return 1;
                        case LuaTypes.LUA_TUSERDATA:
                            object obj = ToLua.ToObject(L, 3);
                            if (obj is SFSObject)
                            {
                                svr.LuaSend(ToLua.CheckString(L, 2), obj as SFSObject, null); return 0;
                            }
                            else if (obj is string)
                            {
                                svr.LuaSend(ToLua.CheckString(L, 2), obj as string, null); return 0;
                            }
                            break;
                    }
                }
                if (count == 4)
                {
                    SvrTask task = null;
                    if (TypeChecker.CheckType(L, typeof(string), 3))
                    {
                        task = svr.LuaSend(ToLua.CheckString(L, 2), ToLua.CheckString(L, 3), ToLua.CheckLuaFunction(L, 4));
                    }
                    else
                    {
                        task = svr.LuaSend(ToLua.CheckString(L, 2), ToLua.CheckObject<SFSObject>(L, 3) as SFSObject, ToLua.CheckLuaFunction(L, 4));
                    }
                    if (task != null)
                    {
                        ToLua.Push(L, task);
                        return 1;
                    }
                    return 0;
                }
            }

            throw new ArgumentException("Server.Send arg count [" + count + "] not match");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 移除并返回任务
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int RemoveTask(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.RemoveTask first arg must Server");
            }
            ToLua.Push(L, svr.RemoveTask(LuaDLL.luaL_checkinteger(L, 2)));
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// 获取任务
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetTask(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.GetTask first arg must Server");
            }
            ToLua.Push(L, svr.GetTask(LuaDLL.luaL_checkinteger(L, 2)));
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// SFSObject取得Json数据
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetJsonDat(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                ToLua.Push(L, Server.SFSObjectGetData(ToLua.CheckObject<SFSObject>(L, 1) as SFSObject));
                return 1;
            }

            throw new ArgumentException("Server.SO2Json(SFSObject) arg not match");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// Json转SFSObject
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Json2So(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                ToLua.Push(L, Server.JsonToSFSObject(ToLua.CheckString(L, 1)));
                return 1;
            }

            throw new ArgumentException("Server.Json2SO(string) arg not match");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    /// <summary>
    /// SFSObject转Json
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int So2Json(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                ToLua.Push(L, Server.SFSObjectToJson(ToLua.CheckObject<SFSObject>(L, 1) as SFSObject));
                return 1;
            }

            throw new ArgumentException("Server.SO2Json(SFSObject) arg not match");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_version(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_version first arg must Server");
            }
            ToLua.Push(L, svr.mVersion);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_version(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_version first arg must Server");
            }
            svr.mVersion = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_debugTag(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_debugTag first arg must Server");
            }
            ToLua.Push(L, svr.debugTag);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_debugTag(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_debugTag first arg must Server");
            }
            svr.debugTag = ToLua.CheckString(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_useUdp(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_useUdp first arg must Server");
            }
            ToLua.Push(L, svr.useUdp);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_useUdp(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_useUdp first arg must Server");
            }
            svr.useUdp = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_stopKeepTime(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_stopKeepTime first arg must Server");
            }
            ToLua.Push(L, svr.stopKeepTime);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_stopKeepTime(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_stopKeepTime first arg must Server");
            }
            svr.stopKeepTime = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_heartBeatInterval(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_heartBeatInterval first arg must Server");
            }
            ToLua.Push(L, svr.heartBeatInterval);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_heartBeatInterval(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_heartBeatInterval first arg must Server");
            }
            svr.heartBeatInterval = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_reconnectCount(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_reconnectCount first arg must Server");
            }
            ToLua.Push(L, svr.mReconnectCount);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_reconnectCount(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_reconnectCount first arg must Server");
            }
            svr.reconnectCount = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_connectDeltaTime(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_connectDeltaTime first arg must Server");
            }
            ToLua.Push(L, svr.mConnectDeltaTime);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_connectDeltaTime(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_connectDeltaTime first arg must Server");
            }
            svr.connectDeltaTime = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_requestTimeout(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_requestTimeout first arg must Server");
            }
            ToLua.Push(L, svr.mRequestTimeout);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_requestTimeout(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_requestTimeout first arg must Server");
            }
            svr.requestTimeout = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_emergencyInterval(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_emergencyInterval first arg must Server");
            }
            ToLua.Push(L, svr.mEmergencyInterval);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_emergencyInterval(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_emergencyInterval first arg must Server");
            }
            svr.emergencyInterval = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_emergencyCount(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_emergencyCount first arg must Server");
            }
            ToLua.Push(L, svr.mEmergencyCount);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_emergencyCount(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_emergencyCount first arg must Server");
            }
            svr.emergencyCount = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_cmdHeartBeat(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_cmdHeartBeat first arg must Server");
            }
            ToLua.Push(L, svr.mCmdHeartBeat);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_cmdHeartBeat(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_cmdHeartBeat first arg must Server");
            }
            svr.cmdHeartBeat = ToLua.CheckString(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_cmdFunction(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_cmdFunction first arg must Server");
            }
            ToLua.Push(L, svr.cmdFunction);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_cmdFunction(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_cmdFunction first arg must Server");
            }
            svr.cmdFunction = ToLua.CheckString(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_funcRegister(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_funcRegister first arg must Server");
            }
            ToLua.Push(L, svr.mFuncRegister);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_funcRegister(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_funcRegister first arg must Server");
            }
            svr.funcRegister = ToLua.CheckString(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_funcLogin(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_funcLogin first arg must Server");
            }
            ToLua.Push(L, svr.mFuncLogin);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_funcLogin(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_funcLogin first arg must Server");
            }
            svr.funcLogin = ToLua.CheckString(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_taskInStatusBar(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_taskInStatusBar first arg must Server");
            }
            ToLua.Push(L, svr.taskInStatusBar);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_taskInStatusBar(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_taskInStatusBar first arg must Server");
            }
            svr.taskInStatusBar = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_offlineSleepTime(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_offlineSleepTime first arg must Server");
            }
            ToLua.Push(L, svr.offlineSleepTime);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_offlineSleepTime(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_offlineSleepTime first arg must Server");
            }
            svr.offlineSleepTime = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isStop(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_isStop first arg must Server");
            }
            ToLua.Push(L, svr.isStop);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isLogined(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_isStop first arg must Server");
            }
            ToLua.Push(L, svr.mStatus == Status.Logined);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isBackground(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_isBackground first arg must Server");
            }
            ToLua.Push(L, svr.isBackground);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_status(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_status first arg must Server");
            }
            ToLua.Push(L, (int)svr.status);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_loginData(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_loginData first arg must Server");
            }
            ToLua.Push(L, svr.loginData);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_compress(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_compress first arg must Server");
            }
            ToLua.Push(L, svr.mConfig.compress);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_compress(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_compress first arg must Server");
            }
            svr.mConfig.compress = LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_encrypt(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_encrypt first arg must Server");
            }
            ToLua.Push(L, svr.mConfig.encrypt);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_encrypt(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_encrypt first arg must Server");
            }
            svr.mConfig.encrypt = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_debug(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.get_debug first arg must Server");
            }
            ToLua.Push(L, svr.mConfig.debug);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_debug(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Server svr = ToLua.CheckObject<Server>(L, 1) as Server;
            if (svr == null)
            {
                throw new ArgumentException("Server.set_debug first arg must Server");
            }
            svr.mConfig.debug = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion
}
#endif