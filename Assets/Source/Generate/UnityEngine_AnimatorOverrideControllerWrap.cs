﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_AnimatorOverrideControllerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.AnimatorOverrideController), typeof(UnityEngine.RuntimeAnimatorController));
		L.RegFunction("get_Item", get_Item);
		L.RegFunction("set_Item", set_Item);
		L.RegFunction("New", _CreateUnityEngine_AnimatorOverrideController);
		L.RegVar("this", _this, null);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("runtimeAnimatorController", get_runtimeAnimatorController, set_runtimeAnimatorController);
		L.RegVar("clips", get_clips, set_clips);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_AnimatorOverrideController(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.AnimatorOverrideController obj = new UnityEngine.AnimatorOverrideController();
				ToLua.Push(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.AnimatorOverrideController.New");
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
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.AnimatorOverrideController), typeof(UnityEngine.AnimationClip)))
			{
				UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)ToLua.ToObject(L, 1);
				UnityEngine.AnimationClip arg0 = (UnityEngine.AnimationClip)ToLua.ToObject(L, 2);
				UnityEngine.AnimationClip o = obj[arg0];
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.AnimatorOverrideController), typeof(string)))
			{
				UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.AnimationClip o = obj[arg0];
				ToLua.Push(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to operator method: UnityEngine.AnimatorOverrideController.this");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _set_this(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.AnimatorOverrideController), typeof(UnityEngine.AnimationClip), typeof(UnityEngine.AnimationClip)))
			{
				UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)ToLua.ToObject(L, 1);
				UnityEngine.AnimationClip arg0 = (UnityEngine.AnimationClip)ToLua.ToObject(L, 2);
				UnityEngine.AnimationClip arg1 = (UnityEngine.AnimationClip)ToLua.ToObject(L, 3);
				obj[arg0] = arg1;
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.AnimatorOverrideController), typeof(string), typeof(UnityEngine.AnimationClip)))
			{
				UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.AnimationClip arg1 = (UnityEngine.AnimationClip)ToLua.ToObject(L, 3);
				obj[arg0] = arg1;
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to operator method: UnityEngine.AnimatorOverrideController.this");
			}
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
			LuaDLL.tolua_bindthis(L, _get_this, _set_this);
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
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.AnimatorOverrideController), typeof(UnityEngine.AnimationClip)))
			{
				UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)ToLua.ToObject(L, 1);
				UnityEngine.AnimationClip arg0 = (UnityEngine.AnimationClip)ToLua.ToObject(L, 2);
				UnityEngine.AnimationClip o = obj[arg0];
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.AnimatorOverrideController), typeof(string)))
			{
				UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.AnimationClip o = obj[arg0];
				ToLua.Push(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.AnimatorOverrideController.get_Item");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Item(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.AnimatorOverrideController), typeof(UnityEngine.AnimationClip), typeof(UnityEngine.AnimationClip)))
			{
				UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)ToLua.ToObject(L, 1);
				UnityEngine.AnimationClip arg0 = (UnityEngine.AnimationClip)ToLua.ToObject(L, 2);
				UnityEngine.AnimationClip arg1 = (UnityEngine.AnimationClip)ToLua.ToObject(L, 3);
				obj[arg0] = arg1;
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.AnimatorOverrideController), typeof(string), typeof(UnityEngine.AnimationClip)))
			{
				UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.AnimationClip arg1 = (UnityEngine.AnimationClip)ToLua.ToObject(L, 3);
				obj[arg0] = arg1;
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.AnimatorOverrideController.set_Item");
			}
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
	static int get_runtimeAnimatorController(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)o;
			UnityEngine.RuntimeAnimatorController ret = obj.runtimeAnimatorController;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index runtimeAnimatorController on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_clips(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)o;
			UnityEngine.AnimationClipPair[] ret = obj.clips;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index clips on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_runtimeAnimatorController(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)o;
			UnityEngine.RuntimeAnimatorController arg0 = (UnityEngine.RuntimeAnimatorController)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.RuntimeAnimatorController));
			obj.runtimeAnimatorController = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index runtimeAnimatorController on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_clips(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimatorOverrideController obj = (UnityEngine.AnimatorOverrideController)o;
			UnityEngine.AnimationClipPair[] arg0 = ToLua.CheckObjectArray<UnityEngine.AnimationClipPair>(L, 2);
			obj.clips = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index clips on a nil value" : e.Message);
		}
	}
}

