using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;

public class WM : Manager<WM>
{
    private Stack<Win> mWins = new Stack<Win>();

    private List<Win> mCaches = new List<Win>();

    public Transform root;
    public Camera cam;

    private void Update()
    {
        if (mCaches.Count > 0)
        {
            float t = Time.realtimeSinceStartup;
            for (int i = 0; i < mCaches.Count; ++i)
            {
                if (t > mCaches[i].dt)
                {
                    Destroy(mCaches[i].gameObject);
                    mCaches.RemoveAt(i);
                    return;
                }
            }
        }
    }

    public static void Open(string nm, object p = null)
    {
        WM wm = ins;
        if (ins == null)
        {
            Debug.LogError("XXX");
            return;
        }
        if (wm.mWins.Count == 0)
        {
            Win w = wm.mCaches.Find(e => e.name == nm);
            if (w == null)
                w = wm.root.AddChild(Resources.Load<GameObject>("Prefab/" + nm)).GetComponent<Win>();
            else
                wm.mCaches.Remove(w);
            w.gameObject.SetActive(true);
            wm.mWins.Push(w);
            w.GetComponent<Canvas>().sortingOrder = 0;
            w.GetComponent<Canvas>().worldCamera = wm.cam;
        }
        else
        {
            Win w = wm.mWins.Peek();
            if (w.name == nm)
            {
                w.param = p;
                w.OnInit();
            }
            else
            {
                Win t = wm.mCaches.Find(e => e.name == nm);
                if (t == null)
                    t = wm.root.AddChild(Resources.Load<GameObject>("Prefab/" + nm)).GetComponent<Win>();
                else
                    wm.mCaches.Remove(t);
                t.param = p;
                t.OnInit();
                t.gameObject.SetActive(true);
                wm.mWins.Push(t);
                t.GetComponent<Canvas>().sortingOrder = w.GetComponent<Canvas>().sortingOrder + 30;
                w.GetComponent<Canvas>().worldCamera = wm.cam;
            }
        }
    }

    public static void Exit()
    {
        WM wm = ins;
        if (ins == null)
        {
            Debug.LogError("XXX");
            return;
        }
        if (wm.mWins.Count > 1)
        {
            Win w = wm.mWins.Pop();
            w.gameObject.SetActive(false);
            w.OnDispose();
            wm.mCaches.Add(w);
            w.dt = w.tm < 0 ? float.MaxValue : Time.realtimeSinceStartup + w.tm;
        }
        else
        {
            Debug.LogError("XXX");
        }
    }
}