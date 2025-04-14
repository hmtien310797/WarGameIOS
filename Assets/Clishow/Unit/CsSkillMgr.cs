using UnityEngine;
using System.Collections;
using System.Collections.Generic;
namespace Clishow
{
    class CsSkillMgr : CsSingletonBehaviour<CsSkillMgr>
    {
        public bool IgnoreDisposeMsg = false;

        public CsBulletEmitter BulletEmitter = null;

        public CsBloodEmitter BoolEmitter = null;

        public CsTrailCanvas TrailCanvas = null;

        public CsBloodEmitter BoomResidualEmitter = null;

        public CsBloodEmitter ButtleBeatenEmitter = null;

        public CsBloodEmitter ButtleSmokeEmitter = null;

        


        private List<ICsSkillInterface> mUnits = new List<ICsSkillInterface>();
        private List<CsBullteSkillIns> mBullteUpdatelist = new List<CsBullteSkillIns>();
        private GameObject mSfxPrefab = null;
        public GameObject UnitSfxPrefab
        {
            get
            {
                if (mSfxPrefab == null)
                {
                    mSfxPrefab = ResourceLibrary.instance.GetUnitSfxPrefab("unit_sfx");
                }
                return mSfxPrefab;
            }
        }
        public override bool IsAutoInit()
        {
            return true;
        }

        public override bool IsGlobal()
        {
            return false;
        }

        public override void OnDestroy()
        {
            base.OnDestroy();
            //for (int i = 0; i < mUnits.Count; i++)
            //{
            //    if (BoolEmitter != null)
            //        BulletEmitter.DestroyBullet(mUnits[i].Bullet);
            //    mUnits[i].Destroy();
            //    mUnits[i] = null;
            //}
            ClearBulltes();
            mUnits.Clear();
            if (BoolEmitter != null)
            {
                GameObject.Destroy(BoolEmitter.gameObject);
            }
            if (BulletEmitter != null)
            {
                GameObject.Destroy(BulletEmitter.gameObject);
            }
            if (BoomResidualEmitter != null)
            {
                GameObject.Destroy(BoomResidualEmitter.gameObject);
            }
            BoolEmitter = null;
            BulletEmitter = null;   
            TrailCanvas = null;
            BoomResidualEmitter = null;
            ButtleBeatenEmitter = null;
            ButtleSmokeEmitter = null;
        }

        public void DisposeSkillMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
        {
            if (IgnoreDisposeMsg)
                return;
            if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_SKILL_MSG)
                return;
            Serclimax.Skill.ScSKillMsg um = msg as Serclimax.Skill.ScSKillMsg;
            if (um == null)
                return;
            int i = um.GetEntityUID();
            if (i < 0 || i >= mUnits.Count)
                return;
            mUnits[i].SyncMsg(um);
        }

        public void DisposeCreateSkillMsg(Serclimax.ScDefineDisMsgEnum tenum, Serclimax.IScMsgBase msg)
        {
            if (IgnoreDisposeMsg)
                return;
            if (tenum != Serclimax.ScDefineDisMsgEnum.SDDM_CREATE_SKILL_MSG)
                return;

            Serclimax.Skill.ScCreateSkillMsg um = msg as Serclimax.Skill.ScCreateSkillMsg;
            if (um == null)
                return;
            if (um.SubCommands.Count != 0)
            {
                for (int i = 0, imax = um.SubCommands.Count; i < imax; i++)
                {
                    RemoveUnit4Command(um.SubCommands[i].InsID);
                }
                for (int i = 0; i < mUnits.Count;)
                {
                    if (mUnits[i] == null)
                    {
                        mUnits.RemoveAt(i);
                    }
                    else
                        i++;
                }
            }

            if (mUnits.Count < um.SkillCount)
            {
                for (int i = 0, imax = um.SkillCount - mUnits.Count; i < imax; i++)
                {
                    mUnits.Add(null);
                }
            }

            if (um.AddCommands.Count != 0)
            {
                for (int i = 0, imax = um.AddCommands.Count; i < imax; i++)
                {
                    CreateUnit4Command(um.AddCommands[i].InsID, um.AddCommands[i].assetName,um.AddCommands[i].TeamID, um.AddCommands[i].SubjoinTime);
                }
            }
        }

