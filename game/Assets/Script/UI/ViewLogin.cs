using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Data;
using MySql.Data.MySqlClient;


public class ViewLogin : View {
    public Button pressButton;
    public InputField input;
    public Button loginButton;
    void Start() {
        pressButton.onClick.AddListener(Login);
        loginButton.onClick.AddListener(LoginGame);
    }

    void Update() {

    }

    void Login() {
        pressButton.gameObject.SetActive(false);
        input.gameObject.SetActive(true);
    }

    void LoginGame() {
        var str = input.text;
        if(str == "") {
            return;
        }
        MysqlMethod mysqlMethod = new MysqlMethod();
        mysqlMethod.GetAccountPlayer(str);
        
        loginButton.enabled = false;
        Debug.Log("login success");
    }
} 
