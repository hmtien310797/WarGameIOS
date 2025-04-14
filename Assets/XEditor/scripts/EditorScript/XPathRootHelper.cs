using UnityEngine;
using System.Collections;
using System.Collections.Generic;

#if UNITY_EDITOR
[ExecuteInEditMode]
public class XPathRootHelper : MonoBehaviour
{
	// cannot move
	void Update()
	{
		if (Application.isPlaying)
			return;

		Transform t = transform;
		if (t.hasChanged)
		{
			t.position = Vector3.zero;
			t.rotation = Quaternion.identity;
			t.localScale = Vector3.one;
			t.hasChanged = false;
		}
	}
    public GameObject CreateTeamNode(string name , int id)
    {
        //add data
        XPathTeamData teamdata = new XPathTeamData();
        teamdata.teamId = id;

        int oldLength = XEditorManager.instance.CurLevelDataXml.pathTeamData.Length;
        int length = oldLength + 1;
        XPathTeamData[] newteam = new XPathTeamData[length];
        for(int i=0 ; i<XEditorManager.instance.CurLevelDataXml.pathTeamData.Length ; ++i)
        {
            newteam[i] = XEditorManager.instance.CurLevelDataXml.pathTeamData[i];
        }
        newteam[oldLength] = teamdata;

        //add GameObject
        GameObject teamObj = new GameObject(name);
        PathTeamEditor teditor = teamObj.AddComponent<PathTeamEditor>();
        teditor.teamId = id;
        return teamObj;
    }
    public GameObject CreateGroupNode(string name, int groupid , int teamid)
    {
        //add data
        XPathGroupData groupdata = new XPathGroupData();
        groupdata.groupId = groupid;
        groupdata.teamId = teamid;
        groupdata.GroupPos = Vector3.zero;

        int oldLength = XEditorManager.instance.CurLevelDataXml.pathGroupData.Length;
        int length = oldLength + 1;
        XPathGroupData[] newgroups = new XPathGroupData[length];
        for (int i = 0; i < XEditorManager.instance.CurLevelDataXml.pathGroupData.Length; ++i)
        {
            newgroups[i] = XEditorManager.instance.CurLevelDataXml.pathGroupData[i];
        }
        newgroups[oldLength] = groupdata;

        //add GameObject
        GameObject groupObj = new GameObject(name);
        PathGroupEditor geditor = groupObj.AddComponent<PathGroupEditor>();

        return groupObj;
    }
    public void BuildPathEditor()
    {
        //XPathPointData[] pathesData = XEditorManager.instance.CurLevelDataXml.pathesData;
        List<XPathEditor> allPathEditor = XEditorManager.instance.GetAllPathes();
        for (int i = 0; i < allPathEditor.Count; i++)
        {
            XPathEditor pathEditor = allPathEditor[i];
            //team root
            string PathTeamRoot = "Team_" + pathEditor.data.team;
            string PathGroupRoot = "Group_" + pathEditor.data.pathGroup;
            Transform teamTrf;
            if (!GameObject.Find(PathTeamRoot))
            {
                GameObject teamObj = CreateTeamNode(PathTeamRoot, pathEditor.data.team);
                teamObj.transform.parent = XEditorManager.instance.pathRoot;
                teamObj.transform.position = Vector3.zero;
                teamTrf = teamObj.transform;
            }
            else
            {
                teamTrf = GameObject.Find(PathTeamRoot).transform;
            }

            //group root
            Transform groupTrf;
            if (!teamTrf.Find(PathGroupRoot))
            {
                GameObject groupObj = CreateGroupNode(PathGroupRoot, pathEditor.data.pathGroup, pathEditor.data.team);
                groupObj.transform.parent = teamTrf;
                groupObj.transform.position = Vector3.zero;
                groupTrf = groupObj.transform;
            }
            else
            {
                groupTrf = teamTrf.Find(PathGroupRoot).transform;
            }
            pathEditor.transform.parent = groupTrf;
            pathEditor.apply();
        }
    }
	public void InsertNewPathAt(int _newPathIndex)
	{
        XLevelDataXML levelData = XEditorManager.instance.CurLevelDataXml;
		
		// create new Path data
        XPathPointData newPath = new XPathPointData();
		newPath.uniqueId = XEditorManager.instance.GetNewUniqueIdForPath();
				
		// construct new Path array
        XPathPointData[] newPathes = new XPathPointData[levelData.pathesData.Length + 1];
		for (int i=0, j=0; i<newPathes.Length; i++)
		{
			if (i != _newPathIndex)
			{
				newPathes[i] = levelData.pathesData[j++];
			}
		}
		newPathes[_newPathIndex] = newPath;
		levelData.pathesData = newPathes;
        levelData.ResetPathList();
		// create Object
		GameObject obj = new GameObject(newPath.uniqueId + XLevelDefine.LEVEL_PATH_NAME + "_" + newPath.pathGroup);
		if (obj)
		{
			obj.transform.parent = XEditorManager.instance.pathRoot;
			
			//Add Editor Component
			XPathEditor pathEditor = obj.AddComponent<XPathEditor>();
			pathEditor.Init(newPath);
			
			// Add to Editor Manager
			List<XPathEditor> allPathes = XEditorManager.instance.GetAllPathes();
			if (allPathes != null)
			{
				allPathes.Add(pathEditor);
			}
		}
	}
	public void ClonePathE()
    {

    }
	public void ClonePath(int _pathIndex)
	{
		int _newPathIndex = _pathIndex + 1;
        XLevelDataXML levelData = XEditorManager.instance.CurLevelDataXml;
		
		// clone new Path data from exist
        XPathPointData newPath = levelData.pathesData[_pathIndex].Clone();
		newPath.uniqueId = XEditorManager.instance.GetNewUniqueIdForPath();
		
		
        XPathPointData[] newPathes = new XPathPointData[levelData.pathesData.Length + 1];
		for (int i=0, j=0; i<newPathes.Length; i++)
		{
			if (i != _newPathIndex)
			{
				newPathes[i] = levelData.pathesData[j++];
			}
		}
		newPathes[_newPathIndex] = newPath;
		levelData.pathesData = newPathes;
        levelData.ResetPathList();

        

        // create Object
        GameObject obj = new GameObject(newPath.uniqueId + XLevelDefine.LEVEL_PATH_NAME + "_" + newPath.pathGroup);
		if (obj)
		{
			obj.transform.parent = XEditorManager.instance.pathRoot;
			
			//Add Editor Component
			XPathEditor pathEditor = obj.AddComponent<XPathEditor>();
			pathEditor.Init(newPath);


            List<XPathEditor> allPathes = XEditorManager.instance.GetAllPathes();
            if (allPathes != null)
            {
                foreach (XPathEditor pe in allPathes)
                {
                    if (levelData.pathesData[_pathIndex].uniqueId == pe.data.uniqueId)
                    {
                        pathEditor.transform.parent = pe.transform.parent;
                        pathEditor.transform.position = pe.transform.position;
                        pathEditor.apply();
                        break;
                    }
                }
                allPathes.Add(pathEditor);
            }
		}
        
	}
	
