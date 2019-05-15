using UnityEngine;
using System.Collections;

public class Main : MonoBehaviour
{
    private void Start()
    {
        GameObject go = gameObject;
        DontDestroyOnLoad(go);
        go.AddCmp<SM>().Init();

        //ui
        go.AddCmp<WM>().Init();
        WM.ins.root = go.Child("UI");
        WM.ins.cam = go.Child<Camera>("Camera");

        go.AddCmp<AM>().Init();
        go.AddCmp<GM>();
        go.AddCmp<BGM>();

        WM.Open("WinLogin");
    }
}