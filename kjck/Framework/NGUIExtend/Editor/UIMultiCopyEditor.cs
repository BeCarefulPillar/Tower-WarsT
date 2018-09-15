using UnityEngine;
using UnityEditor;

[CanEditMultipleObjects]
[CustomEditor(typeof(UIMultiCopy))]
public class UIMultiCopyEditor : UIMultiWidgetEditor
{
    protected override bool ShouldDrawProperties()
    {
        SerializedProperty sp = NGUIEditorTools.DrawProperty(serializedObject, "mCopy", "Target");
        if (sp.objectReferenceValue)
        {
            if (sp.objectReferenceValue == target)
            {
                sp.objectReferenceValue = null;
                Debug.LogWarning("do not set self as target");
            }
            else
            {
                (target as MonoBehaviour).enabled = true;
            }
        }
        NGUIEditorTools.DrawProperty(serializedObject, "mFollowRotation", "FollowRotation");
        NGUIEditorTools.DrawProperty(serializedObject, "mFollowScale", "FollowScale");

        return base.ShouldDrawProperties();
    }

    protected override bool hasAnima { get { return false; } }
}
