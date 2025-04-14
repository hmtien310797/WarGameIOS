using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using Serclimax;
[System.Serializable]
public class XElementData
{
	// the unique id of level element
	public int uniqueId;

	// the element type
	public XLevelDefine.ElementType elementType;
	
	// the element name
	public string name;

	// the element id in table, for example monster id in monster's table
	public int tableId;
		
	// initial position
	public Vector3 position;
	
	// initial rotation
	//public Quaternion rotation;
    public Vector3 forward;

    public int teamId = 0;
	// initial scale
	public Vector3 scale;

	// active when intialize
	public bool activeWhenInitial;

	// global in this level (not initialized by Group, but initialized when Level Launch)
	public bool isGlobal;

	// linked elements, as team element will link to the monster elements
	public int[] linkedElementsUID;

	// if foot on ground at beginning
	public bool isFloatInBeginning;

	// used for Mystery, use this tableID instead of origninal
	private int replacedTableId = 0;

	// used for Mystery, hp percentage when monster initial
	private uint hpPercentage = 100;

	// used for new Mystery, attribute for hero
    //private ProtoMsg.HeroAttributeInfo replaceAttribute;
    private Object replaceAttribute;

    public struct CollideInfo
    {
        public string typeName;
        public Vector3 centerPosition;
        public float height;
        public float radius;
        public int direction;
        public Vector3 size;
        public Vector3 rotation;
    };
    public List<CollideInfo> mCollideInfo = new List<CollideInfo>();

    public void ClearCollideInfo()
    {
        if(mCollideInfo != null)
        {
            mCollideInfo.Clear();
        }
    }
    public void AddCollideInfo(CapsuleCollider capCollide)
    {
        CollideInfo collinfo = new CollideInfo();
        collinfo.typeName = typeof(CapsuleCollider).ToString();
        collinfo.centerPosition = capCollide.center;
        collinfo.height = capCollide.height;
        collinfo.radius = capCollide.radius;
        collinfo.direction = capCollide.direction;
        mCollideInfo.Add(collinfo);
    }
    public void AddCollideInfo(BoxCollider boxCollide)
    {
        CollideInfo collinfo = new CollideInfo();
        collinfo.typeName = typeof(BoxCollider).ToString();
        collinfo.centerPosition = boxCollide.center + boxCollide.transform.position ;
        collinfo.size = boxCollide.size;
        collinfo.rotation = boxCollide.transform.forward;
        mCollideInfo.Add(collinfo);
    }
    public void AddBoundsInfo(Bounds bound)
    {
        CollideInfo collinfo = new CollideInfo();
        collinfo.typeName = "bounds";
        collinfo.centerPosition = bound.center;
        collinfo.size = bound.size;
        mCollideInfo.Add(collinfo);
    }
	public bool CheckResIsReady(string _levelChapterPath)
	{
        bool bResult = true;
		return bResult;
	}

