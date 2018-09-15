using UnityEngine;

public class DoAfter : MonoBehaviour
{
    public enum Work
    {
        Destruct,
        StopParticle,
        Active,
        InActive,
        SendMessage,
    }
    public bool ignoreTimeScale = true;
    public Work work = Work.Destruct;
    public string param;
    public int waitFrame = 0;
    public float time = 0;

    void Update()
    {
        if (waitFrame > 0) waitFrame--;
        else if (time > 0) time -= ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime;
        else DoWork();
    }

    void DoWork()
    {
        switch (work)
        {
            case Work.Active:
                gameObject.SetActive(true);
                break;
            case Work.InActive:
                gameObject.SetActive(false);
                break;
            case Work.Destruct:
                Object.Destroy(gameObject);
                return;
            case Work.StopParticle:
                ParticleSystem[] ps = this.GetComponentsInAllChild<ParticleSystem>();
                foreach (ParticleSystem p in ps)p.Stop();
                UIParticle[] ups = this.GetComponentsInAllChild<UIParticle>();
                foreach (UIParticle p in ups) p.Stop();
                break;
            case Work.SendMessage:
                if (!string.IsNullOrEmpty(param)) SendMessage(param);
                break;
            default: break;
        }
        Object.Destroy(this);
    }

    public static void Do(GameObject go, Work work, float time = 0, bool ignoreTimeScale = true)
    {
        if (go)
        {
            DoAfter da = go.AddComponent<DoAfter>();
            da.work = work;
            da.ignoreTimeScale = ignoreTimeScale;
            da.time = time;
            if (time <= 0) da.DoWork();
        }
    }

    public static void Destroy(GameObject go, float time = 0, bool ignoreTimeScale = true)
    {
        DoAfter.Do(go, Work.Destruct, time, ignoreTimeScale);
    }

    public static void StopParticle(GameObject go, float time = 0, bool ignoreTimeScale = true)
    {
        DoAfter.Do(go, Work.StopParticle, time, ignoreTimeScale);
    }
}
