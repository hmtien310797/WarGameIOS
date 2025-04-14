using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

using Serclimax;

/**
 * Level Manager
 * Manage level elements and data.
 * */

public class XLevelManager
{
	static XLevelManager sInstance;
	
	public static XLevelManager instance
	{
		get
		{
			if (sInstance == null)
			{
				sInstance = new XLevelManager();
			}
			return sInstance;
		}
	}

	// Current Level Data
	private XLevelData mCurLevelData;

	// Generated Scene
	private GameObject mSceneObj;

	// Root Object for all generated objects
	private Transform mLevelRoot;

	// Root of Groups
	private Transform mGroupRoot;
	
	// Root of Elements
	private Transform mElementRoot;


	// Generated Groups in Level
	//private List<XLevelGroup> mLevelGroups = new List<XLevelGroup>();

	// Generated Elements in Level
	private Dictionary<int, XLevelElement> mDicLevelElements = new Dictionary<int, XLevelElement>();

	// Generated Elements in Cache
	private Dictionary<int, XLevelElement> mDicCacheElements = new Dictionary<int, XLevelElement>();

	// Current Active Group
	//private XLevelGroup mCurActiveGroup;

	private int mCurActiveGroupIndex;

	// Current Team Members
	//private List<TeamMember> mTeamMembers = new List<TeamMember>();

    private List<object> mTeamMembers = new List<object>();

	// If use this manager, mInRuntime is true
	private bool mInRuntime = false;

	// If the level is completed
	private bool mIsComplete;

	// If the level is failed
	private bool mIsFail;

	// If the level is timeup (also failed)
	private bool mIsTimeUp;

	// the timer counted in battle end
	private float mBattleEndTimer = 0;
	
	const float BATTLE_END_TIME = 1;

	// Playing Story?
	private bool mIsStoryMode;

	// Specify Group Mode
	private bool mIsSpecifyMode;

	// notice monster callback
	public delegate void XMonsterNotice(int _id, bool _force);

	// notice monster callback
	public XMonsterNotice OnMonsterNotice;

	// notice add hero callback
	public delegate void XNewHeroNotice(int _id);
	
	// notice add hero callback
	public XNewHeroNotice OnHeroAddedNotice;

	// notice tutorial
	public delegate void XTutorialNotice(string _param);
	
	// notice tutorial callback
	public XTutorialNotice OnTutorialNotice;

	// notice capture screen callback
	public XTutorialNotice OnCaptureScreenNotice;
	
	// Check player blocked
	private bool mCheckBlockPlayer;

	public static bool CheckSceneLightMapIsReady(GameObject _scenePrefab)
	{
		bool bResult = true;

		if (_scenePrefab != null)
		{
			string bundle = "";

            SceneEntity sceneData = _scenePrefab.GetComponent<SceneEntity>();
            if (sceneData != null)
            {
            }
		}

		return bResult;
	}

	public bool CheckLevelIsReady(string _chapterId, string _objName)
	{
		string file;
		string bundle;
		XLevelDefine.Chapter_Path = _chapterId;
		file = XLevelDefine.LEVEL_PATH + XLevelDefine.Chapter_Path + "/" + _objName;
       
        return true;
	}

	public void LoadLevel(string _chapterId, string _sceneName, bool _storyMode, bool _seperateLoad = false)
	{
		Destroy();
		XLevelDefine.Chapter_Path = _chapterId;
		mIsStoryMode = _storyMode;
		GameObject obj = XResourceManager.GetLevelObject(_sceneName);
		if (obj)
		{
			if (_seperateLoad)
			{
				mInRuntime = true;
				mCurLevelData = obj.GetComponent<XLevelData>();
				mCurLevelData.Init();
			}
			else
			{
				LoadLevel(obj.GetComponent<XLevelData>());
			}
		}
	}

	public void SetCheckBlockPlayer(bool _check)
	{
		mCheckBlockPlayer = _check;
	}

	void LoadLevel(XLevelData _levelData)
	{
		if (_levelData != null)
		{
			mInRuntime = true;

			mCurLevelData = _levelData;
			mCurLevelData.Init();

			InitRoot();
			InitScene();
			InitLevelGroups();
			InitGlobalElements();

			mCurActiveGroupIndex = 0;
			//ActiveGroup(mCurActiveGroupIndex);

			if (!XLevelDefine.LOAD_RES_BY_GROUP)
			{
				LoadOtherGroup();
			}

			mIsComplete = false;
			mIsFail = false;
			mIsTimeUp = false;
			mIsSpecifyMode = false;
		}
	}

