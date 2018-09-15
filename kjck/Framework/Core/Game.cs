using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Kiol.IO;
using Kiol.Json;
using Kiol.Util;

public class Game : MonoBehaviour
{
    public static string clientUpdateUrl;
    public static string config;

    private static Game _Instance;
    
    public static Game instance { get { return _Instance; } }
    
    [NonSerialized] private List<string> mSrcUrl = new List<string>(4);
    [NonSerialized] private List<string> mCdnUrl = new List<string>(4);

#if TOLUA
    [NonSerialized] private LuaManager mLuaManager;
#endif

    private void Awake()
    {
        // 单例
        if (_Instance && _Instance != this)
        {
            Debug.LogWarning("the game[" + _Instance + "] instance was exist!!");
            this.DestructIfOnly();
            return;
        }

        _Instance = this;
        DontDestroyOnLoad(transform.root);
        
        //基本设置
        //QualitySettings.SetQualityLevel(4);
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
        Application.runInBackground = true;
        Time.timeScale = 1f;

        // 初始化资源管理器
        AssetManager.Init();
        // 加载本地化模块
        L.Load();
        // 初始化线程管理器
        ThreadManager.Init();
        // 初始化场景管理器
        SceneManager.Init();
        // 加载状态器
        StatusBar.Init();
        // 加载消息盒
        MessageBox.Init();
        
        // 初始化BGM
        BGM.Init();
        
        //分辨率检测
        Resolution resoulution = Screen.currentResolution;
        if ((resoulution.width < 800 && resoulution.height < 480) || (resoulution.width < 480 && resoulution.height < 800))
        {
            MessageBox.Show(L.Get(L.ERR_RESOLUTION_NOT_SUPPORTED), input => { Application.Quit(); });
            return;
        }
        
#if UNITY_ANDROID
        float clock = GetProcessorClock();
        Application.targetFrameRate = clock > 0 && clock < 6 ? 30 : 60;
#else
        Application.targetFrameRate = 60;
#endif
        // 加载初始地址
#if TEST
        LoadSrcUrlDebug();

        InitTestLogger();
#else
        LoadSrcUrl();
#endif
        OnStart();
    }

#if TEST
    private System.IO.StreamWriter mLogWriter;
    private System.IO.StreamWriter mWarnWriter;
    private System.IO.StreamWriter mErrorWriter;
    private void InitTestLogger()
    {
        string path = Application.persistentDataPath + "/log.txt";
        Debug.Log("log path = " + path);
        if (!System.IO.File.Exists(path)) System.IO.File.Create(path).Dispose();
         mLogWriter = new System.IO.StreamWriter(path, true, System.Text.Encoding.UTF8);
        path = Application.persistentDataPath + "/log_warn.txt";
        Debug.Log("log warn path = " + path);
        if (!System.IO.File.Exists(path)) System.IO.File.Create(path).Dispose();
        mWarnWriter = new System.IO.StreamWriter(path, true, System.Text.Encoding.UTF8);
        path = Application.persistentDataPath + "/log_err.txt";
        Debug.Log("log error path = " + path);
        if (!System.IO.File.Exists(path)) System.IO.File.Create(path).Dispose();
        mErrorWriter = new System.IO.StreamWriter(path, true, System.Text.Encoding.UTF8);
        Application.logMessageReceived += LogCallback;
    }
    private void LogCallback(string condition, string stackTrace, LogType type)
    {
        if (type == LogType.Warning)
        {
            mWarnWriter.WriteLine(DateTime.Now.ToString());
            mWarnWriter.WriteLine(condition);
            mWarnWriter.WriteLine(stackTrace);
            mWarnWriter.WriteLine();
            mWarnWriter.Flush();
        }
        else if (type == LogType.Error || type == LogType.Exception || type == LogType.Assert)
        {
            mErrorWriter.WriteLine(DateTime.Now.ToString());
            mErrorWriter.WriteLine(condition);
            mErrorWriter.WriteLine(stackTrace);
            mErrorWriter.WriteLine();
            mErrorWriter.Flush();

            //MessageBox.Show("出现异常，请将提交日志文件:\n" + Application.persistentDataPath + "/log.txt");
        }

        mLogWriter.WriteLine(DateTime.Now.ToString() + "    " + type.ToString());
        mLogWriter.WriteLine(condition);
        mLogWriter.WriteLine(stackTrace);
        mLogWriter.WriteLine();
        mLogWriter.Flush();
    }
    private void OnApplicationQuit()
    {
        mLogWriter.Flush();
        mLogWriter.Close();
        mWarnWriter.Flush();
        mWarnWriter.Close();
        mErrorWriter.Flush();
        mErrorWriter.Close();
    }
    /// <summary>
    /// 加载初始地址
    /// </summary>
    private void LoadSrcUrlDebug(bool retry = false)
    {
        TextAsset ta;
        ta = retry ? Resources.Load<TextAsset>(AssetPath.Data + AssetName.SRC_URL + "_all") : AssetManager.Load<TextAsset>(AssetName.SRC_URL + "_all");
        if (ta)
        {
            mSrcUrl.Clear();
            JsonObject child;
            JsonObject srcUrl = new JsonObject(Encryption.DecompressStr(ta.bytes, Encryption.DEFAULT_ENCRYPT_SKIP));
            List<string> lst = new List<string>(srcUrl.childCount);
            for (int i = 0; i < srcUrl.childCount; i++)
            {
                child = srcUrl[i];
                if (child.type != JsonObject.Type.Array || child.childCount < 1) continue;
                lst.Add(child.name);
            }

            if (lst.Count > 0)
            {
                MessageBox.Show("调试模式，选择服务器", string.Join(",", lst.ToArray()), input =>
                {
                    child = srcUrl.GetChild(input.button);
                    if (child.type == JsonObject.Type.Array && child.childCount > 0)
                    {
                        JsonObject child2;
                        for (int i = 0; i < child.childCount; i++)
                        {
                            child2 = child[i];
                            if (child2.type != JsonObject.Type.String || string.IsNullOrEmpty(child2.value)) continue;
                            if (child2.value.StartsWith("http://") || child2.value.StartsWith("https://"))
                            {
                                mSrcUrl.Add(child2.value);
                            }
                        }
                        if (mSrcUrl.Count > 0)
                        {
                            MessageBox.ShowConfirm("调试模式，是否加载SDK", input2 =>
                            {
                                if (input2.buttonIndex == 0)
                                {
                                    SDK.isEnabled = true;
                                    StartCoroutine(InitSDK());
                                }
                                else
                                {
                                    StartCoroutine(CheckCdnUrl());
                                }
                            });
                            return;
                        }
                    }
                    MessageBox.Show("选择的配置无法加载", L.Retry + "," + "原址启动", input2 => { if (input2.buttonIndex == 0) LoadSrcUrlDebug(true); else LoadSrcUrl(); });
                });
                return;
            }
        }

        MessageBox.Show("调试配置加载失败", L.Retry + "," + "原址启动", input => { if (input.buttonIndex == 0) LoadSrcUrlDebug(true); else LoadSrcUrl(); });
    }
#endif
    /// <summary>
    /// 加载初始地址
    /// </summary>
    private void LoadSrcUrl(bool retry = false)
    {
        TextAsset ta = retry ? Resources.Load<TextAsset>(AssetPath.Data + AssetName.SRC_URL) : AssetManager.Load<TextAsset>(AssetName.SRC_URL);
        if (ta)
        {
            mSrcUrl.Clear();
            JsonObject child;
            JsonObject srcUrl = new JsonObject(Encryption.DecompressStr(ta.bytes, Encryption.DEFAULT_ENCRYPT_SKIP));
            for (int i = 0; i < srcUrl.childCount; i++)
            {
                child = srcUrl[i];
                if (child.type != JsonObject.Type.String || string.IsNullOrEmpty(child.value)) continue;
                if (child.value.StartsWith("http://") || child.value.StartsWith("https://"))
                {
                    mSrcUrl.Add(child.value);
                }
            }
            if (mSrcUrl.Count > 0)
            {
                // 加载SDK
                SDK.isEnabled = true;
                StartCoroutine(InitSDK());
                return;
            }
        }

        MessageBox.Show(L.Get(L.ERR_CHECK_CLIENT), L.Retry, input => { LoadSrcUrl(true); });
    }

