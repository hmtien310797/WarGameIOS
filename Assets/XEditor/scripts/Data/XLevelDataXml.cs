using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Serclimax;

using System.Xml;
using Serclimax.Level;
public class XLevelDataXML
{
    public string levelPrefabName;

    public int levelID;
    // resource name of level scene
    public string levelSceneName;

    public string chapterName;
    // all elements in this level
    public XElementData[] elementsData;

    // all path data
    public XPathPointData[] pathesData;
    public XPathGroupData[] pathGroupData;
    public XPathTeamData[] pathTeamData;
    public struct CollideObject
    {
        public GameObject _object;
        public Vector3 center;
        public Vector3 size;
        public CollideObject(string name)
        {
            _object = new GameObject(name);
            center = Vector3.zero;
            size = Vector3.zero;
        }
    }
    public CollideObject[] collideObjects;
  

    public string AstarFile;
    public string EventsFile;

    public List<Serclimax.Level.ScLevelSpace> LevelSpaces;
    public float LevelSpaceEditorWidth =-1;
    public float LevelSpaceEditorHeight = -1;
    public Dictionary<int, List<Serclimax.Unit.ScSlotNode>> UnitSlots;
    public int LevelSpaceMask;
    public Dictionary<int , Vector3> LevelBattleLine;

    public List<Serclimax.Unit.ScTrackPath> TrackPaths;


    private Dictionary<int, XElementData> mElementData;
    private Dictionary<int, XPathPointData> mPathData;


    public float minCameraX;
    public float maxCameraX;
    public float minCameraZ;
    public float maxCameraZ;
    public float minCameraY;
    public float maxCameraY;


    // Use this for initialization

    void OnDisable()
    {
        // Reset render setting
        /*
        RenderSettings.ambientLight = pambientLight;

        RenderSettings.fog = penableFog;
        RenderSettings.fogColor = pfogColor;
        RenderSettings.fogMode = pfogMode;
        RenderSettings.fogDensity = pfogDesity;
        RenderSettings.fogStartDistance = pfogStart;
        RenderSettings.fogEndDistance = pfogEnd;
        */
    }


    public void BuildNewData()
    {
        elementsData = null;
        pathesData = null;
        pathGroupData = null;
        pathTeamData = null;
        collideObjects = null;
        mElementData = null;
        mPathData = null;
        Init();
    }
    public void Init()
    {
        
        if(elementsData == null)
        {
            elementsData = new XElementData[0];
        }
        if (pathesData == null)
        {
            pathesData = new XPathPointData[0];
        }
        if(pathGroupData == null)
        {
            pathGroupData = new XPathGroupData[0];
        }
        if(pathTeamData == null)
        {
            pathTeamData = new XPathTeamData[0];
        }

        int length = elementsData.Length;
        mElementData = new Dictionary<int, XElementData>(length);
        for (int i = 0; i < length; i++)
        {
            mElementData.Add(elementsData[i].uniqueId, elementsData[i]);
        }

        length = pathesData.Length;
        mPathData = new Dictionary<int, XPathPointData>(length);
        for (int i = 0; i < length; i++)
        {
            mPathData.Add(pathesData[i].uniqueId, pathesData[i]);
        }
        /*
        penableFog = RenderSettings.fog;
        pfogColor = RenderSettings.fogColor;
        pfogMode = RenderSettings.fogMode;
        pfogDesity = RenderSettings.fogDensity;
        pfogStart = RenderSettings.fogStartDistance;
        pfogEnd = RenderSettings.fogEndDistance;
        pambientLight = RenderSettings.ambientLight;
        */
        ResetRender();
    }
    public void ResetElementList()
    {
        mElementData.Clear();

        int length = elementsData.Length;
        mElementData = new Dictionary<int, XElementData>(length);
        for (int i = 0; i < length; i++)
        {
            mElementData.Add(elementsData[i].uniqueId, elementsData[i]);
        }
    }
    public void ResetPathList()
    {
        mPathData.Clear();

        int length = pathesData.Length;
        mPathData = new Dictionary<int, XPathPointData>(length);
        for (int i = 0; i < length; i++)
        {
            mPathData.Add(pathesData[i].uniqueId, pathesData[i]);
        }
    }
    public void ResetRender()
    {
        /*
        RenderSettings.ambientLight = ambientLight;

        if (XLevelDefine.SUPPORT_FOG)
        {
            RenderSettings.fog = enableFog;
            RenderSettings.fogColor = fogColor;
            RenderSettings.fogMode = fogMode;
            RenderSettings.fogDensity = fogDesity;
            RenderSettings.fogStartDistance = fogStart;
            RenderSettings.fogEndDistance = fogEnd;
        }
        else
        {
            RenderSettings.fog = false;
        }
         * */
    }

