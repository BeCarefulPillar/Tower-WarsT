using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Win))]
public class PageLoader : AssetLoader
{
    private class PageAsset
    {
        public string name;
        public object data;
        public Transform parent;
        public Asset asset;
        public Page prefab;
        public Page page;
    }

    //[SerializeField] private bool mUseAnim = true;
    [SerializeField] private bool mIsParallel = false;

    [System.NonSerialized] private Win mWin;
    [System.NonSerialized] private Dictionary<string, PageAsset> mPages = new Dictionary<string, PageAsset>();
    [System.NonSerialized] private List<PageAsset> mLoadList = new List<PageAsset>(4);
    [System.NonSerialized] private Dictionary<int, Page> mMutexPage = new Dictionary<int, Page>();

    public Win win { get { if (mWin == null) mWin = GetComponent<Win>(); return mWin; } }

    public void Show(string name, Transform parent = null, object data = null)
    {
        if (string.IsNullOrEmpty(name)) return;

        PageAsset pa;
        mPages.TryGetValue(name, out pa);
        if (pa == null)
        {
            pa = new PageAsset();
            pa.name = name;
            pa.data = data;
            pa.parent = parent ?? win.cachedTransform;
            mPages[name] = pa;

            AssetManager.LoadAssetAsync(name, this, mIsParallel);

            return;
        }

        pa.data = data;
        pa.parent = parent ?? win.cachedTransform;

        TryShow(pa);
    }

    public void Show(Page page, Transform parent = null, object data = null)
    {
        if (page == null) return;

        if (page.GetInstanceID() > 0)
        {
            // 预制件
            string name = page.GetInstanceID().ToString();
            PageAsset pa;
            mPages.TryGetValue(name, out pa);
            if (pa == null)
            {
                pa = new PageAsset();
                pa.name = name;
                pa.data = data;
                pa.parent = parent ?? win.cachedTransform;
                pa.prefab = page;
                mPages[name] = pa;
            }
            else
            {
                pa.data = data;
                pa.parent = parent ?? win.cachedTransform;
                if (pa.prefab != page)
                {
                    pa.prefab = page;
                    if (pa.page)
                    {
                        Destroy(pa.page.cacheGameObject);
                        pa.page = null;
                    }
                }
            }

            TryShow(pa);
        }
        else
        {
            page.Show(data ?? page.data);
        }
    }

    public void Hide(string name)
    {
        if (string.IsNullOrEmpty(name)) return;

        PageAsset pa;
        mPages.TryGetValue(name, out pa);
        if (pa == null) return;

        if (pa.page) pa.page.Hide();

        mLoadList.Remove(pa);
    }

    public void Hide(Page page)
    {
        if (page.GetInstanceID() > 0)
        {
            // 预制件
            string name = page.GetInstanceID().ToString();
            PageAsset pa;
            mPages.TryGetValue(name, out pa);
            if (pa == null) return;

            if (pa.page) pa.page.Hide();

            mLoadList.Remove(pa);
        }
        else
        {
            page.Hide();
        }
    }

    public void HideAll()
    {
        mLoadList.Clear();
        foreach (PageAsset p in mPages.Values)
        {
            if (p != null && p.page)
            {
                p.page.Hide();
            }
        }
    }

    public void RefreshAll()
    {
        foreach (PageAsset p in mPages.Values)
        {
            if (p != null && p.page && p.page.isShow)
            {
                p.page.Refresh();
            }
        }
    }

    public void Refresh(string name)
    {
        if (string.IsNullOrEmpty(name)) return;

        PageAsset pa;
        mPages.TryGetValue(name, out pa);
        if (pa == null) return;

        if (pa.page) pa.page.Refresh();
    }

    public void CheckMutex(Page page)
    {
        if (page.isShow)
        {
            if (page.mutex == 0)
            {
                return;
            }

            Page mp;
            if (mMutexPage.TryGetValue(page.mutex, out mp) && mp && mp.isShow && mp.mutex == page.mutex)
            {
                mp.Hide();
            }

            mMutexPage[page.mutex] = page;
        }
    }

