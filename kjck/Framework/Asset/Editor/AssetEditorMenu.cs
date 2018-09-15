using UnityEditor;
using UnityEngine;

public static class AssetEditorMenu
{
    [MenuItem("资源管理/参数配置")]
    public static void OpenSetting()
    {
        EditorWindow.GetWindow<JW_Setting>(false, "参数配置", true).Show();
    }
    [MenuItem("资源管理/资源树")]
    public static void OpenAssetTree()
    {
        EditorWindow.GetWindow<JW_AssetTree>(false, "资源树", true).Show();
    }
    [MenuItem("资源管理/搜索器")]
    public static void OpenAssetSearcher()
    {
        EditorWindow.GetWindow<JW_AssetSearcher>(false, "资源搜索器", true).Show();
    }

    [MenuItem("资源管理/打包器")]
    public static void OpenAssetManager()
    {
        EditorWindow.GetWindow<JW_AssetManager>(false, "资源管理器", true).Show();
    }

    [MenuItem("资源管理/调整器")]
    public static void OpenAssetAdjust()
    {
        EditorWindow.GetWindow<JW_AssetAdjust>(false, "资源调整器", true).Show();
    }
}
