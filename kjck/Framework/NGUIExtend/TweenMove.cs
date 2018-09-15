using UnityEngine;

public class TweenMove : UITweener
{
    public Vector3 inPos;
    public Vector3 outPos;

    public bool worldSpace = false;

    private Transform mTrans;
    private UIRect mRect;
    private Vector3 from;
    private Vector3 to;

    public Transform cachedTransform { get { if (mTrans == null) mTrans = transform; return mTrans; } }

    public Vector3 value
    {
        get
        {
            return worldSpace ? cachedTransform.position : cachedTransform.localPosition;
        }
        set
        {
            if (mRect == null || !mRect.isAnchored || worldSpace)
            {
                if (worldSpace) cachedTransform.position = value;
                else cachedTransform.localPosition = value;
            }
            else
            {
                value -= cachedTransform.localPosition;
                NGUIMath.MoveRect(mRect, value.x, value.y);
            }
        }
    }

    void Awake() { mRect = GetComponent<UIRect>(); }

    protected override void OnUpdate(float factor, bool isFinished)
    {
        value = from * (1f - factor) + to * factor;
        if (isFinished && value == outPos)
        {
            gameObject.SetActive(false);
        }
    }

    public static TweenMove Begin(GameObject go, bool isIn, float duration, float delay = 0f)
    {
        TweenMove comp = UITweener.Begin<TweenMove>(go, duration, delay);

        comp.to = isIn ? comp.inPos : comp.outPos;

        if (go.activeSelf)
        {
            comp.from = comp.value;
        }
        else
        {
            comp.from = comp.outPos;
            comp.value = comp.outPos;
            go.SetActive(isIn);
        }

        if (duration <= 0f || !go.activeInHierarchy)
        {
            comp.Sample(1f, true);
            comp.enabled = false;
        }
        return comp;
    }

    [ContextMenu("Set 'In Pos' to current value")]
    public override void SetStartToCurrentValue() { inPos = value; }

    [ContextMenu("Set 'Out Pos' to current value")]
    public override void SetEndToCurrentValue() { outPos = value; }
}
