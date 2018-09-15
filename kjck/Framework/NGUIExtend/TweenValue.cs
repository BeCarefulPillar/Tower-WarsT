using UnityEngine;

public class TweenValue : UITweener
{
    public float from = 0, to = 1;
    public System.Action<float> onTween;
    public System.Action<UITweener> onTweenFinished;

    float mVal = 0;

    void Awake()
    {
        eventReceiver = gameObject;
        callWhenFinished = "OnTweenValueFinished";
        mVal = from;
    }

    public float value { get { return mVal; } }

    protected override void OnUpdate(float factor, bool isFinished)
    {
        mVal = from * (1f - factor) + to * factor;
        if (onTween != null) onTween(mVal);
    }

    void OnTweenValueFinished(UITweener ut)
    {
        if (onTweenFinished != null) onTweenFinished(ut);
    }

    static public TweenValue Begin(GameObject go, float duration, float from = 0, float to = 1, AnimationCurve cure = null)
    {
        TweenValue comp = UITweener.Begin<TweenValue>(go, duration);
        comp.animationCurve = cure;
        comp.from = from;
        comp.to = to;

        if (duration <= 0f)
        {
            comp.Sample(1f, true);
            comp.enabled = false;
        }
        return comp;
    }

    public override void SetStartToCurrentValue() { from = value; }
    public override void SetEndToCurrentValue() { to = value; }
}
