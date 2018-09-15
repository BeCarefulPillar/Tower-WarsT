using UnityEditor;
using UnityEngine;
using System.IO;
using Kiol.Util;
using Kiol.Json;

public class JW_Setting : EditorWindow
{
    private const string RES_DATA_DIR = "Assets/Resources/Data/";
    private const string RES_EDITOR_DATA_DIR = "Assets/ResEditor/Data/";
    private const string SRC_URL_PATH = RES_DATA_DIR + AssetName.SRC_URL + ".bytes";
    private const string SRC_URL_ALL_PATH = RES_EDITOR_DATA_DIR + AssetName.SRC_URL + "_all.bytes";

    private readonly string[] mOption = new string[3] { "URL配置", "Build配置", "编辑器配置" };

    private int mCurOpt = 0;
    private JsonObject mSrcUrl = null;
    private JsonObject mSrcUrlAll = null;

    private Vector3 mScrollPos = Vector3.zero;

    void OnEnable()
    {
        titleContent.text = "参数配置";
        minSize = new Vector2(440f, 512f);
        mSrcUrl = null;
        mSrcUrlAll = null;
    }
    void OnDisable()
    {
        mSrcUrl = null;
        mSrcUrlAll = null;
    }

    private void OnGUI()
    {
        //功能项布局
        mCurOpt = GUILayout.SelectionGrid(mCurOpt, mOption, 4);
        if (mCurOpt == 0)
        {
            DrawGameParm();
        }
        else if (mCurOpt == 1)
        {
            DrawGameBuild();
        }
        else if (mCurOpt == 2)
        {
            DrawEditorParam();
        }
    }

