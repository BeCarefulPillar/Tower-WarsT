#if TOLUA
using System;
using System.Text;
using LuaInterface;
using Kiol.IO;
using Kiol.Util;

public static class LuaAdapter
{
    private static LuaFunction _StatusBarOnTimeout;
    private static void OnStatusBarTimeout(IProgress ip) { if (_StatusBarOnTimeout == null || !_StatusBarOnTimeout.IsAlive) return; _StatusBarOnTimeout.Call(ip); }

    public static void Register(LuaState L)
    {
        L.BeginStaticLibs("GM");
        L.RegVar("instance", get_gameInstance, null);
        L.RegVar("config", get_gameConfig, null);
        L.RegVar("clientUpdateUrl", get_clientUpdateUrl, set_clientUpdateUrl);
        L.RegVar("language", get_language, set_language);
        L.RegFunction("GetOldUserRec", GetObsoleteUsrRec);
        L.EndStaticLibs();

        L.BeginStaticLibs("MsgBox");
        L.RegFunction("Show", MsgBoxShow);
        L.RegFunction("Wait", MsgBoxWait);
        L.RegFunction("Exit", MsgBoxExit);
        L.RegFunction("SetInput", MsgBoxSetInput);
        L.RegFunction("InputHasInvisibleChar", InputHasInvisibleChar);
        L.RegVar("isShow", MsgBoxIsShow, null);
        L.EndStaticLibs();

        L.BeginStaticLibs("StatusBar");
        L.RegFunction("Show", StatusBarShow);
        L.RegFunction("ShowR", StatusBarShowR);
        L.RegFunction("Get", StatusBarGet);
        L.RegFunction("Exit", StatusBarExit);
        L.RegVar("onTimeout", StatusBarGetOnTimeOut, StatusBarSetOnTimeOut);
        L.EndStaticLibs();
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_gameInstance(IntPtr L)
    {
        try
        {
            ToLua.Push(L, Game.instance);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_gameConfig(IntPtr L)
    {
        try
        {
            ToLua.Push(L, Game.config);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_clientUpdateUrl(IntPtr L)
    {
        try
        {
            ToLua.Push(L, Game.clientUpdateUrl);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_clientUpdateUrl(IntPtr L)
    {
        try
        {
            Game.clientUpdateUrl = ToLua.CheckString(L, 1);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_language(IntPtr lua)
    {
        try
        {
            ToLua.Push(lua, L.Language);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_language(IntPtr lua)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(lua))
            {
                L.Language = LuaDLL.luaL_checkinteger(lua, 1);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetObsoleteUsrRec(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                byte[] datas = Encryption.Decrypt(File.ReadFile(ToLua.CheckString(L, 1)));
                if (CRC.CheckAndStripCRC16(ref datas))
                {
                    StringBuilder sb = new StringBuilder(datas.Length * 80);
                    sb.Append('[');
                    for (int i = 0; i < datas.Length; i += 68)
                    {
                        if (i > 0) sb.Append(',');
                        sb.Append('[');
                        sb.Append(BitConverter.ToInt32(datas, i));
                        sb.Append(',');
                        sb.Append(Encoding.UTF8.GetString(datas, i + 4, 32));
                        sb.Append(',');
                        sb.Append(Encoding.UTF8.GetString(datas, i + 36, 32));
                        sb.Append(']');
                    }
                    sb.Append(']');
                    ToLua.Push(L, sb.ToString());
                    return 1;
                }
            }
            LuaDLL.lua_pushnil(L);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StatusBarShow(IntPtr lua) { return StatusBarShow(lua, false); }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StatusBarShowR(IntPtr lua) { return StatusBarShow(lua, true); }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StatusBarGet(IntPtr lua)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(lua);
            if (argCnt == 0)
            {
                ToLua.Push(lua, StatusBar.current); return 1;
            }
            else if (argCnt == 1 && TypeChecker.CheckType(lua, typeof(int), 1))
            {
                ToLua.Push(lua, StatusBar.Get((int)LuaDLL.luaL_checknumber(lua, 1))); return 1;
            }
            LuaDLL.lua_pushnil(lua);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StatusBarExit(IntPtr lua)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(lua);
            if (argCnt == 0) StatusBar.Exit();
            else if (argCnt == 1 && TypeChecker.CheckType(lua, typeof(int), 1))
            {
                StatusBar.Exit((int)LuaDLL.luaL_checknumber(lua, 1));
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    private static int StatusBarShow(IntPtr L, bool returnProcess)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 0)
            {
                StatusBar.TempProcess tp = StatusBar.Show();
                if (returnProcess) { ToLua.Push(L, tp); return 1; }
            }
            else if (count >= 1)
            {
                if (TypeChecker.CheckType(L, typeof(IProgress), 1))
                {
                    IProgress ip = ToLua.ToObject(L, 1) as IProgress;
                    if (ip != null)
                    {
                        bool delay = true;
                        if (count >= 2) delay = LuaDLL.luaL_checkboolean(L, 2);
                        StatusBar.Show(ip, delay);
                    }
                }
                else
                {
                    int id = 0;
                    string msg = string.Empty;
                    float waitTime = StatusBar.DEFAULT_TIMEOUT;
                    bool delay = true;
                    if (TypeChecker.CheckType(L, typeof(int), 1))
                    {
                        id = (int)LuaDLL.lua_tonumber(L, 1);
                        if (count >= 2) msg = ToLua.CheckString(L, 2);
                        if (count >= 3) waitTime = (float)LuaDLL.luaL_checknumber(L, 3);
                        if (count >= 4) delay = LuaDLL.luaL_checkboolean(L, 4);
                    }
                    else if (TypeChecker.CheckType(L, typeof(string), 1))
                    {
                        msg = ToLua.ToString(L, 1);
                        if (count >= 2) waitTime = (float)LuaDLL.luaL_checknumber(L, 2);
                        if (count >= 3) delay = LuaDLL.luaL_checkboolean(L, 3);
                    }
                    StatusBar.TempProcess tp = StatusBar.Show(id, msg, waitTime < 3f ? 3f : waitTime, delay);
                    if (returnProcess) { ToLua.Push(L, tp); return 1; }
                }
            }

            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StatusBarGetOnTimeOut(IntPtr L)
    {
        try
        {
            ToLua.Push(L, _StatusBarOnTimeout);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StatusBarSetOnTimeOut(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                _StatusBarOnTimeout = ToLua.CheckLuaFunction(L, 1);
                StatusBar.onTimeout -= OnStatusBarTimeout;
                StatusBar.onTimeout += OnStatusBarTimeout;
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int MsgBoxShow(IntPtr Lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(Lua);

            if (count > 0 && count <= 6 && TypeChecker.CheckType(Lua, typeof(string), 1))
            {
                string content = ToLua.ToString(Lua, 1);
                string button = string.Empty;
                string checkbox = string.Empty;
                string input = string.Empty;
                bool mexit = false;
                LuaFunction luaback = null;
                switch (count)
                {
                    default:
                    case 1:
                        button = L.Sure;
                        break;
                    case 2:
                        if (TypeChecker.CheckType(Lua, typeof(string), 2))
                        {
                            button = ToLua.ToString(Lua, 2);
                        }
                        else
                        {
                            luaback = ToLua.CheckLuaFunction(Lua, 2);
                            if (luaback == null) throw new ArgumentException("messagebox(string, func) arg2 not match");
                            button = L.Sure;
                        }
                        break;
                    case 3:
                        if (TypeChecker.CheckType(Lua, typeof(string), 2))
                        {
                            button = ToLua.ToString(Lua, 2);
                            if (TypeChecker.CheckType(Lua, typeof(string), 3))
                            {
                                checkbox = ToLua.ToString(Lua, 3);
                            }
                            else
                            {
                                luaback = ToLua.ToLuaFunction(Lua, 3);
                                if (luaback == null) throw new ArgumentException("messagebox(string, string, func) arg3 not match");
                            }
                        }
                        else
                        {
                            throw new ArgumentException("messagebox(string, string, string/func) arg2 not match");
                        }
                        break;
                    case 4:
                        if (TypeChecker.CheckType(Lua, typeof(string), 2))
                        {
                            if (TypeChecker.CheckType(Lua, typeof(string), 3))
                            {
                                luaback = ToLua.ToLuaFunction(Lua, 4);
                                if (luaback == null) throw new ArgumentException("messagebox(string, string, string, func) arg4 not match");
                                checkbox = ToLua.ToString(Lua, 3);
                            }
                            else if (TypeChecker.CheckType(Lua, typeof(bool), 4))
                            {
                                luaback = ToLua.ToLuaFunction(Lua, 3);
                                if (luaback == null) throw new ArgumentException("messagebox(string, string, func, bool) arg3 not match");
                                mexit = LuaDLL.tolua_toboolean(Lua, 4);
                            }
                            else
                            {
                                throw new ArgumentException("messagebox(string, string, func, bool) arg4 not match");
                            }
                            button = ToLua.ToString(Lua, 2);
                        }
                        else
                        {
                            throw new ArgumentException("messagebox(string, string, string/func, func/bool) arg2 not match");
                        }
                        break;
                    case 5:
                        if (TypeChecker.CheckTypes(Lua, 2, typeof(string), typeof(string)))
                        {
                            if (TypeChecker.CheckType(Lua, typeof(string), 4))
                            {
                                luaback = ToLua.ToLuaFunction(Lua, 5);
                                if (luaback == null) throw new ArgumentException("messagebox(string, string, string, string, func) arg3 not match");
                                input = ToLua.ToString(Lua, 4);
                            }
                            else if (TypeChecker.CheckTypes(Lua, 5, typeof(bool)))
                            {
                                luaback = ToLua.ToLuaFunction(Lua, 4);
                                if (luaback == null) throw new ArgumentException("messagebox(string, string, string, func, bool) arg4 not match");
                                mexit = LuaDLL.tolua_toboolean(Lua, 5);
                            }
                            else
                            {
                                throw new ArgumentException("messagebox(string, string, string, func, bool) arg5 not match");
                            }
                            button = ToLua.ToString(Lua, 2);
                            checkbox = ToLua.ToString(Lua, 3);
                        }
                        else
                        {
                            throw new ArgumentException("messagebox(string, string, string, func/bool) arg2/3 not match");
                        }
                        break;
                    case 6:
                        if (TypeChecker.CheckTypes(Lua, 2, typeof(string), typeof(string), typeof(string)))
                        {
                            if (TypeChecker.CheckType(Lua, typeof(bool), 6))
                            {
                                luaback = ToLua.ToLuaFunction(Lua, 5);
                                if (luaback == null) throw new ArgumentException("messagebox(string, string, string, func, bool) arg5 not match");
                            }
                            else
                            {
                                throw new ArgumentException("messagebox(string, string, string, string, func, bool) arg6 not match");
                            }
                        }
                        else
                        {
                            throw new ArgumentException("messagebox(string, string, string, string, func, bool) arg2/3/4 not match");
                        }
                        button = ToLua.ToString(Lua, 2);
                        checkbox = ToLua.ToString(Lua, 3);
                        input = ToLua.ToString(Lua, 4);
                        mexit = LuaDLL.tolua_toboolean(Lua, 6);
                        break;
                }

                MessageBox.ShowBox(content, button, checkbox, input, luaback, mexit);
                return 0;
            }
            else
            {
                throw new ArgumentException("messagebox(string...) arg1 not match");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(Lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int MsgBoxWait(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L) && TypeChecker.CheckType(L, typeof(string), 1))
            {
                MessageBox.Wait(ToLua.ToString(L, 1));
                return 0;
            }
            else
            {
                throw new ArgumentException("WaitMsgox(string...) arg1 not match");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int MsgBoxExit(IntPtr L)
    {
        try
        {
            MessageBox.Exit();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int MsgBoxSetInput(IntPtr L)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(L))
            {
                MessageBox.SetInputValue((int)LuaDLL.luaL_checknumber(L, 1), ToLua.CheckString(L, 2));
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int InputHasInvisibleChar(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                MessageBox.InputHasInvisibleChar((int)LuaDLL.luaL_checknumber(L, 1));
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int MsgBoxIsShow(IntPtr L)
    {
        try
        {
            ToLua.Push(L, MessageBox.IsShow);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
}
#endif