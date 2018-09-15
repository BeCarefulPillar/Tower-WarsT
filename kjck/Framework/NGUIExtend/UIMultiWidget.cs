using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIMultiWidget : UIWidget
{
    [System.Serializable]
    public class Unit
    {
        public Vector3 pos;
        public Vector3 scale = Vector3.one;
        public float rotate = 0f;
        public Color color = Color.white;
        //public Vector2[] uvs;

        public void SetPos(float x, float y, float z = 0f)
        {
            pos.x = x;
            pos.y = y;
            pos.z = z;
        }
        public void SetScale(float x, float y, float z = 1f)
        {
            scale.x = x;
            scale.y = y;
            scale.z = z;
        }
        public void SetColor(float r, float g, float b)
        {
            color.r = r;
            color.g = g;
            color.b = b;
        }
        public void SetColor(float r, float g, float b, float a)
        {
            color.r = r;
            color.g = g;
            color.b = b;
            color.a = a;
        }
        public void SetAlpha(float a)
        {
            color.a = a;
        }
        //public void SetUVS(params float[] args)
        //{
        //    if (args == null || args.Length < 2)
        //    {
        //        uvs = null;
        //    }
        //    else
        //    {
        //        uvs = new Vector2[args.Length / 2];
        //        for (int i = 0; i < uvs.Length; i++)
        //        {
        //            uvs[i].x = args[i * 2];
        //            uvs[i].y = args[i * 2 + 1];
        //        }
        //    }
        //}
        //public void SetUV(int idx, float x, float y)
        //{
        //    if (uvs == null || idx < 0 || idx >= uvs.Length) return;
        //    uvs[idx].x = x;
        //    uvs[idx].y = y;
        //}
    }

    protected static Rect _DefUV = new Rect(0f, 0f, 1f, 1f);

    [SerializeField] protected Unit[] mUnits;
    [SerializeField] protected bool mActualBounds = false;
    [SerializeField] protected float mAnimTime = 0f;
    [SerializeField] protected bool mAnimIgnoreTimeScale = false;
    [SerializeField] protected AnimationCurve mAnimCurve;

    [System.NonSerialized] protected float mAnimCurTime = 0f;
    [System.NonSerialized] protected Matrix4x4 mMatrix = new Matrix4x4();
    [System.NonSerialized] private Vector3 mPosMin;
    [System.NonSerialized] private Vector3 mPosMax;

    public bool isActualBounds { get { return mActualBounds; } set { mActualBounds = value; MarkAsChanged(); } }
    public bool isAnima { get { return mAnimTime > 0f; } set { mAnimTime = value ? 1f : 0f; } }
    public bool animIgnoreTimeScale { get { return mAnimIgnoreTimeScale; } set { mAnimIgnoreTimeScale = value; } }
    public float animTime { get { return mAnimTime; } set { mAnimTime = value; } }
    public AnimationCurve AnimationCurve { get { return mAnimCurve; } set { mAnimCurve = value; } }

    public virtual bool premultipliedAlpha { get { return false; } }

    public virtual int unitCount
    {
        get { return mUnits == null ? 0 : mUnits.Length; }
        set
        {
            if (value > 0)
            {
                int idx = 0;
                if (mUnits == null)
                {
                    mUnits = new Unit[value];
                }
                else
                {
                    idx = mUnits.Length;
                    System.Array.Resize(ref mUnits, value);
                }
                if (idx < value)
                {
                    for (; idx < value; idx++)
                    {
                        mUnits[idx] = new Unit();
                    }
                }
            }
            else
            {
                mUnits = null;
            }
        }
    }
    
    public Unit this[int idx] { get { return mUnits != null && idx >= 0 && idx < mUnits.Length ? mUnits[idx] : null; } }

    public Unit GetUnit(int idx) { return mUnits != null && idx >= 0 && idx < mUnits.Length ? mUnits[idx] : null; }

    public Unit AddUnit() { return AddUnit(Vector3.zero, Vector3.one, Color.white); }
    public Unit AddUnit(Vector3 pos) { return AddUnit(pos, Vector3.one, Color.white); }
    public Unit AddUnit(Vector3 pos, Vector3 scale) { return AddUnit(pos, scale, Color.white); }
    public virtual Unit AddUnit(Vector3 pos, Vector3 scale, Color color, float rotate = 0f)
    {
        Unit u = new Unit();
        u.pos = pos;
        u.scale = scale;
        u.rotate = rotate;
        u.color = color;
        if (mUnits == null)
        {
            mUnits = new Unit[1] { u };
        }
        else
        {
            int len = mUnits.Length;
            System.Array.Resize(ref mUnits, len + 1);
            mUnits[len] = u;
        }
        mChanged = true;
        return u;
    }

    public virtual void RemoveUnit(int idx)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        if (idx < mUnits.Length - 1)
        {
            System.Array.Copy(mUnits, idx + 1, mUnits, idx, mUnits.Length - idx - 1);
        }
        System.Array.Resize(ref mUnits, mUnits.Length - 1);
        mChanged = true;
    }

    public virtual void ClearUnit()
    {
        mUnits = null;
        mChanged = true;
    }

    public void SetUnit(int idx, Vector3 pos, Vector3 scale, Color color, float rotate)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        Unit u = mUnits[idx];
        u.pos = pos;
        u.scale = scale;
        u.color = color;
        u.rotate = rotate;
        mChanged = true;
    }
    public void SetUnit(int idx, Vector3 pos, Vector3 scale, Color color)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        Unit u = mUnits[idx];
        u.pos = pos;
        u.scale = scale;
        u.color = color;
        mChanged = true;
    }
    public void SetUnit(int idx, Vector3 pos, Vector3 scale, float rotate)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        Unit u = mUnits[idx];
        u.pos = pos;
        u.scale = scale;
        u.rotate = rotate;
        mChanged = true;
    }
    public void SetUnit(int idx, Vector3 pos, Vector3 scale)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        Unit u = mUnits[idx];
        u.pos = pos;
        u.scale = scale;
        mChanged = true;
    }

    public void SetUnit(int idx, Vector3 pos, Color color)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        Unit u = mUnits[idx];
        u.pos = pos;
        u.color = color;
        mChanged = true;
    }
    public void SetUnit(int idx, Vector3 pos, float rotate)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        Unit u = mUnits[idx];
        u.pos = pos;
        u.rotate = rotate;
        mChanged = true;
    }
    public void SetUnit(int idx, Vector3 pos)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].pos = pos;
        mChanged = true;
    }
    public void SetUnit(int idx, Color color)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].color = color;
        mChanged = true;
    }
    public void SetUnit(int idx, float rotate)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].rotate = rotate;
        mChanged = true;
    }
    public void SetUnitPos(int idx, Vector3 pos)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].pos = pos;
        mChanged = true;
    }

    public void SetUnitScale(int idx, Vector3 scale)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].scale = scale;
        MarkAsChanged();
    }
    public void SetUnitScale(int idx, Vector3 scale, Color color)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].scale = scale;
        mUnits[idx].color = color;
        mChanged = true;
    }
    public void SetUnitScale(int idx, Vector3 scale, float rotate)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].scale = scale;
        mUnits[idx].rotate = rotate;
        mChanged = true;
    }
    public void SetUnitScale(int idx, Vector3 scale, Color color, float rotate)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        Unit u = mUnits[idx];
        u.scale = scale;
        u.color = color;
        u.rotate = rotate;
        mChanged = true;
    }
    public void SetUnitColor(int idx, Color color)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].color = color;
        mChanged = true;
    }
    public void SetUnitColor(int idx, Color color, float rotate)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].color = color;
        mUnits[idx].rotate = rotate;
        mChanged = true;
    }
    public void SetUnitRotate(int idx, float rotate)
    {
        if (mUnits == null || idx < 0 || idx >= mUnits.Length) return;
        mUnits[idx].rotate = rotate;
        mChanged = true;
    }

    public Vector3 GetUnitPos(int idx) { return mUnits == null || idx < 0 || idx >= mUnits.Length ? Vector3.zero : mUnits[idx].pos; }
    public Vector3 GetUnitScale(int idx) { return mUnits == null || idx < 0 || idx >= mUnits.Length ? Vector3.zero : mUnits[idx].scale; }
    public Color GetUnitColor(int idx) { return mUnits == null || idx < 0 || idx >= mUnits.Length ? Color.white : mUnits[idx].color; }
    public float GetUnitRotate(int idx) { return mUnits == null || idx < 0 || idx >= mUnits.Length ? 0f : mUnits[idx].rotate; }


    protected override void OnUpdate()
    {
        base.OnUpdate();

        if (mAnimTime > 0)
        {
            mAnimCurTime += mAnimIgnoreTimeScale ? Time.unscaledDeltaTime : Time.deltaTime;
            mChanged = true;
        }
    }

    public override Vector3[] localCorners
    {
        get
        {
            if (isActualBounds)
            {
                mCorners[0] = new Vector3(mPosMin.x, mPosMin.y);
                mCorners[1] = new Vector3(mPosMin.x, mPosMax.y);
                mCorners[2] = new Vector3(mPosMax.x, mPosMax.y);
                mCorners[3] = new Vector3(mPosMax.x, mPosMin.y);
                return mCorners;
            }
            return base.localCorners;
        }
    }

    public override Vector3[] worldCorners
    {
        get
        {
            if (isActualBounds)
            {
                Transform wt = cachedTransform;
                mCorners[0] = wt.TransformPoint(mPosMin.x, mPosMin.y, 0f);
                mCorners[1] = wt.TransformPoint(mPosMin.x, mPosMax.y, 0f);
                mCorners[2] = wt.TransformPoint(mPosMax.x, mPosMax.y, 0f);
                mCorners[3] = wt.TransformPoint(mPosMax.x, mPosMin.y, 0f);
                return mCorners;
            }
            return base.worldCorners;
        }
    }

    protected virtual Rect OnGetUV(int idx) { return _DefUV; }

