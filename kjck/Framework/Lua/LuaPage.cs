#if TOLUA
using System;
using LuaInterface;

public partial class Page : LuaContainer, IPage
{
    private const string Func_OnInit = "OnInit";
    private const string Func_OnShow = "OnShow";
    private const string Func_OnHide = "OnHide";
    private const string Func_Refresh = "Refresh";
    private const string Func_Help = "Help";
    private const string Func_OnDispose = "OnDispose";

    [NonSerialized] private LuaFunction luaOnBind = null;
    [NonSerialized] private LuaFunction luaOnInit = null;
    [NonSerialized] private LuaFunction luaOnShow = null;
    [NonSerialized] private LuaFunction luaOnHide = null;
    [NonSerialized] private LuaFunction luaRefresh = null;
    [NonSerialized] private LuaFunction luaHelp = null;
    [NonSerialized] private LuaFunction luaOnDispose = null;

    protected override void OnBindToLua()
    {
        base.OnBindToLua();

        luaOnInit = GetBindFunction(Func_OnInit);
        luaOnShow = GetBindFunction(Func_OnShow);
        luaOnHide = GetBindFunction(Func_OnHide);
        luaRefresh = GetBindFunction(Func_Refresh);
        luaHelp = GetBindFunction(Func_Help);
        luaOnDispose = GetBindFunction(Func_OnDispose);
    }

    public void Refresh() { CallFunction(ref luaRefresh); }
    public void Help() { CallFunction(ref luaHelp); }

    private void OnBind() { CallFunction(ref luaOnBind); }
    private void OnInit() { CallFunction(ref luaOnInit); }
    private void OnShow() { CallFunction(ref luaOnShow); }
    private void OnHide() { CallFunction(ref luaOnHide); }
    private void OnDispose() { CallFunction(ref luaOnDispose); }

    #region LUA注册
    public new static void Register(LuaState L)
    {
        L.BeginClass(typeof(Page), typeof(LuaContainer));
        L.RegFunction("Init", LuaInit);
        L.RegFunction("Show", LuaShow);
        L.RegFunction("Hide", LuaHide);
        L.RegFunction("Dispose", LuaDispose);
        L.RegFunction("Refresh", LuaRefresh);
        L.RegFunction("Help", LuaHelp);
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegVar("data", get_data, set_data);
        L.RegVar("win", get_win, null);
        L.RegVar("winTable", get_winTable, null);
        L.RegVar("isInit", get_isInit, null);
        L.RegVar("isShow", get_isShow, null);
        L.RegVar("mutex", get_mutex, set_mutex);
        L.EndClass();
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaInit(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count == 1)
            {
                (ToLua.CheckObject<Page>(L, 1) as Page).Init(null);
            }
            if (count == 2)
            {
                (ToLua.CheckObject<Page>(L, 1) as Page).Init(ToLua.ToVarObject(L, 2));
            }
            else
            {
                return LuaDLL.luaL_throw(L, "page.Init args count err");
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaShow(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            (ToLua.CheckObject<Page>(L, 1) as Page).Show();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaHide(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            (ToLua.CheckObject<Page>(L, 1) as Page).Hide();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaDispose(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            (ToLua.CheckObject<Page>(L, 1) as Page).Dispose();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaRefresh(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            (ToLua.CheckObject<Page>(L, 1) as Page).Refresh();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaHelp(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            (ToLua.CheckObject<Page>(L, 1) as Page).Help();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_data(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Page>(L, 1) as Page).mData);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_data(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count > 0)
            {
                (ToLua.CheckObject<Page>(L, 1) as Page).mData = count > 1 ? ToLua.ToVarObject(L, 2) : null;
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to Page.data");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_win(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Page>(L, 1) as Page).mWin);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_winTable(IntPtr L)
    {
        try
        {
            Win win = (ToLua.CheckObject<Page>(L, 1) as Page).mWin;
            if (win)
            {
                ToLua.Push(L, win.luaTable);
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isInit(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Page>(L, 1) as Page).mIsInit);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isShow(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Page>(L, 1) as Page).mIsShow);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_mutex(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Page>(L, 1) as Page).mutex);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_mutex(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Page>(L, 1) as Page).mutex = (int)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int op_Equality(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            LuaDLL.lua_pushboolean(L, (ToLua.ToObject(L, 1) as UnityEngine.Object) == (ToLua.ToObject(L, 2) as UnityEngine.Object));
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion
}
#endif