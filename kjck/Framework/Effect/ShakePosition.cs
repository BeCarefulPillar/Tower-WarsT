using UnityEngine;

public class ShakePosition : MonoBehaviour
{
    [SerializeField] public Vector3 amount;
    [SerializeField] public float time;

    Vector3 initPos = Vector3.zero;
    bool isLocal = true;
    Transform mTrans;
    float curTime;

    void Start()
    {
        Init();
    }

    public void Init()
    {
        if (!mTrans)
        {
            mTrans = transform;
            initPos = mTrans.position;
        }
        curTime = 0f;
        mTrans.position = initPos;
    }

    void Update()
    {
        if (curTime < time)
        {
            float v = 1f - curTime / time;
            //float v = Mathf.Pow(2f, -10f * curTime / time);
            Vector3 pos = new Vector3(Random.Range(-amount.x * v, amount.x * v), Random.Range(-amount.y * v, amount.y * v), Random.Range(-amount.z * v, amount.z * v));
            if (isLocal)mTrans.localPosition += pos;
            else mTrans.position += pos;
        }
        else
        {
            enabled = false;
            Destroy(this);
        }

        curTime += Time.deltaTime;
    }

    void OnDisable()
    {
        Init();
        mTrans = null;
        
    }

    public static ShakePosition Begin(GameObject target, Vector3 amount, float time, bool islocal = true)
    {
        if (target)
        {
            ShakePosition sp = target.GetComponent<ShakePosition>() ?? target.AddComponent<ShakePosition>();
            sp.time = time;
            sp.amount = amount;
            sp.isLocal = islocal;
            sp.Init();
            sp.enabled = true;
            return sp;
        }
        return null;
    }
}
