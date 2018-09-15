using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
[AddComponentMenu("NGUIEX/UI/UIChart")]
public class UIChart : UIWidget 
{
    [HideInInspector][SerializeField] UIAtlas mAtlas;
	[HideInInspector][SerializeField] string mSpriteName;
	[HideInInspector][SerializeField] bool mInvert = false;
    [HideInInspector][SerializeField] int vertices = 3;

    [HideInInspector][SerializeField] float[] vertexValues;

    protected UISpriteData mSprite;
    protected Rect mOuterUV;

    bool mSpriteSet = false;

    /// <summary>
    /// Atlas used by this widget.
    /// </summary>

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

                // Make sure the panel knows that the draw calls may have changed
                if (panel != null) panel.RebuildAllDrawCalls();
                
            }
        }
    }

    /// <summary>
    /// Sprite within the atlas used to draw this widget.
    /// </summary>

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

    /// <summary>
    /// Is there a valid sprite to work with?
    /// </summary>

    public bool isValid { get { return GetAtlasSprite() != null; } }

    /// <summary>
    /// Retrieve the material used by the font.
    /// </summary>
    public override Material material { get { return (mAtlas != null) ? mAtlas.spriteMaterial : null; } }

    /// <summary>
    /// Outer set of UV coordinates.
    /// </summary>

    public Rect outerUV { get { return mOuterUV; } }

    /// <summary>
    /// Whether the sprite should be filled in the opposite direction.
    /// </summary>

    public bool invert
    {
        get
        {
            return mInvert;
        }
        set
        {
            if (mInvert != value)
            {
                mInvert = value;
                mChanged = true;
            }
        }
    }

    public int Vertices
    {
        get { return vertices; }
        set
        {
            value = Mathf.Max(3, value);
            if (vertices != value)
            {
                vertices = value;
                mChanged = true;
            }
        }
    }

    public float[] VertexValues
    {
        get
        {
            if (vertexValues == null)
            {
                vertexValues = new float[vertices];
                for (int i = 0; i < vertices; i++) vertexValues[i] = 1;
            }
            else
            {
                int len = vertexValues.Length;
                if (len != vertices)
                {
                    System.Array.Resize<float>(ref vertexValues, vertices);
                    if (len < vertices) for (int i = len; i < vertices; i++) vertexValues[i] = 1;
                }
            }
            return vertexValues;
        }
    }

    public void SetVertexValues(params float[] values)
    {
        if (values == null) return;
        int len = values.Length;
        if (len != Vertices)
            System.Array.Resize<float>(ref values, Vertices);
        values.ForEach(v => { v = Mathf.Clamp01(v); });
        vertexValues = values;
        MarkAsChanged();
    }

    /// <summary>
    /// Retrieve the atlas sprite referenced by the spriteName field.
    /// </summary>

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

    /// <summary>
    /// Set the atlas sprite directly.
    /// </summary>

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

    /// <summary>
    /// Adjust the size of the widget to make it pixel-perfect.
    /// </summary>

    override public void MakePixelPerfect()
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

    /// <summary>
    /// Update the UV coordinates.
    /// </summary>

    override protected void OnUpdate()
    {
        base.OnUpdate();

        if (mChanged || !mSpriteSet)
        {
            mSpriteSet = true;
            mSprite = null;
            mChanged = true;
        }
    }

    /// <summary>
    /// Virtual function called by the UIScreen that fills the buffers.
    /// </summary>

    override public void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        Texture tex = mainTexture;
        if (tex != null )
        {
            if (mSprite == null) mSprite = atlas.GetSprite(spriteName);
            if (mSprite == null) return;
            mOuterUV.Set(mSprite.x, mSprite.y, mSprite.width, mSprite.height);
            mOuterUV = NGUIMath.ConvertToTexCoords(mOuterUV, tex.width, tex.height);
        }

        Vector4 dd = drawingDimensions;
        Vector2 ddc = new Vector2((dd.x + dd.z) * 0.5f, (dd.y + dd.w) * 0.5f);
        float dr = Mathf.Min(dd.z - dd.x, dd.w - dd.y) * 0.5f;
        //Vector2 dds = new Vector2(dd.z - dd.x, dd.w - dd.y);

        float pa = Mathf.PI * 2 / vertices;
        float ur = Mathf.Min(mOuterUV.width, mOuterUV.height) * 0.5f;
        Vector2 cu = mOuterUV.center;
        Vector2[] vs = new Vector2[vertices];
        Vector2[] us = new Vector2[vertices];

        for (int i = 0; i < vertices; i++)
        {
            float sa = Mathf.Sin(pa * i);
            float ca = Mathf.Cos(pa * i);
            float r = dr * VertexValues[i];
            vs[i] = ddc + new Vector2(r * sa, r * ca);
            r = ur * VertexValues[i];
            us[i] = cu + new Vector2(r * sa, r * ca);
        }

        int cors = 0;
        if (vertices == 3 || vertices == 4)
        {
            for (int i = 0; i < 4; i++)
            {
                int idx = i;
                if (idx == vertices) idx = 0;
                verts.Add(vs[idx]);
                uvs.Add(us[idx]);
            }
            cors = 4;
        }
        else if (vertices > 4)
        {
            int t = vertices / 2;
            for (int i = 0; i < t; i++)
            {
                verts.Add(ddc);
                uvs.Add(cu);
                for (int j = 0; j < 3; j++)
                {
                    int idx = i * 2 + j;
                    if (idx == vertices) idx = 0;
                    if (idx < vertices)
                    {
                        verts.Add(vs[idx]);
                        uvs.Add(us[idx]);
                    }
                }
                cors += 4;
            }
            if (vertices % 2 == 1)
            {
                verts.Add(ddc);
                uvs.Add(cu);
                verts.Add(vs[vertices - 1]);
                uvs.Add(us[vertices - 1]);
                verts.Add(vs[0]);
                uvs.Add(us[0]);
                verts.Add(ddc);
                uvs.Add(cu);
                cors += 4;
            }
        }

        Color colF = color;
        colF.a *= finalAlpha;
        Color col = atlas.premultipliedAlpha ? NGUITools.ApplyPMA(colF) : colF;

        for (int i = 0; i < cors; i++)
            cols.Add(col);
    }
}
