using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

[CustomEditor(typeof(AssetManager))]
public class AssetManagerEditor : Editor
{
    private bool showAvailableName = false;
    public override void OnInspectorGUI()
    {
        AssetManager am = target as AssetManager;
        am.showInfoPanel = EditorGUILayout.Toggle("Show Info Panel", am.showInfoPanel);
        EditorGUILayout.LabelField("Asset Count : " + AssetManager.assetCount);
        int a, b;
        AssetManager.GetAssetStatic(out a, out b);
        EditorGUILayout.LabelField("Asset Available Count : " + a);
        EditorGUILayout.LabelField("Asset Invalid Count : " + b);
        EditorGUILayout.LabelField("Memory : " + AssetManager.assetMemory);
        EditorGUILayout.LabelField("Asset On Loading : " + AssetManager.assetLoadingCount);
        EditorGUILayout.LabelField("Asset On Wait : " + AssetManager.assetLoadWaitCount);

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("UnLoad UnUse", GUILayout.Width(100)))
        {
            AssetManager.UnLoadAsset(100);
        }
        if (GUILayout.Button("UnLoad All", GUILayout.Width(100)))
        {
            AssetManager.UnloadAllAsset();
        }
        if (GUILayout.Button(showAvailableName ? "Hide Name" : "Show Name", GUILayout.Width(100)))
        {
            showAvailableName = !showAvailableName;
        }
        EditorGUILayout.EndHorizontal();

        if (showAvailableName)
        {
            List<Asset> list = AssetManager.GetAvailableAssets();
            for (int i = 0; i < list.Count; i++)
            {
                EditorGUILayout.LabelField((i + 1) + " " + list[i].name);
            }
        }
    }

    public void OnSceneGUI()
    {
        Repaint();
    }
}
