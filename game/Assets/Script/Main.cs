using UnityEngine;
using System.Collections;

public class Main : MonoBehaviour
{
    public GameObject pb;
    private IEnumerator Start()
    {
        GameObject go = gameObject;

        DontDestroyOnLoad(go);

        go.AddComponent<SM>().Init();
        go.AddComponent<AM>().Init();
        go.AddComponent<GM>();
        go.AddComponent<BGM>();

        //SM.ins.ChangeScene("game");

        //Instantiate(AM.ins.LoadAsset("abc").prefab);

        pb = Resources.Load<GameObject>("Prefab/abc");
        yield return null;
        yield return null;
        DestroyImmediate(pb);
        //Instantiate(pb);
    }
}