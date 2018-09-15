using UnityEditor;
using UnityEngine;
using Kiol.IO;
using Kiol.Util;
using System.Collections.Generic;

public class JW_AssetManager : EditorWindow
{
    public class AssetEntry
    {
        public string path;
        public Object obj;
        public List<Object> objs = new List<Object>();
    }
    public class BundleEntry
    {
        public string path;
        public Object obj;
        public AssetBundle bundle;
        public Object[] assets;

        public BundleEntry(string bundlePath)
        {
            byte[] datas = File.ReadFile(bundlePath);
            bundle = datas.GetLength() > 0 ? AssetBundle.LoadFromMemory(datas) : null;
            if (bundle)
            {
                path = bundlePath;
                obj = AssetDatabase.LoadAssetAtPath(path, typeof(Object));
                if (!obj) Debug.LogWarning(path);
                assets = bundle.LoadAllAssets();
                if (bundle.mainAsset)
                {
                    int midx = System.Array.IndexOf(assets, bundle.mainAsset);
                    if (midx > 0)
                    {
                        assets[midx] = assets[0];
                        assets[0] = bundle.mainAsset;
                    }
                    else if (midx < 0)
                    {
                        int l = assets.Length;
                        System.Array.Resize(ref assets, l + 1);
                        assets[l] = assets[0];
                        assets[0] = bundle.mainAsset;
                    }
                }
            }
        }

        public void Dispose()
        {
            if (bundle) bundle.Unload(true);
            bundle = null;
            path = null;
            obj = null;
            assets = null;
        }
    }

    private const string BUNDLE_PATH = "Assets/AssetBundles";
    private const string TEXTURE_PATH = "Assets/AssetBundles/Texture";
    /// <summary>
    /// [0=离散打包, 1=包装打包, 2=纹理去Alpha, 3=纹理导入, 4=AssetBundle
    /// </summary>
    private int mCurOption = 0;
    private string[] mOption = new string[5] { "离散打包", "包装打包", "纹理去Alpha", "纹理导入", "AssetBundle" };
    private string[] mBtnName = new string[5] { "打包", "打包", "执行", "配置", "查看" };
    private string[] mIntro = new string[5]
    {
        "将选中的资源分别独立打包成Assetbundle(同名资源不会分离)，不会剥离内部依赖资源。\n输出目录：" + BUNDLE_PATH,
        "将选中的资源打包成一个Assetbundle，剥离内部依赖资源。\n输出目录：" + BUNDLE_PATH,
        "将选中的纹理Alpha预乘剥离，并替换原有纹理(备份于" + TEXTURE_PATH + ")。\n用于Aditive类着色器，Aditive粒子效果",
        "批量配置纹理的导入设置",
        "浏览选定的AssetBundle内容"
    };

    private Object mMainObj;
    private string mMainObjName;
    private Object[] mSelectObjects;
    private Object[] mTempObjects;

    private Vector2 mScrollPos = Vector2.zero;
    private bool mShowScript = false;
    private bool mSshowInRes = false;
    private Dictionary<int, List<AssetEntry>> mObjDeps = new Dictionary<int, List<AssetEntry>>(4);

    List<Object> mCachePrefabs = new List<Object>(8);
    private List<BundleEntry> mCacheBundle = new List<BundleEntry>(2);

    private bool mTexCompress = false;
    private bool mTexAlpha = false;
    private bool mTexReadable = false;

    private void OnEnable()
    {
        titleContent.text = "资源管理器";
        minSize = new Vector2(420f, 512f);
        CheckDirectory();
        SetTempObjs(Selection.objects);
    }

    private void OnDisable() { ClearPrafabCache(); }

    private void OnSelectionChange() { SetTempObjs(Selection.objects); }

