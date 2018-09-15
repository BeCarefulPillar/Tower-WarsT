using UnityEngine;

public class BindLocalPosition : MonoBehaviour
{
    public Transform target;
    public Vector3 dev;

    Transform mTrans;

    void Awake()
    {
        mTrans = transform;
        enabled = target;
    }

    void OnEnable() { LateUpdate(); }

    void LateUpdate()
    {
        mTrans.localPosition = target.localPosition + dev;
    }
}
