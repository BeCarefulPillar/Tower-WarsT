using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Kiol.Util;

public class AssetEditorTools
{
    /// <summary>
    /// 计算代码行数
    /// </summary>
    public static void CountCodeLine()
    {
        int totalLine = 0;
        string[] ms = AssetDatabase.FindAssets("t:MonoScript");
        for (int i = 0; i < ms.Length; i++)
        {
            System.IO.StreamReader sr = null;
            try
            {
                string path = AssetDatabase.GUIDToAssetPath(ms[i]);
                EditorUtility.DisplayProgressBar("正在统计", path, (float)(i + 1) / (float)ms.Length);
                sr = new System.IO.StreamReader(path);
                while (!sr.EndOfStream)
                {
                    sr.ReadLine();
                    totalLine++;
                }
            }
            catch (System.Exception e)
            {
                Debug.Log(e);
            }
            finally
            {
                if (sr != null)
                {
                    sr.Dispose();
                    sr.Close();
                }
            }
        }
        EditorUtility.ClearProgressBar();

        EditorUtility.DisplayDialog("项目代码统计结果", "代码文件总数:" + ms.Length + "\n" + "代码总行数:" + totalLine, "确定");

        Debug.Log("代码文件总数:" + ms.Length);
        Debug.Log("代码总行数:" + totalLine);
    }
    /// <summary>
    /// 更新Lua脚本
    /// </summary>
    public static void UpdateLuaScript()
    {
        string asPath = "Assets/AssetBundles/Lua";
        string luaPath = "Assets/ToLua/Lua";
        string path;
        string[] files;

        if (Directory.Exists(asPath))
        {
            files = Directory.GetFiles(asPath, "*.dat", SearchOption.AllDirectories);
            for (int i = 0; i < files.Length; i++)
            {
                EditorUtility.DisplayProgressBar("正在清理", files[i], 0.1f * i / files.Length);
                File.Delete(files[i]);
                path = files[i] + ".meta";
                if (File.Exists(path)) File.Delete(path);
            }
            files = Directory.GetDirectories(asPath, string.Empty, SearchOption.AllDirectories);
            for (int i = 0; i < files.Length; i++) if (Directory.GetFiles(files[i]).Length <= 0) Directory.Delete(files[i]);
        }
        else
        {
            Directory.CreateDirectory(asPath);
        }

        files = Directory.GetFiles(luaPath, "*.lua", SearchOption.AllDirectories);
        for (int i = 0; i < files.Length; i++)
        {
            EditorUtility.DisplayProgressBar("正在压缩加密", files[i], 0.1f + 0.5f * i / files.Length);
            string newFile = Path.ChangeExtension(files[i].Replace('\\', '/').Replace(luaPath, asPath), ".dat");
            if (newFile.IndexOf("/Discard/") < 0)
            {
                if (!Directory.Exists(Path.GetDirectoryName(newFile))) Directory.CreateDirectory(Path.GetDirectoryName(newFile));
                //File.WriteAllBytes(newFile, Encryption.Compress(File.ReadAllBytes(files[i]), Encryption.DEFAULT_ENCRYPT_SKIP));
                File.WriteAllBytes(newFile, Encryption.Compress(TrimLua(files[i]), Encryption.DEFAULT_ENCRYPT_SKIP));
            }
        }

        // 清理Resources/Lua
        string resLuaPath = "Assets/Resources/Lua";
        if (Directory.Exists(resLuaPath))
        {
            files = Directory.GetFiles(resLuaPath, "*.bytes");
            for (int i = 0; i < files.Length; i++)
            {
                EditorUtility.DisplayProgressBar("正在清理", files[i], 0.6f + 0.1f * i / files.Length);
                File.Delete(files[i]);
                //path = files[i] + ".meta";
                //if (File.Exists(path)) File.Delete(path);
            }
        }
        else
        {
            Directory.CreateDirectory(resLuaPath);
        }
        // 到处加密Lua到Resources/Lua
        files = Directory.GetFiles(asPath, "*.dat", SearchOption.AllDirectories);
        for (int i = 0; i < files.Length; i++)
        {
            EditorUtility.DisplayProgressBar("正在压缩加密", files[i], 0.7f + 0.3f * i / files.Length);
            string newFile = files[i].Replace('\\', '/').Substring(files[i].IndexOf(asPath) + asPath.Length + 1);
            newFile = Path.Combine(resLuaPath, MD5.GetMd5String(newFile.Substring(0, newFile.Length - 4)));
            File.Copy(files[i], newFile + ".bytes");
        }
        EditorUtility.ClearProgressBar();

        EditorUtility.DisplayDialog("Lua更新完成", "脚本数:" + files.Length + "个", "确定");
    }

