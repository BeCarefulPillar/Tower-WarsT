using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections.Generic;

public class JW_AssetTree : EditorWindow
{
    private const string RES_DATA_DIR = "Assets/Resources/Data/";
    private const string ASSET_TREE_PATH = RES_DATA_DIR + AssetName.RES_TREE + ".asset";

    private AssetTree mTree;
    private string mBrowsePath;
    private string mSearchWord;
    private int mAsyncLoadSize = 655360;
    private List<SerializedProperty> mShowAsset = new List<SerializedProperty>(32);

    private Vector3 mScrollPos = Vector3.zero;

    private void OnEnable()
    {
        titleContent.text = "资源树";
        minSize = new Vector2(420f, 512f);
        mBrowsePath = null;
        mSearchWord = null;
        mAsyncLoadSize = JW_Setting.asyncLoadSize;
        mTree = AssetDatabase.LoadAssetAtPath<AssetTree>(ASSET_TREE_PATH);
    }

    private void OnDisable()
    {
        JW_Setting.asyncLoadSize = mAsyncLoadSize;
        mBrowsePath = null;
        mShowAsset.Clear();
    }

    private void OnGUI()
    {
        //EditorGUILayout.HelpBox("", MessageType.Info);

        if (!mTree)
        {
            if (GUILayout.Button("创建资源树\n" + ASSET_TREE_PATH, GUILayout.Height(48)))
            {
                mTree = ScriptableObject.CreateInstance<AssetTree>();
                if (mTree)
                {
                    if (!Directory.Exists(RES_DATA_DIR)) Directory.CreateDirectory(RES_DATA_DIR);
                    AssetDatabase.CreateAsset(mTree, ASSET_TREE_PATH);
                }
                else
                {
                    EditorUtility.DisplayDialog("资源树", "资源树创建失败", "确定");
                    return;
                }
            }
            else
            {
                return;
            }
        }

        SerializedObject so = new SerializedObject(mTree);

        EditorGUIUtility.labelWidth = 80f;
        EditorGUILayout.ObjectField(so.FindProperty("defaultTexture"), new GUIContent("默认图片:"), GUILayout.Width(400));
        EditorGUILayout.ObjectField(so.FindProperty("defaultAvatar"), new GUIContent("默认头像:"), GUILayout.Width(400));
        EditorGUILayout.ObjectField(so.FindProperty("loadingTexture"), new GUIContent("加载图片:"), GUILayout.Width(400));
        EditorGUILayout.ObjectField(so.FindProperty("mainAtlas"), new GUIContent("主图集:"), GUILayout.Width(400));
        EditorGUILayout.ObjectField(so.FindProperty("mainFont"), new GUIContent("主字体:"), GUILayout.Width(400));
        EditorGUILayout.ObjectField(so.FindProperty("commonShader"), new GUIContent("通用着色器:"), GUILayout.Width(400));

        so.ApplyModifiedProperties();

        JWEditorTools.DrawSepLine(1f, 3f);
        EditorGUILayout.BeginHorizontal();
        mAsyncLoadSize = EditorGUILayout.IntField("异步加载大小:", mAsyncLoadSize, GUILayout.Width(300));
        EditorGUILayout.LabelField(" ("+AssetManager.GetMemoryStr(mAsyncLoadSize) +")");
        EditorGUILayout.EndHorizontal();
        EditorGUIUtility.labelWidth = 0f;

        JWEditorTools.DrawSepLine(3f, 2f);

        SerializedProperty sp;
        SerializedProperty spPath = so.FindProperty("paths");
        SerializedProperty spList = so.FindProperty("assetList");

        #region 资源树更新
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("更新资源树", GUILayout.Height(32)))
        {
            if (spPath == null || !spPath.isArray)
            {
                Debug.LogWarning("can not find AssetTree property [paths]!!!");
                return;
            }

            if (spList == null || !spList.isArray)
            {
                Debug.LogWarning("can not find AssetTree property [assetList]!!!");
                return;
            }

            spPath.ClearArray();
            HashSet<string> async = new HashSet<string>();
            if (spList.arraySize > 0)
            {
                for (int i = 0; i < spList.arraySize; i++)
                {
                    sp = spList.GetArrayElementAtIndex(i);
                    if (sp == null || !sp.FindPropertyRelative("needAsyncLoad").boolValue) continue;
                    async.Add(sp.FindPropertyRelative("name").stringValue);
                }
            }
            spList.ClearArray();

            EditorUtility.DisplayProgressBar("载入Resources资源", "", 0f);

            Object[] assets = Resources.LoadAll(string.Empty);
            if (assets == null || assets.Length <= 0)
            {
                so.ApplyModifiedProperties();
                EditorUtility.SetDirty(mTree);
                Debug.LogWarning("can not find anly assset int Resources folder!!!");
                EditorUtility.DisplayDialog("资源树创建完成", "项目中没有任何内部资源", "确定");
                EditorUtility.ClearProgressBar();
                return;
            }

            float qty = assets.Length;
            int cnt = 0;
            int idx = 0;
            string dir;
            AssetMeta am;
            List<string> paths = new List<string>(32) { string.Empty };
            Dictionary<string, AssetMeta> assetDics = new Dictionary<string, AssetMeta>(32);

            foreach (Object asset in assets)
            {
                dir = AssetDatabase.GetAssetPath(asset).Replace('\\', '/');

                EditorUtility.DisplayProgressBar("正在搜索", dir, (cnt++) / qty);

                idx = dir.LastIndexOf("/Resources/");
                if (idx < 0)
                {
                    Debug.Log("un resources folder : " + dir);
                    continue;
                }
                dir = dir.Substring(idx + 11);
                idx = dir.LastIndexOf("/");
                if (idx < 0)
                {
                    idx = 0;
                }
                else
                {
                    dir = dir.Substring(0, idx + 1);
                    idx = paths.IndexOf(dir);
                    if (idx < 0)
                    {
                        idx = paths.Count;
                        paths.Add(dir);
                    }
                }

                if (!assetDics.TryGetValue(asset.name, out am) || am == null)
                {
                    am = new AssetMeta();
                    am.name = asset.name;
                    am.path = idx;
                    assetDics[am.name] = am;
                }
                else if (am.path != idx)
                {
                    Debug.LogWarning("asset [" + AssetDatabase.GetAssetPath(asset) + "] duplicate with [" + paths[idx] + am.name + "]");
                    continue;
                }
                else
                {
                    Debug.Log("asset same path : " + AssetDatabase.GetAssetPath(asset));
                }
                am.size += UnityEngine.Profiling.Profiler.GetRuntimeMemorySize(asset);
            }

            Resources.UnloadUnusedAssets();

            // 写入路径
            spPath.arraySize = paths.Count;
            for (int i = 0; i < paths.Count; i++) spPath.GetArrayElementAtIndex(i).stringValue = paths[i];

            spList.arraySize = assetDics.Count;
            idx = 0;
            foreach (AssetMeta item in assetDics.Values)
            {
                sp = spList.GetArrayElementAtIndex(idx++);
                sp.FindPropertyRelative("name").stringValue = item.name;
                sp.FindPropertyRelative("path").intValue = item.path;
                sp.FindPropertyRelative("size").intValue = item.size;
                sp.FindPropertyRelative("needAsyncLoad").boolValue = item.size > mAsyncLoadSize || async.Contains(item.name);
            }

            EditorUtility.ClearProgressBar();

            so.ApplyModifiedProperties();
            EditorUtility.SetDirty(mTree);

            mBrowsePath = null;
            mShowAsset.Clear();

            EditorUtility.DisplayDialog("资源树创建完成", "资源:" + qty + "个\n元文件:" + assetDics.Count + "个\n目录:" + paths.Count + "个", "确定");
        }
        if (GUILayout.Button("清理资源树", GUILayout.Height(32)))
        {
            spList.ClearArray();
            spPath.ClearArray();
            mBrowsePath = null;
            mShowAsset.Clear();
            so.ApplyModifiedProperties();
            EditorUtility.SetDirty(mTree);
        }
        EditorGUILayout.EndHorizontal();
        #endregion