    public XElementData GetElementDataById(int _uniqueId)
    {
        if (mElementData != null && mElementData.ContainsKey(_uniqueId))
        {
            return mElementData[_uniqueId];
        }
        return null;
    }

    public XPathPointData GetPathDataById(int _uniqueId)
    {
        if (mPathData != null && mPathData.ContainsKey(_uniqueId))
        {
            return mPathData[_uniqueId];
        }
        return null;
    }

    public Serclimax.Level.ScLevelData CreateScLevelData()
    {
        Serclimax.Level.ScLevelData sclevel = new ScLevelData();
        //level id
        sclevel.mLeveId = levelID;
        //elements
        for (int i = 0; i < elementsData.Length; ++i )
        {
            XElementData xEData = elementsData[i];
            sclevel.mLevelElementsData.Add(xEData.uniqueId, xEData.ToScElementData());
        }

        //pathpoint
        //Dictionary<int, Dictionary<int, List<ScPathData>>> _teamPath = new Dictionary<int, Dictionary<int, List<ScPathData>>>();
        Dictionary<int, ScPathTeamData> LevelPathDatas = new Dictionary<int,ScPathTeamData>();
        for (int k = 0; k < pathTeamData.Length; ++k )
        {
            XPathTeamData tda = pathTeamData[k];
            if (!LevelPathDatas.ContainsKey(tda.teamId))
            {
                ScPathTeamData stdata = new ScPathTeamData();
                stdata.teamId = tda.teamId;
                stdata.unitTag = tda.unitTag;
                LevelPathDatas.Add(tda.teamId, stdata);
            }
        }

        for (int j = 0; j < pathGroupData.Length; ++j)
        {
            XPathGroupData gdata = pathGroupData[j];
            if (!LevelPathDatas.ContainsKey(gdata.teamId))
            {
                Debug.LogError("wrong PathGroupData ! have no team id");
                continue;
            }
            ScPathGroupData sgdata = new ScPathGroupData();
            sgdata.groupId = gdata.groupId;
            sgdata.teamId = gdata.teamId;
            sgdata.groupPosition = gdata.GroupPos;
            LevelPathDatas[gdata.teamId].groups.Add(gdata.groupId,sgdata);
            LevelPathDatas[gdata.teamId].pathgroups.Add(sgdata);
            LevelPathDatas[gdata.teamId].groupids.Add(gdata.groupId);
        }

        for (int i = 0; i < pathesData.Length; ++i)
        {
            XPathPointData xPData = pathesData[i];
            if (!LevelPathDatas.ContainsKey(xPData.team))
            {
                Debug.LogError("wrong path point! have no team");
                continue;
            }
            if (!LevelPathDatas[xPData.team].groupids.Contains(xPData.pathGroup))
            {
                Debug.LogError("wrong path point! have no group");
                continue;
            }

            int index = LevelPathDatas[xPData.team].groupids[xPData.pathGroup];
            LevelPathDatas[xPData.team].pathgroups[index].points.Add(xPData.ToScPathData());
        }
        sclevel.mLevelPathDatas = LevelPathDatas;

        sclevel.RootSpace = LevelSpaces[0];
        for (int i = 1, imax = LevelSpaces.Count; i < imax; i++)
        {
            AddSpace(sclevel, LevelSpaces[i].UID, LevelSpaces[i]);
        }


        sclevel.mLevelBattleLines = LevelBattleLine;
        if (UnitSlots != null)
        {
            sclevel.SlotNode = new Dictionary<int, List<Serclimax.Unit.ScSlotNode>>();
            List<Serclimax.Unit.ScSlotNode> nodes = null;
            foreach (KeyValuePair<int, List<Serclimax.Unit.ScSlotNode>> node in UnitSlots)
            {
                nodes = new List<Serclimax.Unit.ScSlotNode>();
                nodes.AddRange(node.Value.ToArray());
                sclevel.SlotNode.Add(node.Key, nodes);
            }
        }


        if (TrackPaths != null)
        {
            sclevel.TarckPaths = new List<Serclimax.Unit.ScTrackPath>();
            sclevel.TarckPaths.AddRange(TrackPaths.ToArray());
        }

        
        //camera
        sclevel.MinCameraX = minCameraX;
        sclevel.MaxCameraX = maxCameraX;
        sclevel.MinCameraZ = minCameraZ;
        sclevel.MaxCameraZ = maxCameraZ;
        sclevel.MinCameraY = minCameraY;
        sclevel.MaxCameraY = maxCameraY;

        return sclevel;
    }


