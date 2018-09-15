using UnityEngine;
using LuaInterface;
using System.Collections.Generic;
using UnityEngine.UI;

public class LuaBehaviour : MonoBehaviour
{
    public string lua = string.Empty;

    private void Awake()
    {
        Util.CallMethod(lua, "Awake", gameObject);
    }

    private void Start()
    {
        Util.CallMethod(lua, "Start");
    }

    private void OnEnable()
    {
        Util.CallMethod(lua, "OnEnable");
    }

    private void OnDisable()
    {
        Util.CallMethod(lua, "OnDisable");
    }

    private void OnDestroy()
    {
        Util.CallMethod(lua, "OnDestroy");
        Util.ClearMemory();
    }
}