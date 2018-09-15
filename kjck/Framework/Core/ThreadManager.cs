#if TOLUA
using LuaInterface;
#endif
using System;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ThreadManager : CoreModule
{
    /// <summary>
    /// 执行等待时间(15S)
    /// </summary>
    private const int TASK_WAIT_TICKS = 150000000;
    /// <summary>
    /// 执行等待时间(15S)
    /// </summary>
    private const int TASK_WAIT_SEC = 15;
    /// <summary>
    /// 线程等待时，每次睡眠时间(MS)
    /// </summary>
    private const int THREAD_WAIT_SLEEP = 10;

    /// <summary>
    /// 主线程
    /// </summary>
    private static Thread _MainThread = null;

    /// <summary>
    /// 单例MonoBehaviour
    /// </summary>
    private static ThreadManager _Instance = null;

    /// <summary>
    /// 同步工作
    /// </summary>
    private static Task _SyncTask = new Task();
    /// <summary>
    /// 是否正在工作
    /// </summary>
    private static bool _IsSyncWorking = false;
    /// <summary>
    /// 异步工作队列
    /// </summary>
    private static Task[] _AsyncTasks = new Task[32];
    /// <summary>
    /// 异步工作队列头
    /// </summary>
    private static int _AsyncTaskHead = 0;
    /// <summary>
    /// 异步工作队列尾
    /// </summary>
    private static int _AsyncTaskTail = 0;

    /// <summary>
    /// 当前是否在主线程
    /// </summary>
    public static bool onMainThread { get { return _MainThread == Thread.CurrentThread; } }

    /// <summary>
    /// 初始化
    /// </summary>
    public static void Init() { Instance(ref _Instance); }

    public static bool Run(WaitCallback call, object state = null) { return ThreadPool.QueueUserWorkItem(call, state); }
    public static void Run(Task task) { if (task == null || task.isDone) return; ThreadPool.QueueUserWorkItem(WaitCallback, task); }

    /// <summary>
    /// 添加工作
    /// </summary>
    private static Task AddTask(Delegate d, params object[] args)
    {
        lock (_AsyncTasks)
        {
            int len = _AsyncTasks.Length;
            if (_AsyncTaskTail - _AsyncTaskHead >= len - 8)
            {
                // 扩容
                Task[] newCache = new Task[len * 2];

                int head = _AsyncTaskHead % len;
                if (head > 0)
                {
                    Array.Copy(_AsyncTasks, head, newCache, 0, len - head);
                    Array.Copy(_AsyncTasks, 0, newCache, len - head, head);
                }

                _AsyncTaskHead = 0;
                _AsyncTaskTail = len;
                _AsyncTasks = newCache;

                len = _AsyncTasks.Length;
            }
            int idx = _AsyncTaskTail % len;
            Task work = _AsyncTasks[idx];
            if(work == null) work = _AsyncTasks[idx] = new Task();
            work.Init(d, args);
            _AsyncTaskTail++;
            return work;
        }
    }

    public static Task Call(Action d) { return Run(d); }
    public static Task Call<T>(Action<T> d, T arg) { return Run(d, arg); }
    public static Task Call<T, U>(Action<T, U> d, T arg1, U arg2) { return Run(d, arg1, arg2); }
    public static Task Call<T, U, V>(Action<T, U, V> d, T arg1, U arg2, V arg3) { return Run(d, arg1, arg2, arg3); }
    public static Task Call<T, U, V, W>(Action<T, U, V, W> d, T arg1, U arg2, V arg3, W arg4) { return Run(d, arg1, arg2, arg3, arg4); }
    public static Task Call<R>(Func<R> d) { return Run(d); }
    public static Task Call<T, R>(Func<T, R> d, T arg) { return Run(d, arg); }
    public static Task Call<T, U, R>(Func<T, U, R> d, T arg1, U arg2) { return Run(d, arg1, arg2); }
    public static Task Call<T, U, V, R>(Func<T, V, R> d, T arg1, U arg2, V arg3) { return Run(d, arg1, arg2, arg3); }
    public static Task Call<T, U, V, W, R>(Func<T, V, R> d, T arg1, U arg2, V arg3, W arg4) { return Run(d, arg1, arg2, arg3, arg4); }
    /// <summary>
    /// 线程执行
    /// </summary>
    public static Task Run(Delegate d, params object[] args)
    {
        Task task = new Task();
        task.Init(d, args);
        ThreadPool.QueueUserWorkItem(WaitCallback, task);
        return task;
    }
    /// <summary>
    /// 线程执行
    /// </summary>
    private static void WaitCallback(object state) { if (state is Task) (state as Task).Do(); }

    public static void CallOnMainThread(Action d) { RunOnMainThread(d); }
    public static void CallOnMainThread<T>(Action<T> d, T arg) { RunOnMainThread(d, arg); }
    public static void CallOnMainThread<T, U>(Action<T, U> d, T arg1, U arg2) { RunOnMainThread(d, arg1, arg2); }
    public static void CallOnMainThread<T, U, V>(Action<T, U, V> d, T arg1, U arg2, V arg3) { RunOnMainThread(d, arg1, arg2, arg3); }
    public static void CallOnMainThread<T, U, V, W>(Action<T, U, V, W> d, T arg1, U arg2, V arg3, W arg4) { RunOnMainThread(d, arg1, arg2, arg3, arg4); }
    public static R CallOnMainThread<R>(Func<R> d) { object obj = RunOnMainThread(d); return obj == null ? default(R) : (R)obj; }
    public static R CallOnMainThread<T, R>(Func<T, R> d, T arg) { object obj = RunOnMainThread(d, arg); return obj == null ? default(R) : (R)obj; }
    public static R CallOnMainThread<T, U, R>(Func<T, U, R> d, T arg1, U arg2) { object obj = RunOnMainThread(d, arg1, arg2); return obj == null ? default(R) : (R)obj; }
    public static R CallOnMainThread<T, U, V, R>(Func<T, V, R> d, T arg1, U arg2, V arg3) { object obj = RunOnMainThread(d, arg1, arg2, arg3); return obj == null ? default(R) : (R)obj; }
    public static R CallOnMainThread<T, U, V, W, R>(Func<T, V, R> d, T arg1, U arg2, V arg3, W arg4) { object obj = RunOnMainThread(d, arg1, arg2, arg3, arg4); return obj == null ? default(R) : (R)obj; }
    /// <summary>
    /// 主线程执行
    /// </summary>
    public static object RunOnMainThread(Delegate d, params object[] args)
    {
        if (d == null) return null;
        try
        {
#if UNITY_EDITOR
            if (_MainThread == null || _MainThread == Thread.CurrentThread)
#else
            if (_MainThread == Thread.CurrentThread)
#endif
            {
                return d.DynamicInvoke(args);
            }
            else
            {
                lock (_SyncTask)
                {
                    long expTick = DateTime.Now.Ticks + TASK_WAIT_TICKS;
                    while (_IsSyncWorking && expTick > DateTime.Now.Ticks) Thread.Sleep(THREAD_WAIT_SLEEP);
                    _SyncTask.Init(d, args);
                    _IsSyncWorking = true;
                    while (_IsSyncWorking && expTick > DateTime.Now.Ticks) Thread.Sleep(THREAD_WAIT_SLEEP);
                    return _SyncTask.returnObject;
                }
            }
        }
        catch(Exception e)
        {
            Debug.LogException(e);
        }
        return null;
    }

    public static Task CallOnMainThreadAsync(Action d) { return RunOnMainThreadAsync(d); }
    public static Task CallOnMainThreadAsync<T>(Action<T> d, T arg) { return RunOnMainThreadAsync(d, arg); }
    public static Task CallOnMainThreadAsync<T, U>(Action<T, U> d, T arg1, U arg2) { return RunOnMainThreadAsync(d, arg1, arg2); }
    public static Task CallOnMainThreadAsync<T, U, V>(Action<T, U, V> d, T arg1, U arg2, V arg3) { return RunOnMainThreadAsync(d, arg1, arg2, arg3); }
    public static Task CallOnMainThreadAsync<T, U, V, W>(Action<T, U, V, W> d, T arg1, U arg2, V arg3, W arg4) { return RunOnMainThreadAsync(d, arg1, arg2, arg3, arg4); }
    public static Task CallOnMainThreadAsync<R>(Func<R> d) { return RunOnMainThreadAsync(d); }
    public static Task CallOnMainThreadAsync<T, R>(Func<T, R> d, T arg) { return RunOnMainThreadAsync(d, arg); }
    public static Task CallOnMainThreadAsync<T, U, R>(Func<T, U, R> d, T arg1, U arg2) { return RunOnMainThreadAsync(d, arg1, arg2); }
    public static Task CallOnMainThreadAsync<T, U, V, R>(Func<T, V, R> d, T arg1, U arg2, V arg3) { return RunOnMainThreadAsync(d, arg1, arg2, arg3); }
    public static Task CallOnMainThreadAsync<T, U, V, W, R>(Func<T, V, R> d, T arg1, U arg2, V arg3, W arg4) { return RunOnMainThreadAsync(d, arg1, arg2, arg3, arg4); }
    /// <summary>
    /// 主线程异步执行
    /// </summary>
    public static Task RunOnMainThreadAsync(Delegate d, params object[] args)
    {
        if (d == null) return null;
        try
        {
            if (_MainThread == Thread.CurrentThread)
            {
                Task task = new Task();
                task.Init(d, args);
                task.Do();
                return task;
            }
            else
            {
                return AddTask(d, args);
            }
        }
        catch (Exception e)
        {
            Debug.LogException(e);
        }
        return null;
    }

#if TOLUA
    /// <summary>
    /// 主线程执行
    /// </summary>
    public static void RunOnMainThread(LuaFunction func, params object[] args)
    {
        if (func == null || !func.IsAlive) return;
        try
        {
            if (_MainThread == Thread.CurrentThread)
            {
                if (args == null || args.Length < 1)
                {
                    func.Call();
                }
                else
                {
                    func.BeginPCall();
                    func.PushArgs(args);
                    func.PCall();
                    func.EndPCall();
                }
            }
            else
            {
                lock (_SyncTask)
                {
                    long expTick = DateTime.Now.Ticks + TASK_WAIT_TICKS;
                    while (_IsSyncWorking && expTick > DateTime.Now.Ticks) Thread.Sleep(THREAD_WAIT_SLEEP);
                    _SyncTask.Init(func, args);
                    _IsSyncWorking = true;
                    while (_IsSyncWorking && expTick > DateTime.Now.Ticks) Thread.Sleep(THREAD_WAIT_SLEEP);
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogException(e);
        }
    }
    /// <summary>
    /// 主线程执行
    /// </summary>
    public static void RunOnMainThreadAsync(LuaFunction func, params object[] args)
    {
        if (func == null || !func.IsAlive) return;
        try
        {
            if (_MainThread == Thread.CurrentThread)
            {
                if (args == null || args.Length < 1)
                {
                    func.Call();
                }
                else
                {
                    func.BeginPCall();
                    func.PushArgs(args);
                    func.PCall();
                    func.EndPCall();
                }
            }
            else
            {
                lock (_AsyncTasks)
                {
                    int len = _AsyncTasks.Length;
                    if (_AsyncTaskTail - _AsyncTaskHead >= len - 8)
                    {
                        // 扩容
                        Task[] newCache = new Task[len * 2];

                        int head = _AsyncTaskHead % len;
                        if (head > 0)
                        {
                            Array.Copy(_AsyncTasks, head, newCache, 0, len - head);
                            Array.Copy(_AsyncTasks, 0, newCache, len - head, head);
                        }

                        _AsyncTaskHead = 0;
                        _AsyncTaskTail = len;
                        _AsyncTasks = newCache;

                        len = _AsyncTasks.Length;
                    }
                    int idx = _AsyncTaskTail % len;
                    Task work = _AsyncTasks[idx];
                    if (work == null) work = _AsyncTasks[idx] = new Task();
                    work.Init(func, args);
                    _AsyncTaskTail++;
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogException(e);
        }
    }

    private void OnStartLuaLite(object chunk)
    {
        LuaStateLite lsl = new LuaStateLite();
        lsl.DoString(chunk as string);
        lsl.Dispose();
    }
    public void StartLuaLiteTask(string chunk, LuaFunction callback = null)
    {
        if (string.IsNullOrEmpty(chunk)) return;
        if (callback == null)
        {
            ThreadPool.QueueUserWorkItem(OnStartLuaLite, chunk);
        }
        else
        {
            ThreadPool.QueueUserWorkItem(obj =>
            {
                LuaStateLite lsl = new LuaStateLite();
                string ret = lsl.DoString(chunk);
                lsl.Dispose();
                RunOnMainThread(callback, ret);
            });
        }
    }
#endif

    #region 组件部分
    private void Awake()
    {
        // 记录主线程
        _MainThread = Thread.CurrentThread;
    }
    private void Start()
    {
        if (_Instance == null)
        {
            _Instance = this;
            MoveToGame(_Instance.gameObject);
        }
        else if (_Instance != this)
        {
            this.DestructIfOnly();
        }
    }

    private void Update()
    {
        if (_IsSyncWorking)
        {
            _SyncTask.Do();
            _IsSyncWorking = false;
        }

        if (_AsyncTaskHead < _AsyncTaskTail)
        {
            _AsyncTasks[_AsyncTaskHead % _AsyncTasks.Length].Do();
            _AsyncTaskHead++;
        }
    }
#endregion

    /// <summary>
    /// 工作类
    /// </summary>
    public class Task : IProgress
    {
        private Delegate mDelegate;
#if TOLUA
        private LuaFunction mLuaFunction;
#endif
        private object[] mArgs;
        private object mReturnObject;

        public Task() { }

        public void Init(Delegate d, params object[] args)
        {
            mDelegate = d;
            mArgs = args;
            mReturnObject = null;
        }

#if TOLUA
        public void Init(LuaFunction luaFunc, params object[] args)
        {
            mDelegate = null;
            mLuaFunction = luaFunc;
            mArgs = args;
            mReturnObject = null;
        }
#endif

        public void Do()
        {
            try
            {
                if (mDelegate != null)
                {
                    mReturnObject = mDelegate.DynamicInvoke(mArgs);
                }
#if TOLUA
                if (mLuaFunction != null)
                {
                    mLuaFunction.BeginPCall();
                    if(mArgs != null && mArgs.Length > 0) mLuaFunction.PushArgs(mArgs);
                    mLuaFunction.PCall();
                    mLuaFunction.EndPCall();
                }
#endif
            }
            catch(Exception e)
            {
                Debug.LogException(e);
            }
            finally
            {
#if TOLUA
                mLuaFunction = null;
#endif
                mDelegate = null;
                mArgs = null;
            }
        }

        public object returnObject { get { return mReturnObject; } }

        public float process { get { return mDelegate == null ? 1f : 0f; } }

        public bool isDone { get { return mDelegate == null; } }

        public bool isTimeOut { get { return false; } }

        public string processMessage { get { return string.Empty; } }
    }
}
