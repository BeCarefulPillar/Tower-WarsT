using System;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

public class UIWrapGrid : MonoBehaviour, IDisposable
{
    /// <summary>
    /// 对齐方式
    /// </summary>
    public enum Align
    {
        /// <summary>
        /// 不对齐
        /// </summary>
        None,
        /// <summary>
        /// 对齐到首部
        /// </summary>
        Head,
        /// <summary>
        /// 对齐到中间
        /// </summary>
        Center,
        /// <summary>
        /// 对齐到尾部
        /// </summary>
        Tail
    }

    /// <summary>
    /// 指定所属的UIPanel
    /// </summary>
    [SerializeField] private UIPanel mPanel;
    /// <summary>
    /// 序列化保存的事件持有对象
    /// </summary>
    [SerializeField] private Object mHolderObject;
    /// <summary>
    /// Item预制件
    /// </summary>
    [SerializeField] private GameObject mItemPrefab;

    /// <summary>
    /// Item缓存大小
    /// </summary>
    [SerializeField] private int mItemCacheSize = 8;
    /// <summary>
    /// 请求数据超时时间
    /// </summary>
    [SerializeField] public float requestTimeOut = 10f;
    /// <summary>
    /// 是否水平
    /// </summary>
    [SerializeField] private bool mCullItem = false;
    /// <summary>
    /// 平滑动画处理
    /// </summary>
    [SerializeField] public bool animateSmoothly = false;

    /// <summary>
    /// 是否水平
    /// </summary>
    [SerializeField] private bool mIsHorizontal = false;
    /// <summary>
    /// 格子宽
    /// </summary>
    [SerializeField] private float mGridWidth = 200f;
    /// <summary>
    /// 格子高
    /// </summary>
    [SerializeField] private float mGridHeight = 200f;
    /// <summary>
    /// 每行格子数
    /// </summary>
    [SerializeField] private int mGridCountPerLine = 0;
    /// <summary>
    /// 是否对齐起始位置
    /// </summary>
    [SerializeField] private Align mOrginAlign = Align.None;
    /// <summary>
    /// 起始位置偏移
    /// </summary>
    [SerializeField] private Vector3 mOrginOffset = Vector3.zero;

    /// <summary>
    /// 是否对齐Item
    /// </summary>
    [SerializeField] private bool mAlignItem = false;
    /// <summary>
    /// 对齐偏移
    /// </summary>
    [SerializeField] private float mAlignOffset = 0f;
    /// <summary>
    /// 添加Item等待时间
    /// </summary>
    [SerializeField] public float addItemWaitTime = 0f;

#if TOLUA
    /// <summary>
    /// Lua容器
    /// </summary>
    [SerializeField] private LuaContainer mLuaContainer;
    /// <summary>
    /// 是否传送自身
    /// </summary>
    [SerializeField] public bool transferSelf = false;
    /// <summary>
    /// Item初始化Function
    /// </summary>
    [SerializeField] public string onItemInit = "OnWrapGridInitItem";
    /// <summary>
    /// Item对齐Function
    /// </summary>
    [SerializeField] public string onItemAlign = "OnWrapGridAlignItem";
    /// <summary>
    /// 请求新的数据Function
    /// </summary>
    [SerializeField] public string onRequestCount = "OnWrapGridRequestCount";
#endif

    /// <summary>
    /// 当前Transform
    /// </summary>
    [NonSerialized] private Transform mTrans;
    /// <summary>
    /// 当前GameObject
    /// </summary>
    [NonSerialized] private GameObject mGo;
    /// <summary>
    /// Item对象
    /// </summary>
    [NonSerialized] private GameObject[] mItems;
    /// <summary>
    /// UIScrollView缓存
    /// </summary>
    [NonSerialized] private UIScrollView mScrollView;
    /// <summary>
    /// 起始位置
    /// </summary>
    [NonSerialized] private Vector3 mOrgin = Vector3.zero;

    /// <summary>
    /// Item数量
    /// </summary>
    [NonSerialized] private int mItemCount;
    /// <summary>
    /// 实际数量
    /// </summary>
    [NonSerialized] private int mRealCount = 0;
    /// <summary>
    /// 需要重置
    /// </summary>
    [NonSerialized] private float mWaitTime = 0f;
    /// <summary>
    /// 需要重置
    /// </summary>
    [NonSerialized] private bool mNeedReset = true;
    /// <summary>
    /// 需要约束
    /// </summary>
    [NonSerialized] private bool mNeedConstraint = false;
    /// <summary>
    /// 当前索引
    /// </summary>
    [NonSerialized] private int mIndex;
    /// <summary>
    /// 当前目标索引
    /// </summary>
    [NonSerialized] private int mIndexTarget;
    /// <summary>
    /// 当前对齐的Item索引
    /// </summary>
    [NonSerialized] private int mAlignItemIndex;
    /// <summary>
    /// 转换矩阵
    /// </summary>
    [NonSerialized] private Matrix4x4 mPanelToLocal;
    /// <summary>
    /// 缓存的初始化队列
    /// </summary>
    [NonSerialized] private int[] mInitItem;
    /// <summary>
    /// 缓存的初始化队列索引
    /// </summary>
    [NonSerialized] private int mInitItemStart;
    /// <summary>
    /// 缓存的初始化队列大小
    /// </summary>
    [NonSerialized] private int mInitItemEnd;

    /// <summary>
    /// 运行时的事件持有对象
    /// </summary>
    [NonSerialized] private IWrapGridHolder mHolder;
    /// <summary>
    /// 事件持有者传递的数据
    /// </summary>
    [NonSerialized] public object holderData;

