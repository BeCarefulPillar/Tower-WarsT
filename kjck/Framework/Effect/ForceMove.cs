using UnityEngine;

public class ForceMove : MonoBehaviour {
    public Vector3 velocity = Vector3.zero;
    public Vector3 destination = Vector3.zero;
    public Vector3 deviation = new Vector3(10, 10, 10);
    public float forceAmount = 1;
    public bool playOnAwake = false;
    public System.Action<ForceMove> moveOver;
    public object param;

    Transform mTrans;
    bool isPlay = false;
    bool isDone = false;
	//支持中文
	// Use this for initialization
	void Start () {
        mTrans = transform;
        if (playOnAwake) isPlay = true;
	}
	
	// Update is called once per frame
    void Update()
    {
        if (isPlay && !isDone)
        {
            Vector3 dis = destination - mTrans.localPosition;
            Vector3 dv = (2 * dis.normalized - velocity.normalized).normalized * forceAmount * Time.deltaTime;
            velocity += dv;
            mTrans.localPosition += velocity * Time.deltaTime;
            mTrans.localRotation = Quaternion.FromToRotation(Vector3.back, velocity);
            if (Mathf.Abs(dis.x) < deviation.x && Mathf.Abs(dis.y) < deviation.y && Mathf.Abs(dis.z) < deviation.z)
            {
                if (moveOver != null) moveOver(this);
                isDone = true;
            }
        }
    }

    public bool IsDone { get { return isDone; } }

    public void Play() { isPlay = true; }
    public void Pause() { isPlay = false; }
}
