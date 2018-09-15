using UnityEngine;

public class SingleAssetLoader : AssetLoader
{

    [SerializeField] private string mAssetName;
    [SerializeField] private bool mIsParallel = false;
    [SerializeField] private bool mImmediate = false;

#if TOLUA
    [SerializeField] protected LuaContainer mLua;
    [SerializeField] protected bool mTransferSelf;
    [SerializeField] protected string mOnLuaAssetLoad;
#endif

    [System.NonSerialized] private Asset mAsset;

    public System.Action<Asset> onAssetLoad = null;

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
            mAssetName = assetName;
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
#if UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetAdd(Asset asset)
    {
        if (asset.name == mAssetName && mAsset == null)
        {
            mAsset = asset;
        }
    }
#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetComplete(Asset asset)
    {
        if (onAssetLoad.IsAvailable()) onAssetLoad(mAsset);
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
        RemoveAsset(mAsset);
        mAsset = null;
    }

    public T GetAsset<T>(string resName) where T : Object { return mAsset != null && mAsset.isDone ? mAsset.GetAsset<T>(resName) : null; }
    public T GetAsset<T>() where T : Object { return mAsset != null && mAsset.isDone ? mAsset.GetAsset<T>() : null; }
    public Object GetAsset(string typeName) { return mAsset != null && mAsset.isDone ? mAsset.GetAsset(typeName) : null; }
    public Object GetAsset(System.Type type) { return mAsset != null && mAsset.isDone ? mAsset.GetAsset(type) : null; }
    public Object GetAsset(string resName, string typeName) { return mAsset != null && mAsset.isDone ? mAsset.GetAsset(resName, typeName) : null; }
    public Object GetAsset(string resName, System.Type type) { return mAsset != null && mAsset.isDone ? mAsset.GetAsset(resName, type) : null; }
    public override float process { get { return mAsset != null ? mAsset.process : 0f; } }
    public override bool isDone { get { return mAsset != null && mAsset.isDone; } }
    public override bool isTimeOut { get { return mAsset != null && mAsset.isTimeOut; } }
    public override string processMessage { get { return mAsset != null ? mAsset.processMessage : string.Empty; } }
}
