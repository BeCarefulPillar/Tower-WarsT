//Assets Manager Copyright © 何权

#if UNITY_EDITOR
using UnityEditor;
#if TOLUA
using LuaInterface;
#endif
#endif
using UnityEngine;
using System.Collections.Generic;
using Kiol.IO;
using Kiol.Json;

public class AssetManager : CoreModule
{
    #region 字段，属性
    /// <summary>
    /// AssetBundle的扩展名
    /// </summary>
    public const string BUNDLE_EXTENSION = ".unity3d";
    /// <summary>
    /// 数据扩展名
    /// </summary>
    public const string DAT_EXTENSION = ".dat";
    /// <summary>
    /// 自动卸载的最小时间间隔
    /// </summary>
    private const int AUTO_UNLOAD_MIN_DELTA_TIME = 15;
    /// <summary>
    /// 资源请求的超时时间
    /// </summary>
    public static int TIME_OUT = 15;
    /// <summary>
    /// 单例
    /// </summary>
    private static AssetManager _Instance;
    /// <summary>
    /// 最大并行加载的数量
    /// </summary>
    private static int _maxParallelCount = 16;
    
    private static string _rootPath;
    private static string _userPath;
    private static string _userRecPath;
    private static string _svrPath;
    private static string _datPath;
    private static string _luaPath;
    private static string _resPath;
    private static string _streamPath;
    private static string _voicePath;
    private static string _tempPath;

    private static string _rootUrl;
    private static string _svrUrl;
    private static string _luaUrl;
    private static string _datUrl;
    private static string _resUrl;

    /// <summary>
    /// 游戏是否在后台
    /// </summary>
    private static bool _isBackground = false;
    /// <summary>
    /// 资源总大小
    /// </summary>
    private static int _assetSize = -1;
    /// <summary>
    /// 资源可用的内存大小
    /// </summary>
    private static int assetSizeLimit = 53687091;
    /// <summary>
    /// 资源自动卸载的阈值
    /// </summary>
    private static int assetAutoUnloadLimit = 53687091;
    /// <summary>
    /// 下次可自动卸载的时间
    /// </summary>
    private static float nextAutoUnloadTime = 0f;
    /// <summary>
    /// 下次卸载未用资源的时间
    /// </summary>
    private static float nextResourcesUnloadTime = 0f;
    /// <summary>
    /// 下次获取内存的时间
    /// </summary>
    private static float nextGetMemTime = 0f;
    /// <summary>
    /// 获取内存的时间间隔
    /// </summary>
    private static float getMemTimeDelta = 60f;
    /// <summary>
    /// 上次获取的可用内存
    /// </summary>
    private static int lastAvlMem = 0;

    /// <summary>
    /// 包内路径
    /// </summary>
    private static string[] _inPaths;
    /// <summary>
    /// 资源元数据
    /// </summary>
    private static Dictionary<string, AssetMeta> _assetMetas = new Dictionary<string, AssetMeta>(4096);
    /// <summary>
    /// 权重设置缓存
    /// </summary>
    private static Dictionary<string, byte> _weightBuffer = new Dictionary<string, byte>(8);
    /// <summary>
    /// 资源库
    /// </summary>
    private static Dictionary<string, Asset> _assetDic = new Dictionary<string, Asset>(64);
    /// <summary>
    /// 并行下载列表
    /// </summary>
    private static List<Asset> _assetList = new List<Asset>(8);
    /// <summary>
    /// 串行下载队列
    /// </summary>
    private static Queue<Asset> _assetQueue = new Queue<Asset>(8);
    /// <summary>
    /// 当前正在加载资源
    /// </summary>
    private static Asset _curLoadAsset;
    /// <summary>
    /// 清理等级(小于0不清理 0=保留清理 1-100清理比率 大于100完全清理)
    /// </summary>
    private static int _unloadLevel = -1;
    /// <summary>
    /// 默认纹理
    /// </summary>
    private static Texture2D _defaultTexture;
    /// <summary>
    /// 默认头像
    /// </summary>
    private static Texture2D _defaultAvatar;
    /// <summary>
    /// 加载中动画纹理
    /// </summary>
    private static Texture2D _loadingTexture;
    /// <summary>
    /// 通用着色器
    /// </summary>
    private static Shader _commonShader;
    /// <summary>
    /// 主图集
    /// </summary>
    private static UIAtlas _mainAtlas;
    /// <summary>
    /// 主字体
    /// </summary>
    private static Font _mainFont;

