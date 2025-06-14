﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class AnimColltrollerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(AnimColltroller), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("SetFinishCallback", SetFinishCallback);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("finishCallback", get_finishCallback, set_finishCallback);
		L.RegFunction("FinishCallback", AnimColltroller_FinishCallback);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetFinishCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			AnimColltroller obj = (AnimColltroller)ToLua.CheckObject(L, 1, typeof(AnimColltroller));
			AnimColltroller.FinishCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (AnimColltroller.FinishCallback)ToLua.CheckObject(L, 2, typeof(AnimColltroller.FinishCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(AnimColltroller.FinishCallback), func) as AnimColltroller.FinishCallback;
			}

			obj.SetFinishCallback(arg0);
			return 0;
		}
		catch(Exception e)
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
	static int get_finishCallback(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimColltroller obj = (AnimColltroller)o;
			AnimColltroller.FinishCallback ret = obj.finishCallback;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index finishCallback on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_finishCallback(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimColltroller obj = (AnimColltroller)o;
			AnimColltroller.FinishCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (AnimColltroller.FinishCallback)ToLua.CheckObject(L, 2, typeof(AnimColltroller.FinishCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(AnimColltroller.FinishCallback), func) as AnimColltroller.FinishCallback;
			}

			obj.finishCallback = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index finishCallback on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AnimColltroller_FinishCallback(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(AnimColltroller.FinishCallback), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

