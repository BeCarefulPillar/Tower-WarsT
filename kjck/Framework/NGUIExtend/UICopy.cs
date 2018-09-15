using UnityEngine;
using System.Collections.Generic;

public class UICopy : UIWidget
{
    [SerializeField] UIWidget mCopy;

    private int offset;

    public UIWidget copy
    {
        get { return mCopy; }
        set
        {
            if (mCopy != value)
            {
                if (mCopy) mCopy.onPostFill -= OnCopyFill;
                mCopy = value;
                if (mCopy)
                {
                    mCopy.onPostFill += OnCopyFill;
                    enabled = true;
                }
            }
        }
    }

    protected override void OnInit()
    { 
        if (copy)
        {
            copy.onPostFill -= OnCopyFill;
            copy.onPostFill += OnCopyFill;
        }
    }

    void OnDestroy() { copy = null; }

    void OnCopyFill(UIWidget w, int offset, List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        this.offset = offset;
        mChanged = true;
    }

    protected override void OnUpdate()
    {
        if (copy)
        {
            mChanged = true;
        }
        else
        {
            enabled = false;
        }
    }

    public override Texture mainTexture { get { return copy ? copy.mainTexture : null; } }

    public override Material material { get { return copy ? copy.material : null; } }

    public override Shader shader { get { return copy ? copy.shader : null; } }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        int of = verts.Count;

        if (mainTexture && copy.geometry != null)
        {
            for (int i = offset; i < copy.geometry.verts.Count; i++)
            {
                verts.Add(copy.geometry.verts[i]); uvs.Add(copy.geometry.uvs[i]); cols.Add(copy.geometry.cols[i]);
            }

            if (onPostFill != null) onPostFill(this, of, verts, uvs, cols);
        }

        offset = 0;
    }

    public static UICopy Copy(UIWidget widget, GameObject parent)
    {
        UICopy copy = null;
        if (widget && parent)
        {
            copy = parent.AddWidget<UICopy>(widget.name);
            copy.copy = widget;
            copy.cachedTransform.localPosition = widget.cachedTransform.localPosition;
            copy.cachedTransform.localScale = widget.cachedTransform.localScale;
            copy.depth = widget.depth;

            int cc = widget.cachedTransform.childCount;
            for (int i = 0; i < cc; i++)
            {
                UIWidget w = widget.cachedTransform.GetChild(i).GetComponent<UIWidget>();
                if (w) UICopy.Copy(w, copy.cachedGameObject);
            }
        }
        return copy;
    }
}
