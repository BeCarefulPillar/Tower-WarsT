using UnityEngine;

public class PathMove : MonoBehaviour
{
    [SerializeField] private Space mSpace = Space.Self;
    [SerializeField] private Vector3[] mNodes;
    [SerializeField] public AnimationCurve move = new AnimationCurve(new Keyframe(0f, 0f, 0f, 1f), new Keyframe(1f, 1f, 1f, 0f));
    [SerializeField] public AnimationCurve alpha = new AnimationCurve(new Keyframe(0f, 1f, 0f, 0f), new Keyframe(1f, 1f, 0f, 0f));
    [SerializeField] public bool playOnAwake = true;
    [SerializeField] public float time = 1f;
    [SerializeField] public bool ignoreTimeScale = false;
    [SerializeField] public float loop = 0f;

    private Transform mTrans;
    private UIWidget widget;
    private float playTime = 0f;
    private bool isPlay = false;
    private int nodeLength = -1;
    private float[] rates;

    void Awake() { mTrans = transform; }

    void OnEnable() { Reset(); }

    void OnDisable() { Reset(); }

    void Start() { if (playOnAwake) Play(); }

    void Update()
    {
        if (!isPlay) return;
        if (nodeLength < 0) { Calculate(); if (!isPlay) return; }

        if (playTime > time)
        {
            if (loop < 0)
            {
                playTime = 0f;
                isPlay = false;
            }
            else if (playTime - time >= loop)
            {
                playTime = 0f;
            }
        }
        else
        {
            float tt = playTime / time;

            float t = MathEx.FlotPart(move.Evaluate(tt));
            Vector3 pos = Path[0];
            for (int i = 1; i < nodeLength; i++)
            {
                if (t <= rates[i])
                {
                    pos = Vector3.Lerp(Path[i - 1], Path[i], (t - rates[i - 1]) / (rates[i] - rates[i - 1]));
                    break;
                }
            }

            if (Space == UnityEngine.Space.Self)
            {
                mTrans.localPosition = pos;
            }
            else
            {
                mTrans.position = pos;
            }

            if (widget) widget.alpha = alpha.Evaluate(tt);
        }
        
        playTime += ignoreTimeScale ? RealTime.deltaTime : Time.deltaTime;
    }

    public void Reset()
    {
        playTime = 0f;
        Calculate();
        widget = GetComponent<UIWidget>();
        if (widget is UITrail) (widget as UITrail).Clear();
        if (nodeLength > 0)
        {
            if (Space == UnityEngine.Space.Self)
            {
                mTrans.localPosition = Path[0];
            }
            else
            {
                mTrans.position = Path[0];
            }
        }
    }

    public void Calculate()
    {
        nodeLength = Path.GetLength();
        if (nodeLength > 1)
        {
            int end = nodeLength - 1;
            float maxDis = 0f; float dis = 0f;
            rates = new float[nodeLength];
            for (int i = 1; i < nodeLength; i++)
            {
                rates[i] = Vector3.Distance(Path[i], Path[i - 1]);
                maxDis += rates[i];
            }
            rates[0] = 0f; rates[end] = 1f;
            for (int i = 1; i < end; i++)
            {
                dis += rates[i];
                rates[i] = dis / maxDis;
            }
        }
        if (isPlay && nodeLength < 2) isPlay = false;
    }

    public void Play() { isPlay = true; }

    public void Pause() { isPlay = false; }

    public void Stop() { isPlay = false; Reset(); }

    public Vector3 this[int index]
    {
        get
        {
            return mNodes[index];
        }
        set
        {
            mNodes[index] = value;
            nodeLength = -1;
        }
    }

    public Vector3[] Path { get { return mNodes; } }

    public Space Space
    {
        get { return mSpace; }
        set
        {
            if (mSpace != value)
            {
                mSpace = value;
                if (transform.parent)
                {
                    int len = Path.GetLength();
                    if (len > 0)
                    {
                        Matrix4x4 matrix = (Space == Space.Self) ? transform.parent.worldToLocalMatrix : transform.parent.localToWorldMatrix;
                        for (int i = 0; i < len; i++) Path[i] = matrix.MultiplyPoint3x4(Path[i]);
                    }
                }
            }
        }
    }

#if UNITY_EDITOR
    void OnDrawGizmosSelected()
    {
        int len = Path.GetLength();
        if (len > 1)
        {
            Gizmos.matrix = (Space == UnityEngine.Space.Self && transform.parent) ? transform.parent.localToWorldMatrix : Matrix4x4.identity; ;
            Gizmos.color = Color.cyan;
            for (int i = 1; i < len; i++) Gizmos.DrawLine(Path[i - 1], Path[i]);
        }
    }
#endif
}
