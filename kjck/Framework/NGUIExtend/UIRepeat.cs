using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
[AddComponentMenu("NGUIEX/UI/UIRepeat")]
public class UIRepeat : UIWidget {
    public enum Arrangement
	{
		Horizontal,
		Vertical,
	}

    [HideInInspector][SerializeField] UIAtlas mAtlas;//精灵所在的图集
	[HideInInspector][SerializeField] string backSpriteName;//底部精灵名称
	[HideInInspector][SerializeField] string frontSpriteName;//前面精灵名称
	[HideInInspector][SerializeField] string extendSpriteName;//反向扩展精灵名称
    [HideInInspector][SerializeField] Color backColor = Color.white;
    [HideInInspector][SerializeField] Color frontColor = Color.white;
    [HideInInspector][SerializeField] Color extendColor = Color.white;
    [HideInInspector][SerializeField] Arrangement mArrangement = Arrangement.Horizontal;

    [SerializeField]int curCount = 0;//当前计数
    [SerializeField]int extendCount=0;//扩展的计数
    [SerializeField]int totalCount = 1;//总数
    [SerializeField]float spacing = 0;//精灵之间的空隙

    private bool mUpdateUV = false;

    Rect backUV;//底部的UV
    Rect frontUV;//前面的UV
    Rect extendUV;//扩展的UV

    float XV;
    float YV;
    float sXV;
    float sYV;
    float bXV;
    float bYV;
    float eXV;
    float eYV;

    protected override void OnStart()
    {
        base.OnStart();
        if (mAtlas != null) UVChange();
    }

    public Arrangement arrangement
    {
        get { return mArrangement; }
        set
        {
            if (mArrangement != value)
            {
                mArrangement = value;
                UVChange();
            }
        }
    }

    /// <summary>
    /// 当前精灵计数
    /// </summary>
    public int Count
    {
        get
        {
            return curCount;
        }
        set
        {
            value = Mathf.Clamp(value, 0, totalCount - extendCount);
            if(curCount != value)
            {
                curCount = value;
                UVChange();
            }
        }
    }
    /// <summary>
    /// 后部扩展精灵计数
    /// </summary>
    public int ExtendCount
    {
        get
        {
            return extendCount;
        }
        set
        {
            value = Mathf.Clamp(value, 0, totalCount - curCount);
            if(extendCount != value)
            {
                extendCount = value;
                UVChange();
            }
        }
    }
    /// <summary>
    /// 总精灵数
    /// </summary>
    public int TotalCount
    {
        get
        {
            return totalCount;
        }
        set
        {
            value = Mathf.Max(0, value);
            if (value != totalCount)
            {
                ExtendCount = 0;
                if (value < Count) Count = value;
                totalCount = value;
                UVChange();
            }
        }
    }
    /// <summary>
    /// 精灵之间的间距
    /// </summary>
    public float Spacing
    {
        get
        {
            return spacing;
        }
        set
        {
            if (spacing == value) return;
            spacing = value;
            UVChange();
        }
    }
    /// <summary>
    /// UI图集
    /// </summary>
    public UIAtlas Atlas
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

                // Automatically choose the first sprite
                if (mAtlas != null && mAtlas.spriteList.Count > 0)
                {
                    frontSpriteName = mAtlas.spriteList[0].name;
                    backSpriteName = mAtlas.spriteList[0].name;
                    extendSpriteName = mAtlas.spriteList[0].name;
                    UVChange();
                }

