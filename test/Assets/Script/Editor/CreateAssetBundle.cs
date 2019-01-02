using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections.Generic;

public class XWTool : EditorWindow
{
    public class Asset
    {
        public Object obj;

        public string assetPath;

        public string[] opts;

        public int idx = 0;

        public bool active = false;

        public string md5;

        public string umd5;

        /// <summary>
        /// 包装打包参数
        /// </summary>
        public string pname;

        public Asset(Object _obj, string _assetPath, string[] _opts)
        {
            obj = _obj;
            assetPath = _assetPath;
            opts = _opts;

            pname = obj.name;
        }

        public void Draw()
        {
            EditorGUILayout.BeginHorizontal();
            bool a = EditorGUILayout.Toggle(active,GUILayout.Width(20.0f));
            if (active != a)
                active = a;
            EditorGUILayout.ObjectField("", obj, typeof(Object),GUILayout.Width(140.0f));
            int i = EditorGUILayout.Popup(idx, opts,GUILayout.Width(100.0f));
            if (idx != i)
                idx = i;
            switch(opts[idx])
            {
                case "包装打包":
                    string n = EditorGUILayout.TextField(pname);
                    if (pname != n)
                        pname = n;
                    break;
            }
            EditorGUILayout.EndHorizontal();
        }
    }

    private List<Asset> assets = new List<Asset>();

    private Vector2 scrollPosition = Vector2.zero;

    private KeyValuePair<string[], string[]>[] opts = 
    {
        new KeyValuePair<string[],string[]>(new string[]{".prefab"},new string[]{"包装打包","离散打包"}),
        new KeyValuePair<string[],string[]>(new string[]{".cs"},new string[]{"cs操作1","cs操作2"}),
        new KeyValuePair<string[],string[]>(new string[]{".png"},new string[]{"包装打包","离散打包","纹理操作1","纹理操作2"}),
        new KeyValuePair<string[],string[]>(new string[]{".lua"},new string[]{"加密Lua文件"}),
    };

    private string[] GetOpts(string ext)
    {
        if (ext == null)
            return null;
        for (int i = 0; i < opts.Length; ++i)
            for (int j = 0; j < opts[i].Key.Length; ++j)
                if (ext == opts[i].Key[j])
                    return opts[i].Value;
        return null;
    }

    private void OnEnable()
    {
        minSize = new Vector2(450.0f, 400.0f);
    }

    private void OnGUI()
    {
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("添加",GUILayout.Width(80.0f)))
        {
            Object[] objs = Selection.objects;
            if (objs.Length > 0)
            {
                Object t;
                string p;
                string[] q;
                foreach (Object obj in objs)
                {
                    p = AssetDatabase.GetAssetPath(obj);
                    if (string.IsNullOrEmpty(p))
                        continue;
                    t = AssetDatabase.LoadAssetAtPath<Object>(p);
                    if (!t)
                        continue;
                    if (!assets.Exists(a => { return a.obj == t; }))
                    {
                        q = GetOpts(Path.GetExtension(p));
                        if (q != null && q.Length > 0)
                            assets.Add(new Asset(t, p, q));
                    }
                }
            }
        }
        if(GUILayout.Button("运行",GUILayout.Width(80.0f)))
        {
            List<Object> list = new List<Object>(); //离散打包
            Dictionary<string, List<Object>> dic = new Dictionary<string, List<Object>>(); //包装打包
            List<string> luas = new List<string>(); //加密Lua文件

            foreach(Asset asset in assets)
            {
                if (!asset.active)
                    continue;
                switch(asset.opts[asset.idx])
                {
                    case "包装打包":
                        if (!string.IsNullOrEmpty(asset.pname))
                        {
                            if(!dic.ContainsKey(asset.pname))
                                dic.Add(asset.pname, new List<Object>());
                            dic[asset.pname].Add(asset.obj);
                        }
                        break;
                    case "离散打包":
                        list.Add(asset.obj);
                        break;
                    case "加密Lua文件":
                        luas.Add(asset.assetPath);
                        break;
                }
            }

            Debug.Log(list.Count);
            Debug.Log(dic.Count);
            Debug.Log(luas.Count);
        }
        EditorGUILayout.EndHorizontal();

        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);
        for (int i = 0; i < assets.Count; ++i)
            assets[i].Draw();
        EditorGUILayout.EndScrollView();
    }

    [MenuItem("工具/opts")]
    private static void Open()
    {
        EditorWindow.GetWindow<XWTool>().Show();
    }
}





























public class Auto : AssetPostprocessor
{
    public static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
    {
        Debug.Log(importedAssets.Length);
        Debug.Log(deletedAssets.Length);
        Debug.Log(movedAssets.Length);
        Debug.Log(movedFromAssetPaths.Length);
    }
}

