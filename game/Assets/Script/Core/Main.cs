using UnityEngine;
using UnityEditor;
using System.Collections;
using Newtonsoft.Json;

public class BD_Dat
{
    public int sn;
    public int[] arr;
}

public class BD_Filed
{
    public int sn;
    public string nm;
    public BD_Dat d;
}

public class Main : MonoBehaviour
{
    [MenuItem("Test/Fun")]
    private static void Fun()
    {
        BD_Filed b = new BD_Filed();
        b.sn = 2;
        b.nm = "pp";
        b.d = new BD_Dat();
        b.d.sn = 99;
        b.d.arr = new int[] { 3, 4, 5 };

        string t = Tools.Serialize(b);
        BD_Filed f = Tools.Deserialize<BD_Filed>(t);
        Debug.Log(f.sn);
        Debug.Log(f.nm);
        Debug.Log(t);
    }

    private void Start()
    {
        GameObject go = gameObject;
        go.AddCmp<SM>().Init();

        //ui
        go.AddCmp<WM>().Init();
        WM.ins.root = go.Child("UI");
        WM.ins.cam = go.Child<Camera>("Camera");

        go.AddCmp<AM>().Init();
        go.AddCmp<GM>();
        go.AddCmp<BGM>().Init();

        WM.Open("WinLogin");

        Destroy(this);
    }
}