	// Clone
	public XElementData Clone()
	{
		XElementData element = new XElementData();
		element.uniqueId = uniqueId;
		element.elementType = elementType;
		element.name = name;
		element.tableId = tableId;
		element.activeWhenInitial = activeWhenInitial;
		element.position = position;
        element.forward = forward;
		element.scale = scale;
		element.isGlobal = isGlobal;
		element.linkedElementsUID = (int[])linkedElementsUID.Clone();
		element.isFloatInBeginning = isFloatInBeginning;
		return element;
	}
    public void ReadFromXml(XmlElement _xmlElement)
    {
        uniqueId = int.Parse(_xmlElement.GetAttribute("uniqueId"));
        elementType = (XLevelDefine.ElementType)int.Parse(_xmlElement.GetAttribute("elementType"));
        name = _xmlElement.GetAttribute("name");
        tableId = int.Parse(_xmlElement.GetAttribute("tableId"));
        activeWhenInitial = bool.Parse(_xmlElement.GetAttribute("activeWhenInitial"));
        string sPosition = _xmlElement.GetAttribute("position");
        position = RawTable.ParseVector3(sPosition);

        forward = RawTable.ParseVector3(_xmlElement.GetAttribute("rotation"));
       // rotation = Quaternion.Euler(forward);
        teamId = int.Parse(_xmlElement.GetAttribute("Team"));
        //rotation.eu(rotationEular);
       
        string sScal = _xmlElement.GetAttribute("scale");
        scale = RawTable.ParseVector3(sScal);

        isGlobal = bool.Parse(_xmlElement.GetAttribute("isGlobal"));
        isFloatInBeginning = bool.Parse(_xmlElement.GetAttribute("isFloatInBeginning"));

        //collide info
        foreach (XmlNode node in _xmlElement.ChildNodes)
        {
            if (node.Name == "Collide")
            {
                XmlElement _xElementsCoInfo = (XmlElement)node;
                CollideInfo co = new CollideInfo();
                co.centerPosition = RawTable.ParseVector3(_xElementsCoInfo.GetAttribute("center"));
                co.size = RawTable.ParseVector3(_xElementsCoInfo.GetAttribute("size"));
                co.rotation = RawTable.ParseVector3(_xElementsCoInfo.GetAttribute("rotation"));
                mCollideInfo.Add(co);
            }
        }
    }
    public Serclimax.Level.ScElementData ToScElementData()
    {
        Serclimax.Level.ScElementData Scdata = new Serclimax.Level.ScElementData();
        Scdata.uniqueId = uniqueId;
        Scdata.tableId = tableId;
        Scdata.position = position;
        Scdata.forward = forward;
        Scdata.teamId = teamId;
        Scdata.elementType = (Serclimax.Level.ScElementData.ElementType)elementType;
        /*
        foreach(CollideInfo co in mCollideInfo)
        {
            
            Serclimax.Level.ScElementData.CollideInfo scCo = new Serclimax.Level.ScElementData.CollideInfo();
            scCo.centerPosition = co.centerPosition;
            scCo.size = co.size;
            scCo.rotation = co.rotation;
            Scdata.AddCollideInfo(scCo);
        }
         * */
        return Scdata;
    }
	public void WriteToXml(XmlDocument _doc, XmlElement _xmlElement)
    {
        _xmlElement.SetAttribute("uniqueId", uniqueId.ToString());
        _xmlElement.SetAttribute("elementType", ((int)elementType).ToString());
        _xmlElement.SetAttribute("name", name);
        _xmlElement.SetAttribute("tableId", tableId.ToString());
        _xmlElement.SetAttribute("activeWhenInitial", activeWhenInitial.ToString());
        _xmlElement.SetAttribute("position", position.x + "," + position.y + "," + position.z);
        //_xmlElement.SetAttribute("rotation", rotation.x + "," + rotation.y + "," + rotation.z + "," + rotation.w);
        _xmlElement.SetAttribute("rotation", forward.x + "," + forward.y + "," + forward.z);
        
        _xmlElement.SetAttribute("scale", scale.x + "," + scale.y + "," + scale.z);
        _xmlElement.SetAttribute("isGlobal", isGlobal.ToString());
        _xmlElement.SetAttribute("isFloatInBeginning", isFloatInBeginning.ToString());
        _xmlElement.SetAttribute("Team", teamId.ToString());
        
        string strLinkedID = string.Empty;
        string cSplite = ",";

        if(linkedElementsUID != null)
        {
            for (int i = 0; i < linkedElementsUID.Length; ++i)
            {
                if (i == linkedElementsUID.Length - 1)
                    strLinkedID = linkedElementsUID[i].ToString();
                else
                    strLinkedID = linkedElementsUID[i].ToString() + ",";
            }
        }
        _xmlElement.SetAttribute("linkedElementsUID", strLinkedID);
        

        //collide info
        foreach(CollideInfo cinfo in mCollideInfo)
        {
            XmlElement collid = _doc.CreateElement("Collide");
            collid.SetAttribute("Type" , cinfo.typeName);
            collid.SetAttribute("center", cinfo.centerPosition.ToString());
            collid.SetAttribute("height", cinfo.height.ToString());
            collid.SetAttribute("radius", cinfo.radius.ToString());
            collid.SetAttribute("direction", cinfo.direction.ToString());
            collid.SetAttribute("size", cinfo.size.ToString());
            collid.SetAttribute("rotation", cinfo.rotation.ToString());
            _xmlElement.AppendChild(collid);
        }
    }
	// Instantiate XLevelElement Component
	public XLevelElement Instantiate()
	{
		GameObject obj = new GameObject(uniqueId + "_" + name);
		XLevelElement result = AddComponent(obj);
        
		return result;
	}

	public XLevelElement AddComponent(GameObject obj)
	{
		XLevelElement result = null;

		switch (elementType)
		{
            case XLevelDefine.ElementType.Defense:
            case XLevelDefine.ElementType.Unit:
			    result = obj.AddComponent<XLevelInuObject>();
			break;
			
		
		default:
			break;
		}

		if (result)
		{
			result.Init(this);
		}
		return result;
	}


}
