using UnityEngine;
using System.Collections;

public class Main : MonoBehaviour
{
    private void Start()
    {
        GameObject go = gameObject;
        DontDestroyOnLoad(go);
        go.AddComponent<SM>().Init();

        //ui
        go.AddComponent<WM>().Init();
        Transform tf = transform;
        WM.ins.root = tf.Find("UI");
        WM.ins.cam = tf.Find("Camera").GetComponent<Camera>();

        go.AddComponent<AM>().Init();
        go.AddComponent<GM>();
        go.AddComponent<BGM>();

        WM.Open("WinLogin");
    }
}