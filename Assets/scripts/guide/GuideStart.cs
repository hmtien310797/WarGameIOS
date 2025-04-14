using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using Clishow;
using Serclimax;

public class GuideStart
{
    public Serclimax.GuideInfoData Data;
    protected Transform GuideUi = null;
    protected GuideStepBase guiStep = null;
    protected bool mStart = true;
    protected float mDefaultFadeOverTime;

    public GuideStart(GuideStepBase step , Serclimax.GuideInfoData data , Transform ui)
    {
        guiStep = step;
        Data = data;
        GuideUi = ui;

    }
    public virtual bool Start(float _dt)
    {
        if (mDefaultFadeOverTime > 0)
        {
            mDefaultFadeOverTime -= _dt;
        }
        else
        {
            mStart = true;
        }
        return mStart;
    }
    public virtual void Init()
    {
        // 2016/11/09 一次判读，不通过则整个group结束。by:借你蛋
        if(!CheckCondition())
        {
            guiStep.mGroup.Finish();
            return;
        }

        guiStep.DisplayPart = GuideUi.transform.Find(Data._guide_display);
        if (guiStep.DisplayPart != null)
        {
            if (!guiStep.DisplayPart.gameObject.activeSelf)
                guiStep.DisplayPart.gameObject.SetActive(true);
        }
        //text
        string textp = Data._guide_display + "/bg/text_guide";
        Transform textTrf = GuideUi.transform.Find(textp);
        if (textTrf != null)
        {
            textTrf.GetComponent<UILabel>().text = TextManager.Instance.GetText(Data._guide_text);
            textTrf.GetComponent<TypewriterEffect>().ResetToBeginning();
        }

        //guide hint
        if (Data._guide_paramstr != null && Data._guide_paramstr != "NA")
        {
            string[] para = Data._guide_paramstr.Split(',');
            //title
            GuideUi.transform.Find(Data._guide_display + "/bg/bg_mid/txt_title").GetComponent<UILabel>().text = TextManager.Instance.GetText(para[0]);
            //des
            GuideUi.transform.Find(Data._guide_display + "/bg/bg_mid/txt_describe").GetComponent<UILabel>().text = TextManager.Instance.GetText(para[1]);
            //texture
            GuideUi.transform.Find(Data._guide_display + "/bg/bg_mid/Texture").GetComponent<UITexture>().mainTexture = ResourceLibrary.instance.GetIcon(ResourceLibrary.PATH_ICON + "Guide/", para[2]);
        }

        
        if (guiStep.pauseType == GuideStepBase.ePauseType._PAUSE || 
           guiStep.pauseType == GuideStepBase.ePauseType._NOPAUSE_WHENOVER)
        {
            if(SceneManager.instance.gScRoots != null)
            SceneManager.instance.gScRoots.GamePaused = true;
            LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
            if (inGame != null)
            {
                inGame.CallFunc("DisableUI", null);
                inGame.CallFunc("DisableCameraFollowFireLine", null);
                inGame.CallFunc("SetEnableCameraPinch", false);
                inGame.CallFunc("ResetCameraBattleHeight", null);
                inGame.CallFunc("SetEnableCameraDrag", false);
            }
        }
        else
        {
            if(SceneManager.instance.gScRoots != null)
            SceneManager.instance.gScRoots.GamePaused = false;
            LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
            if (inGame != null)
            {
                inGame.CallFunc("SetEnableCameraPinch", true);
                inGame.CallFunc("SetEnableCameraDrag", true);
            }
        }
		      
		mStart = true;
        mDefaultFadeOverTime = 0;
        //开场的fadein 动画
        string[] fadeoutStr = Data._guide_fadeinout.Split(',');
        if (fadeoutStr[0] == "1")
        {
            mStart = false;
            mDefaultFadeOverTime = 1.0f;
            Transform startEffectTop = GuideUi.Find(Data._guide_display + "/black_top");
            Transform startEffectBottom = GuideUi.Find(Data._guide_display + "/black_bottom");
            Transform startEffectRole = GuideUi.Find(Data._guide_display + "/bg");

            if (startEffectTop != null && startEffectBottom != null && startEffectRole != null) // 如果有退场特效，先播放
            {
                TweenPosition EffTop = startEffectTop.Find("black").GetComponent<TweenPosition>();
                TweenPosition EffBottom = startEffectBottom.Find("black").GetComponent<TweenPosition>();
                TweenAlpha roleEff = startEffectRole.GetComponent<TweenAlpha>();

                EffTop.ClearOnFinished();
                EffBottom.ClearOnFinished();
                roleEff.ClearOnFinished();

                
                EffTop.PlayForward();
                EffBottom.PlayForward();
                EventDelegate.Add(EffTop.onFinished, () => {
                    roleEff.PlayForward();
                    EventDelegate.Add(roleEff.onFinished , () =>
                    {
                        Debug.Log("引导start：" + Data._guide_type + " step :" + Data._guide_step);
                    });
                });
               
            }
        }
    }
    public virtual bool CheckCondition()
    {
        return true;
    }
    public bool GetStarStatus()
    {
        return mStart;
    }
}
public class GuideStartWaitTime: GuideStart
{
    private float duringTime = 0;
    private float waitTime = 0;

