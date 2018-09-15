using System.Collections.Generic;
using UnityEngine;

public static class L
{
    /// <summary>
    /// 语言字段
    /// </summary>
    public const string FN_LANGUAGE = "language";
    /// <summary>
    /// 默认语言
    /// </summary>
    public const int DEFAULT_LANGUAGE = 0;

    #region 基本词汇
    /***************词汇***************/
    /// <summary>
    /// 确定
    /// </summary>
    public static string Sure { get { return L.Get("sure"); } }
    /// <summary>
    /// 取消
    /// </summary>
    public static string Cancel { get { return L.Get("cancel"); } }
    /// <summary>
    /// 退出
    /// </summary>
    public static string Exit { get { return L.Get("exit"); } }
    /// <summary>
    /// 重试
    /// </summary>
    public static string Retry { get { return L.Get("retry"); } }
    /// <summary>
    /// 更新
    /// </summary>
    public static string Update { get { return L.Get("update"); } }
    /// <summary>
    /// 查看
    /// </summary>
    public static string View { get { return L.Get("view"); } }
    /// <summary>
    /// 自动更新
    /// </summary>
    public static string AutoUpdate { get { return L.Get("autoUpdate"); } }
    /// <summary>
    /// 手动更新
    /// </summary>
    public static string ManualUpdate { get { return L.Get("manualUpdate"); } }
    /// <summary>
    /// 继续
    /// </summary>
    public static string Continue { get { return L.Get("continue"); } }
    /// <summary>
    /// 安装
    /// </summary>
    public static string Install { get { return L.Get("install"); } }
    /// <summary>
    /// 重新下载
    /// </summary>
    public static string ReDownload { get { return L.Get("redownload"); } }
    /// <summary>
    /// 手动下载
    /// </summary>
    public static string ManualDownload { get { return L.Get("manualDownload"); } }
    /// <summary>
    /// 未知
    /// </summary>
    public static string Unknown { get { return L.Get("unknown"); } }
    /// <summary>
    /// 加载中
    /// </summary>
    public static string Loading { get { return L.Get("loading"); } }
    #endregion

    #region 前缀
    /***************前缀***************/
    /// <summary>
    /// 请输入
    /// </summary>
    public static string P_Input { get { return L.Get("pleaseInput"); } }
    #endregion

    #region 错误提示
    /***************错误提示***************/
    /// <summary>
    /// err_1001:非常抱歉,您的手机分辨率过低，游戏暂不支持
    /// </summary>
    public const string ERR_RESOLUTION_NOT_SUPPORTED = "err_1001";
    /// <summary>
    /// err_1002:游戏初始化失败！请检查您的网络环境
    /// </summary>
    public const string ERR_SDK_INIT = "err_1002";
    /// <summary>
    /// err_1003:服务器数据解析错误，请联系客服
    /// </summary>
    public const string ERR_SERVER_DATA = "err_1003";
    /// <summary>
    /// err_1004:无法连接服务器，建议您尝试开启WIFI或者移动网络
    /// </summary>
    public const string ERR_CONNECT_FAILED = "err_1004";
    /// <summary>
    /// err_1005:未找到更新地址，请联系客服
    /// </summary>
    public const string ERR_UPDATE_URL_NOT_FOUND = "err_1005";
    /// <summary>
    /// err_1006:资源加载发生错误，若此错误发生多次，请检查您的网络环境
    /// </summary>
    public const string ERR_DOWNLOAD_DATA = "err_1006";
    /// <summary>
    /// err_1007:写入资源发生错误！请检查您手机的存储空间是否充足，或是否允许写入
    /// </summary>
    public const string ERR_WRITE_DATA = "err_1007";
    /// <summary>
    /// err_1008:检查客户端版本发生错误，是否重新检查？若此错误发生多次，请检查您的网络环境
    /// </summary>
    public const string ERR_CHECK_CLIENT = "err_1008";
    /// <summary>
    /// err_1009:无法连接服务器，是否重新连接？若此错误发生多次，请检查您的网络环境
    /// </summary>
    public const string ERR_CONNECT_SERVER = "err_1009";
    /// <summary>
    /// err_1010:与服务器连接丢失，是否重新连接
    /// </summary>
    public const string ERR_CONNECT_LOST = "err_1010";
    /// <summary>
    /// err_1011:连接超时，请重新连接
    /// </summary>
    public const string ERR_CONNECT_TIME_OUT = "err_1011";
    /// <summary>
    /// err_1012:您的账号已在别处登录！
    /// </summary>
    public const string ERR_CONNECT_KICK = "err_1012";
    /// <summary>
    /// err_1013:您已被禁止登录！
    /// </summary>
    public const string ERR_CONNECT_BAN = "err_1013";
    /// <summary>
    /// err_1014:语音连接失败
    /// </summary>
    public const string ERR_VOICE = "err_1014";
    /// <summary>
    /// err_1015:下载意外中断！
    /// </summary>
    public const string ERR_DOWNLOAD = "err_1015";
    /// <summary>
    /// err_1016:检测到下载中断多次
    /// </summary>
    public const string ERR_DOWNLOAD_REPEAT = "err_1016";
    /// <summary>
    /// err_1017:Disk写入失败，请手动下载更新
    /// </summary>
    public const string ERR_DOWNLOAD_WRITE = "err_1017";
    /// <summary>
    /// err_1018:初始化配置失败
    /// </summary>
    public const string ERR_INIT_CONFIG = "err_1018";
    /// <summary>
    /// err_1019:资源地址加载异常
    /// </summary>
    public const string ERR_CDN_URL_NOT_FOUND = "err_1019";
    /// <summary>
    /// err_1020:操作超时
    /// </summary>
    public const string ERR_TIMEOUT = "err_1020";
    /// <summary>
    /// err_1020:数据异常，请稍后重试
    /// </summary>
    public const string ERR_GENERIC = "err_1021";
    #endregion

