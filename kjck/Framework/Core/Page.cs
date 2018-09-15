using System;
using UnityEngine;

#if TOLUA
public partial class Page
#else
public class Page : MonoBehaviour, IPage
#endif
{
    [SerializeField] private AnimationAdapter mAnim;
    /// <summary>
    /// 互斥编号
    /// </summary>
    [SerializeField] private int mMutex;

    [NonSerialized] private Win mWin;

    [NonSerialized] private GameObject mGo;
    [NonSerialized] private Transform mTrans;
    [NonSerialized] private bool mIsInit = false;
    [NonSerialized] private bool mIsShow = false;
    [NonSerialized] private bool mIsHide = false;
    [NonSerialized] protected object mData;

    public Transform cacheTransform { get { if (mTrans == null) mTrans = transform; return mTrans; } }
    public GameObject cacheGameObject { get { if (mGo == null) mGo = gameObject; return mGo; } }
    /// <summary>
    /// 所属窗体
    /// </summary>
    public Win win { get { return mWin; } }
    /// <summary>
    /// 互斥编号
    /// </summary>
    public int mutex { get { return mMutex; } set { if (mMutex == value) return; mMutex = value; FindWin(); if (mWin) mWin.OnPageShow(this); } }

    public object data { get { return mData; } }
    public bool isInit { get { return mIsInit; } }

    public bool isShow { get { return mIsShow; } }

    private void Start()
    {
        if (mAnim) mAnim.onFinished = OnAnimFinished;

        FindWin();
    }

    private void FindWin()
    {
        if (mWin) return;
        mWin = cacheTransform.FindCmpInParent<Win>();
        if (mWin) cacheGameObject.layer = mWin.cachedGameObject.layer;
    }

    public void Init(object data)
    {
        Dispose();

        FindWin();

        mData = data;

        OnInit();

        mIsInit = true;
    }

    public void Show() { Show(mData); }

    public void Show(object data)
    {
        if (!mIsInit || mData != data)
        {
            Init(data);
        }

        cacheGameObject.SetActive(true);

        if (mIsShow) return;

        if (mAnim)
        {
            mAnim.onFinished = null;
            mAnim.Play();
        }

        mIsShow = true;
        mIsHide = false;

        OnShow();

        FindWin();

        if (mWin) mWin.OnPageShow(this);
    }

    public void Hide()
    {
        if (mIsShow)
        {
            mIsShow = false;

            if (mIsHide) return;

            if (mAnim)
            {
                mAnim.onFinished = OnAnimFinished;
                mAnim.PlayReverse();
                return;
            }

            mIsHide = true;
            cacheGameObject.SetActive(false);
            OnHide();
        }
    }

    private void OnAnimFinished(AnimationAdapter aa)
    {
        if (aa.isForward) return;
        if (mIsShow || mIsHide) return;
        mIsHide = true;
        cacheGameObject.SetActive(false);
        OnHide();
    }

    public void Dispose()
    {
        if (mIsInit)
        {
            mIsInit = false;
            mIsShow = false;
            mIsHide = false;
            mData = null;
            Hide();
            OnDispose();
        }
    }
    
#if TOLUA
    protected override void OnDestroy() { Dispose(); base.OnDestroy();  }
#else
    public void Refresh() { }
    public void Help() { }
    private void OnDestroy() { Dispose(); }
    protected virtual void OnBind() { }
    protected virtual void OnInit() { }
    protected virtual void OnShow() { }
    protected virtual void OnHide() { }
    protected virtual void OnDispose() { }
#endif
}
