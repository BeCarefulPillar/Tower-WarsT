#if TOLUA
using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;
using Kiol.Util;

public static class LuaTool
{
    public static void Register(LuaState L)
    {
        L.BeginModule("CS");
        L.RegFunction("RunOnThread", RunOnThread);
        L.RegFunction("RunOnMainThread", RunOnMainThread);
        L.RegFunction("RunOnMainThreadAsync", RunOnMainThreadAsync);
        L.RegFunction("onMainThread", get_onMainThread);
        //L.RegVar("onMainThread", get_onMainThread, null);
        L.RegFunction("ThreadSleep", ThreadSleep);
        L.RegFunction("Invoke", Invoke);
        
        L.RegFunction("Timestamp", GetTimestamp);

        L.RegFunction("NameToLayer", NameToLayer);

        L.RegFunction("GetBit", GetBit);
        L.RegFunction("Base64ToTable", Base64ToTable);
        L.RegFunction("MD5", GetMD5);
        L.RegFunction("Encrypt", Encrypt);
        L.RegFunction("Decrypt", Decrypt);
        L.RegFunction("DecryptText", DecryptText);
        L.RegFunction("Compress", Compress);
        L.RegFunction("UnCompress", UnCompress);
        L.RegFunction("UnCompressText", UnCompressText);

        L.RegFunction("E2I", Enum2Int);
        L.RegFunction("ToEnum", ToEnum);

        L.RegFunction("DesGo", DesGo);
        L.RegFunction("IsGo", IsGo);
        L.RegFunction("NotNull", NotNull);

        L.RegFunction("IsMatchCnString", IsMatchCnString);

        L.EndModule();

        L.BeginStaticLibs("BGM");
        L.RegFunction("Play", PlayBGM);
        L.RegFunction("PlaySOE", PlaySOE);
        L.RegFunction("Quite", Quite);
        L.RegVar("volume", get_BGMVolume, set_BGMVolume);
        L.RegVar("mute", get_BGMMute, set_BGMMute);
        L.RegVar("soeVolume", get_SOEVolume, set_SOEVolume);
        L.EndStaticLibs();
    }

    #region CSTool

    #region 日期时间

