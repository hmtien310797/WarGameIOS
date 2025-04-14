using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using Serclimax;
public class XLevelData : MonoBehaviour 
{
	// resource name of level scene
	public string levelSceneName;

	// all elements in this level
    public List<XElementData> _elementsData;
	public XElementData[] elementsData;

	// all path data
    public XPathPointData[] pathesData;

	// level settings
	public bool enableFog = false;

	public Color fogColor = Color.grey;

	public FogMode fogMode = FogMode.Linear;

	public float fogDesity = 0.01f;

	public float fogStart = 20;

	public float fogEnd = 40;

	public Color ambientLight = Color.grey;
	

	// for convenience
	private Dictionary<int, XElementData> mElementData;
    private Dictionary<int, XPathPointData> mPathData;


	private bool mInited = false;

	bool penableFog = false;
	
	Color pfogColor = Color.grey;
	
	FogMode pfogMode = FogMode.Linear;
	
	float pfogDesity = 0.01f;
	
	float pfogStart = 20;
	
	float pfogEnd = 40;
	
	Color pambientLight = Color.grey;

	// Use this for initialization
	void Awake () 
	{
		Init();
	}

	void OnDisable()
	{
		// Reset render setting
		RenderSettings.ambientLight = pambientLight;
		
		RenderSettings.fog = penableFog;
		RenderSettings.fogColor = pfogColor;
		RenderSettings.fogMode = pfogMode;
		RenderSettings.fogDensity = pfogDesity;
		RenderSettings.fogStartDistance = pfogStart;
		RenderSettings.fogEndDistance = pfogEnd;
	}

	public void Init()
	{
		if (mInited)
			return;

		mInited = true;

		int length = elementsData.Length;
		mElementData = new Dictionary<int, XElementData>(length);
		for (int i=0; i<length; i++)
		{
			mElementData.Add(elementsData[i].uniqueId, elementsData[i]);
		}

		length = pathesData.Length;
        mPathData = new Dictionary<int, XPathPointData>(length);
		for (int i=0; i<length; i++)
		{
			mPathData.Add(pathesData[i].uniqueId, pathesData[i]);
		}

		penableFog = RenderSettings.fog;
		pfogColor = RenderSettings.fogColor;
		pfogMode = RenderSettings.fogMode;
		pfogDesity = RenderSettings.fogDensity;
		pfogStart = RenderSettings.fogStartDistance;
		pfogEnd = RenderSettings.fogEndDistance;
		pambientLight = RenderSettings.ambientLight;

		ResetRender();
	}

	public void ResetRender()
	{
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

    public void ReadFromXml(XmlElement _xmlElement)
    {
        levelSceneName = _xmlElement.GetAttribute("sceneName");
	    enableFog = bool.Parse(_xmlElement.GetAttribute("enableFog"));
	    fogColor = RawTable.ParseColor(_xmlElement.GetAttribute("fogColor"));
        fogMode = (FogMode)(int.Parse(_xmlElement.GetAttribute("fogMode")));
	    fogDesity = float.Parse(_xmlElement.GetAttribute("fogDesity"));
        fogStart = float.Parse(_xmlElement.GetAttribute("fogStart"));
        fogEnd = float.Parse(_xmlElement.GetAttribute("fogEnd"));
        ambientLight = RawTable.ParseColor(_xmlElement.GetAttribute("ambientLight"));
        mInited = bool.Parse(_xmlElement.GetAttribute("mInited"));
        penableFog = bool.Parse(_xmlElement.GetAttribute("penableFog"));
        pfogColor =RawTable.ParseColor( _xmlElement.GetAttribute("pfogColor"));
        pfogMode = (FogMode)(int.Parse(_xmlElement.GetAttribute("pfogMode")));
        pfogDesity = float.Parse(_xmlElement.GetAttribute("pfogDesity"));
        pfogStart = float.Parse(_xmlElement.GetAttribute("pfogStart"));
        pfogEnd = float.Parse(_xmlElement.GetAttribute("pfogEnd"));
        pambientLight = RawTable.ParseColor(_xmlElement.GetAttribute("pambientLight"));
        
        foreach(XmlNode node in _xmlElement.ChildNodes)
        {
            if(node.Name == "LevelElements")
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
        }
    }
   
    public void WriteToXml(XmlDocument _doc , XmlElement _xmlElement)
    {
        _xmlElement.SetAttribute("sceneName", levelSceneName);
        _xmlElement.SetAttribute("enableFog", enableFog.ToString());
        _xmlElement.SetAttribute("fogColor", fogColor.r + "," + fogColor.g + "," + fogColor.b + "," + fogColor.a );
        _xmlElement.SetAttribute("fogMode", ((int)fogMode).ToString());
        _xmlElement.SetAttribute("fogDesity", fogDesity.ToString());
        _xmlElement.SetAttribute("fogStart", fogStart.ToString());
        _xmlElement.SetAttribute("fogEnd", fogEnd.ToString());
        _xmlElement.SetAttribute("ambientLight", ambientLight.r + "," + ambientLight.g + "," + ambientLight.b + "," + ambientLight.a);
        _xmlElement.SetAttribute("mInited", mInited.ToString());
        _xmlElement.SetAttribute("penableFog", penableFog.ToString());
        _xmlElement.SetAttribute("pfogColor", pfogColor.r + "," + pfogColor.g + "," + pfogColor.b + "," + pfogColor.a);
        _xmlElement.SetAttribute("pfogMode", ((int)pfogMode).ToString() );
        _xmlElement.SetAttribute("pfogDesity", pfogDesity.ToString());
        _xmlElement.SetAttribute("pfogStart", pfogStart.ToString());
        _xmlElement.SetAttribute("pfogEnd", pfogEnd.ToString());
        _xmlElement.SetAttribute("pambientLight", pambientLight.r + "," + pambientLight.g + "," + pambientLight.b + "," + pambientLight.a);

        /*
        //element data
        if(elementsData.Length > 0)
        {
            XmlElement mapele = _doc.CreateElement("LevelElements");
            mapele.SetAttribute("count", elementsData.Length.ToString());
            for (int i = 0; i < elementsData.Length; ++i)
            {
                XmlElement ele = _doc.CreateElement("Element");
                elementsData[i].WriteToXml(_doc, ele);
                mapele.AppendChild(ele);
            }
            _xmlElement.AppendChild(mapele);
        }
        
        //todo path points data
        if(pathesData.Length > 0)
        {
            XmlElement xmlPathRoot = _doc.CreateElement("PathPoints");
            xmlPathRoot.SetAttribute("count", pathesData.Length.ToString());
            for(int i=0 ; i<pathesData.Length ; ++i)
            {
                XmlElement elePathP = _doc.CreateElement("PathPoint");
                pathesData[i].WriteToXml(_doc, elePathP);
                xmlPathRoot.AppendChild(elePathP);
            }
            _xmlElement.AppendChild(xmlPathRoot);
        }
         * */
    }
}
