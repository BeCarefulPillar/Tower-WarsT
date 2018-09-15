//Assets Manager Copyright © 何权

using UnityEngine;
using System.Collections;

public class MultiAssetLoader : AssetLoader
{
    [SerializeField] private string[] mAssetNames;
    [SerializeField] private bool mIsParallel = false;
    [SerializeField] private bool mImmediate = false;
    [SerializeField] private bool mDisposeRes = false;

#if TOLUA
    [SerializeField] protected LuaContainer mLua;
    [SerializeField] protected bool mTransferSelf;
    [SerializeField] protected string mOnLuaAssetLoad;
#endif

    public System.Action<MultiAssetLoader> onAssetLoad = null;

    private Asset[] mAssets;

    private void Start()
    {
        if (mAssetNames == null || mAssets != null) return;
        if (mImmediate)
        {
            LoadImmediate(mAssetNames);
        }
        else
        {
            Load(mAssetNames);
        }
    }

    public void LoadImmediate(params string[] assetNames)
    {
        Dispose();
        if (assetNames != null) assetNames = System.Array.FindAll(assetNames, a => { return !string.IsNullOrEmpty(a); });
        if (assetNames.GetLength() > 0)
        {
            mAssetNames = assetNames;
            for (int i = 0; i < mAssetNames.Length; i++)
            {
                AssetManager.LoadAsset(mAssetNames[i], this);
            }
        }
    }
    public void Load(params string[] assetNames)
    {
        Dispose();
        if (assetNames != null) assetNames = System.Array.FindAll(assetNames, a => { return !string.IsNullOrEmpty(a); });
        if (assetNames.GetLength() > 0)
        {
            mAssetNames = assetNames;
            mAssets = new Asset[mAssetNames.Length];
            for (int i = 0; i < mAssetNames.Length; i++)
            {
                AssetManager.LoadAssetAsync(mAssetNames[i], this, mIsParallel);
            }
        }
    }
#if UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetAdd(Asset asset)
    {
        if (mAssetNames != null && mAssetNames.Contains(asset.name) && mAssets != null && !mAssets.Contains(asset))
        {
            for (int i = 0; i < mAssets.Length; i++)
            {
                if (mAssets[i] == null)
                {
                    mAssets[i] = asset;
                    return;
                }
            }
        }
    }
#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetComplete(Asset asset)
    {
        if (onAssetLoad.IsAvailable()) onAssetLoad(this);
#if TOLUA
        if (mLua && !string.IsNullOrEmpty(mOnLuaAssetLoad))
        {
            if (mTransferSelf) mLua.CallFunction(mOnLuaAssetLoad, this);
            else mLua.CallFunction(mOnLuaAssetLoad);
        }
#endif
    }
    public override bool Contains(Asset asset) { return mAssets != null && mAssets.Contains(asset); }
    public override void Dispose()
    {
        mAssetNames = null;
        RemoveAsset(mAssets, mDisposeRes);
        mAssets = null;
    }
    public T GetAsset<T>(int index) where T : Object { return mAssets.IndexAvailable(index) && mAssets[index] != null && mAssets[index].isDone ? mAssets[index].GetAsset<T>() : null; }
    public Object GetAsset(int index, System.Type type) { return type != null && mAssets.IndexAvailable(index) && mAssets[index] != null && mAssets[index].isDone ? mAssets[index].GetAsset(type) : null; }
    public Object GetAsset(int index, string typeName) { return GetAsset(index, System.Type.GetType(typeName)); }
    public bool doneAndProcess(out float process)
    {
        bool ret = true;
        process = 0f;
        if (mAssets.GetLength() > 0)
        {
            for (int i = 0; i < mAssets.Length; i++)
            {
                if (mAssets[i] == null) { ret = false; continue; }
                process += mAssets[i].process;
                if (ret && !mAssets[i].isDone) ret = false;
            }
            process /= mAssets.Length;
        }
        return ret;
    }
    public override float process
    {
        get
        {
            float process = 0f;
            if (mAssets.GetLength() > 0)
            {
                for (int i = 0; i < mAssets.Length; i++)
                {
                    if (mAssets[i] != null)
                    {
                        process += mAssets[i].process;
                    }
                }
                process /= mAssets.Length;
            }
            return process;
        }
    }
    public override bool isDone
    {
        get
        {
            if(mAssets.GetLength() > 0)
            {
                for (int i = 0; i < mAssets.Length; i++)
                {
                    if (mAssets[i] != null && !mAssets[i].isDone)
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
