using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(UIPanel))]
public class BindPanel : MonoBehaviour
{
    public UIPanel bind;
    public int depthOffset = 0;
    public bool bindEnable = true;

    UIPanel panel;

    void Start()
    {
        panel = GetComponent<UIPanel>();
        if (bind == null && transform.parent) bind = UIPanel.Find(transform.parent);
        if (bind == panel) bind = null;
        LateUpdate();
    }

    void OnDisable() { if (panel) LateUpdate(); }
	
    void LateUpdate()
    {
        if (bind != null )
        {
            if (bindEnable) panel.enabled = bind.enabled;
            panel.depth = bind.depth + depthOffset;
        }
    }

    public void Set(UIPanel bind, int offset)
    {
        if (bind != panel)
        {
            this.bind = bind;
            depthOffset = offset;
        }
    }
}