    public GuideStartWaitTime(GuideStepBase step , GuideInfoData data , Transform ui) : base(step ,data , ui)
    {
    }
    public override void Init()
    {
        if (Data._guide_startparam1 != null && Data._guide_startparam1 != string.Empty)
            waitTime = float.Parse(Data._guide_startparam1);

        duringTime = 0;
        waitTime = 0;
        base.Init();
    }
    public override bool Start(float _dt)
    {
        bool baseStart = base.Start(_dt);
        duringTime += _dt;

        return baseStart && duringTime >= waitTime;
    }
    
}
public class GuideStartWaitCall : GuideStart
{
    public GuideStartWaitCall(GuideStepBase step , GuideInfoData data , Transform ui) : base(step ,data , ui)
    {
       
    }
}
public class GuideStartCheckSpecialArmy:GuideStart
{
    private int mSpecialArmy = 0;
    private int mSpecialArmyIndex = 0;

    public GuideStartCheckSpecialArmy(GuideStepBase step, GuideInfoData data, Transform ui) : base(step ,data , ui)
    {

    }
    public override bool Start(float _dt)
    {

        return true;
    }

    public override void Init()
    {
        if (Data._guide_startparam1 != null && Data._guide_startparam1 != string.Empty)
            mSpecialArmy = int.Parse(Data._guide_startparam1);

        // 2016/11/09 一次判读，不通过则整个group结束。by:借你蛋
        if (!CheckCondition())
        {
            guiStep.mGroup.Finish();
            return;
        }

        string disPrefab = String.Format(Data._guide_display, mSpecialArmyIndex);

        guiStep.DisplayPart = GuideUi.transform.Find(disPrefab);
        guiStep.AddStepOverParam(mSpecialArmyIndex.ToString());
        if (guiStep.DisplayPart != null)
        {
            if (!guiStep.DisplayPart.gameObject.activeSelf)
                guiStep.DisplayPart.gameObject.SetActive(true);
        }
        //text
        string textp = disPrefab + "/bg/text_guide";
        Transform textTrf = GuideUi.transform.Find(textp);
        if (textTrf != null)
        {
            textTrf.GetComponent<UILabel>().text = TextManager.Instance.GetText(Data._guide_text);
            textTrf.GetComponent<TypewriterEffect>().ResetToBeginning();
        }


        if (guiStep.pauseType == GuideStepBase.ePauseType._PAUSE ||
           guiStep.pauseType == GuideStepBase.ePauseType._NOPAUSE_WHENOVER)
        {
            if(SceneManager.instance.gScRoots != null)
            SceneManager.instance.gScRoots.GamePaused = true;
            LuaBehaviour inGame = GUIMgr.Instance.FindMenu("InGameUI");
            if (inGame != null)
            {
                inGame.CallFunc("DisableCameraFollowFireLine", null);
            }
        }


    }
    public override bool CheckCondition()
    {
        List<int> army = GameStateBattle.Instance.SelectArmy;
        for(int i=0; i<army.Count; ++i)
        {
            if (mSpecialArmy == army[i])
            {
                mSpecialArmyIndex = i + 1;
                return true;
            }
        }
        return false;
    }
}