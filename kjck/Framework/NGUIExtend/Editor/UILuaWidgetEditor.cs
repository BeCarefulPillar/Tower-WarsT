using UnityEngine;
using UnityEditor;

[CanEditMultipleObjects]
[CustomEditor(typeof(UILuaWidget))]
public class UILuaWidgetEditor : UIWidgetInspector
{
    protected override bool ShouldDrawProperties()
    {
        NGUIEditorTools.DrawProperty(serializedObject, "mMat", "mat");
        NGUIEditorTools.DrawProperty(serializedObject, "mTexture", "texture");
        NGUIEditorTools.DrawProperty(serializedObject, "mShader", "shader");
        NGUIEditorTools.DrawProperty(serializedObject, "mLua", "luaContainer");
        NGUIEditorTools.DrawProperty(serializedObject, "mOnFill", "onFill");
        return true;
    }
}
