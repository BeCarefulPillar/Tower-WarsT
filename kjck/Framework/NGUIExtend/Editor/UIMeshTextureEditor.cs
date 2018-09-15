using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

[CustomEditor(typeof(UIMeshTexture))]
public class UIMeshTextureEditor : UIWidgetInspector
{
    UIMeshTexture mTex;

    protected override void OnEnable()
    {
        base.OnEnable();
        mTex = target as UIMeshTexture;
    }

    protected override bool ShouldDrawProperties()
    {
        SerializedProperty sp = NGUIEditorTools.DrawProperty("Texture", serializedObject, "mTexture");
        NGUIEditorTools.DrawProperty("Material", serializedObject, "mMat");

        NGUISettings.texture = sp.objectReferenceValue as Texture;

        if (mTex.material == null || serializedObject.isEditingMultipleObjects)
        {
            NGUIEditorTools.DrawProperty("Shader", serializedObject, "mShader");
        }

        EditorGUI.BeginDisabledGroup(serializedObject.isEditingMultipleObjects);
        if (mTex.mainTexture != null)
        {
            Rect rect = EditorGUILayout.RectField("UV Rectangle", mTex.uvRect);

            if (rect != mTex.uvRect)
            {
                NGUIEditorTools.RegisterUndo("UV Rectangle Change", mTex);
                mTex.uvRect = rect;
            }
        }
        EditorGUI.EndDisabledGroup();



        return (sp.objectReferenceValue != null);
    }

    protected override void DrawCustomProperties()
    {
        base.DrawCustomProperties();

        mTex.showGizmos = EditorGUILayout.Toggle("Show Gizmos", mTex.showGizmos);
        EditorGUIUtility.labelWidth = 12;
        Vector2 v2; float v;
        for (int i = 0; i < mTex.PointCount; i++)
        {
            v2 = mTex.GetPoint(i);
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("×", GUILayout.Width(20))) mTex.RemovePoint(i);
            EditorGUILayout.LabelField("P" + i + ":", GUILayout.Width(40));
            v = EditorGUILayout.FloatField("X", v2.x);
            if (v != v2.x) v2.x = v;
            v = EditorGUILayout.FloatField("Y", v2.y);
            if (v != v2.y) v2.y = v;
            EditorGUILayout.EndHorizontal();
            mTex.SetPoint(i, v2);
        }
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("AddPoint", GUILayout.Width(80))) mTex.AddNewPoiint();
        EditorGUILayout.EndHorizontal();
        EditorGUIUtility.labelWidth = 0;

        if (GUI.changed)
        {
            EditorUtility.SetDirty(mTex);
        }
    }

    /// <summary>
    /// Allow the texture to be previewed.
    /// </summary>

    public override bool HasPreviewGUI()
    {
        return (mTex != null) && (mTex.mainTexture as Texture2D != null);
    }

    /// <summary>
    /// Draw the sprite preview.
    /// </summary>

    public override void OnPreviewGUI(Rect rect, GUIStyle background)
    {
        Texture2D tex = mTex.mainTexture as Texture2D;
        if (tex != null) NGUIEditorTools.DrawTexture(tex, rect, mTex.uvRect, mTex.color);
    }

    public new void OnSceneGUI()
    {
        if (mTex.showGizmos)
        {
            Undo.RecordObject(mTex, "Mesh2D Adjust Point");
            Transform trans = mTex.transform;
            for (int i = 0; i < mTex.PointCount; i++)
            {
                Vector3 v = trans.TransformPoint(mTex.GetPoint(i));
                Handles.Label(v, "P" + i);
                //Vector2 v2 = Handles.DoPositionHandle(v, Quaternion.identity);
                Vector2 v2 = Handles.PositionHandle(v, Quaternion.identity);
                if (v2 != (Vector2)v)
                {
                    mTex.SetPoint(i, trans.InverseTransformPoint(v2));
                    EditorUtility.SetDirty(mTex);
                }
            }
        }
    }
}