    /// <summary>
    /// Item预制件
    /// </summary>
    public GameObject itemPrefab
    {
        get
        {
            return mItemPrefab;
        }
        set
        {
            if (mItemPrefab == value) return;
            mItemPrefab = value;
            if (mTrans == null) mTrans = transform;
            DestroyAllChild();
            if (mItems != null) Array.Clear(mItems, 0, mItems.Length);
            mNeedReset = true;
        }
    }
    /// <summary>
    /// 设置的Item缓存数量
    /// </summary>
    public int itemCacheSize { get { return mItemCacheSize; } set { if (mItemCacheSize == value) return; mItemCacheSize = value; mNeedReset = true; } }
    /// <summary>
    /// 隐藏不在显示区域外的对象
    /// </summary>
    public bool cullItem { get { return mCullItem; } set { if (mCullItem == value) return; mCullItem = value; Wrap(); } }
    /// <summary>
    /// 初始点对齐方式
    /// </summary>
    public Align orginAlign { get { return mOrginAlign; } set { if (mOrginAlign == value) return; mOrginAlign = value; ResetOrgin(); RePositonAllItem(); } }
    /// <summary>
    /// 初始点对齐偏移
    /// </summary>
    public Vector3 orginOffset { get { return mOrginOffset; } set { if (mOrginOffset == value) return; mOrginOffset = value; ResetOrgin(); RePositonAllItem(); } }
    /// <summary>
    /// 是否水平滑动
    /// </summary>
    public bool isHorizontal { get { return mIsHorizontal; } set { if (mIsHorizontal == value) return; mIsHorizontal = value; RePositonAllItem(); } }
    /// <summary>
    /// 网格宽
    /// </summary>
    public float gridWidth { get { return mGridWidth; } set { if (mGridWidth == value) return; mGridWidth = value; RePositonAllItem(); } }
    /// <summary>
    /// 网格高
    /// </summary>
    public float gridHeight { get { return mGridHeight; } set { if (mGridHeight == value) return; mGridHeight = value; RePositonAllItem(); } }
    /// <summary>
    /// 网格每行数量
    /// </summary>
    public int gridCountPerLine { get { return mGridCountPerLine; } set { if (mGridCountPerLine == value) return; mGridCountPerLine = value; RePositonAllItem(); } }
    /// <summary>
    /// Item对齐方式
    /// </summary>
    public bool alignItem { get { return mAlignItem; } set { if (mAlignItem == value) return; mAlignItem = value; if (value) CheckAlignIndex(); } }
    /// <summary>
    /// Item对齐的偏移量
    /// </summary>
    public float alignOffset { get { return mAlignOffset; } set { if (mAlignOffset == value) return; mAlignOffset = value; } }
    /// <summary>
    /// 当前对齐的索引
    /// </summary>
    public int alignItemIndex { get { if (!mAlignItem || mAlignItemIndex < 0) CheckAlignIndex(); return mAlignItemIndex; } }

    /// <summary>
    /// 事件持有对象
    /// </summary>
    public IWrapGridHolder holder { get { return mHolder; } set { if (mHolder == value) return; mHolder = value; mNeedReset = true; } }

    /// <summary>
    /// 需要重置
    /// </summary>
    public bool needReset { get { return mNeedReset; } set { mNeedReset = value; } }

    /// <summary>
    /// 当前Item实际缓存数量
    /// </summary>
    public int itemCount { get { return mItemCount; } }
    /// <summary>
    /// 显示Item的终止数(view = [Math.Max(0, viewEnd - itemCount), viewEnd))
    /// </summary>
    public int viewEnd { get { return mIndex; } }
    /// <summary>
    /// 实际数据数量
    /// </summary>
    public int realCount { get { return mRealCount; } set { if (mRealCount == value) return; mWaitTime = 0f; if (mRealCount > value) Remove(value, mRealCount - value); else mRealCount = value; Wrap(); } }

#if TOLUA
    /// <summary>
    /// Lua容器
    /// </summary>
    public LuaContainer luaContainer { get { return mLuaContainer; } set { if (mLuaContainer == value) return; mLuaContainer = value; mNeedReset = true; } }
#endif

    private void Awake()
    {
        mGo = gameObject;
        mTrans = transform;

        if (mHolderObject is IWrapGridHolder)
        {
            mHolder = mHolderObject as IWrapGridHolder;
        }
    }

    private void Start()
    {
        if (!mNeedReset) return;
#if TOLUA
        if (mItemPrefab ? (mHolder != null && mHolder.isAlive) || mLuaContainer != null : mTrans.childCount > 0)
#else
        if (mItemPrefab ? mHolder != null && mHolder.isAlive : mTrans.childCount > 0)
#endif
        {
            Reset();
        }
    }

