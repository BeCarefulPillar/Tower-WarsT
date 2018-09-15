//Assets Manager Copyright © 何权

using UnityEngine;
using Kiol.IO;
using System.Collections;
using System.Collections.Generic;

public class Asset : IProgress
{
    /// <summary>
    /// 资源请求委托
    /// </summary>
    /// <param name="asset">资源</param>
    public delegate void AssetRequest(Asset asset);

    /// <summary>
    /// 请求数据网络下载权限
    /// </summary>
    public static AssetRequest requestDataNetPerm;

    /// <summary>
    /// 资源异步加载的阈值
    /// </summary>
    public static int aysncDownSize = 524288;
    /// <summary>
    /// 一次性下载阈值
    /// </summary>
    public static int quickDownSize = 1048576;
    /// <summary>
    /// 分块下载的块大小
    /// </summary>
    public static int dataBlockSize = 102400;

    private byte mWeight = 0;//权重

    private string mName;//资源名称
    private int mUseCount = 0;//资源使用次数
    private byte mStatus = 0;//0=初始 1=正在加载 2=加载完成 3=加载中断
    private float mExpiredTime = 0;//开始加载的时间
    private float mPercent = 0;//加载进度
    private int mSize = 0;
    private WWW mWWW;
    private AssetBundle mBundle;//资源包，若是内部资源则为null
    private Object mRes;//最终资源

    private AssetMeta mMeta;// 元数据
    private byte mDataNetPerm = 0;// 数据网络下载权限 0=未知, 1=同意，2=拒绝

    private IEnumerator mLoadCoroutine;

    private List<AssetLoader> mLoaders;//加载器列表
    private List<AssetRequest> mCallback;//加载回调列表

#if TEST
    private string debugInfo = string.Empty;
#endif

#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public Asset(AssetMeta meta) : this(meta.name)
    {
        mMeta = meta;
    }

    public Asset(string name)
    {
        mName = name;
        mWeight = 128;
    }

    public void LoadImmediate()
    {
        if (isDone) return;

        bool isExt = isExternal;
        
        if (isExt && !mBundle)
        {
            string exName = mName + AssetManager.BUNDLE_EXTENSION;

            // 加载外部包
            byte[] data = File.ReadFile(Path.Combine(AssetManager.resPath, exName));
            if (data != null && data.Length > 0)
            {
                mSize = data.Length;
                mBundle = AssetBundle.LoadFromMemory(data);
                if (mBundle == null) mBundle = AssetManager.FindAssetBundle(mName);
            }

            if (!mBundle)
            {
                // 加载内部流
#if UNITY_ANDROID
                data = ENV.GetAssetsData(exName);
#else
                data = File.ReadFile(AssetManager.streamPath + exName);
#endif
                if (data != null && data.Length > 0)
                {
                    mSize = data.Length;
                    mBundle = AssetBundle.LoadFromMemory(data);
                    if (mBundle == null) mBundle = AssetManager.FindAssetBundle(mName);
                }
            }
        }

        // 加载包资源
        if (mBundle)
        {
            mBundle.name = mName;
            mRes = mBundle.LoadAsset<GameObject>(mName);
            if (!mRes) mRes = mBundle.LoadAsset(mName);
            if (mRes)
            {
                Done();
                return;
            }
            else
            {
                mBundle.Unload(true);
                mBundle = null;
            }
        }
        else
        {
            mSize = 0;
        }

        // 尝试下载外部资源
        if (isExt && AssetManager.hasWebAsset)
        {
            AssetManager.LoadAssetAsync(mName, false);
        }
        else 
        {
            // 尝试加载内部资源
            mRes = Resources.Load(AssetManager.GetPathFromAsset(this));

            if (!mRes) mRes = Resources.Load(mName);

            if (mRes) Done();
        }
    }

#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public bool Loading()
    {
        if (isDone)
        {
            if (isTimeOut) Done(true);
            return false;
        }
        if (mLoadCoroutine == null)
        {
            mLoadCoroutine = OnLoad();
        }
        return mLoadCoroutine.MoveNext();
    }

#if TEST
    private string WriteDebugInfo(int step)
    {
        return debugInfo += step + "-";
    }
#endif

