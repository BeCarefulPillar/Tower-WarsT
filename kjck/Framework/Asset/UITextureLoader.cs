//Assets Manager Copyright © 何权

using UnityEngine;
using System.Collections.Generic;

public class UITextureLoader : AssetLoader, IUITextureLoader
{
    [SerializeField] private UITexture mUITexture;
    [SerializeField] private string mAssetName;
    [SerializeField] private bool mIsParallel = false;
    [SerializeField] private bool mImmediate = false;
    [SerializeField] private bool mLoadDefault = true;
    [SerializeField] private bool mUseAnim = true;

    [System.NonSerialized] private Asset mAsset;
    [System.NonSerialized] private float mFadeValue = 0f;
    [System.NonSerialized] private UIWidget.OnPostFillCallback mOnFade = null;

    public System.Action<UITextureLoader> onAssetLoad = null;
    public System.Action<IUITextureLoader> onLoad = null;
#if TOLUA
    public LuaContainer luaContainer = null;
    public bool luaTransferSelf = false;
    public string luaOnAssetLoad = null;
#endif

    private void Awake()
    {
        if (!mUITexture) mUITexture = GetComponent<UITexture>();
    }

    private void Start()
    {
        if (mAsset == null)
        {
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

    protected override void OnDestroy()
    {
        if (mOnFade != null)
        {
            mUITexture.onPostFill -= mOnFade;
            mOnFade = null;
        }
        base.OnDestroy();
    }

    public void LoadImmediate(string assetName)
    {
        if (mAsset == null || mAsset.name != assetName) Dispose();
        if (!string.IsNullOrEmpty(assetName))
        {
            mAssetName = assetName;
            AssetManager.LoadAsset(assetName, this);
        }
    }
    
    public void Load(string assetName)
    {
        if (mAsset == null || mAsset.name != assetName) Dispose();
        if (!string.IsNullOrEmpty(assetName))
        {
            mAssetName = assetName;
            AssetManager.LoadAssetAsync(assetName, this, mIsParallel);
        }
    }
    //private void Apply()
    //{
    //    if (mUITexture)
    //    {
    //        enabled = true;
    //        mUITexture.onPostFill = OnFade;
    //        //if (_asset != null && _asset.isDone && mUITexture.material == null && !(mUITexture.mainTexture is RenderTexture))
    //        if (_asset != null && _asset.isDone)
    //        {
    //            mUITexture.mainTexture = texture;
    //        }
    //    }
    //    //SceneManager.Current.StartCoroutine(OnApply());
    //}

    //private IEnumerator OnApply()
    //{
    //    yield return new WaitForEndOfFrame();
    //    if (mUITexture && mUITexture.material == null && !(mUITexture.mainTexture is RenderTexture))
    //    {
    //        enabled = true;
    //        mUITexture.onPostFill = OnFade;
    //        if (_asset != null && _asset.isDone)
    //        {
    //            mUITexture.mainTexture = texture;
    //        }
    //    }
    //}

    private void Update()
    {
        if (mUITexture)
        {
            if (texture)
            {
                if (mFadeValue < 1f)
                {
                    mFadeValue += Time.unscaledDeltaTime * 3.33f;
                    mUITexture.MarkAsChanged();
                    if (mOnFade == null)
                    {
                        mOnFade = OnFade;
                        uiTexture.onPostFill += mOnFade;
                    }
                }
                else
                {
                    mFadeValue = 1f;
                    enabled = false;
                    if (mOnFade != null)
                    {
                        mUITexture.onPostFill -= mOnFade;
                        mOnFade = null;
                    }
                }
            }
            else
            {
                if (mFadeValue > 0f && mUITexture.finalAlpha > 0f)
                {
                    mFadeValue -= Time.unscaledDeltaTime * 5f / mUITexture.finalAlpha;
                    mUITexture.MarkAsChanged();
                    if (mOnFade == null)
                    {
                        mOnFade = OnFade;
                        uiTexture.onPostFill += mOnFade;
                    }
                }
                else
                {
                    mFadeValue = 0f;
                    //if (mUITexture.mainTexture) mUITexture.mainTexture = null;
                    ApplyTexture(null);
                    enabled = false;
                    if (mOnFade != null)
                    {
                        mUITexture.onPostFill -= mOnFade;
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
        if (mUseAnim && mUITexture && mAsset != null && !mAsset.isDone)
        {
            UIAssetLoadAnim ula = UIAssetLoadAnim.Creat(this, true);
            if (ula)
            {
                ula.depth = mUITexture.depth;
                ula.secondDepth = 1000;
                ula.width = mUITexture.width;
                ula.height = mUITexture.height;
            }
        }
    }
#if UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetAdd(Asset asset)
    {
        if (asset.name == mAssetName)
        {
            mAsset = asset;
            if (mUseAnim && !mAsset.isDone)
            {
                if (IsInvoking("AddLoadingAnim")) CancelInvoke("AddLoadingAnim");
                Invoke("AddLoadingAnim", ANIM_WAIT_TIME);
            }
        }
    }
#if UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetComplete(Asset asset)
    {
        if (mUITexture)
        {
            enabled = true;
            if (mAsset != null && mAsset.isDone)
            {
                ApplyTexture(texture);
            }
            if (mOnFade == null)
            {
                mOnFade = OnFade;
                uiTexture.onPostFill += mOnFade;
            }
        }
        if (IsInvoking("AddLoadingAnim")) CancelInvoke("AddLoadingAnim");
        if (onAssetLoad.IsAvailable()) onAssetLoad(this);
        if (onLoad.IsAvailable()) onLoad(this);
#if TOLUA
        if (luaContainer && !string.IsNullOrEmpty(luaOnAssetLoad))
        {
            if(luaTransferSelf)
            {
                luaContainer.CallFunction(luaOnAssetLoad, this);
            }
            else
            {
                luaContainer.CallFunction(luaOnAssetLoad);
            }
        }
#endif
        base.OnAssetComplete(asset);
    }
    private void ApplyTexture(Texture tex)
    {
        mUITexture.mainTexture = tex;
        mUITexture.material = null;
        mUITexture.parentRect = new Rect(0f, 0f, 1f, 1f);
        mUITexture.CreatePanel();
    }
    public override bool Contains(Asset asset) { return mAsset == asset; }
    public override void Dispose()
    {
        if (mUITexture)
        {
            if (texture)
            {
                ApplyTexture(gameObject.activeInHierarchy ? texture : null);
                if (mUITexture.mainTexture)
                {
                    enabled = true;
                    mFadeValue = 1f;
                    if (mOnFade == null)
                    {
                        mOnFade = OnFade;
                        uiTexture.onPostFill += mOnFade;
                    }
                }
            }
            if (!enabled)
            {
                ApplyTexture(null);
                mFadeValue = 0f;
            }
        }
        mAssetName = string.Empty;
        RemoveAsset(mAsset);
        mAsset = null;
        UIAssetLoadAnim.Delete(this);
    }
    public override float process { get { return mAsset != null ? mAsset.process : 0f; } }
    public override bool isDone { get { return mAsset != null && mAsset.isDone; } }
    public override bool isTimeOut { get { return mAsset != null && mAsset.isTimeOut; } }
    public override string processMessage { get { return mAsset != null ? mAsset.processMessage : string.Empty; } }

    public UITexture uiTexture { get { return mUITexture; } }

    public Texture texture { get { return mAsset != null && mAsset.isDone ? mAsset.texture ?? (mLoadDefault ? AssetManager.defaultTexture : null) : null; } }

    public bool isAlive { get { return mUITexture && mAsset != null && (mLoadDefault || !mAsset.isInvalid); } }

    public bool isSuccess { get { return mAsset != null && mAsset.isDone && mAsset.texture; } }

    public static UITextureLoader LoadAsync(UITexture utex, string assetName) { return LoadAsync(utex, assetName, true, true, true); }
    public static UITextureLoader LoadAsync(UITexture utex, string assetName, bool loadDefault) { return LoadAsync(utex, assetName, loadDefault, true, true); }
    public static UITextureLoader LoadAsync(UITexture utex, string assetName, bool loadDefault, bool useAnim) { return LoadAsync(utex, assetName, loadDefault, useAnim, true); }
    public static UITextureLoader LoadAsync(UITexture utex, string assetName, bool loadDefault, bool useAnim, bool isParallel)
    {
        if (!utex || string.IsNullOrEmpty(assetName)) return null;
        UITextureLoader loader = utex.GetComponent<UITextureLoader>() ?? utex.gameObject.AddComponent<UITextureLoader>();
        loader.mUITexture = utex;
        loader.mLoadDefault = loadDefault;
        loader.mUseAnim = useAnim;
        loader.mImmediate = false;
        loader.mIsParallel = isParallel;
        loader.Load(assetName);
        return loader;
    }

    public static UITextureLoader LoadSync(UITexture utex, string assetName) { return LoadSync(utex, assetName, true); }
    public static UITextureLoader LoadSync(UITexture utex, string assetName, bool loadDefault)
    {
        if (!utex || string.IsNullOrEmpty(assetName)) return null;
        UITextureLoader loader = utex.GetComponent<UITextureLoader>() ?? utex.gameObject.AddComponent<UITextureLoader>();
        loader.mUITexture = utex;
        loader.mLoadDefault = loadDefault;
        loader.mUseAnim = false;
        loader.mImmediate = true;
        loader.mIsParallel = false;
        loader.LoadImmediate(assetName);
        return loader;
    }

    public static void UnLoad(UITexture utex, bool unloadRes)
    {
        if (!utex) return;
        UITextureLoader loader = utex.GetComponent<UITextureLoader>();
        if (loader)
        {
            if (unloadRes && loader.mAsset != null) loader.mAsset.Dispose(true);
            loader.Dispose();
        }
        else
        {
            utex.mainTexture = null;
            utex.material = null;
            utex.parentRect = new Rect(0f, 0f, 1f, 1f);
        }
    }

    public void SetOnLoad(System.Action<IUITextureLoader> onload)
    {
        this.onLoad = onload;
    }
}
