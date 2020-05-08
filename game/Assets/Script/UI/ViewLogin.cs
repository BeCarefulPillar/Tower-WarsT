using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class ViewLogin : MonoBehaviour {
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
        SceneManager.LoadScene("gameTest_SK");
    }
} 
