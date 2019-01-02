using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssetManager : UMonoBehaviour
{
    private Dictionary<string, Asset> mAssets = new Dictionary<string, Asset>();

    private void Awake()
    {
    }

    private void Update()
    {
    }

    public Asset LoadAsset(string assetName, GameObject go)
    {
        Asset asset = CreateAsset(assetName, go);
        asset.Load();
        return asset;
    }

    //public Asset LoadAssetAsync(string assetName,GameObject go, AssetRequest callback)
    //{
    //    Asset asset = CreateAsset(assetName, go);
    //    if (asset.isDone || _curLoadAsset == asset)
    //        return asset;
    //    if (!_assetQueue.Contains(asset))
    //        _assetQueue.Enqueue(asset);
    //    if (callback != null)
    //        asset.AddCallback(callback);
    //    return asset;
    //}

    private Asset CreateAsset(string assetName, GameObject go)
    {
        Asset asset = null;
        mAssets.TryGetValue(assetName, out asset);
        if (asset == null)
        {
            asset = new Asset(assetName);
            asset.AddRef(go);
        }
        else
        {
            asset.AddRef(go);
        }
        return asset;
    }

    public static AssetManager Ins
    {
        get
        {
            return Game.Ins.mIns["AssetManager"] as AssetManager;
        }
    }
}