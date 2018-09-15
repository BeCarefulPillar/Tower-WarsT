#if TOLUA
using System;
using LuaInterface;
using Kiol.Util;

public static class LuaIO
{
    public static void Register(LuaState L)
    {
        L.BeginModule("File");
        L.RegFunction("PathCombine", PathCombine);
        L.RegFunction("ReadText", FileReadText);
        L.RegFunction("ReadByte", FileReadByte);
        L.RegFunction("ReadCEText", FileReadCEText);
        L.RegFunction("ReadCETextCRC", FileReadCETextCRC);
        L.RegFunction("WriteByte", FileWriteByte);
        L.RegFunction("WriteText", FileWriteText);
        L.RegFunction("WriteCEText", FileWriteCEText);
        L.RegFunction("WriteCETextCRC", FileWriteCETextCRC);
        L.RegFunction("Extension", FileExtension);
        L.RegFunction("Name", FileName);
        L.RegFunction("NameWithoutExtension", FileNameWithoutExtension);
        L.RegFunction("Length", FileLength);
        L.RegFunction("Exists", FileExists);
        L.RegFunction("Delete", FileDelete);
        L.RegFunction("DirExists", DirExists);
        L.RegFunction("DirCreate", DirCreate);
        L.RegFunction("DirFiles", DirFiles);
        L.RegFunction("DirDelete", DirDelete);
        L.EndModule();
    }

