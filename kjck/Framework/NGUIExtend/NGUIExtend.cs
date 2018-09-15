using UnityEngine;
using System;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using Kiol.Reflection;

public static class NGUIExtend
{
    #region UIWidget
    /// <summary>
    /// 更换渲染面板
    /// </summary>
    /// <param name="newPanel"></param>
    public static void ChangePanel(this UIWidget widget, UIPanel newPanel)
    {
        if (newPanel && widget.panel != newPanel)
        {
            widget.RemoveFromPanel();
            widget.panel = newPanel;
            //widget.ParentHasChanged();
            widget.panel.AddWidget(widget);
            widget.CheckLayer();
            widget.Invalidate(true);
        }
    }
    /// <summary>
    /// 复制一个UIWidget
    /// </summary>
    public static T CloneWidget<T>(this T widget, GameObject parent = null) where T : UIWidget
    {
        if (!widget) return null;

        GameObject go = (parent ? parent : widget.cachedTransform.parent.gameObject).AddChild(widget.name + "(Clone)");
        Type type = widget.GetType();
        T w = go.AddComponent(type) as T;

        go.layer = widget.cachedGameObject.layer;
        w.cachedTransform.localPosition = widget.cachedTransform.localPosition;
        w.cachedTransform.localScale = widget.cachedTransform.localScale;
        w.cachedTransform.localEulerAngles = widget.cachedTransform.localEulerAngles;

        PropertyInfo[] pis = type.GetTypeProperties(true, true, false);
        foreach (PropertyInfo pi in pis)
        {
            if (pi.CanWrite)
            {
                try { pi.SetValue(w, pi.GetValue(widget, null), null); }
                catch { }
            }
        }

        return w;
    }
    /// <summary>
    /// 禁用启用自身和子级
    /// </summary>
    public static void SetEnable<T>(this T widget, bool enabled) where T : UIWidget
    {
        if (widget)
        {
            UIWidget[] w = widget.GetComponentsInAllChild<UIWidget>();
            for (int i = 0; i < w.Length; i++)w[i].enabled = enabled;
        }
    }

    #endregion

    #region UITexture
    /// <summary>
    /// 同步加载图片
    /// </summary>
    /// <param name="assetName">资源唯一名称</param>
    public static UITextureLoader LoadTexSync(this UITexture utex, string assetName, bool loadDefault = true) { return UITextureLoader.LoadSync(utex, assetName, loadDefault); }
    /// <summary>
    /// 异步加载图片
    /// </summary>
    /// <param name="assetName">资源唯一名称</param>
    public static UITextureLoader LoadTexAsync(this UITexture utex, string assetName, bool loadDefault = true, bool useAnim = true) { return UITextureLoader.LoadAsync(utex, assetName, loadDefault, useAnim, true); }
    /// <summary>
    /// 异步默认图片
    /// </summary>
    public static UITextureLoader LoadTexAsync(this UITexture utex) { return UITextureLoader.LoadAsync(utex, AssetName.DEFAUL_TTEXTURE, true, true, true); }
    /// <summary>
    /// 卸载图片
    /// </summary>
    public static void UnLoadTex(this UITexture utex, bool unloadRes = false) { UITextureLoader.UnLoad(utex, unloadRes); }

    public static void UnLoadAllTex(this IEnumerable<UITexture> texs) { if (texs != null) foreach (UITexture item in texs) item.UnLoadTex(); }
    #endregion

    #region UILabel
    /// <summary>
    /// 点击某个Label时，若是点击的URL，则改变URL的颜色
    /// </summary>
    public static void UrlPressColor(this UILabel label, Color color, bool pressed)
    {
        if (label == null || !label.supportEncoding) return;

        string col = string.Format("[{0}]", NGUIText.EncodeColor(color));
        string text = label.text;
        int index = label.GetCharacterIndexAtPosition(UICamera.lastHit.point, true);
        int linkStart, linkEnd, closingStatement;

        if (index != -1 && index < text.Length)
        {
            linkStart = text.LastIndexOf("[url=", index);

            if (linkStart != -1)
            {
                linkStart += 5;
                linkEnd = text.IndexOf("]", linkStart);

                if (linkEnd != -1)
                {
                    closingStatement = text.IndexOf("[/url]", linkEnd);
                    if (closingStatement == -1)
                    {
                        if (pressed)
                        {
                            text = text.Insert(linkEnd + 1, col);
                        }
                        else
                        {
                            if (text.Substring(linkEnd + 1, 8) == col)
                            {
                                text = text.Remove(linkEnd + 1, 8);
                            }
                        }
                    }
                    else if (closingStatement >= index)
                    {
                        if (pressed)
                        {
                            text = text.Insert(closingStatement, "[-]");
                            text = text.Insert(linkEnd + 1, col);
                        }
                        else
                        {
                            if (text.Substring(closingStatement - 3, 3) == "[-]")
                            {
                                text = text.Remove(closingStatement - 3, 3);
                            }
                            if (text.Substring(linkEnd + 1, 8) == col)
                            {
                                text = text.Remove(linkEnd + 1, 8);
                            }
                        }
                    }
                }
            }
        }
        label.text = text;
    }
    #endregion

