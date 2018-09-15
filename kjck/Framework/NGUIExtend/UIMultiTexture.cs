using UnityEngine;

[ExecuteInEditMode]
public class UIMultiTexture : UIMultiWidget
{
    [SerializeField] Texture mTexture;
	[SerializeField] Shader mShader;

    [SerializeField] private Rect[] mUVs;
    [SerializeField] private bool mMulti = false;

    [System.NonSerialized] int mPMA = -1;

    public override Texture mainTexture
    {
        get
        {
            if (mTexture != null) return mTexture;
            if (mMat != null) return mMat.mainTexture;
            return null;
        }
        set
        {
            if (mTexture != value)
            {
                if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mTexture = value;
                    drawCall.mainTexture = value;
                }
                else
                {
                    RemoveFromPanel();
                    mTexture = value;
                    mPMA = -1;
                    MarkAsChanged();
                }
            }
        }
    }

    public override Material material
    {
        get
        {
            return mMat;
        }
        set
        {
            if (mMat != value)
            {
                RemoveFromPanel();
                mShader = null;
                mMat = value;
                mPMA = -1;
                MarkAsChanged();
            }
        }
    }

    public override bool premultipliedAlpha
    {
        get
        {
            if (mPMA == -1)
            {
                Material mat = material;
                mPMA = (mat != null && mat.shader != null && mat.shader.name.Contains("Premultiplied")) ? 1 : 0;
            }
            return (mPMA == 1);
        }
    }

    public override Shader shader
    {
        get
        {
            if (mMat != null) return mMat.shader;
            if (mShader == null) mShader = Shader.Find("Unlit/Transparent Colored");
            return mShader;
        }
        set
        {
            if (mShader != value)
            {
                if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mShader = value;
                    drawCall.shader = value;
                }
                else
                {
                    RemoveFromPanel();
                    mShader = value;
                    mPMA = -1;
                    mMat = null;
                    MarkAsChanged();
                }
            }
        }
    }

    public bool isMulti { get { return mMulti; } set { mMulti = value; MarkAsChanged(); } }

    public override int unitCount
    {
        get
        {
            return base.unitCount;
        }
        set
        {
            base.unitCount = value;
            if (value > 0)
            {
                if (mUVs == null)
                {
                    mUVs = new Rect[value];
                }
                else
                {
                    System.Array.Resize(ref mUVs, value);
                }
            }
            else
            {
                mUVs = null;
            }
        }
    }

    public override void ClearUnit()
    {
        base.ClearUnit();
        mUVs = null;
    }

    public Rect GetUV(int idx) { return OnGetUV(idx); }

    public void SetUV(int idx, Rect rect)
    {
        if (mUVs == null || idx < 0 || idx >= mUVs.Length || mUVs[idx] == rect) return;
        mUVs[idx] = rect;
    }

    public void AddUV(Rect rect)
    {
        if (mUVs == null)
        {
            mUVs = new Rect[1] { rect };
        }
        else
        {
            int len = mUVs.Length;
            System.Array.Resize(ref mUVs, len + 1);
            mUVs[len] = rect;
        }
    }

    public void RemoveUV(int idx)
    {
        if (mUVs == null || idx < 0 || idx >= mUVs.Length) return;
        if (idx < mUVs.Length - 1)
        {
            System.Array.Copy(mUVs, idx + 1, mUVs, idx, mUVs.Length - idx - 1);
        }
        System.Array.Resize(ref mUVs, mUVs.Length - 1);
    }

    public override Unit AddUnit(Vector3 pos, Vector3 scale, Color color, float rotate)
    {
        Unit u = base.AddUnit(pos, scale, color, rotate);
        AddUV(Rect.zero);
        return u;
    }

    public override void RemoveUnit(int idx)
    {
        base.RemoveUnit(idx);
        RemoveUV(idx);
    }

    protected override Rect OnGetUV(int idx)
    {
        if (mUVs != null && mUVs.Length > 0)
        {
            if (mMulti)
            {
                return idx >= 0 && idx < mUVs.Length ? mUVs[idx] : Rect.zero;
            }
            else
            {
                return mUVs[0];
            }
        }

        return _DefUV;
    }
}
