using System.Collections;
using UnityEngine;
using UnitySceneManager = UnityEngine.SceneManagement.SceneManager;
using UnityScene = UnityEngine.SceneManagement.Scene;

public class SceneManager : CoreModule
{
    /// <summary>
    /// 场景加载超时时间
    /// </summary>
    public const int LOAD_TIME_OUT = 15;
    /// <summary>
    /// 系统场景名称
    /// </summary>
    public const string SCENE_ENTRY = "entry";
    /// <summary>
    /// 过渡场景名称
    /// </summary>
    public const string SCENE_TRANSITION = "transition";

    /// <summary>
    /// 加载时间
    /// </summary>
    private static float _LoadSceneWait = 0f;

    /// <summary>
    /// 单例
    /// </summary>
    private static SceneManager _Instance;

    /// <summary>
    /// 当前场景
    /// </summary>
    private static UnityScene _Current;
    /// <summary>
    /// 当前场景对象
    /// </summary>
    private static Scene _Scene;

    /// <summary>
    /// 当前是否是入口场景
    /// </summary>
    public static bool isEntry { get { return _Current.name == SCENE_ENTRY; } }
    /// <summary>
    /// 当前是否是过渡场景
    /// </summary>
    public static bool isTransition { get { return _Current.name == SCENE_TRANSITION; } }
    /// <summary>
    /// 当前场景对象
    /// </summary>
    public static Scene current { get { return _Scene; } }

    /// <summary>
    /// 初始化
    /// </summary>
    public static void Init() { Instance(ref _Instance); }

    /// <summary>
    /// 当前场景名称
    /// </summary>
    public static string currentName { get { return _Current.name; } }
    /// <summary>
    /// 场景切换事件
    /// </summary>
    private static void OnActiveSceneChanged(UnityScene from, UnityScene to)
    {
        Debug.Log("Scene Changed " + _Current.name + " -> " + to.name);
        _Current = to;
        BindScene();
    }

    /// <summary>
    /// 当前是否是给定的场景
    /// </summary>
    /// <param name="sceneName">场景名称</param>
    public static bool CurrentIs(string sceneName)
    {
        return _Current.name == sceneName;
    }
    /// <summary>
    /// 场景是否加载
    /// </summary>
    /// <param name="sceneName">场景名称</param>
    public static bool IsLoaded(string sceneName)
    {
        return UnitySceneManager.GetSceneByName(sceneName).isLoaded;
    }
    /// <summary>
    /// 加载场景
    /// </summary>
    /// <param name="name">场景名称</param>
    public static void LoadScene(string name) { LoadScene(name, 0f); }
    /// <summary>
    /// 加载场景
    /// </summary>
    /// <param name="name">场景名称</param>
    /// <param name="delay">延迟加载</param>
    public static void LoadScene(string name, float delay)
    {
        if (name == _Current.name) return;
        if (_Instance)
        {
            if (_Instance.gameObject.activeInHierarchy)
            {
                _Instance.StartCoroutine(_Instance.Loading(name, delay));
            }
            else
            {
                Debug.LogWarning("SceneManager dose not ActiveInHierarchy!!!");
            }
        }
        else
        {
            Debug.LogWarning("SceneManager dose not Init!!!");
        }
    }
    /// <summary>
    /// 绑定场景对象
    /// </summary>
    private static void BindScene()
    {
        _Scene = null;
        if (_Current.rootCount <= 0 || SCENE_TRANSITION == _Current.name) return;
        GameObject[] roots = _Current.GetRootGameObjects();
        for (int i = 0; i < roots.Length; i++)
        {
            _Scene = roots[i].GetComponentInAllChild<Scene>();
            if (_Scene) break;
        }
        if (_Scene == null && _Instance.genSceneWhenAbsent)
        {
            _Scene = new GameObject("Scene").AddComponent<Scene>();
        }
        //else
        //{
        //    return;
        //}
    }

    #region 实体
    /// <summary>
    /// 当场景中没有Scene时自动生成
    /// </summary>
    [SerializeField] public bool genSceneWhenAbsent = false;
    [SerializeField] private MainBgLoader mLoadingScreen;
    [SerializeField] private UILabel mLoadingLab;
    [SerializeField] private UIProgressBar mLoadingProgress;

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
            return;
        }

        UnitySceneManager.activeSceneChanged -= OnActiveSceneChanged;
        UnitySceneManager.activeSceneChanged += OnActiveSceneChanged;

        _Current = UnitySceneManager.GetActiveScene();
        BindScene();
    }
    /// <summary>
    /// 场景加载协同
    /// </summary>
    private IEnumerator Loading(string name, float delay = 0f)
    {
        while (_LoadSceneWait > Time.realtimeSinceStartup) yield return null;

        if (name == _Current.name) yield break;

        _LoadSceneWait = Time.realtimeSinceStartup + LOAD_TIME_OUT;
        delay += Time.realtimeSinceStartup;
        while (Time.realtimeSinceStartup < delay) yield return null;
        ShowLoading(true);
        yield return new WaitForSeconds(0.2f);
        //ToolTip.ShowGameTip(true);
        yield return UnitySceneManager.LoadSceneAsync(SCENE_TRANSITION);//加载过渡场景（用于避免内存高峰）
        yield return null; yield return null;
        AsyncOperation ao = UnitySceneManager.LoadSceneAsync(name);
        while (!ao.isDone)
        {
            SetLoadingProgress(ao.progress * 0.8f);
            yield return null;
        }
        yield return null; yield return null;
        if (_Scene)
        {
            while (_Scene.loadingProgress < 1f)
            {
                SetLoadingProgress(0.8f + 0.2f * _Scene.loadingProgress);
                yield return null;
            }
        }
        SetLoadingProgress(1f);
        yield return null; yield return null;
        ShowLoading(false);
        _LoadSceneWait = 0f;
    }

    /// <summary>
    /// 显示Loding
    /// </summary>
    /// <param name="flag"></param>
    private void ShowLoading(bool flag)
    {
        if (mLoadingScreen)
        {
            mLoadingScreen.LoadBg(AssetName.BG_MAIN);
            mLoadingScreen.LoadLogo(AssetName.LOGO_MAIN);
            TweenFade.Begin(mLoadingScreen.gameObject, flag, 0.3f);
        }
        if(flag) SetLoadingProgress(0f);
    }
    /// <summary>
    /// Loding进度
    /// </summary>
    private void SetLoadingProgress(float progress)
    {
        if (mLoadingProgress) mLoadingProgress.value = progress;
        if (mLoadingLab) mLoadingLab.text = (progress * 100f).ToString("f0") + "%";
    }
    #endregion
}
