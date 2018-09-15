using UnityEngine;
using System.Collections.Generic;

public class UIArrow : UIWidget
{
    // Cached and saved values
	[HideInInspector][SerializeField] UIAtlas mAtlas;
	[HideInInspector][SerializeField] string mSpriteName;

    protected UISpriteData mSprite;
    bool mSpriteSet = false;
    float mValue;

    public float Value
    {
        get { return mValue; }
        set
        {
            mValue = Mathf.Clamp01(value);
            MarkAsChanged();
        }
    }

    public override Material material { get { return (mAtlas != null) ? mAtlas.spriteMaterial : null; } }

    public UIAtlas atlas
    {
        get
        {
            return mAtlas;
        }
        set
        {
            if (mAtlas != value)
            {
                RemoveFromPanel();

                mAtlas = value;
                mSpriteSet = false;
                mSprite = null;

                // Automatically choose the first sprite
                if (string.IsNullOrEmpty(mSpriteName))
                {
                    if (mAtlas != null && mAtlas.spriteList.Count > 0)
                    {
                        SetAtlasSprite(mAtlas.spriteList[0]);
                        mSpriteName = mSprite.name;
                    }
                }

                // Re-link the sprite
                if (!string.IsNullOrEmpty(mSpriteName))
                {
                    string sprite = mSpriteName;
                    mSpriteName = "";
                    spriteName = sprite;
                    MarkAsChanged();
                }
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
                // If the sprite name hasn't been set yet, no need to do anything
                if (string.IsNullOrEmpty(mSpriteName)) return;

                // Clear the sprite name and the sprite reference
                mSpriteName = "";
                mSprite = null;
                mChanged = true;
                mSpriteSet = false;
            }
            else if (mSpriteName != value)
            {
                // If the sprite name changes, the sprite reference should also be updated
                mSpriteName = value;
                mSprite = null;
                mChanged = true;
                mSpriteSet = false;
            }
        }
    }

    public bool isValid { get { return GetAtlasSprite() != null; } }

    public UISpriteData GetAtlasSprite()
    {
        if (!mSpriteSet) mSprite = null;

        if (mSprite == null && mAtlas != null)
        {
            if (!string.IsNullOrEmpty(mSpriteName))
            {
                UISpriteData sp = mAtlas.GetSprite(mSpriteName);
                if (sp == null) return null;
                SetAtlasSprite(sp);
            }

            if (mSprite == null && mAtlas.spriteList.Count > 0)
            {
                UISpriteData sp = mAtlas.spriteList[0];
                if (sp == null) return null;
                SetAtlasSprite(sp);

                if (mSprite == null)
                {
                    Debug.LogError(mAtlas.name + " seems to have a null sprite!");
                    return null;
                }
                mSpriteName = mSprite.name;
            }
        }
        return mSprite;
    }

    protected void SetAtlasSprite(UISpriteData sp)
    {
        mChanged = true;
        mSpriteSet = true;

        if (sp != null)
        {
            mSprite = sp;
            mSpriteName = mSprite.name;
        }
        else
        {
            mSpriteName = (mSprite != null) ? mSprite.name : "";
            mSprite = sp;
        }
    }

    public override void MakePixelPerfect()
    {
        if (!isValid) return;
        base.MakePixelPerfect();

        Texture tex = mainTexture;
        UISpriteData sp = GetAtlasSprite();

        if (tex != null && sp != null)
        {
            int x = Mathf.RoundToInt(atlas.pixelSize * (sp.width + sp.paddingLeft + sp.paddingRight));
            int y = Mathf.RoundToInt(atlas.pixelSize * (sp.height + sp.paddingTop + sp.paddingBottom));

            if ((x & 1) == 1) ++x;
            if ((y & 1) == 1) ++y;

            width = x;
            height = y;
        }
    }

    protected override void OnUpdate()
    {
        base.OnUpdate();

        if (mChanged || !mSpriteSet)
        {
            mSpriteSet = true;
            mSprite = null;
            mChanged = true;
        }
    }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        Texture tex = mainTexture;

        if (tex != null)
        {
            if (mSprite == null) mSprite = atlas.GetSprite(spriteName);
            if (mSprite == null) return;

            Color colF = color;
            colF.a = finalAlpha;
            Color col = atlas.premultipliedAlpha ? NGUITools.ApplyPMA(colF) : colF;

            Rect rect = new Rect(mSprite.x, mSprite.y, mSprite.width, mSprite.height);
            rect = NGUIMath.ConvertToTexCoords(rect, tex.width, tex.height);
            Vector2 uv0 = new Vector2(rect.xMin, rect.yMin);
            Vector2 uv1 = new Vector2(rect.xMax, rect.yMax);

            Vector4 v = drawingDimensions;

            Vector2 us = (uv1 - uv0) * 0.5f;
            Vector2 vs = new Vector2(v.z - v.x, v.w - v.y) * 0.5f;

            float mid = Mathf.Max(v.y + vs.y, v.w - vs.x);

            //verts.Add(new Vector3(v.x + vs.x, v.w));
            //verts.Add(new Vector3(v.x, v.y));
            //verts.Add(new Vector3(v.z, v.y));
            //verts.Add(new Vector3(v.z, v.y));
            //uvs.Add(new Vector2(uv0.x + us.x, uv1.y));
            //uvs.Add(uv0);
            //uvs.Add(new Vector2(uv1.x, uv0.y));
            //uvs.Add(new Vector2(uv1.x, uv0.y));

            verts.Add(new Vector3(v.x + vs.x * 0.8f, mid));
            verts.Add(new Vector3(v.x, v.y));
            verts.Add(new Vector3(v.z, v.y));
            verts.Add(new Vector3(v.z - vs.x * 0.8f, mid));
            uvs.Add(new Vector2(uv0.x + us.x * 0.8f, uv0.y + us.y));
            uvs.Add(uv0);
            uvs.Add(new Vector2(uv1.x, uv0.y));
            uvs.Add(new Vector2(uv1.x - us.x * 0.8f, uv0.y + us.y));
            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
            cols.Add(col);

            verts.Add(new Vector3(v.x + vs.x, mid));
            verts.Add(new Vector3(v.x, Mathf.Max(v.y, v.w - vs.x * 2f)));
            verts.Add(new Vector3(v.x + vs.x, v.w));
            verts.Add(new Vector3(v.z, Mathf.Max(v.y, v.w - vs.x * 2f)));
            uvs.Add(new Vector2(uv0.x + us.x, uv0.y + us.y));
            uvs.Add(uv0);
            uvs.Add(new Vector2(uv0.x + us.x, uv1.y));
            uvs.Add(new Vector2(uv1.x, uv0.y));
            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
        }
      
    }
}
