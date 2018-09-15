#if TOLUA
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(LuaSerializeRef), true)]
public class LuaSerEditor : Editor
{
    private static List<Component> list = new List<Component>(8);
    private static GUIStyle style = null;
    private static int cmpSize = -1;

    private void OnEnable()
    {
        cmpSize = -1;
        if (style == null)
        {
            style = new GUIStyle();
            style.normal.textColor = EditorGUIUtility.isProSkin ? new Color(1f, 1f, 1f, 0.7f) : new Color(0f, 0f, 0f, 0.7f);
        }
    }

    private static string[] GetPop(Component cmp)
    {
        cmp.GetComponents(list);
        string[] pop = new string[list.Count];
        for (int i = 0; i < pop.Length; i++)
        {
            pop[i] = list[i].GetType().Name;
        }
        return pop;
    }

    public override void OnInspectorGUI()
    {
        EditorGUILayout.PropertyField(serializedObject.FindProperty("gameObjects"), true);
        EditorGUILayout.PropertyField(serializedObject.FindProperty("widgets"), true);
        EditorGUILayout.PropertyField(serializedObject.FindProperty("buttons"), true);

        EditorGUILayout.BeginHorizontal();
        GUILayout.Space(-11f);
        bool toggle = EditorPrefs.GetBool("LuaSerEditor.Cmps", false);
        toggle = GUILayout.Toggle(toggle, toggle ? "\u25BCCmps" : "\u25BACmps", style, GUILayout.MinWidth(20f));
        if (GUI.changed) EditorPrefs.SetBool("LuaSerEditor.Cmps", toggle);
        EditorGUILayout.EndHorizontal();
        if (toggle)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(15f);
            EditorGUILayout.BeginVertical();
            EditorGUIUtility.labelWidth = 150f;
            SerializedProperty sp = serializedObject.FindProperty("cmps");
            EditorGUILayout.BeginHorizontal();
            cmpSize = EditorGUILayout.IntField("Size", cmpSize < 0 ? sp.arraySize : cmpSize);
            if(cmpSize != sp.arraySize && GUILayout.Button("Apply", GUILayout.Width(100))) sp.arraySize = cmpSize;
            EditorGUILayout.EndHorizontal();
            SerializedProperty c;
            Component cmp;
            for (int i = 0; i < sp.arraySize; i++)
            {
                c = sp.GetArrayElementAtIndex(i);
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PropertyField(c);
                cmp = c.objectReferenceValue as Component;
                if (cmp)
                {
                    int index = 0;
                    cmp.GetComponents(list);
                    string[] pop = new string[list.Count];
                    for (int j = 0; j < pop.Length; j++)
                    {
                        if (cmp == list[j]) index = j;
                        pop[j] = list[j].GetType().Name;
                    }
                    int idx = EditorGUILayout.Popup(index, GetPop(cmp), GUILayout.Width(100f));
                    if (index != idx)
                    {
                        c.objectReferenceValue = list[idx];
                    }
                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUIUtility.labelWidth = 0f;
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndHorizontal();
        }
        

        EditorGUILayout.PropertyField(serializedObject.FindProperty("objects"), true);
        EditorGUILayout.PropertyField(serializedObject.FindProperty("curves"), true);

        serializedObject.ApplyModifiedProperties();
    }
}
#endif