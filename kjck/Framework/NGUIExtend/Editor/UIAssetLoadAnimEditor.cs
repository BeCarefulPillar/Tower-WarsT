using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(UIAssetLoadAnim))]
public class UIAssetLoadAnimEditor : UIWidgetInspector
{
    protected override bool ShouldDrawProperties()
    {
        if (target == null) return false;

        NGUIEditorTools.DrawProperty("ShowMask", serializedObject, "showMask");

        return true;
    }
}