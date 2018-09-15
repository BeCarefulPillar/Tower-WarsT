//NGUI Extend Copyright © 何权

using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
[AddComponentMenu("Effects/UITrail")]
public class UITrail : UIWidget
{
    public struct Trail
    {
        public Vector3 position;
        public Vector3 vector;
        public float dis;
        public float life;
    }

    /// <summary>
    /// 排除超量移动的开始帧数
    /// </summary>
    private const int START_FRAME_QTY = 4;

    //资源显示属性
    [HideInInspector][SerializeField] UIAtlas mAtlas;
    [HideInInspector][SerializeField] string mSpriteName;
    [HideInInspector][SerializeField] Texture mTex;
	[HideInInspector][SerializeField] Shader mShader;
    [HideInInspector][SerializeField] UIEffectFlip mFlip = UIEffectFlip.Nothing;
    [HideInInspector][SerializeField] Transform mRelative;
    
    [SerializeField] Gradient mGradient = new Gradient();
    [SerializeField] float mStartWidth = 1f;
    [SerializeField] float mEndWidth = 1f;
    [SerializeField] float mTime = 5f;
    [SerializeField] float mMinVertexDis = 0.1f;
    [SerializeField] public bool isActualBounds = false;
    [System.NonSerialized] private Vector3 pos_min;
    [System.NonSerialized] private Vector3 pos_max;

    /// <summary>
    /// [0=xmin,1=width,2=ymin,3=ymax]
    /// </summary>
    [System.NonSerialized] private Vector2[] mUV;
    [System.NonSerialized] private int startFrame;
    [System.NonSerialized] private List<Trail> trails = new List<Trail>();
    [System.NonSerialized] private float listDis = 0f;
    [System.NonSerialized] private Trail trail = new Trail();

    protected override void OnDisable()
    {
        base.OnDisable();
        Clear();
    }

    protected override void OnStart()
    {
        base.OnStart();
        Clear();
    }

    void LateUpdate()
    {
        int cnt = trails.Count;

        float dt = Time.deltaTime / mTime;
        for (int i = 0; i < cnt; i++)
        {
            Trail t = trails[i];
            t.life -= dt;
            if (t.life > 0)
            {
                trails[i] = t;
            }
            else
            {
                
                int next = i + 1;
                if (next < cnt)
                {
                    Trail t2 = trails[next];
                    if (i == 0)
                    {
                        listDis = Mathf.Max(0f, listDis - t2.dis);
                        t2.dis = 0f;
                    }
                    else t2.dis += t.dis;
                    trails[next] = t2;
                }
                trails.RemoveAt(i);
                i--;
                cnt--;
                mChanged = true;
            }
        }

        if (cachedTransform.hasChanged)
        {
            cachedTransform.hasChanged = false;

            trail.position = (mRelative && mRelative.parent) ? mRelative.parent.worldToLocalMatrix.MultiplyPoint3x4(cachedTransform.position) : cachedTransform.position;

            if (cnt > 0)
            {
                Trail last = trails[cnt - 1];

                Vector3 v = trail.position - last.position;
                trail.vector = new Vector3(-v.y, v.x).normalized;
                trail.dis = v.magnitude;

                if (cnt == 1)
                {
                    if (startFrame > Time.frameCount)
                    {
                        if (trail.dis > mMinVertexDis)
                        {
                            trail.dis = 0;
                            last.position = trail.position;
                            trails[0] = last;
                            return;
                        }
                        else
                        {
                            startFrame = 0;
                        }
                    }
                    last.vector = trail.vector;
                    trails[0] = last;
                }

                if (trail.dis >= mMinVertexDis)
                {
                    listDis += trail.dis;
                    trails.Add(trail);
                    trail.dis = 0f;
                }
            }
            else
            {
                trail.dis = 0f;
                listDis = 0f;
                trails.Add(trail);
            }

            mChanged = true;
        }
    }

    public override bool canBeAnchored { get { return false; } }

    public UIAtlas atlas
    {
        get { return mAtlas; }
        set
        {
            if (mAtlas != value)
            {
                RemoveFromPanel();

                mAtlas = value;
                mUV = null;
            }
        }
    }

    public string spriteName
    {
        get
        {
            return mSpriteName;
        }
        set
        {
            if (string.IsNullOrEmpty(value))
            {
                if (string.IsNullOrEmpty(mSpriteName)) return;

                mSpriteName = "";
                mUV = null;
                mChanged = true;
            }
            else if (mSpriteName != value)
            {
                mSpriteName = value;
                mUV = null;
                mChanged = true;
            }
        }
    }