#if TOLUA
    [LuaInterface.NoToLua]
#endif
    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        if (mUnits == null || mainTexture == null || mUnits.Length < 1) return;
        Vector4 draw = drawingDimensions;

        Vector3 v1 = new Vector3(draw.x, draw.y);
        Vector3 v2 = new Vector3(draw.x, draw.w);
        Vector3 v3 = new Vector3(draw.z, draw.w);
        Vector3 v4 = new Vector3(draw.z, draw.y);

        Color cor = color;
        cor.a = finalAlpha;
        cor = premultipliedAlpha ? NGUITools.ApplyPMA(cor) : cor;

        int offset = verts.Count;

        if (mAnimTime > 0)
        {
            int idx = Mathf.RoundToInt(mAnimCurve == null ? mAnimCurve.Evaluate(MathEx.FlotPart(mAnimCurTime / mAnimTime)) : MathEx.FlotPart(mAnimCurTime / mAnimTime)) % mUnits.Length;
            Unit u = mUnits[idx];
            mMatrix.SetTRS(u.pos, Quaternion.Euler(0f, 0f, -u.rotate), u.scale);

            verts.Add(mMatrix.MultiplyPoint3x4(v1));
            verts.Add(mMatrix.MultiplyPoint3x4(v2));
            verts.Add(mMatrix.MultiplyPoint3x4(v3));
            verts.Add(mMatrix.MultiplyPoint3x4(v4));

            cols.Add(cor * u.color);
            cols.Add(cor * u.color);
            cols.Add(cor * u.color);
            cols.Add(cor * u.color);

            Rect uv = OnGetUV(idx);
            uvs.Add(new Vector2(uv.xMin, uv.yMin));
            uvs.Add(new Vector2(uv.xMin, uv.yMax));
            uvs.Add(new Vector2(uv.xMax, uv.yMax));
            uvs.Add(new Vector2(uv.xMax, uv.yMin));
        }
        else
        {
            for (int i = 0; i < mUnits.Length; i++)
            {
                Unit u = mUnits[i];
                mMatrix.SetTRS(u.pos, Quaternion.Euler(0f, 0f, -u.rotate), u.scale);

                verts.Add(mMatrix.MultiplyPoint3x4(v1));
                verts.Add(mMatrix.MultiplyPoint3x4(v2));
                verts.Add(mMatrix.MultiplyPoint3x4(v3));
                verts.Add(mMatrix.MultiplyPoint3x4(v4));

                cols.Add(cor * u.color);
                cols.Add(cor * u.color);
                cols.Add(cor * u.color);
                cols.Add(cor * u.color);

                Rect uv = OnGetUV(i);
                uvs.Add(new Vector2(uv.xMin, uv.yMin));
                uvs.Add(new Vector2(uv.xMin, uv.yMax));
                uvs.Add(new Vector2(uv.xMax, uv.yMax));
                uvs.Add(new Vector2(uv.xMax, uv.yMin));
            }
        }
        if (mActualBounds)
        {
            mPosMin = mPosMax = Vector3.zero;
            for (int i = offset; i < verts.Count; i++)
            {
                Vector3 v = verts[i];
                mPosMin = Vector3.Min(mPosMin, v);
                mPosMax = Vector3.Max(mPosMax, v);
            }
        }
        if (onPostFill != null) onPostFill(this, offset, verts, uvs, cols);
    }

}
