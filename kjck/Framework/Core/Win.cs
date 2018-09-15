using System;
using System.Collections;
using UnityEngine;

#if TOLUA
public partial class Win : IWin
#else
public class Win : MonoBehaviour, IWin
#endif
{
    /// <summary>
    /// 窗体状态
    /// </summary>
    public enum Status
    {
        /// <summary>
        /// 初始
        /// </summary>
        Init = 0,
        /// <summary>
        /// 正在进入
        /// </summary>
        Entering = 1,
        /// <summary>
        /// 已进入
        /// </summary>
        Entered = 2,
        /// <summary>
        /// 正在退出
        /// </summary>
        Exting = 3,
        /// <summary>
        /// 已退出
        /// </summary>
        Exited = 4
    }
    /// <summary>
    /// 窗体的尺寸样式
    /// </summary>
    public enum SizeStyle
    {
        // 计算所得
        Calc = 0,
        // 空的
        Empty = 1,
        // 全屏
        FullScreen = 2,
        // 自定义
        Custom = 3,
    }

    /// <summary>
    /// 空体积
    /// </summary>
    public static readonly Bounds EmptyBounds = new Bounds();
    /// <summary>
    /// 最大体积
    /// </summary>
    public static readonly Bounds MaxBounds = new Bounds(Vector3.zero, new Vector3(float.MaxValue, float.MaxValue, float.MaxValue));
    /// <summary>
    /// 初始化异常
    /// </summary>
    public static readonly Exception InitException = new Exception("init failed");

    /// <summary>
    /// 后台是否显示
    /// </summary>
    [SerializeField] private bool mAutoHide = true;
    /// <summary>
    /// 是否是悬浮窗
    /// </summary>
    [SerializeField] private bool mIsFloat = false;
    /// <summary>
    /// 是否是固定的窗口,固定的窗口不被后台退出
    /// </summary>
    [SerializeField] private bool mIsFiexd = false;
    /// <summary>
    /// 是否是背景层
    /// </summary>
    [SerializeField] private bool mIsBackLayer = false;
    /// <summary>
    /// 排序权重
    /// </summary>
    [SerializeField] private int mMutex = 0;
    /// <summary>
    /// 排序权重
    /// </summary>
    [SerializeField] private int mSort = 0;
    /// <summary>
    /// 退出后窗口存活时间
    /// </summary>
    [SerializeField] private float mLifeTime = 10f;
    /// <summary>
    /// 尺寸定义
    /// </summary>
    [SerializeField] private SizeStyle mSizeStyle = SizeStyle.Calc;
    /// <summary>
    /// 自定义的尺寸
    /// </summary>
    [SerializeField] private Bounds mBounds;

    /// <summary>
    /// 窗体名称
    /// </summary>
    [NonSerialized] private string mWinName;
    /// <summary>
    /// 窗体所属的场景
    /// </summary>
    [NonSerialized] private Scene mScene;
    /// <summary>
    /// 窗体当前的状态
    /// </summary>
    [NonSerialized] private Status mStatus = Status.Init;
    /// <summary>
    /// 手动设置激活状态
    /// </summary>
    [NonSerialized] private bool mActive = true;
    /// <summary>
    /// 深度
    /// </summary>
    [NonSerialized] private int mDepth = 0;

    /// <summary>
    /// 初始化对象
    /// </summary>
    [NonSerialized] protected object mInitObj = null;

    /// <summary>
    /// gameObject 缓存
    /// </summary>
    [NonSerialized] private GameObject mGo;
    /// <summary>
    /// transform 缓存
    /// </summary>
    [NonSerialized] private Transform mTrans;
    /// <summary>
    /// 页面加载器
    /// </summary>
    [NonSerialized] private PageLoader mPageLoader;

    /// <summary>
    /// 进入协同
    /// </summary>
    private IEnumerator mEntering;
    /// <summary>
    /// 进入协同
    /// </summary>
    private IEnumerator mOnEnter;
    /// <summary>
    /// 退出协同
    /// </summary>
    private IEnumerator mExiting;
    /// <summary>
    /// 退出协同
    /// </summary>
    private IEnumerator mOnExit;

    /// <summary>
    /// NGUI UIPanel 缓存
    /// </summary>
    [NonSerialized] private UIPanel mPanel;
    /// <summary>
    /// 屏蔽层
    /// </summary>
    [NonSerialized] private UIWidget mask;

    /// <summary>
    /// 窗体名称
    /// </summary>
    public string winName { get { return mWinName; } }
    /// <summary>
    /// 所属场景
    /// </summary>
    public Scene scene { get { return mScene; } }
    /// <summary>
    /// 窗体状态
    /// </summary>
    public Status status { get { return mStatus; } }
    /// <summary>
    /// 是否打开状态
    /// </summary>
    public bool isOpen { get { return mStatus == Status.Entering || mStatus == Status.Entered; } }
    /// <summary>
    /// 自定义激活状态
    /// </summary>
    public bool active { get { return mActive; } set { mActive = value; if (cachedGameObject.activeSelf == value) return; mGo.SetActive(value); } }
    /// <summary>
    /// 当窗体被覆盖时隐藏
    /// </summary>
    public bool autoHide { get { return mAutoHide; } set { if (mAutoHide == value) return; mAutoHide = value; if (mScene) mScene.CheckWinLayer(false); } }
    /// <summary>
    /// 当窗体被覆盖时隐藏
    /// </summary>
    public bool isFloat { get { return mIsFloat; } set { if (mIsFloat == value) return; mIsFloat = value; if (value) UICamera.onPress += OnGlobalPress; else UICamera.onPress -= OnGlobalPress; } }
    /// <summary>
    /// 显示深度
    /// </summary>
    public int depth { get { return mPanel ? mPanel.depth : mDepth; } set { if (mPanel) mPanel.depth = value; mDepth = value; } }
    /// <summary>
    /// 是否处于背景层
    /// </summary>
    public bool isBackLayer { get { return mIsBackLayer; } set { if (mIsBackLayer == value) return; mIsBackLayer = value; if (mScene) mScene.CheckWinLayer(); } }
    /// <summary>
    /// 是否固定，固定的窗口不被后台退出
    /// </summary>
    public bool isFixed { get { return mIsFiexd; } set { if (mIsFiexd == value) return; mIsFiexd = value; } }
    /// <summary>
    /// 互斥编号，0表示不互斥，其它有相同互斥编号的窗体仅能存在最后打开的那个
    /// </summary>
    public int mutex { get { return mMutex; } set { if (mMutex == value) return; mMutex = value; if (mScene) mScene.CheckMutexWin(mMutex); } }
    /// <summary>
    /// 排序权重
    /// </summary>
    public int sort { get { return mSort; } set { if (mSort == value) return; mSort = value; if (mScene) mScene.CheckWinLayer(); } }
    /// <summary>
    /// 尺寸样式
    /// </summary>
    public SizeStyle sizeStyle { get { return mSizeStyle; } set { if (mSizeStyle == value) return; mSizeStyle = value; if (mScene) mScene.CheckWinLayer(false); } }
    /// <summary>
    /// 窗体体积
    /// </summary>
    public Bounds bounds
    {
        get
        {
            if (mIsFloat || mSizeStyle == SizeStyle.Empty) return EmptyBounds;
            if (mSizeStyle == SizeStyle.FullScreen) return MaxBounds;
            if (mSizeStyle == SizeStyle.Custom) return mBounds;
            return NGUIMath.CalculateRelativeWidgetBounds(mScene ? mScene.transform : cachedTransform, cachedTransform, true);
        }
        set
        {
            mBounds = value;
        }
    }
    /// <summary>
    /// 缓存的GameObject
    /// </summary>
    public GameObject cachedGameObject { get { if (mGo == null) mGo = gameObject; return mGo;  } }
    /// <summary>
    /// 缓存的Transform
    /// </summary>
    public Transform cachedTransform { get { if (mTrans == null) mTrans = transform; return mTrans; } }
    /// <summary>
    /// 页面加载器
    /// </summary>
    protected PageLoader pageLoader { get { if (mPageLoader == null) mPageLoader = GetComponent<PageLoader>() ?? cachedGameObject.AddComponent<PageLoader>(); return mPageLoader; } }

    /// <summary>
    /// 绑定场景
    /// </summary>
    /// <param name="scene">场景</param>
    /// <param name="winName">窗体名称</param>
    public void Bind(Scene scene, string winName)
    {
        mWinName = winName;

        mGo = gameObject;
        mGo.name = winName;
        mTrans = mGo.transform;
        mPanel = mGo.GetComponent<UIPanel>();

        if (mScene == scene) return;

        mScene = scene;

        if (mScene == null)
        {
            active = false;
        }
        else
        {
            mGo.layer = scene.gameObject.layer;
            mTrans.parent = scene.transform;
            mTrans.localPosition = Vector3.zero;
            mTrans.localRotation = Quaternion.identity;
            mTrans.localScale = Vector3.one;
        }
    }

    /// <summary>
    /// 用原始初始化对象显示窗口
    /// </summary>
    public void Enter() { Enter(null); }
    /// <summary>
    /// 用给定的初始化对象初始化并显示窗口
    /// </summary>
    public void Enter(object obj)
    {
        CancelInvoke("Destruct");
        StopExitCoroutines();

        if (mStatus == Status.Init || mStatus == Status.Exited || !object.Equals(mInitObj, obj))
        {
            Dispose();
            mStatus = Status.Init;
            initObj = obj;
            try
            {
                OnInit();
                if (mIsFloat)
                {
                    UICamera.onPress += OnGlobalPress;
                }
            }
            catch (Exception e)
            {
                Debug.LogWarning(e);
                return;
            }
        }

        if (mStatus == Status.Entered)
        {
            active = true;
            if (mScene) mScene.focusWin = this;
            return;
        }

        if (mStatus != Status.Entering)
        {
            if (mScene)
            {
                mStatus = Status.Entering;
                mEntering = OnEntering();
                mScene.StartCoroutine(mEntering);
            }
            else
            {
                mStatus = Status.Entered;
                active = true;
            }
        }
        else if (mEntering == null)
        {
            mStatus = Status.Entered;
            active = true;
            if (mScene)
            {
                depth = mScene.topDepth;
                mScene.CheckWinLayer();
                mScene.CheckMutexWin(mMutex);
            }
        }
    }
    /// <summary>
    /// 进入协同
    /// </summary>
    private IEnumerator OnEntering()
    {
        //SetEventMask(false);
        yield return null; yield return null;
        active = true;
        if (mScene)
        {
            depth = mScene.topDepth;
            mScene.CheckWinLayer(true, false);
            mOnEnter = OnEnter();
            yield return mScene.StartCoroutine(mOnEnter);
            mStatus = Status.Entered;
            mEntering = mOnEnter = null;
            mScene.CheckWinLayer();
            mScene.CheckMutexWin(mMutex);
        }
        else
        {
            mStatus = Status.Entered;
            mEntering = mOnEnter = null;
        }
    }
    /// <summary>
    /// 退出窗体
    /// </summary>
    public void Exit()
    {
        StopEnterCoroutines();

        if (mStatus == Status.Exited) return;

        if (mStatus != Status.Exting)
        {
            if (mScene)
            {
                mStatus = Status.Exting;
                mScene.CheckWinLayer();
                mExiting = OnExiting();
                mScene.StartCoroutine(mExiting);
            }
            else
            {
                if (mLifeTime > 0f && !IsInvoking("Destruct")) Invoke("Destruct", mLifeTime);
                active = false;
                Dispose();
            }
        }
        else if (mExiting == null)
        {
            if (mLifeTime > 0f && !IsInvoking("Destruct")) Invoke("Destruct", mLifeTime);
            active = false;
            Dispose();
        }
    }
    /// <summary>
    /// 退出协同
    /// </summary>
    private IEnumerator OnExiting()
    {
        if (mScene)
        {
            mOnExit = OnExit();
            yield return mScene.StartCoroutine(mOnExit);
        }
        mExiting = mOnExit = null;
        if (mLifeTime > 0f && !IsInvoking("Destruct")) Invoke("Destruct", mLifeTime);
        active = false;
        Dispose();
    }
    /// <summary>
    /// 聚焦该窗体
    /// </summary>
    public void Focus() { if (mScene) mScene.focusWin = this; }

#region 内部
    /// <summary>
    /// 释放窗口所用的所用资源
    /// </summary>
    private void Dispose()
    {
        if (mStatus == Status.Exited) return;
        mStatus = Status.Exited;
        initObj = null;
        StopEnterCoroutines();
        StopExitCoroutines();
        UICamera.onPress -= OnGlobalPress;
        if (mPageLoader) mPageLoader.Dispose();
        //if (mScene) mScene.CheckWinLayer();
        OnDispose();
    }
    /// <summary>
    /// 停止进入协同
    /// </summary>
    private void StopEnterCoroutines()
    {
        if (mEntering == null && mOnEnter == null) return;
        if (mEntering != null) mScene.StopCoroutine(mEntering);
        if (mOnEnter != null) mScene.StopCoroutine(mOnEnter);
        mEntering = mOnEnter = null;
        OnStopEnter();
    }
    /// <summary>
    /// 停止退出协同
    /// </summary>
    private void StopExitCoroutines()
    {
        if (mExiting == null && mOnExit == null) return;
        if (mExiting != null) mScene.StopCoroutine(mExiting);
        if (mOnExit != null) mScene.StopCoroutine(mOnExit);
        mExiting = mOnExit = null;
        OnStopExit();
    }
    /// <summary>
    /// 全局点击事件
    /// </summary>
    private void OnGlobalPress(GameObject go, bool pressed)
    {
        if (pressed && this && !NGUITools.IsChild(cachedTransform, go.transform))
        {
            Exit();
        }
    }
    /// <summary>
    /// 销毁自身
    /// </summary>
    protected void Destruct() { Destroy(cachedGameObject); }
    /// <summary>
    /// 当自身被销毁时，移除全局字典的引用
    /// </summary>
#if TOLUA
    protected override void OnDestroy()
#else
    protected void OnDestroy()
#endif
    {
        Dispose();
        if (mScene) mScene.OnWinDestroy(this);
        OnDestroyed();
#if TOLUA
        base.OnDestroy();
#endif
        AssetManager.UnloadUnusedAsset();
    }
#endregion

#region 页面加载部分
    /// <summary>
    /// 页面显示时
    /// </summary>
    public void OnPageShow(Page page)
    {
        if (page == null || page.win != this) return;
        if (page.mutex == 0) return;
        pageLoader.CheckMutex(page);
    }
    /// <summary>
    /// 显示页面
    /// </summary>
    /// <param name="pageName">页面名称</param>
    /// <param name="parent">挂载父级</param>
    /// <param name="data">数据</param>
    public void ShowPage(string pageName, Transform parent = null, object data = null)
    {
        if (string.IsNullOrEmpty(pageName)) return;
        pageLoader.Show(pageName, parent, data);
    }
    /// <summary>
    /// 显示页面
    /// </summary>
    /// <param name="page">页面对象(若是预制件将实例化)</param>
    /// <param name="parent">挂载父级</param>
    /// <param name="data">数据</param>
    public void ShowPage(Page page, Transform parent = null, object data = null)
    {
        if (page == null) return;

        if (page.GetInstanceID() < 0 && page.mutex == 0)
        {
            page.Show(data ?? page.data);
            return;
        }

        pageLoader.Show(page, parent, data);
    }
    /// <summary>
    /// 隐藏页面
    /// </summary>
    /// <param name="pageName">页面名称</param>
    public void HidePage(string pageName)
    {
        if (string.IsNullOrEmpty(pageName)) return;
        pageLoader.Hide(pageName);
    }
    /// <summary>
    /// 隐藏页面
    /// </summary>
    /// <param name="pageName">页面对象</param>
    public void HidePage(Page page)
    {
        if (page == null) return;
        if (page.GetInstanceID() < 0 && page.mutex == 0)
        {
            page.Hide();
            return;
        }
        pageLoader.Hide(page);
    }
    /// <summary>
    /// 所有
    /// </summary>
    public void HidePage()
    {
        if (mPageLoader) mPageLoader.HideAll();
    }
    /// <summary>
    /// 刷新所有页面
    /// </summary>
    public void RefresPage()
    {
        if (mPageLoader) mPageLoader.RefreshAll();
    }
    /// <summary>
    /// 刷新所有页面
    /// </summary>
    public void RefresPage(string pageName)
    {
        if (mPageLoader) mPageLoader.Refresh(pageName);
    }
    /// <summary>
    /// 清除所有页面
    /// </summary>
    public void ClearPage()
    {
        if (mPageLoader) mPageLoader.Dispose();
    }
#endregion

#region 重载的功能事件
#if !TOLUA
    /// <summary>
    /// 初始化对象
    /// </summary>
    public object initObj { get { return mInitObj; } protected set { mInitObj = value; } }
    /// <summary>
    /// 帮助功能
    /// </summary>
    public virtual void Help() { }
    /// <summary>
    /// 立即刷新窗体
    /// </summary>
    public virtual void Refresh() { }
    /// <summary>
    /// 此界面返回
    /// </summary>
    public virtual void Return() { Exit(); }
    /// <summary>
    /// 初始化
    /// </summary>
    protected virtual void OnInit() { }
    /// <summary>
    /// 进入时
    /// </summary>
    protected virtual IEnumerator OnEnter()
    {
        UITweener[] uts = GetComponents<UITweener>();
        UITweener u = null;
        if (uts.GetLength() > 0)
        {
            u = uts[0];
            foreach (UITweener ut in uts) { ut.PlayForward(); if (ut.duration > u.duration) u = ut; }
        }

        ActiveAnimation aa = null;
        Animation animation = GetComponent<Animation>();
        if (animation)
        {
            if(mPanel) mPanel.alpha = 0.01f;
            aa = ActiveAnimation.Play(animation, AnimationOrTween.Direction.Forward);
        }

        if (u) while (u.enabled) yield return null;
        if (aa) while (aa.isPlaying) yield return null;
    }
    /// <summary>
    /// 退出时
    /// </summary>
    protected virtual IEnumerator OnExit()
    {
        UITweener[] uts = GetComponents<UITweener>();
        if (active)
        {
            UITweener u = null;
            if (uts.GetLength() > 0)
            {
                u = uts[0];
                foreach (UITweener ut in uts) { ut.PlayReverse(); if (ut.duration > u.duration) u = ut; }
            }

            ActiveAnimation aa = null;
            Animation animation = GetComponent<Animation>();
            if (animation)
            {
                aa = ActiveAnimation.Play(animation, AnimationOrTween.Direction.Reverse);
            }
            if (u) while (u.enabled) yield return null;
            if (aa) while (aa.isPlaying) yield return null;
        }
        else if (uts.GetLength() > 0)
        {
            foreach (UITweener ut in uts) ut.ResetToInit();
        }
    }
    /// <summary>
    /// 进入被终止
    /// </summary>
    protected virtual void OnStopEnter() { }
    /// <summary>
    /// 退出被终止
    /// </summary>
    protected virtual void OnStopExit() { }
    /// <summary>
    /// 聚焦时
    /// </summary>
    /// <param name="isFocus">是否聚焦</param>
    public virtual void OnFocus(bool isFocus) { }
    /// <summary>
    /// 释放
    /// </summary>
    protected virtual void OnDispose() { }
#endif
    /// <summary>
    /// 销毁时
    /// </summary>
    protected virtual void OnDestroyed() { }
#endregion
}
