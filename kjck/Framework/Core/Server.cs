using UnityEngine;
using System;
using System.Collections.Generic;
using Sfs2X;
using Sfs2X.Core;
using Sfs2X.Entities.Data;
using Sfs2X.Requests;
using Sfs2X.Logging;
using Sfs2X.Util;
using Kiol.Util;
using Kiol.Json;
#if TOLUA
using LuaInterface;

public delegate void SvrCallBack(SvrTask task);

public partial class Server
#else

public delegate void SvrCallBack(SvrTask task);

public class Server : MonoBehaviour
#endif
{
    /// <summary>
    /// 服务器配置
    /// </summary>
    public class Config
    {
        /// <summary>
        /// 主机
        /// </summary>
        public string host;
        /// <summary>
        /// 端口
        /// </summary>
        public int port;
        /// <summary>
        /// 区
        /// </summary>
        public string zone;
        /// <summary>
        /// 压缩阈值
        /// </summary>
        public int compress;
        /// <summary>
        /// 是否加密
        /// </summary>
        public bool encrypt;
        /// <summary>
        /// 调试信息
        /// </summary>
        public bool debug;

        /// <summary>
        /// 是否无效
        /// </summary>
        public bool invalid { get { return port < 255 || string.IsNullOrEmpty(host) || string.IsNullOrEmpty(zone); } }

        public static bool Compare(Config a, Config b)
        {
            if (a == null || b == null)
            {
                return false;
            }

            if (ReferenceEquals(a, b))
            {
                return true;
            }

            return a.host == b.host && a.port == b.port && a.zone == b.zone;
        }
    }
    /// <summary>
    /// 服务器状态
    /// </summary>
    public enum Status
    {
        /// <summary>
        /// 空闲
        /// </summary>
        Stop = 0,
        /// <summary>
        /// 准备连接
        /// </summary>
        ReadyToConnect = 1,
        /// <summary>
        /// 正在连接
        /// </summary>
        Connecting = 2,
        /// <summary>
        /// 连接失败
        /// </summary>
        ConnectFailed = 3,
        /// <summary>
        /// 正在登录(已连接)
        /// </summary>
        Login = 4,
        /// <summary>
        /// 登录成功
        /// </summary>
        Logined = 5,
        /// <summary>
        /// 登录失败
        /// </summary>
        LoginFailed = 6,
    }
    /// <summary>
    /// 丢失连接原因
    /// </summary>
    public enum DisconnectReason
    {
        /// <summary>
        /// 无
        /// </summary>
        None = 0,
        /// <summary>
        /// 被踢
        /// </summary>
        Kick = 1,
        /// <summary>
        /// 被禁
        /// </summary>
        Ban = 2,
        /// <summary>
        /// 手动
        /// </summary>
        Manual = 3,
    }

    /// <summary>
    /// 字段名称-功能
    /// </summary>
    public const string FN_FUNC = "func";
    /// <summary>
    /// 字段名称-任务ID
    /// </summary>
    public const string FN_TASK_ID = "tid";
    /// <summary>
    /// 字段名称-结果
    /// </summary>
    public const string FN_RESULT = "ret";
    /// <summary>
    /// 字段名称-数据
    /// </summary>
    public const string FN_DATA = "dat";
    /// <summary>
    /// 字段名称-打包压缩
    /// </summary>
    public const string FN_PACK = "p";

    /// <summary>
    /// 启动时间
    /// </summary>
    private readonly static long _LaunchTime = DateTime.Now.Ticks;

    /// <summary>
    /// 版本
    /// </summary>
    [SerializeField] protected int mVersion = 0;
    /// <summary>
    /// 请求超时时间
    /// </summary>
    [SerializeField] public string debugTag = "";
    /// <summary>
    /// 停止后保留时间(S)
    /// </summary>
    [SerializeField] public int stopKeepTime = 120;
    /// <summary>
    /// 使用UDP
    /// </summary>
    [SerializeField] private bool mUseUdp = false;
    /// <summary>
    /// 尝试重连的次数
    /// </summary>
    [SerializeField] private int mReconnectCount = 3;
    /// <summary>
    /// 链接的间隔时间
    /// </summary>
    [SerializeField] private int mConnectDeltaTime = 3;
    /// <summary>
    /// 请求超时时间
    /// </summary>
    [SerializeField] internal int mRequestTimeout = 10;
    /// <summary>
    /// 心跳间隔（小于等于0表示关闭心跳）
    /// </summary>
    [SerializeField] public int heartBeatInterval = 20;
    /// <summary>
    /// 紧急通信间隔
    /// </summary>
    [SerializeField] private int mEmergencyInterval = 3;
    /// <summary>
    /// 紧急通信次数
    /// </summary>
    [SerializeField] private int mEmergencyCount = 2;
    /// <summary>
    /// 心跳命令
    /// </summary>
    [SerializeField] protected string mCmdHeartBeat = "c_hb";
    /// <summary>
    /// 通用存储过程命令
    /// </summary>
    [SerializeField] public string cmdFunction = "c_func";
    /// <summary>
    /// 注册命令
    /// </summary>
    [SerializeField] private string mFuncRegister = "up_reg";
        /// <summary>
    /// 登录命令
    /// </summary>
    [SerializeField] private string mFuncLogin = "up_login";
    /// <summary>
    /// 任务进入StatusBar
    /// </summary>
    [SerializeField] public bool taskInStatusBar = false;
    /// <summary>
    /// 断网休眠时间
    /// </summary>
    [SerializeField] public int offlineSleepTime = 10;

    /// <summary>
    /// SmartFoxs实例
    /// </summary>
    [NonSerialized] private SmartFox mSmartFox;
    /// <summary>
    /// 服务器配置
    /// </summary>
    [NonSerialized] protected Config mConfig;
    /// <summary>
    /// 当前登录命令
    /// </summary>
    [NonSerialized] private string mCurLoginFunc = null;
    /// <summary>
    /// 登录数据
    /// </summary>
    [NonSerialized] private string mLoginData = null;
    /// <summary>
    /// 当前使用的登录数据
    /// </summary>
    [NonSerialized] private string mCurLoginData = null;
    /// <summary>
    /// 废弃队列
    /// </summary>
    [NonSerialized] private Queue<SmartFox> mWasteSfs = new Queue<SmartFox>(8);
    /// <summary>
    /// 任务
    /// </summary>
    [NonSerialized] private Dictionary<int, SvrTask> mTasks = new Dictionary<int, SvrTask>(32);
    /// <summary>
    /// 废弃的任务
    /// </summary>
    [NonSerialized] private List<int> mWasteTasks = new List<int>(32);

    /// <summary>
    /// 停止时间
    /// </summary>
    [NonSerialized] private float mStopTime = 0f;
    /// <summary>
    /// 下次可重连的时间
    /// </summary>
    [NonSerialized] private float mNextConnectTime = 0f;
    /// <summary>
    /// 下次可登录的时间
    /// </summary>
    [NonSerialized] private float mLoginExpTime = 0f;
    /// <summary>
    /// 连接计数
    /// </summary>
    [NonSerialized] private int mConnectCount = 0;
    /// <summary>
    /// 下次检测任务时间
    /// </summary>
    [NonSerialized] private float mNextCheckTaskTime = 0f;

    /// <summary>
    ///  当前服务器状态
    /// </summary>
    [NonSerialized] private Status mStatus = Status.Stop;
    /// <summary>
    /// 在后台
    /// </summary>
    [NonSerialized] private bool mIsBackground;
    /// <summary>
    /// 进入后台的时间
    /// </summary>
    [NonSerialized] private float mBackgroundTime;
    /// <summary>
    /// 发送时间
    /// </summary>
    [NonSerialized] internal float mSendTime;
    /// <summary>
    /// 收到时间
    /// </summary>
    [NonSerialized] private float mReceiveTime;
    /// <summary>
    /// 心跳次数
    /// </summary>
    [NonSerialized] private int mHeartBeatCount;

    /// <summary>
    /// 版本号
    /// </summary>
    public int version { get { return mVersion; } set { mVersion = value; } }
    /// <summary>
    /// 使用UDP
    /// </summary>
    public bool useUdp
    {
        get { return mUseUdp; }
        set
        {
            if (mUseUdp == value) return; mUseUdp = value;
            if (mStatus != Status.Logined) return;
            if (mUseUdp)
            {
                if (mSmartFox.UdpAvailable && !mSmartFox.UdpInited)
                {
                    mSmartFox.InitUDP(mConfig.host, mConfig.port);
                }
            }
            else if (mSmartFox.UdpInited)
            {
                mSmartFox.BitSwarm.UdpManager.Disconnect();
            }
        }
    }
    /// <summary>
    /// 自动重连尝试次数(最小1)
    /// </summary>
    public int reconnectCount { get { return mReconnectCount; } set { mReconnectCount = value > 1 ? value : 1; } }
    /// <summary>
    /// 重连尝试间隔(S)(最小1)
    /// </summary>
    public int connectDeltaTime { get { return mConnectDeltaTime; } set { mConnectDeltaTime = value > 1 ? value : 1; } }
    /// <summary>
    /// 请求超时时间(S)(最小3)
    /// </summary>
    public int requestTimeout { get { return mRequestTimeout; } set { mRequestTimeout = value > 3 ? value : 3; } }
    /// <summary>
    /// 紧急心跳通信发送间隔(S)(最小3)
    /// </summary>
    public int emergencyInterval { get { return mEmergencyInterval; } set { mEmergencyInterval = value > 3 ? value : 3; } }
    /// <summary>
    /// 紧急心跳通信次数(最小2)，当紧急次数耗尽后将尝试重连
    /// </summary>
    public int emergencyCount { get { return mEmergencyCount; } set { mEmergencyCount = value > 2 ? value : 2; } }
    /// <summary>
    /// 心跳命令(不能为空)
    /// </summary>
    public string cmdHeartBeat { get { return mCmdHeartBeat; } set { if (string.IsNullOrEmpty(value)) return ; mCmdHeartBeat = value; } }
    /// <summary>
    /// 登录命令
    /// </summary>
    public string funcLogin { get { return mFuncLogin; } set { if (mFuncLogin == value) return; if (mCurLoginFunc == mFuncLogin) mCurLoginFunc = value; mFuncLogin = value; } }
    /// <summary>
    /// 注册命令
    /// </summary>
    public string funcRegister { get { return mFuncRegister; } set { if (mFuncRegister == value) return; if (mCurLoginFunc == mFuncRegister) mCurLoginFunc = value; mFuncRegister = value; } }


    /// <summary>
    /// 服务器是否处于停止状态
    /// </summary>
    public bool isStop { get { return mStatus == Status.Stop || mStopTime > 0; } }
    /// <summary>
    /// 是否在后台
    /// </summary>
    public bool isBackground { get { return mIsBackground; } }
    /// <summary>
    /// 服务器状态
    /// </summary>
    public Status status { get { return mStatus; } }
    /// <summary>
    /// 当前登录数据
    /// </summary>
    public string loginData { get { return mCurLoginData ?? mLoginData; } }

#region API
    /// <summary>
    /// 配置服务器
    /// </summary>
    /// <param name="host">主机</param>
    /// <param name="port">端口</param>
    /// <param name="zone">区</param>
    /// <param name="encrypt">是否加密</param>
    public void Configure(string host, int port, string zone, int compress = 0, bool encrypt = false, bool debug = false)
    {
        if (mConfig != null && mConfig.host == host && mConfig.port == port && mConfig.zone == zone)
        {
            mConfig.compress = compress;
            mConfig.encrypt = encrypt;
            mConfig.debug = debug;
            return;
        }

        if (mConfig == null) mConfig = new Config();
        mConfig.host = host;
        mConfig.port = port;
        mConfig.zone = zone;
        mConfig.compress = compress;
        mConfig.encrypt = encrypt;
        mConfig.debug = debug;

        // 停止
        Close();
    }
    /// <summary>
    /// 配置服务器
    /// </summary>
    /// <param name="config">配置数据</param>
    public void Configure(Config config)
    {
        if (config == null) return;

        if (Config.Compare(config, mConfig))
        {
            mConfig.compress = config.compress;
            mConfig.encrypt = config.encrypt;
            return;
        }

        mConfig = config;

        // 停止
        Close();
    }
    /// <summary>
    /// 启动
    /// </summary>
    public void Startup()
    {
        if (mConfig == null || mConfig.invalid)
        {
            Debug.LogError(debugTag + ": you must Configure server before startup");
            return;
        }

        if (mStopTime > 0)
        {
            mStopTime = 0f;
        }

        mConnectCount = 0;

        if (mSmartFox == null)
        {
            // 状态-准备连接
            mStatus = Status.ReadyToConnect;
        }
        else if (mSmartFox.IsConnecting)
        {
            // 状态-连接中
            mStatus = Status.Connecting;
        }
        else if (mSmartFox.IsConnected)
        {
            if (mStatus != Status.Login && mStatus != Status.Logined)
            {
                // 状态-登录
                mStatus = Status.Login;
            }
        }
        else
        {
            // 状态-准备连接
            mStatus = Status.ReadyToConnect;
        }

        enabled = true;
    }
    /// <summary>
    /// 停止
    /// </summary>
    /// <param name="instant">立即</param>
    public void Stop(bool instant = false)
    {
        if (instant)
        {
            // 立即停止
            enabled = false;
            Close();
            return;
        }

        if (mStopTime > 0)
        {
            return;
        }

        if (enabled)
        {
            // 设置停止时间
            mStopTime = runTime + stopKeepTime;
        }
        else
        {
            Close();
        }
    }
    /// <summary>
    /// 注册
    /// </summary>
    /// <param name="loginData">登录数据</param>
    public void Register(string loginData)
    {
        if (string.IsNullOrEmpty(mFuncRegister))
        {
            Debug.Log(debugTag + " you must config the funcRegister!");
            return;
        }

        if (mStopTime > 0 || mStatus == Status.Stop)
        {
            Debug.Log(debugTag + " you must startup server first!");
            mCurLoginFunc = mFuncRegister;
            mLoginData = loginData;
            return;
        }

        if (mLoginData != loginData)
        {
            // 登出
            Logout();
            mCurLoginFunc = mFuncRegister;
            mLoginData = loginData;
        }

        if (mStatus == Status.ConnectFailed)
        {
            // 状态-准备连接
            mStatus = Status.ReadyToConnect;
        }
        else if (mStatus == Status.LoginFailed)
        {
            // 状态-登录
            mStatus = Status.Login;
        }
    }
    /// <summary>
    /// 登录
    /// </summary>
    /// <param name="loginData">登录数据</param>
    public void Login(string loginData)
    {
        if (string.IsNullOrEmpty(mFuncLogin))
        {
            Debug.Log(debugTag + " you must config the funcLogin!");
            return;
        }

        if (mStopTime > 0 || mStatus == Status.Stop)
        {
            Debug.Log(debugTag + " you must startup server first!");
            mCurLoginFunc = mFuncLogin;
            mLoginData = loginData;
            return;
        }

        if (mLoginData != loginData)
        {
            // 登出
            if (mCurLoginFunc != mFuncRegister) Logout();
            mCurLoginFunc = mFuncLogin;
            mLoginData = loginData;
        }

        if (mStatus == Status.ConnectFailed)
        {
            // 状态-准备连接
            mStatus = Status.ReadyToConnect;
        }
        else if (mStatus == Status.LoginFailed)
        {
            // 状态-登录
            mStatus = Status.Login;
        }
    }
    /// <summary>
    /// 登出
    /// </summary>
    public void Logout()
    {
        ClearTask();

        if ((mCurLoginData != null && mStatus == Status.Logined) || (mSmartFox != null && mSmartFox.IsConnected && !string.IsNullOrEmpty(mSmartFox.CurrentZone))) SendRequest(new LogoutRequest());

        if (mStatus == Status.Logined)
        {
            // 状态-登录
            mStatus = Status.Login;
        }

        mLoginData = mCurLoginData = null;
    }
    /// <summary>
    /// 调用存储过程
    /// </summary>
    /// <param name="func"></param>
    /// <param name="param"></param>
    public void Function(string func, params object[] param) { Function(func, null, param); }
    /// <summary>
    /// 调用存储过程
    /// </summary>
    /// <param name="func">存储过程名</param>
    /// <param name="callback">回调</param>
    /// <param name="param">参数</param>
    public SvrTask Function(string func, SvrCallBack callback, params object[] param)
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
        if (string.IsNullOrEmpty(cmdFunction))
        {
            Debug.LogWarning(debugTag + " you can not send Function with empty cmd [mCmdFunction]!");
            return null;
        }

        System.Text.StringBuilder sb = new System.Text.StringBuilder(64);
        if (param != null)
        {
            foreach (object p in param)
            {
                if (p == null)
                {
                    sb.Append("NULL");
                }
                else if (p is Char || p is String)
                {
                    sb.Append('\'');
                    sb.Append(p);
                    sb.Append('\'');
                }
                else if (p is DateTime)
                {
                    sb.Append('\'');
                    sb.Append(((DateTime)p).ToString("yyyy-MM-dd hh:mm:ss"));
                    sb.Append('\'');
                }
                else
                {
                    sb.Append(p);
                }
                sb.Append(',');
            }
        }
        sb.Append(mVersion);
        sb.Append(",@out");

        return Function(func, sb.ToString(), callback);
    }
    /// <summary>
    /// 调用存储过程
    /// </summary>
    /// <param name="func">存储过程名</param>
    /// <param name="data">参数</param>
    /// <param name="callback">回调</param>
    public SvrTask Function(string func, string data, SvrCallBack callback = null) { return Function(cmdFunction, func, data, callback); }
    /// <summary>
    /// 发送数据
    /// </summary>
    /// <param name="cmd">命令</param>
    /// <param name="func">子过程</param>
    /// <param name="data">数据</param>
    /// <param name="callback">回调</param>
    public SvrTask Function(string cmd, string func, string data, SvrCallBack callback = null)
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
        if (callback == null)
        {
            if (mStatus == Status.Logined)
            {
                SendRequest(new ExtensionRequest(cmd, CreateSFSObject(func, (string.IsNullOrEmpty(data) ? string.Empty : data + ",") + mVersion + ",@out")));
            }
            else
            {
                Debug.LogWarning(debugTag + " -> send without lisenter but not Logined");
            }
            return null;
        }

        SvrTask task = AddTask(func, callback);
        SFSObject obj = CreateSFSObject(func, (string.IsNullOrEmpty(data) ? string.Empty : data + ",") + mVersion + ",@out");
        obj.PutInt(FN_TASK_ID, task.id);
        task.mRequest = new ExtensionRequest(cmd, obj);
        return task;
    }
    /// <summary>
    /// 发送数据
    /// </summary>
    /// <param name="cmd">命令</param>
    /// <param name="data">数据</param>
    /// <param name="callback">回调</param>
    public SvrTask Send(string cmd, SFSObject data, SvrCallBack callback = null)
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

    #region SFS事件
    /// <summary>
    /// SFS事件：调试消息
    /// </summary>
    private void OnDebugMessage(BaseEvent evt) { Debug.Log(debugTag + ":[SFS DEBUG] " + evt.Params["message"].ToString()); }
    /// <summary>
    /// SFS事件：连接服务器
    /// </summary>
    private void OnConnection(BaseEvent evt)
    {
        if (mNextConnectTime - runTime > mConnectDeltaTime)
        {
            mNextConnectTime = runTime + mConnectDeltaTime;
        }

        if (true.Equals(evt.Params["success"]) && mSmartFox.IsConnected)
        {
            if (mConfig.debug)
            {
                Debug.Log(debugTag + ": connected to " + mConfig.host + ":" + mConfig.port + " success!");
            }
            else
            {
                Debug.Log(debugTag + ": connected to svr success!");
            }

            // 状态-登录
            mStatus = Status.Login;
            // 重置连接计数
            mConnectCount = 0;
        }
        else
        {
            if (mStatus == Status.Connecting)
            {
                // 状态-准备连接(自动)
                mStatus = Status.ReadyToConnect;
            }
            else
            {
                Debug.LogWarning(debugTag + ": get connected message but status[" + mStatus + "] not Connecting");
            }

            if (mConfig.debug)
            {
                Debug.Log(debugTag + ": connected to " + mConfig.host + ":" + mConfig.port + " failed! error:\n" + evt.Params["errorMessage"]);
            }
            else
            {
                Debug.Log(debugTag + ": connected to svr failed! error:\n" + evt.Params["errorMessage"]);
            }
        }
    }
    /// <summary>
    /// SFS事件：尝试重新连接
    /// </summary>
    private void OnConnectionRetry(BaseEvent evt) { Debug.Log(debugTag + ":connection retry!"); }
    /// <summary>
    /// SFS事件：断线恢复
    /// </summary>
    private void OnConnectionResume(BaseEvent evt)
    {
        // 断线恢复需要重新登录
        if (mStatus == Status.ConnectFailed || mStatus == Status.Logined || mStatus == Status.LoginFailed)
        {
            // 状态-登录
            mStatus = Status.Login;
        }

        Debug.Log(debugTag + ": connection resume!");
    }
    /// <summary>
    /// SFS事件：连接丢失
    /// </summary>
    private void OnConnectionLost(BaseEvent evt)
    {
        // 取得丢失连接的原因
        string reason = evt.Params.Contains("reason") ? evt.Params["reason"] as string : ClientDisconnectionReason.UNKNOWN;
        Debug.Log(debugTag + ": connection lost with reason : " + reason);
        // 状态校验
        if (mStatus == Status.Login || mStatus == Status.Logined || mStatus == Status.LoginFailed)
        {
            // 帐号冲突
            if (ClientDisconnectionReason.KICK == reason)
            {
                // 状态-连接失败
                mStatus = Status.ConnectFailed;
                // 重置连接计数
                mConnectCount = 0;
                // 抛出错误
                OnDisconnect(DisconnectReason.Kick);
            }
            // 禁止登录
            else if (ClientDisconnectionReason.BAN == reason)
            {

                // 状态-连接失败
                mStatus = Status.ConnectFailed;
                // 重置连接计数
                mConnectCount = 0;
                // 抛出错误
                OnDisconnect(DisconnectReason.Ban);
            }
            // 手动被踢
            else if (ClientDisconnectionReason.MANUAL == reason)
            {
                // 状态-连接失败
                mStatus = Status.ConnectFailed;
                // 重置连接计数
                mConnectCount = 0;
                // 抛出错误
                OnDisconnect(DisconnectReason.Manual);
            }
            // 未知原因
            else
            {
                // 状态-准备连接(自动)
                mStatus = Status.ReadyToConnect;
            }
        }
        else
        {
            Debug.LogWarning(debugTag + ":connect lost, but status[" + mStatus + "] not match");
        }
    }
    /// <summary>
    /// SFS事件：登录
    /// </summary>
    private void OnLogin(BaseEvent evt)
    {
        // 超时重置
        mLoginExpTime = 0f;

        if (mStatus == Status.Login)
        {
            if (mLoginData == mCurLoginData && mCurLoginData != null)
            {
                // 状态-登录成功
                mStatus = Status.Logined;
                // 重置通信统计数据
                mHeartBeatCount = 0;
                mSendTime = mReceiveTime = 0f;
                // 注册要清理数据
                if (mCurLoginFunc != mFuncLogin)
                {
                    mLoginData = mCurLoginData = null;
                }

                SFSObject obj = evt.Params["data"] as SFSObject;
                if (mConfig.debug)
                {
                    Debug.Log(debugTag + " <- login  data:" + obj.GetDump());
                }
                else
                {
                    Debug.Log(debugTag + " <- login  success");
                }

                if (mUseUdp && mSmartFox.UdpAvailable && !mSmartFox.UdpInited)
                {
                    mSmartFox.InitUDP(mConfig.host, mConfig.port);
                }

                OnLogin(obj);
            }
            else if (mConfig.debug)
            {
                Debug.LogWarning(debugTag + ":login success but current login data [" + mCurLoginData + "] not match [" + mLoginData + "]");
            }
            else
            {
                Debug.LogWarning(debugTag + ":login success but current login data not match");
            }
        }
        else
        {
            Debug.LogWarning(debugTag + ":login success but status[" + mStatus + "] not Login");
        }
    }
    /// <summary>
    /// SFS事件：登录异常
    /// </summary>
    private void OnLoginError(BaseEvent evt)
    {
        // 超时重置
        mLoginExpTime = 0f;

        string msg = evt.Params["errorMessage"].ToString();

        if (mStatus == Status.Login)
        {
            if (mLoginData == mCurLoginData && mCurLoginData != null)
            {
                // 状态-登录失败
                mStatus = Status.LoginFailed;
                // 返回结果
                OnError(ErrorCode.Login, msg);
            }
            else if (mConfig.debug)
            {
                Debug.LogWarning(debugTag + ":login error but current login data [" + mCurLoginData + "] not match [" + mLoginData + "]");
            }
            else
            {
                Debug.LogWarning(debugTag + ":login error but current login data  not match");
            }
        }
        else
        {
            Debug.LogWarning(debugTag + ":login error but status[" + mStatus + "] not Login");
        }

        Debug.Log(debugTag + ": login error code " + evt.Params["errorCode"] + ":" + msg);
    }
    /// <summary>
    /// SFS事件：登出
    /// </summary>
    private void OnLogout(BaseEvent evt) { Debug.Log(debugTag + " on logout"); }
    /// <summary>
    /// SFS事件：UDP初始化
    /// </summary>
    private void OnUdpInit(BaseEvent evt)
    {
        Debug.Log(debugTag + ": OnUdpInit");
    }
    /// <summary>
    /// SFS事件：通用扩展
    /// </summary>
    private void OnExtension(BaseEvent evt)
    {
        mReceiveTime = runTime;
        mHeartBeatCount = 0;

        string func = (string)evt.Params["cmd"];
        SFSObject obj = evt.Params["params"] as SFSObject;

        int ret = obj.GetInt(FN_RESULT);
        int taskID = obj.ContainsKey(FN_TASK_ID) ? obj.GetInt(FN_TASK_ID) : -1;
        string data = SFSObjectGetData(obj);

        if (mConfig.debug)
        {
            Debug.Log(debugTag + " <- taskID=" + taskID + "  ret:" + ret + "  func:" + func + "  data:" + data + "  sfs:" + obj.GetDump());
        }
        else
        {
            Debug.Log(debugTag + " <- taskID=" + taskID + "  ret:" + ret);
        }

        OnGameEvent(ret, func, data, obj);
        
        if (taskID > 0)
        {
            SvrTask task = null;
            if (mTasks.TryGetValue(taskID, out task) && task != null)
            {
                mTasks.Remove(task.id);
                if (task.isDone) return;
                task.Complete(ret, data, obj);
                if (ret == 0 || task.hideErr || ret == ErrorCode.Hidden) return;
                OnError(ret, data);
            }
        }
    }
