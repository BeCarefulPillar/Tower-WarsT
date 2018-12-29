using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssetLoader : UMonoBehaviour
{
    [SerializeField]
    private string mAssetName;
    [SerializeField]
    private bool mIsParallel;
    [SerializeField]
    private bool mImmediate = true;
    [System.NonSerialized]
    private Asset mAsset;
    [System.NonSerialized]
    private System.Action<Asset> onAssetLoad;

    private void Awake()
    {
        if(mAsset == null)
        {
            enabled = false;
            if(!string.IsNullOrEmpty(mAssetName))
            {
                if(mImmediate)
                    LoadImmediate(mAssetName);
                else
                    Load(mAssetName);
            }
        }
    }

    private void LoadImmediate(string assetName)
    {
        if (!string.IsNullOrEmpty(assetName))
        {
            mAssetName = assetName;
        }
    }

    private void Load(string assetName)
    {
        if (!string.IsNullOrEmpty(assetName))
        {
            mAssetName = assetName;
            //AssetManager.Ins.load
        }
    }
}