using UnityEngine;
using System;

public abstract class Win : MonoBehaviour
{
    public object param;
    public float tm = 20f;
    public float dt;
    public virtual void OnInit() { }
    public virtual void OnDispose() { }
}