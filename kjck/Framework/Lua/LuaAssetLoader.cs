#if TOLUA
using UnityEngine;
using System.Collections.Generic;

public class LuaAssetLoader : AssetLoader
{
    [SerializeField] protected bool mIsParallel = false;
    [SerializeField] protected bool mDisposeRes = false;

    [SerializeField] protected LuaContainer mLua;
    [SerializeField] public bool transferSelf;
    [SerializeField] public string onLuaAssetLoad;

    protected Dictionary<string, Asset> mAssets = new Dictionary<string, Asset>();

    void Awake()
    {
        if (!mLua) mLua = GetComponent<LuaContainer>();
    }

    public virtual Asset LoadImmediate(string assetName)
    {
        return string.IsNullOrEmpty(assetName) ? null : AssetManager.LoadAsset(assetName, this);
    }
    public virtual Asset Load(string assetName)
    {
        return string.IsNullOrEmpty(assetName) ? null : AssetManager.LoadAssetAsync(assetName, this, mIsParallel);
    }
#if UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetAdd(Asset asset)
    {
        if (mAssets != null && !mAssets.ContainsKey(asset.name))
        {
            mAssets.Add(asset.name, asset);
        }
    }
#if UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetComplete(Asset asset)
    {
        if (mLua && !string.IsNullOrEmpty(onLuaAssetLoad))
        {
            if (transferSelf)
            {
                mLua.CallFunction(onLuaAssetLoad, this, asset);
            }
            else
            {
                mLua.CallFunction(onLuaAssetLoad, asset);
            }
        }
    }
    public virtual void Remove(string assetName)
    {
        Asset asset = null;
        if (mAssets.TryGetValue(assetName, out asset))
        {
            mAssets.Remove(assetName);
        }
        RemoveAsset(asset);
    }
    public override bool Contains(Asset asset) { return mAssets != null && mAssets.ContainsKey(asset.name); }
    public override void Dispose()
    {
        RemoveAsset(mAssets.Values, mDisposeRes);
        mAssets.Clear();
    }
    public void Dispose(string assetName)
    {
        Asset asset = null;
        mAssets.TryGetValue(assetName, out asset);
        if (asset == null) return;
        RemoveAsset(asset, mDisposeRes);
        mAssets.Remove(assetName);
    }
    public Asset GetAsset(string assetName)
    {
        if (string.IsNullOrEmpty(assetName)) return null;
        Asset asset = null;
        mAssets.TryGetValue(assetName, out asset);
        return asset;
    }
    public Object GetAsset(string assetName, System.Type type)
    {
        if (type == null || string.IsNullOrEmpty(assetName)) return null;
        Asset asset = null;
        mAssets.TryGetValue(assetName, out asset);
        if (asset == null || !asset.isDone) return null;
        return asset.GetAsset(type);
    }
    public Object GetAsset(string assetName, string typeName) { return GetAsset(assetName, System.Type.GetType(typeName)); }
    public virtual bool doneAndProcess(out float process)
    {
        bool ret = true;
        process = 0f;
        if (mAssets.Count > 0)
        {
            foreach (Asset asset in mAssets.Values)
            {
                if (asset == null) { ret = false; continue; }
                process += asset.process;
                if (ret && !asset.isDone) ret = false;
            }
            process /= mAssets.Count;
        }
        return ret;
    }
    public override float process
    {
        get
        {
            float process = 0f;
            if (mAssets.Count > 0)
            {
                foreach (Asset asset in mAssets.Values)
                {
                    if (asset != null)
                    {
                        process += asset.process;
                    }
                }
                process /= mAssets.Count;
            }
            return process;
        }
    }
    public override bool isDone
    {
        get
        {
            if (mAssets.Count > 0)
            {
                foreach (Asset asset in mAssets.Values)
                {
                    if (asset != null && !asset.isDone)
                    {
                        return false;
                    }
                }
            }
            return true;
        }
    }
    public override bool isTimeOut { get { return false; } }
    public override string processMessage { get { return string.Empty; } }
}
#endif