#endregion

#region 内部
    /// <summary>
    /// 连接
    /// </summary>
    private void Connect()
    {
        if (mNextConnectTime > runTime) return;
        mNextConnectTime = runTime + mConnectDeltaTime;

        if (mConfig == null || mConfig.invalid)
        {
            Debug.LogWarning(debugTag + ": you must Configure server before start");
            return;
        }

        if (mConnectCount < mReconnectCount)
        {
            // 连接计数
            mConnectCount++;
        }
        else
        {
            // 重复超次
            // 状态-连接失败
            mStatus = Status.ConnectFailed;
            // 重置连接计数
            mConnectCount = 0;

            Debug.LogWarning(debugTag + ": [Connect] count[" + mReconnectCount + "] was overrun!!!");

            // 抛出错误
            OnError(ErrorCode.Connect, L.Get(L.ERR_TIMEOUT));
            return;
        }

        // 超时计时
        mNextConnectTime = runTime + mRequestTimeout;

        Close(false);

        mSmartFox = new SmartFox(false);
        mSmartFox.AddEventListener(SFSEvent.CONNECTION, OnConnection);
        mSmartFox.AddEventListener(SFSEvent.CONNECTION_RETRY, OnConnectionRetry);
        mSmartFox.AddEventListener(SFSEvent.CONNECTION_RESUME, OnConnectionResume);
        mSmartFox.AddEventListener(SFSEvent.CONNECTION_LOST, OnConnectionLost);
        //mSmartFox.AddEventListener(SFSEvent.PING_PONG, OnPingPong);
        mSmartFox.AddEventListener(SFSEvent.LOGIN, OnLogin);
        mSmartFox.AddEventListener(SFSEvent.LOGOUT, OnLogout);
        mSmartFox.AddEventListener(SFSEvent.LOGIN_ERROR, OnLoginError);
        mSmartFox.AddEventListener(SFSEvent.EXTENSION_RESPONSE, OnExtension);
        mSmartFox.AddEventListener(SFSEvent.UDP_INIT, OnUdpInit);

        if (mSmartFox.Debug) mSmartFox.AddLogListener(LogLevel.DEBUG, OnDebugMessage);
#if TEST
        //mConfig.host = "fe80::3147:73b0:2b25:1c70%12";
        //mConfig.zone = "QYHDT";
        //mConfig.port = 9802;
#endif
        mSmartFox.UseBlueBox = false;

        if (mConfig.debug)
        {
            Debug.Log(debugTag + ": try connect to " + mConfig.host + ":" + mConfig.port);
        }
        else
        {
            Debug.Log(debugTag + ": try connect to svr");
        }

        mStatus = Status.Connecting;

        mSmartFox.Connect(mConfig.host, mConfig.port);

//#if NETFX_CORE
//        new System.Threading.Tasks.Task(() => { if (mSmartFox != null) lock (mSmartFox) mSmartFox.Connect(mConfig.host, mConfig.port); }).Start();
//#else
//        ThreadManager.Run(state => { if (mSmartFox != null) lock (mSmartFox) mSmartFox.Connect(mConfig.host, mConfig.port); });
//#endif
    }
    /// <summary>
    /// 登录
    /// </summary>
    private void Login()
    {
        if (mStatus != Status.Login)
        {
            Debug.LogWarning(debugTag + " you want login, but the status[" + mStatus + "] not Status.Login");
            return;
        }

        if (string.IsNullOrEmpty(mCurLoginFunc))
        {
            Debug.LogWarning(debugTag + " you want login, but the func is empty");
            return;
        }

        if (mLoginExpTime > runTime || mLoginData == null) return;

        if (mLoginExpTime > 0)
        {
            // 超时
            mLoginExpTime = 0f;
            // 状态-登录失败
            mStatus = Status.LoginFailed;
            // 抛出错误
            OnError(ErrorCode.Login, L.Get(L.ERR_TIMEOUT));
            return;
        }

        // 超时计时
        mLoginExpTime = runTime + mRequestTimeout;
        // 记录当前使用的登录数据
        mCurLoginData = mLoginData;
        //登录请求
        if (mConfig.debug)
        {
            Debug.Log(debugTag + " -> call " + mCurLoginFunc + "(" + mLoginData + "," + mVersion + ",@out);");
        }
        SFSObject obj = CreateSFSObject(mCurLoginFunc, mLoginData + "," + mVersion + ",@out");
        SendRequest(new LoginRequest("", "", mConfig.zone, obj));
    }
    /// <summary>
    /// 发送心跳
    /// </summary>
    protected void HeartBeat()
    {
        if (mStatus != Status.Logined) return;
        // 记录次数
        mHeartBeatCount++;
        // 强制记录时间
        mSendTime = runTime;
        // 发送心跳
        Debug.Log("-> pp");
        SendRequest(new ExtensionRequest(mCmdHeartBeat, null));
    }
    /// <summary>
    /// 关闭服务
    /// <param name="clear">清除任务和登录数据</param>
    /// </summary>
    private void Close(bool clear = true)
    {
        if (clear)
        {
            // 清除登录数据
            //mCurLoginData = mLoginData = null;
            // 清除任务
            ClearTask();
        }

        // 状态-停止
        mStatus = Status.Stop;

        if (mSmartFox != null)
        {
            mSmartFox.RemoveAllEventListeners();
            if (mSmartFox.IsConnected)
            {
                mSmartFox.Disconnect();
            }
            else if (mSmartFox.IsConnecting)
            {
                mWasteSfs.Enqueue(mSmartFox);
            }
            mSmartFox = null;
        }
    }
    /// <summary>
    /// 发送请求
    /// </summary>
    internal bool SendRequest(IRequest request)
    {
        try
        {
            if (request == null)
            {
                return false;
            }
            if (mSmartFox == null)
            {
                if (mStopTime == 0 && mStatus != Status.Stop)
                {
                    // 状态-准备连接(自动)
                    mStatus = Status.ReadyToConnect;
                }
                return false;
            }
            if (mSmartFox.IsConnecting)
            {
                return false;
            }
            if (mSmartFox.IsConnected)
            {
                if (string.IsNullOrEmpty(mSmartFox.CurrentZone) && !(request is LoginRequest))
                {
                    if (mStopTime == 0 && (mStatus == Status.Logined || mStatus == Status.LoginFailed))
                    {
                        // 状态-登录
                        mStatus = Status.Login;
                    }
                    return false;
                }
                mSmartFox.Send(request);
                return true;
            }
            else
            {
                if (mStopTime == 0 && mStatus != Status.Stop)
                {
                    // 状态-准备连接(自动)
                    mStatus = Status.ReadyToConnect;
                }
                return false;
            }
        }
        catch (Exception e)
        {
            Debug.LogWarning(debugTag + ":send request error:\n" + e);
            if (mStopTime == 0 && mStatus != Status.Stop)
            {
                // 状态-准备连接(自动)
                mStatus = Status.ReadyToConnect;
            }
            return false;
        }
    }
    /// <summary>
    /// 添加一个网络任务
    /// </summary>
    /// <param name="name">任务名称</param>
    /// <param name="callback">任务回调</param>
    private SvrTask AddTask(string name, SvrCallBack callback)
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
        if(taskInStatusBar) StatusBar.Show(task);
        return task;
    }
    /// <summary>
    /// 清除所有任务
    /// </summary>
    private void ClearTask()
    {
        if (mTasks.Count < 1) return;
        foreach (SvrTask task in mTasks.Values) task.Complete(ErrorCode.Hidden, null, null);
        mTasks.Clear();
    }
    /// <summary>
    /// 移除并返回任务
    /// </summary>
    protected SvrTask RemoveTask(int id)
    {
        SvrTask ret = null;
        if (mTasks.TryGetValue(id, out ret)) mTasks.Remove(id);
        return ret;
    }
    /// <summary>
    /// 获取任务
    /// </summary>
    protected SvrTask GetTask(int id)
    {
        SvrTask ret = null;
        mTasks.TryGetValue(id, out ret);
        return ret;
    }
    #endregion

    #region 组件
    private void Start()
    {
        mVersion = ParseVer(ENV.BundleVersion);
    }
    /// <summary>
    /// 循环
    /// </summary>
    private void Update()
    {
        // 清理废弃SFS
        if (mWasteSfs.Count > 0)
        {
            SmartFox sfs = mWasteSfs.Peek();
            if (sfs == null)
            {
                mWasteSfs.Dequeue();
            }
            else if (!sfs.IsConnecting)
            {
                if (sfs.IsConnected) sfs.Disconnect();
                mWasteSfs.Dequeue();
            }
        }

        // 后台休眠
        if (mIsBackground || mStatus == Status.Stop) return;

        // 准备连接
        if (mStatus == Status.ReadyToConnect)
        {
            Connect();
            return;
        }

        // SmartFox事件
        mSmartFox.ProcessEvents();

        // 连接中
        if (mStatus == Status.Connecting)
        {
            //if (mSmartFox.IsConnected)
            //{
            //    // 状态-登录
            //    mStatus = Status.Login;
            //    // 重置连接计数
            //    mConnectCount = 0;
            //}
            //else if (mNextConnectTime <= runTime)
            //{
            //    // 状态-准备连接(自动)
            //    mStatus = Status.ReadyToConnect;
            //    return;
            //}
            if (mNextConnectTime <= runTime)
            {
                // 状态-准备连接(自动)
                mStatus = Status.ReadyToConnect;
                return;
            }
        }
        // 登录中
        else if (mStatus == Status.Login)
        {
            if (mLoginData != null)
            {
                Login();
            }
        }
        // 正常登录状态
        else if (mStatus == Status.Logined)
        {
            if (mTasks.Count > 0 && mNextCheckTaskTime < runTime)
            {
                mNextCheckTaskTime = runTime + 1;
                mWasteTasks.Clear();
                foreach (SvrTask task in mTasks.Values)
                {
                    task.Update();
                    if (task.isDone) mWasteTasks.Add(task.id);
                }
                if (mWasteTasks.Count > 0)
                {
                    for (int i = 0; i < mWasteTasks.Count; i++) mTasks.Remove(mWasteTasks[i]);
                }
            }

            if (mSendTime > mReceiveTime)
            {
                if (mHeartBeatCount > mEmergencyCount)
                {
                    // 状态-重连(自动)
                    mStatus = Status.ReadyToConnect;
                }
                else if (runTime - mSendTime > mEmergencyInterval)
                {
                    // 紧急超时检测
                    HeartBeat();
                }
            }
            else if (heartBeatInterval > 0 && runTime - mReceiveTime > heartBeatInterval)
            {
                HeartBeat();
            }
        }
        // 异常状态
        else if (mStatus == Status.ConnectFailed || mStatus == Status.LoginFailed)
        {
            if (mTasks.Count > 0) ClearTask();
        }

        // 停止
        if (mStopTime > 0 && mStopTime <= runTime)
        {
            enabled = false;
            Close();
        }
    }
    /// <summary>
    /// 销毁时
    /// </summary>