    private void Update()
    {
        if (mNeedReset) Reset();

        if (mWaitTime > Time.realtimeSinceStartup || mItemCount <= 0) return;

        lbl_upd:

        int index = -1;

        if (mInitItemStart < mInitItemEnd)
        {
            index = mInitItem[mInitItemStart++ % mInitItem.Length];
            if (index < 0 || index >= mIndex || index >= mRealCount || index < mIndex - mItemCount) goto lbl_upd;
        }
        else if (mIndex == mIndexTarget)
        {
            if (mNeedConstraint)
            {
                mNeedConstraint = false;
                if (mScrollView)
                {
                    mScrollView.restrictWithinPanel = true;
                    mScrollView.InvalidateBounds();
                    mScrollView.RestrictWithinBounds(false);
                }
            }
            return;
        }
        else if (mIndex < mIndexTarget)
        {
            if (mIndex < mRealCount)
            {
                if (mIndexTarget - mIndex > mItemCount)
                {
                    // 超出太多，跳过
                    mIndex = Mathf.Min(mIndexTarget - mItemCount, mRealCount - 1);
                }
                index = mIndex;
            }
#if TOLUA
            else if ((mHolder != null && mHolder.isAlive && mHolder.OnWrapGridRequestCount(this)) || LuaRequestCount())
#else
            else if (mHolder != null && mHolder.isAlive && mHolder.OnWrapGridRequestCount(this))
#endif
            {
                // 有新数据
                if (mIndex < mRealCount)
                {
                    index = mIndex;
                }
                else if (mIndex > mRealCount)
                {
                    // 超限
                    mIndexTarget = mIndex;
                    return;
                }
                else
                {
                    // 等待请求数据
                    mWaitTime = Time.realtimeSinceStartup + requestTimeOut;
                    return;
                }
            }
            else
            {
                // 无新数据
                mIndexTarget = mIndex;
                return;
            }
        }
        else if (mIndex > mIndexTarget)
        {
            if (mIndex - mIndexTarget > mItemCount)
            {
                // 超出太多，跳过
                mIndex = Mathf.Max(mIndexTarget + mItemCount, mItemCount + 1);
            }
            index = mIndex - mItemCount - 1;
            if (index < 0)
            {
                if (mIndex > mRealCount)
                {
                    mIndex = mRealCount;
                }
                mIndexTarget = mIndex;
                return;
            }
        }

        if (index < 0)
        {
            mIndexTarget = mIndex;
            return;
        }

        int itemIdx = index % mItemCount;
        GameObject item = mItems[itemIdx];
        if (!item)
        {
            item = mItems[itemIdx] = mGo.AddChild(mItemPrefab, mItemPrefab.name + "_" + itemIdx, false);
            if (!item)
            {
                // 实例化异常
                mIndexTarget = mIndex;
                mWaitTime = Time.realtimeSinceStartup + 1f;
                Debug.LogWarning("UIWrapGrid[" + this.name + "] instance itemPrefab[" + (mItemPrefab ? mItemPrefab.name : "null") + "] failed!!!");
                return;
            }
        }

        if (item)
        {
#if TOLUA
            if ((mHolder != null && mHolder.isAlive && !mHolder.OnWrapGridInitItem(this, item, index)) || !LuaInitItem(item, index))
#else
            if (mHolder != null && mHolder.isAlive && !mHolder.OnWrapGridInitItem(this, item, index))
#endif
            {
                // 初始化失败
                item.SetActive(false);
                mIndexTarget = mIndex;
                mWaitTime = Time.realtimeSinceStartup + (addItemWaitTime > 0f ? addItemWaitTime : 0.2f);
                return;
            }
            if (index == mIndex)
            {
                mIndex++;
            }
            else if (index == mIndex - mItemCount - 1)
            {
                mIndex--;
            }
            //else
            //{
            //    // 异常数据
            //    mIndexTarget = mIndex;
            //    return;
            //}

            Vector3 pos = GetItemPosition(index);
            UIWrapItemTween.Position(item, pos);
            UIWrapItemTween.Active(item, !mCullItem || IsVisible(pos), animateSmoothly);

            mNeedConstraint = true;

            if (mScrollView && mScrollView.restrictWithinPanel)
            {
                mScrollView.restrictWithinPanel = false;
                //mScrollView.DisableSpring();
            }
        }

        mWaitTime = addItemWaitTime > 0f ? Time.realtimeSinceStartup + addItemWaitTime : 0f;
    }
    /// <summary>
    /// 检测Item与UIPanel的显示关系
    /// </summary>
    private void Wrap()
    {
        if (!mPanel || mItemCount <= 0 || mNeedReset || mIndex != mIndexTarget) return;

        Vector3 min, max;

        if (mPanel.clipping != UIDrawCall.Clipping.None)
        {
            Vector4 clip = mPanel.baseClipRegion;
            Vector2 offset = mPanel.clipOffset;

            max = new Vector3(clip.x + offset.x + clip.z * 0.5f, clip.y + offset.y + clip.w * 0.5f, 0f);
            min = new Vector3(max.x - clip.z, max.y - clip.w, 0f);

            if (mTrans != mPanel.cachedTransform)
            {
                mPanelToLocal = mTrans.worldToLocalMatrix * mPanel.cachedTransform.localToWorldMatrix;

                max = mPanelToLocal.MultiplyPoint3x4(max);
                min = mPanelToLocal.MultiplyPoint3x4(min);
            }
        }
        else
        {
            Vector3[] corner = mPanel.worldCorners;
            Matrix4x4 wtl = mTrans == mPanel.cachedTransform ? mPanel.worldToLocal : mTrans.worldToLocalMatrix;
            min = wtl.MultiplyPoint3x4(corner[0]);
            max = wtl.MultiplyPoint3x4(corner[2]);
        }

        Vector3 grid = new Vector3(Mathf.Abs(mGridWidth), Mathf.Abs(mGridHeight), 0f);
        max += grid;
        min -= grid;

        int dim = mGridCountPerLine > 1 ? mGridCountPerLine : 1;

        if (mIndex > mRealCount)
        {
            mIndexTarget = mRealCount;
        }
        else if (mIsHorizontal)
        {
            int minCount = Mathf.Approximately(grid.x, 0f) ? int.MaxValue : Mathf.FloorToInt(((max.x - min.x) / grid.x)) * dim;
            if (mItemCount < minCount)
            {
                mIndexTarget = mItemCount;
            }
            else if (mIndex < minCount)
            {
                mIndexTarget = minCount;
            }
            else
            {
                float pos = mOrgin.x + mGridWidth * (mIndex / dim);

                if (mGridWidth > 0)
                {
                    if (pos < max.x)
                    {
                        mIndexTarget = mIndex + dim * Mathf.CeilToInt((max.x - pos) / mGridWidth);
                    }
                    else if (mIndex > mItemCount)
                    {
                        pos = mOrgin.x + mGridWidth * ((mIndex - mItemCount - 1) / dim);
                        if (pos > min.y)
                        {
                            mIndexTarget = mIndex - dim * Mathf.CeilToInt((pos - min.x) / mGridWidth);
                        }
                    }
                }
                else if (pos > min.x)
                {
                    mIndexTarget = mIndex + dim * Mathf.CeilToInt((min.x - pos) / mGridWidth);
                }
                else if (mIndex > mItemCount)
                {
                    pos = mOrgin.x + mGridWidth * ((mIndex - mItemCount - 1) / dim);
                    if (pos < max.y)
                    {
                        mIndexTarget = mIndex - dim * Mathf.CeilToInt((pos - max.x) / mGridWidth);
                    }
                }
            }
        }
        else
        {
            int minCount = Mathf.Approximately(grid.y, 0f) ? int.MaxValue : Mathf.FloorToInt(((max.y - min.y) / grid.y)) * dim;
            if (mItemCount < minCount)
            {
                mIndexTarget = mItemCount;
            }
            else if (mIndex < minCount)
            {
                mIndexTarget = minCount;
            }
            else
            {
                float pos = mOrgin.y - mGridHeight * (mIndex / dim);

                if (mGridHeight > 0)
                {
                    if (pos > min.y)
                    {
                        mIndexTarget = mIndex + dim * Mathf.CeilToInt((pos - min.y) / mGridHeight);
                    }
                    else if (mIndex > mItemCount)
                    {
                        pos = mOrgin.y - mGridHeight * ((mIndex - mItemCount - 1) / dim);
                        if (pos < max.y)
                        {
                            mIndexTarget = mIndex - dim * Mathf.CeilToInt((max.y - pos) / mGridHeight);
                        }
                    }
                }
                else if (pos < max.y)
                {
                    mIndexTarget = mIndex + dim * Mathf.CeilToInt((pos - max.y) / mGridHeight);
                }
                else if (mIndex > mItemCount)
                {
                    pos = mOrgin.y - mGridHeight * ((mIndex - mItemCount - 1) / dim);
                    if (pos > min.y)
                    {
                        mIndexTarget = mIndex - dim * Mathf.CeilToInt((min.y - pos) / mGridHeight);
                    }
                }
            }
        }

        if (mCullItem)
        {
            Vector3 pos;
            int itemIdx;
            for (int i = mIndex > mItemCount ? mIndex - mItemCount : 0; i < mIndex; i++)
            {
                itemIdx = i % mItemCount;
                if (mItems[itemIdx])
                {
                    pos = GetItemPosition(i);
                    UIWrapItemTween.Active(mItems[itemIdx], i < mRealCount && pos.x >= min.x && pos.x <= max.x && pos.y >= min.y && pos.y <= max.y);
                }
            }
        }
    }

