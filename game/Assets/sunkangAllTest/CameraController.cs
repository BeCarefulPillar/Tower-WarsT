using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour {
    public PlayerInput pi;
    public float horizontalSpeed = 100.0f;
    
    private GameObject playerHandle;
    private GameObject cameraHandle;

	// Use this for initialization
	void Awake () {
		cameraHandle = transform.parent.gameObject;
        playerHandle = cameraHandle.transform.parent.gameObject;
	}
	
	// Update is called once per frame
	void Update () {
		playerHandle.transform.Rotate(Vector3.up,pi.Jright * horizontalSpeed * Time.deltaTime);
	}
}