    private static readonly DateTime DT_O_UTC = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
    private static readonly DateTime DT_O_LOCAL = TimeZone.CurrentTimeZone.ToLocalTime(DT_O_UTC);

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetTimestamp(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1)
            {
                if (TypeChecker.CheckType(L, typeof(string), 1))
                {
                    DateTime dt;
                    if (DateTime.TryParse(ToLua.ToString(L, 1), out dt))
                    {
                        LuaDLL.lua_pushnumber(L, (dt - DT_O_LOCAL).TotalSeconds); return 1;
                    }
                }
                else if (TypeChecker.CheckType(L, typeof(DateTime), 1))
                {
                    LuaDLL.lua_pushnumber(L, ((DateTime)ToLua.ToObject(L,1) - DT_O_LOCAL).TotalSeconds); return 1;
                }

                LuaDLL.lua_pushnil(L); return 1;
            }
            else
            {
                LuaDLL.lua_pushnumber(L, (DateTime.UtcNow - DT_O_UTC).TotalSeconds); return 1;
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region 线程相关
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int RunOnThread(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1)
            {
                LuaFunction func = ToLua.CheckLuaFunction(L, 1);
                if (func == null) return 0;
                if (count == 1)
                {
                    ThreadManager.Run(func.Call);
                }
                else if (count == 2)
                {
                    ThreadManager.Run(func.Call, ToLua.ToVarObject(L, 2));
                }
                else if (count > 2)
                {
                    object[] args = new object[count - 2];
                    for (int i = 3; i <= count; i++) args[i - 3] = ToLua.ToVarObject(L, i);
                    ThreadManager.Task task = new ThreadManager.Task();
                    task.Init(func, args);
                    ThreadManager.Run(task);
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
    private static int RunOnMainThread(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1)
            {
                LuaFunction func = ToLua.CheckLuaFunction(L, 1);
                if (func == null) return 0;
                if (count == 1)
                {
                    ThreadManager.RunOnMainThread(func);
                }
                else if (count == 2)
                {
                    ThreadManager.RunOnMainThread(func, ToLua.ToVarObject(L, 2));
                }
                else if (count == 3)
                {
                    ThreadManager.RunOnMainThread(func, ToLua.ToVarObject(L, 2), ToLua.ToVarObject(L, 3));
                }
                else if (count > 2)
                {
                    object[] args = new object[count - 2];
                    for (int i = 3; i <= count; i++) args[i - 3] = ToLua.ToVarObject(L, i);
                    ThreadManager.RunOnMainThread(func, args);
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
    private static int RunOnMainThreadAsync(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1)
            {
                LuaFunction func = ToLua.CheckLuaFunction(L, 1);
                if (func == null) return 0;
                if (count == 1)
                {
                    ThreadManager.RunOnMainThreadAsync(func);
                }
                else if (count == 2)
                {
                    ThreadManager.RunOnMainThreadAsync(func, ToLua.ToVarObject(L, 2));
                }
                else if (count == 3)
                {
                    ThreadManager.RunOnMainThreadAsync(func, ToLua.ToVarObject(L, 2), ToLua.ToVarObject(L, 3));
                }
                else if (count > 2)
                {
                    object[] args = new object[count - 2];
                    for (int i = 3; i <= count; i++) args[i - 3] = ToLua.ToVarObject(L, i);
                    ThreadManager.RunOnMainThreadAsync(func, args);
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
    private static int get_onMainThread(IntPtr L)
    {
        try
        {
            ToLua.Push(L, ThreadManager.onMainThread);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ThreadSleep(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                int ms = (int)LuaDLL.luaL_checknumber(L, 1);
                if (ms > 0) System.Threading.Thread.Sleep(ms);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Invoke(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 2)
            {
                LuaFunction func = ToLua.CheckLuaFunction(L, 1);
                if (func == null) return 0;
                if (count == 2)
                {
                    LuaManager.Invoke(func, (float)LuaDLL.luaL_checknumber(L, 2));
                }
                else
                {
                    object[] args = new object[count - 2];
                    for (int i = 3; i <= count; i++) args[i - 3] = ToLua.ToVarObject(L, i);
                    LuaManager.Invoke(func, (float)LuaDLL.luaL_checknumber(L, 2), args);
                }
                return 0;
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: CS.Invoke");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    
    #endregion

    #region 加密压缩
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetBit(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 2)
            {
                int val = (int)LuaDLL.luaL_checknumber(L, 1);
                if (val == 0)
                {
                    LuaDLL.lua_pushboolean(L, false);
                }
                else
                {
                    int bit = (int)LuaDLL.luaL_checknumber(L, 2);
                    LuaDLL.lua_pushboolean(L, (val & (1 << bit)) != 0);
                }
            }
            else
            {
                LuaDLL.lua_pushboolean(L, false);
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Base64ToTable(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                string b64 = ToLua.CheckString(L, 1);
                if (string.IsNullOrEmpty(b64)) return 0;
                byte[] data = Convert.FromBase64String(b64);
                LuaDLL.lua_createtable(L, 0, 0);
                for (int i = 0; i < data.Length; i++)
                {
                    for (int j = 7; j >= 0; j--)
                    {
                        if (((data[i] >> j) & 1) == 1)
                        {
                            LuaDLL.lua_pushnumber(L, (i * 8) + 8 - j);
                            LuaDLL.lua_pushboolean(L, 1);
                            LuaDLL.lua_rawset(L, -3);
                        }
                    }
                }
                return 1;
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetMD5(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L) && TypeChecker.CheckType(L, typeof(string), 1))
            {
                ToLua.Push(L, MD5.GetMd5String(ToLua.ToString(L, 1)));
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
    private static int Encrypt(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1)
            {
                if (TypeChecker.CheckType(L, typeof(string), 1))
                {
                    ToLua.Push(L, Encryption.Encrypt(ToLua.ToString(L, 1)));
                }
                else if (TypeChecker.CheckType(L, typeof(byte[]), 1))
                {
                    ToLua.Push(L, Encryption.Encrypt(ToLua.ToObject(L, 1) as byte[]));
                }
                else
                {
                    LuaDLL.lua_pushnil(L);
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
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Decrypt(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(byte[]), 1))
            {
                ToLua.Push(L, Encryption.Decrypt(ToLua.ToObject(L, 1) as byte[]));
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
    private static int DecryptText(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(byte[]), 1))
            {
                ToLua.Push(L, Encryption.DecryptStr(ToLua.ToObject(L, 1) as byte[]));
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
    private static int Compress(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1)
            {
                if (TypeChecker.CheckType(L, typeof(string), 1))
                {
                    ToLua.Push(L, Encryption.Compress(ToLua.ToString(L, 1), count == 2 ? LuaDLL.luaL_checkinteger(L, 2) : 0));
                }
                else if (TypeChecker.CheckType(L, typeof(byte[]), 1))
                {
                    ToLua.Push(L, Encryption.Compress(ToLua.ToObject(L, 1) as byte[], count == 2 ? LuaDLL.luaL_checkinteger(L, 2) : 0));
                }
                else
                {
                    LuaDLL.lua_pushnil(L);
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
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnCompress(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1 && TypeChecker.CheckType(L, typeof(byte[]), 1))
            {
                ToLua.Push(L, Encryption.Decompress(ToLua.ToObject(L, 1) as byte[], count == 2 ? LuaDLL.luaL_checkinteger(L, 2) : 0));
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
    private static int UnCompressText(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(byte[]), 1))
            {
                ToLua.Push(L, Encryption.DecompressStr(ToLua.ToObject(L, 1) as byte[], count == 2 ? LuaDLL.luaL_checkinteger(L, 2) : 0));
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
    #endregion

    #region 枚举
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Enum2Int(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count == 1 && TypeChecker.CheckType(L, typeof(Enum), 1))
            {
                ToLua.Push(L, Convert.ChangeType(ToLua.ToObject(L, 1), TypeCode.Int32));
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
    private static int ToEnum(IntPtr L)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(L))
            {
                Type type;
                if (TypeChecker.CheckType(L, typeof(string), 2))
                {
                    type = Type.GetType(ToLua.ToString(L, 2), true);
                }
                else
                {
                    type = ToLua.CheckObject<Type>(L, 2) as Type;
                }
                if (type != null && type.IsEnum)
                {
                    LuaTypes t = LuaDLL.lua_type(L, 1);
                    object val = null;
                    switch (t)
                    {
                        case LuaTypes.LUA_TNUMBER:
                            val = (int)LuaDLL.lua_tonumber(L, 1); break;
                        case LuaTypes.LUA_TSTRING:
                            val = LuaDLL.lua_tostring(L, 1); break;
                        case LuaTypes.LUA_TUSERDATA:
                            switch (LuaDLL.tolua_getvaluetype(L, 1))
                            {
                                case LuaValueType.Int64:
                                    val = LuaDLL.tolua_toint64(L, 1); break;
                                case LuaValueType.UInt64:
                                    val = LuaDLL.tolua_touint64(L, 1); break;
                                default:
                                    val = ToLua.ToObject(L, 1); break;
                            }
                            break;
                        default:
                            break;
                    }
                    if (val != null)
                    {
                        if (val is string)
                        {
                            ToLua.Push(L, Enum.Parse(type, val as string)); return 1;
                        }
                        else if(Enum.IsDefined(type, val))
                        {
                            ToLua.Push(L, Enum.ToObject(type, val)); return 1;
                        }
                    }
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
    #endregion

    #region Unity
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DesGo(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count == 1)
            {
                object obj = ToLua.CheckObject<UnityEngine.Object>(L, 1);
                if (obj is Component)
                {
                    UnityEngine.Object.Destroy((obj as Component).gameObject);
                }
                else if (obj is UnityEngine.Object)
                {
                    UnityEngine.Object.Destroy(obj as UnityEngine.Object);
                }
                return 0;
            }
            else if (count > 1)
            {
                object obj;
                for (int i = 1; i <= count; i++)
                {
                    obj = ToLua.ToObject(L, i);
                    if (obj is Component)
                    {
                        UnityEngine.Object.Destroy((obj as Component).gameObject);
                    }
                    else if (obj is UnityEngine.Object)
                    {
                        UnityEngine.Object.Destroy(obj as UnityEngine.Object);
                    }
                }
                return 0;
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: CS.DesGo");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsGo(IntPtr L)
    {
        try
        {
            ToLua.Push(L, 1 == LuaDLL.lua_gettop(L) && ToLua.ToObject(L, 1) is GameObject);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int NotNull(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                object o = ToLua.ToObject(L, 1);
                LuaDLL.lua_pushboolean(L, o != null && !o.Equals(null));
            }
            else
            {
                LuaDLL.lua_pushboolean(L, false);
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int NameToLayer(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                string str = ToLua.ToString(L, 1);
                int layer = LayerMask.NameToLayer(str);
                LuaDLL.lua_pushnumber(L, layer);
            }
            else
            {
                LuaDLL.lua_pushnumber(L, 0);
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    #region System

    private static readonly System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex("^[\u4e00-\u9fa5]{0,}$");

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsMatchCnString(IntPtr L)
    {
        try
        {
            int cnt = LuaDLL.lua_gettop(L);
            if (1 >= cnt && TypeChecker.CheckType(L, typeof(string), 1))
            {
                string str = ToLua.ToString(L, 1);
                bool isMatch = false;
                if (1 > cnt && TypeChecker.CheckType(L, typeof(int), 2)) isMatch = regex.IsMatch(str, (int)LuaDLL.luaL_checknumber(L, 2));
                else isMatch = regex.IsMatch(str);
                LuaDLL.lua_pushboolean(L, isMatch);
            }
            else
            {
                LuaDLL.lua_pushboolean(L, false);
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    #endregion

    #endregion

    #region BGM
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int PlayBGM(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt > 0)
            {
                if (argCnt == 1 && TypeChecker.CheckType(L, typeof(string), 1))
                {
                    BGM.Play(ToLua.ToString(L, 1));
                }
                else
                {
                    List<string> bgms = new List<string>(argCnt);
                    for (int i = 1; i <= argCnt; i++)
                    {
                        if (TypeChecker.CheckType(L, typeof(string), i))
                        {
                            bgms.Add(ToLua.ToString(L, i));
                        }
                    }
                    if (bgms.Count > 0)
                    {
                        BGM.Play(bgms.ToArray());
                    }
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
    private static int PlaySOE(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 1 && TypeChecker.CheckType(L, typeof(string), 1))
            {
                NGUITools.PlaySound(AssetManager.LoadAudioClip(ToLua.ToString(L, 1)), argCnt > 1 ? (float)LuaDLL.luaL_checknumber(L, 2) : NGUITools.soundVolume);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Quite(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) > 0)
            {
                BGM.Quite((float)LuaDLL.luaL_checknumber(L, 1));
            }
            else
            {
                BGM.Quite(0f);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_BGMVolume(System.IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, BGM.volume);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_BGMVolume(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count == 2 && TypeChecker.CheckType(L, typeof(float), 2))
            {
                BGM.volume = (float)LuaDLL.luaL_checknumber(L, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: set_BGMVolume");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_SOEVolume(System.IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, NGUITools.soundVolume);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_SOEVolume(System.IntPtr L)
    {
        try
        {
            NGUITools.soundVolume = (float)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_BGMMute(System.IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, BGM.mute);
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_BGMMute(System.IntPtr L)
    {
        try
        {
            BGM.mute = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion

    
}
#endif