    /// <summary>
    /// 获取指定索引的Item位置
    /// </summary>
    private Vector3 GetItemPosition(int index)
    {
        if (mIsHorizontal)
        {
            if (mGridCountPerLine > 1)
            {
                return mOrgin + new Vector3(mGridWidth * (index / mGridCountPerLine), -(index % mGridCountPerLine) * mGridHeight, 0f);
            }
            else
            {
                return mOrgin + new Vector3(index * mGridWidth, 0f, 0f);
            }
        }
        else if (mGridCountPerLine > 1)
        {
            return mOrgin + new Vector3((index % mGridCountPerLine) * mGridWidth, -mGridHeight * (index / mGridCountPerLine), 0f);
        }
        else
        {
            return mOrgin + new Vector3(0f, -index * mGridHeight, 0f);
        }
    }
    /// <summary>
    /// 指定位置是否可见
    /// </summary>
    private bool IsVisible(Vector3 pos)
    {
        if (mPanel)
        {
            Vector3 min, max;
            if (mPanel.clipping != UIDrawCall.Clipping.None)
            {
                Vector4 clip = mPanel.baseClipRegion;
                Vector2 offset = mPanel.clipOffset;

                max = new Vector3(clip.x + offset.x + clip.z * 0.5f, clip.y + offset.y + clip.w * 0.5f, 0f);
                min = new Vector3(max.x - clip.z, max.y - clip.w, 0f);

                if (mTrans != mPanel.cachedTransform)
                {
                    max = mPanelToLocal.MultiplyPoint3x4(max);
                    min = mPanelToLocal.MultiplyPoint3x4(min);
                }
            }
            else
            {
                Vector3[] corner = mPanel.worldCorners;
                Matrix4x4 wtl = mTrans == mPanel.cachedTransform ? mPanel.worldToLocal : mTrans.worldToLocalMatrix;
                min = wtl.MultiplyPoint3x4(corner[0]);
                max = wtl.MultiplyPoint3x4(corner[2]);
            }

            Vector3 grid = new Vector3(Mathf.Abs(mGridWidth), Mathf.Abs(mGridHeight), 0f);
            max += grid;
            min -= grid;

            if (pos.x < min.x || pos.x > max.x || pos.y < min.y || pos.y > max.y)
            {
                return false;
            }
        }
        return true;
    }

    [ContextMenu("ResetGrid")]
    /// <summary>
    /// 重置
    /// </summary>
    public void Reset()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying) return;
#endif
        mNeedReset = false;
        mNeedConstraint = false;
        mWaitTime = 0f;

        if (mTrans == null) mTrans = transform;
        if (mGo == null) mGo = gameObject;

        if (!mPanel)
        {
            mPanel = GetComponent<UIPanel>();
            if (mPanel == null) mPanel = mGo.GetComponentInParent<UIPanel>();
        }
        if (mPanel)
        {
            mPanel.onClipMove += OnMove;
            mPanelToLocal = mTrans.worldToLocalMatrix * mPanel.cachedTransform.localToWorldMatrix;
            // 重置UIPanel
            mPanel.cachedTransform.localPosition += (Vector3)mPanel.clipOffset;
            mPanel.clipOffset = Vector3.zero;

            mScrollView = mPanel.GetComponent<UIScrollView>();
            if (mScrollView)
            {
                mScrollView.DisableSpring();
                mScrollView.currentMomentum = Vector3.zero;
                mScrollView.onDragFinished += OnAlignItem;
                mScrollView.restrictWithinPanel = false;
                mNeedConstraint = true;
                mScrollView.UpdateScrollbars(false);
            }
        }
        else
        {
            mScrollView = null;
        }

        // 初始化索引
        mIndex = 0;
        mIndexTarget = 0;
        mAlignItemIndex = -1;
        // 初始化Item数量
        mItemCount = mItemPrefab ? mItemCacheSize : mTrans.childCount;
        // 真实数量
#if TOLUA
        mRealCount = (mHolder != null && mHolder.isAlive) || mLuaContainer != null ? 0 : mItemCount;
#else
        mRealCount = mHolder != null && mHolder.isAlive ? 0 : mItemCount;
