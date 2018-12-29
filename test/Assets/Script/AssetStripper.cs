using System.Reflection;
using UnityEngine;
using System;
using Object = UnityEngine.Object;

public class AssetStripper : UMonoBehaviour
{
    [Serializable]
    public class RefRes
    {
        public Object target;
        public string fieldPath;
        public string resPath;

        public RefRes(Object _target,string _fieldPath, string _resPath)
        {
            target = _target;
            fieldPath = _fieldPath;
            resPath = _resPath;
        }

        public void Restore()
        {
            if (!target || string.IsNullOrEmpty(fieldPath) || string.IsNullOrEmpty(resPath))
                return;
            string[] paths = fieldPath.Split('.');
            if (paths.Length > 1)
            {
                object val = target;
                object obj = null;
                FieldInfo fi = null;
                int arrIdx = -1;
                for (int i = 0; i < paths.Length; i++)
                {
                    obj = val;
                    if (obj == null)
                    {
                        Debug.LogWarning(string.Format("AssetPacker Restore {0}[{1}] error :obj[{2}] is null", target, fieldPath, i));
                        return;
                    }
                    if (obj is Array)
                    {
                        try
                        {
                            fi = null;
                            arrIdx = int.Parse(paths[i]);
                            val = (obj as Array).GetValue(arrIdx);
                        }
                        catch (Exception e)
                        {
                            Debug.LogWarning(string.Format("AssetPacker Restore {0}[{1}] error[{2}] :{3}", target, fieldPath, i, e));
                            return;
                        }
                    }
                    else
                    {
                        arrIdx = -1;
                        fi = obj.GetType().GetField(paths[i],
                            BindingFlags.GetField |
                            BindingFlags.SetField |
                            BindingFlags.Public |
                            BindingFlags.NonPublic |
                            BindingFlags.Instance |
                            BindingFlags.Static);
                        if (fi == null)
                        {
                            Debug.LogWarning(string.Format("AssetPacker Restore {0}[{1}] error :can not get FieldInfo[{2}]", target, fieldPath, i));
                            return;
                        }
                        val = fi.GetValue(obj);
                    }
                }

                if (val as Object)
                {
                    Debug.LogWarning(string.Format("AssetPacker Restore Warning : val was exist " + val));
                }
                else
                {
                    try
                    {
                        val = Resources.Load(resPath, obj is Array ? obj.GetType().GetElementType() : fi.FieldType);

                        if (val == null)
                        {
                            Debug.Log(resPath);
                            AssetBundle ab = AssetBundle.LoadFromFile("c:/test/" + resPath + ".unity3d");
                            if (ab != null)
                            {
                                fi.SetValue(obj, ab.LoadAsset(resPath));
                            }
                            //AssetManager.LoadAssetAsync(Kiol.IO.Path.GetFileNameWithoutExtension(resPath), a =>
                            //{
                            //    if (obj is Array)
                            //    {
                            //        (obj as Array).SetValue(a.GetAsset(obj.GetType().GetElementType()), arrIdx);
                            //    }
                            //    else
                            //    {
                            //        fi.SetValue(obj, a.GetAsset(fi.FieldType));
                            //    }
                            //});
                        }
                        else if (obj is Array)
                        {
                            (obj as Array).SetValue(val, arrIdx);
                        }
                        else
                        {
                            fi.SetValue(obj, val);
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.Log(e);
                    }
                }
            }
            else
            {
                FieldInfo fi = target.GetType().GetField(fieldPath,
                    BindingFlags.GetField |
                    BindingFlags.SetField |
                    BindingFlags.Public |
                    BindingFlags.NonPublic |
                    BindingFlags.Instance |
                    BindingFlags.Static);
                if (fi == null)
                {
                    Debug.LogWarning(string.Format("AssetPacker Restore {0}[{1}] error :can not get FieldInfo", target, fieldPath));
                    return;
                }
                try
                {

                    AssetBundle ab = AssetBundle.LoadFromFile("c:/test/" + resPath + ".unity3d");
                    if (ab != null)
                    {
                        fi.SetValue(target, ab.LoadAsset(resPath));
                    }
                }
                catch (Exception e)
                {
                    Debug.Log(e);
                }
            }
        }
    }

    public RefRes[] mRefs;

    private void Awake()
    {
        if (mRefs != null)
        {
            for (int i = 0; i < mRefs.Length; ++i)
                mRefs[i].Restore();
        }
    }
}