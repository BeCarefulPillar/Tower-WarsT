#if TOLUA
using UnityEngine;

[RequireComponent(typeof(LuaContainer))]
public class LuaCmpApp : MonoBehaviour
{
    [SerializeField] public LuaContainer luaContainer;

    private void Awake()
    {
        if (luaContainer) return;
        luaContainer = GetComponent<LuaContainer>();
    }

    private void OnApplicationFocus(bool focusStatus)
    {
        luaContainer.CallFunction("OnApplicationFocus", focusStatus);
    }

    private void OnApplicationPause(bool pause)
    {
        luaContainer.CallFunction("OnApplicationPause", pause);
    }

    private void OnApplicationQuit()
    {
        luaContainer.CallFunction("OnApplicationQuit");
    }
}
#endif