using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInput : MonoBehaviour {
    [Header("========= Key setting ========")]
    public string keyUp = "w";
    public string keyDown = "s";
    public string keyLeft = "a";
    public string keyRight = "d";

    public string keyA;
    public string keyB;
    public string keyC;
    public string keyD;
    [Header("========= Output signale ========")]
    public float Dup;
    public float Dright;
    public float Dmag;
    public Vector3 Dvec;

    public bool inputEnable = true;
    public bool run = true;

    [Header("========= Other ========")]
    private float targerDup;
    private float targerDright;
    private float velocityDup;
    private float velocityDright;

    // Use this for initialization
    void Start() {

    }

    // Update is called once per frame
    void Update() {
        targerDup = (Input.GetKey(keyUp) ? 1.0f : 0) - (Input.GetKey(keyDown) ? 1.0f : 0);
        targerDright = (Input.GetKey(keyRight) ? 1.0f : 0) - (Input.GetKey(keyLeft) ? 1.0f : 0);

        if (inputEnable == false) {
            targerDup = 0;
            targerDright = 0;
        }

        Dup = Mathf.SmoothDamp(Dup, targerDup, ref velocityDup, 0.1f);
        Dright = Mathf.SmoothDamp(Dright, targerDright, ref velocityDright, 0.1f);
        Dmag = Mathf.Sqrt((Dup * Dup) + (Dright * Dright));
        Dvec = Dright * transform.right + Dup * transform.forward;

        run = Input.GetKey(keyA);
    }
}
