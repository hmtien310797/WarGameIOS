using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;

namespace Clishow
{
    public class CsSLGSimulate : EditorWindow
    {
        public float ExtralAttackForce = 1;
        public float AssistForce =1;
        public float RestraintForce =1.5f;
        public float WeakForce = 0.5f;
        public float DefenseForce = 1;
        public float CriticalChance = 0.2f;
        public float CriticalFactor = 1.5f;
        public float BlockChance = 0.2f;
        public float BlockFactor = 0.5f;
        public float MagicHurtFactor6 = 6;
        public float MagicHurtFactor14 = 14;
        public int[] WinLoseRoundCount = new int[3] { 10,110,200};
        public float[] WinRevertPercent = new float[3] { 0.1f,0.2f,0.3f};
        public float[] LoseRevertPercent = new float[3] { 0.1f,0.2f,0.3f};
        public int[][] RestraintRelations = new int[6][]{ 
        new int[]{0,1,0,0,0,0},
        new int[]{-1,0,1,0,0,0},
        new int[]{0,-1,0,1,0,0},
        new int[]{1,0,0,-1,0,0},
        new int[]{1,1,0,0,0,0},
        new int[]{0,0,1,1,0,0}
        };
        [MenuItem("Tools/SLG PVP SIMULATE ...")]
        static void Init()
        {
            // Get existing open window or if none, make a new one:
            CsSLGSimulate window = (CsSLGSimulate)EditorWindow.GetWindow<CsSLGSimulate>("SLG PVP SIMULATE");
            window.Show();
        }

        public Serclimax.SLGPVP.ScArmy[] GArmy1()
        {
            List<Serclimax.SLGPVP.ScArmy> armys= new List<Serclimax.SLGPVP.ScArmy>();
            armys.Add(new Serclimax.SLGPVP.ScArmy(){Armor =1,ArmyType =1,Attack = 10,Count = 10,HP = 5,Level =1,Penetrate = 0.5f,PhalanxType = 1 });
            return armys.ToArray();
        }

        public Serclimax.SLGPVP.ScArmy[] GArmy2()
        {
            List<Serclimax.SLGPVP.ScArmy> armys= new List<Serclimax.SLGPVP.ScArmy>();
            armys.Add(new Serclimax.SLGPVP.ScArmy(){Armor =1,ArmyType =1,Attack = 10,Count = 10,HP = 5,Level =1,Penetrate = 0.5f,PhalanxType = 1 });
            return armys.ToArray();
        }

        public Serclimax.SLGPVP.ScSLGPlayer[] GPlayer1(bool isdefend)
        {
            List<Serclimax.SLGPVP.ScSLGPlayer> players = new List<Serclimax.SLGPVP.ScSLGPlayer>();
            players.Add(new Serclimax.SLGPVP.ScSLGPlayer() {IsSponsor = 0,IsDefend = isdefend?1:0,Armys = GArmy1(),Formation=new int[]{1 },SupportRevert = 1 });
            return players.ToArray();
        }

        public Serclimax.SLGPVP.ScSLGPlayer[] GPlayer2(bool isdefend)
        {
            List<Serclimax.SLGPVP.ScSLGPlayer> players = new List<Serclimax.SLGPVP.ScSLGPlayer>();
            players.Add(new Serclimax.SLGPVP.ScSLGPlayer() {IsSponsor = 0,IsDefend = isdefend?1:0,Armys = GArmy1(),Formation=new int[]{1 },SupportRevert = 1 });
            return players.ToArray();
        }

        void Simulate()
        {
            Serclimax.SLGPVP.ScSLGPvP.ExtralAttackForce = ExtralAttackForce;
            Serclimax.SLGPVP.ScSLGPvP.AssistForce = AssistForce;
            Serclimax.SLGPVP.ScSLGPvP.RestraintForce = RestraintForce;
            Serclimax.SLGPVP.ScSLGPvP.WeakForce = WeakForce;
            Serclimax.SLGPVP.ScSLGPvP.DefenseForce = DefenseForce;
            Serclimax.SLGPVP.ScSLGPvP.CriticalChance = CriticalChance;
            Serclimax.SLGPVP.ScSLGPvP.CriticalFactor = CriticalFactor;
            Serclimax.SLGPVP.ScSLGPvP.BlockChance = BlockChance;
            Serclimax.SLGPVP.ScSLGPvP.BlockFactor = BlockFactor;
            Serclimax.SLGPVP.ScSLGPvP.WinLoseRoundCount = WinLoseRoundCount;
            Serclimax.SLGPVP.ScSLGPvP.WinRevertPercent = WinRevertPercent;
            Serclimax.SLGPVP.ScSLGPvP.LoseRevertPercent = LoseRevertPercent;
            Serclimax.SLGPVP.ScSLGPvP.RestraintRelations = RestraintRelations;
            Serclimax.SLGPVP.ScSLGPvP.MagicHurtFactor6 = MagicHurtFactor6;
            Serclimax.SLGPVP.ScSLGPvP.MagicHurtFactor14 = MagicHurtFactor14;
            Serclimax.SLGPVP.ScSLGPvP pvp = new Serclimax.SLGPVP.ScSLGPvP();
            List<Serclimax.SLGPVP.ScSLGPlayer> players = new List<Serclimax.SLGPVP.ScSLGPlayer>();
            players.AddRange(GPlayer1(false));
            players.AddRange(GPlayer2(true));
            pvp.StartBattle(players.ToArray(),0,true);
            pvp.PrintLog();
        }

        void OnGUI()
        {
            EditorGUILayout.BeginHorizontal();
            if(GUILayout.Button("Simulate"))
            {
                Simulate();
            }
            EditorGUILayout.EndHorizontal();
        }
    }
}
