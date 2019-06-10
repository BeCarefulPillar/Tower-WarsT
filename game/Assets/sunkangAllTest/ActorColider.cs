using UnityEngine;
using System.Collections;

public class ActorColider : MonoBehaviour {
    public GameObject model;
    public PlayerInput pi;
    public float speed = 1.4f;
    public float runMutiply = 2.0f;
    public float jumpVelocity = 3.0f;

    [SerializeField]
    private Animator anim;
    private Rigidbody rigid;
    private Vector3 planarVec;
    private Vector3 thrustVec;

    private bool lockPlanar = false;
    // Use this for initialization
    void Awake() {
        pi = GetComponent<PlayerInput>();
        anim = model.GetComponent<Animator>();
        rigid = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update() {
        anim.SetFloat("forward", pi.Dmag * Mathf.Lerp(anim.GetFloat("forward"), (pi.run ? 2.0f : 1.0f), 0.3f));//线性差值
        if (pi.jump) {
            anim.SetTrigger("jump");
        }

        if (pi.Dmag > 0.01f) {
            model.transform.forward = Vector3.Slerp(model.transform.forward, pi.Dvec, 0.3f);//球形差值
        }
        if (lockPlanar == false) {
            planarVec = pi.Dmag * model.transform.forward * speed * (pi.run ? runMutiply : 1.0f);
        }
    }

    private void FixedUpdate() {
        //rigid.position += planarVec * Time.fixedDeltaTime;
        rigid.velocity = new Vector3(planarVec.x, rigid.velocity.y, planarVec.z) + thrustVec;
        thrustVec = Vector3.zero;
    }

    public void OnJumpEnter() {
        pi.inputEnable = false;
        lockPlanar = true;
        thrustVec = new Vector3(0, jumpVelocity, 0);
    }

    public void OnJumpExit() {
        pi.inputEnable = true;
        lockPlanar = false;
    }
}
