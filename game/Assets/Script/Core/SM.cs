using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;

public class SM : Manager<SM>
{
    private HashSet<string> mScenes = new HashSet<string>();
    private bool mRunning = false;

    private IEnumerator IEAdd(string sceneName, Action action = null)
    {
        mRunning = true;
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
        mRunning = false;
        mScenes.Add(sceneName);
        if (action != null)
            action();
        Debug.Log("添加场景" + sceneName);
    }

    private IEnumerator IERemove(string sceneName, Action action = null)
    {
        mRunning = true;
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
        mRunning = false;
        mScenes.Remove(sceneName);
        if (action != null)
            action();
        Debug.Log("移除场景" + sceneName);
    }

    public void AddScene(string sceneName, Action action = null)
    {
        if (mRunning)
        {
            Debug.LogError("mRunning");
            return;
        }
        if (mScenes.Contains(sceneName))
        {
            Debug.LogError("mScenes.Contains(sceneName)");
            return;
        }
        StartCoroutine(IEAdd(sceneName, action));
    }

    public void RemoveScene(string sceneName, Action action = null)
    {
        if (mRunning)
        {
            Debug.LogError("mRunning");
            return;
        }
        if (!mScenes.Contains(sceneName))
        {
            Debug.LogError("!mScenes.Contains(sceneName)");
            return;
        }
        StartCoroutine(IERemove(sceneName, action));
    }
}