#if TOLUA
    protected override void OnDestroy() { Close(); base.OnDestroy(); }
#else
    private void OnDestroy() { Close(); }
#endif
    /// <summary>
    /// Unity事件：游戏暂停/恢复
    /// </summary>
    protected virtual void OnApplicationPause(bool pause)
    {
        mIsBackground = pause;

        if (pause)
        {
            // 记录进入后台的时间
            mBackgroundTime = runTime;
            return;
        }

        if (mStatus == Status.Stop || mStopTime > 0)
        {
            return;
        }

        float dt = runTime - mBackgroundTime;

        Debug.Log(debugTag + " sleep time : " + dt);

        if (dt > offlineSleepTime)
        {
            // 一段时间后自动断网
            mStatus = Status.ReadyToConnect;
        }
        else
        {
            // 紧急心跳
            HeartBeat();
        }
    }
#endregion

#region 重写项
#if !TOLUA
    /// <summary>
    /// 丢失连接
    /// </summary>
    /// <param name="sfsObj"></param>
    protected virtual void OnDisconnect(DisconnectReason reason) { }
    /// <summary>
    /// 登录返回
    /// </summary>
    /// <param name="sfsObj">返回数据</param>
    protected virtual void OnLogin(SFSObject sfsObj) { }
    /// <summary>
    /// 错误处理
    /// </summary>
    /// <param name="code">错误码</param>
    protected virtual void OnError(int code, string msg) { }
    /// <summary>
    /// 游戏事件
    /// </summary>
    /// <param name="ret">结果码</param>
    /// <param name="func">事件名称</param>
    /// <param name="data">字符串数据</param>
    /// <param name="sfsObj">SFSObject数据</param>
    protected virtual void OnGameEvent(int ret, string func, string data, SFSObject sfsObj) { }
