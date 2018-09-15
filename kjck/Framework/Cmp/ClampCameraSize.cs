using UnityEngine;

[RequireComponent(typeof(Camera))][ExecuteInEditMode]
public class ClampCameraSize : MonoBehaviour
{
    public ClampScale3D clamp3d;
    private Camera mCam;

#if !UNITY_EDITOR
    void Start()
    {
        mCam = GetComponent<Camera>();
        if (mCam == null || !mCam.orthographic)
        {
            Destroy(this); 
            return;
        }
        if (clamp3d)mCam.orthographicSize = clamp3d.Scale.z;
    }
#endif

    void LateUpdate()
    {
        if (clamp3d == null) return;
#if UNITY_EDITOR
        if (mCam == null) mCam = GetComponent<Camera>();
#endif
        if (mCam.orthographicSize != clamp3d.Scale.z) mCam.orthographicSize = clamp3d.Scale.z;
    }
}