#endif
        // 缓存计算
        int cacheSize = mItemCount > mItemCacheSize ? mItemCount : mItemCacheSize;
        cacheSize = cacheSize > 16 ? Mathf.NextPowerOfTwo(cacheSize) : 16;
        // 清空需求缓存
        mInitItemStart = 0;
        mInitItemEnd = 0;
        if (mInitItem == null) mInitItem = new int[cacheSize];
        // 初始化Item缓存
        if (mItems == null)
        {
            mItems = new GameObject[cacheSize];
        }
        else if (mItems.Length < cacheSize)
        {
            Array.Resize(ref mItems, cacheSize);
        }
        else
        {
            // 当实际缓存大于2倍设置缓存时，缩进
            cacheSize *= 2;
            if (mItems.Length > cacheSize)
            {
                for (int i = cacheSize; i < mItems.Length; i++)
                {
#if UNITY_EDITOR
                    Object.DestroyImmediate(mItems[i]);
#else
                    Object.Destroy(mItems[i]);
#endif
                }
                Array.Resize(ref mItems, cacheSize);
            }
        }

        // 非预制件模式初始
        if (mItemCount > 0 && !mItemPrefab)
        {
            for (int i = 0; i < mItemCount; ++i)
            {
                mItems[i] = mTrans.GetChild(i).gameObject;
            }
        }

        // 初始免激活Iitem
        for (int i = 0; i < mItemCount; i++)
        {
            if (mItems[i])
            {
                mItems[i].SetActive(false);
            }
        }

        // 重置初始位置
        ResetOrgin();

        Wrap();
    }

    /// <summary>
    /// 重置初始位置
    /// </summary>
    private void ResetOrgin()
    {
        if (mPanel)
        {
            if (mOrginAlign == Align.None)
            {
                mOrgin = mOrginOffset;
            }
            else
            {
                Vector3 min, max;
                if (mPanel.clipping != UIDrawCall.Clipping.None)
                {
                    Vector4 clip = mPanel.baseClipRegion;
                    //Vector2 offset = mPanel.clipOffset;

                    //max = new Vector3(clip.x + offset.x + clip.z * 0.5f, clip.y + offset.y + clip.w * 0.5f, 0f);
                    max = new Vector3(clip.x + clip.z * 0.5f, clip.y + clip.w * 0.5f, 0f);
                    min = new Vector3(max.x - clip.z, max.y - clip.w, 0f);

                    if (mTrans != mPanel.cachedTransform)
                    {
                        max = mPanelToLocal.MultiplyPoint3x4(max);
                        min = mPanelToLocal.MultiplyPoint3x4(min);
                    }
                }
                else
                {
                    if (mPanel.anchorCamera)
                    {
                        Vector3[] corner = mPanel.worldCorners;
                        min = corner[0];
                        max = corner[2];
                    }
                    else
                    {
                        Vector2 size = NGUITools.screenSize;
                        max = new Vector3(size.x * 0.5f, size.y * 0.5f, 0f);
                        min = -max;
                    }

                    Matrix4x4 wtl = mTrans == mPanel.cachedTransform ? mPanel.worldToLocal : mTrans.worldToLocalMatrix;
                    min = wtl.MultiplyPoint3x4(min);
                    max = wtl.MultiplyPoint3x4(max);
                }

                if (mIsHorizontal)
                {
                    mOrgin.x = (mGridWidth < 0f ? max.x : min.x) + mGridWidth * 0.5f;
                    if (mOrginAlign == Align.Head)
                    {
                        mOrgin.y = max.y - (mGridCountPerLine > 1 && mGridHeight < 0 ? mGridCountPerLine - 0.5f : 0.5f) * Mathf.Abs(mGridHeight);
                    }
                    else if (mOrginAlign == Align.Tail)
                    {
                        mOrgin.y = min.y + (mGridCountPerLine > 1 && mGridHeight > 0 ? mGridCountPerLine - 0.5f : 0.5f) * Mathf.Abs(mGridHeight);
                    }
                    else
                    {
                        mOrgin.y = (min.y + max.y + (mGridCountPerLine > 1 ? mGridHeight * (mGridCountPerLine - 1) : 0)) * 0.5f;
                    }
                }
                else
                {
                    mOrgin.y = (mGridHeight < 0f ? min.y : max.y) - mGridHeight * 0.5f;
                    if (mOrginAlign == Align.Head)
                    {
                        mOrgin.x = min.x + (mGridCountPerLine > 1 && mGridWidth < 0 ? mGridCountPerLine - 0.5f : 0.5f) * Mathf.Abs(mGridWidth);
                    }
                    else if (mOrginAlign == Align.Tail)
                    {
                        mOrgin.x = max.x - (mGridCountPerLine > 1 && mGridWidth > 0 ? mGridCountPerLine - 0.5f : 0.5f) * Mathf.Abs(mGridWidth);
                    }
                    else
                    {
                        mOrgin.x = (min.x + max.x - (mGridCountPerLine > 1 ? mGridWidth * (mGridCountPerLine - 1) : 0)) * 0.5f;
                    }
                }

                mOrgin += mOrginOffset;
            }
        }
        else
        {
            mOrgin = mOrginOffset;
        }
    }

    [ContextMenu("RePositonAllItem")]
    /// <summary>
    /// 归位所有Item
    /// </summary>
    private void RePositonAllItem()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying) return;
