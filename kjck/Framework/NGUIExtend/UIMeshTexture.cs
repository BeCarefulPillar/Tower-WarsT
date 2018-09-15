using UnityEngine;
using System.Collections.Generic;

public class UIMeshTexture : UITexture
{
    [SerializeField] Vector2[] points = new Vector2[3];

    public void AddNewPoiint()
    {
        int len = points.Length;
        System.Array.Resize<Vector2>(ref points, len + 1);
        points[len] = len > 0 ? points[len - 1] : Vector2.zero;
        mChanged = true;
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
            mChanged = true;
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

    public Vector2 GetPoint(int index)
    {
        if (index >= 0 && index < points.Length)
        {
            Vector4 d = drawingDimensions;
            Vector2 p = points[index];
            p.x = d.x + (d.z - d.x) * p.x;
            p.y = d.y + (d.w - d.y) * p.y;
            return p; 
        }
        return Vector2.zero;
    }
    public void SetPoint(int index, Vector2 value)
    {
        if (index >= 0 && index < points.Length)
        {
            Vector4 d = drawingDimensions;
            value.x = Mathf.Clamp01((value.x - d.x) / (d.z - d.x));
            value.y = Mathf.Clamp01((value.y - d.y) / (d.w - d.y));
            //value.x = Mathf.Clamp(value.x, d.x, d.z);
            //value.y = Mathf.Clamp(value.y, d.y, d.w);
            if (points[index] != value)
            {
                points[index] = value;
                mChanged = true;
            }
        }
    }

    public Vector2[] Points { get { return points; } set { points = value; } }

    public int PointCount { get { return points.Length; } }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        if (points == null || mainTexture == null) return;
        int len = PointCount;
        if (len < 3) return;

        int offset = verts.Count; 

        Color colF = color;
        colF.a = finalAlpha;
        Color col = premultipliedAlpha ? NGUITools.ApplyPMA(colF) : colF;

        int pcs = (len % 2 != 0) ? len + 1 : len;
        int pes = pcs / 2;

        Vector4 v = drawingDimensions;
        Vector2[] pt = new Vector2[pcs];
        Vector2[] uv = new Vector2[pcs];
        Rect outer = new Rect(parentRect.x + uvRect.x * parentRect.width, parentRect.y + uvRect.y * parentRect.height, parentRect.width * uvRect.width, parentRect.height * uvRect.height);
        //Rect outer = uvRect;
        float vw = v.z - v.x, vh = v.w - v.y;
        for (int i = 0; i < len; i++)
        {
            pt[i].Set(v.x + points[i].x * vw,v.y + points[i].y * vh);
            uv[i].Set(outer.xMin + points[i].x * outer.width, outer.yMin + points[i].y * outer.height);
        }
        if (pcs > len)
        {
            pt[pcs - 1] = pt[pcs - 2];
            uv[pcs - 1] = uv[pcs - 2];
        }

        bool flag = true;
        for (int i = 1; i < pes; i++)
        {
            int idx = i * 2;
            if (flag)
            {
                verts.Add(pt[idx - 2]);
                verts.Add(pt[idx - 1]);
                verts.Add(pt[idx]);
                verts.Add(pt[idx + 1]);

                uvs.Add(uv[idx - 2]);
                uvs.Add(uv[idx - 1]);
                uvs.Add(uv[idx]);
                uvs.Add(uv[idx + 1]);
                flag = false;
            }
            else
            {
                verts.Add(pt[idx + 1]);
                verts.Add(pt[idx]);
                verts.Add(pt[idx - 1]);
                verts.Add(pt[idx - 2]);

                uvs.Add(uv[idx + 1]);
                uvs.Add(uv[idx]);
                uvs.Add(uv[idx - 1]);
                uvs.Add(uv[idx - 2]);
                flag = true;
            }

            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
        }

        if (onPostFill != null) onPostFill(this, offset, verts, uvs, cols);
    }

#if UNITY_EDITOR
#if TOLUA
    [LuaInterface.NoToLua]
#endif
    public bool showGizmos = false;
    //void OnDrawGizmos()
    //{
    //    if (!showGizmos) return;
    //    int len = PointCount;
    //    if (len < 3) return;
    //    Matrix4x4 ltw = transform.localToWorldMatrix;

    //    //int pcs = (len % 2 != 0) ? len + 1 : len;
    //    //int pes = pcs / 2;

    //    Gizmos.color = Color.green;

    //    Vector2[] pt = new Vector2[len];
    //    Vector4 v = drawingDimensions;
    //    float vw = v.z - v.x, vh = v.w - v.y;
    //    for (int i = 0; i < len; i++)
    //    {
    //        pt[i].Set(v.x + points[i].x * vw, v.y + points[i].y * vh);
    //    }
        
    //    for (int i = 1; i < len; i++)
    //    {
    //        if (i < len - 1)
    //        {

    //            Gizmos.DrawLine(ltw.MultiplyPoint3x4(pt[i-1]), ltw.MultiplyPoint3x4(pt[i]));
    //        }
    //        //else
    //        //{
    //        //    Gizmos.DrawLine(ltw.MultiplyPoint3x4(pt[i]), ltw.MultiplyPoint3x4(pt[0]));
    //        //}
    //    }
    //}
#endif
}