    private void OnGUI()
    {
        if (mCacheBundle.Count > 0)
        {
            
        }
        //功能项布局
        int opt = GUILayout.SelectionGrid(mCurOption, mOption, 4);
        if (mCurOption != opt)
        {
            mCurOption = opt;
            //功能切换时过滤已添加项
            //if (HasSelectOpt)
            //{
            //    if (_selectObjects.GetLength() > 0)
            //    {
            //        _selectObjects = System.Array.FindAll(_selectObjects, CheckObject);
            //        System.Array.Resize(ref _selectObjects, _selectObjects.Length + 1);
            //    }
            //}
        }
        if (mIntro.IndexAvailable(mCurOption)) EditorGUILayout.HelpBox(mIntro[mCurOption], MessageType.Info);
        JWEditorTools.DrawSepLine(3f, 2f);

        if (hasSelectOpt)
        {
            if (mCurOption == 4 && mCacheBundle.Count > 0)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("浏览资源包" , GUILayout.Width(80f));
                if (GUILayout.Button("清除返回", GUILayout.Width(80f)))
                {
                    ClearPrafabCache();
                }
                EditorGUILayout.EndHorizontal();
                JWEditorTools.DrawSepLine(1f);
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("资源包", GUILayout.Width(120f));
                EditorGUILayout.LabelField("包内容", GUILayout.Width(120f));
                EditorGUILayout.EndHorizontal();

                mScrollPos = EditorGUILayout.BeginScrollView(mScrollPos, false, false);
                for (int i = 0; i < mCacheBundle.Count; i++)
                {
                    if (mCacheBundle[i].bundle)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.ObjectField("", mCacheBundle[i].obj, typeof(AssetBundle), false, GUILayout.Width(120f));
                        EditorGUILayout.BeginVertical();
                        Object[] bas = mCacheBundle[i].assets;
                        for (int j = 0; j < bas.Length; j++)
                        {
                            EditorGUILayout.ObjectField("", bas[j], typeof(Object), false, GUILayout.Width(120f));
                        }
                        EditorGUILayout.EndVertical();
                        EditorGUILayout.EndHorizontal();
                    }
                }

                if (mCachePrefabs.Count > 0)
                {
                    EditorGUILayout.Space();
                    EditorGUILayout.LabelField("缓存Prefab", GUILayout.Width(120f));
                    for (int i = 0; i < mCachePrefabs.Count; i++)
                    {
                        EditorGUILayout.ObjectField("", mCachePrefabs[i], typeof(Object), false, GUILayout.Width(120f));
                    }
                }

                EditorGUILayout.EndScrollView();
            }
            else
            {
                //当前选择项布局
                int lineCount = Mathf.Max(1, Mathf.FloorToInt(position.width / 120f));

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("当前选中资源", GUILayout.Width(80f));
                if (GUILayout.Button("添加", GUILayout.Width(80f)) && mTempObjects.GetLength() > 0)
                {
                    Object[] temp = System.Array.FindAll(mTempObjects, CheckSelectObject);
                    if (temp.GetLength() > 0)
                    {
                        ArrayExtend.TrimSame(ref mSelectObjects);
                        int idx = mSelectObjects.Length;
                        System.Array.Resize(ref mSelectObjects, idx + temp.Length + 1);
                        System.Array.Copy(temp, 0, mSelectObjects, idx, temp.Length);
                    }
                    temp = null;
                }
                EditorGUILayout.EndHorizontal();
                if (mTempObjects.GetLength() > 0)
                {
                    int c = 0;
                    for (int i = 0; i < mTempObjects.Length; i++)
                    {
                        if (CheckObject(mTempObjects[i]))
                        {
                            if (lineCount > 1 && c % lineCount == 0)
                            {
                                if (c > 0) EditorGUILayout.EndHorizontal();
                                EditorGUILayout.BeginHorizontal();
                            }
                            EditorGUILayout.ObjectField("", mTempObjects[i], typeof(Object), false, GUILayout.Width(120f));
                            c++;
                        }
                    }
                    if (c > 0 && lineCount > 1) EditorGUILayout.EndHorizontal();
                }
                else
                {
                    EditorGUILayout.LabelField("当未选中可用资源");
                }

                JWEditorTools.DrawSepLine(3f, 2f);

                //已添加项
                if (mSelectObjects.GetLength() < 1) mSelectObjects = new Object[1];

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("已添加资源", GUILayout.Width(80f));
                if (GUILayout.Button("清除已添加", GUILayout.Width(80f)))
                {
                    mSelectObjects = new Object[1];
                }
                if (GUILayout.Button(mBtnName.IndexAvailable(mCurOption) ? mBtnName[mCurOption] : "确定", GUILayout.Width(80f)))
                {
                    if (mCurOption == 0 || mCurOption == 1)
                    {
                        if (mCurOption == 1)
                        {
                            string packName = mMainObj ? mMainObj.name : mMainObjName;
                            if (string.IsNullOrEmpty(packName))
                            {
                                Debug.LogWarning("main asset or name is empty");
                                return;
                            }
                            BuildAssetBundle(System.Array.FindAll(mSelectObjects, CheckObject), packName);
                        }
                        else
                        {
                            BuildAssetBundle(System.Array.FindAll(mSelectObjects, CheckObject));
                        }

                        if (mCacheBundle.Count > 0)
                        {
                            int l = CollapseArray(mSelectObjects);
                            int nl = l + mCacheBundle.Count + 1;
                            if (nl > mSelectObjects.Length) System.Array.Resize(ref mSelectObjects, nl);
                            for (int i = 0; i < mCacheBundle.Count; i++)
                            {
                                if (System.Array.Exists(mSelectObjects, o => { return o == mCacheBundle[i].obj; })) continue;
                                mSelectObjects[l + i] = mCacheBundle[i].obj;
                            }

                            mCurOption = 4;

                            return;
                        }
                    }
                    else if (mCurOption == 2)
                    {
                        PremultipliedAlpha();
                    }
                    else if (mCurOption == 3)
                    {
                        if (mSelectObjects.GetLength() > 0)
                        {
                            for (int i = 0; i < mSelectObjects.Length; i++)
                            {
                                if (mSelectObjects[i] is Texture2D)
                                {
                                    string texPath = AssetDatabase.GetAssetPath(mSelectObjects[i]);
                                    if (string.IsNullOrEmpty(texPath)) continue;
                                    if (mTexCompress)
                                    {
                                        AssetEditorTools.TextureCompressImport(texPath, mTexAlpha, mTexReadable);
                                    }
                                    else
                                    {
                                        AssetEditorTools.TextureTrueImport(texPath, mTexAlpha, mTexReadable);
                                    }
                                }
                            }
                        }
                    }
                    else if (mCurOption == 4)
                    {
                        ClearPrafabCache();
                        foreach (Object obj in mSelectObjects)
                        {
                            if (CheckObject(obj))
                            {
                                AddBundleToCache(AssetDatabase.GetAssetPath(obj));
                            }
                        }
                    }
                }
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.Space();

                //选择主资源布局
                if (mCurOption == 1)
                {
                    List<Object> objs = new List<Object>(mSelectObjects.Length);
                    List<string> objNmaes = new List<string>(mSelectObjects.Length);
                    for (int i = 0; i < mSelectObjects.Length; i++)
                    {
                        if (mSelectObjects[i] is GameObject && CheckObject(mSelectObjects[i]))
                        {
                            objs.Add(mSelectObjects[i]);
                            objNmaes.Add(mSelectObjects[i].name);
                        }
                    }
                    objNmaes.Add("自定义名称");
                    int idx = mMainObj ? objs.IndexOf(mMainObj) : -1;
                    if (idx < 0) idx = objNmaes.Count - 1;

                    EditorGUILayout.BeginHorizontal();
                    EditorGUIUtility.labelWidth = 60f;
                    idx = EditorGUILayout.Popup("资源包名称", idx, objNmaes.ToArray(), GUILayout.Width(200f));
                    mMainObj = idx < objs.Count ? objs[idx] : null;
                    if (mMainObj == null)
                    {
                        mMainObjName = EditorGUILayout.TextField("输入名称", mMainObjName);
                        if (string.IsNullOrEmpty(mMainObjName)) mMainObjName = "GameObject";
                    }
                    EditorGUIUtility.labelWidth = 0f;
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.Space();
                }

                if (mCurOption == 0 || mCurOption == 1)
                {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField("已选资源", GUILayout.Width(120f));
                    EditorGUILayout.LabelField("依赖资源", GUILayout.Width(120f));
                    if (mCurOption == 1)
                    {
                        if (mSshowInRes)
                        {
                            EditorGUIUtility.labelWidth = 50f;
                            mShowScript = EditorGUILayout.Toggle("显示脚本", mShowScript, GUILayout.Width(70f));
                        }
                        else
                        {
                            GUILayout.Space(74f);
                        }
                        EditorGUIUtility.labelWidth = 72f;
                        mSshowInRes = EditorGUILayout.Toggle("显示内部资源", mSshowInRes, GUILayout.Width(120f));
                        EditorGUIUtility.labelWidth = 0f;
                    }
                    EditorGUILayout.EndHorizontal();
                    JWEditorTools.DrawSepLine(1f);
                }
                else if (mCurOption == 3)
                {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUIUtility.labelWidth = 50f;
                    mTexCompress = EditorGUILayout.Toggle("是否压缩", mTexCompress, GUILayout.Width(70f));
                    EditorGUIUtility.labelWidth = 50f;
                    mTexAlpha = EditorGUILayout.Toggle("是否透明", mTexAlpha, GUILayout.Width(70f));
                    EditorGUIUtility.labelWidth = 50f;
                    mTexReadable = EditorGUILayout.Toggle("是否可写", mTexReadable, GUILayout.Width(70f));
                    EditorGUIUtility.labelWidth = 0f;
                    EditorGUILayout.EndHorizontal();
                    JWEditorTools.DrawSepLine(1f);
                }

                //已添加项布局
                mScrollPos = EditorGUILayout.BeginScrollView(mScrollPos, false, false);
                bool expend = true;
                for (int i = 0; i < mSelectObjects.Length; i++)
                {
                    if (mSelectObjects[i] != null && !CheckObject(mSelectObjects[i])) continue;

                    EditorGUILayout.BeginHorizontal();
                    Object obj = EditorGUILayout.ObjectField("", mSelectObjects[i], typeof(Object), false, GUILayout.Width(120f));
                    if (obj != mSelectObjects[i] && (obj == null || CheckSelectObject(obj)))
                    {
                        mSelectObjects[i] = obj;
                    }
                    //依赖项布局
                    if (mSelectObjects[i] == null)
                    {
                        expend = false;
                    }
                    else if (mCurOption == 0 || mCurOption == 1)
                    {
                        List<AssetEntry> dpes = SearchObjectDependencies(mSelectObjects[i]);
                        if (dpes != null && dpes.Count > 0)
                        {
                            EditorGUILayout.BeginVertical();
                            for (int j = 0; j < dpes.Count; j++)
                            {
                                if (mCurOption == 1)
                                {
                                    if (!mSshowInRes && JWEditorTools.CheckInRes(dpes[j].path)) continue;
                                    if (!mShowScript && dpes[j].obj is MonoScript) continue;
                                }
                                EditorGUILayout.BeginHorizontal();
                                if (dpes[j].obj)
                                {
                                    EditorGUILayout.ObjectField("", dpes[j].obj, typeof(Object), false, GUILayout.Width(120f));
                                }
                                else
                                {
                                    EditorGUILayout.TextField("", Path.GetFileName(dpes[j].path), GUILayout.Width(120f));
                                }
                                EditorGUILayout.TextField("", dpes[j].path);
                                EditorGUILayout.EndHorizontal();
                            }
                            EditorGUILayout.EndVertical();
                        }
                        else
                        {
                            GUI.color = new Color(0.8f, 0.8f, 0.8f);
                            EditorGUILayout.LabelField("无依赖资源");
                            GUI.color = Color.white;
                        }
                    }
                    EditorGUILayout.EndHorizontal();
                }
                if (expend) System.Array.Resize(ref mSelectObjects, mSelectObjects.Length + 1);
                EditorGUILayout.EndScrollView();
            }
        }
    }

    private void CheckDirectory()
    {
        if (!Directory.Exists(BUNDLE_PATH)) Directory.CreateDirectory(BUNDLE_PATH);
        if (!Directory.Exists(TEXTURE_PATH)) Directory.CreateDirectory(TEXTURE_PATH);
    }

    private bool hasSelectOpt { get { return mCurOption >= 0 && mCurOption < 5; } }

    private void ClearPrafabCache()
    {
        for (int i = 0; i < mCacheBundle.Count; i++) mCacheBundle[i].Dispose();
        mCacheBundle.Clear();
        foreach (GameObject item in mCachePrefabs)
        {
            if (item)
            {
                string path = AssetDatabase.GetAssetPath(item);
                if (string.IsNullOrEmpty(path))
                {
                    DestroyImmediate(item);
                }
                else
                {
                    AssetDatabase.DeleteAsset(path);
                }
            }
        }
        mCachePrefabs.Clear();
        string[] prefabs = System.IO.Directory.GetFiles(BUNDLE_PATH, "*.prefab", System.IO.SearchOption.AllDirectories);
        foreach (string prefab in prefabs)
        {
            Object obj = AssetDatabase.LoadAssetAtPath(prefab, typeof(GameObject));
            if (obj)
            {
                string nt = GetTempNameSuffix(obj);
                string n = Path.GetFileNameWithoutExtension(prefab);
                if (n.EndsWith(nt))
                {
                    string ret = AssetDatabase.RenameAsset(prefab, n.Remove(n.Length - nt.Length));
                    if (!string.IsNullOrEmpty(ret))
                    {
                        Debug.LogWarning("restore name error:" + ret + "\n" + prefab);
                    }
                }
            }
        }
    }

    private bool CheckSelectObject(Object obj)
    {
        return CheckObject(obj) && (mSelectObjects == null || !System.Array.Exists(mSelectObjects, o => { return o == obj; }));
    }
    private bool CheckObject(Object obj)
    {
        string apath = AssetDatabase.GetAssetPath(obj);
        if (obj && File.Exists(apath))
        {
            if (mCurOption == 0 || mCurOption == 1)
            {
                return !(obj is MonoScript) && AssetDatabase.LoadAssetAtPath(apath, typeof(Object)) == obj;
            }
            if (mCurOption == 2 || mCurOption == 3)
            {
                return obj is Texture2D;
            }
            if (mCurOption == 4)
            {
                return Path.GetExtension(AssetDatabase.GetAssetPath(obj)).ToLower() == AssetManager.BUNDLE_EXTENSION;
            }
        }
        return false;
    }
    private void SetTempObjs(Object[] objs)
    {
        if (objs.GetLength() > 0)
        {
            mTempObjects = objs;
            Repaint();
        }
    }
    private void AddBundleToCache(string bundlePath)
    {
        int idx = -1;
        for (int i = 0; i < mCacheBundle.Count; i++)
        {
            if (mCacheBundle[i].path == bundlePath)
            {
                mCacheBundle[i].Dispose();
                idx = i;
                break;
            }
        }
        BundleEntry be = new BundleEntry(bundlePath);
        if (be.bundle)
        {
            if (idx < 0)
            {
                mCacheBundle.Add(be);
            }
            else
            {
                mCacheBundle[idx] = be;
            }
        }
        else if (idx >= 0)
        {
            mCacheBundle.RemoveAt(idx);
        }
    }

    private List<AssetEntry> SearchObjectDependencies(Object obj)
    {
        List<AssetEntry> list = null;
        if (obj && !mObjDeps.TryGetValue(obj.GetInstanceID(), out list))
        {
            string title = "正在搜索[" + obj + "]依赖项";
            EditorUtility.DisplayProgressBar(title, "", 0f);
            list = new List<AssetEntry>(8);
            mObjDeps.Add(obj.GetInstanceID(), list);
            Object[] deps = EditorUtility.CollectDependencies(new Object[1] { obj });
            for (int i = 0; i < deps.Length; i++)
            {
                if (deps[i] == obj) continue;

                string path = AssetDatabase.GetAssetPath(deps[i]);
                if (string.IsNullOrEmpty(path)) continue;

                EditorUtility.DisplayProgressBar(title, path, (float)(i + 1) / (float)deps.Length);

                AssetEntry ae = list.Find(a => { return a.path.Equals(path); });
                if (ae == null)
                {
                    ae = new AssetEntry();
                    ae.path = path;
                    ae.obj = AssetDatabase.LoadAssetAtPath(path, typeof(Object));
                    list.Add(ae);
                }
                ae.objs.Add(deps[i]);
            }
            EditorUtility.ClearProgressBar();
        }
        return list;
    }

    private void BuildAssetBundle(Object[] objs, string packName = null)
    {
        if (objs.GetLength() < 1) return;

        //清除缓存
        ClearPrafabCache();

        //原始资源列表
        List<Object> list = new List<Object>(objs);
        // 名称互斥集合
        HashSet<string> pathSet = new HashSet<string>();
        // 路径
        string path = null;

        BuildTarget platform = EditorUserBuildSettings.activeBuildTarget;

        if (string.IsNullOrEmpty(packName))
        {
            List<AssetBundleBuild> abbs = new List<AssetBundleBuild>();
            List<string> temp = new List<string>(4);
            for (int i = 0; i < list.Count; i++)
            {
                Object obj = list[i];
                if (obj == null) continue;
                path = AssetDatabase.GetAssetPath(obj);
                if (string.IsNullOrEmpty(path))
                {
                    Debug.Log("Object [" + obj.name + "(" + obj.GetInstanceID() + ")] is not a assets");
                    continue;
                }
                if (!pathSet.Add(path)) continue;
                if (obj is GameObject || obj is Component) obj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                temp.Clear();
                temp.Add(path);
                AssetBundleBuild abb = new AssetBundleBuild();
                abb.assetBundleName = obj.name;
                for (int j = i + 1; j < list.Count; j++)
                {
                    obj = list[j];
                    if (obj && obj.name == abb.assetBundleName)
                    {
                        list[j] = null;
                        path = AssetDatabase.GetAssetPath(obj);
                        if (string.IsNullOrEmpty(path))
                        {
                            Debug.Log("Object [" + obj.name + "(" + obj.GetInstanceID() + ")] is not a assets");
                            continue;
                        }
                        if (pathSet.Add(path)) temp.Add(path);
                    }
                }
                abb.assetNames = temp.ToArray();
                abbs.Add(abb);
            }
            
            if (abbs.Count > 0)
            {
                AssetBundleManifest abm = BuildPipeline.BuildAssetBundles(BUNDLE_PATH, abbs.ToArray(), BuildAssetBundleOptions.StrictMode, platform);
                if (abm != null)
                {
                    string[] abs = abm.GetAllAssetBundles();
                    for (int i = 0; i < abs.Length; i++)
                    {
                        path = Path.Combine(BUNDLE_PATH, abs[i]);
                        string abpath = path + AssetManager.BUNDLE_EXTENSION;
                        System.IO.File.Move(path, abpath);
                        uint crc = CRC32.CalculateCRC32(abpath);
                        byte[] crcBytes = new byte[4] { (byte)crc, (byte)(crc >> 8), (byte)(crc >> 16), (byte)(crc >> 24) };
                        FileStream fs = null;
                        try
                        {
                            fs = new FileStream(abpath, FileMode.Open);
                            long len = fs.Length;
                            fs.SetLength(len + 4);
                            fs.Seek(len);
                            fs.Write(crcBytes, 0, 4);
                        }
                        catch (System.Exception e)
                        {
                            Debug.Log("write crc error " + e);
                        }
                        finally
                        {
                            if (fs != null)
                            {
                                fs.Dispose();
                            }
                        }
                        AssetDatabase.ImportAsset(abpath);
                        AddBundleToCache(abpath);
                    }
                }
            }
        }
        else
        {
            string[] dps = null;
            int flag = 0;
            // 资源列表
            List<string> assets = new List<string>(list.Count);
            System.Type script = typeof(MonoScript);

            foreach (Object obj in list)
            {
                if (obj == null) continue;
                path = AssetDatabase.GetAssetPath(obj);
                if (string.IsNullOrEmpty(path))
                {
                    Debug.Log("Object [" + obj.name + "(" + obj.GetInstanceID() + ")] is not a assets");
                    continue;
                }
                if (!pathSet.Add(path)) continue;
                if (obj is GameObject || obj is Component)
                {
                    GameObject tempPrefab = CreatTempPrefab(AssetDatabase.LoadAssetAtPath<GameObject>(path));
                    if (tempPrefab)
                    {
                        path = AssetDatabase.GetAssetPath(tempPrefab);
                        if (string.IsNullOrEmpty(path))
                        {
                            EditorUtility.DisplayDialog("打包警告", "创建临时预制件失败\n" + AssetDatabase.GetAssetPath(obj), "终止");
                            return;
                        }
                        if (!pathSet.Add(path))
                        {
                            EditorUtility.DisplayDialog("打包警告", "创建临时预制件重复\n" + AssetDatabase.GetAssetPath(obj), "终止");
                            return;
                        }
                        if (obj.name == packName)
                        {
                            assets.Insert(flag == 2 ? 1 : 0, path);
                            flag = 2;
                        }
                        else
                        {
                            assets.Add(path);
                        }
                        List<AssetStripper.RefRes> rfs = StripAsset(tempPrefab);
                        AssetDatabase.SaveAssets();
                        dps = AssetDatabase.GetDependencies(path);
                        if (dps != null && dps.Length > 0)
                        {
                            foreach (string p in dps)
                            {
                                if (string.IsNullOrEmpty(p) || AssetDatabase.GetMainAssetTypeAtPath(p) == script) continue;
                                if (pathSet.Add(p)) assets.Add(p);
                            }
                        }
                        if (rfs.Count > 0)
                        {
                            SerializedObject so = new SerializedObject(tempPrefab.AddComponent<AssetStripper>());
                            SerializedProperty sp = so.FindProperty("mRef");
                            sp.arraySize = rfs.Count;
                            for (int i = 0; i < rfs.Count; i++)
                            {
                                SerializedProperty asp = sp.GetArrayElementAtIndex(i);
                                asp.FindPropertyRelative("target").objectReferenceValue = rfs[i].target;
                                asp.FindPropertyRelative("fieldPath").stringValue = rfs[i].fieldPath;
                                asp.FindPropertyRelative("resPath").stringValue = rfs[i].resPath;
                                asp.Dispose();
                            }
                            so.ApplyModifiedProperties();
                            sp.Dispose();
                            so.Dispose();
                        }
                    }
                    else
                    {
                        EditorUtility.DisplayDialog("打包警告", "创建临时预制件失败\n" + AssetDatabase.GetAssetPath(obj), "终止");
                        ClearPrafabCache();
                        return;
                    }
                }
                else if (obj.name == packName)
                {
                    assets.Insert(flag == 0 ? 0 : 1, path);
                    if (flag == 0) flag = 1;
                }
                else
                {
                    assets.Add(path);
                }
            }
            if (assets.Count < 1)
            {
                Debug.LogWarning("nothing build");
                return;
            }

            if (flag == 0)
            {
                path = BUNDLE_PATH + packName + ".asset";
                if (pathSet.Contains(path))
                {
                    Debug.LogWarning("create asset ["+ path + "] pack was exists");
                    return;
                }
                ScriptableObject obj = ScriptableObject.CreateInstance<ScriptableObject>();
                obj.name = packName;
                AssetDatabase.CreateAsset(obj, path);
                Destroy(obj);
                obj = AssetDatabase.LoadAssetAtPath<ScriptableObject>(path);
                if (obj)
                {
                    mCachePrefabs.Add(obj);
                    assets.Insert(0, path);
                }
                else
                {
                    Debug.LogWarning("create asset [" + path + "] failed");
                    return;
                }
            }

            AssetBundleBuild[] abbs = new AssetBundleBuild[1];
            abbs[0].assetBundleName = packName;
            abbs[0].assetNames = assets.ToArray();
            AssetBundleManifest abm = BuildPipeline.BuildAssetBundles(BUNDLE_PATH, abbs, BuildAssetBundleOptions.StrictMode, platform);
            if (abm != null)
            {
                path = Path.Combine(BUNDLE_PATH, packName);
                string bundlePath = path + AssetManager.BUNDLE_EXTENSION;
                System.IO.File.Move(path, bundlePath);
                uint crc = CRC32.CalculateCRC32(bundlePath);
                byte[] crcBytes = new byte[4] { (byte)crc, (byte)(crc >> 8), (byte)(crc >> 16), (byte)(crc >> 24) };
                FileStream fs = null;
                try
                {
                    fs = new FileStream(bundlePath, FileMode.Open);
                    long len = fs.Length;
                    fs.SetLength(len + 4);
                    fs.Seek(len);
                    fs.Write(crcBytes, 0, 4);
                }
                catch (System.Exception e)
                {
                    Debug.Log("write crc error " + e);
                }
                finally
                {
                    if (fs != null)
                    {
                        fs.Dispose();
                    }
                }
                AssetDatabase.ImportAsset(bundlePath);
                AddBundleToCache(bundlePath);
            }
        }
    }

    private GameObject CreatTempPrefab(GameObject go)
    {
        string path = AssetDatabase.GetAssetPath(go);
        string pn;
        if (string.IsNullOrEmpty(path))
        {
            pn = go.name;
        }
        else
        {
            pn = Path.GetFileNameWithoutExtension(path);
            if (Path.GetDirectoryName(path) == BUNDLE_PATH)
            {
                string nt = GetTempNameSuffix(go);
                if (pn.EndsWith(nt)) pn = pn.Remove(pn.Length - nt.Length);
                else
                {
                    string ret = AssetDatabase.RenameAsset(path, pn + nt);
                    if (!string.IsNullOrEmpty(ret))
                    {
                        Debug.LogWarning("rename prefab error:" + ret + "\n" + path);
                        return null;
                    }
                }
            }
        }
        go = PrefabUtility.CreatePrefab(GetPrefabPath(pn), go);
        mCachePrefabs.Add(go);
        return go;
    }

    private void PremultipliedAlpha()
    {
        if (mSelectObjects.GetLength() < 1) return;

        for (int j = 0; j < mSelectObjects.Length; j++)
        {
            if (mSelectObjects[j] is Texture2D)
            {
                string texPath = AssetDatabase.GetAssetPath(mSelectObjects[j]);
                if (string.IsNullOrEmpty(texPath)) continue;

                string backPath = TEXTURE_PATH + "/" + Path.GetFileName(texPath);
                string ret = AssetDatabase.MoveAsset(texPath, backPath);
                if (!string.IsNullOrEmpty(ret))
                {
                    Debug.LogWarning(texPath + "can not move to " + backPath);
                    continue;
                }

                AssetEditorTools.TextureTrueImport(backPath, true, true);

                AssetEditorTools.PremultipliedAlpha(mSelectObjects[j] as Texture2D);

                Texture2D tex = mSelectObjects[j] as Texture2D;
                AssetEditorTools.PremultipliedAlpha(tex);

                texPath = Path.ChangeExtension(texPath, ".png");
                File.WriteFile(texPath, tex.EncodeToPNG());
                AssetDatabase.ImportAsset(texPath);
                mSelectObjects[j] = AssetDatabase.LoadAssetAtPath(texPath, typeof(Texture2D));

                AssetEditorTools.TextureCompressImport(texPath, false, false);
            }
        }
    }

    private static int CollapseArray<T>(T[] arr)
    {
        if (arr == null) return 0;
        int l = 0;
        for (int i = 0; i < arr.Length; i++)
        {
            if (arr[i] == null) continue;
            if (i > l) { arr[l] = arr[i]; arr[i] = default(T); }
            l++;
        }
        return l;
    }
    private static string GetTempNameSuffix(Object go)
    {
        return "[" + go.GetInstanceID() + "]";
    }
    private static string GetPrefabPath(string prefabName)
    {
        return BUNDLE_PATH + "/" + prefabName + ".prefab";
    }
    private static string GetBundlePath(string bundleName)
    {
        return BUNDLE_PATH + "/" + bundleName + AssetManager.BUNDLE_EXTENSION;
    }

    private static Object GetMainAsset(List<Object> list)
    {
        foreach (Object obj in list) if (obj is GameObject) return obj;
        foreach (Object obj in list) if (obj is Material) return obj;
        return list[0];
    }

    #region AssetPacker Extend
    private static bool InvRes(Object res)
    {
        return res == null || res is MonoScript ||
            !(res is GameObject || res is Component || res is Font || res is Texture
            || res is AudioClip || res is Mesh || res is Material);
    }
    /// <summary>
    /// 剥离内部资源
    /// </summary>
    private static List<AssetStripper.RefRes> StripAsset(GameObject go)
    {
        if (Application.isPlaying)
        {
            Debug.LogWarning("please stop playing!");
            return null;
        }

        PrefabType pt = PrefabUtility.GetPrefabType(go);
        if (pt != PrefabType.Prefab)
        {
            Debug.LogWarning(go.name + "is not a Prefab, it is " + pt);
            return null;
        }

        //int aspsdx = 0;
        //SerializedObject aso = null;
        //SerializedProperty asps = null;
        //Component[] cmps = go.GetComponents<AssetStripper>();
        //if (cmps != null && cmps.Length > 0) foreach (Component cmp in cmps) DestroyImmediate(cmp);

        List<AssetStripper.RefRes> list = new List<AssetStripper.RefRes>(4);
        string oPath = AssetDatabase.GetAssetPath(go);

        Component[] cmps = go.GetComponentsInAllChild<Component>();
        foreach (Component cmp in cmps)
        {
            if (cmp is AssetStripper) continue;

            if (cmp is MonoBehaviour)
            {
                SerializedObject so = new SerializedObject(cmp);
                SerializedProperty sp = so.GetIterator();
                while (sp.Next(true))
                {
                    if (SerializedPropertyType.ObjectReference != sp.propertyType) continue;

                    Object value = sp.objectReferenceValue;

                    if (InvRes(value)) continue;

                    string path = AssetDatabase.GetAssetPath(value);

                    if (string.IsNullOrEmpty(path) || path.StartsWith("Library/") || path == oPath || AssetDatabase.LoadAssetAtPath(path, typeof(Object)) == null) continue;
                    int idx = path.IndexOf("/Resources/");
                    if (idx < 0)
                    {
                        continue;
                    }
                    //if (aso == null)
                    //{
                    //    aso = new SerializedObject(go.AddComponent<AssetStripper>());
                    //    asps = aso.FindProperty("mRef");
                    //    if (asps == null)
                    //    {
                    //        Debug.LogError("AssetStripper.mRef Cannot Find!"); return null;
                    //    }
                    //    if (!asps.isArray)
                    //    {
                    //        Debug.LogError("AssetStripper.mRef Cannot Type is Not Array!"); return null;
                    //    }
                    //    aspsdx = 0;
                    //}
                    path = path.Substring(idx + 11);
                    sp.objectReferenceValue = null;
                    AssetStripper.RefRes asp = new AssetStripper.RefRes();
                    asp.target = cmp;
                    asp.fieldPath = WrapPropertyPath(sp.propertyPath);
                    asp.resPath = System.IO.Path.Combine(System.IO.Path.GetDirectoryName(path), System.IO.Path.GetFileNameWithoutExtension(path)).Replace("\\", "/");
                    list.Add(asp);
                    //asps.arraySize = aspsdx + 1;
                    //SerializedProperty aspse = asps.GetArrayElementAtIndex(aspsdx++);
                    //aspse.FindPropertyRelative("target").objectReferenceValue = cmp;
                    //aspse.FindPropertyRelative("fieldPath").stringValue = WrapPropertyPath(sp.propertyPath);
                    //aspse.FindPropertyRelative("resPath").stringValue = System.IO.Path.Combine(System.IO.Path.GetDirectoryName(path), System.IO.Path.GetFileNameWithoutExtension(path)).Replace("\\", "/");
                    //aspse.Dispose();
                }
                so.ApplyModifiedProperties();
                sp.Dispose();
                so.Dispose();
            }
            else
            {
                // 暂不支持unity原生组件
            }
        }
        if (list.Count > 0)
        {
            cmps = go.GetComponents<AssetStripper>();
            if (cmps != null && cmps.Length > 0) foreach (Component cmp in cmps) DestroyImmediate(cmp);
        }
        return list;
    }

    private static string WrapPropertyPath(string pp)
    {
        string ret = "";
        int idx1 = 0;
        while (true)
        {
            int idx2 = pp.IndexOf(".Array.data[", idx1);
            if (idx2 < 0)
            {
                ret += pp.Substring(idx1, pp.Length - idx1);
                break;
            }
            else
            {
                ret += pp.Substring(idx1, idx2 - idx1);
                int idx3 = pp.IndexOf("]", idx2 + 12);
                if (idx3 < 0)
                {
                    throw new System.Exception("propertyPath : " + pp + "  wrap error : array idx parse failed");
                }
                else
                {
                    int idx4 = pp.IndexOf(".", idx2 + 12);
                    if (idx4 < 0 || idx3 < idx4)
                    {
                        ret += "." + int.Parse(pp.Substring(idx2 + 12, idx3 - idx2 - 12));
                        idx1 = idx3 + 1;
                    }
                    else
                    {
                        throw new System.Exception("propertyPath : " + pp + "  wrap error : array idx parse failed");
                    }
                }
            }
            
        }
        return ret;
    }
#endregion
}
