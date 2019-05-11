using UnityEngine;
using System.Collections.Generic;

public class AM : Manager<AM>
{
    private Dictionary<string, string> mPaths = new Dictionary<string, string>();
    private Dictionary<string, Asset> mDic = new Dictionary<string, Asset>();
    private Queue<Asset> mAssetQueue = new Queue<Asset>();
    private Asset mCurLoadAsset;
    private GameObject mGo;

    public GameObject cachedGameObject { get { if (mGo == null) mGo = gameObject; return mGo; } }

    public override void Init()
    {
        base.Init();
    }

    public string GetInternalPath(string nm)
    {
        string path = null;
        mPaths.TryGetValue(nm, out path);
        return path;
    }

    public Asset LoadAsset(string nm, GameObject go = null)
    {
        Asset asset;
        if (!mDic.TryGetValue(nm, out asset))
            asset = new Asset(nm);
        asset.AddRef(go ?? cachedGameObject);
        asset.Load();
        return asset;
    }

    public Asset LoadAssetAsync(string nm, GameObject go = null)
    {
        Asset asset;
        if (!mDic.TryGetValue(nm, out asset))
            asset = new Asset(nm);
        asset.AddRef(go ?? cachedGameObject);
        if (!asset.isDone || mCurLoadAsset != asset || !mAssetQueue.Contains(asset))
            mAssetQueue.Enqueue(asset);
        return asset;
    }

    private void Update()
    {
        if (mCurLoadAsset != null)
        {
        }
        else
        {
            while (mAssetQueue.Count > 0 && mCurLoadAsset == null)
                mCurLoadAsset = mAssetQueue.Dequeue();
        }
    }
}