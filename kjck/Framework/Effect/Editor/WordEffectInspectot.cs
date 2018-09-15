using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(WordEffect))]
public class WordEffectInspectot : Editor
{
    WordEffect effect;

    public override void OnInspectorGUI()
    {
        effect = target as WordEffect;

        EditorGUIUtility.labelWidth = 80f;

        effect.Font = EditorGUILayout.ObjectField("Font", effect.Font, typeof(Font), false) as Font;
        
        if (effect.Font == null) return;

        int size = EditorGUILayout.IntField("Font Size", effect.FontSize);
        if (effect.FontSize != size) effect.FontSize = size;

        float width = EditorGUILayout.FloatField("MaxWidth", effect.MaxWidth);
        if (effect.MaxWidth != width) effect.MaxWidth = width;

        float lineSpace = EditorGUILayout.FloatField("LineSpace", effect.LineSpace);
        if (effect.LineSpace != lineSpace) effect.LineSpace = lineSpace;

        bool ver = EditorGUILayout.Toggle("Vertical", effect.Vertical);
        if (effect.Vertical != ver) effect.Vertical = ver;

        GUI.skin.textArea.wordWrap = true;
        string text = string.IsNullOrEmpty(effect.Text) ? "" : effect.Text;
        text = EditorGUILayout.TextArea(effect.Text, GUI.skin.textArea, GUILayout.Height(100f));
        if (!text.Equals(effect.Text)) { effect.Text = text; }

        UIWidget.Pivot pivot = (UIWidget.Pivot)EditorGUILayout.EnumPopup("Pivot", effect.Pivot);
        if (effect.Pivot != pivot) effect.Pivot = pivot;

        int depth = EditorGUILayout.IntField("Depth", effect.Depth);
        if (effect.Depth != depth)
        {
            effect.Depth = depth;
            NGUIEditorTools.RegisterUndo("Depth Change", effect);
        } 

        Color color = EditorGUILayout.ColorField("Text Color", effect.Color);
        if (effect.Color != color) { effect.Color = color; NGUIEditorTools.RegisterUndo("Color Change", effect); }

        WordEffect.EffectStyle wordEffect = (WordEffect.EffectStyle)EditorGUILayout.EnumPopup("Effect Style", effect.Effect);
        if (effect.Effect != wordEffect) effect.Effect = wordEffect;

        float sleep = EditorGUILayout.FloatField("Sleep", effect.Sleep);
        if (sleep != effect.Sleep) effect.Sleep = sleep;
        float rate = EditorGUILayout.FloatField("Rate", effect.Rate);
        if (rate != effect.Rate) effect.Rate = rate;
        float sTime = EditorGUILayout.FloatField("Single Time", effect.STime);
        if (sTime != effect.STime) effect.STime = sTime;

        if (GUI.changed)
        {
            UnityEditor.EditorUtility.SetDirty(effect);
        }
    }
}
