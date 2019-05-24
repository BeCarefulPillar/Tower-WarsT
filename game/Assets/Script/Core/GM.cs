using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GM : MonoBehaviour
{
    public static GM ins = null;

    private void Awake()
    {
        ins = this;
    }
}