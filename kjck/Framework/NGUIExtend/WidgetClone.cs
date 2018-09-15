using System.Collections.Generic;
using UnityEngine;

public class WidgetClone : UIWidget
{
    UIWidget widget;

    public UIWidget Widget { get { return widget; } set { widget = value; if (widget)color = widget.color; } }

    public override Material material { get { return widget ? widget.material : null; } }
    public override Shader shader { get { return widget ? widget.shader : null; } }
    public override Texture mainTexture { get { return widget ? widget.mainTexture : null; } }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        if (widget)
        {
            List<Vector3> vs = new List<Vector3>();
            List<Vector2> us = new List<Vector2>();
            List<Color> cs = new List<Color>();
            widget.OnFill(vs, us, cs);
            for (int i = 0; i < cs.Count; i++) cs[i] = color;
            foreach (Vector3 v in vs) verts.Add(v);
            foreach (Vector2 u in us) uvs.Add(u);
            foreach (Color32 c in cs) cols.Add(c);
        }
    }
}
