using UnityEngine;
using System.Collections;

public class GameVersion
{
    public static string EXE = "11.18";
    public static string BUILD = "001";
    public static string RES = "0";
}


public class GameEnviroment
{
    public enum EEnviroment
    {
        eDebug = 0,
        eRelease,
        eDist,
    };

    public static EEnviroment NETWORK_ENV = EEnviroment.eDebug;        // NEED to change for Distribution
    public static bool NeedAndroidObb = false;
}
