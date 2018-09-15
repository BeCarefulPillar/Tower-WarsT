using UnityEngine;

public class SDK : MonoBehaviour
{
    /// <summary>
    /// 操作等待时间
    /// </summary>
    public const int SHORT_TIME_OUT = 3;
    /// <summary>
    /// 微信秘钥
    /// </summary>
    private const string WX_SECRET = "308baa9fa1adda97f244647d3d73ccab";

    /// <summary>
    /// 单例
    /// </summary>
    private static SDK _Instance = null;
    /// <summary>
    /// 初始化状态(0=初始 1=成功 -1=失败)
    /// </summary>
    private static int _IsInit = 0;
    /// <summary>
    /// 调用屏蔽时间
    /// </summary>
    private static float _NextCallTime = 0;
    /// <summary>
    /// 默认渠道ID
    /// </summary>
    public static int defaultChannel = -1;
#if !TOLUA
    /// <summary>
    /// 接受者
    /// </summary>
    public static ISDKReceiver receiver;
#endif

    #region API
    /// <summary>
    /// 是否开启SDK
    /// </summary>
    public static bool isEnabled
    {
        get
        {
#if UNITY_EDITOR
            return false;
#else
            return _Instance && _Instance.enabled;
#endif
        }
        set
        {
#if UNITY_EDITOR
            value = false;
#endif
            if (value)
            {
                try
                {
                    if (_Instance == null)
                    {
                        _Instance = FindObjectOfType<SDK>();
                        if (_Instance == null)
                        {
                            _Instance = new GameObject("SDK").AddComponent<SDK>();
                        }
                        DontDestroyOnLoad(_Instance.transform.root);
                    }

                    _Instance.enabled = true;
#if UNITY_ANDROID
                    if (java_class == null)
                    {
                        java_class = new AndroidJavaClass("net.joywii.cjqy.sdk");
                    }
#endif
                    return;
                }
                catch (System.Exception e)
                {
                    Debug.LogError(e);
                }
            }

            if (_Instance)
            {
                _Instance.enabled = false;
            }
#if UNITY_ANDROID
            if (java_class != null)
            {
                java_class.Dispose();
                java_class = null;
            }
#endif
        }
    }
    /// <summary>
    /// 初始化状态(0=初始 1=成功 -1=失败)
    /// </summary>
    public static int initStatus { get { return _IsInit; } }
    /// <summary>
    /// 当前渠道
    /// </summary>
    public static int channel
    {
        get
        {
            if (isEnabled)
            {
#if UNITY_ANDROID
                return java_class.CallStatic<int>("channelId");
#elif UNITY_IPHONE
                return _ChannelID();
#endif
            }
            return defaultChannel;
        }
    }
    /// <summary>
    /// 子渠道ID
    /// </summary>
    public static int subChannel
    {
        get
        {
            if (isEnabled)
            {
#if UNITY_ANDROID
                return java_class.CallStatic<int>("subChannelId");
#elif UNITY_IPHONE
                return _FromID();
#endif
            }
            return 0;
        }
    }
    /// <summary>
    /// SDK是否曾经登录过
    /// </summary>
    public static bool isNewUser
    {
        get
        {
            if (isEnabled)
            {
#if UNITY_ANDROID
                return java_class.CallStatic<bool>("isNewUser");
#elif UNITY_IPHONE
                return _IsNewUser();
#else
                return false;
#endif
            }
            else
            {
                return false;
            }
        }
    }
    /// <summary>
    /// 初始化SDK
    /// </summary>
    /// <param name="callback">初始化完成后的回调</param>
    public static void Init()
    {
        if (_IsInit == 1 || _NextCallTime > Time.realtimeSinceStartup)
        {
            return;
        }

        _IsInit = 0;

#if UNITY_ANDROID
        Debug.Log("SDK Init channel = " + channel);
        //回调方法 顺序依次是 [初始化,登录,注销,重登录,充值,退出界面,防沉迷]
        if (isEnabled && java_class.CallStatic<bool>("Init", _Instance.gameObject.name, "OnSdkInit,OnSdkLogin,OnSdkLogout,OnSdkRelogin,OnSdkPay,OnSdkExit,OnSdkAdultInfo,OnSdkPreLogin", WX_SECRET))
        {
            _NextCallTime = Time.realtimeSinceStartup + SHORT_TIME_OUT;
            return;
        }
#elif UNITY_IPHONE
        if (isEnabled && _Init(_Instance.gameObject.name))
        {
            _NextCallTime = Time.realtimeSinceStartup + SHORT_TIME_OUT;
            return;
        }
#endif
        _IsInit = 1;
    }
    /// <summary>
    /// SDK登录
    /// </summary>
    public static bool Login()
    {
        if (_NextCallTime > Time.realtimeSinceStartup)
        {
            return true;
        }
#if UNITY_ANDROID
        if (isEnabled)
        {
            java_class.CallStatic<bool>("Login");
            _NextCallTime = Time.realtimeSinceStartup + 5f;
            return true;
        }
#elif UNITY_IPHONE
        if (isEnabled && _Login())
        {
            _NextCallTime = Time.realtimeSinceStartup + 5f;
            return true;
        }
#endif
        return false;
    }
    /// <summary>
    /// 注销SDK用户
    /// </summary>
    public static bool Logout()
    {
        if (_NextCallTime > Time.realtimeSinceStartup)
        {
            return true;
        }
#if UNITY_ANDROID
        if (isEnabled && java_class.CallStatic<bool>("Logout"))
        {
            _NextCallTime = Time.realtimeSinceStartup + 5f;
            return true;
        }
#elif UNITY_IPHONE
        if (isEnabled && _Logout())
        {
            _NextCallTime = Time.realtimeSinceStartup + 5f;
            return true;
        }
#endif
        return false;
    }
    /// <summary>
    /// SDK支付
    /// </summary>
    /// <param name="price">支付金额</param>
    public static void Pay(string payUrl, string psn, string serverId, string price, string amount, string extraParam)
    {
        if (_NextCallTime > Time.realtimeSinceStartup)
        {
            return;
        }
#if UNITY_ANDROID
        if (isEnabled)
        {
            java_class.CallStatic<bool>("Pay", payUrl, psn, serverId, price, amount, extraParam);
            _NextCallTime = Time.realtimeSinceStartup + SHORT_TIME_OUT;
        }
#elif UNITY_IPHONE
        if (enabled)
        {
            _Pay(payUrl, psn, serverId, price, amount, extraParam);
            _NextCallTime = Time.realtimeSinceStartup + SHORT_TIME_OUT;
        }
#endif
    }
    /// <summary>
    /// 微信/支付宝 支付
    /// </summary>
    public static void PayTwo(string payUrl, string userID, string sevrID, string price, string itemName, string extraParam, string payType)
    {
        if (!isEnabled) return;
#if UNITY_ANDROID
        java_class.CallStatic("PayTwo", payUrl, userID, sevrID, price, itemName, extraParam, payType);
#elif UNITY_IPHONE
        _PayTow(payUrl, userID, sevrID, price, itemName, extraParam, payType);
#endif
    }
    /// <summary>
    /// 显示用户中心
    /// </summary>
    public static void ShowAccountCenter()
    {
#if UNITY_ANDROID
        if (isEnabled) java_class.CallStatic("ShowAccountCenter");
#elif UNITY_IPHONE
        if (enabled) _ShowAccountCenter();
#endif
    }
    /// <summary>
    /// 显示退出画面
    /// </summary>
    public static void ShowExitView()
    {
#if UNITY_ANDROID
        if (isEnabled && java_class.CallStatic<bool>("ShowExitView"))
        {
            return;
        }
#elif UNITY_IPHONE
        if (isEnabled && _ShowExitView())
        {
            return;
        }
#endif

#if TOLUA
        if (LuaManager.isStart)
        {
            LuaManager.CallFunction("OnGameExit");
            return;
        }
#endif

        MessageBox.ShowConfirm(L.Get(L.TIP_EXIT_GAME), input => { if (input.buttonIndex == 0) Application.Quit(); });
    }
    /// <summary>
    /// 分享给好友
    /// </summary>
    public static void Share(string text, string url, string image)
    {
        if (!isEnabled) return;
#if UNITY_ANDROID
        java_class.CallStatic("Share", text, url, image);
#elif UNITY_IPHONE
        _Share(text, url, image);
#endif
    }
    /// <summary>
    /// 分享到朋友圈
    /// </summary>
    public static void ShareToMoment(string title, string text, string url)
    {
        if (!isEnabled) return;
#if UNITY_ANDROID
        java_class.CallStatic("ShareToMoment", title, text, url);
#elif UNITY_IPHONE
        _ShareToMoment(title, text, url);
#endif
    }
    /// <summary>
    /// 邀请
    /// </summary>
    public static void Invite(string text, string content, string url)
    {
        if (!isEnabled) return;
#if UNITY_ANDROID
        java_class.CallStatic("Invite", text, content, url);
#elif UNITY_IPHONE
        _Invite(text, content, url);
#endif
    }
    /// <summary>
    /// 通知SDK审核模式
    /// </summary>
    public static void SetReview(bool review)
    {
#if UNITY_IPHONE
        if (enabled) _SetReview(review);
#endif
    }
    /// <summary>
    /// 调用
    /// </summary>
    /// <param name="func">函数名称</param>
    public static void Call(string func)
    {
        if (!isEnabled) return;
#if UNITY_ANDROID
        try
        {
            java_class.CallStatic(func);
        }
        catch
        {
            Debug.Log("Call " + func + " failed!");
        }
#elif UNITY_IPHONE
        _Call(func);
#endif
    }
    /// <summary>
    /// 调用
    /// </summary>
    /// <param name="func">函数名称</param>
    /// <param name="param">参数</param>
    public static void Call(string func, string param)
    {
        if (!isEnabled) return;
#if UNITY_ANDROID
        try
        {
            java_class.CallStatic(func, param);
        }
        catch
        {
            Debug.Log("Call " + func + " failed!");
        }
#elif UNITY_IPHONE
        _CallParam(func, param);
#endif
    }
    /// <summary>
    /// 调用并返回
    /// </summary>
    /// <param name="func">函数名称</param>
    public static string CallRet(string func)
    {
        if (!isEnabled) return string.Empty;
#if UNITY_ANDROID
        try
        {
            return java_class.CallStatic<string>(func);
        }
        catch
        {
            Debug.Log("Call " + func + " failed!");
            return string.Empty;
        }
#elif UNITY_IPHONE
        return  EnvTool.IntPtrToUTF8String(_CallRet(func));
#else
        return string.Empty;
#endif
    }
    /// <summary>
    /// 调用并返回
    /// </summary>
    /// <param name="func">函数名称</param>
    /// <param name="param">参数</param>
    public static string CallRet(string func, string param)
    {
        if (!isEnabled) return string.Empty;
#if UNITY_ANDROID
        try
        {
            return java_class.CallStatic<string>(func, param);
        }
        catch
        {
            Debug.Log("Call " + func + " failed!");
            return string.Empty;
        }
#elif UNITY_IPHONE
        return EnvTool.IntPtrToUTF8String(_CallRetParam(func, param));
#else
        return string.Empty;
#endif
    }
#endregion

#region 组件内容
    private void Awake()
    {
        if (_Instance == null)
        {
            _Instance = this;
            _Instance.enabled = false;
            DontDestroyOnLoad(_Instance.transform.root);
        }
        else if (_Instance != this)
        {
            this.DestructIfOnly();
        }
    }

