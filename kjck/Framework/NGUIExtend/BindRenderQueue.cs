using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class BindRenderQueue : MonoBehaviour
{
    public UIWidget binder;
    public int offset = 0;
    public bool allways = false;

    bool notSet = true;

    Renderer render;

    void OnEnable() { notSet = true; }

    public void SetBind(UIWidget binder, int offset)
    {
        this.binder = binder;
        this.offset = offset;
        notSet = true;
    }

    void Update()
    {
        if ((allways || notSet) && binder && binder.drawCall)
        {
            if (render == null) render = GetComponent<Renderer>();
            render.sortingOrder = binder.drawCall.sortingOrder;
            render.material.renderQueue = binder.drawCall.finalRenderQueue + offset;
            notSet = false;
        }
    }
}
