using UnityEngine;

public class Manager<T> : MonoBehaviour where T : Manager<T>
{
    public static T ins = null;

    public virtual void Init()
    {
        ins = this as T;
    }
}