using UnityEngine;
using System.Collections.Generic;

public class TranSwirl : MonoBehaviour
{
    private struct Trans
    {
        public Transform transform;
        public float time;
        public Trans(Transform t) { transform = t; time = 0; }
        public override bool Equals(object obj)
        {
            return obj is Trans ? Transform.Equals(transform, ((Trans)obj).transform) : base.Equals(obj);
        }
        public override int GetHashCode()
        {
            return transform ? transform.GetHashCode() : base.GetHashCode();
        }
    }

    public Vector3 axisOfRotation = Vector3.forward;
    public float range = 1f;
    public float angularSpeed = 1f;
    public float suckSpeed = 1f;
    public bool ignoreTimeScale = false;
    [SerializeField] Transform[] transforms;

    Transform mTrans;
    List<Trans> trans;

    void Start()
    {
        mTrans = transform;
        AddTransform(transforms);

    }

    void OnEnable()
    {
        if (transforms == null) enabled = false;
    }

    void Update()
    {
        float time = ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime;
        Vector3 center = mTrans.position;
        int count = trans.Count;
        for (int i = 0; i < count; i++)
        {
            Trans t = trans[i];
            if (!t.transform) continue;
            Vector3 pos = t.transform.position;
            if (Vector3.Distance(pos, center) > range) continue;

            t.time += time;

            //角速度
            Vector3 dre = pos - center;
            t.transform.position = dre.RotateAxis(axisOfRotation, t.time * angularSpeed * time) + center - dre.normalized * suckSpeed * t.time * time;

            trans[i] = t;
        }
    }

    public void AddTransform(params Transform[] ts)
    {
        if (ts != null)
        {
            if (trans == null) trans = new List<Trans>();
            foreach (Transform t in ts)
            {
                if (t && !trans.Exists(tr => { return tr.transform == t; }))
                {
                    trans.Add(new Trans(t));
                }
            }

            enabled = true;
        }
    }

    public void RemoveTransform(params Transform[] ts)
    {
        if (ts != null && trans != null)
        {
            foreach (Transform t in ts)
            {
                int idx = trans.FindIndex(tr => { return tr.transform == t; });
                if (idx >= 0) trans.RemoveAt(idx);
            }
        }
    }

#if UNITY_EDITOR
    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireSphere(transform.position, range);
    }
#endif
}
