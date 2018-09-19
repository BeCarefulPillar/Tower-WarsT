using UnityEngine;

public class Main : MonoBehaviour
{
    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
        Game.Ins.StartUp();
    }
}