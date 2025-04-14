using System;
using LuaInterface;
using System.Text;
//using UnityEngine;

public static class LuaNetwork
{
    [LuaByteBufferAttribute]
    public delegate void CallbackFunc(uint _seq_id, byte[] _data);

    public static uint Request(uint _category_id, uint _type_id, LuaByteBuffer _data, CallbackFunc _callback, bool _lockScreen)
    {
        //Debug.Log("cid : " + _category_id + "  _type_id :" + _type_id + " _pc:" + pc.GetType().GetProperties());
        return NetworkManager.instance.RequestLua(_category_id, _type_id, _data.buffer, _callback, _lockScreen);
    }

    public static void Response(uint _seq_id, byte[] _data, CallbackFunc _callback)
    {
        if (_callback != null)
        {
            _callback(_seq_id, _data);
        }
    }

    public static void RegisterPush(uint _category_id, uint _type_id, CallbackFunc _func)
    {
        NetworkManager.instance.RegisterPushMsgCallbackLua(_category_id, _type_id, _func);
    }
    public static bool EnableLog()
    {
        return NetworkManager.instance.enableLog;
    }
}