#endif
        if (mIndex <= 0) return;

        GameObject item;
        for (int i = mIndex > mItemCount ? mIndex - mItemCount : 0; i < mIndex; i++)
        {
            item = mItems[i % mItemCount];
            if (item)
            {
                UIWrapItemTween.Position(item, GetItemPosition(i), animateSmoothly);
            }
        }

        mNeedConstraint = true;

        Wrap();
    }

    /// <summary>
    /// 计算当前对齐的索引
    /// </summary>
    private void CheckAlignIndex()
    {
        if (mRealCount < 1) return;

        Vector3 center;

        if (mPanel.clipping != UIDrawCall.Clipping.None)
        {
            Vector4 clip = mPanel.baseClipRegion;
            Vector3 offset = mPanel.clipOffset;

            Vector3 max = new Vector3(clip.x + offset.x + clip.z * 0.5f, clip.y + offset.y + clip.w * 0.5f, 0f);
            Vector3 min = new Vector3(max.x - clip.z, max.y - clip.w, 0f);

            center = (min + max) * 0.5f;
        }
        else
        {
            Vector3[] corner = mPanel.worldCorners;

            center = (mTrans == mPanel.cachedTransform ? mPanel.worldToLocal : mTrans.worldToLocalMatrix).MultiplyPoint3x4((corner[0] + corner[2]) * 0.5f);
        }

        // 网格间距
        float grid = mIsHorizontal ? mGridWidth : -mGridHeight;
        // 每行数
        int dim = mGridCountPerLine > 1 ? mGridCountPerLine : 1;

        // 中心索引
        int index = 0;
        if (mIsHorizontal)
        {
            index = Mathf.RoundToInt((center.x - mOrgin.x) / grid) * dim;
        }
        else
        {
            index = Mathf.RoundToInt((center.y - mOrgin.y) / grid) * dim;
        }
        index = Mathf.Clamp(index, 0, mRealCount - 1);

        if (mAlignItemIndex == index) return;
        mAlignItemIndex = index;

        if (!mAlignItem) return;

        if (mHolder != null && mHolder.isAlive)
        {
            mHolder.OnWrapGridAlignItem(this, mAlignItemIndex);
        }
#if TOLUA
        LuaAlignItem(mAlignItemIndex);
#endif
    }
    /// <summary>
    /// 对齐到指定Item
    /// </summary>
    /// <param name="index">Item索引(小于0表示对齐到最近的)</param>
    public void AlignItem(int index = -1)
    {
        if (mAlignItem || index >= 0)
        {
            Vector3 min, max, center, offset, size;

            Transform pTrans = mPanel.cachedTransform;
            Matrix4x4 pltw = pTrans.localToWorldMatrix;
            Matrix4x4 pwtl = pTrans.worldToLocalMatrix;

            if (mPanel.clipping != UIDrawCall.Clipping.None)
            {
                Vector4 clip = mPanel.baseClipRegion;
                offset = mPanel.clipOffset;

                max = new Vector3(clip.x + offset.x + clip.z * 0.5f, clip.y + offset.y + clip.w * 0.5f, 0f);
                min = new Vector3(max.x - clip.z, max.y - clip.w, 0f);

                // 获取中心
                center = pltw.MultiplyPoint3x4((min + max) * 0.5f);

                size = max - min;
            }
            else
            {
                Vector3[] corner = mPanel.worldCorners;
                min = corner[0];
                max = corner[2];

                // 获取中心
                center = (min + max) * 0.5f;

                size = pwtl.MultiplyPoint3x4((max - min));
            }

            // 网格间距
            float grid = mIsHorizontal ? mGridWidth : -mGridHeight;
            // 每行数
            int dim = mGridCountPerLine > 1 ? mGridCountPerLine : 1;
            // 目标位置
            float disPos = 0f;
            // 扩展数量
            int target = 0;

            // 计算最近的Item
            if (index < 0 || index >= mRealCount)
            {
                Vector3 ofCenter = center;
                // 中心动量偏移
                if (mScrollView && mScrollView.currentMomentum.magnitude > 0.0001f)
                {
#if UNITY_4_6 || UNITY_4_7
                    ofCenter -= mScrollView.currentMomentum * 6.636619f;
#else
                    ofCenter += (mScrollView.currentMomentum / Mathf.Log(1f - mScrollView.dampenStrength * 0.001f)) * 0.06f;
#endif
                }
                // 转换中心到Local
                Matrix4x4 wtl = mTrans == pTrans ? pwtl : mTrans.worldToLocalMatrix;
                ofCenter = wtl.MultiplyPoint3x4(ofCenter);

                // 中心索引
                if (mIsHorizontal)
                {
                    index = Mathf.RoundToInt((ofCenter.x - mOrgin.x) / grid) * dim;
                }
                else
                {
                    index = Mathf.RoundToInt((ofCenter.y - mOrgin.y) / grid) * dim;
                }

                index = Mathf.Clamp(index, 0, mRealCount - 1);
            }

            // 转换中心到本地坐标
            center = mTrans.worldToLocalMatrix.MultiplyPoint3x4(center);
            // 计算目标偏移
            if (mIsHorizontal)
            {
                disPos = mOrgin.x + grid * (index / dim) - center.x + mAlignOffset;
                offset = new Vector3(disPos, 0f, 0f);
                target = Mathf.CeilToInt(Mathf.Abs(size.x * 0.5f / grid)) * dim;
            }
            else
            {
                disPos = mOrgin.y + grid * (index / dim) - center.y + mAlignOffset;
                offset = new Vector3(0f, disPos, 0f);
                target = Mathf.CeilToInt(Mathf.Abs(size.y * 0.5f / grid)) * dim;
            }

            if (mIndex == 0)
            {
                // 转换到Panel空间
                if (mTrans != pTrans)
                {
                    offset = (pwtl * mTrans.localToWorldMatrix).MultiplyVector(offset);
                }
                // 初始立即到位
                if (mScrollView)
                {
                    mScrollView.MoveRelative(-offset);
                }
                else
                {
                    mTrans.localPosition -= offset;
                    mPanel.clipOffset += (Vector2)offset;
                }
            }
            else
            {
                SpringPanel sp = mPanel.GetComponent<SpringPanel>();
                if (sp && sp.enabled)
                {
                    // 转换到Panel空间
                    if (mTrans != pTrans)
                    {
                        offset = (pwtl * mTrans.localToWorldMatrix).MultiplyVector(offset);
                    }
                    // 定位到目标
                    SpringPanel.Begin(mPanel.cachedGameObject, pTrans.localPosition - offset, 9f);
                }
                else if (mScrollView)
                {
                    float momentumVal = mScrollView.currentMomentum.magnitude;
                    if (momentumVal > 0.0001f)
                    {
                        // 转换到World空间
                        offset = mTrans.localToWorldMatrix.MultiplyVector(offset);
                        // 计算所需动量
#if UNITY_4_6 || UNITY_4_7
                    Vector3 momentum = -offset * 0.1506791f;
#else
                        Vector3 momentum = offset * Mathf.Log(1f - mScrollView.dampenStrength * 0.001f) * 16.6666667f;
#endif
                        // 2倍以上的动量则使用定位
                        if (momentum.magnitude > momentumVal * 2)
                        {
                            offset = pwtl.MultiplyVector(offset);
                            // 定位到目标
                            SpringPanel.Begin(mPanel.cachedGameObject, pTrans.localPosition - offset, 9f);
                        }
                        else
                        {
                            // 重定动量
                            mScrollView.currentMomentum = momentum;
                        }
                    }
                    else
                    {
                        // 转换到Panel空间
                        if (mTrans != pTrans)
                        {
                            offset = (pwtl * mTrans.localToWorldMatrix).MultiplyVector(offset);
                        }
                        // 定位到目标
                        SpringPanel.Begin(mPanel.cachedGameObject, pTrans.localPosition - offset, 9f);
                    }
                }
                else
                {
                    // 转换到Panel空间
                    if (mTrans != pTrans)
                    {
                        offset = (pwtl * mTrans.localToWorldMatrix).MultiplyVector(offset);
                    }
                    // 定位到目标
                    SpringPanel.Begin(mPanel.cachedGameObject, pTrans.localPosition - offset, 9f);
                }
            }

            // 重定位索引
            target += index;
            if (target > mIndex)
            {
                mIndexTarget = target;
            }
            else if (target < mIndex - mItemCount)
            {
                mIndexTarget = target + mItemCount;
            }
        }
        //else
        //{
        //    if (mIndex == mIndexTarget && mScrollView && mScrollView.restrictWithinPanel)
        //    {
        //        mScrollView.InvalidateBounds();
        //        mScrollView.RestrictWithinBounds(false);
        //    }
        //}
    }

    /// <summary>
    /// 添加初始化需求
    /// </summary>
    private void AddInitItem(int index)
    {
        if (index < 0 || index >= mIndex || index >= mRealCount || index < mIndex - mItemCount) return;
        int len = mInitItem.Length;
        for (int i = mInitItemStart; i < mInitItemEnd; i++)
        {
            if (mInitItem[i % len] == index)
            {
                return;
            }
        }
        if (mInitItemEnd - mInitItemStart >= len)
        {
            // 扩容
            int[] newCache = new int[len * 2];

            int head = mInitItemStart % len;
            if (head > 0)
            {
                Array.Copy(mInitItem, head, newCache, 0, len - head);
                Array.Copy(mInitItem, 0, newCache, len - head, head);
            }

            mInitItemStart = 0;
            mInitItemEnd = len;
            mInitItem = newCache;

            len = mInitItem.Length;
        }
        mInitItem[mInitItemEnd++ % len] = index;
    }
    /// <summary>
    /// 移除初始化需求
    /// </summary>
    private void RemoveInitItem(int index)
    {
        if (index < 0) return;
        int len = mInitItem.Length;
        for (int i = mInitItemStart; i < mInitItemEnd; i++)
        {
            if (mInitItem[i % len] == index)
            {
                mInitItem[i % len] = -1;
                return;
            }
        }
    }

    /// <summary>
    /// 销毁所有子级
    /// </summary>
    private void DestroyAllChild()
    {
        for (int i = mTrans.childCount - 1; i >= 0; i--)
        {
            Transform t = mTrans.GetChild(i);
            if (t)
            {
#if UNITY_EDITOR
                Object.DestroyImmediate(mTrans.GetChild(i).gameObject);
#else
                Object.Destroy(mTrans.GetChild(i).gameObject);
#endif
            }
        }
    }

    /// <summary>
    /// 获取某个显示的Item，如果指定索引不在显示中，则返回NULL
    /// </summary>
    public GameObject GetItem(int index)
    {
        if (index < 0 || index >= mIndex || index >= mRealCount || index < mIndex - mItemCount) return null;
        return mItems[index % mItemCount];
    }