#endif
#endregion

#region 辅助
    /// <summary>
    /// JSON的FUNC和DATA拼合成SFSObject
    /// </summary>
    /// <param name="func">存储过程</param>
    /// <param name="data">操作数据</param>
    protected SFSObject CreateSFSObject(string func, string data)
    {
        SFSObject obj = SFSObject.NewInstance();
        obj.PutUtfString(FN_FUNC, func);
        SFSObjectPutData(obj, "(" + (data ?? string.Empty) + ");");
        return obj;
    }
    /// <summary>
    /// 写入数据
    /// </summary>
    /// <param name="obj">SFSObject</param>
    /// <param name="data">数据</param>
    protected void SFSObjectPutData(SFSObject obj, string data)
    {
        if (string.IsNullOrEmpty(data))
        {
            obj.PutUtfString(FN_DATA, ";");
        }
        else if (mConfig == null)
        {
            obj.PutUtfString(FN_DATA, data);
        }
        else if (mConfig.compress > 0 && data.Length >= mConfig.compress)
        {
            if (mConfig.encrypt)
            {
                // 压缩并加密
                obj.PutInt(FN_PACK, PackStyle.CompressAndEncrypt);
                obj.PutByteArray(FN_DATA, new ByteArray(Encryption.Compress(data, Encryption.DEFAULT_ENCRYPT_SKIP)));
            }
            else
            {
                // 压缩
                obj.PutInt(FN_PACK, PackStyle.Compress);
                obj.PutByteArray(FN_DATA, new ByteArray(Encryption.Compress(data)));
            }
        }
        else if (mConfig.encrypt)
        {
            // 加密
            obj.PutInt(FN_PACK, PackStyle.Encrypt);
            obj.PutByteArray(FN_DATA, new ByteArray(Encryption.Encrypt(data)));
        }
    }
    /// <summary>
    /// 获取dat封装的数据
    /// </summary>
    protected static string SFSObjectGetData(SFSObject sfsObj)
    {
        object dataObj = sfsObj.ContainsKey(FN_DATA) ? sfsObj.GetClass(FN_DATA) : null;
        if (dataObj is ByteArray)
        {
            int pack = sfsObj.ContainsKey(FN_PACK) ? sfsObj.GetInt(FN_PACK) : PackStyle.None;
            if (pack == PackStyle.Compress)
            {
                // 压缩
                return Encryption.DecompressStr((dataObj as ByteArray).Bytes);
            }
            if (pack == PackStyle.Encrypt)
            {
                // 加密
                return Encryption.DecryptStr((dataObj as ByteArray).Bytes);
            }
            if (pack == PackStyle.CompressAndEncrypt)
            {
                // 压缩加密
                return Encryption.DecompressStr((dataObj as ByteArray).Bytes, Encryption.DEFAULT_ENCRYPT_SKIP);
            }
            // 默认UTF8字符串
            return System.Text.Encoding.UTF8.GetString((dataObj as ByteArray).Bytes);
        }
        else if (dataObj is string)
        {
            return dataObj as string;
        }
        else
        {
            return null;
        }
    }
    /// <summary>
    /// 从Json创建SFSObject
    /// </summary>
    public static SFSObject JsonToSFSObject(string json)
    {
        if (string.IsNullOrEmpty(json)) return null;
        SFSDataWrapper data = JsonToSFSData(new JsonObject(json));
        SFSDataType type = (SFSDataType)data.Type;
        if (SFSDataType.SFS_OBJECT == type)
        {
            return data.Data as SFSObject;
        }
        if (SFSDataType.NULL == type)
        {
            return null;
        }
        SFSObject obj = SFSObject.NewInstance();
        obj.Put(FN_DATA, data);
        return obj;
    }
    /// <summary>
    /// 将Json转换为SFSData
    /// </summary>
    private static SFSDataWrapper JsonToSFSData(JsonObject json)
    {
        if (json == null) return new SFSDataWrapper(SFSDataType.NULL, null);

        if (JsonObject.Type.Array == json.type)
        {
            if (json.childCount < 1) return new SFSDataWrapper(SFSDataType.NULL, null);

            JsonObject child = json[0];
            JsonObject.Type type = child.type;

            if (JsonObject.Type.String == type || JsonObject.Type.Value == type)
            {
                // 检测类型
                for (int i = 1; i < json.childCount; i++)
                {
                    child = json[i];
                    if (child == null || child.type == type) continue;
                    goto lbl_sfsarr;
                }

                if (JsonObject.Type.String != type)
                {
                    string val = json[0].value;

                    int intVal;
                    if (int.TryParse(val, out intVal))
                    {
                        int[] arr = new int[json.childCount];
                        arr[0] = intVal;
                        for (int i = 1; i < arr.Length; i++)
                        {
                            child = json[i];
                            if (child == null) continue;
                            if (int.TryParse(child.value, out intVal))
                            {
                                arr[i] = intVal;
                                continue;
                            }
                            goto lbl_farr;
                        }
                        return new SFSDataWrapper(SFSDataType.INT_ARRAY, arr);
                    }

                lbl_farr:
                    float floatVal;
                    if (float.TryParse(val, out floatVal))
                    {
                        float[] arr = new float[json.childCount];
                        arr[0] = floatVal;
                        for (int i = 1; i < arr.Length; i++)
                        {
                            child = json[i];
                            if (child == null) continue;
                            if (float.TryParse(child.value, out floatVal))
                            {
                                arr[i] = floatVal;
                                continue;
                            }
                            goto lbl_farr2;
                        }
                        return new SFSDataWrapper(SFSDataType.FLOAT_ARRAY, arr);
                    }

                lbl_farr2:
                    long longVal;
                    if (long.TryParse(val, out longVal))
                    {
                        long[] arr = new long[json.childCount];
                        arr[0] = longVal;
                        for (int i = 1; i < arr.Length; i++)
                        {
                            child = json[i];
                            if (child == null) continue;
                            if (long.TryParse(child.value, out longVal))
                            {
                                arr[i] = longVal;
                                continue;
                            }
                            goto lbl_farr4;
                        }
                        return new SFSDataWrapper(SFSDataType.LONG_ARRAY, arr);
                    }

                    bool boolVal;
                    if (bool.TryParse(val, out boolVal))
                    {
                        bool[] arr = new bool[json.childCount];
                        arr[0] = boolVal;
                        for (int i = 1; i < arr.Length; i++)
                        {
                            child = json[i];
                            if (child == null) continue;
                            if (bool.TryParse(child.value, out boolVal))
                            {
                                arr[i] = boolVal;
                                continue;
                            }
                            goto lbl_farr4;
                        }
                        return new SFSDataWrapper(SFSDataType.BOOL_ARRAY, arr);
                    }
                }
            lbl_farr4:
                string[] strArr = new string[json.childCount];
                for (int i = 0; i < strArr.Length; i++)
                {
                    child = json[i];
                    strArr[i] = child == null ? string.Empty : (child.value ?? string.Empty);
                }
                return new SFSDataWrapper(SFSDataType.UTF_STRING_ARRAY, strArr);
            }

        lbl_sfsarr:

            SFSArray sfsArr = new SFSArray();

            for (int i = 0; i < json.childCount; i++)
            {
                sfsArr.Add(JsonToSFSData(json[i]));
            }

            return new SFSDataWrapper(SFSDataType.SFS_ARRAY, sfsArr);
        }

        if (JsonObject.Type.Object == json.type)
        {
            if (json.childCount < 1) return new SFSDataWrapper(SFSDataType.NULL, null);
            JsonObject child;
            SFSObject obj = SFSObject.NewInstance();
            for (int i = 0; i < json.childCount; i++)
            {
                child = json[i];
                if (child == null || string.IsNullOrEmpty(child.name)) continue;
                obj.Put(child.name, JsonToSFSData(child));
            }
            return new SFSDataWrapper(SFSDataType.SFS_OBJECT, obj);
        }

        if (json.value == null) return new SFSDataWrapper(SFSDataType.NULL, null);

        if (JsonObject.Type.String != json.type)
        {
            int intVal;
            if (int.TryParse(json.value, out intVal))
            {
                return new SFSDataWrapper(SFSDataType.INT, intVal);
            }

            float floatVal;
            if (float.TryParse(json.value, out floatVal))
            {
                return new SFSDataWrapper(SFSDataType.FLOAT, floatVal);
            }

            long longVal;
            if (long.TryParse(json.value, out longVal))
            {
                return new SFSDataWrapper(SFSDataType.LONG, longVal);
            }

            bool boolVal;
            if (bool.TryParse(json.value, out boolVal))
            {
                return new SFSDataWrapper(SFSDataType.DOUBLE, boolVal);
            }
        }

        return new SFSDataWrapper(SFSDataType.UTF_STRING, json.value);
    }
    /// <summary>
    /// 从SFSObject创建Json
    /// </summary>
    public static string SFSObjectToJson(SFSObject obj)
    {
        if (obj == null) return null;
        System.Text.StringBuilder sb = new System.Text.StringBuilder(256);
        SFSDataToJson(sb, new SFSDataWrapper(SFSDataType.SFS_OBJECT, obj));
        return sb.ToString();
    }
    /// <summary>
    /// 将SFSData转换为Json
    /// </summary>
    private static void SFSDataToJson(System.Text.StringBuilder sb, SFSDataWrapper data)
    {
        if (data == null || data.Data == null)
        {
            sb.Append("null");
            return;
        }

        SFSDataType type = (SFSDataType)data.Type;

        switch (type)
        {
            case SFSDataType.NULL: sb.Append("null"); return;
            //case SFSDataType.BOOL:
            //case SFSDataType.BYTE: 
            //case SFSDataType.SHORT: 
            //case SFSDataType.INT: 
            //case SFSDataType.LONG: 
            //case SFSDataType.FLOAT: 
            //case SFSDataType.DOUBLE:
            //case SFSDataType.CLASS:
            default:
                sb.Append(data.Data); return;
            case SFSDataType.UTF_STRING:
                sb.Append('"');
                sb.Append(data.Data);
                sb.Append('"');
                return;
            case SFSDataType.BOOL_ARRAY:
            case SFSDataType.BYTE_ARRAY:
            case SFSDataType.SHORT_ARRAY:
            case SFSDataType.INT_ARRAY:
            case SFSDataType.LONG_ARRAY:
            case SFSDataType.FLOAT_ARRAY:
            case SFSDataType.DOUBLE_ARRAY:
                sb.Append('[');
                Array arr = data.Data as Array;
                if(arr != null && arr.Length > 0)
                {
                    sb.Append(arr.GetValue(0));
                    for (int i = 1; i < arr.Length; i++)
                    {
                        sb.Append(',');
                        sb.Append(arr.GetValue(i));
                    }
                }
                sb.Append(']');
                return;
            case SFSDataType.UTF_STRING_ARRAY:
                sb.Append('[');
                arr = data.Data as Array;
                if (arr != null && arr.Length > 0)
                {
                    sb.Append('"');
                    sb.Append(arr.GetValue(0));
                    sb.Append('"');
                    for (int i = 1; i < arr.Length; i++)
                    {
                        sb.Append(',');
                        sb.Append('"');
                        sb.Append(arr.GetValue(i));
                        sb.Append('"');
                    }
                }
                sb.Append(']');
                return;
            case SFSDataType.SFS_OBJECT:
                sb.Append('{');
                SFSObject obj = data.Data as SFSObject;
                if (obj != null)
                {
                    string[] keys = obj.GetKeys();
                    if (keys != null && keys.Length > 0)
                    {
                        sb.Append('"');
                        sb.Append(keys[0]);
                        sb.Append('"');
                        sb.Append(':');
                        SFSDataToJson(sb, obj.GetData(keys[0]));
                        for (int i = 1; i < keys.Length; i++)
                        {
                            sb.Append(',');
                            sb.Append('"');
                            sb.Append(keys[i]);
                            sb.Append('"');
                            sb.Append(':');
                            SFSDataToJson(sb, obj.GetData(keys[i]));
                        }
                    }
                }
                sb.Append('}');
                return;
            case SFSDataType.SFS_ARRAY:
                sb.Append('[');
                SFSArray sfsArr = data.Data as SFSArray;
                if (sfsArr != null)
                {
                    int size = sfsArr.Size();
                    if (size > 0)
                    {
                        SFSDataToJson(sb, sfsArr.GetWrappedElementAt(0));
                        for (int i = 1; i < size; i++)
                        {
                            sb.Append(',');
                            SFSDataToJson(sb, sfsArr.GetWrappedElementAt(i));
                        }
                    }
                }
                sb.Append(']');
                return;
        }
    }
    /// <summary>
    /// 解析版本号
    /// </summary>
    public static int ParseVer(string ver)
    {
        if (string.IsNullOrEmpty(ver))
        {
            return 1;
        }
        int v = 0;
        string[] arr = ver.Split('.');
        for (int i = 0; i < 3; i++)
        {
            int sub = 0;
            if (i < arr.Length)
            {
                int.TryParse(arr[i], out sub);
            }
            v = v * 100 + Mathf.Clamp(sub, 0, 99);
        }
        return v < 1 ? 1 : v;
    }
    /// <summary>
    /// 时间
    /// </summary>
    public static float runTime { get { return (DateTime.Now.Ticks - _LaunchTime) * 0.0000001f; } }
    /// <summary>
    /// 打包方式
    /// </summary>
    private struct PackStyle
    {
        /// <summary>
        /// 无(UTF8字符串)
        /// </summary>
        public const int None = 0;
        /// <summary>
        /// 压缩
        /// </summary>
        public const int Compress = 1;
        /// <summary>
        /// 加密
        /// </summary>
        public const int Encrypt = 2;
        /// <summary>
        /// 压缩并加密
        /// </summary>
        public const int CompressAndEncrypt = 3;
    }
