using UnityEngine;
using System.Collections.Generic;

public class Game
{
    private GameObject go;

    private Dictionary<string, object> ms;

    private static Game ins;

    private Game()
    {
    }

    public static Game Ins
    {
        get
        {
            if (ins == null)
                ins = new Game();
            return ins;
        }
    }

    public LuaManager LuaMgr { get { return (LuaManager)ms["LuaManager"]; } }
    public PanelManager PanelMgr { get { return (PanelManager)ms["PanelManager"]; } }
    public SoundManager SoundMgr { get { return (SoundManager)ms["SoundManager"]; } }
    public TimerManager TimerMgr { get { return (TimerManager)ms["TimerManager"]; } }
    public NetworkManager NetworkMgr { get { return (NetworkManager)ms["NetworkManager"]; } }
    public ResourceManager ResourceMgr { get { return (ResourceManager)ms["ResourceManager"]; } }
    public ThreadManager ThreadMgr { get { return (ThreadManager)ms["ThreadManager"]; } }
    public ObjectPoolManager ObjectPoolMgr { get { return (ObjectPoolManager)ms["ObjectPoolManager"]; } }
    public GameManager GameMgr { get { return (GameManager)ms["GameManager"]; } }

    public void StartUp()
    {
        if (go == null)
        {
            go = GameObject.Find("Game");
            if (go == null)
            {
                return;
            }
        }
        ms = new Dictionary<string, object>();
        ms.Add("LuaManager", go.AddComponent<LuaManager>());
        ms.Add("PanelManager", go.AddComponent<PanelManager>());
        ms.Add("SoundManager", go.AddComponent<SoundManager>());
        ms.Add("TimerManager", go.AddComponent<TimerManager>());
        ms.Add("NetworkManager", go.AddComponent<NetworkManager>());
        ms.Add("ResourceManager", go.AddComponent<ResourceManager>());
        ms.Add("ThreadManager", go.AddComponent<ThreadManager>());
        ms.Add("ObjectPoolManager", go.AddComponent<ObjectPoolManager>());
        ms.Add("GameManager", go.AddComponent<GameManager>());
    }
}