    /// <summary>
    /// 静态初始化
    /// </summary>
    public static void Init()
    {
        _streamPath = Application.streamingAssetsPath;
        _rootPath = Application.persistentDataPath;

        _userPath = _rootPath + "/usr/";
        _userRecPath = _rootPath + "/ur";
        _svrPath = _rootPath + "/svr";
        //_datPath = _rootPath + "/dat/";
        _datPath = LuaConst.luaResDir;
        _luaPath = _rootPath + "/crc/";
        _tempPath = _rootPath + "/tmp/";

#if RES_CACHE
        _resPath = Application.temporaryCachePath + "/res/";
#else
        _resPath = _rootPath + "/res/";
#endif
        _voicePath = Application.temporaryCachePath + "/voice/";

        if (!Directory.Exists(_userPath)) Directory.CreateDirectory(_userPath);
        if (!Directory.Exists(_datPath)) Directory.CreateDirectory(_datPath);
        if (!Directory.Exists(_luaPath)) Directory.CreateDirectory(_luaPath);
        if (!Directory.Exists(_tempPath)) Directory.CreateDirectory(_tempPath);
        if (!Directory.Exists(_resPath)) Directory.CreateDirectory(_resPath);
        if (!Directory.Exists(_voicePath)) Directory.CreateDirectory(_voicePath);

//#if UNITY_ANDROID
//        if (!File.Exists(_resPath + ".nomedia")) File.Create(_resPath + ".nomedia").Dispose();
//#endif
        // 最大并行下载数
        _maxParallelCount = SystemInfo.systemMemorySize > 1024 ? 16 : 8;

        // 计算内存使用限制
        CalculateMemoryLimt();

        // 加载资源树
        LoadAssetTree();

        // 初始对象
        Instance(ref _Instance);
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    /// <summary>
    /// 从json数据配置url
    /// </summary>
    public static void ApplyUrl(string rootUrl, JsonObject update)
    {
        _rootUrl = rootUrl;
        _svrUrl = _rootUrl + "server.dat";
        _luaUrl = _rootUrl + "lua/";
        _datUrl = _rootUrl + "dat/";
#if UNITY_ANDROID
        _resUrl = _rootUrl + "res/adr/";
#elif UNITY_IPHONE
        _resUrl = _rootUrl + "res/ios/";
#else
        _resUrl = _rootUrl + "res/def/";
#endif
        if (update == null) return;

        string val = update.GetValueByPath("svr", "p");
        _svrUrl = _rootUrl + (string.IsNullOrEmpty(val) ? "server.dat" : val);
        val = update.GetValueByPath("lua", "p");
        _luaUrl = _rootUrl + (string.IsNullOrEmpty(val) ? "" : val);
        if (!string.IsNullOrEmpty(val)) _luaUrl = _rootUrl + val;
        val = update.GetValueByPath("dat", "p");
        if (!string.IsNullOrEmpty(val)) _datUrl = _rootUrl + val;
        JsonObject jo = update.GetChild("res");
        if (jo == null) return;
        val = jo.GetChildValue("p");
        if (!string.IsNullOrEmpty(val)) _resUrl = _rootUrl + val;
        val = jo.GetChildValue("ads");
        if (!string.IsNullOrEmpty(val)) int.TryParse(val, out Asset.aysncDownSize);
        val = jo.GetChildValue("qds");
        if (!string.IsNullOrEmpty(val)) int.TryParse(val, out Asset.quickDownSize);
        val = jo.GetChildValue("dbs");
        if (!string.IsNullOrEmpty(val)) int.TryParse(val, out Asset.dataBlockSize);
    }
    /// <summary>
    /// 加载资源树
    /// </summary>
    public static void LoadAssetTree()
    {
        Asset asset = AssetManager.GetAsset(AssetName.RES_TREE);
        if (asset != null) asset.Dispose(true);
        AssetTree tree = AssetManager.Load<AssetTree>(AssetName.RES_TREE);
        if (tree)
        {
            // 内部路径
            _inPaths = tree.paths;
            // 默认资源
            _defaultTexture = tree.defaultTexture;
            _defaultAvatar = tree.defaultAvatar;
            _loadingTexture = tree.loadingTexture;
            _mainAtlas = tree.mainAtlas;
            _mainFont = tree.mainFont;
            _commonShader = tree.commonShader;
            // 清理旧元数据
            HashSet<string> removeMeta = new HashSet<string>();
            if (_assetMetas.Count > 0)
            {
                foreach (AssetMeta item in _assetMetas.Values)
                {
                    if (item.hasExtAsset)
                    {
                        item.path = -1;
                        item.needAsyncLoad = false;
                    }
                    else
                    {
                        removeMeta.Add(item.name);
                    }
                }
            }
            // 载入元数据
            AssetMeta am;
            foreach (AssetMeta item in tree.assetList)
            {
                if (item == null || string.IsNullOrEmpty(item.name)) continue;
                if (removeMeta.Count > 0) removeMeta.Remove(item.name);
                if (_assetMetas.TryGetValue(item.name, out am) && am != null)
                {
                    am.path = item.path;
                    am.size = item.size;
                    am.needAsyncLoad = item.needAsyncLoad;
                }
                else
                {
                    _assetMetas[item.name] = item;
                }
            }
            // 移除不存在的元数据
            if (removeMeta.Count > 0) foreach (string item in removeMeta) _assetMetas.Remove(item);
            // 卸载加载的资源
            AssetManager.UnLoadAsset(AssetName.RES_TREE, true);
        }
    }

    /// <summary>
    /// 流数据路径
    /// </summary>
    public static string streamPath { get { return _streamPath; } }
    /// <summary>
    /// 数据保存路径
    /// </summary>
    public static string rootPath { get { return _rootPath; } }
    /// <summary>
    /// 用户存档路径
    /// </summary>
    public static string userPath { get { return _userPath; } }
    /// <summary>
    /// 本地存储的用户登陆记录列表路径
    /// </summary>
    public static string userRecPath { get { return _userRecPath; } }
    /// <summary>
    /// 服务器列表保存路径
    /// </summary>
    public static string svrPath { get { return _svrPath; } }
    /// <summary>
    /// 游戏数据保存路径
    /// </summary>
    public static string datPath { get { return _datPath; } }
    /// <summary>
    /// lua脚本保存路径
    /// </summary>
    public static string luaPath { get { return _luaPath; } }
    /// <summary>
    /// 临时路径
    /// </summary>
    public static string tempPath { get { return _tempPath; } }
    /// <summary>
    ///资源保存路径
    /// </summary>
    public static string resPath { get { return _resPath; } }
    /// <summary>
    /// 云娃语音路径
    /// </summary>
    public static string voicePath { get { return _voicePath; } }
    /// <summary>
    /// LUA地址
    /// </summary>
    public static string rootUrl { get { return _rootUrl; } }
    /// <summary>
    /// LUA地址
    /// </summary>
    public static string svrUrl { get { return _svrUrl; } }
    /// <summary>
    /// LUA地址
    /// </summary>
    public static string luaUrl { get { return _luaUrl; } }
    /// <summary>
    /// 游戏数据地址
    /// </summary>
    public static string datUrl { get { return _datUrl; } }
    /// <summary>
    /// 资源包地址
    /// </summary>
    public static string resUrl { get { return _resUrl; } }
    /// <summary>
    /// 是否有网络资源可用
    /// </summary>
    public static bool hasWebAsset { get { return !string.IsNullOrEmpty(_rootUrl); } }
    /// <summary>
    /// 是否是数据网
    /// </summary>
    public static bool isDataNet { get { return Application.internetReachability == NetworkReachability.ReachableViaCarrierDataNetwork; } }
    /// <summary>
    /// 默认的问号纹理
    /// </summary>
    public static Texture2D defaultTexture { get { return _defaultTexture; } }
    /// <summary>
    /// 默认头像
    /// </summary>
    public static Texture2D defaultAvatar { get { return _defaultAvatar; } }
    /// <summary>
    /// 加载中动画纹理
    /// </summary>
    public static Texture2D loadingTexture { get { return _loadingTexture; } }
    /// <summary>
    /// 通用着色器
    /// </summary>
    public static Shader commonShader { get { return _commonShader; } }
    /// <summary>
    /// 默认主图集
    /// </summary>
    public static UIAtlas mainAtlas { get { return _mainAtlas; } }
    /// <summary>
    /// 默认主字体
    /// </summary>
    public static Font mainFont { get { return _mainFont; } }
    /// <summary>
    /// 默认的加载回调
    /// </summary>
    public static readonly Asset.AssetRequest defaultCallback = asset => { };

    public static int systemAvailableMemory
    {
        get
        {
            int ret = ENV.GetSystemAvailableMemory();
#if !TEST && !UNITY_EDITOR
            Debug.Log("get sys avl memory = " + ret);
#endif
            return ret;
        }
    }
    #endregion

    /// <summary>
    /// 加载一个资源
    /// </summary>
    /// <param name="assetName">资源名称</param>
    public static Asset LoadAsset(string assetName) { return LoadAsset(assetName, null); }
    /// <summary>
    /// 加载一个资源
    /// </summary>
    /// <param name="assetName">资源名称</param>
    public static Asset LoadAsset(string assetName, AssetLoader loader)
    {
        Asset asset = CreateAsset(assetName);
        if (loader) asset.AddLoader(loader);
        asset.LoadImmediate();
        return asset;
    }
    /// <summary>
    /// 异步加载资源，加载器侦听（非并行）
    /// </summary>
    /// <param name="assetName">资源名称</param>
    /// <param name="loader">加载器</param>
    public static Asset LoadAssetAsync(string assetName, AssetLoader loader) { return LoadAssetAsync(assetName, loader, false); }
    /// <summary>
    /// 异步加载资源，加载器侦听
    /// </summary>
    /// <param name="assetName">资源名称</param>
    /// <param name="loader">加载器</param>
    /// <param name="isParallel">是否并行下载</param>
    public static Asset LoadAssetAsync(string assetName, AssetLoader loader, bool isParallel)
    {
        Asset asset = LoadAssetAsync(assetName, isParallel);
        if (loader) asset.AddLoader(loader);
        return asset;
    }
    /// <summary>
    /// 异步加载资源，回调侦听（非并行）
    /// </summary>
    /// <param name="assetName">资源名称</param>
    /// <param name="loader">加载回调</param>
    public static Asset LoadAssetAsync(string assetName, Asset.AssetRequest callback) { return LoadAssetAsync(assetName, callback, false); }
    /// <summary>
    /// 异步加载资源，回调侦听
    /// </summary>
    /// <param name="assetName">资源名称</param>
    /// <param name="loader">加载回调</param>
    /// <param name="isParallel">是否并行下载</param>
    public static Asset LoadAssetAsync(string assetName, Asset.AssetRequest callback, bool isParallel)
    {
        Asset asset = LoadAssetAsync(assetName, isParallel);
        if (callback != null) asset.AddCallback(callback);
        return asset;
    }
    /// <summary>
    /// 异步加载资源
    /// </summary>
    /// <param name="assetName">资源名称</param>
    /// <param name="isParallel">是否并行下载</param>
    /// <returns></returns>
    public static Asset LoadAssetAsync(string assetName, bool isParallel)
    {
        Asset asset = CreateAsset(assetName);
        if (asset.isDone || _curLoadAsset == asset || _assetList.Contains(asset))
        {
            return asset;
        }
        if (isParallel)
        {
            _assetList.Add(asset);
        }
        else if (!_assetQueue.Contains(asset))
        {
            _assetQueue.Enqueue(asset);
        }
        return asset;
    }

    /// <summary>
    /// 创建资源
    /// </summary>
    /// <param name="assetName">资源名称</param>
    private static Asset CreateAsset(string assetName)
    {
        Asset asset = null;
        _assetDic.TryGetValue(assetName, out asset);
        if (asset == null)
        {
            AssetMeta am = GetAssetMeta(assetName);
            asset = _assetDic[assetName] = am == null ? new Asset(assetName) : new Asset(am);
            byte weight = 128;
            if(_weightBuffer.TryGetValue(assetName, out weight))
            {
                asset.weight = weight;
                _weightBuffer.Remove(assetName);
            }
        }
        else
        {
            asset.InterruptRecovery();
        }
        return asset;
    }
    /// <summary>
    /// 获取资源
    /// </summary>
    /// <param name="assetName">资源名称</param>
    public static Asset GetAsset(string assetName)
    {
        Asset asset = null;
        _assetDic.TryGetValue(assetName, out asset);
        return asset;
    }
    /// <summary>
    /// 获取资源元数据
    /// </summary>
    /// <param name="assetName">资源名称</param>
    public static AssetMeta GetAssetMeta(string assetName)
    {
        AssetMeta am;
        _assetMetas.TryGetValue(assetName, out am);
        return am;
    }
    /// <summary>
    /// 查找丢失的资源包
    /// </summary>
    /// <param name="assetName">资源包名称</param>
    public static AssetBundle FindAssetBundle(string assetName)
    {
        AssetBundle[] bundles = Resources.FindObjectsOfTypeAll<AssetBundle>();
        if (bundles.GetLength() > 0)
        {
            for (int i = 0; i < bundles.Length; i++)
            {
                if (bundles[i].name == assetName) return bundles[i];
                Object asset = bundles[i].mainAsset;
                if (asset && asset.name == assetName)
                {
                    bundles[i].name = assetName;
                    return bundles[i];
                }
            }
        }
        return null;
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    /// <summary>
    /// 有资源加载完成
    /// </summary>
    public static void OnAssetLoaded(Asset asset)
    {
        if (asset == null) return;
        if (_assetSize < 0) AssetManager.RecalculateAssetSize();
        else _assetSize += asset.size;
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    /// <summary>
    /// 有资源被卸载
    /// </summary>
    public static void OnAssetDispose(Asset asset)
    {
        if (asset == null || _assetSize < 0) return;
        _assetSize -= asset.size;
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    /// <summary>
    /// 计算资源可用内存极限
    /// </summary>
    private static void CalculateMemoryLimt()
    {
        if (Time.realtimeSinceStartup > nextGetMemTime)
        {
            int avlMem = systemAvailableMemory;
            if (lastAvlMem > avlMem)
            {
                getMemTimeDelta = Mathf.Clamp(getMemTimeDelta + (lastAvlMem > avlMem ? -5f : 5), 5f, 60f);
                lastAvlMem = avlMem;
            }
            nextGetMemTime = Time.realtimeSinceStartup + getMemTimeDelta;
            //assetSizeLimit = (int)(SystemInfo.systemMemorySize * 52428.8f);
            assetSizeLimit = Mathf.Clamp(Mathf.Min((int)((avlMem - SystemInfo.systemMemorySize * 251658) * 0.5f), SystemInfo.systemMemorySize * 32768), 16777216, 100663296);
            assetAutoUnloadLimit = (int)(assetSizeLimit * 1.2f);

            Debug.Log("Get New Assest Size Limit = " + assetSizeLimit);
        }
    }
    /// <summary>
    /// 重算资源总大小
    /// </summary>
    private static void RecalculateAssetSize()
    {
        _assetSize = 0;
        foreach (Asset asset in _assetDic.Values) _assetSize += asset.size;
    }
    /// <summary>
    /// 标记资源为弱引用，优先卸载
    /// </summary>
    /// <param name="assetName">资源名称</param>
    public static void SetAssetWeight(string assetName, byte weight)
    {
        Asset asset = null;
        if (_assetDic.TryGetValue(assetName, out asset))
        {
            asset.weight = weight;
        }
        else if (_weightBuffer.ContainsKey(assetName))
        {
            _weightBuffer[assetName] = weight;
        }
        else
        {
            _weightBuffer.Add(assetName, weight);
        }
    }
    
    #region 资源卸载接口
    /// <summary>
    /// 卸载一个资源(非强制)
    /// </summary>
    /// <param name="assetName">资源名称</param>
    public static void UnLoadAsset(string assetName) { UnLoadAsset(assetName, false); }
    /// <summary>
    /// 卸载一个资源
    /// </summary>
    /// <param name="assetName">资源名称</param>
    /// <param name="force">是否强制卸载</param>
    public static void UnLoadAsset(string assetName, bool force)
    {
        Asset asset = null;
        _assetDic.TryGetValue(assetName, out asset);
        if (asset != null) asset.Dispose(force);
    }
    /// <summary>
    /// 按等级清理资源
    /// </summary>
    public static void UnLoadAsset(int level)
    {
        Debug.Log("UnLoad Asset Level = " + level);
        Debug.Log("current assets size = " + _assetSize);
        if (level >= 80 && _isBackground)
        {
            UnloadAllAsset();
            AvatarLoader.Release(true);
        }
        else
        {
            if (level > 0)
            {
                if (_assetSize < 0) RecalculateAssetSize();

                int toSize = Mathf.RoundToInt(Mathf.Min(assetSizeLimit, _assetSize) * Mathf.Clamp01(1f - level * 0.01f));

                Asset[] assets = new Asset[_assetDic.Count];
                _assetDic.Values.CopyTo(assets, 0);
                System.Array.Sort(assets, (x, y) =>
                {
                    if (x.weight < y.weight) return -1;
                    if (x.weight > y.weight) return 1;
                    return x.useCount < y.useCount ? -1 : 1;
                });
                for (int i = 0; i < assets.Length && _assetSize > toSize; i++)
                {
                    assets[i].Dispose();
                }
            }
            else
            {
                foreach (Asset item in _assetDic.Values) if (item.weight < 128) item.Dispose();
            }

            Resources.UnloadUnusedAssets();
            RecalculateAssetSize();
            AvatarLoader.Release(false);

            nextResourcesUnloadTime = Time.realtimeSinceStartup + 5f;
        }
        Debug.Log("unload asset size = " + _assetSize);
    }
    /// <summary>
    /// 强制清理所有资源
    /// </summary>
    public static void UnloadAllAsset()
    {
        foreach (Asset asset in _assetDic.Values) asset.Dispose();
        Resources.UnloadUnusedAssets();
        nextResourcesUnloadTime = Time.realtimeSinceStartup + 5f;
        RecalculateAssetSize();
    }
    /// <summary>
    /// 卸载未用的资源
    /// </summary>
    public static void UnloadUnusedAsset()
    {
        _unloadLevel = 0;
    }
    /// <summary>
    /// 卸载纹理
    /// </summary>
    public static void UnLoadTexture(Texture texture)
    {
        if (texture == null) return;
        if (texture.GetInstanceID() > 0) Resources.UnloadAsset(texture);
        else UnityEngine.Object.Destroy(texture);
    }
    /// <summary>
    /// 卸载纹理
    /// </summary>
    public static void UnLoadTexture(params Texture[] texture)
    {
        if (texture != null) foreach (Texture tex in texture) AssetManager.UnLoadTexture(tex);
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    /// <summary>
    /// 卸载纹理
    /// </summary>
    public static void UnLoadTextures<T>(IEnumerable<T> enumerable) where T : Texture
    {
        if (enumerable != null) foreach (Texture tex in enumerable) AssetManager.UnLoadTexture(tex);
    }

    /// <summary>
    /// 卸载材质
    /// </summary>
    public static void UnLoadMaterial(Material material)
    {
        if (material == null) return;
        AssetManager.UnLoadTexture(material.mainTexture);
        if (material.GetInstanceID() > 0) Resources.UnloadAsset(material);
        else UnityEngine.Object.Destroy(material);
    }
    /// <summary>
    /// 卸载材质
    /// </summary>
    /// <param name="material">材质</param>
    public static void UnLoadMaterial(params Material[] material)
    {
        if (material != null) foreach (Material mat in material) AssetManager.UnLoadMaterial(mat);
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    /// <summary>
    /// 卸载材质
    /// </summary>
    public static void UnLoadMaterials(IEnumerable<Material> enumerable)
    {
        if (enumerable != null) foreach (Material mat in enumerable) AssetManager.UnLoadMaterial(mat); foreach (Material mat in enumerable) AssetManager.UnLoadMaterial(mat);
    }
    /// <summary>
    /// 卸载对象
    /// </summary>
    public static void UnLoadObject(UnityEngine.Object obj)
    {
        if (obj == null) return;
        if (obj is GameObject)
        {
            if (obj.GetInstanceID() < 0) UnityEngine.Object.Destroy(obj);
            return;
        }
        if (obj is AssetBundle)
        {
            (obj as AssetBundle).Unload(true);
            return;
        }
        if (obj is Material)
        {
            AssetManager.UnLoadMaterial(obj as Material);
            return;
        }
        else if (obj is Component)
        {
            if (obj.GetInstanceID() < 0) UnityEngine.Object.Destroy((obj as Component).gameObject);
            return;
        }

        if (obj.GetInstanceID() > 0) Resources.UnloadAsset(obj);
        else UnityEngine.Object.Destroy(obj);
    }
    /// <summary>
    /// 卸载对象
    /// </summary>
    public static void UnLoadObject(params UnityEngine.Object[] objects)
    {
        if (objects == null) return;
        foreach (UnityEngine.Object obj in objects) AssetManager.UnLoadObject(obj);
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    /// <summary>
    /// 卸载对象
    /// </summary>
    public static void UnLoadObjects<T>(IEnumerable<T> objs) where T : UnityEngine.Object
    {
        if (objs == null) return;
        foreach (UnityEngine.Object obj in objs) AssetManager.UnLoadObject(obj);
    }
    /// <summary>
    /// 删除本地缓存的资源数据
    /// </summary>
    /// <param name="assetName">资源名称</param>
    public static void DeleteLocalAsset(string assetName)
    {
        File.Delete(Path.Combine(AssetManager.resPath, assetName + BUNDLE_EXTENSION));
    }
    #endregion

    #region 资源通用加载
    /// <summary>
    /// 创建一个纹理
    /// </summary>
    /// <param name="width">纹理宽</param>
    /// <param name="height">纹理高</param>
    /// <param name="apply">是否Apply</param>
    /// <param name="format">纹理格式</param>
    /// <returns>纹理</returns>
    public static Texture2D CreatTexture(int width, int height, Color color, TextureFormat format = TextureFormat.RGBA32, bool apply = false)
    {
        Texture2D tex = CreatTexture(width, height, format);
        tex.name = "temp_texture";
        tex.hideFlags = HideFlags.HideAndDontSave;
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Trilinear;
        tex.anisoLevel = 4;
        Color[] cors = new Color[width * height];
        for (int i = 0; i < cors.Length; i++) cors[i] = color;
        tex.SetPixels(cors);
        if (apply) tex.Apply();
        return tex;
    }
    /// <summary>
    /// 创建一个纹理
    /// </summary>
    /// <param name="width">纹理宽</param>
    /// <param name="height">纹理高</param>
    /// <param name="format">纹理格式</param>
    /// <returns>纹理</returns>
    public static Texture2D CreatTexture(int width = 1, int height = 1, TextureFormat format = TextureFormat.RGBA32)
    {
        Texture2D tex = new Texture2D(width, height, format, false);
        tex.name = "temp_texture";
        tex.hideFlags = HideFlags.HideAndDontSave;
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Trilinear;
        tex.anisoLevel = 4;
        return tex;
    }
    /// <summary>
    /// 打包纹理
    /// </summary>
    /// <param name="texs">纹理</param>
    /// <param name="mat">输出的材质(Unlit/Transparent Colored)</param>
    /// <param name="unloadTexs">是否卸载打包纹理</param>
    /// <param name="padding">打包纹理间距</param>
    /// <param name="maxSize">最大输出纹理尺寸</param>
    /// <returns></returns>
    public static Rect[] PackTextures(Texture2D[] texs, out Material mat, bool unloadTexs = false, int padding = 1, int maxSize = 1024)
    {
        Texture2D merge = AssetManager.CreatTexture();
        merge.Apply();
        Rect[] rects = merge.PackTextures(texs, padding, maxSize, true);
        if (unloadTexs) AssetManager.UnLoadTexture(texs);
        merge.hideFlags = HideFlags.HideAndDontSave;
        merge.wrapMode = TextureWrapMode.Clamp;
        merge.filterMode = FilterMode.Trilinear;
        merge.anisoLevel = 4;
        mat = new Material(Shader.Find("Unlit/Transparent Colored"));
        mat.mainTexture = merge;
        return rects;
    }
    /// <summary>
    /// 创建一个图集
    /// </summary>
    /// <param name="texs">图集的纹理</param>
    /// <param name="trimAlpha">是否修剪透明边</param>
    /// <param name="unload">是否卸载原图</param>
    /// <returns>图集</returns>
    public static UIAtlas CreatAtlas(Texture2D[] texs, bool trimAlpha = false, bool unload = true)
    {
        if (texs == null) return null;
        int len = texs.Length;
        if (len <= 0) return null;

        Vector4[] pads = null;
        if (trimAlpha)
        {
            Texture2D[] temps = new Texture2D[len];
            pads = new Vector4[len];

            for (int i = 0; i < len; i++)
            {
                Texture2D oldTex = texs[i];
                Color32[] pixels = oldTex.GetPixels32();
                Vector4 pad = new Vector4(oldTex.width, 0, oldTex.height, 0);//x=xmin,y=xmax,z=ymin,w=ymax
                int oldWidth = oldTex.width, oldHeight = oldTex.height;

                for (int y = 0; y < oldHeight; ++y)
                {
                    for (int x = 0; x < oldWidth; ++x)
                    {
                        Color32 c = pixels[y * oldWidth + x];

                        if (c.a != 0)
                        {
                            if (y < pad.z) pad.z = y;
                            if (y > pad.w) pad.w = y;
                            if (x < pad.x) pad.x = x;
                            if (x > pad.y) pad.y = x;
                        }
                    }
                }

                int newWidth = (int)(pad.y - pad.x) + 1, newHeight = (int)(pad.w - pad.z) + 1;

                if (newWidth > 0 && newHeight > 0)
                {
                    Color32[] newPixels = new Color32[newWidth * newHeight];

                    for (int y = 0; y < newHeight; ++y)
                        for (int x = 0; x < newWidth; ++x)
                            newPixels[y * newWidth + x] = pixels[((int)pad.z + y) * oldWidth + ((int)pad.x + x)];
                    pads[i] = new Vector4(pad.x, oldWidth - newWidth - pad.x, pad.z, oldHeight - newHeight - pad.z);
                    temps[i] = new Texture2D(newWidth, newHeight);
                    temps[i].name = texs[i].name;
                    temps[i].SetPixels32(newPixels);
                }
            }
            if (unload) AssetManager.UnLoadTexture(texs);
            texs = temps;
            unload = true;
        }

        Material mat = null;
        Rect[] rects = AssetManager.PackTextures(texs, out mat, unload);
        Texture2D tex = mat.mainTexture as Texture2D;
        UIAtlas atlas = new GameObject("TempAtlas").AddComponent<UIAtlas>();
        atlas.spriteMaterial = mat;
        atlas.spriteMaterial.mainTexture = tex;
        int width = tex.width, height = tex.height;
        for (int i = 0; i < len; i++)
        {
            UISpriteData sprite = new UISpriteData();
            sprite.name = texs[i].name;
            Rect rect = NGUIMath.ConvertToPixels(rects[i], width, height, true);
            sprite.SetRect((int)rect.xMin, (int)rect.yMin, (int)rect.width, (int)rect.height);
            if (pads != null)
            {
                Vector4 pad = pads[i];
                sprite.SetPadding((int)pad.x, (int)pad.z, (int)pad.y, (int)pad.w);
            }
            atlas.spriteList.Add(sprite);
        }
        return atlas;
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    /// <summary>
    /// 加载一个资源
    /// </summary>
    /// <typeparam name="T">资源类型</typeparam>
    /// <param name="resName">资源名称</param>
    /// <returns></returns>
    public static T Load<T>(string resName) where T : Object { return AssetManager.LoadAsset(resName).GetAsset<T>(); }
    /// <summary>
    /// 加载一个资源
    /// </summary>
    /// <param name="resName">资源名称</param>
    /// <typeparam name="type">资源类型</typeparam>
    public static Object Load(string resName, System.Type type) { return AssetManager.LoadAsset(resName).GetAsset(type); }
    /// <summary>
    /// 加载一个资源
    /// </summary>
    /// <param name="resName">资源名称</param>
    /// <typeparam name="typeName">资源类型名称</typeparam>
    public static Object Load(string resName, string typeName)
    {
        System.Type type = System.Type.GetType(typeName);
        return type == null ? null : AssetManager.LoadAsset(resName).GetAsset(type);
    }
    /// <summary>
    /// 加载一张纹理(失败时加载默认)
    /// </summary>
    /// <param name="resName">资源名称</param>
    public static Texture LoadTexture(string resName) { return LoadTexture(resName, true); }
    /// <summary>
    /// 加载一张纹理
    /// </summary>
    /// <param name="resName">资源名称</param>
    /// <param name="loadDefault">是否加载默认图片</param>
    public static Texture LoadTexture(string resName, bool loadDefault) { return AssetManager.Load<Texture>(resName) ?? (loadDefault ? AssetManager.defaultTexture : null); }
    /// <summary>
    /// 加载材质
    /// </summary>
    /// <param name="resName">资源名称</param>
    public static Material LoadMaterial(string resName) { return AssetManager.Load<Material>(resName); }
    /// <summary>
    /// 加载TextAsset
    /// </summary>
    /// <param name="resName">资源名称</param>
    public static TextAsset LoadTextAsset(string resName) { return AssetManager.Load<TextAsset>(resName); }
    /// <summary>
    /// 加载文本
    /// </summary>
    /// <param name="resName">资源名称</param>
    public static string LoadText(string resName) { TextAsset txt = AssetManager.Load<TextAsset>(resName); return txt ? txt.text : null; }
    /// <summary>
    /// 加载字节数据
    /// </summary>
    /// <param name="resName">资源名称</param>
    public static byte[] LoadBytes(string resName) { TextAsset txt = AssetManager.Load<TextAsset>(resName); return txt ? txt.bytes : null; }
    /// <summary>
    /// 加载一个预制件
    /// </summary>
    /// <param name="resName">资源名称</param>
    public static GameObject LoadPrefab(string resName) { return AssetManager.Load<GameObject>(resName); }
    /// <summary>
    /// 加载一个声音文件
    /// </summary>
    /// <param name="resNmae">资源名称</param>
    public static AudioClip LoadAudioClip(string resNmae) { return AssetManager.Load<AudioClip>(resNmae); }
    #endregion

    #region 辅助函数
    /// <summary>
    /// 获取资源在内存中的大小
    /// </summary>
    public static int GetResSize(Object res)
    {
        if (!res) return 0;
        if (res is Texture) return GetTextureSize(res as Texture);
        if (res is TextAsset) return (res as TextAsset).bytes.Length;
        if (res is AudioClip) return GetAudioClipSize(res as AudioClip);
        if (res is Mesh) return GetMeshSize(res as Mesh);
        return 0;
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    /// <summary>
    /// 获取纹理在内存中的大小
    /// </summary>
    public static int GetTextureSize(Texture tex)
    {
        /*
        ATF_RGB_DXT1 = 38,
        ATF_RGBA_JPG = 39,
        ATF_RGB_JPG = 40,
        EAC_R = 41,
        EAC_R_SIGNED = 42,
        EAC_RG = 43,
        EAC_RG_SIGNED = 44,
        */
        float size = tex.height * tex.height;
        if (tex is Texture2D)
        {
            Texture2D t = tex as Texture2D;
            switch(t.format)
            {
                default:
                case TextureFormat.Alpha8:
                case TextureFormat.DXT5:
                case TextureFormat.ATC_RGBA8:
                case TextureFormat.ETC2_RGBA8:
                case TextureFormat.ASTC_RGB_4x4:
                case TextureFormat.ASTC_RGBA_4x4:
                    break;
                case TextureFormat.RGBA32:
                case TextureFormat.ARGB32:
                case TextureFormat.BGRA32:
                    size *= 4f;
                    break;
                case TextureFormat.ARGB4444:
                case TextureFormat.RGBA4444:
                case TextureFormat.RGB565:
                    size *= 2f;
                    break;
                case TextureFormat.RGB24:
                    size *= 3f;
                    break;
                case TextureFormat.DXT1:
                case TextureFormat.PVRTC_RGB4:
                case TextureFormat.PVRTC_RGBA4:
                case TextureFormat.ATC_RGB4:
                case TextureFormat.ETC_RGB4:
                case TextureFormat.ETC2_RGB:
                case TextureFormat.ETC2_RGBA1:
                    size *= 0.5f;
                    break;
                case TextureFormat.PVRTC_RGB2:
                case TextureFormat.PVRTC_RGBA2:
                case TextureFormat.ASTC_RGB_8x8:
                case TextureFormat.ASTC_RGBA_8x8:
                    size *= 0.25f;
                    break;
                case TextureFormat.ASTC_RGB_5x5:
                case TextureFormat.ASTC_RGBA_5x5:
                    size *= 0.64f;
                    break;
                case TextureFormat.ASTC_RGB_6x6:
                case TextureFormat.ASTC_RGBA_6x6:
                    size *= 0.445f;
                    break;
                case TextureFormat.ASTC_RGB_10x10:
                case TextureFormat.ASTC_RGBA_10x10:
                    size *= 0.16f;
                    break;
                case TextureFormat.ASTC_RGB_12x12:
                case TextureFormat.ASTC_RGBA_12x12:
                    size *= 0.11125f;
                    break;
            }
            if (t.mipmapCount > 1) size *= 1.33f;
        }
        else if (tex is RenderTexture)
        {
            RenderTexture t = tex as RenderTexture;
            switch (t.format)
            {
                default:
                case RenderTextureFormat.Default:
                case RenderTextureFormat.ARGB32:
                case RenderTextureFormat.RGHalf:
                case RenderTextureFormat.RFloat:
                    size *= 4f;
                    break;
                case RenderTextureFormat.RGB565:
                case RenderTextureFormat.ARGB4444:
                case RenderTextureFormat.ARGB1555:
                case RenderTextureFormat.RHalf:
                    size *= 2f;
                    break;
                case RenderTextureFormat.ARGBHalf:
                case RenderTextureFormat.DefaultHDR:
                case RenderTextureFormat.RGFloat:
                    size *= 8f;
                    break;
                case RenderTextureFormat.Depth:
                    size *= 0f;
                    break;
                case RenderTextureFormat.ARGBFloat:
                    size *= 16f;
                    break;
                case RenderTextureFormat.R8:
                    break;
                case RenderTextureFormat.ARGBInt:
                case RenderTextureFormat.RGInt:
                case RenderTextureFormat.RInt:
                    break;
            }
            if (t.depth == 16) size += 2;
            else if (t.depth == 24) size += 4;
            if (t.antiAliasing > 0) size *= t.antiAliasing;
        }
        return (int)size;
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    public static int GetAudioClipSize(AudioClip ac)
    {
        return Mathf.CeilToInt(ac.length * 4000);
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    public static int GetMeshSize(Mesh mesh)
    {
        return 0;
    }
    /// <summary>
    /// 根据资源，取得包内路径
    /// </summary>
    /// <param name="asset">资源</param>
    public static string GetPathFromAsset(Asset asset)
    {
        if (asset == null) return string.Empty;
        return (asset.meta == null || asset.meta.path < 0 ? InferInternalPath(asset.name) : GetPathFromId(asset.meta.path)) + asset.name;
    }
    /// <summary>
    /// 根据资源唯一名称，取得包内存储路径
    /// </summary>
    /// <param name="assetName">资源唯一名称</param>
    public static string GetPathFromAssetName(string assetName)
    {
        if (string.IsNullOrEmpty(assetName)) return string.Empty;
        AssetMeta meta = GetAssetMeta(assetName);
        return (meta == null || meta.path < 0 ? InferInternalPath(assetName) : GetPathFromId(meta.path)) + assetName;
    }
    /// <summary>
    /// 根据PathID获取内部路径
    /// </summary>
    private static string GetPathFromId(int pathId)
    {
        if (_inPaths == null || pathId < 0 || pathId >= _inPaths.Length) return string.Empty;
        return _inPaths[pathId];
    }
    /// <summary>
    /// 根据资源名称推断其包内路径
    /// </summary>
    /// <param name="assetName">资源名称</param>
    private static string InferInternalPath(string assetName)
    {
        if (assetName.StartsWith("tex_", true, null)) return AssetPath.Texture;
        if (assetName.StartsWith("dat_", true, null)) return AssetPath.Data;
        if (assetName.StartsWith("mat_", true, null)) return AssetPath.Material;

        if (assetName.StartsWith("ef_", true, null)) return AssetPath.Effect;
        if (assetName.StartsWith("atlas_", true, null)) return AssetPath.Atlas;
        if (assetName.StartsWith("anim_", true, null)) return AssetPath.Anim;
        if (assetName.StartsWith("bgm_", true, null)) return AssetPath.BGM;
        if (assetName.StartsWith("soe_", true, null)) return AssetPath.SOE;

        if (assetName.StartsWith("bg_", true, null)) return AssetPath.Background;
        if (assetName.StartsWith("font_", true, null)) return AssetPath.Font;
        if (assetName.StartsWith("mesh_", true, null)) return AssetPath.Mesh;

        if (assetName.StartsWith("efr_", true, null)) return AssetPath.EffectRes;

        return AssetPath.Prefab;
    }

    /// <summary>
    /// 存储数量单位输出
    /// </summary>
    public static string GetMemoryStr(int memoryInByte)
    {
        if(memoryInByte < 10000)
        {
            return memoryInByte + " B";
        }
        else if(memoryInByte < 1024000)
        {
            return (memoryInByte * 0.0009765625f).ToString("f2") + " KB";
        }
        else if (memoryInByte < 1048576000)
        {
            return (memoryInByte * 0.00000095367431640625f).ToString("f2") + " MB";
        }
        else
        {
            return (memoryInByte * 0.00000095367431640625f).ToString("f2") + " MB";
        }
    }
    /// <summary>
    /// 获取资源的CRC
    /// </summary>
    public static int GetAssetCRC(string assetPath)
    {
        FileStream fs = null;
        try
        {
            fs = new FileStream(assetPath, FileMode.Open);
            if (fs.Length > 4)
            {
                fs.Seek(fs.Length - 4);
                byte[] buffer = new byte[4];
                fs.Read(buffer, 0, 4);
                return (buffer[0] | buffer[1] << 8 | buffer[2] << 16 | buffer[3] << 24);
            }
        }
        catch (System.Exception e)
        {
            Debug.Log(e);
        }
        finally
        {
            if (fs != null)
            {
                fs.Dispose();
            }
        }
        return 0;
    }
    #endregion

    #region 组件部分
    private void Start()
    {
        if (_Instance == null)
        {
            _Instance = this;
            MoveToGame(_Instance.gameObject);
        }
        else if (_Instance != this)
        {
            this.DestructIfOnly();
        }
    }

    private void Update()
    {
        if (_curLoadAsset != null)
        {
            if (!_curLoadAsset.Loading()) _curLoadAsset = null;
        }
        else if (_assetQueue.Count > 0)
        {
            while (_curLoadAsset == null)
            {
                _curLoadAsset = _assetQueue.Dequeue();
                if (_assetList.Contains(_curLoadAsset)) _curLoadAsset = null;
                if (_assetQueue.Count < 1) break;
            }
        }
        if (_assetList.Count > 0)
        {
            for (int i = Mathf.Min(_assetList.Count - 1, _maxParallelCount); i >= 0; i--)
            {
                if (_assetList[i].Loading()) continue;
                _assetList.RemoveAt(i);
            }
        }

        CalculateMemoryLimt();

        if (_assetSize > assetAutoUnloadLimit && nextAutoUnloadTime < Time.realtimeSinceStartup)
        {
            _unloadLevel = 100;
            nextAutoUnloadTime = Time.realtimeSinceStartup + AUTO_UNLOAD_MIN_DELTA_TIME;
        }

        if (_unloadLevel >= 0)
        {
            UnLoadAsset(_unloadLevel);
            _unloadLevel = -1;
        }

        if (nextResourcesUnloadTime > 0f && nextResourcesUnloadTime < Time.realtimeSinceStartup)
        {
            nextResourcesUnloadTime = 0f;
            Resources.UnloadUnusedAssets();
        }
    }

    private void OnApplicationPause(bool pause)
    {
        _isBackground = pause;
    }

    #region 调试部分
#if TEST || UNITY_EDITOR
    [System.NonSerialized] private UIPanel mInfoPanel;
    [System.NonSerialized] private UITexture mInfoBg;
    [System.NonSerialized] private UILabel mInfoText;
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    [SerializeField] public bool showInfoPanel;
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    public static int assetCount { get { return _assetDic.Count; } }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    public static void GetAssetStatic(out int available, out int invalid)
    {
        available = 0;
        invalid = 0;
        foreach (Asset asset in _assetDic.Values)
        {
            if (asset.isDone)
            {
                if (asset.isInvalid) invalid++;
                else available++;
            }
        }
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    public static List<Asset> GetAvailableAssets()
    {
        List<Asset> list = new List<Asset>(8);
        foreach (Asset asset in _assetDic.Values)
        {
            if (asset.isDone)
            {
                if (!asset.isInvalid) list.Add(asset);
            }
        }
        return list;
    }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    public static int assetMemory { get { return _assetSize; } }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    public static int assetLoadingCount { get { return _assetList.Count + (_curLoadAsset != null ? 1 : 0); } }
#if UNITY_EDITOR && TOLUA
    [NoToLua]
#endif
    public static int assetLoadWaitCount { get { return _assetQueue.Count; } }

    private void LateUpdate()
    {
        if (!showInfoPanel)
        {
            if (mInfoText) mInfoText.DestructGameObject();
            if (mInfoBg) mInfoBg.DestructGameObject();
            if (mInfoPanel) mInfoPanel.Destruct();
            return;
        }
        if (!mInfoPanel)
        {
            mInfoPanel = gameObject.AddComponent<UIPanel>();
            mInfoPanel.depth = 2000;
        }
        if (!mInfoText)
        {
            mInfoText = gameObject.AddWidget<UILabel>();
            mInfoText.trueTypeFont = _mainFont;
            mInfoText.fontSize = 32;
            mInfoText.overflowMethod = UILabel.Overflow.ResizeHeight;
            mInfoText.width = 480;
            mInfoText.supportEncoding = true;
            mInfoText.effectStyle = UILabel.Effect.None;
            mInfoText.depth = 1;
            mInfoText.rawPivot = UIWidget.Pivot.TopLeft;
            mInfoText.cachedTransform.localPosition = new Vector3(-478f, 268f, 0f);
            mInfoText.cachedTransform.localScale = Vector3.one * 0.5625f;
        }
        if (!mInfoBg)
        {
            mInfoBg = gameObject.AddWidget<UITexture>("info_bg");
            mInfoBg.mainTexture = CreatTexture(8, 8, new Color(0f, 0f, 0f, 0.8f), TextureFormat.Alpha8, true);
            mInfoBg.pivot = UIWidget.Pivot.TopLeft;
            mInfoBg.depth = 0;
            mInfoBg.cachedTransform.localPosition = mInfoText.cachedTransform.localPosition;
            mInfoBg.SetAnchor(mInfoText.cachedGameObject, -2, -2, 2, 2);
        }

        mInfoText.text = "系统内存:" + SystemInfo.systemMemorySize + " MB";
#if UNITY_EDITOR
        mInfoText.text += "\n可用保留内存:" + GetMemoryStr(systemAvailableMemory);
#else
        mInfoText.text += "\n系统空余内存:" + GetMemoryStr(systemAvailableMemory);
#endif
        int a = 0, b = 0;
        GetAssetStatic(out a, out b);
        mInfoText.text += "\n资源总数:" + assetCount;
        mInfoText.text += "\n      可用:" + a + "  无效:" + b;
        mInfoText.text += "\n      下载:" + assetLoadingCount + "  等待:" + assetLoadWaitCount;
        mInfoText.text += "\n预计资源占用内存:" + GetMemoryStr(assetMemory);
        mInfoText.text += "\n资源内存可用极限:" + GetMemoryStr(assetSizeLimit);
        mInfoText.text += "\n";
        mInfoText.text += "\n无效资源:\n";
        foreach (Asset asset in _assetDic.Values)
        {
            if (asset.isDone)
            {
                if (asset.isInvalid) mInfoText.text += asset.name + " ";
            }
        }
    }
#endif
    #endregion

#if UNITY_EDITOR
    private void OnApplicationQuit()//退出游戏时
    {
        UnloadAllAsset();
        File.DeleteFiles(voicePath);
    }
#endif
    #endregion
}