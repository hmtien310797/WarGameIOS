using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Clishow;
using System;
using ProtoMsg;
using System.Text;

public class GameStateSLGBattle : GameState
{
    private static GameStateSLGBattle instance;

    private CsSLGPVPMgr.CsSLGPVPLoader mLoader = null;

    private int mBattleID;

    private bool mEnableLog = false;

    public Serclimax.SLGPVP.ScSLGPlayer[] SlgPlayers;

    public HeroBuffShowInfo heroBuffs;

    [LuaInterface.LuaByteBufferAttribute]
    public delegate void OnGameOver_Debug(byte[] reslut);

    public OnGameOver_Debug onGameOver_Debug;

    public delegate void OnGameOver();

    public OnGameOver onGameOver;

    public delegate void OnShowBattleState(int round,float[] hps);

    public OnShowBattleState onShowBattleState;

    public delegate void OnShowBeatHurt(Vector3 pos,int type,Int64 hurt);

    public OnShowBeatHurt onShowBeatHurt;

    public delegate void OnAnimFinish();

    public OnAnimFinish onAnimFinish;

    public delegate void OnSkipShowHeroFinish();

    public OnSkipShowHeroFinish onSkipShowHeroFinish;

     public delegate void OnShowHeroFinish();
    public OnShowHeroFinish onShowHeroFinish;

     public delegate void OnShowHero(int heroIndex);
    public OnShowHero onShowHero;

     public delegate void OnShowHeroSkillEffect(int[] hero_base_ids,float time);
    public OnShowHeroSkillEffect onShowHeroSkillEffect;


    public int Slg_Random_Seed;

    public string strAConfig = "";
    public string strDConfig = "";
    public string strPhalanxConfig = "";

    private GameStateSLGBattle()
    {
    }

