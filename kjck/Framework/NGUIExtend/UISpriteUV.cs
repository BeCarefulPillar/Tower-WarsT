using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
public class UISpriteUV : UIWidget
{
    [SerializeField] UIAtlas mAtlas;
    [SerializeField] string mSpriteName;
    [SerializeField] Rect mRect = new Rect(0f, 0f, 1f, 1f);
    [SerializeField] TextureWrapMode mWrapMode = TextureWrapMode.Clamp;
    [System.NonSerialized] UISpriteData mSprite;

    public TextureWrapMode wrapMode
    {
        get { return mWrapMode; }
        set
        {
            if (mWrapMode != value)
            {
                mWrapMode = value;
                mChanged = true;
            }
        }
    }

    public Rect uvRect
    {
        get { return mRect; }
        set
        {
            if (uvRect != value)
            {
                mRect = value;
                mChanged = true;
            }
        }
    }

    public UIAtlas atlas
    {
        get { return mAtlas; }
        set
        {
            if (mAtlas != value)
            {
                mAtlas = value;
                mSprite = null;
                mChanged = true;
            }
        }
    }

    public string spriteName
    {
        get { return mSpriteName; }
        set
        {
            if (mSpriteName != value)
            {
                if (atlas)
                {
                    mSprite = atlas.GetSprite(value);
                    mSpriteName = mSprite != null ? mSprite.name : null;
                }
                else mSpriteName = value;
                mChanged = true;
            }
        }
    }

#if UNITY_EDITOR
    public bool isChanged { get { return mChanged; } }
#endif

    public override Material material { get { return atlas ? atlas.spriteMaterial : null; } }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        Texture tex = mainTexture;
        if (tex == null) return;

        if (mSprite == null) mSprite = atlas.GetSprite(spriteName);
        if (mSprite == null) return;

        int offset = verts.Count;

        Rect outer = NGUIMath.ConvertToTexCoords(new Rect(mSprite.x, mSprite.y, mSprite.width, mSprite.height), tex.width, tex.height);
        Vector4 v = drawingDimensions;
        float dw = v.z - v.x, dh = v.w - v.y;
        Color c = color;
        c.a = finalAlpha;

        if (mWrapMode == TextureWrapMode.Repeat)
        {
            if (uvRect.width == 0 || uvRect.height == 0) return;

            float ddx = Mathf.Abs(1f / uvRect.width), ddy = Mathf.Abs(1f / uvRect.height);

            float sx = MathEx.FlotPart(uvRect.x), sy = MathEx.FlotPart(uvRect.y);
            if (sx < 0f) sx = 1f + sx; if (sy < 0f) sy = 1f + sy;

            float dy = 0f;

            while (dy < 1f)
            {
                float mdy = Mathf.Clamp01(dy + ddy - sy * ddy);
                float muy = dy + ddy > 1f ? (1f - dy) / ddy : 1f;
                float dx = 0f, ssx = sx;

                while (dx < 1f)
                {
                    float mdx = Mathf.Clamp01(dx + ddx - ssx * ddx);
                    float mux = dx + ddx > 1f ? (1f - dx) / ddx : 1f;

                    Vector4 d = new Vector4(v.x + dx * dw, v.y + dy * dh, v.x + mdx * dw, v.y + mdy * dh);
                    Vector4 u = new Vector4(outer.xMin + ssx * outer.width, outer.yMin + sy * outer.height, outer.xMin + mux * outer.width, outer.yMin + muy * outer.height);

                    verts.Add(new Vector3(d.x, d.y));
                    verts.Add(new Vector3(d.x, d.w));
                    verts.Add(new Vector3(d.z, d.w));
                    verts.Add(new Vector3(d.z, d.y));

                    uvs.Add(new Vector2(u.x, u.y));
                    uvs.Add(new Vector2(u.x, u.w));
                    uvs.Add(new Vector2(u.z, u.w));
                    uvs.Add(new Vector2(u.z, u.y));

                    cols.Add(c);
                    cols.Add(c);
                    cols.Add(c);
                    cols.Add(c);

                    dx = mdx; ssx = 0;
                }

                dy = mdy; sy = 0;
            }
        }
        else
        {
            Vector4 d = new Vector4(
                v.x + Mathf.Clamp01(-mRect.x / mRect.width) * dw,
                v.y + Mathf.Clamp01(-mRect.y / mRect.height) * dh,
                v.x + Mathf.Clamp01((1f - mRect.x) / mRect.width) * dw,
                v.y + Mathf.Clamp01((1f - mRect.y) / mRect.height) * dh);

            Vector4 u = new Vector4(
                       outer.xMin + Mathf.Clamp01(mRect.x) * outer.width,
                       outer.yMin + Mathf.Clamp01(mRect.y) * outer.height,
                       outer.xMin + Mathf.Clamp01(mRect.width + mRect.x) * outer.width,
                       outer.yMin + Mathf.Clamp01(mRect.height + mRect.y) * outer.height);
            
            verts.Add(new Vector3(d.x, d.y));
            verts.Add(new Vector3(d.x, d.w));
            verts.Add(new Vector3(d.z, d.w));
            verts.Add(new Vector3(d.z, d.y));

            uvs.Add(new Vector2(u.x, u.y));
            uvs.Add(new Vector2(u.x, u.w));
            uvs.Add(new Vector2(u.z, u.w));
            uvs.Add(new Vector2(u.z, u.y));

            cols.Add(c);
            cols.Add(c);
            cols.Add(c);
            cols.Add(c);

            //if (u.x < 1f && u.y < 1f && u.z > 0f && u.w > 0f)
            //{
                
            //}
        }

        if (onPostFill != null)
            onPostFill(this, offset, verts, uvs, cols);
    }
}
