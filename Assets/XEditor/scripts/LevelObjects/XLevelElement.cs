using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

public class XLevelElement : MonoBehaviour 
{
	// transform of XLevelElement
	protected Transform mTransform;

	// real object of tween animation, mostly that is XLevelElement self, except which is InuObject ofr XLevelInuObject
	protected GameObject mTweenObject;
	protected Transform mTweenTransform;

	protected XElementData mData;
	protected GameObject mContent;
	protected Animation mContentAnimation;

	protected Dictionary<string, object> mOptionsHash = new Dictionary<string, object>();

	// for link function
	protected XLevelElement mParent;
	protected XLevelElement[] mLinkedChildren;

	// for XPath function
    private XPathPointData mPath;
	private int mCurrentPathPoint;
	private float mPathTimer;
	private bool mTimerForward;


	public virtual void Init(XElementData _data)
	{
		mData = _data;
		mTransform = transform;
		mTweenObject = gameObject;
		mTweenTransform = mTransform;

		mTransform.localScale = mData.scale;
		mTransform.forward = mData.forward;
		mTransform.position = mData.position;

		if (mContent)
		{
			GameObject.DestroyImmediate(mContent);
			mContent = null;
		}
		CreateContent();

		if (Application.isPlaying && !mData.activeWhenInitial)
		{
			gameObject.SetActive(false);
		}

		if (mContent)
		{

		}

		ResetPath();
	}

	protected virtual void CreateContent() {}


	public XLevelDefine.ElementType type
	{
		get
		{
			return mData.elementType;
		}
	}
    public int TableID
    {
        get 
        {
            return mData.tableId;
        }
    }
	public int uid
	{
		get
		{
			return mData.uniqueId;
		}
	}

	public Transform tt
	{
		get
		{
			return mTransform;
		}
	}

	public Transform tweenTransform
	{
		get
		{
			return mTweenTransform;
		}
	}

	public virtual Vector3 Position
	{
		get
		{
			return mTweenTransform.position;
		}
		set
		{
			mTweenTransform.position = value;
		}
	}

	public virtual Quaternion Rotation
	{
		get
		{
			return mTweenTransform.rotation;
		}
		set
		{
			mTweenTransform.rotation = value;
		}
	}

	public virtual Vector3 Scale
	{
		get
		{
			return mTweenTransform.localScale;
		}
		set
		{
			mTweenTransform.localScale = value;
		}
	}

	public XElementData data
	{
		get
		{
			return mData;
		}
	}

	public GameObject Content
	{
		get
		{
			return mContent;
		}
	}



	// Use this for initialization
	protected virtual void Start () 
	{
	
	}
	
	// Update is called once per frame
	protected virtual void Update () 
	{
		if (mPath != null)
		{
		}
	}

	protected virtual void OnDestroy()
	{
	}

	
	

    
	

	public virtual void HandleLinks()
	{
		if (data.linkedElementsUID != null && data.linkedElementsUID.Length > 0)
		{
			mLinkedChildren = new XLevelElement[data.linkedElementsUID.Length];
			for (int i=0; i<data.linkedElementsUID.Length; i++)
			{
				mLinkedChildren[i] = XLevelManager.instance.GetElementByUID(data.linkedElementsUID[i]);
				if (mLinkedChildren[i])
				{
					if (mLinkedChildren[i].Parent != null)
					{
						Debug.LogWarning("Duplicated Parent("+name+") for element:"+mLinkedChildren[i].name);
					}
					mLinkedChildren[i].Parent = this;
				}
			}
		}
	}
   
	public virtual XLevelElement Parent
	{
		set
		{
			mParent = value;
		}
		get
		{
			return mParent;
		}
	}



	protected void ResetPath()
	{
		mCurrentPathPoint = 0;
		mPathTimer = 0;
		mPath = null;
		//mPathEventData = null;
	}

	
	Transform FindDummyTransforms(Transform t, string _dummyName)
	{
		Transform ret;
		int childCount = t.childCount;
		for (int i=0; i<childCount; i++)
		{
			ret = t.GetChild(i);
			if (ret.name == _dummyName)
			{
				return ret;
			}

			ret = FindDummyTransforms(ret, _dummyName);
			if (ret)
			{
				return ret;
			}
		}
		return null;
	}

    public void SetCollideInfoData()
    {
        if(mContent != null)
        {
            CapsuleCollider[] cap_collide = mContent.GetComponentsInChildren<CapsuleCollider>();
            
        }
    }
}
