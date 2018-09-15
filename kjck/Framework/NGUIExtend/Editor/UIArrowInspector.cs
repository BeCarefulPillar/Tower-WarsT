using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(UIArrow), true)]
public class UIArrowInspector : UIWidgetInspector
{
    void OnSelectAtlas(Object obj)
    {
        serializedObject.Update();
        SerializedProperty sp = serializedObject.FindProperty("mAtlas");
        sp.objectReferenceValue = obj;
        serializedObject.ApplyModifiedProperties();
        NGUISettings.atlas = obj as UIAtlas;
    }

    void SelectSprite(string spriteName)
    {
        serializedObject.Update();
        SerializedProperty sp = serializedObject.FindProperty("mSpriteName");
        sp.stringValue = spriteName;
        serializedObject.ApplyModifiedProperties();
        NGUISettings.selectedSprite = spriteName;
    }

    protected override bool ShouldDrawProperties()
    {
        GUILayout.BeginHorizontal();
        if (NGUIEditorTools.DrawPrefixButton("Atlas"))
            ComponentSelector.Show<UIAtlas>(OnSelectAtlas);
        SerializedProperty atlas = NGUIEditorTools.DrawProperty("", serializedObject, "mAtlas", GUILayout.MinWidth(20f));

        if (GUILayout.Button("Edit", GUILayout.Width(40f)))
        {
            if (atlas != null)
            {
                UIAtlas atl = atlas.objectReferenceValue as UIAtlas;
                NGUISettings.atlas = atl;
                NGUIEditorTools.Select(atl.gameObject);
            }
        }
        GUILayout.EndHorizontal();

        SerializedProperty sp = serializedObject.FindProperty("mSpriteName");
        NGUIEditorTools.DrawAdvancedSpriteField(atlas.objectReferenceValue as UIAtlas, sp.stringValue, SelectSprite, false);
        return true;
    }

    public override bool HasPreviewGUI() { return !serializedObject.isEditingMultipleObjects; }

    public override void OnPreviewGUI(Rect rect, GUIStyle background)
    {
        UISprite sprite = target as UISprite;
        if (sprite == null || !sprite.isValid) return;

        Texture2D tex = sprite.mainTexture as Texture2D;
        if (tex == null) return;

        UISpriteData sd = sprite.atlas.GetSprite(sprite.spriteName);
        if (sd != null)//add by kiol 2015.11.17
        {
            if (sprite.atlas.spriteMaterial.IsMergeShader())
            {
                int idx = sd.x / tex.width;
                if (idx > 0)
                {
                    tex = sprite.atlas.spriteMaterial.GetMergeTexture(idx) as Texture2D;
                    if (tex)
                    {
                        UISpriteData sp = new UISpriteData();
                        sp.CopyFrom(sd);
                        sp.x %= tex.width;
                        sd = sp;
                    }
                }
            }
        }
        NGUIEditorTools.DrawSprite(tex, rect, sd, sprite.color);
    }

}
