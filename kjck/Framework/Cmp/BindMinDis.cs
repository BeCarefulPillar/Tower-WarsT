using UnityEngine;
using System.Collections;

public class BindMinDis : MonoBehaviour
{
    public Transform target;
    public float minDis;

    Transform mTrans;

    void Start()
    {
        mTrans = transform;
        enabled = target;
    }

    void OnEnable() { LateUpdate(); }

    void LateUpdate()
    {
        if (target)
        {
            Vector3 dire = mTrans.localPosition - target.localPosition;
            if (dire.magnitude < minDis)
            {
                mTrans.localPosition = target.localPosition + dire.normalized * minDis;
                iTween it = GetComponent<iTween>();
                if (it) Destroy(it);
            }
        }
    }

    public void Bind(Transform target, float dis)
    {
        this.target = target;
        this.minDis = dis;
    }
}
