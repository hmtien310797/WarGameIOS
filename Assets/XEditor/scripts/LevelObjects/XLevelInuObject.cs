using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

using Serclimax;
using Clishow;
public class XLevelInuObject : XLevelElement {

	private CsUnit mUnit;
    private CsBuild mBuild;
    private object mTempHeroData;

#if UNITY_EDITOR
	protected override void CreateContent()
	{
        int tableId =  mData.tableId;
        if (tableId < 0)
            return;

        
        if (mData.elementType == XLevelDefine.ElementType.Defense)
        {
           // DefenseInfo.Data defInfo = XTableData.instance.GetBattleDefense(tableId);
            Serclimax.Unit.ScUnitDefenseData defInfo = XEditorManager.eScTableData.GetTable<Serclimax.Unit.ScUnitDefenseData>().GetData(tableId);
            if (defInfo != null)
            {
                CreatContentUnit(defInfo._unitDefensePrefab, mData.elementType);
               // CreatContentBuild(defInfo.mPrefab);
            }

        }
        else if(mData.elementType == XLevelDefine.ElementType.Unit)
        {
            Serclimax.Unit.ScUnitData unitdata = XEditorManager.eScTableData.GetTable<Serclimax.Unit.ScUnitData>().GetData(tableId);
            if(unitdata != null)
            {
                CreatContentUnit(unitdata._unitPrefab, mData.elementType);
            }
        }


        if (mContent)
        {
            Vector3 contentsize = mContent.transform.localScale;

            mContent.transform.parent = mTransform;
            mContent.transform.position = mTransform.position;
            mContent.transform.rotation = mTransform.rotation;

            mContent.transform.localScale = contentsize;

            mTweenObject = mContent;
            mTweenTransform = mContent.transform;
        }
	}

    public void CreatContentUnit(string prefab , XLevelDefine.ElementType type)
    {
        if(type == XLevelDefine.ElementType.Unit)
        {
            mContent = ResourceLibrary.instance.GetLevelUnitInstance(prefab, type, mTransform.position, mTransform.rotation);
        }
        else if(type == XLevelDefine.ElementType.Defense)
        {
            mContent = ResourceLibrary.instance.GetLevelObjectInstance(prefab);
        }
        else
        {
            return;
        }
        if (mContent)
        {
            mUnit = mContent.GetComponent<CsUnit>();
            if (mUnit)
            {
                //load modulel
                if (mUnit._modelPrefab)
                {
                    GameObject modulePrefab = GameObject.Instantiate(mUnit._modelPrefab);
                    if (modulePrefab)
                    {
                        modulePrefab.transform.parent = mContent.transform;
                        modulePrefab.transform.position = mContent.transform.position;
                        modulePrefab.transform.rotation = mContent.transform.rotation;
                    }
                }
            }
        }
    }
#endif
}