    /// <summary>
    /// 检测SDK
    /// </summary>
    /// <returns></returns>
    private IEnumerator InitSDK()
    {
        if (SDK.isEnabled && SDK.initStatus != 1)
        {
            SDK.Init();
            float timeout = Time.realtimeSinceStartup + 10f;
            while (SDK.initStatus == 0 && timeout > Time.realtimeSinceStartup) yield return null;
            if (SDK.initStatus != 1)
            {
                MessageBox.Show(L.Get(L.ERR_SDK_INIT), L.Retry + "," + L.Exit, input =>
                {
                    if (input.buttonIndex == 0)
                    {
                        StartCoroutine(InitSDK());
                    }
                    else
                    {
                        Application.Quit();
                    }
                });
                yield break;
            }
        }
        StartCoroutine(CheckCdnUrl());
        yield break;
    }
    /// <summary>
    /// 检测CDN地址集
    /// </summary>
    private IEnumerator CheckCdnUrl()
    {
        // 联网检测
        WWW www = null;
        StatusBar.TempProcess atp = StatusBar.Show(StatusBar.TempProcess.ID_CHECK_LINK, StatusBar.DEFAULT_TIMEOUT_LONG, false);
        for (int i = 0; i < mSrcUrl.Count; i++)
        {
            if (www != null) www.Dispose();
            Debug.Log("try get init url : " + mSrcUrl[i]);
            www = new WWW(Url.Dynamic(mSrcUrl[i]));
            yield return www;
            if (string.IsNullOrEmpty(www.error)) break;
        }
        
        atp.Done();

        string banMsg = null;
        //Debug.Log("Ver Content : " + www.text);
        if (string.IsNullOrEmpty(www.error))
        {
            try
            {
                // CDN地址集获取
                mCdnUrl.Clear();
                string[] vals = www.text.TrimBOM().Split('\r');
                for (int i = 0; i < vals.Length; i++)
                {
                    if (string.IsNullOrEmpty(vals[i])) continue;
                    string val = vals[i].Trim();
                    if (string.IsNullOrEmpty(val)) continue;
                    if (val.StartsWith("http://") || val.StartsWith("https://"))
                    {
                        mCdnUrl.Add(val);
                    }
                    else if (val[0] == '@' && mCdnUrl.Count == 0)
                    {
                        // 特殊禁用状态
                        banMsg = val.Substring(1);
                        break;
                    }
                }
            }
            catch (Exception e)
            {
                Debug.LogWarning(e);
                MessageBox.Show(L.Get(L.ERR_SERVER_DATA), L.Retry, input => { StartCoroutine(CheckCdnUrl()); });
                yield break;
            }
            finally
            {
                www.Dispose();
            }
        }
        else
        {
            Debug.Log(www.error);
            www.Dispose();
            MessageBox.Show(L.Get(L.ERR_CONNECT_FAILED), L.Retry, input => { StartCoroutine(CheckCdnUrl()); });
            yield break;
        }

        //Analytics.StartWithAppKeyAndChannelId("547be055fd98c54f59000680", SDK.CurChannel);
        //Analytics.SetLogEnabled(false);
        
        //TdAnalytics.OnStart();

        yield return null;
        //Analytics.Event(UMEvent.GameLine, "0_StartGame");
        //TdAnalytics.OnEvent(TDEvent.GameLine, "0_StartGame", "0_StartGame");

        if (mCdnUrl.Count > 0)
        {
            JsonObject update;
            for (int i = 0; i < mCdnUrl.Count; i++)
            {
                www = new WWW(Url.Dynamic(mCdnUrl[i] + AssetName.UPDATE));
                yield return www;
                Debug.Log(www.url);
                if (string.IsNullOrEmpty(www.error))
                {
                    try
                    {
                        config = www.text.TrimBOM();
                        update = new JsonObject(www.text.TrimBOM());
                        if (update.childCount > 0)
                        {
#if UNITY_ANDROID
                            update = update["adr"];
#elif UNITY_IPHONE
                            update = update["ios"];
#else
                            update = update["def"];
#endif
                            if (update != null && update.childCount > 0)
                            {
                                //AssetManager.ApplyUrl(mCdnUrl[i], update);
                                //StartCoroutine(CheckClientVer(mCdnUrl[i], update));
                                config = update.ToJson();
                                CheckClientVer(mCdnUrl[i], update);
                                break;
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.Log(www.url + " error : " + e);
                    }
                }
                else
                {
                    Debug.Log(www.url + " error : " + www.error);
                }
                www.Dispose();
                www = null;
            }
            if (www == null)
            {
                MessageBox.Show(L.Get(L.ERR_CHECK_CLIENT), L.Retry + "," + L.Exit, input => { if (input.buttonIndex == 0) StartCoroutine(CheckCdnUrl()); });
                yield break;
            }
            www.Dispose();
        }
        else
        {
            MessageBox.Show(string.IsNullOrEmpty(banMsg) ? L.Get(L.ERR_CDN_URL_NOT_FOUND) : banMsg, L.Exit, input => { Application.Quit(); });
        }
    }
    /// <summary>
    /// 检测客户端版本
    /// </summary>
    private void CheckClientVer(string cdnUrl, JsonObject update)
    {
        //配置默认渠道(若有)
        JsonObject tempJo = update["def_chn"];
        if (tempJo != null) SDK.defaultChannel = tempJo.ValueFor<int>();

        //取得渠道数据
        JsonObject channel = update["C" + SDK.channel];
        if (channel == null) channel = update["C" + SDK.defaultChannel];

        // 取得子渠道(若有)
        Debug.Log("subChannel = " + SDK.subChannel);
        JsonObject subChannel = channel["F" + SDK.subChannel];
        Debug.Log("subNode = " + subChannel);
        if (subChannel == null)
        {
            // 取得包渠道(若有)
            Debug.Log("bundle id = " + ENV.BundleIdentifier);
            subChannel = channel[ENV.BundleIdentifier];
            Debug.Log("bundleNode = " + subChannel);
        }

        if (subChannel == null) subChannel = channel;

        // 替换渠道配置
        tempJo = subChannel.GetChild("lua") ?? channel.GetChild("lua");
        if (tempJo != null)
        {
            update.RemoveChild("lua");
            update.AddChild("lua", tempJo.ToString(), JsonObject.Type.Object);
        }
        tempJo = subChannel.GetChild("dat") ?? channel.GetChild("dat");
        if (tempJo != null)
        {
            update.RemoveChild("dat");
            update.AddChild("dat", tempJo.ToString(), JsonObject.Type.Object);
        }
        tempJo = subChannel.GetChild("res") ?? channel.GetChild("res");
        if (tempJo != null)
        {
            update.RemoveChild("res");
            update.AddChild("res", tempJo.ToString(), JsonObject.Type.Object);
        }
        tempJo = subChannel.GetChild("svr") ?? channel.GetChild("svr");
        if (tempJo != null)
        {
            update.RemoveChild("svr");
            update.AddChild("svr", tempJo.ToString(), JsonObject.Type.Object);
        }
        // 配置URL到AssetManager
        AssetManager.ApplyUrl(cdnUrl, update);

        clientUpdateUrl = subChannel.GetChildValue("u");

        StartCoroutine(CheckAssets(update));
    }
    /// <summary>
    /// 检测资源
    /// </summary>
    private IEnumerator CheckAssets(JsonObject update)
    {
        StatusBar.TempProcess atp = StatusBar.Show(StatusBar.TempProcess.ID_CHECK_CLIENT, StatusBar.DEFAULT_TIMEOUT_LONG, false);

        WWW www = null;
        string path = null;
        bool check = false;
        CRC32 crc = null;
        byte[] buffer = null;
        int size = 0;
        Exception exception = null;
        JsonObject tempJo = null;
        JsonObject index = null;
        List<JsonObject> luaLst = new List<JsonObject>(16);
        List<JsonObject> datLst = new List<JsonObject>(16);
        List<JsonObject> resLst = new List<JsonObject>(16);
        string btnLab = L.Retry + "," + L.Exit;
        MessageBox.Feedback checkError = input => { if (input.buttonIndex == 0) StartCoroutine(CheckAssets(update)); else Application.Quit(); };

        //校验lua资源
        path = LuaConst.luaResDir + AssetName.INDEX;
        check = File.Exists(path);
        if (check)
        {
            crc = new CRC32(path);
            while (!crc.isDone) yield return null;
            check = crc.crc.ToString("X") == update.GetValueByPath("lua", "c");
        }
        if (check)
        {
            buffer = File.ReadFile(path);
        }
        else
        {
            Debug.Log("download lua index");
            www = new WWW(Url.Dynamic(AssetManager.luaUrl + AssetName.INDEX));
            yield return www;
            if (!string.IsNullOrEmpty(www.error))
            {
                atp.Done();
                
                MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
                yield break;
            }
            if (!File.WriteFile(path, www.bytes))
            {
                atp.Done();
                MessageBox.Show(L.Get(L.ERR_WRITE_DATA), btnLab, checkError);
                yield break;
            }
            buffer = www.bytes;
            www.Dispose();
        }
        try
        {
            index = new JsonObject(Encryption.DecompressStr(buffer, Encryption.DEFAULT_ENCRYPT_SKIP));
        }
        catch (Exception e)
        {
            exception = e;
        }
        if (exception == null)
        {
            for (int i = 0; i < index.childCount; i++)
            {
                tempJo = index[i];
                string nm = tempJo.GetChildValue("name");
                if (string.IsNullOrEmpty(nm)) continue;
                CheckChannelItem(tempJo);
                path = LuaConst.luaResDir + MD5.GetMd5String(nm);
                check = File.Exists(path);
                if (check)
                {
                    crc = new CRC32(path);
                    while (!crc.isDone) yield return null;
                    check = crc.crc.ToString("X") == tempJo.GetChildValue("crc");
                }
                if (check) continue;
                if (KConvert.Base16ToUInt32(tempJo.GetChildValue("crc")) != 0)
                {
                    luaLst.Add(tempJo);
                    size += tempJo.GetChildValue<int>("size");
                }
                File.Delete(path);
            }
        }
        if (exception != null)
        {
            Debug.Log("cac check error :" + exception);
            MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
            yield break;
        }

        //检测游戏数据
        path = AssetManager.datPath + AssetName.INDEX;
        check = File.Exists(path);
        if (check)
        {
            crc = new CRC32(path);
            while (!crc.isDone) yield return null;
            check = crc.crc.ToString("X") == update.GetValueByPath("dat", "c");
        }
        if (check)
        {
            buffer = File.ReadFile(path);
        }
        else
        {
            Debug.Log("download dat index");
            www = new WWW(Url.Dynamic(AssetManager.datUrl + AssetName.INDEX));
            yield return www;
            if (!string.IsNullOrEmpty(www.error))
            {
                atp.Done();
                MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
                yield break;
            }
            if (!File.WriteFile(path, www.bytes))
            {
                atp.Done();
                MessageBox.Show(L.Get(L.ERR_WRITE_DATA), btnLab, checkError);
                yield break;
            }
            buffer = www.bytes;
            www.Dispose();
        }
        try
        {
            index = new JsonObject(Encryption.DecompressStr(buffer, Encryption.DEFAULT_ENCRYPT_SKIP));
        }
        catch (Exception e)
        {
            exception = e;
        }
        if (exception == null)
        {
            for (int i = 0; i < index.childCount; i++)
            {
                tempJo = index[i];
                string nm = tempJo.GetChildValue("name");
                if (string.IsNullOrEmpty(nm)) continue;
                CheckChannelItem(tempJo);
                path = AssetManager.datPath + nm + AssetManager.DAT_EXTENSION;
                check = File.Exists(path);
                if (check)
                {
                    crc = new CRC32(path);
                    while (!crc.isDone) yield return null;
                    check = crc.crc.ToString("X") == tempJo.GetChildValue("crc");
                }
                if (check) continue;
                if (KConvert.Base16ToUInt32(tempJo.GetChildValue("crc")) != 0)
                {
                    datLst.Add(tempJo);
                    size += tempJo.GetChildValue<int>("size");
                }
                File.Delete(path);
            }
        }
        if (exception != null)
        {
            atp.Done();
            Debug.Log("dat check error :" + exception);
            MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
            yield break;
        }

        //检测游戏资源
        path = AssetManager.resPath + AssetName.INDEX;
        check = File.Exists(path);
        if (check)
        {
            crc = new CRC32(path);
            while (!crc.isDone) yield return null;
            check = crc.crc.ToString("X") == update.GetValueByPath("res", "c");
        }
        if (check)
        {
            buffer = File.ReadFile(path);
        }
        else
        {
            Debug.Log("download res index");
            www = new WWW(Url.Dynamic(AssetManager.resUrl + AssetName.INDEX));
            yield return www;
            if (!string.IsNullOrEmpty(www.error))
            {
                atp.Done();
                MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
                yield break;
            }
            if (!File.WriteFile(path, www.bytes))
            {
                atp.Done();
                MessageBox.Show(L.Get(L.ERR_WRITE_DATA), btnLab, checkError);
                yield break;
            }
            buffer = www.bytes;
            www.Dispose();
        }
        try
        {
            index = new JsonObject(Encryption.DecompressStr(buffer, Encryption.DEFAULT_ENCRYPT_SKIP));
        }
        catch (Exception e)
        {
            exception = e;
        }
        if (exception == null)
        {
            //校对后台资源
            ThreadManager.Run(BackResCheck, index);
            //统计下载大小
            for (int i = 0; i < index.childCount; i++)
            {
                tempJo = index[i];
                if (tempJo.GetChildValue("perload") == "1")
                {
                    string nm = tempJo.GetChildValue("name");
                    if (string.IsNullOrEmpty(nm)) continue;
                    path = AssetManager.resPath + nm + AssetManager.BUNDLE_EXTENSION;
                    check = File.Exists(path) && AssetManager.GetAssetCRC(path).ToString("X") == tempJo.GetChildValue("crc");
                    if (check) continue;
                    if (KConvert.Base16ToUInt32(tempJo.GetChildValue("crc")) != 0)
                    {
                        resLst.Add(tempJo);
                        size += tempJo.GetChildValue<int>("size");
                    }
                    File.Delete(path);
                }
            }
        }
        if (exception != null)
        {
            atp.Done();
            Debug.Log("res check error :" + exception);
            MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
            yield break;
        }

        //下载必须资源
        if (size > 0)
        {
            int curSize = 0;
            //下载lua
            if (luaLst.Count > 0)
            {
                for (int i = 0; i < luaLst.Count; i++)
                {
                    tempJo = luaLst[i];
                    string nm = tempJo.GetChildValue("name");
                    www = new WWW(Url.Dynamic(AssetManager.luaUrl + nm + tempJo.GetChildValue("r") + AssetManager.DAT_EXTENSION));
                    yield return www;
                    if (!string.IsNullOrEmpty(www.error))
                    {
                        Debug.LogWarning("load [" + www.url + "] error:" + www.error);
                        atp.Done();
                        MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
                        yield break;
                    }
                    if (!File.WriteFile(LuaConst.luaResDir + MD5.GetMd5String(nm), www.bytes))
                    {
                        atp.Done();
                        MessageBox.Show(L.Get(L.ERR_WRITE_DATA), btnLab, checkError);
                        yield break;
                    }
                    curSize += tempJo.GetChildValue<int>("size");
                    //此处刷新进度显示
                    atp.process = (float)curSize / (float)size;
                    Debug.Log("download " + nm);
                }
            }
            //下载数据
            if (datLst.Count > 0)
            {
                for (int i = 0; i < datLst.Count; i++)
                {
                    tempJo = datLst[i];
                    string nm = tempJo.GetChildValue("name");
                    www = new WWW(Url.Dynamic(AssetManager.datUrl + nm + tempJo.GetChildValue("r") + AssetManager.DAT_EXTENSION));
                    nm += AssetManager.DAT_EXTENSION;
                    yield return www;
                    if (!string.IsNullOrEmpty(www.error))
                    {
                        Debug.LogWarning("load [" + www.url + "] error:" + www.error);
                        atp.Done();
                        MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
                        yield break;
                    }
                    if (!File.WriteFile(AssetManager.datPath + nm, www.bytes))
                    {
                        atp.Done();
                        MessageBox.Show(L.Get(L.ERR_WRITE_DATA), btnLab, checkError);
                        yield break;
                    }
                    curSize += tempJo.GetChildValue<int>("size");
                    //此处刷新进度显示
                    atp.process = (float)curSize / (float)size;
                    Debug.Log("download " + nm);
                }
            }
            //下载资源
            if (resLst.Count > 0)
            {
                for (int i = 0; i < resLst.Count; i++)
                {
                    tempJo = resLst[i];
                    string nm = tempJo.GetChildValue("name") + AssetManager.BUNDLE_EXTENSION;
                    www = new WWW(Url.Dynamic(AssetManager.resUrl + nm));
                    yield return www;
                    if (!string.IsNullOrEmpty(www.error))
                    {
                        Debug.LogWarning("load [" + www.url + "] error:" + www.error);
                        atp.Done();
                        MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
                        yield break;
                    }
                    if (!File.WriteFile(AssetManager.resPath + nm, www.bytes))
                    {
                        atp.Done();
                        MessageBox.Show(L.Get(L.ERR_WRITE_DATA), btnLab, checkError);
                        yield break;
                    }
                    curSize += tempJo.GetChildValue<int>("size");
                    //此处刷新进度显示
                    atp.process = (float)curSize / (float)size;
                    Debug.Log("download " + nm);
                }
            }
        }

        atp.Done();

        StartCoroutine(CheckEnd(update));

        yield break;
    }
    /// <summary>
    /// 检测结束
    /// </summary>
    private IEnumerator CheckEnd(JsonObject update)
    {
        StatusBar.TempProcess atp = StatusBar.Show(StatusBar.TempProcess.ID_CHECK_CLIENT, StatusBar.DEFAULT_TIMEOUT_LONG, false);

        MessageBox.Feedback checkError = input => { if (input.buttonIndex == 0) StartCoroutine(CheckEnd(update)); else Application.Quit(); };

        //服务器列表校检
        string path = AssetManager.svrPath;
        bool check = File.Exists(path);
        byte[] svrBuffer = null;
        string btnLab = L.Retry + "," + L.Exit;

        if (check)
        {
            CRC32 crc = new CRC32(path);
            while (!crc.isDone) yield return null;
            check = crc.crc.ToString("X") == update.GetValueByPath("svr", "c");
        }
        if (check)
        {
            svrBuffer = File.ReadFile(path);
        }
        else
        {
            Debug.Log("download svr");
            WWW www = new WWW(Url.Dynamic(AssetManager.svrUrl));
            yield return www;
            if (!string.IsNullOrEmpty(www.error))
            {
                atp.Done();
                MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
                yield break;
            }
            if (!File.WriteFile(path, www.bytes))
            {
                atp.Done();
                MessageBox.Show(L.Get(L.ERR_WRITE_DATA), btnLab, checkError);
                yield break;
            }
            svrBuffer = www.bytes;
            www.Dispose();
        }

        atp.Done();

        //string svrJson = Encryption.DecompressStr(svrBuffer, Encryption.DEFAULT_ENCRYPT_SKIP);
        //if (string.IsNullOrEmpty(svrJson))
        //{
        //    MessageBox.Show(L.Get(L.ERR_DOWNLOAD_DATA), btnLab, checkError);
        //    yield break;
        //}

        yield return new WaitForSeconds(0.2f);

        //OnCheckEnd(svrBuffer);
        OnCheckEnd();
    }
    /// <summary>
    /// 后台校检动态资源
    /// </summary>
    private void BackResCheck(object state)
    {
        JsonObject index = state as JsonObject;
        if (index == null) return;
        for (int i = 0; i < index.childCount; i++)
        {
            JsonObject jo = index[i];
            if (jo.GetChildValue("perload") == "1") continue;
            string nm = jo.GetChildValue("name");
            if (string.IsNullOrEmpty(nm)) continue;
            string path = AssetManager.resPath + nm + AssetManager.BUNDLE_EXTENSION;
            if (File.Exists(path))
            {
                if (AssetManager.GetAssetCRC(path).ToString("X") == jo.GetChildValue("crc")) continue;
                File.Delete(path);
                Debug.Log(nm + " delete!");
            }
        }
    }
    /// <summary>
    /// 检测渠道项
    /// </summary>
    private void CheckChannelItem(JsonObject item)
    {
        JsonObject child = item.GetChild("ex");
        if (child == null || child.childCount < 1) return;
        JsonObject jo;
        for (int i = 0; i < child.childCount; i++)
        {
            jo = child[i];
            if (jo == null || jo.childCount < 1) continue;
            string r = jo.GetChildValue("r");
            if (string.IsNullOrEmpty(r)) continue;
            string c = jo.GetChildValue("c");
            if (string.IsNullOrEmpty(c) || c == "0") continue;
            if (Tools.ValInRange(SDK.channel, r))
            {
                item.RemoveChild("r");
                item.AddChild("r", r, JsonObject.Type.String);
                jo = item.GetChild("crc");
                if (jo != null) jo.value = c;
                return;
            }
        }
    }

#if !UNITY_IPHONE
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape) && !isBusy)
        {
            SDK.ShowExitView();
        }
        else if (Input.GetKeyDown(KeyCode.Menu))
        {
            if (!MessageBox.IsShow) SDK.ShowExitView();
        }
#if UNITY_EDITOR
        //if (Input.GetKey(KeyCode.K))
        //{
        //    Application.targetFrameRate = Mathf.Max(1, Application.targetFrameRate - 1);
        //}
        //else
        //{
        //    Application.targetFrameRate = Config.FRAME_RATE;
        //}