    public static void InitSimulateSLGPVPCfg()
    {


        //float ExtralAttackForce = 1;
        //float AssistForce = 1;
        //float RestraintForce = 1.5f;
        //float WeakForce = 0.5f;
        //float DefenseForce = 1;
        //float CriticalChance = 0.2f;
        //float CriticalFactor = 1.5f;
        //float BlockChance = 0.2f;
        //float BlockFactor = 0.5f;
        //int[] WinLoseRoundCount = new int[3] { 10, 110, 200 };
        //float[] WinRevertPercent = new float[3] { 0.1f, 0.2f, 0.3f };
        //float[] LoseRevertPercent = new float[3] { 0.1f, 0.2f, 0.3f };
        //int[][] RestraintRelations = new int[6][]{
        //new int[]{0,1,0,0,0,0},
        //new int[]{-1,0,1,0,0,0},
        //new int[]{0,-1,0,1,0,0},
        //new int[]{1,0,0,-1,0,0},
        //new int[]{1,1,0,0,0,0},
        //new int[]{0,0,1,1,0,0}
        //};
        
        Serclimax.SLGPVP.ScSLGPvP.ExtralAttackForce = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.ExtralAttackForce).value);
        Serclimax.SLGPVP.ScSLGPvP.AssistForce = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.AssistForce).value);
        Serclimax.SLGPVP.ScSLGPvP.RestraintForce = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.RestraintForce).value);
        Serclimax.SLGPVP.ScSLGPvP.WeakForce = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.WeakForce).value);
        Serclimax.SLGPVP.ScSLGPvP.DefenseForce = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.DefenseForce).value);
        Serclimax.SLGPVP.ScSLGPvP.CriticalChance = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.CriticalChance).value);
        Serclimax.SLGPVP.ScSLGPvP.CriticalFactor = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.CriticalFactor).value);
        Serclimax.SLGPVP.ScSLGPvP.BlockChance = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.BlockChance).value);
        Serclimax.SLGPVP.ScSLGPvP.BlockFactor = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.BlockFactor).value);
        Serclimax.SLGPVP.ScSLGPvP.ExtralAttack = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.ExtralAttack).value);
        Serclimax.SLGPVP.ScSLGPvP.MagicHurtFactor6 = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.MagicHurtFactor6).value);
        Serclimax.SLGPVP.ScSLGPvP.MagicHurtFactor14 = float.Parse(Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.MagicHurtFactor14).value);
        string t =Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.WinLoseRoundCount).value;
        int[] wls = new int[6];
        string[] tt = t.Split(',');
        for(int i =0;i<6;i++)
        {
            wls[i] = int.Parse(tt[i]);
        }
        Serclimax.SLGPVP.ScSLGPvP.WinLoseRoundCount = wls;
        t =Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.WinRevertPercent).value;
        float[] wlsf = new float[6];
        tt = t.Split(',');
        for(int i =0;i<6;i++)
        {
            wlsf[i] = float.Parse(tt[i]);
        }
        Serclimax.SLGPVP.ScSLGPvP.WinRevertPercent = wlsf;
        t =Main.Instance.TableMgr.GetGlobalData(Serclimax.ScGlobalDataId.LoseRevertPercent).value;
        wlsf = new float[6];
        tt = t.Split(',');
        for(int i =0;i<6;i++)
        {
            wlsf[i] = float.Parse(tt[i]);
        }

        Serclimax.SLGPVP.ScSLGPvP.LoseRevertPercent = wlsf;
        int[][] rrs = new int[6][];
        for(int i =0;i<6;i++)
        {
            t =Main.Instance.TableMgr.GetGlobalData((Serclimax.ScGlobalDataId)(62+i)).value;
            tt = t.Split(',');
            rrs[i] = new int[6];
            for(int j = 0;j<6;j++)
            {
                rrs[i][j] = int.Parse(tt[j]);
            }
        }
        Serclimax.SLGPVP.ScSLGPvP.RestraintRelations = rrs;
    }


    public static GameStateSLGBattle Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new GameStateSLGBattle();
            }

            return instance;
        }
    }

    public void ShowHurt(Vector3 pos,int type,Int64 hurt)
    {
        if(onShowBeatHurt != null)
        {
            onShowBeatHurt(pos,type,hurt);
        }
    }

    public void BattleEnd()
    {
        Serclimax.GameTime.timeScale = 1;

        CsSLGPVPMgr.instance.BattleEnd();
    }

    public void BattleSkillAnim()
    {
        CsSLGPVPMgr.instance.SkipCamAnim();
    }

    public void OnBattleEnd()
    {

    }

    public override void OnEnter(string _param,System.Action done)
    {
        if (_param != null)
        {
            Dictionary<string, object> param = OurMiniJSON.Json.Deserialize(_param) as Dictionary<string, object>;
            if (param.ContainsKey("battleId"))
            {
                mBattleID = Convert.ToInt32(param["battleId"]);
            }
            if(param.ContainsKey("enbaleLog"))
            {
                mEnableLog = Convert.ToBoolean(param["enbaleLog"]);
            }
        }
        else
        {
            Serclimax.DebugUtils.LogError("Invalid enter param!");
        }
        mLoader = CsSLGPVPMgr.instance.StartPVP(mBattleID,SlgPlayers,heroBuffs,(uint)Slg_Random_Seed,mEnableLog , strAConfig , strDConfig , strPhalanxConfig,done);
    }

    public override void OnUpdate()
    {
        if (mLoader != null)
            mLoader.Update();
        CsSLGPVPMgr.instance.Update();
    }

    public override void OnFixedUpdate()
    {


    }

    public override void OnLeave()
    {
        onGameOver = null;
        Slg_Random_Seed = 0;
        if(!CsSLGPVPMgr.instance.mIsGameOver)
        {
            SlgPlayers = null;
        }
        mLoader = null;
        CsSLGPVPMgr.instance.ClearLevel();
        GUIMgr.Instance.CloseAllMenu();
        Debugger.Log("leave battle state");
    }
}