public class CreateAssetBundle
{
    [MenuItem("工具/打包")]
    private static void SetBundleName()
    {
        ClearAssetBundlesName();
        Object[] objs = Selection.objects;
        if (objs.Length > 0)
            GenAssetBundles(objs);
        AssetDatabase.Refresh();
    }

    private static void GenAssetBundles(Object[] objs)
    {
        string ext = "unity3d";
        AssetImporter ai;
        foreach (Object obj in objs)
        {
            if (obj is MonoScript)
            {
                Debug.LogErrorFormat("{0}不可以打包", obj.name);
                return;
            }
            ai = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(obj));
            ai.assetBundleName = obj.name;
            ai.assetBundleVariant = ext;
        }
        BuildPipeline.BuildAssetBundles("Assets/AssetBundles/", BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows);
        ClearAssetBundlesName();
    }

    [MenuItem("工具/查看依赖")]
    private static void fun()
    {
        Object[] objs = Selection.objects;
        if (objs.Length == 1)
        {
            string[] strs = AssetDatabase.GetDependencies(AssetDatabase.GetAssetPath(objs[0]));
            foreach (string str in strs)
            {
                Debug.Log(str);
            }
        }
    }

    [MenuItem("工具/创建临时prefab")]
    private static void CreatePrefab()
    {
        Object[] objs = Selection.objects;
        if (objs.Length == 1 && objs[0] is GameObject)
        {
            //string pnm = Path.GetFileNameWithoutExtension(AssetDatabase.GetAssetPath(objs[0]));
            //Debug.Log(pnm);
            //PrefabUtility.CreatePrefab("Assets/AssetBundles/"+objs[0].name+".prefab", objs[0] as GameObject);
            //AssetDatabase.Refresh();
        }
    }

    [MenuItem("工具/剥离内部资源")]
    private static void StripAsset()
    {
        Object[] objs = Selection.objects;
        if (objs.Length == 1 && objs[0] is GameObject)
        {
            GameObject go = objs[0] as GameObject;
            string goPath = AssetDatabase.GetAssetPath(go);
            PrefabType pt = PrefabUtility.GetPrefabType(go);
            if (pt != PrefabType.Prefab)
            {
                Debug.LogError(pt);
                return;
            }
            MonoBehaviour[] mbs = go.GetComponents<MonoBehaviour>();
            List<AssetStripper.RefRes> list = new List<AssetStripper.RefRes>();
            SerializedObject so;
            SerializedProperty sp;
            Object value;
            string path;
            foreach (MonoBehaviour mb in mbs)
            {
                so = new SerializedObject(mb);
                sp = so.GetIterator();
                while (sp.Next(true))
                {
                    if (sp.propertyType != SerializedPropertyType.ObjectReference)
                        continue;
                    value = sp.objectReferenceValue;
                    path = AssetDatabase.GetAssetPath(value);
                    Debug.Log(value + " - " + InvRes(value));
                    if (InvRes(value))
                    {
                        continue;
                    }
                    Debug.Log(" - " + path);
                    if (string.IsNullOrEmpty(path) ||
                        path.StartsWith("Library/") ||
                        path == goPath ||
                        AssetDatabase.LoadAssetAtPath<Object>(path) == null)
                        continue;
                    //if (path.IndexOf("/Resources/") < 0)
                    //continue;
                    Debug.Log("单独" + path);

                    list.Add(new AssetStripper.RefRes(mb, WrapPropertyPath(sp.propertyPath), Path.GetFileNameWithoutExtension(path)));
                    sp.objectReferenceValue = null;

                    //if (InvRes(value))
                    //    continue;
                }
                so.ApplyModifiedProperties();
                sp.Dispose();
                so.Dispose();
            }

            if (list.Count > 0)
            {
                AssetStripper r = go.GetComponent<AssetStripper>() ?? go.AddComponent<AssetStripper>();
                r.mRefs = list.ToArray();
            }

            GenAssetBundles(new Object[1] { go });

            AssetDatabase.Refresh();
        }
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

    //是否是内部资源
    private static bool InvRes(Object res)
    {
        bool t =
            res == null ||
            res is MonoScript ||
            !(res is GameObject ||
            res is Component ||
            res is Font ||
            res is Texture ||
            res is AudioClip ||
            res is Mesh ||
            res is Material ||
            res is SceneAsset);


        return t;
    }

    private static void ClearAssetBundlesName()
    {
        string[] abs = AssetDatabase.GetAllAssetBundleNames();
        foreach (string ab in abs)
            AssetDatabase.RemoveAssetBundleName(ab, true);
    }
}