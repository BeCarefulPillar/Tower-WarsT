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

    public string keyJRight;
    public string keyJUp;
    public string keyJLeft;
    public string keyJDown;

    [Header("========= Output signal ========")]
    public float Dup;
    public float Dright;
    public float Dmag;
    public Vector3 Dvec;
    public float Jup;
    public float Jright;

   
    //press signal
    public bool run = true;
    //trigger signal
    public bool jump = true;
    private bool lastJump = false; 

    public bool attack = true;
    public bool lastAttack = true;
    [Header("========= Other ========")]
    public bool inputEnable = true; //flag
    
    private float targerDup;
    private float targerDright;
    private float velocityDup;
    private float velocityDright;

    // Use this for initialization
    void Start() {

    }

    // Update is called once per frame
    void Update() {

        Jup = (Input.GetKey(keyJUp)? 1.0f: 0.0f) - (Input.GetKey(keyJDown)? 1.0f: 0.0f);
        Jright = (Input.GetKey(keyJRight)? 1.0f: 0.0f) - (Input.GetKey(keyJLeft)? 1.0f: 0.0f);


        //所有的转换到数学坐标
        targerDup = (Input.GetKey(keyUp) ? 1.0f : 0) - (Input.GetKey(keyDown) ? 1.0f : 0);
        targerDright = (Input.GetKey(keyRight) ? 1.0f : 0) - (Input.GetKey(keyLeft) ? 1.0f : 0);

        if (inputEnable == false) {
            targerDup = 0;
            targerDright = 0;
        }

        Dup = Mathf.SmoothDamp(Dup, targerDup, ref velocityDup, 0.1f);              //y 
        Dright = Mathf.SmoothDamp(Dright, targerDright, ref velocityDright, 0.1f);  //x
        
        Vector2 tempDAxis = SquareToCricle(new Vector2(Dright, Dup));
        var Dright2 = tempDAxis.x;
        var Dup2 = tempDAxis.y;
        Dmag = Mathf.Sqrt((Dup2 * Dup2) + (Dright2 * Dright2));
        Dvec = Dright2 * transform.right + Dup2 * transform.forward;

        run = Input.GetKey(keyA);

        var newJump = Input.GetKey(keyB);
        if(newJump != lastJump && newJump == true) {
            jump = true;
        } else {
            jump = false;
        }
        lastJump = newJump;

        var newAttack = Input.GetKey(keyC);
        if (newAttack != lastAttack && newAttack == true) {
            attack = true;
        } else {
            attack = false;
        }
        lastAttack = newAttack;
    }

    Vector2 SquareToCricle(Vector2 input) {
        Vector2 output = Vector2.zero;
        output.x = input.x * Mathf.Sqrt(1 - (input.y * input.y) / 2.0f);
        output.y = input.y * Mathf.Sqrt(1 - (input.x * input.x) / 2.0f);
        return output;
    }
}
