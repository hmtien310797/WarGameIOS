﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class GameEnviroment_EEnviromentWrap
{
	public static void Register(LuaState L)
	{
		L.BeginEnum(typeof(GameEnviroment.EEnviroment));
		L.RegVar("eDebug", get_eDebug, null);
		L.RegVar("eRelease", get_eRelease, null);
		L.RegVar("eDist", get_eDist, null);
		L.RegFunction("IntToEnum", IntToEnum);
		L.EndEnum();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_eDebug(IntPtr L)
	{
		ToLua.Push(L, GameEnviroment.EEnviroment.eDebug);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_eRelease(IntPtr L)
	{
		ToLua.Push(L, GameEnviroment.EEnviroment.eRelease);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_eDist(IntPtr L)
	{
		ToLua.Push(L, GameEnviroment.EEnviroment.eDist);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IntToEnum(IntPtr L)
	{
		int arg0 = (int)LuaDLL.lua_tonumber(L, 1);
		GameEnviroment.EEnviroment o = (GameEnviroment.EEnviroment)arg0;
		ToLua.Push(L, o);
		return 1;
	}
}

