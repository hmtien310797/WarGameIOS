﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ProtoMsg_ActGuildMonsterInfoWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ProtoMsg.ActGuildMonsterInfo), typeof(System.Object));
		L.RegFunction("New", _CreateProtoMsg_ActGuildMonsterInfo);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("guildMonster", get_guildMonster, set_guildMonster);
		L.RegVar("guildMonsterState", get_guildMonsterState, set_guildMonsterState);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateProtoMsg_ActGuildMonsterInfo(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				ProtoMsg.ActGuildMonsterInfo obj = new ProtoMsg.ActGuildMonsterInfo();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: ProtoMsg.ActGuildMonsterInfo.New");
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
	static int get_guildMonster(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.ActGuildMonsterInfo obj = (ProtoMsg.ActGuildMonsterInfo)o;
			bool ret = obj.guildMonster;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index guildMonster on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_guildMonsterState(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.ActGuildMonsterInfo obj = (ProtoMsg.ActGuildMonsterInfo)o;
			uint ret = obj.guildMonsterState;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index guildMonsterState on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_guildMonster(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.ActGuildMonsterInfo obj = (ProtoMsg.ActGuildMonsterInfo)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.guildMonster = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index guildMonster on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_guildMonsterState(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.ActGuildMonsterInfo obj = (ProtoMsg.ActGuildMonsterInfo)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.guildMonsterState = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index guildMonsterState on a nil value" : e.Message);
		}
	}
}

