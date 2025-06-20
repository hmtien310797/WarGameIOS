﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_MaterialWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.Material), typeof(UnityEngine.Object));
		L.RegFunction("SetColor", SetColor);
		L.RegFunction("GetColor", GetColor);
		L.RegFunction("SetVector", SetVector);
		L.RegFunction("GetVector", GetVector);
		L.RegFunction("SetTexture", SetTexture);
		L.RegFunction("GetTexture", GetTexture);
		L.RegFunction("SetTextureOffset", SetTextureOffset);
		L.RegFunction("GetTextureOffset", GetTextureOffset);
		L.RegFunction("SetTextureScale", SetTextureScale);
		L.RegFunction("GetTextureScale", GetTextureScale);
		L.RegFunction("SetMatrix", SetMatrix);
		L.RegFunction("GetMatrix", GetMatrix);
		L.RegFunction("SetFloat", SetFloat);
		L.RegFunction("GetFloat", GetFloat);
		L.RegFunction("SetFloatArray", SetFloatArray);
		L.RegFunction("SetVectorArray", SetVectorArray);
		L.RegFunction("SetColorArray", SetColorArray);
		L.RegFunction("SetMatrixArray", SetMatrixArray);
		L.RegFunction("SetInt", SetInt);
		L.RegFunction("GetInt", GetInt);
		L.RegFunction("SetBuffer", SetBuffer);
		L.RegFunction("HasProperty", HasProperty);
		L.RegFunction("GetTag", GetTag);
		L.RegFunction("SetOverrideTag", SetOverrideTag);
		L.RegFunction("Lerp", Lerp);
		L.RegFunction("SetPass", SetPass);
		L.RegFunction("CopyPropertiesFromMaterial", CopyPropertiesFromMaterial);
		L.RegFunction("EnableKeyword", EnableKeyword);
		L.RegFunction("DisableKeyword", DisableKeyword);
		L.RegFunction("IsKeywordEnabled", IsKeywordEnabled);
		L.RegFunction("New", _CreateUnityEngine_Material);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("shader", get_shader, set_shader);
		L.RegVar("color", get_color, set_color);
		L.RegVar("mainTexture", get_mainTexture, set_mainTexture);
		L.RegVar("mainTextureOffset", get_mainTextureOffset, set_mainTextureOffset);
		L.RegVar("mainTextureScale", get_mainTextureScale, set_mainTextureScale);
		L.RegVar("passCount", get_passCount, null);
		L.RegVar("renderQueue", get_renderQueue, set_renderQueue);
		L.RegVar("shaderKeywords", get_shaderKeywords, set_shaderKeywords);
		L.RegVar("globalIlluminationFlags", get_globalIlluminationFlags, set_globalIlluminationFlags);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_Material(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material)))
			{
				UnityEngine.Material arg0 = (UnityEngine.Material)ToLua.CheckUnityObject(L, 1, typeof(UnityEngine.Material));
				UnityEngine.Material obj = new UnityEngine.Material(arg0);
				ToLua.Push(L, obj);
				return 1;
			}
			else if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Shader)))
			{
				UnityEngine.Shader arg0 = (UnityEngine.Shader)ToLua.CheckUnityObject(L, 1, typeof(UnityEngine.Shader));
				UnityEngine.Material obj = new UnityEngine.Material(arg0);
				ToLua.Push(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.Material.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetColor(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(UnityEngine.Color)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Color arg1 = ToLua.ToColor(L, 3);
				obj.SetColor(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(UnityEngine.Color)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Color arg1 = ToLua.ToColor(L, 3);
				obj.SetColor(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetColor");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetColor(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Color o = obj.GetColor(arg0);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Color o = obj.GetColor(arg0);
				ToLua.Push(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.GetColor");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetVector(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(UnityEngine.Vector4)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Vector4 arg1 = ToLua.ToVector4(L, 3);
				obj.SetVector(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(UnityEngine.Vector4)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Vector4 arg1 = ToLua.ToVector4(L, 3);
				obj.SetVector(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetVector");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetVector(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Vector4 o = obj.GetVector(arg0);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Vector4 o = obj.GetVector(arg0);
				ToLua.Push(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.GetVector");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetTexture(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(UnityEngine.Texture)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Texture arg1 = (UnityEngine.Texture)ToLua.ToObject(L, 3);
				obj.SetTexture(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(UnityEngine.Texture)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Texture arg1 = (UnityEngine.Texture)ToLua.ToObject(L, 3);
				obj.SetTexture(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetTexture");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTexture(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Texture o = obj.GetTexture(arg0);
				ToLua.Push(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Texture o = obj.GetTexture(arg0);
				ToLua.Push(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.GetTexture");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetTextureOffset(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.Vector2 arg1 = ToLua.ToVector2(L, 3);
			obj.SetTextureOffset(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTextureOffset(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.Vector2 o = obj.GetTextureOffset(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetTextureScale(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.Vector2 arg1 = ToLua.ToVector2(L, 3);
			obj.SetTextureScale(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTextureScale(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			string arg0 = ToLua.CheckString(L, 2);
			UnityEngine.Vector2 o = obj.GetTextureScale(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetMatrix(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(UnityEngine.Matrix4x4)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Matrix4x4 arg1 = (UnityEngine.Matrix4x4)ToLua.ToObject(L, 3);
				obj.SetMatrix(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(UnityEngine.Matrix4x4)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Matrix4x4 arg1 = (UnityEngine.Matrix4x4)ToLua.ToObject(L, 3);
				obj.SetMatrix(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetMatrix");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetMatrix(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Matrix4x4 o = obj.GetMatrix(arg0);
				ToLua.PushValue(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Matrix4x4 o = obj.GetMatrix(arg0);
				ToLua.PushValue(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.GetMatrix");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetFloat(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(float)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				obj.SetFloat(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(float)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				obj.SetFloat(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetFloat");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFloat(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				float o = obj.GetFloat(arg0);
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				float o = obj.GetFloat(arg0);
				LuaDLL.lua_pushnumber(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.GetFloat");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetFloatArray(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(float[])))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				float[] arg1 = ToLua.CheckNumberArray<float>(L, 3);
				obj.SetFloatArray(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(float[])))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				float[] arg1 = ToLua.CheckNumberArray<float>(L, 3);
				obj.SetFloatArray(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetFloatArray");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetVectorArray(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(UnityEngine.Vector4[])))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Vector4[] arg1 = ToLua.CheckObjectArray<UnityEngine.Vector4>(L, 3);
				obj.SetVectorArray(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(UnityEngine.Vector4[])))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Vector4[] arg1 = ToLua.CheckObjectArray<UnityEngine.Vector4>(L, 3);
				obj.SetVectorArray(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetVectorArray");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetColorArray(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(UnityEngine.Color[])))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Color[] arg1 = ToLua.CheckObjectArray<UnityEngine.Color>(L, 3);
				obj.SetColorArray(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(UnityEngine.Color[])))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Color[] arg1 = ToLua.CheckObjectArray<UnityEngine.Color>(L, 3);
				obj.SetColorArray(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetColorArray");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetMatrixArray(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(UnityEngine.Matrix4x4[])))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.Matrix4x4[] arg1 = ToLua.CheckObjectArray<UnityEngine.Matrix4x4>(L, 3);
				obj.SetMatrixArray(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(UnityEngine.Matrix4x4[])))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.Matrix4x4[] arg1 = ToLua.CheckObjectArray<UnityEngine.Matrix4x4>(L, 3);
				obj.SetMatrixArray(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetMatrixArray");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetInt(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(int)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				int arg1 = (int)LuaDLL.lua_tonumber(L, 3);
				obj.SetInt(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(int)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				int arg1 = (int)LuaDLL.lua_tonumber(L, 3);
				obj.SetInt(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetInt");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetInt(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				int o = obj.GetInt(arg0);
				LuaDLL.lua_pushinteger(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				int o = obj.GetInt(arg0);
				LuaDLL.lua_pushinteger(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.GetInt");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetBuffer(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int), typeof(UnityEngine.ComputeBuffer)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				UnityEngine.ComputeBuffer arg1 = (UnityEngine.ComputeBuffer)ToLua.ToObject(L, 3);
				obj.SetBuffer(arg0, arg1);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(UnityEngine.ComputeBuffer)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				UnityEngine.ComputeBuffer arg1 = (UnityEngine.ComputeBuffer)ToLua.ToObject(L, 3);
				obj.SetBuffer(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.SetBuffer");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HasProperty(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(int)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				bool o = obj.HasProperty(arg0);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				bool o = obj.HasProperty(arg0);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.HasProperty");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTag(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(bool)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				bool arg1 = LuaDLL.lua_toboolean(L, 3);
				string o = obj.GetTag(arg0, arg1);
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else if (count == 4 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.Material), typeof(string), typeof(bool), typeof(string)))
			{
				UnityEngine.Material obj = (UnityEngine.Material)ToLua.ToObject(L, 1);
				string arg0 = ToLua.ToString(L, 2);
				bool arg1 = LuaDLL.lua_toboolean(L, 3);
				string arg2 = ToLua.ToString(L, 4);
				string o = obj.GetTag(arg0, arg1, arg2);
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.Material.GetTag");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetOverrideTag(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			obj.SetOverrideTag(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Lerp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			UnityEngine.Material arg0 = (UnityEngine.Material)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Material));
			UnityEngine.Material arg1 = (UnityEngine.Material)ToLua.CheckUnityObject(L, 3, typeof(UnityEngine.Material));
			float arg2 = (float)LuaDLL.luaL_checknumber(L, 4);
			obj.Lerp(arg0, arg1, arg2);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetPass(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			bool o = obj.SetPass(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CopyPropertiesFromMaterial(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			UnityEngine.Material arg0 = (UnityEngine.Material)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Material));
			obj.CopyPropertiesFromMaterial(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnableKeyword(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			string arg0 = ToLua.CheckString(L, 2);
			obj.EnableKeyword(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DisableKeyword(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			string arg0 = ToLua.CheckString(L, 2);
			obj.DisableKeyword(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsKeywordEnabled(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Material obj = (UnityEngine.Material)ToLua.CheckObject(L, 1, typeof(UnityEngine.Material));
			string arg0 = ToLua.CheckString(L, 2);
			bool o = obj.IsKeywordEnabled(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
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
	static int get_shader(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Shader ret = obj.shader;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index shader on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_color(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Color ret = obj.color;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index color on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mainTexture(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Texture ret = obj.mainTexture;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mainTexture on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mainTextureOffset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Vector2 ret = obj.mainTextureOffset;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mainTextureOffset on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mainTextureScale(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Vector2 ret = obj.mainTextureScale;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mainTextureScale on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_passCount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			int ret = obj.passCount;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index passCount on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_renderQueue(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			int ret = obj.renderQueue;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index renderQueue on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_shaderKeywords(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			string[] ret = obj.shaderKeywords;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index shaderKeywords on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_globalIlluminationFlags(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.MaterialGlobalIlluminationFlags ret = obj.globalIlluminationFlags;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index globalIlluminationFlags on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_shader(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Shader arg0 = (UnityEngine.Shader)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Shader));
			obj.shader = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index shader on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_color(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Color arg0 = ToLua.ToColor(L, 2);
			obj.color = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index color on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mainTexture(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Texture arg0 = (UnityEngine.Texture)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Texture));
			obj.mainTexture = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mainTexture on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mainTextureOffset(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.mainTextureOffset = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mainTextureOffset on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mainTextureScale(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.mainTextureScale = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mainTextureScale on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_renderQueue(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.renderQueue = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index renderQueue on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_shaderKeywords(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			string[] arg0 = ToLua.CheckStringArray(L, 2);
			obj.shaderKeywords = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index shaderKeywords on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_globalIlluminationFlags(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Material obj = (UnityEngine.Material)o;
			UnityEngine.MaterialGlobalIlluminationFlags arg0 = (UnityEngine.MaterialGlobalIlluminationFlags)ToLua.CheckObject(L, 2, typeof(UnityEngine.MaterialGlobalIlluminationFlags));
			obj.globalIlluminationFlags = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index globalIlluminationFlags on a nil value" : e.Message);
		}
	}
}

