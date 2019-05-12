using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SM : Manager<SM>
{
    public List<string> lst = new List<string>();
    public bool running = false;

    /*private void Update()
    {
        if (Input.GetKeyDown(KeyCode.J))
        {
            AddScene("New Scene");
            AddScene("New Scene");
        }
        if (Input.GetKeyDown(KeyCode.K))
            RemoveScene("New Scene");
        if (Input.GetKeyDown(KeyCode.N))
            AddScene("New Scene 1");
        if (Input.GetKeyDown(KeyCode.M))
            RemoveScene("New Scene 1");
    }*/

    private IEnumerator Adding(string sceneName)
    {
        running = true;
        yield return null;
        AsyncOperation ao = SceneManager.LoadSceneAsync(sceneName, LoadSceneMode.Additive);
        yield return null;
        string s = "添加进度";
        while (!ao.isDone)
        {
            s += " " + ao.progress;
            Debug.Log(s);
            yield return null;
        }
        yield return null;
        running = false;
        lst.Add(sceneName);
        Debug.Log("添加场景" + sceneName);
    }

    private IEnumerator Removeing(string sceneName)
    {
        running = true;
        yield return null;
        AsyncOperation ao = SceneManager.UnloadSceneAsync(sceneName);
        yield return null;
        string s = "移除进度";
        while (!ao.isDone)
        {
            s += " " + ao.progress;
            Debug.Log(s);
            yield return null;
        }
        yield return null;
        running = false;
        lst.Remove(sceneName);
        Debug.Log("移除场景" + sceneName);
    }

    public void AddScene(string sceneName)
    {
        if (running)
        {
            Debug.LogError("正在运行");
            return;
        }
        if (lst.Exists(s => s == sceneName))
        {
            Debug.LogError("已存在场景" + sceneName);
            return;
        }
        StartCoroutine(Adding(sceneName));
    }

    public void RemoveScene(string sceneName)
    {
        if (running)
        {
            Debug.LogError("正在运行");
            return;
        }
        if (!lst.Exists(s => s == sceneName))
        {
            Debug.LogError("不存在场景" + sceneName);
            return;
        }
        StartCoroutine(Removeing(sceneName));
    }

    private IEnumerator Changing(string sceneName)
    {
        running = true;
        yield return null;
        yield return SceneManager.LoadSceneAsync("transition");
        yield return null;
        AsyncOperation ao = SceneManager.LoadSceneAsync(sceneName);
        yield return null;
        while (!ao.isDone)
            yield return null;
        yield return null;
        lst.Clear();
        lst.Add(sceneName);
        running = false;
        Debug.Log("切换场景" + sceneName);
    }

    public void ChangeScene(string sceneName)
    {
        if (running)
        {
            Debug.LogError("正在运行");
            return;
        }
        StartCoroutine(Changing(sceneName));
    }

}