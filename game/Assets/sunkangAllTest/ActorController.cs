using UnityEngine;
using System.Collections;

public class ActorController : MonoBehaviour {
    public GameObject model;
    public PlayerInput pi;
    public float speed = 1.4f;
    public float runMutiply = 2.0f;
    public float jumpVelocity = 3.0f;
    public float rollVelocity = 3.0f;

    [Space(10)]
    [Header("======== Friction Settion =========")]
    public PhysicMaterial frictionOne;
    public PhysicMaterial frictionZero;

    private Animator anim;
    private Rigidbody rigid;
    private Vector3 planarVec;
    private Vector3 thrustVec;
    private bool canAttack;
    private bool lockPlanar = false;
    private CapsuleCollider col;
    private float lerpTarget;
    private Vector3 deltaPos;
    // Use this for initialization
    void Awake() {
        pi = GetComponent<PlayerInput>();
        anim = model.GetComponent<Animator>();
        rigid = GetComponent<Rigidbody>();
        col = GetComponent<CapsuleCollider>();
    }

    // Update is called once per frame
    void Update() {
        anim.SetFloat("forward", pi.Dmag * Mathf.Lerp(anim.GetFloat("forward"), (pi.run ? 2.0f : 1.0f), 0.3f));//线性差值
        if (rigid.velocity.magnitude > 5.0f) {
            anim.SetTrigger("roll");
        }
        
        if (pi.jump) {
            anim.SetTrigger("jump");
            canAttack = false;
        }

        if (pi.attack && CheckState("ground") &&canAttack) {
            anim.SetTrigger("attack");
        }

        if (pi.Dmag > 0.01f) {
            model.transform.forward = Vector3.Slerp(model.transform.forward, pi.Dvec, 0.3f);//球形差值
        }
        if (lockPlanar == false) {
            planarVec = pi.Dmag * model.transform.forward * speed * (pi.run ? runMutiply : 1.0f);
        }
        
    }

    private void FixedUpdate() {
        rigid.position += deltaPos;
        rigid.velocity = new Vector3(planarVec.x, rigid.velocity.y, planarVec.z) + thrustVec;
        thrustVec = Vector3.zero;
        deltaPos = Vector3.zero;
    }


    private bool CheckState(string stateName, string layerName = "Base Layer") {
        int layerIndex = anim.GetLayerIndex(layerName);
        bool result = anim.GetCurrentAnimatorStateInfo(layerIndex).IsName(stateName);
        return result;
    }


    ///
    /// Message processing block
    /// 
    
    public void OnJumpEnter() {
        pi.inputEnable = false;
        lockPlanar = true;
        thrustVec = new Vector3(0, jumpVelocity, 0);
    }

//     public void OnJumpExit() {
//         pi.inputEnable = true;
//         lockPlanar = false;
//     }

    public void IsGround() {
        anim.SetBool("isGround", true);
    }

    public void IsNotGround() {
        anim.SetBool("isGround", false);
    }

    public void OnGroundEnter() {
        pi.inputEnable = true;
        lockPlanar = false;
        canAttack = true;
        col.material = frictionOne;
    }

    public void OnGroundExit() {
        col.material = frictionZero;
    }

    public void OnFallEnter() {
        pi.inputEnable = false;
        lockPlanar = true;
    }

    public void OnRollEnter() {
        pi.inputEnable = false;
        lockPlanar = true;
        thrustVec = new Vector3(0, rollVelocity, 0);
    }

    public void OnJabEnter() {
        pi.inputEnable = false;
        lockPlanar = true;
    }

    public void OnJabUpdate() {
        thrustVec = model.transform.forward * anim.GetFloat("jabVelocity");
    }

    public void OnAttack1hAEnter() {
        pi.inputEnable = false;
        lerpTarget = 1.0f;
    }

    public void OnAttack1hUpdate() {
        thrustVec = model.transform.forward * anim.GetFloat("attack1hAVelocity");
        float currentWeight = anim.GetLayerWeight(anim.GetLayerIndex("attack"));
        currentWeight = Mathf.Lerp(currentWeight, lerpTarget, 0.5f);
        anim.SetLayerWeight(anim.GetLayerIndex("attack"), currentWeight);
    }

    public void OnAttackIdleEnter() {
        pi.inputEnable = true;
        lerpTarget = 0.0f;
    }

    public void OnAttackIdleUpdate() {
        thrustVec = model.transform.forward * anim.GetFloat("attack1hAVelocity");
        float currentWeight = anim.GetLayerWeight(anim.GetLayerIndex("attack"));
        currentWeight = Mathf.Lerp(currentWeight, lerpTarget, 0.5f);
        anim.SetLayerWeight(anim.GetLayerIndex("attack"), currentWeight);
    }

    public void OnUpdateRM(object _deltaPos) {
        //(Vector3)_deltaPos;
        if (!CheckState("attack1hC", "attack")) {
            return;
        }
        deltaPos += (Vector3)_deltaPos;
    }


}
