using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssetManager : UMonoBehaviour
{
    private Dictionary<string, AbstractAsset> mAssets = new Dictionary<string, AbstractAsset>();
    private Queue<AsyncAsset> _assetQueue = new Queue<AsyncAsset>();
    private Asset _curLoadAsset;

    private void Awake()
    {
    }

    private void Update()
    {
        if (_curLoadAsset != null)
        {
            if (!_curLoadAsset.Loading())
                _curLoadAsset = null;
        }
        else if (_assetQueue.Count > 0)
        {
            while (_curLoadAsset == null)
            {
                _curLoadAsset = _assetQueue.Dequeue();
                if (_assetQueue.Count < 1)
                    break;
            }
        }
    }

    public Asset LoadAsset(string assetName,GameObject go)
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

    private Asset CreateAsset(string assetName,GameObject go)
    {
        Asset asset = null;
        mAssets.TryGetValue(assetName, out asset);
        if(asset==null)
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