    public static byte[] TrimLua(string path)
    {
        using (FileStream reader = new FileStream(path, FileMode.Open, FileAccess.Read))
        {
            using (MemoryStream mes = new MemoryStream((int)reader.Length))
            {
                int b = 0;
                int str = 0;
                int cmt = 0;
                long lnidx = 0;
                int last = -1;
                while ((b = reader.ReadByte()) != -1)
                {
                    if (cmt == 0)
                    {
                        if (str == 0)
                        {
                            if (b == 10)
                            {
                                if (lnidx < 0)
                                {
                                    mes.WriteByte(10);
                                    lnidx = mes.Position;
                                }
                                else
                                {
                                    mes.Position = lnidx;
                                }
                                last = b;
                                continue;
                            }
                            if (b == 45) // -
                            {
                                if (last == 45)
                                {
                                    cmt = 1;
                                }
                                last = b;
                                continue;
                            }

                            if (last == 45)
                            {
                                lnidx = -1;
                                mes.WriteByte(45);
                            }

                            if (b < 32) // 空白
                            {
                                last = b;
                                continue;
                            }

                            if (b == 34 || b == 39) // " '
                            {
                                str = b;
                            }

                            if (b != 32) lnidx = -1;
                        }
                        else if (b == str)
                        {
                            str = 0;
                        }

                        mes.WriteByte((byte)b);
                    }
                    else if (cmt == 3)
                    {
                        if (last == 93 && b == 93) // ]
                        {
                            cmt = 0;
                        }
                    }
                    else if (b == 10) // \n
                    {
                        cmt = 0;

                        if (lnidx < 0)
                        {
                            mes.WriteByte(10);
                            lnidx = mes.Position;
                        }
                        else
                        {
                            mes.Position = lnidx;
                        }
                    }
                    else if (cmt == 1)
                    {
                        if (b != 91) // [
                        {
                            cmt = 2;
                        }
                        else if (last == 91) // [
                        {
                            cmt = 3;
                        }
                    }

                    last = b;
                }
                return mes.ToArray();
            }
        }
    }

    /// <summary>
    /// 纹理压缩设置
    /// </summary>
    /// <param name="texPath">纹理路径</param>
    /// <param name="hasAlpah">是否透明</param>
    /// <param name="readabel">是否可写</param>
    public static void TextureCompressImport(string texPath, bool hasAlpah, bool readabel = false)
    {
        TextureImporter ti = TextureImporter.GetAtPath(texPath) as TextureImporter;

        ti.isReadable = readabel;
        ti.mipmapEnabled = false;
        ti.npotScale = TextureImporterNPOTScale.ToNearest;
        ti.wrapMode = TextureWrapMode.Clamp;
        ti.anisoLevel = 4;

        TextureImporterPlatformSettings tips = ti.GetDefaultPlatformTextureSettings();
        tips.format = hasAlpah ? TextureImporterFormat.RGBA32 : TextureImporterFormat.RGB24;
        tips.maxTextureSize = ti.maxTextureSize;

        ti.SetPlatformTextureSettings(tips);

        tips.name = "Android";
        tips.format = hasAlpah ? TextureImporterFormat.ETC2_RGBA8 : TextureImporterFormat.ETC2_RGB4;
        ti.SetPlatformTextureSettings(tips);
        tips.name = "iPhone";
        tips.format = hasAlpah ? TextureImporterFormat.PVRTC_RGBA4 : TextureImporterFormat.PVRTC_RGB4;
        ti.SetPlatformTextureSettings(tips);

        AssetDatabase.ImportAsset(texPath, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
    }
    /// <summary>
    /// 纹理真彩设置
    /// </summary>
    /// <param name="texPath">纹理路径</param>
    /// <param name="hasAlpah">是否透明</param>
    /// <param name="readabel">是否可写</param>
    public static void TextureTrueImport(string texPath, bool hasAlpah, bool readabel = false)
    {
        TextureImporter ti = TextureImporter.GetAtPath(texPath) as TextureImporter;
        if (!ti) return;
        ti.isReadable = readabel;
        ti.mipmapEnabled = false;
        ti.npotScale = TextureImporterNPOTScale.None;
        ti.wrapMode = TextureWrapMode.Clamp;
        ti.anisoLevel = 4;

        TextureImporterPlatformSettings tips = ti.GetDefaultPlatformTextureSettings();
        tips.format = hasAlpah ? TextureImporterFormat.RGBA32 : TextureImporterFormat.RGB24;
        tips.maxTextureSize = ti.maxTextureSize;
        ti.SetPlatformTextureSettings(tips);

        if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.Android)
        {
            ti.ClearPlatformTextureSettings("Android");
        }
        else if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.iOS)
        {
            ti.ClearPlatformTextureSettings("iPhone");
        }

        AssetDatabase.ImportAsset(texPath, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
    }
    /// <summary>
    /// 纹理预乘Alpha
    /// </summary>
    public static void PremultipliedAlpha(Texture2D tex)
    {
        if (!tex) return;
        Color[] cols = tex.GetPixels();
        for (int i = 0; i < cols.Length; i++)
        {
            cols[i].r *= cols[i].a;
            cols[i].g *= cols[i].a;
            cols[i].b *= cols[i].a;
            cols[i].a = 1f;
        }
        tex.SetPixels(cols);
    }
}
