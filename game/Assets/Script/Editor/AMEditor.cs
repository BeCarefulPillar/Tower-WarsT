using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;

[CustomEditor(typeof(AM))]
public class AMEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (!AM.ins)
            return;
        Dictionary<string, Asset> dic = AM.ins.dic;
        foreach (KeyValuePair<string, Asset> e in dic)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.ObjectField(e.Value.res, typeof(Object), false);
            EditorGUILayout.IntField(e.Value.refs.Count);
            EditorGUILayout.EndHorizontal();
        }
    }
}