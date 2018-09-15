using UnityEngine;

[ExecuteInEditMode]
public class BindPosition : MonoBehaviour
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
        mTrans.position = target.position + dev;
    }
}