#endregion

}

/// <summary>
/// 服务器网络任务
/// </summary>
public class SvrTask : IProgress
{
    /// <summary>
    /// ID
    /// </summary>
    private static int gId = 0;

    public static int GID  { get{ return gId; } }

    /// <summary>
    /// 任务唯一名称
    /// </summary>
    private string mName;
    /// <summary>
    /// 任务ID
    /// </summary>
    private int mId;
    /// <summary>
    /// 所属服务
    /// </summary>
    private Server mSvr;
    /// <summary>
    /// 开始时间
    /// </summary>
    private float mExpTime;
    /// <summary>
    /// 任务状态(0:初始 1:完成 2:超时)
    /// </summary>
    private int mStatus;
    /// <summary>
    /// 返回码
    /// </summary>
    private int mCode;
    /// <summary>
    /// 返回数据
    /// </summary>
    private string mData;
    /// <summary>
    /// 返回数据
    /// </summary>
    private SFSObject mSfsObj;
    /// <summary>
    /// 缓存的请求
    /// </summary>
    internal IRequest mRequest;

    public bool hideErr = false;

    /// <summary>
    /// 回调
    /// </summary>
    private SvrCallBack mCallback;
#if TOLUA
    /// <summary>
    /// Lua回调
    /// </summary>
    private LuaFunction mLuaFunc;

