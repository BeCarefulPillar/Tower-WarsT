using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInput : MonoBehaviour {
    public string keyUp = "w";
    public string keyDown = "s";
    public string keyLeft = "a";
    public string keyRight = "d";

    public float Dup;
    public float Dright;
    public bool inputEnable = true;

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
        
        if(inputEnable == false) {
            targerDup = 0;
            targerDright = 0;
        }

        Dup = Mathf.SmoothDamp(Dup, targerDup, ref velocityDup, 0.1f);
        Dright = Mathf.SmoothDamp(Dright, targerDright, ref velocityDright, 0.1f);
    }
}
