using UnityEngine;
using Kiol.Util;

[ExecuteInEditMode]
public class ParticleSwirl : MonoBehaviour
{
    public Vector3 axisOfRotation = Vector3.forward;
    public float range = 1f;
    public float angularSpeed = 1f;
    public float suckSpeed = 1f;
    public bool ignoreTimeScale = false;
    [SerializeField] ParticleSystem[] partieles;

    //ParticleSystem.Particle[] particle;

    Transform mTrans;

    void Start()
    {
        mTrans = transform;
        //particle = new ParticleSystem.Particle[200];
    }

    void OnEnable()
    {
        if (partieles == null)
        {
            ParticleSystem ps = GetComponent<ParticleSystem>();
            if (ps) partieles = new ParticleSystem[1] { ps };
        }
        if (partieles == null) enabled = false;
#if UNITY_EDITOR
        lastTime = UnityEditor.EditorApplication.timeSinceStartup;
#endif
    }

    
#if UNITY_EDITOR
    double lastTime = 0;
    void Update()
    {
        float time = (float)(UnityEditor.EditorApplication.timeSinceStartup - lastTime);
        lastTime = UnityEditor.EditorApplication.timeSinceStartup;
#else
    void Update()
    {
        float time = ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime;
#endif
        Vector3 center = mTrans.position;
        foreach (ParticleSystem ps in partieles)
        {
            if (!ps) continue;

            ParticleSystem.Particle[] particle = new ParticleSystem.Particle[ps.particleCount];

            int count = ps.GetParticles(particle);

            for (int i = 0; i < count; i++)
            {
                ParticleSystem.Particle p = particle[i];
                if (Vector3.Distance(p.position, center) > range) continue;

                //力的方式
                //Plane plane = new Plane(center, p.position, center + axisOfRotation);
                //particle[i].velocity += ((center - p.position).normalized * suckSpeed + plane.normal * angularSpeed) * time;

                //角速度
                Vector3 dre = p.position - center;
                Vector3 v = p.velocity - dre.normalized * suckSpeed * time;
                particle[i].velocity = dre.magnitude > (v * time).magnitude ? v : Vector3.zero;
                particle[i].position = dre.RotateAxis(axisOfRotation, (p.startLifetime - p.remainingLifetime) * angularSpeed * time) + center;
                //particle[i].position = ToolHelper.RotateVector3(dre, axisOfRotation, dt * angularSpeed * time) + center + (particle[i].velocity - dt * dre.normalized * suckSpeed * time) * time;
            }
            
            ps.SetParticles(particle, count);
            particle = null;
        }
    }

    public void AddParticle(params ParticleSystem[] ps)
    {
        if (ps != null)
        {
            if (partieles == null) partieles = ps;
            else partieles = KConvert.PieceArray(partieles, ps);
            
            enabled = true;
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
