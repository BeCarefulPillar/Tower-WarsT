using UnityEditor;
using UnityEngine;
using System.Collections.Generic;

public static class JWEditorTools
{
    /// <summary>
    /// 获取场景的根
    /// </summary>
    public static List<Transform> FindSceneRoots()
    {
        Transform[] ts = Object.FindObjectsOfType<Transform>();
        List<Transform> roots = new List<Transform>(2);
        for (int i = 0; i < ts.Length; i++)
        {
            if (ts[i].root && !roots.Contains(ts[i].root))
            {
                roots.Add(ts[i].root);
            }
        }
        return roots;
    }
    /// <summary>
    /// 获取场景的组件对象
    /// </summary>
    public static T[] FindSceneCmps<T>() where T : Component
    {
        List<Transform> roots = FindSceneRoots();
        List<T> ret = new List<T>();
        for (int i = 0; i < roots.Count; i++)
        {
            ret.AddRange(roots[i].GetComponentsInAllChild<T>());
        }
        ret.TrimSame();
        return ret.ToArray();
        //return FindObjectsOfTypeAll(typeof(T)) as T[];
    }
    /// <summary>
    /// 获取GameObject的布局路径
    /// </summary>
    public static string GetHierarchy(GameObject obj)
    {
        if (obj == null) return "";
        string path = obj.name;

        while (obj.transform.parent != null)
        {
            obj = obj.transform.parent.gameObject;
            path = obj.name + "/" + path;
        }
        return path;
    }
    /// <summary>
    /// 检测给定资源路径是否属于内部资源
    /// </summary>
    public static bool CheckInRes(string path)
    {
        if (string.IsNullOrEmpty(path)) return false;
        return path.StartsWith("Library/") ||
            path.StartsWith("Assets/NGUI/Scripts") ||
            path.StartsWith("Assets/Scene") ||
            path.StartsWith("Assets/Resources") ||
            path.StartsWith("Resources/") ||
            path.StartsWith("Assets/Script") ||
            path.StartsWith("Assets/NGUI/Resources/Shaders");
    }
    /// <summary>
    /// 绘制分割线
    /// </summary>
    /// <param name="lineHeight">线高</param>
    /// <param name="padding">间隔</param>
    public static void DrawSepLine(float lineHeight, float padding = 1f)
    {
        if (lineHeight < 1f) lineHeight = 1f;

        GUILayout.Space(padding * 2f + lineHeight);

        if (Event.current != null && Event.current.type == EventType.Repaint)
        {
            Texture2D tex = EditorGUIUtility.whiteTexture;
            Rect rect = GUILayoutUtility.GetLastRect();
            GUI.color = new Color(0f, 0f, 0f, 0.25f);
            float y = rect.yMin + EditorGUIUtility.standardVerticalSpacing + padding;
            GUI.DrawTexture(new Rect(0f, y, Screen.width, lineHeight), tex);
            if (lineHeight > 2f)
            {
                GUI.DrawTexture(new Rect(0f, y, Screen.width, 1f), tex);
                GUI.DrawTexture(new Rect(0f, y + lineHeight - 1, Screen.width, 1f), tex);
            }
            GUI.color = Color.white;
        }
    }
    /// <summary>
    /// 添加预编译符号
    /// </summary>
    public static void AddScriptingDefineSymbols(params string[] symbols)
    {
        string def = AddScriptingDefineSymbols(PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Standalone), symbols);
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Standalone, def);

        def = AddScriptingDefineSymbols(PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android), symbols);
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, def);

        def = AddScriptingDefineSymbols(PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS), symbols);
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS, def);
    }
    /// <summary>
    /// 移除预编译符号
    /// </summary>
    public static void RemoveScriptingDefineSymbols(params string[] symbols)
    {
        string def = RemoveScriptingDefineSymbols(PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Standalone), symbols);
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Standalone, def);

        def = RemoveScriptingDefineSymbols(PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android), symbols);
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, def);

        def = RemoveScriptingDefineSymbols(PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS), symbols);
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS, def);
    }
    /// <summary>
    /// 添加预编译符号
    /// </summary>
    private static string AddScriptingDefineSymbols(string def, params string[] symbols)
    {
        if (symbols == null) return def;
        foreach (string s in symbols)
        {
            if (string.IsNullOrEmpty(s)) continue;
            if (string.IsNullOrEmpty(def))
            {
                def = s;
            }
            else if (def == s || def.StartsWith(s + ";") || def.EndsWith(";" + s) || def.Contains(";" + s + ";"))
            {
                continue;
            }
            else
            {
                def = def + ";" + s;
            }
        }
        return def;
    }
    /// <summary>
    /// 移除预编译符号
    /// </summary>
    private static string RemoveScriptingDefineSymbols(string def, params string[] symbols)
    {
        if (string.IsNullOrEmpty(def) || symbols == null) return def;
        foreach (string s in symbols)
        {
            if (string.IsNullOrEmpty(s)) continue;
            if (def == s)
            {
                def = string.Empty;
                break;
            }
            else if (def.StartsWith(s + ";"))
            {
                def = def.Substring(s.Length + 1);
            }
            else if (def.EndsWith(";" + s))
            {
                def = def.Substring(0, def.Length - s.Length - 1);
            }
            else if (def.Contains(";" + s + ";"))
            {
                def = def.Replace(";" + s + ";", ";");
            }
        }
        return def;
    }
}