﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ProtoMsg_SEntryResourceWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ProtoMsg.SEntryResource), typeof(System.Object));
		L.RegFunction("New", _CreateProtoMsg_SEntryResource);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("level", get_level, set_level);
		L.RegVar("num", get_num, set_num);
		L.RegVar("owner", get_owner, set_owner);
		L.RegVar("lastowner", get_lastowner, set_lastowner);
		L.RegVar("takestarttime", get_takestarttime, set_takestarttime);
		L.RegVar("taketime", get_taketime, set_taketime);
		L.RegVar("ownername", get_ownername, set_ownername);
		L.RegVar("lastownername", get_lastownername, set_lastownername);
		L.RegVar("takespeed", get_takespeed, set_takespeed);
		L.RegVar("ownerhomelvl", get_ownerhomelvl, set_ownerhomelvl);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateProtoMsg_SEntryResource(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				ProtoMsg.SEntryResource obj = new ProtoMsg.SEntryResource();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: ProtoMsg.SEntryResource.New");
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
	static int get_level(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint ret = obj.level;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index level on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_num(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint ret = obj.num;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index num on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_owner(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint ret = obj.owner;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index owner on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_lastowner(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint ret = obj.lastowner;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index lastowner on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_takestarttime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint ret = obj.takestarttime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index takestarttime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_taketime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint ret = obj.taketime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index taketime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ownername(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			string ret = obj.ownername;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index ownername on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_lastownername(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			string ret = obj.lastownername;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index lastownername on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_takespeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint ret = obj.takespeed;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index takespeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ownerhomelvl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint ret = obj.ownerhomelvl;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index ownerhomelvl on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_level(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.level = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index level on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_num(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.num = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index num on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_owner(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.owner = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index owner on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_lastowner(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.lastowner = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index lastowner on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_takestarttime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.takestarttime = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index takestarttime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_taketime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.taketime = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index taketime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ownername(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.ownername = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index ownername on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_lastownername(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.lastownername = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index lastownername on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_takespeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.takespeed = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index takespeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ownerhomelvl(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ProtoMsg.SEntryResource obj = (ProtoMsg.SEntryResource)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.ownerhomelvl = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index ownerhomelvl on a nil value" : e.Message);
		}
	}
}