    /// <summary>
    /// 初始化返回
    /// </summary>
    private void OnSdkInit(string result)
    {
        Debug.Log("OnSdkInit = " + result);
        _NextCallTime = 0f;
        _IsInit = result == "0" ? 1 : -1;
    }
    /// <summary>
    /// 预登录返回
    /// </summary>
    private void OnSdkPreLogin(string ret)
    {
        _NextCallTime = 0f;
        Debug.Log("OnSdkPreLogin = " + ret);
#if TOLUA
        LuaManager.CallFunction("SDK.OnSdkPreLogin", ret);
#else
        if (receiver == null) return;
        receiver.OnSdkPreLogin(ret);
#endif
    }
    /// <summary>
    /// 登录返回
    /// </summary>
    private void OnSdkLogin(string ret)
    {
        _NextCallTime = 0f;
        Debug.Log("OnSdkLogin = " + ret);
#if TOLUA
        LuaManager.CallFunction("SDK.OnSdkLogin", ret);
#else
        if (receiver == null) return;
        receiver.OnSdkLogin(ret);
#endif
    }
    /// <summary>
    /// 注销返回
    /// </summary>
    private void OnSdkLogout(string ret)
    {
        _NextCallTime = 0f;
        Debug.Log("logout Result = " + ret);
#if TOLUA
        LuaManager.CallFunction("SDK.OnSdkLogout", ret);
#else
        if (receiver == null) return;
        receiver.OnSdkLogout(ret);
#endif
    }
    /// <summary>
    /// 切换账号和注销账号返回
    /// </summary>
    private void OnSdkRelogin(string ret)
    {
        Debug.Log("OnSdkRelogin = " + ret);
#if TOLUA
        LuaManager.CallFunction("SDK.OnSdkRelogin", ret);
#else
        if (receiver == null) return;
        receiver.OnSdkRelogin(ret);
#endif
    }
    /// <summary>
    /// 充值返回
    /// </summary>
    private void OnSdkPay(string ret)
    {
        _NextCallTime = 0f;
        Debug.Log("OnSdkPay = " + ret);
#if TOLUA
        LuaManager.CallFunction("SDK.OnSdkPay", ret);
#else
        if (receiver == null) return;
        receiver.OnSdkPay(ret);
#endif
    }
    /// <summary>
    /// 退出页面返回
    /// </summary>
    private void OnSdkExit(string ret)
    {
        Debug.Log("OnSdkExit = " + ret);
        if (ret == "0") Application.Quit();
    }
    /// <summary>
    /// 防沉迷返回
    /// </summary>
    private void OnSdkAdultInfo(string ret)
    {
        Debug.Log("OnSdkAdultInfo = " + ret);
#if TOLUA
        LuaManager.CallFunction("SDK.OnSdkAdultInfo", ret);
#else
        if (receiver == null) return;
        receiver.OnSdkAdultInfo(ret);
#endif
    }
#endregion

#region 安卓外部接口
#if UNITY_ANDROID
    private static AndroidJavaClass java_class;
#endif
#endregion

#region 苹果外部接口
#if UNITY_IPHONE
    [DllImport("__Internal")]
    private static extern bool _Init(string receiver);
    [DllImport("__Internal")]
    private static extern bool _IsNewUser();
    [DllImport("__Internal")]
    private static extern bool _Login();
    [DllImport("__Internal")]
    private static extern bool _Logout();
    [DllImport("__Internal")]
    private static extern bool _ReLogin();
    [DllImport("__Internal")]
    private static extern void _ShowAccountCenter();
    [DllImport("__Internal")]
    private static extern bool _ShowExitView();
    [DllImport("__Internal")]
    private static extern int _ChannelID();
    [DllImport("__Internal")]
    private static extern int _SunChannelID();
    [DllImport("__Internal")]
    private static extern void _Pay(string payUrl, string psn, string serverId, string price, string amount, string extraParam);
    [DllImport("__Internal")]
    private static extern void _PayTow(string payUrl, string psn, string serverId, string price, string amount, string extraParam, string type);
    [DllImport("__Internal")]
    private static extern void _Share(string text, string url, string image);
    [DllImport("__Internal")]
    private static extern void _ShareToMoment(string title, string text, string url);
    [DllImport("__Internal")]
    private static extern void _Invite(string text, string content, string url);
    [DllImport("__Internal")]
    private static extern void _SetReview(bool review);
    [DllImport("__Internal")]
    private static extern void _Call(string func);
    [DllImport("__Internal")]
    private static extern void _CallParam(string func, string param);
    [DllImport("__Internal")]
    private static extern IntPtr _CallRet(string func);
    [DllImport("__Internal")]
    private static extern IntPtr _CallRetParam(string func, string param);
#endif
#endregion
}
