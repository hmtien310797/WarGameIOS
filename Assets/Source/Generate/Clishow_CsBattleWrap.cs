﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Clishow_CsBattleWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Clishow.CsBattle), typeof(Clishow.CsSingletonBehaviour<Clishow.CsBattle>));
		L.RegFunction("RequestCast", RequestCast);
		L.RegFunction("RequestCast2RedCmd", RequestCast2RedCmd);
		L.RegFunction("RequestCast4RedCmd", RequestCast4RedCmd);
		L.RegFunction("NotifyTitleFinished", NotifyTitleFinished);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("onBattleInfo", get_onBattleInfo, set_onBattleInfo);
		L.RegVar("onBattleStatus", get_onBattleStatus, set_onBattleStatus);
		L.RegVar("onBattleUpdate", get_onBattleUpdate, set_onBattleUpdate);
		L.RegVar("onPlayerInfo", get_onPlayerInfo, set_onPlayerInfo);
		L.RegVar("onBattleDrop", get_onBattleDrop, set_onBattleDrop);
		L.RegVar("onPlayerUpdate", get_onPlayerUpdate, set_onPlayerUpdate);
		L.RegVar("onDropUpdate", get_onDropUpdate, set_onDropUpdate);
		L.RegVar("onCastSkill", get_onCastSkill, set_onCastSkill);
		L.RegFunction("OnCastSkill", Clishow_CsBattle_OnCastSkill);
		L.RegFunction("OnDropUpdate", Clishow_CsBattle_OnDropUpdate);
		L.RegFunction("OnPlayerUpdate", Clishow_CsBattle_OnPlayerUpdate);
		L.RegFunction("OnBattleDrop", Clishow_CsBattle_OnBattleDrop);
		L.RegFunction("OnPlayerInfo", Clishow_CsBattle_OnPlayerInfo);
		L.RegFunction("OnBattleUpdate", Clishow_CsBattle_OnBattleUpdate);
		L.RegFunction("OnBattleStatus", Clishow_CsBattle_OnBattleStatus);
		L.RegFunction("OnBattleInfo", Clishow_CsBattle_OnBattleInfo);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RequestCast(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Clishow.CsBattle obj = (Clishow.CsBattle)ToLua.CheckObject(L, 1, typeof(Clishow.CsBattle));
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
	static int RequestCast2RedCmd(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Clishow.CsBattle obj = (Clishow.CsBattle)ToLua.CheckObject(L, 1, typeof(Clishow.CsBattle));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Vector3 arg1 = ToLua.ToVector3(L, 3);
			string o = obj.RequestCast2RedCmd(arg0, arg1);
			LuaDLL.lua_pushstring(L, o);
			return 1;
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
			Clishow.CsBattle obj = (Clishow.CsBattle)ToLua.CheckObject(L, 1, typeof(Clishow.CsBattle));
			string arg0 = ToLua.CheckString(L, 2);
			obj.RequestCast4RedCmd(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int NotifyTitleFinished(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)ToLua.CheckObject(L, 1, typeof(Clishow.CsBattle));
			obj.NotifyTitleFinished();
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
	static int get_onBattleInfo(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnBattleInfo ret = obj.onBattleInfo;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onBattleInfo on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onBattleStatus(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnBattleStatus ret = obj.onBattleStatus;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onBattleStatus on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onBattleUpdate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnBattleUpdate ret = obj.onBattleUpdate;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onBattleUpdate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onPlayerInfo(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnPlayerInfo ret = obj.onPlayerInfo;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onPlayerInfo on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onBattleDrop(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnBattleDrop ret = obj.onBattleDrop;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onBattleDrop on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onPlayerUpdate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnPlayerUpdate ret = obj.onPlayerUpdate;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onPlayerUpdate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onDropUpdate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnDropUpdate ret = obj.onDropUpdate;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onDropUpdate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onCastSkill(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnCastSkill ret = obj.onCastSkill;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onCastSkill on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onBattleInfo(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnBattleInfo arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Clishow.CsBattle.OnBattleInfo)ToLua.CheckObject(L, 2, typeof(Clishow.CsBattle.OnBattleInfo));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnBattleInfo), func) as Clishow.CsBattle.OnBattleInfo;
			}

			obj.onBattleInfo = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onBattleInfo on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onBattleStatus(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnBattleStatus arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Clishow.CsBattle.OnBattleStatus)ToLua.CheckObject(L, 2, typeof(Clishow.CsBattle.OnBattleStatus));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnBattleStatus), func) as Clishow.CsBattle.OnBattleStatus;
			}

			obj.onBattleStatus = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onBattleStatus on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onBattleUpdate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnBattleUpdate arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Clishow.CsBattle.OnBattleUpdate)ToLua.CheckObject(L, 2, typeof(Clishow.CsBattle.OnBattleUpdate));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnBattleUpdate), func) as Clishow.CsBattle.OnBattleUpdate;
			}

			obj.onBattleUpdate = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onBattleUpdate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onPlayerInfo(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnPlayerInfo arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Clishow.CsBattle.OnPlayerInfo)ToLua.CheckObject(L, 2, typeof(Clishow.CsBattle.OnPlayerInfo));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnPlayerInfo), func) as Clishow.CsBattle.OnPlayerInfo;
			}

			obj.onPlayerInfo = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onPlayerInfo on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onBattleDrop(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnBattleDrop arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Clishow.CsBattle.OnBattleDrop)ToLua.CheckObject(L, 2, typeof(Clishow.CsBattle.OnBattleDrop));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnBattleDrop), func) as Clishow.CsBattle.OnBattleDrop;
			}

			obj.onBattleDrop = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onBattleDrop on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onPlayerUpdate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnPlayerUpdate arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Clishow.CsBattle.OnPlayerUpdate)ToLua.CheckObject(L, 2, typeof(Clishow.CsBattle.OnPlayerUpdate));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnPlayerUpdate), func) as Clishow.CsBattle.OnPlayerUpdate;
			}

			obj.onPlayerUpdate = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onPlayerUpdate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onDropUpdate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnDropUpdate arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Clishow.CsBattle.OnDropUpdate)ToLua.CheckObject(L, 2, typeof(Clishow.CsBattle.OnDropUpdate));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnDropUpdate), func) as Clishow.CsBattle.OnDropUpdate;
			}

			obj.onDropUpdate = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onDropUpdate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onCastSkill(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Clishow.CsBattle obj = (Clishow.CsBattle)o;
			Clishow.CsBattle.OnCastSkill arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Clishow.CsBattle.OnCastSkill)ToLua.CheckObject(L, 2, typeof(Clishow.CsBattle.OnCastSkill));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnCastSkill), func) as Clishow.CsBattle.OnCastSkill;
			}

			obj.onCastSkill = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index onCastSkill on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clishow_CsBattle_OnCastSkill(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnCastSkill), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clishow_CsBattle_OnDropUpdate(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnDropUpdate), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clishow_CsBattle_OnPlayerUpdate(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnPlayerUpdate), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clishow_CsBattle_OnBattleDrop(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnBattleDrop), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clishow_CsBattle_OnPlayerInfo(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnPlayerInfo), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clishow_CsBattle_OnBattleUpdate(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnBattleUpdate), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clishow_CsBattle_OnBattleStatus(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnBattleStatus), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clishow_CsBattle_OnBattleInfo(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Clishow.CsBattle.OnBattleInfo), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