    #region 系统提示
    /***************系统提示***************/
    /// <summary>
    /// tip_1001:客户端有新版本。是否更新
    /// </summary>
    public const string TIP_UPDATE_CLIENT = "tip_1001";
    /// <summary>
    /// tip_1002:客户端有新版本。必须更新才能继续游戏
    /// </summary>
    public const string TIP_UPDATE_CLIENT_FORCE = "tip_1002";
    /// <summary>
    /// tip_1003:主公，发现新版本可更新，若不更新仍可继续游戏，但新功能将无法使用，为保证游戏体验请尽快更新
    /// </summary>
    public const string TIP_UPDATE_CLIENT_SKIP = "tip_1003";
    /// <summary>
    /// tip_1004:正在连接服务器...
    /// </summary>
    public const string TIP_CONNECTING = "tip_1004";
    /// <summary>
    /// tip_1005:游戏正在更新维护，请稍候再进入游戏
    /// </summary>
    public const string TIP_SERVER_REST = "tip_1005";
    /// <summary>
    /// tip_1006:是否退出游戏？
    /// </summary>
    public const string TIP_EXIT_GAME = "tip_1006";
    /// <summary>
    /// tip_1007:下载完成，请确认安装！
    /// </summary>
    public const string TIP_DOWNLOAD_INSTALL = "tip_1007";
    /// <summary>
    /// tip_1008:下载完成，请确认安装！\n(若安装失败，可尝试重新下载，或手动更新)
    /// </summary>
    public const string TIP_DOWNLOAD_INSTALL_REPEAT = "tip_1008";
    /// <summary>
    /// tip_1009:复制成功
    /// </summary>
    public const string TIP_COPY_SUCCESS = "tip_1009";
    #endregion

    private static Dictionary<string, string> _dic;

    /// <summary>
    /// 当前语言
    /// </summary>
    public static int _language = -1;
    /// <summary>
    /// 当前选择的语言
    /// </summary>
    public static int Language
    {
        get
        {
            if (_language < 0)
            {
                _language = PlayerPrefs.GetInt(FN_LANGUAGE, DEFAULT_LANGUAGE);
                if (_language < 0) _language = DEFAULT_LANGUAGE;
            }
            return _language;
        }
        set
        {
            if (_language == value || value < 0) return;
            _language = value;
            PlayerPrefs.SetInt(FN_LANGUAGE, _language);
            Load();
        }
    }
    /// <summary>
    /// 加载本地化文件
    /// </summary>
    public static void Load()
    {
        string lang = AssetName.LOCALIZATION + Language;
        AssetManager.UnLoadAsset(lang);
        byte[] data = AssetManager.LoadBytes(lang);
        if (data == null || data.Length < 1)
        {
            data = AssetManager.LoadBytes(AssetName.LOCALIZATION + DEFAULT_LANGUAGE);
        }
        if (data != null && data.Length > 0)
        {
            _dic = new ByteReader(data).ReadDictionary();
        }
        else if (_dic == null)
        {
            _dic = new Dictionary<string, string>();
        }
        AssetManager.UnLoadAsset(lang);
    }

    public static string Get(string lab)
    {
        string txt;
        _dic.TryGetValue(lab, out txt);
        return txt ?? lab;
    }

    public static string Format(string lab, object arg)
    {
        return _dic.TryGetValue(lab, out lab) ? string.Format(lab, arg) : lab;
    }
    public static string Format(string lab, object arg0, object arg1)
    {
        return _dic.TryGetValue(lab, out lab) ? string.Format(lab, arg0, arg1) : lab;
    }
    public static string Format(string lab, object arg0, object arg1, object arg2)
    {
        return _dic.TryGetValue(lab, out lab) ? string.Format(lab, arg0, arg1, arg2) : lab;
    }
    public static string Format(string lab, params object[] args)
    {
        return _dic.TryGetValue(lab, out lab) ? string.Format(lab, args) : lab;
    }
}