using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OnGroundSensor : MonoBehaviour {
    public CapsuleCollider capcol;

    private float radis;
    private Vector3 point1;
    private Vector3 point2;

	// Use this for initialization
	void Awake () {
		radis = capcol.radius;
	}
	
	// Update is called once per frame
	void FixedUpdate () {
        point1 = transform.position + transform.up * radis;
        point2 = transform.position + transform.up * capcol.height - transform.up * radis;

        Collider[] outputCols = Physics.OverlapCapsule(point1, point2, radis, LayerMask.GetMask("ground"));
        if (outputCols.Length != 0) {
            foreach (var col in outputCols) {
                print("collision:" + col.name);
            }
        }

    }
}
