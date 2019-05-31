using UnityEngine;
using System.Collections;

public class ActorColider : MonoBehaviour {
    public GameObject model;
    public PlayerInput pi;
    public Rigidbody rigid;
    public float speed = 1.4f;
    public float runMutiply = 2.0f;

    [SerializeField]
    private Animator anim;
    private Vector3 movingVec;
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
        movingVec = pi.Dmag * model.transform.forward * speed * (pi.run ? runMutiply : 1.0f);
    }

    private void FixedUpdate() {
        rigid.position += movingVec * Time.fixedDeltaTime;
    }
}