                if (panel != null) panel.RebuildAllDrawCalls();
            }
        }
    }

    public override Material material { get { return (mAtlas != null) ? mAtlas.spriteMaterial : null; } }

    /// <summary>
    /// 底部精灵名称，数目表示总数
    /// </summary>
    public string BackSpriteName
    {
        get
        {
            return backSpriteName;
        }
        set
        {
            if (backSpriteName != value)
            {
                backSpriteName = value;
                UVChange();
            }
        }
    }
    
    /// <summary>
    /// 前面精灵名称，数目表示当前计数
    /// </summary>
    public string FrontSpriteName
    {
        get
        {
            return frontSpriteName;
        }
        set
        {
            if (frontSpriteName != value)
            {
                frontSpriteName = value;
                UVChange();
            }
        }
    }
    
    /// <summary>
    /// 后部扩展精灵名称，数目表示后部扩展总数
    /// </summary>
    public string ExtendSpriteName
    {
        get
        {
            return extendSpriteName;
        }
        set
        {
            if (extendSpriteName != value)
            {
                extendSpriteName = value;
                UVChange();
            }
        }
    }

    public Color FrontColor { get { return frontColor; } set { frontColor = value; UVChange(); } }
    public Color BackColor { get { return backColor; } set { backColor = value; UVChange(); } }
    public Color ExtendColor { get { return extendColor; } set { extendColor = value; UVChange(); } }

    /// <summary>
    /// 更新精灵的UV
    /// </summary>
    void UpdateUVs()
    {
        if (mAtlas == null) return;
        mUpdateUV = false;
        UISpriteData bs = mAtlas.GetSprite(backSpriteName);
        UISpriteData fs = mAtlas.GetSprite(frontSpriteName);
        UISpriteData es = mAtlas.GetSprite(extendSpriteName);
        backUV = new Rect(); frontUV = new Rect(); extendUV = new Rect();
        if (!string.IsNullOrEmpty(backSpriteName)) backUV.Set(bs.x, bs.y, bs.width, bs.height);
        if (!string.IsNullOrEmpty(frontSpriteName)) frontUV.Set(fs.x, fs.y, fs.width, fs.height);
        if (!string.IsNullOrEmpty(extendSpriteName)) extendUV.Set(es.x, es.y, es.width, es.height);
        float maxWidth = Mathf.Max(frontUV.width, backUV.width, extendUV.width);
        float maxHeight = Mathf.Max(frontUV.height, backUV.height, extendUV.height);
        float XW = maxWidth, YW = maxHeight;
        if (mArrangement == Arrangement.Vertical)
        {
            YW = totalCount * maxHeight + spacing * (totalCount - 1);
            XV = 0;
            //YV = (spacing + maxHeight) / YW;
            YV = spacing + maxHeight;
            width = Mathf.RoundToInt(Mathf.Max(minWidth, maxWidth));
            height = Mathf.RoundToInt(Mathf.Max(minHeight, YW));
        }
        else
        {
            XW = totalCount * maxWidth + spacing * (totalCount - 1);
            //XV = (spacing + maxWidth) / XW;
            XV = spacing + maxWidth;
            YV = 0;
            width = Mathf.RoundToInt(Mathf.Max(minWidth, XW));
            height = Mathf.RoundToInt(Mathf.Max(minHeight, maxHeight));
        }

        //sXV = frontUV.width / XW;
        //sYV = frontUV.height / YW;
        sXV = frontUV.width;
        sYV = frontUV.height;
        if (!string.IsNullOrEmpty(backSpriteName))
        {
            //bXV = backUV.width / XW;
            //bYV = backUV.height / YW;
            bXV = backUV.width;
            bYV = backUV.height;
        }
        if (!string.IsNullOrEmpty(extendSpriteName))
        {
            //eXV = extendUV.width / XW;
            //eYV = extendUV.height / YW;
            eXV = extendUV.width;
            eYV = extendUV.height;
        }

        Texture tex = mainTexture;
        backUV = NGUIMath.ConvertToTexCoords(backUV, tex.width, tex.height);
        frontUV = NGUIMath.ConvertToTexCoords(frontUV, tex.width, tex.height);
        extendUV = NGUIMath.ConvertToTexCoords(extendUV, tex.width, tex.height);
    }

    public void UVChange()
    {
        mChanged = mUpdateUV = true;
    }

    public override void MakePixelPerfect()
    {
        base.MakePixelPerfect();
        UpdateUVs();
    }

    protected override void OnUpdate()
    {
        base.OnUpdate();
        if (mChanged || mUpdateUV) UpdateUVs();
    }

    override public void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        if (mainTexture == null) return;
        
        Vector2 uv0 = new Vector2(frontUV.xMin, frontUV.yMin);
        Vector2 uv1 = new Vector2(frontUV.xMax, frontUV.yMax);

        Vector4 dd = drawingDimensions;

        Color colF = frontColor;
        colF.a *= finalAlpha;
        Color col = colF;

        for (int i = 0; i < curCount; i++)
        {
            float dx = i * XV, dy = i * YV;
            verts.Add(new Vector2(dd.x + dx, dd.y + dy));
            verts.Add(new Vector2(dd.x + dx, dd.y + dy + sYV));
            verts.Add(new Vector2(dd.x + dx + sXV, dd.y + dy + sYV));
            verts.Add(new Vector2(dd.x + dx + sXV, dd.y + dy));
            uvs.Add(uv0);
            uvs.Add(new Vector2(uv0.x, uv1.y));
            uvs.Add(uv1);
            uvs.Add(new Vector2(uv1.x, uv0.y));

            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
        }

        if (curCount >= totalCount && string.IsNullOrEmpty(backSpriteName)) return;
        uv0 = new Vector2(backUV.xMin, backUV.yMin);
        uv1 = new Vector2(backUV.xMax, backUV.yMax);
        int idx = totalCount - extendCount;
        colF = backColor;
        colF.a *= finalAlpha;
        col = colF;
        for (int i = curCount; i < idx; i++)
        {
            float dx = i * XV, dy = i * YV;
            verts.Add(new Vector2(dd.x + dx, dd.y + dy));
            verts.Add(new Vector2(dd.x + dx, dd.y + dy + bYV));
            verts.Add(new Vector2(dd.x + dx + bXV, dd.y + dy + bYV));
            verts.Add(new Vector2(dd.x + dx + bXV, dd.y + dy));
            uvs.Add(uv0);
            uvs.Add(new Vector2(uv0.x, uv1.y));
            uvs.Add(uv1);
            uvs.Add(new Vector2(uv1.x, uv0.y));

            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
        }
        if (idx >= totalCount && string.IsNullOrEmpty(extendSpriteName)) return;
        uv0 = new Vector2(extendUV.xMin, extendUV.yMin);
        uv1 = new Vector2(extendUV.xMax, extendUV.yMax);
        colF = extendColor;
        colF.a *= finalAlpha;
        col = colF;
        for (int i = idx; i < totalCount; i++)
        {
            float dx = i * XV, dy = i * YV;
            verts.Add(new Vector2(dd.x + dx, dd.y + dy));
            verts.Add(new Vector2(dd.x + dx, dd.y + dy + eYV));
            verts.Add(new Vector2(dd.x + dx + eXV, dd.y + dy + eYV));
            verts.Add(new Vector2(dd.x + dx + eXV, dd.y + dy));
            uvs.Add(uv0);
            uvs.Add(new Vector2(uv0.x, uv1.y));
            uvs.Add(uv1);
            uvs.Add(new Vector2(uv1.x, uv0.y));

            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
            cols.Add(col);
        }
    }
}
