using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class WSdkCallback : MonoBehaviour 
{
	void initCallback(string _param)
	{
		WSdkManager.instance.OnInitCallback (_param);
	}

	void loginCallback(string _param)
	{
		WSdkManager.instance.OnLoginCallback (_param);
	}

	void logoutCallback(string _param)
	{
		WSdkManager.instance.OnLogoutCallback (_param);
	}

	void initServerCallback(string _param)
	{
		WSdkManager.instance.OnInitServerCallback (_param);
	}

	void rechargeCallback(string _param)
	{
		WSdkManager.instance.OnRechargeCallback (_param);
	}

	void exitCallback(string _param)
	{
        WSdkManager.instance.OnExitCallback(_param);
	}

	void socialCallback(string _param)
	{
		WSdkManager.instance.OnSocialCallback (_param);
	}

    void getInventoryListCallback(string _param)
    {
        WSdkManager.instance.OnGetInventoryListCallback(_param);
    }

    void sdkErrorCallback(string _param)
    {
        WSdkManager.instance.OnSDKErrorCallback(_param);
    }

    void wakeupCallback(string _param)
    {
        WSdkManager.instance.OnWakeupCallback(_param);
    }
}
