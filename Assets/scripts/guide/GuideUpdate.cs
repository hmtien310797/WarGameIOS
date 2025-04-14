using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using Clishow;
using Serclimax;

public class GuideUpdate
{
    protected Transform GuideUi = null;
    public Serclimax.GuideInfoData Data;
    protected GuideStepBase guiStep = null;

    public GuideUpdate(GuideStepBase step ,Serclimax.GuideInfoData data, Transform ui)
    {
        Data = data;
        GuideUi = ui;
        guiStep = step;
    }
    public virtual bool Update(float _dt)
    {
        return true;
    }
    public virtual void Finish()
    {
        Data = null;
        GuideUi = null;
    } 
    public virtual void Init()
    {
        
    }


}

public class GuideUpdateBuildFlash : GuideUpdate
{
    private CsUnit targetObj = null;
    private Transform animationCom = null;
    private SkinnedMeshRenderer objMeshRender = null;
    public GuideUpdateBuildFlash(GuideStepBase step , Serclimax.GuideInfoData data, Transform ui) : base(step, data, ui)
    {
    }
    public override bool Update(float _dt)
    {
        //todo: building flash
        //if(targetObj != null)
        //{
        //    Transform rendobj = targetObj.transform.FindChild(targetObj._modelPrefab.name + "(Clone)") as Transform;
        //    if(rendobj != null)
        //    {
        //        objMeshRender = rendobj.GetComponentInChildren<SkinnedMeshRenderer>();
        //        if (objMeshRender != null)
        //        {

        //            float c_g = Mathf.Lerp(0, 128, startFlashTime / flashTime);
        //            objMeshRender.materials[0].SetColor("_AdditiveColor", new Color(0, c_g, 0));
        //        }
        //    }
        //}
        //startFlashTime += _dt;
        //duringTime += _dt;
        //if(startFlashTime >= flashTime)
        //{
        //    startFlashTime = 0;
        //}

        return false;
    }
    public override void Init()
    {
        base.Init();
        targetObj = CsUnitMgr.Instance.GetGuideTargetUnit(Data._guide_updateobj);

        if(targetObj != null)
        {
            animationCom = targetObj.transform.Find(targetObj._modelPrefab.name + "(Clone)") as Transform;
            if (animationCom != null)
            {
                animationCom.GetComponent<Animation>().Play("changecolour");
            }
        }
    }
    public override void Finish()
    {
        base.Finish();
        if (animationCom != null && animationCom.GetComponent<Animation>() != null)
        {
            animationCom.GetComponent<Animation>().Play("idle");
        }
        targetObj = null;
        animationCom = null;
    }
}
public class GuideUpdateRegionFlash : GuideUpdate
{
    private GameObject mFireLine; 
    public GuideUpdateRegionFlash(GuideStepBase step , Serclimax.GuideInfoData data, Transform ui) : base(step ,data, ui)
    {
    }
    public override void Init()
    {
        base.Init();
        mFireLine = SceneManager.instance.GetFireline();
        if(mFireLine != null)
        {
            mFireLine.SetActive(true);
            mFireLine.GetComponent<FirelineController>().Flash(1f, 1f);
        }
        /*
        targetObj = CsUnitMgr.Instance.GetGuideTargetUnit(Data._guide_updateobj);

        if (targetObj != null)
        {
            animationCom = targetObj.transform.FindChild(targetObj._modelPrefab.name + "(Clone)") as Transform;
            if (animationCom != null)
            {
                animationCom.GetComponent<Animation>().Play("changecolour");
            }
        }
        */
    }
    public override bool Update(float _dt)
    {
        return false;
    }
    public override void Finish()
    {
        base.Finish();
        if(mFireLine != null)
        {
            mFireLine.SetActive(false);
            mFireLine.GetComponent<FirelineController>().StopFlash();
        }
    }
}