    #region UIScrollView
    /// <summary>
    /// 对齐轴心点
    /// </summary>
    /// <param name="pivot">轴心点</param>
    /// <param name="instant">是否立即到达</param>
    public static void ConstraintPivot(this UIScrollView scrollView, UIWidget.Pivot pivot, bool instant, bool hideInactive = false)
    {
        UIPanel panel = scrollView.panel;
        if (panel == null) return;

        scrollView.DisableSpring();
        scrollView.currentMomentum = Vector3.zero;

        Vector3 offset = Vector3.zero;
        Vector4 clip = panel.finalClipRegion;
        Bounds b = NGUIMath.CalculateRelativeWidgetBounds(scrollView.transform, !hideInactive);
        Vector2 clipSoftness = panel.clipping == UIDrawCall.Clipping.SoftClip ? panel.clipSoftness : Vector2.zero;
        
        switch (pivot)
        {
            case UIWidget.Pivot.Left:
                offset = new Vector3(clip.x - clip.z * 0.5f + clipSoftness.x - b.min.x + 1, 0, 0);
                break;
            case UIWidget.Pivot.TopLeft:
                offset = new Vector3(clip.x - clip.z * 0.5f + clipSoftness.x - b.min.x + 1, clip.y + clip.w * 0.5f - clipSoftness.y - b.max.y - 1, 0);
                break;
            case UIWidget.Pivot.Top:
                offset = new Vector3(0, clip.y + clip.w * 0.5f - clipSoftness.y - b.max.y - 1, 0);
                break;
            case UIWidget.Pivot.TopRight:
                offset = new Vector3(clip.x + clip.z * 0.5f - clipSoftness.x - b.max.x - 1, clip.y + clip.w * 0.5f - clipSoftness.y - b.max.y - 1, 0);
                break;
            case UIWidget.Pivot.Right:
                offset = new Vector3(clip.x + clip.z * 0.5f - clipSoftness.x - b.max.x - 1, 0, 0);
                break;
            case UIWidget.Pivot.BottomRight:
                offset = new Vector3(clip.x + clip.z * 0.5f - clipSoftness.x - b.max.x - 1, clip.y - clip.w * 0.5f + clipSoftness.y - b.min.y + 1, 0);
                break;
            case UIWidget.Pivot.Bottom:
                offset = new Vector3(0, clip.y - clip.w * 0.5f + clipSoftness.y - b.min.y + 1, 0);
                break;
            case UIWidget.Pivot.BottomLeft:
                offset = new Vector3(clip.x - clip.z * 0.5f + clipSoftness.x - b.min.x + 1, clip.y - clip.w * 0.5f + clipSoftness.y - b.min.y + 1, 0);
                break;
            case UIWidget.Pivot.Center:
                offset = new Vector3(clip.x - b.center.x, clip.y - b.center.y, 0);
                break;
        }
        if (instant) scrollView.MoveRelative(offset);
        else SpringPanel.Begin(scrollView.gameObject, scrollView.transform.localPosition + offset, 13f);
    }
    /// <summary>
    /// 移动scrollView视口对准位置
    /// </summary>
    /// <param name="localPosition">scrollView的子级坐标</param>
    /// <param name="instant">是否立即到达</param>
    public static void MoveTo(this UIScrollView scrollView, Vector3 localPosition, bool instant)
    {
        UIPanel panel = scrollView.panel;
        if (panel == null) return;

        Bounds b = NGUIMath.CalculateRelativeWidgetBounds(scrollView.transform, true);
        Vector4 clip = panel.finalClipRegion;
        Vector2 pos = localPosition;
        Vector2 size = new Vector2(clip.z * 0.5f, clip.w * 0.5f);

        if (panel.clipping == UIDrawCall.Clipping.SoftClip)
        {
            size.x -= panel.clipSoftness.x;
            size.y -= panel.clipSoftness.y;
        }
        float min = b.min.x + size.x, max = b.max.x - size.x;
        if (min > max) min = max = (min + max) * 0.5f;
        pos.x = Mathf.Clamp(pos.x, min, max);
        min = b.min.y + size.y; max = b.max.y - size.y;
        if (min > max) min = max = (min + max) * 0.5f;
        pos.y = Mathf.Clamp(pos.y, min, max);
        if (instant) scrollView.MoveRelative(new Vector2(clip.x - pos.x, clip.y - pos.y));
        else SpringPanel.Begin(scrollView.gameObject, -pos, 13f);
    }
    #endregion

    #region UITweener
    /// <summary>
    /// 重置动画到最初
    /// </summary>
    /// <param name="direction">初始的方向</param>
    public static void ResetToInit(this UITweener tweener, bool direction = true)
    {
        if (tweener)
        {
            if (tweener.enabled)
            {
                tweener.enabled = false;
                tweener.enabled = true;
            }
            tweener.tweenFactor = direction ? 0f : 1f;
            tweener.Sample(tweener.tweenFactor, false);
        }
    }
    #endregion

    #region UISpriteData
    /// <summary>
    /// 缩放数据
    /// </summary>
    /// <param name="scale"></param>
    public static void Scale(this UISpriteData spd, Vector2 scale)
    {
        spd.x = Mathf.RoundToInt(spd.x * scale.x);
        spd.y = Mathf.RoundToInt(spd.y * scale.y);
        spd.width = Mathf.RoundToInt(spd.width * scale.x);
        spd.height = Mathf.RoundToInt(spd.height * scale.y);

        spd.borderLeft = Mathf.RoundToInt(spd.borderLeft * scale.x);
        spd.borderRight = Mathf.RoundToInt(spd.borderRight * scale.x);
        spd.borderTop = Mathf.RoundToInt(spd.borderTop * scale.y);
        spd.borderBottom = Mathf.RoundToInt(spd.borderBottom * scale.y);

        spd.paddingLeft = Mathf.RoundToInt(spd.paddingLeft * scale.x);
        spd.paddingRight = Mathf.RoundToInt(spd.paddingRight * scale.x);
        spd.paddingTop = Mathf.RoundToInt(spd.paddingTop * scale.y);
        spd.paddingBottom = Mathf.RoundToInt(spd.paddingBottom * scale.y);
    }
    #endregion

}