    private IEnumerator OnLoad()
    {
        if (mStatus != 0) yield break;
#if TEST
        debugInfo = "asset[" + mName + "] load process: ";

        WriteDebugInfo(1);
#endif
        if (mRes || (mBundle && !hasRefer))
        {
            Done(!mRes);
            yield break;
        }
#if TEST
        WriteDebugInfo(2);
#endif
        mSize = 0;
        mPercent = 0f;
        mStatus = 1;
        ResetExpiredTime();
        bool interrupt = false;
        bool isExt = mMeta == null || mMeta.hasExtAsset;
        string exName = mName + AssetManager.BUNDLE_EXTENSION;
        string exPath = AssetManager.resPath;
        string path;

        //外部存储加载
        if(isExt && !mBundle)
        {
            // 加载外部包
            path = Path.Combine(exPath, exName);
            mSize = (int)File.Length(path);
            if (mSize > 0)
            {
                if (mSize <= aysncDownSize)//立即加载
                {
                    try
                    {
                        mBundle = AssetBundle.LoadFromMemory(File.ReadFile(path));
                    }
                    catch
                    {
                        mBundle = null;
                    }
                }
                if (!mBundle) //异步加载
                {
                    if (mWWW != null) mWWW.Dispose();
                    mWWW = new WWW("file:///" + path);
                    //Debug.Log("asset ext load =" + mWWW.url);
                    while (!mWWW.isDone) yield return null;
                    if (!mBundle)
                    {
                        if (string.IsNullOrEmpty(mWWW.error))
                        {
                            mSize = mWWW.bytesDownloaded;
                            mBundle = mWWW.assetBundle;
                            if (mBundle == null) mBundle = AssetManager.FindAssetBundle(mName);
                            if (mBundle == null) { File.Delete(path); interrupt = true; }
                        }
                        else
                        {
                            Debug.Log(mWWW.error);
                            if (!mWWW.IsBadFileLength()) interrupt = true;
                        }
                    }
                }

                //if (interrupt) { Done(true); yield break; }
            }
#if TEST
            WriteDebugInfo(3);
#endif
            // 加载内部流
            if (!mBundle)
            {
#if UNITY_ANDROID && !UNITY_EDITOR
                mSize = ENV.GetAssetsDataLength(exName);
#else
                path = Path.Combine(AssetManager.streamPath, exName);
                mSize = (int)File.Length(path);
#endif
                if (mSize > 0)
                {
                    if (mSize <= aysncDownSize)//立即加载
                    {
                        try
                        {
#if UNITY_ANDROID && !UNITY_EDITOR
                            mBundle = AssetBundle.LoadFromMemory(ENV.GetAssetsData(exName));
#else
                            mBundle = AssetBundle.LoadFromMemory(File.ReadFile(path));
#endif
                        }
                        catch
                        {
                            mBundle = null;
                        }
                    }
                    if (!mBundle)//异步加载
                    {
                        if (mWWW != null) mWWW.Dispose();
#if UNITY_ANDROID && !UNITY_EDITOR
                        mWWW = new WWW(Path.Combine(AssetManager.streamPath, exName));
#else
                        mWWW = new WWW("file:///" + path);
#endif
                        Debug.Log("asset stream load =" + mWWW.url);
                        while (!mWWW.isDone) yield return null;
                        if (!mBundle)
                        {
                            if (string.IsNullOrEmpty(mWWW.error))
                            {
                                mSize = mWWW.bytesDownloaded;
                                mBundle = mWWW.assetBundle;
                                if (mBundle == null) mBundle = AssetManager.FindAssetBundle(mName);
                                if (mBundle == null) interrupt = true;
                            }
                            else
                            {
                                Debug.Log(mWWW.error);
                                interrupt = true;
                            }
                        }
                    }

                    //if (interrupt) { Done(true); yield break; }
                }
            }
#if TEST
            WriteDebugInfo(4);
#endif
        }

        if (mRes) { Done(); yield break; }//防止立即加载的冲突

#if TEST
        WriteDebugInfo(5);
#endif

        //加载包内资源
        if (mBundle)
        {
            mBundle.name = mName;
            if (hasRefer)
            {
                if (mSize > aysncDownSize)//异步加载
                {
                    AssetBundleRequest abr = mBundle.LoadAssetAsync<GameObject>(mName);
                    while (!abr.isDone) yield return null;
                    mRes = abr.asset;
                    if (!mRes)
                    {
                        abr = mBundle.LoadAssetAsync(mName);
                        while (!abr.isDone) yield return null;
                        mRes = abr.asset;
                    }
                }
                else//立即加载
                {
                    mRes = mBundle.LoadAsset<GameObject>(mName);
                    if (!mRes) mRes = mBundle.LoadAsset(mName);
                }
                if (mRes)
                {
                    Done(); yield break;
                }
                else
                {
                    interrupt = true;
                    mBundle.Unload(true);
                    mBundle = null;
                }
            }
            else
            {
                Done(true); yield break;
            }
        }
        else
        {
            mSize = 0;
        }

#if TEST
        WriteDebugInfo(6);
#endif
        if (isExt && AssetManager.hasWebAsset)
        {
#if TEST
            WriteDebugInfo(7);
#endif
            //网络加载
            path = Path.Combine(exPath, exName);
            string url = AssetManager.resUrl + exName;
            int resSize = 0;
            string[] iheader = new string[2] { "Range", "bytes=0-0" };
            WWW www = new WWW(Url.Dynamic(url));
            www.InitWWW(www.url, null, iheader);
            while (!www.isDone) yield return null;
            if (string.IsNullOrEmpty(www.error))
            {
                string str = "";
                www.responseHeaders.TryGetValue("CONTENT-RANGE", out str);
                int lenIndex = str.LastIndexOf('/');
                if (lenIndex >= 0)
                {
                    str = str.Substring(lenIndex + 1);
                    int.TryParse(str, out resSize);
                }
            }
            else if (!www.Is404NotFound())
            {
                interrupt = true;
#if TEST
                Debug.Log("get [" + www.url + "] is not found!");
            }
            else
            {
                Debug.LogWarning("get [" + www.url + "] error:" + www.error);
            }
#else
        }
#endif
            www.Dispose();

#if TEST
            WriteDebugInfo(8);
#endif

            ResetExpiredTime();

            if (resSize < quickDownSize)//小文件直接下载
            {
                if (mWWW != null) mWWW.Dispose();
                mWWW = new WWW(Url.Dynamic(url));
                while (!mWWW.isDone) { mPercent = Mathf.Max(mPercent, mWWW.progress); yield return null; }
                if (string.IsNullOrEmpty(mWWW.error))
                {
                    mSize = mWWW.bytesDownloaded;
                    mBundle = mWWW.assetBundle;
                    if (mBundle) File.WriteFile(path, mWWW.bytes);
                    else
                    {
                        if (mBundle == null) mBundle = AssetManager.FindAssetBundle(mName);
                        if (mBundle == null) { File.Delete(path); interrupt = true; }
                    }
                }
                else if (!mWWW.Is404NotFound())
                {
                    interrupt = true;
#if TEST
                    Debug.Log("download [" + mWWW.url + "] is not found!");
                }
                else
                {
                    Debug.LogWarning("download [" + mWWW.url + "] error:" + mWWW.error);
                }
#else
                }
#endif
                //if (!interrupt) { Done(true); yield break; }

#if TEST
                WriteDebugInfo(9);
#endif
            }
            else//大文件分块下载
            {
#if TEST
                WriteDebugInfo(10);
#endif
                FileStream fileStream = null;
                int index = 0;
                if (File.Exists(path))
                {
                    try
                    {
                        fileStream = File.OpenWrite(path);
                        index = (int)fileStream.Length;
                        fileStream.Seek(index); //移动文件流中的当前指针
                    }
                    catch (System.Exception e)
                    {
                        Debug.Log(e);
                        if (fileStream != null)
                        {
                            fileStream.Dispose();
                            fileStream = null;
                        }
                    }
                }
                if (fileStream == null)
                {
                    index = 0;
                    fileStream = new FileStream(path, FileMode.Create);
                }
                Debug.Log(string.Format("big res load current {0}/{1} ", index, resSize));
                if (index < resSize)
                {
                    mPercent = (float)index / (float)resSize;

                    if (AssetManager.isDataNet && resSize - index > quickDownSize)//等待同意
                    {
                        if (mDataNetPerm == 0 && requestDataNetPerm != null)
                        {
                            requestDataNetPerm(this);
                            while (mDataNetPerm == 0) yield return null;
                        }
                        if (mDataNetPerm == 2)
                        {
                            interrupt = true;
                        }
                    }

                    while (!interrupt)
                    {
                        int temp = 0;
                        if (index < 1)
                        {
                            index = temp = 0;
                        }
                        else
                        {
                            temp = Mathf.Min(index + dataBlockSize, resSize - 1);
                        }
                        Debug.Log(string.Format("big res loading bytes={0}-{1}", index, temp));
                        iheader[1] = string.Format("bytes={0}-{1}", index, temp);
                        temp -= index;
                        www.InitWWW(Url.Dynamic(url), null, iheader);
                        while (!www.isDone) { mPercent = Mathf.Max(mPercent, (www.progress * temp + index) / resSize); yield return null; }
                        ResetExpiredTime();
                        if (string.IsNullOrEmpty(www.error))
                        {
                            if (www.bytes != null)
                            {
                                try
                                {
                                    fileStream.Write(www.bytes, 0, www.bytes.Length);
                                    index += www.bytes.Length;
                                }
                                catch (System.Exception e)
                                {
                                    interrupt = true;
                                    Debug.Log(e);
                                    break;
                                }
                                if (index >= resSize)
                                {
                                    mPercent = 1f;
                                    break;
                                }
                            }
                            else
                            {
                                break;
                            }
                        }
                        else
                        {
                            interrupt = true;
                            Debug.Log(www.error);
                            break;
                        }
                    }
                    www.Dispose(); www = null;
                }

                fileStream.Dispose();

                if (File.Exists(path))
                {
                    if (mWWW != null) mWWW.Dispose();
                    mWWW = new WWW("file://" + WWW.EscapeURL(path));
                    while (!mWWW.isDone) yield return null;
                    if (!mBundle)
                    {
                        if (string.IsNullOrEmpty(mWWW.error))
                        {
                            mSize = mWWW.bytesDownloaded;
                            mBundle = mWWW.assetBundle;
                            if (mBundle == null) mBundle = AssetManager.FindAssetBundle(mName);
                            if (mBundle == null) { File.Delete(path); interrupt = true; }
                        }
                        else
                        {
                            Debug.Log(mWWW.error);
                            Debug.Log(mWWW.url);
                            if (mWWW.IsBadFileLength())
                            {
                                File.Delete(path);
                                interrupt = true;
                            }
                        }
                    }
                }
            }
#if TEST
            WriteDebugInfo(11);
#endif
            //分配资源
            if (mBundle)
            {
                mBundle.name = mName;
                if (hasRefer)
                {
                    if (mSize > aysncDownSize)
                    {
                        AssetBundleRequest abr = mBundle.LoadAssetAsync<GameObject>(mName);
                        while (!abr.isDone) yield return null;
                        mRes = abr.asset;
                        if (!mRes)
                        {
                            abr = mBundle.LoadAssetAsync(mName);
                            while (!abr.isDone) yield return null;
                            mRes = abr.asset;
                        }
                    }
                    else
                    {
                        mRes = mBundle.LoadAsset<GameObject>(mName);
                        if (!mRes) mRes = mBundle.LoadAsset(mName);
                    }
                    if (!mRes)
                    {
                        mBundle.Unload(true);
                        mBundle = null;
                        interrupt = true;
                    }
                }
                else
                {
                    interrupt = true;
                }
            }
            else
            {
                mSize = 0;
            }
        }

        if (!mRes)
        {
#if TEST
            WriteDebugInfo(12);
#endif
            //内部加载
            if (mMeta != null && mMeta.needAsyncLoad)
            {
                ResourceRequest rr = Resources.LoadAsync(AssetManager.GetPathFromAsset(this), typeof(Object));
                while (!rr.isDone) yield return null;
                mRes = rr.asset;
                if (!mRes)
                {
                    rr = Resources.LoadAsync(mName, typeof(Object));
                    while (!rr.isDone) yield return null;
                    mRes = rr.asset;
                }
            }
            else
            {
                mRes = Resources.Load(AssetManager.GetPathFromAsset(this));
                if (!mRes) mRes = Resources.Load(mName);
            }

            if (mRes) { Done(); yield break; }
        }

