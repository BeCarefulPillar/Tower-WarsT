//Assets Manager Copyright © 何权

using UnityEngine;
using System.Collections.Generic;

public class AtlasLoader : AssetLoader
{
    [SerializeField] private UISprite mSprite;
    [SerializeField] private string mAssetName;
    [SerializeField] private bool mIsParallel = false;
    [SerializeField] private bool mImmediate = false;
    [SerializeField] private bool mUseAnim = true;

#if TOLUA
    [SerializeField] protected LuaContainer mLua;
    [SerializeField] protected bool mTransferSelf;
    [SerializeField] protected string mOnLuaAssetLoad;
#endif

    [System.NonSerialized] private Asset mAsset;
    [System.NonSerialized] private UIAtlas mAtlas;
    [System.NonSerialized] private float mFadeValue = 0f;
    [System.NonSerialized] private UIWidget.OnPostFillCallback mOnFade = null;

    public System.Action<AtlasLoader> onAssetLoad = null;

    private void Awake()
    {
        if (mSprite == null) mSprite = GetComponent<UISprite>();
    }

    private void Start()
    {
        if (mAsset == null)
        {
            enabled = false;

            if (!string.IsNullOrEmpty(mAssetName))
            {
                if (mImmediate)
                {
                    LoadImmediate(mAssetName);
                }
                else
                {
                    Load(mAssetName);
                }
            }
        }
    }
    public void LoadImmediate(string assetName)
    {
        Dispose();
        if (!string.IsNullOrEmpty(assetName))
        {
            AssetManager.LoadAsset(assetName, this);
        }
    }
    public void Load(string assetName)
    {
        Dispose();
        if (!string.IsNullOrEmpty(assetName))
        {
            mAssetName = assetName;
            AssetManager.LoadAssetAsync(assetName, this, mIsParallel);
        }
    }
    private void Apply()
    {
        if (mAsset != null && mAsset.isDone)
        {
            mAtlas = mAsset.GetAsset<UIAtlas>();
            if (mAtlas)
            {
                if (mSprite == null) mSprite = GetComponent<UISprite>();
                if (mSprite)
                {
                    enabled = true;
                    mSprite.atlas = mAtlas;
                    UISpriteAnimation spa = GetComponent<UISpriteAnimation>();
                    if (spa) spa.RebuildSpriteList();
                    if (mOnFade == null)
                    {
                        mOnFade = OnFade;
                        mSprite.onPostFill += mOnFade;
                    }
                }
            }
        }
    }

    protected override void OnDestroy()
    {
        if (mOnFade != null)
        {
            mSprite.onPostFill -= mOnFade;
            mOnFade = null;
        }
        base.OnDestroy();
    }

    private void Update()
    {
        if (mSprite)
        {
            if (mAtlas)
            {
                if (mFadeValue < 1f)
                {
                    mFadeValue += Time.unscaledDeltaTime * 3.33f;
                    mSprite.MarkAsChanged();
                    if (mOnFade == null)
                    {
                        mOnFade = OnFade;
                        mSprite.onPostFill += mOnFade;
                    }
                }
                else
                {
                    mFadeValue = 1f;
                    enabled = false;
                    if (mOnFade != null)
                    {
                        mSprite.onPostFill -= mOnFade;
                        mOnFade = null;
                    }
                }
            }
            else
            {
                if (mFadeValue > 0f && mSprite.finalAlpha > 0f)
                {
                    mFadeValue -= Time.unscaledDeltaTime * 5f / mSprite.finalAlpha;
                    mSprite.MarkAsChanged();
                    if (mOnFade == null)
                    {
                        mOnFade = OnFade;
                        mSprite.onPostFill += mOnFade;
                    }
                }
                else
                {
                    mFadeValue = 0f;
                    if (mSprite.atlas) mSprite.atlas = null;
                    enabled = false;
                    if (mOnFade != null)
                    {
                        mSprite.onPostFill -= mOnFade;
                        mOnFade = null;
                    }
                }
            }
        }
        else
        {
            enabled = false;
        }
    }

    private void OnFade(UIWidget widget, int bufferOffset, List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        for (int i = bufferOffset; i < cols.Count; i++)
        {
            Color cor = cols[i];
            cor.a *= mFadeValue;
            cols[i] = cor;
        }
    }

    private void AddLoadingAnim()
    {
        if (mUseAnim && mSprite && mAsset != null && !mAsset.isDone)
        {
            UIAssetLoadAnim ula = UIAssetLoadAnim.Creat(this, true);
            if (ula)
            {
                ula.depth = mSprite.depth;
                ula.secondDepth = 1000;
                ula.width = mSprite.width;
                ula.height = mSprite.height;
            }
        }
    }
#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetAdd(Asset asset)
    {
        if (asset.name == mAssetName && mAsset == null)
        {
            mAsset = asset;
            if (mUseAnim && !mAsset.isDone)
            {
                if (IsInvoking("AddLoadingAnim")) CancelInvoke("AddLoadingAnim");
                Invoke("AddLoadingAnim", ANIM_WAIT_TIME);
            }
        }
    }
#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetComplete(Asset asset)
    {
        Apply();
        if (IsInvoking("AddLoadingAnim")) CancelInvoke("AddLoadingAnim");
        if (onAssetLoad.IsAvailable()) onAssetLoad(this);
#if TOLUA
        if (mLua && !string.IsNullOrEmpty(mOnLuaAssetLoad))
        {
            if (mTransferSelf) mLua.CallFunction(mOnLuaAssetLoad, this);
            else mLua.CallFunction(mOnLuaAssetLoad);
        }
#endif
    }
    public override bool Contains(Asset asset) { return mAsset == asset; }

    public override void Dispose()
    {
        if (mSprite && mAtlas)
        {
            enabled = true;
            mFadeValue = 1f;
            if (mOnFade == null)
            {
                mOnFade = OnFade;
                mSprite.onPostFill += mOnFade;
            }
        }
        RemoveAsset(mAsset);
        mAtlas = null;
        mAsset = null;
        UIAssetLoadAnim.Delete(this);
    }

    public UIAtlas atlas { get { return mAtlas; } }
    public override float process { get { return mAsset != null ? mAsset.process : 0f; } }
    public override bool isDone { get { return mAsset != null && mAsset.isDone; } }
    public override bool isTimeOut { get { return mAsset != null && mAsset.isTimeOut; } }
    public override string processMessage { get { return mAsset != null ? mAsset.processMessage : string.Empty; } }

    public static AtlasLoader LoadAsync(UISprite sp, string assetName) { return LoadAsync(sp, assetName, true, false); }
    public static AtlasLoader LoadAsync(UISprite sp, string assetName, bool useAnim) { return LoadAsync(sp, assetName, useAnim, false); }
    public static AtlasLoader LoadAsync(UISprite sp, string assetName, bool useAnim, bool isParallel)
    {
        if (!sp || string.IsNullOrEmpty(assetName)) return null;
        AtlasLoader loader = sp.GetComponent<AtlasLoader>() ?? sp.gameObject.AddComponent<AtlasLoader>();
        loader.mSprite = sp;
        loader.mUseAnim = useAnim;
        loader.mImmediate = false;
        loader.Load(assetName);
        return loader;
    }
    public static void UnLoad(UISprite sp, bool unloadRes)
    {
        if (!sp) return;
        AtlasLoader loader = sp.GetComponent<AtlasLoader>();
        if (loader)
        {
            if (unloadRes && loader.mAsset != null) loader.mAsset.Dispose(true);
            loader.Dispose();
        }
    }
}