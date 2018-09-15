
#if TOLUA
using System;
using UnityEngine;
using LuaInterface;

namespace LuaInterface
{
    public partial struct LuaValueType
    {
        public const int Rect = 13;
    }
}
public static class LuaValueTypeExtend
{
    public static void Register(LuaState L)
    {
        // Rect
        NewRect = L.GetFunction("Rect.New");
        GetRect = L.GetFunction("Rect.Get");
        StackTraits<Rect>.Init(PushRect, CheckRectValue, ToRectValue);           //支持压入lua以及从lua栈读取
        TypeTraits<Rect>.Init(CheckRectType);                                    //支持重载函数TypeCheck.CheckTypes
        TypeTraits<Nullable<Rect>>.Init(CheckNullRectType);                      //支持重载函数TypeCheck.CheckTypes
        LuaValueTypeName.names[LuaValueType.Rect] = "Rect";                      //CheckType失败提示的名字
        TypeChecker.LuaValueTypeMap[LuaValueType.Rect] = typeof(Rect);           //用于支持类型匹配检查操作
        ToLua.ToVarMap[LuaValueType.Rect] = ToRectTable;                         //Rect作为object读取
        ToLua.VarPushMap[typeof(Rect)] = PushRect;                               //Rect作为object压入
    }

    #region Rect
    private static LuaFunction NewRect = null;
    private static LuaFunction GetRect = null;

    private static void PushRect(IntPtr L, object rt) { PushRect(L, (Rect)rt); }

    private static void PushRect(IntPtr L, Rect rt)
    {
        LuaDLL.lua_getref(L, NewRect.GetReference());
        LuaDLL.lua_pushnumber(L, rt.xMin);
        LuaDLL.lua_pushnumber(L, rt.yMin);
        LuaDLL.lua_pushnumber(L, rt.width);
        LuaDLL.lua_pushnumber(L, rt.height);
        LuaDLL.lua_call(L, 4, 1);
    }

    private static Rect ToRectValue(IntPtr L, int pos)
    {
        pos = LuaDLL.abs_index(L, pos);
        LuaDLL.lua_getref(L, GetRect.GetReference());
        LuaDLL.lua_pushvalue(L, pos);
        LuaDLL.lua_call(L, 1, 4);
        float x = (float)LuaDLL.lua_tonumber(L, -4);
        float y = (float)LuaDLL.lua_tonumber(L, -3);
        float w = (float)LuaDLL.lua_tonumber(L, -2);
        float h = (float)LuaDLL.lua_tonumber(L, -1);
        LuaDLL.lua_pop(L, 4);
        return new Rect(x, y, w, h);
    }

    private static Rect CheckRectValue(IntPtr L, int pos)
    {
        int type = LuaDLL.tolua_getvaluetype(L, pos);

        if (type != LuaValueType.Rect)
        {
            LuaDLL.luaL_typerror(L, pos, "Rect", LuaValueTypeName.Get(type));
            return new Rect();
        }

        return ToRectValue(L, pos);
    }

    private static bool CheckRectType(IntPtr L, int pos)
    {
        return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Rect;
    }

    private static bool CheckNullRectType(IntPtr L, int pos)
    {
        LuaTypes luaType = LuaDLL.lua_type(L, pos);

        switch (luaType)
        {
            case LuaTypes.LUA_TNIL:
                return true;
            case LuaTypes.LUA_TTABLE:
                return LuaDLL.tolua_getvaluetype(L, pos) == LuaValueType.Rect;
            default:
                return false;
        }
    }

    private static object ToRectTable(IntPtr L, int pos)
    {
        return ToRectValue(L, pos);
    }
    #endregion
}

#endif