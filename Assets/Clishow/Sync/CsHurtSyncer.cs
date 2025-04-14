using UnityEngine;
using System.Collections;
using Serclimax.Unit;

namespace Clishow
{
    public class CsHurtSyncer : CsSynchronizer<Serclimax.Unit.ScUnitMsg>
    {
        private CsUnit mUnit = null;
        public CsSkillAsset Eff_PointHurt = null;
        public CsSkillAsset Eff_DiffacHurt = null;
        public CsSkillAsset EFf_FireHurt = null;
        public CsHurtSyncer(CsUnit unit)
        {
            mUnit = unit;
        }


        private CsSkillAsset LoadParticle(Serclimax.QuadSpace.ScHitType type)
        {
            string name = string.Empty;
            switch (type)
            {
                case Serclimax.QuadSpace.ScHitType.SHT_POINT:
                    if (string.IsNullOrEmpty(mUnit.Eff_PointHurtName))
                        return null;
                    if (Eff_PointHurt == null)
                    {
                        Eff_PointHurt = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.Eff_PointHurtName).GetComponent<CsSkillAsset>();
                        Eff_PointHurt.gameObject.transform.parent = mUnit.gameObject.transform;
                        Eff_PointHurt.gameObject.SetActive(false);
                        if (Eff_PointHurt.Particle != null)
                        {
                            Eff_PointHurt.Particle.DestroyWhenInvalid = false;
                        }
                    }
                    if (Eff_PointHurt.Particle != null)
                    {
                        Eff_PointHurt.Particle.ReclaimReset();
                    }
                    return Eff_PointHurt;
                case Serclimax.QuadSpace.ScHitType.SHT_DIFFRAC:
                    if (string.IsNullOrEmpty(mUnit.Eff_DiffacHurtName))
                        return null;
                    if (Eff_DiffacHurt == null)
                    {
                        Eff_DiffacHurt = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.Eff_DiffacHurtName).GetComponent<CsSkillAsset>();
                        Eff_DiffacHurt.gameObject.transform.parent = mUnit.gameObject.transform;
                        Eff_DiffacHurt.gameObject.SetActive(false);
                        if (Eff_DiffacHurt.Particle != null)
                        {
                            Eff_DiffacHurt.Particle.DestroyWhenInvalid = false;
                        }
                    }
                    if (Eff_DiffacHurt.Particle != null)
                    {
                        Eff_DiffacHurt.Particle.ReclaimReset();
                    }
                    return Eff_DiffacHurt;
                case Serclimax.QuadSpace.ScHitType.SHT_FIRE:
                    if (string.IsNullOrEmpty(mUnit.EFf_FireHurtName))
                        return null;
                    if (EFf_FireHurt == null)
                    {
                        EFf_FireHurt = ResourceLibrary.instance.GetEffectInstanceFromPool(mUnit.EFf_FireHurtName).GetComponent<CsSkillAsset>();
                        EFf_FireHurt.gameObject.transform.parent = mUnit.gameObject.transform;
                        EFf_FireHurt.gameObject.SetActive(false);
                        if (EFf_FireHurt.Particle != null)
                        {
                            EFf_FireHurt.Particle.DestroyWhenInvalid = false;
                        }
                    }
                    if (EFf_FireHurt.Particle != null)
                    {
                        EFf_FireHurt.Particle.ReclaimReset();
                    }
                    return EFf_FireHurt;
            }
            return null;
        }

        public void DisplayEffect(Serclimax.QuadSpace.ScHitInfo hifinfo)
        {
            if (hifinfo.Hurt <= 0)
                return;
            if (mUnit.BakeObj != null && hifinfo.HitType != Serclimax.QuadSpace.ScHitType.SHT_NIL)
            {
                int pp = Random.Range(0, 100);
                if (pp < 30)
                {
                    mUnit.BakeObj.Blend("hurt", 1f);
                }
            }

            CsSkillAsset p = LoadParticle(hifinfo.HitType);
            if (p == null)
                return;
            Vector3 pos = hifinfo.HitPoint;// mUnit.transform.position;
            pos.y = mUnit.SoliderHight;
            p.transform.position = pos;
            if (mUnit.unitType == (int)Serclimax.Unit.ScUnitType.SUT_BUILD)
            {
                p.transform.forward = -hifinfo.HitDir;
                if (mUnit.SfxData != null && hifinfo.HitType != Serclimax.QuadSpace.ScHitType.SHT_FIRE)
                {
                    string sfxParams = mUnit.SfxData.GetStateSfx(ScUnitAnimState.SUAS_HURT);
                    if (sfxParams != "NA")
                    {
                        string[] s_params = sfxParams.Split(';');
                        string sfxName = s_params[0];
                        AudioManager.Instance.PlaySfx(mUnit.mUnitAudio, sfxName);
                    }
                }
            }
            else if (mUnit.unitType == (int)Serclimax.Unit.ScUnitType.SUT_SOLDIER)
            {
                p.transform.forward = hifinfo.HitDir;
                if (hifinfo.HitType == Serclimax.QuadSpace.ScHitType.SHT_POINT)
                {
                    int pp = Random.Range(0, 100);
                    if (pp < 50)
                        CsSkillMgr.Instance.BoolEmitter.ShowBlood(p.transform.position);
                }

                //hurt sfx
                if (mUnit.SfxData != null)
                {
                    int playRate = Random.Range(0, 100);
                    string sfxParams = mUnit.SfxData.GetStateSfx(ScUnitAnimState.SUAS_HURT);
                    if (sfxParams != "NA")
                    {
                        string[] s_params = sfxParams.Split(';');
                        string sfxName = s_params[0];
                        if (playRate < 30)
                            AudioManager.Instance.PlaySfx(mUnit.mUnitAudio, sfxName);
                    }
                }
            }
            p.transform.forward = -hifinfo.HitDir;
            if (p.Particle != null)
            {
                p.gameObject.SetActive(true);
                p.Particle.Active();

            }
        }

        public override void OnDestroy()
        {
            if (Eff_PointHurt != null)
            {
                Clishow.CsObjPoolMgr.Instance.Destroy(Eff_PointHurt.gameObject);
            }
            Eff_PointHurt = null;
            if (Eff_DiffacHurt != null)
            {
                Clishow.CsObjPoolMgr.Instance.Destroy(Eff_DiffacHurt.gameObject);
            }
            Eff_DiffacHurt = null;
            if (EFf_FireHurt != null)
            {
                Clishow.CsObjPoolMgr.Instance.Destroy(EFf_FireHurt.gameObject);
            }
            EFf_FireHurt = null;
        }

        public override void Sync(ScUnitMsg msg)
        {
            if (msg.HitInfos.Count == 0)
                return;
            switch (msg.HitMode)
            {
                case 1://normal
                    if (mUnit.HUD != null)
                    {
                        mUnit.HUD.Show();
                        mUnit.HUD.SetHp(msg.HP / msg.maxHP);
#if SHOW_HUD_VALUE
                        mUnit.HUD.SetHpNum((int)msg.HP);
#endif
                    }

                    for (int i = 0, imax = msg.HitInfos.Count; i < imax; i++)
                    {
                        DisplayEffect(msg.HitInfos[i]);
                    }
                    break;
                case 2://mine
                    for (int i = 0, imax = msg.HitInfos.Count; i < imax; i++)
                    {
                        if (msg.HitInfos[i].HitType == Serclimax.QuadSpace.ScHitType.SHT_SPECIALMINE)
                        {
                            if (mUnit.HUD != null)
                            {
                                mUnit.HUD.Show();
                                mUnit.HUD.SetHp(msg.HitInfos[i].Hurt / msg.HitInfos[i].SpecialParam);
                            }
                        }
                    }
                    break;
            }
        }
    }
}
