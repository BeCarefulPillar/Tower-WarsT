using UnityEditor;
using UnityEngine;

[CanEditMultipleObjects]
[CustomEditor(typeof(UIMultiTexture), true)]
public class UIMultiTextureEditor : UIMultiWidgetEditor
{
    private UIMultiTexture mTex;

    protected override void OnEnable()
    {
        base.OnEnable();
        mTex = target as UIMultiTexture;
    }

    protected override bool ShouldDrawProperties()
    {
        SerializedProperty sp = NGUIEditorTools.DrawProperty("Texture", serializedObject, "mTexture");
        NGUIEditorTools.DrawProperty("Material", serializedObject, "mMat");

        if (sp != null) NGUISettings.texture = sp.objectReferenceValue as Texture;

        if (mTex != null && (mTex.material == null || serializedObject.isEditingMultipleObjects))
        {
            NGUIEditorTools.DrawProperty("Shader", serializedObject, "mShader");
        }

        NGUIEditorTools.DrawProperty("isMulti", serializedObject, "mMulti");

        if (!mTex.isMulti)
        {
            sp = serializedObject.FindProperty("mUVs");
            if (sp.arraySize < 1)
            {
                sp.arraySize = 1;
                sp.GetArrayElementAtIndex(0).rectValue = new Rect(0f, 0f, 1f, 1f);
            }
            NGUIEditorTools.DrawProperty("Rect", sp.GetArrayElementAtIndex(0));
        }

        return base.ShouldDrawProperties();
    }

    protected override void OnDeleteUnitAt(int idx)
    {
        serializedObject.FindProperty("mUVs").DeleteArrayElementAtIndex(idx);
    }

    protected override void OnDrawUnit(int size)
    {
        if (mTex.isMulti)
        {
            SerializedProperty uvs = serializedObject.FindProperty("mUVs");
            if (uvs.arraySize != size)
            {
                uvs.arraySize = size;
                if (size == 1)
                {
                    uvs.GetArrayElementAtIndex(0).rectValue = new Rect(0f, 0f, 1f, 1f);
                }
            }
            NGUIEditorTools.DrawProperty("Rect", uvs.GetArrayElementAtIndex(mSltIdx));
        }
    }

    public override bool HasPreviewGUI()
    {
        return (Selection.activeGameObject == null || Selection.gameObjects.Length == 1) &&
            (mTex != null) && (mTex.mainTexture as Texture2D != null);
    }

    public override void OnPreviewGUI(Rect rect, GUIStyle background)
    {
        UIMultiWidget.Unit u = mTex ? mTex.GetUnit(mSltIdx) : null;
        if (u == null) return;

        Texture2D tex = mTex.mainTexture as Texture2D;

        if (tex != null)
        {
            Rect tc = mTex.GetUV(mSltIdx);
            tc.xMin *= tex.width;
            tc.xMax *= tex.width;
            tc.yMin *= tex.height;
            tc.yMax *= tex.height;
            NGUIEditorTools.DrawSprite(tex, rect, mTex.color * u.color, tc, mTex.border);
        }
    }
}