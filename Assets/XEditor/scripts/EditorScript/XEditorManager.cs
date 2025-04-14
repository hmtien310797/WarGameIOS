using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using System.Text;


#if UNITY_EDITOR

using System.Xml;
using UnityEditor;

/**
 * Editor Manager
 * Manage level elements and data in X Editor
 * */

public class XEditorManager
{
	static XEditorManager sInstance;
	
	public static XEditorManager instance
	{
		get
		{
			if (sInstance == null)
			{
				sInstance = new XEditorManager();
			}
			return sInstance;
		}
	}
    private static Serclimax.ScTableMgr egScTableData = null;
    public static Serclimax.ScTableMgr eScTableData
    {
        get 
        {
            if(egScTableData == null || egScTableData.ProductionSet == null)
            {
            
                egScTableData = new Serclimax.ScTableMgr();
                egScTableData.Init(null);
            }
            return egScTableData;
        }
    }

	// Current Level Data
	private XLevelData mCurLevelData;
    private  XLevelDataXML mCurLevelDataXml;

    public XLevelDataXML CurLevelDataXml
    {
        get
        {
            return mCurLevelDataXml;
        }
        set
        {
            mCurLevelDataXml = value;
        }

    }
	// Generated Scene
	private GameObject mSceneObj;
	
	// Root Object for all generated objects
	private Transform mLevelRoot;

	// Root of Groups
	private Transform mGroupRoot;

	// Root of Elements
	private Transform mElementRoot;

	// Root of Pathes
    private Transform mPathRoot;

    // Root of Events
    private Transform mEventRoot;
    // Root of BattleLine
    private Transform mBattleLineRoot;

    private Transform mTrackRoot;


    private Clishow.CsLevelQuadSpace mLevelSpace;

	// Unique ids
	private int mMaxGroupUid;
	private int mMaxElementUid;
	private int mMaxPathUid;

	// For Runtime

	// Current Team Members
	//private List<TeamMember> mTeamMembers = new List<TeamMember>();

	//private TeamBuild mTeam;

	private List<XElementEditor> mAllElements;
	private List<XPathEditor> mAllPathes;

	private bool sIsSimulating = false;

	private bool mSkipBattle;

	private bool mIsStoryMode;

