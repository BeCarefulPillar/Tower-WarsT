using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIMultiSprite : UIMultiWidget
{
    [SerializeField] private UIAtlas mAtlas;
    [SerializeField] private bool mMulti = false;
    [SerializeField] private string[] mSpriteNames;

    [System.NonSerialized] private UISpriteData[] mSprites;
    [System.NonSerialized] private int mTexWidth;
    [System.NonSerialized] private int mTexHeight;

    protected override void OnStart()
    {
        base.OnStart();

        Texture tex = mainTexture;
        if (tex)
        {
            mTexWidth = tex.width;
            mTexHeight = tex.height;
        }
    }

    public override Texture mainTexture
    {
        get
        {
            Material mat = mAtlas ? mAtlas.spriteMaterial : null;
            return mat ? mat.mainTexture : null;
        }
        set
        {
            base.mainTexture = value;
        }
    }

    public override Material material
    {
        get
        {
            var mat = base.material;
            if (mat) return mat;
            return mAtlas ? mAtlas.spriteMaterial : null;
        }
        set
        {
            base.material = value;
        }
    }

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
                if (mSprites != null) System.Array.Clear(mSprites, 0, mSprites.Length);
                Texture tex = mainTexture;
                if (tex)
                {
                    mTexWidth = tex.width;
                    mTexHeight = tex.height;
                }
                MarkAsChanged();
            }
        }
    }

    public override bool premultipliedAlpha { get { return (mAtlas != null) && mAtlas.premultipliedAlpha; } }

    public bool isMulti { get { return mMulti; } set { mMulti = value; mChanged = true; } }

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
                if (mSpriteNames == null)
                {
                    mSpriteNames = new string[value];
                }
                else
                {
                    System.Array.Resize(ref mSpriteNames, value);
                }
                if (mSprites != null) System.Array.Resize(ref mSprites, value);
            }
            else
            {
                mSpriteNames = null;
                mSprites = null;
            }
        }
    }

    public string GetSprite(int idx)
    {
        if (mMulti)
        {
            return mSpriteNames != null && idx >= 0 && idx < mSpriteNames.Length ? mSpriteNames[idx] : null;
        }
        return mSpriteNames != null && mSpriteNames.Length > 0 ? mSpriteNames[0] : null;
    }

    public void SetSprite(int idx, string spriteName)
    {
        if (mSpriteNames == null || idx < 0 || idx >= mSpriteNames.Length || mSpriteNames[idx] == spriteName) return;
        mSpriteNames[idx] = spriteName;
        if (mSprites != null) mSprites[idx] = null;
        mChanged = true;
    }

    public void AddSprite(string spriteName)
    {
        if (mSpriteNames == null)
        {
            mSpriteNames = new string[1] { spriteName };
            if (mSprites != null) System.Array.Resize(ref mSprites, 1);
        }
        else
        {
            int len = mSpriteNames.Length;
            System.Array.Resize(ref mSpriteNames, len + 1);
            mSpriteNames[len] = spriteName;
            if (mSprites != null) System.Array.Resize(ref mSprites, mSpriteNames.Length);
        }
        mChanged = true;
    }

    public void RemoveSprite(int idx)
    {
        if (mSpriteNames == null || idx < 0 || idx >= mSpriteNames.Length) return;
        int len = mSpriteNames.Length;
        if (mSprites != null && mSprites.Length != len) mSprites = null;
        if (idx < len - 1)
        {
            System.Array.Copy(mSpriteNames, idx + 1, mSpriteNames, idx, len - idx - 1);
            if (mSprites != null) System.Array.Copy(mSprites, idx + 1, mSprites, idx, len - idx - 1);
        }
        System.Array.Resize(ref mSpriteNames, len - 1);
        if (mSprites != null) System.Array.Resize(ref mSprites, len - 1);
        mChanged = true;
    }

    public override void ClearUnit()
    {
        base.ClearUnit();
        mSpriteNames = null;
        mSprites = null;
    }

    public void ClearCache() { mSprites = null; }
    public void ClearCache(int idx)
    {
        if (mSprites == null || idx < 0 || idx >= mSprites.Length) return;
        mSprites[idx] = null;
    }

    public override Unit AddUnit(Vector3 pos, Vector3 scale, Color color, float rotate)
    {
        Unit u = base.AddUnit(pos, scale, color, rotate);
        AddSprite(null);
        return u;
    }

    public override void RemoveUnit(int idx)
    {
        base.RemoveUnit(idx);
        RemoveSprite(idx);
    }

    protected override Rect OnGetUV(int idx)
    {
        if (mAtlas && mSpriteNames != null && mSpriteNames.Length > 0)
        {
            if (mMulti)
            {
                if (idx < 0 || idx >= mSpriteNames.Length) return Rect.zero;
            }
            else
            {
                idx = 0;
            }
            if (mSprites == null || mSprites.Length != mSpriteNames.Length)
            {
                mSprites = new UISpriteData[mSpriteNames.Length];
            }
            string sp = mSpriteNames[idx];
            if (!string.IsNullOrEmpty(sp))
            {
                UISpriteData spd = mSprites[idx];
                if (spd == null)
                {
                    spd = mSprites[idx] = mAtlas.GetSprite(sp);
                }
                if (spd != null)
                {
#if UNITY_EDITOR
                    mTexWidth = mainTexture.width;
                    mTexHeight = mainTexture.height;
#endif
                    return NGUIMath.ConvertToTexCoords(new Rect(spd.x, spd.y, spd.width, spd.height), mTexWidth, mTexHeight);
                    //return new Rect(spd.x, spd.y, spd.width, spd.height);
                }
            }
        }
        return Rect.zero;
    }
}
