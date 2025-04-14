using UnityEngine;
using System.Collections;
using LuaInterface;
using System;

public class LuaBehaviour : MonoBehaviour
{
    private LuaTable moduleTable;

    private LuaFunction awakeFunc;

    private LuaFunction startFunc;

    private LuaFunction updateFunc;

    private LuaFunction lateUpdateFunc;

    private LuaFunction onDestroyFunc;

    private LuaFunction enabledFunc;

    private LuaFunction disabledFunc;

    void Awake()
    {
        RequireLuaModule();
        awakeFunc = GetModuleFunc("Awake");
        startFunc = GetModuleFunc("Start");
        updateFunc = GetModuleFunc("Update");
        lateUpdateFunc = GetModuleFunc("LateUpdate");
        onDestroyFunc = GetModuleFunc("OnDestroy");
        enabledFunc = GetModuleFunc("OnEnable");
        disabledFunc = GetModuleFunc("OnDisable");
        if (awakeFunc != null)
        {
            awakeFunc.Call();
        }
    }

    void Start()
    {
        if (startFunc != null)
        {
            startFunc.Call();
        }

        if (GUIMgr.Instance.onMenuOpen != null)
        {
            GUIMgr.Instance.onMenuOpen(name);
        }
    }

    void Update()
    {
#if PROFILER
        Profiler.BeginSample("LuaBehaviour_Update");
#endif
        if (updateFunc != null)
        {
            updateFunc.Call();
        }
#if PROFILER
        Profiler.EndSample();
#endif
    }

    void LateUpdate()
    {
#if PROFILER
        Profiler.BeginSample("LuaBehaviour_LateUpdate");
#endif
        if (lateUpdateFunc != null)
        {
            lateUpdateFunc.Call();
        }
#if PROFILER
        Profiler.EndSample();
#endif
    }

    public void Close()
    {
        CallFunc("Close", null);
        GUIMgr.Instance.__Internal_RemoveMenu(this);
    }

    void OnDestroy()
    {
        if (onDestroyFunc != null)
        {
            onDestroyFunc.Call();
        }
        SafeRelease(ref awakeFunc);
        SafeRelease(ref startFunc);
        SafeRelease(ref updateFunc);
        SafeRelease(ref lateUpdateFunc);
        SafeRelease(ref onDestroyFunc);
        SafeRelease(ref enabledFunc);
        SafeRelease(ref disabledFunc);
        if (moduleTable != null)
        {
            moduleTable["this"] = null;
            moduleTable["gameObject"] = null;
            moduleTable["tag"] = null;
            moduleTable["transform"] = null;
            moduleTable.Dispose();
            moduleTable = null;
        }
    }

    private void RequireLuaModule()
    {
        if (name.Contains("(Clone)"))
        {
            name = name.Replace("(Clone)", "");
        }
        moduleTable = LuaClient.GetMainState().GetTable(name);
        if (moduleTable != null)
        {
            moduleTable["this"] = this;
            moduleTable["gameObject"] = gameObject;
            moduleTable["tag"] = tag;
            moduleTable["transform"] = transform;
        }
    }

    public LuaTable GetModuleTable()
    {
        return moduleTable;
    }

    private LuaFunction GetModuleFunc(string funcName)
    {
        return LuaClient.GetMainState().GetFunction(name + "." + funcName, false);
    }

    private object[] GetAndCallModuleFunc(string funcName, object[] args, out LuaFunction luaFunc)
    {
        luaFunc = GetModuleFunc(funcName);

        if (luaFunc != null)
        {
            return luaFunc.Call(args);
        }

        return null;
    }

    private void SafeRelease(ref LuaFunction luaFunc)
    {
        if (luaFunc != null)
        {
            luaFunc.Dispose();
            luaFunc = null;
        }
    }

    public object[] CallFunc(string funcName, object _arg1, object _arg2)
    {
        object[] param = new object[2];
        param[0] = _arg1;
        param[1] = _arg2;

        return CallFunc(funcName, param);
    }

    public object[] CallFunc(string funcName, object _arg1)
    {
        object[] param = new object[1];
        param[0] = _arg1;

        return CallFunc(funcName, param);
    }

    public object[] CallFunc(string funcName, object[] args)
    {
        LuaFunction func = GetModuleFunc(funcName);
        object[] r = null;
        if (func != null)
        {
            r = func.Call(args);
            func.Dispose();
        }
        return r;
    }

    public void Reload()
    {
        Awake();
        Start();
    }

    void OnDisable()
    {
        if (disabledFunc != null)
        {
            disabledFunc.Call();
        }
    }

    void OnEnable()
    {
        if (enabledFunc != null)
        {
            enabledFunc.Call();
        }
    }
}
