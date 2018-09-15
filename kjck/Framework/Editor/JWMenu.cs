using UnityEditor;
using UnityEngine;
using System.Collections;

public static class JWMenu
{
    [MenuItem("JOYGM-Q/标准压缩纹理(透明)")]
    public static void QuickApplyTexCAImp()
    {
        QuickApplyTexImp(true, true, false);
    }
    [MenuItem("JOYGM-Q/标准压缩纹理(不透明)")]
    public static void QuickApplyTexCImp()
    {
        QuickApplyTexImp(true, false, false);
    }
    [MenuItem("JOYGM-Q/真彩可写纹理")]
    public static void QuickApplyTexAImp()
    {
        QuickApplyTexImp(false, true, true);
    }



    private static void QuickApplyTexImp(bool compress, bool hasAlpha, bool readable)
    {
        Object[] objs = Selection.objects;
        if (objs.GetLength() > 0)
        {
            foreach (Object obj in objs)
            {
                if (obj is Texture2D)
                {
                    string texPath = AssetDatabase.GetAssetPath(obj);
                    if (string.IsNullOrEmpty(texPath)) continue;
                    if (compress)
                    {
                        AssetEditorTools.TextureCompressImport(texPath, hasAlpha, readable);
                    }
                    else
                    {
                        AssetEditorTools.TextureTrueImport(texPath, hasAlpha, readable);
                    }
                }
            }
        }
    }

    [MenuItem("JOYGM-Q/标准音效配置")]
    public static void QuickSOESet()
    {
        Object[] objs = Selection.objects;
        if (objs.GetLength() > 0)
        {
            foreach (Object obj in objs)
            {
                if (obj is AudioClip)
                {
                    string texPath = AssetDatabase.GetAssetPath(obj);
                    if (string.IsNullOrEmpty(texPath)) continue;
                    AudioImporter ai = AudioImporter.GetAtPath(texPath) as AudioImporter;

                    AudioImporterSampleSettings aiss = ai.defaultSampleSettings;
                    aiss.loadType = AudioClipLoadType.CompressedInMemory;
                    aiss.sampleRateOverride = 128000;
                    ai.defaultSampleSettings = aiss;

                    AssetDatabase.ImportAsset(texPath, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
                }
            }
        }
    }

    [MenuItem("JOYGM-Q/加密Lua文件")]
    public static void QuickEncLua()
    {
        Object[] objs = Selection.objects;
        if (objs.GetLength() > 0)
        {
            foreach (Object obj in objs)
            {
                string path = AssetDatabase.GetAssetPath(obj);
                if (path.EndsWith(".lua"))
                {
                    try
                    {
                        System.IO.File.WriteAllBytes(path.Substring(0, path.Length - 3) + "bytes",
                        Kiol.Util.Encryption.Compress(AssetEditorTools.TrimLua(path), Kiol.Util.Encryption.DEFAULT_ENCRYPT_SKIP));
                        AssetDatabase.ImportAsset(path.Substring(0, path.Length - 3) + "bytes");
                    }
                    catch (System.Exception e)
                    {
                        Debug.LogWarning(e);
                    }
                }
            }
        }
    }

    //取得要创建文件的路径  
    public static string GetSelectPathOrFallback()
    {
        string path = "Assets";
        //遍历选中的资源以获得路径  
        //Selection.GetFiltered是过滤选择文件或文件夹下的物体，assets表示只返回选择对象本身  
        foreach (Object obj in Selection.GetFiltered(typeof(Object), SelectionMode.Assets))
        {
            path = AssetDatabase.GetAssetPath(obj);
            if (!string.IsNullOrEmpty(path) && System.IO.File.Exists(path))
            {
                path = System.IO.Path.GetDirectoryName(path);
                break;
            }
        }
        return path;
    }

    [MenuItem("Assets/Create/Lua Script", false, 82)]
    public static void CreateLua()
    {
        //将设置焦点到某文件并进入重命名  
        ProjectWindowUtil.StartNameEditingIfProjectWindowExists(0,
            ScriptableObject.CreateInstance<CreateLuaScriptAsset>(),
            GetSelectPathOrFallback() + "/New Lua.lua", null,
            "Assets/Framework/Editor/LuaClass.lua");
    }
}