﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaAssetLoaderWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaAssetLoader), typeof(UMonoBehaviour));
		L.RegFunction("LoadPrefab", LoadPrefab);
		L.RegFunction("LoadPrefabAsync", LoadPrefabAsync);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadPrefab(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaAssetLoader obj = (LuaAssetLoader)ToLua.CheckObject<LuaAssetLoader>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.GameObject o = obj.LoadPrefab(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadPrefabAsync(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaAssetLoader obj = (LuaAssetLoader)ToLua.CheckObject<LuaAssetLoader>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.AssetBundleCreateRequest o = obj.LoadPrefabAsync(arg0);
			ToLua.PushSealed(L, o);
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

