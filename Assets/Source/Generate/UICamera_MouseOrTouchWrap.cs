﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UICamera_MouseOrTouchWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UICamera.MouseOrTouch), typeof(System.Object));
		L.RegFunction("New", _CreateUICamera_MouseOrTouch);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("key", get_key, set_key);
		L.RegVar("pos", get_pos, set_pos);
		L.RegVar("lastPos", get_lastPos, set_lastPos);
		L.RegVar("delta", get_delta, set_delta);
		L.RegVar("totalDelta", get_totalDelta, set_totalDelta);
		L.RegVar("pressedCam", get_pressedCam, set_pressedCam);
		L.RegVar("last", get_last, set_last);
		L.RegVar("current", get_current, set_current);
		L.RegVar("pressed", get_pressed, set_pressed);
		L.RegVar("dragged", get_dragged, set_dragged);
		L.RegVar("pressTime", get_pressTime, set_pressTime);
		L.RegVar("clickTime", get_clickTime, set_clickTime);
		L.RegVar("clickNotification", get_clickNotification, set_clickNotification);
		L.RegVar("touchBegan", get_touchBegan, set_touchBegan);
		L.RegVar("pressStarted", get_pressStarted, set_pressStarted);
		L.RegVar("dragStarted", get_dragStarted, set_dragStarted);
		L.RegVar("ignoreDelta", get_ignoreDelta, set_ignoreDelta);
		L.RegVar("deltaTime", get_deltaTime, null);
		L.RegVar("isOverUI", get_isOverUI, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUICamera_MouseOrTouch(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UICamera.MouseOrTouch obj = new UICamera.MouseOrTouch();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UICamera.MouseOrTouch.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Lua_ToString(IntPtr L)
	{
		object obj = ToLua.ToObject(L, 1);

		if (obj != null)
		{
			LuaDLL.lua_pushstring(L, obj.ToString());
		}
		else
		{
			LuaDLL.lua_pushnil(L);
		}

		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_key(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.KeyCode ret = obj.key;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index key on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pos(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Vector2 ret = obj.pos;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pos on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_lastPos(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Vector2 ret = obj.lastPos;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index lastPos on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_delta(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Vector2 ret = obj.delta;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index delta on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_totalDelta(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Vector2 ret = obj.totalDelta;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index totalDelta on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pressedCam(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Camera ret = obj.pressedCam;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pressedCam on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_last(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.GameObject ret = obj.last;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index last on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_current(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.GameObject ret = obj.current;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index current on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pressed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.GameObject ret = obj.pressed;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pressed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_dragged(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.GameObject ret = obj.dragged;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index dragged on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pressTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			float ret = obj.pressTime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pressTime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_clickTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			float ret = obj.clickTime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index clickTime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_clickNotification(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UICamera.ClickNotification ret = obj.clickNotification;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index clickNotification on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_touchBegan(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			bool ret = obj.touchBegan;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index touchBegan on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pressStarted(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			bool ret = obj.pressStarted;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pressStarted on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_dragStarted(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			bool ret = obj.dragStarted;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index dragStarted on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ignoreDelta(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			int ret = obj.ignoreDelta;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index ignoreDelta on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_deltaTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			float ret = obj.deltaTime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index deltaTime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isOverUI(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			bool ret = obj.isOverUI;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isOverUI on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_key(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.KeyCode arg0 = (UnityEngine.KeyCode)ToLua.CheckObject(L, 2, typeof(UnityEngine.KeyCode));
			obj.key = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index key on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pos(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.pos = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pos on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_lastPos(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.lastPos = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index lastPos on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_delta(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.delta = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index delta on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_totalDelta(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.totalDelta = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index totalDelta on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pressedCam(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.Camera arg0 = (UnityEngine.Camera)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Camera));
			obj.pressedCam = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pressedCam on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_last(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.GameObject));
			obj.last = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index last on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_current(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.GameObject));
			obj.current = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index current on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pressed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.GameObject));
			obj.pressed = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pressed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_dragged(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.GameObject));
			obj.dragged = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index dragged on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pressTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.pressTime = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pressTime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_clickTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.clickTime = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index clickTime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_clickNotification(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			UICamera.ClickNotification arg0 = (UICamera.ClickNotification)ToLua.CheckObject(L, 2, typeof(UICamera.ClickNotification));
			obj.clickNotification = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index clickNotification on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_touchBegan(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.touchBegan = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index touchBegan on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pressStarted(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.pressStarted = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pressStarted on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_dragStarted(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.dragStarted = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index dragStarted on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ignoreDelta(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UICamera.MouseOrTouch obj = (UICamera.MouseOrTouch)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.ignoreDelta = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index ignoreDelta on a nil value" : e.Message);
		}
	}
}

