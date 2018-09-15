using UnityEngine;
using System;

public class SpringValue : MonoBehaviour
{
    public Action<SpringValue> onUpdate;
    public Action<SpringValue> onFinished;

    public float from = 0;
    public float to = 0;
    public float strength = 10f;
    public bool ignoreTimeScale = false;

    float value = 0;
    float mThreshold = 0f;
    // Use this for initialization
    void Start()
    {
        value = from;
    }

    // Update is called once per frame
    void Update()
    {
        float delta = ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime;

        if (mThreshold == 0f) mThreshold = Mathf.Abs(to - value) * 0.001f;
        value = NGUIMath.SpringLerp(value, to, strength, delta);
        if (onUpdate != null) onUpdate(this);

        if (mThreshold >= Mathf.Abs(to - value))
        {
            value = to;
            if (onFinished != null) onFinished(this);
            enabled = false;
        }
    }

    public static SpringValue Begin(GameObject go, float from, float to, float strength, Action<SpringValue> onUpdate = null, Action<SpringValue> onFinished = null)
    {
        SpringValue sv = go.GetComponent<SpringValue>();
        if (sv && sv.enabled) sv.value = from;
        else
        {
            if (!sv) sv = go.AddComponent<SpringValue>();
            sv.value = sv.from = from;
        }
        
        sv.to = to;
        sv.strength = strength;

        sv.onUpdate = onUpdate;
        sv.onFinished = onFinished;

        if (!sv.enabled)
        {
            sv.mThreshold = 0f;
            sv.enabled = true;
        }
        return sv;
    }

    public float Value { get { return value; } }
}