        private void RemoveUnit4Command(int id)
        {
            ICsSkillInterface ins = mUnits[id];
            ins.PlayDeadSfx();
            ins.RemoveDestroy();
            mUnits[id] = null;
        }

        private void CreateUnit4Command(int id, string assetName,int teamID,float SubjoinTime)
        {
            CsSkillIns ins = null;
            if (assetName.Contains("none"))
            {
                mUnits[id] = new CsNoneSkillIns();
                return;
                //GameObject obj = null;
                //if (CsObjPoolMgr.Instance.IsContainPool(ResourceLibrary.ASSET_PATH_EFFECT+"Skill_none_node"))
                //{
                //    obj = ResourceLibrary.instance.GetEffectInstanceFromPool("Skill_none_node");
                //}
                //else
                //{
                //    obj = new GameObject("Skill_none_node");
                //    obj.AddComponent<CsSkillIns>();
                //    CsObjPoolMgr.Instance.NewPool(obj, ResourceLibrary.ASSET_PATH_EFFECT + "Skill_none_node");
                //    obj = ResourceLibrary.instance.GetEffectInstanceFromPool("Skill_none_node");
                //}

                //ins = obj.GetComponent<CsSkillIns>();
            }
            else
            {
                if (assetName.Contains("bullet"))
                {
                    CsPoolUnit unit = ResourceLibrary.instance.GetEffectPool(assetName);
                    if (unit != null)
                    {
                        CsSkillIns insoure = unit.UnitSource.GetComponent<CsSkillIns>();
                        if (insoure != null)
                        {
                            CsBullteSkillIns bullte = new CsBullteSkillIns();
                            bullte.ShortTrail = insoure.ShortTrail;
                            bullte.DelayDestroy = insoure.DelayDestroy;
                            Color tColor = insoure.BulletColor;
                            //if (teamID == 1)
                            //{
                            //    tColor += Color.blue;
                            //}
                            //if(teamID == 2)
                            //{
                            //    tColor += Color.yellow;

                            //}
                            bullte.Bullet = BulletEmitter.Emit(insoure.BulletSize, tColor);

                            

                            mBullteUpdatelist.Add(bullte);
                            mUnits[id] = bullte;
                        }
                    }
                    return;
                }
                else
                {
                    ins = ResourceLibrary.instance.GetEffectInstanceFromPool(assetName).GetComponent<CsSkillIns>();
                }
            }

            ins.transform.parent = gameObject.transform;
            ins.gameObject.SetActive(false);
            ins.uid = id;
            ins.SubjoinTime = SubjoinTime;
            ins.SfxData = CsUnitMgr.Instance.UnitSfxData.GetData(ins.SfxTableId);
            if (ins.mUnitAudio == null)
            {
                if (UnitSfxPrefab != null)
                {
                    GameObject sfxObj = UnityEngine.Object.Instantiate(UnitSfxPrefab) as GameObject;
                    ins.mUnitAudio = sfxObj.GetComponent<AudioSource>();
                    sfxObj.transform.parent = ins.transform;
                    sfxObj.transform.position = Vector3.zero;
                }
            }
            mUnits[ins.uid] = ins;
        }

        void UpdateBulltes()
        {
            int imax = mBullteUpdatelist.Count;
            if (imax == 0)
                return;
            for (int i = 0; i < mBullteUpdatelist.Count; )
            {
                if (mBullteUpdatelist[i].IsActived)
                {
                    mBullteUpdatelist[i].Update();
                    i++;
                }
                else
                {
                    mBullteUpdatelist[i].Clear();
                    mBullteUpdatelist.RemoveAt(i);
                }
            }
        }

        void ClearBulltes()
        {
            int imax = mBullteUpdatelist.Count;
            if (imax == 0)
                return;
            for (int i = 0; i < imax; i++)
            {
                mBullteUpdatelist[i].Clear();
            }
            mBullteUpdatelist.Clear();
        }

        void Update()
        {
            UpdateBulltes();
        }
    }
}
