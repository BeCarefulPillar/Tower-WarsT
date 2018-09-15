using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

/// <summary>
/// Inspector class used to edit UIRepeat.
/// </summary>

[CustomEditor(typeof(UIRepeat))]
public class UIRepeatInspector :UIWidgetInspector
{
    public UIRepeat repeat;

    /// <summary>
    /// 图集选择回调
    /// </summary>
    void OnSelectAtlas(Object obj)
    {
        if (repeat != null && !repeat.Atlas.Equals(obj))
        {
            NGUIEditorTools.RegisterUndo("Atlas Selection", repeat);
            repeat.Atlas = obj as UIAtlas;
            repeat.MakePixelPerfect();
            EditorUtility.SetDirty(repeat.gameObject);
        }
    }

    /// <summary>
    /// 精灵选择回调
    /// </summary>
    void SelectFrontSprite(string spriteName)
    {
        if (repeat != null && repeat.FrontSpriteName != spriteName)
        {
            NGUIEditorTools.RegisterUndo("Sprite Change", repeat);
            repeat.FrontSpriteName = spriteName;
            repeat.MakePixelPerfect();
            EditorUtility.SetDirty(repeat.gameObject);
        }
    }
    void SelectExtendSprite(string spriteName)
    {
        if (repeat != null && repeat.ExtendSpriteName != spriteName)
        {
            NGUIEditorTools.RegisterUndo("Sprite Change", repeat);
            repeat.ExtendSpriteName = spriteName;
            repeat.MakePixelPerfect();
            EditorUtility.SetDirty(repeat.gameObject);
        }
    }
    void SelectBackSprite(string spriteName)
    {
        if (repeat != null && repeat.BackSpriteName != spriteName)
        {
            NGUIEditorTools.RegisterUndo("Sprite Change", repeat);
            repeat.BackSpriteName = spriteName;
            repeat.MakePixelPerfect();
            EditorUtility.SetDirty(repeat.gameObject);
        }
    }

    override protected bool ShouldDrawProperties()
    {
        if (base.ShouldDrawProperties())
        {
            repeat = mWidget as UIRepeat;

            ComponentSelector.Draw<UIAtlas>(repeat.Atlas, OnSelectAtlas, true);
            if (repeat.Atlas == null) return false;
            
            NGUIEditorTools.DrawAdvancedSpriteField(repeat.Atlas, repeat.BackSpriteName, SelectBackSprite, false);

            Color bColor = EditorGUILayout.ColorField("Back Color", repeat.BackColor);
            if (repeat.BackColor != bColor)
            {
                repeat.BackColor = bColor;
                NGUIEditorTools.RegisterUndo("Color Change", repeat);
            }

            NGUIEditorTools.DrawAdvancedSpriteField(repeat.Atlas, repeat.FrontSpriteName, SelectFrontSprite, false);

            Color fColor = EditorGUILayout.ColorField("Front Color", repeat.FrontColor);
            if (repeat.FrontColor != fColor)
            {
                repeat.FrontColor = fColor;
                NGUIEditorTools.RegisterUndo("Color Change", repeat);
            }

            NGUIEditorTools.DrawAdvancedSpriteField(repeat.Atlas, repeat.ExtendSpriteName, SelectExtendSprite, false);

            Color eColor = EditorGUILayout.ColorField("Extend Color", repeat.ExtendColor);
            if (repeat.ExtendColor != eColor)
            {
                repeat.ExtendColor = eColor;
                NGUIEditorTools.RegisterUndo("Color Change", repeat);
            }

            int count = EditorGUILayout.IntField("Count", repeat.Count);
            if (count != repeat.Count)
            {
                repeat.Count = Mathf.Clamp(count, 0, repeat.TotalCount - repeat.ExtendCount);
                NGUIEditorTools.RegisterUndo("Count Change", repeat);
            }

            int extendCount = EditorGUILayout.IntField("Extend Count", repeat.ExtendCount);
            if (extendCount != repeat.ExtendCount)
            {
                repeat.ExtendCount = Mathf.Clamp(extendCount, 0, repeat.TotalCount - repeat.Count);
                NGUIEditorTools.RegisterUndo("Count Change", repeat);
            }

            int totalCount = EditorGUILayout.IntField("Total Count", repeat.TotalCount);
            if (totalCount != repeat.TotalCount)
            {
                repeat.TotalCount = Mathf.Max(0, totalCount);
                NGUIEditorTools.RegisterUndo("Count Change", repeat);
            }

            float space = EditorGUILayout.FloatField("Space", repeat.Spacing);
            if (space != repeat.Spacing)
            {
                repeat.Spacing = space;
                NGUIEditorTools.RegisterUndo("Sprite Change", repeat);
            }

            UIRepeat.Arrangement agm = (UIRepeat.Arrangement)EditorGUILayout.EnumPopup("Arrangement", repeat.arrangement);
            if (agm != repeat.arrangement)
            {
                repeat.arrangement = agm;
                NGUIEditorTools.RegisterUndo("Arrangement Change", repeat);
            }
            return true;
        }
        return false;
    }

    //public override void OnPreviewGUI(Rect rect, GUIStyle background)
    //{
    //    base.OnPreviewGUI(rect, background);
    //}
}