#if TOLUA
    [LuaInterface.NoToLua]
#endif
    /// <summary>
    /// 从当前显示的第一个Item开始遍历到显示的最后一个Item
    /// </summary>
    public IEnumerable<KeyValuePair<int, GameObject>> items { get { for (int i = Mathf.Max(0, mIndex - mItemCount); i < mIndex; i++) { yield return new KeyValuePair<int, GameObject>(i, mItems[i % mItemCount]); } } }
    /// <summary>
    /// 初始化某个Item
    /// </summary>
    public void InitItem(int index)
    {
        AddInitItem(index);
    }
    /// <summary>
    /// 初始化所有显示的Item
    /// </summary>
    public void InitAllItem()
    {
        int start = mIndex - mItemCount;
        if (start < 0) start = 0;
        int end = mIndex < mRealCount ? mIndex : mRealCount;
        for (int i = start; i < end; i++)
        {
            AddInitItem(i);
        }
    }
    /// <summary>
    /// 移除指定Item
    /// </summary>
    ///<param name="item">Item</param>
    public bool Remove(GameObject item)
    {
        if (item)
        {
            for (int i = mIndex > mItemCount ? mIndex - mItemCount : 0; i < mIndex; i++)
            {
                if (item == mItems[i % mItemCount])
                {
                    Remove(i, 1);
                    return true;
                }
            }
        }
        return false;
    }
    /// <summary>
    /// 移除指定索引数据
    /// </summary>
    ///<param name="index">真实索引</param>
    public void Remove(int index)
    {
        Remove(index, 1);
    }
    /// <summary>
    /// 移除指定索引数据
    /// </summary>
    ///<param name="index">真实索引</param>
    ///<param name="count">索引开始的数量</param>
    public void Remove(int index, int count)
    {
        if (count <= 0 || mRealCount <= 0 || index >= mRealCount) return;
        if (index < 0) index = 0;
        if (index + count > mRealCount) count = mRealCount - index;
        if (mItemCount > 0 && index < mIndex)
        {
            int itemIdx;
            int end = index + count;
            int srcIdx = Mathf.Max(0, mIndex - mItemCount);

            if (end < mIndex && end < mRealCount)
            {
                mIndexTarget = mIndex - count;
                GameObject item;
                int startIdx = index > srcIdx ? index : srcIdx;

                if (srcIdx < end)
                {
                    int initIdx = mIndexTarget - mItemCount;
                    for (int i = startIdx; i < end; i++)
                    {
                        item = mItems[i % mItemCount];
                        if (item)
                        {
                            UIWrapItemTween.Active(item, false, animateSmoothly);
                        }
                        RemoveInitItem(i);
                        AddInitItem(--initIdx);
                    }
                    if (mWaitTime <= Time.realtimeSinceStartup) mWaitTime = Time.realtimeSinceStartup + 0.2f;
                }

                int delCnt = mIndex - startIdx;
                if (count % delCnt != 0)
                {
                    // 数组局部偏移
                    int itemIdx2;
                    int itemIdxInit = itemIdx = 0;
                    item = mItems[startIdx % mItemCount];
                    for (int i = startIdx + 1; i < mIndex; i++)
                    {
                        itemIdx2 = (itemIdx + count) % delCnt;
                        if (itemIdx2 == itemIdxInit)
                        {
                            mItems[(itemIdx + startIdx) % mItemCount] = item;
                            itemIdxInit = itemIdx = (itemIdx + 1) % delCnt;
                            item = mItems[(itemIdx + startIdx) % mItemCount];
                        }
                        else
                        {
                            mItems[(itemIdx + startIdx) % mItemCount] = mItems[(itemIdx2 + startIdx) % mItemCount];
                            itemIdx = itemIdx2;
                        }
                    }
                    mItems[(itemIdx + startIdx) % mItemCount] = item;
                }
            }
            else
            {
                mIndexTarget = index;
                int initIdx = srcIdx;
                for (int i = index > srcIdx ? index : srcIdx; i < mIndex; i++)
                {
                    itemIdx = i % mItemCount;
                    if (mItems[itemIdx])
                    {
                        UIWrapItemTween.Active(mItems[itemIdx], false, animateSmoothly);
                    }
                    RemoveInitItem(i);
                    AddInitItem(--initIdx);
                }
                if (mWaitTime <= Time.realtimeSinceStartup) mWaitTime = Time.realtimeSinceStartup + 0.2f;
            }

            mIndex = mIndexTarget;

            // 归位对齐
            // AlignItem();
            RePositonAllItem();
        }

        mRealCount -= count;
    }
    /// <summary>
    /// 在指定索引插入
    /// </summary>
    ///<param name="target">目标位置</param>
    public void Insert(Transform target)
    {
        if (target)
        {
            int index;
            int dim = mGridCountPerLine > 1 ? mGridCountPerLine : 1;
            Vector3 pos = mTrans.worldToLocalMatrix.MultiplyPoint3x4(target.position) - mOrgin;
            if (mIsHorizontal)
            {
                index = Mathf.RoundToInt(pos.x / mGridWidth) * dim + Mathf.Clamp(Mathf.Abs(Mathf.RoundToInt(pos.y / mGridHeight)), 0, dim - 1);
            }
            else
            {
                index = Mathf.RoundToInt(pos.y / -mGridHeight) * dim + Mathf.Clamp(Mathf.Abs(Mathf.RoundToInt(pos.x / mGridWidth)), 0, dim - 1);
            }
            Insert(Mathf.Clamp(index, 0, mRealCount), 1);
        }
    }
    /// <summary>
    /// 在指定索引插入
    /// </summary>
    ///<param name="index">真实索引</param>
    public void Insert(int index)
    {
        Insert(index, 1);
    }
    /// <summary>
    /// 在指定索引插入
    /// </summary>
    ///<param name="index">真实索引</param>
    ///<param name="count">索引开始的数量</param>
    public void Insert(int index, int count)
    {
        if (count <= 0 || index < 0 || index > mRealCount) return;
        mRealCount += count;
        if (mItemCount > 0 && index < mIndex)
        {
            int itemIdx;
            GameObject item;
            int end = index + count;
            int srcIdx = Mathf.Max(0, mIndex - mItemCount);
            int startIdx = index > srcIdx ? index : srcIdx;
            int delCnt = mIndex - startIdx;
            int delta = count % delCnt;
            if (delta != 0)
            {
                // 数组局部偏移
                delta = delCnt - delta;
                int itemIdx2;
                int itemIdxInit = itemIdx = 0;
                item = mItems[startIdx % mItemCount];
                for (int i = startIdx + 1; i < mIndex; i++)
                {
                    itemIdx2 = (itemIdx + delta) % delCnt;
                    if (itemIdx2 == itemIdxInit)
                    {
                        mItems[(itemIdx + startIdx) % mItemCount] = item;
                        itemIdxInit = itemIdx = (itemIdx + delCnt - 1) % delCnt;
                        item = mItems[(itemIdx + startIdx) % mItemCount];
                    }
                    else
                    {
                        mItems[(itemIdx + startIdx) % mItemCount] = mItems[(itemIdx2 + startIdx) % mItemCount];
                        itemIdx = itemIdx2;
                    }
                }
                mItems[(itemIdx + startIdx) % mItemCount] = item;
            }

            if (index < srcIdx)
            {
                mIndexTarget = mIndex = mIndex + count;
            }
            else
            {
                mIndexTarget = mIndex;
            }

            // 归位对齐
            //AlignItem();
            RePositonAllItem();

            if (srcIdx < end)
            {
                for (int i = startIdx; i < end; i++)
                {
                    item = mItems[i % mItemCount];
                    if (item)
                    {
                        UIWrapItemTween.Active(item, false);
                    }
                    AddInitItem(i);
                }
            }
        }
    }
    /// <summary>
    /// 释放
    /// </summary>
    public void Dispose()
    {
        mIndex = 0;
        mIndexTarget = 0;
        mAlignItemIndex = -1;
        mRealCount = 0;
        mItemCount = 0;
        mWaitTime = 0f;
        mNeedReset = false;
        mNeedConstraint = false;
        mInitItemStart = 0;
        mInitItemEnd = 0;
        mInitItem = null;
        if (mTrans == null) mTrans = transform;
        if (mPanel) mPanel.onClipMove -= OnMove;
        if (mScrollView) mScrollView.onDragFinished -= OnAlignItem;
        DestroyAllChild();
        mItems = null;
    }
    /// <summary>
    /// UIPanel的Clip变动事件
    /// </summary>
    private void OnMove(UIPanel panel) { Wrap(); if (mAlignItem) CheckAlignIndex(); }
    /// <summary>
    /// 滑动结束时
    /// </summary>
    private void OnAlignItem() { AlignItem(); }

