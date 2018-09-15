using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using System.Reflection;
using System.Collections.Generic;
using UnityEditor.SceneManagement;

public class JW_AssetSearcher : EditorWindow
{
    public class Entry
    {
        public string path;
        public Object obj;
    }
    public class TextEntry : Entry
    {
        public List<int> line = new List<int>();
        public string lineStr;
    }
    public class PropEntry : Entry
    {
        public List<string> props = new List<string>();
    }
    public class AssetEntry : Entry
    {
        public List<Object> objs = new List<Object>();
        //public List<System.Type> types = new List<System.Type>();
    }

    private int _curOption = 0;
    private string[] _option = new string[4] { "查找依赖", "查找引用", "查找文本", "其它功能" };
    private string[] _intro = new string[4]
    {
        "搜索选中对象（仅GameObject资源和场景）的所有依赖项，仅搜索资源依赖关系，不会搜索文本内容和序列化数据",
        "搜索引用/依赖选中对象的资源，搜索 文本和序列化数据字符串属性 精确匹配/包含匹配选中对象名称 的行号和属性路径",
        "搜索 文本和序列化数据字符串属性 精确匹配/包含匹配输入文本 的行号和属性路径\n例如:精确搜索SpriteName",
        ""
    };
    private string[] _ortherFunc = new string[2] { "查找Miss脚本", "查找简体字" };
    private string[] _ortherIntro = new string[2] 
    { 
        "查找序列化对象中的Miss脚本", 
        "查找文本和序列化数据中的简体字" 
    };

    private Object[] _selectObjs;
    private string _text;

    private bool _searchScene = true;

    private bool _flag = false;
    private List<AssetEntry> _assetEntry;
    private List<TextEntry> _codeEntry;
    private List<PropEntry> _propEntry;

    private Vector2 _scrollPos = Vector2.zero;

    private bool _showDetail = false;
    private bool _showScript = false;
    private bool _showInRes = false;

    void OnEnable()
    {
        titleContent.text = "资源搜索器";
        minSize = new Vector2(420f, 512f);
        _selectObjs = new Object[1];
        SetSelectObjs(Selection.objects);
    }
    void OnDisable() { }

    void OnSelectionChange() { SetSelectObjs(Selection.objects); }