	// Load Level in Editor Mode
    public void LoadLevelXml(XLevelDataXML _levelData)
    {
        Destroy();

        if(_levelData != null)
        {
            mCurLevelDataXml = _levelData;

            mMaxGroupUid = 0;
            mMaxElementUid = 0;
            mMaxPathUid = 0;

            InitRoot();
            InitSceneXml();
            InitElements();
            InitPathes();
            InitLevelGroups();
            InitLevelSpaceXML();
            InitBattleLine();
            InitTrack();
        }
    }
	public void LoadLevel(XLevelData _levelData)
	{
		Destroy();

		if (_levelData != null)
		{
			curLevelData = _levelData;

			mMaxGroupUid = 0;
			mMaxElementUid = 0;
			mMaxPathUid = 0;
			
			InitRoot();
			InitScene();
			InitElements();
			InitPathes();
			InitLevelGroups();
            InitBattleLine();
            InitTrack();
		}
	}
    public GameObject GenerateLevel(string chapterName , string levelScene)
    {
        GameObject levelObj = null;
        if (mCurLevelDataXml != null)
        {
            mCurLevelDataXml.BuildNewData();
        }
        else
        {
            mCurLevelDataXml = new XLevelDataXML();
            mCurLevelDataXml.Init();
        }

        mCurLevelDataXml.chapterName = chapterName;
        mCurLevelDataXml.levelSceneName = levelScene;

        InitRoot();
        levelObj = ResourceLibrary.instance.GetLevelSceneInstanse(chapterName, levelScene);
        if (levelObj != null && GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME))
        {
            GameObject rootObj = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME);
            levelObj.transform.parent = rootObj.transform;
        }

        return levelObj;
    }

	// //Script changed leads to this function
	public void Validate()
	{
		if (!Application.isPlaying)
		{
			// All setting in Editor mode will miss, so we need contruct level structure by hierarchy, the structur is stored in XLevelData
			ConstructLevelDataByHierarchy();
		}
	}

	public void Destroy()
	{
        //mLevelRoot.DestroyChildren();  
		mCurLevelData = null;
		mSceneObj = null;
		mLevelRoot = null;
		mGroupRoot = null;
		mElementRoot = null; 
		mPathRoot = null;
        mEventRoot = null;
        mBattleLineRoot = null;
		mAllElements = null;
		mAllPathes = null;

        mTrackRoot = null;
	}

	public void PlayRuntime()
	{
		// All setting in Editor mode will miss, so we need contruct level structure by hierarchy, the structur is stored in XLevelData
		ConstructLevelDataByHierarchy();
	}
    public static void Save()
    {
        XLevelData levelData = instance.curLevelData;
        if (levelData)
        {
            string levelname = levelData.name;
            //PrefabUtility.CreatePrefab(XLevelDefine.ASSET_R_PATH + XLevelDefine.LEVEL_PATH + XLevelDefine.Chapter_Path + "/" + levelname + ".prefab", levelData.gameObject);
            PrefabUtility.CreatePrefab(XLevelDefine.ASSET_RESOURCE_PATH + XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + "/" + levelname + ".prefab", levelData.gameObject);
            AssetDatabase.SaveAssets();
            
            EditorUtility.DisplayDialog("Saving", "Save Successfully on file " + levelname + ".prefab", "OK");
        }
    }

    private void FillSlotNode()
    {
        if (mCurLevelDataXml == null)
        {
            return;
        }
        if (mCurLevelDataXml.UnitSlots != null)
            mCurLevelDataXml.UnitSlots.Clear();
        else
            mCurLevelDataXml.UnitSlots = new Dictionary<int, List<Serclimax.Unit.ScSlotNode>>();

        List<XElementEditor> allelements = XEditorManager.instance.GetAllElements();

        
        for (int i = 0, imax = allelements.Count; i < imax; i++)
        {
            Clishow.CsSlotTag[] tags = allelements[i].gameObject.GetComponentsInChildren<Clishow.CsSlotTag>();
            List<Serclimax.Unit.ScSlotNode> nodes = new List<Serclimax.Unit.ScSlotNode>();

            for (int j = 0, jmax = tags.Length; j < jmax; j++)
            {
                nodes.Add(tags[j].ToSlotNode());
            }
            if(nodes.Count != 0)
                mCurLevelDataXml.UnitSlots.Add(allelements[i].mElementUID, nodes);
        }
    }

    public void SaveLevelToXml()
    {
        if (mCurLevelDataXml == null)
        {
            return;
        }
        if (mLevelSpace != null)
        {
            Clishow.CsLevelQuadSpace.FillLevelSpace(mLevelSpace);
        }
        FillSlotNode();
        XmlDocument objDataXml = new XmlDocument();
        XmlDeclaration xmldecl = objDataXml.CreateXmlDeclaration("1.0", "utf-8", null);
        objDataXml.AppendChild(xmldecl);

        XmlElement root = objDataXml.CreateElement("root");
        objDataXml.AppendChild(root);

        XmlElement map = objDataXml.CreateElement("Map");
        mCurLevelDataXml.WriteToXml(objDataXml, map);

        //level data
        List<XElementEditor> eleList = GetAllElements();
        XmlElement xmlElementRoot = objDataXml.CreateElement("LevelElements");
        xmlElementRoot.SetAttribute("count", eleList.Count.ToString());
        foreach(XElementEditor xeditor in eleList)
        {
            xeditor.saveData();
            XmlElement xmlElement = objDataXml.CreateElement("Element");
            xeditor.WriteToXml(objDataXml, xmlElement);
            xmlElementRoot.AppendChild(xmlElement);
        }
        map.AppendChild(xmlElementRoot);


        //pathpoint data
        List<XPathEditor> pathPList = GetAllPathes();
        XmlElement xmlPathRoot = objDataXml.CreateElement("PathPoints");
        xmlPathRoot.SetAttribute("point_count", pathPList.Count.ToString());
        foreach (XPathEditor xeditor in pathPList)
        {
            xeditor.saveData();
            XmlElement xmlElement = objDataXml.CreateElement("PathPoint");
            xeditor.WriteToXml(objDataXml, xmlElement);
            xmlPathRoot.AppendChild(xmlElement);
        }
        //group
        PathGroupEditor[] pGroups = pathRoot.GetComponentsInChildren<PathGroupEditor>();
        xmlPathRoot.SetAttribute("group_count", pGroups.Length.ToString());
        for (int i = 0; i < pGroups.Length; ++i )
        {
            XmlElement GpElement = objDataXml.CreateElement("PathGroup");
            string[] gpflag = pGroups[i].name.Split('_');
            GpElement.SetAttribute("group", gpflag[1]);
            GpElement.SetAttribute("position", pGroups[i].transform.position.ToString());
            PathTeamEditor teamParent = pGroups[i].GetComponentInParent<PathTeamEditor>();
            string[] tflag = teamParent.name.Split('_');
            GpElement.SetAttribute("team", tflag[1]);
            xmlPathRoot.AppendChild(GpElement);
        }
        //team
        PathTeamEditor[] pTeams = pathRoot.GetComponentsInChildren<PathTeamEditor>();
        xmlPathRoot.SetAttribute("team_count", pTeams.Length.ToString());
        for (int i = 0; i < pTeams.Length; ++i)
        {
            XmlElement TpElement = objDataXml.CreateElement("PathTeam");
            string[] tpflag = pTeams[i].name.Split('_');
            TpElement.SetAttribute("team", tpflag[1]);
            TpElement.SetAttribute("tag", pTeams[i].pathTag);
            xmlPathRoot.AppendChild(TpElement);
        }
        map.AppendChild(xmlPathRoot);
        

        //event data
        XmlElement xmlEventsRoot = objDataXml.CreateElement("Events");
        xmlEventsRoot.SetAttribute("file", XLevelDefine.Chapter_Scene + eventRoot.GetComponent<Clishow.EEventMgrShell>().name);
        map.AppendChild(xmlEventsRoot);

        //QuadSpace data
        XmlElement xmlLevelSpaceRoot = objDataXml.CreateElement("LevelQuadSpace");
        XmlElement xmlSpaceRoot = objDataXml.CreateElement("RootSpace");
        xmlSpaceRoot.SetAttribute("RootRect", mLevelSpace.RootSpace.RootRect.X.ToString() + "," +
            mLevelSpace.RootSpace.RootRect.Y.ToString() + "," +
            mLevelSpace.RootSpace.RootRect.Width.ToString() + "," +
            mLevelSpace.RootSpace.RootRect.Height.ToString());
        xmlSpaceRoot.SetAttribute("Height", mLevelSpace.RootSpace.Height.ToString());
        xmlSpaceRoot.SetAttribute("EditorWidth", mLevelSpace.Width.ToString());
        xmlSpaceRoot.SetAttribute("EditorHeight", mLevelSpace.Height.ToString());
        xmlSpaceRoot.SetAttribute("UID", mLevelSpace.RootSpace.UID.ToString());
        xmlSpaceRoot.SetAttribute("Mask", mLevelSpace.Mask.value.ToString());
        xmlLevelSpaceRoot.AppendChild(xmlSpaceRoot);

        XmlElement xmlSubSpaceRoot = objDataXml.CreateElement("SubSpaces");
        for (int i = 0, imax = mLevelSpace.SubSpaces.Count; i < imax; i++)
        {
            xmlSpaceRoot = objDataXml.CreateElement("Space");
            xmlSpaceRoot.SetAttribute("RootRect", mLevelSpace.SubSpaces[i].RootRect.X.ToString() + "," +
                mLevelSpace.SubSpaces[i].RootRect.Y.ToString() + "," +
                mLevelSpace.SubSpaces[i].RootRect.Width.ToString() + "," +
                mLevelSpace.SubSpaces[i].RootRect.Height.ToString());
            xmlSpaceRoot.SetAttribute("Height", mLevelSpace.SubSpaces[i].Height.ToString());
            xmlSpaceRoot.SetAttribute("UID", mLevelSpace.SubSpaces[i].UID.ToString());
            xmlSubSpaceRoot.AppendChild(xmlSpaceRoot);
        }
        xmlLevelSpaceRoot.AppendChild(xmlSubSpaceRoot);
        map.AppendChild(xmlLevelSpaceRoot);
        //scene data
        if (mSceneObj != null)
        {
            //XSceneData sdata = mSceneObj.GetComponent<XSceneData>();
            SceneEntity sdata = mSceneObj.GetComponent<SceneEntity>();
            if (sdata != null)
            {
                sdata.WriteToXml(objDataXml, map);
            }
        }
        //BattleLine
        XmlElement xmlBattleLineRoot = objDataXml.CreateElement("BattleLine");
        for (int i = 0; i < BattleLineRoot.childCount; ++i)
        {
            XmlElement BLPElement = objDataXml.CreateElement("BattleLinePoint");
            BLPElement.SetAttribute("id", mBattleLineRoot.GetChild(i).name);
            BLPElement.SetAttribute("position", mBattleLineRoot.GetChild(i).position.ToString());
            xmlBattleLineRoot.AppendChild(BLPElement);
        }
        map.AppendChild(xmlBattleLineRoot);


        //slot
        XmlElement xmlSlotRoot = objDataXml.CreateElement("Slots");
        foreach (KeyValuePair<int,List<Serclimax.Unit.ScSlotNode>> s in mCurLevelDataXml.UnitSlots)
        {
            XmlElement xmlsubSlotRoot = objDataXml.CreateElement("Slot");
            xmlsubSlotRoot.SetAttribute("UID", s.Key.ToString());
            for (int i = 0, imax = s.Value.Count; i < imax; i++)
            {
                XmlElement xmlNoderoot = objDataXml.CreateElement("Node");
                xmlNoderoot.SetAttribute("Pos", s.Value[i].Pos.ToString());
                xmlNoderoot.SetAttribute("Forward", s.Value[i].Forward.ToString());
                xmlsubSlotRoot.AppendChild(xmlNoderoot);
            }

            xmlSlotRoot.AppendChild(xmlsubSlotRoot);
        }
        map.AppendChild(xmlSlotRoot);



        //track
        XmlElement xmlTrackRoot = objDataXml.CreateElement("Tracks");
        iTweenPath[] itpaths = TrackRoot.GetComponentsInChildren<iTweenPath>();
        for (int i = 0, imax = itpaths.Length; i < imax; i++)
        {
            XmlElement xmlsubTrackRoot = objDataXml.CreateElement("TrackPath");

            xmlsubTrackRoot.SetAttribute("Dis", iTween.PathLength(itpaths[i].nodes.ToArray()).ToString());
            xmlsubTrackRoot.SetAttribute("Bothway", itpaths[i].name.Contains("@").ToString());
            XmlElement xmlNodeRoot = objDataXml.CreateElement("Nodes");


            for (int j = 0, jmax = itpaths[i].nodes.Count; j < jmax; j++)
            {
                XmlElement xmlsubNoderoot = objDataXml.CreateElement("Node");
                xmlsubNoderoot.SetAttribute("Pos", itpaths[i].nodes[j].ToString());
                xmlNodeRoot.AppendChild(xmlsubNoderoot);
            }

            xmlsubTrackRoot.AppendChild(xmlNodeRoot);
            xmlTrackRoot.AppendChild(xmlsubTrackRoot);
        }
        map.AppendChild(xmlTrackRoot);



        root.AppendChild(map);
        
        //write file
        string fileAbsPath = Application.dataPath + XLevelDefine.RESOURCE_PATH + XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + "/dat/" + XLevelDefine.Chapter_Scene;
        StreamWriter streamWriter = new StreamWriter(fileAbsPath + ".xml", false, new UTF8Encoding(false));
        objDataXml.Save(streamWriter);
        streamWriter.Close();
        objDataXml = null;


    }
    public void SaveXmlFile(string filename)
    {
        

    }
    
    public void LoadLevelFromXml(string filename , bool buildlevel = true)
    {
        string fileAbsPath = Application.dataPath + XLevelDefine.RESOURCE_PATH + XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + "/dat/" + XLevelDefine.Chapter_Scene + ".xml";
        if (!File.Exists(fileAbsPath))
        {
            Debug.LogError("no levelxmlData : " + mCurLevelData + ".xml in the folder:" + fileAbsPath);
            return;
        }

        string fileName = XLevelDefine.ASSET_RESOURCE_PATH + XLevelDefine.ASSET_RLEVEL_PATH + XLevelDefine.Chapter_Path + "/dat/" + filename + ".xml";
        XmlDocument levelDataXml = new XmlDocument();
        TextAsset text = AssetDatabase.LoadAssetAtPath(fileName, typeof(TextAsset)) as TextAsset;
         //TextAsset text = Resources.LoadAssetAtPath(fileName, typeof(TextAsset)) as TextAsset;
        if (text != null)
        {
            levelDataXml.LoadXml(text.text); 
        }
        XLevelDataXML data = new XLevelDataXML();
        XSceneDataXml scData = new XSceneDataXml();
        foreach (XmlNode objNode in levelDataXml.DocumentElement.ChildNodes)
        {
            if (objNode.Name == "Map")
            {
                data.ReadFromXml((XmlElement)objNode);
                data.Init();
                break;
            }
        }
        if (buildlevel)
            LoadLevelXml(data);
        else
            mCurLevelDataXml = data;
    }
	void ConstructLevelDataByHierarchy()
	{
		if (levelRoot == null)
		{
			Debug.LogError("Cannot Find the Level Root, please load level in Editor Mode first.");
			return;
		}

        if(CurLevelDataXml == null)
        {
            LoadLevelFromXml(XLevelDefine.Chapter_Scene , false);
        }
        if(CurLevelDataXml == null)
        {
            return;
        }

        Transform obj = levelRoot.Find(CurLevelDataXml.levelSceneName);
		if (obj)
		{
			mSceneObj = obj.gameObject;
		}
		
		levelRoot.GetComponent<XLevelSettingEditor>().Reconstruct();


		mMaxElementUid = 0;
        for (int i = 0; i < CurLevelDataXml.elementsData.Length; i++)
		{
            if (CurLevelDataXml.elementsData[i].uniqueId > mMaxElementUid)
			{
                mMaxElementUid = CurLevelDataXml.elementsData[i].uniqueId;
			}
		}

		mMaxPathUid = 0;
        for (int i = 0; i < CurLevelDataXml.pathesData.Length; i++)
		{
            if (CurLevelDataXml.pathesData[i].uniqueId > mMaxPathUid)
			{
				mMaxPathUid = CurLevelDataXml.pathesData[i].uniqueId;
			}
		}

		if (Application.isPlaying)
        {
			// Handle linked relationship
			XLevelElement[] listElements = elementRoot.GetComponentsInChildren<XLevelElement>(true);
			for (int i=0; i<listElements.Length; i++)
			{
				listElements[i].HandleLinks();
			}

			if (Camera.main)
			{
				//setup the 3d top camera
				GameObject obj1 = new GameObject("3d top camera");
				Camera m3DTopCamera = obj1.AddComponent<Camera>();
				m3DTopCamera.CopyFrom(Camera.main);
				
				m3DTopCamera.transform.parent = Camera.main.transform;
				m3DTopCamera.transform.localPosition = Vector3.zero;
				m3DTopCamera.transform.localRotation = Quaternion.identity;
				
				m3DTopCamera.cullingMask = 1 << LayerMask.NameToLayer("3d top layer");
				m3DTopCamera.depth = 0.5f;
				m3DTopCamera.clearFlags = CameraClearFlags.Depth;	

				//setup character camera
				GameObject obj2 = new GameObject("character");
				Camera mCharacterCamera = obj2.AddComponent<Camera>();
				mCharacterCamera.CopyFrom(Camera.main);
				
				mCharacterCamera.transform.parent = Camera.main.transform;
				mCharacterCamera.transform.localPosition = Vector3.zero;
				mCharacterCamera.transform.localRotation = Quaternion.identity;
				
				//change camera cull mask
				mCharacterCamera.cullingMask = 1 << LayerMask.NameToLayer("highlight");
				mCharacterCamera.clearFlags = CameraClearFlags.Nothing;
				
				mCharacterCamera.depth = Camera.main.depth + 0.1f;
			}


		}
	}

	void OnBattleBegin()
	{
       
	}

	void OnBattleStop()
	{
		
	}

	public void Update(float _dt)
	{
        
	}

	public void SkipBattle()
	{
		mSkipBattle = true;
	}
	

	public void InitRoot()
	{
		if (GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME))
		{
			mLevelRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME).transform;
		}
		else
		{
			GameObject obj = new GameObject(XLevelDefine.LEVEL_ROOT_NAME);
			mLevelRoot = obj.transform;

			// Editor Component
			XLevelSettingEditor levelEditor = obj.AddComponent<XLevelSettingEditor>();
			levelEditor.Init(mCurLevelDataXml);

			obj = new GameObject(XLevelDefine.GROUP_ROOT_NAME);
			//obj.AddComponent<XGroupRootHelper>();
			mGroupRoot = obj.transform;
			mGroupRoot.parent = mLevelRoot;

			obj = new GameObject(XLevelDefine.ELEMENT_ROOT_NAME);
			obj.AddComponent<XElementRootHelper>();
			mElementRoot = obj.transform;
			mElementRoot.parent = mLevelRoot;

			obj = new GameObject(XLevelDefine.PATH_ROOT_NAME);
			obj.AddComponent<XPathRootHelper>();
			mPathRoot = obj.transform;
			mPathRoot.parent = mLevelRoot;

            obj = new GameObject(XLevelDefine.EVENT_ROOT_NAME);
            obj.AddComponent<Clishow.EEventMgrShell>();
            mEventRoot = obj.transform;
            mEventRoot.parent = mLevelRoot;

            obj = new GameObject(XLevelDefine.BATTLELINE_ROOT_NAME);
            mBattleLineRoot = obj.transform;
            mBattleLineRoot.parent = mLevelRoot;


            obj = new GameObject(XLevelDefine.TRACK_ROOT_NAME);
            mTrackRoot = obj.transform;
            mTrackRoot.parent = mLevelRoot;
		}
        mLevelSpace = mLevelRoot.GetComponent<Clishow.CsLevelQuadSpace>();
        if (mLevelSpace == null)
        {
            mLevelSpace = mLevelRoot.gameObject.AddComponent<Clishow.CsLevelQuadSpace>();
        }
	}

	public void InitSceneXml()
    {
        mSceneObj = XResourceManager.GetLevelScene(mCurLevelDataXml.levelSceneName);
        
        if (mSceneObj)
        {
            mSceneObj.transform.parent = levelRoot;
            SceneEntity se = mSceneObj.GetComponent<SceneEntity>();
            if (se != null)
            {
                se.LoadPrefabs();
                se.ResetRenderSettings();
            }
        }
        
        //load level prefab
       // GameObject levelObj = XResourceManager.GetLevelObject(mCurLevelDataXml.levelPrefabName);
        //if(levelObj)
        //{
            //levelObj.transform.parent = levelRoot;
            //XLevelData lvData = levelObj.GetComponent<XLevelData>();

            //mSceneObj = XResourceManager.GetLevelScene(lvData.levelSceneName);
            //if (mSceneObj)
            //{
                
            //    if (mSceneObj.GetComponent<SceneEntity>())
            //    {
            //        mSceneObj.GetComponent<SceneEntity>().LoadPrefabs();
            //       // mSceneObj.transform.parent = levelObj.transform;
            //    }
            //}
        //}
        
        /*
        mSceneObj = XResourceManager.GetLevelScene(mCurLevelDataXml.levelSceneName);
        if (mSceneObj)
        {
            mSceneObj.transform.parent = levelRoot;
            if (mSceneObj.GetComponent<SceneEntity>())
            {
                mSceneObj.GetComponent<SceneEntity>().LoadPrefabs();
            }
        }
         * */
    }
	public void InitScene()
	{
		mSceneObj = XResourceManager.GetLevelScene(curLevelData.levelSceneName);
		if (mSceneObj)
		{
			mSceneObj.transform.parent = levelRoot;
		}
	}
	public void InitBattleLine()
    {
        Dictionary<int, Vector3> battlelines = mCurLevelDataXml.LevelBattleLine;
        if(mBattleLineRoot != null)
        {
            foreach (KeyValuePair<int, Vector3> blp in battlelines)
            {
                GameObject blpObj = new GameObject();
                blpObj.name = blp.Key.ToString();
                blpObj.transform.parent = mBattleLineRoot;
                blpObj.transform.position = blp.Value;
            }
        }
        
    }


    public void InitTrack()
    {
        List<Serclimax.Unit.ScTrackPath> paths = mCurLevelDataXml.TrackPaths;
        if (mTrackRoot != null && paths != null)
        {
            for (int i = 0, imax = paths.Count; i < imax; i++)
            {
                GameObject blpObj = new GameObject();
                blpObj.name = "Track";
                blpObj.transform.parent = mTrackRoot;
                iTweenPath path = blpObj.AddComponent<iTweenPath>();
                path.nodes.Clear();
                path.nodes.AddRange(paths[i].Path.ToArray());
            }
        }
    }

	public void InitLevelGroups()
	{

        
	}
	
	public void InitLevelGroup(int _groupIndex)
	{

	}

    public void InitLevelSpaceXML()
    {
        if (mLevelSpace == null)
        {
            return;
        }
        mLevelSpace.Width = mCurLevelDataXml.LevelSpaceEditorWidth;
        mLevelSpace.Height = mCurLevelDataXml.LevelSpaceEditorHeight;
        mLevelSpace.RootSpace = new Serclimax.Level.ScLevelSpace();
        mLevelSpace.SubSpaces.Clear();
        if (mCurLevelDataXml.LevelSpaces.Count == 0)
            return;
        mLevelSpace.RootSpace = mCurLevelDataXml.LevelSpaces[0];
        mCurLevelDataXml.LevelSpaces.RemoveAt(0);
        mLevelSpace.SubSpaces.AddRange(mCurLevelDataXml.LevelSpaces.ToArray());
        mLevelSpace.Mask = (LayerMask)mCurLevelDataXml.LevelSpaceMask;

    }

	public void InitElements()
	{
		XElementData[] elementsData = mCurLevelDataXml.elementsData;
		mMaxElementUid = 0;
		List<XLevelElement> listElements = new List<XLevelElement>();
		for (int i=0; i<elementsData.Length; i++)
		{
			XElementData elementData = elementsData[i];

			if (elementData.uniqueId > mMaxElementUid)
			{
				mMaxElementUid = elementData.uniqueId;
			}
			
			XLevelElement element = elementData.Instantiate();
			if (element)
			{
				element.transform.parent = elementRoot;
						
				//Add Editor Component
				XElementEditor elementEditor = element.gameObject.AddComponent<XElementEditor>();
				elementEditor.Init(elementData);
			}
            
			listElements.Add(element);
		}

		// Handle linked relationship
		if (Application.isPlaying)
		{
			for (int i=0; i<listElements.Count; i++)
			{
				listElements[i].HandleLinks();
			}
		}
	}
    public void BuildPath()
    {
        
    }
	public void InitPathes()
	{
        ClearPath();

        //init team
        for(int team=0 ; team<mCurLevelDataXml.pathTeamData.Length ; ++team)
        {
            XPathTeamData teamdata = mCurLevelDataXml.pathTeamData[team];
            string PathTeamRoot = "Team_" + teamdata.teamId;
            if (!GameObject.Find(PathTeamRoot))
            {
                GameObject teamObj = new GameObject(PathTeamRoot);
                PathTeamEditor teamEdt = teamObj.AddComponent<PathTeamEditor>();
                teamObj.transform.parent = pathRoot;
                teamObj.transform.position = Vector3.zero;
                teamEdt.Init(teamdata);
            }
        }

        //init group
        for (int group = 0; group < mCurLevelDataXml.pathGroupData.Length; ++group)
        {
            XPathGroupData groupdata = mCurLevelDataXml.pathGroupData[group];
            string parentName = "Team_" + groupdata.teamId;
            Transform teamTrf;
            if (!GameObject.Find(parentName))
            {
                GameObject teamObj = new GameObject(parentName);
                teamObj.AddComponent<PathTeamEditor>();
                teamObj.transform.parent = pathRoot;
                teamObj.transform.position = Vector3.zero;
                teamTrf = teamObj.transform;
            }
            else
            {
                teamTrf = GameObject.Find(parentName).transform;
            }
            GameObject groupObj = new GameObject("Group_" + groupdata.groupId);
            groupObj.AddComponent<PathGroupEditor>();
            groupObj.transform.parent = teamTrf;
            groupObj.transform.position = groupdata.GroupPos;
        }


        XPathPointData[] pathesData = mCurLevelDataXml.pathesData;
		mMaxPathUid = 0;
		for (int i=0; i<pathesData.Length; i++)
		{
            XPathPointData pathData = pathesData[i];
			
			if (pathData.uniqueId > mMaxPathUid)
			{
				mMaxPathUid = pathData.uniqueId;
			}

            GameObject obj = new GameObject(pathData.uniqueId + XLevelDefine.LEVEL_PATHPOINT_NAME + "_Team" + pathData.team + "_group" + pathData.pathGroup);
			if (obj)
			{
                //team root
                string PathTeamRoot = "Team_" + pathData.team;
                string PathGroupRoot = "Group_" + pathData.pathGroup;
                Transform teamTrf;
                Transform groupTrf;
                if (!GameObject.Find(PathTeamRoot) || !GameObject.Find(PathGroupRoot))
                {
                    obj.transform.parent = pathRoot;
                    obj.transform.position = pathData.worldPosition;
                }
                else
                {
                    teamTrf = GameObject.Find(PathTeamRoot).transform;
                    groupTrf = teamTrf.Find(PathGroupRoot).transform;
                    obj.transform.parent = groupTrf;
                    obj.transform.position = pathData.worldPosition;
                   
                }
                XPathEditor pathEditor = obj.AddComponent<XPathEditor>();
                pathEditor.Init(pathData);
			}
		}
	}
    public void ClearPath()
    {
        pathRoot.DestroyChildren();
    }
	public int GetNewUniqueIdForGroup()
	{
		mMaxGroupUid = mMaxGroupUid + 1;
		return mMaxGroupUid;
	}
	
	public int GetNewUniqueIdForElement()
	{
		mMaxElementUid = mMaxElementUid + 1;
		return mMaxElementUid;
	}
	
	public int GetNewUniqueIdForPath()
	{
		mMaxPathUid = mMaxPathUid + 1;
		return mMaxPathUid;
	}
	
	public void EditorSwitchScene(string _lastname)
	{
		if (mSceneObj)
		{
			GameObject.DestroyImmediate(mSceneObj);
			mSceneObj = null;
		}
		else
		{
			Transform obj = levelRoot.Find(_lastname);
			if (obj)
			{
				GameObject.DestroyImmediate(obj.gameObject);
			}
		}
		InitScene();
	}

	public void StartSimulate()
	{
		sIsSimulating = true;
	}

	public void StopSimulate()
	{
		sIsSimulating = false;
	}

	public bool IsSimulating()
	{
		return sIsSimulating;
	}

	public XLevelData curLevelData
	{
		get
		{
			if (mCurLevelData)
			{
				return mCurLevelData;
			}
			else
			{
				mCurLevelData = GameObject.FindObjectOfType<XLevelData>();
				if (mCurLevelData)
					mCurLevelData.Init();
				return mCurLevelData;
			}
		}
		set
		{
			mCurLevelData = value;
			if (mCurLevelData)
				mCurLevelData.Init();
		}
	}

	public Transform levelRoot
	{
		get
		{
			if (mLevelRoot)
			{
				return mLevelRoot;
			}
			else
			{
				mLevelRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME).transform;
				return mLevelRoot;
			}
		}
	}

	public Transform groupRoot
	{
		get
		{
			if (mGroupRoot)
			{
				return mGroupRoot;
			}
			else
			{
				mGroupRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME + "/" + XLevelDefine.GROUP_ROOT_NAME).transform;
				return mGroupRoot;
			}
		}
	}

	public Transform elementRoot
	{
		get
		{
			if (mElementRoot)
			{
				return mElementRoot;
			}
			else
			{
				mElementRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME + "/" + XLevelDefine.ELEMENT_ROOT_NAME).transform;
				return mElementRoot;
			}
		}
	}

	public Transform pathRoot
	{
		get
		{
			if (mPathRoot)
			{
				return mPathRoot;
			}
			else
			{
				mPathRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME + "/" + XLevelDefine.PATH_ROOT_NAME).transform;
				return mPathRoot;
			}
		}
        set
        {
            mPathRoot = value;
        }
	}
    public Transform eventRoot
    {
        get
        {
            if (mEventRoot)
            {
                return mEventRoot;
            }
            else
            {
                mEventRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME + "/" + XLevelDefine.EVENT_ROOT_NAME).transform;
                return mEventRoot;
            }
        }
        set
        {
            mEventRoot = value;
        }
    }
    public Transform BattleLineRoot
    {
        get
        {
            if (mBattleLineRoot)
            {
                return mBattleLineRoot;
            }
            else
            {
                mBattleLineRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME + "/" + XLevelDefine.BATTLELINE_ROOT_NAME).transform;
                return mBattleLineRoot;
            }
        }
        set
        {
            mBattleLineRoot = value;
        }
    }


    public Transform TrackRoot
    {
        get
        {
            if (mTrackRoot != null)
            {
                return mTrackRoot;
            }
            else
            {
                mTrackRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME + "/" + XLevelDefine.TRACK_ROOT_NAME).transform;
                return mTrackRoot;
            }
        }
        set
        {
            mTrackRoot = value;
        }
    }


    public List<XElementEditor> GetAllElements()
	{
		if (mAllElements != null)
		{
            mAllElements.Clear();
            mAllElements = null;
		}
        XElementEditor[] elements = elementRoot.GetComponentsInChildren<XElementEditor>();
        mAllElements = new List<XElementEditor>(elements);
		return mAllElements;
	}

	public GameObject FindElementInHierarchy(int _uid)
	{
		List<XElementEditor> elements = GetAllElements();
		for (int i=0; i<elements.Count; i++)
		{
			if (elements[i].data.uniqueId == _uid)
			{
				return elements[i].gameObject;
			}
		}
		return null;
	}

	public List<XPathEditor> GetAllPathes()
	{
		if (mAllPathes != null)
		{
            mAllPathes.Clear();
            mAllPathes = null;
		}
        XPathEditor[] pathes = pathRoot.GetComponentsInChildren<XPathEditor>();
        mAllPathes = new List<XPathEditor>(pathes);
		return mAllPathes;
	}

}

#endif