    internal SvrTask(Server svr, string name, LuaFunction callback)
    {
        if (svr == null)
        {
            throw new ArgumentNullException("create SvrTask need Server object");
        }
        mId = ++gId;
        mSvr = svr;
        mStatus = 0;
        mExpTime = 0f;
        mName = name;

        mCallback = null;
        mLuaFunc = callback;
    }
#endif

    internal SvrTask(Server svr, string name, SvrCallBack callbcack)
    {
        if (svr == null)
        {
            throw new ArgumentNullException("create SvrTask need Server object");
        }
        mId = ++gId;
        mSvr = svr;
        mStatus = 0;
        mExpTime = 0f;
        mName = name;
        mCallback = callbcack;
#if TOLUA
        mLuaFunc = null;
#endif
    }

    /// <summary>
    /// 任务初始化
    /// </summary>
    public void Init() { mExpTime = 0f; mStatus = 0; mCode = 0; mData = null; }

    public void Complete(int code, string data, SFSObject sfsObj)
    {
        if (mStatus == 0)
        {
            mStatus = 1;
            mCode = code;
            mData = data;
            mSfsObj = sfsObj;

            OnComplete();
        }
    }

    public void Update()
    {
        if (mStatus != 0) return;

        if (mRequest != null && mSvr.SendRequest(mRequest))
        {
            if (mRequest is ExtensionRequest)
            {
                // 记录发送时间
                mSvr.mSendTime = Server.runTime;
            }
            mRequest = null;
        }
        if (mExpTime == 0)
        {
            mExpTime = Server.runTime + mSvr.mRequestTimeout;
        }
        else if (mExpTime < Server.runTime)
        {
            mStatus = 2;

            //mData = L.Get(L.ERR_TIMEOUT);

            OnComplete();
        }
    }

