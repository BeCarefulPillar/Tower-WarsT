using UnityEngine;
using UnityEditor;

[CanEditMultipleObjects]
[CustomEditor(typeof(UICopy))]
public class UICopyEditor : UIWidgetInspector
{
    protected override bool ShouldDrawProperties()
    {
        NGUIEditorTools.DrawProperty(serializedObject, "mCopy", "Target");
        return true;
    }
}
