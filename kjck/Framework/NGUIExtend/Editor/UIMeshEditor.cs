using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(UIMesh))]
public class UIMeshEditor : UIWidgetInspector
{
    UIMesh mMesh;

    protected override void OnEnable()
    {
        base.OnEnable();
        mMesh = target as UIMesh;
    }

    protected override bool ShouldDrawProperties()
    {
        SerializedProperty sp = NGUIEditorTools.DrawProperty("Texture", serializedObject, "mTexture");
        NGUIEditorTools.DrawProperty("Material", serializedObject, "mMat");

        NGUISettings.texture = sp.objectReferenceValue as Texture;

        if (mMesh.material == null || serializedObject.isEditingMultipleObjects)
        {
            NGUIEditorTools.DrawProperty("Shader", serializedObject, "mShader");
        }

        NGUIEditorTools.DrawProperty("Mesh", serializedObject, "mMesh");
        NGUIEditorTools.DrawRectProperty("UV Rect", serializedObject, "mRect");

        if (GUI.changed) mMesh.ReBuild();

        return true;
    }
}