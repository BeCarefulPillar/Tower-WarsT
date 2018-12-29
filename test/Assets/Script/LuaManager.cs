using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;
using System.IO;

public class LuaManager : UMonoBehaviour
{
    private LuaState lua;
    private LuaLooper loop;
    private LuaFileUtils loader;
    private List<LuaContainer> luaContainers = new List<LuaContainer>();

    private void Awake()
    {
        loader = new LuaFileUtils();
#if TEST
        loader.beZip = false;
#else
        loader.beZip = true;
#endif

        lua = new LuaState();


        lua.OpenLibs(LuaDLL.luaopen_pb);
        //lua.OpenLibs(LuaDLL.luaopen_sproto_core);
        //lua.OpenLibs(LuaDLL.luaopen_protobuf_c);
        lua.OpenLibs(LuaDLL.luaopen_lpeg);
        lua.OpenLibs(LuaDLL.luaopen_bit);
        lua.OpenLibs(LuaDLL.luaopen_socket_core);


        lua.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
        lua.OpenLibs(LuaDLL.luaopen_cjson);
        lua.LuaSetField(-2, "cjson");
        lua.OpenLibs(LuaDLL.luaopen_cjson_safe);
        lua.LuaSetField(-2, "cjson.safe");


        lua.LuaSetTop(0);

        LuaBinder.Bind(lua);
        Bind(lua);
        DelegateFactory.Init();
        LuaCoroutine.Register(lua, this);
    }

    private void Bind(LuaState L)
    {
        L.BeginModule(null);
        LuaRef.Register(L);
        L.EndModule();
    }

    private void AddBundle(string bundleName)
    {
        string url = Game.dataPath + bundleName;
        if(File.Exists(url))
        {
            AssetBundle bundle = AssetBundle.LoadFromFile(url);
            if(bundle!=null)
            {
                bundleName = bundleName.Replace("lua/", string.Empty).Replace(".unity3d", string.Empty);
                loader.AddSearchBundle(bundleName, bundle);
            }
        }
    }

    public void AddLuaContainer(LuaContainer c)
    {
        luaContainers.Add(c);
        Debug.Log(luaContainers.Count);
    }

    public void InitStart()
    {
#if TEST
        lua.AddSearchPath(Application.dataPath+"/ToLua/Lua/");
#else
        lua.AddSearchPath(Game.dataPath + "lua");
#endif

        //AddBundle("lua/lua.unity3d");
        //AddBundle("lua/lua_math.unity3d");
        //AddBundle("lua/lua_system.unity3d");
        //AddBundle("lua/lua_system_reflection.unity3d");
        //AddBundle("lua/lua_unityengine.unity3d");
        //AddBundle("lua/lua_common.unity3d");
        //AddBundle("lua/lua_logic.unity3d");
        //AddBundle("lua/lua_view.unity3d");
        //AddBundle("lua/lua_controller.unity3d");
        //AddBundle("lua/lua_misc.unity3d");
        //AddBundle("lua/lua_protobuf.unity3d");
        //AddBundle("lua/lua_3rd_cjson.unity3d");
        //AddBundle("lua/lua_3rd_luabitop.unity3d");
        //AddBundle("lua/lua_3rd_pbc.unity3d");
        //AddBundle("lua/lua_3rd_pblua.unity3d");
        //AddBundle("lua/lua_3rd_sproto.unity3d");

        lua.Start();

        //lua.DoFile("Main.lua");
        //LuaFunction main = lua.GetFunction("Main");
        //main.Call();
        //main.Dispose();
        //main = null;

        loop = cachedGameObject.GetComponent<LuaLooper>() ?? cachedGameObject.AddComponent<LuaLooper>();
        loop.luaState = lua;

        Debug.Log(LuaFileUtils.Instance.searchPaths.Count);
        foreach (string path in LuaFileUtils.Instance.searchPaths)
        {
            Debug.Log(path);
        }

        //DoFile("Logic/Game");
        //CallMethod("Game", "OnInitOK");
    }

    public object[] CallMethod(string module, string func, params object[] args)
    {
        LuaFunction fun = lua.GetFunction(module +"."+ func);
        if (fun != null)
            return fun.LazyCall(args);
        return null;
    }

    public LuaTable GetLuaTable(string name)
    {
        if (lua == null || string.IsNullOrEmpty(name))
            return null;
        int idx = name.LastIndexOf("/");
        string n = idx < 0 ? name : name.Substring(idx + 1);
        LuaTable tab = lua.GetTable(n, false);
        if (tab == null)
        {
            lua.Require(name);
            tab = lua.GetTable(n);
        }
        return tab;
    }

    public void DoFile(string filename)
    {
        lua.DoFile(filename);
    }

    public void Close()
    {
        LuaContainer c;
        for (int i = 0; i < luaContainers.Count; ++i)
        {
            c = luaContainers[i];
            if (c != null)
                c.Dispose();
        }
        luaContainers.Clear();

        if (loop != null)
        {
            loop.Destroy();
            loop = null;
        }

        if (lua != null)
        {
            lua.Dispose();
            lua = null;
        }

        loader = null;
    }

    public static LuaManager Ins
    {
        get
        {
            return Game.Ins.mIns["LuaManager"] as LuaManager;
        }
    }
}