public class GuideUpdateActiveMenuObj : GuideUpdate
{
    private GameObject mTargetMenuObj = null;
    public GuideUpdateActiveMenuObj(GuideStepBase step, Serclimax.GuideInfoData data, Transform ui) : base(step ,data, ui)
    {
    }
    public override void Init()
    {
        base.Init();
        mTargetMenuObj = GameObject.Find(Data._guide_updateobj);
        if(mTargetMenuObj != null)
        {
            mTargetMenuObj.SetActive(false);
        }
    }
    public override bool Update(float _dt)
    {
        return false;
    }
    public override void Finish()
    {
        base.Finish();
        if (mTargetMenuObj != null)
        {
            mTargetMenuObj.SetActive(true);
        }
    }
}
public class GuideUpdateUnlockSoldier : GuideUpdate
{
    public GuideUpdateUnlockSoldier(GuideStepBase step, Serclimax.GuideInfoData data, Transform ui) : base(step, data, ui)
    {
    }
    public override void Init()
    {
        base.Init();
        LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
        if (inGame != null)
        {
            inGame.CallFunc("UnlockArmyOrHero", null);
        }
    }
    public override bool Update(float _dt)
    {
        return false;
    }
    public override void Finish()
    {
        base.Finish();
        
    }
}
public class GuideUpdateUnlockHero : GuideUpdate
{
    public GuideUpdateUnlockHero(GuideStepBase step, Serclimax.GuideInfoData data, Transform ui) : base(step, data, ui)
    {
    }
    public override void Init()
    {
        base.Init();
        LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
        if (inGame != null)
        {
            inGame.CallFunc("UnlockArmyOrHero", null);
        }
    }
    public override bool Update(float _dt)
    {
        return false;
    }
    public override void Finish()
    {
        base.Finish();

    }
}

public class GuideUpdateActiveUIPoint : GuideUpdate
{
    private GameObject gameCamera = null;
    private Camera uiMainCamera = null; 
    private CsUnit targetObj = null;
    public float hudPosHeight = 4;

    public GuideUpdateActiveUIPoint(GuideStepBase step, Serclimax.GuideInfoData data, Transform ui) : base(step, data, ui)
    {
    }
    public override void Init()
    {
        base.Init();
        uiMainCamera = UICamera.mainCamera;
        targetObj = CsUnitMgr.Instance.GetGuideTargetUnit(Data._guide_updateobj);
        if (targetObj != null)
        {
            Vector3 uipos = Camera.main.WorldToScreenPoint(targetObj.transform.position + Vector3.up * hudPosHeight);

            if (uiMainCamera != null)
            {
                Vector3 worldPos = uiMainCamera.ScreenToWorldPoint(uipos);
                worldPos.z = 0;
                GuideUi.position = worldPos;
                

                Vector3 lp = GuideUi.localPosition;
                lp.x = Mathf.RoundToInt(lp.x);
                lp.y = Mathf.RoundToInt(lp.y);
                GuideUi.localPosition = lp;
            }


            
        }
    }
    public override bool Update(float _dt)
    {
        return false;
    }
    public override void Finish()
    {
        GuideUi.position = Vector3.zero;
        GuideUi.localPosition = Vector3.zero;
        base.Finish();
    }
}

public class GuideUpdateOpenUI : GuideUpdate
{
    private LuaBehaviour unlock;
    private string uiName = string.Empty;
    public GuideUpdateOpenUI(GuideStepBase step, Serclimax.GuideInfoData data, Transform ui) : base(step, data, ui)
    {
    }
    public override void Init()
    {
        base.Init();
        string[] updateParams = Data._guide_updateobj.Split(',');
        uiName = updateParams[0];
        if(uiName != string.Empty && uiName != "NA")
        {
            if(!GUIMgr.Instance.FindMenu(uiName))
            {
                unlock =  GUIMgr.Instance.CreateMenu(uiName);
                unlock.CallFunc("SetUnlockId", Data._guide_updateobj , null/*updateParams[2], updateParams[1]*/);

                if(updateParams.Length >= 4)
                {
                
                    //unlock.transform.Find("bg_soldier/bg/bg_mid/3Darea").GetComponent<UIWidget>().localSize.y = float.Parse( updateParams[3]);
                }
                

                BoxCollider close = unlock.transform.Find("bg_soldier/bg/text_sure").GetComponent<BoxCollider>();
                var listener = UIEventListener.Get(close.gameObject);
                listener.onClick += ClickCallBack;
            }
        }
    }
    public void ClickCallBack(GameObject go)
    {

    }
    public override bool Update(float _dt)
    {
        return false;
    }
    public override void Finish()
    {
        if (unlock != null)
        {
            GUIMgr.Instance.CloseMenu(uiName);
            unlock = null;
        }
        base.Finish();
       
    }
}