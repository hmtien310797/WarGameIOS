using UnityEngine;
using System.Collections;


#if UNITY_EDITOR
using System.Xml;

[ExecuteInEditMode]
public class XElementEditor : MonoBehaviour
{
	public int mElementUID;

	private XElementData mData;

	public void Init(XElementData _elementData)
	{
		mElementUID = _elementData.uniqueId;

		mData = _elementData;

        if(mData.isGlobal)
        {
            for(int i =0 ; i < mData.mCollideInfo.Count ; ++i )
            {
                GameObject coCube = new GameObject("Cube");
                coCube.transform.position = mData.mCollideInfo[i].centerPosition;
                coCube.transform.forward = mData.mCollideInfo[i].rotation;
            
                BoxCollider bc = coCube.AddComponent<BoxCollider>();
                bc.size = mData.mCollideInfo[i].size;

                coCube.transform.parent = gameObject.transform;
            }
        }
	}

	public XElementData data
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
            XElementData[] elements = XEditorManager.instance.CurLevelDataXml.elementsData;
			for (int i=0; i<elements.Length; i++)
			{
				if (elements[i].uniqueId == mElementUID)
				{
					mData = elements[i];
					break;

				}
			}

			if (Application.isPlaying)
			{
				// destroy the content
				foreach (Transform t in transform)
				{
					DestroyImmediate(t.gameObject);
				}

				// detroy iTween components
				iTween.Stop(gameObject);

				GetComponent<XLevelElement>().Init(mData);
			}
		}
	}

	public void ChangeType()
	{
		 // TODO: the behavior will lead to an error, there is no way to handle it for now
		XLevelElement element = GetComponent<XLevelElement>();
		if (element)
		{
			GameObject.DestroyImmediate(element);
		}

		// destroy the content
		foreach (Transform t in transform)
		{
			DestroyImmediate(t.gameObject);
		}
		
		data.AddComponent(gameObject);
	}

	public void ChangeName()
	{
		name = data.uniqueId + "_" + data.name;

		// destroy the content
		foreach (Transform t in transform)
		{
			DestroyImmediate(t.gameObject);
		}

		XLevelElement element = GetComponent<XLevelElement>();
		if (element)
		{
			element.Init(data);
		}
	}

	void Update()
	{
		if (Application.isPlaying)
			return;

		if (data == null)
		{
			Reconstruct();
		}

        /*
		Transform t = transform;
		if (t.hasChanged)
		{
			data.position = t.position;
			data.rotation = t.rotation;
			data.scale = t.localScale;
			t.hasChanged = false;
		}
         * */
	}

	void OnDrawGizmos() 
	{
		Gizmos.color = Color.clear;
		Gizmos.DrawSphere(transform.position, 1.2f);
	}
    public void saveData()
    {
        mData.position = gameObject.transform.position;
        //mData.rotation = gameObject.transform.rotation;
        mData.forward = gameObject.transform.forward;

        mData.ClearCollideInfo();
        
        //collide
        BoxCollider[] box_collide = GetComponentsInChildren<BoxCollider>();
        if (box_collide.Length > 0)
        {
            for (int i = 0; i < box_collide.Length; ++i)
            {
                mData.AddCollideInfo(box_collide[i]);
            }
        }
    }
    public void WriteToXml(XmlDocument _doc, XmlElement _xmlElement)
    {
        mData.WriteToXml(_doc, _xmlElement);
    }
}
#endif