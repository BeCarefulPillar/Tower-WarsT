using UnityEngine;
using System;
using System.Collections.Generic;

[ExecuteInEditMode]
public class Mesh2D : MonoBehaviour
{
    public bool showGizmos = true;
    public string meshName = "New Mesh";
    [SerializeField] Vector2[] points = new Vector2[3];

    public void AddNewPoiint()
    {
        int len = points.Length;
        Array.Resize<Vector2>(ref points, len + 1);
        points[len] = len > 0 ? points[len - 1] : Vector2.zero;
    }

    public void RemovePoint(int index)
    {
        int len = points.Length;
        if (len > 3 && index >= 0 && index < len)
        {
            List<Vector2> temp = new List<Vector2>();
            for (int i = 0; i < len; i++)
                if (i != index)
                    temp.Add(points[i]);
            points = temp.ToArray();
        }
    }

    public void RemovePoint(Vector2 point)
    {
        int len = points.Length;
        if (len > 3)
        {
            List<Vector2> temp = new List<Vector2>();
            foreach (Vector2 p in points)
                if (p != point)
                    temp.Add(p);
            points = temp.ToArray();
        }
    }

    public Vector2 GetPoint(int index) { if (index >= 0 && index < points.Length)return points[index]; return Vector2.zero; }
    public void SetPoint(int index, Vector2 value)
    {
        if (index >= 0 && index < points.Length)
        {
            points[index] = value;
        }
    }

    public Mesh BuildMesh()
    {
        Mesh mesh = new Mesh();
        mesh.name = meshName;
        int pc = PointCount;
        if (pc > 2)
        {
            float maxX = 0, maxY = 0;
            foreach (Vector2 p in points)
            {
                if (Mathf.Abs(p.x) > maxX) maxX = Mathf.Abs(p.x);
                if (Mathf.Abs(p.y) > maxY) maxY = Mathf.Abs(p.y);
            }

            Vector3[] vertices = new Vector3[pc];
            Vector2[] uv = new Vector2[pc];
            Vector3[] normals = new Vector3[pc];
            for (int i = 0; i < pc; i++)
            {
                vertices[i] = new Vector3(points[i].x, points[i].y, 0);
                uv[i] = new Vector2(maxX > 0 ? 0.5f + 0.5f * points[i].x / maxX : 0, maxY > 0 ? 0.5f + 0.5f * points[i].y / maxY : 0);
                normals[i] = Vector3.forward;
            }

            //normals[0] = Vector3.left;
            //normals[1] = Vector3.down;
            //normals[2] = Vector3.down;
            //normals[3] = Vector3.right;
            //normals[4] = Vector3.right;
            //normals[5] = Vector3.up;
            //normals[6] = Vector3.up;
            //normals[7] = Vector3.left;

            int[] triangles = new int[(pc - 2) * 3];
            for (int i = 0; i < pc - 2; i++)
            {
                triangles[i * 3] = 0;
                triangles[i * 3 + 1] = i + 1;
                triangles[i * 3 + 2] = i + 2;
            }
            mesh.vertices = vertices;
            mesh.uv = uv;
            mesh.normals = normals;
            mesh.triangles = triangles;
        }
        return mesh;
    }

    public int PointCount { get { return points.Length; } }
    public Vector2[] Positions { get { return points; } }

    void OnDrawGizmos()
    {
        if (!showGizmos) return;

        Gizmos.color = Color.green;

        int c = PointCount;
        Transform trans = transform;
        for (int i = 0; i < c; i++)
        {
            if (i < c - 1)
            {
                Gizmos.DrawLine(trans.TransformPoint(points[i]), trans.TransformPoint(points[i + 1]));
            }
            else
            {
                Gizmos.DrawLine(trans.TransformPoint(points[i]), trans.TransformPoint(points[0]));
            }
        }
    }
}