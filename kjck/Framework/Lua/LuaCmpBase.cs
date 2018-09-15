#if TOLUA
using UnityEngine;

[RequireComponent(typeof(LuaContainer))]
public class LuaCmpBase : MonoBehaviour
{
    [SerializeField] public LuaContainer luaContainer;

    private void Awake()
    {
        if (luaContainer) return;
        luaContainer = GetComponent<LuaContainer>();
    }
    private void Start() { luaContainer.CallFunction("Start"); }

    private void OnEnable() { luaContainer.CallFunction("OnEnable"); }

    private void OnDisable() { luaContainer.CallFunction("OnDisable"); }
}
#endif