	public void LoadLevelInStep(int _step)
	{
		if (_step == 1)
		{
			InitRoot();
			InitScene();
		}
		else if (_step == 2)
		{
			InitLevelGroups();
		}
		else if (_step == 3)
		{
			InitGlobalElements();
		}
		else if (_step == 4)
		{
			mCurActiveGroupIndex = 0;
			ActiveGroup(mCurActiveGroupIndex);
		}
		else if (_step == 5)
		{
			if (!XLevelDefine.LOAD_RES_BY_GROUP)
			{
				LoadOtherGroup();
			}
			
			mIsComplete = false;
			mIsFail = false;
			mIsTimeUp = false;
			mIsSpecifyMode = false;
		}
	}

	public bool InRuntime
	{
		get
		{
			return mInRuntime;
		}
	}

	public bool IsComplete
	{
		get
		{
			return mIsComplete;
		}
	}

	public bool IsFail
	{
		get
		{
			return mIsFail && mBattleEndTimer >= BATTLE_END_TIME;
		}
	}

	public bool IsTimeUp
	{
		get
		{
			return mIsTimeUp;
		}
	}

	public void Destroy()
	{
		if (mCurLevelData)
		{
			GameObject.DestroyImmediate(mCurLevelData.gameObject);
			mCurLevelData = null;
		}

		if (mLevelRoot)
		{
			GameObject.DestroyImmediate(mLevelRoot.gameObject);
			mLevelRoot = null;
		}

		mSceneObj = null; // under root
		mGroupRoot = null; // under root
		mElementRoot = null; // under root
		//mCurActiveGroup = null; // under root
		//XLevelGroup.curActiveGroup = mCurActiveGroup;
		//mLevelGroups.Clear(); // under root
		mDicLevelElements.Clear(); // under root
		mDicCacheElements.Clear(); // under root
		mTeamMembers.Clear();


        //for (int i=InuResources.s_lUnitInstances.Count-1; i>=0; i--)
        //{
        //    if (InuResources.s_lUnitInstances[i])
        //    {
        //        GameObject.DestroyImmediate(InuResources.s_lUnitInstances[i].mGameObject);
        //    }
        //}

		//XBattle.instance.Destroy();

		OnMonsterNotice = null;
		OnHeroAddedNotice = null;
	}

	public void Update(float _dt)
	{
       
	}

	void InitRoot()
	{
		GameObject obj = new GameObject(XLevelDefine.LEVEL_ROOT_NAME);
		mLevelRoot = obj.transform;


		obj = new GameObject(XLevelDefine.GROUP_ROOT_NAME);
		mGroupRoot = obj.transform;
		mGroupRoot.parent = mLevelRoot;
		
		obj = new GameObject(XLevelDefine.ELEMENT_ROOT_NAME);
		mElementRoot = obj.transform;
		mElementRoot.parent = mLevelRoot;
	}

	void InitScene()
	{
		mSceneObj = XResourceManager.GetLevelScene(mCurLevelData.levelSceneName);
		if (mSceneObj)
		{
			mSceneObj.transform.parent = mLevelRoot;
		}
	}

	void InitLevelGroups()
	{
       
	}

	void InitLevelGroup(int _groupIndex)
	{
       
	}

	void InitGlobalElements()
	{
		XElementData[] elementsData = mCurLevelData.elementsData;
		List<XLevelElement> listElements = new List<XLevelElement>();
		for (int i=0; i<elementsData.Length; i++)
		{
			XElementData elementData = elementsData[i];
			if (elementData.isGlobal)
			{
				XLevelElement element = elementData.Instantiate();
				if (element)
				{
                    //temp set team
                    //if(element.data.elementType ==XLevelDefine.ElementType.Monster )

					element.transform.parent = mElementRoot;
					mDicLevelElements.Add(elementData.uniqueId, element);
					listElements.Add(element);
				}
			}
		}
		// Handle linked relationship
		for (int i=0; i<listElements.Count; i++)
		{
			listElements[i].HandleLinks();
		}
	}
    public void ActiveElementAI()
    {
        //foreach(XLevelElement xle in listE)
        //Transform elementRoot = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME + "/" + XLevelDefine.ELEMENT_ROOT_NAME).transform;

        //XLevelInuObject[] listInuObjs = elementRoot.GetComponentsInChildren<XLevelInuObject>(true);
        //for(int j=0 ; j<listInuObjs.Length ; j++)
        //{
        //    XLevelInuObject xlobj = listInuObjs[j];
        //    if(xlobj.type == XLevelDefine.ElementType.Monster)
        //    {
        //        InuUnit inumoster = xlobj.GetComponentInChildren<InuUnit>();
        //        if(inumoster != null)
        //        {
        //            if(xlobj.TableID == 20000)
        //            {
        //                inumoster.SetTeam(InuDefine.EInuTeam.eTeam1);
        //            }
        //            else
        //            {
        //                inumoster.SetTeam(InuDefine.EInuTeam.eTeam2);
        //            }
        //            inumoster.InitAI(true);
        //        }
        //    }
        //}
    }

