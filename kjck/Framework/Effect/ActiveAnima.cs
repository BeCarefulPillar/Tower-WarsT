using UnityEngine;

public class ActiveAnima : MonoBehaviour
{
    public enum Style
    {
        Rotate,
        Move,
        Scale,
    }

    [SerializeField] Style style = Style.Move;
    [SerializeField] Vector3 initVelocity = Vector3.zero;
    [SerializeField] bool playOnAwake = true;

    private Vector3 velocity = Vector3.zero;
    private Vector3 acceleration = Vector3.zero;
    private Vector3 angles = Vector3.zero;//用于旋转

    private Transform mTrans;

    private Vector3 oAngle;
    private Vector3 oPosition;
    private Vector3 oScale;

    public float springFactor = 128;
    public float dampFactor = 0.99f;
    public float loop = 0;
    private float loopTime = 0;

    public static ActiveAnima Begin(GameObject target, Vector3 initVelocity, Style style, float loop = 0, float springFactor = 128, float dampFactor = 0.99f)
    {
        ActiveAnima aa = target.GetComponent<ActiveAnima>();
        if (aa != null)
        {
            aa.Restore();
        }
        else
        {
            aa = target.AddComponent<ActiveAnima>();
            aa.SetInitValue();
            aa.angles = aa.oAngle;
        }
        aa.style = style;
        aa.initVelocity = aa.velocity = initVelocity;
        aa.loop = loop;
        aa.springFactor = springFactor;
        aa.dampFactor = dampFactor;
        aa.enabled = true;
        return aa;
    }
    public static void Remove(GameObject target)
    {
        ActiveAnima aa = target.GetComponent<ActiveAnima>();
        if (aa == null) return;
        aa.Restore();
        Destroy(aa);
    }
    public static bool IsPlaying(GameObject target)
    {
        ActiveAnima aa = target.GetComponent<ActiveAnima>();
        return aa && aa.enabled && (aa.loop > 0 || aa.velocity.magnitude >= 3 || aa.acceleration.magnitude >= 3);
    }

    void Start()
    {
        if (playOnAwake) SetInitValue();
        else enabled = false;
    }
    
    void Update()
    {
        if (velocity != Vector3.zero || acceleration != Vector3.zero)
        {
            float dt = Mathf.Clamp(Time.deltaTime, 0, 0.04f);
            switch (style)
            {
                case Style.Scale:
                    acceleration = -(Trans.localScale - oScale) * springFactor;
                    velocity += acceleration * dt;
                    Trans.localScale += velocity * dt;
                    break;
                case Style.Rotate:
                    acceleration = -(angles - oAngle) * springFactor;
                    velocity += acceleration * dt;
                    Trans.localEulerAngles += velocity * dt;
                    angles += velocity * dt;
                    break;
                case Style.Move:
                    acceleration = -(Trans.localPosition - oPosition) * springFactor;
                    velocity += acceleration * dt;
                    Trans.localPosition += velocity * dt;
                    break;
                default:
                    Restore();
                    return;
            }
            velocity = velocity * Mathf.Pow(dampFactor, dt * 200f);
            if (velocity.magnitude < 3f && acceleration.magnitude < 3f) Restore();
        }
        else if (loop > 0)
        {
            if (loopTime > loop)
            {
                velocity = initVelocity;
                loopTime = 0;
            }
            else loopTime += Time.deltaTime;
        }
        else enabled = false;
    }

    public void Restore()
    {
        loopTime = 0;
        velocity = Vector3.zero;
        acceleration = Vector3.zero;
        angles = oAngle;
        if (style == Style.Move) Trans.localPosition = oPosition;
        else if (style == Style.Rotate) Trans.localEulerAngles = oAngle;
        else if (style == Style.Scale) Trans.localScale = oScale;
    }

    public Vector3 InitEulerAngles { get { return oAngle; } set { oAngle = value; } }
    public Vector3 InitPosition { get { return oPosition; } set { oPosition = value; } }
    public Vector3 InitScale { get { return oScale; } set { oScale = value; } }
    public void SetInitValue(Vector3 eulerAngles, Vector3 position, Vector3 scale)
    {
        oAngle = eulerAngles;
        oPosition = position;
        oScale = scale;
    }
    public void SetInitValue()
    {
        oPosition = Trans.localPosition;
        oAngle = Trans.localEulerAngles;
        oScale = Trans.localScale;
    }
    public Transform Trans { get { if (mTrans == null)mTrans = transform; return mTrans; } }
}
