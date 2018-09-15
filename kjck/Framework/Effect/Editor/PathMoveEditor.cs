using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(PathMove))]
public class PathMoveEditor : Editor
{
    PathMove pathMove;
    GUIStyle style = new GUIStyle();

    void OnEnable()
    {
        pathMove = target as PathMove;
        style.fontStyle = FontStyle.Bold;
        style.normal.textColor = Color.white;
    }

    public override void OnInspectorGUI()
    {
        pathMove.playOnAwake = EditorGUILayout.Toggle("PlayOnAwake", pathMove.playOnAwake);
        pathMove.ignoreTimeScale = EditorGUILayout.Toggle("IgnoreTimeScale", pathMove.ignoreTimeScale);
        pathMove.time = EditorGUILayout.FloatField("Time", pathMove.time);
        pathMove.loop = EditorGUILayout.FloatField("Loop", pathMove.loop);
        pathMove.Space = (Space)EditorGUILayout.EnumPopup("Space", pathMove.Space);
        pathMove.move = EditorGUILayout.CurveField("MoveCure", pathMove.move, Color.green, new Rect(0f, 0f, 1f, 1f));
        pathMove.alpha = EditorGUILayout.CurveField("AlphaCure", pathMove.alpha, Color.green, new Rect(0f, 0f, 1f, 1f));

        int len = pathMove.Path.GetLength();
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Path Nodes :", GUILayout.Width(80f));
        int newLen = Mathf.Max(0, EditorGUILayout.IntField("", len, GUILayout.Width(100f)));
        EditorGUILayout.EndHorizontal();

        if (newLen != len)
        {
            if (newLen < len)
            {
                if (!EditorUtility.DisplayDialog("删除节点", "你将删除" + (len - newLen) + "个路径节点", "确定", "取消")) return;
            }
            serializedObject.FindProperty("mNodes").arraySize = newLen;
            serializedObject.ApplyModifiedProperties();
            len = pathMove.Path.GetLength();
        }

        for (int i = 0; i < len; i++)
        {
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("X", GUILayout.Width(30f)))
            {
                serializedObject.FindProperty("mNodes").DeleteArrayElementAtIndex(i);
                serializedObject.ApplyModifiedProperties();
                i--; len--;
            }
            else
            {
                EditorGUILayout.LabelField("Node " + i, GUILayout.Width(50f));
                pathMove.Path[i] = EditorGUILayout.Vector3Field("", pathMove.Path[i]);
                EditorGUILayout.EndHorizontal();
            }
        }

        if (GUILayout.Button("Add Nodes"))
        {
            serializedObject.FindProperty("mNodes").arraySize = len + 1;
            serializedObject.ApplyModifiedProperties();
        }
    }

    void OnSceneGUI()
    {
        int len = pathMove.Path.GetLength();
        if (len > 0)
        {
            Undo.RecordObject(pathMove, "Adjust PathMove Path");

            if (pathMove.Space == Space.Self && pathMove.transform.parent)
            {
                Matrix4x4 ltw = pathMove.transform.parent.localToWorldMatrix;
                Matrix4x4 wtl = pathMove.transform.parent.worldToLocalMatrix;

                Handles.Label(ltw.MultiplyPoint3x4(pathMove.Path[0]), "Begin", style);
                Handles.Label(ltw.MultiplyPoint3x4(pathMove.Path[len - 1]), "End", style);

                Vector3 v1, v2;
                for (int i = 0; i < len; i++)
                {
                    v1 = ltw.MultiplyPoint3x4(pathMove.Path[i]);
                    v2 = Handles.PositionHandle(v1, Quaternion.identity);
                    if (v1 != v2) pathMove.Path[i] = wtl.MultiplyPoint3x4(v2);
                }
            }
            else
            {
                Handles.Label(pathMove.Path[0], "Begin", style);
                Handles.Label(pathMove.Path[len - 1], "End", style);

                for (int i = 0; i < len; i++)
                {
                    pathMove.Path[i] = Handles.PositionHandle(pathMove.Path[i], Quaternion.identity);
                }
            }
        }
    }
}