        //if (Input.GetKey(KeyCode.S))
        //{
        //    LoadScene(Scene.Login);
        //}
#endif
    }
#endif

    public static bool isBusy { get { return MessageBox.IsShow || StatusBar.IsShow; } }

    private void OnMemoryWarning(string level)
    {
        Debug.LogWarning("receive memory warning level = " + level);
        int l = 0;
        int.TryParse(level, out l);
        AssetManager.UnLoadAsset(l);
#if TOLUA
        LuaManager.GC();
        LuaManager.CallFunction("Game.OnMemoryWarning", l);
#endif
    }

    private float GetProcessorClock()
    {
        float clock = 0f;
        string pt = SystemInfo.processorType;
        int idx = pt.IndexOf("GHz", StringComparison.CurrentCultureIgnoreCase);
        if (idx > 0)
        {
            int idx2 = pt.LastIndexOf(' ', idx);
            if (idx2 >= 0 && idx2 < idx)
            {
                float.TryParse(pt.Substring(idx2 + 1, idx - idx2 - 1), out clock);
            }
        }
        Debug.Log(pt + "(" + SystemInfo.processorCount + "x" + clock.ToString("f2") + ")");
        return clock * SystemInfo.processorCount;
    }

    protected virtual void OnStart() { }

#if TOLUA
    protected virtual void OnCheckEnd()
    {
        if (mLuaManager) Destroy(mLuaManager);
        mLuaManager = gameObject.AddComponent<LuaManager>();
    }
#else
    protected virtual void OnCheckEnd() { }
#endif
}
