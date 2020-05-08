using UnityEngine;
using System.Collections;

public class View : MonoBehaviour {
    void OnApplicationQuit() {
        if (GameData.Instance.IsLogin) {
            GameData.Instance.SavePlayer();
            print("save succeed");
        }
    }

}
