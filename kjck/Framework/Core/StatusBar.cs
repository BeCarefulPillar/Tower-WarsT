using UnityEngine;
using System.Collections.Generic;

public class StatusBar : CoreModule
{
    public const float DEFAULT_TIMEOUT = 10f;
    public const float DEFAULT_TIMEOUT_LONG = 60f;

    private static StatusBar _Instance = null;
    /// <summary>
    /// 初始化
    /// </summary>
    public static void Init() { Instance(ref _Instance); }

    public static System.Action<IProgress> onTimeout;
#if TOLUA
    public static LuaInterface.LuaFunction luaOnTimeout;
#endif

    public static void Show(IProgress process, bool delay = true) { if (_Instance) _Instance.Enter(process, delay); }
    public static TempProcess Show(string msg = "", float timeOut = DEFAULT_TIMEOUT, bool delay = true) { return Show(0, msg, timeOut, delay); }
    public static TempProcess Show(int id, bool delay = true) { return Show(id, "", DEFAULT_TIMEOUT, delay); }
    public static TempProcess Show(int id, float timeOut = DEFAULT_TIMEOUT, bool delay = true) { return Show(id, "", timeOut, delay); }
    public static TempProcess Show(int id, string msg = "", float timeOut = DEFAULT_TIMEOUT, bool delay = true)
    {
        TempProcess tp = new TempProcess(id, msg, timeOut);
        if (_Instance)
        {
            _Instance.Enter(tp, delay);
        }
        return tp;
    }
    public static TempProcess Get(int id)
    {
        if (_Instance)
        {
            if (_Instance.mCurrent is TempProcess)
            {
                TempProcess stp = _Instance.mCurrent as TempProcess;
                if (stp.id == id) return stp;
            }
            foreach (IProgress ipro in _Instance.mQueue)
            {
                if (ipro is TempProcess)
                {
                    TempProcess stp = ipro as TempProcess;
                    if (stp.id == id) return stp;
                }
            }
        }
        return null;
    }
    public static void Exit() { if (_Instance) { _Instance.mCurrent = null; _Instance.mQueue.Clear(); } }
    public static void Exit(int id)
    {
        if (_Instance)
        {
            if (_Instance.mCurrent is TempProcess)
            {
                TempProcess stp = _Instance.mCurrent as TempProcess;
                if (stp.id == id) stp.Done();
            }
            foreach (IProgress ipro in _Instance.mQueue)
            {
                if (ipro is TempProcess)
                {
                    TempProcess stp = ipro as TempProcess;
                    if (stp != null && stp.id == id)
                    {
                        stp.Done();
                    }
                }
            }
        }
    }
    public static bool IsShow { get { return _Instance && _Instance.gameObject.activeSelf && _Instance.mCurrent != null; } }
    public static IProgress current { get { return _Instance ? _Instance.mCurrent : null; } }

    [SerializeField] private UILabel mMessage;
    [SerializeField] private UILabel mPercent;

    private IProgress mCurrent;
    private Queue<IProgress> mQueue = new Queue<IProgress>(8);

    public void Start()
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
        if (mCurrent == null && mQueue.Count > 0) mCurrent = mQueue.Dequeue();
        if (mCurrent != null)
        {
            mMessage.text = mCurrent.processMessage;
            if (mCurrent.process > 0)
            {
                mPercent.text = (mCurrent.process * 100f).ToString("f0") + "%";
                if (!mPercent.cachedGameObject.activeSelf) mPercent.cachedGameObject.SetActive(true);
            }
            else
            {
                mPercent.text = string.Empty;
            }
            if (mCurrent.isDone)
            {
                if (mCurrent.isTimeOut)
                {
                    if (onTimeout.IsAvailable())
                    {
                        onTimeout(mCurrent);
                    }
#if TOLUA
                    if (luaOnTimeout != null && luaOnTimeout.IsAlive)
                    {
                        luaOnTimeout.BeginPCall();
                        luaOnTimeout.Push(mCurrent);
                        luaOnTimeout.PCall();
                        luaOnTimeout.EndPCall();
                    }
#endif
                }
                mCurrent = null;
            }
        }
        else
        {
            OnExit();
        }
    }

    private void Enter(IProgress process, bool delay)
    {
        if (process == null || process.isDone) return;
        gameObject.SetActive(true);
        if (mQueue.Contains(process)) return;
        mQueue.Enqueue(process);
        if (delay)
        {
            CancelInvoke("PlayTween");
            Invoke("PlayTween", 1.5f);
        }
        else
        {
            PlayTween();
        }
    }

    private void PlayTween()
    {
        mPercent.cachedGameObject.SetActive(true);
    }

    private void OnExit()
    {
        mCurrent = null;
        mQueue.Clear();
        CancelInvoke("PlayTween");
        mPercent.cachedGameObject.SetActive(false);
        gameObject.SetActive(false);
        mMessage.text = mPercent.text = "";
    }

    public class TempProcess : IProgress
    {
        public const int ID_CHECK_LINK = 1;
        public const int ID_CHECK_CLIENT = 2;
        public const int ID_CONNECT = 3;
        public const int ID_LOGIN = 4;
        public const int ID_LOGOUT = 5;
        public const int ID_LOAD_LUA = 6;
        public const int ID_LOAD_SCENE = 7;

        private int mId = 0;
        private float mProcess = 0f;
        private float mDoneTime = float.MaxValue;
        private float mOutDeltaTime = 0f;
        private float mOutTime = 0f;

        public TempProcess(int id, string msg, float timeOut)
        {
            mId = id;
            mDoneTime = float.MaxValue;
            mProcess = 0;
            mOutDeltaTime = timeOut;
            processMessage = msg;
            ResetOutTime();
        }
        public void Done() { mDoneTime = Time.realtimeSinceStartup; }
        public void Done(float time) { mDoneTime = Time.realtimeSinceStartup + time; }
        public void ResetOutTime() { mOutTime = Time.realtimeSinceStartup + mOutDeltaTime; }
        public float process { get { return mProcess; } set { mProcess = value; ResetOutTime(); } }
        public bool isDone { get { return mDoneTime <= Time.realtimeSinceStartup || mOutTime < Time.realtimeSinceStartup; } }
        public bool isTimeOut { get { return mDoneTime > Time.realtimeSinceStartup && mOutTime < Time.realtimeSinceStartup; } }
        public string processMessage { get; set; }
        public int id { get { return mId; } }
    }
}
