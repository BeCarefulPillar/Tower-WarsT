//Assets Manager Copyright © 何权

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;

public class AssetLoader : MonoBehaviour, IProgress
{
    protected const float ANIM_WAIT_TIME = 0.5f;
    protected virtual void OnDestroy() { Dispose(); }
#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public virtual void OnAssetAdd(Asset asset) { }
#if UNITY_EDITOR && TOLUA
    [LuaInterface.NoToLua]
#endif
    public virtual void OnAssetComplete(Asset asset) { }

    public virtual bool Contains(Asset asset) { return false; }

    public virtual void Dispose() { }

    protected void RemoveAsset(Asset asset, bool dispose = false)
    {
        if (asset == null) return;
        if (dispose) asset.Dispose();
        asset.RemoveLoader(this);
    }
    protected void RemoveAsset(IEnumerable<Asset> assets, bool dispose = false)
    {
        if (assets == null) return;
        foreach (Asset asset in assets)
        {
            if (asset != null)
            {
                if (dispose) asset.Dispose();
                asset.RemoveLoader(this);
            }
        }
    }

    public virtual float process { get { return 0f; } }
    public virtual bool isDone { get { return true; } }
    public virtual bool isTimeOut { get { return false; } }
    public virtual string processMessage { get { return string.Empty; } }
}