    private void AddSpace(Serclimax.Level.ScLevelData level,int uid, Serclimax.Level.ScLevelSpace space)
    {
        List<Serclimax.Level.ScLevelSpace> spaces = null;
        if (level.SpaceMap.TryGetValue(uid, out spaces))
        {
            spaces.Add(space);
        }
        else
        {
            if (spaces == null)
                spaces = new List<ScLevelSpace>();
            spaces.Add(space);
            level.SpaceMap.Add(uid, spaces);
        }
    }

    public void ReadFromXml(XmlElement _xmlElement)
    {
        levelPrefabName = _xmlElement.GetAttribute("levelName");
        levelSceneName = _xmlElement.GetAttribute("sceneName");

        foreach (XmlNode node in _xmlElement.ChildNodes)
        {
            if (node.Name == "LevelElements")
            {
                XmlElement _xLevelElements = (XmlElement)node;
                int count = int.Parse(_xLevelElements.GetAttribute("count"));
                int i = 0;
                elementsData = new XElementData[count];
                foreach (XmlNode eleNode in _xLevelElements.ChildNodes)
                {
                    XmlElement _XmlEle = (XmlElement)eleNode;
                    XElementData eleData = new XElementData();
                    eleData.ReadFromXml(_XmlEle);
                    elementsData[i] = eleData;
                    i++;
                }
            }
            else if (node.Name == "PathPoints")
            {
                XmlElement _xLevelPaths = (XmlElement)node;
                int point = 0, group = 0, team = 0;
                int count = int.Parse(_xLevelPaths.GetAttribute("point_count"));
                pathesData = new XPathPointData[count];
                count = int.Parse(_xLevelPaths.GetAttribute("group_count"));
                pathGroupData = new XPathGroupData[count];
                count = int.Parse(_xLevelPaths.GetAttribute("team_count"));
                pathTeamData = new XPathTeamData[count];

                foreach (XmlNode pathNode in _xLevelPaths.ChildNodes)
                {
                    if (pathNode.Name == "PathPoint")
                    {
                        XmlElement _XmlPoint = (XmlElement)pathNode;
                        XPathPointData pPointData = new XPathPointData();
                        pPointData.ReadFromXml(_XmlPoint);
                        pathesData[point] = pPointData;
                        point++;
                    }
                    else if (pathNode.Name == "PathGroup")
                    {
                        XmlElement _XmlGroup = (XmlElement)pathNode;
                        XPathGroupData pGroupData = new XPathGroupData();
                        pGroupData.groupId = int.Parse(_XmlGroup.GetAttribute("group"));
                        pGroupData.teamId = int.Parse(_XmlGroup.GetAttribute("team"));
                        pGroupData.GroupPos = RawTable.ParseVector3(_XmlGroup.GetAttribute("position"));
                        pathGroupData[group] = pGroupData;
                        group++;
                    }
                    else if (pathNode.Name == "PathTeam")
                    {
                        XmlElement _XmlTeam = (XmlElement)pathNode;
                        XPathTeamData pTeamData = new XPathTeamData();
                        pTeamData.teamId = int.Parse(_XmlTeam.GetAttribute("team"));
                        pTeamData.unitTag = _XmlTeam.GetAttribute("tag");
                        pathTeamData[team] = pTeamData;
                        team++;
                    }
                }

            }
            else if (node.Name == "Events")
            {
                XmlElement _xEventsObjs = (XmlElement)node;
                EventsFile = _xEventsObjs.GetAttribute("file");
            }
            else if (node.Name == "Scene")
            {
                XmlElement _xCollideObjs = (XmlElement)node;
                int count = int.Parse(_xCollideObjs.GetAttribute("count"));
                string name = _xCollideObjs.GetAttribute("name");
                AstarFile = _xCollideObjs.GetAttribute("AStar");
                minCameraX = float.Parse(_xCollideObjs.GetAttribute("minCameraX"));
                maxCameraX = float.Parse(_xCollideObjs.GetAttribute("maxCameraX"));
                minCameraZ = float.Parse(_xCollideObjs.GetAttribute("minCameraZ"));
                maxCameraZ = float.Parse(_xCollideObjs.GetAttribute("maxCameraZ"));
                minCameraY = float.Parse(_xCollideObjs.GetAttribute("minCameraY"));
                maxCameraY = float.Parse(_xCollideObjs.GetAttribute("maxCameraY"));
                int i = 0;
                collideObjects = new CollideObject[count];
                foreach (XmlNode collideNode in _xCollideObjs.ChildNodes)
                {
                    XmlElement _XmlCObj = (XmlElement)collideNode;
                    CollideObject cObj = new CollideObject(name);
                    cObj._object.transform.position = RawTable.ParseVector3(_XmlCObj.GetAttribute("position"));
                    Vector3 rotateEular = RawTable.ParseVector3(_XmlCObj.GetAttribute("rotate"));
                    cObj._object.transform.rotation = Quaternion.Euler(rotateEular);
                    //RawTable.ParseQuaternion(_XmlCObj.GetAttribute("rotate"));
                    cObj._object.transform.localScale = RawTable.ParseVector3(_XmlCObj.GetAttribute("scale"));
                    cObj.center = RawTable.ParseVector3(_XmlCObj.GetAttribute("center"));
                    cObj.size = RawTable.ParseVector3(_XmlCObj.GetAttribute("size"));
                    collideObjects[i] = cObj;
                    i++;
                }
            }
            else if (node.Name == "LevelQuadSpace")
            {
                XmlElement _xLevelSpaceObjs = (XmlElement)node;
                LevelSpaces = new List<Serclimax.Level.ScLevelSpace>();
                Serclimax.Level.ScLevelSpace space;
                Serclimax.Level.ScLevelSpace root = new Serclimax.Level.ScLevelSpace();
                foreach (XmlNode levelspaceNode in _xLevelSpaceObjs.ChildNodes)
                {
                    if (levelspaceNode.Name == "RootSpace")
                    {
                        string[] rectstrs = ((XmlElement)levelspaceNode).GetAttribute("RootRect").Split(',');
                        root.RootRect = new Serclimax.QuadSpace.ScQuadRect(float.Parse(rectstrs[0]), float.Parse(rectstrs[1]), float.Parse(rectstrs[2]), float.Parse(rectstrs[3]));
                        root.Height = float.Parse(((XmlElement)levelspaceNode).GetAttribute("Height"));
                        root.UID = int.Parse(((XmlElement)levelspaceNode).GetAttribute("UID"));
                        LevelSpaceMask = int.Parse(((XmlElement)levelspaceNode).GetAttribute("Mask"));

                        string ew = ((XmlElement)levelspaceNode).GetAttribute("EditorWidth");
                        if (!string.IsNullOrEmpty(ew))
                        {
                            LevelSpaceEditorWidth = float.Parse(ew);
                        }
                        ew = ((XmlElement)levelspaceNode).GetAttribute("EditorHeight");
                        if (!string.IsNullOrEmpty(ew))
                        {
                            LevelSpaceEditorHeight = float.Parse(ew);
                        }
                    }
                    else
                    if (levelspaceNode.Name == "SubSpaces")
                    {
                        foreach (XmlNode spaceNode in ((XmlElement)levelspaceNode).ChildNodes)
                        {
                            space = new Serclimax.Level.ScLevelSpace();
                            string[] rectstrs = ((XmlElement)spaceNode).GetAttribute("RootRect").Split(',');
                            space.RootRect = new Serclimax.QuadSpace.ScQuadRect(float.Parse(rectstrs[0]), float.Parse(rectstrs[1]), float.Parse(rectstrs[2]), float.Parse(rectstrs[3]));
                            space.Height = float.Parse(((XmlElement)spaceNode).GetAttribute("Height"));
                            space.UID = int.Parse(((XmlElement)spaceNode).GetAttribute("UID"));
                            LevelSpaces.Add(space);
                        }
                    }
                }
                if (LevelSpaces.Count != 0)
                {
                    LevelSpaces.Insert(0, root);
                }
            }

            else if (node.Name == "BattleLine")
            {
                LevelBattleLine = new Dictionary<int, Vector3>();
                XmlElement _xLevelBattleLineObjs = (XmlElement)node;
                foreach (XmlNode levelBlpNode in _xLevelBattleLineObjs.ChildNodes)
                {
                    int id = int.Parse(((XmlElement)levelBlpNode).GetAttribute("id"));
                    if (!LevelBattleLine.ContainsKey(id))
                    {
                        Vector3 pos = RawTable.ParseVector3(((XmlElement)levelBlpNode).GetAttribute("position"));
                        LevelBattleLine[id] = pos;
                    }
                }
            }
            else if (node.Name == "Slots")
            {
                XmlElement _xLevelSlotObjs = (XmlElement)node;
                UnitSlots = new Dictionary<int, List<Serclimax.Unit.ScSlotNode>>();
                foreach (XmlNode levelSlotNode in _xLevelSlotObjs.ChildNodes)
                {
                    if (levelSlotNode.Name == "Slot")
                    {
                        int uid = int.Parse(((XmlElement)levelSlotNode).GetAttribute("UID"));
                        List<Serclimax.Unit.ScSlotNode> nodes = new List<Serclimax.Unit.ScSlotNode>();
                        Serclimax.Unit.ScSlotNode inode = null;
                        foreach (XmlNode SlotNode in ((XmlElement)levelSlotNode).ChildNodes)
                        {
                            inode = new Serclimax.Unit.ScSlotNode();
                            inode.Pos = RawTable.ParseVector3(((XmlElement)SlotNode).GetAttribute("Pos"));
                            inode.Forward = RawTable.ParseVector3(((XmlElement)SlotNode).GetAttribute("Forward"));
                            nodes.Add(inode);
                        }
                        UnitSlots.Add(uid, nodes);
                    }
                }
            }
            else if (node.Name == "Tracks")
            {
                XmlElement _xLevelTrackObjs = (XmlElement)node;
                TrackPaths = new List<Serclimax.Unit.ScTrackPath>();
                foreach (XmlNode levelTrackPathNode in _xLevelTrackObjs.ChildNodes)
                {
                    bool bothway = false;
                    Serclimax.Unit.ScTrackPath path = new Serclimax.Unit.ScTrackPath(); 
                    path.TotalDis = float.Parse(((XmlElement)levelTrackPathNode).GetAttribute("Dis"));
                    bothway = bool.Parse(((XmlElement)levelTrackPathNode).GetAttribute("Bothway"));
                    path.Path = new List<Vector3>();
                    foreach (XmlNode levelNodesNode in levelTrackPathNode.ChildNodes)
                    {
                        foreach (XmlNode levelNodeNode in levelNodesNode.ChildNodes)
                            path.Path.Add( RawTable.ParseVector3(((XmlElement)levelNodeNode).GetAttribute("Pos")));
                    }

                    TrackPaths.Add(path);
                    if (bothway)
                    {
                        Serclimax.Unit.ScTrackPath path1 = new Serclimax.Unit.ScTrackPath();
                        path1.TotalDis = path.TotalDis;
                        path1.Path = new List<Vector3>();
                        for (int i = path.Path.Count - 1, imin = 0; i >= imin; i--)
                        {
                            path1.Path.Add(path.Path[i]);
                        }
                        TrackPaths.Add(path1);
                    }
                }

            }
            else
            {

            }
        }
    }

