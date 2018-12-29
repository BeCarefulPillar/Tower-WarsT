using System.Collections.Generic;
using UnityEngine;
using System.Collections;
using System.IO;
using System;
using Object = UnityEngine.Object;

public abstract class AbstractAsset : IDisposable
{
    public string mName;
    public AssetBundle mAssetBundle;
    public HashSet<GameObject> mRefs = new HashSet<GameObject>();

    public static string dir = "c:/test/";
    public static string ext = ".unity3d";

    public AbstractAsset(string name)
    {
        mName = name;
    }

    public abstract void Dispose();

    public bool NeedDispose
    {
        get
        {
            return mRefs.Count == 0;
        }
    }

    public void AddRef(GameObject go)
    {
        if (go != null && !mRefs.Contains(go))
            mRefs.Add(go);
    }

    public T GetAsset<T>(string name) where T : Object
    {
        if (!mAssetBundle)
            return null;
        return mAssetBundle.LoadAsset<T>(name);
    }

    public GameObject prefab { get { return GetAsset<GameObject>(mName); } }

    public Texture texture { get { return GetAsset<Texture>(mName); } }

    public Material material { get { return GetAsset<Material>(mName); } }

    public AudioClip audio { get { return GetAsset<AudioClip>(mName); } }

    public TextAsset text { get { return GetAsset<TextAsset>(mName); } }
}

public class Asset : AbstractAsset
{
    public Asset(string name)
        : base(name)
    {
    }

    public override void Dispose()
    {
        if (mRefs.Count != 0)
        {
            string str = string.Empty;
            int i = 1;
            foreach (GameObject go in mRefs)
                str += i++ == mRefs.Count ? go.name : go.name + ",";
            mRefs.Clear();
            Debug.LogWarningFormat("资源{0}正在被[{1}]使用", mName, str);
        }
        if (mAssetBundle)
        {
            mAssetBundle.Unload(true);
            mAssetBundle = null;
        }
    }

    public void Done()
    {
    }

    public void Load()
    {
        string path = dir + mName + ext;
        if (File.Exists(path))
        {
            mAssetBundle = AssetBundle.LoadFromFile(path);
            if (mAssetBundle)
            {
                Done();
            }
        }
    }
}


public class AsyncAsset : AbstractAsset
{
    public delegate void Request(AsyncAsset asset);

    /// <summary>
    /// 0=初始 1=正在加载 2=加载完成 3=加载中断
    /// </summary>
    public byte mStatus = 0;
    public List<Request> mCallbacks = new List<Request>();
    public IEnumerator mLoadCoroutine;

    public AsyncAsset(string name)
        : base(name)
    {
    }

    public bool Loading()
    {
        if (isDone)
            return false;
        if (mLoadCoroutine == null)
            mLoadCoroutine = OnLoad();
        return mLoadCoroutine.MoveNext();
    }

    private IEnumerator OnLoad()
    {
        mStatus = 1;
        string path = dir + mName + ext;
        AssetBundleCreateRequest abcr = AssetBundle.LoadFromFileAsync(path);
        while (!abcr.isDone)
            yield return null;
        mAssetBundle = abcr.assetBundle;
        Done();
    }

    public bool isDone
    {
        get
        {
            return mStatus == 2 || mStatus == 3;
        }
    }

    public bool isTimeOut
    {
        get
        {
            return false;
        }
    }

    private void Done()
    {
        if (isDone)
            return;

        mStatus = 2;
        mLoadCoroutine = null;

        if (mCallbacks.Count != 0)
        {
            Request f;
            for (int i = mCallbacks.Count - 1; i >= 0; --i)
            {
                f = mCallbacks[i];
                if (f != null)
                    f(this);
            }
            mCallbacks.Clear();
        }
    }

    public void AddCallback(Request callback)
    {
        if (callback != null)
        {
            if (mCallbacks == null)
                mCallbacks = new List<Request>();
            if (!mCallbacks.Contains(callback))
                mCallbacks.Add(callback);
        }
    }

    public override void Dispose()
    {
        throw new NotImplementedException();
    }
}