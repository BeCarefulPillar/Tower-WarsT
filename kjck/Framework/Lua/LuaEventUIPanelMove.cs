using UnityEngine;

public class LuaEventUIPanelMove : LuaFuncBridge
{
    [SerializeField] private UIPanel mPanel;

    public override byte MaxFuncCount { get { return 1; } }

    private void Awake()
    {
        if (mPanel == null) mPanel = GetComponent<UIPanel>();
    }

    private void OnMove(UIPanel panel) { CallFunction(0); }

    private void OnEnable()
    {
        if (mPanel) mPanel.onClipMove += OnMove;
    }

    private void OnDisable()
    {
        if (mPanel) mPanel.onClipMove -= OnMove;
    }
}
