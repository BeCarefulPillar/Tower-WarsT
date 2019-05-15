using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WinLogin : Win
{
    public Button[] btns;

    private void Awake()
    {
        btns[0].onClick.AddListener(() =>
        {
            Debug.Log("xxxxxxxxxxxxxx");
            WM.Open("WinSetting");
        });
    }

    public override void OnInit()
    {
    }

    public override void OnDispose()
    {
    }
}