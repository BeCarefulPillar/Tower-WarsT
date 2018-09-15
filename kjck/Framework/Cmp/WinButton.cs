using UnityEngine;
#if TOLUA
using LuaInterface;
#endif

public class WinButton : MonoBehaviour
{
    public enum Action
    {
        None = 0,
        Close = 1,
        Return = 2,
        Refresh = 3,
        Help = 4,
    }

    [SerializeField] private Win mWin;
    [SerializeField] private Action mAction = Action.None;
    [SerializeField] private float mRefreshCd = 0f;
    [System.NonSerialized] private float mNextRefreshTime = 0f;

    void OnClick()
    {
        switch (mAction)
        {
            case Action.Close: mWin.Exit(); return;
            case Action.Refresh:
                if (mRefreshCd > 0)
                {
                    if (mNextRefreshTime > Time.realtimeSinceStartup) return;
                    mNextRefreshTime = Time.realtimeSinceStartup + mRefreshCd;
                    UISpriteTimer.Begin(GetComponent<UISprite>(), mRefreshCd);
                }
                mWin.Refresh();
                return;
            case Action.Return: mWin.Return(); return;
            case Action.Help: mWin.Help(); return;
            default: return;
        }
    }

#if TOLUA
    #region LUA注册
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(WinButton), typeof(MonoBehaviour));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegVar("win", get_Win, set_Win);
        L.RegVar("action", get_Action, set_Action);
        L.RegVar("refreshCD", get_refreshCD, set_refreshCD);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_Win(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(WinButton), 1))
            {
                ToLua.Push(lua, ((WinButton)ToLua.ToObject(lua, 1)).mWin);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: WinButton.getWin");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_Win(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(WinButton), typeof(MonoBehaviour)))
            {
                ((WinButton)ToLua.ToObject(lua, 1)).mWin = ToLua.ToObject(lua, 2) as Win;
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: WinButton.setWin");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_Action(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(WinButton), 1))
            {
                LuaDLL.lua_pushinteger(lua, (int)((WinButton)ToLua.ToObject(lua, 1)).mAction);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: WinButton.getAction");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_Action(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(WinButton), typeof(int)))
            {
                ((WinButton)ToLua.ToObject(lua, 1)).mAction = (Action)((int)LuaDLL.lua_tonumber(lua, 2));
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: WinButton.setAction");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_refreshCD(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(WinButton), 1))
            {
                LuaDLL.lua_pushnumber(lua, ((WinButton)ToLua.ToObject(lua, 1)).mRefreshCd);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: WinButton.get_refreshCD");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_refreshCD(System.IntPtr lua)
    {
        try
        {
            ToLua.CheckArgsCount(lua, 2);
            (ToLua.CheckObject<WinButton>(lua, 1) as WinButton).mRefreshCd = (float)LuaDLL.luaL_checknumber(lua, 2);
            return 0;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int op_Equality(System.IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
            UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
            bool o = arg0 == arg1;
            LuaDLL.lua_pushboolean(L, o);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion
#endif
}