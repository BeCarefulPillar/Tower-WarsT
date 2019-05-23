using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour {
    private Vector3 mMovement;
    private Rigidbody mPlayerRigidbody;

    public float speed = 8;
    void Start() {
        mPlayerRigidbody = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update() {
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");

        PlayerMove(h, v);

        if (h != 0 || v != 0) {
            Rotating(h,v);
        }
        //         if (Input.GetMouseButtonDown(0)) {
        //             Ray ray =Camera.main.ScreenPointToRay(Input.mousePosition);
        //             RaycastHit hit;
        //             if(Physics.Raycast(ray, out hit)){ 
        //                 GetComponent<UnityEngine.AI.NavMeshAgent>().destination = hit.point;    
        //             } 
        //          }
    }

    void PlayerMove(float h, float v) {
        mMovement.Set(h, 0f, v);
        mMovement = mMovement.normalized * speed * Time.deltaTime;
        mPlayerRigidbody.MovePosition(transform.position + mMovement);
    }

    void Rotating(float hor, float ver) {
        Vector3 dir = new Vector3(hor, 0, ver);
        Quaternion quaDir = Quaternion.LookRotation(dir, Vector3.up);
        Quaternion newRotation = Quaternion.Lerp(transform.rotation, quaDir, Time.deltaTime * 3.0f);
        mPlayerRigidbody.MoveRotation(newRotation);
    }

}