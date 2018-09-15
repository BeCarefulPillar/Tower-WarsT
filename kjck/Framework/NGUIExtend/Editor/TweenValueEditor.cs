using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(TweenValue))]
public class TweenValueEditor : UITweenerEditor
{
    public override void OnInspectorGUI()
    {
        GUILayout.Space(6f);
        NGUIEditorTools.SetLabelWidth(120f);

        TweenValue tv = target as TweenValue;
        GUI.changed = false;

        float from = EditorGUILayout.FloatField("From", tv.from);
        float to = EditorGUILayout.FloatField("To", tv.to);

        if (GUI.changed)
        {
            NGUIEditorTools.RegisterUndo("Tween Change", tv);
            tv.from = from;
            tv.to = to;
            UnityEditor.EditorUtility.SetDirty(tv);
        }

        DrawCommonProperties();
    }
}