    private void DrawGameParm()
    {
        if (mSrcUrl == null)
        {
            if (File.Exists(SRC_URL_PATH))
            {
                mSrcUrl = new JsonObject(Encryption.DecompressStr(File.ReadAllBytes(SRC_URL_PATH), Encryption.DEFAULT_ENCRYPT_SKIP));
            }
            else
            {
                mSrcUrl = new JsonObject("{}");
            }
        }
        if (mSrcUrlAll == null)
        {
            if (File.Exists(SRC_URL_ALL_PATH))
            {
                mSrcUrlAll = new JsonObject(Encryption.DecompressStr(File.ReadAllBytes(SRC_URL_ALL_PATH), Encryption.DEFAULT_ENCRYPT_SKIP));
            }
            else
            {
                mSrcUrlAll = new JsonObject("{}");
            }
        }

        string str;
        JsonObject jo;
        JsonObject joChild;

        mScrollPos = EditorGUILayout.BeginScrollView(mScrollPos, false, false);

        EditorGUILayout.LabelField("当前包地址:");
        for (int i = 0; i < mSrcUrl.childCount; i++)
        {
            jo = mSrcUrl[i];
            if (jo.type == JsonObject.Type.String)
            {
                EditorGUILayout.BeginHorizontal();
                str = EditorGUILayout.TextField(jo.value);
                if (str.StartsWith("http://") || str.StartsWith("https://"))
                {
                    jo.value = str;
                }
                if (GUILayout.Button("x", GUILayout.Width(20)))
                {
                    mSrcUrl.RemoveChild(i--);
                }
                EditorGUILayout.EndHorizontal();
                GUILayout.Space(3);
            }
            else if (jo.type != JsonObject.Type.Array)
            {
                mSrcUrl.RemoveChild(i--);
            }
        }
        if (GUILayout.Button("添加")) mSrcUrl.AddChild(null, "http://", JsonObject.Type.String);

        JWEditorTools.DrawSepLine(1f, 3f);

        // 分类地址
        for (int i = 0; i < mSrcUrlAll.childCount; i++)
        {
            jo = mSrcUrlAll[i];
            if (jo.type == JsonObject.Type.Array)
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("x", GUILayout.Width(20)))
                {
                    mSrcUrlAll.RemoveChild(i--);
                    continue;
                }
                EditorGUIUtility.labelWidth = 54f;
                str = EditorGUILayout.TextField("分类地址:", jo.name);
                EditorGUIUtility.labelWidth = 0f;
                if (!string.IsNullOrEmpty(str)) jo.name = str;
                EditorGUILayout.EndHorizontal();


                for (int j = 0; j < jo.childCount; j++)
                {
                    joChild = jo[j];
                    if (joChild.type == JsonObject.Type.String)
                    {
                        joChild.name = string.Empty;
                        EditorGUILayout.BeginHorizontal();
                        str = EditorGUILayout.TextField(joChild.value);
                        if (str.StartsWith("http://") || str.StartsWith("https://"))
                        {
                            joChild.value = str;
                        }
                        if (GUILayout.Button("x", GUILayout.Width(20)))
                        {
                            jo.RemoveChild(j--);
                        }
                        EditorGUILayout.EndHorizontal();
                        GUILayout.Space(3);
                    }
                    else
                    {
                        jo.RemoveChild(j--);
                    }
                }

                if (GUILayout.Button("添加")) jo.AddChild(null, "http://", JsonObject.Type.String);
            }
        }

        EditorGUILayout.BeginHorizontal();

        if (GUILayout.Button("添加分类", GUILayout.Width(135), GUILayout.Height(32)))
        {
            mSrcUrlAll.AddChild("New" + mSrcUrlAll.childCount, null, JsonObject.Type.Array);
        }
        if (GUILayout.Button("保存", GUILayout.Width(135), GUILayout.Height(32)))
        {
            if (!Directory.Exists(RES_DATA_DIR)) Directory.CreateDirectory(RES_DATA_DIR);
            File.WriteAllBytes(SRC_URL_PATH, Encryption.Compress(mSrcUrl.ToString(), Encryption.DEFAULT_ENCRYPT_SKIP));
            if (!Directory.Exists(RES_EDITOR_DATA_DIR)) Directory.CreateDirectory(RES_EDITOR_DATA_DIR);
            File.WriteAllBytes(SRC_URL_ALL_PATH, Encryption.Compress(mSrcUrlAll.ToString(), Encryption.DEFAULT_ENCRYPT_SKIP));
        }
        if (GUILayout.Button("恢复", GUILayout.Width(135), GUILayout.Height(32)))
        {
            mSrcUrl = null;
            mSrcUrlAll = null;
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.EndScrollView();
    }

    private void DrawGameBuild()
    {
        EditorGUILayout.BeginHorizontal();

        if (GUILayout.Button("测试模式-开启", GUILayout.Width(135), GUILayout.Height(32)))
        {
            EditorUtility.DisplayProgressBar("正在配置测试模式", "", 0f);
            JWEditorTools.AddScriptingDefineSymbols("TEST");
            if (File.Exists(SRC_URL_ALL_PATH))
            {
                if (!Directory.Exists(RES_DATA_DIR)) Directory.CreateDirectory(RES_DATA_DIR);
                string path = RES_DATA_DIR + AssetName.SRC_URL + "_all.bytes";
                if (File.Exists(path)) File.Delete(path);
                File.Copy(SRC_URL_ALL_PATH, path);
            }
            EditorUtility.ClearProgressBar();
        }
        if (GUILayout.Button("测试模式-关闭", GUILayout.Width(135), GUILayout.Height(32)))
        {
            EditorUtility.DisplayProgressBar("正在移除测试模式", "", 0f);
            JWEditorTools.RemoveScriptingDefineSymbols("TEST");
            string path = RES_DATA_DIR + AssetName.SRC_URL + "_all.bytes";
            if (File.Exists(path)) File.Delete(path);
            EditorUtility.ClearProgressBar();
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DrawEditorParam()
    {
        EditorGUIUtility.labelWidth = 80f;
        luaDir = EditorGUILayout.TextField("Lua目录:", luaDir);
        EditorGUIUtility.labelWidth = 0f;
    }

    public static string luaDir
    {
        get
        {
            string dir = EditorPrefs.GetString("LUA DIR", Application.dataPath + "/ToLua/Lua");
            return string.IsNullOrEmpty(dir) ? Application.dataPath + "/ToLua/Lua" : dir;
        }
        set
        {
            EditorPrefs.SetString("LUA DIR", string.IsNullOrEmpty(value) ? Application.dataPath + "/ToLua/Lua" : value);
        }
    }

    public static int asyncLoadSize
    {
        get
        {
            return EditorPrefs.GetInt("asyncLoadSize", 655360);
        }
        set
        {
            EditorPrefs.SetInt("asyncLoadSize", value > 0 ? value : 655360);
        }
    }
}
