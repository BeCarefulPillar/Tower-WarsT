#if TOLUA
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(LuaButton), true)]
public class LuaButtonEditor : Editor
{
    private static List<Component> list = new List<Component>(8);

    public override void OnInspectorGUI()
    {
        NGUIEditorTools.DrawProperty(serializedObject, "mLuaContainer", "LuaContainer");
        NGUIEditorTools.DrawProperty(serializedObject, "mNguiButton", "NguiButton");
        NGUIEditorTools.DrawProperty(serializedObject, "mLbl", "Label");

        EditorGUILayout.BeginHorizontal();
        SerializedProperty sp = serializedObject.FindProperty("mTransfer");
        NGUIEditorTools.DrawProperty("Transfer", sp);
        Object obj = sp.objectReferenceValue;
        string[] pops = null;
        if (obj is GameObject)
        {
            (obj as GameObject).GetComponents(list);
            pops = new string[list.Count + 1];
        }
        else if (obj is Component)
        {
            (obj as Component).GetComponents(list);
            pops = new string[list.Count + 1];
        }
        if (pops != null)
        {
            int index = 0;
            pops[0] = "GameObject";
            for (int i = 1; i < pops.Length; i++)
            {
                pops[i] = list[i - 1].GetType().Name;
                if (list[i - 1] == obj) index = i;
            }
            int idx = EditorGUILayout.Popup(index, pops, GUILayout.Width(100f));
            if (index != idx)
            {
                if (idx < 1)
                {
                    sp.objectReferenceValue = obj is GameObject ? obj as GameObject : (obj as Component).gameObject;
                }
                else
                {
                    sp.objectReferenceValue = list[idx - 1];
                }
            }
        }

        EditorGUILayout.EndHorizontal();

        NGUIEditorTools.DrawProperty(serializedObject, "mOnClick", "OnClick");
        NGUIEditorTools.DrawProperty(serializedObject, "mOnDoubleClick", "OnDoubleClick");
        NGUIEditorTools.DrawProperty(serializedObject, "mOnPress", "OnPress");
        NGUIEditorTools.DrawProperty(serializedObject, "mOnDrag", "OnDrag");
        NGUIEditorTools.DrawProperty(serializedObject, "mOnSelect", "OnSelect");
        NGUIEditorTools.DrawProperty(serializedObject, "mOnScroll", "OnScroll");
        NGUIEditorTools.DrawProperty(serializedObject, "mOnTooltip", "OnTooltip");

        serializedObject.ApplyModifiedProperties();
    }
}
#endif