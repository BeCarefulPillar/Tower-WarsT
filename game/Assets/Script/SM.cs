using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using System;
using System.Collections;

public class SM : Manager<SM>
{
    public List<string> lst = new List<string>();
    public bool running = false;

    public void AddScene(string sceneName)
    {
    }

    public void SubScene(string sceneName)
    {
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
        if(running)
        {
            Debug.LogError("正在运行");
            return;
        }
        StartCoroutine(Changing(sceneName));
    }
}