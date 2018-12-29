using UnityEngine.SceneManagement;
using System.Collections;
using UnityEngine;

public class USceneManager : UMonoBehaviour
{
    private UScene mUScene;

    private void Awake()
    {
        Debug.LogFormat("进入场景 {0}", sname);
    }

    public UScene uscene
    {
        get
        {
            return mUScene;
        }
        set
        {
            if (mUScene != null)
            {
                Debug.LogError("mUScene is not null");
                return;
            }
            mUScene = value;
        }
    }

    public string sname
    {
        get
        {
            return SceneManager.GetActiveScene().name;
        }
    }

    public void LoadScene(string name, float delay = 0)
    {
        if (name == sname)
            return;
        StopCoroutine("CoLoadScene");
        StartCoroutine(CoLoadScene(name, delay));
    }

    private IEnumerator CoLoadScene(string name, float delay)
    {
        delay += Time.realtimeSinceStartup;
        while (delay > Time.realtimeSinceStartup)
            yield return null;

        string a,b;

        a = sname;
        yield return SceneManager.LoadSceneAsync("transition");
        b = sname;
        Debug.LogFormat("场景切换 {0}->{1}", a, b);
        yield return null;

        a = sname;
        yield return SceneManager.LoadSceneAsync(name);
        b = sname;
        Debug.LogFormat("场景切换 {0}->{1}", a, b);
        yield return null;
    }

    public static USceneManager Ins
    {
        get
        {
            return Game.Ins.mIns["USceneManager"] as USceneManager;
        }
    }
}