        JWEditorTools.DrawSepLine(3f, 1f);

        if (spPath == null || !spPath.isArray)
        {
            EditorGUILayout.HelpBox("can not find AssetTree property [mPaths]", MessageType.Info);
            return;
        }

        if (spList == null || !spList.isArray)
        {
            EditorGUILayout.HelpBox("can not find AssetTree property [mAssetList]", MessageType.Info);
            return;
        }

        EditorGUILayout.LabelField("资源树统计  目录:" + spPath.arraySize + "个  资源:" + spList.arraySize + "个");
        JWEditorTools.DrawSepLine(1f, 3f);
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("返回"))
        {
            mBrowsePath = null;
            mShowAsset.Clear();
        }
        GUILayout.Space(3f);
        EditorGUIUtility.labelWidth = 42f;
        mSearchWord = EditorGUILayout.TextField("关键字", mSearchWord, GUILayout.Width(200));
        EditorGUIUtility.labelWidth = 0f;
        if (GUILayout.Button("搜索") && !string.IsNullOrEmpty(mSearchWord))
        {
            mBrowsePath = null;
            mShowAsset.Clear();
            if (mSearchWord.StartsWith("size:", true, null) && mSearchWord.Length > 5)
            {
                int size = 0;
                int eql = 0;
                if ('>' == mSearchWord[5])
                {
                    if (mSearchWord.Length > 6 && '=' == mSearchWord[6])
                    {
                        eql = int.TryParse(mSearchWord.Substring(7), out size) ? 2 : -1;
                    }
                    else
                    {
                        eql = int.TryParse(mSearchWord.Substring(6), out size) ? 1 : -1;
                    }
                }
                else if ('<' == mSearchWord[5])
                {
                    if (mSearchWord.Length > 6 && '=' == mSearchWord[6])
                    {
                        eql = int.TryParse(mSearchWord.Substring(7), out size) ? 4 : -1;
                    }
                    else
                    {
                        eql = int.TryParse(mSearchWord.Substring(6), out size) ? 3 : -1;
                    }
                }
                else
                {
                    eql = int.TryParse(mSearchWord.Substring(5), out size) ? 0 : -1;
                }

                if (eql < 0)
                {
                    Debug.LogWarning("search size format error, size search must like[size:>1,size:>=1,size:<1,size:<=1,size:=1]");
                }
                else
                {
                    int val = 0;

                    for (int j = 0; j < spList.arraySize; j++)
                    {
                        sp = spList.GetArrayElementAtIndex(j);
                        if (sp == null) continue;
                        val = sp.FindPropertyRelative("size").intValue;
                        switch (eql)
                        {
                            case 1: if (val > size) break; continue;
                            case 2: if (val >= size) break; continue;
                            case 3: if (val < size) break; continue;
                            case 4: if (val <= size) break; continue;
                            default: if (val == size) break; continue;
                        }
                        mShowAsset.Add(sp);
                    }
                }
            }
            else
            {
                for (int j = 0; j < spList.arraySize; j++)
                {
                    sp = spList.GetArrayElementAtIndex(j);
                    if (sp == null) continue;
                    if (sp.FindPropertyRelative("name").stringValue.Contains(mSearchWord))
                    {
                        mShowAsset.Add(sp);
                    }
                }
            }
            if (mShowAsset.Count < 1) mShowAsset.Add(null);
        }
        EditorGUILayout.EndHorizontal();

        JWEditorTools.DrawSepLine(1f, 3f);
        if (mShowAsset.Count > 0)
        {
            // 浏览资源
            if (!string.IsNullOrEmpty(mBrowsePath))
            {
                EditorGUILayout.LabelField("浏览资源[" + mBrowsePath + "]:");
                GUILayout.Space(3f);
            }
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("资源名称", GUILayout.Width(64));
            GUILayout.Space(3f);
            EditorGUILayout.LabelField("资源路径", GUILayout.Width(160));
            GUILayout.Space(3f);
            EditorGUILayout.LabelField("资源大小", GUILayout.Width(64));
            GUILayout.Space(3f);
            EditorGUILayout.LabelField("异步", GUILayout.Width(64));
            EditorGUILayout.EndHorizontal();
            JWEditorTools.DrawSepLine(1f, 2f);

            int path;
            bool async = false;
            mScrollPos = EditorGUILayout.BeginScrollView(mScrollPos, false, false);
            foreach (SerializedProperty item in mShowAsset)
            {
                if (item == null) continue;
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField(item.FindPropertyRelative("name").stringValue, GUILayout.Width(64));
                GUILayout.Space(3f);
                path = item.FindPropertyRelative("path").intValue;
                EditorGUILayout.LabelField(path > 0 ? mTree.GetPath(path) : "/", GUILayout.Width(160));
                GUILayout.Space(3f);
                EditorGUILayout.LabelField(AssetManager.GetMemoryStr(item.FindPropertyRelative("size").intValue), GUILayout.Width(64));
                GUILayout.Space(3f);
                sp = item.FindPropertyRelative("needAsyncLoad");
                async = EditorGUILayout.Toggle("", sp.boolValue, GUILayout.Width(64));
                if (async != sp.boolValue)
                {
                    sp.boolValue = async;
                    sp.serializedObject.ApplyModifiedProperties();
                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndScrollView();
        }
        else
        {
            // 浏览目录
            EditorGUILayout.LabelField("浏览资源树目录:");
            GUILayout.Space(3f);
            string path;
            mScrollPos = EditorGUILayout.BeginScrollView(mScrollPos, false, false);
            for (int i = 0; i < spPath.arraySize; i++)
            {
                path = spPath.GetArrayElementAtIndex(i).stringValue;
                if (string.IsNullOrEmpty(path)) path = "根目录";
                if (GUILayout.Button(path))
                {
                    mBrowsePath = path;
                    mShowAsset.Clear();
                    for (int j = 0; j < spList.arraySize; j++)
                    {
                        sp = spList.GetArrayElementAtIndex(j);
                        if (sp != null && sp.FindPropertyRelative("path").intValue == i)
                        {
                            mShowAsset.Add(sp);
                        }
                    }
                    if (mShowAsset.Count < 1) mShowAsset.Add(null);
                }
                GUILayout.Space(3f);
            }
            EditorGUILayout.EndScrollView();
        }
    }
}