using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ViewLogin : MonoBehaviour {
    public Button pressButton;
    public InputField input;

    void Start() {
        pressButton.onClick.AddListener(Login);
    }

    void Update() {

    }

    void Login() {
        Debug.Log("1111111111");
        pressButton.gameObject.SetActive(false);
        input.gameObject.SetActive(true);
    }
}
