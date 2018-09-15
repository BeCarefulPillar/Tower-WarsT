#if TOLUA
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using LuaInterface;

public class LuaStateLite : LuaStatePtr, IDisposable
{
    private static Dictionary<IntPtr, LuaStateLite> _StateMap = new Dictionary<IntPtr, LuaStateLite>();

    public LuaStateLite()
    {
        long time = DateTime.Now.Ticks;
        L = LuaNewState();
        _StateMap.Add(L, this);
        OpenToLuaLibs();
        ToLua.OpenLibs(L);
        LuaSetTop(0);
        InitLuaPath();
        Debugger.Log("Init lua state lite cost: {0}", (DateTime.Now.Ticks - time) * 0.0000001f);
    }

    public static LuaStateLite Get(IntPtr ptr)
    {
        LuaStateLite state = null;

        if (_StateMap.TryGetValue(ptr, out state))
        {
            return state;
        }
        else
        {
            return Get(LuaDLL.tolua_getmainstate(ptr));
        }
    }

    public void Dispose()
    {
        if (IntPtr.Zero != L)
        {
            LuaDLL.lua_close(L);
            _StateMap.Remove(L);
            L = IntPtr.Zero;
            Debugger.Log("LuaStateLite destroy");
        }
    }

    public string DoString(string chunk, string chunkName = "LuaStateLite.cs")
    {
        return LuaLoadBuffer(Encoding.UTF8.GetBytes(chunk), chunkName);
    }

    public string DoFile(string fileName)
    {
        byte[] buffer = LoadFileBuffer(fileName);
        fileName = LuaChunkName(fileName);
        return LuaLoadBuffer(buffer, fileName);
    }

    public void Require(string fileName)
    {
        int top = LuaGetTop();
        int ret = LuaRequire(fileName);

        if (ret != 0)
        {
            string err = LuaToString(-1);
            LuaSetTop(top);
            throw new LuaException(err, LuaException.GetLastError());
        }

        LuaSetTop(top);
    }

    private string LuaLoadBuffer(byte[] buffer, string chunkName)
    {
        LuaDLL.tolua_pushtraceback(L);
        int oldTop = LuaGetTop();

        if (LuaLoadBuffer(buffer, buffer.Length, chunkName) == 0)
        {
            if (LuaPCall(0, LuaDLL.LUA_MULTRET, oldTop) == 0)
            {
                int pos = oldTop + 1;
                string ret = null;
                switch (LuaDLL.lua_type(L, pos))
                {
                    case LuaTypes.LUA_TSTRING: ret = LuaDLL.lua_tostring(L, pos); break;
                    case LuaTypes.LUA_TNUMBER: ret = LuaDLL.lua_tonumber(L, pos).ToString(); break;
                    case LuaTypes.LUA_TBOOLEAN: ret = LuaDLL.tolua_toboolean(L, pos).ToString(); break;
                    default: break;
                }
                LuaSetTop(oldTop - 1);
                return ret;
            }
        }

        string err = LuaToString(-1);
        LuaSetTop(oldTop - 1);
        throw new LuaException(err, LuaException.GetLastError());
    }

    private byte[] LoadFileBuffer(string fileName)
    {
        byte[] buffer = LuaFileUtils.Instance.ReadFile(fileName);

        if (buffer == null)
        {
            string error = string.Format("cannot open {0}: No such file or directory", fileName);
            error += LuaFileUtils.Instance.FindFileError(fileName);
            throw new LuaException(error);
        }

        return buffer;
    }

    private string LuaChunkName(string name)
    {
        if (LuaConst.openLuaDebugger)
        {
            name = LuaFileUtils.Instance.FindFile(name);
        }

        return "@" + name;
    }

    private void InitLuaPath()
    {
        InitPackagePath();

#if UNITY_EDITOR
        if (!Directory.Exists(LuaConst.luaDir))
        {
            string msg = string.Format("luaDir path not exists: {0}, configer it in LuaConst.cs", LuaConst.luaDir);
            throw new LuaException(msg);
        }

        if (!Directory.Exists(LuaConst.toluaDir))
        {
            string msg = string.Format("toluaDir path not exists: {0}, configer it in LuaConst.cs", LuaConst.toluaDir);
            throw new LuaException(msg);
        }

        AddSearchPath(LuaConst.toluaDir);
        AddSearchPath(LuaConst.luaDir);
#endif
        if (LuaFileUtils.Instance.GetType() == typeof(LuaFileUtils))
        {
            AddSearchPath(LuaConst.luaResDir);
        }
    }