#if TEST
        WriteDebugInfo(13);
#endif
        Done(interrupt);
    }

    private void Done(bool interrupt = false)
    {
        if (isDone) return;

#if TEST
        if (!string.IsNullOrEmpty(debugInfo))
        {
            Debug.Log(debugInfo);
            debugInfo = string.Empty;
        }
#endif

        if (interrupt)
        {
            mStatus = 3;
        }
        else if (!isTimeOut)
        {
            mStatus = 2;
        }

        mDataNetPerm = 0;
        mLoadCoroutine = null;

        if (mRes)
        {
            mPercent = 1f;
            int resSize = AssetManager.GetResSize(res);
            if (mBundle && resSize < mSize * 2) mSize *= 3;
            else mSize += resSize;

            if (mRes is GameObject) AssetStripper.RestoreGo(mRes as GameObject);
        }

        AssetManager.OnAssetLoaded(this);

        if (hasLoader)
        {
            for (int i = mLoaders.Count - 1; i >= 0; i--)
            {
                if (mLoaders[i] && mLoaders[i].Contains(this)) mLoaders[i].OnAssetComplete(this);
                else mLoaders.RemoveAt(i);
            }
        }
        if (hasCallback)
        {
            for (int i = 0; i < mCallback.Count; i++)
            {
                if (mCallback[i].IsAvailable()) mCallback[i](this);
            }
            mCallback.Clear();
        }
    }

    private void ResetExpiredTime() { mExpiredTime = Time.realtimeSinceStartup + AssetManager.TIME_OUT; }

    public void InterruptRecovery()
    {
        if (mStatus == 3 || isTimeOut)
        {
            mStatus = 0;
            mDataNetPerm = 0;
            mLoadCoroutine = null;
        }
    }

    public void SetDataNetPerm(bool refuse = false)
    {
        if (refuse) mDataNetPerm = 2;
        mDataNetPerm = 1;
    }

    public void Dispose(bool force = false)
    {
        if (mStatus == 1 || mWeight == byte.MaxValue) return;

        if (hasCallback) mCallback.Clear();

        if (hasLoader)
        {
            for (int i = mLoaders.Count - 1; i >= 0; i--)
            {
                if (mLoaders[i] && mLoaders[i].Contains(this)) continue;
                mLoaders.RemoveAt(i);
            }
        }

        if (!force && hasLoader) return;

        if (mBundle)
        {
            mBundle.Unload(true);
            mBundle = null;
        }
        else if(mRes)
        {
            AssetManager.UnLoadObject(mRes);
            mRes = null;
        }
        if (mWWW != null)
        {
            mWWW.Dispose();
            mWWW = null;
        }

        AssetManager.OnAssetDispose(this);

        mPercent = 0f;
        mStatus = 3;
        mSize = 0;
        mDataNetPerm = 0;
        mLoadCoroutine = null;
    }

    public void AddLoader(AssetLoader loader)
    {
        if (loader)
        {
            if (!loader.Contains(this))
            {
                loader.OnAssetAdd(this);
                if (!loader.Contains(this)) return;
            }
            if (mLoaders == null) mLoaders = new List<AssetLoader>(4);
            else if (mLoaders.Contains(loader)) return;
            mLoaders.Add(loader);
            if (isDone) loader.OnAssetComplete(this);
            mUseCount++;
        }
    }

    public void RemoveLoader(AssetLoader loader)
    {
        if (mLoaders != null && loader) mLoaders.Remove(loader);
    }

    public void AddCallback(AssetRequest request)
    {
        if(request!=null)
        {
            if (mCallback == null) mCallback = new List<AssetRequest>(1);
            else if (mCallback.Contains(request)) return;
            mCallback.Add(request);
            mUseCount++;
        }
    }
    public Object GetAsset(string typeName) { return GetAsset(System.Type.GetType(typeName)); }
    public Object GetAsset(string assetName, string typeName) { return GetAsset(assetName, System.Type.GetType(typeName)); }
    public Object GetAsset(System.Type type)
    {
        if (mRes != null && (mRes.GetType() == type || mRes.GetType().IsSubclassOf(type)))
        {
            return mRes;
        }
        if (mRes is GameObject && type.IsSubclassOf(typeof(Component)))
        {
            return prefab.GetComponent(type);
        }
        if (mBundle)
        {
            return mBundle.LoadAsset(mName, type);
        }
        else
        {
            Object res = Resources.Load(AssetManager.GetPathFromAsset(this), type);
            if (!res) res = Resources.Load(mName, type);
            if (res)
            {
                if (!mRes || res is GameObject || res is Component) mRes = res;
                return res;
            }
        }
        return null;
    }
