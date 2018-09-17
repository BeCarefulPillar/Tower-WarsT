using UnityEngine;
using LuaInterface;

public class LuaContainer : MonoBehaviour
{
    [SerializeField]
    private string mScriptName;
    private LuaTable mLua;
    private readonly string FUNC_ONLOAD = "OnLoad";
    private readonly string FUNC_ONUNLOAD = "OnUnLoad";
    private void Awake()
    {
        mLua = Game.Ins.LuaMgr.GetLuaState().GetTable(mScriptName, false);
        if (mLua == null)
        {
            Debug.LogError(name + "LuaContainer error!!!");
            return;
        }
        CallMethod(FUNC_ONLOAD);
    }
    public LuaFunction GetLuaFunction(string nm)
    {
        return mLua.GetLuaFunction(nm);
    }
    public void CallMethod(string nm)
    {
        LuaFunction func = mLua.GetLuaFunction(nm);
        if (func == null)
            return;
        func.BeginPCall();
        func.PushObject(this);
        func.PCall();
        func.EndPCall();
        func.Dispose();
        func = null;
    }
    private void OnDestroy()
    {
        CallMethod(FUNC_ONUNLOAD);
        mLua.Dispose();
        mLua = null;
    }
}