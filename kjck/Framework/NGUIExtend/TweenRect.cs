using UnityEngine;

[AddComponentMenu("NGUI/Tween/Tween Rect")]
[RequireComponent(typeof(UIWidget))]
public class TweenRect : UITweener
{
    public Rect from;
    public Rect to;

    public UIWidget widget;

    UITexture utex;
    UISpriteUV sprite;

    protected override void Start()
    {
        base.Start();
        GetWidget();
    }

    void GetWidget()
    {
        if (!widget) widget = GetComponent<UIWidget>();
        if (widget is UITexture) utex = widget as UITexture;
        if (widget is UISpriteUV) sprite = widget as UISpriteUV;
    }

    /// <summary>
    /// Tween's current value.
    /// </summary>

    public Rect value
    {
        get
        {
#if UNITY_EDITOR
            if (!widget) GetWidget();
#endif
            if (utex) return utex.uvRect;
            if (sprite) return sprite.uvRect;
            return new Rect();
        }
        set
        {
#if UNITY_EDITOR
            if (!widget) GetWidget();
#endif
            if (utex) utex.uvRect = value;
            if (sprite) sprite.uvRect = value;
        }
    }

    /// <summary>
    /// Tween the value.
    /// </summary>

    protected override void OnUpdate(float factor, bool isFinished)
    {
        float f1 = 1f - factor;
        value = new Rect(from.x * f1 + to.x * factor, from.y * f1 + to.y * factor, from.width * f1 + to.width * factor, from.height * f1 + to.height * factor);
    }

    /// <summary>
    /// Start the tweening operation.
    /// </summary>

    static public TweenRect Begin(GameObject go, float duration, Rect pos)
    {
        TweenRect comp = UITweener.Begin<TweenRect>(go, duration);
        comp.from = comp.value;
        comp.to = pos;

        if (duration <= 0f)
        {
            comp.Sample(1f, true);
            comp.enabled = false;
        }
        return comp;
    }

    [ContextMenu("Set 'From' to current value")]
    public override void SetStartToCurrentValue() { from = value; }

    [ContextMenu("Set 'To' to current value")]
    public override void SetEndToCurrentValue() { to = value; }

    [ContextMenu("Assume value of 'From'")]
    void SetCurrentValueToStart() { value = from; }

    [ContextMenu("Assume value of 'To'")]
    void SetCurrentValueToEnd() { value = to; }
}
