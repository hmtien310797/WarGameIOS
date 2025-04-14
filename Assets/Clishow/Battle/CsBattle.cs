using UnityEngine;
using System.Collections;
using Serclimax;
using System;

namespace Clishow
{
    public class CsBattle : CsSingletonBehaviour<CsBattle>
    {
        public delegate void OnBattleInfo(Serclimax.Battle.ScBattleInfoMsg battleInfoMsg);

        public OnBattleInfo onBattleInfo;

        public delegate void OnBattleStatus(Serclimax.Battle.ScBattleStatusMsg battleStatusMsg);

        public OnBattleStatus onBattleStatus;

        public delegate void OnBattleUpdate(Serclimax.Battle.ScBattleUpdateMsg battleUpdateMsg);

        public OnBattleUpdate onBattleUpdate;

        public delegate void OnPlayerInfo(Serclimax.Player.ScPlayerInfoMsg playerInfoMsg);

        public OnPlayerInfo onPlayerInfo;

        public delegate void OnBattleDrop(Serclimax.Battle.ScBattleDropMsg battleDropMsg);

        public OnBattleDrop onBattleDrop;

        public delegate void OnPlayerUpdate(Serclimax.Player.ScPlayerUpdateMsg playerUpdateMsg);

        public OnPlayerUpdate onPlayerUpdate;

        public delegate void OnDropUpdate(Serclimax.Player.ScDropUpdateMsg dropUpdateMsg);

        public OnDropUpdate onDropUpdate;

        public delegate void OnCastSkill(Serclimax.Player.ScCastSkillMsg enegyUpdateMsg);

        public OnCastSkill onCastSkill;
        internal void DisposeBattleInfoMsg(ScDefineDisMsgEnum tenum, IScMsgBase msg)
        {
            Serclimax.Battle.ScBattleInfoMsg bm = msg as Serclimax.Battle.ScBattleInfoMsg;
            if (bm == null)
            {
                return;
            }

            if (onBattleInfo != null)
            {
                onBattleInfo(bm);
            }
        }

        internal void DisposeBattleUpdateMsg(ScDefineDisMsgEnum tenum, IScMsgBase msg)
        {
            Serclimax.Battle.ScBattleUpdateMsg bm = msg as Serclimax.Battle.ScBattleUpdateMsg;
            if (bm == null)
            {
                return;
            }

            if (onBattleUpdate != null)
            {
                onBattleUpdate(bm);
            }
        }

        internal void DisposePlayerInfoMsg(ScDefineDisMsgEnum tenum, IScMsgBase msg)
        {
            Serclimax.Player.ScPlayerInfoMsg pm = msg as Serclimax.Player.ScPlayerInfoMsg;
            if (pm == null)
            {
                return;
            }

            if (onPlayerInfo != null)
            {
                onPlayerInfo(pm);
            }
        }

        public void RequestCast(int castIndex, Vector3 targetPos)
        {
            SceneManager.instance.gScRoots.GetBattle().RequestCast(castIndex, targetPos);
        }

        public string RequestCast2RedCmd(int castIndex, Vector3 targetPos)
        {
            return SceneManager.instance.gScRoots.GetBattle().RequestCast2RedCmd(castIndex, targetPos);
        }

        public void RequestCast4RedCmd(string str)
        {
            SceneManager.instance.gScRoots.GetBattle().RequestCast4RedCmd(str);
        }

        public void NotifyTitleFinished()
        {
            SceneManager.instance.gScRoots.GetBattle().OnTitleFinished();
        }

        internal void DisposeBattleInitMsg(ScDefineDisMsgEnum tenum, IScMsgBase msg)
        {
            GameStateBattle stateBattle = Main.Instance.CurrentGameState as GameStateBattle;
            if (stateBattle != null)
            {
                stateBattle.OnBattleInited();
            }
        }

        internal void DisposeBattleDropMsg(ScDefineDisMsgEnum tenum, IScMsgBase msg)
        {
            Serclimax.Battle.ScBattleDropMsg dm = msg as Serclimax.Battle.ScBattleDropMsg;
            if (dm == null)
            {
                return;
            }

            if (onBattleDrop != null)
            {
                onBattleDrop(dm);
            }
        }

        internal void DisposePlayerUpdateMsg(ScDefineDisMsgEnum tenum, IScMsgBase msg)
        {
            Serclimax.Player.ScPlayerUpdateMsg pm = msg as Serclimax.Player.ScPlayerUpdateMsg;

            if (pm == null)
            {
                return;
            }

            if (onPlayerUpdate != null)
            {
                onPlayerUpdate(pm);
            }
        }

        internal void DisposeDropUpdateMsg(ScDefineDisMsgEnum tenum, IScMsgBase msg)
        {
            Serclimax.Player.ScDropUpdateMsg dm = msg as Serclimax.Player.ScDropUpdateMsg;
            if (dm == null)
            {
                return;
            }

            if (onDropUpdate != null)
            {
                onDropUpdate(dm);
            }
        }

        internal void DisposeCastSkillMsg(ScDefineDisMsgEnum tenum, IScMsgBase msg)
        {
            Serclimax.Player.ScCastSkillMsg cm = msg as Serclimax.Player.ScCastSkillMsg;
            if (cm == null)
            {
                return;
            }

            if (onCastSkill != null)
            {
                onCastSkill(cm);
            }
        }

        internal void DisposeBattleStatusMsg(ScDefineDisMsgEnum tenum, IScMsgBase msg)
        {
            Serclimax.Battle.ScBattleStatusMsg m = msg as Serclimax.Battle.ScBattleStatusMsg;

            if (m == null)
            {
                return;
            }

            if (onBattleStatus != null)
            {
                onBattleStatus(m);
            }
        }
    }
}
