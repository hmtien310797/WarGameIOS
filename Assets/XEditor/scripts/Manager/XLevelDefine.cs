using UnityEngine;
using System.Collections;

public static class XLevelDefine
{
    public static string ASSET_R_PATH = "Assets/XEditor/Resources/";
    public static string ASSET_R_PATH1 = "/XEditor/Resources/";


    public static string ART_RESOURCE_PATH = "/Art/Prefabs/";
    //public static string ART_RESOURCE_DATABASE_PATH = "Assets/Art/Prefabs/";
    public static string ART_RESOURCE_UNITS_PATH = "Unit/";
    public static string ART_RESOURCE_OBJS_PATH = "Object/";
    public static string ART_RESOURCE_Level_PATH = "Level/";

    public static string ASSET_RLEVEL_PATH = "level/";
    public static string ASSET_LEVELOBJECT_PATH = "obj/";
    public static string ASSET_RESOURCE_PATH = "Assets/Resources/";
    public static string RESOURCE_PATH = "/Resources/";


    public static string ASSET_LEVELOBJECT_UNITS_PATH = "units/";
    public static string ASSET_LEVELOBJECT_CONSTRUCTS_PATH = "constructs/";
    public static string ASSET_LEVELOBJECT_DEFENSES_PATH = "defense/";


	public static string LEVEL_PATH = "wlevels/";
	public static string SCENE_PATH = "/scene/";
	public static string LEVEL_CAMERA_PATH = "/camera/";
    public static string LEVEL_OBJECT_PATH = "/objects/";
    public static string LEVEL_DAT_PATH = "/dat/";
	public static string LEVEL_TEAM_PATH = "levels/team/";
	public static string LEVEL_WAVE_PATH = "levels/waves/";
	public static string LEVEL_TEXTURE_PATH = "levels/texture/";

	public static string EFFECT_ASSET_X_PATH = "Assets/EffectResource/Resources/";
	public static string LEVEL_EFFECT_PATH = "Level/";

	public static string LEVEL_ROOT_NAME = "XRoot";
	public static string GROUP_ROOT_NAME = "Groups";
	public static string ELEMENT_ROOT_NAME = "Elements";
    public static string PATH_ROOT_NAME = "Pathes";
    public static string EVENT_ROOT_NAME = "Events";
    public static string BATTLELINE_ROOT_NAME = "BattleLine";
    public static string TRACK_ROOT_NAME = "Track";

	public static string LEVEL_GROUP_NAME = "Group_";
	public static string LEVEL_PATH_NAME = "_path";
	public static string LEVEL_EVENT_NAME = "Event ";
    public static string LEVEL_TRAIL_NAME = "trail";
    public static string LEVEL_PATHPOINT_NAME = "_pathPoint";

	// Excel path = Application.datapath + ExcelPath
	public const string ExcelPath = "/../../../tables/";
	
	// Chapter Excel file name
    public const string ExcelFile_Chapter = "Chapters";

    // battlelevel sheet name in Excel file
    public const string ExcelChapter_LevelSheet = "battles";
	
	// Chaoter sheet name
	public const string ExcelSheet_Chapters = "Chapters";
	
	// Monster Excel file name
	public const string ExcelFile_Monster = "Monsters";
	
	// Interact Excel file name
	public const string ExcelFile_Interact = "Interacts";

	// chapter path, changed by outside
	public static string Chapter_Path = string.Empty;
    public static string Chapter_Scene = string.Empty;
    public const string ExcelFile_UnitInfo = "UnitInfo";


	public enum ElementType
	{
		SimpleObject 	= 1,			// From resources/levels/object folder
        Defense       = 2,
        Unit            = 3,
	}
    


	public enum PathType
	{
		eXPath		 			= 0,
		eiTweenPath				= 1,
	}


	public static bool SUPPORT_FOG = true;

	public static bool LOAD_RES_BY_GROUP = false;
}
