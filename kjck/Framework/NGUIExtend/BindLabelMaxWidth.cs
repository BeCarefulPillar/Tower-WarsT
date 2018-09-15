using UnityEngine;

[ExecuteInEditMode]
public class BindLabelMaxWidth : MonoBehaviour
{
    public UIRect bind;
    public int offset = 0;
    public UILabel label;

    private void Start()
    {
        if (label == null) label = GetComponent<UILabel>();
        if (bind == label) bind = null;
        LateUpdate();

    }

    private void LateUpdate()
    {
        if (bind)
        {
            label.overflowWidth = Mathf.CeilToInt(Mathf.Abs(bind.localCorners[0].x - bind.localCorners[2].x)) + offset;
        }
    }
}