#if TOLUA
    /// <summary>
    /// Lua请求数量
    /// </summary>
    private bool LuaRequestCount()
    {
        if (mLuaContainer == null || string.IsNullOrEmpty(onRequestCount)) return false;
        LuaInterface.LuaFunction luaFunc = mLuaContainer.GetBindFunction(onRequestCount);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mLuaContainer.isInstance) luaFunc.Push(mLuaContainer.luaTable);
        if (transferSelf) luaFunc.Push(this);
        luaFunc.PCall();
        bool ret = luaFunc.CheckBoolean();
        luaFunc.EndPCall();
        return ret;
    }
    /// <summary>
    /// Lua初始化Item
    /// </summary>
    private bool LuaInitItem(GameObject item, int index)
    {
        if (mLuaContainer == null || string.IsNullOrEmpty(onItemInit)) return true;
        LuaInterface.LuaFunction luaFunc = mLuaContainer.GetBindFunction(onItemInit);
        if (luaFunc == null) return false;
        luaFunc.BeginPCall();
        if (mLuaContainer.isInstance) luaFunc.Push(mLuaContainer.luaTable);
        if (transferSelf) luaFunc.Push(this);
        luaFunc.Push(item);
        luaFunc.Push(index);
        luaFunc.PCall();
        bool ret = luaFunc.CheckBoolean();
        luaFunc.EndPCall();
        return ret;
    }
    /// <summary>
    /// Lua初始化Item
    /// </summary>
    private void LuaAlignItem(int index)
    {
        if (mLuaContainer == null || string.IsNullOrEmpty(onItemAlign)) return;
        LuaInterface.LuaFunction luaFunc = mLuaContainer.GetBindFunction(onItemAlign);
        if (luaFunc == null) return;
        luaFunc.BeginPCall();
        if (mLuaContainer.isInstance) luaFunc.Push(mLuaContainer.luaTable);
        if (transferSelf) luaFunc.Push(this);
        luaFunc.Push(index);
        luaFunc.PCall();
        luaFunc.EndPCall();
    }
#endif
}
