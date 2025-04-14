using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using ProtoMsg;
using Serclimax;

public class PathData  {

    public Color PathBlue = new Color(0,1,1,1);
    public Color PathRed =  Color.red;//new Color(1,73.0f/255.0f,73.0f/255.0f,1);
    public Color PathGreen =  Color.green; //new Color(33.0f/255.0f,1,3.0f/255.0f,1);
    public Color PathWhite = Color.white;
    public Color PathYellow = Color.yellow;//new Color(1,249.0f/255.0f,73.0f/255.0f,1);
    public Color PathViolet = new Color(128, 0, 128);

    public Dictionary<int, SEntryPathInfo> SEntryPathInfo = new Dictionary<int, SEntryPathInfo>();
    private void SimulateEntryPathInfo(SEntryPathInfo data)
    {
        if(data == null)
            return;
        data.fortTitle = 1;
    }

    public void SetData(SEntryPathInfo sEntryPathInfo) {
        //if (!SEntryPathInfo.ContainsKey((int)sEntryPathInfo.pathId))
        //{
            SEntryPathInfo[(int)sEntryPathInfo.pathId] = sEntryPathInfo;
        //}
    }

    public SEntryPathInfo GetData(int index) {
        if (SEntryPathInfo.ContainsKey(index)) {
            return SEntryPathInfo[index];
        }
        return null;
    }

    public void ClearAllCache()
    {
        SEntryPathInfo.Clear();
    }

    public void SetPathData(SEntryPathInfo sEntryPathInfo)
    {
        //SimulateEntryPathInfo(sEntryPathInfo);

        if (sEntryPathInfo.status == (int)PathMoveStatus.PathMoveStatus_Go || sEntryPathInfo.status == (int)PathMoveStatus.PathMoveStatus_Back) {
            //只绘制超时不超过1秒的路线
            int charId = WorldMapMgr.Instance.CharId;
            int selfGuildId = WorldMapMgr.Instance.GuildId;
            if (sEntryPathInfo.starttime + sEntryPathInfo.time + 1 > GameTime.GetSecTime()) {
                OwnerGuildInfo guildMsg = sEntryPathInfo.ownerguild;
                //if (sEntryPathInfo.pathType == (int)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                //{
                //    if ((int)sEntryPathInfo.tarGuildId != WorldMapMgr.instance.GuildId)
                //        return;
                //}
                Color color;
                int pathStatus = sEntryPathInfo.status;
                Position sourcePos = new Position();
                Position targetPos = new Position();
                if (pathStatus == (int)PathMoveStatus.PathMoveStatus_Go)
                {
                    sourcePos = sEntryPathInfo.sourcePos;
                    targetPos = sEntryPathInfo.targetPos;
                }
                else if (pathStatus == (int)PathMoveStatus.PathMoveStatus_Back)
                {
                    sourcePos = sEntryPathInfo.targetPos;
                    targetPos = sEntryPathInfo.sourcePos;
                }
                if(sEntryPathInfo.govtOfficial > 0)
                {
                    ScOfficialData scOfficialData = Main.Instance.TableMgr.GetOfficialByID((int)sEntryPathInfo.govtOfficial);
                    if (scOfficialData.grade == 1)
                    {
                        color = PathYellow;
                        WorldMapMgr.Instance.AddLine(sEntryPathInfo, (int)sourcePos.x, (int)sourcePos.y, (int)targetPos.x, (int)targetPos.y, color);
                        return;
                    }
                }
                if (sEntryPathInfo.guildOfficialId > 0)
                {
                    ScUnionOfficialData scUnionOfficialData = Main.Instance.TableMgr.GetUnionOfficialByID((int)sEntryPathInfo.guildOfficialId);
                    if (scUnionOfficialData.isLord == 1)
                    {
                        color = PathYellow;
                        WorldMapMgr.Instance.AddLine(sEntryPathInfo, (int)sourcePos.x, (int)sourcePos.y, (int)targetPos.x, (int)targetPos.y, color);
                        return;
                    }
                }
                if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_MonsterSiege)
                {
                    color = PathWhite;                                       
                    WorldMapMgr.Instance.AddLine(sEntryPathInfo, (int)sourcePos.x, (int)sourcePos.y, (int)targetPos.x, (int)targetPos.y, color);
                    return;
                }
                if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_Nemesis)
                {
                    color = PathRed;
                    WorldMapMgr.Instance.AddLine(sEntryPathInfo, (int)sourcePos.x, (int)sourcePos.y, (int)targetPos.x, (int)targetPos.y, color);
                    return;
                }
                if (sEntryPathInfo.pathType == (uint)ProtoMsg.TeamMoveType.TeamMoveType_Prisoner)
                {
                    color = PathViolet;
                    WorldMapMgr.Instance.AddLine(sEntryPathInfo, (int)sourcePos.x, (int)sourcePos.y, (int)targetPos.x, (int)targetPos.y, color);
                    return;
                }
                if (sEntryPathInfo.charid == charId)
                {
                    color = PathGreen;
                }
                else
                {
                        if (selfGuildId != 0 && selfGuildId == (int)guildMsg.guildid)
                            color = PathBlue;
                        else
                            color = PathRed;
                    
                }
                //if(sEntryPathInfo.guildOfficialId > 0 )
                //飞机线
                WorldMapMgr.Instance.AddLine(sEntryPathInfo, (int)sourcePos.x, (int)sourcePos.y, (int)targetPos.x, (int)targetPos.y, color);

            }
        }
    }
}