    private void InitPackagePath()
    {
        LuaGetGlobal("package");
        LuaGetField(-1, "path");
        string current = LuaToString(-1);
        string[] paths = current.Split(';');

        for (int i = 0; i < paths.Length; i++)
        {
            if (!string.IsNullOrEmpty(paths[i]))
            {
                string path = paths[i].Replace('\\', '/');
                LuaFileUtils.Instance.AddSearchPath(path);
            }
        }

        LuaPushString("");
        LuaSetField(-3, "path");
        LuaPop(2);
    }

    private void AddSearchPath(string fullPath)
    {
        if (!Path.IsPathRooted(fullPath))
        {
            throw new LuaException(fullPath + " is not a full path");
        }

        fullPath = ToPackagePath(fullPath);
        LuaFileUtils.Instance.AddSearchPath(fullPath);
    }

    private string ToPackagePath(string path)
    {
        using (CString.Block())
        {
            CString sb = CString.Alloc(256);
            sb.Append(path);
            sb.Replace('\\', '/');

            if (sb.Length > 0 && sb[sb.Length - 1] != '/')
            {
                sb.Append('/');
            }

            sb.Append("?.lua");
            return sb.ToString();
        }
    }

    #region LUA注册
    [NoToLua]
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(LuaStateLite), typeof(object));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("DoString", DoString);
        L.RegFunction("DoFile", DoFile);
        L.RegFunction("Require", Require);
        L.RegFunction("Dispose", Dispose);
        L.RegFunction("New", _CreateLuaStateLite);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int _CreateLuaStateLite(System.IntPtr L)
    {
        try
        {
            if (0 == LuaDLL.lua_gettop(L))
            {
                ToLua.Push(L, new LuaStateLite());
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaStateLite.New");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DoString(System.IntPtr L)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(L))
            {
                LuaStateLite lsl = ToLua.CheckObject<LuaStateLite>(L, 1) as LuaStateLite;
                if (lsl != null)
                {
                    LuaTypes luaType = LuaDLL.lua_type(L, 2);
                    switch (luaType)
                    {
                        case LuaTypes.LUA_TSTRING:
                            ToLua.Push(L, lsl.DoString(LuaDLL.lua_tostring(L, 2))); return 1;
                        case LuaTypes.LUA_TUSERDATA:
                            ToLua.Push(L, lsl.DoString(ToLua.ToObject(L, 2) as string)); return 1;
                        default: break;
                    }
                }
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaStateLite.DoString");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DoFile(System.IntPtr L)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(L))
            {
                LuaStateLite lsl = ToLua.CheckObject<LuaStateLite>(L, 1) as LuaStateLite;
                if (lsl != null)
                {
                    LuaTypes luaType = LuaDLL.lua_type(L, 2);
                    switch (luaType)
                    {
                        case LuaTypes.LUA_TSTRING:
                            ToLua.Push(L, lsl.DoFile(LuaDLL.lua_tostring(L, 2))); return 1;
                        case LuaTypes.LUA_TUSERDATA:
                            ToLua.Push(L, lsl.DoFile(ToLua.ToObject(L, 2) as string)); return 1;
                        default: break;
                    }
                }
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaStateLite.DoFile");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Require(System.IntPtr L)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(L))
            {
                LuaStateLite lsl = ToLua.CheckObject<LuaStateLite>(L, 1) as LuaStateLite;
                if (lsl != null)
                {
                    LuaTypes luaType = LuaDLL.lua_type(L, 2);
                    switch (luaType)
                    {
                        case LuaTypes.LUA_TSTRING:
                            lsl.Require(LuaDLL.lua_tostring(L, 2)); return 0;
                        case LuaTypes.LUA_TUSERDATA:
                            lsl.Require(ToLua.ToObject(L, 2) as string); return 0;
                        default: break;
                    }
                }
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaStateLite.Require");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Dispose(System.IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                (ToLua.CheckObject<LuaStateLite>(L, 1) as LuaStateLite).Dispose();
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaStateLite.Dispose");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int op_Equality(System.IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            LuaDLL.lua_pushboolean(L, ToLua.ToObject(L, 1) == ToLua.ToObject(L, 2));
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion
}
#endif