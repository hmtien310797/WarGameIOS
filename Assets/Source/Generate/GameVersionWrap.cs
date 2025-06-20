﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class GameVersionWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(GameVersion), typeof(System.Object));
		L.RegFunction("New", _CreateGameVersion);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("EXE", get_EXE, set_EXE);
		L.RegVar("BUILD", get_BUILD, set_BUILD);
		L.RegVar("RES", get_RES, set_RES);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateGameVersion(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				GameVersion obj = new GameVersion();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: GameVersion.New");
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
	static int get_EXE(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, GameVersion.EXE);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_BUILD(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, GameVersion.BUILD);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_RES(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushstring(L, GameVersion.RES);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EXE(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 2);
			GameVersion.EXE = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_BUILD(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 2);
			GameVersion.BUILD = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_RES(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 2);
			GameVersion.RES = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

