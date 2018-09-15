using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections.Generic;
using Kiol.Util;

public class JW_AssetAdjust : EditorWindow
{
    private int _curOption = 0;
    private string[] _option = new string[3] { "图集复制", "配置字体", "其它功能" };
    private string[] _intro = new string[3]
    {
        "将from图集的sprite数据配置到to图集",
        "将选中的GameObject及其子级的所有UILabel的trueFont设置成指定的Font",
        "小功能"
    };
    private Object[] _selectObjs;

    private UIAtlas _fromAtlas;
    private UIAtlas _toAtlas;

    private Font _font;

    void OnEnable()
    {
        titleContent.text = "资源调整器";
        minSize = new Vector2(420f, 512f);
        _font = Resources.Load<Font>("Font/font_default");
        SetSelectObjs(Selection.objects);
    }
    void OnDisable() { }

    void OnSelectionChange() { SetSelectObjs(Selection.objects); }

    void OnGUI()
    {
        _curOption = GUILayout.SelectionGrid(_curOption, _option, 4);
        if (_intro.IndexAvailable(_curOption)) EditorGUILayout.HelpBox(_intro[_curOption], MessageType.Info);
        JWEditorTools.DrawSepLine(3f, 2f);

        if (_curOption == 0)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUIUtility.labelWidth = 50f;
            UIAtlas fromAtlas = EditorGUILayout.ObjectField("源图集", _fromAtlas, typeof(UIAtlas), true, GUILayout.Width(160f)) as UIAtlas;
            if (fromAtlas == null || fromAtlas != _toAtlas) _fromAtlas = fromAtlas;
            UIAtlas toAtlas = EditorGUILayout.ObjectField("目标图集", _toAtlas, typeof(UIAtlas), true, GUILayout.Width(160f)) as UIAtlas;
            if (toAtlas == null || toAtlas != _fromAtlas) _toAtlas = toAtlas;
            if (_fromAtlas && _toAtlas)
            {
                if (GUILayout.Button("配置", GUILayout.Width(80f)))
                {
                    _toAtlas.spriteList = _fromAtlas.spriteList;
                    //UISpriteData[] data = _fromAtlas.spriteList.ToArray();
                    //for (int i = 0; i < data.Length; i++)
                    //{
                    //    UISpriteData sd = _toAtlas.GetSprite(data[i].name);
                    //    if (sd != null)
                    //    {
                    //        sd.SetBorder(data[i].borderLeft, data[i].borderBottom, data[i].borderRight, data[i].borderTop);
                    //    }
                    //}
                }
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Separator();

            EditorGUILayout.BeginHorizontal();
            UIAtlas select = EditorGUILayout.ObjectField("当前选择", (Selection.activeGameObject ? Selection.activeGameObject.GetComponent<UIAtlas>() : null), typeof(UIAtlas), true, GUILayout.Width(160f)) as UIAtlas;
            EditorGUIUtility.labelWidth = 0;
            if (select)
            {
                if (select != _fromAtlas && select != _toAtlas && GUILayout.Button("配到源图集", GUILayout.Width(100f)))
                {
                    _fromAtlas = select;
                }
                if (select != _fromAtlas && select != _toAtlas && GUILayout.Button("配到目标图集", GUILayout.Width(100f)))
                {
                    _toAtlas = select;
                }
            }
            EditorGUILayout.EndHorizontal();
        }
        else if (_curOption == 1)
        {
            EditorGUIUtility.labelWidth = 50f;
            _font = EditorGUILayout.ObjectField("字体", _font, typeof(Font), false, GUILayout.Width(160f)) as Font;
            EditorGUILayout.Separator();
            if (_font)
            {
                EditorGUILayout.BeginHorizontal();

                EditorGUILayout.ObjectField("目标", Selection.activeGameObject, typeof(GameObject), false, GUILayout.Width(160f));
                if (Selection.activeGameObject && GUILayout.Button("配置", GUILayout.Width(80f)))
                {
                    UILabel[] labs = Selection.activeGameObject.GetComponentsInAllChild<UILabel>();
                    for (int i = 0; i < labs.Length; i++)
                    {
                        if (labs[i] && !labs[i].trueTypeFont)
                        {
                            labs[i].trueTypeFont = _font;
                        }
                    }
                }

                EditorGUILayout.EndHorizontal();
            }
            else
            {
                EditorGUILayout.HelpBox("请先选择字体", MessageType.Info);
            }
        }
        else if (_curOption == 2)
        {
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("统计当前项目代码", GUILayout.Width(135), GUILayout.Height(32)))
            {
                AssetEditorTools.CountCodeLine();
            }
            if (GUILayout.Button("更新Lua脚本", GUILayout.Width(135), GUILayout.Height(32)))
            {
                AssetEditorTools.UpdateLuaScript();
            }
            //if (GUILayout.Button("创建资源树", GUILayout.Width(135), GUILayout.Height(32)))
            //{
            //    AssetEditorTools.CreateAssetTree();
            //}
            GUILayout.EndHorizontal();
            if (GUILayout.Button("测试", GUILayout.Width(135), GUILayout.Height(32)))
            {
                if (Selection.activeGameObject)
                {
                    string[] dps = AssetDatabase.GetDependencies(AssetDatabase.GetAssetPath(Selection.activeGameObject));
                    foreach (var item in dps)
                    {
                        if (AssetDatabase.GetMainAssetTypeAtPath(item) == typeof(MonoScript)) continue;
                        Debug.Log(item);
                    }
                }
                
                //char c = (char)0xFEFF;
                //System.Action<Transform> aaa = null;
                //aaa = t =>
                //{
                //    if (t)
                //    {
                //        if (!t.GetComponent<BindSkillDepth>() && t.GetComponent<UIWidget>()) Debug.Log(t.name);
                //        if (t.childCount > 0)
                //        {
                //            for (int i = 0; i < t.childCount; i++)
                //            {
                //                aaa(t.GetChild(i));
                //            }
                //        }
                //    }
                //};

                //GameObject go = Selection.activeGameObject;
                //if (go)
                //{
                //    aaa(go.transform);
                //}

                //Debug.Log(System.Convert.ToBase64String(Resources.Load<TextAsset>("Lineup/lu_d_1").bytes));

                //string m = "UPDATE tb_lineup SET pos_data=CHAR({0}) WHERE lsn={1};";
                //string m = "UPDATE tb_lineup SET pos_data='{0}' WHERE lsn={1};";
                //string r = ""; 
                //for (int i = 1; i <=9; i++)
                //{
                //    byte[] d = Resources.Load<TextAsset>("Lineup/lu_d_"+i).bytes;
                //    byte[] cd = new byte[d.Length / 2];
                //    string ret = "";
                //    for (int j = 0; j < d.Length; j+=2)
                //    {
                //        cd[j / 2] = (byte)(d[j + 1] * BD_Const.BATTLE_HEIGHT + d[j]);
                //        ret += (d[j + 1] * BD_Const.BATTLE_HEIGHT + d[j]).ToString() + ",";
                //    }
                //    //r += string.Format(m, ret.Substring(0, ret.Length - 1), i) + "\n";
                //    //r += string.Format(m, System.Convert.ToBase64String(cd), i) + "\n";
                //    r += "new byte[100] { " + string.Join(", ", ByteConvert.ConvertArrType<string>(cd)) + " },\n";
                //    //Debug.Log("(" + i + "-->" + (ret.Split(',').Length - 1) + ")" + System.Convert.ToBase64String(cd));
                //}

                //Debug.Log(r);

                //Debug.Log(System.Guid.NewGuid().ToString().ToUpper());

                //byte[] data = Kiol.IO.File.ReadFile(@"C:\UnityProject\QYSGZ_2D\Assets\bak\95d8bddf026889149a95c16b31c981df");

                //string[] fs = System.IO.Directory.GetFiles("Assets/bak");
                //for (int i = 0; i < fs.Length; i++)
                //{
                //Texture2D tex = AssetDatabase.LoadAssetAtPath(fs[i], typeof(Texture2D)) as Texture2D;
                //if (tex)
                //{
                //    if (tex.format == TextureFormat.Alpha8 || tex.format == TextureFormat.RGB24 || tex.format == TextureFormat.RGBA32 || tex.format == TextureFormat.ARGB32)
                //    {
                //        Kiol.IO.File.WriteFile(string.Format(@"C:\Users\HeQuan\Desktop\4\{0}.png", tex.name), tex.EncodeToPNG());
                //    }
                //    else
                //    {
                //        Debug.Log(tex.name);
                //        Texture2D temp = new Texture2D(tex.width, tex.height, TextureFormat.RGBA32, false);
                //        temp.SetPixels32(tex.GetPixels32());
                //        temp.Apply();
                //        Kiol.IO.File.WriteFile(string.Format(@"C:\Users\HeQuan\Desktop\4\{0}.png", tex.name), temp.EncodeToPNG());
                //        DestroyImmediate(temp);
                //    }
                //}
                //}
            }
        }
    }

    private void SetSelectObjs(Object[] objs)
    {
        Repaint();
    }

    IEnumerable<int> TTT(bool sss)
    {
        if (sss)
        {
            for (int i = 0; i < 10; i++)
            {
                yield return i;
            }
        }
        else
        {
            for (int i = 11; i < 20; i++)
            {
                yield return i;
            }
        }
    }
}