    void OnGUI()
    {
        if (_flag)
        {
            GUILayout.SelectionGrid(_curOption, _option, 4);

            JWEditorTools.DrawSepLine(3f, 2f);

            if (_curOption == 0 || _curOption == 1)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("当前选择", GUILayout.Width(76f));
                if (GUILayout.Button("重置", GUILayout.Width(80f))) Reset();
                EditorGUILayout.EndHorizontal();

                JWEditorTools.DrawSepLine(1f, 2f);

                if (_selectObjs.GetLength() > 0)
                {
                    int line = Mathf.Max(1, Mathf.FloorToInt(position.width / 80f));
                    for (int i = 0; i < _selectObjs.Length; i++)
                    {
                        if (line > 1 && i % line == 0)
                        {
                            if (i > 0) EditorGUILayout.EndHorizontal();
                            EditorGUILayout.BeginHorizontal();
                        }
                        EditorGUILayout.ObjectField("", _selectObjs[i], typeof(Object), true, GUILayout.Width(80f));
                    }
                    if (line > 1) EditorGUILayout.EndHorizontal();
                }

                JWEditorTools.DrawSepLine(3f, 2f);

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("查找结果", GUILayout.Width(76f));
                EditorGUIUtility.labelWidth = 50f;
                if (_curOption == 0)
                {
                    _showDetail = EditorGUILayout.Toggle("显示详情", _showDetail, GUILayout.Width(80f));
                    _showScript = EditorGUILayout.Toggle("显示脚本", _showScript, GUILayout.Width(80f));
                }
                EditorGUIUtility.labelWidth = 72f;
                _showInRes = EditorGUILayout.Toggle("显示内部资源", _showInRes, GUILayout.Width(120f));
                EditorGUIUtility.labelWidth = 0f;
                EditorGUILayout.EndHorizontal();

                int an = _assetEntry != null ? _assetEntry.Count : 0;
                int cn = _codeEntry != null ? _codeEntry.Count : 0;
                int pn = _propEntry != null ? _propEntry.Count : 0;

                if (an > 0 || cn > 0 || pn > 0)
                {
                    _scrollPos = EditorGUILayout.BeginScrollView(_scrollPos, false, false);
                    if (an > 0)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField("资源", GUILayout.Width(120f));
                        EditorGUILayout.LabelField((_curOption == 0 && _showDetail) ? "对象" : "路径");
                        EditorGUILayout.EndHorizontal();
                        JWEditorTools.DrawSepLine(1f);

                        for (int i = 0; i < an; i++)
                        {
                            if (!_showInRes && JWEditorTools.CheckInRes(_assetEntry[i].path)) continue;
                            if (_curOption == 0 && !_showScript && _assetEntry[i].obj is MonoScript) continue;
                            GUI.backgroundColor = i % 2 == 0 ? new Color(0.8f, 0.8f, 0.8f) : new Color(0.9f, 0.9f, 0.9f);
                            EditorGUILayout.BeginHorizontal();
                            if (_assetEntry[i].obj)
                            {
                                EditorGUILayout.ObjectField("", _assetEntry[i].obj, typeof(Object), false, GUILayout.Width(120f));
                            }
                            else
                            {
                                EditorGUILayout.TextField("", Path.GetFileName(_assetEntry[i].path), GUILayout.Width(120f));
                            }
                            if (_curOption == 0 && _showDetail)
                            {
                                EditorGUILayout.BeginVertical();
                                List<Object> oList = _assetEntry[i].objs;
                                for (int j = 0; j < oList.Count; j++) if (oList[j]) EditorGUILayout.ObjectField("", oList[j], typeof(Object), false);
                                EditorGUILayout.EndVertical();
                            }
                            else
                            {
                                EditorGUILayout.TextField("", _assetEntry[i].path);
                            }
                            EditorGUILayout.EndHorizontal();
                        }
                        GUI.backgroundColor = Color.white;
                    }
                    else
                    {
                        EditorGUILayout.LabelField("资源未找到");
                    }
                    EditorGUILayout.Space();
                    if (cn > 0)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField("文本", GUILayout.Width(120f));
                        EditorGUILayout.LabelField("行号");
                        EditorGUILayout.EndHorizontal();
                        JWEditorTools.DrawSepLine(1f);

                        for (int i = 0; i < cn; i++)
                        {
                            GUI.backgroundColor = i % 2 == 0 ? new Color(0.8f, 0.8f, 0.8f) : new Color(0.9f, 0.9f, 0.9f);
                            EditorGUILayout.BeginHorizontal();
                            if (_codeEntry[i].obj)
                            {
                                EditorGUILayout.ObjectField("", _codeEntry[i].obj, _codeEntry[i].obj.GetType(), false, GUILayout.Width(120f));
                            }
                            else
                            {
                                EditorGUILayout.TextField("", Path.GetFileName(_codeEntry[i].path), GUILayout.Width(120f));
                            }
                            EditorGUILayout.TextField("", _codeEntry[i].lineStr);
                            EditorGUILayout.EndHorizontal();
                        }
                        GUI.backgroundColor = Color.white;
                    }
                    else if(_curOption == 1)
                    {
                        EditorGUILayout.LabelField("文本资源未找到");
                    }
                    EditorGUILayout.Space();
                    if (pn > 0)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField("序列化对象", GUILayout.Width(120f));
                        EditorGUILayout.LabelField("属性路径");
                        EditorGUILayout.EndHorizontal();
                        JWEditorTools.DrawSepLine(1f);

                        for (int i = 0; i < pn; i++)
                        {
                            GUI.backgroundColor = i % 2 == 0 ? new Color(0.8f, 0.8f, 0.8f) : new Color(0.9f, 0.9f, 0.9f);
                            EditorGUILayout.BeginHorizontal();
                            if (_propEntry[i].obj)
                            {
                                EditorGUILayout.ObjectField("", _propEntry[i].obj, _propEntry[i].obj.GetType(), false, GUILayout.Width(120f));
                            }
                            else
                            {
                                EditorGUILayout.TextField("", Path.GetFileName(_propEntry[i].path), GUILayout.Width(120f));
                            }
                            EditorGUILayout.BeginVertical();
                            List<string> pList = _propEntry[i].props;
                            for (int j = 0; j < pList.Count; j++) EditorGUILayout.TextField("", pList[j]);
                            EditorGUILayout.EndVertical();
                            EditorGUILayout.EndHorizontal();
                        }
                        GUI.backgroundColor = Color.white;
                    }
                    else if (_curOption == 1)
                    {
                        EditorGUILayout.LabelField("序列化资源未找到");
                    }
                    EditorGUILayout.EndScrollView();
                }
                else
                {
                    EditorGUILayout.LabelField("未找到");
                }
            }
            else if (_curOption == 2)
            {

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("输入文本", GUILayout.Width(76f));
                if (GUILayout.Button("重置", GUILayout.Width(80f))) Reset();
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.Space();
                EditorGUILayout.TextField(_text);

                JWEditorTools.DrawSepLine(3f, 2f);

                EditorGUILayout.LabelField("查找结果", GUILayout.Width(76f));
                //EditorGUILayout.Space();
                int cn = _codeEntry != null ? _codeEntry.Count : 0;
                int pn = _propEntry != null ? _propEntry.Count : 0;
                if (cn > 0 || pn > 0)
                {
                    _scrollPos = EditorGUILayout.BeginScrollView(_scrollPos, false, false);

                    if (cn > 0)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField("文本", GUILayout.Width(120f));
                        EditorGUILayout.LabelField("行号");
                        EditorGUILayout.EndHorizontal();
                        JWEditorTools.DrawSepLine(1f);

                        for (int i = 0; i < cn; i++)
                        {
                            GUI.backgroundColor = i % 2 == 0 ? new Color(0.8f, 0.8f, 0.8f) : new Color(0.9f, 0.9f, 0.9f);
                            EditorGUILayout.BeginHorizontal();
                            if (_codeEntry[i].obj)
                            {
                                EditorGUILayout.ObjectField("", _codeEntry[i].obj, _codeEntry[i].obj.GetType(), false, GUILayout.Width(120f));
                            }
                            else
                            {
                                EditorGUILayout.TextField("", Path.GetFileName(_codeEntry[i].path), GUILayout.Width(120f));
                            }
                            EditorGUILayout.TextField("", _codeEntry[i].lineStr);
                            EditorGUILayout.EndHorizontal();
                        }
                        GUI.backgroundColor = Color.white;
                    }
                    else
                    {
                        EditorGUILayout.LabelField("文本资源未找到");
                    }
                    EditorGUILayout.Space();
                    if (pn > 0)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField("序列化对象", GUILayout.Width(120f));
                        EditorGUILayout.LabelField("属性路径");
                        EditorGUILayout.EndHorizontal();
                        JWEditorTools.DrawSepLine(1f);

                        for (int i = 0; i < pn; i++)
                        {
                            GUI.backgroundColor = i % 2 == 0 ? new Color(0.8f, 0.8f, 0.8f) : new Color(0.9f, 0.9f, 0.9f);
                            EditorGUILayout.BeginHorizontal();
                            if (_propEntry[i].obj)
                            {
                                EditorGUILayout.ObjectField("", _propEntry[i].obj, _propEntry[i].obj.GetType(), false, GUILayout.Width(120f));
                            }
                            else
                            {
                                EditorGUILayout.TextField("", Path.GetFileName(_propEntry[i].path), GUILayout.Width(120f));
                            }
                            EditorGUILayout.BeginVertical();
                            List<string> pList = _propEntry[i].props;
                            for (int j = 0; j < pList.Count; j++) EditorGUILayout.TextField("", pList[j]);
                            EditorGUILayout.EndVertical();
                            EditorGUILayout.EndHorizontal();
                        }
                        GUI.backgroundColor = Color.white;
                    }
                    else
                    {
                        EditorGUILayout.LabelField("序列化资源未找到");
                    }

                    EditorGUILayout.EndScrollView();
                }
                else
                {
                    EditorGUILayout.LabelField("未找到");
                }
            }
            else if (_curOption == 3)
            {
                int cn = _codeEntry != null ? _codeEntry.Count : 0;
                int pn = _propEntry != null ? _propEntry.Count : 0;

                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("重置", GUILayout.Width(80f))) Reset();
                if ((cn > 0 || pn > 0) && GUILayout.Button("保存", GUILayout.Width(80f)))
                {
                    string path = EditorUtility.SaveFilePanel("保存当前结果", "", "search", ".txt");
                    if (!string.IsNullOrEmpty(path) && (!File.Exists(path) || EditorUtility.DisplayDialog("警告", "文件已存在，是否覆盖", "确定", "取消")))
                    {
                        StreamWriter sr = null;
                        try
                        {
                            sr = new StreamWriter(path);
                            if (cn > 0)
                            {
                                sr.WriteLine("文本部分：");
                                for (int i = 0; i < cn; i++)
                                {
                                    sr.WriteLine((_codeEntry[i].obj ? _codeEntry[i].obj.name + " Path=" : "Null Path=") + _codeEntry[i].path);
                                    sr.WriteLine(_codeEntry[i].lineStr);
                                    sr.WriteLine();
                                }
                            }
                            if (pn > 0)
                            {
                                sr.WriteLine("序列化数据部分：");
                                for (int i = 0; i < pn; i++)
                                {
                                    sr.WriteLine((_propEntry[i].obj ? _propEntry[i].obj.name + " Path=" : "Null Path=") + _propEntry[i].path);
                                    List<string> pList = _propEntry[i].props;
                                    for (int j = 0; j < pList.Count; j++) sr.WriteLine("    " + pList[j]);
                                    sr.WriteLine();
                                }
                            }
                            if (EditorUtility.DisplayDialog("结果", "保存成功", "查看", "取消"))
                            {
                                Application.OpenURL("file://" + System.IO.Path.GetDirectoryName(path));
                                //EditorUtility.OpenWithDefaultApp(path);
                            }
                        }
                        catch (System.Exception e)
                        {
                            EditorUtility.DisplayDialog("错误", "保存结果发生错误:\n" + e.Message, "确定");
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
                }
                EditorGUILayout.EndHorizontal();

                JWEditorTools.DrawSepLine(3f, 2f);
                EditorGUILayout.LabelField("查找结果", GUILayout.Width(76f));
                
                if (cn > 0 || pn > 0)
                {
                    _scrollPos = EditorGUILayout.BeginScrollView(_scrollPos, false, false);

                    if (cn > 0)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField("文本", GUILayout.Width(120f));
                        EditorGUILayout.LabelField("内容");
                        EditorGUILayout.EndHorizontal();
                        JWEditorTools.DrawSepLine(1f);

                        for (int i = 0; i < cn; i++)
                        {
                            GUI.backgroundColor = i % 2 == 0 ? new Color(0.8f, 0.8f, 0.8f) : new Color(0.9f, 0.9f, 0.9f);
                            EditorGUILayout.BeginHorizontal();
                            if (_codeEntry[i].obj)
                            {
                                EditorGUILayout.ObjectField("", _codeEntry[i].obj, _codeEntry[i].obj.GetType(), false, GUILayout.Width(120f));
                            }
                            else
                            {
                                EditorGUILayout.TextField("", Path.GetFileName(_codeEntry[i].path), GUILayout.Width(120f));
                            }
                            EditorGUILayout.TextField("", _codeEntry[i].lineStr, GUILayout.Height(_codeEntry[i].line.Count * (_codeEntry[i].line.Count > 20 ? 13.2f : 14f)));
                            EditorGUILayout.EndHorizontal();
                        }
                        GUI.backgroundColor = Color.white;
                    }
                    else
                    {
                        EditorGUILayout.LabelField("文本资源未找到");
                    }
                    EditorGUILayout.Space();
                    if (pn > 0)
                    {
                        

                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField("序列化对象", GUILayout.Width(120f));
                        EditorGUILayout.LabelField("属性路径");
                        EditorGUILayout.EndHorizontal();
                        JWEditorTools.DrawSepLine(1f);

                        for (int i = 0; i < pn; i++)
                        {
                            GUI.backgroundColor = i % 2 == 0 ? new Color(0.8f, 0.8f, 0.8f) : new Color(0.9f, 0.9f, 0.9f);
                            EditorGUILayout.BeginHorizontal();
                            if (_propEntry[i].obj)
                            {
                                EditorGUILayout.ObjectField("", _propEntry[i].obj, _propEntry[i].obj.GetType(), false, GUILayout.Width(120f));
                            }
                            else
                            {
                                EditorGUILayout.TextField("", Path.GetFileName(_propEntry[i].path), GUILayout.Width(120f));
                            }
                            EditorGUILayout.BeginVertical();
                            List<string> pList = _propEntry[i].props;
                            for (int j = 0; j < pList.Count; j++) EditorGUILayout.TextField("", pList[j]);
                            EditorGUILayout.EndVertical();
                            EditorGUILayout.EndHorizontal();
                        }
                        GUI.backgroundColor = Color.white;
                    }
                    else
                    {
                        EditorGUILayout.LabelField("序列化资源未找到");
                    }

                    EditorGUILayout.EndScrollView();
                }
                else
                {
                    EditorGUILayout.LabelField("未找到");
                }
            }
        }
        else
        {
            _curOption = GUILayout.SelectionGrid(_curOption, _option, 4);
            if (_intro.IndexAvailable(_curOption) && !string.IsNullOrEmpty(_intro[_curOption])) EditorGUILayout.HelpBox(_intro[_curOption], MessageType.Info);
            JWEditorTools.DrawSepLine(3f, 2f);

            if (_curOption == 0 || _curOption == 1)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("当前选择", GUILayout.Width(76f));
                if (GUILayout.Button("查找", GUILayout.Width(80f)))
                {
                    if (_selectObjs.GetLength() > 0)
                    {
                        if (_curOption == 0)
                        {
                            EditorUtility.DisplayProgressBar("正在搜索", "", 0f);
                            _assetEntry = SearchAssetDependencies(_selectObjs, (f, p) => { EditorUtility.DisplayProgressBar("正在搜索", p, f); });
                            _flag = true;
                            EditorUtility.ClearProgressBar();
                        }
                        else if (_curOption == 1)
                        {
                            EditorUtility.DisplayProgressBar("正在搜索", "", 0f);
                            _assetEntry = SearchAssetReference(_selectObjs, (f, p) => { EditorUtility.DisplayProgressBar("正在搜索资源", p, f / 3f); });
                            _codeEntry = SearchObjsFromTextAsset(_selectObjs, (f, p) => { EditorUtility.DisplayProgressBar("正在搜索文本", p, (f + 1f) / 3f); });
                            _propEntry = SearchObjsFromSerialize(_selectObjs, _searchScene, (f, p) => { EditorUtility.DisplayProgressBar("正在搜索序列化对象", p, (f + 2f) / 3f); });
                            _flag = true;
                            EditorUtility.ClearProgressBar();
                        }
                    }
                }
                if (_curOption == 1)
                {
                    EditorGUIUtility.labelWidth = 50f;
                    _searchScene = EditorGUILayout.Toggle("搜索场景", _searchScene, GUILayout.Width(80f));
                    EditorGUIUtility.labelWidth = 0f;
                }
                EditorGUILayout.EndHorizontal();

                JWEditorTools.DrawSepLine(1f, 2f);

                if (_selectObjs.GetLength() < 1) _selectObjs = new Object[1];

                bool expend = true;
                int line = Mathf.Max(1, Mathf.FloorToInt(position.width / 80f));
                for (int i = 0; i < _selectObjs.Length; i++)
                {
                    if (line > 1 && i % line == 0)
                    {
                        if (i > 0) EditorGUILayout.EndHorizontal();
                        EditorGUILayout.BeginHorizontal();
                    }
                    Object obj = EditorGUILayout.ObjectField("", _selectObjs[i], typeof(Object), true, GUILayout.Width(80f));
                    if (obj == null || CheckObject(obj)) _selectObjs[i] = obj;
                    if (_selectObjs[i] == null) expend = false;
                }
                if (line > 1) EditorGUILayout.EndHorizontal();
                if (expend) System.Array.Resize(ref _selectObjs, _selectObjs.Length + 1);
            }
            else if (_curOption == 2)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("输入文本", GUILayout.Width(76f));
                int search = 0;
                if (GUILayout.Button("精确搜索", GUILayout.Width(80f))) search = 1;
                if (GUILayout.Button("模糊搜索", GUILayout.Width(80f))) search = 2;
                EditorGUIUtility.labelWidth = 50f;
                _searchScene = EditorGUILayout.Toggle("搜索场景", _searchScene, GUILayout.Width(80f));
                EditorGUIUtility.labelWidth = 0f;
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.Space();
                _text = EditorGUILayout.TextField(_text);

                if (search > 0 && !string.IsNullOrEmpty(_text))
                {
                    EditorUtility.DisplayProgressBar("正在搜索", "", 0f);
                    _codeEntry = SearchTextFromTextAsset(_text, search == 1, (f, p) => { EditorUtility.DisplayProgressBar("正在搜索文本", p, 0.5f * f); });
                    _propEntry = SearchTextFromSerialize(_text, _searchScene, search == 1, (f, p) => { EditorUtility.DisplayProgressBar("正在搜索序列化对象", p, 0.5f + 0.5f * f); });
                    _flag = true;
                    EditorUtility.ClearProgressBar();
                }
            }
            else if (_curOption == 3 && _ortherFunc.GetLength() > 0)
            {
                EditorGUIUtility.labelWidth = 50f;
                _searchScene = EditorGUILayout.Toggle("搜索场景", _searchScene, GUILayout.Width(80f));
                EditorGUIUtility.labelWidth = 0f;
                JWEditorTools.DrawSepLine(1f, 2f);
                EditorGUILayout.Space();

                int idx = -1;
                for (int i = 0; i < _ortherFunc.Length; i++)
                {
                    EditorGUILayout.BeginHorizontal();
                    if (GUILayout.Button(_ortherFunc[i], GUILayout.Height(24), GUILayout.Width(100f))) idx = i;
                    if (_ortherIntro.IndexAvailable(i))
                    {
                        GUILayout.Label(_ortherIntro[i], GUILayout.Height(24));
                    }
                    EditorGUILayout.EndHorizontal();
                    EditorGUILayout.Space();
                }
                if (idx == 0)
                {
                    EditorUtility.DisplayProgressBar("正在搜索", "", 0f);
                    _propEntry = SearchMissingScript(_searchScene, (f, p) => { EditorUtility.DisplayProgressBar("正在搜索序列化对象", p, f); });
                    _flag = true;
                    EditorUtility.ClearProgressBar();
                }
                else if (idx == 1)
                {
                    EditorUtility.DisplayProgressBar("正在搜索", "", 0f);
                    _codeEntry = SearchCnFromTextAsset((f, p) => { EditorUtility.DisplayProgressBar("正在搜索文本", p, 0.5f * f); });
                    _propEntry = SearchCnFromSerialize(_searchScene, (f, p) => { EditorUtility.DisplayProgressBar("正在搜索序列化对象", p, 0.5f + 0.5f * f); });
                    _flag = true;
                    EditorUtility.ClearProgressBar();
                }
            }
        }
    }

    private void Reset()
    {
        _flag = false;
        _scrollPos = Vector2.zero;
    }

    private bool CheckObject(Object obj)
    {
        if (obj && !System.Array.Exists(_selectObjs, o => { return o == obj; }))
        {
            if (_curOption == 0)
            {
                PrefabType pt = PrefabUtility.GetPrefabType(obj);
                return pt == PrefabType.Prefab || pt == PrefabType.ModelPrefab || AssetDatabase.GetAssetPath(obj).EndsWith(".unity");
            }
            if (_curOption == 1)
            {
                return obj.GetType().IsSubclassOf(typeof(Object)) || File.Exists(AssetDatabase.GetAssetPath(obj));
            }
        }
        return false;
    }

    private void SetSelectObjs(Object[] objs)
    {
        if (_flag) return;
        objs = System.Array.FindAll(objs, CheckObject);
        if (objs.GetLength() > 0)
        {
            ArrayExtend.TrimSame(ref objs);
            System.Array.Sort(objs, (x, y) => { return string.CompareOrdinal(x.name, y.name); });
        }
        if (objs.GetLength() > 0)
        {
            _selectObjs = objs;
            System.Array.Resize(ref _selectObjs, _selectObjs.Length + 1);
            Repaint();
        }
    }

    /// <summary>
    /// 搜索MissingScript
    /// </summary>
    public static List<PropEntry> SearchMissingScript(bool searchScene, System.Action<float, string> process = null)
    {
        List<PropEntry> ret = new List<PropEntry>(32);
        string[] guids = AssetDatabase.FindAssets("t:GameObject");


        string csguid = AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path);
        string[] sces = null;
        if (searchScene)
        {
            sces = FindScene(true);
            int idx = System.Array.IndexOf(sces, csguid);
            if (idx >= 0)
            {
                sces[idx] = sces[0];
                sces[0] = csguid;
            }
        }
        int cnt = guids.Length + sces.GetLength();
        for (int i = 0; i < guids.Length; i++)
        {
            string p = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (process != null) process((float)(i + 1) / (float)cnt, p);
            GameObject go = AssetDatabase.LoadAssetAtPath(p, typeof(GameObject)) as GameObject;
            if (go)
            {
                PropEntry pe = null;
                SearchMissingScript(go.transform, ref pe);
                if (pe != null)
                {
                    pe.path = p;
                    pe.obj = go;
                    ret.Add(pe);
                }
            }
        }
        if (sces.GetLength() > 0)
        {
            for (int i = 0; i < sces.Length; i++)
            {
                string p = AssetDatabase.GUIDToAssetPath(sces[i]);
                if (process != null) process((float)(guids.Length + i + 1) / (float)cnt, p);

                if (sces[i] != AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path))
                {

                    if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                    {
                        EditorSceneManager.OpenScene(p);
                    }
                    else
                    {
                        Debug.LogWarning("Search Scene Cancel");
                        break;
                    }
                }
                if (sces[i] == AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path))
                {
                    PropEntry pe = null;
                    List<Transform> roots = JWEditorTools.FindSceneRoots();
                    for (int j = 0; j < roots.Count; j++)
                    {
                        SearchMissingScript(roots[j], ref pe);
                        if (pe != null)
                        {
                            pe.path = p;
                            pe.obj = AssetDatabase.LoadAssetAtPath(p, typeof(Object));
                            ret.Add(pe);
                        }
                    }
                }
            }
            EditorSceneManager.OpenScene(AssetDatabase.GUIDToAssetPath(csguid));
        }
        return ret;
    }
    private static void SearchMissingScript(Transform t, ref PropEntry pe)
    {
        if (t)
        {
            string cp = JWEditorTools.GetHierarchy(t.gameObject);
            Component[] comps = t.GetComponents<Component>();
            for (int i = 0; i < comps.Length; i++)
            {
                if (comps[i]) continue;
                if (pe == null) pe = new PropEntry();
                pe.props.Add(cp + "[" + (i + 1) + "]");
            }
            if (t.childCount > 0)
            {
                for (int i = 0; i < t.childCount; i++)
                {
                    SearchMissingScript(t.GetChild(i), ref pe);
                }
            }
        }
    }

    /// <summary>
    /// 搜索给定对象的依赖资源
    /// </summary>
    public static List<AssetEntry> SearchAssetDependencies(Object[] objs, System.Action<float, string> process = null)
    {
        List<AssetEntry> ret = new List<AssetEntry>(32);
        if (objs.GetLength() < 1) return ret;
        Object[] deps = EditorUtility.CollectDependencies(objs);
        for (int i = 0; i < deps.Length; i++)
        {
            string path = AssetDatabase.GetAssetPath(deps[i]);

            if (string.IsNullOrEmpty(path)) continue;
            if (process != null) process((float)(i + 1) / (float)deps.Length, path);

            AssetEntry ae = ret.Find(a => { return a.path.Equals(path); });
            if (ae == null)
            {
                ae = new AssetEntry();
                ae.path = path;
                ae.obj = deps[i];
                ret.Add(ae);
            }
            ae.objs.Add(deps[i]);
        }
        return ret;
    }
    /// <summary>
    /// 搜索引用给定对象的资源
    /// </summary>
    public static List<AssetEntry> SearchAssetReference(Object[] objs, System.Action<float, string> process = null)
    {
        List<AssetEntry> ret = new List<AssetEntry>(32);
        if (objs.GetLength() < 1) return ret;
        List<string> paths = new List<string>(objs.Length);
        for (int i = 0; i < objs.Length; i++) if (objs[i]) paths.Add(AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(objs[i])));
        if (paths.Count < 1) return ret;

        string[] sceneAsset = FindScene(true);
        string[] resAsset = AssetDatabase.FindAssets("t:GameObject");
        string[] guids = new string[sceneAsset.GetLength() + resAsset.GetLength()];
        if (sceneAsset.GetLength() > 0) { System.Array.Copy(sceneAsset, guids, sceneAsset.Length); }
        if (resAsset.GetLength() > 0) { System.Array.Copy(resAsset, 0, guids, sceneAsset.GetLength(), resAsset.Length); }

        string[] temp = new string[1];

        for (int i = 0; i < guids.Length; i++)
        {
            temp[0] = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (process != null) process((float)(i + 1) / (float)guids.Length, temp[0]);
            string[] deps = AssetDatabase.GetDependencies(temp);
            AssetEntry ae = null;
            for (int j = 0; j < deps.Length; j++)
            {
                if (paths.Contains(AssetDatabase.AssetPathToGUID(deps[j])))
                {
                    if (ae == null)
                    {
                        ae = new AssetEntry();
                        ae.path = temp[0];
                        ae.obj = AssetDatabase.LoadAssetAtPath(temp[0], typeof(Object));
                        ret.Add(ae);
                        break;
                    }
                }
            }
        }
        return ret;
    }
    /// <summary>
    /// 搜索精确匹配给定对象名称的文本
    /// </summary>
    public static List<TextEntry> SearchObjsFromTextAsset(Object[] objs, System.Action<float, string> process = null)
    {
        List<TextEntry> ret = new List<TextEntry>(32);
        if (objs.GetLength() < 1) return ret;
        List<string> names = new List<string>(objs.Length);
        for (int i = 0; i < objs.Length; i++) if (objs[i]) names.Add(objs[i] is MonoScript ? objs[i].name : "\"" + objs[i].name + "\"");
        if (names.Count < 1) return ret;
        string[] guids = AssetDatabase.FindAssets("t:TextAsset");
        for (int i = 0; i < guids.Length; i++)
        {
            StreamReader sr = null;
            string p = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (process != null) process((float)(i + 1) / (float)guids.Length, p);
            try
            {
                int lineNum = 0;
                TextEntry ce = null;
                sr = new StreamReader(p);
                while (!sr.EndOfStream)
                {
                    lineNum++;
                    for (int j = 0; j < names.Count; j++)
                    {
                        if (sr.ReadLine().Contains(names[j]))
                        {
                            if (ce == null)
                            {
                                ce = new TextEntry();
                                ce.path = p;
                                ce.obj = AssetDatabase.LoadAssetAtPath(ce.path, typeof(TextAsset));
                                ce.lineStr = "[" + lineNum;
                                ret.Add(ce);
                            }
                            else
                            {
                                ce.lineStr += "," + lineNum;
                            }
                            ce.line.Add(lineNum);
                            break;
                        }
                    }
                }
                if (ce != null) ce.lineStr += "]";
            }
            catch (System.Exception e)
            {
                Debug.LogWarning(Path.GetFileNameWithoutExtension(p) + e.Message);
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
        ret.Sort((x, y) => { return string.Compare(x.GetType().Name, y.GetType().Name); });
        return ret;
    }
    /// <summary>
    /// 搜索精确匹配给定对象名称的序列化数据
    /// </summary>
    public static List<PropEntry> SearchObjsFromSerialize(Object[] objs, bool searchScene, System.Action<float, string> process = null)
    {
        List<PropEntry> ret = new List<PropEntry>(32);
        if (objs.GetLength() < 1) return ret;
        List<string> names = new List<string>(objs.Length);
        for (int i = 0; i < objs.Length; i++) if (objs[i]) names.Add("\"" + objs[i].name + "\"");
        if (names.Count < 1) return ret;
        string[] guids = AssetDatabase.FindAssets("t:GameObject");
        string csguid = AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path);
        string[] sces = null;
        if (searchScene)
        {
            sces = FindScene(true);
            int idx = System.Array.IndexOf(sces, csguid);
            if (idx >= 0)
            {
                sces[idx] = sces[0];
                sces[0] = csguid;
            }
        }
        int cnt = guids.Length + sces.GetLength();
        for (int i = 0; i < guids.Length; i++)
        {
            string p = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (process != null) process((float)(i + 1) / (float)cnt, p);
            GameObject go = AssetDatabase.LoadAssetAtPath(p, typeof(GameObject)) as GameObject;
            if (go)
            {
                PropEntry pe = SearchTextFromComponent(go.GetComponentsInAllChild<Component>(), names);
                if (pe != null)
                {
                    pe.path = p;
                    pe.obj = go;
                    ret.Add(pe);
                }
            }
        }
        if (sces.GetLength() > 0)
        {
            for (int i = 0; i < sces.Length; i++)
            {
                string p = AssetDatabase.GUIDToAssetPath(sces[i]);
                if (process != null) process((float)(guids.Length + i + 1) / (float)cnt, p);

                if (sces[i] != AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path))
                {
                    if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                    {
                        EditorSceneManager.OpenScene(p);
                    }
                    else
                    {
                        Debug.LogWarning("Search Scene Cancel");
                        break;
                    }
                }
                if (sces[i] == AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path))
                {
                    PropEntry pe = SearchTextFromComponent(JWEditorTools.FindSceneCmps<Component>(), names);
                    if (pe != null)
                    {
                        pe.path = p;
                        pe.obj = AssetDatabase.LoadAssetAtPath(p, typeof(Object));
                        ret.Add(pe);
                    }
                }
            }
            EditorSceneManager.OpenScene(AssetDatabase.GUIDToAssetPath(csguid));
        }
        return ret;
    }
    /// <summary>
    /// 搜索引用给定文本的文本
    /// <param name="isExplicit">是精确还是模糊</param>
    /// </summary>
    public static List<TextEntry> SearchTextFromTextAsset(string text, bool isExplicit = false, System.Action<float, string> process = null)
    {
        List<TextEntry> ret = new List<TextEntry>(32);
        if (string.IsNullOrEmpty(text)) return ret;
        if (isExplicit) text = "\"" + text + "\"";
        string[] guids = AssetDatabase.FindAssets("t:TextAsset");
        for (int i = 0; i < guids.Length; i++)
        {
            StreamReader sr = null;
            string p = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (process != null) process((float)(i + 1) / (float)guids.Length, p);
            try
            {
                int lineNum = 0;
                TextEntry ce = null;
                sr = new StreamReader(p);
                while (!sr.EndOfStream)
                {
                    lineNum++;
                    if (sr.ReadLine().Contains(text))
                    {
                        if (ce == null)
                        {
                            ce = new TextEntry();
                            ce.path = p;
                            ce.obj = AssetDatabase.LoadAssetAtPath(ce.path, typeof(TextAsset));
                            ce.lineStr = "[" + lineNum;
                            ret.Add(ce);
                        }
                        else
                        {
                            ce.lineStr += "," + lineNum;
                        }
                        ce.line.Add(lineNum);
                    }
                }
                if (ce != null) ce.lineStr += "]";
            }
            catch (System.Exception e)
            {
                Debug.LogWarning(Path.GetFileNameWithoutExtension(p) + e.Message);
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
        ret.Sort((x, y) => { return string.Compare(x.GetType().Name, y.GetType().Name); });
        return ret;
    }
    /// <summary>
    /// 搜索引用给定文本的序列化数据
    /// <param name="isExplicit">是精确还是模糊</param>
    /// </summary>
    public static List<PropEntry> SearchTextFromSerialize(string text, bool searchScene, bool isExplicit = false, System.Action<float, string> process = null)
    {
        List<PropEntry> ret = new List<PropEntry>(32);
        if (string.IsNullOrEmpty(text)) return ret;
        string[] guids = AssetDatabase.FindAssets("t:GameObject");

        string csguid = AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path);
        string[] sces = null;
        if (searchScene)
        {
            sces = FindScene(true);
            int idx = System.Array.IndexOf(sces, csguid);
            if (idx >= 0)
            {
                sces[idx] = sces[0];
                sces[0] = csguid;
            }
        }
        
        int cnt = guids.Length + sces.GetLength();
        
        for (int i = 0; i < guids.Length; i++)
        {
            string p = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (process != null) process((float)(i + 1) / (float)cnt, p);
            GameObject go = AssetDatabase.LoadAssetAtPath(p, typeof(GameObject)) as GameObject;
            if (go)
            {
                PropEntry pe = SearchTextFromComponent(go.GetComponentsInAllChild<Component>(), text, isExplicit);
                if (pe != null)
                {
                    pe.path = p;
                    pe.obj = go;
                    ret.Add(pe);
                }
            }
            
        }

        if (sces.GetLength() > 0)
        {
            for (int i = 0; i < sces.Length; i++)
            {
                string p = AssetDatabase.GUIDToAssetPath(sces[i]);
                if (process != null) process((float)(guids.Length + i + 1) / (float)cnt, p);

                if (sces[i] != AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path))
                {
                    if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                    {
                        EditorSceneManager.OpenScene(p);
                    }
                    else
                    {
                        Debug.LogWarning("Search Scene Cancel");
                        break;
                    }
                }
                if (sces[i] == AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path))
                {
                    PropEntry pe = SearchTextFromComponent(JWEditorTools.FindSceneCmps<Component>(), text, isExplicit);
                    if (pe != null)
                    {
                        pe.path = p;
                        pe.obj = AssetDatabase.LoadAssetAtPath(p, typeof(Object));
                        ret.Add(pe);
                    }
                }
            }
            EditorSceneManager.OpenScene(AssetDatabase.GUIDToAssetPath(csguid));
        }

        return ret;
    }
    /// <summary>
    /// 从给定组件中搜索匹配text的序列化字段
    /// </summary>
    /// <param name="isExplicit">是明确还是模糊</param>
    private static PropEntry SearchTextFromComponent(Component[] cmps, string text, bool isExplicit)
    {
        PropEntry pe = null;
        for (int j = 0; j < cmps.Length; j++)
        {
            if (!cmps[j]) continue;
            string cp = JWEditorTools.GetHierarchy(cmps[j].gameObject) + ":" + cmps[j].GetType().Name;
            SerializedObject so = new SerializedObject(cmps[j]);
            SerializedProperty sp = so.GetIterator();
            while (sp.Next(true))
            {
                if (sp.propertyType == SerializedPropertyType.String)
                {
                    if (isExplicit ? sp.stringValue == text : sp.stringValue.Contains(text))
                    {
                        if (pe == null) pe = new PropEntry();
                        pe.props.Add(cp + "." + sp.propertyPath.Replace(".Array.data", ""));
                    }
                }
            }
            sp.Dispose();
            so.Dispose();
        }
        return pe;
    }
    /// <summary>
    /// 从给定组件中搜索精确匹配text列表的序列化字段
    /// </summary>
    private static PropEntry SearchTextFromComponent(Component[] cmps, List<string> text)
    {
        PropEntry pe = null;
        for (int j = 0; j < cmps.Length; j++)
        {
            if (!cmps[j]) continue;
            string cp = JWEditorTools.GetHierarchy(cmps[j].gameObject) + ":" + cmps[j].GetType().Name;
            SerializedObject so = new SerializedObject(cmps[j]);
            SerializedProperty sp = so.GetIterator();
            while (sp.Next(true))
            {
                if (sp.propertyType == SerializedPropertyType.String)
                {
                    if (text.Contains(sp.stringValue))
                    {
                        if (pe == null) pe = new PropEntry();
                        pe.props.Add(cp + "." + sp.propertyPath.Replace(".Array.data", ""));
                    }
                }
            }
            sp.Dispose();
            so.Dispose();
        }
        return pe;
    }

    /// <summary>
    /// 从文本中搜索中文字符串
    /// </summary>
    public List<TextEntry> SearchCnFromTextAsset(System.Action<float, string> process = null)
    {
        List<TextEntry> ret = new List<TextEntry>(32);
        string[] guids = AssetDatabase.FindAssets("t:TextAsset");
        for (int i = 0; i < guids.Length; i++)
        {
            StreamReader sr = null;
            string p = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (process != null) process((float)(i + 1) / (float)guids.Length, p);
            try
            {
                int lineNum = 1;
                int status = 0;//0=普通文本，1=字符串，2=字符，3=行注释，4=块注释
                int lastVal = 0;
                RecString rec = new RecString(16);
                bool findCn = false;
                int debugDepth = 0;//>10 方可

                StringBuilder sb = null;
                TextEntry ce = null;
                sr = new StreamReader(p);
                while (!sr.EndOfStream)
                {
                    int val = sr.Read();
                    if (val == 10)//'\n'
                    {
                        lineNum++;
                        if (status == 3) status = 0;//退出行注释
                    }
                    else if (status == 1 || status == 2)//字符串/字符
                    {
                        if (lastVal != 92 && ((val == 34 && status == 1) || (val == 39 && status == 2)))//退出字符串
                        {
                            status = 0;
                            if (findCn)
                            {
                                findCn = false;
                                if (ce == null)
                                {
                                    ce = new TextEntry();
                                    ce.path = p;
                                    ce.obj = AssetDatabase.LoadAssetAtPath(ce.path, typeof(TextAsset));
                                    ret.Add(ce);
                                }
                                ce.line.Add(lineNum);
                                ce.lineStr += (debugDepth > 10 ? "[Debug]" : "") + "[" + lineNum + "]" + sb.ToString() + "\n";
                            }
                        }
                        else
                        {
                            sb.Append((char)val);
                            if (!findCn && val >= 19968 && val <= 40869)//检测中文 '一'-'龥' [\u4e00-\u9fa5]
                            {
                                findCn = true;
                            }
                        }
                    }
                    else if (status == 4)//块注释
                    {
                        if (val == 47)
                        {
                            if (lastVal == 42)//退出块注释
                            {
                                status = 0;
                            }
                        }
                    }
                    else if (status == 0)
                    {
                        if (val == 34 || val == 39)
                        {
                            status = val == 34 ? 1 : 2;
                            if (debugDepth < 11) debugDepth = 0;
                            findCn = false;
                            if (sb == null) sb = new StringBuilder(1024);
                            else sb.Length = 0;
                        }
                        else if (val == 47)//'/'
                        {
                            if (lastVal == 47)//进入行注释
                            {
                                status = 3;
                                if (debugDepth < 11) debugDepth = 0;
                            }
                        }
                        else if (val == 42)//'*'
                        {
                            if (lastVal == 47)//进入块注释
                            {
                                status = 4;
                                if (debugDepth < 11) debugDepth = 0;
                            }
                        }
                        else
                        {
                            if (debugDepth > 0)
                            {
                                if (val == 41)//')'
                                {
                                    debugDepth--;
                                    if (debugDepth < 11)
                                    {
                                        debugDepth = 0;
                                    }
                                }
                                else if (!char.IsWhiteSpace((char)val))
                                {
                                    if (debugDepth == 1)//Debug 1
                                    {
                                        if (val == 46)//'.'
                                        {
                                            debugDepth = 2;
                                        }
                                        else
                                        {
                                            debugDepth = 0;
                                        }
                                    }
                                    else if (debugDepth == 2)//Debug 2
                                    {
                                        if (val == 40)//'('
                                        {
                                            debugDepth = 11;
                                        }
                                    }
                                    else if (debugDepth == 3)//Exception 1
                                    {
                                        if (val == 40)//'('
                                        {
                                            debugDepth = 11;
                                        }
                                        else
                                        {
                                            debugDepth = 0;
                                        }
                                    }
                                    else if (debugDepth > 10 && val == 40)//'('
                                    {
                                        debugDepth++;
                                    }
                                }
                            }
                            else
                            {
                                rec.Add(val);
                                if (val == 103)//'g'
                                {
                                    string rstr = rec.RightString(6);
                                    if (rstr == " Debug" || rstr == ".Debug")
                                    {
                                        debugDepth = 1;
                                        rec.Clear();
                                    }
                                }
                                else if (val == 110)//'n'
                                {
                                    string rstr = rec.RightString(10);
                                    if (rstr == " Exception" || rstr == ".Exception")
                                    {
                                        debugDepth = 3;
                                        rec.Clear();
                                    }
                                }
                            }
                        }
                        
                    }
                    lastVal = val;
                }
            }
            catch (System.Exception e)
            {
                Debug.LogWarning(Path.GetFileNameWithoutExtension(p) + e.Message);
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
        ret.Sort((x, y) => { return string.Compare(x.GetType().Name, y.GetType().Name); });
        return ret;
    }
    /// <summary>
    /// 从序列化数据中搜索中文
    /// </summary>
    public static List<PropEntry> SearchCnFromSerialize(bool searchScene, System.Action<float, string> process = null)
    {
        List<PropEntry> ret = new List<PropEntry>(32);
        string[] guids = AssetDatabase.FindAssets("t:GameObject");

        string csguid = AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path);
        string[] sces = null;
        if (searchScene)
        {
            sces = FindScene(true);
            int idx = System.Array.IndexOf(sces, csguid);
            if (idx >= 0)
            {
                sces[idx] = sces[0];
                sces[0] = csguid;
            }
        }

        int cnt = guids.Length + sces.GetLength();

        for (int i = 0; i < guids.Length; i++)
        {
            string p = AssetDatabase.GUIDToAssetPath(guids[i]);
            if (process != null) process((float)(i + 1) / (float)cnt, p);
            GameObject go = AssetDatabase.LoadAssetAtPath(p, typeof(GameObject)) as GameObject;
            if (go)
            {
                PropEntry pe = SearchCnFromComponent(go.GetComponentsInAllChild<Component>());
                if (pe != null)
                {
                    pe.path = p;
                    pe.obj = go;
                    ret.Add(pe);
                }
            }

        }

        if (sces.GetLength() > 0)
        {
            for (int i = 0; i < sces.Length; i++)
            {
                string p = AssetDatabase.GUIDToAssetPath(sces[i]);
                if (process != null) process((float)(guids.Length + i + 1) / (float)cnt, p);

                if (sces[i] != AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path))
                {
                    if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                    {
                        EditorSceneManager.OpenScene(p);
                    }
                    else
                    {
                        Debug.LogWarning("Search Scene Cancel");
                        break;
                    }
                }
                if (sces[i] == AssetDatabase.AssetPathToGUID(EditorSceneManager.GetActiveScene().path))
                {
                    PropEntry pe = SearchCnFromComponent(JWEditorTools.FindSceneCmps<Component>());
                    if (pe != null)
                    {
                        pe.path = p;
                        pe.obj = AssetDatabase.LoadAssetAtPath(p, typeof(Object));
                        ret.Add(pe);
                    }
                }
            }
            EditorSceneManager.OpenScene(AssetDatabase.GUIDToAssetPath(csguid));
        }

        return ret;
    }
    /// <summary>
    /// 从给定组件中搜索含有中文的的序列化字段
    /// </summary>
    private static PropEntry SearchCnFromComponent(Component[] cmps)
    {
        PropEntry pe = null;
        for (int j = 0; j < cmps.Length; j++)
        {
            if (!cmps[j]) continue;
            string cp = JWEditorTools.GetHierarchy(cmps[j].gameObject) + ":" + cmps[j].GetType().Name;
            SerializedObject so = new SerializedObject(cmps[j]);
            SerializedProperty sp = so.GetIterator();
            while (sp.Next(true))
            {
                if (sp.propertyType == SerializedPropertyType.String)
                {
                    string stringValue = sp.stringValue;
                    if (string.IsNullOrEmpty(stringValue)) continue;
                    for (int i = 0; i < stringValue.Length; i++)
                    {
                        int v = stringValue[i];
                        if (v < 19968 || v > 40869) continue;
                        if (pe == null) pe = new PropEntry();
                        pe.props.Add(cp + "." + sp.propertyPath.Replace(".Array.data", "") + "=" + stringValue);
                        break;
                    }
                }
            }
            sp.Dispose();
            so.Dispose();
        }
        return pe;
    }

    private string GetShortPath(string path)
    {
        if (!string.IsNullOrEmpty(path))
        {
            if (path.StartsWith("Assets/") || path.StartsWith("Assets\\"))
            {
                path = path.Substring(7, path.Length - 7);
            }
            else
            {
                int idx = path.IndexOf("/Assets/");
                if (idx < 0) idx = path.IndexOf("/Assets\\");
                if (idx < 0) idx = path.IndexOf("\\Assets/");
                if (idx < 0) idx = path.IndexOf("\\Assets\\");
                if (idx >= 0) path = path.Substring(idx + 8, path.Length - idx - 8);
            }
        }
        return path;
    }

    public static string[] FindScene(bool guid = false)
    {
        string[] sces = Directory.GetFiles("Assets", "*.unity", SearchOption.AllDirectories);
        if (guid) for (int i = 0; i < sces.Length; i++) sces[i] = AssetDatabase.AssetPathToGUID(sces[i]);
        return sces;
    }
}

internal class RecString
{
    private char[] mChars;
    private int mIdx;
    private int mLen;
    public RecString(int len)
    {
        mIdx = 0;
        mLen = Mathf.Max(1, len);
        mChars = new char[mLen];
    }

    public int length { get { return mLen; } }
    public void Add(int cv) { Add((char)cv); }
    public void Add(char c) { mChars[mIdx++ % mLen] = c; }
    public void Clear() { System.Array.Clear(mChars, 0, mLen); mIdx = 0; }

    public void Warp()
    {
        if (mIdx > mLen)
        {
            mChars.OffsetIndex(-(mIdx % mLen));
            mIdx = mLen;
        }
    }

    public override string ToString()
    {
        Warp();
        return new string(mChars, 0, mIdx);
    }

    public string LeftString(int cnt)
    {
        Warp();
        if (cnt <= 0) return string.Empty;
        if (cnt >= mIdx) return ToString();
        return new string(mChars, 0, cnt);
    }
    public string RightString(int cnt)
    {
        Warp();
        if (cnt <= 0) return string.Empty;
        if (cnt >= mIdx) return ToString();
        return new string(mChars, mIdx - cnt, cnt);
    }
}