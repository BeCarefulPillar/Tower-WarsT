using UnityEngine;

[RequireComponent(typeof(UIWidget))]
public class WidgetShadow : MonoBehaviour
{
    public float interval = 0;
    public float lifeTime = 0;
    UIWidget widget;
    float delta = 0;

    void Start()
    {
        if (!widget) widget = GetComponent<UIWidget>();
    }

    void LateUpdate()
    {
        if (!widget) return;
        if (delta > interval)
        {
            delta = 0;
            if (widget.cachedTransform.hasChanged)
            {
                GameObject go = widget.cachedTransform.parent.gameObject.AddChild("WidgetClone");
                WidgetClone w = go.AddComponent<WidgetClone>();
                w.Widget = widget;
                w.depth = widget.depth;
                w.width = widget.width;
                w.height = widget.height;
                w.cachedTransform.localPosition = widget.cachedTransform.localPosition;
                w.cachedTransform.localScale = widget.cachedTransform.localScale;
                w.cachedTransform.localEulerAngles = widget.cachedTransform.localEulerAngles;
                TweenAlpha.Begin(go, 0.3f, 0);
                Destroy(go, 0.3f);
                widget.cachedTransform.hasChanged = false;
            }
        }
        else
        {
            delta += Time.deltaTime;
        }
        if (lifeTime > 0)
        {
            lifeTime -= Time.deltaTime;
            if (lifeTime <= 0) Destroy(this);
        }
    }

    public static WidgetShadow Cast(UIWidget widget, float interval = 0, float lifeTime = 0)
    {
        WidgetShadow ws = widget.cachedGameObject.AddComponent<WidgetShadow>();
        ws.widget = widget;
        ws.interval = interval;
        ws.lifeTime = lifeTime;
        return ws;
    }
}
