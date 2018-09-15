#if TOLUA
using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

public static class LuaStr
{
    public static void Register(LuaState L)
    {
        L.BeginModule("STR");

        L.RegFunction("Len", Len);
        L.RegFunction("TrimBOM", TrimBOM);
        L.RegFunction("LDP", LDP);
        L.RegFunction("HasInvChar", HasInvisibleChar);
        L.RegFunction("ByteToUTF8", ByteToUTF8);
        L.RegFunction("UTF8ToByte", UTF8ToByte);
        L.RegFunction("Base64ToByte", Base64ToByte);
        L.RegFunction("Base64ToJson", Base64ToJson);
        L.RegFunction("FilterEmoji", FilterEmoji);

        L.EndModule();
    }

    #region 字符串
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Len(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            string str = ToLua.CheckString(L, 1);
            ToLua.Push(L, str == null ? 0 : str.Length);
            return 1;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int TrimBOM(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            ToLua.Push(L, ToLua.CheckString(L, 1).TrimBOM());
            return 1;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LDP(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            LuaDLL.lua_pushnumber(L, SystemExtend.LevenshteinDistancePercent(ToLua.CheckString(L, 1), ToLua.CheckString(L, 2)));
            return 1;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int HasInvisibleChar(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 3);
            ToLua.Push(L, ToLua.CheckString(L, 1).HasInvisibleChar(ToLua.CheckObject<Font>(L, 2) as Font, LuaDLL.luaL_checkinteger(L, 3)));
            return 1;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ByteToUTF8(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count == 1 && TypeChecker.CheckType(L, typeof(byte[]), 1))
            {
                byte[] data = ToLua.ToObject(L, 1) as byte[];
                if (data == null) LuaDLL.lua_pushnil(L);
                else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(int), typeof(int)))
                {
                    ToLua.Push(L, System.Text.Encoding.UTF8.GetString(data, (int)LuaDLL.lua_tonumber(L, 2), (int)LuaDLL.lua_tonumber(L, 3)));
                }
                else
                {
                    ToLua.Push(L, System.Text.Encoding.UTF8.GetString(data));
                }
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UTF8ToByte(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(string), 1))
            {
                string str = ToLua.ToString(L, 1);
                if (str == null) LuaDLL.lua_pushnil(L);
                else ToLua.Push(L, System.Text.Encoding.UTF8.GetBytes(str));
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Base64ToByte(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(string), 1))
            {
                string str = ToLua.ToString(L, 1);
                if (str == null) LuaDLL.lua_pushnil(L);
                else ToLua.Push(L, System.Convert.FromBase64String(str));
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Base64ToJson(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(string), 1))
            {
                string str = ToLua.ToString(L, 1);
                if (str == null) LuaDLL.lua_pushnil(L);
                else
                {
                    byte[] data = System.Convert.FromBase64String(str);
                    if (data.GetLength() > 0)
                    {
                        System.Text.StringBuilder sb = new System.Text.StringBuilder();
                        sb.Append('[');
                        sb.Append(data[0]);
                        for (int i = 1; i < data.Length; i++)
                        {
                            sb.Append(',');
                            sb.Append(data[i]);
                        }
                        sb.Append(']');
                        ToLua.Push(L, sb.ToString());
                    }
                    else
                    {
                        ToLua.Push(L, "[]");
                    }
                }
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
            return 1;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FilterEmoji(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                string str = ToLua.CheckString(L, 1);
                ToLua.Push(L, string.IsNullOrEmpty(str) ? string.Empty : System.Text.RegularExpressions.Regex.Replace(str, @"\p{Cs}", ""));
            }
            else
            {
                ToLua.Push(L, string.Empty);
            }
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