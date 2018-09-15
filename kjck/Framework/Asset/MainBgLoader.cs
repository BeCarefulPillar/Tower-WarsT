using UnityEngine;

public class MainBgLoader : AssetLoader
{
    [SerializeField] public bool loadOnStart = true;
    [SerializeField] public bool instant = true;
    [SerializeField] public UITexture bg;
    [SerializeField] public UITexture logo;
    [SerializeField] private string mBgName;
    [SerializeField] private string mLogoName;

    [System.NonSerialized] private Asset mBgAsset;
    [System.NonSerialized] private Asset mLogoAsset;

    private void Start()
    {
        if (bg == null) bg = GetComponent<UITexture>();
        if (loadOnStart)
        {
            if (bg && !string.IsNullOrEmpty(mBgName)) LoadBg(mBgName);
            if (logo && !string.IsNullOrEmpty(mLogoName)) LoadLogo(mLogoName);
        }
    }

    public void LoadBg(string nm) { LoadBg(nm, instant); }
    public void LoadBg(string nm, bool instant)
    {

        if (mBgAsset == null || mBgAsset.name != mBgName)
        {
            if (bg) bg.mainTexture = null;
            RemoveAsset(mBgAsset);
            mBgAsset = null;
        }
        mBgName = nm;
        this.instant = instant;
        if (bg == null || string.IsNullOrEmpty(mBgName)) return;
        if (instant)
        {
            AssetManager.LoadAsset(mBgName, this);
        }
        else
        {
            AssetManager.LoadAssetAsync(mBgName, this);
        }
    }

    public void LoadLogo(string nm) { LoadLogo(nm, instant); }
    public void LoadLogo(string nm, bool instant)
    {
        if (mLogoAsset == null || mLogoAsset.name != mLogoName)
        {
            if (logo) logo.mainTexture = null;
            RemoveAsset(mLogoAsset);
            mLogoAsset = null;
        }
        mLogoName = nm;
        this.instant = instant;
        if (logo == null || string.IsNullOrEmpty(mLogoName)) return;
        if (instant)
        {
            AssetManager.LoadAsset(mLogoName, this);
        }
        else
        {
            AssetManager.LoadAssetAsync(mLogoName, this);
        }
    }

#if TOLUA && UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override bool Contains(Asset asset)
    {
        return mBgAsset == asset || mLogoAsset == asset;
    }

#if TOLUA && UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetAdd(Asset asset)
    {
        if (asset == null) return;
        if (asset.name == mBgName)
        {
            mBgAsset = asset;
        }
        if (asset.name == mLogoName)
        {
            mLogoAsset = asset;
        }
    }

#if TOLUA && UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetComplete(Asset asset)
    {
        if (mBgAsset == asset)
        {
            if (bg) bg.mainTexture = asset.GetAsset<Texture>();
        }
        if (mLogoAsset == asset)
        {
            if (logo) logo.mainTexture = asset.GetAsset<Texture>();
        }
    }

#if TOLUA && UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void Dispose()
    {
        if (bg)
        {
            bg.mainTexture = null;
        }
        if (logo)
        {
            logo.mainTexture = null;
        }

        RemoveAsset(mBgAsset); mBgAsset = null;
        RemoveAsset(mLogoAsset); mLogoAsset = null;
    }
}