    private void TryShow(PageAsset pa, bool priority = true)
    {
        Page page = pa.page;
        if (page)
        {
            if (page.mutex == 0)
            {
                page.Show(pa.data ?? page.data);

                if (page.isShow && page.cacheTransform.parent != pa.parent)
                {
                    Vector3 pos = page.cacheTransform.localPosition;
                    page.cacheTransform.parent = pa.parent;
                    page.cacheTransform.localPosition = pos;
                }

                goto lbl_check;
            }
        }
        else if (pa.prefab && pa.prefab.mutex == 0)
        {
            CreateInstance(pa);
            page = pa.page;
            if (page)
            {
                page.Show(pa.data ?? page.data);
            }

            goto lbl_check;
        }

        if (pa.asset == null && pa.prefab == null) return;

        int idx = mLoadList.IndexOf(pa);
        if (idx < 0)
        {
            mLoadList.Add(pa);
        }
        else if (priority)
        {
            mLoadList.RemoveAt(idx);
            mLoadList.Add(pa);
        }

        lbl_check:

        if (mLoadList.Count < 1) return;

        for (int i = mLoadList.Count - 1; i >= 0; i--)
        {
            pa = mLoadList[i];
            //if (pa.asset == null)
            //{
            //    if (!pa.prefab) mLoadList.RemoveAt(i);
            //    continue;
            //}
            //if (pa.asset.isDone)
            //{
            //    if (!pa.prefab) mLoadList.RemoveAt(i);
            //    continue;
            //}
            if (pa.asset == null || pa.asset.isDone) continue;
            return;
        }

        HashSet<int> mutex = new HashSet<int>();

        for (int i = mLoadList.Count - 1; i >= 0; i--)
        {
            pa = mLoadList[i];
            page = pa.page;
            if (page)
            {
                if (page.mutex == 0 || !mutex.Contains(page.mutex))
                {
                    page.Show(pa.data ?? page.data);

                    if (page.isShow)
                    {
                        mutex.Add(page.mutex);

                        if (page.cacheTransform.parent != pa.parent)
                        {
                            Vector3 pos = page.cacheTransform.localPosition;
                            page.cacheTransform.parent = pa.parent;
                            page.cacheTransform.localPosition = pos;
                        }
                    }

                    continue;
                }
            }
            else if (pa.prefab && (pa.prefab.mutex == 0 || !mutex.Contains(pa.prefab.mutex)))
            {
                CreateInstance(pa);
                page = pa.page;
                if (page)
                {
                    page.Show(pa.data ?? page.data);

                    if (page.isShow)
                    {
                        mutex.Add(page.mutex);
                    }
                }
            }
        }

        mLoadList.Clear();
    }

    private void CreateInstance(PageAsset pa)
    {
        if (pa.page) return;
        if (pa.prefab)
        {
            GameObject go = Instantiate(pa.prefab.cacheGameObject) as GameObject;

            Page page = pa.page = go.GetComponent<Page>();

            if (page == null)
            {
                Debug.LogWarning("未找到指定的Page脚本，请检查["+ pa.prefab + "]是否添加了继承于Page的脚本");
#if UNITY_EDITOR
                DestroyImmediate(go);
#else
                Destroy(go); 
#endif
                return;
            }

            go.name = pa.prefab.name;
            go.layer = win.cachedGameObject.layer;
            go.SetActive(false);

            Transform trans = page.cacheTransform;
            Vector3 pos = trans.localPosition;
            trans.parent = pa.parent;
            trans.localPosition = pos;
            trans.localRotation = Quaternion.identity;
            trans.localScale = Vector3.one;

            if (go.GetComponent<UIPanel>())
            {
                UIPanel winPanel = win.GetComponent<UIPanel>();
                if (winPanel)
                {
                    BindPanel bp = go.GetComponent<BindPanel>();
                    if (bp)
                    {
                        bp.bind = winPanel;
                    }
                    else
                    {
                        bp = go.AddComponent<BindPanel>();
                        bp.Set(winPanel, 1);
                    }
                }
            }
        }
    }

    public override bool Contains(Asset asset)
    {
        return true;
    }

    public override void OnAssetComplete(Asset asset)
    {
        PageAsset pa;
        mPages.TryGetValue(asset.name, out pa);
        if (pa != null)
        {
            Page prefab = asset.GetAsset<Page>();
            if (prefab == null)
            {
                Debug.LogWarning("加载指定页面发生错误，请检查[" + pa.name + "]页面是否存在");
                return;
            }

            pa.asset = asset;

            if (pa.prefab != prefab)
            {
                pa.prefab = prefab;
                if (pa.page)
                {
                    Destroy(pa.page.cacheGameObject);
                    pa.page = null;
                }
            }
        }

        TryShow(pa);
    }

    public override void Dispose()
    {
        mLoadList.Clear();
        mMutexPage.Clear();

        foreach (PageAsset pa in mPages.Values)
        {
            if (pa == null) continue;
            if (pa.page) Destroy(pa.page.cacheGameObject);
            if (pa.asset == null) continue;
            RemoveAsset(pa.asset);
        }

        mPages.Clear();
    }
}
