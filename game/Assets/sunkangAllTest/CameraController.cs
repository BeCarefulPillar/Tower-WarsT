using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour {
    public PlayerInput pi;
    public float horizontalSpeed = 100.0f;
    public float verticalSpeed = 80.0f;
    public float cameraDampValue = 0.1f;

    private GameObject playerHandle;
    private GameObject cameraHandle;
    private float tempRulerX;
    private GameObject model;
    private new GameObject camera;

    private Vector3 cameraDampVelocity;
	// Use this for initialization
	void Awake () {
		cameraHandle = transform.parent.gameObject;
        playerHandle = cameraHandle.transform.parent.gameObject;
        tempRulerX = 20;
        model = playerHandle.GetComponent<ActorController>().model;
        camera = Camera.main.gameObject;
	}
	
	// Update is called once per frame
	void FixedUpdate () {

        Vector3 tempModelEuler = model.transform.eulerAngles;

		playerHandle.transform.Rotate(Vector3.up, pi.Jright * horizontalSpeed * Time.fixedDeltaTime);
        tempRulerX -= pi.Jup * verticalSpeed * Time.fixedDeltaTime;
        tempRulerX = Mathf.Clamp(tempRulerX,-40,30);
        cameraHandle.transform.localEulerAngles = new Vector3(tempRulerX, 0, 0);
        model.transform.eulerAngles = tempModelEuler;

        camera.transform.position = Vector3.SmoothDamp(camera.transform.position, transform.position, ref cameraDampVelocity, cameraDampValue);
        //camera.transform.position = Vector3.Lerp(camera.transform.position, transform.position, 0.2f);
        camera.transform.eulerAngles = transform.eulerAngles;
	}
}
