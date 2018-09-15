using UnityEngine;
using System.Collections.Generic;

public class UIFragment : UIWidget
{
    UIWidget mWidget;
    WidgetEffect.Triangle[] triangle;
    Vector2 min, max;

    public override void MakePixelPerfect()
    {
        base.MakePixelPerfect();
        Vector2 area = max - min;
        width = Mathf.RoundToInt(area.x); height = Mathf.RoundToInt(area.y);
    }

    public override Material material { get { return mWidget ? mWidget.material : null; ; } }
    public override Texture mainTexture { get { return mWidget ? mWidget.mainTexture : null; } }
    public override Shader shader { get { return mWidget ? mWidget.shader : null; } set { if (mWidget) mWidget.shader = value; } }

    public void Set(UIWidget widget, WidgetEffect.Triangle[] triangle)
    {
        this.mWidget = widget;
        this.triangle = triangle;
        if (triangle != null)
        {
            max = new Vector2(float.MinValue, float.MinValue);
            min = new Vector2(float.MaxValue, float.MaxValue);
            foreach (WidgetEffect.Triangle b in triangle)
            {
                if (b.verts == null) continue;
                foreach (Vector2 v in b.verts)
                {
                    min = Vector2.Min(min, v);
                    max = Vector2.Max(max, v);
                }
            }
            Vector3 pos = cachedTransform.localPosition = (max + min) * 0.5f;
            foreach (WidgetEffect.Triangle b in triangle)
            {
                if (b.verts == null) continue;
                for (int i = 0; i < b.verts.Count; i++)
                    b.verts[i] -= pos;
            }
        }
        MakePixelPerfect();
    }

    Color32 GetColor(Color32 cor)
    {
        cor.a = (byte)Mathf.RoundToInt((cor.a / 255f) * Mathf.Clamp01(finalAlpha) * 255f);
        return cor;
    }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        if (mainTexture == null || triangle == null) return;
        foreach (WidgetEffect.Triangle b in triangle)
        {
            if (b.verts == null || b.verts.Count < 3) continue;
            int index = 0;
            foreach (int cnt in b.counts)
            {
                if (cnt == 3)
                {
                    verts.Add(b.verts[index]);
                    verts.Add(b.verts[index + 1]);
                    verts.Add(b.verts[index + 2]);
                    verts.Add(b.verts[index]);

                    uvs.Add(b.uvs[index]);
                    uvs.Add(b.uvs[index + 1]);
                    uvs.Add(b.uvs[index + 2]);
                    uvs.Add(b.uvs[index]);

                    cols.Add(GetColor(b.cols[index]));
                    cols.Add(GetColor(b.cols[index + 1]));
                    cols.Add(GetColor(b.cols[index + 2]));
                    cols.Add(GetColor(b.cols[index]));
                }
                else if (cnt == 4)
                {
                    verts.Add(b.verts[index]);
                    verts.Add(b.verts[index + 1]);
                    verts.Add(b.verts[index + 2]);
                    verts.Add(b.verts[index + 3]);

                    uvs.Add(b.uvs[index]);
                    uvs.Add(b.uvs[index + 1]);
                    uvs.Add(b.uvs[index + 2]);
                    uvs.Add(b.uvs[index + 3]);

                    cols.Add(GetColor(b.cols[index]));
                    cols.Add(GetColor(b.cols[index + 1]));
                    cols.Add(GetColor(b.cols[index + 2]));
                    cols.Add(GetColor(b.cols[index + 3]));
                }
                else if (cnt == 5)
                {
                    verts.Add(b.verts[index]);
                    verts.Add(b.verts[index + 1]);
                    verts.Add(b.verts[index + 2]);
                    verts.Add(b.verts[index + 3]);
                    verts.Add(b.verts[index + 4]);
                    verts.Add(b.verts[index]);
                    verts.Add(b.verts[index + 3]);
                    verts.Add(b.verts[index + 4]);

                    uvs.Add(b.uvs[index]);
                    uvs.Add(b.uvs[index + 1]);
                    uvs.Add(b.uvs[index + 2]);
                    uvs.Add(b.uvs[index + 3]);
                    uvs.Add(b.uvs[index + 4]);
                    uvs.Add(b.uvs[index]);
                    uvs.Add(b.uvs[index + 3]);
                    uvs.Add(b.uvs[index + 4]);

                    cols.Add(GetColor(b.cols[index]));
                    cols.Add(GetColor(b.cols[index + 1]));
                    cols.Add(GetColor(b.cols[index + 2]));
                    cols.Add(GetColor(b.cols[index + 3]));
                    cols.Add(GetColor(b.cols[index + 4]));
                    cols.Add(GetColor(b.cols[index]));
                    cols.Add(GetColor(b.cols[index + 3]));
                    cols.Add(GetColor(b.cols[index + 4]));
                }
                else if (cnt == 6)
                {
                    verts.Add(b.verts[index]);
                    verts.Add(b.verts[index + 1]);
                    verts.Add(b.verts[index + 2]);
                    verts.Add(b.verts[index + 3]);
                    verts.Add(b.verts[index + 4]);
                    verts.Add(b.verts[index + 5]);
                    verts.Add(b.verts[index]);
                    verts.Add(b.verts[index + 3]);

                    uvs.Add(b.uvs[index]);
                    uvs.Add(b.uvs[index + 1]);
                    uvs.Add(b.uvs[index + 2]);
                    uvs.Add(b.uvs[index + 3]);
                    uvs.Add(b.uvs[index + 4]);
                    uvs.Add(b.uvs[index + 5]);
                    uvs.Add(b.uvs[index]);
                    uvs.Add(b.uvs[index + 3]);

                    cols.Add(GetColor(b.cols[index]));
                    cols.Add(GetColor(b.cols[index + 1]));
                    cols.Add(GetColor(b.cols[index + 2]));
                    cols.Add(GetColor(b.cols[index + 3]));
                    cols.Add(GetColor(b.cols[index + 4]));
                    cols.Add(GetColor(b.cols[index + 5]));
                    cols.Add(GetColor(b.cols[index]));
                    cols.Add(GetColor(b.cols[index + 3]));
                }
                else
                {
                    Debug.LogWarning("三角形超数");
                }
                index += cnt;
            }

            //int d = b.verts.size % 3;
            //if (d == 1)
            //{
            //    b.verts.Add(b.verts[0]);
            //    b.verts.Add(b.verts[b.verts.size - 1]);
            //    b.uvs.Add(b.uvs[0]);
            //    b.uvs.Add(b.uvs[b.verts.size - 1]);
            //    b.cols.Add(b.cols[0]);
            //    b.cols.Add(b.cols[b.verts.size - 1]);
            //}
            //else if (d == 2)
            //{
            //    b.verts.Add(b.verts[b.verts.size - 1]);
            //    b.uvs.Add(b.uvs[b.verts.size - 1]);
            //    b.cols.Add(b.cols[b.verts.size - 1]);
            //}

            //for (int i = 0; i < b.verts.size; i += 3)
            //{
            //    verts.Add(b.verts[i]);
            //    verts.Add(b.verts[i + 1]);
            //    verts.Add(b.verts[i + 2]);
            //    verts.Add(b.verts[i]);

            //    uvs.Add(b.uvs[i]);
            //    uvs.Add(b.uvs[i + 1]);
            //    uvs.Add(b.uvs[i + 2]);
            //    uvs.Add(b.uvs[i]);


            //    cols.Add(b.cols[i]);
            //    cols.Add(b.cols[i + 1]);
            //    cols.Add(b.cols[i + 2]);
            //    cols.Add(b.cols[i]);
            //}

            //int s = b.verts.size - 1;
            //if (s % 3 == 1)
            //{
            //    b.verts.Add(b.verts[0]);
            //    b.verts.Add(b.verts[0]);
            //    b.uvs.Add(b.uvs[0]);
            //    b.uvs.Add(b.uvs[0]);
            //    b.cols.Add(b.cols[0]);
            //    b.cols.Add(b.cols[0]);
            //}
            //else if (s % 3 == 2)
            //{
            //    b.verts.Add(b.verts[0]);
            //    b.uvs.Add(b.uvs[0]);
            //    b.cols.Add(b.cols[0]);
            //}
            //for (int i = 1; i < b.verts.size; i += 3)
            //{
            //    verts.Add(b.verts[i - 1]);
            //    verts.Add(b.verts[i]);
            //    verts.Add(b.verts[i + 1]);
            //    verts.Add(b.verts[i + 2]);

            //    uvs.Add(b.uvs[i - 1]);
            //    uvs.Add(b.uvs[i]);
            //    uvs.Add(b.uvs[i + 1]);
            //    uvs.Add(b.uvs[i + 2]);

            //    cols.Add(b.cols[i - 1]);
            //    cols.Add(b.cols[i]);
            //    cols.Add(b.cols[i + 1]);
            //    cols.Add(b.cols[i + 2]);
            //}
        }
    }

    public static UIFragment Generate(UIWidget widget, params WidgetEffect.Triangle[] triangle)
    {
        if (widget == null) return null;
        UIFragment f = widget.gameObject.AddWidget<UIFragment>("fragment");
        f.Set(widget, triangle);
        f.depth = widget.depth;
        return f;
    }

