using System;
using UnityEngine;

[AddComponentMenu("Game/System/Mouse Event Forward")]
public class MouseEventForward : MonoBehaviour
{
    private object param;
    private Action onClick;
    private Action<MouseEventForward> onClickTag;
    private Action onDoubleClick;
    private Action<MouseEventForward> onDoubleClickTag;
    private Action<Vector2> onDrag;
    private Action<bool> onPress;
    private Action<MouseEventForward, bool> onPressTag;
    private Action<bool> onSelect;
    private Action<MouseEventForward, bool> onSelectTag;
    private Action<float> onScroll;
    private Action<bool> onTooltip;
    private Action<MouseEventForward, bool> onTooltipTag;

    /****************************事件****************************/
    void OnClick()
    {
        if (onClickTag != null) onClickTag(this);
        else if (onClick != null) onClick();
    }

    void OnDoubleClick()
    {
        if (onDoubleClickTag != null) onDoubleClickTag(this);
        else if (onDoubleClick != null) onDoubleClick();
    }

    void OnPress(bool pressed)
    {
        if (enabled)
        {
            if (onPress != null) onPress(pressed);
            else if (onPressTag != null) onPressTag(this, pressed);
        }
    }

    void OnSelect(bool selected)
    {
        if (enabled)
        {
            if (onSelect != null) onSelect(selected);
            else if (onSelectTag != null) onSelectTag(this, selected);
        }
    }

    void OnDrag(Vector2 delta) { if (enabled && onDrag != null) onDrag(delta); }

    void OnScroll(float delta) { if (enabled && onScroll != null)onScroll(delta); }

    void OnTooltip(bool show)
    {
        if (enabled)
        {
            if (onTooltip != null) onTooltip(show);
            else if (onTooltipTag != null) onTooltipTag(this, show);
        }
    }

    /****************************设置****************************/
    public void ClearEvent()
    {
        this.param = null;
        this.onClick = null;
        this.onClickTag = null;
    }

    public void SetClick(Action onClick) { this.onClick = onClick; }
    public void SetClick(Action<MouseEventForward> onClickSelf, object param = null)
    {
        this.param = param;
        this.onClickTag = onClickSelf;
    }

    public void SetDoubleClick(Action onDoubleClick) { this.onDoubleClick = onDoubleClick; }
    public void SetDoubleClick(Action<MouseEventForward> onClickSelf, object param = null)
    {
        this.param = param;
        this.onDoubleClickTag = onClickSelf;
    }

    public void SetPress(Action<bool> onPress) { this.onPress = onPress; }
    public void SetPress(Action<MouseEventForward, bool> onPress, object param = null)
    {
        this.param = param;
        this.onPressTag = onPress;
    }

    public void SetSelect(Action<bool> onSelect) { this.onSelect = onSelect; }
    public void SetSelect(Action<MouseEventForward, bool> onSelect, object param = null)
    {
        this.param = param;
        this.onSelectTag = onSelect;
    }

    public void SetTooltip(Action<bool> onTooltip) { this.onTooltip = onTooltip; }
    public void SetTooltip(Action<MouseEventForward, bool> onTooltip, object param = null)
    {
        this.param = param;
        this.onTooltipTag = onTooltip;
    }

    public void SetDrag(Action<Vector2> onDrag) { this.onDrag = onDrag; }

    public void SetScroll(Action<float> onScroll) { this.onScroll = onScroll; }

    public void SetParam(object param) { this.param = param; }

    /****************************附加参数****************************/
    public object Param { get { return param; } }
}
