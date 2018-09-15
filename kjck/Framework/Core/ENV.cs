using UnityEngine;
#if UNITY_IPHONE
using IntPtr = System.IntPtr;
using System.Runtime.InteropServices;
#endif

/// <summary>
/// 环境数据及操作
/// </summary>
public static class ENV
{
    /// <summary>
    /// 当前包名
    /// </summary>
    public static string BundleIdentifier
    {
        get
        {
#if UNITY_EDITOR
            return UnityEditor.PlayerSettings.bundleIdentifier;
#elif UNITY_ANDROID
            return javaClass.CallStatic<string>("GetBundleIdentifier");
#elif UNITY_IPHONE
            return IntPtrToUTF8String(GetBundleIdentifier());
#else
            return string.Empty;
#endif
        }
    }
    /// <summary>
    /// 获取当前包版本名称
    /// </summary>
    public static string BundleVersion
    {
        get
        {
#if UNITY_EDITOR
            return UnityEditor.PlayerSettings.bundleVersion;
#elif UNITY_ANDROID
            return javaClass.CallStatic<string>("GetVersionName");
#elif UNITY_IPHONE
            return IntPtrToUTF8String(GetBundleVersion());
#else
            return "0.0.0.0";
#endif

        }
    }

    /// <summary>
    /// 获取当前包版本号
    /// </summary>
    public static int BundleVersionCode
    {
        get
        {
#if UNITY_EDITOR
            return 0;
#elif UNITY_ANDROID
            return javaClass.CallStatic<int>("GetVersionCode");
#else
            return 0;
#endif
        }
    }

    /// <summary>
    /// 获取Application中定义的MetaData
    /// </summary>
    /// <param name="key">键</param>
    public static string GetAppMetaData(string key)
    {
#if UNITY_EDITOR
        return string.Empty;
#elif UNITY_ANDROID
        return javaClass.CallStatic<string>("GetApplicationMetaData", key);
#elif UNITY_IPHONE
        return string.Empty;
#else
        return string.Empty;
#endif

    }
    /// <summary>
    /// 获取当前Activity中定义的MetaData
    /// </summary>
    /// <param name="key">键</param>
    public static string GetActivityMetaData(string key)
    {
#if UNITY_EDITOR
        return string.Empty;
#elif UNITY_ANDROID
        return javaClass.CallStatic<string>("GetActivityMetaData", key);
#elif UNITY_IPHONE
        return string.Empty;
#else
        return string.Empty;
#endif

    }

    /// <summary>
    /// 获取手机的外部存储路径
    /// </summary>
    public static string GetDownloadPath
    {
        get
        {
#if UNITY_EDITOR
            return Application.temporaryCachePath + "/apk";
#elif UNITY_ANDROID
            return javaClass.CallStatic<string>("GetDownloadPath");
#elif UNITY_IPHONE
            return Application.temporaryCachePath + "/ios";
#else
            return Application.temporaryCachePath + "/apk";
#endif
        }
    }

    /// <summary>
    /// 安装指定路径的APK包
    /// </summary>
    /// <param name="path">APK包的路径</param>
    public static void InstallAPK(string path)
    {
#if UNITY_EDITOR
        Debug.Log("Install Apk :" + path);
#elif UNITY_ANDROID
        javaClass.CallStatic("InstallAPK", path);
#endif
    }

    /// <summary>
    /// WIFI是否连接
    /// </summary>
    public static bool WifiEnabled
    {
        get
        {
#if UNITY_EDITOR
            return Application.internetReachability != NetworkReachability.NotReachable;
#elif UNITY_ANDROID
            return javaClass.CallStatic<bool>("GetWifiEnabled");
#else
            return Application.internetReachability != NetworkReachability.NotReachable;
#endif
        }
    }

    /// <summary>
    /// 获取设备IMEI
    /// </summary>
    public static string DeviceId
    {
        get
        {
#if UNITY_EDITOR
            return SystemInfo.deviceUniqueIdentifier;
#elif UNITY_ANDROID
            return javaClass.CallStatic<string>("GetDeviceId");
#elif UNITY_IPHONE
            return IntPtrToUTF8String(GetDeviceId());
#else
            return SystemInfo.deviceUniqueIdentifier;
#endif
        }
    }

    /// <summary>
    /// 获取设备信息描述
    /// </summary>
    public static string DeviceInfo
    {
        get
        {
            string str = SystemInfo.operatingSystem;
            return str.Length > 48 ? str.Substring(0, 48) : str;
        }
    }

