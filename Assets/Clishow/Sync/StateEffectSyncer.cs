using UnityEngine;
using System.Collections;
using Clishow;

namespace Clishow
{
    public class CsStateEffectSyncer : CsSynchronizer<Serclimax.Unit.ScUnitMsg>
    {
        private CsUnit mUnit;
        public  UISprite SprStateEffect = null;

        private int mCurEffectState = -1;
        private int mPreEffectState;
        public CsStateEffectSyncer(CsUnit unit)
        {
            mUnit = unit;
            
        }
        public override void Sync(Serclimax.Unit.ScUnitMsg msg)
        {
            if (msg.AnimState == 10)
            {
                if (mUnit.StateEffect != null)
                {
                    mUnit.StateEffect.SetProgress(msg.StateTime, msg.StateDuration);
                }
            }
        }

        public override void Update(float dt)
        {

        }
    }
}