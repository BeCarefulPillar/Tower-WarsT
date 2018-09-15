using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

[CustomEditor(typeof(SerializeRef))]
public class SerializeRefEditor : Editor
{
    private static GUIContent empty = new GUIContent("");
    private static List<Object> list = new List<Object>();

    private static Object[] GetRefs(Object o)
    {
        GameObject go = (o is GameObject) ? (o as GameObject) : (o as Component).gameObject;
        list.Clear();
        list.AddRange(go.GetComponents<Component>());
        list.Add(go);
        list.RemoveAll(r => { return r == null; });
        return list.ToArray();
    }

    private static string[] GetRefNames(Object[] refs)
    {
        string[] strs = new string[refs.Length];
        for (int i = 0; i < strs.Length; ++i)
        {
            strs[i] = refs[i].GetType().Name;
        }
        return strs;
    }

    private static int FindIndex(Object[] refs, Object o)
    {
        int index = 0;
        for (int i = 0; i < refs.Length; ++i)
        {
            if (refs[i] == o)
            {
                index = i;
                break;
            }
        }
        return index;
    }

    public override void OnInspectorGUI()
    {
        //obj
        SerializedProperty obj = serializedObject.FindProperty("obj");
        if (EditorGUILayout.PropertyField(obj))
        {
            ++EditorGUI.indentLevel;
            obj.arraySize = EditorGUILayout.DelayedIntField("个数", obj.arraySize);
            for (int i = 0; i < obj.arraySize; ++i)
            {
                var qyo = obj.GetArrayElementAtIndex(i);

                EditorGUILayout.BeginHorizontal();
                //{
                EditorGUILayout.PropertyField(qyo.FindPropertyRelative("name"), empty);
                EditorGUILayout.PropertyField(qyo.FindPropertyRelative("o"), empty);

                Object value = qyo.FindPropertyRelative("o").objectReferenceValue;
                if (value && (value is GameObject || value is Component))
                {
                    Object[] refs = GetRefs(value);
                    int index = FindIndex(refs, value);
                    int idx = EditorGUILayout.Popup(index, GetRefNames(refs), GUILayout.Width(100.0f));
                    if (idx != index)
                        qyo.FindPropertyRelative("o").objectReferenceValue = refs[idx];
                }
                //}
                EditorGUILayout.EndHorizontal();
            }
            --EditorGUI.indentLevel;
        }

        //objs
        var objs = this.serializedObject.FindProperty("objs");
        if (EditorGUILayout.PropertyField(objs))
        {
            ++EditorGUI.indentLevel;
            objs.arraySize = EditorGUILayout.DelayedIntField("个数", objs.arraySize);
            for (int i = 0; i < objs.arraySize; ++i)
            {
                var qyos = objs.GetArrayElementAtIndex(i);

                if (EditorGUILayout.PropertyField(qyos))
                {
                    EditorGUILayout.BeginHorizontal();
                    //{
                    EditorGUILayout.PropertyField(qyos.FindPropertyRelative("name"), empty);
                    var values = qyos.FindPropertyRelative("o");
                    values.arraySize = EditorGUILayout.DelayedIntField(empty, values.arraySize);
                    //}
                    EditorGUILayout.EndHorizontal();

                    for (int j = 0; j < values.arraySize; ++j)
                    {
                        EditorGUILayout.BeginHorizontal();
                        //{
                        EditorGUILayout.PropertyField(values.GetArrayElementAtIndex(j));
                        Object value = values.GetArrayElementAtIndex(j).objectReferenceValue;
                        if (value && (value is GameObject || value is Component))
                        {
                            Object[] refs = GetRefs(value);
                            int index = FindIndex(refs, value);
                            int idx = EditorGUILayout.Popup(index, GetRefNames(refs), GUILayout.Width(100.0f));
                            if (idx != index)
                                values.GetArrayElementAtIndex(j).objectReferenceValue = refs[idx];
                        }
                        //}
                        EditorGUILayout.EndHorizontal();
                    }
                }
            }
            --EditorGUI.indentLevel;
        }

        serializedObject.ApplyModifiedProperties();
    }
}