	void ActiveGroup(int _index)
	{
       
	}

	void LoadOtherGroup()
	{
       
	}

	void PlayNextGroup()
	{

	}

	public Transform GetElementRoot()
	{
		// In Gameplay
		if (InRuntime)
		{
			return mElementRoot;
		}
		else
		{
			GameObject obj = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME + "/" + XLevelDefine.ELEMENT_ROOT_NAME);
			if (obj)
			{
				return obj.transform;
			}
		}
		return null;
	}
	
	public XLevelElement GetElementByUID(int _uid)
	{
		// In Gameplay
		if (InRuntime)
		{
			if (mDicLevelElements != null && mDicLevelElements.ContainsKey(_uid))
			{
				return mDicLevelElements[_uid];
			}
		}
		// In Editor Runtime
		else
		{
			GameObject obj = GameObject.Find(XLevelDefine.LEVEL_ROOT_NAME + "/" + XLevelDefine.ELEMENT_ROOT_NAME);
			if (obj)
			{
				XLevelElement[] elements = obj.GetComponentsInChildren<XLevelElement>(true);
				for (int i=0; i<elements.Length; i++)
				{
					if (elements[i].data != null && elements[i].data.uniqueId == _uid)
					{
						return elements[i];
					}
				}
			}
		}
		return null;
	}

    public XPathPointData GetPathByUID(int _uid)
	{
		// In Gameplay
		if (InRuntime)
		{
			return mCurLevelData.GetPathDataById(_uid);
		}
		// In Editor Runtime
		else
		{
			XLevelData levelData = GameObject.FindObjectOfType<XLevelData>();
			if (levelData)
			{
				return levelData.GetPathDataById(_uid);
			}
		}
		return null;
	}

	//public void SetTeamMembers(List<HeroData> _teamMembers)
    public void SetTeamMembers(List<object> _teamMembers)
	{
        
	}

	public List<object> GetTeamMembers()
	{
		return mTeamMembers;
	}

	
	public void SetEffectActive(bool _active, string _effectName)
	{
		
	}

	public void SetEffectAnimation(string _effectName, string _anim)
	{
		
	}

	public void SetSceneActive(bool _active, string _childName)
	{
		
	}

	public void SetSceneAnimation(string _childName, string _anim)
	{
		
	}

	public bool InBattle()
	{
        /*
		if (mCurActiveGroup && !mIsFail)
		{
			return mCurActiveGroup.inBattle;
		}
         * */
		return false;
	}

	#region Mystery and Activity

	// Mystery reset team
	//public void ResetTeamMembers(List<HeroData> _teamMembers, List<uint> _teamHps)

    public void ResetTeamMembers(List<object> _teamMembers, List<uint> _teamHps)
	{
       
	}
		
	
	
	// Mystery clean monsters
	public void CleanAllUnits()
	{
		if (mDicLevelElements != null)
		{
			foreach (XLevelElement element in mDicLevelElements.Values)
			{
				if (element != null)
				{
                    /*
					if (element.type == XLevelDefine.ElementType.Monster)
					{
						element.gameObject.SetActive(false);
					}
                     * */
				}
			}
		}
	}

	// Activity Replace monsters
	public void ReplaceAllMonstersInActivity(Dictionary<int, int> _replacedId)
	{
        /*
		foreach (KeyValuePair<int, int> kv in _replacedId)
		{
			XElementData elementData = mCurLevelData.GetElementDataById(kv.Key);

			if (elementData == null)
			{
				DebugUtils.LogError("no element id is "+kv.Key);
			}
			else if (elementData.elementType == XLevelDefine.ElementType.Monster)
			{
				elementData.ReplaceTableId = -1;

				// replace the monster
				if (kv.Value > 0)
				{
					elementData.ReplaceTableId = kv.Value;
				}

				// reset the content of monster
				XLevelElement element = null;
				
				// element has instantiated
				if (mDicLevelElements.ContainsKey(kv.Key))
				{
					element = mDicLevelElements[kv.Key];
					if (element) 
					{
						// recover active if reused in Trials Mode
						if (elementData.activeWhenInitial && !element.gameObject.activeSelf)
						{
							element.gameObject.SetActive(true);
						}
						element.Init(elementData);
					}
				}
				// element has cached
				else if (mDicCacheElements.ContainsKey(kv.Key))
				{
					element = mDicCacheElements[kv.Key];
					if (element) element.Init(elementData);
				}
			}
			else
			{
				DebugUtils.LogError("element id "+kv.Key+" type is wrong.");
			}
		}
         * */
	}

	// Trails Replace monsters
	public void ReplaceAllMonstersInTrial(int _groupId, Dictionary<int, int> _replacedId)
	{
        
	}

	#endregion
}
