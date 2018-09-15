using UnityEditor;
using UnityEngine;
using System.Collections;

[CustomEditor(typeof(UISpriteUV))]
public class UISpriteUVEditor : UIWidgetInspector
{
    UISpriteUV mSprite;

    protected override void OnEnable()
    {
        base.OnEnable();
        mSprite = target as UISpriteUV;
    }

    /// <summary>
    /// 图集选择回调.
    /// </summary>
    void OnSelectAtlas(Object obj)
    {
        mSprite.atlas = obj as UIAtlas;
        NGUITools.SetDirty(serializedObject.targetObject);
        NGUISettings.atlas = obj as UIAtlas;
    }

    /// <summary>
    /// 精灵选择回调.
    /// </summary>
    void SelectSprite(string spriteName)
    {
        mSprite.spriteName = spriteName;
        NGUITools.SetDirty(serializedObject.targetObject);
        NGUISettings.selectedSprite = spriteName;
    }

    protected override bool ShouldDrawProperties()
    {
        GUILayout.BeginHorizontal();
        if (NGUIEditorTools.DrawPrefixButton("Atlas", GUILayout.Width(64f))) ComponentSelector.Show<UIAtlas>(OnSelectAtlas);
        mSprite.atlas = EditorGUILayout.ObjectField(mSprite.atlas, typeof(UIAtlas), false) as UIAtlas;
        if (GUILayout.Button("Edit", GUILayout.Width(40f)))
        {
            if (mSprite.atlas)
            {
                NGUISettings.atlas = mSprite.atlas;
                NGUIEditorTools.Select(mSprite.atlas.gameObject);
            }
        }
        GUILayout.EndHorizontal();
        if (mSprite.atlas) NGUIEditorTools.DrawAdvancedSpriteField(mSprite.atlas, mSprite.spriteName, SelectSprite, false);

        mSprite.wrapMode = (TextureWrapMode)EditorGUILayout.EnumPopup("Wrap Mode", mSprite.wrapMode);

        mSprite.uvRect = EditorGUILayout.RectField("UV Rect", mSprite.uvRect);

        if (mSprite.isChanged) EditorUtility.SetDirty(mSprite);

        return true;
    }
}