    #region File
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FileReadText(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(string), 1))
            {
                try
                {
                    ToLua.Push(L, System.IO.File.ReadAllText(ToLua.ToString(L, 1), System.Text.Encoding.UTF8));
                }
                catch
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
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FileReadByte(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(string), 1))
            {
                try
                {
                    ToLua.Push(L, Kiol.IO.File.ReadFile(ToLua.ToString(L, 1)));
                }
                catch
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
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FileWriteByte(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 2 && TypeChecker.CheckTypes(L, 1, typeof(string), typeof(byte[])))
            {
                LuaDLL.lua_pushboolean(L, Kiol.IO.File.WriteFile(ToLua.ToString(L, 1), ToLua.ToObject(L, 2) as byte[]));
            }
            else
            {
                LuaDLL.lua_pushboolean(L, false);
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
    private static int FileWriteText(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 2 && TypeChecker.CheckTypes(L, 1, typeof(string), typeof(string)))
            {
                LuaDLL.lua_pushboolean(L, Kiol.IO.File.WriteFile(ToLua.ToString(L, 1), System.Text.Encoding.UTF8.GetBytes(ToLua.ToString(L, 2))));
                //System.IO.File.WriteAllText(ToLua.ToString(L, 1), ToLua.ToString(L, 2), System.Text.Encoding.UTF8);
            }
            else
            {
                LuaDLL.lua_pushboolean(L, false);
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
    private static int PathCombine(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 2 && TypeChecker.CheckTypes(L, 1, typeof(string), typeof(string)))
            {
                ToLua.Push(L, System.IO.Path.Combine(ToLua.ToString(L, 1), ToLua.ToString(L, 2)));
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
    private static int FileExtension(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckTypes(L, 1, typeof(string)))
            {
                ToLua.Push(L, System.IO.Path.GetExtension(ToLua.ToString(L, 1)));
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
    private static int FileName(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckTypes(L, 1, typeof(string)))
            {
                ToLua.Push(L, System.IO.Path.GetFileName(ToLua.ToString(L, 1)));
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
    private static int FileNameWithoutExtension(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckTypes(L, 1, typeof(string)))
            {
                ToLua.Push(L, System.IO.Path.GetFileNameWithoutExtension(ToLua.ToString(L, 1)));
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
    private static int FileLength(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckTypes(L, 1, typeof(string)))
            {
                LuaDLL.lua_pushnumber(L, (int)Kiol.IO.File.Length(ToLua.ToString(L, 1)));
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
    private static int FileExists(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckTypes(L, 1, typeof(string)))
            {
                LuaDLL.lua_pushboolean(L, System.IO.File.Exists(ToLua.ToString(L, 1)));
            }
            else
            {
                LuaDLL.lua_pushboolean(L, false);
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
    private static int FileDelete(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckTypes(L, 1, typeof(string)))
            {
                System.IO.File.Delete(ToLua.ToString(L, 1));
            }
            return 0;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DirExists(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckType(L, typeof(string), 1))
            {
                LuaDLL.lua_pushboolean(L, System.IO.Directory.Exists(ToLua.ToString(L, 1)));
            }
            else
            {
                LuaDLL.lua_pushboolean(L, false);
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
    private static int DirCreate(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 1 && TypeChecker.CheckTypes(L, 1, typeof(string)))
            {
                System.IO.Directory.CreateDirectory(ToLua.ToString(L, 1));
            }
            return 0;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DirDelete(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1 && TypeChecker.CheckTypes(L, 1, typeof(string)))
            {
                if (count >= 2 && TypeChecker.CheckTypes(L, 2, typeof(bool)))
                {
                    System.IO.Directory.Delete(ToLua.ToString(L, 1), LuaDLL.lua_toboolean(L, 2));
                }
                else
                {
                    System.IO.Directory.Delete(ToLua.ToString(L, 1));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            return 0;
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DirFiles(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1 && TypeChecker.CheckTypes(L, 1, typeof(string)))
            {
                if (count >= 2 && TypeChecker.CheckTypes(L, 2, typeof(string)))
                {
                    if (count >= 3 && TypeChecker.CheckTypes(L, 3, typeof(bool)))
                    {
                        ToLua.Push(L, System.IO.Directory.GetFiles(ToLua.ToString(L, 1), ToLua.ToString(L, 2), LuaDLL.luaL_checkboolean(L, 3) ? System.IO.SearchOption.AllDirectories : System.IO.SearchOption.TopDirectoryOnly));
                    }
                    else
                    {
                        ToLua.Push(L, System.IO.Directory.GetFiles(ToLua.ToString(L, 1), ToLua.ToString(L, 2)));
                    }
                }
                else
                {
                    ToLua.Push(L, System.IO.Directory.GetFiles(ToLua.ToString(L, 1)));
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
    private static int FileReadCEText(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1 && TypeChecker.CheckType(L, typeof(string), 1))
            {
                ToLua.Push(L, Encryption.DecompressStr(Kiol.IO.File.ReadFile(ToLua.ToString(L, 1)), count == 2 ? LuaDLL.luaL_checkinteger(L, 2) : Encryption.DEFAULT_ENCRYPT_SKIP));
            }
            else
            {
                LuaDLL.lua_pushnil(L);
            }
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            LuaDLL.lua_pushnil(L);
        }
        return 1;
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FileWriteCEText(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (LuaDLL.lua_gettop(L) >= 2 && TypeChecker.CheckTypes(L, 1, typeof(string), typeof(string)))
            {
                LuaDLL.lua_pushboolean(L, Kiol.IO.File.WriteFile(ToLua.ToString(L, 1), Encryption.Compress(ToLua.ToString(L, 2), count == 3 ? LuaDLL.luaL_checkinteger(L, 3) : Encryption.DEFAULT_ENCRYPT_SKIP)));
            }
            else
            {
                LuaDLL.lua_pushboolean(L, false);
            }
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            LuaDLL.lua_pushboolean(L, false);
        }
        return 1;
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FileReadCETextCRC(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 1 && TypeChecker.CheckType(L, typeof(string), 1))
            {
                byte[] data = Encryption.Decompress(Kiol.IO.File.ReadFile(ToLua.ToString(L, 1)), count == 2 ? LuaDLL.luaL_checkinteger(L, 2) : Encryption.DEFAULT_ENCRYPT_SKIP);
                if (CRC.CheckAndStripCRC16(ref data))
                {
                    ToLua.Push(L, System.Text.Encoding.UTF8.GetString(data, 0, data.Length));
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
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            LuaDLL.lua_pushnil(L);
        }
        return 1;
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FileWriteCETextCRC(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (LuaDLL.lua_gettop(L) >= 2 && TypeChecker.CheckTypes(L, 1, typeof(string), typeof(string)))
            {
                LuaDLL.lua_pushboolean(L, Kiol.IO.File.WriteFile(ToLua.ToString(L, 1), Encryption.Compress(CRC.AddCRC16(System.Text.Encoding.UTF8.GetBytes(ToLua.ToString(L, 2))), count == 3 ? LuaDLL.luaL_checkinteger(L, 3) : Encryption.DEFAULT_ENCRYPT_SKIP)));
            }
            else
            {
                LuaDLL.lua_pushboolean(L, false);
            }
        }
        catch (Exception e)
        {
            Debugger.LogWarning(e);
            LuaDLL.lua_pushboolean(L, false);
        }
        return 1;
    }
    #endregion
}
#endif