    public override Texture mainTexture
    {
        get
        {
            Material mat = material;
            return mat ? mat.mainTexture : mTex;
        }
        set
        {
            if (!mAtlas && mTex != value)
            {
                if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mTex = value;
                    drawCall.mainTexture = value;
                }
                else
                {
                    RemoveFromPanel();
                    mTex = value;
                    mUV = null;
                    MarkAsChanged();
                }
            }
        }
    }

    public override Material material
    {
        get
        {
            return mAtlas ? mAtlas.spriteMaterial : mMat;
        }
        set
        {
            if (mAtlas) return;
            if (!mAtlas && mMat != value)
            {
                RemoveFromPanel();
                mShader = null;
                mMat = value;
                mUV = null;
                MarkAsChanged();
            }
        }
    }

    public override Shader shader
    {
        get
        {
            Material mat = material;
            if (mat) return mat.shader;
            if (mShader == null) mShader = Shader.Find("Unlit/Transparent Colored");
            return mShader;
        }
        set
        {
            if (mShader != value)
            {
                if (mAtlas && mAtlas.spriteMaterial)
                {
                    mAtlas.spriteMaterial.shader = value;
                    RemoveFromPanel();
                    MarkAsChanged();
                }
                else if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mShader = value;
                    drawCall.shader = value;
                }
                else
                {
                    RemoveFromPanel();
                    mShader = value;
                    mMat = null;
                    MarkAsChanged();
                }
            }
        }
    }

    /// <summary>
    /// Local space corners of the widget. The order is bottom-left, top-left, top-right, bottom-right.
    /// </summary>
    public override Vector3[] localCorners
    {
        get
        {
            if (isActualBounds)
            {
                mCorners[0] = new Vector3(pos_min.x, pos_min.y);
                mCorners[1] = new Vector3(pos_min.x, pos_max.y);
                mCorners[2] = new Vector3(pos_max.x, pos_max.y);
                mCorners[3] = new Vector3(pos_max.x, pos_min.y);
                return mCorners;
            }
            return base.localCorners;
        }
    }
    /// <summary>
    /// World-space corners of the widget. The order is bottom-left, top-left, top-right, bottom-right.
    /// </summary>
    public override Vector3[] worldCorners
    {
        get
        {
            if (isActualBounds)
            {
                Transform wt = cachedTransform;
                mCorners[0] = wt.TransformPoint(pos_min.x, pos_min.y, 0f);
                mCorners[1] = wt.TransformPoint(pos_min.x, pos_max.y, 0f);
                mCorners[2] = wt.TransformPoint(pos_max.x, pos_max.y, 0f);
                mCorners[3] = wt.TransformPoint(pos_max.x, pos_min.y, 0f);
                return mCorners;
            }
            return base.worldCorners;
        }
    }

    public UIEffectFlip flip
    {
        get { return mFlip; }
        set
        {
            if (mFlip != value)
            {
                mFlip = value;
                mUV = null;
                mChanged = true;
            }
        }
    }

    public Transform Relative
    {
        get { return mRelative; }
        set
        {
            if (mRelative != value)
            {
                mRelative = value;
                Clear();
            }
        }
    }

    public float StartWidth
    {
        get { return mStartWidth; }
        set
        {
            value = Mathf.Max(0f, value);
            if (mStartWidth != value)
            {
                mStartWidth = value;
                mChanged = true;
            }
        }
    }
    public float EndWidth
    {
        get { return mEndWidth; }
        set
        {
            value = Mathf.Max(0f, value);
            if (mEndWidth != value)
            {
                mEndWidth = value;
                mChanged = true;
            }
        }
    }
    public float LifeTime
    {
        get { return mTime; }
        set
        {
            value = Mathf.Max(0f, value);
            if (mTime != value)
            {
                mTime = value;
                mChanged = true;
            }
        }
    }
    public float MinVertexDistance
    {
        get { return mMinVertexDis; }
        set
        {
            value = Mathf.Max(0f, value);
            if (mMinVertexDis != value)
            {
                mMinVertexDis = value;
                mChanged = true;
            }
        }
    }

    [ContextMenu("Clear")]
    public void Clear()
    {
        startFrame = Time.frameCount + START_FRAME_QTY;
        listDis = 0f;
        trail.position = (mRelative && mRelative.parent) ? mRelative.parent.worldToLocalMatrix.MultiplyPoint3x4(cachedTransform.position) : cachedTransform.position;
        trail.life = 1f;
        trail.dis = 0f;
        trails.Clear();
    }

    void GenUV()
    {
        mUV = null;
        Texture tex = mainTexture;
        if (!tex) return;

        if (atlas)
        {
            UISpriteData sprite = atlas.GetSprite(spriteName);
            if (sprite != null)
            {
                Rect outer = new Rect(sprite.x, sprite.y, sprite.width, sprite.height);
                outer = NGUIMath.ConvertToTexCoords(outer, tex.width, tex.height);
                mUV = new Vector2[4] { new Vector2(outer.xMin, outer.yMin), new Vector2(outer.xMin, outer.yMax), new Vector2(outer.xMax, outer.yMax), new Vector2(outer.xMax, outer.yMin) };
            }
        }
        else
        {
            mUV = new Vector2[4] { new Vector2(0f, 0f), new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(1f, 0f) };
        }

        if (mFlip == UIEffectFlip.Left) mUV.OffsetIndex(-1);
        else if (mFlip == UIEffectFlip.Right) mUV.OffsetIndex(1);
        else if (mFlip == UIEffectFlip.Horizontally) System.Array.Reverse(mUV);
        else if (mFlip == UIEffectFlip.Vertically) { System.Array.Reverse(mUV, 0, 2); System.Array.Reverse(mUV, 2, 2); }
        else if (mFlip == UIEffectFlip.Both) mUV.OffsetIndex(-2);
    }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        int cnt = trails.Count;
        if (cnt <= 0) return;
        Texture tex = mainTexture;
        if (tex == null) return;

        if (mUV == null) GenUV();
        if (mUV == null) return;
        
        Color colF = color;
        colF.a = finalAlpha;

        Matrix4x4 matrix = cachedTransform.worldToLocalMatrix * ((mRelative && mRelative.parent) ? mRelative.parent.localToWorldMatrix : Matrix4x4.identity);

        int last = cnt - 1;

        float halfSW = mStartWidth * 0.5f;
        float halfEW = mEndWidth * 0.5f;
        float totalDis = listDis + trail.dis;

        Trail tr = trails[0];
        float t = tr.dis / totalDis;
        Vector3 dv = matrix.MultiplyVector(tr.vector).normalized * Mathf.Lerp(halfEW, halfSW, t);
        Vector3 pos = matrix.MultiplyPoint3x4(tr.position);
        Color c = colF * mGradient.Evaluate(1f - t);

        Vector3 v1 = pos - dv;
        Vector3 v2 = pos + dv;
        Vector2 u1 = Vector2.Lerp(mUV[0], mUV[3], t);
        Vector2 u2 = Vector2.Lerp(mUV[1], mUV[2], t);

        int offset = verts.Count;

        verts.Add(v1);
        verts.Add(v2);
        uvs.Add(u1);
        uvs.Add(u2);
        cols.Add(c);
        cols.Add(c);
        
        for (int i = 1; i < last; i++)
        {
            tr = trails[i];
            t += tr.dis / totalDis;
            dv = matrix.MultiplyVector(tr.vector).normalized * Mathf.Lerp(halfEW, halfSW, t);
            pos = matrix.MultiplyPoint3x4(tr.position);
            c = colF * mGradient.Evaluate(1f - t);

            v1 = pos - dv;
            v2 = pos + dv;
            u1 = Vector2.Lerp(mUV[0], mUV[3], t);
            u2 = Vector2.Lerp(mUV[1], mUV[2], t);

            verts.Add(v2);
            verts.Add(v1);
            verts.Add(v1);
            verts.Add(v2);

            uvs.Add(u2);
            uvs.Add(u1);
            uvs.Add(u1);
            uvs.Add(u2);

            cols.Add(c);
            cols.Add(c);
            cols.Add(c);
            cols.Add(c);
        }

        dv = matrix.MultiplyVector(trail.vector).normalized * halfSW;
        pos = matrix.MultiplyPoint3x4(trail.position);
        c = colF * mGradient.Evaluate(0f);

        v1 = pos - dv;
        v2 = pos + dv;
        u1 = mUV[3];
        u2 = mUV[2];

        verts.Add(v2);
        verts.Add(v1);
        uvs.Add(u2);
        uvs.Add(u1);
        cols.Add(c);
        cols.Add(c);

        if (isActualBounds)
        {
            if (verts.Count > offset)
            {
                pos_min = pos_max = verts[offset];
                for (int i = offset + 1; i < verts.Count; i++)
                {
                    pos_min = Vector3.Min(pos_min, verts[i]);
                    pos_max = Vector3.Max(pos_max, verts[i]);
                }
            }
            else
            {
                pos_min = pos_max = Vector3.zero;
            }
        }

        if (onPostFill != null) onPostFill(this, offset, verts, uvs, cols);
    }
}
