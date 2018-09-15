using UnityEngine;

[ExecuteInEditMode]
public class BindRectCorner : MonoBehaviour
{
    public UIRect rect;
    public int dre;
    public float offset = 0;

    private Transform mTrans;
    private float lastVal = float.MinValue;

    private void Start()
    {
        mTrans = transform;
        if (rect && rect.cachedTransform == mTrans) rect = null;
        LateUpdate();
    }

    private void LateUpdate()
    {
        if (rect)
        {
            if (dre == 0 || dre == 2)
            {
                float val = rect.worldCorners[dre].x;
                if (val == lastVal) return;
                lastVal = val;
                Vector3 pos = mTrans.position;
                pos.x = val;
                mTrans.position = pos;
                pos = mTrans.localPosition;
                pos.x += offset;
                mTrans.localPosition = pos;
            }
            else if (dre == 1 || dre == 3)
            {
                float val = rect.worldCorners[dre].y;
                if (val == lastVal) return;
                lastVal = val;
                Vector3 pos = mTrans.position;
                pos.y = val;
                mTrans.position = pos;
                pos = mTrans.localPosition;
                pos.y += offset;
                mTrans.localPosition = pos;
            }
        }
    }

    [ContextMenu("Changed")]
    public void MarkAsChanged() { lastVal = float.MinValue; }
}
