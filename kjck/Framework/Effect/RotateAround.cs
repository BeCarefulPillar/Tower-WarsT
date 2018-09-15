using UnityEngine;

public class RotateAround : MonoBehaviour
{
    public Vector3 destination = Vector3.zero;
    public float angularSpeed = Mathf.PI * 2;
    public float radiusSpeed = 20;

    public bool stopParticle = true;

    Transform mTrans;

    void Start()
    {
        mTrans = transform;
    }

    void Update()
    {
        Vector3 dre = mTrans.localPosition - destination;

        Vector3 vv = dre.normalized * radiusSpeed * Time.deltaTime;

        if (dre.magnitude <= vv.magnitude)
        {
            mTrans.localPosition = destination;
            enabled = false;
            if (stopParticle)
            {
                ParticleSystem[] ps = this.GetComponentsInAllChild<ParticleSystem>();
                foreach (ParticleSystem p in ps) p.Stop();
                UIParticle[] ups = this.GetComponentsInAllChild<UIParticle>();
                foreach (UIParticle p in ups) p.Stop();
            }
            return;
        }

        mTrans.localPosition = dre.RotateZ(angularSpeed * Time.deltaTime) + destination - vv;
    }
}
