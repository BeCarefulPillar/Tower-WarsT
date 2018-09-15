using UnityEngine;
using System.Collections;

[RequireComponent(typeof(AudioSource))]
public class SOESetPlayer : AssetLoader
{
    [SerializeField] private string mSoeSetName;
    [SerializeField] private bool mIsParallel = false;
    [SerializeField] private bool mImmediate = false;

    [System.NonSerialized] private Asset mAsset;
    [System.NonSerialized] private SOESet mSoeSet;
    [System.NonSerialized] private AudioSource mAudio;

    private void Start()
    {
        mAudio = GetComponent<AudioSource>();

        if (mAsset == null)
        {
            enabled = false;

            if (!string.IsNullOrEmpty(mSoeSetName))
            {
                if (mImmediate)
                {
                    LoadImmediate(mSoeSetName);
                }
                else
                {
                    Load(mSoeSetName);
                }
            }
        }
    }

    public void Play(string soeName)
    {
        if (mSoeSet && mAudio)
        {
            AudioClip ac = mSoeSet.Get(soeName);
            if (ac)
            {
                mAudio.PlayOneShot(ac, NGUITools.soundVolume);
            }
        }
    }
    public void Play(int index)
    {
        if (mSoeSet && mAudio)
        {
            AudioClip ac = mSoeSet.Get(index);
            if (ac)
            {
                mAudio.PlayOneShot(ac, NGUITools.soundVolume);
            }
        }
    }

    public void LoadImmediate(string soeSetName)
    {
        Dispose();
        if (!string.IsNullOrEmpty(soeSetName))
        {
            mSoeSetName = soeSetName;
            AssetManager.LoadAsset(soeSetName, this);
        }
    }
    public void Load(string assetName)
    {
        Dispose();
        if (!string.IsNullOrEmpty(assetName))
        {
            mSoeSetName = assetName;
            AssetManager.LoadAssetAsync(assetName, this, mIsParallel);
        }
    }
#if UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetAdd(Asset asset)
    {
        if (asset.name == mSoeSetName && mAsset == null)
        {
            mAsset = asset;
        }
    }
#if UNITY_EDITOR
    [LuaInterface.NoToLua]
#endif
    public override void OnAssetComplete(Asset asset)
    {
        mSoeSet = mAsset.GetAsset<SOESet>();
    }
    public override bool Contains(Asset asset) { return mAsset == asset; }

    public override void Dispose()
    {
        RemoveAsset(mAsset);
        mAsset = null;
    }
}
