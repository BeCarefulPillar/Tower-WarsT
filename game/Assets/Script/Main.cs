using UnityEngine;

public class Main : MonoBehaviour
{
    private void Start()
    {
        GameObject go = gameObject;

        DontDestroyOnLoad(go);

        go.AddComponent<SM>().Init();
        go.AddComponent<AM>().Init();
        go.AddComponent<GM>();
        go.AddComponent<BGM>();

        SM.ins.ChangeScene("game");

        AM.ins.LoadAsset("abc");
        Instantiate(AM.ins.LoadAsset("abc").prefab);
    }
}