using UnityEngine;
using System.Collections;
using System.Collections.Generic;

#if UNITY_EDITOR
using System.Xml;

[ExecuteInEditMode]
public class XPathEditor : MonoBehaviour
{
	public int mPathUID;

    private XPathPointData mData;

    public void Init(XPathPointData _pathData)
	{
		mPathUID = _pathData.uniqueId;

		mData = _pathData;
	}

    public XPathPointData data
	{
		get
		{
			return mData;
		}
	}
	
	public void Reconstruct()
	{
		mData = null;

		// locate the data
		if (mData == null)
		{
            XPathPointData[] pathes = XEditorManager.instance.CurLevelDataXml.pathesData;
			for (int i=0; i<pathes.Length; i++)
			{
				if (pathes[i].uniqueId == mPathUID)
				{
					mData = pathes[i];
					break;
				}
			}
		}
	}

    public void apply()
    {
        name = mData.uniqueId + XLevelDefine.LEVEL_PATHPOINT_NAME + "_team" + mData.team + "_group"+ mData.pathGroup;
        mData.worldPosition = GetComponent<Transform>().position;
    }
    public void saveData()
    {
       
        mData.worldPosition = gameObject.transform.position;
        
    }
    public void WriteToXml(XmlDocument _doc , XmlElement _xmlElement)
    {
        mData.WriteToXml( _doc ,  _xmlElement);
    }
}
#endif