    protected void OnComplete()
    {
        try
        {
            bool invalid = true;

            if (mCallback.IsAvailable())
            {
                mCallback(this);
                invalid = false;
            }
#if TOLUA
            if (mLuaFunc != null && mLuaFunc.IsAlive)
            {
                mLuaFunc.Call(this);
                invalid = false;
            }
#endif
            if(invalid) Debug.LogWarning(string.Format("任务[{0}-{1}]执行失败,任务回调不可用", mId, mName));
        }
        catch (Exception e)
        {
            Debug.LogWarning(string.Format("任务[{0}-{1}]执行失败,错误信息如下:\n", mId, mName) + e);
        }
        finally
        {
            mCallback = null;
#if TOLUA
            mLuaFunc.Dispose();
            mLuaFunc = null;
#endif
        }
    }

    /// <summary>
    /// 检查给定的回调是否匹配
    /// </summary>
    public bool CheckCallback(SvrCallBack callback) { return mCallback == callback; }
#if TOLUA
    /// <summary>
    /// 检查给定的回调是否匹配
    /// </summary>
    public bool CheckCallback(LuaFunction callback) { return mLuaFunc == callback; }
#endif

    public void SetTimeout(float dt) { mExpTime = Server.runTime + dt; }
    public int id { get { return mId; } }

    public Server server { get { return mSvr; } }

    public bool success { get { return mStatus == 1 && code == 0; } }

    public int code { get { return mCode; } }

    public object data { get { return mData; } }

    public SFSObject sfsObj { get { return mSfsObj; } }

    public float process { get { return 0f; } }

    public bool isDone { get { return mStatus != 0; } }

    public bool isTimeOut { get { return mStatus == 2; } }

    public string processMessage { get { return string.Empty; } }
}