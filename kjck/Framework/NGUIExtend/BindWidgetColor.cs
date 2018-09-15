using UnityEngine;
using System.Collections.Generic;

[ExecuteInEditMode]
[RequireComponent(typeof(UIWidget))]
public class BindWidgetColor : MonoBehaviour
{
    public UIWidget bind;
    public Color defaultColor = Color.white;

    private UIWidget mWidget;

    //private void OnEnable() { if (!bind)bind = transform.parent.GetComponent<UIWidget>(); enabled = bind; }

    //private void Start()
    //{
    //    mWidget = GetComponent<UIWidget>();
    //    if (bind == null || bind == mWidget)
    //        bind = mWidget.cachedTransform.parent.GetComponent<UIWidget>();
    //    enabled = bind;
    //}

    //private void Update()
    //{
    //    mWidget.color = bind.color * defaultColor;
    //}

    private void OnEnable()
    {
        if (mWidget == null)
        {
            mWidget = GetComponent<UIWidget>();
        }
        if (bind == null)
        {
            bind = transform.parent.GetComponent<UIWidget>();
        }
        if (mWidget && bind)
        {
            mWidget.onPostFill += OnWidgetFill;
            bind.onPostFill += OnBindFill;
        }
        else
        {
            enabled = false;
        }
    }

    private void OnDisable()
    {
        if (mWidget)
        {
            mWidget.onPostFill -= OnWidgetFill;
        }
        if (bind)
        {
            bind.onPostFill -= OnBindFill;
        }
    }

    private void OnWidgetFill(UIWidget w, int bufferOffset, List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        Color c = bind.color;
        for (int i = bufferOffset; i < cols.Count; i++) cols[i] *= c;
    }

    private void OnBindFill(UIWidget w, int bufferOffset, List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        mWidget.MarkAsChanged();
    }
}