﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Serclimax_SLGPVP_ScSLGCampWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Serclimax.SLGPVP.ScSLGCamp), typeof(System.Object));
		L.RegFunction("get_Item", get_Item);
		L.RegFunction("toPhalanxsString", toPhalanxsString);
		L.RegFunction("FillPhalanx4Camp", FillPhalanx4Camp);
		L.RegFunction("EnterCamp", EnterCamp);
		L.RegFunction("Start", Start);
		L.RegFunction("ResetBeatBack", ResetBeatBack);
		L.RegFunction("CheckLived", CheckLived);
		L.RegFunction("GetPhalanx", GetPhalanx);
		L.RegFunction("PT2RestraintRelation", PT2RestraintRelation);
		L.RegFunction("GetRestraintFactor", GetRestraintFactor);
		L.RegFunction("CalculationHurt", CalculationHurt);
		L.RegFunction("SreachPhalanx", SreachPhalanx);
		L.RegFunction("GetInjuredNum", GetInjuredNum);
		L.RegFunction("GetCurCampHp", GetCurCampHp);
		L.RegFunction("GetTotalArmyCount", GetTotalArmyCount);
		L.RegFunction("AdjustHurt", AdjustHurt);
		L.RegFunction("Attack", Attack);
		L.RegFunction("Revert", Revert);
		L.RegFunction("GetTotalExportHurt", GetTotalExportHurt);
		L.RegFunction("CalDeadAccount", CalDeadAccount);
		L.RegFunction("CalKillAccount", CalKillAccount);
		L.RegFunction("CalRevertNumWithRate", CalRevertNumWithRate);
		L.RegFunction("CalInjuredNum", CalInjuredNum);
		L.RegFunction("GetDeadAndLostForce", GetDeadAndLostForce);
		L.RegFunction("GetTotalDead", GetTotalDead);
		L.RegFunction("GetTotalKill", GetTotalKill);
		L.RegFunction("GetLossExp", GetLossExp);
		L.RegFunction("hadVaildExp", hadVaildExp);
		L.RegFunction("FillKillAndInjuredResult", FillKillAndInjuredResult);
		L.RegFunction("New", _CreateSerclimax_SLGPVP_ScSLGCamp);
		L.RegVar("this", _this, null);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("isLived", get_isLived, set_isLived);
		L.RegVar("StartHp", get_StartHp, set_StartHp);
		L.RegVar("players", get_players, set_players);
		L.RegVar("atk_kill_armys", get_atk_kill_armys, set_atk_kill_armys);
		L.RegVar("kill_army_count", get_kill_army_count, set_kill_army_count);
		L.RegVar("atk_injured_armys", get_atk_injured_armys, set_atk_injured_armys);
		L.RegVar("injured_army_count", get_injured_army_count, set_injured_army_count);
		L.RegVar("EnterExtraAttack", get_EnterExtraAttack, set_EnterExtraAttack);
		L.RegVar("PushAttackRoundCB", get_PushAttackRoundCB, set_PushAttackRoundCB);
		L.RegVar("Magic_Factor", get_Magic_Factor, set_Magic_Factor);
		L.RegVar("isActMonster", get_isActMonster, set_isActMonster);
		L.RegVar("deadRate", get_deadRate, set_deadRate);
		L.RegVar("Camp12", get_Camp12, null);
		L.RegVar("Camp34", get_Camp34, null);
		L.RegVar("IsDefend", get_IsDefend, null);
		L.RegFunction("OnAttackCallBack", Serclimax_SLGPVP_ScSLGCamp_OnAttackCallBack);
		L.RegFunction("PushAttackRoundCallBack", Serclimax_SLGPVP_ScSLGCamp_PushAttackRoundCallBack);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateSerclimax_SLGPVP_ScSLGCamp(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				Serclimax.SLGPVP.ScSLGCamp obj = new Serclimax.SLGPVP.ScSLGCamp();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: Serclimax.SLGPVP.ScSLGCamp.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _get_this(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			Serclimax.SLGPVP.ScSLGPhalanx o = obj[arg0];
			ToLua.PushObject(L, o);
			return 1;

		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _this(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushvalue(L, 1);
			LuaDLL.tolua_bindthis(L, _get_this, null);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Item(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			Serclimax.SLGPVP.ScSLGPhalanx o = obj[arg0];
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int toPhalanxsString(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			string o = obj.toPhalanxsString();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FillPhalanx4Camp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			Serclimax.SLGPVP.ScSLGPlayer arg0 = (Serclimax.SLGPVP.ScSLGPlayer)ToLua.CheckObject(L, 2, typeof(Serclimax.SLGPVP.ScSLGPlayer));
			string arg1 = ToLua.CheckString(L, 3);
			obj.FillPhalanx4Camp(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnterCamp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			Serclimax.SLGPVP.ScSLGPlayer arg0 = (Serclimax.SLGPVP.ScSLGPlayer)ToLua.CheckObject(L, 2, typeof(Serclimax.SLGPVP.ScSLGPlayer));
			obj.EnterCamp(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Start(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			obj.Start();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetBeatBack(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			obj.ResetBeatBack();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CheckLived(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			bool o = obj.CheckLived();
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPhalanx(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			Serclimax.SLGPVP.ScSLGPhalanx o = obj.GetPhalanx(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PT2RestraintRelation(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 1);
			int arg1 = (int)LuaDLL.luaL_checknumber(L, 2);
			int o = Serclimax.SLGPVP.ScSLGCamp.PT2RestraintRelation(arg0, arg1);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetRestraintFactor(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			Serclimax.SLGPVP.ScSLGPhalanx arg0 = (Serclimax.SLGPVP.ScSLGPhalanx)ToLua.CheckObject(L, 2, typeof(Serclimax.SLGPVP.ScSLGPhalanx));
			Serclimax.SLGPVP.ScSLGPhalanx arg1 = (Serclimax.SLGPVP.ScSLGPhalanx)ToLua.CheckObject(L, 3, typeof(Serclimax.SLGPVP.ScSLGPhalanx));
			float o = obj.GetRestraintFactor(arg0, arg1);
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalculationHurt(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			Serclimax.SLGPVP.ScSLGPhalanx arg0 = (Serclimax.SLGPVP.ScSLGPhalanx)ToLua.CheckObject(L, 2, typeof(Serclimax.SLGPVP.ScSLGPhalanx));
			Serclimax.SLGPVP.ScSLGPhalanx arg1 = (Serclimax.SLGPVP.ScSLGPhalanx)ToLua.CheckObject(L, 3, typeof(Serclimax.SLGPVP.ScSLGPhalanx));
			Serclimax.ScRandom arg2 = (Serclimax.ScRandom)ToLua.CheckObject(L, 4, typeof(Serclimax.ScRandom));
			float o = obj.CalculationHurt(arg0, arg1, arg2);
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SreachPhalanx(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			Serclimax.SLGPVP.ScSLGPhalanx arg0 = (Serclimax.SLGPVP.ScSLGPhalanx)ToLua.CheckObject(L, 2, typeof(Serclimax.SLGPVP.ScSLGPhalanx));
			Serclimax.SLGPVP.ScSLGCamp arg1 = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 3, typeof(Serclimax.SLGPVP.ScSLGCamp));
			int o = obj.SreachPhalanx(arg0, arg1);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetInjuredNum(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			int o = obj.GetInjuredNum();
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetCurCampHp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			float o = obj.GetCurCampHp();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTotalArmyCount(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			long o = obj.GetTotalArmyCount();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AdjustHurt(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.SLGPVP.ScSLGPhalanx arg0 = (Serclimax.SLGPVP.ScSLGPhalanx)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGPhalanx));
			long arg1 = (long)LuaDLL.luaL_checknumber(L, 2);
			long o = Serclimax.SLGPVP.ScSLGCamp.AdjustHurt(arg0, arg1);
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Attack(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 9);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			Serclimax.SLGPVP.ScSLGCamp arg1 = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 3, typeof(Serclimax.SLGPVP.ScSLGCamp));
			bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
			bool arg3 = LuaDLL.luaL_checkboolean(L, 5);
			Serclimax.ScRandom arg4 = (Serclimax.ScRandom)ToLua.CheckObject(L, 6, typeof(Serclimax.ScRandom));
			bool arg5;
			string arg6 = null;
			Serclimax.SLGPVP.ScSLGCamp.OnAttackCallBack arg7 = null;
			LuaTypes funcType9 = LuaDLL.lua_type(L, 9);

			if (funcType9 != LuaTypes.LUA_TFUNCTION)
			{
				 arg7 = (Serclimax.SLGPVP.ScSLGCamp.OnAttackCallBack)ToLua.CheckObject(L, 9, typeof(Serclimax.SLGPVP.ScSLGCamp.OnAttackCallBack));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 9);
				arg7 = DelegateFactory.CreateDelegate(typeof(Serclimax.SLGPVP.ScSLGCamp.OnAttackCallBack), func) as Serclimax.SLGPVP.ScSLGCamp.OnAttackCallBack;
			}

			bool o = obj.Attack(arg0, arg1, arg2, arg3, arg4, out arg5, out arg6, arg7);
			LuaDLL.lua_pushboolean(L, o);
			LuaDLL.lua_pushboolean(L, arg5);
			LuaDLL.lua_pushstring(L, arg6);
			return 3;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Revert(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.Revert(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTotalExportHurt(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			float[] o = obj.GetTotalExportHurt();
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalDeadAccount(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp)))
			{
				Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.ToObject(L, 1);
				float o = obj.CalDeadAccount();
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp), typeof(float)))
			{
				Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.ToObject(L, 1);
				float arg0 = (float)LuaDLL.lua_tonumber(L, 2);
				float o = obj.CalDeadAccount(arg0);
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: Serclimax.SLGPVP.ScSLGCamp.CalDeadAccount");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalKillAccount(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			Serclimax.SLGPVP.ScSLGCamp arg0 = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 2, typeof(Serclimax.SLGPVP.ScSLGCamp));
			long o = obj.CalKillAccount(arg0);
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalRevertNumWithRate(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			Serclimax.SLGPVP.ScSLGCamp arg1 = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 3, typeof(Serclimax.SLGPVP.ScSLGCamp));
			string o = obj.CalRevertNumWithRate(arg0, arg1);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CalInjuredNum(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			string o = obj.CalInjuredNum(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDeadAndLostForce(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			ulong arg0;
			float arg1;
			obj.GetDeadAndLostForce(out arg0, out arg1);
			LuaDLL.lua_pushnumber(L, arg0);
			LuaDLL.lua_pushnumber(L, arg1);
			return 2;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTotalDead(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			ulong o = obj.GetTotalDead();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTotalKill(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			long o = obj.GetTotalKill();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLossExp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			float o = obj.GetLossExp();
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int hadVaildExp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			bool o = obj.hadVaildExp();
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FillKillAndInjuredResult(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 1, typeof(Serclimax.SLGPVP.ScSLGCamp));
			Serclimax.SLGPVP.ScSLGCamp arg0 = (Serclimax.SLGPVP.ScSLGCamp)ToLua.CheckObject(L, 2, typeof(Serclimax.SLGPVP.ScSLGCamp));
			obj.FillKillAndInjuredResult(arg0);
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
	static int get_isLived(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			bool ret = obj.isLived;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isLived on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_StartHp(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			float ret = obj.StartHp;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index StartHp on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_players(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			System.Collections.Generic.List<Serclimax.SLGPVP.ScSLGPlayer> ret = obj.players;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index players on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_atk_kill_armys(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			System.Collections.Generic.Dictionary<int,Serclimax.SLGPVP.ScSLGATKResult> ret = obj.atk_kill_armys;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index atk_kill_armys on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_kill_army_count(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			long ret = obj.kill_army_count;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index kill_army_count on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_atk_injured_armys(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			System.Collections.Generic.Dictionary<int,Serclimax.SLGPVP.ScSLGATKResult> ret = obj.atk_injured_armys;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index atk_injured_armys on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_injured_army_count(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			long ret = obj.injured_army_count;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index injured_army_count on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EnterExtraAttack(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			bool ret = obj.EnterExtraAttack;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index EnterExtraAttack on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_PushAttackRoundCB(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			Serclimax.SLGPVP.ScSLGCamp.PushAttackRoundCallBack ret = obj.PushAttackRoundCB;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index PushAttackRoundCB on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Magic_Factor(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			float ret = obj.Magic_Factor;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index Magic_Factor on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isActMonster(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			bool ret = obj.isActMonster;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isActMonster on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_deadRate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			float ret = obj.deadRate;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index deadRate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Camp12(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			Serclimax.SLGPVP.ScSLGCamp ret = obj.Camp12;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index Camp12 on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Camp34(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			Serclimax.SLGPVP.ScSLGCamp ret = obj.Camp34;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index Camp34 on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_IsDefend(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			bool ret = obj.IsDefend;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index IsDefend on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isLived(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.isLived = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isLived on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_StartHp(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.StartHp = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index StartHp on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_players(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			System.Collections.Generic.List<Serclimax.SLGPVP.ScSLGPlayer> arg0 = (System.Collections.Generic.List<Serclimax.SLGPVP.ScSLGPlayer>)ToLua.CheckObject(L, 2, typeof(System.Collections.Generic.List<Serclimax.SLGPVP.ScSLGPlayer>));
			obj.players = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index players on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_atk_kill_armys(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			System.Collections.Generic.Dictionary<int,Serclimax.SLGPVP.ScSLGATKResult> arg0 = (System.Collections.Generic.Dictionary<int,Serclimax.SLGPVP.ScSLGATKResult>)ToLua.CheckObject(L, 2, typeof(System.Collections.Generic.Dictionary<int,Serclimax.SLGPVP.ScSLGATKResult>));
			obj.atk_kill_armys = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index atk_kill_armys on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_kill_army_count(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			long arg0 = (long)LuaDLL.luaL_checknumber(L, 2);
			obj.kill_army_count = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index kill_army_count on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_atk_injured_armys(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			System.Collections.Generic.Dictionary<int,Serclimax.SLGPVP.ScSLGATKResult> arg0 = (System.Collections.Generic.Dictionary<int,Serclimax.SLGPVP.ScSLGATKResult>)ToLua.CheckObject(L, 2, typeof(System.Collections.Generic.Dictionary<int,Serclimax.SLGPVP.ScSLGATKResult>));
			obj.atk_injured_armys = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index atk_injured_armys on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_injured_army_count(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			long arg0 = (long)LuaDLL.luaL_checknumber(L, 2);
			obj.injured_army_count = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index injured_army_count on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EnterExtraAttack(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.EnterExtraAttack = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index EnterExtraAttack on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_PushAttackRoundCB(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			Serclimax.SLGPVP.ScSLGCamp.PushAttackRoundCallBack arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (Serclimax.SLGPVP.ScSLGCamp.PushAttackRoundCallBack)ToLua.CheckObject(L, 2, typeof(Serclimax.SLGPVP.ScSLGCamp.PushAttackRoundCallBack));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(Serclimax.SLGPVP.ScSLGCamp.PushAttackRoundCallBack), func) as Serclimax.SLGPVP.ScSLGCamp.PushAttackRoundCallBack;
			}

			obj.PushAttackRoundCB = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index PushAttackRoundCB on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Magic_Factor(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.Magic_Factor = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index Magic_Factor on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isActMonster(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.isActMonster = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isActMonster on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_deadRate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Serclimax.SLGPVP.ScSLGCamp obj = (Serclimax.SLGPVP.ScSLGCamp)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.deadRate = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index deadRate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Serclimax_SLGPVP_ScSLGCamp_OnAttackCallBack(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Serclimax.SLGPVP.ScSLGCamp.OnAttackCallBack), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Serclimax_SLGPVP_ScSLGCamp_PushAttackRoundCallBack(IntPtr L)
	{
		try
		{
			LuaFunction func = ToLua.CheckLuaFunction(L, 1);
			Delegate arg1 = DelegateFactory.CreateDelegate(typeof(Serclimax.SLGPVP.ScSLGCamp.PushAttackRoundCallBack), func);
			ToLua.Push(L, arg1);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

