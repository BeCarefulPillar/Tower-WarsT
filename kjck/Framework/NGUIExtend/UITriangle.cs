using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
public class UITriangle : UIWidget
{
    Vector4 rect = Vector4.zero;
    Vector2[] triangles;
    Vector2[] vertices;

    public override Material material { get { return mMat; } set { } }

    public void AddTriangles(Material mat, params Vector2[] triangles)
    {
        if (mat == null || mat.mainTexture == null || triangles == null) return;
        int len = triangles.Length;
        if (len < 3 || len % 3 != 0) return;
        foreach (Vector2 v in triangles)
        {
            if (v.x > 1 || v.y > 1)
            {
                Debug.LogError("加载的三角形点必须是纹理点");
                return;
            }
        }

        mMat = mat;
        this.triangles = triangles;
        Vector2 temp = triangles[0];
        Vector4 bound = new Vector4(temp.x, temp.x, temp.y, temp.y);
        foreach (Vector2 v in triangles)
        {
            if (v.x < bound.x) bound.x = v.x;
            else if (v.x > bound.y) bound.y = v.x;
            if (v.y < bound.z) bound.z = v.y;
            else if (v.y > bound.w) bound.w = v.y;
        }
        float w = mainTexture.width, h = mainTexture.height;
        float bw = bound.y - bound.x, bh = bound.w - bound.z;
        rect.x = (bound.x + bw * 0.5f - 0.5f) * w;
        rect.y = (bound.z + bh * 0.5f - 0.5f) * h;
        rect.z = bw * w;
        rect.w = bh * h;
        vertices = new Vector2[len];
        for (int i = 0; i < len; i++)
            vertices[i] = new Vector2((triangles[i].x - bound.x) / bw, (triangles[i].y - bound.z) / bh);
        MarkAsChanged();
    }

    /// <summary>
    /// Adjust the Dimensions of the widget to make it pixel-perfect.
    /// </summary>

    public override void MakePixelPerfect()
    {
        Texture tex = mainTexture;
        if (tex != null)
        {
            Vector3 pos = cachedTransform.localPosition;
            pos.x = rect.x;
            pos.y = rect.y;
            cachedTransform.localPosition = pos;
            width = Mathf.RoundToInt(rect.z);
            height = Mathf.RoundToInt(rect.w);
        }
        base.MakePixelPerfect();
    }

    /// <summary>
    /// Virtual function called by the UIScreen that fills the buffers.
    /// </summary>

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        if (mainTexture == null) return;
        Color colF = color;
        colF.a *= finalAlpha;
        Color col = colF;

        Vector4 d = drawingDimensions;
        Vector2 dd = new Vector2(d.z - d.x, d.w - d.y);

        int len = triangles.Length;

        Vector2[] vs = new Vector2[len];
        for (int i = 0; i < len; i++)
        {
            Vector2 v = vertices[i];
            vs[i] = new Vector2(d.x + v.x * dd.x, d.y + v.y * dd.y);
        }

        for (int i = 0; i < len; i += 3)
        {
            verts.Add(vs[i]);
            verts.Add(vs[i + 1]);
            verts.Add(vs[i + 2]);
            verts.Add(vs[i + 2]);

            uvs.Add(triangles[i]);
            uvs.Add(triangles[i + 1]);
            uvs.Add(triangles[i + 2]);
            uvs.Add(triangles[i + 2]);

            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
        }
    }
}
