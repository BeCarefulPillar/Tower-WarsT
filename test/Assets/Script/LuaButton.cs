using UnityEngine;
using LuaInterface;

public class LuaButton : UMonoBehaviour
{
    [SerializeField]
    private LuaContainer mLuaContainer;

    [SerializeField]
    private string mOnClick;
    [SerializeField]
    private string mOnDoubleClick;

    [System.NonSerialized]
    private object mParam;

    private void Awake()
    {
    }

    public LuaContainer luaContainer
    {
        get
        {
            return mLuaContainer;
        }
        set
        {
            mLuaContainer = value;
        }
    }

    public object param
    {
        get
        {
            return mParam;
        }
        set
        {
            mParam = value;
        }
    }

    private void OnClick()
    {
        if (mLuaContainer == null)
            return;
        LuaFunction func = mLuaContainer.GetBindFunction(mOnClick);
        if (func == null)
            return;

        func.BeginPCall();
        //实例
        func.Push(mParam);
        func.PCall();
        func.EndPCall();
    }

    private void OnDoubleClick()
    {
        if (mLuaContainer == null)
            return;
        LuaFunction func = mLuaContainer.GetBindFunction(mOnDoubleClick);
        if (func == null)
            return;

        func.BeginPCall();
        //实例
        func.Push(mParam);
        func.PCall();
        func.EndPCall();
    }
}