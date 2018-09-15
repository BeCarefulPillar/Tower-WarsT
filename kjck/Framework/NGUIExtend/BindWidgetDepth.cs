using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(UIWidget))]
public class BindWidgetDepth : MonoBehaviour
{
    public UIWidget bind;
    public int depthOffset = 0;

    UIWidget widget;

    void Start()
    {
        widget = GetComponent<UIWidget>();
        if (bind == widget) bind = null;
        Update();
    }

    void Update()
    {
        if (bind) widget.depth = bind.depth + depthOffset;
    }

    public void Bind(UIWidget bind, int offset) { this.bind = bind; depthOffset = offset; }
}
