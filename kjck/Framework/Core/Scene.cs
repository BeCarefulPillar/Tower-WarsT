using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if TOLUA
public partial class Scene : IScene
#else
public class Scene : MonoBehaviour, IScene
#endif
{
    /// <summary>
    /// 窗体的禁用
    /// </summary>
    public struct BanWin
    {
        /// <summary>
        /// 条件
        /// </summary>
        public System.Func<bool> condition;
        /// <summary>
        /// 提示
        /// </summary>
        public string tip;

        public BanWin(System.Func<bool> cod, string tip) { this.condition = cod; this.tip = tip; }
    }

    /// <summary>
    /// 窗体的起始深度
    /// </summary>
    [SerializeField] private int mDepthStart = 10;
    /// <summary>
    /// 下层窗体的终止深度
    /// </summary>
    [SerializeField] private int mDepthBack = -10;
    /// <summary>
    /// 深度分段
    /// </summary>
    [SerializeField] private int mDepthSpace = 10;
    /// <summary>
    /// 可视化误差
    /// </summary>
    [SerializeField] private float mVisibleTolerance = 64f;
    /// <summary>
    /// 正在加载中
    /// </summary>
    [System.NonSerialized] protected float mLoadingProgress = 0f;

    /// <summary>
    /// 窗体字典
    /// </summary>
    private Dictionary<string, Win> mWins = new Dictionary<string, Win>(8);
    /// <summary>
    /// 窗体列表缓存
    /// </summary>
    private List<Win> mWinList = new List<Win>(8);
    /// <summary>
    /// 被禁用的窗体
    /// </summary>
    private Dictionary<string, BanWin> mBanWins = new Dictionary<string, BanWin>(8);
    /// <summary>
    /// 焦点窗体
    /// </summary>
    [System.NonSerialized] private Win mFocusWin = null;

    /// <summary>
    /// 场景加载进度
    /// </summary>
    public float loadingProgress { get { return mLoadingProgress; } }
    /// <summary>
    /// 窗体的起始深度
    /// </summary>
    public int depthStart { get { return mDepthStart; } set { if (mDepthStart == value) return; mDepthStart = value; CheckWinDpeth(); } }
    /// <summary>
    /// 背景层窗体的终止深度
    /// </summary>
    public int depthBack { get { return mDepthBack; } set { if (mDepthBack == value) return; mDepthBack = value; CheckWinDpeth(); } }
    /// <summary>
    /// 深度分段
    /// </summary>
    public int depthSpace { get { return mDepthSpace; } set { if (mDepthSpace == value) return; mDepthSpace = value; CheckWinDpeth(); } }
    /// <summary>
    /// 可视化检测的误差
    /// </summary>
    public float visibleTolerance { get { return mVisibleTolerance; } set { if (mVisibleTolerance == value) return; mVisibleTolerance = value; CheckWinVisible(); } }
    /// <summary>
    /// 当前的焦点窗体
    /// </summary>
    public Win focusWin { get { return mFocusWin; } set { if (mFocusWin == value || value == null) return; value.depth = topDepth; CheckWinLayer(); } }
    /// <summary>
    /// 顶部的深度
    /// </summary>
    public int topDepth { get { return mFocusWin ? mFocusWin.depth + mDepthSpace : mDepthStart; } }

    #region 组件
#if !TOLUA
    /// <summary>
    /// 初始加载
    /// </summary>
    protected virtual IEnumerator Start()
    {
        mLoadingProgress = 1f;
        yield break;
    }
#endif
    #endregion

    #region 窗体接口
    /// <summary>
    /// 打开以类型名称指定的且挂有指定类型脚本的窗体
    /// </summary>
    /// <typeparam name="T">窗体类型</typeparam>
    public T OpenWin<T>() where T : Win { T win = LoadWin<T>(typeof(T).Name); if (win == null || win.Equals(null)) return default(T); win.Enter(); return win; }
    /// <summary>
    /// 打开以类型名称指定的且挂有指定类型脚本的窗体
    /// </summary>
    /// <typeparam name="T">窗体类型</typeparam>
    /// <param name="param">初始化参数</param>
    public T OpenWin<T>(object param) where T : Win { T win = LoadWin<T>(typeof(T).Name); if (win == null || win.Equals(null)) return default(T); win.Enter(param); return win; }
    /// <summary>
    /// 打开指定名称且挂有指定类型脚本的窗体
    /// </summary>
    /// <param name="winName">窗体名称</param>
    public T OpenWin<T>(string winName) where T : Win { T win = LoadWin<T>(winName); if (win == null || win.Equals(null)) return default(T); win.Enter(); return win; }
    /// <summary>
    /// 打开指定名称且挂有指定类型脚本的窗体
    /// </summary>
    /// <param name="winName">窗体名称</param>
    /// <param name="param">初始化参数</param>
    public T OpenWin<T>(string winName, object param) where T : Win { T win = LoadWin<T>(winName); if (win == null || win.Equals(null)) return default(T); win.Enter(param); return win; }
    /// <summary>
    /// 打开指定名称的窗体
    /// </summary>
    /// <param name="winName">窗体名称</param>
    public Win OpenWin(string winName) { Win win = LoadWin<Win>(winName); if (win == null || win.Equals(null)) return null; win.Enter(); return win; }
    /// <summary>
    /// 打开指定名称的窗体
    /// </summary>
    /// <param name="winName">窗体名称</param>
    /// <param name="param">初始化参数</param>
    public Win OpenWin(string winName, object param) { Win win = LoadWin<Win>(winName); if (win == null || win.Equals(null)) return null; win.Enter(param); return win; }
    /// <summary>
    /// 立即加载一个指定类型的窗体到当前场景，若列表中没有则创建
    /// </summary>
    /// <typeparam name="T">窗体类型</typeparam>
    /// <param name="winName">窗体名称</param>
    /// <returns>返回所创建的窗体，若为Null为创建失败</returns>
    private T LoadWin<T>(string winName) where T : Win
    {
        bool flag = false;

        //阻止禁用窗体打开 并提示
        BanWin ban;
        if (mBanWins.TryGetValue(winName, out ban))
        {
            if (ban.condition != null)
            {
                try
                {
                    flag = ban.condition();
                }
                catch
                {
                    flag = true;
                }
                if (flag)
                {
                    //ToolTip.ShowPopTip(ban.tip);
                    return default(T);
                }
            }
            else
            {
                mBanWins.Remove(winName);
            }
        }

        Win win = null;

        flag = mWins.TryGetValue(winName, out win);

        if (win == null || win.Equals(null))
        {
            if (flag) TrimWins();

            GameObject prefab = AssetManager.Load<GameObject>(winName);

            if (prefab == null)
            {
#if UNITY_EDITOR
                throw new System.Exception("加载指定窗体发送错误，请检查[" + winName + "]窗体是否存在");
#else
                return null;
#endif
            }

            GameObject go = GameObject.Instantiate(prefab) as GameObject;
            win = go.GetComponent<T>();

            if (win == null || win.Equals(null))
            {
#if UNITY_EDITOR
                DestroyImmediate(go);

                throw new System.Exception("未找到指定的窗体脚本，请检查窗体是否添加了" + (typeof(T).IsInterface ? "实现" : "继承") + "[" + typeof(T).Name + "]的脚本");
#else
                Destroy(go);
                return null;
#endif
            }

            mWins[winName] = win;
            if (mWinList.IndexOf(win) < 0) mWinList.Add(win);
            win.active = true;
            win.active = false;
        }

        win.Bind(this, winName);

        return win as T;
    }

    /// <summary>
    /// 从已有窗口列表中获取指定类型的窗口
    /// </summary>
    /// <typeparam name="T">窗口类型</typeparam>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    public T GetWin<T>() where T : Win { return GetWin(typeof(T).Name) as T; }
    /// <summary>
    /// 从已有窗口列表中获取指定类型的窗口
    /// </summary>
    /// <param name="type">窗口类型</param>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    public Win GetWin(System.Type type) { return GetWin(type.Name); }
    /// <summary>
    /// 从已有窗口列表中获取指定类名的窗口
    /// </summary>
    /// <param name="winName">窗口唯一名称</param>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    public Win GetWin(string winName) { Win win = null; mWins.TryGetValue(winName, out win); return win; }

    /// <summary>
    /// 从已有窗口列表中获取指定类型的活动窗口
    /// </summary>
    /// <typeparam name="T">窗口类型</typeparam>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    public T GetActiveWin<T>() where T : Win { return GetActiveWin(typeof(T).Name) as T; }
    /// <summary>
    /// 从已有窗口列表中获取指定类型的活动窗口
    /// </summary>
    /// <param name="type">窗口类型</param>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    public Win GetActiveWin(System.Type type) { return GetActiveWin(type.Name); }
    /// <summary>
    /// 从已有窗口列表中获取指定类名的活动窗口
    /// </summary>
    /// <param name="winName">窗口唯一名称</param>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    public Win GetActiveWin(string winName) { Win win = null; mWins.TryGetValue(winName, out win); return (win && (win.status == Win.Status.Entered || win.status == Win.Status.Entering) && win.cachedGameObject.activeInHierarchy) ? win : null; }
    /// <summary>
    /// 从已有窗口列表中获取指定类名打开的窗口
    /// </summary>
    /// <param name="winName">窗口唯一名称</param>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    public Win GetOpenWin(string winName) { Win win = null; mWins.TryGetValue(winName, out win); return (win && (win.status == Win.Status.Entered || win.status == Win.Status.Entering)) ? win : null; }
    /// <summary>
    /// 获取所有窗口(不排序)
    /// </summary>
    public Win[] GetWins() { CacheWinList(); return mWinList.ToArray(); }
    /// <summary>
    /// 获取所有窗口
    /// </summary>
    public Win[] GetWins(bool sort) { CacheWinList(sort); return mWinList.ToArray(); }
    /// <summary>
    /// 退出所有上层定窗口
    /// </summary>
    public void ExitWin() { ExitWin(false); }
    /// <summary>
    /// 退出所有上层定窗口
    /// </summary>
    public void ExitWin(bool exitFixed)
    {
        if (mWins.Count == 0) return;
        CacheWinList();
        Win win;
        if (exitFixed)
        {
            for (int i = mWinList.Count - 1; i >= 0; i--)
            {
                win = mWinList[i];
                if (win && !win.isBackLayer) win.Exit();
            }
        }
        else
        {
            for (int i = mWinList.Count - 1; i >= 0; i--)
            {
                win = mWinList[i];
                if (win && !win.isFixed && !win.isBackLayer) win.Exit();
            }
        }
    }
    /// <summary>
    /// 退出所有背景层定窗口
    /// </summary>
    public void ExitBackWin() { ExitBackWin(false); }
    /// <summary>
    /// 退出所有背景层定窗口
    /// </summary>
    public void ExitBackWin(bool exitFixed)
    {
        if (mWins.Count == 0) return;
        CacheWinList();
        Win win;
        if (exitFixed)
        {
            for (int i = mWinList.Count - 1; i >= 0; i--)
            {
                win = mWinList[i];
                if (win && win.isBackLayer) win.Exit();
            }
        }
        else
        {
            for (int i = mWinList.Count - 1; i >= 0; i--)
            {
                win = mWinList[i];
                if (win && !win.isFixed && win.isBackLayer) win.Exit();
            }
        }
    }
    /// <summary>
    /// 删除所有互斥窗体
    /// </summary>
    /// <param name="mutex">互斥编号</param>
    public void ExitMutexWin(int mutex)
    {
        if (mutex == 0 || mWins.Count == 0) return;
        foreach (Win win in mWins.Values) if (win && win.mutex == mutex) win.Exit();
    }
    /// <summary>
    /// 退出所有窗体
    /// </summary>
    public void ExitAllWin()
    {
        if (mWins.Count == 0) return;
        CacheWinList();
        Win win;
        for (int i = mWinList.Count - 1; i >= 0; i--)
        {
            win = mWinList[i];
            if (win) win.Exit();
        }
    }
    /// <summary>
    /// 剔除已销毁的窗体
    /// </summary>
    private void TrimWins()
    {
        if (mWins.Count == 0) return;
        List<string> lst = new List<string>(mWins.Count);
        foreach (KeyValuePair<string, Win> item in mWins)
        {
            if (item.Value) continue;
            lst.Add(item.Key);
        }
        if (lst.Count == 0) return;
        foreach (string item in lst) mWins.Remove(item);
        mWinList.Clear();
        mWinList.AddRange(mWins.Values);
    }

    /// <summary>
    /// 校对窗口互斥
    /// </summary>
    /// <param name="mutex">指定的互斥号</param>
    public void CheckMutexWin(int mutex)
    {
        if (mutex == 0) return;
        CacheWinList(true);
        bool flag = false;
        Win w = null;
        for (int i = mWinList.Count - 1; i >= 0; i--)
        {
            w = mWinList[i];
            if (w && w.mutex == mutex)
            {
                if (flag)
                {
                    w.Exit();
                }
                else if (w.status == Win.Status.Entered)
                {
                    flag = true;
                }
            }
        }
    }
    /// <summary>
    /// 校对窗口层级关系
    /// </summary>
    /// <param name="visible">是否检测可见性</param>
    public void CheckWinLayer(bool depth = true, bool visible = true)
    {
        if (depth)
        {
            CheckWinDpeth();
        }
        if (visible)
        {
            CheckWinVisible(!depth);
        }
    }
    /// <summary>
    /// 校对窗体列表
    /// </summary>
    /// <param name="sort">是否排序</param>
    private void CacheWinList(bool sort = false)
    {
        if (mWinList.Count > 0)
        {
            if (mWins.Count == mWinList.Count)
            {
                if (sort) mWinList.Sort(WinSort);
                return;
            }
            mWinList.Clear();
        }
        if (mWins.Count > 0)
        {
            mWinList.AddRange(mWins.Values);
            if (sort) mWinList.Sort(WinSort);
        }
    }
    /// <summary>
    /// 窗体排序
    /// </summary>
    private static int WinSort(Win x, Win y)
    {
        if (!x) return y ? -1 : 0;
        if (!y) return 1;
        if (x.isBackLayer != y.isBackLayer) return x.isBackLayer ? -1 : 1;
        if (x.sort < y.sort) return -1;
        if (x.sort > y.sort) return 1;
        if (x.depth < y.depth) return -1;
        if (x.depth > y.depth) return 1;
        return 0;
    }
    /// <summary>
    /// 检测窗体深度
    /// </summary>
    private void CheckWinDpeth(bool cache = true)
    {
        if (mWinList.Count == 0) return;

        if(cache) CacheWinList(true);

        int depth = mDepthStart;
        int back = mDepthBack - mDepthSpace;
        Win focus = null;

        foreach (Win win in mWinList) if (win && win.isBackLayer) back -= mDepthSpace;
        foreach (Win win in mWinList)
        {
            if (!win) continue;
            if (win.isBackLayer)
            {
                win.depth = back;
                back += mDepthSpace;
            }
            else
            {
                if (win.active && (win.status == Win.Status.Entering || win.status == Win.Status.Entered)) focus = win;
                win.depth = depth;
                depth += mDepthSpace;
            }
        }

        if (focus != mFocusWin)
        {
            Win lastFocus = mFocusWin;
            mFocusWin = focus;
            if (lastFocus) lastFocus.OnFocus(false);
            if (focus && focus == mFocusWin) focus.OnFocus(true);
        }
    }
    /// <summary>
    /// 校检所有窗口的可视特性
    /// </summary>
    private void CheckWinVisible(bool cache = true)
    {
        if (mWinList.Count == 0) return;

        if (cache) CacheWinList(true);

        Bounds mb = new Bounds();
        bool isFull = false;
        Win win;
        for (int i = mWinList.Count - 1; i >= 0; i--)
        {
            win = mWinList[i];
            if (win && win.status == Win.Status.Entered && win.active)
            {
                if (win.autoHide)
                {
                    if (isFull)
                    {
                        win.cachedGameObject.SetActive(false);
                    }
                    else
                    {
                        if (win.sizeStyle == Win.SizeStyle.FullScreen)
                        {
                            isFull = true;
                            win.cachedGameObject.SetActive(true);
                        }
                        else if (win.isFloat || win.sizeStyle == Win.SizeStyle.Empty)
                        {
                            win.cachedGameObject.SetActive(false);
                        }
                        else
                        {
                            Bounds b = win.bounds;
                            win.cachedGameObject.SetActive(!mb.HasVolume() || b.min.x < mb.min.x - mVisibleTolerance || b.min.y < mb.min.y - mVisibleTolerance || b.max.x > mb.max.x + mVisibleTolerance || b.max.y > mb.max.y + mVisibleTolerance);
                            mb.Encapsulate(b);
                        }
                    }
                }
                else
                {
                    win.cachedGameObject.SetActive(true);
                }
            }
        }
    }
    #endregion

    #region 事件接口

    /// <summary>
    /// 有窗体销毁
    /// </summary>
    public void OnWinDestroy(Win win)
    {
        if (!win) return;

        Win target = null;

        if(mWins.TryGetValue(win.winName, out target) && win == target)
        {
            target = win;
        }
        else
        {
            foreach (Win item in mWins.Values)
            {
                if (item != win) continue;
                target = win;
                break;
            }
        }

        if (target == null) return;

        mWins.Remove(target.winName);
        mWinList.Remove(target);
        Destroy(target.cachedGameObject);
    }

    public virtual void OnInitEvent() { }
    #endregion

    #region 辅助函数
    /// <summary>
    /// 延迟调用
    /// </summary>
    public void Invoke(float delay, System.Action callback)
    {
        if (callback != null)
        {
            if (delay > 0f)
            {
                StartCoroutine(OnInvoke(delay, callback));
            }
            else
            {
                callback();
            }
        }
    }
    private IEnumerator OnInvoke(float delay, System.Action callback)
    {
        yield return new WaitForSeconds(delay);
        if (callback.IsAvailable()) callback();
    }
    /// <summary>
    /// 延迟调用
    /// </summary>
    public void Invoke<T>(float delay, System.Action<T> callback, T arg)
    {
        if (callback != null)
        {
            if (delay > 0f)
            {
                StartCoroutine(OnInvoke(delay, callback, arg));
            }
            else
            {
                callback(arg);
            }
        }
    }
    private IEnumerator OnInvoke<T>(float delay, System.Action<T> callback, T arg)
    {
        yield return new WaitForSeconds(delay);
        if (callback.IsAvailable()) callback(arg);
    }
    /// <summary>
    /// 帧尾调用
    /// </summary>
    public void InvokeOnFrameEnd(System.Action callback)
    {
        if (callback.IsAvailable()) StartCoroutine(OnFrameEnd(callback));
    }
    private IEnumerator OnFrameEnd(System.Action callback)
    {
        yield return new WaitForEndOfFrame();
        if (callback.IsAvailable()) callback();
    }
    /// <summary>
    /// 帧尾调用
    /// </summary>
    public void InvokeOnFrameEnd<T>(System.Action<T> callback, T arg)
    {
        if (callback.IsAvailable()) StartCoroutine(OnFrameEnd<T>(callback, arg));
    }
    private IEnumerator OnFrameEnd<T>(System.Action<T> callback, T arg)
    {
        yield return new WaitForEndOfFrame();
        if (callback.IsAvailable()) callback(arg);
    }
    #endregion
}
