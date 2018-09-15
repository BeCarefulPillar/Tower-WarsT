using UnityEngine;
using System;

[RequireComponent(typeof(UIProgressBar))]
public class SpringProgress : MonoBehaviour
{
    public Action<SpringProgress> onUpdate;
    public Action<SpringProgress> onFinished;
    
    UIProgressBar mProgress;

    public float target = 0f;
    public float strength = 10f;
    public bool ignoreTimeScale = false;

    private float value = 0f;

    private float mThreshold = 0f;

    void Start()
    {
        mProgress = GetComponent<UIProgressBar>();
        value = mProgress.value;
    }

    void Update()
    {
        float delta = ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime;

        if (mThreshold == 0f) mThreshold = Mathf.Abs(target - value) * 0.001f;
        mProgress.value = value = NGUIMath.SpringLerp(value, target, strength, delta);

        if (onUpdate != null) onUpdate(this);

        if (mThreshold >= Mathf.Abs(target - value))
        {
            mProgress.value = value = target;
            if (onFinished != null) onFinished(this);
            enabled = false;
        }
    }

    public static SpringProgress Begin(GameObject go, float target, float strength, Action<SpringProgress> onUpdate = null, Action<SpringProgress> onFinished = null)
    {
        SpringProgress sp = go.GetComponent<SpringProgress>();
        if (sp == null) sp = go.AddComponent<SpringProgress>();
        sp.target = Mathf.Clamp01(target);
        sp.strength = strength;

        sp.onUpdate = onUpdate;
        sp.onFinished = onFinished;

        if (!sp.enabled)
        {
            sp.mThreshold = 0f;
            sp.enabled = true;
        }
        return sp;
    }

    public float Value { get { return value; } }
}