#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public T GetAsset<T>() where T : Object
    {
        if (mRes is T)
        {
            return mRes as T;
        }
        if (mRes is GameObject && typeof(T).IsSubclassOf(typeof(Component)))
        {
            return prefab.GetComponent<T>();
        }
        if(mBundle)
        {
            return mBundle.LoadAsset<T>(mName);
        }
        else
        {
            T res = Resources.Load<T>(AssetManager.GetPathFromAsset(this));
            if (!res) res = Resources.Load<T>(mName);
            if (res)
            {
                if (!mRes || res is GameObject || res is Component) mRes = res;
                return res;
            }
        }
        return null;
    }
    public Object GetAsset(string assetName, System.Type type)
    {
        if (assetName == mName || string .IsNullOrEmpty(assetName))
        {
            return GetAsset(type);
        }
        if (mBundle)
        {
            Object res = mBundle.LoadAsset(assetName, type);
            if (res is GameObject) AssetStripper.RestoreGo(res as GameObject);
            return res;
        }
        return null;
    }
#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public T GetAsset<T>(string assetName) where T : Object
    {
        if (assetName == mName || string.IsNullOrEmpty(assetName))
        {
            return GetAsset<T>();
        }
        if (mBundle)
        {
            T res = mBundle.LoadAsset<T>(assetName);
            if (res is GameObject) AssetStripper.RestoreGo(res as GameObject);
            return res;
        }
        return null;
    }

    public string name { get { return mName; } }
    public AssetMeta meta { get { return mMeta; } }
    public bool isExternal { get { return mMeta == null || mMeta.hasExtAsset; } }
    public float process { get { return Mathf.Clamp01(mPercent); } }
    public bool isDone { get { return mStatus == 2 || isInterrupt || isTimeOut; } }
    public bool isInterrupt { get { return mStatus == 3; } }
    public bool isTimeOut { get { return mStatus == 1 && Time.realtimeSinceStartup > mExpiredTime; } }
    public bool isInvalid { get { return mStatus == 2 && !mBundle && !mRes; } }
    public int size { get { return mMeta == null ? mSize : mMeta.size; } }
    public int useCount { get { return mUseCount; } }
    public string processMessage { get { return string.Empty; } }
    private bool hasLoader { get { return mLoaders != null && mLoaders.Count > 0; } }
    private bool hasCallback { get { return mCallback != null && mCallback.Count > 0; } }
    private bool hasRefer { get { return hasLoader || hasCallback; } }
    public byte weight { get { return mWeight; } set { mWeight = value; } }

    public GameObject prefab { get { return GetAsset<GameObject>(); } }
    public Texture texture { get { return GetAsset<Texture>(); } }
    public Material material { get { return GetAsset<Material>(); } }
    public AudioClip audio { get { return GetAsset<AudioClip>(); } }
    public TextAsset text { get { return GetAsset<TextAsset>(); } }
    public Object res { get { return mRes; } }
}
