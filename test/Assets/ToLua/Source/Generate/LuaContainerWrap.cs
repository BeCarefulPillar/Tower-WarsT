﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaContainerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaContainer), typeof(UMonoBehaviour));
		L.RegFunction("BindFunction", BindFunction);
		L.RegFunction("GetBindFunction", GetBindFunction);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int BindFunction(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);
			LuaContainer obj = (LuaContainer)ToLua.CheckObject<LuaContainer>(L, 1);
			string[] arg0 = ToLua.CheckParamsString(L, 2, count - 1);
			obj.BindFunction(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetBindFunction(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaContainer obj = (LuaContainer)ToLua.CheckObject<LuaContainer>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaInterface.LuaFunction o = obj.GetBindFunction(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
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
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

