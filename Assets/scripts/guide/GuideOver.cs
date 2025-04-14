using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using Clishow;
using Serclimax;


public class GuideOver
{
    protected bool isFinish = false;
    protected Transform GuideUi = null;
    public Serclimax.GuideInfoData Data;
    protected GuideStepBase guiStep = null;

    //fade in/out controll
    protected float mDefaultFadeOverTime;
    protected bool mFadeStatus = false;


    public GuideOver(GuideStepBase step  , Serclimax.GuideInfoData data , Transform ui)
    {
        Data = data;
        GuideUi = ui;
        guiStep = step;
    }
    public virtual bool IsFinish(float _dt)
    {
        if(mFadeStatus)
        {
            if (mDefaultFadeOverTime > 0)
                mDefaultFadeOverTime -= _dt;
            else
            {
                mFadeStatus = false;
                isFinish = true;
            }
        }
        return isFinish;
    }

    public virtual void Init()
    {
        isFinish = false;
        mDefaultFadeOverTime = 0;
        mFadeStatus = false;
    }
    public virtual void StepFinish()
    {
        string[] fadeoutStr = Data._guide_fadeinout.Split(',');
        if (fadeoutStr[1] == "1")
        {
            mDefaultFadeOverTime = 1.0f;
            mFadeStatus = true;
            Transform overEffectTop = GuideUi.Find(Data._guide_display + "/black_top");
            Transform overEffectBottom = GuideUi.Find(Data._guide_display + "/black_bottom");
            Transform overEffectRole = GuideUi.Find(Data._guide_display + "/bg");

            if (overEffectTop != null && overEffectBottom != null && overEffectRole != null) // 如果有退场特效，先播放
            {
                TweenAlpha roleEff = overEffectRole.GetComponent<TweenAlpha>();
                TweenPosition overEffTop = overEffectTop.Find("black").GetComponent<TweenPosition>();
                TweenPosition overEffBottom = overEffectBottom.Find("black").GetComponent<TweenPosition>();

                bool isFade = roleEff.isActiveAndEnabled || overEffTop.isActiveAndEnabled || overEffBottom.isActiveAndEnabled;
                Debug.Log(isFade);

                roleEff.ClearOnFinished();
                roleEff.PlayReverse(!isFade);


                EventDelegate.Add(roleEff.onFinished, () =>
                {
                    overEffTop.ClearOnFinished();
                    overEffBottom.ClearOnFinished();
                    overEffTop.PlayReverse(!isFade);
                    overEffBottom.PlayReverse(!isFade);

                    EventDelegate.Add(overEffTop.onFinished, () =>
                    {
                        //isFinish = true;
                        Debug.Log("引导finish：" + Data._guide_type + " step :" + Data._guide_step);
                    });

                });
            }
        }
        else
        {
            isFinish = true;
        }
    }
    public virtual void Finished()
    {
        if (guiStep.pauseType == GuideStepBase.ePauseType._PAUSE ||
            guiStep.pauseType == GuideStepBase.ePauseType._NOPAUSE_WHENOVER)
        {
            if(SceneManager.instance.gScRoots != null)
            SceneManager.instance.gScRoots.GamePaused = false;
            LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
            if (inGame != null)
            {
                inGame.CallFunc("EnableCameraFollowFireLine", false);
                inGame.CallFunc("SetEnableCameraPinch", true);
                inGame.CallFunc("SetEnableCameraDrag", true);
                inGame.CallFunc("EnableUI", null);
            }
        }
    }
}
public class GuideOverPress : GuideOver
{
    private UIButton btnOver = null;

    public GuideOverPress(GuideStepBase step, GuideInfoData data, Transform ui) : base(step, data, ui)
    {

    }

    public override void Init()
    {
        base.Init();
        if (GuideUi != null)
        {
            Transform overTrf = GuideUi.Find(Data._guide_display + "/bg/btn_over");
            if (overTrf != null)
            {
                btnOver = overTrf.GetComponent<UIButton>();
                var listener = UIEventListener.Get(btnOver.gameObject);
                //listener.onClick += ClickCallBack;

                if (Data._guide_resparam != null && Data._guide_resparam != string.Empty)
                {
                    string[] pars = Data._guide_resparam.Split(',');
                    string btnParam = pars.Length > 1 ? pars[0] : string.Empty;
                    if (btnParam != string.Empty && btnParam == "resetbtn")
                    {
                        LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
                        if (inGame != null)
                        {
                            inGame.CallFunc("CancelArmyPressState", null);
                        }
                    }


                    listener.onPress += PressCallBack;
                }
                else
                {
                    listener.onClick += ClickCallBack;
                }
            }
        }
    }

    
    public void PressCallBack(GameObject go, bool press)
    {
        if (!guiStep.GetStepStartStatus())
            return;

        string[] pars = Data._guide_resparam.Split(',');
        string objName = pars.Length > 1 ? pars[1] : pars[0];

        GameObject btnObj = GameObject.Find(objName);
        if (btnObj != null)
        {
            btnObj.SendMessage("OnPress", press);
            LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
            if (inGame != null)
            {
                inGame.CallFunc("SetEnableCameraDrag", !press);
            }
        }

        if (!press)
        {
            StepFinish();
        }
    }
    public void ClickCallBack(GameObject go)
    {
        if (!guiStep.GetStepStartStatus())
            return;

        Transform textTrf = GuideUi.Find(Data._guide_display + "/bg/text_guide");
        if (textTrf != null)
        {
            TypewriterEffect tywrite = textTrf.GetComponent<TypewriterEffect>();
            if (tywrite != null)
            {
                if (tywrite.isActive)
                {
                    tywrite.Finish();
                    return;
                }
            }
        }

        StepFinish();
    }

