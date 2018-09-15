//Assets Manager Copyright © 何权

using System.Collections.Generic;
using UnityEngine;

public class AssetTree : ScriptableObject
{
    [SerializeField] public Texture2D defaultTexture;
    [SerializeField] public Texture2D defaultAvatar;
    [SerializeField] public Texture2D loadingTexture;
    [SerializeField] public UIAtlas mainAtlas;
    [SerializeField] public Font mainFont;
    [SerializeField] public Shader commonShader;

    [SerializeField] public AssetMeta[] assetList;
    [SerializeField] public string[] paths;

    [System.NonSerialized] private Dictionary<string, AssetMeta> mAssetDic;

    public void Init()
    {
        int count = assetList == null ? 0 : assetList.Length;
        if(mAssetDic == null)
        {
            mAssetDic = new Dictionary<string, AssetMeta>(count);
        }
        if (count > 0)
        {
            mAssetDic.Clear();
            foreach (AssetMeta item in assetList) mAssetDic[item.name] = item;
        }
        assetList = null;

        if (mainAtlas) AssetManager.SetAssetWeight(mainAtlas.name, byte.MaxValue);
        if (mainFont) AssetManager.SetAssetWeight(mainFont.name, byte.MaxValue);
    }

    public AssetMeta GetAssetMeta(string assetName)
    {
        AssetMeta meta;
        mAssetDic.TryGetValue(assetName, out meta);
        return meta;
    }

    public string GetPath(int pathID)
    {
        return pathID >= 0 && pathID < paths.Length ? paths[pathID] : string.Empty;
    }
}
