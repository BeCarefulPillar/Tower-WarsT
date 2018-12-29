using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections.Generic;

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
            if(pt!=PrefabType.Prefab)
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
                    Debug.Log(value + " - "+InvRes(value));
                    if (InvRes(value))
                    {
                        continue;
                    }
                    Debug.Log(" - " + path);
                    if (string.IsNullOrEmpty(path) || 
                        path.StartsWith("Library/") ||
                        path==goPath || 
                        AssetDatabase.LoadAssetAtPath<Object>(path)==null)
                        continue;
                    //if (path.IndexOf("/Resources/") < 0)
                        //continue;
                    Debug.Log("单独" + path);

                    list.Add(new AssetStripper.RefRes( mb, WrapPropertyPath(sp.propertyPath), Path.GetFileNameWithoutExtension(path) ));
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
            AssetDatabase.RemoveAssetBundleName(ab,true);
    }
}