using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using System;

public class LuaContainer : UMonoBehaviour, IDisposable
{
    public LuaTable mLua;
    public string mScriptName;
    public Dictionary<string, LuaFunction> mLuaFunction = new Dictionary<string, LuaFunction>();

    protected virtual void Awake()
    {
        mLua = LuaManager.Ins.GetLuaTable(mScriptName);
        if (!CheckLuaBaseRef(ref mLua))
        {
            Debug.LogErrorFormat("mLua is null");
            Destroy(this);
            return;
        }

        LuaFunction func = mLua.GetLuaFunction("OnLoad");
        if (!CheckLuaBaseRef(ref func))
        {
            Debug.LogErrorFormat("函数{0}.OnLoad不存在", mScriptName);
            Destroy(this);
            return;
        }

        func.BeginPCall();
        func.PushObject(this);
        func.PCall();
        func.EndPCall();
        func.Dispose();
        func = null;

        LuaManager.Ins.AddLuaContainer(this);
    }

    protected virtual void OnDestroy()
    {
        //Dispose();
    }

    public virtual void Dispose()
    {
        LuaFunction func = mLua.GetLuaFunction("OnUnLoad");
        if (CheckLuaBaseRef(ref func))
        {
            func.BeginPCall();
            func.PushObject(this);
            func.PCall();
            func.EndPCall();
            func.Dispose();
            func = null;
        }

        foreach (LuaFunction fun in mLuaFunction.Values)
        {
            if (fun != null)
                fun.Dispose();
        }
        mLuaFunction.Clear();

        mLua.Dispose();
        mLua = null;

        Debug.Log(this+" - Dispose");
    }

    public void BindFunction(params string[] names)
    {
        LuaFunction func;
        LuaFunction old;
        foreach (string name in names)
        {
            if (!string.IsNullOrEmpty(name))
            {
                func = mLua.GetLuaFunction(name);
                if (CheckLuaBaseRef(ref func))
                {
                    if (mLuaFunction.TryGetValue(name, out old))
                        if (CheckLuaBaseRef(ref old))
                            old.Dispose();
                    mLuaFunction.Add(name, func);
                }
            }
        }
    }

    public LuaFunction GetBindFunction(string name)
    {
        if (string.IsNullOrEmpty(name))
            return null;
        LuaFunction func = null;
        if (mLuaFunction.TryGetValue(name, out func))
        {
            if (!CheckLuaBaseRef(ref func))
                mLuaFunction.Remove(name);
            return func;
        }
        return null;
    }

    public static bool CheckLuaBaseRef<T>(ref T lbr) where T : LuaBaseRef
    {
        bool isnull = lbr == null;
        if (isnull || !lbr.IsAlive)
        {
            if (!isnull)
            {
                lbr.Dispose();
                lbr = null;
            }
            return false;
        }
        return true;
    }
}