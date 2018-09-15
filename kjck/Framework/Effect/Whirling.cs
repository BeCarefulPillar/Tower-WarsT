using UnityEngine;

public class Whirling : MonoBehaviour
{
    public Vector3 axis = Vector3.zero;
    public float angularVelocity = 0;
    public float time = 0;
    public float delay = 0;

    public bool playOnAwake = true;
    public bool ignoreTimeScale = true;

    Transform mTrans;
    bool play = false;
    float playTime = 0;

    void Awake()
    {
        mTrans = transform;
        play = playOnAwake;
        playTime = 0;
    }

    void Update()
    {
        if (play)
        {
            float deltaTime = ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime;
            if (playTime >= delay && (time <= 0 || playTime - delay < time))
            {
                mTrans.Rotate(axis, angularVelocity * deltaTime, Space.Self);
                //mTrans.Rotate(axis, angularVelocity / 30f, Space.Self);
            }
            playTime += deltaTime;
        }
    }

    public void Set(Vector3 axis, float angularVelocity, float time = 0, float delay = 0)
    {
        this.axis = axis;
        this.angularVelocity = angularVelocity;
        this.time = time;
        this.delay = delay;
    }

    public void Reset()
    {
        playTime = 0;
    }

    public void Play(float time, float delay = 0)
    {
        this.time = time;
        this.delay = delay;
        Reset();
        play = true;
    }

    public void Play()
    {
        Reset();
        play = true;
    }

    public static Whirling Begin(GameObject go, Vector3 axis, float angularVelocity, float time = 0, float delay = 0)
    {
        Whirling w = go.GetComponent<Whirling>();
        if (!w) w = go.AddComponent<Whirling>();
        w.Set(axis, angularVelocity, time, delay);
        w.Play();
        return w;
    }
}
