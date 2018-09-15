using UnityEngine;

public class MomentumMove : MonoBehaviour
{
    public System.Action<GameObject> onFinished;

    Transform mTrans;
    UIWidget widget;

    float momentum;
    float Imomentum;
    Vector3 drect;
    Vector3 axis;
    bool action = false;

    void Start() { mTrans = transform; widget = GetComponent<UIWidget>(); }

    void Update()
    {
        if (!action) return;
        if (Mathf.Abs(momentum) > 0.01f)
        {
            float angle = 0, dis = 0;
            SpringDampen(Mathf.Min(Time.deltaTime, 0.04f), out angle, out dis);
            mTrans.localPosition += drect * dis;
            mTrans.Rotate(axis, angle * 3, Space.Self);
            if (widget) widget.alpha = 20f * momentum / Imomentum;
        }
        else
        {
            momentum = 0;
            if (onFinished != null) onFinished(gameObject);
            else Destroy(gameObject);
            action = false;
        }
    }

    //势的衰减转换为欧拉角与位移的变量
    void SpringDampen(float deltaTime, out float angle, out float dis)
    {
        // Dampening factor applied each millisecond
        if (deltaTime > 1f) deltaTime = 1f;
        float dampeningFactor = 0.995f;
        int ms = Mathf.RoundToInt(deltaTime * 1000f);
        angle = 0;
        dis = 0;
        // Apply the offset for each millisecond
        for (int i = 0; i < ms; ++i)
        {
            // Mimic 60 FPS the editor runs at
            //angle += momentum * 0.002f;
            angle += momentum * 0.05f;
            dis += momentum * 0.05f;
            momentum *= dampeningFactor;
        }
    }

    public float Momentum
    {
        get { return momentum; }
        set { Imomentum = momentum = value; action = true; }
    }

    public void ApplyData(float momentum, Vector3 drect, Vector3 axis, System.Action<GameObject> onFinished = null)
    {
        this.drect = drect;
        this.axis = axis;
        this.onFinished = onFinished;
        this.Momentum = momentum;
    }
}
