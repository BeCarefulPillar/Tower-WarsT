using UnityEngine;
using System.IO;
using System.Collections.Generic;

public class Asset
{
    private string mNm;
    private Object mRes;
    private AssetBundle mAb;
    private HashSet<GameObject> mRefs;
    /// <summary>
    /// 0初始 1正在加载 2加载完成 3加载中断
    /// </summary>
    private byte mStatus = 0;
    private float mExpiredTime = 0f;

    public Asset(string nm)
    {
        mNm = nm;
        mRefs = new HashSet<GameObject>();
    }

    public void Load()
    {
        if (isDone)
            return;
        string path = AM.ins.GetInternalPath(mNm);
        if (!string.IsNullOrEmpty(path))
            mRes = Resources.Load(path);
        else if(File.Exists("未写"))
            mAb = AssetBundle.LoadFromFile("未写");
        Done(mRes == null || mAb == null);
    }

    public void Done(bool interrupt)
    {
        if (isDone)
            return;
        if (interrupt)
            mStatus = 3;
    }

    public void AddRef(GameObject go) { if (!go) return; mRefs.Add(go); }

    public void RemoveRef(GameObject go) { if (!go) return; mRefs.Remove(go); }

    public T GetAsset<T>(string name) where T : Object
    {
        if (mRes)
            return mRes as T;
        if(mAb)
            return mAb.LoadAsset<T>(mNm);
        return null;
    }

    public GameObject prefab
    {
        get
        {
            return GetAsset<GameObject>(mNm);
        }
    }

    public bool isTimeOut { get { return mStatus == 1 && Time.realtimeSinceStartup > mExpiredTime; } }

    public bool isDone
    {
        get
        {
            return false;
        }
    }
}