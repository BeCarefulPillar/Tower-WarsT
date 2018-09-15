using System.Collections.Generic;
using UnityEngine;

public class UIMultiCopy : UIMultiWidget
{
    [SerializeField] private UIWidget mCopy;
    [SerializeField] private bool mFollowRotation = false;
    [SerializeField] private bool mFollowScale = false;

    private int mOffset;

    public UIWidget copy
    {
        get { return mCopy; }
        set
        {
            if (mCopy == null || value == this) return;
            if (mCopy) mCopy.onPostFill -= OnCopyFill;
            mCopy = value;
            if (mCopy)
            {
                mCopy.onPostFill += OnCopyFill;
                enabled = true;
            }
        }
    }

    public bool followRotation { get { return mFollowRotation; }set { mFollowRotation = value; } }
    public bool followScale { get { return mFollowScale; }set { mFollowScale = value; } }

    protected override void OnInit()
    {
        if (mCopy)
        {
            mCopy.onPostFill -= OnCopyFill;
            mCopy.onPostFill += OnCopyFill;
        }
    }

    private void OnDestroy() { copy = null; }

    private void OnCopyFill(UIWidget w, int offset, List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        mOffset = offset;
        mChanged = true;
    }

    protected override void OnUpdate()
    {
        if (mCopy)
        {
            mChanged = true;
        }
        else
        {
            enabled = false;
        }

        if (panel == null) CreatePanel();
    }

    public override Texture mainTexture { get { return mCopy ? mCopy.mainTexture : null; } }

    public override Material material { get { return mCopy ? mCopy.material : null; } }

    public override Shader shader { get { return mCopy ? mCopy.shader : null; } }

#if TOLUA
    [LuaInterface.NoToLua]
#endif
    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        int offset = verts.Count;

        if (mainTexture && mCopy.geometry != null && mUnits != null && mUnits.Length > 0)
        {
            UIGeometry geo = mCopy.geometry;
            Vector3 pr = mFollowRotation ? -mCopy.cachedTransform.eulerAngles : Vector3.zero;
            Vector3 ps = ScaleR(mCopy.cachedTransform.lossyScale, cachedTransform.lossyScale);
            if (mFollowScale && ps != Vector3.zero)
            {
                for (int i = 0; i < mUnits.Length; i++)
                {
                    Unit u = mUnits[i];
                    mMatrix.SetTRS(u.pos, Quaternion.Euler(pr.x, pr.y, pr.z - u.rotate), Vector3.Scale(u.scale, ps));
                    for (int j = mOffset; j < geo.verts.Count; j++)
                    {
                        verts.Add(mMatrix.MultiplyPoint3x4(geo.verts[j]));
                        uvs.Add(geo.uvs[j]);
                        cols.Add(geo.cols[j] * u.color);
                    }
                }
            }
            else
            {
                for (int i = 0; i < mUnits.Length; i++)
                {
                    Unit u = mUnits[i];
                    mMatrix.SetTRS(u.pos, Quaternion.Euler(pr.x, pr.y, pr.z - u.rotate), u.scale);
                    for (int j = mOffset; j < geo.verts.Count; j++)
                    {
                        verts.Add(mMatrix.MultiplyPoint3x4(geo.verts[j]));
                        uvs.Add(geo.uvs[j]);
                        cols.Add(geo.cols[j] * u.color);
                    }
                }
            }
            
            if (onPostFill != null) onPostFill(this, offset, verts, uvs, cols);
        }

        //mOffset = 0;
    }

    private Vector3 ScaleR(Vector3 a, Vector3 b)
    {
        if (a == b) return Vector3.one;
        a.x = b.x == 0 ? 0 : a.x / b.x;
        a.y = b.y == 0 ? 0 : a.y / b.y;
        a.z = b.z == 0 ? 0 : a.z / b.z;
        return a;
    }
}