    /// <summary>
    /// 将文本复制到剪切板
    /// </summary>
    public static void CopyToClipboard(string txt)
    {
#if UNITY_EDITOR
        UnityEditor.EditorGUIUtility.systemCopyBuffer = txt;
#elif UNITY_ANDROID
        javaClass.CallStatic("CopyToClipboard", txt, L.Get(L.TIP_COPY_SUCCESS));
#elif UNITY_IPHONE
        _CopyToClipboard(txt);
#else

#endif
    }
    public static int GetBatteryLevel()
    {
#if UNITY_EDITOR
        return 100;
#elif UNITY_ANDROID
        return javaClass.CallStatic<int>("GetBatteryLevel");
#elif UNITY_IPHONE
        return (int)_GetBatteryLevel();
#else
        return 100;
#endif
    }
    /// <summary>
    /// 获取系统剩余内存
    /// </summary>
    public static int GetSystemAvailableMemory()
    {
#if UNITY_EDITOR
        return (int)UnityEngine.Profiling.Profiler.GetTotalUnusedReservedMemory();
#elif UNITY_ANDROID
        return javaClass.CallStatic<int>("GetSystemAvailableMemory");
#elif UNITY_IPHONE
        return (int)_GetSystemAvailableMemory();
#else
        return 0;
#endif
    }
    /// <summary>
    /// 获取apk包assets目录指定名称的资源大小
    /// </summary>
    /// <param name="fileName">资源名称</param>
    public static int GetAssetsDataLength(string fileName)
    {
#if UNITY_EDITOR
        return (int)Kiol.IO.File.Length(Kiol.IO.Path.Combine(Application.streamingAssetsPath, fileName));
#elif UNITY_ANDROID
        return javaClass.CallStatic<int>("GetAssetsDataLength", fileName);
#else
        return (int)Kiol.IO.File.Length(Kiol.IO.Path.Combine(Application.streamingAssetsPath, fileName));
#endif
    }
    /// <summary>
    /// 获取apk包assets目录指定名称的资源
    /// </summary>
    /// <param name="fileName">资源名称</param>
    public static byte[] GetAssetsData(string fileName)
    {
#if UNITY_EDITOR
        return Kiol.IO.File.ReadFile(Kiol.IO.Path.Combine(Application.streamingAssetsPath, fileName));
#elif UNITY_ANDROID
        try
        {
            using (AndroidJavaObject ajo = javaClass.CallStatic<AndroidJavaObject>("GetAssetsData", fileName))
            {
                if (ajo != null)
                {
                    System.IntPtr ptr = ajo.GetRawObject();
                    if (ptr != System.IntPtr.Zero) return AndroidJNI.FromByteArray(ptr);
                }
            }
        }
        catch
        {
        }
        return null;
        //return javaClass.CallStatic<byte[]>("GetAssetsData", fileName);
        //return AndroidJNI.FromByteArray(javaClass.CallStatic<System.IntPtr>("GetAssetsData", fileName));
#else
        return Kiol.IO.File.ReadFile(Kiol.IO.Path.Combine(Application.streamingAssetsPath, fileName));
#endif
    }

#if UNITY_IPHONE
    /// <summary>
    /// 跨平台指针转换到UTF8String
    /// </summary>
    /// <param name="ptr"></param>
    /// <returns></returns>
    public static string IntPtrToUTF8String(IntPtr ptr)
    {
        int size = 0;
        for (size = 0; Marshal.ReadByte(ptr, size) > 0; size++) ;
        byte[] bytes = new byte[size];
        Marshal.Copy(ptr, bytes, 0, size);
        return System.Text.Encoding.UTF8.GetString(bytes);
    }
    [DllImport("__Internal")] private static extern IntPtr GetBundleIdentifier();
    [DllImport("__Internal")] private static extern IntPtr GetBundleVersion();
    [DllImport("__Internal")] private static extern IntPtr GetDeviceId();
    [DllImport("__Internal")] private static extern void _CopyToClipboard(string txt);
    [DllImport("__Internal")] private static extern long _GetSystemAvailableMemory();
    [DllImport("__Internal")] private static extern int _GetBatteryLevel();
#elif UNITY_ANDROID
    private static AndroidJavaObject _JavaClass;
    private static AndroidJavaObject javaClass { get { if (_JavaClass == null) _JavaClass = new AndroidJavaClass("com.android.tool.AndroidTool"); return _JavaClass; } }
#endif
}