	public void RemovePath(int _pathIndex)
	{
        XLevelDataXML levelData = XEditorManager.instance.CurLevelDataXml;
		int pathUID = levelData.pathesData[_pathIndex].uniqueId;
		
		// construct new path array
        XPathPointData[] newPathes = new XPathPointData[levelData.pathesData.Length - 1];
		for (int i=0, j=0; i<levelData.pathesData.Length; i++)
		{
			if (i != _pathIndex)
			{
				newPathes[j++] = levelData.pathesData[i];
			}
		}
		levelData.pathesData = newPathes;
        levelData.ResetPathList();
        
		// Find the PathEditor Object
		XPathEditor[] pathes = GetComponentsInChildren<XPathEditor>(true);
		for (int i=0; i<pathes.Length; i++)
		{
			if (pathes[i].data.uniqueId == pathUID)
			{
				DestroyImmediate(pathes[i].gameObject);
				break;
			}
		}
		
		// Remove to Editor Manager
		List<XPathEditor> allPathes = XEditorManager.instance.GetAllPathes();
		if (allPathes != null)
		{
			for (int i=allPathes.Count-1; i>=0; i--)
			{
				if (allPathes[i] == null)
				{
					allPathes.RemoveAt(i);
				}
			}
		}
        
	}
}

#endif