    public override void StepFinish()
    {
        base.StepFinish();
        if (btnOver != null)
        {
            var listener = UIEventListener.Get(btnOver.gameObject);
            if (Data._guide_resparam != null && Data._guide_resparam != string.Empty)
            {
                listener.onPress -= PressCallBack;
            }
            else
            {
                listener.onClick -= ClickCallBack;
            }
        }
    }
    public override void Finished()
    {
        base.Finished();
        if (guiStep.pauseType == GuideStepBase.ePauseType._NOPAUSE_WHENOVER)
        {
            if(SceneManager.instance.gScRoots != null)
            SceneManager.instance.gScRoots.GamePaused = false;
        }
    }
}

public class GuideOverAutoMoveCamera : GuideOver
{
    private GameObject gameCamera = null;
    private Vector3 targetPos ;
    private float movespeed = 1f;
    private Vector3 movedir;
    private UIButton btnOver = null;
    private bool isArrive = false;

    public GuideOverAutoMoveCamera(GuideStepBase step , GuideInfoData data , Transform ui) : base(step ,data , ui)
    {
        
    }

    public override void Init()
    {
        base.Init();
        gameCamera = GameObject.Find("Main Camera");
        float posx = 0; 
        float posz = 0;
        if (Data._guide_resparam == "0")
        {

            Vector3 pr = (Vector3)guiStep.mGroup.mParams;
            posx = pr.x;
            posz = pr.z;
            targetPos = new Vector3(posx, gameCamera.transform.position.y, gameCamera.transform.position.z);
        }
        else
        {
            string[] para = Data._guide_resparam.Split(',');
            posx = float.Parse(para[0]);
            posz = float.Parse(para[1]);
            targetPos = new Vector3(posx, gameCamera.transform.position.y, posz);
        }

        mDefaultFadeOverTime = 3.0f;
        movedir = (targetPos - gameCamera.transform.position).normalized;

        LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
        if (inGame != null)
        {
            inGame.CallFunc("SetEnableCameraDrag", false);
            inGame.CallFunc("SetEnableCameraPinch", false);
            inGame.CallFunc("SetCameraFollowPosition", targetPos);
        }
    }
    public override void StepFinish()
    {
        isArrive = true;
        base.StepFinish();
    }
    public override bool IsFinish(float _dt)
    {
        float posx = 0;
        float posz = 0;
        if (Data._guide_resparam == "0")
        {

            Vector3 pr = (Vector3)guiStep.mGroup.mParams;
            posx = pr.x;
            posz = pr.z;
            targetPos = new Vector3(posx, gameCamera.transform.position.y, gameCamera.transform.position.z);
        }
        else
        {
            string[] para = Data._guide_resparam.Split(',');
            posx = float.Parse(para[0]);
            posz = float.Parse(para[1]);
            targetPos = new Vector3(posx, gameCamera.transform.position.y, posz);
        }

        if (mDefaultFadeOverTime > 0)
            mDefaultFadeOverTime -= _dt;


        Vector3 dir = (targetPos - gameCamera.transform.position).normalized;
        float dis = (targetPos - gameCamera.transform.position).magnitude;
       // Debug.Log("============" + dis);
        if (dir == -movedir || dis < 0.1 || mDefaultFadeOverTime <= 0)//arrive
        {
            gameCamera.transform.position = targetPos;
            StepFinish();
            if (guiStep.pauseType == GuideStepBase.ePauseType._NOPAUSE_WHENOVER)
            {
                if(SceneManager.instance.gScRoots != null)
                SceneManager.instance.gScRoots.GamePaused = false;
            }

        }
        return isFinish;
    }
    public override void Finished()
    {
        if (guiStep.pauseType == GuideStepBase.ePauseType._PAUSE ||
            guiStep.pauseType == GuideStepBase.ePauseType._NOPAUSE_WHENOVER)
        {
            LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
            if (inGame != null)
            {

                inGame.CallFunc("SetEnableCameraDrag", true);
                inGame.CallFunc("EnableCameraFollowFireLine", true);
                inGame.CallFunc("SetEnableCameraPinch", true);
            }
        }
    }
}
public class GuideOverMoveCamera : GuideOver
{
    private GameObject gameCamera = null;
    private Vector3 targetPos;
    private float movespeed = 0.03f;
    private Vector3 movedir;

