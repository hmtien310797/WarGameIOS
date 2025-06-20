﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Serclimax_Player_ScPlayerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Serclimax.Player.ScPlayer), typeof(System.Object));
		L.RegFunction("Init", Init);
		L.RegFunction("OnSceneLoadFinished", OnSceneLoadFinished);
		L.RegFunction("RequestCast4RedCmd", RequestCast4RedCmd);
		L.RegFunction("RequestCast2RedCmd", RequestCast2RedCmd);
		L.RegFunction("RequestCast", RequestCast);
		L.RegFunction("New", _CreateSerclimax_Player_ScPlayer);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegConstant("MaxHeroCount", 5);
		L.RegVar("playerInfo", get_playerInfo, set_playerInfo);
		L.RegVar("groupCooldown", get_groupCooldown, set_groupCooldown);
		L.RegVar("MaxArmyID", get_MaxArmyID, null);
		L.RegVar("CollectorMgr", get_CollectorMgr, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateSerclimax_Player_ScPlayer(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				Serclimax.Player.ScPlayer obj = new Serclimax.Player.ScPlayer();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: Serclimax.Player.ScPlayer.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Init(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)ToLua.CheckObject(L, 1, typeof(Serclimax.Player.ScPlayer));
			Serclimax.Battle.ScBattle arg0 = (Serclimax.Battle.ScBattle)ToLua.CheckObject(L, 2, typeof(Serclimax.Battle.ScBattle));
			obj.Init(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnSceneLoadFinished(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)ToLua.CheckObject(L, 1, typeof(Serclimax.Player.ScPlayer));
			obj.OnSceneLoadFinished();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RequestCast4RedCmd(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)ToLua.CheckObject(L, 1, typeof(Serclimax.Player.ScPlayer));
			Serclimax.ScRecordMgr.RedCommand[] arg0 = ToLua.CheckObjectArray<Serclimax.ScRecordMgr.RedCommand>(L, 2);
			obj.RequestCast4RedCmd(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RequestCast2RedCmd(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)ToLua.CheckObject(L, 1, typeof(Serclimax.Player.ScPlayer));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Vector3 arg1 = ToLua.ToVector3(L, 3);
			Serclimax.ScRecordMgr.RedCommand[] o = obj.RequestCast2RedCmd(arg0, arg1);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RequestCast(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)ToLua.CheckObject(L, 1, typeof(Serclimax.Player.ScPlayer));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Vector3 arg1 = ToLua.ToVector3(L, 3);
			obj.RequestCast(arg0, arg1);
			return 0;
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
	static int get_playerInfo(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)o;
			Serclimax.Player.ScPlayerInfo ret = obj.playerInfo;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index playerInfo on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_groupCooldown(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)o;
			float ret = obj.groupCooldown;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index groupCooldown on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_MaxArmyID(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)o;
			Serclimax.Player.ScPlayerMaxArmyID ret = obj.MaxArmyID;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index MaxArmyID on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_CollectorMgr(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)o;
			Serclimax.ScCollectorMgr ret = obj.CollectorMgr;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index CollectorMgr on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_playerInfo(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)o;
			Serclimax.Player.ScPlayerInfo arg0 = (Serclimax.Player.ScPlayerInfo)ToLua.CheckObject(L, 2, typeof(Serclimax.Player.ScPlayerInfo));
			obj.playerInfo = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index playerInfo on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_groupCooldown(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.Player.ScPlayer obj = (Serclimax.Player.ScPlayer)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.groupCooldown = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index groupCooldown on a nil value" : e.Message);
		}
	}
}

