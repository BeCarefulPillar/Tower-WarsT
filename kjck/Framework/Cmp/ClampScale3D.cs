using UnityEngine;

[ExecuteInEditMode]
public class ClampScale3D : MonoBehaviour
{
    private float TAN_30 = 0.57735f;

    public bool once = true;

    Transform mCam;
    Transform mTrans;
    float z = 0;

#if !UNITY_EDITOR
    void Start()
    {
        mTrans = transform;
        Camera cam = NGUITools.FindCameraForLayer(gameObject.layer);
        if (cam == null || cam.orthographic)
        {
            Destroy(this); 
            return;
        }
        mCam = cam.transform;
        z = mTrans.position.z;
        ClampScale();
        if (once) Destroy(this);
    }
#endif

    void LateUpdate()
    {
#if UNITY_EDITOR
        if (mTrans == null) mTrans = transform;
        if (mTrans.position.z != z)
        {
            z = mTrans.position.z;
            if (mCam == null)
            {
                Camera cam = NGUITools.FindCameraForLayer(gameObject.layer);
                
                if (cam == null || cam.orthographic)
                {
                    //Debug.LogWarning("Camera 不存在或不是3D镜头");
                    return;
                }
                mCam = cam.transform;
            }
            
            ClampScale();
        }
#else
        if (!once && mTrans.position.z != z)
        {
            z = mTrans.position.z;
            ClampScale();
        }
#endif
    }

    [ContextMenu("ClampScale")]
    public void ClampScale()
    {
        float wd = z - mCam.position.z;
        float ws = wd > 0 ? wd * TAN_30 : 0.001f;

        Vector3 scale = Vector3.one;
        Transform trans = mTrans.parent;
        while (true)
        {
            if (trans != null && trans.GetComponent<UIRoot>() == null)
            {
                Vector3 ts = trans.localScale;
                scale.x *= ts.x;
                scale.y *= ts.y;
                scale.z *= ts.z;
                trans = trans.parent;
            }
            else break;
        }

        mTrans.localScale = new Vector3(ws / scale.x, ws / scale.y, ws / scale.z);
    }

    public Vector3 Scale { get { return mTrans ? mTrans.localScale : Vector3.one; } }
}