#if UNITY_EDITOR
    //Selected
    void OnDrawGizmos()
    {
        //if (triangle == null) return;
        //foreach (DetonateWidget.Triangle b in triangle)
        //{
        //    if (b.verts == null || b.verts.size < 3) continue;
        //    int s = b.verts.size - 1;
        //    if (s % 3 == 1)
        //    {
        //        b.verts.Add(b.verts[0]);
        //        b.verts.Add(b.verts[0]);
        //        b.uvs.Add(b.uvs[0]);
        //        b.uvs.Add(b.uvs[0]);
        //        b.cols.Add(b.cols[0]);
        //        b.cols.Add(b.cols[0]);
        //    }
        //    else if (s % 3 == 2)
        //    {
        //        b.verts.Add(b.verts[0]);
        //        b.uvs.Add(b.uvs[0]);
        //        b.cols.Add(b.cols[0]);
        //    }
        //    Matrix4x4 ltw = transform.localToWorldMatrix;
        //    Gizmos.matrix = ltw;
        //    for (int i = 0; i < b.verts.size; i++)
        //    {
        //        if (i > 5 && i < 9)
        //        {
        //            Gizmos.DrawIcon(ltw.MultiplyPoint3x4(b.verts[i]), "label_" + i, false);
        //        }
        //    }
        //    for (int i = 1; i < b.verts.size; i += 3)
        //    {
        //        Gizmos.DrawLine(ltw.MultiplyPoint3x4(b.verts[i - 1]), ltw.MultiplyPoint3x4(b.verts[i]));
        //        Gizmos.DrawLine(ltw.MultiplyPoint3x4(b.verts[i + 1]), ltw.MultiplyPoint3x4(b.verts[i + 2]));

        //    }
        //}
    }
#endif
}
