﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class AudioManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(AudioManager), typeof(Clishow.CsSingletonBehaviour<AudioManager>));
		L.RegFunction("ClearData", ClearData);
		L.RegFunction("Update", Update);
		L.RegFunction("PlaySfx", PlaySfx);
		L.RegFunction("MusicSwitch", MusicSwitch);
		L.RegFunction("SfxSwitch", SfxSwitch);
		L.RegFunction("SfxIsPlaying", SfxIsPlaying);
		L.RegFunction("PlayUISfx", PlayUISfx);
		L.RegFunction("PlayCommonSfx", PlayCommonSfx);
		L.RegFunction("AddAudioSourceListner", AddAudioSourceListner);
		L.RegFunction("GetSfxActiceCount", GetSfxActiceCount);
		L.RegFunction("GetSfx", GetSfx);
		L.RegFunction("UpdateAudioClip", UpdateAudioClip);
		L.RegFunction("AddBattleAudio", AddBattleAudio);
		L.RegFunction("PlayMusic", PlayMusic);
		L.RegFunction("StopMusic", StopMusic);
		L.RegFunction("PauseSfx", PauseSfx);
		L.RegFunction("ResumeSfx", ResumeSfx);
		L.RegFunction("StopSfx", StopSfx);
		L.RegFunction("SetMusic", SetMusic);
		L.RegFunction("EnableDefaultListener", EnableDefaultListener);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("instance", get_instance, set_instance);
		L.RegVar("enableLog", get_enableLog, set_enableLog);
		L.RegVar("mUnitSfxCountData", get_mUnitSfxCountData, set_mUnitSfxCountData);
		L.RegVar("MusicSwith", get_MusicSwith, null);
		L.RegVar("SfxSwith", get_SfxSwith, null);
		L.RegVar("UnitSfxCountData", get_UnitSfxCountData, set_UnitSfxCountData);
		L.RegVar("AudioVolData", get_AudioVolData, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearData(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			obj.ClearData();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Update(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			obj.Update();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlaySfx(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(AudioManager), typeof(UnityEngine.AudioSource), typeof(string)))
			{
				AudioManager obj = (AudioManager)ToLua.ToObject(L, 1);
				UnityEngine.AudioSource arg0 = (UnityEngine.AudioSource)ToLua.ToObject(L, 2);
				string arg1 = ToLua.ToString(L, 3);
				bool o = obj.PlaySfx(arg0, arg1);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 4 && TypeChecker.CheckTypes(L, 1, typeof(AudioManager), typeof(string), typeof(float), typeof(bool)))
			{
				AudioManager obj = (AudioManager)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				bool arg2 = LuaDLL.lua_toboolean(L, 4);
				obj.PlaySfx(arg0, arg1, arg2);
				return 0;
			}
			else if (count == 4 && TypeChecker.CheckTypes(L, 1, typeof(AudioManager), typeof(UnityEngine.AudioClip), typeof(float), typeof(bool)))
			{
				AudioManager obj = (AudioManager)ToLua.ToObject(L, 1);
				UnityEngine.AudioClip arg0 = (UnityEngine.AudioClip)ToLua.ToObject(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				bool arg2 = LuaDLL.lua_toboolean(L, 4);
				obj.PlaySfx(arg0, arg1, arg2);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: AudioManager.PlaySfx");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int MusicSwitch(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.MusicSwitch(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SfxSwitch(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.SfxSwitch(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SfxIsPlaying(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			bool o = obj.SfxIsPlaying();
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayUISfx(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			string arg0 = ToLua.CheckString(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
			obj.PlayUISfx(arg0, arg1, arg2);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayCommonSfx(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			string arg0 = ToLua.CheckString(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
			obj.PlayCommonSfx(arg0, arg1, arg2);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddAudioSourceListner(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.AudioSource arg1 = (UnityEngine.AudioSource)ToLua.CheckUnityObject(L, 3, typeof(UnityEngine.AudioSource));
			obj.AddAudioSourceListner(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetSfxActiceCount(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			string arg0 = ToLua.CheckString(L, 2);
			int o = obj.GetSfxActiceCount(arg0);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetSfx(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.AudioClip o = obj.GetSfx(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UpdateAudioClip(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.AudioSource arg1 = (UnityEngine.AudioSource)ToLua.CheckUnityObject(L, 3, typeof(UnityEngine.AudioSource));
			obj.UpdateAudioClip(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddBattleAudio(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			UnityEngine.AudioSource arg0 = (UnityEngine.AudioSource)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.AudioSource));
			obj.AddBattleAudio(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PlayMusic(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 5 && TypeChecker.CheckTypes(L, 1, typeof(AudioManager), typeof(string), typeof(float), typeof(bool), typeof(float)))
			{
				AudioManager obj = (AudioManager)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				bool arg2 = LuaDLL.lua_toboolean(L, 4);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 5);
				obj.PlayMusic(arg0, arg1, arg2, arg3);
				return 0;
			}
			else if (count == 5 && TypeChecker.CheckTypes(L, 1, typeof(AudioManager), typeof(UnityEngine.AudioClip), typeof(float), typeof(bool), typeof(float)))
			{
				AudioManager obj = (AudioManager)ToLua.ToObject(L, 1);
				UnityEngine.AudioClip arg0 = (UnityEngine.AudioClip)ToLua.ToObject(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				bool arg2 = LuaDLL.lua_toboolean(L, 4);
				float arg3 = (float)LuaDLL.lua_tonumber(L, 5);
				obj.PlayMusic(arg0, arg1, arg2, arg3);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: AudioManager.PlayMusic");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StopMusic(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			obj.StopMusic();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PauseSfx(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			obj.PauseSfx();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResumeSfx(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			obj.ResumeSfx();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StopSfx(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			obj.StopSfx();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetMusic(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.SetMusic(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnableDefaultListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			AudioManager obj = (AudioManager)ToLua.CheckObject(L, 1, typeof(AudioManager));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.EnableDefaultListener(arg0);
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
	static int get_instance(IntPtr L)
	{
		try
		{
			ToLua.Push(L, AudioManager.instance);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_enableLog(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AudioManager obj = (AudioManager)o;
			bool ret = obj.enableLog;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index enableLog on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mUnitSfxCountData(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AudioManager obj = (AudioManager)o;
			Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData> ret = obj.mUnitSfxCountData;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mUnitSfxCountData on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_MusicSwith(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AudioManager obj = (AudioManager)o;
			bool ret = obj.MusicSwith;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index MusicSwith on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_SfxSwith(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AudioManager obj = (AudioManager)o;
			bool ret = obj.SfxSwith;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SfxSwith on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_UnitSfxCountData(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AudioManager obj = (AudioManager)o;
			Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData> ret = obj.UnitSfxCountData;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index UnitSfxCountData on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_AudioVolData(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AudioManager obj = (AudioManager)o;
			System.Collections.Generic.Dictionary<string,float> ret = obj.AudioVolData;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index AudioVolData on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_instance(IntPtr L)
	{
		try
		{
			AudioManager arg0 = (AudioManager)ToLua.CheckUnityObject(L, 2, typeof(AudioManager));
			AudioManager.instance = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_enableLog(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AudioManager obj = (AudioManager)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.enableLog = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index enableLog on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mUnitSfxCountData(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AudioManager obj = (AudioManager)o;
			Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData> arg0 = (Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData>)ToLua.CheckObject(L, 2, typeof(Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData>));
			obj.mUnitSfxCountData = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mUnitSfxCountData on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_UnitSfxCountData(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AudioManager obj = (AudioManager)o;
			Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData> arg0 = (Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData>)ToLua.CheckObject(L, 2, typeof(Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData>));
			obj.UnitSfxCountData = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index UnitSfxCountData on a nil value" : e.Message);
		}
	}
}