    public void WriteToXml(XmlDocument _doc, XmlElement _xmlElement)
    {
        _xmlElement.SetAttribute("levelName", levelPrefabName);
        _xmlElement.SetAttribute("sceneName", levelSceneName);
        /*
        _xmlElement.SetAttribute("enableFog", enableFog.ToString());
        _xmlElement.SetAttribute("fogColor", fogColor.r + "," + fogColor.g + "," + fogColor.b + "," + fogColor.a);
        _xmlElement.SetAttribute("fogMode", ((int)fogMode).ToString());
        _xmlElement.SetAttribute("fogDesity", fogDesity.ToString());
        _xmlElement.SetAttribute("fogStart", fogStart.ToString());
        _xmlElement.SetAttribute("fogEnd", fogEnd.ToString());
        _xmlElement.SetAttribute("ambientLight", ambientLight.r + "," + ambientLight.g + "," + ambientLight.b + "," + ambientLight.a);
        _xmlElement.SetAttribute("mInited", mInited.ToString());
        _xmlElement.SetAttribute("penableFog", penableFog.ToString());
        _xmlElement.SetAttribute("pfogColor", pfogColor.r + "," + pfogColor.g + "," + pfogColor.b + "," + pfogColor.a);
        _xmlElement.SetAttribute("pfogMode", ((int)pfogMode).ToString());
        _xmlElement.SetAttribute("pfogDesity", pfogDesity.ToString());
        _xmlElement.SetAttribute("pfogStart", pfogStart.ToString());
        _xmlElement.SetAttribute("pfogEnd", pfogEnd.ToString());
        _xmlElement.SetAttribute("pambientLight", pambientLight.r + "," + pambientLight.g + "," + pambientLight.b + "," + pambientLight.a);
        */

    }
}
