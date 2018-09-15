using System;
using System.Collections.Generic;
using UnityEngine;
using Kiol.Reflection;
using System.Reflection;
using Object = UnityEngine.Object;

public class AssetStripper : MonoBehaviour
{
    [Serializable]
    public class RefRes
    {
        [SerializeField] public Object target;
        [SerializeField] public string fieldPath;
        [SerializeField] public string resPath;

        public void Restore()
        {
            if (target && !string.IsNullOrEmpty(resPath) && !string.IsNullOrEmpty(fieldPath))
            {
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
                            fi = obj.GetType().GetTypeField(paths[i]);
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
                            if (AssetManager.mainAtlas && resPath.EndsWith(AssetManager.mainAtlas.name))
                            {
                                val = AssetManager.mainAtlas;
                            }
                            else if (AssetManager.mainFont && resPath.EndsWith(AssetManager.mainFont.name))
                            {
                                val = AssetManager.mainFont;
                            }
                            else
                            {
                                val = Resources.Load(resPath, obj is Array ? obj.GetType().GetElementType() : fi.FieldType);
                            }

                            if (val == null)
                            {
                                AssetManager.LoadAssetAsync(Kiol.IO.Path.GetFileNameWithoutExtension(resPath), a =>
                                {
                                    if (obj is Array)
                                    {
                                        (obj as Array).SetValue(a.GetAsset(obj.GetType().GetElementType()), arrIdx);
                                    }
                                    else
                                    {
                                        fi.SetValue(obj, a.GetAsset(fi.FieldType));
                                    }
                                });
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
                    FieldInfo fi = target.GetType().GetTypeField(fieldPath);
                    if (fi == null)
                    {
                        Debug.LogWarning(string.Format("AssetPacker Restore {0}[{1}] error :can not get FieldInfo", target, fieldPath));
                        return;
                    }
                    try
                    {
                        if (AssetManager.mainAtlas && resPath.EndsWith(AssetManager.mainAtlas.name))
                        {
                            fi.SetValue(target, AssetManager.mainAtlas);
                        }
                        else if (AssetManager.mainFont && resPath.EndsWith(AssetManager.mainFont.name))
                        {
                            fi.SetValue(target, AssetManager.mainFont);
                        }
                        else
                        {
                            fi.SetValue(target, Resources.Load(resPath, fi.FieldType));

                            if (fi.GetValue(target) == null)
                            {
                                AssetManager.LoadAssetAsync(Kiol.IO.Path.GetFileNameWithoutExtension(resPath), a => { fi.SetValue(target, a.GetAsset(fi.FieldType)); });
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.Log(e);
                    }
                }
            }
        }
    }

    [SerializeField] private RefRes[] mRef;

    private void Awake() { Restore(); }

    [ContextMenu("Restore")]
    public void Restore()
    {
        if (mRef != null)
        {
            for (int i = 0; i < mRef.Length; i++)
            {
                mRef[i].Restore();
            }
            mRef = null;
        }
        if (GetInstanceID() > 0) return;
#if UNITY_EDITOR
        if (!Application.isPlaying) return;
#endif
        Destroy(this);
    }

    public static void RestoreGo(GameObject go)
    {
        AssetStripper asp = go.GetComponent<AssetStripper>();
        if (asp) asp.Restore();
    }
}
