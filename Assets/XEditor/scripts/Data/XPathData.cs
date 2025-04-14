using UnityEngine;
using System.Collections;
using Serclimax;

//#if UNITY_EDITOR
using System.Xml;

[System.Serializable]
public class XPathPointData
{
	// the unique id of the path
	public int uniqueId;
	
	
	// the path type
	public XLevelDefine.PathType pathType;

    public Vector3 worldPosition;
    public int pathGroup;
    public int team;

    public XPathPointData()
	{
		pathType = XLevelDefine.PathType.eXPath;
        pathGroup = 0;
        worldPosition = Vector3.zero;
        team = 1;
	}

	public XPathPointData Clone()
	{
		XPathPointData newPath = new XPathPointData();
		newPath.pathType = pathType;
        newPath.pathGroup = pathGroup;
        newPath.team = team;
        newPath.worldPosition = worldPosition;
		return newPath;
	}
    public Serclimax.Level.ScPathData ToScPathData()
    {
        Serclimax.Level.ScPathData Scdata = new Serclimax.Level.ScPathData();
        Scdata.uniqueId = uniqueId;
        Scdata.pathType = (Serclimax.Level.ScPathData.PathType)pathType;
        Scdata.worldPosition = worldPosition;
        Scdata.pathGroup = pathGroup;
        Scdata.team = team;
        return Scdata;

    }
    public void WriteToXml(XmlDocument _doc, XmlElement _xmlElement)
    {
        _xmlElement.SetAttribute("uniqueId", uniqueId.ToString());
        _xmlElement.SetAttribute("group", pathGroup.ToString());
        _xmlElement.SetAttribute("position", worldPosition.ToString());
        _xmlElement.SetAttribute("team", team.ToString());
    }
    public void ReadFromXml(XmlElement _xmlElement)
    {
        string id = _xmlElement.GetAttribute("uniqueId");
        worldPosition = RawTable.ParseVector3(_xmlElement.GetAttribute("position"));
        pathGroup = int.Parse(_xmlElement.GetAttribute("group"));
        uniqueId = int.Parse(_xmlElement.GetAttribute("uniqueId"));
        team = int.Parse(_xmlElement.GetAttribute("team"));
    }
}

public class XPathGroupData
{
    public int groupId;
    public int teamId;

    // the path points
    public Vector3 GroupPos;

    public XPathGroupData()
    {
        GroupPos = Vector3.zero;
    }

    public void ReadFromXml(XmlElement _xmlElement)
    {
        GroupPos = RawTable.ParseVector3(_xmlElement.GetAttribute("position"));
        groupId = int.Parse(_xmlElement.GetAttribute("group"));
        teamId = int.Parse(_xmlElement.GetAttribute("team"));
    }
}
public class XPathTeamData
{
    public int teamId;
    public string unitTag = string.Empty;
    public XPathTeamData()
    {
        teamId = 0;
    }
}
//#endif