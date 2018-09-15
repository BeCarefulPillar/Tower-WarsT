using UnityEngine;
using UnityEditor;

[CanEditMultipleObjects]
[CustomEditor(typeof(UIMultiWidget), true)]
public class UIMultiWidgetEditor : UIWidgetInspector
{
    protected int mSltIdx = 0;
    protected GUIStyle mStyle = new GUIStyle();

    protected override void OnEnable()
    {
        base.OnEnable();
        mStyle.fontStyle = FontStyle.Bold;
        mStyle.normal.textColor = Color.white;
    }
    
    protected override bool ShouldDrawProperties()
    {
        NGUIEditorTools.DrawProperty("isActualBounds", serializedObject, "mActualBounds");
        SerializedProperty sp = serializedObject.FindProperty("mAnimTime");
        if (hasAnima)
        {
            if (EditorGUILayout.Toggle("isAnima", sp.floatValue > 0))
            {
                if (sp.floatValue <= 0f) sp.floatValue = 1f;
                NGUIEditorTools.DrawProperty("AnimIgnoreTimeScale", serializedObject, "mAnimIgnoreTimeScale");
                NGUIEditorTools.DrawProperty("AnimTime", serializedObject, "mAnimTime");
                NGUIEditorTools.DrawProperty("AnimCurve", serializedObject, "mAnimCurve");
            }
            else
            {
                if (sp.floatValue > 0f) sp.floatValue = 0f;
            }
        }
        else
        {
            sp.floatValue = 0f;
        }

        EditorGUI.BeginDisabledGroup(!(target is UIMultiWidget) || (target as UIMultiWidget).mainTexture == null || serializedObject.isEditingMultipleObjects);

        SerializedProperty units = serializedObject.FindProperty("mUnits");
        int size = units.arraySize;
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Unit Size " + size);
        if (GUILayout.Button("Add"))
        {
            mSltIdx = size;
            size++;
            units.arraySize = size;
            if (size == 1)
            {
                sp = units.GetArrayElementAtIndex(mSltIdx);
                sp.FindPropertyRelative("scale").vector3Value = Vector3.one;
                sp.FindPropertyRelative("color").colorValue = Color.white;
            }
        }
        EditorGUILayout.EndHorizontal();

        if (size > 0)
        {
            NGUIEditorTools.DrawSeparator();

            EditorGUILayout.BeginHorizontal();
            mSltIdx = EditorGUILayout.IntField("Unit", mSltIdx);
            if (GUILayout.Button("◀")) mSltIdx--;
            if (GUILayout.Button("▶")) mSltIdx++;
            if (GUILayout.Button("Delete"))
            {
                mSltIdx = Mathf.Clamp(mSltIdx, 0, --size);
                units.DeleteArrayElementAtIndex(mSltIdx);
                OnDeleteUnitAt(mSltIdx);
            }
            EditorGUILayout.EndHorizontal();

            mSltIdx = Mathf.Clamp(mSltIdx, 0, size - 1);

            OnDrawUnit(size);

            if (size > 0)
            {
                sp = units.GetArrayElementAtIndex(mSltIdx);
                EditorGUILayout.BeginHorizontal();
                NGUIEditorTools.DrawProperty("Position", sp.FindPropertyRelative("pos"));
                if (GUILayout.Button("◯", GUILayout.Width(30f))) sp.FindPropertyRelative("pos").vector3Value = Vector3.zero;
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                NGUIEditorTools.DrawProperty("Scale", sp.FindPropertyRelative("scale"));
                if (GUILayout.Button("◯", GUILayout.Width(30f))) sp.FindPropertyRelative("scale").vector3Value = Vector3.one;
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                NGUIEditorTools.DrawProperty("Rotate", sp.FindPropertyRelative("rotate"));
                if (GUILayout.Button("◯", GUILayout.Width(30f))) sp.FindPropertyRelative("rotate").floatValue = 0f;
                EditorGUILayout.EndHorizontal();
                NGUIEditorTools.DrawProperty("Color", sp.FindPropertyRelative("color"));
                NGUIEditorTools.DrawSeparator();
            }
        }
        else
        {
            EditorGUILayout.HelpBox("Click Add To Create Unit.", MessageType.Info);
        }

        EditorGUI.EndDisabledGroup();
        return size > 0;
    }

    protected virtual bool hasAnima { get { return true; } }

    protected virtual void OnDeleteUnitAt(int idx) { }

    protected virtual void OnDrawUnit(int size) { }

    public new void OnSceneGUI()
    {
        base.OnSceneGUI();

        UIMultiWidget w = target as UIMultiWidget;
        if (w && w.unitCount > 0)
        {
            Undo.RecordObject(w, "Adjust UIMultiWidget Unit");

            Matrix4x4 ltw = w.cachedTransform.localToWorldMatrix;
            Matrix4x4 wtl = w.cachedTransform.worldToLocalMatrix;

            for (int i = 0; i < w.unitCount; i++)
            {
                UIMultiWidget.Unit u = w[i];

                Vector3 curPos = ltw.MultiplyPoint3x4(u.pos);

                Handles.Label(curPos, "U-" + i + "", mStyle);

                if (Tools.current == Tool.Move)
                {
                    Vector3 newPos = Handles.PositionHandle(curPos, Quaternion.identity);
                    if (curPos != newPos) u.pos = wtl.MultiplyPoint3x4(newPos);
                }
                else if (Tools.current == Tool.Scale)
                {
                    //Vector3 curScale = ltw.MultiplyVector(u.scale);
                    //Vector3 newScale = Handles.ScaleHandle(curScale, ltw.MultiplyPoint3x4(u.pos), Quaternion.identity, 1f);
                    //if (curScale != newScale) u.scale = wtl.MultiplyVector(newScale);
                    Vector3 newScale = Handles.ScaleHandle(u.scale, curPos, Quaternion.identity, 1f);
                    if (newScale != u.scale) u.scale = newScale;
                }
                else if (Tools.current == Tool.Rotate)
                {
                    u.rotate = 360f - Handles.RotationHandle(Quaternion.Euler(0f, 0f, u.rotate), curPos).eulerAngles.z;
                }
            }

            w.MarkAsChanged();
        }
    }
}
