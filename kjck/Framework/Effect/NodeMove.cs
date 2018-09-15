using UnityEngine;

public class NodeMove : MonoBehaviour
{
    public UIWidget widget;
    public bool loop = false;
    public float loopWait = 1f;
    public Vector3[] points;
    public float[] speeds;

    Transform mTrans;

    bool isInit = false;
    int index = 0;
    int next = 0;
    int last = 0;
    float initDis = 0;
    float dSpd = 0;
    float totalDis = 0;
    float curDis = 0;
    float deltaTime = 0;

    Vector3 initScale;

    void Awake() { mTrans = transform; }

    void Start()
    {
        initScale = mTrans.localScale;
        if (!isInit) Init();
    }

    void Init()
    {
        if (points == null || speeds == null) return;
        int len1 = points.Length;
        int len2 = speeds.Length;
        if (len1 < 3 || len2 < 3 || len1 != len2) return;
        last = len1 - 1;
        index = 0; next = 1;
        mTrans.localPosition = points[0];
        initDis = (points[0] - points[1]).magnitude;
        dSpd = speeds[1] - speeds[0];
        curDis = totalDis = 0;
        for (int i = 0; i < last; i++)
            totalDis += (points[i] - points[i + 1]).magnitude;
        isInit = true;
        deltaTime = 0;
    }

    void Update()
    {
        if (!isInit) return;
        if (index >= last)
        {
            if (loop)
            {
                if (deltaTime < loopWait)
                {
                    deltaTime += Time.deltaTime;
                }
                else
                {
                    deltaTime = 0;
                    Reset();
                }
            }
            return;
        }
        float dt = Mathf.Min(Time.deltaTime, 0.045f);
        float dis = (mTrans.localPosition - points[next]).magnitude;
        float dsp = (1 - Mathf.Min(dis / initDis, 1)) * dSpd;
        float dd = (speeds[index] + dsp) * dt;
        if (dd < dis)
        {
            curDis += dd;
            mTrans.localPosition += (points[next] - mTrans.localPosition).normalized * dd;
        }
        else
        {
            curDis += dis;
            mTrans.localPosition = points[next];
            next++;
            index++;
            if (index < last)
            {
                initDis = (points[next] - points[index]).magnitude;
                dSpd = speeds[next] - speeds[index];
            }
        }
        if (widget)
        {
            widget.alpha = GetCurAlpha();
            widget.cachedTransform.localScale = initScale * GetCurScale();
        }
    }

    float GetCurAlpha()
    {
        float dal = totalDis / 3f;
        float dal2 = dal * 2f;
        if (curDis < dal)
            return curDis / dal;
        else if (curDis > dal2)
            return  (1f - (curDis - dal2) / dal);
        return 1f;
    }
    float GetCurScale()
    {
        float dal = totalDis / 3f;
        float dal2 = dal * 2f;
        if (curDis < dal)
            return 0.7f + 0.3f * curDis / dal;
        else if (curDis > dal2)
            return 0.7f + 0.3f * (1f - (curDis - dal2) / dal);
        return 1f;
    }

    public void Reset()
    {
        isInit = false;
        Init();
    }

    void OnEnable() { Reset(); }

    void OnDisable() { Reset(); }
}
