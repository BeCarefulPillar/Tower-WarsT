using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WinSetting : Win
{
    public Button btn;

    private void Awake()
    {
        btn.onClick.AddListener(() =>
        {
            Debug.Log("xxxxxxxxxxxxxx");
            WM.Exit();
        });
    }
}