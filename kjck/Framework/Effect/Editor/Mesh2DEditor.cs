using UnityEngine;
using UnityEditor;
using System.Collections;

[CustomEditor(typeof(Mesh2D))]
public class Mesh2DEditor : Editor
{
    Mesh2D mesh2D;
    GUIStyle style = new GUIStyle();

    void OnEnable()
    {
        style.fontStyle = FontStyle.Bold;
        style.normal.textColor = Color.white;
        mesh2D = (Mesh2D)target;
    }

    public override void OnInspectorGUI()
    {
        mesh2D.showGizmos = EditorGUILayout.Toggle("Show Gizmos", mesh2D.showGizmos);
        DrawSeparator();
        EditorGUIUtility.labelWidth = 12;
        Vector2 v2; float v;
        for (int i = 0; i < mesh2D.PointCount; i++)
        {
            v2 = mesh2D.GetPoint(i);
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("×", GUILayout.Width(20))) mesh2D.RemovePoint(i);
            EditorGUILayout.LabelField("P" + i + ":", GUILayout.Width(40));
            v = EditorGUILayout.FloatField("X", v2.x);
            if (v != v2.x) v2.x = v;
            v = EditorGUILayout.FloatField("Y", v2.y);
            if (v != v2.y) v2.y = v;
            EditorGUILayout.EndHorizontal();
            mesh2D.SetPoint(i, v2);
        }
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("AddPoint", GUILayout.Width(80))) mesh2D.AddNewPoiint();
        if (GUILayout.Button("SaveMesh", GUILayout.Width(80)))
        {
            //string str = "Vector2[] nodes = new Vector2[" + mesh2D.PointCount + "] { ";
            //for (int i = 0; i < mesh2D.PointCount; i++)
            //{
            //    v2 = mesh2D.GetPoint(i);
            //    str += "new Vector2(" + v2.x.ToString("f0") + "," + v2.y.ToString("f0") + "),";
            //}
            //str += "}";
            //Debug.Log(str);

            Mesh mesh = mesh2D.BuildMesh();
            AssetDatabase.CreateAsset(mesh, "Assets/Resources/Mesh/" + mesh2D.meshName + ".prefab");
            MeshCollider mc = mesh2D.GetComponent<MeshCollider>();
            if (mc != null) mc.sharedMesh = mesh;
            MeshFilter mf = mesh2D.GetComponent<MeshFilter>();
            if (mf != null) mf.sharedMesh = mesh;
        }
        mesh2D.meshName = EditorGUILayout.TextField("", mesh2D.meshName);
        EditorGUILayout.EndHorizontal();
        EditorGUIUtility.labelWidth = 0;
        DrawSeparator();

        if (GUI.changed)
        {
            EditorUtility.SetDirty(mesh2D);
        }
    }

    void OnSceneGUI()
    {
        if (mesh2D.showGizmos)
        {
            Undo.RecordObject(mesh2D, "Mesh2D Adjust Point");
            Transform trans = mesh2D.transform;
            for (int i = 0; i < mesh2D.PointCount; i++)
            {
                Vector3 v = trans.TransformPoint(mesh2D.GetPoint(i));
                Handles.Label(v, "P" + i, style);
                //Vector2 v2 = Handles.DoPositionHandle(v, Quaternion.identity);
                Vector2 v2 = Handles.PositionHandle(v, Quaternion.identity);
                if (v2 != (Vector2)v) mesh2D.SetPoint(i, trans.InverseTransformPoint(v2));
            }
        }
    }

    void DrawSeparator()
    {
        GUILayout.Space(12f);

        if (Event.current.type == EventType.Repaint)
        {
            Texture2D tex = EditorGUIUtility.whiteTexture;
            Rect rect = GUILayoutUtility.GetLastRect();
            GUI.color = new Color(0f, 0f, 0f, 0.25f);
            GUI.DrawTexture(new Rect(0f, rect.yMin + 6f, Screen.width, 4f), tex);
            GUI.DrawTexture(new Rect(0f, rect.yMin + 6f, Screen.width, 1f), tex);
            GUI.DrawTexture(new Rect(0f, rect.yMin + 9f, Screen.width, 1f), tex);
            GUI.color = Color.white;
        }
    }
}