    public GuideOverMoveCamera(GuideStepBase step ,GuideInfoData data , Transform ui) : base(step ,data , ui)
    {
    }
    public override void Init()
    {
        base.Init();
        gameCamera = GameObject.Find("Main Camera");
        string[] para = Data._guide_resparam.Split(',');
        float posx = float.Parse(para[0]);
        float posz = float.Parse(para[1]);
        targetPos = new Vector3(posx, gameCamera.transform.position.y, posz);
        movedir = (targetPos - gameCamera.transform.position).normalized;

        LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
        if (inGame != null)
        {
            inGame.CallFunc("DisableUI",null);
        }
    }
    public override bool IsFinish(float _dt)
    {
        float deltaX = Controller.instance.GetDeltaX();
        float deltaZ = Controller.instance.GetDeltaY();
        LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
        if (inGame != null)
        {
            inGame.CallFunc("MoveCamera", -deltaX * movespeed, deltaZ * movespeed);
        }


        Vector3 dir = (targetPos - gameCamera.transform.position).normalized;
        if (dir == -movedir)
        {
            if (guiStep.pauseType == GuideStepBase.ePauseType._NOPAUSE_WHENOVER)
            {
                if(SceneManager.instance.gScRoots != null)
                SceneManager.instance.gScRoots.GamePaused = false;
            }

            gameCamera.transform.position = targetPos;

            if (inGame != null)
            {
                inGame.CallFunc("EnableUI", null);
            }
            StepFinish();
        }
        return isFinish;
    }
}

public class GuideOverWaitTime: GuideOver
{
    private float waitTime = 0;
    private float passTime = 0;
    public GuideOverWaitTime(GuideStepBase step , GuideInfoData data, Transform ui) : base(step ,data , ui)
    {

    }
    public override void Init()
    {
        passTime = 0;
        waitTime = float.Parse(Data._guide_resparam);
    }
 
    public override bool IsFinish(float _dt)
    {
        if(passTime >= waitTime)
        {
            StepFinish();
            if (guiStep.pauseType == GuideStepBase.ePauseType._NOPAUSE_WHENOVER)
            {
                if(SceneManager.instance.gScRoots != null)
                SceneManager.instance.gScRoots.GamePaused = false;
            }
        }
        else
        {
            passTime += _dt;
        }
        return isFinish;
    }
}

public class GuideOverPressWithOneParam : GuideOver
{
    private UIButton btnOver = null;

    public GuideOverPressWithOneParam(GuideStepBase step, GuideInfoData data, Transform ui) : base(step ,data , ui)
    {

    }

    public override void Init()
    {
        base.Init();
        if (GuideUi != null && guiStep.DisplayPart != null)
        {
            Transform overTrf = guiStep.DisplayPart.Find("bg/btn_over");
            if (overTrf != null)
            {
                btnOver = overTrf.GetComponent<UIButton>();
                var listener = UIEventListener.Get(btnOver.gameObject);
                //listener.onClick += ClickCallBack;

                if (Data._guide_resparam != null && Data._guide_resparam != string.Empty)
                {
                    listener.onPress += PressCallBack;
                }
                else
                {
                    listener.onClick += ClickCallBack;
                }
            }
        }
    }

    public void PressCallBack(GameObject go, bool press)
    {
        if (!guiStep.GetStepStartStatus())
            return;

        string overParam = guiStep.GetStepParam()[0];
        GameObject btnObj = GameObject.Find(string.Format(Data._guide_resparam , overParam, overParam));
        if (btnObj != null)
        {
            btnObj.SendMessage("OnPress", press);
            LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
            if (inGame != null)
            {
                inGame.CallFunc("SetEnableCameraDrag", !press);
            }
        }

        if (!press)
        {
            StepFinish();
        }
    }
    public void ClickCallBack(GameObject go)
    {
        if (!guiStep.GetStepStartStatus())
            return;

        Transform textTrf = guiStep.DisplayPart.Find("bg/text_guide");
        if (textTrf != null)
        {
            TypewriterEffect tywrite = textTrf.GetComponent<TypewriterEffect>();
            if (tywrite != null)
            {
                if (tywrite.isActive)
                {
                    tywrite.Finish();
                    return;
                }
            }
        }
        StepFinish();
    }

    public override void StepFinish()
    {
        base.StepFinish();
        if (btnOver != null)
        {
            var listener = UIEventListener.Get(btnOver.gameObject);
            if (Data._guide_resparam != null && Data._guide_resparam != string.Empty)
            {
                listener.onPress -= PressCallBack;
            }
            else
            {
                listener.onClick -= ClickCallBack;
            }
        }
    }

    public override void Finished()
    {
        base.Finished();
        if (guiStep.pauseType == GuideStepBase.ePauseType._NOPAUSE_WHENOVER)
        {
            if(SceneManager.instance.gScRoots != null)
            SceneManager.instance.gScRoots.GamePaused = false;
        }
        if (btnOver != null)
        {
            var listener = UIEventListener.Get(btnOver.gameObject);
            if (Data._guide_resparam != null && Data._guide_resparam != string.Empty)
            {
                listener.onPress -= PressCallBack;
            }
            else
            {
                listener.onClick -= ClickCallBack;
            }
        }
    }
}

