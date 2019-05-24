using UnityEngine;
using System;
using System.IO;
using System.Collections.Generic;
using Object = UnityEngine.Object;

/*
1.内部
Instantiate(AM.ins.LoadAsset("abc").prefab);
2.外部
Instantiate(AM.ins.LoadAsset("abc").prefab);
*/

public class Asset : IDisposable
{
    private Object mRes;
    private HashSet<GameObject> mRefs;
    private Asset() { }
    public static Asset Create(Object res)
    {
        if (!res)
            return null;
        return new Asset() { mRes = res, mRefs = new HashSet<GameObject>() };
    }
    public void AddRef(GameObject go) { if (!go) return; mRefs.Add(go); }
    public void RemoveRef(GameObject go) { if (!go) return; mRefs.Remove(go); }
    public Object res { get { return mRes; } }
    public HashSet<GameObject> refs { get { return mRefs; } }
    public void Dispose()
    {
        if (mRes is AssetBundle)
            (mRes as AssetBundle).Unload(true);
        mRes = null;
        mRefs.Clear();
    }
    public GameObject prefab
    {
        get
        {
            if (mRes is AssetBundle)
                return (mRes as AssetBundle).LoadAsset<GameObject>(mRes.name);
            return mRes as GameObject;
        }
    }
}