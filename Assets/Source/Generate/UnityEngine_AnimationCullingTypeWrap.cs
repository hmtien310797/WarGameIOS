﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_AnimationCullingTypeWrap
{
	public static void Register(LuaState L)
	{
		L.BeginEnum(typeof(UnityEngine.AnimationCullingType));
		L.RegVar("AlwaysAnimate", get_AlwaysAnimate, null);
		L.RegVar("BasedOnRenderers", get_BasedOnRenderers, null);
		L.RegFunction("IntToEnum", IntToEnum);
		L.EndEnum();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_AlwaysAnimate(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.AnimationCullingType.AlwaysAnimate);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_BasedOnRenderers(IntPtr L)
	{
		ToLua.Push(L, UnityEngine.AnimationCullingType.BasedOnRenderers);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IntToEnum(IntPtr L)
	{
		int arg0 = (int)LuaDLL.lua_tonumber(L, 1);
		UnityEngine.AnimationCullingType o = (UnityEngine.AnimationCullingType)arg0;
		ToLua.Push(L, o);
		return 1;
	}
}

