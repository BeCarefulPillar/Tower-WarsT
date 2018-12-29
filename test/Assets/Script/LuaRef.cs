using System.Collections.Generic;
using LuaInterface;
using UnityEngine;

[System.Serializable] public class QYObject { public string name; public Object o; }

[System.Serializable] public class QYObjectS { public string name; public Object[] o; }

public class LuaRef : UMonoBehaviour
{
    [SerializeField] private string scriptName;
    [SerializeField] public QYObject[] obj;
    [SerializeField] public QYObjectS[] objs;

    [ContextMenu("ClearNULL")]
    private void ClearNULL()
    {
        if (obj.Length > 0)
        {
            List<QYObject> lobj = new List<QYObject>();
            lobj.AddRange(obj);

            lobj.RemoveAll(o => { return o.name == string.Empty || o.o == null; });

            obj = lobj.ToArray();
            lobj.Clear();
        }

        if (objs.Length > 0)
        {
            List<QYObjectS> lobjs = new List<QYObjectS>();
            lobjs.AddRange(objs);

            List<Object> lObjects = new List<Object>();
            for (int i = 0; i < lobjs.Count; ++i)
            {
                QYObjectS os = lobjs[i];
                lObjects.AddRange(os.o);

                lObjects.RemoveAll(o =>
                {
                    return o == null;
                });

                os.o = lObjects.ToArray();
                lObjects.Clear();
            }

            lobjs.RemoveAll(os => { return os.name == string.Empty || os.o == null || os.o.Length == 0; });

            objs = lobjs.ToArray();
            lobjs.Clear();
        }
    }

    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(LuaRef), typeof(UMonoBehaviour));
        L.RegVar("ref", get_ref, null);
        L.EndClass();
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_ref(System.IntPtr L)
    {
        try
        {
            LuaRef rf = ToLua.ToObject(L, 1) as LuaRef;

            LuaDLL.lua_createtable(L, 0, 0);
            foreach (QYObject e in rf.obj)
            {
                if (!string.IsNullOrEmpty(e.name))
                {
                    LuaDLL.lua_pushstring(L, e.name);
                    ToLua.Push(L, e.o);
                    LuaDLL.lua_rawset(L, -3);
                }
            }

            foreach (QYObjectS e in rf.objs)
            {
                if (!string.IsNullOrEmpty(e.name))
                {
                    LuaDLL.lua_pushstring(L, e.name);

                    LuaDLL.lua_createtable(L, 0, 0);
                    for (int i = 0; i < e.o.Length; ++i)
                    {
                        LuaDLL.lua_pushnumber(L, i + 1);
                        ToLua.Push(L, e.o[i]);
                        LuaDLL.lua_rawset(L, -3);
                    }

                    LuaDLL.lua_rawset(L, -3);
                }
            }
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
}