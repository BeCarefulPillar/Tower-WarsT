using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(NavMeshAgent))]
public class BU_Unit : MonoBehaviour
{
    public BD_Unit dat;

    private Transform mTrans;
    private GameObject mGo;
    private NavMeshAgent mAgent;
    private Animator mAni;

    public float dt;
    public bool isMe = false;

    private void Awake()
    {
        dat = new BD_Unit();
        dat.isMe = isMe;

        mTrans = transform;
        mAgent = GetComponent<NavMeshAgent>();
        mAni = GetComponent<Animator>();
    }

    private void Update()
    {
        if(dat.isMe)
        {
            //me

            float hor = Input.GetAxis("Horizontal");
            float ver = Input.GetAxis("Vertical");
            //bool space = Input.GetKeyDown(KeyCode.Space);
            //bool ml = Input.GetMouseButtonDown(0);
            //bool mr = Input.GetMouseButtonDown(1);

            mTrans.position += mTrans.right * hor * 1.0f + mTrans.forward * ver * 1.0f;
            if (hor != 0f || ver != 0f)
            {
            }
        }
        else
        {
            //ai

            if (Time.realtimeSinceStartup > dt)
            {
                dt = Time.realtimeSinceStartup + 1f;
                mAgent.destination = new Vector3(Random.Range(-10, 10), Random.Range(-10, 10), 0f);
            }
        }
    }

    public Transform cachedTransform { get { if (mTrans == null) mTrans = transform; return mTrans; } }
    public GameObject cachedGameObject { get { if (mGo == null) mGo = gameObject; return mGo; } }
}