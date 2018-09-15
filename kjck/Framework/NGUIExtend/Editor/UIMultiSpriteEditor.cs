using UnityEngine;
using UnityEditor;

[CanEditMultipleObjects]
[CustomEditor(typeof(UIMultiSprite), true)]
public class UIMultiSpriteEditor : UIMultiWidgetEditor
{
    private UIMultiSprite mSp;

    protected override void OnEnable()
    {
        base.OnEnable();
        mSp = target as UIMultiSprite;
    }

    void OnSelectAtlas(Object obj)
    {
        serializedObject.Update();
        SerializedProperty sp = serializedObject.FindProperty("mAtlas");
        sp.objectReferenceValue = obj;
        serializedObject.ApplyModifiedProperties();
        NGUITools.SetDirty(serializedObject.targetObject);
        NGUISettings.atlas = obj as UIAtlas;
    }

    void SelectSprite(string spriteName)
    {
        if (mSp)
        {
            serializedObject.Update();
            SerializedProperty sp = serializedObject.FindProperty("mSpriteNames");
            if(sp.arraySize > 0)
            {
                if (mSp.isMulti)
                {
                    if (mSltIdx >= 0 && mSltIdx < sp.arraySize)
                    {
                        sp.GetArrayElementAtIndex(mSltIdx).stringValue = spriteName;
                        mSp.ClearCache(mSltIdx);
                    }
                }
                else
                {
                    sp.GetArrayElementAtIndex(0).stringValue = spriteName;
                    mSp.ClearCache(0);
                }
                serializedObject.ApplyModifiedProperties();
                NGUITools.SetDirty(serializedObject.targetObject);
                NGUISettings.selectedSprite = spriteName;
            }
        }
    }

    protected override bool ShouldDrawProperties()
    {
        GUILayout.BeginHorizontal();
        if (NGUIEditorTools.DrawPrefixButton("Atlas")) ComponentSelector.Show<UIAtlas>(OnSelectAtlas);
        SerializedProperty atlas = NGUIEditorTools.DrawProperty("", serializedObject, "mAtlas", GUILayout.MinWidth(20f));

        if (GUILayout.Button("Edit", GUILayout.Width(40f)))
        {
            if (atlas != null)
            {
                UIAtlas atl = atlas.objectReferenceValue as UIAtlas;
                NGUISettings.atlas = atl;
                if (atl != null) NGUIEditorTools.Select(atl.gameObject);
            }
        }
        GUILayout.EndHorizontal();

        if (!mSp.isMulti)
        {
            SerializedProperty sp = serializedObject.FindProperty("mSpriteNames");
            if (sp.arraySize < 1) sp.arraySize = 1;
            sp = sp.GetArrayElementAtIndex(0);
            NGUIEditorTools.DrawAdvancedSpriteField(atlas.objectReferenceValue as UIAtlas, sp.stringValue, SelectSprite, false);
        }

        NGUIEditorTools.DrawProperty("Material", serializedObject, "mMat");
        NGUIEditorTools.DrawProperty("isMulti", serializedObject, "mMulti");

        return base.ShouldDrawProperties();
    }

    protected override void OnDeleteUnitAt(int idx)
    {
        mSp.RemoveSprite(idx);
        //serializedObject.FindProperty("mUVs").DeleteArrayElementAtIndex(idx);
    }

    protected override void OnDrawUnit(int size)
    {
        if (mSp.isMulti)
        {
            SerializedProperty sp = serializedObject.FindProperty("mSpriteNames");
            if (sp.arraySize != size) sp.arraySize = size;
            sp = sp.GetArrayElementAtIndex(mSltIdx);
            NGUIEditorTools.DrawAdvancedSpriteField(serializedObject.FindProperty("mAtlas").objectReferenceValue as UIAtlas, sp.stringValue, SelectSprite, false);
        }
    }

    public override bool HasPreviewGUI()
    {
        return (Selection.activeGameObject == null || Selection.gameObjects.Length == 1);
    }

    public override void OnPreviewGUI(Rect rect, GUIStyle background)
    {
        UIMultiWidget.Unit u = mSp ? mSp.GetUnit(mSltIdx) : null;
        if (u == null) return;

        Texture2D tex = mSp.mainTexture as Texture2D;
        if (tex == null) return;

        string spn = mSp.GetSprite(mSltIdx);
        if (string.IsNullOrEmpty(spn)) return;

        UISpriteData sd = mSp.atlas.GetSprite(spn);
        NGUIEditorTools.DrawSprite(tex, rect, sd, mSp.color * u.color);
    }
}
