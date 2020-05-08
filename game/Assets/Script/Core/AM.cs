using UnityEngine;
using System.IO;
using System.Collections.Generic;

public class AM : Manager<AM>
{
    private Dictionary<string, string> mPaths = new Dictionary<string, string>();
    private Dictionary<string, Asset> mDic = new Dictionary<string, Asset>();
    public Dictionary<string , Asset> dic { get { return mDic; } }
    private GameObject mGo;
    public GameObject cachedGameObject { get { if (mGo == null) mGo = gameObject; return mGo; } }
    public override void Init()
    {
        base.Init();
        //test
        mPaths.Add("abc", "Prefab/abc");
    }
    public Asset LoadAsset(string nm, GameObject go = null)
    {
        Asset asset = null;
        if (!mDic.TryGetValue(nm, out asset))
        {
            string path = "c:/res/" + nm + ".unity3d";
            if (File.Exists(path))
                asset = Asset.Create(AssetBundle.LoadFromFile(path));
            else if (mPaths.TryGetValue(nm, out path))
                asset = Asset.Create(Resources.Load(path));
            if (asset != null)
                mDic.Add(nm, asset);
        }
        if (asset != null)
            asset.AddRef(go ?? cachedGameObject);
        return asset;
    }
}