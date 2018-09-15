#if TOLUA
using System;
using LuaInterface;

public class UIWrapGridWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UIWrapGrid), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("Reset", Reset);
		L.RegFunction("AlignItem", AlignItem);
		L.RegFunction("GetItem", GetItem);
		L.RegFunction("InitItem", InitItem);
		L.RegFunction("InitAllItem", InitAllItem);
		L.RegFunction("Remove", Remove);
		L.RegFunction("Insert", Insert);
		L.RegFunction("Dispose", Dispose);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("requestTimeOut", get_requestTimeOut, set_requestTimeOut);
		L.RegVar("animateSmoothly", get_animateSmoothly, set_animateSmoothly);
		L.RegVar("addItemWaitTime", get_addItemWaitTime, set_addItemWaitTime);
		L.RegVar("onItemInit", get_onItemInit, set_onItemInit);
		L.RegVar("onItemAlign", get_onItemAlign, set_onItemAlign);
		L.RegVar("onRequestCount", get_onRequestCount, set_onRequestCount);
		L.RegVar("holderData", get_holderData, set_holderData);
		L.RegVar("itemPrefab", get_itemPrefab, set_itemPrefab);
		L.RegVar("itemCacheSize", get_itemCacheSize, set_itemCacheSize);
		L.RegVar("cullItem", get_cullItem, set_cullItem);
		L.RegVar("orginAlign", get_orginAlign, set_orginAlign);
		L.RegVar("orginOffset", get_orginOffset, set_orginOffset);
		L.RegVar("isHorizontal", get_isHorizontal, set_isHorizontal);
		L.RegVar("gridWidth", get_gridWidth, set_gridWidth);
		L.RegVar("gridHeight", get_gridHeight, set_gridHeight);
		L.RegVar("gridCountPerLine", get_gridCountPerLine, set_gridCountPerLine);
		L.RegVar("alignItem", get_alignItem, set_alignItem);
		L.RegVar("alignOffset", get_alignOffset, set_alignOffset);
		L.RegVar("alignItemIndex", get_alignItemIndex, null);
		L.RegVar("holder", get_holder, set_holder);
		L.RegVar("needReset", get_needReset, set_needReset);
		L.RegVar("itemCount", get_itemCount, null);
		L.RegVar("viewEnd", get_viewEnd, null);
		L.RegVar("realCount", get_realCount, set_realCount);
		L.RegVar("luaContainer", get_luaContainer, set_luaContainer);
		L.RegVar("transferSelf", get_transferSelf, set_transferSelf);
        L.RegVar("items", get_items, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Reset(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
			obj.Reset();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AlignItem(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
				obj.AlignItem();
				return 0;
			}
			else if (count == 2)
			{
				UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
				obj.AlignItem(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UIWrapGrid.AlignItem");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetItem(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.GameObject o = obj.GetItem(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int InitItem(IntPtr L)
	{
		try
		{
            int count = LuaDLL.lua_gettop(L);
            if (count == 2)
            {
                (ToLua.ToObject(L, 1) as UIWrapGrid).InitItem((int)LuaDLL.luaL_checknumber(L, 2)); return 0;
            }
            if (count > 2)
            {
                UIWrapGrid obj = ToLua.ToObject(L, 1) as UIWrapGrid;
                for (int i = 2; i <= count; i++)
                {
                    obj.InitItem((int)LuaDLL.luaL_checknumber(L, i));
                }
                return 0;
            }
            return LuaDLL.luaL_throw(L, "invalid arguments to method : UIWrapGrid.InitItem");
        }
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int InitAllItem(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
			obj.InitAllItem();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Remove(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes<int>(L, 2))
			{
				UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				obj.Remove(arg0);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes<UnityEngine.GameObject>(L, 2))
			{
				UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
				UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.ToObject(L, 2);
				bool o = obj.Remove(arg0);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 3)
			{
				UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
				obj.Remove(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UIWrapGrid.Remove");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Insert(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes<int>(L, 2))
			{
				UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				obj.Insert(arg0);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes<UnityEngine.Transform>(L, 2))
			{
				UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
				UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.ToObject(L, 2);
				obj.Insert(arg0);
				return 0;
			}
			else if (count == 3)
			{
				UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
				obj.Insert(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UIWrapGrid.Insert");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Dispose(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UIWrapGrid obj = (UIWrapGrid)ToLua.CheckObject(L, 1, typeof(UIWrapGrid));
			obj.Dispose();
			return 0;
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

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_requestTimeOut(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float ret = obj.requestTimeOut;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index requestTimeOut on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_animateSmoothly(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool ret = obj.animateSmoothly;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index animateSmoothly on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_addItemWaitTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float ret = obj.addItemWaitTime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index addItemWaitTime on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onItemInit(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			string ret = obj.onItemInit;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onItemInit on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onItemAlign(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			string ret = obj.onItemAlign;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onItemAlign on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onRequestCount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			string ret = obj.onRequestCount;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onRequestCount on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_holderData(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			object ret = obj.holderData;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index holderData on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_itemPrefab(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			UnityEngine.GameObject ret = obj.itemPrefab;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index itemPrefab on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_itemCacheSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			int ret = obj.itemCacheSize;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index itemCacheSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cullItem(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool ret = obj.cullItem;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index cullItem on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_orginAlign(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			UIWrapGrid.Align ret = obj.orginAlign;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index orginAlign on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_orginOffset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			UnityEngine.Vector3 ret = obj.orginOffset;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index orginOffset on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isHorizontal(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool ret = obj.isHorizontal;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index isHorizontal on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_gridWidth(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float ret = obj.gridWidth;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index gridWidth on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_gridHeight(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float ret = obj.gridHeight;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index gridHeight on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_gridCountPerLine(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			int ret = obj.gridCountPerLine;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index gridCountPerLine on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_alignItem(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool ret = obj.alignItem;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index alignItem on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_alignOffset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float ret = obj.alignOffset;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index alignOffset on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_alignItemIndex(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			int ret = obj.alignItemIndex;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index alignItemIndex on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_holder(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			IWrapGridHolder ret = obj.holder;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index holder on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_needReset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool ret = obj.needReset;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index needReset on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_itemCount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			int ret = obj.itemCount;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index itemCount on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_viewEnd(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			int ret = obj.viewEnd;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index viewCount on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_realCount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			int ret = obj.realCount;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index realCount on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_luaContainer(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			LuaContainer ret = obj.luaContainer;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaContainer on a nil value");
		}
	}
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_transferSelf(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            UIWrapGrid obj = (UIWrapGrid)o;
            ToLua.Push(L, obj.transferSelf);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o, "attempt to index transferSelf on a nil value");
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_items(IntPtr L)
	{
		object o = null;

		try
		{
			UIWrapGrid grid = ToLua.ToObject(L, 1) as UIWrapGrid;
            LuaDLL.lua_createtable(L, 0, 0);
            foreach (var item in grid.items)
            {
                LuaDLL.lua_pushnumber(L, item.Key);
                ToLua.PushSealed(L, item.Value);
                LuaDLL.lua_rawset(L, -3);
            }
            return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index items on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_requestTimeOut(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.requestTimeOut = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index requestTimeOut on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_animateSmoothly(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.animateSmoothly = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index animateSmoothly on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_addItemWaitTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.addItemWaitTime = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index addItemWaitTime on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onItemInit(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.onItemInit = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onItemInit on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onItemAlign(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.onItemAlign = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onItemAlign on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onRequestCount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.onRequestCount = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index onRequestCount on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_holderData(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			object arg0 = ToLua.ToVarObject(L, 2);
			obj.holderData = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index holderData on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_itemPrefab(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
			obj.itemPrefab = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index itemPrefab on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_itemCacheSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.itemCacheSize = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index itemCacheSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cullItem(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.cullItem = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index cullItem on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_orginAlign(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			UIWrapGrid.Align arg0 = (UIWrapGrid.Align)ToLua.CheckObject(L, 2, typeof(UIWrapGrid.Align));
			obj.orginAlign = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index orginAlign on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_orginOffset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.orginOffset = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index orginOffset on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isHorizontal(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.isHorizontal = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index isHorizontal on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_gridWidth(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.gridWidth = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index gridWidth on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_gridHeight(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.gridHeight = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index gridHeight on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_gridCountPerLine(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.gridCountPerLine = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index gridCountPerLine on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_alignItem(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.alignItem = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index alignItem on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_alignOffset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.alignOffset = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index alignOffset on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_holder(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			IWrapGridHolder arg0 = (IWrapGridHolder)ToLua.CheckObject<IWrapGridHolder>(L, 2);
			obj.holder = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index holder on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_needReset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.needReset = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index needReset on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_realCount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.realCount = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index realCount on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_luaContainer(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIWrapGrid obj = (UIWrapGrid)o;
			LuaContainer arg0 = (LuaContainer)ToLua.CheckObject<LuaContainer>(L, 2);
			obj.luaContainer = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaContainer on a nil value");
		}
	}
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int set_transferSelf(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            UIWrapGrid obj = (UIWrapGrid)o;
            obj.transferSelf = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o, "attempt to index transferSelf on a nil value");
        }
    }
}
#endif